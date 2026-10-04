<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>XO Game - Play</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/gamePlay.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="game-page">

    <!-- =========================
         BACK
         ========================= -->

    <button class="back-button"
            onclick="leaveGame()">

        ←

    </button>


    <!-- =========================
         TOP TITLE
         ========================= -->

    <div class="game-title">

        XO GAME

    </div>


    <!-- =========================
         MAIN AREA
         ========================= -->

    <div class="game-layout">


        <!-- =========================
            LEFT CHAT & EMOJI PANEL
            ========================= -->

        <div class="emoji-panel">

            <div class="panel-title">
                Chat
            </div>

            <!-- CHAT INPUT -->
            <div class="chat-box">

                <input type="text"
                       id="chatInput"
                       placeholder="Type a message..."
                       maxlength="100">

                <button type="button" id="sendChatButton" onclick="console.log('🔥 BUTTON ĐƯỢC BẤM')">
                    ➤
                </button>

            </div>


            <div class="panel-title reaction-title">
                Reactions
            </div>

            <div class="emoji-list">

                <button onclick="sendEmoji('😀')">😀</button>
                <button onclick="sendEmoji('😂')">😂</button>
                <button onclick="sendEmoji('😮')">😮</button>

                <button onclick="sendEmoji('😢')">😢</button>
                <button onclick="sendEmoji('😡')">😡</button>
                <button onclick="sendEmoji('❤️')">❤️</button>

                <button onclick="sendEmoji('👍')">👍</button>
                <button onclick="sendEmoji('🔥')">🔥</button>
                <button onclick="sendEmoji('👏')">👏</button>

            </div>

        </div>


        <!-- =========================
             CARO BOARD
             ========================= -->

        <div class="board-area">

            <div class="turn-text" id="turnText">

                Your Turn

            </div>

            <div class="board"
                 id="board">

                <!-- JS tạo 225 ô -->

            </div>

        </div>


        <!-- =========================
             TIMER
             ========================= -->

        <div class="timer-panel">

            <div class="panel-title">
                Time
            </div>

            <div class="timer-circle">

                <span id="timer">
                    60
                </span>

                <small>
                    sec
                </small>

            </div>

            <div class="timer-status"
                 id="timerStatus">

                Your turn

            </div>

        </div>

    </div>


    <!-- =========================
         PLAYERS
         ========================= -->

    <div class="players-area">


        <!-- PLAYER 1 -->

        <div class="player-card active-player">

            <div class="avatar">

                🧑🏻‍💻

            </div>

            <div class="player-info">

                <div class="player-name">
                    Player 1
                </div>

                <div class="player-status">
                    ● Your Turn
                </div>

            </div>

            <div class="symbol x-symbol">
                X
            </div>

        </div>


        <!-- VS -->

        <div class="vs">

            VS

        </div>


        <!-- PLAYER 2 -->

        <div class="player-card">

            <div class="symbol o-symbol">
                O
            </div>

            <div class="player-info">

                <div class="player-name">
                    Player 2
                </div>

                <div class="player-status waiting">
                    ○ Waiting
                </div>

            </div>

            <div class="avatar">

                🐱

            </div>

        </div>


    </div>


    <!-- =========================
         EMOJI POPUP
         ========================= -->

    <div id="emojiPopup"
         class="emoji-popup">

    </div>


</div>


<script src="${pageContext.request.contextPath}/js/gamePlay.js"></script>

</body>

</html>