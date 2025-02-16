/*
 * Copyright (C) 2010 Apple Inc. All rights reserved.
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
#include "APIError.h"

#include "WebCoreArgumentCoders.h"
#include <wtf/NeverDestroyed.h>
#include <wtf/text/WTFString.h>

namespace API {

const WTF::String& Error::webKitErrorDomain()
{
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitErrorDomain"));
    return webKitErrorDomainString;
}

const WTF::String& Error::webKitNetworkErrorDomain()
{
#if USE(GLIB)
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitNetworkError"));
    return webKitErrorDomainString;
#else
    return webKitErrorDomain();
#endif
}

const WTF::String& Error::webKitPolicyErrorDomain()
{
#if USE(GLIB)
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitPolicyError"));
    return webKitErrorDomainString;
#else
    return webKitErrorDomain();
#endif
}

const WTF::String& Error::webKitPluginErrorDomain()
{
#if USE(GLIB)
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitPluginError"));
    return webKitErrorDomainString;
#else
    return webKitErrorDomain();
#endif
}

#if USE(SOUP)
const WTF::String& Error::webKitDownloadErrorDomain()
{
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitDownloadError"));
    return webKitErrorDomainString;
}
#endif

#if PLATFORM(GTK)
const WTF::String& Error::webKitPrintErrorDomain()
{
    static NeverDestroyed<WTF::String> webKitErrorDomainString(ASCIILiteral("WebKitPrintError"));
    return webKitErrorDomainString;
}
#endif

void Error::encode(IPC::Encoder& encoder) const
{
    encoder << platformError();
}

bool Error::decode(IPC::Decoder& decoder, RefPtr<Object>& result)
{
    WebCore::ResourceError error;
    if (!decoder.decode(error))
        return false;
    
    result = create(error);
    return true;
}

} // namespace WebKit
