package Controller;

import dao.RoomDAO;
import dao.UserDAO;
import engine.RoomManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Room;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/game")
public class GameMenuServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        request.setAttribute("currentUser", currentUser);

        // Lấy số lượng người online đồng bộ giữa CSDL và WebSocket
        int dbOnlineCount = userDAO.getOnlineCount();
        int wsOnlineCount = RoomManager.getInstance().getOnlineCount();
        int onlineCount = Math.max(dbOnlineCount, wsOnlineCount);
        if (onlineCount <= 0) {
            onlineCount = 1; // Bản thân người chơi đang truy cập
        }
        request.setAttribute("onlineCount", onlineCount);

        // Lấy danh sách người chơi hiển thị thông minh:
        // Ưu tiên 1: Người chơi đang ONLINE (đặt lên đầu)
        // Ưu tiên 2: Nếu chưa đủ 6 người, bổ sung thêm Top cao thủ CSDL để danh sách luôn đầy đặn
        int currentUserId = (currentUser != null) ? currentUser.getId() : -1;
        java.util.List<User> activePlayers = new java.util.ArrayList<>();
        java.util.Set<Integer> addedIds = new java.util.HashSet<>();
        if (currentUserId > 0) {
            addedIds.add(currentUserId);
        }

        List<User> onlineList = userDAO.getOnlineUsers(currentUserId);
        if (onlineList != null) {
            for (User u : onlineList) {
                if (addedIds.add(u.getId())) {
                    activePlayers.add(u);
                }
                if (activePlayers.size() >= 6) break;
            }
        }

        boolean hasOtherOnline = !activePlayers.isEmpty();
        request.setAttribute("hasOtherOnline", hasOtherOnline);

        if (activePlayers.size() < 6) {
            List<User> topList = userDAO.getTopRankings(10);
            if (topList != null) {
                for (User u : topList) {
                    if (addedIds.add(u.getId())) {
                        activePlayers.add(u);
                    }
                    if (activePlayers.size() >= 6) break;
                }
            }
        }
        request.setAttribute("topPlayers", activePlayers);

        // Lấy danh sách phòng đang chờ
        List<Room> waitingRooms = roomDAO.getWaitingRooms();
        request.setAttribute("waitingRooms", waitingRooms);

        request.getRequestDispatcher("/WEB-INF/views/gameMenu.jsp").forward(request, response);
    }
}