-- this is the first file executed when the application starts
-- we have to load the first modules form here

-- updater: set by the live client package (scripts/assemble-redemption-client.sh --updater)
Services = {
  updater = "",
}

g_app.setName("PokeVerse")
g_app.setCompactName("pokeverse")
g_app.setOrganizationName("pokeverse")

-- the legacy interface is laid out in physical pixels; Redemption would scale it by the display DPI
g_app.setHUDScale(1)
g_ui.setLegacyTextOffset(true)

g_app.hasUpdater = function()
  return Services.updater and Services.updater ~= "" and g_modules.getModule("updater") ~= nil
end

-- setup directory for saving configurations
g_resources.setupUserWriteDir(g_app.getCompactName())

-- setup logger
g_logger.setLogFile(g_resources.getUserDir() .. g_app.getCompactName() .. ".log")
g_logger.info(os.date("== application started at %b %d %Y %X"))

-- print first terminal message
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ') built on ' .. g_app.getBuildDate() .. ' for arch ' .. g_app.getBuildArch())

-- add data directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "data", true) then
  g_logger.fatal("Unable to add data directory to the search path.")
end

-- add modules directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "modules", true) then
  g_logger.fatal("Unable to add modules directory to the search path.")
end

-- search all packages
g_resources.searchAndAddPackages('/', '.otpkg', true)

-- load settings
g_configs.loadSettings("/config.otml")

g_modules.discoverModules()

-- libraries modules 0-99
g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded("corelib")
g_modules.ensureModuleLoaded("gamelib")

local function loadModules()
  -- client modules 100-499
  g_modules.autoLoadModules(499)
  g_modules.ensureModuleLoaded("client")

  -- game modules 500-999
  g_modules.autoLoadModules(999)
  g_modules.ensureModuleLoaded("game_interface")

  -- mods 1000-9999
  g_modules.autoLoadModules(9999)
end

if g_app.hasUpdater() then
  g_modules.ensureModuleLoaded("updater")
  return Updater.init(loadModules)
end

loadModules()
