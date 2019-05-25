local C, G = unpack(select(2, ...))

--=================================================--
-----------------    [[ Notes ]]    -----------------
--=================================================--

-- 至config.lua編輯設定

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

----------------------------
-- Power color / 能量顏色 --
----------------------------

local ColorPower = {}
for power, color in next, PowerBarColor do
	if type(power) == "string" then
		ColorPower[power] = {color.r, color.g, color.b}
	end
end

-- Text / 文本
local CreateText = function(frame, layer, font, fontsize, flag, justifyh)
	local text = frame:CreateFontString(nil, layer)
	text:SetFont(font, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

-- Style for bar / 給各個條條兒的毛絨絨框體樣式
local CreateBackdrop = function(parent, anchor, a)
    local frame = CreateFrame("Frame", nil, parent)

	local flvl = parent:GetFrameLevel()
	if flvl - 1 >= 0 then frame:SetFrameLevel(flvl-1) end

	frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)

    frame:SetBackdrop({
    edgeFile = G.glow, edgeSize = 3,
    bgFile = G.blank,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
	})
	
	if a then
		frame:SetBackdropColor(.15, .15, .15, a)
		frame:SetBackdropBorderColor(0, 0, 0)
	end

    return frame
end

-- 獲取NPC ID
local GetNPCID = function(guid)
	local id = tonumber(strmatch((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

-- 省點空間
local function multicheck(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then return true end
	end
	
	return false
end

--==================================================--
-----------------    [[ Status ]]    -----------------
--==================================================--

-- Name / 名字
local function UpdateName(unitFrame)
	local name = GetUnitName(unitFrame.displayedUnit, false) or UNKNOWN
	local level = UnitLevel(unitFrame.unit)
	local hexColor
	
	if not C.numberstyle and UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 then return end
	
	if name then
		if C.level then
			if UnitIsUnit(unitFrame.displayedUnit, "player") then
				unitFrame.name:SetText("")
			else
				if level >= (UnitLevel("player") + 5) then
					hexColor = "ff0000"
				elseif level >= (UnitLevel("player") + 3) then
					hexColor = "ff6600"
				elseif level <= (UnitLevel("player") - 3) then
					hexColor = "00ff00"
				elseif level <= (UnitLevel("player") - 5) then
					hexColor = "808080"
				else
					hexColor = "ffff00"
				end

				if level == -1 then
					unitFrame.name:SetText("|cffff0000??|r "..name)
				elseif level == UnitLevel("player") and UnitLevel("player") == MAX_PLAYER_LEVEL then
					unitFrame.name:SetText(name)
				else
					unitFrame.name:SetText("|cff"..hexColor..""..level.."|r "..name)
				end
			end
		else
			if UnitIsUnit(unitFrame.displayedUnit, "player") then
				unitFrame.name:SetText("")
			else
				unitFrame.name:SetText(name)
			end
		end
	end
end

-- Health / 血量
local function UpdateHealth(unitFrame)
	local unit = unitFrame.displayedUnit
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	local perc = cur / max
	local percT = math.floor(perc * 100 + .5)
	local r, g, b
	
	-- 血量百分比
	if C.numberstyle then
		if cur ~= max then
			--數字模式只有百分比
			unitFrame.healthperc:SetText(percT)
		else
			-- 個人資源永遠顯示血量
			if UnitIsUnit("player", unit) then
				unitFrame.healthperc:SetText("100")
			else
				unitFrame.healthperc:SetText("")
			end
		end		
	else
		-- status bar value
		unitFrame.healthBar:SetValue(perc)
		-- 不滿血顯示百分比
		if cur ~= max then
			unitFrame.healthBar.value:SetText(percT)
		else
			unitFrame.healthBar.value:SetText("")
		end
	end

	-- 血量漸變色	
  	if perc < .25 then
		r, g, b = .8, .05, 0
	elseif perc < .3 then
		r, g, b = .95, .7, .25
	else
		r, g, b = 1, 1, 1
	end
	
	if C.numberstyle then
		unitFrame.healthperc:SetTextColor(r, g, b)
	else
		unitFrame.healthBar.value:SetTextColor(r, g, b)
	end
end

-- 無拾取權匙
local function IsTapDenied(unitFrame)
	return UnitIsTapDenied(unitFrame.unit) and not UnitPlayerControlled(unitFrame.unit)
end

-- Health color / 血量顏色
local function UpdateHealthColor(unitFrame)
	local unit = unitFrame.displayedUnit
	local npcID = GetNPCID(UnitGUID(unit))
	local r, g, b
	
	if not UnitIsConnected(unit) then
		-- 離線
		r, g, b = .7, .7, .7
	else
		--職業或陣營染色
		local Class = select(2, UnitClass(unit))
		local CC = RAID_CLASS_COLORS[Class]
	
		if UnitIsPlayer(unit) and CC and C.friendlyCR and UnitReaction(unit, "player") >= 5 then
			-- 友方職業染色
			r, g, b = CC.r, CC.g, CC.b
		elseif UnitIsPlayer(unit) and CC and C.enemyCR and UnitReaction(unit, "player") <= 4 then
			-- 敵方職業染色
			r, g, b = CC.r, CC.g, CC.b
		elseif IsTapDenied(unitFrame) then
			-- 無拾取權
			r, g, b = .3, .3, .3
		else
			r, g, b = UnitSelectionColor(unit, true)
		end
	end
	
	if (r ~= unitFrame.r or g ~= unitFrame.g or b ~= unitFrame.b) then
		if C.numberstyle then
			unitFrame.name:SetTextColor(r, g, b)
		else
			unitFrame.healthBar:SetStatusBarColor(r, g, b)
			unitFrame.healthBar.bd:SetBackdropColor(r/3, g/3, b/3)
			
			if C.nameOnly then
				if UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 then
					unitFrame.name:SetTextColor(r, g, b)
				else
					unitFrame.name:SetTextColor(1, 1, 1)
				end
			end
		end
		
		unitFrame.r, unitFrame.g, unitFrame.b = r, g, b
	end
end

--==================================================--
-----------------    [[ Others ]]    -----------------
--==================================================--

----------------------
-- Highlight / 高亮 --
----------------------

local function UpdateSelectionHighlight(unitFrame)
	local unit = unitFrame.unit
	
	-- 目標高亮
	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") and C.HighlightTarget then
		unitFrame.hltarget:Show()
	else
		unitFrame.hltarget:Hide()
	end
	
	if C.HighlightMode == "Vertical" then		--垂直箭頭
		if not C.numberstyle then
			unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
		else
			if UnitHealth(unit) and UnitHealthMax(unit) and UnitHealth(unit) ~= UnitHealthMax(unit) then		-- 非滿血
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
			else																								-- 只有名字
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
			end
		end
	elseif C.HighlightMode == "Horizontal" then	--橫向箭頭
		if not C.numberstyle then
			unitFrame.hltarget:SetPoint("LEFT", unitFrame.healthBar, "RIGHT", 0, 0)
		else
			unitFrame.hltarget:SetPoint("LEFT", unitFrame.name, "RIGHT", 0, 0)
		end
	elseif C.HighlightMode == "Glow" then
		if not C.numberstyle then
			unitFrame.hltarget:SetPoint("BOTTOMLEFT", unitFrame.healthBar, "LEFT", -10, 4)
			unitFrame.hltarget:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "RIGHT", 10, 0)
		else
			unitFrame.hltarget:SetPoint("LEFT", unitFrame.name, "TOPLEFT", -16, 0)
			unitFrame.hltarget:SetPoint("RIGHT", unitFrame.name,"TOPRIGHT", 16, 0)
		end
	else
		return
	end
end

--------------------------
-- Raid mark / 團隊標記 --
--------------------------

local function UpdateRaidTarget(unitFrame)
	local icon = unitFrame.RaidTargetFrame.RaidTargetIcon
	local index = GetRaidTargetIndex(unitFrame.displayedUnit)
	
	if index then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

--===========================================================--
-----------------    [[ Update elements ]]    -----------------
--===========================================================--

local function UpdateNamePlateEvents(unitFrame)
	-- These are events affected if unit is in a vehicle
	local unit = unitFrame.unit
	local displayedUnit
	
	if unit ~= unitFrame.displayedUnit then
		displayedUnit = unitFrame.displayedUnit
	end
	
	unitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit)
end

-- Name-only mode / 名字模式
local function UpdateforNamemod(unitFrame)
	if not C.nameOnly then return end	
	local unit = unitFrame.displayedUnit
	
	if UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 and not UnitIsUnit(unit, "player") then
		if C.numberstyle then
			unitFrame.healthperc:Hide()
		else
			unitFrame.healthBar:Hide()
		end
	else
		if C.numberstyle then
			unitFrame.healthperc:Show()
		else
			unitFrame.healthBar:Show()
		end
	end
end

---------------------
-- Update them all --
---------------------

local function UpdateAll(unitFrame)
	if UnitExists(unitFrame.displayedUnit) then
		UpdateName(unitFrame)
		UpdateHealthColor(unitFrame)
		UpdateHealth(unitFrame)
		UpdateSelectionHighlight(unitFrame)
		UpdateRaidTarget(unitFrame)
		UpdateforNamemod(unitFrame)
	end
end

local function NamePlate_OnEvent(self, event, ...)
	local arg1 = ...
	if event == "PLAYER_TARGET_CHANGED" then
		UpdateName(self)
		UpdateSelectionHighlight(self)
	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdateAll(self)
	elseif arg1 == self.unit or arg1 == self.displayedUnit then
		if event == "UNIT_HEALTH_FREQUENT" then
			UpdateHealth(self)
			UpdateSelectionHighlight(self)
		elseif event == "UNIT_NAME_UPDATE" then
			UpdateName(self)
		elseif event == "UNIT_PET" then
			UpdateAll(self)
		end
	end
end

local function RegisterNamePlateEvents(unitFrame)
	unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
	unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	unitFrame:RegisterEvent("UNIT_PET")
	UpdateNamePlateEvents(unitFrame)
	unitFrame:SetScript("OnEvent", NamePlate_OnEvent)
end

local function UnregisterNamePlateEvents(unitFrame)
	unitFrame:UnregisterAllEvents()
	unitFrame:SetScript("OnEvent", nil)
end

local function SetUnit(unitFrame, unit)
	unitFrame.unit = unit
	unitFrame.displayedUnit = unit	 -- For vehicles
	unitFrame.inVehicle = false
	if unit then
		RegisterNamePlateEvents(unitFrame)
	else
		UnregisterNamePlateEvents(unitFrame)
	end
end

local NamePlateDriverFrame = NamePlateDriverFrame
local function HideBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.SetupClassNameplateBars = function() end

	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("NamePlateVerticalScale", 1)
end

local function OnUnitFactionChanged(unit)
	-- This would make more sense as a unitFrame:RegisterUnitEvent
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	
	if namePlate then
		UpdateName(namePlate.UnitFrame)
		UpdateHealthColor(namePlate.UnitFrame)
		UpdateforNamemod(namePlate.UnitFrame)
	end
end

local function OnRaidTargetUpdate()
	for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
		UpdateRaidTarget(namePlate.UnitFrame)
	end
end


local NamePlates_UpdateNamePlateOptions = NamePlates_UpdateNamePlateOptions
function NamePlates_UpdateNamePlateOptions()
	-- Called at VARIABLES_LOADED and by "Larger Nameplates" interface options checkbox(110/45)	
	
	-- DONT TOUCH THIS! 別碰這個！
	local baseNamePlateWidth = 110
	local baseNamePlateHeight = 45
	-- DONT TOUCH THIS! 別碰這個！
	
	C_NamePlate.SetNamePlateFriendlySize(baseNamePlateWidth , baseNamePlateHeight)
	C_NamePlate.SetNamePlateEnemySize(baseNamePlateWidth, baseNamePlateHeight)
	C_NamePlate.SetNamePlateSelfSize(baseNamePlateWidth, baseNamePlateHeight)

	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = namePlate.UnitFrame
		UpdateAll(unitFrame)
	end
end

--=============================================================--
-----------------    [[ Create Nameplates ]]    -----------------
--=============================================================--

local function OnNamePlateCreated(namePlate)
	namePlate.UnitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate)
	namePlate.UnitFrame:SetAllPoints(namePlate)
	namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
	
	if C.numberstyle then
	
		-- [[ 數字模式 ]] --
		
		-- 百分比
		namePlate.UnitFrame.healthperc = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
		namePlate.UnitFrame.healthperc:SetFont(G.percFont, G.fontSize * 1.75, G.fontFlag)
		namePlate.UnitFrame.healthperc:SetPoint("CENTER")
		namePlate.UnitFrame.healthperc:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.healthperc:SetShadowColor(0, 0, 0, .4)
		namePlate.UnitFrame.healthperc:SetShadowOffset(1, -1)
		namePlate.UnitFrame.healthperc:SetText("92")
		
		-- 名字
		namePlate.UnitFrame.name = CreateText(namePlate.UnitFrame, "ARTWORK", G.norFont, G.fontSize, G.fontFlag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("TOP", namePlate.UnitFrame.healthperc, "BOTTOM", 0, -3)
		namePlate.UnitFrame.name:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.name:SetText("Name")
		
		-- 團隊標記
		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 4)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(G.raidIcon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
		
		-- 目標高亮
		if C.HighlightMode == "Glow" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND", nil, -1)
			namePlate.UnitFrame.hltarget:SetTexture(G.hlGlow)
			namePlate.UnitFrame.hltarget:SetVertexColor(0, .85, 1)
			namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 0)
			namePlate.UnitFrame.hltarget:SetBlendMode("ADD")
		else
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redArrow)
			
			if C.HighlightMode == "Horizontal" then
				namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
			end
		end
		namePlate.UnitFrame.hltarget:Hide()	
	else
		-- [[ 條形模式 ]] --
		
		-- 血量條
		namePlate.UnitFrame.healthBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.healthBar:SetHeight(8)
		namePlate.UnitFrame.healthBar:SetPoint("LEFT", 0, 0)
		namePlate.UnitFrame.healthBar:SetPoint("RIGHT", 0, 0)
		namePlate.UnitFrame.healthBar:SetStatusBarTexture(G.ufbar)
		namePlate.UnitFrame.healthBar:SetMinMaxValues(0, 1)		
		namePlate.UnitFrame.healthBar.bd = CreateBackdrop(namePlate.UnitFrame.healthBar, namePlate.UnitFrame.healthBar, 1)
		
		-- 百分比
		namePlate.UnitFrame.healthBar.value = CreateText(namePlate.UnitFrame.healthBar, "OVERLAY", G.norFont, G.fontSize-4, G.fontFlag, "CENTER")
		namePlate.UnitFrame.healthBar.value:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", 0, -G.fontSize / 3)
		namePlate.UnitFrame.healthBar.value:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.healthBar.value:SetText("Value")
		
		-- 名字
		namePlate.UnitFrame.name = CreateText(namePlate.UnitFrame, "OVERLAY", G.norFont, G.fontSize-2, G.fontFlag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("BOTTOM", namePlate.UnitFrame.healthBar, "TOP", 0, 0)
		namePlate.UnitFrame.name:SetHeight(G.fontSize)
		namePlate.UnitFrame.name:SetWidth(100)
		namePlate.UnitFrame.name:SetWordWrap(false)
		namePlate.UnitFrame.name:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.name:SetText("Name")
		
		-- 目標高亮
		if C.HighlightMode == "Glow" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND", nil, -1)
			namePlate.UnitFrame.hltarget:SetTexture(G.hlGlow)
			namePlate.UnitFrame.hltarget:SetVertexColor(0, .85, 1)
			namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 0)
			namePlate.UnitFrame.hltarget:SetBlendMode("ADD")
		else
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redArrow)
			if C.HighlightMode == "Horizontal" then
				namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
			end
		end
		namePlate.UnitFrame.hltarget:Hide()
		
		-- 團隊標記
		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 4)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(G.raidIcon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()


	end
	
	namePlate.UnitFrame:EnableMouse(false)
end

-----------
-- Spawn --
-----------

local function OnNamePlateAdded(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = namePlate.UnitFrame
	SetUnit(unitFrame, unit)
	UpdateAll(unitFrame)
end

local function OnNamePlateRemoved(unit)
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	SetUnit(namePlate.UnitFrame, nil)
end

----------
-- CVar --
----------

local function defaultcvar()
	if C.Inset then
		SetCVar("nameplateOtherTopInset", .06)			-- default is 0.08
		SetCVar("nameplateOtherBottomInset", .09)		-- default is 0.1
		SetCVar("nameplateLargeTopInset", .06) 
		SetCVar("nameplateLargeBottomInset", .09)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
		SetCVar("nameplateLargeTopInset", -1) 
		SetCVar("nameplateLargeBottomInset", -1)
	end
	
	-- 最大視距
	SetCVar("nameplateMaxDistance", C.MaxDistance)		-- default is 60
	-- fix fps drop
	SetCVar("namePlateMinScale", 1)						-- default is 0.8
	SetCVar("namePlateMaxScale", 1)
	-- boss nameplate scale
	SetCVar("nameplateLargerScale", 1)					-- default is 1.2
	-- 當前目標大小
	SetCVar("nameplateSelectedScale", C.SelectedScale)
	-- 讓堆疊血條的間距小一點
	SetCVar("nameplateOverlapH",  0.6)					-- default is 0.8
	SetCVar("nameplateOverlapV",  0.9)					-- default is 1.1
	-- 非當前目標透明度
	SetCVar("nameplateMinAlpha", C.MinAlpha)			-- default is 0.8
	-- 障礙物後的名條透名度
	SetCVar("nameplateOccludedAlphaMult", 0.2)			-- default is 0.4
	-- 禁用點擊
	C_NamePlate.SetNamePlateFriendlyClickThrough(C.FriendlyClickThrough)
	C_NamePlate.SetNamePlateEnemyClickThrough(C.EnemyClickThrough)
	-- 個人資源顯示條件
	SetCVar("nameplateSelfAlpha", 1)
	SetCVar("nameplatePersonalShowAlways", 0)
	SetCVar("nameplatePersonalShowInCombat", 1)
	SetCVar("nameplatePersonalShowWithTarget", 1)
	SetCVar("nameplatePersonalHideDelaySeconds", 3)
	-- 敵方顯示條件
	SetCVar("nameplateShowEnemyGuardians", 1)			-- 守護者
	SetCVar("nameplateShowEnemyMinions", 1)				-- 僕從
	--SetCVar("nameplateShowEnemyPets", 0)				-- 寵物
	SetCVar("nameplateShowEnemyTotems", 1)				-- 圖騰
	--SetCVar("nameplateShowEnemyMinus", 1				-- 次要
	-- 友方顯示條件
	SetCVar("nameplateShowFriendlyGuardians", 0)		-- 守護者
	SetCVar("nameplateShowFriendlyMinions", 0)			-- 僕從
	SetCVar("nameplateShowFriendlyNPCs", 0)				-- npc
	SetCVar("nameplateShowFriendlyPets", 0)				-- 寵物
	SetCVar("nameplateShowFriendlyTotems", 0)			-- 圖騰
end 

------------
-- Events --
------------

local function NamePlates_OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		HideBlizzard()
	elseif event == "NAME_PLATE_CREATED" then
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unit = ...
		OnNamePlateAdded(unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "RAID_TARGET_UPDATE" then
		OnRaidTargetUpdate()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		NamePlates_UpdateNamePlateOptions()
	elseif event == "UNIT_FACTION" then
		OnUnitFactionChanged(...)
	elseif event == "PLAYER_ENTERING_WORLD" then
		defaultcvar()
	end
end

local NamePlatesFrame = CreateFrame("Frame", "NamePlatesFrame", UIParent)
	NamePlatesFrame:SetScript("OnEvent", NamePlates_OnEvent)
	NamePlatesFrame:RegisterEvent("VARIABLES_LOADED")
	NamePlatesFrame:RegisterEvent("NAME_PLATE_CREATED")
	NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	NamePlatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	NamePlatesFrame:RegisterEvent("CVAR_UPDATE")
	NamePlatesFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
	NamePlatesFrame:RegisterEvent("RAID_TARGET_UPDATE")
	NamePlatesFrame:RegisterEvent("UNIT_FACTION")
	NamePlatesFrame:RegisterEvent("UNIT_AURA")
	NamePlatesFrame:RegisterEvent("PLAYER_ENTERING_WORLD")