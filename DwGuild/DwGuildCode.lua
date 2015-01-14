--[[ Downwinds Addons

DwGuild-
A small collection of commands that are useful for a Guild leader.

--]]
local appName = "|cFF0000FFDwGuild:|r ";
local noteError = "Requires permission to edit notes";
local motdInfo = "This command sets the Guild MOTD, turns on and off the repeater, and sets the interval to repeat it.";
local noteInfo = "This command replaces all guild officer or public notes with a new note.";

local repeatRate
local wasOn

local DwGuildFrame = CreateFrame("FRAME") DwGuildFrame:Hide()
DwGuildFrame:RegisterEvent("ADDON_LOADED")

function DwGuildFrame:OnEvent(event,arg1,...)

	if (event == "ADDON_LOADED" and arg1 == "DwGuild") then
		
		DwGuildFrame:UnregisterEvent("ADDON_LOADED")
		
		if (DwGuildConfigValues == nil) then DwGuildConfigValues = {nil} end
		if (DwGuildConfigValues.Interval == nil) then DwGuildConfigValues.Interval = 600 end
		if (DwGuildConfigValues.TimerON == nil) then DwGuildConfigValues.TimerON = false end

	end
end		
DwGuildFrame:SetScript("OnEvent", DwGuildFrame.OnEvent);
		
--Register Slash Command for main HELP.
SLASH_DWGUILD1, SLASH_DWGUILD2, SLASH_DWGUILD3 = "/dwg", "/DWG", "/DwGuild";
SlashCmdList["DWGUILD"] = function(msg, editbox)
print(appName.. "Command List");
print(appName.. "/DWG = This menu.");
print(appName.. "/DWGnote = ".. noteInfo);
print(appName.. "/DWGmotd = ".. motdInfo);
end

--Register Slash Command for Guild note re-placer. 
SLASH_GUILDNOTE1 = "/DWGnote";
SlashCmdList["GUILDNOTE"] = function(note)
local command, rest = note:match("^(%S*)%s*(.-)$");

 -- Handle officer note.
 if command == "officer" and rest ~= "" then
	if CanEditOfficerNote() then
		for i = 1, GetNumGuildMembers() do
		GuildRosterSetOfficerNote(i, rest)
		end
	else
		print(appName.. ": ".. noteError);
	end
 
 -- Handle public note.  
 elseif command == "public" and rest ~= "" then
	if CanEditPublicNote() then
		for i = 1, GetNumGuildMembers() do
		GuildRosterSetPublicNote(i, rest)
		end
	else
		print(appName.. ": ".. noteError);
	end
	
 else
  -- If not handled above.
  print(appName.. noteInfo);
  print("Syntax: /DWGnote (officer|public) The new note.");
 end
end

--Register Slash Command for Guild MOTD.
SLASH_GUILDMOTD1 = "/DWGmotd";
SlashCmdList["GUILDMOTD"] = function(msg)
local command, rest = msg:match("^(%S*)%s*(.-)$");

--Handle Set MOTD.
 if command == "set" and rest ~= "" then
	if CanEditMOTD() then
		GuildSetMOTD(rest)
	end
	
--Handle Repeat On.
 elseif command == "on" then
	DwGuildConfigValues.TimerON = true;
	repeatRate = DwGuildConfigValues.Interval;
	print(appName.. "Guild MOTD repeating is now ON.")
	
--Handle Repeat Off.
 elseif command == "off" then
	DwGuildConfigValues.TimerON = false;
	print(appName.. "Guild MOTD repeating is now OFF.")

--Handle Repeat rate.
 elseif command == "rate" and rest ~= "" then
	if DwGuildConfigValues.TimerON == true then 
		DwGuildConfigValues.TimerON = false;
		wasOn = true;	
	end
	
	if rest == "5" then DwGuildConfigValues.Interval = 300 
	elseif rest == "10" then DwGuildConfigValues.Interval = 600 
	elseif rest == "15" then DwGuildConfigValues.Interval = 900 
	elseif rest == "30" then DwGuildConfigValues.Interval = 1800 
	elseif rest == "60" then DwGuildConfigValues.Interval = 3600 
	else print(appName.. "Valid rates are 5 10 15 30 or 60");
	end

	print(appName.. "Guild MOTD repeater rate is set to: ".. SecondsToTime(DwGuildConfigValues.Interval, true));
	
	if wasOn then DwGuildConfigValues.TimerON = true;
		wasOn = false
	print(appName.. "Repeating was on, restarting Guild MOTD repeater at new rate.");
	end

--If not handled above.
 else 
	print(appName.. motdInfo);
	if DwGuildConfigValues.TimerON then
		print(appName.. "MOTD repeater is Enabled.");
	else 
		print(appName.. "MOTD repeater is Disabled.") 
	end
	print(appName.. "Guild MOTD repeater rate is set to: ".. SecondsToTime(DwGuildConfigValues.Interval, true));
	print("Syntax: /DWGmotd (set | on,off | rate) Message of the Day or Interval");
 end
end


--MOTD Repeater function
local total = 0 
local motd 
local function onUpdate(self,elapsed)
    total = total + elapsed
	if DwGuildConfigValues.TimerON and CanEditMOTD() then
		if total >= repeatRate then
			motd = GetGuildRosterMOTD();
			GuildSetMOTD(motd);
		
			total = 0
		end
	end
end
 
local f = CreateFrame("frame")
f:SetScript("OnUpdate", onUpdate)