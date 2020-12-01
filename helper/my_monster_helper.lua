-- 我的怪物工具类
MyMonsterHelper = {
  soldierMap = {}, -- { objid -> soldier }
  needDelSoldiers = {}, -- { objid } 需要删除的小兵id
}

-- 初始化
function MyMonsterHelper:init ()
  -- chick = Chick:new()
  -- dog = Dog:new()
  -- wolf = Wolf:new()
  -- ox = Ox:new()
  -- local monsterModels = { chick, dog, wolf, ox }
  -- MonsterHelper:init(monsterModels)
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

-- 事件

-- 怪物属性变化
function MyMonsterHelper:actorChangeAttr (objid, actorattr)
  -- body
  if (actorattr == CREATUREATTR.CUR_HP) then
    
  end
end