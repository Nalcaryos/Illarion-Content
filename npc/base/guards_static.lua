require("base.factions")
require("base.common")
module("npc.base.guards_static", package.seeall)

ACTION_NONE = 0;
ACTION_WARP = 1;
ACTION_KILL = 2;

WarpPos = {};
FactionId = {};
Radius = {};

function Init(guard, factionId, warpPos, radius)
	WarpPos[guard.id] = warpPos;
	FactionId[guard.id] = factionId;
	Radius[guard.id] = radius;
end

function HandleCharacterNear(guard, char)
	-- check if char is within radius at all
	local dist = guard:distanceMetric(char);
	if (dist > Radius[guard.id]) then
		return;
	end
	local mode = GetMode(char, FactionId[guard.id]);
	if (mode == ACTION_WARP) then
		-- warp
		Warp(guard, char);
	elseif (mode == ACTION_KILL) then
		-- spawn monster guards
		-- for now: just warp
		Warp(guard, char);
	end
end

-- get the mode for this faction depending on the char's faction
function GetMode(char, factionId)
	--for testing: aggressive
	return ACTION_KILL;
	--[[
	local found, mode = ScriptVars:find("Mode_".. factionId);
	local f = base.factions.BF_get_Faction(char).tid;
	if not found then
		SetMode(factionId, f, ACTION_NONE);
		return ACTION_NONE;
	end
	mode = mode % (10^(f+1));
	mode = math.floor(mode / 10^f);
	return mode;]]
end

function SetMode(thisFaction, otherFaction, newMode)
	thisNPC:talk("SetMode. Parameters: ".. thisFaction ..";".. otherFaction ..";".. newMode);
	-- get mode for all factions
	local found, modeAll = ScriptVars:find("Mode_".. thisFaction);
	thisNPC:talk("1");
	if not found then
		modeAll = 0;
		oldMode = 0;
		thisNPC:talk("2");
	else
		-- calculate the old mode for the otherFaction
		oldMode = oldMode % (10^(otherFaction+1));
		oldMode = math.floor(oldMode / 10^f);
		thisNPC:talk("3");
	end
	-- subtract old mode
	modeAll = modeAll - (oldMode * 10^(otherFaction+1));
	-- add new mode
	modeAll = modeAll + (newMode * 10^(otherFaction+1));
	-- set ScriptVar again
	thisNPC:talk("4");
	ScriptVars:set("Mode_".. thisFaction, modeAll);
	thisNPC:talk("5");
end

function Warp(guard, char)
	char:warp(WarpPos[guard.id]);
	base.common.TempInformNLS(Char,
		"Du wurdest soeben von einer Wache der Stadt verwiesen.",
		"You've just been expelled from the town by a guard.");
end

--- checks if an admin wants to change the guard mode. Should be called in receiveText.
-- @param guard The guard character struct
-- @param speaker The speaker character struct
-- @param message The message that the guard received
function CheckAdminCommand(guard, speaker, message)
	if guard.id == speaker.id then
		return;
	end
	if not speaker:isAdmin() then
		return;
	end
	if speaker:distanceMetric(guard) > 2 then
		return;
	end
	local msg = string.lower(message);
	if string.find(msg, "set .*mode") then
		local faction = -1;
		local factionString = {};
		factionString[0] = "outcast";
		factionString[1] = "cadomyr";
		factionString[2] = "runewick";
		factionString[3] = "galmair";
		for i,s in pairs(factionString) do
			if string.find(msg, s) then
				faction = i;
			end
		end
		if faction == -1 then
			speaker:inform("#w no proper faction found. Try cadomyr, galmair, runewick or outcast.");
			return;
		end
		
		local mode = -1;
		local modeString = {};
		modeString[ACTION_NONE] = "passive";
		modeString[ACTION_WARP] = "hostile";
		modeString[ACTION_KILL] = "aggressive";
		for i,s in pairs(modeString) do
			if string.find(msg, s) then
				mode = i;
			end
		end
		if mode == -1 then
			speaker:inform("#w no proper mode found. Try passive, hostile or aggressive.");
			return;
		end
		SetMode(FactionId[guard.id], faction, mode);
		speaker:inform("#w Mode for ".. factionString[faction] .." set to ".. modeString[mode]);
	elseif string.find("help") then
		speaker:inform("#w You can set the mode for the guards by: set mode <faction> <mode>");
	end
end