<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Bảng Xếp Hạng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/ranking.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap" rel="stylesheet">
</head>

<body>

<div class="ranking-page">

    <!-- BACK -->
    <button class="back-button" onclick="goBack()">
        ← Back
    </button>

    <!-- TITLE -->
    <div class="ranking-title">
        PLAYER RANKING
    </div>

    <!-- RANKING BOARD -->
    <div class="ranking-board">

        <!-- HEADER -->
        <div class="ranking-header">
            <div>Rank</div>
            <div>Player</div>
            <div>Wins</div>
            <div>Losses</div>
            <div>Rating</div>
        </div>

        <%
            List<User> rankings = (List<User>) request.getAttribute("rankings");
            if (rankings != null && !rankings.isEmpty()) {
                int rank = 1;
                for (User u : rankings) {
                    String rankBadge = String.valueOf(rank);
                    String rowClass = "";
                    if (rank == 1) {
                        rankBadge = "🥇";
                        rowClass = "first";
                    } else if (rank == 2) {
                        rankBadge = "🥈";
                        rowClass = "second";
                    } else if (rank == 3) {
                        rankBadge = "🥉";
                        rowClass = "third";
                    }

                    String avaUrl = u.getAvatarUrl(request.getContextPath());
        %>
            <div class="ranking-row <%= rowClass %>">
                <div class="rank"><%= rankBadge %></div>
                <div class="player">
                    <div class="avatar">
                        <img src="<%= avaUrl %>" alt="Avatar" class="ranking-avatar-img">
                    </div>
                    <span><%= u.getNickname() != null ? u.getNickname() : u.getUsername() %></span>
                </div>
                <div><%= u.getWins() %></div>
                <div><%= u.getLosses() %></div>
                <div class="rating"><%= u.getScore() %></div>
            </div>
        <%
                    rank++;
                }
            } else {
        %>
            <div style="padding: 20px; text-align: center; color: white;">
                Chưa có dữ liệu người chơi!
            </div>
        <% } %>

    </div>

    <!-- CURRENT PLAYER -->
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        Integer myRank = (Integer) request.getAttribute("myRank");
        if (currentUser != null) {
    %>
    <div class="my-ranking" style="display: flex; align-items: center; justify-content: space-between; gap: 15px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <img src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Avatar" class="ranking-avatar-img" style="width: 44px; height: 44px; border: 2px solid #00e878; border-radius: 50%; box-shadow: 0 0 10px rgba(0,232,120,0.5);">
            <div>
                <span style="display: block; font-size: 14px; color: #a0d8b5;">Xếp hạng của bạn:</span>
                <strong style="font-size: 20px; color: #ffd700;">#<%= myRank != null ? myRank : "-" %></strong>
            </div>
        </div>
        <div>
            <span style="font-size: 15px; color: #ffffff;"><%= currentUser.getRankBadge() %></span> &bull; 
            <span style="font-size: 15px; color: #00e878; font-weight: bold;">⭐ <%= currentUser.getScore() %> pts</span> 
            <span style="font-size: 13px; color: #a0d8b5;">(Thắng: <%= currentUser.getWins() %> | Thua: <%= currentUser.getLosses() %>)</span>
        </div>
    </div>
    <% } %>

</div>

<script src="${pageContext.request.contextPath}/js/ranking.js"></script>

</body>
</html>