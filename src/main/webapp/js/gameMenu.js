function goBack() {
    window.location.href = "home";
}

function createRoom() {
    window.location.href = "create-room";
}

function joinRoom() {
    window.location.href = "join-room";
}

function findMatch() {
    window.location.href = "find-match";
}

function challengePlayer() {
    window.location.href = "challenge";
}

// ==========================================
// LẮNG NGHE LỜI MỜI THÁCH ĐẤU REAL-TIME
// ==========================================
let currentChallengeId = null;
let challengeTimerInterval = null;
let menuWs = null;

if (typeof currentUserId !== "undefined" && currentUserId > 0) {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const wsUrl = protocol + "//" + window.location.host + contextPath + "/ws/game/" + currentUserId;

    menuWs = new WebSocket(wsUrl);

    menuWs.onopen = function () {
        console.log("[Menu WS] Connected for challenge notifications.");
    };

    menuWs.onmessage = function (event) {
        try {
            const data = JSON.parse(event.data);
            if (data.action === "CHALLENGE_INVITATION") {
                showIncomingChallenge(data);
            } else if (data.action === "CHALLENGE_CANCELLED") {
                hideIncomingChallenge();
                alert("Đối thủ đã hủy lời mời thách đấu.");
            } else if (data.action === "CHALLENGE_START") {
                clearInterval(challengeTimerInterval);
                const desc = document.getElementById("challengeModalDesc");
                if (desc) desc.textContent = "Đang chuyển vào bàn cờ thi đấu...";
                setTimeout(function () {
                    window.location.href = contextPath + "/game-play?roomCode=" + data.roomCode;
                }, 500);
            }
        } catch (e) {
            console.error("Lỗi parse WS message trong gameMenu:", e);
        }
    };

    menuWs.onclose = function () {
        console.log("[Menu WS] Disconnected.");
    };
}

function showIncomingChallenge(data) {
    currentChallengeId = data.challengeId;
    const modal = document.getElementById("incomingChallengeModal");
    const desc = document.getElementById("challengeModalDesc");
    const timerElem = document.getElementById("challengeModalTimer");

    if (desc) {
        desc.textContent = data.message || "Bạn nhận được một lời mời thách đấu!";
    }

    if (modal) {
        modal.style.display = "flex";
    }

    let remainingSeconds = 30;
    if (timerElem) timerElem.textContent = "⏳ Hết hạn sau: " + remainingSeconds + "s";

    clearInterval(challengeTimerInterval);
    challengeTimerInterval = setInterval(function () {
        remainingSeconds--;
        if (timerElem) timerElem.textContent = "⏳ Hết hạn sau: " + remainingSeconds + "s";
        if (remainingSeconds <= 0) {
            clearInterval(challengeTimerInterval);
            respondChallenge(false);
        }
    }, 1000);
}

function hideIncomingChallenge() {
    clearInterval(challengeTimerInterval);
    currentChallengeId = null;
    const modal = document.getElementById("incomingChallengeModal");
    if (modal) {
        modal.style.display = "none";
    }
}

function respondChallenge(accepted) {
    if (!currentChallengeId || !menuWs || menuWs.readyState !== WebSocket.OPEN) {
        hideIncomingChallenge();
        return;
    }

    menuWs.send(JSON.stringify({
        action: "CHALLENGE_RESPONSE",
        challengeId: currentChallengeId,
        accepted: accepted
    }));

    if (!accepted) {
        hideIncomingChallenge();
    } else {
        const desc = document.getElementById("challengeModalDesc");
        if (desc) desc.textContent = "Đã chấp nhận! Đang thiết lập bàn cờ...";
    }
}
