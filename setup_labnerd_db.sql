-- setup nobuk database for use
DROP DATABASE IF EXISTS nobuk_db;
CREATE DATABASE IF NOT EXISTS nobuk_db;

USE nobuk_db;

-- Clients table
DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `id` INT auto_increment NOT NULL,
  `firstname` VARCHAR(30) NOT NULL,
  `surname` VARCHAR(30) NOT NULL,
  `email` VARCHAR(30) NOT NULL,
  `password` VARCHAR(60) NOT NULL,
  `buying_user` BOOLEAN DEFAULT TRUE,
  `selling_user` BOOLEAN DEFAULT FALSE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`)
);

LOCK TABLES `clients` WRITE;
INSERT INTO `clients` (`firstname`, `surname`, `email`, `password`, `buying_user`, `selling_user`) 
VALUES ("Ibrahim", "Muriuki", "kimothoibrahim@yahoo.com", "$2b$12$d62nuJG2ErEY/0y/AmaBTuMCidzTNkkorSJ.Jho18hWmIBLmhGcU6", TRUE, TRUE);
UNLOCK TABLES;

-- Groups table
DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` INT auto_increment NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NOT NULL,
  `admin_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY (`admin_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE
);

LOCK TABLES `groups` WRITE;
INSERT INTO `groups` (`name`, `description`, `admin_id`) 
VALUES ("Group 1", "First group description", 1), ("Group 2", "Second group description", 1);
UNLOCK TABLES;

-- Members table
DROP TABLE IF EXISTS `members`;
CREATE TABLE `members` (
  `id` INT auto_increment NOT NULL,
  `group_id` INT NOT NULL,
  `client_id` INT NOT NULL,
  `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`client_id`) REFERENCES `clients`(`id`) ON DELETE CASCADE
);

LOCK TABLES `members` WRITE;
INSERT INTO `members` (`group_id`, `client_id`) 
VALUES (1, 1), (2, 1);
UNLOCK TABLES;

-- Payments table
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` INT auto_increment NOT NULL,
  `group_id` INT NOT NULL,
  `member_id` INT NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `status` ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`member_id`) REFERENCES `members`(`id`) ON DELETE CASCADE
);

LOCK TABLES `payments` WRITE;
INSERT INTO `payments` (`group_id`, `member_id`, `amount`, `status`) 
VALUES (1, 1, 100.00, 'PENDING'), (2, 1, 150.00, 'COMPLETED');
UNLOCK TABLES;

-- Payment Links table
DROP TABLE IF EXISTS `payment_links`;
CREATE TABLE `payment_links` (
  `id` INT auto_increment NOT NULL,
  `group_id` INT NOT NULL,
  `link` VARCHAR(255) NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `currency` VARCHAR(10) NOT NULL,
  `notification_email` VARCHAR(100) NOT NULL,
  `link_status` BOOLEAN DEFAULT FALSE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY (`group_id`) REFERENCES `groups`(`id`) ON DELETE CASCADE
);

LOCK TABLES `payment_links` WRITE;
INSERT INTO `payment_links` (`group_id`, `link`, `amount`, `currency`, `notification_email`, `link_status`) 
VALUES (1, "https://payment.link/abc123", 100.00, "KES", "elvisbando@gmail.com", TRUE);
UNLOCK TABLES;

-- Reminders table
DROP TABLE IF EXISTS `reminders`;
CREATE TABLE `reminders` (
  `id` INT auto_increment NOT NULL,
  `payment_id` INT NOT NULL,
  `reminder_time` DATETIME NOT NULL,
  `status` ENUM('SENT', 'PENDING') DEFAULT 'PENDING',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE
);

LOCK TABLES `reminders` WRITE;
INSERT INTO `reminders` (`payment_id`, `reminder_time`, `status`) 
VALUES (1, NOW(), 'PENDING');
UNLOCK TABLES;

-- Transactions table
DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id` INT auto_increment NOT NULL,
  `payment_id` INT NOT NULL,
  `transaction_id` VARCHAR(100) NOT NULL,
  `amount` DECIMAL(10, 2) NOT NULL,
  `transaction_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS',
  PRIMARY KEY(`id`),
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE
);

LOCK TABLES `transactions` WRITE;
INSERT INTO `transactions` (`payment_id`, `transaction_id`, `amount`, `status`) 
VALUES (1, "TX123456789", 100.00, 'SUCCESS');
UNLOCK TABLES;
