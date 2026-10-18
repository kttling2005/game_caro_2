package Controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

@WebServlet("/option")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB
        maxFileSize = 3 * 1024 * 1024,       // 3MB
        maxRequestSize = 6 * 1024 * 1024     // 6MB
)
public class OptionServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Luôn nạp thông tin mới nhất từ CSDL
        User user = userDAO.findById(currentUser.getId());
        if (user != null) {
            currentUser = user;
            session.setAttribute("currentUser", currentUser);
        }

        int myRank = userDAO.getUserRank(currentUser.getId());
        request.setAttribute("user", currentUser);
        request.setAttribute("myRank", myRank);

        // Danh sách 12 avatar có sẵn
        List<String> presetAvatars = new ArrayList<>();
        for (int i = 1; i <= 12; i++) {
            presetAvatars.add("avatar" + i + ".svg");
        }
        request.setAttribute("presetAvatars", presetAvatars);

        // Đọc thông báo flash từ session (nếu có)
        if (session.getAttribute("optionSuccess") != null) {
            request.setAttribute("success", session.getAttribute("optionSuccess"));
            session.removeAttribute("optionSuccess");
        }
        if (session.getAttribute("optionError") != null) {
            request.setAttribute("error", session.getAttribute("optionError"));
            session.removeAttribute("optionError");
        }

        request.getRequestDispatcher("/WEB-INF/views/option.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        switch (action) {
            case "changeAvatar":
                handleChangeAvatar(request, session, currentUser);
                break;

            case "uploadAvatar":
                handleUploadAvatar(request, session, currentUser);
                break;

            case "changeNickname":
                handleChangeNickname(request, session, currentUser);
                break;

            case "changePassword":
                handleChangePassword(request, session, currentUser);
                break;

            default:
                session.setAttribute("optionError", "Hành động không hợp lệ!");
                break;
        }

        response.sendRedirect(request.getContextPath() + "/option");
    }

    private void handleChangeAvatar(HttpServletRequest request, HttpSession session, User user) {
        String avatar = request.getParameter("presetAvatar");
        if (avatar == null || !avatar.matches("^avatar([1-9]|1[0-2])\\.svg$")) {
            session.setAttribute("optionError", "Avatar chọn không hợp lệ!");
            return;
        }

        if (userDAO.updateAvatar(user.getId(), avatar)) {
            user.setAvatar(avatar);
            session.setAttribute("currentUser", user);
            session.setAttribute("optionSuccess", "Cập nhật Avatar game thành công!");
        } else {
            session.setAttribute("optionError", "Không thể cập nhật avatar. Vui lòng thử lại!");
        }
    }

    private void handleUploadAvatar(HttpServletRequest request, HttpSession session, User user) {
        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("optionError", "Vui lòng chọn một tệp ảnh để tải lên!");
                return;
            }

            if (filePart.getSize() > 3 * 1024 * 1024) {
                session.setAttribute("optionError", "Kích thước ảnh vượt quá giới hạn 3MB!");
                return;
            }

            String submittedFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String lowerName = submittedFileName.toLowerCase();
            String extension = "";
            if (lowerName.endsWith(".png")) extension = ".png";
            else if (lowerName.endsWith(".jpg")) extension = ".jpg";
            else if (lowerName.endsWith(".jpeg")) extension = ".jpeg";
            else if (lowerName.endsWith(".webp")) extension = ".webp";
            else if (lowerName.endsWith(".gif")) extension = ".gif";
            else {
                session.setAttribute("optionError", "Định dạng không hỗ trợ! Chỉ chấp nhận PNG, JPG, JPEG, WEBP, GIF.");
                return;
            }

            // Tên file duy nhất luôn lưu chuẩn định dạng .png
            String newFileName = "avatar_user_" + user.getId() + "_" + System.currentTimeMillis() + ".png";

            // Thư mục uploads trong webapp deployed
            String deployedUploadPath = request.getServletContext().getRealPath("/uploads/avatars");
            if (deployedUploadPath != null) {
                File dir = new File(deployedUploadPath);
                if (!dir.exists()) dir.mkdirs();
                File targetFile = new File(dir, newFileName);

                // Tự động cắt vuông và resize về chuẩn 256x256 để chống vỡ khung hình
                try (InputStream input = filePart.getInputStream()) {
                    BufferedImage original = ImageIO.read(input);
                    if (original != null) {
                        int w = original.getWidth();
                        int h = original.getHeight();
                        int size = Math.min(w, h);
                        int cropX = (w - size) / 2;
                        int cropY = (h - size) / 2;
                        BufferedImage cropped = original.getSubimage(cropX, cropY, size, size);

                        int targetSize = 256;
                        BufferedImage resized = new BufferedImage(targetSize, targetSize, BufferedImage.TYPE_INT_ARGB);
                        Graphics2D g2 = resized.createGraphics();
                        g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
                        g2.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
                        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                        g2.drawImage(cropped, 0, 0, targetSize, targetSize, null);
                        g2.dispose();

                        ImageIO.write(resized, "png", targetFile);
                    } else {
                        Files.copy(filePart.getInputStream(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                }
            }

            // Đồng thời lưu vào thư mục nguồn nếu tồn tại để không bị mất khi build lại
            try {
                String srcUploadPath = request.getServletContext().getRealPath("/").replace("target\\Caro_game-1.0-SNAPSHOT", "src\\main\\webapp") + "uploads/avatars";
                File srcDir = new File(srcUploadPath);
                if (srcDir.exists() && deployedUploadPath != null) {
                    Files.copy(new File(deployedUploadPath, newFileName).toPath(),
                            new File(srcDir, newFileName).toPath(),
                            StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (Exception ignored) {}

            String dbAvatarPath = "uploads/avatars/" + newFileName;
            if (userDAO.updateAvatar(user.getId(), dbAvatarPath)) {
                user.setAvatar(dbAvatarPath);
                session.setAttribute("currentUser", user);
                session.setAttribute("optionSuccess", "Tải lên ảnh đại diện cá nhân thành công!");
            } else {
                session.setAttribute("optionError", "Không thể lưu thông tin ảnh vào cơ sở dữ liệu!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("optionError", "Lỗi trong quá trình tải ảnh: " + e.getMessage());
        }
    }

    private void handleChangeNickname(HttpServletRequest request, HttpSession session, User user) {
        String nickname = request.getParameter("nickname");
        if (nickname == null || nickname.trim().isEmpty()) {
            session.setAttribute("optionError", "Tên hiển thị không được để trống!");
            return;
        }

        nickname = nickname.trim();
        if (nickname.length() > 30) {
            session.setAttribute("optionError", "Tên hiển thị không được vượt quá 30 ký tự!");
            return;
        }

        if (userDAO.updateNickname(user.getId(), nickname)) {
            user.setNickname(nickname);
            session.setAttribute("currentUser", user);
            session.setAttribute("optionSuccess", "Đổi tên hiển thị thành công!");
        } else {
            session.setAttribute("optionError", "Không thể cập nhật tên. Vui lòng thử lại!");
        }
    }

    private void handleChangePassword(HttpServletRequest request, HttpSession session, User user) {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || currentPassword.isEmpty()
                || newPassword == null || newPassword.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            session.setAttribute("optionError", "Vui lòng nhập đầy đủ các trường mật khẩu!");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("optionError", "Mật khẩu mới và xác nhận mật khẩu không khớp!");
            return;
        }

        if (newPassword.length() < 6) {
            session.setAttribute("optionError", "Mật khẩu mới phải có ít nhất 6 ký tự!");
            return;
        }

        if (userDAO.updatePassword(user.getId(), currentPassword, newPassword)) {
            user.setPassword(newPassword);
            session.setAttribute("currentUser", user);
            session.setAttribute("optionSuccess", "Đổi mật khẩu thành công!");
        } else {
            session.setAttribute("optionError", "Mật khẩu hiện tại không chính xác!");
        }
    }
}
