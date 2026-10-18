package dao;

import model.Room;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    public boolean createRoom(Room room) {
        String sql = "INSERT INTO rooms (room_code, room_name, host_id, password, status, room_type) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, room.getRoomCode());
            ps.setString(2, room.getRoomName());
            ps.setInt(3, room.getHostId());
            ps.setString(4, room.getPassword());
            ps.setString(5, room.getStatus() != null ? room.getStatus() : "WAITING");
            ps.setString(6, room.getRoomType() != null ? room.getRoomType() : "CUSTOM");
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        room.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Room findByCode(String roomCode) {
        String sql = "SELECT * FROM rooms WHERE room_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRoom(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updateGuest(int roomId, Integer guestId, String status) {
        String sql = "UPDATE rooms SET guest_id = ?, status = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (guestId != null) {
                ps.setInt(1, guestId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, status);
            ps.setInt(3, roomId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateStatus(int roomId, String status) {
        String sql = "UPDATE rooms SET status = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, roomId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Room> getWaitingRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE status = 'WAITING' ORDER BY created_at DESC LIMIT 20";
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Room mapRoom(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId(rs.getInt("id"));
        r.setRoomCode(rs.getString("room_code"));
        r.setRoomName(rs.getString("room_name"));
        r.setHostId(rs.getInt("host_id"));
        int guestId = rs.getInt("guest_id");
        r.setGuestId(rs.wasNull() ? null : guestId);
        r.setPassword(rs.getString("password"));
        r.setStatus(rs.getString("status"));
        r.setRoomType(rs.getString("room_type"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        return r;
    }
}
