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

@WebServlet("/result")
public class ResultServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        String winnerSymbol = request.getParameter("winner");
        String mySymbol = request.getParameter("mySymbol");
        String moves = request.getParameter("moves");
        String time = request.getParameter("time");

        boolean isWin = false;
        boolean isDraw = "DRAW".equalsIgnoreCase(winnerSymbol);

        if (mySymbol != null && mySymbol.equalsIgnoreCase(winnerSymbol)) {
            isWin = true;
        }

        // Cập nhật lại thông tin mới nhất của user từ DB
        if (currentUser != null) {
            User updated = userDAO.findById(currentUser.getId());
            if (updated != null) {
                session.setAttribute("currentUser", updated);
                currentUser = updated;
            }
        }

        request.setAttribute("isWin", isWin);
        request.setAttribute("isDraw", isDraw);
        request.setAttribute("winnerSymbol", winnerSymbol);
        request.setAttribute("moves", moves != null ? moves : "0");
        request.setAttribute("time", time != null ? time : "00:00");
        request.setAttribute("currentUser", currentUser);

        request.getRequestDispatcher("/WEB-INF/views/result.jsp").forward(request, response);
    }
}