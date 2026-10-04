<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>XO Game - Ranking</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/ranking.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="ranking-page">

    <!-- BACK -->

    <button class="back-button"
            onclick="goBack()">

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


        <!-- 1 -->

        <div class="ranking-row first">

            <div class="rank">
                🥇
            </div>

            <div class="player">

                <div class="avatar">
                    🧑🏻‍💻
                </div>

                <span>
                    Player 1
                </span>

            </div>

            <div>12</div>

            <div>2</div>

            <div class="rating">
                325
            </div>

        </div>


        <!-- 2 -->

        <div class="ranking-row second">

            <div class="rank">
                🥈
            </div>

            <div class="player">

                <div class="avatar">
                    🐱
                </div>

                <span>
                    Player 2
                </span>

            </div>

            <div>10</div>

            <div>4</div>

            <div class="rating">
                290
            </div>

        </div>


        <!-- 3 -->

        <div class="ranking-row third">

            <div class="rank">
                🥉
            </div>

            <div class="player">

                <div class="avatar">
                    🧙
                </div>

                <span>
                    Player 3
                </span>

            </div>

            <div>8</div>

            <div>5</div>

            <div class="rating">
                250
            </div>

        </div>


        <!-- 4 -->

        <div class="ranking-row">

            <div class="rank">
                4
            </div>

            <div class="player">

                <div class="avatar">
                    🐼
                </div>

                <span>
                    Player 4
                </span>

            </div>

            <div>7</div>

            <div>6</div>

            <div class="rating">
                225
            </div>

        </div>


        <!-- 5 -->

        <div class="ranking-row">

            <div class="rank">
                5
            </div>

            <div class="player">

                <div class="avatar">
                    🦊
                </div>

                <span>
                    Player 5
                </span>

            </div>

            <div>6</div>

            <div>7</div>

            <div class="rating">
                210
            </div>

        </div>


    </div>


    <!-- CURRENT PLAYER -->

    <div class="my-ranking">

        <span>Your Ranking:</span>

        <strong>#12</strong>

        <span>Rating: 185</span>

    </div>


</div>


<script src="${pageContext.request.contextPath}/js/ranking.js"></script>

</body>

</html>