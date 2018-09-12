local drone = component.proxy(component.list("drone")())
local inv = component.proxy(component.list("inventory_controller")())
local modem = component.proxy(component.list("modem")())

function main()
  sleep(10)
  moveToAboveChest()
  drone.select(1)
  for i = 28,45 do
    local hasCount = drone.count()
    if hasCount == 64 then
      local currentSelect = drone.select()
      if currentSelect == 8 then
        break
      else
        drone.select(currentSelect + 1)
      end
    end
    local available = inv.getStackInSlot(0, i).size
    if available > 1 then
      inv.suckFromSlot(0, i, math.min(available - 1, 64 - hasCount))
    end
  end
  drone.select(1)
  ascendToFarm()
  local startTime = computer.uptime()
  repeat
    modem.broadcast(4723)
    sleep(0.2)
  until computer.uptime() > startTime + 2
  sleep(10)
  navigateFarmLayout(function()
    if drone.count() == 0 then
      drone.select(drone.select() + 1)
    end
    drone.place(0)
  end)
  returnToCharger()
end

function moveToAboveChest()
  move(0, 0, 3)
end

function ascendToFarm()
  move(0, 4, -1)
end

function navigateFarmLayout(f)
  move(-7, 0, -7)
  function plantRow(n)
    f()
    for i=1,n do
      move(0, 0, 1)
      f()
    end
  end
  plantRow(12)
  plantRow(12)
  for i=1,12 do
    plantRow(14)
    move(1, 0, -14)
  end
  plantRow()
end

function returnToCharger()
  move(-6, 0, -7)
  move(0, -4, -2)
end

function move(x, y, z)
  drone.move(x, y, z)
  repeat
    sleep(0.1)
  until drone.getOffset() < 0.4
end

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

main()
