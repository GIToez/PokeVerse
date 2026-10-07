broadcastMsg = nil
notificationsPanel = nil
catchWindow = nil

FIFO_broadcast = nil

inBroadcast = nil
event = nil


local function _getPrev(self, str, i, total)
	if i > total then
		return false
	end

	self:setText(string.sub(str, string.len(str)-self.txt_pos, string.len(str)))
	self.txt_pos = self.txt_pos + 1
			
	scheduleEvent(function() _getPrev(self, str, i+1, total) end, 50)
end

local function _getNext(self, str, i, total)
	if i > total then
		scheduleEvent(function() inBroadcast = false end, 1000)
		return false
	end

	if i == 1 then
		self:setTextAlign(AlignRightCenter)
		self.txt_pos = 1
    end
            
    if i == math.ceil((7*total)/10) then
		g_effects.fadeOut(broadcastMsg, (total-i)*50)
    end

	self:setText(string.sub(str, 0, string.len(str)-self.txt_pos))

	self.txt_pos = self.txt_pos + 1
			
	scheduleEvent(function() _getNext(self, str, i+1, total) end, 50)
end

local function _executeBroadcastNotification()
	if inBroadcast then
		return false
	end

	if #FIFO_broadcast == 0 then
		return false
	end
	
	local info = FIFO_broadcast[1]
	
	table.remove(FIFO_broadcast, 1)

	inBroadcast = true
	
	info.text = ""..info.text.."        "
    broadcastMsg:setImageColor(info.background_color)
    broadcastMsg:setOpacity(info.opacity)
    broadcastMsg:getChildById("icon"):setImageSource(info.icon)
    broadcastMsg:show()
    g_effects.fadeIn(broadcastMsg, 450)

    local label = broadcastMsg:getChildById("text")
    label:setTextAutoResize(true)
    label:setText(info.text)
    local width = label:getWidth()
    label:setTextAutoResize(false)
    label:setText("")
    
    broadcastMsg:setWidth(width + 39)
    
    label:setTextAlign(AlignLeftCenter)
    label.txt_pos = 1
    label.txt = ""
	
	scheduleEvent(function()
		_getPrev(label, info.text, 1, string.len(info.text))
	end, 50)
	
	scheduleEvent(function()
		_getNext(label, info.text, 1, string.len(info.text)+1)
	end, 60*string.len(info.text)+info.time)
end

function init()
	connect(g_game, {	onGameEnd = close	})

	ProtocolGame.registerExtendedOpcode(25, _onReceiveExtendedOpcode)

	broadcastMsg = g_ui.loadUI('broadcast_notifications', modules.game_interface.getMapPanel())
	notificationsPanel = g_ui.loadUI('notifications', modules.game_interface.getMapPanel())
	catchWindow = g_ui.displayUI("catch_window")
	
	FIFO_broadcast = {}

	inBroadcast = false
	
	event = cycleEvent(_executeBroadcastNotification, 1000)

end

function terminate()
	disconnect(g_game, {	onGameEnd = close	})
	
	if broadcastMsg then
		broadcastMsg:destroy()
		broadcastMsg = nil
	end

	if notificationsPanel then
		notificationsPanel:destroy()
		notificationsPanel = nil
	end

	if catchWindow then
		catchWindow:destroy()
		catchWindow = nil
	end

	ProtocolGame.unregisterExtendedOpcode(25)
	
	removeEvent(event)
end

local function _correctName(str)
	return string.upper(string.sub(str, 0, 1))..string.sub(str, 2, string.len(str))
end

function openFurtherInfoWindow(self)

	local balls = catchWindow:recursiveGetChildById("balls")
	balls:destroyChildren()

	local balls_tab = {"pokeball", "greatball", "superball", "ultraball", "saffariball", "moonball", "tinkerball", "soraball", "duskball", "yumeball", "taleball", "netball", "janguruball", "maguball", "fastball", "heavyball", "premierball", "deltaball"}	
	for index, ballName in pairs(balls_tab) do
		local brokes = self.information.balls[ballName]

		local ball = g_ui.createWidget("Pokeball", balls)
		ball:getChildById("pokeball"):setImageSource("images/pokeballs/"..ballName)
		ball:getChildById("balls_amount"):setText(tostring(brokes))
		ball:setTooltip(_correctName(ballName))
	end

	catchWindow:getChildById("poke_image"):setImageSource("/images/game/pokes/"..self.information.name)
	catchWindow:getChildById("mini_poke_icon"):setImageSource("/images/game/miniicons/normal/"..self.information.dex)
	catchWindow:getChildById("poke_label"):setText(_correctName(self.information.name))
	catchWindow:getChildById("exp_label"):setText(self.information.exp)
	
	local types = catchWindow:recursiveGetChildById("types")
	types:destroyChildren()
	
	for index, type in pairs(self.information.types) do
		local widget = g_ui.createWidget("UIButton", types)
		widget:setImageSource("/images/game/elements/"..type)
		widget:setTooltip(_correctName(type))
	end

	catchWindow:raise()
	catchWindow:focus()
	catchWindow:show()
end

function open()
	catchWindow:raise()
	catchWindow:focus()
	catchWindow:show()
end

function close()
	catchWindow:hide()
end

function destroy()
	if catchWindow then
		catchWindow:destroy()
		catchWindow = nil
	end
end

function remove_notification(self)
	g_effects.fadeOut(self:getParent(), 400)
	scheduleEvent(function() self:getParent():destroy() end, 500)
end

function _onReceiveExtendedOpcode(protocol, opcode, buffer)
	local info = json.parse(buffer)

	if not info then
		print(">> Error, unable to retrieve json from:"..buffer)
	end

	if info.action == "showNotification" then
		local child = g_ui.createWidget("Notification", notificationsPanel)
		child:show()

		g_effects.fadeIn(child, 350)

		if info.poke then
			child:getChildById("image"):setImageSource("/images/game/pokes/"..info.poke)
		end

		if info.image then
			child:getChildById("image"):setImageSource("images/icons/"..info.image)
		end

		child:getChildById("text"):setText(info.text)

		if info.custom then
			for index, inf in pairs(info.custom) do
				local btn = g_ui.createWidget(inf.type, child)
				btn:addAnchor(AnchorTop, 'parent', AnchorTop)
				btn:addAnchor(AnchorLeft, 'parent', AnchorLeft)
				btn:setMarginTop(inf.top)
				btn:setMarginLeft(inf.left)
				btn:setWidth(inf.width)
				btn:setHeight(inf.height)

				if inf.image then
					btn:setImageSource(inf.image)
				end

				if inf.text then
					btn:setText(inf.text)
				end

				if inf.action then
					if inf.action == "catch" then
						btn.information = inf.catch_info
						btn.onClick = openFurtherInfoWindow
					else
						btn.onClick = function(self) g_game.talk(inf.action) end
					end
				end

			end
		end
	elseif info.action == "showBroadcastNotification" then
		table.insert(FIFO_broadcast, info)
	end
end