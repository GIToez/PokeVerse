UpdaterWindow = nil
UpdaterProgressBackground = nil
UpdaterProgress = nil
UpdatePercentText = nil

local download = {
    arquivosMax = 0,
    arquivos = 0,
	progress = 0,
	cancel = false,
}

function updateProgressMod()
    if download.cancel then
	    return
	end
	local progress = g_game.getUpdateProgress()
	if(download.progress ~= progress) then
		UpdaterProgress:setProgress(progress)
		download.progress = progress
	end
	
	
	if tonumber(g_game.getProgressFiles()) == tonumber(download.arquivosMax) then
		
		download.arquivos = 0
		download.arquivosMax = 0
		g_game.setProgressFiles(0)
		scheduleEvent(g_game.updOtcCreateFiles, 10)
		scheduleEvent(UpdaterWindow:setVisible(false), 1000)
		scheduleEvent(rootWidget:getChildById("enterGame"):show(), 1000)
		return
	end

	scheduleEvent(updateProgressMod, 100)
end

function updateProgress()
    if download.cancel then
	    return
	end
	
	local progress = g_game.getUpdateProgress()
	if(progress ~= 100 and g_game.getProgressFiles() == 0) then
		UpdaterProgress:setProgress(progress)
		download.progress = progress
		
	elseif progress == 100 then
	    g_game.updOtcCreateFiles()
	    download.arquivosMax = g_game.updaterVerificClient()
	    g_game.setUpdateProgress(0)
		download.progress = 0
		g_game.setProgressFiles(0)
		
		if download.arquivosMax > 0 then
			scheduleEvent(g_game.updaterClient, 1000)
			scheduleEvent(updateProgressMod, 1000)
			UpdaterWindow:getChildById("labelM"):setText("Baixando arquivos de atualização.")
            UpdaterWindow:getChildById("EnterButton"):setImageSource('images/download')
	        doCloseSubs()
		end
		if download.arquivosMax == 0 then
		    hide()
		end
			
		return
	end
	doCloseSubs()
	scheduleEvent(updateProgress, 10)
end

function onGameUpdateNeeded(protocol, signature)
	download.progress = 0
	download.cancel = false

    UpdaterWindow:getChildById("labelM"):setText("Vireficando intergridade dos arquivos.")
    UpdaterWindow:getChildById("EnterButton"):setImageSource('images/loading')
	UpdaterWindow:setVisible(true)

	scheduleEvent(updateProgress, 10)
end

function onLoad()
	g_ui.importStyle('updater')
	UpdaterWindow = g_ui.createWidget('UpdaterWindow', rootWidget)

	UpdaterProgress = UpdaterWindow:getChildById("UpdaterProgress")
	UpdaterProgress.setProgress = function(widget, progress)
		UpdaterWindow:getChildById('UpdaterBarProgress'):setPercent(progress);
		UpdaterWindow:getChildById("UpdatePercentText"):setText(progress .."%");
	end

	doCloseSubs()
	g_game.setUpdateProgress(0)
	g_game.setCancelUpdaterOtc(false)
	g_game.updaterXmlClient()
	onGameUpdateNeeded(0, 0)
end

function hide()
	UpdaterWindow:hide()
	download.arquivosMax = 0
	download.arquivos = 0
	download.progress = 0
	download.cancel = true
	g_game.setCancelUpdaterOtc(true)
	g_game.setUpdateProgress(0)
	g_game.setProgressFiles(0)
	doShowSubs()
end

function onUnload()
	UpdaterWindow:destroy()
end

function doCloseSubs()
    rootWidget:getChildById("enterGame"):hide()
end
function doShowSubs()
    rootWidget:getChildById("enterGame"):show()
end