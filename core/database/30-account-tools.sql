-- Development helpers for creating accounts and characters without a website.
--
--   CALL pokeverse_create_account('name', 'password');
--   CALL pokeverse_create_character('account name', 'Character Name', sex);   -- sex: 0 female, 1 male
--   CALL pokeverse_set_group('Character Name', group_id);                     -- see data/XML/groups.xml
--
-- pokeverse_add_character(account id, name, sex) inserts a character and its starting kit
-- without any checks or result rows. The game server's account service (create character
-- from the client) validates the input itself and then calls it.
--
-- New characters use the same start values as config.lua (newPlayer* settings):
-- Tutorial (town 34) at 5000, 806, 6, the bedroom where Red's guided tutorial starts (Professor Oak's
-- starter Pokemon, first battle, PokeMart, then Red lets the player pick a starting city).
-- Level 1, vocation 1 (Trainer), world 1; login.lua raises level 1 characters outside town 10 to level 5
-- on their first login.

DROP PROCEDURE IF EXISTS `pokeverse_create_account`;
DROP PROCEDURE IF EXISTS `pokeverse_create_character`;
DROP PROCEDURE IF EXISTS `pokeverse_add_character`;
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

CREATE PROCEDURE `pokeverse_add_character`(IN p_account_id INT, IN p_name VARCHAR(255), IN p_sex TINYINT)
BEGIN
  DECLARE v_player INT;
  INSERT INTO `players` (`name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`,
      `experience`, `looktype`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `description`)
    VALUES (p_name, 1, 1, p_account_id, 1, 1, 150, 150,
      0, IF(p_sex = 0, 611, 612), 34, 5000, 806, 6, '', 400, p_sex, '');
  SET v_player = LAST_INSERT_ID();
  -- Starting kit; Professor Oak adds the starter Pokemon and the main items (doPlayerAddMainItems).
  -- Slot ids follow PLAYER_SLOT_* in data/lib/ps/others/constants.lua; the bag goes to slot 10
  -- because the client hides the regular backpack slot 3 (used for the duel icon).
  -- pid = slot id for equipped items, or the sid of the parent container. Container items are
  -- shown lowest sid first.
  INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES
    (v_player, 1, 101, 13206, 1, ''),   -- order icon (off)
    (v_player, 2, 102, 13204, 1, ''),   -- evolve icon, used by the client's "Evolve" menu entry
    (v_player, 3, 103, 13016, 1, ''),   -- duel icon, written to for duels with bets
    (v_player, 5, 104, 12280, 1, ''),   -- Kanto badge case
    (v_player, 6, 105, 12281, 1, ''),   -- Kanto Pokedex
    (v_player, 10, 106, 12282, 1, ''),  -- simple pokebag
    (v_player, 106, 107, 13820, 20, ''), -- starter cookies
    -- Empty badge slots; gym leaders transform them into badges (001-npcBattle.lua). A full
    -- case also keeps new items from being placed in it instead of the bag.
    (v_player, 104, 108, 12214, 1, ''), -- Boulder
    (v_player, 104, 109, 12216, 1, ''), -- Cascade
    (v_player, 104, 110, 12218, 1, ''), -- Thunder
    (v_player, 104, 111, 12220, 1, ''), -- Rainbow
    (v_player, 104, 112, 12222, 1, ''), -- Soul
    (v_player, 104, 113, 12224, 1, ''), -- Marsh
    (v_player, 104, 114, 12226, 1, ''), -- Volcano
    (v_player, 104, 115, 12228, 1, ''); -- Earth
END //

CREATE PROCEDURE `pokeverse_create_character`(IN p_account VARCHAR(32), IN p_name VARCHAR(255), IN p_sex TINYINT)
BEGIN
  DECLARE v_account INT;
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
  CALL pokeverse_add_character(v_account, p_name, p_sex);
  SELECT CONCAT('Character created: ', p_name) AS `result`;
END //

CREATE PROCEDURE `pokeverse_set_group`(IN p_name VARCHAR(255), IN p_group INT)
BEGIN
  UPDATE `players` SET `group_id` = p_group WHERE `name` = p_name;
  UPDATE `accounts` a JOIN `players` p ON p.`account_id` = a.`id`
    SET a.`group_id` = GREATEST(a.`group_id`, p_group) WHERE p.`name` = p_name;
END //

DELIMITER ;
