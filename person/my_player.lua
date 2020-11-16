-- 我的玩家类
MyPlayer = BasePlayer:new()

function MyPlayer:new (objid)
  local o = {
    objid = objid,
    x = 0,
    y = 0,
    z = 0,
    yawDiff = 0, -- 朝向与镜头角度差值
  }
  o.action = BasePlayerAction:new(o)
  o.attr = BasePlayerAttr:new(o)
  o.attr.defeatedExp = 0
  setmetatable(o, self)
  self.__index = self
  return o
end

function MyPlayer:initMyPlayer ()
  
end
