-- =============================================================================
-- Nova IMS — Peer-to-Peer Marketplace (Storing and Retrieving Data Project)
-- =============================================================================
-- Team:
--  - Afonso Maia       (20250464)
--  - Francisco Graça   (20250471)
--  - Maria Pimentel    (20250466)
--  - Renato Scotto     (20250420)
--  - Rodrigo Gonçalves (20250529)
--
-- Database: lx_buy_sell
-- Engine: MySQL InnoDB
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1) Reset and Create Database
-- ---------------------------------------------------------------------------
DROP DATABASE IF EXISTS lx_buy_sell;
CREATE DATABASE IF NOT EXISTS lx_buy_sell;
USE lx_buy_sell;

-- ---------------------------------------------------------------------------
-- 2) Core Tables
-- ---------------------------------------------------------------------------

-- Table 1: STUDENT
CREATE TABLE IF NOT EXISTS `STUDENT` (
  `STUDENT_ID`        CHAR(8)      NOT NULL,
  `FIRST_NAME`        VARCHAR(20)  NOT NULL,
  `LAST_NAME`         VARCHAR(20)  NOT NULL,
  `EMAIL`             VARCHAR(50)  DEFAULT NULL,
  `PHONE`             VARCHAR(16)  NOT NULL,
  `REGISTRATION_DATE` DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `STATUS`            ENUM('ACTIVE', 'INACTIVE', 'BANNED') NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (`STUDENT_ID`),
  CONSTRAINT `UQ_STUDENT_EMAIL` UNIQUE (`EMAIL`),
  CONSTRAINT `UQ_STUDENT_PHONE` UNIQUE (`PHONE`)
) ENGINE = InnoDB;

-- Table 2: CATEGORY
CREATE TABLE IF NOT EXISTS `CATEGORY` (
  `CATEGORY_ID` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `NAME`        ENUM('Kitchenware','Appliance','Storage','Technology','Cleaning','Other') NOT NULL,
  `DESCRIPTION` VARCHAR(200) DEFAULT NULL,
  PRIMARY KEY (`CATEGORY_ID`)
) ENGINE = InnoDB;

-- Table 3: LISTING
CREATE TABLE IF NOT EXISTS `LISTING` (
  `LISTING_ID`   SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `SELLER_ID`    CHAR(8)           NOT NULL,
  `CATEGORY_ID`  TINYINT UNSIGNED  NOT NULL,

  `NAME`         VARCHAR(50)       NOT NULL,
  `DESCRIPTION`  TEXT,
  `CONDITION`    ENUM('LIKE_NEW', 'GOOD', 'USED', 'DAMAGED') NOT NULL,
  `ASKING_PRICE` DECIMAL(6,2)      NOT NULL,

  `CREATED_AT`   DATETIME          DEFAULT CURRENT_TIMESTAMP,
  `STATUS`       ENUM('ACTIVE', 'RESERVED', 'SOLD', 'DELETED') NOT NULL DEFAULT 'ACTIVE',

  PRIMARY KEY (`LISTING_ID`),

  CONSTRAINT `FK_LISTING_SELLER`
    FOREIGN KEY (`SELLER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`)
    ON DELETE CASCADE,

  CONSTRAINT `FK_LISTING_CAT`
    FOREIGN KEY (`CATEGORY_ID`) REFERENCES `CATEGORY`(`CATEGORY_ID`),

  CONSTRAINT `CHK_LISTING_PRICE`
    CHECK (`ASKING_PRICE` >= 0)
) ENGINE = InnoDB;

-- Table 4: LISTING_IMAGE
CREATE TABLE IF NOT EXISTS `LISTING_IMAGE` (
  `IMAGE_ID`      INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `LISTING_ID`    SMALLINT UNSIGNED NOT NULL,
  `IMAGE_URL`     VARCHAR(255)      NOT NULL,
  `IS_MAIN_PHOTO` BOOLEAN           NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`IMAGE_ID`),
  CONSTRAINT `FK_IMAGE_LISTING`
    FOREIGN KEY (`LISTING_ID`) REFERENCES `LISTING`(`LISTING_ID`)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- Table 5: WISHLIST
CREATE TABLE IF NOT EXISTS `WISHLIST` (
  `WISHLIST_ID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `STUDENT_ID`  CHAR(8)           NOT NULL,
  `LISTING_ID`  SMALLINT UNSIGNED NOT NULL,
  `ADDED_AT`    DATETIME          DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`WISHLIST_ID`),
  CONSTRAINT `FK_WISH_STUDENT`
    FOREIGN KEY (`STUDENT_ID`) REFERENCES `STUDENT`(`STUDENT_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_WISH_LISTING`
    FOREIGN KEY (`LISTING_ID`) REFERENCES `LISTING`(`LISTING_ID`) ON DELETE CASCADE,
  CONSTRAINT `UQ_WISH_ITEM`
    UNIQUE (`STUDENT_ID`, `LISTING_ID`)
) ENGINE = InnoDB;

-- Table 6: TRADE
CREATE TABLE IF NOT EXISTS `TRADE` (
  `TRADE_ID`       SMALLINT          NOT NULL AUTO_INCREMENT,
  `LISTING_ID`     SMALLINT UNSIGNED NOT NULL,
  `BUYER_ID`       CHAR(8)           NOT NULL,
  `SELLER_ID`      CHAR(8)           NOT NULL,

  `AGREED_PRICE`   DECIMAL(6,2)      NOT NULL,
  `PAYMENT_METHOD` ENUM('CASH', 'MBWAY', 'REVOLUT') NOT NULL DEFAULT 'MBWAY',

  `CREATED_AT`     DATETIME          DEFAULT CURRENT_TIMESTAMP,
  `COMPLETED_AT`   DATETIME          DEFAULT NULL,

  `STATUS`         ENUM('PENDING_MEETUP', 'COMPLETED', 'CANCELLED', 'SUSPENDED')
                   NOT NULL DEFAULT 'PENDING_MEETUP',

  PRIMARY KEY (`TRADE_ID`),

  CONSTRAINT `FK_TRADE_LISTING`
    FOREIGN KEY (`LISTING_ID`) REFERENCES `LISTING`(`LISTING_ID`),

  CONSTRAINT `FK_TRADE_BUYER`
    FOREIGN KEY (`BUYER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `FK_TRADE_SELLER`
    FOREIGN KEY (`SELLER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `CHK_SELF_DEAL`
    CHECK (`BUYER_ID` <> `SELLER_ID`),

  CONSTRAINT `UQ_TRADE_LISTING`
    UNIQUE (`LISTING_ID`)
) ENGINE = InnoDB;

-- Table 7: MESSAGE
CREATE TABLE IF NOT EXISTS `MESSAGE` (
  `MESSAGE_ID`      BIGINT           NOT NULL AUTO_INCREMENT,
  `SENDER_ID`       CHAR(8)          NOT NULL,
  `RECEIVER_ID`     CHAR(8)          NOT NULL,
  `LISTING_ID`      SMALLINT UNSIGNED NOT NULL,

  `MESSAGE_TEXT`    TEXT             NOT NULL,
  `SENT_AT`         DATETIME         DEFAULT CURRENT_TIMESTAMP,
  `IS_READ`         BOOLEAN          DEFAULT FALSE,

  PRIMARY KEY (`MESSAGE_ID`),

  CONSTRAINT `FK_MSG_SENDER`
    FOREIGN KEY (`SENDER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `FK_MSG_RECEIVER`
    FOREIGN KEY (`RECEIVER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `FK_MSG_LISTING`
    FOREIGN KEY (`LISTING_ID`) REFERENCES `LISTING`(`LISTING_ID`)
) ENGINE = InnoDB;

-- Table 8: USER_REVIEW
CREATE TABLE IF NOT EXISTS `USER_REVIEW` (
  `REVIEW_ID`      SMALLINT          NOT NULL AUTO_INCREMENT,
  `TRADE_ID`       SMALLINT          NOT NULL,
  `REVIEWER_ID`    CHAR(8)           NOT NULL,
  `TARGET_USER_ID` CHAR(8)           NOT NULL,

  `RATING_TYPE`    ENUM('AS_BUYER', 'AS_SELLER') NOT NULL,
  `SCORE`          TINYINT           NOT NULL,
  `COMMENT`        TEXT,
  `CREATED_AT`     DATETIME          DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`REVIEW_ID`),

  CONSTRAINT `FK_REVIEW_TRADE`
    FOREIGN KEY (`TRADE_ID`) REFERENCES `TRADE`(`TRADE_ID`),

  CONSTRAINT `FK_REVIEW_WRITER`
    FOREIGN KEY (`REVIEWER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `FK_REVIEW_TARGET`
    FOREIGN KEY (`TARGET_USER_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `CHK_REVIEW_SCORE`
    CHECK (`SCORE` BETWEEN 1 AND 5),

  CONSTRAINT `UQ_REVIEW_PER_TRADE_ROLE`
    UNIQUE (`TRADE_ID`, `REVIEWER_ID`, `RATING_TYPE`)
) ENGINE = InnoDB;

-- Table 9: REPORT
CREATE TABLE IF NOT EXISTS `REPORT` (
  `REPORT_ID`           SMALLINT NOT NULL AUTO_INCREMENT,
  `REPORTER_STUDENT_ID` CHAR(8)  NOT NULL,
  `REPORTED_LISTING_ID` SMALLINT UNSIGNED DEFAULT NULL,
  `REPORTED_STUDENT_ID` CHAR(8)  DEFAULT NULL,

  `REASON`      ENUM('SCAM', 'NO_SHOW', 'INAPPROPRIATE', 'DAMAGED_ITEM', 'OTHER') NOT NULL,
  `DESCRIPTION` TEXT,
  `REPORT_DATE` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `STATUS`      ENUM('OPEN', 'REVIEWING', 'RESOLVED', 'DISMISSED') NOT NULL DEFAULT 'OPEN',

  PRIMARY KEY (`REPORT_ID`),

  CONSTRAINT `FK_RPT_REPORTER`
    FOREIGN KEY (`REPORTER_STUDENT_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `FK_RPT_LISTING`
    FOREIGN KEY (`REPORTED_LISTING_ID`) REFERENCES `LISTING`(`LISTING_ID`),

  CONSTRAINT `FK_RPT_TARGET_USER`
    FOREIGN KEY (`REPORTED_STUDENT_ID`) REFERENCES `STUDENT`(`STUDENT_ID`),

  CONSTRAINT `CHK_REPORT_TARGET`
    CHECK (`REPORTED_LISTING_ID` IS NOT NULL OR `REPORTED_STUDENT_ID` IS NOT NULL),

  CONSTRAINT `CHK_REPORTER_NOT_TARGET`
    CHECK (`REPORTER_STUDENT_ID` <> `REPORTED_STUDENT_ID` OR `REPORTED_STUDENT_ID` IS NULL)
) ENGINE = InnoDB;

-- Table 10: SYSTEM_LOG
CREATE TABLE IF NOT EXISTS `SYSTEM_LOG` (
  `LOG_ID`       INT NOT NULL AUTO_INCREMENT,
  `LOG_DATETIME` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `LOG_TYPE`     VARCHAR(50) NOT NULL,
  `MESSAGE`      TEXT NOT NULL,
  PRIMARY KEY (`LOG_ID`)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- 3) Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX `IDX_LISTING_SELLER`              ON `LISTING`(`SELLER_ID`);
CREATE INDEX `IDX_LISTING_STATUS_CAT_CREATED`  ON `LISTING`(`STATUS`, `CATEGORY_ID`, `CREATED_AT`);
CREATE INDEX `IDX_TRADE_BUYER`                ON `TRADE`(`BUYER_ID`);
CREATE INDEX `IDX_MESSAGE_RECEIVER`           ON `MESSAGE`(`RECEIVER_ID`);
CREATE INDEX `IDX_WISHLIST_STUDENT`           ON `WISHLIST`(`STUDENT_ID`);

-- ---------------------------------------------------------------------------
-- 4) Triggers
-- ---------------------------------------------------------------------------

DELIMITER $$

-- Enforce that TRADE.SELLER_ID always matches LISTING.SELLER_ID
CREATE TRIGGER `trg_trade_validate_seller_insert`
BEFORE INSERT ON `TRADE`
FOR EACH ROW
BEGIN
  DECLARE v_listing_seller CHAR(8);

  SELECT `SELLER_ID`
    INTO v_listing_seller
  FROM `LISTING`
  WHERE `LISTING_ID` = NEW.`LISTING_ID`;

  IF v_listing_seller IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid LISTING_ID in TRADE.';
  END IF;

  IF NEW.`SELLER_ID` <> v_listing_seller THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TRADE.SELLER_ID must match LISTING.SELLER_ID.';
  END IF;
END$$

CREATE TRIGGER `trg_trade_validate_seller_update`
BEFORE UPDATE ON `TRADE`
FOR EACH ROW
BEGIN
  DECLARE v_listing_seller CHAR(8);

  SELECT `SELLER_ID`
    INTO v_listing_seller
  FROM `LISTING`
  WHERE `LISTING_ID` = NEW.`LISTING_ID`;

  IF v_listing_seller IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid LISTING_ID in TRADE.';
  END IF;

  IF NEW.`SELLER_ID` <> v_listing_seller THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TRADE.SELLER_ID must match LISTING.SELLER_ID.';
  END IF;
END$$

-- Reserve a listing when a trade is created (ACTIVE -> RESERVED)
CREATE TRIGGER `trg_trade_reserve_listing`
AFTER INSERT ON `TRADE`
FOR EACH ROW
BEGIN
  UPDATE `LISTING`
  SET `STATUS` = 'RESERVED'
  WHERE `LISTING_ID` = NEW.`LISTING_ID`
    AND `STATUS` = 'ACTIVE';
END$$

-- Sync LISTING status from TRADE status updates
CREATE TRIGGER `trg_trade_sync_listing_status`
AFTER UPDATE ON `TRADE`
FOR EACH ROW
BEGIN
  IF NEW.`STATUS` = 'COMPLETED' AND OLD.`STATUS` <> 'COMPLETED' THEN
    UPDATE `LISTING`
    SET `STATUS` = 'SOLD'
    WHERE `LISTING_ID` = NEW.`LISTING_ID`;

  ELSEIF NEW.`STATUS` = 'CANCELLED' AND OLD.`STATUS` <> 'CANCELLED' THEN
    UPDATE `LISTING`
    SET `STATUS` = 'ACTIVE'
    WHERE `LISTING_ID` = NEW.`LISTING_ID`
      AND `STATUS` = 'RESERVED';
  END IF;
END$$

-- Log LISTING status changes
CREATE TRIGGER `trg_listing_status_log`
AFTER UPDATE ON `LISTING`
FOR EACH ROW
BEGIN
  IF NEW.`STATUS` <> OLD.`STATUS` THEN
    INSERT INTO `SYSTEM_LOG` (`LOG_DATETIME`, `LOG_TYPE`, `MESSAGE`)
    VALUES (
      NOW(),
      'LISTING_STATUS_CHANGE',
      CONCAT(
        'Listing ', NEW.`LISTING_ID`,
        ' changed STATUS from ', OLD.`STATUS`,
        ' to ', NEW.`STATUS`, '.'
      )
    );
  END IF;
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------
-- 5) Reset Data (useful when rerunning only the seeding section)
-- ---------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `SYSTEM_LOG`;
TRUNCATE TABLE `REPORT`;
TRUNCATE TABLE `USER_REVIEW`;
TRUNCATE TABLE `MESSAGE`;
TRUNCATE TABLE `TRADE`;
TRUNCATE TABLE `WISHLIST`;
TRUNCATE TABLE `LISTING_IMAGE`;
TRUNCATE TABLE `LISTING`;
TRUNCATE TABLE `CATEGORY`;
TRUNCATE TABLE `STUDENT`;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------------
-- 6) Seed Data
-- ---------------------------------------------------------------------------

-- Categories
INSERT INTO `CATEGORY` (`CATEGORY_ID`, `NAME`, `DESCRIPTION`) VALUES
(1, 'Technology',  'Laptops, tablets, calculators, and chargers'),
(2, 'Kitchenware', 'Pots, pans, cutlery, and plates'),
(3, 'Appliance',   'Microwaves, heaters, toasters, and fans'),
(4, 'Storage',     'Boxes, organizers, and hangers'),
(5, 'Cleaning',    'Mops, brooms, and vacuums'),
(6, 'Other',       'Books, stationery, and miscellaneous items');

-- Students (25 rows)
INSERT INTO `STUDENT`
(`STUDENT_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE`, `STATUS`, `REGISTRATION_DATE`)
VALUES
('20230101', 'Tiago',     'Silva',       '20230101@novaims.unl.pt', '910000001', 'ACTIVE',   '2023-09-01'),
('20230102', 'Beatriz',   'Costa',       '20230102@novaims.unl.pt', '910000002', 'ACTIVE',   '2023-09-02'),
('20230103', 'Lars',      'Nielsen',     '20230103@novaims.unl.pt', '910000003', 'ACTIVE',   '2023-09-03'),
('20230104', 'Sofia',     'Martins',     '20230104@novaims.unl.pt', '910000004', 'ACTIVE',   '2023-09-04'),
('20230105', 'Diogo',     'Ferreira',    '20230105@novaims.unl.pt', '910000005', 'ACTIVE',   '2023-09-05'),
('20230106', 'Emma',      'Schmidt',     '20230106@novaims.unl.pt', '910000006', 'ACTIVE',   '2023-09-06'),
('20230107', 'João',      'Pereira',     '20230107@novaims.unl.pt', '910000007', 'ACTIVE',   '2023-09-07'),
('20230108', 'Mariana',   'Rodrigues',   '20230108@novaims.unl.pt', '910000008', 'ACTIVE',   '2023-09-08'),
('20230109', 'Lucas',     'Oliveira',    '20230109@novaims.unl.pt', '910000009', 'ACTIVE',   '2023-09-09'),
('20230110', 'Inês',      'Santos',      '20230110@novaims.unl.pt', '910000010', 'ACTIVE',   '2023-09-10'),
('20230111', 'Pedro',     'Gomes',       '20230111@novaims.unl.pt', '910000011', 'ACTIVE',   '2023-09-11'),
('20230112', 'Ana',       'Lopes',       '20230112@novaims.unl.pt', '910000012', 'ACTIVE',   '2023-09-12'),
('20230113', 'Miguel',    'Almeida',     '20230113@novaims.unl.pt', '910000013', 'ACTIVE',   '2023-09-13'),
('20230114', 'Catarina',  'Ribeiro',     '20230114@novaims.unl.pt', '910000014', 'ACTIVE',   '2023-09-14'),
('20230115', 'Giulia',    'Ricci',       '20230115@novaims.unl.pt', '910000015', 'ACTIVE',   '2023-09-15'),
('20230116', 'Rafael',    'Carvalho',    '20230116@novaims.unl.pt', '910000016', 'ACTIVE',   '2023-09-16'),
('20230117', 'Margarida', 'Pinto',       '20230117@novaims.unl.pt', '910000017', 'ACTIVE',   '2023-09-17'),
('20230118', 'Francisco', 'Teixeira',    '20230118@novaims.unl.pt', '910000018', 'ACTIVE',   '2023-09-18'),
('20230119', 'Bad',       'Actor',       '20230119@novaims.unl.pt', '910000019', 'BANNED',   '2023-10-01'),
('20230120', 'Lazy',      'Student',     '20230120@novaims.unl.pt', '910000020', 'INACTIVE', '2023-09-01'),
('20230124', 'Matilde',   'Vieira',      '20230124@novaims.unl.pt', '910000024', 'ACTIVE',   '2023-10-05'),
('20240101', 'Afonso',    'Mendes',      '20240101@novaims.unl.pt', '910000021', 'ACTIVE',   '2024-01-02'),
('20240102', 'Chloe',     'Dubois',      '20240102@novaims.unl.pt', '910000022', 'ACTIVE',   '2024-01-03'),
('20240103', 'Gonçalo',   'Nunes',       '20240103@novaims.unl.pt', '910000023', 'ACTIVE',   '2024-01-04'),
('20240104', 'Tomás',     'Neves',       '20240104@novaims.unl.pt', '910000025', 'ACTIVE',   '2024-01-06');

-- Listings (30 rows) start as ACTIVE; triggers will drive RESERVED/SOLD/ACTIVE transitions.
INSERT INTO `LISTING`
(`LISTING_ID`, `SELLER_ID`, `CATEGORY_ID`, `NAME`, `DESCRIPTION`, `CONDITION`, `ASKING_PRICE`, `STATUS`, `CREATED_AT`)
VALUES
(1,  '20230101', 1, 'TI-Nspire CX II',   'Used for Stats I',        'GOOD',      90.00, 'ACTIVE', '2023-12-10 10:10:03'),
(2,  '20230102', 3, 'Oil Heater',        'Winter heater',           'LIKE_NEW',  30.00, 'ACTIVE', '2023-12-12 11:04:38'),
(3,  '20230103', 1, 'MacBook Charger',   'Original Apple',          'USED',      20.00, 'ACTIVE', '2023-12-15 09:12:00'),
(4,  '20230105', 3, 'Toaster',           'Bread gets stuck',        'USED',      10.00, 'ACTIVE', '2023-12-18 14:03:50'),
(5,  '20230104', 1, 'iPad 9th Gen',      'Mint condition',          'LIKE_NEW', 250.00, 'ACTIVE', '2023-12-20 10:43:52'),
(6,  '20230106', 1, 'Casio Calculator',  'fx-82MS',                 'GOOD',      10.00, 'ACTIVE', '2023-12-22 12:29:18'),
(7,  '20230101', 5, 'Vacuum Cleaner',    'Bagless',                 'USED',      35.00, 'ACTIVE', '2023-12-28 10:01:40'),
(8,  '20230107', 6, 'Stats Textbook',    'Highlighting inside',     'GOOD',      25.00, 'ACTIVE', '2024-01-05 09:00:02'),
(9,  '20230108', 6, 'Python Book',       'O Reilly',                'LIKE_NEW',  40.00, 'ACTIVE', '2024-01-08 11:30:45'),
(10, '20230109', 6, 'Marketing Book',    'Kotler 15th Ed',          'USED',      30.00, 'ACTIVE', '2024-01-10 10:21:00'),
(11, '20230110', 6, 'Notebooks Bundle',  'Unused',                  'LIKE_NEW',   5.00, 'ACTIVE', '2024-01-12 15:32:00'),
(12, '20230111', 6, 'Financial Acc.',    'Global Edition',          'GOOD',      35.00, 'ACTIVE', '2024-01-15 10:56:20'),
(13, '20230103', 4, 'IKEA Box',          'Transparent',             'GOOD',       8.00, 'ACTIVE', '2024-01-16 10:18:04'),
(14, '20230112', 4, 'Hangers (20x)',     'Velvet',                  'LIKE_NEW',  10.00, 'ACTIVE', '2024-01-18 10:09:47'),
(15, '20230113', 2, 'Frying Pan',        'Scratched',               'DAMAGED',    2.00, 'ACTIVE', '2024-01-20 12:40:01'),
(16, '20230114', 2, 'Cutlery Set',       'For 4 people',            'GOOD',      12.00, 'ACTIVE', '2024-01-22 09:29:00'),
(17, '20230115', 2, 'Blender',           'Smoothies',               'USED',      15.00, 'ACTIVE', '2024-01-25 14:01:23'),
(18, '20230116', 3, 'Desk Fan',          'USB',                     'LIKE_NEW',   8.00, 'ACTIVE', '2024-02-01 10:05:00'),
(19, '20230117', 6, 'Drawing Tube',      'Plastic',                 'GOOD',       5.00, 'ACTIVE', '2024-02-02 11:28:58'),
(20, '20230119', 1, 'Broken iPhone',     'Parts only',              'DAMAGED',   50.00, 'ACTIVE', '2024-02-03 10:20:56'),
(21, '20230118', 4, 'Shoe Rack',         '10 pairs',                'USED',      10.00, 'ACTIVE', '2024-02-05 12:30:44'),
(22, '20240101', 1, 'Dell Monitor',      '24 inch',                 'GOOD',      80.00, 'ACTIVE', '2024-02-06 09:00:02'),
(23, '20240102', 1, 'Keyboard',          'Logitech K380',           'LIKE_NEW',  25.00, 'ACTIVE', '2024-02-07 14:03:39'),
(24, '20240103', 5, 'Mop Bucket',        'Vileda',                  'USED',      10.00, 'ACTIVE', '2024-02-08 10:38:22'),
(25, '20230124', 3, 'Nespresso',         'Essenza Mini',            'GOOD',      45.00, 'ACTIVE', '2024-02-10 11:01:54'),
(26, '20240104', 6, 'Backpack',          'Eastpak',                 'USED',      15.00, 'ACTIVE', '2024-02-12 10:02:55'),
(27, '20230102', 2, 'Wine Glasses',      'Box of 6',                'LIKE_NEW',  15.00, 'ACTIVE', '2024-02-14 12:53:59'),
(28, '20230105', 1, 'Fake AirPods',      'Replica',                 'LIKE_NEW',  20.00, 'ACTIVE', '2024-02-15 09:08:00'),
(29, '20230108', 6, 'Highlighters',      'Pack of 10',              'USED',       2.00, 'ACTIVE', '2024-02-16 10:45:01'),
(30, '20230111', 4, 'Underbed Box',      'Fabric',                  'GOOD',       5.00, 'ACTIVE', '2024-02-16 11:00:11');

-- Trades (28 rows) spanning 2023–2024 (consecutive years)
INSERT INTO `TRADE`
(`TRADE_ID`, `LISTING_ID`, `BUYER_ID`, `SELLER_ID`, `AGREED_PRICE`, `PAYMENT_METHOD`, `STATUS`, `CREATED_AT`, `COMPLETED_AT`)
VALUES
-- 2023 trades
(1,  1,  '20230106', '20230101', 85.00, 'MBWAY',   'COMPLETED',       '2023-12-11 10:01:37', '2023-12-11 12:04:20'),
(2,  2,  '20230104', '20230102', 25.00, 'CASH',    'COMPLETED',       '2023-12-13 12:40:00', '2023-12-14 09:00:02'),
(3,  7,  '20230103', '20230101', 30.00, 'REVOLUT', 'COMPLETED',       '2023-12-29 12:31:09', '2023-12-30 10:02:00'),

-- 2024 trades
(4,  8,  '20230115', '20230107', 20.00, 'MBWAY',   'COMPLETED',       '2024-01-06 14:30:00', '2024-01-07 10:00:57'),
(5,  11, '20230116', '20230110',  5.00, 'CASH',    'COMPLETED',       '2024-01-13 16:54:30', '2024-01-14 09:03:49'),
(6,  13, '20230120', '20230103',  8.00, 'MBWAY',   'COMPLETED',       '2024-01-17 11:00:48', '2024-01-17 14:50:12'),
(7,  17, '20240104', '20230115', 12.00, 'CASH',    'COMPLETED',       '2024-01-26 15:39:20', '2024-01-27 09:20:39'),
(8,  21, '20230102', '20230118', 10.00, 'MBWAY',   'COMPLETED',       '2024-02-05 13:02:00', '2024-02-06 10:19:19'),
(9,  26, '20230101', '20240104', 15.00, 'MBWAY',   'COMPLETED',       '2024-02-13 11:01:37', '2024-02-13 13:09:00'),
(10, 5,  '20230102', '20230104', 240.00, 'MBWAY',   'PENDING_MEETUP', '2024-02-18 09:22:04', NULL),
(11, 12, '20230106', '20230111',  30.00, 'CASH',    'PENDING_MEETUP', '2024-02-19 10:05:46', NULL),
(12, 22, '20230110', '20240101',  75.00, 'REVOLUT', 'PENDING_MEETUP', '2024-02-20 11:59:01', NULL),
(13, 20, '20230105', '20230119',  40.00, 'MBWAY',   'SUSPENDED',      '2024-02-04 11:03:30', NULL),
(14, 28, '20230124', '20230105',  20.00, 'CASH',    'CANCELLED',      '2024-02-16 08:21:05', NULL),
(15, 3,  '20230114', '20230103',  18.00, 'MBWAY',   'COMPLETED',      '2024-02-22 10:12:59', '2024-02-22 12:06:09'),
(16, 4,  '20230112', '20230105',   8.00, 'CASH',    'CANCELLED',      '2024-02-23 12:01:20', NULL),
(17, 6,  '20230115', '20230106',   8.00, 'MBWAY',   'COMPLETED',      '2024-02-24 09:58:21', '2024-02-24 10:30:01'),
(18, 9,  '20240102', '20230108',  35.00, 'REVOLUT', 'PENDING_MEETUP', '2024-02-25 11:24:05', NULL),
(19, 10, '20230113', '20230109',  25.00, 'MBWAY',   'COMPLETED',      '2024-02-26 14:05:00', '2024-02-27 09:02:50'),
(20, 16, '20230107', '20230114',  10.00, 'CASH',    'COMPLETED',      '2024-03-01 10:29:43', '2024-03-01 12:38:02'),
(21, 18, '20230102', '20230116',   7.00, 'MBWAY',   'COMPLETED',      '2024-03-02 10:00:00', '2024-03-02 12:32:02'),
(22, 19, '20230110', '20230117',   4.00, 'CASH',    'COMPLETED',      '2024-03-03 11:03:04', '2024-03-03 12:10:57'),
(23, 23, '20230111', '20240102',  22.00, 'REVOLUT', 'COMPLETED',      '2024-03-05 15:49:08', '2024-03-06 09:56:23'),
(24, 24, '20230118', '20240103',   9.00, 'MBWAY',   'COMPLETED',      '2024-03-06 10:42:57', '2024-03-06 12:12:29'),
(25, 27, '20240101', '20230102',  13.00, 'CASH',    'COMPLETED',      '2024-03-07 13:34:12', '2024-03-07 16:01:58'),
(26, 25, '20230104', '20230124',  40.00, 'MBWAY',   'PENDING_MEETUP', '2024-03-08 11:03:07', NULL),
(27, 29, '20230101', '20230108',   2.00, 'CASH',    'COMPLETED',      '2024-03-09 10:29:07', '2024-03-09 11:02:27'),
(28, 30, '20230106', '20230111',   5.00, 'MBWAY',   'PENDING_MEETUP', '2024-03-10 09:40:29', NULL);

-- Align listing status deterministically from trade status without updating TRADE.
-- This avoids Safe Update mode issues and avoids relying on retroactive trigger firing.
UPDATE `LISTING` l
JOIN `TRADE` t ON t.`LISTING_ID` = l.`LISTING_ID`
SET l.`STATUS` = CASE
  WHEN t.`STATUS` = 'COMPLETED' THEN 'SOLD'
  WHEN t.`STATUS` = 'CANCELLED' THEN 'ACTIVE'
  ELSE l.`STATUS`
END
WHERE t.`STATUS` IN ('COMPLETED', 'CANCELLED')
  AND l.`LISTING_ID` IS NOT NULL;

-- Mark content-moderation / invalid listings as deleted.
UPDATE `LISTING`
SET `STATUS` = 'DELETED'
WHERE `LISTING_ID` IN (15, 20, 28)
  AND `LISTING_ID` IS NOT NULL;

-- Populate messages
INSERT INTO `MESSAGE`
(`SENDER_ID`, `RECEIVER_ID`, `LISTING_ID`, `MESSAGE_TEXT`, `IS_READ`, `SENT_AT`)
VALUES
('20230106', '20230101', 1,  'Hi Tiago, €85 and I buy it now?',                  TRUE,  '2023-12-10 12:01:00'),
('20230101', '20230106', 1,  'Deal. Meet at the cafeteria?',                     TRUE,  '2023-12-10 12:10:20'),
('20230104', '20230102', 2,  'Is the heater working well?',                      TRUE,  '2023-12-12 12:30:33'),
('20230102', '20230104', 2,  'Yes, it works perfectly.',                         TRUE,  '2023-12-12 12:35:59'),
('20230102', '20230104', 5,  'Can you lower the price for the iPad?',            FALSE, '2023-12-21 09:30:21'),
('20230105', '20230124', 28, 'Trust me, they are real Apple.',                   TRUE,  '2024-02-15 10:30:45'),
('20230124', '20230105', 28, 'The serial number is fake. Cancelling the trade.', TRUE,  '2024-02-15 10:45:03');

-- Populate reviews
INSERT INTO `USER_REVIEW`
(`TRADE_ID`, `REVIEWER_ID`, `TARGET_USER_ID`, `RATING_TYPE`, `SCORE`, `COMMENT`)
VALUES
(1,  '20230106', '20230101', 'AS_SELLER', 5, 'Fast transaction.'),
(2,  '20230104', '20230102', 'AS_SELLER', 5, 'This heater saved my winter.'),
(3,  '20230103', '20230101', 'AS_SELLER', 4, 'Vacuum works, but it was a bit dirty.'),
(7,  '20240104', '20230115', 'AS_SELLER', 3, 'Blender is loud but functional.'),
(9,  '20230101', '20240104', 'AS_BUYER',  5, 'Polite buyer and on time.'),
(23, '20230111', '20240102', 'AS_SELLER', 5, 'Quick meetup, item as described.');

-- Populate reports
INSERT INTO `REPORT`
(`REPORTER_STUDENT_ID`, `REPORTED_LISTING_ID`, `REPORTED_STUDENT_ID`, `REASON`, `DESCRIPTION`, `STATUS`)
VALUES
('20230124', 28, '20230105', 'SCAM', 'Attempted to sell fake AirPods as genuine.',      'RESOLVED'),
('20230101', 20, '20230119', 'SCAM', 'Suspicious device origin (potentially stolen).', 'REVIEWING');

-- Seeded system log examples
INSERT INTO `SYSTEM_LOG` (`LOG_TYPE`, `MESSAGE`) VALUES
('SYSTEM_STARTUP', 'Data seeding completed successfully.'),
('TRADE_ERROR',    'Failed payment attempt for Trade ID 12 - Retrying.');

-- Populate listing images
INSERT INTO `LISTING_IMAGE` (`LISTING_ID`, `IMAGE_URL`, `IS_MAIN_PHOTO`) VALUES
(1,  'https://cloud.storage/img/ti_nspire_front.jpg',            TRUE),
(1,  'https://cloud.storage/img/ti_nspire_back.jpg',             FALSE),
(3,  'https://cloud.storage/img/magsafe_charger.jpg',            TRUE),
(5,  'https://cloud.storage/img/ipad_screen.jpg',                TRUE),
(5,  'https://cloud.storage/img/ipad_back_case.jpg',             FALSE),
(5,  'https://cloud.storage/img/ipad_box.jpg',                   FALSE),
(6,  'https://cloud.storage/img/casio_calc.jpg',                 TRUE),
(20, 'https://cloud.storage/img/broken_iphone_front.jpg',        TRUE),
(20, 'https://cloud.storage/img/broken_iphone_crack_detail.jpg', FALSE),
(22, 'https://cloud.storage/img/monitor_dell.jpg',               TRUE),
(23, 'https://cloud.storage/img/logitech_k380.jpg',              TRUE),
(28, 'https://cloud.storage/img/fake_airpods_box.jpg',           TRUE),
(2,  'https://cloud.storage/img/oil_heater.jpg',                 TRUE),
(4,  'https://cloud.storage/img/toaster_sketchy.jpg',            TRUE),
(7,  'https://cloud.storage/img/vacuum.jpg',                     TRUE),
(13, 'https://cloud.storage/img/ikea_box_transparent.jpg',       TRUE),
(15, 'https://cloud.storage/img/pan_scratched.jpg',              TRUE),
(17, 'https://cloud.storage/img/blender.jpg',                    TRUE),
(18, 'https://cloud.storage/img/usb_fan.jpg',                    TRUE),
(24, 'https://cloud.storage/img/mop_bucket.jpg',                 TRUE),
(25, 'https://cloud.storage/img/nespresso_essenza.jpg',          TRUE),
(25, 'https://cloud.storage/img/nespresso_capsules.jpg',         FALSE),
(8,  'https://cloud.storage/img/stats_book_cover.jpg',           TRUE),
(9,  'https://cloud.storage/img/python_book.jpg',                TRUE),
(10, 'https://cloud.storage/img/marketing_kotler.jpg',           TRUE),
(11, 'https://cloud.storage/img/notebooks_stack.jpg',            TRUE),
(12, 'https://cloud.storage/img/financial_accounting.jpg',       TRUE),
(19, 'https://cloud.storage/img/arch_tube.jpg',                  TRUE),
(29, 'https://cloud.storage/img/highlighters.jpg',               TRUE),
(14, 'https://cloud.storage/img/hangers_black.jpg',              TRUE),
(16, 'https://cloud.storage/img/cutlery_set.jpg',                TRUE),
(21, 'https://cloud.storage/img/shoe_rack.jpg',                  TRUE),
(26, 'https://cloud.storage/img/eastpak_black.jpg',              TRUE),
(27, 'https://cloud.storage/img/wine_glasses_box.jpg',           TRUE),
(30, 'https://cloud.storage/img/underbed_storage.jpg',           TRUE);

-- Populate wishlist
INSERT INTO `WISHLIST` (`STUDENT_ID`, `LISTING_ID`) VALUES
('20230101', 5),
('20230102', 5),
('20230103', 5),
('20240102', 5),
('20230115', 1),
('20230116', 1),
('20230115', 6),
('20240104', 8),
('20240104', 9),
('20230105', 12),
('20230120', 9),
('20230104', 2),
('20230110', 25),
('20230111', 25),
('20230112', 7),
('20230118', 21),
('20230105', 22),
('20230105', 20),
('20230108', 26),
('20230109', 14),
('20230119', 28),
('20240103', 23),
('20230114', 17);

-- ---------------------------------------------------------------------------
-- 7) Invoice Views (no invoice tables)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW `vw_invoice_head_totals` AS
SELECT
  t.`TRADE_ID`                                       AS `INVOICE_ID`,
  t.`COMPLETED_AT`                                   AS `INVOICE_DATE`,
  t.`BUYER_ID`                                       AS `BUYER_ID`,
  CONCAT(b.`FIRST_NAME`, ' ', b.`LAST_NAME`)         AS `BUYER_NAME`,
  b.`EMAIL`                                          AS `BUYER_EMAIL`,
  b.`PHONE`                                          AS `BUYER_PHONE`,
  t.`SELLER_ID`                                      AS `SELLER_ID`,
  CONCAT(s.`FIRST_NAME`, ' ', s.`LAST_NAME`)         AS `SELLER_NAME`,
  t.`LISTING_ID`                                     AS `LISTING_ID`,
  l.`NAME`                                           AS `ITEM_NAME`,
  t.`PAYMENT_METHOD`                                 AS `PAYMENT_METHOD`,
  t.`AGREED_PRICE`                                   AS `TOTAL_AMOUNT`,
  'PAID'                                             AS `INVOICE_STATUS`
FROM `TRADE` t
JOIN `STUDENT` b ON b.`STUDENT_ID` = t.`BUYER_ID`
JOIN `STUDENT` s ON s.`STUDENT_ID` = t.`SELLER_ID`
JOIN `LISTING`  l ON l.`LISTING_ID`  = t.`LISTING_ID`
WHERE t.`STATUS` = 'COMPLETED';

CREATE OR REPLACE VIEW `vw_invoice_details` AS
SELECT
  t.`TRADE_ID`                                       AS `INVOICE_ID`,
  1                                                  AS `LINE_NO`,
  CONCAT('Item: ', l.`NAME`)                         AS `DESCRIPTION`,
  t.`AGREED_PRICE`                                   AS `AMOUNT`
FROM `TRADE` t
JOIN `LISTING` l ON l.`LISTING_ID` = t.`LISTING_ID`
WHERE t.`STATUS` = 'COMPLETED';

-- ---------------------------------------------------------------------------
-- 8) Sanity Checks
-- ---------------------------------------------------------------------------
SHOW TABLES;

SELECT COUNT(*) AS students FROM STUDENT;
SELECT COUNT(*) AS listings FROM LISTING;
SELECT COUNT(*) AS trades   FROM TRADE;

SELECT YEAR(CREATED_AT) AS yr, COUNT(*) AS n_trades
FROM TRADE
GROUP BY YEAR(CREATED_AT)
ORDER BY yr;

SHOW TRIGGERS FROM lx_buy_sell;

-- ---------------------------------------------------------------------------
-- 9) Trigger Demo Snippet (run manually)
-- ---------------------------------------------------------------------------
/*
-- Reset demo case (so it always works)
UPDATE `TRADE`
SET `STATUS` = 'PENDING_MEETUP', `COMPLETED_AT` = NULL
WHERE `TRADE_ID` = 11;

UPDATE `LISTING`
SET `STATUS` = 'RESERVED'
WHERE `LISTING_ID` = 12;

-- Before
SELECT `TRADE_ID`, `STATUS`, `LISTING_ID` FROM `TRADE` WHERE `TRADE_ID` = 11;
SELECT `LISTING_ID`, `STATUS` FROM `LISTING` WHERE `LISTING_ID` = 12;

-- Action: updating the trade triggers listing SOLD and logs the change
UPDATE `TRADE`
SET `STATUS` = 'COMPLETED', `COMPLETED_AT` = NOW()
WHERE `TRADE_ID` = 11;

-- After
SELECT `LISTING_ID`, `STATUS` FROM `LISTING` WHERE `LISTING_ID` = 12;

-- Log check
SELECT `LOG_ID`, `LOG_DATETIME`, `LOG_TYPE`, `MESSAGE`
FROM `SYSTEM_LOG`
ORDER BY `LOG_ID` DESC
LIMIT 10;

-- Invoice via views
SELECT * FROM `vw_invoice_head_totals` WHERE `INVOICE_ID` = 11;
SELECT * FROM `vw_invoice_details`     WHERE `INVOICE_ID` = 11;
*/

-- ---------------------------------------------------------------------------
-- 10) CEO Business Questions (5 queries; at least 3 with JOIN + GROUP BY)
-- ---------------------------------------------------------------------------

-- Q1) Which categories generate the highest completed-trade revenue?
SELECT
  c.`NAME` AS category,
  COUNT(*) AS completed_trades,
  SUM(t.`AGREED_PRICE`) AS revenue
FROM `TRADE` t
JOIN `LISTING` l ON l.`LISTING_ID` = t.`LISTING_ID`
JOIN `CATEGORY` c ON c.`CATEGORY_ID` = l.`CATEGORY_ID`
WHERE t.`STATUS` = 'COMPLETED'
GROUP BY c.`NAME`
ORDER BY revenue DESC;

-- Q2) Who are the top sellers by number of completed sales and average seller rating?
SELECT
  t.`SELLER_ID`,
  CONCAT(s.`FIRST_NAME`, ' ', s.`LAST_NAME`) AS seller_name,
  COUNT(*) AS completed_sales,
  AVG(r.`SCORE`) AS avg_seller_rating
FROM `TRADE` t
JOIN `STUDENT` s ON s.`STUDENT_ID` = t.`SELLER_ID`
LEFT JOIN `USER_REVIEW` r
  ON r.`TRADE_ID` = t.`TRADE_ID` AND r.`RATING_TYPE` = 'AS_SELLER'
WHERE t.`STATUS` = 'COMPLETED'
GROUP BY t.`SELLER_ID`, seller_name
ORDER BY completed_sales DESC, avg_seller_rating DESC;

-- Q3) What is the cancellation and suspension rate by payment method?
SELECT
  `PAYMENT_METHOD`,
  SUM(`STATUS` = 'COMPLETED')   AS n_completed,
  SUM(`STATUS` = 'CANCELLED')   AS n_cancelled,
  SUM(`STATUS` = 'SUSPENDED')   AS n_suspended,
  COUNT(*)                      AS n_total,
  SUM(`STATUS` = 'CANCELLED') / COUNT(*) AS cancelled_rate,
  SUM(`STATUS` = 'SUSPENDED') / COUNT(*) AS suspended_rate
FROM `TRADE`
GROUP BY `PAYMENT_METHOD`;

-- Q4) How long do deals take to complete, by category (hours)?
SELECT
  c.`NAME` AS category,
  AVG(TIMESTAMPDIFF(HOUR, t.`CREATED_AT`, t.`COMPLETED_AT`)) AS avg_hours_to_complete
FROM `TRADE` t
JOIN `LISTING` l ON l.`LISTING_ID` = t.`LISTING_ID`
JOIN `CATEGORY` c ON c.`CATEGORY_ID` = l.`CATEGORY_ID`
WHERE t.`STATUS` = 'COMPLETED'
GROUP BY c.`NAME`
ORDER BY avg_hours_to_complete;

-- Q5) Which users are most frequently reported, and how many reports are still open?
SELECT
  r.`REPORTED_STUDENT_ID` AS student_id,
  CONCAT(s.`FIRST_NAME`, ' ', s.`LAST_NAME`) AS student_name,
  COUNT(*) AS total_reports,
  SUM(r.`STATUS` = 'OPEN') AS open_reports
FROM `REPORT` r
JOIN `STUDENT` s ON s.`STUDENT_ID` = r.`REPORTED_STUDENT_ID`
WHERE r.`REPORTED_STUDENT_ID` IS NOT NULL
GROUP BY r.`REPORTED_STUDENT_ID`, student_name
ORDER BY open_reports DESC, total_reports DESC;
