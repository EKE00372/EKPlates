local addon, ns = ...
local oUF = ns.oUF
local C, F, G, T = unpack(ns)

--==================================================--
-----------------    [[ Colors ]]    -----------------
--==================================================--

-- [[ 職業 ]] --

oUF.colors.class["SHAMAN"] = {0, .6, 1}
oUF.colors.class["MAGE"] = {.48, .84, .94}
oUF.colors.class["DEATHKNIGHT"] = {1, .23, .23}
oUF.colors.class["DEMONHUNTER"] = {.74, .35, .95}
oUF.colors.class["EVOKER"] = {.33, .68, .68}

-- [[ 威脅 ]] --

oUF.colors.threat[0] = {.1, .7, .9} -- 非當前仇恨，低威脅值
oUF.colors.threat[1] = {.4, .1, .9} -- 非當前仇恨，但已OT即將獲得仇恨，或坦克正在獲得仇恨
oUF.colors.threat[2] = {.9, .1, .9} -- 當前仇恨，但不穩，已被OT或坦克正在丟失仇恨
oUF.colors.threat[3] = {.9, .1, .4} -- 當前仇恨，威脅值穩定

-- [[ 光環 ]] --

--oUF.colors.debuff.none = {.6, .6, .6}

-- [[ 能量 ]] --

-- 資源類型
oUF.colors.power["MANA"] = {0, .8, 1}						-- 0 法力
oUF.colors.power[0] = oUF.colors.power["MANA"]
oUF.colors.power["RAGE"] = {.9, .1, .1}						-- 1 戰士熊德 怒氣
oUF.colors.power["FOCUS"] = {.9, .5, .1}					-- 2 獵人 集中值
oUF.colors.power["ENERGY"] = {.9, .9, .1}					-- 3 盜賊武僧貓德 能量
oUF.colors.power["RUNIC_POWER"] = {.1, .9, .9}				-- 6 死騎 符能
oUF.colors.power["LUNAR_POWER"] = {0, .6, 1}				-- 8 鳥德 月能
oUF.colors.power["MAELSTROM"] = {0, .6, 1}					-- 11 薩滿旋渦值
oUF.colors.power["INSANITY"] = {.74, .35, .95}				-- 13 暗牧 瘋狂值(共用dh職業色)
oUF.colors.power["ARCANE_CHARGES"] = {0, .8, 1}				-- 16 秘法 充能
-- 載具類型
oUF.colors.power["FUEL"] = {0, .75, .7}						-- 同時用於npc無屬能量
oUF.colors.power["AMMOSLOT"] = {.8, .6, 0}
-- 幹啥用的?
oUF.colors.power["POWER_TYPE_STEAM"] = {.6, .6, .6}
oUF.colors.power["POWER_TYPE_PYRITE"] = {.70, .1, .1}

-- [[ 陣營 ]] --

oUF.colors.reaction[1] = {1, .12, .25}
oUF.colors.reaction[2] = {1, .12, .25}
oUF.colors.reaction[3] = {1, .5, .25}
oUF.colors.reaction[4] = {1, 1, 0}
oUF.colors.reaction[5] = {.26, 1, .22}
oUF.colors.reaction[6] = {.26, 1, .22}
oUF.colors.reaction[7] = {.26, 1, .22}
oUF.colors.reaction[8] = {.26, 1, .22}

--[[
	["HUNTER"] = { r = 0.58, g = 0.86, b = 0.49 },
	["WARLOCK"] = { r = 0.6, g = 0.47, b = 0.85 },
	["PALADIN"] = { r = 1, g = 0.22, b = 0.52 },
	["PRIEST"] = { r = 0.8, g = 0.87, b = .9 },
	["MAGE"] = { r = 0, g = 0.76, b = 1 },
	["MONK"] = {r = 0.0, g = 1.00 , b = 0.59},
	["ROGUE"] = { r = 1, g = 0.91, b = 0.2 },
	["DRUID"] = { r = 1, g = 0.49, b = 0.04 },
	["SHAMAN"] = { r = 0, g = 0.6, b = 0.6 };
	["WARRIOR"] = { r = 0.9, g = 0.65, b = 0.45 },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23 },
]]--

--==================================================--
-----------------    [[ Status ]]    -----------------
--==================================================--

-- [[ 任務目標 ]] --

oUF.Tags.Methods["quest"] = function(u)
	local quest = UnitIsQuestBoss(u)
	if quest then
		return "|cff8AFF30!|r"
	else
		return ""
	end
end
oUF.Tags.Events["quest"] = "UNIT_CLASSIFICATION_CHANGED"

--==================================================--
-----------------    [[ Values ]]    -----------------
--==================================================--

-- [[ 血量 ]] --

-- unitframes
oUF.Tags.Methods["unit:hp"] = function(u)
	local cur, max = UnitHealth(u), UnitHealthMax(u)
	
	if UnitIsDead(u) then
		-- 死亡
		return "|cff559655RIP|r"	-- or DEAD
	elseif UnitIsGhost(u) then
		-- 鬼魂
		return "|cff559655GHO|r"
	elseif not UnitIsConnected(u) then
		-- 離線
		return "|cff559655OFF|r"	-- or PLAYER_OFFLINE
	elseif cur < max then
		-- 不滿血顯示當前血量和百分比
		if C.verticalTarget and u == "target" then
			return F.Hex(1, 1, 0)..math.floor((cur / max * 100) + .5).."|r "..F.Hex(1, 1, 1)..F.ShortValue(cur).."|r"
		else
			return F.ShortValue(cur).." "..F.Hex(1, 1, 0)..math.floor((cur / max * 100) + .5).."|r"
		end
	elseif cur == max then
		-- 滿血顯示血量
		return F.ShortValue(cur)
	else
		return ""
	end
end
oUF.Tags.Events["unit:hp"] = "UNIT_MAXHEALTH UNIT_HEALTH UNIT_CONNECTION"

-- bar style nameplates
oUF.Tags.Methods["bp:hp"] = function(u)
	local per = oUF.Tags.Methods["perhp"](u)
	
	if UnitIsDead(u) then
		-- 死亡
		return ""
	elseif not UnitIsConnected(u) then
		-- 離線
		return ""
	elseif per == 100 then
		-- 滿血不顯示血量
		return ""
	else
		return per
	end
end
oUF.Tags.Events["bp:hp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

-- number style nameplates
oUF.Tags.Methods["np:hp"] = function(u)
	local per = oUF.Tags.Methods["perhp"](u)
	--local player = UnitIsPlayer(u)
	local reaction = UnitReaction(u, "player")
	local absorb = UnitGetTotalAbsorbs(u) or 0
	local color
	
	if per < 25 then
		color = F.Hex(.8, .05, 0)
	elseif per < 30 then
		color = F.Hex(.95, .7, .25)
	else
		color = F.Hex(1, 1, 1)
	end
	
	if reaction and reaction >= 5 then
		return ""
	else
		if UnitIsDead(u) then
			-- 死亡
			return ""
		elseif not UnitIsConnected(u) then
			-- 離線
			return ""
		elseif per == 100 then
			-- 滿血不顯示血量
			--return UnitAffectingCombat("player") and "100" or ""
			return (absorb > 0 and "+") or ""
		elseif per ~= 100 then
			return color..per.."|r"
		else
			return ""
		end
	end
end
oUF.Tags.Events["np:hp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

-- [[ 能量 ]] --

-- unitframes
oUF.Tags.Methods["unit:pp"]  = function(u)
	local cur, max = UnitPower(u), UnitPowerMax(u)
	local _, class = UnitClass(u)
	local _, type = UnitPowerType(u)
	local color = oUF.colors.power[type] or oUF.colors.power.FUEL

	if max == 0 then
		return ""
	else
		if type == "MANA" then
			-- 魔力
			return F.Hex(unpack(color))..F.ShortValue(cur).."|r"
		else
			-- 其他
			return F.Hex(unpack(color))..cur.."|r"
		end
	end
end
oUF.Tags.Events["unit:pp"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_DISPLAYPOWER"

-- nameplates
oUF.Tags.Methods["np:pp"] = function(unit)
	-- 只監控白名單的能量
	local npcID = F.GetNPCID(UnitGUID(unit))
	if not C.ShowPower[npcID] then return end
	
	local per = oUF.Tags.Methods["perpp"](unit)
	local color
	
	if per < 25 then
		color = F.Hex(.2, .2, 1)
	elseif per < 30 then
		color = F.Hex(.4, .4, 1)
	else
		color = F.Hex(.8, .8, 1)
	end
	
	per = color..per.."|r"

	return per
end
oUF.Tags.Events["np:pp"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER"

-- [[ 吸收量 ]] --

-- nameplates
oUF.Tags.Methods["np:ab"] = function(u)
	local max = UnitHealthMax(u)
	local absorb = UnitGetTotalAbsorbs(u) or 0
	
	if absorb ~= 0 then
		return F.Hex(1, .9, .4).."+"..math.floor((absorb / max * 100) + .5)
	else
		return ""
	end
end
oUF.Tags.Events["np:ab"] = "UNIT_ABSORB_AMOUNT_CHANGED"

-- [[ 名字顏色 ]] --

oUF.Tags.Methods["namecolor"] = function(u, r)
	local reaction = UnitReaction(u, "player")
	
	if UnitIsTapDenied(u) then
		return F.Hex(oUF.colors.tapped)
	elseif UnitIsPlayer(u) then
		local _, class = UnitClass(u)
		return F.Hex(oUF.colors.class[class])
	elseif reaction then
		return F.Hex(oUF.colors.reaction[reaction])
	else
		return F.Hex(1, 1, 1)
	end
end
oUF.Tags.Events["namecolor"] = "UNIT_NAME_UPDATE UNIT_FACTION"

-- [[ 單位的目標 ]] --

oUF.Tags.Methods["np:tar"] = function(unit)
	local targetUnit = unit.."target"

	if UnitExists(targetUnit) then
		local targetClass = select(2, UnitClass(targetUnit))
		return F.Hex(oUF.colors.class[targetClass])..UnitName(targetUnit)
	else
		return ""
	end
end
oUF.Tags.Events["np:tar"] = "UNIT_NAME_UPDATE UNIT_THREAT_SITUATION_UPDATE UNIT_HEALTH"


--[[
oUF.Tags.Methods["npcast"] = function(unit)
	local unitTarget = unit.."target"
	
	if UnitExists(unitTarget) and UnitIsPlayer(unitTarget) then
		local nameString
		--if UnitIsUnit(unitTarget, "player") then
			nameString = format("|cffff0000%s|r", ">"..strupper(YOU).."<")
		--else
			local _, class = UnitClass(unitTarget)
			nameString = F.Hex(oUF.colors.class[class])..">>"..UnitName(unitTarget)
		--end
		
		return nameString
	end
end
oUF.Tags.Events["npcast"] = "UNIT_SPELLCAST_START UNIT_SPELLCAST_CHANNEL_START"
]]--

--[[
oUF.Tags.Methods["np:name"] = function(u)
	local name = GetUnitName(u) or UNKNOWN
	local status = UnitThreatSituation("player", u) or false
	local reaction = UnitReaction(u, "player")
	
	if UnitIsTapDenied(u) then
		return F.Hex(oUF.colors.tapped)
	elseif UnitIsPlayer(u) then
		local _, class = UnitClass(u)
		return F.Hex(oUF.colors.class[class])
	elseif reaction and reaction >= 5 then
		return F.Hex(oUF.colors.reaction[reaction])
	elseif status then
		if status == 0 then
			return F.Hex(.1, .7, .9)
		elseif status == 1 then
			return F.Hex(.4, .1, .9)
		elseif status == 2 then
			return F.Hex(.9, .1, .9)
		elseif status == 3 then
			return F.Hex(.9, .1, .4)
		end
	else
		return F.Hex(1, 0, 0)
	end
end
oUF.Tags.Events["np:name"] = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_THREAT_SITUATION_UPDATE"
]]--