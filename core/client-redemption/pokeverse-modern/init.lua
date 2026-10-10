-- PokeVerse on the Redemption engine: Redemption's startup with the PokeVerse modules.

-- Redemption's modules use LuaJIT's bit library; this build runs PUC Lua 5.1 with bit32
bit = bit or bit32

Services = {
  updater = "",
}

g_app.setName("PokeVerse")
g_app.setCompactName("pokeverse")
g_app.setOrganizationName("pokeverse")

g_app.hasUpdater = function()
  return Services.updater and Services.updater ~= "" and g_modules.getModule("updater") ~= nil
end

g_resources.setupUserWriteDir(g_app.getCompactName() .. "/")

g_logger.setLogFile(g_resources.getUserDir() .. g_app.getCompactName() .. ".log")
g_logger.info(os.date("== application started at %b %d %Y %X"))
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' ..
  g_app.getBuildCommit() .. ') built on ' .. g_app.getBuildDate() .. ' for arch ' .. g_app.getBuildArch())

if not g_resources.addSearchPath(g_resources.getWorkDir() .. "data", true) then
  g_logger.fatal("Unable to add data directory to the search path.")
end

if not g_resources.addSearchPath(g_resources.getWorkDir() .. "modules", true) then
  g_logger.fatal("Unable to add modules directory to the search path.")
end

g_html.addGlobalStyle('/data/styles/html.css')
g_html.addGlobalStyle('/data/styles/custom.css')

g_resources.searchAndAddPackages('/', '.otpkg', true)

g_configs.loadSettings("/config.otml")

g_modules.discoverModules()

g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded("corelib")
g_modules.ensureModuleLoaded("gamelib")
g_modules.ensureModuleLoaded("modulelib")
g_modules.ensureModuleLoaded("startup")

g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded("game_shaders")

local function loadModules()
  g_modules.autoLoadModules(499)
  g_modules.ensureModuleLoaded("client")

  g_modules.autoLoadModules(999)
  g_modules.ensureModuleLoaded("game_interface")

  g_modules.autoLoadModules(9999)
end

if g_app.hasUpdater() then
  g_modules.ensureModuleLoaded("updater")
  return Updater.init(loadModules)
end

loadModules()
