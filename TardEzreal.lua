if myHero.charName~="Ezreal"then return end local X,w,pe,z,U,u,e,ce,he,me,ye,fe,ue,se,L,ie,ae,le,D,P,F,I,q,b,y,Ie,g local n=_G.myHero local oe="2.7.1"local l=nil local R=Callback.Add local W=Draw.Circle local _=Draw.Color local te=Draw.Text local r=Game.CanUseSpell local m=Game.Latency local c=Game.Timer local e=Game.HeroCount local C=Game.Hero local H=Game.MinionCount local B=Game.Minion local Me=Game.IsChatOpen local j=e()local O=math.huge local S=math.sqrt local Z=math.min local ee=math.max local ne=math.floor local De=math.atan2 local be=math.pi local A=Vector local f=GetTickCount local v=_Q local T=_W local V=_E local d=_R local re=ITEM_1 local G=ITEM_2 local h=ITEM_3 local M=ITEM_4 local e=ITEM_5 local t=ITEM_6 local Ee=ITEM_7 local o=5 local E=1 local N=n.team local a=300 local K=300-N local de=f()local ge=f()local p,i={},{}local a={}local s={state=0,tick=f(),casting=f()-1000,mouse=mousePos}local e={[re]=HK_ITEM_1,[G]=HK_ITEM_2,[h]=HK_ITEM_3,[M]=HK_ITEM_4,[e]=HK_ITEM_5,[t]=HK_ITEM_6}local t={[0]={range=1200,delay=.25,speed=2000,width=80,spellType=TYPE_LINE,hitBox=true},[1]={range=1050,delay=.54,speed=1600,width=80,spellType=TYPE_LINE,hitBox=false},[2]={range=475},[3]={range=20000,delay=1.7666,speed=2000,width=160,spellType=TYPE_LINE,hitBox=false}}local e=MenuElement({type=MENU,id="TardEzrealMenu",name="Tard Ezreal",leftIcon="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/EzrealIcon.png"})local G={["Braum"]={buff="BraumShieldRaise",amount=function(e)return 1-({.3,.325,.35,.375,.4})[e:GetSpellData(V).level]end},["Urgot"]={buff="urgotswapdef",amount=function(e)return 1-({.3,.4,.5})[e:GetSpellData(d).level]end},["Alistar"]={buff="Ferocious Howl",amount=function(e)return({.5,.4,.3})[e:GetSpellData(d).level]end},["Amumu"]={buff="Tantrum",amount=function(e)return({2,4,6,8,10})[e:GetSpellData(V).level]end,damageType=1},["Galio"]={buff="GalioIdolOfDurand",amount=function(e)return .5 end},["Garen"]={buff="GarenW",amount=function(e)return .7 end},["Gragas"]={buff="GragasWSelf",amount=function(e)return({.1,.12,.14,.16,.18})[e:GetSpellData(T).level]end},["Annie"]={buff="MoltenShield",amount=function(e)return 1-({.16,.22,.28,.34,.4})[e:GetSpellData(V).level]end},["Malzahar"]={buff="malzaharpassiveshield",amount=function(e)return .1 end}}local d=function(a,e)local e=e or n.pos local n=a.x-e.x local e=(a.z or a.y)-(e.z or e.y)return n*n+e*e end local we=function(e)return e.health/e.maxHealth*100 end local M=function(e)return e.mana/e.maxMana*100 end local h=function(e,n)local n=n or O return e and e.isEnemy and e.valid and e.distance<=n and e.isTargetable and not e.dead and not e.isImmortal and not(GotBuff(e,"FioraW")==1)and not(GotBuff(e,"XinZhaoRRangedImmunity")==1 and e.distance<450)end local _e=function(e,a)for n=0,e.buffCount do local e=e:GetBuff(n)if e and e.name~=""and e.count>0 and c()>=e.startTime and c()<e.expireTime and e.name==a then return e.count end end return 0 end local Pe=function()if o==1 then if EOW.CurrentMode==1 then return"Combo"elseif EOW.CurrentMode==2 then return"Harass"elseif EOW.CurrentMode==3 then return"Lasthit"elseif EOW.CurrentMode==4 then return"Clear"end elseif o==2 then TardSDKModes=ce.Modes if TardSDKModes[he]then return"Combo"elseif TardSDKModes[me]then return"Harass"elseif TardSDKModes[fe]or TardSDKModes[Tard_SDKJungle]then return"Clear"elseif TardSDKModes[ue]then return"Lasthit"elseif TardSDKModes[se]then return"Flee"end elseif o==3 then return b()elseif o==4 then if b.isCombo()then return"Combo"elseif b.isHarass()then return"Harass"elseif b.isLaneClear()then return"Clear"elseif b.isLastHit()then return"LastHit"end else return GOS:GetMode()end end local J=function(a)local e if o==1 then if n.totalDamage>=n.ap then e=EOW:GetTarget(a,ad_dec)else e=EOW:GetTarget(a,ap_dec)end elseif o==2 then if n.totalDamage>=n.ap then e=L:GetTarget(a,ae)else e=L:GetTarget(a,le)end elseif o==3 then if n.totalDamage>n.ap then local n=y:GetEnemyHeroes(a,false,"attack")e=z:GetTarget(n)else local n=y:GetEnemyHeroes(a,false,"spell")e=z:GetTarget(n,1)end elseif o==4 then if n.totalDamage>n.ap then local t=y.enemyHeroes_attack e=q(a,t,n.pos,false,false)else local n=y.enemyHeroes_spell e=q(a,n,myHero.pos,true,false)end else e=GOS:GetTarget(a)end return e end local Ae=function()if g then return g end g={}for e=1,j do local e=C(e)if e.team==K then g[E]=e E=E+1 end end E=1 return#g end local Se=function(e)for n=0,e.buffCount do local e=e:GetBuff(n)and buff and(buff.type==5 or buff.type==11 or buff.type==29 or buff.type==24 or buff.name=="recall")and buff.count>0 and true end return false end local Y=function(e,n)if o==1 then return EOW:GetHealthPrediction(e,n)elseif o==2 then return ie:GetPrediction(e,n)elseif o==3 then return TardgsoFarm:MinionHpPredAccuracy(e,n)elseif o==4 then return TardgsoHPPred(e.health,e.handle,n)else return GOS:HP_Pred(e,n)end end local x=function(a,n,e)local o,a,e,n,l,t=e.x,e.z,a.x,a.z,n.x,n.z local a=((o-e)*(l-e)+(a-n)*(t-n))/((l-e)*(l-e)+(t-n)*(t-n))local r={x=e+a*(l-e),z=n+a*(t-n)}local o=a<0 and 0 or(a>1 and 1 or a)local a=o==a local e=a and r or{x=e+o*(l-e),z=n+o*(t-n)}return e,r,a end local k=function(o,i,a,l)local n=0 for e=H(),1,-1 do local e=B(e)if e~=o and e.team~=N and e.dead==false and e.isTargetable then local o,c,r=x(a,l,e.pos)local t=t[i].width+e.boundingRadius local e=e.pos if r and d(o,e)<t*t and d(a,l)>d(a,e)then n=n+1 end end end return n end local Q=function(o,r,n,l)local a=0 for e=j,1,-1 do local e=C(e)if e~=o and e.team==K and e.dead==false and e.isTargetable then local o,i,i=x(n,l,e.pos)local t=t[r].width+e.boundingRadius local e=e.pos if sOnSegment and d(o,e)<t*t and d(n,l)>d(n,e)then a=a+1 end end end return a end local N=function(e)p[e.networkID]=p[e.networkID]==nil and{state=e.visible,tick=f(),pos=e.pos}or p[e.networkID]if p[e.networkID].state==true and not e.visible then p[e.networkID].state=false p[e.networkID].tick=f()end if p[e.networkID].state==false and e.visible then p[e.networkID].state=true p[e.networkID].tick=f()end return p[e.networkID]end local p=function()if f()-de>100 then for e=1,w do N(g[e])end end end local x=function(e)i[e.networkID]=i[e.networkID]==nil and{pos=e.posTo,speed=e.ms,time=c()}or i[e.networkID]if i[e.networkID].pos~=e.posTo then i[e.networkID]={startPos=e.pos,pos=e.posTo,speed=e.ms,time=c()}DelayAction(function()local n=i[e.networkID].time and c()-i[e.networkID].time local a=S(d(i[e.networkID].startPos,e.pos))/(c()-i[e.networkID].time)if a>1250 and n>0 and e.posTo==i[e.networkID].pos and d(e.pos,i[e.networkID].pos)>40000 then i[e.networkID].speed=S(d(i[e.networkID].startPos,e.pos))/(c()-i[e.networkID].time)end end,.05)end return i[e.networkID]end local O=function(e,a,n)local a=a or O local t=n or .25 local n=x(e).speed>e.ms and x(e).speed or e.ms if N(e).state==false then local l=e.pos+A(e.pos,e.posTo):Normalized()*(f()-N(e).tick)*.001*n local n=l+A(e.pos,e.posTo):Normalized()*n*(t+l:DistanceTo()/a)if d(e.pos,n)>d(e.pos,e.posTo)then n=e.posTo end return n else if n>e.ms then local n=e.pos+A(x(e).startPos,e.posTo):Normalized()*n*(t+e.distance/a)if d(e.pos,n)>d(e.pos,e.posTo)then n=e.posTo end return n elseif Se(e)then return e.pos else return e:GetPrediction(a,t)end end end local p=function(t,a,e)local n=e or 250 if a==nil then return end local e=f()if s.state==0 and e-s.casting>n+m()then s.state=1 s.mouse=mousePos s.tick=e end if s.state==1 then if e-s.tick<m()then Control.SetCursorPos(a)Control.KeyDown(t)Control.KeyUp(t)s.casting=e+n DelayAction(function()if s.state==1 then Control.SetCursorPos(s.mouse)s.state=0 end end,m()*.001)end if e-s.casting>m()then Control.SetCursorPos(s.mouse)s.state=0 end end end local i=function(n,a)for e=re,Ee do if n:GetItemData(e).itemID==a then return e end end return 0 end local re=function(e,n,a)local t=e.armorPenPercent local o=(.4+n.levelData.lvl/30)*e.armorPen local r=e.bonusArmorPenPercent if e.type==Obj_AI_Minion then t=1 o=0 r=1 elseif e.type==Obj_AI_Turret then o=0 r=1 if e.charName:find("3")or e.charName:find("4")then t=.25 else t=.7 end end if e.type==Obj_AI_Turret then if n.type==Obj_AI_Minion then a=a*1.25 string.ends=function(n,e)return e==""or string.sub(n,-string.len(e))==e end if string.ends(n.charName,"MinionSiege")then a=a*.7 end return a end end local l=n.armor local i=n.bonusArmor local d=100/(100+l*t-i*(1-r)-o)if l<0 then d=2-100/(100-l)elseif l*t-i*(1-r)-o<0 then d=1 end return ee(0,ne(DamageReductionMod(e,n,PassivePercentMod(e,n,d)*a,1)))end local ee=function(e,t,l)local n=t.magicResist local a=100/(100+n*e.magicPenPercent-e.magicPen)if n<0 then a=2-100/(100-n)elseif n*e.magicPenPercent-e.magicPen<0 then a=1 end return ee(0,ne(DamageReductionMod(e,t,PassivePercentMod(e,t,a)*l,2)))end local s=function(t,n,e,l)if t.type==Obj_AI_Hero then if _e(t,"Exhaust")>0 then e=e*.6 end end if n.type==Obj_AI_Hero then for a=0,n.buffCount do if n:GetBuff(a).count>0 then local a=n:GetBuff(a)if a.name=="w"then e=e*(1-.06*a.count)end if G[n.charName]then if a.name==G[n.charName].buff and(not G[n.charName].damagetype or G[n.charName].damagetype==l)then e=e*G[n.charName].amount(n)end end if n.charName=="Maokai"and t.type~=Obj_AI_Turret then if a.name=="MaokaiDrainDefense"then e=e*.8 end end if n.charName=="MasterYi"then if a.name=="Meditate"then e=e-e*({.5,.55,.6,.65,.7})[n:GetSpellData(T).level]/(t.type==Obj_AI_Turret and 2 or 1)end end end end if i(n,1054)>0 then e=e-8 end if n.charName=="Kassadin"and l==2 then e=e*.85 end end return e end local s=function(n,a,e,t)local l={"Red_Minion_MechCannon","Blue_Minion_MechCannon"}local o={"Red_Minion_Wizard","Blue_Minion_Wizard","Red_Minion_Basic","Blue_Minion_Basic"}if n.type==Obj_AI_Turret then if table.contains(l,a.charName)then e=e*.7 elseif table.contains(o,a.charName)then e=e*1.14285714285714 end end if n.type==Obj_AI_Hero then if a.type==Obj_AI_Hero then if(i(n,3036)>0 or i(n,3034)>0)and n.maxHealth<a.maxHealth and t==1 then e=e*(1+Z(a.maxHealth-n.maxHealth,500)/50*(i(n,3036)>0 and .015 or .01))end end end return e end local ne=function(e)local n=0 for a=0,e.buffCount do local e=e:GetBuff(a)if e.count>0 and e.duration>n and(e.type==5 or e.type==8 or e.type==21 or e.type==22 or e.type==24 or e.type==11 or e.type==29 or e.type==30 or e.type==39)then n=e.duration end end return n end local G=function(e)local e=e.pathing.isDashing and e.pathing.dashSpeed or e.ms return e end local s=function(e)local n={}n[E]=e.pos if e.pathing.hasMovePath then for a=e.pathing.pathIndex,e.pathing.pathCount do local e=e:GetPath(a)E=E+1 n[E]=e end end E=1 return n,#n end local s=function(t,e)local l=t.pos local a=e local e=s(t)for n=1,#e-1 do local o=S(d(e[n],e[n+1]))local t=G(t)local o=o/t if a>o then a=a-o l=e[n+1]else local o=(e[n+1]-e[n]):Normalized()l=e[n]+o*t*a break end end return l end local E=function(e,a,t)local l=s(e,a)local n=0 local a=a-t-ne(e)if a>0 then n=G(e)*a end return l,n end local G=function(e)for n=0,e.buffCount do local e=e:GetBuff(n)if e and e.name=="recall"and e.duration>0 then return true,c()-e.startTime end end return false end local ne=function(e,n)local n=n if e.activeSpell and e.activeSpell.valid then local e=e.activeSpell.startTime+e.activeSpell.windup-c()if e>0 then n=e end end local e,a=G(e)if e and a>.25 then n=.25 end return n end local G=function(e,n,a,t)local e=m()/2000+a+S(d(e,n))/t return e end local Ee=function(e)return e.team==K and e.alive and e.visible and e.isTargetable end local Ee=function(e,n)local e=e-n local e=De(e.x,e.z)*180/be if e<0 then e=e+360 end return e end local A=function()for e=1,w do local e=C(e)if not a[e.charName]then a[e.charName]={}a[e.charName]["EndPos"]=e.pathing.endPos a[e.charName]["StartPos"]=e.pathing.endPos a[e.charName]["PreviousAngle"]=0 a[e.charName]["ChangedAt"]=c()end if a[e.charName]["EndPos"].x~=e.pathing.endPos.x or a[e.charName]["EndPos"].y~=e.pathing.endPos.y or a[e.charName]["EndPos"].z~=e.pathing.endPos.z then a[e.charName]["PreviousAngle"]=Ee(A(a[e.charName]["StartPos"].x,a[e.charName]["StartPos"].y,a[e.charName]["StartPos"].z),A(a[e.charName]["EndPos"].x,a[e.charName]["EndPos"].y,a[e.charName]["EndPos"].z))a[e.charName]["EndPos"]=e.pathing.endPos a[e.charName]["StartPos"]=e.pos a[e.charName]["ChangedAt"]=c()end end end local E=function(o,e,u,l,r,i,n)local n=1 local t=s(e,l+S(d(o,e.pos))/r)local o=G(o,t,l,r)local r=ne(e,.1)if a and a[e.charName]and c()-a[e.charName]["ChangedAt"]<.25 then n=2 end if not e.pathing or not e.pathing.hasMovePath then n=2 end local r,a=E(e,o,r)if a-e.boundingRadius<=i/2 then r,a=E(e,o,0)if a-e.boundingRadius<=i/2 then n=4 else n=3 end end if e.activeSpell and e.activeSpell.valid then if e.activeSpell.startTime+e.activeSpell.windup-c()>=l then n=5 else n=3 end end if t:DistanceTo()>u then n=-1 end return n,t end local x=function()if u==1 then if f()-ge>100 then A()end elseif u==3 then if f()-de>100 then for e=1,w do N(g[e])x(g[e])end end end end local s=function()if ExtLibEvade and ExtLibEvade.Evading then print"it's evading"return true end end local ne=function()if n.dead or Me()or s()then return end end local N=function()if not e.B.Combo.sheen:Value()then return false end local e=i(n,3057)>=1 and i(n,3057)or i(n,3025)>=1 and i(n,3025)or i(n,3100)>=1 and i(n,3100)or i(n,3078)>=1 and i(n,3078)if e and n:GetSpellData(e).currentCd==0 and GotBuff(n,"sheen")==1 then return true end return false end local i=function(l,r,o)local a if u==1 then local n,t=E(n.pos,l,t[0].range,t[0].delay,t[0].speed,t[0].width,false)a=n and n>=e.A.P.AccuracyQ:Value()and t elseif u==2 then local n=P[0]:GetPrediction(l,n.pos)a=n and n.hitChance>=e.A.P.PredHitChance:Value()/100 and n.castPos else a=O(l,2000,.25+m()*.001)end if a and a:DistanceTo()<1200 then local e=r~=false and k(l,0,n.pos,a)+Q(l,0,n.pos,a)or 0 if o and e~=0 then return end if e==0 and l.health>0 then p(HK_Q,a,200)end end end local f=function(l)local a if u==1 then local n,t=E(n.pos,l,t[1].range,t[1].delay,t[1].speed,t[1].width,false)a=n and n>=e.A.P.AccuracyW:Value()and t elseif u==2 then local n=P[1]:GetPrediction(l,n.pos)a=n and n.hitChance>=e.A.P.PredHitChance:Value()/100 and n.castPos else a=O(l,1600,.54+m()*.001)end if a and a:DistanceTo()<1050 then p(HK_W,a)end end local p=function(l)local a if u==1 then local t,l=E(n.pos,l,20000,1.76,2000,160,false)a=t and t>=e.A.P.AccuracyR:Value()local e=n.pos+(l-n.pos):Normalized()*500 p(HK_R,e,1000)elseif u==2 then local t=P[3]:GetPrediction(l,n.pos)a=t and t.hitChance>=e.A.P.PredHitChance:Value()/100 and t.castPos local e=n.pos+(t.castPos-n.pos):Normalized()*500 p(HK_R,e,1000)else a=O(l,2000,1.76+m()*.001)local e=a and n.pos+(a-n.pos):Normalized()*500 p(HK_R,e,1000)end end local G=function(a)local e=e.A.autoQ local a=e.ON:Value()and(e.disable:Value()==1 and a~="Combo"or e.disable:Value()==2 and a=="")a=a and r(0)==0 and M(n)>=e.Qmana:Value()and we(n)>=e.health:Value()a=a and myHero.attackDataState~=2 if a then local n=n local t=n.range+n.boundingRadius local n=n.pos local n=J(1200)if n and e.CastOn[n.charName]and e.CastOn[n.charName]:Value()then local a=n.distance local e=e.OutR:Value()and a>t or e.OutR:Value()==false if e and a<1200 then i(n)end end end end local S=function()if e.A.Rkey:Value()and r(3)==0 and l~=nil then local e=l if e then p(e)end end end local A=function()local c=e.A.KS.debug:Value()if n.attackData.state==2 or n.activeSpell.valid then return end for a=1,w do local a=C(a)if h(a)then local l,o,d if e.A.KS.Q_KS:Value()and r(0)==0 and a.distance<t[0].range then l=t[0].dmg(a)end if e.A.KS.W_KS:Value()and r(1)==0 and a.distance<t[1].range then o=t[1].dmg(a)end if e.A.KS.R_KS:Value()and r(3)==0 and a.distance<e.A.KS.R_Ksrange:Value()then d=t[3].dmg(a)end if o~=nil and o>a.health+a.shieldAP then if c then print"KS W"print(o)end f(a)D=a end if l~=nil and l>a.health+a.shieldAD then if c then print"KS Q"print(l)end i(a)D=a end if l~=nil and o~=nil and l+o>a.health+a.shieldAD+a.shieldAP then if c then print"KS W + Q"end D=a i(a)DelayAction(function()f(a)end,t[0].delay+m()*.001)end if d and d>a.health+a.shieldAP then if c then print"KS R"print(d)end local n=n.range+n.boundingRadius+a.boundingRadius local e=a.distance if e>n and Y(a,e/2000)>0 then p(a)D=a end end end end end local p=function()local a if l~=nil and l.distance>2500 then l=nil end if l==nil or not h(l,1200)then a=J(1200)else a=l end local t=n.attackData.state if a==nil or t==2 and n.activeSpell.windup>0 or t==2 or s()then return end if N()and a.distance<=700 then return end if e.B.Combo.ComboQ:Value()and M(n)>=e.B.Combo.ComboQmana:Value()and r(v)==0 and h(a,1200)then i(a)D=a end if e.B.Combo.ComboW:Value()and M(n)>=e.B.Combo.ComboWmana:Value()and r(T)==0 and h(a,1050)then f(a)D=a end end local f=function()local a if l~=nil and l.distance>2500 then l=nil end if l==nil or not h(l,1200)then a=J(1200)else a=l end local t=n.attackData.state if a==nil or t==2 and n.activeSpell.windup>0 or t==2 or s()then return end if e.B.Harass.HarassQ:Value()and M(n)>=e.B.Harass.HarassQMana:Value()and r(v)==0 and h(a,1200)then if n.activeSpell.valid~=true then i(a)D=a end end if e.B.Harass.HarassW:Value()and M(n)>=e.B.Harass.HarassWMana:Value()and r(T)==0 and h(a,1050)then if n.activeSpell.valid~=true then f(a)D=a end end end local D=function()if not e.B.Farm.FarmQ:Value()or M(n)<e.B.Farm.FarmMana:Value()or r(0)~=0 or s()then return end local o=n.range+n.boundingRadius local e=n:GetSpellData(0).level local t=n.totalDamage local a=({15,40,65,90,115})[e]+1.1*t+.4*n.ap for e=1,H()do local e=B(e)if h(e,1200)and e.team~=300 then local l=e.distance/2000 local l=l and Y(e,l)-a local n=n.attackData if e.health<=a and e.health>t or n.state==3 and e.health<=a and n.target~=e.handle or e.distance>o+e.boundingRadius and a>=e.health then i(e,true,false)break end end end end local N=function()if not e.B.JungleClear.JungleQ:Value()or M(n)<e.B.JungleClear.JungleMana:Value()or n.attackData.state==2 or r(v)~=0 or s()then return end for e=1,H()do local e=B(e)if e.team==300 and h(e,1200)and n.attackData.target==e.handle then Control.CastSpell(HK_Q,e)break end end end local i=function()if not e.B.LastHit.LastHitQ:Value()or M(n)<e.B.LastHit.LastHitMana:Value()or Tard_AAstate==2 or r(v)~=0 or s()then return end local r=n.range+n.boundingRadius local e=n:GetSpellData(0).level local a=({15,40,65,90,115})[e]+1.1*n.totalDamage+.4*n.ap for e=1,H()do local e=B(e)local n=n.attackData local l=n.target local o=n.state if h(e,1200)and a>=e.health then local t=e.distance/2000 local n=t and Y(e,n.endTime-c())if o==3 and n<=a and l~=e.handle or e.distance>r+e.boundingRadius then i(e)break end end end end local a=function(a)local e=e.A.KeepRmana:Value()if e and r(3)==0 and n.mana>=140 or(r(3)~=0 or not e)then if a=="Combo"then p()elseif a=="Harass"then f()elseif a=="Lasthit"then i()elseif a=="Clear"then D()N()end end end R("Tick",function()ne()F=Pe()a(F)G(F)x()A()S()end)R("Draw",function()if n.dead or e.Draw.DisableDraw:Value()then return end local d=n.pos local n=e.Draw local i,a,t,o=n.DrawQ,n.DrawW,n.DrawE,n.DrawT local f,c,s,p=i.Width:Value(),a.Width:Value(),t.Width:Value(),o.Width:Value()local u,m,h,s=i.Color:Value(),a.Color:Value(),t.Color:Value(),o.Color:Value()if i.ON:Value()and(r(v)==0 or not n.DrawReady:Value())then W(d,1200,f,u)end if a.ON:Value()and(r(T)==0 or not n.DrawReady:Value())then W(d,1050,c,m)end if t.ON:Value()and(r(V)==0 or not n.DrawReady:Value())then W(d,475,h)end if o.ON:Value()then if U and l and l.visible and l.alive and l.team==K then W(l.pos,80,p,s)end end if n.dautoQ:Value()then local n=myHero.pos:To2D()if e.A.autoQ.ON:Value()then te("Auto Q ON",20,n.x-60,n.y+30,_(255,255,255,0))else te("Auto Q OFF",20,n.x-60,n.y+30,_(255,220,50,0))end end end)R("Load",function()X()print("Hello"..n.name..", TardEzreal v"..oe.." is ready to feed.")w=Ae()for n=1,w do local n=g[n]e.A.autoQ.CastOn:MenuElement({id=n.charName,name=n.charName,value=true})end u=e.A.P.Pred:Value()U=e.A.SelectedTarget:Value()if u==1 then print"HPred loaded"elseif u==2 then require"Eternal Prediction"print"Tosh Pred loaded ;)"P={[0]=Prediction:SetSpell(t[0],t[0].spellType,t[0].hitBox),[1]=Prediction:SetSpell(t[1],t[1].spellType,t[1].hitBox),[3]=Prediction:SetSpell(t[3],t[3].spellType,t[3].hitBox)}else print"Noddy's pred loaded"end if _G.EOWLoaded then o=1 elseif _G.SDK and _G.SDK.Orbwalker then o=2 elseif _G.gsoSDK then o=3 elseif _G.__gsoOrbwalker then o=4 end if o==1 then print"New Eternal Orb is good but Tosh is still toxic ^^"elseif o==2 then print"IC is a good Orb"ce=SDK.Orbwalker he=SDK.ORBWALKER_MODE_COMBO me=SDK.ORBWALKER_MODE_HARASS ye=SDK.ORBWALKER_MODE_JUNGLECLEAR fe=SDK.ORBWALKER_MODE_LANECLEAR ue=SDK.ORBWALKER_MODE_LASTHIT se=SDK.ORBWALKER_MODE_FLEE L=SDK.TargetSelector ie=SDK.HealthPrediction ae=SDK.DAMAGE_TYPE_PHYSICAL le=SDK.DAMAGE_TYPE_MAGICAL elseif o==3 then print"gamsteronOrb v2 Loaded by Gamsteron, The return of the Genius Dev"_G.gsoTicks={HPred=false,All=false,ObjectManager=false,Utilities=false,Cursor=false,Farm=false,Noddy=false}I=__gsoOrbwalker()pe=_G.gsoSDK z=__gsoTS()TardgsoFarm=__gsoFarm()b=I.UOL_GetMode y=pe.ObjectManager elseif o==4 then print"gamsteronOrb Loaded by Gamsteron the Genius Dev"I=__gsoOrbwalker()q=I.GetTarget b=I.Mode y=I.Objects Ie=I.State TardgsoHPPred=I.MinionHealthPrediction elseif o==5 then if Orbwalker.Enabled:Value()then print"Noddy rocks"else o=6 print"WARNING : you're not using any Orbwalker"end end for l=0,3 do if l==0 then t[l].dmg=function(e)local a=n:GetSpellData(0).level return re(n,e,({15,40,65,90,115})[a]+1.1*n.totalDamage+.4*n.ap)end elseif l==1 then t[l].dmg=function(a)local e=n:GetSpellData(1).level return ee(n,a,({70,115,160,205,250})[e]+.8*n.ap)end elseif l==3 then t[l].dmg=function(a)local t=n:GetSpellData(l).level local r=({350,500,650})[t]+.9*n.ap+n.bonusDamage local t if u==1 then local o,l=E(n.pos,a,20000,1.76,2000,160,false)if o and o>=e.A.P.AccuracyR:Value()and l then t=k(a,3,n.pos,l)+Q(a,3,n.pos,l)end elseif u==2 then local e=P[l]:GetPrediction(a,n.pos)t=k(a,3,n.pos,e.castPos)+Q(a,3,n.pos,e.castPos)else local e=O(a,2000,1.76+m()*.001)if e then t=k(a,3,n.pos,e)+Q(a,3,n.pos,e)end end if t then local e=t~=nil and Z(t,7)local e=r*(10-e)/10 return ee(n,a,e)end end end end end)R("WndMsg",function(e,n)if e==WM_LBUTTONDOWN then if U then for e=1,j do local e=C(e)if d(e.pos,mousePos)<=10000 then if e~=nil and l~=nil and l.networkID==e.networkID then l=nil break else l=e break end end end end end end)local n={["Sheen"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/Sheen.png",["Draw"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/draw.png",["Color"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/color.png",["Width"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/width.png",["ON"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/ON.png",["PredHitChance"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/hitchance.png",["Pred"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/prediction.png",["SelectedTarget"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/selected.png",["Key"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/key.png",["disable"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/disable.png",["Health"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/Health.png",["Mana"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/Mana.png",["range"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/range.png",["EzrealR"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/EzrealR.png",["EzrealE"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/EzrealE.png",["EzrealW"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/EzrealW.png",["EzrealQ"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/EzrealQ.png",["Debug"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/Debug.png",["KS"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/KS.png",["basic"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/basic.png",["advanced"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/advanced.png",["JungleAD"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/JungleAD.png",["ClearAD"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/ClearAD.png",["LastHitAD"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/LastHitAD.png",["HarassAD"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/HarassAD.png",["ComboAD"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/ComboAD.png",["info"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/info.png",["yaddle"]="http://raw.githubusercontent.com/yaddle/GosExt/master/Icons/Menu_Icons/yaddle.png"}X=function()e:MenuElement({type=MENU,id="B",name="Basic Settings",leftIcon=n.basic})e.B:MenuElement({type=MENU,id="Combo",name="Combo",leftIcon=n.ComboAD})e.B.Combo:MenuElement({id="sheen",name="Don't cast if under Sheen/Tri/lich buff",value=false,leftIcon=n.Sheen,tooltip="Don't cast spell if you have Sheen buff"})e.B.Combo:MenuElement({id="ComboQ",name="Use Q",value=true,leftIcon=n.EzrealQ})e.B.Combo:MenuElement({id="ComboW",name="Use W",value=true,leftIcon=n.EzrealW})e.B.Combo:MenuElement({id="ComboQmana",name="Min. Mana to Q",value=0,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B.Combo:MenuElement({id="ComboWmana",name="Min. Mana to W",value=75,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B:MenuElement({type=MENU,id="Harass",name="Harass",leftIcon=n.HarassAD})e.B.Harass:MenuElement({id="HarassQ",name="Use Q",value=true,leftIcon=n.EzrealQ})e.B.Harass:MenuElement({id="HarassW",name="Use W",value=true,leftIcon=n.EzrealW})e.B.Harass:MenuElement({id="HarassQMana",name="Min. Mana to Q",value=40,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B.Harass:MenuElement({id="HarassWMana",name="Min. Mana to W",value=75,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B:MenuElement({type=MENU,id="LastHit",name="LastHit",leftIcon=n.LastHitAD})e.B.LastHit:MenuElement({id="LastHitQ",name="Use Q",value=true,leftIcon=n.EzrealQ})e.B.LastHit:MenuElement({id="LastHitMana",name="Min Mana To Lasthit",value=40,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B:MenuElement({type=MENU,id="Farm",name="Clear",leftIcon=n.ClearAD})e.B.Farm:MenuElement({id="FarmQ",name="Use Q",value=true,leftIcon=n.EzrealQ})e.B.Farm:MenuElement({id="FarmMana",name="Min. Mana",value=70,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.B:MenuElement({type=MENU,id="JungleClear",name="JungleClear",leftIcon=n.JungleAD})e.B.JungleClear:MenuElement({id="JungleQ",name="Use Q",value=true,leftIcon=n.EzrealQ})e.B.JungleClear:MenuElement({id="JungleMana",name="Min Mana To JungleClear",value=60,min=0,max=100,step=1,tooltip="It's %",leftIcon=n.Mana})e:MenuElement({type=MENU,id="A",name="Advanced Settings",leftIcon=n.advanced})e.A:MenuElement({type=MENU,id="autoQ",name="Auto Q",leftIcon=n.EzrealQ})e.A.autoQ:MenuElement({id="ON",name="Enable Auto cast Q",key=string.byte("M"),toggle=true,leftIcon=n.ON})e.A.autoQ:MenuElement({id="OutR",name="Try to Cast only if out of attack range",value=false,leftIcon=n.range})e.A.autoQ:MenuElement({id="Qmana",name="Min. Mana to Auto Q",value=60,min=0,max=100,tooltip="It's %",leftIcon=n.Mana})e.A.autoQ:MenuElement({id="health",name="Min. Health to Auto Q",value=40,min=0,max=100,tooltip="It's %",leftIcon=n.Health})e.A.autoQ:MenuElement({id="disable",name="Disable Auto Q : ",value=1,drop={"Disable on Combo","Disable in all mode"},leftIcon=n.disable})e.A.autoQ:MenuElement({type=MENU,id="CastOn",name="Auto Cast Q on :"})e.A:MenuElement({type=MENU,id="KS",name="KillSteal",leftIcon=n.KS})e.A.KS:MenuElement({id="debug",name="print debug KS",value=false,tooltip="message when script try to ks, with total dmg to target",leftIcon=n.Debug})e.A.KS:MenuElement({id="Q_KS",name="Use Q to try to KillSteal",value=true,leftIcon=n.EzrealQ})e.A.KS:MenuElement({id="W_KS",name="Use W to try to KillSteal",value=true,leftIcon=n.EzrealW})e.A.KS:MenuElement({id="R_KS",name="Use R to try to KillSteal",value=true,tooltip="only if target is out of AA range",leftIcon=n.EzrealR})e.A.KS:MenuElement({id="R_Ksrange",name="R Max Range",value=7000,min=300,max=20000,step=100,tooltip="It's %",leftIcon=n.range})e.A:MenuElement({type=MENU,id="P",name="Prediction",leftIcon=n.Pred})e.A.P:MenuElement({id="Pred",name="Which Prediction (Need Reload)",value=1,drop={"HPred","Eternal Pred","Noddy's Pred"}})if e.A.P.Pred:Value()==1 then e.A.P:MenuElement({id="AccuracyQ",name="HPred Accuracy Q",value=2,min=1,max=5,step=1,leftIcon=n.EzrealQ})e.A.P:MenuElement({id="AccuracyW",name="HPred Accuracy W",value=2,min=1,max=5,step=1,leftIcon=n.EzrealW})e.A.P:MenuElement({id="AccuracyR",name="HPred Accuracy R",value=2,min=1,max=5,step=1,leftIcon=n.EzrealR})e.A.P:MenuElement({type=SPACE,id="info",name="Recommended value is 2, perfect is 3",leftIcon=n.info})elseif e.A.P.Pred:Value()==2 then e.A.P:MenuElement({id="PredHitChance",name="Eternal Pred HitChance (default 25)",value=25,min=0,max=100,tooltip="higher value better pred but slower||don't change it if don't know what is it||",leftIcon=n.PredHitChance})e.A.P:MenuElement({type=SPACE,id="info",name="Higher value better pred but slower",leftIcon=n.info})end e.A:MenuElement({id="Rkey",name="Ulti Champ targeted on key",key=string.byte("T"),tooltip="the target needs to be targeted by spell focus first, mouse clic on it, a blue circle shoulds be on the target",leftIcon=n.Key})e.A:MenuElement({id="KeepRmana",name="Keep mana for R",value=false,tooltip="KillSteal never keep mana",leftIcon=n.Mana})e.A:MenuElement({id="SelectedTarget",name="Focus on Selected Target - need reload",value=true,tooltip="Focus Spell on selected target (need reload)",leftIcon=n.SelectedTarget})e:MenuElement({type=MENU,id="Draw",name="Drawing Settings",leftIcon=n.Draw,leftIcon=n.Draw})e.Draw:MenuElement({type=MENU,id="DrawQ",name="Draw Q",leftIcon=n.EzrealQ})e.Draw.DrawQ:MenuElement({id="ON",name="Draw Q range",value=true,leftIcon=n.range})e.Draw.DrawQ:MenuElement({id="Width",name="Width",value=1,min=1,max=5,step=1,leftIcon=n.Width})e.Draw.DrawQ:MenuElement({id="Color",name="Color",color=_(255,0,0,255),leftIcon=n.Color})e.Draw:MenuElement({type=MENU,id="DrawW",name="Draw W",leftIcon=n.EzrealW})e.Draw.DrawW:MenuElement({id="ON",name="Draw W range",value=false,leftIcon=n.range})e.Draw.DrawW:MenuElement({id="Width",name="Width",value=1,min=1,max=5,step=1,leftIcon=n.Width})e.Draw.DrawW:MenuElement({id="Color",name="Color",color=_(255,255,255,255),leftIcon=n.Color})e.Draw:MenuElement({type=MENU,id="DrawE",name="Draw E",leftIcon=n.EzrealE})e.Draw.DrawE:MenuElement({id="ON",name="Draw E range",value=false,leftIcon=n.range})e.Draw.DrawE:MenuElement({id="Width",name="Width",value=1,min=1,max=5,step=1,leftIcon=n.Width})e.Draw.DrawE:MenuElement({id="Color",name="Color",color=_(255,255,255,255),leftIcon=n.Color})e.Draw:MenuElement({type=MENU,id="DrawT",name="Draw Selected Spell Target",leftIcon=n.SelectedTarget})e.Draw.DrawT:MenuElement({id="ON",name="Draw circle under Selected Target",value=true,leftIcon=n.ON})e.Draw.DrawT:MenuElement({id="Width",name="Width",value=3,min=1,max=5,step=1,leftIcon=n.Width})e.Draw.DrawT:MenuElement({id="Color",name="Color",color=_(255,0,0,255),leftIcon=n.Color})e.Draw:MenuElement({id="dautoQ",name="Draw Auto Q status under your Champ",value=true,leftIcon=n.ON})e.Draw:MenuElement({id="DrawReady",name="Draw Only Ready Spells",value=true,tooltip="Only draws spells when they're ready",leftIcon=n.ON})e.Draw:MenuElement({id="DisableDraw",name="Disable all Draws",value=false,leftIcon=n.ON})e:MenuElement({name="         ",drop={"Tard_Version : "..oe},leftIcon=n.info})e:MenuElement({type=SPACE,name="                     by Yaddle",leftIcon=n.yaddle,icon=n.yaddle})end