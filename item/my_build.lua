-- 我的建筑
BaseBuild = {
  lookSize = 6, -- 视野
  maxHp = 5000, -- 最大生命
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
  o.hp = o.maxHp
  return o
end

function BaseBuild:newBuild (x, y, z, teamid)
  local pos = MyPosition:new(x, y, z)
  local objids = WorldHelper:getCreaturesAroundPos(pos, 4, 2)
  objids = ActorHelper:getSpecificActors(objids, MyMap.ACTOR.BUILD)
  if (#objids > 0) then
    local objid = objids[1]
    CreatureHelper:closeAI(objid)
    CreatureHelper:setMaxHp(objid, self.maxHp)
    CreatureHelper:setHp(objid, self.hp)
    CreatureHelper:setTeam(objid, teamid)
    ActorHelper:setPosition(objid, x, y + 2.5, z)
    CreatureHelper:showHp(objid)
    local build = self:new({
      objid = objid,
      pos = pos,
      teamid = teamid,
    })
    MyMonsterHelper:addBuild(build)
  else
    TimeHelper:callFnFastRuns(function ()
      self:newBuild(x, y, z, teamid)
    end, 1)
  end
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

-- 生命变化
function BaseBuild:changeHp (hp)
  self.hp = hp
  if (hp <= 0) then
    MyMonsterHelper:delBuild(self.objid)
    if (self.name == 'crystal') then
      LogHelper:debug('被毁水晶队伍：', self.teamid, '-', self.teamid % 2)
      TeamHelper:setTeamResults(self.teamid % 2 + 1, 1)
    else
      local areaid = AreaHelper:createAreaRect(self.pos, { x = 2, y = 1, z = 2 })
      AreaHelper:clearAllBlock(areaid, MyMap.BLOCK.AIR)
      AreaHelper:clearAllBlock(areaid, MyMap.BLOCK.TOWER)
      -- AreaHelper:clearAllBlock(areaid, MyMap.BLOCK.CRYSTAL)
    end
  end
end

-- 防御塔
Tower = BaseBuild:new({
  name = 'tower', -- 名称
})

function Tower:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 水晶
Crystal = BaseBuild:new({
  maxHp = 10000, -- 最大生命
  attSpace = 60, -- 攻击间隔
  name = 'crystal', -- 名称
})

function Crystal:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end
