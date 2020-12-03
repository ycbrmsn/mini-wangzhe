-- 我的怪物工具类
MyMonsterHelper = {
  soldierMap = {}, -- { objid -> soldier }
  needDelSoldiers = {}, -- { objid } 需要删除的小兵id
  buildMap = {}, -- { objid -> soldier }
  needDelBuilds = {}, -- { objid } 需要删除的建筑
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
  Tower:newBuild(-16, 7, 1, 1)
  Tower:newBuild(-29, 7, 1, 1)
  Crystal:newBuild(-43, 7, 1, 1)
  Tower:newBuild(17, 7, 1, 2)
  Tower:newBuild(30, 7, 1, 2)
  Crystal:newBuild(44, 7, 1, 2)
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
  for objid, soldier in pairs(self.soldierMap) do
    if (soldier) then
      soldier:run()
    end
  end
  for i = #self.needDelSoldiers, 1, -1 do
    local objid = self.needDelSoldiers[i]
    self.soldierMap[objid] = nil
    table.remove(self.needDelSoldiers, i)
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
  for objid, build in pairs(self.buildMap) do
    if (build) then
      build:run()
    end
  end
  for i = #self.needDelBuilds, 1, -1 do
    local objid = self.needDelBuilds[i]
    self.buildMap[objid] = nil
    table.remove(self.needDelBuilds, i)
  end
end

-- 事件

-- 怪物属性变化
function MyMonsterHelper:actorChangeAttr (objid, actorattr)
  -- body
  if (actorattr == CREATUREATTR.CUR_HP) then
    
  end
end