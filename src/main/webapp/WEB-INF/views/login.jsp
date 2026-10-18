<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Caro Game - Đăng Nhập & Đăng Ký</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <link href="https://fonts.googleapis.com/css2?family=Irish+Grover&family=Montserrat:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        .error-alert {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: rgba(220, 53, 69, 0.35);
            border: 1px solid #ff4d5e;
            color: #ffb3ba;
            font-family: 'Montserrat', sans-serif;
            font-size: 13px;
            font-weight: 600;
            padding: 10px 14px;
            border-radius: 8px;
            margin-bottom: 14px;
            box-shadow: 0 4px 12px rgba(255, 77, 94, 0.2);
        }
        .close-alert-btn {
            background: none;
            border: none;
            color: #ffb3ba;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            margin-left: 10px;
            line-height: 1;
            padding: 0 4px;
        }
        .close-alert-btn:hover {
            color: #ffffff;
        }
    </style>
</head>

<body>

<div class="game-screen">

    <div class="auth-container">
        <!-- TAB CHỌN FORM -->
        <div class="auth-tabs">
            <button type="button" class="tab-btn ${mode != 'register' ? 'active' : ''}" onclick="switchTab('login')">
                Đăng Nhập
            </button>
            <button type="button" class="tab-btn ${mode == 'register' ? 'active' : ''}" onclick="switchTab('register')">
                Đăng Ký
            </button>
        </div>

        <!-- THÔNG BÁO LỖI -->
        <% if (request.getAttribute("error") != null) { %>
            <div id="errorAlert" class="error-alert">
                <span>⚠️ <%= request.getAttribute("error") %></span>
                <button type="button" class="close-alert-btn" onclick="dismissAlert()">×</button>
            </div>
        <% } %>

        <!-- FORM ĐĂNG NHẬP -->
        <form id="loginForm" action="${pageContext.request.contextPath}/login" method="POST"
              class="auth-form ${mode != 'register' ? '' : 'hidden'}">
            <div class="form-group">
                <label for="login-username">Tên đăng nhập</label>
                <input type="text" id="login-username" name="username" 
                       value="${username != null ? username : ''}" 
                       placeholder="Nhập tên đăng nhập..." required autocomplete="username">
            </div>

            <div class="form-group">
                <label for="login-password">Mật khẩu</label>
                <input type="password" id="login-password" name="password" 
                       placeholder="Nhập mật khẩu..." required autocomplete="current-password">
            </div>

            <button type="submit" class="submit-btn">
                VÀO GAME
            </button>
        </form>

        <!-- FORM ĐĂNG KÝ -->
        <form id="registerForm" action="${pageContext.request.contextPath}/register" method="POST"
              class="auth-form ${mode == 'register' ? '' : 'hidden'}">
            <div class="form-group">
                <label for="reg-username">Tên tài khoản (dùng đăng nhập)</label>
                <input type="text" id="reg-username" name="username" 
                       placeholder="Tạo tên tài khoản..." required autocomplete="username">
            </div>

            <div class="form-group">
                <label for="reg-nickname">Tên hiển thị (Nickname trong game)</label>
                <input type="text" id="reg-nickname" name="nickname" 
                       value="${nickname != null ? nickname : ''}"
                       placeholder="Biệt danh hiển thị..." required>
            </div>

            <div class="form-group">
                <label for="reg-password">Mật khẩu</label>
                <input type="password" id="reg-password" name="password" 
                       placeholder="Tạo mật khẩu..." required autocomplete="new-password">
            </div>

            <button type="submit" class="submit-btn register-submit">
                TẠO TÀI KHOẢN
            </button>
        </form>
    </div>

</div>

<script>
    function switchTab(tab) {
        const loginForm = document.getElementById('loginForm');
        const registerForm = document.getElementById('registerForm');
        const tabs = document.querySelectorAll('.tab-btn');

        if (tab === 'login') {
            loginForm.classList.remove('hidden');
            registerForm.classList.add('hidden');
            tabs[0].classList.add('active');
            tabs[1].classList.remove('active');
        } else {
            loginForm.classList.add('hidden');
            registerForm.classList.remove('hidden');
            tabs[0].classList.remove('active');
            tabs[1].classList.add('active');
        }
    }

    function dismissAlert() {
        const alert = document.getElementById('errorAlert');
        if (alert) {
            alert.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                if (alert.parentNode) alert.remove();
            }, 400);
        }
    }

    // Tự động tắt thông báo lỗi sau 3 giây
    window.addEventListener('DOMContentLoaded', () => {
        const alert = document.getElementById('errorAlert');
        if (alert) {
            setTimeout(dismissAlert, 3000);
        }
    });
</script>

</body>
</html>