package model;

import java.sql.Timestamp;

public class MatchHistory {
    private int id;
    private Integer roomId;
    private int player1Id;
    private int player2Id;
    private Integer winnerId;
    private int totalMoves;
    private int durationSeconds;
    private Timestamp playedAt;

    private User player1;
    private User player2;
    private User winner;

    public MatchHistory() {
    }

    public MatchHistory(Integer roomId, int player1Id, int player2Id, Integer winnerId, int totalMoves, int durationSeconds) {
        this.roomId = roomId;
        this.player1Id = player1Id;
        this.player2Id = player2Id;
        this.winnerId = winnerId;
        this.totalMoves = totalMoves;
        this.durationSeconds = durationSeconds;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public int getPlayer1Id() {
        return player1Id;
    }

    public void setPlayer1Id(int player1Id) {
        this.player1Id = player1Id;
    }

    public int getPlayer2Id() {
        return player2Id;
    }

    public void setPlayer2Id(int player2Id) {
        this.player2Id = player2Id;
    }

    public Integer getWinnerId() {
        return winnerId;
    }

    public void setWinnerId(Integer winnerId) {
        this.winnerId = winnerId;
    }

    public int getTotalMoves() {
        return totalMoves;
    }

    public void setTotalMoves(int totalMoves) {
        this.totalMoves = totalMoves;
    }

    public int getDurationSeconds() {
        return durationSeconds;
    }

    public void setDurationSeconds(int durationSeconds) {
        this.durationSeconds = durationSeconds;
    }

    public Timestamp getPlayedAt() {
        return playedAt;
    }

    public void setPlayedAt(Timestamp playedAt) {
        this.playedAt = playedAt;
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

    public User getWinner() {
        return winner;
    }

    public void setWinner(User winner) {
        this.winner = winner;
    }

    public String getFormattedDuration() {
        if (durationSeconds <= 0) return "00:01";
        int mins = durationSeconds / 60;
        int secs = durationSeconds % 60;
        return String.format("%02d:%02d", mins, secs);
    }

    public String getFormattedPlayedAt() {
        if (playedAt == null) return "N/A";
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
        return sdf.format(playedAt);
    }

    public String getTimeAgo() {
        if (playedAt == null) return "Vừa xong";
        long diffMs = System.currentTimeMillis() - playedAt.getTime();
        long diffSecs = diffMs / 1000;
        if (diffSecs < 60) return "Vừa xong";
        long diffMins = diffSecs / 60;
        if (diffMins < 60) return diffMins + " phút trước";
        long diffHours = diffMins / 60;
        if (diffHours < 24) return diffHours + " giờ trước";
        long diffDays = diffHours / 24;
        if (diffDays < 30) return diffDays + " ngày trước";
        return getFormattedPlayedAt();
    }

    public String getResultForUser(int currentUserId) {
        if (winnerId == null || winnerId == 0) {
            return "DRAW";
        }
        if (winnerId == currentUserId) {
            return "WIN";
        }
        return "LOSS";
    }

    public User getOpponent(int currentUserId) {
        if (player1Id == currentUserId) {
            return player2;
        }
        return player1;
    }

    public int getScoreChangeForUser(int currentUserId) {
        if (winnerId == null || winnerId == 0) {
            return 5;
        }
        if (winnerId == currentUserId) {
            return 25;
        }
        return -15;
    }
}
