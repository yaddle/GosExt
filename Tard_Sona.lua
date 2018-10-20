    --------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------<INIT>---------------------------------------------------
	if myHero.charName ~= "Sona" then return end
    -----------------------------------------------------</INIT>---------------------------------------------------
    --------------------------------------------------------------------------------------------------------------

    --------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------</VARIABLES>---------------------------------------------------
    --////not assigned variables
    local _EnemyHeroes, EnemyCount, OnVision, OnVisionF, OnWaypoint, GetPred, CastSpell, Q, W, E, R, Menu_AssistedR,  OnDrawQFarm, Mode, castSpell
    --LocalgsoMenuTS = LocalgsoSDK.Menu.ts

    local myHero						= _G.myHero
    local LocalExtLibEvade              = _G.ExtLibEvade or nil
    local LocalgsoSDK                   = _G.SDK or nil
    local LocalmousePos                 = _G.mousePos
    local LocalgsoOrb                   = _G.SDK.Orbwalker or nil
    local LocalgsoTS                    = _G.SDK.TargetSelector or nil
    local LocalgsoOB                    = _G.SDK.ObjectManager or nil
    local LocalgsoHealthPred            = _G.SDK.HealthPrediction or nil
    local LocalCallbackAdd				= Callback.Add
    local LocalCallbackDel              = Callback.Del
	local LocalDrawCircle				= Draw.Circle
    local LocalDrawColor				= Draw.Color
    local LocalGameMinionCount          = Game.MinionCount
    local LocalGameMinion               = Game.Minion
	local LocalGameIsChatOpen			= Game.IsChatOpen
    local LocalGameCanUseSpell			= Game.CanUseSpell
    local LocalGameLatency              = Game.Latency
    local LocalGameTimer                = Game.Timer
    local LocalGetTick                  = GetTickCount
    local ControlCastSpell              = Control.CastSpell
    local ControlIsKeyDown              = Control.IsKeyDown
    local ControlKeyDown                = Control.KeyDown
    local ControlKeyUp                  = Control.KeyUp
    local ControlSetCursorPos           = Control.SetCursorPos
    local LocalSqrt                     = math.sqrt
    local LocalVector                   = Vector

    local TEAM_ALLY                     = myHero.team
    local TEAM_ENEMY                    = 300 - TEAM_ALLY
    local __counter                     = 1                         
    local __green                       = LocalDrawColor(255, 000, 255, 000)
    local __blue                        = LocalDrawColor(255, 180, 255, 255)
    local __yellow                      = LocalDrawColor(255, 255,255,0)
    local __myHero                      = myHero
    local __mana                        = __myHero.mana
    local __ap                          = __myHero.ap
    local _OnVision, _OnWaypoint        = {}, {}
    local variablesTick                 = LocalGetTick()
    

    local Tard_GetDistanceSqr           = function(Pos1, Pos2)
                                            local Pos2 = Pos2 or Tard_myHero.pos
                                            local Tard_dx = Pos1.x - Pos2.x
                                            local Tard_dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
                                            return (Tard_dx * Tard_dx) + (Tard_dz * Tard_dz)
                                        end

    local GetEnemyHeroes                = function()
                                            if _EnemyHeroes then return _EnemyHeroes end
                                            _EnemyHeroes = {}
                                            for i = 1, Game.HeroCount() do
                                                local unit = Game.Hero(i)
                                                if unit.team == TEAM_ENEMY then
                                                    _EnemyHeroes[__counter] = unit
                                                    __counter = __counter+1
                                                end
                                            end
                                            __counter = 1
                                            return #_EnemyHeroes
                                        end                                        

    local IsEvading                     = function()
                                            if LocalExtLibEvade and LocalExtLibEvade.Evading then 
                                                return print("it's evading") and true
                                            end
                                        end

    local CantUse                       = function()
                                            return __myHero.dead or GotBuff(myHero, 'recall') == 1 or LocalGameIsChatOpen() or IsEvading()
                                        end

    local isEnemyNear                   = function(range)
                                            local CanUse
                                            for i = 1, EnemyCount do
                                                if  _EnemyHeroes[i].distance < range then return true end
                                            end
                                            return false
                                        end

    local GetMode                       = function()
                                            local Modes = LocalgsoOrb.Modes
                                            return Modes and (Modes[0] and 0 or Modes[1] and 1 or (Modes[3] or Modes[2]) and 3 or Modes[4] and 2) 
                                        end

    local UpdateVariables               = function(times)
                                            local timer = LocalGetTick()
                                            if timer - variablesTick > times then
                                                __myHero = __myHero
                                                __mana   = __myHero.mana/myHero.maxMana*100
                                                __ap     = __myHero.ap
                                                for i=1, EnemyCount do
                                                    OnVision(_EnemyHeroes[i])
                                                end
                                                variablesTick = timer
                                            end
                                        end

    local CastQ                         = function(Mode)
                                            --if myHero.activeSpell.valid then return end
                                            local CanUse = Mode == 0 and __mana > 5 or Mode == 1 and __mana > 40
                                            --local CanUse = (Mode = 0 or Mode = 1) and CanSpellMenu(Q)
                                            CanUse = CanUse and LocalGameCanUseSpell(0) == 0 and LocalgsoTS:GetTarget(Q.range, 1)

                                            return CanUse and ControlCastSpell(HK_Q)
                                        end

    local CastE                         = function(Mode)
                                            --if myHero.activeSpell.valid then return end
                                            local CanUse = Mode == 0 and __mana > 70
                                            local distance = CanUse and 1000
                                            --local CanUse, Menu  = CanSpellMenu(E)
                                            --local distance = CanUse and Menu.use:active() and Menu.enemy_distance
                                            --local CanUse2 = distance and (Mode = 0 or Mode = 1)
                                            CanUse = distance and LocalGameCanUseSpell(2) == 0 and isEnemyNear(distance)

                                            return CanUse and ControlCastSpell(HK_E)
                                        end

    local ManualR                       = function()
                                            local CanUse = isEnemyNear(1000) and LocalGameCanUseSpell(3) == 0 and castSpell.state == 0 and ControlIsKeyDown(46)
                                            local target = CanUse and LocalgsoTS:GetTarget(1000, 1)
                                            local rPred = target and GetPred(target, R.speed, R.delay + LocalGameLatency()*.001)
                                            local distance = rPred and rPred:DistanceTo() < 1000
                                            return distance and CastSpell(HK_R, rPred, 250)
                                        end

    local FarmQ                         = function(Mode)
                                            local CanUse = Mode == 2 and isEnemyNear(825) and __mana > 30
                                            local Qlvl = CanUse and LocalGameCanUseSpell(0) == 0 and __myHero:GetSpellData(0).level
                                            local Qdmg = Qlvl and ({40, 70, 100, 130, 160})[Qlvl] + .5 * __ap

                                            if Qdmg then 
                                                for i =1, LocalGameMinionCount() do
                                                    local minion = LocalGameMinion(i)
                                                    CanUse = minion and minion.team == TEAM_ENEMY and minion.distance < 825 and minion.health < Qdmg--LocalgsoHealthPred:GetPrediction(minion, 0.25) < Qdmg
                                                    
                                                    return CanUse and ControlCastSpell(HK_Q)
                                                end
                                            end
                                        end


    local Tard_Tick                     = function()
                                            if CantUse() then return end
                                            Mode = GetMode()
                                            UpdateVariables(5) --number of ticks
                                            ManualR()
                                            CastQ(Mode)
                                            FarmQ(Mode)
                                            --CastE(Mode)
                                            --CastR(Mode)
                                        end


    LocalgsoOrb:OnPreAttack             (function(attack)
                                            if CantUse() then attack.Process = false;
                                                return
                                            end
                                        end)

    LocalgsoOrb:OnPreMovement           (function(Movement)
                                            if CantUse() then Movement.Process = false;
                                                return
                                            end
                                        end)

    LocalCallbackAdd                    ("Load", function()
                                            LocalExtLibEvade = _G.ExtLibEvade
                                            LocalgsoSDK = _G.SDK
                                            LocalgsoOrb = LocalgsoSDK.Orbwalker
                                            LocalgsoTS = LocalgsoSDK.TargetSelector
                                            LocalgsoOB = LocalgsoSDK.ObjectManager
                                            LocalgsoHealthPred = LocalgsoSDK.HealthPrediction
                                            EnemyCount = GetEnemyHeroes()
                                            LocalCallbackAdd("Tick", function() Tard_Tick() end)
                                            LocalCallbackAdd("Draw", function() 
                                                LocalDrawCircle(myHero.pos, 825, __blue)
                                                LocalDrawCircle(myHero.pos, 1000, __yellow) 
                                            end)
                                            print("Tard Sona launch done. Enjoy your game")
                                            if _EnemyHeroes then 
                                                for i=1, EnemyCount do
                                                    print("You're facing : " .. _EnemyHeroes[i].charName)
                                                end
                                            end                              
                                        end)

---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------VARIABLES INITIALISATION>---------------------------------------------------
Q                                       = {range = 825}
W                                       = {range = 1000}
E                                       = {range = 430}
R                                       = {range = 900, width = 140, speed = 2400, delay = .25}
castSpell                               = {state = 0, tick = LocalGetTick(), casting = LocalGetTick() - 1000, mouse = mousePos}


OnDrawQFarm                             = function(Mode)
                                            if not Mode or Mode == 0 then return end 
                                            local Qlvl = LocalGameCanUseSpell(0) == 0 and __myHero:GetSpellData(0).level
                                            local Qdmg = Qlvl and ({40, 70, 100, 130, 160})[Qlvl] + .5 * __ap
                                            if Qdmg then
                                                local _minionsNear = LocalgsoOB:GetEnemyMinions(Q.range)
                                                local minionsCount = _minionsNear and #_minionsNear
                                                for i = 1, minionsCount do
                                                    local minion = _minionsNear[i]
                                                    minion = minion and minion.health <= Qdmg and print(minion.health) and minion --LocalgsoHealthPred:GetPrediction(minion, 2) < Qdmg and minion
                                                    if minion then
                                                        LocalDrawCircle(minion.pos, 140, __green)
                                                        break
                                                    end
                                                end
                                            end
                                        end

---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<NODDY FONCTIONS, THX TO HIM :)>---------------------------------------------------

OnVision                                = function(unit)
                                            _OnVision[unit.networkID] = _OnVision[unit.networkID] == nil and {state = unit.visible , tick = LocalGetTick(), pos = unit.pos} or _OnVision[unit.networkID]
                                            if _OnVision[unit.networkID].state == true and not unit.visible then _OnVision[unit.networkID].state = false _OnVision[unit.networkID].tick = LocalGetTick() end
                                            if _OnVision[unit.networkID].state == false and unit.visible then _OnVision[unit.networkID].state = true _OnVision[unit.networkID].tick = LocalGetTick() end
                                            return _OnVision[unit.networkID]
                                        end

OnVisionF                               = function()
                                            local ticker = LocalGetTick()
                                            if ticker - visionTick > 100 then
                                                for i=1, EnemyCount do
                                                    OnVision(_EnemyHeroes[i])
                                                end
                                                visionTick = ticker
                                            end
                                        end

OnWaypoint                              = function(unit)
                                            _OnWaypoint[unit.networkID] = (_OnWaypoint[unit.networkID] == nil and {pos = unit.posTo , speed = unit.ms, time = LocalGameTimer()}) or _OnWaypoint[unit.networkID]
                                            if _OnWaypoint[unit.networkID].pos ~= unit.posTo then 
                                                -- print("OnWayPoint:"..unit.charName.." | "..TardMathFloor(LocalGameTimer()))
                                                _OnWaypoint[unit.networkID] = {startPos = unit.pos, pos = unit.posTo , speed = unit.ms, time = LocalGameTimer()}
                                                    DelayAction(function()
                                                        local time = _OnWaypoint[unit.networkID].time and (LocalGameTimer() - _OnWaypoint[unit.networkID].time)
                                                        local speed = LocalSqrt(Tard_GetDistanceSqr(_OnWaypoint[unit.networkID].startPos,unit.pos))/(LocalGameTimer() - _OnWaypoint[unit.networkID].time)
                                                        if speed > 1250 and time > 0 and unit.posTo == _OnWaypoint[unit.networkID].pos and Tard_GetDistanceSqr(unit.pos,_OnWaypoint[unit.networkID].pos) > 40000 then
                                                            _OnWaypoint[unit.networkID].speed = LocalSqrt(Tard_GetDistanceSqr(_OnWaypoint[unit.networkID].startPos,unit.pos))/(LocalGameTimer() - _OnWaypoint[unit.networkID].time)
                                                            print("OnDash: "..unit.charName)
                                                        end
                                                    end,0.05)
                                            end
                                            return _OnWaypoint[unit.networkID]
                                        end

GetPred                                     = function(unit, speed, delay)
                                            local speed = speed or TardMathHuge
                                            local delay = delay or 0.25
                                            local unitSpeed = (OnWaypoint(unit).speed > unit.ms and OnWaypoint(unit).speed) or unit.ms
                                            if OnVision(unit).state == false then
                                                local unitPos = unit.pos + LocalVector(unit.pos,unit.posTo):Normalized() * ((LocalGetTick() - OnVision(unit).tick)*.001 * unitSpeed)
                                                local predPos = unitPos + LocalVector(unit.pos,unit.posTo):Normalized() * (unitSpeed * (delay + unitPos:DistanceTo()/speed))
                                                if Tard_GetDistanceSqr(unit.pos,predPos) > Tard_GetDistanceSqr(unit.pos,unit.posTo) then predPos = unit.posTo end
                                                return predPos
                                            else
                                                if unitSpeed > unit.ms then
                                                    local predPos = unit.pos + LocalVector(OnWaypoint(unit).startPos,unit.posTo):Normalized() * (unitSpeed * (delay + (unit.distance/speed)))
                                                    if Tard_GetDistanceSqr(unit.pos,predPos) > Tard_GetDistanceSqr(unit.pos,unit.posTo) then predPos = unit.posTo end
                                                    return predPos
                                                elseif unit.pos == unit.posTo then
                                                --elseif IsImmobileTarget(unit) then
                                                    return unit.pos
                                                else
                                                    return unit:GetPrediction(speed,delay)
                                                end
                                            end	
                                        end

CastSpell                               = function(spell, pos, delay) -- Noddy CastSpell
                                            local delay = delay or 250
                                            if pos == nil then
                                                return
                                            end
                                            local ticker = LocalGetTick()
                                            if castSpell.state == 0 and ticker - castSpell.casting > delay + LocalGameLatency() then -- and pos:ToScreen().onScreen then
                                                castSpell.state = 1
                                                castSpell.mouse = mousePos
                                                castSpell.tick = ticker
                                            end
                                            if castSpell.state == 1 then
                                                if ticker - castSpell.tick < LocalGameLatency() then
                                                    ControlSetCursorPos(pos)
                                                    ControlKeyDown(spell)
                                                    ControlKeyUp(spell)
                                                    castSpell.casting = ticker + delay
                                                    DelayAction(
                                                        function()
                                                            if castSpell.state == 1 then
                                                                ControlSetCursorPos(castSpell.mouse)
                                                                castSpell.state = 0
                                                            end
                                                        end,
                                                        LocalGameLatency() * .001
                                                    )
                                                end
                                                if ticker - castSpell.casting > LocalGameLatency() then
                                                    ControlSetCursorPos(castSpell.mouse)
                                                    castSpell.state = 0
                                                end
                                            end
                                        end
-----------------------------------------------------</NODDY FONCTIONS, THX TO HIM :)>---------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------<FUNCTIONS TO FINISH >---------------------------------------------------
                                        --[[

    local CanSpellMenu                  = function(Mode, spell)
                                            local Menu = Menu.spell.Mode
                                            return Menu and Menu.use:active() and Menu.mana < myHero.mana, Menu
                                        end

    local CastR                         = function(Mode)
                                            local CanUse, Menu = Mode == 0 and CanSpellMenu(R) or Menu_AssistedR

                                            CanUse = CanUse and (Mode == 0 and Menu.enemyCount or Menu_AssistedR)
                                            for i=1, EnemyCount do
                                                local enemy = _EnemyHeroes[i]
                                                if distance < Q.range and 
                                            local CanUse, Menu = CanSpellMenu(R)
                                                ]]