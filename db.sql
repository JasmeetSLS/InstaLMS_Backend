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

-- Dumping data for table insta_style_lms.admins: ~0 rows (approximately)
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

-- Dumping structure for table insta_style_lms.cms_pages
CREATE TABLE IF NOT EXISTS `cms_pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_status` (`status`),
  KEY `idx_title` (`title`),
  KEY `idx_image_url` (`image_url`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.cms_pages: ~3 rows (approximately)
INSERT INTO `cms_pages` (`id`, `title`, `slug`, `content`, `image_url`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'About Us', 'about-us', '<h1>About InstaStyle LMS</h1>\n<p>Welcome to <strong>InstaStyle LMS</strong>, a modern learning management system designed to revolutionize the way you learn and grow.</p>\n\n<h2>Our Mission</h2>\n<p>Our mission is to provide high-quality, accessible, and engaging learning experiences that empower individuals to achieve their full potential. We believe that learning should be fun, interactive, and tailored to each learner\'s unique style.</p>\n\n<h2>What We Offer</h2>\n<ul>\n<li><strong>Interactive Learning Content</strong> - Engaging posts with videos, images, and quizzes</li>\n<li><strong>Personalized Learning Paths</strong> - Content organized by categories and interests</li>\n<li><strong>Social Learning Features</strong> - Like, comment, share, and bookmark posts</li>\n<li><strong>Quiz Assessments</strong> - Test your knowledge with interactive quizzes</li>\n<li><strong>Progress Tracking</strong> - Track your learning journey and achievements</li>\n</ul>\n\n<h2>Our Vision</h2>\n<p>To become the leading social learning platform that combines the best of social media engagement with serious learning outcomes.</p>\n\n<h2>Why Choose InstaStyle LMS?</h2>\n<p>InstaStyle LMS brings the familiar social media experience into the learning environment. Just like scrolling through your favorite social feed, learning becomes effortless and enjoyable. Our platform is designed to keep you engaged while ensuring real learning outcomes.</p>\n\n<h2>Our Team</h2>\n<p>We are a team of passionate educators, developers, and designers dedicated to creating the best learning experience possible. With years of experience in e-learning and technology, we understand what it takes to make learning effective and enjoyable.</p>\n\n<h2>Contact Us</h2>\n<p>Have questions or feedback? We\'d love to hear from you! Reach out to us at <a href="mailto:support@instastyle.com">support@instastyle.com</a></p>', '/uploads/cms/1/About-Us-banner.jpeg', 'active', '2026-04-30 07:22:54', '2026-04-30 07:22:54'),
	(2, 'Terms and Conditions', 'terms-and-conditions', '<h1>Terms and Conditions</h1>\n<p>Last updated: April 29, 2026</p>\n\n<h2>1. Acceptance of Terms</h2>\n<p>By accessing and using InstaStyle LMS (the "Platform"), you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access the Platform.</p>\n\n<h2>2. User Accounts</h2>\n<p>2.1. You must be at least 18 years old to use this Platform.<br />\n2.2. You are responsible for maintaining the confidentiality of your account credentials.<br />\n2.3. You are responsible for all activities that occur under your account.<br />\n2.4. You agree to provide accurate and complete information when creating your account.</p>\n\n<h2>3. User Conduct</h2>\n<p>You agree not to:</p>\n<ul>\n<li>Post or share inappropriate, offensive, or illegal content</li>\n<li>Harass, bully, or intimidate other users</li>\n<li>Impersonate any person or entity</li>\n<li>Attempt to gain unauthorized access to the Platform</li>\n<li>Use the Platform for any illegal purpose</li>\n<li>Interfere with or disrupt the Platform\'s servers or networks</li>\n</ul>\n\n<h2>4. Intellectual Property</h2>\n<p>4.1. All content on the Platform, including text, graphics, logos, and software, is the property of InstaStyle LMS and protected by copyright laws.<br />\n4.2. You retain ownership of content you post but grant us a license to use, display, and distribute it on the Platform.<br />\n4.3. You may not copy, modify, or distribute Platform content without permission.</p>\n\n<h2>5. Quiz and Assessment Results</h2>\n<p>5.1. Quiz results are for learning purposes only.<br />\n5.2. We do not guarantee accuracy or completeness of quiz content.<br />\n5.3. Results may be used for internal analytics and improvement of learning materials.</p>\n\n<h2>6. Privacy</h2>\n<p>Your use of the Platform is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.</p>\n\n<h2>7. Third-Party Links</h2>\n<p>The Platform may contain links to third-party websites. We are not responsible for the content or practices of these websites.</p>\n\n<h2>8. Termination</h2>\n<p>We reserve the right to terminate or suspend your account immediately, without prior notice, for conduct that violates these Terms or is harmful to other users or the Platform.</p>\n\n<h2>9. Disclaimer of Warranties</h2>\n<p>The Platform is provided "as is" without warranties of any kind. We do not warrant that the Platform will be uninterrupted or error-free.</p>\n\n<h2>10. Limitation of Liability</h2>\n<p>To the maximum extent permitted by law, InstaStyle LMS shall not be liable for any indirect, incidental, or consequential damages arising from your use of the Platform.</p>\n\n<h2>11. Changes to Terms</h2>\n<p>We reserve the right to modify these Terms at any time. Your continued use of the Platform after changes constitutes acceptance of the new Terms.</p>\n\n<h2>12. Governing Law</h2>\n<p>These Terms shall be governed by and construed in accordance with the laws of [Your Country/State].</p>\n\n<h2>13. Contact Information</h2>\n<p>For questions about these Terms, please contact us at: <a href="mailto:legal@instastyle.com">legal@instastyle.com</a></p>', '/uploads/cms/2/termCondition_banner.jpeg', 'active', '2026-04-30 07:23:35', '2026-04-30 07:23:35'),
	(3, 'Privacy Policy', 'privacy-policy', '<h1>Privacy Policy</h1>\n<p>Last updated: April 29, 2026</p>\n\n<h2>1. Introduction</h2>\n<p>InstaStyle LMS ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our learning management platform.</p>\n\n<h2>2. Information We Collect</h2>\n\n<h3>2.1 Personal Information</h3>\n<p>We collect information you provide directly to us, including:</p>\n<ul>\n<li>Name and email address</li>\n<li>Employee ID</li>\n<li>Phone number</li>\n<li>Gender</li>\n<li>Profile picture (optional)</li>\n<li>Account credentials</li>\n</ul>\n\n<h3>2.2 Usage Information</h3>\n<p>We automatically collect information about your interaction with the Platform:</p>\n<ul>\n<li>Posts viewed, liked, commented on, or shared</li>\n<li>Quiz attempts and scores</li>\n<li>Bookmarked content</li>\n<li>Time spent on different sections</li>\n<li>Device type and operating system</li>\n<li>IP address and browser information</li>\n<li>FCM token for push notifications</li>\n</ul>\n\n<h2>3. How We Use Your Information</h2>\n<p>We use the collected information to:</p>\n<ul>\n<li>Provide, maintain, and improve the Platform</li>\n<li>Process and manage your account</li>\n<li>Track learning progress and quiz results</li>\n<li>Personalize your learning experience</li>\n<li>Send notifications about new content or updates</li>\n<li>Analyze usage patterns and improve content</li>\n<li>Respond to your comments and questions</li>\n<li>Ensure platform security and prevent fraud</li>\n</ul>\n\n<h2>4. Information Sharing and Disclosure</h2>\n<p>We do not sell your personal information. We may share your information in the following circumstances:</p>\n<ul>\n<li><strong>With other users:</strong> Your profile information may be visible to other authenticated users of the Platform.</li>\n<li><strong>For legal reasons:</strong> If required by law or to protect our rights.</li>\n<li><strong>Service providers:</strong> Third-party vendors who help us operate the Platform (subject to confidentiality agreements).</li>\n<li><strong>Business transfers:</strong> In connection with a merger, acquisition, or sale of assets.</li>\n</ul>\n\n<h2>5. Data Security</h2>\n<p>We implement appropriate technical and organizational measures to protect your personal information, including encryption, secure servers, and access controls. However, no method of transmission over the Internet is 100% secure.</p>\n\n<h2>6. Your Rights and Choices</h2>\n<p>Depending on your location, you may have the right to:</p>\n<ul>\n<li>Access your personal information</li>\n<li>Correct inaccurate information</li>\n<li>Delete your account and associated data</li>\n<li>Opt-out of marketing communications</li>\n<li>Export your data</li>\n</ul>\n<p>To exercise these rights, contact us at <a href="mailto:privacy@instastyle.com">privacy@instastyle.com</a></p>\n\n<h2>7. Cookies and Tracking Technologies</h2>\n<p>We use cookies and similar technologies to enhance your experience, analyze usage, and personalize content. You can control cookie settings through your browser preferences.</p>\n\n<h2>8. Data Retention</h2>\n<p>We retain your personal information for as long as your account is active or as needed to provide services. Quiz results and engagement data may be retained for analytics purposes even after account deletion.</p>\n\n<h2>9. Children\'s Privacy</h2>\n<p>The Platform is not intended for children under 13. We do not knowingly collect information from children under 13.</p>\n\n<h2>10. International Data Transfers</h2>\n<p>Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place for such transfers.</p>\n\n<h2>11. Changes to This Privacy Policy</h2>\n<p>We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date.</p>\n\n<h2>12. Contact Us</h2>\n<p>If you have questions about this Privacy Policy, please contact us:</p>\n<ul>\n<li>Email: <a href="mailto:privacy@instastyle.com">privacy@instastyle.com</a></li>\n<li>Address: [Your Company Address]</li>\n</ul>', '/uploads/cms/3/Privacy-Policy-banner.jpeg', 'active', '2026-04-30 07:24:09', '2026-04-30 07:24:09');

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

-- Dumping structure for table insta_style_lms.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  `image_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.notifications: ~2 rows (approximately)
INSERT INTO `notifications` (`id`, `title`, `message`, `image_url`, `created_at`) VALUES
	(1, 'Tesing1', 'Tesing1', '/uploads/notifications/1/popup-banner2.jpg', '2026-05-04 07:24:18'),
	(2, 'Tesing2', 'Tesing2', '/uploads/notifications/2/popup-banner1.jpg', '2026-05-04 07:24:31');

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
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_bookmarks: ~9 rows (approximately)
INSERT INTO `post_bookmarks` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(3, 3, 2, '2026-04-09 11:13:46'),
	(4, 1, 2, '2026-04-20 06:31:38'),
	(25, 8, 1, '2026-05-01 07:38:07'),
	(26, 45, 1, '2026-05-01 07:44:05'),
	(28, 5, 1, '2026-05-12 10:40:05'),
	(29, 1, 1, '2026-05-13 18:19:52'),
	(30, 16, 1, '2026-05-15 09:11:11'),
	(31, 4, 1, '2026-05-15 10:29:03'),
	(32, 29, 1, '2026-05-21 06:23:43');

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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_comments: ~17 rows (approximately)
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
	(19, 7, 1, 'Great content', 'active', '2026-05-15 06:59:32', '2026-05-15 06:59:32');

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
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_likes: ~20 rows (approximately)
INSERT INTO `post_likes` (`id`, `post_id`, `user_id`, `created_at`) VALUES
	(4, 1, 2, '2026-04-20 06:30:47'),
	(9, 3, 1, '2026-04-25 12:27:08'),
	(16, 29, 1, '2026-04-28 06:58:32'),
	(17, 23, 1, '2026-04-28 06:58:37'),
	(22, 45, 1, '2026-04-29 07:53:43'),
	(24, 7, 1, '2026-05-01 07:38:00'),
	(27, 2, 1, '2026-05-01 07:43:18'),
	(29, 8, 1, '2026-05-05 09:57:39'),
	(30, 5, 1, '2026-05-05 11:44:19'),
	(31, 4, 1, '2026-05-05 11:44:23'),
	(32, 19, 1, '2026-05-06 09:32:39'),
	(34, 9, 1, '2026-05-07 10:26:24'),
	(35, 6, 1, '2026-05-07 11:09:16'),
	(37, 10, 1, '2026-05-11 05:11:12'),
	(40, 41, 1, '2026-05-12 07:26:22'),
	(43, 14, 1, '2026-05-14 08:50:40'),
	(45, 1, 1, '2026-05-15 05:49:55'),
	(47, 12, 1, '2026-05-20 09:05:55'),
	(48, 46, 1, '2026-05-21 07:23:07'),
	(49, 33, 1, '2026-05-22 09:46:32');

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
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media: ~88 rows (approximately)
INSERT INTO `post_media` (`id`, `post_id`, `media_type`, `media_url`, `thumbnail_url`, `created_at`) VALUES
	(1, 1, 'image', '/uploads/posts/1/media/1/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/1/media/1/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-09 05:16:40'),
	(2, 1, 'video', '/uploads/posts/1/media/2/EV.mp4', '/uploads/posts/1/media/2/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-04-09 05:16:40'),
	(3, 2, 'image', '/uploads/posts/2/media/3/life_at_jk_page_3a591463b2.png', '/uploads/posts/2/media/3/thumb_life_at_jk_page_3a591463b2.png', '2026-04-09 05:18:48'),
	(4, 2, 'video', '/uploads/posts/2/media/4/Test1.mp4', '/uploads/posts/2/media/4/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-04-09 05:18:48'),
	(5, 3, 'image', '/uploads/posts/3/media/5/farm_tractor_trolley_54c9074369.png', '/uploads/posts/3/media/5/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-09 05:20:55'),
	(6, 3, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/3/media/6/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.avif', '2026-04-09 05:20:55'),
	(7, 4, 'video', '/uploads/posts/4/media/7/test3.mp4', '/uploads/posts/4/media/7/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-04-09 05:23:20'),
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
	(28, 16, 'video', '/uploads/posts/16/media/28/test3.mp4', '/uploads/posts/16/media/28/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.jpg', '2026-04-15 11:55:34'),
	(29, 16, 'image', '/uploads/posts/16/media/29/p3.jpg', '/uploads/posts/16/media/29/thumb_p3.png', '2026-04-15 11:55:34'),
	(30, 17, 'image', '/uploads/posts/17/media/30/farm_tractor_trolley_54c9074369.png', '/uploads/posts/17/media/30/thumb_farm_tractor_trolley_54c9074369.avif', '2026-04-15 11:56:53'),
	(31, 17, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/17/media/31/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.png', '2026-04-15 11:56:53'),
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
	(44, 24, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/24/media/44/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:18:47'),
	(45, 24, 'image', '/uploads/posts/24/media/45/p5.jpg', '/uploads/posts/24/media/45/thumb_p5.jpg', '2026-04-15 12:18:47'),
	(46, 25, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/25/media/46/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:01'),
	(47, 25, 'image', '/uploads/posts/25/media/47/p5.jpg', '/uploads/posts/25/media/47/thumb_p5.jpg', '2026-04-15 12:19:01'),
	(48, 26, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/26/media/48/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:14'),
	(49, 26, 'image', '/uploads/posts/26/media/49/p5.jpg', '/uploads/posts/26/media/49/thumb_p5.jpg', '2026-04-15 12:19:14'),
	(50, 27, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/27/media/50/thumb_SHRESTH_PUDDLING_MASTER_3D_Animation_Hindi_VO_11-12-25.jpg', '2026-04-15 12:19:29'),
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
	(65, 34, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/34/media/65/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 07:15:26'),
	(66, 35, 'image', '/uploads/posts/35/media/66/row-cars_83_1_0.jpg', '/uploads/posts/35/media/66/thumb_row-cars_83_1_0.jpg', '2026-04-16 07:18:12'),
	(67, 35, 'image', '/uploads/posts/35/media/67/images.jpg', '/uploads/posts/35/media/67/thumb_images.jpg', '2026-04-16 07:18:12'),
	(68, 35, 'image', '/uploads/posts/35/media/68/car-sales_1d8acd.avif', '/uploads/posts/35/media/68/thumb_car-sales_1d8acd.avif', '2026-04-16 07:18:12'),
	(69, 36, 'image', '/uploads/posts/36/media/69/image_870x580_67653903cb44e.jpg', '/uploads/posts/36/media/69/thumb_image_870x580_67653903cb44e.jpg', '2026-04-16 07:18:41'),
	(70, 36, 'video', '/uploads/posts/17/media/31/test4.mp4  ', '/uploads/posts/36/media/70/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 07:18:41'),
	(71, 37, 'image', '/uploads/posts/37/media/71/p2.jpg', '/uploads/posts/37/media/71/thumb_p2.jpg', '2026-04-16 10:21:46'),
	(72, 37, 'pdf', '/uploads/posts/37/media/72/sample.pdf', '/uploads/posts/37/media/72/thumb_sample.jpg', '2026-04-16 10:21:46'),
	(73, 38, 'image', '/uploads/posts/38/media/73/front-left-side-47.avif', '/uploads/posts/38/media/73/thumb_front-left-side-47.avif', '2026-04-16 10:24:28'),
	(74, 38, 'image', '/uploads/posts/38/media/74/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/38/media/74/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-16 10:24:28'),
	(75, 39, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/39/media/75/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-04-16 10:25:36'),
	(76, 39, 'image', '/uploads/posts/39/media/76/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/39/media/76/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-04-16 10:25:36'),
	(77, 40, 'image', '/uploads/posts/40/media/77/images.jpg', '/uploads/posts/40/media/77/thumb_images.jpg', '2026-04-16 10:29:34'),
	(78, 40, 'image', '/uploads/posts/40/media/78/Service_Advisor_Training_CPI.webp', '/uploads/posts/40/media/78/thumb_Service_Advisor_Training_CPI.webp', '2026-04-16 10:29:34'),
	(79, 40, 'image', '/uploads/posts/40/media/79/images.jpg', '/uploads/posts/40/media/79/thumb_images.jpg', '2026-04-16 10:29:34'),
	(80, 41, 'wbt', '/uploads/posts/41/media/80/extracted/story.html', '/uploads/posts/41/media/80/thumb_Basic_Electrical_WBT_-_POC.jpg', '2026-04-16 10:31:24'),
	(81, 42, 'image', '/uploads/posts/42/media/81/farm_tractor_trolley_54c9074369.png', '/uploads/posts/42/media/81/thumb_farm_tractor_trolley_54c9074369.png', '2026-04-16 10:34:16'),
	(82, 42, 'youtube', 'https://www.youtube.com/shorts/KCqMBVaT9g0', 'https://img.youtube.com/vi/KCqMBVaT9g0/maxresdefault.jpg', '2026-04-16 10:34:16'),
	(83, 43, 'image', '/uploads/posts/43/media/83/image_870x580_67653903cb44e.jpg', '/uploads/posts/43/media/83/thumb_image_870x580_67653903cb44e.jpg', '2026-04-16 10:36:25'),
	(84, 43, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/43/media/84/thumb_JK_Tyre_Dealer_Onboarding_Process_Video_19-2-26_1_.png', '2026-04-16 10:36:25'),
	(85, 44, 'image', '/uploads/posts/44/media/85/image_6487327-copy.jpg', '/uploads/posts/44/media/85/thumb_image_6487327-copy.jpg', '2026-04-16 10:37:48'),
	(86, 44, 'youtube', 'https://www.youtube.com/shorts/VTU0UXZmfeQ', 'https://img.youtube.com/vi/VTU0UXZmfeQ/maxresdefault.jpg', '2026-04-16 10:37:48'),
	(87, 45, 'pdf', '/uploads/posts/5/media/8/SCV.pdf', '/uploads/posts/45/media/87/thumb_SCV.jpeg', '2026-04-21 10:24:27'),
	(88, 46, 'pdf', '/uploads/posts/46/media/88/certificate_1_.pdf', '/uploads/posts/46/media/88/thumb_certificate_1_.jpeg', '2026-04-21 10:29:45'),
	(89, 47, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/47/media/89/thumb_Ventilated_seat_reel.jpg', '2026-04-23 04:48:28'),
	(90, 48, 'wbt', '/uploads/posts/48/media/90/extracted/story.html', '/uploads/posts/48/media/90/thumb_JK_Tyre_Rural_Distribution_Assessment_1_.png', '2026-04-29 08:59:08'),
	(91, 49, 'wbt', '/uploads/posts/49/media/91/extracted/story.html', '/uploads/posts/49/media/91/thumb_Hero_Ultimate_Striker_Assessment.png', '2026-04-29 09:09:53'),
	(92, 50, 'wbt', '/uploads/posts/50/media/92/extracted/story.html', '/uploads/posts/50/media/92/thumb_RACE-TO-ACE.png', '2026-04-29 09:20:06'),
	(94, 52, 'image', '/uploads/posts/52/media/94/WhatsApp_Image_2026-03-24_at_2.45.02_PM.jpeg', '/uploads/posts/52/media/94/thumb_WhatsApp_Image_2026-03-24_at_2.45.02_PM.jpeg', '2026-05-05 05:54:29'),
	(95, 53, 'image', '/uploads/posts/53/media/95/BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '/uploads/posts/53/media/95/thumb_BR_43_BR_50_BF_32_copy_png_a64bc06916.png', '2026-05-05 05:55:29'),
	(96, 53, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/53/media/96/thumb_E-BLAZE_EV_Tyre_Video_Comp_7-11-25.webp', '2026-05-05 05:55:29'),
	(97, 54, 'video', '/uploads/posts/3/media/6/Test2.mp4', '/uploads/posts/54/media/97/thumb_JK_Tyre_Micro_Learning_01_-_Tyre_Construction.png', '2026-05-05 05:57:43'),
	(98, 54, 'image', '/uploads/posts/54/media/98/images.jpg', '/uploads/posts/54/media/98/thumb_images.webp', '2026-05-05 05:57:43'),
	(99, 55, 'video', '/uploads/posts/2/media/4/Test1.mp4', '/uploads/posts/55/media/99/thumb_Ventilated_seat_reel.jpg', '2026-05-05 06:00:32');

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
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_media_views: ~48 rows (approximately)
INSERT INTO `post_media_views` (`id`, `post_id`, `media_id`, `user_id`, `viewed_at`) VALUES
	(1, 1, 1, 1, '2026-05-07 05:36:19'),
	(2, 2, 4, 1, '2026-05-07 06:50:07'),
	(3, 1, 2, 1, '2026-05-07 08:04:59'),
	(4, 3, 5, 1, '2026-05-07 08:05:27'),
	(5, 3, 6, 1, '2026-05-07 08:05:32'),
	(6, 14, 24, 1, '2026-05-07 08:08:19'),
	(7, 10, 16, 1, '2026-05-07 08:08:48'),
	(8, 2, 3, 1, '2026-05-07 10:17:10'),
	(9, 11, 17, 1, '2026-05-07 10:22:26'),
	(10, 7, 11, 1, '2026-05-07 10:25:36'),
	(11, 4, 7, 1, '2026-05-07 10:27:48'),
	(12, 6, 9, 1, '2026-05-07 11:08:57'),
	(13, 6, 10, 1, '2026-05-07 11:09:02'),
	(14, 13, 23, 1, '2026-05-11 05:12:09'),
	(15, 45, 87, 1, '2026-05-11 05:12:40'),
	(16, 5, 8, 1, '2026-05-11 11:34:52'),
	(17, 23, 42, 1, '2026-05-11 11:37:48'),
	(18, 23, 43, 1, '2026-05-11 11:38:15'),
	(19, 40, 77, 1, '2026-05-11 12:13:15'),
	(20, 53, 95, 1, '2026-05-11 12:13:37'),
	(21, 54, 97, 1, '2026-05-11 12:13:56'),
	(22, 41, 80, 1, '2026-05-11 12:14:49'),
	(23, 31, 57, 1, '2026-05-12 07:21:06'),
	(25, 34, 64, 1, '2026-05-12 07:21:12'),
	(26, 35, 66, 1, '2026-05-12 07:21:25'),
	(27, 39, 75, 1, '2026-05-12 07:34:57'),
	(28, 46, 88, 1, '2026-05-12 07:39:40'),
	(29, 31, 58, 1, '2026-05-12 07:39:59'),
	(30, 31, 59, 1, '2026-05-12 07:40:04'),
	(32, 34, 65, 1, '2026-05-12 09:15:54'),
	(33, 48, 90, 1, '2026-05-12 10:45:14'),
	(34, 49, 91, 1, '2026-05-12 10:45:47'),
	(35, 52, 94, 1, '2026-05-13 04:57:06'),
	(36, 9, 14, 1, '2026-05-13 18:02:32'),
	(37, 8, 12, 1, '2026-05-13 18:06:04'),
	(38, 16, 28, 1, '2026-05-14 07:12:08'),
	(39, 15, 25, 1, '2026-05-15 06:23:59'),
	(40, 19, 34, 1, '2026-05-15 06:24:37'),
	(41, 50, 92, 1, '2026-05-15 07:21:14'),
	(42, 55, 99, 1, '2026-05-15 07:23:25'),
	(43, 27, 50, 1, '2026-05-15 07:24:21'),
	(44, 29, 54, 1, '2026-05-21 06:23:05'),
	(45, 29, 55, 1, '2026-05-21 06:23:12'),
	(46, 30, 56, 1, '2026-05-21 06:37:59'),
	(47, 12, 21, 1, '2026-05-21 10:21:00'),
	(48, 33, 62, 1, '2026-05-21 12:22:17'),
	(49, 12, 18, 1, '2026-05-22 09:41:42'),
	(50, 8, 13, 1, '2026-05-25 02:18:53');

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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_shares: ~23 rows (approximately)
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
	(24, 1, 1, 6, 'active', '2026-05-21 09:29:18');

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
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.post_views: ~25 rows (approximately)
INSERT INTO `post_views` (`id`, `post_id`, `user_id`, `viewed_at`) VALUES
	(1, 1, 1, '2026-05-07 08:04:59'),
	(2, 3, 1, '2026-05-07 08:05:32'),
	(3, 14, 1, '2026-05-07 08:08:19'),
	(4, 10, 1, '2026-05-07 08:08:48'),
	(5, 2, 1, '2026-05-07 10:17:10'),
	(6, 11, 1, '2026-05-07 10:22:26'),
	(7, 7, 1, '2026-05-07 10:25:36'),
	(8, 4, 1, '2026-05-07 10:27:48'),
	(9, 6, 1, '2026-05-07 11:09:02'),
	(10, 13, 1, '2026-05-11 05:12:09'),
	(11, 45, 1, '2026-05-11 05:12:40'),
	(12, 5, 1, '2026-05-11 11:34:52'),
	(13, 23, 1, '2026-05-11 11:38:15'),
	(14, 41, 1, '2026-05-11 12:14:49'),
	(15, 46, 1, '2026-05-12 07:39:40'),
	(16, 31, 1, '2026-05-12 07:40:04'),
	(18, 34, 1, '2026-05-12 09:15:54'),
	(19, 48, 1, '2026-05-12 10:45:14'),
	(20, 49, 1, '2026-05-12 10:45:47'),
	(21, 52, 1, '2026-05-13 04:57:06'),
	(22, 50, 1, '2026-05-15 07:21:14'),
	(23, 55, 1, '2026-05-15 07:23:25'),
	(24, 29, 1, '2026-05-21 06:23:12'),
	(25, 30, 1, '2026-05-21 06:37:59'),
	(26, 8, 1, '2026-05-25 02:18:53');

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
	(1, 2, 3, 'E-BLAZE_EV Tyre', 'E-BLAZE_EV Tyre', '#E-BLAZE #Tyre', 'landscape', 2, 9, 3, 10, 1, 0, 'active', '2026-04-09 05:16:40', '2026-05-21 09:29:18'),
	(2, 3, 3, 'JK Tyre Dealer Onboarding Process', 'JK Tyre Dealer Onboarding Process', '#JK Tyre #Dealer Onboarding Process', 'landscape', 1, 2, 3, 1, 1, 0, 'active', '2026-04-09 05:18:48', '2026-05-07 10:17:10'),
	(3, 2, 3, 'Farm Tyre', 'Farm Tyre', '#Farm Tyre', 'landscape', 1, 1, 3, 2, 1, 0, 'active', '2026-04-09 05:20:55', '2026-05-07 08:05:32'),
	(4, 2, 3, 'JK Tyre Micro Learning', 'JK Tyre Micro Learning 01 - Tyre Construction', '#MicroLearning #JK Tyre', 'landscape', 1, 1, 2, 0, 1, 0, 'active', '2026-04-09 05:23:20', '2026-05-07 10:27:48'),
	(5, 4, 3, 'SCV - Instructor material - BAT', 'SCV - Instructor material - BAT', '#BAT #SCV - Instructor material', 'landscape', 1, 2, 4, 1, 1, 1, 'active', '2026-04-09 05:24:44', '2026-05-18 06:16:21'),
	(6, 5, 3, 'Soft Skills', 'Soft Skills', '#Soft Skills', 'landscape', 1, 1, 3, 3, 0, 1, 'active', '2026-04-09 05:26:45', '2026-05-18 06:16:34'),
	(7, 2, 3, 'Ventilated Seat', 'Ventilated Seat', '#Ventilated Seat', 'landscape', 1, 1, 2, 0, 0, 0, 'active', '2026-04-09 05:30:45', '2026-05-15 06:59:32'),
	(8, 2, 3, 'Ventilated Seat Shorts', 'Ventilated Seat', '#Ventilated Seat', 'landscape', 1, 0, 4, 0, 0, 0, 'active', '2026-04-09 05:34:23', '2026-05-25 02:18:53'),
	(9, 2, 3, 'E-BLAZE Youtube Shorts', 'E-BLAZE Youtube Shorts', '#E-BLAZE', 'landscape', 1, 0, 1, 2, 0, 0, 'active', '2026-04-09 05:36:20', '2026-05-07 10:26:24'),
	(10, 3, 3, 'WBT Training Module1', 'This is an interactive WBT training module', '#WBT #Training #Learning', 'landscape', 1, 1, 4, 0, 0, 0, 'active', '2026-04-09 05:37:26', '2026-05-11 05:11:12'),
	(11, 3, 3, 'WBT Training Module2', 'This is an interactive WBT training module', '#WBT #Training #Learning', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-09 05:37:56', '2026-05-07 10:22:26'),
	(12, 2, 3, 'Maruti Suzuki Cars', 'Maruti Suzuki Cars', '#Maruti Suzuki', 'landscape', 1, 0, 1, 0, 0, 0, 'active', '2026-04-09 10:25:40', '2026-05-20 09:05:55'),
	(13, 5, 3, 'Soft Skills -2 ', 'Soft Skills -2 ', '#Soft Skills', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-04-13 07:32:37', '2026-05-18 06:16:35'),
	(14, 4, 3, 'BAT', 'BAT', '#BAT', 'landscape', 1, 0, 2, 0, 0, 0, 'active', '2026-04-13 07:35:30', '2026-05-14 08:50:40'),
	(15, 2, 3, 'Testing1', 'This is Testing1 description', '#test,#testing1', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-15 11:53:07', '2026-05-06 17:07:20'),
	(16, 2, 3, 'Testing2', 'This is Testing2 description', '#test,#testing2', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 11:55:34', '2026-05-05 10:13:44'),
	(17, 2, 2, 'Testing3', 'This is Testing3 description', '#test,#testing3', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 11:56:53', '2026-05-05 10:13:47'),
	(18, 2, 3, 'Testing4', 'This is Testing4 description', '#test,#testing4', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 11:58:47', '2026-05-05 10:13:48'),
	(19, 2, 3, 'Testing5', 'This is Testing5 description', '#test,#testing5', 'landscape', 1, 0, 2, 0, 0, 0, 'active', '2026-04-15 12:00:25', '2026-05-06 16:32:57'),
	(20, 2, 4, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 12:16:11', '2026-05-05 07:08:09'),
	(21, 3, 4, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 12:16:18', '2026-05-05 10:13:51'),
	(22, 4, 2, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-15 12:16:23', '2026-05-05 10:13:53'),
	(23, 5, 3, 'Testing6', 'This is Testing6 description', '#test,#testing6', 'landscape', 1, 0, 3, 1, 0, 0, 'active', '2026-04-15 12:16:34', '2026-05-11 11:38:15'),
	(24, 2, 4, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-15 12:18:47', '2026-05-05 10:13:57'),
	(25, 3, 2, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 3, 1, 0, 0, 'active', '2026-04-15 12:19:01', '2026-05-05 10:14:00'),
	(26, 4, 1, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-15 12:19:14', '2026-05-05 10:14:01'),
	(27, 5, 3, 'Testing7', 'This is Testing7 description', '#test,#testing7', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-15 12:19:29', '2026-05-05 10:12:17'),
	(28, 2, 2, 'Testing8', 'Testing8', '#Testing8', 'landscape', 0, 0, 5, 0, 0, 0, 'active', '2026-04-16 06:47:09', '2026-05-05 10:12:20'),
	(29, 2, 1, 'Testing9', 'Testing9', '#Testing9', 'landscape', 1, 0, 4, 1, 0, 0, 'active', '2026-04-16 06:49:32', '2026-05-21 06:23:12'),
	(30, 2, 3, 'Testing10', 'Testing10', '#Testing10', 'landscape', 0, 0, 2, 1, 0, 1, 'active', '2026-04-16 06:51:39', '2026-05-21 06:37:59'),
	(31, 2, 3, 'Testing11', 'Testing11', '#Testing11', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-04-16 06:54:43', '2026-05-12 07:40:04'),
	(32, 2, 2, 'Testing12', 'Testing12', '#Testing12', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 06:57:04', '2026-05-05 10:12:48'),
	(33, 10, 3, 'Testing13', 'Testing13', '#Testing13', 'landscape', 1, 0, 5, 1, 0, 1, 'active', '2026-04-16 07:01:23', '2026-05-22 09:46:32'),
	(34, 10, 3, 'Testing14', 'Testing14', '#test,#testing14', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 07:15:26', '2026-05-12 09:15:54'),
	(35, 2, 3, 'Testing15', 'Testing15', '#Test#Testing15', 'landscape', 0, 0, 5, 0, 0, 1, 'active', '2026-04-16 07:18:12', '2026-05-12 06:13:16'),
	(36, 2, 2, 'Testing16', 'Testing16', '#test,#Testing16', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 07:18:41', '2026-05-05 10:12:45'),
	(37, 3, 4, 'Testing1', 'Testing1', '#Testing1', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:21:46', '2026-05-05 10:12:47'),
	(38, 3, 1, 'Testing2', 'Testing2', '#Testing2', 'landscape', 0, 0, 6, 0, 0, 0, 'active', '2026-04-16 10:24:28', '2026-05-05 10:12:29'),
	(39, 3, 3, 'Testing3', 'Testing3', '#Test#Testing3', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 10:25:36', '2026-05-11 11:44:31'),
	(40, 9, 3, 'Testing4', 'Testing4', '#Testing4', 'landscape', 0, 0, 1, 0, 0, 1, 'active', '2026-04-16 10:29:34', '2026-05-11 11:44:32'),
	(41, 10, 3, 'Testing5', 'Testing5', '#Test#Testing5', 'landscape', 1, 1, 8, 0, 0, 1, 'active', '2026-04-16 10:31:24', '2026-05-12 07:26:34'),
	(42, 3, 1, 'Testing8', 'Testing8', '#Testing8', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:34:16', '2026-05-05 10:12:36'),
	(43, 3, 4, 'Testing9', 'Testing9', '#test,#testing9', 'landscape', 0, 0, 3, 0, 0, 0, 'active', '2026-04-16 10:36:25', '2026-05-05 10:12:35'),
	(44, 3, 2, 'Testing10', 'Testing10', '#Test#Testing10', 'landscape', 0, 0, 1, 0, 0, 0, 'active', '2026-04-16 10:37:48', '2026-05-05 10:12:55'),
	(45, 6, 3, 'TestingPDF', 'TestingPDF', '#TestingPDF', 'portrait', 1, 0, 5, 0, 0, 0, 'active', '2026-04-21 10:24:27', '2026-05-15 07:27:54'),
	(46, 6, 3, 'TestingPDF2', 'TestingPDF2', '#TestingPDF2', 'portrait', 1, 0, 4, 0, 0, 0, 'active', '2026-04-21 10:29:45', '2026-05-21 07:23:07'),
	(47, 6, 4, 'Testing Video', 'Testing Video', '#Testing Video', 'landscape', 0, 0, 2, 0, 0, 0, 'active', '2026-04-23 04:48:28', '2026-05-05 10:12:58'),
	(48, 7, 3, 'TestingWBT', 'TestingWBT', '#TestingWBT', 'portrait', 0, 0, 5, 0, 0, 0, 'active', '2026-04-29 08:59:08', '2026-05-12 10:45:14'),
	(49, 7, 3, 'TestingWBT2', 'TestingWBT2', '#TestingWBT2', 'portrait', 0, 0, 3, 0, 0, 0, 'active', '2026-04-29 09:09:53', '2026-05-12 10:45:47'),
	(50, 7, 3, 'TestingWBT3', 'TestingWBT3', '#TestingWBT3', 'portrait', 0, 0, 2, 0, 0, 0, 'active', '2026-04-29 09:20:06', '2026-05-15 07:21:14'),
	(52, 8, 3, 'Tesing1', 'Tesing1', '#Tesing1', 'portrait', 0, 0, 2, 0, 0, 1, 'active', '2026-05-05 05:54:29', '2026-05-13 04:57:06'),
	(53, 8, 3, 'Testing2', 'Testing2', '#Testing2', 'landscape', 0, 0, 2, 0, 0, 1, 'active', '2026-05-05 05:55:29', '2026-05-11 11:43:43'),
	(54, 9, 3, 'Testing1', 'Testing1', '#Testing1', 'landscape', 0, 0, 3, 0, 0, 1, 'active', '2026-05-05 05:57:43', '2026-05-11 11:43:45'),
	(55, 10, 3, 'Tesing1', 'Tesing1', '#Tesing1', 'landscape', 0, 0, 3, 0, 0, 1, 'active', '2026-05-05 06:00:32', '2026-05-15 07:23:25');

-- Dumping structure for table insta_style_lms.quiz_questions
CREATE TABLE IF NOT EXISTS `quiz_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
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
  CONSTRAINT `quiz_questions_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.quiz_questions: ~25 rows (approximately)
INSERT INTO `quiz_questions` (`id`, `post_id`, `question_text`, `question_media_url`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `marks`, `status`, `created_at`) VALUES
	(1, 1, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-22 05:23:50'),
	(2, 1, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-22 05:23:50'),
	(3, 1, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-22 05:23:50'),
	(4, 1, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-22 05:23:50'),
	(5, 1, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-22 05:23:50'),
	(6, 2, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 23:53:50'),
	(7, 2, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(8, 2, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 23:53:50'),
	(9, 2, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 23:53:50'),
	(10, 2, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(11, 3, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 23:53:50'),
	(12, 3, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(13, 3, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 23:53:50'),
	(14, 3, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 23:53:50'),
	(15, 3, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(16, 4, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 23:53:50'),
	(17, 4, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(18, 4, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 23:53:50'),
	(19, 4, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 23:53:50'),
	(20, 4, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(21, 5, 'Which car manufacturer does this logo belong to?', '/uploads/quiz/questions/1/bmw.png', 'Mercedes-Benz', 'BMW', 'Audi', 'Volkswagen', 'B', 10, 'active', '2026-04-21 23:53:50'),
	(22, 5, 'What does "ABS" stand for in modern automobiles?', NULL, 'Automatic Braking System', 'Anti-lock Braking System', 'Advanced Brake Support', 'Auto Boost Steering', 'B', 5, 'active', '2026-04-21 23:53:50'),
	(23, 5, 'What does this dashboard warning light indicate?', '/uploads/quiz/questions/3/CE.png', 'Low fuel', 'Battery issue', 'Check engine', 'Oil pressure low', 'C', 10, 'active', '2026-04-21 23:53:50'),
	(24, 5, 'Which company produces the "Model 3" electric car?', NULL, 'Ford', 'GM', 'Tesla', 'Nissan', 'C', 5, 'active', '2026-04-21 23:53:50'),
	(25, 5, 'What is the purpose of a turbocharger in a car?', NULL, 'Reduce fuel consumption', 'Increase engine power', 'Lower emissions', 'Improve braking', 'B', 5, 'active', '2026-04-21 23:53:50');

-- Dumping structure for table insta_style_lms.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.roles: ~4 rows (approximately)
INSERT INTO `roles` (`id`, `name`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'PSE', 'active', '2026-05-05 06:39:59', '2026-05-05 06:39:59'),
	(2, 'DSE', 'active', '2026-05-05 06:39:59', '2026-05-05 06:39:59'),
	(3, 'SNE', 'active', '2026-05-05 06:39:59', '2026-05-05 06:39:59'),
	(4, 'TE', 'active', '2026-05-05 06:39:59', '2026-05-05 06:39:59');

-- Dumping structure for table insta_style_lms.user_media_progress
CREATE TABLE IF NOT EXISTS `user_media_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `total_media_count` int NOT NULL DEFAULT '0',
  `viewed_media_count` int NOT NULL DEFAULT '0',
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
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_media_progress: ~37 rows (approximately)
INSERT INTO `user_media_progress` (`id`, `user_id`, `post_id`, `total_media_count`, `viewed_media_count`, `view_percentage`, `last_viewed_at`, `created_at`) VALUES
	(1, 1, 1, 2, 2, 100.00, '2026-05-07 08:04:59', '2026-05-07 05:36:19'),
	(2, 1, 2, 2, 2, 100.00, '2026-05-07 10:17:10', '2026-05-07 06:50:07'),
	(3, 1, 3, 2, 2, 100.00, '2026-05-07 08:05:32', '2026-05-07 08:05:27'),
	(4, 1, 14, 1, 1, 100.00, '2026-05-07 08:08:19', '2026-05-07 08:08:19'),
	(5, 1, 10, 1, 1, 100.00, '2026-05-07 08:08:48', '2026-05-07 08:08:48'),
	(6, 1, 11, 1, 1, 100.00, '2026-05-07 10:22:26', '2026-05-07 10:22:26'),
	(7, 1, 7, 1, 1, 100.00, '2026-05-07 10:25:36', '2026-05-07 10:25:36'),
	(8, 1, 4, 1, 1, 100.00, '2026-05-07 10:27:48', '2026-05-07 10:27:48'),
	(9, 1, 6, 2, 2, 100.00, '2026-05-07 11:09:02', '2026-05-07 11:08:57'),
	(10, 1, 13, 1, 1, 100.00, '2026-05-11 05:12:09', '2026-05-11 05:12:09'),
	(11, 1, 45, 1, 1, 100.00, '2026-05-11 05:12:40', '2026-05-11 05:12:40'),
	(12, 1, 5, 1, 1, 100.00, '2026-05-11 11:34:52', '2026-05-11 11:34:52'),
	(13, 1, 23, 2, 2, 100.00, '2026-05-11 11:38:15', '2026-05-11 11:37:48'),
	(14, 1, 40, 3, 1, 33.33, '2026-05-11 12:13:15', '2026-05-11 12:13:15'),
	(15, 1, 53, 2, 1, 50.00, '2026-05-11 12:13:37', '2026-05-11 12:13:37'),
	(16, 1, 54, 2, 1, 50.00, '2026-05-11 12:13:56', '2026-05-11 12:13:56'),
	(17, 1, 41, 1, 1, 100.00, '2026-05-11 12:14:49', '2026-05-11 12:14:49'),
	(18, 1, 31, 3, 3, 100.00, '2026-05-12 07:40:04', '2026-05-12 07:21:06'),
	(20, 1, 34, 2, 2, 100.00, '2026-05-12 09:15:54', '2026-05-12 07:21:12'),
	(21, 1, 35, 3, 1, 33.33, '2026-05-12 07:21:25', '2026-05-12 07:21:25'),
	(22, 1, 39, 2, 1, 50.00, '2026-05-12 07:34:57', '2026-05-12 07:34:57'),
	(23, 1, 46, 1, 1, 100.00, '2026-05-12 07:39:40', '2026-05-12 07:39:40'),
	(24, 1, 48, 1, 1, 100.00, '2026-05-12 10:45:14', '2026-05-12 10:45:14'),
	(25, 1, 49, 1, 1, 100.00, '2026-05-12 10:45:47', '2026-05-12 10:45:47'),
	(26, 1, 52, 1, 1, 100.00, '2026-05-13 04:57:06', '2026-05-13 04:57:06'),
	(27, 1, 9, 2, 1, 50.00, '2026-05-13 18:02:32', '2026-05-13 18:02:32'),
	(28, 1, 8, 2, 2, 100.00, '2026-05-25 02:18:53', '2026-05-13 18:06:04'),
	(29, 1, 16, 2, 1, 50.00, '2026-05-14 07:12:08', '2026-05-14 07:12:08'),
	(30, 1, 15, 3, 1, 33.33, '2026-05-15 06:23:59', '2026-05-15 06:23:59'),
	(31, 1, 19, 2, 1, 50.00, '2026-05-15 06:24:37', '2026-05-15 06:24:37'),
	(32, 1, 50, 1, 1, 100.00, '2026-05-15 07:21:14', '2026-05-15 07:21:14'),
	(33, 1, 55, 1, 1, 100.00, '2026-05-15 07:23:25', '2026-05-15 07:23:25'),
	(34, 1, 27, 2, 1, 50.00, '2026-05-15 07:24:21', '2026-05-15 07:24:21'),
	(35, 1, 29, 2, 2, 100.00, '2026-05-21 06:23:12', '2026-05-21 06:23:05'),
	(36, 1, 30, 1, 1, 100.00, '2026-05-21 06:37:59', '2026-05-21 06:37:59'),
	(37, 1, 12, 5, 2, 40.00, '2026-05-22 09:41:42', '2026-05-21 10:21:00'),
	(38, 1, 33, 2, 1, 50.00, '2026-05-21 12:22:17', '2026-05-21 12:22:17');

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.user_notification_reads: ~0 rows (approximately)

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
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_quiz_answers: ~20 rows (approximately)
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
	(16, 1, 4, 16, 'A', 0, '2026-05-05 09:55:20'),
	(17, 1, 4, 17, 'D', 0, '2026-05-05 09:55:20'),
	(18, 1, 4, 18, 'A', 0, '2026-05-05 09:55:20'),
	(19, 1, 4, 19, 'D', 0, '2026-05-05 09:55:20'),
	(20, 1, 4, 20, 'D', 0, '2026-05-05 09:55:20'),
	(21, 1, 2, 6, 'C', 0, '2026-05-11 11:33:16'),
	(22, 1, 2, 7, 'A', 0, '2026-05-11 11:33:16'),
	(23, 1, 2, 8, 'A', 0, '2026-05-11 11:33:16'),
	(24, 1, 2, 9, 'C', 1, '2026-05-11 11:33:16'),
	(25, 1, 2, 10, 'B', 1, '2026-05-11 11:33:16');

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table insta_style_lms.user_quiz_completion: ~3 rows (approximately)
INSERT INTO `user_quiz_completion` (`id`, `user_id`, `post_id`, `score`, `completed_at`) VALUES
	(1, 1, 1, 0, '2026-05-01 06:58:06'),
	(3, 1, 3, 5, '2026-05-01 07:41:20'),
	(4, 1, 4, 0, '2026-05-05 09:55:20'),
	(5, 1, 2, 10, '2026-05-11 11:33:17');

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
  CONSTRAINT `fk_users_dealer_id` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_users_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table insta_style_lms.users: ~12 rows (approximately)
INSERT INTO `users` (`id`, `email`, `employee_id`, `name`, `phone`, `gender`, `password`, `role_id`, `dealer_id`, `profile_url`, `fcm_token`, `device_type`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'demo@sls.com', 'EMP001', 'Keshav_Goyal', '8282828282', 'male', '$2b$12$ZslmCICm4jckewtmotATtOyvLHKWfDRSBks.slJVbMrB3LImYsnsa', 3, 1, '/uploads/users/1/profile-1775713806692.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-09 05:50:06', '2026-05-20 12:07:53'),
	(2, 'demo@sls2.com', 'EMP002', 'Neeraj Jain', '8989898989', 'male', '$2b$12$QBXiSY0OPhBa9qV8f48MzuRvUwqsl67/Sb1mjCjKsvlcszd5nvAQa', 2, 2, '/uploads/users/2/profile-1775713867244.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-09 05:51:07', '2026-05-12 06:19:09'),
	(3, 'demo@sls3.com', 'EMP003', 'Ravi Pandey', '8181818181', 'male', '$2b$12$PNRO6eNla8CKqp4prVXoT.QNjB8ULGi/u0dc2N1Wo1wP7U8OsFlKi', 4, 3, '/uploads/users/3/profile-1775713939921.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-09 05:52:19', '2026-05-12 06:19:09'),
	(4, 'demo@sls4.com', 'EMP004', 'Subhojit', '9876543210', 'male', '$2b$12$Jig.kclv.RbH2wwxgm48rOC32nnuyFWSxkoHHIy5kA3xX0xseY3pC', 1, 4, '/uploads/users/4/profile-1776246467383.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:47:47', '2026-05-12 06:19:09'),
	(5, 'demo@sls5.com', 'EMP005', 'Pradeep Kumar', '9876543291', 'male', '$2b$12$UUNeVsUpZytLAKhajq36Ce0l6OwWmwO3.hiHp2j0VwKsrcmJfjSIS', 2, 5, '/uploads/users/5/profile-1776246576012.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:49:36', '2026-05-12 06:19:09'),
	(6, 'demo@sls6.com', 'EMP006', 'Anil Kumawat', '9234897684', 'male', '$2b$12$uRpsPxHFAXtBGSSeSJAO8uCNAqaebvW.09HTHrS.8UPtcEiNF.zlq', 4, 1, '/uploads/users/6/profile-1776246747079.jpg', 'fcm_token_xyz_123_abc', 'android', 'active', '2026-04-15 09:52:27', '2026-05-12 06:19:09'),
	(7, 'demo@sls7.com', 'EMP007', 'Dheeraj', '9994328902', 'male', '$2b$12$TCdpZGJ7fK8os0EDuR60Y.GnPPK9L33XZNRlM4vbLFEfSO2w7./pW', 3, 2, '/uploads/users/7/profile-1776246864430.jpg', NULL, NULL, 'active', '2026-04-15 09:54:24', '2026-05-12 06:19:09'),
	(8, 'demo@sls8.com', 'EMP008', 'Karthick', '9876543233', 'male', '$2b$12$s2j/DMLuBB4ceYibqtuQzO9Mvq2VyDt7I1klxpeK1RN6e/qpdSOSq', 1, 1, '/uploads/users/8/profile-1778652931250.jpg', NULL, NULL, 'active', '2026-05-13 06:15:31', '2026-05-13 06:15:31'),
	(9, 'demo@sls9.com', 'EMP009', 'SOHAIL KHAN', '9876543122', 'male', '$2b$12$HrOtucb5rRqZUyWgwhAUFu62dtIxlnmgJjDVz2X.63HCiY3kbS3ma', 1, 1, '/uploads/users/9/profile-1778653072931.jpg', NULL, NULL, 'active', '2026-05-13 06:17:52', '2026-05-13 06:17:52'),
	(10, 'demo@sls10.com', 'EMP0010', 'Vinaya Prasad', '9876543122', 'male', '$2b$12$4DCIVZfU570HZOJRxNgAxudZZMUAut7Prlm.FHbqJm2pI8xjgj4bO', 1, 1, '/uploads/users/10/profile-1778653116674.jpg', NULL, NULL, 'active', '2026-05-13 06:18:36', '2026-05-13 06:18:36'),
	(11, 'demo@sls11.com', 'EMP0011', 'Sudha Pawar', '9876543122', 'male', '$2b$12$eFj6Rx46Y/yWcjODoodI0uqpshOiOy5xGHqfyoRp5tsyFLtGuPHQ.', 1, 1, '/uploads/users/11/profile-1778653157019.jpg', NULL, NULL, 'active', '2026-05-13 06:19:17', '2026-05-13 06:19:17'),
	(12, 'demo@sls12.com', 'EMP0012', 'Nagnath Pise', '9876543122', 'male', '$2b$12$SdC7AF271okTtt3cwIIrtOfxgYXb8XhB.kRf//Eq0mnGSAHIZg0la', 1, 1, '/uploads/users/12/profile-1778653233079.jpg', NULL, NULL, 'active', '2026-05-13 06:20:33', '2026-05-13 06:20:33');

-- Dumping structure for trigger insta_style_lms.update_post_views_count
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `update_post_views_count` AFTER INSERT ON `post_media_views` FOR EACH ROW BEGIN
    DECLARE total_media_count INT DEFAULT 0;
    DECLARE viewed_media_count INT DEFAULT 0;
    DECLARE view_exists INT DEFAULT 0;
    DECLARE view_percentage DECIMAL(5,2) DEFAULT 0.00;
    DECLARE progress_exists INT DEFAULT 0;
    
    -- Get total media count for this post
    SELECT COUNT(*) INTO total_media_count
    FROM post_media
    WHERE post_id = NEW.post_id;
    
    -- Only proceed if post has media
    IF total_media_count > 0 THEN
        
        -- Get how many media this user has viewed for this post
        SELECT COUNT(DISTINCT media_id) INTO viewed_media_count
        FROM post_media_views
        WHERE post_id = NEW.post_id AND user_id = NEW.user_id;
        
        -- Calculate percentage
        SET view_percentage = (viewed_media_count / total_media_count) * 100;
        
        -- Check if progress record already exists
        SELECT COUNT(*) INTO progress_exists
        FROM user_media_progress
        WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
        
        -- Update existing or insert new record
        IF progress_exists > 0 THEN
            UPDATE user_media_progress 
            SET 
                viewed_media_count = viewed_media_count,
                view_percentage = view_percentage,
                total_media_count = total_media_count,
                last_viewed_at = NOW()
            WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
        ELSE
            INSERT INTO user_media_progress (user_id, post_id, total_media_count, viewed_media_count, view_percentage, last_viewed_at)
            VALUES (NEW.user_id, NEW.post_id, total_media_count, viewed_media_count, view_percentage, NOW());
        END IF;
        
        -- Check if user has viewed all media
        IF viewed_media_count = total_media_count THEN
            
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
        
    ELSE
        -- For posts with no media
        SELECT COUNT(*) INTO view_exists
        FROM post_views
        WHERE post_id = NEW.post_id AND user_id = NEW.user_id;
        
        IF view_exists = 0 THEN
            INSERT INTO post_views (post_id, user_id, viewed_at)
            VALUES (NEW.post_id, NEW.user_id, NOW());
            
            UPDATE posts 
            SET views_count = views_count + 1 
            WHERE id = NEW.post_id;
            
            SELECT COUNT(*) INTO progress_exists
            FROM user_media_progress
            WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
            
            IF progress_exists > 0 THEN
                UPDATE user_media_progress 
                SET view_percentage = 100.00, last_viewed_at = NOW()
                WHERE user_id = NEW.user_id AND post_id = NEW.post_id;
            ELSE
                INSERT INTO user_media_progress (user_id, post_id, total_media_count, viewed_media_count, view_percentage, last_viewed_at)
                VALUES (NEW.user_id, NEW.post_id, 0, 0, 100.00, NOW());
            END IF;
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
