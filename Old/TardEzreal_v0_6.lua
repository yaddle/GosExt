
class "Need"
local toto = 36
function Need:__init()

	self.Tard_version = 1.1
	print("Hello ", myHero.name, ", TardEzreal v", self.Tard_version, " is ready to feed")

	self.DamageReductionTable = {
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

	if _G.EOWLoaded then 
		self.Tard_Orb = 0; print("New Eternal Orb is good but Tosh is still toxic ^^") 
	elseif _G.SDK and _G.SDK.Orbwalker then 
		self.Tard_Orb = 1; print("IC is a good Orb")		
		self.Tard_SDK = _G.SDK.Orbwalker		
    self.Tard_SDKCombo = _G.SDK.ORBWALKER_MODE_COMBO      	
    self.Tard_SDKHarass = _G.SDK.ORBWALKER_MODE_HARASS
    self.Tard_SDKJungleClear = _G.SDK.ORBWALKER_MODE_JUNGLECLEAR
    self.Tard_SDKLaneClear = _G.SDK.ORBWALKER_MODE_LANECLEAR
    self.Tard_SDKLastHit = _G.SDK.ORBWALKER_MODE_LASTHIT
    self.Tard_SDKFlee = _G.SDK.ORBWALKER_MODE_FLEE
    self.Tard_SDKSelector = _G.SDK.TargetSelector
    self.Tard_SDKHealthPrediction = _G.SDK.HealthPrediction
	else 
		print("Noddy rocks") 
	end	
end

function Need:Tard_GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myHero.pos
	local Tard_dx = Pos1.x - Pos2.x
	local Tard_dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return (Tard_dx * Tard_dx) + (Tard_dz * Tard_dz)
end

function Need:Tard_PercentMP()
	return (myHero.mana / myHero.maxMana) * 100
end

function Need:Tard_IsValidTarget(unit,range)
	local range = range or math.huge
	return unit and unit.isEnemy and unit.valid and Need:Tard_GetDistanceSqr(unit.pos) <= (range*range) and unit.visible and unit.isTargetable and not unit.dead and not unit.isImmune 
end

function Need:Tard_HasBuff(unit, buffname)
	for i = 0,  unit.buffCount do
		local Tard_Buff = unit:GetBuff(i)
		if Tard_Buff and Tard_Buff.name ~= "" and Tard_Buff.count > 0 and Game.Timer() >= Tard_Buff.startTime and Game.Timer() < Tard_Buff.expireTime and Tard_Buff.name == buffname then
			return  Tard_Buff.count
		end
	end
	return 0
end		

function Need:Tard_GetMode()
		if self.Tard_Orb == 0 then
			if EOW.CurrentMode == 1 then
				return "Combo"
			elseif EOW.CurrentMode == 2 then
			 	return "Harass"
			elseif EOW.CurrentMode == 3 then
				return "Lasthit"
			elseif EOW.CurrentMode == 4 then
				return "Clear"
			end
		elseif self.Tard_Orb == 1 then		
			if self.Tard_SDK.Modes[self.Tard_SDKCombo] then				
				return "Combo"
			elseif self.Tard_SDK.Modes[self.Tard_SDKHarass] then
				return "Harass"	
			elseif self.Tard_SDK.Modes[self.Tard_SDKLaneClear] or self.Tard_SDK.Modes[self.Tard_SDKJungle] then
				return "Clear"
			elseif self.Tard_SDK.Modes[self.Tard_SDKLastHit] then
				return "Lasthit"
			elseif self.Tard_SDK.Modes[self.Tard_SDKFlee] then
				return "Flee"
			end
		else 
			return GOS.GetMode()
		end
end

function Need:Tard_GetTarget(range)
	local Tard_target 
	if self.Tard_Orb == 0 then
		Tard_target = EOW:GetTarget(range, easykill_acd)
	elseif self.Tard_Orb == 1 then
        if myHero.totalDamage >= myHero.ap then Tard_target = self.Tard_SDKSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL)			
        else Tard_target = self.Tard_SDKSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL)			
        end
	else
		Tard_target = GOS:GetTarget(range)
	end
	return Tard_target
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function Need:Tard_CastSpell(spell, pos, delay)
	if pos == nil then return end
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
		end
		if castSpell.state == 1 then
			if ticker - castSpell.tick < Game.Latency() then
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				castSpell.casting = ticker + delay
				DelayAction(function()
					if castSpell.state == 1 then
						Control.SetCursorPos(castSpell.mouse)
						castSpell.state = 0
					end
				end, Game.Latency()/1000)
			end
			if ticker - castSpell.casting > Game.Latency() then
				Control.SetCursorPos(castSpell.mouse)
				castSpell.state = 0
			end
		end	
end

function Need:Tard_HP_PRED(unit, time)
  if self.Tard_Orb == 0 then
    return EOW:GetHealthPrediction(unit,time)
  elseif self.Tard_Orb == 1 then
    return self.Tard_SDKHealthPrediction:GetPrediction(unit, time)
  else
    return GOS:HP_Pred(unit,time)
  end
end

function Need:Tard_GetEnemynearMouse()
    for i = 1, Game.HeroCount() do
        local Tard_H = Game.Hero(i)
        if Need:Tard_IsValidTarget(Tard_H) and Need:Tard_GetDistanceSqr(_G.mousePos, Tard_H.pos) <= 100 * 100 then
            print("ok")
            return Tard_H        
        end
        break
    end
end

function Need:Tard_GetEnemybyHandle(handle)
	for i = 1, Game.HeroCount() do
		local Tard_h = Game.Hero(i)
		if Tard_h.handle == handle then
			return Tard_h
		end
	end
end 
-------------------------------------------------------------------------------------------------------------------------------------------
--local dmglib

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

function Need:CalcMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
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
    
        if self.DamageReductionTable[target.charName] then
          if buff.name == self.DamageReductionTable[target.charName].buff and (not self.DamageReductionTable[target.charName].damagetype or self.DamageReductionTable[target.charName].damagetype == DamageType) then
            amount = amount * self.DamageReductionTable[target.charName].amount(target)
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

------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
class "TardEzreal"

function TardEzreal:__init()
    require("Eternal Prediction")   
	self.Tard_EzrealSpells = { 
		[0] = {range = 1175, delay = 0.25, speed = 2000, width = 60, spellType = TYPE_LINE, hitBox = true},	
		[1] = {range = 1050, delay = 0.54, speed = 1600, width = 80, spellType = TYPE_LINE, hitBox = false},
		[2] = {range = 450},
		[3] = {range = 20000, delay = 1.76, speed = 2000, width = 160, spellType = TYPE_LINE, hitBox = false}
	}

    if _G.Prediction_Loaded then self.Tard_EternalPred = true; print("Tosh Pred loaded ;)");
            self.Tard_SpellstoPred = {
            [0] = Prediction:SetSpell(self.Tard_EzrealSpells[0], self.Tard_EzrealSpells[0].spellType, self.Tard_EzrealSpells[0].hitBox),
            [1] = Prediction:SetSpell(self.Tard_EzrealSpells[1], self.Tard_EzrealSpells[1].spellType, self.Tard_EzrealSpells[1].hitBox),
            [3] = Prediction:SetSpell(self.Tard_EzrealSpells[3], self.Tard_EzrealSpells[3].spellType, self.Tard_EzrealSpells[3].hitBox)
            }
    else 
            require("Collision")
            print("collision loaded")
            self.Tard_SpellstoCollision = {
            [0] = Collision:SetSpell(self.Tard_EzrealSpells[0].range, self.Tard_EzrealSpells[0].speed, self.Tard_EzrealSpells[0].delay, self.Tard_EzrealSpells[0].width, self.Tard_EzrealSpells[0].hitBox),
            [3] = Collision:SetSpell(self.Tard_EzrealSpells[3].range, self.Tard_EzrealSpells[3].speed, self.Tard_EzrealSpells[0].delay, self.Tard_EzrealSpells[3].width, self.Tard_EzrealSpells[3].hitBox)   
            }
    end  
    for i = 0, 3 do
        if i == 0 then self.Tard_EzrealSpells[i].dmg = function(unit) local Tard_level=myHero:GetSpellData(0).level return Need:CalcPhysicalDamage(myHero, unit, ({35, 55, 75, 95, 115})[Tard_level] + 1.1 * myHero.totalDamage + 0.4 * myHero.ap) end
        elseif i == 1 then self.Tard_EzrealSpells[i].dmg = function(unit) local Tard_level=myHero:GetSpellData(1).level return Need:CalcMagicalDamage(myHero, unit, ({70, 115, 160, 205, 250})[Tard_level] + 0.8 * myHero.ap) end
        elseif i == 3 then
            self.Tard_EzrealSpells[i].dmg = function(unit)
            local Tard_level = myHero:GetSpellData(i).level
            local Tard_initialdmg = ({350, 500, 650})[Tard_level] + 0.9 * myHero.ap + myHero.bonusDamage
            local Tard_Collision
            if self.Tard_EternalPred == true then
                local pred = self.Tard_SpellstoPred[i]:GetPrediction(unit, myHero.pos)
                Tard_Collision = pred:mCollision() + pred:hCollision()
            else
                local Tard_RblockUnit 
                Tard_Collision, Tard_RblockUnit = self.Tard_SpellstoCollision[i]:__GetCollision(myHero, unit, 5)
                Tard_Collision = #Tard_RblockUnit
            end
            local Tard_nerf = math.min(Tard_Collision,7)
            local Tard_finaldmg = Tard_initialdmg * ((10 - Tard_nerf) / 10)
            return Need:CalcMagicalDamage(myHero, unit, Tard_finaldmg)
            end
        end
    end
    self.myHero = myHero
    self.Tard_SelectedTarget = nil
    self:Tard_Menu() 
	Callback.Add("Tick", function() self:Tard_Tick() end)
    Callback.Add("Draw", function() self:Tard_Draw() end)
    Callback.Add('WndMsg', function(msg, wParam) self:Tard_OnWndMsg(msg, 0x54) end)
end

function TardEzreal:Tard_Menu()
    self.Tard_TardMenu = MenuElement({type = MENU, id = "TardEzrealMenu", name = "TardEzreal", leftIcon="https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c3/EzrealSquare.png"})

        --[[Combo]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboQmana", name = "Min. Mana to Q", value = 0, min = 0, max = 100, tooltip = "It's %"}) 
    self.Tard_TardMenu.Combo:MenuElement({id = "ComboWmana", name = "Min. Mana to W", value = 25, min = 0, max = 100, tooltip = "It's %"})  

        --[[Harass]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassQMana", name = "Min. Mana to Q", value = 40, min = 0, max = 100, tooltip = "It's %"})
    self.Tard_TardMenu.Harass:MenuElement({id = "HarassWMana", name = "Min. Mana to W", value = 70, min = 0, max = 100, tooltip = "It's %"})
        
        --[[Farm]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.Tard_TardMenu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})  
    self.Tard_TardMenu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 60, min = 0, max = 100, tooltip = "It's %"})

        --[[LastHit]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
    self.Tard_TardMenu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
    self.Tard_TardMenu.LastHit:MenuElement({id = "LastHitMana", name = "Min Mana To Lasthit", value = 40, min = 0, max = 100, tooltip = "It's %"})

        --[[JungleClear]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
    self.Tard_TardMenu.JungleClear:MenuElement({id = "JungleQ", name = "Use Q", value = true})
    self.Tard_TardMenu.JungleClear:MenuElement({id = "JungleMana", name = "Min Mana To JungleClear", value = 40, min = 0, max = 100, step = 1, tooltip = "It's %"})  
    
    --[[KS]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "KS", name = "KillSteal Settings"})
    self.Tard_TardMenu.KS:MenuElement({id = "Q_KS", name = "Use Q to try to KillSteal", value = true})
    self.Tard_TardMenu.KS:MenuElement({id = "W_KS", name = "Use W to try to KillSteal", value = true})
    self.Tard_TardMenu.KS:MenuElement({id = "R_KS", name = "Use R to try to KillSteal", value = true})
    self.Tard_TardMenu.KS:MenuElement({id = "R_Ksrange", name = "R Max Range", value = 10000, min = 300, max = 20000, step = 100, tooltip = "It's %"})

    --[[Misc]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.Tard_TardMenu.Misc:MenuElement({id = "Rkey", name = "Ulti Champ near mouse on key", key = string.byte("T")}) 
    self.Tard_TardMenu.Misc:MenuElement({id = "KeepRmana", name = "Keep mana for R", value = false, tooltip = "KillSteal never keep mana"})  
    self.Tard_TardMenu.Misc:MenuElement({id = "SelectedTarget", name = "Focus Spell target", value = true, tooltip = "Focus Spell on selected target"}) 
    
        --[[Pred]]
    if self.Tard_EternalPred then
        self.Tard_TardMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
        self.Tard_TardMenu.Pred:MenuElement({id = "PredHitChance", name = "HitChance (default 25)", value = 25, min = 0, max = 100,  tooltip = "higher value better pred but slower(%)||don't change it if don't know what is it||"})
    end

        --[[Draw]]
    self.Tard_TardMenu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DrawSpellTarget", name = "Draw Spell Target Focus [?]", value = true, tooltip = "Draws spell target focus"})
    self.Tard_TardMenu.Draw:MenuElement({id = "DisableDraw", name = "Disable all Draws [?]", value = false})

    PrintChat("Menu Ok")
end

function TardEzreal:Tard_Tick()
	if myHero.dead then return end	
 -- if (self.Tard_TardMenu.Combo.ComboW:Value() and Game.CanUseSpell(3) == 0 and myHero.mana >= 140) or (Game.CanUseSpell(3) == 1 or not self.Tard_TardMenu.Combo.ComboW:Value()) then
	local Tard_Mode = Need:Tard_GetMode()	
	if Tard_Mode == "Combo" then
	    self:Tard_Combo()   
	elseif Tard_Mode == "Harass" then
	    self:Tard_Harass()
    elseif Tard_Mode == "Lasthit" then
        self:Tard_LastHit() 
    elseif Tard_Mode == "Clear" then 
        self:Tard_LastHit()
        self:Tard_Farm()
        self:Tard_JungleClear() 
	end       
 -- end 
          
    self:Tard_KillSteal()
    self:Tard_RonKey()
end

local Tard_CurrentTarget
function TardEzreal:Tard_Combo()
    local Tard_target
    if self.Tard_SelectedTarget == nil or not Need:Tard_IsValidTarget(self.Tard_SelectedTarget, 1175) then
        Tard_target = Need:Tard_GetTarget(1175)        
    else
        Tard_target = self.Tard_SelectedTarget
    end
    if Tard_target == nil or myHero.attackData.state == 2  then return end  
	--CAST Q SPELL
	if self.Tard_TardMenu.Combo.ComboQ:Value() and Need:Tard_PercentMP() >= self.Tard_TardMenu.Combo.ComboQmana:Value() and Game.CanUseSpell(_Q) == 0 and Need:Tard_IsValidTarget(Tard_target, self.Tard_EzrealSpells[0].range) then
        self:Tard_CastQ(Tard_target)
        Tard_CurrentTarget = Tard_target
	--CAST W SPELL
	elseif self.Tard_TardMenu.Combo.ComboW:Value() and Need:Tard_PercentMP() >= self.Tard_TardMenu.Combo.ComboWmana:Value() and Game.CanUseSpell(_W) == 0 and Need:Tard_IsValidTarget(Tard_target, self.Tard_EzrealSpells[1].range) then
		self:Tard_CastW(Tard_target)
        Tard_CurrentTarget = Tard_target
	end
end

function TardEzreal:Tard_Harass()
	local Tard_target
    if self.Tard_SelectedTarget == nil or not Need:Tard_IsValidTarget(self.Tard_SelectedTarget, 1175) then
        Tard_target = Need:Tard_GetTarget(1175)        
    else
        Tard_target = self.Tard_SelectedTarget
    end
    if Tard_target == nil or myHero.attackData.state == 2  then return end 
	--CAST Q SPELL
	if self.Tard_TardMenu.Harass.HarassQ:Value() and Need:Tard_PercentMP() >= self.Tard_TardMenu.Harass.HarassQMana:Value() and Game.CanUseSpell(_Q) == 0 and Need:Tard_IsValidTarget(Tard_target, self.Tard_EzrealSpells[0].range) then
		if myHero.activeSpell.valid ~= true then
            self:Tard_CastQ(Tard_target)
            Tard_CurrentTarget = Tard_target
        end
    end
	--CAST W SPELL
	if self.Tard_TardMenu.Harass.HarassW:Value() and Need:Tard_PercentMP() >= self.Tard_TardMenu.Harass.HarassWMana:Value() and Game.CanUseSpell(_W) == 0 and Need:Tard_IsValidTarget(Tard_target, self.Tard_EzrealSpells[1].range) then
		if myHero.activeSpell.valid ~= true then
            self:Tard_CastW(Tard_target)
            Tard_CurrentTarget = Tard_target
        end
	end
end

function TardEzreal:Tard_Farm()
	if not self.Tard_TardMenu.Farm.FarmQ:Value() or Need:Tard_PercentMP() < self.Tard_TardMenu.Farm.FarmMana:Value() or myHero.attackData.state == 2 or Game.CanUseSpell(0) ~= 0 then return end
	for i = 1, Game.MinionCount() do
		local Tard_Minion = Game.Minion(i)
		if Need:Tard_IsValidTarget(Tard_Minion, self.Tard_EzrealSpells[0].range) and Tard_Minion.team ~= 300 then
			self:Tard_CastQ(Tard_Minion)
			break
		end
	end
end

function TardEzreal:Tard_JungleClear()
	if not self.Tard_TardMenu.JungleClear.JungleQ:Value() or Need:Tard_PercentMP() < self.Tard_TardMenu.JungleClear.JungleMana:Value() or myHero.attackData.state == 2 or Game.CanUseSpell(_Q) ~= 0 then return end
    for i = 1, Game.MinionCount() do
		local Tard_JungleMinion = Game.Minion(i)
		if Tard_JungleMinion.team == 300 and Need:Tard_IsValidTarget(Tard_JungleMinion, self.Tard_EzrealSpells[0].range) then
            self:Tard_CastQ(Tard_JungleMinion)
			break
		end
	end	
end

function TardEzreal:Tard_LastHit()
    print(toto)  
	local Tard_AAstate = myHero.attackData.state
	if not self.Tard_TardMenu.LastHit.LastHitQ:Value() or Need:Tard_PercentMP() < self.Tard_TardMenu.LastHit.LastHitMana:Value() or Tard_AAstate == 2 or Game.CanUseSpell(_Q) ~= 0 then return end
	local Tard_AAtarget = myHero.attackData.target
	local Tard_AArange = myHero.range 
	for i = 1, Game.MinionCount() do
		local Tard_Minion = Game.Minion(i)
		if Tard_AAtarget ~= Tard_Minion.handle and Need:Tard_IsValidTarget(Tard_Minion, self.Tard_EzrealSpells[0].range) and self.Tard_EzrealSpells[0].dmg(Tard_Minion) >= Tard_Minion.health then
            if self.Tard_Orb == 0 then
                if Tard_AAstate == 3 or not EOW:CanOrb(Tard_Minion) then
                    self:Tard_CastQ(Tard_Minion)
				    break
                end
            elseif (Tard_AAstate == 3 and Need:Tard_HP_PRED(Tard_Minion, myHero.attackData.endTime - Game.Timer()) > 0) or (Need:Tard_GetDistanceSqr(Tard_Minion.pos) > Tard_AArange*Tard_AArange and Tard_AAstate ~= 2)  then
				--test si minion va mourir avant le reset aa et tard_hp_pred (temps = myHero.attackData.endTime-Game.Timer() ou attackData.animationTime)
                self:Tard_CastQ(Tard_Minion)
				break
			end
		end		
	end
end

function TardEzreal:Tard_KillSteal()
	if myHero.attackData.state == 2 then return end	
	for i = 1, Game.HeroCount() do
		local Tard_Hero = Game.Hero(i)
		if Need:Tard_IsValidTarget(Tard_Hero) then
			local Tard_Q_DMG; local Tard_W_DMG; local Tard_R_DMG;
			if self.Tard_TardMenu.KS.Q_KS:Value() and Game.CanUseSpell(0) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= self.Tard_EzrealSpells[0].range*self.Tard_EzrealSpells[0].range then 
                Tard_Q_DMG = self.Tard_EzrealSpells[0].dmg(Tard_Hero)
            end 
            if self.Tard_TardMenu.KS.W_KS:Value() and Game.CanUseSpell(1) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= self.Tard_EzrealSpells[1].range*self.Tard_EzrealSpells[1].range then 
                Tard_W_DMG = self.Tard_EzrealSpells[1].dmg(Tard_Hero) 
            end
            if self.Tard_TardMenu.KS.R_KS:Value() and Game.CanUseSpell(3) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= self.Tard_TardMenu.KS.R_Ksrange:Value()*self.Tard_TardMenu.KS.R_Ksrange:Value() then 
                Tard_R_DMG = self.Tard_EzrealSpells[3].dmg(Tard_Hero) 
            end
			if Tard_W_DMG ~= nil and Tard_W_DMG > Tard_Hero.health + Tard_Hero.shieldAP then
				    print("KS W")
                    print(Tard_W_DMG)
                    self:Tard_CastW(Tard_Hero)
                    Tard_CurrentTarget = Tard_Hero
            end
			if Tard_Q_DMG ~= nil and Tard_Q_DMG > Tard_Hero.health + Tard_Hero.shieldAD then
                    print("KS Q")
                    print(Tard_Q_DMG)
                    self:Tard_CastQ(Tard_Hero)
                    Tard_CurrentTarget = Tard_Hero
            end
			if Tard_Q_DMG ~= nil and Tard_W_DMG ~= nil and Tard_Q_DMG + Tard_W_DMG > Tard_Hero.health + Tard_Hero.shieldAD + Tard_Hero.shieldAP then
                    print("KS W+Q")
                    Tard_CurrentTarget = Tard_Hero
                    self:Tard_CastQ(Tard_Hero)
                    DelayAction(function()
                        self:Tard_CastW(Tard_Hero)
                        end, self.Tard_EzrealSpells[0].delay + Game.Latency()/1000)
            end           
			if Tard_R_DMG and Tard_R_DMG > Tard_Hero.health + Tard_Hero.shieldAP then
                    print("KS R")
                    print(Tard_R_DMG)
                    local Tard_AArange = myHero.range                    
                    if Need:Tard_GetDistanceSqr(Tard_Hero.pos) > Tard_AArange*Tard_AArange then
                    -- include Y dans GetDistance pour plus de precision
                        self:Tard_CastR(Tard_Hero)
                        Tard_CurrentTarget = Tard_Hero
                    end
			end
		end
	end
end

function TardEzreal:Tard_CastQ(unit)
  if self.Tard_EternalPred == true then 
    local Tard_QPred = self.Tard_SpellstoPred[0]:GetPrediction(unit, myHero.pos)
      if Tard_QPred and (Tard_QPred.hitChance >= self.Tard_TardMenu.Pred.PredHitChance:Value()/100) and Tard_QPred:mCollision() == 0 and Tard_QPred:hCollision() == 0 and Need:Tard_GetDistanceSqr(Tard_QPred.castPos) <= 1380625 then
        Need:Tard_CastSpell(HK_Q,Tard_QPred.castPos, 250)            
      end 
  else
    local Tard_QPred = unit:GetPrediction(self.Tard_EzrealSpells[0].speed, self.Tard_EzrealSpells[0].delay + Game.Latency()/1000)
    local Tard_QCollision, Tard_QblockUnit = self.Tard_SpellstoCollision[0]:__GetCollision(myHero, unit, 5)
    if (Tard_QCollision == false or (unit.type == Obj_AI_Minion and #Tard_QblockUnit == 1)) and Need:Tard_GetDistanceSqr(Tard_QPred) < (self.Tard_EzrealSpells[0].range*self.Tard_EzrealSpells[0].range) then-- 1380625 then
      --Need:Tard_CastSpell(HK_Q, Tard_QPred, self.Tard_EzrealSpells[0].delay)   
        GOS.BlockMovement = true
      --GOS.BlockAttack = true
        Control.CastSpell(HK_Q, Tard_QPred)
        GOS.BlockMovement = false
      --GOS.BlockAttack = false
    end
  end
end

function TardEzreal:Tard_CastW(unit)
    if self.Tard_EternalPred == true then
        local Tard_WPred = self.Tard_SpellstoPred[1]:GetPrediction(unit, myHero.pos)
        if Tard_WPred and Tard_WPred.hitChance >= self.Tard_TardMenu.Pred.PredHitChance:Value()/100 and Need:Tard_GetDistanceSqr(Tard_WPred.castPos) < 1050625 then
            Need:Tard_CastSpell(HK_W,Tard_WPred.castPos,540)  
        end
    else
        local Tard_WPred = unit:GetPrediction(self.Tard_EzrealSpells[1].speed, self.Tard_EzrealSpells[1].delay + Game.Latency()/1000)
        if Need:Tard_GetDistanceSqr(Tard_WPred) < 1050625 then
        --Need:Tard_CastSpell(HK_W, Tard_WPred, self.Tard_EzrealSpells[0].delay)
        GOS.BlockMovement = true
        --GOS.BlockAttack = true
        Control.CastSpell(HK_W, Tard_WPred)
        GOS.BlockAttack = false
    --  GOS.BlockAttack = false
        end
    end 
end

function TardEzreal:Tard_CastR(unit)
print(toto)  
    if self.Tard_EternalPred == true then  
      local Tard_RPred = self.Tard_SpellstoPred[3]:GetPrediction(unit, myHero.pos)
      if Tard_RPred and (Tard_RPred.hitChance >= self.Tard_TardMenu.Pred.PredHitChance:Value()/100) then
            Tard_RPred.castPos = Vector(Tard_RPred.castPos)
            Tard_RPred.castPos = myHero.pos + Vector(Tard_RPred.castPos - myHero.pos):Normalized() * math.random(500,800)
            Need:Tard_CastSpell(HK_R,Tard_RPred.castPos, 1760)
      end 
    else
      local Tard_RPred = unit:GetPrediction(self.Tard_EzrealSpells[3].speed, self.Tard_EzrealSpells[3].delay + Game.Latency()/1000)    
      if Need:Tard_GetDistanceSqr(myHero.pos,Tard_RPred) < (self.Tard_EzrealSpells[3].range*self.Tard_EzrealSpells[3].range) then
        Need:Tard_CastSpell(HK_R, Tard_RPred, self.Tard_EzrealSpells[3].delay)
      end
    end
end

function TardEzreal:Tard_RonKey()
    if self.Tard_TardMenu.Misc.Rkey:Value() and Game.CanUseSpell(3) == 0 and self.Tard_SelectedTarget ~= nil then
        local Tard_Rtarget = self.Tard_SelectedTarget
        if Tard_Rtarget then
        print(self.Tard_EternalPred)
        
            TardEzreal:Tard_CastR(Tard_Rtarget)
        end
    end
end

function TardEzreal:Tard_Draw()
    if myHero.dead or self.Tard_TardMenu.Draw.DisableDraw:Value() then return end
    local Tard_EzrealPos = myHero.pos
    local Tard_DrawMenu = self.Tard_TardMenu.Draw
    local Tard_DrawCircle = Draw.Circle
    if Tard_DrawMenu.DrawReady:Value() then
      local Tard_Spell = Game.CanUseSpell     
        if Tard_Spell(_Q) == 0 and Tard_DrawMenu.DrawQ:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[0].range, 1, Draw.Color(255, 96, 203, 67))
        end
        if Tard_Spell(_W) == 0 and Tard_DrawMenu.DrawW:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[1].range, 1, Draw.Color(255, 255, 255, 255))
        end
        if Tard_Spell(_E) == 0 and Tard_DrawMenu.DrawE:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[2].range, 1, Draw.Color(255, 255, 255, 255))
        end
    else
        if Tard_DrawMenu.DrawQ:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[0].range, 1, Draw.Color(255, 96, 203, 67))
        end
        if Tard_DrawMenu.DrawW:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[1].range, 1, Draw.Color(255, 255, 255, 255))
        end
        if Tard_DrawMenu.DrawE:Value() then
            Draw.Circle(Tard_EzrealPos, self.Tard_EzrealSpells[2].range, 1, Draw.Color(255, 255, 255, 255))
        end
    end
    if Tard_DrawMenu.DrawTarget:Value() then
        local Tard_drawTarget = Tard_CurrentTarget
        if Tard_drawTarget == nil or Tard_drawTarget.dead then return 
        else
            Tard_DrawCircle(Tard_drawTarget,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
    if Tard_DrawMenu.DrawSpellTarget:Value() then
        if self.Tard_TardMenu.Misc.SelectedTarget:Value() and Need:Tard_IsValidTarget(self.Tard_SelectedTarget) then
            Tard_DrawCircle(self.Tard_SelectedTarget.pos, 80, 3,Draw.Color(255, 0, 0 ,255))
        end
    end
end

function TardEzreal:Tard_OnWndMsg(msg, wParam)
    if msg == WM_LBUTTONDOWN then
        if self.Tard_TardMenu.Misc.SelectedTarget:Value() then
            --local Tard_hero = Need:Tard_GetEnemynearMouse()
            for i = 1, Game.HeroCount() do
                local H = Game.Hero(i)
                if Need:Tard_GetDistanceSqr(H.pos, _G.mousePos) <= 100*100 then
                    if (H ~= nil and self.Tard_SelectedTarget ~= nil) and self.Tard_SelectedTarget.networkID == H.networkID then
                        self.Tard_SelectedTarget = nil;
                    else
                        self.Tard_SelectedTarget = H
                    end
                    break;
                end
            end
        end
    end
    --if msg == KEY_DOWN and wParam == 0x54 then 
    --    self:Tard_CastR(self.Tard_SelectedTarget)
    --end

end

--------------------------------------------------------------------------------------------------------------------------------------
Callback.Add("Load", function() 
	if _G["TardEzreal"] and myHero.charName == "Ezreal" then		
		_G["TardEzreal"]()
		_G.Need = Need()
	end
end)


