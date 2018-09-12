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
  function plantRow(n)
    f()
    for i=1,n-1 do
      move(0, 0, 1)
      f()
    end
  end
  move(-6, 0, -4)
  plantRow(6)
  move(1, 0, -6)
  plantRow(8)
  move(1, 0, -8)
  plantRow(10)
  move(1, 0, -10)
  f()
  move(0, 0, 1)
  f()
  move(0, 0, 2)
  plantRow(6)
  move(0, 0, 2)
  f()
  move(0, 0, 1)
  f()
  move(1, 0, -12)
  plantRow(14)
  move(1, 0, -14)
  plantRow(14)
  move(1, 0, -14)
  plantRow(14)
  move(1, 0, -14)
  plantRow(14)
  move(1, 0, -14)
  plantRow(14)
  move(1, 0, -14)
  plantRow(14)
  move(1, 0, -13)
  f()
  move(0, 0, 1)
  f()
  move(0, 0, 2)
  plantRow(6)
  move(0, 0, 2)
  f()
  move(0, 0, 1)
  f()
  move(1, 0, -10)
  plantRow(10)
  move(1, 0, -8)
  plantRow(8)
  move(1, 0, -6)
  plantRow(6)
end

function returnToCharger()
  move(-6, 0, -3)
  move(0, -3, -1)
end

function move(x, y, z)
  drone.move(x, y, z)
  repeat
    sleep(0.1)
  until drone.getVelocity() == 0
end

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

main()
