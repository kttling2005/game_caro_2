package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user != null) {
            User freshUser = new dao.UserDAO().findById(user.getId());
            if (freshUser != null) {
                user = freshUser;
                session.setAttribute("currentUser", user);
            }
        }
        request.setAttribute("user", user);

        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}