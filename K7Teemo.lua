local K7Version = "1.2"

function AutoUpdate(data)
    if tonumber(data) > tonumber(K7Version) then
        PrintChat("<font color=\"#ffffff\"><b>K7Teemo:</b></font> <font color=\"#adff2f\">New Version found</font> " .. data)
        PrintChat("<font color=\"#ffffff\"><b>K7Teemo:</b></font> <font color=\"#adff2f\">Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/Kyushmi/GoS/master/K7Teemo.lua", SCRIPT_PATH .. "K7Teemo.lua", function() PrintChat("<font color=\"#ffffff\"><b>K7Teemo:</b></font> <font color=\"#adff2f\">Downloaded Update. Please 2x F6!</font>") return end)
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
require('OpenPredict')
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
K7M.LaneClear:Slider("manaQ", "Min Mana To Use Q", 60, 0, 100)

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

K7M:SubMenu('Pred', 'Prediction Hitchance')
K7M.Pred:Slider("HitchanceR", "Hitchance R", 60, 0, 100)

K7M:SubMenu('Draws', 'Drawnings')
K7M.Draws:Boolean("drawQ", "Draw Q range", true)
K7M.Draws:Boolean("drawR", "Draw R range", true)
K7M.Draws:Boolean("drawReady", "Only draw when skills are ready")

K7M:SubMenu('Gapcloser', 'Gapcloser')
K7M.Gapcloser:Info("useQ", "Use Q on:")

local TeemoR = {delay = 1.25, range = 900, radius = 250, speed = 1200}


local function TGetHPBarPos(enemy)
  local barPos = GetHPBarPos(enemy) 
  local BarPosOffsetX = -50
  local BarPosOffsetY = 46
  local CorrectionY = 39
  local StartHpPos = 31 
  local StartPos = Vector(barPos.x , barPos.y, 0)
  local EndPos = Vector(barPos.x + 108 , barPos.y , 0)    
  return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

local function DrawLineHPBar(text, unit, team)
  if unit.dead or not unit.visible then return end
  local p = WorldToScreen(0, Vector(unit.x, unit.y, unit.z))
  local thedmg = 0
  local line = 2
  local linePosA  = { x = 0, y = 0 }
  local linePosB  = { x = 0, y = 0 }
  local TextPos   = { x = 0, y = 0 }

  if getdmg("Q", unit) >= unit.health then
    thedmg = unit.health - 1
    text = "KILLABLE FROM Q!"
  else
    thedmg = getdmg("Q", unit)
    text = "Damage from Q"
  end

  thedmg = math.round(thedmg)

  local StartPos, EndPos = TGetHPBarPos(unit)
  local Real_X = StartPos.x + 24
  local Offs_X = (Real_X + ((unit.health - thedmg) / unit.maxHealth) * (EndPos.x - StartPos.x - 2))
  if Offs_X < Real_X then Offs_X = Real_X end 
  local mytrans = 350 - math.round(255*((unit.health-thedmg)/unit.maxHealth))
  if mytrans >= 255 then mytrans=254 end
  local my_bluepart = math.round(400*((unit.health-thedmg)/unit.maxHealth))
  if my_bluepart >= 255 then my_bluepart=254 end

  if team then
    linePosA.x = Offs_X - 24
    linePosA.y = (StartPos.y-(30+(line*15)))    
    linePosB.x = Offs_X - 24 
    linePosB.y = (StartPos.y+10)
    TextPos.x = Offs_X - 20
    TextPos.y = (StartPos.y-(30+(line*15)))
  else
    linePosA.x = Offs_X-125
    linePosA.y = (StartPos.y-(30+(line*15)))    
    linePosB.x = Offs_X-125
    linePosB.y = (StartPos.y-15)

    TextPos.x = Offs_X-122
    TextPos.y = (StartPos.y-(30+(line*15)))
  end

  DrawLine(linePosA.x, linePosA.y, linePosB.x, linePosB.y , 2, ARGB(mytrans, 255, my_bluepart, 0))
  DrawText(tostring(thedmg).." "..tostring(text), 15, TextPos.x, TextPos.y , ARGB(mytrans, 255, my_bluepart, 0))
end


OnDraw(function()
	
	if not localplayer.dead then

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

		for i, Enemy in pairs(GetEnemyHeroes()) do
        	if not Enemy.dead and Enemy.visible then
            	if localplayer:CanUseSpell(_Q) == READY and not Enemy.dead then
            		DrawLineHPBar("", Enemy, Enemy.team)
           		end
        	end 
    	end

	end
end)

function CastR(unit)
	local predictR = GetCircularAOEPrediction(unit, TeemoR)
	if predictR.hitChance >= (K7M.Pred.HitchanceR:Value() * 0.01) then
		CastSkillShot(_R, predictR.castPos)
	end
end

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
			if GetTeam(minion) == MINION_JUNGLE then
				local iCount = GetSpellData(localplayer, _R).ammo
				if K7M.JungleClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 680) and K7M.JungleClear.manaQ:Value() < GetPercentMP(localplayer) then
					CastTargetSpell(minion, _Q)
				end
				if K7M.JungleClear.useR:Value() and Ready(_R) and ValidTarget(minion, (250+ 150*GetCastLevel(localplayer,_R))) and K7M.JungleClear.chargeR:Value() <= iCount and K7M.JungleClear.manaR:Value() < GetPercentMP(localplayer) then
					CastR(minion)
				end
			end

			if GetTeam(minion) ~= MINION_ALLY then
				if K7M.LaneClear.useQ:Value() and Ready(_Q) and ValidTarget(minion, 680) and K7M.LaneClear.manaQ:Value() < GetPercentMP(localplayer) then
					CastTargetSpell(minion, _Q)
				end
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
			CastR(entitytarget)
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
PrintChat("<font color=\"#ffffff\"><b>K7Teemo Toxic Player:</b></font> <font color=\"#adff2f\">Injected successfully!</font>")
