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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_points`
--

LOCK TABLES `activity_points` WRITE;
/*!40000 ALTER TABLE `activity_points` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clubs`
--

LOCK TABLES `clubs` WRITE;
/*!40000 ALTER TABLE `clubs` DISABLE KEYS */;
INSERT INTO `clubs` VALUES (1,'NSS','Social Service',NULL,'2024-01-15','Active',NULL),(2,'IEEE MACE','Technical',NULL,'2024-01-15','Active',NULL),(3,'Literary and Debating Club','Cultural',NULL,'2024-01-15','Active',NULL),(4,'Dance Club','Cultural',NULL,'2024-01-15','Active',NULL),(5,'Sports and Games Association','Sports',NULL,'2024-01-15','Active',NULL),(6,'SAE MACE','Technical',NULL,'2024-01-15','Active',NULL),(7,'ISTE MACE','Technical',NULL,'2024-01-15','Active',NULL),(8,'MACE Film Society','Film',NULL,'2024-01-15','Active',NULL),(9,'ASME MACE','Technical',NULL,'2024-01-15','Active',NULL),(10,'MACE NetX Club','Technical',NULL,'2024-01-15','Active',NULL),(11,'Divaat Club','Arts',NULL,'2024-01-15','Active',NULL),(12,'MACE MUN','Academic',NULL,'2024-01-15','Active',NULL),(13,'AISA MACE','Technical',NULL,'2024-01-15','Active',NULL),(14,'Quiz Club','Academic',NULL,'2024-01-15','Active',NULL),(15,'Music Club','Cultural',NULL,'2024-01-15','Active',NULL),(16,'ASCE MACE','Technical',NULL,'2024-01-15','Active',NULL),(17,'ENCIDE MACE','Technical',NULL,'2024-01-15','Active',NULL),(18,'ENCON Club','Environmental',NULL,'2024-01-15','Active',NULL),(19,'Developers Students Club (DSC)','Technical',NULL,'2024-01-15','Active',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_attendance`
--

LOCK TABLES `event_attendance` WRITE;
/*!40000 ALTER TABLE `event_attendance` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (18,'Prof. Joby George','joby.george@mace.ac.in','Computer Science and Engineering',NULL,'123','HOD',NULL),(19,'Dr. Aji Joy','aji.joy@mace.ac.in','Electronics and Communication Engineering',NULL,'123','HOD',NULL),(20,'Dr. Elson John','elson.john@mace.ac.in','Civil Engineering',NULL,'123','HOD',NULL),(21,'Dr. Siny Paul','siny.paul@mace.ac.in','Electrical and Electronics Engineering',NULL,'123','HOD',NULL),(22,'Dr. Soni Kuriakose','soni.kuriakose@mace.ac.in','Mechanical Engineering',NULL,'123','HOD',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `membership`
--

LOCK TABLES `membership` WRITE;
/*!40000 ALTER TABLE `membership` DISABLE KEYS */;
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

-- Dump completed on 2026-03-23 22:24:46
