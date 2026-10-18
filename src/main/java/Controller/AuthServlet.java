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

@WebServlet({"/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.equals("/logout")) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                User user = (User) session.getAttribute("currentUser");
                if (user != null) {
                    userDAO.updateStatus(user.getId(), "OFFLINE");
                }
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if (path.equals("/register")) {
            request.setAttribute("mode", "register");
        } else {
            request.setAttribute("mode", "login");
        }

        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if (path.equals("/login")) {
            handleLogin(request, response);
        } else if (path.equals("/register")) {
            handleRegister(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            request.setAttribute("mode", "login");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.login(username.trim(), password.trim());
        if (user != null) {
            userDAO.updateStatus(user.getId(), "ONLINE");
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            request.setAttribute("mode", "login");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String nickname = request.getParameter("nickname");

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || nickname == null || nickname.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ các thông tin đăng ký!");
            request.setAttribute("mode", "register");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        if (userDAO.checkUsernameExists(username.trim())) {
            request.setAttribute("error", "Tên đăng nhập đã tồn tại! Vui lòng chọn tên khác.");
            request.setAttribute("mode", "register");
            request.setAttribute("nickname", nickname);
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        User newUser = new User();
        newUser.setUsername(username.trim());
        newUser.setPassword(password.trim());
        newUser.setNickname(nickname.trim());
        newUser.setAvatar("default.png");

        if (userDAO.register(newUser)) {
            userDAO.updateStatus(newUser.getId(), "ONLINE");
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", newUser);
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            request.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại sau!");
            request.setAttribute("mode", "register");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }
}