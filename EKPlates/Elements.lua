local addon, ns = ...
local oUF = ns.oUF
local C, F, G, T = unpack(ns)

--===================================================--
------------------    [[ Others ]]    -----------------
--===================================================--

-- [[ 職業資源 ]] --

T.CreateClassPower = function(self, unit)
	if not F.Multicheck(G.myClass, "PRIEST", "MAGE", "WARLOCK", "ROGUE", "MONK", "DRUID", "PALADIN", "DEATHKNIGHT", "EVOKER") then return end
	--if F.Multicheck(G.myClass, "WARRIOR", "HUNTER", "SHAMAN") then return end
	
	local isDK = G.myClass == "DEATHKNIGHT"
	local maxPoint = (isDK and 6) or 7
	
	local ClassPower = {}
	
	for i = 1, maxPoint do
		-- 創建總體條
		ClassPower[i] = F.CreateStatusbar(self, G.addon..unit.."_ClassPowerBar"..i, "ARTWORK", nil, nil, 1, 1, 0, 1)
		ClassPower[i].border = F.CreateSD(ClassPower[i], ClassPower[i], 4)
		ClassPower[i]:SetFrameLevel(self:GetFrameLevel() + 2)
		
		if self.mystyle == "NPP" or self.mystyle == "BPP" then
			ClassPower[i]:SetSize((C.PlayerNPWidth - (maxPoint-1)*C.PPOffset)/maxPoint, C.PPHeight)
			
			if C.NumberStylePP then
				if i == 1 then
					ClassPower[i]:SetPoint("TOP", self.HealthText, "BOTTOM", -(C.PlayerNPWidth - 3*C.PPOffset)/2, -C.PPOffset)
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
		else
			ClassPower[i]:SetSize((C.PWidth - 6*C.PPOffset)/maxPoint, C.PPHeight)
			
			if i == 1 then
				ClassPower[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, C.PPOffset)
			else
				ClassPower[i]:SetPoint("LEFT", ClassPower[i-1], "RIGHT", C.PPOffset, 0)
			end
		end
		
		if isDK then
			ClassPower[i].bg = ClassPower[i]:CreateTexture(nil, "BACKGROUND")
			ClassPower[i].bg:SetAllPoints()
			ClassPower[i].bg:SetTexture(G.media.blank)
			ClassPower[i].bg.multiplier = .4
			ClassPower[i].timer = F.CreateText(ClassPower[i], "OVERLAY", G.Font, G.NameFS, G.FontFlag, "CENTER")
			ClassPower[i].timer:SetPoint("CENTER", 0, 0)
		end
		
		--[[if G.myClass == "EVOKER" then
			ClassPower[i].bg = ClassPower[i]:CreateTexture(nil, "BACKGROUND")
			ClassPower[i].bg:SetAllPoints()
			ClassPower[i].bg:SetTexture(G.media.blank)
			ClassPower[i].bg.multiplier = .4
			ClassPower[i].timer = F.CreateText(ClassPower[i], "OVERLAY", G.Font, G.NameFS, G.FontFlag, "CENTER")
			ClassPower[i].timer:SetPoint("CENTER", 0, 0)
		end]]--
	end
	
	-- 註冊到ouf並整合符文顯示
	if isDK then
		ClassPower.colorSpec = true
		ClassPower.sortOrder = "asc"
		--ClassPower.__max = 6
		self.Runes = ClassPower
		self.Runes.PostUpdate = T.PostUpdateRunes
	else
		self.ClassPower = ClassPower
		self.ClassPower.PostUpdate = T.PostUpdateClassPower
	end
end

-- [[ 額外能量 暗牧鳥德薩滿的法力 ]] --

T.CreateAddPower = function(self, unit)
	if not F.Multicheck(G.myClass, "DRUID", "SHAMAN", "PRIEST") then return end
	
	-- 創建一個條
	local AddPower = F.CreateStatusbar(self, G.addon..unit.."_AddPowerBar", "ARTWORK", nil, nil, 1, 1, 0, 1)
	AddPower:SetFrameLevel(self:GetFrameLevel() + 2)
	AddPower:SetHeight(C.PPHeight)
	AddPower:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, C.PPOffset)
	AddPower:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, C.PPOffset)
	
	-- 選項
	AddPower.colorPower = true
	-- 背景
	AddPower.bg = AddPower:CreateTexture(nil, "BACKGROUND")
	AddPower.bg:SetAllPoints()
	AddPower.bg:SetTexture(G.media.blank)
	AddPower.bg.multiplier = .3
	-- 陰影
	AddPower.border = F.CreateSD(AddPower, AddPower, 4)
	-- 註冊到ouf
	self.AdditionalPower = AddPower
	-- 文本
	self.AdditionalPower.value = F.CreateText(self.AdditionalPower, "OVERLAY", G.Font, G.NameFS, G.FontFlag, "LEFT")
end

-- [[ 酒池 ]] --

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
	Stagger.border = F.CreateSD(Stagger, Stagger, 4)
	
	-- 註冊到ouf	
	self.Stagger = Stagger
	self.Stagger.PostUpdate = T.PostUpdateStagger
	-- 文本
	self.Stagger.value = F.CreateText(self.Stagger, "OVERLAY", G.Font, G.NameFS, G.FontFlag, nil)
	if self.mystyle == "VL" then
		self.Stagger.value:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMLEFT", -C.PPOffset, (G.NameFS + 2)*2)
		self.Stagger.value:SetJustifyH("RIGHT")
	else
		self.Stagger.value:SetPoint("CENTER", self.Stagger, 0, 0)
		self.Stagger.value:SetJustifyH("CENTER")
	end
end

-- [[ 預估治療 ]] --

T.CreateHealthPrediction = function(self, unit)
	local AbsorbBar = F.CreateStatusbar(self, G.addon..unit.."_AbsorbBar", "ARTWORK", nil, nil, 0, .5, .8, .5)
	AbsorbBar:SetFrameLevel(self:GetFrameLevel() + 2)
	
	if self.mystyle == "VL" then
		-- 玩家直式
		AbsorbBar:SetSize(C.PHeight, C.PWidth)
		AbsorbBar:SetOrientation("VERTICAL")
		AbsorbBar:SetPoint("BOTTOM", self.Health:GetStatusBarTexture(), "BOTTOM")
	elseif self.mystyle == "BP" then
		-- 條形名條
		AbsorbBar:SetSize(C.NPWidth, C.NPHeight)
		AbsorbBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
	elseif self.mystyle == "BPP" then
		-- 條形個人資源條
		AbsorbBar:SetSize(C.PlayerNPWidth, C.NPHeight+4)
		AbsorbBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
	else
		-- 玩家橫式
		AbsorbBar:SetSize(C.PWidth, C.PHeight)
		AbsorbBar:SetReverseFill(true)
		AbsorbBar:SetPoint("TOP")
		AbsorbBar:SetPoint("BOTTOM")
		AbsorbBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
	end

	-- 只做了吸收盾，治療吸收盾跟其他一堆都還沒做
	self.HealthPrediction = {
        absorbBar = AbsorbBar,
        -- healAbsorbBar
		-- overAbsorb
		-- overHealAbsorb
        frequentUpdates = true,
    }
end
