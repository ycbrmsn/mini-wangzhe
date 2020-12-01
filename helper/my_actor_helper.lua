-- 我的角色工具类
MyActorHelper = {}

-- 初始化actors
function MyActorHelper:init ()
  -- chimo = Chimo:new()
  -- meigao = Meigao:new()
  -- wangyi = Wangyi:new()
  -- liangzhang = Liangzhang:new()
  -- zhendao = Zhendao:new()
  -- yaogao = Yaogao:new()
  -- chuyi = Chuyi:new()
  -- mochi = Mochi:new()
  -- luren = Luren:new()
  -- jiayi = Jiayi:new()
  -- linyin = Linyin:new()
  -- local myActors = { chimo, meigao, wangyi, liangzhang, zhendao, yaogao, chuyi, mochi, luren, jiayi, linyin }
  -- for i, v in ipairs(myActors) do
  --   TimeHelper:initActor(v)
  -- end
  -- LogHelper:debug('创建人物完成')
end

-- 事件

-- 生物被创建
function MyActorHelper:actorCreate (objid, toobjid)
  ActorHelper:actorCreate(objid, toobjid)
  MyStoryHelper:actorCreate(objid, toobjid)
  -- body
  CreatureHelper:showHp(objid)
end

-- 生物进入区域
function MyActorHelper:actorEnterArea (objid, areaid)
  ActorHelper:actorEnterArea(objid, areaid)
  MyStoryHelper:actorEnterArea(objid, areaid)
  -- body
  if (MySkillHelper:enterActiveArea(objid, areaid)) then
  end
end

-- 生物离开区域
function MyActorHelper:actorLeaveArea (objid, areaid)
  ActorHelper:actorLeaveArea(objid, areaid)
  MyStoryHelper:actorLeaveArea(objid, areaid)
end

-- 生物碰撞
function MyActorHelper:actorCollide (objid, toobjid)
  ActorHelper:actorCollide(objid, toobjid)
  MyStoryHelper:actorCollide(objid, toobjid)
  -- body
end

-- 生物攻击命中
function MyActorHelper:actorAttackHit (objid, toobjid)
  ActorHelper:actorAttackHit(objid, toobjid)
  MyStoryHelper:actorAttackHit(objid, toobjid)
end

-- 生物击败目标
function MyActorHelper:actorBeat (objid, toobjid)
  ActorHelper:actorBeat(objid, toobjid)
  MyStoryHelper:actorBeat(objid, toobjid)
end

-- 生物行为改变
function MyActorHelper:actorChangeMotion (objid, actormotion)
  ActorHelper:actorChangeMotion(objid, actormotion)
  MyStoryHelper:actorChangeMotion(objid, actormotion)
  -- body
end

-- 生物受到伤害
function MyActorHelper:actorBeHurt (objid, toobjid, hurtlv)
  ActorHelper:actorBeHurt(objid, toobjid, hurtlv)
  MyStoryHelper:actorBeHurt(objid, toobjid, hurtlv)
  -- body
end

-- 生物死亡
function MyActorHelper:actorDie (objid, toobjid)
  ActorHelper:actorDie(objid, toobjid)
  MyStoryHelper:actorDie(objid, toobjid)
end

-- 生物获得状态效果
function MyActorHelper:actorAddBuff (objid, buffid, bufflvl)
  ActorHelper:actorAddBuff(objid, buffid, bufflvl)
  MyStoryHelper:actorAddBuff(objid, buffid, bufflvl)
  -- body
end

-- 生物失去状态效果
function MyActorHelper:actorRemoveBuff (objid, buffid, bufflvl)
  ActorHelper:actorRemoveBuff(objid, buffid, bufflvl)
  MyStoryHelper:actorRemoveBuff(objid, buffid, bufflvl)
  -- body
end

-- 生物属性变化
function MyActorHelper:actorChangeAttr (objid, actorattr)
  ActorHelper:actorChangeAttr(objid, actorattr)
  MyStoryHelper:actorChangeAttr(objid, actorattr)
  MyMonsterHelper:actorChangeAttr(objid, actorattr)
  -- body
  if (actorattr == CREATUREATTR.CUR_HP) then
    local hp = CreatureHelper:showHp(objid)
    local soldier = MyMonsterHelper:getSoldier(objid)
    soldier:changeHp(hp)
  end
end