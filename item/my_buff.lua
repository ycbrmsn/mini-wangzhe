-- 我的状态
BaseBuff = {}

function BaseBuff:new (o)
  o = o or {}
  if (o.id) then
    ActorHelper:registerBuff(o)
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseBuff:addBuff (objid)
  -- body
end

function BaseBuff:removeBuff (objid)
  -- body
end

-- 眩晕
Dizzy = BaseBuff:new({ id = MyMap.BUFF.DIZZY, name = 'dizzy' })

function Dizzy:addBuff (objid)
  ActorHelper:playDizzy(objid)
  -- ActorHelper:tryEnableMove(objid, self.name, false)
end

function Dizzy:removeBuff (objid)
  ActorHelper:stopDizzy(objid)
  -- ActorHelper:tryEnableMove(objid, self.name, true)
  -- 迟缓状态
  ActorHelper:addBuff(objid, 8, 3, 20)
end
