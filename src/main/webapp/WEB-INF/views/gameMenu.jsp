<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%@page import="java.util.List"%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>XO Game - Game Menu</title>

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/gameMenu.css?v=<%= System.currentTimeMillis() %>">

    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&display=swap"
          rel="stylesheet">

    <style>
        /* ========================================================
           STATUS-SPECIFIC COLORS & EFFECTS (ONLINE, OFFLINE, PLAYING, IN_ROOM)
           ======================================================== */

        .player-avatar {
            width: 44px !important;
            height: 44px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            flex-shrink: 0 !important;
            border-radius: 50% !important;
            background: #0c1a0e !important;
            overflow: hidden !important;
            padding: 0 !important;
            transition: all 0.25s ease !important;
        }

        .player-avatar img {
            width: 100% !important;
            height: 100% !important;
            object-fit: cover !important;
            border-radius: 50% !important;
            display: block !important;
        }

        .player-status {
            display: inline-flex !important;
            align-items: center !important;
            gap: 5px !important;
            font-family: Arial, sans-serif !important;
            font-size: 11px !important;
            font-weight: 700 !important;
            letter-spacing: 0.5px !important;
        }

        .status-dot {
            width: 8px !important;
            height: 8px !important;
            border-radius: 50% !important;
            display: inline-block !important;
            flex-shrink: 0 !important;
        }

        /* 🟢 ONLINE: Xanh lá Neon tươi sáng */
        .status-online .player-avatar {
            border: 2px solid #00e878 !important;
            box-shadow: 0 0 10px rgba(0, 232, 120, 0.45) !important;
        }
        .status-online .player-avatar img {
            filter: none !important;
        }
        .status-online .status-dot {
            background: #00e878 !important;
            box-shadow: 0 0 6px #00e878 !important;
            animation: onlinePulse 1.8s infinite ease-in-out !important;
        }
        .status-online .status-text,
        .player-status.status-online {
            color: #00e878 !important;
            text-shadow: 0 0 6px rgba(0, 232, 120, 0.35) !important;
        }
        .player.status-online:hover {
            background: rgba(0, 232, 120, 0.14) !important;
        }

        /* ⚪ OFFLINE: Xám trầm lịch thiệp */
        .status-offline .player-avatar {
            border: 2px solid rgba(135, 150, 140, 0.45) !important;
            box-shadow: none !important;
        }
        .status-offline .player-avatar img {
            filter: grayscale(45%) opacity(0.8) !important;
        }
        .status-offline .status-dot {
            background: #78857c !important;
            box-shadow: none !important;
            animation: none !important;
        }
        .status-offline .status-text,
        .player-status.status-offline {
            color: #8c9b91 !important;
            text-shadow: none !important;
        }
        .player.status-offline:hover {
            background: rgba(255, 255, 255, 0.06) !important;
        }

        /* 🔴 PLAYING: Đỏ rực đang trong trận chiến */
        .status-playing .player-avatar {
            border: 2px solid #ff4757 !important;
            box-shadow: 0 0 10px rgba(255, 71, 87, 0.5) !important;
        }
        .status-playing .player-avatar img {
            filter: none !important;
        }
        .status-playing .status-dot {
            background: #ff4757 !important;
            box-shadow: 0 0 7px #ff4757 !important;
            animation: playingPulse 1.3s infinite ease-in-out !important;
        }
        .status-playing .status-text,
        .player-status.status-playing {
            color: #ff5252 !important;
            text-shadow: 0 0 6px rgba(255, 82, 82, 0.35) !important;
        }
        .player.status-playing:hover {
            background: rgba(255, 71, 87, 0.14) !important;
        }

        /* 🟡 IN_ROOM / WAITING: Vàng cam đang chờ trong phòng */
        .status-in-room .player-avatar {
            border: 2px solid #ffa502 !important;
            box-shadow: 0 0 10px rgba(255, 165, 2, 0.45) !important;
        }
        .status-in-room .player-avatar img {
            filter: none !important;
        }
        .status-in-room .status-dot {
            background: #ffa502 !important;
            box-shadow: 0 0 7px #ffa502 !important;
            animation: inRoomPulse 1.8s infinite ease-in-out !important;
        }
        .status-in-room .status-text,
        .player-status.status-in-room {
            color: #ffa502 !important;
            text-shadow: 0 0 6px rgba(255, 165, 2, 0.35) !important;
        }
        .player.status-in-room:hover {
            background: rgba(255, 165, 2, 0.14) !important;
        }

        @keyframes playingPulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(0.8); }
        }

        @keyframes inRoomPulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.55; transform: scale(0.85); }
        }
    </style>
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

    <!-- CHALLENGE -->
    <button class="game-option challenge-menu-btn"
            onclick="window.location.href='${pageContext.request.contextPath}/challenge';">
        Challenge
    </button>
    
    <button class="back-button" onclick="goBack()">
        ← Back
    </button>
    
    <!-- CURRENT USER PROFILE BADGE -->
    <%
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser != null) {
    %>
    <div style="position: absolute; top: 20px; right: 25px; display: flex; align-items: center; gap: 10px; background: rgba(4,18,9,0.85); border: 2px solid #00e878; padding: 6px 16px 6px 8px; border-radius: 30px; box-shadow: 0 0 15px rgba(0,232,120,0.4); cursor: pointer;" onclick="window.location.href='profile?tab=profile'" title="Xem cài đặt và hồ sơ">
        <img src="<%= currentUser.getAvatarUrl(request.getContextPath()) %>" alt="Avatar" style="width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #ffd700;">
        <div>
            <div style="font-size: 13px; font-weight: bold; color: #ffffff; font-family: sans-serif;"><%= currentUser.getNickname() != null ? currentUser.getNickname() : currentUser.getUsername() %></div>
            <div style="font-size: 11px; color: #00e878; font-family: sans-serif;">⭐ <%= currentUser.getScore() %> pts &bull; <%= currentUser.getRankTier() %></div>
        </div>
    </div>
    <% } %>

    <!-- ONLINE PLAYERS -->
    <div class="online-players">

        <div class="online-header">
            <span class="online-title">Online Players</span>
            <span class="online-count"><%= request.getAttribute("onlineCount") != null ? request.getAttribute("onlineCount") : 1 %> Online</span>
        </div>

        <div class="player-list">

            <%
                List<User> topPlayers = (List<User>) request.getAttribute("topPlayers");
                Boolean hasOtherOnline = (Boolean) request.getAttribute("hasOtherOnline");
                if (topPlayers != null && !topPlayers.isEmpty()) {
                    for (User p : topPlayers) {
                        String avaUrl = p.getAvatarUrl(request.getContextPath());
                        String rawStatus = p.getStatus() != null ? p.getStatus().toUpperCase() : "OFFLINE";
                        boolean isOnline = "ONLINE".equals(rawStatus);
                        boolean isPlaying = "PLAYING".equals(rawStatus) || "IN_ROOM".equals(rawStatus) || "WAITING".equals(rawStatus);

                        String statusClass = isOnline ? "status-online" : (isPlaying ? "status-playing" : "status-offline");
                        String statusLabel = isOnline ? "ONLINE" : (isPlaying ? "IN ROOM" : "OFFLINE");
            %>
            <div class="player <%= statusClass %>" style="display: flex; align-items: center; justify-content: space-between;">
                <div style="display: flex; align-items: center; gap: 8px; overflow: hidden; flex: 1;">
                    <div class="player-avatar">
                        <img src="<%= avaUrl %>" alt="Avatar">
                    </div>
                    <div class="player-info" style="overflow: hidden;">
                        <span class="player-name" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; display: block;" title="<%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>">
                            <%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>
                        </span>
                        <div class="player-details">
                            <span class="player-score">
                                ⭐ <%= p.getScore() %> pts &bull; <%= p.getRankTier() %>
                            </span>

                            <span class="player-status <%= statusClass %>">
                                <span class="status-dot"></span>
                                <span class="status-text"><%= statusLabel %></span>
                            </span>
                        </div>
                    </div>
                </div>

                <% if (isOnline) { %>
                <button class="btn-quick-challenge"
                        onclick="window.location.href='${pageContext.request.contextPath}/challenge-wait?targetId=<%= p.getId() %>'"
                        title="Thách đấu ngay với <%= p.getNickname() != null ? p.getNickname() : p.getUsername() %>">
                    ⚔️
                </button>
                <% } %>
            </div>
            <%
                    }
                }
            %>

        </div>

        <% if (Boolean.FALSE.equals(hasOtherOnline)) { %>
        <div style="font-size: 11px; color: #8eb39b; text-align: center; margin-top: 8px; padding-top: 6px; border-top: 1px dashed rgba(255,255,255,0.18); font-family: sans-serif; line-height: 1.35;">
            💡 <em>Chưa có đối thủ trực tuyến khác.<br>Dùng <strong>Find Match</strong> để chờ ghép trận!</em>
        </div>
        <% } %>

    </div>

</div>

<!-- MODAL NHẬN THÁCH ĐẤU -->
<div id="incomingChallengeModal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.78); z-index: 9999; justify-content: center; align-items: center; backdrop-filter: blur(5px);">
    <div style="background: linear-gradient(135deg, #092e1a, #04160b); border: 2px solid #ffd338; border-radius: 18px; padding: 25px 35px; text-align: center; max-width: 440px; width: 90%; box-shadow: 0 0 35px rgba(255,211,56,0.35); font-family: sans-serif;">
        <div style="font-size: 50px; margin-bottom: 10px;">⚔️</div>
        <div style="font-size: 24px; font-weight: bold; color: #ffd338; font-family: 'Irish Grover', cursive; margin-bottom: 10px;">LỜI MỜI THÁCH ĐẤU!</div>
        <p id="challengeModalDesc" style="color: #ffffff; font-size: 15px; margin-bottom: 15px; line-height: 1.5;">
            Đối thủ đang gửi lời mời thách đấu với bạn!
        </p>
        <div id="challengeModalTimer" style="font-size: 18px; font-weight: bold; color: #ff5252; margin-bottom: 22px;">
            ⏳ Hết hạn sau: 30s
        </div>
        <div style="display: flex; gap: 15px; justify-content: center;">
            <button id="btnAcceptChallenge" onclick="respondChallenge(true)" style="background: linear-gradient(135deg, #00e878, #05a855); color: #052611; border: none; padding: 12px 24px; border-radius: 8px; font-weight: bold; font-size: 14px; cursor: pointer; box-shadow: 0 0 10px rgba(0,232,120,0.4);">
                ✅ Chấp Nhận
            </button>
            <button id="btnDeclineChallenge" onclick="respondChallenge(false)" style="background: rgba(255,82,82,0.2); border: 1px solid #ff5252; color: #ff5252; padding: 12px 24px; border-radius: 8px; font-weight: bold; font-size: 14px; cursor: pointer;">
                ❌ Từ Chối
            </button>
        </div>
    </div>
</div>

<script>
    const currentUserId = ${sessionScope.currentUser != null ? sessionScope.currentUser.id : 0};
    const contextPath = "${pageContext.request.contextPath}";
    function goBack() { window.location.href = contextPath + "/home"; }
    function createRoom() { window.location.href = contextPath + "/create-room"; }
    function joinRoom() { window.location.href = contextPath + "/join-room"; }
    function findMatch() { window.location.href = contextPath + "/find-match"; }
    function challengePlayer() { window.location.href = contextPath + "/challenge"; }
</script>
<script src="${pageContext.request.contextPath}/js/gameMenu.js?v=<%= System.currentTimeMillis() %>"></script>

</body>
</html>