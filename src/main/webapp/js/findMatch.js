let secondsElapsed = 0;
let searchTimerInterval = null;

const timerElem = document.getElementById("searchTimer");
const statusElem = document.getElementById("searchStatus");
const descElem = document.getElementById("searchDesc");

// Khởi tạo WebSocket kết nối vào server
const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const wsUrl = protocol + "//" + window.location.host + contextPath + "/ws/game/" + currentUserId;
const socket = new WebSocket(wsUrl);

socket.onopen = function () {
    console.log("WebSocket connected for Matchmaking.");
    // Gửi yêu cầu tìm trận
    socket.send(JSON.stringify({
        action: "FIND_MATCH"
    }));

    // Bắt đầu đếm thời gian
    startTimer();
};

socket.onmessage = function (event) {
    try {
        const data = JSON.parse(event.data);
        if (data.action === "MATCH_FOUND") {
            clearInterval(searchTimerInterval);
            if (statusElem) statusElem.textContent = "ĐÃ TÌM THẤY ĐỐI THỦ!";
            if (descElem) descElem.textContent = "Đang chuyển vào bàn cờ...";

            setTimeout(function () {
                window.location.href = contextPath + "/game-play?roomCode=" + data.roomCode;
            }, 1000);
        }
    } catch (e) {
        console.error("Lỗi parse WS match message:", e);
    }
};

function startTimer() {
    clearInterval(searchTimerInterval);
    searchTimerInterval = setInterval(function () {
        secondsElapsed++;
        const mins = String(Math.floor(secondsElapsed / 60)).padStart(2, "0");
        const secs = String(secondsElapsed % 60).padStart(2, "0");
        if (timerElem) {
            timerElem.textContent = mins + ":" + secs;
        }
    }, 1000);
}

function cancelSearch() {
    clearInterval(searchTimerInterval);
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
            action: "CANCEL_FIND_MATCH"
        }));
    }
    window.location.href = contextPath + "/game";
}

function goBack() {
    cancelSearch();
}