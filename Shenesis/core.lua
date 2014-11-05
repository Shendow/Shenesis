if not (Shenesis) then
	Shenesis = true

	SH = {}
	SH.LuaPath = "Shenesis/lua/"
end

SH.HookFiles = {
	["lib/managers/menumanager"] = "menumanager.lua",
	["lib/managers/localizationmanager"] = "localizationmanager.lua",
	["lib/managers/menu/menucomponentmanager"] = {
		"menucomponentmanager.lua",
		"gui_playonline.lua",
	},
	["lib/managers/crimenetmanager"] = "crimenetmanager.lua",
}

local function file_is_readable(fname)
	local fil = io.open(fname, "r")
	if (fil ~= nil) then
		io.close(fil)
		return true
	end

	return false
end

local function istable(o)
	return type(o) == "table"
end

local function Msg(text)
	io.stderr:write(text)
end

local function MsgN(text)
	Msg(text .. "\n")
end

local function CountTable(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end

	return count
end

local function PrintTable(t, indent, done)
	done = done or {}
	indent = indent or 0

	for key, value in pairs (t) do
		Msg(string.rep("\t", indent))

		if (istable(value) and not done[value]) then
			done[value] = true
			Msg(tostring(key) .. ":" .. "\n")
			PrintTable(value, indent + 2, done)
		else
			Msg(tostring (key) .. "\t=\t")
			Msg(tostring(value) .. "\n")
		end
	end
end

local function QuickLabel(parent, name, text, font, color, xalign, yalign)
	xalign = xalign or "left"
	yalign = yalign or "top"
	font = font or "small"
	color = color or tweak_data.screen_colors.text

	return parent:text({
		name = name,
		text = text,
		align = xalign,
		vertical = yalign,
		h = tweak_data.menu["pd2_" .. font .. "_font_size"],
		font_size = tweak_data.menu["pd2_" .. font .. "_font_size"],
		font = tweak_data.menu["pd2_" .. font .. "_font"],
		color = color
	})
end

io.file_is_readable = file_is_readable
SH.Msg = Msg
SH.MsgN = MsgN
SH.PrintTable = PrintTable
SH.CountTable = CountTable
SH.QuickLabel = QuickLabel

local function SafeDoFile(fileName)
	local success, errorMsg = pcall(function()
		if (io.file_is_readable(fileName)) then
			dofile(fileName)
		else
			MsgN("[Error] Could not open file '" .. fileName .. "'! Does it exist, is it readable?")
		end
	end)

	if not (success) then
		MsgN("[Error]\nFile: " .. fileName .. "\n" .. errorMsg)
	end
end
SH.SafeDoFile = SafeDoFile

if (RequiredScript) then
	local requiredScript = RequiredScript:lower()
	local hf = SH.HookFiles[requiredScript]
	if (hf) then
		if (type(hf) == "table") then
			for _, fil in pairs (hf) do
				SafeDoFile(SH.LuaPath .. fil)
			end
		else
			SafeDoFile(SH.LuaPath .. SH.HookFiles[requiredScript])
		end
	end
end