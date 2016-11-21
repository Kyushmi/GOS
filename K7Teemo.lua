local K7Version = "1.0"

function AutoUpdate(data)
    if tonumber(data) > tonumber(K7Version) then
        PrintChat("<font color=\"#ffffff\">K7Teemo:</font> <font color=\"#adff2f\">New Version found</font> " .. data)
        PrintChat("<font color=\"#ffffff\">K7Teemo:</font> <font color=\"#adff2f\">Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/Kyushmi/GoS/master/K7Teemo.lua", SCRIPT_PATH .. "K7Teemo.lua", function() PrintChat("<font color=\"#ffffff\">K7Teemo:</font> <font color=\"#adff2f\">Downloaded Update. Please 2x F6!</font>") return end)
    else
		PrintChat("<font color=\"#ffffff\">K7Teemo:</font> <font color=\"#adff2f\">No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Kyushmi/GoS/master/Version/K7Teemo.version", AutoUpdate)

local localplayer = GetMyHero()

if GetObjectName(localplayer) ~= "Teemo" then return end

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end 

Skins = 
{
	["Teemo"] = {"Classic", "Happy Elf", "Recon", "Badger", "Astronaut", "Cottontail", "Super", "Panda", "Omega Squad"},
}

local entitytarget = GetCurrentTarget()
require("DamageLib")
require('Inspired')
local K7M = Menu("K7Teemo - Toxic Player", "K7Teemo")

K7M:Menu("Combo", "Combo")
K7M.Combo:Boolean("useQ", "Use Q", true)
K7M.Combo:Boolean("useW", "Use W", true)
K7M.Combo:Boolean("useR", "Use R", true)
K7M.Combo:Slider("manaR", "Min Mana To Use R", 45, 0, 100)
K7M.Combo:Slider("chargeR", "Charges of R before using R", 2, 1, 3)

K7M:Menu("Harass", "Harass")
K7M.Harass:Boolean("useQ", "Use Q", true)
K7M.Harass:Slider("manaQ", "Min Mana To Use Q", 30, 0, 100)

K7M:SubMenu('LastHit', 'Last Hit')
K7M.LastHit:Boolean('useQ', 'Use Q', true)
K7M.LastHit:Slider("manaQ", "Min Mana To Use Q", 60, 0, 100)

K7M:SubMenu('LaneClear', 'Lane Clear')
K7M.LaneClear:Boolean('useQ', 'Use Q', true)
K7M.LaneClear:Boolean('useR', 'Use R', true)
K7M.LaneClear:Slider("manaQ", "Min Mana To Use Q", 60, 0, 100)
K7M.LaneClear:Slider("manaR", "Min Mana To Use R", 60, 0, 100)
K7M.LaneClear:Slider("chargeR", "Charges of R before using R", 2, 1, 3)

K7M:SubMenu('JungleClear', 'Jungle Clear')
K7M.JungleClear:Boolean('useQ', 'Use Q', true)
K7M.JungleClear:Boolean('useR', 'Use R', true)
K7M.JungleClear:Slider("manaQ", "Min Mana To Use Q", 60, 0, 100)
K7M.JungleClear:Slider("manaR", "Min Mana To Use R", 60, 0, 100)
K7M.JungleClear:Slider("chargeR", "Charges of R before using R", 2, 1, 3)

K7M:SubMenu('KS', 'Kill Steal')
K7M.KS:Boolean('useQ', 'Use Q', true)

K7M:SubMenu('LvL', 'Auto Level')
K7M.LvL:Boolean('AutoLvL', 'Enable Auto LvL')
K7M.LvL:Boolean('MaxE', 'E Max')
K7M.LvL:Boolean('MaxQ', 'Q Max', true)

K7M:SubMenu('SkinChanger', 'Skin Changer')
K7M.SkinChanger:DropDown('skin', localplayer.charName.. " Skins", 1, Skins[localplayer.charName], function(model) HeroSkinChanger(localplayer, model - 1) end, true)

K7M:SubMenu('Draws', 'Drawnings')
K7M.Draws:Boolean("drawQ", "Draw Q range", true)
K7M.Draws:Boolean("drawR", "Draw R range", true)
K7M.Draws:Boolean("drawReady", "Only draw when skills are ready")

K7M:SubMenu('Gapcloser', 'Gapcloser')
K7M.Gapcloser:Info("useQ", "Use Q on:")

OnDraw(function()
	
	if K7M.Draws.drawReady:Value() then

		if CanUseSpell(localplayer,_Q) == READY and K7M.Draws.drawQ:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_Q),1,25,GoS.Blue)
		end

		if CanUseSpell(localplayer,_R) == READY and K7M.Draws.drawR:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_R),1,25,GoS.Yellow)
		end

	else

		if K7M.Draws.drawQ:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_Q),1,25,GoS.Blue)
		end

		if K7M.Draws.drawR:Value() then
			DrawCircle(localplayer,GetCastRange(localplayer,_R),1,25,GoS.Yellow)
		end
	end
end)

function KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do

		if K7M.KS.useQ:Value() and Ready(_Q) and ValidTarget(enemy, 680) and GetCurrentHP(enemy) < getdmg("Q", enemy) then
			CastTargetSpell(enemy, _Q)
		end
	end
end

function AutoLvl()
	LvLE = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}
	LvLQ = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}

	if K7M.LvL.AutoLvL:Value() and GetLevelPoints(localplayer) > 0 then

		if K7M.LvL.MaxE:Value() and not K7M.LvL.MaxQ:Value() then
			LevelSpell(LvLE[GetLevel(localplayer)-GetLevelPoints(localplayer)+1])
		end

		if K7M.LvL.MaxQ:Value() and not K7M.LvL.MaxE:Value() then
			LevelSpell(LvLQ[GetLevel(localplayer)-GetLevelPoints(localplayer)+1])
		end
	end
end

function LaneClear()
	if Mix:Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_JUNGLE and K7M.JungleClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 680) and K7M.JungleClear.manaQ:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _Q)
				IOW:ResetAA()
			end

			local iCount = GetSpellData(localplayer, _R).ammo

			if GetTeam(minion) == MINION_JUNGLE and K7M.JungleClear.useR:Value() and Ready(_R) and ValidTarget(minion, (250+ 150*GetCastLevel(localplayer,_R))) and K7M.JungleClear.chargeR:Value() <= iCount and K7M.JungleClear.manaR:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _R)
			end

			if GetTeam(minion) ~= MINION_ALLY and K7M.LaneClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 680) and K7M.LaneClear.manaQ:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _Q)
				IOW:ResetAA()
			end

			if GetTeam(minion) ~= MINION_ALLY and K7M.LaneClear.useR:Value() and Ready(_R) and ValidTarget(minion, (250+ 150*GetCastLevel(localplayer,_R))) and K7M.LaneClear.chargeR:Value() <= iCount and K7M.LaneClear.manaR:Value() < GetPercentMP(localplayer) then
				CastTargetSpell(minion, _R)
			end
		end
	end
end


function LastHitQ()
	if Mix:Mode() == "LastHit" then
	  	if Ready(_Q) and K7M.LastHit.useQ:Value() then 
	  		if K7M.LastHit.manaQ:Value() <= GetPercentMP(localplayer) then
	  		for _, minion in pairs(minionManager.objects) do
	  			if IsObjectAlive(minion) and GetTeam(minion) ~= MINION_ALLY and GetDistance(minion) <= 680 and GetCurrentHP(minion) < getdmg("Q", minion) then
	  				CastTargetSpell(minion, _Q)
	  			end
	  		end
	  	end
	  end
	end
end

function Harass()
	if Mix:Mode() == "Harass" then
		if K7M.Harass.useQ:Value() and Ready(_Q) and ValidTarget(entitytarget, 680) then
			CastTargetSpell(entitytarget, _Q)
			IOW:ResetAA()
		end
	end
end

function Combo()
	if Mix:Mode() == "Combo" then
		if K7M.Combo.useQ:Value() and Ready(_Q) and ValidTarget(entitytarget, 680) then
			CastTargetSpell(entitytarget, _Q)
			IOW:ResetAA()
		end

		if K7M.Combo.useW:Value() and Ready(_W) and ValidTarget(entitytarget, 710) then
			CastSpell(_W)
		end

		local iCount = GetSpellData(localplayer, _R).ammo

		if K7M.Combo.useR:Value() and Ready(_R) and ValidTarget(entitytarget, (250 + 150 * GetCastLevel(localplayer,_R))) and K7M.Combo.chargeR:Value() <= iCount and K7M.Combo.manaR:Value() <= GetPercentMP(localplayer) then
			CastTargetSpell(entitytarget, _R)
		end
	end
end



	OnTick(function(localplayer)
		
		Combo()

		KillSteal()

		Harass()

		LastHitQ()

		LaneClear()

		AutoLvl()
end)


AddGapcloseEvent(_Q, 680, true, K7M.Gapcloser)
PrintChat("<font color=\"#ffffff\">K7Teemo Toxic Player:</font> <font color=\"#adff2f\">Injected successfully!</font>")
