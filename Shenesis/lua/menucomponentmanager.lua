local OldMenuComponentManagerInit = MenuComponentManager.init
function MenuComponentManager:init()
	OldMenuComponentManagerInit(self)

	self._active_components.play_online = {
		create = callback(self, self, "_create_play_online"),
		close = callback(self, self, "close_play_online")
	}
end

local OldMenuComponentManagerInputFocus = MenuComponentManager.input_focus
function MenuComponentManager:input_focus()
	OldMenuComponentManagerInputFocus(self)

	if self._playonline_gui then
		return self._playonline_gui:input_focus()
	end
end

local OldMenuComponentManagerMouseMoved = MenuComponentManager.mouse_moved
function MenuComponentManager:mouse_moved(o, x, y)
	local wanted_pointer = "arrow"
	if (self._playonline_gui) then
		local used, pointer = self._playonline_gui:mouse_moved(o, x, y)
		wanted_pointer = pointer or wanted_pointer
		if (used) then
			return true, wanted_pointer
		end
	end

	return OldMenuComponentManagerMouseMoved(self, o, x, y)
end

local OldMenuComponentManagerMousePressed = MenuComponentManager.mouse_pressed
function MenuComponentManager:mouse_pressed(o, button, x, y)
	if (self._playonline_gui and self._playonline_gui:mouse_pressed(button, x, y)) then
		return true
	end

	return OldMenuComponentManagerMousePressed(self, o, button, x, y)
end

function MenuComponentManager:update_shenesis_server_list(data)
	if (self._playonline_gui) then
		self._playonline_gui:update_server_list(data)
	end
end

function MenuComponentManager:set_shenesis_players_online(amount)
	if (self._playonline_gui) then
		self._playonline_gui:set_players_online(amount)
	end
end

function MenuComponentManager:_create_play_online()
	self:create_play_online()
end

function MenuComponentManager:create_play_online(node)
	self:close_play_online()
	self._playonline_gui = PlayOnlineGui:new(self._ws, self._fullscreen_ws, node)
end

function MenuComponentManager:close_play_online()
	if (self._playonline_gui) then
		self._playonline_gui:close()
		self._playonline_gui = nil
	end
end