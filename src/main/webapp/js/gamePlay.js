const BOARD_SIZE = 15;

let currentPlayer = "X";
let timeLeft = 60;
let timer = null;
let gameOver = false;

const board = document.getElementById("board");
const timerElement = document.getElementById("timer");
const turnText = document.getElementById("turnText");
const timerStatus = document.getElementById("timerStatus");


// =========================
// CREATE BOARD
// =========================

function createBoard() {

    board.innerHTML = "";

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


// =========================
// MAKE MOVE
// =========================

function makeMove(cell) {

    if (gameOver) {
        return;
    }

    if (cell.textContent !== "") {
        return;
    }

    cell.textContent = currentPlayer;

    cell.classList.add(
        currentPlayer === "X" ? "x" : "o"
    );


    // Check winner
    if (checkWin(cell)) {

        endGame(currentPlayer);

        return;
    }


    // Change player
    currentPlayer =
        currentPlayer === "X" ? "O" : "X";

    updateTurn();

    resetTimer();
}


// =========================
// CHECK WIN
// =========================

function checkWin(cell) {

    const row = parseInt(cell.dataset.row);
    const col = parseInt(cell.dataset.col);

    const directions = [
        [1, 0],
        [0, 1],
        [1, 1],
        [1, -1]
    ];

    for (const [dr, dc] of directions) {

        let count = 1;

        count += countDirection(row, col, dr, dc);
        count += countDirection(row, col, -dr, -dc);

        if (count >= 5) {
            return true;
        }
    }

    return false;
}


function countDirection(row, col, dr, dc) {

    let count = 0;

    let r = row + dr;
    let c = col + dc;

    while (
        r >= 0 &&
        r < BOARD_SIZE &&
        c >= 0 &&
        c < BOARD_SIZE
    ) {

        const cell = document.querySelector(
            `.cell[data-row="${r}"][data-col="${c}"]`
        );

        if (!cell || cell.textContent !== currentPlayer) {
            break;
        }

        count++;

        r += dr;
        c += dc;
    }

    return count;
}


// =========================
// GAME OVER
// =========================

function endGame(winner) {

    gameOver = true;

    clearInterval(timer);

    if (winner === "X") {

        turnText.textContent = "You Win!";
        timerStatus.textContent = "Victory!";

    } else {

        turnText.textContent = "You Lose!";
        timerStatus.textContent = "Defeat!";
    }

    setTimeout(function () {

        window.location.href =
            "/Caro_game/result?winner=" + winner;

    }, 1000);
}


// =========================
// TURN
// =========================

function updateTurn() {

    if (currentPlayer === "X") {

        turnText.textContent = "Your Turn";
        timerStatus.textContent = "Your turn";

    } else {

        turnText.textContent = "Opponent's Turn";
        timerStatus.textContent = "Opponent's turn";
    }
}


// =========================
// TIMER
// =========================

function startTimer() {

    clearInterval(timer);

    timer = setInterval(function () {

        timeLeft--;

        timerElement.textContent = timeLeft;


        const timerPanel =
            document.querySelector(".timer-panel");


        if (timeLeft <= 20) {
            timerPanel.classList.add("warning");
        }

        if (timeLeft <= 10) {
            timerPanel.classList.add("danger");
        }


        if (timeLeft <= 0) {

            clearInterval(timer);

            timerStatus.textContent = "Time's up!";

            // Demo: đổi lượt
            currentPlayer =
                currentPlayer === "X" ? "O" : "X";

            updateTurn();

            resetTimer();
        }

    }, 1000);
}


function resetTimer() {

    timeLeft = 60;

    timerElement.textContent = timeLeft;

    const timerPanel =
        document.querySelector(".timer-panel");

    timerPanel.classList.remove("warning");
    timerPanel.classList.remove("danger");

    startTimer();
}


// =========================
// CHAT
// =========================

function sendChat() {

    const input = document.getElementById("chatInput");

    if (!input) {
        console.log("Không tìm thấy chatInput!");
        return;
    }

    const message = input.value.trim();

    if (message === "") {
        return;
    }

    console.log("Sending:", message);

    const playerCard =
        document.querySelector(".active-player");

    if (!playerCard) {
        console.log("Không tìm thấy active-player!");
        return;
    }

    // Xóa bubble cũ
    const oldBubble =
        playerCard.querySelector(".chat-bubble");

    if (oldBubble) {
        oldBubble.remove();
    }

    // Tạo bubble
    const bubble =
        document.createElement("div");

    bubble.className = "chat-bubble";
    bubble.textContent = message;

    playerCard.appendChild(bubble);

    // Hiện bubble
    requestAnimationFrame(() => {
        bubble.classList.add("show");
    });

    // Xóa sau 4 giây
    setTimeout(() => {

        bubble.classList.remove("show");

        setTimeout(() => {
            bubble.remove();
        }, 300);

    }, 4000);

    // Xóa input
    input.value = "";
    input.focus();
}


// Enter để gửi
function handleChatKey(event) {

    if (event.key === "Enter") {
        event.preventDefault();
        sendChat();
    }
}


// Gắn sự kiện sau khi trang load
document.addEventListener("DOMContentLoaded", function () {

    const button =
        document.getElementById("sendChatButton");

    const input =
        document.getElementById("chatInput");


    if (button) {
        button.addEventListener("click", sendChat);
    }


    if (input) {
        input.addEventListener("keydown", handleChatKey);
    }

});


// =========================
// CHAT BUBBLE
// =========================

function showChatBubble(message) {

    const playerCard =
        document.querySelector(".active-player");

    if (!playerCard) {
        return;
    }


    // Xóa bubble cũ
    const oldBubble =
        playerCard.querySelector(".chat-bubble");

    if (oldBubble) {
        oldBubble.remove();
    }


    // Tạo bubble
    const bubble =
        document.createElement("div");

    bubble.classList.add("chat-bubble");

    bubble.textContent = message;


    // Gắn vào Player 1
    playerCard.appendChild(bubble);


    // Hiện
    setTimeout(function () {
        bubble.classList.add("show");
    }, 10);


    // Tự biến mất sau 4 giây
    setTimeout(function () {

        bubble.classList.remove("show");

        setTimeout(function () {

            if (bubble.parentElement) {
                bubble.remove();
            }

        }, 300);

    }, 4000);
}


// =========================
// EMOJI
// =========================

function sendEmoji(emoji) {

    const playerCard =
        document.querySelector(".active-player");

    if (!playerCard) {
        return;
    }


    const oldBubble =
        playerCard.querySelector(".chat-bubble");

    if (oldBubble) {
        oldBubble.remove();
    }


    const bubble =
        document.createElement("div");

    bubble.classList.add(
        "chat-bubble",
        "emoji-bubble"
    );

    bubble.textContent = emoji;

    playerCard.appendChild(bubble);


    setTimeout(function () {
        bubble.classList.add("show");
    }, 10);


    setTimeout(function () {

        bubble.classList.remove("show");

        setTimeout(function () {

            if (bubble.parentElement) {
                bubble.remove();
            }

        }, 300);

    }, 2500);
}


// =========================
// LEAVE GAME
// =========================

function leaveGame() {

    if (confirm("Leave this game?")) {

        window.location.href =
            "/Caro_game/game";
    }
}


// =========================
// START
// =========================

createBoard();

updateTurn();

startTimer();