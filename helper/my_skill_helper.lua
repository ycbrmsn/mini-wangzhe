-- 我的技能工具类
MySkillHelper = {
  activeAreas = {}, -- { areaid -> { objid = objid, name = name, index = index } }
  -- heroData = {}, -- { name -> { objid -> { 1, 2, 3 } } }
  heroData = {}, -- { objid -> hero }
}

-- 注册英雄
function MySkillHelper:register (o)
  self.heroData[o.objid] = o
end

-- 获取英雄
function MySkillHelper:getHero (objid)
  return self.heroData[objid]
end

-- 获取英雄技能数据
function MySkillHelper:getSkillData (objid)
  local hero = MySkillHelper:getHero(objid)
  local data = hero.skillData
  if (not(data)) then
    data = {}
    self.heroData[objid].skillData = data
  end
  return data
end

-- 获取某技能信息
function MySkillHelper:getSkillInfo (objid, index)
  local data = MySkillHelper:getSkillData(objid)
  local info = data[index]
  if (not(info)) then
    info = {}
    data[index] = info
  end
  return info
end

-- 设置某技能信息
function MySkillHelper:setSkillInfo (objid, index, info)
  local data = MySkillHelper:getSkillData(objid)
  data[index] = info
end

-- 新增有效区域
function MySkillHelper:addActiveArea (objid, index, areaid)
  self.activeAreas[areaid] = { objid = objid, index = index }
end

-- 删除有效区域
function MySkillHelper:delActiveArea (areaid)
  self.activeAreas[areaid] = nil
end

-- 进入有效区域，查询对应英雄区域作用
function MySkillHelper:enterActiveArea (objid, areaid)
  local info = self.activeAreas[areaid]
  if (info) then
    local hero = self.heroData[info.objid]
    if (info.index == 1) then
      hero:enterSkill1(objid, areaid)
    elseif (info.index == 2) then
      hero:enterSkill2(objid, areaid)
    elseif (info.index == 3) then
      hero:enterSkill3(objid, areaid)
    elseif (info.index == 4) then
      hero:enterSkill4(objid, areaid)
    end
    return true
  else
    return false
  end
end

-- -- 施展言灵壁垒
-- function MySkillHelper:useYanlingbilei (objid, level)
--   local innerSize, outerSize = 4, 6
--   local pos = ActorHelper:getMyPosition(objid)
--   pos.y = 7
--   local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
--   if (objids and #objids == 0) then
--     objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
--   end
--   if (not(objids) or #objids == 0) then -- 外圈没有找到目标
--     local angle = ActorHelper:getFaceYaw(objid)
--     MySkillHelper:generateYanlingbilei(objid, pos, angle, innerSize, level)
--   else -- 外圈找到目标
--     local nearestObjid, distance = ActorHelper:getNearestActor(objids, pos)
--     local targetPos = ActorHelper:getMyPosition(nearestObjid)
--     local angle = MathHelper:getActorFaceYaw(MyVector3:new(pos, targetPos))
--     ActorHelper:lookAt(objid, nearestObjid)
--     if (distance <= innerSize) then -- 在技能范围内
--       MySkillHelper:generateYanlingbilei(objid, pos, angle, distance, level)
--     else -- 不在范围内
--       -- local dstPos = MathHelper:getPos2PosInLineDistancePosition(pos, targetPos, innerSize)
--       -- print(dstPos)
--       -- ActorHelper:tryMoveToPos(objid, dstPos.x, dstPos.y + 1, dstPos.z)
--       -- LogHelper:debug('寻路')
--       -- ChatHelper:sendSpacedMsg(objid, '言灵壁垒', 2, '目标不在技能范围内')
--       MySkillHelper:generateYanlingbilei(objid, pos, angle, innerSize, level)
--     end
--   end
-- end

-- -- 清除效果
-- function MySkillHelper:clearYanlingbilei (objid, info)
--   for areaid, v in pairs(info) do
--     MySkillHelper:delActiveArea(areaid)
--     WorldHelper:stopBodyEffect(v.pos, BaseConstant.BODY_EFFECT.LIGHT37)
--     info[areaid] = nil
--   end
--   -- MySkillHelper:setSkillInfo(objid, 'zhangliang', 1, {})
--   TimeHelper:delFnFastRuns(objid .. 'zhangliang1')
-- end

-- -- 生成
-- function MySkillHelper:generateYanlingbilei (objid, pos, angle, distance, level)
--   local positions = MathHelper:getRegularDistancePositions(pos, angle, distance, 3)
--   local info = MySkillHelper:getSkillInfo(objid, 'zhangliang', 1)
--   MySkillHelper:clearYanlingbilei(objid, info)
--   for i, v in ipairs(positions) do
--     local areaid = AreaHelper:createAreaRect(v, { x = 0, y = 0, z = 0 })
--     MySkillHelper:addActiveArea(objid, 'zhangliang', 1, areaid)
--     info[areaid] = { pos = v, level = level }
--     WorldHelper:playBodyEffect(v, BaseConstant.BODY_EFFECT.LIGHT37)
--   end
--   -- 一定时间后清除
--   TimeHelper:callFnFastRuns(function ()
--     MySkillHelper:clearYanlingbilei(objid, info)
--   end, 3, objid .. 'zhangliang1')
-- end

-- -- 进入言灵壁垒区域
-- function MySkillHelper:enterYanlingbilei (objid, areaid)
--   local skillObj = self.activeAreas[areaid].objid
--   -- if (not(ActorHelper:isTheSameTeamActor(objid, skillObj))) then -- 不同队伍
--   if (true) then
--     local info = MySkillHelper:getSkillInfo(skillObj, 'zhangliang', 1)
--     local pos = info[areaid].pos
--     local level = info[areaid].level
--     MySkillHelper:delActiveArea(areaid)
--     info[areaid] = nil
--     WorldHelper:stopBodyEffect(pos, BaseConstant.BODY_EFFECT.LIGHT37)
--     -- 眩晕迟缓效果
--     ActorHelper:playHurt(objid)
--     ActorHelper:addBuff(objid, MyMap.BUFF.DIZZY, 1, 20) -- 眩晕
--     -- 根据level与玩家属性计算伤害
--   end
-- end