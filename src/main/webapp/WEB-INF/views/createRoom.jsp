<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Create Room - XO Game</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/createRoom.css">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

</head>

<body>

<div class="create-room-page">

    <!-- BACK -->

    <button class="back-button"
            onclick="goBack()">

        ← Back

    </button>


    <!-- TITLE -->

    <div class="room-title">

        <span>Create Room</span>

    </div>


    <!-- FORM PANEL -->

    <div class="room-panel">

        <form action="${pageContext.request.contextPath}/create-room"
              method="POST">


            <!-- ROOM NAME -->

            <div class="form-group">

                <label for="roomName">

                    Room Name

                </label>

                <input
                    type="text"
                    id="roomName"
                    name="roomName"
                    placeholder="Enter room name..."
                    maxlength="30"
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


            <!-- CREATE -->

            <button type="submit"
                    class="create-button">

                Create

            </button>

        </form>

    </div>

</div>


<script src="${pageContext.request.contextPath}/js/createRoom.js"></script>

</body>

</html>