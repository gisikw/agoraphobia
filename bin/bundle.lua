-- OpenOS Usage: bundle file.lua output.lua
-- Unix Usage: lua bundle.lua file.lua output.lua

local REQUIRE_PATTERN = "^(.*)require%([\"']([^\"']+)[\"']%)(.*)$"

arg = {...}
if #arg ~= 2 then
  print "Usage: bundle input.lua output.lua"
  return 1
end
local scanContent
local defined = {}

local function define(name, buffer)
  if not defined[name] then
    local path = package.searchpath(name, package.path)
    local lines = scanContent(path, buffer)
    buffer:write("bundle.__defs[\"" .. name .. "\"] = function()\n")
    for _, line in ipairs(lines) do
      buffer:write(line .. "\n")
    end
    buffer:write("end\n")
    defined[name] = true
  end
end

function scanContent(path, buffer)
  local file = io.open(path)
  local lines = {}
  local line = file:read("*l")
  while line do
    line = line:gsub(REQUIRE_PATTERN, function(prefix, name, suffix)
      define(name, buffer)
      return prefix .. "bundle[\"" .. name .. "\"]" .. suffix
    end)
    table.insert(lines, line)
    line = file:read("*l")
  end
  file:close()
  return lines
end

local function main()
  local buffer = io.open(arg[2], "w")
  buffer:write([[bundle = { __defs = { } }
setmetatable(bundle, {
  __index = function(self, key)
    local result
    if self.__defs[key] then
      result = self.__defs[key]()
      self[key] = result 
      return result
    end
  end
})
]])
  local lines = scanContent(arg[1], buffer)
  buffer:write("\n")
  for _, line in ipairs(lines) do
    buffer:write(line .. "\n")
  end
  buffer:close()
end

main()
