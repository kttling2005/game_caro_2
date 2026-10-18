package Controller;

import dao.RoomDAO;
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

@WebServlet("/game-play")
public class GamePlayServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roomCode = request.getParameter("roomCode");
        if (roomCode == null || roomCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/game");
            return;
        }

        roomCode = roomCode.trim();
        Room room = RoomManager.getInstance().getRoom(roomCode);
        if (room == null) {
            room = roomDAO.findByCode(roomCode);
            if (room != null) {
                RoomManager.getInstance().addRoom(room);
            }
        }

        request.setAttribute("roomCode", roomCode);
        request.setAttribute("room", room);
        request.setAttribute("currentUser", currentUser);

        request.getRequestDispatcher("/WEB-INF/views/gamePlay.jsp").forward(request, response);
    }
}