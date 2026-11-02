package Controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet("/challenge-wait")
public class ChallengeWaitServlet extends HttpServlet {

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

        String targetIdStr = request.getParameter("targetId");
        if (targetIdStr == null || targetIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/challenge");
            return;
        }

        try {
            int targetId = Integer.parseInt(targetIdStr.trim());
            if (targetId == currentUser.getId()) {
                response.sendRedirect(request.getContextPath() + "/challenge");
                return;
            }

            User targetUser = userDAO.findById(targetId);
            if (targetUser == null) {
                response.sendRedirect(request.getContextPath() + "/challenge");
                return;
            }

            request.setAttribute("currentUser", currentUser);
            request.setAttribute("targetUser", targetUser);
            request.getRequestDispatcher("/WEB-INF/views/challengeWait.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/challenge");
        }
    }
}
