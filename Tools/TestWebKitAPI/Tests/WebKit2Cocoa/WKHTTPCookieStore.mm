/*
 * Copyright (C) 2017 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"

#import "PlatformUtilities.h"
#import <WebKit/WKFoundation.h>
#import <WebKit/WKHTTPCookieStore.h>
#import <WebKit/WKWebsiteDataStorePrivate.h>
#import <wtf/RetainPtr.h>

#if WK_API_ENABLED

static bool gotFlag;
uint64_t observerCallbacks;
RetainPtr<WKHTTPCookieStore> globalCookieStore;

@interface CookieObserver : NSObject<WKHTTPCookieStoreObserver>
- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore;
@end

@implementation CookieObserver

- (void)cookiesDidChangeInCookieStore:(WKHTTPCookieStore *)cookieStore
{
    ASSERT_EQ(cookieStore, globalCookieStore.get());
    ++observerCallbacks;
}

@end

TEST(WebKit2, WKHTTPCookieStore)
{
    auto webView = adoptNS([[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)]);
    [webView loadHTMLString:@"Oh hello" baseURL:[NSURL URLWithString:@"http://webkit.org"]];

    globalCookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
    RetainPtr<CookieObserver> observer1 = adoptNS([[CookieObserver alloc] init]);
    RetainPtr<CookieObserver> observer2 = adoptNS([[CookieObserver alloc] init]);
    [globalCookieStore addObserver:observer1.get()];
    [globalCookieStore addObserver:observer2.get()];

    NSArray<NSHTTPCookie *> *cookies = nil;
    [globalCookieStore getAllCookies:[cookiesPtr = &cookies](NSArray<NSHTTPCookie *> *nsCookies) {
        *cookiesPtr = [nsCookies retain];
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);

    ASSERT_EQ(cookies.count, 0u);
    [cookies release];

    gotFlag = false;

    RetainPtr<NSHTTPCookie> cookie1 = [NSHTTPCookie cookieWithProperties:@{
        NSHTTPCookiePath: @"/",
        NSHTTPCookieName: @"CookieName",
        NSHTTPCookieValue: @"CookieValue",
        NSHTTPCookieDomain: @".www.webkit.org",
        NSHTTPCookieSecure: @"TRUE",
        NSHTTPCookieDiscard: @"TRUE",
        NSHTTPCookieMaximumAge: @"10000",
    }];

    RetainPtr<NSHTTPCookie> cookie2 = [NSHTTPCookie cookieWithProperties:@{
        NSHTTPCookiePath: @"/path",
        NSHTTPCookieName: @"OtherCookieName",
        NSHTTPCookieValue: @"OtherCookieValue",
        NSHTTPCookieDomain: @".www.w3c.org",
        NSHTTPCookieMaximumAge: @"10000",
    }];

    [globalCookieStore setCookie:cookie1.get() completionHandler:[](){
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);
    gotFlag = false;

    [globalCookieStore setCookie:cookie2.get() completionHandler:[](){
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);
    gotFlag = false;

    [globalCookieStore getAllCookies:[cookiesPtr = &cookies](NSArray<NSHTTPCookie *> *nsCookies) {
        *cookiesPtr = [nsCookies retain];
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);
    gotFlag = false;

    ASSERT_EQ(cookies.count, 2u);
    ASSERT_EQ(observerCallbacks, 4u);

    for (NSHTTPCookie *cookie : cookies) {
        if ([cookie.name isEqual:@"CookieName"]) {
            ASSERT_TRUE([cookie1.get().path isEqualToString:cookie.path]);
            ASSERT_TRUE([cookie1.get().value isEqualToString:cookie.value]);
            ASSERT_TRUE([cookie1.get().domain isEqualToString:cookie.domain]);
            ASSERT_TRUE(cookie1.get().secure);
            ASSERT_TRUE(cookie1.get().sessionOnly);
        } else {
            ASSERT_TRUE([cookie2.get().path isEqualToString:cookie.path]);
            ASSERT_TRUE([cookie2.get().value isEqualToString:cookie.value]);
            ASSERT_TRUE([cookie2.get().name isEqualToString:cookie.name]);
            ASSERT_TRUE([cookie2.get().domain isEqualToString:cookie.domain]);
            ASSERT_FALSE(cookie2.get().secure);
            ASSERT_FALSE(cookie2.get().sessionOnly);
        }
    }
    [cookies release];

    [globalCookieStore deleteCookie:cookie2.get() completionHandler:[](){
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);
    gotFlag = false;

    [globalCookieStore getAllCookies:[cookiesPtr = &cookies](NSArray<NSHTTPCookie *> *nsCookies) {
        *cookiesPtr = [nsCookies retain];
        gotFlag = true;
    }];

    TestWebKitAPI::Util::run(&gotFlag);
    gotFlag = false;

    ASSERT_EQ(cookies.count, 1u);
    ASSERT_EQ(observerCallbacks, 6u);

    for (NSHTTPCookie *cookie : cookies) {
        ASSERT_TRUE([cookie1.get().path isEqualToString:cookie.path]);
        ASSERT_TRUE([cookie1.get().value isEqualToString:cookie.value]);
        ASSERT_TRUE([cookie1.get().domain isEqualToString:cookie.domain]);
        ASSERT_TRUE(cookie1.get().secure);
        ASSERT_TRUE(cookie1.get().sessionOnly);
    }
    [cookies release];

    [globalCookieStore removeObserver:observer1.get()];
    [globalCookieStore removeObserver:observer2.get()];
}

#endif
