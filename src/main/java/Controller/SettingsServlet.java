package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String tabParam = request.getParameter("tab");
        if (tabParam != null && !tabParam.trim().isEmpty()) {
            request.setAttribute("activeTab", tabParam.trim());
        } else {
            request.setAttribute("activeTab", "settings");
        }

        request.getRequestDispatcher("/WEB-INF/views/settings.jsp").forward(request, response);
    }
}
