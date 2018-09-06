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
    if inv.getStackInSlot(sides.down, i) then
      for j = 1,robot.inventorySize() do
        robot.select(j)
        inv.suckFromSlot(sides.down, i)
      end
    end
  end
end

function goToFirstStorageChest()
  move("u5fl5fr")
end

function processColumn()
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
  move("ul2fl12f2d2l")
end

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
