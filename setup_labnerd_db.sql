-- setup labnerd database for use
DROP DATABASE IF EXISTS labnerd_db;
CREATE DATABASE IF NOT EXISTS labnerd_db;

USE labnerd_db;

DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `id` INT auto_increment NOT NULL,
  `firstname` varchar(30) NOT NULL,
  `surname` varchar(30) NOT NULL,
  `email` varchar(30) NOT NULL,
  `password` varchar(60) NOT NULL,
  `buying_user` BOOLEAN DEFAULT TRUE,
  `selling_user` BOOLEAN DEFAULT FALSE,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`)
);

LOCK TABLES `clients` WRITE;
INSERT INTO `clients` (`firstname`, `surname`, `email`, `password`, `buying_user`, `selling_user`) VALUES ("Ibrahim", "Muriuki", "kimothoibrahim@yahoo.com", "$2b$12$d62nuJG2ErEY/0y/AmaBTuMCidzTNkkorSJ.Jho18hWmIBLmhGcU6", TRUE, TRUE);
UNLOCK TABLES;

DROP TABLE IF EXISTS `instruments`;
CREATE TABLE `instruments` (
  `id` INT auto_increment,
  `name` VARCHAR(60) NOT NULL,
  `price_per_day` INT NOT NULL,
  `price_per_week` INT,
  `price_per_sample` INT NOT NULL,
  `category_id` INT NOT NULL,
  `client_id` INT NOT NULL,
  `description` varchar(1024) DEFAULT NULL,
  `location` varchar(1024) NOT NULL,
  `instrument_image` VARCHAR(60) DEFAULT "default.png",
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY(`client_id`) REFERENCES `clients` (`id`)
);

LOCK TABLES `instruments` WRITE;
INSERT INTO `instruments` (`name`, `price_per_day`, `price_per_sample`, `category_id`, `client_id`, `description`, `location`) VALUES ("AAS", 2300, 275, 1, 1, "Does elemental analysis", "University of Nairobi - Nairobi"),  ("ICP-AES", 3500, 320, 1, 1, "Does trace element analysis", "Kenyatta University - Ruiru"),  ("HPLC", 1800, 145, 3, 1, "Does chromatographic work", "Analabs - Mombasa Road"),  ("SEM", 3800, 400, 2, 1, "Does microscopy on varied elemets", "SGS - Mombasa"),  ("FTIR", 2800, 240, 1, 1, "Does desicive qualitative determiations on organic elements", "USIU-Africa - Nairobi");
UNLOCK TABLES;


DROP TABLE IF EXISTS `sales`;
CREATE TABLE `sales` (
  `id` INT auto_increment,
  `instument_id` INT NOT NULL,
  `buying_clients_id` INT NOT NULL,
  `selling_clients_id` INT NOT NULL,
  `order_length` INT DEFAULT 1,
  `sample_quantity` INT DEFAULT 1,
  `sale_value` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`),
  FOREIGN KEY(`instument_id`) REFERENCES `instruments` (`id`),
  FOREIGN KEY(`buying_clients_id`) REFERENCES `clients` (`id`),
  FOREIGN KEY(`selling_clients_id`) REFERENCES `instruments` (`client_id`)
);

LOCK TABLES `sales` WRITE;
INSERT INTO `sales`(`instument_id`, `buying_clients_id`, `selling_clients_id`, `order_length`, `sample_quantity`, `sale_value`) VALUES (1, 1, 1, 0, 1, 275);
UNLOCK TABLES;

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`(
  `id` INT auto_increment,
  `name` varchar(20) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY(`id`)
);

LOCK TABLES `categories` WRITE;
INSERT INTO `categories` (`name`) VALUES ("chromatography"), ("spectroscopy"), ("microscopy"), ("other");
UNLOCK TABLES;
