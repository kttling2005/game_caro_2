function goBack() {
    window.location.href = contextPath + "/game";
}

function filterPlayersClientSide() {
    const input = document.getElementById("searchInput");
    if (!input) return;
    const q = input.value.trim().toLowerCase();
    const cards = document.querySelectorAll(".player-card");

    cards.forEach(card => {
        const nick = card.getAttribute("data-nickname") || "";
        const user = card.getAttribute("data-username") || "";
        if (nick.includes(q) || user.includes(q)) {
            card.style.display = "flex";
        } else {
            card.style.display = "none";
        }
    });
}

function sendChallenge(targetUserId, targetName) {
    if (!targetUserId) return;
    window.location.href = contextPath + "/challenge-wait?targetId=" + targetUserId;
}

// ==========================================
// REAL-TIME WEBSOCKET LISTENER FOR LOBBY
// ==========================================
let lobbyWs = null;
let currentChallengeId = null;
let challengeTimerInterval = null;

if (typeof currentUserId !== "undefined" && currentUserId > 0) {
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const wsUrl = protocol + "//" + window.location.host + contextPath + "/ws/game/" + currentUserId;

    lobbyWs = new WebSocket(wsUrl);

    lobbyWs.onopen = function () {
        console.log("[Lobby WS] Connected for challenge events.");
    };

    lobbyWs.onmessage = function (event) {
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
                if (desc) desc.textContent = "Thách đấu được chấp nhận! Đang vào bàn cờ...";
                setTimeout(function () {
                    window.location.href = contextPath + "/game-play?roomCode=" + data.roomCode;
                }, 500);
            }
        } catch (e) {
            console.error("Lỗi parse WS trong challenge:", e);
        }
    };

    lobbyWs.onclose = function () {
        console.log("[Lobby WS] Disconnected.");
    };
}

function showIncomingChallenge(data) {
    currentChallengeId = data.challengeId;
    const modal = document.getElementById("incomingChallengeModal");
    const desc = document.getElementById("challengeModalDesc");
    const timerElem = document.getElementById("challengeModalTimer");

    if (desc) {
        desc.textContent = data.message || "Bạn nhận được một lời mời thách đấu cờ caro!";
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
    if (!currentChallengeId || !lobbyWs || lobbyWs.readyState !== WebSocket.OPEN) {
        hideIncomingChallenge();
        return;
    }

    lobbyWs.send(JSON.stringify({
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
