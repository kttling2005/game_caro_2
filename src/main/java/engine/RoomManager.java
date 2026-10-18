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
