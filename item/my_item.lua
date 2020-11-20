-- 我的道具

function BaseItem:check (objid, skillname)
  if (skillname) then
    local player = PlayerHelper:getPlayer(objid)
    if (not(player:ableUseSkill(skillname))) then
      return
    end
  end
  if (self.cd) then
    local ableUseSkill = ItemHelper:ableUseSkill(objid, self.id, self.cd)
    if (not(ableUseSkill)) then
      self.cdReason = self.cdReason or '技能冷却中'
      ChatHelper:sendSystemMsg(self.cdReason, objid)
      return
    end
  end
end

-- 调整视角
AdjustCamera = BaseItem:new({ id = MyMap.ITEM.ADJUST_CAMERA })

function AdjustCamera:useItem (objid)
  PlayerHelper:rotateCamera(objid, 0, 0)
  TimeHelper:callFnAfterSecond(function ()
    local faceYaw = ActorHelper:getFaceYaw(objid)
    LogHelper:debug(faceYaw % 360)
  --   if (faceYaw) then
  --     local player = PlayerHelper:getPlayer(objid)
  --     player.yawDiff = faceYaw
  --   end
  end, 1)
end

ToZhangliang = BaseItem:new({ id = MyMap.ITEM.ZHANGLIANG })

function ToZhangliang:useItem (objid)
  if (BackpackHelper:removeGridItemByItemID(objid, self.id, 1)) then
    Zhangliang:shift(objid)
  end
end

-- 言灵壁垒
Yanlingbilei = BaseItem:new({
  id = MyMap.ITEM.YANLINGBILEI,
  cd = 10,
  name = 'zhangliang',
})

function Yanlingbilei:selectItem (objid, index)
  local hero = MySkillHelper:getHero(objid)
  if (not(hero) or hero.name ~= self.name) then
    ChatHelper:sendSpacedMsg(objid, self.name, 2, '你无法使用此技能')
  else
    ItemHelper:recordUseSkill(objid, self.id, self.cd)
    hero:useSkill1(objid)
  end
end

function Yanlingbilei:useItem (objid)
  -- body
end

-- 言灵命数
Yanlingmingshu = BaseItem:new({
  id = MyMap.ITEM.YANLINGMINGSHU,
  cd = 10,
  name = 'zhangliang',
})

function Yanlingmingshu:selectItem (objid, index)
  local hero = MySkillHelper:getHero(objid)
  if (not(hero) or hero.name ~= self.name) then
    ChatHelper:sendSpacedMsg(objid, self.name, 2, '你无法使用此技能')
  else
    ItemHelper:recordUseSkill(objid, self.id, self.cd)
    hero:useSkill2(objid)
  end
end

function Yanlingmingshu:useItem (objid)
  -- body
end
