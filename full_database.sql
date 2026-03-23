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
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_points`
--

LOCK TABLES `activity_points` WRITE;
/*!40000 ALTER TABLE `activity_points` DISABLE KEYS */;
INSERT INTO `activity_points` VALUES (1,'B24CS001',1,NULL,5,'2026-03-19 23:40:42','Blood Donation Camp - Auto'),(2,'B24CS002',1,NULL,5,'2026-03-19 23:40:42','Blood Donation Camp - Auto'),(3,'B24AIM001',1,NULL,5,'2026-03-19 23:40:42','Blood Donation Camp - Auto'),(4,'B24CS001',2,NULL,5,'2026-03-19 23:40:42','Village Cleanup - Auto'),(5,'B24AIM001',3,NULL,5,'2026-03-19 23:40:42','Coding Workshop - Auto'),(6,'B24CS001',3,NULL,5,'2026-03-19 23:40:42','Coding Workshop - Auto'),(7,'B24CS002',5,1,5,'2026-03-19 23:40:42','Debate Competition Winner'),(8,'B24CS001',NULL,2,20,'2026-03-19 23:40:42','Internship - Self Initiative'),(9,'B24AIM001',NULL,3,20,'2026-03-19 23:40:42','Internship - Self Initiative'),(10,'B24CS002',NULL,4,15,'2026-03-19 23:40:42','Industrial Visit - Self Initiative'),(11,'B24CS001',NULL,NULL,15,'2026-03-19 23:40:42','Previous semester activities'),(12,'B24CS002',NULL,NULL,5,'2026-03-19 23:40:42','Previous semester activities'),(13,'B24AIM001',NULL,NULL,30,'2026-03-19 23:40:42','Previous semester activities'),(14,'B24CS001',NULL,6,5,'2026-03-20 15:45:45','workshop - Verified');
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
INSERT INTO `announcements` VALUES (1,'Welcome to Activity Points System','Track your participation and earn points for graduation eligibility. Complete 100 points before final year!',NULL,NULL,'System Admin','all','2026-03-19 23:40:43'),(2,'Semester Activity Registration Open','All students can now register for club activities and events. Join at least one club to start earning points.',NULL,NULL,'System Admin','all','2026-03-19 23:40:43'),(3,'NSS Blood Donation Camp','Registrations are now open! Please register before April 10th.',1,1,'B24CS001','all','2026-03-19 23:40:43'),(4,'IEEE Hackathon 2026','Get ready for the biggest coding event of the year! Form teams of 3-4 members.',2,4,'B24AIM001','all','2026-03-19 23:40:43'),(5,'Literary Club Meeting','All members are requested to attend the monthly meeting on April 5th at 4 PM.',3,NULL,'B24CS002','all','2026-03-19 23:40:43'),(6,'meeting ','on friday 4pm',8,NULL,'B24CS001','all','2026-03-21 14:05:15');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
INSERT INTO `certificates` VALUES (1,'B24CS002',5,'event','uploads/b24cs002_debate_winner.pdf','2026-03-19 23:40:42','approved',1,5,NULL,'competition_win'),(2,'B24CS001',NULL,'self_initiative','uploads/b24cs001_internship.pdf','2026-03-19 23:40:42','approved',1,20,NULL,'internship'),(3,'B24AIM001',NULL,'self_initiative','uploads/b24aim001_internship.pdf','2026-03-19 23:40:42','approved',2,20,NULL,'internship'),(4,'B24CS002',NULL,'self_initiative','uploads/b24cs002_iv.pdf','2026-03-19 23:40:42','approved',1,15,NULL,'industrial_visit'),(5,'B24AIM001',NULL,'self_initiative','uploads/b24aim001_nptel.pdf','2026-03-19 23:40:42','pending',NULL,0,NULL,'nptel'),(6,'B24CS001',NULL,'event','B24CS001_1773985121_module5_Part1.pdf','2026-03-20 11:08:41','approved',1,5,NULL,'workshop');
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
INSERT INTO `clubs` VALUES (1,'NSS','Social Service',2,'2024-01-15','Active',NULL),(2,'IEEE MACE','Technical',4,'2024-01-15','Active',NULL),(3,'Literary and Debating Club','Cultural',NULL,'2024-01-15','Active',NULL),(4,'Dance Club','Cultural',6,'2024-01-15','Active',NULL),(5,'Sports and Games Association','Sports',7,'2024-01-15','Active',NULL),(6,'SAE MACE','Technical',5,'2024-01-15','Active',NULL),(7,'ISTE MACE','Technical',15,'2024-01-15','Active',NULL),(8,'MACE Film Society','Film',8,'2024-01-15','Active',NULL),(9,'ASME MACE','Technical',5,'2024-01-15','Active',NULL),(10,'MACE NetX Club','Technical',9,'2024-01-15','Active',NULL),(11,'Divaat Club','Arts',10,'2024-01-15','Active',NULL),(12,'MACE MUN','Academic',11,'2024-01-15','Active',NULL),(13,'AISA MACE','Technical',9,'2024-01-15','Active',NULL),(14,'Quiz Club','Academic',12,'2024-01-15','Active',NULL),(15,'Music Club','Cultural',13,'2024-01-15','Active',NULL),(16,'ASCE MACE','Technical',3,'2024-01-15','Active',NULL),(17,'ENCIDE MACE','Technical',9,'2024-01-15','Active',NULL),(18,'ENCON Club','Environmental',4,'2024-01-15','Active',NULL),(19,'Developers Students Club (DSC)','Technical',9,'2024-01-15','Active',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_attendance`
--

LOCK TABLES `event_attendance` WRITE;
/*!40000 ALTER TABLE `event_attendance` DISABLE KEYS */;
INSERT INTO `event_attendance` VALUES (1,1,'B24CS001','present','paid'),(2,1,'B24CS002','present','paid'),(3,1,'B24AIM001','present','paid'),(4,2,'B24CS001','present','paid'),(5,2,'B24CS002','absent','paid'),(6,3,'B24AIM001','present','paid'),(7,3,'B24CS001','present','paid'),(8,5,'B24CS002','present','paid'),(9,5,'B24AIM001','present','paid'),(10,7,'B24CS001','absent','not_paid'),(11,5,'B24CS001','absent','not_paid'),(12,8,'B24CS001','present','not_paid'),(13,11,'B24CS001','NA','paid');
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (1,1,'Blood Donation Camp','2026-04-15','09:00:00','Main Auditorium','Annual blood donation drive',100,5,'approved','B24CS001',0,NULL),(2,1,'Village Cleanup Drive','2026-04-20','07:00:00','Nearby Village','Community service activity',50,5,'approved','B24CS001',0,NULL),(3,2,'Coding Workshop','2026-04-10','14:00:00','Computer Lab 1','Learn Python basics',40,5,'approved','B24AIM001',0,NULL),(4,2,'Hackathon 2026','2026-05-01','09:00:00','Tech Park','24-hour coding competition',80,5,'pending','B24AIM001',0,NULL),(5,3,'Debate Competition','2026-04-25','15:00:00','Seminar Hall','Inter-department debate',60,5,'approved','B24CS002',0,NULL),(6,4,'Dance Fest 2026','2026-05-10','18:00:00','College Grounds','Annual dance competition',100,5,'pending',NULL,0,NULL),(7,14,'General Quiz Competition','2026-04-18','16:00:00','Auditorium','Open quiz for all students',80,5,'approved',NULL,0,NULL),(8,7,'TechSprint','2026-04-01','09:00:00','Seminar Hall 2','Hackathon software and hardware based',50,5,'approved','B24CS001',0,NULL),(9,8,'TechSprint','2026-04-01','09:00:00','Seminar Hall 2','Hackathon software and hardware based',50,5,'pending','B24CS001',0,NULL),(10,8,'Dhrishyam','2026-03-05','09:00:00','Room M01','It is a place where cinemas lovers and directors meet ',30,5,'pending','B24CS001',0,NULL),(11,8,'Dhrishyam 2.0','2026-03-21','09:00:00','Room M01','reloaded',30,5,'approved','B24CS001',20,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (1,'Prof. Joby George','joby.george@mace.ac.in','CS',NULL,'123','HOD+coordinator',NULL),(2,'Dr. Aji Joy','aji.joy@mace.ac.in','EC',NULL,'123','HOD',NULL),(3,'Dr. Elson John','elson.john@mace.ac.in','CE',NULL,'123','faculty',NULL),(4,'Dr. Siny Paul','siny.paul@mace.ac.in','EE',NULL,'123','faculty',NULL),(5,'Dr. Soni Kuriakose','soni.kuriakose@mace.ac.in','ME',NULL,'123','faculty',NULL),(6,'Prof. Nithin Eldho Subash','nithin.subash@mace.ac.in','CE','S4CE','123','faculty',NULL),(7,'Mr. Binu Varghese','binu.varghese@mace.ac.in','ME',NULL,'123','faculty',NULL),(8,'Dr. Reenu George','reenu.george@mace.ac.in','CS','S6CS','123','FA+coordinator',NULL),(9,'Prof. Eldo P Elias','eldo.elias@mace.ac.in','CS','S1CE','123','FA+coordinator',NULL),(10,'Dr. Kurian John','kurian.john@mace.ac.in','ME','S4ME','123','faculty',NULL),(11,'Dr. Deepak Eldho Babu','deepak.babu@mace.ac.in','EC','S4EC','123','faculty',NULL),(12,'Dr. Joby Joseph','joby.joseph@mace.ac.in','CS','S6AIM','123','faculty',NULL),(13,'Dr. Vinod Yeldho Baby','vinod.baby@mace.ac.in','EC',NULL,'123','faculty',NULL),(14,'Dr Test','test@mace.ac.in','CS','S4CS','123','FA',NULL),(15,'Dr Test+club+class','test1@mace.ac.in','CS','S4CS','123','FA+coordinator',NULL),(16,'Dr hello','hello@mace.ac.in','CD','-','faculty123','faculty','faculty_hello_1774177838.jpg'),(17,'js','js@mace.ac.in','ME','-','faculty123','faculty',NULL);
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
INSERT INTO `membership` VALUES (1,'B24CS001',1,'coordinator','2024-02-01','approved'),(2,'B24AIM001',2,'coordinator','2024-02-01','approved'),(3,'B24CS002',3,'coordinator','2024-02-01','approved'),(4,'B24CS001',2,'member','2024-02-15','approved'),(5,'B24CS002',1,'member','2024-02-20','approved'),(6,'B24AIM001',7,'member','2024-03-01','approved'),(7,'B24CS001',8,'coordinator','2024-03-01','approved');
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
INSERT INTO `students` VALUES ('B24AIM001','Priya Sharma','b24aim001@mace.ac.in','9876543212',2,'S4','123',60,NULL),('B24CS001','Arjun Krishna','b24cs001@mace.ac.in','9876543210',1,'S4','123',100,NULL),('B24CS002','Aditya Menon','b24cs002@mace.ac.in','9876543211',1,'S6','123',30,NULL);
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

-- Dump completed on 2026-03-22 17:11:28
