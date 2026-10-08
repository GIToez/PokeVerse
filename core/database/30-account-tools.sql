-- Development helpers for creating accounts and characters without a website.
--
--   CALL pokeverse_create_account('name', 'password');
--   CALL pokeverse_create_character('account name', 'Character Name', sex);   -- sex: 0 female, 1 male
--   CALL pokeverse_set_group('Character Name', group_id);                     -- see data/XML/groups.xml
--
-- New characters use the same start values as config.lua (newPlayer* settings):
-- town 3 at 3307, 300, 7, level 1, vocation 1 (Trainer), world 1.

DROP PROCEDURE IF EXISTS `pokeverse_create_account`;
DROP PROCEDURE IF EXISTS `pokeverse_create_character`;
DROP PROCEDURE IF EXISTS `pokeverse_set_group`;

DELIMITER //

CREATE PROCEDURE `pokeverse_create_account`(IN p_name VARCHAR(32), IN p_password VARCHAR(255))
BEGIN
  IF CHAR_LENGTH(p_name) < 3 OR CHAR_LENGTH(p_password) < 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account name and password must be at least 3 characters.';
  END IF;
  IF EXISTS (SELECT 1 FROM `accounts` WHERE `name` = p_name) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'An account with that name already exists.';
  END IF;
  INSERT INTO `accounts` (`name`, `password`, `premdays`, `lastday`, `email`, `key`, `blocked`, `warnings`, `group_id`)
    VALUES (p_name, SHA2(p_password, 256), 0, 0, '', '0', 0, 0, 1);
  SELECT CONCAT('Account created: ', p_name) AS `result`;
END //

CREATE PROCEDURE `pokeverse_create_character`(IN p_account VARCHAR(32), IN p_name VARCHAR(255), IN p_sex TINYINT)
BEGIN
  DECLARE v_account INT;
  DECLARE v_player INT;
  SELECT `id` INTO v_account FROM `accounts` WHERE `name` = p_account LIMIT 1;
  IF v_account IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account not found.';
  END IF;
  IF p_name NOT REGEXP '^[A-Za-z][A-Za-z ]{1,28}[A-Za-z]$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Character names must be 3-30 letters and spaces.';
  END IF;
  IF EXISTS (SELECT 1 FROM `players` WHERE `name` = p_name) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A character with that name already exists.';
  END IF;
  IF p_sex NOT IN (0, 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sex must be 0 (female) or 1 (male).';
  END IF;
  INSERT INTO `players` (`name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`,
      `experience`, `looktype`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `description`)
    VALUES (p_name, 1, 1, v_account, 1, 1, 150, 150,
      0, IF(p_sex = 0, 611, 612), 3, 3307, 300, 7, '', 400, p_sex, '');
  SET v_player = LAST_INSERT_ID();
  -- Starting kit. The original website template is not available; these items are
  -- what data/creaturescripts/scripts/login.lua and npc/scripts/professorTommy.lua
  -- expect a new character to carry. Slot ids: 6 = left hand (Pokedex), 3 = backpack.
  INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES
    (v_player, 6, 101, 12281, 1, ''),   -- Kanto Pokedex
    (v_player, 3, 102, 13499, 1, ''),   -- locked backpack
    (v_player, 102, 103, 13492, 1, ''), -- empty soul ball
    (v_player, 102, 104, 13497, 1, ''), -- special small stone
    (v_player, 102, 105, 13820, 20, ''); -- starter cookies
  SELECT CONCAT('Character created: ', p_name) AS `result`;
END //

CREATE PROCEDURE `pokeverse_set_group`(IN p_name VARCHAR(255), IN p_group INT)
BEGIN
  UPDATE `players` SET `group_id` = p_group WHERE `name` = p_name;
  UPDATE `accounts` a JOIN `players` p ON p.`account_id` = a.`id`
    SET a.`group_id` = GREATEST(a.`group_id`, p_group) WHERE p.`name` = p_name;
END //

DELIMITER ;
