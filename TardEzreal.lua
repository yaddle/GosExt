--Datas----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tard_Orb; local Tard_SDK; local Tard_SDKCombo; local Tard_SDKHarass; local Tard_SDKJungleClear; local Tard_SDKLaneClear; local Tard_SDKLastHit; local Tard_SDKFlee; local Tard_SDKSelector; local Tard_SDKHealthPrediction; local Tard_SDKDamagePhysical; local Tard_SDKDamageMagical; local Tard_CurrentTarget; local Tard_SpellstoPred;local Tard_Mode;local Tard_TardMenu;local Tard_EternalPred;local Tard_myHero;local Tard_SelectedTarget;local Tard_Item;local Tard_ItemHotKey;local DamageReductionTable;local Tard_SpellstoCollision; 
local Tard_version = 1.1
local Tard_Icon = {
    ["Ezreal"] = "https://vignette4.wikia.nocookie.net/leagueoflegends/images/c/c3/EzrealSquare.png",
    ["Botrk"] = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/2/2f/Blade_of_the_Ruined_King_item.png",
    ["Cutlass"] = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/4/44/Bilgewater_Cutlass_item.png"
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class "Need"
function Need:Tard_GetDistanceSqr(Pos1, Pos2)
	local Pos2 = Pos2 or Tard_myHero.pos
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
		if Tard_SDK.Modes[Tard_SDKCombo] then				
			return "Combo"
		elseif Tard_SDK.Modes[Tard_SDKHarass] then
			return "Harass"	
		elseif Tard_SDK.Modes[Tard_SDKLaneClear] or Tard_SDK.Modes[Tard_SDKJungle] then
			return "Clear"
		elseif Tard_SDK.Modes[Tard_SDKLastHit] then
			return "Lasthit"
		elseif Tard_SDK.Modes[Tard_SDKFlee] then
			return "Flee"
		end
	else 
		return GOS.GetMode()
	end
end

function Need:Tard_GetTarget(range)
	local Tard_target 
	if Tard_Orb == 0 then
        if Tard_myHero.totalDamage >= Tard_myHero.ap then Tard_target = EOW:GetTarget(range, ad_dec)
        else Tard_target = EOW:GetTarget(range, ap_dec)
        end
	elseif Tard_Orb == 1 then
        if Tard_myHero.totalDamage >= Tard_myHero.ap then Tard_target = Tard_SDKSelector:GetTarget(range, Tard_SDKDamagePhysical)			
        else Tard_target = Tard_SDKSelector:GetTarget(range, Tard_SDKDamageMagical)			
        end
	else
		Tard_target = GOS:GetTarget(range)
	end
	return Tard_target
end

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
function Need:Tard_CastSpell(spell, pos, delay)

    local delay = delay or 250
	if pos == nil then return end
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker - castSpell.casting > delay + Game.Latency() then -- and pos:ToScreen().onScreen then
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
    if Tard_Orb == 0 then
        return EOW:GetHealthPrediction(unit,time)
    elseif Tard_Orb == 1 then
        return Tard_SDKHealthPrediction:GetPrediction(unit, time)
    else
        return GOS:HP_Pred(unit,time)
    end
end

function Need:Tard_GetEnemynearMouse()
    for i = 1, Game.HeroCount() do
        local Tard_H = Game.Hero(i)
        if Need:Tard_IsValidTarget(Tard_H) and Need:Tard_GetDistanceSqr(_G.mousePos, Tard_H.pos) <= 100 * 100 then
            return Tard_H        
        end
        break
    end
end

function Need:Tard_OnWndMsg(msg, wParam)
    if msg == WM_LBUTTONDOWN then
        if Tard_TardMenu.Misc.SelectedTarget:Value() then
            --local Tard_hero = Need:Tard_GetEnemynearMouse()
            for i = 1, Game.HeroCount() do
                local H = Game.Hero(i)
                if self:Tard_GetDistanceSqr(H.pos, _G.mousePos) <= 100*100 then
                    if (H ~= nil and Tard_SelectedTarget ~= nil) and Tard_SelectedTarget.networkID == H.networkID then
                        Tard_SelectedTarget = nil;
                    else
                        Tard_SelectedTarget = H
                    end
                    break;
                end
            end
        end
    end
    --if msg == KEY_DOWN and wParam == 0x54 then 
    --    Need:Tard_CastR(self.Tard_SelectedTarget)
    --end
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

------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
class "TardEzreal"
function TardEzreal:__init()     
    Tard_TardMenu = MenuElement({type = MENU, id = "TardEzrealMenu", name = "TardEzreal", leftIcon=Tard_Icon.Ezreal})
    Tard_EternalPred = false
    Tard_myHero = myHero
    Tard_SelectedTarget = nil
    Tard_Item = {Cutlass = 3144, Botrk = 3153}
    Tard_ItemHotKey = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3,[ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6, [ITEM_7] = HK_ITEM_7}
    Tard_EzrealSpells = { 
        [0] = {range = 1200, delay = 0.25, speed = 2000, width = 60, spellType = TYPE_LINE, hitBox = true},	
        [1] = {range = 1050, delay = 0.54, speed = 1600, width = 80, spellType = TYPE_LINE, hitBox = false},
        [2] = {range = 475},
        [3] = {range = 20000, delay = 1.76, speed = 2000, width = 160, spellType = TYPE_LINE, hitBox = false}
    }
    DamageReductionTable = {
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

    if _G.Prediction_Loaded then Tard_EternalPred = true; print("Tosh Pred loaded ;)");
        Tard_SpellstoPred = {
        [0] = Prediction:SetSpell(Tard_EzrealSpells[0], Tard_EzrealSpells[0].spellType, Tard_EzrealSpells[0].hitBox),
        [1] = Prediction:SetSpell(Tard_EzrealSpells[1], Tard_EzrealSpells[1].spellType, Tard_EzrealSpells[1].hitBox),
        [3] = Prediction:SetSpell(Tard_EzrealSpells[3], Tard_EzrealSpells[3].spellType, Tard_EzrealSpells[3].hitBox)
        }
    --[[else 
        require("Collision")
        print("collision loaded")
        Tard_SpellstoCollision = {
            [0] = Collision:SetSpell(Tard_EzrealSpells[0].range, Tard_EzrealSpells[0].speed, Tard_EzrealSpells[0].delay, Tard_EzrealSpells[0].width, Tard_EzrealSpells[0].hitBox),
            [3] = Collision:SetSpell(Tard_EzrealSpells[3].range, Tard_EzrealSpells[3].speed, Tard_EzrealSpells[0].delay, Tard_EzrealSpells[3].width, Tard_EzrealSpells[3].hitBox)   
        }--]]
    end  
    if _G.EOWLoaded then 
        Tard_Orb = 0; print("New Eternal Orb is good but Tosh is still toxic ^^")  
    elseif _G.SDK and _G.SDK.Orbwalker then 
        Tard_Orb = 1; print("IC is a good Orb")		
        Tard_SDK = _G.SDK.Orbwalker		
        Tard_SDKCombo = _G.SDK.ORBWALKER_MODE_COMBO      	
        Tard_SDKHarass = _G.SDK.ORBWALKER_MODE_HARASS
        Tard_SDKJungleClear = _G.SDK.ORBWALKER_MODE_JUNGLECLEAR
        Tard_SDKLaneClear = _G.SDK.ORBWALKER_MODE_LANECLEAR
        Tard_SDKLastHit = _G.SDK.ORBWALKER_MODE_LASTHIT
        Tard_SDKFlee = _G.SDK.ORBWALKER_MODE_FLEE
        Tard_SDKSelector = _G.SDK.TargetSelector
        Tard_SDKHealthPrediction = _G.SDK.HealthPrediction
        Tard_SDKDamagePhysical = _G.SDK.DAMAGE_TYPE_PHYSICAL
        Tard_SDKDamageMagical = _G.SDK.DAMAGE_TYPE_MAGICAL
    else 
        print("Noddy rocks") 
    end	
    for i = 0, 3 do
        if i == 0 then Tard_EzrealSpells[i].dmg = function(unit) local Tard_level=Tard_myHero:GetSpellData(0).level return Need:CalcPhysicalDamage(Tard_myHero, unit, ({35, 55, 75, 95, 115})[Tard_level] + 1.1 * Tard_myHero.totalDamage + 0.4 * Tard_myHero.ap) end
        elseif i == 1 then Tard_EzrealSpells[i].dmg = function(unit) local Tard_level=Tard_myHero:GetSpellData(1).level return Need:CalcMagicalDamage(Tard_myHero, unit, ({70, 115, 160, 205, 250})[Tard_level] + 0.8 * Tard_myHero.ap) end
        elseif i == 3 then
            Tard_EzrealSpells[i].dmg = function(unit)
            local Tard_level = Tard_myHero:GetSpellData(i).level
            local Tard_initialdmg = ({350, 500, 650})[Tard_level] + 0.9 * Tard_myHero.ap + Tard_myHero.bonusDamage
            local Tard_Collision
            if Tard_EternalPred == true then
                local pred = Tard_SpellstoPred[i]:GetPrediction(unit, Tard_myHero.pos)
                Tard_Collision = pred:mCollision() + pred:hCollision()
            --[[   else
                local Tard_RblockUnit 
                Tard_Collision, Tard_RblockUnit = Tard_SpellstoCollision[i]:__GetCollision(Tard_myHero, unit, 5)
                Tard_Collision = #Tard_RblockUnit ]]
            end
            local Tard_nerf = math.min(Tard_Collision,7)
            local Tard_finaldmg = Tard_initialdmg * ((10 - Tard_nerf) / 10)
            return Need:CalcMagicalDamage(Tard_myHero, unit, Tard_finaldmg)
            end
        end
    end       
    print("Hello ", myHero.name, ", TardEzreal v", Tard_version, " is ready to feed")      
    self:Tard_Menu()     
    Callback.Add("Tick", function() self:Tard_Tick() end)
    Callback.Add("Draw", function() self:Tard_Draw() end)
    Callback.Add('WndMsg', function(msg, wParam) Need:Tard_OnWndMsg(msg, wParam) end)   
end

function TardEzreal:Tard_Menu()
        --[[Combo]]
    Tard_TardMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
    Tard_TardMenu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
    Tard_TardMenu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
    Tard_TardMenu.Combo:MenuElement({id = "ComboQmana", name = "Min. Mana to Q", value = 0, min = 0, max = 100, tooltip = "It's %"}) 
    Tard_TardMenu.Combo:MenuElement({id = "ComboWmana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})  
    Tard_TardMenu.Combo:MenuElement({type = MENU, id = "Item", name = "Item"})
    Tard_TardMenu.Combo.Item:MenuElement({id = "Botrk", name = "Blade of the Ruined King", value = true, leftIcon = Tard_Icon.Botrk})
    Tard_TardMenu.Combo.Item:MenuElement({id = "Cutlass", name = "Bilgewater Cutlass", value = true, leftIcon = Tard_Icon.Cutlass})
    Tard_TardMenu.Combo.Item:MenuElement({id = "MyHP", name = "Max HP to use items", value = 60, min = 0, max = 100, tooltip = "It's %"})
    Tard_TardMenu.Combo.Item:MenuElement({id = "EnemyHP", name = "Max enemy HP to use items", value = 60, min = 0, max = 100, tooltip = "It's %"})

        --[[Harass]]
    Tard_TardMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
    Tard_TardMenu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
    Tard_TardMenu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
    Tard_TardMenu.Harass:MenuElement({id = "HarassQMana", name = "Min. Mana to Q", value = 40, min = 0, max = 100, tooltip = "It's %"})
    Tard_TardMenu.Harass:MenuElement({id = "HarassWMana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})
        
        --[[Farm]]
    Tard_TardMenu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
    Tard_TardMenu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})  
    Tard_TardMenu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 70, min = 0, max = 100, tooltip = "It's %"})

        --[[LastHit]]
    Tard_TardMenu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
    Tard_TardMenu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
    Tard_TardMenu.LastHit:MenuElement({id = "LastHitMana", name = "Min Mana To Lasthit", value = 40, min = 0, max = 100, tooltip = "It's %"})

        --[[JungleClear]]
    Tard_TardMenu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
    Tard_TardMenu.JungleClear:MenuElement({id = "JungleQ", name = "Use Q", value = true})
    Tard_TardMenu.JungleClear:MenuElement({id = "JungleMana", name = "Min Mana To JungleClear", value = 60, min = 0, max = 100, step = 1, tooltip = "It's %"})  
    
    --[[KS]]
    Tard_TardMenu:MenuElement({type = MENU, id = "KS", name = "KillSteal Settings"})
    Tard_TardMenu.KS:MenuElement({id = "Q_KS", name = "Use Q to try to KillSteal", value = true})
    Tard_TardMenu.KS:MenuElement({id = "W_KS", name = "Use W to try to KillSteal", value = true})
    Tard_TardMenu.KS:MenuElement({id = "R_KS", name = "Use R to try to KillSteal", value = true})
    Tard_TardMenu.KS:MenuElement({id = "R_Ksrange", name = "R Max Range", value = 7000, min = 300, max = 20000, step = 100, tooltip = "It's %"})

    --[[Misc]]
    Tard_TardMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
    Tard_TardMenu.Misc:MenuElement({id = "Rkey", name = "Ulti Champ targeted on key", key = string.byte("T"), tooltip = "the target need to be targeted by spell focus first, mouse clic on it, a blue circle should be on the target"}) 
    Tard_TardMenu.Misc:MenuElement({id = "KeepRmana", name = "Keep mana for R", value = false, tooltip = "KillSteal never keep mana"})  
    Tard_TardMenu.Misc:MenuElement({id = "SelectedTarget", name = "Focus Spell target", value = true, tooltip = "Focus Spell on selected target"}) 
    
        --[[Pred]]
    if Tard_EternalPred then
        Tard_TardMenu:MenuElement({type = MENU, id = "Pred", name = "Prediction Settings"})
        Tard_TardMenu.Pred:MenuElement({id = "PredHitChance", name = "HitChance (default 25)", value = 25, min = 0, max = 100,  tooltip = "higher value better pred but slower(%)||don't change it if don't know what is it||"})
    end

        --[[Draw]]
    Tard_TardMenu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
    Tard_TardMenu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
    Tard_TardMenu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
    Tard_TardMenu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
    Tard_TardMenu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
    --Tard_TardMenu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target [?]", value = true, tooltip = "Draws current target"})
    Tard_TardMenu.Draw:MenuElement({id = "DrawSpellTarget", name = "Draw Spell Target Focus [?]", value = true, tooltip = "Draws spell target focus"})
    Tard_TardMenu.Draw:MenuElement({id = "DisableDraw", name = "Disable all Draws [?]", value = false})
end

function TardEzreal:Tard_Tick()
	if Tard_myHero.dead then return end
    Tard_Mode = Need:Tard_GetMode()
    if (Tard_TardMenu.Misc.KeepRmana:Value() and Game.CanUseSpell(3) == 0 and Tard_myHero.mana >= 140) or (Game.CanUseSpell(3) ~= 0 or not Tard_TardMenu.Misc.KeepRmana:Value()) then
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
    end    
    self:Tard_KillSteal()
    self:Tard_RonKey()
end

function TardEzreal:Tard_Combo()
    local Tard_target
    if Tard_SelectedTarget ~= nil and (Tard_SelectedTarget.dead or Need:Tard_GetDistanceSqr(Tard_SelectedTarget.pos) > 2500*2500) then Tard_SelectedTarget = nil end
    if Tard_SelectedTarget == nil or not Need:Tard_IsValidTarget(Tard_SelectedTarget, 1200) then
        Tard_target = Need:Tard_GetTarget(1200)        
    else
        Tard_target = Tard_SelectedTarget
    end
    if Tard_target == nil or Tard_myHero.attackData.state == 2  then return end  
	--CAST Q SPELL
	if Tard_TardMenu.Combo.ComboQ:Value() and Need:Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Combo.ComboQmana:Value() and Game.CanUseSpell(_Q) == 0 and Need:Tard_IsValidTarget(Tard_target, 1200) then
        self:Tard_CastQ(Tard_target)
        Tard_CurrentTarget = Tard_target
	--CAST W SPELL
	elseif Tard_TardMenu.Combo.ComboW:Value() and Need:Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Combo.ComboWmana:Value() and Game.CanUseSpell(_W) == 0 and Need:Tard_IsValidTarget(Tard_target, 1050) then
		self:Tard_CastW(Tard_target)
        Tard_CurrentTarget = Tard_target
	end
 
    if Tard_TardMenu.Combo.Item.Botrk:Value() then
        local botrk = Need:GetItemSlot(Tard_myHero, Tard_Item.Botrk)
        if botrk >= 1 and Tard_myHero:GetSpellData(botrk).currentCd == 0 and Need:Tard_GetDistanceSqr(Tard_target.pos) <= 550*550 + (25*25) and Need:Tard_PercentHP(Tard_myHero) <= Tard_TardMenu.Combo.Item.MyHP:Value() and Need:Tard_PercentHP(Tard_target) <= Tard_TardMenu.Combo.Item.EnemyHP:Value() then
            Need:Tard_CastSpell(Tard_ItemHotKey[botrk], Tard_target.pos, 50)      
        end   
    elseif Tard_TardMenu.Combo.Item.Cutlass:Value() then
        local cutlass = Need:GetItemSlot(Tard_myHero, Tard_Item.Cutlass)
        if cutlass >= 1 and Tard_myHero:GetSpellData(cutlass).currentCd == 0 and Need:Tard_GetDistanceSqr(Tard_target.pos) <= 550*550 + (25*25) and Need:Tard_PercentHP(Tard_myHero) <= Tard_TardMenu.Combo.Item.MyHP:Value() and Need:Tard_PercentHP(Tard_target) <= Tard_TardMenu.Combo.Item.EnemyHP:Value() then
            Need:Tard_CastSpell(Tard_ItemHotKey[cutlass], Tard_target.pos, 50)      
        end    
    end
end

function TardEzreal:Tard_Harass()
	local Tard_target
    if Tard_SelectedTarget ~= nil and (Tard_SelectedTarget.dead or Need:Tard_GetDistanceSqr(Tard_SelectedTarget.pos) > 2500*2500) then Tard_SelectedTarget = nil end
    if Tard_SelectedTarget == nil or not Need:Tard_IsValidTarget(Tard_SelectedTarget, 1200) then
        Tard_target = Need:Tard_GetTarget(1200)        
    else
        Tard_target = Tard_SelectedTarget
    end
    if Tard_target == nil or Tard_myHero.attackData.state == 2  then return end 
	--CAST Q SPELL
	if Tard_TardMenu.Harass.HarassQ:Value() and Need:Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Harass.HarassQMana:Value() and Game.CanUseSpell(_Q) == 0 and Need:Tard_IsValidTarget(Tard_target, 1200) then
		if Tard_myHero.activeSpell.valid ~= true then
            self:Tard_CastQ(Tard_target)
            Tard_CurrentTarget = Tard_target
        end
    end
	--CAST W SPELL
	if Tard_TardMenu.Harass.HarassW:Value() and Need:Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Harass.HarassWMana:Value() and Game.CanUseSpell(_W) == 0 and Need:Tard_IsValidTarget(Tard_target, 1050) then
		if Tard_myHero.activeSpell.valid ~= true then
            self:Tard_CastW(Tard_target)
            Tard_CurrentTarget = Tard_target
        end
	end
end

function TardEzreal:Tard_Farm()
	if not Tard_TardMenu.Farm.FarmQ:Value() or Need:Tard_PercentMP(Tard_myHero) < Tard_TardMenu.Farm.FarmMana:Value() or Tard_myHero.attackData.state == 2 or Game.CanUseSpell(0) ~= 0 then return end
	for i = 1, Game.MinionCount() do
		local Tard_Minion = Game.Minion(i)
		if Need:Tard_IsValidTarget(Tard_Minion, Tard_EzrealSpells[0].range) and Tard_Minion.team ~= 300 then
			self:Tard_CastQ(Tard_Minion)
			break
		end
	end
end

function TardEzreal:Tard_JungleClear()
	if not Tard_TardMenu.JungleClear.JungleQ:Value() or Need:Tard_PercentMP(Tard_myHero) < Tard_TardMenu.JungleClear.JungleMana:Value() or Tard_myHero.attackData.state == 2 or Game.CanUseSpell(_Q) ~= 0 then return end
    for i = 1, Game.MinionCount() do
		local Tard_JungleMinion = Game.Minion(i)
		if Tard_JungleMinion.team == 300 and Need:Tard_IsValidTarget(Tard_JungleMinion, Tard_EzrealSpells[0].range) then
            self:Tard_CastQ(Tard_JungleMinion)
			break
		end
	end	
end

function TardEzreal:Tard_LastHit()
	local Tard_AAstate = Tard_myHero.attackData.state
	if not Tard_TardMenu.LastHit.LastHitQ:Value() or Need:Tard_PercentMP(Tard_myHero) < Tard_TardMenu.LastHit.LastHitMana:Value() or Tard_AAstate == 2 or Game.CanUseSpell(_Q) ~= 0 then return end
	local Tard_AAtarget = Tard_myHero.attackData.target
	local Tard_AArange = Tard_myHero.range + Tard_myHero.boundingRadius
	for i = 1, Game.MinionCount() do
		local Tard_Minion = Game.Minion(i)
		if Tard_AAtarget ~= Tard_Minion.handle and Need:Tard_IsValidTarget(Tard_Minion, Tard_EzrealSpells[0].range) and Tard_EzrealSpells[0].dmg(Tard_Minion) >= Tard_Minion.health then
            if (Tard_AAstate == 3 and Need:Tard_HP_PRED(Tard_Minion, Tard_myHero.attackData.endTime - Game.Timer()) > 0) or (Need:Tard_GetDistanceSqr(Tard_Minion.pos) > (Tard_AArange+Tard_Minion.boundingRadius)*(Tard_AArange+Tard_Minion.boundingRadius) and Tard_AAstate ~= 2)  then
				--test si minion va mourir avant le reset aa et tard_hp_pred (temps = Tard_myHero.attackData.endTime-Game.Timer() ou attackData.animationTime)
                self:Tard_CastQ(Tard_Minion)
				break
			end
		end		
	end
end

function TardEzreal:Tard_KillSteal()
	if Tard_myHero.attackData.state == 2 then return end	
	for i = 1, Game.HeroCount() do
		local Tard_Hero = Game.Hero(i)
		if Need:Tard_IsValidTarget(Tard_Hero) then
			local Tard_Q_DMG; local Tard_W_DMG; local Tard_R_DMG;
			if Tard_TardMenu.KS.Q_KS:Value() and Game.CanUseSpell(0) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_EzrealSpells[0].range*Tard_EzrealSpells[0].range then 
                Tard_Q_DMG = Tard_EzrealSpells[0].dmg(Tard_Hero)
            end 
            if Tard_TardMenu.KS.W_KS:Value() and Game.CanUseSpell(1) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_EzrealSpells[1].range*Tard_EzrealSpells[1].range then 
                Tard_W_DMG = Tard_EzrealSpells[1].dmg(Tard_Hero) 
            end
            if Tard_TardMenu.KS.R_KS:Value() and Game.CanUseSpell(3) == 0 and Need:Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_TardMenu.KS.R_Ksrange:Value()*Tard_TardMenu.KS.R_Ksrange:Value() then 
                Tard_R_DMG = Tard_EzrealSpells[3].dmg(Tard_Hero) 
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
                        end, Tard_EzrealSpells[0].delay + Game.Latency()/1000)
            end           
			if Tard_R_DMG and Tard_R_DMG > Tard_Hero.health + Tard_Hero.shieldAP then
                    print("KS R")
                    print(Tard_R_DMG)
                    local Tard_AArange = Tard_myHero.range + Tard_myHero.boundingRadius + Tard_Hero.boundingRadius    
                    if Need:Tard_GetDistanceSqr(Tard_Hero.pos) > Tard_AArange * Tard_AArange and Need:Tard_HP_PRED(Tard_Hero, 1,5) then
                        self:Tard_CastR(Tard_Hero)
                        Tard_CurrentTarget = Tard_Hero
                    end
			end
		end
	end
end

function TardEzreal:Tard_CastQ(unit)
    if Tard_EternalPred == true then 
        local Tard_QPred = Tard_SpellstoPred[0]:GetPrediction(unit, Tard_myHero.pos)
        if Tard_QPred and (Tard_QPred.hitChance >= Tard_TardMenu.Pred.PredHitChance:Value()/100) and Tard_QPred:mCollision() == 0 and Tard_QPred:hCollision() == 0 and Need:Tard_GetDistanceSqr(Tard_QPred.castPos) <= 1440000 then
            Need:Tard_CastSpell(HK_Q,Tard_QPred.castPos, 250)            
        end 
    --[[else
        local Tard_QPred = unit:GetPrediction(Tard_EzrealSpells[0].speed, Tard_EzrealSpells[0].delay + Game.Latency()/1000)
        local Tard_QCollision, Tard_QblockUnit = Tard_SpellstoCollision[0]:__GetCollision(Tard_myHero, unit, 5)
        if (Tard_QCollision == false or (unit.type == Obj_AI_Minion and #Tard_QblockUnit == 1)) and Need:Tard_GetDistanceSqr(Tard_QPred) < (Tard_EzrealSpells[0].range*Tard_EzrealSpells[0].range) then-- 1440000 then
        --Need:Tard_CastSpell(HK_Q, Tard_QPred, Tard_EzrealSpells[0].delay)   
            GOS.BlockMovement = true
        --GOS.BlockAttack = true
            Control.CastSpell(HK_Q, Tard_QPred)
            GOS.BlockMovement = false
        --GOS.BlockAttack = false
        end ]]
    end
end

function TardEzreal:Tard_CastW(unit)
    if Tard_EternalPred == true then
        local Tard_WPred = Tard_SpellstoPred[1]:GetPrediction(unit, Tard_myHero.pos)
        if Tard_WPred and Tard_WPred.hitChance >= Tard_TardMenu.Pred.PredHitChance:Value()/100 and Need:Tard_GetDistanceSqr(Tard_WPred.castPos) < 1102500 then
            Need:Tard_CastSpell(HK_W,Tard_WPred.castPos,540)  
        end
    --[[else
        local Tard_WPred = unit:GetPrediction(Tard_EzrealSpells[1].speed, Tard_EzrealSpells[1].delay + Game.Latency()/1000)
        if Need:Tard_GetDistanceSqr(Tard_WPred) < 1050625 then
        --Need:Tard_CastSpell(HK_W, Tard_WPred, Tard_EzrealSpells[0].delay)
        GOS.BlockMovement = true
        --GOS.BlockAttack = true
        Control.CastSpell(HK_W, Tard_WPred)
        GOS.BlockAttack = false
    --  GOS.BlockAttack = false
        end]]
    end 
end

function TardEzreal:Tard_CastR(unit)
    if Tard_EternalPred == true then  
        local Tard_RPred = Tard_SpellstoPred[3]:GetPrediction(unit, Tard_myHero.pos)
        if Tard_RPred and (Tard_RPred.hitChance >= Tard_TardMenu.Pred.PredHitChance:Value()/100) then
                Tard_RPred.castPos = Vector(Tard_RPred.castPos)
                Tard_RPred.castPos = Tard_myHero.pos + Vector(Tard_RPred.castPos - Tard_myHero.pos):Normalized() * math.random(500,800)
                Need:Tard_CastSpell(HK_R,Tard_RPred.castPos, 1760)
        end 
        --[[else
        local Tard_RPred = unit:GetPrediction(Tard_EzrealSpells[3].speed, Tard_EzrealSpells[3].delay + Game.Latency()/1000)    
        if Need:Tard_GetDistanceSqr(Tard_myHero.pos,Tard_RPred) < (Tard_EzrealSpells[3].range*Tard_EzrealSpells[3].range) then
            Need:Tard_CastSpell(HK_R, Tard_RPred, 1760)
        end]]
    end
end

function TardEzreal:Tard_RonKey()
    if Tard_TardMenu.Misc.Rkey:Value() and Game.CanUseSpell(3) == 0 and Tard_SelectedTarget ~= nil then
        local Tard_Rtarget = Tard_SelectedTarget
        if Tard_Rtarget then
            TardEzreal:Tard_CastR(Tard_Rtarget)
        end
    end
end

function TardEzreal:Tard_Draw()
    if Tard_myHero.dead or Tard_TardMenu.Draw.DisableDraw:Value() then return end
    local Tard_EzrealPos = Tard_myHero.pos
    local Tard_DrawMenu = Tard_TardMenu.Draw
    local Tard_DrawCircle = Draw.Circle
    local Tard_DrawColor = Draw.Color
    local Tard_Spell = Game.CanUseSpell
    if Tard_DrawMenu.DrawQ:Value() and (Tard_Spell(_Q) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
            Draw.Circle(Tard_EzrealPos, 1200, 1, Tard_DrawColor(255, 96, 203, 67))
    end
    if Tard_DrawMenu.DrawW:Value() and (Tard_Spell(_W) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
            Draw.Circle(Tard_EzrealPos, 1050, 1, Tard_DrawColor(255, 255, 255, 255))
    end
    if Tard_DrawMenu.DrawE:Value() and (Tard_Spell(_E) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
           Draw.Circle(Tard_EzrealPos, 475, 1, Tard_DrawColor(255, 255, 255, 255))
    end
    --[[if Tard_DrawMenu.DrawTarget:Value() then
        local Tard_drawTarget = Tard_CurrentTarget
        if Tard_drawTarget == nil or Tard_drawTarget.dead then return 
        else
            Tard_DrawCircle(Tard_drawTarget,70,3,Tard_DrawColor(255, 255, 255, 0))
        end
    end ]]
    if Tard_DrawMenu.DrawSpellTarget:Value() then
        if Tard_TardMenu.Misc.SelectedTarget:Value() and Need:Tard_IsValidTarget(Tard_SelectedTarget) then
            Tard_DrawCircle(Tard_SelectedTarget.pos, 80, 3, Tard_DrawColor(255, 0, 0 ,255))
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------------------
Callback.Add("Load", function() 
	if _G["TardEzreal"] and myHero.charName == "Ezreal" then
        require 'Eternal Prediction'
        if not _G.Prediction_Loaded then 
            print("Warning : Eternal Prediction is missing and required, you need to install it, Ezreal script closing...")
            return
        else	            	
		    _G["TardEzreal"]() 
        end       		       
	end
end)


