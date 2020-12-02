-- 我的建筑
BaseBuild = {
  lookSize = 6, -- 视野
  maxHp = 3000, -- 最大生命
  hp = 3000, -- 生命
  attSpace = 40, -- 攻击间隔
  attCd = 0, -- 攻击冷却
  attSize = 5, -- 攻击距离
  baseAtt = 200, -- 基本攻击
  att = 200, -- 攻击
  targetObjid = nil, -- 目标
  pos = nil, -- 位置
  teamid = 0, -- 队伍
}

function BaseBuild:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 搜索敌人
function BaseBuild:searchEnemy ()
  if (self.targetObjid) then -- 当前有目标
    local objids = ActorHelper:getRadiusActors({ self.targetObjid }, self.pos, self.attSize, true)
    if (#objids == 1) then
      return objids[1]
    end
  end
  -- 当前无目标
  local dim = { x = self.lookSize, y = 3, z = self.lookSize }
  local objids = ActorHelper:getAllCreaturesArroundPos(self.pos, dim, self.teamid, false)
  objids = ActorHelper:getRadiusActors(objids, self.pos, self.attSize, true)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllPlayersArroundPos(self.pos, dim, self.teamid, false)
    objids = ActorHelper:getRadiusActors(objids, self.pos, self.attSize, true)
  end
  if (not(objids) or #objids == 0) then -- 没有目标
    return nil
  else
    return ActorHelper:getNearestActor(objids, self.pos)
  end
end

-- 攻击
function BaseBuild:attack ()
  if (self.targetObjid) then
    self:resetAttCd()
    self:remoteAtt(self.targetObjid)
  end
end

-- 重置攻击冷却
function BaseBuild:resetAttCd ()
  self.attCd = self.attSpace
  TimeHelper:callFnFastRuns(function ()
    self.attCd = 0
    LogHelper:debug('恢复：', self.objid)
  end, 0.05 * self.attSpace, self.objid .. 'resetAttCd')
end

-- 远程攻击
function BaseBuild:remoteAtt (toobjid)
  local pos1 = MyPosition:new(self.pos.x, self.pos.y + 3, self.pos.z)
  local callback = function ()
    ActorHelper:playHurt(toobjid)
    ActorHelper:damageActor(nil, toobjid, self.att)
  end
  local projectileid = WorldHelper:spawnProjectileByPos(nil, 
    MyMap.ITEM.AMMUNITION3, pos1, pos1, 0)
  MySkillHelper:continueAttack(projectileid, toobjid, 4, callback)
end

function BaseBuild:run ()
  if (self.attCd == 0) then
    local objid = self:searchEnemy()
    if (objid) then -- 找到目标
      -- 设置伤害
      if (not(self.targetObjid) or objid ~= self.targetObjid) then -- 目标不同
        self.att = self.baseAtt
      else -- 目标相同
        if (ActorHelper:isPlayer(objid)) then -- 玩家
          self.att = self.att * 2
        end
      end
    end
    self.targetObjid = objid
    self:attack()
  end
end

-- 防御塔
Tower = BaseBuild:new()

function Tower:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Tower:newTower (x, y, z, teamid)
  local tower = self:new({
    pos = MyPosition:new(x, y, z),
    teamid = teamid,
  })
  MyMonsterHelper:addBuild(tower)
end

-- 水晶
Crystal = BaseBuild:new({
  maxHp = 5000, -- 最大生命
  hp = 5000,
  attSpace = 60, -- 攻击间隔
})

function Crystal:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Crystal:newTower (x, y, z, teamid)
  local crystal = self:new({
    pos = MyPosition:new(x, y, z),
    teamid = teamid,
  })
  MyMonsterHelper:addBuild(crystal)
end