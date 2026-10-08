-- Creates the local development database and its user.
-- Run as the MariaDB root user. Development only: the user can connect from
-- this computer (127.0.0.1 / localhost) and nowhere else.

CREATE DATABASE IF NOT EXISTS `pokeverse` CHARACTER SET latin1 COLLATE latin1_swedish_ci;

CREATE USER IF NOT EXISTS 'pokeverse'@'127.0.0.1' IDENTIFIED BY 'pokeverse';
CREATE USER IF NOT EXISTS 'pokeverse'@'localhost' IDENTIFIED BY 'pokeverse';
GRANT ALL PRIVILEGES ON `pokeverse`.* TO 'pokeverse'@'127.0.0.1';
GRANT ALL PRIVILEGES ON `pokeverse`.* TO 'pokeverse'@'localhost';
FLUSH PRIVILEGES;
