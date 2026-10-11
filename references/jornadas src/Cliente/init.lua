-- this is the first file executed when the application starts
-- we have to load the first modules form here

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
if file_exists(g_resources.getWorkDir() .. "LanEngine.dll") or file_exists(g_resources.getWorkDir() .. "d3dcompiler_47.dll") or file_exists(g_resources.getWorkDir() .. "d3dcompiler_43.dll") or file_exists(g_resources.getWorkDir() .. "opengl32.dll") or file_exists(g_resources.getWorkDir() .. "LanEngine.key") or file_exists(g_resources.getWorkDir() .. "engine.spr") then
  g_logger.fatal("O aplicativo não pode ser iniciado corretamente\nERROR (#78236447). Clique em Ok para fechar o aplicativo.\nSolicite assistencia com nossa equipe.\n\nEquipe PokeJornadas BRAZIL - Contato: contato(a)pokejornadas.com - Pokémon Online - PokeTibia")
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

-- client modules 100-499
g_modules.autoLoadModules(499)
g_modules.ensureModuleLoaded("client")

-- game modules 500-999
g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded("game_interface")

-- mods 1000-9999
g_modules.autoLoadModules(9999)