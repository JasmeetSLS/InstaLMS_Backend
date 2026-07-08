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


-- Dumping database structure for school_erp
CREATE DATABASE IF NOT EXISTS `school_erp` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `school_erp`;

-- Dumping structure for table school_erp.book_issues
CREATE TABLE IF NOT EXISTS `book_issues` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `book_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `issue_date` date NOT NULL,
  `due_date` date NOT NULL,
  `return_date` date DEFAULT NULL,
  `fine_amount` decimal(10,2) DEFAULT '0.00',
  `status` enum('issued','returned','overdue') DEFAULT 'issued',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `book_id` (`book_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `book_issues_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE,
  CONSTRAINT `book_issues_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.book_issues: ~2 rows (approximately)
INSERT INTO `book_issues` (`id`, `book_id`, `student_id`, `issue_date`, `due_date`, `return_date`, `fine_amount`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 2, '2026-07-09', '2026-07-23', '2026-07-04', 0.00, 'returned', '2026-07-04 11:04:41', '2026-07-04 11:05:46'),
	(2, 1, 2, '2026-07-10', '2026-07-23', '2026-07-04', 0.00, 'returned', '2026-07-04 11:18:16', '2026-07-04 11:18:35');

-- Dumping structure for table school_erp.books
CREATE TABLE IF NOT EXISTS `books` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `author` varchar(100) NOT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `available` int unsigned NOT NULL DEFAULT '1',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `isbn` (`isbn`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.books: ~2 rows (approximately)
INSERT INTO `books` (`id`, `title`, `author`, `isbn`, `quantity`, `available`, `status`, `created_at`, `updated_at`) VALUES
	(1, 's', 'as', 'sas', 1, 1, 'active', '2026-07-04 11:04:23', '2026-07-04 11:18:35'),
	(2, 'Sample', 'Sample', 'sds', 1, 1, 'active', '2026-07-05 06:48:04', '2026-07-05 06:48:04');

-- Dumping structure for table school_erp.calendar_events
CREATE TABLE IF NOT EXISTS `calendar_events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text,
  `event_type` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `color` varchar(7) DEFAULT '#3B82F6',
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.calendar_events: ~1 rows (approximately)
INSERT INTO `calendar_events` (`id`, `title`, `description`, `event_type`, `start_date`, `end_date`, `start_time`, `end_time`, `location`, `color`, `attachment`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Testing', 'Testing', 'Holiday', '2026-07-04', '2026-07-04', '12:07:00', '18:07:00', 'Testing', '#3B82F6', '/uploads/calendar/1/event-1783147077735.pdf', 'active', '2026-07-04 06:37:57', '2026-07-04 06:37:57');

-- Dumping structure for table school_erp.class_teachers
CREATE TABLE IF NOT EXISTS `class_teachers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `teacher_id` bigint unsigned NOT NULL,
  `class_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `class_id` (`class_id`),
  KEY `section_id` (`section_id`),
  CONSTRAINT `class_teachers_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_teachers_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_teachers_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.class_teachers: ~2 rows (approximately)
INSERT INTO `class_teachers` (`id`, `teacher_id`, `class_id`, `section_id`, `academic_year`, `status`, `created_at`, `updated_at`) VALUES
	(1, 3, 1, 1, '2026-2027', 'active', '2026-07-01 05:22:20', '2026-07-01 05:22:20'),
	(2, 3, 1, 2, '2026-2027', 'active', '2026-07-01 05:25:25', '2026-07-01 05:25:25');

-- Dumping structure for table school_erp.classes
CREATE TABLE IF NOT EXISTS `classes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.classes: ~2 rows (approximately)
INSERT INTO `classes` (`id`, `name`, `status`, `created_at`, `updated_at`) VALUES
	(1, '1', 'active', '2026-06-28 10:08:29', '2026-06-28 10:08:29'),
	(2, '2', 'active', '2026-06-28 10:10:09', '2026-06-28 10:10:09');

-- Dumping structure for table school_erp.events
CREATE TABLE IF NOT EXISTS `events` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text,
  `event_type` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `venue` varchar(200) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.events: ~1 rows (approximately)
INSERT INTO `events` (`id`, `title`, `description`, `event_type`, `start_date`, `end_date`, `venue`, `attachment`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Testing', 'Testing', 'Sports Day', '2026-07-17', '2026-07-22', 'Etsting', '/uploads/events/1/event-1783165494271.jpg', 'active', '2026-07-04 11:44:54', '2026-07-04 11:44:54');

-- Dumping structure for table school_erp.exam_marks
CREATE TABLE IF NOT EXISTS `exam_marks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `exam_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `marks_obtained` decimal(5,2) DEFAULT NULL,
  `grade` varchar(5) DEFAULT NULL,
  `remarks` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_exam_student` (`exam_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `exam_marks_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exam_marks_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.exam_marks: ~0 rows (approximately)
INSERT INTO `exam_marks` (`id`, `exam_id`, `student_id`, `marks_obtained`, `grade`, `remarks`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 2, 100.00, 'A+', 'Top', 'active', '2026-07-03 11:30:02', '2026-07-03 11:30:02');

-- Dumping structure for table school_erp.exams
CREATE TABLE IF NOT EXISTS `exams` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `exam_type` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `class_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `max_marks` decimal(5,2) NOT NULL DEFAULT '100.00',
  `passing_marks` decimal(5,2) NOT NULL DEFAULT '35.00',
  `exam_date` date DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `section_id` (`section_id`),
  KEY `subject_id` (`subject_id`),
  CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.exams: ~1 rows (approximately)
INSERT INTO `exams` (`id`, `exam_type`, `name`, `class_id`, `section_id`, `subject_id`, `academic_year`, `max_marks`, `passing_marks`, `exam_date`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Mid Term', 'Testing', 1, 1, 5, '2026-2027', 100.00, 35.00, '2026-07-10', 'active', '2026-07-03 11:29:48', '2026-07-03 11:29:48');

-- Dumping structure for table school_erp.grades
CREATE TABLE IF NOT EXISTS `grades` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `grade` varchar(5) NOT NULL,
  `min_marks` decimal(5,2) NOT NULL,
  `max_marks` decimal(5,2) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_grade` (`grade`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.grades: ~7 rows (approximately)
INSERT INTO `grades` (`id`, `grade`, `min_marks`, `max_marks`, `description`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'A+', 90.00, 100.00, 'Outstanding', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(2, 'A', 80.00, 89.00, 'Excellent', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(3, 'B+', 70.00, 79.00, 'Very Good', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(4, 'B', 60.00, 69.00, 'Good', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(5, 'C', 50.00, 59.00, 'Average', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(6, 'D', 35.00, 49.00, 'Below Average', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08'),
	(7, 'F', 0.00, 34.00, 'Fail', 'active', '2026-07-03 10:32:08', '2026-07-03 10:32:08');

-- Dumping structure for table school_erp.homework
CREATE TABLE IF NOT EXISTS `homework` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `class_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `teacher_id` bigint unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text,
  `due_date` date NOT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `section_id` (`section_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `homework_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `homework_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `homework_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `homework_ibfk_4` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.homework: ~0 rows (approximately)
INSERT INTO `homework` (`id`, `class_id`, `section_id`, `subject_id`, `teacher_id`, `title`, `description`, `due_date`, `attachment`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 5, 3, 'Testing', 'Testing', '2026-07-03', '/uploads/homework/1/attachment-1782971633832.pdf', 'active', '2026-07-02 05:53:53', '2026-07-05 16:19:20');

-- Dumping structure for table school_erp.homework_submissions
CREATE TABLE IF NOT EXISTS `homework_submissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `homework_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `submission_text` text,
  `attachment` varchar(255) DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Pending','Submitted','Evaluated') DEFAULT 'Pending',
  `marks` decimal(5,2) DEFAULT NULL,
  `teacher_remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_homework_student` (`homework_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `homework_submissions_ibfk_1` FOREIGN KEY (`homework_id`) REFERENCES `homework` (`id`) ON DELETE CASCADE,
  CONSTRAINT `homework_submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.homework_submissions: ~0 rows (approximately)

-- Dumping structure for table school_erp.modules
CREATE TABLE IF NOT EXISTS `modules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `module_code` varchar(50) NOT NULL,
  `module_name` varchar(100) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `module_code` (`module_code`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.modules: ~24 rows (approximately)
INSERT INTO `modules` (`id`, `module_code`, `module_name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'STUDENT', 'Student Management', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(2, 'TEACHER', 'Teacher Management', 'active', '2026-06-21 11:07:49', '2026-06-21 11:07:49'),
	(3, 'STUDENT_ATTENDANCE', 'Student Attendance', 'active', '2026-06-21 11:21:09', '2026-06-21 11:21:09'),
	(4, 'TEACHER_ATTENDANCE', 'Teacher Attendance', 'active', '2026-06-21 11:26:03', '2026-06-21 11:26:03'),
	(5, 'ROLE_PERMISSION', 'Role & Permission', 'active', '2026-06-21 15:32:25', '2026-06-21 15:32:25'),
	(6, 'TIMETABLE', 'Timetable Management', 'active', '2026-06-23 10:10:49', '2026-07-01 06:44:43'),
	(7, 'CLASS_SECTION', 'Class & Section Management', 'active', '2026-06-23 10:13:56', '2026-06-28 10:05:47'),
	(8, 'SUBJECTS', 'Subjects Management', 'active', '2026-06-28 09:25:44', '2026-06-28 15:33:39'),
	(9, 'CLASS_TEACHERS', 'Class Teachers', 'active', '2026-06-28 15:34:05', '2026-06-28 15:34:06'),
	(10, 'ONLINE_MEET_LINKS', 'Online Meet Links', 'active', '2026-07-01 12:06:09', '2026-07-01 12:06:09'),
	(11, 'HOMEWORK', 'Homework Management', 'active', '2026-07-02 05:32:07', '2026-07-02 05:32:07'),
	(12, 'STUDY_MATERIAL', 'Study Material', 'active', '2026-07-02 06:10:53', '2026-07-02 06:10:53'),
	(13, 'EXAM', 'Exam Management', 'active', '2026-07-02 08:54:10', '2026-07-03 10:33:16'),
	(14, 'RESULT', 'Result Management', 'active', '2026-07-02 10:22:45', '2026-07-03 10:33:30'),
	(15, 'NOTICE', 'Notice Board', 'active', '2026-07-04 06:15:44', '2026-07-04 06:15:44'),
	(16, 'CALENDAR', 'Calendar', 'active', '2026-07-04 06:33:32', '2026-07-04 06:33:32'),
	(17, 'TRANSPORT', 'Transport Management', 'active', '2026-07-04 06:42:00', '2026-07-04 08:12:36'),
	(18, 'STUDENT_TRANSPORT', 'Student Transport', 'active', '2026-07-04 06:42:00', '2026-07-04 08:12:25'),
	(19, 'BOOKS', 'Books', 'active', '2026-07-04 09:52:00', '2026-07-04 10:24:45'),
	(20, 'BOOK_ISSUE', 'Book Issue', 'active', '2026-07-04 09:52:00', '2026-07-04 10:24:40'),
	(21, 'BOOK_RECORD', 'Book Record', 'active', '2026-07-04 10:24:04', '2026-07-04 10:24:04'),
	(22, 'ACHIEVEMENT', 'Student Achievements', 'active', '2026-07-04 11:19:39', '2026-07-04 11:19:39'),
	(24, 'EVENT', 'Events', 'active', '2026-07-04 11:41:20', '2026-07-04 11:41:20'),
	(25, 'LEAVE', 'Student Leave', 'active', '2026-07-04 11:51:52', '2026-07-04 11:51:52');

-- Dumping structure for table school_erp.notices
CREATE TABLE IF NOT EXISTS `notices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `description` text,
  `type` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.notices: ~1 rows (approximately)
INSERT INTO `notices` (`id`, `title`, `description`, `type`, `start_date`, `end_date`, `attachment`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Testing', 'Testing', 'Holiday', '2026-07-15', '2026-07-30', '/uploads/notices/1/notice-1783146037835.pdf', 'active', '2026-07-04 06:20:37', '2026-07-04 06:20:37');

-- Dumping structure for table school_erp.permissions
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint unsigned NOT NULL,
  `module_id` bigint unsigned NOT NULL,
  `can_view` tinyint(1) DEFAULT '0',
  `can_create` tinyint(1) DEFAULT '0',
  `can_update` tinyint(1) DEFAULT '0',
  `can_delete` tinyint(1) DEFAULT '0',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_module` (`role_id`,`module_id`),
  KEY `module_id` (`module_id`),
  CONSTRAINT `permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `permissions_ibfk_2` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.permissions: ~71 rows (approximately)
INSERT INTO `permissions` (`id`, `role_id`, `module_id`, `can_view`, `can_create`, `can_update`, `can_delete`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 22, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(2, 1, 20, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(3, 1, 21, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(4, 1, 19, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(5, 1, 16, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(6, 1, 7, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(7, 1, 9, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(8, 1, 13, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(9, 1, 11, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(10, 1, 15, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(11, 1, 10, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(12, 1, 14, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(13, 1, 5, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(14, 1, 1, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(15, 1, 3, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(16, 1, 18, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(17, 1, 12, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(18, 1, 8, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(19, 1, 2, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(20, 1, 4, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(21, 1, 6, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(22, 1, 17, 1, 1, 1, 1, 'active', '2026-07-04 11:23:31', '2026-07-04 11:23:31'),
	(32, 1, 24, 1, 1, 1, 1, 'active', '2026-07-04 11:41:32', '2026-07-04 11:41:32'),
	(33, 1, 25, 1, 1, 1, 1, 'active', '2026-07-04 11:52:04', '2026-07-04 11:52:04'),
	(34, 4, 20, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(35, 4, 21, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(36, 4, 19, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(37, 4, 16, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(38, 4, 7, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(39, 4, 9, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(40, 4, 24, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(41, 4, 13, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(42, 4, 11, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(43, 4, 15, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(44, 4, 10, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(45, 4, 14, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(46, 4, 5, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(47, 4, 22, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(48, 4, 3, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(49, 4, 25, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(50, 4, 1, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(51, 4, 18, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(52, 4, 12, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(53, 4, 8, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(54, 4, 4, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(55, 4, 2, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(56, 4, 6, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(57, 4, 17, 1, 0, 0, 0, 'active', '2026-07-05 06:16:36', '2026-07-05 06:16:36'),
	(58, 3, 20, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(59, 3, 21, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(60, 3, 19, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(61, 3, 16, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(62, 3, 7, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(63, 3, 9, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(64, 3, 24, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(65, 3, 13, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(66, 3, 11, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(67, 3, 15, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(68, 3, 14, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(69, 3, 5, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(70, 3, 22, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(71, 3, 3, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(72, 3, 25, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(73, 3, 1, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(74, 3, 18, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(75, 3, 12, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(76, 3, 8, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(77, 3, 4, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(78, 3, 2, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(79, 3, 6, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46'),
	(80, 3, 17, 1, 0, 0, 0, 'active', '2026-07-05 16:18:46', '2026-07-05 16:18:46');

-- Dumping structure for table school_erp.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_name` varchar(100) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.roles: ~6 rows (approximately)
INSERT INTO `roles` (`id`, `role_name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Super Admin', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(2, 'Admin', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(3, 'Teacher', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(4, 'Student', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(5, 'Librarian', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30'),
	(6, 'Transport', 'active', '2026-06-21 10:29:30', '2026-06-21 10:29:30');

-- Dumping structure for table school_erp.sections
CREATE TABLE IF NOT EXISTS `sections` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `class_id` bigint unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_section` (`class_id`,`name`),
  CONSTRAINT `sections_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.sections: ~4 rows (approximately)
INSERT INTO `sections` (`id`, `class_id`, `name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 'A', 'active', '2026-06-28 10:09:59', '2026-06-28 10:09:59'),
	(2, 1, 'B', 'active', '2026-06-28 10:10:04', '2026-06-28 10:10:04'),
	(3, 2, 'A', 'active', '2026-06-28 10:10:15', '2026-06-28 10:10:15'),
	(4, 2, 'B', 'active', '2026-06-28 10:10:20', '2026-06-28 10:10:20'),
	(5, 1, 'C', 'active', '2026-06-28 10:15:21', '2026-06-28 10:15:21');

-- Dumping structure for table school_erp.student_achievements
CREATE TABLE IF NOT EXISTS `student_achievements` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `student_id` bigint unsigned NOT NULL,
  `achievement_type` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text,
  `achievement_date` date NOT NULL,
  `level` varchar(50) DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `student_achievements_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.student_achievements: ~0 rows (approximately)
INSERT INTO `student_achievements` (`id`, `student_id`, `achievement_type`, `title`, `description`, `achievement_date`, `level`, `attachment`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 'Award', 'Testing', 'Testing', '2026-07-04', 'School', '/uploads/achievements/1/ach-1783164465087.png', 'active', '2026-07-04 11:27:45', '2026-07-04 11:27:45');

-- Dumping structure for table school_erp.student_attendance
CREATE TABLE IF NOT EXISTS `student_attendance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `student_id` bigint unsigned NOT NULL,
  `attendance_date` date NOT NULL,
  `status` enum('Present','Absent','Late','Leave') NOT NULL,
  `remarks` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_date` (`student_id`,`attendance_date`),
  CONSTRAINT `student_attendance_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.student_attendance: ~3 rows (approximately)
INSERT INTO `student_attendance` (`id`, `student_id`, `attendance_date`, `status`, `remarks`, `created_at`, `updated_at`) VALUES
	(1, 2, '2026-06-22', 'Present', 'Present', '2026-06-28 10:58:41', '2026-06-28 10:58:41'),
	(2, 11, '2026-06-28', 'Present', 'Present\n', '2026-06-28 15:14:02', '2026-06-28 15:14:02'),
	(3, 2, '2026-07-15', 'Present', 'Present\n', '2026-07-05 07:14:22', '2026-07-05 07:14:22');

-- Dumping structure for table school_erp.student_details
CREATE TABLE IF NOT EXISTS `student_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `class_id` bigint unsigned DEFAULT NULL,
  `section_id` bigint unsigned DEFAULT NULL,
  `father_name` varchar(100) DEFAULT NULL,
  `mother_name` varchar(100) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `blood_group` varchar(10) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `roll_number` varchar(20) DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  `address` text,
  `father_phone` varchar(20) DEFAULT NULL,
  `father_occupation` varchar(100) DEFAULT NULL,
  `mother_phone` varchar(20) DEFAULT NULL,
  `mother_occupation` varchar(100) DEFAULT NULL,
  `sibling_details` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `fk_student_class` (`class_id`),
  KEY `fk_student_section` (`section_id`),
  CONSTRAINT `fk_student_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_student_details_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_student_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.student_details: ~5 rows (approximately)
INSERT INTO `student_details` (`id`, `user_id`, `class_id`, `section_id`, `father_name`, `mother_name`, `dob`, `gender`, `blood_group`, `profile_picture`, `roll_number`, `admission_date`, `address`, `father_phone`, `father_occupation`, `mother_phone`, `mother_occupation`, `sibling_details`) VALUES
	(1, 2, 1, 1, 'Bittu', 'Rekha', '2002-06-22', 'Male', NULL, '/uploads/students/3/profile-1782208792109.jpg', 'R001', '2026-06-01', '123 Main Street, City', '9876543210', NULL, '9876543211', NULL, NULL),
	(2, 4, 1, 2, 'Deepak', 'Sunita', '2026-06-15', 'Male', NULL, '/uploads/students/3/profile-1782208792109.jpg', 'R002', '2026-06-15', '456 Park Avenue, Town', '9876543212', NULL, '9876543213', NULL, NULL),
	(3, 9, 1, 5, 'Easter', 'Rekha', '2009-06-16', 'Male', NULL, '/uploads/students/3/profile-1782208792109.jpg', '20', '2026-06-16', 'A-909,Rajiv Chowk', '2323232', NULL, '12121212', NULL, NULL),
	(5, 10, 2, 3, 'sdsd', 'dsd', '2006-06-28', 'Male', 'A', '/uploads/students/3/profile-1782208792109.jpg', '14', '2026-06-28', 'sas', '212132', 'sdsd', '2323', 'dsd', 'ewe'),
	(7, 11, 2, 4, 'sdsd', 'ssdsd', '2009-06-08', 'Male', 'o+', '/uploads/students/11/profile-1782641805600.jpg', '23', '2026-06-26', 'ddsdsd', '212121212', 'dsdsd', '2121212', 'wewewe', 'wewe');

-- Dumping structure for table school_erp.student_leaves
CREATE TABLE IF NOT EXISTS `student_leaves` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `student_id` bigint unsigned NOT NULL,
  `leave_type` varchar(50) NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `reason` text,
  `leave_status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `applied_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_by` bigint unsigned DEFAULT NULL,
  `approved_date` date DEFAULT NULL,
  `remarks` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `approved_by` (`approved_by`),
  CONSTRAINT `student_leaves_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_leaves_ibfk_2` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.student_leaves: ~2 rows (approximately)
INSERT INTO `student_leaves` (`id`, `student_id`, `leave_type`, `from_date`, `to_date`, `reason`, `leave_status`, `applied_date`, `approved_by`, `approved_date`, `remarks`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 'TEsting', '2026-07-04', '2026-07-04', 'Testing', 'Approved', '2026-07-04 11:55:32', 1, '2026-07-04', 'Testing', 'active', '2026-07-04 11:55:40', '2026-07-04 11:56:04'),
	(2, 4, 'Sick', '2026-07-09', '2026-07-15', 'Testing', 'Pending', '2026-07-04 11:59:56', NULL, NULL, NULL, 'active', '2026-07-04 11:59:56', '2026-07-04 12:01:05');

-- Dumping structure for table school_erp.student_transports
CREATE TABLE IF NOT EXISTS `student_transports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `student_id` bigint unsigned NOT NULL,
  `transport_id` bigint unsigned NOT NULL,
  `pickup_point` varchar(100) DEFAULT NULL,
  `drop_point` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_transport` (`student_id`,`transport_id`),
  KEY `transport_id` (`transport_id`),
  CONSTRAINT `student_transports_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_transports_ibfk_2` FOREIGN KEY (`transport_id`) REFERENCES `transports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.student_transports: ~2 rows (approximately)
INSERT INTO `student_transports` (`id`, `student_id`, `transport_id`, `pickup_point`, `drop_point`, `status`, `created_at`, `updated_at`) VALUES
	(1, 2, 1, 'Testing', 'Testing', 'active', '2026-07-04 08:17:39', '2026-07-04 08:17:39'),
	(2, 4, 1, 'asaasa', 'sas', 'active', '2026-07-04 08:19:54', '2026-07-04 08:19:54');

-- Dumping structure for table school_erp.study_materials
CREATE TABLE IF NOT EXISTS `study_materials` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `class_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `teacher_id` bigint unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text,
  `type` enum('pdf','note','video','ppt','lecture','ebook','link') NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `link_url` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `section_id` (`section_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `study_materials_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `study_materials_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `study_materials_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `study_materials_ibfk_4` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.study_materials: ~2 rows (approximately)
INSERT INTO `study_materials` (`id`, `class_id`, `section_id`, `subject_id`, `teacher_id`, `title`, `description`, `type`, `file_path`, `link_url`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 5, 1, 'Testing', 'Testing', 'pdf', '/uploads/study_materials/1/file-1782974893085.pdf', '', 'active', '2026-07-02 06:48:13', '2026-07-02 06:48:13'),
	(2, 2, 3, 7, 1, 'Tesrtig', 'Tesrtig', 'video', '/uploads/study_materials/2/file-1782975127618.mp4', '', 'active', '2026-07-02 06:52:07', '2026-07-02 06:52:07');

-- Dumping structure for table school_erp.subjects
CREATE TABLE IF NOT EXISTS `subjects` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.subjects: ~8 rows (approximately)
INSERT INTO `subjects` (`id`, `name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'English', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(2, 'Mathematics', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(3, 'EVS', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(4, 'Hindi', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(5, 'Art', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(6, 'Music', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(7, 'Computer', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12'),
	(8, 'General', 'active', '2026-07-01 10:26:12', '2026-07-01 10:26:12');

-- Dumping structure for table school_erp.teacher_attendance
CREATE TABLE IF NOT EXISTS `teacher_attendance` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `teacher_id` bigint unsigned NOT NULL,
  `attendance_date` date NOT NULL,
  `status` enum('Present','Absent','Late','Leave') DEFAULT 'Present',
  `check_in_time` time DEFAULT NULL,
  `check_out_time` time DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_teacher_date` (`teacher_id`,`attendance_date`),
  CONSTRAINT `teacher_attendance_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.teacher_attendance: ~1 rows (approximately)
INSERT INTO `teacher_attendance` (`id`, `teacher_id`, `attendance_date`, `status`, `check_in_time`, `check_out_time`, `created_at`, `updated_at`) VALUES
	(1, 3, '2026-06-21', 'Present', '13:50:00', '00:00:00', '2026-06-21 11:32:12', '2026-06-21 17:20:06');

-- Dumping structure for table school_erp.teacher_details
CREATE TABLE IF NOT EXISTS `teacher_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `joining_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `teacher_details_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.teacher_details: ~5 rows (approximately)
INSERT INTO `teacher_details` (`id`, `user_id`, `qualification`, `gender`, `date_of_birth`, `profile_picture`, `joining_date`) VALUES
	(1, 3, 'B.sc', 'Male', '2002-06-23', '/uploads/teachers/8/profile-1782196790532.jpg', '2026-06-15'),
	(2, 5, 'B.tech', 'Male', '2001-06-02', '/uploads/teachers/8/profile-1782196790532.jpg', '2026-06-09'),
	(3, 6, 'B.Tech', 'Male', '1996-06-17', '/uploads/teachers/8/profile-1782196790532.jpg', '2026-06-16'),
	(4, 7, 'B.sc', 'Male', '1990-06-09', '/uploads/teachers/8/profile-1782196790532.jpg', '2026-06-09'),
	(5, 8, 'B.Tech', 'Male', '1990-06-09', '/uploads/teachers/8/profile-1782196790532.jpg', '2026-06-01');

-- Dumping structure for table school_erp.timetable
CREATE TABLE IF NOT EXISTS `timetable` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `class_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') DEFAULT NULL,
  `period_number` tinyint unsigned NOT NULL,
  `subject_id` bigint unsigned NOT NULL,
  `teacher_id` bigint unsigned NOT NULL,
  `room` varchar(20) DEFAULT NULL,
  `online_link` varchar(255) DEFAULT NULL,
  `academic_year` varchar(20) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `section_id` (`section_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `timetable_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_ibfk_4` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.timetable: ~48 rows (approximately)
INSERT INTO `timetable` (`id`, `class_id`, `section_id`, `day_of_week`, `period_number`, `subject_id`, `teacher_id`, `room`, `online_link`, `academic_year`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 'Monday', 1, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(2, 1, 1, 'Monday', 2, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(3, 1, 1, 'Monday', 3, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(4, 1, 1, 'Monday', 4, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(5, 1, 1, 'Monday', 5, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(6, 1, 1, 'Monday', 6, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(7, 1, 1, 'Monday', 7, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(8, 1, 1, 'Monday', 8, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(16, 1, 1, 'Tuesday', 1, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(17, 1, 1, 'Tuesday', 2, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(18, 1, 1, 'Tuesday', 3, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(19, 1, 1, 'Tuesday', 4, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(20, 1, 1, 'Tuesday', 5, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(21, 1, 1, 'Tuesday', 6, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(22, 1, 1, 'Tuesday', 7, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(23, 1, 1, 'Tuesday', 8, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:03', '2026-07-05 16:04:03'),
	(31, 1, 1, 'Wednesday', 1, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(32, 1, 1, 'Wednesday', 2, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(33, 1, 1, 'Wednesday', 3, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(34, 1, 1, 'Wednesday', 4, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(35, 1, 1, 'Wednesday', 5, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(36, 1, 1, 'Wednesday', 6, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(37, 1, 1, 'Wednesday', 7, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(38, 1, 1, 'Wednesday', 8, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(46, 1, 1, 'Thursday', 1, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(47, 1, 1, 'Thursday', 2, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(48, 1, 1, 'Thursday', 3, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(49, 1, 1, 'Thursday', 4, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(50, 1, 1, 'Thursday', 5, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(51, 1, 1, 'Thursday', 6, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(52, 1, 1, 'Thursday', 7, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(53, 1, 1, 'Thursday', 8, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(61, 1, 1, 'Friday', 1, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(62, 1, 1, 'Friday', 2, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(63, 1, 1, 'Friday', 3, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(64, 1, 1, 'Friday', 4, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(65, 1, 1, 'Friday', 5, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(66, 1, 1, 'Friday', 6, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(67, 1, 1, 'Friday', 7, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(68, 1, 1, 'Friday', 8, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(76, 1, 1, 'Saturday', 1, 1, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(77, 1, 1, 'Saturday', 2, 2, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(78, 1, 1, 'Saturday', 3, 3, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(79, 1, 1, 'Saturday', 4, 4, 7, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(80, 1, 1, 'Saturday', 5, 5, 8, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(81, 1, 1, 'Saturday', 6, 6, 3, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(82, 1, 1, 'Saturday', 7, 7, 5, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04'),
	(83, 1, 1, 'Saturday', 8, 8, 6, 'Room 101', NULL, '2026-27', 'active', '2026-07-05 16:04:04', '2026-07-05 16:04:04');

-- Dumping structure for table school_erp.transports
CREATE TABLE IF NOT EXISTS `transports` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `route_name` varchar(100) NOT NULL,
  `driver_name` varchar(100) NOT NULL,
  `driver_phone` varchar(20) NOT NULL,
  `pickup_time` time NOT NULL,
  `drop_time` time NOT NULL,
  `route_details` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.transports: ~2 rows (approximately)
INSERT INTO `transports` (`id`, `route_name`, `driver_name`, `driver_phone`, `pickup_time`, `drop_time`, `route_details`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Testing', 'Testing', '12121212', '13:47:00', '13:47:00', 'Testing', 'active', '2026-07-04 08:17:19', '2026-07-04 08:17:19'),
	(2, 'sas', 'asa', '21212', '13:50:00', '01:50:00', 'sas', 'active', '2026-07-04 08:20:14', '2026-07-04 08:20:14');

-- Dumping structure for table school_erp.user_roles
CREATE TABLE IF NOT EXISTS `user_roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.user_roles: ~11 rows (approximately)
INSERT INTO `user_roles` (`id`, `user_id`, `role_id`, `status`, `created_at`) VALUES
	(1, 1, 1, 'active', '2026-06-21 10:37:21'),
	(2, 2, 4, 'active', '2026-06-21 10:39:21'),
	(3, 3, 3, 'active', '2026-06-21 11:31:35'),
	(4, 4, 4, 'active', '2026-06-21 17:42:50'),
	(5, 5, 3, 'active', '2026-06-23 05:32:11'),
	(6, 6, 3, 'active', '2026-06-23 06:06:55'),
	(7, 7, 3, 'active', '2026-06-23 06:23:17'),
	(8, 8, 3, 'active', '2026-06-23 06:39:50'),
	(9, 9, 4, 'active', '2026-06-23 09:58:43'),
	(10, 10, 4, 'active', '2026-06-28 07:54:57'),
	(11, 11, 4, 'active', '2026-06-28 10:16:45');

-- Dumping structure for table school_erp.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `login_id` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `device_type` enum('android','ios','web') DEFAULT 'web',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_id` (`login_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table school_erp.users: ~11 rows (approximately)
INSERT INTO `users` (`id`, `login_id`, `password`, `full_name`, `email`, `mobile`, `fcm_token`, `device_type`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'SA001', '$2a$12$Em9Sg2K43D5LRPvEaVPQ0OPOtP3UiIWR0xivcHayBf34/KMiJvGdm', 'SuperAdmin', 'SuperAdmin@gmail.com', '989898989', 'abc123...', 'android', 'active', '2026-06-21 10:35:05', '2026-07-05 07:09:07'),
	(2, 'STD001', '$2b$10$hyjwGey.ZV.9UCDUa6jkF.MkqjnTBnVvMKAM6H8TdyoGUAuAZB9xe', 'Nikhil', 'nikhil@gmail.com', '898989898', 'abc123...', 'android', 'active', '2026-06-21 10:39:21', '2026-07-05 06:41:05'),
	(3, 'TC001', '$2b$10$W0diP0hFg7vCdSONWhR9euI8dWBL4e4QUVq5uomtTLxy6bHtfkKGW', 'Deepak', 'deepak@gmail.com', '212121212', 'abc123...', 'android', 'active', '2026-06-21 11:31:35', '2026-07-05 06:56:01'),
	(4, 'STD002', '$2b$10$WUDRq5VJ3KMrhfDIQOnut.tjAnVf31i8nuTLKJAF.6rxTOSr7cthG', 'Rakesh', 'Rakesh@gmail.com', '676767676', 'abc123...', 'android', 'active', '2026-06-21 17:42:50', '2026-07-05 07:46:05'),
	(5, 'TC002', '$2b$10$wNJ2Sekd9Wipj32PWNYNmOp9NgjlbWqtYZIgszAA6B0/RgWi7ZG7u', 'Chintu', 'chintu@gmail.com', '92393239', 'abc123...', 'android', 'active', '2026-06-23 05:32:11', '2026-07-05 16:19:44'),
	(6, 'TC003', '$2b$10$Vgx.D33xAuTMVvCCy3Nw/eW5VtSYVkyxYsbeYFdkptrhnW22R0EFu', 'Gaurav', 'gaurav@gmail.com', '323232332', NULL, 'web', 'active', '2026-06-23 06:06:55', '2026-06-23 06:06:55'),
	(7, 'TC004', '$2b$10$TlLkzmULZIx1hv5M/AoizOq6zdJDYFOt8Kt7rVDirTKwhxkQYx5ti', 'Rishi', 'rishi@gmail.com', '90909090', NULL, 'web', 'active', '2026-06-23 06:23:17', '2026-06-23 06:23:17'),
	(8, 'TC005', '$2b$10$IyB56AGMg1xDWVc4svwsPempId5FnMs3gJ2W8oJC3Z7TovHid/jvq', 'Bittu', 'bittu@gmail.com', '787878787', NULL, 'web', 'active', '2026-06-23 06:39:50', '2026-06-23 06:39:50'),
	(9, 'STD003', '$2b$10$rrq027zzuif2Q/.KfhUDj.W0i2EXEdC9qqf4i2CDFfnYVZaG0mVD6', 'Deepak', 'deepak@gmail.com', '2121212', 'abc123...', 'android', 'active', '2026-06-23 09:58:43', '2026-07-05 16:17:15'),
	(10, 'STD004', '$2b$10$57yttniK2T3DcKEaQ875U.91Qb.VxtalDtwk/JCMyPwsMeQ/hk2SC', 'Chintu', 'chintu@gmail.com', '21212', 'abc123...', 'android', 'active', '2026-06-28 07:54:57', '2026-07-05 16:20:04'),
	(11, 'STD005', '$2b$10$IGt5cT8.FaHNNdgQfDilCePU1VP1sPHIE3oKVH.lUQgyXgZY6M0sO', 'harsh', 'harsh@gmail.com', '89898989', NULL, 'web', 'active', '2026-06-28 10:16:45', '2026-06-28 10:16:45');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
