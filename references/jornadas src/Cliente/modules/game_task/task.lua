TaskWidget =
{
   Widgets =
   {
      windowButton = nil,
      window = nil,
      delayTaskWindow = nil,
      unlockRankWindow = nil
   },
   TaskButton = {}
}
TaskWidget.Ranks = {"E","D","C","B","A","S"}
TaskWidget.WidgetsButtons = {
   ["doneButtonWidget"] = "done",
   ["cancelButtonWidget"] = "cancel",
   ["acceptButtonWidget"] = "accept"
}
TaskWidget.ChangedFocus = false
TaskWidget.WindowID = "taskButton"
TaskWidget.Hotkey = "Ctrl + 0"
TaskWidget.HasPlayerBuffer = false

TaskWidget.isInArray = function(array, value)
   for _, val in pairs(array) do
      if value == val then
         return true
      end
   end
   return false
end

function toggle()           
  if not g_game.getLocalPlayer() then
     return false
  end         
   g_game.talk("/parseRank E")
   g_game.talk("/showtaskrank")
  if TaskWidget.Widgets.windowButton then        
     if TaskWidget.Widgets.windowButton:isOn() then
       TaskWidget.Widgets.window:hide()
       TaskWidget.Widgets.windowButton:setOn(false)
     else          
       local node = g_settings.getNode('firsttimeseta') or {}
       if node then
          if not node[TaskWidget.WindowID] then
             node[TaskWidget.WindowID] = true
             g_settings.setNode('firsttimeseta', node)
          end                
          if TaskWidget.Widgets.windowButton:getChildById('setaCima') then    
             TaskWidget.Widgets.windowButton:getChildById('setaCima'):destroy()
          end      
       end               
       TaskWidget.Widgets.window:show()
       TaskWidget.Widgets.windowButton:setOn(true)  
     end
  end
end

function onMiniWindowClose()    
   if TaskWidget.Widgets.delayTaskWindow then
      if TaskWidget.Widgets.delayTaskWindow.isOn then     
         TaskWidget.Widgets.delayTaskWindow.isOn = false
         TaskWidget.Widgets.delayTaskWindow:destroy()
         TaskWidget.Widgets.delayTaskWindow = nil
      end
   end
   if TaskWidget.Widgets.unlockRankWindow then    
      if TaskWidget.Widgets.unlockRankWindow.isOn then     
         TaskWidget.Widgets.unlockRankWindow.isOn = false
         TaskWidget.Widgets.unlockRankWindow:destroy()
         TaskWidget.Widgets.unlockRankWindow = nil
      end
   end    
end

function parseRank(rank)
   g_game.talk("/parseRank "..rank)
   g_game.talk("/showtaskrank")
end    

ProtocolGame.registerExtendedOpcode(GameServerOpcodes.TaskModule, 
function (protocol, opcode, buffer)   
   if TaskWidget.Widgets.window then
      TaskWidget.Widgets.panelPTaskList = TaskWidget.Widgets.window:getChildById('panelPTask'):getChildById("panelPTaskList")

      if buffer == "[resetList]" then
         for taskButton in pairs(TaskWidget.TaskButton) do 
            TaskWidget.TaskButton[taskButton]:destroy()
            TaskWidget.TaskButton[taskButton] = nil
         end
         return true
      end                          
      loadstring("__newBuffer = ".. buffer)()    
      if __newBuffer["[unlockRank]"] then 
         if not TaskWidget.Widgets.unlockRankWindow then
            TaskWidget.Widgets.unlockRankWindow = g_ui.createWidget('UnlockTaskWindow', rootWidget)  
            TaskWidget.Widgets.unlockRankWindow.isOn = true      
         end                                  
         TaskWidget.Widgets.unlockRankWindow:getChildById('unlockRankLevel'):setText("Level: "..__newBuffer["[unlockRank]"].level..".") 
         TaskWidget.Widgets.unlockRankWindow:getChildById('unlockRankPoints'):setText("Points: "..__newBuffer["[unlockRank]"].points..".")
         TaskWidget.Widgets.unlockRankWindow:getChildById('unlockRankRank'):setText("Unlocked: Rank "..__newBuffer["[unlockRank]"].rank..".")
         TaskWidget.Widgets.unlockRankWindow:getChildById('unlockRankUnlock').onClick = function()
            local p = 1
            for i=1, #TaskWidget.Ranks do           
               if TaskWidget.Ranks[i] == __newBuffer["[unlockRank]"].rank then
                  p = i
               end
            end           
            g_game.talk("/buyrank "..TaskWidget.Ranks[p+1])   
            onMiniWindowClose()      
         end 
         TaskWidget.HasPlayerBuffer = true
      end

      if __newBuffer["[TaskNaoCompleta]"] then  
		 TaskNaoCompleta()
         return true
      end  
      if __newBuffer["[MissaoAbandonada]"] then  
		 TaskAbandonada()
         return true
      end  
      if __newBuffer["[PegueiUmaMissao]"] then  
		 PegueiUmaMissao()
         return true
      end  
      if __newBuffer["[CompleteiAMissao]"] then  
		 CompleteiAMissao()
         return true
      end

      if __newBuffer["[delayTask]"] then  
         if not TaskWidget.Widgets.delayTaskWindow then
            TaskWidget.Widgets.delayTaskWindow = g_ui.createWidget('DelayTaskWindow', rootWidget)  
            TaskWidget.Widgets.delayTaskWindow.isOn = true     
         end
		local timer =__newBuffer["[delayTask]"]
		TaskWidget.Widgets.delayTaskWindow:getChildById('minutesLabel'):setText("Você deve aguardar "..convertSecondsToStrings(timer).." para fazer essa missão novamente.")
		TaskWidget.HasPlayerBuffer = true 
	  end
      if __newBuffer["[pointsHave]"] then
         TaskWidget.Widgets.window:getChildById('labelPoints'):setText(__newBuffer["[pointsHave]"])
         TaskWidget.HasPlayerBuffer = true
      end
      if __newBuffer["[unlockedRanks]"] then                  
         for i=1, #TaskWidget.Ranks do                            
            local taskRank = TaskWidget.Widgets.window:getChildById('PanelRanks'):getChildById("Rank"..TaskWidget.Ranks[i]):getChildById("RankButtonLock")
            if taskRank then
               if TaskWidget.isInArray(__newBuffer["[unlockedRanks]"], TaskWidget.Ranks[i]) then
                  taskRank:setImageSource("")
               else
                  taskRank:setImageSource("images/locked")
               end
            end
         end     
         TaskWidget.HasPlayerBuffer = true
      end      
      if TaskWidget.HasPlayerBuffer then
         TaskWidget.HasPlayerBuffer = false  
         return true
      end                                         
      for name, taskInfo in pairs(__newBuffer) do     
         local pass = false
         if TaskWidget.TaskButton[taskInfo.id] then
            pass = true
         end
         if not pass then                                        
            TaskWidget.TaskButton[taskInfo.id] = g_ui.createWidget('TaskButton', TaskWidget.Widgets.panelPTaskList)    
            TaskWidget.TaskButton[taskInfo.id].taskInfo = {doing = taskInfo.doing, kills = taskInfo.kills}
         end

         local taskCreature = TaskWidget.TaskButton[taskInfo.id]:getChildById('CreatureUIPanel')   
         --- labels ---                   
         local labelKill = TaskWidget.TaskButton[taskInfo.id]:getChildById('labelKill')                       
         local NamePoke = TaskWidget.TaskButton[taskInfo.id]:getChildById('NamePoke')
         local desc = TaskWidget.TaskButton[taskInfo.id]:getChildById('desc')                       
         local labelLevel = TaskWidget.TaskButton[taskInfo.id]:getChildById('labelLevel')                      
         local labelReward = TaskWidget.TaskButton[taskInfo.id]:getChildById('labelReward')  
         local labelPoint = TaskWidget.TaskButton[taskInfo.id]:getChildById('labelPoint')  
         --- hud (?) ---

         local backgroundType = TaskWidget.TaskButton[taskInfo.id]:getChildById('BackgroudType') 
		 
         local type1 = TaskWidget.TaskButton[taskInfo.id]:getChildById('type1')     
         local type2 = TaskWidget.TaskButton[taskInfo.id]:getChildById('type2')  
		 
         local itemSlot1 = TaskWidget.TaskButton[taskInfo.id]:getChildById('itemSlot1')
         ---------------
         if TaskWidget.TaskButton[taskInfo.id].taskButtons then
            if TaskWidget.TaskButton[taskInfo.id].taskInfo.doing ~= taskInfo.doing then
               TaskWidget.TaskButton[taskInfo.id].taskButtons:destroy()
               TaskWidget.TaskButton[taskInfo.id].taskButtons = nil
            end
         end         
         if taskInfo.doing then  --- ja aceita            
            TaskWidget.TaskButton[taskInfo.id]:setImageSource('images/window_list/type/'..TABLE_KILL[taskInfo.id].background)  

            if TABLE_KILL[taskInfo.id].type2 == "" then
                type2:setImageSource("")
            elseif TABLE_KILL[taskInfo.id].type2 then
				type2:setImageSource('images/window_list/type/type_ball/'..TABLE_KILL[taskInfo.id].type2)
            end

            backgroundType:setImageSource('images/window_list/border_on')

            if not TaskWidget.TaskButton[taskInfo.id].taskButtons then
               TaskWidget.TaskButton[taskInfo.id].taskButtons = g_ui.createWidget('TaskDoneCancel', TaskWidget.TaskButton[taskInfo.id]) 
            end
         else  --- para aceitar                                 
            TaskWidget.TaskButton[taskInfo.id]:setImageSource('images/window_list/type/'..TABLE_KILL[taskInfo.id].background)

            backgroundType:setImageSource('images/window_list/border_off')

            if not TaskWidget.TaskButton[taskInfo.id].taskButtons then
               TaskWidget.TaskButton[taskInfo.id].taskButtons = g_ui.createWidget('TaskAccept', TaskWidget.TaskButton[taskInfo.id]) 
            end
         end    
         TaskWidget.TaskButton[taskInfo.id].taskInfo.doing = taskInfo.doing        
         for name, response in pairs(TaskWidget.WidgetsButtons) do  
            if TaskWidget.TaskButton[taskInfo.id].taskButtons then 
               if TaskWidget.TaskButton[taskInfo.id].taskButtons:getChildById(name) then  
                  TaskWidget.TaskButton[taskInfo.id].taskButtons:getChildById(name).id = taskInfo.id     
                  TaskWidget.TaskButton[taskInfo.id].taskButtons:getChildById(name).onClick = function()
                     g_game.talk("/task "..response..","..TaskWidget.TaskButton[taskInfo.id].taskButtons:getChildById(name).id)
                  end 
               end
            end
         end
         if taskInfo.id then   
            for i=1,#taskInfo.id do
               local taskOutfit = g_ui.createWidget('TaskOutfit', taskCreature)
               taskOutfit:setOutfit({type=POKE_SPRITE[taskInfo.id]})
            end
            labelKill:setText("- "..tostring(taskInfo.kills).."/"..tostring(taskInfo.count))
            labelLevel:setText("Lv."..taskInfo.level)
            labelReward:setText("Experiência: "..taskInfo.reward.."+")      
            labelPoint:setText("Pontos de caça: "..taskInfo.point)   
            NamePoke:setText(CORRECT_NAME[taskInfo.id])   
            taskCreature:setWidth(36) 
            desc:setText(POKE_DESCRIPTION[taskInfo.id])
			
			itemSlot1:setItemId(33448)
			itemSlot1:setTooltip("Hunter Token")

            if TABLE_KILL[taskInfo.id].type1 then
                type1:setImageSource('images/window_list/type/type_ball/'..TABLE_KILL[taskInfo.id].type1)
                type1:setTooltip(TABLE_KILL[taskInfo.id].type1)
            else
                type1:setImageSource("")
                type1:setTooltip("")
            end
            if TABLE_KILL[taskInfo.id].type2 == "" then
                type2:setImageSource("")
                type2:setTooltip("")
            elseif TABLE_KILL[taskInfo.id].type2 then
				type2:setImageSource('images/window_list/type/type_ball/'..TABLE_KILL[taskInfo.id].type2)
                type2:setTooltip(TABLE_KILL[taskInfo.id].type2)
            end

         end
      end
   end
   return true
end
)
function hideMiniWindow()
  TaskWidget.Widgets.window:getChildById("WindowAlert"):hide()
  TaskWidget.Widgets.window:getChildById("BackgroundBlack"):hide()
end

function TaskNaoCompleta()
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/exclaming") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/nao_completa") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):show()
    TaskWidget.Widgets.window:getChildById("BackgroundBlack"):show()
end
function TaskAbandonada()
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/exclaming") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/missao_cancelada") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):show()
    TaskWidget.Widgets.window:getChildById("BackgroundBlack"):show()
end  
function PegueiUmaMissao()
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/exclaming") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/peguei_missao") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):show()
    TaskWidget.Widgets.window:getChildById("BackgroundBlack"):show()
end  
function CompleteiAMissao()
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageSource("images/alert/exclaming") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("SlotItem"):setImageColor("#faff00") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("desc"):setImageSource("images/alert/texto/completei") 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):getChildById("Cancelar").onClick = function() hideMiniWindow() end 
	TaskWidget.Widgets.window:getChildById("WindowAlert"):show()
    TaskWidget.Widgets.window:getChildById("BackgroundBlack"):show()
end  

function online()
   TaskWidget.Widgets.window = g_ui.createWidget('TaskWindow', rootWidget) 
   TaskWidget.Widgets.windowButton = modules.client_topmenu.addRightGameToggleButton(TaskWidget.WindowID, tr('Task') .. ' ('..TaskWidget.Hotkey..')', 'images/window_list/slotitem', toggle, true, true)
   TaskWidget.Widgets.windowButton:setOn(false)
   TaskWidget.Widgets.window:hide()      
end

function offline()
   for widget in pairs(TaskWidget.Widgets) do
      if TaskWidget.Widgets[widget] ~= nil then
         TaskWidget.Widgets[widget]:destroy()
         TaskWidget.Widgets[widget] = nil
      end
   end
   return true
end

function init()
   g_ui.importStyle('task')    
   connect(g_game, { onGameStart = online, onGameEnd = offline })
   if g_game.getLocalPlayer() then
      online()
   end     
   g_keyboard.bindKeyDown(TaskWidget.Hotkey, toggle)
end

function hide()
   if TaskWidget.Widgets.window then
      TaskWidget.Widgets.window:hide()
      TaskWidget.Widgets.windowButton:setOn(false) 
   end
end

function terminate()     
   ProtocolGame.unregisterExtendedOpcode(GameServerOpcodes.TaskModule)
   offline()        
end
function convertSeconds(seconds)
  local hours = 0
  local minutes = 0
  repeat
    if seconds >= 60 then
	  minutes = minutes + 1; seconds = seconds - 60
	elseif minutes >= 60 then
	  hours = hours + 1; minutes = minutes - 60
	end
  until seconds < 60 and minutes < 60
  return {hours = hours, seconds = seconds, minutes = minutes}
end
function convertSecondsToStrings(seconds)
  local time = convertSeconds(tonumber(seconds))
  return (time.hours > 0 and time.hours.."d " or "") .. (time.minutes > 0 and time.minutes.."h " or "") .. time.seconds.."m"
end