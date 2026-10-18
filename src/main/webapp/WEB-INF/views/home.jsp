<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>XO Game - Conqueror</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/home.css?v=2">
</head>

<body>

<div class="home-screen">

    <!-- TOP-RIGHT PLAYER PROFILE BAR -->
    <% if (session.getAttribute("currentUser") != null) { %>
    <div class="top-profile-bar" onclick="openProfile()" title="Nhấp để xem Hồ sơ cá nhân & Đổi Avatar">
        <div class="top-profile-avatar">
            <img src="${sessionScope.currentUser.getAvatarUrl(pageContext.request.contextPath)}" 
                 alt="Avatar"
                 width="44" height="44"
                 style="width: 44px !important; height: 44px !important; min-width: 44px !important; max-width: 44px !important; min-height: 44px !important; max-height: 44px !important; border-radius: 50% !important; object-fit: cover !important; display: block !important; border: 2px solid #00e878;">
            <span class="top-rank-badge">${sessionScope.currentUser.getRankTier()}</span>
        </div>
        <div class="top-profile-details">
            <div class="top-profile-name">
                ${sessionScope.currentUser.nickname != null ? sessionScope.currentUser.nickname : sessionScope.currentUser.username}
            </div>
            <div class="top-profile-score">
                ⭐ ${sessionScope.currentUser.score} pts &bull; Thắng: ${sessionScope.currentUser.winRate}%
            </div>
        </div>
        <span class="top-profile-arrow">👤</span>
    </div>
    <% } %>

    <div class="center-content">

        <div class="game-logo">
            <div class="logo-main">XO Game</div>
            <div class="logo-sub">- CONQUEROR -</div>
        </div>

        <div class="welcome-text">
            Xin chào, <strong>${sessionScope.currentUser.nickname != null ? sessionScope.currentUser.nickname : sessionScope.currentUser.username}</strong>
            <span class="welcome-rank">(${sessionScope.currentUser.getRankBadge()})</span>
        </div>

        <div class="main-menu">

            <button class="menu-item" onclick="newGame()">
                New Game
            </button>

            <button class="menu-item" onclick="openHistory()">
                History
            </button>

            <button class="menu-item" onclick="openRanking()">
                Ranking
            </button>

            <button class="menu-item" onclick="openSettings()">
                Settings
            </button>

            <button class="menu-item" onclick="exitGame()">
                Exit
            </button>

        </div>

    </div>


    <!-- DECORATION -->
    <div class="pixel-decoration decoration-left">
        <div class="pixel-flower"></div>
    </div>

    <div class="pixel-decoration decoration-right">
        <div class="pixel-flower"></div>
    </div>

</div>

<script>
    const contextPath = "${pageContext.request.contextPath}";
    function newGame() { window.location.href = contextPath + "/game"; }
    function openProfile() { window.location.href = contextPath + "/profile?tab=profile"; }
    function openHistory() { window.location.href = contextPath + "/profile?tab=history"; }
    function openRanking() { window.location.href = contextPath + "/ranking"; }
    function openSettings() { window.location.href = contextPath + "/settings"; }
    function openOption() { window.location.href = contextPath + "/settings"; }
    function exitGame() { window.location.href = contextPath + "/logout"; }
</script>
<script src="${pageContext.request.contextPath}/js/home.js?v=<%= System.currentTimeMillis() %>"></script>

</body>
</html>