local redstone = component.proxy(component.list("redstone")())
local modem = component.proxy(component.list("modem")())

local PORT = 4723
local UP = 1

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

modem.open(PORT)
while true do
  local evt,_,_,port = computer.pullSignal()
  if evt == "modem_message" and port == PORT then
    redstone.setOutput(UP, 15)
    redstone.setOutput(UP, 0)
    sleep(3)
    redstone.setOutput(UP, 15)
    redstone.setOutput(UP, 0)
  end
end
