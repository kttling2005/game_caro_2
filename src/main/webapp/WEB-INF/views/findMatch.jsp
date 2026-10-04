<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Find Match - XO Game</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/findMatch.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="find-match-page">

    <!-- BACK -->

    <button class="back-button"
            onclick="goBack()">

        ← Back

    </button>


    <!-- TITLE -->

    <div class="match-title">

        <span>Find Match</span>

    </div>


    <!-- SEARCH PANEL -->

    <div class="match-panel">

        <div class="search-icon">

            <div class="pixel-circle"></div>

        </div>


        <div class="search-status">

            Searching for opponent<span class="dots"></span>

        </div>


        <div class="search-description">

            Looking for another player<br>
            to start a game with you.

        </div>


        <!-- CANCEL -->

        <button class="cancel-button"
                onclick="cancelSearch()">

            Cancel

        </button>

    </div>

</div>


<script src="${pageContext.request.contextPath}/js/findMatch.js"></script>

</body>

</html>