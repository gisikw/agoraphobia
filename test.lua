local robot = require("robot")

-- Usage: move("3fur2b")
function move(path)
  local move_dir = {
    l = robot.turnLeft,
    r = robot.turnRight,
    f = robot.forward,
    b = robot.back,
    u = robot.up,
    d = robot.down
  }
  for step in string.gmatch(path, "%d*%a") do
    local quantity = string.match(step, "%d+") or 1
    local direction = string.sub(step, -1)
    for i = 1,quantity do 
      move_dir[direction]()
    end
  end
end

function feedCage()
  -- robot.useDown()
  move("f")
  -- robot.useDown()
end

function feedCycle()
  move("f")
  -- TODO: Get stuff from chest
  move("4fl")
  feedCage()
  move("4fl")
  feedCage()
  move("7f")
  feedCage()
  move("l4f")
  feedCage()
  move("4fl")
  feedCage()
  move("7f")
  feedCage()
  move("l4fl5f2r")
end

feedCycle()
