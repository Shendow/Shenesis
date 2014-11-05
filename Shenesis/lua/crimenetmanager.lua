function CrimeNetManager:_find_online_games_shenesis(friends_only)
	if not (self._active_server_jobs_shenesis) then
		self._active_server_jobs_shenesis = {}
	end

	local function f(info)
		managers.network.matchmake:search_lobby_done()

		local room_list = info.room_list
		local attribute_list = info.attribute_list
		local dead_list = {}
		for id, _ in pairs(self._active_server_jobs_shenesis) do
			dead_list[id] = true
		end

		local servers = {}
		for i, room in ipairs(room_list) do
			local name_str = tostring(room.owner_name)
			local attributes_numbers = attribute_list[i].numbers
			if managers.network.matchmake:is_server_ok(friends_only, room.owner_id, attributes_numbers) then
				dead_list[room.room_id] = nil
				local host_name = name_str
				local level_id = tweak_data.levels:get_level_name_from_index(attributes_numbers[1] % 1000)
				local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
				local level_name = name_id and managers.localization:text(name_id) or "LEVEL NAME ERROR"
				local difficulty_id = attributes_numbers[2]
				local difficulty = tweak_data:index_to_difficulty(difficulty_id)
				local job_id = tweak_data.narrative:get_job_name_from_index(math.floor(attributes_numbers[1] / 1000))
				local kick_option = attributes_numbers[8] == 0 and 0 or 1
				local state_string_id = tweak_data:index_to_server_state(attributes_numbers[4])
				local state_name = state_string_id and managers.localization:text("menu_lobby_server_state_" .. state_string_id) or "UNKNOWN"
				local state = attributes_numbers[4]
				local num_plrs = attributes_numbers[5]
				local is_friend = false

				if Steam:logged_on() and Steam:friends() then
					for _, friend in ipairs(Steam:friends()) do
						if friend:id() == room.owner_id then
							is_friend = true
						end
					end
				end

				if name_id then
					local room = {
						room_id = room.room_id,
						id = room.room_id,
						level_id = level_id,
						difficulty = difficulty,
						difficulty_id = difficulty_id,
						num_plrs = num_plrs,
						host_name = host_name,
						state_name = state_name,
						state = state,
						level_name = level_name,
						job_id = job_id,
						is_friend = is_friend,
						kick_option = kick_option
					}
					self._active_server_jobs_shenesis[room.room_id] = room
				end
			end
		end

		for id, _ in pairs(dead_list) do
			self._active_server_jobs_shenesis[id] = nil
		end

		managers.menu_component:update_crimenet_server_list_shenesis(self._active_server_jobs_shenesis)
	end

	managers.network.matchmake:register_callback("search_lobby", f)
	managers.network.matchmake:search_lobby(friends_only)
end