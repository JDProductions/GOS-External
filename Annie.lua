require("DamageLib")
if myHero.charName ~= "Annie" then
  return
end

local path = SCRIPT_PATH.."ExtLib.lua"

if FileExist(path) then
  _G.Enable_Ext_Lib = true
  loadfile(path)()
else
  print("ExtLib Not Found. You need to install ExtLib before using this script")
  return
end 

local Q = {Delay = 0, Radius = 0, Range = 625, Speed = math.huge}
local W = {Delay = 0, Radius = 0, Range = 625, Speed = math.huge}
local R = {Delay = 0, Radius = 10, Range = 600, Speed = math.huge}
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


OnActiveMode(function (OW, Minions)
  if OW.Mode == "Combo" then
    Combo(OW)
  elseif OW.Mode == "LastHit" then  
    LastHit(OW,Minions)
  end
end)
 
function IsReady(slot)
  if  myHero:GetSpellData(slot).currentCd == 0 and myHero.mana > myHero:GetSpellData(slot).mana and myHero:GetSpellData(slot).level > 0 then
    return true
  end
  return false
end
 
 
function DisableOrb(OW)
  OW.enableAttack = false
  OW.enableMove = false
end

function EnableOrb(OW)
  OW.enableAttack = true
  OW.enableMove = true
end

function Combo(OW)
  local qTarget = Ts:GetTarget(Q.Range)
  local wTargets = Ts:GetTarget(W.Range)
  local rTargets = Ts:GetTarget(R.Range)
  
  if qTarget and Game.CanUseSpell(_Q) == READY and AnnieMenu.Combo.UseQ:Value() then
    Control.CastSpell(HK_Q)
    end
    
    if wTargets and Game.CanUseSpell(_W) == READY then
      local CastPosition, Hitchance = _prediction:GetPrediction(wTargets,W)
        if Hitchance == "High" then
        Control.CastSpell(HK_W, CastPosition)
          end
     end
     
    if rTargets and Game.CanUseSpell(_R) and IsReady(_R) and AnnieMenu.Combo.UseR:Value() then
    local CastPosition, Hitchance = _prediction:GetPrediction(rTargets, R)
      if Hitchance == "High" then
        Control.CastSpell(HK_R, CastPosition)
        end
     end
 end -- end function Combo

 
function LastHit(OW, Minions)
  local qTarget = Ts:GetTarget(Q.range)
  for i, minion in pairs (Minions[1]) do
    if minion and IsReady(_Q) and IsValidTarget(minion, 625, false, myHero.pos, minion)  then
      local castPos = minion:GetPrediction(1500, 0.25)
      DisableOrb(OW)
      Control.CastSpell(HK_Q, castPos)
      EnableOrb(OW)
    end
  end
end