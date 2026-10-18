<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>

<%
    Boolean isWin = (Boolean) request.getAttribute("isWin");
    Boolean isDraw = (Boolean) request.getAttribute("isDraw");
    if (isWin == null) isWin = false;
    if (isDraw == null) isDraw = false;

    String moves = (String) request.getAttribute("moves");
    String time = (String) request.getAttribute("time");
    User currentUser = (User) request.getAttribute("currentUser");

    String statusText = isWin ? "VICTORY!" : (isDraw ? "HÒA CỜ!" : "DEFEAT!");
    String trophyIcon = isWin ? "🏆" : (isDraw ? "🤝" : "💔");
    String winnerText = isWin ? "Bạn đã giành chiến thắng xuất sắc!" : (isDraw ? "Hai kỳ thủ bất phân thắng bại!" : "Rất tiếc, bạn đã nhận thất bại!");
    String ratingText = isWin ? "+25" : (isDraw ? "+5" : "-15");
    String ratingClass = (isWin || isDraw) ? "rating-up" : "rating-down";
%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Kết Quả Trận Đấu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/result.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap" rel="stylesheet">
    <style>
        .rating-down {
            color: #ff5252 !important;
        }
    </style>
</head>

<body>

<div class="result-page">

    <!-- BACK TO HOME -->
    <button class="back-button" onclick="goHome()">
        ← Back
    </button>

    <!-- TITLE -->
    <div class="result-title">
        KẾT QUẢ VÁN ĐẤU
    </div>

    <!-- RESULT CARD -->
    <div class="result-card">

        <!-- TROPHY -->
        <div class="trophy">
            <%= trophyIcon %>
        </div>

        <!-- RESULT -->
        <div class="result-status">
            <%= statusText %>
        </div>

        <!-- PLAYER -->
        <div class="winner-avatar">
            🧑🏻‍💻
        </div>

        <div class="winner-name">
            <%= currentUser != null ? currentUser.getNickname() : "Bạn" %>
        </div>

        <div class="winner-text">
            <%= winnerText %>
        </div>

        <!-- GAME INFORMATION -->
        <div class="game-info">
            <div>
                <span>Số nước đi</span>
                <strong><%= moves %></strong>
            </div>

            <div>
                <span>Thời gian</span>
                <strong><%= time %></strong>
            </div>

            <div>
                <span>Điểm Rank</span>
                <strong class="<%= ratingClass %>"><%= ratingText %></strong>
            </div>
        </div>

    </div>

    <!-- BUTTONS -->
    <div class="action-buttons">
        <button onclick="playAgain()">
            Chơi Tiếp
        </button>

        <button onclick="viewRanking()">
            Bảng Xếp Hạng
        </button>

        <button onclick="goHome()">
            Trang Chủ
        </button>
    </div>

</div>

<script src="${pageContext.request.contextPath}/js/result.js"></script>

</body>
</html>