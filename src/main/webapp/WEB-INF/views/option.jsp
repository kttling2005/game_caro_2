<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Cài Đặt & Hồ Sơ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/option.css?v=3">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&family=Montserrat:wght@400;600;700;800&display=swap" rel="stylesheet">
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
            GAME OPTIONS & PROFILE
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

    <!-- FLASH MESSAGES -->
    <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success">
            <span>✅ <%= request.getAttribute("success") %></span>
            <span class="alert-close" onclick="closeAlert(this)">&times;</span>
        </div>
    <% } %>

    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error">
            <span>⚠️ <%= request.getAttribute("error") %></span>
            <span class="alert-close" onclick="closeAlert(this)">&times;</span>
        </div>
    <% } %>

    <!-- TABS NAVIGATION -->
    <div class="option-tabs">
        <button class="tab-btn active" id="tab-btn-profile" onclick="switchTab('profile')">
            👤 Hồ Sơ & Avatar
        </button>
        <button class="tab-btn" id="tab-btn-settings" onclick="switchTab('settings')">
            ⚙️ Cài Đặt & Âm Thanh
        </button>
        <button class="tab-btn" id="tab-btn-security" onclick="switchTab('security')">
            🔒 Đổi Mật Khẩu
        </button>
        <button class="tab-btn" id="tab-btn-rules" onclick="switchTab('rules')">
            📖 Hướng Dẫn & Bảng Rank
        </button>
    </div>

    <%
        User u = (User) request.getAttribute("user");
        Integer myRank = (Integer) request.getAttribute("myRank");
        List<String> presetAvatars = (List<String>) request.getAttribute("presetAvatars");
        String currentAvatarUrl = (u != null) ? u.getAvatarUrl(request.getContextPath()) : request.getContextPath() + "/assets/avatars/avatar1.svg";
    %>

    <!-- TAB 1: PROFILE & AVATAR -->
    <div class="tab-panel active" id="tab-profile">
        <div class="profile-grid">

            <!-- LEFT: PROFILE SUMMARY CARD -->
            <div class="profile-card">
                <div class="avatar-wrapper">
                    <img id="currentAvatarPreview" class="avatar-preview-img" src="<%= currentAvatarUrl %>" alt="Avatar"
                         width="130" height="130"
                         style="width: 130px !important; height: 130px !important; min-width: 130px !important; max-width: 130px !important; min-height: 130px !important; max-height: 130px !important; border-radius: 50% !important; object-fit: cover !important; display: block !important; border: 4px solid #00e878;">
                    <div class="rank-badge-tag">
                        <%= u != null ? u.getRankBadge() : "Đồng" %>
                    </div>
                </div>

                <div class="profile-name">
                    <%= (u != null && u.getNickname() != null) ? u.getNickname() : (u != null ? u.getUsername() : "") %>
                </div>
                <div class="profile-username">
                    @<%= u != null ? u.getUsername() : "" %>
                </div>

                <div class="stats-box">
                    <div class="stat-row">
                        <span class="stat-label">Hạng BXH:</span>
                        <span class="stat-value">#<%= myRank != null ? myRank : "-" %></span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Điểm Rank:</span>
                        <span class="stat-value" style="color: #00e878;">⭐ <%= u != null ? u.getScore() : 1000 %> pts</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Tỷ Lệ Thắng:</span>
                        <span class="stat-value"><%= u != null ? u.getWinRate() : 0.0 %>%</span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Tổng Số Trận:</span>
                        <span class="stat-value"><%= u != null ? u.getTotalMatches() : 0 %></span>
                    </div>
                    <div class="stat-row">
                        <span class="stat-label">Thắng / Hòa / Thua:</span>
                        <span class="stat-value">
                            <span style="color:#00e878;"><%= u != null ? u.getWins() : 0 %></span> / 
                            <span style="color:#ffd700;"><%= u != null ? u.getDraws() : 0 %></span> / 
                            <span style="color:#ff5252;"><%= u != null ? u.getLosses() : 0 %></span>
                        </span>
                    </div>
                </div>

                <!-- FORM ĐỔI NICKNAME -->
                <form action="${pageContext.request.contextPath}/option" method="POST" style="margin-top: 15px;">
                    <input type="hidden" name="action" value="changeNickname">
                    <div class="form-group" style="margin-bottom: 8px;">
                        <label class="form-label" style="text-align: left;">Đổi Tên Hiển Thị (Nickname):</label>
                        <input type="text" name="nickname" class="form-control" 
                               value="<%= (u != null && u.getNickname() != null) ? u.getNickname() : "" %>" 
                               maxlength="30" required>
                    </div>
                    <button type="submit" class="btn-primary" style="width: 100%; justify-content: center;">
                        💾 Lưu Tên Mới
                    </button>
                </form>
            </div>

            <!-- RIGHT: AVATAR SELECTION & UPLOAD -->
            <div class="avatar-manager">

                <!-- 1. KHO AVATAR GAME CHẤT LƯỢNG CAO -->
                <div class="section-title">
                    <span>👑</span> Kho Avatar Game Huyền Thoại (Chọn 1 trong 12 nhân vật)
                </div>

                <form action="${pageContext.request.contextPath}/option" method="POST" id="presetAvatarForm">
                    <input type="hidden" name="action" value="changeAvatar">
                    <input type="hidden" name="presetAvatar" id="selectedPresetInput" value="">

                    <div class="avatar-gallery">
                        <%
                            if (presetAvatars != null) {
                                for (String ava : presetAvatars) {
                                    boolean isCurrent = (u != null && ava.equals(u.getAvatar()));
                        %>
                        <div class="preset-avatar-item <%= isCurrent ? "selected" : "" %>" 
                             onclick="selectPresetAvatar('<%= ava %>', this)"
                             title="<%= ava %>">
                            <img src="${pageContext.request.contextPath}/assets/avatars/<%= ava %>" alt="Avatar">
                        </div>
                        <%
                                }
                            }
                        %>
                    </div>

                    <button type="submit" id="savePresetBtn" class="btn-primary" disabled style="margin-bottom: 24px;">
                        ✨ Áp Dụng Avatar Đã Chọn
                    </button>
                </form>

                <!-- 2. TỰ TẢI ẢNH CÁ NHÂN TỪ MÁY TÍNH LÊN (CUSTOM UPLOAD) -->
                <div class="section-title">
                    <span>🖼️</span> Hoặc Tự Tải Ảnh Từ Máy Tính Lên (PNG, JPG, WEBP, GIF &le; 3MB)
                </div>

                <form action="${pageContext.request.contextPath}/option" method="POST" enctype="multipart/form-data" id="uploadAvatarForm">
                    <input type="hidden" name="action" value="uploadAvatar">
                    
                    <input type="file" id="avatarFileInput" name="avatarFile" accept="image/png, image/jpeg, image/jpg, image/webp, image/gif" style="display: none;">

                    <div class="upload-dropzone" id="uploadDropzone" onclick="triggerFileInput()">
                        <div class="dropzone-icon">📁</div>
                        <div class="dropzone-text">Kéo & thả ảnh cá nhân vào đây hoặc nhấp để duyệt file</div>
                        <div class="dropzone-hint">Hệ thống hỗ trợ chuẩn ảnh vuông, tối đa 3MB</div>
                    </div>

                    <button type="submit" id="uploadAvatarBtn" class="btn-primary" style="display: none;">
                        🚀 Tải Lên & Đặt Làm Avatar
                    </button>
                </form>

            </div>

        </div>
    </div>

    <!-- TAB 2: SETTINGS & AUDIO -->
    <div class="tab-panel" id="tab-settings">
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

    <!-- TAB 3: SECURITY / PASSWORD -->
    <div class="tab-panel" id="tab-security">
        <form action="${pageContext.request.contextPath}/option" method="POST" style="max-width: 480px;">
            <input type="hidden" name="action" value="changePassword">

            <div class="form-group">
                <label class="form-label">Mật Khẩu Hiện Tại:</label>
                <input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required>
            </div>

            <div class="form-group">
                <label class="form-label">Mật Khẩu Mới:</label>
                <input type="password" name="newPassword" class="form-control" placeholder="Tối thiểu 6 ký tự" minlength="6" required>
            </div>

            <div class="form-group">
                <label class="form-label">Xác Nhận Mật Khẩu Mới:</label>
                <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu mới" minlength="6" required>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                🔑 Cập Nhật Mật Khẩu
            </button>
        </form>
    </div>

    <!-- TAB 4: RULES & RANK GUIDE -->
    <div class="tab-panel" id="tab-rules">
        <div class="guide-card">
            <div class="guide-title">
                <span>⚔️</span> Luật Thi Đấu Cờ Caro (XO Game Conqueror)
            </div>
            <div class="guide-text">
                • Bàn cờ tiêu chuẩn kích thước <strong>15 x 15</strong> ô vuông.<br>
                • Hai người chơi luân phiên đặt ký hiệu <strong>X</strong> và <strong>O</strong> vào các ô trống.<br>
                • <strong>Điều kiện thắng:</strong> Người chơi đầu tiên tạo được một hàng gồm <strong>5 quân cờ liên tiếp</strong> theo hàng ngang, hàng dọc hoặc đường chéo sẽ giành chiến thắng ngay lập tức.<br>
                • <strong>Thời gian:</strong> Mỗi lượt đi có <strong>60 giây</strong> suy nghĩ. Nếu hết thời gian mà chưa đánh, người chơi sẽ bị xử thua cuộc do quá giờ.
            </div>
        </div>

        <div class="guide-card">
            <div class="guide-title">
                <span>🏆</span> Quy Chế Tính Điểm & Xếp Hạng (Rank System)
            </div>
            <div class="guide-text">
                • <strong>Thắng trận:</strong> Nhận ngay <strong style="color: #00e878;">+25 điểm Rank</strong>.<br>
                • <strong>Thua trận / Thoát trận giữa chừng:</strong> Bị trừ <strong style="color: #ff5252;">-15 điểm Rank</strong>.<br>
                • <strong>Hòa cờ:</strong> Cả 2 bên được cộng <strong style="color: #ffd700;">+5 điểm Rank</strong>.<br>
                <br>
                <strong>Bảng Phân Bậc Xếp Hạng:</strong>
                <table class="rank-tier-table">
                    <thead>
                        <tr>
                            <th>Huy Hiệu</th>
                            <th>Bậc Rank</th>
                            <th>Điểm Yêu Cầu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>👑</td>
                            <td style="color: #ff1744; font-weight: 700;">Cao Thủ (Master)</td>
                            <td>&ge; 1900 điểm</td>
                        </tr>
                        <tr>
                            <td>💎</td>
                            <td style="color: #00e5ff; font-weight: 700;">Kim Cương (Diamond)</td>
                            <td>1700 - 1899 điểm</td>
                        </tr>
                        <tr>
                            <td>🔮</td>
                            <td style="color: #b388ff; font-weight: 700;">Bạch Kim (Platinum)</td>
                            <td>1500 - 1699 điểm</td>
                        </tr>
                        <tr>
                            <td>🥇</td>
                            <td style="color: #ffd700; font-weight: 700;">Vàng (Gold)</td>
                            <td>1300 - 1499 điểm</td>
                        </tr>
                        <tr>
                            <td>🥈</td>
                            <td style="color: #cfd8dc; font-weight: 700;">Bạc (Silver)</td>
                            <td>1100 - 1299 điểm</td>
                        </tr>
                        <tr>
                            <td>🥉</td>
                            <td style="color: #cd7f32; font-weight: 700;">Đồng (Bronze)</td>
                            <td>&lt; 1100 điểm</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="guide-card" style="margin-bottom: 0;">
            <div class="guide-title">
                <span>ℹ️</span> Thông Tin Ứng Dụng
            </div>
            <div class="guide-text">
                • <strong>Phiên bản:</strong> XO Game Conqueror v2.0 Professional<br>
                • <strong>Công nghệ:</strong> Java Jakarta EE 10, WebSocket RFC 6455, MySQL 8 / MariaDB, Web Audio API.<br>
                • Chúc bạn có những phút giây thi đấu trí tuệ đỉnh cao!
            </div>
        </div>
    </div>

</div>

<!-- TOAST MESSAGE -->
<div id="toast" class="toast-msg"></div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/js/audio.js?v=1"></script>
<script src="${pageContext.request.contextPath}/js/option.js?v=6"></script>

</body>
</html>
