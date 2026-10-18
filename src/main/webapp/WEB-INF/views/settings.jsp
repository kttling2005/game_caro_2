<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài Đặt & Luật Chơi - XO Game Conqueror</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/option.css?v=6">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800;900&family=Irish+Grover&display=swap" rel="stylesheet">
</head>
<body>

<div class="option-container">

    <!-- HEADER -->
    <div class="option-header">
        <div class="option-header-side option-header-left">
            <a href="${pageContext.request.contextPath}/home" class="back-btn" style="text-decoration: none;">
                ← Menu Chính
            </a>
        </div>
        <div class="option-title">
            GAME SETTINGS & RULES
        </div>
        <div class="option-header-side option-header-right">
            <button type="button"
                    class="option-close-btn"
                    title="Đóng"
                    aria-label="Đóng"
                    onclick="closeOption()">
                &times;
            </button>
        </div>
    </div>

    <%
        String activeTab = (String) request.getAttribute("activeTab");
        if (activeTab == null || activeTab.trim().isEmpty()) {
            activeTab = "settings";
        }
    %>

    <!-- TABS NAVIGATION (2 TABS) -->
    <div class="option-tabs">
        <button class="tab-btn <%= "rules".equals(activeTab) ? "" : "active" %>" id="tab-btn-settings" onclick="switchTab('settings')">
            ⚙️ Cài Đặt Âm Thanh & Bàn Cờ
        </button>
        <button class="tab-btn <%= "rules".equals(activeTab) ? "active" : "" %>" id="tab-btn-rules" onclick="switchTab('rules')">
            📖 Luật Thi Đấu
        </button>
    </div>

    <!-- TAB 1: SETTINGS & AUDIO -->
    <div class="tab-panel <%= "rules".equals(activeTab) ? "" : "active" %>" id="tab-settings">
        <div class="settings-list">

            <div class="setting-item">
                <div class="setting-info">
                    <div class="setting-title">🔊 Hiệu Ứng Âm Thanh Nước Đi (SFX)</div>
                    <div class="setting-desc">Phát tiếng cờ "cắc" vui tai khi đặt quân và chuông chiến thắng</div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="sfxToggle" checked>
                    <span class="slider"></span>
                </label>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <div class="setting-title">🎵 Nhạc Nền Thư Giãn (BGM)</div>
                    <div class="setting-desc">Phát giai điệu retro 8-bit lặp lại khi ván đấu bắt đầu. Bật công tắc để nghe thử ngay.</div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="bgmToggle" onchange="onBgmToggleChange(this.checked)">
                    <span class="slider"></span>
                </label>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <div class="setting-title">🎚️ Âm Lượng Tổng Thể</div>
                    <div class="setting-desc">Điều chỉnh độ to nhỏ của âm thanh trong trò chơi</div>
                </div>
                <div class="range-slider-wrap">
                    <input type="range" id="volumeSlider" class="range-slider" min="0" max="100" value="80" oninput="updateVolumeDisplay(this.value)">
                    <span id="volumeValue" style="font-weight: 700; color: #00e878; width: 45px;">80%</span>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <div class="setting-title">📐 Hiển Thị Tọa Độ Bàn Cờ</div>
                    <div class="setting-desc">Hiện các chữ cái (A-O) và số (1-15) quanh mép bàn cờ caro</div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="coordsToggle" checked>
                    <span class="slider"></span>
                </label>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <div class="setting-title">✨ Làm Nổi Bật Nước Cờ Gần Nhất</div>
                    <div class="setting-desc">Hiển thị viền vàng nhấp nháy tại ô cờ vừa được đánh</div>
                </div>
                <label class="switch">
                    <input type="checkbox" id="highlightToggle" checked>
                    <span class="slider"></span>
                </label>
            </div>

            <div style="margin-top: 10px;">
                <button type="button" class="btn-primary" onclick="saveGameSettings()">
                    💾 Lưu Thiết Lập Cài Đặt
                </button>
                <button type="button" class="back-btn" onclick="playSoundMove()" style="margin-left: 10px;">
                    🔊 Nghe Thử SFX
                </button>
            </div>

        </div>
    </div>

    <!-- TAB 2: RULES -->
    <div class="tab-panel <%= "rules".equals(activeTab) ? "active" : "" %>" id="tab-rules">
        <div class="guide-card">
            <div class="guide-title">
                <span>⚔️</span> Luật Thi Đấu Cờ Caro (XO Game Conqueror)
            </div>
            <div class="guide-text">
                • Bàn cờ tiêu chuẩn kích thước <strong>15 x 15</strong> ô vuông.<br>
                • Hai người chơi luân phiên đặt ký hiệu <strong>X</strong> và <strong>O</strong> vào các ô trống.<br>
                • <strong>Điều kiện thắng:</strong> Người chơi đầu tiên tạo được một hàng gồm <strong>5 quân cờ liên tiếp</strong> theo hàng ngang, hàng dọc hoặc đường chéo sẽ giành chiến thắng ngay lập tức.<br>
                • <strong>Thời gian suy nghĩ:</strong> Mỗi lượt đi có <strong>60 giây</strong> suy nghĩ. Nếu hết thời gian mà chưa đánh, người chơi sẽ bị xử thua cuộc do quá giờ.<br>
                • <strong>Cầu hòa & Đầu hàng:</strong> Bạn có thể gửi lời mời xin hòa khi thế cờ cân bằng, hoặc bấm đầu hàng để kết thúc ván đấu một cách văn minh.
            </div>
        </div>

        <div class="guide-card" style="margin-bottom: 0;">
            <div class="guide-title">
                <span>ℹ️</span> Thông Tin Hệ Thống
            </div>
            <div class="guide-text">
                • <strong>Tên sản phẩm:</strong> XO Game Conqueror - Cờ Caro Online v2.0<br>
                • <strong>Công nghệ:</strong> Java Jakarta EE 10, WebSocket RFC 6455 Real-time, Web Audio API.<br>
                • Chúc bạn có những phút giây so tài trí tuệ đỉnh cao và leo rank vui vẻ!
            </div>
        </div>
    </div>

</div>

<!-- TOAST NOTIFICATION -->
<div id="toast" class="toast-msg"></div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/js/audio.js?v=2"></script>
<script src="${pageContext.request.contextPath}/js/option.js?v=7"></script>

</body>
</html>
