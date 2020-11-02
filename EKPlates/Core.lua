local addon, ns = ...
local oUF = ns.oUF
local C, F, G, T = unpack(ns)

-- note:
-- 在CreateCastbar裡的self.Castbar中，self指的是頭像本身
-- 而在施法條、光環、副資源等元素的PostUpdate中，self指的是self.Castbar，即施法條元素自身
-- 為了防止搞混，這裡的function(self, unit)有些會寫為function(element, unit)，例如ouf core、ndui等
-- 有些仍寫為function(castbar, unit)，例如ouf_mlight、farva等

--===================================================--
-----------------    [[ Castbar ]]    -----------------
--===================================================--

-- [[ 開始施法 ]] --
T.PostCastStart = function(self, unit)
	local frame = self:GetParent()
	
	if frame.mystyle == "NP" then
		-- 數字模式名條名字上移
		frame.Name:SetPoint("BOTTOM", 0, 6+G.NPNameFS)
	else
		self.Spark:SetAlpha(.5)
	end

	if unit == "player" then
		self:SetStatusBarColor(unpack(C.CastNormal))
	else
		if self.notInterruptible then
			self:SetStatusBarColor(unpack(C.CastShield))			-- 紫色條
		else
			self:SetStatusBarColor(unpack(C.CastNormal))
		end
	end
end

-- [[ 停止施法 ]] --

T.PostCastStop = function(self, unit)
	local frame = self:GetParent()
	if frame.mystyle == "NP" then
		-- 使數字模式名條的名字復位
		frame.Name:SetPoint("BOTTOM", 0, 6)
	end
end

-- [[ 狀態更新 ]] --

T.PostCastStopUpdate = function(self, event, unit)
	-- 施法過程中切換目標、新生成的名條，按施法結束處理
	if unit ~= self.unit then return end
	return T.PostCastStop(self.Castbar, unit)
end


T.PostCastFailed = function(self, unit)
	local frame = self:GetParent()
	-- 一閃而過的施法失敗紅色條
	self:SetStatusBarColor(unpack(C.CastFailed))
	self:SetValue(self.max)
	if frame.mystyle ~= "NP" then
		self.Spark:SetAlpha(0)
	end
	self:Show()
end

-- [[ 施法過程中更新打斷狀態 ]] --

-- 例子：燃燒王座三王小怪
T.PostUpdateCast = function(self, unit)
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(C.CastShield))				-- 紫色條
	else
		self:SetStatusBarColor(unpack(C.CastNormal))
	end
end

-- [[ 自定格式的施法時間 ]] --

T.CustomTimeText = function(self, duration)
	if self.__owner.unit == "player" and self.delay ~= 0 then
		if self.casting then
			self.Time:SetFormattedText("%.1f/%.1f |cffff0000+%.1f|r", duration, self.max, self.delay)
		elseif self.channeling then
			self.Time:SetFormattedText("%.1f/%.1f |cffff0000+%.1f|r", self.max - duration, self.max, self.delay)
		end
	else
		if self.casting then
			self.Time:SetFormattedText("%.1f/%.1f", duration, self.max)
		elseif self.channeling then
			self.Time:SetFormattedText("%.1f/%.1f", self.max - duration, self.max)
		end
	end
end

--===================================================--
-------------------    [[ Auras ]]    -----------------
--===================================================--

-- [[ 顯示光環時間 ]] --

T.CreateAuraTimer = function(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	
	if self.elapsed >= 0.1 then
		local timeLeft = self.timeLeft - GetTime()
		if timeLeft > 0 then
			self.time:SetText(F.FormatTime(timeLeft))
		else
			self:SetScript("OnUpdate", nil)
			self.time:SetText(nil)
		end
	self.elapsed = 0
	end
end

-- [[ 獲得光環時創建光環 ]] --

T.PostCreateIcon = function(self, button)
	-- 切邊
	button.icon:SetTexCoord(.08, .92, .08, .92)
	-- 邊框
	button.overlay:SetTexture(G.media.blank)
	button.overlay:SetDrawLayer("BACKGROUND")
	button.overlay:SetPoint("TOPLEFT", button.icon, "TOPLEFT", -1, 1)
	button.overlay:SetPoint("BOTTOMRIGHT", button.icon, "BOTTOMRIGHT", 1, -1)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	-- 時間
	button.time = F.CreateText(button, "OVERLAY", G.NFont, G.NumberFS, G.FontFlag, "LEFT")
	button.time:ClearAllPoints()
	button.time:SetPoint("TOP", button, 0, 4)
	-- 層數
	button.count = F.CreateText(button, "OVERLAY", G.NFont, G.NumberFS, G.FontFlag, "RIGHT")
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", button, 0, 0)
	button.count:SetTextColor(.9, .9, .1)
	-- 陰影
	button.shadow = F.CreateSD(button, button.overlay, 3)
end

-- [[ 更新光環 ]] --

T.PostUpdateIcon = function(self, unit, button, _, _, duration, expiration, debuffType)
	local style = self.__owner.mystyle
	local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none

	-- 更新陰影
	if duration then
		button.shadow:Show()
	end
	
	-- 更新overlay
	if style == "PP" then
		-- 玩家名條固定灰色
		button.overlay:SetVertexColor(.6, .6, .6)
	elseif style == "NP" or style == "BP"  or style == "R" then
		-- 名條上的光環一率按類型染色
		button.overlay:SetVertexColor(color[1], color[2], color[3])
	else
		if button.icon:GetTexture() ~= nil then
			-- 只在有圖示的時候才顯示overlay，並顯示debuff type
			-- 避免啟用gap時，間隔buff和debuff的占位空aura icon出現陰影
			button.overlay:Show()
			-- 頭像上減益效果按類型染色，增益效果固定灰色
			if button.isDebuff then
				local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
				button.overlay:SetVertexColor(color[1], color[2], color[3])
			else
				button.overlay:SetVertexColor(.6, .6, .6)
			end
		else
			button.overlay:Hide()
		end	
	end
	
	-- 更新時間
	if duration and duration > 0 then
		button.timeLeft = expiration
		button:SetScript("OnUpdate", T.CreateAuraTimer)
		button.time:Show()
	else
		button:SetScript("OnUpdate", nil)
		button.time:Hide()
	end
	
	button.first = true
end

-- [[ 光環過濾 ]] --

-- 替激勵設一個初始層數並用於重置
T.BolsterPreUpdate = function(self)
	self.bolster = 0
	self.bolsterIndex = nil
end

-- 更新激勵層數
T.BolsterPostUpdate = function(self)
	if not self.bolsterIndex then return end
	for _, button in pairs(self) do
		if button == self.bolsterIndex then
			button.count:SetText(self.bolster)
			return
		end
	end
end

-- 光環過濾
T.CustomFilter = function(self, unit, button, name, _, _, _, duration, expiration, caster, isStealable, _, spellID, _, isBossDebuff, casterIsPlayer, nameplateShowAll)
	local style = self.__owner.mystyle
	local npc = not UnitIsPlayer(unit)
	
	if name and spellID == 209859 then			-- 激勵顯示為層數
		self.bolster = (self.bolster or 0) + 1
		if not self.bolsterIndex then
			self.bolsterIndex = button
			return true
		end
	elseif style == "NP" or style == "BP" then
		if UnitIsUnit("player", unit) then		-- 當該單位是自己(自身名條，只是預防有人把個人資源打開搞事)
			return false
		elseif self.showStealableBuffs and isStealable and npc then	-- 非玩家，可驅散
			return true
		elseif C.BlackList[spellID] then		-- 黑名單
			return false
		elseif C.WhiteList[spellID] then		-- 白名單(主要補足暴雪白名單沒有的法術)
			return true
		else									-- 暴雪內建的控場白名單和玩家/寵物/載具的法術
			return nameplateShowAll or F.Multicheck(caster, "player", "pet", "vehicle")
		end
	elseif style == "PP" then					-- 個人資源條顯示30秒(含)以下的光環
		if C.PlayerBlackList[spellID] then
			return false
		elseif C.PlayerWhiteList[spellID] then
			return true
		else
			return F.Multicheck(caster, "player", "pet", "vehicle") and duration <= 30 and duration ~= 0
		end
	else
		return true
	end
end

--=================================================--
-----------------    [[ Power ]]    -----------------
--=================================================--

-- [[ 酒池文本 ]] --
--[[
T.PostUpdateStagger = function(self, cur, max)
	local perc = cur / max
	
	if cur == 0 then
		self.value:SetText("")
	else
		self.value:SetText(F.ShortValue(cur) .. " |cff70C0F5" .. F.ShortValue(perc * 100) .. "|r")
	end
end
]]--
-- [[ 坦克資源的天賦更新 ]] --
--[[
T.PostUpdateTankResource = function(self, cur, max, MaxChanged)
	if not max or not cur then return end
	
	local style = self.__owner.mystyle

	for i = 1, 4 do
		if MaxChanged then
			if style == "VL" then
				self[i]:SetHeight((C.PWidth - (max-1) * C.PPOffset) / max)
			elseif style == "PP" then
				self[i]:SetWidth((C.NPWidth - (max-1) * C.PPOffset) / max)
			else
				self[i]:SetWidth((C.PWidth - (max-1) * C.PPOffset) / max)
			end
		end
	end
end
]]--
-- [[ 連擊點的天賦更新 ]] --

T.PostUpdateClassPower = function(self, cur, max, MaxChanged, powerType)
	if not max or not cur then return end
	
	local style = self.__owner.mystyle
	local cpColor = {
	--{1, .8, .5},
	{1, .7, .1},
	{1, .95, .4},		-- 滿星
	}
	
	for i = 1, 6 do
		if MaxChanged then
			self[i]:SetWidth((C.PPWidth - (max-1) * C.PPOffset) / max)
		end
		
		if F.Multicheck(G.myClass, "ROUGE", "DRUID") then
			if max > 0 and cur == max then
				self[i]:SetStatusBarColor(unpack(cpColor[2]))
			else
				self[i]:SetStatusBarColor(unpack(cpColor[1]))
			end
		end
	end
end

-- [[ 符能 ]] --

T.OnUpdateRunes = function(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.timer then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(F.FormatTime(remain))
		else
			self.timer:SetText(nil)
		end
	end
end

-- [[ 把ouf/rune整段搬過來 ]] --

T.PostUpdateRunes = function(self, runemap)
	for index, runeID in next, runemap do
		local rune = self[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				--rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then rune.timer:SetText(nil) end
			elseif start then
				--rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", T.OnUpdateRunes)
			end
		end
	end
end