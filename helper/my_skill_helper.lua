-- 我的技能工具类
MySkillHelper = {
  activeAreas = {}, -- { areaid -> { objid = objid, name = name, index = index } }
  zhangliang = {}, -- { objid -> { 1, 2, 3 } }

}

function MySkillHelper:getSkillData (objid, name)
  local data = self[name][objid]
  if (not(data)) then
    data = {}
    self[name][objid] = data
  end
  return data
end

function MySkillHelper:getSkillInfo (objid, name, index)
  local data = MySkillHelper:getSkillData(objid, name)
  return data[index]
end

function MySkillHelper:setSkillInfo (objid, name, index, info)
  local data = MySkillHelper:getSkillData(objid, name)
  data[index] = info
end

function MySkillHelper:addActiveArea (objid, name, index, areaid)
  self.activeAreas[areaid] = { objid = objid, name = name, index = index }
end

function MySkillHelper:delActiveArea (areaid)
  self.activeAreas[areaid] = nil
end

function MySkillHelper:enterActiveArea (objid, areaid)
  local info = self.activeAreas[areaid]
  if (info) then
    if (info.name == 'zhangliang') then
      if (info.index == 1) then
        MySkillHelper:enterYanlingbilei(objid, areaid)
      end
    end
    return true
  else
    return false
  end
end

-- 言灵壁垒
function MySkillHelper:useYanlingbilei (objid, level)
  LogHelper:debug('言灵壁垒')
  local innerSize, outerSize = 3, 5
  local pos = ActorHelper:getMyPosition(objid)
  pos.y = 7
  local objids = ActorHelper:getAllPlayersArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  if (objids and #objids == 0) then
    objids = ActorHelper:getAllCreaturesArroundPos(pos, { x = outerSize, y = 3, z = outerSize }, objid, false)
  end
  if (not(objids) or #objids == 0) then
    local angle = ActorHelper:getFaceYaw(objid)
    local positions = MathHelper:getRegularDistancePositions(pos, angle, innerSize, 3)
    local info = {}
    MySkillHelper:setSkillInfo(objid, 'zhangliang', 1, info)
    for i, v in ipairs(positions) do
      local areaid = AreaHelper:createAreaRect(v, { x = 0, y = 0, z = 0 })
      MySkillHelper:addActiveArea(objid, 'zhangliang', 1, areaid)
      info[areaid] = { pos = v, level = level }
      WorldHelper:playBodyEffect(v, BaseConstant.BODY_EFFECT.LIGHT37)
    end
    -- 一定时间后清除
    TimeHelper:callFnFastRuns(function ()
      for k, v in pairs(info) do
        MySkillHelper:delActiveArea(k)
        WorldHelper:stopBodyEffect(v.pos, BaseConstant.BODY_EFFECT.LIGHT37)
      end
      MySkillHelper:setSkillInfo(objid, 'zhangliang', 1, {})
    end, 3)
  else

  end
end

-- 进入言灵壁垒区域
function MySkillHelper:enterYanlingbilei (objid, areaid)
  local skillObj = self.activeAreas[areaid].objid
  -- if (not(ActorHelper:isTheSameTeamActor(objid, skillObj))) then -- 不同队伍
  if (true) then
    local info = MySkillHelper:getSkillInfo(skillObj, 'zhangliang', 1)
    local pos = info[areaid].pos
    local level = info[areaid].level
    MySkillHelper:delActiveArea(areaid)
    info[areaid] = nil
    WorldHelper:stopBodyEffect(pos, BaseConstant.BODY_EFFECT.LIGHT37)
    -- 眩晕迟缓效果
    ActorHelper:playHurt(objid)
    ActorHelper:addBuff(objid, MyMap.BUFF.DIZZY, 1, 20) -- 眩晕
    -- 根据level与玩家属性计算伤害
  end
end