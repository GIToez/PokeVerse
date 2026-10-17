-- Keybinds (Settings > Controls) for the top bar windows that have none in their own module.
-- Letter defaults only apply with chat off; the rest start unbound for players to set.

local CATEGORY = 'Windows'

local function call(moduleName, path)
    return function()
        local target = modules[moduleName]
        for part in path:gmatch('[^.]+') do
            target = target and target[part]
        end
        if g_game.isOnline() and type(target) == 'function' then
            target()
        end
    end
end

local function visibleButton(id)
    local button = modules.client_topmenu.getButton(id)
    return button and button:isVisible()
end

local keybinds = {
    { 'Show/hide your Trainer Card', 'C', call('game_trainercard', 'toggle') },
    { 'Show/hide Tasks', 'T', call('game_dailytasks', 'toggle') },
    { 'Show/hide the event calendar', '', call('game_calendar', 'toggle') },
    { 'Show/hide the daily login reward', '', call('game_dailylogin', 'toggle') },
    { 'Show/hide the Pokepedia tracker', '', call('game_pokepedia', 'Tracker.toggle') },
    { 'Show/hide the minimap', '', call('game_minimap', 'toggle') },
    { 'Show/hide the inventory', '', call('game_inventory', 'toggle') },
    { 'Show/hide the options', '', call('client_options', 'toggle') },
    { 'Open the store', '', call('game_mainpanel', 'toggleStore') },
    { 'Show/hide the admin panel', '', function()
        if visibleButton('adminButton') then
            call('game_admin', 'toggle')()
        end
    end },
}

function init()
    for _, entry in ipairs(keybinds) do
        local key = entry[2]
        Keybind.new(CATEGORY, entry[1], key ~= '' and { [CHAT_MODE.ON] = '', [CHAT_MODE.OFF] = key } or '', '')
        Keybind.bind(CATEGORY, entry[1], { { type = KEY_DOWN, callback = entry[3] } })
    end
end

function terminate()
    for _, entry in ipairs(keybinds) do
        Keybind.delete(CATEGORY, entry[1])
    end
end
