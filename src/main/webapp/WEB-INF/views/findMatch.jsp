<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Tìm Trận Tự Động</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/findMatch.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap" rel="stylesheet">
    <style>
        .match-timer {
            font-size: 24px;
            color: #ffd338;
            margin: 10px 0;
            font-weight: bold;
        }
    </style>
</head>

<body>

<div class="find-match-page">

    <!-- BACK -->
    <button class="back-button" onclick="cancelSearch()">
        ← Back
    </button>

    <!-- TITLE -->
    <div class="match-title">
        <span>TÌM TRẬN ĐẤU</span>
    </div>

    <!-- SEARCH PANEL -->
    <div class="match-panel">

        <div class="search-icon">
            <div class="pixel-circle"></div>
        </div>

        <div class="search-status" id="searchStatus">
            Đang tìm kiếm đối thủ<span class="dots"></span>
        </div>

        <div class="match-timer" id="searchTimer">
            00:00
        </div>

        <div class="search-description" id="searchDesc">
            Hệ thống đang ghép cặp bạn với người chơi khác...
        </div>

        <!-- CANCEL -->
        <button class="cancel-button" onclick="cancelSearch()">
            Hủy Tìm Kiếm
        </button>

    </div>

</div>

<script>
    const currentUserId = ${sessionScope.currentUser.id};
    const contextPath = "${pageContext.request.contextPath}";
</script>

<script src="${pageContext.request.contextPath}/js/findMatch.js"></script>

</body>
</html>