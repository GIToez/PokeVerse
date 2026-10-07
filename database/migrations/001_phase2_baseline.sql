-- PokeVerse Phase 2 baseline migration. Apply after database/pokeaventuras.sql.
-- Safe to re-run. Every column below is taken from the queries that use it:
--   market_items, market_offers, market_historic -> server/runtime-data/data/lib/game_market.lua
--   dungeon_ranking                               -> server/runtime-data/data/lib/game_dungeon.lua
-- Tables deliberately NOT created (see tools/check_db_tables.py):
--   datalog_ping       IODatalog::logPing is commented out in server/source/iodatalog.cpp
--   z_ots_comunication, z_shop_history  the gesior-shop-system globalevent is commented out
--   player_stored_items  doPlayerInsertStoredItem/doPlayerRemoveStoredItems have no callers

-- Graphical market listings. `attributes` holds getItemAttributesBlob() output and is read
-- back with doItemLoadAttributes(); `time` is os.time() based (expiry).
CREATE TABLE IF NOT EXISTS `market_items` (
  `item_code` varchar(64) NOT NULL,
  `playerseller_id` int(11) NOT NULL,
  `playerseller_name` varchar(255) NOT NULL,
  `onlyoffer` tinyint(1) NOT NULL DEFAULT 0,
  `itemid` int(10) UNSIGNED NOT NULL,
  `count` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `price` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `attributes` blob DEFAULT NULL,
  `time` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`item_code`),
  KEY `playerseller_id` (`playerseller_id`),
  CONSTRAINT `market_items_player_fk` FOREIGN KEY (`playerseller_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- The imported dump ships the TFS 1.x `market_offers` layout (player_id, sale, itemtype,
-- amount, ...), which no PokeVerse code reads. Replace it only while it still has that
-- layout and holds no rows, so re-running never drops Jornadas market data.
DELIMITER //
BEGIN NOT ATOMIC
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = 'market_offers' AND column_name = 'itemtype')
     AND NOT EXISTS (SELECT 1 FROM `market_offers`) THEN
    DROP TABLE `market_offers`;
  END IF;
END //
DELIMITER ;

-- Offers made on a market listing. `state`: 0 under construction, 1 posted,
-- 2 declined, 3 accepted (OFFER* constants in game_market.lua).
CREATE TABLE IF NOT EXISTS `market_offers` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_code` varchar(64) NOT NULL,
  `itemid` int(10) UNSIGNED NOT NULL,
  `count` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `item_index` int(10) UNSIGNED NOT NULL,
  `playeroffer_id` int(11) NOT NULL,
  `playeroffer_name` varchar(255) NOT NULL,
  `attributes` blob DEFAULT NULL,
  `state` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `item_code` (`item_code`, `playeroffer_id`, `item_index`),
  KEY `playeroffer_id` (`playeroffer_id`),
  CONSTRAINT `market_offers_player_fk` FOREIGN KEY (`playeroffer_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Per-player market history, stored as a JSON document.
CREATE TABLE IF NOT EXISTS `market_historic` (
  `player_id` int(11) NOT NULL,
  `historic` mediumtext NOT NULL,
  PRIMARY KEY (`player_id`),
  CONSTRAINT `market_historic_player_fk` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dungeon leaderboard: one JSON ranking document per (difficulty, map).
CREATE TABLE IF NOT EXISTS `dungeon_ranking` (
  `diff` int(11) NOT NULL,
  `mapId` int(11) NOT NULL,
  `ranking` mediumtext NOT NULL,
  PRIMARY KEY (`diff`, `mapId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- The dump ships two staff accounts (GOD, Canibal) whose password is SHA-1("123456").
-- Their characters have datalog history behind NO ACTION foreign keys, so disable the
-- accounts instead of deleting them: '!' can never equal a SHA-1 hex digest.
-- Development accounts live in database/seeds/.
UPDATE `accounts` SET `password` = '!', `blocked` = 1
  WHERE `name` IN ('GOD', 'Canibal') AND `password` = '7c4a8d09ca3762af61e59520943dc26494f8941b';
