-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: mace_activity_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activity_points`
--

DROP TABLE IF EXISTS `activity_points`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_points` (
  `point_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `certificate_id` int DEFAULT NULL,
  `points` int NOT NULL,
  `date_awarded` datetime DEFAULT CURRENT_TIMESTAMP,
  `description` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`point_id`),
  KEY `student_id` (`student_id`),
  KEY `event_id` (`event_id`),
  KEY `certificate_id` (`certificate_id`),
  CONSTRAINT `activity_points_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`reg_no`),
  CONSTRAINT `activity_points_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`),
  CONSTRAINT `activity_points_ibfk_3` FOREIGN KEY (`certificate_id`) REFERENCES `certificates` (`certificate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_points`
--

LOCK TABLES `activity_points` WRITE;
/*!40000 ALTER TABLE `activity_points` DISABLE KEYS */;
INSERT INTO `activity_points` VALUES (21,'B24CS001',NULL,12,20,'2026-03-24 03:26:12','Self-initiative: internship'),(22,'B24CS001',NULL,11,20,'2026-03-24 03:30:42','Self-initiative: internship'),(23,'B24CS013',NULL,20,5,'2026-03-24 21:23:15','Self-initiative: workshop'),(24,'B24CS013',NULL,21,5,'2026-03-24 21:24:19','Self-initiative: workshop'),(25,'B24CS013',NULL,22,5,'2026-03-24 21:24:51','Event participation: None'),(26,'B24CS013',19,23,5,'2026-03-24 21:25:08','Event participation: None'),(27,'B24CS002',NULL,13,5,'2026-03-24 21:25:32','Event participation: None'),(28,'B24CS002',NULL,14,20,'2026-03-24 21:25:49','Self-initiative: internship'),(29,'B24CS002',NULL,15,5,'2026-03-24 21:25:53','Event participation: None'),(30,'B24CS003',NULL,16,5,'2026-03-24 21:26:07','Event participation: None'),(31,'B24CS003',NULL,17,5,'2026-03-24 21:26:09','Event participation: None'),(32,'B24CS004',NULL,18,5,'2026-03-24 21:26:20','Event participation: None'),(33,'B24CS004',NULL,19,5,'2026-03-24 21:26:22','Event participation: None');
/*!40000 ALTER TABLE `activity_points` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'Administrator','admin@mace.ac.in','123');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `announcement_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `message` text,
  `club_id` int DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `audience` enum('all','students','faculty') DEFAULT 'all',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`announcement_id`),
  KEY `club_id` (`club_id`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`club_id`),
  CONSTRAINT `announcements_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (7,'Password','All students and faculties are required to be notified that they can update their password according to their choice',NULL,NULL,'Administrator','all','2026-03-24 01:29:42'),(8,'End Semester Examination 2026 (S4)','End Semester Examination 2026 for S4 will commence on 20 April 2026',NULL,NULL,'Administrator','all','2026-03-24 01:32:24'),(9,'Class extended','KTU has extended Regular classes for S6 and S8 till 7 April 2026  ',NULL,NULL,'Administrator','all','2026-03-24 01:34:02');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificates` (
  `certificate_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `certificate_type` enum('event','self_initiative') NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `upload_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','approved','rejected','auto_approved') DEFAULT 'pending',
  `verified_by` int DEFAULT NULL,
  `points_awarded` int DEFAULT '0',
  `remarks` text,
  `activity_category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`certificate_id`),
  KEY `student_id` (`student_id`),
  KEY `event_id` (`event_id`),
  KEY `verified_by` (`verified_by`),
  CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`reg_no`),
  CONSTRAINT `certificates_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`),
  CONSTRAINT `certificates_ibfk_3` FOREIGN KEY (`verified_by`) REFERENCES `faculty` (`faculty_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
INSERT INTO `certificates` VALUES (11,'B24CS001',NULL,'self_initiative','certificates/B24CS001_1774299967.png','2026-03-24 02:36:07','approved',36,20,NULL,'internship'),(12,'B24CS001',NULL,'self_initiative','certificates/B24CS001_1774300040.png','2026-03-24 02:37:20','approved',36,20,NULL,'internship'),(13,'B24CS002',NULL,'event','certificates/B24CS002_1774303460.png','2026-03-24 03:34:20','approved',36,5,NULL,'workshop'),(14,'B24CS002',NULL,'self_initiative','certificates/B24CS002_1774303516.png','2026-03-24 03:35:16','approved',36,20,NULL,'internship'),(15,'B24CS002',NULL,'event','certificates/B24CS002_1774303712.png','2026-03-24 03:38:32','approved',36,5,NULL,'workshop'),(16,'B24CS003',NULL,'event','certificates/B24CS003_1774303862.png','2026-03-24 03:41:02','approved',36,5,NULL,'workshop'),(17,'B24CS003',NULL,'event','certificates/B24CS003_1774303919.png','2026-03-24 03:41:59','approved',36,5,NULL,'workshop'),(18,'B24CS004',NULL,'event','certificates/B24CS004_1774304010.png','2026-03-24 03:43:30','approved',36,5,NULL,'workshop'),(19,'B24CS004',NULL,'event','certificates/B24CS004_1774304140.png','2026-03-24 03:45:40','approved',36,5,NULL,'hackathon'),(20,'B24CS013',NULL,'self_initiative','certificates/B24CS013_1774304658.png','2026-03-24 03:54:18','approved',36,5,NULL,'workshop'),(21,'B24CS013',NULL,'self_initiative','certificates/B24CS013_1774304764.png','2026-03-24 03:56:04','approved',36,5,NULL,'workshop'),(22,'B24CS013',NULL,'event','certificates/B24CS013_1774304824.png','2026-03-24 03:57:04','approved',36,5,NULL,'hackathon'),(23,'B24CS013',19,'event','certificates/B24CS013_1774304992.png','2026-03-24 03:59:52','approved',36,5,NULL,'workshop');
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clubs`
--

DROP TABLE IF EXISTS `clubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clubs` (
  `club_id` int NOT NULL AUTO_INCREMENT,
  `club_name` varchar(100) NOT NULL,
  `club_type` varchar(50) DEFAULT NULL,
  `faculty_incharge` int DEFAULT NULL,
  `created_date` date DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `photo` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`club_id`),
  KEY `faculty_incharge` (`faculty_incharge`),
  CONSTRAINT `clubs_ibfk_1` FOREIGN KEY (`faculty_incharge`) REFERENCES `faculty` (`faculty_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clubs`
--

LOCK TABLES `clubs` WRITE;
/*!40000 ALTER TABLE `clubs` DISABLE KEYS */;
INSERT INTO `clubs` VALUES (1,'NSS','Social Service',24,'2024-01-15','Active','clubs/NSS.png'),(2,'IEEE MACE','Technical',25,'2024-01-15','Active','clubs/IEEE.png'),(3,'Literary and Debating Club','Cultural',NULL,'2024-01-15','Active','clubs/Literary.png'),(4,'Dance Club','Cultural',30,'2024-01-15','Active','clubs/Dance.png'),(5,'Sports and Games Association','Sports',31,'2024-01-15','Active','clubs/Sports.png'),(6,'SAE MACE','Technical',34,'2024-01-15','Active','clubs/SAE.png'),(7,'ISTE MACE','Technical',33,'2024-01-15','Active','clubs/ISTE.png'),(8,'MACE Film Society','Film',26,'2024-01-15','Active','clubs/Film.png'),(9,'ASME MACE','Technical',29,'2024-01-15','Active','clubs/ASME.png'),(10,'MACE NetX Club','Technical',NULL,'2024-01-15','Active','clubs/NetX.png'),(11,'Divaat Club','Arts',32,'2024-01-15','Active','clubs/Divaat.png'),(12,'MACE MUN','Academic',35,'2024-01-15','Active','clubs/MUN.png'),(13,'AISA MACE','Technical',NULL,'2024-01-15','Active','clubs/AISA.png'),(14,'Quiz Club','Academic',27,'2024-01-15','Active','clubs/Quiz.png'),(15,'Music Club','Cultural',28,'2024-01-15','Active','clubs/Music.png'),(16,'ASCE MACE','Technical',NULL,'2024-01-15','Active','clubs/ASCE.png'),(17,'ENCIDE MACE','Technical',33,'2024-01-15','Active','clubs/Encide.png'),(18,'ENCON Club','Environmental',NULL,'2024-01-15','Active','clubs/ENCON.png'),(19,'Developers Students Club (DSC)','Technical',33,'2024-01-15','Active','clubs/DSC.png'),(21,'Google Developers Group (GDG)','Technical',36,'2026-03-24','Active','clubs/GDG.png');
/*!40000 ALTER TABLE `clubs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `dept_id` int NOT NULL AUTO_INCREMENT,
  `dept_name` varchar(100) NOT NULL,
  `dept_code` varchar(10) NOT NULL,
  `hod_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'Computer Science and Engineering','CS','Prof. Joby George'),(2,'CSE with Artificial Intelligence','AIM','Prof. Joby George'),(3,'CSE with Data Science','CD','Prof. Joby George'),(4,'Electronics and Communication Engineering','EC','Dr. Aji Joy'),(5,'Civil Engineering','CE','Dr. Elson John'),(6,'Electrical and Electronics Engineering','EE','Dr. Siny Paul'),(7,'Mechanical Engineering','ME','Dr. Soni Kuriakose'),(8,'Computer Applications','MCA','Prof. Biju Skaria'),(9,'Mathematics','Math','Prof. Rani Thomas'),(10,'Science and Humanities','SH','Dr. Arunkumar S');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_attendance`
--

DROP TABLE IF EXISTS `event_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_attendance` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `event_id` int DEFAULT NULL,
  `student_id` varchar(20) DEFAULT NULL,
  `attendance_status` varchar(20) DEFAULT NULL,
  `payment_status` enum('paid','not_paid') DEFAULT 'not_paid',
  PRIMARY KEY (`attendance_id`),
  KEY `event_id` (`event_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `event_attendance_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`),
  CONSTRAINT `event_attendance_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`reg_no`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_attendance`
--

LOCK TABLES `event_attendance` WRITE;
/*!40000 ALTER TABLE `event_attendance` DISABLE KEYS */;
INSERT INTO `event_attendance` VALUES (15,16,'B24CS013','NA','paid'),(16,19,'B24CS004','NA','not_paid'),(17,20,'B24CS004','NA','not_paid'),(18,19,'B24CS007','NA','not_paid'),(19,20,'B24CS007','NA','not_paid'),(20,19,'B24CS001','NA','not_paid'),(21,20,'B24CS001','NA','not_paid'),(22,19,'B24CS002','NA','not_paid'),(23,20,'B24CS002','NA','not_paid'),(24,19,'B24CS005','NA','not_paid'),(25,17,'B24CS005','NA','not_paid'),(26,19,'B24CS013','NA','not_paid'),(27,20,'B24CS013','NA','not_paid');
/*!40000 ALTER TABLE `event_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `event_id` int NOT NULL AUTO_INCREMENT,
  `club_id` int DEFAULT NULL,
  `event_name` varchar(150) NOT NULL,
  `event_date` date DEFAULT NULL,
  `event_time` time DEFAULT NULL,
  `location` varchar(200) DEFAULT NULL,
  `description` text,
  `max_participants` int DEFAULT NULL,
  `points` int DEFAULT '0',
  `status` enum('pending','approved','rejected','completed') DEFAULT 'pending',
  `created_by` varchar(20) DEFAULT NULL,
  `reg_fee` int DEFAULT '0',
  `photo` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `club_id` (`club_id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`club_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (13,7,'NLP Workshop','2026-03-01','13:00:00','Seminar Hall 3 ',' NLP Workshop organized as part of  Takshak\'24 by Computer Science Engineering Department in collaboration with ISTE MACE SC at Mar Athanasius College of Engineering! Led by Dr. Shailesh Sivan, Assistant Professor at CUSAT, this workshop is designed for all skill levels, ensuring everyone gains a deeper understanding of how machines process human language.',50,5,'approved','B24CS013',0,'events/Screenshot 2026-03-24 041053.png'),(14,7,'TECHNOVA - HackForge','2026-03-10','17:30:00','MACE Kothamangalam','A Hackathon Bootcamp & Mini Hackathon\r\n\r\nNew to hackathons? Start here.\r\nISTE MACE presents a completely beginner-friendly 3-day bootcamp to turn your ideas into working projects. No prior experience required.',50,5,'approved','B24CS013',150,'events/Screenshot 2026-03-24 041950.png'),(15,7,'Nav Kerala Hackfest','2026-03-29','09:00:00','MACE Kothamangalam','Talent deserves to be showcased, and here comes your stage! \r\n\r\nNav Kerala Global Startup Summit presents an open hackathon at Mar Athanasius College of Engineering, Kothamangalam, Kerala -\r\nNav Kerala Hackfest',150,5,'approved','B24CS013',150,'events/Screenshot 2026-03-24 042253.png'),(16,7,'TECHNOVA - CTRL+ALT+ELITE','2026-03-15','17:30:00','online','Ready to prove you’ve got the fastest fingers in the room?\r\n \r\n ISTE MACE proudly presents CTRL+ALT+ELITE  — an exciting online typing challenge where speed meets skill! ',100,5,'approved','B24CS013',30,'events/Screenshot 2026-03-24 042528.png'),(17,7,'DECODE the hackathon','2026-03-30','08:30:00','L212','Welcome to DECODE a beginner friendly guide to hackathons presented by Encide MACE.\r\nThis event is specially designed for first-timers yet curious learners and anyone who has the urge to explore the technical world.',100,5,'approved','B24CS013',0,'events/event_7_1774307867.png'),(19,21,'Zero to Hello Cloud AI','2026-03-25','19:00:00','Online','Unlock the Power of Cloud & AI !\r\n\r\n Hello to Cloud AI : Online session\r\n\r\nStep into the future with Google Cloud Platform (GCP) and Gemini AI — your ultimate tools for smarter projects, coding, and innovation. \r\n',100,5,'approved','B24CS013',0,'events/ZerotoHello.png'),(20,21,'Lumora','2026-03-26','09:00:00','Indoor Auditorium','\" Design is the bridge between technology and art\"\r\n\r\nGet ready to turn your ideas into digital masterpieces! We\'re thrilled to announce that LÚMORA 2026 - The Light of Design the ultimate UI/UX hackathon, is happening on January 31st and February 1st at Mar Athanasius College of Engineering! ',150,5,'approved','B24CS013',0,'events/event_21_1774318184.png');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `faculty_id` int NOT NULL AUTO_INCREMENT,
  `faculty_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `class_incharge` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) DEFAULT NULL,
  `photo` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`faculty_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (18,'Prof. Joby George','joby.george@mace.ac.in','Computer Science and Engineering','-','123','HOD','faculty/Prof. Joby George.png'),(19,'Dr. Aji Joy','aji.joy@mace.ac.in','Electronics and Communication Engineering','-','123','HOD','faculty/Dr. Aji Joy.png'),(20,'Dr. Elson John','elson.john@mace.ac.in','Civil Engineering','-','123','HOD','faculty/DR. Elson John.png'),(21,'Dr. Siny Paul','siny.paul@mace.ac.in','Electrical and Electronics Engineering','-','123','HOD','faculty/Dr. Siny Paul.png'),(22,'Dr. Soni Kuriakose','soni.kuriakose@mace.ac.in','Mechanical Engineering','-','123','HOD','faculty/Dr. Soni Kuriakose.png'),(24,'Prof. Bybin Paul','bybin.paul@mace.ac.in','CE','-','123','coordinator','faculty/faculty_bybin.paul_1774292496.png'),(25,'Prof. Neethu Salim','neethu.salim@mace.ac.in','SH','-','123','coordinator','faculty/faculty_neethu.salim_1774292648.png'),(26,'Dr. Reenu George','reenu.george@mace.ac.in','EE','-','123','coordinator','faculty/faculty_reenu.george_1774292807.png'),(27,'Dr. Joby Joseph','joby.joseph@mace.ac.in','ME','-','123','coordinator','faculty/faculty_joby.joseph_1774292921.png'),(28,'Dr. Vinod Yeldho Baby','vinod.baby@mace.ac.in','ME','-','123','coordinator','faculty/faculty_vinod.baby_1774293021.png'),(29,'Dr. Bobin Cherian Jos','bobin.jos@mace.ac.in','ME','-','123','coordinator','faculty/faculty_bobin.jos_1774294435.png'),(30,'Dr. Aby Thomas','aby.thomas@mace.ac.in','EC','-','123','coordinator','faculty/faculty_aby.thomas_1774294525.png'),(31,'Prof. Vinod Kunjappan','vinod.kunjappan@mace.ac.in','CE','-','123','coordinator','faculty/faculty_vinod.kunjappan_1774294669.png'),(32,'Prof. Nithin Eldho Subash','nithin.subash@mace.ac.in','ME','-','123','coordinator','faculty/faculty_nithin.subash_1774294767.png'),(33,'Prof. Eldo P Elias','eldo.elias@mace.ac.in','CS','S2CS','123','FA+coordinator','faculty/faculty_eldo.elias_1774294877.png'),(34,'Dr. Biju Cherian','biju.cherian@mace.ac.in','ME','-','123','coordinator','faculty/faculty_biju.cherian_1774294978.png'),(35,'Dr. Deepak Eldho Babu','deepak.babu@mace.ac.in','ME','-','123','coordinator','faculty/faculty_deepak.babu_1774295081.png'),(36,'Prof Basil Joy','basil.joy@mace.ac.in','CS','S4CS','123','FA+coordinator','faculty/faculty_basil.joy_1774295732.png');
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `membership`
--

DROP TABLE IF EXISTS `membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `membership` (
  `membership_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) DEFAULT NULL,
  `club_id` int DEFAULT NULL,
  `role` enum('member','coordinator') DEFAULT 'member',
  `join_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  PRIMARY KEY (`membership_id`),
  UNIQUE KEY `unique_membership` (`student_id`,`club_id`),
  KEY `club_id` (`club_id`),
  CONSTRAINT `membership_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`reg_no`),
  CONSTRAINT `membership_ibfk_2` FOREIGN KEY (`club_id`) REFERENCES `clubs` (`club_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `membership`
--

LOCK TABLES `membership` WRITE;
/*!40000 ALTER TABLE `membership` DISABLE KEYS */;
INSERT INTO `membership` VALUES (12,'B24CS003',2,'member','2026-03-24','approved'),(13,'B24CS003',7,'member','2026-03-24','approved'),(14,'B24CS003',1,'member','2026-03-24','approved'),(15,'B24CS001',1,'member','2026-03-24','approved'),(16,'B24CS001',7,'member','2026-03-24','approved'),(17,'B24CS001',12,'member','2026-03-24','approved'),(18,'B24CS002',19,'member','2026-03-24','approved'),(19,'B24CS002',17,'member','2026-03-24','approved'),(20,'B24CS002',7,'member','2026-03-24','approved'),(21,'B24CS013',19,'member','2026-03-24','approved'),(22,'B24CS013',17,'member','2026-03-24','approved'),(23,'B24CS013',7,'coordinator','2026-03-24','approved'),(24,'B24CS013',21,'coordinator','2026-03-24','approved'),(25,'B24CS004',1,'member','2026-03-24','pending'),(26,'B24CS004',21,'member','2026-03-24','pending'),(27,'B24CS004',7,'member','2026-03-24','pending'),(28,'B24CS004',15,'member','2026-03-24','pending'),(29,'B24CS007',21,'member','2026-03-24','pending'),(30,'B24CS007',19,'member','2026-03-24','pending'),(31,'B24CS007',17,'member','2026-03-24','pending'),(32,'B24CS007',7,'member','2026-03-24','pending'),(33,'B24CS002',21,'member','2026-03-24','pending');
/*!40000 ALTER TABLE `membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `reg_no` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `dept_id` int DEFAULT NULL,
  `semester` varchar(5) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `total_points` int DEFAULT '0',
  `photo` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`reg_no`),
  UNIQUE KEY `email` (`email`),
  KEY `dept_id` (`dept_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `departments` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('B24CS001','Aayisha Muhammed','b24cs001@mace.ac.in','9723654781',1,'S4','123',40,'students/Aayisha.jpg'),('B24CS002','Abhinav Vinod','b24cs002@mace.ac.in','9728925673',1,'S4','123',30,'students/Abhinav.png'),('B24CS003','Adarsh Prasad','b24cs003@mace.ac.in','9728162873',1,'S4','123',10,'students/Adharsh.png'),('B24CS004','Aditi M','b24cs004@mace.ac.in','09742948267',1,'S4','123',10,'students/student_B24CS004_1774298192.png'),('B24CS005','Akash Mathew','b24cs005@mace.ac.in','09742948267',1,'S4','123',0,'students/student_B24CS005_1774298587.png'),('B24CS007','Aleena Marie Thampi','b24cs007@mace.ac.in','9567290356',1,'S4','123',0,'students/student_B24CS007_1774298797.png'),('B24CS008','Alfi Vadakkan','b24cs008@mace.ac.in','9529103547',1,'S4','123',0,'students/student_B24CS008_1774299057.png'),('B24CS010','Alna Biju Gregory','b24cs010@mace.ac.in','09742948267',1,'S4','123',0,'students/student_B24CS010_1774299196.png'),('B24CS011','Amit R','b24cs011@mace.ac.in','09742948267',1,'S4','123',0,'students/student_B24CS011_1774299274.png'),('B24CS012','Anjana A S','b24cs012@mace.ac.in','09742948267',1,'S4','123',0,'students/student_B24CS012_1774299376.png'),('B24CS013','Shincina Shinto','b24cs013@mace.ac.in','9745960340',1,'S4','123',20,'students/student_B24CS013_1774304516.png');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-24 23:34:32
