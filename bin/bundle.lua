-- OpenOS Usage: bundle file.lua output.lua
-- Unix Usage: lua bundle.lua file.lua output.lua

local REQUIRE_PATTERN = "^(.*)require%([\"']([^\"']+)[\"']%)(.*)$"
local HEADER = [[bundle = { __defs = { } }
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
]]

arg = {...}
if #arg ~= 2 then
  print "Usage: bundle input.lua output.lua"
  return 1
end

local function parseDependencyTree(paths, deps)
  if #paths == 0 then return deps end
  local file = io.open(table.remove(paths, 1))
  local line = file:read("*l")
  while line do
    line:gsub(REQUIRE_PATTERN, function(prefix, name, suffix)
      if not deps[name] then
        local path = package.searchpath(name, package.path)
        table.insert(paths, path)
        deps[name] = path
      end
    end)
    line = file:read("*l")
  end
  file:close()
  return parseDependencyTree(paths, deps)
end

local function appendFile(file, buffer)
  local line = file:read("*l")
  while line do
    buffer:write(line:gsub(REQUIRE_PATTERN, function(prefix, name, suffix)
      return prefix .. "bundle[\"" .. name .. "\"]" .. suffix
    end) .. "\n")
    line = file:read("*l")
  end
  file:close()
end

local function main()
  dependencies = parseDependencyTree({ arg[1] }, {})
  local buffer = io.open(arg[2], "w")
  buffer:write(HEADER)
  for name, path in pairs(dependencies) do
    buffer:write("bundle.__defs[\"" .. name .. "\"] = function()\n")
    appendFile(io.open(path), buffer)
    buffer:write("end\n")
  end
  appendFile(io.open(arg[1]), buffer)
end

main()
