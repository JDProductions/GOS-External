require("DamageLib")

class "JhinSmokingDoobie"

local path = SCRIPT_PATH.."eXternal Orbwalker.lua"

if FileExist(path) then
  _G.Enable_Ext_Lib = true
  loadfile(path)()
  -- Begin Script

 _MAX_AMMO = 4
 _currentAmmo = myHero.hudAmmo
 isReloading = false
 isCritShot = false

  function JhinSmokingDoobie:__init()
  	if myHero.charName ~= "Jhin" then
  		return 
	end -- END MY HERO NAME IF

	 Q = {Delay = 0, Radius = 0, Range = 550, Speed = math.huge}

	PrintChat("[JHIN SMOKING DOOBIE], Welcome please report all bugs on forum. Have Fun (:")
	--self.LoadSpells()
	--self.LoadMenu()
	Callback.Add("Tick", self.Combo);
	end
  end -- End Initialize Function

----------------------- HELPERS ---------------------
function IsReady(slot)
  if  myHero:GetSpellData(slot).currentCd == 0 and myHero.mana > myHero:GetSpellData(slot).mana and myHero:GetSpellData(slot).level > 0 then
    return true
  end
  return false
end

----------------------- END HELPERS---------------------


  function JhinSmokingDoobie:Tick()
    -- Put everything you want to update every time the game ticks here (don't put too many calculations here or you'll drop FPS)
    if EOW:Mode() == "Combo" then
        self:Combo()
    elseif EOW:Mode() == "Harass" then
        self:Harass()
    elseif EOW:Mode() == "LaneClear" then
        self:Farm()
    elseif EOW:Mode() == "LastHit" then
        self:LastHit()
    end
end -- Tick Function

function JhinSmokingDoobie:Combo()
	-- Combo logic
	  local target = EOW:GetTarget()
	  if target and IsReady(_Q)then
    Control.CastSpell(HK_Q, target)
    end
end

function JhinSmokingDoobie:Harass()
	-- body
end

function JhinSmokingDoobie:LaneClear( ... )
	-- body
end
 -- END Orbwalking

function OnLoad()
    JhinSmokingDoobie()
end