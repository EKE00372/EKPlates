----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- T, ouf custom

local C, F, G, T = unpack(ns)


	G.addon = "EKPlates_"
	G.myClass = select(2, UnitClass("player"))
	
local MediaFolder = "Interface\\AddOns\\EKPlates\\Media\\"

-------------
-- Texture --
-------------

	G.media = {
		blank = MediaFolder.."ufbar",		-- "Interface\\Buttons\\WHITE8x8",
		--blank = "Interface\\Buttons\\WHITE8x8",		-- "Interface\\Buttons\\WHITE8x8",
		glow = MediaFolder.."glow.tga",
		barhightlight = MediaFolder.."highlight.tga",
		
		--spark = MediaFolder.."spark.tga",	-- "Interface\\UnitPowerBarAlt\\Generic1Player_Pill_Flash"
		spark = "Interface\\UnitPowerBarAlt\\Generic1Player_Pill_Flash",	-- "Interface\\UnitPowerBarAlt\\Generic1Player_Pill_Flash"
		border = MediaFolder.."border.tga",
		
		raidicon = MediaFolder.."raidicons.blp",
	}

-----------
-- Fonts --
-----------

	G.Font = STANDARD_TEXT_FONT						-- general font / 字型
	G.NameFS = 14									-- general font size / 字型大小
	G.FontFlag = "OUTLINE"							-- general font flag / 描邊 "OUTLINE" or none
	
	G.NFont = MediaFolder.."number.ttf"			-- number font for auras / 光環數字字型
	G.NumberFS = 14
	
	G.NPNameFS = 12									-- nameplate font size / 名條的字型
	G.NPFont = MediaFolder.."Infinity Gears.ttf"	-- number style nameplate health text font / 數字模式名條的血量字型
	G.NPFS = 18										-- number style nameplate health text font size / 數字模式名條的血量字型大小

------------------------
-- Nameplate settings --
------------------------

	C.NumberStyle = true	-- number style nameplates / 數字模式的名條
	
	-- Number style nameplate config
	C.NPCastIcon = 32		-- number style nameplate cast icon size /  數字模式的施法圖示大小
	
	-- Bar style nameplate config
	C.NPWidth = 110			-- nameplate frame width / 名條寬度
	C.NPHeight = 8			-- nameplate frame height / 名條高度

	-- auras
	C.ShowAuras = true		-- show auras / 顯示光環
	C.Auranum = 5			-- how many aura show / 顯示光環數量
	C.AuraSize = 20			-- aura icon size / 光環大小

	-- highlight
	C.HLTarget = true		-- highlight target and focus / 高亮目標和焦點
	C.HLMouseover = true	-- highlight mouseover / 高亮滑鼠指向
	
	-- colors
	C.friendlyCR = true		-- friendly unit class color / 友方職業染色
	C.enemyCR = true		-- enemy unit class color / 敵方職業染色
	
	C.CastNormal = {.6, .6, .6}			-- 一般施法條顏色 / normal castbar color
	C.CastFailed = {.5, .2, .2}			-- 施法失敗顏色 / cast failed color
	C.CastShield = {.9, 0, 1}			-- 不可打斷施法條顏色 / non-InterruptibleColor castbar color
	
	-- [[ player plate ]] --
	
	C.PlayerPlate = true	-- enable player plate / 玩家名條(個人資源)
	C.NumberstylePP = true	-- number style player plate / 數字模式的玩家名條
	C.PlayerBuffs = true	-- show player buff on player plate / 顯示自身增益
	
	C.PPWidth = 180			-- player/target/focus frame width / 主框體(血量條)寬度(玩家/目標/焦點)
	C.PPHeight = 4			-- power bar height / 能量條高度
	C.PPOffset = 6			-- power bar offset / 能量條向下偏移

	--[[ nameplates cvar ]] --
	
	C.Inset = true			-- Let Nameplates don't go off screen / 名條貼齊畫面邊緣
	C.MaxDistance = 45		-- Max distance for nameplate show on / 名條顯示的最大距離
	C.SelectedScale = 1		-- Scale select target nameplate / 縮放當前目標的名條大小
	C.MinAlpha = 1			-- Set fadeout for out of range and non-target / 非當前目標與遠距離名條的透明度
	
-----------------------
-- Position settings --
-----------------------

	C.Position = {	-- 各元素座標 / Elements positions
		PlayerPlate	= {"CENTER", 0, -200},
	}

-------------
-- Credits --
-------------

	-- NDui by Siweia
	-- unitframes
	-- https://github.com/siweia/NDui/tree/master/Interface/AddOns/NDui/Modules/UFs
	-- spell list
	-- https://github.com/siweia/NDui/blob/master/Interface/AddOns/NDui/Config/Nameplate.lua
	
	-- AltzUI by Paopao
	-- unitframes
	-- https://github.com/Paojy/Altz-UI/tree/master/Interface/AddOns/AltzUI/mods/unitframes
	
	-- oUF Mlight
	-- https://www.wowinterface.com/downloads/info21095-oUF_Mlight.html
	
	-- oUF Farva
	-- https://github.com/scrable/oUF_Farva

	-- oUF Slim
	-- https://www.wowinterface.com/downloads/info12972-oUF_Slim.html
	
	-- oUF Skaarj
	-- https://www.wowinterface.com/downloads/info20211-oUFSkaarj.html
	
	-- Infinity Plates by Dawn
	-- https://www.wowinterface.com/downloads/info19881-InfinityPlates.html

	-- SpecialTotemBar by HopeASD
	
	-- [oUF] 1.5版 oUF系插件 通用说明 (FD) NGA玩家社区
	-- https://nga.178.com/read.php?tid=4107042

	-- [oUF][最基础扫盲][初稿完工！]以Ouf_viv5为例，不完全不专业注释
	-- https://nga.178.com/read.php?tid=4184224

	-- [未完成]oUF系列头像编写教程 NGA玩家社区
	-- https://bbs.nga.cn/read.php?tid=7212677