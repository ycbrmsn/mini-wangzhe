-- 我的怪物工具类
MyMonsterHelper = {
  soldierMap = {}, -- { objid -> soldier }
  needDelSoldiers = {}, -- { objid } 需要删除的小兵id
  buildMap = {}, -- { objid -> soldier }
  needDelBuilds = {}, -- { objid } 需要删除的建筑
  monsterInfos = {}, -- { index -> { soldier -> { 1 = {}, 2 = {} }, build -> ..., player -> ... } }
}

-- 初始化
function MyMonsterHelper:init ()
  -- chick = Chick:new()
  -- dog = Dog:new()
  -- wolf = Wolf:new()
  -- ox = Ox:new()
  -- local monsterModels = { chick, dog, wolf, ox }
  -- MonsterHelper:init(monsterModels)
  MyMonsterHelper:initBuilds()
end

-- 初始化建筑
function MyMonsterHelper:initBuilds ()
  Tower:newBuild(-12, 7, 1, 1)
  Tower:newBuild(-20, 7, 1, 1)
  Crystal:newBuild(-29, 7, 1, 1)
  Tower:newBuild(13, 7, 1, 2)
  Tower:newBuild(21, 7, 1, 2)
  Crystal:newBuild(30, 7, 1, 2)
end

-- 获取行动小兵
function MyMonsterHelper:getSoldier (objid)
  return self.soldierMap[objid]
end

-- 加入行动小兵
function MyMonsterHelper:addSoldier (soldier)
  if (soldier) then
    self.soldierMap[soldier.objid] = soldier
  end
end

-- 移除行动小兵
function MyMonsterHelper:delSoldier (objid)
  table.insert(self.needDelSoldiers, objid)
end

-- 小兵行动
function MyMonsterHelper:runSoldiers ()
  for i = #self.needDelSoldiers, 1, -1 do
    local objid = self.needDelSoldiers[i]
    self.soldierMap[objid] = nil
    table.remove(self.needDelSoldiers, i)
  end
  for objid, soldier in pairs(self.soldierMap) do
    if (soldier) then
      soldier:run()
    end
  end
end

-- 获取有效建筑
function MyMonsterHelper:getBuild (objid)
  return self.buildMap[objid]
end

-- 加入有效建筑
function MyMonsterHelper:addBuild (build)
  if (build) then
    self.buildMap[build.objid] = build
  end
end

-- 移除无效建筑
function MyMonsterHelper:delBuild (objid)
  table.insert(self.needDelBuilds, objid)
end

-- 建筑行为
function MyMonsterHelper:runBuilds ()
  for i = #self.needDelBuilds, 1, -1 do
    local objid = self.needDelBuilds[i]
    self.buildMap[objid] = nil
    table.remove(self.needDelBuilds, i)
  end
  for objid, build in pairs(self.buildMap) do
    if (build) then
      build:run()
    end
  end
end

-- 获取特定队伍的所有敌方
function MyMonsterHelper:getTeamMonsterInfos (teamid)
  local index = MyGameHelper.index
  local monsterInfo = self.monsterInfos[index]
  if (not(monsterInfo)) then
    monsterInfo = {
      player = { [1] = {}, [2] = {} },
      soldier = { [1] = {}, [2] = {} },
      build = { [1] = {}, [2] = {} },
    }
    self.monsterInfos[index] = monsterInfo
    -- 十秒后删除
    TimeHelper:callFnAfterSecond(function ()
      self.monsterInfos[index] = nil
    end, 10)
    -- 玩家
    for i, player in ipairs(PlayerHelper:getActivePlayers()) do
      local x, y, z = ActorHelper:getPosition(player.objid)
      if (x) then
        local hp = PlayerHelper:getHp(player.objid)
        if (hp and hp > 0) then
          player.pos.x, player.pos.y, player.pos.z = x, y, z
          local tid = PlayerHelper:getTeam(player.objid)
          table.insert(monsterInfo.player[tid], player)
        end
      end
    end
    -- 小兵
    for k, soldier in pairs(self.soldierMap) do
      local x, y, z = ActorHelper:getPosition(soldier.objid)
      if (x) then -- 存在
        soldier.pos.x, soldier.pos.y, soldier.pos.z = x, y, z
        table.insert(monsterInfo.soldier[soldier.teamid], soldier)
      end
    end
    -- 建筑
    for k, build in pairs(self.buildMap) do
      local x, y, z = ActorHelper:getPosition(build.objid)
      if (x) then -- 建筑的代表怪物存在
        table.insert(monsterInfo.build[build.teamid], build)
      end
    end
  end
  return monsterInfo.player[teamid], monsterInfo.soldier[teamid], monsterInfo.build[teamid]
end

-- 获取最近的敌人
function MyMonsterHelper:getEmeny (pos, teamid, category, lookSize)
  local players, soldiers, builds = MyMonsterHelper:getTeamMonsterInfos(teamid)
  local enemyMap = { players, soldiers, builds }
  local objid, distance = MyMonsterHelper:getNearestEmeny(enemyMap[category], pos)
  if (distance and distance <= lookSize) then
    return objid, distance
  else
    return nil
  end
end

function MyMonsterHelper:getNearestEmeny (enemies, pos)
  local objid, tempDistance
  for i, enemy in ipairs(enemies) do
    local distance = MathHelper:getDistanceV2(enemy.pos, pos)
    if (not(tempDistance) or tempDistance > distance) then
      tempDistance = distance
      objid = enemy.objid
    end
  end
  return objid, tempDistance
end

-- 事件

-- 怪物属性变化
function MyMonsterHelper:actorChangeAttr (objid, actorattr)
  -- body
  if (actorattr == CREATUREATTR.CUR_HP) then
    
  end
end