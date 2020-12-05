-- 我的玩家类
MyPlayer = BasePlayer:new()

function MyPlayer:new (objid)
  local o = {
    objid = objid,
    x = 0,
    y = 0,
    z = 0,
    yawDiff = 270,
    pos = {},
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

-- 能否操作
function MyPlayer:ableAction ()
  if (ActorHelper:hasBuff(self.objid, MyMap.BUFF.DIZZY)) then
    LogHelper:debug(false)
    return false
  end
  return true
end