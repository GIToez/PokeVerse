# Redemption ↔ PokeVerse Server: Network Protocol Compatibility

This audit compares three things:

- **Server**: the PokeVerse server (`server/source/`, a PSoul fork of TFS 0.3/0.4 for 8.54/8.6).
- **Legacy**: the legacy PokeVerse client (`client/source/`, `client/runtime-data/`, a modified OTClient 0.6.6).
- **Redemption**: the imported OTClient Redemption (`client-redemption/`, upstream commit `396f0b39`, see `docs/REDEMPTION_BASELINE.md:9`).

All findings come from reading the source and parsing asset headers offline. I did not run any binary, connect to a live server, or capture any packets. Anything the code alone cannot settle is marked **UNVERIFIED**, along with what would settle it.

Throughout, `S→C` means server to client and `C→S` means client to server.

---

## 1. Summary verdict

**Unmodified, Redemption cannot log in.**

The login packet is wrong. The server always reads one extra language byte from any client that reports an OTClient OS, and Redemption reports one. Without that byte, the RSA block lands at the wrong offset and the server drops the connection:

- the server reads the extra byte at `server/source/protocollogin.cpp:86-89`;
- the server's RSA size check is `server/source/protocol.cpp:200-204`;
- Redemption reports an OTClient OS at `client-redemption/src/client/game.cpp:1788-1799`.

The same fix also unblocks the character list. The server adds PokeVerse fields to it (`protocollogin.cpp:470-505`), and Redemption parses it as stock 8.54 (`client-redemption/modules/gamelib/protocollogin.lua:232-262`). Both fixes are Lua-only.

**After login, entering the game breaks on the first packet** for six independent reasons. Each one desynchronises the byte stream:

1. **Login packet (0x0A).** It carries an extra `u16 lightHour`.
2. **Item counts.** They are `u16`.
3. **Creatures.** Every creature carries 10 extra PokeVerse bytes.
4. **Inventory and container items.** They carry a `pname/level/gender` trailer.
5. **Map size.** The map window is 32×28, but Redemption expects 18×14.
6. **Sprites.** They have an alpha channel, and Redemption does not read `.otfi`.

Two of these are pure feature flags that Redemption already supports: `GameCountU16` and `GameSpritesAlphaChannel`. The map size is a config value (`viewport`). The other three need small C++ changes in `protocolgameparse.cpp`.

**The PokeVerse UI modules then need four more things:**

- the `0xFF` PSoul sub-protocol, which can be done entirely in Lua through `ProtocolGame.registerOpcode(255, …)`;
- extended-opcode sending to be unlocked, because the server never sends ext-opcode 0;
- the channel-list count to be read as `u16`;
- the poll packets `0xFA`/`0xFB`, which can be done in Lua through `Protocol:send`.

**Recommendation: change Redemption, not the server.**

- Every incompatibility is a deterministic format difference that the legacy client already handles.
- Redemption has a feature or hook for most of them.
- No server change is needed.
- Thing IDs, `Tibia.dat`, and `Tibia.spr` can be used byte-for-byte as they are. `Tibia.dat` parses cleanly with Redemption's existing 7.80–8.54 rules (§10).

Two server-side one-liners are offered only as optional alternatives (§8, §11).

The protocol mode should be **clientVersion = protocolVersion = 854** in Redemption. Do not copy the legacy client's nominal clientVersion of 1041: in Redemption, clientVersion drives all feature gating, and 1041 would switch on many incompatible features (§2).

---

## 2. Versions

| Item | Value | Evidence |
|---|---|---|
| Server accepted login `version` field | 312–1343, checked **only** in the login protocol | `server/source/resources.h:79-81`, `server/source/protocollogin.cpp:323-327` |
| Server game-protocol version check | Disabled (commented out) | `server/source/protocolgame.cpp:488-492` |
| Server OS constants | OTClient Win/Linux/Mac = 0x0A/0x0B/0x0C; `isUsingOtclient()` ⇔ `os >= 10` | `server/source/enums.h:58-63`, `server/source/player.cpp:5502-5505` |
| Legacy protocolVersion | 854 | `client/runtime-data/modules/client_entergame/entergame.lua:194-240` |
| Legacy clientVersion | 1041 (nominal). `getSupportedClients` ignores its argument and returns a list whose last entry is 1041 | `client/runtime-data/modules/gamelib/game.lua:49-60` |
| Legacy version field on the wire | Hard-coded `312` in both the login and game packets | `client/runtime-data/modules/gamelib/protocollogin.lua:224`, `client/source/src/client/protocolgamesend.cpp:51-112` |
| Legacy OS sent | 10 (Win) / 11 (Linux) / 12 (Mac) | `client/source/src/client/game.cpp:1811-1822` |
| Legacy feature source | Keyed on **protocolVersion** (C++ `setProtocolVersion`) | `client/source/src/client/game.cpp:1617-1749` |
| Redemption feature source | Keyed on **clientVersion** (Lua `onClientVersionChange`) | `client-redemption/modules/game_features/features.lua:3-295`, `client-redemption/src/client/game.cpp:1722-1738` |
| Redemption accepted versions | 740…last supported; 854 is in `supportedClients` | `client-redemption/src/client/game.cpp:1712,1730`, `client-redemption/modules/gamelib/game.lua:54-71` |
| Redemption version field on the wire | `g_game.getProtocolVersion()` (854), which is inside 312–1343, so it is accepted | `client-redemption/modules/gamelib/protocollogin.lua:42`, `client-redemption/src/client/protocolgamesend.cpp:56` |
| Redemption OS sent | Linux=10, Windows=11, Mac=12. All three are inside the server's 10–12 window; only the naming differs | `client-redemption/src/client/const.h:27-33`, `client-redemption/src/client/game.cpp:1788-1799` |

**Why 1041 must not be used in Redemption.** At clientVersion ≥ 980 Redemption enables `GameClientVersion` and `GamePreviewState`. At ≥ 981 it enables `GameLoginPending` and `GameNewSpeedLaw`. At ≥ 984 it enables `GameContainerPagination`. At ≥ 1000 it enables `GameThingMarks`. At ≥ 1036 it enables `GameCreatureIcons`. And so on (`features.lua:106-134`). Each of these adds wire fields that this server never sends or reads. Set clientVersion and protocolVersion to **854**, then enable the extra features listed in §9 explicitly.

---

## 3. Login protocol (port 7564)

Config: `ip = 127.0.0.1`, `loginPort = 7564`, `gamePort = 8548` (`server/runtime-data/config.lua:89-94`). Redemption's default port is 7171 (`client-redemption/modules/client_entergame/entergame.lua:189-190`), so it must be pointed at 7564 through `init.lua` `Servers_init` or the login UI.

### 3.1 C→S login packet (after the 2-byte length and 4-byte Adler-32)

| # | Server expects (`protocollogin.cpp:83-99,310`) | Legacy sends (`protocollogin.lua:222-268`) | Redemption sends (`client-redemption/modules/gamelib/protocollogin.lua:37-96`) |
|---|---|---|---|
| 1 | u8 opcode 0x01 (consumed by the dispatcher) | 0x01 | 0x01 |
| 2 | u16 os | `getOs()` = 10/11/12 | `getOs()` = 10/11/12 |
| 3 | u16 version | **312** | **854** (accepted) |
| 4 | **u8 lang**, only if `os ∈ [10,12]` and `version ≥ 293` (`:86-89`) | `u8 locale.id` (`:225`) | **missing** ← *breaks login* |
| 5 | skip 12 bytes (dat/spr/pic signatures, never checked) (`:91`) | u32 dat sig, u32 spr sig, u32 `PIC_SIGNATURE` | same 12 bytes (`:52-55`). `GameClientVersion`, `GameContentRevision`, and `GamePreviewState` are off at 854, so nothing extra is sent |
| 6 | **exactly 128 bytes** RSA (`protocol.cpp:200-211`); the first plaintext byte must be 0 | RSA(0, 4×u32 XTEA, string account, string password, zero padding) | RSA(0, 4×u32 XTEA, string account, string password, random padding) (`:62-96`). `GameLoginPacketEncryption` and `GameAccountNames` are on at ≥770 and ≥840 |
| 7 | — | — | No OGL info and no authenticator block at 854 (`:98-129`) |

**What goes wrong.** Without item 4, the server takes the first byte of the dat signature as `lang`. It then skips 12 bytes, which eats 1 byte of the RSA block, so `getMessageLength()-readPos` is 127, not 128. The server prints "Not valid packet size" and closes the connection.

**Fix (Lua only).** In `client-redemption/modules/gamelib/protocollogin.lua`, insert `msg:addU8(<lang id>)` right after `msg:addU16(g_game.getProtocolVersion())` (line 42). Use 0, or a locale id compatible with the legacy client.

Also:

- Do **not** set `self.getLoginExtendedData`. It would add a string inside the RSA block. That would still fit in 128 bytes, but the server ignores it.
- Random padding is harmless, because the server reads only up to the password.

### 3.2 S→C login response (XTEA-encrypted, Adler-32 always present)

Server (`protocollogin.cpp:420-512`; error responses via `disconnectClient(0x0A, …)`):

```
[0x14] string motd "<id>\n<text>"            (optional)
[0x64] u8 charCount
       per character:
         string name
         string world   (or "Online"/"Offline" if displayOnOrOffAtCharlist)
         u32 ip
         u16 port
         if os ∈ [10,12]:                       ← PokeVerse/OTClient extension
           u16 level
           u8 vocation
           u16 lookType
           u8 head, u8 body, u8 legs, u8 feet, u8 addons
           u8 pokemonCount
           pokemonCount × { u16 number, string description }
       u16 premiumDays (65535 = free premium)
       if os ∈ [10,12]: u8 pollAvailable          ← PokeVerse extension
[0x0A] string error                             (on failure)
```

- **Legacy** parses all of this (`client/runtime-data/modules/gamelib/protocollogin.lua:323-387`). It feeds the poll flag to `modules.game_poll.doPreparePollIconShow`.
- **Redemption** handles opcodes 0x0A, 0x14, and 0x64 (`client-redemption/modules/gamelib/protocollogin.lua:156-186`). For clientVersion ≤ 1010, `parseCharacterList` reads only name, world, ip, and port per character, then `u16 premDays` (`:232-262`). The first character's `u16 level` is therefore read as the next character's name length, and the stream is lost. A trailing poll byte would also be read as a new opcode, which falls through to `parseOpcode` (`:181-182`).

**Fix (Lua only).** Override `ProtocolLogin:parseCharacterList` with a port of the legacy parser. Read the extra per-character fields, then `u16 premDays`, then `u8 poll`. Carry `level`, `vocation`, `outfit`, and `pokemonTeam` into the character table so the PokeVerse character-select UI can use them. If no poll module exists yet, consume the poll byte and discard it.

---

## 4. Game protocol (port 8548)

### 4.1 Framing, checksum, XTEA

| Aspect | Server | Redemption | Status |
|---|---|---|---|
| Outer header | u16 length, then u32 Adler-32 if checksum is enabled (`server/source/outputmessage.h:49-52`, `protocol.cpp:33-56`) | Reads u16, then 4 bytes of checksum if enabled (`client-redemption/src/framework/net/protocol.cpp:184-193`) | ✔ |
| Checksum S→C | Always on. Login: `protocollogin.h:35`. Game: enabled in `onConnect`, `protocolgame.cpp:443` | Enabled before the first recv when `GameProtocolChecksum` is on (≥840) (`client-redemption/src/client/protocolgame.cpp:52-53`). Verified strictly (`framework/net/protocol.cpp:239-249`) | ✔ |
| Checksum C→S | Auto-detected per packet: if Adler matches, skip 4 bytes (`server/source/connection.cpp:396-405`) | Always written when enabled (`framework/net/protocol.cpp:144-149`) | ✔ |
| Sequence numbers | None | Only with `GameSequencedPackets` (≥1290) | ✔ (off) |
| Inner length | Always written (`OutputMessage::writeMessageLength`, `protocol.cpp:39`) | Read inside XTEA decrypt (`framework/net/protocol.cpp:373`). For the first, unencrypted packet it is read by `GameMessageSizeCheck` (`client-redemption/src/client/protocolgame.cpp:66-78`) | ✔ The challenge arrives as `[len][adler][u16 6][0x1F …]`, so the size check passes |
| XTEA | 32 rounds, delta `0x61C88647` with subtraction (same as `0x9E3779B9`), little-endian words (`server/source/protocol.cpp:110-191`). Decrypt requires `(len-6)%8==0` | 32 rounds, delta `0x9E3779B9`, 8-byte padding (`framework/net/protocol.cpp:328-406`) | ✔ Standard TFS/OTC XTEA. **UNVERIFIED** at runtime; a successful login capture would confirm it |
| Compression | None | Only with sequenced packets | ✔ |

### 4.2 First server packet (challenge)

The server sends `0x1F, u16 random, u16 0x0000, u8 random` (`server/source/protocolgame.cpp:438-452`). That is 5 bytes, the same size as stock `u32 timestamp, u8 random`.

Redemption's `parseLoginChallenge` reads `u32, u8` and replies with the login packet (`client-redemption/src/client/protocolgameparse.cpp:1394-1404`). `GameChallengeOnLogin` is on at ≥841. ✔

### 4.3 C→S game login packet

| # | Server (`protocolgame.cpp:471-487`) | Legacy (`client/source/src/client/protocolgamesend.cpp:51-112`) | Redemption (`client-redemption/src/client/protocolgamesend.cpp:50-134`) |
|---|---|---|---|
| 1 | u8 0x0A (dispatcher) | 0x0A | `ClientPendingGame` = 10 ✔ |
| 2 | u16 os | os | os ✔ |
| 3 | u16 version (ignored) | 312 | 854 ✔ |
| 4 | — (**no** lang byte here) | — | `GameClientVersion`, `GameContentRevision`, `GamePreviewState` all off at 854 ✔ |
| 5 | RSA, exactly 128 bytes | RSA | RSA ✔ |
| 5a | u8 0, then 4×u32 XTEA | same | same ✔ |
| 5b | u8 gamemaster | u8 0 | u8 0 ✔ |
| 5c | string account, string character, string password | same | same (`GameSessionKey` off) ✔ |
| 5d | skip 6 bytes (`:487`) | u32 ts, u8 rnd | u32 ts, u8 rnd (`:106-109`) ✔ |
| 5e | — | — | Optional `getLoginExtendedData` string (`:111-113`). Leave it unset; it would be ignored anyway ✔ |

The game login is compatible as-is.

Server failure replies are `0x14` with a string (`disconnectClient`, e.g. `protocolgame.cpp:498-544`) and `0x16` with a string and u8 (wait list, `:276`). Redemption maps these to `GameServerLoginError` = 20 and `GameServerLoginWait` = 22 (`client-redemption/src/client/protocolcodes.h:53-55`, `protocolgameparse.cpp:1362-1383`). ✔

### 4.4 Login success packet 0x0A, then initial state

Server (`protocolgame.cpp:2815-2845`):

```
0x0A
  u32 playerId
  u16 0x0032 (beat)
  u8 canReportBugs
  if OTClient: u16 realLightHour          ← extension
[0x0B 20 × u8]                            (GM actions, only if group violation reasons > 1)
0x64 map description …
0x78 × inventory …
0xA0 stats, 0xA1 skills, 0x82 world light, 0x8D creature light, 0xA2 icons, 0xD2 VIPs …
```

- **Legacy** always reads `u16 lightHour` and calls `g_game.onLightHour` (`client/source/src/client/protocolgameparse.cpp:482-502`). That feeds the `game_time` module (`client/runtime-data/modules/game_time/time.lua:113-142`).
- **Redemption** `parseLogin` reads `u32`, `u16`, then `u8` (`GameDynamicBugReporter` is off). Nothing else is read at 854 (`client-redemption/src/client/protocolgameparse.cpp:728-776`). The 2 light-hour bytes are then parsed as an opcode. For example, hour 500 is `F4 01`, so it would parse as opcode 0xF4 `ItemInfo`. This throws or desyncs, and the whole first game packet, including the map, is lost.

**Fix (C++).** In `parseLogin`, read a `u16` when a PokeVerse feature is on and forward it with `g_lua.callGlobalField("g_game", "onLightHour", h)`. §11 suggests adding a feature called `GamePokeVerse`.

The GM-actions packet `0x0B` is 20 bytes at ≥850 in Redemption (`protocolgameparse.cpp:1332-1354`), which matches the server. ✔

---

## 5. RSA

| Item | Value | Evidence |
|---|---|---|
| Server private key | Hard-coded OTServ primes p and q. I verified earlier that p×q equals the OTServ modulus | `server/source/otserv.cpp:678-681` |
| Legacy public key | `OTSERV_RSA`, selected by `chooseRsa` | `client/runtime-data/modules/gamelib/game.lua:21-37,77` |
| Redemption public key | `OTSERV_RSA`, the identical string | `client-redemption/modules/gamelib/const.lua:314-318`, `client-redemption/modules/gamelib/game.lua:19-46,107` |
| Block size | 128 bytes (1024-bit) on both sides | `server/source/protocol.cpp:200-206`; Redemption pads to `g_crypt.rsaGetSize()` (`protocollogin.lua:88`, `protocolgamesend.cpp:116`) |

**RSA is compatible with no change.** The only RSA failure mode is the login-packet offset issue in §3.1.

---

## 6. Server→client opcode table

Column meanings:

- **Legacy**: whether the legacy client parses the opcode correctly.
- **Redemption @854**: what unmodified Redemption does with clientVersion = protocolVersion = 854 and the stock `features.lua`.

"Change" says what Redemption needs. Redemption line numbers refer to `client-redemption/src/client/protocolgameparse.cpp` unless stated otherwise.

**Unknown-opcode behaviour.** Redemption logs the opcode and **skips the rest of the message** (`:664-684`). Exceptions inside a parser are caught at `:688-725`, and the rest of that message is dropped. Desync is therefore contained to one message, but anything after the bad byte in that message is lost.

| Op | Name | Server format (file:line) / PokeVerse delta | Legacy | Redemption @854 | Change |
|---|---|---|---|---|---|
| 0x0A | Login | §4.4; **+u16 lightHour** (`protocolgame.cpp:2815-2823`) | ✔ `:482-502` | ✘ `:728-776` | **C++**: read u16 and forward to Lua |
| 0x0B | GM actions | 20×u8 (`:2829-2840`) | ✔ | ✔ `:1332-1354` | — |
| 0x14 | Login error | string | ✔ | ✔ `:1362-1369` | — |
| 0x15 | FYI box | string (`:2698-2699`) | ✔ | ⚠ dispatched as `LoginAdvice`, which reads a string (`:1371-1375`) | Optional: route to a message box |
| 0x16 | Wait list | string, u8 (`:276`) | ✔ | ✔ `:1377-1383` | — |
| 0x1E | Ping | empty (`:2602`) | ✔ | ✔ `parsePing` replies with 0x1E (`:120-128`); `GameClientPing` is off | — |
| 0x1F | Challenge | §4.2 | ✔ | ✔ `:1394-1404` | — |
| 0x28 | Re-login window | empty (`:2020`) | ✔ | ⚠ dispatched as `Death`; reads nothing at 854 (`:1406-1424`), so the death window shows | Usually what is wanted |
| 0x32 | Extended opcode | u8 op, string (`:1834-1848`) | ✔ | ✔ parse `:3817-3829` | See §8 (sending is locked) |
| 0x64 | Full map | pos, then tiles for 32×28×floors (`Map::maxClientViewportX/Y=15/13`, `server/source/map.h:160-163`) | ✔ (aware range 15/13/16/14, `client/source/src/client/map.cpp:659-667`) | ✘ aware range is `viewport` 8×6, i.e. 18×14 (`client-redemption/data/setup.otml:7`, `client-redemption/src/client/map.cpp:844-850`) | **Config**: `viewport: 15 13` |
| 0x65–0x68 | Map scroll | rows and columns sized by the aware range | ✔ | ✘ same as above (`:1477-1515`) | same |
| 0x69 | Update tile | pos, tile, `00 FF` / `01 FF` (`:2773-2785`) | ✔ | ✔ `:1517-1521` | — |
| 0x6A | Add thing | pos, **u8 stackpos**, thing (`:4567-4580`) | ✔ | ✔ `GameTileAddThingWithStackpos` is on at ≥841 (`:1523-1530`) | — |
| 0x6B | Transform / turn | pos, stackpos, item **or** `u16 0x63, u32 id, u8 dir` (`:2481-2486, 4593-4596`) | ✔ | ✔ turn: no unpass byte below 953 (`:4303-4322`) | — |
| 0x6C | Remove thing | pos, stackpos (`:4604-4606`) | ✔ | ✔ | — |
| 0x6D | Move creature | oldPos, oldStack, newPos (`:2947-2950`) | ✔ | ✔ `:1565-1584` | — |
| 0x6E | Open container | u8 cid, u16 itemId, string name, u8 cap, u8 hasParent, u8 n, then n × [AddItem **+ string pname [+ u32 level, u32 gender if pname≠"none"]**] (`:2260-2308`) | ✔ `:752-786` | ✘ reads only items (`:1586-1633`) | **C++**: read the pname trailer per item |
| 0x6F | Close container | u8 | ✔ | ✔ | — |
| 0x70 | Container add | u8 cid, AddItem **+ pname trailer** (`:4741-4765`) | ✔ | ✘ `:1641-1648` | **C++** |
| 0x71 | Container update | u8 cid, u8 slot, AddItem **+ pname trailer** (`:4767-…`) | ✔ | ✘ `:1650-1657` | **C++** |
| 0x72 | Container remove | u8 cid, u8 slot | ✔ | ✔ `:1659-1677` (no pagination) | — |
| 0x78 | Inventory set | u8 slot, AddItem **+ pname trailer** (`:4690-4716`) | ✔ | ✘ `:1787-1793` | **C++** |
| 0x79 | Inventory clear | u8 slot | ✔ | ✔ | — |
| 0x7A | NPC shop | u8 n; n × [u16 clientId, u8 subtype, string name, u32 weight, u32 buy, u32 sell] (`:4825-4840`) | ✔ | ✔ u8 count below 900 (`:1801-1835`) | — |
| 0x7B | Player goods | u32 money, u8 n, n × [u16 id, u8 count] | ✔ | ✔ `:1837-1861` | — |
| 0x7C | Close shop | empty | ✔ | ✔ | — |
| 0x7D/0x7E | Trade own/counter | string, u8 n, n × AddItem (u16 counts) | ✔ | ✔ once `GameCountU16` is on (`:1865-1893`) | Flag |
| 0x7F | Close trade | empty | ✔ | ✔ | — |
| 0x82 | World light | u8, u8 (`:4546`) | ✔ | ✔ `:1897-1909` | — |
| 0x83 | Magic effect | pos, **u16 type+1** (`:4281-4286`) | ✔ (`GameMagicEffectU16`) | ✘ reads u8 (`:1992`) | **Flag** `GameMagicEffectU16` |
| 0x84 | Animated text | pos, u8 color, string | ✔ | ✔ below 1320 (`:2030-2037`) | — |
| 0x85 | Missile | pos, pos, u8 | ✔ | ✔ `GameDistanceEffectU16` off (`:2047-2063`) | — |
| 0x86 | Creature square | u32 id, u8 color (`:1975-1977`) | ✔ | ✔ `parseCreatureMark` below 1281 (`:2194-2206`) | — |
| 0x8C | Creature health | u32, u8 | ✔ | ✔ | — |
| 0x8D | Creature light | u32, u8, u8 | ✔ | ✔ | — |
| 0x8E | Creature outfit | u32, outfit (u16 lookType + 5 bytes, or u16 lookTypeEx; **no mount**) | ✔ | ✔ `GamePlayerMounts` is off at 854 (`:3970-4035`) | — |
| 0x8F | Creature speed | u32, u16 | ✔ | ✔ no base speed below 1059 (`:2438-2454`) | — |
| 0x90 | Skull | u32, u8 (`:1954`) | ✔ | ✔ | — |
| 0x91 | Shield | u32, u8 (`:1933`) | ✔ | ✔ | — |
| 0x96 | Edit text | u32 id, u16 itemId, u16 maxLen, string text, string writer, string date | ✔ | ✔ `GameWritableDate` on (`:2498-2526`) | — |
| 0x97 | House window | u8 0, u32 id, string (`:3541-3544`) | ✔ | ✔ `:2528-2535` | — |
| 0xA0 | Stats | u16 hp, u16 maxHp, u32 cap×100, u32 exp, u16 lvl, u8 lvl%, u16 mana, u16 maxMana, u8 mlvl, u8 mlvl%, u8 soul, u16 stamina (`:4384-4404`) | ✔ | ✔ `:2585-2674` (cap /100, GameSoul, GamePlayerStamina) | — |
| 0xA1 | Skills | 7 × (u8, u8) | ✔ | ✔ `:2676-…` | — |
| 0xA2 | Icons | u16 | ✔ | ✔ `GamePlayerStateU16` | — |
| 0xA3 | Cancel target | empty (`:2544`) | ✔ | ✔ `GameAttackSeq` off (`:2821-2825`) | — |
| 0xAA | Talk | u32 stmt, string name, u16 level, u8 type, then pos / u16 channel / u32 time, string (`:4425-4509`) | ✔ | ✔ 840–860 mode map (`client-redemption/src/client/protocolcodes.cpp:167-196`, `:2868-2926`). ⚠ type 0x11 (`SPEAK_CHANNEL_RA`, anonymous red) is unmapped in **both** clients and throws | Optional: map 17 to `MessageChannelHighlight` (or a new mode) and read u16 |
| 0xAB | Channel list | **u16 count**, then n × [u16 id, string] (`:2091-2101, 2114-2132`) | ✔ reads u16 (`client/source/src/client/protocolgameparse.cpp:1415-1426`) | ✘ reads **u8** count (`:2928-2940`) | **C++**: u16 count under the PokeVerse feature |
| 0xAC | Open channel | u16, string (`:2179-2181`) | ✔ | ✔ `GameChannelPlayerList` off (`:2942-2960`) | — |
| 0xAD | Open private | string (`:1860-1861`) | ✔ | ✔ | — |
| 0xAE–0xB1 | Rule violation | stock | ✔ | ✔ below 1200 / 1310 | — |
| 0xB2 | Own channel | u16, string (`:2076-2078`) | ✔ | ✔ | — |
| 0xB3 | Close channel | u16 | ✔ | ✔ | — |
| 0xB4 | Text message | u8 class (0x12–0x1B), string | ✔ | ✔ classes 18–27 map to Red…Blue; the default branch reads the string (`:3013-3094`) | — |
| 0xB5 | Cancel walk | u8 dir | ✔ | ✔ | — |
| 0xBE/0xBF | Floor change | stock, using the 15/13 viewport | ✔ | ✘ until `viewport` is fixed | Config |
| 0xC8 | Outfit window | outfit, **u8** n (all outfits for OTClient, truncated to u8), n × [u16, string, u8 addons]; no mounts (`:3550-3601`) | ✔ | ✔ `GameNewOutfitProtocol`, u8 count, no mounts (`:3158-3206`) | — |
| 0xD2 | VIP add | u32, string, u8 (`:4247-4250`) | ✔ | ✔ `:3383-3409` | — |
| 0xD3/0xD4 | VIP login/logout | u32 | ✔ | ✔ `:3411-3437` | — |
| 0xDC | Tutorial | u8 | ✔ | ✔ `:3636-3640` | — |
| 0xDD | Map mark | pos, u8, string | ✔ | ✔ below 1200 (`:3642-3664`) | — |
| 0xF0 | Quest log | u16 n, n × [u16, string, u8] (`:4171-…`) | ✔ | ✔ `:3666-3679` | — |
| 0xF1 | Quest line | u16, u8 n, n × [string, string] (`:4195-…, 4888-4895`) | ✔ | ✔ `:3681-3699` | — |
| 0xF6–0xF9 | Market | **not sent** (commented out, `:3642-3945`) | — | — | — |
| **0xFF** | **PSoul sub-protocol** | u8 sub-opcode + payload. **Each one is its own OutputMessage** ("single message", e.g. `:3075-3090, 4905-4917`). See §6.2 | ✔ `client/source/src/client/protocolgameparse.cpp:62-183, 1842-2088` | ✘ unknown; the rest of the message is skipped (`:664-684`). Harmless to the stream, but all PokeVerse UI data is lost | **Lua**: `ProtocolGame.registerOpcode(255, handler)` (`client-redemption/modules/gamelib/protocolgame.lua:7-15,49-55`) |

### 6.1 Shared item and creature encodings (used inside 0x64–0x6B, 0x6E–0x78, 0x7D/0x7E)

**Item (`AddItem`, `server/source/networkmessage.cpp:97-118`).**

- Always `u16 clientId`.
- Then a **u16** count if the item is stackable or a rune, or a **u16** fluid index if it is a splash or fluid container. Stock 8.54 uses u8. This is the "65kitem" change.
- Legacy reads u16 for stackable, fluid, splash, or chargeable items (`client/source/src/client/protocolgameparse.cpp:2437-2466`).
- Redemption reads `GameCountU16 ? u16 : u8` for the same set (`:4350-4352`).
- **Fix: enable `GameCountU16`.**
- **UNVERIFIED**: whether any item has the server-side `isRune()` group but neither the stackable nor the chargeable DAT flag. Such an item would desync *both* clients. To check, dump `items.otb` groups and cross-reference DAT flags. The DAT has **zero** chargeable items (§10).

**Creature (`AddCreature`, `server/source/protocolgame.cpp:4297-4382`).**

```
u16 0x61 (unknown): u32 removeId, u32 id, string name
u16 0x62 (known):   u32 id
then:
  u8 health%
  u8 dir
  outfit
  u8 lightLevel
  u8 lightColor
  u16 speed
  u8 skull
  u8 shield
  [unknown only] u8 emblem
  [OTClient]     u8 icon                                   ← needs GameCreatureIcons
  u8 unpassable
  [OTClient]     u8 isMyMaster, u8 canAttack               ← PokeVerse
  [always]       u8 firstType, u8 secondType,
                 u16 level, u32 experience                 ← PokeVerse
```

- **Legacy** reads all of it (`client/source/src/client/protocolgameparse.cpp:2283-2410`). It stores the extra fields with `setNewInfo`, `setLocalPlayerSummon`, and `setAttackable` (`client/source/src/client/creature.cpp:931-938`), which raise Lua `onSetNewInfo` (`client/runtime-data/modules/gamelib/creature.lua:167`). Modules use `isLocalPlayerSummon()` and `isAttackable()` (`game_battle/battle.lua:24`, `game_pokebar/pokebar.lua:500`, `game_hotkeys/hotkeys_manager.lua:457-467`).
- **Redemption** reads emblem (on at 854 for unknown creatures, `:4190-4192`), icon only if `GameCreatureIcons` (`:4211-4213`), and unpass at ≥854 (`:4235-4237`), then stops. That leaves **10 unread bytes per creature**, so every map packet with a creature desyncs.
- Creature type is derived from ID ranges below 910 (`:4104-4114`). That matches the server's 0x10000000/0x40000000/0x80000000 ranges (`server/source/creature.h:180-182`, `client-redemption/src/client/protocolcodes.h:419-423`). ✔
- **Fix**: enable `GameCreatureIcons`, and in C++ read the 10 PokeVerse bytes after `unpass` under the PokeVerse feature. Store them on `Creature` with Lua getters, and raise `onSetNewInfo`, `isLocalPlayerSummon`, and `isAttackable` for module parity.

### 6.2 PSoul `0xFF` sub-opcodes (S→C)

Payloads come from the server senders (`server/source/protocolgame.cpp:3073-3401, 4908-5072`). Callback names come from `docs/EXTENDED_OPCODE_MAP.md:79-…`.

| Sub-op | Payload |
|---|---|
| 1 | u16 icon, u8 n, n×u16 |
| 2, 3 | empty |
| 4 | u16 itemId, u16 fastcall, u8 color, string, u8 level, u16 maxMana, u16 mana, u16 gender, u8 exp |
| 5 | u16 |
| 6 | u16 fastcall, u8, string, u8, u16, u16, u16, u8 |
| 7, 8 | empty |
| 9 | u16, u8 |
| 10 | u16 n, n×u8 |
| 11 | empty |
| 12 | u16, u8 |
| 13 | u16, u8 n, n×u16 |
| 14 | u16, u8 |
| 15 | u16 |
| 16 | empty |
| 17 | u16, 4×string |
| 18 | u32 creatureId |
| 19 | u32 id, u8 effect, u32 var |
| 20 | u16 n, n×u8 |
| 21 | u16, u8 |
| 22 | 3×u8 |
| 23 | u8 |
| 24 | string, then u8 textMode, or 0 + u8 n + n×[u8 id, string] |
| 25 | u16, u8, u16 n, n×u16 |
| 26 (OTClient only) | u8 n, n×[u16 clientId, u8 count] |

**Legacy bug.** `DollCaseStatus` (0x14) and `PokemonLevelUp` read the u16 count into a `uint8`. Do not copy that into the Redemption port.

Because each 0xFF packet is its own message, a Lua handler only has to consume its own payload. Redemption's `InputMessage` is exposed to Lua with `getU8`, `getU16`, `getU32`, and `getString`, so the whole sub-protocol can be ported to Lua and raise the same `g_game.on…` signals the legacy modules expect.

---

## 7. Client→server opcodes

The server switch is `server/source/protocolgame.cpp:577-916`. Each message has one opcode, and trailing bytes are ignored. Unknown opcodes are logged. Account banning for unknown bytes is controlled by `autoBanishUnknownBytes`, which is **false** (`server/runtime-data/config.lua:53`, `server/source/configmanager.cpp:238`, `protocolgame.cpp:874-903`).

Redemption sender references are in `client-redemption/src/client/protocolgamesend.cpp`.

| Op | Name | Server reads | Redemption @854 sends | Status / change |
|---|---|---|---|---|
| 0x0A | Game login | §4.3 | §4.3 | ✔ |
| 0x14 | Logout | — | `sendLogout` (`:143-148`) | ✔ |
| 0x1D | Ping-back | `playerReceivePingBack` | — (`GameClientPing` off) | ✔ |
| 0x1E | Ping reply | `parseReceivePing` | `sendPingBack` 0x1E (`:161-166`) | ✔ same as legacy |
| 0x32 | Extended opcode | u8 op, string (`parseExtendedOpcode`) | Only after the server sends ext-op 0 (`:37-48`) | ✘ **blocked**, see §8 |
| 0x33 | Change aware range | **not handled** | Only if `GameChangeMapAwareRange` (`:1397-1407`); off | ✔ keep it off |
| 0x64–0x6D | Walk / auto-walk / stop | stock | stock (`:168-…`) | ✔ |
| 0x6F–0x72 | Turn | stock | stock | ✔ |
| 0x77 | Equip item | **not handled** (no `case 0x77`) | `sendEquipItemWithCountOrSubType` (`:337-347`) | ⚠ ignored by the server; keep the UI from using it |
| 0x78 | Move / throw | pos, u16 sprite, u8 stack, pos, **u16 count** (`parseThrow`, `:1482`) | `GameCountU16 ? u16 : u8` (`:350-363`) | ✘ until **`GameCountU16`** is on |
| 0x79 | Look in shop | u16 id, **u8** count (`:1587-1592`) | `GameCountU16 ? u16 : u8` (`:365-375`) | ⚠ with the flag on, the server reads only the low byte; the high byte is ignored. Fine for count < 256 |
| 0x7A | Shop buy | u16, u8 subtype, u8 amount, u8 ignoreCap, u8 inBackpacks (`:1594-1602`) | u16, u8, u8 (`GameDoubleShopSellAmount` off), u8, u8 (`:377-390`) | ✔ |
| 0x7B | Shop sell | u16, u8, u8 (`:1604-1610`) | u16, u8, u8, **u8 ignoreEquipped** (`:392-404`) | ✔ trailing byte ignored (the legacy client does the same) |
| 0x7C–0x80 | Shop/trade close, trade | stock | stock | ✔ |
| 0x82–0x85 | Use / use-with / rotate | stock 8.6 | stock (no extra fields below 860) | ✔ |
| 0x87–0x8A | Container / text edit | stock | stock | ✔ |
| 0x8C/0x8D | Look | stock | stock | ✔ |
| 0x96 | Say | u8 type; private: string receiver; channels Y/RN/RA: u16 (`:1496-1531`) | same mode map at 840–860 (`:555-587`) | ✔ |
| 0x97–0x9E | Channels / RVR | stock | stock | ✔ |
| 0xA0–0xA2 | Fight modes / attack / follow | stock (no seq) | `GameAttackSeq` off | ✔ |
| 0xA3–0xAC | Party / own channel | stock | stock | ✔ |
| 0xBE | Cancel move | stock | stock | ✔ |
| 0xD2/0xD3 | Outfit request / set | u16 look + 4 colors + addons | same, no mount (`:850-…`) | ✔ |
| 0xDC–0xDE | VIP | stock | stock (`GameAdditionalVipInfo` off) | ✔ |
| 0xF0/0xF1 | Quest log / line | stock | stock | ✔ |
| **0xFA** | Request poll window | empty | **none** | Add a Lua sender (`Protocol:send` is bound, `client-redemption/src/framework/luafunctions.cpp:1049`) |
| **0xFB** | Poll vote | u8 option, or string in text mode | **none** | Same; port from legacy `sendPollVote` |

---

## 8. Extended opcodes (0x32): enabling

**Server side.**

- On game login it registers the `ExtendedOpcode` creature event only for OTClient OS values (`server/source/protocolgame.cpp:302-304`).
- It sends `0x32` only to OTClient users (`:1834-1848`).
- It **never sends ext-opcode 0**. I found no `0x32/0` in `protocolgame.cpp`, and no `doSendPlayerExtendedOpcode(cid, 0, …)` in `server/runtime-data`.

**Legacy client.** `sendExtendedOpcode` sends unconditionally, with no enable check (`client/source/src/client/protocolgamesend.cpp:38-49`).

**Redemption.**

- Receive: ✔ (`protocolgameparse.cpp:3817-3829`). It dispatches to Lua `ProtocolGame:onExtendedOpcode` (`client-redemption/modules/gamelib/protocolgame.lua:17-47`), which supports `registerExtendedOpcode` and JSON chunking.
- Send: ✘. `sendExtendedOpcode` refuses until `m_enableSendExtendedOpcode` is true (`protocolgamesend.cpp:39-47`, `protocolgame.h:474`). That flag is set only when ext-op 0 arrives (`protocolgameparse.cpp:3822-3823`).
- Every C→S PokeVerse opcode would therefore be dropped with "extended opcodes are not enabled": 10, 41, 61, 62, 63, 64, 103, 141, …

**Fix (preferred, Redemption C++).** Set `m_enableSendExtendedOpcode = true` in `ProtocolGame::onConnect` or `parseLogin` when the PokeVerse feature is on.

**Alternative (one-line server Lua).** `doSendPlayerExtendedOpcode(cid, 0, "")` in `login.lua`.

**PokeVerse IDs in use** (`docs/EXTENDED_OPCODE_MAP.md:42-69`): 0, 1, 2, 8, 9, 10, 25, 27, 41, 58, 59, 60, 61, 62, 63, 64, 81, 85, 103, 141, 199, 200, 201, 202.

- Opcode 2 is consumed in C++ as ping-back on both clients. `GameExtendedClientPing` is off, so Redemption never *sends* 2.
- Redemption treats opcode 0 as the enable signal and opcode 2 as ping-back, exactly like legacy.

---

## 9. Feature flags: legacy vs Redemption

Legacy features come from `client/source/src/client/game.cpp:1617-1749` for protocol 854, plus Lua `protocollogin.lua:215-218` and `things.lua:25-28`. Redemption features come from `client-redemption/modules/game_features/features.lua` at clientVersion 854. Enum values are in `client-redemption/src/client/const.h:532-670`.

| Feature | Legacy @854 | Redemption @854 stock | Needed | Why |
|---|---|---|---|---|
| ProtocolChecksum, AccountNames, DoubleFreeCapacity | on | on (`:44-48`) | on | §4.1, §3, 0xA0 |
| ChallengeOnLogin | on | on (`:50-51`) | on | §4.2 |
| MessageSizeCheck | (n/a) | on (`:52`) | on | The challenge carries an inner length (§4.1) |
| TileAddThingWithStackpos | (implicit) | on (`:53`) | on | 0x6A |
| CreatureEmblems | on | on (`:56-58`) | on | §6.1 |
| LooktypeU16, MessageStatements, LoginPacketEncryption | on | on (`:25-29`) | on | |
| PlayerAddons, PlayerStamina, NewFluids, MessageLevel, PlayerStateU16, NewOutfitProtocol, WritableDate | on | on (`:31-42`) | on | |
| GameSoul, GameLevelU16 | (implicit) | on (`:17-23`) | on | 0xA0 |
| ChargeableItems (DAT remap) | on (780–854) | built into DAT parse for 780–859 (`client-redemption/src/client/thingtype.cpp:528-538`) | — | §10 |
| **MagicEffectU16** | on (Lua) | **off** | **on** | 0x83 |
| **CreatureIcons** | on (Lua) | **off** (≥1036) | **on** | §6.1 |
| **SpritesU32** | on (`things.lua`) | **off**; tried as a fallback after the first DAT load fails (`client-redemption/modules/game_things/things.lua:14-42`) | **on** (enable explicitly) | DAT and SPR, §10 |
| **SpritesAlphaChannel** | on (Lua) | **off** | **on** | SPR has alpha (§10) |
| **CountU16** | (legacy reads u16 unconditionally) | **off** | **on** | §6.1, 0x78 |
| PlayerMarket | on (always) | off (≥940) | off | Market packets are not sent; DAT has no market attribute (§10) |
| BlueNpcNameColor, DiagonalAnimatedText, ForceFirstAutoWalkStep | on | off | optional | Cosmetic only |
| FormatCreatureName, AllowPreWalk, MapCache | — | on (`:10-14`) | keep | FormatCreatureName only re-capitalises names (cosmetic) |
| ChangeMapAwareRange | off | off | **keep off** | The server has no 0x33 handler |
| ClientVersion, PreviewState, LoginPending, NewSpeedLaw, ContainerPagination, ThingMarks, … | off (protocol-keyed) | off at 854 | **keep off** | Would add wire fields (§2) |
| *(new)* `GamePokeVerse` | — | — | **add** | Gates the C++ deltas: lightHour, creature +10 bytes, item pname trailer, u16 channel count, extended-opcode auto-enable |

The legacy client turns `GameMagicEffectU16`, `GameCreatureIcons`, `GameSpritesAlphaChannel`, and `GamePlayerMarket` on from Lua right before the login packet. Do the same in Redemption: add an `if version == 854 then … end` block to `features.lua`, or enable them in a PokeVerse module's `onClientVersionChange`.

---

## 10. Assets: SPR, DAT, and decryption (no renumbering, no format change)

**Files.** `client/runtime-data/data/things/Tibia.{dat,spr,otfi}`. The `.dat` is byte-identical to `_import/extracted/Cliente/Cliente/data/things/Tibia.dat`. Redemption looks for `/data/things/<version>/Tibia.{dat,spr}`, i.e. `/data/things/854/` (`client-redemption/modules/game_things/things.lua:60-77`, `client-redemption/data/things/README.md`).

### 10.1 DAT

**Header.** Signature `0x4B1E2CAA` (8.54). Counts: items 34575, outfits 2846, effects 1147, missiles 121. File size 1,905,047 bytes.

**I parsed the whole file offline with Python**, using Redemption's 854 rules:

- attribute 8 means Chargeable, and attributes above 8 are decremented (`client-redemption/src/client/thingtype.cpp:528-538`);
- no frame groups and no enhanced animations, because `GameIdleAnimations` and `GameEnhancedAnimations` are off (`:632-672`);
- **u32 sprite indices** (`:681`).

The parse consumed **exactly** 1,905,047 bytes and ended cleanly. With no attribute remap, it fails almost immediately.

So:

- The DAT is **plaintext 8.54 with u32 sprite IDs** and needs no decryption.
- Raw attribute 8 (Chargeable) occurs **0 times**, and raw 33 does not occur. The highest raw attribute is 32, which is *Look* after the remap.
- The legacy "PS" hack `protocolVersion == 854 && attr == 32 → ThingAttrMarket` (`client/source/src/client/thingtype.cpp:162-164`) therefore **never fires** for this DAT.
- Redemption would map post-remap 32 to Cloth (`client-redemption/src/client/const.h:1214`), but no such attribute exists in this file either.
- **No DAT parser change is needed**; only `GameSpritesU32` must be on. If a future DAT ever uses raw attribute 33, port the PS hack (Market payload: u16, u16, u16, string, u16, u16).

**Legacy decryption.** The legacy `loadDat` XORs the file with a key from `g_app.getMainCode()` whenever the key size is non-zero (`client/source/src/client/thingtypemanager.cpp:101-163`). Since the shipped DAT parses as plaintext, the shipped legacy binary must have run with an empty key. Equivalently, the encryption is a no-op for this asset set. **UNVERIFIED** for the original Windows build, which I did not run; it does not matter for Redemption.

### 10.2 SPR

- Signature `0x4B1E2C87`, **u32** sprite count 169,214, about 275 MB (Git LFS).
- The legacy normal path is unencrypted (`client/source/src/client/spritemanager.cpp:61-83`). Custom `/sprs/*.sp` decryption is used only when `/sprs/config` exists (`:749-817`), and it does not exist here.
- Redemption reads the u32 count under `GameSpritesU32` (`client-redemption/src/client/spritemanager.cpp:92`) and RGBA pixels under `GameSpritesAlphaChannel` (`:280`).

### 10.3 OTFI

`Tibia.otfi` declares `extended: true`, `transparency: true`, `frame-durations: false`, `frame-groups: false`.

**Redemption has no `.otfi` reader** (no `otfi` references in `client-redemption/src`). The two flags must therefore be enabled in Lua:

- `extended` maps to `GameSpritesU32`;
- `transparency` maps to `GameSpritesAlphaChannel`.

The other two must stay off: `frame-durations` corresponds to `GameEnhancedAnimations` and `frame-groups` to `GameIdleAnimations`.

**Risk in the fallback loader.** `things.lua` tries `GameEnhancedAnimations` and `GameIdleAnimations` combinations if the first load fails. Enabling `GameSpritesU32` up front avoids a wrong combination ever being tried. **UNVERIFIED** whether u16 indices would fail fast; a single load attempt with logging would show it.

### 10.4 Thing IDs

No renumbering is needed. The server sends `clientId` values (`networkmessage.cpp:100,113`), which index this DAT directly. The legacy client and Redemption use the same item, outfit, effect, and missile numbering.

---

## 11. Prioritised change list for Redemption

All changes are in `client-redemption/`. None touch the server or the assets.

Proposed new feature: `GamePokeVerse`. Add it to `const.h:532-670` and `modules/gamelib/const.lua`, and enable it at 854 only, or from a PokeVerse module.

### A. Required to log in (character list visible)

1. **Login packet lang byte (Lua).** In `modules/gamelib/protocollogin.lua:42`, after `addU16(protocolVersion)`, add `msg:addU8(langId)`. Without it, the server's RSA size check fails (`server/source/protocollogin.cpp:86-92`, `protocol.cpp:200`).
2. **Character list parser (Lua).** Override `ProtocolLogin:parseCharacterList` (`protocollogin.lua:203-265`) to read, per character, `u16 level, u8 vocation, u16 lookType, 5×u8, u8 n, n×[u16, string]`, then `u16 premDays`, then `u8 pollAvailable`. The server side is `protocollogin.cpp:470-505`.
3. **Server address and version (config).** Host 127.0.0.1, port **7564**, client/protocol **854** (`init.lua` `Servers_init`, or the login UI). The RSA key is already `OTSERV_RSA` (no change).

### B. Required to enter the game and render

4. **Feature flags at 854 (Lua).** Enable `GameMagicEffectU16`, `GameCreatureIcons`, `GameSpritesU32`, `GameSpritesAlphaChannel`, `GameCountU16`, and `GamePokeVerse`, *before* things load and before login. The legacy client does the same (`protocollogin.lua:215-218`, `things.lua:25-28`).
5. **Map aware range 32×28 (config).** In `client-redemption/data/setup.otml:7`, change `viewport: 8 6` to `viewport: 15 13`. This makes `resetAwareRange` produce 15/13/16/14 (`src/client/map.cpp:844-850`), which matches `server/source/map.h:160-163`. **UNVERIFIED**: the effect on the visible game-window size. If it enlarges the drawn area, decouple the drawing dimension from the aware range in `gameconfig`/`MapView`.
6. **parseLogin lightHour (C++).** In `protocolgameparse.cpp:728-776`: `if (getFeature(GamePokeVerse)) { auto h = msg->getU16(); g_lua.callGlobalField("g_game","onLightHour",h); }`.
7. **Creature PokeVerse fields (C++).** In `getCreature`, after `unpass` (`:4235-4237`), under `GamePokeVerse`, read `u8 isMyMaster, u8 canAttack, u8 firstType, u8 secondType, u16 level, u32 exp`. Store them on `Creature`, add Lua bindings (`isLocalPlayerSummon`, `isAttackable`, getters), and raise `onSetNewInfo(firstType, secondType, level, exp)`.
8. **Item pname trailer (C++).** In `parseOpenContainer` (per content item, `:1614-1616`), `parseContainerAddItem` (`:1641-1648`), `parseContainerUpdateItem` (`:1650-1657`), and `parseAddInventoryItem` (`:1787-1793`): under `GamePokeVerse`, read `string pname` and, if `pname != "none"`, `u32 level, u32 gender`. Store them on `Item` with Lua getters. Do **not** apply this to the container header item, trade, or map items; the server does not send it there.
9. **Channel list u16 count (C++).** `parseChannelList` (`:2928-2940`): use `GamePokeVerse ? getU16() : getU8()`. This is reached when opening the channel dialog, so it is only borderline "required to render".

### C. Required for PokeVerse modules

10. **Unlock extended-opcode sending (C++).** Set `m_enableSendExtendedOpcode = true` on connect or login when `GamePokeVerse` is on (`protocolgamesend.cpp:39`, `protocolgameparse.cpp:3822-3823`). Optional server alternative: `doSendPlayerExtendedOpcode(cid, 0, "")` in `login.lua`.
11. **PSoul 0xFF sub-protocol (Lua).** `ProtocolGame.registerOpcode(255, function(proto, msg) … end)` in a PokeVerse gamelib file. Port the 26 sub-opcode parsers (§6.2, legacy `protocolgameparse.cpp:1842-2088`) and raise the same `g_game.onPokemon…`, `onPokedex…`, `onStatusBar…` signals. Fix the legacy u8 truncation for sub-ops 0x14 and PokemonLevelUp.
12. **Poll packets (Lua).** Senders for `0xFA` (empty) and `0xFB` (u8, or string) via `OutputMessage.create()` and `g_game.getProtocolGame():send(msg)`. Wire them to the character-list poll flag (item 2).
13. **Port the PokeVerse Lua modules.** Re-register their extended-opcode handlers using the IDs in §8. Redemption's `ProtocolGame.registerExtendedOpcode` and `registerExtendedJSONOpcode` APIs are the same shape as legacy (`modules/gamelib/protocolgame.lua:61-115`).
14. **Optional polish.**
    - Map speak type 0x11 (`SPEAK_CHANNEL_RA`) in `protocolcodes.cpp:167-196`.
    - Route 0x15 to an FYI box instead of LoginAdvice.
    - Enable BlueNpcNameColor and DiagonalAnimatedText.
    - Keep `GameChangeMapAwareRange` off; there is no server 0x33 handler.
    - Avoid equip-hotkeys (0x77, which the server ignores).

### How to verify the remaining UNVERIFIED points

- **XTEA/checksum interop and the full login flow.** Run Redemption at 854 against the Linux server build with items 1–9 applied. Log `[Warning - Protocol::RSA_decrypt]` on the server and `invalid checksum` / `Unhandled opcode` / `parse message exception` on the client (`protocolgameparse.cpp:664-725`).
- **Rune-group items.** Dump the `items.otb` groups and confirm every `isRune()` item is stackable in the DAT.
- **Viewport side effects.** Take screenshots at `viewport: 15 13`.
