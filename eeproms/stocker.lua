-- Stocker eeprom
local modem = component.proxy(component.list("modem")())
local drone = component.proxy(component.list("drone")())
local inv = component.proxy(component.list("inventory_controller")())

local PORT = 6020

function main()
  move(0, 2, 0)
  modem.open(PORT)
  while true do
    local event = {computer.pullSignal()}
    if event[1] == "modem_message" then
      run(table.unpack(event))
    end
  end
end

local commands = {
  CHECK = function(location, remote)
    local col, row, shelf, side = parseLocation(location)
    local addr, port = parseRemote(remote)
    moveToNeutral()
    navigateTo(col, row, shelf)
    local contents = ""
    for i = 1,27 do
      local stack = inv.getStackInSlot(side, i)
      if stack then
        contents = contents .. stack.label .. "," .. stack.size .. "/" .. stack.maxSize
      end
      contents = contents .. "|"
    end
    contents = contents:sub(1, -2)
    navigateFrom(col, row, shelf)
    moveToBase()
    modem.send(addr, port, "CHEST", col, row, shelf, contents)
  end,

  STORE = function(inputSlot, size, location, storageSlot, remote)
    local col, row, shelf, side = parseLocation(location)
    local addr, port = parseRemote(remote)
    inv.suckFromSlot(1, inputSlot, size)
    moveToNeutral()
    navigateTo(col, row, shelf)
    inv.dropIntoSlot(side, storageSlot)
    navigateFrom(col, row, shelf)
    moveToBase()
    modem.send(addr, port, "STORED", inputSlot, size, col, row, shelf)
  end,

  FETCH = function(location, storageSlot, size, remote)
    local col, row, shelf, side = parseLocation(location)
    local addr, port = parseRemote(remote)
    moveToNeutral()
    navigateTo(col, row, shelf)
    inv.suckFromSlot(side, storageSlot, size)
    navigateFrom(col, row, shelf)
    move(1, 0, 2)
    sleep(1)
    inv.dropIntoSlot(1, 1)
    drone.use(1)
    move(-1, 0, -2)
    moveToBase()
    modem.send(addr, port, "FETCHED", location, storageSlot, size)
  end,
}

function run(_, _, _, _, _, command, ...)
  if commands[command] then
    -- Reply with an acknowledgement
    commands[command](...)
  end
end

function split(s, delimiter)
  result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return table.unpack(result)
end

function moveToNeutral()
  move(0, -1, 0)  
end

function moveToBase()
  move(0, 1, 0)
end

local xOffsetForColumn = {-4, -1, -1, 2, 2, 5, 5, 8, 8}

function navigateTo(col, row, shelf)
  move(xOffsetForColumn[col], 0, 0)
  move(0, shelf - 9, 5 - row)
end

function navigateFrom(col, row, shelf)
  move(0, 9 - shelf, row - 5)
  move(-xOffsetForColumn[col], 0, 0)
end

function move(x, y, z, timeout)
  drone.move(x, y, z)
  repeat
    sleep(0.1)
  until drone.getOffset() < 0.4 or drone.getVelocity() == 0
end

function parseLocation(location)
  local col, row, shelf = split(location, "|")
  col = tonumber(col)
  local side = 4
  if col % 2 then
    side = 5
  end
  return col, tonumber(row), tonumber(shelf), side
end

function parseRemote(remote)
  local addr, port = split(remote, "|")
  return addr, tonumber(port)
end

function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

main()
