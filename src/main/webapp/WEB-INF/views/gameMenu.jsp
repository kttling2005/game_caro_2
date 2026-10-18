<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>XO Game - Game Menu</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/gameMenu.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">
</head>

<body>

<div class="game-menu">

    <!-- CREATE ROOM -->
    <button class="game-option create-room"
            onclick="createRoom()">
        Create Room
    </button>

    <!-- JOIN ROOM -->
    <button class="game-option join-room"
            onclick="joinRoom()">
        Join Room
    </button>

    <!-- FIND MATCH -->
    <button class="game-option find-match"
            onclick="findMatch()">
        Find Match
    </button>
    
    <button class="back-button" onclick="goBack()">
        ← Back
    </button>
    
    <!-- CURRENT USER PROFILE BADGE -->
    <%
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) {
    %>
    <div style="position: absolute; top: 20px; right: 25px; display: flex; align-items: center; gap: 10px; background: rgba(4,18,9,0.85); border: 2px solid #00e878; padding: 6px 16px 6px 8px; border-radius: 30px; box-shadow: 0 0 15px rgba(0,232,120,0.4); cursor: pointer;" onclick="window.location.href='option'" title="Xem cài đặt và hồ sơ">
        <img src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Avatar" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #ffd700;">
        <div>
            <div style="font-size: 13px; font-weight: bold; color: #ffffff; font-family: sans-serif;"><%= currentUser.getNickname() != null ? currentUser.getNickname() : currentUser.getUsername() %></div>
            <div style="font-size: 11px; color: #00e878; font-family: sans-serif;">⭐ <%= currentUser.getScore() %> pts &bull; <%= currentUser.getRankTier() %></div>
        </div>
    </div>
    <% } %>

    <!-- ONLINE PLAYERS -->
    <div class="online-players">

        <div class="online-header">
            <span class="online-title">Online Players</span>
            <span class="online-count"><%= request.getAttribute("onlineCount") != null ? request.getAttribute("onlineCount") : 1 %> Online</span>
        </div>

        <div class="player-list">

            <%
                List<User> topPlayers = (List<User>) request.getAttribute("topPlayers");
                if (topPlayers != null && !topPlayers.isEmpty()) {
                    for (User p : topPlayers) {
                        String avaUrl = p.getAvatarUrl(request.getContextPath());
            %>
            <div class="player">
                <div class="player-avatar" style="border: 2px solid #00e878; border-radius: 50%; overflow: hidden; padding: 0; background: #000; width: 44px; height: 44px; display: flex; align-items: center; justify-content: center;">
                    <img src="<%= avaUrl %>" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">
                </div>
                <div class="player-info">
                    <span class="player-name"><%= p.getNickname() != null ? p.getNickname() : p.getUsername() %></span>
                    <div class="player-details">
                        <span class="player-score">
                            ⭐ <%= p.getScore() %> pts &bull; <%= p.getRankTier() %>
                        </span>

                        <span class="player-status">
                            <span class="status-dot"></span>
                            <%= p.getStatus() != null ? p.getStatus() : "ONLINE" %>
                        </span>
                    </div>
                </div>
            </div>
            <%
                    }
                }
            %>

        </div>

    </div>

</div>

<script src="${pageContext.request.contextPath}/js/gameMenu.js"></script>

</body>
</html>