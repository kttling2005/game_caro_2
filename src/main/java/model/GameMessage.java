package model;

public class GameMessage {
    private String[][] board;
    private int movesCount;
    private long elapsedMillis;
    private long remainingMillis;
    private boolean paused;
    private String roomStatus;
    public void setSnapshot(Room room) {
        board = new String[Room.BOARD_SIZE][];
        for (int i = 0; i < board.length; i++) board[i] = room.getBoard()[i].clone();
        movesCount = room.getMovesCount();
        elapsedMillis = Math.max(0, System.currentTimeMillis() - room.getMatchStartTime());
        remainingMillis = room.remainingTurnMillis();
        paused = room.isPaused();
        roomStatus = room.getStatus();
    }
    private String action;
    private String roomCode;
    private int senderId;
    private String senderName;
    private int row;
    private int col;
    private String symbol; // "X" or "O"
    private String nextTurn; // "X" or "O"
    private String content; // Chat message or emoji
    private String winner; // "X", "O", or "DRAW"
    private Integer winnerId;
    private int scoreChange;
    private int onlineCount;
    private String message;
    private boolean success;
    private boolean accepted;

    // Challenge related fields
    private int targetUserId;
    private String challengeId;
    private User challenger;
    private User target;

    // Additional info for START_GAME
    private User player1;
    private User player2;
    private String yourSymbol;

    public GameMessage() {
    }

    public GameMessage(String action) {
        this.action = action;
    }

    // Getters and Setters
    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getRoomCode() {
        return roomCode;
    }

    public void setRoomCode(String roomCode) {
        this.roomCode = roomCode;
    }

    public int getSenderId() {
        return senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public int getRow() {
        return row;
    }

    public void setRow(int row) {
        this.row = row;
    }

    public int getCol() {
        return col;
    }

    public void setCol(int col) {
        this.col = col;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getNextTurn() {
        return nextTurn;
    }

    public void setNextTurn(String nextTurn) {
        this.nextTurn = nextTurn;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getWinner() {
        return winner;
    }

    public void setWinner(String winner) {
        this.winner = winner;
    }

    public Integer getWinnerId() {
        return winnerId;
    }

    public void setWinnerId(Integer winnerId) {
        this.winnerId = winnerId;
    }

    public int getScoreChange() {
        return scoreChange;
    }

    public void setScoreChange(int scoreChange) {
        this.scoreChange = scoreChange;
    }

    public int getOnlineCount() {
        return onlineCount;
    }

    public void setOnlineCount(int onlineCount) {
        this.onlineCount = onlineCount;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public User getPlayer1() {
        return player1;
    }

    public void setPlayer1(User player1) {
        this.player1 = player1;
    }

    public User getPlayer2() {
        return player2;
    }

    public void setPlayer2(User player2) {
        this.player2 = player2;
    }

    public String getYourSymbol() {
        return yourSymbol;
    }

    public void setYourSymbol(String yourSymbol) {
        this.yourSymbol = yourSymbol;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }

    public int getTargetUserId() {
        return targetUserId;
    }

    public void setTargetUserId(int targetUserId) {
        this.targetUserId = targetUserId;
    }

    public String getChallengeId() {
        return challengeId;
    }

    public void setChallengeId(String challengeId) {
        this.challengeId = challengeId;
    }

    public User getChallenger() {
        return challenger;
    }

    public void setChallenger(User challenger) {
        this.challenger = challenger;
    }

    public User getTarget() {
        return target;
    }

    public void setTarget(User target) {
        this.target = target;
    }
}
