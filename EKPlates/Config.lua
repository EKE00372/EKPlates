local EKPlates, ns = ...
ns[1] = {} -- C, config
ns[2] = {} -- G, globals (Optionnal)

local C, G = unpack(select(2, ...))

-- [[ Global ]] --

-- 啟用/enable = true 停用/disable = false
C.numberstyle = true		-- 啟用數字樣式，如果想要條形的血條就關閉這項 / Number style, if you want a bar-style nameplates, change to false.

-- [[ Textures ]] --

G.iconcastbar = "Interface\\AddOns\\EKplates\\media\\dM3"
G.raidicon = "Interface\\AddOns\\EKplates\\media\\raidicons"
G.redarrow1 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrow"
G.redarrow2 = "Interface\\AddOns\\EKplates\\media\\NeonRedArrowH"
G.hlglow = "Interface\\AddOns\\EKplates\\media\\hlglow"
G.ufbar = "Interface\\AddOns\\EKplates\\media\\ufbar"
G.blank = "Interface\\Buttons\\WHITE8x8"
G.glow = "Interface\\AddOns\\EKplates\\media\\glow"
G.myClass = select(2, UnitClass("player"))			-- DO NOT touch this! / 別碰這個！

-- [[ Fonts ]] --

G.numberstylefont = "Interface\\AddOns\\EKplates\\media\\Infinity Gears.ttf"	-- 數字樣式的數字字體 / Number style's number font
G.numFont = "Interface\\AddOns\\EKplates\\media\\number.ttf"					-- 數字字體 / Number font
G.norFont = STANDARD_TEXT_FONT													-- 名字字體 / Name font (or use"GameFontHighlight:GetFont()"to get default game font)
G.fontsize = 12																	-- 名字字體大小 / Name font size
G.aurafontsize = 12																-- 光環字體大小 / Aura font size
G.fontflag = "OUTLINE"															-- 描邊 / "OUTLINE" or none

-- [[ Config ]] --

C.Inset = true						-- 名條貼齊畫面邊緣 / Let Nameplates don't go off screen
C.MaxDistance = 45 					-- 名條顯示的最大距離 / Max distance for nameplate show on
C.SelectedScale = 1					-- 縮放當前目標的名條大小 / Scale select target nameplate
C.MinAlpha = 0.8					-- 非當前目標與遠距離名條的透明度 / Set fadeout for out of range and non-target

C.FriendlyClickThrough = true		-- 友方名條點擊穿透 / Friendly nameplate click through
C.EnemyClickThrough = false 		-- 敵方名條點擊穿透 / Enemy nameplate click through

C.name_mod = true					-- 友方玩家只顯示名字不顯示血量 / Show only name on friendy player nameplates
C.friendlyCR = true					-- 友方職業顏色 / Friendly class color

C.enemyCR = true					-- 敵方職業顏色 / Enemy class color
C.threatcolor = true				-- 名字仇恨染色 / Change name color by threat

C.cbshield = false					-- 施法條不可打斷圖示 / Show castbar un-interrupt shield icon
C.level = false						-- 顯示等級 / Show level

-- highlight / 高亮
C.HighlightTarget = true			-- 高亮目標 / Highlight target
C.HighlightMode = "Vertical"			-- "Vertical", "Horizontal", "Glow" 直向箭頭、橫向箭頭、光暈染色 / vertical arrow ,horizontal arrow ,or blue glow on nameplate
C.HighlightFocus = true				-- 高亮焦點 / Highlight focus
C.HighlightMouseover = true			-- 高亮游標指向目標(高cpu占用) / Highlight mouseover target (!!! high CPU usage !!!)

-- number style additional config / 數字模式額外選項
C.cbtext = false					-- 施法條法術名稱 / Show castbar text
C.castbar = false					-- 條形施法條 / Show castbar as a "bar"

-- [[ Player Plate / 玩家名條 ]] --

C.playerplate = false				-- 玩家名條 /Player self nameplate
C.classresource_show = false		-- 玩家資源 /Player resource
C.classresource = "player"			-- "player", "target": 玩家資源顯示在何處 / Show player resource on player nameplate or target nameplate
C.plateaura = false					-- 玩家光環 / Player aura
C.PlayerClickThrough = false		-- 個人資源點擊穿透 / Player resource click through

-- [[ Aura Icons on Plates / 光環 ]] --

C.auranum = 5						-- 圖示數量 / The number of auras
C.auraiconsize = 22					-- 圖示大小 / Aura icon size
C.myfiltertype = "blacklist"		-- 自身施放 / Show aura cast by player
C.otherfiltertype = "whitelist"		-- 他人施放 / Show aura cast by other

-- "whitelist": show only list / 白名單：只顯示列表中
-- "blacklist": show only unlist / 黑名單：只顯示列表外
-- "none": do not show anything / 不顯示任何光環

C.WhiteList = {
	--[166646]=	true,	-- 御風而行(test)
	
	-- BUFF
	-- Mythic+
	[209859]= true,		-- 激勵/Bolster
	[226510]= true,		-- 膿血/Sanguine Ichor
	[277242]= true,		-- 感染/Symbiote of G'huun
	-- TOS
	[236513]= true,		-- 骨牢護甲
	-- antorus
	[244383]= true,		-- 火焰護盾
	[245075]= true,		-- 飢餓鬱影
	[245631]= true,		-- 無縛烈焰
	[255425]= true,		-- 冰霜易傷
	[255430]= true,		-- 暗影易傷
	[255429]= true,		-- 火焰易傷
	[255419]= true,		-- 神聖易傷
	[255422]= true,		-- 自然易傷
	[255418]= true,		-- 物理易傷
	[255433]= true,		-- 秘法易傷
	
	-- DEBUFF
	-- 種族
	[25049]	= true,		-- 戰爭踐踏/War Stomp
	-- 法師
	[118]	= true,		-- 變形術/Polymorph
	-- 薩滿
	[51514]	= true,		-- 妖術/Hex
	[64695]	= true,		-- 地縛圖騰/Earthgrab
	[118905]= true,		-- 電容/Static Charge
	-- 獵人
	[217832]= true,		-- 禁錮/Imprison
	[3355]	= true,		-- 冰凍陷阱/Freezing Trap
	[117405]= true,		-- 束縛射擊/Binding Shot
	-- 牧師
	[605]	= true,		-- 心控/Mind Contrl
	[9484]	= true,		-- 束縛不死生物/Shackle Undead
	[205369]= true,		-- 精神炸彈/Mind Bomb
	-- 術士
	[710]	= true,		-- 放逐/Banish
	[30283]	= true,		-- 暗影之怒/Shadowfury
	-- 盜賊
	[2094]	= true,		-- 致盲/Blind
	[6770]	= true,		-- 悶棍/Sap
	-- 聖騎士
	[20066]	= true,		-- 懺悔/Repentance
	[29511]	= true,		-- 懺悔/Repentance
	[853]	= true,		-- 制裁/Hammer of Justice
	[205290]= true,		-- 灰燼甦醒/Wake of Ashes
	[115750]= true,		-- 盲目之光/Blinding Light
	[183218]= true,		-- 封阻之手/Hand of Hindrance
	-- 武僧
	[115078]= true,		-- 點穴/Paralysis
	[119381]= true,		-- 掃葉腿/Leg Sweep
	-- 德魯伊
	[339]	= true,		-- 糾纏根鬚/Entangling Roots
	[102359]= true,		-- 群體糾纏/Mass Entanglement
	[5211]	= true,		-- 蠻力猛擊/Mighty Bash
	[81261]	= true,		-- 日光/Solar Beam
	[127797]= true,		-- 厄索克之旋/Ursol's Vortex
	-- 死亡騎士
	[221562]= true,		-- 窒息/Asphyxiate
	[207171]= true,		-- 凜冬將至/Winter is Coming
	[207167]= true,		-- 致盲凍雨/Blinding Sleet
	-- 戰士
	[132168]= true,		-- 震懾波/Shockwave
	-- 惡魔獵人
	[179057]= true,		-- 混沌新星/Chaos Nova
}

C.BlackList = {
	--[11426]= true,	-- 寒冰護體(test)
	--[196741]= true,	-- 連珠狂拳(test)
	[166646]= true,		-- 御風而行/Windwalking
	[227723]= true,		-- 上古法力感應石/Mana Divining Stone
	[15407]	= true,		-- 精神鞭笞
}

-- [[ Custom colored plates ]] --

C.Customcoloredplates = {
	-- 感染
	[1] = {
		name = "古翰幼體",
		color = {r = 1, g = 1, b = 0.2},
	},
	[2] = {
		name = "Spawn of G'huun",
		color = {r = 1, g = 1, b = 0.2},
	},
	[3] = {
		name = "戈霍恩之嗣",
		color = {r = 1, g = 1, b = 0.2},
	},
	-- 火爆
	[4] = {
		name = "爆炸物",
		color = {r = 0.7, g = 0.95, b = 1},
	},
	[5] = {
		name = "炸藥",
		color = {r = 0.7, g = 0.95, b = 1},
	},
	[6] = {
		name = "Explosives",
		color = {r = 0.7, g = 0.95, b = 1},
	},
		--color = {r = 0.95, g = 1, b = 0.8},
		--color = {r = 0.9, g = 1, b = 0.8},
		--color = {r = 0.92, g = 1, b = 0.48},
		--color = {r = 0.8, g = 1, b = 0.1},
}

-- [[ Show Power ]] --

C.show_power = true		-- 替特定怪(自行編輯清單)啟用顯示能量值 / show power or energy
C.ShowPower = {
	--["訓練假人"] = true,
	
	-- Temple of Sethraliss
	["阿德利斯"] = true,
	["艾斯匹"] = true,
	["阿德里斯"] = true,
	["阿斯匹克斯"] = true,
	["Adderis"] = true,
	["Aspix"] = true,	
}
