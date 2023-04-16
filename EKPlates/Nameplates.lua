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
	SetCVar("nameplateLargeBottomInset", .1)			-- boss nameplate bottom inset
	
	-- avoid fps drop (距離縮放與描邊功能可能引起掉幀)
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


--=====================================================--
-----------------    [[ NameColor ]]    -----------------
--=====================================================--

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

--===================================================--
-----------------    [[ Castbar ]]    -----------------
--===================================================--

-- [[ 方塊施法條 ]] --

local function CreateIconCastbar(self, unit)
	local Castbar = F.CreateStatusbar(self, G.addon..unit.."_CastBar", "ARTWORK", C.NPCastIcon, C.NPCastIcon, .6, .6, .6, 1)
	Castbar:SetFrameLevel(self:GetFrameLevel() + 2)
	Castbar.BD = F.CreateBD(Castbar, Castbar, 1, 0, 0, 0, 1)
	
	-- 圖示
	Castbar.Icon = Castbar:CreateTexture(nil, "OVERLAY", nil, 1)
	Castbar.Icon:SetSize(C.NPCastIcon-6, C.NPCastIcon-6)
	Castbar.Icon:SetPoint("CENTER")
	Castbar.Icon:SetTexCoord(.08, .92, .08, .92)
	-- 圖示邊框
	Castbar.IconBD = Castbar:CreateTexture(nil, "OVERLAY", nil, -1)
	Castbar.IconBD:SetPoint("TOPLEFT", Castbar.Icon, -1, 1)
	Castbar.IconBD:SetPoint("BOTTOMRIGHT", Castbar.Icon, 1, -1)
	Castbar.IconBD:SetTexture(G.media.blank)
	Castbar.IconBD:SetVertexColor(0, 0, 0)
	-- 法術名
	--[[Castbar.Text = F.CreateText(Castbar, "OVERLAY", G.Font, G.NPNameFS-4, G.FontFlag, "CENTER")
	Castbar.Text:SetPoint("CENTER", Castbar, 0, 5)
	Castbar.Text:SetPoint("BOTTOMLEFT", Castbar, "TOPLEFT", -5, 5)
	Castbar.Text:SetPoint("BOTTOMRIGHT", Castbar, "TOPRIGHT", 5, -5)
	Castbar.Text:SetText("")]]--
	
	-- 選項
	Castbar.timeToHold = 0.05
	-- 註冊到ouf
	self.Castbar = Castbar
	self.Castbar.PostCastStart = T.PostStandaloneCastStart			-- 開始施法
	self.Castbar.PostCastStop = T.PostCastStop						-- 施法結束
	self.Castbar.PostCastFail = T.PostStandaloneCastFailed			-- 施法失敗
	self.Castbar.PostCastInterruptible = T.PostUpdateStandaloneCast	-- 打斷狀態刷新
end

-- [[ 條形施法條 ]]--

local function CreateStandaloneCastbar(self, unit)
	local Castbar = F.CreateStatusbar(self, G.addon..unit.."_CastBar", "ARTWORK", C.NPHeight, nil, .6, .6, .6, 1)
	Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	Castbar:SetFrameLevel(self:GetFrameLevel() + 2)
	Castbar.BarShadow = F.CreateSD(Castbar, Castbar, 3)
	-- 施法條背景
	Castbar.bg = Castbar:CreateTexture(nil, "BACKGROUND")
	Castbar.bg:SetAllPoints()
	Castbar.bg:SetTexture(G.media.blank)
	Castbar.bg:SetVertexColor(.15, .15, .15)
	-- 進度高亮
	Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
	Castbar.Spark:SetTexture(G.media.spark)
	Castbar.Spark:SetBlendMode("ADD")
	Castbar.Spark:SetVertexColor(1, 1, .85, .5)
	Castbar.Spark:SetSize(C.NPHeight*2, C.NPHeight)
	Castbar.Spark:SetPoint("RIGHT", Castbar:GetStatusBarTexture(), 0, 0)
	-- 圖示
	Castbar.Icon = Castbar:CreateTexture(nil, "OVERLAY")
	Castbar.Icon:SetSize(C.NPHeight*2 + 4, C.NPHeight*2 + 4)
	Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -4, 0)
	Castbar.Icon:SetTexCoord(.08, .92, .08, .92)
	-- 圖示邊框
	Castbar.IconSD = F.CreateSD(Castbar, Castbar.Icon, 3)
	Castbar.IconBD = F.CreateBD(Castbar, Castbar.Icon, 1, .15, .15, .15, 1)
	-- 法術名
	Castbar.Text = F.CreateText(Castbar, "OVERLAY", G.Font, G.NPNameFS-2, G.FontFlag, "CENTER")
	Castbar.Text:SetPoint("TOPLEFT", Castbar, "BOTTOMLEFT", -5, 5)
	Castbar.Text:SetPoint("TOPRIGHT", Castbar, "BOTTOMRIGHT", 5, -5)
	
	Castbar.spellTarget = F.CreateText(Castbar, "OVERLAY", G.Font, G.NPNameFS-2, G.FontFlag, "CENTER")
	Castbar.spellTarget:ClearAllPoints()
	Castbar.spellTarget:SetJustifyH("LEFT")
	Castbar.spellTarget:SetPoint("TOP", Castbar.Text, "BOTTOM", 0, -2)

	-- 選項
	Castbar.timeToHold = 0.05
	-- 註冊到ouf
	self.Castbar = Castbar
	self.Castbar.PostCastStart = T.PostStandaloneCastStart			-- 施法開始
	self.Castbar.PostCastStop = T.PostCastStop						-- 施法中斷
	self.Castbar.PostCastFail = T.PostStandaloneCastFailed			-- 施法失敗
	self.Castbar.PostCastInterruptible = T.PostUpdateStandaloneCast	-- 打斷狀態更新
	self.Castbar.PostCastUpdate = T.PostCastUpdate					-- 施法目標更新
	-- 根據UNIT_TARGET檢測名條單位的目標變更
	self:RegisterEvent("UNIT_TARGET", function(_, _, unit)
		T.UpdateSpellTarget(self.Castbar, unit)
	end)
end

--=================================================--
-----------------    [[ Auras ]]    -----------------
--=================================================--

-- [[ 替名條重做光環排列方式為置中對齊 ]] --

local function SetPosition(self, from, to)
	local num = #self.sortedBuffs + #self.sortedDebuffs
	
	for i = 1, num do
		local button = self[i]
		if not button then break end
		
		if i == 1 then
			-- 第一個aura向左位移的格數是總數-1，所以是to(=last aura)-1
			button:SetPoint("CENTER", -(((self.size + self.spacing) * (num - 1)) / 2), 0)
		else
			-- 每一個aura都要anchor到前一個光環，所以是i-1
			button:SetPoint("LEFT", self[i-1], "RIGHT", self.spacing, 0)
		end
	end
end

-- [[ 光環 ]] --

local function CreateAuras(self, unit)
	local style = self.mystyle
	
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetWidth(self:GetWidth())
	
	if style == "NPP" or style == "BPP" then
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
	Auras.reanchorIfVisibleChanged = true
	-- 註冊到ouf
	self.Auras = Auras
	
	self.Auras.SetPosition = SetPosition
	self.Auras.PostCreateButton = T.PostCreateIcon
	self.Auras.PostUpdateButton = T.PostUpdateIcon
	self.Auras.FilterAura = T.CustomFilter				-- 光環過濾
	self.Auras.PostUpdateInfo = T.BolsterPostUpdateInfo -- 激勵
end

--=====================================================--
-----------------    [[ Highlight ]]    -----------------
--=====================================================--

-- [[ 目標高亮 ]] --

-- 判斷目標，更新顏色
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

-- 創建目標高亮
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
	Mark:Hide()	-- 預設隱藏
	
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
	hl:Hide()	-- 預設隱藏
	
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", OnUpdateMouseover, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", OnUpdateMouseover, true)
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", OnUpdateMouseover, true)
	
	local update = CreateFrame("Frame", nil, self)
	-- 指向高亮的事件只在移入時觸發，必需用OnUpdate來代替移出檢測
	update:SetScript("OnUpdate", function(_, elapsed)
		update.elapsed = (update.elapsed or 0) + elapsed
		-- 限制更新頻率
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
	-- 使數字模式的狀態顏色在名字上更新
	self.Name.UpdateColor = UpdateColor
	-- 血量
	self.HealthText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPFS, G.FontFlag, "CENTER")
	self.HealthText:SetPoint("BOTTOM", self.Name,"TOP", 0, 2)
	self.HealthText.frequentUpdates = .1
	self:Tag(self.HealthText, "[np:hp]")
	
	-- 能量
	self.PowerText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPNameFS, G.FontFlag, "LEFT")
	self.PowerText:SetPoint("LEFT", self.Name, "RIGHT", 2, 0)
	self:Tag(self.PowerText, "[np:pp]")
	-- 吸收量，血量百分比形式
	self.AbsorbText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPNameFS-2, G.FontFlag, "LEFT")
	self.AbsorbText:SetPoint("BOTTOMLEFT", self.HealthText, "BOTTOMRIGHT", 0, 0)
	self:Tag(self.AbsorbText, "[np:ab]")
	
	-- 施法條
	CreateIconCastbar(self, unit)
	self.Castbar:SetPoint("TOP", self.Name, "BOTTOM", 0, -4)
	-- 施法目標
	--self.CastTargetText = F.CreateText(self.Castbar, "OVERLAY", G.Font, G.NPNameFS-4, G.FontFlag, "RIGHT")
	--self.CastTargetText:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -2)
	--self:Tag(self.CastTargetText, "[npcast]")
	
	-- 目標名字，用於惡意詞綴的怨毒幽影
	self.TargetName = F.CreateText(self.Castbar, "OVERLAY", G.Font, G.NPNameFS-4, G.FontFlag, "RIGHT")
	self.TargetName:ClearAllPoints()
	self.TargetName:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, 0)
	self.TargetName:Hide()
	self:Tag(self.TargetName, "[np:tar]")
	
	-- 威脅值，使狀態顏色在名字上更新
	local threat = CreateFrame("Frame", nil, self)
	self.ThreatIndicator = threat
	self.ThreatIndicator.Override = UpdateThreatColor

	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(24, 24)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.Name, "LEFT", 0, 0)
	self.RaidTargetIndicator = RaidIcon
	
	-- 光環
	if C.ShowAuras then
		CreateAuras(self, unit)
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
	self.mystyle = "BP" -- Bar style Nameplates
	
	if not unit:match("nameplate") then return end
	
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
	-- 取代ouf本身對名條顏色的設定
	self.Health.PostUpdateColor = UpdateColor
	
	-- 威脅值，取代ouf本身對名條顏色的設定
	local threat = CreateFrame("Frame", nil, self)
	self.ThreatIndicator = threat
	self.ThreatIndicator.Override = UpdateThreatColor
	
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
	-- 目標名字，用於惡意詞綴的怨毒幽影
	self.TargetName = F.CreateText(self, "OVERLAY", G.Font, G.NPNameFS-4, G.FontFlag, "RIGHT")
	self.TargetName:ClearAllPoints()
	self.TargetName:SetPoint("TOP", self.Health, "BOTTOM", 0, -4)
	self.TargetName:Hide()
	self:Tag(self.TargetName, "[np:tar]")
	
	-- 團隊標記
	local RaidIcon = self:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(28, 28)
	RaidIcon:SetTexture(G.media.raidicon)
	RaidIcon:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
	self.RaidTargetIndicator = RaidIcon

	-- 施法條
	CreateStandaloneCastbar(self, unit)
	-- 吸收盾
	T.CreateHealthPrediction(self, unit)
	
	-- 光環
	if C.ShowAuras then
		CreateAuras(self, unit)
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

	-- 每個名條創建時獲取該單位的npc id，在名條消失時清空
	if event == "NAME_PLATE_UNIT_ADDED" then
		self.npcID = F.GetNPCID(UnitGUID(unit))
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
	end
	
	--[[if event == "UNIT_SPELLCAST_START" then
		T.UpdateSpellTarget(self, event, unit)
	end]]--
	
	-- 顯示特定目標的目標：將判斷置於PostUpdatePlates中，只在觸發更新時檢測一次
	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		self.TargetName:SetShown(C.UnitTarget[self.npcID])
	end
end

--=======================================================--
-----------------    [[ PlayerPlate ]]    -----------------
--=======================================================--

-- [[ 關閉暴雪的個人資源條，自己創建一個玩家名條，因為暴雪的資源條有很多衍生問題 ]] --

local function CreatePlayerNumberPlate(self, unit)
	self.mystyle = "NPP" -- Number style Player Plate
	
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
	-- 吸收量
	self.AbsorbText = F.CreateText(self, "OVERLAY", G.NPFont, G.NPNameFS+2, G.FontFlag, "LEFT")
	self.AbsorbText:SetPoint("BOTTOMLEFT", self.PowerText, "TOPLEFT", 0, 0)
	self:Tag(self.AbsorbText, "[np:ab]")
	
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
		CreateAuras(self, unit)
		self.Auras.numDebuffs = 0
		self.Auras:SetPoint("BOTTOM", self.HealthText, "TOP", 0, 0)
	end
	
	if C.Fade then
		self.FadeMinAlpha = C.FadeOutAlpha
		self.FadeInSmooth = 0.4
		self.FadeOutSmooth = 1.5
		self.FadeCasting = true
		self.FadeCombat = true
		self.FadeTarget = true
		self.FadeHealth = true
		self.FadePower = true
		self.FadeHover = true
	end
end

local function CreatePlayerBarPlate(self, unit)
	self.mystyle = "BPP" -- Bar style Player Plate
	
	-- 框體，因為這其實是創建了一個偽頭像，所以不像名條無視UI縮放，要做大點......吧
	self:SetSize(C.PlayerNPWidth, C.NPHeight*5)
	self:SetPoint("CENTER", 0, 0)

	-- 創建一個條
	local Health = F.CreateStatusbar(self, G.addon..unit, "ARTWORK", C.NPHeight+4, C.PlayerNPWidth, 0, 0, 0, 1)
	Health:SetPoint("CENTER", self, 0, 0)
	Health:SetFrameLevel(self:GetFrameLevel() + 2)
	-- 選項
	Health.colorClass = true			-- 職業染色
	-- 陰影
	Health.border = F.CreateSD(Health, Health, 3)
	-- 背景
	Health.bg = Health:CreateTexture(nil, "BACKGROUND")
	Health.bg:SetAllPoints()
	Health.bg:SetTexture(G.media.blank)
	Health.bg.multiplier = .3
	-- 註冊到ouf
	self.Health = Health
	
	local Power = F.CreateStatusbar(self, G.addon..unit, "ARTWORK", (C.NPHeight+4)/2, C.PlayerNPWidth, 0, 0, 0, 1)
	Power:SetPoint("TOP", self.Health, "BOTTOM",  0, -1)
	Power:SetFrameLevel(self:GetFrameLevel() + 2)
	-- 選項
	Power.frequentUpdates  = true		-- 更新速率
	Power.colorPower   = true			-- 職業染色
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
		CreateAuras(self, unit)
		self.Auras.numDebuffs = 0
		self.Auras:SetPoint("BOTTOM", self.Health, "TOP", 0, 8)
	end
	
	-- 副資源
	T.CreateClassPower(self, unit)
	-- 吸收盾
	T.CreateHealthPrediction(self, unit)
	
	if C.Fade then
		self.FadeMinAlpha = C.FadeOutAlpha
		self.FadeInSmooth = 0.4
		self.FadeOutSmooth = 1.5
		self.FadeCasting = true
		self.FadeCombat = true
		self.FadeTarget = true
		self.FadeHealth = true
		self.FadePower = true
		self.FadeHover = true
	end
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