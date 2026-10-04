<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Caro Game</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/login.css">
</head>

<body>

<div class="game-screen">

    <div class="menu">

        <button class="menu-button"
                onclick="goToLogin()">
            Login
        </button>

        <button class="menu-button"
                onclick="goToRegister()">
            Register
        </button>

    </div>

</div>

<script src="${pageContext.request.contextPath}/js/login.js"></script>

</body>
</html>