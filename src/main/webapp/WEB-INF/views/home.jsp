<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>XO Game - Conqueror</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/home.css">
</head>

<body>

<div class="home-screen">

    <div class="center-content">

        <div class="game-logo">
            <div class="logo-main">XO Game</div>
            <div class="logo-sub">- CONQUEROR -</div>
        </div>

        <div class="main-menu">

            <button class="menu-item" onclick="newGame()">
                New Game
            </button>

            <button class="menu-item" onclick="openOption()">
                Option
            </button>

            <button class="menu-item" onclick="openRanking()">
                Ranking
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

<script src="${pageContext.request.contextPath}/js/home.js"></script>

</body>
</html>