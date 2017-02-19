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
local LastDmg = 0;
local Ts = TargetSelector
local _prediction = Prediction


local AnnieMenu = MenuElement({type = MENU, id = "AnnieMenu", name = "Doobies Annie", leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.1.1/img/champion/Annie.png"})

AnnieMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
AnnieMenu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true})
AnnieMenu.Combo:MenuElement({id = "UseW", name = "Use W", value = true})

-- Last Hit orbwalker menu
AnnieMenu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit Settings"})
AnnieMenu.LastHit:MenuElement({id = "UseQ", name = "Use Q", value = true})



function CountEnemy(pos,range)
  local N = 0
  for i = 1,Game.HeroCount()  do
    local hero = Game.Hero(i) 
    if isValidTarget(hero,range) and hero.team ~= myHero.team then
      N = N + 1
    end
  end
  return N  
end

function OnTick()
  if  isReady(_R) and os.clock() - LastDmg > 0.5 then -- crappy pc
      LastDmg = os.clock()
      for i = 1, Game.HeroCount()do
        local hero = Game.Hero(i)
        if hero.isEnemy and ValidTarget(hero) then
          RDamages[hero.networkID] = GetDamage(_R, hero, myHero)
          end
       end
    end
end

OnActiveMode(function (OW, Minions)
  if OW.Mode == "Combo" then
    Combo(OW)
	
		elseif OW.Mode == "LastHit" then	
		LastHit(OW,Minions)
    end
 end
 )
 
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
     
    if rTargets and Game.CanUseSpell(_R) == IsReady(_Q) and AnnieMenu.Combo.UseR:Value() then
    local CastPosition, Hitchance = _prediction:GetPrediction(rTargets, R)
      if Hitchance == "High" then
        Control.CastSpell(HK_R, CastPosition)
        end
     end
 end -- end function Combo
 
function LastHit(OW,Minions)
    local qTarget = Ts:GetTarget(Q.Range)
    for i, minion in pairs (Minions[1]) do
        if IsReady(_Q) and ValidTarget(minion, Q.Range) then
            if getdmg("Q", minion, myHero) > minion.health then
                DisableOrb(OW)
				Control.CastSpell(HK_Q)
				EnableOrb(OW)
            end
        end
    end
end
 
 function GetDamage(slot,unit)
  if slot == _Q then
    local dmg = ({80, 115, 150, 185})[myHero:GetSpellData(_Q).level] + 0.3 * myHero.ap
    return CalcMagicalDamage(myHero,unit,dmg)
  end
  if slot == _R then
    local dmg = ({250, 400, 550})[myHero:GetSpellData(_R).level] + 0.6 * myHero.ap 
    return CalcMagicalDamage(myHero,unit,dmg)
  end
end