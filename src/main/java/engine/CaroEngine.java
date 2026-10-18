package engine;

import model.Room;

public class CaroEngine {

    public static final int WIN_COUNT = 5;

    /**
     * Kiểm tra tính hợp lệ của nước đi
     */
    public static boolean isValidMove(String[][] board, int row, int col) {
        if (row < 0 || row >= Room.BOARD_SIZE || col < 0 || col >= Room.BOARD_SIZE) {
            return false;
        }
        return board[row][col] == null || board[row][col].trim().isEmpty();
    }

    /**
     * Kiểm tra xem nước đi tại (row, col) có tạo thành 5 quân liên tiếp hay không
     */
    public static boolean checkWin(String[][] board, int row, int col, String symbol) {
        if (symbol == null || symbol.isEmpty()) {
            return false;
        }

        // 4 hướng: Ngang, Dọc, Chéo chính (\), Chéo phụ (/)
        int[][] directions = {
            {0, 1},   // Ngang
            {1, 0},   // Dọc
            {1, 1},   // Chéo chính (\)
            {1, -1}   // Chéo phụ (/)
        };

        for (int[] dir : directions) {
            int dr = dir[0];
            int dc = dir[1];
            int count = 1;

            // Đếm về hướng dương
            count += countDirection(board, row, col, dr, dc, symbol);
            // Đếm về hướng âm
            count += countDirection(board, row, col, -dr, -dc, symbol);

            if (count >= WIN_COUNT) {
                return true;
            }
        }
        return false;
    }

    private static int countDirection(String[][] board, int row, int col, int dr, int dc, String symbol) {
        int count = 0;
        int r = row + dr;
        int c = col + dc;

        while (r >= 0 && r < Room.BOARD_SIZE && c >= 0 && c < Room.BOARD_SIZE) {
            if (symbol.equals(board[r][c])) {
                count++;
                r += dr;
                c += dc;
            } else {
                break;
            }
        }
        return count;
    }

    /**
     * Kiểm tra xem bàn cờ đã đầy chưa (kết quả Hòa)
     */
    public static boolean isBoardFull(String[][] board) {
        for (int r = 0; r < Room.BOARD_SIZE; r++) {
            for (int c = 0; c < Room.BOARD_SIZE; c++) {
                if (board[r][c] == null || board[r][c].trim().isEmpty()) {
                    return false;
                }
            }
        }
        return true;
    }
}
