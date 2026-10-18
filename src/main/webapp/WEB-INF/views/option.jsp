<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="model.MatchHistory"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Cài Đặt & Hồ Sơ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/option.css?v=4">
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
            PLAYER PROFILE & CAREER
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

    <%
        String activeTab = (String) request.getAttribute("activeTab");
        if (activeTab == null || activeTab.trim().isEmpty()) {
            activeTab = "profile";
        }
    %>

    <!-- TABS NAVIGATION (3 TABS) -->
    <div class="option-tabs">
        <button class="tab-btn <%= "profile".equals(activeTab) ? "active" : "" %>" id="tab-btn-profile" onclick="switchTab('profile')">
            👤 Hồ Sơ & Bảo Mật
        </button>
        <button class="tab-btn <%= "history".equals(activeTab) ? "active" : "" %>" id="tab-btn-history" onclick="switchTab('history')">
            📜 Lịch Sử Đấu
        </button>
        <button class="tab-btn <%= "ranks".equals(activeTab) ? "active" : "" %>" id="tab-btn-ranks" onclick="switchTab('ranks')">
            🏆 Bảng Bậc Rank
        </button>
    </div>

    <%
        User u = (User) request.getAttribute("user");
        Integer myRank = (Integer) request.getAttribute("myRank");
        List<String> presetAvatars = (List<String>) request.getAttribute("presetAvatars");
        List<MatchHistory> matchHistoryList = (List<MatchHistory>) request.getAttribute("matchHistoryList");
        String currentAvatarUrl = (u != null) ? u.getAvatarUrl(request.getContextPath()) : request.getContextPath() + "/assets/avatars/avatar1.svg";
    %>

    <!-- TAB 1: PROFILE & AVATAR -->
    <div class="tab-panel <%= "profile".equals(activeTab) ? "active" : "" %>" id="tab-profile">
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

                <!-- 3. BẢO MẬT & ĐỔI MẬT KHẨU TÀI KHOẢN -->
                <div class="section-title" style="margin-top: 26px;">
                    <span>🔒</span> Bảo Mật & Đổi Mật Khẩu Tài Khoản
                </div>

                <form action="${pageContext.request.contextPath}/option" method="POST" class="security-box" style="background: rgba(0,0,0,0.4); border: 1.5px solid rgba(0,232,120,0.25); border-radius: 14px; padding: 18px 20px;">
                    <input type="hidden" name="action" value="changePassword">

                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 12px;">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label" style="font-size: 12px; text-align: left;">Mật Khẩu Hiện Tại:</label>
                            <input type="password" name="currentPassword" class="form-control" placeholder="••••••••" required style="padding: 9px 12px; font-size: 13.5px;">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label" style="font-size: 12px; text-align: left;">Mật Khẩu Mới:</label>
                            <input type="password" name="newPassword" class="form-control" placeholder="Tối thiểu 6 ký tự" minlength="6" required style="padding: 9px 12px; font-size: 13.5px;">
                        </div>

                        <div class="form-group" style="margin-bottom: 0;">
                            <label class="form-label" style="font-size: 12px; text-align: left;">Xác Nhận Mật Khẩu:</label>
                            <input type="password" name="confirmPassword" class="form-control" placeholder="Nhập lại mật khẩu" minlength="6" required style="padding: 9px 12px; font-size: 13.5px;">
                        </div>
                    </div>

                    <button type="submit" class="btn-primary" style="padding: 9px 20px; font-size: 13.5px;">
                        🔑 Cập Nhật Mật Khẩu Mới
                    </button>
                </form>

            </div>

        </div>
    </div>

    <!-- TAB: MATCH HISTORY -->
    <div class="tab-panel <%= "history".equals(activeTab) ? "active" : "" %>" id="tab-history">
        <div class="history-container">
            <!-- OVERVIEW STATS BANNER -->
            <div class="history-stats-banner">
                <div class="h-stat-item">
                    <span class="h-stat-label">Tổng Trận Đấu</span>
                    <span class="h-stat-val text-white"><%= u != null ? u.getTotalMatches() : 0 %></span>
                </div>
                <div class="h-stat-item">
                    <span class="h-stat-label">Tỷ Lệ Thắng</span>
                    <span class="h-stat-val text-gold"><%= u != null ? u.getWinRate() : "0.0" %>%</span>
                </div>
                <div class="h-stat-item">
                    <span class="h-stat-label">Thắng - Hòa - Thua</span>
                    <span class="h-stat-val">
                        <span class="c-win"><%= u != null ? u.getWins() : 0 %> W</span> - 
                        <span class="c-draw"><%= u != null ? u.getDraws() : 0 %> D</span> - 
                        <span class="c-loss"><%= u != null ? u.getLosses() : 0 %> L</span>
                    </span>
                </div>
                <div class="h-stat-item">
                    <span class="h-stat-label">Điểm Xếp Hạng</span>
                    <span class="h-stat-val text-gold">⭐ <%= u != null ? u.getScore() : 1000 %> pts</span>
                </div>
            </div>

            <!-- FILTER & TITLE BAR -->
            <div class="history-filter-bar">
                <div class="history-title-wrap">
                    <h3 class="history-section-title">Danh Sách Trận Gần Nhất</h3>
                    <span class="history-count-badge"><%= matchHistoryList != null ? matchHistoryList.size() : 0 %> trận</span>
                </div>
                <div class="history-filter-buttons">
                    <button type="button" class="h-filter-btn active" onclick="filterMatches('all', this)">Tất cả</button>
                    <button type="button" class="h-filter-btn" onclick="filterMatches('win', this)">🏆 Thắng</button>
                    <button type="button" class="h-filter-btn" onclick="filterMatches('loss', this)">💔 Thua</button>
                    <button type="button" class="h-filter-btn" onclick="filterMatches('draw', this)">🤝 Hòa</button>
                </div>
            </div>

            <!-- MATCH CARDS LIST -->
            <div class="history-list" id="historyMatchesList">
                <%
                    if (matchHistoryList == null || matchHistoryList.isEmpty()) {
                %>
                    <div class="history-empty">
                        <div class="empty-icon">🎮</div>
                        <div class="empty-title">Chưa có lịch sử đấu</div>
                        <p class="empty-desc">Bạn chưa tham gia trận đấu nào. Hãy vào "New Game" hoặc "Find Match" để bắt đầu so tài và leo rank nhé!</p>
                        <a href="<%= request.getContextPath() %>/game" class="empty-action-btn">⚔️ Chơi Ngay</a>
                    </div>
                <%
                    } else {
                        for (MatchHistory m : matchHistoryList) {
                            String res = (u != null) ? m.getResultForUser(u.getId()) : "DRAW"; // "WIN", "LOSS", "DRAW"
                            User opp = (u != null) ? m.getOpponent(u.getId()) : null;
                            int scoreChange = (u != null) ? m.getScoreChangeForUser(u.getId()) : 0;
                            String cardClass = "card-win";
                            String badgeText = "CHIẾN THẮNG";
                            String badgeIcon = "🏆";
                            String scoreClass = "score-plus";
                            String scoreText = "+" + scoreChange;

                            if ("LOSS".equals(res)) {
                                cardClass = "card-loss";
                                badgeText = "THẤT BẠI";
                                badgeIcon = "💔";
                                scoreClass = "score-minus";
                                scoreText = String.valueOf(scoreChange);
                            } else if ("DRAW".equals(res)) {
                                cardClass = "card-draw";
                                badgeText = "HÒA CỜ";
                                badgeIcon = "🤝";
                                scoreClass = "score-draw";
                                scoreText = "+" + scoreChange;
                            }

                            String oppName = (opp != null && opp.getNickname() != null && !opp.getNickname().isEmpty())
                                            ? opp.getNickname()
                                            : ((opp != null) ? opp.getUsername() : "Đối thủ");
                            String oppUsername = (opp != null && opp.getUsername() != null) ? "@" + opp.getUsername() : "";
                            String oppAvatar = (opp != null) ? opp.getAvatarUrl(request.getContextPath()) : request.getContextPath() + "/assets/avatars/default.svg";
                            String oppRank = (opp != null) ? opp.getRankBadge() : "🥉 Đồng";
                %>
                    <div class="match-card <%= cardClass %>" data-result="<%= res.toLowerCase() %>">
                        <!-- RESULT BADGE -->
                        <div class="match-result-badge">
                            <span class="m-badge-icon"><%= badgeIcon %></span>
                            <span class="m-badge-text"><%= badgeText %></span>
                        </div>

                        <!-- OPPONENT INFO -->
                        <div class="match-opponent-info">
                            <div class="m-opp-avatar">
                                <img src="<%= oppAvatar %>" alt="Opponent" width="46" height="46">
                            </div>
                            <div class="m-opp-meta">
                                <div class="m-opp-title">Đấu với</div>
                                <div class="m-opp-name"><%= oppName %> <span class="m-opp-user"><%= oppUsername %></span></div>
                                <div class="m-opp-rank"><%= oppRank %></div>
                            </div>
                        </div>

                        <!-- MATCH STATS -->
                        <div class="match-stats-col">
                            <div class="m-stat-item" title="Số nước cờ">
                                <span class="m-icon">🎯</span>
                                <span><%= m.getTotalMoves() %> nước</span>
                            </div>
                            <div class="m-stat-item" title="Thời lượng trận đấu">
                                <span class="m-icon">⏱️</span>
                                <span><%= m.getFormattedDuration() %></span>
                            </div>
                            <div class="m-stat-item" title="Thời điểm thi đấu">
                                <span class="m-icon">📅</span>
                                <span><%= m.getTimeAgo() %></span>
                            </div>
                        </div>

                        <!-- SCORE BADGE -->
                        <div class="match-score-badge <%= scoreClass %>">
                            <span class="m-score-val"><%= scoreText %></span>
                            <span class="m-score-sub">Điểm Rank</span>
                        </div>
                    </div>
                <%
                        }
                    }
                %>
            </div>
        </div>
    </div>

    <!-- TAB 3: RANK TIERS & SCORING -->
    <div class="tab-panel <%= "ranks".equals(activeTab) ? "active" : "" %>" id="tab-ranks">
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
                <span>⚙️</span> Cài Đặt Trò Chơi & Luật Thi Đấu
            </div>
            <div class="guide-text">
                Bạn muốn tùy chỉnh nhạc nền, âm thanh nước đi hoặc xem luật thi đấu 15x15?
                <a href="${pageContext.request.contextPath}/settings" style="color: #00e878; font-weight: 700; text-decoration: underline; margin-left: 6px;">
                    👉 Mở Cài Đặt & Luật Chơi
                </a>
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
