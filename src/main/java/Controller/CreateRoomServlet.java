package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/create-room")
public class CreateRoomServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/createRoom.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String roomName = request.getParameter("roomName");
        String maxPlayers = request.getParameter("maxPlayers");
        String password = request.getParameter("password");

        // Tạm thời kiểm tra dữ liệu
        System.out.println("Room name: " + roomName);
        System.out.println("Max players: " + maxPlayers);
        System.out.println("Password: " + password);

        // Sau này xử lý tạo phòng ở đây

        response.sendRedirect(request.getContextPath() + "/game");
    }
}