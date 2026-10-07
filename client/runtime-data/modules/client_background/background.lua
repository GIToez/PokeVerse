-- private variables
local background
local clientVersionLabel

-- public functions
function init()
  background = g_ui.displayUI('background')
  background:lower()
  

  clientVersionLabel = background:getChildById('clientVersionLabel')
  clientVersionLabel:setText("Build: 0.0.1")

  if not g_game.isOnline() then
    addEvent(function() g_effects.fadeIn(clientVersionLabel, 1500) end)
    addEvent(function() g_effects.fadeIn(background, 1500) end)
  end
  modules.client_topmenu.getTopMenu():setHeight(0)
  slide1()

  connect(g_game, { onGameStart = hide })
  connect(g_game, { onGameEnd = show })
end

function terminate()
  disconnect(g_game, { onGameStart = hide })
  disconnect(g_game, { onGameEnd = show })

  g_effects.cancelFade(background:getChildById('clientVersionLabel'))
  background:destroy()

  Background = nil
end

function hide()
  background:hide()
  local name = g_game.getCharacterName()
  g_window.setTitle("Pokémon Jornadas | Jogador: "..name)
  
  modules.game_bottommenu.show()
  removeEvent(myLoopEventId1)
  removeEvent(myLoopEventId2)
  removeEvent(myLoopEventId3)
  removeEvent(myLoopEventId4)
end

function show()
  background:show()
end

function hideVersionLabel()
  background:getChildById('clientVersionLabel'):hide()
end

function setVersionText(text)
  clientVersionLabel:setText(text)
end

function ReloadCharacterTime()
local Window = "WindowReloadCharacter"
local Window2 = "BackgroundReload"
background:getChildById(Window):getChildById(Window2):getChildById("Text"):setImageSource('images/reloading/text')
background:getChildById(Window):getChildById(Window2):getChildById("Animation"):setImageSource('images/reloading/animation')
background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setImageSource('images/reloading/loadingbar_time')
background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarBorder"):setImageSource('images/reloading/loadingbar_border')
background:getChildById(Window):show()

scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 1, height = 26}) end, 100)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 5, height = 26}) end, 3500)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 37, height = 26}) end, 7000)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 69, height = 26}) end, 10500)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 101, height = 26}) end, 14000)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 133, height = 26}) end, 17500)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 165, height = 26}) end, 21000)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 197, height = 26}) end, 24500)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 229, height = 26}) end, 28000)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 261, height = 26}) end, 31500)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 293, height = 26}) end, 35000)
scheduleEvent(function() background:getChildById(Window):getChildById(Window2):getChildById("LoadingBarTime"):setSize({width = 325, height = 26}) end, 38000)

scheduleEvent(function() background:getChildById(Window):hide() end, 39500)
end

function ShowBlackWindow()
background:getChildById("blackWindow"):setVisible(true)
background:getChildById("logoAccount"):setVisible(true)
end
function HideBlackWindow()
background:getChildById("blackWindow"):setVisible(false)
background:getChildById("logoAccount"):setVisible(false)
end

function CloseInfos()
background:getChildById("BckgroundSLIDE"):setVisible(false)
background:getChildById("TitleLog"):setVisible(false)
background:getChildById("ImageSLIDE"):setVisible(false)
background:getChildById("TextSLIDE"):setVisible(false)
background:getChildById("BallSelect1"):setVisible(false)
background:getChildById("BallSelect2"):setVisible(false)
background:getChildById("BallSelect3"):setVisible(false)
background:getChildById("BallSelect4"):setVisible(false)
background:getChildById("BckgroundLOG"):setVisible(false)
background:getChildById("Facebook"):setVisible(false)
background:getChildById("Youtube"):setVisible(false)
background:getChildById("Instagram"):setVisible(false)
background:getChildById("Discord"):setVisible(false)
removeEvent(myLoopEventId1)
removeEvent(myLoopEventId2)
removeEvent(myLoopEventId3)
removeEvent(myLoopEventId4)
end
function OpenInfos()
background:getChildById("BckgroundSLIDE"):setVisible(true)
background:getChildById("ImageSLIDE"):setVisible(true)
background:getChildById("TextSLIDE"):setVisible(true)
background:getChildById("BallSelect1"):setVisible(true)
background:getChildById("BallSelect2"):setVisible(true)
background:getChildById("BallSelect3"):setVisible(true)
background:getChildById("BallSelect4"):setVisible(true)
background:getChildById("BckgroundLOG"):setVisible(true)
background:getChildById("Facebook"):setVisible(true)
background:getChildById("Youtube"):setVisible(true)
background:getChildById("Instagram"):setVisible(true)
background:getChildById("Discord"):setVisible(true)
background:getChildById("TitleLog"):setVisible(true)
end


--- looping event slidebar <> LISTA 1
function slide1()
scheduleEvent(function() background:getChildById("ImageSLIDE"):setImageSource('images/slide/image_1')end, 100)
scheduleEvent(function() background:getChildById("TextSLIDE"):setImageSource('images/slide/text_1')end, 100)
scheduleEvent(function() background:getChildById("BallSelect1"):setImageSource('images/slide/ball_white')end, 100) -- Bola 1

scheduleEvent(function() background:getChildById("BallSelect3"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect2"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect4"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4

removeEvent(myLoopEventId3)
removeEvent(myLoopEventId2)
removeEvent(myLoopEventId4)
myLoopEventId1 = scheduleEvent(slide2, 5000)
end
function slide2()
scheduleEvent(function() background:getChildById("ImageSLIDE"):setImageSource('images/slide/image_2')end, 100)
scheduleEvent(function() background:getChildById("TextSLIDE"):setImageSource('images/slide/text_2')end, 100)
scheduleEvent(function() background:getChildById("BallSelect2"):setImageSource('images/slide/ball_white')end, 100) -- Bola 1

scheduleEvent(function() background:getChildById("BallSelect1"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect3"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect4"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4

removeEvent(myLoopEventId1)
removeEvent(myLoopEventId3)
removeEvent(myLoopEventId4)

myLoopEventId2 = scheduleEvent(slide3, 5000)
end
function slide3()
scheduleEvent(function() background:getChildById("ImageSLIDE"):setImageSource('images/slide/image_3')end, 100)
scheduleEvent(function() background:getChildById("TextSLIDE"):setImageSource('images/slide/text_3')end, 100)
scheduleEvent(function() background:getChildById("BallSelect3"):setImageSource('images/slide/ball_white')end, 100) -- Bola 1

scheduleEvent(function() background:getChildById("BallSelect1"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect2"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect4"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
removeEvent(myLoopEventId1)
removeEvent(myLoopEventId2)
removeEvent(myLoopEventId4)

myLoopEventId3 = scheduleEvent(slide4, 5000)
end
function slide4()
scheduleEvent(function() background:getChildById("ImageSLIDE"):setImageSource('images/slide/image_4')end, 100)
scheduleEvent(function() background:getChildById("TextSLIDE"):setImageSource('images/slide/text_4')end, 100)
scheduleEvent(function() background:getChildById("BallSelect4"):setImageSource('images/slide/ball_white')end, 100) -- Bola 1

scheduleEvent(function() background:getChildById("BallSelect1"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect2"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4
scheduleEvent(function() background:getChildById("BallSelect3"):setImageSource('images/slide/ball_transparent')end, 100) -- Bola 4

removeEvent(myLoopEventId1)
removeEvent(myLoopEventId2)
removeEvent(myLoopEventId3)

myLoopEventId4 = scheduleEvent(slide1, 5000)
end
--- looping event slidebar <> LISTA 1

