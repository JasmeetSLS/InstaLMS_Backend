-- --------------------------------------------------------
-- Host:                         192.168.10.15
-- Server version:               8.0.45-0ubuntu0.22.04.1 - (Ubuntu)
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


-- Dumping database structure for Tata_Microlearning
CREATE DATABASE IF NOT EXISTS `Tata_Microlearning` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `Tata_Microlearning`;

-- Dumping structure for table Tata_Microlearning.assignment_categories
CREATE TABLE IF NOT EXISTS `assignment_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `category_id` int NOT NULL,
  `question_count` int NOT NULL,
  `easy_count` int DEFAULT '0',
  `medium_count` int DEFAULT '0',
  `hard_count` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `assignment_categories_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.assignment_categories: ~4 rows (approximately)
INSERT INTO `assignment_categories` (`id`, `assignment_id`, `category_id`, `question_count`, `easy_count`, `medium_count`, `hard_count`) VALUES
	(1, 1, 1, 8, 3, 3, 2),
	(2, 2, 4, 1, 0, 1, 0),
	(3, 2, 2, 2, 0, 2, 0),
	(4, 2, 3, 2, 0, 2, 0);

-- Dumping structure for table Tata_Microlearning.assignment_languages
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.assignment_languages: ~5 rows (approximately)
INSERT INTO `assignment_languages` (`id`, `assignment_id`, `language_id`, `created_at`) VALUES
	(1, 1, 1, '2025-11-07 05:08:03'),
	(2, 1, 2, '2025-11-07 05:08:03'),
	(3, 2, 1, '2025-11-07 05:08:51'),
	(4, 2, 2, '2025-11-07 05:08:51'),
	(5, 2, 5, '2025-11-07 05:08:51');

-- Dumping structure for table Tata_Microlearning.assignment_roles
CREATE TABLE IF NOT EXISTS `assignment_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `role_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_assignment_role` (`assignment_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `assignment_roles_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.assignment_roles: ~2 rows (approximately)
INSERT INTO `assignment_roles` (`id`, `assignment_id`, `role_id`, `created_at`) VALUES
	(1, 1, 1, '2025-11-07 05:08:03'),
	(2, 2, 2, '2025-11-07 05:08:51');

-- Dumping structure for table Tata_Microlearning.base_questions
CREATE TABLE IF NOT EXISTS `base_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `difficulty_level` enum('Easy','Medium','Hard') DEFAULT 'Medium',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `base_questions_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.base_questions: ~13 rows (approximately)
INSERT INTO `base_questions` (`id`, `category_id`, `difficulty_level`, `created_at`, `status`) VALUES
	(1, 1, 'Easy', '2025-09-16 05:58:25', 'Active'),
	(2, 1, 'Easy', '2025-09-16 05:58:25', 'Active'),
	(3, 1, 'Easy', '2025-09-16 05:58:25', 'Active'),
	(4, 1, 'Medium', '2025-09-16 05:58:25', 'Active'),
	(5, 1, 'Medium', '2025-09-16 05:58:25', 'Active'),
	(6, 1, 'Medium', '2025-09-16 05:58:25', 'Active'),
	(7, 1, 'Hard', '2025-09-16 05:58:25', 'Active'),
	(8, 1, 'Hard', '2025-09-16 05:58:25', 'Active'),
	(9, 2, 'Medium', '2025-11-06 07:12:10', 'Active'),
	(10, 3, 'Medium', '2025-11-06 07:12:10', 'Active'),
	(11, 3, 'Medium', '2025-11-06 07:12:10', 'Active'),
	(12, 4, 'Medium', '2025-11-06 07:12:10', 'Active'),
	(13, 2, 'Medium', '2025-11-06 07:12:10', 'Active');

-- Dumping structure for table Tata_Microlearning.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.categories: ~4 rows (approximately)
INSERT INTO `categories` (`id`, `name`, `created_at`, `status`) VALUES
	(1, 'CAN', '2025-10-28 12:18:48', 'Active'),
	(2, 'Product', '2025-11-06 07:08:08', 'Active'),
	(3, 'Sales Process', '2025-11-06 07:08:16', 'Active'),
	(4, 'BAT', '2025-11-06 07:08:23', 'Active');

-- Dumping structure for table Tata_Microlearning.cities
CREATE TABLE IF NOT EXISTS `cities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `zone_id` int DEFAULT NULL,
  `state_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `state_id` (`state_id`),
  KEY `cities_ibfk_zone` (`zone_id`),
  CONSTRAINT `cities_ibfk_state` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cities_ibfk_zone` FOREIGN KEY (`zone_id`) REFERENCES `zones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.cities: ~19 rows (approximately)
INSERT INTO `cities` (`id`, `zone_id`, `state_id`, `name`, `status`, `created_at`) VALUES
	(1, 1, 1, 'Delhi', 'Active', '2025-10-28 12:22:36'),
	(2, 2, 1, 'Delhi-NCR', 'Active', '2025-10-27 05:15:11'),
	(3, 3, 2, 'Jaipur', 'Active', '2025-10-27 05:15:11'),
	(4, 4, 3, 'Indore', 'Active', '2025-10-27 05:15:11'),
	(5, 5, 4, 'Kolkata', 'Active', '2025-10-27 05:15:11'),
	(6, 6, 5, 'Ranchi', 'Active', '2025-10-27 05:15:11'),
	(7, 7, 6, 'Guwahati', 'Active', '2025-10-27 05:15:11'),
	(8, 8, 7, 'Dehradun', 'Active', '2025-10-27 05:15:11'),
	(9, 9, 8, 'Chandigarh', 'Active', '2025-10-27 05:15:11'),
	(10, 10, 9, 'Lucknow', 'Active', '2025-10-27 05:15:11'),
	(11, 11, 10, 'Panchkula', 'Active', '2025-10-27 05:15:11'),
	(12, 12, 11, 'Chennai', 'Active', '2025-10-27 05:15:11'),
	(13, 13, 12, 'Bangalore', 'Active', '2025-10-27 05:15:11'),
	(14, 14, 13, 'Kochi', 'Active', '2025-10-27 05:15:11'),
	(15, 15, 14, 'Hyderabad', 'Active', '2025-10-27 05:15:11'),
	(16, 16, 15, 'Bhubaneshwar', 'Active', '2025-10-27 05:15:11'),
	(17, 17, 16, 'Mumbai', 'Active', '2025-10-27 05:15:11'),
	(18, 18, 16, 'Pune', 'Active', '2025-10-27 05:15:11'),
	(19, 19, 17, 'Ahmedabad', 'Active', '2025-10-27 05:15:11');

-- Dumping structure for table Tata_Microlearning.countries
CREATE TABLE IF NOT EXISTS `countries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.countries: ~1 rows (approximately)
INSERT INTO `countries` (`id`, `name`, `code`, `status`, `created_at`) VALUES
	(1, 'India', 'IN', 'Active', '2025-10-28 12:19:24');

-- Dumping structure for table Tata_Microlearning.languages
CREATE TABLE IF NOT EXISTS `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.languages: ~5 rows (approximately)
INSERT INTO `languages` (`id`, `code`, `name`, `created_at`, `status`) VALUES
	(1, 'eng', 'English', '2025-10-28 12:17:12', 'Active'),
	(2, 'hin', 'Hindi', '2025-09-16 07:07:17', 'Active'),
	(3, 'pun', 'Punjabi', '2025-09-16 07:07:17', 'Active'),
	(4, 'tam', 'Tamil', '2025-09-16 07:07:17', 'Active'),
	(5, 'mr', 'Marathi', '2025-11-06 07:10:48', 'Active');

-- Dumping structure for table Tata_Microlearning.question_translations
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
  `option_a` text,
  `option_b` text,
  `option_c` text,
  `option_d` text,
  `correct_option` enum('A','B','C','D') NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_question_language` (`base_question_id`,`language_id`),
  KEY `language_id` (`language_id`),
  CONSTRAINT `question_translations_ibfk_1` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `question_translations_ibfk_2` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.question_translations: ~47 rows (approximately)
INSERT INTO `question_translations` (`id`, `base_question_id`, `language_id`, `question`, `question_media_path`, `short_content`, `long_content_text`, `long_content_file_path`, `long_content_audio_path`, `question_answer_audio_path`, `created_at`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_option`, `status`) VALUES
	(1, 1, 1, 'How many types of CAN Communication lines are used in Tata Motors?', '', 'Tata Motors uses multiple CAN communication lines to support the growing number of ECUs and sensors in their BSVI vehicles.', 'What is CAN Communication?\r\nCAN (Controller Area Network) is a vehicle bus standard designed to allow electronic control units (ECUs) to communicate with each other without a host computer.\r\nIt allows multiple systems in a vehicle (like engine, transmission, ABS, dashboard) to exchange information in real time.\r\n________________________________________\r\n🚗 Why CAN is Important in Tata Motors Vehicles\r\nTata Motors uses CAN Communication in all modern vehicles to ensure:\r\n•	Fast and reliable communication between ECUs.\r\n•	Accurate diagnostics.\r\n•	Efficient operation and safety of vehicle systems.\r\n________________________________________\r\n📊 Three Types of CAN Communication in Tata Motors\r\nType	Name	Speed	Purpose	Example ECUs\r\n1️⃣	High-Speed CAN	~500 kbps - 1 Mbps	Used for critical systems needing fast data exchange	Engine ECU, ABS, Transmission\r\n2️⃣	Mid-Speed CAN	~125 kbps - 250 kbps	Used for comfort and convenience systems	Body Control Module, HVAC\r\n3️⃣	Low-Speed CAN / LIN (as sub-network)	< 125 kbps	For non-critical functions, often via gateways	Window controls, seat modules\r\n💡 Note: LIN (Local Interconnect Network) is sometimes grouped under CAN architecture due to its integration, but technically it is a sub-network.\r\n________________________________________\r\n🔁 Real-life Application\r\nWhen diagnosing a communication issue, knowing the type of CAN helps:\r\n•	Identify correct wiring and pinouts.\r\n•	Choose the right tools (scanner or oscilloscope).\r\n•	Narrow down fault zones (High-Speed or Low-Speed lines).\r\n•	Prevent misdiagnosis of the communication path.\r\n________________________________________\r\n⚠️ Common Mistake by Participants\r\nMistake: Some participants answered “2” types (only High and Low-Speed), assuming Mid-Speed doesn’t exist or is part of Low-Speed.\r\nWhy this is incorrect:\r\n•	Tata Motors uses Mid-Speed CAN especially in comfort modules.\r\n•	Each type has different voltage levels, protocol rules, and ECU roles.\r\n________________________________________\r\n🎯 Key Takeaways\r\n•	Tata Motors vehicles have 3 types of CAN Communication.\r\n•	Understanding these types improves diagnostic accuracy and troubleshooting skills.\r\n•	Each type serves different vehicle systems based on data speed and criticality.\r\n________________________________________\r\n✅ Quick Recap\r\nType	Speed	Used In\r\nHigh-Speed	~500 kbps to 1 Mbps	Engine, ABS, Transmission\r\nMid-Speed	~125–250 kbps	HVAC, Infotainment, BCM\r\nLow-Speed / LIN	<125 kbps	Seats, Windows, Mirrors', '/uploads/1755086250529.pdf', '/uploads/questions/Q1/english/L1.mp3', '/uploads/questions/Q1/english/Q1.mp3', '2025-09-16 05:58:25', '4', '6', '8', '10', 'B', 'Active'),
	(2, 1, 2, 'टाटा मोटर्स में कितने प्रकार की CAN कम्युनिकेशन लाइन्स उपयोग की जाती हैं?', '', 'टाटा मोटर्स अपने बीएस-6 वाहनों में ईसीयू और सेंसरों की बढ़ती संख्या को समर्थन देने के लिए कई CAN संचार लाइनों का उपयोग करती है।', 'CAN संचार क्या है?\r\nCAN (Controller Area Network) एक वाहन बस मानक है जिसे इस प्रकार बनाया गया है कि विभिन्न ECU (Electronic Control Units) बिना किसी होस्ट कंप्यूटर के एक-दूसरे से संचार कर सकें।\r\nयह वाहन के कई सिस्टमों (जैसे इंजन, ट्रांसमिशन, ABS, डैशबोर्ड) को रीयल-टाइम में जानकारी का आदान-प्रदान करने की अनुमति देता है।\r\n\r\n🚗 टाटा मोटर्स वाहनों में CAN का महत्व\r\nटाटा मोटर्स अपने सभी आधुनिक वाहनों में CAN Communication का उपयोग करती है ताकि यह सुनिश्चित किया जा सके:\r\n• ECU के बीच तेज़ और विश्वसनीय संचार हो।\r\n• सटीक डायग्नोस्टिक संभव हो।\r\n• वाहन के सिस्टम कुशलता और सुरक्षा के साथ कार्य करें।\r\n\r\n📊 टाटा मोटर्स में CAN Communication के तीन प्रकार\r\n\r\nप्रकार	नाम	स्पीड	उद्देश्य	उदाहरण ECU\r\n1️⃣	हाई-स्पीड CAN	~500 kbps - 1 Mbps	तेज़ डेटा एक्सचेंज की आवश्यकता वाले महत्वपूर्ण सिस्टमों के लिए	इंजन ECU, ABS, ट्रांसमिशन\r\n2️⃣	मिड-स्पीड CAN	~125 kbps - 250 kbps	कम्फर्ट और कन्वीनियंस सिस्टमों के लिए	बॉडी कंट्रोल मॉड्यूल (BCM), HVAC\r\n3️⃣	लो-स्पीड CAN / LIN (सब-नेटवर्क)	<125 kbps	गैर-महत्वपूर्ण कार्यों के लिए, अक्सर गेटवे के माध्यम से	विंडो कंट्रोल, सीट मॉड्यूल\r\n\r\n💡 नोट:\r\nLIN (Local Interconnect Network) को कभी-कभी CAN आर्किटेक्चर का हिस्सा माना जाता है, क्योंकि यह उसी नेटवर्क में इंटीग्रेट होता है, लेकिन तकनीकी रूप से यह एक सब-नेटवर्क है।', '/uploads/1755086250529.pdf', '/uploads/questions/Q1/hindi/L1.mp3', '/uploads/questions/Q1/hindi/Q1.mp3', '2025-09-16 05:58:25', '4', '6', '8', '10', 'B', 'Active'),
	(3, 1, 3, 'ਟਾਟਾ ਮੋਟਰਜ਼ ਵਿੱਚ ਕਿੰਨੇ ਕਿਸਮ ਦੀਆਂ CAN ਕਮਿਊਨੀਕੇਸ਼ਨ ਲਾਈਨਾਂ ਵਰਤੀਆਂ ਜਾਂਦੀਆਂ ਹਨ?', '', 'ਟਾਟਾ ਮੋਟਰਜ਼ ਆਪਣੇ BSVI ਵਾਹਨਾਂ ਵਿੱਚ ECUs ਅਤੇ ਸੈਂਸਰਾਂ ਦੀ ਵਧ ਰਹੀ ਗਿਣਤੀ ਦਾ ਸਮਰਥਨ ਕਰਨ ਲਈ ਕਈ CAN ਕਮਿਊਨੀਕੇਸ਼ਨ ਲਾਈਨਾਂ ਦੀ ਵਰਤੋਂ ਕਰਦੀ ਹੈ।', 'CAN ਕਮਿਊਨੀਕੇਸ਼ਨ ਕੀ ਹੈ? CAN (ਕੰਟਰੋਲਰ ਏਰੀਆ ਨੈੱਟਵਰਕ) ਇੱਕ ਵਾਹਨ ਬਸ ਮਾਨਕ ਹੈ ਜੋ ਇਲੈਕਟ੍ਰਾਨਿਕ ਕੰਟਰੋਲ ਯੂਨਿਟਸ (ECUs) ਨੂੰ ਹੋਸਟ ਕੰਪਿਊਟਰ ਤੋਂ ਬਿਨਾਂ ਇੱਕ ਦੂਜੇ ਨਾਲ ਸੰਚਾਰ ਕਰਨ ਦੀ ਆਗਿਆ ਦੇਣ ਲਈ ਤਿਆਰ ਕੀਤਾ ਗਿਆ ਹੈ।', '/uploads/1755086250529.pdf', '/uploads/punjabi_audio1.mp3', '/uploads/punjabi_answer1.mp3', '2025-09-16 05:58:25', 'ਚਾਰ', 'ਛੇ', 'ਅੱਠ', 'ਦੱਸ', 'B', 'Active'),
	(4, 1, 4, 'டாடா மோட்டார்ஸில் எத்தனை வகையான CAN கம்யூனிகேஷன் கோடுகள் பயன்படுத்தப்படுகின்றன?', '', 'டாடா மோட்டார்ஸ் அதன் BSVI வாகனங்களில் ECUs மற்றும் சென்சார்களின் அதிகரித்த எண்ணிக்கையை ஆதரிக்க பல CAN கம்யூனிகேஷன் கோடுகளைப் பயன்படுத்துகிறது.', 'CAN கம்யூனிகேஷன் என்றால் என்ன? CAN (கன்ட்ரோலர் ஏரியா நெட்வொர்க்) என்பது எலக்ட்ரானிக் கன்ட்ரோல் யூனிட்கள் (ECUs) ஒரு ஹோஸ்ட் கம்ப்யூட்டர் இல்லாமல் ஒருவருக்கொருவர் தொடர்பு கொள்ள அனுமதிக்க வடிவமைக்கப்பட்ட ஒரு வாகன பஸ் தரநிலையாகும்.', '/uploads/1755086250529.pdf', '/uploads/tamil_audio1.mp3', '/uploads/tamil_answer1.mp3', '2025-09-16 05:58:25', 'நான்கு', 'ஆறு', 'எட்டு', 'பத்து', 'B', 'Active'),
	(5, 2, 1, 'What is the resistance between High CAN and Low CAN on OBD Connector?', '', 'Each CAN bus is terminated at both ends with 120Ω resistors to prevent signal reflection.', 'Learning Material: Understanding CAN Communication for NOx Sensor in 3.3L Phase 2\r\n________________________________________\r\n🔹 What is the NOx Sensor?\r\n•	NOx (Nitrogen Oxide) sensors monitor emissions from diesel engines.\r\n•	The Upstream NOx sensor is placed before the SCR (Selective Catalytic Reduction) system.\r\n•	It provides real-time exhaust gas data to the Engine Control Unit (ECU).\r\n•	This data helps in optimizing urea injection and ensures BS-VI compliance.\r\n________________________________________\r\n🔹 Understanding PCAN in 3.3L Phase 2 Engines\r\nIn Tata Motors\' 3.3L Phase 2 (BSVI) engines:\r\n•	The PCAN (Powertrain CAN) is the primary communication network for powertrain-related ECUs and sensors.\r\n•	It connects:\r\no	ECU (Engine Control Unit)\r\no	TCU (Transmission Control Unit)\r\no	Gear Selector\r\no	ABS\r\no	Instrument Cluster\r\no	NOx Sensors (Upstream & Downstream)\r\n________________________________________\r\n🧠 Key Technical Insight\r\nIf the Upstream NOx sensor is not communicating, the issue lies in the PCAN network, not ICAN, DCAN, or any other.\r\n________________________________________\r\n🔧 How to Diagnose PCAN Communication Issues\r\n1.	Check CAN Resistance on PCAN\r\no	Measure between CAN High and CAN Low with ignition OFF.\r\no	Expected resistance: ~60 Ohms\r\no	If not, check for open circuits, shorts, or missing terminating resistors.\r\n2.	Inspect Connector & Wiring\r\no	Ensure sensor and ECU connectors are tight and not corroded.\r\no	Check continuity of CAN wires between ECU and NOx sensor.\r\n3.	Check CAN Voltage\r\no	Power ON the vehicle.\r\no	CAN High to Ground: ~2.5–3.0 VDC\r\no	CAN Low to Ground: ~2.0–2.5 VDC\r\no	If both are ~2.5V and static, it may indicate no data traffic.\r\n4.	Verify Sensor Status via Diagnostic Tool\r\no	Use diagnostic software (e.g., Jaltest or Tata-approved tool).\r\no	Look for communication errors or timeouts from the NOx sensor.\r\n________________________________________\r\n📌 Field Application Example (3.3L Phase 2 BSVI)\r\nModule	Connected CAN\r\nNOx Upstream Sensor	PCAN\r\nEngine Control Unit	PCAN\r\nABS	PCAN\r\nInstrument Cluster	ICAN\r\nTelematics / Diagnostics	DCAN\r\n________________________________________\r\n🛠️ Best Practices\r\n•	Always start diagnosis by checking the correct CAN network.\r\n•	Use circuit diagrams specific to the vehicle model.\r\n•	Ensure proper grounding and sensor power supply before concluding sensor failure.\r\n•	Cross-check sensor ID and location to avoid confusion with downstream NOx sensor.\r\n________________________________________\r\n📷 Diagram: Simplified View (Conceptual)\r\n[NOx Upstream Sensor] <--PCAN--> [ECU] <--PCAN--> [ABS, TCU, Gear Selector]\r\n________________________________________\r\n🧠 Takeaway:\r\nWhen the NOx Upstream Sensor in a 3.3L Phase 2 engine is not communicating with the ECU, the first thing to check is the PCAN, which handles all powertrain-related communications.', '/uploads/1755086385841.pdf', '/uploads/questions/Q2/english/L2.mp3', '/uploads/questions/Q2/english/Q2.mp3', '2025-09-16 05:58:25', '60Ω', '120Ω', '40Ω', '10Ω', 'A', 'Active'),
	(6, 2, 2, 'OBD कनेक्टर पर High CAN और Low CAN के बीच कितना रेजिस्टेंस  है?', '', 'प्रत्येक CAN बस के दोनों सिरों पर 120Ω रेज़िस्टर लगाए जाते हैं ताकि सिग्नल रिफ्लेक्शन (signal reflection) को रोका जा सके।', 'लर्निंग मटेरियल: 3.3L फेज़ 2 में NOx सेंसर के लिए CAN कम्युनिकेशन की समझ\r\n\r\n🔹 NOx सेंसर क्या है?\r\n• NOx (नाइट्रोजन ऑक्साइड) सेंसर डीज़ल इंजनों से निकलने वाले उत्सर्जन (emissions) की निगरानी करता है।\r\n• अपस्ट्रीम NOx सेंसर को SCR (Selective Catalytic Reduction) सिस्टम से पहले लगाया जाता है।\r\n• यह सेंसर एक्जॉस्ट गैस का रीयल-टाइम डेटा इंजन कंट्रोल यूनिट (ECU) को भेजता है।\r\n• यह डेटा यूrea इंजेक्शन को ऑप्टिमाइज़ करने और BS-VI मानकों का पालन सुनिश्चित करने में मदद करता है।\r\n\r\n🔹 3.3L फेज़ 2 इंजनों में PCAN की समझ\r\nटाटा मोटर्स के 3.3L फेज़ 2 (BSVI) इंजनों में:\r\n• PCAN (Powertrain CAN) पावरट्रेन से जुड़े सभी ECU और सेंसरों के लिए मुख्य कम्युनिकेशन नेटवर्क है।\r\n• यह निम्नलिखित यूनिट्स को जोड़ता है:\r\no ECU (Engine Control Unit)\r\no TCU (Transmission Control Unit)\r\no गियर सेलेक्टर (Gear Selector)\r\no ABS (Anti-lock Braking System)\r\no इंस्ट्रूमेंट क्लस्टर (Instrument Cluster)\r\no NOx सेंसर (अपस्ट्रीम और डाउनस्ट्रीम दोनों)\r\n\r\n🧠 मुख्य तकनीकी जानकारी (Key Technical Insight)\r\nयदि अपस्ट्रीम NOx सेंसर संचार नहीं कर रहा है, तो समस्या PCAN नेटवर्क में है — न कि ICAN, DCAN या किसी अन्य नेटवर्क में।\r\n\r\n🔧 PCAN कम्युनिकेशन समस्या का निदान कैसे करें (Diagnosis Steps)\r\n\r\n1️⃣ PCAN पर CAN रेज़िस्टेंस जाँचें\r\n• CAN High और CAN Low के बीच इग्निशन OFF स्थिति में माप करें।\r\n• अपेक्षित रेज़िस्टेंस: लगभग 60 ओम (Ohms)\r\n• यदि नहीं है — तो ओपन सर्किट, शॉर्ट या टर्मिनेटिंग रेज़िस्टर्स की कमी की जाँच करें।\r\n\r\n2️⃣ कनेक्टर और वायरिंग की जाँच करें\r\n• सेंसर और ECU कनेक्टर ढीले या जंग लगे न हों।\r\n• ECU और NOx सेंसर के बीच CAN तारों की कंटिन्युटी (Continuity) जाँचें।\r\n\r\n3️⃣ CAN वोल्टेज की जाँच करें\r\n• वाहन को ON करें।\r\n• CAN High से ग्राउंड तक: लगभग 2.5–3.0 VDC\r\n• CAN Low से ग्राउंड तक: लगभग 2.0–2.5 VDC\r\n• यदि दोनों लगभग 2.5V और स्थिर हैं — तो इसका अर्थ है कि डेटा ट्रैफिक नहीं है।\r\n\r\n4️⃣ डायग्नोस्टिक टूल से सेंसर की स्थिति जांचें\r\n• Jaltest या Tata-अनुमोदित डायग्नोस्टिक टूल का उपयोग करें।\r\n• NOx सेंसर से संबंधित कम्युनिकेशन एरर या टाइमआउट की जांच करें।\r\n\r\n📌 फील्ड एप्लिकेशन उदाहरण (3.3L Phase 2 BSVI)\r\n\r\nमॉड्यूल	कनेक्टेड CAN\r\nNOx अपस्ट्रीम सेंसर	PCAN\r\nइंजन कंट्रोल यूनिट	PCAN\r\nABS	PCAN\r\nइंस्ट्रूमेंट क्लस्टर	ICAN\r\nटेलीमैटिक्स / डायग्नोस्टिक्स	DCAN\r\n\r\n🛠️ सर्वश्रेष्ठ अभ्यास (Best Practices)\r\n• हमेशा डायग्नोसिस की शुरुआत सही CAN नेटवर्क से करें।\r\n• वाहन मॉडल के अनुसार सर्किट डायग्राम का उपयोग करें।\r\n• ग्राउंडिंग और सेंसर पॉवर सप्लाई की जांच करें, सेंसर फेल घोषित करने से पहले।\r\n• सेंसर ID और लोकेशन क्रॉस-चेक करें ताकि डाउनस्ट्रीम सेंसर के साथ भ्रम न हो।\r\n\r\n📷 सरल चित्र (कॉन्सेप्चुअल व्यू):\r\n[NOx अपस्ट्रीम सेंसर] ←PCAN→ [ECU] ←PCAN→ [ABS, TCU, गियर सेलेक्टर]\r\n\r\n🧠 मुख्य निष्कर्ष (Takeaway):\r\nजब 3.3L Phase 2 इंजन में NOx अपस्ट्रीम सेंसर ECU से संचार नहीं कर रहा हो, तो सबसे पहले PCAN नेटवर्क की जांच करें, क्योंकि यह सभी पावरट्रेन संबंधित संचार को संभालता है।', '/uploads/1755086385841.pdf', '/uploads/questions/Q2/hindi/L2.mp3', '/uploads/questions/Q2/hindi/Q2.mp3', '2025-09-16 05:58:25', '60 ओम', '120 ओम', '40 ओम', '10 ओम', 'A', 'Active'),
	(7, 2, 3, 'OBD ਕਨੈਕਟਰ \'ਤੇ ਹਾਈ CAN ਅਤੇ ਲੋ CAN ਵਿਚਕਾਰ ਪ੍ਰਤੀਰੋਧ ਕੀ ਹੈ?', '', 'ਸਿਗਨਲ ਰਿਫਲੈਕਸ਼ਨ ਨੂੰ ਰੋਕਣ ਲਈ ਹਰੇਕ CAN ਬਸ ਦੋਵੇਂ ਸਿਰਿਆਂ \'ਤے 120Ω ਰੈਜ਼ਿਸਟਰਾਂ ਨਾਲ ਟਰਮੀਨੇਟ ਕੀਤੀ ਜਾਂਦੀ ਹੈ।', 'ਸਿਖਲਾਈ ਸਮੱਗਰੀ: 3.3L ਫੇਜ਼ 2 ਵਿੱਚ NOx ਸੈਂਸਰ ਲਈ CAN ਕमਿਊਨੀਕੇਸ਼ਨ ਨੂੰ ਸਮਝਣਾ', '/uploads/1755086385841.pdf', '/uploads/punjabi_audio2.mp3', '/uploads/punjabi_answer2.mp3', '2025-09-16 05:58:25', 'ਸਾਠ ਓਮ', 'ਇੱਕ ਸੌ ਵੀਹ ਓਮ', 'ਚਾਲੀ ਓਮ', 'ਦਸ ਓਮ', 'A', 'Active'),
	(8, 2, 4, 'OBD இணைப்பியில் High CAN மற்றும் Low CAN க்கு இடையே உள்ள எதிர்ப்பு என்ன?', '', 'சிக்னல் ரிஃப்ளெக்ஷனைத் தடுக்க ஒவ்வொரு CAN பஸும் இரு முனைகளிலும் 120Ω ரெசிஸ்டர்களுடன் முடிக்கப்படுகிறது.', 'கற்றல் பொருள்: 3.3L பேஸ் 2 இல் NOx சென்சருக்கான CAN கம்யூனிகேஷனைப் புரிந்துகொள்வது', '/uploads/1755086385841.pdf', '/uploads/tamil_audio2.mp3', '/uploads/tamil_answer2.mp3', '2025-09-16 05:58:25', 'அறுபது ஓம்', 'நூற்று இருபது ஓம்', 'நாற்பது ஓம்', 'பத்து ஓம்', 'A', 'Active'),
	(9, 3, 1, 'What is the speed of High-Speed CAN?', '', 'High-Speed CAN, defined by ISO 11898-2, can communicate at up to 1 Mbps (1000 Kbps).', '🔍 What is High-Speed CAN?\r\nHigh-Speed CAN is a critical communication bus used in modern vehicles to allow real-time data exchange between ECUs that control safety, powertrain, and dynamic systems.\r\nIt is the fastest form of CAN in the vehicle, capable of handling time-sensitive data reliably and quickly.\r\n________________________________________\r\n🚀 High-Speed CAN Speed: 500 kbps to 1 Mbps\r\nTerm	Meaning\r\nkbps	Kilobits per second\r\nMbps	Megabits per second (1 Mbps = 1000 kbps)\r\n✅ In Tata Motors vehicles:\r\n•	Minimum speed: 500 kbps\r\n•	Maximum speed: 1 Mbps\r\nThis range ensures:\r\n•	Quick response time in safety-critical modules.\r\n•	Stable communication with minimal delay.\r\n•	Compatibility with OBD-II diagnostic tools.\r\n________________________________________\r\n⚙️ Where is High-Speed CAN Used?\r\nVehicle Area	Modules/ECUs Using High-Speed CAN\r\nEngine System	Engine ECU, Fuel Injection, Turbo control\r\nBraking System	ABS, EBD, ESP\r\nTransmission	AMT/AT Control Modules\r\nSafety Systems	Airbags, Crash sensors\r\nDiagnostic Port	Connected to OBD-II (mandatory by law)\r\n________________________________________\r\n⚠️ Common Mistake by Participants\r\nMistake: Some participants answered 250 kbps or 125 kbps, confusing it with Mid-Speed CAN or Low-Speed CAN.\r\nWhy this is incorrect:\r\n•	250 kbps and 125 kbps are used for non-critical systems like HVAC or Body Control Modules.\r\n•	High-Speed CAN handles mission-critical operations and needs higher bandwidth.\r\n________________________________________\r\n💡 Important Notes\r\n•	Tata Motors follows international CAN protocol standards (ISO 11898) for High-Speed communication.\r\n•	Always check wiring diagrams or service manuals to confirm bus type and speed during troubleshooting.\r\n•	Using tools like a CAN scope or diagnostic scanner, incorrect speed settings may lead to no communication error.\r\n________________________________________\r\n🎯 Key Takeaways\r\nType of CAN	Speed Range	Used For\r\nHigh-Speed CAN	500 kbps – 1 Mbps	Safety, Engine, Brakes, Diagnostics\r\nMid-Speed CAN	125 – 250 kbps	Body Control, Comfort modules\r\nLow-Speed / LIN	<125 kbps	Seats, Mirrors, Windows\r\n________________________________________\r\n✅ Quick Recap\r\n•	High-Speed CAN operates at 500 kbps to 1 Mbps.\r\n•	It is used for critical real-time communication in Tata Motors vehicles.\r\n•	Knowing this speed is essential for correct diagnostics and troubleshooting CAN line faults.', '/uploads/1755086513742.pdf', '/uploads/questions/Q3/english/L3.mp3', '/uploads/questions/Q3/english/Q3.mp3', '2025-09-16 05:58:25', '100 Kbps', '300 Kbps', '500 Kbps', 'More Than 500Kbps', 'D', 'Active'),
	(10, 3, 2, 'हाई-स्पीड CAN की स्पीड क्या है?', '', 'हाई-स्पीड CAN, जिसे ISO 11898-2 द्वारा परिभाषित किया गया है, 1 Mbps (1000 Kbps) तक की गति से संचार कर सकता है।', '🔍 हाई-स्पीड CAN क्या है?\r\nहाई-स्पीड CAN एक महत्वपूर्ण संचार बस (communication bus) है जिसका उपयोग आधुनिक वाहनों में किया जाता है ताकि सुरक्षा, पावरट्रेन और डायनेमिक सिस्टम्स को नियंत्रित करने वाले ECU के बीच रीयल-टाइम डेटा एक्सचेंज संभव हो सके।\r\nयह वाहन में सबसे तेज़ प्रकार का CAN नेटवर्क है, जो समय-संवेदनशील डेटा को तेज़ी और विश्वसनीयता के साथ ट्रांसफर करता है।\r\n\r\n🚀 हाई-स्पीड CAN की गति: 500 kbps से 1 Mbps तक\r\n\r\nशब्द	अर्थ\r\nkbps	किलोबिट प्रति सेकंड\r\nMbps	मेगाबिट प्रति सेकंड (1 Mbps = 1000 kbps)\r\n\r\n✅ टाटा मोटर्स वाहनों में:\r\n• न्यूनतम गति: 500 kbps\r\n• अधिकतम गति: 1 Mbps\r\n\r\nयह रेंज सुनिश्चित करती है कि:\r\n• सुरक्षा-सम्बंधित मॉड्यूल्स में तेज़ प्रतिक्रिया समय मिले।\r\n• संचार स्थिर और बिना देरी के हो।\r\n• OBD-II डायग्नोस्टिक टूल्स के साथ पूर्ण संगतता बनी रहे।\r\n\r\n⚙️ हाई-स्पीड CAN कहाँ उपयोग होता है?\r\n\r\nवाहन क्षेत्र	हाई-स्पीड CAN उपयोग करने वाले मॉड्यूल/ECU\r\nइंजन सिस्टम	इंजन ECU, फ्यूल इंजेक्शन, टर्बो कंट्रोल\r\nब्रेकिंग सिस्टम	ABS, EBD, ESP\r\nट्रांसमिशन	AMT/AT कंट्रोल मॉड्यूल्स\r\nसुरक्षा प्रणाली	एयरबैग, क्रैश सेंसर\r\nडायग्नोस्टिक पोर्ट	OBD-II से कनेक्टेड (कानूनी रूप से अनिवार्य)\r\n\r\n⚠️ प्रतिभागियों द्वारा की जाने वाली सामान्य गलती\r\nगलती: कुछ प्रतिभागी 250 kbps या 125 kbps का उत्तर देते हैं, इसे मिड-स्पीड या लो-स्पीड CAN समझकर।\r\n\r\nक्यों गलत है:\r\n• 250 kbps और 125 kbps का उपयोग गैर-महत्वपूर्ण सिस्टम्स जैसे HVAC या बॉडी कंट्रोल मॉड्यूल्स के लिए होता है।\r\n• हाई-स्पीड CAN का उपयोग महत्वपूर्ण (mission-critical) ऑपरेशन्स के लिए किया जाता है, जहाँ उच्च बैंडविड्थ की आवश्यकता होती है।\r\n\r\n💡 महत्वपूर्ण नोट्स\r\n• टाटा मोटर्स हाई-स्पीड संचार के लिए अंतर्राष्ट्रीय CAN प्रोटोकॉल मानक (ISO 11898) का पालन करती है।\r\n• ट्रबलशूटिंग के दौरान हमेशा वायरिंग डायग्राम या सर्विस मैनुअल में बस के प्रकार और गति की पुष्टि करें।\r\n• यदि CAN स्कोप या डायग्नोस्टिक स्कैनर में गलत स्पीड सेटिंग की गई हो, तो नो कम्युनिकेशन एरर उत्पन्न हो सकता है।', '/uploads/1755086513742.pdf', '/uploads/questions/Q3/hindi/L3.mp3', '/uploads/questions/Q3/hindi/Q3.mp3', '2025-09-16 05:58:25', '100  केबीपीएस', '300  केबीपीएस', '500 केबीपीएस', '500  केबीपीएस से अधिक', 'D', 'Active'),
	(11, 3, 3, 'ਹਾਈ-ਸਪੀਡ CAN ਦੀ ਸਪੀਡ ਕੀ ਹੈ?', '', 'ਹਾਈ-ਸਪੀਡ CAN, ISO 11898-2 ਦੁਆਰਾ ਪਰਿਭਾਸ਼ਿਤ, 1 Mbps (1000 Kbps) ਤੱਕ ਸੰਚਾਰ ਕਰ ਸਕਦੀ ਹੈ।', 'ਹਾਈ-ਸਪੀਡ CAN ਆਧੁਨਿਕ ਵਾਹਨਾਂ ਵਿੱਚ ECUs ਵਿਚਕਾਰ ਰੀਅਲ-ਟਾਈਮ ਡੇਟਾ ਐਕਸਚੇਂਜ ਲਈ ਇੱਕ ਮਹੱਤਵਪੂਰਨ ਕमਿਊਨੀਕੇਸ਼न ਬस ਹੈ।', '/uploads/1755086513742.pdf', '/uploads/punjabi_audio3.mp3', '/uploads/punjabi_answer3.mp3', '2025-09-16 05:58:25', '੧੦੦ ਕੇਬੀਪੀਐਸ', '੩੦੦ ਕੇਬੀਪੀਐਸ', '੫੦੦ ਕੇਬੀਪੀਐਸ', '੫੦੦ ਕੇਬੀਪੀਐਸ ਤੋਂ ਵੱਧ', 'D', 'Active'),
	(12, 3, 4, 'ஹை-ஸ்பீட் CAN இன் வேகம் என்ன?', '', 'ஹை-ஸ்பீட் CAN, ISO 11898-2 மூலம் வரையறுக்கப்பட்டது, 1 Mbps (1000 Kbps) வரை தொடர்பு கொள்ள முடியும்.', 'ஹை-ஸ்பீட் CAN என்பது நவீன வாகனங்களில் ECUs க்கு இடையே ரியல்-டைம் டேட்டா பரிமாற்றத்திற்குப் பயன்படும் ஒரு முக்கியமான கம்யூனிகேஷன் பஸ் ஆகும்.', '/uploads/1755086513742.pdf', '/uploads/tamil_audio3.mp3', '/uploads/tamil_answer3.mp3', '2025-09-16 05:58:25', '100 கே.பி.பி.எஸ்', '300 கே.பி.பி.எஸ்', '500 கே.பி.பி.எஸ்', '500 கே.பி.பி.எஸ்-ஐ விட அதிகம்', 'D', 'Active'),
	(13, 4, 1, 'If NOx Upstream sensor is not communicating with ECU in 3.3 L Phase 2, which CAN system will you check?', '', 'In Tata\'s 3.3L Phase 2 platforms, the NOx Upstream Sensor is part of the emission control system.', '🔍 What is the NOx Upstream Sensor?\r\n•	The NOx Upstream Sensor monitors Nitrogen Oxide emissions before SCR treatment.\r\n•	It helps the ECU to:\r\no	Maintain compliance with BS6 emission norms.\r\no	Optimize urea dosing and combustion control.\r\no	Trigger limp mode or warnings if emissions exceed thresholds.\r\n________________________________________\r\n🔌 How Does the NOx Sensor Communicate?\r\nIn the 3.3L Phase 2 Tata Diesel Engine, the NOx Upstream Sensor is an intelligent sensor with a dedicated control module that communicates directly with the ECU over a specific CAN line.\r\n✅ It communicates via:\r\nDiagnostics CAN – High-Speed CAN2\r\n________________________________________\r\n⚙️ Breakdown of CAN Architecture in 3.3L Phase 2\r\nCAN Line	Speed	Used For\r\nHigh-Speed CAN1	500 kbps – 1 Mbps	Engine, ABS, Transmission\r\nHigh-Speed CAN2 (Diag CAN)	500 kbps – 1 Mbps	Diagnostic communication with sensors/modules\r\nLow-Speed CAN / LIN	<125 kbps	Body functions (windows, locks, seats)\r\n________________________________________\r\n📍Why Check Diagnostics CAN (HS CAN2)?\r\n•	The NOx sensor does not transmit data over the primary engine CAN (HS CAN1).\r\n•	It uses the Diagnostic CAN line (CAN2) to:\r\no	Send diagnostic trouble codes (DTCs).\r\no	Share real-time sensor data for OBD monitoring.\r\no	Allow reprogramming or configuration through service tools.\r\nSo if the NOx upstream sensor is not communicating, the first check should be:\r\n•	CAN2 wiring/connectors\r\n•	CAN2 termination\r\n•	Power supply to sensor ECU\r\n•	Continuity between sensor and vehicle ECU on CAN2 line\r\n________________________________________\r\n⚠️ Common Mistake by Participants\r\nMistake: Some participants assumed the sensor communicates over Engine CAN (HS CAN1) because it is related to emissions.\r\nWhy this is incorrect:\r\n•	In Tata\'s 3.3L Phase 2 architecture, emission-related smart sensors are connected to the ECU via CAN2 for isolation and accurate diagnostics.\r\n•	Misidentifying the CAN line can waste time checking the wrong branch of the network.\r\n________________________________________\r\n🎯 Key Takeaways\r\n•	NOx Upstream Sensor in 3.3L Phase 2 engine uses Diagnostics CAN (High-Speed CAN2).\r\n•	It is part of the OBD-related communication path, not the engine operation CAN.\r\n•	Always verify the correct CAN line in wiring diagrams or technical manual before proceeding with troubleshooting.\r\n________________________________________\r\n✅ Quick Recap\r\nItem	Value\r\nEngine Type	3.3L Phase 2\r\nSensor	NOx Upstream\r\nCAN Line Used	Diagnostics CAN (High-Speed CAN2)\r\nTypical Speed	500 kbps – 1 Mbps\r\nCommon Fault Area	Open CAN2 line, connector issues, sensor internal fault', '/uploads/1755086646305.pdf', '/uploads/questions/Q4/english/L4.mp3', '/uploads/questions/Q4/english/Q4.mp3', '2025-09-16 05:58:25', 'D CAN', 'P CAN', 'E CAN', 'I CAN', 'C', 'Active'),
	(14, 4, 2, 'यदि 3.3 L फेज 2 में NOx अपस्ट्रीम सेंसर ECU के साथ कम्युनिकेशन नहीं कर रहा है, तो आप किस CAN सिस्टम को टेस्ट करेंगे?', '', 'टाटा के 3.3L फेज़ 2 प्लेटफॉर्म में, NOx अपस्ट्रीम सेंसर उत्सर्जन नियंत्रण प्रणाली (Emission Control System) का एक हिस्सा है।', '🔍 NOx अपस्ट्रीम सेंसर क्या है?\r\n• NOx अपस्ट्रीम सेंसर SCR ट्रीटमेंट से पहले नाइट्रोजन ऑक्साइड (NOx) उत्सर्जन की निगरानी करता है।\r\n• यह सेंसर ECU को निम्नलिखित में मदद करता है:\r\no BS6 उत्सर्जन मानकों का पालन सुनिश्चित करने में।\r\no यूrea डोज़िंग और दहन नियंत्रण (Combustion Control) को ऑप्टिमाइज़ करने में।\r\no यदि उत्सर्जन सीमा से अधिक हो जाए, तो लिम्प मोड या चेतावनी (warning) सक्रिय करने में।\r\n\r\n🔌 NOx सेंसर कैसे संचार करता है?\r\nटाटा के 3.3L फेज़ 2 डीज़ल इंजन में, NOx अपस्ट्रीम सेंसर एक इंटेलिजेंट सेंसर है, जिसके पास अपना कंट्रोल मॉड्यूल होता है।\r\nयह ECU से एक विशिष्ट CAN लाइन के माध्यम से सीधे संचार करता है।\r\n\r\n✅ यह संचार करता है:\r\nDiagnostics CAN – High-Speed CAN2 के माध्यम से।\r\n\r\n⚙️ 3.3L फेज़ 2 की CAN आर्किटेक्चर का विवरण\r\n\r\nCAN लाइन	गति	उपयोग क्षेत्र\r\nहाई-स्पीड CAN1	500 kbps – 1 Mbps	इंजन, ABS, ट्रांसमिशन\r\nहाई-स्पीड CAN2 (डायग CAN)	500 kbps – 1 Mbps	सेंसर/मॉड्यूल्स के साथ डायग्नोस्टिक संचार\r\nलो-स्पीड CAN / LIN	<125 kbps	बॉडी फंक्शन (विंडो, लॉक, सीट)\r\n\r\n📍 डायग्नोस्टिक CAN (HS CAN2) क्यों जांचें?\r\n• NOx सेंसर अपना डेटा प्राइमरी इंजन CAN (HS CAN1) पर ट्रांसमिट नहीं करता।\r\n• यह डायग्नोस्टिक CAN लाइन (CAN2) का उपयोग करता है ताकि:\r\no डायग्नोस्टिक ट्रबल कोड (DTCs) भेज सके।\r\no OBD मॉनिटरिंग के लिए रीयल-टाइम सेंसर डेटा साझा कर सके।\r\no सर्विस टूल्स के माध्यम से रीप्रोग्रामिंग या कॉन्फ़िगरेशन की अनुमति दे सके।', '/uploads/1755086646305.pdf', '/uploads/questions/Q4/hindi/L4.mp3', '/uploads/questions/Q4/hindi/Q4.mp3', '2025-09-16 05:58:25', 'डी कैन', 'पी कैन', 'ई कैन', 'आई कैन', 'C', 'Active'),
	(15, 4, 3, 'ਜੇਕਰ 3.3 L ਫੇਜ਼ 2 ਵਿੱਚ NOx ਅਪਸਟ੍ਰੀਮ ਸੈਂਸਰ ECU ਨਾਲ ਸੰਚਾਰ ਨਹੀਂ ਕਰ ਰਿਹਾ ਹੈ, ਤਾਂ ਤੁਸੀਂ ਕਿਸ CAN ਸਿਸਟਮ ਦੀ ਜਾਂਚ ਕਰੋਗੇ?', '', 'ਟਾਟਾ ਦੇ 3.3L ਫےਜ਼ 2 ਪਲੇਟਫਾਰਮਾਂ ਵਿੱਚ, NOx ਅਪਸਟ੍ਰੀਮ ਸੈਂਸਰ ਉਤਸਰਜਨ ਨਿਯੰਤਰਣ ਪ੍ਰਣਾਲੀ ਦਾ ਹਿੱਸਾ ਹੈ।', 'NOx ਅਪਸਟ੍ਰੀਮ ਸੈਂਸਰ SCR ਟ੍ਰੀਟਮੈਂਟ ਤੋਂ ਪਹਿਲਾਂ ਨਾਈਟ੍ਰੋਜਨ ਆਕਸਾਈਡ ਉਤਸਰਜਨ ਦੀ ਨਿਗਰਾਨੀ ਕਰਦਾ ਹੈ ਅਤੇ BS6 ਅਨੁਪਾਲਨ ਬਣਾਈ ਰੱਖਣ ਵਿੱਚ ਮਦਦ ਕਰਦਾ ਹੈ।', '/uploads/1755086646305.pdf', '/uploads/punjabi_audio4.mp3', '/uploads/punjabi_answer4.mp3', '2025-09-16 05:58:25', 'ਡੀ ਕੈਨ', 'ਪੀ ਕੈਨ', 'ਈ ਕੈਨ', 'ਆਈ ਕੈਨ', 'C', 'Active'),
	(16, 4, 4, '3.3 L பேஸ் 2 இல் NOx அப்ஸ்ட்ரீம் சென்சார் ECU உடன் தொடர்பு கொள்ளவில்லை என்றால், எந்த CAN அமைப்பை நீங்கள் சரிபார்க்குவீர்கள்?', '', 'டாடாவின் 3.3L பேஸ் 2 தளங்களில், NOx அப்ஸ்ட்ரீம் சென்சார் என்பது எமிஷன் கன்ட்ரோல் சிஸ்டத்தின் ஒரு பகுதியாகும்.', 'NOx அப்ஸ்ட்ரீம் சென்சார் SCR சிகிச்சைக்கு முன் நைட்ரஜன் ஆக்சைடு எமிஷன்களை கண்காணிக்கிறது மற்றும் BS6 இணக்கத்தை பராமரிக்க உதவுகிறது.', '/uploads/1755086646305.pdf', '/uploads/tamil_audio4.mp3', '/uploads/tamil_answer4.mp3', '2025-09-16 05:58:25', 'டி கான்', 'பி கான்', 'ஈ கான்', 'ஐ கான்', 'C', 'Active'),
	(17, 5, 1, 'In Ultra T 14, ICAN is connected between Instrument Cluster & ____________?', '', 'In Ultra T14 platforms, ICAN (Instrument CAN) provides the communication link between Instrument Cluster and VECU/BCM.', '🧩 What is ICAN?\r\nICAN = Instrumentation CAN\r\nIt is a dedicated communication channel in Tata Ultra series vehicles used for:\r\n•	Vehicle dashboard data display\r\n•	Cluster messages, warnings, tell-tales\r\n•	Communication with Telematics Unit, which sends/receives real-time data from Tata Fleet Edge or similar platforms.\r\n________________________________________\r\n🔌 ECUs on the ICAN Network in Ultra T14\r\nECU	Role\r\nInstrument Cluster	Displays speed, fuel, RPM, DTCs, tell-tales, alerts\r\nTelematics Unit (TDC)	Sends vehicle data (e.g., speed, fuel level, DTCs) to server via GPS/GPRS\r\nThese two are directly connected via the ICAN bus.\r\n________________________________________\r\n🔧 How Does ICAN Work Here?\r\n•	The Instrument Cluster collects real-time data from other ECUs (e.g., engine ECU via gateway).\r\n•	It shares this data with the Telematics Unit through ICAN.\r\n•	The Telematics Unit transmits selected parameters to the Tata Fleet Management System, which allows:\r\no	Remote monitoring\r\no	Fleet analytics\r\no	Vehicle health alerts\r\no	Driving behavior tracking\r\n________________________________________\r\n📍Example Data Flow\r\n1.	Engine ECU sends engine speed to the Instrument Cluster (via CAN1).\r\n2.	Cluster receives and displays it.\r\n3.	The same data is shared with the Telematics Unit via ICAN.\r\n4.	Telematics Unit sends the data to the cloud.\r\n________________________________________\r\n⚠️ Common Mistake by Participants\r\nMistake: Some participants answered "BCM" or "Engine ECU" instead of Telematics Unit.\r\nWhy this is incorrect:\r\n•	Engine ECU and BCM communicate over other CAN lines (e.g., CAN1, CAN2).\r\n•	ICAN is a dedicated short CAN loop between Cluster and Telematics Unit only.\r\n________________________________________\r\n🎯 Key Takeaways\r\n•	ICAN in Ultra T14 connects only two ECUs:\r\no	Instrument Cluster\r\no	Telematics Unit (TDC)\r\n•	It ensures real-time data sharing for fleet monitoring and dashboard display coordination.\r\n•	Understanding this connection is crucial for diagnosing cluster communication or data transmission issues.\r\n________________________________________\r\n✅ Quick Recap\r\nParameter	Value\r\nVehicle	Ultra T14 (BSVI Platform)\r\nCAN Line	ICAN\r\nECUs Connected	Instrument Cluster & Telematics Unit\r\nPurpose	Fleet data communication and display\r\nCommon Issue Symptoms	No GPS data, No tell-tale sync, CAN errors in Telematics', '/uploads/1755086811837.pdf', '/uploads/questions/Q5/english/L5.mp3', '/uploads/questions/Q5/english/Q5.mp3', '2025-09-16 05:58:25', 'ECU', 'VECU/BCM', 'GDCU', 'NOx Sensor', 'B', 'Active'),
	(18, 5, 2, 'अल्ट्रा T 14 में, ICAN इंस्ट्रूमेंट क्लस्टर और ____________ के बीच जुड़ा हुआ है?', '', 'अल्ट्रा T14 प्लेटफ़ॉर्म में, ICAN (Instrument CAN) इंस्ट्रूमेंट क्लस्टर और VECU/BCM के बीच संचार लिंक प्रदान करता है।', '🧩 ICAN क्या है?\r\nICAN = Instrumentation CAN\r\nयह टाटा अल्ट्रा सीरीज़ वाहनों में उपयोग किया जाने वाला एक समर्पित (dedicated) संचार चैनल है, जिसका उपयोग निम्नलिखित कार्यों के लिए किया जाता है:\r\n• वाहन डैशबोर्ड पर डेटा प्रदर्शित करने के लिए\r\n• क्लस्टर संदेश, चेतावनियाँ (warnings), और टेल-टेल्स दिखाने के लिए\r\n• टेलीमैटिक्स यूनिट (Telematics Unit) के साथ संचार करने के लिए, जो Tata Fleet Edge या इसी तरह के प्लेटफ़ॉर्म से रीयल-टाइम डेटा भेजती और प्राप्त करती है।\r\n\r\n🔌 Ultra T14 में ICAN नेटवर्क पर जुड़े ECU\r\n\r\nECU	भूमिका (Role)\r\nइंस्ट्रूमेंट क्लस्टर	स्पीड, फ्यूल, RPM, DTCs, टेल-टेल्स और अलर्ट प्रदर्शित करता है\r\nटेलीमैटिक्स यूनिट (TDC)	वाहन डेटा (जैसे स्पीड, फ्यूल लेवल, DTCs) को GPS/GPRS के माध्यम से सर्वर तक भेजता है\r\n\r\nये दोनों ECU सीधे ICAN बस के माध्यम से एक-दूसरे से जुड़े होते हैं।\r\n\r\n🔧 ICAN यहाँ कैसे काम करता है?\r\n• इंस्ट्रूमेंट क्लस्टर, अन्य ECU (जैसे इंजन ECU) से गेटवे के माध्यम से रीयल-टाइम डेटा प्राप्त करता है।\r\n• यह डेटा फिर टेलीमैटिक्स यूनिट के साथ ICAN के माध्यम से साझा किया जाता है।\r\n• टेलीमैटिक्स यूनिट चयनित पैरामीटर को Tata Fleet Management System को भेजती है, जिससे संभव होता है:\r\no रिमोट मॉनिटरिंग\r\no फ्लीट एनालिटिक्स\r\no वाहन स्वास्थ्य अलर्ट\r\no ड्राइविंग व्यवहार ट्रैकिंग\r\n\r\n📍 डेटा फ्लो का उदाहरण:\r\n1️⃣ इंजन ECU इंजन स्पीड डेटा इंस्ट्रूमेंट क्लस्टर को भेजता है (CAN1 के माध्यम से)।\r\n2️⃣ क्लस्टर डेटा प्राप्त करता है और डिस्प्ले पर दिखाता है।\r\n3️⃣ वही डेटा ICAN के माध्यम से टेलीमैटिक्स यूनिट को भेजा जाता है।\r\n4️⃣ टेलीमैटिक्स यूनिट वह डेटा क्लाउड सर्वर को ट्रांसमिट करती है।\r\n\r\n⚠️ प्रतिभागियों द्वारा की जाने वाली सामान्य गलती\r\nगलती: कुछ प्रतिभागियों ने BCM या Engine ECU का उत्तर दिया, टेलीमैटिक्स यूनिट के स्थान पर।\r\n\r\nक्यों गलत है:\r\n• Engine ECU और BCM अन्य CAN लाइनों (जैसे CAN1, CAN2) के माध्यम से संचार करते हैं।\r\n• ICAN एक छोटी, समर्पित CAN लाइन है, जो केवल क्लस्टर और टेलीमैटिक्स यूनिट के बीच जुड़ी होती है।\r\n\r\n🎯 मुख्य बातें (Key Takeaways)\r\n• Ultra T14 में ICAN केवल दो ECU को जोड़ता है:\r\no Instrument Cluster\r\no Telematics Unit (TDC)\r\n• यह फ्लीट मॉनिटरिंग और डैशबोर्ड डिस्प्ले सिंक्रोनाइज़ेशन के लिए रीयल-टाइम डेटा शेयरिंग सुनिश्चित करता है।\r\n• इस कनेक्शन को समझना क्लस्टर कम्युनिकेशन या डेटा ट्रांसमिशन से जुड़ी समस्याओं के निदान में महत्वपूर्ण है।\r\n\r\n✅ त्वरित पुनरावलोकन (Quick Recap)\r\n\r\nपैरामीटर	मान (Value)\r\nवाहन	Ultra T14 (BSVI प्लेटफ़ॉर्म)\r\nCAN लाइन	ICAN\r\nजुड़े ECU	इंस्ट्रूमेंट क्लस्टर और टेलीमैटिक्स यूनिट\r\nउद्देश्य	फ्लीट डेटा कम्युनिकेशन और डिस्प्ले\r\nसामान्य समस्या लक्षण	GPS डेटा न मिलना, टेल-टेल सिंक न होना, टेलीमैटिक्स में CAN एरर', '/uploads/1755086811837.pdf', '/uploads/questions/Q5/hindi/L5.mp3', '/uploads/questions/Q5/hindi/Q5.mp3', '2025-09-16 05:58:25', 'ईसीयू', 'वीईसीयू/बीसीएम', 'जीडीसीयू', 'एनओएक्स सेंसर', 'B', 'Active'),
	(19, 5, 3, 'ਅਲਟਰਾ T 14 ਵਿੱਚ, ICAN ਇੰਸਟ੍ਰੂਮੈਂਟ ਕਲਸਟਰ ਅਤੇ ____________ ਦੇ ਵਿਚਕਾਰ ਜੁੜਿਆ ਹੋਇਆ ਹੈ?', '', 'ਅਲਟਰਾ T14 ਪਲੇਟਫਾਰਮਾਂ ਵਿੱਚ, ICAN (ਇੰਸਟ੍ਰੂਮੈਂਟ CAN) ਇੰਸਟ੍ਰੂਮੈਂਟ ਕਲਸਟਰ ਅਤੇ VECU/BCM ਦੇ ਵਿਚਕਾਰ ਸੰਚਾਰ ਲਿੰਕ ਪ੍ਰਦਾਨ ਕਰਦਾ ਹੈ।', 'ICAN ਵਾਹਨ ਡੈਸ਼ਬੋਰਡ ਡੇਟਾ ਡਿਸਪਲੇ ਅਤੇ ਕਲਸਟਰ ਸੁਨੇਹਿਆਂ  ਲਈ ਵਰਤਿਆ ਜਾਣ ਵਾਲਾ ਇੱਕ ਸਮਰਪਿਤ ਸੰਚਾਰ ਚੈਨਲ ਹੈ।', '/uploads/1755086811837.pdf', '/uploads/punjabi_audio5.mp3', '/uploads/punjabi_answer5.mp3', '2025-09-16 05:58:25', 'ਈਸੀਯੂ', 'ਵੀਈਸੀਯੂ/ਬੀਸੀਐਮ', 'ਜੀਡੀਸੀਯੂ', 'ਐਨਓਐਕਸ ਸੈਂਸਰ', 'B', 'Active'),
	(20, 5, 4, 'அல்ட்ரா T 14 இல், ICAN இன்ஸ்ட்ருமென்ட் கிளஸ்டர் மற்றும் ____________ இடையே இணைக்கப்பட்டுள்ளது?', '', 'அல்ட்ரா T14 தளங்களில், ICAN (இன்ஸ்ட்ருமென்ட் CAN) இன்ஸ்ட்ருமென்ட் கிளஸ்டர் மற்றும் VECU/BCM க்கு இடையேயான தொடர்பு இணைப்பை வழங்குகிறது.', 'ICAN என்பது வாகன டாஷ்போர்டு டேட்டா டிஸ்ப்ளே மற்றும் கிளஸ்டர் செய்திகளுக்குப் பயன்படுத்தப்படும் ஒரு அர்ப்பணிக்கப்பட்ட தொடர்பு சேனல் ஆகும்.', '/uploads/1755086811837.pdf', '/uploads/tamil_audio5.mp3', '/uploads/tamil_answer5.mp3', '2025-09-16 05:58:25', 'ஈ.சி.யூ', 'வீ.இ.சி.யூ/பி.சி.எம்', 'ஜி.டி.சி.யூ', 'என்.ஆக்ஸ் சென்சார்', 'B', 'Active'),
	(21, 6, 1, 'If CAN Low & CAN High wires are short circuit, then what resistance will you get on OBD Connector between Pin No 6 & Pin No 14.', '', 'In case of a short circuit between CAN High and CAN Low, the resistance drops well below expected values.', '🔍 Understanding CAN Bus Termination\r\nA healthy CAN Bus has:\r\n•	Two termination resistors of 120 ohms each, connected at the two ends of the CAN line.\r\n•	The effective total resistance between CAN High (Pin 6) and CAN Low (Pin 14) should be:\r\n✅ ~60 Ohms (When both terminators are present and no short circuit exists)\r\n________________________________________\r\n⚠️ What Happens in a Short Circuit?\r\nIf CAN High and CAN Low wires are shorted:\r\n•	They are directly connected together (no resistance in between).\r\n•	You will get 0 Ohms resistance at the OBD connector (between Pin 6 and Pin 14).\r\nThis is because electricity flows freely between the lines due to the short, with no resistance to oppose it.\r\n________________________________________\r\n🔌 OBD (16-pin DLC) Pin Reference\r\nPin Number	Signal\r\n6	CAN High\r\n14	CAN Low\r\n________________________________________\r\n🧪 Resistance Readings – What They Indicate\r\nResistance Value (Between Pin 6 & 14)	Condition\r\n~60 Ohms	✅ Healthy CAN network\r\n120 Ohms	❗ One terminator missing (open end)\r\n0 Ohms	❌ Short circuit between CAN H & L\r\nInfinite / OL (Over Limit)	❌ Open circuit or broken CAN wires\r\n________________________________________\r\n🧠 Practical Scenario\r\nTechnician connects a multimeter across Pins 6 and 14 of the OBD port and sees:\r\n🔻 Reading: 0 Ohms\r\n✅ Interpretation: There is a short circuit between CAN High and CAN Low — likely due to:\r\n•	Crushed or pinched harness\r\n•	Water ingress causing bridging\r\n•	Connector back-probing damage\r\n•	Solder or splice issues\r\n________________________________________\r\n🎯 Key Takeaways\r\n•	Short circuit between CAN H & CAN L = 0 Ohms resistance across OBD Pins 6 & 14.\r\n•	Use a multimeter in resistance (Ω) mode with vehicle ignition OFF.\r\n•	Always measure between DLC Pin 6 (CAN H) and Pin 14 (CAN L).\r\n•	Correct interpretation of resistance is key to accurate CAN line diagnostics.\r\n________________________________________\r\n✅ Quick Recap\r\nCondition	Resistance (Pin 6–14)\r\nHealthy CAN (2 terminators)	~60 Ohms\r\nOne terminator only	~120 Ohms\r\nShort between CAN H & L	0 Ohms\r\nOpen or broken circuit	Infinite / OL', '/uploads/1755086968748.pdf', '/uploads/questions/Q6/english/L6.mp3', '/uploads/questions/Q6/english/Q6.mp3', '2025-09-16 05:58:25', '60Ω', '40Ω', '120Ω', '10Ω', 'B', 'Active'),
	(22, 6, 2, 'यदि CAN Low और CAN High वायर शॉर्ट सर्किट हैं, तो OBD कनेक्टर पर Pin No 6 और Pin No 14 के बीच आपको कितना रेजिस्टेंस  मिलेगा?', '', 'यदि CAN High और CAN Low के बीच शॉर्ट सर्किट हो जाए, तो रेज़िस्टेंस अपेक्षित मान से काफी नीचे गिर जाती है।', '🔍 CAN बस टर्मिनेशन की समझ\r\nएक स्वस्थ CAN बस में होता है:\r\n• दो टर्मिनेशन रेज़िस्टर्स (प्रत्येक 120 ओम) जो CAN लाइन के दोनों सिरों पर जुड़े होते हैं।\r\n• CAN High (Pin 6) और CAN Low (Pin 14) के बीच कुल प्रभावी रेज़िस्टेंस होना चाहिए:\r\n✅ लगभग 60 ओम (जब दोनों टर्मिनेटर मौजूद हों और शॉर्ट सर्किट न हो)\r\n\r\n⚠️ शॉर्ट सर्किट होने पर क्या होता है?\r\nयदि CAN High और CAN Low तार शॉर्ट हो जाएँ:\r\n• वे सीधे एक-दूसरे से जुड़ जाते हैं (बीच में कोई रेज़िस्टेंस नहीं)।\r\n• OBD कनेक्टर (Pin 6 और Pin 14 के बीच) पर रेज़िस्टेंस 0 ओम दिखाई देगा।\r\nयह इसलिए होता है क्योंकि शॉर्ट के कारण बिजली दोनों लाइनों में बिना किसी प्रतिरोध के स्वतंत्र रूप से बहती है।\r\n\r\n🔌 OBD (16-पिन DLC) पिन संदर्भ\r\n\r\nपिन नंबर	सिग्नल\r\n6	CAN High\r\n14	CAN Low\r\n\r\n🧪 रेज़िस्टेंस रीडिंग्स – उनका अर्थ\r\n\r\nरेज़िस्टेंस मान (Pin 6 & 14 के बीच)	स्थिति\r\n~60 ओम	✅ स्वस्थ CAN नेटवर्क\r\n120 ओम	❗ केवल एक टर्मिनेटर मौजूद (ओपन एंड)\r\n0 ओम	❌ CAN H & L के बीच शॉर्ट सर्किट\r\nअनंत / OL (Over Limit)	❌ ओपन सर्किट या टूटी हुई CAN वायर\r\n\r\n🧠 प्रैक्टिकल उदाहरण\r\nटेक्नीशियन OBD पोर्ट के Pin 6 और 14 के बीच मल्टीमीटर लगाता है और पढ़ता है:\r\n🔻 रीडिंग: 0 ओम\r\n✅ व्याख्या: CAN High और CAN Low के बीच शॉर्ट सर्किट — संभावित कारण:\r\n• कुचले या दबे हुए हार्नेस\r\n• पानी का रिसाव (Water ingress) causing bridging\r\n• कनेक्टर बैक-प्रोबिंग डैमेज\r\n• सोल्डर या स्प्लाइस समस्या\r\n\r\n🎯 मुख्य बातें (Key Takeaways)\r\n• CAN H & CAN L के बीच शॉर्ट = OBD Pins 6 & 14 पर 0 ओम रेज़िस्टेंस\r\n• वाहन की इग्निशन OFF स्थिति में मल्टीमीटर का उपयोग करें।\r\n• हमेशा DLC Pin 6 (CAN H) और Pin 14 (CAN L) के बीच मापें।\r\n• रेज़िस्टेंस की सही व्याख्या सटीक CAN लाइन डायग्नोस्टिक्स के लिए महत्वपूर्ण है।\r\n\r\n✅ त्वरित पुनरावलोकन (Quick Recap)\r\n\r\nस्थिति	रेज़िस्टेंस (Pin 6–14)\r\nस्वस्थ CAN (2 टर्मिनेटर)	~60 ओम\r\nकेवल एक टर्मिनेटर	~120 ओम\r\nCAN H & L के बीच शॉर्ट	0 ओम\r\nओपन या टूटी सर्किट	अनंत / OL', '/uploads/1755086968748.pdf', '/uploads/questions/Q6/hindi/L6.mp3', '/uploads/questions/Q6/hindi/Q6.mp3', '2025-09-16 05:58:25', '60 ओम', '40 ओम', '120 ओम', '10 ओम', 'B', 'Active'),
	(23, 6, 3, 'ਜੇਕਰ CAN Low ਅਤੇ CAN High ਵਾਇਰਾਂ ਵਿੱਚ ਸ਼ਾਰਟ ਸਰਕਟ ਹੈ, ਤਾਂ OBD ਕਨੈਕਟਰ \'ਤੇ ਪਿੰਨ ਨੰਬਰ 6 ਅਤੇ ਪਿੰਨ ਨੰਬर 14 ਦੇ ਵਿਚਕਾਰ ਤੁਹਾਨੂੰ ਕਿੰਨਾ ਪ੍ਰਤੀਰੋਧ ਮਿਲੇਗਾ?', '', 'CAN High ਅਤੇ CAN Low ਦੇ ਵਿਚਕਾਰ ਸ਼ਾਰਟ ਸਰਕਟ ਦੀ ਸਥਿਤੀ ਵਿੱਚ, ਪ੍ਰਤੀਰੋਧ ਉਮੀਦਵਾਰ ਮੁੱਲਾਂ ਤੋਂ ਕਾਫੀ ਹੇਠਾਂ ਡਿੱਗ ਜਾਂਦਾ ਹੈ।', 'ਇੱਕ ਸਿਹਤਮੰਦ CAN ਬਸ ਵਿੱਚ 120 ਓਮ ਦੇ ਦੋ ਟਰਮੀਨੇਸ਼ਨ ਰੈਜ਼ਿਸਟਰ ਹੁੰਦੇ ਹਨ, ਜੋ CAN High ਅਤੇ CAN Low ਦੇ ਵਿਚਕਾਰ ~60 ਓਮ ਦਾ ਪ੍ਰਭਾਵੀ ਪ੍ਰਤੀਰੋਧ ਦਿੰਦੇ ਹਨ।', '/uploads/1755086968748.pdf', '/uploads/punjabi_audio6.mp3', '/uploads/punjabi_answer6.mp3', '2025-09-16 05:58:25', 'ਸਾਠ ਓਮ', 'ਚਾਲੀ ਓਮ', 'ਇੱਕ ਸੌ ਵੀਹ ਓਮ', 'ਦਸ ਓਮ', 'B', 'Active'),
	(24, 6, 4, 'CAN Low & CAN High கம்பிகள் ஷார்ட் சர்க்யூட் என்றால், OBD இணைப்பியில் பின் எண் 6 மற்றும் பின் எண் 14 க்கு இடையே எவ்வளவு எதிர்ப்பு கிடைக்கும்?', '', 'CAN High மற்றும் CAN Low க்கு இடையே ஷார்ட் சர்க்யூட் ஏற்பட்டால், எதிர்ப்பு எதிர்பார்க்கப்பட்ட மதிப்புகளை விட கணிசமாக குறைகிறது.', 'ஒரு ஆரோக்கியமான CAN பஸில் 120 ஓம்ஸின் இரண்டு டெர்மினேஷன் ரெசிஸ்டர்கள் உள்ளன, இது CAN High மற்றும் CAN Low க்கு இடையே ~60 ஓம்ஸின் பயனுள்ள எதிர்ப்பை அளிக்கிறது.', '/uploads/1755086968748.pdf', '/uploads/tamil_audio6.mp3', '/uploads/tamil_answer6.mp3', '2025-09-16 05:58:25', 'அறுபது ஓம்', 'நாற்பது ஓம்', 'நூற்று இருபது ஓம்', 'பத்து ஓம்', 'B', 'Active'),
	(25, 7, 1, 'In SIGNA BSVI Steering Angle Sensor is connected to which CAN?', '', 'In SIGNA M&HCV BSVI platforms, the Steering Angle Sensor is part of the ICAN network.', 'What is the Steering Angle Sensor (SAS)?\r\n•	The Steering Angle Sensor detects:\r\no	The position, direction, and speed of rotation of the steering wheel.\r\no	Crucial input for systems like ABS, ESC (Electronic Stability Control), and hill hold assist.\r\n•	It helps in controlling vehicle dynamics and safety systems by providing real-time steering feedback to the ECU.\r\n________________________________________\r\n🔌 Where is the SAS Connected in SIGNA BSVI?\r\n✅ Connected to:\r\nCAN2 (High-Speed Diagnostic CAN)\r\n•	NOT connected directly to Engine ECU via CAN1.\r\n•	CAN2 allows the sensor to:\r\no	Communicate with relevant ECUs (like ESC/ABS module).\r\no	Be accessed during diagnostic scans (read live data or DTCs).\r\no	Function independently from critical engine control messaging on CAN1.\r\n________________________________________\r\n📊 CAN Network Overview – SIGNA BSVI\r\nCAN Line	Speed	Typical ECUs Connected\r\nCAN1 (HS CAN)	500 kbps – 1 Mbps	Engine ECU, Transmission, ABS\r\nCAN2 (Diag CAN)	500 kbps – 1 Mbps	Steering Angle Sensor, Telematics, DEF ECU\r\nLow-Speed CAN/LIN	<125 kbps	Body modules (e.g., window, HVAC)\r\n________________________________________\r\n⚠️ Common Mistake by Participants\r\nMistake: Answered "Engine CAN" (CAN1), assuming all safety-related sensors are connected there.\r\nWhy this is incorrect:\r\n•	SAS data is not time-critical like engine injection timing, hence diagnostics CAN (CAN2) is used.\r\n•	CAN2 allows the cluster and ESC modules to access this data efficiently.\r\n•	Tata Motors keeps SAS and similar sensors on CAN2 for modular diagnostics and flexibility.\r\n________________________________________\r\n🔧 Real-Life Application\r\nWhile diagnosing hill hold failure or ESC malfunction, if SAS is not showing data in the scanner:\r\n•	First, check CAN2 continuity.\r\n•	Confirm power and ground to the SAS.\r\n•	Check for DTCs on CAN2-related modules.\r\n________________________________________\r\n🎯 Key Takeaways\r\n•	In SIGNA BSVI, the Steering Angle Sensor (SAS) is connected to Diagnostics CAN (CAN2).\r\n•	It communicates with ABS/ESC, BCM, or telematics via CAN2.\r\n•	Knowing this avoids wasting time checking the wrong network (like CAN1).\r\n________________________________________\r\n✅ Quick Recap\r\nSensor	Steering Angle Sensor (SAS)\r\nVehicle Platform	SIGNA BSVI\r\nConnected CAN	Diagnostics CAN (High-Speed CAN2)\r\nSpeed	500 kbps – 1 Mbps\r\nFunction	Steering direction, angle, feedback\r\nUsed By	ABS, ESC, Hill Hold Assist', '/uploads/1755087101814.pdf', '/uploads/questions/Q7/english/L7.mp3', '/uploads/questions/Q7/english/Q7.mp3', '2025-09-16 05:58:25', 'I CAN', 'E CAN', 'C CAN', 'P CAN', 'A', 'Active'),
	(26, 7, 2, 'SIGNA BSVI में स्टीयरिंग एंगल सेंसर किस CAN से कनेक्टेड  है?', '', 'SIGNA M&HCV BSVI प्लेटफ़ॉर्म में, Steering Angle Sensor ICAN नेटवर्क का हिस्सा है।', 'Steering Angle Sensor (SAS) क्या है?\r\n• Steering Angle Sensor निम्नलिखित को पहचानता है:\r\no स्टीयरिंग व्हील की स्थिति, दिशा और घूर्णन की गति\r\no ABS, ESC (Electronic Stability Control), Hill Hold Assist जैसे सिस्टम्स के लिए महत्वपूर्ण इनपुट\r\n• यह ECU को रीयल-टाइम स्टीयरिंग फीडबैक प्रदान करके वाहन डायनेमिक्स और सुरक्षा सिस्टम्स को नियंत्रित करने में मदद करता है।\r\n\r\n🔌 SIGNA BSVI में SAS कहाँ जुड़ा है?\r\n✅ जुड़ा है: CAN2 (High-Speed Diagnostic CAN)\r\n• Engine ECU के साथ सीधे CAN1 के माध्यम से नहीं जुड़ा।\r\n• CAN2 सेंसर को सक्षम करता है कि:\r\no संबंधित ECU (जैसे ESC/ABS मॉड्यूल) के साथ संचार करे।\r\no डायग्नोस्टिक स्कैन के दौरान डेटा या DTCs पढ़ा जा सके।\r\no Engine CAN1 पर क्रिटिकल मैसेजिंग से स्वतंत्र रूप से काम करे।\r\n\r\n📊 CAN नेटवर्क का अवलोकन – SIGNA BSVI\r\n\r\nCAN लाइन	गति	सामान्य जुड़े ECU\r\nCAN1 (HS CAN)	500 kbps – 1 Mbps	इंजन ECU, ट्रांसमिशन, ABS\r\nCAN2 (Diag CAN)	500 kbps – 1 Mbps	Steering Angle Sensor, Telematics, DEF ECU\r\nलो-स्पीड CAN / LIN	<125 kbps	बॉडी मॉड्यूल्स (जैसे विंडो, HVAC)\r\n\r\n⚠️ प्रतिभागियों द्वारा की जाने वाली सामान्य गलती\r\nगलती: "Engine CAN (CAN1)" का उत्तर देना, यह मानकर कि सभी सुरक्षा-संबंधित सेंसर वहीं जुड़े हैं।\r\n\r\nक्यों गलत है:\r\n• SAS डेटा इंजन इंजेक्शन टाइमिंग जैसा टाइम-संवेदनशील नहीं है, इसलिए Diagnostics CAN (CAN2) का उपयोग किया जाता है।\r\n• CAN2 क्लस्टर और ESC मॉड्यूल्स को डेटा कुशलतापूर्वक एक्सेस करने की अनुमति देता है।\r\n• टाटा मोटर्स SAS और इसी तरह के सेंसर को CAN2 पर रखता है ताकि मॉड्यूलर डायग्नोस्टिक और लचीलापन बना रहे।', '/uploads/1755087101814.pdf', '/uploads/questions/Q7/hindi/L7.mp3', '/uploads/questions/Q7/hindi/Q7.mp3', '2025-09-16 05:58:25', 'आई कैन', 'ई कैन', 'सी कैन', 'पी कैन', 'A', 'Active'),
	(27, 7, 3, 'SIGNA BSVI ਵਿੱਚ ਸਟੀਅਰਿੰਗ ਐਂਗਲ ਸੈਂਸर ਕਿਸ CAN ਨਾਲ ਜੁੜਿਆ ਹੈ?', '', 'SIGNA M&HCV BSVI ਪਲੇਟਫਾਰਮਾਂ ਵਿੱਚ, ਸਟੀਅਰਿੰਗ ਐਂਗਲ ਸੈਂਸਰ ICAN ਨੈੱਟਵਰਕ ਦਾ ਹਿੱਸਾ ਹੈ।', 'ਸਟੀਅਰਿੰਗ ਐਂਗਲ ਸੈਂਸਰ ਸੁਰੱਖਿਆ ਪ੍ਰਣਾਲੀਆਂ ਲਈ ਸਟੀਅਰਿੰਗ ਵਹੀਲ ਦੇ ਘੁਮਾਓ ਦੀ ਸਥਿਤੀ, ਦਿਸ਼ਾ ਅਤੇ ਗਤੀ ਦਾ ਪਤਾ ਲਗਾਉਂਦਾ ਹੈ।', '/uploads/1755087101814.pdf', '/uploads/punjabi_audio7.mp3', '/uploads/punjabi_answer7.mp3', '2025-09-16 05:58:25', 'ਆਈ ਕੈਨ', 'ਈ ਕੈਨ', 'ਸੀ ਕੈਨ', 'ਪੀ ਕੈਨ', 'A', 'Active'),
	(28, 7, 4, 'SIGNA BSVI இல் ஸ்டீயரிங் ஆங்கிள் சென்சார் எந்த CAN உடன் இணைக்கப்பட்டுள்ளது?', '', 'SIGNA M&HCV BSVI தளங்களில், ஸ்டீயரிங் ஆங்கிள் சென்சார் ICAN நெட்வொர்க்கின் ஒரு பகுதியாகும்.', 'ஸ்டீயரிங் ஆங்கிள் சென்சார் பாதுகாப்பு அமைப்புகளுக்காக ஸ்டீயரிங் வீலின் நிலை, திசை மற்றும் சுழற்சி வேகத்தைக் கண்டறிகிறது.', '/uploads/1755087101814.pdf', '/uploads/tamil_audio7.mp3', '/uploads/tamil_answer7.mp3', '2025-09-16 05:58:25', 'ஐ கான்', 'ஈ கான்', 'சி கான்', 'பி கான்', 'A', 'Active'),
	(29, 8, 1, 'If you are getting DTC of Boost Pressure Sensor Signal range High, what is the suspected fault?', '/uploads/questions/Q8/english/M8.mp4', 'When Signal Wire is Short to Battery Voltage it becomes higher than the Signal Limit that’s why ECU register a DTC of Signal Range High.', 'There are three wires For Boost Pressure Sensor in That Reference Voltage from ECU to Sensor is 5V to activate sensor to generate voltage through Signal wire. Another wire is for Ground which completes the circuit works as return Path for Supply to ECU.\r\nSignal Wire is only to pass the signal voltage to ECU. But in OBD 2 ECU Supplies 5 Volt to the Signal wire through pull down resistor in series but current level is very low. Why it is done suppose the signal wire is cut so the complete 5 Volt will receive by ECU without consumption so it will generate DTC of Signal Too high but when it is Short to 12 Volts it crosses the maximum signal range of 5 Volt that’s why it is generating DTC Signal range high,\r\n', '/uploads/1755087309595.pdf', '/uploads/questions/Q8/english/L8.mp3', '/uploads/questions/Q8/english/Q8.mp3', '2025-09-16 05:58:25', 'Signal wire short to battery voltage', 'Input Voltage short to ground', 'Signal wire Short to Ground', 'Ground wire Short to Ground', 'A', 'Active'),
	(30, 8, 2, 'यदि आपको “Boost Pressure Sensor Signal Range High” DTC मिल रहा है, तो संदिग्ध फाल्ट क्या हो सकता है?', '/uploads/questions/Q8/hindi/M8.mp4', 'सिग्नल वायर जब बैटरी वोल्टेज से शॉर्ट हो जाता है, तो उसका मान सिग्नल लिमिट से अधिक हो जाता है। इसी कारण ECU एक DTC Signal Range High दर्ज कर देता है।', 'बूस्ट प्रेशर सेंसर के लिए तीन वायर होते हैं। उसमें ECU से सेंसर को रेफरेंस वोल्टेज 5V सप्लाई की जाती है ताकि सेंसर सक्रिय होकर सिग्नल वायर के माध्यम से वोल्टेज उत्पन्न कर सके। दूसरा वायर ग्राउंड के लिए होता है, जो सर्किट को पूरा करता है और ECU के लिए सप्लाई का रिटर्न पाथ बनता है।\r\nसिग्नल वायर केवल ECU तक सिग्नल वोल्टेज पहुँचाने के लिए होता है। लेकिन OBD-2 में ECU सिग्नल वायर को 5 वोल्ट सप्लाई करता है, जो सीरीज में लगे पुल-डाउन रेज़िस्टर से होकर गुजरता है, और इसमें करंट का स्तर बहुत कम होता है। ऐसा इसलिए किया जाता है कि अगर सिग्नल वायर कट हो जाए, तो पूरा 5 वोल्ट बिना किसी खपत के ECU तक पहुँचेगा और ECU "Signal Too High" का DTC दर्ज करेगा। लेकिन जब यह 12 वोल्ट से शॉर्ट हो जाता है, तो यह अधिकतम 5 वोल्ट की सिग्नल रेंज को पार कर जाता है, इसी कारण "Signal Range High" का DTC उत्पन्न होता है।\r\n', '/uploads/1755087309595.pdf', '/uploads/questions/Q8/hindi/L8.mp3', '/uploads/questions/Q8/hindi/Q8.mp3', '2025-09-16 05:58:25', 'सिग्नल वायर बैटरी वोल्टेज से शॉर्ट', 'इनपुट वोल्टेज ग्राउंड से शॉर्ट', 'सिग्नल वायर ग्राउंड से शॉर्ट', 'ग्राउंड वायर ग्राउंड से शॉर्ट', 'A', 'Active'),
	(31, 8, 3, 'ਜੇ ਤੁਹਾਨੂੰ “Boost Pressure Sensor Signal Range High” ਦੀ ਗਲਤੀ ਮਿਲ ਰਹੀ ਹੈ, ਤਾਂ ਸੰਭਾਵਿਤ ਖ਼ਰਾਬੀ ਕੀ ਹੋ ਸਕਦੀ ਹੈ?', '/uploads/questions/Q8/punjabi/M8.mp4', 'ਗਣਨਾ: 1/R= 1/120+1/120, 1/R = 2/120, R= 120/2= 60Ω', 'CAN ਕਮਿਊਨੀਕੇਸ਼ਨ ਦੋਵੇਂ ਸਿਰਿਆਂ \'ਤੇ 120 ਓਮ ਦੇ ਟਰਮੀਨੇਟਿੰਗ ਰੈਜ਼ਿਸਟਰਾਂ ਦੀ ਵਰਤੋਂ ਕਰਦਾ ਹੈ, ਜੋ CAN High ਅਤੇ CAN Low ਦੇ ਵਿਚਕਾਰ ~60 ਓਮ ਦਾ ਪ੍ਰਭਾਵੀ ਪ੍ਰਤੀਰੋਧ ਦਿੰਦਾ ਹੈ।', '/uploads/1755087309595.pdf', '/uploads/punjabi_audio8.mp3', '/uploads/punjabi_answer8.mp3', '2025-09-16 05:58:25', 'ਸਿਗਨਲ ਵਾਇਰ ਬੈਟਰੀ ਵੋਲਟੇਜ਼ ਨਾਲ ਸ਼ਾਰਟ', 'ਇਨਪੁੱਟ ਵੋਲਟੇਜ਼ ਗ੍ਰਾਊਂਡ ਨਾਲ ਸ਼ਾਰਟ', 'ਸਿਗਨਲ ਵਾਇਰ ਗ੍ਰਾਊਂਡ ਨਾਲ ਸ਼ਾਰਟ', 'ਗ੍ਰਾਊਂਡ ਵਾਇਰ ਗ੍ਰਾਊਂਡ ਨਾਲ ਸ਼ਾਰਟ', 'A', 'Active'),
	(32, 8, 4, 'நீங்கள் “Boost Pressure Sensor Signal Range High” எனும் பிழையை பெறுகிறீர்களெனில், சந்தேகிக்கப்படக்கூடிய தப்பான பகுதி என்ன?', '/uploads/questions/Q8/tamil/M8.mp4', 'கணக்கீடு: 1/R= 1/120+1/120, 1/R = 2/120, R= 120/2= 60Ω', 'CAN கம்யூனிகேஷன் இரு முனைகளிலும் 120 ஓம்களின் டெர்மினேட்டிங் ரெசிஸ்டர்களைப் பயன்படுத்துகிறது, இது CAN High மற்றும் CAN Low க்கு இடையே ~60 ஓம்ஸின் பயனுள்ள எதிர்ப்பை அளிக்கிறது.', '/uploads/1755087309595.pdf', '/uploads/tamil_audio8.mp3', '/uploads/tamil_answer8.mp3', '2025-09-16 05:58:25', 'சிக்னல் வயர் பேட்டரி வோல்டேஜுடன் குறுக்கு இணைப்பு (Short)', 'இன்புட் வோல்டேஜ் கிரவுண்டுடன் குறுக்கு இணைப்பு', 'சிக்னல் வயர் கிரவுண்டுடன் குறுக்கு இணைப்பு', 'கிரவுண்ட் வயர் கிரவுண்டுடன் குறுக்கு இணைப்பு', 'A', 'Active'),
	(33, 9, 1, 'The Splendor+ XTEC 2.0 has an Best in Class unbeatable mileage of ______kmpl.', NULL, 'The Splendor+ XTEC 2.0 offers an impressive 73 kmpl mileage, ensuring you go further on less fuel. This unmatched efficiency means fewer fuel stops, making your daily rides more economical and hassle-free. It\'s the perfect choice for those who value both performance and savings.', 'The Splendor+ XTEC 2.0 offers an unbeatable mileage of 73 kmpl, making it one of the most fuel-efficient bikes in its category. This exceptional fuel efficiency means you can travel longer distances on less fuel, saving both time and money. Whether you\'re commuting daily or taking longer rides, the Splendor+ XTEC ensures fewer fuel stops, giving you a smoother, more economical riding experience. It\'s the perfect blend of performance and savings.', NULL, NULL, '/uploads/questions/Q9/english/Q9.mp3', '2025-11-06 07:12:10', '70', '71', '72', '73', 'D', 'Active'),
	(34, 9, 2, 'Splendor+ XTEC 2.0 की  Best in Class में अद्वितीय माइलेज ______kmpl है ।', NULL, 'Splendor+ XTEC 2.0 देता है बेहतरीन 73 kmpl का माइलेज, जिससे आप कम फ्यूल में ज़्यादा दूर तक जा सकते हैं। ये शानदार एफिशिएंसी मतलब कम फ्यूल स्टॉप्स और आपकी रोज़ की सवारी होगी और भी सस्ती और बिना झंझट के। परफॉर्मेंस और सेविंग — दोनों चाहने वालों के लिए ये है एकदम परफेक्ट चॉइस।', 'Splendor+ XTEC 2.0 देता है जबरदस्त 73 kmpl का माइलेज, जिससे ये अपनी कैटेगरी की सबसे फ्यूल-एफिशिएंट बाइक बनती है। इसकी शानदार एफिशिएंसी का मतलब है कम फ्यूल में ज़्यादा दूरी तय करना — समय और पैसे दोनों की बचत। चाहे आप रोज़ाना ऑफिस जा रहे हों या लंबी राइड पर, Splendor+ XTEC देता है कम फ्यूल स्टॉप्स और एक स्मूद, किफायती राइडिंग एक्सपीरियंस। परफॉर्मेंस और सेविंग का ये है परफेक्ट कॉम्बिनेशन।', NULL, NULL, '/uploads/questions/Q9/hindi/Q9.mp3', '2025-11-06 07:12:10', '70', '71', '72', '73', 'D', 'Active'),
	(35, 9, 5, 'Splendor+ XTEC 2.0 मध्ये ______kmpl इतके न हरवू शकणारे  Best in Class मायलेज आहे.', NULL, 'Splendor+ XTEC 2.0 देतो जबरदस्त 73 kmpl मायलेज, ज्यामुळे तुम्ही कमी इंधनात जास्त अंतर सहज गाठू शकता. ही अप्रतिम कार्यक्षमता म्हणजे कमी इंधन भरण्याची गरज, आणि तुमचे दैनंदिन प्रवास अधिक किफायतशीर व सोपे होतात. जे लोक परफॉर्मन्स आणि बचत या दोन्ही गोष्टींचा मुल्य देतात त्यांच्यासाठी हा परिपूर्ण पर्याय आहे.', 'Splendor+ XTEC 2.0 देते जबरदस्त 73 kmpl मायलेज, ज्यामुळे ही आपल्या श्रेणीतली सर्वात इंधन-कार्यक्षम बाईक ठरते. ही अप्रतिम इंधन कार्यक्षमता म्हणजे कमी इंधनात जास्त अंतर पार करता येणे, ज्यामुळे वेळ आणि पैसे दोन्ही वाचतात. तुम्ही रोजच्या प्रवासासाठी असाल किंवा लांब राईडवर, Splendor+ XTEC कमी इंधन भरण्याची गरज देते आणि राईड स्मूथ व अधिक किफायतशीर बनवते. परफॉर्मन्स आणि बचतीचे हे परिपूर्ण मिश्रण आहे.', NULL, NULL, '/uploads/questions/Q9/marathi/Q9.mp3', '2025-11-06 07:12:10', '70', '71', '72', '73', 'D', 'Active'),
	(36, 10, 1, 'What does "Probing" mean in the OPDOC process?', NULL, 'In the OPDOC process, Probing involves asking questions to uncover the customer\'s hidden needs and pain points, ensuring the solution aligns with their actual requirements.', 'In the OPDOC process, Probing refers to the technique of asking targeted questions to gather deeper insights into the customer\'s needs, preferences, and pain points. It helps in identifying the underlying requirements that may not be immediately obvious, ensuring that the solution provided is well-aligned with the customer\'s actual needs. This step is crucial for a thorough Need Analysis to offer tailored solutions.', NULL, NULL, '/uploads/questions/Q10/english/Q10.mp3', '2025-11-06 07:12:10', 'Rapport Building ', 'Closing the deal', 'FABing', 'Need Analysis ', 'D', 'Active'),
	(37, 10, 2, 'OPDOC प्रोसेस में "Probing" का क्या अर्थ है?', NULL, 'OPDOC प्रक्रिया में Probing का मतलब है सवाल पूछकर ग्राहक की छिपी हुई ज़रूरतें और परेशानियों को समझना, ताकि दी जाने वाली समाधान उनके असली आवश्यकताओं के साथ पूरी तरह मेल खा सके।', 'OPDOC प्रक्रिया में Probing का मतलब है ग्राहक की ज़रूरतों, पसंद और परेशानियों को गहराई से समझने के लिए सही और उद्देश्यपूर्ण सवाल पूछने की तकनीक। इससे वे छिपी हुई ज़रूरतें सामने आती हैं जो तुरंत नज़र नहीं आतीं, जिससे दिया गया समाधान ग्राहक की असली आवश्यकताओं के अनुरूप होता है। ये स्टेप एक गहराई वाली Need Analysis के लिए बेहद ज़रूरी है, ताकि हर ग्राहक को उनके मुताबिक समाधान दिया जा सके।', NULL, NULL, '/uploads/questions/Q10/hindi/Q10.mp3', '2025-11-06 07:12:10', 'राप्पोर्ट बिल्डिंग', 'क्लोजिंग ढ डील ', 'FABing', 'आवश्यकता एनालिसिस', 'D', 'Active'),
	(38, 10, 5, 'OPDOC प्रोसेसमध्ये \'प्रोबिंग \' म्हणजे काय?', NULL, 'OPDOC प्रक्रियेत, Probing म्हणजे प्रश्न विचारून ग्राहकाच्या लपलेल्या गरजा आणि अडचणी शोधणे, जेणेकरून दिलेले समाधान त्यांच्या खरी गरजांशी जुळेल याची खात्री करता येईल.', 'OPDOC प्रक्रियेत, Probing म्हणजे ग्राहकाच्या गरजा, प्राधान्ये आणि अडचणी याबद्दल सखोल माहिती मिळवण्यासाठी लक्ष्यित प्रश्न विचारण्याची तंत्र आहे. यामुळे त्या लपलेल्या गरजा समजतात ज्या लगेच दिसत नाहीत, आणि दिलेले समाधान ग्राहकाच्या खरी गरजांशी पूर्णपणे जुळते याची खात्री करता येते. वैयक्तिकृत उपाय सुचवण्यासाठी ही Need Analysis ची महत्वाची पायरी आहे.', NULL, NULL, '/uploads/questions/Q10/marathi/Q10.mp3', '2025-11-06 07:12:10', 'रॅप्पो बिल्डिंग ', 'डील क्लोज करणे ', 'FABing', 'नीड ऍनालिसिस', 'D', 'Active'),
	(39, 11, 1, 'What does a Warm Enquiry mean?', NULL, 'A Warm Enquiry refers to leads with genuine interest, likely to close within 7 days, and are more likely to convert into sales quickly.', 'A Warm Enquiry refers to inquiries from potential customers who are actively interested and are likely to close within 7 days. These leads show genuine intent and have moved beyond initial curiosity, making them more likely to convert into sales quickly.', NULL, NULL, '/uploads/questions/Q11/english/Q11.mp3', '2025-11-06 07:12:10', ' Enquiries likely to close in less than 7 days', 'Enquiries likely to close in 7-14 days', 'Enquiries likely to close in 15 days or more', 'Enquiries with no likelihood of closure', 'B', 'Active'),
	(40, 11, 2, '"वॉर्म एन्क्वॉयरी" का क्या मतलब है?', NULL, 'Warm Enquiry ऐसे लीड्स को कहा जाता है जिनमें ग्राहक की असली दिलचस्पी होती है, जो अगले 7 दिनों में डील क्लोज़ करने की संभावना रखते हैं, और जल्दी से सेल्स में कन्वर्ट होने की ज़्यादा संभावना होती है।', 'Warm Enquiry उन संभावित ग्राहकों की पूछताछ को कहा जाता है जो वास्तव में रुचि रखते हैं और अगले 7 दिनों में डील क्लोज़ करने की संभावना रखते हैं। ऐसे लीड्स केवल शुरुआती जिज्ञासा से आगे बढ़ चुके होते हैं और सच्चे इरादे दिखाते हैं, जिससे इनके जल्दी सेल्स में कन्वर्ट होने की संभावना ज़्यादा होती है।', NULL, NULL, '/uploads/questions/Q11/hindi/Q11.mp3', '2025-11-06 07:12:10', 'एन्क्वॉयरीस  7 दिनों से कम समय में बंद होने की संभावना है', 'एन्क्वॉयरीस 7-14 दिनों में बंद होने की संभावना है', 'एन्क्वॉयरीस 15 दिन या उससे अधिक समय में बंद होने की संभावना है', 'बंद होने की संभावना नहीं वाली एन्क्वॉयरीस ', 'B', 'Active'),
	(41, 11, 5, 'वॉर्म इन्क्वायरी \' म्हणजे काय?', NULL, 'Warm Enquiry म्हणजे अशा लीड्स ज्यांना खरी रुची आहे, जे पुढील 7 दिवसांत डील क्लोज होण्याची शक्यता असते आणि जे लवकरच सेल्समध्ये रूपांतरित होण्याची जास्त संधी असतात', 'Warm Enquiry म्हणजे अशा संभाव्य ग्राहकांकडून येणारी चौकशी जी खऱ्या रुचीने केली जाते आणि पुढील 7 दिवसांत डील क्लोज होण्याची शक्यता असते. हे लीड्स फक्त सुरुवातीच्या जिज्ञासेपलीकडे गेलेले असतात आणि त्यांचे खरे उद्देश दिसून येतो, ज्यामुळे ते लवकरच सेल्समध्ये रूपांतरित होण्याची जास्त शक्यता असते.', NULL, NULL, '/uploads/questions/Q11/marathi/Q11.mp3', '2025-11-06 07:12:10', '7 पेक्षा कमी दिवसात क्लोज होण्याची शक्यता असलेल्या इन्क्वायरीज ', '7-14 दिवसात इन्क्वायरी क्लोज करणे ', '15 दिवस किंवा अधिक मध्ये क्लोज होऊ शकणाऱ्या इन्क्वायरीज ', 'पूर्ण न होणाऱ्या इन्क्वायरी ', 'B', 'Active'),
	(42, 12, 1, 'What is the benefit of Telecospic suspension?', NULL, 'The benefit of Telescopic Suspension is that it provides jerk-free rides, ensuring a smoother and more comfortable experience, especially on rough or uneven roads.', 'The benefit of Telescopic Suspension is that it provides jerk-free rides, offering a smoother and more comfortable experience, particularly on rough or uneven roads. This suspension system absorbs shocks and vibrations effectively, preventing them from reaching the rider. By enhancing stability and reducing discomfort, it ensures better control, handling, and a more enjoyable ride, especially during long journeys or on bumpy terrain.', NULL, NULL, '/uploads/questions/Q12/english/Q12.mp3', '2025-11-06 07:12:10', 'Provides Jerk free rides', 'Provides Convenience', 'Provides comfortable ride', 'Provides Safety', 'C', 'Active'),
	(43, 12, 2, 'टेलीस्कोपिक सस्पेंशन का क्या बेनिफिट  है?', NULL, 'Telescopic Suspension का फायदा यह है कि यह झटकों को कम करके राइड को स्मूद और आरामदायक बनाता है, खासकर खराब या ऊबड़-खाबड़ सड़कों पर।', 'Telescopic Suspension का फायदा यह है कि यह झटकों को प्रभावी ढंग से सोखकर राइड को स्मूद और आरामदायक बनाता है, खासकर ऊबड़-खाबड़ या खराब सड़कों पर। यह सस्पेंशन सिस्टम रोड के शॉक्स और वाइब्रेशन्स को राइडर तक पहुँचने से रोकता है, जिससे स्टेबिलिटी और कंट्रोल बेहतर होता है। नतीजा — लंबी यात्राओं या खराब रास्तों पर भी राइड होती है ज़्यादा कम्फर्टेबल और मज़ेदार।', NULL, NULL, '/uploads/questions/Q12/hindi/Q12.mp3', '2025-11-06 07:12:10', 'जर्क फ्री राइड्स  प्रदान करता है', 'कन्वीनिएंस  प्रदान करता है', 'कम्फर्टेबल राइड प्रदान करता है', 'सेफ्टी  प्रदान करता है', 'C', 'Active'),
	(44, 12, 5, 'टेलिस्कोपिक सस्पेन्शनचे बेनिफिट काय आहे?', NULL, 'Telescopic Suspension चा फायदा असा आहे की हे झटक्यांशिवाय राइड देते, ज्यामुळे प्रवास अधिक गुळगुळीत आणि आरामदायक होतो, विशेषतः खड्ड्यांनी भरलेल्या किंवा असमान रस्त्यावर.', 'Telescopic Suspension चा फायदा असा आहे की हे झटक्यांशिवाय राइड देते, ज्यामुळे प्रवास अधिक गुळगुळीत आणि आरामदायक होतो, विशेषतः खड्ड्यांनी भरलेल्या किंवा असमान रस्त्यावर. हे सस्पेंशन सिस्टम शॉक आणि व्हायब्रेशन्स प्रभावीपणे शोषते, ज्यामुळे ती थेट राइडरपर्यंत पोहोचत नाहीत. स्टेबिलिटी वाढवून आणि अस्वस्थता कमी करून, हे अधिक चांगले कंट्रोल आणि हँडलिंग सुनिश्चित करते, आणि विशेषतः लांब राइड्स किंवा खडबडीत मार्गावर प्रवास अधिक आनंददायी बनवते.', NULL, NULL, '/uploads/questions/Q12/marathi/Q12.mp3', '2025-11-06 07:12:10', 'जर्क फ्री राईड्स देते ', 'कन्व्हिनियन्स देते ', 'कम्फर्टेबल राईड्स देणे ', 'सेफ्टी देते ', 'C', 'Active'),
	(45, 13, 1, 'What specific dimension of the bike is indicated by the red arrow?', '/uploads/questions/Q13/english/M13.jpg', 'Saddle Height is the seat’s height from the ground, impacting comfort and control. Lower heights suit shorter riders, while higher ones provide more legroom for taller riders.', 'Saddle Height is the distance from the seat to the ground, affecting rider comfort and control. A lower height suits shorter riders for better stability, while a higher height offers more legroom for taller riders.', NULL, NULL, '/uploads/questions/Q13/english/Q13.mp3', '2025-11-06 07:12:10', 'Saddle Height', 'Height', 'Ground Clearance', 'Wheelbase', 'A', 'Active'),
	(46, 13, 2, 'बाइक के किस विशेष डाइमेंशन को लाल एरो द्वारा दर्शाया गया है?', '/uploads/questions/Q13/hindi/M13.jpg', 'Saddle Height सीट की ज़मीन से ऊँचाई होती है, जो राइड के कम्फर्ट और कंट्रोल पर असर डालती है। कम ऊँचाई छोटी हाइट वाले राइडर्स के लिए बेहतर होती है, जबकि ज़्यादा ऊँचाई लंबे राइडर्स को ज़्यादा लेगरूम देती है।', 'Saddle Height सीट से ज़मीन तक की दूरी होती है, जो राइडर के कम्फर्ट और कंट्रोल को प्रभावित करती है। कम सैडल हाइट छोटे राइडर्स को बेहतर स्टेबिलिटी देती है, जबकि ज़्यादा हाइट लंबे राइडर्स को अधिक लेगरूम और आराम प्रदान करती है।', NULL, NULL, '/uploads/questions/Q13/hindi/Q13.mp3', '2025-11-06 07:12:10', 'सैडल की ऊँचाई', 'ऊंचाई', 'ग्राउंड क्लीयरेंस', 'व्हीलबेस', 'A', 'Active'),
	(47, 13, 5, 'लाल ऍरो ने बाइकचा कोणता विशिष्ट डायमेन्शन  दर्शविला आहे?', '/uploads/questions/Q13/marathi/M13.jpg', 'Saddle Height म्हणजे सीटची जमिनीपासूनची उंची, जी राइडरच्या आराम आणि कंट्रोलवर परिणाम करते. कमी उंची छोटे राइडर्ससाठी योग्य असते, तर जास्त उंची मोठ्या राइडर्सला अधिक पायासाठी जागा देते.', 'Saddle Height म्हणजे सीटपासून जमिनीपर्यंतचे अंतर, जे राइडरच्या आराम आणि कंट्रोलवर परिणाम करते. कमी उंची छोटे राइडर्ससाठी चांगली स्टेबिलिटी देते, तर जास्त उंची मोठ्या राइडर्सला अधिक पायासाठी जागा आणि आराम प्रदान करते', NULL, NULL, '/uploads/questions/Q13/marathi/Q13.mp3', '2025-11-06 07:12:10', 'सॅडलची   उंची ', 'उंची', ' ग्राउंड क्लियरन्स ', 'व्हीलबेस', 'A', 'Active');

-- Dumping structure for table Tata_Microlearning.regions
CREATE TABLE IF NOT EXISTS `regions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `regions_ibfk_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.regions: ~5 rows (approximately)
INSERT INTO `regions` (`id`, `country_id`, `name`, `status`, `created_at`) VALUES
	(1, 1, 'Central', 'Active', '2025-10-28 12:19:55'),
	(2, 1, 'East', 'Active', '2025-10-24 12:20:48'),
	(3, 1, 'North', 'Active', '2025-10-24 12:20:48'),
	(4, 1, 'South', 'Active', '2025-10-24 12:20:48'),
	(5, 1, 'West', 'Active', '2025-10-24 12:20:48');

-- Dumping structure for table Tata_Microlearning.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.roles: ~4 rows (approximately)
INSERT INTO `roles` (`id`, `name`, `description`, `status`, `created_at`) VALUES
	(1, 'Sales Executive', 'Responsible for sales operations', 'Active', '2025-10-28 12:19:07'),
	(2, 'Training Manager', 'Manages training programs', 'Active', '2025-10-17 08:38:20'),
	(3, 'Regional Manager', 'Manages regional operations', 'Active', '2025-10-17 07:29:55'),
	(4, 'Dealer', 'Dealer representative', 'Active', '2025-10-15 10:16:36');

-- Dumping structure for table Tata_Microlearning.states
CREATE TABLE IF NOT EXISTS `states` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.states: ~17 rows (approximately)
INSERT INTO `states` (`id`, `name`, `status`, `created_at`) VALUES
	(1, 'Delhi', 'Active', '2025-10-27 06:07:53'),
	(2, 'Rajasthan', 'Active', '2025-10-27 06:07:54'),
	(3, 'Madhya Pradesh', 'Active', '2025-10-24 12:20:48'),
	(4, 'West Bengal', 'Active', '2025-10-24 12:20:48'),
	(5, 'Jharkhand', 'Active', '2025-10-24 12:20:48'),
	(6, 'Assam', 'Active', '2025-10-27 06:03:14'),
	(7, 'Uttarakhand', 'Active', '2025-10-24 12:20:48'),
	(8, 'Chandigarh', 'Active', '2025-10-27 06:03:15'),
	(9, 'Uttar Pradesh', 'Active', '2025-10-24 12:20:48'),
	(10, 'Haryana', 'Active', '2025-10-24 12:20:48'),
	(11, 'Tamil Nadu', 'Active', '2025-10-24 12:20:48'),
	(12, 'Karnataka', 'Active', '2025-10-24 12:20:48'),
	(13, 'Kerala', 'Active', '2025-10-24 12:20:48'),
	(14, 'Andhra Pradesh', 'Active', '2025-10-27 06:03:13'),
	(15, 'Orissa', 'Active', '2025-10-24 12:20:48'),
	(16, 'Maharashtra', 'Active', '2025-10-24 12:20:48'),
	(17, 'Gujarat', 'Active', '2025-10-24 12:20:48');

-- Dumping structure for table Tata_Microlearning.test_assignments
CREATE TABLE IF NOT EXISTS `test_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) DEFAULT '0',
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `max_attempts` int DEFAULT '1',
  `passing_score` int DEFAULT '60',
  `shuffle_questions` tinyint(1) DEFAULT '0',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `total_marks` int DEFAULT '100',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `shuffle_options` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `test_assignments_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.test_assignments: ~2 rows (approximately)
INSERT INTO `test_assignments` (`id`, `admin_id`, `name`, `created_at`, `is_completed`, `start_date`, `end_date`, `duration_minutes`, `max_attempts`, `passing_score`, `shuffle_questions`, `status`, `total_marks`, `updated_at`, `shuffle_options`) VALUES
	(1, 1, 'Sample_Assessment', '2025-11-07 05:08:02', 0, '2026-01-15 00:00:00', '2026-02-20 00:00:00', 60, 4, 60, 1, 'Active', 100, '2026-01-30 05:32:59', 1),
	(2, 1, 'Hero_Assessment', '2025-11-07 05:08:51', 0, '2026-01-15 00:00:00', '2026-01-20 00:00:00', 60, 4, 60, 1, 'Inactive', 100, '2026-01-20 04:45:46', 1);

-- Dumping structure for table Tata_Microlearning.user_assignment_completion
CREATE TABLE IF NOT EXISTS `user_assignment_completion` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `assignment_id` int NOT NULL,
  `is_completed` tinyint(1) DEFAULT '0',
  `completed_at` timestamp NULL DEFAULT NULL,
  `attempt` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_assignment_attempt` (`user_id`,`assignment_id`,`attempt`),
  KEY `assignment_id` (`assignment_id`),
  KEY `idx_user_assignment_attempt` (`user_id`,`assignment_id`,`attempt`),
  CONSTRAINT `user_assignment_completion_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_assignment_completion_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.user_assignment_completion: ~1 rows (approximately)
INSERT INTO `user_assignment_completion` (`id`, `user_id`, `assignment_id`, `is_completed`, `completed_at`, `attempt`) VALUES
	(1, 2, 1, 1, '2026-02-03 09:50:12', 1);

-- Dumping structure for table Tata_Microlearning.user_responses
CREATE TABLE IF NOT EXISTS `user_responses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `base_question_id` int NOT NULL,
  `assignment_id` int DEFAULT NULL,
  `status` enum('sure_correct','not_sure_correct','sure_incorrect','not_sure_incorrect') NOT NULL,
  `answer` enum('A','B','C','D') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_sure` tinyint(1) DEFAULT NULL,
  `attempt` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question_attempt` (`user_id`,`base_question_id`,`assignment_id`,`attempt`),
  KEY `user_id` (`user_id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `user_responses_ibfk_2` (`base_question_id`),
  KEY `idx_user_responses_attempt` (`user_id`,`assignment_id`,`attempt`),
  KEY `idx_user_mastered_questions` (`user_id`,`base_question_id`,`status`,`attempt`),
  CONSTRAINT `user_responses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_responses_ibfk_2` FOREIGN KEY (`base_question_id`) REFERENCES `base_questions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_responses_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `test_assignments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.user_responses: ~8 rows (approximately)
INSERT INTO `user_responses` (`id`, `user_id`, `base_question_id`, `assignment_id`, `status`, `answer`, `created_at`, `is_sure`, `attempt`) VALUES
	(1, 2, 1, 1, 'sure_correct', 'B', '2026-02-03 09:50:12', 1, 1),
	(2, 2, 2, 1, 'not_sure_incorrect', 'B', '2026-02-03 09:50:12', 0, 1),
	(3, 2, 3, 1, 'sure_incorrect', 'C', '2026-02-03 09:50:12', 1, 1),
	(4, 2, 4, 1, 'not_sure_incorrect', 'B', '2026-02-03 09:50:12', 0, 1),
	(5, 2, 5, 1, 'sure_incorrect', 'C', '2026-02-03 09:50:12', 1, 1),
	(6, 2, 6, 1, 'not_sure_incorrect', 'D', '2026-02-03 09:50:12', 0, 1),
	(7, 2, 7, 1, 'not_sure_incorrect', 'B', '2026-02-03 09:50:12', 0, 1),
	(8, 2, 8, 1, 'sure_incorrect', 'D', '2026-02-03 09:50:12', 1, 1);

-- Dumping structure for table Tata_Microlearning.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_admin` tinyint(1) DEFAULT '0',
  `role_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `preferred_language_id` int DEFAULT NULL,
  `default_language_id` int DEFAULT NULL,
  `mobile` varchar(20) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `doj` date DEFAULT NULL,
  `dealer_code` varchar(50) DEFAULT NULL,
  `dealer_name` varchar(255) DEFAULT NULL,
  `country_id` int DEFAULT NULL,
  `region_id` int DEFAULT NULL,
  `zone_id` int DEFAULT NULL,
  `state_id` int DEFAULT NULL,
  `city_id` int DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_preferred_language` (`preferred_language_id`),
  KEY `fk_default_language` (`default_language_id`),
  KEY `role_id` (`role_id`),
  KEY `country_id` (`country_id`),
  KEY `region_id` (`region_id`),
  KEY `zone_id` (`zone_id`),
  KEY `state_id` (`state_id`),
  KEY `city_id` (`city_id`),
  CONSTRAINT `fk_default_language` FOREIGN KEY (`default_language_id`) REFERENCES `languages` (`id`),
  CONSTRAINT `fk_preferred_language` FOREIGN KEY (`preferred_language_id`) REFERENCES `languages` (`id`),
  CONSTRAINT `users_ibfk_city` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`),
  CONSTRAINT `users_ibfk_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`),
  CONSTRAINT `users_ibfk_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  CONSTRAINT `users_ibfk_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `users_ibfk_state` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`),
  CONSTRAINT `users_ibfk_zone` FOREIGN KEY (`zone_id`) REFERENCES `zones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.users: ~3 rows (approximately)
INSERT INTO `users` (`id`, `email`, `first_name`, `last_name`, `password`, `is_admin`, `role_id`, `created_at`, `preferred_language_id`, `default_language_id`, `mobile`, `dob`, `doj`, `dealer_code`, `dealer_name`, `country_id`, `region_id`, `zone_id`, `state_id`, `city_id`, `status`) VALUES
	(1, 'admin@admin.com', 'Admin', '1', '$2b$12$24vr9WK4g3VJRlDslopOBuIU5tsgIVNcfEx4jhgaYrcMszO5wqyzS', 1, 2, '2025-10-28 06:49:24', 1, 1, '8920465565', '2025-10-09', '2025-10-26', 'FC000ER', 'ROHAN', 1, 3, 10, 9, 10, 'Active'),
	(2, 'user@user.com', 'User', '1', '$2b$12$Z8oLIMq2Z7YHK.6sn9lUrus24y.cZsTrHnlzgqb1ax4cyrtxO52xm', 0, 4, '2025-10-28 06:54:44', 2, 1, '8920465565', '2025-10-06', '2025-10-31', 'SS33S09', 'Preet', 1, 5, 18, 16, 18, 'Active'),
	(3, 'user@user2.com', 'User', '1', '$2b$12$Z8oLIMq2Z7YHK.6sn9lUrus24y.cZsTrHnlzgqb1ax4cyrtxO52xm', 0, 4, '2025-10-28 06:54:44', 2, 1, '8920465565', '2025-10-06', '2025-10-31', 'SS33S09', 'Preet', 1, 5, 18, 16, 18, 'Active');

-- Dumping structure for table Tata_Microlearning.zones
CREATE TABLE IF NOT EXISTS `zones` (
  `id` int NOT NULL AUTO_INCREMENT,
  `region_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `region_id` (`region_id`),
  CONSTRAINT `zones_ibfk_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table Tata_Microlearning.zones: ~19 rows (approximately)
INSERT INTO `zones` (`id`, `region_id`, `name`, `status`, `created_at`) VALUES
	(1, 1, 'C1', 'Active', '2025-10-28 12:20:51'),
	(2, 1, 'C2', 'Active', '2025-10-24 12:20:48'),
	(3, 1, 'C3', 'Active', '2025-10-24 12:20:48'),
	(4, 1, 'C4', 'Active', '2025-10-24 12:20:48'),
	(5, 2, 'E1', 'Active', '2025-10-24 12:20:48'),
	(6, 2, 'E2', 'Active', '2025-10-24 12:20:48'),
	(7, 2, 'E3', 'Active', '2025-10-24 12:20:48'),
	(8, 3, 'N1', 'Active', '2025-10-24 12:20:48'),
	(9, 3, 'N2', 'Active', '2025-10-24 12:20:48'),
	(10, 3, 'N3', 'Active', '2025-10-24 12:20:48'),
	(11, 3, 'N4', 'Active', '2025-10-24 12:20:48'),
	(12, 4, 'S1', 'Active', '2025-10-24 12:20:48'),
	(13, 4, 'S2', 'Active', '2025-10-24 12:20:48'),
	(14, 4, 'S3', 'Active', '2025-10-24 12:20:48'),
	(15, 4, 'T1', 'Active', '2025-10-24 12:20:48'),
	(16, 2, 'T2', 'Active', '2025-10-24 12:20:48'),
	(17, 5, 'W1', 'Active', '2025-10-24 12:20:48'),
	(18, 5, 'W2', 'Active', '2025-10-24 12:20:48'),
	(19, 5, 'W3', 'Active', '2025-10-24 12:20:48');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
