require("lib/managers/menu/WalletGuiObject")

local is_win_32 = SystemInfo:platform() == Idstring("WIN32")

PlayOnlineGui = PlayOnlineGui or class()
function PlayOnlineGui:init(ws, fullscreen_ws, node)
	managers.menu:active_menu().renderer.ws:hide()

	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	managers.menu_component:close_contract_gui()

	self:_setup()
	self:set_layer(1000)
end

function PlayOnlineGui:start_finding_servers()
	if (self.server_list_panels) then
		for id, pnl in pairs (self.server_list_panels) do
			self.list_panel:remove(pnl)
		end
	end

	self.server_list = {}
	self.server_list_panels = {}

	CrimeNetManager:_find_online_games_shenesis()
end

function PlayOnlineGui:update_server_list(joblist)
	if not (self.list_panel) then return end

	self.server_list = joblist
	
	local padding = 10
	local y = padding

	local amount = 0
	for id, job in pairs (joblist) do
		amount = amount + 1
		if (amount > 35) then
			break
		end
		
		local wi, he = self.list_panel:w(), 24

		local jobpnl = self.list_panel:panel({name = "jobpnl_" .. id})
		jobpnl:set_w(wi)
		jobpnl:set_h(he)
		jobpnl:set_top(y)

			local bg = jobpnl:rect({
				name = "bg", 
				color = tweak_data.screen_colors.crimenet_lines,
				layer = 17,
				blend_mode = "add"
			})
			bg:set_alpha(0)

		y = y + he
		self.server_list_panels[id] = jobpnl

			local job_tweak = tweak_data.narrative:job_data(job.job_id)
			local job_string = job.job_id and managers.localization:to_upper_text(job_tweak.name_id) or job.level_name or "NO JOB"
			
			local host_name = SH.QuickLabel(jobpnl, "host_name", job.host_name, nil, nil, nil, "center")
			local num_plrs = SH.QuickLabel(jobpnl, "num_plrs", job.num_plrs .. "/4", nil, nil, "right", "center")
			local state_name = SH.QuickLabel(jobpnl, "state_name", job.state_name, nil, nil, "right", "center")
			local level_name = SH.QuickLabel(jobpnl, "level_name", utf8.to_upper(job_string), nil, nil, "right", "center")
			
			managers.gui_data:safe_to_full_16_9(host_name:world_x(), host_name:world_center_y())
			host_name:set_left(padding)
			host_name:set_center_y(jobpnl:height() * 0.5)
			
			managers.gui_data:safe_to_full_16_9(num_plrs:world_x(), num_plrs:world_center_y())
			num_plrs:set_right(jobpnl:width() - padding)
			num_plrs:set_center_y(jobpnl:height() * 0.5)

			managers.gui_data:safe_to_full_16_9(state_name:world_x(), state_name:world_center_y())
			state_name:set_right(jobpnl:width() - 30 - padding)
			state_name:set_center_y(jobpnl:height() * 0.5)

			managers.gui_data:safe_to_full_16_9(level_name:world_x(), level_name:world_center_y())
			level_name:set_right(jobpnl:width() - 185 - padding)
			level_name:set_center_y(jobpnl:height() * 0.5)
	end
end

function PlayOnlineGui:update_server_info(job)
	local heistpnl = self.heistpnl

	local job_tweak = tweak_data.narrative:job_data(job.job_id)
	local job_string = job.job_id and managers.localization:to_upper_text(job_tweak.name_id) or job.level_name or "NO JOB"
	local briefing_string = job.job_id and managers.localization:to_upper_text(job_tweak.briefing_id) or "NO BRIEFING"

	if not (job_tweak.briefing_id) then
		SH.PrintTable(job_tweak)
		print("--------")
	end
	
	local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[tweak_data.difficulties[job.difficulty_id]])
	
	if (self._server_label) then
		heistpnl:remove(self._server_label)
		self._server_label = nil
	end

	if (self._server_state_label) then
		heistpnl:remove(self._server_state_label)
		self._server_state_label = nil
	end

	if (self._heist_label) then
		heistpnl:remove(self._heist_label)
		self._heist_label = nil
	end

	if (self._difficulty_label) then
		heistpnl:remove(self._difficulty_label)
		self._difficulty_label = nil
	end

	if (self._briefing_label) then
		heistpnl:remove(self._briefing_label)
		self._briefing_label = nil
	end

	local host_name = SH.QuickLabel(heistpnl, "host_name", job.host_name, nil, tweak_data.screen_colors.button_stage_2)
	host_name:set_top(self.server_label:top())
	host_name:set_left(self.server_label:left() + 57)
	self._server_label = host_name

	local state_name = SH.QuickLabel(heistpnl, "state_name", job.state_name, nil, tweak_data.screen_colors.button_stage_2)
	state_name:set_top(self.server_state_label:top())
	state_name:set_left(self.server_state_label:left() + 98)
	self._server_state_label = state_name

	local level_name = SH.QuickLabel(heistpnl, "level_name", job_string, nil, tweak_data.screen_colors.button_stage_2)
	level_name:set_top(self.heist_label:top())
	level_name:set_left(self.heist_label:left() + 44)
	self._heist_label = level_name

	local difficulty = SH.QuickLabel(heistpnl, "difficulty", difficulty_string, nil, tweak_data.screen_colors.button_stage_2)
	difficulty:set_top(self.difficulty_label:top())
	difficulty:set_left(self.difficulty_label:left() + 79)
	self._difficulty_label = difficulty

	local briefing = heistpnl:text({
		name = "objective_text",
		text = briefing_string,
		layer = 1,
		align = "left",
		vertical = "top",
		font_size = tweak_data.hud.small_font_size,
		font = tweak_data.hud.small_font,
		w = heistpnl:w() - 20,
		h = heistpnl:h(),
		x = self.difficulty_label:left(),
		y = self.difficulty_label:top() + 36,
		wrap = true,
		word_wrap = true
	})
	self._briefing_label = briefing
	
	-- local briefing = SH.QuickLabel(heistpnl, "briefing", briefing_string, nil, tweak_data.screen_colors.button_stage_2)
	-- briefing:set_top(self.difficulty_label:top() + 24)
	-- briefing:set_left(self.difficulty_label:left())
	-- self._briefing_label = briefing
end

function PlayOnlineGui:set_players_online(amount)
	if not (self.heisters_label) then return end

	local txt = utf8.to_upper(managers.localization:text("heisters_x")) .. managers.money:add_decimal_marks_to_string(string.format("%.3d", amount))
	self.heisters_label:set_text(txt)
end

function PlayOnlineGui:_setup()
	if (alive(self._panel)) then
		self._ws:panel():remove(self._panel)
	end

	self:start_finding_servers()

	self._panel = self._ws:panel():panel({
		visible = true,
		layer = self._init_layer,
		valign = "center"
	})

	self._fullscreen_panel = self._fullscreen_ws:panel():panel()
	WalletGuiObject.set_wallet(self._panel)

	local title_text = SH.QuickLabel(self._panel, "play_online", utf8.to_upper(managers.localization:text("play_online")), "large")

		local title_bg_text = self._fullscreen_panel:text({
			name = "play_online",
			text = utf8.to_upper(managers.localization:text("play_online")),
			h = 90,
			align = "left",
			vertical = "top",
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3,
			alpha = 0.4,
			blend_mode = "add",
			layer = 1
		})

	local x, y = managers.gui_data:safe_to_full_16_9(title_text:world_x(), title_text:world_center_y())
	title_bg_text:set_world_left(x)
	title_bg_text:set_world_center_y(y)
	title_bg_text:move(-13, 9)
	MenuBackdropGUI.animate_bg_text(self, title_bg_text)

	local HEIST_INFO_WIDTH = 0.35
	local HEIST_LIST = 1 - HEIST_INFO_WIDTH
	local MARGIN = 10

	local heistpnl = self._panel:panel({name = "heistpnl"})
	heistpnl:set_w(math.round(self._panel:w() * HEIST_INFO_WIDTH))
	heistpnl:set_h(math.round(self._panel:h() * 0.75))
	heistpnl:set_top(title_text:bottom() + 32)
	self.heistpnl = heistpnl
	BoxGuiObject:new(heistpnl, {sides = {1, 1, 1, 1}})

		local padding = 10
	
		local server_label = SH.QuickLabel(heistpnl, "server_x", utf8.to_upper(managers.localization:text("server_x")))
		self.server_label = server_label
		local server_state_label = SH.QuickLabel(heistpnl, "server_state_x", utf8.to_upper(managers.localization:text("server_state_x")))
		self.server_state_label = server_state_label
		local heist_label = SH.QuickLabel(heistpnl, "heist_x", utf8.to_upper(managers.localization:text("heist_x")))
		self.heist_label = heist_label
		local difficulty_label = SH.QuickLabel(heistpnl, "difficulty_x", utf8.to_upper(managers.localization:text("difficulty_x")))
		self.difficulty_label = difficulty_label
		
		local y = padding
		
		managers.gui_data:safe_to_full_16_9(server_label:world_x(), server_label:world_center_y())
		server_label:move(padding, y)
		y = y + server_label:height()
		
		managers.gui_data:safe_to_full_16_9(server_state_label:world_x(), server_state_label:world_center_y())
		server_state_label:move(padding, y)
		y = y + server_state_label:height()
		
		managers.gui_data:safe_to_full_16_9(heist_label:world_x(), heist_label:world_center_y())
		heist_label:move(padding, y)
		y = y + heist_label:height()
		
		managers.gui_data:safe_to_full_16_9(difficulty_label:world_x(), difficulty_label:world_center_y())
		difficulty_label:move(padding, y)
		y = y + difficulty_label:height()

	local listpnl = self._panel:panel({name = "listpnl"})
	listpnl:set_w(math.round(self._panel:w() * HEIST_LIST - MARGIN))
	listpnl:set_h(math.round(self._panel:h() * 0.75))
	listpnl:set_top(title_text:bottom() + 32)
	listpnl:set_left(heistpnl:right() + MARGIN)
	self.list_panel = listpnl
	BoxGuiObject:new(listpnl, {sides = {1, 1, 1, 1}})

			self._list_scroll_bar_panel = self._panel:panel({
				name = "list_scroll_bar_panel",
				w = 20,
				h = listpnl:h()
			})
			self._list_scroll_bar_panel:set_world_left(listpnl:world_right())
			self._list_scroll_bar_panel:set_world_top(listpnl:world_top())
			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			local scroll_up_indicator_arrow = self._list_scroll_bar_panel:bitmap({
				name = "scroll_up_indicator_arrow",
				texture = texture,
				texture_rect = rect,
				layer = 2,
				color = Color.white
			})
			scroll_up_indicator_arrow:set_center_x(self._list_scroll_bar_panel:w() * 0.5)
			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			local scroll_down_indicator_arrow = self._list_scroll_bar_panel:bitmap({
				name = "scroll_down_indicator_arrow",
				texture = texture,
				texture_rect = rect,
				layer = 2,
				color = Color.white,
				rotation = 180
			})
			scroll_down_indicator_arrow:set_bottom(self._list_scroll_bar_panel:h())
			scroll_down_indicator_arrow:set_center_x(self._list_scroll_bar_panel:w() * 0.5)
			local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()
			self._list_scroll_bar_panel:rect({
				color = Color.black,
				alpha = 0.05,
				y = scroll_up_indicator_arrow:bottom(),
				h = bar_h,
				w = 4
			}):set_center_x(self._list_scroll_bar_panel:w() * 0.5)
			bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
			local scroll_bar = self._list_scroll_bar_panel:panel({
				name = "scroll_bar",
				layer = 2,
				h = bar_h
			})
			local scroll_bar_box_panel = scroll_bar:panel({
				name = "scroll_bar_box_panel",
				w = 4,
				halign = "scale",
				valign = "scale"
			})
			self._list_scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
				sides = {
					2,
					2,
					0,
					0
				}
			})
			self._list_scroll_bar_box_class:set_aligns("scale", "scale")
			scroll_bar_box_panel:set_w(8)
			scroll_bar_box_panel:set_center_x(scroll_bar:w() * 0.5)
			scroll_bar:set_top(scroll_up_indicator_arrow:top())
			scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())

		local y = padding

		--[[
		local distance_label = SH.QuickLabel(listpnl, "distance_filter", utf8.to_upper(managers.localization:text("distance_filter")))
		local difficulty_label = SH.QuickLabel(listpnl, "difficulty_filter", utf8.to_upper(managers.localization:text("difficulty_filter")))
		
		managers.gui_data:safe_to_full_16_9(distance_label:world_x(), distance_label:world_center_y())
		distance_label:move(padding + 20, y)
		y = y + distance_label:height()
		
		managers.gui_data:safe_to_full_16_9(difficulty_label:world_x(), difficulty_label:world_center_y())
		difficulty_label:move(padding + 20, y)
		y = y + difficulty_label:height()
		]]--

	local bottompnl = self._panel:panel({name = "bottompnl"})
	bottompnl:set_w(self._panel:w())
	bottompnl:set_h(32)
	bottompnl:set_top(listpnl:bottom() + MARGIN)
	bottompnl:set_left(heistpnl:left())
	self.bottom_panel = bottompnl
	BoxGuiObject:new(bottompnl, {sides = {1, 1, 1, 1}})

		local heisters_label = SH.QuickLabel(bottompnl, "heisters_x", utf8.to_upper(managers.localization:text("heisters_x")) .. "0")
		self.heisters_label = heisters_label

		managers.gui_data:safe_to_full_16_9(heisters_label:world_x(), heisters_label:world_center_y())
		heisters_label:set_left(padding)
		heisters_label:set_center_y(bottompnl:height() * 0.5)

		local update_text = bottompnl:text({
			name = "update_button",
			text = utf8.to_upper(managers.localization:text("update")),
			align = "right",
			vertical = "center",
			h = tweak_data.menu.pd2_small_font_size,
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			blend_mode = "add",
			color = tweak_data.screen_colors.button_stage_3
		})
		
		update_text:set_right(bottompnl:width() - padding)
		update_text:set_center_y(bottompnl:height() * 0.5)

	if (managers.menu:is_pc_controller()) then
		local back_text = self._panel:text({
			name = "back_button",
			text = utf8.to_upper(managers.localization:text("menu_back")),
			align = "right",
			vertical = "bottom",
			h = tweak_data.menu.pd2_large_font_size,
			font_size = tweak_data.menu.pd2_large_font_size,
			font = tweak_data.menu.pd2_large_font,
			blend_mode = "add",
			color = tweak_data.screen_colors.button_stage_3
		})
		local _, _, w, h = back_text:text_rect()
		back_text:set_size(w, h)
		back_text:set_position(math.round(back_text:x()), math.round(back_text:y()))
		back_text:set_right(self._panel:w())
		back_text:set_bottom(self._panel:h())
		local bg_back = self._fullscreen_panel:text({
			name = "back_button",
			text = utf8.to_upper(managers.localization:text("menu_back")),
			h = 90,
			align = "right",
			vertical = "bottom",
			blend_mode = "add",
			font_size = tweak_data.menu.pd2_massive_font_size,
			font = tweak_data.menu.pd2_massive_font,
			color = tweak_data.screen_colors.button_stage_3,
			alpha = 0.4,
			layer = 1
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())
		bg_back:set_world_right(x)
		bg_back:set_world_center_y(y)
		bg_back:move(13, -9)
		MenuBackdropGUI.animate_bg_text(self, bg_back)
	end

	local black_rect = self._fullscreen_panel:rect({
		color = Color(0.4, 0, 0, 0),
		layer = 1
	})

	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h(),
		render_template = "VertexColorTexturedBlur3D",
		layer = -1
	})

	local func = function(o)
		over(0.6, function(p)
			o:set_alpha(p)
		end)
	end
	blur:animate(func)
end

function PlayOnlineGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function PlayOnlineGui:input_focus()
	return 1
end

function PlayOnlineGui:mouse_moved(o, x, y)
	if (managers.menu:is_pc_controller()) then
		local back_button = self._panel:child("back_button")
		if (back_button:inside(x, y)) then
			if not self._back_highlight then
				self._back_highlight = true
				back_button:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end
		else
			self._back_highlight = false
			back_button:set_color(tweak_data.screen_colors.button_stage_3)
		end

		local update_button = self.bottom_panel:child("update_button")
		if (update_button:inside(x, y)) then
			if not self._update_highlight then
				self._update_highlight = true
				update_button:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end
		else
			self._update_highlight = false
			update_button:set_color(tweak_data.screen_colors.button_stage_3)
		end

		-- Recipe for bad lags?
		for id, pnl in pairs (self.server_list_panels) do
			local x2, y2 = pnl:world_left(), pnl:world_top()
		
			local bg = pnl:child("bg")
			if (self.list_panel and self.list_panel:inside(x2, y2) and pnl:inside(x, y)) then
				local job = self.server_list[id]
				if (job) then
					if (bg) then
						bg:set_alpha(0.1)
					end

					self:update_server_info(job)
				end
			else
				if (bg) then
					bg:set_alpha(0)
				end
			end
		end
	end

	if (self._panel:inside(x, y)) then
		return true
	end
end
function PlayOnlineGui:mouse_pressed(button, x, y)
	if (button == Idstring("0")) then
		if (self._panel:child("back_button"):inside(x, y)) then
			managers.menu:back()
			return
		end

		if (self.bottom_panel:child("update_button"):inside(x, y)) then
			self:start_finding_servers()
			return
		end

		for id, pnl in pairs (self.server_list_panels) do
			local x2, y2 = pnl:world_left(), pnl:world_top()
			if (self.list_panel and self.list_panel:inside(x2, y2)) then
				if (pnl:inside(x, y)) then
					local job = self.server_list[id]
					managers.network.matchmake:join_server_with_check(job.room_id)

					break
				end
			end
		end
	end
end

function PlayOnlineGui:confirm_pressed()
	return false
end

function PlayOnlineGui:close()
	self.server_list = {}

	managers.menu:active_menu().renderer.ws:show()
	WalletGuiObject.close_wallet(self._panel)

	self._ws:panel():remove(self._panel)
	self._fullscreen_ws:panel():remove(self._fullscreen_panel)
end
