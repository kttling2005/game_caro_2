<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
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
    
    <!-- ONLINE PLAYERS -->
    <div class="online-players">

        <div class="online-header">
            <span class="online-title">Online Players</span>
            <span class="online-count">6 Online</span>
        </div>

        <div class="player-list">

            <div class="player">
                <div class="player-avatar avatar-1">🐱</div>
                <div class="player-info">
                    <span class="player-name">Mochi</span>
                    <div class="player-details">
                        <span class="player-score">
                            ⭐ 1,250 pts
                        </span>

                        <span class="player-status">
                            <span class="status-dot"></span>
                            Online
                        </span>
                    </div>
                </div>
            </div>

            <div class="player">
                <div class="player-avatar avatar-2">🐰</div>
                <div class="player-info">
                    <span class="player-name">Lumi</span>
                    <div class="player-details">
                        <span class="player-score">
                            ⭐ 1,250 pts
                        </span>

                        <span class="player-status">
                            <span class="status-dot"></span>
                            Online
                        </span>
                    </div>
                </div>
            </div>

            <div class="player">
                <div class="player-avatar avatar-3">🐻</div>
                <div class="player-info">
                    <span class="player-name">Mikan</span>
                    <div class="player-details">
                        <span class="player-score">
                            ⭐ 1,250 pts
                        </span>

                        <span class="player-status">
                            <span class="status-dot"></span>
                            Online
                        </span>
                    </div>
                </div>
            </div>

            <div class="player">
                <div class="player-avatar avatar-4">🦊</div>
                <div class="player-info">
                    <span class="player-name">Kitsu</span>
                    <div class="player-details">
                        <span class="player-score">
                            ⭐ 1,250 pts
                        </span>

                        <span class="player-status">
                            <span class="status-dot"></span>
                            Online
                        </span>
                    </div>
                </div>
            </div>

        </div>

    </div>

</div>

<script src="${pageContext.request.contextPath}/js/gameMenu.js"></script>

</body>
</html>