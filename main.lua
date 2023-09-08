repeat task.wait() until game:IsLoaded()
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end

assert(not shared.RiseExecuted, "Rise Already Injected")
shared.RiseExecuted = true

for i,v in pairs({"risesix", "risesix/games", "risesix/profiles", "risesix/assets"}) do 
	if not isfolder(v) then makefolder(v) end
end

local gui = loadstring(readfile("risesix/gui.lua"))()
shared.risegui = gui

gui:CreateCategory("Search", gui.Fonts.RiseIcon3, "U")
gui:CreateCategory("Combat", gui.Fonts.RiseIcon1, "a")
gui:CreateCategory("Movement", gui.Fonts.RiseIcon1, "b")
gui:CreateCategory("Player", gui.Fonts.RiseIcon1, "c")
local render = gui:CreateCategory("Render", gui.Fonts.RiseIcon1, "g")
local interface = render:CreateModule("Interface", function(val) 
	for i, v in pairs(gui.Interface) do 
		v.Visible = val
	end
end, "The clients interface with all information", function() return "Modern" end, true)
interface:CreateDropdown("BackGround", function(val)
	gui.Settings.bkg = val == "Normal"
	gui:UpdateTextGUI() 
end, {"Normal", "Off"})
interface:CreateDropdown("Modules to Show", function(val) 
	gui.Settings.mode = val 
	gui:UpdateTextGUI() 
end, {"Exclude render", "All", "Only bound"})
interface:CreateToggle("Sidebar", function(val) 
	gui.Settings.sidebar = val 
	gui:UpdateTextGUI() 
end, true)
interface:CreateToggle("Suffix", function(val) 
	gui.Settings.suffix = val 
	gui:UpdateTextGUI() 
end, true)
interface:CreateToggle("Lowercase", function(val) 
	gui.Settings.lowercase = val 
	gui:UpdateTextGUI() 
end)
interface:CreateToggle("Remove spaces", function(val) 
	gui.Settings.spaces = not val 
	gui:UpdateTextGUI() 
end)
interface:CreateToggle("Toggle Notifications", function(val) 
	gui.Settings.notifs = val 
	gui:UpdateTextGUI() 
end, true)
local targetinfo = render:CreateModule("Target Info", function(callback)
	gui.TargetInfo.Visible = callback
	gui.Settings.targetinfoenabled = callback
end, "Displays information about the entity you're fighting", function() return "Modern" end)
targetinfo:CreateToggle("Follow Player", function(val) gui.targetinfofollow = val end)
gui:CreateCategory("Exploit", gui.Fonts.RiseIcon1, "a")
gui:CreateCategory("Ghost", gui.Fonts.RiseIcon1, "f")
gui:CreateCategory("Other", gui.Fonts.RiseIcon1, "e")
gui:CreateCategory("Script", gui.Fonts.RiseIcon3, "m")
gui:CreateThemeCategory("Themes", gui.Fonts.RiseIcon3, "U")
gui:CreateCategory("Language", gui.Fonts.RiseIcon3, "U")

if isfile("risesix/games/"..game.PlaceId..".lua") then 
	loadstring(readfile("risesix/games/"..game.PlaceId..".lua"))()
end
gui:Load()
gui:CreateNotification("Rise", "Reconnecting to nothing...", 5)

local teleportedServers = false
local teleportConnection = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if (not teleportedServers) then
		teleportedServers = true
		local teleportScript = [[
			loadstring(readfile("risesix/main.lua"))()
		]]
		gui:Save()
		queueonteleport(teleportScript)
    end
end)
gui.uninjectEvent.Event:Connect(function()
	if teleportConnection then teleportConnection:Disconnect() end
end)