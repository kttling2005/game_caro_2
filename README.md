
#  Thành viên nhóm

| Thành viên | Phần phụ trách |
|---|---|
| Dang Ngoc | Login / Register |
| Vu Thi Dao | Create Room / Join Room |
| Cam Ly | Find Match |
| Thuy Linh | Gameplay / Ranking |

# 🎮 Caro Game

Ứng dụng game **Cờ Caro 2 người chơi** được xây dựng theo mô hình Client–Server, cho phép người chơi tạo phòng, tham gia phòng và thi đấu Caro trực tuyến.

## 📌 Giới thiệu

**Caro Game** là một trò chơi cờ Caro dành cho 2 người chơi.

Người chơi có thể:

*  Đăng nhập vào hệ thống
*  Tạo phòng chơi
*  Tham gia phòng bằng mã phòng
*  Tìm đối thủ
*  Chơi Caro trên bàn cờ 15×15
*  Theo dõi thời gian lượt chơi
*  Sử dụng emoji trong trận đấu
*  Xác định người thắng/thua sau khi kết thúc ván

---

##  Chức năng chính

### 1. Login

Người chơi đăng nhập trước khi sử dụng hệ thống.

* Nhập username
* Nhập password
* Kiểm tra thông tin đăng nhập
* Chuyển đến giao diện chính sau khi đăng nhập thành công

### 2. Create Room

Người chơi có thể tạo một phòng chơi mới.

Thông tin phòng bao gồm:

* Room ID
* Người tạo phòng
* Trạng thái phòng

Sau khi tạo phòng, người chơi có thể chờ đối thủ tham gia.

### 3. Join Room

Người chơi có thể nhập mã phòng để tham gia một phòng có sẵn.

### 4. Find Match

Hệ thống hỗ trợ tìm kiếm đối thủ để bắt đầu một trận đấu.

### 5. Caro Game

Bàn cờ có kích thước:

**15 × 15**

Trong trận đấu:

* Hai người chơi lần lượt đánh X và O.
* Mỗi người có một khu vực hiển thị Avatar.
* Đồng hồ đếm ngược thời gian lượt chơi.
* Người chơi có thể sử dụng emoji để tương tác.
* Khi có người tạo được chuỗi quân cờ hợp lệ, trận đấu kết thúc.

---

# 🛠️ Công nghệ sử dụng

| Thành phần | Công nghệ                                    |
| ---------- | -------------------------------------------- |
| Frontend   | HTML, CSS, JavaScript                        |
| Backend    | Java                                         |
| Web Server | Apache Tomcat                                |
| Database   | MySQL                                        |
| IDE        | NetBeans / IntelliJ IDEA / VS Code           |
| Build Tool | Maven                                        |
| Giao thức  | HTTP / TCP hoặc WebSocket tùy implementation |

---

# 📂 Cấu trúc project

Cấu trúc project có thể được tổ chức như sau:

```text
Caro_game/
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── ...
│   │   │
│   │   └── webapp/
│   │       ├── css/
│   │       ├── js/
│   │       ├── images/
│   │       ├── WEB-INF/
│   │       └── ...
│
├── pom.xml
├── README.md
└── ...
```

---

#  Hướng dẫn cài đặt

## 1. Yêu cầu môi trường

Trước khi chạy project, cần cài đặt:

* **JDK 17 trở lên**
* **Apache Tomcat 10.x**
* **Maven**
* **MySQL** nếu project sử dụng database
* IDE hỗ trợ Java Web/Maven

Kiểm tra Java:

```bash
java -version
```

Kiểm tra Maven:

```bash
mvn -version
```

---

# ⚙️ Cấu hình Apache Tomcat

## Bước 1: Cài đặt Apache Tomcat

Tải Apache Tomcat từ trang chủ:

https://tomcat.apache.org/

Khuyến nghị sử dụng **Tomcat 10.x** nếu project sử dụng Jakarta Servlet.

Sau khi tải về, giải nén Tomcat.

Ví dụ trên macOS:

```text
/Users/yourname/apache-tomcat-10.x.x/
```

Cấu trúc thư mục Tomcat:

```text
apache-tomcat-10.x.x/
├── bin/
├── conf/
├── lib/
├── logs/
├── temp/
├── webapps/
└── work/
```

---

# ▶️ Chạy Tomcat bằng Terminal

Di chuyển đến thư mục `bin` của Tomcat:

```bash
cd /path/to/apache-tomcat-10.x.x/bin
```

### Khởi động server

Trên macOS/Linux:

```bash
./startup.sh
```

Nếu chạy thành công, Terminal sẽ hiển thị thông báo tương tự:

```text
Tomcat started.
```

Sau đó mở trình duyệt:

```text
http://localhost:8080
```

Nếu xuất hiện trang Apache Tomcat thì server đã hoạt động.

---

##  Dừng Tomcat

Để dừng server:

```bash
./shutdown.sh
```

---

#  Deploy project lên Tomcat

Có 2 cách phổ biến để chạy project.

## Cách 1: Chạy bằng IDE

Nếu sử dụng NetBeans:

1. Mở project bằng NetBeans.

2. Cấu hình Apache Tomcat trong:

   ```text
   Tools → Servers
   ```

3. Thêm Apache Tomcat.

4. Chọn project.

5. Chọn:

   ```text
   Run Project
   ```

NetBeans sẽ tự động build và deploy project lên Tomcat.

Sau đó truy cập:

```text
http://localhost:8080/<ten-project>
```

Ví dụ:

```text
http://localhost:8080/Caro_game
```

---

#  Cách 2: Deploy file WAR

Build project bằng Maven:

```bash
mvn clean package
```

Sau khi build thành công, file `.war` sẽ được tạo trong:

```text
target/
```

Ví dụ:

```text
target/Caro_game.war
```

Copy file WAR vào thư mục:

```text
apache-tomcat-10.x.x/webapps/
```

Ví dụ:

```bash
cp target/Caro_game.war /path/to/apache-tomcat-10.x.x/webapps/
```

Sau đó khởi động Tomcat:

```bash
cd /path/to/apache-tomcat-10.x.x/bin
./startup.sh
```

Tomcat sẽ tự động giải nén file WAR.

Truy cập:

```text
http://localhost:8080/Caro_game
```

---

#  Cấu hình Database

Nếu project sử dụng MySQL, trước tiên tạo database:

```sql
CREATE DATABASE caro_game;
```

Sau đó import file SQL của project nếu có:

```bash
mysql -u root -p caro_game < database.sql
```

Cập nhật thông tin database trong file cấu hình của project:

```text
Database URL: jdbc:mysql://localhost:3306/caro_game
Username: root
Password: your_password
```

> Thay đổi username, password và tên database tùy theo cấu hình máy.

---

#  Hướng dẫn chơi

### Bước 1

Mở ứng dụng:

```text
http://localhost:8080/Caro_game
```

### Bước 2

Đăng nhập tài khoản.

### Bước 3

Tại Menu chính, chọn một trong các chức năng:

```text
Create Room
Join Room
Find Match
```

### Bước 4

Nếu tạo phòng:

```text
Create Room
      ↓
Waiting for opponent
      ↓
Opponent joins
      ↓
Start Game
```

Nếu tham gia phòng:

```text
Join Room
      ↓
Enter Room ID
      ↓
Join
      ↓
Start Game
```

### Bước 5

Bắt đầu trận đấu trên bàn cờ 15×15.

Hai người chơi lần lượt thực hiện nước đi.

---

#  Luật chơi

* Bàn cờ gồm **15 × 15 ô**.
* Hai người chơi lần lượt đánh quân.
* Mỗi người có một lượt chơi.
* Mỗi lượt có thời gian giới hạn.
* Người chơi tạo được chuỗi quân cờ theo luật của game sẽ thắng.
* Khi hết thời gian lượt chơi, hệ thống xử lý lượt chơi theo luật được cài đặt.

---

#  Một số lỗi thường gặp

## Tomcat không khởi động

Kiểm tra port 8080:

```bash
lsof -i :8080
```

Nếu port đang được sử dụng, có thể thay đổi port trong:

```text
conf/server.xml
```

Tìm:

```xml
<Connector port="8080" ... />
```

Đổi thành port khác, ví dụ:

```xml
<Connector port="8081" ... />
```

Sau đó truy cập:

```text
http://localhost:8081
```

---

## Lỗi Java version

Kiểm tra:

```bash
java -version
```

và:

```bash
mvn -version
```

Đảm bảo Maven đang sử dụng đúng JDK mà project yêu cầu.

---

## Lỗi 404

Kiểm tra:

1. Tomcat đã chạy chưa.
2. Tên project/WAR có chính xác không.
3. Project đã được deploy vào `webapps` chưa.
4. URL có đúng context path không.

Ví dụ file:

```text
Caro_game.war
```

thường sẽ được truy cập bằng:

```text
http://localhost:8080/Caro_game
```

---

# 📄 License

Project được thực hiện với mục đích học tập.
