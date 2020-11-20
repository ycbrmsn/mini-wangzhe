-- 我的建筑
BaseBuild = {}

function BaseBuild:new (o)
  o = o or {}
  if (o.id) then
    ActorHelper:registerBuild(o)
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

