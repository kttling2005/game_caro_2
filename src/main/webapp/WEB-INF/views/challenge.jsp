<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sảnh Thách Đấu - XO Game</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/challenge.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&family=Montserrat:wght@400;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="challenge-page">
    <div class="challenge-content">

        <!-- HEADER BAR -->
        <div class="header-bar">
            <button class="btn-back" onclick="goBack()" title="Quay lại sảnh chính">
                ← Back
            </button>

            <h1 class="page-title">⚔️ SẢNH THÁCH ĐẤU</h1>

            <%
                User currentUser = (User) request.getAttribute("currentUser");
                if (currentUser != null) {
            %>
            <div class="user-badge" title="Tài khoản của bạn">
                <img src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Avatar">
                <div>
                    <div style="font-size: 13px; font-weight: bold; color: #ffffff;">
                        <%= currentUser.getNickname() != null ? currentUser.getNickname() : currentUser.getUsername() %>
                    </div>
                    <div style="font-size: 11px; color: #00e878;">
                        ⭐ <%= currentUser.getScore() %> pts &bull; <%= currentUser.getRankTier() %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>

        <!-- SEARCH & FILTER BAR -->
        <div class="search-filter-box">
            <div class="search-input-wrapper">
                <span class="search-icon">🔍</span>
                <input type="text"
                       id="searchInput"
                       class="search-input"
                       placeholder="Tìm kiếm cờ thủ theo Nickname hoặc Username..."
                       value="<%= request.getAttribute("searchQuery") != null ? request.getAttribute("searchQuery") : "" %>"
                       oninput="filterPlayersClientSide()">
            </div>
            <div class="filter-badge">
                <span>🟢 Đang Sẵn Sàng</span>
            </div>
        </div>

        <%
            List<User> playerList = (List<User>) request.getAttribute("playerList");
            boolean isFallback = Boolean.TRUE.equals(request.getAttribute("isFallbackList"));
        %>

        <% if (isFallback) { %>
            <div style="background: rgba(255, 211, 56, 0.15); border: 1px solid rgba(255, 211, 56, 0.4); color: #ffd338; padding: 10px 16px; border-radius: 10px; margin-bottom: 20px; font-size: 13px; text-align: center;">
                💡 <em>Hiện chưa có cờ thủ nào khác trực tuyến cùng lúc. Đang hiển thị danh sách các cao thủ trong hệ thống để bạn có thể xem hồ sơ hoặc gửi thách đấu thử nghiệm!</em>
            </div>
        <% } %>

        <!-- PLAYERS GRID -->
        <div class="players-grid" id="playersGrid">
            <%
                if (playerList != null && !playerList.isEmpty()) {
                    for (User p : playerList) {
                        String rawStatus = p.getStatus() != null ? p.getStatus().toUpperCase() : "OFFLINE";
                        boolean isOnline = "ONLINE".equals(rawStatus);
                        boolean isPlaying = "PLAYING".equals(rawStatus) || "IN_ROOM".equals(rawStatus) || "WAITING".equals(rawStatus);

                        String dotClass = isOnline ? "dot-online" : (isPlaying ? "dot-playing" : "dot-offline");
                        String statusLabel = isOnline ? "🟢 Rảnh Rỗi" : (isPlaying ? "🔴 Đang Đấu" : "⚪ Ngoại Tuyến");
            %>
            <div class="player-card" data-nickname="<%= (p.getNickname() != null ? p.getNickname() : "").toLowerCase() %>" data-username="<%= p.getUsername().toLowerCase() %>">
                <div class="player-card-header">
                    <div class="card-avatar-wrapper">
                        <img class="card-avatar" src="<%= p.getAvatarUrl(request.getContextPath()) %>" alt="<%= p.getNickname() %>">
                        <span class="card-status-dot <%= dotClass %>" title="<%= statusLabel %>"></span>
                    </div>
                    <div class="card-info">
                        <div class="card-nickname" title="<%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>">
                            <%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>
                        </div>
                        <div class="card-score">
                            ⭐ <%= p.getScore() %> pts
                        </div>
                        <div class="card-tier">
                            <%= p.getRankTier() %> &bull; <span style="font-size: 11px; opacity: 0.85;"><%= statusLabel %></span>
                        </div>
                    </div>
                </div>

                <div class="card-stats">
                    <div class="stat-item">
                        <span>Trận</span>
                        <span class="stat-val"><%= p.getTotalMatches() %></span>
                    </div>
                    <div class="stat-item">
                        <span>Thắng</span>
                        <span class="stat-val" style="color: #00e878;"><%= p.getWins() %></span>
                    </div>
                    <div class="stat-item">
                        <span>Hòa</span>
                        <span class="stat-val" style="color: #ffd338;"><%= p.getDraws() %></span>
                    </div>
                    <div class="stat-item">
                        <span>Thua</span>
                        <span class="stat-val" style="color: #ff5252;"><%= p.getLosses() %></span>
                    </div>
                </div>

                <div class="card-actions">
                    <% if (isPlaying) { %>
                        <div class="btn-disabled">🔴 Đang trong trận đấu</div>
                    <% } else { %>
                        <button class="btn-challenge" onclick="sendChallenge(<%= p.getId() %>, '<%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>')">
                            ⚔️ Thách Đấu Ngay
                        </button>
                    <% } %>
                </div>
            </div>
            <%
                    }
                } else {
            %>
            <div class="empty-state" style="grid-column: 1 / -1;">
                <div class="empty-icon">🏜️</div>
                <div class="empty-title">Chưa Tìm Thấy Đối Thủ Phù Hợp</div>
                <p class="empty-desc">
                    Hiện chưa có cờ thủ nào khác trực tuyến hoặc khớp với từ khóa tìm kiếm.
                    Bạn có thể tạo phòng riêng hoặc sử dụng chức năng Tìm Trận Tự Động!
                </p>
                <button class="btn-find-alt" onclick="window.location.href='find-match'">
                    ⚡ Tìm Trận Tự Động
                </button>
            </div>
            <% } %>
        </div>

    </div>
</div>

<!-- POPUP NHẬN THÁCH ĐẤU -->
<div id="incomingChallengeModal" class="modal-overlay" style="display: none;">
    <div class="modal-card">
        <div class="modal-icon">⚔️</div>
        <div class="modal-heading">LỜI MỜI THÁCH ĐẤU!</div>
        <p class="modal-desc" id="challengeModalDesc">
            Bạn nhận được một lời mời thách đấu cờ caro!
        </p>
        <div class="modal-timer" id="challengeModalTimer">
            ⏳ Hết hạn sau: 30s
        </div>
        <div class="modal-btns">
            <button class="modal-btn-accept" onclick="respondChallenge(true)">
                ✅ Chấp Nhận
            </button>
            <button class="modal-btn-decline" onclick="respondChallenge(false)">
                ❌ Từ Chối
            </button>
        </div>
    </div>
</div>

<script>
    const currentUserId = ${sessionScope.currentUser != null ? sessionScope.currentUser.id : 0};
    const contextPath = "${pageContext.request.contextPath}";
    function goBack() { window.location.href = contextPath + "/game"; }
    function sendChallenge(targetUserId, targetName) {
        if (!targetUserId) return;
        window.location.href = contextPath + "/challenge-wait?targetId=" + targetUserId;
    }
</script>
<script src="${pageContext.request.contextPath}/js/challenge.js?v=<%= System.currentTimeMillis() %>"></script>

</body>
</html>
