function OnLoad() TardQuinn:Tard__init() end

class "Need"

--[[function Need:CanUseSpell(spell)
--	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana
	end
]]

--Thx Tosh :)
function Need:Tard_HasBuff(unit, buffname)
	for i = 0,  unit.buffCount do
		local Tard_Buff = unit:GetBuff(i)
		if Tard_Buff and Tard_Buff.name ~= "" and Tard_Buff.count > 0 and Game.Timer() >= Tard_Buff.startTime and Game.Timer() < Tard_Buff.expireTime and Tard_Buff.name == buffname then
			return  Tard_Buff.count
		end
	end
	return 0
end		

--Thx Tosh :)
function Need:Tard_GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local Tard_dx = Pos1.x - Pos2.x
	local Tard_dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return (Tard_dx * Tard_dx) + (Tard_dz * Tard_dz)
end

--Thx Tosh :)
function Need:Tard_GetDistance(Pos1, Pos2)
	return math.sqrt(self:Tard_GetDistanceSqr(Pos1, Pos2))
end

function Need:Tard_IsValidTarget(unit,range)
	local range = range or math.huge
	return unit and unit.team ~= myHero.team and unit.valid and Need:Tard_GetDistanceSqr(unit.pos*unit.pos) <= range and unit.visible and unit.isTargetable and not unit.dead and not unit.isImmune 
end


--local QDamage=(({20, 45, 70, 95, 120})[level] + myHero.bonusDamage)
--local EDamage=(({40, 70, 100, 130, 160})[level] +(0.2*(myHero.bonusDamage))

function Need:Tard_CastQ(unit)
	if unit then
    local Tard_QPred = unit:GetPrediction(Tard_QuinnSpellQ.speed, Tard_QuinnSpellQ.delay + Game.Latency()/1000) 
    local Tard_QCollision = unit:GetCollision(Tard_QuinnSpellQ.width,Tard_QuinnSpellQ.speed,Tard_QuinnSpellQ.delay)
		  if Game.CanUseSpell(_Q) == 0 and Tard_QCollision == 0 and Need:Tard_GetDistanceSqr(myHero.pos,Tard_QPred) < Tard_QuinnSpellQ.range then
			   Control.CastSpell(HK_Q,Tard_QPred)
		  end
	end
	return false
end

function Need:Tard_CastE(unit)
	if unit then
		if Game.CanUseSpell(_E) == 0 then
		    Control.CastSpell(HK_E,unit)			
		end		
	end
	return false
end

--Thx Weedle :)
function Need:Tard_GetOrb()
		if _G.EOWLoaded then
			Tard_Orb = "EOW"
			print("Don't use Toshi Orb dude, he is toxic ^^")
		elseif _G.SDK and _G.SDK.Orbwalker then
			Tard_Orb = "SDK"
			print("IC is a good Orb")
		else 
			print("Noddy rocks")
		end
end

--Thx Weedle :)
function Need:Tard_GetMode()
		if Tard_Orb == "EOW" then
			return EOW:Mode()
		elseif Tard_Orb == "SDK" then
			local Tard_SDKMode  = _G.SDK.Orbwalker.Modes
			if Tard_SDKMode[_G.SDK.ORBWALKER_MODE_COMBO] then
				return "Combo"
			elseif Tard_SDKMode[_G.SDK.ORBWALKER_MODE_HARASS] then
				return "Harass"	
			elseif Tard_SDKMode[_G.SDK.ORBWALKER_MODE_LANECLEAR] or Tard_SDKMode[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
				return "Clear"
			elseif Tard_SDKMode[_G.SDK.ORBWALKER_MODE_LASTHIT] then
				return "LastHit"
			elseif Tard_SDKMode[_G.SDK.ORBWALKER_MODE_FLEE] then
				return "Flee"
			end
		elseif Tard_Orb == nil then
			return GOS.GetMode()
		end
end

--Thx Weedle :)
function Need:Tard_QuinnTarget(range)	
		if Tard_Orb == nil then
			Tard_target = GOS:GetTarget(range)
		elseif Tard_Orb == "SDK" then			
			Tard_target = _G.SDK.TargetSelector:GetTarget(range)			
		elseif Tard_Orb == "EOW" then
			Tard_target = EOW:GetTarget(range)
		end
		return Tard_target
end
----------------------------------------------------------------------------------------------------------------------------------------------------
--Thx Deftsu for your Dmg Lib and Noddy for his bik new release :)

local DamageReductionTable = {
  ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
  ["Urgot"] = {buff = "urgotswapdef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
  ["Alistar"] = {buff = "Ferocious Howl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
  ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
  ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
  ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
  ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
  ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
  ["Malzahar"] = {buff = "malzaharpassiveshield", amount = function(target) return 0.1 end}
}
 

function Need:GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0
end

function Need:CalcPhysicalDamage(source, target, amount)
  local ArmorPenPercent = source.armorPenPercent
  local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * source.armorPen
  local BonusArmorPen = source.bonusArmorPenPercent

  if source.type == Obj_AI_Minion then
    ArmorPenPercent = 1
    ArmorPenFlat = 0
    BonusArmorPen = 1
  elseif source.type == Obj_AI_Turret then
    ArmorPenFlat = 0
    BonusArmorPen = 1
    if source.charName:find("3") or source.charName:find("4") then
      ArmorPenPercent = 0.25
    else
      ArmorPenPercent = 0.7
    end
  end

  if source.type == Obj_AI_Turret then
    if target.type == Obj_AI_Minion then
      amount = amount * 1.25
      string.ends = function(String,End) return End == "" or string.sub(String,-string.len(End)) == End end
      if string.ends(target.charName, "MinionSiege") then
        amount = amount * 0.7
      end
      return amount
    end
  end

  local armor = target.armor
  local bonusArmor = target.bonusArmor
  local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

  if armor < 0 then
    value = 2 - 100 / (100 - armor)
  elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
    value = 1
  end
  return math.max(0, math.floor(Need:DamageReductionMod(source, target,Need:PassivePercentMod(source, target, value) * amount, 1)))
end


function Need:DamageReductionMod(source,target,amount,DamageType)
  if source.type == Obj_AI_Hero then
    if Need:Tard_HasBuff(source, "Exhaust") > 0 then
      amount = amount * 0.6
    end
  end

  if target.type == Obj_AI_Hero then

    for i = 0, target.buffCount do
      if target:GetBuff(i).count > 0 then
        local buff = target:GetBuff(i)
        if buff.name == "w" then
          amount = amount * (1 - (0.06 * buff.count))
        end
    
        if DamageReductionTable[target.charName] then
          if buff.name == DamageReductionTable[target.charName].buff and (not DamageReductionTable[target.charName].damagetype or DamageReductionTable[target.charName].damagetype == DamageType) then
            amount = amount * DamageReductionTable[target.charName].amount(target)
          end
        end

        if target.charName == "Maokai" and source.type ~= Obj_AI_Turret then
          if buff.name == "MaokaiDrainDefense" then
            amount = amount * 0.8
          end
        end

        if target.charName == "MasterYi" then
          if buff.name == "Meditate" then
            amount = amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] / (source.type == Obj_AI_Turret and 2 or 1)
          end
        end
      end
    end

    if Need:GetItemSlot(target, 1054) > 0 then
      amount = amount - 8
    end

    if target.charName == "Kassadin" and DamageType == 2 then
      amount = amount * 0.85
    end
  end

  return amount
end

function Need:PassivePercentMod(source, target, amount, damageType)
  local SiegeMinionList = {"Red_Minion_MechCannon", "Blue_Minion_MechCannon"}
  local NormalMinionList = {"Red_Minion_Wizard", "Blue_Minion_Wizard", "Red_Minion_Basic", "Blue_Minion_Basic"}

  if source.type == Obj_AI_Turret then
    if table.contains(SiegeMinionList, target.charName) then
      amount = amount * 0.7
    elseif table.contains(NormalMinionList, target.charName) then
      amount = amount * 1.14285714285714
    end
  end
  if source.type == Obj_AI_Hero then 
    if target.type == Obj_AI_Hero then
      if (Need:GetItemSlot(source, 3036) > 0 or Need:GetItemSlot(source, 3034) > 0) and source.maxHealth < target.maxHealth and damageType == 1 then
        amount = amount * (1 + math.min(target.maxHealth - source.maxHealth, 500) / 50 * (Need:GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
      end
    end
  end
  return amount
end
         
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
class "TardQuinn"

function TardQuinn:Tard__init()
	if myHero.charName ~= "Quinn" then return end
	self.Tard_version = 0.8
	print("Hello ", myHero.name, ", TardQuinn v", self.Tard_version, " is ready to feed")
	Tard_QuinnSpellQ = { range = myHero:GetSpellData(_Q).range, delay = 0.25, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/8/87/Blinding_Assault.png"}	
	Tard_QuinnSpellW = { range = myHero:GetSpellData(_W).range, delay = 0, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/e/e1/Heightened_Senses.png"}
	Tard_QuinnSpellE = { range = myHero:GetSpellData(_E).range, delay = 0.25, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width, icon = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c9/Vault.png"}
	Tard_QuinnSpellR = { range = myHero:GetSpellData(_R).range, delay = 0.25, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/a/af/Behind_Enemy_Lines.png"}
	self.Tard_QuinnQ_Dmg = function(target) local Tard_level=myHero:GetSpellData(0).level return Need:CalcPhysicalDamage(myHero, target, (({20, 45, 70, 95, 120})[Tard_level] + ({0.8, 0.9, 1.0, 1.1, 1.2})[Tard_level] * myHero.totalDamage) + 0.35 * myHero.ap) end
	self.Tard_QuinnE_Dmg = function(target) local Tard_level=myHero:GetSpellData(2).level return Need:CalcPhysicalDamage(myHero, target, ({40, 70, 100, 130, 160})[Tard_level] + 0.2 * myHero.totalDamage) end
	self.Tard_QuinnR_Dmg = function(target) local Tard_level=myHero:GetSpellData(3).level return Need:CalcPhysicalDamage(myHero, target, 0.4 * myHero.totalDamage) end
	self:Tard_Menu()
  Need:Tard_GetOrb()
  Callback.Add("Tick", function() self:Tard_Tick() end)
  Callback.Add("Draw", function() self:Tard_Draw() end)
end 

function TardQuinn:Tard_Menu()
    self.Tard_TardMenu = MenuElement({type = MENU, id = "TardQuinnMenu", name = "TardQuinn", leftIcon="https://vignette3.wikia.nocookie.net/leagueoflegends/images/a/af/Behind_Enemy_Lines.png"})

    --[[Combo]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
    

    --[[Harass]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Farm]]
    --self.Tard_TardMenu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
   -- self.Tard_TardMenu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
   -- self.Tard_TardMenu.Farm:MenuElement({id = "FarmW", name = "Use W", value = true})
   -- self.Tard_TardMenu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})
   -- self.Tard_TardMenu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

    --[[Misc]]
   self.Tard_TardMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
   self.Tard_TardMenu.Misc:MenuElement({id = "Passive", name = "Block spell if target is under passive", value = true, tooltip = "more dps, less burst"})
   self.Tard_TardMenu.Misc:MenuElement({id = "AntiGap", name = "Anti Gapcloser", value = true})
   self.Tard_TardMenu.Misc:MenuElement({id = "NotQ_underR", name = "Block Q under Ulti (more dps, less burst)", value = true})
   self.Tard_TardMenu.Misc:MenuElement({id = "E_AAreset", name = "Use E to reset AA (more dps, less burst)", value = true})

   --[[KS]]
   self.Tard_TardMenu:MenuElement({type = MENU, id = "KS", name = "KillSteal Settings"})
   self.Tard_TardMenu.KS:MenuElement({id = "Q_KS", name = "Use Q to try to KillSteal", value = true})
   self.Tard_TardMenu.KS:MenuElement({id = "E_KS", name = "Use E to try to KillSteal", value = true})
   self.Tard_TardMenu.KS:MenuElement({id = "R_KS", name = "Use R to try to KillSteal", value = true})

    --[[Draw]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})

    PrintChat("Menu Ok")
end


function TardQuinn:Tard_Tick()

-- Put everything you want to update every time the game ticks here (don't put too many calculations here or you'll drop FPS)
	if myHero.dead then return end	
	local Tard_Mode = Need:Tard_GetMode()
	if Tard_Mode == "Combo" or Tard_Mode == 1 then
		self:Tard_Combo()
	elseif Tard_Mode == "Harass" or Tard_Mode == 2 then
		self:Tard_Harass()
	end	
-------------------------------------------------------------------------------------------------------------------------------------------
    --ANTI GAP CLOSER

    if self.Tard_TardMenu.Misc.AntiGap:Value() then
    	self:Tard_AntiGapCloser()
    end

---------------------------------------------------------------------------------------------------------------------------------------------
    --KillSteal

    if self.Tard_TardMenu.KS.Q_KS:Value() or self.Tard_TardMenu.KS.E_KS:Value() or self.Tard_TardMenu.KS.R_KS:Value() then
      self:Tard_KillSteal()
    end
end
----------------------------------------------------------------------------------------------------------------------------------------
	--TO DO
	--if Need:Tard_GetMode() == "Clear" then
	--	self:Clear()
	--end
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

function TardQuinn:Tard_Combo()
	-- COMBO LOGIC HERE

		local Tard_target = Need:Tard_QuinnTarget(925)
		if Tard_target == nil then return end	
		if Need:Tard_IsValidTarget(Tard_target,925) then	
		  local Tard_AAstate =	myHero.attackData.state    
      local Tard_AArange = myHero.range    
	-- CAST Q SPELL	
			if self.Tard_TardMenu.Combo.ComboQ:Value() and Tard_AAstate ~= 2  and Game.CanUseSpell(_Q) == 0 then    
				if (Need:Tard_GetDistanceSqr(Tard_target.pos) > Tard_AArange or (Need:Tard_HasBuff(Tard_target, "QuinnW") == 0 or not self.Tard_TardMenu.Misc.Passive:Value())) and (Need:Tard_HasBuff(myHero, "QuinnR") == 0 or not self.Tard_TardMenu.Misc.NotQ_underR:Value()) then					
					Need:Tard_CastQ(Tard_target)
          Tard_AAstate =  myHero.attackData.state
          Tard_AArange = myHero.range
				end
    
	-- CAST E SPELL
			elseif self.Tard_TardMenu.Combo.ComboE:Value() and (Tard_AAstate == 3 or not self.Tard_TardMenu.Misc.E_AAreset:Value()) and Game.CanUseSpell(_E) == 0 then	      
				      if Need:Tard_GetDistanceSqr(Tard_target.pos) > Tard_AArange or (Need:Tard_HasBuff(Tard_target, "QuinnW") == 0 or not self.Tard_TardMenu.Misc.Passive:Value()) then
					       Need:Tard_CastE(Tard_target)
				      end
			end		
		end	
end

function TardQuinn:Tard_Harass()	
	 -- HARASS LOGIC HERE

	local Tard_target = Need:Tard_QuinnTarget(925)
	if Tard_target == nil then return end
	if Need:Tard_IsValidTarget(Tard_target,925) then
    local Tard_AAstate =  myHero.attackData.state    
    local Tard_AArange = myHero.range  
	-- CAST Q SPELL	
		if self.Tard_TardMenu.Harass.HarassQ:Value() and (myHero.mana/myHero.maxMana >= self.Tard_TardMenu.Harass.HarassMana:Value()/100) and Tard_AAstate ~= 2 and Game.CanUseSpell(_Q) == 0 then
			if (Need:Tard_GetDistanceSqr(Tard_target.pos) > Tard_AArange or (Need:Tard_HasBuff(Tard_target, "QuinnW") == 0  or not self.Tard_TardMenu.Misc.Passive:Value())) and (Need:Tard_HasBuff(myHero, "QuinnR") == 0 or not self.Tard_TardMenu.Misc.NotQ_underR:Value()) then
				Need:Tard_CastQ(Tard_target)
        Tard_AAstate =  myHero.attackData.state
        Tard_AArange = myHero.range
			end
	-- CAST E SPELL			
		elseif self.Tard_TardMenu.Harass.HarassE:Value() and (myHero.mana/myHero.maxMana >= self.Tard_TardMenu.Harass.HarassMana:Value()/100) and (Tard_AAstate == 3 or not self.Tard_TardMenu.Misc.E_AAreset:Value()) and Game.CanUseSpell(_E) == 0 then
			if Need:Tard_GetDistanceSqr(Tard_target.pos) > Tard_AArange or (Need:Tard_HasBuff(Tard_target, "QuinnW") == 0 or not self.Tard_TardMenu.Misc.Passive:Value()) then
				Need:Tard_CastE(Tard_target)
			end
		end	
	end
end		

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function TardQuinn:Tard_KillSteal()
  for i=1, Game.HeroCount() do
        local Tard_hero = Game.Hero(i)
        if Need:Tard_GetDistanceSqr(Tard_hero.pos) <= Tard_QuinnSpellQ.range and Need:Tard_IsValidTarget(Tard_hero) then
          local Tard_Q_DMG = 0
          local Tard_E_DMG = 0
          local Tard_R_DMG = 0
          if self.Tard_TardMenu.KS.Q_KS:Value() and Game.CanUseSpell(_Q) == 0 then Tard_Q_DMG = self.Tard_QuinnQ_Dmg(Tard_hero) end
          if self.Tard_TardMenu.KS.E_KS:Value() and Game.CanUseSpell(_E) == 0 then Tard_E_DMG = self.Tard_QuinnE_Dmg(Tard_hero) end
          if self.Tard_TardMenu.KS.R_KS:Value() and Need:Tard_HasBuff(myHero, "QuinnR") == 1 then Tard_R_DMG = self.Tard_QuinnR_Dmg(Tard_hero) end          
            if Tard_E_DMG > 0 and Tard_hero.health + Tard_hero.shieldAD < Tard_E_DMG then
                Need:Tard_CastE(Tard_target) 
                print("it's working1")
            elseif Tard_Q_DMG > 0 and Tard_hero.health + Tard_hero.shieldAD < Tard_Q_DMG then
                Need:Tard_CastQ(Tard_target)
                print("it's working2")
            elseif Tard_E_DMG > 0 and Tard_Q_DMG > 0 and Tard_hero.health + Tard_hero.shieldAD < Tard_E_DMG + Tard_Q_DMG  then
                Need:Tard_CastE(Tard_hero)
                DelayAction(function()
                  Need:Tard_CastQ(Tard_hero)
                end, 0.25 + Tard_QuinnSpellQ.delay)
                print("it's working3")
            elseif Tard_E_DMG > 0 and Tard_Q_DMG > 0 and Tard_R_DMG > 0 and Tard_hero.health + Tard_hero.shieldAD < Tard_E_DMG + Tard_Q_DMG + Tard_R_DMG  then 
                Need:Tard_CastE(Tard_hero)
                DelayAction(function()
                  Need:Tard_CastQ(Tard_hero)
                end, 0.25 + Tard_QuinnSpellQ.delay)
                print("it's working4")
                return
            end
        end   
  end
end
function TardQuinn:Tard_AntiGapCloser()
    for i = 1, Game.HeroCount() do
        local Tard_Hero = Game.Hero(i)
        if Need:Tard_IsValidTarget(Tard_Hero,350) and Need:Tard_GetDistanceSqr(Tard_Hero.pos) > Need:Tard_GetDistanceSqr(Tard_Hero.posTo)  then
          Need:Tard_CastE(Hero)         
        end 
      end
end

function TardQuinn:Tard_Draw()
    if myHero.dead then return end
    local Tard_DrawMenu = self.Tard_TardMenu.Draw

    if self.Tard_TardMenu.Draw.DrawReady:Value() then
    	local Tard_Spell = Game.CanUseSpell    	
        if Tard_Spell(_Q) == 0 and Tard_DrawMenu.DrawQ:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellQ.range, 1, Draw.Color(255, 96, 203, 67))
        end
        if Tard_Spell(_W) == 0 and Tard_DrawMenu.DrawW:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellW.range, 1, Draw.Color(255, 255, 255, 255))
        end
        if Tard_Spell(_E) == 0 and Tard_DrawMenu.DrawE:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellE.range, 1, Draw.Color(255, 255, 255, 255))
        end
       
    else
        if Tard_DrawMenu.DrawQ:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellQ.range, 1, Draw.Color(255, 96, 203, 67))
        end
        if Tard_DrawMenu.DrawW:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellW.range, 1, Draw.Color(255, 255, 255, 255))
        end
        if Tard_DrawMenu.DrawE:Value() then
            Draw.Circle(myHero.pos, Tard_QuinnSpellE.range, 1, Draw.Color(255, 255, 255, 255))
        end
       
    end

    if Tard_DrawMenu.DrawTarget:Value() then
        local Tard_drawTarget = Need:Tard_QuinnTarget(925)
        if Tard_drawTarget then
            Draw.Circle(Tard_drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

