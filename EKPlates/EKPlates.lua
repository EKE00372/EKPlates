local C, G = unpack(select(2, ...))

-- [[ config從beta7版本起獨立，至config.lua編輯設定 ]] --

-- [[ Functions ]] -- 

-- Power color / 能量顏色
local colorspower = {}
for power, color in next, PowerBarColor do
	if type(power) == "string" then
		colorspower[power] = {color.r, color.g, color.b}
	end
end

-- Class Color / 職業顏色
local Ccolors = {}
if IsAddOnLoaded("!ClassColors") and CUSTOM_CLASS_COLORS then
	Ccolors = CUSTOM_CLASS_COLORS
else
	Ccolors = RAID_CLASS_COLORS
end

-- Aura text / 光環的數字文本
local createnumber = function(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(G.numFont, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

-- Text / 文本
local createtext = function(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(G.norFont, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

-- Icon style for number style cast bar / 給數字模式施法條的框體樣式
local CreateBD = function(f, a)
	f:SetBackdrop({
		bgFile = G.blank,
		edgeFile = G.blank,
		edgeSize = 1,
	})
	f:SetBackdropColor(0, 0, 0, a or 1)
	f:SetBackdropBorderColor(0, 0, 0)
end

-- make shadowed style / 創建毛絨絨
local CreateThinSD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 1
	sd.offset = offset or 0
	sd:SetBackdrop({
		bgFile = G.blank,
		edgeFile = G.blank,
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetBackdropColor(r or 0, g or 0, b or 0, alpha or 0)
	
	return sd
end

-- make background / 創建背景
local CreateBDFrame = function(f, a)
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	CreateBD(bg, a or .5)

	return bg
end

-- Icon style for cast bar / 給施法條圖示的框體樣式
local CreateBG = function(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture(G.blank)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- Style for bar / 給各個條條兒的框體樣式
local frameBD = {
    edgeFile = G.glow, edgeSize = 3,
    bgFile = G.blank,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
}

local createBackdrop = function(parent, anchor, a)
    local frame = CreateFrame("Frame", nil, parent)

	local flvl = parent:GetFrameLevel()
	if flvl - 1 >= 0 then frame:SetFrameLevel(flvl-1) end

	frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)

    frame:SetBackdrop(frameBD)
	if a then
		frame:SetBackdropColor(.15, .15, .15, a)
		frame:SetBackdropBorderColor(0, 0, 0)
	end

    return frame
end

-- [[ Auras ]] -- 
	
-- timer / 數值
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

-- Make icon / 創建圖示
local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame", "EKPlateButton",parent)
	button:SetSize(C.auraiconsize, C.auraiconsize)

	button.icon = button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.icon:SetPoint("TOPLEFT", button,"TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT",-1, 1)
	button.icon:SetTexCoord(.08, .92, 0.08, 0.92)
	
	button.overlay = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.overlay:SetAllPoints(button)	
	
	button.bd = button:CreateTexture(nil, "ARTWORK", nil, 6)
	button.bd:SetTexture("Interface\\Buttons\\WHITE8x8")
	button.bd:SetVertexColor(0, 0, 0)
	button.bd:SetPoint("TOPLEFT", button,"TOPLEFT", -1, 1)
	button.bd:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT", 1, -1)
	
	button.text = createnumber(button, "OVERLAY", G.aurafontsize, G.fontflag, "CENTER")
	button.text:SetPoint("BOTTOM", button, "BOTTOM", 0, -2)
	button.text:SetTextColor(1, 1, 0)
	
	button.count = createnumber(button, "OVERLAY", G.aurafontsize-2, G.fontflag, "RIGHT")
	button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, 2)
	button.count:SetTextColor(.4, .95, 1)
	
	return button
end

-- Creat aura icon and update / 更新圖示
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

local function UpdateAuraIcon(button, unit, index, filter)
	local name, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	button.icon:SetTexture(icon)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	
	local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
	button.overlay:SetVertexColor(color.r, color.g, color.b)

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end	
	-- 激勵?
	--[[
	if spellID == 209859 or spellID == 113746 or spellID == 228287 then
		count = (count or 0) + 1
		button.count:SetText(count)
	end
	]]--
	button:SetScript("OnUpdate", AuraIconOnUpdate)
	
	button:Show()
end

-- Aura filter / 過濾器
local function AuraFilter(caster, spellid)
	if caster == "player" then
		if C["myfiltertype"] == "none" then
			return false
		elseif C["myfiltertype"] == "whitelist" and C.WhiteList[spellid] then
			return true
		elseif C["myfiltertype"] == "blacklist" and not C.BlackList[spellid] then
			return true
		end
	else
		if C["otherfiltertype"] == "none" then
			return false
		elseif C["otherfiltertype"] == "whitelist" and C.WhiteList[spellid] then
			return true
		end
	end
end

-- Update and show aura / 顯示圖示
local function UpdateBuffs(unitFrame)
	if not unitFrame.icons or not unitFrame.displayedUnit then return end
	if not C.plateaura and UnitIsUnit(unitFrame.displayedUnit, "player") then return end
	local unit = unitFrame.displayedUnit
	local i = 1
	
	
	for index = 1, 15 do
		if i <= C.auranum then
			local bname, _, _, _, bduration, _, bcaster, _, _, bspellid = UnitAura(unit, index, "HELPFUL")
			local matchbuff = AuraFilter(bcaster, bspellid)
			if bname and matchbuff then
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(unitFrame.icons)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, "HELPFUL")
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end

	for index = 1, 20 do
		if i <= C.auranum then
			local dname, _, _, _, dduration, _, dcaster, _, _, dspellid = UnitAura(unit, index, "HARMFUL")
			local matchdebuff = AuraFilter(dcaster, dspellid)
			if dname and matchdebuff then
				--if dspellid == 209859 or dspellid == 113746 or dspellid == 228287 then return end -- 激勵?				
				if not unitFrame.icons[i] then
					unitFrame.icons[i] = CreateAuraIcon(unitFrame.icons)
				end
				UpdateAuraIcon(unitFrame.icons[i], unit, index, "HARMFUL")
				if i ~= 1 then
					unitFrame.icons[i]:SetPoint("LEFT", unitFrame.icons[i-1], "RIGHT", 4, 0)
				end
				i = i + 1
			end
		end
	end
	
	unitFrame.iconnumber = i - 1
	
	if i > 1 then	
		unitFrame.icons[1]:SetPoint("LEFT", unitFrame.icons, "CENTER", -((C.auraiconsize+4)*(unitFrame.iconnumber)-4)/2, 0)
	end
	for index = i, #unitFrame.icons do unitFrame.icons[index]:Hide() end
end

-- [[ Player Power ]] -- 

if C.playerplate then
	local PowerFrame = CreateFrame("Frame", "EKPlatePowerFrame")
	
	PowerFrame.powerBar = CreateFrame("StatusBar", nil, PowerFrame)
	PowerFrame.powerBar:SetHeight(3)
	PowerFrame.powerBar:SetStatusBarTexture(G.ufbar)
	PowerFrame.powerBar:SetMinMaxValues(0, 1)
	
	PowerFrame.powerBar.bd = createBackdrop(PowerFrame.powerBar, PowerFrame.powerBar, 1)
	
	PowerFrame.powerperc = PowerFrame:CreateFontString(nil, "OVERLAY")
	PowerFrame.powerperc:SetFont(G.numberstylefont, G.fontsize, G.fontflag)
	PowerFrame.powerperc:SetShadowColor(0, 0, 0, 0.4)
	PowerFrame.powerperc:SetShadowOffset(1, -1)
	
	PowerFrame:SetScript("OnEvent", function(self, event, unit)
		if event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player") then
			local minPower, maxPower, powertype_index, powertype = UnitPower("player"), UnitPowerMax("player"), UnitPowerType("player")
			local perc
			
			if maxPower ~= 0 then
				perc = minPower/maxPower
			else
				perc = 0
			end
			local perc_text = string.format("%d", math.floor(perc*100))
			
			if not C.numberstyle then
				PowerFrame.powerBar:SetValue(perc)
			else
				if minPower ~= maxPower then  
					if powertype_index == 0 then
						PowerFrame.powerperc:SetText(perc_text)
					else
						PowerFrame.powerperc:SetText(minPower)
					end
				else
					PowerFrame.powerperc:SetText("")
				end
			end
			local r, g, b = unpack(colorspower[powertype])

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
					PowerFrame.powerBar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -3)
					PowerFrame.powerBar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -3)
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

if C.classresource_show then
	local function multicheck(check, ...)
		for i=1, select("#", ...) do
			if check == select(i, ...) then return true end
		end
		return false
	end

	local ClassPowerID, ClassPowerType, RequireSpec
	local classicon_colors = { --monk/paladin/preist
		{.6, 0, .1},
		{.9, .1, .2},
		{1, .2, .3},
		{1, .3, .4},
		{1, .4, .5},
		{1, .5, .6},
	}
	
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
	Resourcebar:SetHeight(3)
	Resourcebar.maxbar = 6
	
	for i = 1, 6 do
		Resourcebar[i] = CreateFrame("Frame", "EKPlateResource"..i, Resourcebar)
		Resourcebar[i]:SetFrameLevel(1)
		Resourcebar[i]:SetSize(15, 3)
		Resourcebar[i].bd = createBackdrop(Resourcebar[i], Resourcebar[i], 1)
		Resourcebar[i].tex = Resourcebar[i]:CreateTexture(nil, "OVERLAY")
		Resourcebar[i].tex:SetAllPoints(Resourcebar[i])
		if G.myClass == "DEATHKNIGHT" then
			Resourcebar[i].value = createtext(Resourcebar[i], "OVERLAY", G.fontsize-2, G.fontflag, "CENTER")
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

				if multicheck(G.myClass, "WARLOCK", "PALADIN", "MONK", "MAGE") then
					for i = 1, max do
						if(i <= cur) then
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
					if(max ~= oldMax) then
						if(max < oldMax) then
							for i = max + 1, oldMax do
								self[i]:Hide()
							end
						end
						for i = 1, 6 do
							self[i]:SetWidth(102/max-2)
						end
						self.maxbar = max
					end
				else -- 連擊點
					if max <= 6 then
						for i = 1, max do
							if(i <= cur) then
								self[i]:Show()
							else
								self[i]:Hide()
							end
							self[i].tex:SetColorTexture(unpack(cpoints_colors[1]))
						end
					else
						if cur <= 5 then
							for i = 1, 5 do
								if(i <= cur) then
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
					if(max ~= oldMax) then
						if max <= 6 then
							for i = 1, 6 do
								self[i]:SetWidth(102/max-2)
								if i > max then
									self[i]:Hide()
								end
							end
						else
							self[6]:Hide()
							for i = 1, 6 do
								self[i]:SetWidth(102/5-2)
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
		elseif C.classresource == "player" then
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
		elseif C.classresource == "target" and (event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED") then
			local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target")
			if namePlateTarget and UnitCanAttack("player", namePlateTarget.UnitFrame.displayedUnit) then
				self:SetParent(namePlateTarget)
				self:ClearAllPoints()
				if C.numberstyle then
					self:SetPoint("TOP", namePlateTarget.UnitFrame.name, "BOTTOM", 0, -2)			-- 目標數字
				else
					self:SetPoint("TOP", namePlateTarget.UnitFrame.healthBar, "BOTTOM", 0, -2)		-- 目標條
				end
				self:Show()
			else
				self:Hide()
			end
		end
	end)
	
	Resourcebar:RegisterEvent("PLAYER_TALENT_UPDATE")
end

-- [[ Unit frame ]] --

-- Name / 名字
local function UpdateName(unitFrame)
	local name = GetUnitName(unitFrame.displayedUnit, false) or UNKNOWN
	local unit = unitFrame.displayedUnit
	local level = UnitLevel(unit)
	local hexColor
	if not C.numberstyle and UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 then return end
	if name then
		if C.level then
			if UnitIsUnit(unitFrame.displayedUnit, "player") then
				unitFrame.name:SetText("")
			else
				if level >= UnitLevel("player")+5 then
					hexColor = "ff0000"
				elseif level >= UnitLevel("player")+3 then
					hexColor = "ff6600"
				elseif level <= UnitLevel("player")-3 then
					hexColor = "00ff00"
				elseif level <= UnitLevel("player")-5 then
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
	local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local perc = minHealth/maxHealth
	local perc_text = string.format("%d", math.floor(perc*100))
	
	if not C.numberstyle then
		unitFrame.healthBar:SetValue(perc)
		if minHealth ~= maxHealth then
			unitFrame.healthBar.value:SetText(perc_text)
		else
			unitFrame.healthBar.value:SetText("")
		end
		
		if perc < .25 then
			unitFrame.healthBar.value:SetTextColor(0.8, 0.05, 0)
		elseif perc < .3 then
			unitFrame.healthBar.value:SetTextColor(0.95, 0.7, 0.25)
		else
			unitFrame.healthBar.value:SetTextColor(1, 1, 1)
		end
	else
		if minHealth ~= maxHealth then
			unitFrame.healthperc:SetText(perc_text)
		else
			if UnitIsUnit("player", unitFrame.displayedUnit) then
				unitFrame.healthperc:SetText("100")
			else
				unitFrame.healthperc:SetText("")
			end
		end
		
		if perc < .25 then
			unitFrame.healthperc:SetTextColor(0.8, 0.05, 0)
		elseif perc < .3 then
			unitFrame.healthperc:SetTextColor(0.95, 0.7, 0.25)
		else
			unitFrame.healthperc:SetTextColor(1, 1, 1)
		end
	end
end

-- Power / 能量
local function UpdatePower(unitFrame)
	local unit = unitFrame.displayedUnit
	local minPower, maxPower = UnitPower(unit), UnitPowerMax(unit)
	local perc = minPower/maxPower
	local perc_text
	if minPower and maxPower and maxPower > 0 then
		perc = minPower/maxPower
		perc_text = string.format("%d", math.floor(perc*100))
	else
		perc = 0
		perc_text = 0
	end
	
	if not C.numberstyle then
		unitFrame.powerBar:SetValue(perc)
		unitFrame.powerBar.value:SetText(perc_text)
	else
		unitFrame.powerperc:SetText(perc_text)
	end
	
	local r, g, b
  	if perc < .25 then
		r, g, b = .2, .2, 1
	elseif perc < .3 then
		r, g, b = .4, .4, 1
	else
		r, g, b = .8, .8, 1
	end
	
	if not C.numberstyle then
		unitFrame.powerBar:SetStatusBarColor(r, g, b)
	else
		unitFrame.powerperc:SetTextColor(r, g, b)
	end
	
end

-- Threat / 仇恨
local function IsOnThreatList(unit)
	local _, threatStatus = UnitDetailedThreatSituation("player", unit)
	if threatStatus == 3 then 
		--穩定仇恨，當前坦克/securely tanking, highest threat
		return .9, .1, .4  --紅色/red
	elseif threatStatus == 2 then
		--非當前仇恨，當前坦克(已OT或坦克正在丟失仇恨)/insecurely tanking, another unit have higher threat but not tanking.
		return .9, .1, .9  --粉色/pink
	elseif threatStatus == 1 then
		--當前仇恨，非當前坦克(非坦克高仇恨或坦克正在獲得仇恨)/not tanking, higher threat than tank.
		return .4, .1, .9  --紫色/purple
	elseif threatStatus == 0 then 
		--低仇恨，安全/not tanking, lower threat than tank.
		return .1, .7, .9  --藍色/blue
	end
end

local function IsTapDenied(unitFrame)
	return UnitIsTapDenied(unitFrame.unit) and not UnitPlayerControlled(unitFrame.unit)
end

-- Health color / 血量顏色
local function UpdateHealthColor(unitFrame)
	local unit = unitFrame.displayedUnit
	local r, g, b
	
	if ( not UnitIsConnected(unit) ) then
		r, g, b = 0.7, 0.7, 0.7
	else
		local iscustomed = false
		for index, info in pairs(C.Customcoloredplates) do
			if GetUnitName(unit, false) == info.name then
				r, g, b= info.color.r, info.color.g, info.color.b
				iscustomed = true
				break
			end
		end
		
		if not iscustomed then
			local _, englishClass = UnitClass(unit)
			local classColor = Ccolors[englishClass]
			if UnitIsPlayer(unit) and classColor and C.friendlyCR and UnitReaction(unit, "player") >= 5 then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif UnitIsPlayer(unit) and classColor and C.enemyCR and UnitReaction(unit, "player") <= 4 then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif ( IsTapDenied(unitFrame) ) then
				r, g, b = 0.3, 0.3, 0.3
			else
				if C.threatcolor and IsOnThreatList(unitFrame.displayedUnit) then
					r, g, b = IsOnThreatList(unitFrame.displayedUnit)
				else
					r, g, b = UnitSelectionColor(unit, true)
				end
			end
		end
	end
	
	if ( r ~= unitFrame.r or g ~= unitFrame.g or b ~= unitFrame.b ) then
		if C.numberstyle then
			unitFrame.name:SetTextColor(r, g, b)
		else
			unitFrame.healthBar:SetStatusBarColor(r, g, b)
			unitFrame.healthBar.bd:SetBackdropColor(r/3, g/3, b/3)
			if C.name_mod then
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

-- Cast bar / 施法條
local function UpdateCastBar(unitFrame)
	local castBar = unitFrame.castBar
	if not castBar.colored then
		castBar.startCastColor = CreateColor(0.6, 0.6, 0.6)
		castBar.startChannelColor = CreateColor(0.6, 0.6, 0.6)
		castBar.finishedCastColor = CreateColor(0.6, 0.6, 0.6)
		castBar.failedCastColor = CreateColor(0.5, 0.2, 0.2)
		castBar.nonInterruptibleColor = CreateColor(0.9, 0, 1)
		CastingBarFrame_AddWidgetForFade(castBar, castBar.BorderShield)
		castBar.colored = true
	end

	if UnitIsUnit("player", unitFrame.displayedUnit) then return end
	if C.name_mod and UnitIsPlayer(unitFrame.unit) and UnitReaction(unitFrame.unit, "player") >= 5 then return end
	if C.cbshield then
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, true)
	else
		CastingBarFrame_SetUnit(castBar, unitFrame.unit, false, false)
	end
end

-- Highlight / 高亮
local function UpdateSelectionHighlight(unitFrame)
	local unit = unitFrame.unit
	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") and C.HighlightTarget then
		unitFrame.hltarget:Show()
	else
		unitFrame.hltarget:Hide()
	end
	
	if UnitIsUnit(unit, "focus") and not UnitIsUnit(unit, "player") and C.HighlightFocus then
		unitFrame.hlfocus:Show()
	else
		unitFrame.hlfocus:Hide()
	end
	
	if C.HighlightMode == "Vertical" then	--垂直箭頭
		if not C.numberstyle then
			if unitFrame.iconnumber and unitFrame.iconnumber > 0 then
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, C.auraiconsize+3)
			else
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
			end
		else
			if unitFrame.iconnumber and unitFrame.iconnumber > 0 then -- 有圖示
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.icons, "TOP", 0, 3)
			elseif UnitHealth(unit) and UnitHealthMax(unit) and UnitHealth(unit) ~= UnitHealthMax(unit) then -- 非滿血
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.healthperc, "TOP", 0, 0)
			else -- 只有名字
				unitFrame.hltarget:SetPoint("BOTTOM", unitFrame.name, "TOP", 0, 0)
			end
		end
	elseif C.HighlightMode == "Horizontal" then	--橫向箭頭
		if not C.numberstyle then
			unitFrame.hltarget:SetPoint("LEFT", unitFrame.healthBar, "RIGHT", 0, 0)
		else
			if C.show_power then
				if C.ShowPower[UnitName(unitFrame.displayedUnit)] then	--顯示能量
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

-- special update for mouseover highlight remove / 指向高亮
local function MouseoverOnUpdate(self, elapsed)
	if not UnitIsUnit(self.unit, "mouseover") then
		self.hlmo:Hide()
	end
end

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

-- Raid mark / 團隊標記
local function UpdateRaidTarget(unitFrame)
	local icon = unitFrame.RaidTargetFrame.RaidTargetIcon
	local index = GetRaidTargetIndex(unitFrame.displayedUnit)
	if ( index ) then
		SetRaidTargetIconTexture(icon, index)
		icon:Show()
	else
		icon:Hide()
	end
end

-- Update / 更新
local function UpdateNamePlateEvents(unitFrame)
	-- These are events affected if unit is in a vehicle
	local unit = unitFrame.unit
	local displayedUnit
	
	if ( unit ~= unitFrame.displayedUnit ) then
		displayedUnit = unitFrame.displayedUnit
	end
	
	unitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit)
	unitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit)
	
	if C.show_power then
		if C.ShowPower[UnitName(unitFrame.displayedUnit)] then
			unitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit)
			if not C.numberstyle then	-- 顯示能量條時微調名字位置
				unitFrame.powerBar:Show()
				unitFrame.powerBar.value:Show()
				unitFrame.name:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 5, 6)
				unitFrame.name:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", -5, -4)
			else
				unitFrame.powerperc:Show()
			end
		else
			unitFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
			if not C.numberstyle then
				unitFrame.powerBar:Hide()
				unitFrame.powerBar.value:Hide()
				unitFrame.name:SetPoint("TOPLEFT", unitFrame, "TOPLEFT", 5, 2)
				unitFrame.name:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", -5, -8)
			else
				unitFrame.powerperc:Hide()
			end
		end
	end
end

-- vehicle / 載具
local function UpdateInVehicle(unitFrame)
	if ( UnitHasVehicleUI(unitFrame.unit) ) then
		if ( not unitFrame.inVehicle ) then
			unitFrame.inVehicle = true
			local prefix, id, suffix = string.match(unitFrame.unit, "([^%d]+)([%d]*)(.*)")
			unitFrame.displayedUnit = prefix.."pet"..id..suffix
			UpdateNamePlateEvents(unitFrame)
		end
	else
		if ( unitFrame.inVehicle ) then
			unitFrame.inVehicle = false
			unitFrame.displayedUnit = unitFrame.unit
			UpdateNamePlateEvents(unitFrame)
		end
	end
end

-- Name-only mode / 名字模式
local function UpdateforNamemod(unitFrame)
	if not C.name_mod then return end
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

local function UpdateAll(unitFrame)
	UpdateInVehicle(unitFrame)
	if ( UnitExists(unitFrame.displayedUnit) ) then
		UpdateName(unitFrame)
		UpdateHealthColor(unitFrame)
		UpdateHealth(unitFrame)
		UpdateCastBar(unitFrame)
		UpdateSelectionHighlight(unitFrame)
		UpdateBuffs(unitFrame)
		UpdateRaidTarget(unitFrame)
		UpdateforNamemod(unitFrame)
		
		if UnitIsUnit("player", unitFrame.displayedUnit) then	-- 替個人資源微調位置
			unitFrame.castBar:UnregisterAllEvents()
			if not C.numberstyle then	-- 條形樣式
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
		
		if C.show_power and C.ShowPower[UnitName(unitFrame.displayedUnit)] then
			UpdatePower(unitFrame)
		end
	end
end

local function NamePlate_OnEvent(self, event, ...)
	local arg1 = ...
	if ( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" ) then
		UpdateName(self)
		UpdateSelectionHighlight(self)
	elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
		UpdateMouseover(self)
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		UpdateAll(self)
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == "UNIT_HEALTH_FREQUENT" ) then
			UpdateHealth(self)
			UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_AURA" ) then
			UpdateBuffs(self)
			UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_THREAT_LIST_UPDATE" ) then
			UpdateHealthColor(self)
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			UpdateName(self)
		elseif ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" ) then
			UpdateAll(self)
		elseif (C.show_power and event == "UNIT_POWER_FREQUENT" ) then
			if C.ShowPower[UnitName(self.displayedUnit)] then
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
	if ( unit ) then
		RegisterNamePlateEvents(unitFrame)
	else
		UnregisterNamePlateEvents(unitFrame)
	end
end

-- [[ Driver frame ]] --

local NamePlateDriverFrame = NamePlateDriverFrame
local function HideBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.SetupClassNameplateBars = function() end
	ClassNameplateManaBarFrame:Hide()
  
	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBar", function()  
		NamePlateTargetResourceFrame:Hide()
		NamePlatePlayerResourceFrame:Hide()
	end)

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
	if (namePlate) then
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
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))
	C_NamePlate.SetNamePlateFriendlySize(baseNamePlateWidth * horizontalScale, baseNamePlateHeight)
	C_NamePlate.SetNamePlateEnemySize(baseNamePlateWidth, baseNamePlateHeight)
	C_NamePlate.SetNamePlateSelfSize(baseNamePlateWidth, baseNamePlateHeight)

	for i, namePlate in ipairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = namePlate.UnitFrame
		UpdateAll(unitFrame)
	end
end

local function OnNamePlateCreated(namePlate)

	namePlate.UnitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate)
	namePlate.UnitFrame:SetAllPoints(namePlate)
	namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
	
	if C.numberstyle then -- 數字樣式
		namePlate.UnitFrame.healthperc = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
		namePlate.UnitFrame.healthperc:SetFont(G.numberstylefont, G.fontsize*1.75, G.fontflag)
		namePlate.UnitFrame.healthperc:SetPoint("CENTER")
		namePlate.UnitFrame.healthperc:SetTextColor(1,1,1)
		namePlate.UnitFrame.healthperc:SetShadowColor(0, 0, 0, 0.4)
		namePlate.UnitFrame.healthperc:SetShadowOffset(1, -1)
		namePlate.UnitFrame.healthperc:SetText("92")
		
		namePlate.UnitFrame.name = createtext(namePlate.UnitFrame, "ARTWORK", G.fontsize, G.fontflag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("TOP", namePlate.UnitFrame.healthperc, "BOTTOM", 0, -3)
		namePlate.UnitFrame.name:SetTextColor(1,1,1)
		namePlate.UnitFrame.name:SetText("Name")
		
		namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.castBar:Hide()
		namePlate.UnitFrame.castBar.iconWhenNoninterruptible = false
		if C.castbar then
			namePlate.UnitFrame.castBar:SetSize(110, 8)
			else
			namePlate.UnitFrame.castBar:SetSize(38,38)
		end
		if C.classresource_show and C.classresource == "target" then
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -7)
		else
			namePlate.UnitFrame.castBar:SetPoint("TOP", namePlate.UnitFrame.name, "BOTTOM", 0, -3)
		end

		if C.castbar then
			namePlate.UnitFrame.castBar:SetStatusBarTexture(G.ufbar)
			createBackdrop(namePlate.UnitFrame.castBar, namePlate.UnitFrame.castBar, 1) 
			else
			namePlate.UnitFrame.castBar:SetStatusBarTexture(G.iconcastbar)
		end
		namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5)
		
		namePlate.UnitFrame.castBar.border = CreateBDFrame(namePlate.UnitFrame.castBar, 0)
		CreateThinSD(namePlate.UnitFrame.castBar.border, 1, 0, 0, 0, 1, -2)
		
		namePlate.UnitFrame.castBar.bg = namePlate.UnitFrame.castBar:CreateTexture(nil, "BORDER")
		namePlate.UnitFrame.castBar.bg:SetAllPoints(namePlate.UnitFrame.castBar)
		namePlate.UnitFrame.castBar.bg:SetTexture(1/3, 1/3, 1/3, .5)

		namePlate.UnitFrame.castBar.Icon = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		if C.castbar then
			namePlate.UnitFrame.castBar.Icon:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -4, -8)
			namePlate.UnitFrame.castBar.Icon:SetSize(16, 16)
		else
			namePlate.UnitFrame.castBar.Icon:SetPoint("CENTER")
			namePlate.UnitFrame.castBar.Icon:SetSize(32, 32)
		end
		namePlate.UnitFrame.castBar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		namePlate.UnitFrame.castBar.iconborder = CreateBG(namePlate.UnitFrame.castBar.Icon)
		namePlate.UnitFrame.castBar.iconborder:SetDrawLayer("OVERLAY", -1)

		if C.cbtext then
			namePlate.UnitFrame.castBar.Text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
			namePlate.UnitFrame.castBar.Text:SetPoint("CENTER")
		end

		namePlate.UnitFrame.castBar.BorderShield = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
		namePlate.UnitFrame.castBar.BorderShield:SetSize(15, 15)
		namePlate.UnitFrame.castBar.BorderShield:SetPoint("CENTER", namePlate.UnitFrame.castBar, "BOTTOMLEFT")  
		namePlate.UnitFrame.castBar.BorderShield:SetDrawLayer("OVERLAY",2)

		namePlate.UnitFrame.castBar.Spark = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Spark:SetSize(30, 25)
		namePlate.UnitFrame.castBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		namePlate.UnitFrame.castBar.Spark:SetBlendMode("ADD")
		namePlate.UnitFrame.castBar.Spark:SetPoint("CENTER", 0, -1)
		if C.castbar then
			namePlate.UnitFrame.castBar.Spark:SetAlpha(1)
		else
			namePlate.UnitFrame.castBar.Spark:SetAlpha(0) --Disable this spark in icon style
		end
		
		namePlate.UnitFrame.castBar.Flash = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Flash:SetAllPoints()
		namePlate.UnitFrame.castBar.Flash:SetTexture(G.ufbar)
		namePlate.UnitFrame.castBar.Flash:SetBlendMode("ADD")
		
		CastingBarFrame_OnLoad(namePlate.UnitFrame.castBar, nil, false, true)
		namePlate.UnitFrame.castBar:SetScript("OnEvent", CastingBarFrame_OnEvent)
		namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
		namePlate.UnitFrame.castBar:SetScript("OnShow", CastingBarFrame_OnShow)

		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 4)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(G.raidicon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
		
		if C.HighlightMode == "Horizontal" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redarrow2)
		elseif C.HighlightMode == "Vertical" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redarrow1)
		else
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
			namePlate.UnitFrame.hltarget:SetTexture(G.hlglow)
			namePlate.UnitFrame.hltarget:SetPoint("LEFT", namePlate.UnitFrame.name, "TOPLEFT", -16, 0)
			namePlate.UnitFrame.hltarget:SetPoint("RIGHT", namePlate.UnitFrame.name,"TOPRIGHT", 16, 0)
			namePlate.UnitFrame.hltarget:SetVertexColor(0, 1, 1)
			namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 0)
			namePlate.UnitFrame.hltarget:SetBlendMode("ADD")
		end
		namePlate.UnitFrame.hltarget:Hide()
		
		namePlate.UnitFrame.hlfocus = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
		namePlate.UnitFrame.hlfocus:SetTexture(G.hlglow)
		namePlate.UnitFrame.hlfocus:SetPoint("LEFT", namePlate.UnitFrame.name, "TOPLEFT", -16, 0)
		namePlate.UnitFrame.hlfocus:SetPoint("RIGHT", namePlate.UnitFrame.name,"TOPRIGHT", 16, 0)
		namePlate.UnitFrame.hlfocus:SetVertexColor(1, 1, 0)
		namePlate.UnitFrame.hlfocus:SetTexCoord(0, 1, 1, 0)
		namePlate.UnitFrame.hlfocus:SetBlendMode("ADD")
		namePlate.UnitFrame.hlfocus:Hide()
		
		namePlate.UnitFrame.hlmo = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
		namePlate.UnitFrame.hlmo:SetTexture(G.hlglow)
		namePlate.UnitFrame.hlmo:SetPoint("LEFT", namePlate.UnitFrame.name, "TOPLEFT", -16, 0)
		namePlate.UnitFrame.hlmo:SetPoint("RIGHT", namePlate.UnitFrame.name,"TOPRIGHT", 16, 0)
		namePlate.UnitFrame.hlmo:SetVertexColor(1, 1, 1)
		namePlate.UnitFrame.hlmo:SetTexCoord(0, 1, 1, 0)
		namePlate.UnitFrame.hlmo:SetBlendMode("ADD")
		namePlate.UnitFrame.hlmo:Hide()

		namePlate.UnitFrame.icons = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.icons:SetPoint("BOTTOM", namePlate.UnitFrame.healthperc, "TOP", 0, 0)
		namePlate.UnitFrame.icons:SetWidth(140)
		namePlate.UnitFrame.icons:SetHeight(C.auraiconsize)
		namePlate.UnitFrame.icons:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2)
		
		namePlate.UnitFrame.powerperc = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
		namePlate.UnitFrame.powerperc:SetFont(G.numberstylefont, G.fontsize, G.fontflag)
		namePlate.UnitFrame.powerperc:SetPoint("LEFT", namePlate.UnitFrame.name, "RIGHT", 0, 0)
		namePlate.UnitFrame.powerperc:SetTextColor(.8,.8,1)
		namePlate.UnitFrame.powerperc:SetShadowColor(0, 0, 0, 0.4)
		namePlate.UnitFrame.powerperc:SetShadowOffset(1, -1)
		namePlate.UnitFrame.powerperc:SetText("55")
		
	else -- 條形樣式
		namePlate.UnitFrame.healthBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.healthBar:SetHeight(8)
		namePlate.UnitFrame.healthBar:SetPoint("LEFT", 0, 0)
		namePlate.UnitFrame.healthBar:SetPoint("RIGHT", 0, 0)
		namePlate.UnitFrame.healthBar:SetStatusBarTexture(G.ufbar)
		namePlate.UnitFrame.healthBar:SetMinMaxValues(0, 1)
		
		namePlate.UnitFrame.healthBar.bd = createBackdrop(namePlate.UnitFrame.healthBar, namePlate.UnitFrame.healthBar, 1)
		
		namePlate.UnitFrame.healthBar.value = createtext(namePlate.UnitFrame.healthBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
		namePlate.UnitFrame.healthBar.value:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", 0, -G.fontsize/3)
		namePlate.UnitFrame.healthBar.value:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.healthBar.value:SetText("Value")
		
		namePlate.UnitFrame.name = createtext(namePlate.UnitFrame.healthBar, "OVERLAY", G.fontsize-2, G.fontflag, "CENTER")
		namePlate.UnitFrame.name:SetPoint("BOTTOMLEFT", namePlate.UnitFrame.healthBar, "TOPLEFT", 5, 0)
		namePlate.UnitFrame.name:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", -5, 0)
		namePlate.UnitFrame.name:SetIndentedWordWrap(false)
		namePlate.UnitFrame.name:SetTextColor(1, 1, 1)
		namePlate.UnitFrame.name:SetText("Name")
		
		namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.castBar:Hide()
		namePlate.UnitFrame.castBar.iconWhenNoninterruptible = false
		namePlate.UnitFrame.castBar:SetHeight(8)
		if C.classresource_show and C.classresource == "target" then
			namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -7)
			namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -7)
		else
			namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -3)
			namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -3)
		end

		namePlate.UnitFrame.castBar:SetStatusBarTexture(G.ufbar)
		namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5)
		createBackdrop(namePlate.UnitFrame.castBar, namePlate.UnitFrame.castBar, 1) 
			
		namePlate.UnitFrame.castBar.Text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
		namePlate.UnitFrame.castBar.Text:SetPoint("TOPLEFT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -5, 5)
		namePlate.UnitFrame.castBar.Text:SetPoint("TOPRIGHT", namePlate.UnitFrame.castBar, "BOTTOMRIGHT", 5, -5)
		namePlate.UnitFrame.castBar.Text:SetText("Spell Name")
		
		namePlate.UnitFrame.castBar.Icon = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.Icon:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -4, -1)
		namePlate.UnitFrame.castBar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		if C.classresource_show and C.classresource == "target" then
			namePlate.UnitFrame.castBar.Icon:SetSize(25, 25)
		else
			namePlate.UnitFrame.castBar.Icon:SetSize(21, 21)
		end

		namePlate.UnitFrame.castBar.Icon.iconborder = CreateBG(namePlate.UnitFrame.castBar.Icon)
		namePlate.UnitFrame.castBar.Icon.iconborder:SetDrawLayer("OVERLAY", -1)
		
		namePlate.UnitFrame.castBar.BorderShield = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
		namePlate.UnitFrame.castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
		namePlate.UnitFrame.castBar.BorderShield:SetSize(15, 15)
		namePlate.UnitFrame.castBar.BorderShield:SetPoint("LEFT", namePlate.UnitFrame.castBar, "LEFT", 5, -5)

		namePlate.UnitFrame.castBar.Spark = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Spark:SetSize(30, 25)
		namePlate.UnitFrame.castBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		namePlate.UnitFrame.castBar.Spark:SetBlendMode("ADD")
		namePlate.UnitFrame.castBar.Spark:SetPoint("CENTER", 0, -1)
		
		namePlate.UnitFrame.castBar.Flash = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.castBar.Flash:SetAllPoints()
		namePlate.UnitFrame.castBar.Flash:SetTexture(G.ufbar)
		namePlate.UnitFrame.castBar.Flash:SetBlendMode("ADD")
		
		CastingBarFrame_OnLoad(namePlate.UnitFrame.castBar, nil, false, true)
		namePlate.UnitFrame.castBar:SetScript("OnEvent", CastingBarFrame_OnEvent)
		namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
		namePlate.UnitFrame.castBar:SetScript("OnShow", CastingBarFrame_OnShow)

		namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
		namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
		
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(G.raidicon)
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
		namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
		
		if C.HighlightMode == "Horizontal" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redarrow2)
		elseif C.HighlightMode == "Vertical" then
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "OVERLAY")
			namePlate.UnitFrame.hltarget:SetSize(50, 50)
			namePlate.UnitFrame.hltarget:SetTexture(G.redarrow1)
		else
			namePlate.UnitFrame.hltarget = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
			namePlate.UnitFrame.hltarget:SetTexture(G.hlglow)
			namePlate.UnitFrame.hltarget:SetPoint("BOTTOMLEFT", namePlate.UnitFrame, "LEFT", -10, 4)
			namePlate.UnitFrame.hltarget:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "RIGHT", 10, 0)
			namePlate.UnitFrame.hltarget:SetVertexColor(0, 0.65, 1, 0.9)
			namePlate.UnitFrame.hltarget:SetTexCoord(0, 1, 1, 0)
			namePlate.UnitFrame.hltarget:SetBlendMode("ADD")
		end
		namePlate.UnitFrame.hltarget:Hide()
		
		namePlate.UnitFrame.hlfocus = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
		namePlate.UnitFrame.hlfocus:SetTexture(G.hlglow)
		namePlate.UnitFrame.hlfocus:SetPoint("BOTTOMLEFT", namePlate.UnitFrame, "LEFT", -10, 4)
		namePlate.UnitFrame.hlfocus:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "RIGHT", 10, 0)
		namePlate.UnitFrame.hlfocus:SetVertexColor(1, 1, 0)
		namePlate.UnitFrame.hlfocus:SetTexCoord(0, 1, 1, 0)
		namePlate.UnitFrame.hlfocus:SetBlendMode("ADD")
		namePlate.UnitFrame.hlfocus:Hide()
		
		namePlate.UnitFrame.hlmo = namePlate.UnitFrame:CreateTexture("$parent_Arrow", "BACKGROUND")
		namePlate.UnitFrame.hlmo:SetTexture(G.hlglow)
		namePlate.UnitFrame.hlmo:SetPoint("BOTTOMLEFT", namePlate.UnitFrame, "LEFT", -10, 4)
		namePlate.UnitFrame.hlmo:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "RIGHT", 10, 0)
		namePlate.UnitFrame.hlmo:SetVertexColor(1, 1, 1)
		namePlate.UnitFrame.hlmo:SetTexCoord(0, 1, 1, 0)
		namePlate.UnitFrame.hlmo:SetBlendMode("ADD")
		namePlate.UnitFrame.hlmo:Hide()
		
		namePlate.UnitFrame.icons = CreateFrame("Frame", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.icons:SetPoint("BOTTOM",namePlate.UnitFrame.name, "TOP", 0, -2)
		namePlate.UnitFrame.icons:SetWidth(140)
		--namePlate.UnitFrame.icons:SetWidth(namePlate.UnitFrame:GetWidth()) namePlate.UnitFrame.name:GetStringWidth()
		namePlate.UnitFrame.icons:SetHeight(C.auraiconsize)
		namePlate.UnitFrame.icons:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2)
		
		namePlate.UnitFrame.powerBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
		namePlate.UnitFrame.powerBar:SetHeight(3)
		namePlate.UnitFrame.powerBar:SetPoint("BOTTOMLEFT", namePlate.UnitFrame.healthBar, "TOPLEFT", 0, 2)
		namePlate.UnitFrame.powerBar:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", 0, 2)
		namePlate.UnitFrame.powerBar:SetStatusBarTexture(G.ufbar)
		namePlate.UnitFrame.powerBar:SetMinMaxValues(0, 1)
		
		namePlate.UnitFrame.powerBar.bd = createBackdrop(namePlate.UnitFrame.powerBar, namePlate.UnitFrame.powerBar, 1)
		
		namePlate.UnitFrame.powerBar.value = createtext(namePlate.UnitFrame.healthBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
		namePlate.UnitFrame.powerBar.value:SetPoint("BOTTOMLEFT", namePlate.UnitFrame.healthBar, "TOPLEFT", 0, -G.fontsize/3)
		namePlate.UnitFrame.powerBar.value:SetText("55")
		
	end
	
	namePlate.UnitFrame:EnableMouse(false)
end

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

-- [[ cvar ]] --

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
	-- fix fps drop(距離縮放與描邊功能會引起掉幀)
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

local function NamePlates_OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		HideBlizzard()
		if C.playerplate then
			SetCVar("nameplateShowSelf", 1)
		else
			SetCVar("nameplateShowSelf", 0)
		end
		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "NAME_PLATE_CREATED" ) then
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then
		local unit = ...
		OnNamePlateAdded(unit)
	elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "RAID_TARGET_UPDATE" then
		OnRaidTargetUpdate()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "UNIT_FACTION" ) then
		OnUnitFactionChanged(...)
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
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