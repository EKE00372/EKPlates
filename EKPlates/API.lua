local addon, ns = ... 
local C, F, G, T = unpack(ns)

--======================================================--
-----------------    [[ Functions ]]    ------------------
--======================================================--

-- [[ 多重條件匹配 ]] --

-- 使用範例：
-- F.Multicheck(unit, "player", "boss", "pet")
F.Multicheck = function(check, ...)
	for i = 1, select("#", ...) do
		if check == select(i, ...) then
			return true
		end
	end
	return false
end

-- [[ 獲取 npc id ]] --

F.GetNPCID = function(guid)
	local id = tonumber(strmatch((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

--===================================================--
-----------------    [[ Format ]]    ------------------
--===================================================--

-- [[ 數值 ]] --

F.ShortValue = function(val)
	-- 讓20k不顯示為20.0k
	local round = function(val, idp)
		if idp and idp > 0 then
			local mult = 10^idp
			return math.floor(val * mult + 0.5) / mult
		end
		return math.floor(val + 0.5)
	end

	if val >= 1e9 then
		-- 億至小數點後四位
		return ("%.4fb"):format(val / 1e9)
	elseif val >= 1e6 then
		-- 百萬至小數點後二位
		return ("%.2fm"):format(val / 1e6)
	elseif val >= 1e5 then
		-- 十萬顯示千取整
		return ("%.fk"):format(val / 1e3)	
	elseif val >= 1e3 and val < 1e5 then
		-- 不滿十萬顯示千後小數點一位
		return round(val / 1e3, 1).."k"
	else
		-- 千以下
		return ("%d"):format(val)
	end
end

-- [[ 顏色 ]] --

F.Hex = function(r, g, b)
	-- 未定義則白色
	if not r then return "|cffFFFFFF" end
	
	if type(r) == "table" then
		if(r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	
	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end

-- [[ 計時 ]] --

F.FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	
	if s >= day then
		-- 天
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		-- 時
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		-- 五分以下
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		else
		-- 五分以上
			return format("%dm", floor(s/minute + 0.5)), s % minute
		end
	else
		return format("%d", s + .5), s - floor(s)
	end
end

--======================================================--
-----------------    [[ Templates ]]    ------------------
--======================================================--

-- [[ 文字 ]] --

-- 格式：父級框體，層級，字型，字型大小，描邊，對齊
F.CreateText = function(parent, layer, font, fontsize, fontflag, justify)
	local text = parent:CreateFontString(nil, layer)
	text:SetFont(font, fontsize, fontflag)
	text:SetShadowOffset(0, 0)
	text:SetWordWrap(false)

	if justify then
		text:SetJustifyH(justify)
	end
	
	return text
end

-- [[ 框體模板 ]] --

-- 格式：父級框體，大小
F.CreateBackdrop = function(parent, size)
	parent:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",		-- 背景
		edgeFile = G.media.glow,						-- 陰影邊框
		edgeSize = size,								-- 邊框大小
		tile = false, tilesize = size,
		insets = {left = size, right = size, top = size, bottom = size}	-- 正值內縮，負值外擴
	})
end

-- [[ 背景與邊框 ]] --

-- 格式：父級框體，錨點，大小，紅，綠，藍，透明度
F.CreateBD = function(parent, anchor, size, r, g, b, a)
	local bd = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	local framelvl = parent:GetFrameLevel()
	
	bd:ClearAllPoints()
	bd:SetPoint("TOPLEFT", anchor, "TOPLEFT", -size, size)
	bd:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", size, -size)
	bd:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	bd:SetBackdrop({
		bgFile = G.media.blank,		-- 背景
		edgeFile = G.media.blank,	-- 邊框
		edgeSize = size or 1,		-- 邊框大小
		})
	bd:SetBackdropColor(r or 0, g or 0, b or 0, a or 0)
	bd:SetBackdropBorderColor(r or 0, g or 0, b or 0, a or 0)
	
	return bd
end

-- [[ 陰影 ]] --

-- 格式：父級框體，錨點，大小
F.CreateSD = function(parent, anchor, size)
	local sd = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	local framelvl = parent:GetFrameLevel()
	
	sd:ClearAllPoints()
	sd:SetPoint("TOPLEFT", anchor, -size, size)
	sd:SetPoint("BOTTOMRIGHT", anchor, size, -size)
	sd:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	sd:SetBackdrop({
		edgeFile = G.media.glow,	-- 陰影邊框
		edgeSize = size or 3,		-- 邊框大小
	})
	--sd:SetBackdropColor(0, 0, 0, 1)
	--sd:SetBackdropBorderColor(0, 0, 0, 1)
	sd:SetBackdropBorderColor(.05, .05, .05, 1)
	
	return sd
end

-- [[ 狀態條 ]] --

-- 格式：父級框體，自身框體名，層級，高度，寬度，紅，綠，藍，透明度
F.CreateStatusbar = function(parent, name, layer, height, width, r, g, b, alpha)
	local bar = CreateFrame("StatusBar", name, parent)
	
	if height then
		bar:SetHeight(height)
	end
	
	if width then
		bar:SetWidth(width)
	end
	
	bar:SetStatusBarTexture(G.media.blank, layer)
	
	-- fix bar texture
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:GetStatusBarTexture():SetVertTile(false)
	
	if r then
		bar:SetStatusBarColor(r, g, b, alpha)
	end
	
	return bar
end