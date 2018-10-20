    --------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------<INIT>---------------------------------------------------
	if myHero.charName ~= "Cassiopeia" then return end
    -----------------------------------------------------</INIT>---------------------------------------------------
    --------------------------------------------------------------------------------------------------------------

    --------------------------------------------------------------------------------------------------------------
    -----------------------------------------------------</VARIABLES>---------------------------------------------------
    --////not assigned variables
    local EnemyCount, targetPoisoned, poisonedHeroesCount
    
    LocalgsoMenuTS = LocalgsoSDK.Menu.ts

    local myHero						= _G.myHero
    local LocalExtLibEvade              = _G.ExtLibEvade or nil
	local LocalOsClock					= os.clock
	local LocalCallbackAdd				= Callback.Add
	local LocalVector					= Vector	
	local LocalDrawCircle				= Draw.Circle
	local LocalDrawText					= Draw.Text
	local LocalDrawColor				= Draw.Color
	local LocalDrawLine					= Draw.Line
	local LocalLineSegment				= LineSegment
	local LocalCircle					= Circle
	local LocalGameLatency				= Game.Latency
	local LocalGameTimer				= Game.Timer
	local LocalGameHeroCount 			= Game.HeroCount
	local LocalGameHero 				= Game.Hero
	local LocalGameMinionCount 			= Game.MinionCount
	local LocalGameMinion 				= Game.Minion
	local LocalGameWardCount			= Game.WardCount
	local LocalGameWard					= Game.Ward	
	local LocalGameTurretCount			= Game.TurretCount
	local LocalGameTurret				= Game.Turret
	local LocalGameParticleCount		= Game.ParticleCount
    local LocalGameParticle				= Game.Particle
    local LocalGameObjectCount			= Game.ObjectCount
	local LocalGameObject				= Game.Object
	local LocalGameIsChatOpen			= Game.IsChatOpen
	local LocalGameCanUseSpell			= Game.CanUseSpell
	local _Q							= _Q
	local _W							= _W
	local _E							= _E
	local _R							= _R
    local LocalTickCount				= GetTickCount
	local LocalMathMin					= math.min
	local LocalMathSqrt					= math.sqrt
	local LocalMathHuge					= math.huge
	local LocalMathAbs					= math.abs
	local LocalMathDeg					= math.deg
	local LocalMathAcos					= math.acos
	local LocalMathAtan2				= math.atan2
	local LocalMathPI					= math.pi
	local LocalSub						= string.sub

    local __counter                     = 1
 

    local IsUnitValid                   = function(unit, range)
                                            return unit and unit.distance > range and not unit.dead and unit.isTargetable and unit.valid and unit.visible
                                        end

    local IsPoisoned                    = function(unit)    
                                            return GotBuff(unit, cassiopeiaqdebuff) == 1 or GotBuff(unit, cassiopeiawpoison) == 1
                                        end

    local GetPoisonedHeroes            = function(range)
                                            _cachedPoisonedHeroes = {}
                                            for i = 1, EnemyCount do
                                                local enemy = _EnemyHeroes[i]
                                                if enemy.distance < 700 and IsPoisoned(enemy) then
                                                    _cachedPoisonedHeroes[__counter] = enemy
                                                    __counter = __counter + 1
                                                end
                                            end                                            
                                            __counter = 1
                                            return #_cachedPoisonedHeroes
                                        end

    local GetPoisonedBestTarget         = function()
                                            local x, result
                                            local num = 10000000
                                            for i = 1, poisonedHeroesCount do
                                                local enemy = _cachedPoisonedHeroes[i]
                                                if LocalgsoOB:IsHeroImmortal(enemy, false) then return end
                                                local enemyName = enemy.charName
                                                local multiplier = LocalgsoTS.PriorityMultiplier[LocalgsoMenuTS.priority[enemyName] and LocalgsoMenuTS.priority[enemyName]:Value() or 6]
                                                local def = multiplier * (enemy.magicResist - myHero.magicPen)
                                                def = def > 0 and myHero.magicPenPercent * def or def
                                                --if def > 0 and  then
                                                --    def = and myHero.magicPenPercent * def
                                                --   end
                                                x = ( ( enemy.health * multiplier * ( ( 100 + def ) / 100 ) ) - ( enemy.totalDamage * enemy.attackSpeed * 2 ) ) - enemy.ap
                                                if x < num then
                                                    num = x
                                                    result = unit
                                                end
                                            end
                                            return result
                                        end

    local IsEvading                     = function()
                                            if LocalExtLibEvade and LocalExtLibEvade.Evading then 
                                                return print("it's evading") and true
                                            end
                                        end

    local CantUse                       = function()
                                            if myHero.dead or LocalGameIsChatOpen() or IsEvading() then
                                                return
                                            end
                                        end
    
    local GetMode                                                               

    local Tard_Tick                     = function()
                                            CantUse()


                                            poisonedHeroesCount = GetPoisonedHeroes(700) > 0
                                            targetPoisoned = poisonedHeroesCount and GetPoisonedBestTarget() or nil
        

                                        end

    LocalCallbackAdd                    ('ProcessRecall',
                                            function(unit, recall)
                                                return print("You're recalling...") and unit == myHero
                                            end
                                        )
                                                                            