const BOARD_SIZE = 15;

let mySymbol = null; // "X" hoặc "O"
let currentTurn = "X";
let isGameStarted = false;
let gameOver = false;
let timeLeft = 60;
let timer = null;
let movesCount = 0;
let gameStartTime = null;
let gameOverModalTimeout = null;

const board = document.getElementById("board");
const timerElement = document.getElementById("timer");
const turnText = document.getElementById("turnText");
const timerStatus = document.getElementById("timerStatus");
const waitingOverlay = document.getElementById("waitingOverlay");

const player1Card = document.getElementById("player1Card");
const player2Card = document.getElementById("player2Card");
const player1Name = document.getElementById("player1Name");
const player2Name = document.getElementById("player2Name");
const player1Status = document.getElementById("player1Status");
const player2Status = document.getElementById("player2Status");
const player1Symbol = document.getElementById("player1Symbol");
const player2Symbol = document.getElementById("player2Symbol");

// Modals
const resultModal = document.getElementById("resultModal");
const resTrophy = document.getElementById("resTrophy");
const resStatus = document.getElementById("resStatus");
const resScore = document.getElementById("resScore");
const resMoves = document.getElementById("resMoves");
const resTime = document.getElementById("resTime");
const rematchBtn = document.getElementById("rematchBtn");
const rematchStatusMsg = document.getElementById("rematchStatusMsg");

const rematchInviteModal = document.getElementById("rematchInviteModal");
const inviteText = document.getElementById("inviteText");

// ==========================================
// 1. KẾT NỐI WEBSOCKET
// ==========================================

const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const wsUrl = protocol + "//" + window.location.host + contextPath + "/ws/game/" + currentUserId;
const socket = new WebSocket(wsUrl);

socket.onopen = function () {
    console.log("WebSocket connected to:", wsUrl);
    socket.send(JSON.stringify({
        action: "JOIN_ROOM",
        roomCode: roomCode
    }));
};

socket.onmessage = function (event) {
    try {
        const data = JSON.parse(event.data);
        console.log("WS Message received:", data);

        switch (data.action) {
            case "WAITING_OPPONENT":
                if (roomCode.startsWith("QUICK_")) {
                    if (waitingOverlay) {
                        waitingOverlay.style.display = "flex";
                        const waitingTitle = waitingOverlay.querySelector(".waiting-title");
                        if (waitingTitle) waitingTitle.textContent = "ĐANG GHÉP TRẬN...";
                        const waitingDesc = waitingOverlay.querySelector("p");
                        if (waitingDesc) waitingDesc.textContent = "Đang kết nối với đối thủ, vui lòng đợi giây lát...";
                        const waitingCode = waitingOverlay.querySelector(".waiting-code");
                        if (waitingCode) waitingCode.style.display = "none";
                    }
                    turnText.textContent = "Đang kết nối đối thủ...";
                } else {
                    if (waitingOverlay) waitingOverlay.style.display = "flex";
                    turnText.textContent = "Đang chờ đối thủ...";
                }
                break;

            case "START_GAME":
            case "REMATCH_START":
                handleStartGame(data);
                break;

            case "MOVE_UPDATE":
                handleMoveUpdate(data);
                break;

            case "CHAT":
                handleIncomingChat(data);
                break;

            case "EMOJI":
                handleIncomingEmoji(data);
                break;

            case "GAME_OVER":
                handleGameOver(data);
                break;

            case "REMATCH_INVITATION":
                handleRematchInvitation(data);
                break;

            case "REMATCH_DECLINED":
                handleRematchDeclined(data);
                break;

            case "OPPONENT_LEFT":
                alert(data.message || "Đối thủ đã thoát ván. Bạn giành chiến thắng!");
                window.location.href = contextPath + "/game";
                break;

            case "GUEST_LEFT_WAITING":
                handleGuestLeftWaiting(data);
                break;

            case "HOST_LEFT_ROOM":
                alert(data.message || "Chủ phòng đã rời đi. Phòng đã đóng!");
                window.location.href = contextPath + "/game";
                break;

            case "ERROR":
                alert("Lỗi: " + data.message);
                window.location.href = contextPath + "/game";
                break;

            default:
                break;
        }
    } catch (e) {
        console.error("Lỗi parse WS message:", e);
    }
};

socket.onclose = function () {
    console.log("WebSocket closed.");
};

socket.onerror = function (err) {
    console.error("WebSocket error:", err);
};

// ==========================================
// 2. ÂM THANH & TIỆN ÍCH AVATAR
// ==========================================

let gameAudioCtx = null;
function getGameAudioContext() {
    if (!gameAudioCtx) {
        const AudioContext = window.AudioContext || window.webkitAudioContext;
        gameAudioCtx = new AudioContext();
    }
    if (gameAudioCtx.state === 'suspended') {
        gameAudioCtx.resume();
    }
    return gameAudioCtx;
}

function isSfxEnabled() {
    return localStorage.getItem('caro_sfx') !== 'false';
}

function getVolumeLevel() {
    const vol = localStorage.getItem('caro_volume');
    return vol !== null ? parseFloat(vol) / 100 : 0.8;
}

function setGameToneGain(gainNode, ctx, startTime, peak, duration) {
    const start = Math.max(peak, 0.0001);
    gainNode.gain.setValueAtTime(start, startTime);
    gainNode.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
}

function playGameSoundMove() {
    if (!isSfxEnabled()) return;
    try {
        const vol = getVolumeLevel();
        if (vol <= 0) return;
        const ctx = getGameAudioContext();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(800, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.08);
        setGameToneGain(gain, ctx, ctx.currentTime, vol * 0.4, 0.08);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.08);
    } catch (e) {
        console.warn("Audio error:", e);
    }
}

function playGameSoundWin() {
    if (!isSfxEnabled()) return;
    try {
        const vol = getVolumeLevel();
        if (vol <= 0) return;
        const ctx = getGameAudioContext();
        const notes = [523.25, 659.25, 783.99, 1046.50];
        notes.forEach((freq, idx) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            const startTime = ctx.currentTime + idx * 0.1;
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, startTime);
            setGameToneGain(gain, ctx, startTime, vol * 0.35, 0.25);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(startTime);
            osc.stop(startTime + 0.25);
        });
    } catch (e) {
        console.warn("Audio error:", e);
    }
}

function playGameSoundDefeat() {
    if (!isSfxEnabled()) return;
    try {
        const vol = getVolumeLevel();
        if (vol <= 0) return;
        const ctx = getGameAudioContext();
        const notes = [440, 415.3, 392, 369.99];
        notes.forEach((freq, idx) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            const startTime = ctx.currentTime + idx * 0.15;
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(freq, startTime);
            setGameToneGain(gain, ctx, startTime, vol * 0.25, 0.2);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(startTime);
            osc.stop(startTime + 0.2);
        });
    } catch (e) {
        console.warn("Audio error:", e);
    }
}

function resolveAvatarUrl(avatar) {
    if (!avatar || avatar === "default.png" || avatar === "default.svg") {
        return contextPath + "/assets/avatars/avatar1.svg";
    }
    if (avatar.startsWith("uploads/") || avatar.startsWith("assets/")) {
        return contextPath + "/" + avatar;
    }
    if (avatar.startsWith("avatar") && avatar.endsWith(".svg")) {
        return contextPath + "/assets/avatars/" + avatar;
    }
    if (avatar.startsWith("http://") || avatar.startsWith("https://")) {
        return avatar;
    }
    return contextPath + "/assets/avatars/" + avatar;
}

// ==========================================
// 3. XỬ LÝ BẮT ĐẦU VÁN / TÁI ĐẤU
// ==========================================

function handleStartGame(data) {
    console.log("[GAME] handleStartGame received:", data);

    if (gameOverModalTimeout) {
        clearTimeout(gameOverModalTimeout);
        gameOverModalTimeout = null;
    }

    // Ẩn tất cả popup
    if (waitingOverlay) waitingOverlay.style.display = "none";
    if (resultModal) resultModal.style.display = "none";
    if (rematchInviteModal) rematchInviteModal.style.display = "none";
    if (rematchBtn) {
        rematchBtn.style.display = "inline-block";
        rematchBtn.textContent = "🔄 Tái Đấu Ngay";
        rematchBtn.style.background = "";
        rematchBtn.style.color = "";
    }
    if (rematchStatusMsg) {
        rematchStatusMsg.style.display = "none";
        rematchStatusMsg.textContent = "";
    }

    isGameStarted = true;
    gameOver = false;
    if (window.CaroAudio) {
        CaroAudio.syncBgm();
    }
    mySymbol = data.yourSymbol;
    currentTurn = data.nextTurn || "X";
    movesCount = 0;
    gameStartTime = Date.now();

    // Cập nhật tên, ảnh avatar, điểm số và vai trò của 2 người chơi
    const p1Img = document.getElementById("player1AvatarImg");
    const p2Img = document.getElementById("player2AvatarImg");
    const p1Role = document.getElementById("player1Role");
    const p2Role = document.getElementById("player2Role");
    const p1Score = document.getElementById("player1Score");
    const p2Score = document.getElementById("player2Score");

    if (data.player1) {
        if (player1Name) player1Name.textContent = data.player1.nickname || data.player1.username;
        if (p1Img) p1Img.src = resolveAvatarUrl(data.player1.avatar);
        if (p1Score) p1Score.textContent = "⭐ " + (data.player1.score || 1000) + " pts";

        const isMeP1 = (data.player1.id === currentUserId);
        if (p1Role) {
            p1Role.textContent = isMeP1 ? "BẠN (YOU)" : "ĐỐI THỦ";
            p1Role.className = "player-role-badge " + (isMeP1 ? "role-you" : "role-opponent");
        }
    }

    if (data.player2) {
        if (player2Name) player2Name.textContent = data.player2.nickname || data.player2.username;
        if (p2Img) p2Img.src = resolveAvatarUrl(data.player2.avatar);
        if (p2Score) p2Score.textContent = "⭐ " + (data.player2.score || 1000) + " pts";

        const isMeP2 = (data.player2.id === currentUserId);
        if (p2Role) {
            p2Role.textContent = isMeP2 ? "BẠN (YOU)" : "ĐỐI THỦ";
            p2Role.className = "player-role-badge " + (isMeP2 ? "role-you" : "role-opponent");
        }
    }

    // Cập nhật hiển thị Symbol (X / O) cho người chơi
    if (player1Symbol && player2Symbol) {
        const p1IsX = (data.player1 && data.player1.id === currentUserId)
            ? (mySymbol === "X")
            : (mySymbol === "O");

        player1Symbol.textContent = p1IsX ? "X" : "O";
        player1Symbol.className = "symbol " + (p1IsX ? "x-symbol" : "o-symbol");

        player2Symbol.textContent = p1IsX ? "O" : "X";
        player2Symbol.className = "symbol " + (p1IsX ? "o-symbol" : "x-symbol");
    }

    createBoard();
    updateTurnUI();
    resetTimer();
}

function handleMoveUpdate(data) {
    const row = data.row;
    const col = data.col;
    const symbol = data.symbol;

    // Xóa highlight ở tất cả ô cờ cũ
    document.querySelectorAll(".cell.last-move").forEach(c => c.classList.remove("last-move"));

    const cell = document.querySelector(`.cell[data-row="${row}"][data-col="${col}"]`);
    if (cell) {
        cell.textContent = symbol;
        cell.classList.add(symbol === "X" ? "x" : "o");
        
        // Kiểm tra thiết lập highlight trong localStorage (mặc định là true)
        const isHighlightEnabled = localStorage.getItem('caro_highlight') !== 'false';
        if (isHighlightEnabled) {
            cell.classList.add("last-move");
        }
    }

    currentTurn = data.nextTurn;
    movesCount++;

    playGameSoundMove();

    updateTurnUI();
    resetTimer();
}

function handleGameOver(data) {
    gameOver = true;
    clearInterval(timer);
    if (window.CaroAudio) {
        CaroAudio.stopBgm();
    }

    // Vẽ nước cờ cuối nếu có
    if (data.row >= 0 && data.col >= 0) {
        const cell = document.querySelector(`.cell[data-row="${data.row}"][data-col="${data.col}"]`);
        if (cell && cell.textContent === "") {
            cell.textContent = data.winner;
            cell.classList.add(data.winner === "X" ? "x" : "o");
            const isHighlightEnabled = localStorage.getItem('caro_highlight') !== 'false';
            if (isHighlightEnabled) {
                document.querySelectorAll(".cell.last-move").forEach(c => c.classList.remove("last-move"));
                cell.classList.add("last-move");
            }
        }
    }

    let timeString = "00:00";
    if (gameStartTime) {
        const elapsedSec = Math.floor((Date.now() - gameStartTime) / 1000);
        const mins = String(Math.floor(elapsedSec / 60)).padStart(2, "0");
        const secs = String(elapsedSec % 60).padStart(2, "0");
        timeString = mins + ":" + secs;
    }

    // Cập nhật giao diện modal kết quả
    if (resMoves) resMoves.textContent = movesCount;
    if (resTime) resTime.textContent = timeString;

    if (data.winner === "DRAW") {
        turnText.textContent = "HÒA CỜ!";
        timerStatus.textContent = "Hòa!";
        if (resTrophy) resTrophy.textContent = "🤝";
        if (resStatus) resStatus.textContent = "HÒA CỜ!";
        if (resScore) {
            resScore.textContent = "+5 điểm Rank";
            resScore.className = "result-score-change score-draw";
        }
    } else if (data.winner === mySymbol) {
        playGameSoundWin();
        turnText.textContent = "BẠN ĐÃ THẮNG!";
        timerStatus.textContent = "Chiến thắng!";
        if (resTrophy) resTrophy.textContent = "🏆";
        if (resStatus) resStatus.textContent = "VICTORY!";
        if (resScore) {
            resScore.textContent = "+25 điểm Rank";
            resScore.className = "result-score-change score-win";
        }
    } else {
        playGameSoundDefeat();
        turnText.textContent = "BẠN ĐÃ THUA!";
        timerStatus.textContent = "Thất bại!";
        if (resTrophy) resTrophy.textContent = "💔";
        if (resStatus) resStatus.textContent = "DEFEAT!";
        if (resScore) {
            resScore.textContent = "-15 điểm Rank";
            resScore.className = "result-score-change score-loss";
        }
    }

    // Hiển thị modal kết quả trên bàn cờ sau 1 giây nếu vẫn đang ở trạng thái kết thúc ván
    if (gameOverModalTimeout) clearTimeout(gameOverModalTimeout);
    gameOverModalTimeout = setTimeout(function () {
        if (gameOver && resultModal) {
            resultModal.style.display = "flex";
        }
    }, 1000);
}

// ==========================================
// 3. TÁI ĐẤU (REMATCH)
// ==========================================

function requestRematch() {
    console.log("[REMATCH] Sending REMATCH_REQUEST for room: " + roomCode);
    socket.send(JSON.stringify({
        action: "REMATCH_REQUEST",
        roomCode: roomCode
    }));

    if (rematchBtn) rematchBtn.style.display = "none";
    if (rematchStatusMsg) {
        rematchStatusMsg.textContent = "⏳ Đã sẵn sàng! Đang chờ đối thủ bấm Tái Đấu...";
        rematchStatusMsg.style.display = "block";
    }
}

function handleRematchInvitation(data) {
    console.log("[REMATCH] Received REMATCH_INVITATION from " + data.senderName);
    if (rematchBtn) {
        rematchBtn.textContent = "⚔️ Đối thủ muốn tái đấu! Bấm để đấu ngay!";
        rematchBtn.style.background = "linear-gradient(135deg, #ffd338, #d4a008)";
        rematchBtn.style.color = "#3b2800";
        rematchBtn.style.display = "inline-block";
    }
    if (rematchStatusMsg) {
        rematchStatusMsg.textContent = "⚔️ Đối thủ [" + (data.senderName || "Người chơi") + "] đã bấm Tái Đấu! Hãy bấm Tái Đấu để bắt đầu ngay!";
        rematchStatusMsg.style.display = "block";
    }

    // Nếu modal kết quả đã đóng, mở popup lời mời
    if (!resultModal || resultModal.style.display === "none") {
        if (inviteText) {
            inviteText.textContent = "Đối thủ [" + (data.senderName || "Người chơi") + "] muốn tái đấu ván tiếp theo với bạn!";
        }
        if (rematchInviteModal) rematchInviteModal.style.display = "flex";
    }
}

function acceptRematch() {
    console.log("[REMATCH] Sending REMATCH_RESPONSE accepted=true for room: " + roomCode);
    socket.send(JSON.stringify({
        action: "REMATCH_RESPONSE",
        roomCode: roomCode,
        accepted: true
    }));
    if (rematchInviteModal) rematchInviteModal.style.display = "none";
}

function declineRematch() {
    socket.send(JSON.stringify({
        action: "REMATCH_RESPONSE",
        roomCode: roomCode,
        accepted: false
    }));
    if (rematchInviteModal) rematchInviteModal.style.display = "none";
    if (resultModal) resultModal.style.display = "flex";
}

function handleRematchDeclined(data) {
    if (rematchStatusMsg) {
        rematchStatusMsg.textContent = "⚠️ Đối thủ đã từ chối yêu cầu tái đấu.";
        rematchStatusMsg.style.display = "block";
    }
    if (rematchBtn) rematchBtn.style.display = "inline-block";
}

function leaveRoom() {
    if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            action: "LEAVE_ROOM",
            roomCode: roomCode
        }));
    }
    window.location.href = contextPath + "/game";
}

function handleGuestLeftWaiting(data) {
    if (resultModal) resultModal.style.display = "none";
    if (rematchInviteModal) rematchInviteModal.style.display = "none";
    if (waitingOverlay) waitingOverlay.style.display = "flex";

    if (player2Name) player2Name.textContent = "Người chơi 2";
    if (player2Status) player2Status.textContent = "○ Đang chờ";
    if (player2Card) player2Card.classList.remove("active-player");
    const p2Img = document.getElementById("player2AvatarImg");
    if (p2Img) p2Img.src = contextPath + "/assets/avatars/default.svg";
    const p2Score = document.getElementById("player2Score");
    if (p2Score) p2Score.textContent = "";

    isGameStarted = false;
    gameOver = false;
    if (window.CaroAudio) {
        CaroAudio.stopBgm();
    }
    turnText.textContent = "Đang chờ đối thủ mới...";
    timerStatus.textContent = "Chờ đối thủ...";
    clearInterval(timer);
    createBoard();
}

// ==========================================
// 4. TẠO BÀN CỜ, TỌA ĐỘ VÀ ĐÁNH CỜ
// ==========================================

function setupCoordinates() {
    const isCoordsEnabled = localStorage.getItem('caro_coords') !== 'false';
    const wrapper = document.getElementById("boardWrapper");
    if (!wrapper) return;

    if (!isCoordsEnabled) {
        wrapper.classList.add("no-coords");
        return;
    }
    wrapper.classList.remove("no-coords");

    const topElem = document.getElementById("coordsTop");
    const bottomElem = document.getElementById("coordsBottom");
    const leftElem = document.getElementById("coordsLeft");
    const rightElem = document.getElementById("coordsRight");

    const COLS = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'];
    const ROWS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    if (topElem && topElem.children.length === 0) {
        COLS.forEach(c => {
            const span = document.createElement("span");
            span.className = "coord-label";
            span.textContent = c;
            topElem.appendChild(span);
        });
    }

    if (bottomElem && bottomElem.children.length === 0) {
        COLS.forEach(c => {
            const span = document.createElement("span");
            span.className = "coord-label";
            span.textContent = c;
            bottomElem.appendChild(span);
        });
    }

    if (leftElem && leftElem.children.length === 0) {
        ROWS.forEach(r => {
            const span = document.createElement("span");
            span.className = "coord-label";
            span.textContent = r;
            leftElem.appendChild(span);
        });
    }

    if (rightElem && rightElem.children.length === 0) {
        ROWS.forEach(r => {
            const span = document.createElement("span");
            span.className = "coord-label";
            span.textContent = r;
            rightElem.appendChild(span);
        });
    }
}

function createBoard() {
    board.innerHTML = "";
    document.querySelectorAll(".cell.last-move").forEach(c => c.classList.remove("last-move"));
    setupCoordinates();
    for (let row = 0; row < BOARD_SIZE; row++) {
        for (let col = 0; col < BOARD_SIZE; col++) {
            const cell = document.createElement("div");
            cell.classList.add("cell");
            cell.dataset.row = row;
            cell.dataset.col = col;

            cell.addEventListener("click", function () {
                makeMove(cell);
            });

            board.appendChild(cell);
        }
    }
}

function makeMove(cell) {
    if (!isGameStarted || gameOver) {
        return;
    }

    if (currentTurn !== mySymbol) {
        return; // Chưa tới lượt bạn
    }

    if (cell.textContent !== "") {
        return; // Ô đã đánh
    }

    const row = parseInt(cell.dataset.row);
    const col = parseInt(cell.dataset.col);

    document.querySelectorAll(".cell.last-move").forEach(c => c.classList.remove("last-move"));

    socket.send(JSON.stringify({
        action: "MOVE",
        roomCode: roomCode,
        row: row,
        col: col,
        symbol: mySymbol
    }));
}

// ==========================================
// 5. CẬP NHẬT GIAO DIỆN LƯỢT ĐI & TIMER
// ==========================================

function updateTurnUI() {
    if (!isGameStarted) return;

    const isMyTurn = (currentTurn === mySymbol);

    if (isMyTurn) {
        turnText.textContent = "LƯỢT CỦA BẠN (" + mySymbol + ")";
        timerStatus.textContent = "Đang đi...";
    } else {
        const opponentSymbol = (mySymbol === "X" ? "O" : "X");
        turnText.textContent = "LƯỢT ĐỐI THỦ (" + opponentSymbol + ")";
        timerStatus.textContent = "Đang chờ...";
    }

    const p1Symbol = (player1Symbol ? player1Symbol.textContent.trim() : "X");
    if (currentTurn === p1Symbol) {
        if (player1Card) player1Card.classList.add("active-player");
        if (player2Card) player2Card.classList.remove("active-player");
        if (player1Status) player1Status.textContent = "● Đang đánh";
        if (player2Status) player2Status.textContent = "○ Chờ lượt";
    } else {
        if (player2Card) player2Card.classList.add("active-player");
        if (player1Card) player1Card.classList.remove("active-player");
        if (player2Status) player2Status.textContent = "● Đang đánh";
        if (player1Status) player1Status.textContent = "○ Chờ lượt";
    }
}

function startTimer() {
    clearInterval(timer);
    timer = setInterval(function () {
        timeLeft--;
        if (timerElement) timerElement.textContent = timeLeft;

        const timerPanel = document.querySelector(".timer-panel");
        if (timerPanel) {
            if (timeLeft <= 20) timerPanel.classList.add("warning");
            if (timeLeft <= 10) timerPanel.classList.add("danger");
        }

        if (timeLeft <= 0) {
            clearInterval(timer);
            if (currentTurn === mySymbol && !gameOver) {
                socket.send(JSON.stringify({
                    action: "TIMEOUT",
                    roomCode: roomCode
                }));
            }
        }
    }, 1000);
}

function resetTimer() {
    timeLeft = 60;
    if (timerElement) timerElement.textContent = timeLeft;
    const timerPanel = document.querySelector(".timer-panel");
    if (timerPanel) {
        timerPanel.classList.remove("warning");
        timerPanel.classList.remove("danger");
    }
    startTimer();
}

// ==========================================
// 6. CHAT & EMOJI
// ==========================================

function sendChat() {
    const input = document.getElementById("chatInput");
    if (!input) return;
    const message = input.value.trim();
    if (message === "") return;

    socket.send(JSON.stringify({
        action: "CHAT",
        roomCode: roomCode,
        content: message
    }));

    input.value = "";
    input.focus();
}

function sendEmoji(emoji) {
    socket.send(JSON.stringify({
        action: "EMOJI",
        roomCode: roomCode,
        content: emoji
    }));
}

function handleIncomingChat(data) {
    const targetCard = (data.senderId === currentUserId) ? player1Card : player2Card;
    showBubble(targetCard, data.content, false);
}

function handleIncomingEmoji(data) {
    const targetCard = (data.senderId === currentUserId) ? player1Card : player2Card;
    showBubble(targetCard, data.content, true);
}

function showBubble(targetCard, content, isEmoji) {
    if (!targetCard) return;

    const oldBubble = targetCard.querySelector(".chat-bubble");
    if (oldBubble) oldBubble.remove();

    const bubble = document.createElement("div");
    bubble.className = "chat-bubble" + (isEmoji ? " emoji-bubble" : "");
    bubble.textContent = content;

    targetCard.appendChild(bubble);

    requestAnimationFrame(() => {
        bubble.classList.add("show");
    });

    setTimeout(() => {
        bubble.classList.remove("show");
        setTimeout(() => bubble.remove(), 300);
    }, isEmoji ? 2500 : 4000);
}

// ==========================================
// 7. THOÁT VÁN CỜ & SỰ KIỆN LOAD
// ==========================================

function leaveGame() {
    if (isGameStarted && !gameOver) {
        if (confirm("Bạn có chắc muốn đầu hàng và thoát khỏi ván cờ? Bạn sẽ bị xử thua (-15 điểm).")) {
            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send(JSON.stringify({
                    action: "SURRENDER",
                    roomCode: roomCode
                }));
                socket.send(JSON.stringify({
                    action: "LEAVE_ROOM",
                    roomCode: roomCode
                }));
            }
            window.location.href = contextPath + "/game";
        }
    } else {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({
                action: "LEAVE_ROOM",
                roomCode: roomCode
            }));
        }
        window.location.href = contextPath + "/game";
    }
}

document.addEventListener("DOMContentLoaded", function () {
    const button = document.getElementById("sendChatButton");
    const input = document.getElementById("chatInput");

    if (button) {
        button.addEventListener("click", sendChat);
    }
    if (input) {
        input.addEventListener("keydown", function (e) {
            if (e.key === "Enter") {
                e.preventDefault();
                sendChat();
            }
        });
    }

    createBoard();
});