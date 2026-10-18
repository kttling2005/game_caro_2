package Controller;

import dao.RoomDAO;
import engine.RoomManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Room;

import java.io.IOException;

@WebServlet("/join-room")
public class JoinRoomServlet extends HttpServlet {

    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String roomCode = request.getParameter("roomId");
        String password = request.getParameter("password");

        if (roomCode == null || roomCode.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã phòng!");
            request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
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

        if (room == null) {
            request.setAttribute("error", "Phòng không tồn tại hoặc đã kết thúc!");
            request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
            return;
        }

        if ("CLOSED".equals(room.getStatus())) {
            request.setAttribute("error", "Phòng này đã đóng!");
            request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
            return;
        }

        if (room.getPassword() != null && !room.getPassword().isEmpty()) {
            if (password == null || !room.getPassword().equals(password.trim())) {
                request.setAttribute("error", "Mật khẩu phòng không chính xác!");
                request.setAttribute("roomId", roomCode);
                request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/game-play?roomCode=" + roomCode);
    }
}