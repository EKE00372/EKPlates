local C, G = unpack(select(2, ...))

--=================================================--
-----------------    [[ Notes ]]    -----------------
--=================================================--

-- 至config.lua編輯設定

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

local function insecureOnShow(self)
	self:Hide()
end

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

--=================================================--
-----------------    [[ Auras ]]    -----------------
--=================================================--

-- Create aura timer / 光環計時
local day, hour, minute = 86400, 3600, 60
local function FormatTime(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
    end

    return format("%d", math.fmod(s, minute))
end

-- Update aura timer / 更新計時
local function AuraIconOnUpdate(self, elapsed)
	if not self.duration then return end
	
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed < .2 then return end
	self.elapsed = 0

	local timeLeft = self.expirationTime - GetTime()
	if timeLeft <= 0 then
		self.text:SetText(nil)
	else
		self.text:SetText(FormatTime(timeLeft))
	end
end

-- Update aura icon / 更新光環
local function UpdateAuraIcon(button, unit, index, filter)
	local name, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	button.icon:SetTexture(icon)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	button.name = name
	
	local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
	button.overlay:SetVertexColor(color.r, color.g, color.b)

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	button:SetScript("OnUpdate", AuraIconOnUpdate)	
	button:Show()
end

-- Aura filter / 過濾器
local function AuraFilter(caster, spellid, nameplateShowAll)
	if C.showMyAuras and multicheck(caster, "player", "pet", "vehicle") then
		if C.BlackList[spellid] then
			return false
		else
			return true
		end
	elseif C.showOtherAuras and not multicheck(caster, "player", "pet", "vehicle") then
		if C.BlackList[spellid] then
			return false
		elseif C.WhiteList[spellid] then
			return true
		else
			return nameplateShowAll
		end
	else
		return false
	end
end

-- Show aura and sort anchor / 顯示圖示並排列
local function UpdateBuffs(unitFrame)
	if not unitFrame.icons or not unitFrame.displayedUnit then return end	
	if UnitIsUnit(unitFrame.displayedUnit, "player") then return end
	local unit = unitFrame.displayedUnit
	local i = 1
	
	for index = 1, 15 do
		if i <= C.auraNum then
			local bname, _, _, _, bduration, _, bcaster, _, _, bspellid, _, _, _, nameplateShowAll = UnitAura(unit, index, "HELPFUL")
			local matchbuff = AuraFilter(bcaster, bspellid, nameplateShowAll)
			
			if bname and matchbuff then
				if not unitFrame.icons[i] then					
					unitFrame.icons[i] = unitFrame.Pools:Acquire("AuraIconTemplate")
					unitFrame.icons[i]:SetSize(C.auraIconSize, C.auraIconSize)
					unitFrame.icons[i].text:SetFont(G.numFont, G.auraFontSize, G.fontFlag)
					unitFrame.icons[i].count:SetFont(G.numFont, G.auraFontSize-2, G.fontFlag)
				end
				UpdateAuraIcon(unitFrame.icons[i], unitFrame.displayedUnit, index, 'HELPFUL')
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end

	for index = 1, 20 do
		if i <= C.auraNum then
			local dname, _, _, _, dduration, _, dcaster, _, _, dspellid, _, _, _, nameplateShowAll = UnitAura(unit, index, "HARMFUL")
			local matchdebuff = AuraFilter(dcaster, dspellid, nameplateShowAll)
			
			if dname and matchdebuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = unitFrame.Pools:Acquire("AuraIconTemplate")
					unitFrame.icons[i]:SetSize(C.auraIconSize, C.auraIconSize)
					unitFrame.icons[i].text:SetFont(G.numFont, G.auraFontSize, G.fontFlag)
					unitFrame.icons[i].count:SetFont(G.numFont, G.auraFontSize-2, G.fontFlag)
				end
				UpdateAuraIcon(unitFrame.icons[i], unitFrame.displayedUnit, index, 'HARMFUL')
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end

	unitFrame.iconnumber = i - 1
	
	if i > 1 then	
		unitFrame.icons[1]:SetPoint("LEFT", unitFrame.icons, "CENTER", -((C.auraIconSize + 4) * (unitFrame.iconnumber) - 4) / 2, 0)
	end
	
	for index = i, #unitFrame.icons do
		unitFrame.icons[index]:Hide()
	end
end

--========================================================--
-----------------    [[ Player Plate ]]    -----------------
--========================================================--

if C.playerPlate then
	local PowerFrame = CreateFrame("Frame", "EKPlatePowerFrame")
	
	PowerFrame.powerBar = CreateFrame("StatusBar", nil, PowerFrame)
	PowerFrame.powerBar:SetHeight(4)
	PowerFrame.powerBar:SetStatusBarTexture(G.ufbar)
	PowerFrame.powerBar:SetMinMaxValues(0, 1)
	
	PowerFrame.powerBar.bd = CreateBackdrop(PowerFrame.powerBar, PowerFrame.powerBar, 1)
	
	PowerFrame.powerperc = PowerFrame:CreateFontString(nil, "OVERLAY")
	PowerFrame.powerperc:SetFont(G.percFont, G.fontSize, G.fontFlag)
	PowerFrame.powerperc:SetShadowColor(0, 0, 0, .4)
	PowerFrame.powerperc:SetShadowOffset(1, -1)
	
	PowerFrame:SetScript("OnEvent", function(self, event, unit)
		if event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player") then
			local cur, max, index, powertype = UnitPower("player"), UnitPowerMax("player"), UnitPowerType("player")
			local perc
			
			if max ~= 0 then
				perc = cur / max
			else
				perc = 0
			end
			
			local percT = math.floor(perc * 100 + .5)
			
			if not C.numberstyle then
				PowerFrame.powerBar:SetValue(perc)
			else
				if cur ~= max then  
					if index == 0 then
						PowerFrame.powerperc:SetText(percT)
					else
						PowerFrame.powerperc:SetText(cur)
					end
				else
					PowerFrame.powerperc:SetText("")
				end
			end
			
			local r, g, b = unpack(ColorPower[powertype])

			if ( r ~= PowerFrame.r or g ~= PowerFrame.g or b ~= PowerFrame.b ) then
				if not C.numberstyle then
					PowerFrame.powerBar:SetStatusBarColor(r, g, b)
				else
					PowerFrame.powerperc:SetTextColor(r, g, b)
				end
				
				PowerFrame.r, PowerFrame.g, PowerFrame.b = r, g, b
			end
		elseif event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
			local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
			
			if namePlatePlayer then
				PowerFrame:Show()
				PowerFrame:SetParent(namePlatePlayer)
				
				if not C.numberstyle then
					PowerFrame.powerBar:ClearAllPoints()
					PowerFrame.powerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -2)
					PowerFrame.powerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -2)
				else
					PowerFrame.powerperc:ClearAllPoints()
					PowerFrame.powerperc:SetPoint("BOTTOMLEFT", namePlatePlayer.UnitFrame.healthperc, "BOTTOMRIGHT", 0, 0)
				end
			end
		elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
			PowerFrame:Hide()
		end
	end)
	PowerFrame:RegisterEvent("UNIT_POWER_FREQUENT")
	PowerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	PowerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	PowerFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

-- [[ Class bar stuff ]] --

if C.classResourceShow then
	local ClassPowerID, ClassPowerType, RequireSpec
	-- 副資源漸變色
	local classicon_colors = { --monk/paladin/preist
		{.6, 0, .1},
		{.9, .1, .2},
		{1, .2, .3},
		{1, .3, .4},
		{1, .4, .5},
		{1, .5, .6},
	}
	-- 連擊點滿星色
	local cpoints_colors = { -- combat points
		{1, 0, 0},
		{1, 1, 0},
	}
	
	if(G.myClass == "MONK") then
		ClassPowerID = Enum.PowerType.Chi
		ClassPowerType = "CHI"
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif(G.myClass == "PALADIN") then
		ClassPowerID = Enum.PowerType.HolyPower
		ClassPowerType = "HOLY_POWER"
		RequireSpec = SPEC_PALADIN_RETRIBUTION
	elseif(G.myClass == "MAGE") then
		ClassPowerID = Enum.PowerType.ArcaneCharges
		ClassPowerType = "ARCANE_CHARGES"
		RequireSpec = SPEC_MAGE_ARCANE
	elseif(G.myClass == "WARLOCK") then
		ClassPowerID = Enum.PowerType.SoulShards
		ClassPowerType = "SOUL_SHARDS"
	elseif(G.myClass == "ROGUE" or G.myClass == "DRUID") then
		ClassPowerID = Enum.PowerType.ComboPoints
		ClassPowerType = "COMBO_POINTS"
	end

	local Resourcebar = CreateFrame("Frame", "EKPlateResource", UIParent)
	Resourcebar:SetWidth(100)		--(10+3)*6 - 3
	Resourcebar:SetHeight(4)
	Resourcebar.maxbar = 6
	
	for i = 1, 6 do
		Resourcebar[i] = CreateFrame("Frame", "EKPlateResource"..i, Resourcebar)
		Resourcebar[i]:SetFrameLevel(1)
		Resourcebar[i]:SetSize(15, 3)
		Resourcebar[i].bd = CreateBackdrop(Resourcebar[i], Resourcebar[i], 1)
		Resourcebar[i].tex = Resourcebar[i]:CreateTexture(nil, "OVERLAY")
		Resourcebar[i].tex:SetAllPoints(Resourcebar[i])
		
		if G.myClass == "DEATHKNIGHT" then
			Resourcebar[i].value = CreateText(Resourcebar[i], "OVERLAY", G.numFont, G.fontSize-2, G.fontFlag, "CENTER")
			Resourcebar[i].value:SetPoint("CENTER")
			Resourcebar[i].tex:SetColorTexture(.7, .7, 1)
		end
		
		if i == 1 then
			Resourcebar[i]:SetPoint("BOTTOMLEFT", Resourcebar, "BOTTOMLEFT")
		else
			Resourcebar[i]:SetPoint("LEFT", Resourcebar[i-1], "RIGHT", 2, 0)
		end
	end
	
	local function RuneOnUpdate(self, elapsed)
		self.duration = self.duration + elapsed
		if self.duration >= self.max or self.duration <= 0 then
			self.value:SetText("")
		else
			self.value:SetText(FormatTime(self.max - self.duration))
		end
	end

	Resourcebar:SetScript("OnEvent", function(self, event, unit, powerType)
		if event == "PLAYER_TALENT_UPDATE" then
			if multicheck(G.myClass, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID", "DEATHKNIGHT") and not RequireSpec or RequireSpec == GetSpecialization() then -- 啟用
				self:RegisterEvent("UNIT_POWER_FREQUENT")
				self:RegisterEvent("PLAYER_ENTERING_WORLD")
				self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
				self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:RegisterEvent("PLAYER_TARGET_CHANGED")
				self:RegisterEvent("RUNE_POWER_UPDATE")
				self:Show()
			else
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
				self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")
				self:UnregisterEvent("RUNE_POWER_UPDATE")
				self:Hide()
			end
		elseif event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player" and powerType == ClassPowerType) then
			if multicheck(G.myClass, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID") then
				local cur, max, oldMax

				cur = UnitPower("player", ClassPowerID)
				max = UnitPowerMax("player", ClassPowerID)

				if multicheck(G.myClass, "WARLOCK", "PALADIN", "MONK", "MAGE") then	-- 副資源
					for i = 1, max do
						if i <= cur then
							self[i]:Show()
						else
							self[i]:Hide()
						end
						
						if cur == max then
							self[i].tex:SetColorTexture(unpack(classicon_colors[max]))
						else
							self[i].tex:SetColorTexture(unpack(classicon_colors[i]))
						end
					end

					oldMax = self.maxbar
					if max ~= oldMax then
						if max < oldMax then
							for i = max + 1, oldMax do
								self[i]:Hide()
							end
						end
						
						for i = 1, 6 do
							self[i]:SetWidth(102/max-2)
						end
						
						self.maxbar = max
					end
				else	-- 連擊點
					if max <= 6 then
						for i = 1, max do
							if i <= cur then
								self[i]:Show()
							else
								self[i]:Hide()
							end
							
							self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))
						end
					else
						if cur <= 5 then
							for i = 1, 5 do
								if i <= cur then
									self[i]:Show()
								else
									self[i]:Hide()
								end
								
								self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))
							end
						else
							for i = 1, 5 do
								self[i]:Show()
							end
							
							for i = 1, cur - 5 do
								self[i].tex:SetColorTexture(unpack(cpoints_colors[2]))
							end
							
							for i = cur - 4, 5 do
								self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))
							end
						end
					end

					oldMax = self.maxbar
					if max ~= oldMax then
						if max <= 6 then
							for i = 1, 6 do
								self[i]:SetWidth(102 / max - 2)
								
								if i > max then
									self[i]:Hide()
								end
							end
						else
							self[6]:Hide()
							
							for i = 1, 6 do
								self[i]:SetWidth(102 / 5 - 2)
							end
						end
						self.maxbar = max
					end
				end
			end
		elseif G.myClass == "DEATHKNIGHT" and event == "RUNE_POWER_UPDATE" then
			local rid = unit
			local start, duration, runeReady = GetRuneCooldown(rid)
			
			if runeReady then
				self[rid]:SetAlpha(1)
				self[rid].tex:SetColorTexture(.7, .7, 1)
				self[rid]:SetScript("OnUpdate", nil)
				self[rid].value:SetText("")
			elseif start then
				self[rid]:SetAlpha(.7)
				self[rid].tex:SetColorTexture(.3, .3, .3)
				self[rid].max = duration
				self[rid].duration = GetTime() - start
				self[rid]:SetScript("OnUpdate", RuneOnUpdate)
			end
		elseif C.classResourceOn == "player" then
			if event == "NAME_PLATE_UNIT_ADDED" and UnitIsUnit(unit, "player") then
				local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player")
				
				if namePlatePlayer then
					self:SetParent(namePlatePlayer)
					self:ClearAllPoints()
					self:Show()
					
					if C.numberstyle then
						self:SetPoint("TOP", namePlatePlayer.UnitFrame.name, "TOP", 0, 0)			-- 玩家數字
					else
						self:SetPoint("TOP", namePlatePlayer.UnitFrame.healthBar, "BOTTOM", 0, -8)	-- 玩家條
					end
				end
			elseif event == "NAME_PLATE_UNIT_REMOVED" and UnitIsUnit(unit, "player") then
				self:Hide()
			end
		elseif C.classResourceOn == "target" and (event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED") then
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target")
			
			if namePlateTarget and UnitCanAttack("player", namePlateTarget.UnitFrame.displayedUnit) then
				self:SetParent(namePlateTarget)
				self:ClearAllPoints()
				
				if C.numberstyle then
					self:SetPoint("TOP", namePlateTarget.UnitFrame.name, "BOTTOM", 0, -2)			-- 目標數字
				else
					self:SetPoint("TOP", namePlateTarget.UnitFrame.healthBar, "BOTTOM", 0, 0)		-- 目標條
				end
				
				self:Show()
			else
				self:Hide()
			end
		end
	end)
	
	Resourcebar:RegisterEvent("PLAYER_TALENT_UPDATE")
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

-- Power / 能量
local function UpdatePower(unitFrame)
	local unit = unitFrame.displayedUnit
	local cur, max = UnitPower(unit), UnitPowerMax(unit)
	local perc = cur / max
	local percT
	local r, g, b
	
	if cur and max and max > 0 then
		perc = cur / max
		percT = math.floor(perc * 100 + .5)
	else
		perc = 0
		percT = 0		
	end
	
	-- 能量百分比
	if C.numberstyle then
		unitFrame.powerperc:SetText(percT)
	else
		unitFrame.powerBar:SetValue(perc)
		unitFrame.powerBar.value:SetText(percT)
	end
	
	-- 能量漸變色
  	if perc < .25 then
		r, g, b = .2, .2, 1
	elseif perc < .3 then
		r, g, b = .4, .4, 1
	else
		r, g, b = .8, .8, 1
	end
	
	if not C.numberstyle then
		unitFrame.powerBar:SetStatusBarColor(r, g, b)
		unitFrame.powerBar.bd:SetBackdropColor(r/3, g/3, b/3)
	else
		unitFrame.powerperc:SetTextColor(r, g, b)
	end	
end

-- Threat / 威脅值
local function IsOnThreatList(unit)
	local _, threatStatus = UnitDetailedThreatSituation("player", unit)
	
	if threatStatus == 3 then 
		-- 當前仇恨，威脅值穩定/securely tanking, highest threat
		return .9, .1, .4  -- 紅色/red
	elseif threatStatus == 2 then
		-- 當前仇恨，但不穩，已被OT或坦克正在丟失仇恨/insecurely tanking, another unit have higher threat but not tanking.
		return .9, .1, .9  -- 粉色/pink
	elseif threatStatus == 1 then
		-- 非當前仇恨，但已OT即將獲得仇恨，或坦克正在獲得仇恨/not tanking, higher threat than tank.
		return .4, .1, .9  -- 紫色/purple
	elseif threatStatus == 0 then 
		-- 非當前仇恨，低威脅值/not tanking, lower threat than tank.
		return .1, .7, .9  -- 藍色/blue
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
		local iscustomed = false
		
		-- 特定目標染色白名單
		for index, info in pairs(C.CustomUnit) do
			if npcID == info.id then
				r, g, b = unpack(info.color)
				iscustomed = true
				break
			end
		end
		
		--職業或陣營染色
		if not iscustomed then
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
				if C.threatColor and IsOnThreatList(unitFrame.displayedUnit) then
					-- 威脅染色
					r, g, b = IsOnThreatList(unitFrame.displayedUnit)
				else
					-- 陣營染色
					r, g, b = UnitSelectionColor(unit, true)
				end
			end
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

--===================================================--
-----------------    [[ CastBar ]]    -----------------
--===================================================--

-- Cast bar / 施法條
local function UpdateCastBar(unitFrame)
	local castBar = unitFrame.castBar
	
	if not castBar.colored then
		castBar.startCastColor = CreateColor(unpack(C.castStart))			-- 開始施法
		castBar.startChannelColor = CreateColor(unpack(C.castStart))		-- 開始引導
		castBar.finishedCastColor = CreateColor(unpack(C.castStart))		-- 施法完成
		castBar.failedCastColor = CreateColor(unpack(C.castFailed))			-- 施法失敗
		castBar.nonInterruptibleColor = CreateColor(unpack(C.castShield))	-- 不可打斷

		CastingBarFrame_AddWidgetForFade(castBar, castBar.BorderShield)
		castBar.colored = true
	end

	if UnitIsUnit("player", unitFrame.displayedUnit) then return end
	if C.nameOnly and UnitIsPlayer(unitFrame.unit) and UnitReaction(unitFrame.unit, "player") >= 5 then return end
	
	if C.cbShield then
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, true)
	else
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, false)
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
	
	-- 焦點高亮
	if UnitIsUnit(unit, "focus") and not UnitIsUnit(unit, "player") and C.HighlightFocus then
		unitFrame.hlfocus:Show()
	else
		unitFrame.hlfocus:Hide()
	end
	
	-- 箭頭位移
	unitFrame.hltarget:ClearAllPoints()
	
	if C.HighlightMode == "Vertical" then		--垂直箭頭
		if not C.numberstyle then
			if unitFrame.iconnumber and unitFrame.iconnumber > 0 then											-- 有光環
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, C.auraIconSize + 3)
			else																								-- 只有名字
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
			end
		else
			if unitFrame.iconnumber and unitFrame.iconnumber > 0 then											-- 有光環
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.icons, "TOP", 0, 3)
			elseif UnitHealth(unit) and UnitHealthMax(unit) and UnitHealth(unit) ~= UnitHealthMax(unit) then	-- 非滿血
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
			else																								-- 只有名字
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
			end
		end
	elseif C.HighlightMode == "Horizontal" then	--橫向箭頭
		unitFrame.hltarget:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
		
		if not C.numberstyle then
			unitFrame.hltarget:SetPoint("LEFT", unitFrame.healthBar, "RIGHT", 0, 0)
		else
			if C.ShowPower then
				local npcID = GetNPCID(UnitGUID(unitFrame.displayedUnit))
				
				if C.ShowPowerList[npcID] then																	--顯示能量
					unitFrame.hltarget:SetPoint("LEFT", unitFrame.powerperc, "RIGHT", 0, 0)
				else
					unitFrame.hltarget:SetPoint("LEFT", unitFrame.name, "RIGHT", 0, 0)
				end
			end
		end
	else
		return
	end
end

------------------------------------
-- mouseover highlight / 指向高亮 --
------------------------------------

-- Update mouseover move out because event only check move in / 檢測移出
local function MouseoverOnUpdate(self, elapsed)
	if not UnitIsUnit(self.unit, "mouseover") then
		self.hlmo:Hide()
	end
end

-- Update mouseover
local function UpdateMouseover(unitFrame)
	if not C.HighlightMouseover then return end
	local unit = unitFrame.unit
	if UnitIsUnit(unit, "mouseover") and not UnitIsUnit(unit, "player") then
		unitFrame.hlmo:Show()
	else
		unitFrame.hlmo:Hide()
	end
	unitFrame:SetScript("OnUpdate", MouseoverOnUpdate)
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
	unitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit)
	
	if C.ShowPower then
		local npcID = GetNPCID(UnitGUID(unitFrame.displayedUnit))
		
		if C.ShowPowerList[npcID] then
			unitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit)
			-- 顯示能量條時微調名字位置
			if not C.numberstyle then
				unitFrame.powerBar:Show()
				unitFrame.powerBar.value:Show()
				unitFrame.name:SetPoint("BOTTOM", unitFrame.powerBar, "TOP", 0, 2)
			else
				unitFrame.powerperc:Show()
			end
		else
			unitFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
			
			if not C.numberstyle then
				unitFrame.powerBar:Hide()
				unitFrame.powerBar.value:Hide()
				unitFrame.name:SetPoint("BOTTOM", unitFrame.healthBar, "TOP", 0, 2)
			else
				unitFrame.powerperc:Hide()
			end
		end
	end
end

-- vehicle / 載具
local function UpdateInVehicle(unitFrame)
	if ( UnitHasVehicleUI(unitFrame.unit) ) then
		if not unitFrame.inVehicle then
			unitFrame.inVehicle = true
			
			local prefix, id, suffix = string.match(unitFrame.unit, "([^%d]+)([%d]*)(.*)")
			unitFrame.displayedUnit = prefix.."pet"..id..suffix
			UpdateNamePlateEvents(unitFrame)
		end
	else
		if unitFrame.inVehicle then
			unitFrame.inVehicle = false
			
			unitFrame.displayedUnit = unitFrame.unit
			UpdateNamePlateEvents(unitFrame)
		end
	end
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
		unitFrame.castBar:UnregisterAllEvents()
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
	UpdateInVehicle(unitFrame)
	
	if UnitExists(unitFrame.displayedUnit) then
		UpdateName(unitFrame)
		UpdateHealthColor(unitFrame)
		UpdateHealth(unitFrame)
		UpdateCastBar(unitFrame)
		UpdateSelectionHighlight(unitFrame)
		UpdateBuffs(unitFrame)
		UpdateRaidTarget(unitFrame)
		UpdateforNamemod(unitFrame)
		
		-- 替個人資源微調各元素
		if UnitIsUnit("player", unitFrame.displayedUnit) then
			unitFrame.castBar:UnregisterAllEvents()
			
			if not C.numberstyle then
				unitFrame.healthBar.value:Hide()
				unitFrame.icons:SetPoint("BOTTOM", unitFrame.healthBar, "TOP", 0, 4)	
				unitFrame.RaidTargetFrame:SetPoint("RIGHT", unitFrame.healthBar, "LEFT")
			else
				unitFrame.icons:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
				unitFrame.RaidTargetFrame:SetPoint("RIGHT", unitFrame.healthperc, "LEFT")
			end
		else
			unitFrame.RaidTargetFrame:SetPoint("RIGHT", unitFrame.name, "LEFT")
			
			if not C.numberstyle then
				unitFrame.healthBar.value:Show()
				unitFrame.icons:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 2)
			else
				unitFrame.icons:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
			end
		end
		
		-- 能量白名單
		local npcID = GetNPCID(UnitGUID(unitFrame.displayedUnit))
		if C.ShowPower and C.ShowPowerList[npcID] then
			UpdatePower(unitFrame)
		end
	end
end

local function NamePlate_OnEvent(self, event, ...)
	local arg1 = ...
	if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
		UpdateName(self)
		UpdateSelectionHighlight(self)
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		UpdateMouseover(self)
	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdateAll(self)
	elseif arg1 == self.unit or arg1 == self.displayedUnit then
		if event == "UNIT_HEALTH_FREQUENT" then
			UpdateHealth(self)
			UpdateSelectionHighlight(self)
		elseif event == "UNIT_AURA" then
			UpdateBuffs(self)
			UpdateSelectionHighlight(self)
		elseif event == "UNIT_THREAT_LIST_UPDATE" then
			UpdateHealthColor(self)
		elseif event == "UNIT_NAME_UPDATE" then
			UpdateName(self)
		elseif event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" then
			UpdateAll(self)
		elseif C.ShowPower and event == "UNIT_POWER_FREQUENT" then
			local npcID = GetNPCID(UnitGUID(self.displayedUnit))
			
			if C.ShowPowerList[npcID] then
				UpdatePower(self)
			end
		end
	end
end

local function RegisterNamePlateEvents(unitFrame)
	unitFrame:RegisterEvent("UNIT_NAME_UPDATE")
	unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	unitFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	unitFrame:RegisterEvent("UNIT_PET")
	unitFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
	unitFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
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
	ClassNameplateManaBarFrame:Hide()

	local checkBox = InterfaceOptionsNamesPanelUnitNameplatesMakeLarger
	function checkBox.setFunc(value)
		if value == "1" then
			SetCVar("NamePlateHorizontalScale", checkBox.largeHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.largeVerticalScale)
		else
			SetCVar("NamePlateHorizontalScale", checkBox.normalHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.normalVerticalScale)
		end
		
		NamePlates_UpdateNamePlateOptions()
	end
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
	namePlate.Pools = CreatePoolCollection() 
	
	if C.numberstyle then -- 数字样式
		if C.castBar then
			namePlate.Pools:CreatePool("Button", namePlate, "NumberStyleNameplateNormalCastBarTemplate")
			namePlate.UnitFrame = namePlate.Pools:Acquire("NumberStyleNameplateNormalCastBarTemplate")
		else
			namePlate.Pools:CreatePool("Button", namePlate, "NumberStyleNameplateTemplate")
			namePlate.UnitFrame = namePlate.Pools:Acquire("NumberStyleNameplateTemplate")
			if C.cbText then
				namePlate.UnitFrame.castBar.Text:Show()
			else
				namePlate.UnitFrame.castBar.Text:Hide()
			end
		end
		
		namePlate.UnitFrame:SetAllPoints(namePlate)
		namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
		namePlate.UnitFrame:Show()
		namePlate.UnitFrame.Pools = CreatePoolCollection() 
		namePlate.UnitFrame.Pools:CreatePool("Frame", namePlate, "AuraIconTemplate")
		
		if C.classResourceShow and C.classResourceOn == "target" then
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -8)
		else
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -4)
		end
	else -- 条形样式
		namePlate.Pools:CreatePool("Button", namePlate, "BarStyleNameplateTemplate")
		namePlate.UnitFrame = namePlate.Pools:Acquire("BarStyleNameplateTemplate")
		namePlate.UnitFrame:SetAllPoints(namePlate)
		namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
		namePlate.UnitFrame:Show()
		namePlate.UnitFrame.Pools = CreatePoolCollection() 
		namePlate.UnitFrame.Pools:CreatePool("Frame", namePlate, "AuraIconTemplate")
		
		namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -4)
		namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -4)
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
	CastingBarFrame_SetUnit(namePlate.UnitFrame.castBar, nil, false, true)
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
	C_NamePlate.SetNamePlateSelfClickThrough(C.PlayerClickThrough)
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
		if C.playerPlate then
			SetCVar("nameplateShowSelf", 1)
		else
			SetCVar("nameplateShowSelf", 0)
		end
		NamePlates_UpdateNamePlateOptions()
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