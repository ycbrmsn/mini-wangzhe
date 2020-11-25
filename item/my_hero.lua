-- 我的英雄
BaseHero = {
  level = 1, -- 人物等级
  attSpace = 20, -- 攻击间隔
  attCd = 0, -- 攻击冷却
  targetCategory = 1, -- 攻击模式（1英雄2生物3建筑）
  attCategory = 1, -- 普攻方式（1近程攻击2远程攻击）
  meleeSize = 1, -- 近程攻击距离
  remoteSize = 4, -- 远程攻击距离
  doubleHurt = 2, -- 暴击伤害
  doubleRatio = 0, -- 暴击概率
} 

function BaseHero:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 变身
function BaseHero:shift (objid)
  PlayerHelper:rotateCamera(objid, 0, 0)
  TimeHelper:callFnAfterSecond(function ()
    local faceYaw = ActorHelper:getFaceYaw(objid) % 360
    print(faceYaw)
    if (faceYaw > 265 and faceYaw < 275) then
      ActorHelper:addBuff(objid, MyMap.BUFF.ZHANGLIANG, 1)
    else
      ChatHelper:sendMsg(objid, '矫正朝向中，请勿转动。')
      self:shift(objid)
    end
  end, 1)
end

-- 重置攻击冷却
function BaseHero:resetAttCd ()
  self.attCd = self.attSpace
  TimeHelper:callFnFastRuns(function ()
    self.attCd = 0
  end, 0.05 * self.attSpace, self.objid .. 'resetAttCd')
end

-- 普攻
function BaseHero:attack ()
  if (self.attCd == 0) then
    self:resetAttCd()
    ActorHelper:addBuff(self.objid, MyMap.BUFF.ATTACK, 1, math.ceil(self.attSpace / 5)) -- 攻击不可移动时长
    ActorHelper:playAct(self.objid, ActorHelper.ACT.ATTACK)
    if (self.attCategory == 1) then
      self:meleeAtt()
    else
      self:remoteAtt()
    end
  end
end

-- 近程攻击
function BaseHero:meleeAtt ()
  local pos = ActorHelper:getMyPosition(self.objid)
  local dim = { x = self.meleeSize, y = 3, z = self.meleeSize }
  if (self.targetCategory == 1) then -- 英雄
    local objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
    if (objids and #objids == 0) then
      objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
    end
    self:meleeAtt2(objids, pos)
  elseif (self.targetCategory == 2) then -- 生物
    local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
    if (objids and #objids == 0) then
      objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
    end
    self:meleeAtt2(objids, pos)
  elseif (self.targetCategory == 3) then -- 建筑

  end
end

function BaseHero:meleeAtt2 (objids, pos)
  local player = PlayerHelper:getPlayer(self.objid)
  local dim = { x = 1, y = 3, z = 1 }
  if (not(objids) or #objids == 0) then -- 没有目标
    
  else
    local nearestObjid = ActorHelper:getNearestActor(objids, pos)
    player:lookAt(nearestObjid)
    local nearPos = ActorHelper:getMyPosition(nearestObjid)
    nearPos.y = nearPos.y + 1
    local objids1 = ActorHelper:getAllPlayersArroundPos(nearPos, dim, self.objid, false)
    local objids2 = ActorHelper:getAllCreaturesArroundPos(nearPos, dim, self.objid, false)
    for i, v in ipairs(objids2) do
      table.insert(objids1, v)
    end
    for i, v in ipairs(objids1) do
      ActorHelper:playHurt(v)
    end
  end
end

-- 远程攻击
function BaseHero:remoteAtt ()
  local pos = ActorHelper:getMyPosition(self.objid)
  local dim = { x = self.remoteSize, y = 3, z = self.remoteSize }
  if (self.targetCategory == 1) then -- 英雄
    local objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
    if (objids and #objids == 0) then
      objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
    end
    self:remoteAtt2(objids, pos, dim)
  elseif (self.targetCategory == 2) then -- 生物
    local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, self.objid, false)
    if (objids and #objids == 0) then
      objids = ActorHelper:getAllPlayersArroundPos(pos, dim, self.objid, false)
    end
    self:remoteAtt2(objids, pos, dim)
  elseif (self.targetCategory == 3) then -- 建筑

  end
end

function BaseHero:remoteAtt2 (objids, pos, dim)
  local player = PlayerHelper:getPlayer(self.objid)
  local pos1, pos2 = player:getDistancePosition(1)
  pos1.y = pos1.y + 1
  local toobjid, callback
  if (not(objids) or #objids == 0) then -- 没有目标
    pos2 = player:getDistancePosition(self.remoteSize)
    pos2.y = pos2.y + 1
    toobjid = pos2
  else
    local nearestObjid = ActorHelper:getNearestActor(objids, pos)
    player:lookAt(nearestObjid)
    -- pos2 = ActorHelper:getEyeHeightPosition(nearestObjid)
    toobjid = nearestObjid
    callback = function ()
      ActorHelper:playHurt(nearestObjid)
      self:attackHit(nearestObjid)
    end
  end
  local projectileid = WorldHelper:spawnProjectileByPos(self.objid, 
    MyMap.ITEM.AMMUNITION1, pos1, pos1, 0)
  MySkillHelper:continueAttack(projectileid, toobjid, 4, callback)
  -- ActorHelper:playBodyEffect(projectileid, BaseConstant.BODY_EFFECT.PARTICLE24)
end

function BaseHero:attackHit (toobjid)
  -- body
end

-- 张良
Zhangliang = BaseHero:new({
  name = 'zhangliang',
  attCategory = 2, -- 远程攻击
  phyAtt = 50, -- 物攻
  magAtt = 10, -- 法攻
  maxHp = 1000, -- 最大生命
  maxMp = 1000, -- 最大法力
  speed = 10, -- 移动速度
  skillnames = { '言灵咒印', '言灵壁垒', '言灵侵蚀', '言灵操纵' },
})

function Zhangliang:new (objid)
  local o = {
    objid = objid,
    skillData = {},
    skillLevels = { 0, 0, 0 }, -- 技能等级
  }
  MySkillHelper:register(o)
  setmetatable(o, self)
  self.__index = self
  o:init()
  return o
end

function Zhangliang:init ()
  PlayerHelper:setMaxHp(self.objid, self.maxHp)
  PlayerHelper:setHp(self.objid, self.maxHp)
  -- PlayerHelper:setMaxHunger(self.objid, self.maxMp)
  PlayerHelper:setFoodLevel(self.objid, self.maxMp)
end

function Zhangliang:attackHit (toobjid)
  ActorHelper:damageActor(self.objid, toobjid, self.phyAtt)
end

-- 使用一技能
function Zhangliang:useSkill1 ()
  local innerSize, outerSize = 4, 6
  local player = PlayerHelper:getPlayer(self.objid)
  local pos = ActorHelper:getMyPosition(self.objid)
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, self.objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, self.objid, false)
  end
  if (not(objids) or #objids == 0) then -- 外圈没有找到目标
    local angle = ActorHelper:getFaceYaw(self.objid)
    self:generateSkill1(pos, angle, innerSize)
  else -- 外圈找到目标
    local nearestObjid, distance = ActorHelper:getNearestActor(objids, pos)
    local targetPos = ActorHelper:getMyPosition(nearestObjid)
    local angle = MathHelper:getActorFaceYaw(MyVector3:new(pos, targetPos))
    if (distance <= innerSize) then -- 在技能范围内
      self:generateSkill1(pos, angle, distance)
    else -- 不在范围内
      self:generateSkill1(pos, angle, innerSize)
    end
    player:lookAt(nearestObjid)
  end
end

-- 清除效果
function Zhangliang:clearSkill1 (info)
  for areaid, v in pairs(info) do
    MySkillHelper:delActiveArea(areaid)
    local particleid = self:getSkill1Particleid()
    WorldHelper:stopBodyEffect(v.pos, particleid)
    info[areaid] = nil
  end
  TimeHelper:delFnFastRuns(self.objid .. self.name .. 1)
end

-- 生成
function Zhangliang:generateSkill1 (pos, angle, distance)
  local positions = MathHelper:getRegularDistancePositions(pos, angle, distance, 3)
  local info = MySkillHelper:getSkillInfo(self.objid, 1)
  self:clearSkill1(info)
  for i, v in ipairs(positions) do
    local areaid = AreaHelper:createAreaRect(v, { x = 0, y = 1, z = 0 })
    MySkillHelper:addActiveArea(self.objid, 1, areaid)
    info[areaid] = { pos = v }
    local particleid = self:getSkill1Particleid()
    WorldHelper:playBodyEffect(v, particleid)
  end
  -- 一定时间后清除
  TimeHelper:callFnFastRuns(function ()
    self:clearSkill1(info)
  end, 3, self.objid .. self.name .. 1)
end

-- 敌方进入言灵壁垒区域 objid敌方
function Zhangliang:enterSkill1 (objid, areaid)
  -- if (not(ActorHelper:isTheSameTeamActor(objid, skillObj))) then -- 不同队伍
  if (true) then
    local info = MySkillHelper:getSkillInfo(self.objid, 1)
    local pos = info[areaid].pos
    local level = self.skillLevels[1]
    MySkillHelper:delActiveArea(areaid)
    info[areaid] = nil
    local particleid = self:getSkill1Particleid()
    WorldHelper:stopBodyEffect(pos, particleid)
    -- 眩晕迟缓效果
    ActorHelper:playHurt(objid)
    ActorHelper:addBuff(objid, MyMap.BUFF.DIZZY, 1, 20) -- 眩晕
    -- 根据level与玩家属性计算伤害
  end
end

function Zhangliang:getSkill1Particleid ()
  local teamid = ActorHelper:getTeam(self.objid)
  local particleid
  if (teamid == 1) then
    particleid = BaseConstant.BODY_EFFECT.LIGHT37
  elseif (itemid == 2) then
    particleid = BaseConstant.BODY_EFFECT.LIGHT36
  else
    particleid = BaseConstant.BODY_EFFECT.LIGHT38
  end
  return particleid
end

-- 使用二技能
function Zhangliang:useSkill2 ()
  local innerSize, outerSize = 4, 6
  local player = PlayerHelper:getPlayer(self.objid)
  local pos = ActorHelper:getMyPosition(self.objid)
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, self.objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, self.objid, false)
  end
  if (not(objids) or #objids == 0) then -- 外圈没有找到目标
    local angle = ActorHelper:getFaceYaw(self.objid)
    self:generateSkill2(pos, angle, innerSize)
  else -- 外圈找到目标
    local nearestObjid, distance = ActorHelper:getNearestActor(objids, pos)
    local targetPos = ActorHelper:getMyPosition(nearestObjid)
    local angle = MathHelper:getActorFaceYaw(MyVector3:new(pos, targetPos))
    if (distance <= innerSize) then -- 在技能范围内
      self:generateSkill2(pos, angle, distance)
    else -- 不在范围内
      self:generateSkill2(pos, angle, innerSize)
    end
    player:lookAt(nearestObjid)
  end
end

-- 清除效果
function Zhangliang:clearSkill2 (info)
  if (info.areaid) then
    -- MySkillHelper:delActiveArea(info.areaid)
    local particleid = self:getSkill2Particleid()
    WorldHelper:stopBodyEffect(info.pos, particleid)
    info.areaid = nil
    local t = self.objid .. self.name .. 2
    TimeHelper:delFnFastRuns(t)
    TimeHelper:delFnContinueRuns(t)
  end
end

-- 生成
function Zhangliang:generateSkill2 (pos, angle, distance)
  local player = PlayerHelper:getPlayer(self.objid)
  local dstPos = MathHelper:getDistancePosition(pos, angle, distance)
  local info = MySkillHelper:getSkillInfo(self.objid, 2)
  self:clearSkill2(info)
  local posBeg = MyPosition:new(dstPos.x - 2, 7, dstPos.z - 2)
  local posEnd = MyPosition:new(dstPos.x + 1, 9, dstPos.z + 1)
  local areaid = AreaHelper:createAreaRectByRange(posBeg, posEnd)
  info.areaid = areaid
  info.pos = dstPos
  local particleid = self:getSkill2Particleid()
  WorldHelper:playBodyEffect(dstPos, particleid, 3)
  -- 一定时间后清除
  local t = self.objid .. self.name .. 2
  TimeHelper:callFnFastRuns(function ()
    self:clearSkill2(info)
  end, 4, t)
  local idx = 1
  TimeHelper:callFnContinueRuns(function ()
    if (idx % 10 == 0) then
      local objids = AreaHelper:getAllPlayersInAreaId(areaid, self.objid, false)
      if (objids and #objids == 0) then
        objids = AreaHelper:getAllCreaturesInAreaId(areaid, self.objid, false)
      end
      if (objids and #objids > 0) then
        local nearestObjid = ActorHelper:getNearestActor(objids, dstPos)
        local attPos = MyPosition:new(dstPos.x, dstPos.y + 2, dstPos.z)
        local projectileid = WorldHelper:spawnProjectileByPos(self.objid, 
          MyMap.ITEM.AMMUNITION1, attPos, attPos, 0)
        MySkillHelper:continueAttack(projectileid, nearestObjid, 4, function ()
          ActorHelper:playHurt(nearestObjid)
        end)
      end
    end
    idx = idx + 1
  end, 4, t)
end

function Zhangliang:getSkill2Particleid ()
  local teamid = ActorHelper:getTeam(self.objid)
  local particleid
  if (teamid == 1) then
    particleid = BaseConstant.BODY_EFFECT.PROMPT10
  elseif (itemid == 2) then
    particleid = BaseConstant.BODY_EFFECT.PROMPT11
  else
    particleid = BaseConstant.BODY_EFFECT.PROMPT9
  end
  return particleid
end

-- 使用三技能
function Zhangliang:useSkill3 ()
  local innerSize = 4
  local player = PlayerHelper:getPlayer(self.objid)
  local pos = player:getMyPosition()
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = innerSize, y = 3, z = innerSize }, self.objid, false)
  if (not(objids) or #objids == 0) then -- 内圈没有找到目标
    ChatHelper:sendSpacedMsg(objid, self.name .. 'skill3', 2, '附近无目标')
  else -- 内圈找到目标
    local nearestObjid = ActorHelper:getNearestActor(objids, pos)
    self:generateSkill3(nearestObjid)
    player:lookAt(nearestObjid)
  end
end

-- 生成
function Zhangliang:generateSkill3 (toobjid)
  ActorHelper:addBuff(toobjid, MyMap.BUFF.CONTROL, 1, 20 * 3) -- 被掌控
end
