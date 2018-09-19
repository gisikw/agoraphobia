local redstone = component.proxy(component.list("redstone")())
local SOUTH = 3

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

while true do
  redstone.setOutput(SOUTH, 15)
  redstone.setOutput(SOUTH, 0)
  sleep(60 * 18)
end
