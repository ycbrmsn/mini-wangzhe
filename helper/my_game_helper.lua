-- 我的游戏工具类
MyGameHelper = {
  index = 0, -- 帧序数
  name = '', -- 称号
  desc = '', -- 描述
  ammus = {
    [1] = {}, -- 英雄投掷物
    [2] = {}, -- 英雄投掷物
    [3] = {}, -- 小兵投掷物
    [4] = {}, -- 小兵投掷物
    [5] = {}, -- 建筑投掷物
    [6] = {}, -- 建筑投掷物
  },
  ammuItemids = { MyMap.ITEM.AMMUNITION1, MyMap.ITEM.AMMUNITION2, MyMap.ITEM.AMMUNITION3 },
  ammuIndexs = { 1, 3, 5 }, -- 使用弹药序数
  ammuPos = MyPosition:new(0, 5, 0), -- 弹药创建位置
  ammuBuff = 30, -- 弹药缓存数量
  ammuCache = false,
}

function MyGameHelper:init ()
  if (self.ammuCache) then
    MyGameHelper:initAmmus()
  end
end

-- 初始化弹药
function MyGameHelper:initAmmus ()
  for i, v in ipairs(self.ammus) do
    local itemid -- 投掷物id
    for j = 1, self.ammuBuff do
      itemid = self.ammuItemids[math.ceil(i / 2)]
      -- LogHelper:debug(itemid, '-', i)
      local projectileid = WorldHelper:spawnProjectileByPos(nil, 
        itemid, self.ammuPos, self.ammuPos, 0)
      table.insert(v, { objid = projectileid, isUsed = false })
    end
  end
end

-- 获取一个弹药 category类型：1英雄2小兵3建筑
function MyGameHelper:getAmmu (category, pos)
  local itemid = self.ammuItemids[category]
  if (self.ammuCache) then
    local index = self.ammuIndexs[category]
    local objid
    for i, v in ipairs(self.ammus[index]) do
      if (not(v.isUsed)) then
        v.isUsed = true
        local pos = ActorHelper:getMyPosition(v.objid)
        if (pos) then -- 弹药还存在
          ActorHelper:setMyPosition(v.objid, pos)
          return v.objid
        end
      end
    end
    -- 没找到，则一秒后重新填满
    TimeHelper:callFnFastRuns(function ()
      for i = 1, self.ammuBuff do
        local projectileid = WorldHelper:spawnProjectileByPos(nil, 
          itemid, self.ammuPos, self.ammuPos, 0)
         table.insert(self.ammus[index], { objid = projectileid, isUsed = false })
      end
    end, 1)
    if (index % 2 == 0) then -- 偶数
      self.ammuIndexs[category] = index - 1
    else
      self.ammuIndexs[category] = index + 1
    end
    return MyGameHelper:getAmmu(category)
  else
    return WorldHelper:spawnProjectileByPos(self.objid, itemid, pos, pos, 0)
  end
end

-- 改变玩家朝向
function MyGameHelper:changePlayerFace ()
  PlayerHelper:everyPlayerDoSomeThing(function (player)
    local pos = player:getMyPosition()
    -- if (pos and self.index % 20 == 0) then -- player.x ~= pos.x and player.z ~= pos.z
    if (pos and player.x ~= pos.x and player.z ~= pos.z) then 
      local mv2 = MyVector3:new(player.x, player.y, player.z, pos.x, pos.y, pos.z)
      local faceYaw2 = MathHelper:getActorFaceYaw(mv2)
      -- ActorHelper:setFaceYaw(player.objid, faceYaw2)
      -- local x, y, z = ActorHelper:getFaceDirection(player.objid)
      -- local mv1 = MyVector3:new(x, y, z)
      -- local faceYaw1 = MathHelper:getActorFaceYaw(mv1)
      -- local faceYaw3 = ActorHelper:getFaceYaw(player.objid)
      PlayerHelper:rotateCamera(player.objid, faceYaw2 - player.yawDiff, 0)
      player.x, player.y, player.z = pos.x, pos.y, pos.z
    end
  end)
end

-- 事件

-- 开始游戏
function MyGameHelper:startGame ()
  LogHelper:debug('开始游戏')
  GameHelper:startGame()
  MyBlockHelper:init()
  MyActorHelper:init()
  MyMonsterHelper:init()
  MyAreaHelper:init()
  MyStoryHelper:init()
  -- body
  MyGameHelper:initAmmus()
end

-- 游戏运行时
function MyGameHelper:runGame ()
  GameHelper:runGame()
  self.index = self.index + 1
  -- body
  MyGameHelper:changePlayerFace()
end

-- 结束游戏
function MyGameHelper:endGame ()
  GameHelper:endGame()
  -- body
end

-- 世界时间到[n]点
function MyGameHelper:atHour (hour)
  GameHelper:atHour(hour)
end

-- 世界时间到[n]秒
function MyGameHelper:atSecond (second)
  GameHelper:atSecond(second)
  -- body
  -- 小兵前进
  MyMonsterHelper:runSoldiers()
  -- 建筑
  MyMonsterHelper:runBuilds()
  if (second % 30 == 2) then
    Soldier11:newSolders(2)
    Soldier12:newSolders(1)
    Soldier13:newSolders(1)
    Soldier21:newSolders(2)
    Soldier22:newSolders(1)
    Soldier23:newSolders(1)
  end
end

-- 任意计时器发生变化
function MyGameHelper:minitimerChange (timerid, timername)
  GameHelper:minitimerChange(timerid, timername)
  -- body
end