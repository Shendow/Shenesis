local menu_manager_init_orig = MenuManager.init
function MenuManager:init(is_start_menu)
	menu_manager_init_orig(self, is_start_menu)

	if (is_start_menu) then
		addCustomMenu()
	end
end

function addCustomMenu()
	local mainMenuNodes = managers.menu._registered_menus.menu_main.logic._data._nodes

	local crimenet = -1
	for id, v in pairs (mainMenuNodes["main"]._items) do
		if (v._parameters.name == "crimenet") then
			crimenet = id
			break
		end
	end

	if (crimenet == -1) then -- wat?
		return
	end

	local btn = deep_clone(mainMenuNodes.options._items[1])
	btn._parameters.name = "sh_play_online"
	btn._parameters.text_id = "play_online"
	btn._parameters.help_id = "play_online_desc"
	btn._parameters.next_node = "play_online"
	mainMenuNodes["main"]:insert_item(btn, crimenet + 1) -- After Crime.net

	local node = deep_clone(mainMenuNodes["infamytree"])
	node._parameters.name = "sh_play_online_real"
	node._parameters.help_id = "play_online_desc"
	node._parameters.topic_id = "play_online"
	node._parameters.sync_state = "play_online"
	node._parameters.menu_components[1] = "play_online"
	node._items = {}
	mainMenuNodes["play_online"] = node
end

function MenuCallbackHandler:multichoiceTest(item)
	io.write("Multichoice value: " .. tostring(item:value()) .. "\n")
end