if myHero.charName                          ~= "Kalista" then return end
require "HPred"
require "JADL"
local Menu, Pos1, Orb, SDK, TargetSelector, AD, MODE_FLEE, MODE_COMBO, MODE_HARASS, MODE_LANECLEAR, MODE_LASTHIT, GetMode, ObjectManager, _EnemyHeroes, TotalEnemy, customcast, getdmg, HPred
local myHero                                = myHero
local HeroCount                             = Game.HeroCount()
local GameHero                              = Game.Hero
local MinionCount                           = Game.MinionCount
local GameMinion                            = Game.Minion
local IsChatOpen                            = Game.IsChatOpen
local CanUseSpell                           = Game.CanUseSpell
local GameTimer                             = Game.Timer
local Latency                               = Game.Latency
local Vector                                = Vector
local DrawCircle                            = Draw.Circle
local DrawColor                             = Draw.Color
local DrawText                              = Draw.Text   
local SetCursorPos                          = Control.SetCursorPos
local CastSpell                             = Control.CastSpell
local GetTickCount                          = GetTickCount
local CallbackAdd                           = Callback.Add

local sqrt, huge, atan2, ceil, PI   = math.sqrt, math.huge, math.atan2, math.ceil, math.pi

local Version,Author,LVersion               = "v1.0","Tweetieshy","8.3"
local HeroIcon                              = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/aa/KalistaSquare.png"
local TCount                                = 1
local barHeight                             = 8
local barWidth                              = 103
local barXOffset                            = 24
local barYOffset                            = -8
local castSpell                             = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local Q                                     = {Range = 1150, Width = 40, Delay = 0.35, Speed = 1200, Collision = true, aoe = false, Type = "line"}
local E                                     = {Range = 1000, Delay = 0.25}
local R                                     = {Range = 1200, Width = 160, Delay = 1.35, Speed = 2000, Collision = false, aoe = false, Type = "circular"}
local EDMG                                  = {}


local GetDistanceSqr                        = function(Pos1, Pos2)
                                                local Pos2 = Pos2 or myHero.pos
                                                local dx = Pos1.x - Pos2.x
                                                local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
                                                return dx ^ 2 + dz ^ 2
                                            end

local GetDistance                           = function(Pos1, Pos2)
                                                return sqrt(GetDistanceSqr(Pos1, Pos2))
                                            end

local ValidTarget                           = function(target, range)
                                                range = range and range or math.huge
                                                return target ~= nil and target.valid and target.visible and target.alive and target.distance < range
                                            end

local GetEnemyHeroes                        = function()
                                                if _EnemyHeroes then
                                                    return _EnemyHeroes
                                                end
                                                _EnemyHeroes = {}
                                                for i = 1, HeroCount do
                                                    local unit = GameHero(i)
                                                    if unit.team == TEAM_ENEMY then
                                                        _EnemyHeroes[TCount] = unit
                                                        TCount = TCount + 1
                                                    end
                                                end
                                                TCount = 1
                                                return #_EnemyHeroes
                                            end
                                            
local EnemyInRange                          = function(range)
                                                local count = 0
                                                for i = 1, TotalEnemy do
                                                    local target = _EnemyHeroes[i]
                                                    count = target.distance < range and count + 1 or count
                                                end
                                                return count
                                            end                                            

local HasBuff                               = function(unit, buffname)
                                                for i = 0, unit.buffCount do
                                                    local buff = unit:GetBuff(i)
                                                    if buff.name == buffname and buff.count > 0 then 
                                                        return true
                                                    end
                                                end
                                                return false
                                            end
                                            
local CanCast                               = function(spell)
                                                return CanUseSpell(spell) == 0
                                            end

local GetTarget                             = function(range)
                                                if Orb == 1 then
                                                    return TargetSelector:GetTarget(range, AD)
                                                elseif Orb == 2 then
                                                    AD = ObjectManager:GetEnemyHeroes(range, false, 'attack')
                                                    return TargetSelector:GetTarget(AD)
                                                elseif Orb == 3 then
                                                    return GetTarget(range, 'AD')
                                                else
                                                    print("No Orbwalker ! Can't find target !!")
                                                end
                                            end                                            

local SetMovement                           = function(bool)
                                                if Orb == 1 then
                                                    Orbwalker:SetMovement(bool)
                                                    Orbwalker:SetAttack(bool)
                                                elseif Orb == 2 then
                                                    Orbwalker:UOL_SetMovement(bool)
                                                    Orbwalker:UOL_SetAttack(bool)
                                                elseif Orb == 3 then
                                                    GOS.BlockMovement = not bool
                                                    GOS.BlockAttack = not bool
                                                end
                                            end

local VectorPointProjectionOnLineSegment    = function(v1, v2, v)
                                                local cx, cy, ax, ay, bx, by = v.x, v.z, v1.x, v1.z, v2.x, v2.z
                                                local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
                                                local pointLine = { x = ax + rL * (bx - ax), z = ay + rL * (by - ay) }
                                                local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
                                                local isOnSegment = rS == rL
                                                local pointSegment = isOnSegment and pointLine or {x = ax + rS * (bx - ax), z = ay + rS * (by - ay)}
                                                return pointSegment, pointLine, isOnSegment
                                            end	

local Tard_CastSpell                        = function(spell, pos, delay) -- Noddy CastSpell
                                                customcast = Menu.CustomSpellCast:Value()
                                                if not customcast then return CastSpell(spell, pos)
                                                else                                                
                                                    local delay = Menu.delay:Value()
                                                    local ticker = GetTickCount()
                                                    if castSpell.state == 0 and ticker - castSpell.casting > delay + Latency() then -- and pos:ToScreen().onScreen then
                                                        castSpell.state = 1
                                                        castSpell.mouse = mousePos
                                                        castSpell.tick = ticker
                                                    end
                                                    if castSpell.state == 1 then
                                                        if ticker - castSpell.tick < TardLatency() then
                                                            SetCursorPos(pos)
                                                            KeyDown(spell)
                                                            KeyUp(spell)
                                                            castSpell.casting = ticker + delay
                                                            DelayAction( function()
                                                                if castSpell.state == 1 then
                                                                    SetCursorPos(castSpell.mouse)
                                                                    castSpell.state = 0
                                                                end
                                                            end, Latency() * .001)
                                                        end
                                                        if ticker - castSpell.casting > Latency() then
                                                            SetCursorPos(castSpell.mouse)
                                                            castSpell.state = 0
                                                        end
                                                    end
                                                end
                                            end

local PredDmg                               = function(target, damage)
                                                local Misc = Menu.Misc
                                                if target.type == Obj_AI_Hero then
                                                    local PrecisionCombatRune = Misc.PrecisionRune:Value()
                                                    if PrecisionCombatRune == 2 then
                                                        if target.health/target.maxHealth < 0.4 then
                                                            damage = damage * 1.07
                                                        end
                                                    elseif PrecisionCombatRune == 3 then
                                                        local healthdifference = target.maxHealth - myHero.maxHealth
                                                        if healthdifference > 150 then
                                                            amount = amount * (1.04 + mathmin(healthdifference-150, 2000) / 20 * 0.0008)
                                                        end
                                                    elseif PrecisionCombatRune == 4 then
                                                        local missinghealth = 1 - myHero.health/myHero.maxHealth
                                                        local calculatebonus = missinghealth < 0.4 and 1 or (1.05 + (mathfloor(missinghealth*10 - 4)*0.02))
                                                        damage = damage * (calculatebonus < 1.12 and calculatebonus or 1.11)
                                                    end
                                                end
                                            
                                                if target.team == 300 and Misc.EarthDragonsSlain:Value() > 0 then
                                                    damage = damage * (1 + Misc.EarthDragonsSlain:Value() * 0.10)
                                                end
                                                
                                                if target.type == Obj_AI_Minion and target.charName:find("_Dragon_") and Menu.Misc.DragonsSlain:Value() > 0 then
                                                    damage = damage * (1 - 0.07 * Menu.Misc.DragonsSlain:Value())
                                                end
                                                        
                                                return damage
                                            end
                                            
local GetSkillshotTarget                    = function(minAccuracy, Spell)
                                                for i = 1, TotalEnemy do
                                                    local enemy = _EnemyHeroes[i]		
                                                    if enemy and ValidTarget(enemy) then
                                                        local range = Spell.Range	
                                                        local hitChance, aimPosition = HPred:GetHitchance(myHero.pos, enemy, range, Spell.Delay, Spell.Speed, Spell.Width, Spell.Collision, nil)
                                                        if hitChance and hitChance >= minAccuracy and aimPosition:DistanceTo() < range then
                                                            return enemy,aimPosition
                                                        end
                                                    end
                                                end
                                                return nil
                                            end
                                            
local EStacks                               = function(unit)
                                                if not unit then return 0 end
                                                for i = 0, unit.buffCount do
                                                    local buff = unit:GetBuff(i)
                                                    if buff.name and buff.name == "kalistaexpungemarker" and buff.count > 0 and buff.expireTime >= GameTimer() then
                                                        return buff.count
                                                    end
                                                end
                                                return 0
                                            end
                                            
local EnemyCCD                              = function(unit)
                                                for i = 0, unit.buffCount do
                                                    local buff = unit:GetBuff(i);
                                                    if buff.count > 0 and (buff.type == 5 or buff.type == 8 or buff.type == 10 or buff.type == 21 or buff.type == 22 or buff.type == 24 or buff.type == 11 or buff.type == 29 or buff.type == 30 or buff.type == 39 ) then
                                                        return true
                                                    end
                                                end
                                                return false
                                            end                                            



CallbackAdd                                 ('ProcessRecall', function(Object, recallProc)
                                                if Object == myHero then return end
                                            end)

CallbackAdd                                 ("Load", function()
                                                Orb = _G.SDK and 1 or _G.gsoSDK and 2 or _G.Orbwalker.Enabled:Value() and 3
                                                if Orb == 1 then
                                                    SDK = _G.SDK; Orbwalker = SDK.Orbwalker; TargetSelector = SDK.TargetSelector;AD = SDK.DAMAGE_TYPE_PHYSICAL;
                                                    MODE_FLEE = SDK.ORBWALKER_MODE_FLEE; MODE_COMBO = SDK.ORBWALKER_MODE_COMBO;
                                                    MODE_HARASS = SDK.ORBWALKER_MODE_HARASS; MODE_LANECLEAR = SDK.ORBWALKER_MODE_LANECLEAR;
                                                    MODE_LASTHIT = SDK.ORBWALKER_MODE_LASTHIT; 
                                                elseif Orb == 2 then
                                                    SDK = gsoSDK; Orbwalker = __gsoOrbwalker(); TargetSelector = __gsoTS(); GetMode = Orbwalker.UOL_GetMode;
                                                    ObjectManager = __gsoOB();
                                                elseif Orb == 3 then
                                                    GetMode = GOS:GetMode()
                                                end
                                                customcast = Menu.CustomSpellCast:Value()
                                                TotalEnemy = GetEnemyHeroes()
                                                Menu.Misc.DragonsSlain:Value(0)
                                                Menu.Misc.EarthDragonsSlain:Value(0)
                                            end)

CallbackAdd                                 ("Tick", function()
                                                if myHero.dead or IsChatOpen() == true then return end
                                                local Mode = Menu.Combo.comboActive:Value() and Combo() or Menu.Clear.clearActive:Value() and Clear() or Menu.Lasthit.lasthitActive:Value() and Lasthit()
                                                if Menu.Misc.MinionQ:Value() then MinionQCombo() end
                                                AutoJungleE()
                                                Killsteal()
                                                ESlow()
                                                SpellonCCQ()
                                            end)