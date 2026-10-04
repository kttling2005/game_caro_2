<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Join Room - XO Game</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/joinRoom.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="join-room-page">

    <!-- BACK -->

    <button class="back-button"
            onclick="goBack()">

        ← Back

    </button>


    <!-- TITLE -->

    <div class="room-title">

        <span>Join Room</span>

    </div>


    <!-- PANEL -->

    <div class="room-panel">

        <form action="${pageContext.request.contextPath}/join-room"
              method="POST">


            <!-- ROOM ID -->

            <div class="form-group">

                <label for="roomId">

                    Room ID

                </label>

                <input
                    type="text"
                    id="roomId"
                    name="roomId"
                    placeholder="Enter room ID..."
                    maxlength="20"
                    required>

            </div>


            <!-- PASSWORD -->

            <div class="form-group">

                <label for="password">

                    Password
                    <span class="optional">(Optional)</span>

                </label>

                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Enter password..."
                    maxlength="30">

            </div>


            <!-- JOIN -->

            <button type="submit"
                    class="join-button">

                Join Room

            </button>


        </form>


        <!-- FIND MATCH -->

        <div class="find-match-link">

            <span>Don't have a Room ID?</span>

            <button type="button"
                    onclick="findMatch()">

                Find Match

            </button>

        </div>

    </div>

</div>


<script src="${pageContext.request.contextPath}/js/joinRoom.js"></script>

</body>

</html>