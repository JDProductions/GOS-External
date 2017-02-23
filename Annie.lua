require("DamageLib")

if myHero.charName ~= "Annie" then
  return
end

local path = SCRIPT_PATH.."eXternal Orbwalker.lua"

if FileExist(path) then
  _G.Enable_Ext_Lib = true
  loadfile(path)()
else
  print("eXternal Orbwalker Not Found. You need to install eXternal Orbwalker before using this script")
  return
end 

PrintChat("[DOOBIES ANNIE] Welcome. and please report bugs on the forums.")

 Q = {Delay = 0, Radius = 0, Range = 625, Speed = math.huge}
 W = {Delay = 0, Radius = 0, Range = 625, Speed = math.huge}
 R = {Delay = 0, Radius = 10, Range = 600, Speed = math.huge}

local PASSIVE_AMMO_MAX = myHero.hudMaxAmmo
local currentAmmo = myHero.hudAmmo
IsPassiveReady = false

local Ts = TargetSelector
local _prediction = Prediction


local AnnieMenu = MenuElement({type = MENU, id = "AnnieMenu", name = "Doobies Annie", leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/champion/Annie.png"})

AnnieMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
AnnieMenu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
AnnieMenu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})
AnnieMenu.Combo:MenuElement({id = "UseR", name = "Use R", value = true})


-- Last Hit orbwalker menu
AnnieMenu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit Settings"})
AnnieMenu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true})



function IsValidTarget(unit, range, checkTeam, from)
    local range = range == nil and math.huge or range
    if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or IsImmune(unit) or (checkTeam and unit.isAlly) then 
        return false 
    end 
    return unit.pos:DistanceTo(from) < range 
end

function IsImmune(unit)
    for K, Buff in pairs(GetBuffs(unit)) do
        if (Buff.name == "kindredrnodeathbuff" or Buff.name == "undyingrage") and GetPercentHP(unit) <= 10 then
            return true
        end
        if Buff.name == "vladimirsanguinepool" or Buff.name == "judicatorintervention" or Buff.name == "zhonyasringshield" then 
            return true
        end
    end
    return false
end

function GetBuffs(unit)
    T = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(T, Buff)
        end
    end
    return T
end

function CheckForPassiveBuff()
        if currentAmmo < PASSIVE_AMMO_MAX then
            IsPassiveReady = false
        elseif currentAmmo == PASSIVE_AMMO_MAX then
            PrintChat("Annie Passive Is Ready")
        end

        -- if passive is true then set the value of last hit q farm to false
end


function IsReady(slot)
  if  myHero:GetSpellData(slot).currentCd == 0 and myHero.mana > myHero:GetSpellData(slot).mana and myHero:GetSpellData(slot).level > 0 then
    return true
  end
  return false
end

function GetEnemyMinions()
	EnemyMinions = {}
	for i = 1, Game.MinionCount() do
		local Minion = Game.Minion(i)
		if Minion.isEnemy then
			table.insert(EnemyMinions, Minion)
		end
	end
	return EnemyMinions
end

function Combo()
local target = EOW:GetTarget()
  if EOW:Mode() == "Combo" then
  if target and Game.CanUseSpell(_Q)and IsReady(_Q) and AnnieMenu.Combo.UseQ:Value() then
    Control.CastSpell(HK_Q,target)
    end
    
    if target and Game.CanUseSpell(_W) and IsReady(_W) and AnnieMenu.Combo.UseW:Value()then
			local Prediction = target:GetPrediction(Q.Speed, Q.Delay)
			Control.CastSpell(HK_W, Prediction)
     end
     
    if target and Game.CanUseSpell(_R) and IsReady(_R) and AnnieMenu.Combo.UseR:Value()then
			local Prediction = target:GetPrediction(R.Speed, R.Delay)
			Control.CastSpell(HK_R, Prediction)
     end
 end
 end -- end function Combo
Callback.Add("Tick", Combo);

 
function LastHit()
  --CheckForPassiveBuff()
  Minions = {GetEnemyMinions()}
  if EOW.Mode() == "LastHit" then
  for i, minion in pairs (Minions[1]) do--should check passive buff before lasthit
    if minion and AnnieMenu.LastHit.UseQ:Value()  and  IsReady(_Q) and IsValidTarget(minion, 625, false, myHero.pos, minion) and getdmg("Q",minion,myHero) > minion.health  then
      Control.CastSpell(HK_Q, minion)--Q is targeted spell, no need prediction here
    end
  end
end
end
Callback.Add("Tick", LastHit);