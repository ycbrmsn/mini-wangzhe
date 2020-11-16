-- 我的道具类

AdjustCamera = BaseItem:new({ id = MyMap.ITEM.ADJUST_CAMERA })

function AdjustCamera:useItem (objid)
  PlayerHelper:rotateCamera(objid, 0, 0)
  local faceYaw = ActorHelper:getFaceYaw(objid)
  if (faceYaw) then
    local player = PlayerHelper:getPlayer(objid)
    player.yawDiff = faceYaw
  end
end