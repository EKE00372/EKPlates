local addon, ns = ...
ns[1] = {} -- T, functions, constants, variables
ns[2] = {} -- C, config
ns[3] = {} -- L, localization
ns[4] = {} -- G, globals (Optionnal)

local T, C, L, G = unpack(select(2, ...))

--[[ Global ]]--

C.numberstyle = true --數字樣式/infinity plates's number style

--[[ Textures ]]--

G.iconcastbar = "Interface\\AddOns\\EKplates\\media\\dM3"
G.raidicon = "Interface\\AddOns\\EKplates\\media\\raidicons"
G.redarrow1 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrow"
G.redarrow2 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrowH"
G.ufbar = "Interface\\AddOns\\EKplates\\media\\ufbar"
G.blank = "Interface\\Buttons\\WHITE8x8"
G.glow = "Interface\\AddOns\\EKplates\\media\\glow"
G.myClass = select(2, UnitClass("player"))  --dont touch this!/別碰這個！

--[[ Fonts ]]--

G.numberstylefont = "Interface\\AddOns\\EKplates\\media\\Infinity Gears.ttf"  --數字樣式的數字字體/number style's number font
G.numFont = "Interface\\AddOns\\EKplates\\media\\number.ttf" --數字字體/number font
G.norFont = STANDARD_TEXT_FONT  --名字字體/name font(or use"GameFontHighlight:GetFont()")
G.fontsize = 10  --名字字體大小/name font size
G.aurafontsize = 12  --光環字體大小/Aura font size
G.fontflag = "OUTLINE"  -- "OUTLINE" or none

--[[ Config ]]--

C.castbar = "bar" --can be bar or icon
C.CVAR = false  --舊版姓名板/do a cvar setting to turn nameplate work like WOD
C.MinAlpha = 0.8 --非當前目標與遠距離姓名板的透明度/set fadeout for out range and non-target
C.SelectedScale = 1 --縮放當前目標的姓名板大小/scale select target nameplate
C.FriendlyClickThrough = true --友方姓名板點擊穿透/friendly nameplate click through
C.EnemyClickThrough = false  --敵方姓名板點擊穿透/enemy nameplate click through

C.name_mod = true --友方玩家只顯示名字不顯示血量/show only name on friendy player nameplates
C.friendlyCR = true --友方職業顏色/friendly class color

C.enemyCR = true --敵方職業顏色/enemy class color
C.threatcolor = true --名字仇恨染色/change name color by threat

C.cbshield = false  --施法條不可打斷圖示/show castbar un-interrupt shield icon
C.level = false --顯示等級/show level

C.HorizontalArrow = false --橫向箭頭/horizontal red arrow at right
C.HideArrow = false  --隱藏箭頭/hide arrow

--number style additional config
C.cbtext = true --施法條法術名稱/show castbar text

--[[ the Player Plate ]]--

C.playerplate = false  --玩家個人資源/player self nameplate
C.classresource_show = false  --玩家資源/resource
C.classresource = "player" -- "player", "target"
C.plateaura = false  --玩家光環/aura

--[[ Aura Icons on Plates ]]--

C.auranum = 5 --圖示數量
C.auraiconsize = 22 --圖示大小
C.myfiltertype = "whitelist" --自身施放/show aura cast by player
C.otherfiltertype = "none"  --他人施放/show aura cast by other

-- "whitelist": show only list/白名單：只顯示列表中
-- "blacklist": show only unlist/黑名單：只顯示列表外
-- "none": do not show anything/不顯示任何光環

C.WhiteList = {
	--[166646] = true, -- 御風而行(test)
	--BUFF
	--[209859] = true, -- 激勵(mythic+)
	--[226510] = true, -- 膿血(mythic+)

	-- DEBUFF
	[146739] = true, -- Corruption
	[980] = true, -- Agony
	[63106] = true, -- Siphon Life
	[27243] = true, -- Seed of Corruption

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
	--[11426]  = true, -- 寒冰護體(test)
	--[196741] = true, -- 連珠狂拳(test)
	[166646] = true, -- 御風而行
	[227723] = true, -- 上古法力感應石(test)
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
	[3] = {
		name = "魔化炸彈", --M+易爆詞綴ZHTW
		color = {r = 1, g = 1, b = 0},
	},
	[4] = {
		name = "邪能炸弹", --M+易爆詞綴ZHCN
		color = {r = 1, g = 1, b = 0},
	},
}

--[[ Show Power ]]--

C.show_power = true  --替特定怪(自行編輯清單)顯示特特殊能量/show spacial power
C.ShowPower = {
	["清扫器"] = true,
	["清掃者"] = true,
	["Scrubber"] = true,
}
