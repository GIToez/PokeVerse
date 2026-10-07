# Database

## Source

| Item | Value |
|---|---|
| File | `database/pokeaventuras.sql` (originally `pokeaventuras (1).sql` at the archive root). Byte-identical copy: `server/runtime-data/poketibia.sql` |
| Size | 223,588 bytes |
| Producer | phpMyAdmin 5.0.1, MariaDB 10.4.11, PHP 7.4.3, dumped 2020-08-01 |
| Internal DB name | `poketibia` (but `server/runtime-data/config.lua` expects `sqlDatabase = "pokeaventuras"`) |
| Engine | MySQL/MariaDB. Mostly InnoDB, some MyISAM (`daycare_*`, `loyalty_ranks`, `paypal_items`). SQLite is compiled into the server (`__USE_SQLITE__`), but no SQLite schema is shipped. |
| Tables | **141** |
| Schema version | `server_config.db_version = 23`, `encryption = 3` (SHA-1) |
| Seed data | 56 `INSERT` statements: 2 accounts, 3 players, guild ranks, 2 houses, 1 tournament, Znote config/news/forum, sample player items/skills/pokemon. See `SECURITY_AUDIT.md` for the default `GOD` account. |

## Table groups

### Core TFS 0.3.6
`accounts`, `account_viplist`, `bans`, `environment_killers`, `global_storage`, `guilds`, `guild_invites`, `guild_ranks`, `houses`, `house_auctions`, `house_data`, `house_lists`, `killers`, `players`, `player_deaths`, `player_depotitems`, `player_items`, `player_killers`, `player_namelocks`, `player_skills`, `player_spells`, `player_storage`, `player_viplist`, `server_config`, `server_motd`, `server_record`, `server_reports`, `tiles`, `tile_items`

### Account and player extensions (custom columns)
- `accounts` adds `soulcoins` (premium currency), `display_name`, `referral`, `admin`, `referral_points`, `lang_id`, `client_id`.
- `players` adds `lasteggtime`, `pvparenafrags`, `pvparenadeaths`, `firstpokemon`, `tournament_score`, `tournament_weekly_score`, `hidden`.
- `account_storage` (key/value per account), `player_statistics`, `player_achievements` (player_id, key), `player_highscores` (player_id, score_id, value).

### Pokémon
| Table | Purpose / columns |
|---|---|
| `player_pokemon` | `player_id, slot, pokemon_number, description` (party snapshot for the website/highscores; real Pokémon data lives in pokeball **item attributes** in `player_items`/`player_depotitems`) |
| `daycare_male`, `daycare_female` | Day care / breeding slots: `pokemon_name, level, experience, energy, maxenergy, nickname, sex, extrapoints, ball_id, max_training_minutes, specialability, tm1/tm1_slot, tm2/tm2_slot, ball_seal, attributes` |
| `daycare_plates` | `player_id, item_id` |
| `egg_counter` | `player_id, pokemon_id, tries` (egg generation pity counter) |
| `ball_counter` | Per-player per-species counter for 26 ball types (poke, great, ultra, safari, … premier, quick, repeat, timer) |
| `ball_pillars` | World pillars showing a captured Pokémon (`attributes, ball_id, creature_name, creature_sex`) |
| `berry_trees` | `world_id, position, itemid, growdate` (berry farming) |
| `rank_caught_species`, `rank_generals`, `rank_pvps` | Ranking tables |

### Market / trading
| Table | Purpose |
|---|---|
| `market_offers` | Stock Tibia 9.44-style table (`id, player_id, sale, itemtype, amount, created, anonymous, price`). **Incompatible:** `server/runtime-data/data/lib/game_market.lua` queries a custom `market_offers` with `item_code`, `playeroffer_id`, `item_index`, `attributes` columns, none of which exist in the dump. |
| `market_history` | Stock Tibia 9.44-style table. Not referenced by any server Lua or C++. |
| **`market_items`** | **Missing.** The custom market's listings table. `game_market.lua` inserts `item_code, playerseller_id, playerseller_name, onlyoffer, itemid, count, price, attributes, time` and joins it with `players`. |
| `pokemon_market` | Pokémon market listings (`pokemon_name, level, extrapoints, sex, specialability, ball_id, attributes, value, pokemon_eggmove`) |
| `poketrader_offerts`, `poketrader_bids` | Auction ("PokéTrader") with min bid and deadline |
| `datalog_pokemon_market`, `datalog_poketrader_boughts` | Logs |
| **`market_historic`** | **Missing.** Used by `server/runtime-data/data/lib/game_market.lua` (per-player JSON history). |

### Dungeons
- **`dungeon_ranking`** is **missing**. It is used by `server/runtime-data/data/lib/game_dungeon.lua` (`ranking` JSON, `diff`, `mapId`). Dungeon progress otherwise uses storages.

### Battle pass, daily rewards, tasks, achievements
- No dedicated tables. These systems use `player_storage` / `account_storage` / `global_storage` (see `FEATURES.md`). `datalog_*` tables log some of the results.

### Tournaments and PvP
`tournaments`, `tournament_bans`, `tournament_histories`, `tournament_history_pokemon`, `tournament_inscriptions`, `tournament_teams`, `tournament_team_players`, `tournament_weekly_winners`, `tournament_winners`, `elite_four_champions`, `elite_four_champion_pokemons`, `datalog_colosseum_arena`, `datalog_duel_bet`

### Shop, currency, payments
| Table | Notes |
|---|---|
| `accounts.soulcoins` | Account-level premium currency column |
| `donates` | `account_id, value, ref, date` |
| `coupons`, `coupon_uses` | Redeemable codes (`type, reward, expires, code`) |
| `instant_payment_notifications`, `paypal_items` | PayPal IPN storage (website side) |
| `znote_shop`, `znote_shop_logs`, `znote_shop_orders`, `znote_paypal`, `znote_paygol` | Znote AAC shop and payments |
| `datalog_coin_uses`, `datalog_token_bought`, `datalog_mastery_token_bought`, `datalog_casino_token_bought`, `datalog_bank_transactions` | Spending logs |
| **`z_ots_comunication`, `z_shop_history`** | **Missing.** Needed by `globalevents/scripts/gesior-shop-system.lua` (Gesior shop delivery) |

### Datalog (analytics)
`datalog_anniversary_drops, datalog_bank_transactions, datalog_boss_rewards, datalog_boss_spawns, datalog_casino_token_bought, datalog_caughts, datalog_christmas_drops, datalog_coin_uses, datalog_colosseum_arena, datalog_duel_bet, datalog_easter_drops, datalog_egg_generate, datalog_egg_move_generate, datalog_egg_move_regenerate, datalog_halloween_drops, datalog_julyvacation_drops, datalog_logins, datalog_map_items, datalog_mastery_token_bought, datalog_online, datalog_player_items, datalog_player_ups, datalog_pokemon_market, datalog_pokemon_ups, datalog_poketrader_boughts, datalog_poke_nick_change, datalog_rangerclub_boss, datalog_rangerclub_boss_rewards, datalog_rangerclub_task, datalog_referral_exchange, datalog_slot_machine, datalog_surprise_box, datalog_token_bought`. Written from C++ `iodatalog.cpp` and Lua `lib/ps/systems/025-datalog.lua`. **`datalog_ping` is missing** (used by `iodatalog.cpp`).

### Polls, tickets, referral, misc
`polls, poll_options, poll_texts, poll_votes` (in-game poll window), `tickets, ticket_categories, ticket_messages`, `referral_friends`, `loyalty_ranks`, `parcels`, `password_requests`, `change_emails`, `delete_players`, `guild_loves`, `servers`

### Website (code not included)
- **Znote AAC:** `znote, znote_accounts, znote_auction_player, znote_changelog, znote_deleted_characters, znote_forum, znote_forum_posts, znote_forum_threads, znote_global_storage, znote_guild_wars, znote_images, znote_news, znote_paygol, znote_paypal, znote_players, znote_player_reports, znote_shop, znote_shop_logs, znote_shop_orders, znote_tickets, znote_tickets_replies, znote_visitors, znote_visitors_details`
- **Blog (custom, Laravel-style naming):** `blog_posts, blog_post_categories, blog_post_categories_blog_posts, blog_post_comments, blog_post_loves`

## Requested table categories, at a glance

| Category | Present? | Where |
|---|---|---|
| Account | Yes | `accounts`, `account_storage`, `account_viplist`, `znote_accounts` |
| Player | Yes | `players` + `player_*` |
| Pokémon | Yes (partial) | `player_pokemon`, `daycare_*`, `egg_counter`, `ball_counter`, `pokemon_market`. Core Pokémon data is item attributes. |
| Market | Yes, but the custom market's history table is missing | `pokemon_market`, `poketrader_*`, `market_history` (unused); **`market_items` and `market_historic` missing; `market_offers` has the wrong columns** |
| Shop | Yes (website-side) | `znote_shop*`, `donates`, `coupons`, `accounts.soulcoins` |
| Dungeon | **Missing** | `dungeon_ranking` not in dump |
| Battle pass | No table | storages |
| Achievement | Yes | `player_achievements` |

## Gaps to fix before first run

1. Create `market_items (item_code, playerseller_id, playerseller_name, onlyoffer, itemid, count, price, attributes, time)`, replace `market_offers` with the custom layout (`item_code, playeroffer_id, item_index, attributes, …`), and create `market_historic (player_id INT PRIMARY KEY, historic TEXT)`, `dungeon_ranking (diff INT, mapId INT, ranking TEXT)`, `player_stored_items (player_id, item_type, count, attributes)`, `datalog_ping (player_id, date, ping)`. The column lists are inferred from the queries and need verifying.
2. Decide whether the Gesior shop script is used. If not, disable `gesior-shop-system.lua`. If it is, add `z_ots_comunication` / `z_shop_history`.
3. Align the database name (`poketibia` vs `pokeaventuras`).
4. Remove or replace the seeded `GOD`/`Canibal` accounts.
