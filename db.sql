-- --------------------------------------------------------
-- Host:                         192.168.10.72
-- Server version:               8.0.43 - MySQL Community Server - GPL
-- Server OS:                    Linux
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.categories: ~5 rows (approximately)
INSERT INTO `categories` (`id`, `name`, `icon_url`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Product', '/uploads/category/1/icon-1775728660466-890754222.svg', 'active', '2026-04-09 09:57:40', '2026-04-09 09:57:40'),
	(2, 'Process', '/uploads/category/2/icon-1775730548438-315653422.svg', 'active', '2026-04-09 10:29:08', '2026-04-09 10:29:08'),
	(3, 'Technology', '/uploads/category/3/icon-1775730588754-706962643.svg', 'active', '2026-04-09 10:29:48', '2026-04-09 10:29:48'),
	(4, 'BAT', '/uploads/category/4/icon-1775730607174-102396582.svg', 'active', '2026-04-09 10:30:07', '2026-04-09 10:30:07'),
	(5, 'Soft Skills', '/uploads/category/5/icon-1775730629357-684959557.svg', 'active', '2026-04-09 10:30:29', '2026-04-09 10:30:29');

-- Dumping structure for table insta_style_lms.post_bookmarks
CREATE TABLE IF NOT EXISTS `post_bookmarks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_bookmark` (`post_id`,`user_id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_bookmarks_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_bookmarks_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_bookmarks: ~2 rows (approximately)
INSERT INTO `post_bookmarks` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(1, 1, 2, '2026-04-09 06:48:19'),
	(2, 1, 1, '2026-04-09 06:49:04');

-- Dumping structure for table insta_style_lms.post_comments
CREATE TABLE IF NOT EXISTS `post_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `comment_text` text NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `post_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_comments: ~3 rows (approximately)
INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `comment_text`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 2, 'Very informative.', 'active', '2026-04-09 06:24:31', '2026-04-09 06:24:31'),
	(2, 1, 1, 'great post!', 'active', '2026-04-09 06:26:07', '2026-04-09 06:26:07'),
	(3, 1, 1, 'Very informative.', 'active', '2026-04-09 06:26:20', '2026-04-09 06:26:20');

-- Dumping structure for table insta_style_lms.post_likes
CREATE TABLE IF NOT EXISTS `post_likes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_like` (`post_id`,`user_id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `post_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_likes: ~2 rows (approximately)
INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(1, 1, 1, '2026-04-09 06:12:51'),
	(2, 1, 2, '2026-04-09 06:14:55');

-- Dumping structure for table insta_style_lms.post_media
CREATE TABLE IF NOT EXISTS `post_media` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `media_type` enum('image','video','gif','youtube','wbt','pdf','ppt') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_media_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~22 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`, `thumbnail_url`, `created_at`) VALUES
	(1, 1, 'image', '/uploads/posts/1/media/1/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/1/media/1/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-09 05:16:40'),
	(2, 1, 'video', '/uploads/posts/1/media/2/E-BLAZE_EV_Tyre_Video_Comp_7-11-25.mp4', '/uploads/posts/1/media/2/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-04-09 05:16:40'),
	(3, 2, 'image', '/uploads/posts/2/media/3/life_at_jk_page_3a591463b2.png', '/uploads/posts/2/media/3/thumb_life_at_jk_page_3a591463b2.png', '2026-04-09 05:18:48'),
	(4, 2, 'video', '/uploads/posts/2/media/4/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/2/media/4/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-04-09 05:18:48'),
	(5, 3, 'image', '/uploads/posts/3/media/5/farm_tractor_trolley_54c9074369.png', '/uploads/posts/3/media/5/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-09 05:20:55'),
	(6, 3, 'video', '/uploads/posts/3/media/6/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/3/media/6/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.avif', '2026-04-09 05:20:55'),
	(7, 4, 'video', '/uploads/posts/4/media/7/JK_Tyre_Micro_Learning_01_-_Tyre_Construction.mp4', '/uploads/posts/4/media/7/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-04-09 05:23:20'),
	(8, 5, 'ppt', '/uploads/posts/5/media/8/SCV_-_Instructor_material_-_BAT_ver2.0_29-05-2015.pptx', '/uploads/posts/5/media/8/thumb_SCV_-_Instructor_material_-_BAT_ver2.0_29-05-2015.png', '2026-04-09 05:24:44'),
	(9, 6, 'image', '/uploads/posts/6/media/9/Service_Advisor_Training_CPI.webp', '/uploads/posts/6/media/9/thumb_Service_Advisor_Training_CPI.webp', '2026-04-09 05:26:45'),
	(10, 6, 'image', '/uploads/posts/6/media/10/images.jpg', '/uploads/posts/6/media/10/thumb_images.jpg', '2026-04-09 05:26:45'),
	(11, 7, 'image', '/uploads/posts/7/media/11/image_6487327-copy.jpg', '/uploads/posts/7/media/11/thumb_image_6487327-copy.jpg', '2026-04-09 05:30:45'),
	(12, 8, 'image', '/uploads/posts/8/media/12/image_6487327-copy.jpg', '/uploads/posts/8/media/12/thumb_image_6487327-copy.jpg', '2026-04-09 05:34:23'),
	(13, 8, 'youtube', 'https://www.youtube.com/watch?v=n_ewkN4SPTg&t=46s', 'https://img.youtube.com/vi/n_ewkN4SPTg/maxresdefault.jpg', '2026-04-09 05:34:23'),
	(14, 9, 'image', '/uploads/posts/9/media/14/JK_Tyre_Blaze-Rydr-Tyre-for-Premium-Motorcycles-750x375.webp', '/uploads/posts/9/media/14/thumb_JK_Tyre_Blaze-Rydr-Tyre-for-Premium-Motorcycles-750x375.webp', '2026-04-09 05:36:20'),
	(15, 9, 'youtube', 'https://www.youtube.com/watch?v=aMstMFkpRiQ', 'https://img.youtube.com/vi/aMstMFkpRiQ/maxresdefault.jpg', '2026-04-09 05:36:20'),
	(16, 10, 'wbt', '/uploads/posts/10/media/16/extracted/story.html', '/uploads/posts/10/media/16/thumb_SLS_LMS.jpg', '2026-04-09 05:37:26'),
	(17, 11, 'wbt', '/uploads/posts/11/media/17/extracted/story.html', '/uploads/posts/11/media/17/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-04-09 05:37:56'),
	(18, 12, 'image', '/uploads/posts/12/media/18/p1.jpg', '/uploads/posts/12/media/18/thumb_p1.jpg', '2026-04-09 10:25:40'),
	(19, 12, 'image', '/uploads/posts/12/media/19/p2.jpg', '/uploads/posts/12/media/19/thumb_p2.jpg', '2026-04-09 10:25:40'),
	(20, 12, 'image', '/uploads/posts/12/media/20/p3.jpg', '/uploads/posts/12/media/20/thumb_p3.jpg', '2026-04-09 10:25:40'),
	(21, 12, 'image', '/uploads/posts/12/media/21/p4.jpg', '/uploads/posts/12/media/21/thumb_p4.jpg', '2026-04-09 10:25:40'),
	(22, 12, 'image', '/uploads/posts/12/media/22/p5.jpg', '/uploads/posts/12/media/22/thumb_p5.jpg', '2026-04-09 10:25:40');

-- Dumping structure for table insta_style_lms.post_shares
CREATE TABLE IF NOT EXISTS `post_shares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL COMMENT 'User who is sharing the post',
  `share_id` int NOT NULL COMMENT 'User ID of the person the post is shared with',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `share_id` (`share_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `post_shares_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_shares_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_shares_ibfk_3` FOREIGN KEY (`share_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_shares: ~2 rows (approximately)
INSERT INTO `post_shares` (`id`, `post_id`, `user_id`, `share_id`, `status`, `created_at`) VALUES
	(1, 1, 1, 2, 'active', '2026-04-09 07:32:38'),
	(2, 1, 1, 3, 'active', '2026-04-09 07:33:14');

-- Dumping structure for table insta_style_lms.post_views
CREATE TABLE IF NOT EXISTS `post_views` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `viewed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_view` (`post_id`,`user_id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_viewed_at` (`viewed_at`),
  CONSTRAINT `post_views_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_views_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_views: ~2 rows (approximately)
INSERT INTO `post_views` (`id`, `post_id`, `user_id`, `viewed_at`) VALUES
	(1, 1, 1, '2026-04-09 06:40:37'),
	(2, 1, 2, '2026-04-09 06:41:33');

-- Dumping structure for table insta_style_lms.posts
CREATE TABLE IF NOT EXISTS `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `hashtags` text,
  `likes_count` int NOT NULL DEFAULT '0',
  `comments_count` int NOT NULL DEFAULT '0',
  `views_count` int NOT NULL DEFAULT '0',
  `shares_count` int NOT NULL DEFAULT '0',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.posts: ~12 rows (approximately)
INSERT INTO `posts` (`id`, `category_id`, `title`, `content`, `hashtags`, `likes_count`, `comments_count`, `views_count`, `shares_count`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 'E-BLAZE_EV Tyre', 'E-BLAZE_EV Tyre', '#E-BLAZE #Tyre', 2, 3, 2, 2, 'active', '2026-04-09 05:16:40', '2026-04-09 07:33:14'),
	(2, 2, 'JK Tyre Dealer Onboarding Process', 'JK Tyre Dealer Onboarding Process', '#JK Tyre #Dealer Onboarding Process', 0, 0, 0, 0, 'active', '2026-04-09 05:18:48', '2026-04-09 05:19:27'),
	(3, 1, 'Farm Tyre', 'Farm Tyre', '#Farm Tyre', 0, 0, 0, 0, 'active', '2026-04-09 05:20:55', '2026-04-09 05:20:55'),
	(4, 1, 'JK Tyre Micro Learning', 'JK Tyre Micro Learning 01 - Tyre Construction', '#MicroLearning #JK Tyre', 0, 0, 0, 0, 'active', '2026-04-09 05:23:20', '2026-04-09 05:23:20'),
	(5, 4, 'SCV - Instructor material - BAT', 'SCV - Instructor material - BAT', '#BAT #SCV - Instructor material', 0, 0, 0, 0, 'active', '2026-04-09 05:24:44', '2026-04-09 05:24:44'),
	(6, 5, 'Soft Skills', 'Soft Skills', '#Soft Skills', 0, 0, 0, 0, 'active', '2026-04-09 05:26:45', '2026-04-09 10:32:12'),
	(7, 3, 'Ventilated Seat', 'Ventilated Seat', '#Ventilated Seat', 0, 0, 0, 0, 'active', '2026-04-09 05:30:45', '2026-04-09 05:33:10'),
	(8, 3, 'Ventilated Seat Shorts', 'Ventilated Seat', '#Ventilated Seat', 0, 0, 0, 0, 'active', '2026-04-09 05:34:23', '2026-04-09 10:32:21'),
	(9, 1, 'E-BLAZE Youtube Shorts', 'E-BLAZE Youtube Shorts', '#E-BLAZE', 0, 0, 0, 0, 'active', '2026-04-09 05:36:20', '2026-04-09 05:36:46'),
	(10, 2, 'WBT Training Module1', 'This is an interactive WBT training module', '#WBT #Training #Learning', 0, 0, 0, 0, 'active', '2026-04-09 05:37:26', '2026-04-09 05:37:26'),
	(11, 2, 'WBT Training Module2', 'This is an interactive WBT training module', '#WBT #Training #Learning', 0, 0, 0, 0, 'active', '2026-04-09 05:37:56', '2026-04-09 05:37:56'),
	(12, 1, 'Maruti Suzuki Cars', 'Maruti Suzuki Cars', '#Maruti Suzuki', 0, 0, 0, 0, 'active', '2026-04-09 10:25:40', '2026-04-09 10:25:40');

-- Dumping structure for table insta_style_lms.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` enum('android','ios') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.users: ~3 rows (approximately)
INSERT INTO `users` (`id`, `email`, `employee_id`, `name`, `phone`, `gender`, `password`, `profile_url`, `fcm_token`, `device_type`, `role`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'demo@sls.com', 'EMP001', 'Keshav_Goyal', '8282828282', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', '/uploads/users/1/profile-1775713806692.jpg', 'fcm_token_xyz_123_abc', NULL, 'DSE', 'active', '2026-04-09 05:50:06', '2026-04-09 09:30:02'),
	(2, 'demo@sls2.com', 'EMP002', 'Neeraj Jain', '8989898989', 'male', '$2b$12$QBXiSY0OPhBa9qV8f48MzuRvUwqsl67/Sb1mjCjKsvlcszd5nvAQa', '/uploads/users/2/profile-1775713867244.jpg', NULL, NULL, 'PSE', 'active', '2026-04-09 05:51:07', '2026-04-09 05:51:07'),
	(3, 'demo@sls3.com', 'EMP003', 'Ravi Pandey', '8181818181', 'male', '$2b$12$PNRO6eNla8CKqp4prVXoT.QNjB8ULGi/u0dc2N1Wo1wP7U8OsFlKi', '/uploads/users/3/profile-1775713939921.jpg', NULL, NULL, 'SNE', 'active', '2026-04-09 05:52:19', '2026-04-09 05:52:19');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
