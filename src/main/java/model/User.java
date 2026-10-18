package model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password;
    private String nickname;
    private String avatar;
    private int totalMatches;
    private int wins;
    private int draws;
    private int losses;
    private int score;
    private String status;
    private Timestamp createdAt;

    public User() {
        this.avatar = "default.png";
        this.score = 1000;
        this.status = "OFFLINE";
    }

    public User(int id, String username, String nickname, String avatar, int totalMatches, int wins, int draws, int losses, int score, String status) {
        this.id = id;
        this.username = username;
        this.nickname = nickname;
        this.avatar = avatar;
        this.totalMatches = totalMatches;
        this.wins = wins;
        this.draws = draws;
        this.losses = losses;
        this.score = score;
        this.status = status;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public int getTotalMatches() {
        return totalMatches;
    }

    public void setTotalMatches(int totalMatches) {
        this.totalMatches = totalMatches;
    }

    public int getWins() {
        return wins;
    }

    public void setWins(int wins) {
        this.wins = wins;
    }

    public int getDraws() {
        return draws;
    }

    public void setDraws(int draws) {
        this.draws = draws;
    }

    public int getLosses() {
        return losses;
    }

    public void setLosses(int losses) {
        this.losses = losses;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public double getWinRate() {
        if (totalMatches == 0) return 0.0;
        return Math.round(((double) wins / totalMatches * 100) * 10.0) / 10.0;
    }

    public String getAvatarUrl(String contextPath) {
        String ctx = (contextPath != null) ? contextPath : "";
        if (avatar == null || avatar.trim().isEmpty() || "default.png".equals(avatar) || "default.svg".equals(avatar)) {
            return ctx + "/assets/avatars/avatar1.svg";
        }
        if (avatar.startsWith("uploads/")) {
            return ctx + "/" + avatar;
        }
        if (avatar.startsWith("assets/")) {
            return ctx + "/" + avatar;
        }
        if (avatar.startsWith("avatar") && avatar.endsWith(".svg")) {
            return ctx + "/assets/avatars/" + avatar;
        }
        if (avatar.startsWith("http://") || avatar.startsWith("https://")) {
            return avatar;
        }
        return ctx + "/assets/avatars/" + avatar;
    }

    public String getRankTier() {
        if (score >= 1900) return "Cao Thủ";
        if (score >= 1700) return "Kim Cương";
        if (score >= 1500) return "Bạch Kim";
        if (score >= 1300) return "Vàng";
        if (score >= 1100) return "Bạc";
        return "Đồng";
    }

    public String getRankBadge() {
        if (score >= 1900) return "👑 Cao Thủ";
        if (score >= 1700) return "💎 Kim Cương";
        if (score >= 1500) return "🔮 Bạch Kim";
        if (score >= 1300) return "🥇 Vàng";
        if (score >= 1100) return "🥈 Bạc";
        return "🥉 Đồng";
    }

    public String getRankColor() {
        if (score >= 1900) return "#ff1744";
        if (score >= 1700) return "#00e5ff";
        if (score >= 1500) return "#b388ff";
        if (score >= 1300) return "#ffd700";
        if (score >= 1100) return "#cfd8dc";
        return "#cd7f32";
    }
}
