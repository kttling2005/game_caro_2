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
import java.util.List;

@WebServlet("/ranking")
public class RankingServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        List<User> rankings = userDAO.getTopRankings(10);
        request.setAttribute("rankings", rankings);

        if (currentUser != null) {
            // Cập nhật lại thông tin mới nhất từ DB
            User updatedUser = userDAO.findById(currentUser.getId());
            if (updatedUser != null) {
                currentUser = updatedUser;
                session.setAttribute("currentUser", currentUser);
            }
            int myRank = userDAO.getUserRank(currentUser.getId());
            request.setAttribute("myRank", myRank);
            request.setAttribute("currentUser", currentUser);
        }

        request.getRequestDispatcher("/WEB-INF/views/ranking.jsp").forward(request, response);
    }
}