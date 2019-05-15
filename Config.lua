----------------------
-- Dont touch this! --
----------------------

local EKPlates, ns = ...

	ns[1] = {} -- C, config
	ns[2] = {} -- G, globals (Optionnal)

local C, G = unpack(select(2, ...))
local MediaFolder = "Interface\\AddOns\\EKPlates\\media\\"

	G.myClass = select(2, UnitClass("player"))

------------
-- Golbal --
------------

	-- 啟用/enable = true
	-- 停用/disable = false
	
	-- 啟用數字樣式，如果想要條形的血條就關閉這項
	-- Number style, if you want a bar-style nameplates, change to false.
	C.numberstyle = true

-------------
-- Texture --
-------------

	G.raidIcon = MediaFolder.."raidicons"		-- raid icon
	G.redArrow = MediaFolder.."NeonRedArrow"	-- Vertical arrow
	G.hlGlow = MediaFolder.."hlglow"			-- highlight glow
	G.ufbar = MediaFolder.."ufbar"				-- health bar
	G.blank = "Interface\\Buttons\\WHITE8x8"	-- background
	G.glow = MediaFolder.."glow"				-- shadow border

-----------
-- Media --
-----------

	-- use custom font or use STANDARD_TEXT_FONT / GameFontHighlight:GetFont() to get default game font
	
	G.percFont = MediaFolder.."Infinity Gears.ttf"			-- 數字樣式的數字字體 / Number style's number font
	G.numFont = MediaFolder.."number.ttf"					-- 數字字體 / Number font
	G.norFont = STANDARD_TEXT_FONT							-- 名字字體 / Name font
	
	G.fontSize = 12						-- 名字字體大小 / Name font size
	G.auraFontSize = 12					-- 光環字體大小 / Aura font size
	G.fontFlag = "OUTLINE"				-- 描邊 / "OUTLINE" or none

---------------------
-- General Options --
---------------------

	-- [[ cvars ]] --
	
	C.Inset = true						-- 名條貼齊畫面邊緣 / Let Nameplates don't go off screen
	C.MaxDistance = 45 					-- 名條顯示的最大距離 / Max distance for nameplate show on
	C.SelectedScale = 1					-- 縮放當前目標的名條大小 / Scale select target nameplate
	C.MinAlpha = 0.8					-- 非當前目標與遠距離名條的透明度 / Set fadeout for out of range and non-target

	C.FriendlyClickThrough = true		-- 友方名條點擊穿透 / Friendly nameplate click through
	C.EnemyClickThrough = false 		-- 敵方名條點擊穿透 / Enemy nameplate click through

	-- [[ colors / 染色 ]] --
	
	C.nameOnly = true					-- 友方玩家只顯示名字不顯示血量 / Show only name on friendy player nameplates
	C.friendlyCR = true					-- 友方職業顏色 / Friendly class color
	C.enemyCR = true					-- 敵方職業顏色 / Enemy class color
	C.threatColor = true				-- 名字仇恨染色 / Change name color by threat
	
	C.castStart = {.6, .6, .6}			-- 施法條顏色 / normal castbar color
	C.castFailed = {.5, .2, .2}			-- 施法失敗顏色 / cast failed color
	C.castShield = {.9, 0, 1}			-- 不可打斷顏色 / non-InterruptibleColor castbar color

	-- [[ highlight / 高亮 ]] --
	
	C.HighlightFocus = true				-- 高亮焦點 / Highlight focus
	C.HighlightMouseover = true			-- 高亮游標指向目標 / Highlight mouseover target
	C.HighlightTarget = true			-- 高亮目標 / Highlight target
	C.HighlightMode = "Vertical"		-- "Vertical", "Horizontal", "Glow" 三種目標高亮模式 / three highlight way for target
	
	-- "Vertical" = 直向箭頭 / vertical arrow
	-- "Horizontal" = 橫向箭頭 / horizontal arrow
	-- "Glow" = 無箭頭，光暈染色 / no arrow, glow on nameplate

	-- [[ other / 其他 ]] --

	C.cbShield = false					-- 施法條不可打斷圖示 / Show castbar un-interrupt shield icon
	C.level = false						-- 顯示等級 / Show level
	
	-- [[ number style additional config / 數字模式額外選項 ]] --
	
	C.cbText = false					-- 施法條法術名稱 / Show castbar text
	C.castBar = false					-- 條形施法條 / Show castbar as a "bar"

------------------
-- Player Plate --
------------------

	C.playerPlate = false				-- 玩家名條 /Player self nameplate
	C.classResourceShow = false			-- 玩家資源 /Player resource
	C.classResourceOn = "player"		-- "player", "target": 玩家資源顯示在何處 / where to how player resource
	C.PlayerClickThrough = false		-- 個人資源點擊穿透 / Player resource click through

-----------
-- Auras --
-----------
	
	C.auraNum = 5						-- 圖示數量 / The number of auras
	C.auraIconSize = 22					-- 圖示大小 / Aura icon size
	C.showMyAuras = true				-- 自身施放 / Show aura cast by player
	C.showOtherAuras = true				-- 他人施放 / Show aura cast by other

	C.WhiteList = {
		-- [[ 補足暴雪的白名單裡缺少的控場法術 ]] --
		
		-- Buffs
		--[281744]	= true,		-- 罰站披風 test
		[642]		= true,		-- 聖盾術
		[1022]		= true,		-- 保護祝福
		[23920]		= true,		-- 法術反射
		[45438]		= true,		-- 寒冰屏障
		[186265]	= true,		-- 灵龟守护
		
		-- Debuffs
		[2094]		= true,		-- 致盲
		[117405]	= true,		-- 束缚射击
		[127797]	= true,		-- 厄索爾之旋
		[20549] 	= true,		-- 戰爭踐踏
		[107079] 	= true,		-- 震山掌
		[272295] 	= true,		-- 悬赏
		
		-- [[ 副本 ]] --
		
		-- Dungeons
		[257899]	= true,		-- 痛苦激励，自由镇
		[268008]	= true,		-- 毒蛇诱惑，神庙
		[260792]	= true,		-- 尘土云，神庙
		[260416]	= true,		-- 蜕变，孢林
		
		[267981]	= true,		-- 防护光环，风暴神殿
		[274631]	= true,		-- 次级铁墙祝福，风暴神殿
		[267901]	= true,		-- 铁墙祝福，风暴神殿
		[276767]	= true,		-- 吞噬虚空，风暴神殿
		[268212]	= true,		-- 小型强化结界，风暴神殿
		[268186]	= true,		-- 强化结界，风暴神殿
		[263246]	= true,		-- 闪电之盾，风暴神殿
		
		[257597]	= true,		-- 艾泽里特的灌注，矿区
		[260805]	= true,		-- 聚焦之虹，庄园
		[264027]	= true,		-- 结界蜡烛，庄园
		[255960]	= true,		-- 强效巫毒，阿塔达萨
		[255967]	= true,
		[255968]	= true,
		[255970]	= true,
		[255972]	= true,
		
		-- 詞綴
		[228318]	= true,		-- 狂怒
		[226510]	= true,		-- 膿血

	}

	C.BlackList = {
		-- [[ 幹掉那些太煩人的常駐dot ]] --
		
		--[166646]	= true,		-- 御風而行/Windwalking
		[15407]		= true,		-- 精神鞭笞
		[51714]		= true,		-- 锋锐之霜
		[199721]	= true,		-- 腐烂光环
		[214968]	= true,		-- 死灵光环
		[214975]	= true,		-- 抑心光环
		[273977]	= true,		-- 亡者之握
		[206930]	= true,		-- 心脏打击
	}

------------
-- Custom --
------------

	-- [[ Custom colored plates / 特定目標染色 ]] --

	C.CustomUnit = {
		--[[
		example: 
		[index] = {id = NPC ID , color = {r, g, b}, },
		]]--
		[1] = {id = 120651,	color = {.7, .95, 1}, },	-- 炸藥 火爆詞綴
		[2] = {id = 135764,	color = {.8, 1, .1}, },		-- 爆裂圖騰 諸王之眠
		[3] = {id = 137591,	color = {.8, 1, .1},},		-- 療癒之潮圖騰 諸王之眠
		[4] = {id = 130896,	color = {.8, 1, .1},},		-- 昏厥酒桶 自由港
	}

	-- [[ Show Power / 特定目標顯示能量 ]] --

	C.ShowPower = true
	C.ShowPowerList = {
		-- Temple of Sethraliss
		[133944] = true,	-- 艾斯匹 神廟
		[133379] = true,	-- 阿德利斯 神廟	
	}