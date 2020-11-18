-- 我的英雄
BaseHero = {} 

function BaseHero:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseHero:shift (objid)
  PlayerHelper:rotateCamera(objid, 0, 0)
  TimeHelper:callFnAfterSecond(function ()
    local faceYaw = ActorHelper:getFaceYaw(objid) % 360
    print(faceYaw)
    if (faceYaw > 269 and faceYaw < 270) then
      ActorHelper:addBuff(objid, MyMap.BUFF.ZHANGLIANG, 1)
    else
      ChatHelper:sendMsg(objid, '矫正朝向中，请勿转动。')
      self:shift(objid)
    end
  end, 1)
end

-- 张良
Zhangliang = BaseHero:new({
  name = 'zhangliang',
  level = 1, -- 人物等级
  phyAtt = 5, -- 物攻
  magAtt = 10, -- 法攻
  maxHp = 1000,
  maxMp = 1000,
  speed = 10,
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