package model;

import java.sql.Timestamp;

public class Room {
    public static final int BOARD_SIZE = 15;

    private int id;
    private String roomCode;
    private String roomName;
    private int hostId;
    private Integer guestId;
    private String password;
    private String status; // WAITING, PLAYING, CLOSED
    private String roomType; // CUSTOM, RANKED
    private Timestamp createdAt;

    // Transient game state
    private User hostUser;
    private User guestUser;
    private String[][] board;
    private String currentTurn; // "X" or "O"
    private int hostSymbolPlayerId; // Player who plays "X"
    private boolean hostPlaysX = true;
    private boolean hostReadyRematch = false;
    private boolean guestReadyRematch = false;
    private int movesCount;
    private long matchStartTime;

    public Room() {
        this.status = "WAITING";
        this.roomType = "CUSTOM";
        this.board = new String[BOARD_SIZE][BOARD_SIZE];
        this.currentTurn = "X";
        this.movesCount = 0;
    }

    public void resetBoard() {
        this.board = new String[BOARD_SIZE][BOARD_SIZE];
        this.currentTurn = "X";
        this.movesCount = 0;
        this.hostReadyRematch = false;
        this.guestReadyRematch = false;
        this.matchStartTime = System.currentTimeMillis();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomCode() {
        return roomCode;
    }

    public void setRoomCode(String roomCode) {
        this.roomCode = roomCode;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public int getHostId() {
        return hostId;
    }

    public void setHostId(int hostId) {
        this.hostId = hostId;
    }

    public Integer getGuestId() {
        return guestId;
    }

    public void setGuestId(Integer guestId) {
        this.guestId = guestId;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public User getHostUser() {
        return hostUser;
    }

    public void setHostUser(User hostUser) {
        this.hostUser = hostUser;
    }

    public User getGuestUser() {
        return guestUser;
    }

    public void setGuestUser(User guestUser) {
        this.guestUser = guestUser;
    }

    public String[][] getBoard() {
        return board;
    }

    public void setBoard(String[][] board) {
        this.board = board;
    }

    public String getCurrentTurn() {
        return currentTurn;
    }

    public void setCurrentTurn(String currentTurn) {
        this.currentTurn = currentTurn;
    }

    public int getHostSymbolPlayerId() {
        return hostSymbolPlayerId;
    }

    public void setHostSymbolPlayerId(int hostSymbolPlayerId) {
        this.hostSymbolPlayerId = hostSymbolPlayerId;
    }

    public int getMovesCount() {
        return movesCount;
    }

    public void setMovesCount(int movesCount) {
        this.movesCount = movesCount;
    }

    public long getMatchStartTime() {
        return matchStartTime;
    }

    public void setMatchStartTime(long matchStartTime) {
        this.matchStartTime = matchStartTime;
    }

    public boolean isHostPlaysX() {
        return hostPlaysX;
    }

    public void setHostPlaysX(boolean hostPlaysX) {
        this.hostPlaysX = hostPlaysX;
    }

    public boolean isHostReadyRematch() {
        return hostReadyRematch;
    }

    public void setHostReadyRematch(boolean hostReadyRematch) {
        this.hostReadyRematch = hostReadyRematch;
    }

    public boolean isGuestReadyRematch() {
        return guestReadyRematch;
    }

    public void setGuestReadyRematch(boolean guestReadyRematch) {
        this.guestReadyRematch = guestReadyRematch;
    }
}
