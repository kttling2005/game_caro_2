let secondsLeft = 30;
let timerInterval = null;
let waitSocket = null;
let currentChallengeId = null;

const timerElem = document.getElementById("waitTimer");
const statusElem = document.getElementById("waitStatus");
const btnCancel = document.getElementById("btnCancel");

// Khởi tạo WebSocket kết nối vào server
const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const wsUrl = protocol + "//" + window.location.host + contextPath + "/ws/game/" + currentUserId;

waitSocket = new WebSocket(wsUrl);

waitSocket.onopen = function () {
    console.log("[ChallengeWait] WebSocket connected. Sending CHALLENGE_REQUEST...");
    
    // Gửi yêu cầu thách đấu ngay khi vừa kết nối
    waitSocket.send(JSON.stringify({
        action: "CHALLENGE_REQUEST",
        targetUserId: targetUserId
    }));
};

waitSocket.onmessage = function (event) {
    try {
        const data = JSON.parse(event.data);
        console.log("[ChallengeWait] WS received:", data);

        if (data.action === "CHALLENGE_SENT_SUCCESS") {
            currentChallengeId = data.challengeId;
            if (statusElem) {
                statusElem.textContent = "⏳ Đã gửi lời mời thành công! Đang chờ đối thủ phản hồi...";
            }
            startCountdown();

        } else if (data.action === "CHALLENGE_BUSY") {
            clearInterval(timerInterval);
            alert(data.message || "Đối thủ hiện đang bận hoặc không thể nhận lời mời!");
            window.location.href = contextPath + "/challenge";

        } else if (data.action === "CHALLENGE_DECLINED") {
            clearInterval(timerInterval);
            alert(data.message || "Đối thủ đã từ chối lời mời thách đấu.");
            window.location.href = contextPath + "/challenge";

        } else if (data.action === "CHALLENGE_CANCELLED") {
            clearInterval(timerInterval);
            alert(data.message || "Lời mời thách đấu đã kết thúc.");
            window.location.href = contextPath + "/challenge";

        } else if (data.action === "CHALLENGE_START") {
            clearInterval(timerInterval);
            if (statusElem) {
                statusElem.innerHTML = "🎉 <strong>Đối thủ đã chấp nhận!</strong> Đang chuyển vào bàn cờ...";
                statusElem.style.color = "#00e878";
            }
            if (btnCancel) {
                btnCancel.style.display = "none";
            }

            setTimeout(function () {
                window.location.href = contextPath + "/game-play?roomCode=" + data.roomCode;
            }, 800);
        }
    } catch (e) {
        console.error("Lỗi parse WS trong challengeWait:", e);
    }
};

waitSocket.onerror = function (err) {
    console.error("[ChallengeWait] WS Error:", err);
};

waitSocket.onclose = function () {
    console.log("[ChallengeWait] WS Closed.");
};

function startCountdown() {
    clearInterval(timerInterval);
    updateTimerDisplay();

    timerInterval = setInterval(function () {
        secondsLeft--;
        updateTimerDisplay();

        if (secondsLeft <= 0) {
            clearInterval(timerInterval);
            if (statusElem) statusElem.textContent = "⌛ Hết thời gian chờ phản hồi!";
            cancelChallenge(true);
        }
    }, 1000);
}

function updateTimerDisplay() {
    if (timerElem) {
        const secs = String(Math.max(0, secondsLeft)).padStart(2, "0");
        timerElem.textContent = "00:" + secs;
    }
}

function cancelChallenge(isTimeout) {
    clearInterval(timerInterval);

    if (currentChallengeId && waitSocket && waitSocket.readyState === WebSocket.OPEN) {
        waitSocket.send(JSON.stringify({
            action: "CHALLENGE_CANCEL",
            challengeId: currentChallengeId
        }));
    }

    if (isTimeout) {
        alert("Đối thủ không phản hồi kịp thời. Đang quay lại sảnh thách đấu.");
    }

    window.location.href = contextPath + "/challenge";
}
