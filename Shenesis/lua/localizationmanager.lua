SH.Localization = {
	["play_online"] = "PLAY ONLINE",
	["play_online_desc"] = "PLAY PAYDAY 2 MULTIPLAYER.",

	["play_with_anyone"] = "PLAY WITH ANYONE",
	["play_with_anyone_desc"] = "PLAY WITH RANDOM PEOPLE.",
	["play_with_friends"] = "PLAY WITH YOUR FRIENDS",
	["play_with_friends_desc"] = "PLAY WITH YOUR FRIENDS.",

	["server_x"] = "SERVER:",
	["server_state_x"] = "SERVER STATE:",
	["heist_x"] = "HEIST:",
	["difficulty_x"] = "DIFFICULTY:",

	["distance_filter"] = "DISTANCE FILTER",
	["difficulty_filter"] = "DIFFICULTY FILTER",
}

local OldLocalizationManagerText = LocalizationManager.text
function LocalizationManager:text(string_id, macros)
	return SH.Localization[string_id] or OldLocalizationManagerText(self, string_id, macros)
end