<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chờ Đối Thủ Phản Hồi - XO Game</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/challengeWait.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&family=Montserrat:wght@400;600;700;800&display=swap" rel="stylesheet">
</head>
<body>

<%
    User currentUser = (User) request.getAttribute("currentUser");
    User targetUser = (User) request.getAttribute("targetUser");
%>

<div class="challenge-wait-page">
    <div class="wait-container">
        
        <h1 class="wait-title">⚔️ THÁCH ĐẤU ĐỐI THỦ</h1>

        <div class="battle-arena">
            <!-- CHỦ LỜI MỜI (BẠN) -->
            <div class="fighter-card">
                <div class="fighter-avatar-wrapper">
                    <img class="fighter-avatar avatar-you" src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Bạn">
                </div>
                <div class="fighter-name">
                    <%= currentUser.getNickname() != null ? currentUser.getNickname() : currentUser.getUsername() %>
                </div>
                <div class="fighter-rank">
                    ⭐ <%= currentUser.getScore() %> pts &bull; <%= currentUser.getRankTier() %>
                </div>
            </div>

            <!-- VS BADGE -->
            <div class="vs-badge-wrapper">
                <div class="vs-text">VS</div>
            </div>

            <!-- ĐỐI THỦ -->
            <div class="fighter-card">
                <div class="fighter-avatar-wrapper">
                    <img class="fighter-avatar avatar-opponent" src="<%= targetUser.getAvatarUrl(request.getContextPath()) %>" alt="Đối thủ">
                </div>
                <div class="fighter-name">
                    <%= targetUser.getNickname() != null ? targetUser.getNickname() : targetUser.getUsername() %>
                </div>
                <div class="fighter-rank">
                    ⭐ <%= targetUser.getScore() %> pts &bull; <%= targetUser.getRankTier() %>
                </div>
            </div>
        </div>

        <div class="wait-status" id="waitStatus">
            ⏳ Đang gửi lời mời thách đấu tới <strong><%= targetUser.getNickname() != null ? targetUser.getNickname() : targetUser.getUsername() %></strong>...
        </div>

        <div class="wait-timer" id="waitTimer">
            00:30
        </div>

        <button class="btn-cancel-challenge" id="btnCancel" onclick="cancelChallenge()">
            ❌ Hủy Lời Mời
        </button>

    </div>
</div>

<script>
    const currentUserId = ${currentUser.id};
    const targetUserId = ${targetUser.id};
    const contextPath = "${pageContext.request.contextPath}";
</script>
<script src="${pageContext.request.contextPath}/js/challengeWait.js?v=<%= System.currentTimeMillis() %>"></script>

</body>
</html>
