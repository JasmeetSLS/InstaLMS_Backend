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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.categories: ~10 rows (approximately)
INSERT INTO `categories` (`id`, `name`, `icon_url`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'All', '/uploads/category/1/All.png', 'active', '2026-04-09 09:57:40', '2026-04-16 11:02:03'),
	(2, 'Product', '/uploads/category/2/Products.png', 'active', '2026-04-09 10:29:08', '2026-04-16 11:02:10'),
	(3, 'Process', '/uploads/category/3/Process.png', 'active', '2026-04-09 10:29:48', '2026-04-16 11:02:18'),
	(4, 'BAT', '/uploads/category/4/Bat.png', 'active', '2026-04-09 10:30:07', '2026-04-16 11:04:43'),
	(5, 'Soft Skills', '/uploads/category/5/Soft-Skills.png', 'active', '2026-04-09 10:30:29', '2026-04-16 10:57:37'),
	(6, 'Sales', '/uploads/category/1/All.png', 'active', '2026-04-21 04:30:00', '2026-04-21 04:30:00'),
	(7, 'Management', '/uploads/category/2/Products.png', 'active', '2026-04-21 04:30:00', '2026-04-21 04:30:00'),
	(8, 'Communication', '/uploads/category/3/Process.png', 'active', '2026-04-21 04:30:00', '2026-04-21 04:30:00'),
	(9, 'Leadership', '/uploads/category/4/Bat.png', 'active', '2026-04-21 04:30:00', '2026-04-21 04:30:00'),
	(10, 'Technical', '/uploads/category/5/Soft-Skills.png', 'active', '2026-04-21 04:30:00', '2026-04-21 04:30:00');

-- Dumping structure for table insta_style_lms.cities
CREATE TABLE IF NOT EXISTS `cities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealer_id` int NOT NULL,
  `city_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_dealer_id` (`dealer_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_cities_dealer_id` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.cities: ~7 rows (approximately)
INSERT INTO `cities` (`id`, `dealer_id`, `city_name`, `state`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Mumbai ', 'maharashtra', 'active', '2026-06-14 07:35:18', '2026-06-17 07:06:44'),
	(2, 1, 'Pune ', 'maharashtra', 'active', '2026-06-14 07:35:18', '2026-06-17 07:06:51'),
	(3, 2, 'Delhi', 'Delhi', 'active', '2026-06-14 07:35:18', '2026-06-14 07:35:18'),
	(4, 2, 'Noida', 'Uttar Pradesh', 'active', '2026-06-14 07:35:18', '2026-06-14 07:35:18'),
	(5, 3, 'Bangalore', 'Karnataka', 'active', '2026-06-14 07:35:18', '2026-06-14 07:35:18'),
	(6, 4, 'Kolkata', 'West Bengal', 'active', '2026-06-14 07:35:18', '2026-06-14 07:35:18'),
	(7, 5, 'Chennai', 'Tamil Nadu', 'active', '2026-06-14 07:35:18', '2026-06-14 07:35:18');

-- Dumping structure for table insta_style_lms.cms_categories
CREATE TABLE IF NOT EXISTS `cms_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `content` longtext,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_categories: ~6 rows (approximately)
INSERT INTO `cms_categories` (`id`, `title`, `icon_url`, `content`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Product Training', 'category1.png', 'Product learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(2, 'Sales Training', 'category2.png', 'Sales learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(3, 'Technical Training', 'category3.png', 'Technical learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(4, 'Leadership Training', 'category4.png', 'Leadership learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(5, 'Announcements', 'category5.png', 'Company announcements and updates', 'active', '2026-06-18 11:33:39', '2026-06-18 11:33:39'),
	(6, 'Business Engagement', 'category6.png', 'Business engagement learning materials', 'active', '2026-06-22 05:03:05', '2026-06-22 05:07:54');

-- Dumping structure for table insta_style_lms.cms_content_images
CREATE TABLE IF NOT EXISTS `cms_content_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_id` int NOT NULL,
  `image_url` varchar(1000) NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_content_id` (`content_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_cms_content_images_content` FOREIGN KEY (`content_id`) REFERENCES `cms_contents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_content_images: ~4 rows (approximately)
INSERT INTO `cms_content_images` (`id`, `content_id`, `image_url`, `sort_order`, `created_at`) VALUES
	(1, 1, '/uploads/cmscontent/1/slide_0_1782714928925_Chetak_C30_RACINGRED1777551678.avif', 0, '2026-06-29 06:34:53'),
	(2, 1, '/uploads/cmscontent/1/slide_2_1782714928928_exterior_bajaj-chetak_front-left-view_930x620_v3.jpeg', 2, '2026-06-29 06:34:53'),
	(14, 8, '/uploads/cmscontent/8/slide_0_1782970947180_cng-freedom-125-right-side-view-2.webp', 0, '2026-07-02 05:42:27'),
	(15, 8, '/uploads/cmscontent/8/slide_2_1782970947178_ebony-black-bajaj-pulsar-150-neo-11562960918aqcrhcozk1.avif', 2, '2026-07-02 05:42:27');

-- Dumping structure for table insta_style_lms.cms_content_text
CREATE TABLE IF NOT EXISTS `cms_content_text` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_id` int NOT NULL,
  `text_content` longtext NOT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_content_id` (`content_id`),
  KEY `idx_sort_order` (`sort_order`),
  CONSTRAINT `fk_cms_content_text_content` FOREIGN KEY (`content_id`) REFERENCES `cms_contents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_content_text: ~3 rows (approximately)
INSERT INTO `cms_content_text` (`id`, `content_id`, `text_content`, `sort_order`, `created_at`) VALUES
	(1, 1, 'Lorem', 1, '2026-06-29 06:34:53'),
	(2, 1, 'Lorem', 3, '2026-06-29 06:35:28'),
	(18, 8, 'Lorem', 1, '2026-07-02 05:42:27');

-- Dumping structure for table insta_style_lms.cms_contents
CREATE TABLE IF NOT EXISTS `cms_contents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `content_type` enum('video','pdf_extract','url_extract','multiple_image_text') NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `media_url` varchar(1000) DEFAULT NULL,
  `thumbnail_url` varchar(1000) DEFAULT NULL,
  `pdf_url` varchar(1000) DEFAULT NULL,
  `pdf_text` longtext,
  `source_url` varchar(1000) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_content_section` (`section_id`),
  CONSTRAINT `fk_content_section` FOREIGN KEY (`section_id`) REFERENCES `cms_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_contents: ~5 rows (approximately)
INSERT INTO `cms_contents` (`id`, `section_id`, `content_type`, `title`, `description`, `media_url`, `thumbnail_url`, `pdf_url`, `pdf_text`, `source_url`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'multiple_image_text', 'Lorem Lorem', 'Lorem', NULL, 'http://localhost:5000/uploads/cmscontent/1/slide_0_1782714928925_Chetak_C30_RACINGRED1777551678.avif', NULL, NULL, NULL, 'active', 0, '2026-06-29 06:34:53', '2026-07-21 09:04:55'),
	(2, 1, 'video', 'Lorem', 'Lorem', '/uploads/cmscontent/2/video_1782715031457_Recording_2026-05-05_100455.mp4', NULL, NULL, NULL, NULL, 'active', 0, '2026-06-29 06:36:48', '2026-06-29 06:37:11'),
	(3, 1, 'pdf_extract', 'Lorem', 'Lorem', NULL, NULL, '/uploads/cmscontent/3/sample.pdf', 'Sample PDF\r\nThis is a simple PDF file. Fun fun fun.\r\nLorem ipsum dolor sit amet, consectetuer adipiscing elit. Phasellus facilisis odio sed mi.\r\nCurabitur suscipit. Nullam vel nisi. Etiam semper ipsum ut lectus. Proin aliquam, erat eget\r\npharetra commodo, eros mi condimentum quam, sed commodo justo quam ut velit.\r\nInteger a erat. Cras laoreet ligula cursus enim. Aenean scelerisque velit et tellus.\r\nVestibulum dictum aliquet sem. Nulla facilisi. Vestibulum accumsan ante vitae elit. Nulla\r\nerat dolor, blandit in, rutrum quis, semper pulvinar, enim. Nullam varius congue risus.\r\nVivamus sollicitudin, metus ut interdum eleifend, nisi tellus pellentesque elit, tristique\r\naccumsan eros quam et risus. Suspendisse libero odio, mattis sit amet, aliquet eget,\r\nhendrerit vel, nulla. Sed vitae augue. Aliquam erat volutpat. Aliquam feugiat vulputate nisl.\r\nSuspendisse quis nulla pretium ante pretium mollis. Proin velit ligula, sagittis at, egestas a,\r\npulvinar quis, nisl.\r\nPellentesque sit amet lectus. Praesent pulvinar, nunc quis iaculis sagittis, justo quam\r\nlobortis tortor, sed vestibulum dui metus venenatis est. Nunc cursus ligula. Nulla facilisi.\r\nPhasellus ullamcorper consectetuer ante. Duis tincidunt, urna id condimentum luctus, nibh\r\nante vulputate sapien, id sagittis massa orci ut enim. Pellentesque vestibulum convallis\r\nsem. Nulla consequat quam ut nisl. Nullam est. Curabitur tincidunt dapibus lorem. Proin\r\nvelit turpis, scelerisque sit amet, iaculis nec, rhoncus ac, ipsum. Phasellus lorem arcu,\r\nfeugiat eu, gravida eu, consequat molestie, ipsum. Nullam vel est ut ipsum volutpat\r\nfeugiat. Aenean pellentesque.\r\n\r\nIn mauris. Pellentesque dui nisi, iaculis eu, rhoncus in, venenatis ac, ante. Ut odio justo,\r\nscelerisque vel, facilisis non, commodo a, pede. Cras nec massa sit amet tortor volutpat\r\nvarius. Donec lacinia, neque a luctus aliquet, pede massa imperdiet ante, at varius lorem\r\npede sed sapien. Fusce erat nibh, aliquet in, eleifend eget, commodo eget, erat. Fusce\r\nconsectetuer. Cras risus tortor, porttitor nec, tristique sed, convallis semper, eros. Fusce\r\nvulputate ipsum a mauris. Phasellus mollis. Curabitur sed urna. Aliquam nec sapien non\r\nnibh pulvinar convallis. Vivamus facilisis augue quis quam. Proin cursus aliquet metus.\r\nSuspendisse lacinia. Nulla at tellus ac turpis eleifend scelerisque. Maecenas a pede vitae\r\nenim commodo interdum. Donec odio. Sed sollicitudin dui vitae justo.\r\nMorbi elit nunc, facilisis a, mollis a, molestie at, lectus. Suspendisse eget mauris eu tellus\r\nmolestie cursus. Duis ut magna at justo dignissim condimentum. Cum sociis natoque\r\npenatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus varius. Ut sit\r\namet diam suscipit mauris ornare aliquam. Sed varius. Duis arcu. Etiam tristique massa\r\neget dui. Phasellus congue. Aenean est erat, tincidunt eget, venenatis quis, commodo at,\r\nquam.', NULL, 'active', 0, '2026-06-29 06:38:31', '2026-07-21 09:03:11'),
	(4, 1, 'url_extract', 'Lorem', 'Lorem', NULL, NULL, NULL, NULL, 'https://www.youtube.com/embed/MSHuhtbvITA?si=QmPzcOnZ2WRzHuB3', 'active', 0, '2026-06-29 06:39:18', '2026-06-29 06:39:34'),
	(8, 1, 'multiple_image_text', 'Lorem', 'Lorem', NULL, '/uploads/cmscontent/8/slide_0_1782970947178_ebony-black-bajaj-pulsar-150-neo-11562960918aqcrhcozk1_(1).png', NULL, NULL, NULL, 'active', 0, '2026-07-02 05:42:27', '2026-07-13 05:38:30');

-- Dumping structure for table insta_style_lms.cms_fill_blanks
CREATE TABLE IF NOT EXISTS `cms_fill_blanks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `answer` varchar(500) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_fill_blanks_question` (`question_id`),
  CONSTRAINT `fk_fill_blanks_question` FOREIGN KEY (`question_id`) REFERENCES `cms_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_fill_blanks: ~1 rows (approximately)
INSERT INTO `cms_fill_blanks` (`id`, `question_id`, `answer`, `created_at`) VALUES
	(1, 2, 'Ride Modes', '2026-06-29 09:36:43');

-- Dumping structure for table insta_style_lms.cms_match_following
CREATE TABLE IF NOT EXISTS `cms_match_following` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `left_text` varchar(500) NOT NULL,
  `right_text` varchar(500) NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_match_following_question` (`question_id`),
  CONSTRAINT `fk_match_following_question` FOREIGN KEY (`question_id`) REFERENCES `cms_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_match_following: ~4 rows (approximately)
INSERT INTO `cms_match_following` (`id`, `question_id`, `left_text`, `right_text`, `sort_order`, `created_at`) VALUES
	(1, 6, 'Ride Modes', 'Displays ride information', 0, '2026-06-29 09:47:41'),
	(2, 6, 'Dual-Channel ABS', 'Improves braking safety', 1, '2026-06-29 09:47:41'),
	(3, 6, 'LCD Digital Console', 'Adapts the motorcycle to different riding conditions', 2, '2026-06-29 09:47:41'),
	(4, 6, 'LED Headlamp', 'Provides better visibility at night', 3, '2026-06-29 09:47:41');

-- Dumping structure for table insta_style_lms.cms_options
CREATE TABLE IF NOT EXISTS `cms_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `option_text` varchar(1000) NOT NULL,
  `is_correct` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_option_question` (`question_id`),
  CONSTRAINT `fk_option_question` FOREIGN KEY (`question_id`) REFERENCES `cms_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_options: ~8 rows (approximately)
INSERT INTO `cms_options` (`id`, `question_id`, `option_text`, `is_correct`, `sort_order`, `created_at`) VALUES
	(1, 1, 'Cruise Control', 0, 0, '2026-06-29 09:36:08'),
	(2, 1, 'Ride Modes', 1, 1, '2026-06-29 09:36:08'),
	(3, 1, 'Kick Starter', 0, 2, '2026-06-29 09:36:08'),
	(4, 1, 'Manual Choke', 0, 3, '2026-06-29 09:36:08'),
	(9, 7, 'Ride Modes', 1, 0, '2026-06-29 09:50:33'),
	(10, 7, 'Kick Starter', 0, 1, '2026-06-29 09:50:33'),
	(11, 8, 'True', 1, 0, '2026-06-29 09:52:00'),
	(12, 8, 'False', 0, 1, '2026-06-29 09:52:00');

-- Dumping structure for table insta_style_lms.cms_order_following
CREATE TABLE IF NOT EXISTS `cms_order_following` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `item_text` varchar(500) NOT NULL,
  `correct_position` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_order_following_question` (`question_id`),
  CONSTRAINT `fk_order_following_question` FOREIGN KEY (`question_id`) REFERENCES `cms_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_order_following: ~4 rows (approximately)
INSERT INTO `cms_order_following` (`id`, `question_id`, `item_text`, `correct_position`, `created_at`) VALUES
	(1, 3, 'Wear your helmet and riding gear.', 1, '2026-06-29 09:38:43'),
	(2, 3, 'Turn the ignition ON.', 2, '2026-06-29 09:38:43'),
	(3, 3, 'Start the engine.', 3, '2026-06-29 09:38:43'),
	(4, 3, 'Engage first gear and ride.', 4, '2026-06-29 09:38:43');

-- Dumping structure for table insta_style_lms.cms_pages
CREATE TABLE IF NOT EXISTS `cms_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_status` (`status`),
  KEY `idx_title` (`title`),
  KEY `idx_image_url` (`image_url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.cms_pages: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.cms_questions
CREATE TABLE IF NOT EXISTS `cms_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `question_text` longtext NOT NULL,
  `question_type` enum('mcq','match_following','fill_blank','order_following','true_false','this_or_that') NOT NULL,
  `marks` int DEFAULT '1',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_question_section` (`section_id`),
  CONSTRAINT `fk_question_section` FOREIGN KEY (`section_id`) REFERENCES `cms_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_questions: ~6 rows (approximately)
INSERT INTO `cms_questions` (`id`, `section_id`, `question_text`, `question_type`, `marks`, `sort_order`, `created_at`) VALUES
	(1, 1, 'Which feature of the Pulsar NS400Z helps riders switch between different riding conditions?', 'mcq', 1, 0, '2026-06-29 09:36:08'),
	(2, 1, 'The Pulsar NS400Z offers multiple __________ to suit different riding conditions.', 'fill_blank', 1, 0, '2026-06-29 09:36:43'),
	(3, 1, 'Arrange the steps to start riding the Pulsar NS400Z in the correct order:', 'order_following', 1, 0, '2026-06-29 09:38:43'),
	(6, 1, 'Match the Pulsar NS400Z Features with Their Functions', 'match_following', 1, 0, '2026-06-29 09:47:41'),
	(7, 1, 'Which feature is available on the Pulsar NS400Z?', 'this_or_that', 1, 0, '2026-06-29 09:50:33'),
	(8, 1, 'The Pulsar NS400Z comes equipped with multiple Ride Modes for different riding conditions.', 'true_false', 1, 0, '2026-06-29 09:52:00');

-- Dumping structure for table insta_style_lms.cms_sections
CREATE TABLE IF NOT EXISTS `cms_sections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `stream_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_section_stream` (`stream_id`),
  CONSTRAINT `fk_section_stream` FOREIGN KEY (`stream_id`) REFERENCES `cms_streams` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_sections: ~5 rows (approximately)
INSERT INTO `cms_sections` (`id`, `stream_id`, `title`, `description`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Pulsar 220F - Introduction', 'Pulsar 220 F', 'active', 0, '2026-06-18 09:34:30', '2026-06-29 10:50:32'),
	(3, 1, 'Pulsar 220F - Color & Specifications', 'Pulsar 220F', 'active', 0, '2026-06-22 06:24:40', '2026-06-29 10:50:33'),
	(4, 1, 'Pulsar 220F - Design', 'Pulsar 220F', 'active', 0, '2026-06-22 06:25:27', '2026-06-29 10:50:35'),
	(5, 1, 'Pulsar 220F - Digital Instrument', 'Pulsar 220 F', 'active', 0, '2026-06-25 06:34:24', '2026-06-29 10:50:42'),
	(7, 1, 'Elevator Pitch', 'Pulsar 220F', 'active', 0, '2026-06-29 10:49:52', '2026-06-29 10:50:39');

-- Dumping structure for table insta_style_lms.cms_streams
CREATE TABLE IF NOT EXISTS `cms_streams` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `language` varchar(100) DEFAULT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `content` longtext,
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_stream_category` (`category_id`),
  CONSTRAINT `fk_stream_category` FOREIGN KEY (`category_id`) REFERENCES `cms_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_streams: ~5 rows (approximately)
INSERT INTO `cms_streams` (`id`, `category_id`, `title`, `language`, `icon_url`, `content`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, '(Old) Mastering the Pulsar 220F', 'English', '/uploads/cmsstream/1/1.avif', 'Master the iconic Pulsar 220F', 'active', 0, '2026-06-18 09:34:23', '2026-06-26 11:14:53'),
	(2, 1, '(Old) Inside the Chetak Range', 'English', '/uploads/cmsstream/2/2.avif', 'Discover the Chetak legacy', 'active', 0, '2026-06-22 05:38:06', '2026-07-21 07:28:35'),
	(3, 1, '(Old) Pulsar 150 Smart Cluster Mastery', 'English', '/uploads/cmsstream/3/3.avif', 'Learn the Smart Cluster features', 'active', 0, '2026-06-22 05:45:11', '2026-06-22 05:56:21'),
	(4, 1, 'Mastering Freedom 125', 'English', '/uploads/cmsstream/4/4.webp', 'Explore Freedom 125 features', 'active', 0, '2026-06-22 05:48:22', '2026-07-21 07:30:36'),
	(5, 1, 'Mastering the Pulsar NS400Z', 'English', '/uploads/cmsstream/5/5.jpg', 'Discover its features and performance', 'active', 0, '2026-06-29 07:11:58', '2026-07-21 07:31:39');

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

-- Dumping structure for table insta_style_lms.curriculum_posts
CREATE TABLE IF NOT EXISTS `curriculum_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `curriculum_id` int NOT NULL,
  `post_id` int NOT NULL,
  `level` enum('1','2','3') NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `curriculum_id` (`curriculum_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `curriculum_posts_ibfk_1` FOREIGN KEY (`curriculum_id`) REFERENCES `curriculums` (`id`) ON DELETE CASCADE,
  CONSTRAINT `curriculum_posts_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.curriculum_posts: ~9 rows (approximately)
INSERT INTO `curriculum_posts` (`id`, `curriculum_id`, `post_id`, `level`, `sort_order`, `created_at`) VALUES
	(1, 1, 1, '1', 1, '2026-07-06 09:22:00'),
	(2, 1, 2, '1', 2, '2026-07-06 09:22:00'),
	(3, 1, 3, '1', 3, '2026-07-06 09:22:00'),
	(4, 1, 4, '2', 1, '2026-07-06 09:22:00'),
	(5, 1, 5, '2', 2, '2026-07-06 09:22:00'),
	(6, 1, 6, '2', 3, '2026-07-06 09:22:00'),
	(7, 1, 7, '3', 1, '2026-07-06 09:22:00'),
	(8, 1, 8, '3', 2, '2026-07-06 09:22:00'),
	(9, 1, 9, '3', 3, '2026-07-06 09:22:00');

-- Dumping structure for table insta_style_lms.curriculums
CREATE TABLE IF NOT EXISTS `curriculums` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `role_id` int NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `curriculums_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.curriculums: ~1 rows (approximately)
INSERT INTO `curriculums` (`id`, `title`, `description`, `role_id`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Sample Curriculum', 'This is a sample curriculum with three levels.', 1, 'active', '2026-07-06 09:22:00', '2026-07-06 09:22:00');

-- Dumping structure for table insta_style_lms.dealers
CREATE TABLE IF NOT EXISTS `dealers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealer_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dealer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dealer_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealer_code` (`dealer_code`),
  KEY `idx_dealer_code` (`dealer_code`),
  KEY `idx_zone` (`zone`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.dealers: ~5 rows (approximately)
INSERT INTO `dealers` (`id`, `dealer_code`, `dealer_name`, `dealer_location`, `zone`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'DLR001', 'ABC Motors', 'Mumbai, Maharashtra', 'West', 'active', '2026-05-12 06:19:09', '2026-05-12 06:19:09'),
	(2, 'DLR002', 'Shree Auto Sales', 'Delhi, NCR', 'North', 'active', '2026-05-12 06:19:09', '2026-05-12 06:19:09'),
	(3, 'DLR003', 'Sai Automobiles', 'Chennai, Tamil Nadu', 'South', 'active', '2026-05-12 06:19:09', '2026-05-12 06:19:09'),
	(4, 'DLR004', 'City Motors', 'Kolkata, West Bengal', 'East', 'active', '2026-05-12 06:19:09', '2026-05-12 06:19:09'),
	(5, 'DLR005', 'Central Auto Hub', 'Bhopal, Madhya Pradesh', 'Central', 'active', '2026-05-12 06:19:09', '2026-05-12 06:19:09');

-- Dumping structure for table insta_style_lms.languages
CREATE TABLE IF NOT EXISTS `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `code` varchar(10) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.languages: ~2 rows (approximately)
INSERT INTO `languages` (`id`, `name`, `code`, `status`, `created_at`) VALUES
	(1, 'English', 'en', 'active', '2026-07-10 07:15:44'),
	(2, 'Hindi', 'hi', 'active', '2026-07-10 07:15:44');

-- Dumping structure for table insta_style_lms.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.notifications: ~2 rows (approximately)
INSERT INTO `notifications` (`id`, `title`, `message`, `created_at`) VALUES
	(1, 'Tesing1', 'Tesing1', '2026-05-04 07:24:18'),
	(2, 'Tesing2', 'Tesing2', '2026-05-04 07:24:31');

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
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_bookmarks: ~10 rows (approximately)
INSERT INTO `post_bookmarks` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(3, 3, 2, '2026-04-09 11:13:46'),
	(4, 1, 2, '2026-04-20 06:31:38'),
	(28, 5, 1, '2026-05-12 10:40:05'),
	(30, 16, 1, '2026-05-15 09:11:11'),
	(31, 4, 1, '2026-05-15 10:29:03'),
	(32, 29, 1, '2026-05-21 06:23:43'),
	(39, 6, 5, '2026-05-29 06:38:21'),
	(40, 23, 5, '2026-05-29 06:38:35'),
	(41, 33, 1, '2026-05-29 06:40:19'),
	(43, 1, 1, '2026-06-04 07:58:28');

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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_comments: ~25 rows (approximately)
INSERT INTO `post_comments` (`id`, `post_id`, `user_id`, `comment_text`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 2, 'Very informative.', 'active', '2026-04-09 06:24:31', '2026-04-09 06:24:31'),
	(2, 1, 1, 'great post!', 'active', '2026-04-09 06:26:07', '2026-04-09 06:26:07'),
	(3, 1, 1, 'Very informative.', 'active', '2026-04-09 06:26:20', '2026-04-09 06:26:20'),
	(4, 2, 2, 'Very informative.', 'active', '2026-04-09 11:12:30', '2026-04-09 11:12:30'),
	(5, 5, 2, 'Helpful post', 'active', '2026-04-16 05:53:13', '2026-04-16 05:53:13'),
	(6, 1, 1, 'Helpful post', 'active', '2026-05-03 16:24:31', '2026-05-03 16:24:31'),
	(7, 1, 1, 'Great content', 'active', '2026-05-03 16:26:13', '2026-05-03 16:26:13'),
	(8, 1, 1, 'Awesome', 'active', '2026-05-03 16:30:05', '2026-05-03 16:30:05'),
	(9, 1, 1, 'Awesome', 'active', '2026-05-03 16:30:58', '2026-05-03 16:30:58'),
	(10, 1, 1, 'Awesome', 'active', '2026-05-03 16:32:56', '2026-05-03 16:32:56'),
	(11, 1, 1, 'Well explained', 'active', '2026-05-03 16:34:34', '2026-05-03 16:34:34'),
	(12, 2, 1, 'Thanks for sharing', 'active', '2026-05-03 16:38:01', '2026-05-03 16:38:01'),
	(13, 3, 1, 'Very informative', 'active', '2026-05-03 16:40:27', '2026-05-03 16:40:27'),
	(14, 4, 1, 'Great content', 'active', '2026-05-04 06:53:14', '2026-05-04 06:53:14'),
	(15, 5, 1, 'Well explained', 'active', '2026-05-04 06:54:24', '2026-05-04 06:54:24'),
	(16, 6, 1, 'Helpful post', 'active', '2026-05-04 10:59:48', '2026-05-04 10:59:48'),
	(17, 10, 1, 'Nice information', 'active', '2026-05-11 05:11:04', '2026-05-11 05:11:04'),
	(18, 41, 1, 'Very informative', 'active', '2026-05-12 07:26:34', '2026-05-12 07:26:34'),
	(19, 7, 1, 'Great content', 'active', '2026-05-15 06:59:32', '2026-05-15 06:59:32'),
	(20, 9, 1, 'Helpful post', 'active', '2026-05-26 04:15:17', '2026-05-26 04:15:17'),
	(21, 48, 1, 'Great content', 'active', '2026-05-27 08:02:31', '2026-05-27 08:02:31'),
	(22, 46, 1, 'Great content', 'active', '2026-05-27 08:02:45', '2026-05-27 08:02:45'),
	(23, 45, 1, 'Great content', 'active', '2026-05-27 08:03:30', '2026-05-27 08:03:30'),
	(24, 1, 3, 'Helpful post', 'active', '2026-05-29 05:45:01', '2026-05-29 05:45:01'),
	(25, 2, 5, 'Very informative', 'active', '2026-05-29 06:59:12', '2026-05-29 06:59:12');

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

-- Dumping data for table insta_style_lms.post_likes: ~1 rows (approximately)
INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(2, 3, 1, '2026-08-20 10:25:37');

-- Dumping structure for table insta_style_lms.post_media
CREATE TABLE IF NOT EXISTS `post_media` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `media_type` enum('image','video','gif','youtube','wbt','pdf','ppt') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  `role_id` int NOT NULL DEFAULT '1',
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `fk_post_media_role_id` (`role_id`),
  CONSTRAINT `fk_post_media_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `post_media_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~91 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`, `role_id`, `thumbnail_url`, `created_at`) VALUES
	(1, 1, 'image', '/uploads/posts/1/media/1/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', 1, '/uploads/posts/1/media/1/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-06-04 11:57:11'),
	(2, 1, 'video', '/uploads/posts/2/media/4/Test1.mp4', 1, '/uploads/posts/1/media/2/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-06-04 11:57:11'),
	(3, 2, 'image', '/uploads/posts/2/media/3/life_at_jk_page_3a591463b2.png', 1, '/uploads/posts/2/media/3/thumb_life_at_jk_page_3a591463b2.png', '2026-06-04 11:57:11'),
	(4, 2, 'video', '/uploads/posts/2/media/4/Test1.mp4', 1, '/uploads/posts/2/media/4/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-06-04 11:57:11'),
	(5, 3, 'image', '/uploads/posts/3/media/5/farm_tractor_trolley_54c9074369.png', 1, '/uploads/posts/3/media/5/thumb_farm_tractor_trolley_54c9074369.png', '2026-06-04 11:57:11'),
	(6, 3, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/3/media/6/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.avif', '2026-06-04 11:57:11'),
	(7, 4, 'video', '/uploads/posts/4/media/7/test3.mp4', 1, '/uploads/posts/4/media/7/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-06-04 11:57:11'),
	(8, 5, 'pdf', '/uploads/posts/5/media/8/SCV.pdf', 1, '/uploads/posts/5/media/8/thumb_SCV_-_Instructor_material_-_BAT_ver2.0_29-05-2015.png', '2026-06-04 11:57:11'),
	(9, 6, 'image', '/uploads/posts/6/media/9/Service_Advisor_Training_CPI.webp', 1, '/uploads/posts/6/media/9/thumb_Service_Advisor_Training_CPI.webp', '2026-06-04 11:57:11'),
	(10, 6, 'image', '/uploads/posts/6/media/10/images.jpg', 1, '/uploads/posts/6/media/10/thumb_images.jpg', '2026-06-04 11:57:11'),
	(11, 7, 'image', '/uploads/posts/7/media/11/image_6487327-copy.jpg', 1, '/uploads/posts/7/media/11/thumb_image_6487327-copy.jpg', '2026-06-04 11:57:11'),
	(12, 8, 'image', '/uploads/posts/8/media/12/image_6487327-copy.jpg', 1, '/uploads/posts/8/media/12/thumb_image_6487327-copy.jpg', '2026-06-04 11:57:11'),
	(13, 9, 'image', '/uploads/posts/9/media/14/JK_Tyre_Blaze-Rydr-Tyre-for-Premium-Motorcycles-750x375.webp', 1, '/uploads/posts/9/media/14/thumb_JK_Tyre_Blaze-Rydr-Tyre-for-Premium-Motorcycles-750x375.webp', '2026-06-04 11:57:11'),
	(14, 10, 'wbt', '/uploads/posts/10/media/16/extracted/story.html', 1, '/uploads/posts/10/media/16/thumb_SLS_LMS.jpg', '2026-06-04 11:57:11'),
	(15, 11, 'wbt', '/uploads/posts/11/media/17/extracted/story.html', 1, '/uploads/posts/11/media/17/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-06-04 11:57:11'),
	(16, 12, 'image', '/uploads/posts/12/media/18/p1.jpg', 1, '/uploads/posts/12/media/18/thumb_p1.jpg', '2026-06-04 11:57:11'),
	(17, 12, 'image', '/uploads/posts/12/media/19/p2.jpg', 1, '/uploads/posts/12/media/19/thumb_p2.jpg', '2026-06-04 11:57:11'),
	(18, 12, 'image', '/uploads/posts/12/media/20/p3.jpg', 1, '/uploads/posts/12/media/20/thumb_p3.jpg', '2026-06-04 11:57:11'),
	(19, 12, 'image', '/uploads/posts/12/media/21/p4.jpg', 1, '/uploads/posts/12/media/21/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(20, 12, 'image', '/uploads/posts/12/media/22/p5.jpg', 1, '/uploads/posts/12/media/22/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(21, 14, 'image', '/uploads/posts/15/media/25/p4.jpg', 1, '/uploads/posts/15/media/25/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(22, 15, 'image', '/uploads/posts/15/media/26/p3.jpg', 1, '/uploads/posts/15/media/26/thumb_p3.jpg', '2026-06-04 11:57:11'),
	(23, 15, 'image', '/uploads/posts/15/media/27/p2.jpg', 1, '/uploads/posts/15/media/27/thumb_p2.jpg', '2026-06-04 11:57:11'),
	(24, 16, 'video', '/uploads/posts/16/media/28/test3.mp4', 1, '/uploads/posts/16/media/28/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-06-04 11:57:11'),
	(25, 16, 'image', '/uploads/posts/16/media/29/p3.jpg', 1, '/uploads/posts/16/media/29/thumb_p3.png', '2026-06-04 11:57:11'),
	(26, 17, 'image', '/uploads/posts/17/media/30/farm_tractor_trolley_54c9074369.png', 1, '/uploads/posts/17/media/30/thumb_farm_tractor_trolley_54c9074369.avif', '2026-06-04 11:57:11'),
	(27, 17, 'video', '/uploads/posts/17/media/31/test4.mp4', 1, '/uploads/posts/17/media/31/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.png', '2026-06-04 11:57:11'),
	(28, 18, 'pdf', '/uploads/posts/18/media/32/sample.pdf', 1, '/uploads/posts/18/media/32/thumb_sample.webp', '2026-06-04 11:57:11'),
	(29, 18, 'image', '/uploads/posts/18/media/33/images.jpg', 1, '/uploads/posts/18/media/33/thumb_images.webp', '2026-06-04 11:57:11'),
	(30, 19, 'wbt', '/uploads/posts/19/media/34/extracted/story.html', 1, '/uploads/posts/19/media/34/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-06-04 11:57:11'),
	(31, 19, 'image', '/uploads/posts/19/media/35/image_6487327-copy.jpg', 1, '/uploads/posts/19/media/35/thumb_image_6487327-copy.jpg', '2026-06-04 11:57:11'),
	(32, 20, 'image', '/uploads/posts/20/media/36/p5.jpg', 1, '/uploads/posts/20/media/36/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(33, 20, 'image', '/uploads/posts/20/media/37/p4.jpg', 1, '/uploads/posts/20/media/37/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(34, 21, 'image', '/uploads/posts/21/media/38/p5.jpg', 1, '/uploads/posts/21/media/38/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(35, 21, 'image', '/uploads/posts/21/media/39/p4.jpg', 1, '/uploads/posts/21/media/39/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(36, 22, 'image', '/uploads/posts/22/media/40/p5.jpg', 1, '/uploads/posts/22/media/40/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(37, 22, 'image', '/uploads/posts/22/media/41/p4.jpg', 1, '/uploads/posts/22/media/41/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(38, 23, 'image', '/uploads/posts/23/media/42/p5.jpg', 1, '/uploads/posts/23/media/42/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(39, 23, 'image', '/uploads/posts/23/media/43/p4.jpg', 1, '/uploads/posts/23/media/43/thumb_p4.jpg', '2026-06-04 11:57:11'),
	(40, 24, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/24/media/44/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-06-04 11:57:11'),
	(41, 24, 'image', '/uploads/posts/24/media/45/p5.jpg', 1, '/uploads/posts/24/media/45/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(42, 25, 'video', '/uploads/posts/16/media/28/test3.mp4', 1, '/uploads/posts/25/media/46/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-06-04 11:57:11'),
	(43, 25, 'image', '/uploads/posts/25/media/47/p5.jpg', 1, '/uploads/posts/25/media/47/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(44, 26, 'video', '/uploads/posts/2/media/4/Test1.mp4', 1, '/uploads/posts/26/media/48/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-06-04 11:57:11'),
	(45, 26, 'image', '/uploads/posts/26/media/49/p5.jpg', 1, '/uploads/posts/26/media/49/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(46, 27, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/27/media/50/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-06-04 11:57:11'),
	(47, 27, 'image', '/uploads/posts/27/media/51/p5.jpg', 1, '/uploads/posts/27/media/51/thumb_p5.jpg', '2026-06-04 11:57:11'),
	(48, 28, 'image', '/uploads/posts/28/media/52/car-sales_1d8acd.avif', 1, '/uploads/posts/28/media/52/thumb_car-sales_1d8acd.avif', '2026-06-04 11:57:11'),
	(49, 28, 'image', '/uploads/posts/28/media/53/images_1_.jpg', 1, '/uploads/posts/28/media/53/thumb_images_1_.jpg', '2026-06-04 11:57:11'),
	(50, 29, 'image', '/uploads/posts/29/media/54/infographics0.avif', 1, '/uploads/posts/29/media/54/thumb_infographics0.avif', '2026-06-04 11:57:11'),
	(51, 29, 'pdf', '/uploads/posts/29/media/55/certificate_undefined_Sample_Assessment_attempt_1.pdf', 1, '/uploads/posts/29/media/55/thumb_certificate_undefined_Sample_Assessment_attempt_1.avif', '2026-06-04 11:57:11'),
	(52, 30, 'wbt', '/uploads/posts/30/media/56/extracted/story.html', 1, '/uploads/posts/30/media/56/thumb_SLS_LMS.jpg', '2026-06-04 11:57:11'),
	(53, 31, 'image', '/uploads/posts/31/media/57/Service_Advisor_Training_CPI.webp', 1, '/uploads/posts/31/media/57/thumb_Service_Advisor_Training_CPI.webp', '2026-06-04 11:57:11'),
	(54, 31, 'image', '/uploads/posts/31/media/58/images.jpg', 1, '/uploads/posts/31/media/58/thumb_images.jpg', '2026-06-04 11:57:11'),
	(55, 32, 'image', '/uploads/posts/32/media/60/p2.jpg', 1, '/uploads/posts/32/media/60/thumb_p2.jpg', '2026-06-04 11:57:11'),
	(56, 32, 'image', '/uploads/posts/32/media/61/p1.jpg', 1, '/uploads/posts/32/media/61/thumb_p1.jpg', '2026-06-04 11:57:11'),
	(57, 33, 'image', '/uploads/posts/33/media/62/AutoMobiles.avif', 1, '/uploads/posts/33/media/62/thumb_AutoMobiles.avif', '2026-06-04 11:57:11'),
	(58, 33, 'image', '/uploads/posts/33/media/63/farm_tractor_trolley_54c9074369.png', 1, '/uploads/posts/33/media/63/thumb_farm_tractor_trolley_54c9074369.png', '2026-06-04 11:57:11'),
	(59, 34, 'image', '/uploads/posts/34/media/64/image_870x580_67653903cb44e.jpg', 1, '/uploads/posts/34/media/64/thumb_image_870x580_67653903cb44e.jpg', '2026-06-04 11:57:11'),
	(60, 34, 'video', '/uploads/posts/16/media/28/test3.mp4', 1, '/uploads/posts/34/media/65/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-06-04 11:57:11'),
	(61, 35, 'image', '/uploads/posts/35/media/66/row-cars_83_1_0.jpg', 1, '/uploads/posts/35/media/66/thumb_row-cars_83_1_0.jpg', '2026-06-04 11:57:11'),
	(62, 35, 'image', '/uploads/posts/35/media/67/images.jpg', 1, '/uploads/posts/35/media/67/thumb_images.jpg', '2026-06-04 11:57:11'),
	(63, 35, 'image', '/uploads/posts/35/media/68/car-sales_1d8acd.avif', 1, '/uploads/posts/35/media/68/thumb_car-sales_1d8acd.avif', '2026-06-04 11:57:11'),
	(64, 36, 'image', '/uploads/posts/36/media/69/image_870x580_67653903cb44e.jpg', 1, '/uploads/posts/36/media/69/thumb_image_870x580_67653903cb44e.jpg', '2026-06-04 11:57:11'),
	(65, 36, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/36/media/70/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-06-04 11:57:11'),
	(66, 37, 'image', '/uploads/posts/37/media/71/p2.jpg', 1, '/uploads/posts/37/media/71/thumb_p2.jpg', '2026-06-04 11:57:11'),
	(67, 37, 'pdf', '/uploads/posts/37/media/72/sample.pdf', 1, '/uploads/posts/37/media/72/thumb_sample.jpg', '2026-06-04 11:57:11'),
	(68, 38, 'image', '/uploads/posts/38/media/73/front-left-side-47.avif', 1, '/uploads/posts/38/media/73/thumb_front-left-side-47.avif', '2026-06-04 11:57:12'),
	(69, 38, 'image', '/uploads/posts/38/media/74/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', 1, '/uploads/posts/38/media/74/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-06-04 11:57:12'),
	(70, 39, 'video', '/uploads/posts/2/media/4/Test1.mp4', 1, '/uploads/posts/39/media/75/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-06-04 11:57:12'),
	(71, 39, 'image', '/uploads/posts/39/media/76/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', 1, '/uploads/posts/39/media/76/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-06-04 11:57:12'),
	(72, 40, 'image', '/uploads/posts/40/media/77/images.jpg', 1, '/uploads/posts/40/media/77/thumb_images.jpg', '2026-06-04 11:57:12'),
	(73, 40, 'image', '/uploads/posts/40/media/78/Service_Advisor_Training_CPI.webp', 1, '/uploads/posts/40/media/78/thumb_Service_Advisor_Training_CPI.webp', '2026-06-04 11:57:12'),
	(74, 40, 'image', '/uploads/posts/40/media/79/images.jpg', 1, '/uploads/posts/40/media/79/thumb_images.jpg', '2026-06-04 11:57:12'),
	(75, 41, 'wbt', '/uploads/posts/41/media/80/extracted/story.html', 1, '/uploads/posts/41/media/80/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-06-04 11:57:12'),
	(76, 42, 'image', '/uploads/posts/42/media/81/farm_tractor_trolley_54c9074369.png', 1, '/uploads/posts/42/media/81/thumb_farm_tractor_trolley_54c9074369.png', '2026-06-04 11:57:12'),
	(77, 43, 'image', '/uploads/posts/43/media/83/image_870x580_67653903cb44e.jpg', 1, '/uploads/posts/43/media/83/thumb_image_870x580_67653903cb44e.jpg', '2026-06-04 11:57:12'),
	(78, 43, 'video', '/uploads/posts/16/media/28/test3.mp4', 1, '/uploads/posts/43/media/84/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-06-04 11:57:12'),
	(79, 44, 'image', '/uploads/posts/44/media/85/image_6487327-copy.jpg', 1, '/uploads/posts/44/media/85/thumb_image_6487327-copy.jpg', '2026-06-04 11:57:12'),
	(80, 45, 'ppt', '/uploads/posts/45/media/87/SCV_-_Instructor_material_-_BAT_ver2.0_29-05-2015.pptx', 1, '/uploads/posts/45/media/87/thumb_SCV.jpeg', '2026-06-04 11:57:12'),
	(81, 46, 'pdf', '/uploads/posts/46/media/88/certificate_1_.pdf', 1, '/uploads/posts/46/media/88/thumb_certificate_1_.jpeg', '2026-06-04 11:57:12'),
	(82, 47, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/47/media/89/thumb_Ventilated_seat_reel.jpg', '2026-06-04 11:57:12'),
	(83, 48, 'wbt', '/uploads/posts/48/media/90/extracted/story.html', 1, '/uploads/posts/48/media/90/thumb_JK_Tyre_Rural_Distribution_Assessment_1_.png', '2026-06-04 11:57:12'),
	(84, 49, 'wbt', '/uploads/posts/49/media/91/extracted/story.html', 1, '/uploads/posts/49/media/91/thumb_Hero_Ultimate_Striker_Assessment.png', '2026-06-04 11:57:12'),
	(85, 50, 'wbt', '/uploads/posts/50/media/92/extracted/story.html', 1, '/uploads/posts/50/media/92/thumb_RACE-TO-ACE.png', '2026-06-04 11:57:12'),
	(86, 52, 'image', '/uploads/posts/52/media/94/WhatsApp_Image_2026-03-24_at_2.45.02_PM.jpeg', 1, '/uploads/posts/52/media/94/thumb_WhatsApp_Image_2026-03-24_at_2.45.02_PM.jpeg', '2026-06-04 11:57:12'),
	(87, 53, 'image', '/uploads/posts/53/media/95/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', 1, '/uploads/posts/53/media/95/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-06-04 11:57:12'),
	(88, 53, 'video', '/uploads/posts/2/media/4/Test1.mp4', 1, '/uploads/posts/53/media/96/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-06-04 11:57:12'),
	(89, 54, 'video', '/uploads/posts/16/media/28/test3.mp4', 1, '/uploads/posts/54/media/97/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-06-04 11:57:12'),
	(90, 54, 'image', '/uploads/posts/54/media/98/images.jpg', 1, '/uploads/posts/54/media/98/thumb_images.webp', '2026-06-04 11:57:12'),
	(91, 55, 'video', '/uploads/posts/3/media/6/Test2.mp4', 1, '/uploads/posts/55/media/99/thumb_Ventilated_seat_reel.jpg', '2026-06-04 11:57:12');

-- Dumping structure for table insta_style_lms.post_media_views
CREATE TABLE IF NOT EXISTS `post_media_views` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `media_id` int NOT NULL,
  `user_id` int NOT NULL,
  `viewed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_media_view` (`post_id`,`media_id`,`user_id`),
  KEY `post_id` (`post_id`),
  KEY `media_id` (`media_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_viewed_at` (`viewed_at`),
  CONSTRAINT `post_media_views_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_media_views_ibfk_2` FOREIGN KEY (`media_id`) REFERENCES `post_media` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_media_views_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media_views: ~22 rows (approximately)
INSERT INTO `post_media_views` (`id`, `post_id`, `media_id`, `user_id`, `viewed_at`) VALUES
	(1, 10, 16, 12, '2026-06-17 10:19:47'),
	(2, 1, 1, 2, '2026-07-29 10:31:28'),
	(3, 1, 1, 4, '2026-08-19 06:40:17'),
	(4, 1, 1, 1, '2026-08-20 09:39:34'),
	(6, 7, 11, 1, '2026-08-20 09:46:08'),
	(7, 8, 12, 1, '2026-08-20 09:46:15'),
	(8, 9, 13, 1, '2026-08-20 09:46:22'),
	(9, 6, 9, 1, '2026-08-20 09:47:21'),
	(10, 6, 10, 1, '2026-08-20 09:47:24'),
	(11, 20, 32, 1, '2026-08-20 09:48:01'),
	(12, 20, 33, 1, '2026-08-20 09:48:02'),
	(13, 3, 6, 1, '2026-08-20 10:25:27'),
	(14, 2, 4, 1, '2026-08-20 10:55:48'),
	(15, 2, 3, 1, '2026-08-20 10:55:51'),
	(16, 38, 68, 1, '2026-08-21 05:10:37'),
	(17, 38, 69, 1, '2026-08-21 05:10:40'),
	(18, 14, 21, 1, '2026-08-21 05:11:23'),
	(19, 15, 22, 1, '2026-08-21 05:11:57'),
	(20, 15, 23, 1, '2026-08-21 05:12:00'),
	(21, 3, 5, 1, '2026-08-21 05:16:05'),
	(22, 1, 1, 8, '2026-08-21 05:17:34'),
	(23, 1, 2, 8, '2026-08-21 05:18:19');

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
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_shares: ~28 rows (approximately)
INSERT INTO `post_shares` (`id`, `post_id`, `user_id`, `share_id`, `status`, `created_at`) VALUES
	(1, 1, 1, 2, 'active', '2026-04-09 07:32:38'),
	(2, 1, 1, 3, 'active', '2026-04-09 07:33:14'),
	(3, 1, 2, 3, 'active', '2026-04-09 11:14:01'),
	(4, 1, 2, 3, 'active', '2026-04-09 11:14:07'),
	(5, 6, 1, 2, 'active', '2026-04-15 07:26:27'),
	(6, 6, 2, 1, 'active', '2026-04-27 10:14:30'),
	(7, 3, 2, 1, 'active', '2026-04-27 10:14:43'),
	(8, 6, 3, 1, 'active', '2026-04-27 10:15:22'),
	(9, 9, 3, 1, 'active', '2026-04-27 10:15:26'),
	(10, 1, 4, 1, 'active', '2026-04-27 11:19:58'),
	(11, 30, 4, 1, 'active', '2026-04-27 11:20:03'),
	(12, 25, 5, 1, 'active', '2026-04-27 11:20:34'),
	(13, 33, 5, 1, 'active', '2026-04-27 11:20:39'),
	(14, 23, 6, 1, 'active', '2026-04-27 11:21:03'),
	(15, 29, 6, 1, 'active', '2026-04-27 11:21:12'),
	(16, 1, 1, 3, 'active', '2026-05-03 17:01:20'),
	(17, 2, 1, 4, 'active', '2026-05-03 17:01:51'),
	(18, 1, 1, 3, 'active', '2026-05-03 17:02:25'),
	(19, 1, 1, 7, 'active', '2026-05-03 17:05:10'),
	(20, 9, 1, 3, 'active', '2026-05-03 17:09:03'),
	(21, 5, 1, 4, 'active', '2026-05-04 06:55:07'),
	(22, 1, 1, 7, 'active', '2026-05-04 06:56:33'),
	(23, 3, 1, 3, 'active', '2026-05-05 09:58:56'),
	(24, 1, 1, 6, 'active', '2026-05-21 09:29:18'),
	(25, 1, 1, 5, 'active', '2026-05-26 04:26:23'),
	(26, 2, 5, 2, 'active', '2026-05-29 06:58:39'),
	(27, 11, 4, 2, 'active', '2026-05-29 08:55:57'),
	(28, 7, 4, 1, 'active', '2026-05-29 09:02:46');

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
) ENGINE=InnoDB AUTO_INCREMENT=193 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_views: ~192 rows (approximately)
INSERT INTO `post_views` (`id`, `post_id`, `user_id`, `viewed_at`) VALUES
	(1, 5, 23, '2026-05-18 04:11:42'),
	(2, 5, 22, '2026-06-07 04:11:42'),
	(3, 5, 21, '2026-06-06 04:11:42'),
	(4, 5, 20, '2026-06-01 04:11:42'),
	(5, 5, 2, '2026-06-07 04:11:42'),
	(6, 5, 19, '2026-05-27 04:11:42'),
	(7, 5, 18, '2026-05-11 04:11:42'),
	(8, 5, 17, '2026-05-24 04:11:42'),
	(9, 5, 16, '2026-05-19 04:11:42'),
	(10, 5, 15, '2026-05-14 04:11:42'),
	(11, 5, 14, '2026-05-31 04:11:42'),
	(12, 5, 13, '2026-05-16 04:11:42'),
	(13, 6, 23, '2026-06-05 04:11:42'),
	(14, 6, 22, '2026-05-31 04:11:42'),
	(15, 6, 21, '2026-06-08 04:11:42'),
	(16, 6, 20, '2026-06-01 04:11:42'),
	(17, 6, 2, '2026-06-01 04:11:42'),
	(18, 6, 19, '2026-05-25 04:11:42'),
	(19, 6, 18, '2026-05-20 04:11:42'),
	(20, 6, 17, '2026-05-13 04:11:42'),
	(21, 6, 16, '2026-05-29 04:11:42'),
	(22, 6, 15, '2026-06-06 04:11:42'),
	(23, 6, 14, '2026-05-27 04:11:42'),
	(24, 6, 13, '2026-05-14 04:11:42'),
	(25, 13, 23, '2026-05-10 04:11:42'),
	(26, 13, 22, '2026-05-29 04:11:42'),
	(27, 13, 21, '2026-05-17 04:11:42'),
	(28, 13, 20, '2026-05-18 04:11:42'),
	(29, 13, 2, '2026-05-30 04:11:42'),
	(30, 13, 19, '2026-05-27 04:11:42'),
	(31, 13, 18, '2026-06-05 04:11:42'),
	(32, 13, 17, '2026-05-30 04:11:42'),
	(33, 13, 16, '2026-06-02 04:11:42'),
	(34, 13, 15, '2026-06-05 04:11:42'),
	(35, 13, 14, '2026-05-11 04:11:42'),
	(36, 13, 13, '2026-05-25 04:11:42'),
	(37, 30, 23, '2026-05-25 04:11:42'),
	(38, 30, 22, '2026-06-08 04:11:42'),
	(39, 30, 21, '2026-05-22 04:11:42'),
	(40, 30, 20, '2026-05-13 04:11:42'),
	(41, 30, 2, '2026-05-19 04:11:42'),
	(42, 30, 19, '2026-05-17 04:11:42'),
	(43, 30, 18, '2026-05-19 04:11:42'),
	(44, 30, 17, '2026-06-04 04:11:42'),
	(45, 30, 16, '2026-05-20 04:11:42'),
	(46, 30, 15, '2026-05-13 04:11:42'),
	(47, 30, 14, '2026-05-28 04:11:42'),
	(48, 30, 13, '2026-05-31 04:11:42'),
	(49, 31, 23, '2026-05-31 04:11:42'),
	(50, 31, 22, '2026-05-21 04:11:42'),
	(51, 31, 21, '2026-06-02 04:11:42'),
	(52, 31, 20, '2026-05-31 04:11:42'),
	(53, 31, 2, '2026-05-18 04:11:42'),
	(54, 31, 19, '2026-05-15 04:11:42'),
	(55, 31, 18, '2026-05-14 04:11:42'),
	(56, 31, 17, '2026-05-16 04:11:42'),
	(57, 31, 16, '2026-05-27 04:11:42'),
	(58, 31, 15, '2026-05-16 04:11:42'),
	(59, 31, 14, '2026-05-22 04:11:42'),
	(60, 31, 13, '2026-05-24 04:11:42'),
	(61, 33, 23, '2026-05-11 04:11:42'),
	(62, 33, 22, '2026-06-04 04:11:42'),
	(63, 33, 21, '2026-05-13 04:11:42'),
	(64, 33, 20, '2026-05-11 04:11:42'),
	(65, 33, 2, '2026-06-05 04:11:42'),
	(66, 33, 19, '2026-05-18 04:11:42'),
	(67, 33, 18, '2026-06-02 04:11:42'),
	(68, 33, 17, '2026-05-11 04:11:42'),
	(69, 33, 16, '2026-06-04 04:11:42'),
	(70, 33, 15, '2026-05-15 04:11:42'),
	(71, 33, 14, '2026-05-19 04:11:42'),
	(72, 33, 13, '2026-05-11 04:11:42'),
	(73, 34, 23, '2026-05-18 04:11:42'),
	(74, 34, 22, '2026-05-18 04:11:42'),
	(75, 34, 21, '2026-05-27 04:11:42'),
	(76, 34, 20, '2026-05-10 04:11:42'),
	(77, 34, 2, '2026-05-21 04:11:42'),
	(78, 34, 19, '2026-06-06 04:11:42'),
	(79, 34, 18, '2026-05-19 04:11:42'),
	(80, 34, 17, '2026-06-07 04:11:42'),
	(81, 34, 16, '2026-05-31 04:11:42'),
	(82, 34, 15, '2026-05-31 04:11:42'),
	(83, 34, 14, '2026-05-22 04:11:42'),
	(84, 34, 13, '2026-06-05 04:11:42'),
	(85, 35, 23, '2026-05-18 04:11:42'),
	(86, 35, 22, '2026-05-29 04:11:42'),
	(87, 35, 21, '2026-05-25 04:11:42'),
	(88, 35, 20, '2026-05-26 04:11:42'),
	(89, 35, 2, '2026-05-15 04:11:42'),
	(90, 35, 19, '2026-05-17 04:11:42'),
	(91, 35, 18, '2026-05-30 04:11:42'),
	(92, 35, 17, '2026-05-29 04:11:42'),
	(93, 35, 16, '2026-05-17 04:11:42'),
	(94, 35, 15, '2026-05-20 04:11:42'),
	(95, 35, 14, '2026-06-07 04:11:42'),
	(96, 35, 13, '2026-05-31 04:11:42'),
	(97, 39, 23, '2026-06-01 04:11:42'),
	(98, 39, 22, '2026-05-26 04:11:42'),
	(99, 39, 21, '2026-05-24 04:11:42'),
	(100, 39, 20, '2026-06-01 04:11:42'),
	(101, 39, 2, '2026-05-20 04:11:42'),
	(102, 39, 19, '2026-05-24 04:11:42'),
	(103, 39, 18, '2026-05-22 04:11:42'),
	(104, 39, 17, '2026-05-25 04:11:42'),
	(105, 39, 16, '2026-05-23 04:11:42'),
	(106, 39, 15, '2026-05-30 04:11:42'),
	(107, 39, 14, '2026-06-08 04:11:42'),
	(108, 39, 13, '2026-06-07 04:11:42'),
	(109, 40, 23, '2026-06-01 04:11:42'),
	(110, 40, 22, '2026-06-05 04:11:42'),
	(111, 40, 21, '2026-05-17 04:11:42'),
	(112, 40, 20, '2026-05-26 04:11:42'),
	(113, 40, 2, '2026-05-11 04:11:42'),
	(114, 40, 19, '2026-05-27 04:11:42'),
	(115, 40, 18, '2026-05-31 04:11:42'),
	(116, 40, 17, '2026-06-02 04:11:42'),
	(117, 40, 16, '2026-06-05 04:11:42'),
	(118, 40, 15, '2026-06-08 04:11:42'),
	(119, 40, 14, '2026-05-18 04:11:42'),
	(120, 40, 13, '2026-05-24 04:11:42'),
	(121, 41, 23, '2026-05-26 04:11:42'),
	(122, 41, 22, '2026-05-18 04:11:42'),
	(123, 41, 21, '2026-05-31 04:11:42'),
	(124, 41, 20, '2026-06-02 04:11:42'),
	(125, 41, 2, '2026-06-01 04:11:42'),
	(126, 41, 19, '2026-05-20 04:11:42'),
	(127, 41, 18, '2026-05-25 04:11:42'),
	(128, 41, 17, '2026-05-27 04:11:42'),
	(129, 41, 16, '2026-05-19 04:11:42'),
	(130, 41, 15, '2026-06-04 04:11:42'),
	(131, 41, 14, '2026-05-18 04:11:42'),
	(132, 41, 13, '2026-06-05 04:11:42'),
	(133, 52, 23, '2026-05-27 04:11:42'),
	(134, 52, 22, '2026-05-17 04:11:42'),
	(135, 52, 21, '2026-05-27 04:11:42'),
	(136, 52, 20, '2026-05-11 04:11:42'),
	(137, 52, 2, '2026-05-25 04:11:42'),
	(138, 52, 19, '2026-05-23 04:11:42'),
	(139, 52, 18, '2026-05-31 04:11:42'),
	(140, 52, 17, '2026-05-17 04:11:42'),
	(141, 52, 16, '2026-05-10 04:11:42'),
	(142, 52, 15, '2026-05-21 04:11:42'),
	(143, 52, 14, '2026-06-03 04:11:42'),
	(144, 52, 13, '2026-05-10 04:11:42'),
	(145, 53, 23, '2026-05-28 04:11:42'),
	(146, 53, 22, '2026-06-07 04:11:42'),
	(147, 53, 21, '2026-05-10 04:11:42'),
	(148, 53, 20, '2026-05-14 04:11:42'),
	(149, 53, 2, '2026-05-31 04:11:42'),
	(150, 53, 19, '2026-05-16 04:11:42'),
	(151, 53, 18, '2026-06-04 04:11:42'),
	(152, 53, 17, '2026-05-27 04:11:42'),
	(153, 53, 16, '2026-05-23 04:11:42'),
	(154, 53, 15, '2026-05-23 04:11:42'),
	(155, 53, 14, '2026-06-06 04:11:42'),
	(156, 53, 13, '2026-05-15 04:11:42'),
	(157, 54, 23, '2026-05-15 04:11:42'),
	(158, 54, 22, '2026-05-21 04:11:42'),
	(159, 54, 21, '2026-05-19 04:11:42'),
	(160, 54, 20, '2026-05-25 04:11:42'),
	(161, 54, 2, '2026-05-26 04:11:42'),
	(162, 54, 19, '2026-05-14 04:11:42'),
	(163, 54, 18, '2026-05-16 04:11:42'),
	(164, 54, 17, '2026-05-28 04:11:42'),
	(165, 54, 16, '2026-05-22 04:11:42'),
	(166, 54, 15, '2026-05-16 04:11:42'),
	(167, 54, 14, '2026-06-06 04:11:42'),
	(168, 54, 13, '2026-06-03 04:11:42'),
	(169, 55, 23, '2026-05-21 04:11:42'),
	(170, 55, 22, '2026-05-22 04:11:42'),
	(171, 55, 21, '2026-05-10 04:11:42'),
	(172, 55, 20, '2026-06-01 04:11:42'),
	(173, 55, 2, '2026-06-01 04:11:42'),
	(174, 55, 19, '2026-05-24 04:11:42'),
	(175, 55, 18, '2026-05-15 04:11:42'),
	(176, 55, 17, '2026-05-25 04:11:42'),
	(177, 55, 16, '2026-05-10 04:11:42'),
	(178, 55, 15, '2026-05-27 04:11:42'),
	(179, 55, 14, '2026-06-02 04:11:42'),
	(180, 55, 13, '2026-05-16 04:11:42'),
	(181, 10, 12, '2026-06-17 04:39:26'),
	(182, 7, 1, '2026-08-20 09:46:08'),
	(183, 8, 1, '2026-08-20 09:46:15'),
	(184, 9, 1, '2026-08-20 09:46:22'),
	(185, 6, 1, '2026-08-20 09:47:24'),
	(186, 20, 1, '2026-08-20 09:48:02'),
	(187, 2, 1, '2026-08-20 10:55:51'),
	(188, 38, 1, '2026-08-21 05:10:40'),
	(189, 14, 1, '2026-08-21 05:11:23'),
	(190, 15, 1, '2026-08-21 05:12:00'),
	(191, 3, 1, '2026-08-21 05:16:05'),
	(192, 1, 8, '2026-08-21 05:18:19');

-- Dumping structure for table insta_style_lms.posts
CREATE TABLE IF NOT EXISTS `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `role_id` int NOT NULL DEFAULT '1',
  `title` varchar(255) NOT NULL,
  `content` text,
  `hashtags` text,
  `thumbnail_type` enum('portrait','landscape') DEFAULT 'landscape',
  `likes_count` int NOT NULL DEFAULT '0',
  `comments_count` int NOT NULL DEFAULT '0',
  `views_count` int NOT NULL DEFAULT '0',
  `shares_count` int NOT NULL DEFAULT '0',
  `quiz_active` tinyint(1) NOT NULL DEFAULT '0',
  `my_course` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `idx_role_id` (`role_id`),
  CONSTRAINT `fk_posts_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.posts: ~54 rows (approximately)
INSERT INTO `posts` (`id`, `category_id`, `role_id`, `title`, `content`, `hashtags`, `thumbnail_type`, `likes_count`, `comments_count`, `views_count`, `shares_count`, `quiz_active`, `my_course`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 1, 'E-BLAZE_EV Tyre', 'E-BLAZE_EV Tyre', '#E-BLAZE #Tyre', 'landscape', 3, 10, 6, 11, 1, 0, 'active', '2026-04-09 05:16:40', '2026-08-21 05:18:19'),
	(2, 3, 1, 'JK Tyre Dealer Onboarding Process', 'JK Tyre Dealer Onboarding Process', '#JK Tyre #Dealer Onboarding Process', 'landscape', 2, 3, 5, 2, 1, 0, 'active', '2026-04-09 05:18:48', '2026-08-20 10:55:51'),
	(3, 2, 1, 'Farm Tyre', 'Farm Tyre', '#Farm Tyre', 'landscape', 1, 1, 5, 2, 1, 0, 'active', '2026-04-09 05:20:55', '2026-08-21 05:16:05'),
	(4, 2, 1, 'JK Tyre Micro Learning', 'JK Tyre Micro Learning 01 - Tyre Construction', '#MicroLearning #JK Tyre', 'landscape', 1, 1, 3, 0, 1, 0, 'active', '2026-04-09 05:23:20', '2026-06-11 10:23:33'),
	(5, 4, 1, 'SCV - Instructor material - BAT', 'SCV - Instructor material - BAT', '#BAT #SCV - Instructor material', 'landscape', 1, 2, 4, 1, 1, 1, 'active', '2026-04-09 05:24:44', '2026-06-11 10:23:33'),
	(6, 5, 1, 'Soft Skills', 'Soft Skills', '#Soft Skills', 'landscape', 1, 1, 4, 3, 1, 1, 'active', '2026-04-09 05:26:45', '2026-08-20 09:47:24'),
	(7, 2, 1, 'Ventilated Seat', 'Ventilated Seat', '#Ventilated Seat', 'landscape', 1, 1, 4, 1, 0, 0, 'active', '2026-04-09 05:30:45', '2026-08-20 09:46:08'),
	(8, 2, 1, 'Ventilated Seat Shorts', 'Ventilated Seat', '#Ventilated Seat', 'landscape', 1, 0, 6, 0, 0, 0, 'active', '2026-04-09 05:34:23', '2026-08-20 09:46:15'),
	(9, 2, 1, 'E-BLAZE Youtube Shorts', 'E-BLAZE Youtube Shorts', '#E-BLAZE', 'landscape', 1, 1, 4, 2, 0, 0, 'active', '2026-04-09 05:36:20', '2026-08-20 09:46:22'),
	(10, 3, 1, 'WBT Training Module1', 'This is an interactive WBT training module', '#WBT #Training #Learning', 'landscape', 2, 1, 7, 0, 0, 0, 'active', '2026-04-09 05:37:26', '2026-06-17 10:09:26'),
	(11, 3, 1, 'WBT Training Module2', 'This is an interactive WBT training module', '#WBT #Training #Learning', 'landscape', 2, 0, 5, 1, 0, 0, 'active', '2026-04-09 05:37:56', '2026-06-11 10:23:33'),
	(12, 2, 1, 'Maruti Suzuki Cars', 'Maruti Suzuki Cars', '#Maruti Suzuki', 'landscape', 1, 0, 1, 0, 0, 0, 'active', '2026-04-09 10:25:40', '2026-06-11 10:23:33'),
	(13, 5, 1, 'Soft Skills -2 ', 'Soft Skills -2 ', '#Soft Skills', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-04-13 07:32:37', '2026-06-11 10:23:33'),
	(14, 4, 1, 'BAT', 'BAT', '#BAT', 'landscape', 1, 0, 5, 0, 0, 0, 'active', '2026-04-13 07:35:30', '2026-08-21 05:11:23'),
	(15, 2, 1, 'Testing1', 'This is Testing1 description', '#test,#testing1', 'landscape', 1, 0, 4, 0, 0, 0, 'active', '2026-04-15 11:53:07', '2026-08-21 05:12:00'),
	(16, 2, 1, 'Testing2', 'This is Testing2 description', '#test,#testing2', 'landscape', 1, 0, 2, 0, 0, 0, 'active', '2026-04-15 11:55:34', '2026-06-11 10:23:33'),
	(17, 2, 1, 'Testing3', 'This is Testing3 description', '#test,#testing3', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 11:56:53', '2026-06-11 10:23:33'),
	(18, 2, 1, 'Testing4', 'This is Testing4 description', '#test,#testing4', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 11:58:47', '2026-06-11 10:23:33'),
	(19, 2, 1, 'Testing5', 'This is Testing5 description', '#test,#testing5', 'landscape', 1, 0, 4, 0, 0, 0, 'active', '2026-04-15 12:00:25', '2026-06-11 10:23:33'),
	(20, 2, 1, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-15 12:16:11', '2026-08-20 09:48:02'),
	(21, 3, 1, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 12:16:18', '2026-06-11 10:23:33'),
	(22, 4, 1, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 12:16:23', '2026-06-11 10:23:33'),
	(23, 5, 1, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 1, 0, 3, 1, 0, 0, 'active', '2026-04-15 12:16:34', '2026-06-11 10:23:33'),
	(24, 2, 1, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-15 12:18:47', '2026-06-11 10:23:33'),
	(25, 3, 1, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 3, 1, 0, 0, 'active', '2026-04-15 12:19:01', '2026-06-11 10:23:33'),
	(26, 4, 1, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-15 12:19:14', '2026-06-11 10:23:33'),
	(27, 5, 1, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-15 12:19:29', '2026-06-11 10:23:33'),
	(28, 2, 1, 'Testing8', 'Testing8', '#Testing8', 'landscape', 0, 0, 5, 0, 0, 0, 'active', '2026-04-16 06:47:09', '2026-06-11 10:23:33'),
	(29, 2, 1, 'Testing9', 'Testing9', '#Testing9', 'landscape', 1, 0, 4, 1, 0, 0, 'active', '2026-04-16 06:49:32', '2026-06-11 10:23:33'),
	(30, 2, 1, 'Testing10', 'Testing10', '#Testing10', 'landscape', 0, 0, 2, 1, 0, 1, 'active', '2026-04-16 06:51:39', '2026-06-11 10:23:33'),
	(31, 2, 1, 'Testing11', 'Testing11', '#Testing11', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-04-16 06:54:43', '2026-06-11 10:23:33'),
	(32, 2, 1, 'Testing12', 'Testing12', '#Testing12', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 06:57:04', '2026-06-11 10:23:33'),
	(33, 10, 1, 'Testing13', 'Testing13', '#Testing13', 'landscape', 1, 0, 6, 1, 0, 1, 'active', '2026-04-16 07:01:23', '2026-06-11 10:23:33'),
	(34, 10, 1, 'Testing14', 'Testing14', '#test,#testing14', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 07:15:26', '2026-06-11 10:23:33'),
	(35, 2, 1, 'Testing15', 'Testing15', '#Test#Testing15', 'landscape', 0, 0, 5, 0, 0, 1, 'active', '2026-04-16 07:18:12', '2026-06-11 10:23:33'),
	(36, 2, 1, 'Testing16', 'Testing16', '#test,#Testing16', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 07:18:41', '2026-06-11 10:23:33'),
	(37, 3, 1, 'Testing1', 'Testing1', '#Testing1', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:21:46', '2026-06-11 10:23:33'),
	(38, 3, 1, 'Testing2', 'Testing2', '#Testing2', 'landscape', 0, 0, 7, 0, 0, 0, 'active', '2026-04-16 10:24:28', '2026-08-21 05:10:40'),
	(39, 3, 1, 'Testing3', 'Testing3', '#Test#Testing3', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 10:25:36', '2026-06-11 10:23:33'),
	(40, 9, 1, 'Testing4', 'Testing4', '#Testing4', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 10:29:34', '2026-06-11 10:23:33'),
	(41, 10, 1, 'Testing5', 'Testing5', '#Test#Testing5', 'landscape', 1, 1, 8, 0, 0, 1, 'active', '2026-04-16 10:31:24', '2026-06-11 10:23:33'),
	(42, 3, 1, 'Testing8', 'Testing8', '#Testing8', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:34:16', '2026-06-11 10:23:33'),
	(43, 3, 1, 'Testing9', 'Testing9', '#test,#testing9', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-16 10:36:25', '2026-06-11 10:23:33'),
	(44, 3, 1, 'Testing10', 'Testing10', '#Test#Testing10', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:37:48', '2026-06-11 10:23:33'),
	(45, 6, 1, 'TestingPDF', 'TestingPDF', '#TestingPDF', 'portrait', 1, 1, 6, 0, 0, 0, 'active', '2026-04-21 10:24:27', '2026-06-11 10:23:33'),
	(46, 6, 1, 'TestingPDF2', 'TestingPDF2', '#TestingPDF2', 'portrait', 1, 1, 5, 0, 0, 0, 'active', '2026-04-21 10:29:45', '2026-06-11 10:23:33'),
	(47, 6, 1, 'Testing Video', 'Testing Video', '#Testing Video', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-23 04:48:28', '2026-06-11 10:23:33'),
	(48, 7, 1, 'TestingWBT', 'TestingWBT', '#TestingWBT', 'portrait', 0, 1, 8, 0, 0, 0, 'active', '2026-04-29 08:59:08', '2026-06-11 10:23:33'),
	(49, 7, 1, 'TestingWBT2', 'TestingWBT2', '#TestingWBT2', 'portrait', 0, 0, 5, 0, 0, 0, 'active', '2026-04-29 09:09:53', '2026-06-11 10:23:33'),
	(50, 7, 1, 'TestingWBT3', 'TestingWBT3', '#TestingWBT3', 'portrait', 0, 0, 3, 0, 0, 0, 'active', '2026-04-29 09:20:06', '2026-06-11 10:23:33'),
	(52, 8, 1, 'Tesing1', 'Tesing1', '#Tesing1', 'portrait', 0, 0, 2, 0, 0, 1, 'active', '2026-05-05 05:54:29', '2026-06-11 10:23:33'),
	(53, 8, 1, 'Testing2', 'Testing2', '#Testing2', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-05-05 05:55:29', '2026-06-11 10:23:33'),
	(54, 9, 1, 'Testing1', 'Testing1', '#Testing1', 'landscape', 0, 0, 3, 0, 0, 1, 'active', '2026-05-05 05:57:43', '2026-06-11 10:23:33'),
	(55, 10, 1, 'Tesing1', 'Tesing1', '#Tesing1', 'landscape', 0, 0, 3, 0, 0, 1, 'active', '2026-05-05 06:00:32', '2026-06-15 09:42:08');

-- Dumping structure for table insta_style_lms.quiz_categories
CREATE TABLE IF NOT EXISTS `quiz_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.quiz_categories: ~5 rows (approximately)
INSERT INTO `quiz_categories` (`id`, `name`, `status`, `created_at`) VALUES
	(1, 'Brand', 'active', '2026-06-08 10:00:45'),
	(2, 'BAT', 'active', '2026-06-08 10:00:45'),
	(3, 'SOP', 'active', '2026-06-08 10:00:45'),
	(4, 'soft skills', 'active', '2026-06-08 10:00:45'),
	(5, 'Product', 'active', '2026-06-08 10:00:45');

-- Dumping structure for table insta_style_lms.quiz_questions
CREATE TABLE IF NOT EXISTS `quiz_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `question_text` text NOT NULL,
  `question_media_url` varchar(500) DEFAULT NULL,
  `option_a` varchar(500) NOT NULL,
  `option_b` varchar(500) NOT NULL,
  `option_c` varchar(500) DEFAULT NULL,
  `option_d` varchar(500) DEFAULT NULL,
  `correct_option` enum('A','B','C','D') NOT NULL,
  `marks` int NOT NULL DEFAULT '1',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `idx_category_id` (`category_id`),
  CONSTRAINT `fk_quiz_questions_category` FOREIGN KEY (`category_id`) REFERENCES `quiz_categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `quiz_questions_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.quiz_questions: ~30 rows (approximately)
INSERT INTO `quiz_questions` (`id`, `post_id`, `category_id`, `question_text`, `question_media_url`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `marks`, `status`, `created_at`) VALUES
	(1, 1, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 23:53:50'),
	(2, 1, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(3, 1, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 23:53:50'),
	(4, 1, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 23:53:50'),
	(5, 1, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(6, 2, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 18:23:50'),
	(7, 2, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(8, 2, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 18:23:50'),
	(9, 2, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 18:23:50'),
	(10, 2, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(11, 3, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 18:23:50'),
	(12, 3, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(13, 3, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 18:23:50'),
	(14, 3, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 18:23:50'),
	(15, 3, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(16, 6, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 18:23:50'),
	(17, 6, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(18, 6, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 18:23:50'),
	(19, 6, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 18:23:50'),
	(20, 6, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(21, 5, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 18:23:50'),
	(22, 5, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(23, 5, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 18:23:50'),
	(24, 5, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 18:23:50'),
	(25, 5, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(26, 4, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 18:23:50'),
	(27, 4, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 18:23:50'),
	(28, 4, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 18:23:50'),
	(29, 4, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 18:23:50'),
	(30, 4, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 18:23:50');

-- Dumping structure for table insta_style_lms.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.roles: ~5 rows (approximately)
INSERT INTO `roles` (`id`, `name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'DSE', 'active', '2026-05-05 06:39:59', '2026-06-08 09:49:10'),
	(2, 'TL', 'active', '2026-05-05 06:39:59', '2026-06-08 09:49:15'),
	(3, 'RSE', 'active', '2026-05-05 06:39:59', '2026-06-08 09:49:20'),
	(4, 'DSM', 'active', '2026-05-05 06:39:59', '2026-06-08 09:49:25'),
	(5, 'GM', 'active', '2026-06-08 09:49:39', '2026-06-08 09:49:41');

-- Dumping structure for table insta_style_lms.user_daily_activity
CREATE TABLE IF NOT EXISTS `user_daily_activity` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.user_daily_activity: ~143 rows (approximately)
INSERT INTO `user_daily_activity` (`id`, `user_id`, `start_time`, `end_time`) VALUES
	(1, 2, '2026-06-16 09:22:00', '2026-06-16 18:21:00'),
	(2, 3, '2026-06-16 08:18:00', '2026-06-16 17:26:00'),
	(3, 4, '2026-06-16 08:27:00', '2026-06-16 17:52:00'),
	(4, 6, '2026-06-16 08:15:00', '2026-06-16 18:07:00'),
	(5, 7, '2026-06-16 09:46:00', '2026-06-16 18:11:00'),
	(6, 8, '2026-06-16 10:09:00', '2026-06-16 17:57:00'),
	(7, 9, '2026-06-16 09:55:00', '2026-06-16 17:18:00'),
	(8, 10, '2026-06-16 08:29:00', '2026-06-16 18:30:00'),
	(9, 11, '2026-06-16 09:11:00', '2026-06-16 17:44:00'),
	(10, 12, '2026-06-16 10:38:00', '2026-06-16 18:02:00'),
	(11, 14, '2026-06-16 10:45:00', '2026-06-16 18:41:00'),
	(12, 15, '2026-06-16 09:16:00', '2026-06-16 18:32:00'),
	(13, 17, '2026-06-16 09:41:00', '2026-06-16 18:59:00'),
	(14, 18, '2026-06-16 09:29:00', '2026-06-16 18:38:00'),
	(15, 19, '2026-06-16 08:54:00', '2026-06-16 18:27:00'),
	(16, 20, '2026-06-16 09:42:00', '2026-06-16 18:40:00'),
	(17, 21, '2026-06-16 10:49:00', '2026-06-16 18:39:00'),
	(18, 22, '2026-06-16 08:00:00', '2026-06-16 17:21:00'),
	(19, 1, '2026-06-15 09:46:00', '2026-06-15 18:23:00'),
	(20, 2, '2026-06-15 09:15:00', '2026-06-15 17:58:00'),
	(21, 3, '2026-06-15 10:30:00', '2026-06-15 18:27:00'),
	(22, 4, '2026-06-15 10:52:00', '2026-06-15 17:57:00'),
	(23, 5, '2026-06-15 09:12:00', '2026-06-15 18:51:00'),
	(24, 6, '2026-06-15 08:23:00', '2026-06-15 17:31:00'),
	(25, 7, '2026-06-15 10:33:00', '2026-06-15 17:31:00'),
	(26, 8, '2026-06-15 10:59:00', '2026-06-15 18:35:00'),
	(27, 10, '2026-06-15 10:51:00', '2026-06-15 17:51:00'),
	(28, 11, '2026-06-15 08:46:00', '2026-06-15 17:42:00'),
	(29, 12, '2026-06-15 09:22:00', '2026-06-15 17:55:00'),
	(30, 13, '2026-06-15 09:22:00', '2026-06-15 18:00:00'),
	(31, 14, '2026-06-15 09:30:00', '2026-06-15 17:30:00'),
	(32, 15, '2026-06-15 10:01:00', '2026-06-15 18:02:00'),
	(33, 16, '2026-06-15 10:35:00', '2026-06-15 18:09:00'),
	(34, 17, '2026-06-15 10:08:00', '2026-06-15 17:39:00'),
	(35, 19, '2026-06-15 08:12:00', '2026-06-15 18:53:00'),
	(36, 20, '2026-06-15 08:04:00', '2026-06-15 18:25:00'),
	(37, 21, '2026-06-15 10:34:00', '2026-06-15 17:24:00'),
	(38, 22, '2026-06-15 08:54:00', '2026-06-15 18:34:00'),
	(39, 23, '2026-06-15 09:29:00', '2026-06-15 17:46:00'),
	(40, 1, '2026-06-14 09:19:00', '2026-06-14 17:22:00'),
	(41, 2, '2026-06-14 10:06:00', '2026-06-14 18:30:00'),
	(42, 3, '2026-06-14 10:06:00', '2026-06-14 18:40:00'),
	(43, 4, '2026-06-14 08:21:00', '2026-06-14 17:08:00'),
	(44, 5, '2026-06-14 08:10:00', '2026-06-14 18:57:00'),
	(45, 6, '2026-06-14 08:15:00', '2026-06-14 17:41:00'),
	(46, 7, '2026-06-14 09:46:00', '2026-06-14 18:40:00'),
	(47, 8, '2026-06-14 09:55:00', '2026-06-14 18:50:00'),
	(48, 11, '2026-06-14 09:17:00', '2026-06-14 18:02:00'),
	(49, 13, '2026-06-14 10:09:00', '2026-06-14 18:40:00'),
	(50, 14, '2026-06-14 08:19:00', '2026-06-14 18:48:00'),
	(51, 15, '2026-06-14 08:30:00', '2026-06-14 18:35:00'),
	(52, 16, '2026-06-14 08:51:00', '2026-06-14 17:11:00'),
	(53, 17, '2026-06-14 08:00:00', '2026-06-14 17:18:00'),
	(54, 18, '2026-06-14 09:49:00', '2026-06-14 18:45:00'),
	(55, 19, '2026-06-14 10:43:00', '2026-06-14 17:20:00'),
	(56, 20, '2026-06-14 09:04:00', '2026-06-14 18:52:00'),
	(57, 21, '2026-06-14 09:29:00', '2026-06-14 17:41:00'),
	(58, 22, '2026-06-14 10:14:00', '2026-06-14 18:19:00'),
	(59, 23, '2026-06-14 08:53:00', '2026-06-14 18:51:00'),
	(60, 1, '2026-06-13 08:29:00', '2026-06-13 17:41:00'),
	(61, 2, '2026-06-13 09:56:00', '2026-06-13 17:52:00'),
	(62, 4, '2026-06-13 10:58:00', '2026-06-13 18:17:00'),
	(63, 5, '2026-06-13 10:27:00', '2026-06-13 18:29:00'),
	(64, 6, '2026-06-13 10:23:00', '2026-06-13 18:27:00'),
	(65, 7, '2026-06-13 09:43:00', '2026-06-13 18:35:00'),
	(66, 8, '2026-06-13 08:29:00', '2026-06-13 18:23:00'),
	(67, 9, '2026-06-13 08:07:00', '2026-06-13 17:14:00'),
	(68, 10, '2026-06-13 09:19:00', '2026-06-13 18:45:00'),
	(69, 11, '2026-06-13 10:41:00', '2026-06-13 17:00:00'),
	(70, 12, '2026-06-13 10:32:00', '2026-06-13 18:03:00'),
	(71, 13, '2026-06-13 08:54:00', '2026-06-13 17:16:00'),
	(72, 14, '2026-06-13 09:24:00', '2026-06-13 18:07:00'),
	(73, 15, '2026-06-13 09:47:00', '2026-06-13 17:37:00'),
	(74, 16, '2026-06-13 10:57:00', '2026-06-13 17:21:00'),
	(75, 17, '2026-06-13 08:07:00', '2026-06-13 18:56:00'),
	(76, 18, '2026-06-13 09:58:00', '2026-06-13 17:59:00'),
	(77, 20, '2026-06-13 10:33:00', '2026-06-13 17:07:00'),
	(78, 21, '2026-06-13 10:11:00', '2026-06-13 18:59:00'),
	(79, 22, '2026-06-13 09:42:00', '2026-06-13 18:45:00'),
	(80, 23, '2026-06-13 08:38:00', '2026-06-13 18:02:00'),
	(81, 1, '2026-06-12 10:23:00', '2026-06-12 18:14:00'),
	(82, 2, '2026-06-12 08:43:00', '2026-06-12 18:09:00'),
	(83, 4, '2026-06-12 10:44:00', '2026-06-12 18:46:00'),
	(84, 5, '2026-06-12 09:59:00', '2026-06-12 17:35:00'),
	(85, 6, '2026-06-12 10:28:00', '2026-06-12 18:43:00'),
	(86, 7, '2026-06-12 10:13:00', '2026-06-12 17:45:00'),
	(87, 8, '2026-06-12 08:41:00', '2026-06-12 18:47:00'),
	(88, 9, '2026-06-12 08:04:00', '2026-06-12 17:57:00'),
	(89, 11, '2026-06-12 10:25:00', '2026-06-12 18:52:00'),
	(90, 12, '2026-06-12 08:13:00', '2026-06-12 17:46:00'),
	(91, 13, '2026-06-12 09:51:00', '2026-06-12 18:59:00'),
	(92, 14, '2026-06-12 08:15:00', '2026-06-12 17:16:00'),
	(93, 15, '2026-06-12 10:43:00', '2026-06-12 17:52:00'),
	(94, 16, '2026-06-12 08:20:00', '2026-06-12 18:28:00'),
	(95, 17, '2026-06-12 08:32:00', '2026-06-12 18:17:00'),
	(96, 18, '2026-06-12 09:07:00', '2026-06-12 17:56:00'),
	(97, 19, '2026-06-12 10:13:00', '2026-06-12 18:57:00'),
	(98, 20, '2026-06-12 09:34:00', '2026-06-12 17:11:00'),
	(99, 22, '2026-06-12 09:43:00', '2026-06-12 17:31:00'),
	(100, 23, '2026-06-12 09:20:00', '2026-06-12 17:40:00'),
	(101, 1, '2026-06-11 09:12:00', '2026-06-11 17:29:00'),
	(102, 2, '2026-06-11 09:36:00', '2026-06-11 17:30:00'),
	(103, 3, '2026-06-11 08:26:00', '2026-06-11 18:45:00'),
	(104, 4, '2026-06-11 09:50:00', '2026-06-11 18:31:00'),
	(105, 5, '2026-06-11 08:00:00', '2026-06-11 18:30:00'),
	(106, 7, '2026-06-11 09:42:00', '2026-06-11 17:49:00'),
	(107, 8, '2026-06-11 10:14:00', '2026-06-11 17:47:00'),
	(108, 9, '2026-06-11 10:57:00', '2026-06-11 17:09:00'),
	(109, 10, '2026-06-11 08:38:00', '2026-06-11 18:36:00'),
	(110, 11, '2026-06-11 10:58:00', '2026-06-11 18:17:00'),
	(111, 12, '2026-06-11 08:52:00', '2026-06-11 18:51:00'),
	(112, 13, '2026-06-11 09:58:00', '2026-06-11 17:37:00'),
	(113, 14, '2026-06-11 09:16:00', '2026-06-11 17:32:00'),
	(114, 15, '2026-06-11 10:27:00', '2026-06-11 18:13:00'),
	(115, 16, '2026-06-11 10:23:00', '2026-06-11 17:50:00'),
	(116, 17, '2026-06-11 09:54:00', '2026-06-11 18:14:00'),
	(117, 18, '2026-06-11 08:32:00', '2026-06-11 18:37:00'),
	(118, 19, '2026-06-11 09:50:00', '2026-06-11 18:21:00'),
	(119, 20, '2026-06-11 10:05:00', '2026-06-11 17:43:00'),
	(120, 21, '2026-06-11 09:59:00', '2026-06-11 17:45:00'),
	(121, 22, '2026-06-11 09:12:00', '2026-06-11 17:25:00'),
	(122, 23, '2026-06-11 09:19:00', '2026-06-11 18:05:00'),
	(123, 1, '2026-06-10 08:50:00', '2026-06-10 18:45:00'),
	(124, 2, '2026-06-10 10:44:00', '2026-06-10 18:15:00'),
	(125, 3, '2026-06-10 10:00:00', '2026-06-10 17:06:00'),
	(126, 4, '2026-06-10 09:59:00', '2026-06-10 17:12:00'),
	(127, 5, '2026-06-10 08:00:00', '2026-06-10 17:45:00'),
	(128, 7, '2026-06-10 08:50:00', '2026-06-10 18:58:00'),
	(129, 8, '2026-06-10 10:48:00', '2026-06-10 18:24:00'),
	(130, 9, '2026-06-10 08:45:00', '2026-06-10 17:24:00'),
	(131, 10, '2026-06-10 09:53:00', '2026-06-10 18:44:00'),
	(132, 11, '2026-06-10 09:31:00', '2026-06-10 18:40:00'),
	(133, 13, '2026-06-10 09:27:00', '2026-06-10 18:02:00'),
	(134, 14, '2026-06-10 08:37:00', '2026-06-10 18:05:00'),
	(135, 15, '2026-06-10 10:56:00', '2026-06-10 18:43:00'),
	(136, 16, '2026-06-10 08:25:00', '2026-06-10 18:49:00'),
	(137, 17, '2026-06-10 09:16:00', '2026-06-10 17:37:00'),
	(138, 18, '2026-06-10 08:31:00', '2026-06-10 17:51:00'),
	(139, 19, '2026-06-10 08:07:00', '2026-06-10 17:44:00'),
	(140, 20, '2026-06-10 10:46:00', '2026-06-10 18:09:00'),
	(141, 21, '2026-06-10 10:19:00', '2026-06-10 18:42:00'),
	(142, 22, '2026-06-10 08:24:00', '2026-06-10 18:59:00'),
	(143, 23, '2026-06-10 09:02:00', '2026-06-10 17:58:00');

-- Dumping structure for table insta_style_lms.user_media_progress
CREATE TABLE IF NOT EXISTS `user_media_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `total_media_count` int NOT NULL DEFAULT '0',
  `view_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `last_viewed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_post_progress` (`user_id`,`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_view_percentage` (`view_percentage`),
  CONSTRAINT `user_media_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_media_progress_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_media_progress: ~18 rows (approximately)
INSERT INTO `user_media_progress` (`id`, `user_id`, `post_id`, `total_media_count`, `view_percentage`, `last_viewed_at`, `created_at`) VALUES
	(1, 12, 10, 1, 100.00, '2026-06-17 10:19:47', '2026-06-17 10:19:32'),
	(2, 2, 1, 2, 50.00, '2026-07-29 10:31:28', '2026-07-29 10:31:28'),
	(3, 4, 1, 2, 50.00, '2026-08-19 06:40:17', '2026-08-19 06:40:17'),
	(4, 1, 4, 1, 47.62, '2026-08-20 09:46:01', '2026-08-20 06:34:21'),
	(5, 1, 1, 2, 95.00, '2026-08-20 09:40:23', '2026-08-20 09:39:34'),
	(6, 1, 7, 1, 100.00, '2026-08-20 09:46:08', '2026-08-20 09:46:08'),
	(7, 1, 8, 1, 100.00, '2026-08-20 09:46:15', '2026-08-20 09:46:15'),
	(8, 1, 9, 1, 100.00, '2026-08-20 09:46:22', '2026-08-20 09:46:22'),
	(9, 1, 5, 1, 16.98, '2026-08-20 09:47:03', '2026-08-20 09:46:53'),
	(10, 1, 6, 2, 100.00, '2026-08-20 09:47:24', '2026-08-20 09:47:21'),
	(11, 1, 20, 2, 100.00, '2026-08-20 09:48:02', '2026-08-20 09:48:01'),
	(12, 1, 3, 2, 100.00, '2026-08-21 05:16:05', '2026-08-20 10:25:27'),
	(13, 1, 10, 1, 11.11, '2026-08-20 10:33:07', '2026-08-20 10:33:07'),
	(14, 1, 2, 2, 100.00, '2026-08-20 10:55:51', '2026-08-20 10:55:39'),
	(15, 1, 38, 2, 100.00, '2026-08-21 05:10:40', '2026-08-21 05:10:37'),
	(16, 1, 14, 1, 100.00, '2026-08-21 05:11:23', '2026-08-21 05:11:23'),
	(17, 1, 15, 2, 100.00, '2026-08-21 05:12:00', '2026-08-21 05:11:57'),
	(18, 8, 1, 2, 100.00, '2026-08-21 05:18:19', '2026-08-21 05:17:34');

-- Dumping structure for table insta_style_lms.user_media_tracking
CREATE TABLE IF NOT EXISTS `user_media_tracking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `media_id` int NOT NULL,
  `post_id` int NOT NULL,
  `media_type` enum('image','video','pdf','wbt','youtube') NOT NULL,
  `viewed_at` timestamp NULL DEFAULT NULL,
  `total_minutes` varchar(10) DEFAULT NULL,
  `viewed_minutes` varchar(10) DEFAULT NULL,
  `total_slides` int DEFAULT '0',
  `viewed_slides` int DEFAULT '0',
  `wbt_json` json DEFAULT NULL,
  `percentage` decimal(5,2) DEFAULT '0.00',
  `completed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_media` (`user_id`,`media_id`),
  KEY `idx_media_id` (`media_id`),
  KEY `idx_post_id` (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_media_tracking: ~26 rows (approximately)
INSERT INTO `user_media_tracking` (`id`, `user_id`, `media_id`, `post_id`, `media_type`, `viewed_at`, `total_minutes`, `viewed_minutes`, `total_slides`, `viewed_slides`, `wbt_json`, `percentage`, `completed`, `created_at`, `updated_at`) VALUES
	(1, 12, 16, 10, 'wbt', NULL, NULL, NULL, 0, 0, '{"postId": 10, "mediaId": 16, "mediaUrl": "https://yourdomain.com/upload/wbt-file", "spentTime": "47s", "totalSlides": 10, "currentSlide": 10, "spentSeconds": 47, "completedSlides": 10}', 100.00, 1, '2026-06-17 10:19:32', '2026-06-17 10:19:47'),
	(2, 2, 1, 1, 'image', '2026-07-29 10:31:28', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-07-29 10:31:28', '2026-07-29 10:31:28'),
	(3, 4, 1, 1, 'image', '2026-08-19 06:40:17', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-19 06:40:17', '2026-08-19 06:40:17'),
	(4, 1, 7, 4, 'video', NULL, '0:21', '0:10', 0, 0, NULL, 47.62, 0, '2026-08-20 06:34:21', '2026-08-20 09:46:01'),
	(5, 1, 1, 1, 'image', '2026-08-20 09:39:34', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:39:34', '2026-08-20 09:39:34'),
	(6, 1, 2, 1, 'video', NULL, '0:40', '0:36', 0, 0, NULL, 90.00, 1, '2026-08-20 09:39:44', '2026-08-20 09:40:23'),
	(7, 1, 11, 7, 'image', '2026-08-20 09:46:08', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:46:08', '2026-08-20 09:46:08'),
	(8, 1, 12, 8, 'image', '2026-08-20 09:46:15', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:46:15', '2026-08-20 09:46:15'),
	(9, 1, 13, 9, 'image', '2026-08-20 09:46:22', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:46:22', '2026-08-20 09:46:22'),
	(10, 1, 8, 5, 'pdf', NULL, NULL, NULL, 53, 9, NULL, 16.98, 0, '2026-08-20 09:46:53', '2026-08-20 09:47:03'),
	(11, 1, 9, 6, 'image', '2026-08-20 09:47:21', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:47:21', '2026-08-20 09:47:21'),
	(12, 1, 10, 6, 'image', '2026-08-20 09:47:24', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:47:24', '2026-08-20 09:47:24'),
	(13, 1, 32, 20, 'image', '2026-08-20 09:48:01', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:48:01', '2026-08-20 09:48:01'),
	(14, 1, 33, 20, 'image', '2026-08-20 09:48:02', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 09:48:02', '2026-08-20 09:48:02'),
	(15, 1, 6, 3, 'video', NULL, '0:18', '0:18', 0, 0, NULL, 100.00, 1, '2026-08-20 10:25:27', '2026-08-20 10:25:27'),
	(16, 1, 14, 10, 'wbt', NULL, NULL, NULL, 0, 0, '{"type": "wbt-tracking", "totalSlides": 18, "currentSlide": "/uploads/posts/10/media/16/extracted/story.html", "spentSeconds": 54, "pendingSlides": 16, "completedSlides": 2}', 11.11, 0, '2026-08-20 10:33:07', '2026-08-20 10:33:07'),
	(17, 1, 4, 2, 'video', NULL, '0:40', '0:40', 0, 0, NULL, 100.00, 1, '2026-08-20 10:55:39', '2026-08-20 10:55:48'),
	(18, 1, 3, 2, 'image', '2026-08-20 10:55:51', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-20 10:55:51', '2026-08-20 10:55:51'),
	(19, 1, 68, 38, 'image', '2026-08-21 05:10:37', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:10:37', '2026-08-21 05:10:37'),
	(20, 1, 69, 38, 'image', '2026-08-21 05:10:40', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:10:40', '2026-08-21 05:10:40'),
	(21, 1, 21, 14, 'image', '2026-08-21 05:11:23', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:11:23', '2026-08-21 05:11:23'),
	(22, 1, 22, 15, 'image', '2026-08-21 05:11:57', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:11:57', '2026-08-21 05:11:57'),
	(23, 1, 23, 15, 'image', '2026-08-21 05:12:00', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:12:00', '2026-08-21 05:12:00'),
	(24, 1, 5, 3, 'image', '2026-08-21 05:16:05', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:16:05', '2026-08-21 05:16:05'),
	(25, 8, 1, 1, 'image', '2026-08-21 05:17:34', NULL, NULL, 0, 0, NULL, 100.00, 1, '2026-08-21 05:17:34', '2026-08-21 05:17:34'),
	(26, 8, 2, 1, 'video', NULL, '0:40', '0:40', 0, 0, NULL, 100.00, 1, '2026-08-21 05:18:09', '2026-08-21 05:18:19');

-- Dumping structure for table insta_style_lms.user_notification_reads
CREATE TABLE IF NOT EXISTS `user_notification_reads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `notification_id` int NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_notification` (`user_id`,`notification_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_notification_id` (`notification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.user_notification_reads: ~2 rows (approximately)
INSERT INTO `user_notification_reads` (`id`, `user_id`, `notification_id`, `is_read`, `read_at`) VALUES
	(1, 1, 1, 1, '2026-07-06 07:31:53'),
	(2, 1, 2, 1, '2026-07-06 07:31:53');

-- Dumping structure for table insta_style_lms.user_quiz_answers
CREATE TABLE IF NOT EXISTS `user_quiz_answers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `question_id` int NOT NULL,
  `selected_option` enum('A','B','C','D') NOT NULL,
  `is_correct` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_answer` (`user_id`,`post_id`,`question_id`),
  KEY `user_id` (`user_id`),
  KEY `post_id` (`post_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `user_quiz_answers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_quiz_answers_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_quiz_answers_ibfk_3` FOREIGN KEY (`question_id`) REFERENCES `quiz_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_quiz_answers: ~110 rows (approximately)
INSERT INTO `user_quiz_answers` (`id`, `user_id`, `post_id`, `question_id`, `selected_option`, `is_correct`, `created_at`) VALUES
	(1, 1, 1, 1, 'A', 0, '2026-05-01 06:58:06'),
	(2, 1, 1, 2, 'D', 0, '2026-05-01 06:58:06'),
	(3, 1, 1, 3, 'A', 0, '2026-05-01 06:58:06'),
	(4, 1, 1, 4, 'D', 0, '2026-05-01 06:58:06'),
	(5, 1, 1, 5, 'D', 0, '2026-05-01 06:58:06'),
	(11, 1, 3, 11, 'A', 0, '2026-05-01 07:41:20'),
	(12, 1, 3, 12, 'B', 1, '2026-05-01 07:41:20'),
	(13, 1, 3, 13, 'A', 0, '2026-05-01 07:41:20'),
	(14, 1, 3, 14, 'D', 0, '2026-05-01 07:41:20'),
	(15, 1, 3, 15, 'A', 0, '2026-05-01 07:41:20'),
	(16, 1, 6, 16, 'A', 0, '2026-05-05 09:55:20'),
	(17, 1, 6, 17, 'D', 0, '2026-05-05 09:55:20'),
	(18, 1, 6, 18, 'A', 0, '2026-05-05 09:55:20'),
	(19, 1, 6, 19, 'D', 0, '2026-05-05 09:55:20'),
	(20, 1, 6, 20, 'D', 0, '2026-05-05 09:55:20'),
	(21, 1, 2, 6, 'C', 0, '2026-05-11 11:33:16'),
	(22, 1, 2, 7, 'A', 0, '2026-05-11 11:33:16'),
	(23, 1, 2, 8, 'A', 0, '2026-05-11 11:33:16'),
	(24, 1, 2, 9, 'C', 1, '2026-05-11 11:33:16'),
	(25, 1, 2, 10, 'B', 1, '2026-05-11 11:33:16'),
	(26, 3, 1, 1, 'B', 1, '2026-05-29 05:44:36'),
	(27, 3, 1, 2, 'B', 1, '2026-05-29 05:44:36'),
	(28, 3, 1, 3, 'C', 1, '2026-05-29 05:44:36'),
	(29, 3, 1, 4, 'C', 1, '2026-05-29 05:44:36'),
	(30, 3, 1, 5, 'B', 1, '2026-05-29 05:44:36'),
	(31, 4, 1, 1, 'B', 1, '2026-05-29 08:15:41'),
	(32, 4, 1, 2, 'B', 1, '2026-05-29 08:15:41'),
	(33, 4, 1, 3, 'C', 1, '2026-05-29 08:15:41'),
	(34, 4, 1, 4, 'C', 1, '2026-05-29 08:15:41'),
	(35, 4, 1, 5, 'B', 1, '2026-05-29 08:15:41'),
	(36, 4, 2, 6, 'B', 1, '2026-05-29 08:16:53'),
	(37, 4, 2, 7, 'B', 1, '2026-05-29 08:16:53'),
	(38, 4, 2, 8, 'C', 1, '2026-05-29 08:16:53'),
	(39, 4, 2, 9, 'B', 0, '2026-05-29 08:16:53'),
	(40, 4, 2, 10, 'B', 1, '2026-05-29 08:16:53'),
	(41, 4, 3, 11, 'B', 1, '2026-05-29 08:18:07'),
	(42, 4, 3, 12, 'B', 1, '2026-05-29 08:18:07'),
	(43, 4, 3, 13, 'C', 1, '2026-05-29 08:18:07'),
	(44, 4, 3, 14, 'C', 1, '2026-05-29 08:18:07'),
	(45, 4, 3, 15, 'B', 1, '2026-05-29 08:18:07'),
	(46, 4, 6, 16, 'B', 1, '2026-05-29 09:01:06'),
	(47, 4, 6, 17, 'B', 1, '2026-05-29 09:01:06'),
	(48, 4, 6, 18, 'C', 1, '2026-05-29 09:01:06'),
	(49, 4, 6, 19, 'C', 1, '2026-05-29 09:01:06'),
	(50, 4, 6, 20, 'B', 1, '2026-05-29 09:01:06'),
	(51, 13, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(52, 13, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(53, 13, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(54, 13, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(55, 13, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(56, 14, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(57, 14, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(58, 14, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(59, 14, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(60, 14, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(61, 15, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(62, 15, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(63, 15, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(64, 15, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(65, 15, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(66, 16, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(67, 16, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(68, 16, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(69, 16, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(70, 16, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(71, 17, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(72, 17, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(73, 17, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(74, 17, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(75, 17, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(76, 18, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(77, 18, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(78, 18, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(79, 18, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(80, 18, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(81, 19, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(82, 19, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(83, 19, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(84, 19, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(85, 19, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(86, 2, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(87, 2, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(88, 2, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(89, 2, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(90, 2, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(91, 20, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(92, 20, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(93, 20, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(94, 20, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(95, 20, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(96, 21, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(97, 21, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(98, 21, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(99, 21, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(100, 21, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(101, 22, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(102, 22, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(103, 22, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(104, 22, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(105, 22, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(106, 23, 5, 25, 'B', 1, '2026-06-08 10:06:50'),
	(107, 23, 5, 24, 'C', 1, '2026-06-08 10:06:50'),
	(108, 23, 5, 23, 'C', 1, '2026-06-08 10:06:50'),
	(109, 23, 5, 22, 'B', 1, '2026-06-08 10:06:50'),
	(110, 23, 5, 21, 'B', 1, '2026-06-08 10:06:50'),
	(111, 1, 4, 26, 'A', 0, '2026-08-20 10:27:38'),
	(112, 1, 4, 27, 'B', 1, '2026-08-20 10:27:38'),
	(113, 1, 4, 28, 'B', 0, '2026-08-20 10:27:38'),
	(114, 1, 4, 29, 'A', 0, '2026-08-20 10:27:38'),
	(115, 1, 4, 30, 'C', 0, '2026-08-20 10:27:38');

-- Dumping structure for table insta_style_lms.user_quiz_completion
CREATE TABLE IF NOT EXISTS `user_quiz_completion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `score` int DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_completion` (`user_id`,`post_id`),
  KEY `user_id` (`user_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `user_quiz_completion_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_quiz_completion_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_quiz_completion: ~22 rows (approximately)
INSERT INTO `user_quiz_completion` (`id`, `user_id`, `post_id`, `score`, `completed_at`) VALUES
	(1, 1, 1, 35, '2026-05-01 06:58:06'),
	(3, 1, 3, 35, '2026-05-01 07:41:20'),
	(4, 1, 6, 35, '2026-05-05 09:55:20'),
	(5, 1, 2, 35, '2026-05-11 11:33:17'),
	(6, 3, 1, 35, '2026-05-29 05:44:36'),
	(7, 4, 1, 35, '2026-05-29 08:15:41'),
	(8, 4, 2, 35, '2026-05-29 08:16:53'),
	(9, 4, 3, 35, '2026-05-29 08:18:07'),
	(10, 13, 6, 35, '2026-05-29 09:01:06'),
	(11, 13, 5, 35, '2026-06-08 10:14:31'),
	(12, 14, 5, 35, '2026-06-08 10:14:31'),
	(13, 15, 5, 35, '2026-06-08 10:14:31'),
	(14, 16, 5, 35, '2026-06-08 10:14:31'),
	(15, 17, 5, 35, '2026-06-08 10:14:31'),
	(16, 18, 5, 35, '2026-06-08 10:14:31'),
	(17, 19, 5, 35, '2026-06-08 10:14:31'),
	(18, 2, 5, 35, '2026-06-08 10:14:31'),
	(19, 20, 5, 35, '2026-06-08 10:14:31'),
	(20, 21, 5, 35, '2026-06-08 10:14:31'),
	(21, 22, 5, 35, '2026-06-08 10:14:31'),
	(22, 23, 5, 35, '2026-06-08 10:14:31'),
	(27, 1, 4, 5, '2026-08-20 10:27:38');

-- Dumping structure for table insta_style_lms.user_video_analysis
CREATE TABLE IF NOT EXISTS `user_video_analysis` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `assessment_id` int NOT NULL,
  `question_id` int NOT NULL,
  `video_file_path` varchar(500) NOT NULL,
  `audio_file_path` varchar(500) DEFAULT NULL,
  `isAwsReportGenerated` tinyint(1) DEFAULT '0' COMMENT '0=pending, 1=processing, 2=completed',
  `aws_file_path` varchar(500) DEFAULT NULL,
  `isGeminiReportGenerated` tinyint(1) DEFAULT '0' COMMENT '0=pending, 1=processing, 2=completed',
  `GeminiReportFilePath` varchar(500) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_assessment_question` (`user_id`,`assessment_id`,`question_id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `user_video_analysis_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_video_analysis_ibfk_2` FOREIGN KEY (`assessment_id`) REFERENCES `video_analysis_assessments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_video_analysis_ibfk_3` FOREIGN KEY (`question_id`) REFERENCES `video_assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_video_analysis: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `employee_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` enum('male','female') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int NOT NULL,
  `dealer_id` int DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `profile_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` enum('android','ios') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `idx_email` (`email`),
  KEY `idx_employee_id` (`employee_id`),
  KEY `idx_status` (`status`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_dealer_id` (`dealer_id`),
  KEY `idx_city_id` (`city_id`),
  CONSTRAINT `fk_users_city_id` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_dealer_id` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.users: ~23 rows (approximately)
INSERT INTO `users` (`id`, `email`, `employee_id`, `name`, `phone`, `gender`, `password`, `role_id`, `dealer_id`, `city_id`, `profile_url`, `fcm_token`, `device_type`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'demo@sls.com', 'EMP001', 'Keshav_Goyal', '8282828282', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 1, '/uploads/users/1/profile-1775713806692.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-09 05:50:06', '2026-08-21 05:20:41'),
	(2, 'demo@sls2.com', 'EMP002', 'Neeraj Jain', '8989898989', 'male', '$2b$12$QBXiSY0OPhBa9qV8f48MzuRvUwqsl67/Sb1mjCjKsvlcszd5nvAQa', 1, 1, 1, '/uploads/users/2/profile-1775713867244.jpg', 'edbpkSYgT6OoTCiTbo1Vww:APA91bE7yRp_Au-9PIumwi7YnOZTiu3iCoc7jkN8ocE6VePrp65-Q1mjzlRydOBPu-z4etOCQyf61CoLeYX6xPYD_hAzH6-tpzOWfQZRsG5C24ee1DBRr-o', 'android', 'active', '2026-04-09 05:51:07', '2026-07-29 10:31:14'),
	(3, 'demo@sls3.com', 'EMP003', 'Ravi Pandey', '8181818181', 'male', '$2b$12$PNRO6eNla8CKqp4prVXoT.QNjB8ULGi/u0dc2N1Wo1wP7U8OsFlKi', 1, 1, 1, '/uploads/users/3/profile-1775713939921.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-09 05:52:19', '2026-06-17 10:40:10'),
	(4, 'demo@sls4.com', 'EMP004', 'Subhojit', '9876543210', 'male', '$2b$12$Jig.kclv.RbH2wwxgm48rOC32nnuyFWSxkoHHIy5kA3xX0xseY3pC', 1, 1, 1, '/uploads/users/4/profile-1776246467383.jpg', 'cwlXgXP3Su-hT8Er3jvf2S:APA91bEMKVWtENVYZTBZjmKmiLEx8D8MqTQkN8GeMw8emQu2EcJnEdZArTFr2eEfadCjbi_mAGRD4eyiH5NoxzgtfXGF8DdJTIfiIDsabohM_ijggoxIP6w', 'android', 'active', '2026-04-15 09:47:47', '2026-08-19 06:40:03'),
	(5, 'demo@sls5.com', 'EMP005', 'Pradeep Kumar', '9876543291', 'male', '$2b$12$UUNeVsUpZytLAKhajq36Ce0l6OwWmwO3.hiHp2j0VwKsrcmJfjSIS', 1, 1, 1, '/uploads/users/5/profile-1776246576012.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:49:36', '2026-06-17 10:40:10'),
	(6, 'demo@sls6.com', 'EMP006', 'Anil Kumawat', '9234897684', 'male', '$2b$12$uRpsPxHFAXtBGSSeSJAO8uCNAqaebvW.09HTHrS.8UPtcEiNF.zlq', 1, 1, 1, '/uploads/users/6/profile-1776246747079.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:52:27', '2026-06-17 10:40:10'),
	(7, 'demo@sls7.com', 'EMP007', 'Dheeraj', '9994328902', 'male', '$2b$12$TCdpZGJ7fK8os0EDuR60Y.GnPPK9L33XZNRlM4vbLFEfSO2w7./pW', 1, 1, 1, '/uploads/users/7/profile-1776246864430.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:54:24', '2026-06-17 10:40:10'),
	(8, 'demo@sls8.com', 'EMP008', 'Karthick', '9876543233', 'male', '$2b$12$s2j/DMLuBB4ceYibqtuQzO9Mvq2VyDt7I1klxpeK1RN6e/qpdSOSq', 1, 1, 1, '/uploads/users/8/profile-1778652931250.jpg', 'dl2BUmA3SyKYupZ3m7MT4N:APA91bFBPBVNz8z76z0hGomrwrNuV7zIWGAyjWQ3FygMZmzPHmmOQY9oxZtzr8sd9rmvKnDFZLbYoL0u-R8-5gROrBZbbX9sEUVnQr8O1q3tTU7bB8AXpUw', 'android', 'active', '2026-05-13 06:15:31', '2026-08-21 05:17:05'),
	(9, 'demo@sls9.com', 'EMP009', 'SOHAIL KHAN', '9876543122', 'male', '$2b$12$HrOtucb5rRqZUyWgwhAUFu62dtIxlnmgJjDVz2X.63HCiY3kbS3ma', 1, 1, 1, '/uploads/users/9/profile-1778653072931.jpg', NULL, NULL, 'active', '2026-05-13 06:17:52', '2026-06-17 10:40:10'),
	(10, 'demo@sls10.com', 'EMP0010', 'Vinaya Prasad', '9876543122', 'male', '$2b$12$4DCIVZfU570HZOJRxNgAxudZZMUAut7Prlm.FHbqJm2pI8xjgj4bO', 1, 1, 1, '/uploads/users/10/profile-1778653116674.jpg', NULL, NULL, 'active', '2026-05-13 06:18:36', '2026-06-17 10:40:10'),
	(11, 'demo@sls11.com', 'EMP0011', 'Sudha Pawar', '9876543122', 'male', '$2b$12$eFj6Rx46Y/yWcjODoodI0uqpshOiOy5xGHqfyoRp5tsyFLtGuPHQ.', 1, 1, 1, '/uploads/users/11/profile-1778653157019.jpg', NULL, NULL, 'active', '2026-05-13 06:19:17', '2026-06-17 10:40:10'),
	(12, 'demo@sls12.com', 'EMP0012', 'Nagnath Pise', '9876543122', 'male', '$2b$12$SdC7AF271okTtt3cwIIrtOfxgYXb8XhB.kRf//Eq0mnGSAHIZg0la', 1, 1, 1, '/uploads/users/12/profile-1778653233079.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-05-13 06:20:33', '2026-06-17 10:40:10'),
	(13, 'demo@sls13.com', 'EMP013', 'Rajesh Kumar Sharma', '9876543213', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/1/profile-1775713806692.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:45'),
	(14, 'demo@sls14.com', 'EMP014', 'Priya Singh', '9876543214', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/2/profile-1775713867244.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:48'),
	(15, 'demo@sls15.com', 'EMP015', 'Amit Patel', '9876543215', 'female', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/3/profile-1775713939921.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:57'),
	(16, 'demo@sls16.com', 'EMP016', 'Sunita Verma', '9876543216', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/4/profile-1776246467383.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:53'),
	(17, 'demo@sls17.com', 'EMP017', 'Vikram Rathore', '9876543217', 'female', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/5/profile-1776246576012.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:50'),
	(18, 'demo@sls18.com', 'EMP018', 'Neha Gupta', '9876543218', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/6/profile-1776246747079.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:49:59'),
	(19, 'demo@sls19.com', 'EMP019', 'Rahul Mehta', '9876543219', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/7/profile-1776246864430.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:50:02'),
	(20, 'demo@sls20.com', 'EMP020', 'Anjali Nair', '9876543220', 'female', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/8/profile-1778652931250.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:50:06'),
	(21, 'demo@sls21.com', 'EMP021', 'Suresh Reddy', '9876543221', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/9/profile-1778653072931.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:50:08'),
	(22, 'demo@sls22.com', 'EMP022', 'Arun Joshi', '9876543222', 'female', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/10/profile-1778653116674.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-08-20 17:10:21'),
	(23, 'demo@sls23.com', 'EMP023', 'Manish Khanna', '9876543223', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 1, 1, 2, '/uploads/users/11/profile-1778653157019.jpg', NULL, NULL, 'active', '2026-06-08 09:16:21', '2026-06-14 07:50:13');

-- Dumping structure for table insta_style_lms.video_analysis_assessments
CREATE TABLE IF NOT EXISTS `video_analysis_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.video_analysis_assessments: ~1 rows (approximately)
INSERT INTO `video_analysis_assessments` (`id`, `title`, `description`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'TVS Assessment', 'Assess sales representatives on TVS bike features and selling points.', '2026-07-01', '2028-12-22', 'active', '2026-07-10 09:33:06', '2026-08-20 06:05:45');

-- Dumping structure for table insta_style_lms.video_analysis_overall_summary
CREATE TABLE IF NOT EXISTS `video_analysis_overall_summary` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `userId` bigint NOT NULL,
  `assessmentId` bigint NOT NULL,
  `overall_face` float(10,2) DEFAULT '0.00',
  `overall_voice` float(10,2) DEFAULT '0.00',
  `overall_emotion` float(10,2) DEFAULT '0.00',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_assessment` (`userId`,`assessmentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.video_analysis_overall_summary: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.video_analysis_question_answer_evaluation
CREATE TABLE IF NOT EXISTS `video_analysis_question_answer_evaluation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_video_analysis_id` int NOT NULL COMMENT 'Reference to user_video_analysis',
  `user_id` int NOT NULL,
  `question_id` int NOT NULL,
  `transcript` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Transcribed user answer',
  `score` int NOT NULL DEFAULT '0' COMMENT 'Score out of 70',
  `score_percentage` int NOT NULL DEFAULT '0' COMMENT 'Percentage score (score/70 * 100)',
  `grammar_mistakes` int NOT NULL DEFAULT '0' COMMENT 'Number of grammar mistakes found',
  `sentiment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'very positive, positive, slightly positive, neutral, slightly negative, very negative',
  `emotion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'joy, love, surprise, anger, sadness, fear, disgust, neutral',
  `correctness` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Correctness judgment and explanation',
  `understanding` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Understanding evaluation with reasoning',
  `depth_and_clarity` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Depth, clarity, and terminology usage',
  `explanation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Brief summary of the evaluation',
  `matched_keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'List of keywords found in user answer',
  `missing_keywords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'List of keywords not found in user answer',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_video_analysis` (`user_video_analysis_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_question_id` (`question_id`),
  CONSTRAINT `fk_eval_question` FOREIGN KEY (`question_id`) REFERENCES `video_assessment_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_eval_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_eval_user_video_analysis` FOREIGN KEY (`user_video_analysis_id`) REFERENCES `user_video_analysis` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.video_analysis_question_answer_evaluation: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.video_analysis_question_summary
CREATE TABLE IF NOT EXISTS `video_analysis_question_summary` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `userId` bigint NOT NULL,
  `assessmentId` bigint NOT NULL,
  `questionId` bigint NOT NULL,
  `face_interest` float(10,2) DEFAULT '0.00',
  `face_concentration` float(10,2) DEFAULT '0.00',
  `face_doubt` float(10,2) DEFAULT '0.00',
  `face_anxiety` float(10,2) DEFAULT '0.00',
  `face_confidence` float(10,2) DEFAULT '0.00',
  `face_attention` float(10,2) DEFAULT '0.00',
  `voice_interest` float(10,2) DEFAULT '0.00',
  `voice_concentration` float(10,2) DEFAULT '0.00',
  `voice_doubt` float(10,2) DEFAULT '0.00',
  `voice_anxiety` float(10,2) DEFAULT '0.00',
  `voice_confidence` float(10,2) DEFAULT '0.00',
  `voice_attention` float(10,2) DEFAULT '0.00',
  `emotion_joy` float(10,2) DEFAULT '0.00',
  `emotion_sadness` float(10,2) DEFAULT '0.00',
  `emotion_fear` float(10,2) DEFAULT '0.00',
  `emotion_confusion` float(10,2) DEFAULT '0.00',
  `emotion_happy` float(10,2) DEFAULT '0.00',
  `emotion_neutral` float(10,2) DEFAULT '0.00',
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_assessment` (`userId`,`assessmentId`),
  KEY `idx_question` (`questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.video_analysis_question_summary: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.video_assessment_questions
CREATE TABLE IF NOT EXISTS `video_assessment_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_id` int NOT NULL,
  `question_text` text NOT NULL,
  `expected_answer` text,
  `keywords` text,
  `language_id` int NOT NULL,
  `sort_order` int DEFAULT '0',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `video_assessment_questions_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `video_analysis_assessments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `video_assessment_questions_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.video_assessment_questions: ~1 rows (approximately)
INSERT INTO `video_assessment_questions` (`id`, `assessment_id`, `question_text`, `expected_answer`, `keywords`, `language_id`, `sort_order`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 'What are the key selling points of the TVS Apache RTR 200 4V compared to its competitors?', 'The TVS Apache RTR 200 4V offers a 4-valve engine with 20.5 bhp and 17 Nm torque, ride modes (Sport/Urban/Rain), slipper clutch, dual-channel ABS, SmartXonnect Bluetooth connectivity, oil-cooled system, race-tuned USD suspension, aggressive styling, and excellent value for money compared to competitors like Bajaj Pulsar NS200 and Honda CB200X.', '4-valve, 20.5 bhp, ride modes, slipper clutch, dual ABS, SmartXonnect, oil-cooled, USD forks, aggressive styling, value for money', 1, 1, 'active', '2026-07-15 07:13:15', '2026-07-15 07:13:15');

-- Dumping structure for trigger insta_style_lms.add_post_view_on_insert_progress
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `add_post_view_on_insert_progress` AFTER INSERT ON `user_media_progress` FOR EACH ROW BEGIN
    DECLARE view_exists INT DEFAULT 0;
    
    IF NEW.view_percentage = 100.00 THEN
        
        SELECT COUNT(*) INTO view_exists
        FROM post_views
        WHERE post_id = NEW.post_id AND user_id = NEW.user_id;
        
        IF view_exists = 0 THEN
            INSERT INTO post_views (post_id, user_id, viewed_at)
            VALUES (NEW.post_id, NEW.user_id, NOW());
            
            UPDATE posts 
            SET views_count = views_count + 1 
            WHERE id = NEW.post_id;
        END IF;
        
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger insta_style_lms.add_post_view_on_update_progress
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `add_post_view_on_update_progress` AFTER UPDATE ON `user_media_progress` FOR EACH ROW BEGIN
    DECLARE view_exists INT DEFAULT 0;
    
    IF (OLD.view_percentage != 100.00 AND NEW.view_percentage = 100.00) OR 
       (NEW.view_percentage = 100.00 AND OLD.view_percentage != 100.00) THEN
        
        SELECT COUNT(*) INTO view_exists
        FROM post_views
        WHERE post_id = NEW.post_id AND user_id = NEW.user_id;
        
        IF view_exists = 0 THEN
            INSERT INTO post_views (post_id, user_id, viewed_at)
            VALUES (NEW.post_id, NEW.user_id, NOW());
            
            UPDATE posts 
            SET views_count = views_count + 1 
            WHERE id = NEW.post_id;
        END IF;
        
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger insta_style_lms.trg_overall_after_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_overall_after_insert` AFTER INSERT ON `video_analysis_question_summary` FOR EACH ROW BEGIN
  DECLARE avg_face FLOAT DEFAULT 0;
  DECLARE avg_voice FLOAT DEFAULT 0;
  DECLARE avg_emotion FLOAT DEFAULT 0;
  DECLARE row_exists INT DEFAULT 0;

  -- Calculate averages
  SELECT 
    IFNULL(AVG(face_confidence), 0),
    IFNULL(AVG(voice_confidence), 0),
    IFNULL(AVG(IFNULL(emotion_neutral, 0)), 0)
  INTO avg_face, avg_voice, avg_emotion
  FROM video_analysis_question_summary
  WHERE userId = NEW.userId
    AND assessmentId = NEW.assessmentId;

  -- Check if row already exists
  SELECT COUNT(*) INTO row_exists
  FROM video_analysis_overall_summary
  WHERE userId = NEW.userId
    AND assessmentId = NEW.assessmentId;

  IF row_exists = 0 THEN
    -- Insert new row
    INSERT INTO video_analysis_overall_summary (
      userId,
      assessmentId,
      overall_face,
      overall_voice,
      overall_emotion
    )
    VALUES (
      NEW.userId,
      NEW.assessmentId,
      avg_face,
      avg_voice,
      avg_emotion
    );
  ELSE
    -- Update existing row
    UPDATE video_analysis_overall_summary
    SET 
      overall_face = avg_face,
      overall_voice = avg_voice,
      overall_emotion = avg_emotion,
      updatedAt = NOW()
    WHERE userId = NEW.userId
      AND assessmentId = NEW.assessmentId;
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger insta_style_lms.trg_overall_after_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `trg_overall_after_update` AFTER UPDATE ON `video_analysis_question_summary` FOR EACH ROW BEGIN
  DECLARE avg_face FLOAT DEFAULT 0;
  DECLARE avg_voice FLOAT DEFAULT 0;
  DECLARE avg_emotion FLOAT DEFAULT 0;
  DECLARE row_exists INT DEFAULT 0;

  -- Calculate averages
  SELECT 
    IFNULL(AVG(face_confidence), 0),
    IFNULL(AVG(voice_confidence), 0),
    IFNULL(AVG(IFNULL(emotion_neutral, 0)), 0)
  INTO avg_face, avg_voice, avg_emotion
  FROM video_analysis_question_summary
  WHERE userId = NEW.userId
    AND assessmentId = NEW.assessmentId;

  -- Check if row already exists
  SELECT COUNT(*) INTO row_exists
  FROM video_analysis_overall_summary
  WHERE userId = NEW.userId
    AND assessmentId = NEW.assessmentId;

  IF row_exists = 0 THEN
    -- Insert new row
    INSERT INTO video_analysis_overall_summary (
      userId,
      assessmentId,
      overall_face,
      overall_voice,
      overall_emotion
    )
    VALUES (
      NEW.userId,
      NEW.assessmentId,
      avg_face,
      avg_voice,
      avg_emotion
    );
  ELSE
    -- Update existing row
    UPDATE video_analysis_overall_summary
    SET 
      overall_face = avg_face,
      overall_voice = avg_voice,
      overall_emotion = avg_emotion,
      updatedAt = NOW()
    WHERE userId = NEW.userId
      AND assessmentId = NEW.assessmentId;
  END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger insta_style_lms.update_user_media_progress_on_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `update_user_media_progress_on_insert` AFTER INSERT ON `user_media_tracking` FOR EACH ROW BEGIN
    DECLARE total_media_count INT DEFAULT 0;
    DECLARE total_percentage DECIMAL(10,2) DEFAULT 0.00;
    DECLARE avg_percentage DECIMAL(5,2) DEFAULT 0.00;
    DECLARE progress_exists INT DEFAULT 0;
    
    -- Get total media count for this post
    SELECT COUNT(DISTINCT id) INTO total_media_count
    FROM post_media
    WHERE post_id = NEW.post_id;
    
    -- Calculate sum of all percentages for this user's media in this post
    SELECT IFNULL(SUM(percentage), 0) INTO total_percentage
    FROM user_media_tracking
    WHERE post_id = NEW.post_id 
      AND user_id = NEW.user_id;
    
    -- Calculate average percentage
    IF total_media_count > 0 THEN
        SET avg_percentage = total_percentage / total_media_count;
    ELSE
        SET avg_percentage = 100.00;
    END IF;
    
    -- Check if progress record already exists
    SELECT COUNT(*) INTO progress_exists
    FROM user_media_progress
    WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
    
    -- Update existing or insert new record
    IF progress_exists > 0 THEN
        UPDATE user_media_progress 
        SET 
            total_media_count = total_media_count,
            view_percentage = avg_percentage,
            last_viewed_at = NOW()
        WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
    ELSE
        INSERT INTO user_media_progress (user_id, post_id, total_media_count, view_percentage, last_viewed_at)
        VALUES (NEW.user_id, NEW.post_id, total_media_count, avg_percentage, NOW());
    END IF;
    
    -- If media is 100% complete, add to post_media_views
    IF NEW.percentage >= 100 OR NEW.completed = 1 THEN
        INSERT INTO post_media_views (post_id, media_id, user_id, viewed_at)
        VALUES (NEW.post_id, NEW.media_id, NEW.user_id, NOW());
    END IF;
    
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger insta_style_lms.update_user_media_progress_on_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `update_user_media_progress_on_update` AFTER UPDATE ON `user_media_tracking` FOR EACH ROW BEGIN
    DECLARE total_media_count INT DEFAULT 0;
    DECLARE total_percentage DECIMAL(10,2) DEFAULT 0.00;
    DECLARE avg_percentage DECIMAL(5,2) DEFAULT 0.00;
    DECLARE progress_exists INT DEFAULT 0;
    
    -- Check if percentage or completed changed
    IF (OLD.percentage != NEW.percentage) OR (OLD.completed != NEW.completed) THEN
    
        -- Get total media count for this post
        SELECT COUNT(DISTINCT id) INTO total_media_count
        FROM post_media
        WHERE post_id = NEW.post_id;
        
        -- Calculate sum of all percentages for this user's media in this post
        SELECT IFNULL(SUM(percentage), 0) INTO total_percentage
        FROM user_media_tracking
        WHERE post_id = NEW.post_id 
          AND user_id = NEW.user_id;
        
        -- Calculate average percentage
        IF total_media_count > 0 THEN
            SET avg_percentage = total_percentage / total_media_count;
        ELSE
            SET avg_percentage = 100.00;
        END IF;
        
        -- Check if progress record already exists
        SELECT COUNT(*) INTO progress_exists
        FROM user_media_progress
        WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
        
        -- Update existing or insert new record
        IF progress_exists > 0 THEN
            UPDATE user_media_progress 
            SET 
                total_media_count = total_media_count,
                view_percentage = avg_percentage,
                last_viewed_at = NOW()
            WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
        ELSE
            INSERT INTO user_media_progress (user_id, post_id, total_media_count, view_percentage, last_viewed_at)
            VALUES (NEW.user_id, NEW.post_id, total_media_count, avg_percentage, NOW());
        END IF;
        
        -- If media became 100% complete, add to post_media_views
        IF (NEW.percentage >= 100 OR NEW.completed = 1) AND 
           (OLD.percentage < 100 AND OLD.completed = 0) THEN
            
            INSERT INTO post_media_views (post_id, media_id, user_id, viewed_at)
            VALUES (NEW.post_id, NEW.media_id, NEW.user_id, NOW());
            
        END IF;
        
    END IF;
    
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
