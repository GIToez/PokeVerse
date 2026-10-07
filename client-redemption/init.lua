-- this is the first file executed when the application starts
-- we have to load the first modules form here

-- updater
Services = {
    --updater = "http://localhost/api/updater.php", --./updater
    --status = "http://localhost/login.php", --./client_entergame | ./client_topmenu
    --websites = "http://localhost/?subtopic=accountmanagement", --./client_entergame "Forgot password and/or email"
    --createAccount = "http://localhost/clientcreateaccount.php", --./client_entergame -- createAccount.lua
    --getCoinsUrl = "http://localhost/?subtopic=shop&step=terms", --./game_market
    -- PokeVerse ships its own 854 SPR/DAT; never download upstream Tibia assets.
    clientAssets = {
        enabled = false,
        repository = "dudantas/tibia-client",
        installSounds = true,
        strictManifestSha256 = true,
        allowRawFallbackHashMismatch = false,
        allowMissingPackedRawFallback = true,
        preferArchive = true,
        fallbackToArchiveOnManifestFailure = false,
        installArchiveExtras = true,
        archiveExtraPrefixes = { "bin" },
        installPackagedFiles = true
    }, -- ./client_assets
}

--- Enables or disables the entire server configuration block.
-- Set to `false` to disable all configuration below.
local ENABLE_SERVERS = true

---
-- @module Servers_init
-- Configuration table for all servers used by the system.
--
-- This entire block is conditionally enabled based on ENABLE_SERVERS.
-- When ENABLE_SERVERS == false, everything is ignored/disabled.
--

---
-- Server configuration system for multi-server or multi-world clients.
--
-- This structure allows a single client build to connect to multiple servers
-- without requiring duplicate client folders.
--
-- A server that hosts several worlds, or that provides a separate test environment,
-- can simply define additional entries inside this configuration table.
--
-- Instead of maintaining multiple client installations (one per world/server),
-- the client can switch between servers by selecting the desired configuration entry.
-- This simplifies testing, avoids redundant directories, and centralizes connection settings.
--
-- The ENABLE_SERVERS flag allows the entire configuration block to be enabled or disabled
-- without deleting or commenting out individual entries.
--

Servers_init = {}

-- PokeVerse server profiles. Development packages use "development" (the local server from
-- server/runtime-data/config.lua). Staging and production entries are added here once those servers
-- exist; POKEVERSE_SERVER_PROFILE selects a profile without editing this file.
local POKEVERSE_SERVER_PROFILES = {
    development = {
        ["127.0.0.1"] = { port = 7564, protocol = 854, httpLogin = false },
    },
}

if ENABLE_SERVERS then
    local profileName = os.getenv("POKEVERSE_SERVER_PROFILE") or "development"
    local profile = POKEVERSE_SERVER_PROFILES[profileName] or POKEVERSE_SERVER_PROFILES.development
    for host, values in pairs(profile) do
        Servers_init[host] = values
    end
    -- On a phone, 127.0.0.1 is the phone itself. A second entry (10.0.2.2 is the host PC as seen from
    -- the Android emulator) makes the login screen show an editable server address and port, so a
    -- tester can type the address of the PC running the server (docs/DOWNLOAD_AND_RUN.md).
    local first = next(Servers_init)
    if g_platform.isMobile() and first and next(Servers_init, first) == nil then
        Servers_init["10.0.2.2"] = { port = 7564, protocol = 854, httpLogin = false }
    end
end

-- buildProfile "production" keeps developer tools unloaded; "development" (or the environment variable
-- POKEVERSE_PROFILE=development) loads them. disabledModules lists Redemption modules that the PokeVerse
-- 8.54 server does not support; they stay on disk and are skipped by every load path
-- (g_modules.setModuleDisabled). Classification: docs/REDEMPTION_MODULE_AUDIT.md.
PokeVerseConfig = {
    buildProfile = os.getenv("POKEVERSE_PROFILE") or "production",
    disabledModules = {
        -- CipSoft store: opcodes 0xFA / 0xFB are the PokeVerse server's poll request / vote
        "game_store",
        -- stock Tibia market (0xF4-0xF9, not handled by the server) and the opcode 201 coin shop (no server
        -- handler); the PokeVerse market and shop ports replace them
        "game_market", "game_shop",
        -- Tibia 10.x-15.x systems without a PokeVerse server side
        "game_prey", "game_imbuing", "game_imbuementtracker", "game_forge", "game_wheel", "game_cyclopedia",
        "game_highscore", "game_stash", "game_quickloot", "game_rewardwall", "game_blessing", "game_taskboard",
        "game_tutorial", "game_inspect", "game_proficiency", "game_analyser", "game_lootsplitter",
        "game_paperdolls", "game_playermount", "game_unjustifiedpoints", "game_spelllist",
        -- bundled bot (automation is not allowed) and its button window
        "game_bot", "game_buttons"
    },
    developerModules = { "client_debug_info", "client_terminal", "dev_otui", "game_htmlsample", "game_soundDebug" }
}

g_app.setName("PokeVerse");
g_app.setCompactName("pokeverse");
g_app.setOrganizationName("pokeverse");

g_app.hasUpdater = function()
    return (Services.updater and Services.updater ~= "" and g_modules.getModule("updater"))
end

-- setup logger
g_logger.setLogFile(g_resources.getWorkDir() .. g_app.getCompactName() .. '.log')
g_logger.info("Operating system: " .. g_platform.getOSName())

-- print first terminal message
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' ..
    g_app.getBuildCommit() .. ') built on ' .. g_app.getBuildDate() .. ' for arch ' ..
    g_app.getBuildArch())

-- setup lua debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
    g_logger.debug("Started LUA debugger.")
else
    g_logger.debug("LUA debugger not started (not launched with VSCode local-lua).")
end

-- add data directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. 'data', true) then
    g_logger.fatal('Unable to add data directory to the search path.')
end

-- add modules directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. 'modules', true) then
    g_logger.fatal('Unable to add modules directory to the search path.')
end

g_html.addGlobalStyle('/data/styles/html.css')
g_html.addGlobalStyle('/data/styles/custom.css')

-- try to add mods path too
g_resources.addSearchPath(g_resources.getWorkDir() .. 'mods', true)

-- setup directory for saving configurations
g_resources.setupUserWriteDir(('%s/'):format(g_app.getCompactName()))

-- search all packages
g_resources.searchAndAddPackages('/', '.otpkg', true)

-- load settings
g_configs.loadSettings('/config.otml')

g_modules.discoverModules()

for _, name in ipairs(PokeVerseConfig.disabledModules) do
    g_modules.setModuleDisabled(name, true)
end
if PokeVerseConfig.buildProfile ~= "development" then
    for _, name in ipairs(PokeVerseConfig.developerModules) do
        g_modules.setModuleDisabled(name, true)
    end
end
g_logger.info(("PokeVerse build profile '%s', %d module(s) disabled"):format(PokeVerseConfig.buildProfile,
    #g_modules.getDisabledModules()))

-- libraries modules 0-99
g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded('corelib')
g_modules.ensureModuleLoaded('gamelib')
g_modules.ensureModuleLoaded('modulelib')
g_modules.ensureModuleLoaded("startup")

g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded('game_shaders') -- pre load

local function loadModules()
    -- client modules 100-499
    g_modules.autoLoadModules(499)
    g_modules.ensureModuleLoaded('client')

    -- game modules 500-999
    g_modules.autoLoadModules(999)
    g_modules.ensureModuleLoaded('game_interface')

    -- mods 1000-9999
    g_modules.autoLoadModules(9999)
    g_modules.ensureModuleLoaded('client_mods')

    -- Fixed name: upstream packaging (Dockerfiles, Android and Emscripten builds) ships otclientrc.lua.
    local script = '/otclientrc.lua'

    if g_resources.fileExists(script) then
        dofile(script)
    end

    -- uncomment the line below so that modules are reloaded when modified. (Note: Use only mod dev)
    -- g_modules.enableAutoReload()
end

-- run updater, must use data.zip
if g_app.hasUpdater() then
    g_modules.ensureModuleLoaded("updater")
    return Updater.init(loadModules)
end

loadModules()
