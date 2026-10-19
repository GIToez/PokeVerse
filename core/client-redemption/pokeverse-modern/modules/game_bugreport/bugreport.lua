-- Ctrl+Z opens the bug tab of the Reports window (game_reports). The old one-line window is only the
-- fallback when that module is not loaded.
HOTKEY = 'Ctrl+Z'

bugReportWindow = nil
bugTextEdit = nil

function init()
    g_ui.importStyle('bugreport')

    bugReportWindow = g_ui.createWidget('BugReportWindow', rootWidget)
    bugReportWindow:hide()

    bugTextEdit = bugReportWindow:getChildById('bugTextEdit')

    Keybind.new("Dialogs", "Open Bugreport", HOTKEY, "")
    Keybind.bind("Dialogs", "Open Bugreport", {
      {
        type = KEY_DOWN,
        callback = show,
      }
    }, modules.game_interface.getRootPanel())
end

function terminate()
    Keybind.delete("Dialogs", "Open Bugreport")
    bugReportWindow:destroy()
end

function doReport()
    g_game.reportBug(bugTextEdit:getText())
    bugReportWindow:hide()
    modules.game_textmessage.displayGameMessage(tr('Bug report sent.'))
end

function show()
    if not g_game.isOnline() then
        return
    end
    local reports = modules.game_reports
    if reports and reports.openBug then
        reports.openBug()
        return
    end
    bugTextEdit:setText('')
    bugReportWindow:show()
    bugReportWindow:raise()
    bugReportWindow:focus()
end
