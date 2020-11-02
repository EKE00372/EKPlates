local addon, ns = ...
local oUF = ns.oUF
local C, F, G, T = unpack(ns)

--===================================================--
-----------------    [[ Castbar ]]    -----------------
--===================================================--

-- [[ 方塊施法條 ]] --

T.CreateIconCastbar = function(self, unit)
	local Castbar = CreateFrame("StatusBar", nil, self)
	Castbar:SetSize(C.NPCastIcon, C.NPCastIcon)
	Castbar:SetFrameLevel(self:GetFrameLevel() + 2)
	Castbar.Border = F.CreateBD(Castbar, Castbar, 1, 0, 0, 0, 1)
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
	
	-- 選項
	Castbar.timeToHold = 0.05
	-- 註冊到ouf
	self.Castbar = Castbar
	self.Castbar.PostCastStart = T.PostCastStart			-- 開始施法
	self.Castbar.PostCastStop = T.PostCastStop				-- 施法結束
	self.Castbar.PostCastFail = T.PostCastFailed			-- 施法失敗
	self.Castbar.PostCastInterruptible = T.PostUpdateCast	-- 打斷狀態刷新
end

-- [[ 條形施法條 ]]--

T.CreateStandaloneCastbar = function(self, unit)
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
	Castbar.Spark:SetSize(C.NPHeight/2, C.NPHeight*2)
	Castbar.Spark:SetPoint("RIGHT", Castbar:GetStatusBarTexture(), C.NPHeight/4, 0)
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

	-- 選項
	Castbar.timeToHold = 0.05
	-- 註冊到ouf
	self.Castbar = Castbar
	self.Castbar.PostCastStart = T.PostCastStart
	self.Castbar.PostCastFail = T.PostCastFailed			-- 施法失敗
	self.Castbar.PostCastInterruptible = T.PostUpdateCast	-- 打斷狀態刷新
end

--===================================================--
------------------    [[ Others ]]    -----------------
--===================================================--

-- [[ 職業資源 ]] --

T.CreateClassPower = function(self, unit)
	if not F.Multicheck(G.myClass, "PRIEST", "MAGE", "WARLOCK", "ROGUE", "MONK", "DRUID", "PALADIN", "DEATHKNIGHT") then return end
	
	local ClassPower = {}
	
	for i = 1, 6 do
		-- 創建總體條
		ClassPower[i] = F.CreateStatusbar(self, G.addon..unit.."_ClassPowerBar"..i, "ARTWORK", nil, nil, 1, 1, 0, 1)
		ClassPower[i].border = F.CreateSD(ClassPower[i], ClassPower[i], 3)
		ClassPower[i]:SetFrameLevel(self:GetFrameLevel() + 2)
		
		ClassPower[i]:SetSize((C.PPWidth- 5*C.PPOffset)/6, C.PPHeight)
		
		if C.NumberStyle then
			if i == 1 then
				ClassPower[i]:SetPoint("TOP", self.HealthText, "BOTTOM", -(C.PPWidth - 3*C.PPOffset)/2, -C.PPOffset)
			else
				ClassPower[i]:SetPoint("LEFT", ClassPower[i-1], "RIGHT", C.PPOffset, 0)
			end
		else
			if i == 1 then
				ClassPower[i]:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -4)
			else
				ClassPower[i]:SetPoint("LEFT", ClassPower[i-1], "RIGHT", C.PPOffset, 0)
			end
		end
		
		if G.myClass == "DEATHKNIGHT" then
			ClassPower[i].bg = ClassPower[i]:CreateTexture(nil, "BACKGROUND")
			ClassPower[i].bg:SetAllPoints()
			ClassPower[i].bg:SetTexture(G.media.blank)
			ClassPower[i].bg.multiplier = .4
			ClassPower[i].timer = F.CreateText(ClassPower[i], "OVERLAY", G.Font, G.NameFS, G.FontFlag, "CENTER")
			ClassPower[i].timer:SetPoint("CENTER", 0, 0)
		end
	end
	
	-- 註冊到ouf並整合符文顯示
	if G.myClass == "DEATHKNIGHT" then
		ClassPower.colorSpec = true
		ClassPower.sortOrder = "asc"
		self.Runes = ClassPower
		self.Runes.PostUpdate = T.PostUpdateRunes
	else
		self.ClassPower = ClassPower
		self.ClassPower.PostUpdate = T.PostUpdateClassPower
	end
end

-- [[ 酒池 ]] --
--[[
T.CreateStagger = function(self, unit)
	if G.myClass ~= "MONK" then return end
	
	local Stagger = F.CreateStatusbar(self, G.addon..unit.."_StaggerBar", "ARTWORK", nil, nil, 1, 1, 0, 1)
	Stagger:SetFrameLevel(self:GetFrameLevel() + 2)
	Stagger:SetHeight(C.PPHeight)
	Stagger:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, C.PPOffset)
	Stagger:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, C.PPOffset)
	
	-- 背景
	Stagger.bg = Stagger:CreateTexture(nil, "BACKGROUND")
	Stagger.bg:SetAllPoints()
	Stagger.bg:SetTexture(G.media.blank)
	Stagger.bg.multiplier = .3
	-- 陰影
	Stagger.border = F.CreateSD(Stagger, Stagger, 3)
	
	-- 註冊到ouf	
	self.Stagger = Stagger
	self.Stagger.PostUpdate = T.PostUpdateStagger
	-- 文本
	self.Stagger.value = F.CreateText(self.Stagger, "OVERLAY", G.Font, G.NameFS, G.FontFlag, nil)
	self.Stagger.value:SetPoint("CENTER", self.Stagger, 0, 0)
	self.Stagger.value:SetJustifyH("CENTER")
end
]]--
-- [[ 預估治療 ]] --

T.CreateHealthPrediction = function(self, unit)
	local AbsorbBar = F.CreateStatusbar(self, G.addon..unit.."_AbsorbBar", "ARTWORK", nil, nil, 0, .5, .8, .5)
	AbsorbBar:SetFrameLevel(self:GetFrameLevel() + 2)
	AbsorbBar:SetSize(C.NPWidth+40, C.NPHeight+4)
	AbsorbBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")

	-- 只做了吸收盾，治療吸收盾跟其他一堆都沒
	self.HealthPrediction = {
        absorbBar = AbsorbBar,
		maxOverflow = 1,
    }
end