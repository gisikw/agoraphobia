local serialization = require("../src/vendor/openos/serialization")

local arg = {...}
local cmd = {}

function cmd.help()
  print("usage: coming soon!")
end

function pullTree(meta, sha, dir, pathPrefix)
  os.execute("mkdir -p " .. dir)
  local https = io.popen("curl -s https://api.github.com/repos/" ..  meta.user ..  "/" ..  meta.repo ..  "/git/trees/" .. sha)
  local result = https:read("*a"):match("\"tree\": %[([^%]]+)%]")
  https:close()
  local entries = {}
  for jsonEntry in result:gmatch("{([^}]+)}") do
    table.insert(entries, {
      path = jsonEntry:match("\"path\": \"([^\"]+)\""),
      type = jsonEntry:match("\"type\": \"([^\"]+)\""),
      sha = jsonEntry:match("\"sha\": \"([^\"]+)\"")
    })
  end
  for _, entry in ipairs(entries) do
    if entry.type == "blob" then
      os.execute("wget https://raw.githubusercontent.com/" ..  meta.user ..  "/" ..  meta.repo ..  "/master/" .. pathPrefix .. entry.path .. " -O " .. dir .. "/" .. entry.path)
    else
      pullTree(meta, entry.sha, dir .. "/" .. entry.path, pathPrefix .. entry.path .. "/")
    end
  end
end

function cmd.pull(arg)
  local dir = arg.dir or "."
  local meta = serialization.unserialize(io.open(dir .. "/.oaf"):read("*a"))
  pullTree(meta, "master", dir, "")
end

function cmd.clone(arg)
  user, repo = arg[2]:match("([^/]+)/(.+)")
  os.execute("mkdir " .. repo)
  local metafile = io.open(repo .. "/.oaf", "w")
  local meta = { user = user, repo = repo }
  metafile:write(serialization.serialize(meta))
  metafile:close()
  cmd.pull({ dir = repo })
end

cmd[arg[1] or "help"](arg)
