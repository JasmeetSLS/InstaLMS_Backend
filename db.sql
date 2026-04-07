-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.43 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.15.0.7171
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for insta_style_lms
CREATE DATABASE IF NOT EXISTS `insta_style_lms` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `insta_style_lms`;

-- Dumping structure for table insta_style_lms.admins
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'admin',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.admins: ~1 rows (approximately)
INSERT INTO `admins` (`id`, `username`, `password`, `email`, `role`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Admin', '$2b$12$24vr9WK4g3VJRlDslopOBuIU5tsgIVNcfEx4jhgaYrcMszO5wqyzS', 'admin@admin.com', 'SuperAdmin', 'active', '2026-04-06 06:34:53', '2026-04-06 06:35:37');

-- Dumping structure for table insta_style_lms.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_status` (`status`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.categories: ~2 rows (approximately)
INSERT INTO `categories` (`id`, `name`, `icon_url`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Product', '/uploads/category/1/file-1775459235909-282061595.jpg', 'active', '2026-04-06 07:07:15', '2026-04-06 07:07:15'),
	(2, 'Process', '/uploads/category/2/file-1775459882744-309037248.avif', 'active', '2026-04-06 07:18:02', '2026-04-06 07:18:02'),
	(3, 'Technology', '/uploads/category/3/file-1775468411468-13970111.avif', 'active', '2026-04-06 09:40:11', '2026-04-06 09:40:11');

-- Dumping structure for table insta_style_lms.post_media
CREATE TABLE IF NOT EXISTS `post_media` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `media_type` enum('image','video','gif','youtube','wbt') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_media_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~0 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`, `thumbnail_url`, `created_at`) VALUES
	(1, 1, 'image', '/uploads/posts/1/media/media-1775560390434-104687468.avif', '/uploads/posts/1/thumbnails/thumb-1775560390434-104687468.jpeg', '2026-04-07 11:13:10'),
	(2, 1, 'video', '/uploads/posts/1/media/media-1775560390439-7343781.mp4', '/uploads/posts/1/thumbnails/thumb-1775560390439-7343781.jpeg', '2026-04-07 11:13:10'),
	(3, 1, 'wbt', '/uploads/posts/1/wbt/wbt-1775560390442-368929299/story.html', '/uploads/posts/1/thumbnails/thumb-1775560390442-368929299.jpeg', '2026-04-07 11:13:11'),
	(4, 1, 'youtube', 'https://www.youtube.com/watch?v=n_ewkN4SPTg', 'https://img.youtube.com/vi/n_ewkN4SPTg/maxresdefault.jpg', '2026-04-07 11:13:11'),
	(5, 1, 'youtube', 'https://www.youtube.com/watch?v=n_ewkN4SPTg', 'https://img.youtube.com/vi/n_ewkN4SPTg/maxresdefault.jpg', '2026-04-07 11:13:11');

-- Dumping structure for table insta_style_lms.posts
CREATE TABLE IF NOT EXISTS `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `hashtags` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.posts: ~0 rows (approximately)
INSERT INTO `posts` (`id`, `category_id`, `title`, `content`, `hashtags`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 'MicroLearning', 'MicroLearning', '#MicroLearning #JK Tyre', 'active', '2026-04-07 11:13:10', '2026-04-07 11:13:10');

-- Dumping structure for table insta_style_lms.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_email` (`email`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.users: ~0 rows (approximately)
INSERT INTO `users` (`id`, `email`, `employee_id`, `name`, `password`, `role`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'jasmeet.singh@sls-india.com', 'EMP001', 'Jasmeet', '$2b$12$ftUqFbPXYKVb8YvoAhv48./decnV3m2eSzxSLP7A5B6wydLwsj5aG', 'DSE', 'active', '2026-04-06 06:30:05', '2026-04-06 06:30:05');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
