-- DEVELOPMENT ONLY test accounts. Never use these on a public server.
--
--   Account "test"  / password "test"  -> character "Trainer"  (normal player)
--   Account "admin" / password "admin" -> character "Admin"    (God, group 6)

-- The base schema ships an "Account Manager" account (1/1). It is not used
-- (accountManager = false in config.lua); give it an unusable password.
UPDATE `accounts` SET `password` = '!' WHERE `id` = 1 AND `name` = '1';

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS `pokeverse_seed_dev`()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM `accounts` WHERE `name` = 'test') THEN
    CALL pokeverse_create_account('test', 'test');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM `players` WHERE `name` = 'Trainer') THEN
    CALL pokeverse_create_character('test', 'Trainer', 1);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM `accounts` WHERE `name` = 'admin') THEN
    CALL pokeverse_create_account('admin', 'admin');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM `players` WHERE `name` = 'Admin') THEN
    CALL pokeverse_create_character('admin', 'Admin', 1);
    CALL pokeverse_set_group('Admin', 6);
  END IF;
END //
DELIMITER ;

CALL pokeverse_seed_dev();
DROP PROCEDURE `pokeverse_seed_dev`;
