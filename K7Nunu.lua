local K7Version = "1.0"

function AutoUpdate(data)
    if tonumber(data) > tonumber(K7Version) then
        PrintChat("<font color=\"#ffffff\">K7Nunu:</font> <font color=\"#adff2f\">New Version found</font> " .. data)
        PrintChat("<font color=\"#ffffff\">K7Nunu:</font> <font color=\"#adff2f\">Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/Kyushmi/GoS/master/K7Nunu.lua", SCRIPT_PATH .. "K7Nunu.lua", function() PrintChat("<font color=\"#ffffff\">K7Nunu:</font> <font color=\"#adff2f\">Downloaded Update. Please 2x F6!</font>") return end)
    else
		PrintChat("<font color=\"#ffffff\">K7Nunu:</font> <font color=\"#adff2f\">No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Kyushmi/GoS/master/Version/K7Nunu.version", AutoUpdate)

local localplayer = GetMyHero()

if GetObjectName(localplayer) ~= "Nunu" then return end

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end 

Skins = 
{
	["Nunu"] = {"Classic", "Sasquatch", "Workshop", "Grungy", "Nunu Bot", "Demolisher", "TPA", "Zombie"},
}

local entitytarget = GetCurrentTarget()
require("DamageLib")
local K7M = Menu("K7Nunu", "K7Nunu")

K7M:Menu("Combo", "Combo")
K7M.Combo:Boolean("useW", "Use W", true)
K7M.Combo:Boolean("useE", "Use E", true)
K7M.Combo:Boolean("useR", "Use R", false)
K7M.Combo:Slider("manaW", "Min Mana To Use W", 30, 0, 100)
K7M.Combo:Slider("manaR", "Min Mana To Use R", 45, 0, 100)
K7M.Combo:Slider("minenemiesR", "Min Enemies for R", 3, 1, 5)

K7M:Menu("Harass", "Harass")
K7M.Harass:Boolean("useE", "Use E", true)
K7M.Harass:Slider("manaE", "Min Mana To Use E", 30, 0, 100)

K7M:SubMenu('LastHit', 'Last Hit')
K7M.LastHit:Boolean('useQ', 'Use Q', true)
K7M.LastHit:Boolean('useE', 'Use E', true)
K7M.LastHit:Slider("manaQ", "Min Mana To Use Q", 50, 0, 100)
K7M.LastHit:Slider("manaE", "Min Mana To Use E", 70, 0, 100)

K7M:SubMenu('LaneClear', 'Lane Clear')
K7M.LaneClear:Boolean('useQ', 'Use Q', true)
K7M.LaneClear:Boolean('useE', 'Use E', true)
K7M.LaneClear:Slider("manaQ", "Min Mana To Use Q", 50, 0, 100)
K7M.LaneClear:Slider("manaE", "Min Mana To Use E", 80, 0, 100)

K7M:SubMenu('JungleClear', 'Jungle Clear')
K7M.JungleClear:Boolean('useQ', 'Use Q', true)
K7M.JungleClear:Boolean('useQ', 'Use W', false)
K7M.JungleClear:Boolean('useE', 'Use E', true)
K7M.JungleClear:Slider("manaQ", "Min Mana To Use Q", 20, 0, 100)
K7M.JungleClear:Slider("manaW", "Min Mana To Use W", 40, 0, 100)
K7M.JungleClear:Slider("manaE", "Min Mana To Use E", 50, 0, 100)

K7M:SubMenu('KS', 'Kill Steal')
K7M.KS:Boolean('useE', 'Use E', true)

K7M:SubMenu('LvL', 'Auto Level')
K7M.LvL:Boolean('AutoLvL', 'Enable Auto LvL')
K7M.LvL:Boolean('Jungle', 'Jungle')
K7M.LvL:Boolean('AP', 'AP', true)

K7M:SubMenu('SkinChanger', 'Skin Changer')
K7M.SkinChanger:DropDown('skin', localplayer.charName.. " Skins", 1, Skins[localplayer.charName], function(model) HeroSkinChanger(localplayer, model - 1) end, true)

K7M:SubMenu('Draws', 'Drawnings')
K7M.Draws:Boolean("drawQ", "Draw Q range", true)
K7M.Draws:Boolean("drawW", "Draw W range", true)
K7M.Draws:Boolean("drawE", "Draw E range", true)
K7M.Draws:Boolean("drawR", "Draw R range", true)
K7M.Draws:Boolean("drawReady", "Only draw when skills are ready")

K7M:SubMenu('Gapcloser', 'Gapcloser')
K7M.Gapcloser:Info("useE", "Use E on:")

summonerName1 = localplayer:GetSpellData(SUMMONER_1).name 
summonerName2 = localplayer:GetSpellData(SUMMONER_2).name

OneTick(function() Smite = (summonerName1:lower():find("smite") and SUMMONER_1 or (summonerName2:lower():find("smite") and SUMMONER_2 or nil)); end, 12000)

OnDraw(function()
	
	if K7M.Draws.drawReady:Value() then

		if Ready(_Q) and K7M.Draws.drawQ:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_Q),1,25,GoS.Blue)
		end

		if Ready(_W) and K7M.Draws.drawW:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_W),1,25,GoS.Pink)
		end

		if Ready(_E) and K7M.Draws.drawE:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_E),1,25,GoS.Green)

		if Ready(_R) and K7M.Draws.drawR:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_R),1,25,GoS.Yellow)
		end

	else

		if K7M.Draws.drawQ:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_Q),1,25,GoS.Blue)
		end

		if K7M.Draws.drawW:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_W),1,25,GoS.Pink)
		end

		if K7M.Draws.drawE:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_E),1,25,GoS.Green)

		if K7M.Draws.drawR:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_R),1,25,GoS.Yellow)
		end
	end
end)

function KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if K7M.KS.useE:Value() and Ready(_E) and ValidTarget(enemy, 550) and GetCurrentHP(enemy) < getdmg("E", enemy) then
			CastTargetSpell(enemy, _E)
		end
	end
end

function AutoLvl()
	LvLAP = {_E,_Q,_E,_W,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}
	LvLJungle = {_Q,_W,_E,_Q,_E,_R,_E,_E,_E,_W,_R,_W,_W,_W,_Q,_R,_Q,_Q}

	if K7M.LvL.AutoLvL:Value() and GetLevelPoints(localplayer) > 0 then

		if not Smite then
			LevelSpell(LvLAP[GetLevel(localplayer)-GetLevelPoints(localplayer)+1])
		end

		if Smite then
			LevelSpell(LvLJungle[GetLevel(localplayer)-GetLevelPoints(localplayer)+1])
		end
	end
end

function LaneClear()
	if Mix:Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_JUNGLE and K7M.JungleClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 125) and K7M.JungleClear.manaQ:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _Q)
			end

			if GetTeam(minion) == MINION_JUNGLE and K7M.JungleClear.useW:Value() and Ready(_W) and ValidTarget(minion, 140) and K7M.JungleClear.manaW:Value() < GetPercentMP(localplayer) then
				CastSpell(_W)
			end

			if GetTeam(minion) == MINION_JUNGLE and K7M.JungleClear.useE:Value() and Ready(_E) and ValidTarget(minion, 550) and K7M.JungleClear.manaE:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _E)
			end

			if GetTeam(minion) == MINION_ENEMY and K7M.LaneClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 125) and K7M.LaneClear.manaQ:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _Q)
			end


			if GetTeam(minion) == MINION_ENEMY and K7M.LaneClear.useE:Value() and Ready(_E) and ValidTarget(minion, 550) and K7M.LaneClear.manaE:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _E)
			end
		end
	end
end


function LastHit()
	if Mix:Mode() == "LastHit" then
	  for _, minion in pairs(minionManager.objects) do
	  	if Ready(_Q) and K7M.LastHit.useQ:Value() and IsObjectAlive(minion) and GetTeam(minion) ~= MINION_ALLY and GetDistance(minion) <= 125 and K7M.LastHit.manaQ:Value() <= GetPercentMP(localplayer) and GetCurrentHP(minion) < getdmg("Q", minion) then
	  		CastTargetSpell(minion, _Q)
	  	end
	  	if Ready(_E) and K7M.LastHit.useE:Value() and IsObjectAlive(minion) and GetTeam(minion) ~= MINION_ALLY and GetDistance(minion) <= 550 and K7M.LastHit.manaQ:Value() <= GetPercentMP(localplayer) and GetCurrentHP(minion) < getdmg("E", minion) then
	  		CastTargetSpell(minion, _E)
	  	end
	  end
	end
end

function Harass()
	if Mix:Mode() == "Harass" then
		if K7M.Harass.useE:Value() and Ready(_E) and ValidTarget(entitytarget, 550) and K7M.Harass.manaE:Value() < GetPercentMP(localplayer) then
			CastTargetSpell(entitytarget, _E)
		end
	end
end

function Combo()
	if Mix:Mode() == "Combo" then
		if K7M.Combo.useE:Value() and Ready(_E) and ValidTarget(entitytarget, 550) then
			CastTargetSpell(entitytarget, _E)
		end

		for _,ally in pairs(GetAllyHeroes()) do
			if K7M.Combo.useW:Value() and Ready(_W) and GetDistance(localplayer,ally) <= 700 and EnemiesAround(GetOrigin(localplayer), 750) >= 1 and K7M.Combo.manaW:Value() <= GetPercentMP(localplayer) then
				CastTargetSpell(ally, _W)
			end
		end

		if K7M.Combo.useR:Value() and Ready(_R) and ValidTarget(entitytarget, 630) and EnemiesAround(GetOrigin(localplayer), 630) >= K7M.Combo.minenemiesR:Value() and K7M.Combo.manaR:Value() <= GetPercentMP(localplayer) then
			CastSpell(_R)
		end
	end
end



	OnTick(function(localplayer)
		
		Combo()

		KillSteal()

		Harass()

		LastHit()

		LaneClear()

		AutoLvl()
end)


AddGapcloseEvent(_E, 680, true, K7M.Gapcloser)
PrintChat("<font color=\"#ffffff\">K7Nunu:</font> <font color=\"#adff2f\">Injected successfully!</font>")
