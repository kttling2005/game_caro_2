<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>XO Game - Trận Đấu [${roomCode}]</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/gamePlay.css?v=6">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        .waiting-overlay, .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.78);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 999;
            color: #00e878;
            font-family: 'Irish Grover', cursive;
            text-align: center;
            backdrop-filter: blur(5px);
        }
        .waiting-box, .modal-box {
            background: rgba(10, 30, 15, 0.95);
            border: 3px solid #00e878;
            border-radius: 20px;
            padding: 30px 40px;
            box-shadow: 0 0 35px rgba(0, 232, 120, 0.5);
            max-width: 450px;
            width: 90%;
        }
        .waiting-title, .modal-title {
            font-size: 32px;
            margin-bottom: 12px;
        }
        .waiting-code {
            font-size: 40px;
            color: #ffd338;
            letter-spacing: 4px;
            margin: 15px 0;
            user-select: all;
            background: rgba(0,0,0,0.4);
            padding: 8px 16px;
            border-radius: 10px;
            display: inline-block;
        }
        .waiting-spinner {
            font-size: 28px;
            animation: spin 2s infinite linear;
            display: inline-block;
            margin-top: 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* MODAL KẾT QUẢ & TÁI ĐẤU */
        .result-trophy {
            font-size: 55px;
            margin: 5px 0;
        }
        .result-status {
            font-size: 32px;
            margin-bottom: 8px;
        }
        .result-score-change {
            font-family: 'Montserrat', sans-serif;
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 15px;
        }
        .score-win { color: #00e878; }
        .score-loss { color: #ff5252; }
        .score-draw { color: #ffd338; }

        .modal-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 20px;
        }
        .btn-rematch {
            background: linear-gradient(135deg, #00e878, #05a855);
            color: #052611;
            border: none;
            padding: 12px 20px;
            border-radius: 10px;
            font-family: 'Montserrat', sans-serif;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(0, 232, 120, 0.4);
            transition: all 0.2s ease;
        }
        .btn-rematch:hover {
            transform: scale(1.05);
            filter: brightness(1.1);
        }
        .btn-leave {
            background: rgba(220, 53, 69, 0.25);
            border: 2px solid #ff4d5e;
            color: #ff9da6;
            padding: 12px 20px;
            border-radius: 10px;
            font-family: 'Montserrat', sans-serif;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-leave:hover {
            background: #ff4d5e;
            color: white;
        }
        .btn-accept {
            background: #00e878;
            color: #052611;
            border: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-family: 'Montserrat', sans-serif;
            font-weight: 700;
            cursor: pointer;
            font-size: 16px;
        }
        .btn-decline {
            background: #ff4d5e;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-family: 'Montserrat', sans-serif;
            font-weight: 700;
            cursor: pointer;
            font-size: 16px;
        }
        .rematch-status-msg {
            font-family: 'Montserrat', sans-serif;
            font-size: 13px;
            color: #ffd338;
            margin-top: 10px;
        }
    </style>
</head>

<body>

<!-- POPUP CHỜ ĐỐI THỦ LÚC ĐẦU -->
<div id="waitingOverlay" class="waiting-overlay" style="display: none;">
    <div class="waiting-box">
        <div class="waiting-title">ĐANG CHỜ ĐỐI THỦ...</div>
        <p style="font-family: 'Montserrat', sans-serif; font-size: 14px; color: #a0e0b5;">Chia sẻ mã phòng này để đối thủ tham gia:</p>
        <div class="waiting-code">${roomCode}</div>
        <div class="waiting-spinner">⏳</div>
        <div style="margin-top: 20px;">
            <button onclick="leaveGame()" class="btn-leave">Hủy & Rời Phòng</button>
        </div>
    </div>
</div>

<!-- POPUP KẾT QUẢ VÁN ĐẤU & TÁI ĐẤU -->
<div id="resultModal" class="modal-overlay" style="display: none;">
    <div class="modal-box">
        <div class="result-trophy" id="resTrophy">🏆</div>
        <div class="result-status" id="resStatus">VICTORY!</div>
        <div class="result-score-change" id="resScore">+25 điểm Rank</div>
        <div style="font-family: 'Montserrat', sans-serif; font-size: 14px; color: #b5ffb5; margin-bottom: 5px;">
            Số nước đi: <strong id="resMoves">0</strong> | Thời gian: <strong id="resTime">00:00</strong>
        </div>

        <div class="rematch-status-msg" id="rematchStatusMsg" style="display: none;">
            ⏳ Đã gửi lời mời tái đấu. Đang chờ đối thủ...
        </div>

        <div class="modal-buttons" id="resultModalBtns">
            <button class="btn-rematch" id="rematchBtn" onclick="requestRematch()">
                🔄 Tái Đấu Ngay
            </button>
            <button class="btn-leave" onclick="leaveRoom()">
                🚪 Rời Phòng
            </button>
        </div>
    </div>
</div>

<!-- POPUP NHẬN LỜI MỜI TÁI ĐẤU TỪ ĐỐI THỦ -->
<div id="rematchInviteModal" class="modal-overlay" style="display: none;">
    <div class="modal-box">
        <div style="font-size: 45px; margin-bottom: 10px;">⚔️</div>
        <div class="modal-title">LỜI MỜI TÁI ĐẤU!</div>
        <p style="font-family: 'Montserrat', sans-serif; font-size: 15px; color: #ffffff; margin-bottom: 20px;" id="inviteText">
            Đối thủ muốn tái đấu ván tiếp theo với bạn!
        </p>
        <div class="modal-buttons">
            <button class="btn-accept" onclick="acceptRematch()">
                ✅ Chấp Nhận
            </button>
            <button class="btn-decline" onclick="declineRematch()">
                ❌ Từ Chối
            </button>
        </div>
    </div>
</div>

<div class="game-page">

    <!-- TOP HEADER BAR -->
    <div class="game-header">
        <button class="back-button" onclick="leaveGame()" title="Rời phòng">
            ←
        </button>
        <div class="game-title">
            <span class="game-brand">XO GAME</span>
            <span class="room-pill">Phòng: <strong>${roomCode}</strong></span>
        </div>
        <div class="header-spacer"></div>
    </div>

    <!-- MAIN AREA -->
    <div class="game-layout">

        <!-- LEFT CHAT & EMOJI PANEL -->
        <div class="emoji-panel">
            <div class="panel-title">
                Chat
            </div>

            <!-- CHAT INPUT -->
            <div class="chat-box">
                <input type="text" id="chatInput" placeholder="Nhập tin nhắn..." maxlength="100">
                <button type="button" id="sendChatButton">
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

        <!-- CARO BOARD -->
        <div class="board-area">
            <div class="turn-text" id="turnText">
                Đang chuẩn bị...
            </div>

            <div class="board-wrapper" id="boardWrapper">
                <div class="coords-top" id="coordsTop"></div>
                <div class="board-middle">
                    <div class="coords-left" id="coordsLeft"></div>
                    <div class="board" id="board">
                        <!-- JS tạo 225 ô -->
                    </div>
                    <div class="coords-right" id="coordsRight"></div>
                </div>
                <div class="coords-bottom" id="coordsBottom"></div>
            </div>
        </div>

        <!-- TIMER -->
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

            <div class="timer-status" id="timerStatus">
                Sẵn sàng
            </div>
        </div>

    </div>

    <!-- PLAYERS -->
    <div class="players-area">

        <!-- PLAYER 1 (X) -->
        <div class="player-card" id="player1Card">
            <div class="avatar" id="player1Avatar" style="width: 58px !important; height: 58px !important; min-width: 58px !important; max-width: 58px !important; overflow: hidden !important; border-radius: 50% !important; border: 2px solid #00e878; display: flex; align-items: center; justify-content: center; background: #0c1f10; box-shadow: 0 0 12px rgba(0, 232, 120, 0.45);">
                <img id="player1AvatarImg" src="${pageContext.request.contextPath}/assets/avatars/default.svg" alt="Avatar" width="58" height="58" style="width: 58px !important; height: 58px !important; min-width: 58px !important; max-width: 58px !important; min-height: 58px !important; max-height: 58px !important; border-radius: 50% !important; object-fit: cover !important; display: block !important;">
            </div>
            <div class="player-info">
                <div class="player-role-badge role-you" id="player1Role">BẠN</div>
                <div class="player-name" id="player1Name">
                    Người chơi 1
                </div>
                <div class="player-score-tag" id="player1Score">
                    ⭐ 1000 pts
                </div>
                <div class="player-status" id="player1Status">
                    ● Lượt đi
                </div>
            </div>
            <div class="symbol x-symbol" id="player1Symbol">
                X
            </div>
        </div>

        <!-- VS -->
        <div class="vs">
            VS
        </div>

        <!-- PLAYER 2 (O) -->
        <div class="player-card" id="player2Card">
            <div class="symbol o-symbol" id="player2Symbol">
                O
            </div>
            <div class="player-info">
                <div class="player-role-badge role-opponent" id="player2Role">ĐỐI THỦ</div>
                <div class="player-name" id="player2Name">
                    Người chơi 2
                </div>
                <div class="player-score-tag" id="player2Score">
                    ⭐ 1000 pts
                </div>
                <div class="player-status waiting" id="player2Status">
                    ○ Đang chờ
                </div>
            </div>
            <div class="avatar" id="player2Avatar" style="width: 58px !important; height: 58px !important; min-width: 58px !important; max-width: 58px !important; overflow: hidden !important; border-radius: 50% !important; border: 2px solid #00e878; display: flex; align-items: center; justify-content: center; background: #0c1f10; box-shadow: 0 0 12px rgba(0, 232, 120, 0.45);">
                <img id="player2AvatarImg" src="${pageContext.request.contextPath}/assets/avatars/default.svg" alt="Avatar" width="58" height="58" style="width: 58px !important; height: 58px !important; min-width: 58px !important; max-width: 58px !important; min-height: 58px !important; max-height: 58px !important; border-radius: 50% !important; object-fit: cover !important; display: block !important;">
            </div>
        </div>

    </div>

    <!-- EMOJI POPUP -->
    <div id="emojiPopup" class="emoji-popup"></div>

</div>

<!-- THIẾT LẬP THÔNG SỐ TOÀN CỤC CHO WEBSOCKET -->
<script>
    const currentUserId = ${sessionScope.currentUser.id};
    const currentUsername = "${sessionScope.currentUser.username}";
    const currentNickname = "${sessionScope.currentUser.nickname}";
    const roomCode = "${roomCode}";
    const contextPath = "${pageContext.request.contextPath}";
</script>

<script src="${pageContext.request.contextPath}/js/audio.js?v=1"></script>
<script src="${pageContext.request.contextPath}/js/gamePlay.js?v=<%= System.currentTimeMillis() %>"></script>

</body>
</html>