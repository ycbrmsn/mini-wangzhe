-- 我的怪物
BaseSoldier = {
  lookSize = 5, -- 视野
  attSpace = 60, -- 攻击间隔
  attCd = 0, -- 攻击冷却
  maxHp = 1000, -- 最大生命
  hp = 1000, -- 生命
  att = 100, -- 攻击
}

function BaseSoldier:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseSoldier:init ()
  CreatureHelper:closeAI(self.objid)
  CreatureHelper:setMaxHp(self.objid, self.maxHp)
  CreatureHelper:setHp(self.objid, self.hp)
end

-- 生成小兵
function BaseSoldier:newSolders (num)
  local objids = WorldHelper:spawnCreature(self.initPos.x, self.initPos.y, self.initPos.z, self.actorid, num)
  if (objids and #objids > 0) then
    for i, objid in ipairs(objids) do
      local soldier = self:addSoldier(objid)
      soldier:init()
    end
  end
end

-- 重新生成小兵(用于小兵因bug消失)
function BaseSoldier:renewSoldier ()
  if (self.x) then
    local objids = WorldHelper:spawnCreature(self.x, self.y, self.z, self.actorid, 1)
    MyMonsterHelper:delSoldier(self.objid)
    self.objid = objids[1]
    self:init()
    MyMonsterHelper:addSoldier(self)
  end
end

-- 加入小兵
function BaseSoldier:addSoldier (objid)
  local o = { objid = objid }
  setmetatable(o, self)
  self.__index = self
  MyMonsterHelper:addSoldier(o)
  return o
end

-- 行动
function BaseSoldier:run ()
  local pos = ActorHelper:getMyPosition(self.objid)
  if (not(pos)) then -- 小兵不见了
    local soldier = MyMonsterHelper:getSoldier(self.objid)
    if (soldier and soldier.hp > 0) then -- 小兵还应该行动
      self:renewSoldier()
      pos = ActorHelper:getMyPosition(self.objid)
    else -- 小兵已死
      return
    end
  end
  if (pos) then
    local objid = self:searchEnemy()
    if (objid) then -- 找到敌人
      self:tryAttack(objid)
    else -- 无敌人
      ActorHelper:tryMoveToPos(self.objid, self.toPos.x, self.toPos.y, self.toPos.z)
    end
    -- 记录小兵的位置等数据
    local x, y, z = ActorHelper:getPosition(self.objid)
    if (x) then
      self.x, self.y, self.z = x, y, z
    end
  end
end

-- 搜索敌人
function BaseSoldier:searchEnemy ()
  -- body
end

-- 尝试攻击
function BaseSoldier:tryAttack (toobjid)
  local distance = MathHelper:getDistanceV2(self.objid, toobjid)
  local dstPos
  if (distance > self.attSize) then -- 超出攻击距离
    local pos1 = ActorHelper:getMyPosition(self.objid)
    local pos2 = ActorHelper:getMyPosition(toobjid)
    dstPos = MathHelper:getPos2PosInLineDistancePosition(pos1, pos2, self.attSize - 1.5)
    if (not(BlockHelper:isAirBlockOffset(dstPos))) then -- 不可以到达
      dstPos = pos2
    end
    ActorHelper:tryMoveToPos(self.objid, dstPos.x, dstPos.y, dstPos.z)
  else -- 攻击距离内
    dstPos = ActorHelper:getMyPosition(self.objid)
    ActorHelper:tryMoveToPos(self.objid, dstPos.x, dstPos.y, dstPos.z)
    self:attack(toobjid)
  end
end

-- 攻击
function BaseSoldier:attack (toobjid)
  if (self.attCd == 0) then
    self:resetAttCd()
    ActorHelper:addBuff(self.objid, MyMap.BUFF.ATTACK, 1, math.ceil(self.attSpace / 5)) -- 攻击不可移动时长
    ActorHelper:playAct(self.objid, ActorHelper.ACT.ATTACK)
    if (self.attCategory == 1) then
      self:meleeAtt(toobjid)
    else
      self:remoteAtt(toobjid)
    end
  end
end

-- 重置攻击冷却
function BaseSoldier:resetAttCd ()
  self.attCd = self.attSpace
  TimeHelper:callFnFastRuns(function ()
    self.attCd = 0
  end, 0.05 * self.attSpace, self.objid .. 'resetAttCd')
end

-- 近程攻击
function BaseSoldier:meleeAtt (toobjid)
  -- body
end

-- 远程攻击
function BaseSoldier:remoteAtt (toobjid)
  -- body
end

-- 生命变化
function BaseSoldier:changeHp (hp)
  self.hp = hp
  if (hp <= 0) then
    MyMonsterHelper:delSoldier(self.objid)
  end
end

-- 近战兵
Soldier01 = BaseSoldier:new({
  attCategory = 1,
  attSize = 2,
})

function Soldier01:new (o, actorid)
  o.actorid = actorid
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 搜索敌人
function Soldier01:searchEnemy ()
  local pos = ActorHelper:getMyPosition(self.objid)
  local dim = { x = self.lookSize, y = 3, z = self.lookSize }
  local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
  end
  if (not(objids) or #objids == 0) then -- 没有目标
    return nil
  else
    return ActorHelper:getNearestActor(objids, pos)
  end
end

-- 近战攻击
function Soldier01:meleeAtt (toobjid)
  -- local dim = { x = 1, y = 3, z = 1 }
  ActorHelper:lookAt(self.objid, toobjid)
  -- local targetPos = ActorHelper:getMyPosition(toobjid)
  -- targetPos.y = targetPos.y + 1
  -- local objids1 = ActorHelper:getAllPlayersArroundPos(targetPos, dim, self.objid, false)
  -- local objids2 = ActorHelper:getAllCreaturesArroundPos(targetPos, dim, self.objid, false)
  -- for i, v in ipairs(objids2) do
  --   table.insert(objids1, v)
  -- end
  TimeHelper:callFnFastRuns(function ()
    -- for i, v in ipairs(objids1) do
    --   ActorHelper:playHurt(v)
    -- end
    ActorHelper:playHurt(toobjid)
    ActorHelper:damageActor(self.objid, toobjid, self.att)
  end, 0.3)
end

-- 远程兵
Soldier02 = BaseSoldier:new({
  attCategory = 2,
  attSize = 4,
})

function Soldier02:new (o, actorid)
  o.actorid = actorid
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 搜索敌人
function Soldier02:searchEnemy ()
  local pos = ActorHelper:getMyPosition(self.objid)
  local dim = { x = self.lookSize, y = 3, z = self.lookSize }
  local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
  end
  if (not(objids) or #objids == 0) then -- 没有目标
    return nil
  else
    return ActorHelper:getNearestActor(objids, pos)
  end
end

-- 远程攻击
function Soldier02:remoteAtt (toobjid)
  local pos1 = ActorHelper:getDistancePosition(self.objid, 1)
  pos1.y = pos1.y + 1
  ActorHelper:lookAt(self.objid, toobjid)
    -- pos2 = ActorHelper:getEyeHeightPosition(nearestObjid)
  local callback = function ()
    ActorHelper:playHurt(toobjid)
    ActorHelper:damageActor(self.objid, toobjid, self.att)
  end
  local projectileid = WorldHelper:spawnProjectileByPos(self.objid, 
    MyMap.ITEM.AMMUNITION2, pos1, pos1, 0)
  MySkillHelper:continueAttack(projectileid, toobjid, 4, callback)
end

-- 攻城车
Soldier03 = BaseSoldier:new({
  attCategory = 2,
  attSize = 4,
})

function Soldier03:new (o, actorid)
  o.actorid = actorid
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 搜索敌人
function Soldier03:searchEnemy ()
  local pos = ActorHelper:getMyPosition(self.objid)
  local dim = { x = self.lookSize, y = 3, z = self.lookSize }
  local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
  end
  if (not(objids) or #objids == 0) then -- 没有目标
    return nil
  else
    return ActorHelper:getNearestActor(objids, pos)
  end
end

-- 远程攻击
function Soldier03:remoteAtt (toobjid)
  local pos1 = ActorHelper:getDistancePosition(self.objid, 1)
  pos1.y = pos1.y + 1
  ActorHelper:lookAt(self.objid, toobjid)
    -- pos2 = ActorHelper:getEyeHeightPosition(nearestObjid)
  local callback = function ()
    ActorHelper:playHurt(toobjid)
    ActorHelper:damageActor(self.objid, toobjid, self.att)
  end
  local projectileid = WorldHelper:spawnProjectileByPos(self.objid, 
    MyMap.ITEM.AMMUNITION2, pos1, pos1, 0)
  MySkillHelper:continueAttack(projectileid, toobjid, 4, callback)
end

local o1 = function ()
  return {
    teamid = 1, -- 队伍
    initPos = MyPosition:new(-26, 7, 0),
    toPos = MyPosition:new(27, 7, 0),
  }
end

local o2 = function ()
  return {
    teamid = 2, -- 队伍
    initPos = MyPosition:new(27, 7, 0),
    toPos = MyPosition:new(-26, 7, 0),
  }
end

-- 红方近战兵
Soldier11 = Soldier01:new(o1(), MyMap.ACTOR.SOLDIER11)

-- 蓝方近战兵
Soldier21 = Soldier01:new(o2(), MyMap.ACTOR.SOLDIER21)

-- 红方远程兵
Soldier12 = Soldier02:new(o1(), MyMap.ACTOR.SOLDIER12)

-- 蓝方远程兵
Soldier22 = Soldier02:new(o2(), MyMap.ACTOR.SOLDIER22)

-- 红方攻城车
Soldier13 = Soldier03:new(o1(), MyMap.ACTOR.SOLDIER13)

-- 蓝方攻城车
Soldier23 = Soldier03:new(o2(), MyMap.ACTOR.SOLDIER23)
