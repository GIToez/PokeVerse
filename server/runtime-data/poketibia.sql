-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 01-Ago-2020 às 10:48
-- Versão do servidor: 10.4.11-MariaDB
-- versão do PHP: 7.4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `poketibia`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL,
  `premdays` int(11) NOT NULL DEFAULT 0,
  `lastday` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL DEFAULT '',
  `key` varchar(100) DEFAULT NULL,
  `blocked` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'internal usage',
  `warnings` int(11) NOT NULL DEFAULT 0,
  `group_id` int(11) NOT NULL DEFAULT 1,
  `created` datetime DEFAULT NULL,
  `soulcoins` int(11) DEFAULT 0,
  `display_name` varchar(50) DEFAULT NULL,
  `referral` int(11) DEFAULT NULL,
  `admin` tinyint(1) NOT NULL DEFAULT 0,
  `referral_points` mediumint(8) UNSIGNED NOT NULL DEFAULT 0,
  `lang_id` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `client_id` tinyint(3) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `accounts`
--

INSERT INTO `accounts` (`id`, `name`, `password`, `premdays`, `lastday`, `email`, `key`, `blocked`, `warnings`, `group_id`, `created`, `soulcoins`, `display_name`, `referral`, `admin`, `referral_points`, `lang_id`, `client_id`) VALUES
(70846, 'GOD', '7c4a8d09ca3762af61e59520943dc26494f8941b', 0, 1596270520, 'jededias@chammy.info', NULL, 0, 0, 1, NULL, 0, NULL, NULL, 0, 0, 1, 10),
(70848, 'Canibal', '7c4a8d09ca3762af61e59520943dc26494f8941b', 0, 1596271550, 'juliao@mail.com', NULL, 0, 0, 1, NULL, 0, NULL, NULL, 0, 0, 1, 10);

--
-- Acionadores `accounts`
--
DELIMITER $$
CREATE TRIGGER `ondelete_accounts` BEFORE DELETE ON `accounts` FOR EACH ROW BEGIN DELETE FROM `bans` WHERE `type` NOT IN(1, 2) AND `value` = OLD.`id`; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `account_storage`
--

CREATE TABLE `account_storage` (
  `account_id` int(11) NOT NULL,
  `key` int(11) UNSIGNED NOT NULL,
  `value` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `account_viplist`
--

CREATE TABLE `account_viplist` (
  `account_id` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ball_counter`
--

CREATE TABLE `ball_counter` (
  `player_id` int(10) UNSIGNED NOT NULL,
  `pokemon_id` smallint(5) UNSIGNED NOT NULL,
  `poke` mediumint(8) UNSIGNED DEFAULT 0,
  `great` mediumint(8) UNSIGNED DEFAULT 0,
  `ultra` mediumint(8) UNSIGNED DEFAULT 0,
  `safari` mediumint(8) UNSIGNED DEFAULT 0,
  `coloured` mediumint(8) UNSIGNED DEFAULT 0,
  `avalanche` mediumint(8) UNSIGNED DEFAULT 0,
  `blaze` mediumint(8) UNSIGNED DEFAULT 0,
  `gaia` mediumint(8) UNSIGNED DEFAULT 0,
  `heremit` mediumint(8) UNSIGNED DEFAULT 0,
  `hurricane` mediumint(8) UNSIGNED DEFAULT 0,
  `spectrum` mediumint(8) UNSIGNED DEFAULT 0,
  `vital` mediumint(8) UNSIGNED DEFAULT 0,
  `voltagic` mediumint(8) UNSIGNED DEFAULT 0,
  `zen` mediumint(8) UNSIGNED DEFAULT 0,
  `white easter` mediumint(8) UNSIGNED DEFAULT 0,
  `christmas` mediumint(8) UNSIGNED DEFAULT 0,
  `enchanted` mediumint(8) UNSIGNED DEFAULT 0,
  `dive` mediumint(8) UNSIGNED DEFAULT 0,
  `dusk` mediumint(8) UNSIGNED DEFAULT 0,
  `heal` mediumint(8) UNSIGNED DEFAULT 0,
  `luxury` mediumint(8) UNSIGNED DEFAULT 0,
  `nest` mediumint(8) UNSIGNED DEFAULT 0,
  `net` mediumint(8) UNSIGNED DEFAULT 0,
  `premier` mediumint(8) UNSIGNED DEFAULT 0,
  `quick` mediumint(8) UNSIGNED DEFAULT 0,
  `repeat` mediumint(8) UNSIGNED DEFAULT 0,
  `timer` mediumint(8) UNSIGNED DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ball_pillars`
--

CREATE TABLE `ball_pillars` (
  `world_id` tinyint(4) NOT NULL DEFAULT 0,
  `positionx` mediumint(10) NOT NULL,
  `positiony` mediumint(10) NOT NULL,
  `positionz` tinyint(10) NOT NULL,
  `attributes` blob NOT NULL,
  `ball_id` smallint(5) UNSIGNED NOT NULL,
  `creature_name` varchar(100) NOT NULL,
  `creature_sex` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `bans`
--

CREATE TABLE `bans` (
  `id` int(10) UNSIGNED NOT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1 - ip banishment, 2 - namelock, 3 - account banishment, 4 - notation, 5 - deletion',
  `value` int(10) UNSIGNED NOT NULL COMMENT 'ip address (integer), player guid or account number',
  `param` int(10) UNSIGNED NOT NULL DEFAULT 4294967295 COMMENT 'used only for ip banishment mask (integer)',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `expires` int(11) NOT NULL,
  `added` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `comment` text NOT NULL,
  `reason` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `action` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `statement` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `berry_trees`
--

CREATE TABLE `berry_trees` (
  `world_id` tinyint(4) NOT NULL DEFAULT 0,
  `positionx` mediumint(10) NOT NULL,
  `positiony` mediumint(10) NOT NULL,
  `positionz` tinyint(10) NOT NULL,
  `itemid` int(10) NOT NULL,
  `growdate` bigint(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `blog_posts`
--

CREATE TABLE `blog_posts` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `summary` text DEFAULT NULL,
  `body` longtext DEFAULT NULL,
  `published` tinyint(1) NOT NULL DEFAULT 1,
  `sticky` tinyint(1) NOT NULL DEFAULT 0,
  `in_rss` tinyint(1) NOT NULL DEFAULT 1,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `image` varchar(255) NOT NULL,
  `love_count` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `image_thumb` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `blog_post_categories`
--

CREATE TABLE `blog_post_categories` (
  `id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rght` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `rss_channel_title` varchar(255) DEFAULT NULL,
  `rss_channel_description` text DEFAULT NULL,
  `blog_post_count` int(11) NOT NULL DEFAULT 0,
  `under_blog_post_count` int(11) NOT NULL DEFAULT 0,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `blog_post_categories_blog_posts`
--

CREATE TABLE `blog_post_categories_blog_posts` (
  `blog_post_category_id` int(11) NOT NULL,
  `blog_post_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `blog_post_comments`
--

CREATE TABLE `blog_post_comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `account_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `blog_post_loves`
--

CREATE TABLE `blog_post_loves` (
  `blog_post_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `change_emails`
--

CREATE TABLE `change_emails` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `old_email` varchar(500) NOT NULL,
  `new_email` varchar(500) NOT NULL,
  `date` bigint(20) UNSIGNED DEFAULT NULL,
  `start_date` bigint(20) UNSIGNED DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `coupons`
--

CREATE TABLE `coupons` (
  `id` int(10) UNSIGNED NOT NULL,
  `type` tinyint(3) UNSIGNED NOT NULL,
  `reward` int(10) UNSIGNED NOT NULL,
  `expires` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `coupon_uses`
--

CREATE TABLE `coupon_uses` (
  `coupon_id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) NOT NULL,
  `date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_anniversary_drops`
--

CREATE TABLE `datalog_anniversary_drops` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_bank_transactions`
--

CREATE TABLE `datalog_bank_transactions` (
  `action_id` tinyint(3) UNSIGNED NOT NULL,
  `sender` int(11) NOT NULL,
  `receiver` int(11) NOT NULL,
  `amount` int(10) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_boss_rewards`
--

CREATE TABLE `datalog_boss_rewards` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_boss_spawns`
--

CREATE TABLE `datalog_boss_spawns` (
  `world_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(500) NOT NULL,
  `posx` mediumint(8) UNSIGNED NOT NULL,
  `posy` mediumint(8) UNSIGNED NOT NULL,
  `posz` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `datalog_boss_spawns`
--

INSERT INTO `datalog_boss_spawns` (`world_id`, `name`, `posx`, `posy`, `posz`, `date`) VALUES
(1, 'Phyllo Terribil', 3694, 560, 8, 1596271188);

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_casino_token_bought`
--

CREATE TABLE `datalog_casino_token_bought` (
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `item_id` int(11) UNSIGNED NOT NULL,
  `count` tinyint(3) UNSIGNED NOT NULL,
  `tokens` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_caughts`
--

CREATE TABLE `datalog_caughts` (
  `player_id` int(11) NOT NULL,
  `pokemon_number` smallint(5) UNSIGNED NOT NULL,
  `tries` mediumint(8) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_christmas_drops`
--

CREATE TABLE `datalog_christmas_drops` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_coin_uses`
--

CREATE TABLE `datalog_coin_uses` (
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `use` tinyint(3) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_colosseum_arena`
--

CREATE TABLE `datalog_colosseum_arena` (
  `account_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_duel_bet`
--

CREATE TABLE `datalog_duel_bet` (
  `leader_a` int(11) NOT NULL,
  `leader_b` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `amount` mediumint(9) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_easter_drops`
--

CREATE TABLE `datalog_easter_drops` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_egg_generate`
--

CREATE TABLE `datalog_egg_generate` (
  `player_id` int(11) NOT NULL,
  `egg` varchar(100) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `tries` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_egg_move_generate`
--

CREATE TABLE `datalog_egg_move_generate` (
  `id` int(10) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `pokemon_name` varchar(255) NOT NULL,
  `pokemon_level` smallint(6) NOT NULL,
  `pokemon_extrapoints` smallint(6) NOT NULL,
  `egg_move` varchar(255) NOT NULL,
  `from_egg` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_egg_move_regenerate`
--

CREATE TABLE `datalog_egg_move_regenerate` (
  `id` int(10) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `pokemon_name` varchar(255) NOT NULL,
  `pokemon_level` smallint(6) NOT NULL,
  `pokemon_extrapoints` smallint(6) NOT NULL,
  `egg_move` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_halloween_drops`
--

CREATE TABLE `datalog_halloween_drops` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_julyvacation_drops`
--

CREATE TABLE `datalog_julyvacation_drops` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_logins`
--

CREATE TABLE `datalog_logins` (
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `ip` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `datalog_logins`
--

INSERT INTO `datalog_logins` (`player_id`, `date`, `ip`) VALUES
(91190, 1596262765, 16777343),
(91190, 1596262926, 16777343),
(91190, 1596263352, 16777343),
(91190, 1596270540, 16777343),
(91192, 1596271445, 16777343),
(91192, 1596271451, 16777343),
(91192, 1596271524, 16777343),
(91193, 1596271532, 16777343);

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_map_items`
--

CREATE TABLE `datalog_map_items` (
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  `date` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_mastery_token_bought`
--

CREATE TABLE `datalog_mastery_token_bought` (
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `item_id` int(11) UNSIGNED NOT NULL,
  `count` tinyint(3) UNSIGNED NOT NULL,
  `tokens` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_online`
--

CREATE TABLE `datalog_online` (
  `world_id` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `online` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `datalog_online`
--

INSERT INTO `datalog_online` (`world_id`, `date`, `online`) VALUES
(1, 1596270593, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_player_items`
--

CREATE TABLE `datalog_player_items` (
  `player_id` int(10) UNSIGNED NOT NULL,
  `on_logout_count` int(10) UNSIGNED DEFAULT NULL,
  `on_logout_date` bigint(20) UNSIGNED DEFAULT NULL,
  `on_login_count` int(11) DEFAULT NULL,
  `on_login_date` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `datalog_player_items`
--

INSERT INTO `datalog_player_items` (`player_id`, `on_logout_count`, `on_logout_date`, `on_login_count`, `on_login_date`) VALUES
(91190, 14, 1596262924, 14, 1596262926),
(91190, 17, 1596263350, 17, 1596263352),
(91190, 17, 1596263357, 17, 1596270540),
(91190, 101, 1596270860, NULL, NULL),
(91192, 14, 1596271450, 14, 1596271451),
(91192, 14, 1596271466, 14, 1596271524),
(91192, 14, 1596271530, NULL, NULL),
(91193, 14, 1596271544, NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_player_ups`
--

CREATE TABLE `datalog_player_ups` (
  `player_id` int(11) NOT NULL,
  `from_level` smallint(5) UNSIGNED NOT NULL,
  `to_level` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `posx` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `posy` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `posz` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_pokemon_market`
--

CREATE TABLE `datalog_pokemon_market` (
  `seller` int(11) NOT NULL DEFAULT 0,
  `buyer` int(11) NOT NULL DEFAULT 0,
  `date` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `ball_id` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  `value` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_pokemon_ups`
--

CREATE TABLE `datalog_pokemon_ups` (
  `player_id` int(11) NOT NULL,
  `pokemon_number` smallint(5) UNSIGNED NOT NULL,
  `from_level` smallint(5) UNSIGNED NOT NULL,
  `to_level` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `posx` int(10) NOT NULL DEFAULT 0,
  `posy` int(10) NOT NULL DEFAULT 0,
  `posz` int(10) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `datalog_pokemon_ups`
--

INSERT INTO `datalog_pokemon_ups` (`player_id`, `pokemon_number`, `from_level`, `to_level`, `date`, `posx`, `posy`, `posz`) VALUES
(91190, 6, 1, 2, 1596270732, 3308, 570, 7),
(91190, 6, 2, 3, 1596270737, 3308, 570, 7),
(91190, 6, 3, 4, 1596270796, 3308, 570, 7),
(91190, 6, 4, 5, 1596270797, 3308, 570, 7),
(91190, 6, 5, 6, 1596270798, 3308, 570, 7),
(91190, 6, 6, 7, 1596270805, 3308, 570, 7),
(91190, 6, 7, 8, 1596270810, 3308, 570, 7),
(91190, 6, 8, 9, 1596270819, 3306, 570, 7),
(91190, 6, 9, 10, 1596270821, 3305, 570, 7),
(91190, 6, 10, 11, 1596270822, 3305, 570, 7),
(91190, 6, 11, 12, 1596270822, 3305, 570, 7),
(91190, 6, 12, 13, 1596270823, 3305, 570, 7),
(91190, 6, 13, 14, 1596270824, 3305, 570, 7),
(91190, 6, 14, 15, 1596270825, 3305, 570, 7),
(91190, 6, 15, 16, 1596270826, 3305, 570, 7),
(91190, 6, 16, 17, 1596270827, 3305, 570, 7),
(91190, 6, 17, 18, 1596270828, 3305, 570, 7);

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_poketrader_boughts`
--

CREATE TABLE `datalog_poketrader_boughts` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `bid` int(10) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_poke_nick_change`
--

CREATE TABLE `datalog_poke_nick_change` (
  `player_id` int(11) NOT NULL,
  `old_nickname` varchar(100) DEFAULT NULL,
  `new_nickname` varchar(100) DEFAULT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_rangerclub_boss`
--

CREATE TABLE `datalog_rangerclub_boss` (
  `player_id` int(11) NOT NULL,
  `boss_id` mediumint(9) NOT NULL,
  `date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_rangerclub_boss_rewards`
--

CREATE TABLE `datalog_rangerclub_boss_rewards` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_rangerclub_task`
--

CREATE TABLE `datalog_rangerclub_task` (
  `player_id` int(11) NOT NULL,
  `task_id` mediumint(9) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_referral_exchange`
--

CREATE TABLE `datalog_referral_exchange` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_slot_machine`
--

CREATE TABLE `datalog_slot_machine` (
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `gain` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_surprise_box`
--

CREATE TABLE `datalog_surprise_box` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `datalog_token_bought`
--

CREATE TABLE `datalog_token_bought` (
  `date` bigint(20) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `use` tinyint(3) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `daycare_female`
--

CREATE TABLE `daycare_female` (
  `id` int(10) NOT NULL,
  `player_id` int(11) DEFAULT 0,
  `date` bigint(20) UNSIGNED DEFAULT NULL,
  `pokemon_name` varchar(100) DEFAULT NULL,
  `pokemon_level` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_experience` int(10) UNSIGNED DEFAULT 0,
  `pokemon_energy` mediumint(8) UNSIGNED DEFAULT 0,
  `pokemon_maxenergy` mediumint(8) UNSIGNED DEFAULT 0,
  `pokemon_nickname` varchar(100) DEFAULT NULL,
  `pokemon_sex` tinyint(3) UNSIGNED DEFAULT 0,
  `pokemon_extrapoints` smallint(5) UNSIGNED DEFAULT 0,
  `ball_id` smallint(5) UNSIGNED DEFAULT 12159,
  `max_training_minutes` int(10) UNSIGNED DEFAULT 2880,
  `pokemon_specialability` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm1` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm1_slot` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm2` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm2_slot` smallint(5) UNSIGNED DEFAULT 0,
  `ball_seal` smallint(5) UNSIGNED DEFAULT 0,
  `attributes` blob DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estrutura da tabela `daycare_male`
--

CREATE TABLE `daycare_male` (
  `id` int(10) NOT NULL,
  `player_id` int(11) DEFAULT 0,
  `date` bigint(20) UNSIGNED DEFAULT NULL,
  `pokemon_name` varchar(100) DEFAULT NULL,
  `pokemon_level` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_experience` int(10) UNSIGNED DEFAULT 0,
  `pokemon_energy` mediumint(8) UNSIGNED DEFAULT 0,
  `pokemon_maxenergy` mediumint(8) UNSIGNED DEFAULT 0,
  `pokemon_nickname` varchar(100) DEFAULT NULL,
  `pokemon_sex` tinyint(3) UNSIGNED DEFAULT 0,
  `pokemon_extrapoints` smallint(5) UNSIGNED DEFAULT 0,
  `ball_id` smallint(5) UNSIGNED DEFAULT 12159,
  `max_training_minutes` int(10) UNSIGNED DEFAULT 2880,
  `pokemon_specialability` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm1` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm1_slot` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm2` smallint(5) UNSIGNED DEFAULT 0,
  `pokemon_tm2_slot` smallint(5) UNSIGNED DEFAULT 0,
  `ball_seal` smallint(5) UNSIGNED DEFAULT 0,
  `attributes` blob DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Estrutura da tabela `daycare_plates`
--

CREATE TABLE `daycare_plates` (
  `player_id` int(11) NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `delete_players`
--

CREATE TABLE `delete_players` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `donates`
--

CREATE TABLE `donates` (
  `id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) DEFAULT NULL,
  `value` decimal(10,0) NOT NULL DEFAULT 0,
  `ref` varchar(500) NOT NULL DEFAULT '0',
  `date` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `egg_counter`
--

CREATE TABLE `egg_counter` (
  `player_id` int(10) UNSIGNED NOT NULL,
  `pokemon_id` smallint(5) UNSIGNED NOT NULL,
  `tries` mediumint(8) UNSIGNED DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `elite_four_champions`
--

CREATE TABLE `elite_four_champions` (
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `lookbody` smallint(5) UNSIGNED NOT NULL,
  `lookfeet` smallint(5) UNSIGNED NOT NULL,
  `lookhead` smallint(5) UNSIGNED NOT NULL,
  `looklegs` smallint(5) UNSIGNED NOT NULL,
  `looktype` smallint(5) UNSIGNED NOT NULL,
  `lookaddons` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='lookbody\r\nlookfeet\r\nlookhead\r\nlooklegs\r\nlooktype\r\nlookaddons';

-- --------------------------------------------------------

--
-- Estrutura da tabela `elite_four_champion_pokemons`
--

CREATE TABLE `elite_four_champion_pokemons` (
  `player_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `level` tinyint(3) UNSIGNED NOT NULL,
  `nickname` varchar(50) NOT NULL,
  `sex` tinyint(3) UNSIGNED NOT NULL,
  `extra_points` tinyint(3) UNSIGNED NOT NULL,
  `special_ability` smallint(5) UNSIGNED NOT NULL,
  `moveset` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `environment_killers`
--

CREATE TABLE `environment_killers` (
  `kill_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `global_storage`
--

CREATE TABLE `global_storage` (
  `key` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `value` varchar(255) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guilds`
--

CREATE TABLE `guilds` (
  `id` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `creationdata` int(11) NOT NULL,
  `motd` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `love_count` mediumint(8) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Acionadores `guilds`
--
DELIMITER $$
CREATE TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds` FOR EACH ROW BEGIN INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Leader', 3, NEW.`id`); INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Vice-Leader', 2, NEW.`id`); INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Member', 1, NEW.`id`); END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ondelete_guilds` BEFORE DELETE ON `guilds` FOR EACH ROW BEGIN
	UPDATE `players` SET `guildnick` = '', `rank_id` = 0 WHERE `rank_id` IN (SELECT `id` FROM `guild_ranks` WHERE `guild_id` = OLD.`id`);
	
	DELETE FROM `guild_ranks` WHERE `guild_ranks`.`guild_id` = OLD.`id`;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_invites`
--

CREATE TABLE `guild_invites` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `guild_id` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_loves`
--

CREATE TABLE `guild_loves` (
  `guild_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_ranks`
--

CREATE TABLE `guild_ranks` (
  `id` int(11) NOT NULL,
  `guild_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `level` int(11) NOT NULL COMMENT '1 - leader, 2 - vice leader, 3 - member'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `houses`
--

CREATE TABLE `houses` (
  `id` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `owner` int(11) NOT NULL,
  `paid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `warnings` int(11) NOT NULL DEFAULT 0,
  `lastwarning` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `town` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `price` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `rent` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `doors` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `beds` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `tiles` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `guild` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `clear` tinyint(1) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `houses`
--

INSERT INTO `houses` (`id`, `world_id`, `owner`, `paid`, `warnings`, `lastwarning`, `name`, `town`, `size`, `price`, `rent`, `doors`, `beds`, `tiles`, `guild`, `clear`) VALUES
(1, 0, 0, 0, 0, 0, 'Hamlin House #01', 11, 33, 2800, 2800, 2, 2, 56, 0, 0),
(1, 1, 0, 0, 0, 0, 'Hamlin House #01', 11, 33, 2800, 2800, 2, 2, 56, 0, 0),
(2, 0, 0, 0, 0, 0, 'Hamlin House #02', 11, 33, 2600, 2600, 2, 2, 52, 0, 0),
(2, 1, 0, 0, 0, 0, 'Hamlin House #02', 11, 33, 2600, 2600, 2, 2, 52, 0, 0),
(3, 0, 0, 0, 0, 0, 'Hamlin House #03', 11, 61, 4450, 4450, 4, 4, 89, 0, 0),
(3, 1, 0, 0, 0, 0, 'Hamlin House #03', 11, 61, 4450, 4450, 4, 4, 89, 0, 0),
(4, 0, 0, 0, 0, 0, 'Hamlin House #04', 11, 63, 5000, 5000, 2, 2, 100, 0, 0),
(4, 1, 0, 0, 0, 0, 'Hamlin House #04', 11, 63, 5000, 5000, 2, 2, 100, 0, 0),
(5, 0, 0, 0, 0, 0, 'Hamlin House #05', 11, 55, 4100, 4100, 2, 2, 82, 0, 0),
(5, 1, 0, 0, 0, 0, 'Hamlin House #05', 11, 55, 4100, 4100, 2, 2, 82, 0, 0),
(6, 0, 0, 0, 0, 0, 'Hamlin House #06', 11, 36, 2850, 2850, 2, 2, 57, 0, 0),
(6, 1, 0, 0, 0, 0, 'Hamlin House #06', 11, 36, 2850, 2850, 2, 2, 57, 0, 0),
(7, 0, 0, 0, 0, 0, 'Hamlin House #07', 11, 37, 3050, 3050, 2, 2, 61, 0, 0),
(7, 1, 0, 0, 0, 0, 'Hamlin House #07', 11, 37, 3050, 3050, 2, 2, 61, 0, 0),
(8, 0, 0, 0, 0, 0, 'Hamlin House #08', 11, 47, 3550, 3550, 2, 2, 71, 0, 0),
(8, 1, 0, 0, 0, 0, 'Hamlin House #08', 11, 47, 3550, 3550, 2, 2, 71, 0, 0),
(9, 0, 0, 0, 0, 0, 'Hamlin House #09', 11, 51, 4150, 4150, 2, 2, 83, 0, 0),
(9, 1, 0, 0, 0, 0, 'Hamlin House #09', 11, 51, 4150, 4150, 2, 2, 83, 0, 0),
(10, 0, 0, 0, 0, 0, 'Hamlin House #10', 11, 65, 5050, 5050, 3, 2, 101, 0, 0),
(10, 1, 0, 0, 0, 0, 'Hamlin House #10', 11, 65, 5050, 5050, 3, 2, 101, 0, 0),
(11, 0, 0, 0, 0, 0, 'Hamlin House #11', 11, 27, 2200, 2200, 2, 2, 44, 0, 0),
(11, 1, 0, 0, 0, 0, 'Hamlin House #11', 11, 27, 2200, 2200, 2, 2, 44, 0, 0),
(12, 0, 0, 0, 0, 0, 'Hamlin House #12', 11, 33, 2650, 2650, 2, 2, 53, 0, 0),
(12, 1, 0, 0, 0, 0, 'Hamlin House #12', 11, 33, 2650, 2650, 2, 2, 53, 0, 0),
(13, 0, 0, 0, 0, 0, 'Hamlin House #13', 11, 53, 4250, 4250, 2, 2, 85, 0, 0),
(13, 1, 0, 0, 0, 0, 'Hamlin House #13', 11, 53, 4250, 4250, 2, 2, 85, 0, 0),
(14, 0, 0, 0, 0, 0, 'Hamlin House #14', 11, 25, 2100, 2100, 2, 2, 42, 0, 0),
(14, 1, 0, 0, 0, 0, 'Hamlin House #14', 11, 25, 2100, 2100, 2, 2, 42, 0, 0),
(15, 0, 0, 0, 0, 0, 'Hamlin House #15', 11, 55, 4000, 4000, 2, 2, 80, 0, 0),
(15, 1, 0, 0, 0, 0, 'Hamlin House #15', 11, 55, 4000, 4000, 2, 2, 80, 0, 0),
(16, 0, 0, 0, 0, 0, 'Kumquat House #01', 12, 120, 9400, 9400, 2, 2, 188, 0, 0),
(16, 1, 0, 0, 0, 0, 'Kumquat House #01', 12, 120, 9400, 9400, 2, 2, 188, 0, 0),
(17, 0, 0, 0, 0, 0, 'Kumquat House #02', 12, 123, 8700, 8700, 3, 2, 174, 0, 0),
(17, 1, 0, 0, 0, 0, 'Kumquat House #02', 12, 123, 8700, 8700, 3, 2, 174, 0, 0),
(18, 0, 0, 0, 0, 0, 'Kumquat House #03', 12, 103, 7750, 7750, 3, 2, 155, 0, 0),
(18, 1, 0, 0, 0, 0, 'Kumquat House #03', 12, 103, 7750, 7750, 3, 2, 155, 0, 0),
(19, 0, 0, 0, 0, 0, 'Kumquat House #04', 12, 108, 7600, 7600, 2, 2, 152, 0, 0),
(19, 1, 0, 0, 0, 0, 'Kumquat House #04', 12, 108, 7600, 7600, 2, 2, 152, 0, 0),
(20, 0, 0, 0, 0, 0, 'Kumquat House #05', 12, 96, 7050, 7050, 2, 2, 141, 0, 0),
(20, 1, 0, 0, 0, 0, 'Kumquat House #05', 12, 96, 7050, 7050, 2, 2, 141, 0, 0),
(21, 0, 0, 0, 0, 0, 'Kumquat House #06', 12, 60, 4400, 4400, 2, 2, 88, 0, 0),
(21, 1, 0, 0, 0, 0, 'Kumquat House #06', 12, 60, 4400, 4400, 2, 2, 88, 0, 0),
(22, 0, 0, 0, 0, 0, 'Kumquat House #07', 12, 105, 7450, 7450, 3, 2, 149, 0, 0),
(22, 1, 0, 0, 0, 0, 'Kumquat House #07', 12, 105, 7450, 7450, 3, 2, 149, 0, 0),
(23, 0, 0, 0, 0, 0, 'Kumquat House #08', 12, 51, 3800, 3800, 2, 2, 76, 0, 0),
(23, 1, 0, 0, 0, 0, 'Kumquat House #08', 12, 51, 3800, 3800, 2, 2, 76, 0, 0),
(24, 0, 0, 0, 0, 0, 'Kumquat House #09', 12, 63, 4400, 4400, 2, 2, 88, 0, 0),
(24, 1, 0, 0, 0, 0, 'Kumquat House #09', 12, 63, 4400, 4400, 2, 2, 88, 0, 0),
(25, 0, 0, 0, 0, 0, 'Kumquat House #10', 12, 107, 7350, 7350, 3, 4, 147, 0, 0),
(25, 1, 0, 0, 0, 0, 'Kumquat House #10', 12, 107, 7350, 7350, 3, 4, 147, 0, 0),
(26, 0, 0, 0, 0, 0, 'Kumquat House #11', 12, 121, 8800, 8800, 5, 4, 176, 0, 0),
(26, 1, 0, 0, 0, 0, 'Kumquat House #11', 12, 121, 8800, 8800, 5, 4, 176, 0, 0),
(27, 0, 0, 0, 0, 0, 'Kumquat House #12', 12, 129, 9100, 9100, 2, 2, 182, 0, 0),
(27, 1, 0, 0, 0, 0, 'Kumquat House #12', 12, 129, 9100, 9100, 2, 2, 182, 0, 0),
(28, 0, 0, 0, 0, 0, 'Kumquat House #13', 12, 131, 8900, 8900, 3, 2, 178, 0, 0),
(28, 1, 0, 0, 0, 0, 'Kumquat House #13', 12, 131, 8900, 8900, 3, 2, 178, 0, 0),
(29, 0, 0, 0, 0, 0, 'Kumquat House #14', 12, 94, 6900, 6900, 2, 2, 138, 0, 0),
(29, 1, 0, 0, 0, 0, 'Kumquat House #14', 12, 94, 6900, 6900, 2, 2, 138, 0, 0),
(30, 0, 0, 0, 0, 0, 'Kumquat House #15', 12, 122, 8900, 8900, 3, 2, 178, 0, 0),
(30, 1, 0, 0, 0, 0, 'Kumquat House #15', 12, 122, 8900, 8900, 3, 2, 178, 0, 0),
(31, 0, 0, 0, 0, 0, 'Shamouti House #01', 14, 37, 2800, 2800, 2, 2, 56, 0, 0),
(31, 1, 0, 0, 0, 0, 'Shamouti House #01', 14, 37, 2800, 2800, 2, 2, 56, 0, 0),
(32, 0, 0, 0, 0, 0, 'Shamouti House #02', 14, 51, 4200, 4200, 3, 2, 84, 0, 0),
(32, 1, 0, 0, 0, 0, 'Shamouti House #02', 14, 51, 4200, 4200, 3, 2, 84, 0, 0),
(33, 0, 0, 0, 0, 0, 'Shamouti House #03', 14, 86, 6400, 6400, 3, 2, 128, 0, 0),
(33, 1, 0, 0, 0, 0, 'Shamouti House #03', 14, 86, 6400, 6400, 3, 2, 128, 0, 0),
(34, 0, 0, 0, 0, 0, 'Shamouti House #04', 14, 100, 6800, 6800, 3, 2, 136, 0, 0),
(34, 1, 0, 0, 0, 0, 'Shamouti House #04', 14, 100, 6800, 6800, 3, 2, 136, 0, 0),
(35, 0, 0, 0, 0, 0, 'Shamouti House #05', 14, 70, 5200, 5200, 3, 2, 104, 0, 0),
(35, 1, 0, 0, 0, 0, 'Shamouti House #05', 14, 70, 5200, 5200, 3, 2, 104, 0, 0),
(36, 0, 0, 0, 0, 0, 'Shamouti House #06', 14, 38, 3050, 3050, 2, 2, 61, 0, 0),
(36, 1, 0, 0, 0, 0, 'Shamouti House #06', 14, 38, 3050, 3050, 2, 2, 61, 0, 0),
(37, 0, 0, 0, 0, 0, 'Shamouti House #07', 14, 77, 5700, 5700, 2, 2, 114, 0, 0),
(37, 1, 0, 0, 0, 0, 'Shamouti House #07', 14, 77, 5700, 5700, 2, 2, 114, 0, 0),
(38, 0, 0, 0, 0, 0, 'Shamouti House #08', 14, 71, 5250, 5250, 2, 2, 105, 0, 0),
(38, 1, 0, 0, 0, 0, 'Shamouti House #08', 14, 71, 5250, 5250, 2, 2, 105, 0, 0),
(39, 0, 0, 0, 0, 0, 'Shamouti House #09', 14, 85, 6350, 6350, 2, 2, 127, 0, 0),
(39, 1, 0, 0, 0, 0, 'Shamouti House #09', 14, 85, 6350, 6350, 2, 2, 127, 0, 0),
(40, 0, 0, 0, 0, 0, 'Shamouti House #10', 14, 67, 5050, 5050, 3, 2, 101, 0, 0),
(40, 1, 0, 0, 0, 0, 'Shamouti House #10', 14, 67, 5050, 5050, 3, 2, 101, 0, 0),
(41, 0, 0, 0, 0, 0, 'Tarroco House #01', 28, 69, 5200, 5200, 1, 0, 104, 0, 0),
(41, 1, 0, 0, 0, 0, 'Tarroco House #01', 28, 69, 5200, 5200, 1, 0, 104, 0, 0),
(42, 0, 0, 0, 0, 0, 'Tarroco House #02', 28, 78, 5800, 5800, 1, 0, 116, 0, 0),
(42, 1, 0, 0, 0, 0, 'Tarroco House #02', 28, 78, 5800, 5800, 1, 0, 116, 0, 0),
(43, 0, 0, 0, 0, 0, 'Tarroco House #03', 28, 99, 7000, 7000, 3, 0, 140, 0, 0),
(43, 1, 0, 0, 0, 0, 'Tarroco House #03', 28, 99, 7000, 7000, 3, 0, 140, 0, 0),
(44, 0, 0, 0, 0, 0, 'Pummelo House #01', 13, 104, 7600, 7600, 3, 2, 152, 0, 0),
(44, 1, 0, 0, 0, 0, 'Pummelo House #01', 13, 104, 7600, 7600, 3, 2, 152, 0, 0),
(45, 0, 0, 0, 0, 0, 'Pummelo House #02', 13, 70, 5350, 5350, 3, 2, 107, 0, 0),
(45, 1, 0, 0, 0, 0, 'Pummelo House #02', 13, 70, 5350, 5350, 3, 2, 107, 0, 0),
(46, 0, 0, 0, 0, 0, 'Pummelo House #04', 13, 87, 5850, 5850, 2, 2, 117, 0, 0),
(46, 1, 0, 0, 0, 0, 'Pummelo House #04', 13, 87, 5850, 5850, 2, 2, 117, 0, 0),
(47, 0, 0, 0, 0, 0, 'Pummelo House #05', 13, 88, 6700, 6700, 3, 2, 134, 0, 0),
(47, 1, 0, 0, 0, 0, 'Pummelo House #05', 13, 88, 6700, 6700, 3, 2, 134, 0, 0),
(48, 0, 0, 0, 0, 0, 'Pummelo House #06', 13, 71, 5400, 5400, 3, 2, 108, 0, 0),
(48, 1, 0, 0, 0, 0, 'Pummelo House #06', 13, 71, 5400, 5400, 3, 2, 108, 0, 0),
(49, 0, 0, 0, 0, 0, 'Pummelo House #07', 13, 59, 4350, 4350, 2, 2, 87, 0, 0),
(49, 1, 0, 0, 0, 0, 'Pummelo House #07', 13, 59, 4350, 4350, 2, 2, 87, 0, 0),
(50, 0, 0, 0, 0, 0, 'Pummelo House #03', 13, 38, 3050, 3050, 2, 2, 61, 0, 0),
(50, 1, 0, 0, 0, 0, 'Pummelo House #03', 13, 38, 3050, 3050, 2, 2, 61, 0, 0),
(51, 0, 0, 0, 0, 0, 'Pummelo House #08', 13, 75, 5350, 5350, 2, 2, 107, 0, 0),
(51, 1, 0, 0, 0, 0, 'Pummelo House #08', 13, 75, 5350, 5350, 2, 2, 107, 0, 0),
(52, 0, 0, 0, 0, 0, 'Pummelo House #09', 13, 69, 5250, 5250, 2, 2, 105, 0, 0),
(52, 1, 0, 0, 0, 0, 'Pummelo House #09', 13, 69, 5250, 5250, 2, 2, 105, 0, 0),
(53, 0, 0, 0, 0, 0, 'Pummelo House #10', 13, 69, 4900, 4900, 2, 2, 98, 0, 0),
(53, 1, 0, 0, 0, 0, 'Pummelo House #10', 13, 69, 4900, 4900, 2, 2, 98, 0, 0),
(54, 0, 0, 0, 0, 0, 'Pummelo House #11', 13, 79, 6600, 6600, 3, 2, 132, 0, 0),
(54, 1, 0, 0, 0, 0, 'Pummelo House #11', 13, 79, 6600, 6600, 3, 2, 132, 0, 0),
(55, 0, 0, 0, 0, 0, 'Pummelo House #12', 13, 69, 5300, 5300, 2, 2, 106, 0, 0),
(55, 1, 0, 0, 0, 0, 'Pummelo House #12', 13, 69, 5300, 5300, 2, 2, 106, 0, 0),
(56, 0, 0, 0, 0, 0, 'Pummelo House #13', 13, 27, 2400, 2400, 2, 2, 48, 0, 0),
(56, 1, 0, 0, 0, 0, 'Pummelo House #13', 13, 27, 2400, 2400, 2, 2, 48, 0, 0),
(57, 0, 0, 0, 0, 0, 'Pummelo House #14', 13, 87, 6300, 6300, 3, 2, 126, 0, 0),
(57, 1, 0, 0, 0, 0, 'Pummelo House #14', 13, 87, 6300, 6300, 3, 2, 126, 0, 0),
(58, 0, 0, 0, 0, 0, 'Pummelo House #15', 13, 108, 7700, 7700, 2, 2, 154, 0, 0),
(58, 1, 0, 0, 0, 0, 'Pummelo House #15', 13, 108, 7700, 7700, 2, 2, 154, 0, 0),
(59, 0, 0, 0, 0, 0, 'Mandarin North Room #01', 26, 32, 2350, 2350, 1, 2, 47, 0, 0),
(59, 1, 0, 0, 0, 0, 'Mandarin North Room #01', 26, 32, 2350, 2350, 1, 2, 47, 0, 0),
(60, 0, 0, 0, 0, 0, 'Mandarin North Room #02', 26, 39, 2600, 2600, 1, 2, 52, 0, 0),
(60, 1, 0, 0, 0, 0, 'Mandarin North Room #02', 26, 39, 2600, 2600, 1, 2, 52, 0, 0),
(61, 0, 0, 0, 0, 0, 'Mandarin North Room #03', 26, 20, 1800, 1800, 1, 2, 36, 0, 0),
(61, 1, 0, 0, 0, 0, 'Mandarin North Room #03', 26, 20, 1800, 1800, 1, 2, 36, 0, 0),
(62, 0, 0, 0, 0, 0, 'Mandarin North Room #04', 26, 21, 1600, 1600, 1, 2, 32, 0, 0),
(62, 1, 0, 0, 0, 0, 'Mandarin North Room #04', 26, 21, 1600, 1600, 1, 2, 32, 0, 0),
(63, 0, 0, 0, 0, 0, 'Mandarin North Room #05', 26, 28, 1900, 1900, 1, 2, 38, 0, 0),
(63, 1, 0, 0, 0, 0, 'Mandarin North Room #05', 26, 28, 1900, 1900, 1, 2, 38, 0, 0),
(64, 0, 0, 0, 0, 0, 'Mandarin North Room #06', 26, 51, 3400, 3400, 1, 2, 68, 0, 0),
(64, 1, 0, 0, 0, 0, 'Mandarin North Room #06', 26, 51, 3400, 3400, 1, 2, 68, 0, 0),
(65, 0, 0, 0, 0, 0, 'Mandarin North House #01', 26, 75, 5300, 5300, 2, 2, 106, 0, 0),
(65, 1, 0, 0, 0, 0, 'Mandarin North House #01', 26, 75, 5300, 5300, 2, 2, 106, 0, 0),
(66, 0, 0, 0, 0, 0, 'Mandarin North House #02', 26, 48, 3650, 3650, 2, 2, 73, 0, 0),
(66, 1, 0, 0, 0, 0, 'Mandarin North House #02', 26, 48, 3650, 3650, 2, 2, 73, 0, 0),
(67, 0, 0, 0, 0, 0, 'Mandarin North House #03', 26, 69, 5200, 5200, 2, 2, 104, 0, 0),
(67, 1, 0, 0, 0, 0, 'Mandarin North House #03', 26, 69, 5200, 5200, 2, 2, 104, 0, 0),
(68, 0, 0, 0, 0, 0, 'Mandarin North House #04', 26, 58, 4150, 4150, 3, 2, 83, 0, 0),
(68, 1, 0, 0, 0, 0, 'Mandarin North House #04', 26, 58, 4150, 4150, 3, 2, 83, 0, 0),
(69, 0, 0, 0, 0, 0, 'Mandarin North House #05', 26, 58, 4400, 4400, 3, 2, 88, 0, 0),
(69, 1, 0, 0, 0, 0, 'Mandarin North House #05', 26, 58, 4400, 4400, 3, 2, 88, 0, 0),
(70, 0, 0, 0, 0, 0, 'Mandarin North House #06', 26, 80, 5600, 5600, 3, 2, 112, 0, 0),
(70, 1, 0, 0, 0, 0, 'Mandarin North House #06', 26, 80, 5600, 5600, 3, 2, 112, 0, 0),
(71, 0, 0, 0, 0, 0, 'Mandarin North House #07', 26, 36, 3300, 3300, 3, 4, 66, 0, 0),
(71, 1, 0, 0, 0, 0, 'Mandarin North House #07', 26, 36, 3300, 3300, 3, 4, 66, 0, 0),
(72, 0, 0, 0, 0, 0, 'Mandarin North House #08', 26, 82, 5500, 5500, 1, 2, 110, 0, 0),
(72, 1, 0, 0, 0, 0, 'Mandarin North House #08', 26, 82, 5500, 5500, 1, 2, 110, 0, 0),
(73, 0, 0, 0, 0, 0, 'Mandarin North House #09', 26, 31, 2550, 2550, 2, 2, 51, 0, 0),
(73, 1, 0, 0, 0, 0, 'Mandarin North House #09', 26, 31, 2550, 2550, 2, 2, 51, 0, 0),
(74, 0, 0, 0, 0, 0, 'Mikan Room #01', 25, 16, 1400, 1400, 1, 2, 28, 0, 0),
(74, 1, 0, 0, 0, 0, 'Mikan Room #01', 25, 16, 1400, 1400, 1, 2, 28, 0, 0),
(75, 0, 0, 0, 0, 0, 'Mikan Room #02', 25, 16, 1200, 1200, 1, 2, 24, 0, 0),
(75, 1, 0, 0, 0, 0, 'Mikan Room #02', 25, 16, 1200, 1200, 1, 2, 24, 0, 0),
(76, 0, 0, 0, 0, 0, 'Mikan Room #03', 25, 33, 2250, 2250, 1, 2, 45, 0, 0),
(76, 1, 0, 0, 0, 0, 'Mikan Room #03', 25, 33, 2250, 2250, 1, 2, 45, 0, 0),
(77, 0, 0, 0, 0, 0, 'Mikan House #01', 25, 60, 4400, 4400, 4, 4, 88, 0, 0),
(77, 1, 0, 0, 0, 0, 'Mikan House #01', 25, 60, 4400, 4400, 4, 4, 88, 0, 0),
(78, 0, 0, 0, 0, 0, 'Mikan House #02', 25, 85, 6000, 6000, 2, 2, 120, 0, 0),
(78, 1, 0, 0, 0, 0, 'Mikan House #02', 25, 85, 6000, 6000, 2, 2, 120, 0, 0),
(79, 0, 0, 0, 0, 0, 'Mikan House #03', 25, 63, 4650, 4650, 2, 2, 93, 0, 0),
(79, 1, 0, 0, 0, 0, 'Mikan House #03', 25, 63, 4650, 4650, 2, 2, 93, 0, 0),
(80, 0, 0, 0, 0, 0, 'Mikan House #04', 25, 76, 5050, 5050, 1, 2, 101, 0, 0),
(80, 1, 0, 0, 0, 0, 'Mikan House #04', 25, 76, 5050, 5050, 1, 2, 101, 0, 0),
(81, 0, 0, 0, 0, 0, 'Mikan House #05', 25, 27, 2400, 2400, 2, 2, 48, 0, 0),
(81, 1, 0, 0, 0, 0, 'Mikan House #05', 25, 27, 2400, 2400, 2, 2, 48, 0, 0),
(82, 0, 0, 0, 0, 0, 'Mikan House #06', 25, 56, 4450, 4450, 3, 2, 89, 0, 0),
(82, 1, 0, 0, 0, 0, 'Mikan House #06', 25, 56, 4450, 4450, 3, 2, 89, 0, 0),
(83, 0, 0, 0, 0, 0, 'Mikan House #07', 25, 94, 6750, 6750, 3, 2, 135, 0, 0),
(83, 1, 0, 0, 0, 0, 'Mikan House #07', 25, 94, 6750, 6750, 3, 2, 135, 0, 0),
(84, 0, 0, 0, 0, 0, 'Mikan House #08', 25, 53, 4450, 4450, 3, 4, 89, 0, 0),
(84, 1, 0, 0, 0, 0, 'Mikan House #08', 25, 53, 4450, 4450, 3, 4, 89, 0, 0),
(85, 0, 0, 0, 0, 0, 'Sunburst House #01', 24, 30, 2450, 2450, 1, 2, 49, 0, 0),
(85, 1, 0, 0, 0, 0, 'Sunburst House #01', 24, 30, 2450, 2450, 1, 2, 49, 0, 0),
(86, 0, 0, 0, 0, 0, 'Sunburst House #02', 24, 33, 2750, 2750, 2, 2, 55, 0, 0),
(86, 1, 0, 0, 0, 0, 'Sunburst House #02', 24, 33, 2750, 2750, 2, 2, 55, 0, 0),
(87, 0, 0, 0, 0, 0, 'Sunburst House #03', 24, 18, 1450, 1450, 1, 2, 29, 0, 0),
(87, 1, 0, 0, 0, 0, 'Sunburst House #03', 24, 18, 1450, 1450, 1, 2, 29, 0, 0),
(88, 0, 0, 0, 0, 0, 'Sunburst House #04', 24, 41, 3200, 3200, 2, 2, 64, 0, 0),
(88, 1, 0, 0, 0, 0, 'Sunburst House #04', 24, 41, 3200, 3200, 2, 2, 64, 0, 0),
(89, 0, 0, 0, 0, 0, 'Sunburst House #05', 24, 38, 3050, 3050, 2, 2, 61, 0, 0),
(89, 1, 0, 0, 0, 0, 'Sunburst House #05', 24, 38, 3050, 3050, 2, 2, 61, 0, 0),
(90, 0, 0, 0, 0, 0, 'Tangelo House #01', 23, 42, 3550, 3550, 1, 2, 71, 0, 0),
(90, 1, 0, 0, 0, 0, 'Tangelo House #01', 23, 42, 3550, 3550, 1, 2, 71, 0, 0),
(91, 0, 0, 0, 0, 0, 'Tangelo House #02', 23, 67, 5500, 5500, 1, 2, 110, 0, 0),
(91, 1, 0, 0, 0, 0, 'Tangelo House #02', 23, 67, 5500, 5500, 1, 2, 110, 0, 0),
(92, 0, 0, 0, 0, 0, 'Tangelo House #03', 23, 49, 3900, 3900, 1, 2, 78, 0, 0),
(92, 1, 0, 0, 0, 0, 'Tangelo House #03', 23, 49, 3900, 3900, 1, 2, 78, 0, 0),
(93, 0, 0, 0, 0, 0, 'Tangelo House #04', 23, 54, 4100, 4100, 2, 2, 82, 0, 0),
(93, 1, 0, 0, 0, 0, 'Tangelo House #04', 23, 54, 4100, 4100, 2, 2, 82, 0, 0),
(94, 0, 0, 0, 0, 0, 'Tangelo House #05', 23, 26, 2300, 2300, 1, 2, 46, 0, 0),
(94, 1, 0, 0, 0, 0, 'Tangelo House #05', 23, 26, 2300, 2300, 1, 2, 46, 0, 0),
(95, 0, 0, 0, 0, 0, 'Tangelo House #06', 23, 39, 2900, 2900, 2, 2, 58, 0, 0),
(95, 1, 0, 0, 0, 0, 'Tangelo House #06', 23, 39, 2900, 2900, 2, 2, 58, 0, 0),
(96, 0, 0, 0, 0, 0, 'Tangelo House #07', 23, 69, 5150, 5150, 2, 2, 103, 0, 0),
(96, 1, 0, 0, 0, 0, 'Tangelo House #07', 23, 69, 5150, 5150, 2, 2, 103, 0, 0),
(97, 0, 0, 0, 0, 0, 'Butwal House #01', 15, 91, 6600, 6600, 3, 2, 132, 0, 0),
(97, 1, 0, 0, 0, 0, 'Butwal House #01', 15, 91, 6600, 6600, 3, 2, 132, 0, 0),
(98, 0, 0, 0, 0, 0, 'Butwal House #02', 15, 77, 5550, 5550, 2, 2, 111, 0, 0),
(98, 1, 0, 0, 0, 0, 'Butwal House #02', 15, 77, 5550, 5550, 2, 2, 111, 0, 0),
(99, 0, 0, 0, 0, 0, 'Butwal House #03', 15, 90, 6200, 6200, 3, 2, 124, 0, 0),
(99, 1, 0, 0, 0, 0, 'Butwal House #03', 15, 90, 6200, 6200, 3, 2, 124, 0, 0),
(100, 0, 0, 0, 0, 0, 'Butwal House #04', 15, 63, 4950, 4950, 3, 2, 99, 0, 0),
(100, 1, 0, 0, 0, 0, 'Butwal House #04', 15, 63, 4950, 4950, 3, 2, 99, 0, 0),
(101, 0, 0, 0, 0, 0, 'Ascorbia House #01', 16, 63, 4900, 4900, 2, 2, 98, 0, 0),
(101, 1, 0, 0, 0, 0, 'Ascorbia House #01', 16, 63, 4900, 4900, 2, 2, 98, 0, 0),
(102, 0, 0, 0, 0, 0, 'Ascorbia House #02', 16, 77, 5800, 5800, 2, 2, 116, 0, 0),
(102, 1, 0, 0, 0, 0, 'Ascorbia House #02', 16, 77, 5800, 5800, 2, 2, 116, 0, 0),
(103, 0, 0, 0, 0, 0, 'Ascorbia House #03', 16, 64, 4750, 4750, 2, 2, 95, 0, 0),
(103, 1, 0, 0, 0, 0, 'Ascorbia House #03', 16, 64, 4750, 4750, 2, 2, 95, 0, 0),
(104, 0, 0, 0, 0, 0, 'Ascorbia House #04', 16, 79, 6200, 6200, 2, 2, 124, 0, 0),
(104, 1, 0, 0, 0, 0, 'Ascorbia House #04', 16, 79, 6200, 6200, 2, 2, 124, 0, 0),
(105, 0, 0, 0, 0, 0, 'Ascorbia House #05', 16, 87, 7050, 7050, 3, 4, 141, 0, 0),
(105, 1, 0, 0, 0, 0, 'Ascorbia House #05', 16, 87, 7050, 7050, 3, 4, 141, 0, 0),
(106, 0, 0, 0, 0, 0, 'Ascorbia House #06', 16, 86, 6550, 6550, 2, 2, 131, 0, 0),
(106, 1, 0, 0, 0, 0, 'Ascorbia House #06', 16, 86, 6550, 6550, 2, 2, 131, 0, 0),
(107, 0, 0, 0, 0, 0, 'Ascorbia House #07', 16, 48, 3650, 3650, 2, 2, 73, 0, 0),
(107, 1, 0, 0, 0, 0, 'Ascorbia House #07', 16, 48, 3650, 3650, 2, 2, 73, 0, 0),
(108, 0, 0, 0, 0, 0, 'Ascorbia House #08', 16, 74, 5600, 5600, 2, 2, 112, 0, 0),
(108, 1, 0, 0, 0, 0, 'Ascorbia House #08', 16, 74, 5600, 5600, 2, 2, 112, 0, 0),
(109, 0, 0, 0, 0, 0, 'Ascorbia House #09', 16, 66, 4800, 4800, 2, 2, 96, 0, 0),
(109, 1, 0, 0, 0, 0, 'Ascorbia House #09', 16, 66, 4800, 4800, 2, 2, 96, 0, 0),
(110, 0, 0, 0, 0, 0, 'Ascorbia House #10', 16, 43, 3300, 3300, 2, 2, 66, 0, 0),
(110, 1, 0, 0, 0, 0, 'Ascorbia House #10', 16, 43, 3300, 3300, 2, 2, 66, 0, 0),
(111, 0, 0, 0, 0, 0, 'Ascorbia House #11', 16, 75, 5500, 5500, 2, 2, 110, 0, 0),
(111, 1, 0, 0, 0, 0, 'Ascorbia House #11', 16, 75, 5500, 5500, 2, 2, 110, 0, 0),
(112, 0, 0, 0, 0, 0, 'Ascorbia House #12', 16, 79, 5400, 5400, 2, 2, 108, 0, 0),
(112, 1, 0, 0, 0, 0, 'Ascorbia House #12', 16, 79, 5400, 5400, 2, 2, 108, 0, 0),
(113, 0, 0, 0, 0, 0, 'Seven Grapefruit House #01', 18, 49, 3900, 3900, 3, 2, 78, 0, 0),
(113, 1, 0, 0, 0, 0, 'Seven Grapefruit House #01', 18, 49, 3900, 3900, 3, 2, 78, 0, 0),
(114, 0, 0, 0, 0, 0, 'Seven Grapefruit House #02', 18, 55, 4300, 4300, 3, 2, 86, 0, 0),
(114, 1, 0, 0, 0, 0, 'Seven Grapefruit House #02', 18, 55, 4300, 4300, 3, 2, 86, 0, 0),
(115, 0, 0, 0, 0, 0, 'Seven Grapefruit House #03', 18, 53, 3800, 3800, 3, 2, 76, 0, 0),
(115, 1, 0, 0, 0, 0, 'Seven Grapefruit House #03', 18, 53, 3800, 3800, 3, 2, 76, 0, 0),
(116, 0, 0, 0, 0, 0, 'Seven Grapefruit House #04', 18, 31, 2650, 2650, 1, 2, 53, 0, 0),
(116, 1, 0, 0, 0, 0, 'Seven Grapefruit House #04', 18, 31, 2650, 2650, 1, 2, 53, 0, 0),
(117, 0, 0, 0, 0, 0, 'Seven Grapefruit House #05', 18, 64, 5350, 5350, 2, 2, 107, 0, 0),
(117, 1, 0, 0, 0, 0, 'Seven Grapefruit House #05', 18, 64, 5350, 5350, 2, 2, 107, 0, 0),
(118, 0, 0, 0, 0, 0, 'Seven Grapefruit House #06', 18, 36, 2900, 2900, 2, 2, 58, 0, 0),
(118, 1, 0, 0, 0, 0, 'Seven Grapefruit House #06', 18, 36, 2900, 2900, 2, 2, 58, 0, 0),
(119, 0, 0, 0, 0, 0, 'Seven Grapefruit House #07', 18, 99, 6900, 6900, 2, 2, 138, 0, 0),
(119, 1, 0, 0, 0, 0, 'Seven Grapefruit House #07', 18, 99, 6900, 6900, 2, 2, 138, 0, 0),
(120, 0, 0, 0, 0, 0, 'Seven Grapefruit House #08', 18, 40, 3000, 3000, 2, 2, 60, 0, 0),
(120, 1, 0, 0, 0, 0, 'Seven Grapefruit House #08', 18, 40, 3000, 3000, 2, 2, 60, 0, 0),
(121, 0, 0, 0, 0, 0, 'Seven Grapefruit House #09', 18, 69, 5250, 5250, 3, 2, 105, 0, 0),
(121, 1, 0, 0, 0, 0, 'Seven Grapefruit House #09', 18, 69, 5250, 5250, 3, 2, 105, 0, 0),
(122, 0, 0, 0, 0, 0, 'Seven Grapefruit House #10', 18, 39, 3100, 3100, 2, 2, 62, 0, 0),
(122, 1, 0, 0, 0, 0, 'Seven Grapefruit House #10', 18, 39, 3100, 3100, 2, 2, 62, 0, 0),
(123, 0, 0, 0, 0, 0, 'Moro House #01', 19, 32, 2550, 2550, 4, 2, 51, 0, 0),
(123, 1, 0, 0, 0, 0, 'Moro House #01', 19, 32, 2550, 2550, 4, 2, 51, 0, 0),
(124, 0, 0, 0, 0, 0, 'Moro House #02', 19, 30, 2600, 2600, 2, 2, 52, 0, 0),
(124, 1, 0, 0, 0, 0, 'Moro House #02', 19, 30, 2600, 2600, 2, 2, 52, 0, 0),
(125, 0, 0, 0, 0, 0, 'Moro House #03', 19, 10, 900, 900, 1, 2, 18, 0, 0),
(125, 1, 0, 0, 0, 0, 'Moro House #03', 19, 10, 900, 900, 1, 2, 18, 0, 0),
(126, 0, 0, 0, 0, 0, 'Moro House #04', 19, 10, 950, 950, 1, 2, 19, 0, 0),
(126, 1, 0, 0, 0, 0, 'Moro House #04', 19, 10, 950, 950, 1, 2, 19, 0, 0),
(127, 0, 0, 0, 0, 0, 'Moro House #05', 19, 10, 950, 950, 1, 2, 19, 0, 0),
(127, 1, 0, 0, 0, 0, 'Moro House #05', 19, 10, 950, 950, 1, 2, 19, 0, 0),
(128, 0, 0, 0, 0, 0, 'Moro House #06', 19, 43, 3400, 3400, 2, 2, 68, 0, 0),
(128, 1, 0, 0, 0, 0, 'Moro House #06', 19, 43, 3400, 3400, 2, 2, 68, 0, 0),
(129, 0, 0, 0, 0, 0, 'Moro House #07', 19, 73, 5400, 5400, 2, 2, 108, 0, 0),
(129, 1, 0, 0, 0, 0, 'Moro House #07', 19, 73, 5400, 5400, 2, 2, 108, 0, 0),
(130, 0, 0, 0, 0, 0, 'Moro House #08', 19, 52, 3900, 3900, 2, 2, 78, 0, 0),
(130, 1, 0, 0, 0, 0, 'Moro House #08', 19, 52, 3900, 3900, 2, 2, 78, 0, 0),
(131, 0, 0, 0, 0, 0, 'Moro House #09', 19, 48, 3750, 3750, 3, 2, 75, 0, 0),
(131, 1, 0, 0, 0, 0, 'Moro House #09', 19, 48, 3750, 3750, 3, 2, 75, 0, 0),
(132, 0, 0, 0, 0, 0, 'Moro House #10', 19, 61, 4600, 4600, 2, 2, 92, 0, 0),
(132, 1, 0, 0, 0, 0, 'Moro House #10', 19, 61, 4600, 4600, 2, 2, 92, 0, 0),
(133, 0, 0, 0, 0, 0, 'Moro House #11', 19, 63, 4900, 4900, 2, 2, 98, 0, 0),
(133, 1, 0, 0, 0, 0, 'Moro House #11', 19, 63, 4900, 4900, 2, 2, 98, 0, 0),
(134, 0, 0, 0, 0, 0, 'Moro House #12', 19, 62, 4900, 4900, 3, 4, 98, 0, 0),
(134, 1, 0, 0, 0, 0, 'Moro House #12', 19, 62, 4900, 4900, 3, 4, 98, 0, 0),
(135, 0, 0, 0, 0, 0, 'Moro House #13', 19, 37, 3250, 3250, 2, 2, 65, 0, 0),
(135, 1, 0, 0, 0, 0, 'Moro House #13', 19, 37, 3250, 3250, 2, 2, 65, 0, 0),
(136, 0, 0, 0, 0, 0, 'Murcott House #01', 20, 56, 4200, 4200, 2, 2, 84, 0, 0),
(136, 1, 0, 0, 0, 0, 'Murcott House #01', 20, 56, 4200, 4200, 2, 2, 84, 0, 0),
(137, 0, 0, 0, 0, 0, 'Murcott House #02', 20, 38, 2850, 2850, 2, 2, 57, 0, 0),
(137, 1, 0, 0, 0, 0, 'Murcott House #02', 20, 38, 2850, 2850, 2, 2, 57, 0, 0),
(138, 0, 0, 0, 0, 0, 'Murcott House #03', 20, 55, 4050, 4050, 2, 2, 81, 0, 0),
(138, 1, 0, 0, 0, 0, 'Murcott House #03', 20, 55, 4050, 4050, 2, 2, 81, 0, 0),
(139, 0, 0, 0, 0, 0, 'Murcott House #04', 20, 109, 6650, 6650, 2, 2, 133, 0, 0),
(139, 1, 0, 0, 0, 0, 'Murcott House #04', 20, 109, 6650, 6650, 2, 2, 133, 0, 0),
(140, 0, 0, 0, 0, 0, 'Murcott House #05', 20, 69, 5250, 5250, 2, 2, 105, 0, 0),
(140, 1, 0, 0, 0, 0, 'Murcott House #05', 20, 69, 5250, 5250, 2, 2, 105, 0, 0),
(141, 0, 0, 0, 0, 0, 'Murcott House #06', 20, 81, 6150, 6150, 2, 4, 123, 0, 0),
(141, 1, 0, 0, 0, 0, 'Murcott House #06', 20, 81, 6150, 6150, 2, 4, 123, 0, 0),
(142, 0, 0, 0, 0, 0, 'Murcott House #07', 20, 91, 6450, 6450, 2, 2, 129, 0, 0),
(142, 1, 0, 0, 0, 0, 'Murcott House #07', 20, 91, 6450, 6450, 2, 2, 129, 0, 0),
(143, 0, 0, 0, 0, 0, 'Murcott House #08', 20, 76, 5300, 5300, 2, 2, 106, 0, 0),
(143, 1, 0, 0, 0, 0, 'Murcott House #08', 20, 76, 5300, 5300, 2, 2, 106, 0, 0),
(144, 0, 0, 0, 0, 0, 'Murcott House #09', 20, 45, 3500, 3500, 2, 2, 70, 0, 0),
(144, 1, 0, 0, 0, 0, 'Murcott House #09', 20, 45, 3500, 3500, 2, 2, 70, 0, 0),
(145, 0, 0, 0, 0, 0, 'Murcott House #10', 20, 73, 4950, 4950, 2, 2, 99, 0, 0),
(145, 1, 0, 0, 0, 0, 'Murcott House #10', 20, 73, 4950, 4950, 2, 2, 99, 0, 0),
(146, 0, 0, 0, 0, 0, 'Murcott Room #01', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(146, 1, 0, 0, 0, 0, 'Murcott Room #01', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(147, 0, 0, 0, 0, 0, 'Murcott Room #02', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(147, 1, 0, 0, 0, 0, 'Murcott Room #02', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(148, 0, 0, 0, 0, 0, 'Murcott Room #03', 20, 18, 1350, 1350, 1, 2, 27, 0, 0),
(148, 1, 0, 0, 0, 0, 'Murcott Room #03', 20, 18, 1350, 1350, 1, 2, 27, 0, 0),
(149, 0, 0, 0, 0, 0, 'Murcott Room #04', 20, 14, 1150, 1150, 1, 2, 23, 0, 0),
(149, 1, 0, 0, 0, 0, 'Murcott Room #04', 20, 14, 1150, 1150, 1, 2, 23, 0, 0),
(150, 0, 0, 0, 0, 0, 'Murcott Room #05', 20, 14, 1150, 1150, 1, 2, 23, 0, 0),
(150, 1, 0, 0, 0, 0, 'Murcott Room #05', 20, 14, 1150, 1150, 1, 2, 23, 0, 0),
(151, 0, 0, 0, 0, 0, 'Murcott Room #06', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(151, 1, 0, 0, 0, 0, 'Murcott Room #06', 20, 18, 1450, 1450, 1, 2, 29, 0, 0),
(152, 0, 0, 0, 0, 0, 'Trovitopolis House #01', 29, 43, 3350, 3350, 2, 2, 67, 0, 0),
(152, 1, 0, 0, 0, 0, 'Trovitopolis House #01', 29, 43, 3350, 3350, 2, 2, 67, 0, 0),
(153, 0, 0, 0, 0, 0, 'Trovitopolis House #02', 29, 36, 3150, 3150, 3, 4, 63, 0, 0),
(153, 1, 0, 0, 0, 0, 'Trovitopolis House #02', 29, 36, 3150, 3150, 3, 4, 63, 0, 0),
(154, 0, 0, 0, 0, 0, 'Trovitopolis House #03', 29, 91, 6750, 6750, 3, 2, 135, 0, 0),
(154, 1, 0, 0, 0, 0, 'Trovitopolis House #03', 29, 91, 6750, 6750, 3, 2, 135, 0, 0),
(155, 0, 0, 0, 0, 0, 'Trovitopolis House #04', 29, 90, 6600, 6600, 2, 2, 132, 0, 0),
(155, 1, 0, 0, 0, 0, 'Trovitopolis House #04', 29, 90, 6600, 6600, 2, 2, 132, 0, 0),
(156, 0, 0, 0, 0, 0, 'Trovitopolis House #05', 29, 107, 7300, 7300, 3, 2, 146, 0, 0),
(156, 1, 0, 0, 0, 0, 'Trovitopolis House #05', 29, 107, 7300, 7300, 3, 2, 146, 0, 0),
(157, 0, 0, 0, 0, 0, 'Trovitopolis House #06', 29, 76, 5900, 5900, 3, 4, 118, 0, 0),
(157, 1, 0, 0, 0, 0, 'Trovitopolis House #06', 29, 76, 5900, 5900, 3, 4, 118, 0, 0),
(158, 0, 0, 0, 0, 0, 'Trovitopolis House #07', 29, 51, 3750, 3750, 2, 2, 75, 0, 0),
(158, 1, 0, 0, 0, 0, 'Trovitopolis House #07', 29, 51, 3750, 3750, 2, 2, 75, 0, 0),
(159, 0, 0, 0, 0, 0, 'Trovitopolis House #08', 29, 40, 2650, 2650, 1, 2, 53, 0, 0),
(159, 1, 0, 0, 0, 0, 'Trovitopolis House #08', 29, 40, 2650, 2650, 1, 2, 53, 0, 0),
(160, 0, 0, 0, 0, 0, 'Trovitopolis Room #01', 29, 18, 1500, 1500, 1, 2, 30, 0, 0),
(160, 1, 0, 0, 0, 0, 'Trovitopolis Room #01', 29, 18, 1500, 1500, 1, 2, 30, 0, 0),
(161, 0, 0, 0, 0, 0, 'Trovitopolis Room #02', 29, 18, 1450, 1450, 1, 2, 29, 0, 0),
(161, 1, 0, 0, 0, 0, 'Trovitopolis Room #02', 29, 18, 1450, 1450, 1, 2, 29, 0, 0),
(162, 0, 0, 0, 0, 0, 'Trovitopolis Room #03', 29, 18, 1350, 1350, 1, 2, 27, 0, 0),
(162, 1, 0, 0, 0, 0, 'Trovitopolis Room #03', 29, 18, 1350, 1350, 1, 2, 27, 0, 0),
(163, 0, 0, 0, 0, 0, 'Trovitopolis Room #04', 29, 26, 1900, 1900, 1, 2, 38, 0, 0),
(163, 1, 0, 0, 0, 0, 'Trovitopolis Room #04', 29, 26, 1900, 1900, 1, 2, 38, 0, 0),
(164, 0, 0, 0, 0, 0, 'Trovitopolis Room #05', 29, 18, 1500, 1500, 1, 2, 30, 0, 0),
(164, 1, 0, 0, 0, 0, 'Trovitopolis Room #05', 29, 18, 1500, 1500, 1, 2, 30, 0, 0),
(165, 0, 0, 0, 0, 0, 'Trovitopolis Room #06', 29, 26, 2100, 2100, 1, 2, 42, 0, 0),
(165, 1, 0, 0, 0, 0, 'Trovitopolis Room #06', 29, 26, 2100, 2100, 1, 2, 42, 0, 0),
(166, 0, 0, 0, 0, 0, 'Trovitopolis Room #07', 29, 26, 1850, 1850, 1, 2, 37, 0, 0),
(166, 1, 0, 0, 0, 0, 'Trovitopolis Room #07', 29, 26, 1850, 1850, 1, 2, 37, 0, 0),
(167, 0, 0, 0, 0, 0, 'Trovitopolis Room #08', 29, 26, 1850, 1850, 1, 2, 37, 0, 0),
(167, 1, 0, 0, 0, 0, 'Trovitopolis Room #08', 29, 26, 1850, 1850, 1, 2, 37, 0, 0),
(168, 0, 0, 0, 0, 0, 'Trovitopolis Room #09', 29, 10, 1050, 1050, 1, 2, 21, 0, 0),
(168, 1, 0, 0, 0, 0, 'Trovitopolis Room #09', 29, 10, 1050, 1050, 1, 2, 21, 0, 0),
(169, 0, 0, 0, 0, 0, 'Mandarin South House #01', 31, 65, 5000, 5000, 4, 2, 100, 0, 0),
(169, 1, 0, 0, 0, 0, 'Mandarin South House #01', 31, 65, 5000, 5000, 4, 2, 100, 0, 0),
(170, 0, 0, 0, 0, 0, 'Mandarin South House #02', 31, 42, 3400, 3400, 2, 2, 68, 0, 0),
(170, 1, 0, 0, 0, 0, 'Mandarin South House #02', 31, 42, 3400, 3400, 2, 2, 68, 0, 0),
(171, 0, 0, 0, 0, 0, 'Mandarin South House #03', 31, 27, 2450, 2450, 2, 2, 49, 0, 0),
(171, 1, 0, 0, 0, 0, 'Mandarin South House #03', 31, 27, 2450, 2450, 2, 2, 49, 0, 0),
(172, 0, 0, 0, 0, 0, 'Mandarin South House #04', 31, 63, 4750, 4750, 2, 2, 95, 0, 0),
(172, 1, 0, 0, 0, 0, 'Mandarin South House #04', 31, 63, 4750, 4750, 2, 2, 95, 0, 0),
(173, 0, 0, 0, 0, 0, 'Mandarin South House #05', 31, 40, 2950, 2950, 2, 2, 59, 0, 0),
(173, 1, 0, 0, 0, 0, 'Mandarin South House #05', 31, 40, 2950, 2950, 2, 2, 59, 0, 0),
(174, 0, 0, 0, 0, 0, 'Mandarin South House #06', 31, 32, 2650, 2650, 2, 2, 53, 0, 0),
(174, 1, 0, 0, 0, 0, 'Mandarin South House #06', 31, 32, 2650, 2650, 2, 2, 53, 0, 0),
(175, 0, 0, 0, 0, 0, 'Mandarin South House #07', 31, 32, 2600, 2600, 2, 2, 52, 0, 0),
(175, 1, 0, 0, 0, 0, 'Mandarin South House #07', 31, 32, 2600, 2600, 2, 2, 52, 0, 0),
(176, 0, 0, 0, 0, 0, 'Mandarin South House #001', 30, 50, 3750, 3750, 2, 2, 75, 0, 0),
(176, 1, 0, 0, 0, 0, 'Mandarin South House #001', 30, 50, 3750, 3750, 2, 2, 75, 0, 0),
(177, 0, 0, 0, 0, 0, 'Mandarin South House #002', 30, 75, 5350, 5350, 2, 2, 107, 0, 0),
(177, 1, 0, 0, 0, 0, 'Mandarin South House #002', 30, 75, 5350, 5350, 2, 2, 107, 0, 0),
(178, 0, 0, 0, 0, 0, 'Mandarin South House #003', 30, 82, 6100, 6100, 2, 2, 122, 0, 0),
(178, 1, 0, 0, 0, 0, 'Mandarin South House #003', 30, 82, 6100, 6100, 2, 2, 122, 0, 0),
(179, 0, 0, 0, 0, 0, 'Mandarin South House #004', 30, 76, 6200, 6200, 4, 4, 124, 0, 0),
(179, 1, 0, 0, 0, 0, 'Mandarin South House #004', 30, 76, 6200, 6200, 4, 4, 124, 0, 0),
(180, 0, 0, 0, 0, 0, 'Mandarin South House #005', 30, 96, 7100, 7100, 2, 2, 142, 0, 0),
(180, 1, 0, 0, 0, 0, 'Mandarin South House #005', 30, 96, 7100, 7100, 2, 2, 142, 0, 0),
(181, 0, 0, 0, 0, 0, 'Mandarin South House #006', 30, 90, 6650, 6650, 3, 2, 133, 0, 0),
(181, 1, 0, 0, 0, 0, 'Mandarin South House #006', 30, 90, 6650, 6650, 3, 2, 133, 0, 0),
(182, 0, 0, 0, 0, 0, 'Mandarin South House #007', 30, 44, 3700, 3700, 2, 2, 74, 0, 0),
(182, 1, 0, 0, 0, 0, 'Mandarin South House #007', 30, 44, 3700, 3700, 2, 2, 74, 0, 0),
(183, 0, 0, 0, 0, 0, 'Mandarin South #001', 33, 32, 2650, 2650, 1, 2, 53, 0, 0),
(183, 1, 0, 0, 0, 0, 'Mandarin South #001', 33, 32, 2650, 2650, 1, 2, 53, 0, 0),
(184, 0, 0, 0, 0, 0, 'Mandarin South #002', 33, 45, 3350, 3350, 1, 2, 67, 0, 0),
(184, 1, 0, 0, 0, 0, 'Mandarin South #002', 33, 45, 3350, 3350, 1, 2, 67, 0, 0),
(185, 0, 0, 0, 0, 0, 'Mandarin South #003', 33, 56, 4050, 4050, 2, 2, 81, 0, 0),
(185, 1, 0, 0, 0, 0, 'Mandarin South #003', 33, 56, 4050, 4050, 2, 2, 81, 0, 0),
(186, 0, 0, 0, 0, 0, 'Mandarin South #004', 33, 39, 3050, 3050, 2, 2, 61, 0, 0),
(186, 1, 0, 0, 0, 0, 'Mandarin South #004', 33, 39, 3050, 3050, 2, 2, 61, 0, 0),
(188, 0, 0, 0, 0, 0, 'Pallet House #1', 32, 75, 5950, 5950, 4, 4, 119, 0, 0),
(188, 1, 0, 0, 0, 0, 'Pallet House #1', 32, 75, 5950, 5950, 4, 4, 119, 0, 0),
(189, 0, 0, 0, 0, 0, 'Pallet House #2', 32, 58, 4000, 4000, 3, 2, 80, 0, 0),
(189, 1, 0, 0, 0, 0, 'Pallet House #2', 32, 58, 4000, 4000, 3, 2, 80, 0, 0),
(190, 0, 0, 0, 0, 0, 'Pallet House #3', 32, 53, 3850, 3850, 3, 2, 77, 0, 0),
(190, 1, 0, 0, 0, 0, 'Pallet House #3', 32, 53, 3850, 3850, 3, 2, 77, 0, 0),
(191, 0, 0, 0, 0, 0, 'Pallet Farm #1', 32, 16, 850, 850, 1, 0, 17, 0, 0),
(191, 1, 0, 0, 0, 0, 'Pallet Farm #1', 32, 16, 850, 850, 1, 0, 17, 0, 0),
(192, 0, 0, 0, 0, 0, 'Pallet Farm #2', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(192, 1, 0, 0, 0, 0, 'Pallet Farm #2', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(193, 0, 0, 0, 0, 0, 'Pallet Farm #3', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(193, 1, 0, 0, 0, 0, 'Pallet Farm #3', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(194, 0, 0, 0, 0, 0, 'Pallet Farm #4', 32, 12, 650, 650, 1, 0, 13, 0, 0),
(194, 1, 0, 0, 0, 0, 'Pallet Farm #4', 32, 12, 650, 650, 1, 0, 13, 0, 0),
(195, 0, 0, 0, 0, 0, 'Pallet Farm #5', 32, 12, 650, 650, 1, 0, 13, 0, 0),
(195, 1, 0, 0, 0, 0, 'Pallet Farm #5', 32, 12, 650, 650, 1, 0, 13, 0, 0),
(196, 0, 0, 0, 0, 0, 'Pallet Farm #6', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(196, 1, 0, 0, 0, 0, 'Pallet Farm #6', 32, 15, 800, 800, 1, 0, 16, 0, 0),
(197, 0, 0, 0, 0, 0, 'Viridian House #1', 1, 90, 6250, 6250, 2, 2, 125, 0, 0),
(197, 1, 0, 0, 0, 0, 'Viridian House #1', 1, 90, 6250, 6250, 2, 2, 125, 0, 0),
(198, 0, 0, 0, 0, 0, 'Viridian House #2', 1, 90, 6650, 6650, 4, 2, 133, 0, 0),
(198, 1, 0, 0, 0, 0, 'Viridian House #2', 1, 90, 6650, 6650, 4, 2, 133, 0, 0),
(199, 0, 0, 0, 0, 0, 'Viridian House #3', 1, 73, 5700, 5700, 3, 2, 114, 0, 0),
(199, 1, 0, 0, 0, 0, 'Viridian House #3', 1, 73, 5700, 5700, 3, 2, 114, 0, 0),
(200, 0, 0, 0, 0, 0, 'Viridian House #4', 1, 95, 6400, 6400, 2, 2, 128, 0, 0),
(200, 1, 0, 0, 0, 0, 'Viridian House #4', 1, 95, 6400, 6400, 2, 2, 128, 0, 0),
(201, 0, 0, 0, 0, 0, 'Viridian House #5', 1, 80, 6450, 6450, 6, 4, 129, 0, 0),
(201, 1, 0, 0, 0, 0, 'Viridian House #5', 1, 80, 6450, 6450, 6, 4, 129, 0, 0),
(202, 0, 0, 0, 0, 0, 'Viridian House #6', 1, 98, 6400, 6400, 4, 4, 128, 0, 0),
(202, 1, 0, 0, 0, 0, 'Viridian House #6', 1, 98, 6400, 6400, 4, 4, 128, 0, 0),
(203, 0, 0, 0, 0, 0, 'Viridian House #7', 1, 186, 11550, 11550, 4, 2, 231, 0, 0),
(203, 1, 0, 0, 0, 0, 'Viridian House #7', 1, 186, 11550, 11550, 4, 2, 231, 0, 0),
(204, 0, 0, 0, 0, 0, 'Viridian House #8', 1, 139, 10200, 10200, 5, 4, 204, 0, 0),
(204, 1, 0, 0, 0, 0, 'Viridian House #8', 1, 139, 10200, 10200, 5, 4, 204, 0, 0),
(205, 0, 0, 0, 0, 0, 'Viridian House #9', 1, 124, 8500, 8500, 8, 4, 170, 0, 0),
(205, 1, 0, 0, 0, 0, 'Viridian House #9', 1, 124, 8500, 8500, 8, 4, 170, 0, 0),
(206, 0, 0, 0, 0, 0, 'Viridian House #10', 1, 128, 8950, 8950, 5, 4, 179, 0, 0),
(206, 1, 0, 0, 0, 0, 'Viridian House #10', 1, 128, 8950, 8950, 5, 4, 179, 0, 0),
(207, 0, 0, 0, 0, 0, 'Viridian House #11', 1, 57, 4700, 4700, 4, 6, 94, 0, 0),
(207, 1, 0, 0, 0, 0, 'Viridian House #11', 1, 57, 4700, 4700, 4, 6, 94, 0, 0),
(208, 0, 0, 0, 0, 0, 'Viridian House #12', 1, 150, 9600, 9600, 3, 2, 192, 0, 0),
(208, 1, 0, 0, 0, 0, 'Viridian House #12', 1, 150, 9600, 9600, 3, 2, 192, 0, 0),
(209, 0, 0, 0, 0, 0, 'Viridian House #13', 1, 52, 3850, 3850, 2, 2, 77, 0, 0),
(209, 1, 0, 0, 0, 0, 'Viridian House #13', 1, 52, 3850, 3850, 2, 2, 77, 0, 0),
(210, 0, 0, 0, 0, 0, 'Viridian House #14', 1, 100, 6700, 6700, 4, 2, 134, 0, 0),
(210, 1, 0, 0, 0, 0, 'Viridian House #14', 1, 100, 6700, 6700, 4, 2, 134, 0, 0),
(211, 0, 0, 0, 0, 0, 'Viridian House #15', 1, 120, 8350, 8350, 4, 2, 167, 0, 0),
(211, 1, 0, 0, 0, 0, 'Viridian House #15', 1, 120, 8350, 8350, 4, 2, 167, 0, 0),
(212, 0, 0, 0, 0, 0, 'Viridian House #16', 1, 100, 7050, 7050, 5, 4, 141, 0, 0),
(212, 1, 0, 0, 0, 0, 'Viridian House #16', 1, 100, 7050, 7050, 5, 4, 141, 0, 0),
(213, 0, 0, 0, 0, 0, 'Viridian Guild House', 1, 599, 39100, 39100, 7, 10, 782, 1, 0),
(213, 1, 0, 0, 0, 0, 'Viridian Guild House', 1, 599, 39100, 39100, 7, 10, 782, 1, 0),
(214, 0, 0, 0, 0, 0, 'Viridian Room #1', 1, 4, 650, 650, 1, 2, 13, 0, 0),
(214, 1, 0, 0, 0, 0, 'Viridian Room #1', 1, 4, 650, 650, 1, 2, 13, 0, 0),
(215, 0, 0, 0, 0, 0, 'Viridian Room #2', 1, 4, 500, 500, 1, 2, 10, 0, 0),
(215, 1, 0, 0, 0, 0, 'Viridian Room #2', 1, 4, 500, 500, 1, 2, 10, 0, 0),
(216, 0, 0, 0, 0, 0, 'Viridian Room #3', 1, 4, 600, 600, 1, 2, 12, 0, 0),
(216, 1, 0, 0, 0, 0, 'Viridian Room #3', 1, 4, 600, 600, 1, 2, 12, 0, 0),
(217, 0, 0, 0, 0, 0, 'Viridian Room #4', 1, 8, 850, 850, 1, 2, 17, 0, 0),
(217, 1, 0, 0, 0, 0, 'Viridian Room #4', 1, 8, 850, 850, 1, 2, 17, 0, 0),
(218, 0, 0, 0, 0, 0, 'Viridian Room #5', 1, 7, 750, 750, 1, 2, 15, 0, 0),
(218, 1, 0, 0, 0, 0, 'Viridian Room #5', 1, 7, 750, 750, 1, 2, 15, 0, 0),
(219, 0, 0, 0, 0, 0, 'Pewter Room #1', 2, 10, 1000, 1000, 1, 2, 20, 0, 0),
(219, 1, 0, 0, 0, 0, 'Pewter Room #1', 2, 10, 1000, 1000, 1, 2, 20, 0, 0),
(220, 0, 0, 0, 0, 0, 'Pewter Room #2', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(220, 1, 0, 0, 0, 0, 'Pewter Room #2', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(221, 0, 0, 0, 0, 0, 'Pewter Room #3', 2, 32, 2650, 2650, 2, 4, 53, 0, 0),
(221, 1, 0, 0, 0, 0, 'Pewter Room #3', 2, 32, 2650, 2650, 2, 4, 53, 0, 0),
(222, 0, 0, 0, 0, 0, 'Pewter Room #4', 2, 25, 2050, 2050, 2, 2, 41, 0, 0),
(222, 1, 0, 0, 0, 0, 'Pewter Room #4', 2, 25, 2050, 2050, 2, 2, 41, 0, 0),
(223, 0, 0, 0, 0, 0, 'Pewter Room #5', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(223, 1, 0, 0, 0, 0, 'Pewter Room #5', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(224, 0, 0, 0, 0, 0, 'Pewter Room #6', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(224, 1, 0, 0, 0, 0, 'Pewter Room #6', 2, 10, 950, 950, 1, 2, 19, 0, 0),
(225, 0, 0, 0, 0, 0, 'Pewter Room #7', 2, 10, 1000, 1000, 2, 2, 20, 0, 0),
(225, 1, 0, 0, 0, 0, 'Pewter Room #7', 2, 10, 1000, 1000, 2, 2, 20, 0, 0),
(226, 0, 0, 0, 0, 0, 'Pewter Farm #1', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(226, 1, 0, 0, 0, 0, 'Pewter Farm #1', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(227, 0, 0, 0, 0, 0, 'Pewter Farm #2', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(227, 1, 0, 0, 0, 0, 'Pewter Farm #2', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(228, 0, 0, 0, 0, 0, 'Pewter Farm #3', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(228, 1, 0, 0, 0, 0, 'Pewter Farm #3', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(229, 0, 0, 0, 0, 0, 'Pewter Farm #4', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(229, 1, 0, 0, 0, 0, 'Pewter Farm #4', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(230, 0, 0, 0, 0, 0, 'Pewter Farm #5', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(230, 1, 0, 0, 0, 0, 'Pewter Farm #5', 2, 16, 850, 850, 1, 0, 17, 0, 0),
(231, 0, 0, 0, 0, 0, 'Pewter Guild House', 2, 584, 42600, 42600, 16, 20, 852, 1, 0),
(231, 1, 0, 0, 0, 0, 'Pewter Guild House', 2, 584, 42600, 42600, 16, 20, 852, 1, 0),
(232, 0, 0, 0, 0, 0, 'Pewter House #1', 2, 89, 6700, 6700, 3, 4, 134, 0, 0),
(232, 1, 0, 0, 0, 0, 'Pewter House #1', 2, 89, 6700, 6700, 3, 4, 134, 0, 0),
(233, 0, 0, 0, 0, 0, 'Pewter House #2', 2, 66, 4800, 4800, 2, 2, 96, 0, 0),
(233, 1, 0, 0, 0, 0, 'Pewter House #2', 2, 66, 4800, 4800, 2, 2, 96, 0, 0),
(234, 0, 0, 0, 0, 0, 'Pewter House #3', 2, 54, 4500, 4500, 4, 4, 90, 0, 0),
(234, 1, 0, 0, 0, 0, 'Pewter House #3', 2, 54, 4500, 4500, 4, 4, 90, 0, 0),
(235, 0, 0, 0, 0, 0, 'Pewter House #4', 2, 98, 7350, 7350, 4, 4, 147, 0, 0),
(235, 1, 0, 0, 0, 0, 'Pewter House #4', 2, 98, 7350, 7350, 4, 4, 147, 0, 0),
(236, 0, 0, 0, 0, 0, 'Pewter House #5', 2, 96, 7050, 7050, 3, 4, 141, 0, 0),
(236, 1, 0, 0, 0, 0, 'Pewter House #5', 2, 96, 7050, 7050, 3, 4, 141, 0, 0),
(237, 0, 0, 0, 0, 0, 'Pewter House #6', 2, 127, 9250, 9250, 4, 6, 185, 0, 0),
(237, 1, 0, 0, 0, 0, 'Pewter House #6', 2, 127, 9250, 9250, 4, 6, 185, 0, 0),
(238, 0, 0, 0, 0, 0, 'Pewter House #7', 2, 144, 9150, 9150, 4, 4, 183, 0, 0),
(238, 1, 0, 0, 0, 0, 'Pewter House #7', 2, 144, 9150, 9150, 4, 4, 183, 0, 0),
(239, 0, 0, 0, 0, 0, 'Pewter House #10', 2, 110, 8400, 8400, 7, 4, 168, 0, 0),
(239, 1, 0, 0, 0, 0, 'Pewter House #10', 2, 110, 8400, 8400, 7, 4, 168, 0, 0),
(240, 0, 0, 0, 0, 0, 'Pewter House #11', 2, 140, 9400, 9400, 3, 4, 188, 0, 0),
(240, 1, 0, 0, 0, 0, 'Pewter House #11', 2, 140, 9400, 9400, 3, 4, 188, 0, 0),
(241, 0, 0, 0, 0, 0, 'Pewter House #12', 2, 56, 4600, 4600, 5, 4, 92, 0, 0),
(241, 1, 0, 0, 0, 0, 'Pewter House #12', 2, 56, 4600, 4600, 5, 4, 92, 0, 0),
(242, 0, 0, 0, 0, 0, 'Pewter House #13', 2, 174, 11150, 11150, 5, 2, 223, 0, 0),
(242, 1, 0, 0, 0, 0, 'Pewter House #13', 2, 174, 11150, 11150, 5, 2, 223, 0, 0),
(243, 0, 0, 0, 0, 0, 'Pewter House #14', 2, 55, 4300, 4300, 3, 4, 86, 0, 0),
(243, 1, 0, 0, 0, 0, 'Pewter House #14', 2, 55, 4300, 4300, 3, 4, 86, 0, 0),
(244, 0, 0, 0, 0, 0, 'Pewter House #15', 2, 92, 6500, 6500, 5, 4, 130, 0, 0),
(244, 1, 0, 0, 0, 0, 'Pewter House #15', 2, 92, 6500, 6500, 5, 4, 130, 0, 0),
(245, 0, 0, 0, 0, 0, 'Pewter House #16', 2, 134, 8900, 8900, 4, 4, 178, 0, 0),
(245, 1, 0, 0, 0, 0, 'Pewter House #16', 2, 134, 8900, 8900, 4, 4, 178, 0, 0),
(246, 0, 0, 0, 0, 0, 'Pewter House #17', 2, 125, 9450, 9450, 8, 4, 189, 0, 0),
(246, 1, 0, 0, 0, 0, 'Pewter House #17', 2, 125, 9450, 9450, 8, 4, 189, 0, 0),
(247, 0, 0, 0, 0, 0, 'Pewter House #18', 2, 91, 6250, 6250, 2, 2, 125, 0, 0),
(247, 1, 0, 0, 0, 0, 'Pewter House #18', 2, 91, 6250, 6250, 2, 2, 125, 0, 0),
(248, 0, 0, 0, 0, 0, 'Celadon House #1', 5, 116, 8850, 8850, 9, 4, 177, 0, 0),
(248, 1, 0, 0, 0, 0, 'Celadon House #1', 5, 116, 8850, 8850, 9, 4, 177, 0, 0),
(249, 0, 0, 0, 0, 0, 'Celadon House #2', 5, 151, 10000, 10000, 4, 2, 200, 0, 0),
(249, 1, 0, 0, 0, 0, 'Celadon House #2', 5, 151, 10000, 10000, 4, 2, 200, 0, 0),
(250, 0, 0, 0, 0, 0, 'Celadon House #3', 5, 146, 9950, 9950, 5, 4, 199, 0, 0),
(250, 1, 0, 0, 0, 0, 'Celadon House #3', 5, 146, 9950, 9950, 5, 4, 199, 0, 0),
(251, 0, 0, 0, 0, 0, 'Celadon House #4', 5, 177, 12400, 12400, 4, 6, 248, 0, 0),
(251, 1, 0, 0, 0, 0, 'Celadon House #4', 5, 177, 12400, 12400, 4, 6, 248, 0, 0),
(252, 0, 0, 0, 0, 0, 'Celadon House #5', 5, 101, 6900, 6900, 2, 2, 138, 0, 0),
(252, 1, 0, 0, 0, 0, 'Celadon House #5', 5, 101, 6900, 6900, 2, 2, 138, 0, 0),
(253, 0, 0, 0, 0, 0, 'Celadon House #6', 5, 144, 10250, 10250, 5, 4, 205, 0, 0),
(253, 1, 0, 0, 0, 0, 'Celadon House #6', 5, 144, 10250, 10250, 5, 4, 205, 0, 0),
(254, 0, 0, 0, 0, 0, 'Celadon House #7', 5, 208, 14700, 14700, 10, 4, 294, 0, 0),
(254, 1, 0, 0, 0, 0, 'Celadon House #7', 5, 208, 14700, 14700, 10, 4, 294, 0, 0),
(255, 0, 0, 0, 0, 0, 'Celadon House #8', 5, 135, 9250, 9250, 3, 2, 185, 0, 0),
(255, 1, 0, 0, 0, 0, 'Celadon House #8', 5, 135, 9250, 9250, 3, 2, 185, 0, 0),
(256, 0, 0, 0, 0, 0, 'Celadon House #9', 5, 113, 8300, 8300, 6, 4, 166, 0, 0),
(256, 1, 0, 0, 0, 0, 'Celadon House #9', 5, 113, 8300, 8300, 6, 4, 166, 0, 0),
(257, 0, 0, 0, 0, 0, 'Celadon House #10', 5, 255, 17100, 17100, 9, 4, 342, 0, 0),
(257, 1, 0, 0, 0, 0, 'Celadon House #10', 5, 255, 17100, 17100, 9, 4, 342, 0, 0),
(258, 0, 0, 0, 0, 0, 'Celadon House #11', 5, 223, 14650, 14650, 5, 2, 293, 0, 0),
(258, 1, 0, 0, 0, 0, 'Celadon House #11', 5, 223, 14650, 14650, 5, 2, 293, 0, 0),
(259, 0, 0, 0, 0, 0, 'Celadon House #12', 5, 183, 12400, 12400, 3, 4, 248, 0, 0),
(259, 1, 0, 0, 0, 0, 'Celadon House #12', 5, 183, 12400, 12400, 3, 4, 248, 0, 0),
(260, 0, 0, 0, 0, 0, 'Celadon House #13', 5, 181, 12500, 12500, 5, 4, 250, 0, 0),
(260, 1, 0, 0, 0, 0, 'Celadon House #13', 5, 181, 12500, 12500, 5, 4, 250, 0, 0),
(261, 0, 0, 0, 0, 0, 'Celadon House #14', 5, 139, 9350, 9350, 3, 4, 187, 0, 0),
(261, 1, 0, 0, 0, 0, 'Celadon House #14', 5, 139, 9350, 9350, 3, 4, 187, 0, 0),
(262, 0, 0, 0, 0, 0, 'Celadon House #15', 5, 237, 16000, 16000, 4, 4, 320, 0, 0),
(262, 1, 0, 0, 0, 0, 'Celadon House #15', 5, 237, 16000, 16000, 4, 4, 320, 0, 0),
(263, 0, 0, 0, 0, 0, 'Celadon Guild House', 5, 606, 45100, 45100, 13, 20, 902, 1, 0),
(263, 1, 0, 0, 0, 0, 'Celadon Guild House', 5, 606, 45100, 45100, 13, 20, 902, 1, 0),
(264, 0, 0, 0, 0, 0, 'Celadon Room #1', 5, 18, 1450, 1450, 1, 2, 29, 0, 0),
(264, 1, 0, 0, 0, 0, 'Celadon Room #1', 5, 18, 1450, 1450, 1, 2, 29, 0, 0),
(265, 0, 0, 0, 0, 0, 'Celadon Room #2', 5, 14, 1350, 1350, 1, 2, 27, 0, 0),
(265, 1, 0, 0, 0, 0, 'Celadon Room #2', 5, 14, 1350, 1350, 1, 2, 27, 0, 0),
(266, 0, 0, 0, 0, 0, 'Celadon Room #3', 5, 4, 550, 550, 1, 2, 11, 0, 0),
(266, 1, 0, 0, 0, 0, 'Celadon Room #3', 5, 4, 550, 550, 1, 2, 11, 0, 0),
(267, 0, 0, 0, 0, 0, 'Celadon Room #4', 5, 4, 550, 550, 1, 2, 11, 0, 0),
(267, 1, 0, 0, 0, 0, 'Celadon Room #4', 5, 4, 550, 550, 1, 2, 11, 0, 0),
(268, 0, 0, 0, 0, 0, 'Celadon Room #5', 5, 18, 1500, 1500, 1, 2, 30, 0, 0),
(268, 1, 0, 0, 0, 0, 'Celadon Room #5', 5, 18, 1500, 1500, 1, 2, 30, 0, 0),
(269, 0, 0, 0, 0, 0, 'Celadon Room #6', 5, 34, 2300, 2300, 1, 2, 46, 0, 0),
(269, 1, 0, 0, 0, 0, 'Celadon Room #6', 5, 34, 2300, 2300, 1, 2, 46, 0, 0),
(270, 0, 0, 0, 0, 0, 'Cerulean House #1', 3, 166, 11400, 11400, 3, 4, 228, 0, 0),
(270, 1, 0, 0, 0, 0, 'Cerulean House #1', 3, 166, 11400, 11400, 3, 4, 228, 0, 0),
(271, 0, 0, 0, 0, 0, 'Cerulean House #2', 3, 132, 8650, 8650, 3, 2, 173, 0, 0),
(271, 1, 0, 0, 0, 0, 'Cerulean House #2', 3, 132, 8650, 8650, 3, 2, 173, 0, 0),
(272, 0, 0, 0, 0, 0, 'Cerulean House #3', 3, 166, 11350, 11350, 3, 2, 227, 0, 0),
(272, 1, 0, 0, 0, 0, 'Cerulean House #3', 3, 166, 11350, 11350, 3, 2, 227, 0, 0),
(273, 0, 0, 0, 0, 0, 'Cerulean House #4', 3, 131, 9050, 9050, 2, 2, 181, 0, 0),
(273, 1, 0, 0, 0, 0, 'Cerulean House #4', 3, 131, 9050, 9050, 2, 2, 181, 0, 0),
(274, 0, 0, 0, 0, 0, 'Cerulean House #5', 3, 90, 6300, 6300, 3, 4, 126, 0, 0),
(274, 1, 0, 0, 0, 0, 'Cerulean House #5', 3, 90, 6300, 6300, 3, 4, 126, 0, 0),
(275, 0, 0, 0, 0, 0, 'Cerulean House #6', 3, 129, 8850, 8850, 3, 4, 177, 0, 0),
(275, 1, 0, 0, 0, 0, 'Cerulean House #6', 3, 129, 8850, 8850, 3, 4, 177, 0, 0),
(276, 0, 0, 0, 0, 0, 'Cerulean House #7', 3, 219, 13450, 13450, 3, 2, 269, 0, 0),
(276, 1, 0, 0, 0, 0, 'Cerulean House #7', 3, 219, 13450, 13450, 3, 2, 269, 0, 0),
(277, 0, 0, 0, 0, 0, 'Cerulean House #8', 3, 134, 9100, 9100, 4, 2, 182, 0, 0),
(277, 1, 0, 0, 0, 0, 'Cerulean House #8', 3, 134, 9100, 9100, 4, 2, 182, 0, 0),
(278, 0, 0, 0, 0, 0, 'Cerulean House #9', 3, 129, 9200, 9200, 3, 4, 184, 0, 0),
(278, 1, 0, 0, 0, 0, 'Cerulean House #9', 3, 129, 9200, 9200, 3, 4, 184, 0, 0),
(279, 0, 0, 0, 0, 0, 'Cerulean House #10', 3, 72, 5050, 5050, 2, 2, 101, 0, 0),
(279, 1, 0, 0, 0, 0, 'Cerulean House #10', 3, 72, 5050, 5050, 2, 2, 101, 0, 0),
(280, 0, 0, 0, 0, 0, 'Cerulean House #11', 3, 104, 7050, 7050, 5, 2, 141, 0, 0),
(280, 1, 0, 0, 0, 0, 'Cerulean House #11', 3, 104, 7050, 7050, 5, 2, 141, 0, 0),
(281, 0, 0, 0, 0, 0, 'Cerulean House #12', 3, 104, 7550, 7550, 5, 2, 151, 0, 0),
(281, 1, 0, 0, 0, 0, 'Cerulean House #12', 3, 104, 7550, 7550, 5, 2, 151, 0, 0),
(282, 0, 0, 0, 0, 0, 'Cerulean House #13', 3, 124, 8900, 8900, 3, 2, 178, 0, 0),
(282, 1, 0, 0, 0, 0, 'Cerulean House #13', 3, 124, 8900, 8900, 3, 2, 178, 0, 0),
(283, 0, 0, 0, 0, 0, 'Cerulean House #14', 3, 213, 12800, 12800, 3, 2, 256, 0, 0),
(283, 1, 0, 0, 0, 0, 'Cerulean House #14', 3, 213, 12800, 12800, 3, 2, 256, 0, 0),
(284, 0, 0, 0, 0, 0, 'Cerulean House #15', 3, 81, 5700, 5700, 2, 2, 114, 0, 0),
(284, 1, 0, 0, 0, 0, 'Cerulean House #15', 3, 81, 5700, 5700, 2, 2, 114, 0, 0),
(285, 0, 0, 0, 0, 0, 'Cerulean House #16', 3, 159, 10750, 10750, 4, 4, 215, 0, 0),
(285, 1, 0, 0, 0, 0, 'Cerulean House #16', 3, 159, 10750, 10750, 4, 4, 215, 0, 0),
(286, 0, 0, 0, 0, 0, 'Cerulean Guild House', 3, 551, 38200, 38200, 10, 16, 764, 1, 0),
(286, 1, 0, 0, 0, 0, 'Cerulean Guild House', 3, 551, 38200, 38200, 10, 16, 764, 1, 0),
(287, 0, 0, 0, 0, 0, 'Saffron Guild House', 4, 624, 42800, 42800, 12, 18, 856, 1, 0),
(287, 1, 0, 0, 0, 0, 'Saffron Guild House', 4, 624, 42800, 42800, 12, 18, 856, 1, 0),
(288, 0, 0, 0, 0, 0, 'Saffron Room #1', 4, 16, 1300, 1300, 1, 2, 26, 0, 0),
(288, 1, 0, 0, 0, 0, 'Saffron Room #1', 4, 16, 1300, 1300, 1, 2, 26, 0, 0),
(289, 0, 0, 0, 0, 0, 'Saffron Room #2', 4, 16, 1350, 1350, 1, 2, 27, 0, 0),
(289, 1, 0, 0, 0, 0, 'Saffron Room #2', 4, 16, 1350, 1350, 1, 2, 27, 0, 0),
(290, 0, 0, 0, 0, 0, 'Saffron Room #3', 4, 10, 1000, 1000, 1, 2, 20, 0, 0),
(290, 1, 0, 0, 0, 0, 'Saffron Room #3', 4, 10, 1000, 1000, 1, 2, 20, 0, 0),
(291, 0, 0, 0, 0, 0, 'Saffron Room #4', 4, 10, 900, 900, 1, 2, 18, 0, 0),
(291, 1, 0, 0, 0, 0, 'Saffron Room #4', 4, 10, 900, 900, 1, 2, 18, 0, 0),
(292, 0, 0, 0, 0, 0, 'Saffron House #1', 4, 174, 12600, 12600, 5, 8, 252, 0, 0),
(292, 1, 0, 0, 0, 0, 'Saffron House #1', 4, 174, 12600, 12600, 5, 8, 252, 0, 0),
(293, 0, 0, 0, 0, 0, 'Saffron House #2', 4, 232, 14200, 14200, 6, 2, 284, 0, 0),
(293, 1, 0, 0, 0, 0, 'Saffron House #2', 4, 232, 14200, 14200, 6, 2, 284, 0, 0),
(294, 0, 0, 0, 0, 0, 'Saffron House #3', 4, 183, 12250, 12250, 3, 2, 245, 0, 0),
(294, 1, 0, 0, 0, 0, 'Saffron House #3', 4, 183, 12250, 12250, 3, 2, 245, 0, 0),
(295, 0, 0, 0, 0, 0, 'Saffron House #4', 4, 199, 13100, 13100, 5, 4, 262, 0, 0),
(295, 1, 0, 0, 0, 0, 'Saffron House #4', 4, 199, 13100, 13100, 5, 4, 262, 0, 0),
(296, 0, 0, 0, 0, 0, 'Saffron House #5', 4, 123, 8250, 8250, 4, 2, 165, 0, 0),
(296, 1, 0, 0, 0, 0, 'Saffron House #5', 4, 123, 8250, 8250, 4, 2, 165, 0, 0),
(297, 0, 0, 0, 0, 0, 'Saffron House #6', 4, 167, 10850, 10850, 4, 2, 217, 0, 0),
(297, 1, 0, 0, 0, 0, 'Saffron House #6', 4, 167, 10850, 10850, 4, 2, 217, 0, 0),
(298, 0, 0, 0, 0, 0, 'Saffron House #7', 4, 58, 4100, 4100, 2, 2, 82, 0, 0),
(298, 1, 0, 0, 0, 0, 'Saffron House #7', 4, 58, 4100, 4100, 2, 2, 82, 0, 0),
(299, 0, 0, 0, 0, 0, 'Saffron House #8', 4, 120, 8250, 8250, 4, 2, 165, 0, 0),
(299, 1, 0, 0, 0, 0, 'Saffron House #8', 4, 120, 8250, 8250, 4, 2, 165, 0, 0),
(300, 0, 0, 0, 0, 0, 'Saffron House #9', 4, 126, 8650, 8650, 2, 2, 173, 0, 0),
(300, 1, 0, 0, 0, 0, 'Saffron House #9', 4, 126, 8650, 8650, 2, 2, 173, 0, 0),
(301, 0, 0, 0, 0, 0, 'Saffron House #10', 4, 125, 9200, 9200, 7, 4, 184, 0, 0),
(301, 1, 0, 0, 0, 0, 'Saffron House #10', 4, 125, 9200, 9200, 7, 4, 184, 0, 0),
(302, 0, 0, 0, 0, 0, 'Saffron House #11', 4, 82, 5700, 5700, 2, 2, 114, 0, 0),
(302, 1, 0, 0, 0, 0, 'Saffron House #11', 4, 82, 5700, 5700, 2, 2, 114, 0, 0),
(303, 0, 0, 0, 0, 0, 'Saffron House #12', 4, 92, 6850, 6850, 3, 4, 137, 0, 0),
(303, 1, 0, 0, 0, 0, 'Saffron House #12', 4, 92, 6850, 6850, 3, 4, 137, 0, 0),
(304, 0, 0, 0, 0, 0, 'Saffron House #13', 4, 249, 16300, 16300, 3, 4, 326, 0, 0),
(304, 1, 0, 0, 0, 0, 'Saffron House #13', 4, 249, 16300, 16300, 3, 4, 326, 0, 0),
(305, 0, 0, 0, 0, 0, 'Saffron House #14', 4, 103, 7000, 7000, 2, 2, 140, 0, 0),
(305, 1, 0, 0, 0, 0, 'Saffron House #14', 4, 103, 7000, 7000, 2, 2, 140, 0, 0),
(306, 0, 0, 0, 0, 0, 'Saffron House #15', 4, 112, 7450, 7450, 2, 2, 149, 0, 0),
(306, 1, 0, 0, 0, 0, 'Saffron House #15', 4, 112, 7450, 7450, 2, 2, 149, 0, 0),
(307, 0, 0, 0, 0, 0, 'Saffron House #16', 4, 153, 10500, 10500, 2, 2, 210, 0, 0),
(307, 1, 0, 0, 0, 0, 'Saffron House #16', 4, 153, 10500, 10500, 2, 2, 210, 0, 0),
(308, 0, 0, 0, 0, 0, 'Lavender House #1', 7, 141, 9550, 9550, 3, 2, 191, 0, 0),
(308, 1, 0, 0, 0, 0, 'Lavender House #1', 7, 141, 9550, 9550, 3, 2, 191, 0, 0),
(309, 0, 0, 0, 0, 0, 'Lavender House #2', 7, 44, 3450, 3450, 2, 2, 69, 0, 0),
(309, 1, 0, 0, 0, 0, 'Lavender House #2', 7, 44, 3450, 3450, 2, 2, 69, 0, 0),
(310, 0, 0, 0, 0, 0, 'Lavender House #3', 7, 165, 12000, 12000, 7, 4, 240, 0, 0),
(310, 1, 0, 0, 0, 0, 'Lavender House #3', 7, 165, 12000, 12000, 7, 4, 240, 0, 0),
(311, 0, 0, 0, 0, 0, 'Lavender House #4', 7, 287, 17850, 17850, 4, 4, 357, 0, 0),
(311, 1, 0, 0, 0, 0, 'Lavender House #4', 7, 287, 17850, 17850, 4, 4, 357, 0, 0),
(312, 0, 0, 0, 0, 0, 'Lavender House #5', 7, 199, 13350, 13350, 4, 4, 267, 0, 0),
(312, 1, 0, 0, 0, 0, 'Lavender House #5', 7, 199, 13350, 13350, 4, 4, 267, 0, 0),
(313, 0, 0, 0, 0, 0, 'Lavender House #6', 7, 191, 13500, 13500, 6, 6, 270, 0, 0),
(313, 1, 0, 0, 0, 0, 'Lavender House #6', 7, 191, 13500, 13500, 6, 6, 270, 0, 0),
(314, 0, 0, 0, 0, 0, 'Lavender House #7', 7, 154, 10300, 10300, 4, 2, 206, 0, 0),
(314, 1, 0, 0, 0, 0, 'Lavender House #7', 7, 154, 10300, 10300, 4, 2, 206, 0, 0),
(315, 0, 0, 0, 0, 0, 'Lavender House #8', 7, 131, 9200, 9200, 3, 2, 184, 0, 0),
(315, 1, 0, 0, 0, 0, 'Lavender House #8', 7, 131, 9200, 9200, 3, 2, 184, 0, 0),
(316, 0, 0, 0, 0, 0, 'Lavender House #9', 7, 68, 4650, 4650, 2, 2, 93, 0, 0),
(316, 1, 0, 0, 0, 0, 'Lavender House #9', 7, 68, 4650, 4650, 2, 2, 93, 0, 0),
(317, 0, 0, 0, 0, 0, 'Lavender House #10', 7, 277, 16750, 16750, 3, 2, 335, 0, 0),
(317, 1, 0, 0, 0, 0, 'Lavender House #10', 7, 277, 16750, 16750, 3, 2, 335, 0, 0),
(318, 0, 0, 0, 0, 0, 'Lavender House #11', 7, 181, 12150, 12150, 4, 4, 243, 0, 0),
(318, 1, 0, 0, 0, 0, 'Lavender House #11', 7, 181, 12150, 12150, 4, 4, 243, 0, 0),
(319, 0, 0, 0, 0, 0, 'Lavender House #12', 7, 123, 8000, 8000, 2, 2, 160, 0, 0),
(319, 1, 0, 0, 0, 0, 'Lavender House #12', 7, 123, 8000, 8000, 2, 2, 160, 0, 0),
(320, 0, 0, 0, 0, 0, 'Vermilion Room #1', 6, 26, 1950, 1950, 1, 2, 39, 0, 0),
(320, 1, 0, 0, 0, 0, 'Vermilion Room #1', 6, 26, 1950, 1950, 1, 2, 39, 0, 0),
(321, 0, 0, 0, 0, 0, 'Vermilion Room #2', 6, 10, 950, 950, 1, 2, 19, 0, 0),
(321, 1, 0, 0, 0, 0, 'Vermilion Room #2', 6, 10, 950, 950, 1, 2, 19, 0, 0);
INSERT INTO `houses` (`id`, `world_id`, `owner`, `paid`, `warnings`, `lastwarning`, `name`, `town`, `size`, `price`, `rent`, `doors`, `beds`, `tiles`, `guild`, `clear`) VALUES
(322, 0, 0, 0, 0, 0, 'Vermilion Room #3', 6, 7, 750, 750, 1, 2, 15, 0, 0),
(322, 1, 0, 0, 0, 0, 'Vermilion Room #3', 6, 7, 750, 750, 1, 2, 15, 0, 0),
(323, 0, 0, 0, 0, 0, 'Vermilion Room #4', 6, 7, 800, 800, 1, 2, 16, 0, 0),
(323, 1, 0, 0, 0, 0, 'Vermilion Room #4', 6, 7, 800, 800, 1, 2, 16, 0, 0),
(324, 0, 0, 0, 0, 0, 'Vermilion Farm #1', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(324, 1, 0, 0, 0, 0, 'Vermilion Farm #1', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(325, 0, 0, 0, 0, 0, 'Vermilion Farm #2', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(325, 1, 0, 0, 0, 0, 'Vermilion Farm #2', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(326, 0, 0, 0, 0, 0, 'Vermilion Farm #3', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(326, 1, 0, 0, 0, 0, 'Vermilion Farm #3', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(327, 0, 0, 0, 0, 0, 'Vermilion Farm #4', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(327, 1, 0, 0, 0, 0, 'Vermilion Farm #4', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(328, 0, 0, 0, 0, 0, 'Vermilion Farm #5', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(328, 1, 0, 0, 0, 0, 'Vermilion Farm #5', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(329, 0, 0, 0, 0, 0, 'Vermilion Farm #6', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(329, 1, 0, 0, 0, 0, 'Vermilion Farm #6', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(330, 0, 0, 0, 0, 0, 'Vermilion Farm #7', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(330, 1, 0, 0, 0, 0, 'Vermilion Farm #7', 6, 9, 500, 500, 1, 0, 10, 0, 0),
(331, 0, 0, 0, 0, 0, 'Vermilion House #1', 6, 135, 9900, 9900, 8, 6, 198, 0, 0),
(331, 1, 0, 0, 0, 0, 'Vermilion House #1', 6, 135, 9900, 9900, 8, 6, 198, 0, 0),
(332, 0, 0, 0, 0, 0, 'Vermilion House #2', 6, 162, 11400, 11400, 6, 4, 228, 0, 0),
(332, 1, 0, 0, 0, 0, 'Vermilion House #2', 6, 162, 11400, 11400, 6, 4, 228, 0, 0),
(333, 0, 0, 0, 0, 0, 'Vermilion House #3', 6, 136, 8600, 8600, 4, 2, 172, 0, 0),
(333, 1, 0, 0, 0, 0, 'Vermilion House #3', 6, 136, 8600, 8600, 4, 2, 172, 0, 0),
(334, 0, 0, 0, 0, 0, 'Vermilion House #4', 6, 67, 4750, 4750, 2, 2, 95, 0, 0),
(334, 1, 0, 0, 0, 0, 'Vermilion House #4', 6, 67, 4750, 4750, 2, 2, 95, 0, 0),
(335, 0, 0, 0, 0, 0, 'Vermilion House #5', 6, 188, 13400, 13400, 9, 4, 268, 0, 0),
(335, 1, 0, 0, 0, 0, 'Vermilion House #5', 6, 188, 13400, 13400, 9, 4, 268, 0, 0),
(336, 0, 0, 0, 0, 0, 'Vermilion House #6', 6, 126, 9350, 9350, 4, 6, 187, 0, 0),
(336, 1, 0, 0, 0, 0, 'Vermilion House #6', 6, 126, 9350, 9350, 4, 6, 187, 0, 0),
(337, 0, 0, 0, 0, 0, 'Vermilion House #7', 6, 134, 9400, 9400, 3, 4, 188, 0, 0),
(337, 1, 0, 0, 0, 0, 'Vermilion House #7', 6, 134, 9400, 9400, 3, 4, 188, 0, 0),
(338, 0, 0, 0, 0, 0, 'Vermilion House #8', 6, 151, 10100, 10100, 5, 2, 202, 0, 0),
(338, 1, 0, 0, 0, 0, 'Vermilion House #8', 6, 151, 10100, 10100, 5, 2, 202, 0, 0),
(339, 0, 0, 0, 0, 0, 'Vermilion House #9', 6, 197, 13250, 13250, 5, 4, 265, 0, 0),
(339, 1, 0, 0, 0, 0, 'Vermilion House #9', 6, 197, 13250, 13250, 5, 4, 265, 0, 0),
(340, 0, 0, 0, 0, 0, 'Vermilion House #10', 6, 185, 12450, 12450, 3, 4, 249, 0, 0),
(340, 1, 0, 0, 0, 0, 'Vermilion House #10', 6, 185, 12450, 12450, 3, 4, 249, 0, 0),
(341, 0, 0, 0, 0, 0, 'Vermilion House #11', 6, 154, 10300, 10300, 2, 2, 206, 0, 0),
(341, 1, 0, 0, 0, 0, 'Vermilion House #11', 6, 154, 10300, 10300, 2, 2, 206, 0, 0),
(342, 0, 0, 0, 0, 0, 'Vermilion House #12', 6, 121, 8350, 8350, 2, 2, 167, 0, 0),
(342, 1, 0, 0, 0, 0, 'Vermilion House #12', 6, 121, 8350, 8350, 2, 2, 167, 0, 0),
(343, 0, 0, 0, 0, 0, 'Vermilion House #13', 6, 143, 9800, 9800, 4, 4, 196, 0, 0),
(343, 1, 0, 0, 0, 0, 'Vermilion House #13', 6, 143, 9800, 9800, 4, 4, 196, 0, 0),
(344, 0, 0, 0, 0, 0, 'Vermilion House #14', 6, 186, 11950, 11950, 4, 2, 239, 0, 0),
(344, 1, 0, 0, 0, 0, 'Vermilion House #14', 6, 186, 11950, 11950, 4, 2, 239, 0, 0),
(345, 0, 0, 0, 0, 0, 'Vermilion House #15', 6, 108, 7500, 7500, 2, 2, 150, 0, 0),
(345, 1, 0, 0, 0, 0, 'Vermilion House #15', 6, 108, 7500, 7500, 2, 2, 150, 0, 0),
(346, 0, 0, 0, 0, 0, 'Vermilion House #16', 6, 180, 11900, 11900, 5, 2, 238, 0, 0),
(346, 1, 0, 0, 0, 0, 'Vermilion House #16', 6, 180, 11900, 11900, 5, 2, 238, 0, 0),
(347, 0, 0, 0, 0, 0, 'Vermilion Guild House', 6, 785, 55800, 55800, 15, 0, 1116, 1, 0),
(347, 1, 0, 0, 0, 0, 'Vermilion Guild House', 6, 785, 55800, 55800, 15, 0, 1116, 1, 0),
(348, 0, 0, 0, 0, 0, 'Fuchsia Guild House', 8, 531, 35200, 35200, 10, 12, 704, 1, 0),
(348, 1, 0, 0, 0, 0, 'Fuchsia Guild House', 8, 531, 35200, 35200, 10, 12, 704, 1, 0),
(349, 0, 0, 0, 0, 0, 'Fuchsia Farm #1', 8, 24, 1250, 1250, 1, 0, 25, 0, 0),
(349, 1, 0, 0, 0, 0, 'Fuchsia Farm #1', 8, 24, 1250, 1250, 1, 0, 25, 0, 0),
(350, 0, 0, 0, 0, 0, 'Fuchsia Farm #2', 8, 15, 800, 800, 1, 0, 16, 0, 0),
(350, 1, 0, 0, 0, 0, 'Fuchsia Farm #2', 8, 15, 800, 800, 1, 0, 16, 0, 0),
(351, 0, 0, 0, 0, 0, 'Fuchsia Farm #3', 8, 20, 1050, 1050, 1, 0, 21, 0, 0),
(351, 1, 0, 0, 0, 0, 'Fuchsia Farm #3', 8, 20, 1050, 1050, 1, 0, 21, 0, 0),
(352, 0, 0, 0, 0, 0, 'Fuchsia Farm #4', 8, 20, 1050, 1050, 1, 0, 21, 0, 0),
(352, 1, 0, 0, 0, 0, 'Fuchsia Farm #4', 8, 20, 1050, 1050, 1, 0, 21, 0, 0),
(353, 0, 0, 0, 0, 0, 'Fuchsia Farm #5', 8, 25, 1300, 1300, 1, 0, 26, 0, 0),
(353, 1, 0, 0, 0, 0, 'Fuchsia Farm #5', 8, 25, 1300, 1300, 1, 0, 26, 0, 0),
(354, 0, 0, 0, 0, 0, 'Fuchsia Room #1', 8, 13, 1200, 1200, 1, 2, 24, 0, 0),
(354, 1, 0, 0, 0, 0, 'Fuchsia Room #1', 8, 13, 1200, 1200, 1, 2, 24, 0, 0),
(355, 0, 0, 0, 0, 0, 'Fuchsia Room #2', 8, 13, 1100, 1100, 1, 2, 22, 0, 0),
(355, 1, 0, 0, 0, 0, 'Fuchsia Room #2', 8, 13, 1100, 1100, 1, 2, 22, 0, 0),
(356, 0, 0, 0, 0, 0, 'Fuchsia Room #3', 8, 13, 1100, 1100, 1, 2, 22, 0, 0),
(356, 1, 0, 0, 0, 0, 'Fuchsia Room #3', 8, 13, 1100, 1100, 1, 2, 22, 0, 0),
(357, 0, 0, 0, 0, 0, 'Fuchsia House #1', 8, 130, 9200, 9200, 5, 4, 184, 0, 0),
(357, 1, 0, 0, 0, 0, 'Fuchsia House #1', 8, 130, 9200, 9200, 5, 4, 184, 0, 0),
(358, 0, 0, 0, 0, 0, 'Fuchsia House #2', 8, 107, 8400, 8400, 5, 8, 168, 0, 0),
(358, 1, 0, 0, 0, 0, 'Fuchsia House #2', 8, 107, 8400, 8400, 5, 8, 168, 0, 0),
(359, 0, 0, 0, 0, 0, 'Fuchsia House #3', 8, 112, 8400, 8400, 4, 4, 168, 0, 0),
(359, 1, 0, 0, 0, 0, 'Fuchsia House #3', 8, 112, 8400, 8400, 4, 4, 168, 0, 0),
(360, 0, 0, 0, 0, 0, 'Fuchsia House #4', 8, 127, 9300, 9300, 4, 4, 186, 0, 0),
(360, 1, 0, 0, 0, 0, 'Fuchsia House #4', 8, 127, 9300, 9300, 4, 4, 186, 0, 0),
(361, 0, 0, 0, 0, 0, 'Fuchsia House #5', 8, 137, 9450, 9450, 2, 2, 189, 0, 0),
(361, 1, 0, 0, 0, 0, 'Fuchsia House #5', 8, 137, 9450, 9450, 2, 2, 189, 0, 0),
(362, 0, 0, 0, 0, 0, 'Fuchsia House #6', 8, 96, 7400, 7400, 4, 4, 148, 0, 0),
(362, 1, 0, 0, 0, 0, 'Fuchsia House #6', 8, 96, 7400, 7400, 4, 4, 148, 0, 0),
(363, 0, 0, 0, 0, 0, 'Fuchsia House #7', 8, 125, 8950, 8950, 5, 4, 179, 0, 0),
(363, 1, 0, 0, 0, 0, 'Fuchsia House #7', 8, 125, 8950, 8950, 5, 4, 179, 0, 0),
(364, 0, 0, 0, 0, 0, 'Fuchsia House #8', 8, 114, 8300, 8300, 6, 2, 166, 0, 0),
(364, 1, 0, 0, 0, 0, 'Fuchsia House #8', 8, 114, 8300, 8300, 6, 2, 166, 0, 0),
(365, 0, 0, 0, 0, 0, 'Fuchsia House #9', 8, 128, 9050, 9050, 4, 4, 181, 0, 0),
(365, 1, 0, 0, 0, 0, 'Fuchsia House #9', 8, 128, 9050, 9050, 4, 4, 181, 0, 0),
(366, 0, 0, 0, 0, 0, 'Fuchsia House #10', 8, 109, 8350, 8350, 4, 4, 167, 0, 0),
(366, 1, 0, 0, 0, 0, 'Fuchsia House #10', 8, 109, 8350, 8350, 4, 4, 167, 0, 0),
(367, 0, 0, 0, 0, 0, 'Fuchsia House #11', 8, 141, 10100, 10100, 4, 4, 202, 0, 0),
(367, 1, 0, 0, 0, 0, 'Fuchsia House #11', 8, 141, 10100, 10100, 4, 4, 202, 0, 0),
(368, 0, 0, 0, 0, 0, 'Fuchsia House #12', 8, 196, 13350, 13350, 7, 4, 267, 0, 0),
(368, 1, 0, 0, 0, 0, 'Fuchsia House #12', 8, 196, 13350, 13350, 7, 4, 267, 0, 0),
(369, 0, 0, 0, 0, 0, 'Fuchsia House #13', 8, 159, 11400, 11400, 3, 4, 228, 0, 0),
(369, 1, 0, 0, 0, 0, 'Fuchsia House #13', 8, 159, 11400, 11400, 3, 4, 228, 0, 0),
(370, 0, 0, 0, 0, 0, 'Fuchsia House #14', 8, 100, 7400, 7400, 3, 4, 148, 0, 0),
(370, 1, 0, 0, 0, 0, 'Fuchsia House #14', 8, 100, 7400, 7400, 3, 4, 148, 0, 0),
(371, 0, 0, 0, 0, 0, 'Fuchsia House #15', 8, 131, 9050, 9050, 6, 2, 181, 0, 0),
(371, 1, 0, 0, 0, 0, 'Fuchsia House #15', 8, 131, 9050, 9050, 6, 2, 181, 0, 0),
(372, 0, 0, 0, 0, 0, 'Fuchsia House #16', 8, 147, 10200, 10200, 3, 4, 204, 0, 0),
(372, 1, 0, 0, 0, 0, 'Fuchsia House #16', 8, 147, 10200, 10200, 3, 4, 204, 0, 0),
(373, 0, 0, 0, 0, 0, 'Cinnabar Guild House', 9, 457, 37200, 37200, 16, 20, 744, 1, 0),
(373, 1, 0, 0, 0, 0, 'Cinnabar Guild House', 9, 457, 37200, 37200, 16, 20, 744, 1, 0),
(374, 0, 0, 0, 0, 0, 'Cinnabar House #1', 9, 22, 1700, 1700, 1, 2, 34, 0, 0),
(374, 1, 0, 0, 0, 0, 'Cinnabar House #1', 9, 22, 1700, 1700, 1, 2, 34, 0, 0),
(375, 0, 0, 0, 0, 0, 'Cinnabar House #2', 9, 22, 1650, 1650, 1, 2, 33, 0, 0),
(375, 1, 0, 0, 0, 0, 'Cinnabar House #2', 9, 22, 1650, 1650, 1, 2, 33, 0, 0),
(376, 0, 0, 0, 0, 0, 'Cinnabar House #3', 9, 127, 8950, 8950, 7, 4, 179, 0, 0),
(376, 1, 0, 0, 0, 0, 'Cinnabar House #3', 9, 127, 8950, 8950, 7, 4, 179, 0, 0),
(377, 0, 0, 0, 0, 0, 'Cinnabar House #4', 9, 64, 4900, 4900, 4, 4, 98, 0, 0),
(377, 1, 0, 0, 0, 0, 'Cinnabar House #4', 9, 64, 4900, 4900, 4, 4, 98, 0, 0),
(378, 0, 0, 0, 0, 0, 'Cinnabar House #5', 9, 103, 7850, 7850, 5, 6, 157, 0, 0),
(378, 1, 0, 0, 0, 0, 'Cinnabar House #5', 9, 103, 7850, 7850, 5, 6, 157, 0, 0),
(379, 0, 0, 0, 0, 0, 'Cinnabar House #6', 9, 130, 9200, 9200, 5, 4, 184, 0, 0),
(379, 1, 0, 0, 0, 0, 'Cinnabar House #6', 9, 130, 9200, 9200, 5, 4, 184, 0, 0),
(380, 0, 0, 0, 0, 0, 'Cinnabar House #7', 9, 70, 5450, 5450, 7, 4, 109, 0, 0),
(380, 1, 0, 0, 0, 0, 'Cinnabar House #7', 9, 70, 5450, 5450, 7, 4, 109, 0, 0),
(381, 0, 0, 0, 0, 0, 'Cinnabar House #8', 9, 164, 11350, 11350, 5, 4, 227, 0, 0),
(381, 1, 0, 0, 0, 0, 'Cinnabar House #8', 9, 164, 11350, 11350, 5, 4, 227, 0, 0),
(382, 0, 0, 0, 0, 0, 'Cinnabar House #9', 9, 135, 9500, 9500, 3, 2, 190, 0, 0),
(382, 1, 0, 0, 0, 0, 'Cinnabar House #9', 9, 135, 9500, 9500, 3, 2, 190, 0, 0),
(383, 0, 0, 0, 0, 0, 'Cinnabar House #10', 9, 127, 9050, 9050, 6, 2, 181, 0, 0),
(383, 1, 0, 0, 0, 0, 'Cinnabar House #10', 9, 127, 9050, 9050, 6, 2, 181, 0, 0),
(384, 0, 0, 0, 0, 0, 'Cinnabar House #11', 9, 114, 8250, 8250, 4, 4, 165, 0, 0),
(384, 1, 0, 0, 0, 0, 'Cinnabar House #11', 9, 114, 8250, 8250, 4, 4, 165, 0, 0),
(385, 0, 0, 0, 0, 0, 'Cinnabar House #12', 9, 99, 7200, 7200, 8, 2, 144, 0, 0),
(385, 1, 0, 0, 0, 0, 'Cinnabar House #12', 9, 99, 7200, 7200, 8, 2, 144, 0, 0),
(386, 0, 0, 0, 0, 0, 'Cinnabar House #13', 9, 79, 5700, 5700, 4, 2, 114, 0, 0),
(386, 1, 0, 0, 0, 0, 'Cinnabar House #13', 9, 79, 5700, 5700, 4, 2, 114, 0, 0),
(387, 0, 0, 0, 0, 0, 'Pallet House #4', 32, 69, 5100, 5100, 3, 0, 102, 0, 0),
(387, 1, 0, 0, 0, 0, 'Pallet House #4', 32, 69, 5100, 5100, 3, 0, 102, 0, 0),
(388, 0, 0, 0, 0, 0, 'Dewford House #01', 39, 110, 7850, 7850, 4, 2, 157, 0, 0),
(388, 1, 0, 0, 0, 0, 'Dewford House #01', 39, 110, 7850, 7850, 4, 2, 157, 0, 0),
(389, 0, 0, 0, 0, 0, 'Dewford House #02', 39, 84, 6000, 6000, 2, 2, 120, 0, 0),
(389, 1, 0, 0, 0, 0, 'Dewford House #02', 39, 84, 6000, 6000, 2, 2, 120, 0, 0),
(390, 0, 0, 0, 0, 0, 'Dewford House #03', 39, 114, 8150, 8150, 4, 4, 163, 0, 0),
(390, 1, 0, 0, 0, 0, 'Dewford House #03', 39, 114, 8150, 8150, 4, 4, 163, 0, 0),
(391, 0, 0, 0, 0, 0, 'Dewford House #04', 39, 148, 10750, 10750, 6, 4, 215, 0, 0),
(391, 1, 0, 0, 0, 0, 'Dewford House #04', 39, 148, 10750, 10750, 6, 4, 215, 0, 0),
(392, 0, 0, 0, 0, 0, 'Dewford House #05', 39, 91, 6550, 6550, 3, 0, 131, 0, 0),
(392, 1, 0, 0, 0, 0, 'Dewford House #05', 39, 91, 6550, 6550, 3, 0, 131, 0, 0),
(393, 0, 0, 0, 0, 0, 'Unnamed House #393', 39, 166, 10950, 10950, 6, 0, 219, 0, 0),
(393, 1, 0, 0, 0, 0, 'Unnamed House #393', 39, 166, 10950, 10950, 6, 0, 219, 0, 0),
(394, 0, 0, 0, 0, 0, 'Dewford House #06', 39, 118, 8400, 8400, 4, 2, 168, 0, 0),
(394, 1, 0, 0, 0, 0, 'Dewford House #06', 39, 118, 8400, 8400, 4, 2, 168, 0, 0),
(395, 0, 0, 0, 0, 0, 'Dewford House #07', 39, 57, 4700, 4700, 4, 4, 94, 0, 0),
(395, 1, 0, 0, 0, 0, 'Dewford House #07', 39, 57, 4700, 4700, 4, 4, 94, 0, 0),
(396, 0, 0, 0, 0, 0, 'Dewford House #08', 39, 175, 11950, 11950, 4, 2, 239, 0, 0),
(396, 1, 0, 0, 0, 0, 'Dewford House #08', 39, 175, 11950, 11950, 4, 2, 239, 0, 0),
(397, 0, 0, 0, 0, 0, 'Littleroot House #01', 35, 130, 9300, 9300, 4, 4, 186, 0, 0),
(397, 1, 0, 0, 0, 0, 'Littleroot House #01', 35, 130, 9300, 9300, 4, 4, 186, 0, 0),
(398, 0, 0, 0, 0, 0, 'Littleroot House #02', 35, 74, 5750, 5750, 3, 4, 115, 0, 0),
(398, 1, 0, 0, 0, 0, 'Littleroot House #02', 35, 74, 5750, 5750, 3, 4, 115, 0, 0),
(399, 0, 0, 0, 0, 0, 'Littleroot House #03', 35, 127, 8900, 8900, 4, 4, 178, 0, 0),
(399, 1, 0, 0, 0, 0, 'Littleroot House #03', 35, 127, 8900, 8900, 4, 4, 178, 0, 0),
(400, 0, 0, 0, 0, 0, 'Littleroot House #04', 35, 132, 9150, 9150, 3, 2, 183, 0, 0),
(400, 1, 0, 0, 0, 0, 'Littleroot House #04', 35, 132, 9150, 9150, 3, 2, 183, 0, 0),
(401, 0, 0, 0, 0, 0, 'Littleroot House #05', 35, 58, 4550, 4550, 4, 4, 91, 0, 0),
(401, 1, 0, 0, 0, 0, 'Littleroot House #05', 35, 58, 4550, 4550, 4, 4, 91, 0, 0),
(402, 0, 0, 0, 0, 0, 'Littleroot House #06', 35, 123, 8500, 8500, 3, 4, 170, 0, 0),
(402, 1, 0, 0, 0, 0, 'Littleroot House #06', 35, 123, 8500, 8500, 3, 4, 170, 0, 0),
(403, 0, 0, 0, 0, 0, 'Littleroot House #07', 35, 130, 9500, 9500, 3, 4, 190, 0, 0),
(403, 1, 0, 0, 0, 0, 'Littleroot House #07', 35, 130, 9500, 9500, 3, 4, 190, 0, 0),
(404, 0, 0, 0, 0, 0, 'Littleroot House #08', 35, 137, 9400, 9400, 3, 2, 188, 0, 0),
(404, 1, 0, 0, 0, 0, 'Littleroot House #08', 35, 137, 9400, 9400, 3, 2, 188, 0, 0),
(405, 0, 0, 0, 0, 0, 'Oldale House #01', 36, 124, 9850, 9850, 6, 8, 197, 0, 0),
(405, 1, 0, 0, 0, 0, 'Oldale House #01', 36, 124, 9850, 9850, 6, 8, 197, 0, 0),
(406, 0, 0, 0, 0, 0, 'Oldale House #02', 36, 78, 5350, 5350, 3, 2, 107, 0, 0),
(406, 1, 0, 0, 0, 0, 'Oldale House #02', 36, 78, 5350, 5350, 3, 2, 107, 0, 0),
(407, 0, 0, 0, 0, 0, 'Oldale House #03', 36, 88, 5950, 5950, 3, 2, 119, 0, 0),
(407, 1, 0, 0, 0, 0, 'Oldale House #03', 36, 88, 5950, 5950, 3, 2, 119, 0, 0),
(408, 0, 0, 0, 0, 0, 'Oldale House #04', 36, 127, 9300, 9300, 3, 4, 186, 0, 0),
(408, 1, 0, 0, 0, 0, 'Oldale House #04', 36, 127, 9300, 9300, 3, 4, 186, 0, 0),
(409, 0, 0, 0, 0, 0, 'Oldale House #05', 36, 34, 2900, 2900, 2, 2, 58, 0, 0),
(409, 1, 0, 0, 0, 0, 'Oldale House #05', 36, 34, 2900, 2900, 2, 2, 58, 0, 0),
(410, 0, 0, 0, 0, 0, 'Oldale House #06', 36, 34, 2850, 2850, 2, 2, 57, 0, 0),
(410, 1, 0, 0, 0, 0, 'Oldale House #06', 36, 34, 2850, 2850, 2, 2, 57, 0, 0),
(411, 0, 0, 0, 0, 0, 'Oldale House #07', 36, 168, 11350, 11350, 4, 4, 227, 0, 0),
(411, 1, 0, 0, 0, 0, 'Oldale House #07', 36, 168, 11350, 11350, 4, 4, 227, 0, 0),
(412, 0, 0, 0, 0, 0, 'Oldale House #08', 36, 142, 10150, 10150, 4, 4, 203, 0, 0),
(412, 1, 0, 0, 0, 0, 'Oldale House #08', 36, 142, 10150, 10150, 4, 4, 203, 0, 0),
(413, 0, 0, 0, 0, 0, 'Petalburg House #01', 37, 166, 11850, 11850, 6, 10, 237, 0, 0),
(413, 1, 0, 0, 0, 0, 'Petalburg House #01', 37, 166, 11850, 11850, 6, 10, 237, 0, 0),
(414, 0, 0, 0, 0, 0, 'Petalburg House #02', 37, 148, 10950, 10950, 8, 4, 219, 0, 0),
(414, 1, 0, 0, 0, 0, 'Petalburg House #02', 37, 148, 10950, 10950, 8, 4, 219, 0, 0),
(415, 0, 0, 0, 0, 0, 'Petalburg House #03', 37, 128, 9800, 9800, 6, 6, 196, 0, 0),
(415, 1, 0, 0, 0, 0, 'Petalburg House #03', 37, 128, 9800, 9800, 6, 6, 196, 0, 0),
(416, 0, 0, 0, 0, 0, 'Petalburg House #04', 37, 125, 8850, 8850, 3, 4, 177, 0, 0),
(416, 1, 0, 0, 0, 0, 'Petalburg House #04', 37, 125, 8850, 8850, 3, 4, 177, 0, 0),
(417, 0, 0, 0, 0, 0, 'Petalburg House #05', 37, 176, 12100, 12100, 6, 4, 242, 0, 0),
(417, 1, 0, 0, 0, 0, 'Petalburg House #05', 37, 176, 12100, 12100, 6, 4, 242, 0, 0),
(418, 0, 0, 0, 0, 0, 'Petalburg Apartment #01', 37, 18, 1250, 1250, 1, 2, 25, 0, 0),
(418, 1, 0, 0, 0, 0, 'Petalburg Apartment #01', 37, 18, 1250, 1250, 1, 2, 25, 0, 0),
(419, 0, 0, 0, 0, 0, 'Petalburg Apartment #02', 37, 18, 1350, 1350, 1, 2, 27, 0, 0),
(419, 1, 0, 0, 0, 0, 'Petalburg Apartment #02', 37, 18, 1350, 1350, 1, 2, 27, 0, 0),
(420, 0, 0, 0, 0, 0, 'Petalburg Apartment #03', 37, 7, 750, 750, 1, 2, 15, 0, 0),
(420, 1, 0, 0, 0, 0, 'Petalburg Apartment #03', 37, 7, 750, 750, 1, 2, 15, 0, 0),
(421, 0, 0, 0, 0, 0, 'Petalburg Apartment #04', 37, 7, 800, 800, 1, 2, 16, 0, 0),
(421, 1, 0, 0, 0, 0, 'Petalburg Apartment #04', 37, 7, 800, 800, 1, 2, 16, 0, 0),
(422, 0, 0, 0, 0, 0, 'Petalburg House #06', 37, 83, 5700, 5700, 6, 2, 114, 0, 0),
(422, 1, 0, 0, 0, 0, 'Petalburg House #06', 37, 83, 5700, 5700, 6, 2, 114, 0, 0),
(423, 0, 0, 0, 0, 0, 'Petalburg House #07', 37, 141, 10200, 10200, 4, 4, 204, 0, 0),
(423, 1, 0, 0, 0, 0, 'Petalburg House #07', 37, 141, 10200, 10200, 4, 4, 204, 0, 0),
(424, 0, 0, 0, 0, 0, 'Rustboro House #01', 38, 113, 8600, 8600, 4, 4, 172, 0, 0),
(424, 1, 0, 0, 0, 0, 'Rustboro House #01', 38, 113, 8600, 8600, 4, 4, 172, 0, 0),
(425, 0, 0, 0, 0, 0, 'Rustboro House #02', 38, 89, 7200, 7200, 3, 4, 144, 0, 0),
(425, 1, 0, 0, 0, 0, 'Rustboro House #02', 38, 89, 7200, 7200, 3, 4, 144, 0, 0),
(426, 0, 0, 0, 0, 0, 'Rustboro House #03', 38, 103, 9250, 9250, 6, 6, 185, 0, 0),
(426, 1, 0, 0, 0, 0, 'Rustboro House #03', 38, 103, 9250, 9250, 6, 6, 185, 0, 0),
(427, 0, 0, 0, 0, 0, 'Rustboro House #04', 38, 95, 7750, 7750, 3, 4, 155, 0, 0),
(427, 1, 0, 0, 0, 0, 'Rustboro House #04', 38, 95, 7750, 7750, 3, 4, 155, 0, 0),
(428, 0, 0, 0, 0, 0, 'Rustboro House #05', 38, 158, 12000, 12000, 4, 6, 240, 0, 0),
(428, 1, 0, 0, 0, 0, 'Rustboro House #05', 38, 158, 12000, 12000, 4, 6, 240, 0, 0),
(429, 0, 0, 0, 0, 0, 'Rustboro House #06', 38, 122, 10000, 10000, 4, 6, 200, 0, 0),
(429, 1, 0, 0, 0, 0, 'Rustboro House #06', 38, 122, 10000, 10000, 4, 6, 200, 0, 0),
(430, 0, 0, 0, 0, 0, 'Rustboro House #07', 38, 109, 9000, 9000, 4, 6, 180, 0, 0),
(430, 1, 0, 0, 0, 0, 'Rustboro House #07', 38, 109, 9000, 9000, 4, 6, 180, 0, 0),
(431, 0, 0, 0, 0, 0, 'Rustboro House #08', 38, 63, 4950, 4950, 2, 2, 99, 0, 0),
(431, 1, 0, 0, 0, 0, 'Rustboro House #08', 38, 63, 4950, 4950, 2, 2, 99, 0, 0),
(432, 0, 0, 0, 0, 0, 'Rustboro House #09', 38, 164, 13000, 13000, 4, 6, 260, 0, 0),
(432, 1, 0, 0, 0, 0, 'Rustboro House #09', 38, 164, 13000, 13000, 4, 6, 260, 0, 0),
(433, 0, 0, 0, 0, 0, 'Rustboro House #10', 38, 68, 5000, 5000, 2, 2, 100, 0, 0),
(433, 1, 0, 0, 0, 0, 'Rustboro House #10', 38, 68, 5000, 5000, 2, 2, 100, 0, 0),
(434, 0, 0, 0, 0, 0, 'Rustboro House #11', 38, 44, 3600, 3600, 2, 2, 72, 0, 0),
(434, 1, 0, 0, 0, 0, 'Rustboro House #11', 38, 44, 3600, 3600, 2, 2, 72, 0, 0),
(435, 0, 0, 0, 0, 0, 'Rustboro House #12', 38, 126, 9950, 9950, 4, 6, 199, 0, 0),
(435, 1, 0, 0, 0, 0, 'Rustboro House #12', 38, 126, 9950, 9950, 4, 6, 199, 0, 0),
(436, 0, 0, 0, 0, 0, 'Rustboro House #13', 38, 151, 11050, 11050, 2, 2, 221, 0, 0),
(436, 1, 0, 0, 0, 0, 'Rustboro House #13', 38, 151, 11050, 11050, 2, 2, 221, 0, 0),
(437, 0, 0, 0, 0, 0, 'Rustboro House #14', 38, 24, 2050, 2050, 2, 2, 41, 0, 0),
(437, 1, 0, 0, 0, 0, 'Rustboro House #14', 38, 24, 2050, 2050, 2, 2, 41, 0, 0),
(438, 0, 0, 0, 0, 0, 'Rustboro House #15', 38, 132, 10050, 10050, 4, 6, 201, 0, 0),
(438, 1, 0, 0, 0, 0, 'Rustboro House #15', 38, 132, 10050, 10050, 4, 6, 201, 0, 0),
(439, 0, 0, 0, 0, 0, 'Slateport House #01', 40, 64, 5600, 5600, 8, 2, 112, 0, 0),
(439, 1, 0, 0, 0, 0, 'Slateport House #01', 40, 64, 5600, 5600, 8, 2, 112, 0, 0),
(440, 0, 0, 0, 0, 0, 'Slateport House #02', 40, 78, 7200, 7200, 10, 4, 144, 0, 0),
(440, 1, 0, 0, 0, 0, 'Slateport House #02', 40, 78, 7200, 7200, 10, 4, 144, 0, 0),
(441, 0, 0, 0, 0, 0, 'Slateport House #03', 40, 167, 12600, 12600, 18, 4, 252, 0, 0),
(441, 1, 0, 0, 0, 0, 'Slateport House #03', 40, 167, 12600, 12600, 18, 4, 252, 0, 0),
(442, 0, 0, 0, 0, 0, 'Slateport House #04', 40, 157, 12050, 12050, 12, 6, 241, 0, 0),
(442, 1, 0, 0, 0, 0, 'Slateport House #04', 40, 157, 12050, 12050, 12, 6, 241, 0, 0),
(443, 0, 0, 0, 0, 0, 'Slateport House #05', 40, 197, 14450, 14450, 15, 4, 289, 0, 0),
(443, 1, 0, 0, 0, 0, 'Slateport House #05', 40, 197, 14450, 14450, 15, 4, 289, 0, 0),
(444, 0, 0, 0, 0, 0, 'Slateport House #06', 40, 211, 15450, 15450, 17, 4, 309, 0, 0),
(444, 1, 0, 0, 0, 0, 'Slateport House #06', 40, 211, 15450, 15450, 17, 4, 309, 0, 0),
(445, 0, 0, 0, 0, 0, 'Slateport House #07', 40, 241, 18150, 18150, 16, 8, 363, 0, 0),
(445, 1, 0, 0, 0, 0, 'Slateport House #07', 40, 241, 18150, 18150, 16, 8, 363, 0, 0),
(446, 0, 0, 0, 0, 0, 'Slateport House #08', 40, 134, 10450, 10450, 11, 4, 209, 0, 0),
(446, 1, 0, 0, 0, 0, 'Slateport House #08', 40, 134, 10450, 10450, 11, 4, 209, 0, 0),
(447, 0, 0, 0, 0, 0, 'Slateport House #09', 40, 162, 12500, 12500, 15, 4, 250, 0, 0),
(447, 1, 0, 0, 0, 0, 'Slateport House #09', 40, 162, 12500, 12500, 15, 4, 250, 0, 0),
(448, 0, 0, 0, 0, 0, 'Slateport House #10', 40, 199, 14400, 14400, 17, 4, 288, 0, 0),
(448, 1, 0, 0, 0, 0, 'Slateport House #10', 40, 199, 14400, 14400, 17, 4, 288, 0, 0),
(449, 0, 0, 0, 0, 0, 'Slateport House #11', 40, 87, 6500, 6500, 5, 4, 130, 0, 0),
(449, 1, 0, 0, 0, 0, 'Slateport House #11', 40, 87, 6500, 6500, 5, 4, 130, 0, 0),
(450, 0, 0, 0, 0, 0, 'Slateport House #12', 40, 288, 19550, 19550, 16, 6, 391, 0, 0),
(450, 1, 0, 0, 0, 0, 'Slateport House #12', 40, 288, 19550, 19550, 16, 6, 391, 0, 0),
(451, 0, 0, 0, 0, 0, 'Slateport House #13', 40, 121, 8300, 8300, 7, 2, 166, 0, 0),
(451, 1, 0, 0, 0, 0, 'Slateport House #13', 40, 121, 8300, 8300, 7, 2, 166, 0, 0),
(452, 0, 0, 0, 0, 0, 'Slateport House #14', 40, 223, 16250, 16250, 17, 6, 325, 0, 0),
(452, 1, 0, 0, 0, 0, 'Slateport House #14', 40, 223, 16250, 16250, 17, 6, 325, 0, 0),
(453, 0, 0, 0, 0, 0, 'Slateport House #15', 40, 185, 13200, 13200, 13, 6, 264, 0, 0),
(453, 1, 0, 0, 0, 0, 'Slateport House #15', 40, 185, 13200, 13200, 13, 6, 264, 0, 0),
(454, 0, 0, 0, 0, 0, 'Slateport House #16', 40, 152, 11000, 11000, 8, 4, 220, 0, 0),
(454, 1, 0, 0, 0, 0, 'Slateport House #16', 40, 152, 11000, 11000, 8, 4, 220, 0, 0),
(455, 0, 0, 0, 0, 0, 'Slateport House #17', 40, 178, 13050, 13050, 12, 4, 261, 0, 0),
(455, 1, 0, 0, 0, 0, 'Slateport House #17', 40, 178, 13050, 13050, 12, 4, 261, 0, 0),
(456, 0, 0, 0, 0, 0, 'Slateport Apartment #01', 40, 27, 2250, 2250, 5, 2, 45, 0, 0),
(456, 1, 0, 0, 0, 0, 'Slateport Apartment #01', 40, 27, 2250, 2250, 5, 2, 45, 0, 0),
(457, 0, 0, 0, 0, 0, 'Slateport Apartment #02', 40, 19, 1850, 1850, 2, 2, 37, 0, 0),
(457, 1, 0, 0, 0, 0, 'Slateport Apartment #02', 40, 19, 1850, 1850, 2, 2, 37, 0, 0),
(458, 0, 0, 0, 0, 0, 'Slateport Apartment #03', 40, 32, 2750, 2750, 4, 2, 55, 0, 0),
(458, 1, 0, 0, 0, 0, 'Slateport Apartment #03', 40, 32, 2750, 2750, 4, 2, 55, 0, 0),
(459, 0, 0, 0, 0, 0, 'Slateport Apartment #04', 40, 61, 4950, 4950, 6, 2, 99, 0, 0),
(459, 1, 0, 0, 0, 0, 'Slateport Apartment #04', 40, 61, 4950, 4950, 6, 2, 99, 0, 0),
(460, 0, 0, 0, 0, 0, 'Mauville Apartment #01', 41, 62, 4650, 4650, 2, 2, 93, 0, 0),
(460, 1, 0, 0, 0, 0, 'Mauville Apartment #01', 41, 62, 4650, 4650, 2, 2, 93, 0, 0),
(461, 0, 0, 0, 0, 0, 'Mauville Apartment #02', 41, 84, 6050, 6050, 2, 2, 121, 0, 0),
(461, 1, 0, 0, 0, 0, 'Mauville Apartment #02', 41, 84, 6050, 6050, 2, 2, 121, 0, 0),
(462, 0, 0, 0, 0, 0, 'Mauville Apartment #03', 41, 42, 3550, 3550, 2, 2, 71, 0, 0),
(462, 1, 0, 0, 0, 0, 'Mauville Apartment #03', 41, 42, 3550, 3550, 2, 2, 71, 0, 0),
(463, 0, 0, 0, 0, 0, 'Mauville Apartment #04', 41, 49, 4400, 4400, 2, 2, 88, 0, 0),
(463, 1, 0, 0, 0, 0, 'Mauville Apartment #04', 41, 49, 4400, 4400, 2, 2, 88, 0, 0),
(464, 0, 0, 0, 0, 0, 'Mauville Apartment #05', 41, 48, 3750, 3750, 2, 2, 75, 0, 0),
(464, 1, 0, 0, 0, 0, 'Mauville Apartment #05', 41, 48, 3750, 3750, 2, 2, 75, 0, 0),
(465, 0, 0, 0, 0, 0, 'Mauville Apartment #06', 41, 67, 5200, 5200, 2, 2, 104, 0, 0),
(465, 1, 0, 0, 0, 0, 'Mauville Apartment #06', 41, 67, 5200, 5200, 2, 2, 104, 0, 0),
(466, 0, 0, 0, 0, 0, 'Mauville Apartment #07', 41, 76, 6000, 6000, 3, 4, 120, 0, 0),
(466, 1, 0, 0, 0, 0, 'Mauville Apartment #07', 41, 76, 6000, 6000, 3, 4, 120, 0, 0),
(467, 0, 0, 0, 0, 0, 'Mauville Apartment #08', 41, 84, 6500, 6500, 4, 4, 130, 0, 0),
(467, 1, 0, 0, 0, 0, 'Mauville Apartment #08', 41, 84, 6500, 6500, 4, 4, 130, 0, 0),
(468, 0, 0, 0, 0, 0, 'Mauville Apartment #09', 41, 53, 4100, 4100, 2, 2, 82, 0, 0),
(468, 1, 0, 0, 0, 0, 'Mauville Apartment #09', 41, 53, 4100, 4100, 2, 2, 82, 0, 0),
(469, 0, 0, 0, 0, 0, 'Mauville Apartment #10', 41, 74, 4950, 4950, 2, 2, 99, 0, 0),
(469, 1, 0, 0, 0, 0, 'Mauville Apartment #10', 41, 74, 4950, 4950, 2, 2, 99, 0, 0),
(470, 0, 0, 0, 0, 0, 'Mauville Apartment #11', 41, 96, 6850, 6850, 4, 2, 137, 0, 0),
(470, 1, 0, 0, 0, 0, 'Mauville Apartment #11', 41, 96, 6850, 6850, 4, 2, 137, 0, 0),
(471, 0, 0, 0, 0, 0, 'Mauville Apartment #12', 41, 107, 7500, 7500, 4, 2, 150, 0, 0),
(471, 1, 0, 0, 0, 0, 'Mauville Apartment #12', 41, 107, 7500, 7500, 4, 2, 150, 0, 0),
(472, 0, 0, 0, 0, 0, 'Mauville Apartment #13', 41, 63, 4750, 4750, 4, 2, 95, 0, 0),
(472, 1, 0, 0, 0, 0, 'Mauville Apartment #13', 41, 63, 4750, 4750, 4, 2, 95, 0, 0),
(473, 0, 0, 0, 0, 0, 'Mauville Apartment #14', 41, 106, 7500, 7500, 4, 2, 150, 0, 0),
(473, 1, 0, 0, 0, 0, 'Mauville Apartment #14', 41, 106, 7500, 7500, 4, 2, 150, 0, 0),
(474, 0, 0, 0, 0, 0, 'Mauville Apartment #15', 41, 91, 6500, 6500, 2, 2, 130, 0, 0),
(474, 1, 0, 0, 0, 0, 'Mauville Apartment #15', 41, 91, 6500, 6500, 2, 2, 130, 0, 0),
(475, 0, 0, 0, 0, 0, 'Mauville Apartment #16', 41, 79, 6500, 6500, 3, 4, 130, 0, 0),
(475, 1, 0, 0, 0, 0, 'Mauville Apartment #16', 41, 79, 6500, 6500, 3, 4, 130, 0, 0),
(476, 0, 0, 0, 0, 0, 'Mauville Apartment #17', 41, 95, 7100, 7100, 4, 4, 142, 0, 0),
(476, 1, 0, 0, 0, 0, 'Mauville Apartment #17', 41, 95, 7100, 7100, 4, 4, 142, 0, 0),
(477, 0, 0, 0, 0, 0, 'Mauville Apartment #18', 41, 63, 4800, 4800, 4, 2, 96, 0, 0),
(477, 1, 0, 0, 0, 0, 'Mauville Apartment #18', 41, 63, 4800, 4800, 4, 2, 96, 0, 0),
(478, 0, 0, 0, 0, 0, 'Mauville Apartment #19', 41, 103, 8100, 8100, 6, 4, 162, 0, 0),
(478, 1, 0, 0, 0, 0, 'Mauville Apartment #19', 41, 103, 8100, 8100, 6, 4, 162, 0, 0),
(479, 0, 0, 0, 0, 0, 'Mauville Apartment #20', 41, 74, 6100, 6100, 5, 4, 122, 0, 0),
(479, 1, 0, 0, 0, 0, 'Mauville Apartment #20', 41, 74, 6100, 6100, 5, 4, 122, 0, 0),
(480, 0, 0, 0, 0, 0, 'Verdanturf House #01', 42, 91, 6650, 6650, 2, 2, 133, 0, 0),
(480, 1, 0, 0, 0, 0, 'Verdanturf House #01', 42, 91, 6650, 6650, 2, 2, 133, 0, 0),
(481, 0, 0, 0, 0, 0, 'Verdanturf House #02', 42, 121, 9900, 9900, 4, 6, 198, 0, 0),
(481, 1, 0, 0, 0, 0, 'Verdanturf House #02', 42, 121, 9900, 9900, 4, 6, 198, 0, 0),
(482, 0, 0, 0, 0, 0, 'Verdanturf House #03', 42, 144, 11000, 11000, 5, 6, 220, 0, 0),
(482, 1, 0, 0, 0, 0, 'Verdanturf House #03', 42, 144, 11000, 11000, 5, 6, 220, 0, 0),
(483, 0, 0, 0, 0, 0, 'Verdanturf House #04', 42, 126, 9950, 9950, 4, 4, 199, 0, 0),
(483, 1, 0, 0, 0, 0, 'Verdanturf House #04', 42, 126, 9950, 9950, 4, 4, 199, 0, 0),
(484, 0, 0, 0, 0, 0, 'Verdanturf House #05', 42, 125, 10050, 10050, 4, 4, 201, 0, 0),
(484, 1, 0, 0, 0, 0, 'Verdanturf House #05', 42, 125, 10050, 10050, 4, 4, 201, 0, 0),
(485, 0, 0, 0, 0, 0, 'Verdanturf House #06', 42, 157, 12150, 12150, 4, 4, 243, 0, 0),
(485, 1, 0, 0, 0, 0, 'Verdanturf House #06', 42, 157, 12150, 12150, 4, 4, 243, 0, 0),
(486, 0, 0, 0, 0, 0, 'Verdanturf House #07', 42, 131, 10000, 10000, 4, 4, 200, 0, 0),
(486, 1, 0, 0, 0, 0, 'Verdanturf House #07', 42, 131, 10000, 10000, 4, 4, 200, 0, 0),
(487, 0, 0, 0, 0, 0, 'Verdanturf Apartment #01', 42, 22, 1800, 1800, 1, 2, 36, 0, 0),
(487, 1, 0, 0, 0, 0, 'Verdanturf Apartment #01', 42, 22, 1800, 1800, 1, 2, 36, 0, 0),
(488, 0, 0, 0, 0, 0, 'Verdanturf Apartment #02', 42, 22, 1800, 1800, 1, 2, 36, 0, 0),
(488, 1, 0, 0, 0, 0, 'Verdanturf Apartment #02', 42, 22, 1800, 1800, 1, 2, 36, 0, 0),
(489, 0, 0, 0, 0, 0, 'Verdanturf Apartment #03', 42, 28, 2100, 2100, 2, 2, 42, 0, 0),
(489, 1, 0, 0, 0, 0, 'Verdanturf Apartment #03', 42, 28, 2100, 2100, 2, 2, 42, 0, 0),
(490, 0, 0, 0, 0, 0, 'Verdanturf Apartment #04', 42, 28, 2450, 2450, 2, 2, 49, 0, 0),
(490, 1, 0, 0, 0, 0, 'Verdanturf Apartment #04', 42, 28, 2450, 2450, 2, 2, 49, 0, 0),
(491, 0, 0, 0, 0, 0, 'Lavaridge House #01', 44, 156, 10850, 10850, 4, 4, 217, 0, 0),
(491, 1, 0, 0, 0, 0, 'Lavaridge House #01', 44, 156, 10850, 10850, 4, 4, 217, 0, 0),
(492, 0, 0, 0, 0, 0, 'Lavaridge House #02', 44, 131, 9350, 9350, 3, 2, 187, 0, 0),
(492, 1, 0, 0, 0, 0, 'Lavaridge House #02', 44, 131, 9350, 9350, 3, 2, 187, 0, 0),
(493, 0, 0, 0, 0, 0, 'Lavaridge House #03', 44, 116, 8100, 8100, 3, 2, 162, 0, 0),
(493, 1, 0, 0, 0, 0, 'Lavaridge House #03', 44, 116, 8100, 8100, 3, 2, 162, 0, 0),
(494, 0, 0, 0, 0, 0, 'Fallarbor Farm #01', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(494, 1, 0, 0, 0, 0, 'Fallarbor Farm #01', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(495, 0, 0, 0, 0, 0, 'Fallarbor Farm #02', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(495, 1, 0, 0, 0, 0, 'Fallarbor Farm #02', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(496, 0, 0, 0, 0, 0, 'Fallarbor Farm #03', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(496, 1, 0, 0, 0, 0, 'Fallarbor Farm #03', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(497, 0, 0, 0, 0, 0, 'Fallarbor Farm #04', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(497, 1, 0, 0, 0, 0, 'Fallarbor Farm #04', 43, 88, 4450, 4450, 1, 0, 89, 0, 0),
(498, 0, 0, 0, 0, 0, 'Fallarbor House #01', 43, 216, 15650, 15650, 4, 4, 313, 0, 0),
(498, 1, 0, 0, 0, 0, 'Fallarbor House #01', 43, 216, 15650, 15650, 4, 4, 313, 0, 0),
(499, 0, 0, 0, 0, 0, 'Fallarbor House #02', 43, 151, 11050, 11050, 3, 0, 221, 0, 0),
(499, 1, 0, 0, 0, 0, 'Fallarbor House #02', 43, 151, 11050, 11050, 3, 0, 221, 0, 0),
(500, 0, 0, 0, 0, 0, 'Fallarbor House #03', 43, 212, 14650, 14650, 5, 4, 293, 0, 0),
(500, 1, 0, 0, 0, 0, 'Fallarbor House #03', 43, 212, 14650, 14650, 5, 4, 293, 0, 0),
(501, 0, 0, 0, 0, 0, 'Fallarbor House #04', 43, 94, 7100, 7100, 3, 2, 142, 0, 0),
(501, 1, 0, 0, 0, 0, 'Fallarbor House #04', 43, 94, 7100, 7100, 3, 2, 142, 0, 0),
(502, 0, 0, 0, 0, 0, 'Fallarbor House #05', 43, 23, 1800, 1800, 1, 2, 36, 0, 0),
(502, 1, 0, 0, 0, 0, 'Fallarbor House #05', 43, 23, 1800, 1800, 1, 2, 36, 0, 0),
(503, 0, 0, 0, 0, 0, 'Fallarbor House #06', 43, 23, 1800, 1800, 1, 2, 36, 0, 0),
(503, 1, 0, 0, 0, 0, 'Fallarbor House #06', 43, 23, 1800, 1800, 1, 2, 36, 0, 0),
(504, 0, 0, 0, 0, 0, 'Fallarbor House #07', 43, 140, 9950, 9950, 4, 2, 199, 0, 0),
(504, 1, 0, 0, 0, 0, 'Fallarbor House #07', 43, 140, 9950, 9950, 4, 2, 199, 0, 0),
(505, 0, 0, 0, 0, 0, 'Fallarbor House #08', 43, 245, 17400, 17400, 5, 4, 348, 0, 0),
(505, 1, 0, 0, 0, 0, 'Fallarbor House #08', 43, 245, 17400, 17400, 5, 4, 348, 0, 0),
(506, 0, 0, 0, 0, 0, 'Fallarbor House #09', 43, 185, 13000, 13000, 5, 4, 260, 0, 0),
(506, 1, 0, 0, 0, 0, 'Fallarbor House #09', 43, 185, 13000, 13000, 5, 4, 260, 0, 0),
(507, 0, 0, 0, 0, 0, 'Fallarbor Farm #05', 43, 24, 1250, 1250, 1, 0, 25, 0, 0),
(507, 1, 0, 0, 0, 0, 'Fallarbor Farm #05', 43, 24, 1250, 1250, 1, 0, 25, 0, 0),
(508, 0, 0, 0, 0, 0, 'Fortree House #01', 45, 100, 8200, 8200, 4, 6, 164, 0, 0),
(508, 1, 0, 0, 0, 0, 'Fortree House #01', 45, 100, 8200, 8200, 4, 6, 164, 0, 0),
(509, 0, 0, 0, 0, 0, 'Fortree House #02', 45, 64, 5100, 5100, 4, 4, 102, 0, 0),
(509, 1, 0, 0, 0, 0, 'Fortree House #02', 45, 64, 5100, 5100, 4, 4, 102, 0, 0),
(510, 0, 0, 0, 0, 0, 'Fortree House #03', 45, 103, 8550, 8550, 4, 6, 171, 0, 0),
(510, 1, 0, 0, 0, 0, 'Fortree House #03', 45, 103, 8550, 8550, 4, 6, 171, 0, 0),
(511, 0, 0, 0, 0, 0, 'Fortree House #04', 45, 122, 9700, 9700, 3, 4, 194, 0, 0),
(511, 1, 0, 0, 0, 0, 'Fortree House #04', 45, 122, 9700, 9700, 3, 4, 194, 0, 0),
(512, 0, 0, 0, 0, 0, 'Fortree House #05', 45, 146, 11050, 11050, 4, 6, 221, 0, 0),
(512, 1, 0, 0, 0, 0, 'Fortree House #05', 45, 146, 11050, 11050, 4, 6, 221, 0, 0),
(513, 0, 0, 0, 0, 0, 'Fortree House #06', 45, 68, 5600, 5600, 4, 4, 112, 0, 0),
(513, 1, 0, 0, 0, 0, 'Fortree House #06', 45, 68, 5600, 5600, 4, 4, 112, 0, 0),
(514, 0, 0, 0, 0, 0, 'Fortree House #07', 45, 83, 6100, 6100, 2, 2, 122, 0, 0),
(514, 1, 0, 0, 0, 0, 'Fortree House #07', 45, 83, 6100, 6100, 2, 2, 122, 0, 0),
(515, 0, 0, 0, 0, 0, 'Fortree House #08', 45, 107, 8050, 8050, 2, 2, 161, 0, 0),
(515, 1, 0, 0, 0, 0, 'Fortree House #08', 45, 107, 8050, 8050, 2, 2, 161, 0, 0),
(516, 0, 0, 0, 0, 0, 'Fortree House #09', 45, 54, 4500, 4500, 3, 4, 90, 0, 0),
(516, 1, 0, 0, 0, 0, 'Fortree House #09', 45, 54, 4500, 4500, 3, 4, 90, 0, 0),
(517, 0, 0, 0, 0, 0, 'Fortree House #10', 45, 90, 7450, 7450, 3, 4, 149, 0, 0),
(517, 1, 0, 0, 0, 0, 'Fortree House #10', 45, 90, 7450, 7450, 3, 4, 149, 0, 0),
(518, 0, 0, 0, 0, 0, 'Fortree House #11', 45, 64, 5000, 5000, 3, 2, 100, 0, 0),
(518, 1, 0, 0, 0, 0, 'Fortree House #11', 45, 64, 5000, 5000, 3, 2, 100, 0, 0),
(519, 0, 0, 0, 0, 0, 'Lilycove House #01', 46, 98, 7500, 7500, 3, 2, 150, 0, 0),
(519, 1, 0, 0, 0, 0, 'Lilycove House #01', 46, 98, 7500, 7500, 3, 2, 150, 0, 0),
(520, 0, 0, 0, 0, 0, 'Lilycove House #02', 46, 159, 12050, 12050, 4, 2, 241, 0, 0),
(520, 1, 0, 0, 0, 0, 'Lilycove House #02', 46, 159, 12050, 12050, 4, 2, 241, 0, 0),
(521, 0, 0, 0, 0, 0, 'Lilycove House #03', 46, 78, 6650, 6650, 2, 2, 133, 0, 0),
(521, 1, 0, 0, 0, 0, 'Lilycove House #03', 46, 78, 6650, 6650, 2, 2, 133, 0, 0),
(522, 0, 0, 0, 0, 0, 'Lilycove House #04', 46, 39, 3200, 3200, 1, 0, 64, 0, 0),
(522, 1, 0, 0, 0, 0, 'Lilycove House #04', 46, 39, 3200, 3200, 1, 0, 64, 0, 0),
(523, 0, 0, 0, 0, 0, 'Lilycove House #05', 46, 78, 6350, 6350, 2, 2, 127, 0, 0),
(523, 1, 0, 0, 0, 0, 'Lilycove House #05', 46, 78, 6350, 6350, 2, 2, 127, 0, 0),
(524, 0, 0, 0, 0, 0, 'Lilycove House #06', 46, 76, 5500, 5500, 3, 2, 110, 0, 0),
(524, 1, 0, 0, 0, 0, 'Lilycove House #06', 46, 76, 5500, 5500, 3, 2, 110, 0, 0),
(525, 0, 0, 0, 0, 0, 'Lilycove House #07', 46, 37, 3150, 3150, 2, 2, 63, 0, 0),
(525, 1, 0, 0, 0, 0, 'Lilycove House #07', 46, 37, 3150, 3150, 2, 2, 63, 0, 0),
(526, 0, 0, 0, 0, 0, 'Lilycove House #09', 46, 82, 7250, 7250, 4, 4, 145, 0, 0),
(526, 1, 0, 0, 0, 0, 'Lilycove House #09', 46, 82, 7250, 7250, 4, 4, 145, 0, 0),
(527, 0, 0, 0, 0, 0, 'Lilycove House #10', 46, 58, 5450, 5450, 3, 2, 109, 0, 0),
(527, 1, 0, 0, 0, 0, 'Lilycove House #10', 46, 58, 5450, 5450, 3, 2, 109, 0, 0),
(528, 0, 0, 0, 0, 0, 'Lilycove House #11', 46, 172, 13200, 13200, 5, 6, 264, 0, 0),
(528, 1, 0, 0, 0, 0, 'Lilycove House #11', 46, 172, 13200, 13200, 5, 6, 264, 0, 0),
(529, 0, 0, 0, 0, 0, 'Lilycove House #12', 46, 133, 10000, 10000, 3, 2, 200, 0, 0),
(529, 1, 0, 0, 0, 0, 'Lilycove House #12', 46, 133, 10000, 10000, 3, 2, 200, 0, 0),
(530, 0, 0, 0, 0, 0, 'Lilycove House #13', 46, 153, 12100, 12100, 5, 8, 242, 0, 0),
(530, 1, 0, 0, 0, 0, 'Lilycove House #13', 46, 153, 12100, 12100, 5, 8, 242, 0, 0),
(531, 0, 0, 0, 0, 0, 'Lilycove House #08', 46, 22, 2150, 2150, 1, 0, 43, 0, 0),
(531, 1, 0, 0, 0, 0, 'Lilycove House #08', 46, 22, 2150, 2150, 1, 0, 43, 0, 0),
(532, 0, 0, 0, 0, 0, 'Lilycove Apartment #01', 46, 4, 750, 750, 1, 2, 15, 0, 0),
(532, 1, 0, 0, 0, 0, 'Lilycove Apartment #01', 46, 4, 750, 750, 1, 2, 15, 0, 0),
(533, 0, 0, 0, 0, 0, 'Lilycove Apartment #02', 46, 4, 650, 650, 1, 2, 13, 0, 0),
(533, 1, 0, 0, 0, 0, 'Lilycove Apartment #02', 46, 4, 650, 650, 1, 2, 13, 0, 0),
(534, 0, 0, 0, 0, 0, 'Lilycove Apartment #03', 46, 4, 600, 600, 1, 2, 12, 0, 0),
(534, 1, 0, 0, 0, 0, 'Lilycove Apartment #03', 46, 4, 600, 600, 1, 2, 12, 0, 0),
(535, 0, 0, 0, 0, 0, 'Lilycove Apartment #04', 46, 4, 600, 600, 1, 2, 12, 0, 0),
(535, 1, 0, 0, 0, 0, 'Lilycove Apartment #04', 46, 4, 600, 600, 1, 2, 12, 0, 0),
(536, 0, 0, 0, 0, 0, 'Lilycove Apartment #05', 46, 16, 1650, 1650, 2, 2, 33, 0, 0),
(536, 1, 0, 0, 0, 0, 'Lilycove Apartment #05', 46, 16, 1650, 1650, 2, 2, 33, 0, 0),
(537, 0, 0, 0, 0, 0, 'Lilycove Apartment #06', 46, 18, 1550, 1550, 1, 2, 31, 0, 0),
(537, 1, 0, 0, 0, 0, 'Lilycove Apartment #06', 46, 18, 1550, 1550, 1, 2, 31, 0, 0),
(539, 0, 0, 0, 0, 0, 'Lilycove Apartment #07', 46, 10, 1400, 1400, 1, 2, 28, 0, 0),
(539, 1, 0, 0, 0, 0, 'Lilycove Apartment #07', 46, 10, 1400, 1400, 1, 2, 28, 0, 0),
(540, 0, 0, 0, 0, 0, 'Lilycove Apartment #08', 46, 18, 1500, 1500, 1, 2, 30, 0, 0),
(540, 1, 0, 0, 0, 0, 'Lilycove Apartment #08', 46, 18, 1500, 1500, 1, 2, 30, 0, 0),
(541, 0, 0, 0, 0, 0, 'Lilycove Apartment #09', 46, 37, 3250, 3250, 2, 2, 65, 0, 0),
(541, 1, 0, 0, 0, 0, 'Lilycove Apartment #09', 46, 37, 3250, 3250, 2, 2, 65, 0, 0),
(542, 0, 0, 0, 0, 0, 'Lilycove House #14', 46, 63, 5000, 5000, 2, 2, 100, 0, 0),
(542, 1, 0, 0, 0, 0, 'Lilycove House #14', 46, 63, 5000, 5000, 2, 2, 100, 0, 0),
(543, 0, 0, 0, 0, 0, 'Lilycove House #15', 46, 64, 5000, 5000, 2, 2, 100, 0, 0),
(543, 1, 0, 0, 0, 0, 'Lilycove House #15', 46, 64, 5000, 5000, 2, 2, 100, 0, 0),
(544, 0, 0, 0, 0, 0, 'Lilycove House #16', 46, 170, 13050, 13050, 4, 4, 261, 0, 0),
(544, 1, 0, 0, 0, 0, 'Lilycove House #16', 46, 170, 13050, 13050, 4, 4, 261, 0, 0),
(545, 0, 0, 0, 0, 0, 'Lilycove House #17', 46, 94, 7250, 7250, 3, 4, 145, 0, 0),
(545, 1, 0, 0, 0, 0, 'Lilycove House #17', 46, 94, 7250, 7250, 3, 4, 145, 0, 0),
(546, 0, 0, 0, 0, 0, 'Lilycove House #18', 46, 194, 14400, 14400, 4, 2, 288, 0, 0),
(546, 1, 0, 0, 0, 0, 'Lilycove House #18', 46, 194, 14400, 14400, 4, 2, 288, 0, 0),
(547, 0, 0, 0, 0, 0, 'Lilycove House #19', 46, 132, 10050, 10050, 3, 2, 201, 0, 0),
(547, 1, 0, 0, 0, 0, 'Lilycove House #19', 46, 132, 10050, 10050, 3, 2, 201, 0, 0),
(548, 0, 0, 0, 0, 0, 'Lilycove House #20', 46, 147, 12000, 12000, 6, 6, 240, 0, 0),
(548, 1, 0, 0, 0, 0, 'Lilycove House #20', 46, 147, 12000, 12000, 6, 6, 240, 0, 0),
(549, 0, 0, 0, 0, 0, 'Mossdeep House #01', 47, 58, 4550, 4550, 2, 2, 91, 0, 0),
(549, 1, 0, 0, 0, 0, 'Mossdeep House #01', 47, 58, 4550, 4550, 2, 2, 91, 0, 0),
(550, 0, 0, 0, 0, 0, 'Mossdeep House #02', 47, 127, 11050, 11050, 7, 6, 221, 0, 0),
(550, 1, 0, 0, 0, 0, 'Mossdeep House #02', 47, 127, 11050, 11050, 7, 6, 221, 0, 0),
(551, 0, 0, 0, 0, 0, 'Mossdeep House #03', 47, 77, 5500, 5500, 2, 2, 110, 0, 0),
(551, 1, 0, 0, 0, 0, 'Mossdeep House #03', 47, 77, 5500, 5500, 2, 2, 110, 0, 0),
(552, 0, 0, 0, 0, 0, 'Mossdeep House #04', 47, 56, 4500, 4500, 2, 2, 90, 0, 0),
(552, 1, 0, 0, 0, 0, 'Mossdeep House #04', 47, 56, 4500, 4500, 2, 2, 90, 0, 0),
(553, 0, 0, 0, 0, 0, 'Mossdeep House #05', 47, 66, 5000, 5000, 2, 2, 100, 0, 0),
(553, 1, 0, 0, 0, 0, 'Mossdeep House #05', 47, 66, 5000, 5000, 2, 2, 100, 0, 0),
(554, 0, 0, 0, 0, 0, 'Mossdeep House #06', 47, 117, 11300, 11300, 11, 10, 226, 0, 0),
(554, 1, 0, 0, 0, 0, 'Mossdeep House #06', 47, 117, 11300, 11300, 11, 10, 226, 0, 0),
(555, 0, 0, 0, 0, 0, 'Mossdeep House #07', 47, 114, 9950, 9950, 6, 6, 199, 0, 0),
(555, 1, 0, 0, 0, 0, 'Mossdeep House #07', 47, 114, 9950, 9950, 6, 6, 199, 0, 0),
(556, 0, 0, 0, 0, 0, 'Mossdeep House #08', 47, 84, 7200, 7200, 4, 6, 144, 0, 0),
(556, 1, 0, 0, 0, 0, 'Mossdeep House #08', 47, 84, 7200, 7200, 4, 6, 144, 0, 0),
(557, 0, 0, 0, 0, 0, 'Mossdeep House #09', 47, 91, 7200, 7200, 3, 2, 144, 0, 0),
(557, 1, 0, 0, 0, 0, 'Mossdeep House #09', 47, 91, 7200, 7200, 3, 2, 144, 0, 0),
(558, 0, 0, 0, 0, 0, 'Mossdeep House #10', 47, 37, 3200, 3200, 2, 2, 64, 0, 0),
(558, 1, 0, 0, 0, 0, 'Mossdeep House #10', 47, 37, 3200, 3200, 2, 2, 64, 0, 0),
(559, 0, 0, 0, 0, 0, 'Mossdeep House #11', 47, 138, 11050, 11050, 5, 6, 221, 0, 0),
(559, 1, 0, 0, 0, 0, 'Mossdeep House #11', 47, 138, 11050, 11050, 5, 6, 221, 0, 0),
(560, 0, 0, 0, 0, 0, 'Sootopolis House #01', 48, 125, 12150, 12150, 9, 10, 243, 0, 0),
(560, 1, 0, 0, 0, 0, 'Sootopolis House #01', 48, 125, 12150, 12150, 9, 10, 243, 0, 0),
(561, 0, 0, 0, 0, 0, 'Sootopolis House #02', 48, 93, 8100, 8100, 6, 4, 162, 0, 0),
(561, 1, 0, 0, 0, 0, 'Sootopolis House #02', 48, 93, 8100, 8100, 6, 4, 162, 0, 0),
(562, 0, 0, 0, 0, 0, 'Sootopolis House #03', 48, 90, 7200, 7200, 3, 4, 144, 0, 0),
(562, 1, 0, 0, 0, 0, 'Sootopolis House #03', 48, 90, 7200, 7200, 3, 4, 144, 0, 0),
(563, 0, 0, 0, 0, 0, 'Sootopolis House #04', 48, 100, 8150, 8150, 4, 4, 163, 0, 0),
(563, 1, 0, 0, 0, 0, 'Sootopolis House #04', 48, 100, 8150, 8150, 4, 4, 163, 0, 0),
(564, 0, 0, 0, 0, 0, 'Sootopolis House #05', 48, 87, 7000, 7000, 4, 2, 140, 0, 0),
(564, 1, 0, 0, 0, 0, 'Sootopolis House #05', 48, 87, 7000, 7000, 4, 2, 140, 0, 0),
(565, 0, 0, 0, 0, 0, 'Sootopolis House #06', 48, 132, 10450, 10450, 5, 6, 209, 0, 0),
(565, 1, 0, 0, 0, 0, 'Sootopolis House #06', 48, 132, 10450, 10450, 5, 6, 209, 0, 0),
(566, 0, 0, 0, 0, 0, 'Sootopolis House #07', 48, 73, 6350, 6350, 3, 2, 127, 0, 0),
(566, 1, 0, 0, 0, 0, 'Sootopolis House #07', 48, 73, 6350, 6350, 3, 2, 127, 0, 0),
(567, 0, 0, 0, 0, 0, 'Sootopolis House #08', 48, 102, 8150, 8150, 4, 4, 163, 0, 0),
(567, 1, 0, 0, 0, 0, 'Sootopolis House #08', 48, 102, 8150, 8150, 4, 4, 163, 0, 0),
(568, 0, 0, 0, 0, 0, 'Sootopolis House #09', 48, 65, 6450, 6450, 5, 4, 129, 0, 0),
(568, 1, 0, 0, 0, 0, 'Sootopolis House #09', 48, 65, 6450, 6450, 5, 4, 129, 0, 0),
(569, 0, 0, 0, 0, 0, 'Sootopolis House #10', 48, 88, 7250, 7250, 3, 2, 145, 0, 0),
(569, 1, 0, 0, 0, 0, 'Sootopolis House #10', 48, 88, 7250, 7250, 3, 2, 145, 0, 0),
(570, 0, 0, 0, 0, 0, 'Pacifidlog House #01', 49, 71, 6050, 6050, 3, 4, 121, 0, 0),
(570, 1, 0, 0, 0, 0, 'Pacifidlog House #01', 49, 71, 6050, 6050, 3, 4, 121, 0, 0),
(571, 0, 0, 0, 0, 0, 'Pacifidlog House #02', 49, 101, 7800, 7800, 4, 6, 156, 0, 0),
(571, 1, 0, 0, 0, 0, 'Pacifidlog House #02', 49, 101, 7800, 7800, 4, 6, 156, 0, 0),
(572, 0, 0, 0, 0, 0, 'Pacifidlog House #03', 49, 86, 6650, 6650, 2, 2, 133, 0, 0),
(572, 1, 0, 0, 0, 0, 'Pacifidlog House #03', 49, 86, 6650, 6650, 2, 2, 133, 0, 0),
(573, 0, 0, 0, 0, 0, 'Pacifidlog House #04', 49, 95, 7550, 7550, 3, 4, 151, 0, 0),
(573, 1, 0, 0, 0, 0, 'Pacifidlog House #04', 49, 95, 7550, 7550, 3, 4, 151, 0, 0),
(574, 0, 0, 0, 0, 0, 'Pacifidlog House #05', 49, 103, 7750, 7750, 3, 4, 155, 0, 0),
(574, 1, 0, 0, 0, 0, 'Pacifidlog House #05', 49, 103, 7750, 7750, 3, 4, 155, 0, 0),
(575, 0, 0, 0, 0, 0, 'Pacifidlog House #06', 49, 18, 1550, 1550, 1, 2, 31, 0, 0),
(575, 1, 0, 0, 0, 0, 'Pacifidlog House #06', 49, 18, 1550, 1550, 1, 2, 31, 0, 0),
(576, 0, 0, 0, 0, 0, 'Pacifidlog House #07', 49, 23, 1850, 1850, 1, 2, 37, 0, 0),
(576, 1, 0, 0, 0, 0, 'Pacifidlog House #07', 49, 23, 1850, 1850, 1, 2, 37, 0, 0),
(577, 0, 0, 0, 0, 0, 'Pacifidlog House #08', 49, 7, 800, 800, 1, 2, 16, 0, 0),
(577, 1, 0, 0, 0, 0, 'Pacifidlog House #08', 49, 7, 800, 800, 1, 2, 16, 0, 0),
(578, 0, 0, 0, 0, 0, 'Pacifidlog House #09', 49, 7, 800, 800, 1, 2, 16, 0, 0),
(578, 1, 0, 0, 0, 0, 'Pacifidlog House #09', 49, 7, 800, 800, 1, 2, 16, 0, 0),
(579, 0, 0, 0, 0, 0, 'Pacifidlog House #10', 49, 57, 4450, 4450, 2, 2, 89, 0, 0),
(579, 1, 0, 0, 0, 0, 'Pacifidlog House #10', 49, 57, 4450, 4450, 2, 2, 89, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `house_auctions`
--

CREATE TABLE `house_auctions` (
  `house_id` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL,
  `bid` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `limit` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `endtime` bigint(20) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `house_data`
--

CREATE TABLE `house_data` (
  `house_id` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `data` longblob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `house_lists`
--

CREATE TABLE `house_lists` (
  `house_id` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `listid` int(11) NOT NULL,
  `list` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `instant_payment_notifications`
--

CREATE TABLE `instant_payment_notifications` (
  `id` char(36) NOT NULL,
  `notify_version` varchar(64) DEFAULT NULL,
  `verify_sign` varchar(127) DEFAULT NULL,
  `test_ipn` int(11) DEFAULT NULL,
  `address_city` varchar(40) DEFAULT NULL,
  `address_country` varchar(64) DEFAULT NULL,
  `address_country_code` varchar(2) DEFAULT NULL,
  `address_name` varchar(128) DEFAULT NULL,
  `address_state` varchar(40) DEFAULT NULL,
  `address_status` varchar(20) DEFAULT NULL,
  `address_street` varchar(200) DEFAULT NULL,
  `address_zip` varchar(20) DEFAULT NULL,
  `first_name` varchar(64) DEFAULT NULL,
  `last_name` varchar(64) DEFAULT NULL,
  `payer_business_name` varchar(127) DEFAULT NULL,
  `payer_email` varchar(127) DEFAULT NULL,
  `payer_id` varchar(13) DEFAULT NULL,
  `payer_status` varchar(20) DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `residence_country` varchar(2) DEFAULT NULL,
  `business` varchar(127) DEFAULT NULL,
  `item_name` varchar(127) DEFAULT NULL,
  `item_number` varchar(127) DEFAULT NULL,
  `quantity` varchar(127) DEFAULT NULL,
  `receiver_email` varchar(127) DEFAULT NULL,
  `receiver_id` varchar(13) DEFAULT NULL,
  `custom` varchar(255) DEFAULT NULL,
  `invoice` varchar(127) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `option_name1` varchar(64) DEFAULT NULL,
  `option_name2` varchar(64) DEFAULT NULL,
  `option_selection1` varchar(200) DEFAULT NULL,
  `option_selection2` varchar(200) DEFAULT NULL,
  `tax` decimal(10,2) DEFAULT NULL,
  `auth_id` varchar(19) DEFAULT NULL,
  `auth_exp` varchar(28) DEFAULT NULL,
  `auth_amount` int(11) DEFAULT NULL,
  `auth_status` varchar(20) DEFAULT NULL,
  `num_cart_items` int(11) DEFAULT NULL,
  `parent_txn_id` varchar(19) DEFAULT NULL,
  `payment_date` varchar(28) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT NULL,
  `payment_type` varchar(10) DEFAULT NULL,
  `pending_reason` varchar(20) DEFAULT NULL,
  `reason_code` varchar(20) DEFAULT NULL,
  `remaining_settle` int(11) DEFAULT NULL,
  `shipping_method` varchar(64) DEFAULT NULL,
  `shipping` decimal(10,2) DEFAULT NULL,
  `transaction_entity` varchar(20) DEFAULT NULL,
  `txn_id` varchar(19) DEFAULT NULL,
  `txn_type` varchar(20) DEFAULT NULL,
  `exchange_rate` decimal(10,2) DEFAULT NULL,
  `mc_currency` varchar(3) DEFAULT NULL,
  `mc_fee` decimal(10,2) DEFAULT NULL,
  `mc_gross` decimal(10,2) DEFAULT NULL,
  `mc_handling` decimal(10,2) DEFAULT NULL,
  `mc_shipping` decimal(10,2) DEFAULT NULL,
  `payment_fee` decimal(10,2) DEFAULT NULL,
  `payment_gross` decimal(10,2) DEFAULT NULL,
  `settle_amount` decimal(10,2) DEFAULT NULL,
  `settle_currency` varchar(3) DEFAULT NULL,
  `auction_buyer_id` varchar(64) DEFAULT NULL,
  `auction_closing_date` varchar(28) DEFAULT NULL,
  `auction_multi_item` int(11) DEFAULT NULL,
  `for_auction` varchar(10) DEFAULT NULL,
  `subscr_date` varchar(28) DEFAULT NULL,
  `subscr_effective` varchar(28) DEFAULT NULL,
  `period1` varchar(10) DEFAULT NULL,
  `period2` varchar(10) DEFAULT NULL,
  `period3` varchar(10) DEFAULT NULL,
  `amount1` decimal(10,2) DEFAULT NULL,
  `amount2` decimal(10,2) DEFAULT NULL,
  `amount3` decimal(10,2) DEFAULT NULL,
  `mc_amount1` decimal(10,2) DEFAULT NULL,
  `mc_amount2` decimal(10,2) DEFAULT NULL,
  `mc_amount3` decimal(10,2) DEFAULT NULL,
  `recurring` varchar(1) DEFAULT NULL,
  `reattempt` varchar(1) DEFAULT NULL,
  `retry_at` varchar(28) DEFAULT NULL,
  `recur_times` int(11) DEFAULT NULL,
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(24) DEFAULT NULL,
  `subscr_id` varchar(19) DEFAULT NULL,
  `case_id` varchar(28) DEFAULT NULL,
  `case_type` varchar(28) DEFAULT NULL,
  `case_creation_date` varchar(28) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `killers`
--

CREATE TABLE `killers` (
  `id` int(11) NOT NULL,
  `death_id` int(11) NOT NULL,
  `final_hit` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `unjustified` tinyint(1) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `loyalty_ranks`
--

CREATE TABLE `loyalty_ranks` (
  `id` int(10) UNSIGNED NOT NULL,
  `required_points` int(10) UNSIGNED NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `market_history`
--

CREATE TABLE `market_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(1) NOT NULL DEFAULT 0,
  `itemtype` int(10) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL,
  `price` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `expires_at` bigint(20) UNSIGNED NOT NULL,
  `inserted` bigint(20) UNSIGNED NOT NULL,
  `state` tinyint(1) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `market_offers`
--

CREATE TABLE `market_offers` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL,
  `sale` tinyint(1) NOT NULL DEFAULT 0,
  `itemtype` int(10) UNSIGNED NOT NULL,
  `amount` smallint(5) UNSIGNED NOT NULL,
  `created` bigint(20) UNSIGNED NOT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT 0,
  `price` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `parcels`
--

CREATE TABLE `parcels` (
  `id` int(10) NOT NULL,
  `from_player_id` int(10) UNSIGNED DEFAULT 0,
  `to_player_id` int(10) UNSIGNED DEFAULT 0,
  `date` bigint(20) UNSIGNED DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `password_requests`
--

CREATE TABLE `password_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) NOT NULL,
  `token` varchar(30) NOT NULL,
  `expires` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Estrutura da tabela `paypal_items`
--

CREATE TABLE `paypal_items` (
  `id` varchar(36) NOT NULL,
  `instant_payment_notification_id` varchar(36) NOT NULL,
  `item_name` varchar(127) DEFAULT NULL,
  `item_number` varchar(127) DEFAULT NULL,
  `quantity` varchar(127) DEFAULT NULL,
  `mc_gross` float(10,2) DEFAULT NULL,
  `mc_shipping` float(10,2) DEFAULT NULL,
  `mc_handling` float(10,2) DEFAULT NULL,
  `tax` float(10,2) DEFAULT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `group_id` int(11) NOT NULL DEFAULT 1,
  `account_id` int(11) NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 1,
  `vocation` int(11) NOT NULL DEFAULT 0,
  `health` int(11) NOT NULL DEFAULT 150,
  `healthmax` int(11) NOT NULL DEFAULT 150,
  `experience` bigint(20) NOT NULL DEFAULT 0,
  `lookbody` int(11) NOT NULL DEFAULT 0,
  `lookfeet` int(11) NOT NULL DEFAULT 0,
  `lookhead` int(11) NOT NULL DEFAULT 0,
  `looklegs` int(11) NOT NULL DEFAULT 0,
  `looktype` int(11) NOT NULL DEFAULT 136,
  `lookaddons` int(11) NOT NULL DEFAULT 0,
  `maglevel` int(11) NOT NULL DEFAULT 0,
  `mana` int(11) NOT NULL DEFAULT 0,
  `manamax` int(11) NOT NULL DEFAULT 0,
  `manaspent` int(11) NOT NULL DEFAULT 0,
  `soul` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `town_id` int(11) NOT NULL DEFAULT 0,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  `conditions` blob DEFAULT NULL,
  `cap` int(11) NOT NULL DEFAULT 0,
  `sex` int(11) NOT NULL DEFAULT 0,
  `lastlogin` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `lastip` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `save` tinyint(1) NOT NULL DEFAULT 1,
  `skull` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  `skulltime` int(11) NOT NULL DEFAULT 0,
  `rank_id` int(11) NOT NULL DEFAULT 0,
  `guildnick` varchar(255) NOT NULL DEFAULT '',
  `lastlogout` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `blessings` tinyint(2) NOT NULL DEFAULT 0,
  `balance` bigint(20) NOT NULL DEFAULT 0,
  `stamina` int(11) NOT NULL DEFAULT 151200000,
  `direction` int(11) NOT NULL DEFAULT 2,
  `loss_experience` int(11) NOT NULL DEFAULT 100,
  `loss_mana` int(11) NOT NULL DEFAULT 100,
  `loss_skills` int(11) NOT NULL DEFAULT 100,
  `loss_containers` int(11) NOT NULL DEFAULT 100,
  `loss_items` int(11) NOT NULL DEFAULT 100,
  `premend` int(11) NOT NULL DEFAULT 0 COMMENT 'NOT IN USE BY THE SERVER',
  `online` tinyint(1) NOT NULL DEFAULT 0,
  `marriage` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `promotion` int(11) NOT NULL DEFAULT 0,
  `deleted` tinyint(1) NOT NULL DEFAULT 0,
  `description` varchar(255) NOT NULL DEFAULT '',
  `comment` varchar(1000) DEFAULT 'None',
  `lasteggtime` bigint(20) UNSIGNED DEFAULT 0,
  `pvparenafrags` int(10) UNSIGNED DEFAULT 0,
  `pvparenadeaths` int(10) UNSIGNED DEFAULT 0,
  `firstpokemon` tinyint(10) DEFAULT -1,
  `tournament_score` int(10) UNSIGNED DEFAULT 0,
  `hidden` tinyint(1) NOT NULL DEFAULT 0,
  `tournament_weekly_score` int(10) UNSIGNED DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `players`
--

INSERT INTO `players` (`id`, `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `rank_id`, `guildnick`, `lastlogout`, `blessings`, `balance`, `stamina`, `direction`, `loss_experience`, `loss_mana`, `loss_skills`, `loss_containers`, `loss_items`, `premend`, `online`, `marriage`, `promotion`, `deleted`, `description`, `comment`, `lasteggtime`, `pvparenafrags`, `pvparenadeaths`, `firstpokemon`, `tournament_score`, `hidden`, `tournament_weekly_score`) VALUES
(91190, 'GOD', 0, 6, 70846, 8, 1, 185, 185, 4400, 68, 76, 78, 58, 302, 0, 18, 0, 280, 0, 100, 1, 3310, 567, 7, '', 470, 1, 1596270540, 16777343, 1, 0, 0, 0, '', 1596270859, 0, 0, 151200000, 0, 50, 10, 10, 100, 100, 0, 0, 0, 0, 0, '', 'None', 0, 0, 0, -1, 0, 0, 0),
(91191, 'Viciado', 0, 1, 70846, 8, 1, 185, 185, 4200, 68, 76, 78, 58, 128, 0, 0, 90, 90, 0, 100, 1, 5, 5, 2, '', 470, 1, 0, 0, 1, 0, 0, 0, '', 0, 0, 0, 151200000, 0, 10, 10, 10, 100, 100, 0, 0, 0, 0, 0, '', 'None', 0, 0, 0, -1, 0, 0, 0),
(91192, 'Canibal', 0, 1, 70848, 8, 1, 185, 185, 4200, 68, 76, 78, 58, 612, 0, 0, 0, 0, 0, 100, 1, 3295, 563, 7, '', 470, 1, 1596271524, 16777343, 1, 0, 0, 0, '', 1596271530, 0, 0, 151200000, 0, 50, 10, 10, 100, 100, 0, 0, 0, 0, 0, '', 'None', 0, 0, 0, -1, 0, 0, 0),
(91193, 'Teste', 0, 1, 70848, 8, 1, 185, 185, 4200, 68, 76, 78, 58, 612, 0, 0, 0, 0, 0, 100, 1, 3295, 570, 7, '', 470, 1, 1596271532, 16777343, 1, 0, 0, 0, '', 1596271544, 0, 0, 151200000, 0, 50, 10, 10, 100, 100, 0, 0, 0, 0, 0, '', 'None', 0, 0, 0, -1, 0, 0, 0);

--
-- Acionadores `players`
--
DELIMITER $$
CREATE TRIGGER `oncreate_players` AFTER INSERT ON `players` FOR EACH ROW BEGIN
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 0, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 1, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 2, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 3, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 4, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 5, 0);
	INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 6, 0);

	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 1, 101, 13206, 1);
	-- INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 2, 102, 13205, 1);
	-- INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 3, 103, 13207, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 4, 104, 13453, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 5, 105, 12280, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 6, 106, 12281, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 7, 107, 12853, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 10, 108, 13499, 1);
	
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 109, 13805, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 110, 13805, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 111, 13805, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 112, 13805, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 113, 13805, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 104, 114, 13805, 1);
	
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 115, 12214, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 116, 12216, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 117, 12218, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 118, 12220, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 119, 12222, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 120, 12224, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 121, 12226, 1);
	INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`) VALUES (NEW.`id`, 105, 122, 12228, 1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ondelete_players` BEFORE DELETE ON `players` FOR EACH ROW BEGIN
	DELETE FROM `bans` WHERE `type` = 2 AND `value` = OLD.`id`;
	UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;
	DELETE FROM `ball_counter` WHERE `ball_counter`.`player_id` = OLD.`id`;
	DELETE FROM `datalog_caughts` WHERE `datalog_caughts`.`player_id` = OLD.`id`;
	DELETE FROM `datalog_coin_uses` WHERE `datalog_coin_uses`.`player_id` = OLD.`id`;
	DELETE FROM `datalog_egg_generate` WHERE `datalog_egg_generate`.`player_id` = OLD.`id`;
	DELETE FROM `datalog_poke_nick_change` WHERE `datalog_poke_nick_change`.`player_id` = OLD.`id`;
	DELETE FROM `daycare_female` WHERE `daycare_female`.`player_id` = OLD.`id`;
	DELETE FROM `daycare_male` WHERE `daycare_male`.`player_id` = OLD.`id`;
	DELETE FROM `parcels` WHERE `parcels`.`from_player_id` = OLD.`id`;
	DELETE FROM `player_achievements` WHERE `player_achievements`.`player_id` = OLD.`id`;
	DELETE FROM `player_depotitems` WHERE `player_depotitems`.`player_id` = OLD.`id`;
	DELETE FROM `player_highscores` WHERE `player_highscores`.`player_id` = OLD.`id`;
	DELETE FROM `player_namelocks` WHERE `player_namelocks`.`player_id` = OLD.`id`;
	DELETE FROM `player_skills` WHERE `player_skills`.`player_id` = OLD.`id`;
	DELETE FROM `player_statistics` WHERE `player_statistics`.`player_id` = OLD.`id`;
	DELETE FROM `player_storage` WHERE `player_storage`.`player_id` = OLD.`id`;
	DELETE FROM `tournament_bans` WHERE `tournament_bans`.`player_id` = OLD.`id`;
	DELETE FROM `player_items` WHERE `player_items`.`player_id` = OLD.`id`;
	DELETE FROM `player_depotitems` WHERE `player_depotitems`.`player_id` = OLD.`id`;
	DELETE FROM `player_storage` WHERE `player_storage`.`player_id` = OLD.`id`;
	DELETE FROM `player_skills` WHERE `player_skills`.`player_id` = OLD.`id`;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_achievements`
--

CREATE TABLE `player_achievements` (
  `player_id` int(11) NOT NULL,
  `key` mediumint(8) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `player_achievements`
--

INSERT INTO `player_achievements` (`player_id`, `key`) VALUES
(91190, 13),
(91190, 94),
(91192, 94);

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_deaths`
--

CREATE TABLE `player_deaths` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL,
  `level` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_depotitems`
--

CREATE TABLE `player_depotitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range, eg. 0-100 is reserved for depot lockers and all above 100 will be normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_highscores`
--

CREATE TABLE `player_highscores` (
  `player_id` int(11) NOT NULL,
  `score_id` mediumint(8) UNSIGNED NOT NULL,
  `value` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `player_highscores`
--

INSERT INTO `player_highscores` (`player_id`, `score_id`, `value`) VALUES
(91190, 9, 40),
(91192, 9, 30);

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_items`
--

CREATE TABLE `player_items` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `pid` int(11) NOT NULL DEFAULT 0,
  `sid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL DEFAULT 0,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_items`
--

INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES
(91190, 1, 101, 7730, 1, ''),
(91190, 4, 102, 13453, 1, ''),
(91190, 5, 103, 12280, 1, ''),
(91190, 6, 104, 12281, 1, ''),
(91190, 7, 105, 12707, 1, ''),
(91190, 8, 106, 12159, 1, 0x801300040031303030020900000005003130303032010900000043686172697a6172640500313030303302e00b00000500313030303502120000000500313030303602441001000500313030303702000000000500313030303802180100000500313030303902ffffffff0500313030313002ffffffff0500313030313102ffffffff0500313030313202ffffffff0500313030313302ffffffff0500313030313402ffffffff0500313030313602000000000500313030313702640000000500313030313802110000000500313030323102ffffffff0500313030323302020000000b006465736372697074696f6e0145000000436f6e7461696e7320612066656d616c652043686172697a61726420284c6576656c20313829205b2b31375d2e0a5370656369616c204162696c6974793a20426c617a652e),
(91190, 10, 107, 13499, 1, ''),
(91190, 103, 108, 12214, 1, ''),
(91190, 103, 109, 12216, 1, ''),
(91190, 103, 110, 12218, 1, ''),
(91190, 103, 111, 12220, 1, ''),
(91190, 103, 112, 12222, 1, ''),
(91190, 103, 113, 12224, 1, ''),
(91190, 103, 114, 12226, 1, ''),
(91190, 103, 115, 12228, 1, ''),
(91190, 107, 116, 14463, 83, 0x0f53),
(91190, 107, 117, 12159, 1, 0x801a00040031303030020600000005003130303032010700000050696b616368750500313030303302a101000005003130303035020100000005003130303036020000000005003130303037020000000005003130303038026e0000000500313030303902ffffffff0500313030313002ffffffff0500313030313102ffffffff0500313030313202ffffffff0500313030313302ffffffff0500313030313402ffffffff0500313030313602000000000500313030313702640000000500313030313802000000000500313030323102ffffffff05003130303233020d0000000500313530353702726e1a010500313530363602726e1a010500313530383102726e1a010500313530383202726e1a010500313530383602726e1a010500313531323702726e1a010500313532343302726e1a010b006465736372697074696f6e0142000000436f6e7461696e7320612066656d616c652050696b6163687520284c6576656c203129205b2b305d2e0a5370656369616c204162696c6974793a205374617469632e),
(91190, 107, 118, 12159, 1, 0x801a00040031303030020800000005003130303032010a000000436861726d616e646572050031303030330200e1f50505003130303035020100000005003130303036020000000005003130303037029f86010005003130303038026e0000000500313030303902ffffffff0500313030313002ffffffff0500313030313102ffffffff0500313030313202ffffffff0500313030313302ffffffff0500313030313402ffffffff0500313030313602010000000500313030313702640000000500313030313802000000000500313030323102ffffffff0500313030323302020000000500313530323202726e1a010500313530323402726e1a010500313530363302726e1a010500313530363702726e1a010500313530383602726e1a010500313530393602726e1a010500313531343402726e1a010b006465736372697074696f6e0142000000436f6e7461696e732061206d616c6520436861726d616e64657220284c6576656c203129205b2b305d2e0a5370656369616c204162696c6974793a20426c617a652e),
(91190, 107, 119, 12159, 1, 0x801700040031303030020700000005003130303032010700000052617474617461050031303030330200e1f50505003130303035020100000005003130303036020000000005003130303037029f86010005003130303038026e0000000500313030303902ffffffff0500313030313002ffffffff0500313030313102ffffffff0500313030313202ffffffff0500313030313302ffffffff0500313030313402ffffffff0500313030313602010000000500313030313702640000000500313030313802000000000500313030323102ffffffff05003130303233020b0000000500313530303302726e1a010500313530333402726e1a010500313530353702726e1a010500313530383602726e1a010b006465736372697074696f6e013e000000436f6e7461696e732061206d616c65205261747461746120284c6576656c203129205b2b305d2e0a5370656369616c204162696c6974793a20477574732e),
(91191, 1, 101, 13206, 1, ''),
(91191, 4, 104, 13453, 1, ''),
(91191, 5, 105, 12280, 1, ''),
(91191, 6, 106, 12281, 1, ''),
(91191, 7, 107, 12853, 1, ''),
(91191, 10, 108, 13499, 1, ''),
(91191, 104, 109, 13805, 1, ''),
(91191, 104, 110, 13805, 1, ''),
(91191, 104, 111, 13805, 1, ''),
(91191, 104, 112, 13805, 1, ''),
(91191, 104, 113, 13805, 1, ''),
(91191, 104, 114, 13805, 1, ''),
(91191, 105, 115, 12214, 1, ''),
(91191, 105, 116, 12216, 1, ''),
(91191, 105, 117, 12218, 1, ''),
(91191, 105, 118, 12220, 1, ''),
(91191, 105, 119, 12222, 1, ''),
(91191, 105, 120, 12224, 1, ''),
(91191, 105, 121, 12226, 1, ''),
(91191, 105, 122, 12228, 1, ''),
(91192, 1, 101, 13206, 1, ''),
(91192, 4, 102, 13453, 1, ''),
(91192, 5, 103, 12280, 1, ''),
(91192, 6, 104, 12281, 1, ''),
(91192, 7, 105, 12853, 1, ''),
(91192, 10, 106, 13499, 1, ''),
(91192, 103, 107, 12214, 1, ''),
(91192, 103, 108, 12216, 1, ''),
(91192, 103, 109, 12218, 1, ''),
(91192, 103, 110, 12220, 1, ''),
(91192, 103, 111, 12222, 1, ''),
(91192, 103, 112, 12224, 1, ''),
(91192, 103, 113, 12226, 1, ''),
(91192, 103, 114, 12228, 1, ''),
(91193, 1, 101, 13206, 1, ''),
(91193, 4, 102, 13453, 1, ''),
(91193, 5, 103, 12280, 1, ''),
(91193, 6, 104, 12281, 1, ''),
(91193, 7, 105, 12853, 1, ''),
(91193, 10, 106, 13499, 1, ''),
(91193, 103, 107, 12214, 1, ''),
(91193, 103, 108, 12216, 1, ''),
(91193, 103, 109, 12218, 1, ''),
(91193, 103, 110, 12220, 1, ''),
(91193, 103, 111, 12222, 1, ''),
(91193, 103, 112, 12224, 1, ''),
(91193, 103, 113, 12226, 1, ''),
(91193, 103, 114, 12228, 1, '');

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_killers`
--

CREATE TABLE `player_killers` (
  `kill_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_namelocks`
--

CREATE TABLE `player_namelocks` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL,
  `new_name` varchar(255) NOT NULL,
  `date` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_pokemon`
--

CREATE TABLE `player_pokemon` (
  `player_id` int(11) NOT NULL,
  `slot` tinyint(3) UNSIGNED NOT NULL,
  `pokemon_number` smallint(5) UNSIGNED NOT NULL,
  `description` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_pokemon`
--

INSERT INTO `player_pokemon` (`player_id`, `slot`, `pokemon_number`, `description`) VALUES
(91190, 1, 6, 'Contains a female Charizard (Level 18) [+17].\nSpecial Ability: Blaze.'),
(91190, 2, 19, 'Contains a male Rattata (Level 1) [+0].\nSpecial Ability: Guts.'),
(91190, 3, 4, 'Contains a male Charmander (Level 1) [+0].\nSpecial Ability: Blaze.'),
(91190, 4, 25, 'Contains a female Pikachu (Level 1) [+0].\nSpecial Ability: Static.');

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_skills`
--

CREATE TABLE `player_skills` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `skillid` tinyint(2) NOT NULL DEFAULT 0,
  `value` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `count` int(10) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_skills`
--

INSERT INTO `player_skills` (`player_id`, `skillid`, `value`, `count`) VALUES
(91190, 0, 10, 0),
(91190, 1, 10, 0),
(91190, 2, 10, 0),
(91190, 3, 10, 0),
(91190, 4, 10, 0),
(91190, 5, 10, 0),
(91190, 6, 10, 0),
(91191, 0, 10, 0),
(91191, 1, 10, 0),
(91191, 2, 10, 0),
(91191, 3, 10, 0),
(91191, 4, 10, 0),
(91191, 5, 10, 0),
(91191, 6, 10, 0),
(91192, 0, 10, 0),
(91192, 1, 10, 0),
(91192, 2, 10, 0),
(91192, 3, 10, 0),
(91192, 4, 10, 0),
(91192, 5, 10, 0),
(91192, 6, 10, 0),
(91193, 0, 10, 0),
(91193, 1, 10, 0),
(91193, 2, 10, 0),
(91193, 3, 10, 0),
(91193, 4, 10, 0),
(91193, 5, 10, 0),
(91193, 6, 10, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_spells`
--

CREATE TABLE `player_spells` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_statistics`
--

CREATE TABLE `player_statistics` (
  `player_id` int(11) NOT NULL,
  `key` mediumint(8) UNSIGNED NOT NULL,
  `value` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

--
-- Extraindo dados da tabela `player_statistics`
--

INSERT INTO `player_statistics` (`player_id`, `key`, `value`) VALUES
(91190, 9, 2),
(91192, 9, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_storage`
--

CREATE TABLE `player_storage` (
  `player_id` int(11) NOT NULL DEFAULT 0,
  `key` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `value` varchar(255) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_storage`
--

INSERT INTO `player_storage` (`player_id`, `key`, `value`) VALUES
(91190, 7002, '0'),
(91190, 7003, '1073766176'),
(91190, 7004, 'Charizard'),
(91190, 7008, '1'),
(91190, 7015, '-1'),
(91190, 7021, '-1'),
(91190, 7031, '-1'),
(91190, 7043, '0'),
(91190, 7044, '0'),
(91190, 7059, '0'),
(91190, 7060, '-1'),
(91190, 7065, ''),
(91190, 7508, '-1'),
(91190, 10025, '1'),
(91190, 14002, '9'),
(91190, 14003, '0'),
(91190, 14005, '0'),
(91190, 14007, '0'),
(91192, 7015, '-1'),
(91192, 7021, '-1'),
(91192, 7031, '-1'),
(91192, 7043, '0'),
(91192, 7044, '0'),
(91192, 7060, '-1'),
(91192, 7065, ''),
(91192, 7508, '-1'),
(91192, 14003, '0'),
(91192, 14005, '0'),
(91192, 14007, '0'),
(91193, 7015, '-1'),
(91193, 7021, '-1'),
(91193, 7031, '-1'),
(91193, 7043, '0'),
(91193, 7044, '0'),
(91193, 7060, '-1'),
(91193, 7065, ''),
(91193, 7508, '-1'),
(91193, 14003, '0'),
(91193, 14005, '0'),
(91193, 14007, '0');

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_viplist`
--

CREATE TABLE `player_viplist` (
  `player_id` int(11) NOT NULL,
  `vip_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `pokemon_market`
--

CREATE TABLE `pokemon_market` (
  `id` int(10) UNSIGNED NOT NULL,
  `player_id` int(11) NOT NULL DEFAULT 0,
  `date` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  `pokemon_name` varchar(100) NOT NULL DEFAULT '0',
  `pokemon_level` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `pokemon_extrapoints` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `pokemon_sex` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `pokemon_specialability` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `ball_id` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL,
  `value` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `pokemon_eggmove` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `poketrader_bids`
--

CREATE TABLE `poketrader_bids` (
  `player_id` int(11) NOT NULL,
  `offert_id` int(10) UNSIGNED NOT NULL,
  `created` bigint(20) UNSIGNED NOT NULL,
  `bid` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `poketrader_offerts`
--

CREATE TABLE `poketrader_offerts` (
  `id` int(10) UNSIGNED NOT NULL,
  `item_id` mediumint(8) UNSIGNED NOT NULL,
  `count` smallint(5) UNSIGNED NOT NULL,
  `min_bid` int(10) UNSIGNED NOT NULL,
  `created` bigint(20) UNSIGNED NOT NULL,
  `deadline` bigint(20) UNSIGNED NOT NULL,
  `world_id` smallint(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `poketrader_offerts`
--

INSERT INTO `poketrader_offerts` (`id`, `item_id`, `count`, `min_bid`, `created`, `deadline`, `world_id`) VALUES
(10306, 13305, 100, 5000, 1596259449, 1596864249, 1),
(10307, 23546, 1, 1000, 1596259449, 1596864249, 1),
(10308, 17363, 1, 5000, 1596271418, 1596876218, 0),
(10309, 18926, 1, 1000, 1596271418, 1596876218, 0),
(10310, 13305, 100, 5000, 1596271418, 1596876218, 0),
(10311, 23546, 1, 1000, 1596271418, 1596876218, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `polls`
--

CREATE TABLE `polls` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `question` tinytext NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `deadline` datetime NOT NULL,
  `text_mode` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `poll_options`
--

CREATE TABLE `poll_options` (
  `id` int(10) UNSIGNED NOT NULL,
  `poll_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `poll_texts`
--

CREATE TABLE `poll_texts` (
  `poll_id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) NOT NULL,
  `text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `poll_votes`
--

CREATE TABLE `poll_votes` (
  `poll_id` int(10) UNSIGNED NOT NULL,
  `account_id` int(11) NOT NULL,
  `poll_option_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `rank_caught_species`
--

CREATE TABLE `rank_caught_species` (
  `player_id` int(11) NOT NULL,
  `value` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `rank_generals`
--

CREATE TABLE `rank_generals` (
  `player_id` int(11) NOT NULL,
  `value` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `rank_pvps`
--

CREATE TABLE `rank_pvps` (
  `player_id` int(11) NOT NULL,
  `value` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `referral_friends`
--

CREATE TABLE `referral_friends` (
  `account_referral` int(11) NOT NULL,
  `account_friend` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `servers`
--

CREATE TABLE `servers` (
  `id` int(11) NOT NULL,
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `world_id` int(11) NOT NULL,
  `name` varchar(300) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_config`
--

CREATE TABLE `server_config` (
  `config` varchar(35) NOT NULL DEFAULT '',
  `value` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_config`
--

INSERT INTO `server_config` (`config`, `value`) VALUES
('db_version', 23),
('encryption', 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_motd`
--

CREATE TABLE `server_motd` (
  `id` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_motd`
--

INSERT INTO `server_motd` (`id`, `world_id`, `text`) VALUES
(35, 1, 'Sejá bem vindo ao Pokemon Genesis World, Treinador(a)'),
(497, 0, 'Sejá bem vindo ao Pokemon Genesis World, Treinador(a)');

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_record`
--

CREATE TABLE `server_record` (
  `record` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `timestamp` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_record`
--

INSERT INTO `server_record` (`record`, `world_id`, `timestamp`) VALUES
(1, 0, 1596271445),
(1, 1, 1596262764);

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_reports`
--

CREATE TABLE `server_reports` (
  `id` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `player_id` int(11) NOT NULL DEFAULT 1,
  `posx` int(11) NOT NULL DEFAULT 0,
  `posy` int(11) NOT NULL DEFAULT 0,
  `posz` int(11) NOT NULL DEFAULT 0,
  `timestamp` bigint(20) NOT NULL DEFAULT 0,
  `report` text NOT NULL,
  `reads` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tickets`
--

CREATE TABLE `tickets` (
  `id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `subject` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `account_id` mediumint(11) NOT NULL,
  `open` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ticket_categories`
--

CREATE TABLE `ticket_categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `ticket_messages`
--

CREATE TABLE `ticket_messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `ticket_id` int(10) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `from_user` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tiles`
--

CREATE TABLE `tiles` (
  `id` int(11) NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `house_id` int(10) UNSIGNED NOT NULL,
  `x` int(5) UNSIGNED NOT NULL,
  `y` int(5) UNSIGNED NOT NULL,
  `z` tinyint(2) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tile_items`
--

CREATE TABLE `tile_items` (
  `tile_id` int(10) UNSIGNED NOT NULL,
  `world_id` tinyint(2) UNSIGNED NOT NULL DEFAULT 0,
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT 0,
  `itemtype` int(11) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 0,
  `attributes` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournaments`
--

CREATE TABLE `tournaments` (
  `id` int(10) NOT NULL,
  `last_winner` int(11) NOT NULL DEFAULT 0,
  `last_date` bigint(20) NOT NULL DEFAULT 0,
  `number` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `tournament_id` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `next_date` bigint(20) NOT NULL DEFAULT 0,
  `world_id` int(10) NOT NULL DEFAULT 0,
  `min_level` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `max_level` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `tournaments`
--

INSERT INTO `tournaments` (`id`, `last_winner`, `last_date`, `number`, `tournament_id`, `next_date`, `world_id`, `min_level`, `max_level`, `name`) VALUES
(17, 0, 0, 0, 1, 1596409200, 1, 80, 100, 'Titan'),
(18, 0, 0, 0, 4, 1596405600, 1, 41, 50, 'Pro'),
(19, 0, 0, 0, 5, 1596402000, 1, 20, 40, 'Starter'),
(20, 0, 0, 0, 6, 1596312000, 1, 45, 100, 'Epic 1'),
(21, 0, 0, 0, 7, 1596319200, 1, 45, 100, 'Epic 2'),
(22, 0, 0, 0, 8, 1596326400, 1, 45, 100, 'Epic 3'),
(23, 0, 0, 0, 9, 1596315600, 1, 50, 100, 'Mastery'),
(24, 0, 0, 0, 10, 1596412800, 1, 45, 100, 'Epic'),
(25, 0, 0, 0, 1, 0, 0, 80, 100, 'Titan'),
(26, 0, 0, 0, 4, 0, 0, 41, 50, 'Pro'),
(27, 0, 0, 0, 5, 0, 0, 20, 40, 'Starter'),
(28, 0, 0, 0, 6, 0, 0, 45, 100, 'Epic 1'),
(29, 0, 0, 0, 7, 0, 0, 45, 100, 'Epic 2'),
(30, 0, 0, 0, 8, 0, 0, 45, 100, 'Epic 3'),
(31, 0, 0, 0, 9, 0, 0, 50, 100, 'Mastery'),
(32, 0, 0, 0, 10, 0, 0, 45, 100, 'Epic');

--
-- Acionadores `tournaments`
--
DELIMITER $$
CREATE TRIGGER `ondelete_tournaments` BEFORE DELETE ON `tournaments` FOR EACH ROW BEGIN
	DELETE FROM `tournament_inscriptions` WHERE `tournament_inscriptions`.`tournament_id` = OLD.`id`;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_bans`
--

CREATE TABLE `tournament_bans` (
  `id` int(10) NOT NULL,
  `player_id` int(11) DEFAULT 0,
  `expires` bigint(20) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_histories`
--

CREATE TABLE `tournament_histories` (
  `id` int(11) NOT NULL,
  `tournament_id` int(10) NOT NULL,
  `winner` int(11) NOT NULL,
  `loser` int(11) NOT NULL,
  `date` bigint(20) NOT NULL,
  `round` tinyint(4) NOT NULL DEFAULT 0,
  `show` tinyint(1) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_history_pokemon`
--

CREATE TABLE `tournament_history_pokemon` (
  `tournament_history_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `pokemon_number` int(11) NOT NULL,
  `description` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_inscriptions`
--

CREATE TABLE `tournament_inscriptions` (
  `id` int(10) NOT NULL,
  `tournament_id` int(10) DEFAULT 0,
  `player_id` int(11) DEFAULT 0,
  `account_id` int(11) DEFAULT 0,
  `world_id` int(10) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_teams`
--

CREATE TABLE `tournament_teams` (
  `id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_team_players`
--

CREATE TABLE `tournament_team_players` (
  `team_id` int(11) UNSIGNED DEFAULT NULL,
  `player_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_weekly_winners`
--

CREATE TABLE `tournament_weekly_winners` (
  `player_id` int(11) NOT NULL,
  `date` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tournament_winners`
--

CREATE TABLE `tournament_winners` (
  `id` int(11) NOT NULL,
  `tournament_id` int(10) NOT NULL,
  `winner` int(11) NOT NULL,
  `date` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote`
--

CREATE TABLE `znote` (
  `id` int(10) NOT NULL,
  `version` varchar(30) NOT NULL COMMENT 'Znote AAC version',
  `installed` int(10) NOT NULL,
  `cached` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `znote`
--

INSERT INTO `znote` (`id`, `version`, `installed`, `cached`) VALUES
(1, '1.5_SVN', 1596250800, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_accounts`
--

CREATE TABLE `znote_accounts` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `ip` bigint(20) UNSIGNED NOT NULL,
  `created` int(10) NOT NULL,
  `points` int(10) DEFAULT 0,
  `cooldown` int(10) DEFAULT 0,
  `active` tinyint(4) NOT NULL DEFAULT 0,
  `active_email` tinyint(4) NOT NULL DEFAULT 0,
  `activekey` int(11) NOT NULL DEFAULT 0,
  `flag` varchar(20) NOT NULL,
  `secret` char(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `znote_accounts`
--

INSERT INTO `znote_accounts` (`id`, `account_id`, `ip`, `created`, `points`, `cooldown`, `active`, `active_email`, `activekey`, `flag`, `secret`) VALUES
(1, 70846, 0, 1596262315, 0, 0, 1, 0, 777168221, 'br', NULL),
(2, 70847, 0, 1596263658, 0, 0, 1, 0, 553942700, 'br', NULL),
(3, 70848, 2130706433, 1596271075, 0, 0, 1, 0, 156763690, 'br', NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_auction_player`
--

CREATE TABLE `znote_auction_player` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `original_account_id` int(11) NOT NULL,
  `bidder_account_id` int(11) NOT NULL,
  `time_begin` int(11) NOT NULL,
  `time_end` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `bid` int(11) NOT NULL,
  `deposit` int(11) NOT NULL,
  `sold` tinyint(1) NOT NULL,
  `claimed` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_changelog`
--

CREATE TABLE `znote_changelog` (
  `id` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `status` tinyint(3) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_deleted_characters`
--

CREATE TABLE `znote_deleted_characters` (
  `id` int(11) NOT NULL,
  `original_account_id` int(11) NOT NULL,
  `character_name` varchar(255) NOT NULL,
  `time` datetime NOT NULL,
  `done` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_forum`
--

CREATE TABLE `znote_forum` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `access` tinyint(4) NOT NULL,
  `closed` tinyint(4) NOT NULL,
  `hidden` tinyint(4) NOT NULL,
  `guild_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `znote_forum`
--

INSERT INTO `znote_forum` (`id`, `name`, `access`, `closed`, `hidden`, `guild_id`) VALUES
(1, 'Staff Board', 4, 0, 0, 0),
(2, 'Tutors Board', 2, 0, 0, 0),
(3, 'Discussion', 1, 0, 0, 0),
(4, 'Feedback', 1, 0, 1, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_forum_posts`
--

CREATE TABLE `znote_forum_posts` (
  `id` int(11) NOT NULL,
  `thread_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(50) NOT NULL,
  `text` text NOT NULL,
  `created` int(11) NOT NULL,
  `updated` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_forum_threads`
--

CREATE TABLE `znote_forum_threads` (
  `id` int(11) NOT NULL,
  `forum_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `text` text NOT NULL,
  `created` int(11) NOT NULL,
  `updated` int(11) NOT NULL,
  `sticky` tinyint(4) NOT NULL,
  `hidden` tinyint(4) NOT NULL,
  `closed` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_global_storage`
--

CREATE TABLE `znote_global_storage` (
  `key` varchar(32) NOT NULL,
  `value` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_guild_wars`
--

CREATE TABLE `znote_guild_wars` (
  `id` int(11) NOT NULL,
  `limit` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_images`
--

CREATE TABLE `znote_images` (
  `id` int(11) NOT NULL,
  `title` varchar(30) NOT NULL,
  `desc` text NOT NULL,
  `date` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `image` varchar(30) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_news`
--

CREATE TABLE `znote_news` (
  `id` int(11) NOT NULL,
  `title` varchar(30) NOT NULL,
  `text` text NOT NULL,
  `date` int(11) NOT NULL,
  `pid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `znote_news`
--

INSERT INTO `znote_news` (`id`, `title`, `text`, `date`, `pid`) VALUES
(1, 'Teste de Noticia', 'blablablablaablablablablaablablablablaa<br>inaugurado 100%', 1596266782, 91190);

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_paygol`
--

CREATE TABLE `znote_paygol` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `points` int(11) NOT NULL,
  `message_id` varchar(255) NOT NULL,
  `service_id` varchar(255) NOT NULL,
  `shortcode` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `sender` varchar(255) NOT NULL,
  `operator` varchar(255) NOT NULL,
  `country` varchar(255) NOT NULL,
  `currency` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_paypal`
--

CREATE TABLE `znote_paypal` (
  `id` int(11) NOT NULL,
  `txn_id` varchar(30) NOT NULL,
  `email` varchar(255) NOT NULL,
  `accid` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_players`
--

CREATE TABLE `znote_players` (
  `id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `created` int(11) NOT NULL,
  `hide_char` tinyint(4) NOT NULL,
  `comment` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Extraindo dados da tabela `znote_players`
--

INSERT INTO `znote_players` (`id`, `player_id`, `created`, `hide_char`, `comment`) VALUES
(1, 91190, 1596262328, 0, ''),
(2, 91191, 1596267119, 0, ''),
(3, 91192, 1596271086, 0, ''),
(4, 91193, 1596271515, 0, '');

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_player_reports`
--

CREATE TABLE `znote_player_reports` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `posx` int(6) NOT NULL,
  `posy` int(6) NOT NULL,
  `posz` int(6) NOT NULL,
  `report_description` varchar(255) NOT NULL,
  `date` int(11) NOT NULL,
  `status` tinyint(3) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_shop`
--

CREATE TABLE `znote_shop` (
  `id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) DEFAULT NULL,
  `count` int(11) NOT NULL DEFAULT 1,
  `description` varchar(255) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_shop_logs`
--

CREATE TABLE `znote_shop_logs` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `points` int(11) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_shop_orders`
--

CREATE TABLE `znote_shop_orders` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `time` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_tickets`
--

CREATE TABLE `znote_tickets` (
  `id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET latin1 NOT NULL,
  `subject` text CHARACTER SET latin1 NOT NULL,
  `message` text CHARACTER SET latin1 NOT NULL,
  `ip` bigint(20) NOT NULL,
  `creation` int(11) NOT NULL,
  `status` varchar(20) CHARACTER SET latin1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_tickets_replies`
--

CREATE TABLE `znote_tickets_replies` (
  `id` int(11) NOT NULL,
  `tid` int(11) NOT NULL,
  `username` varchar(32) CHARACTER SET latin1 NOT NULL,
  `message` text CHARACTER SET latin1 NOT NULL,
  `created` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_visitors`
--

CREATE TABLE `znote_visitors` (
  `id` int(11) NOT NULL,
  `ip` bigint(20) NOT NULL,
  `value` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `znote_visitors_details`
--

CREATE TABLE `znote_visitors_details` (
  `id` int(11) NOT NULL,
  `ip` bigint(20) NOT NULL,
  `time` int(11) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Índices para tabela `account_storage`
--
ALTER TABLE `account_storage`
  ADD UNIQUE KEY `account_id_key` (`account_id`,`key`);

--
-- Índices para tabela `account_viplist`
--
ALTER TABLE `account_viplist`
  ADD UNIQUE KEY `account_id_2` (`account_id`,`player_id`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `player_id` (`player_id`),
  ADD KEY `world_id` (`world_id`);

--
-- Índices para tabela `ball_counter`
--
ALTER TABLE `ball_counter`
  ADD PRIMARY KEY (`player_id`,`pokemon_id`);

--
-- Índices para tabela `bans`
--
ALTER TABLE `bans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type` (`type`,`value`),
  ADD KEY `active` (`active`);

--
-- Índices para tabela `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `blog_post_categories`
--
ALTER TABLE `blog_post_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Índices para tabela `blog_post_categories_blog_posts`
--
ALTER TABLE `blog_post_categories_blog_posts`
  ADD PRIMARY KEY (`blog_post_category_id`,`blog_post_id`);

--
-- Índices para tabela `blog_post_comments`
--
ALTER TABLE `blog_post_comments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `FK_blog_post_comments_accounts` (`account_id`),
  ADD KEY `FK_blog_post_comments_blog_posts` (`post_id`);

--
-- Índices para tabela `blog_post_loves`
--
ALTER TABLE `blog_post_loves`
  ADD PRIMARY KEY (`blog_post_id`,`account_id`),
  ADD UNIQUE KEY `post_id_account_id` (`blog_post_id`,`account_id`);

--
-- Índices para tabela `change_emails`
--
ALTER TABLE `change_emails`
  ADD KEY `id` (`id`);

--
-- Índices para tabela `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `coupon_uses`
--
ALTER TABLE `coupon_uses`
  ADD UNIQUE KEY `coupon_id_account_id` (`coupon_id`,`account_id`),
  ADD KEY `FK_coupon_uses_accounts` (`account_id`);

--
-- Índices para tabela `datalog_anniversary_drops`
--
ALTER TABLE `datalog_anniversary_drops`
  ADD KEY `FK_datalog_anniversary_drops_players` (`player_id`);

--
-- Índices para tabela `datalog_boss_rewards`
--
ALTER TABLE `datalog_boss_rewards`
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `datalog_casino_token_bought`
--
ALTER TABLE `datalog_casino_token_bought`
  ADD KEY `datalog_casino_token_bought_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_caughts`
--
ALTER TABLE `datalog_caughts`
  ADD KEY `datalog_caughts_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_christmas_drops`
--
ALTER TABLE `datalog_christmas_drops`
  ADD KEY `FK_datalog_christmas_drops_players` (`player_id`);

--
-- Índices para tabela `datalog_coin_uses`
--
ALTER TABLE `datalog_coin_uses`
  ADD KEY `datalog_coin_uses_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_colosseum_arena`
--
ALTER TABLE `datalog_colosseum_arena`
  ADD KEY `FK_datalog_colosseum_arena_accounts` (`account_id`);

--
-- Índices para tabela `datalog_duel_bet`
--
ALTER TABLE `datalog_duel_bet`
  ADD KEY `FK_datalog_duel_bet_players` (`leader_a`),
  ADD KEY `FK_datalog_duel_bet_players_2` (`leader_b`),
  ADD KEY `FK_datalog_duel_bet_players_3` (`player_id`);

--
-- Índices para tabela `datalog_easter_drops`
--
ALTER TABLE `datalog_easter_drops`
  ADD KEY `FK_datalog_easter_drops_players` (`player_id`);

--
-- Índices para tabela `datalog_egg_generate`
--
ALTER TABLE `datalog_egg_generate`
  ADD KEY `datalog_egg_generate_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_egg_move_generate`
--
ALTER TABLE `datalog_egg_move_generate`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_datalog_egg_move_generate_players` (`player_id`);

--
-- Índices para tabela `datalog_egg_move_regenerate`
--
ALTER TABLE `datalog_egg_move_regenerate`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_datalog_egg_move_regenerate_players` (`player_id`);

--
-- Índices para tabela `datalog_halloween_drops`
--
ALTER TABLE `datalog_halloween_drops`
  ADD KEY `FK_datalog_halloween_drops_players` (`player_id`);

--
-- Índices para tabela `datalog_julyvacation_drops`
--
ALTER TABLE `datalog_julyvacation_drops`
  ADD KEY `FK_datalog_julyvacation_drops_players` (`player_id`);

--
-- Índices para tabela `datalog_logins`
--
ALTER TABLE `datalog_logins`
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `datalog_mastery_token_bought`
--
ALTER TABLE `datalog_mastery_token_bought`
  ADD KEY `datalog_mastery_token_bought_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_player_ups`
--
ALTER TABLE `datalog_player_ups`
  ADD KEY `datalog_player_ups_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_pokemon_market`
--
ALTER TABLE `datalog_pokemon_market`
  ADD KEY `datalog_pokemon_market_ibfk_1` (`seller`),
  ADD KEY `datalog_pokemon_market_ibfk_2` (`buyer`);

--
-- Índices para tabela `datalog_pokemon_ups`
--
ALTER TABLE `datalog_pokemon_ups`
  ADD KEY `datalog_pokemon_ups_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_poketrader_boughts`
--
ALTER TABLE `datalog_poketrader_boughts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_datalog_poketrader_boughts_players` (`player_id`);

--
-- Índices para tabela `datalog_poke_nick_change`
--
ALTER TABLE `datalog_poke_nick_change`
  ADD KEY `datalog_poke_nick_change_ibfk_1` (`player_id`);

--
-- Índices para tabela `datalog_rangerclub_boss`
--
ALTER TABLE `datalog_rangerclub_boss`
  ADD KEY `FK_datalog_rangerclub_boss_players` (`player_id`);

--
-- Índices para tabela `datalog_rangerclub_boss_rewards`
--
ALTER TABLE `datalog_rangerclub_boss_rewards`
  ADD KEY `FK_datalog_rangerclub_boss_rewards_players` (`player_id`);

--
-- Índices para tabela `datalog_rangerclub_task`
--
ALTER TABLE `datalog_rangerclub_task`
  ADD KEY `FK_datalog_rangerclub_task_players` (`player_id`);

--
-- Índices para tabela `datalog_referral_exchange`
--
ALTER TABLE `datalog_referral_exchange`
  ADD KEY `datalog_referral_exchange_players` (`player_id`);

--
-- Índices para tabela `datalog_slot_machine`
--
ALTER TABLE `datalog_slot_machine`
  ADD KEY `FK_datalog_slot_machine_players` (`player_id`);

--
-- Índices para tabela `datalog_surprise_box`
--
ALTER TABLE `datalog_surprise_box`
  ADD KEY `FK_datalog_surprise_box_players` (`player_id`);

--
-- Índices para tabela `datalog_token_bought`
--
ALTER TABLE `datalog_token_bought`
  ADD KEY `datalog_token_bought_ibfk_1` (`player_id`);

--
-- Índices para tabela `daycare_female`
--
ALTER TABLE `daycare_female`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `daycare_male`
--
ALTER TABLE `daycare_male`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `daycare_plates`
--
ALTER TABLE `daycare_plates`
  ADD UNIQUE KEY `player_id` (`player_id`);

--
-- Índices para tabela `delete_players`
--
ALTER TABLE `delete_players`
  ADD KEY `id` (`id`);

--
-- Índices para tabela `donates`
--
ALTER TABLE `donates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_donates_accounts` (`account_id`);

--
-- Índices para tabela `egg_counter`
--
ALTER TABLE `egg_counter`
  ADD PRIMARY KEY (`player_id`,`pokemon_id`);

--
-- Índices para tabela `elite_four_champions`
--
ALTER TABLE `elite_four_champions`
  ADD UNIQUE KEY `player_id` (`player_id`);

--
-- Índices para tabela `elite_four_champion_pokemons`
--
ALTER TABLE `elite_four_champion_pokemons`
  ADD KEY `FK_elite_four_champion_pokemons_players` (`player_id`);

--
-- Índices para tabela `environment_killers`
--
ALTER TABLE `environment_killers`
  ADD KEY `kill_id` (`kill_id`);

--
-- Índices para tabela `global_storage`
--
ALTER TABLE `global_storage`
  ADD UNIQUE KEY `key` (`key`,`world_id`),
  ADD UNIQUE KEY `key_2` (`key`,`world_id`),
  ADD UNIQUE KEY `key_3` (`key`,`world_id`);

--
-- Índices para tabela `guilds`
--
ALTER TABLE `guilds`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`world_id`),
  ADD UNIQUE KEY `name_2` (`name`,`world_id`),
  ADD UNIQUE KEY `name_3` (`name`,`world_id`);

--
-- Índices para tabela `guild_invites`
--
ALTER TABLE `guild_invites`
  ADD UNIQUE KEY `player_id` (`player_id`,`guild_id`),
  ADD KEY `guild_id` (`guild_id`);

--
-- Índices para tabela `guild_loves`
--
ALTER TABLE `guild_loves`
  ADD PRIMARY KEY (`guild_id`,`account_id`),
  ADD UNIQUE KEY `guild_id_account_id` (`guild_id`,`account_id`),
  ADD KEY `FK_guild_loves_accounts` (`account_id`);

--
-- Índices para tabela `guild_ranks`
--
ALTER TABLE `guild_ranks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guild_id` (`guild_id`);

--
-- Índices para tabela `houses`
--
ALTER TABLE `houses`
  ADD UNIQUE KEY `id` (`id`,`world_id`),
  ADD UNIQUE KEY `id_2` (`id`,`world_id`),
  ADD UNIQUE KEY `id_3` (`id`,`world_id`);

--
-- Índices para tabela `house_auctions`
--
ALTER TABLE `house_auctions`
  ADD UNIQUE KEY `house_id` (`house_id`,`world_id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `house_data`
--
ALTER TABLE `house_data`
  ADD UNIQUE KEY `house_id` (`house_id`,`world_id`);

--
-- Índices para tabela `house_lists`
--
ALTER TABLE `house_lists`
  ADD UNIQUE KEY `house_id` (`house_id`,`world_id`,`listid`),
  ADD UNIQUE KEY `house_id_2` (`house_id`,`world_id`,`listid`),
  ADD UNIQUE KEY `house_id_3` (`house_id`,`world_id`,`listid`);

--
-- Índices para tabela `instant_payment_notifications`
--
ALTER TABLE `instant_payment_notifications`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `killers`
--
ALTER TABLE `killers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `death_id` (`death_id`);

--
-- Índices para tabela `loyalty_ranks`
--
ALTER TABLE `loyalty_ranks`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `market_history`
--
ALTER TABLE `market_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`,`sale`);

--
-- Índices para tabela `market_offers`
--
ALTER TABLE `market_offers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sale` (`sale`,`itemtype`),
  ADD KEY `created` (`created`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `parcels`
--
ALTER TABLE `parcels`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `password_requests`
--
ALTER TABLE `password_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `FK_password_requests_accounts` (`account_id`);

--
-- Índices para tabela `paypal_items`
--
ALTER TABLE `paypal_items`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`deleted`),
  ADD KEY `account_id` (`account_id`),
  ADD KEY `online` (`online`),
  ADD KEY `deleted` (`deleted`);

--
-- Índices para tabela `player_achievements`
--
ALTER TABLE `player_achievements`
  ADD UNIQUE KEY `player_id_key` (`player_id`,`key`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_deaths`
--
ALTER TABLE `player_deaths`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`),
  ADD KEY `date` (`date`);

--
-- Índices para tabela `player_depotitems`
--
ALTER TABLE `player_depotitems`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_highscores`
--
ALTER TABLE `player_highscores`
  ADD PRIMARY KEY (`player_id`,`score_id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_items`
--
ALTER TABLE `player_items`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`sid`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_killers`
--
ALTER TABLE `player_killers`
  ADD KEY `kill_id` (`kill_id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_namelocks`
--
ALTER TABLE `player_namelocks`
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_pokemon`
--
ALTER TABLE `player_pokemon`
  ADD UNIQUE KEY `player_id_slot` (`player_id`,`slot`);

--
-- Índices para tabela `player_skills`
--
ALTER TABLE `player_skills`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`skillid`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_spells`
--
ALTER TABLE `player_spells`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`name`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_statistics`
--
ALTER TABLE `player_statistics`
  ADD UNIQUE KEY `player_id_key` (`player_id`,`key`);

--
-- Índices para tabela `player_storage`
--
ALTER TABLE `player_storage`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`key`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `player_viplist`
--
ALTER TABLE `player_viplist`
  ADD UNIQUE KEY `player_id_2` (`player_id`,`vip_id`),
  ADD KEY `player_id` (`player_id`),
  ADD KEY `vip_id` (`vip_id`);

--
-- Índices para tabela `pokemon_market`
--
ALTER TABLE `pokemon_market`
  ADD PRIMARY KEY (`id`),
  ADD KEY `player_id` (`player_id`);

--
-- Índices para tabela `poketrader_bids`
--
ALTER TABLE `poketrader_bids`
  ADD UNIQUE KEY `player_id_offert_id` (`player_id`,`offert_id`),
  ADD KEY `FK_poketrader_bids_poketrader_offerts` (`offert_id`);

--
-- Índices para tabela `poketrader_offerts`
--
ALTER TABLE `poketrader_offerts`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `polls`
--
ALTER TABLE `polls`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `poll_options`
--
ALTER TABLE `poll_options`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_poll_options_polls` (`poll_id`);

--
-- Índices para tabela `poll_texts`
--
ALTER TABLE `poll_texts`
  ADD UNIQUE KEY `poll_id_account_id` (`poll_id`,`account_id`),
  ADD KEY `FK_poll_texts_accounts` (`account_id`);

--
-- Índices para tabela `poll_votes`
--
ALTER TABLE `poll_votes`
  ADD UNIQUE KEY `poll_id_account_id` (`poll_id`,`account_id`),
  ADD KEY `FK_poll_votes_accounts` (`account_id`),
  ADD KEY `FK_poll_votes_poll_options` (`poll_option_id`);

--
-- Índices para tabela `rank_caught_species`
--
ALTER TABLE `rank_caught_species`
  ADD UNIQUE KEY `player_id` (`player_id`),
  ADD KEY `FK_rank_caught_especies_players` (`player_id`);

--
-- Índices para tabela `rank_generals`
--
ALTER TABLE `rank_generals`
  ADD UNIQUE KEY `player_id` (`player_id`);

--
-- Índices para tabela `rank_pvps`
--
ALTER TABLE `rank_pvps`
  ADD UNIQUE KEY `player_id` (`player_id`),
  ADD KEY `FK_rank_pvp_players` (`player_id`);

--
-- Índices para tabela `referral_friends`
--
ALTER TABLE `referral_friends`
  ADD UNIQUE KEY `account_referral_account_friend` (`account_referral`,`account_friend`),
  ADD KEY `FK_referral_friends_accounts_2` (`account_friend`);

--
-- Índices para tabela `server_config`
--
ALTER TABLE `server_config`
  ADD UNIQUE KEY `config` (`config`);

--
-- Índices para tabela `server_motd`
--
ALTER TABLE `server_motd`
  ADD UNIQUE KEY `id` (`id`,`world_id`),
  ADD UNIQUE KEY `id_2` (`id`,`world_id`),
  ADD UNIQUE KEY `id_3` (`id`,`world_id`);

--
-- Índices para tabela `server_record`
--
ALTER TABLE `server_record`
  ADD UNIQUE KEY `record` (`record`,`world_id`,`timestamp`),
  ADD UNIQUE KEY `timestamp` (`timestamp`,`record`,`world_id`),
  ADD UNIQUE KEY `timestamp_2` (`timestamp`,`record`,`world_id`);

--
-- Índices para tabela `server_reports`
--
ALTER TABLE `server_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `world_id` (`world_id`),
  ADD KEY `reads` (`reads`),
  ADD KEY `player_id` (`player_id`),
  ADD KEY `world_id_2` (`world_id`),
  ADD KEY `world_id_3` (`world_id`);

--
-- Índices para tabela `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_tickets_ticket_categories` (`category_id`);

--
-- Índices para tabela `ticket_categories`
--
ALTER TABLE `ticket_categories`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `ticket_messages`
--
ALTER TABLE `ticket_messages`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `tiles`
--
ALTER TABLE `tiles`
  ADD UNIQUE KEY `id` (`id`,`world_id`),
  ADD UNIQUE KEY `id_2` (`id`,`world_id`),
  ADD UNIQUE KEY `id_3` (`id`,`world_id`),
  ADD KEY `x` (`x`,`y`,`z`),
  ADD KEY `house_id` (`house_id`,`world_id`),
  ADD KEY `x_2` (`x`,`y`,`z`),
  ADD KEY `x_3` (`x`,`y`,`z`);

--
-- Índices para tabela `tile_items`
--
ALTER TABLE `tile_items`
  ADD UNIQUE KEY `tile_id` (`tile_id`,`world_id`,`sid`),
  ADD UNIQUE KEY `tile_id_2` (`tile_id`,`world_id`,`sid`),
  ADD UNIQUE KEY `tile_id_3` (`tile_id`,`world_id`,`sid`),
  ADD KEY `sid` (`sid`),
  ADD KEY `sid_2` (`sid`),
  ADD KEY `sid_3` (`sid`);

--
-- Índices para tabela `tournaments`
--
ALTER TABLE `tournaments`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `tournament_bans`
--
ALTER TABLE `tournament_bans`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `tournament_histories`
--
ALTER TABLE `tournament_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_tournament_histories_tournaments` (`tournament_id`);

--
-- Índices para tabela `tournament_history_pokemon`
--
ALTER TABLE `tournament_history_pokemon`
  ADD KEY `FK_tournament_history_pokemon_tournament_histories` (`tournament_history_id`),
  ADD KEY `FK_tournament_history_pokemon_players` (`player_id`);

--
-- Índices para tabela `tournament_inscriptions`
--
ALTER TABLE `tournament_inscriptions`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `tournament_teams`
--
ALTER TABLE `tournament_teams`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `tournament_team_players`
--
ALTER TABLE `tournament_team_players`
  ADD KEY `FK_tournament_team_players_players` (`player_id`),
  ADD KEY `FK_tournament_team_players_tournament_teams` (`team_id`);

--
-- Índices para tabela `tournament_weekly_winners`
--
ALTER TABLE `tournament_weekly_winners`
  ADD KEY `FK_tournament_weekly_winners_players` (`player_id`);

--
-- Índices para tabela `tournament_winners`
--
ALTER TABLE `tournament_winners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK_tournament_winners_tournaments` (`tournament_id`);

--
-- Índices para tabela `znote`
--
ALTER TABLE `znote`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_accounts`
--
ALTER TABLE `znote_accounts`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_auction_player`
--
ALTER TABLE `znote_auction_player`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_changelog`
--
ALTER TABLE `znote_changelog`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_deleted_characters`
--
ALTER TABLE `znote_deleted_characters`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_forum`
--
ALTER TABLE `znote_forum`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_forum_posts`
--
ALTER TABLE `znote_forum_posts`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_forum_threads`
--
ALTER TABLE `znote_forum_threads`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_global_storage`
--
ALTER TABLE `znote_global_storage`
  ADD UNIQUE KEY `key` (`key`);

--
-- Índices para tabela `znote_guild_wars`
--
ALTER TABLE `znote_guild_wars`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_images`
--
ALTER TABLE `znote_images`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_news`
--
ALTER TABLE `znote_news`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_paygol`
--
ALTER TABLE `znote_paygol`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_paypal`
--
ALTER TABLE `znote_paypal`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_players`
--
ALTER TABLE `znote_players`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_player_reports`
--
ALTER TABLE `znote_player_reports`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_shop`
--
ALTER TABLE `znote_shop`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_shop_logs`
--
ALTER TABLE `znote_shop_logs`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_shop_orders`
--
ALTER TABLE `znote_shop_orders`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_tickets`
--
ALTER TABLE `znote_tickets`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_tickets_replies`
--
ALTER TABLE `znote_tickets_replies`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_visitors`
--
ALTER TABLE `znote_visitors`
  ADD PRIMARY KEY (`id`);

--
-- Índices para tabela `znote_visitors_details`
--
ALTER TABLE `znote_visitors_details`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70849;

--
-- AUTO_INCREMENT de tabela `bans`
--
ALTER TABLE `bans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1590;

--
-- AUTO_INCREMENT de tabela `blog_posts`
--
ALTER TABLE `blog_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT de tabela `blog_post_categories`
--
ALTER TABLE `blog_post_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de tabela `blog_post_comments`
--
ALTER TABLE `blog_post_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de tabela `change_emails`
--
ALTER TABLE `change_emails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=620;

--
-- AUTO_INCREMENT de tabela `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `datalog_egg_move_generate`
--
ALTER TABLE `datalog_egg_move_generate`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7734;

--
-- AUTO_INCREMENT de tabela `datalog_egg_move_regenerate`
--
ALTER TABLE `datalog_egg_move_regenerate`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=391;

--
-- AUTO_INCREMENT de tabela `datalog_poketrader_boughts`
--
ALTER TABLE `datalog_poketrader_boughts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=447;

--
-- AUTO_INCREMENT de tabela `daycare_female`
--
ALTER TABLE `daycare_female`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164232;

--
-- AUTO_INCREMENT de tabela `daycare_male`
--
ALTER TABLE `daycare_male`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55712;

--
-- AUTO_INCREMENT de tabela `delete_players`
--
ALTER TABLE `delete_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1375;

--
-- AUTO_INCREMENT de tabela `donates`
--
ALTER TABLE `donates`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4475;

--
-- AUTO_INCREMENT de tabela `guilds`
--
ALTER TABLE `guilds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=224;

--
-- AUTO_INCREMENT de tabela `guild_ranks`
--
ALTER TABLE `guild_ranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=729;

--
-- AUTO_INCREMENT de tabela `killers`
--
ALTER TABLE `killers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `loyalty_ranks`
--
ALTER TABLE `loyalty_ranks`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `market_history`
--
ALTER TABLE `market_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `market_offers`
--
ALTER TABLE `market_offers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `parcels`
--
ALTER TABLE `parcels`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32316;

--
-- AUTO_INCREMENT de tabela `password_requests`
--
ALTER TABLE `password_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20101;

--
-- AUTO_INCREMENT de tabela `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91194;

--
-- AUTO_INCREMENT de tabela `player_deaths`
--
ALTER TABLE `player_deaths`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `pokemon_market`
--
ALTER TABLE `pokemon_market`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26858;

--
-- AUTO_INCREMENT de tabela `poketrader_offerts`
--
ALTER TABLE `poketrader_offerts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10312;

--
-- AUTO_INCREMENT de tabela `polls`
--
ALTER TABLE `polls`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT de tabela `poll_options`
--
ALTER TABLE `poll_options`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=229;

--
-- AUTO_INCREMENT de tabela `server_reports`
--
ALTER TABLE `server_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=203;

--
-- AUTO_INCREMENT de tabela `ticket_categories`
--
ALTER TABLE `ticket_categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `ticket_messages`
--
ALTER TABLE `ticket_messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=279;

--
-- AUTO_INCREMENT de tabela `tournaments`
--
ALTER TABLE `tournaments`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de tabela `tournament_bans`
--
ALTER TABLE `tournament_bans`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de tabela `tournament_histories`
--
ALTER TABLE `tournament_histories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30051;

--
-- AUTO_INCREMENT de tabela `tournament_inscriptions`
--
ALTER TABLE `tournament_inscriptions`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=277;

--
-- AUTO_INCREMENT de tabela `tournament_teams`
--
ALTER TABLE `tournament_teams`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1256;

--
-- AUTO_INCREMENT de tabela `tournament_winners`
--
ALTER TABLE `tournament_winners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3558;

--
-- AUTO_INCREMENT de tabela `znote`
--
ALTER TABLE `znote`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `znote_accounts`
--
ALTER TABLE `znote_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `znote_auction_player`
--
ALTER TABLE `znote_auction_player`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_changelog`
--
ALTER TABLE `znote_changelog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_deleted_characters`
--
ALTER TABLE `znote_deleted_characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_forum`
--
ALTER TABLE `znote_forum`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `znote_forum_posts`
--
ALTER TABLE `znote_forum_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_forum_threads`
--
ALTER TABLE `znote_forum_threads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_guild_wars`
--
ALTER TABLE `znote_guild_wars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_images`
--
ALTER TABLE `znote_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_news`
--
ALTER TABLE `znote_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `znote_paygol`
--
ALTER TABLE `znote_paygol`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_paypal`
--
ALTER TABLE `znote_paypal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_players`
--
ALTER TABLE `znote_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `znote_player_reports`
--
ALTER TABLE `znote_player_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_shop`
--
ALTER TABLE `znote_shop`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_shop_logs`
--
ALTER TABLE `znote_shop_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_shop_orders`
--
ALTER TABLE `znote_shop_orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_tickets`
--
ALTER TABLE `znote_tickets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_tickets_replies`
--
ALTER TABLE `znote_tickets_replies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_visitors`
--
ALTER TABLE `znote_visitors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `znote_visitors_details`
--
ALTER TABLE `znote_visitors_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `account_storage`
--
ALTER TABLE `account_storage`
  ADD CONSTRAINT `FK_account_storage_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `blog_post_comments`
--
ALTER TABLE `blog_post_comments`
  ADD CONSTRAINT `FK_blog_post_comments_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_blog_post_comments_blog_posts` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `coupon_uses`
--
ALTER TABLE `coupon_uses`
  ADD CONSTRAINT `FK_coupon_uses_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_coupon_uses_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_anniversary_drops`
--
ALTER TABLE `datalog_anniversary_drops`
  ADD CONSTRAINT `FK_datalog_anniversary_drops_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_boss_rewards`
--
ALTER TABLE `datalog_boss_rewards`
  ADD CONSTRAINT `FK__players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_casino_token_bought`
--
ALTER TABLE `datalog_casino_token_bought`
  ADD CONSTRAINT `datalog_casino_token_bought_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_caughts`
--
ALTER TABLE `datalog_caughts`
  ADD CONSTRAINT `datalog_caughts_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_christmas_drops`
--
ALTER TABLE `datalog_christmas_drops`
  ADD CONSTRAINT `FK_datalog_christmas_drops_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_coin_uses`
--
ALTER TABLE `datalog_coin_uses`
  ADD CONSTRAINT `datalog_coin_uses_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_colosseum_arena`
--
ALTER TABLE `datalog_colosseum_arena`
  ADD CONSTRAINT `FK_datalog_colosseum_arena_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_duel_bet`
--
ALTER TABLE `datalog_duel_bet`
  ADD CONSTRAINT `FK_datalog_duel_bet_players` FOREIGN KEY (`leader_a`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_datalog_duel_bet_players_2` FOREIGN KEY (`leader_b`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_datalog_duel_bet_players_3` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_easter_drops`
--
ALTER TABLE `datalog_easter_drops`
  ADD CONSTRAINT `FK_datalog_easter_drops_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_egg_generate`
--
ALTER TABLE `datalog_egg_generate`
  ADD CONSTRAINT `datalog_egg_generate_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_egg_move_generate`
--
ALTER TABLE `datalog_egg_move_generate`
  ADD CONSTRAINT `FK_datalog_egg_move_generate_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_egg_move_regenerate`
--
ALTER TABLE `datalog_egg_move_regenerate`
  ADD CONSTRAINT `FK_datalog_egg_move_regenerate_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_halloween_drops`
--
ALTER TABLE `datalog_halloween_drops`
  ADD CONSTRAINT `FK_datalog_halloween_drops_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_julyvacation_drops`
--
ALTER TABLE `datalog_julyvacation_drops`
  ADD CONSTRAINT `FK_datalog_julyvacation_drops_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_mastery_token_bought`
--
ALTER TABLE `datalog_mastery_token_bought`
  ADD CONSTRAINT `datalog_mastery_token_bought_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_player_ups`
--
ALTER TABLE `datalog_player_ups`
  ADD CONSTRAINT `datalog_player_ups_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_pokemon_market`
--
ALTER TABLE `datalog_pokemon_market`
  ADD CONSTRAINT `datalog_pokemon_market_ibfk_1` FOREIGN KEY (`seller`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `datalog_pokemon_market_ibfk_2` FOREIGN KEY (`buyer`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_pokemon_ups`
--
ALTER TABLE `datalog_pokemon_ups`
  ADD CONSTRAINT `datalog_pokemon_ups_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_poketrader_boughts`
--
ALTER TABLE `datalog_poketrader_boughts`
  ADD CONSTRAINT `FK_datalog_poketrader_boughts_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_poke_nick_change`
--
ALTER TABLE `datalog_poke_nick_change`
  ADD CONSTRAINT `datalog_poke_nick_change_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_rangerclub_boss`
--
ALTER TABLE `datalog_rangerclub_boss`
  ADD CONSTRAINT `FK_datalog_rangerclub_boss_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_rangerclub_boss_rewards`
--
ALTER TABLE `datalog_rangerclub_boss_rewards`
  ADD CONSTRAINT `FK_datalog_rangerclub_boss_rewards_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_rangerclub_task`
--
ALTER TABLE `datalog_rangerclub_task`
  ADD CONSTRAINT `FK_datalog_rangerclub_task_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_referral_exchange`
--
ALTER TABLE `datalog_referral_exchange`
  ADD CONSTRAINT `FK_datalog_referral_exchange_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_slot_machine`
--
ALTER TABLE `datalog_slot_machine`
  ADD CONSTRAINT `FK_datalog_slot_machine_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `datalog_surprise_box`
--
ALTER TABLE `datalog_surprise_box`
  ADD CONSTRAINT `FK_datalog_surprise_box_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `datalog_token_bought`
--
ALTER TABLE `datalog_token_bought`
  ADD CONSTRAINT `datalog_token_bought_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `daycare_plates`
--
ALTER TABLE `daycare_plates`
  ADD CONSTRAINT `FK_daycare_plates_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `donates`
--
ALTER TABLE `donates`
  ADD CONSTRAINT `FK_donates_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `elite_four_champions`
--
ALTER TABLE `elite_four_champions`
  ADD CONSTRAINT `FK_elite_four_champions_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `elite_four_champion_pokemons`
--
ALTER TABLE `elite_four_champion_pokemons`
  ADD CONSTRAINT `FK_elite_four_champion_pokemons_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `guild_invites`
--
ALTER TABLE `guild_invites`
  ADD CONSTRAINT `guild_invites_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_invites_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `guild_loves`
--
ALTER TABLE `guild_loves`
  ADD CONSTRAINT `FK_guild_loves_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_guild_loves_guilds` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `market_history`
--
ALTER TABLE `market_history`
  ADD CONSTRAINT `market_history_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `market_offers`
--
ALTER TABLE `market_offers`
  ADD CONSTRAINT `market_offers_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `password_requests`
--
ALTER TABLE `password_requests`
  ADD CONSTRAINT `FK_password_requests_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `player_achievements`
--
ALTER TABLE `player_achievements`
  ADD CONSTRAINT `player_achievements_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `player_deaths`
--
ALTER TABLE `player_deaths`
  ADD CONSTRAINT `player_deaths_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Limitadores para a tabela `player_highscores`
--
ALTER TABLE `player_highscores`
  ADD CONSTRAINT `player_highscores_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `player_pokemon`
--
ALTER TABLE `player_pokemon`
  ADD CONSTRAINT `FK_player_pokemon_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `player_statistics`
--
ALTER TABLE `player_statistics`
  ADD CONSTRAINT `player_statistics_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `pokemon_market`
--
ALTER TABLE `pokemon_market`
  ADD CONSTRAINT `FK_pokemon_market_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `poketrader_bids`
--
ALTER TABLE `poketrader_bids`
  ADD CONSTRAINT `FK_poketrader_bids_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_poketrader_bids_poketrader_offerts` FOREIGN KEY (`offert_id`) REFERENCES `poketrader_offerts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `poll_options`
--
ALTER TABLE `poll_options`
  ADD CONSTRAINT `FK_poll_options_polls` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `poll_texts`
--
ALTER TABLE `poll_texts`
  ADD CONSTRAINT `FK_poll_texts_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_poll_texts_polls` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `poll_votes`
--
ALTER TABLE `poll_votes`
  ADD CONSTRAINT `FK_poll_votes_accounts` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_poll_votes_poll_options` FOREIGN KEY (`poll_option_id`) REFERENCES `poll_options` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_poll_votes_polls` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `rank_caught_species`
--
ALTER TABLE `rank_caught_species`
  ADD CONSTRAINT `FK_rank_caught_species_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `rank_generals`
--
ALTER TABLE `rank_generals`
  ADD CONSTRAINT `FK_rank_general_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `rank_pvps`
--
ALTER TABLE `rank_pvps`
  ADD CONSTRAINT `FK_rank_pvp_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `referral_friends`
--
ALTER TABLE `referral_friends`
  ADD CONSTRAINT `FK_referral_friends_accounts` FOREIGN KEY (`account_referral`) REFERENCES `accounts` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_referral_friends_accounts_2` FOREIGN KEY (`account_friend`) REFERENCES `accounts` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `FK_tickets_ticket_categories` FOREIGN KEY (`category_id`) REFERENCES `ticket_categories` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tournament_history_pokemon`
--
ALTER TABLE `tournament_history_pokemon`
  ADD CONSTRAINT `FK_tournament_history_pokemon_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_tournament_history_pokemon_tournament_histories` FOREIGN KEY (`tournament_history_id`) REFERENCES `tournament_histories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tournament_team_players`
--
ALTER TABLE `tournament_team_players`
  ADD CONSTRAINT `FK_tournament_team_players_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_tournament_team_players_tournament_teams` FOREIGN KEY (`team_id`) REFERENCES `tournament_teams` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tournament_weekly_winners`
--
ALTER TABLE `tournament_weekly_winners`
  ADD CONSTRAINT `FK_tournament_weekly_winners_players` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tournament_winners`
--
ALTER TABLE `tournament_winners`
  ADD CONSTRAINT `FK_tournament_winners_tournaments` FOREIGN KEY (`tournament_id`) REFERENCES `tournaments` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
