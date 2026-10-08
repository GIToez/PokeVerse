-- Default rows for the game world configured in config.lua (worldId = 1).
-- The base schema only inserts them for world 0.

INSERT INTO `server_motd` (`id`, `world_id`, `text`)
  SELECT 1, 1, 'Welcome to PokeVerse!' FROM DUAL
  WHERE NOT EXISTS (SELECT 1 FROM `server_motd` WHERE `world_id` = 1);

INSERT INTO `server_record` (`record`, `world_id`, `timestamp`)
  SELECT 0, 1, 0 FROM DUAL
  WHERE NOT EXISTS (SELECT 1 FROM `server_record` WHERE `world_id` = 1);
