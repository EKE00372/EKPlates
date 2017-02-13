﻿local addon, ns = ...
ns[1] = {} -- T, functions, constants, variables
ns[2] = {} -- C, config
ns[3] = {} -- L, localization
ns[4] = {} -- G, globals (Optionnal)

local T, C, L, G = unpack(select(2, ...))

--[[ Global ]]--

G.iconcastbar = "Interface\\AddOns\\EKplates\\media\\dM3"
G.raidicon = "Interface\\AddOns\\EKplates\\media\\raidicons"
G.redarrow1 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrow"
G.redarrow2 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrowH"
G.numberstylefont = "Interface\\AddOns\\EKplates\\media\\Infinity Gears.ttf"  --數字樣式的數字字體/number style's number font
G.numFont = "Interface\\AddOns\\EKplates\\media\\number.ttf" --數字字體/number font
G.norFont = STANDARD_TEXT_FONT  --名字字體/name font(or use"GameFontHighlight:GetFont()")
G.ufbar = "Interface\\AddOns\\EKplates\\media\\ufbar"

G.fontsize = 14  --名字字體大小/name font size (normal font*1.75 = number font)
G.fontflag = "OUTLINE"  -- "OUTLINE" or none

G.blank = "Interface\\Buttons\\WHITE8x8"
G.glow = "Interface\\AddOns\\EKplates\\media\\glow"

G.myClass = select(2, UnitClass("player"))  --dont touch this!/別碰這個！

--[[ Config ]]--

C.numberstyle = true --數字樣式/infinity plates's number style

C.CVAR = true  -- do a cvar setting to turn nameplate work like WOD, can also slove fps drop.

--[[blizzard default setting will scale nameplate to 0.8 when it's 10 yards outside,
	but scale nameplate by range will get fps drop if both range scale and outline working, 
	so if you get fps drop, should enable CVAR or disable font flag (font flag can be change at line 21),
	I suggest to use this config, outline is goodlook for nameplates.
	暴雪預設姓名板在10碼外會自動縮放，但這個功能和姓名板字體描邊同時存在時會引起掉幀(fps drop)
	描邊提供了姓名板美觀與易讀性，所以如果碰到了這個問題，建議啟用cvar設定來解決]]--

C.friendlyCR = true --友方職業顏色/friendly class color
C.enemyCR = true --敵方職業顏色/enemy class color
C.threatcolor = true --名字仇恨染色/change name color by threat
C.cbshield = false  --施法條不可打斷圖示/show castbar un-interrupt shield icon
C.level = false --顯示等級/show level
C.HorizontalArrow = false --橫向箭頭/horizontal red arrow at right
C.HideArrow = false  --隱藏箭頭/hide arrow
C.MinAlpha = 0.8 --非當前目標與遠距離姓名板的透明度/set fadeout for out range and non-target

--number style additional config
C.cbtext = false --施法條法術名稱/show castbar text

--[[ the Player Plate ]]--

--C.playerplate = false
C.classresource_show = false
C.classresource = "player" -- "player", "target"  
C.plateaura = false

--[[ Aura Icons on Plates ]]--

C.auranum = 5 --圖示數量
C.auraiconsize = 22 --圖示大小
C.myfiltertype = "blacklist" --自身施放/show aura cast by player
C.otherfiltertype = "whitelist"  --他人施放/show aura cast by other

-- "whitelist": show only list/白名單：只顯示列表中
-- "blacklist": show only unlist/黑名單：只顯示列表外
-- "none": do not show anything/不顯示任何光環

C.WhiteList = {
	--[166646] = true, -- 御風而行(測試用)
	--BUFF
	--[209859] = true, -- 激勵(mythic+)
	--[226510] = true, -- 膿血(mythic+)
	
	-- DEBUFF
	
	-- CC
	[25046]  = true, -- 奧流之術
	
	[118]    = true, -- 變形術
	[51514]  = true, -- 妖術
	[217832] = true, -- 禁錮
	[605]    = true, -- 心控
	[710]    = true, -- 放逐
	[2094]   = true, -- 致盲
	[6770]   = true, -- 悶棍
	[9484]   = true, -- 束縛不死生物
	[20066]  = true, -- 懺悔
	[115078] = true, -- 點穴
	
	[339]    = true, -- 小d綁
	[102359] = true, -- 群纏
	[3355]   = true, -- 冰凍陷阱
	[64695]  = true, -- 地縛圖騰
	
	[5211]   = true, -- 蠻力猛擊
	[853]    = true, -- 制裁(聖騎)
	[221562] = true, -- 窒息(dk)
	
	[118905] = true, -- 電容(薩滿)
	[132168] = true, -- 震懾波(戰士)
	[179057] = true, -- 混沌新星(dh)
	[30283]  = true, -- 暗影之怒(術士)
 	[207171] = true, -- 凜冬將至(dk)
	[117405] = true, -- 束縛射擊(獵人)
	[119381] = true, -- 掃葉腿(武僧)
	[127797] = true, -- 厄索克之旋(小德)
	[205369] = true, -- 精神炸彈 
	[81261]  = true, -- 日光(小德)
}

C.BlackList = {
	--[11426]  = true, -- 寒冰護體(測試用魔法)
	--[196741] = true, -- 連珠狂拳(測試用)	
	[166646] = true, -- 御風而行
	[15407]  = true, -- 精神鞭笞
}

--[[ Custom colored plates ]]--

C.Customcoloredplates = {
	[1] = {
		name = "暴躁蠍子", --水晶蠍的大怪
		color = {r = 1, g = 1, b = 1},
	},
	[2] = {
		name = "寒冰裂片", --法刃的冰塊
		color = {r = 1, g = 0, b = 1},
	},
}

--[[ Show Power ]]

C.show_power = true
C.ShowPower = {
	["清扫器"] = true,
	["清掃者"] = true,
}

--[[ Show Important Aura Icon on Friendly Nameplates ]]--

C.boss_mod = true
C.boss_mod_iconscale = 2
C.boss_mod_hidename = false --隱藏玩家名稱/hide player name

--[[If you enable this function, remember shift+v to enable friendly-nameplates.
	friendly-nameplates will show only spell icon and raid mark, all other elements will be hided.
	啟用首領模塊要在遊戲內shift+v開啟友方姓名板，開啟此選項會將友方姓名板除法術和團隊標記外的其他元素隱藏]]--

C.ImportantAuras = {
	--[225506] = 61295, -- 測試用
	--[166646] = "none", -- 測試用
	--[57723]  = "none", -- 測試用
	--[227723]  = "compare", -- 測試用
	
	--[[ TrialofValor ]]--
	--顯示中了沫液的人
	-- Show Volatile Foam
	[228818] = "none", -- 暗影易變沫液
	[228810] = "none", -- 鹽蝕易變沫液
	[228744] = "none", -- 火焰易變沫液	
	--當中了沫液，顯示和沫液同色吐息debuff的人
	-- show match breath color debuff when you gain Volatile Foam
	[228769] = 228818, -- 暗黑吐息
	[228768] = 228810, -- 鹽蝕唾沫
	[228758] = 228744, -- 熾炎痰液
	
	--[[ Nighthold ]]--
	--時光異象
	[206617] = "none", --定時炸彈
	--法刃
	[212647] = 212587, --冰霜咬噬
	--植物學家
	[218342] = "none", --寄生專注
	--提克迪奧斯
	[206480] = "none", --腐屍瘟疫
	--星占師
	--[206589] = "none", --冰凍
	--[205445] = "none", --貪狼
	--[205429] = "none", --巨蟹
	--[216345] = "none", --獵戶
	--[216344] = "none", --飛龍	
	[205445] = "compare", --貪狼
	[205429] = "compare", --巨蟹
	[216345] = "compare", --獵戶
	[216344] = "compare", --飛龍
	--古爾丹
	[221606] = "none", --薩格拉斯之焰
	[221603] = "none", --薩格拉斯之焰	
}
