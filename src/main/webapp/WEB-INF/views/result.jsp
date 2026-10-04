<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>XO Game - Result</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/result.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="result-page">


    <!-- BACK TO HOME -->

    <button class="back-button"
            onclick="goHome()">

        ← Back

    </button>


    <!-- TITLE -->

    <div class="result-title">

        GAME RESULT

    </div>


    <!-- RESULT CARD -->

    <div class="result-card">


        <!-- TROPHY -->

        <div class="trophy">

            🏆

        </div>


        <!-- RESULT -->

        <div class="result-status">

            VICTORY!

        </div>


        <!-- PLAYER -->

        <div class="winner-avatar">

            🧑🏻‍💻

        </div>


        <div class="winner-name">

            Player 1

        </div>


        <div class="winner-text">

            You won the game!

        </div>


        <!-- SCORE -->

        <div class="score">

            <div class="player-result">

                <div class="result-avatar">
                    🧑🏻‍💻
                </div>

                <div class="result-player-name">
                    Player 1
                </div>

                <div class="result-symbol x">
                    X
                </div>

            </div>


            <div class="score-value">

                1 - 0

            </div>


            <div class="player-result">

                <div class="result-symbol o">
                    O
                </div>

                <div class="result-player-name">
                    Player 2
                </div>

                <div class="result-avatar">
                    🐱
                </div>

            </div>

        </div>


        <!-- GAME INFORMATION -->

        <div class="game-info">

            <div>

                <span>
                    Moves
                </span>

                <strong>
                    87
                </strong>

            </div>


            <div>

                <span>
                    Time
                </span>

                <strong>
                    04:32
                </strong>

            </div>


            <div>

                <span>
                    Rating
                </span>

                <strong class="rating-up">
                    +25
                </strong>

            </div>

        </div>


    </div>


    <!-- BUTTONS -->

    <div class="action-buttons">

        <button onclick="playAgain()">

            Play Again

        </button>


        <button onclick="viewRanking()">

            Ranking

        </button>


        <button onclick="goHome()">

            Home

        </button>

    </div>


</div>


<script src="${pageContext.request.contextPath}/js/result.js"></script>

</body>

</html>