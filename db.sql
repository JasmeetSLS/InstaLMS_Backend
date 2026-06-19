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

-- Dumping structure for table insta_style_lms.cms_assessment_options
CREATE TABLE IF NOT EXISTS `cms_assessment_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `option_text` varchar(1000) NOT NULL,
  `is_correct` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_option_question` (`question_id`),
  CONSTRAINT `fk_option_question` FOREIGN KEY (`question_id`) REFERENCES `cms_assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_assessment_options: ~0 rows (approximately)
INSERT INTO `cms_assessment_options` (`id`, `question_id`, `option_text`, `is_correct`, `sort_order`, `created_at`) VALUES
	(1, 1, 'Unplasticized Polyvinyl Chloride', 1, 0, '2026-06-18 09:35:04'),
	(2, 1, 'Universal PVC', 0, 0, '2026-06-18 09:35:04'),
	(3, 1, 'Ultra Plastic Vinyl', 0, 0, '2026-06-18 09:35:04'),
	(4, 1, 'None', 0, 0, '2026-06-18 09:35:04'),
	(5, 2, 'Windows & Doors', 1, 0, '2026-06-18 09:35:09'),
	(6, 2, 'Food Packaging', 0, 0, '2026-06-18 09:35:09'),
	(7, 2, 'Textiles', 0, 0, '2026-06-18 09:35:09'),
	(8, 2, 'Furniture', 0, 0, '2026-06-18 09:35:09'),
	(9, 3, 'Corrosion', 1, 0, '2026-06-18 09:35:15'),
	(10, 3, 'Water', 0, 0, '2026-06-18 09:35:15'),
	(11, 3, 'Air', 0, 0, '2026-06-18 09:35:15'),
	(12, 3, 'Sunlight', 0, 0, '2026-06-18 09:35:15'),
	(13, 4, 'Low Maintenance', 1, 0, '2026-06-18 09:35:21'),
	(14, 4, 'High Maintenance', 0, 0, '2026-06-18 09:35:21'),
	(15, 4, 'Weekly Painting', 0, 0, '2026-06-18 09:35:21'),
	(16, 4, 'Oil Coating', 0, 0, '2026-06-18 09:35:21'),
	(17, 5, 'Recyclable', 1, 0, '2026-06-18 09:35:27'),
	(18, 5, 'Hazardous', 0, 0, '2026-06-18 09:35:27'),
	(19, 5, 'Toxic', 0, 0, '2026-06-18 09:35:27'),
	(20, 5, 'Radioactive', 0, 0, '2026-06-18 09:35:27');

-- Dumping structure for table insta_style_lms.cms_assessment_questions
CREATE TABLE IF NOT EXISTS `cms_assessment_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_id` int NOT NULL,
  `question_text` longtext NOT NULL,
  `question_type` enum('mcq','match_following','fill_blank','order_following','true_false','this_or_that') NOT NULL,
  `marks` int DEFAULT '1',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_question_assessment` (`assessment_id`),
  CONSTRAINT `fk_question_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `cms_assessments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_assessment_questions: ~0 rows (approximately)
INSERT INTO `cms_assessment_questions` (`id`, `assessment_id`, `question_text`, `question_type`, `marks`, `sort_order`, `created_at`) VALUES
	(1, 1, 'What does UPVC stand for?', 'mcq', 1, 0, '2026-06-18 09:35:04'),
	(2, 1, 'UPVC is mainly used for?', 'mcq', 1, 0, '2026-06-18 09:35:09'),
	(3, 1, 'UPVC is resistant to?', 'mcq', 1, 0, '2026-06-18 09:35:15'),
	(4, 1, 'UPVC requires?', 'mcq', 1, 0, '2026-06-18 09:35:21'),
	(5, 1, 'UPVC is environmentally?', 'mcq', 1, 0, '2026-06-18 09:35:27'),
	(6, 2, 'Match the Product with Usage', 'match_following', 1, 0, '2026-06-18 09:35:43'),
	(7, 3, 'UPVC stands for ________.', 'fill_blank', 1, 0, '2026-06-18 09:36:39'),
	(8, 3, 'UPVC windows require low ________.', 'fill_blank', 1, 0, '2026-06-18 09:36:39'),
	(9, 3, 'UPVC is resistant to ________.', 'fill_blank', 1, 0, '2026-06-18 09:36:39'),
	(10, 3, 'UPVC is commonly used in ________.', 'fill_blank', 1, 0, '2026-06-18 09:36:39'),
	(11, 3, 'UPVC is ________ friendly.', 'fill_blank', 1, 0, '2026-06-18 09:36:39'),
	(12, 4, 'Arrange Window Installation Process', 'order_following', 1, 0, '2026-06-18 09:37:00'),
	(13, 4, 'Arrange Product Development Process', 'order_following', 1, 0, '2026-06-18 09:37:24'),
	(14, 4, 'Arrange Sales Process', 'order_following', 1, 0, '2026-06-18 09:37:31'),
	(15, 4, 'Arrange Manufacturing Process', 'order_following', 1, 0, '2026-06-18 09:37:37'),
	(16, 4, 'Arrange Learning Flow', 'order_following', 1, 0, '2026-06-18 09:37:43');

-- Dumping structure for table insta_style_lms.cms_assessments
CREATE TABLE IF NOT EXISTS `cms_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `assessment_type` enum('mcq','match_following','fill_blank','order_following','true_false','this_or_that') NOT NULL,
  `passing_percentage` decimal(5,2) DEFAULT '0.00',
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_assessment_section` (`section_id`),
  CONSTRAINT `fk_assessment_section` FOREIGN KEY (`section_id`) REFERENCES `cms_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_assessments: ~0 rows (approximately)
INSERT INTO `cms_assessments` (`id`, `section_id`, `title`, `description`, `assessment_type`, `passing_percentage`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'UPVC MCQ Assessment', NULL, 'mcq', 0.00, 'active', 0, '2026-06-18 09:34:57', '2026-06-18 09:34:57'),
	(2, 1, 'Match Following Assessment', NULL, 'match_following', 0.00, 'active', 0, '2026-06-18 09:35:34', '2026-06-18 09:35:34'),
	(3, 1, 'Fill in the Blanks', NULL, 'fill_blank', 0.00, 'active', 0, '2026-06-18 09:36:32', '2026-06-18 09:36:32'),
	(4, 1, 'Order Following Assessment', NULL, 'order_following', 0.00, 'active', 0, '2026-06-18 09:36:52', '2026-06-18 09:36:52');

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_categories: ~0 rows (approximately)
INSERT INTO `cms_categories` (`id`, `title`, `icon_url`, `content`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Product Training', 'category1.png', 'Product learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(2, 'Sales Training', 'category2.png', 'Sales learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(3, 'Technical Training', 'category3.png', 'Technical learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(4, 'Leadership Training', 'category4.png', 'Leadership learning materials', 'active', '2026-06-18 09:34:12', '2026-06-18 09:34:12'),
	(5, 'Announcements', 'category5.png', 'Company announcements and updates', 'active', '2026-06-18 11:33:39', '2026-06-18 11:33:39'),
	(6, 'Business Engagement', 'category6.png', 'Business engagement learning materials', 'active', '2026-06-18 11:33:39', '2026-06-18 11:33:39');

-- Dumping structure for table insta_style_lms.cms_content_images
CREATE TABLE IF NOT EXISTS `cms_content_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content_id` int NOT NULL,
  `image_url` varchar(1000) NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_content_images` (`content_id`),
  CONSTRAINT `fk_content_images` FOREIGN KEY (`content_id`) REFERENCES `cms_contents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_content_images: ~0 rows (approximately)

-- Dumping structure for table insta_style_lms.cms_contents
CREATE TABLE IF NOT EXISTS `cms_contents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `content_type` enum('image_text','multiple_image','video','image_text_side','pdf_extract','url_extract') NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `media_url` varchar(1000) DEFAULT NULL,
  `thumbnail_url` varchar(1000) DEFAULT NULL,
  `pdf_url` varchar(1000) DEFAULT NULL,
  `source_url` varchar(1000) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_content_section` (`section_id`),
  CONSTRAINT `fk_content_section` FOREIGN KEY (`section_id`) REFERENCES `cms_sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_contents: ~0 rows (approximately)
INSERT INTO `cms_contents` (`id`, `section_id`, `content_type`, `title`, `description`, `media_url`, `thumbnail_url`, `pdf_url`, `source_url`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'image_text', 'What is UPVC?', 'UPVC stands for Unplasticized Polyvinyl Chloride and is widely used in windows.', 'upvc-introduction.jpg', NULL, NULL, NULL, 'active', 0, '2026-06-18 09:34:40', '2026-06-18 09:34:40');

-- Dumping structure for table insta_style_lms.cms_fill_blanks
CREATE TABLE IF NOT EXISTS `cms_fill_blanks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `answer` varchar(500) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `cms_fill_blanks_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `cms_assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_fill_blanks: ~5 rows (approximately)
INSERT INTO `cms_fill_blanks` (`id`, `question_id`, `answer`, `created_at`) VALUES
	(1, 7, 'Unplasticized Polyvinyl Chloride', '2026-06-18 09:36:46'),
	(2, 8, 'maintenance', '2026-06-18 09:36:46'),
	(3, 9, 'corrosion', '2026-06-18 09:36:46'),
	(4, 10, 'windows', '2026-06-18 09:36:46'),
	(5, 11, 'environment', '2026-06-18 09:36:46');

-- Dumping structure for table insta_style_lms.cms_match_following
CREATE TABLE IF NOT EXISTS `cms_match_following` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `left_text` varchar(500) NOT NULL,
  `right_text` varchar(500) NOT NULL,
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `cms_match_following_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `cms_assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_match_following: ~5 rows (approximately)
INSERT INTO `cms_match_following` (`id`, `question_id`, `left_text`, `right_text`, `sort_order`, `created_at`) VALUES
	(1, 6, 'UPVC Window', 'Ventilation', 0, '2026-06-18 09:35:57'),
	(2, 6, 'Door', 'Entry', 0, '2026-06-18 09:35:57'),
	(3, 6, 'Glass', 'Visibility', 0, '2026-06-18 09:35:57'),
	(4, 6, 'Frame', 'Support', 0, '2026-06-18 09:35:57'),
	(5, 6, 'Handle', 'Operation', 0, '2026-06-18 09:35:57');

-- Dumping structure for table insta_style_lms.cms_order_following
CREATE TABLE IF NOT EXISTS `cms_order_following` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `item_text` varchar(500) NOT NULL,
  `correct_position` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `cms_order_following_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `cms_assessment_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_order_following: ~25 rows (approximately)
INSERT INTO `cms_order_following` (`id`, `question_id`, `item_text`, `correct_position`, `created_at`) VALUES
	(1, 12, 'Site Measurement', 1, '2026-06-18 09:37:06'),
	(2, 12, 'Frame Installation', 2, '2026-06-18 09:37:06'),
	(3, 12, 'Glass Fixing', 3, '2026-06-18 09:37:06'),
	(4, 12, 'Hardware Installation', 4, '2026-06-18 09:37:06'),
	(5, 12, 'Final Inspection', 5, '2026-06-18 09:37:06'),
	(6, 13, 'Requirement', 1, '2026-06-18 09:37:24'),
	(7, 13, 'Design', 2, '2026-06-18 09:37:24'),
	(8, 13, 'Development', 3, '2026-06-18 09:37:24'),
	(9, 13, 'Testing', 4, '2026-06-18 09:37:24'),
	(10, 13, 'Deployment', 5, '2026-06-18 09:37:24'),
	(11, 14, 'Lead', 1, '2026-06-18 09:37:31'),
	(12, 14, 'Contact', 2, '2026-06-18 09:37:31'),
	(13, 14, 'Demo', 3, '2026-06-18 09:37:31'),
	(14, 14, 'Proposal', 4, '2026-06-18 09:37:31'),
	(15, 14, 'Closure', 5, '2026-06-18 09:37:31'),
	(16, 15, 'Raw Material', 1, '2026-06-18 09:37:37'),
	(17, 15, 'Cutting', 2, '2026-06-18 09:37:37'),
	(18, 15, 'Assembly', 3, '2026-06-18 09:37:37'),
	(19, 15, 'Quality Check', 4, '2026-06-18 09:37:37'),
	(20, 15, 'Dispatch', 5, '2026-06-18 09:37:37'),
	(21, 16, 'Read Content', 1, '2026-06-18 09:37:43'),
	(22, 16, 'Watch Video', 2, '2026-06-18 09:37:43'),
	(23, 16, 'Practice', 3, '2026-06-18 09:37:43'),
	(24, 16, 'Assessment', 4, '2026-06-18 09:37:43'),
	(25, 16, 'Certification', 5, '2026-06-18 09:37:43');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_sections: ~1 rows (approximately)
INSERT INTO `cms_sections` (`id`, `stream_id`, `title`, `description`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'Introduction to UPVC', 'Basic understanding of UPVC products', 'active', 0, '2026-06-18 09:34:30', '2026-06-18 09:34:30');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.cms_streams: ~1 rows (approximately)
INSERT INTO `cms_streams` (`id`, `category_id`, `title`, `language`, `icon_url`, `content`, `status`, `sort_order`, `created_at`, `updated_at`) VALUES
	(1, 1, 'UPVC Windows', 'English', 'stream1.png', 'UPVC Product Learning Stream', 'active', 0, '2026-06-18 09:34:23', '2026-06-18 09:34:23');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
