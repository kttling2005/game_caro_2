package engine;

import com.google.gson.Gson;
import jakarta.websocket.Session;
import model.GameMessage;
import model.Room;
import model.User;

import java.io.IOException;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class RoomManager {

    private static final RoomManager INSTANCE = new RoomManager();
    private final Gson gson = new Gson();

    // Lưu các phòng đang hoạt động (key: roomCode)
    private final Map<String, Room> activeRooms = new ConcurrentHashMap<>();

    // Lưu WebSocket Session của từng User (key: userId)
    private final Map<Integer, Session> userSessions = new ConcurrentHashMap<>();

    // Lưu vết User đang ở phòng nào (key: userId, value: roomCode)
    private final Map<Integer, String> userInRoom = new ConcurrentHashMap<>();

    // Hàng đợi tìm trận ngẫu nhiên (Matchmaking Queue)
    private final Queue<Integer> matchmakingQueue = new ConcurrentLinkedQueue<>();

    // Lưu các yêu cầu thách đấu đang chờ phản hồi (key: challengeId)
    private final Map<String, ChallengeRequest> activeChallenges = new ConcurrentHashMap<>();
    private final Map<Integer, String> userActiveChallenge = new ConcurrentHashMap<>(); // userId -> challengeId

    public static class ChallengeRequest {
        private final String challengeId;
        private final int challengerId;
        private final String challengerName;
        private final int challengerScore;
        private final String challengerAvatar;
        private final int targetId;
        private final String targetName;
        private final long createdAt;

        public ChallengeRequest(String challengeId, int challengerId, String challengerName, int challengerScore, String challengerAvatar, int targetId, String targetName) {
            this.challengeId = challengeId;
            this.challengerId = challengerId;
            this.challengerName = challengerName;
            this.challengerScore = challengerScore;
            this.challengerAvatar = challengerAvatar;
            this.targetId = targetId;
            this.targetName = targetName;
            this.createdAt = System.currentTimeMillis();
        }

        public String getChallengeId() { return challengeId; }
        public int getChallengerId() { return challengerId; }
        public String getChallengerName() { return challengerName; }
        public int getChallengerScore() { return challengerScore; }
        public String getChallengerAvatar() { return challengerAvatar; }
        public int getTargetId() { return targetId; }
        public String getTargetName() { return targetName; }
        public long getCreatedAt() { return createdAt; }
        public boolean isExpired() { return (System.currentTimeMillis() - createdAt) > 35000; }
    }

    public void addChallenge(ChallengeRequest chal) {
        if (chal != null) {
            activeChallenges.put(chal.getChallengeId(), chal);
            userActiveChallenge.put(chal.getChallengerId(), chal.getChallengeId());
            userActiveChallenge.put(chal.getTargetId(), chal.getChallengeId());
        }
    }

    public ChallengeRequest getChallenge(String challengeId) {
        if (challengeId == null) return null;
        ChallengeRequest req = activeChallenges.get(challengeId);
        if (req != null && req.isExpired()) {
            removeChallenge(challengeId);
            return null;
        }
        return req;
    }

    public ChallengeRequest removeChallenge(String challengeId) {
        if (challengeId == null) return null;
        ChallengeRequest req = activeChallenges.remove(challengeId);
        if (req != null) {
            userActiveChallenge.remove(req.getChallengerId());
            userActiveChallenge.remove(req.getTargetId());
        }
        return req;
    }

    public ChallengeRequest getChallengeForUser(int userId) {
        String chalId = userActiveChallenge.get(userId);
        if (chalId == null) return null;
        return getChallenge(chalId);
    }

    private RoomManager() {
    }

    public static RoomManager getInstance() {
        return INSTANCE;
    }

    public void addRoom(Room room) {
        if (room != null && room.getRoomCode() != null) {
            activeRooms.put(room.getRoomCode(), room);
        }
    }

    public Room getRoom(String roomCode) {
        if (roomCode == null) return null;
        return activeRooms.get(roomCode);
    }

    public void removeRoom(String roomCode) {
        if (roomCode != null) {
            Room r = activeRooms.remove(roomCode);
            if (r != null) {
                userInRoom.remove(r.getHostId());
                if (r.getGuestId() != null) {
                    userInRoom.remove(r.getGuestId());
                }
            }
        }
    }

    public void registerSession(int userId, Session session) {
        userSessions.put(userId, session);
    }

    public boolean removeSession(int userId, Session closingSession) {
        if (closingSession == null) return false;
        Session current = userSessions.get(userId);
        if (current != null && current.getId().equals(closingSession.getId())) {
            userSessions.remove(userId);
            matchmakingQueue.remove(userId);
            return true;
        }
        return false;
    }

    public void removeSession(int userId) {
        userSessions.remove(userId);
        matchmakingQueue.remove(userId);
    }

    public Session getSession(int userId) {
        return userSessions.get(userId);
    }

    public int getOnlineCount() {
        return userSessions.size();
    }

    public void setUserRoom(int userId, String roomCode) {
        userInRoom.put(userId, roomCode);
    }

    public String getUserRoom(int userId) {
        return userInRoom.get(userId);
    }

    public void removeUserRoom(int userId) {
        userInRoom.remove(userId);
    }

    public Queue<Integer> getMatchmakingQueue() {
        return matchmakingQueue;
    }

    /**
     * Gửi bản tin tới 1 người dùng cụ thể
     */
    public void sendToUser(int userId, GameMessage message) {
        Session session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                String json = gson.toJson(message);
                synchronized (session) {
                    session.getBasicRemote().sendText(json);
                }
            } catch (IOException e) {
                System.err.println("Lỗi gửi tin tới user " + userId + ": " + e.getMessage());
            }
        }
    }

    /**
     * Gửi bản tin tới cả 2 người chơi trong 1 phòng
     */
    public void broadcastToRoom(String roomCode, GameMessage message) {
        Room room = activeRooms.get(roomCode);
        if (room == null) return;

        sendToUser(room.getHostId(), message);
        if (room.getGuestId() != null) {
            sendToUser(room.getGuestId(), message);
        }
    }

    /**
     * Gửi bản tin tới tất cả người chơi đang kết nối WebSocket
     */
    public void broadcastAll(GameMessage message) {
        String json = gson.toJson(message);
        for (Session session : userSessions.values()) {
            if (session != null && session.isOpen()) {
                try {
                    synchronized (session) {
                        session.getBasicRemote().sendText(json);
                    }
                } catch (IOException e) {
                    // ignore
                }
            }
        }
    }
}
