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

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        int currentUserId = (currentUser != null) ? currentUser.getId() : 0;

        boolean isCurrentPlayer = (currentUserId > 0) && (room.getHostId() == currentUserId || (room.getGuestId() != null && room.getGuestId() == currentUserId));

        if (!isCurrentPlayer) {
            if ("PLAYING".equals(room.getStatus())) {
                request.setAttribute("error", "Phòng này đang trong trận đấu! Vui lòng chọn phòng khác.");
                request.setAttribute("roomId", roomCode);
                request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
                return;
            }
            if (!"WAITING".equals(room.getStatus()) || room.getGuestId() != null) {
                request.setAttribute("error", "Phòng đã đủ 2 người chơi hoặc không còn nhận thêm đối thủ!");
                request.setAttribute("roomId", roomCode);
                request.getRequestDispatcher("/WEB-INF/views/joinRoom.jsp").forward(request, response);
                return;
            }
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