-- PokeVerse database extensions (MySQL / MariaDB).
--
-- Apply after schemas/mysql.sql. These tables and columns are not part of the
-- base The Forgotten Server schema; they were reconstructed from the queries in
-- the server source (src/*.cpp) and scripts (data/**/*.lua). Column names and
-- meanings must stay compatible with those queries.
-- Every statement is idempotent so the file can be re-applied safely.

-- ---------------------------------------------------------------------------
-- Columns added to base tables
-- ---------------------------------------------------------------------------

ALTER TABLE `accounts`
  ADD COLUMN IF NOT EXISTS `lang_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `client_id` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `soulcoins` INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `referral` INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `referral_points` INT NOT NULL DEFAULT 0;

ALTER TABLE `players`
  ADD COLUMN IF NOT EXISTS `hidden` TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `pvparenafrags` INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `pvparenadeaths` INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `tournament_score` INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `tournament_weekly_score` INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `firstpokemon` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `lasteggtime` BIGINT NOT NULL DEFAULT 0;

-- ---------------------------------------------------------------------------
-- Account and player data
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `account_storage` (
  `account_id` INT UNSIGNED NOT NULL,
  `key` INT NOT NULL,
  `value` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`account_id`, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_statistics` (
  `player_id` INT UNSIGNED NOT NULL,
  `key` SMALLINT UNSIGNED NOT NULL,
  `value` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_achievements` (
  `player_id` INT UNSIGNED NOT NULL,
  `key` INT NOT NULL,
  PRIMARY KEY (`player_id`, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_highscores` (
  `player_id` INT UNSIGNED NOT NULL,
  `score_id` INT NOT NULL,
  `value` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `score_id`),
  KEY `score_id` (`score_id`, `value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_pokemon` (
  `player_id` INT UNSIGNED NOT NULL,
  `slot` TINYINT UNSIGNED NOT NULL,
  `pokemon_number` INT NOT NULL DEFAULT 0,
  `description` TEXT NOT NULL,
  PRIMARY KEY (`player_id`, `slot`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_first_pokemon` (
  `id` INT UNSIGNED NOT NULL,
  `pokemon_sex` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `player_stored_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `item_type` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `attributes` BLOB,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `ball_counter` (
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_id` INT NOT NULL,
  `poke` INT UNSIGNED NOT NULL DEFAULT 0,
  `great` INT UNSIGNED NOT NULL DEFAULT 0,
  `ultra` INT UNSIGNED NOT NULL DEFAULT 0,
  `safari` INT UNSIGNED NOT NULL DEFAULT 0,
  `avalanche` INT UNSIGNED NOT NULL DEFAULT 0,
  `blaze` INT UNSIGNED NOT NULL DEFAULT 0,
  `christmas` INT UNSIGNED NOT NULL DEFAULT 0,
  `coloured` INT UNSIGNED NOT NULL DEFAULT 0,
  `gaia` INT UNSIGNED NOT NULL DEFAULT 0,
  `heremit` INT UNSIGNED NOT NULL DEFAULT 0,
  `hurricane` INT UNSIGNED NOT NULL DEFAULT 0,
  `spectrum` INT UNSIGNED NOT NULL DEFAULT 0,
  `vital` INT UNSIGNED NOT NULL DEFAULT 0,
  `voltagic` INT UNSIGNED NOT NULL DEFAULT 0,
  `white easter` INT UNSIGNED NOT NULL DEFAULT 0,
  `zen` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `pokemon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `egg_counter` (
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_id` INT NOT NULL,
  `tries` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`, `pokemon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `referral_friends` (
  `account_referral` INT UNSIGNED NOT NULL,
  `account_friend` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`account_referral`, `account_friend`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `parcels` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `from_player_id` INT UNSIGNED NOT NULL,
  `to_player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `coupons` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(64) NOT NULL,
  `type` TINYINT NOT NULL DEFAULT 0,
  `reward` INT NOT NULL DEFAULT 0,
  `expires` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `coupon_uses` (
  `coupon_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`coupon_id`, `account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- World objects
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ball_pillars` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `positionx` INT NOT NULL,
  `positiony` INT NOT NULL,
  `positionz` INT NOT NULL,
  `attributes` BLOB,
  `ball_id` INT NOT NULL,
  `creature_name` VARCHAR(255) NOT NULL,
  `creature_sex` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `world_pos` (`world_id`, `positionx`, `positiony`, `positionz`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `berry_trees` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `positionx` INT NOT NULL,
  `positiony` INT NOT NULL,
  `positionz` INT NOT NULL,
  `itemid` INT NOT NULL,
  `growdate` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `world_pos` (`world_id`, `positionx`, `positiony`, `positionz`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Day care
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `daycare_male` (
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `ball_id` INT NOT NULL DEFAULT 0,
  `max_training_minutes` INT NOT NULL DEFAULT 0,
  `pokemon_name` VARCHAR(255) NOT NULL DEFAULT '',
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `pokemon_experience` BIGINT NOT NULL DEFAULT 0,
  `pokemon_energy` INT NOT NULL DEFAULT 0,
  `pokemon_maxenergy` INT NOT NULL DEFAULT 0,
  `pokemon_nickname` VARCHAR(255) NOT NULL DEFAULT '',
  `pokemon_sex` TINYINT NOT NULL DEFAULT 0,
  `pokemon_extrapoints` INT NOT NULL DEFAULT 0,
  `pokemon_specialability` INT NOT NULL DEFAULT 0,
  `pokemon_tm1` INT NOT NULL DEFAULT 0,
  `pokemon_tm1_slot` INT NOT NULL DEFAULT 0,
  `pokemon_tm2` INT NOT NULL DEFAULT 0,
  `pokemon_tm2_slot` INT NOT NULL DEFAULT 0,
  `ball_seal` INT NOT NULL DEFAULT 0,
  `attributes` BLOB,
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `daycare_female` LIKE `daycare_male`;

CREATE TABLE IF NOT EXISTS `daycare_plates` (
  `player_id` INT UNSIGNED NOT NULL,
  `item_id` INT NOT NULL,
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Markets and traders
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `market_offers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `sale` TINYINT(1) NOT NULL DEFAULT 0,
  `itemtype` INT UNSIGNED NOT NULL,
  `amount` SMALLINT UNSIGNED NOT NULL,
  `created` BIGINT UNSIGNED NOT NULL,
  `anonymous` TINYINT(1) NOT NULL DEFAULT 0,
  `price` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `sale` (`sale`, `itemtype`),
  KEY `created` (`created`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `market_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `sale` TINYINT(1) NOT NULL DEFAULT 0,
  `itemtype` INT UNSIGNED NOT NULL,
  `amount` SMALLINT UNSIGNED NOT NULL,
  `price` INT UNSIGNED NOT NULL DEFAULT 0,
  `expires_at` BIGINT UNSIGNED NOT NULL,
  `inserted` BIGINT UNSIGNED NOT NULL,
  `state` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`, `sale`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Global Trade Station (data/lib/ps/systems/066-gts.lua). kind 0 is an item offer (sale 1 sells
-- items held here, sale 0 buys with money held here), kind 1 a Pokemon for sale: itemtype is then
-- the ball and attributes the ball itself. price is per piece.
CREATE TABLE IF NOT EXISTS `gts_offers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `kind` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `sale` TINYINT(1) NOT NULL DEFAULT 1,
  `itemtype` INT UNSIGNED NOT NULL,
  `amount` INT UNSIGNED NOT NULL DEFAULT 1,
  `price` BIGINT UNSIGNED NOT NULL,
  `created` BIGINT NOT NULL,
  `expires` BIGINT NOT NULL,
  `pokemon_name` VARCHAR(255) NOT NULL DEFAULT '',
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `attributes` BLOB,
  PRIMARY KEY (`id`),
  KEY `item` (`kind`, `itemtype`, `expires`),
  KEY `pokemon` (`kind`, `pokemon_name`, `expires`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- state 1 done (sold or bought), 2 cancelled, 3 expired
CREATE TABLE IF NOT EXISTS `gts_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `kind` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `sale` TINYINT(1) NOT NULL DEFAULT 1,
  `itemtype` INT UNSIGNED NOT NULL,
  `pokemon_name` VARCHAR(255) NOT NULL DEFAULT '',
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `amount` INT UNSIGNED NOT NULL DEFAULT 1,
  `price` BIGINT UNSIGNED NOT NULL,
  `state` TINYINT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `pokemon_market` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `pokemon_name` VARCHAR(255) NOT NULL,
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `pokemon_extrapoints` INT NOT NULL DEFAULT 0,
  `pokemon_sex` TINYINT NOT NULL DEFAULT 0,
  `pokemon_specialability` INT NOT NULL DEFAULT 0,
  `pokemon_eggmove` VARCHAR(255) NOT NULL DEFAULT '',
  `ball_id` INT NOT NULL DEFAULT 0,
  `attributes` BLOB,
  `value` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`),
  KEY `pokemon_name` (`pokemon_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `poketrader_offerts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_id` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `min_bid` BIGINT NOT NULL DEFAULT 0,
  `created` BIGINT NOT NULL,
  `deadline` BIGINT NOT NULL,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `world_id` (`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `poketrader_bids` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `offert_id` INT UNSIGNED NOT NULL,
  `created` BIGINT NOT NULL,
  `bid` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `offert_id` (`offert_id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Elite Four
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `elite_four_champions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `lookbody` INT NOT NULL DEFAULT 0,
  `lookfeet` INT NOT NULL DEFAULT 0,
  `lookhead` INT NOT NULL DEFAULT 0,
  `looklegs` INT NOT NULL DEFAULT 0,
  `looktype` INT NOT NULL DEFAULT 0,
  `lookaddons` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `elite_four_champion_pokemons` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `level` INT NOT NULL DEFAULT 0,
  `nickname` VARCHAR(255) NOT NULL DEFAULT '',
  `sex` TINYINT NOT NULL DEFAULT 0,
  `extra_points` INT NOT NULL DEFAULT 0,
  `special_ability` INT NOT NULL DEFAULT 0,
  `moveset` TEXT,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Tournaments
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `tournaments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tournament_id` INT NOT NULL,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `name` VARCHAR(255) NOT NULL DEFAULT '',
  `min_level` INT NOT NULL DEFAULT 0,
  `max_level` INT NOT NULL DEFAULT 0,
  `last_winner` INT UNSIGNED NOT NULL DEFAULT 0,
  `last_date` BIGINT NOT NULL DEFAULT 0,
  `number` INT NOT NULL DEFAULT 0,
  `next_date` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tournament_world` (`tournament_id`, `world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_inscriptions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tournament_id` INT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `tournament_world` (`tournament_id`, `world_id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_bans` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `expires` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_histories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tournament_id` INT NOT NULL,
  `winner` INT UNSIGNED NOT NULL,
  `loser` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `round` INT NOT NULL DEFAULT 0,
  `show` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `winner_loser` (`winner`, `loser`),
  KEY `tournament_id` (`tournament_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_history_pokemon` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tournament_history_id` INT UNSIGNED NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_number` INT NOT NULL DEFAULT 0,
  `description` TEXT,
  PRIMARY KEY (`id`),
  KEY `tournament_history_id` (`tournament_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_winners` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tournament_id` INT NOT NULL,
  `winner` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `tournament_weekly_winners` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Polls
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `polls` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `question` TEXT NOT NULL,
  `deadline` DATETIME NOT NULL,
  `text_mode` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `poll_options` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `poll_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `poll_id` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `poll_votes` (
  `poll_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `poll_option_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`poll_id`, `account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `poll_texts` (
  `poll_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `text` TEXT NOT NULL,
  PRIMARY KEY (`poll_id`, `account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Data logs (write-mostly audit tables; `date` is a Unix timestamp)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `datalog_bank_transactions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `action_id` INT NOT NULL,
  `sender` INT UNSIGNED NOT NULL DEFAULT 0,
  `receiver` INT UNSIGNED NOT NULL DEFAULT 0,
  `amount` BIGINT NOT NULL DEFAULT 0,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sender` (`sender`),
  KEY `receiver` (`receiver`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_boss_rewards` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `item_id` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_anniversary_drops` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_christmas_drops` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_easter_drops` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_halloween_drops` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_julyvacation_drops` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_surprise_box` LIKE `datalog_boss_rewards`;
CREATE TABLE IF NOT EXISTS `datalog_rangerclub_boss_rewards` LIKE `datalog_boss_rewards`;

CREATE TABLE IF NOT EXISTS `datalog_boss_spawns` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `name` VARCHAR(255) NOT NULL,
  `posx` INT NOT NULL,
  `posy` INT NOT NULL,
  `posz` INT NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_casino_token_bought` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `item_id` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `tokens` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_mastery_token_bought` LIKE `datalog_casino_token_bought`;

CREATE TABLE IF NOT EXISTS `datalog_caughts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_number` INT NOT NULL,
  `tries` INT NOT NULL DEFAULT 0,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_coin_uses` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `use` INT NOT NULL,
  `amount` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_token_bought` LIKE `datalog_coin_uses`;

CREATE TABLE IF NOT EXISTS `datalog_colosseum_arena` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_duel_bet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `leader_a` INT UNSIGNED NOT NULL,
  `leader_b` INT UNSIGNED NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `amount` BIGINT NOT NULL DEFAULT 0,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_egg_generate` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `egg` VARCHAR(255) NOT NULL,
  `date` BIGINT NOT NULL,
  `tries` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_egg_move_generate` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_name` VARCHAR(255) NOT NULL,
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `pokemon_extrapoints` INT NOT NULL DEFAULT 0,
  `egg_move` VARCHAR(255) NOT NULL,
  `from_egg` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_egg_move_regenerate` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_name` VARCHAR(255) NOT NULL,
  `pokemon_level` INT NOT NULL DEFAULT 0,
  `pokemon_extrapoints` INT NOT NULL DEFAULT 0,
  `egg_move` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_logins` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `ip` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_map_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `itemtype` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `attributes` BLOB,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_online` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `world_id` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `date` BIGINT NOT NULL,
  `online` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_ping` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `ping` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- One row per logout; the next login fills the row whose on_login_count is still NULL.
CREATE TABLE IF NOT EXISTS `datalog_player_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `on_login_count` INT NULL DEFAULT NULL,
  `on_login_date` BIGINT NULL DEFAULT NULL,
  `on_logout_count` INT NOT NULL DEFAULT 0,
  `on_logout_date` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Databases created before the table had an `id` column allowed only one row per player,
-- so every logout after the first one failed with a duplicate key.
SET @pv_sql := IF((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE()
    AND table_name = 'datalog_player_items' AND column_name = 'id') = 0,
  'ALTER TABLE `datalog_player_items` DROP PRIMARY KEY,
     ADD COLUMN `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
     ADD KEY `player_id` (`player_id`),
     MODIFY `on_login_count` INT NULL DEFAULT NULL,
     MODIFY `on_login_date` BIGINT NULL DEFAULT NULL',
  'DO 0');
PREPARE pv_stmt FROM @pv_sql;
EXECUTE pv_stmt;
DEALLOCATE PREPARE pv_stmt;

CREATE TABLE IF NOT EXISTS `datalog_player_ups` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `from_level` INT NOT NULL,
  `to_level` INT NOT NULL,
  `date` BIGINT NOT NULL,
  `posx` INT NOT NULL DEFAULT 0,
  `posy` INT NOT NULL DEFAULT 0,
  `posz` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_pokemon_ups` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `pokemon_number` INT NOT NULL,
  `from_level` INT NOT NULL,
  `to_level` INT NOT NULL,
  `date` BIGINT NOT NULL,
  `posx` INT NOT NULL DEFAULT 0,
  `posy` INT NOT NULL DEFAULT 0,
  `posz` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_poke_nick_change` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `old_nickname` VARCHAR(255) NOT NULL DEFAULT '',
  `new_nickname` VARCHAR(255) NOT NULL DEFAULT '',
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_pokemon_market` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `seller` INT UNSIGNED NOT NULL,
  `buyer` INT UNSIGNED NOT NULL,
  `date` BIGINT NOT NULL,
  `ball_id` INT NOT NULL DEFAULT 0,
  `attributes` BLOB,
  `value` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_poketrader_boughts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `item_id` INT NOT NULL,
  `count` INT NOT NULL DEFAULT 1,
  `bid` BIGINT NOT NULL DEFAULT 0,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_rangerclub_boss` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `boss_id` INT NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_rangerclub_task` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `task_id` INT NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_referral_exchange` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `date` BIGINT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `datalog_slot_machine` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date` BIGINT NOT NULL,
  `player_id` INT UNSIGNED NOT NULL,
  `gain` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ---------------------------------------------------------------------------
-- Discord account links (PokeVerse-Discord bot, docs/discord-bridge.md)
-- ---------------------------------------------------------------------------
-- One row per linked game account; the game server is the only writer. The Discord user ID
-- is a snowflake stored as text so it never loses precision. `main_player_id` is the
-- character used as the Discord nickname; NULL means "not chosen", and the bridge then uses
-- the account's first-created character (lowest `players`.`id`).
-- Rollback: DROP TABLE `discord_account_links`; no other table refers to it and no existing
-- table was changed.
CREATE TABLE IF NOT EXISTS `discord_account_links` (
  `account_id` INT NOT NULL,
  `discord_user_id` VARCHAR(20) NOT NULL,
  `main_player_id` INT NULL DEFAULT NULL,
  `linked_at` BIGINT UNSIGNED NOT NULL,
  `updated_at` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `discord_user_id` (`discord_user_id`),
  KEY `main_player_id` (`main_player_id`),
  CONSTRAINT `discord_account_links_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `discord_account_links_main` FOREIGN KEY (`main_player_id`) REFERENCES `players` (`id`) ON DELETE SET NULL
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Daily tasks (data/lib/ps/systems/062-dailyTasks.lua)
-- ---------------------------------------------------------------------------
-- One row per character: `day` is the server-local date the tasks were picked for and
-- `data` the JSON state (tasks, progress, claims, reroll). Only the game server writes it.
-- Rollback: DROP TABLE `player_daily_tasks`; no existing table was changed.
CREATE TABLE IF NOT EXISTS `player_daily_tasks` (
  `player_id` INT NOT NULL,
  `day` CHAR(10) NOT NULL,
  `data` TEXT NOT NULL,
  `updated_at` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`player_id`),
  CONSTRAINT `player_daily_tasks_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Weekly tasks and the hunting board (data/lib/ps/systems/062-dailyTasks.lua, 064-huntingTasks.lua)
-- ---------------------------------------------------------------------------
-- One row per character and board ("weekly", "hunting"): `period` is the Monday the weekly
-- tasks were picked for (empty for the hunting board) and `data` the JSON state. Only the
-- game server writes it.
-- Rollback: DROP TABLE `player_task_boards`; no existing table was changed.
CREATE TABLE IF NOT EXISTS `player_task_boards` (
  `player_id` INT NOT NULL,
  `board` VARCHAR(16) NOT NULL,
  `period` VARCHAR(16) NOT NULL,
  `data` TEXT NOT NULL,
  `updated_at` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`player_id`, `board`),
  CONSTRAINT `player_task_boards_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- One-time data migrations
-- ---------------------------------------------------------------------------
-- Each migration runs once per database and is recorded here by name.
CREATE TABLE IF NOT EXISTS `pokeverse_migrations` (
  `name` VARCHAR(64) NOT NULL,
  `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
) ENGINE = InnoDB;

-- New characters start duel win/loss, battle win/loss, headbutting and fishing at 0 (catching
-- stays at 10, getCatchChance uses it directly). Databases created before this still have the
-- old trigger, and their characters lose the 10 they started with; levels earned above it stay.
DROP TRIGGER IF EXISTS `oncreate_players`;
CREATE TRIGGER `oncreate_players` AFTER INSERT ON `players` FOR EACH ROW
  INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES
    (NEW.`id`, 0, 0), (NEW.`id`, 1, 0), (NEW.`id`, 2, 0), (NEW.`id`, 3, 0),
    (NEW.`id`, 4, 0), (NEW.`id`, 5, 10), (NEW.`id`, 6, 0);

UPDATE `player_skills` SET `value` = GREATEST(`value` - 10, 0), `count` = 0
  WHERE `skillid` IN (0, 1, 2, 3, 4, 6)
    AND NOT EXISTS (SELECT 1 FROM `pokeverse_migrations` WHERE `name` = 'skills-start-at-0');
INSERT IGNORE INTO `pokeverse_migrations` (`name`) VALUES ('skills-start-at-0');

-- The Pokemon market and item market NPCs were retired for the GTS. Their listings move over
-- with a fresh 7 days; item offers the GTS doesn't trade come back to their trainers at login.
START TRANSACTION;
INSERT INTO `gts_offers` (`player_id`, `kind`, `sale`, `itemtype`, `amount`, `price`, `created`, `expires`,
    `pokemon_name`, `pokemon_level`, `attributes`)
  SELECT `player_id`, 1, 1, `ball_id`, 1, `value`, `date`, UNIX_TIMESTAMP() + 604800,
    `pokemon_name`, `pokemon_level`, `attributes`
  FROM `pokemon_market`;
DELETE FROM `pokemon_market`;
INSERT INTO `gts_offers` (`player_id`, `kind`, `sale`, `itemtype`, `amount`, `price`, `created`, `expires`)
  SELECT `player_id`, 0, `sale`, `itemtype`, `amount`, `price`, `created`, UNIX_TIMESTAMP() + 604800
  FROM `market_offers`;
DELETE FROM `market_offers`;
COMMIT;
