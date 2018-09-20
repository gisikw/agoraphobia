-- Shallow Clone Repository
-- oaf clone gisikw/agoraphobia

-- Pull Latest Files from Master
-- oaf pull

-- Push Latest Files to Master
-- oaf commit -m "Some message"

local fs = require("filesystem")
local shell = require("shell")

local args = shell.parse(...)
if #args == 0 or not commands[args[1]] then
  io.write("Usage: oaf <command>\n")
  return 1
end

local ec = 0
local commands = {
  clone = function(args)
    print("I want to clone")
  end,

  pull = function(args)
    print("I want to pull")
  end,

  commit = function(args)
    print("I want to commit")
  end
}

commands[args[1]](args)
return ec
