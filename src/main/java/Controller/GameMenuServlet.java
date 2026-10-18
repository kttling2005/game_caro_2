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

        // Lấy số lượng người online
        int onlineCount = RoomManager.getInstance().getOnlineCount();
        if (onlineCount <= 0) {
            onlineCount = userDAO.getOnlineCount();
        }
        if (onlineCount <= 0) {
            onlineCount = 1; // Bản thân người chơi
        }
        request.setAttribute("onlineCount", onlineCount);

        // Lấy danh sách top người chơi để hiển thị
        List<User> topPlayers = userDAO.getTopRankings(6);
        request.setAttribute("topPlayers", topPlayers);

        // Lấy danh sách phòng đang chờ
        List<Room> waitingRooms = roomDAO.getWaitingRooms();
        request.setAttribute("waitingRooms", waitingRooms);

        request.getRequestDispatcher("/WEB-INF/views/gameMenu.jsp").forward(request, response);
    }
}