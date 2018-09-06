local robot = require("robot")
local inv = require("component").inventory_controller
local sides = require("sides")

local COLUMN_HEIGHT = 3

function main()
  goToPickupChest()
  fillInventory()
  goToFirstStorageChest()
  for i = 1,3 do
    for j = 1,10 do
      processColumn() 
    end
    move("r")
  end
  returnToCharger()
end

function goToPickupChest()
  move("2u6fr6f2d")
end

function fillInventory()
  for i = 1,inv.getInventorySize(sides.down) do
    for j = 1,robot.inventorySize() do
      robot.select(j)
      inv.suckFromSlot(sides.down, i)
    end
  end
end

function goToFirstStorageChest()
  move("5fl5f2ur")
end

function processColumn()
  -- Assume we're at the top of the leftmost column
  for i = 1,(COLUMN_HEIGHT-1) do
    processChest()
    robot.move("d")
  end
  processChest()
  move("u"..(COLUMN_HEIGHT - 1).."rfl")
end

function processChest()
  valid = {}
  for i = 1,inv.getInventorySize(sides.front) do
    stack = inv.getStackInSlot(sides.front, i)
    if stack then
      valid[stack.name] = true
    end
  end
  for i = 1,robot.inventorySize() do
    robot.select(i)
    stack = inv.getStackInInternalSlot()
    if stack and valid[stack.name] then
      for j = 1,inv.getInventorySize(sides.front) do
        inv.dropIntoSlot(sides.front, j)
      end
    end
  end
end

function returnToCharger()
  move("3ul2fl13f2d2l")
end

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

main()
