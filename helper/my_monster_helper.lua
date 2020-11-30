-- 我的怪物工具类
MyMonsterHelper = {
  soldiers = { [1] = {}, [2] = {} }, -- 记录所有小兵
  delSoldiers = { [1] = {}, [2] = {} }, -- 需要删除的小兵
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

function MyMonsterHelper:addSoldier (soldier)
  if (soldier) then
    table.insert(self.soldiers[soldier.team], soldier)
  end
end

-- 小兵行动
function MyMonsterHelper:runSoldiers ()
  for i, soldiers in ipairs(self.soldiers) do
    for j, soldier in ipairs(soldiers) do
      soldier:run()
    end
  end
  for i, v in ipairs(self.delSoldiers) do
    
  end
end