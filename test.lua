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
  robot.useDown()
  move("f")
  robot.useDown()
end

function replenishSupplies()
  -- TODO
end

-- Requires 12 wheat
function feedCycle()
  move("f")
  replenishSupplies()
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

function plantRow()
  for i = 1,6 do
    robot.useDown()
    move("f")
  end
  robot.useDown()
end

function cycleFarm()
  robot.use()
  os.sleep(5)
  robot.use()
  move("d2rfl3f2r")
  plantRow()
  move("lfl")
  plantRow()
  move("rfr")
  plantRow()
  move("lfl")
  plantRow() 
end

function plantCycle()
  move("f")
  replenishSupplies()
  move("l2f5ur5fr5fl")
  cycleFarm()
  move("2r3fl7fu")
  cycleFarm()
  move("l4fur2fr5f5dr2fl")
end

plantCycle()
