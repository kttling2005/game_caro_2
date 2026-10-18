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

@WebServlet("/create-room")
public class CreateRoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/createRoom.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roomName = request.getParameter("roomName");
        String password = request.getParameter("password");

        if (roomName == null || roomName.trim().isEmpty()) {
            roomName = "Phòng của " + currentUser.getNickname();
        }

        if (password != null && password.trim().isEmpty()) {
            password = null;
        }

        // Sinh mã phòng ngẫu nhiên 6 chữ số
        String roomCode = String.valueOf((int) (Math.random() * 900000 + 100000));

        Room room = new Room();
        room.setRoomCode(roomCode);
        room.setRoomName(roomName.trim());
        room.setHostId(currentUser.getId());
        room.setHostUser(currentUser);
        room.setPassword(password != null ? password.trim() : null);
        room.setStatus("WAITING");
        room.setRoomType("CUSTOM");

        if (roomDAO.createRoom(room)) {
            RoomManager.getInstance().addRoom(room);
            response.sendRedirect(request.getContextPath() + "/game-play?roomCode=" + roomCode);
        } else {
            request.setAttribute("error", "Không thể tạo phòng. Vui lòng thử lại!");
            request.getRequestDispatcher("/WEB-INF/views/createRoom.jsp").forward(request, response);
        }
    }
}