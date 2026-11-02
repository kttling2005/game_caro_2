package listener;

import dao.UserDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;
import model.User;

@WebListener
public class AppListener implements ServletContextListener, HttpSessionListener {

    private final UserDAO userDAO = new UserDAO();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Khi Server khởi động hoặc reload: reset toàn bộ trạng thái user về OFFLINE để xóa trạng thái ảo
        System.out.println("[AppListener] Application initialized. Resetting all user status to OFFLINE...");
        userDAO.resetAllStatusToOffline();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppListener] Application shutting down.");
    }

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // Session created
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        // Khi Session hết hạn (timeout) hoặc bị hủy: tự động cập nhật user về OFFLINE
        try {
            User user = (User) se.getSession().getAttribute("currentUser");
            if (user != null) {
                System.out.println("[AppListener] Session expired for user: " + user.getUsername() + ". Updating to OFFLINE.");
                userDAO.updateStatus(user.getId(), "OFFLINE");
            }
        } catch (Exception e) {
            // ignore
        }
    }
}
