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

-- Dumping structure for table insta_style_lms.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.categories: ~5 rows (approximately)
INSERT INTO `categories` (`id`, `name`, `icon_url`, `created_at`) VALUES
	(1, 'Product', '/uploads/1775044466337-car-sales_1d8acd.avif', '2026-04-01 11:54:26'),
	(2, 'Process', '/uploads/1775044476486-infographics0.avif', '2026-04-01 11:54:36'),
	(3, 'Technology', '/uploads/1775044604396-row-cars_83_1_0.jpg', '2026-04-01 11:54:48'),
	(4, 'BAT', '/uploads/1775044494997-images.jpg', '2026-04-01 11:54:55'),
	(5, 'Soft Skills', '/uploads/1775044488001-images (1).jpg', '2026-04-01 11:56:44');

-- Dumping structure for table insta_style_lms.post_media
CREATE TABLE IF NOT EXISTS `post_media` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `media_type` enum('image','video','gif') NOT NULL,
  `media_url` varchar(500) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `post_media_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~11 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`) VALUES
	(1, 1, 'image', '/uploads/1775044987996-farm_tractor_trolley_54c9074369.png'),
	(2, 1, 'video', '/uploads/1775044710518-SHRESTH PUDDLING MASTER_3D Animation_Hindi VO_11-12-25.mp4'),
	(3, 2, 'image', '/uploads/1775044777269-AutoMobiles.avif'),
	(4, 2, 'video', '/uploads/1775044777271-JK Tyre Dealer Onboarding Process Video_19-2-26.mp4'),
	(5, 3, 'image', '/uploads/1775044710515-BR_43_BR_50_BF_32_copy_png_a64bc06916.png'),
	(6, 3, 'video', '/uploads/1775044988016-E-BLAZE_EV Tyre_Video_Comp_7-11-25.mp4'),
	(7, 4, 'image', '/uploads/1775045544652-image_6487327-copy.jpg'),
	(8, 4, 'video', '/uploads/1775045544654-Ventilated seat reel.mp4'),
	(9, 5, 'image', '/uploads/1775045707594-2434.avif'),
	(10, 5, 'video', '/uploads/1775045707595-JK Tyre Micro Learning 01 - Tyre Construction.mp4'),
	(11, 5, 'video', '/uploads/1775045708236-JK Tyre Micro Learning 03 - Benefits & Applications of Radial & Bias Tyre.mp4');

-- Dumping structure for table insta_style_lms.posts
CREATE TABLE IF NOT EXISTS `posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text,
  `hashtags` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.posts: ~5 rows (approximately)
INSERT INTO `posts` (`id`, `category_id`, `title`, `content`, `hashtags`, `created_at`) VALUES
	(1, 1, 'Farm Tyre', 'Farm Tyre', '#Farm Tyre #JK Tyre', '2026-04-01 11:58:31'),
	(2, 2, 'Onboarding Process', 'Onboarding Process', '#Onboarding Process #JK Tyre', '2026-04-01 11:59:37'),
	(3, 1, 'E-Blaze', 'E-Blaze', '#E-Blaze', '2026-04-01 12:03:08'),
	(4, 3, 'Ventilated Seat', 'Ventilated Seat', '#Ventilated Seat  #Seat', '2026-04-01 12:12:25'),
	(5, 1, 'MicroLearning', 'MicroLearning', '#MicroLearning #JK Tyre', '2026-04-01 12:15:08');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
