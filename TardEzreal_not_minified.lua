--------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<INIT>---------------------------------------------------
if myHero.charName ~= "Ezreal" then return end
-----------------------------------------------------</INIT>---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-----------------------------------------------------</VARIABLES>---------------------------------------------------
local Tard_SpellstoPred, Tard_EternalPred, HpredV, Tard_SDK,Tard_SDKCombo,Tard_SDKHarass,Tard_SDKJungleClear,Tard_SDKLaneClear,Tard_SDKLastHit,Tard_SDKFlee,Tard_SDKSelector,Tard_SDKHealthPrediction, Tard_SDKDamagePhysical,Tard_SDKDamageMagical,Tard_CurrentTarget,Tard_SpellstoPred,Tard_Mode,TardGSOOrbwalker, TardGSOGetTarget, TardGSOMode, TardGSOObjects, TardGSOState, _EnemyHeroes
local Tard_myHero                   = _G.myHero
local Tard_version                  = 2
local Tard_SelectedTarget           = nil
local LocalCallbackAdd				      = Callback.Add
local Tard_DrawCircle				        = Draw.Circle
local Tard_DrawColor                = Draw.Color
local TardIsRSpell                  = Game.CanUseSpell
local TardLatency                   = Game.Latency
local TardGameTimer                 = Game.Timer
local TardHeroCount                 = Game.HeroCount
local TardHero                      = Game.Hero
local TardMinionCount               = Game.MinionCount
local TardMinion 				            = Game.Minion
local TardIsChatOpen                = Game.IsChatOpen
local TardInsert                    = table.insert
local TardMathHuge                  = math.huge
local TardMathSqrt                  = math.sqrt
local TardMin                       = math.min
local TardVector                    = Vector           
local _Q							              = _Q
local _W							              = _W
local _E							              = _E
local _R							              = _R
local ITEM_1						            = ITEM_1
local ITEM_2						            = ITEM_2
local ITEM_3						            = ITEM_3
local ITEM_4						            = ITEM_4
local ITEM_5						            = ITEM_5
local ITEM_6						            = ITEM_6
local ITEM_7						            = ITEM_7
local Tard_Orb                      = 4
local TEAM_ALLY 					          = Tard_myHero.team
local TEAM_JUNGLE 					        = 300
local TEAM_ENEMY 					          = 300 - TEAM_ALLY
local visionTick 					          = GetTickCount()
local _OnVision, _OnWaypoint        = {}, {}
local _movementHistory              = {}
local castSpell                     = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local Tard_ItemHotKey               = {[ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2,	[ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4,	[ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}
local Tard_EzrealSpells             = { [0] = {range = 1200, delay = 0.25, speed = 2000, width = 80, spellType = TYPE_LINE, hitBox = true},
                                        [1] = {range = 1050, delay = 0.54, speed = 1600, width = 80, spellType = TYPE_LINE, hitBox = false},
                                        [2] = {range = 475},
                                        [3] = {range = 20000, delay = 1.76, speed = 2000, width = 160, spellType = TYPE_LINE, hitBox = false}
                                    }
local Tard_Icon                     = { ["Ezreal"] = "http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/EzrealSquare.png",
                                        ["Sheen"] = "http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Sheen.png"
                                    }

local Tard_TardMenu                 = MenuElement({type = MENU, id = "TardEzrealMenu", name = "TardEzreal", leftIcon = Tard_Icon.Ezreal})
local DamageReductionTable          = { ["Braum"] = {
                                            buff = "BraumShieldRaise",
                                            amount = function(target)
                                                return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level]
                                            end
                                        },
                                        ["Urgot"] = {
                                            buff = "urgotswapdef",
                                            amount = function(target)
                                                return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level]
                                            end
                                        },
                                        ["Alistar"] = {
                                            buff = "Ferocious Howl",
                                            amount = function(target)
                                                return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level]
                                            end
                                        },
                                        ["Amumu"] = {
                                            buff = "Tantrum",
                                            amount = function(target)
                                                return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level]
                                            end,
                                            damageType = 1
                                        },
                                        ["Galio"] = {
                                            buff = "GalioIdolOfDurand",
                                            amount = function(target)
                                                return 0.5
                                            end
                                        },
                                        ["Garen"] = {
                                            buff = "GarenW",
                                            amount = function(target)
                                                return 0.7
                                            end
                                        },
                                        ["Gragas"] = {
                                            buff = "GragasWSelf",
                                            amount = function(target)
                                                return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level]
                                            end
                                        },
                                        ["Annie"] = {
                                            buff = "MoltenShield",
                                            amount = function(target)
                                                return 1 - ({0.16, 0.22, 0.28, 0.34, 0.4})[target:GetSpellData(_E).level]
                                            end
                                        },
                                        ["Malzahar"] = {
                                            buff = "malzaharpassiveshield",
                                            amount = function(target)
                                                return 0.1
                                            end
                                        }
                                    }

-----------------------------------------------------</VARIABLES>---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<FONCTIONS>---------------------------------------------------

local Tard_GetDistanceSqr           = function(Pos1, Pos2)
                                        local Pos2 = Pos2 or Tard_myHero.pos
                                        local Tard_dx = Pos1.x - Pos2.x
                                        local Tard_dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
                                        return (Tard_dx * Tard_dx) + (Tard_dz * Tard_dz)
                                    end

local Tard_PercentHP               = function(unit)
                                        return (unit.health / unit.maxHealth) * 100
                                    end

local Tard_PercentMP                = function(unit)
                                        return (unit.mana / unit.maxMana) * 100
                                    end

local Tard_IsValidTarget            = function(unit, range)
                                        local range = range or TardMathHuge
                                        return unit and unit.isEnemy and unit.valid and Tard_GetDistanceSqr(unit.pos) <= (range * range) and
                                            unit.visible and unit.isTargetable and not unit.dead and not unit.isImmune
                                    end

local Tard_HasBuff                  = function(unit, buffname)
                                        for i = 0, unit.buffCount do
                                            local Tard_Buff = unit:GetBuff(i)
                                            if Tard_Buff and Tard_Buff.name ~= "" and Tard_Buff.count > 0 and TardGameTimer() >= Tard_Buff.startTime and
                                            TardGameTimer() < Tard_Buff.expireTime and Tard_Buff.name == buffname then
                                                return Tard_Buff.count
                                            end
                                        end
                                        return 0
                                    end

local Tard_GetMode                  = function()
                                        if Tard_Orb == 1 then
                                            if EOW.CurrentMode == 1 then
                                                return "Combo"
                                            elseif EOW.CurrentMode == 2 then
                                                return "Harass"
                                            elseif EOW.CurrentMode == 3 then
                                                return "Lasthit"
                                            elseif EOW.CurrentMode == 4 then
                                                return "Clear"
                                            end
                                        elseif Tard_Orb == 2 then
                                            TardSDKModes = Tard_SDK.Modes
                                            if TardSDKModes[Tard_SDKCombo] then
                                                return "Combo"
                                            elseif TardSDKModes[Tard_SDKHarass] then
                                                return "Harass"
                                            elseif TardSDKModes[Tard_SDKLaneClear] or TardSDKModes[Tard_SDKJungle] then
                                                return "Clear"
                                            elseif TardSDKModes[Tard_SDKLastHit] then
                                                return "Lasthit"
                                            elseif TardSDKModes[Tard_SDKFlee] then
                                                return "Flee"
                                            end
                                        elseif Orb == 3 then
                                            if TardGSOMode.isCombo() then
                                                return "Combo"
                                            elseif TardGSOMode.isHarass() then
                                                return "Harass"
                                            elseif TardGSOMode.isLaneClear() then
                                                return "Clear"
                                            elseif TardGSOMode.isLastHit() then
                                                return "LastHit"
                                            end
                                        else
                                            return GOS:GetMode()
                                        end
                                    end

local Tard_GetTarget                = function(range)
                                        local Tard_target
                                        if Tard_Orb == 1 then
                                            if Tard_myHero.totalDamage >= Tard_myHero.ap then
                                                Tard_target = EOW:GetTarget(range, ad_dec)
                                            else
                                                Tard_target = EOW:GetTarget(range, ap_dec)
                                            end
                                        elseif Tard_Orb == 2 then
                                            if Tard_myHero.totalDamage >= Tard_myHero.ap then
                                                Tard_target = Tard_SDKSelector:GetTarget(range, Tard_SDKDamagePhysical)
                                            else
                                                Tard_target = Tard_SDKSelector:GetTarget(range, Tard_SDKDamageMagical)
                                            end
                                        elseif Tard_Orb == 3 then 
                                            local enemyHeroes_spell = TardGSOObjects.enemyHeroes_spell
                                            if Tard_myHero.totalDamage >= Tard_myHero.ap then
                                                Tard_target = TardGSOGetTarget(range, enemyHeroes_spell, Tard_myHero.pos, false, false)
                                            else
                                                Tard_target = TardGSOGetTarget(range, enemyHeroes_spell, Tard_myHero.pos, true, false)
                                            end
                                        else
                                            Tard_target = GOS:GetTarget(range)
                                        end
                                        return Tard_target
                                    end

local GetEnemyHeroes                = function()
                                        if _EnemyHeroes then return _EnemyHeroes end
                                        _EnemyHeroes = {}
                                        for i = 1, TardHeroCount() do
                                            local unit = TardHero(i)
                                            if unit.team == TEAM_ENEMY then
                                                table.insert(_EnemyHeroes, unit)
                                            end
                                        end
                                        return _EnemyHeroes
                                    end
                                         
local IsImmobileTarget              = function(unit)
                                        for i = 0, unit.buffCount do
                                            local buff = unit:GetBuff(i)
                                            if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
                                                return true
                                            end
                                        end
                                        return false	
                                    end
                                    
local Tard_HP_PRED                  = function(unit, time)
                                        if Tard_Orb == 1 then
                                            return EOW:GetHealthPrediction(unit, time)
                                        elseif Tard_Orb == 2 then
                                            return Tard_SDKHealthPrediction:GetPrediction(unit, time)
                                        elseif Tard_Orb == 3 then
                                            return TardGSOHPPred(unit.health, unit.handle, time)
                                        else
                                            return GOS:HP_Pred(unit, time)
                                        end
                                    end

local VectorPntProjecOnLineSegment  = function(v1, v2, v) -- Thx Tosh :)
                                        local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
                                        local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
                                        local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
                                        local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
                                        local isOnSegment = rS == rL
                                        local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
                                        return pointSegment, pointLine, isOnSegment
                                    end

local mCollision                    = function(unit, spell, sourcePos, castPos) -- Thx Tosh :)
                                        local Count = 0
                                        for i = TardMinionCount(), 1, -1 do
                                            local m = TardMinion(i)
                                            if m ~= unit and m.team ~= TEAM_ALLY and m.dead == false and m.isTargetable then
                                                local pointSegment, pointLine, isOnSegment = VectorPntProjecOnLineSegment(sourcePos, castPos, m.pos)
                                                local w = Tard_EzrealSpells[spell].width + m.boundingRadius
                                                local pos = m.pos
                                                if isOnSegment and Tard_GetDistanceSqr(pointSegment, pos) < w * w and Tard_GetDistanceSqr(sourcePos, castPos) > Tard_GetDistanceSqr(sourcePos, pos) then
                                                    Count = Count + 1
                                                end
                                            end
                                        end
                                        return Count
                                    end

local hCollision                    = function(unit, spell, sourcePos, castPos) -- Thx Tosh :)
                                        local Count = 0
                                        for i = TardHeroCount(), 1, -1 do
                                            local m = TardHero(i)
                                            if m ~= unit and m.team == TEAM_ENEMY and m.dead == false and m.isTargetable then
                                                local pointSegment, pointLine, isOnSegment = VectorPntProjecOnLineSegment(sourcePos, castPos, m.pos)
                                                local w = Tard_EzrealSpells[spell].width + m.boundingRadius
                                                local pos = m.pos
                                                if isOnSegment and Tard_GetDistanceSqr(pointSegment, pos) < w * w and Tard_GetDistanceSqr(sourcePos, castPos) > Tard_GetDistanceSqr(sourcePos, pos) then
                                                    Count = Count + 1
                                                end
                                            end
                                        end
                                        return Count
                                    end
                                        
---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<NODDY FONCTIONS, THX TO HIM :)>---------------------------------------------------
local OnVision                      = function(unit)
                                        if _OnVision[unit.networkID] == nil then _OnVision[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
                                        if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = GetTickCount() end
                                        if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = GetTickCount() end
                                        return _OnVision[unit.networkID]
                                    end
LocalCallbackAdd                    ("Tick", function() OnVisionF() end)

OnVisionF                           = function()
                                        if GetTickCount() - visionTick > 100 then
                                            for i,v in pairs(GetEnemyHeroes()) do
                                                OnVision(v)
                                            end
                                        end
                                    end

local OnWaypoint                    = function(unit)
                                        if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = TardGameTimer()} end
                                        if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
                                            -- print("OnWayPoint:"..unit.charName.." | "..math.floor(LocalGameTimer()))
                                            _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = TardGameTimer()}
                                                DelayAction(function()
                                                    local time = (TardGameTimer() - _OnWaypoint[unit.networkID].time)
                                                    local speed = TardMathSqrt(Tard_GetDistanceSqr(_OnWaypoint[unit.networkID].startPos,unit.pos))/(TardGameTimer() - _OnWaypoint[unit.networkID].time)
                                                    if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and Tard_GetDistanceSqr(unit.pos,_OnWaypoint[unit.networkID].pos) > 200^2 then
                                                        _OnWaypoint[unit.networkID].speed = TardMathSqrt(Tard_GetDistanceSqr(_OnWaypoint[unit.networkID].startPos,unit.pos))/(TardGameTimer() - _OnWaypoint[unit.networkID].time)
                                                        print("OnDash: "..unit.charName)
                                                    end
                                                end,0.05)
                                        end
                                        return _OnWaypoint[unit.networkID]
                                    end

local GetPred                       = function(unit, speed, delay)
                                        local speed = speed or TardMathHuge
                                        local delay = delay or 0.25
                                        local unitSpeed = unit.ms
                                        if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
                                        if OnVision(unit).state == false then
                                            local unitPos = unit.pos + TardVector(unit.pos,unit.posTo):Normalized() * ((GetTickCount() - OnVision(unit).tick)*.001 * unitSpeed)
                                            local predPos = unitPos + TardVector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + (TardMathSqrt(Tard_GetDistanceSqr(Tard_myHero.pos,unitPos))/speed)))
                                            if Tard_GetDistanceSqr(unit.pos,predPos) > Tard_GetDistanceSqr(unit.pos,unit.posTo) then predPos = unit.posTo end
                                            return predPos
                                        else
                                            if unitSpeed > unit.ms then
                                                local predPos = unit.pos + TardVector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (unit.distance/speed)))
                                                if Tard_GetDistanceSqr(unit.pos,predPos) > Tard_GetDistanceSqr(unit.pos,unit.posTo) then predPos = unit.posTo end
                                                return predPos
                                            elseif IsImmobileTarget(unit) then
                                                return unit.pos
                                            else
                                                return unit:GetPrediction(speed,delay)
                                            end
                                        end	
                                    end

local Tard_CastSpell                = function(spell, pos, delay)
                                        local delay = delay or 250
                                        if pos == nil then
                                            return
                                        end
                                        local ticker = GetTickCount()
                                        if castSpell.state == 0 and ticker - castSpell.casting > delay + TardLatency() then -- and pos:ToScreen().onScreen then
                                            castSpell.state = 1
                                            castSpell.mouse = mousePos
                                            castSpell.tick = ticker
                                        end
                                        if castSpell.state == 1 then
                                            if ticker - castSpell.tick < TardLatency() then
                                                Control.SetCursorPos(pos)
                                                Control.KeyDown(spell)
                                                Control.KeyUp(spell)
                                                castSpell.casting = ticker + delay
                                                DelayAction(
                                                    function()
                                                        if castSpell.state == 1 then
                                                            Control.SetCursorPos(castSpell.mouse)
                                                            castSpell.state = 0
                                                        end
                                                    end,
                                                    TardLatency() * .001
                                                )
                                            end
                                            if ticker - castSpell.casting > TardLatency() then
                                                Control.SetCursorPos(castSpell.mouse)
                                                castSpell.state = 0
                                            end
                                        end
                                    end
-----------------------------------------------------</NODDY FONCTIONS, THX TO HIM :)>---------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<LOCAL DAMAGELIB, THX TO DEFTSU :)>---------------------------------------------------
local GetItemSlot                         = function(unit, id)
                                        for i = ITEM_1, ITEM_7 do
                                            if unit:GetItemData(i).itemID == id then
                                                return i
                                            end
                                        end
                                        return 0
                                    end

local CalcPhysicalDamage            = function(source, target, amount)
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
                                                string.ends = function(String, End)
                                                    return End == "" or string.sub(String, -string.len(End)) == End
                                                end
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
                                        return math.max(0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 1)))
                                    end

local CalcMagicalDamage             = function(source, target, amount)
                                        local mr = target.magicResist
                                        local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

                                        if mr < 0 then
                                            value = 2 - 100 / (100 - mr)
                                        elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
                                            value = 1
                                        end
                                        return math.max(
                                            0, math.floor(DamageReductionMod(source, target, PassivePercentMod(source, target, value) * amount, 2)))
                                    end

local DamageReductionMod            = function(source, target, amount, DamageType)
                                        if source.type == Obj_AI_Hero then
                                            if Tard_HasBuff(source, "Exhaust") > 0 then
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
                                                        if
                                                            buff.name == DamageReductionTable[target.charName].buff and
                                                                (not DamageReductionTable[target.charName].damagetype or
                                                                    DamageReductionTable[target.charName].damagetype == DamageType)
                                                        then
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
                                                            amount =amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level] /(source.type == Obj_AI_Turret and 2 or 1)
                                                        end
                                                    end
                                                end
                                            end
                                            if GetItemSlot(target, 1054) > 0 then
                                                amount = amount - 8
                                            end
                                            if target.charName == "Kassadin" and DamageType == 2 then
                                                amount = amount * 0.85
                                            end
                                        end
                                        return amount
                                    end

local PassivePercentMod             = function(source, target, amount, damageType)
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
                                                if
                                                    (GetItemSlot(source, 3036) > 0 or GetItemSlot(source, 3034) > 0) and
                                                        source.maxHealth < target.maxHealth and
                                                        damageType == 1
                                                then
                                                    amount =amount * (1 + TardMin(target.maxHealth - source.maxHealth, 500) / 50 *(GetItemSlot(source, 3036) > 0 and 0.015 or 0.01))
                                                end
                                            end
                                        end
                                        return amount
                                    end
-----------------------------------------------------</LOCAL DAMAGELIB, THX TO DEFTSU :)>---------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<LOCAL HPRED, THX TO SIKAKA & DAMNEB NOOB :)>---------------------------------------------------
local GetImmobileTime               = function(unit)
                                        local duration = 0
                                        for i = 0, unit.buffCount do
                                            local buff = unit:GetBuff(i);
                                            if buff.count > 0 and buff.duration> duration and (buff.type == 5 or buff.type == 8 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39) then
                                                duration = buff.duration
                                            end
                                        end
                                        return duration		
                                    end

local GetTargetMS                   = function(target)
                                        local ms = target.pathing.isDashing and target.pathing.dashSpeed or target.ms
                                        return ms
                                    end  

local GetPathNodes                  = function(unit)    
                                        local nodes = {}
                                        TardInsert(nodes, unit.pos)
                                        if unit.pathing.hasMovePath then
                                            for i = unit.pathing.pathIndex, unit.pathing.pathCount do
                                                path = unit:GetPath(i)
                                                TardInsert(nodes, path)
                                            end
                                        end		
                                        return nodes
                                    end   

local PredictUnitPosition           = function(unit, delay)
                                        local predictedPosition = unit.pos
                                        local timeRemaining = delay
                                        local pathNodes = GetPathNodes(unit)
                                        for i = 1, #pathNodes -1 do
                                            local nodeDistance = Tard_GetDistanceSqr(pathNodes[i], pathNodes[i +1])
                                            local targetMs = GetTargetMS(unit)
                                            local nodeTraversalTime = nodeDistance / targetMs^2
                                            if timeRemaining > nodeTraversalTime then
                                                --This node of the path will be completed before the delay has finished. Move on to the next node if one remains
                                                timeRemaining =  timeRemaining - nodeTraversalTime
                                                predictedPosition = pathNodes[i + 1]
                                            else
                                                local directionVector = (pathNodes[i+1] - pathNodes[i]):Normalized()
                                                predictedPosition = pathNodes[i] + directionVector *  GetTargetMS(unit) * timeRemaining
                                                break;
                                            end
                                        end
                                        return predictedPosition
                                    end

local UnitMovementBounds            = function(unit, delay, reactionTime)
                                        local startPosition = PredictUnitPosition(unit, delay)
                                        local radius = 0
                                        local deltaDelay = delay - reactionTime - GetImmobileTime(unit)	
                                        if (deltaDelay >0) then
                                            radius = GetTargetMS(unit) * deltaDelay	
                                        end
                                        return startPosition, radius	
                                    end

local GetRecallingData              = function(unit)
                                        for K, Buff in pairs(GetBuffs(unit)) do
                                            if Buff.name == "recall" and Buff.duration > 0 then
                                                return true, TardGameTimer() - Buff.startTime
                                            end
                                        end
                                        return false
                                    end

local PredictReactionTime           = function(unit, minimumReactionTime)   
                                        local reactionTime = minimumReactionTime
                                        --If the target is auto attacking increase their reaction time by .15s - If using a skill use the remaining windup time
                                        if unit.activeSpell and unit.activeSpell.valid then
                                            local windupRemaining = unit.activeSpell.startTime + unit.activeSpell.windup - TardGameTimer()
                                            if windupRemaining > 0 then
                                                reactionTime = windupRemaining
                                            end
                                        end
                                        --If the target is recalling and has been for over .25s then increase their reaction time by .25s
                                        local isRecalling, recallDuration = GetRecallingData(unit)	
                                        if isRecalling and recallDuration > .25 then
                                            reactionTime = .25
                                        end
                                        return reactionTime
                                    end                                                

local GetSpellInterceptTime         = function(startPos, endPos, delay, speed)
                                        local interceptTime =TardLatency()/2000 + delay + TardMathSqrt(Tard_GetDistanceSqr(startPos, endPos)) / speed
                                        return interceptTime
                                    end

local CanTarget                     = function(target)
                                        return target.team == TEAM_ENEMY and target.alive and target.visible and target.isTargetable
                                    end



local IsMinionIntersection          = function(location, radius, delay, maxDistance)
                                        if not maxDistance then maxDistance = 500 end
                                        for i = 1, TardMinionCount() do
                                            local minion = TardMinion(i)
                                            if CanTarget(minion) and Tard_GetDistanceSqr(minion.pos, location) < maxDistance^2 then
                                                local predictedPosition = PredictUnitPosition(minion, delay)
                                                if Tard_GetDistanceSqr(location, predictedPosition) <= (radius + minion.boundingRadius)^2 then
                                                    return true
                                                end
                                            end
                                        end
                                        return false
                                    end

local CheckMinionCollision          = function(origin, endPos, delay, speed, radius, frequency)
                                        if not frequency then frequency = radius end
                                        local directionVector = (endPos - origin):Normalized()
                                        local checkCount = Tard_GetDistanceSqr(origin, endPos) / frequency^2
                                        for i = 1, checkCount do
                                            local checkPosition = origin + directionVector * i * frequency
                                            local checkDelay = delay + Tard_GetDistanceSqr(origin, checkPosition) / speed^2
                                            if IsMinionIntersection(checkPosition, radius, checkDelay, radius * 3) then
                                                return true
                                            end
                                        end
                                        return false
                                    end

local GetHitchance                  = function(source, target, range, delay, speed, radius, checkCollision)	
                                        local hitChance = 1	
                                        local aimPosition = PredictUnitPosition(target, delay + TardMathSqrt(Tard_GetDistanceSqr(source, target.pos)) / speed)	
                                        local interceptTime = GetSpellInterceptTime(source, aimPosition, delay, speed)
                                        local reactionTime = PredictReactionTime(target, .1)
                                        --If they just now changed their path then assume they will keep it for at least a short while... slightly higher chance
                                        if _movementHistory and _movementHistory[target.charName] and TardGameTimer() - _movementHistory[target.charName]["ChangedAt"] < .25 then
                                            hitChance = 2
                                        end
                                        --If they are standing still give a higher accuracy because they have to take actions to react to it
                                        if not target.pathing or not target.pathing.hasMovePath then
                                            hitChance = 2
                                        end	
                                        local origin,movementRadius = UnitMovementBounds(target, interceptTime, reactionTime)
                                        --Our spell is so wide or the target so slow or their reaction time is such that the spell will be nearly impossible to avoid
                                        if movementRadius - target.boundingRadius <= radius /2 then
                                            origin,movementRadius = UnitMovementBounds(target, interceptTime, 0)
                                            if movementRadius - target.boundingRadius <= radius /2 then
                                                hitChance = 4
                                            else		
                                                hitChance = 3
                                            end
                                        end	
                                        --If they are casting a spell then the accuracy will be fairly high. if the windup is longer than our delay then it's quite likely to hit. 
                                        --Ideally we would predict where they will go AFTER the spell finishes but that's beyond the scope of this prediction
                                        if target.activeSpell and target.activeSpell.valid then
                                            if target.activeSpell.startTime + target.activeSpell.windup - TardGameTimer() >= delay then
                                                hitChance = 5
                                            else			
                                                hitChance = 3
                                            end
                                        end
                                        --Check for out of range
                                        if Tard_GetDistanceSqr(myHero.pos, aimPosition) >= range*range then
                                            hitChance = -1
                                        end
                                        --Check minion block
                                        if hitChance > 0 and checkCollision then	
                                            if CheckMinionCollision(source, aimPosition, delay, speed, radius) then
                                                hitChance = -1
                                            end
                                        end
                                        return hitChance, aimPosition
                                    end
-----------------------------------------------------</LOCAL HPRED, THX TO SIKAKA & DAMNEB NOOB :)>---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<MENU>---------------------------------------------------
local Tard_Menu                     = function()
                                        Tard_TardMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
                                            Tard_TardMenu.Combo:MenuElement({id = "sheen", name = "Don't spell if under Sheen/Triforce/lich buff", value = false, leftIcon = Tard_Icon.Sheen})
                                            Tard_TardMenu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
                                            Tard_TardMenu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
                                            Tard_TardMenu.Combo:MenuElement({id = "ComboQmana", name = "Min. Mana to Q", value = 0, min = 0, max = 100, tooltip = "It's %"})
                                            Tard_TardMenu.Combo:MenuElement({id = "ComboWmana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
                                            Tard_TardMenu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
                                            Tard_TardMenu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
                                            Tard_TardMenu.Harass:MenuElement({id = "HarassQMana", name = "Min. Mana to Q", value = 40, min = 0, max = 100, tooltip = "It's %"})
                                            Tard_TardMenu.Harass:MenuElement({id = "HarassWMana", name = "Min. Mana to W", value = 75, min = 0, max = 100, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
                                            Tard_TardMenu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
                                            Tard_TardMenu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 70, min = 0, max = 100, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "LastHit", name = "LastHit"})
                                            Tard_TardMenu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = true})
                                            Tard_TardMenu.LastHit:MenuElement({id = "LastHitMana", name = "Min Mana To Lasthit", value = 40, min = 0, max = 100, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "JungleClear", name = "JungleClear"})
                                            Tard_TardMenu.JungleClear:MenuElement({id = "JungleQ", name = "Use Q", value = true})
                                            Tard_TardMenu.JungleClear:MenuElement({id = "JungleMana", name = "Min Mana To JungleClear", value = 60,min = 0, max = 100, step = 1, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "KS", name = "KillSteal Settings"})
                                            Tard_TardMenu.KS:MenuElement({id = "debug", name = "print debug KS", value = false, tooltip = "message when script try to ks, with total dmg to target"})
                                            Tard_TardMenu.KS:MenuElement({id = "Q_KS", name = "Use Q to try to KillSteal", value = true})
                                            Tard_TardMenu.KS:MenuElement({id = "W_KS", name = "Use W to try to KillSteal", value = true})
                                            Tard_TardMenu.KS:MenuElement({id = "R_KS", name = "Use R to try to KillSteal", value = true, tooltip = "only if target is out of AA range"})
                                            Tard_TardMenu.KS:MenuElement({id = "R_Ksrange", name = "R Max Range", value = 7000, min = 300, max = 20000, step = 100, tooltip = "It's %"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
                                            Tard_TardMenu.Misc:MenuElement({id = "Rkey", name = "Ulti Champ targeted on key", key = string.byte("T"), tooltip = "the target need to be targeted by spell focus first, mouse clic on it, a blue circle should be on the target"})
                                            Tard_TardMenu.Misc:MenuElement({id = "KeepRmana", name = "Keep mana for R", value = false, tooltip = "KillSteal never keep mana"})
                                            Tard_TardMenu.Misc:MenuElement({id = "SelectedTarget", name = "Focus Spell target", value = true, tooltip = "Focus Spell on selected target"})
                                        Tard_TardMenu:MenuElement({type = MENU, id = "P", name = "Prediction Settings"})
                                            Tard_TardMenu.P:MenuElement({type = SPACE, id = "info",  name = "Disable Hpred to use Eternal Pred, need reload"})
                                            Tard_TardMenu.P:MenuElement({type = SPACE, id = "info2",  name = "Disable all preds to use Noddy pred, need reload"})
                                            Tard_TardMenu.P:MenuElement({id = "hpred", name = "Use HPred -- need reload",  value = true, tooltip = "use Noddy's pred if both pred are disable, Reload script"})
                                            if not Tard_TardMenu.P.hpred:Value() then
                                                Tard_TardMenu.P:MenuElement({id = "Epred", name = "Use Eternal Pred -- need reload",  value = true, tooltip = "use Noddy's pred if both pred are disable, Reload script"})
                                            end    
                                            if Tard_TardMenu.P.hpred:Value() and Tard_TardMenu.P.Epred == nil then
                                                Tard_TardMenu.P:MenuElement({id = "AccuracyQ", name = "Accuracy Q", value = 2, min = 1, max = 5, step = 1})
                                                Tard_TardMenu.P:MenuElement({id = "AccuracyW", name = "Accuracy W", value = 2, min = 1, max = 5, step = 1})
                                                Tard_TardMenu.P:MenuElement({id = "AccuracyR", name = "Accuracy R", value = 2, min = 1, max = 5, step = 1})
                                            end
                                            if not Tard_TardMenu.P.hpred:Value() and Tard_TardMenu.P.Epred:Value() then
                                                Tard_TardMenu.P:MenuElement({id = "PredHitChance", name = "HitChance (default 25)", value = 25, min = 0, max = 100, tooltip = "higher value better pred but slower(%)||don't change it if don't know what is it||"})
                                            end
                                        Tard_TardMenu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
                                            Tard_TardMenu.Draw:MenuElement({id = "DrawReady", name = "Draw Only Ready Spells [?]", value = true, tooltip = "Only draws spells when they're ready"})
                                            Tard_TardMenu.Draw:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
                                            Tard_TardMenu.Draw:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
                                            Tard_TardMenu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = true})
                                            Tard_TardMenu.Draw:MenuElement({id = "DrawSpellTarget", name = "Draw Spell Target Focus [?]", value = true, tooltip = "Draws spell target focus"})
                                            Tard_TardMenu.Draw:MenuElement({id = "DisableDraw", name = "Disable all Draws [?]", value = false})
                                        Tard_TardMenu:MenuElement({name = "by Yaddle", drop = {"Tard_Version : "..Tard_version}})
                                        end
-----------------------------------------------------</MENU>---------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------

local IsEvading                     = function()
                                        if ExtLibEvade and ExtLibEvade.Evading then 
                                            print("it's evading")
                                            return true
                                        end
                                    end

local GotSheen                      = function()
                                        if not Tard_TardMenu.Combo.sheen:Value() then return false end
                                        local Sheen = (GetItemSlot(Tard_myHero, 3057) >= 1 and GetItemSlot(Tard_myHero, 3057)) or 
                                                    (GetItemSlot(Tard_myHero, 3025) >= 1 and GetItemSlot(Tard_myHero, 3025)) or 
                                                    (GetItemSlot(Tard_myHero, 3100) >= 1 and GetItemSlot(Tard_myHero, 3100)) or 
                                                    (GetItemSlot(Tard_myHero, 3078) >= 1 and GetItemSlot(Tard_myHero, 3078))
                                        if Sheen and Tard_myHero:GetSpellData(Sheen).currentCd == 0 and GotBuff(Tard_myHero, "sheen") == 1 then 
                                            return true
                                        end
                                        return false                                        
                                    end

local Tard_CastQ                    = function(unit, collision, cancelifcollision)
                                        if HpredV then
                                            local hitChance, Tard_QPred = GetHitchance(Tard_myHero.pos, unit, Tard_EzrealSpells[0].range, Tard_EzrealSpells[0].delay, Tard_EzrealSpells[0].speed, Tard_EzrealSpells[0].width, false)
                                            if hitChance and hitChance >= Tard_TardMenu.P.AccuracyQ:Value() and Tard_GetDistanceSqr(Tard_QPred) < 1440000 then
                                                local Tard_Collision = (collision ~= false and mCollision(unit, 0, Tard_myHero.pos, Tard_QPred) + hCollision(unit, 0, Tard_myHero.pos, Tard_QPred)) or 0
                                                if cancelifcollision and Tard_Collision ~= 0 then return end
                                                if Tard_Collision == 0 and unit.health > 0 then Tard_CastSpell(HK_Q, Tard_QPred, 250) end
                                            end
                                        elseif Tard_EternalPred then
                                            local Tard_QPred = Tard_SpellstoPred[0]:GetPrediction(unit, Tard_myHero.pos)
                                            local Tard_Collision = (collision ~= false and mCollision(unit, 0, Tard_myHero.pos, Tard_QPred.castPos) + hCollision(unit, 0, Tard_myHero.pos, Tard_QPred.castPos)) or 0 
                                            if cancelifcollision and Tard_Collision ~= 0 then return end
                                            if Tard_QPred and Tard_GetDistanceSqr(Tard_QPred.castPos) < 1440000 and (Tard_QPred.hitChance >= Tard_TardMenu.P.PredHitChance:Value() / 100) and Tard_Collision == 0 and unit.health > 0 then
                                                Tard_CastSpell(HK_Q, Tard_QPred.castPos, 250) 
                                            end    
                                        else local Tard_QPred = GetPred(unit, 2000, 0.25 + TardLatency()*.001)
                                            if Tard_QPred and Tard_GetDistanceSqr(Tard_QPred) < 1440000 then
                                                local Tard_Collision = (collision ~= false and mCollision(unit, 0, Tard_myHero.pos, Tard_QPred) + hCollision(unit, 0, Tard_myHero.pos, Tard_QPred)) or 0
                                                if cancelifcollision and Tard_Collision ~= 0 then return end
                                                if Tard_Collision == 0 and unit.health > 0  then Tard_CastSpell(HK_Q, Tard_QPred, 250) end
                                            end
                                        end
                                    end

local Tard_CastW                    = function(unit)
                                        if HpredV then
                                            local hitChance, Tard_WPred = GetHitchance(Tard_myHero.pos, unit, Tard_EzrealSpells[1].range, Tard_EzrealSpells[1].delay, Tard_EzrealSpells[1].speed, Tard_EzrealSpells[1].width, false)
                                            if hitChance and hitChance >= Tard_TardMenu.P.AccuracyW:Value() and Tard_GetDistanceSqr(Tard_WPred) < 1102500 then
                                                Tard_CastSpell(HK_W, Tard_WPred, 540)
                                            end
                                        elseif Tard_EternalPred then
                                            local Tard_WPred = Tard_SpellstoPred[1]:GetPrediction(unit, Tard_myHero.pos)
                                            if Tard_WPred and Tard_WPred.hitChance >= Tard_TardMenu.P.PredHitChance:Value() / 100 and Tard_GetDistanceSqr(Tard_WPred.castPos) < 1102500 then
                                                Tard_CastSpell(HK_W, Tard_WPred.castPos, 540)
                                            end

                                        else local Tard_WPred = GetPred(unit, 1600, 0.54 + TardLatency()*.001)
                                            if Tard_WPred and Tard_GetDistanceSqr(Tard_WPred) < 1102500 then
                                                Tard_CastSpell(HK_W, Tard_WPred, 540)
                                            end
                                        end
                                    end

local Tard_CastR                    = function(unit)
                                        if HpredV then 
                                            local hitChance, Tard_RPred = GetHitchance(Tard_myHero.pos, unit, 20000, 1.76, 2000, 160, false)
                                            if hitChance and hitChance >= Tard_TardMenu.P.AccuracyR:Value() then
                                                local Vec = TardVector(Tard_RPred) 
                                                local NormalizedPos = Tard_myHero.pos + TardVector(Vec - Tard_myHero.pos):Normalized() * 500
                                                Tard_CastSpell(HK_R, NormalizedPos, 1760)
                                            end
                                        elseif Tard_EternalPred then
                                            local Tard_RPred = Tard_SpellstoPred[3]:GetPrediction(unit, Tard_myHero.pos)
                                            if Tard_RPred and (Tard_RPred.hitChance >= Tard_TardMenu.P.PredHitChance:Value() / 100) then
                                                local Vec = TardVector(Tard_RPred.castPos) 
                                                local NormalizedPos = Tard_myHero.pos + TardVector(Vec - Tard_myHero.pos):Normalized() * 500
                                                Tard_CastSpell(HK_R, NormalizedPos, 1760)
                                            end
                                        else local Tard_RPred = GetPred(unit, 2000, 1.76 + TardLatency()*.001)
                                            if Tard_RPred then 
                                                local Vec = TardVector(Tard_RPred) 
                                                local NormalizedPos = Tard_myHero.pos + TardVector(Vec - Tard_myHero.pos):Normalized() * 500
                                                Tard_CastSpell(HK_R, NormalizedPos, 1760)
                                            end 
                                        end
                                    end

local Tard_RonKey                   = function()
                                        if Tard_TardMenu.Misc.Rkey:Value() and TardIsRSpell(3) == 0 and Tard_SelectedTarget ~= nil then
                                            local Tard_Rtarget = Tard_SelectedTarget
                                            if Tard_Rtarget then
                                                Tard_CastR(Tard_Rtarget)
                                            end
                                        end
                                    end

local Tard_KillSteal                = function()
                                        local DebugMenu = Tard_TardMenu.KS.debug:Value()
                                        if Tard_myHero.attackData.state == 2 then
                                            return
                                        end
                                        for i = 1, TardHeroCount() do
                                            local Tard_Hero = TardHero(i)
                                            if Tard_IsValidTarget(Tard_Hero) then
                                                local Tard_Q_DMG, Tard_W_DMG, Tard_R_DMG
                                                if Tard_TardMenu.KS.Q_KS:Value() and TardIsRSpell(0) == 0 and Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_EzrealSpells[0].range * Tard_EzrealSpells[0].range then
                                                    Tard_Q_DMG = Tard_EzrealSpells[0].dmg(Tard_Hero)
                                                end
                                                if Tard_TardMenu.KS.W_KS:Value() and TardIsRSpell(1) == 0 and Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_EzrealSpells[1].range * Tard_EzrealSpells[1].range then
                                                    Tard_W_DMG = Tard_EzrealSpells[1].dmg(Tard_Hero)
                                                end
                                                if Tard_TardMenu.KS.R_KS:Value() and TardIsRSpell(3) == 0 and Tard_GetDistanceSqr(Tard_Hero.pos) <= Tard_TardMenu.KS.R_Ksrange:Value() * Tard_TardMenu.KS.R_Ksrange:Value() then
                                                    Tard_R_DMG = Tard_EzrealSpells[3].dmg(Tard_Hero)
                                                end
                                                if Tard_W_DMG ~= nil and Tard_W_DMG > Tard_Hero.health + Tard_Hero.shieldAP then
                                                    if DebugMenu then print("KS W"); print(Tard_W_DMG) end
                                                    Tard_CastW(Tard_Hero)
                                                    Tard_CurrentTarget = Tard_Hero
                                                end
                                                if Tard_Q_DMG ~= nil and Tard_Q_DMG > Tard_Hero.health + Tard_Hero.shieldAD then
                                                    if DebugMenu then print("KS Q"); print(Tard_Q_DMG) end
                                                    Tard_CastQ(Tard_Hero)
                                                    Tard_CurrentTarget = Tard_Hero
                                                end
                                                if Tard_Q_DMG ~= nil and Tard_W_DMG ~= nil and Tard_Q_DMG + Tard_W_DMG > Tard_Hero.health + Tard_Hero.shieldAD + Tard_Hero.shieldAP then
                                                    if DebugMenu then print("KS W + Q") end
                                                    Tard_CurrentTarget = Tard_Hero
                                                    Tard_CastQ(Tard_Hero)
                                                    DelayAction(
                                                        function()
                                                            Tard_CastW(Tard_Hero)
                                                        end,
                                                        Tard_EzrealSpells[0].delay + TardLatency()*.001
                                                    )
                                                end
                                                if Tard_R_DMG and Tard_R_DMG > Tard_Hero.health + Tard_Hero.shieldAP then
                                                    if DebugMenu then print("KS R"); print(Tard_R_DMG) end
                                                    local Tard_AArange = Tard_myHero.range + Tard_myHero.boundingRadius + Tard_Hero.boundingRadius
                                                    local Dist = Tard_GetDistanceSqr(Tard_Hero.pos)
                                                    if
                                                        Dist > Tard_AArange * Tard_AArange and
                                                            Tard_HP_PRED(Tard_Hero, Dist/4000000) > 0
                                                    then
                                                        Tard_CastR(Tard_Hero)
                                                        Tard_CurrentTarget = Tard_Hero
                                                    end
                                                end
                                            end
                                        end
                                    end                                    

local Tard_Combo                    = function()
                                        local Tard_target
                                        if Tard_SelectedTarget ~= nil and Tard_GetDistanceSqr(Tard_SelectedTarget.pos) > 6250000 then --2500*2500
                                            Tard_SelectedTarget = nil
                                        end
                                        if Tard_SelectedTarget == nil or not Tard_IsValidTarget(Tard_SelectedTarget, 1200) then
                                            Tard_target = Tard_GetTarget(1200)
                                        else
                                            Tard_target = Tard_SelectedTarget
                                        end
                                        if Tard_target == nil or Tard_myHero.attackData.state == 2 or IsEvading() then
                                            return
                                        end
                                        if GotSheen() and Tard_target.distance <= 700  then return end
                                        if Tard_TardMenu.Combo.ComboQ:Value() and
                                                Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Combo.ComboQmana:Value() and
                                                TardIsRSpell(_Q) == 0 and Tard_IsValidTarget(Tard_target, 1200) then
                                            Tard_CastQ(Tard_target)
                                            Tard_CurrentTarget = Tard_target
                                        end
                                        if Tard_TardMenu.Combo.ComboW:Value() and
                                                Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Combo.ComboWmana:Value() and
                                                TardIsRSpell(_W) == 0 and Tard_IsValidTarget(Tard_target, 1050) then
                                            Tard_CastW(Tard_target)
                                            Tard_CurrentTarget = Tard_target
                                        end
                                    end

local Tard_Harass                   = function()
                                        local Tard_target
                                        if Tard_SelectedTarget ~= nil and Tard_GetDistanceSqr(Tard_SelectedTarget.pos) > 6250000 then --2500*2500
                                            Tard_SelectedTarget = nil
                                        end
                                        if Tard_SelectedTarget == nil or not Tard_IsValidTarget(Tard_SelectedTarget, 1200) then
                                            Tard_target = Tard_GetTarget(1200)
                                        else
                                            Tard_target = Tard_SelectedTarget
                                        end
                                        if Tard_target == nil or Tard_myHero.attackData.state == 2 or IsEvading() then
                                            return
                                        end
                                        if Tard_TardMenu.Harass.HarassQ:Value() and
                                                Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Harass.HarassQMana:Value() and
                                                TardIsRSpell(_Q) == 0 and Tard_IsValidTarget(Tard_target, 1200) then
                                            if Tard_myHero.activeSpell.valid ~= true then
                                                Tard_CastQ(Tard_target)
                                                Tard_CurrentTarget = Tard_target
                                            end
                                        end
                                        if Tard_TardMenu.Harass.HarassW:Value() and
                                                Tard_PercentMP(Tard_myHero) >= Tard_TardMenu.Harass.HarassWMana:Value() and
                                                TardIsRSpell(_W) == 0 and Tard_IsValidTarget(Tard_target, 1050) then
                                            if Tard_myHero.activeSpell.valid ~= true then
                                                Tard_CastW(Tard_target)
                                                Tard_CurrentTarget = Tard_target
                                            end
                                        end
                                    end

local Tard_Farm                     = function()
                                        if not Tard_TardMenu.Farm.FarmQ:Value() or Tard_PercentMP(Tard_myHero) < Tard_TardMenu.Farm.FarmMana:Value() or
                                                Tard_myHero.attackData.state == 2 or TardIsRSpell(0) ~= 0 or IsEvading() then
                                            return
                                        end
                                        local Tard_AArange = Tard_myHero.range + Tard_myHero.boundingRadius
                                        local Qlvl = Tard_myHero:GetSpellData(0).level
                                        local Qdmg = ({15, 40, 65, 90, 115})[Qlvl] + 1.1 * Tard_myHero.totalDamage + 0.4 * Tard_myHero.ap
                                        for i = 1, TardMinionCount() do
                                            local Tard_Minion = TardMinion(i)
                                            if Tard_IsValidTarget(Tard_Minion, 1200) and Tard_Minion.team ~= 300 then
                                                local AAEnd = Tard_GetDistanceSqr(Tard_Minion.pos) / 4000000
                                                local minionHP = AAEnd and Tard_HP_PRED(Tard_Minion, AAEnd) - Qdmg
                                                if minionHP <= 0 or (Tard_Minion.distance > Tard_AArange and Qdmg >= Tard_Minion.health) then
                                                        Tard_CastQ(Tard_Minion, true, false)
                                                        break
                                                end
                                            end
                                        end
                                    end

local Tard_JungleClear              = function()
                                        if not Tard_TardMenu.JungleClear.JungleQ:Value() or
                                                Tard_PercentMP(Tard_myHero) < Tard_TardMenu.JungleClear.JungleMana:Value() or
                                                Tard_myHero.attackData.state == 2 or TardIsRSpell(_Q) ~= 0 or IsEvading()  then
                                            return
                                        end
                                        for i = 1, TardMinionCount() do
                                            local Tard_JungleMinion = TardMinion(i)
                                            if Tard_JungleMinion.team == 300 and Tard_IsValidTarget(Tard_JungleMinion, 1200) then
                                                Control.CastSpell(HK_Q, Tard_JungleMinion)
                                                break
                                            end
                                        end
                                    end

local Tard_LastHit                  = function()
                                        if not Tard_TardMenu.LastHit.LastHitQ:Value() or
                                                Tard_PercentMP(Tard_myHero) < Tard_TardMenu.LastHit.LastHitMana:Value() or
                                                Tard_myHero.attackData.state == 2 or TardIsRSpell(_Q) ~= 0 or IsEvading() then
                                            return
                                        end
                                        local Tard_AArange = Tard_myHero.range + Tard_myHero.boundingRadius
                                        local Qlvl = Tard_myHero:GetSpellData(0).level
                                        local Qdmg = ({15, 40, 65, 90, 115})[Qlvl] + 1.1 * Tard_myHero.totalDamage + 0.4 * Tard_myHero.ap
                                        for i = 1, TardMinionCount() do
                                            local Tard_Minion = TardMinion(i)
                                            local AAData = Tard_myHero.attackData
                                            local Tard_AAtarget = AAData.target
                                            local Tard_AAstate = AAData.state
                                            --if Tard_AAtarget ~= Tard_Minion.handle and Tard_IsValidTarget(Tard_Minion, 1200) and Qdmg >= Tard_Minion.health then
                                            if Tard_IsValidTarget(Tard_Minion, 1200) and Qdmg >= Tard_Minion.health then
                                                local AAEnd = Tard_GetDistanceSqr(Tard_Minion.pos) / 4000000
                                                local minionHP = AAEnd and Tard_HP_PRED(Tard_Minion, AAEnd) - Qdmg
                                                if (Tard_AAstate == 3 and minionHP <= 0 and Tard_myHero.attackData.target ~= Tard_Minion.handle) or Tard_Minion.distance > Tard_AArange + Tard_Minion.boundingRadius then
                                                        Tard_CastQ(Tard_Minion)
                                                        break
                                                end
                                            end
                                        end
                                    end

-----------------------------------------------------</FONCTIONS>---------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<CALLBACKS>---------------------------------------------------

LocalCallbackAdd                    ("Tick", function()
                                        if Tard_myHero.dead or TardIsChatOpen() or IsEvading() then
                                            return
                                        end
                                        Tard_Mode = Tard_GetMode()
                                        if (Tard_TardMenu.Misc.KeepRmana:Value() and TardIsRSpell(3) == 0 and Tard_myHero.mana >= 140) or (TardIsRSpell(3) ~= 0 or not Tard_TardMenu.Misc.KeepRmana:Value()) then
                                            if Tard_Mode == "Combo" then
                                                Tard_Combo()
                                            elseif Tard_Mode == "Harass" then
                                                Tard_Harass()
                                            elseif Tard_Mode == "Lasthit" then
                                                Tard_LastHit()
                                            elseif Tard_Mode == "Clear" then
                                                Tard_Farm()
                                                Tard_JungleClear()
                                            end
                                        end
                                        Tard_KillSteal()
                                        Tard_RonKey()
                                    end
                                    )

LocalCallbackAdd                    ("Draw", function()
                                        if Tard_myHero.dead or Tard_TardMenu.Draw.DisableDraw:Value() then
                                            return
                                        end
                                        local Tard_EzrealPos = Tard_myHero.pos
                                        local Tard_DrawMenu = Tard_TardMenu.Draw
                                        if Tard_DrawMenu.DrawQ:Value() and (TardIsRSpell(_Q) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
                                            Tard_DrawCircle(Tard_EzrealPos, 1200, 1, Tard_DrawColor(255, 96, 203, 67))
                                        end
                                        if Tard_DrawMenu.DrawW:Value() and (TardIsRSpell(_W) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
                                            Tard_DrawCircle(Tard_EzrealPos, 1050, 1, Tard_DrawColor(255, 255, 255, 255))
                                        end
                                        if Tard_DrawMenu.DrawE:Value() and (TardIsRSpell(_E) == 0 or not Tard_DrawMenu.DrawReady:Value()) then
                                            Tard_DrawCircle(Tard_EzrealPos, 475, 1, Tard_DrawColor(255, 255, 255, 255))
                                        end
                                        if Tard_DrawMenu.DrawSpellTarget:Value() then
                                            if Tard_TardMenu.Misc.SelectedTarget:Value() and Tard_IsValidTarget(Tard_SelectedTarget) then
                                                Tard_DrawCircle(Tard_SelectedTarget.pos, 80, 3, Tard_DrawColor(255, 0, 0, 255))
                                            end
                                        end
                                    end
                                    )

LocalCallbackAdd                    ("Load", function()
                                        Tard_Menu()
                                        print("Hello ", Tard_myHero.name, ", TardEzreal v", Tard_version, " is ready to feed")
                                        if Tard_TardMenu.P.hpred:Value() and Tard_TardMenu.P.Epred == nil then HpredV = true; print("HPred loaded")
                                        elseif not Tard_TardMenu.P.hpred:Value() and Tard_TardMenu.P.Epred:Value() then 
                                            Tard_EternalPred = true
                                            require "Eternal Prediction"
                                            print("Tosh Pred loaded ;)")
                                            Tard_SpellstoPred = {
                                                [0] = Prediction:SetSpell(Tard_EzrealSpells[0], Tard_EzrealSpells[0].spellType, Tard_EzrealSpells[0].hitBox),
                                                [1] = Prediction:SetSpell(Tard_EzrealSpells[1], Tard_EzrealSpells[1].spellType, Tard_EzrealSpells[1].hitBox),
                                                [3] = Prediction:SetSpell(Tard_EzrealSpells[3], Tard_EzrealSpells[3].spellType, Tard_EzrealSpells[3].hitBox)
                                            }
                                        else print("Noddy's pred loaded")
                                        end
                                        if _G.EOWLoaded then Tard_Orb = 1 elseif _G.SDK and _G.SDK.Orbwalker then Tard_Orb = 2 elseif _G.__gsoOrbwalker then Tard_Orb = 3 end
                                        if Tard_Orb == 1 then print("New Eternal Orb is good but Tosh is still toxic ^^")
                                        elseif Tard_Orb == 2 then print("IC is a good Orb")
                                            Tard_SDK                    = SDK.Orbwalker
                                            Tard_SDKCombo               = SDK.ORBWALKER_MODE_COMBO
                                            Tard_SDKHarass              = SDK.ORBWALKER_MODE_HARASS
                                            Tard_SDKJungleClear         = SDK.ORBWALKER_MODE_JUNGLECLEAR
                                            Tard_SDKLaneClear           = SDK.ORBWALKER_MODE_LANECLEAR
                                            Tard_SDKLastHit             = SDK.ORBWALKER_MODE_LASTHIT
                                            Tard_SDKFlee                = SDK.ORBWALKER_MODE_FLEE
                                            Tard_SDKSelector            = SDK.TargetSelector
                                            Tard_SDKHealthPrediction    = SDK.HealthPrediction
                                            Tard_SDKDamagePhysical      = SDK.DAMAGE_TYPE_PHYSICAL
                                            Tard_SDKDamageMagical       = SDK.DAMAGE_TYPE_MAGICAL
                                        elseif Tard_Orb == 3 then print("gamsteronOrb Loaded by Gamsteron the Genius Dev")
                                            TardGSOOrbwalker            = __gsoOrbwalker()
                                            TardGSOGetTarget            = TardGSOOrbwalker.GetTarget
                                            TardGSOMode                 = TardGSOOrbwalker.Mode
                                            TardGSOObjects              = TardGSOOrbwalker.Objects
                                            TardGSOState                = TardGSOOrbwalker.State
                                            TardGSOHPPred = TardGSOOrbwalker.MinionHealthPrediction
                                        elseif Tard_Orb == 4 then
                                            if Orbwalker.Enabled:Value() then print("Noddy rocks")
                                            else Tard_Orb = 5; print("WARNING : you're not using any Orbwalker") end
                                        end
                                        for i = 0, 3 do
                                            if i == 0 then
                                                Tard_EzrealSpells[i].dmg =
                                                    function(unit)
                                                    local Tard_level = Tard_myHero:GetSpellData(0).level
                                                    return CalcPhysicalDamage(
                                                        Tard_myHero,
                                                        unit,
                                                        ({15, 40, 65, 90, 115})[Tard_level] + 1.1 * Tard_myHero.totalDamage + 0.4 * Tard_myHero.ap
                                                    )
                                                end
                                            elseif i == 1 then
                                                Tard_EzrealSpells[i].dmg = function(unit)
                                                    local Tard_level = Tard_myHero:GetSpellData(1).level
                                                    return CalcMagicalDamage(
                                                        Tard_myHero,
                                                        unit,
                                                        ({70, 115, 160, 205, 250})[Tard_level] + 0.8 * Tard_myHero.ap
                                                    )
                                                end
                                            elseif i == 3 then
                                                Tard_EzrealSpells[i].dmg = function(unit)
                                                    local Tard_level = Tard_myHero:GetSpellData(i).level
                                                    local Tard_initialdmg = ({350, 500, 650})[Tard_level] + 0.9 * Tard_myHero.ap + Tard_myHero.bonusDamage
                                                    local Tard_Collision
                                                    if HpredV then
                                                        local hitChance, Tard_RPred = GetHitchance(Tard_myHero.pos, unit, 20000, 1.76, 2000, 160, false)
                                                        if hitChance and hitChance >= Tard_TardMenu.P.AccuracyR:Value() and Tard_RPred then
                                                            Tard_Collision = mCollision(unit, 3, Tard_myHero.pos, Tard_RPred) + hCollision(unit, 3, Tard_myHero.pos, Tard_RPred)
                                                        end
                                                    elseif Tard_EternalPred then
                                                        local Tard_RPred = Tard_SpellstoPred[i]:GetPrediction(unit, Tard_myHero.pos)
                                                        Tard_Collision = mCollision(unit, 3, Tard_myHero.pos, Tard_RPred.castPos) + hCollision(unit, 3, Tard_myHero.pos, Tard_RPred.castPos)
                                                    else local Tard_RPred = GetPred(unit, 2000, 1.76 + TardLatency()*.001)
                                                        if Tard_RPred then
                                                            Tard_Collision = mCollision(unit, 3, Tard_myHero.pos, Tard_RPred) + hCollision(unit, 3, Tard_myHero.pos, Tard_RPred)
                                                        end
                                                    end
                                                    if Tard_Collision then
                                                        local Tard_nerf = (Tard_Collision ~= nil and TardMin(Tard_Collision, 7)) 
                                                        local Tard_finaldmg = Tard_initialdmg * ((10 - Tard_nerf) / 10)
                                                        return CalcMagicalDamage(Tard_myHero, unit, Tard_finaldmg)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    )
LocalCallbackAdd                    ("WndMsg", function(msg, wParam)
                                        if msg == WM_LBUTTONDOWN then
                                            if Tard_TardMenu.Misc.SelectedTarget:Value() then
                                                for i = 1, TardHeroCount() do
                                                    local H = TardHero(i)
                                                    if Tard_GetDistanceSqr(H.pos, _G.mousePos) <= 10000 then
                                                        if (H ~= nil and Tard_SelectedTarget ~= nil) and Tard_SelectedTarget.networkID == H.networkID then
                                                            Tard_SelectedTarget = nil
                                                        else
                                                            Tard_SelectedTarget = H
                                                        end
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    )
                                    
