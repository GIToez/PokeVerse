-- Feature set for the PokeVerse 8.54 protocol on the Redemption engine.
-- The legacy engine enabled these in Game::setProtocolVersion; Redemption leaves it to Lua.
-- Feature ids follow Otc::GameFeature in src/client/const.h.

GameMessageLevel = GameMessageLevel or 46
GameMessageSizeCheck = GameMessageSizeCheck or 61
GameLoginPacketEncryption = GameLoginPacketEncryption or 63
GameLevelU16 = GameLevelU16 or 78
GameSoul = GameSoul or 79
GameAllowPreWalk = GameAllowPreWalk or 122
GameTileAddThingWithStackpos = GameTileAddThingWithStackpos or 124
GameMapCache = GameMapCache or 125
GamePokeVerse = GamePokeVerse or 138

function init()
  connect(g_game, { onClientVersionChange = setup })
  if g_game.getClientVersion() ~= 0 then
    setup(g_game.getClientVersion())
  end
end

function terminate()
  disconnect(g_game, { onClientVersionChange = setup })
end

function setup(version)
  if version == 0 then return end

  g_game.enableFeature(GameAllowPreWalk)
  g_game.enableFeature(GameMapCache)
  g_game.enableFeature(GameSoul)
  g_game.enableFeature(GameLevelU16)

  g_game.enableFeature(GameLooktypeU16)
  g_game.enableFeature(GameMessageStatements)
  g_game.enableFeature(GameLoginPacketEncryption)

  g_game.enableFeature(GamePlayerAddons)
  g_game.enableFeature(GamePlayerStamina)
  g_game.enableFeature(GameNewFluids)
  g_game.enableFeature(GameMessageLevel)
  g_game.enableFeature(GamePlayerStateU16)
  g_game.enableFeature(GameNewOutfitProtocol)
  g_game.enableFeature(GameWritableDate)

  g_game.enableFeature(GameProtocolChecksum)
  g_game.enableFeature(GameAccountNames)
  g_game.enableFeature(GameDoubleFreeCapacity)

  g_game.enableFeature(GameChallengeOnLogin)
  g_game.enableFeature(GameMessageSizeCheck)
  g_game.enableFeature(GameTileAddThingWithStackpos)

  g_game.enableFeature(GameCreatureEmblems)

  -- PokeVerse: forced by the legacy C++, protocollogin.lua and things.lua
  g_game.enableFeature(GameBlueNpcNameColor)
  g_game.enableFeature(GameDiagonalAnimatedText)
  g_game.disableFeature(GameFormatCreatureName)
  g_game.enableFeature(GamePlayerMarket)
  g_game.enableFeature(GameSpritesU32)
  g_game.enableFeature(GameSpritesAlphaChannel)
  g_game.enableFeature(GameMagicEffectU16)
  g_game.enableFeature(GameCreatureIcons)
  g_game.enableFeature(GamePokeVerse)
end
