package dao;

import model.MatchHistory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MatchHistoryDAO {

    public boolean saveMatch(MatchHistory match) {
        String sql = "INSERT INTO match_history (room_id, player1_id, player2_id, winner_id, total_moves, duration_seconds) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (match.getRoomId() != null) {
                ps.setInt(1, match.getRoomId());
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, match.getPlayer1Id());
            ps.setInt(3, match.getPlayer2Id());
            if (match.getWinnerId() != null) {
                ps.setInt(4, match.getWinnerId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setInt(5, match.getTotalMoves());
            ps.setInt(6, match.getDurationSeconds());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        match.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public MatchHistory getMatchById(int id) {
        String sql = "SELECT * FROM match_history WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMatch(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<MatchHistory> getRecentMatchesByUserId(int userId, int limit) {
        List<MatchHistory> list = new ArrayList<>();
        String sql = "SELECT * FROM match_history WHERE player1_id = ? OR player2_id = ? ORDER BY played_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMatch(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private MatchHistory mapMatch(ResultSet rs) throws SQLException {
        MatchHistory m = new MatchHistory();
        m.setId(rs.getInt("id"));
        int roomId = rs.getInt("room_id");
        m.setRoomId(rs.wasNull() ? null : roomId);
        m.setPlayer1Id(rs.getInt("player1_id"));
        m.setPlayer2Id(rs.getInt("player2_id"));
        int winnerId = rs.getInt("winner_id");
        m.setWinnerId(rs.wasNull() ? null : winnerId);
        m.setTotalMoves(rs.getInt("total_moves"));
        m.setDurationSeconds(rs.getInt("duration_seconds"));
        m.setPlayedAt(rs.getTimestamp("played_at"));
        return m;
    }
}
