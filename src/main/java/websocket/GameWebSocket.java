package websocket;

import com.google.gson.Gson;
import dao.MatchHistoryDAO;
import dao.RoomDAO;
import dao.UserDAO;
import engine.CaroEngine;
import engine.RoomManager;
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import model.GameMessage;
import model.MatchHistory;
import model.Room;
import model.User;

import java.io.IOException;
import java.util.Queue;

@ServerEndpoint("/ws/game/{userId}")
public class GameWebSocket {

    private static final Gson gson = new Gson();
    private static final RoomManager roomManager = RoomManager.getInstance();
    private static final UserDAO userDAO = new UserDAO();
    private static final RoomDAO roomDAO = new RoomDAO();
    private static final MatchHistoryDAO matchHistoryDAO = new MatchHistoryDAO();

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") int userId) {
        roomManager.registerSession(userId, session);
        userDAO.updateStatus(userId, "ONLINE");

        // Broadcast số người online mới
        broadcastOnlineCount();
    }

    @OnMessage
    public void onMessage(String messageJson, Session session, @PathParam("userId") int userId) {
        try {
            GameMessage message = gson.fromJson(messageJson, GameMessage.class);
            if (message == null || message.getAction() == null) return;

            String action = message.getAction();

            switch (action) {
                case "JOIN_ROOM":
                    handleJoinRoom(userId, message);
                    break;
                case "MOVE":
                    handleMove(userId, message);
                    break;
                case "CHAT":
                    handleChat(userId, message);
                    break;
                case "EMOJI":
                    handleEmoji(userId, message);
                    break;
                case "SURRENDER":
                    handleSurrender(userId, message);
                    break;
                case "TIMEOUT":
                    handleTimeout(userId, message);
                    break;
                case "FIND_MATCH":
                    handleFindMatch(userId);
                    break;
                case "CANCEL_FIND_MATCH":
                    roomManager.getMatchmakingQueue().remove(userId);
                    break;
                case "REMATCH_REQUEST":
                    handleRematchRequest(userId, message);
                    break;
                case "REMATCH_RESPONSE":
                    handleRematchResponse(userId, message);
                    break;
                case "LEAVE_ROOM":
                    handleUserDeparture(userId, message.getRoomCode());
                    break;
                default:
                    System.out.println("Unknown action: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("userId") int userId) {
        // Chỉ xử lý đóng nếu session đang đóng đúng là session active của user
        // Tránh tình trạng session cũ từ trang tìm trận vừa đóng làm ảnh hưởng tới session mới ở trang chơi
        boolean isCurrent = roomManager.removeSession(userId, session);
        if (!isCurrent) {
            System.out.println("[WS] Ignored onClose for old/stale session of user " + userId);
            return;
        }

        userDAO.updateStatus(userId, "OFFLINE");

        String roomCode = roomManager.getUserRoom(userId);
        if (roomCode != null) {
            handleUserDeparture(userId, roomCode);
        }

        broadcastOnlineCount();
    }

    private void handleUserDeparture(int userId, String roomCode) {
        if (roomCode == null) return;
        Room room = roomManager.getRoom(roomCode);
        if (room == null) return;

        synchronized (room) {
            boolean isHost = (userId == room.getHostId());
            boolean isGuest = (room.getGuestId() != null && userId == room.getGuestId());
            boolean isRanked = "RANKED".equals(room.getRoomType()) || roomCode.startsWith("QUICK_");
            boolean wasPlaying = "PLAYING".equals(room.getStatus());

            if (isRanked) {
                // ĐỐI VỚI TRẬN GHÉP NGẪU NHIÊN (QUICK MATCH / RANKED):
                // 1 bên thoát -> Đóng phòng hoàn toàn! Không giữ phòng chờ đối thủ mới.
                if (wasPlaying) {
                    // Nếu đang chơi dở mà 1 bên thoát -> Xử thắng cho bên còn lại (+25 điểm), bên thoát (-15 điểm)
                    String winSymbol = isHost ? 
                            (room.isHostPlaysX() ? "O" : "X") : 
                            (room.isHostPlaysX() ? "X" : "O");
                    finishGame(room, winSymbol, isHost ? "HOST_LEFT" : "GUEST_LEFT", -1, -1);
                }

                room.setStatus("CLOSED");
                roomDAO.updateStatus(room.getId(), "CLOSED");
                roomManager.removeRoom(roomCode);

                int remainingUserId = isHost ? 
                        (room.getGuestId() != null ? room.getGuestId() : 0) : room.getHostId();

                if (remainingUserId > 0) {
                    GameMessage msg = new GameMessage("OPPONENT_LEFT");
                    if (wasPlaying) {
                        msg.setMessage("Đối thủ đã thoát trận giữa chừng! Bạn được xử thắng (+25 điểm). Trận đấu kết thúc.");
                    } else {
                        msg.setMessage("Đối thủ đã hủy trận và rời phòng. Trận đấu đã kết thúc!");
                    }
                    roomManager.sendToUser(remainingUserId, msg);
                    roomManager.removeUserRoom(remainingUserId);
                    userDAO.updateStatus(remainingUserId, "ONLINE");
                }

                roomManager.removeUserRoom(userId);
                userDAO.updateStatus(userId, "ONLINE");
                return;
            }

            // ĐỐI VỚI PHÒNG TỰ TẠO (CUSTOM ROOM):
            if (isHost) {
                // Host rời phòng -> Đóng phòng hoàn toàn
                if (wasPlaying && room.getGuestId() != null) {
                    String winSymbol = room.isHostPlaysX() ? "O" : "X";
                    finishGame(room, winSymbol, "HOST_LEFT", -1, -1);
                }

                room.setStatus("CLOSED");
                roomDAO.updateStatus(room.getId(), "CLOSED");
                roomManager.removeRoom(roomCode);
                userDAO.updateStatus(userId, "ONLINE");

                if (room.getGuestId() != null) {
                    userDAO.updateStatus(room.getGuestId(), "ONLINE");
                    GameMessage msg = new GameMessage("HOST_LEFT_ROOM");
                    if (wasPlaying) {
                        msg.setMessage("Chủ phòng đã thoát trận giữa chừng! Bạn được xử thắng (+25 điểm). Phòng đã đóng.");
                    } else {
                        msg.setMessage("Chủ phòng đã rời đi. Phòng đã đóng!");
                    }
                    roomManager.sendToUser(room.getGuestId(), msg);
                    roomManager.removeUserRoom(room.getGuestId());
                }
            } else if (isGuest) {
                // Guest rời phòng custom
                if (wasPlaying) {
                    String winSymbol = room.isHostPlaysX() ? "X" : "O";
                    finishGame(room, winSymbol, "GUEST_LEFT", -1, -1);
                }

                // Đưa phòng custom trở về WAITING để đón Guest mới vào chơi với Host!
                room.setGuestId(null);
                room.setGuestUser(null);
                room.setStatus("WAITING");
                room.setHostPlaysX(true);
                room.resetBoard();
                roomDAO.updateGuest(room.getId(), null, "WAITING");

                userDAO.updateStatus(userId, "ONLINE");
                userDAO.updateStatus(room.getHostId(), "IN_ROOM");

                // Báo cho Host biết để quay lại màn hình chờ đối thủ mới
                GameMessage waitMsg = new GameMessage("GUEST_LEFT_WAITING");
                waitMsg.setRoomCode(roomCode);
                waitMsg.setMessage("Đối thủ đã rời phòng. Đang chờ người chơi mới...");
                roomManager.sendToUser(room.getHostId(), waitMsg);

                roomManager.removeUserRoom(userId);
            }
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("WebSocket Error: " + throwable.getMessage());
    }

    // ==========================================
    // CÁC HÀM XỬ LÝ NGHIỆP VỤ BẢN TIN
    // ==========================================

    private void handleJoinRoom(int userId, GameMessage msg) {
        String roomCode = msg.getRoomCode();
        Room room = roomManager.getRoom(roomCode);

        if (room == null) {
            room = roomDAO.findByCode(roomCode);
            if (room != null) {
                roomManager.addRoom(room);
            }
        }

        if (room == null) {
            GameMessage error = new GameMessage("ERROR");
            error.setMessage("Phòng không tồn tại!");
            roomManager.sendToUser(userId, error);
            return;
        }

        roomManager.setUserRoom(userId, roomCode);
        User currentUser = userDAO.findById(userId);

        synchronized (room) {
            boolean isHost = (room.getHostId() == userId);
            boolean isAssignedGuest = (room.getGuestId() != null && room.getGuestId() == userId);
            boolean isNewGuest = (room.getGuestId() == null && !isHost);

            if (isHost) {
                room.setHostUser(currentUser);
            } else if (isAssignedGuest || isNewGuest) {
                room.setGuestId(userId);
                room.setGuestUser(currentUser);
            } else {
                // Đã có 2 người khác trong phòng
                GameMessage error = new GameMessage("ERROR");
                error.setMessage("Phòng đã đủ 2 người chơi!");
                roomManager.sendToUser(userId, error);
                return;
            }

            // Nạp thông tin User nếu bị thiếu
            if (room.getHostUser() == null) {
                room.setHostUser(userDAO.findById(room.getHostId()));
            }
            if (room.getGuestId() != null && room.getGuestUser() == null) {
                room.setGuestUser(userDAO.findById(room.getGuestId()));
            }

            // Kiểm tra xem cả 2 người chơi đã có mặt (kết nối WebSocket đang mở) hay chưa
            Session hostSession = roomManager.getSession(room.getHostId());
            boolean hostOnline = (hostSession != null && hostSession.isOpen());

            Session guestSession = (room.getGuestId() != null) ? roomManager.getSession(room.getGuestId()) : null;
            boolean guestOnline = (guestSession != null && guestSession.isOpen());

            // Nếu CẢ HAI NGƯỜI ĐÃ CÓ MẶT (Host và Guest đều đã kết nối WebSocket vào phòng)
            if (hostOnline && guestOnline) {
                // Nếu phòng chưa bắt đầu -> Chuyển sang PLAYING và reset bàn cờ
                if (!"PLAYING".equals(room.getStatus())) {
                    room.setStatus("PLAYING");
                    room.resetBoard();
                    roomDAO.updateGuest(room.getId(), room.getGuestId(), "PLAYING");
                }

                userDAO.updateStatus(room.getHostId(), "PLAYING");
                userDAO.updateStatus(room.getGuestId(), "PLAYING");

                String hostSymbol = room.isHostPlaysX() ? "X" : "O";
                String guestSymbol = room.isHostPlaysX() ? "O" : "X";
                String currentTurn = room.getCurrentTurn() != null ? room.getCurrentTurn() : "X";

                // Báo START_GAME cho Host (luôn gửi lại để đảm bảo tắt modal chờ)
                GameMessage startHost = new GameMessage("START_GAME");
                startHost.setRoomCode(roomCode);
                startHost.setYourSymbol(hostSymbol);
                startHost.setNextTurn(currentTurn);
                startHost.setPlayer1(room.getHostUser());
                startHost.setPlayer2(room.getGuestUser());
                roomManager.sendToUser(room.getHostId(), startHost);

                // Báo START_GAME cho Guest (luôn gửi lại để đảm bảo tắt modal chờ)
                GameMessage startGuest = new GameMessage("START_GAME");
                startGuest.setRoomCode(roomCode);
                startGuest.setYourSymbol(guestSymbol);
                startGuest.setNextTurn(currentTurn);
                startGuest.setPlayer1(room.getHostUser());
                startGuest.setPlayer2(room.getGuestUser());
                roomManager.sendToUser(room.getGuestId(), startGuest);

                System.out.println("[GAME_START] Both players present in room " + roomCode 
                        + ". Host: " + room.getHostId() + " (" + hostSymbol 
                        + "), Guest: " + room.getGuestId() + " (" + guestSymbol + ")");
            } else {
                // Chỉ mới CÓ 1 NGƯỜI kết nối -> Người đó chờ đối thủ
                userDAO.updateStatus(userId, "IN_ROOM");
                GameMessage waitMsg = new GameMessage("WAITING_OPPONENT");
                waitMsg.setMessage("Đang chờ đối thủ tham gia...");
                roomManager.sendToUser(userId, waitMsg);

                System.out.println("[ROOM_WAIT] User " + userId + " waiting for opponent in room " + roomCode 
                        + " (hostOnline=" + hostOnline + ", guestOnline=" + guestOnline + ")");
            }
        }
    }

    private void handleMove(int userId, GameMessage msg) {
        String roomCode = msg.getRoomCode();
        Room room = roomManager.getRoom(roomCode);
        if (room == null || !"PLAYING".equals(room.getStatus())) return;

        int row = msg.getRow();
        int col = msg.getCol();
        String symbol = msg.getSymbol();

        // 1. Kiểm tra có đúng lượt người này không
        if (!room.getCurrentTurn().equals(symbol)) {
            return;
        }

        // Kiểm tra userId có đúng sở hữu symbol đó không
        boolean isHost = (userId == room.getHostId());
        String expectedSymbol = (isHost == room.isHostPlaysX()) ? "X" : "O";
        if (!expectedSymbol.equals(symbol)) {
            return;
        }

        // 2. Kiểm tra ô có hợp lệ không
        if (!CaroEngine.isValidMove(room.getBoard(), row, col)) {
            return;
        }

        // 3. Đánh cờ
        room.getBoard()[row][col] = symbol;
        room.setMovesCount(room.getMovesCount() + 1);

        // 4. Kiểm tra Thắng
        if (CaroEngine.checkWin(room.getBoard(), row, col, symbol)) {
            finishGame(room, symbol, "WIN_5", row, col);
            return;
        }

        // 5. Kiểm tra Hòa
        if (CaroEngine.isBoardFull(room.getBoard())) {
            finishGame(room, "DRAW", "BOARD_FULL", row, col);
            return;
        }

        // 6. Chưa kết thúc -> Đổi lượt
        String nextTurn = "X".equals(symbol) ? "O" : "X";
        room.setCurrentTurn(nextTurn);

        GameMessage moveUpdate = new GameMessage("MOVE_UPDATE");
        moveUpdate.setRow(row);
        moveUpdate.setCol(col);
        moveUpdate.setSymbol(symbol);
        moveUpdate.setNextTurn(nextTurn);
        roomManager.broadcastToRoom(roomCode, moveUpdate);
    }

    private void handleChat(int userId, GameMessage msg) {
        Room room = roomManager.getRoom(msg.getRoomCode());
        if (room == null) return;

        User user = userDAO.findById(userId);
        GameMessage chatMsg = new GameMessage("CHAT");
        chatMsg.setContent(msg.getContent());
        chatMsg.setSenderId(userId);
        chatMsg.setSenderName(user != null ? user.getNickname() : "Player");

        roomManager.broadcastToRoom(msg.getRoomCode(), chatMsg);
    }

    private void handleEmoji(int userId, GameMessage msg) {
        Room room = roomManager.getRoom(msg.getRoomCode());
        if (room == null) return;

        GameMessage emojiMsg = new GameMessage("EMOJI");
        emojiMsg.setContent(msg.getContent());
        emojiMsg.setSenderId(userId);

        roomManager.broadcastToRoom(msg.getRoomCode(), emojiMsg);
    }

    private void handleSurrender(int userId, GameMessage msg) {
        Room room = roomManager.getRoom(msg.getRoomCode());
        if (room == null || !"PLAYING".equals(room.getStatus())) return;

        boolean isHost = (userId == room.getHostId());
        String mySymbol = (isHost == room.isHostPlaysX()) ? "X" : "O";
        String winningSymbol = "X".equals(mySymbol) ? "O" : "X";
        finishGame(room, winningSymbol, "SURRENDER", -1, -1);
    }

    private void handleTimeout(int userId, GameMessage msg) {
        Room room = roomManager.getRoom(msg.getRoomCode());
        if (room == null || !"PLAYING".equals(room.getStatus())) return;

        boolean isHost = (userId == room.getHostId());
        String mySymbol = (isHost == room.isHostPlaysX()) ? "X" : "O";
        String winningSymbol = "X".equals(mySymbol) ? "O" : "X";
        finishGame(room, winningSymbol, "TIMEOUT", -1, -1);
    }

    private void handleFindMatch(int userId) {
        Queue<Integer> queue = roomManager.getMatchmakingQueue();
        if (!queue.contains(userId)) {
            queue.add(userId);
        }

        // Nếu có >= 2 người đang đợi, ghép trận ngay
        if (queue.size() >= 2) {
            Integer p1 = queue.poll();
            Integer p2 = queue.poll();

            if (p1 != null && p2 != null && !p1.equals(p2)) {
                String roomCode = "QUICK_" + (System.currentTimeMillis() % 1000000);
                Room room = new Room();
                room.setRoomCode(roomCode);
                room.setRoomName("Quick Match #" + roomCode);
                room.setHostId(p1);
                room.setGuestId(p2);
                room.setRoomType("RANKED");
                room.setStatus("WAITING");

                roomDAO.createRoom(room);
                roomManager.addRoom(room);

                // Báo tin tìm thấy trận cho 2 bên để tự động chuyển trang
                GameMessage found1 = new GameMessage("MATCH_FOUND");
                found1.setRoomCode(roomCode);
                roomManager.sendToUser(p1, found1);

                GameMessage found2 = new GameMessage("MATCH_FOUND");
                found2.setRoomCode(roomCode);
                roomManager.sendToUser(p2, found2);
            }
        }
    }

    private void handleRematchRequest(int userId, GameMessage msg) {
        String code = (msg.getRoomCode() != null) ? msg.getRoomCode().trim() : null;
        Room room = roomManager.getRoom(code);
        if (room == null) {
            System.err.println("[REMATCH_ERROR] Room is null for code: " + code);
            return;
        }

        synchronized (room) {
            boolean isHost = (userId == room.getHostId());
            if (isHost) {
                room.setHostReadyRematch(true);
            } else {
                room.setGuestReadyRematch(true);
            }

            System.out.println("[REMATCH] User " + userId + " (isHost=" + isHost + ") requested rematch in room " 
                    + code + ". Status: hostReady=" + room.isHostReadyRematch() 
                    + ", guestReady=" + room.isGuestReadyRematch());

            int opponentId = isHost ? 
                    (room.getGuestId() != null ? room.getGuestId() : 0) : room.getHostId();

            // Nếu cả 2 người chơi đều đã bấm Tái đấu -> Bắt đầu ván mới ngay lập tức!
            if (room.isHostReadyRematch() && room.isGuestReadyRematch()) {
                System.out.println("[REMATCH] Both players ready! Starting rematch for room " + code);
                startRematchGame(room);
            } else {
                // Nếu chỉ mới 1 người bấm -> Gửi thông báo/lời mời tới người còn lại
                if (opponentId > 0) {
                    User sender = userDAO.findById(userId);
                    GameMessage invite = new GameMessage("REMATCH_INVITATION");
                    invite.setRoomCode(code);
                    invite.setSenderId(userId);
                    invite.setSenderName(sender != null ? sender.getNickname() : "Đối thủ");
                    roomManager.sendToUser(opponentId, invite);
                }
            }
        }
    }

    private void handleRematchResponse(int userId, GameMessage msg) {
        String code = (msg.getRoomCode() != null) ? msg.getRoomCode().trim() : null;
        Room room = roomManager.getRoom(code);
        if (room == null) return;

        synchronized (room) {
            int opponentId = (userId == room.getHostId()) ? 
                    (room.getGuestId() != null ? room.getGuestId() : 0) : room.getHostId();

            if (!msg.isAccepted()) {
                room.setHostReadyRematch(false);
                room.setGuestReadyRematch(false);
                GameMessage decline = new GameMessage("REMATCH_DECLINED");
                decline.setMessage("Đối thủ đã từ chối yêu cầu tái đấu!");
                roomManager.sendToUser(opponentId, decline);
            } else {
                // Người nhận lời mời bấm chấp nhận -> Bắt đầu ván mới!
                System.out.println("[REMATCH] User " + userId + " accepted rematch invitation for room " + code);
                startRematchGame(room);
            }
        }
    }

    private void startRematchGame(Room room) {
        room.setHostReadyRematch(false);
        room.setGuestReadyRematch(false);

        // Đổi bên đi trước (Luân phiên quân cờ X/O)
        room.setHostPlaysX(!room.isHostPlaysX());
        room.setStatus("PLAYING");
        room.resetBoard();
        roomDAO.updateStatus(room.getId(), "PLAYING");

        int hostId = room.getHostId();
        int guestId = room.getGuestId() != null ? room.getGuestId() : 0;

        userDAO.updateStatus(hostId, "PLAYING");
        if (guestId > 0) userDAO.updateStatus(guestId, "PLAYING");

        String hostSymbol = room.isHostPlaysX() ? "X" : "O";
        String guestSymbol = room.isHostPlaysX() ? "O" : "X";

        // Đảm bảo không bị null thông tin người chơi
        User hostUser = room.getHostUser();
        if (hostUser == null) {
            hostUser = userDAO.findById(hostId);
            room.setHostUser(hostUser);
        }
        User guestUser = room.getGuestUser();
        if (guestUser == null && guestId > 0) {
            guestUser = userDAO.findById(guestId);
            room.setGuestUser(guestUser);
        }

        System.out.println("[REMATCH_START] Room " + room.getRoomCode() 
                + " -> Host (" + hostId + ") is " + hostSymbol 
                + ", Guest (" + guestId + ") is " + guestSymbol);

        // Bắt đầu ván mới cho Host
        GameMessage startHost = new GameMessage("REMATCH_START");
        startHost.setRoomCode(room.getRoomCode());
        startHost.setYourSymbol(hostSymbol);
        startHost.setNextTurn("X");
        startHost.setPlayer1(hostUser);
        startHost.setPlayer2(guestUser);
        roomManager.sendToUser(hostId, startHost);

        // Bắt đầu ván mới cho Guest
        if (guestId > 0) {
            GameMessage startGuest = new GameMessage("REMATCH_START");
            startGuest.setRoomCode(room.getRoomCode());
            startGuest.setYourSymbol(guestSymbol);
            startGuest.setNextTurn("X");
            startGuest.setPlayer1(hostUser);
            startGuest.setPlayer2(guestUser);
            roomManager.sendToUser(guestId, startGuest);
        }
    }

    private void finishGame(Room room, String winnerSymbol, String reason, int lastRow, int lastCol) {
        // Giữ phòng ở trạng thái WAITING_REMATCH để hỗ trợ chơi tiếp
        room.setStatus("WAITING_REMATCH");
        room.setHostReadyRematch(false);
        room.setGuestReadyRematch(false);
        roomDAO.updateStatus(room.getId(), "CLOSED");

        Integer winnerId = null;
        Integer loserId = null;

        int hostId = room.getHostId();
        int guestId = room.getGuestId() != null ? room.getGuestId() : 0;

        if ("X".equals(winnerSymbol)) {
            winnerId = room.isHostPlaysX() ? hostId : guestId;
            loserId = room.isHostPlaysX() ? guestId : hostId;
        } else if ("O".equals(winnerSymbol)) {
            winnerId = room.isHostPlaysX() ? guestId : hostId;
            loserId = room.isHostPlaysX() ? hostId : guestId;
        }

        int duration = (int) ((System.currentTimeMillis() - room.getMatchStartTime()) / 1000);
        if (duration <= 0) duration = 1;

        // Cập nhật CSDL
        if (winnerId != null && loserId != null) {
            userDAO.updateGameResult(winnerId, true, false, 25);
            userDAO.updateGameResult(loserId, false, false, -15);
        } else {
            // DRAW
            userDAO.updateGameResult(room.getHostId(), false, true, 5);
            if (room.getGuestId() != null) {
                userDAO.updateGameResult(room.getGuestId(), false, true, 5);
            }
        }

        userDAO.updateStatus(hostId, "IN_ROOM");
        if (guestId > 0) userDAO.updateStatus(guestId, "IN_ROOM");

        MatchHistory match = new MatchHistory(
            room.getId(),
            room.getHostId(),
            room.getGuestId() != null ? room.getGuestId() : 0,
            winnerId,
            room.getMovesCount(),
            duration
        );
        matchHistoryDAO.saveMatch(match);

        // Broadcast GAME_OVER
        GameMessage gameOverMsg = new GameMessage("GAME_OVER");
        gameOverMsg.setWinner(winnerSymbol);
        gameOverMsg.setWinnerId(winnerId);
        gameOverMsg.setMessage(reason);
        gameOverMsg.setRow(lastRow);
        gameOverMsg.setCol(lastCol);
        gameOverMsg.setScoreChange(25);

        roomManager.broadcastToRoom(room.getRoomCode(), gameOverMsg);
    }

    private void broadcastOnlineCount() {
        GameMessage onlineMsg = new GameMessage("ONLINE_COUNT");
        onlineMsg.setOnlineCount(roomManager.getOnlineCount());
        roomManager.broadcastAll(onlineMsg);
    }
}
