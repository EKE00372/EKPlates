local addon, ns = ...
local oUF = ns.oUF
local C, F, G, T = unpack(ns)

--================================================--
-----------------    [[ CVAR ]]    -----------------
--================================================--

local function OnEvent()
	-- 貼齊邊緣
	if C.Inset then
		SetCVar("nameplateOtherTopInset", .05)			-- default: .08
		SetCVar("nameplateOtherBottomInset", .09)		-- default: .1
		SetCVar("nameplateLargeTopInset", .05)
		SetCVar("nameplateLargeBottomInset", .09)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
		SetCVar("nameplateLargeTopInset", -1)
		SetCVar("nameplateLargeBottomInset", -1)
	end
	
	SetCVar("nameplateShowAll", 1)						-- always show / 總是顯示名條，1開
	SetCVar("nameplateMotion", 1)						-- motion style / 名條排列，1=堆疊，0=重疊
	SetCVar("nameplateMotionSpeed", .01)				-- motion speed / 名條位移速度，預設0.025
	
	SetCVar("nameplateShowSelf", 0)						-- force disable blizzard self nameplate / 顯示個人資源
	SetCVar("nameplateResourceOnTarget", 0)				-- 在目標名條上顯示職業資源
	
	SetCVar("nameplateMaxDistance", C.MaxDistance)		-- max show distance / 最大視距, default: 60
	SetCVar("nameplateSelectedScale", C.SelectedScale)	-- target scale / 當前目標大小
	SetCVar("nameplateMinAlpha", C.MinAlpha)			-- non-target alpha / 非當前目標透明度, default: 0.8
	SetCVar("nameplateOccludedAlphaMult", 0.2)			-- Occluded nameplate alpha / 障礙物後的名條透名度, default: 0.4
	
	SetCVar("nameplateLargerScale", 1)					-- boss nameplate scale, default: 1.2
	SetCVar("nameplateLargeTopInset", .08) 				-- boss nameplate top inset
	SetCVar("nameplateLargeBottomInset", .09)			-- boss nameplate bottom inset
	
	-- fix fps drop (距離縮放與描邊功能可能引起掉幀)
	SetCVar("namePlateMinScale", 1)						-- default is 0.8
	SetCVar("namePlateMaxScale", 1)
	
	-- 調整堆疊血條的間距
	if C.NumberStyle then
		SetCVar("nameplateOverlapH",  .7)				-- default is 0.8
		SetCVar("nameplateOverlapV",  .9)				-- default is 1.1
	else
		SetCVar("nameplateOverlapH",  .6)				-- default is 0.8
		SetCVar("nameplateOverlapV",  .8)				-- default is 1.1
	end
	
	-- 敵方顯示條件
	SetCVar("nameplateShowEnemyGuardians", 1)			-- 守護者
	SetCVar("nameplateShowEnemyMinions", 1)				-- 僕從
	--SetCVar("nameplateShowEnemyPets", 0)				-- 寵物
	SetCVar("nameplateShowEnemyTotems", 1)				-- 圖騰
	SetCVar("nameplateShowEnemyMinus", 1)				-- 次要
	-- 友方顯示條件
	SetCVar("nameplateShowFriendlyGuardians", 0)		-- 守護者
	SetCVar("nameplateShowFriendlyMinions", 0)			-- 僕從
	SetCVar("nameplateShowFriendlyNPCs", 0)				-- npc
	SetCVar("nameplateShowFriendlyPets", 0)				-- 寵物
	SetCVar("nameplateShowFriendlyTotems", 0)			-- 圖騰
end

local defaultCVar = CreateFrame("FRAME", nil)
	defaultCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
	defaultCVar:SetScript("OnEvent", OnEvent)

--==================================================--
-----------------    [[ Colors ]]    -----------------
--==================================================--

-- [[ 名字染色 ]] --

local function UpdateColor(self, unit)
	local style = self:GetParent().mystyle
	
	local npcID = F.GetNPCID(UnitGUID(unit))
	--local npcName = GetUnitName(unit, false)
	--local customUnit = C.CustomUnits and (C.CustomUnits[npcName] or C.CustomUnits[npcID])
	local customUnit = C.CustomUnits and C.CustomUnits[npcID]

	local tap = UnitIsTapDenied(unit) and not UnitPlayerControlled(unit)
	local disconnected = not UnitIsConnected(unit)

	local player = UnitIsPlayer(unit)
	local class = select(2, UnitClass(unit))
	local ccolor = oUF.colors.class[class] or 1, 1, 1
	
	local status = UnitThreatSituation("player", unit) or false		-- just in case
	local tcolor = oUF.colors.threat[status] or 1, 1, 1
	
	local reaction = UnitReaction(unit, "player")
	local rcolor = oUF.colors.reaction[reaction] or 1, 1, 1

	local r, g, b
	
	if disconnected then				-- 離線
		r, g, b = .7, .7, .7
	else
		if customUnit then				-- 目標白名單
			r, g, b = unpack(customUnit)
		elseif player and (reaction and reaction >= 5) then
			if C.friendlyCR then
				r, g, b =  unpack(ccolor)
			else						-- 標準pve狀態玩家色
				r, g, b = .3, .3, 1
			end
		elseif player and (reaction and reaction <= 4) then
			if C.enemyCR then
				r, g, b =  unpack(ccolor)
			else						-- 標準pve狀態玩家色
				r, g, b = .3, .3, 1
			end
		elseif tap then					-- 無拾取權
			r, g, b = .3, .3, .3
		elseif status then				-- 威脅值
			r, g, b = unpack(tcolor)
		else							-- 陣營染色
			r, g, b = unpack(rcolor)
		end
	end
	
	if r or g or b then
		if style ~= "BP" then			-- 數字模式(非條形模式)的染色在名字上
			self:SetTextColor(r, g, b)
		else							-- 條形模式的染色在血條上，並渲染背景
			self:SetStatusBarColor(r, g, b)
			self.bg:SetVertexColor(r*.3, g*.3, b*.3)
		end
	end
end

-- [[ 名字仇恨染色 ]] --

local function UpdateThreatColor(self, _, unit)
	if unit ~= self.unit then return end
	if self.mystyle == "BP" then
		UpdateColor(self.Health, unit)
	else
		UpdateColor(self.Name, unit)
	end
end

--=================================================--
-----------------    [[ Auras ]]    -----------------
--=================================================--

-- [[ 在光環圖示定位前，重置光環index，以更新位置 ]] --

local function PreSetPosition(self, max)
	return 1, self.visibleAuras
end

-- [[ 自訂光環位置 ]] --

local function SetPosition(self, from, to)
	for i = from, to do
		local button = self[i]
		if not button then break end

		if i == 1 then
			-- 第一個aura向左位移的格數是總數-1，所以是to(=last aura)-1
			button:SetPoint("CENTER", -(((self.size + self.spacing) * (to - 1)) / 2), 0)
		else
			-- 每一個aura都要anchor到前一個光環 所以是i-1
			button:SetPoint("LEFT", self[i-1], "RIGHT", self.spacing, 0)
		end
	end
end

-- [[ 光環 ]] --

local function CreeateAuras(self, unit)
	local style = self.mystyle
	
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetWidth(self:GetWidth())
	
	if style == "PP" then
		Auras:SetHeight(C.AuraSize + 6)
		Auras.size = C.AuraSize + 6
	else
		Auras:SetHeight(C.AuraSize)
		Auras.size = C.AuraSize
	end
	
	Auras.spacing = 5
	Auras.numTotal = C.Auranum
	Auras.disableMouse = true
	Auras.gap = false
	
	-- 選項
	Auras.disableCooldown = true
	Auras.showDebuffType = true
	Auras.showBuffType = true
	Auras.showStealableBuffs = true
	-- 註冊到ouf
	self.Auras = Auras
	
	self.Auras.PreSetPosition = PreSetPosition
	self.Auras.SetPosition = SetPosition
	
	self.Auras.PostCreateIcon = T.PostCreateIcon
	self.Auras.PostUpdateIcon = T.PostUpdateIcon
	self.Auras.CustomFilter = T.CustomFilter				-- 光環過濾	
	self.Auras.PreUpdate = T.BolsterPreUpdate				-- 激勵
	self.Auras.PostUpdate = T.BolsterPostUpdate				-- 激勵計數
end

--=====================================================--
-----------------    [[ Highlight ]]    -----------------
--=====================================================--

-- [[ 目標高亮 ]] --

-- 判斷目標
local function UpdateHighlight(self, unit)
	local mark = self.TargetIndicator
		
	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		if mark then mark:Show() end
		-- 當前目標：藍色
		mark:SetBackdropColor(0, .85, 1, .8)
		mark:SetBackdropBorderColor(0, .85, 1, .8)
	elseif UnitIsUnit(self.unit, "focus") and not UnitIsUnit(self.unit, "player") then
		if mark then mark:Show() end
		-- 焦點目標：綠色
		mark:SetBackdropColor(.3, 1, .3, .8)
		mark:SetBackdropBorderColor(.3, 1, .3, .8)
	else
		if mark then mark:Hide() end
	end
end

-- 目標高亮
local function TargetIndicator(self)
	local Mark = CreateFrame("Frame", nil, self, "BackdropTemplate")	
	
	if self.mystyle == "NP" then
		Mark:SetPoint("TOPLEFT", self.Name, -10, 8)
		Mark:SetPoint("BOTTOMRIGHT", self.Name, 10, -10)
	else
		Mark:SetPoint("TOPLEFT", self.Health, -12, 12)
		Mark:SetPoint("BOTTOMRIGHT", self.Health, 12, -12)
	end
	
	F.CreateBackdrop(Mark, 10)
	Mark:SetFrameLevel(self:GetFrameLevel() - 2)
	Mark:EnableMouse(false)
	Mark:Hide()
	
	-- 註冊到ouf
	self.TargetIndicator = Mark
	
	-- 切換目標時重新判斷
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateHighlight, true)
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", UpdateHighlight, true)
	table.insert(self.__elements, UpdateHighlight)
end

-- [[ 指向高亮 ]] --

-- 判斷指向
local function isMouseoverUnit(self, unit, elapsed)
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") and not (UnitIsUnit("target", self.unit) or UnitIsUnit("focus", self.unit)) then
		return UnitIsUnit("mouseover", self.unit)
	end
	
	return false
end

-- 更新狀態
local function OnUpdateMouseover(self, unit)
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) and not (UnitIsUnit("target", self.unit) or UnitIsUnit("focus", self.unit))then
		self.hl:Show()
		self.MouseoverIndicator:Show()
	else
		self.hl:Hide()
		self.MouseoverIndicator:Hide()
	end
end

-- 指向高亮
local function MouseoverIndicator(self)
	local hl = CreateFrame("Frame", nil, self, "BackdropTemplate")

	if self.mystyle == "NP" then
		hl:SetPoint("TOPLEFT", self.Name, -10, 8)
		hl:SetPoint("BOTTOMRIGHT", self.Name, 10, -10)
	else
		hl:SetPoint("TOPLEFT", self.Health, -12, 12)
		hl:SetPoint("BOTTOMRIGHT", self.Health, 12, -12)
	end
	
	F.CreateBackdrop(hl, 10)
	hl:SetFrameLevel(self:GetFrameLevel() - 2)
	hl:SetBackdropColor(1, 1, 0, .8)
	hl:SetBackdropBorderColor(1, 1, 0, .8)
	hl:EnableMouse(false)
	hl:Hide()
	
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", OnUpdateMouseover, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", OnUpdateMouseover, true)
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", OnUpdateMouseover, true)
	
	local update = CreateFrame("Frame", nil, self)
	-- 指向高亮的EVENT只有移入時觸發，必需用OnUpdate來代替移出檢測
	update:SetScript("OnUpdate", function(_, elapsed)
		update.elapsed = (update.elapsed or 0) + elapsed
		if update.elapsed > .1 then
			if not isMouseoverUnit(self) then
				update:Hide()
			end
			update.elapsed = 0
		end
	end)
	
	update:HookScript("OnHide", function()
		hl:Hide()
	end)
	
	-- 註冊到ouf
	self.hl = hl
	self.MouseoverIndicator = update
end

--=======================================================--
-----------------    [[ NamePlates ]]    ------------------
--=======================================================--

-- [[ 數字模式 ]] --

local function CreateNumberPlates(self, unit)
	self.mystyle = "NP"
	
	if not unit:match("nameplate") then
		return
	end
	
	-- 框體
	self:SetSize(C.NPWidth + 10, G.NPFS * 2)
	self:SetPoint("CENTER", 0, 0)

	-- 名字
	self.Name = F.CreateText(self, "OVERLAY", G.Font, G.NPNameFS, G.FontFlag, "CENTER")
	self.Name:SetPoint("BOTTOM", 0, 6)
	self:Tag(self.Name, "[name]")
	self.Name.UpdateColor = UpdateColor	
	-- 血量
	self.HealthText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPFS, G.FontFlag, "CENTER")
	self.HealthText:SetPoint("BOTTOM", self.Name,"TOP", 0, 0)
	self.HealthText.frequentUpdates = .1
	self:Tag(self.HealthText, "[np:hp]")
	-- 能量
	self.PowerText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPNameFS, G.FontFlag, "LEFT")
	self.PowerText:SetPoint("LEFT", self.Name, "RIGHT", 2, 0)
	self:Tag(self.PowerText, "[np:pp]")

	-- 威脅值
	local threat = CreateFrame("Frame", nil, self)
	self.ThreatIndicator = threat
	self.ThreatIndicator.Override = UpdateThreatColor

	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(24, 24)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.Name, "LEFT", 0, 0)
	self.RaidTargetIndicator = RaidIcon
	
	-- 施法條
	T.CreateIconCastbar(self, unit)
	self.Castbar:SetPoint("TOP", self.Name, "BOTTOM", 0, -4)
	
	-- 光環
	if C.ShowAuras then
		CreeateAuras(self, unit)
		self.Auras:SetPoint("BOTTOM", self.HealthText, "TOP", 0, 2)
	end
	-- 指向高亮
	if C.HLMouseover then
		MouseoverIndicator(self)
	end
	-- 目標高亮
	if C.HLTarget then
		TargetIndicator(self)
	end
end

-- [[ 條形模式 ]] --

local function CreateBarPlates(self, unit)
	self.mystyle = "BP"
	
	if not unit:match("nameplate") then
		return
	end
	
	-- 框體
	self:SetSize(C.NPWidth, C.NPHeight*5)
	self:SetPoint("CENTER", 0, 0)

	-- 創建一個條
	local Health = F.CreateStatusbar(self, G.addon..unit, "ARTWORK", C.NPHeight, C.NPWidth, 0, 0, 0, 1)
	Health:SetPoint("CENTER", self, 0, 0)
	Health:SetFrameLevel(self:GetFrameLevel() + 2)
	-- 選項
	-- Health.colorTapping	= true
	-- Health.colorClass	= true
	-- Health.colorReaction	= true
	-- Health.colorThreat	= true
	-- 陰影
	Health.border = F.CreateSD(Health, Health, 3)
	-- 背景
	Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints()
	Health.bg:SetTexture(G.media.blank)
	Health.bg.multiplier = .3
	
	-- 註冊到ouf
	self.Health = Health
	self.Health.UpdateColor = UpdateThreatColor
	
	-- 名字
	self.Name = F.CreateText(self.Health, "OVERLAY", G.Font, G.NPNameFS-2, G.FontFlag, "CENTER")
	self.Name:SetPoint("BOTTOM", self.Health, "TOP",  0, 4)
	self:Tag(self.Name, "[name]")
	-- 血量
	self.Health.value = F.CreateText(self.Health, "OVERLAY", G.Font, G.NPNameFS-2, G.FontFlag, "RIGHT")
	self.Health.value:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, -4)
	self:Tag(self.Health.value, "[bp:hp]")
	-- 能量
	self.PowerText = F.CreateText(self.Health, "OVERLAY", G.Font, G.NPNameFS-2, G.FontFlag, "RIGHT")
	self.PowerText:SetPoint("LEFT", self.Health, "RIGHT", 4, 1)
	self:Tag(self.PowerText, "[np:pp]")

	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(28, 28)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
	self.RaidTargetIndicator = RaidIcon

	-- 施法條
	T.CreateStandaloneCastbar(self, unit)
	
	-- 光環
	if C.ShowAuras then
		CreeateAuras(self, unit)
		self.Auras:SetPoint("BOTTOM", self.Name, "TOP", 0, 4)
	end
	-- 指向高亮
	if C.HLMouseover then
		MouseoverIndicator(self)
	end
	-- 目標高亮
	if C.HLTarget then
		TargetIndicator(self)
	end
end

-- [[ 更新元素 ]] --

local function PostUpdatePlates(self, event, unit)
	if not self then return end	
	-- 目標高亮
	UpdateHighlight(self)
	-- 使數字模式的施法條位置能正確隨每個名條的施法狀態重置
	if C.NumberStyle then
		T.PostCastStopUpdate(self, event, unit)
	end
end

--=======================================================--
-----------------    [[ PlayerPlate ]]    -----------------
--=======================================================--

-- [[ 模仿ndui關閉暴雪的個人資源條，自己創建一個玩家名條 ]] --

local function CreatePlayerNumberPlate(self, unit)
	self.mystyle = "PP"
	
	-- 框體，因為這其實是創建了一個偽頭像，所以不像名條無視UI縮放，要做大點......吧
	self:SetSize(C.NPWidth, G.NPFS*2 + C.AuraSize)
	
	-- 血量
	self.HealthText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPFS*2, G.FontFlag, "CENTER")
	self.HealthText:SetPoint("BOTTOMLEFT", self, 0, C.PPOffset*2)
	self:Tag(self.HealthText, "[perhp]")
	-- 能量
	self.PowerText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPNameFS+2, G.FontFlag, "LEFT")
	self.PowerText:SetPoint("BOTTOMLEFT", self.HealthText, "BOTTOMRIGHT", 0, 0)
	self:Tag(self.PowerText, "[unit:pp]")
	
	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(28, 28)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.HealthText, "LEFT", 0, 0)
	self.RaidTargetIndicator = RaidIcon
	
	-- 副資源
	T.CreateClassPower(self, unit)
	
	-- 光環
	if C.PlayerBuffs then
		CreeateAuras(self, unit)
		self.Auras.numDebuffs = 0
		self.Auras:SetPoint("BOTTOM", self.HealthText, "TOP", 0, 0)
	end
end

local function CreatePlayerBarPlate(self, unit)
	self.mystyle = "PP"
	
	-- 框體，因為這其實是創建了一個偽頭像，所以不像名條無視UI縮放，要做大點......吧
	self:SetSize(C.PPWidth, C.NPHeight*5)
	self:SetPoint("CENTER", 0, 0)

	-- 創建一個條
	local Health = F.CreateStatusbar(self, G.addon..unit, "ARTWORK", C.NPHeight+4, C.PPWidth, 0, 0, 0, 1)
	Health:SetPoint("CENTER", self, 0, 0)
	Health:SetFrameLevel(self:GetFrameLevel() + 2)
	-- 選項
	Health.colorClass = true		-- 職業染色
	-- 陰影
	Health.border = F.CreateSD(Health, Health, 3)
	-- 背景
	Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints()
	Health.bg:SetTexture(G.media.blank)
	Health.bg.multiplier = .3
	-- 註冊到ouf
	self.Health = Health
	
	local Power = F.CreateStatusbar(self, G.addon..unit, "ARTWORK", (C.NPHeight+4)/2, C.PPWidth, 0, 0, 0, 1)
	Power:SetPoint("TOP", self.Health, "BOTTOM",  0, -1)
	Power:SetFrameLevel(self:GetFrameLevel() + 2)
	-- 選項
	Power.frequentUpdates = true	-- 更新速率
	Power.colorPower = true			-- 職業染色
	-- 陰影
	Power.border = F.CreateSD(Power, Power, 3)
	-- 背景
	Power.bg = Power:CreateTexture(nil, "BACKGROUND")
	Power.bg:SetAllPoints()
	Power.bg:SetTexture(G.media.blank)
	Power.bg.multiplier = .3
	-- 註冊到ouf
	self.Power = Power
	
	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(28, 28)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.Health, "LEFT", -4, -2)
	self.RaidTargetIndicator = RaidIcon
	
	-- 光環
	if C.PlayerBuffs then
		CreeateAuras(self, unit)
		self.Auras.numDebuffs = 0
		self.Auras:SetPoint("BOTTOM", self.Health, "TOP", 0, 8)
	end
	
	-- 副資源
	T.CreateClassPower(self, unit)
	-- 吸收盾
	T.CreateHealthPrediction(self, unit)
end

--===================================================--
--------------    [[ RegisterStyle ]]     -------------
--===================================================--

if C.NumberStyle then
	oUF:RegisterStyle("Nameplate", CreateNumberPlates)
else
	oUF:RegisterStyle("Nameplate", CreateBarPlates)
end

if C.PlayerPlate then
	if C.NumberstylePP then
		oUF:RegisterStyle("PlayerPlate", CreatePlayerNumberPlate)
	else
		oUF:RegisterStyle("PlayerPlate", CreatePlayerBarPlate)
	end
end

--===================================================--
-----------------    [[ Spawn ]]     ------------------
--===================================================--

oUF:Factory(function(self)
	self:SetActiveStyle("Nameplate")
	self:SpawnNamePlates("oUF_Nameplate", PostUpdatePlates)

	if C.PlayerPlate then
		self:SetActiveStyle("PlayerPlate")
		local plate = self:Spawn("player", "oUF_PlayerPlate", true)
		plate:SetPoint(unpack(C.Position.PlayerPlate))
	end
end)