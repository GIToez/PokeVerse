-- DEVELOPMENT ONLY. Never load this into a database reachable from outside 127.0.0.1.
-- Apply after database/pokeaventuras.sql and database/migrations/*.sql. Safe to re-run.
--
--   account  password  character   group
--   player   player    Trainer     1 (Player)
--   admin    admin     GM Admin    6 (God)
--
-- Passwords are SHA-1 hex digests because config.lua uses encryptionType = "sha1".
-- Characters match a fresh PokeJornadas level-8 character (the imported template
-- character's stats) and start at the configured new-player spawn
-- (newPlayerTownId/newPlayerSpawnPos* in config.lua). The dump's oncreate_players
-- trigger adds the skills and the starting inventory, exactly as for in-game creation.

INSERT INTO `accounts` (`name`, `password`, `email`, `lastday`)
SELECT 'player', SHA1('player'), 'player@localhost', 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `accounts` WHERE `name` = 'player');

INSERT INTO `accounts` (`name`, `password`, `email`, `lastday`)
SELECT 'admin', SHA1('admin'), 'admin@localhost', 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `accounts` WHERE `name` = 'admin');

INSERT INTO `players` (`name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`,
  `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `soul`, `town_id`, `posx`, `posy`, `posz`,
  `conditions`, `cap`, `sex`, `loss_experience`, `loss_mana`, `loss_skills`)
SELECT c.name, 0, c.group_id, a.id, 8, 1, 185, 185, 4200, 68, 76, 78, 58, 612, 100, 32, 3332, 806, 6, '', 470, 1, 50, 10, 10
FROM (SELECT 'Trainer' AS name, 'player' AS account, 1 AS group_id
      UNION ALL SELECT 'GM Admin', 'admin', 6) c
JOIN `accounts` a ON a.name = c.account
WHERE NOT EXISTS (SELECT 1 FROM `players` p WHERE p.name = c.name);
