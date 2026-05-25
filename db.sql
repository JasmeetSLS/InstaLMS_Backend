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


-- Dumping database structure for Hero_ZSSC_Final
CREATE DATABASE IF NOT EXISTS `Hero_ZSSC_Final` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `Hero_ZSSC_Final`;

-- Dumping structure for table Hero_ZSSC_Final.assignment_categories
CREATE TABLE IF NOT EXISTS `assignment_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `category_id` int NOT NULL,
  `question_count` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `assignment_categories_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.assignment_languages
CREATE TABLE IF NOT EXISTS `assignment_languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `language_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_assignment_language` (`assignment_id`,`language_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `assignment_languages_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_languages_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.attendance
CREATE TABLE IF NOT EXISTS `attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `attendance_url` varchar(500) DEFAULT NULL,
  `match_face_id` varchar(255) DEFAULT NULL,
  `face_confidence` decimal(5,2) DEFAULT NULL,
  `market_status` enum('Present','Absent','Late','Half Day') DEFAULT 'Present',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_attendance_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=386 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.base_questions
CREATE TABLE IF NOT EXISTS `base_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `assignment_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `fk_base_questions_assignment` (`assignment_id`),
  CONSTRAINT `base_questions_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_base_questions_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.dealers
CREATE TABLE IF NOT EXISTS `dealers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealer_code` varchar(50) NOT NULL,
  `dealer_name` varchar(255) NOT NULL,
  `dealer_location` varchar(255) DEFAULT NULL,
  `area_office` varchar(255) DEFAULT NULL,
  `zone` varchar(100) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealer_code` (`dealer_code`)
) ENGINE=InnoDB AUTO_INCREMENT=245 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.designations
CREATE TABLE IF NOT EXISTS `designations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.languages
CREATE TABLE IF NOT EXISTS `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `translate_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.login_logs
CREATE TABLE IF NOT EXISTS `login_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `login_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `login_method` enum('huid','whatsapp') DEFAULT NULL,
  `status` enum('success','failed') DEFAULT NULL,
  `failure_reason` varchar(255) DEFAULT NULL,
  `device_info` text,
  `location` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `login_time` (`login_time`),
  CONSTRAINT `login_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=827 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.question_designations
CREATE TABLE IF NOT EXISTS `question_designations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `base_question_id` int NOT NULL,
  `designation_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_question_designation` (`base_question_id`,`designation_id`),
  KEY `designation_id` (`designation_id`),
  CONSTRAINT `question_designations_ibfk_1` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_designations_ibfk_2` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.question_options
CREATE TABLE IF NOT EXISTS `question_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `translation_id` int NOT NULL,
  `base_question_id` int NOT NULL,
  `option_text` text,
  `option_image_path` varchar(255) DEFAULT NULL,
  `marks` int DEFAULT '0',
  `original_order` int DEFAULT '0',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `translation_id` (`translation_id`),
  KEY `base_question_id` (`base_question_id`),
  CONSTRAINT `question_options_ibfk_1` FOREIGN KEY (`translation_id`) REFERENCES `question_translations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_options_ibfk_2` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2881 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.question_translations
CREATE TABLE IF NOT EXISTS `question_translations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `base_question_id` int NOT NULL,
  `language_id` int NOT NULL,
  `question` text NOT NULL,
  `question_media_path` varchar(255) DEFAULT NULL,
  `short_content` text,
  `long_content_text` text,
  `long_content_file_path` varchar(255) DEFAULT NULL,
  `long_content_audio_path` varchar(255) DEFAULT NULL,
  `question_answer_audio_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_question_translation` (`base_question_id`,`language_id`),
  KEY `language_id` (`language_id`),
  KEY `idx_base_question_id` (`base_question_id`),
  CONSTRAINT `question_translations_ibfk_1` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_translations_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=721 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.sn_codes
CREATE TABLE IF NOT EXISTS `sn_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sn_code` varchar(50) NOT NULL,
  `sn_name` varchar(255) NOT NULL,
  `dealer_code` varchar(50) NOT NULL,
  `dealer_name` varchar(255) NOT NULL,
  `area_office` varchar(255) DEFAULT NULL,
  `zone` varchar(100) DEFAULT NULL,
  `tso` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sn_code` (`sn_code`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.test_assignments
CREATE TABLE IF NOT EXISTS `test_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) DEFAULT '0',
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `passing_score` int DEFAULT '60',
  `shuffle_questions` tinyint(1) DEFAULT '0',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `total_marks` int DEFAULT '100',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `shuffle_options` tinyint(1) DEFAULT '0',
  `proctoring_auto_submit_enabled` tinyint(1) DEFAULT '1',
  `proctoring_warning_limit` int DEFAULT '5',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.user_assignment_completion
CREATE TABLE IF NOT EXISTS `user_assignment_completion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `assignment_id` int NOT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT (now()),
  `start_at` timestamp NULL DEFAULT (now()),
  `face_movement_count` int DEFAULT '0',
  `face_recognition_failure_count` int DEFAULT '0',
  `multiple_face_count` int DEFAULT '0',
  `tab_switch_count` int DEFAULT '0',
  `screenshot_attempt_count` int DEFAULT '0',
  `speech_detection_count` int DEFAULT '0',
  `face_not_detected_count` int DEFAULT '0',
  `status` enum('in_progress','user_submitted','auto_submit_timer','auto_submit_proctoring','locked') DEFAULT 'in_progress',
  `time_left` int DEFAULT NULL COMMENT 'Time left in seconds when test was submitted/auto-submitted',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`assignment_id`),
  KEY `assignment_id` (`assignment_id`),
  CONSTRAINT `user_assignment_completion_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_assignment_completion_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.user_responses
CREATE TABLE IF NOT EXISTS `user_responses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `base_question_id` int NOT NULL,
  `assignment_id` int DEFAULT NULL,
  `response_language_id` int DEFAULT NULL,
  `selected_option_id` int DEFAULT NULL,
  `marks_obtained` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `user_responses_ibfk_2` (`base_question_id`),
  KEY `fk_response_language` (`response_language_id`),
  KEY `idx_selected_option_id` (`selected_option_id`),
  CONSTRAINT `fk_response_language` FOREIGN KEY (`response_language_id`) REFERENCES `languages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_responses_option` FOREIGN KEY (`selected_option_id`) REFERENCES `question_options` (`id`) ON DELETE SET NULL,
  CONSTRAINT `user_responses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_responses_ibfk_2` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_responses_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3777 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table Hero_ZSSC_Final.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `huid` varchar(50) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `whatsapp_number` varchar(20) DEFAULT NULL,
  `dealer_id` int DEFAULT NULL,
  `tm` varchar(255) DEFAULT NULL,
  `designation_id` int DEFAULT NULL,
  `area_office` varchar(255) DEFAULT NULL,
  `zone` varchar(100) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `face_id` varchar(255) DEFAULT NULL,
  `front_adhaar` varchar(500) DEFAULT NULL,
  `back_adhaar` varchar(500) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT (now()),
  `updated_at` timestamp NULL DEFAULT (now()),
  `user_type` enum('Primary','Secondary') DEFAULT 'Primary',
  `sn_code_id` int DEFAULT NULL,
  `tshirt_size` enum('XS (36)','S (38)','M (40)','L (42)','XL (44)','2XL (46)','3XL (48)','4XL (50)') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `huid` (`huid`),
  KEY `fk_user_dealer` (`dealer_id`),
  KEY `fk_user_designation` (`designation_id`),
  KEY `fk_user_sn_code` (`sn_code_id`),
  KEY `idx_users_face_id` (`face_id`),
  CONSTRAINT `fk_user_dealer` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_designation` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_sn_code` FOREIGN KEY (`sn_code_id`) REFERENCES `sn_codes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
