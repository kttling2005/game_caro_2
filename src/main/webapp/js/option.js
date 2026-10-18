// ==========================================
// OPTION & PROFILE JAVASCRIPT
// ==========================================

// 1. CHUYỂN ĐỔI CÁC TABS
function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));

    const activeBtn = document.getElementById('tab-btn-' + tabId);
    const activePanel = document.getElementById('tab-' + tabId);

    if (activeBtn) activeBtn.classList.add('active');
    if (activePanel) activePanel.classList.add('active');

    // Lưu tab hiện tại vào sessionStorage để sau khi reload/post vẫn giữ nguyên tab đó
    sessionStorage.setItem('currentOptionTab', tabId);
}

function isOptionUrl(url) {
    try {
        return new URL(url, window.location.origin).pathname.includes('/option');
    } catch (e) {
        return false;
    }
}

function rememberOptionReturnUrl() {
    const referrer = document.referrer;
    if (referrer && !isOptionUrl(referrer)) {
        sessionStorage.setItem('optionReturnUrl', referrer);
    }
}

function closeOption() {
    const returnUrl = sessionStorage.getItem('optionReturnUrl');
    sessionStorage.removeItem('optionReturnUrl');

    if (returnUrl && !isOptionUrl(returnUrl)) {
        window.location.href = returnUrl;
        return;
    }

    if (window.history.length > 1) {
        window.history.back();
        return;
    }

    window.location.href = contextPath + "/home";
}

// Khôi phục tab trước đó nếu có
document.addEventListener('DOMContentLoaded', () => {
    rememberOptionReturnUrl();

    const savedTab = sessionStorage.getItem('currentOptionTab');
    if (savedTab && document.getElementById('tab-' + savedTab)) {
        switchTab(savedTab);
    }

    initSettings();
});

function goBack() {
    window.location.href = contextPath + "/home";
}

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeOption();
    }
});

function closeAlert(btn) {
    const alert = btn.closest('.alert');
    if (alert) alert.style.display = 'none';
}

// 2. CHỌN AVATAR CÓ SẴN (PRESET AVATAR)
function selectPresetAvatar(avatarFile, elem) {
    document.querySelectorAll('.preset-avatar-item').forEach(item => item.classList.remove('selected'));
    elem.classList.add('selected');

    document.getElementById('selectedPresetInput').value = avatarFile;
    document.getElementById('savePresetBtn').disabled = false;

    // Xem trước trực tiếp trên ảnh đại diện lớn
    const previewImg = document.getElementById('currentAvatarPreview');
    if (previewImg) {
        previewImg.src = contextPath + "/assets/avatars/" + avatarFile;
    }
}

// 3. TỰ TẢI ẢNH LÊN TỪ MÁY TÍNH (CUSTOM UPLOAD & LIVE PREVIEW)
function triggerFileInput() {
    document.getElementById('avatarFileInput').click();
}

const dropzone = document.getElementById('uploadDropzone');
const fileInput = document.getElementById('avatarFileInput');

if (dropzone && fileInput) {
    ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, (e) => {
            e.preventDefault();
            dropzone.classList.add('dragover');
        });
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, (e) => {
            e.preventDefault();
            dropzone.classList.remove('dragover');
        });
    });

    dropzone.addEventListener('drop', (e) => {
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            fileInput.files = files;
            handleFileSelect(files[0]);
        }
    });

    fileInput.addEventListener('change', () => {
        if (fileInput.files.length > 0) {
            handleFileSelect(fileInput.files[0]);
        }
    });
}

function handleFileSelect(file) {
    if (!file) return;

    // Kiểm tra định dạng
    const validTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    if (!validTypes.includes(file.type)) {
        alert('Vui lòng chọn tệp hình ảnh hợp lệ (PNG, JPG, WEBP, GIF)!');
        fileInput.value = '';
        return;
    }

    // Kiểm tra dung lượng (tối đa 3MB)
    if (file.size > 3 * 1024 * 1024) {
        alert('Dung lượng ảnh vượt quá 3MB! Vui lòng chọn ảnh nhẹ hơn.');
        fileInput.value = '';
        return;
    }

    // Xem trước tức thì (Live Preview)
    const reader = new FileReader();
    reader.onload = function (e) {
        const previewImg = document.getElementById('currentAvatarPreview');
        if (previewImg) {
            previewImg.src = e.target.result;
        }

        const dropzoneText = dropzone.querySelector('.dropzone-text');
        if (dropzoneText) {
            dropzoneText.textContent = "Đã chọn: " + file.name + " (" + Math.round(file.size / 1024) + " KB)";
        }

        const submitBtn = document.getElementById('uploadAvatarBtn');
        if (submitBtn) {
            submitBtn.style.display = 'inline-flex';
        }
    };
    reader.readAsDataURL(file);
}

// 4. QUẢN LÝ CÀI ĐẶT GAME & ÂM THANH (LOCALSTORAGE & WEB AUDIO API)
let audioCtx = null;

function getAudioContext() {
    if (!audioCtx) {
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        audioCtx = new AudioContext();
    }
    if (audioCtx.state === 'suspended') {
        audioCtx.resume();
    }
    return audioCtx;
}

function setToneGain(gainNode, ctx, startTime, peak, duration) {
    const start = Math.max(peak, 0.0001);
    gainNode.gain.setValueAtTime(start, startTime);
    gainNode.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
}

// Phát âm thanh tiếng "cắc" khi đánh cờ (Retro SFX)
function playSoundMove() {
    try {
        const vol = getVolume();
        if (vol <= 0) return;

        const ctx = getAudioContext();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(800, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.08);
        setToneGain(gain, ctx, ctx.currentTime, vol * 0.4, 0.08);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start();
        osc.stop(ctx.currentTime + 0.08);
    } catch (e) {
        console.warn("Audio error:", e);
    }
}

// Phát âm thanh chiến thắng
function playSoundWin() {
    try {
        const vol = getVolume();
        if (vol <= 0) return;

        const ctx = getAudioContext();
        const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6

        notes.forEach((freq, idx) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            const startTime = ctx.currentTime + idx * 0.1;

            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, startTime);
            setToneGain(gain, ctx, startTime, vol * 0.35, 0.25);

            osc.connect(gain);
            gain.connect(ctx.destination);

            osc.start(startTime);
            osc.stop(startTime + 0.25);
        });
    } catch (e) {
        console.warn("Audio error:", e);
    }
}

function getVolume() {
    const slider = document.getElementById('volumeSlider');
    if (slider) {
        return parseFloat(slider.value) / 100;
    }
    const vol = localStorage.getItem('caro_volume');
    return vol !== null ? parseFloat(vol) / 100 : 0.8;
}

// Khởi tạo trạng thái cài đặt từ localStorage
function initSettings() {
    const sfx = localStorage.getItem('caro_sfx') !== 'false';
    const bgm = localStorage.getItem('caro_bgm') === 'true';
    const coords = localStorage.getItem('caro_coords') !== 'false';
    const highlight = localStorage.getItem('caro_highlight') !== 'false';
    const volume = localStorage.getItem('caro_volume') || 80;

    const sfxToggle = document.getElementById('sfxToggle');
    const bgmToggle = document.getElementById('bgmToggle');
    const coordsToggle = document.getElementById('coordsToggle');
    const highlightToggle = document.getElementById('highlightToggle');
    const volumeSlider = document.getElementById('volumeSlider');
    const volumeValue = document.getElementById('volumeValue');

    if (sfxToggle) sfxToggle.checked = sfx;
    if (bgmToggle) bgmToggle.checked = bgm;
    if (coordsToggle) coordsToggle.checked = coords;
    if (highlightToggle) highlightToggle.checked = highlight;
    if (volumeSlider) {
        volumeSlider.value = volume;
        if (volumeValue) volumeValue.textContent = volume + "%";
    }
}

function onBgmToggleChange(checked) {
    localStorage.setItem('caro_bgm', checked);
    if (!window.CaroAudio) return;
    if (checked) {
        CaroAudio.startBgm();
    } else {
        CaroAudio.stopBgm();
    }
}

// Lưu cài đặt vào localStorage
function saveGameSettings() {
    const sfx = document.getElementById('sfxToggle').checked;
    const bgm = document.getElementById('bgmToggle').checked;
    const coords = document.getElementById('coordsToggle').checked;
    const highlight = document.getElementById('highlightToggle').checked;
    const volume = document.getElementById('volumeSlider').value;

    localStorage.setItem('caro_sfx', sfx);
    localStorage.setItem('caro_bgm', bgm);
    localStorage.setItem('caro_coords', coords);
    localStorage.setItem('caro_highlight', highlight);
    localStorage.setItem('caro_volume', volume);

    if (window.CaroAudio) {
        CaroAudio.syncBgm();
    }

    if (sfx) {
        playSoundWin();
    }

    showToast("Đã lưu thiết lập trò chơi thành công!");
}

let volumePreviewTimer = null;

function updateVolumeDisplay(val) {
    const volumeValue = document.getElementById('volumeValue');
    if (volumeValue) volumeValue.textContent = val + "%";
    localStorage.setItem('caro_volume', String(val));

    clearTimeout(volumePreviewTimer);
    volumePreviewTimer = setTimeout(() => {
        playSoundMove();
    }, 90);
}

function showToast(msg) {
    const toast = document.getElementById('toast');
    if (toast) {
        toast.textContent = msg;
        toast.style.display = 'block';
        setTimeout(() => {
            toast.style.display = 'none';
        }, 3000);
    }
}
