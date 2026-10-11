filename =  nil
loaded = false

spr_amount = 0
spr_signature = 0

function init()
  connect(g_game, { onClientVersionChange = load })
end

function terminate()
  disconnect(g_game, { onClientVersionChange = load })
end

function setFileName(name)
  filename = name
end

function isLoaded()
  return loaded
end

function load()
  local version = g_game.getClientVersion()
  g_game.enableFeature(GameLightBlueNpcNameColor)
  g_game.enableFeature(GameSpritesAlphaChannel)
  g_game.enableFeature(GameDiagonalAnimatedText)
  g_game.enableFeature(GameSpritesU32)

  local datPath, sprPath, otmlPath
  if filename then
    datPath = resolvepath('/things/' .. filename)
    sprPath = resolvepath('/things/' .. filename)
    otmlPath = resolvepath('/things/' .. filename)
  else
    datPath = resolvepath('/things/Tibia.dat')
    sprPath = resolvepath('/things/Tibia.spr')
    otmlPath = resolvepath('/things/Tibia')
  end

  if not g_resources.fileExists(sprPath) and g_resources.fileExists("/sprs/config") then
    local config = g_resources.readFileContents("/sprs/config")
    if config then
      local t = string.explode(config, "|")

      spr_signature = tonumber(t[1])
      spr_amount = tonumber(t[2])
    end
  end

  local errorMessage = ''
  if not g_things.loadDat(datPath) then
    errorMessage = errorMessage .. tr("Unable to load dat file, please place a valid dat in '%s'", datPath) .. '\n'
  end
  if spr_amount ~= 0 then
    g_sprites.initCustomSprites(spr_amount, spr_signature, "/sprs", false)

    for index, info in pairs(g_resources.listDirectoryFiles("/sprs/")) do
      if string.find(info, ".spj") then
        print(index, "/sprs/"..info)
        g_sprites.cacheCustomSprites("/sprs/"..info)
      end
    end
  else
    if not g_sprites.loadSpr(sprPath) then
      errorMessage = errorMessage .. tr("Unable to load spr file, please place a valid spr in '%s'", sprPath) .. '\n'
    end
  end
  if not g_things.loadOtml(otmlPath) then
    errorMessage = errorMessage .. tr("Unable to load otml file, please place a valid otml in '%s'", otmlPath)
  end

	-- g_things.loadOtb ('/items/items.otb')
	-- g_things.loadXml('/items/items.xml')

  loaded = (errorMessage:len() == 0)

  if errorMessage:len() > 0 then
    local messageBox = displayErrorBox(tr('Error'), errorMessage)
    addEvent(function() messageBox:raise() messageBox:focus() end)

    disconnect(g_game, { onClientVersionChange = load })
    g_game.setClientVersion(0)
    g_game.setProtocolVersion(0)
    connect(g_game, { onClientVersionChange = load })
  end
end
