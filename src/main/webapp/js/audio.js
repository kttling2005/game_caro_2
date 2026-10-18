window.CaroAudio = (function () {
    let ctx = null;
    let bgmGain = null;
    let bgmPlaying = false;
    let bgmWanted = false;
    let nextNoteTime = 0;
    let noteIndex = 0;
    let schedulerId = null;

    // Giai điệu 8-bit chậm, lặp lại (C major)
    const NOTES = [
        261.63, 329.63, 392.00, 329.63,
        349.23, 440.00, 523.25, 440.00,
        392.00, 493.88, 587.33, 493.88,
        523.25, 392.00, 329.63, 261.63
    ];
    const NOTE_DUR = 0.38;

    function getContext() {
        if (!ctx) {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            ctx = new AudioContext();
        }
        if (ctx.state === "suspended") {
            ctx.resume();
        }
        return ctx;
    }

    function getVolume() {
        const slider = document.getElementById("volumeSlider");
        if (slider) {
            return parseFloat(slider.value) / 100;
        }
        const vol = localStorage.getItem("caro_volume");
        return vol !== null ? parseFloat(vol) / 100 : 0.8;
    }

    function isBgmEnabled() {
        return localStorage.getItem("caro_bgm") === "true";
    }

    function ensureBgmGain() {
        const audio = getContext();
        if (!bgmGain) {
            bgmGain = audio.createGain();
            bgmGain.connect(audio.destination);
        }
        bgmGain.gain.setValueAtTime(1, audio.currentTime);
        return bgmGain;
    }

    function scheduleNote(freq, time) {
        const peak = getVolume() * 0.055;
        if (peak <= 0) return;

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "square";
        osc.frequency.setValueAtTime(freq, time);

        const start = Math.max(peak, 0.0001);
        gain.gain.setValueAtTime(0.0001, time);
        gain.gain.exponentialRampToValueAtTime(start, time + 0.03);
        gain.gain.exponentialRampToValueAtTime(0.0001, time + NOTE_DUR * 0.85);

        osc.connect(gain);
        gain.connect(bgmGain);
        osc.start(time);
        osc.stop(time + NOTE_DUR);
    }

    function scheduler() {
        if (!bgmPlaying) return;
        const lookahead = 0.25;
        while (nextNoteTime < ctx.currentTime + lookahead) {
            scheduleNote(NOTES[noteIndex], nextNoteTime);
            nextNoteTime += NOTE_DUR;
            noteIndex = (noteIndex + 1) % NOTES.length;
        }
        schedulerId = setTimeout(scheduler, 80);
    }

    function startBgm() {
        bgmWanted = true;
        if (!isBgmEnabled() || bgmPlaying) return;

        try {
            ensureBgmGain();
            bgmPlaying = true;
            noteIndex = 0;
            nextNoteTime = ctx.currentTime + 0.05;
            scheduler();
        } catch (e) {
            console.warn("BGM error:", e);
        }
    }

    function stopBgm() {
        bgmWanted = false;
        bgmPlaying = false;
        if (schedulerId) {
            clearTimeout(schedulerId);
            schedulerId = null;
        }
        if (bgmGain && ctx) {
            bgmGain.gain.setTargetAtTime(0, ctx.currentTime, 0.08);
        }
    }

    function syncBgm() {
        if (isBgmEnabled()) {
            startBgm();
        } else {
            stopBgm();
        }
    }

    function unlock() {
        try {
            getContext();
            if (bgmWanted && isBgmEnabled() && !bgmPlaying) {
                startBgm();
            }
        } catch (e) {
            // Autoplay có thể bị chặn đến khi người chơi tương tác
        }
    }

    document.addEventListener("pointerdown", unlock, { passive: true });

    return {
        startBgm: startBgm,
        stopBgm: stopBgm,
        syncBgm: syncBgm,
        isBgmEnabled: isBgmEnabled
    };
})();
