--Datas----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tard_Icon = {
    ["Fiora"] = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/d/d2/FioraSquare.png",
    ["Botrk"] = "http://vignette2.wikia.nocookie.net/leagueoflegends/images/2/2f/Blade_of_the_Ruined_King_item.png",
    ["Cutlass"] = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/4/44/Bilgewater_Cutlass_item.png",
    ['Ravenous'] = "http://vignette1.wikia.nocookie.net/leagueoflegends/images/e/e8/Ravenous_Hydra_item.png",
    ['Tiamat'] = "http://vignette2.wikia.nocookie.net/leagueoflegends/images/e/e3/Tiamat_item.png"
} 
local Tard_version = 0; local myH = myHero; local Tard_Orb;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class "Need"
function Need:__init()
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
    self.Tard_ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3,[ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}

    if _G.EOWLoaded then 
        Tard_Orb = 0; print("New Eternal Orb is good but Tosh is still toxic ^^")  
    elseif _G.SDK and _G.SDK.Orbwalker then 
        Tard_Orb = 1; print("IC is a good Orb")		
        self.Tard_SDK = _G.SDK.Orbwalker		
        self.Tard_SDKCombo = _G.SDK.ORBWALKER_MODE_COMBO      	
        self.Tard_SDKHarass = _G.SDK.ORBWALKER_MODE_HARASS
        self.Tard_SDKJungleClear = _G.SDK.ORBWALKER_MODE_JUNGLECLEAR
        self.Tard_SDKLaneClear = _G.SDK.ORBWALKER_MODE_LANECLEAR
        self.Tard_SDKLastHit = _G.SDK.ORBWALKER_MODE_LASTHIT
        self.Tard_SDKFlee = _G.SDK.ORBWALKER_MODE_FLEE
        self.Tard_SDKSelector = _G.SDK.TargetSelector
        self.Tard_SDKHealthPrediction = _G.SDK.HealthPrediction
        self.Tard_SDKDamagePhysical = _G.SDK.DAMAGE_TYPE_PHYSICAL
        self.Tard_SDKDamageMagical = _G.SDK.DAMAGE_TYPE_MAGICAL
    else 
        print("Noddy rocks") 
    end	
end

function Need:Tard_GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or myH.pos
	local Tard_dx = Pos1.x - Pos2.x
	local Tard_dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
	return (Tard_dx * Tard_dx) + (Tard_dz * Tard_dz)
end

function Need:Tard_PercentHP(unit)
	return (unit.health / unit.maxHealth) * 100
end

function Need:Tard_PercentMP(unit)
	return (unit.mana / unit.maxMana) * 100
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
	if Tard_Orb == 0 then         
		if EOW.CurrentMode == 1 then
	        return "Combo"
		elseif EOW.CurrentMode == 2 then
			return "Harass"
		elseif EOW.CurrentMode == 3 then
			return "Lasthit"
		elseif EOW.CurrentMode == 4 then
			return "Clear"
		end
	elseif Tard_Orb == 1 then		
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
		return GOS:GetMode()
	end
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function Need:Tard_CastSpell(spell,pos,delay)
local range = range or math.huge
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and  ticker - castSpell.casting > delay + Game.Latency() then --and pos:ToScreen().onScreen then
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
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function Need:Tard_GetTarget(range, from) 
	local Tard_target 
	if Tard_Orb == 0 then
        local from = from or myH.pos
        if myH.totalDamage >= myH.ap then Tard_target = EOW:GetTarget(range, ad_dec, from)
        else Tard_target = EOW:GetTarget(range, ap_dec, from)
        end
	elseif Tard_Orb == 1 then
        if myH.totalDamage >= myH.ap then Tard_target = self.Tard_SDKSelector:GetTarget(range, self.Tard_SDKDamagePhysical)			
        else Tard_target = self.Tard_SDKSelector:GetTarget(range, self.Tard_SDKDamageMagical)			
        end
	else
        if myH.totalDamage >= myH.ap then Tard_target = GOS:GetTarget(range, "AD")
		else Tard_target = GOS:GetTarget(range, "AP")
        end
	end
	return Tard_target
end

function Need:Tard_HP_PRED(unit, time)
    if Tard_Orb == 0 then
        return EOW:GetHealthPrediction(unit,time)
    elseif Tard_Orb == 1 then
        return Tard_SDKHealthPrediction:GetPrediction(unit, time)
    else
        return GOS:HP_Pred(unit,time)
    end
end

function Need:Tard_UnderTower(unit)
    local count = 0
    local unit = unit or nil
    for i = 1, Game.TurretCount() do
        local turret = Game.Turret(i)
        if turret.valid and turret.isEnemy and not turret.dead then
            if unit and Need:Tard_GetDistanceSqr(turret.pos, unit.pos) <= (turret.boundingRadius + 750 + myHero.boundingRadius / 2)^2 then count = 1 break 
            elseif not unit and Need:Tard_GetDistanceSqr(turret.pos) <= 900*900 then count = 1 break
            end 
        end 
    end
    return count == 1    
end

function Need:Tard_AfterAttack(func)
	if Tard_Orb == 1 then
		_G.SDK.Orbwalker:OnPostAttack(func)		
	elseif Tard_Orb == 0 then
		EOW:AddCallback(EOW.AfterAttack, func)
	else 
		GOS:OnAttackComplete(func)
	end
end

function Need:Tard_UseItem(itemID, range, targetpos, needtarget)
    local needtarget = needtarget or 0
    local item = self:GetItemSlot(myH, itemID)
    if item >= 1 and myH:GetSpellData(item).currentCd == 0 and self:Tard_GetDistanceSqr(targetpos) <= range*range + (25*25) then
        if needtarget == 0 then
            Control.CastSpell(self.Tard_ItemHotKey[item])
        else
            self:Tard_CastSpell(self.Tard_ItemHotKey[item], targetpos, 50)
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
        if self:Tard_HasBuff(source, "Exhaust") > 0 then
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
class "TardFiora"   
function TardFiora:__init()
    self.Tard_FioraSpells = { 
        [0] = {range = 400, delay = 0.25, speed = 500, width = 0, spellType = TYPE_LINE, hitBox = false},	
        [1] = {range = 750, delay = 0.50, speed = 3200, width = 70, spellType = TYPE_LINE, hitBox = true},
        [2] = {range = 175, delay = 0.25},
        [3] = {range = 500, delay = 0.66}
    }
    if _G.Prediction_Loaded then self.Tard_EternalPred = true; print("Tosh Pred loaded ;)");
        self.Tard_SpellstoPred = {
        [0] = Prediction:SetSpell(self.Tard_FioraSpells[0], self.Tard_FioraSpells[0].spellType, self.Tard_FioraSpells[0].hitBox),
        [1] = Prediction:SetSpell(self.Tard_FioraSpells[1], self.Tard_FioraSpells[1].spellType, self.Tard_FioraSpells[1].hitBox),
        }
    end
    for i = 0, 3 do
        if i == 0 then self.Tard_FioraSpells[i].dmg = function(unit) local Tard_level=myH:GetSpellData(0).level return Need:CalcPhysicalDamage(myH, unit, ({65, 75, 85, 95, 105})[Tard_level] + (({0.95, 1, 1.05, 1.1, 1.15})[Tard_level] * myH.bonusDamage)) end
        elseif i == 1 then self.Tard_FioraSpells[i].dmg = function(unit) local Tard_level=myH:GetSpellData(1).level return Need:CalcMagicalDamage(myH, unit, ({90, 130, 170, 210, 250})[Tard_level] + myH.ap) end
        elseif i == 2 then self.Tard_FioraSpells[i].dmg = function(unit) local Tard_level=myH:GetSpellData(2).level return Need:CalcPhysicalDamage(myH, unit, myH.totalDamage + (({1.4, 1.55, 1.7, 1.85, 2})[Tard_level] * myH.totalDamage)) end
        end
    end
    self.Tard_PassiveDMG = function(unit, nbpassive) local nbpassive = nbpassive or 1 return ((0.02 + (0.045 * myH.bonusDamage * 0.01)) * unit.maxHealth) * nbpassive end
    self.Tard_Item = {Cutlass = 3144, Botrk = 3153, Ravenous = 3074, Tiamat = 3077}

    print("Hello ", myH.name, ", TardFiora v", Tard_version, " is ready to feed")      
    self:Tard_Menu()     
    Callback.Add("Tick", function() self:Tard_Tick() end)
    Callback.Add("Draw", function() self:Tard_Draw() end)
end

function TardFiora:Tard_Menu()
    self.TardMenu = MenuElement({type = MENU, id = "TardFioraMenu", name = "TardFiora", leftIcon=Tard_Icon.Fiora})
        --[[Combo]]
    self.TardMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    self.MenuCombo = self.TardMenu.Combo;  
    self.MenuCombo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    self.MenuCombo:MenuElement({id = "ComboW", name = "Use W", value = false})
    self.MenuCombo:MenuElement({id = "ComboE", name = "Use E", value = true})
    self.MenuCombo:MenuElement({id = "ComboR", name = "Use R if can kill with all ready spells", value = true})
    self.MenuCombo:MenuElement({id = "HealthR", name = "Your heal min to use R", value = 25, min = 0, max = 100, tooltip = "It's %"})

    self.MenuCombo:MenuElement({type = MENU, id = "Item", name = "Item"})
    self.MenuItem = self.TardMenu.Combo.Item; 
    self.MenuItem:MenuElement({id = "Botrk", name = "Blade of the Ruined King", value = true, leftIcon = Tard_Icon.Botrk})
    self.MenuItem:MenuElement({id = "Cutlass", name = "Bilgewater Cutlass", value = true, leftIcon = Tard_Icon.Cutlass})
    self.MenuItem:MenuElement({id = "Ravenous", name = "Ravenous Hydra", value = true, leftIcon = Tard_Icon.Ravenous})
    self.MenuItem:MenuElement({id = "Tiamat", name = "Tiamat", value = true, leftIcon = Tard_Icon.Tiamat})
    self.MenuItem:MenuElement({id = "MyHP", name = "Max HP to use Botrk and Cutlass", value = 60, min = 0, max = 100, tooltip = "It's %"})
    self.MenuItem:MenuElement({id = "EnemyHP", name = "Max enemy HP to use Botrk and Cutlass", value = 60, min = 0, max = 100, tooltip = "It's %"})

    self.MenuCombo:MenuElement({type = MENU, id = "ComboMana", name = "Mana Manager"})
    self.MenuComboMana = self.TardMenu.Combo.ComboMana;
    self.MenuComboMana:MenuElement({id = "ComboQMana", name = "Min. Mana to Q", value = 0, min = 0, max = 100, tooltip = "It's %"}) 
    self.MenuComboMana:MenuElement({id = "ComboWMana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})
    self.MenuComboMana:MenuElement({id = "ComboEMana", name = "Min. Mana to E", value = 10, min = 0, max = 100, tooltip = "It's %"})
    self.MenuComboMana:MenuElement({id = "ComboRMana", name = "Min. Mana to R", value = 0, min = 0, max = 100, tooltip = "It's %"})   

        --[[Harass]]
    self.TardMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    self.MenuHarass = self.TardMenu.Harass;    
    self.MenuHarass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    self.MenuHarass:MenuElement({id = "HarassW", name = "Use W", value = false})
    self.MenuHarass:MenuElement({id = "HarassE", name = "Use E", value = true})

    self.MenuHarass:MenuElement({type = MENU, id = "HarassMana", name = "Mana Manager"})
    self.MenuHarassMana = self.TardMenu.Harass.HarassMana;
    self.MenuHarassMana:MenuElement({id = "HarassQMana", name = "Min. Mana to Q", value = 40, min = 0, max = 100, tooltip = "It's %"}) 
    self.MenuHarassMana:MenuElement({id = "HarassWMana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})
    self.MenuHarassMana:MenuElement({id = "HarassEMana", name = "Min. Mana to E", value = 75, min = 0, max = 100, tooltip = "It's %"})
        
        --[[LastHit]]
    self.TardMenu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
    self.MenuLastHit = self.TardMenu.LastHit;
    self.MenuLastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
    self.MenuLastHit:MenuElement({id = "LastHitMana", name = "Min Mana To Lasthit Q with all farm mode", value = 40, min = 0, max = 100, tooltip = "It's %"})
     
        --[[Farm]]
    self.TardMenu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    self.MenuFarm = self.TardMenu.Farm; 
    self.MenuFarm:MenuElement({id = "FarmE", name = "Use E", value = true}) 
    self.MenuFarm:MenuElement({id = "FarmEMana", name = "Min. Mana to E", value = 70, min = 0, max = 100, tooltip = "It's %"})

        --[[JungleClear]]
    self.TardMenu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
    self.MenuJungle = self.TardMenu.JungleClear;
    self.MenuJungle:MenuElement({id = "JungleQ", name = "Use Q", value = true})
    self.MenuJungle:MenuElement({id = "JungleE", name = "Use E", value = true})

    self.MenuJungle:MenuElement({type = MENU, id = "JungleClearMana", name = "Mana Manager"})
    self.MenuJungleMana = self.TardMenu.JungleClear.JungleClearMana;
    self.MenuJungleMana:MenuElement({id = "JungleQMana", name = "Min Mana To Q", value = 60, min = 0, max = 100, step = 1, tooltip = "It's %"})  
    self.MenuJungleMana:MenuElement({id = "JungleEMana", name = "Min Mana To E", value = 60, min = 0, max = 100, step = 1, tooltip = "It's %"})  

    --[[KS]]
    self.TardMenu:MenuElement({type = MENU, id = "KS", name = "KillSteal Settings"})
    self.MenuKS = self.TardMenu.KS;
    self.MenuKS:MenuElement({id = "Q_KS", name = "Use Q to try to KillSteal", value = true})
    self.MenuKS:MenuElement({id = "W_KS", name = "Use W to try to KillSteal", value = true})

    --[[Misc]]
    self.TardMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    self.MenuMisc = self.TardMenu.Misc
    self.MenuMisc:MenuElement({id = "SelectedTarget", name = "Focus Spell target", value = true, tooltip = "Focus Spell on selected target"}) 
    
        --[[Pred]]
    if self.Tard_EternalPred then
        self.TardMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
        self.MenuPred = self.TardMenu.Pred
        self.MenuPred:MenuElement({id = "PredHitChance", name = "HitChance (default 25)", value = 25, min = 0, max = 100,  tooltip = "higher value better pred but slower(%)||don't change it if don't know what is it||"})
    end

        --[[Draw]]
    self.TardMenu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    self.MenuDraw = self.TardMenu.Draw
    self.MenuDraw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    self.MenuDraw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    self.MenuDraw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    self.MenuDraw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    self.MenuDraw:MenuElement({id = "DrawR", name = "Draw R Range", value = true})
    self.MenuDraw:MenuElement({id = "DisableDraw", name = "Disable all Draws [?]", value = false})
end

function TardFiora:Tard_Tick()
    if myH.dead then return end
    self:Tard_Mode()
    self:Tard_KillSteal()
end

function TardFiora:Tard_Draw()
    if myH.dead or self.MenuDraw.DisableDraw:Value() then return end
    local Tard_DrawCircle = Draw.Circle; local Tard_DrawColor = Draw.Color; local Tard_Spell = Game.CanUseSpell
   
    if self.MenuDraw.DrawQ:Value() and (Tard_Spell(_Q) == 0 or not self.MenuDraw.DrawReady:Value()) then
            Tard_DrawCircle(myH.pos, 800, 1, Tard_DrawColor(255, 96, 203, 67))
    end
    if self.MenuDraw.DrawW:Value() and (Tard_Spell(_W) == 0 or not self.MenuDraw.DrawReady:Value()) then
            Tard_DrawCircle(myH.pos, 750, 1, Tard_DrawColor(255, 255, 255, 10))
    end
    if self.MenuDraw.DrawE:Value() and (Tard_Spell(_E) == 0 or not self.MenuDraw.DrawReady:Value()) then
           Tard_DrawCircle(myH.pos, 305, 1, Tard_DrawColor(255, 22, 255, 255))
    end
    if self.MenuDraw.DrawR:Value() and (Tard_Spell(_R) == 0 or not self.MenuDraw.DrawReady:Value()) then
           Tard_DrawCircle(myH.pos, 500, 1, Tard_DrawColor(255, 255, 28, 255))
    end
end

function TardFiora:Tard_Combo()
    local Tard_target = Need:Tard_GetTarget(1200)
    if Tard_target == nil or not Need:Tard_IsValidTarget(Tard_target) then return end
    local TardAAState = myH.attackData.state
    local TardAARange = (myH.range + myH.boundingRadius + Tard_target.boundingRadius)^2

    if self.MenuCombo.ComboR:Value() and self.MenuComboMana.ComboRMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(3) == 0 and self.MenuCombo.HealthR:Value() >= Need:Tard_PercentHP(myH) then
        if Need:Tard_GetDistanceSqr(Tard_target.pos) <= 500*500 then
            local ComboDamage = self:Tard_ComboDamage(Tard_target)
            if ComboDamage and ComboDamage >= Tard_target.health then
                Control.CastSpell(HK_R,Tard_target)
            end
        end
    end
    if self.MenuCombo.ComboE:Value() and self.MenuComboMana.ComboEMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(2) == 0 then
        if TardAAState == 3 then
            if Need:Tard_GetDistanceSqr(Tard_target.pos) <= TardAARange + 25*25 then
                --_G.SDK.Orbwalker:OnPreAttack(function() Control.CastSpell(HK_E) end)	
                Control.CastSpell(HK_E)                
            end
        end
    end
    if self.MenuCombo.ComboQ:Value() and self.MenuComboMana.ComboQMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(0) == 0 then
        if Need:Tard_GetDistanceSqr(Tard_target.pos) <= 160000 then 
            if Need:Tard_GetDistanceSqr(Tard_target.pos) > TardAARange and TardAAState ~= 2 then
                self:Tard_CastQ(Tard_target)
            elseif TardAAState == 3 then
                self:Tard_CastQ(Tard_target)
            end
        end
    end    
    if self.MenuCombo.ComboW:Value() and self.MenuComboMana.ComboWMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(1) == 0 then
        if TardAAState ~= 2 then
            if Need:Tard_GetDistanceSqr(Tard_target.pos) <= 562500 then
                if Need:Tard_GetDistanceSqr(Tard_target.pos) > TardAARange then
                    self:Tard_CastW(Tard_target)
                end
            end
        end
    end
    if self.MenuItem.Cutlass:Value() and Need:Tard_PercentHP(myH) <= self.MenuItem.MyHP:Value() and Need:Tard_PercentHP(Tard_target) <= self.MenuItem.EnemyHP:Value() then
        Need:Tard_UseItem(self.Tard_Item.Cutlass, 550, Tard_target.pos, 1)
    end
    if self.MenuItem.Botrk:Value() and Need:Tard_PercentHP(myH) <= self.MenuItem.MyHP:Value() and Need:Tard_PercentHP(Tard_target) <= self.MenuItem.EnemyHP:Value() then
        Need:Tard_UseItem(self.Tard_Item.Botrk, 550, Tard_target.pos, 1)
    end
    if self.MenuItem.Tiamat:Value() then
        if TardAAState == 3 then
            Need:Tard_UseItem(self.Tard_Item.Tiamat, 400, Tard_target.pos)
        end
    end
    if self.MenuItem.Ravenous:Value() then 
            print(TardAAState)   
        if TardAAState == 3 then
            Need:Tard_UseItem(self.Tard_Item.Ravenous, 400, Tard_target.pos)   
        end
    end
end

function TardFiora:Tard_Harass()
    local Tard_target = Need:Tard_GetTarget(1200)
    if Tard_target == nil or not Need:Tard_IsValidTarget(Tard_target) then return end
    local TardAAState = myH.attackData.state
    local TardAARange = (myH.range + myH.boundingRadius + Tard_target.boundingRadius)^2

    if self.MenuHarass.HarassE:Value() and self.MenuHarassMana.HarassEMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(2) == 0 then
        if TardAAState == 3 then
            if Need:Tard_GetDistanceSqr(Tard_target.pos) <= TardAARange + 25*25 then
                Control.CastSpell(HK_E)                
            end
        end
    end
    if self.MenuHarass.HarassQ:Value() and self.MenuHarassMana.HarassQMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(0) == 0 then
        if Need:Tard_GetDistanceSqr(Tard_target.pos) <= 160000 then 
            if Need:Tard_GetDistanceSqr(Tard_target.pos) > TardAARange and TardAAState ~= 2 then
                self:Tard_CastQ(Tard_target)
            elseif TardAAState == 3 then
                self:Tard_CastQ(Tard_target)
            end             
        end
    end    
    if self.MenuHarass.HarassW:Value() and self.MenuHarassMana.HarassWMana:Value() <= Need:Tard_PercentMP(myH) and Game.CanUseSpell(1) == 0 then
        if TardAAState ~= 2 then
            if Need:Tard_GetDistanceSqr(Tard_target.pos) <= 562500 then
                if Need:Tard_GetDistanceSqr(Tard_target.pos) > TardAARange then
                    self:Tard_CastW(Tard_target)
                end
            end
        end
    end    
end

function TardFiora:Tard_LastHit()    
    if not self.MenuLastHit.LastHitQ:Value() or Need:Tard_PercentMP(myH) < self.MenuLastHit.LastHitMana:Value() or Game.CanUseSpell(0) ~= 0 then return end
    for i = 1, Game.MinionCount() do
        local Tard_Minion = Game.Minion(i)
        local TardAArange = (myH.range + myH.boundingRadius + Tard_Minion.boundingRadius)^2
        if Tard_Minion.team ~= 300 and Need:Tard_IsValidTarget(Tard_Minion, 800) and self.Tard_FioraSpells[0].dmg(Tard_Minion) >= Tard_Minion.health then
            if myH.attackData.state ~= 2 and Need:Tard_HasBuff(Tard_Minion, "turretshield") then
                self:Tard_CastQ(Tard_Minion)
                break 
            end    
            if myH.attackData.target ~= Tard_Minion.handle then
                if (Need:Tard_GetDistanceSqr(Tard_Minion.pos) > TardAArange and myH.attackData.state ~= 2) then --or (myH.attackData.state == 3 and Need:Tard_HP_PRED(Tard_Minion, myH.attackData.endTime - Game.Timer()) < 1) then
                    self:Tard_CastQ(Tard_Minion)
                    break
                end
            end
        end    
    end
end

function TardFiora:Tard_Farm()
    if not self.MenuFarm.FarmE:Value() or Need:Tard_PercentMP(myH) < self.MenuFarm.FarmEMana:Value() or Game.CanUseSpell(2) ~= 0 then return end
    for i = 1, Game.MinionCount() do
        local Tard_Minion = Game.Minion(i)
        if Tard_Minion.team ~= (300 and myH.team) then
            if myH.attackData.target == Tard_Minion.handle and Need:Tard_IsValidTarget(Tard_Minion, 150 + myH.boundingRadius + Tard_Minion.boundingRadius) and self.Tard_FioraSpells[2].dmg(Tard_Minion) >= Tard_Minion.health then
               --if myH.attackData.state ~= 2 and Tard_Minion.health > myH.totalDamage then Control.CastSpell(HK_E) break end
               if myH.attackData.state ~= 2 then Control.CastSpell(HK_E) break end
            end
        end
	end
end

function TardFiora:Tard_JungleClear()  
    for i = 1, Game.MinionCount() do
        local Tard_Minion = Game.Minion(i)
        if Tard_Minion.team == 300 then        
            if self.MenuJungle.JungleQ:Value() and Need:Tard_PercentMP(myH) >= self.MenuJungleMana.JungleQMana:Value() and Game.CanUseSpell(0) == 0 then
                if myH.attackData.state ~= 2 and Need:Tard_IsValidTarget(Tard_Minion, 800) then
                    local mDistance = Need:Tard_GetDistanceSqr(Tard_Minion.pos)
                    if mDistance >= 400*400 then
                        if self.Tard_FioraSpells[0].dmg(Tard_Minion) >= Tard_Minion.health then self:Tard_CastQ(Tard_Minion) end
                    elseif mDistance > myH.range + myH.boundingRadius + Tard_Minion.boundingRadius then  
                        self:Tard_CastQ(Tard_Minion)
                    elseif myH.attackData.state == 3 and self.Tard_FioraSpells[0].dmg(Tard_Minion) >= Tard_Minion.health then
                        self:Tard_CastQ(Tard_Minion)
                    end
                end    
            end
            if self.MenuJungle.JungleE:Value() and Need:Tard_PercentMP(myH) >= self.MenuJungleMana.JungleEMana:Value() and Game.CanUseSpell(2) == 0 then
                if myH.attackData.target == Tard_Minion.handle and Need:Tard_IsValidTarget(Tard_Minion, 150 + myH.boundingRadius + Tard_Minion.boundingRadius) then
                    if myH.attackData.state ~= 2 then Control.CastSpell(HK_E) break end
                end
            end
        end
    end           
end

function TardFiora:Tard_KillSteal()
    for i =1, Game.HeroCount() do
        local Tard_Hero = Game.Hero(i)
        if Need:Tard_IsValidTarget(Tard_Hero, 800*800) then
            local Tard_Q_DMG; local Tard_W_DMG;
            if self.MenuKS.Q_KS:Value() and Game.CanUseSpell(0) == 0 then Tard_Q_DMG = self.Tard_FioraSpells[0].dmg(Tard_Hero) end
            if self.MenuKS.W_KS:Value() and Game.CanUseSpell(1) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) < 750*750 then Tard_W_DMG = self.Tard_FioraSpells[1].dmg(Tard_Hero) end

			if Tard_W_DMG and Tard_W_DMG > Tard_Hero.health then
                print("KS W")
                print(Tard_W_DMG)
                self:Tard_CastW(Tard_Hero)
                break
            end
            if Tard_Q_DMG and Tard_Q_DMG >= Tard_Hero.health then
                print("KS Q")
                print(Tard_Q_DMG)
                self:Tard_CastQkill(Tard_Hero)
                break
            end
        end
    end      
end

function TardFiora:Tard_CastQ(unit)
    if Need:Tard_IsValidTarget(unit) then
        if unit.type == Obj_AI_Hero then
            local Tard_PassiveLoc = self:Tard_PassiveManager(unit, 0)
            if Tard_PassiveLoc then Need:Tard_CastSpell(HK_Q, Tard_PassiveLoc) end
        elseif unit.type == Obj_AI_Minion then
            Need:Tard_CastSpell(HK_Q, unit.pos)
        end
    end
end

function TardFiora:Tard_CastQkill(unit)
    if self.Tard_EternalPred == true then
        local QspellData = {speed = 500, delay = 0.25, range = 800, width = 65}
        local qSpell = Prediction:SetSpell(QspellData, TYPE_LINE, false)
        local Tard_QPred = qSpell:GetPrediction(unit, myH.pos)
        if Tard_QPred and Tard_QPred.hitChance >= 0.25 and not unit.dead then
            Need:Tard_CastSpell(HK_Q, Tard_QPred.castPos)
        end
    end
end

--[[
function TardFiora:Tard_CastW(unit)
    local Tard_CastWCastPos = self:Tard_Prediction(unit, 1, 750, 0)
    if Need:Tard_IsValidTarget(unit) then
        Control.CastSpell(HK_W, Tard_CastWCastPos)
    end
end
]]

function TardFiora:Tard_CastW(unit)
    if self.Tard_EternalPred == true then
        local Tard_WPred = self.Tard_SpellstoPred[1]:GetPrediction(unit, myH.pos)   
        if Tard_WPred and Tard_WPred.hitChance >= 0 and Tard_WPred:hCollision() == 0 and Need:Tard_GetDistanceSqr(Tard_WPred.castPos) < 750*750 then
        
            if Need:Tard_IsValidTarget(unit) then
                Need:Tard_CastSpell(HK_W, Tard_WPred.castPos) 
            end 
        end
    end 
end

function TardFiora:Tard_Mode()
    local Tard_Mode = Need:Tard_GetMode()
    if Tard_Mode == "Combo" then self:Tard_Combo();
    elseif Tard_Mode == "Harass" then self:Tard_Harass()
    elseif Tard_Mode == "Lasthit" then self:Tard_LastHit()
    elseif Tard_Mode == "Clear" then self:Tard_LastHit(); self:Tard_Farm(); self:Tard_JungleClear()
    end    
end

function TardFiora:Tard_PassiveManager(unit, spell)
    local PassiveLoc
    for i = 0, unit.buffCount do
        local Tard_Buff = unit:GetBuff(i)
        if Tard_Buff and (Tard_Buff.name == "fiorapassivemanager" or "fioramark") and (Tard_Buff.duration >= 0.25 and Tard_Buff.duration < 13.1571) then  -- --and Game.Timer() - Tard_Buff.startTime <= 0.5) then
            for i = 0, Game.ParticleCount() do
                local Tard_Particle = Game.Particle(i)
                if Tard_Particle and not Tard_Particle.dead and Tard_Particle.name:find("Fiora_B") then
                    local unitPosPred = self:Tard_Prediction(unit, spell)
                    --local unitPosPred = unit:GetPrediction(500, 0.25)
                    if Tard_Particle.name:find("NE") then
                            PassiveLoc = Vector(unitPosPred.x,unit.pos.y, unitPosPred.z+150)
                            break                      
                    elseif Tard_Particle.name:find("NW") then
                            PassiveLoc = Vector(unitPosPred.x+150,unit.pos.y, unitPosPred.z)
                            break
                    elseif Tard_Particle.name:find("SW") then
                            PassiveLoc = Vector(unitPosPred.x,unit.pos.y, unitPosPred.z-150)
                            break
                    elseif Tard_Particle.name:find("SE") then
                            PassiveLoc = Vector(unitPosPred.x-150,unit.pos.y, unitPosPred.z)
                            break
                    end
                end
            end
            break
        end
    end
   return PassiveLoc
end

function TardFiora:Tard_Prediction(unit, spell, range, nbHcollision, nbMcollision)     
	if self.Tard_EternalPred == true then       
		local range = range or math.huge
		local nbHcollision = nbHcollision or nil
		local nbMcollision = nbMcollision or nil
		local Tard_SpellPred = self.Tard_SpellstoPred[spell]:GetPrediction(unit, myH.pos)
		if Tard_SpellPred and Tard_SpellPred.hitChance >= self.MenuPred.PredHitChance:Value()/100 and Need:Tard_GetDistanceSqr(Tard_SpellPred.castPos) <= range*range then
			if nbHcollision and nbMcollision then
				if Tard_SpellPred:mCollision() == nbMcollision and Tard_SpellPred:hCollision() == nbHcollision then
					return Tard_SpellPred.castPos
				end
            elseif nbHcollision and not nbMcollision then
                if Tard_SpellPred:hCollision() == nbHcollision then
					return Tard_SpellPred.castPos
				end
            elseif not nbHcollision and nbMcollision then
                if Tard_SpellPred:mCollision() == nbMcollision then
					return Tard_SpellPred.castPos
				end
			elseif not nbHcollision and not nbMcollision then
				return Tard_SpellPred.castPos
			end
		end
	end
end

function TardFiora:Tard_ComboDamage(unit)
    if unit == nil then return false end
    local TotalDamage = 0
    if Game.CanUseSpell(0) == 0 then TotalDamage = TotalDamage + self.Tard_FioraSpells[0].dmg(unit) end
    if Game.CanUseSpell(1) == 0 then TotalDamage = TotalDamage + self.Tard_FioraSpells[1].dmg(unit) end
    if Game.CanUseSpell(2) == 0 then TotalDamage = TotalDamage + self.Tard_FioraSpells[2].dmg(unit) end
    if Game.CanUseSpell(3) == 0 then TotalDamage = TotalDamage + self.Tard_PassiveDMG(unit, 4) end
    return TotalDamage
end

--------------------------------------------------------------------------------------------------------------------------------------
Callback.Add("Load", function() 
	if _G["TardFiora"] and myHero.charName == "Fiora" then
        require 'Eternal Prediction'
        if not _G.Prediction_Loaded then 
            print("Warning : Eternal Prediction is missing and required, you need to install it, Fiora script closing...")
            return
        else
            _G.Need = Need()
		    _G["TardFiora"]() 
            --_G["Need"]()
        end       		       
	end
end)