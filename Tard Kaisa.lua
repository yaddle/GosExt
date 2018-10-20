if myHero.charName ~= "Kaisa" then return end
--<--declare variables-->--
local Tard_version, TotalmyBuffsName, _myBuffsName, GetmyBuffsName, _ITEM_1, _ITEM_2, _ITEM_3, _ITEM_4, _ITEM_5, _ITEM_6, _ITEM_7, _Item, DamageReductionTableMod, DamageReductionTablePlain, CalcPhysicalDamage, CalcMagicalDamage, DamageReductionMod, MyHeroBuffDmgMod, GeneralBuffDmgMod, PassivePercentMod, GetWDamage, _OnWaypoint, _OnVision, Tard_Load, castSpell, variableTimer, variableTimer2, visionTick, champRecache, champRecacheTimeOut, MYTEAM, ENEMYTEAM, TCount, TCount2, W, mylvlR, mylvlQ, mylvlW, mylvl, EvolvedQ, Menu_DEBUG, Menu_C_enemyClose, Menu_H_enemyClose, DisableAA, LocalUtilities, LocalTargetSelector, LocalOrbwalker, AD, AP, GetMode, ExtLibEvade, CheckEnemyList, EnemylistDone, MenuDrawQUse,MenuDrawQWidth, MenuDrawQColor, MenuDrawWUse,MenuDrawWWidth, MenuDrawWColor, MenuDrawPassive, MenuDrawKillable, MenuKillsteal, DrawSpell, DrawPassive_or_Killable, passive, killable, GetQDamage, _passiveMarker, _killbill, HasPassive_or_Killable, UpdateVariables, Menu, _EnemyHeroes, TotalEnemy, GetDistanceSqr, GetEnemyHeroes, IsImmobileTarget, GetTarget, BlockSpells, minionCollision, VectorPointProjectionOnLineSegment, CastSpell, CastSpellonMAP, OnVision, OnVisionF, GetDistance2D, OnWaypoint, GetPred, _localosclock, myHeroPos, Menu_Mode, _minionNear, MinionNear, readyQ, readyW, readyE, readyR, CantAA, myMana, _Mode, myAD, myADbonus, myAP, myArmorPenPercent, myArmorPen, mybonusArmorPenPercent, myMagicPen, myMagicPenPercent;
--</--declare variables--\>--
--<--Localise GOS API-->--
local myHero                            = myHero
local LocalGameHeroCount                = Game.HeroCount
local LocalGameHero                     = Game.Hero
local LocalMinionCount                  = Game.MinionCount
local LocalMinion                       = Game.Minion
local LocalGameIsChatOpen               = Game.IsChatOpen
local LocalGameIsOnTop                  = Game.IsOnTop
local CanUseSpell                       = Game.CanUseSpell
local LocalTickCount                    = GetTickCount
local Latency                           = Game.Latency
local GameTimer                         = Game.Timer
local Localosclock                      = os.clock
local ControlSetCursorPos               = Control.SetCursorPos
local ControlKeyDown                    = Control.KeyDown
local ControlKeyUp                      = Control.KeyUp
local ControlCastSpell                  = Control.CastSpell
local LocalCallbackAdd                  = Callback.Add
local DrawCircle, DrawText, DrawColor   = Draw.Circle, Draw.Text, Draw.Color
local sqrt                              = math.sqrt
--</--Localise GOS API--\>--

local Tard_Combo                        = function()
                                            local MENU = Menu_Mode.Combo
                                            local target = GetTarget(3000)
                                            if target then
                                                local delay, menu = .6 + Latency()*.001, MENU.CW
                                                local aim = menu.Enabled:Value() and readyW and myMana > menu.Mana:Value() and GetPred(target, 1750, delay)
                                                if aim and minionCollision(target, myHeroPos, aim) == 0 then
                                                    if aim:To2D().onScreen == true then
                                                        readyW = nil
                                                        return CastSpell(HK_W, aim, 3000, delay*1000)
                                                    else
                                                        readyW = nil
                                                        return CastSpellonMAP(HK_W, aim, 3000, delay*1000)
                                                    end
                                                end
                                            end

                                            target = target == true and target.distance < 650 or GetTarget(650)
                                            if target then
                                                local menu = MENU.CQ
                                                if menu.Enabled:Value() and readyQ and menu.Mana:Value() < myMana then
                                                    if Menu_C_enemyClose and _minionNear == true then return
                                                    else
                                                        readyQ = nil
                                                        return ControlCastSpell(HK_Q)
                                                    end
                                                end
                                            end
                                            target = target == true and target.distance < 525 or GetTarget(525)
                                            if target then
                                                local menu = MENU.CE
                                                if  menu.Enabled:Value() and readyE and menu.Mana:Value() < myMana then
                                                    readyE = nil
                                                    return ControlCastSpell(HK_E)
                                                end
                                            end
                                        end

local Tard_Harass                       = function()
                                            local MENU = Menu_Mode.Harass
                                            local target = GetTarget(3000)
                                            if target then
                                                local delay, menu = .6 + Latency()*.001, MENU.HW
                                                local aim = menu.Enabled:Value() and readyW and myMana > menu.Mana:Value() and GetPred(target, 1750, delay)
                                                if aim and minionCollision(target, myHeroPos, aim) == 0 then
                                                    if aim:To2D().onScreen == true then
                                                        readyW = nil
                                                        return CastSpell(HK_W, aim, 3000, delay*1000)
                                                    else
                                                        readyW = nil
                                                        return CastSpellonMAP(HK_W, aim, 3000, delay*1000)
                                                    end
                                                end
                                            end

                                            target = target == true and target.distance < 650 or GetTarget(650)
                                            if target then
                                                local menu = MENU.HQ
                                                if menu.Enabled:Value() and readyQ and menu.Mana:Value() < myMana  then
                                                    if Menu_H_enemyClose and _minionNear == true then return
                                                    else
                                                        readyQ = nil
                                                        return ControlCastSpell(HK_Q)
                                                    end
                                                end
                                            end
                                        end

local Tard_Tick                         = function()
                                            if not EnemylistDone then CheckEnemyList() return end
                                            if BlockSpells() then return end
                                            UpdateVariables()
                                            DisableAA()
                                            OnVisionF()
                                            _Mode = not CantAA and _Mode == 0 and Tard_Combo() or not CantAA and _Mode == 1 and Tard_Harass()
                                        end

local Tard_Draw                         = function()
                                            DrawPassive_or_Killable()
                                            DrawSpell()
                                        end

HasPassive_or_Killable                  = function()
                                            _passiveMarker, _killbill = {}, {}
                                            if not readyR and not readyW then return end
                                            for i = 1, TotalEnemy do
                                                local enemy = _EnemyHeroes[i]
                                                if enemy.isTargetable and enemy.visible and not enemy.dead then
                                                    local d = enemy.distance
                                                    if LocalUtilities.UndyingBuffs[enemy.charName] == nil and d > 625 and d < 3000 then
                                                        local delay = .6 + Latency()*.001
                                                        local dmg = MenuKillsteal and readyW and GetWDamage(enemy)
                                                        local aim = dmg and dmg > enemy.health+enemy.shieldAD+enemy.shieldAP and GetPred(enemy, 1750, delay)
                                                        if aim and minionCollision(enemy, myHeroPos, aim) == 0 then
                                                            if Menu_DEBUG then print("[Tard Kaisa] : Trying to KS : " .. enemy.charName .. " for " .. dmg .. " dmgs.") end
                                                            if aim:To2D().onScreen == true then
                                                                readyW = nil
                                                                return CastSpell(HK_W, aim, 3000, delay*1000)
                                                            else
                                                                readyW = nil
                                                                return CastSpellonMAP(HK_W, aim, 3000, delay*1000)
                                                            end
                                                        end
                                                    end

                                                    if d < mylvlR and readyR and not enemy.dead then
                                                        if GotBuff(enemy, "kaisapassivemarkerr") == 1 then
                                                            _passiveMarker[TCount] = enemy
                                                            TCount = TCount + 1
                                                            if GetQDamage(enemy) > enemy.health+enemy.shieldAD+enemy.shieldAP then
                                                                _killbill[TCount2] = enemy
                                                                TCount2 = TCount2 + 1
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            TCount, TCount2 = 1, 1
                                            return #_passiveMarker, #_killbill
                                        end

GetQDamage                              = function(target)
                                            return CalcPhysicalDamage(target, mylvlQ)
                                        end

GetWDamage                              = function(target)
                                            return CalcMagicalDamage(target, mylvlW)
                                        end

DisableAA                               = function()
                                            if myHero.activeSpell.name == "KaisaE" then
                                                return LocalOrbwalker:SetAttack(false)
                                            else
                                                return LocalOrbwalker:SetAttack(true)
                                            end
                                        end

DrawPassive_or_Killable                 = function()
                                            if MenuDrawPassive and passive and passive > 0 then
                                                for i = 1, passive do
                                                    local markedtarget = _passiveMarker[i]
                                                    local pos = markedtarget.visible and myHero.pos2D
                                                    if pos then
                                                        DrawText(markedtarget.charName .. " is Marked", 20, pos.x - 100, pos.y + 50 + (i-1)*25 , DrawColor(0, 0, 0, 0))
                                                    end
                                                end
                                            end
                                            if MenuDrawKillable and killable and killable > 0 then
                                                for i = 1, killable do
                                                    local killabletarget = _killbill[i]
                                                    local pos = killabletarget.visible and myHero.pos2D
                                                    if pos then
                                                        DrawText(killabletarget.charName .. " is KILLABLE Q+R", 30, pos.x - 100, pos.y + 75 + (i-1)*25, DrawColor(200, 255, 0, 0))
                                                    end
                                                end
                                            end
                                        end

DrawSpell                               = function()
                                            if MenuDrawQUse then
                                                DrawCircle(myHero.pos, 650, MenuDrawQWidth, MenuDrawQColor)
                                            end

                                            if MenuDrawWUse then
                                                DrawCircle(myHero.pos, 3000, MenuDrawWWidth, MenuDrawWColor)
                                            end
                                        end

CheckEnemyList                          = function()
                                            TotalEnemy = GetEnemyHeroes()
                                            if not TotalEnemy or TotalEnemy == 0 then
                                                print('[Tard Kaisa] : creating EnemyList, you have to wait ' .. champRecacheTimeOut - os.clock() + champRecache .. 'sec before use')
                                                return true
                                            else
                                                for i = 1, TotalEnemy do
                                                    print("[Tard Kaisa] : You are facing : [" .. i .."] " .. _EnemyHeroes[i].charName)
                                                end
                                                print('[Tard Kaisa] : EnemyList is created, all should work fine.')
                                                EnemylistDone = true
                                                return false
                                            end
                                        end

UpdateVariables                         = function()
                                            _localosclock = Localosclock()
                                            if _localosclock - variableTimer > .15 then
                                                local myHero = myHero
                                                myHeroPos = myHero.pos
                                                _minionNear = (Menu_C_enemyClose or Menu_H_enemyClose) and MinionNear() or nil
                                                readyQ = CanUseSpell(0) == 0
                                                readyW = CanUseSpell(1) == 0
                                                readyE = CanUseSpell(2) == 0
                                                readyR = CanUseSpell(3) == 0
                                                CantAA = myHero.attackData.state == 2 or nil
                                                myMana = myHero.mana / myHero.maxMana * 100
                                                _Mode = GetMode()
                                                passive, killable = HasPassive_or_Killable()
                                                TotalmyBuffsName = GetmyBuffsName()
                                                if _localosclock - variableTimer2 > 10 then
                                                    local menuDraw = Menu.Drawings
                                                    Menu_Mode = Menu.Mode
                                                    Menu_C_enemyClose = Menu.Mode.Combo.CQ.enemyClose:Value() or nil
                                                    Menu_H_enemyClose = Menu.Mode.Harass.HQ.enemyClose:Value() or nil
                                                    Menu_DEBUG = menuDraw.debug:Value()
                                                    MenuDrawQUse = menuDraw.Range.Q.Enabled:Value()
                                                    MenuDrawQWidth = menuDraw.Range.Q.Width:Value()
                                                    MenuDrawQColor = menuDraw.Range.Q.Color:Value()
                                                    MenuDrawWUse = menuDraw.Range.W.Enabled:Value()
                                                    MenuDrawWWidth = menuDraw.Range.W.Width:Value()
                                                    MenuDrawWColor = menuDraw.Range.W.Color:Value()
                                                    MenuDrawPassive = menuDraw.Vision.Rpassive:Value()
                                                    MenuDrawKillable = menuDraw.Vision.Rkill:Value()
                                                    MenuKillsteal = Menu_Mode.KS:Value()
                                                    _Item = GetItemSlot(myHero, 3036) > 0 and 1 or GetItemSlot(myHero, 3036) > 0 and 2 or nil
                                                    --mylvl = myHero.levelData.lvl
                                                    myAD = myHero.totalDamage
                                                    myADbonus = myHero.bonusDamage
                                                    myAP = myHero.ap
                                                    myArmorPenPercent = myHero.armorPenPercent
                                                    myArmorPen = myHero.armorPen
                                                    mybonusArmorPenPercent = myHero.bonusArmorPenPercent
                                                    myMagicPen = myHero.magicPen
                                                    myMagicPenPercent = myHero.magicPenPercent
                                                    EvolvedQ = myADbonus >= 100
                                                    --EvolvedQ = myADbonus - (100 - 1.7 * (mylvl - 1 ) * (0.7025 + 0.0175 * (mylvl - 1))) >= 0 or nil
                                                    mylvlQ = myHero:GetSpellData(0).level
                                                    if not EvolvedQ then
                                                        mylvlQ = mylvlQ == 1 and 112.5 + .875 * myADbonus + myAP or mylvlQ == 2 and 152.125 + .875 * myADbonus + myAP or mylvlQ == 3  and 193.75 + .875 * myADbonus + myAP or mylvlQ == 4 and 234.375 + .875 * myADbonus + myAP or mylvlQ == 5 and 275 + .875 * myADbonus + myAP or 0
                                                    else
                                                        mylvlQ = mylvlQ == 1 and 166.5 + 1.295 * myADbonus + 148 * myAP or mylvlQ == 2 and 226.625 + 1.295 * myADbonus + 1.48 * myAP or mylvlQ == 3 and 286.75 + 1.295 * myADbonus + 1.48 * myAP or mylvlQ == 4 and 346.875 + 1.295 * myADbonus + 1.48 * myAP or mylvlQ == 5 and 407 + 1.295 * myADbonus + 1.48 * myAP or 0
                                                    end
                                                    mylvlW = myHero:GetSpellData(1).level
                                                    mylvlW = mylvlW > 0 and (mylvlW * 25 - 5 + myAD * 1.5 + myAP * .6)/2 or 0
                                                    mylvlR = myHero:GetSpellData(3).level
                                                    mylvlR = mylvlR == 1 and 1500 or mylvlR == 2 and 2000 or mylvlR == 3 and 2500 or 0
                                                    variableTimer2 = _localosclock
                                                end
                                                variableTimer = _localosclock
                                            end
                                        end

GetMode                                 = function()
                                            local Modes = LocalOrbwalker.Modes
                                            return Modes and (Modes[0] and 0 or Modes[1] and 1 or (Modes[3] or Modes[2]) and 3 or Modes[4] and 2)
                                        end

LocalCallbackAdd                        ("Tick", function() Tard_Tick() end)
LocalCallbackAdd                        ("Draw", function() Tard_Draw() end)
LocalCallbackAdd                        ("Load", function() Tard_Load() end)

Menu = MenuElement({type = MENU, id = "Kaisa", name = "Tard_Kaisa", leftIcon  = "http://pbs.twimg.com/media/DW2ORQHW0AApkfw.png"})
Menu:MenuElement({id = "Mode", name = "Mode", type = MENU})
Menu.Mode:MenuElement({id = "Combo", name = "Combo", type = MENU})
Menu.Mode.Combo:MenuElement({id = "CQ", name = "Q settings", type = MENU})
Menu.Mode.Combo.CQ:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Mode.Combo.CQ:MenuElement({id = "Mana", name = "Mana Limit", value = 20, min = 5, max = 100, step = 5, tooltip = "it's a %"})
Menu.Mode.Combo.CQ:MenuElement({id = "enemyClose", name = "Use only if no minions", value = true})

Menu.Mode.Combo:MenuElement({id = "CW", name = "W settings", type = MENU})
Menu.Mode.Combo.CW:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Mode.Combo.CW:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 5, max = 100, step = 5, tooltip = "it's a %"})

Menu.Mode.Combo:MenuElement({id = "CE", name = "E settings", type = MENU})
Menu.Mode.Combo.CE:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Mode.Combo.CE:MenuElement({id = "Mana", name = "Mana Limit", value = 25, min = 5, max = 100, step = 5, tooltip = "it's a %"})

Menu.Mode:MenuElement({id = "Harass", name = "Harass", type = MENU})
Menu.Mode.Harass:MenuElement({id = "HQ", name = "Q settings", type = MENU})
Menu.Mode.Harass.HQ:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Mode.Harass.HQ:MenuElement({id = "Mana", name = "Mana Limit", value = 40, min = 5, max = 100, step = 5, tooltip = "it's a %"})
Menu.Mode.Harass.HQ:MenuElement({id = "enemyClose", name = "Use only if no minions", value = true})

Menu.Mode.Harass:MenuElement({id = "HW", name = "W settings", type = MENU})
Menu.Mode.Harass.HW:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Mode.Harass.HW:MenuElement({id = "Mana", name = "Mana Limit", value = 50, min = 5, max = 100, step = 5, tooltip = "it's a %"})

Menu.Mode:MenuElement({id = "KS", name = "Killsteal with W", value = true})

Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
Menu.Drawings:MenuElement({id="Range", name = "Range", type = MENU})
Menu.Drawings:MenuElement({id="Vision", name = "Vision", type = MENU})

Menu.Drawings.Range:MenuElement({id = "Q", name = "Draw Q range", type = MENU})
Menu.Drawings.Range.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Drawings.Range.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
Menu.Drawings.Range.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})

Menu.Drawings.Range:MenuElement({id = "W", name = "Draw W range", type = MENU})
Menu.Drawings.Range.W:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu.Drawings.Range.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
Menu.Drawings.Range.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})

Menu.Drawings.Vision:MenuElement({id = "Rpassive", name = "Draw Text if some targets are marked", value = true})
Menu.Drawings.Vision:MenuElement({id = "Rkill", name = "Draw Text if can kill targets", value = true})
Menu.Drawings:MenuElement({id = "debug", name = "Draw Text if script try to ks with W", value = true})

Menu:MenuElement({name = '         ', drop = {'Tard_Version : 1.0.0'}})


GetDistance2D                           = function(p1,p2)
                                            return sqrt((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y))
                                        end

GetDistanceSqr                          = function(p1, p2)
                                                p2 = p2 or myHero
                                                p1 = p1.pos or p1
                                                p2 = p2.pos or p2


                                                local dx, dz = p1.x - p2.x, p1.z - p2.z
                                                return dx * dx + dz * dz
                                        end

GetEnemyHeroes                          = function()
                                            _EnemyHeroes = {}
                                            for i = 1, LocalGameHeroCount() do
                                                local Hero = LocalGameHero(i)
                                                if Hero.team ~= MYTEAM then
                                                    _EnemyHeroes[TCount] = Hero
                                                    TCount = TCount + 1
                                                end
                                            end
                                            TCount = 1
                                            return #_EnemyHeroes
                                        end

GetTarget                               = function(range)
                                            if myAP < myAD then
                                                return LocalTargetSelector:GetTarget(range, AD)
                                            else
                                                return LocalTargetSelector:GetTarget(range, AP)
                                            end
                                        end

BlockSpells                             = function()
                                            if ExtLibEvade and ExtLibEvade.Evade then
                                                print("[Tard Kaisa] : it's evading")
                                                return true
                                            elseif LocalGameIsChatOpen() then
                                                return true
                                            elseif not LocalGameIsOnTop() then
                                                return true
                                            end
                                        end

minionCollision                         = function(target, me, position)
                                            local counter = 0
                                            for i = LocalMinionCount(), 1, -1 do
                                                local minion = LocalMinion(i)
                                                if minion.visible and minion.isTargetable and minion.team == ENEMYTEAM and minion.dead == false then
                                                    local linesegment, line, isOnSegment = VectorPointProjectionOnLineSegment(me, position, minion.pos)
                                                    if linesegment and isOnSegment and (GetDistanceSqr(minion.pos, linesegment) < (minion.boundingRadius + W.Width) * (minion.boundingRadius + W.Width)) then
                                                        counter = counter + 1
                                                    end
                                                end
                                            end
                                            return counter
                                        end

VectorPointProjectionOnLineSegment      = function(v1, v2, v)
                                            local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
                                            local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
                                            local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
                                            local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
                                            local isOnSegment = rS == rL
                                            local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
                                            return pointSegment, pointLine, isOnSegment
                                        end

MinionNear                              = function()
                                            for i = 1, LocalMinionCount() do
                                                if LocalMinion(i).distance < 650 then
                                                    return true
                                                end
                                            end
                                            return false
                                        end

GetmyBuffsName                          = function()
                                            _myBuffsName = {}
                                            for i = 0, myHero.buffCount do
                                                local buff = myHero:GetBuff(i)
                                                _myBuffsName[TCount] = buff.name
                                                TCount = TCount + 1
                                            end
                                            TCount = 1
                                            return #_myBuffsName
                                        end

---------------------------------------------------------<<NODDY FUNCTIONS, thx to him <3 >>--------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CastSpell                               = function(spell,pos,range,delay)
                                            local range = range or 20000
                                            local delay = delay or 250
                                            local ticker = LocalTickCount()

                                            if castSpell.state == 0 and pos:DistanceTo() < range and ticker - castSpell.casting > delay + Latency() then
                                                castSpell.state = 1
                                                castSpell.mouse = mousePos
                                                castSpell.tick = ticker
                                            end
                                            if castSpell.state == 1 then
                                                if ticker - castSpell.tick < Latency() then
                                                    ControlSetCursorPos(pos)
                                                    ControlKeyDown(spell)
                                                    ControlKeyUp(spell)
                                                    castSpell.casting = ticker + delay
                                                    DelayAction(function()
                                                        if castSpell.state == 1 then
                                                            ControlSetCursorPos(castSpell.mouse)
                                                            castSpell.state = 0
                                                        end
                                                    end,Latency()*.001)
                                                end
                                                if ticker - castSpell.casting > Latency() then
                                                    ControlSetCursorPos(castSpell.mouse)
                                                    castSpell.state = 0
                                                end
                                            end
                                        end

CastSpellonMAP                          = function(spell, pos, range, delay)
                                            local range = range or 25000
                                            local delay = delay or 250
                                            local ticker = LocalTickCount()

                                            if castSpell.state == 0 and pos:DistanceTo() < range and ticker - castSpell.casting > delay + Latency() then
                                                castSpell.state = 1
                                                castSpell.mouse = mousePos
                                                castSpell.tick = ticker
                                            end
                                            if castSpell.state == 1 then
                                                if ticker - castSpell.tick < Latency() then
                                                    local castPosMM = pos:ToMM()
                                                    ControlSetCursorPos(castPosMM.x,castPosMM.y)
                                                    ControlKeyDown(spell)
                                                    ControlKeyUp(spell)
                                                    castSpell.casting = ticker + delay
                                                    DelayAction(function()
                                                        if castSpell.state == 1 then
                                                            ControlSetCursorPos(castSpell.mouse)
                                                            castSpell.state = 0
                                                        end
                                                    end,Latency()*.001)
                                                end
                                                if ticker - castSpell.casting > Latency() then
                                                    ControlSetCursorPos(castSpell.mouse)
                                                    castSpell.state = 0
                                                end
                                            end
                                        end

OnVision                                = function(unit)
                                            _OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible, tick = LocalTickCount(), pos = unit.pos} or _OnVision[unit.networkID]
                                            if _OnVision[unit.networkID].state == true and not unit.visible then
                                                _OnVision[unit.networkID].state = false
                                                _OnVision[unit.networkID].tick = LocalTickCount()
                                            end
                                            if _OnVision[unit.networkID].state == false and unit.visible then
                                                _OnVision[unit.networkID].state = true
                                                _OnVision[unit.networkID].tick = LocalTickCount()
                                            end
                                            return _OnVision[unit.networkID]
                                        end

OnVisionF                               = function()
                                            local ticker = LocalTickCount()
                                            if ticker - visionTick > 100 then
                                                for i = 1, TotalEnemy do
                                                    OnVision(_EnemyHeroes[i])
                                                end
                                                visionTick = ticker
                                            end
                                        end

OnWaypoint                              = function(unit)
                                            if _OnWaypoint[unit.networkID] == nil then _OnWaypoint[unit.networkID] = {pos = unit.posTo , speed = unit.ms, time = GameTimer()} end
                                            if _OnWaypoint[unit.networkID].pos ~= unit.posTo then
                                                -- print("OnWayPoint:"..unit.charName.." | "..math.floor(Game.Timer()))
                                                _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = Game.Timer()}
                                                    DelayAction(function()
                                                        local time = (GameTimer() - _OnWaypoint[unit.networkID].time)
                                                        local speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(GameTimer() - _OnWaypoint[unit.networkID].time)
                                                        if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and sqrt(GetDistanceSqr(unit.pos,_OnWaypoint[unit.networkID].pos)) > 200 then
                                                            _OnWaypoint[unit.networkID].speed = GetDistance2D(_OnWaypoint[unit.networkID].startPos,unit.pos)/(GameTimer() - _OnWaypoint[unit.networkID].time)
                                                            -- print("OnDash: "..unit.charName)
                                                        end
                                                    end,.05)
                                            end
                                            return _OnWaypoint[unit.networkID]
                                        end

IsImmobileTarget                        = function(unit)
                                            for i = 0, unit.buffCount do
                                                local buff = unit:GetBuff(i)
                                                if buff and (buff.type == 5 or buff.type == 8 or buff.type == 11 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 29 or buff.type == 30 or buff.type == 39 or buff.name == "recall") and buff.count > 0 then
                                                    return true
                                                end
                                            end
                                            return false
                                        end

GetPred                                 = function(unit,speed,delay)
                                            local speed = speed or 20000
                                            local delay = delay or 0.25
                                            local unitSpeed = unit.ms
                                            local unitPosition, unitPosTo = unit.pos, unit.posTo
                                            if OnWaypoint(unit).speed > unitSpeed then unitSpeed = OnWaypoint(unit).speed end
                                            if OnVision(unit).state == false then
                                                local unitPos = unitPosition + Vector(unitPosition,unitPosTo):Normalized() * ((LocalTickCount() - OnVision(unit).tick)*.001 * unitSpeed)
                                                local predPos = unitPos + Vector(unitPosition,unitPosTo):Normalized() * (unitSpeed * (delay + (unitPos:DistanceTo()/speed)))
                                                if GetDistanceSqr(unitPosition,predPos) > GetDistanceSqr(unitPosition,unitPosTo) then predPos = unitPosTo end
                                                return predPos
                                            else
                                                if unitSpeed > unit.ms then
                                                    local predPos = unitPosition + Vector(OnWaypoint(unit).startPos,unitPosTo):Normalized() * (unitSpeed * (delay + (unit.distance/speed)))
                                                    if GetDistanceSqr(unitPosition,predPos) > GetDistanceSqr(unitPosition,unitPosTo) then predPos = unitPosTo end
                                                    return predPos
                                                elseif IsImmobileTarget(unit) or unitPosition == unitPosTo then
                                                    return unitPosition
                                                else
                                                    return unit:GetPrediction(speed,delay)
                                                end
                                            end
                                        end
---------------------------------------------------------<<NODDY FUNCTIONS, thx to him <3 >>--------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------<<LOCALISED DMG LIB>>--------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DamageReductionTableMod                 = {
                                            ["Braum"] = {buff = "BraumShieldRaise", amount = function(target) return 1 - ({0.3, 0.325, 0.35, 0.375, 0.4})[target:GetSpellData(_E).level] end},
                                            ["Urgot"] = {buff = "UrgotSwapDef", amount = function(target) return 1 - ({0.3, 0.4, 0.5})[target:GetSpellData(_R).level] end},
                                            ["Alistar"] = {buff = "FerociousHowl", amount = function(target) return ({0.5, 0.4, 0.3})[target:GetSpellData(_R).level] end},
                                            ["Galio"] = {buff = "GalioIdolOfDurand", amount = function(target) return 0.5 end},
                                            ["Garen"] = {buff = "GarenW", amount = function(target) return 0.7 end},
                                            ["Gragas"] = {buff = "GragasWSelf", amount = function(target) return ({0.1, 0.12, 0.14, 0.16, 0.18})[target:GetSpellData(_W).level] end},
                                            ["Annie"] = {buff = "MoltenShield", amount = function(target) return 1 - ({0.16,0.22,0.28,0.34,0.4})[target:GetSpellData(_E).level] end},
                                            ["Malzahar"] = {buff = "MalzaharPassiveShield", amount = function(target) return 0.1 end},
                                            ["Warwick"] = {buff = "Warwicke", amount = function(target) return (1-(0.35+(target:GetSpellData(_E).level-1)*0.05)) end},
                                            ["Shen"] = {buff = "Shen Shadow Dash", amount = function(target) return 0.5 end},
                                            ["Rammus"] = {buff = "taunt", amount = function(target) return 0.5 end},
                                            ["Lissandra"] = {buff = "LissandraRSelf", amount = function(target) return 0 end},
                                            ["Tryndamere"] = {buff = "UndyingRage", amount = function(target) return 0 end}
                                        }

DamageReductionTablePlain               = {
                                            ["Amumu"] = {buff = "Tantrum", amount = function(target) return ({2, 4, 6, 8, 10})[target:GetSpellData(_E).level] end, damageType = 1},
                                            ["Diana"] = {buff = "DianaShield", amount = function(target) return (40+(target:GetSpellData(_W).level-1)*15+target.ap*0.3) end},
                                            ["Riven"] = {buff = "RivenFeint", amount = function(target) return (95+(target:GetSpellData(_E).level-1)*30+target.bonusDamage) end},
                                            ["Ryze"] = {buff = "RyzeQShield", amount = function(target) return (90+(target:GetSpellData(_Q).level-1)*30+target.ap*0.6+(target.maxMana-800)*0.03) end},
                                            ["Sona"] = {buff = "SonaWShield", amount = function(target) return (25+(target:GetSpellData(_W).level-1)*25+target.ap*0.3) end},
                                            ["Udyr"] = {buff = "UdyrTurtleActivation", amount = function(target) return (60+(target:GetSpellData(_W).level-1)*35+target.ap*0.5) end},
                                            ["Victor"] = {buff = "VictorPowerTransfer", amount = function(target) return (23+(target.levelData.lvl-1)*4+target.ap*0.16) end},
                                            ["Vi"] = {buff = "ViWProc", amount = function(target) return (target.maxHealth*0.1) end}
                                        }

CalcPhysicalDamage                      = function(target, amount)
                                            local ArmorPenFlat = (0.4 + target.levelData.lvl / 30) * myArmorPen
                                            local armor = target.armor
                                            local bonusArmor = target.bonusArmor
                                            local value = 100 / (100 + (armor * myArmorPenPercent) - (bonusArmor * (1 - mybonusArmorPenPercent)) - ArmorPenFlat)
                                            if armor < 0 then
                                                value = 2 - 100 / (100 - armor)
                                            elseif (armor * myArmorPenPercent) - (bonusArmor * (1 - mybonusArmorPenPercent)) - ArmorPenFlat < 0 then
                                                value = 1
                                            end
                                            return math.max(0, math.floor(DamageReductionMod(target, PassivePercentMod(target, value, 1) * amount, 1)))
                                        end

CalcMagicalDamage                       = function(target, amount)
                                            local mr = target.magicResist
                                            local value = 100 / (100 + (mr * myMagicPenPercent) - myMagicPen)
                                            if mr < 0 then
                                                value = 2 - 100 / (100 - mr)
                                            elseif (mr * myMagicPenPercent) - myMagicPen< 0 then
                                                value = 1
                                            end
                                            return math.max(0, math.floor(DamageReductionMod(target, PassivePercentMod(target, value) * amount, 2)))
                                        end

DamageReductionMod                      = function(target,amount,DamageType)
                                            if TotalmyBuffsName and TotalmyBuffsName > 0 then
                                                for i = 1, TotalmyBuffsName do
                                                        local buff =_myBuffsName[i]
                                                        amount = MyHeroBuffDmgMod(amount, buff, DamageType)
                                                end
                                            end
                                            for i = 0, target.buffCount do
                                                if target:GetBuff(i).count > 0 then
                                                    local buff = target:GetBuff(i)
                                                    if target and DamageReductionTablePlain[target.charName] then
                                                        if buff.name == DamageReductionTablePlain[target.charName].buff and (not DamageReductionTablePlain[target.charName].damagetype or DamageReductionTablePlain[target.charName].damagetype == DamageType) and amount > 0 then
                                                            amount = amount - DamageReductionTablePlain[target.charName].amount(target)
                                                        end
                                                    end
                                                    if target and DamageReductionTableMod[target.charName] then
                                                        if buff.name == DamageReductionTableMod[target.charName].buff and (not DamageReductionTableMod[target.charName].damagetype or DamageReductionTableMod[target.charName].damagetype == DamageType) then
                                                            amount = amount * DamageReductionTableMod[target.charName].amount(target)
                                                        end
                                                    end
                                                    amount = GeneralBuffDmgMod(amount, buff, target, DamageType)
                                                    if target.charName == "MasterYi" then
                                                        if buff.name == "Meditate" then
                                                            return amount - amount * ({0.5, 0.55, 0.6, 0.65, 0.7})[target:GetSpellData(_W).level]
                                                        end
                                                    end
                                                end
                                            end
                                            if target.charName == "Kassadin" and DamageType == 2 then
                                                amount = amount * 0.85
                                            end
                                            return amount
                                        end

MyHeroBuffDmgMod                        = function(amount, buff)
                                            amount = amount and buff.name == "SummonerExhaustDebuff" and amount*0.6 or
                                                    buff.name == "ItemSmiteChallenge" and amount*0.8 or
                                                    buff.name == "ItemPhantomDancerDebuff" and amount*0.88 or amount
                                            return amount
                                        end

GeneralBuffDmgMod                       = function(amount, buff, target)
                                            if buff.name == "JudicatorIntervention" then return 0 end
                                            if buff.name == "KindredRNoDeathBuff" then return 0 end
                                            if buff.name == "TaricR" then return 0 end
                                            if buff.type == 17 and buff.count > 0 then -- intervention etc
                                                return 0
                                            end
                                            if buff.type == 15 and buff.count > 0 then -- parry etc
                                                return 0
                                            end
                                            if buff.type == 4 and buff.count > 0 then -- sivir spellshield etc
                                                return 0
                                            end
                                            if buff.type == 2 and buff.count > 1 then --  general shields
                                                return amount-buff.count
                                            end
                                            if buff.name == "MasteryWardenOfTheDawn" then
                                            return amount * (1 - (0.06 * buff.count))
                                            end
                                            if string.find(buff.name:lower(), "presstheattackdamag") then -- a revoir
                                                return amount*(1.08  + (myHero.levelData.lvl-1)/18 * 0.04)
                                            end
                                        -- a revoir
                                            if (string.find(buff.name:lower(), "boneplating.lua") or string.find(buff.name:lower(), "boneplatingcd.lua") and buff.duration == 0) then
                                                return amount - (20 + (target.levelData.lvl-1)/18 * 30)
                                            end
                                            if buff.name == "SionWShieldStacks" then return amount-buff.count end
                                            return amount
                                        end

PassivePercentMod                       = function(target, amount, damageType)
                                            if _Item and myHero.maxHealth < target.maxHealth and damageType == 1 then
                                                local delta = target.maxHealth - myHero.maxHealth
                                                delta = delta < 2000 and delta or 2000
                                                amount = amount * (1 + delta / 200 * (_Item == 1 and 0.02 or 0.01))
                                            end
                                            return amount
                                        end

GetItemSlot                             = function(id)
                                            for i = _ITEM_1, _ITEM_7 do
                                                if myHero:GetItemData(i).itemID == id then
                                                    return i
                                                end
                                            end
                                            return 0
                                        end

---------------------------------------------------------<<LOCALISED DMG LIB>>--------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Tard_Load                               = function()
                                            --<--assigning variables-->--
                                            ExtLibEvade = _G.ExtLibEvade or nil
                                            LocalUtilities = _G.SDK.Utilities
                                            LocalTargetSelector = _G.SDK.TargetSelector
                                            LocalOrbwalker = _G.SDK.Orbwalker
                                            AD = _G.SDK.DAMAGE_TYPE_PHYSICAL
                                            AP = _G.SDK.DAMAGE_TYPE_MAGICAL
                                            W = {Range = 3000, Width = 100, Speed = 1750}
                                            TCount, TCount2 = 1, 1
                                            MYTEAM = myHero.team
                                            ENEMYTEAM = 300 - MYTEAM
                                            champRecacheTimeOut = _G.champRecacheTimeOut * .001
                                            champRecache = Localosclock()
                                            visionTick = LocalTickCount()
                                            variableTimer, variableTimer2 = Localosclock(), Localosclock()
                                            castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
                                            --mylvl = myHero.levelData.lvl
                                            mylvlR = myHero:GetSpellData(3).level
                                            mylvlW = myHero:GetSpellData(1).level
                                            mylvlQ = myHero:GetSpellData(0).level
                                            Menu_Mode = Menu.Mode
                                            Menu_C_enemyClose = Menu_Mode.Combo.CQ.enemyClose:Value() or nil
                                            Menu_H_enemyClose = Menu_Mode.Harass.HQ.enemyClose:Value() or nil
                                            MenuKillsteal = Menu_Mode.KS:Value()
                                            local menuDraw = Menu.Drawings
                                            Menu_DEBUG = menuDraw.debug:Value()
                                            MenuDrawQUse = menuDraw.Range.Q.Enabled:Value()
                                            MenuDrawQWidth = menuDraw.Range.Q.Width:Value()
                                            MenuDrawQColor = menuDraw.Range.Q.Color:Value()
                                            MenuDrawWUse = menuDraw.Range.W.Enabled:Value()
                                            MenuDrawWWidth = menuDraw.Range.W.Width:Value()
                                            MenuDrawWColor = menuDraw.Range.W.Color:Value()
                                            MenuDrawPassive = menuDraw.Vision.Rpassive:Value()
                                            MenuDrawKillable = menuDraw.Vision.Rkill:Value()
                                            _ITEM_1, _ITEM_2, _ITEM_3, _ITEM_4, _ITEM_5, _ITEM_6, _ITEM_7 = ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7
                                            myAD = myHero.totalDamage
                                            myADbonus = myHero.bonusDamage
                                            myAP = myHero.ap
                                            myArmorPenPercent = myHero.armorPenPercent
                                            myArmorPen = myHero.armorPen
                                            mybonusArmorPenPercent = myHero.bonusArmorPenPercent
                                            myMagicPen = myHero.magicPen
                                            myMagicPenPercent = myHero.magicPenPercent
                                            EvolvedQ = myADbonus >= 100
                                            _OnWaypoint, _OnVision = {}, {}
                                            --</--assigning variables--\>--
                                        end