package Controller;

import dao.UserDAO;
import engine.RoomManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet("/challenge")
public class ChallengeServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String query = request.getParameter("q");
        List<User> playerList;

        if (query != null && !query.trim().isEmpty()) {
            playerList = userDAO.searchUsers(query.trim(), currentUser.getId());
        } else {
            playerList = userDAO.getOnlineUsers(currentUser.getId());
            // Nếu danh sách online đang trống (ví dụ chỉ có 1 người đang online), lấy thêm top người chơi để giao diện luôn đầy đủ
            if (playerList == null || playerList.isEmpty()) {
                playerList = userDAO.getTopRankings(15);
                playerList.removeIf(u -> u.getId() == currentUser.getId());
                request.setAttribute("isFallbackList", true);
            }
        }

        request.setAttribute("playerList", playerList);
        request.setAttribute("searchQuery", query != null ? query.trim() : "");
        request.setAttribute("currentUser", currentUser);

        request.getRequestDispatcher("/WEB-INF/views/challenge.jsp").forward(request, response);
    }
}
