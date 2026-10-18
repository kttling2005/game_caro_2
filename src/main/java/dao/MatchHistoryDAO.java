package dao;

import model.MatchHistory;
import model.User;
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
        String sql = "SELECT m.*, "
                   + "       u1.username AS p1_username, u1.nickname AS p1_nickname, u1.avatar AS p1_avatar, u1.score AS p1_score, "
                   + "       u2.username AS p2_username, u2.nickname AS p2_nickname, u2.avatar AS p2_avatar, u2.score AS p2_score, "
                   + "       w.username AS win_username, w.nickname AS win_nickname "
                   + "FROM match_history m "
                   + "LEFT JOIN users u1 ON m.player1_id = u1.id "
                   + "LEFT JOIN users u2 ON m.player2_id = u2.id "
                   + "LEFT JOIN users w ON m.winner_id = w.id "
                   + "WHERE m.player1_id = ? OR m.player2_id = ? "
                   + "ORDER BY m.played_at DESC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MatchHistory m = mapMatch(rs);

                    // Map Player 1
                    User p1 = new User();
                    p1.setId(m.getPlayer1Id());
                    p1.setUsername(rs.getString("p1_username"));
                    p1.setNickname(rs.getString("p1_nickname"));
                    p1.setAvatar(rs.getString("p1_avatar"));
                    p1.setScore(rs.getInt("p1_score"));
                    m.setPlayer1(p1);

                    // Map Player 2
                    User p2 = new User();
                    p2.setId(m.getPlayer2Id());
                    p2.setUsername(rs.getString("p2_username"));
                    p2.setNickname(rs.getString("p2_nickname"));
                    p2.setAvatar(rs.getString("p2_avatar"));
                    p2.setScore(rs.getInt("p2_score"));
                    m.setPlayer2(p2);

                    // Map Winner if present
                    if (m.getWinnerId() != null) {
                        User w = new User();
                        w.setId(m.getWinnerId());
                        w.setUsername(rs.getString("win_username"));
                        w.setNickname(rs.getString("win_nickname"));
                        m.setWinner(w);
                    }

                    list.add(m);
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
