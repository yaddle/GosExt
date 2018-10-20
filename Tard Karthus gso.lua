if myHero.charName ~= 'Karthus' then return end;
local Tard_Menu                         = MenuElement({id = "Menu", name = "Tard Karthus", type = MENU, leftIcon = "http://www.mobafire.com/images/champion/icon/karthus.png"})
local myHero                            = myHero;
local MinionCount                       = Game.MinionCount;
local Minion                            = Game.Minion;
local CanUseSpell                       = Game.CanUseSpell;
local LocalGameIsChatOpen               = Game.IsChatOpen;
local LocalGameIsOnTop                  = Game.IsOnTop;
local DrawCircle, DrawColor             = Draw.Circle, Draw.Color;
local ExtLibEvade                       = _G.ExtLibEvade or nil;
local LocalOrbwalker                    = _G.SDK.Orbwalker or nil;
local LocalTargetSelector               = _G.SDK.TargetSelector or nil;
local AD                                = _G.SDK.DAMAGE_TYPE_PHYSICAL or nil;
local AP                                = _G.SDK.DAMAGE_TYPE_MAGICAL or nil;
local HealthPrediction                  = _G.SDK.HealthPrediction or nil;
local LocalCallbackAdd                  = Callback.Add;
local Localosclock                      = os.clock;
local MYTEAM                            = myHero.team;
local BlueColor                         = DrawColor(255, 0, 0, 255)
local _localosclock, variableTimer      = Localosclock(), Localosclock();
local ShouldLoad                        = _G.GamsteronAIOLoaded or false;


local Qdmg                              = function()
                                            return myHero:GetSpellData(0).level * 20 + 30 + myHero.ap * 0.3
                                        end

local GetMode                           = function()
                                            local Modes = LocalOrbwalker.Modes
                                            return Modes and (Modes[0] and 0 or Modes[1] and 1 or (Modes[3] or Modes[2]) and 3 or Modes[4] and 2)
                                        end

local GetTarget                         = function(range, type)
                                            if not type then
                                                return LocalTargetSelector:GetTarget(range, AD)
                                            else
                                                return LocalTargetSelector:GetTarget(range, AP)
                                            end
                                        end

local BlockSpells                       = function()
                                            if ExtLibEvade and ExtLibEvade.Evade then
                                                print("[Tard Karthus] : it's evading")
                                                return
                                            elseif LocalGameIsChatOpen() then
                                                return
                                            elseif not LocalGameIsOnTop() then
                                                return
                                            else
                                                return false
                                            end
                                        end

local Tard_Combo                        = function(Mana)
                                            if myHero.dead or not Tard_Menu.Combo.UseE:Value() or Tard_Menu.Combo.manaCE:Value() > Mana then return end
                                            local target = GetTarget(550)
                                            local isTarget = target and not target.dead or nil
                                            local toggleState =  myHero:GetSpellData(2).toggleState
                                            if isTarget then
                                                toggleState = toggleState == 1 and Control.CastSpell(HK_E)
                                            elseif toggleState == 2 then
                                                return Control.CastSpell(HK_E)
                                            end
                                        end


local Tard_Lasthit                      = function(Mana)
                                            if myHero.dead then return end
                                            for i = 1, MinionCount() do
                                                local minion = Minion(i)
                                                if minion.team ~= MYTEAM and minion.distance < 875 and not minion.dead and minion.isTargetable then
                                                    local minionHP = HealthPrediction:GetPrediction(minion, 1)
                                                    local Qdamage = Qdmg()
                                                    if minionHP > 0 and minionHP < Qdamage then
                                                        local pos = minion:GetPrediction(20000, .6)
                                                        local cb =
                                                            LocalCallbackAdd("Draw", function(...)
                                                                local mHealth = minion and minion.health
                                                                if minion.team ~= MYTEAM and not minion.dead and minion.visible and mHealth > 0 and mHealth < Qdamage + 100 then 
                                                                    DrawCircle(minion.pos, 125, 1, BlueColor)
                                                                end
                                                                if minion.dead or minion.health < 0 or not minion.visible then
                                                                    --minion = nil
                                                                    Callback.Del("Draw", cb)
                                                                end
                                                            end)
                                                        if CanUseSpell(0) == 0 and (Tard_Menu.Lasthit.UseQ:Value() or Tard_Menu.Lasthit.manaLQ:Value() < Mana) then
                                                            LocalOrbwalker:SetAttack(false)
                                                            Control.CastSpell(HK_Q, pos)
                                                            DelayAction(function()
                                                                LocalOrbwalker:SetAttack(true)
                                                            end, .8)
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                        end

local Tard_Clear                        = function(Mana)
                                            if not Tard_Menu.Clear.UseQ:Value() or Tard_Menu.Clear.manaCQ:Value() > Mana and not myHero.dead then return end
                                            for i = 1, MinionCount() do
                                                local minion = Minion(i)
                                                if minion.team ~= MYTEAM and minion.distance < 875 and not minion.dead and minion.isTargetable then
                                                    if HealthPrediction:GetPrediction(minion, .6) > 0 then
                                                        local pos = minion:GetPrediction(20000, .6)
                                                        return CanUseSpell(0) == 0 and Control.CastSpell(HK_Q, pos)
                                                    end
                                                end
                                            end
                                        end

LocalCallbackAdd                        ("Draw", function()
                                            local MenuDraw = Tard_Menu.Draw
                                            if MenuDraw.DrawQ:Value() then
                                                DrawCircle(myHero.pos, 825, 1, BlueColor)
                                            end
                                        end)
LocalCallbackAdd                        ("Load", function()
                                            ExtLibEvade = _G.ExtLibEvade or nil;
                                            LocalOrbwalker = _G.SDK.Orbwalker or nil;
                                            LocalTargetSelector = _G.SDK.TargetSelector or nil;
                                            AD = _G.SDK.DAMAGE_TYPE_PHYSICAL or nil;
                                            AP = _G.SDK.DAMAGE_TYPE_MAGICAL or nil;
                                            HealthPrediction = _G.SDK.HealthPrediction or nil;
                                        end)

LocalCallbackAdd                        ("Tick", function()
                                            if ShouldLoad == false then 
                                                ShouldLoad = _G.GamsteronAIOLoaded or false
                                                return print("You're not using gsoAIO active it or unload Tard Karthus.")
                                            end
                                            BlockSpells()
                                            _localosclock = Localosclock()
                                            if _localosclock - variableTimer > .15 then
                                                local _Mode, Mana = GetMode(), myHero.mana / myHero.maxMana * 100
                                                _Mode = _Mode and (_Mode == 0 and Tard_Combo(Mana) or _Mode == 2 and Tard_Lasthit(Mana) or _Mode == 3 and Tard_Clear(Mana))
                                                variableTimer = Localosclock()
                                            end
                                        end)

Tard_Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
Tard_Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
Tard_Menu:MenuElement({id = "Clear", name = "Farm", type = MENU})
Tard_Menu:MenuElement({id = "Draw", name = "Drawings", type = MENU})

Tard_Menu.Combo:MenuElement({id = "UseE", name = "Use E", value = true})
Tard_Menu.Combo:MenuElement({id = "manaCE", name = "Mana Limit", value = 40, min = 5, max = 100, step = 5 })
Tard_Menu.Lasthit:MenuElement({id = "UseQ", name = "Use Q", value = true})
Tard_Menu.Lasthit:MenuElement({id = "manaLQ", name = "Mana Limit", value = 40, min = 5, max = 100, step = 5 })
Tard_Menu.Clear:MenuElement({id = "UseQ", name = "Use Q", value = true})
Tard_Menu.Clear:MenuElement({id = "manaCQ", name = "Mana Limit", value = 50, min = 5, max = 100, step = 5 })
Tard_Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
Tard_Menu.Draw:MenuElement({id = 'ColorQ', name = 'Color Q', color = DrawColor(255, 0, 0, 255)})







