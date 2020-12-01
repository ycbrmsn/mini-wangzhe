-- 我的游戏工具类
MyGameHelper = {
  index = 0, -- 帧序数
  name = '', -- 称号
  desc = '', -- 描述
}

function MyGameHelper:setGBattleUI ()
  local player = PlayerHelper:getHostPlayer()
  if (player) then
    local story = StoryHelper:getStory()
    local result = PlayerHelper:getGameResults(objid)
    UIHelper:setGBattleUI('left_desc', self.desc)
    UIHelper:setLeftTitle('获得称号：')
    -- UIHelper:setRightTitle(story.name)
    if (player.stealTimes == 0) then
      UIHelper:setRightTitle(self.name)
    elseif (player.stealTimes == 1) then
      UIHelper:setRightTitle('小偷')
    else
      UIHelper:setRightTitle('惯偷')
    end
  end
  UIHelper:setGBattleUI('result', false)
end

function MyGameHelper:setNameAndDesc (name, desc)
  self.name = name
  self.desc = desc
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
      -- LogHelper:debug('---')
      -- LogHelper:debug(math.floor(faceYaw1))
      -- LogHelper:debug(math.floor(faceYaw2))
      -- LogHelper:debug(math.floor(faceYaw3))
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
  TimeHelper:setHour(15)
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
  MyGameHelper:setGBattleUI()
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
  if (second == 2) then
    Soldier11:newSolders(3)
    Soldier21:newSolders(3)
  end
end

-- 任意计时器发生变化
function MyGameHelper:minitimerChange (timerid, timername)
  GameHelper:minitimerChange(timerid, timername)
  -- body
end