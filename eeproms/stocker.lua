-- Stocker eeprom
local modem = component.proxy(component.list("modem")())
local drone = component.proxy(component.list("drone")())
local inv = component.proxy(component.list("inventory_controller")())

local PORT = 6020

-- location: "column|row|shelf"
-- remote: "addr|port"
-- stack: "itemId|size"

function main()
  move(0, 1, 0)
  modem.open(PORT)
  while true do
    local event = {computer.pullSignal()}
    if event[1] == "modem_message" then
      run(select(6, event))
    end
  end
end

local commands = {
  CHECK = function(location, remote)
    local col, row, shelf = split(location, "|")
    local addr, port = split(remote, "|")
    col = tonumber(col)
    row = tonumber(row)
    shelf = tonumber(shelf)
    local side is 5
    if col % 2 then
      side = 4
    end
    moveToNeutral()
    navigateTo(col, row, shelf)
    local contents = ""
    for i = 1,27 do
      local stack = inv.getStackInSlot(side, i)
      if stack then
        contents = contents .. stack.id .. "," .. stack.size .. "/" .. stack.maxSize
      end
      contents = contents .. "|"
    end
    contents = contents:sub(1, -2)
    navigateFrom(col, row, shelf)
    moveToBase()
    modem.send(addr, tonumber(port), "CHEST", col, row, shelf, contents)
  end,

  STORE = function(stack, location, slot, remote)
    -- TODO
  end,

  FETCH = function(location, slot, remote)
    -- TODO
  end,
}

local function run(command, ...)
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
  return result
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
  move(0, 5 - row, 9 - shelf)
end

function navigateFrom(col, row, shelf)
  move(0, row - 5, shelf - 9)
  move(-xOffsetForColumn[col], 0, 0)
end

function move(x, y, z, timeout)
  drone.move(x, y, z)
  repeat
    sleep(0.1)
  until drone.getOffset() < 0.4 or drone.getVelocity() == 0
end

-- Test code
-- run("CHECK", "3|2|1", "primary|20")
-- run("STORE", "34|64", "3|2|1", 1, "primary|20")
-- run("FETCH", "3|2|1", 1, "primary|20")
