/*
 * Copyright (C) 2015-2017 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer
 *    in the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of Ericsson nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#if ENABLE(MEDIA_STREAM)

#include "FontCascade.h"
#include "ImageBuffer.h"
#include "MockRealtimeMediaSource.h"
#include <wtf/RunLoop.h>

namespace WebCore {

class MockRealtimeAudioSource : public MockRealtimeMediaSource {
public:

    static CaptureSourceOrError create(const String&, const MediaConstraints*);
    static RefPtr<MockRealtimeAudioSource> createMuted(const String& name);

    static AudioCaptureFactory& factory();

    virtual ~MockRealtimeAudioSource() = default;

protected:
    MockRealtimeAudioSource(const String& name = ASCIILiteral("Mock audio device"));

    void startProducingData() final;
    void stopProducingData() final;

    virtual void render(double) { }

    double elapsedTime();
    static Seconds renderInterval() { return 60_ms; }

private:

    bool applyVolume(double) override { return true; }
    bool applySampleRate(int) override { return true; }
    bool applySampleSize(int) override { return true; }
    bool applyEchoCancellation(bool) override { return true; }

    void updateSettings(RealtimeMediaSourceSettings&) override;
    void initializeCapabilities(RealtimeMediaSourceCapabilities&) override;
    void initializeSupportedConstraints(RealtimeMediaSourceSupportedConstraints&) override;

    void tick();

    bool isCaptureSource() const final { return true; }

    RunLoop::Timer<MockRealtimeAudioSource> m_timer;
    double m_startTime { NAN };
    double m_lastRenderTime { NAN };
    double m_elapsedTime { 0 };
};

} // namespace WebCore

#endif // ENABLE(MEDIA_STREAM)
