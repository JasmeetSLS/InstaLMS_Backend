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
	(1, 'All', '/uploads/category/1/All.png', 'active', '2026-04-09 09:57:40', '2026-04-16 11:02:03'),
	(2, 'Product', '/uploads/category/2/Products.png', 'active', '2026-04-09 10:29:08', '2026-04-16 11:02:10'),
	(3, 'Process', '/uploads/category/3/Process.png', 'active', '2026-04-09 10:29:48', '2026-04-16 11:02:18'),
	(4, 'BAT', '/uploads/category/4/Bat.png', 'active', '2026-04-09 10:30:07', '2026-04-16 11:04:43'),
	(5, 'Soft Skills', '/uploads/category/5/Soft-Skills.png', 'active', '2026-04-09 10:30:29', '2026-04-16 10:57:37');

-- Dumping structure for table insta_style_lms.comments
CREATE TABLE IF NOT EXISTS `comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comment` text NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.comments: ~8 rows (approximately)
INSERT INTO `comments` (`id`, `comment`, `status`, `created_at`) VALUES
	(1, 'Very informative', 'active', '2026-04-15 06:46:36'),
	(2, 'Great content', 'active', '2026-04-15 06:46:36'),
	(3, 'Thanks for sharing', 'active', '2026-04-15 06:46:36'),
	(4, 'Well explained', 'active', '2026-04-15 06:46:36'),
	(5, 'Helpful post', 'active', '2026-04-15 06:46:36'),
	(6, 'Nice information', 'active', '2026-04-15 06:46:36'),
	(7, 'Awesome', 'active', '2026-04-15 06:46:36'),
	(8, 'Keep it up', 'active', '2026-04-15 06:46:36');

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_bookmarks: ~3 rows (approximately)
INSERT INTO `post_bookmarks` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(2, 1, 1, '2026-04-09 06:49:04'),
	(3, 3, 2, '2026-04-09 11:13:46'),
	(4, 1, 2, '2026-04-20 06:31:38');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_comments: ~5 rows (approximately)
INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `comment_text`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 2, 'Very informative.', 'active', '2026-04-09 06:24:31', '2026-04-09 06:24:31'),
	(2, 1, 1, 'great post!', 'active', '2026-04-09 06:26:07', '2026-04-09 06:26:07'),
	(3, 1, 1, 'Very informative.', 'active', '2026-04-09 06:26:20', '2026-04-09 06:26:20'),
	(4, 2, 2, 'Very informative.', 'active', '2026-04-09 11:12:30', '2026-04-09 11:12:30'),
	(5, 5, 2, 'Helpful post', 'active', '2026-04-16 05:53:13', '2026-04-16 05:53:13');

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_likes: ~2 rows (approximately)
INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(1, 1, 1, '2026-04-09 06:12:51'),
	(4, 1, 2, '2026-04-20 06:30:47');

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
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~86 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`, `thumbnail_url`, `created_at`) VALUES
	(1, 1, 'image', '/uploads/posts/1/media/1/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/1/media/1/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-09 05:16:40'),
	(2, 1, 'video', '/uploads/posts/1/media/2/E-BLAZE_EV_Tyre_Video_Comp_7-11-25.mp4', '/uploads/posts/1/media/2/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-04-09 05:16:40'),
	(3, 2, 'image', '/uploads/posts/2/media/3/life_at_jk_page_3a591463b2.png', '/uploads/posts/2/media/3/thumb_life_at_jk_page_3a591463b2.png', '2026-04-09 05:18:48'),
	(4, 2, 'video', '/uploads/posts/2/media/4/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/2/media/4/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-04-09 05:18:48'),
	(5, 3, 'image', '/uploads/posts/3/media/5/farm_tractor_trolley_54c9074369.png', '/uploads/posts/3/media/5/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-09 05:20:55'),
	(6, 3, 'video', '/uploads/posts/3/media/6/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/3/media/6/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.avif', '2026-04-09 05:20:55'),
	(7, 4, 'video', '/uploads/posts/4/media/7/JK_Tyre_Micro_Learning_01_-_Tyre_Construction.mp4', '/uploads/posts/4/media/7/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-04-09 05:23:20'),
	(8, 5, 'pdf', '/uploads/posts/5/media/8/SCV.pdf', '/uploads/posts/5/media/8/thumb_SCV_-_Instructor_material_-_BAT_ver2.0_29-05-2015.png', '2026-04-09 05:24:44'),
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
	(22, 12, 'image', '/uploads/posts/12/media/22/p5.jpg', '/uploads/posts/12/media/22/thumb_p5.jpg', '2026-04-09 10:25:40'),
	(23, 13, 'youtube', 'https://www.youtube.com/watch?v=4NMo4o3CJ7Q', 'https://img.youtube.com/vi/4NMo4o3CJ7Q/maxresdefault.jpg', '2026-04-13 07:32:37'),
	(24, 14, 'youtube', 'https://www.youtube.com/watch?v=fPjOWekzeGI', 'https://img.youtube.com/vi/fPjOWekzeGI/maxresdefault.jpg', '2026-04-13 07:35:30'),
	(25, 15, 'image', '/uploads/posts/15/media/25/p4.jpg', '/uploads/posts/15/media/25/thumb_p4.jpg', '2026-04-15 11:53:07'),
	(26, 15, 'image', '/uploads/posts/15/media/26/p3.jpg', '/uploads/posts/15/media/26/thumb_p3.jpg', '2026-04-15 11:53:07'),
	(27, 15, 'image', '/uploads/posts/15/media/27/p2.jpg', '/uploads/posts/15/media/27/thumb_p2.jpg', '2026-04-15 11:53:07'),
	(28, 16, 'video', '/uploads/posts/16/media/28/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/16/media/28/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-04-15 11:55:34'),
	(29, 16, 'image', '/uploads/posts/16/media/29/p3.jpg', '/uploads/posts/16/media/29/thumb_p3.png', '2026-04-15 11:55:34'),
	(30, 17, 'image', '/uploads/posts/17/media/30/farm_tractor_trolley_54c9074369.png', '/uploads/posts/17/media/30/thumb_farm_tractor_trolley_54c9074369.avif', '2026-04-15 11:56:53'),
	(31, 17, 'video', '/uploads/posts/17/media/31/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/17/media/31/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.png', '2026-04-15 11:56:53'),
	(32, 18, 'pdf', '/uploads/posts/18/media/32/sample.pdf', '/uploads/posts/18/media/32/thumb_sample.webp', '2026-04-15 11:58:47'),
	(33, 18, 'image', '/uploads/posts/18/media/33/images.jpg', '/uploads/posts/18/media/33/thumb_images.webp', '2026-04-15 11:58:47'),
	(34, 19, 'wbt', '/uploads/posts/19/media/34/extracted/story.html', '/uploads/posts/19/media/34/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-04-15 12:00:25'),
	(35, 19, 'image', '/uploads/posts/19/media/35/image_6487327-copy.jpg', '/uploads/posts/19/media/35/thumb_image_6487327-copy.jpg', '2026-04-15 12:00:25'),
	(36, 20, 'image', '/uploads/posts/20/media/36/p5.jpg', '/uploads/posts/20/media/36/thumb_p5.jpg', '2026-04-15 12:16:11'),
	(37, 20, 'image', '/uploads/posts/20/media/37/p4.jpg', '/uploads/posts/20/media/37/thumb_p4.jpg', '2026-04-15 12:16:11'),
	(38, 21, 'image', '/uploads/posts/21/media/38/p5.jpg', '/uploads/posts/21/media/38/thumb_p5.jpg', '2026-04-15 12:16:18'),
	(39, 21, 'image', '/uploads/posts/21/media/39/p4.jpg', '/uploads/posts/21/media/39/thumb_p4.jpg', '2026-04-15 12:16:18'),
	(40, 22, 'image', '/uploads/posts/22/media/40/p5.jpg', '/uploads/posts/22/media/40/thumb_p5.jpg', '2026-04-15 12:16:23'),
	(41, 22, 'image', '/uploads/posts/22/media/41/p4.jpg', '/uploads/posts/22/media/41/thumb_p4.jpg', '2026-04-15 12:16:23'),
	(42, 23, 'image', '/uploads/posts/23/media/42/p5.jpg', '/uploads/posts/23/media/42/thumb_p5.jpg', '2026-04-15 12:16:34'),
	(43, 23, 'image', '/uploads/posts/23/media/43/p4.jpg', '/uploads/posts/23/media/43/thumb_p4.jpg', '2026-04-15 12:16:34'),
	(44, 24, 'video', '/uploads/posts/24/media/44/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/24/media/44/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:18:47'),
	(45, 24, 'image', '/uploads/posts/24/media/45/p5.jpg', '/uploads/posts/24/media/45/thumb_p5.jpg', '2026-04-15 12:18:47'),
	(46, 25, 'video', '/uploads/posts/25/media/46/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/25/media/46/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:01'),
	(47, 25, 'image', '/uploads/posts/25/media/47/p5.jpg', '/uploads/posts/25/media/47/thumb_p5.jpg', '2026-04-15 12:19:01'),
	(48, 26, 'video', '/uploads/posts/26/media/48/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/26/media/48/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:14'),
	(49, 26, 'image', '/uploads/posts/26/media/49/p5.jpg', '/uploads/posts/26/media/49/thumb_p5.jpg', '2026-04-15 12:19:14'),
	(50, 27, 'video', '/uploads/posts/27/media/50/SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.mp4', '/uploads/posts/27/media/50/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:29'),
	(51, 27, 'image', '/uploads/posts/27/media/51/p5.jpg', '/uploads/posts/27/media/51/thumb_p5.jpg', '2026-04-15 12:19:29'),
	(52, 28, 'image', '/uploads/posts/28/media/52/car-sales_1d8acd.avif', '/uploads/posts/28/media/52/thumb_car-sales_1d8acd.avif', '2026-04-16 06:47:09'),
	(53, 28, 'image', '/uploads/posts/28/media/53/images_1_.jpg', '/uploads/posts/28/media/53/thumb_images_1_.jpg', '2026-04-16 06:47:09'),
	(54, 29, 'image', '/uploads/posts/29/media/54/infographics0.avif', '/uploads/posts/29/media/54/thumb_infographics0.avif', '2026-04-16 06:49:32'),
	(55, 29, 'pdf', '/uploads/posts/29/media/55/certificate_undefined_Sample_Assessment_attempt_1.pdf', '/uploads/posts/29/media/55/thumb_certificate_undefined_Sample_Assessment_attempt_1.avif', '2026-04-16 06:49:32'),
	(56, 30, 'wbt', '/uploads/posts/30/media/56/extracted/story.html', '/uploads/posts/30/media/56/thumb_SLS_LMS.jpg', '2026-04-16 06:51:39'),
	(57, 31, 'image', '/uploads/posts/31/media/57/Service_Advisor_Training_CPI.webp', '/uploads/posts/31/media/57/thumb_Service_Advisor_Training_CPI.webp', '2026-04-16 06:54:43'),
	(58, 31, 'image', '/uploads/posts/31/media/58/images.jpg', '/uploads/posts/31/media/58/thumb_images.jpg', '2026-04-16 06:54:43'),
	(59, 31, 'youtube', 'https://www.youtube.com/shorts/cwoVEnafd6A', 'https://img.youtube.com/vi/cwoVEnafd6A/maxresdefault.jpg', '2026-04-16 06:54:43'),
	(60, 32, 'image', '/uploads/posts/32/media/60/p2.jpg', '/uploads/posts/32/media/60/thumb_p2.jpg', '2026-04-16 06:57:04'),
	(61, 32, 'image', '/uploads/posts/32/media/61/p1.jpg', '/uploads/posts/32/media/61/thumb_p1.jpg', '2026-04-16 06:57:04'),
	(62, 33, 'image', '/uploads/posts/33/media/62/AutoMobiles.avif', '/uploads/posts/33/media/62/thumb_AutoMobiles.avif', '2026-04-16 07:01:23'),
	(63, 33, 'image', '/uploads/posts/33/media/63/farm_tractor_trolley_54c9074369.png', '/uploads/posts/33/media/63/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-16 07:01:23'),
	(64, 34, 'image', '/uploads/posts/34/media/64/image_870x580_67653903cb44e.jpg', '/uploads/posts/34/media/64/thumb_image_870x580_67653903cb44e.jpg', '2026-04-16 07:15:26'),
	(65, 34, 'video', '/uploads/posts/34/media/65/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/34/media/65/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 07:15:26'),
	(66, 35, 'image', '/uploads/posts/35/media/66/row-cars_83_1_0.jpg', '/uploads/posts/35/media/66/thumb_row-cars_83_1_0.jpg', '2026-04-16 07:18:12'),
	(67, 35, 'image', '/uploads/posts/35/media/67/images.jpg', '/uploads/posts/35/media/67/thumb_images.jpg', '2026-04-16 07:18:12'),
	(68, 35, 'image', '/uploads/posts/35/media/68/car-sales_1d8acd.avif', '/uploads/posts/35/media/68/thumb_car-sales_1d8acd.avif', '2026-04-16 07:18:12'),
	(69, 36, 'image', '/uploads/posts/36/media/69/image_870x580_67653903cb44e.jpg', '/uploads/posts/36/media/69/thumb_image_870x580_67653903cb44e.jpg', '2026-04-16 07:18:41'),
	(70, 36, 'video', '/uploads/posts/36/media/70/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/36/media/70/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 07:18:41'),
	(71, 37, 'image', '/uploads/posts/37/media/71/p2.jpg', '/uploads/posts/37/media/71/thumb_p2.jpg', '2026-04-16 10:21:46'),
	(72, 37, 'pdf', '/uploads/posts/37/media/72/sample.pdf', '/uploads/posts/37/media/72/thumb_sample.jpg', '2026-04-16 10:21:46'),
	(73, 38, 'image', '/uploads/posts/38/media/73/front-left-side-47.avif', '/uploads/posts/38/media/73/thumb_front-left-side-47.avif', '2026-04-16 10:24:28'),
	(74, 38, 'image', '/uploads/posts/38/media/74/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/38/media/74/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-16 10:24:28'),
	(75, 39, 'video', '/uploads/posts/39/media/75/E-BLAZE_EV_Tyre_Video_Comp_7-11-25.mp4', '/uploads/posts/39/media/75/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-04-16 10:25:36'),
	(76, 39, 'image', '/uploads/posts/39/media/76/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/39/media/76/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-16 10:25:36'),
	(77, 40, 'image', '/uploads/posts/40/media/77/images.jpg', '/uploads/posts/40/media/77/thumb_images.jpg', '2026-04-16 10:29:34'),
	(78, 40, 'image', '/uploads/posts/40/media/78/Service_Advisor_Training_CPI.webp', '/uploads/posts/40/media/78/thumb_Service_Advisor_Training_CPI.webp', '2026-04-16 10:29:34'),
	(79, 40, 'image', '/uploads/posts/40/media/79/images.jpg', '/uploads/posts/40/media/79/thumb_images.jpg', '2026-04-16 10:29:34'),
	(80, 41, 'wbt', '/uploads/posts/41/media/80/extracted/story.html', '/uploads/posts/41/media/80/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-04-16 10:31:24'),
	(81, 42, 'image', '/uploads/posts/42/media/81/farm_tractor_trolley_54c9074369.png', '/uploads/posts/42/media/81/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-16 10:34:16'),
	(82, 42, 'youtube', 'https://www.youtube.com/shorts/KCqMBVaT9g0', 'https://img.youtube.com/vi/KCqMBVaT9g0/maxresdefault.jpg', '2026-04-16 10:34:16'),
	(83, 43, 'image', '/uploads/posts/43/media/83/image_870x580_67653903cb44e.jpg', '/uploads/posts/43/media/83/thumb_image_870x580_67653903cb44e.jpg', '2026-04-16 10:36:25'),
	(84, 43, 'video', '/uploads/posts/43/media/84/JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.mp4', '/uploads/posts/43/media/84/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 10:36:25'),
	(85, 44, 'image', '/uploads/posts/44/media/85/image_6487327-copy.jpg', '/uploads/posts/44/media/85/thumb_image_6487327-copy.jpg', '2026-04-16 10:37:48'),
	(86, 44, 'youtube', 'https://www.youtube.com/shorts/VTU0UXZmfeQ', 'https://img.youtube.com/vi/VTU0UXZmfeQ/maxresdefault.jpg', '2026-04-16 10:37:48');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_shares: ~5 rows (approximately)
INSERT INTO `post_shares` (`id`, `post_id`, `user_id`, `share_id`, `status`, `created_at`) VALUES
	(1, 1, 1, 2, 'active', '2026-04-09 07:32:38'),
	(2, 1, 1, 3, 'active', '2026-04-09 07:33:14'),
	(3, 1, 2, 3, 'active', '2026-04-09 11:14:01'),
	(4, 1, 2, 3, 'active', '2026-04-09 11:14:07'),
	(5, 6, 1, 2, 'active', '2026-04-15 07:26:27');

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
	(2, 1, 2, '2026-04-09 11:13:24');

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
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.posts: ~44 rows (approximately)
INSERT INTO `posts` (`id`, `category_id`, `title`, `content`, `hashtags`, `likes_count`, `comments_count`, `views_count`, `shares_count`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 'E-BLAZE_EV Tyre', 'E-BLAZE_EV Tyre', '#E-BLAZE #Tyre', 2, 3, 2, 4, 'active', '2026-04-09 05:16:40', '2026-04-20 06:30:47'),
	(2, 3, 'JK Tyre Dealer Onboarding Process', 'JK Tyre Dealer Onboarding Process', '#JK Tyre #Dealer Onboarding Process', 0, 1, 0, 0, 'active', '2026-04-09 05:18:48', '2026-04-13 05:15:14'),
	(3, 2, 'Farm Tyre', 'Farm Tyre', '#Farm Tyre', 0, 0, 0, 0, 'active', '2026-04-09 05:20:55', '2026-04-13 05:15:24'),
	(4, 2, 'JK Tyre Micro Learning', 'JK Tyre Micro Learning 01 - Tyre Construction', '#MicroLearning #JK Tyre', 0, 0, 0, 0, 'active', '2026-04-09 05:23:20', '2026-04-13 05:15:28'),
	(5, 4, 'SCV - Instructor material - BAT', 'SCV - Instructor material - BAT', '#BAT #SCV - Instructor material', 0, 1, 0, 0, 'active', '2026-04-09 05:24:44', '2026-04-20 05:48:21'),
	(6, 5, 'Soft Skills', 'Soft Skills', '#Soft Skills', 0, 0, 0, 1, 'active', '2026-04-09 05:26:45', '2026-04-15 07:26:27'),
	(7, 2, 'Ventilated Seat', 'Ventilated Seat', '#Ventilated Seat', 0, 0, 0, 0, 'active', '2026-04-09 05:30:45', '2026-04-13 05:14:47'),
	(8, 2, 'Ventilated Seat Shorts', 'Ventilated Seat', '#Ventilated Seat', 0, 0, 0, 0, 'active', '2026-04-09 05:34:23', '2026-04-13 05:14:51'),
	(9, 2, 'E-BLAZE Youtube Shorts', 'E-BLAZE Youtube Shorts', '#E-BLAZE', 0, 0, 0, 0, 'active', '2026-04-09 05:36:20', '2026-04-13 05:15:34'),
	(10, 3, 'WBT Training Module1', 'This is an interactive WBT training module', '#WBT #Training #Learning', 0, 0, 0, 0, 'active', '2026-04-09 05:37:26', '2026-04-13 05:14:58'),
	(11, 3, 'WBT Training Module2', 'This is an interactive WBT training module', '#WBT #Training #Learning', 0, 0, 0, 0, 'active', '2026-04-09 05:37:56', '2026-04-13 05:15:00'),
	(12, 2, 'Maruti Suzuki Cars', 'Maruti Suzuki Cars', '#Maruti Suzuki', 0, 0, 0, 0, 'active', '2026-04-09 10:25:40', '2026-04-13 05:15:39'),
	(13, 5, 'Soft Skills -2 ', 'Soft Skills -2 ', '#Soft Skills', 0, 0, 0, 0, 'active', '2026-04-13 07:32:37', '2026-04-13 10:35:03'),
	(14, 4, 'BAT', 'BAT', '#BAT', 0, 0, 0, 0, 'active', '2026-04-13 07:35:30', '2026-04-13 10:40:43'),
	(15, 2, 'Testing1', 'This is Testing1 description', '#test,#testing1', 0, 0, 0, 0, 'active', '2026-04-15 11:53:07', '2026-04-15 11:53:07'),
	(16, 2, 'Testing2', 'This is Testing2 description', '#test,#testing2', 0, 0, 0, 0, 'active', '2026-04-15 11:55:34', '2026-04-15 11:58:33'),
	(17, 2, 'Testing3', 'This is Testing3 description', '#test,#testing3', 0, 0, 0, 0, 'active', '2026-04-15 11:56:53', '2026-04-15 11:58:37'),
	(18, 2, 'Testing4', 'This is Testing4 description', '#test,#testing4', 0, 0, 0, 0, 'active', '2026-04-15 11:58:47', '2026-04-15 11:58:47'),
	(19, 2, 'Testing5', 'This is Testing5 description', '#test,#testing5', 0, 0, 0, 0, 'active', '2026-04-15 12:00:25', '2026-04-15 12:00:25'),
	(20, 2, 'Testing6', 'This is Testing6 description', '#test,#testing6', 0, 0, 0, 0, 'active', '2026-04-15 12:16:11', '2026-04-15 12:16:11'),
	(21, 3, 'Testing6', 'This is Testing6 description', '#test,#testing6', 0, 0, 0, 0, 'active', '2026-04-15 12:16:18', '2026-04-15 12:16:18'),
	(22, 4, 'Testing6', 'This is Testing6 description', '#test,#testing6', 0, 0, 0, 0, 'active', '2026-04-15 12:16:23', '2026-04-15 12:16:23'),
	(23, 5, 'Testing6', 'This is Testing6 description', '#test,#testing6', 0, 0, 0, 0, 'active', '2026-04-15 12:16:34', '2026-04-15 12:16:34'),
	(24, 2, 'Testing7', 'This is Testing7 description', '#test,#testing7', 0, 0, 0, 0, 'active', '2026-04-15 12:18:47', '2026-04-15 12:18:47'),
	(25, 3, 'Testing7', 'This is Testing7 description', '#test,#testing7', 0, 0, 0, 0, 'active', '2026-04-15 12:19:01', '2026-04-15 12:19:01'),
	(26, 4, 'Testing7', 'This is Testing7 description', '#test,#testing7', 0, 0, 0, 0, 'active', '2026-04-15 12:19:14', '2026-04-15 12:19:14'),
	(27, 5, 'Testing7', 'This is Testing7 description', '#test,#testing7', 0, 0, 0, 0, 'active', '2026-04-15 12:19:29', '2026-04-15 12:19:29'),
	(28, 2, 'Testing8', 'Testing8', '#Testing8', 0, 0, 0, 0, 'active', '2026-04-16 06:47:09', '2026-04-16 06:47:37'),
	(29, 2, 'Testing9', 'Testing9', '#Testing9', 0, 0, 0, 0, 'active', '2026-04-16 06:49:32', '2026-04-16 06:49:32'),
	(30, 2, 'Testing10', 'Testing10', '#Testing10', 0, 0, 0, 0, 'active', '2026-04-16 06:51:39', '2026-04-16 06:51:39'),
	(31, 2, 'Testing11', 'Testing11', '#Testing11', 0, 0, 0, 0, 'active', '2026-04-16 06:54:43', '2026-04-16 06:54:43'),
	(32, 2, 'Testing12', 'Testing12', '#Testing12', 0, 0, 0, 0, 'active', '2026-04-16 06:57:04', '2026-04-16 06:57:04'),
	(33, 2, 'Testing13', 'Testing13', '#Testing13', 0, 0, 0, 0, 'active', '2026-04-16 07:01:23', '2026-04-16 07:01:23'),
	(34, 2, 'Testing14', 'Testing14', '#test,#testing14', 0, 0, 0, 0, 'active', '2026-04-16 07:15:26', '2026-04-16 07:15:26'),
	(35, 2, 'Testing15', 'Testing15', '#Test#Testing15', 0, 0, 0, 0, 'active', '2026-04-16 07:18:12', '2026-04-16 07:18:12'),
	(36, 2, 'Testing16', 'Testing16', '#test,#Testing16', 0, 0, 0, 0, 'active', '2026-04-16 07:18:41', '2026-04-16 07:19:22'),
	(37, 3, 'Testing1', 'Testing1', '#Testing1', 0, 0, 0, 0, 'active', '2026-04-16 10:21:46', '2026-04-16 10:21:46'),
	(38, 3, 'Testing2', 'Testing2', '#Testing2', 0, 0, 0, 0, 'active', '2026-04-16 10:24:28', '2026-04-16 10:24:28'),
	(39, 3, 'Testing3', 'Testing3', '#Test#Testing3', 0, 0, 0, 0, 'active', '2026-04-16 10:25:36', '2026-04-16 10:25:36'),
	(40, 3, 'Testing4', 'Testing4', '#Testing4', 0, 0, 0, 0, 'active', '2026-04-16 10:29:34', '2026-04-16 10:29:34'),
	(41, 3, 'Testing5', 'Testing5', '#Test#Testing5', 0, 0, 0, 0, 'active', '2026-04-16 10:31:24', '2026-04-16 10:31:24'),
	(42, 3, 'Testing8', 'Testing8', '#Testing8', 0, 0, 0, 0, 'active', '2026-04-16 10:34:16', '2026-04-16 10:34:16'),
	(43, 3, 'Testing9', 'Testing9', '#test,#testing9', 0, 0, 0, 0, 'active', '2026-04-16 10:36:25', '2026-04-16 10:36:25'),
	(44, 3, 'Testing10', 'Testing10', '#Test#Testing10', 0, 0, 0, 0, 'active', '2026-04-16 10:37:48', '2026-04-16 10:37:48');

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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.users: ~7 rows (approximately)
INSERT INTO `users` (`id`, `email`, `employee_id`, `name`, `phone`, `gender`, `password`, `profile_url`, `fcm_token`, `device_type`, `role`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'demo@sls.com', 'EMP001', 'Keshav_Goyal', '8282828282', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', '/uploads/users/1/profile-1775713806692.jpg', 'fcm_token_xyz_123_abc', 'ios', 'DSE', 'active', '2026-04-09 05:50:06', '2026-04-20 05:38:23'),
	(2, 'demo@sls2.com', 'EMP002', 'Neeraj Jain', '8989898989', 'male', '$2b$12$QBXiSY0OPhBa9qV8f48MzuRvUwqsl67/Sb1mjCjKsvlcszd5nvAQa', '/uploads/users/2/profile-1775713867244.jpg', 'fcm_token_xyz_123_abc', 'android', 'PSE', 'active', '2026-04-09 05:51:07', '2026-04-09 10:50:22'),
	(3, 'demo@sls3.com', 'EMP003', 'Ravi Pandey', '8181818181', 'male', '$2b$12$PNRO6eNla8CKqp4prVXoT.QNjB8ULGi/u0dc2N1Wo1wP7U8OsFlKi', '/uploads/users/3/profile-1775713939921.jpg', 'fcm_token_xyz_123_abc', 'android', 'SNE', 'active', '2026-04-09 05:52:19', '2026-04-09 10:49:50'),
	(4, 'demo@sls4.com', 'EMP004', 'Subhojit', '9876543210', 'male', '$2b$12$Jig.kclv.RbH2wwxgm48rOC32nnuyFWSxkoHHIy5kA3xX0xseY3pC', '/uploads/users/4/profile-1776246467383.jpg', NULL, NULL, 'DFM', 'active', '2026-04-15 09:47:47', '2026-04-15 09:47:47'),
	(5, 'demo@sls5.com', 'EMP005', 'Pradeep Kumar', '9876543291', 'male', '$2b$12$UUNeVsUpZytLAKhajq36Ce0l6OwWmwO3.hiHp2j0VwKsrcmJfjSIS', '/uploads/users/5/profile-1776246576012.jpg', NULL, NULL, 'DHSE', 'active', '2026-04-15 09:49:36', '2026-04-15 09:49:36'),
	(6, 'demo@sls6.com', 'EMP006', 'Anil Kumawat', '9234897684', 'male', '$2b$12$uRpsPxHFAXtBGSSeSJAO8uCNAqaebvW.09HTHrS.8UPtcEiNF.zlq', '/uploads/users/6/profile-1776246747079.jpg', NULL, NULL, 'PSE', 'active', '2026-04-15 09:52:27', '2026-04-15 09:52:27'),
	(7, 'demo@sls7.com', 'EMP007', 'Dheeraj', '9994328902', 'male', '$2b$12$TCdpZGJ7fK8os0EDuR60Y.GnPPK9L33XZNRlM4vbLFEfSO2w7./pW', '/uploads/users/7/profile-1776246864430.jpg', NULL, NULL, 'DSE', 'active', '2026-04-15 09:54:24', '2026-04-15 09:54:24');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
