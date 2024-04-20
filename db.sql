-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           11.1.2-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para faroeste
CREATE DATABASE IF NOT EXISTS `faroeste` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `faroeste`;

-- Copiando estrutura para tabela faroeste.ban_batch
CREATE TABLE IF NOT EXISTS `ban_batch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `perpetrator` varchar(255) DEFAULT NULL,
  `isDeactivated` tinyint(1) NOT NULL DEFAULT 0,
  `expiresAt` timestamp NULL DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- Copiando dados para a tabela faroeste.ban_batch: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.character
CREATE TABLE IF NOT EXISTS `character` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `birthDate` date DEFAULT current_timestamp(),
  `metaData` text DEFAULT '{}',
  `favoriteReserveType` int(11) DEFAULT NULL,
  `deathState` enum('Alive','Incapacitated','Wounded','Dead','Respawning') NOT NULL DEFAULT 'Alive',
  `updatedAt` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `createdAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  KEY `FK_characters_users` (`userId`) USING BTREE,
  KEY `FK_characters_reserve_type` (`favoriteReserveType`),
  CONSTRAINT `FK_character_user` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_characters_reserve_type` FOREIGN KEY (`favoriteReserveType`) REFERENCES `reserve_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Copiando estrutura para tabela faroeste.character_appearance
CREATE TABLE IF NOT EXISTS `character_appearance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `isMale` tinyint(1) DEFAULT 1,
  `expressions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `bodyApparatusId` int(11) DEFAULT 0,
  `bodyApparatusStyleId` int(11) DEFAULT 0,
  `headApparatusId` int(11) DEFAULT 0,
  `teethApparatusStyleId` int(11) DEFAULT 0,
  `eyesApparatusId` int(11) DEFAULT 0,
  `eyesApparatusStyleId` int(11) DEFAULT 0,
  `whistleShape` float DEFAULT 0,
  `whistlePitch` float DEFAULT 0,
  `whistleClarity` float DEFAULT 0,
  `height` tinyint(3) unsigned DEFAULT 180,
  `bodyWeightOufitType` tinyint(3) unsigned DEFAULT 10,
  `bodyKindType` tinyint(3) unsigned DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `charId` (`charId`) USING BTREE,
  CONSTRAINT `FK_character_appearance_character` FOREIGN KEY (`charId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `expressions` CHECK (json_valid(`expressions`))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando estrutura para tabela faroeste.character_appearance_customizable
CREATE TABLE IF NOT EXISTS `character_appearance_customizable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `overridePedModel` varchar(255) DEFAULT NULL,
  `overridePedIsMale` tinyint(1) DEFAULT NULL,
  `equippedOutfitId` int(11) DEFAULT NULL,
  `hairApparatusId` int(11) DEFAULT 0,
  `hairApparatusStyleId` int(11) DEFAULT 0,
  `mustacheApparatusId` int(11) DEFAULT 0,
  `mustacheApparatusStyleId` int(11) DEFAULT 0,
  `weightPercentage` float DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `charId` (`charId`) USING BTREE,
  CONSTRAINT `FK_character_appearance_customizable_character` FOREIGN KEY (`charId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando estrutura para tabela faroeste.character_appearance_overlays
CREATE TABLE IF NOT EXISTS `character_appearance_overlays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `charId` (`charId`) USING BTREE,
  CONSTRAINT `FK_character_appearance_overlays_character` FOREIGN KEY (`charId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `data` CHECK (json_valid(`data`))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando estrutura para tabela faroeste.character_appearance_overlays_customizable
CREATE TABLE IF NOT EXISTS `character_appearance_overlays_customizable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `hasFacialHair` tinyint(1) DEFAULT 0,
  `headHairStyle` int(11) DEFAULT NULL,
  `headHairOpacity` int(11) DEFAULT NULL,
  `foundationColor` int(11) DEFAULT NULL,
  `foundationOpacity` int(11) DEFAULT NULL,
  `lipstickColor` int(11) DEFAULT NULL,
  `lipstickOpacity` int(11) DEFAULT NULL,
  `facePaintColor` int(11) DEFAULT NULL,
  `facePaintOpacity` int(11) DEFAULT NULL,
  `eyeshadowColor` int(11) DEFAULT NULL,
  `eyeshadowOpacity` int(11) DEFAULT NULL,
  `eyelinerColor` int(11) DEFAULT NULL,
  `eyelinerOpacity` int(11) DEFAULT NULL,
  `eyebrowsStyle` int(11) DEFAULT NULL,
  `eyebrowsColor` int(11) DEFAULT NULL,
  `eyebrowsOpacity` int(11) DEFAULT NULL,
  `blusherStyle` int(11) DEFAULT NULL,
  `blusherColor` int(11) DEFAULT NULL,
  `blusherOpacity` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `charId` (`charId`) USING BTREE,
  CONSTRAINT `FK_character_appearance_overlays_customizable_character` FOREIGN KEY (`charId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- Copiando dados para a tabela faroeste.character_appearance_overlays_customizable: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.character_inventory
CREATE TABLE IF NOT EXISTS `character_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `items` longtext DEFAULT '{}',
  `weight` int(11) DEFAULT 30000,
  `slots` int(11) DEFAULT 35,
  `updatedAt` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `createdAt` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_inventories_characters` (`charId`) USING BTREE,
  CONSTRAINT `FK_inventory_character` FOREIGN KEY (`charId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Copiando estrutura para tabela faroeste.character_outfit
CREATE TABLE IF NOT EXISTS `character_outfit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apparels` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  CONSTRAINT `apparels` CHECK (json_valid(`apparels`))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- Copiando dados para a tabela faroeste.character_outfit: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.character_rpg_stats
CREATE TABLE IF NOT EXISTS `character_rpg_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charId` int(11) DEFAULT NULL,
  `statHunger` int(11) NOT NULL DEFAULT 0,
  `statThirst` int(11) NOT NULL DEFAULT 0,
  `statHealth` int(11) NOT NULL DEFAULT 200,
  `statHealthCore` int(11) NOT NULL DEFAULT 100,
  `statStamina` int(11) NOT NULL DEFAULT 200,
  `statStaminaCore` int(11) NOT NULL DEFAULT 100,
  `statDrunk` int(11) NOT NULL DEFAULT 0,
  `statStress` int(11) NOT NULL DEFAULT 0,
  `statDrugs` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `charId` (`charId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando estrutura para tabela faroeste.group
CREATE TABLE IF NOT EXISTS `group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parentId` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `fullName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando dados para a tabela faroeste.group: ~18 rows (aproximadamente)
INSERT INTO `group` (`id`, `parentId`, `name`, `fullName`) VALUES
	(1, NULL, 'staff', NULL),
	(2, 1, 'admin', NULL),
	(3, 2, 'moderator', NULL),
	(4, NULL, 'prime', 'Prime'),
	(5, 4, 'prime_bronze', 'Prime Bronze'),
	(6, 5, 'prime_silver', 'Prime Prata'),
	(7, 6, 'prime_gold', 'Prime Ouro'),
	(8, 7, 'prime_platinum', 'Prime Platina'),
	(9, 8, 'prime_texas', 'Prime Texas'),
	(10, NULL, 'law', NULL),
	(11, 10, 'law_aspirant', 'Aspirant'),
	(12, 11, 'law_offficer', 'Officer'),
	(13, 12, 'law_senior_officer', 'Senior Officer'),
	(14, 13, 'law_trooper', 'Trooper'),
	(15, 14, 'law_sheriff', 'Sheriff'),
	(16, 15, 'law_deputy_sheriff', 'Deputy Sheriff'),
	(17, 16, 'law_assistant_marshal', 'Assistant Marshal'),
	(18, 17, 'law_marshal', 'Marshal');

-- Copiando estrutura para tabela faroeste.group_member
CREATE TABLE IF NOT EXISTS `group_member` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `groupId` int(11) DEFAULT NULL,
  `userId` int(11) NOT NULL,
  `personaId` int(11) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando dados para a tabela faroeste.group_member: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.ox_inventory
CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` varchar(60) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `data` longtext DEFAULT NULL,
  `lastupdated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  UNIQUE KEY `owner` (`owner`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela faroeste.ox_inventory: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.reserve
CREATE TABLE IF NOT EXISTS `reserve` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `typeId` int(11) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `FK_reserve_reserve_type` (`typeId`),
  CONSTRAINT `FK_reserve_reserve_type` FOREIGN KEY (`typeId`) REFERENCES `reserve_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela faroeste.reserve: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.reserve_item
CREATE TABLE IF NOT EXISTS `reserve_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reserveId` int(11) NOT NULL,
  `itemKey` varchar(50) NOT NULL,
  `itemAmount` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reserveId_itemKey` (`reserveId`,`itemKey`),
  KEY `reserveId` (`reserveId`),
  CONSTRAINT `FK_reserve_item_reserve` FOREIGN KEY (`reserveId`) REFERENCES `reserve` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela faroeste.reserve_item: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.reserve_owner
CREATE TABLE IF NOT EXISTS `reserve_owner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reserveId` int(11) NOT NULL,
  `ownerId` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_character_reserve_reserve` (`reserveId`),
  KEY `FK_character_reserve_characters` (`ownerId`) USING BTREE,
  CONSTRAINT `FK_character_reserve_characters` FOREIGN KEY (`ownerId`) REFERENCES `character` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_character_reserve_reserve` FOREIGN KEY (`reserveId`) REFERENCES `reserve` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela faroeste.reserve_owner: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela faroeste.reserve_type
CREATE TABLE IF NOT EXISTS `reserve_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` tinytext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela faroeste.reserve_type: ~5 rows (aproximadamente)
INSERT INTO `reserve_type` (`id`, `code`) VALUES
	(1, 'BANK_BLACKWATER'),
	(2, 'BANK_SAINTDENIS'),
	(3, 'BANK_VALENTINE'),
	(4, 'BANK_RHODES'),
	(5, 'BANK_ARMADILLO');

-- Copiando estrutura para tabela faroeste.user
CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `numCharSlots` int(5) DEFAULT 1,
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Copiando estrutura para tabela faroeste.user_credentials
CREATE TABLE IF NOT EXISTS `user_credentials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `steam` varchar(50) NOT NULL,
  `fivem` varchar(50) DEFAULT NULL,
  `xbl` varchar(50) DEFAULT NULL,
  `license2` varchar(50) DEFAULT NULL,
  `live` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `steam` (`steam`),
  UNIQUE KEY `fivem` (`fivem`),
  UNIQUE KEY `license` (`license`),
  UNIQUE KEY `discord` (`discord`),
  KEY `FK_user_credentials_user` (`userId`),
  CONSTRAINT `FK_user_credentials_user` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
