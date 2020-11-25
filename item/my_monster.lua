-- 我的怪物
BaseSoldier = {}

function BaseSoldier:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseSoldier:newSolders (num)
  local objids = WorldHelper:spawnCreature(self.initPos.x, self.initPos.y, self.initPos.z, self.actorid, num)
  if (objids and #objids > 0) then
    for i, objid in ipairs(objids) do
      CreatureHelper:closeAI(objid)
      self:addSoldier(objid)
    end
  end
end

-- 加入小兵
function BaseSoldier:addSoldier (objid)
  local o = { objid = objid }
  setmetatable(o, self)
  self.__index = self
  MyMonsterHelper:addSoldier(o)
end

-- 红方小兵
Soldier1 = BaseSoldier:new({
  team = 1, -- 队伍
  initPos = MyPosition:new(-40, 7, 0),
  toPos = MyPosition:new(40, 7, 0),
})

function Soldier1:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 红方近战兵
Soldier11 = Soldier1:new({
  actorid = MyMap.ACTOR.SOLDIER11,
})

-- 蓝方小兵
Soldier2 = BaseSoldier:new({
  team = 2, -- 队伍
  initPos = MyPosition:new(40, 7, 0),
  toPos = MyPosition:new(-40, 7, 0),
})

function Soldier2:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 蓝方近战兵
Soldier21 = Soldier2:new({
  actorid = MyMap.ACTOR.SOLDIER21,
})