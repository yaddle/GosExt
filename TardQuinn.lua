local u={["Quinn"]="https://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Behind_Enemy_Lines.png"}local e,o=_G.myHero,Game.HeroCount()class"Need"function Need:__init()self.Tard_version=1.5 print("Hello ",e.name,", TardQuinn v",self.Tard_version," is ready to feed")self.DamageReductionTable={["Braum"]={buff="BraumShieldRaise",amount=function(e)return 1-({.3,.325,.35,.375,.4})[e:GetSpellData(_E).level]end},["Urgot"]={buff="urgotswapdef",amount=function(e)return 1-({.3,.4,.5})[e:GetSpellData(_R).level]end},["Alistar"]={buff="Ferocious Howl",amount=function(e)return({.5,.4,.3})[e:GetSpellData(_R).level]end},["Amumu"]={buff="Tantrum",amount=function(e)return({2,4,6,8,10})[e:GetSpellData(_E).level]end,damageType=1},["Galio"]={buff="GalioIdolOfDurand",amount=function(e)return .5 end},["Garen"]={buff="GarenW",amount=function(e)return .7 end},["Gragas"]={buff="GragasWSelf",amount=function(e)return({.1,.12,.14,.16,.18})[e:GetSpellData(_W).level]end},["Annie"]={buff="MoltenShield",amount=function(e)return 1-({.16,.22,.28,.34,.4})[e:GetSpellData(_E).level]end},["Malzahar"]={buff="malzaharpassiveshield",amount=function(e)return .1 end}}if _G.EOWLoaded then self.Tard_Orb=1 print"Don't use Toshi Orb dude, he is toxic ^^"elseif _G.SDK and _G.SDK.Orbwalker then self.Tard_Orb=2 print"IC is a good Orb"self.Tard_SDK=_G.SDK.Orbwalker self.Tard_SDKCombo=_G.SDK.ORBWALKER_MODE_COMBO self.Tard_SDKHarass=_G.SDK.ORBWALKER_MODE_HARASS self.Tard_SDKJungleClear=_G.SDK.ORBWALKER_MODE_JUNGLECLEAR self.Tard_SDKLaneClear=_G.SDK.ORBWALKER_MODE_LANECLEAR self.Tard_SDKLastHit=_G.SDK.ORBWALKER_MODE_LASTHIT self.Tard_SDKFlee=_G.SDK.ORBWALKER_MODE_FLEE self.Tard_SDKSelector=_G.SDK.TargetSelector self.Tard_SDKDamagePhysical=_G.SDK.DAMAGE_TYPE_PHYSICAL elseif _G.gsoSDK then self.Tard_Orb=3 print"gamsteronOrb v2 Loaded by Gamsteron, The return of the Genius Dev"self.TardgsoOrbwalker=__gsoOrbwalker()self.TardgsoSDK=_G.gsoSDK self.TardgsoTS=__gsoTS()self.TardgsoMode=self.TardgsoOrbwalker.UOL_GetMode self.TardgsoObjects=self.TardgsoSDK.ObjectManager elseif _G.__gsoOrbwalker then self.Tard_Orb=4 print"gamsteronOrb Loaded by Gamsteron the Genius Dev"self.TardgsoOrbwalker=__gsoOrbwalker()self.TardgsoGetTarget=self.TardgsoOrbwalker.GetTarget self.TardgsoMode=self.TardgsoOrbwalker.Mode self.TardgsoObjects=self.TardgsoOrbwalker.Objects else if Orbwalker.Enabled:Value()then self.Tard_Orb=5 print"Noddy rocks"else self.Tard_Orb=6 print"WARNING : you're not using any Orb"end end end function Need:Tard_HasBuff(e,a)for n=0,e.buffCount do local e=e:GetBuff(n)if e and e.name~=""and e.count>0 and Game.Timer()>=e.startTime and Game.Timer()<e.expireTime and e.name==a then return e.count end end return 0 end function Need:Tard_GetDistanceSqr(a,n)local e=n or e.pos local n=a.x-e.x local e=(a.z or a.y)-(e.z or e.y)return n*n+e*e end function Need:Tard_GetDistance(a,e)return math.sqrt(self:Tard_GetDistanceSqr(a,e))end function Need:Tard_IsValidTarget(a,n)local n=n or math.huge return a and a.team~=e.team and a.valid and a.distance<n and a.visible and a.isTargetable and not a.dead and not a.isImmortal and not(GotBuff(a,"FioraW")==1)and not(GotBuff(a,"XinZhaoRRangedImmunity")==1 and a.distance<450)end function Need:Tard_GetMode()if self.Tard_Orb==1 then if EOW.CurrentMode==1 then return"Combo"elseif EOW.CurrentMode==2 then return"Harass"elseif EOW.CurrentMode==3 then return"Lasthit"elseif EOW.CurrentMode==4 then return"Clear"end elseif self.Tard_Orb==2 then if self.Tard_SDK.Modes[self.Tard_SDKCombo]then return"Combo"elseif self.Tard_SDK.Modes[self.Tard_SDKHarass]then return"Harass"elseif self.Tard_SDK.Modes[self.Tard_SDKLaneClear]or self.Tard_SDK.Modes[self.Tard_SDKJungle]then return"Clear"elseif self.Tard_SDK.Modes[self.Tard_SDKLastHit]then return"LastHit"elseif self.Tard_SDK.Modes[self.Tard_SDKFlee]then return"Flee"end elseif Tard_Orb==3 then return self.TardgsoMode()elseif Orb==4 then if self.TardgsoMode.isCombo()then return"Combo"elseif self.TardgsoMode.isHarass()then return"Harass"elseif self.TardgsoMode.isLaneClear()then return"Clear"elseif self.TardgsoMode.isLastHit()then return"LastHit"end else return GOS:GetMode()end end function Need:Tard_QuinnTarget(n)local a if self.Tard_Orb==1 then a=EOW:GetTarget(n,ad_dec)elseif self.Tard_Orb==2 then a=self.Tard_SDKSelector:GetTarget(n,self.Tard_SDKDamagePhysical)elseif self.Tard_Orb==3 then local e=self.TardgsoObjects:GetEnemyHeroes(n,false,"attack")a=self.TardgsoTS:GetTarget(e)elseif self.Tard_Orb==4 then local r=self.TardgsoObjects.enemyHeroes_attack a=self.TardgsoGetTarget(n,r,e.pos,false,false)else a=GOS:GetTarget(n,"AD")end return a end local a={state=0,tick=GetTickCount(),casting=GetTickCount()-1000,mouse=mousePos}function Need:Tard_CastSpell(r,n,e)local d=e or 250 if n==nil then return end local e=GetTickCount()if a.state==0 and e-a.casting>d+Game.Latency()then a.state=1 a.mouse=mousePos a.tick=e end if a.state==1 then if e-a.tick<Game.Latency()then Control.SetCursorPos(n)Control.KeyDown(r)Control.KeyUp(r)a.casting=e+d DelayAction(function()if a.state==1 then Control.SetCursorPos(a.mouse)a.state=0 end end,Game.Latency()/1000)end if e-a.casting>Game.Latency()then Control.SetCursorPos(a.mouse)a.state=0 end end end function Need:Tard_IsEvading()if ExtLibEvade and ExtLibEvade.Evading then print"it's evading"return true end end function Need:GetItemSlot(a,n)for e=ITEM_1,ITEM_7 do if a:GetItemData(e).itemID==n then return e end end return 0 end function Need:CalcPhysicalDamage(e,a,n)local r=e.armorPenPercent local d=(.4+a.levelData.lvl/30)*e.armorPen local t=e.bonusArmorPenPercent if e.type==Obj_AI_Minion then r=1 d=0 t=1 elseif e.type==Obj_AI_Turret then d=0 t=1 if e.charName:find("3")or e.charName:find("4")then r=.25 else r=.7 end end if e.type==Obj_AI_Turret then if a.type==Obj_AI_Minion then n=n*1.25 string.ends=function(a,e)return e==""or string.sub(a,-string.len(e))==e end if string.ends(a.charName,"MinionSiege")then n=n*.7 end return n end end local l=a.armor local o=a.bonusArmor local i=100/(100+l*r-o*(1-t)-d)if l<0 then i=2-100/(100-l)elseif l*r-o*(1-t)-d<0 then i=1 end return math.max(0,math.floor(Need:DamageReductionMod(e,a,Need:PassivePercentMod(e,a,i)*n,1)))end function Need:DamageReductionMod(r,a,e,d)if r.type==Obj_AI_Hero then if self:Tard_HasBuff(r,"Exhaust")>0 then e=e*.6 end end if a.type==Obj_AI_Hero then for n=0,a.buffCount do if a:GetBuff(n).count>0 then local n=a:GetBuff(n)if n.name=="w"then e=e*(1-.06*n.count)end if self.DamageReductionTable[a.charName]then if n.name==self.DamageReductionTable[a.charName].buff and(not self.DamageReductionTable[a.charName].damagetype or self.DamageReductionTable[a.charName].damagetype==d)then e=e*self.DamageReductionTable[a.charName].amount(a)end end if a.charName=="Maokai"and r.type~=Obj_AI_Turret then if n.name=="MaokaiDrainDefense"then e=e*.8 end end if a.charName=="MasterYi"then if n.name=="Meditate"then e=e-e*({.5,.55,.6,.65,.7})[a:GetSpellData(_W).level]/(r.type==Obj_AI_Turret and 2 or 1)end end end end if self:GetItemSlot(a,1054)>0 then e=e-8 end if a.charName=="Kassadin"and d==2 then e=e*.85 end end return e end function Need:PassivePercentMod(e,n,a,t)local d={"Red_Minion_MechCannon","Blue_Minion_MechCannon"}local r={"Red_Minion_Wizard","Blue_Minion_Wizard","Red_Minion_Basic","Blue_Minion_Basic"}if e.type==Obj_AI_Turret then if table.contains(d,n.charName)then a=a*.7 elseif table.contains(r,n.charName)then a=a*1.14285714285714 end end if e.type==Obj_AI_Hero then if n.type==Obj_AI_Hero then if(Need:GetItemSlot(e,3036)>0 or Need:GetItemSlot(e,3034)>0)and e.maxHealth<n.maxHealth and t==1 then a=a*(1+math.min(n.maxHealth-e.maxHealth,500)/50*(Need:GetItemSlot(e,3036)>0 and .015 or .01))end end end return a end class"TardQuinn"function TardQuinn:__init()require"Eternal Prediction"self.Tard_QuinnSpells={[0]={range=e:GetSpellData(0).range,delay=.25,speed=e:GetSpellData(0).speed,width=e:GetSpellData(0).width},[1]={range=e:GetSpellData(1).range,delay=0,speed=e:GetSpellData(1).speed,width=e:GetSpellData(1).width},[2]={range=e:GetSpellData(2).range,delay=.25,speed=e:GetSpellData(2).speed,width=e:GetSpellData(2).width},[3]={range=e:GetSpellData(3).range,delay=.25,speed=e:GetSpellData(3).speed,width=e:GetSpellData(3).width}}self.Tard_QuinnDmg={[0]=function(n)local a=e:GetSpellData(0).level return Need:CalcPhysicalDamage(e,n,({20,45,70,95,120})[a]+({.8,.9,1.,1.1,1.2})[a]*e.totalDamage+.5*e.ap)end,[2]=function(a)local n=e:GetSpellData(2).level return Need:CalcPhysicalDamage(e,a,({40,70,100,130,160})[n]+.2*e.bonusDamage)end,[3]=function(a)local n=e:GetSpellData(3).level return Need:CalcPhysicalDamage(e,a,.4*e.totalDamage)end}if _G.Prediction_Loaded then self.Tard_EternalPred=true print"Tosh Pred loaded ;)"self.Tard_QPred=Prediction:SetSpell(self.Tard_QuinnSpells[0],TYPE_LINE,true)end self.mathsqrt=math.sqrt self:Tard_Menu()Callback.Add("Tick",function()self:Tard_Tick()end)Callback.Add("Draw",function()self:Tard_Draw()end)end function TardQuinn:Tard_Menu()self.Tard_TardMenu=MenuElement({type=MENU,id="TardQuinnMenu",name="TardQuinn",leftIcon=u.Quinn})self.Tard_TardMenu:MenuElement({type=MENU,id="Combo",name="Combo Settings"})self.Tard_TardMenu.Combo:MenuElement({id="ComboQ",name="Use Q",value=true})self.Tard_TardMenu.Combo:MenuElement({id="ComboW",name="Use W if lose vision in AA range",value=true})self.Tard_TardMenu.Combo:MenuElement({id="ComboE",name="Use E",value=false})self.Tard_TardMenu:MenuElement({type=MENU,id="Harass",name="Harass Settings"})self.Tard_TardMenu.Harass:MenuElement({id="HarassQ",name="Use Q",value=true})self.Tard_TardMenu.Harass:MenuElement({id="HarassW",name="Use W if lose vision in AA range",value=true})self.Tard_TardMenu.Harass:MenuElement({id="HarassE",name="Use E",value=false})self.Tard_TardMenu.Harass:MenuElement({id="HarassMana",name="Min. Mana",value=40,min=0,max=100})self.Tard_TardMenu:MenuElement({type=MENU,id="Farm",name="Farm Settings"})self.Tard_TardMenu.Farm:MenuElement({id="FarmQ",name="Use Q",value=true})self.Tard_TardMenu.Farm:MenuElement({id="FarmW",name="Use W",value=true})self.Tard_TardMenu.Farm:MenuElement({id="FarmE",name="Use E",value=true})self.Tard_TardMenu.Farm:MenuElement({id="FarmMana",name="Min. Mana",value=40,min=0,max=100})self.Tard_TardMenu:MenuElement({type=MENU,id="Misc",name="Misc Settings"})self.Tard_TardMenu.Misc:MenuElement({id="Passive",name="Block spell if target is under passive",value=true,tooltip="more dps, less burst"})self.Tard_TardMenu.Misc:MenuElement({id="AntiGap",name="Anti Gapcloser",value=true})self.Tard_TardMenu.Misc:MenuElement({id="NotQ_underR",name="Block Q under Ulti (more dps, less burst)",value=true})self.Tard_TardMenu.Misc:MenuElement({id="E_AAreset",name="Use E to reset AA (more dps, less burst)",value=true})self.Tard_TardMenu.Misc:MenuElement({id="Rrecall",name="Auto use R after recall",value=true})self.Tard_TardMenu:MenuElement({type=MENU,id="KS",name="KillSteal Settings"})self.Tard_TardMenu.KS:MenuElement({id="Q_KS",name="Use Q to try to KillSteal",value=true})self.Tard_TardMenu.KS:MenuElement({id="E_KS",name="Use E to try to KillSteal",value=true})self.Tard_TardMenu.KS:MenuElement({id="R_KS",name="Use R to try to KillSteal",value=true})if self.Tard_EternalPred then self.Tard_TardMenu:MenuElement({type=MENU,id="Pred",name="Prediction Settings"})self.Tard_TardMenu.Pred:MenuElement({id="PredHitChance",name="HitChance (default 25)",value=25,min=0,max=100,tooltip="higher value better pred but slower.  ||don't change it if don't know what is it||"})end self.Tard_TardMenu:MenuElement({type=MENU,id="Draw",name="Drawing Settings"})self.Tard_TardMenu.Draw:MenuElement({id="DrawReady",name="Draw Only Ready Spells [?]",value=true,tooltip="Only draws spells when they're ready"})self.Tard_TardMenu.Draw:MenuElement({id="DrawQ",name="Draw Q Range",value=true})self.Tard_TardMenu.Draw:MenuElement({id="DrawW",name="Draw W Range",value=true})self.Tard_TardMenu.Draw:MenuElement({id="DrawE",name="Draw E Range",value=true})self.Tard_TardMenu.Draw:MenuElement({id="DrawTarget",name="Draw Target [?]",value=true,tooltip="Draws current target"})PrintChat"Menu Ok"end function TardQuinn:Tard_Tick()if e.dead or Need:Tard_IsEvading()or Game.IsChatOpen()then return end local e=Need:Tard_GetMode()if e=="Combo"then self:Tard_Combo()elseif e=="Harass"then self:Tard_Harass()end if self.Tard_TardMenu.Misc.AntiGap:Value()then self:Tard_AntiGapCloser()end if self.Tard_TardMenu.KS.Q_KS:Value()or self.Tard_TardMenu.KS.E_KS:Value()or self.Tard_TardMenu.KS.R_KS:Value()then self:Tard_KillSteal()end end function TardQuinn:Tard_Combo()local a=Need:Tard_QuinnTarget(925)if a==nil or Need:Tard_IsEvading()then return end if Need:Tard_IsValidTarget(a,925)then local r=e.attackData.state local n=e.range if self.Tard_TardMenu.Combo.ComboW:Value()then self:Tard_Vision(e.range+e.boundingRadius+a.boundingRadius)end if self.Tard_TardMenu.Combo.ComboQ:Value()and r~=2 and Game.CanUseSpell(_Q)==0 then if Need:Tard_GetDistanceSqr(a.pos)>(n+e.boundingRadius+a.boundingRadius)*(n+e.boundingRadius+a.boundingRadius)or(Need:Tard_HasBuff(a,"QuinnW")==0 or not self.Tard_TardMenu.Misc.Passive:Value())and(Need:Tard_HasBuff(e,"QuinnR")==0 or not self.Tard_TardMenu.Misc.NotQ_underR:Value())then self:Tard_CastQ(a)end elseif self.Tard_TardMenu.Combo.ComboE:Value()and(r==3 or not self.Tard_TardMenu.Misc.E_AAreset:Value())and Game.CanUseSpell(_E)==0 then if Need:Tard_GetDistanceSqr(a.pos)>(n+e.boundingRadius+a.boundingRadius)*(n+e.boundingRadius+a.boundingRadius)or(Need:Tard_HasBuff(a,"QuinnW")==0 or not self.Tard_TardMenu.Misc.Passive:Value())then self:Tard_CastE(a)end end end end function TardQuinn:Tard_Harass()local a=Need:Tard_QuinnTarget(925)if a==nil or Need:Tard_IsEvading()then return end if Need:Tard_IsValidTarget(a,925)then local r=e.attackData.state local n=e.range if self.Tard_TardMenu.Harass.HarassW:Value()and e.mana/e.maxMana>=self.Tard_TardMenu.Harass.HarassMana:Value()/100 then self:Tard_Vision(e.range+e.boundingRadius+a.boundingRadius)end if self.Tard_TardMenu.Harass.HarassQ:Value()and e.mana/e.maxMana>=self.Tard_TardMenu.Harass.HarassMana:Value()/100 and r~=2 and Game.CanUseSpell(_Q)==0 then if Need:Tard_GetDistanceSqr(a.pos)>(n+e.boundingRadius+a.boundingRadius)*(n+e.boundingRadius+a.boundingRadius)or(Need:Tard_HasBuff(a,"QuinnW")==0 or not self.Tard_TardMenu.Misc.Passive:Value())and(Need:Tard_HasBuff(e,"QuinnR")==0 or not self.Tard_TardMenu.Misc.NotQ_underR:Value())then self:Tard_CastQ(a)end elseif self.Tard_TardMenu.Harass.HarassE:Value()and e.mana/e.maxMana>=self.Tard_TardMenu.Harass.HarassMana:Value()/100 and(r==3 or not self.Tard_TardMenu.Misc.E_AAreset:Value())and Game.CanUseSpell(_E)==0 then if Need:Tard_GetDistanceSqr(a.pos)>(n+e.boundingRadius+a.boundingRadius)*(n+e.boundingRadius+a.boundingRadius)or(Need:Tard_HasBuff(a,"QuinnW")==0 or not self.Tard_TardMenu.Misc.Passive:Value())then self:Tard_CastE(a)end end end end function TardQuinn:Tard_KillSteal()for a=1,o do local a=Game.Hero(a)if Need:Tard_IsValidTarget(a,self.Tard_QuinnSpells[0].range)then local n=0 local r=0 local d=0 if self.Tard_TardMenu.KS.Q_KS:Value()and Game.CanUseSpell(_Q)==0 then n=self.Tard_QuinnDmg[0](a)end if self.Tard_TardMenu.KS.E_KS:Value()and Game.CanUseSpell(_E)==0 then r=self.Tard_QuinnDmg[2](a)end if self.Tard_TardMenu.KS.R_KS:Value()and Need:Tard_HasBuff(e,"QuinnR")==1 then d=self.Tard_QuinnDmg[3](a)end if r>0 and a.health+a.shieldAD<r then print"Kill Steal E working"self:Tard_CastE(a)break elseif n>0 and a.health+a.shieldAD<n then print"Kill Steal Q working"self:Tard_CastQ(a)break elseif r>0 and n>0 and a.health+a.shieldAD<r+n then print"Kill Steal E+Q working"self:Tard_CastE(a)DelayAction(function()self:Tard_CastQ(a)end,.25+self.Tard_QuinnSpells[0].delay)break elseif(r>0 or n>0)and d>0 and a.health+a.shieldAD<r+n+d then print"Kill Steal E+Q+R working"if r>0 then self:Tard_CastE(a)end if n>0 then DelayAction(function()self:Tard_CastQ(a)end,.25+self.Tard_QuinnSpells[0].delay)break end return end end end end function TardQuinn:Tard_AntiGapCloser()for e=1,o do local e=Game.Hero(e)if Game.CanUseSpell(_E)==0 and Need:Tard_IsValidTarget(e,300)and Need:Tard_GetDistanceSqr(e.pos)>Need:Tard_GetDistanceSqr(e.posTo)then self:Tard_CastE(e)break end end end function TardQuinn:Tard_CastQ(a)if a then if self.Tard_EternalPred==true then local e=self.Tard_QPred:GetPrediction(a,e.pos)if e and e.hitChance>=self.Tard_TardMenu.Pred.PredHitChance:Value()/100 and e:mCollision()==0 and e:hCollision()==0 then Need:Tard_CastSpell(HK_Q,e.castPos,250)end else local n=a:GetPrediction(self.Tard_QuinnSpells[0].speed,self.Tard_QuinnSpells[0].delay+Game.Latency()/1000)local a=a:GetCollision(self.Tard_QuinnSpells[0].width,self.Tard_QuinnSpells[0].speed,self.Tard_QuinnSpells[0].delay)if Game.CanUseSpell(_Q)==0 and a==0 and Need:Tard_GetDistanceSqr(e.pos,n)<self.Tard_QuinnSpells[0].range*self.Tard_QuinnSpells[0].range then DelayAction(function()Need:Tard_CastSpell(HK_Q,n,250)end,self.Tard_QuinnSpells[0].delay)end end end return false end function TardQuinn:Tard_CastE(e)if e then if Game.CanUseSpell(_E)==0 then Control.CastSpell(HK_E,e)end end return false end function TardQuinn:Tard_Vision(n)if Game.CanUseSpell(1)==0 then for a=1,o do local a=Game.Hero(a)if a and a.team~=e.team and not a.visible and not a.dead and Need:Tard_GetDistanceSqr(a.pos)<=n*n and Game.CanUseSpell(_W)==0 then Control.CastSpell(HK_W)break end end end end function TardQuinn:Tard_Draw()if e.dead then return end local a=e.pos local e=self.Tard_TardMenu.Draw if self.Tard_TardMenu.Draw.DrawReady:Value()then local n=Game.CanUseSpell if n(_Q)==0 and e.DrawQ:Value()then Draw.Circle(a,self.Tard_QuinnSpells[0].range,1,Draw.Color(255,96,203,67))end if n(_W)==0 and e.DrawW:Value()then Draw.Circle(a,self.Tard_QuinnSpells[1].range,1,Draw.Color(255,255,255,255))end if n(_E)==0 and e.DrawE:Value()then Draw.Circle(a,self.Tard_QuinnSpells[2].range,1,Draw.Color(255,255,255,255))end else if e.DrawQ:Value()then Draw.Circle(a,self.Tard_QuinnSpells[0].range,1,Draw.Color(255,96,203,67))end if e.DrawW:Value()then Draw.Circle(a,self.Tard_QuinnSpells[1].range,1,Draw.Color(255,255,255,255))end if e.DrawE:Value()then Draw.Circle(a,self.Tard_QuinnSpells[2].range,1,Draw.Color(255,255,255,255))end end if e.DrawTarget:Value()then local e=Need:Tard_QuinnTarget(925)if e then Draw.Circle(e.pos,80,3,Draw.Color(255,255,0,0))end end end Callback.Add("Load",function()if _G["TardQuinn"]and e.charName=="Quinn"then _G["TardQuinn"]()_G.Need=Need()end end)