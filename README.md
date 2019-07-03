# EKPlates

* 數字模式與條形模式
* 自定義光環顯示白名單
* 自定義能量監控白名單
* 自定義名字染色白名單
* 目標、指向、焦點高亮
* **無遊戲內設定介面**
* **只顯示血量百分比**
* **無法在地城內顯示友方名條**
* **所有的改動都要編輯Config.lua，推薦使用Notepad++**
* 數字模式
    * 可選條形或圖示施法條
    * 圖示施法條：可打斷灰色邊框，不可打斷紫色邊框
    * 滿血時只顯示名字
    * 名字左方團隊標記，右方能量監控，下方施法條，上方光環
* 條型模式：普通的名條

## 簡單寫一下FAQ：

1.設定指令是什麼？

這個插件沒有遊戲內設定指令，沒有遊戲內選項，沒有遊戲內的圖形化介面(GUI)控制台，將來也不會有。所有的改動都要編輯Config.lua，如果要求高度自定義，那就自己改ekplates.lua吧。如果不願意，那這個插件不適合你，去用knp或tptp吧。

2.怎麼顯示血量啊

因為一堆人要豐富的設定卻又跑來ekplates，所以我把話放這裡了：**ekp是以簡潔美觀為主旨的名條插件，顯示等級的PR都是別人加的，而且主打數字模式；條型模式也不打算顯示血量百分比以外的數值。要不自己魔改，要不摸摸鼻子認命改變自己的思維和習慣，什麼東西都附上一堆資訊是很沒有意義的事情。**

喔對了，用了魔改版如果出了什麼問題別來找我～關老子屁事。

## 關於EKPlates

Dawn是個神人，也曾經很高產，但軍團入侵時我真的以為他不更新了，於是有了這個。現在Infinity Plates仍在，而且代碼一如既往地精簡強大。

**數字模式用了超過五年，以後大概也會一直用下去；本插件不提供售後，條形模式的bug修復也永遠不是最優先。**

## license

The contents of this addon, excluding third-party resources, are copyrighted to its authors with all rights reserved. The author of this addon hereby grants you the following rights:
1. You may make modifications to this addon **for private use only**, except if you have been granted explicit permission by the author;
2. Do not modify the name of this addon, includig the addon folders;
3. You can upload, share or redistribute copies of this addon with offical link (curse/wowi/github).
4. from 1, if You got premission from author, when you public your edit version, you must give appropriate **credit**, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

All rights not explicitly addressed in this license are reserved by the copyright holder.

此插件中除第三方資源外的內容均受版權保護。
1. 你可以隨意修改插件，但僅供私人使用，**除非你獲得了插件作者明確的許可方可公開**；
2. 不要修改此插件的名稱，包括資料夾；
3. 你可以在**附上官方頁面**（curse/wowi/github）的前提下轉載本插件的原始版本。
4. 承第一條，若取得公開許可，你必須給予適當表彰、提供指向本授權條款的連結、並**指出（本作品的原始版本）是否已被變更**。你可以任何合理方式為前述表彰，但不得以任何方式暗示授權人為你或你的使用方式背書。

本聲明中未明確規定的所有權利均由版權所有者保留。

## 更新紀錄

* R3.2c
    * 修正template命名錯誤
	* 修正條形模式的名字
* R3.2b
    * 更正條形施法條引用錯誤的字型和變胖的箭頭
	* 使xml可引用光環字型
	* 替所有的框架命名為專屬名稱以避免遇料之外的衝突
	* 修正法術白名單邏輯
* B3.2a
    * 移除測試用id
    * 恢復config預設值
* B3.2
    * 使字型正確調用
    * 修正布局
* B3.1
    * 用xml重做了框架以解決8.2被暴雪爆破的問題
    * 移除目標的glow高亮，現在只有橫直箭頭可以選
* R3
    * 重做監視名單
        * 目標染色：改用NPC ID
        * 能量監視：改用NPC ID
        * 法術過濾：使用暴雪自身的白名單，輔以自訂義的黑白名單
    * 重新命名config選項，**不要覆蓋舊的config.lua**
    * 個人資源不再顯示光環，請改用tmw或wa
    * 清理冗餘代碼
    * 數字模式的圖示施法條大約縮小了15%
    * 所有的名條現在都是統一寬度
    * 添加施法條顏色自訂選項
    * 目標指向箭頭現在共用一個材質
    
<details>
    <summary>過去更新紀錄</summary>

* R2.1b
    * 將版權聲明由All Rights Reserved改為自訂授權
    * to do: 個人資源似乎有錯誤地顯示他人的debuff的現象
    * 修正8.1的錯誤
    * to do: 改以npc id過濾染色
* R2.1a
    * 修正條形模式的玩家名條錯誤顯示不該顯示的名字的問題
    * 調整條形模式的高亮層級至陰影之後
    * 調整條形模式的名字與光環布局
* R2.1
    * 更正不規範的寫法
    * 滿等後，隱藏同等級(120)的等級數字
    * 修正條形模式的高亮錯誤
* R2.0
    * 刪除legion白名單
    * 重做高亮功能，現在可以高亮目標、焦點和滑鼠游標指向的目標
    * 名條的預設大小現在和暴雪預設的數值一樣了
    * 名條的貼邊距離微調
    * 將美化陰影正確套用在數字模式的條形施法條上
    * to do: 激勵改為層數疊加
    * 火爆詞綴的小球染色改為亮青色
* R1.9a
    * fix toc. emmm....
* R1.9
    * bump toc
    * 刪除legion相容性
    * 將新的感染詞綴加入法術白名單
    * 將的感染詞綴小怪加入怪物染色白名單：黃色
    * 將神廟一王加入能量白名單
* B1.8
    * for bfa test: 相容live735和beta801
* R1.7a  
    * 將泰夏拉克燼火加入能量白名單  
* R1.7  
    * bump toc  
    * T21 Spell  
* R1.6  
    * 更新cvar和inset選項  
    * 數字模式的個人資源現在總是在非隱藏狀態時顯示血量，不論是否滿血  
    * 整理排版  
    * 修正條形模式光環圖示的錨點  
    * 補充幾個控場法術  
* R1.5  
    * 增加四個CVAR  
    * 數字模式的法力值改成百分比而非數值  
* R1.4  
    * 針對7.2.5 PTR的更新。暴雪超無聊，更名爆破副資源  
* R1.3a  
    * 快速修復：條形樣式的名字錯位。是的，我又不小心搞爆它了  
* R1.3  
    * 試著修復載具問題  
    * 幹掉boss mod，保留友方只顯示名字的功能，但只在副本外生效  
    * 因為某些連遊戲介面選項都不看的（逼）太煩了，強制開啟敵方守護者和僕從名條  
    * 加入m+易爆小球特殊染色：黃色
    * 修復數字模式的個人資源會以百分比顯示的問題  
    * 現在可以單獨設定名條的最大顯示距離，預設45  
    * 數字模式現在有施法「條」的選項了  
    * 整理config註解  
* R1.2  
    * 加入點擊穿透選項  
    * 幹掉友方非玩家名條，但是除了NPC以外，這些CVAR本來應該由用戶自己去開關，所以敵方的你們自己處理吧  
    * 光環可以調整字體了  
    * 試著幹掉dbm nameplate  
    * 待修復: 載具bug  
* R1.1  
    * 修復增加隱藏姓名選項時捅的漏子會導致記憶體爆炸的問題  
    * 強制套用修復掉幀的CVAR  
    * 整理Config註解  
* R1  
    * 噱頭：第一個release  

</details>
