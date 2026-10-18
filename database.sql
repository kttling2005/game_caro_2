-- ========================================================
-- Database Schema for Caro Game (XO Game)
-- Database: caro_db
-- ========================================================

CREATE DATABASE IF NOT EXISTS `caro_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `caro_db`;

-- --------------------------------------------------------
-- 1. Table structure for table `users`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `match_history`;
DROP TABLE IF EXISTS `rooms`;
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `nickname` VARCHAR(50) NOT NULL,
  `avatar` VARCHAR(255) DEFAULT 'default.png',
  `total_matches` INT(11) DEFAULT 0,
  `wins` INT(11) DEFAULT 0,
  `draws` INT(11) DEFAULT 0,
  `losses` INT(11) DEFAULT 0,
  `score` INT(11) DEFAULT 1000,
  `status` ENUM('OFFLINE','ONLINE','IN_ROOM','PLAYING') DEFAULT 'OFFLINE',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data for `users`
INSERT INTO `users` (`id`, `username`, `password`, `nickname`, `avatar`, `total_matches`, `wins`, `draws`, `losses`, `score`, `status`) VALUES
(1, 'player1', '123456', 'Nguyễn Văn An', 'avatar1.svg', 12, 10, 0, 2, 1250, 'OFFLINE'),
(2, 'player2', '123456', 'Lê Thị Bình', 'avatar5.svg', 9, 5, 0, 4, 1100, 'OFFLINE'),
(3, 'admin', '123456', 'Quản Trị Viên', 'avatar7.svg', 21, 20, 0, 1, 1500, 'OFFLINE');

-- --------------------------------------------------------
-- 2. Table structure for table `rooms`
-- --------------------------------------------------------
CREATE TABLE `rooms` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `room_code` VARCHAR(20) NOT NULL,
  `room_name` VARCHAR(100) NOT NULL,
  `host_id` INT(11) NOT NULL,
  `guest_id` INT(11) DEFAULT NULL,
  `password` VARCHAR(50) DEFAULT NULL,
  `status` ENUM('WAITING','PLAYING','CLOSED') DEFAULT 'WAITING',
  `room_type` VARCHAR(20) DEFAULT 'CUSTOM',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_room_code` (`room_code`),
  KEY `fk_rooms_host` (`host_id`),
  KEY `fk_rooms_guest` (`guest_id`),
  CONSTRAINT `fk_rooms_host` FOREIGN KEY (`host_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rooms_guest` FOREIGN KEY (`guest_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- 3. Table structure for table `match_history`
-- --------------------------------------------------------
CREATE TABLE `match_history` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `room_id` INT(11) DEFAULT NULL,
  `player1_id` INT(11) NOT NULL,
  `player2_id` INT(11) NOT NULL,
  `winner_id` INT(11) DEFAULT NULL,
  `total_moves` INT(11) DEFAULT 0,
  `duration_seconds` INT(11) DEFAULT 0,
  `played_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `fk_history_room` (`room_id`),
  KEY `fk_history_p1` (`player1_id`),
  KEY `fk_history_p2` (`player2_id`),
  KEY `fk_history_winner` (`winner_id`),
  CONSTRAINT `fk_history_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_history_p1` FOREIGN KEY (`player1_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_history_p2` FOREIGN KEY (`player2_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_history_winner` FOREIGN KEY (`winner_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
