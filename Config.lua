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
SlashCmdList["ETTRACE"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools")
	EventTraceFrame_HandleSlashCmd(msg)
end
SLASH_ETTRACE1 = "/et" --etrace

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
	
	-- [[ highlight / 高亮 ]] --
	
	C.HighlightTarget = true			-- 高亮目標 / Highlight target
	C.HighlightMode = "Glow"			-- "Vertical", "Horizontal", "Glow" 三種目標高亮模式 / three highlight way for target
	
	-- "Vertical" = 直向箭頭 / vertical arrow
	-- "Horizontal" = 橫向箭頭 / horizontal arrow
	-- "Glow" = 無箭頭，光暈染色 / no arrow, glow on nameplate

	-- [[ other / 其他 ]] --

	C.level = true						-- 顯示等級 / Show level