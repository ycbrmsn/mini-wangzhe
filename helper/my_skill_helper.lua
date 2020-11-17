-- 我的技能工具类
MySkillHelper = {}

-- 言灵壁垒
function MySkillHelper:yanlingbilei (objid, level)
  LogHelper:debug('言灵壁垒')
  local innerSize, outerSize = 4, 6
  local pos = ActorHelper:getMyPosition(objid)
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  end
  if (not(objids) or #objids == 0) then
    local angle = ActorHelper:getFaceYaw(objid)
    local positions = MathHelper:getRegularDistancePositions(pos, angle, innerSize, 3)
    for i, v in ipairs(positions) do
      BlockHelper:placeBlock(200, v.x, v.y, v.z)
    end
  else

  end
end