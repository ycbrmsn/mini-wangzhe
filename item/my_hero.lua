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
  if (not(objids) or #objids == 0) then -- 没有目标
    pos2 = player:getDistancePosition(self.remoteSize)
    pos2.y = pos2.y + 1
  else
    local nearestObjid = ActorHelper:getNearestActor(objids, pos)
    player:lookAt(nearestObjid)
    pos2 = ActorHelper:getEyeHeightPosition(nearestObjid)
  end
  local projectileid = WorldHelper:spawnProjectileByPos(self.objid, 
    12051, pos1, pos2, 50)
  -- ActorHelper:playBodyEffect(projectileid, BaseConstant.BODY_EFFECT.PARTICLE24)
end

-- 张良
Zhangliang = BaseHero:new({
  name = 'zhangliang',
  -- attCategory = 2, -- 远程攻击
  phyAtt = 5, -- 物攻
  magAtt = 10, -- 法攻
  maxHp = 1000, -- 最大生命
  maxMp = 1000, -- 最大法力
  speed = 10, -- 移动速度
  skillnames = { '言灵咒印', '言灵壁垒', '言灵侵蚀', '言灵操纵' },
  skillLevels = { 0, 0, 0 }, -- 技能等级
})

function Zhangliang:new (objid)
  local o = {
    objid = objid,
    skillData = {},
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

-- 使用一技能
function Zhangliang:useSkill1 (objid)
  local innerSize, outerSize = 4, 6
  local pos = ActorHelper:getMyPosition(objid)
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  end
  if (not(objids) or #objids == 0) then -- 外圈没有找到目标
    local angle = ActorHelper:getFaceYaw(objid)
    self:generateSkill1(objid, pos, angle, innerSize, level)
  else -- 外圈找到目标
    local nearestObjid, distance = ActorHelper:getNearestActor(objids, pos)
    local targetPos = ActorHelper:getMyPosition(nearestObjid)
    local angle = MathHelper:getActorFaceYaw(MyVector3:new(pos, targetPos))
    ActorHelper:lookAt(objid, nearestObjid)
    if (distance <= innerSize) then -- 在技能范围内
      self:generateSkill1(objid, pos, angle, distance, level)
    else -- 不在范围内
      self:generateSkill1(objid, pos, angle, innerSize, level)
    end
  end
end

-- 清除效果
function Zhangliang:clearSkill1 (objid, info)
  for areaid, v in pairs(info) do
    MySkillHelper:delActiveArea(areaid)
    WorldHelper:stopBodyEffect(v.pos, BaseConstant.BODY_EFFECT.LIGHT37)
    info[areaid] = nil
  end
  TimeHelper:delFnFastRuns(objid .. self.name .. '1')
end

-- 生成
function Zhangliang:generateSkill1 (objid, pos, angle, distance, level)
  local positions = MathHelper:getRegularDistancePositions(pos, angle, distance, 3)
  local info = MySkillHelper:getSkillInfo(objid, 1)
  self:clearSkill1(objid, info)
  for i, v in ipairs(positions) do
    local areaid = AreaHelper:createAreaRect(v, { x = 0, y = 0, z = 0 })
    MySkillHelper:addActiveArea(objid, 1, areaid)
    info[areaid] = { pos = v, level = level }
    WorldHelper:playBodyEffect(v, BaseConstant.BODY_EFFECT.LIGHT37)
  end
  -- 一定时间后清除
  TimeHelper:callFnFastRuns(function ()
    self:clearSkill1(objid, info)
  end, 3, objid .. 'zhangliang1')
end

-- 敌方进入言灵壁垒区域
function Zhangliang:enterSkill1 (objid, areaid)
  -- if (not(ActorHelper:isTheSameTeamActor(objid, skillObj))) then -- 不同队伍
  if (true) then
    local info = MySkillHelper:getSkillInfo(self.objid, 1)
    local pos = info[areaid].pos
    local level = info[areaid].level
    MySkillHelper:delActiveArea(areaid)
    info[areaid] = nil
    WorldHelper:stopBodyEffect(pos, BaseConstant.BODY_EFFECT.LIGHT37)
    -- 眩晕迟缓效果
    ActorHelper:playHurt(objid)
    ActorHelper:addBuff(objid, MyMap.BUFF.DIZZY, 1, 20) -- 眩晕
    -- 根据level与玩家属性计算伤害
  end
end