if myHero.charName ~= "Kennen" then return end
require 'JADL'

--<--declare variables-->--
local CalcMagicalDamage, mylvlQ, mylvlW, GetMode, EnemiesAround, Color, BlockSpells, minionCollision, TotalEnemy, _EnemyHeroes, UpdateVariables,Menu, ExtLibEvade, LocalUtilities, LocalTargetSelector, LocalOrbwalker, AD, AP, TCount, MYTEAM, ENEMYTEAM, champRecacheTimeOut, champRecache, visionTick, variableTimer, variableTimer2, castSpell, _OnWaypoint, _OnVision,readyQ, readyW, readyR, CantAA, _Mode, myHeroPos, _localosclock, CheckEnemyList, EnemylistDone
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
local DrawCircle, DrawColor             = Draw.Circle, Draw.Color
local sqrt                              = math.sqrt

local HeroIcon                          = "http://i11.servimg.com/u/f11/16/33/77/19/kennen15.png"
local QIcon                             = "http://i11.servimg.com/u/f11/16/33/77/19/kennen10.png"
local WIcon                             = "http://i11.servimg.com/u/f11/16/33/77/19/kennen12.png"
local RIcon                             = "http://i11.servimg.com/u/f11/16/33/77/19/kennen14.png"

local Tard_Combo                        = function()
                                            local  target = GetTarget(1050)
                                            if not target then return end
                                            local d, hasbuff = target.distance, GotBuff(target, 'kennenmarkofstorm') == 1
                                            if Menu.Combo.UseW:Value() and readyW and d < 750 and hasbuff then
                                                readyW = nil
                                                return ControlCastSpell(HK_W)
                                            elseif Menu.Combo.UseQ:Value() and readyQ then
                                                local delay = .15 + Latency()*.001
                                                local aim = GetPred(target, 1700, delay)
                                                if minionCollision(target, myHero.pos, aim) == 0 and aim:DistanceTo() < 1050 then 
                                                    readyQ = nil
                                                    --return CastSpell(HK_Q, aim, 1050, delay*1000)
                                                    return ControlCastSpell(HK_Q, aim)
                                                end
                                            end
                                            if Menu.Combo.UseUltimate:Value() and readyR and d < 550 then
                                                if d > 480 and target.ms > myHero.ms then return end
                                                if EnemiesAround(550) >= Menu.Combo.UseRMini:Value() then
                                                    readyR = nil
                                                    ControlCastSpell(HK_R)
                                                elseif Menu.Combo.UseR1v1:Value() and (not readyQ or not readyW) and hasbuff then
                                                    readyR = nil
                                                    ControlCastSpell(HK_R)
                                                end
                                            end
                                        end

local Tard_Harass                       = function()
                                            local  target = GetTarget(1050)
                                            if not target then return end
                                            local d, hasbuff = target.distance, GotBuff(target, 'kennenmarkofstorm') == 1
                                            if Menu.Harass.UseW:Value() and readyW and d < 750 and hasbuff then
                                                readyW = nil
                                                return ControlCastSpell(HK_W)
                                            elseif Menu.Harass.UseQ:Value() and readyQ then
                                                local delay = .15 + Latency()*.001
                                                local aim = GetPred(target, 1700, delay)
                                                if minionCollision(target, myHero.pos, aim) == 0 and aim:DistanceTo() < 1050 then 
                                                    readyQ = nil
                                                    --return CastSpell(HK_Q, aim, 1050, delay*1000)
                                                    return ControlCastSpell(HK_Q, aim, 1050, delay*1000)
                                                end
                                            end
                                        end

local Tard_Clear                        = function()
                                            --if (not readyQ and not readyW) or myHero.activeSpell.valid then return end                                         
                                            for i = 1, LocalMinionCount() do
                                                local minion = LocalMinion(i)
                                                if minion.team ~= MYTEAM then  
                                                    local d = minion.distance
                                                    local mhealth = minion.health
                                                    if not minion.dead and minion.visible and minion.isTargetable then
                                                        if Menu.Lasthit.UseQ:Value() and readyQ and d < 1050 and minionCollision(minion, myHeroPos, minion.pos) == 1 and mylvlQ > 0 and mylvlQ > mhealth then
                                                            readyQ = nil
                                                            return ControlCastSpell(HK_Q, minion)
                                                        end
                                                        if Menu.Lasthit.UseW:Value() and readyW and d < 750 and mylvlW > 0 and mylvlW > mhealth and GotBuff(minion,'kennenmarkofstorm') == 1 then
                                                            readyW = nil
                                                            return ControlCastSpell(HK_W)
                                                        end
                                                    end
                                                end
                                            end
                                        end

local Killable                          = function()
                                            if (not readyQ and not readyW) or myHero.activeSpell.valid then return end
                                            for i = 1, TotalEnemy do
                                                local enemy = _EnemyHeroes[i]
                                                if enemy.dead or not enemy.visible or not enemy.isTargetable then return end
                                                local d, currentHealth = enemy.distance, enemy.health + enemy.shieldAD + enemy.shieldAP
                                                local Qdmg, Wdmg = d < 1050 and CalcMagicalDamage(myHero, enemy, mylvlQ), d < 750 and CalcMagicalDamage(myHero, enemy, mylvlW)
                                                if Menu.Killsteal.UseW:Value() and readyW and Wdmg and GotBuff(enemy, "kennenmarkofstorm") == 1 and currentHealth < Wdmg then
                                                    readyW = nil
                                                    return ControlCastSpell(HK_W)                 
                                                elseif Menu.Killsteal.UseW:Value() and readyQ and d < 1050 and currentHealth < Qdmg then
                                                    local delay = .15 + Latency()*.001
                                                    local aim = GetPred(enemy, 1700, delay)
                                                    if minionCollision(enemy, myHero.pos, aim) == 0 and aim:DistanceTo() < 1050 then 
                                                        readyQ = nil
                                                        --return CastSpell(HK_Q, aim, 1050, delay*1000)
                                                        return ControlCastSpell(HK_Q, aim)
                                                    end
                                                end
                                            end
                                        end

local Tard_Tick                         = function()
                                            if not EnemylistDone then CheckEnemyList() return end
                                            if BlockSpells() then return end
                                            UpdateVariables()
                                            OnVisionF()
                                            Killable()
                                            _Mode = not CantAA and _Mode == 0 and Tard_Combo() or not CantAA and _Mode == 1 and Tard_Harass()-- or (_Mode == 3 or _Mode == 2) and Tard_Clear() 
                                        end

local Tard_Draw                         = function()
                                            if myHero.dead then return end
                                            if Menu.Drawings.DrawQ:Value() then
                                                DrawCircle(myHero.pos, 1050, 2, Color)
                                            end
                                            if Menu.Drawings.DrawW:Value() then
                                                DrawCircle(myHero.pos, 750, 2, Color)
                                            end
                                            if Menu.Drawings.DrawR:Value() then
                                                DrawCircle(myHero.pos, 550, 2, Color)
                                            end
                                        end

UpdateVariables                         = function()
                                            _localosclock = Localosclock()
                                            if _localosclock - variableTimer > .15 then
                                                local myHero = myHero
                                                myHeroPos = myHero.pos
                                                readyQ = CanUseSpell(0) == 0
                                                readyW = CanUseSpell(1) == 0 or CanUseSpell(1) == 8
                                                readyR = CanUseSpell(3) == 0
                                                CantAA = myHero.attackData.state == 2 or nil
                                                _Mode = GetMode()
                                                if _localosclock - variableTimer2 > 10 then
                                                    myAD = myHero.totalDamage
                                                    myAP = myHero.ap
                                                    mylvlW = myHero:GetSpellData(1).level
                                                    mylvlW = mylvlW > 0 and mylvlW * 25 + 35 + myAP * .8 or 0
                                                    mylvlQ = myHero:GetSpellData(0).level
                                                    mylvlQ = mylvlQ > 0 and mylvlQ * 40 + 35 + .75 * myAP or 0
                                                    variableTimer2 = _localosclock
                                                end
                                                variableTimer = _localosclock
                                            end
                                        end

CheckEnemyList                          = function()
                                            TotalEnemy = GetEnemyHeroes()
                                            if not TotalEnemy or TotalEnemy == 0 then
                                                print('[Tard Kennen] : creating EnemyList, you have to wait ' .. champRecacheTimeOut - os.clock() + champRecache .. 'sec before use')
                                                return true
                                            else
                                                for i = 1, TotalEnemy do
                                                    print("[Tard Kennen] : You are facing : [" .. i .."] " .. _EnemyHeroes[i].charName)
                                                end
                                                print('[Tard Kennen] : EnemyList is created, all should work fine.')
                                                EnemylistDone = true
                                                return false
                                            end
                                        end

EnemiesAround                           = function(range)
                                            local Count = 0
                                            for i = 1 , TotalEnemy do
                                                local enemy = _EnemyHeroes[i]
                                                if enemy.distance < range then
                                                    Count = Count + 1
                                                end
                                            end
                                            return Count
                                        end                                        

BlockSpells                             = function()
                                            if myHero.dead then return true
                                            elseif ExtLibEvade and ExtLibEvade.Evade then
                                                print("[Tard Kennen] : it's evading")
                                                return true
                                            elseif LocalGameIsChatOpen() then
                                                return true
                                            elseif not LocalGameIsOnTop() then
                                                return true
                                            end
                                        end

GetMode                                 = function()
                                            local Modes = LocalOrbwalker.Modes
                                            return Modes and (Modes[0] and 0 or Modes[1] and 1 or (Modes[3] or Modes[2]) and 3 or Modes[4] and 2)
                                        end                                        

LocalCallbackAdd                        ("Load", function() Tard_Load() end)
LocalCallbackAdd                        ("Tick", function() Tard_Tick() end)
LocalCallbackAdd                        ("Draw", function() Tard_Draw() end)

Menu = MenuElement({id = "Menu", name = "Tard Kennen", type = MENU, leftIcon = HeroIcon})
Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})

Menu:MenuElement({name = '         ', drop = {'Tard_Version : 1.0.1'}})

Menu.Combo:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
Menu.Combo:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})
Menu.Combo:MenuElement({id = "UseUltimate", name = "Use Ultimate", value = true, leftIcon = RIcon})
Menu.Combo:MenuElement({id = "UseR1v1", name = "Use R 1v1 mode", value = false, leftIcon = RIcon})
Menu.Combo:MenuElement({id = "UseRMini", name = "Minimum enemies to R", value = 1, min = 0, max = 5, leftIcon = RIcon})

Menu.Harass:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
Menu.Harass:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})

Menu.Lasthit:MenuElement({id = "UseQ", name = "Use Q", value = true, leftIcon = QIcon})
Menu.Lasthit:MenuElement({id = "UseW", name = "Use W", value = true, leftIcon = WIcon})

Menu.Killsteal:MenuElement({id = "UseQ", name = "Use Q", value = false, leftIcon = QIcon})
Menu.Killsteal:MenuElement({id = "UseW", name = "Use W", value = false, leftIcon = WIcon})

Menu.Drawings:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true, leftIcon = QIcon})
Menu.Drawings:MenuElement({id = "DrawW", name = "Draw W Range", value = true, leftIcon = WIcon})
Menu.Drawings:MenuElement({id = "DrawR", name = "Draw R Range", value = true, leftIcon = RIcon})

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
                                                print("[Tard Kennen] : it's evading")
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
                                                    if linesegment and isOnSegment and (GetDistanceSqr(minion.pos, linesegment) < (minion.boundingRadius + 50) * (minion.boundingRadius + 50)) then
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
Tard_Load                               = function()
                                            --<--assigning variables-->--
                                            CalcMagicalDamage = _G.CalcMagicalDamage
                                            Color = DrawColor(255, 255, 200, 100)
                                            ExtLibEvade = _G.ExtLibEvade or nil
                                            LocalUtilities = _G.SDK.Utilities
                                            LocalTargetSelector = _G.SDK.TargetSelector
                                            LocalOrbwalker = _G.SDK.Orbwalker
                                            AD = _G.SDK.DAMAGE_TYPE_PHYSICAL
                                            AP = _G.SDK.DAMAGE_TYPE_MAGICAL
                                            myAD = myHero.totalDamage
                                            myAP = myHero.ap
                                            TCount = 1
                                            MYTEAM = myHero.team
                                            ENEMYTEAM = 300 - MYTEAM
                                            mylvlW = myHero:GetSpellData(1).level
                                            mylvlQ = myHero:GetSpellData(0).level
                                            champRecacheTimeOut = _G.champRecacheTimeOut * .001
                                            champRecache = Localosclock()
                                            visionTick = LocalTickCount()
                                            variableTimer, variableTimer2 = Localosclock(), Localosclock()
                                            castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
                                            _OnWaypoint, _OnVision = {}, {}
                                            --</--assigning variables--\>--
                                        end