local robot = component.proxy(component.list("robot")())
local STOPPING_DURABILITY = 0.1

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

while true do
  while true do
    local durability = robot.durability()
    if durability == nil or durability < STOPPING_DURABILITY then
      break
    end
    if robot.detect(3) then
      robot.swing(3)
    end
    sleep(0.2)
  end
  while true do
    local durability = robot.durability()
    if durability ~= nil and durability > STOPPING_DURABILITY then
      break
    end
    sleep(5)
  end
end
