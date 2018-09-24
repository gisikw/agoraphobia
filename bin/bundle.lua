-- Usage: 
--   OpenOS: bundle input output
--   Unix:   lua bundle.lua input output
local REQUIRE_PATTERN = "require%([\"']([^\"']+)[\"']%)"

local arg = {...}
if #arg ~= 2 then
  print "Usage: bundle input output"
  return 1
end

function getDependencies(paths, dependencies)
  if #paths == 0 then return dependencies end
  local file = io.open(table.remove(paths, 1))
  for name in file:read("*a"):gmatch(REQUIRE_PATTERN) do
    if not dependencies[name] then
      local path = package.searchpath(name, package.path)
      dependencies[name] = path
      table.insert(paths, path)
    end
  end
  file:close()
  return getDependencies(paths, dependencies)
end

function appendFile(file, buffer)
  buffer:write(file:read("*a"):gsub(REQUIRE_PATTERN, "bundle[\"%1\"]") .. "")
end

local input = io.open(arg[1] .. ".lua")
local output = io.open(arg[2] .. ".lua", "w")
output:write([[local bundle = { __defs = {} }
setmetatable(bundle, {
  __index = function(self, key)
    if self.__defs[key] then
      local result = self.__defs[key]()
      self[key] = result
      return result
    end
  end
})
]])
for name, path in pairs(getDependencies({ arg[1] .. ".lua" }, {})) do
  output:write("bundle.__defs[\"" .. name .. "\"] = function()\n")
  appendFile(io.open(path), output)
  output:write("\nend\n")
end
appendFile(input, output)
input:close()
output:close()
