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

CREATE TABLE IF NOT EXISTS `datalog_player_items` (
  `player_id` INT UNSIGNED NOT NULL,
  `on_login_count` INT NOT NULL DEFAULT 0,
  `on_login_date` BIGINT NOT NULL DEFAULT 0,
  `on_logout_count` INT NOT NULL DEFAULT 0,
  `on_logout_date` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
