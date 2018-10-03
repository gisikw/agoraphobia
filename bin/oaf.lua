local serialization = require("../src/vendor/openos/serialization")
local github = require("../src/lib/github")

local arg = {...}
local cmd = {}

local function pullTree(meta, sha, dir, pathPrefix)
  os.execute("mkdir -p " .. dir)
  local entries = github.entriesInTree(meta.shortname, sha)
  for _, entry in ipairs(entries) do
    if entry.type == "blob" then
      github.getBlob(meta.shortname, pathPrefix .. entry.path, dir .. "/" .. entry.path)
    else
      pullTree(meta, entry.sha, dir .. "/" .. entry.path, pathPrefix .. entry.path .. "/")
    end
  end
end

local function getMeta(dir)
  local dir = dir or "."
  return serialization.unserialize(io.open(dir .. "/.oaf"):read("*a"))
end

local function setMeta(meta, dir)
  local dir = dir or "."
  local metafile = io.open(dir .. "/.oaf", "w")
  metafile:write(serialization.serialize(meta))
  metafile:close()
end

function cmd.help()
  print("usage: coming soon!")
end

function cmd.commit(arg)
  local meta = getMeta(dir) 
  if not next(meta.staged) then
    print "No staged changes to commit"
    return 1
  end
  local changes = {}
  for path, _ in pairs(meta.staged) do
    table.insert(changes, {
      path = path,
      content = io.open(path):read("*a")
    })
  end
  github.push(meta.shortname, changes)
end

function cmd.status()
  local dir = arg.dir or "./agoraphobia" -- FIXME
  local meta = getMeta(dir)
  if next(meta.staged) then
    print("Files staged for commit:")
    for file, _ in pairs(meta.staged) do
      print("- " .. file)
    end
  else
    print("No files staged for commit")
  end
end

-- TODO Features: 
-- - Check if file exists
-- - If a directory, add everything in that dir
function cmd.add(arg)
  local dir = arg.dir or "./agoraphobia" -- FIXME
  local meta = getMeta(dir)
  meta.staged[arg[2]] = true
  setMeta(meta, dir)
  print(arg[2] .. " staged for commit")
end

-- TODO Features: 
-- - Check if file exists
-- - If a directory, add everything in that dir
function cmd.reset(arg)
  local dir = arg.dir or "./agoraphobia" -- FIXME
  local meta = getMeta(dir)
  if arg[2] then
    meta.staged[arg[2]] = nil
    print(arg[2] .. " unstaged")
  else
    meta.staged = {}
    print("All files unstaged")
  end
  setMeta(meta, dir)
end

function cmd.pull(arg)
  local dir = arg.dir or "."
  local meta = getMeta(dir)
  pullTree(meta, "master", dir, "")
end

function cmd.clone(arg)
  user, repo = arg[2]:match("([^/]+)/(.+)")
  os.execute("mkdir " .. repo)
  local meta = 
  setMeta({ 
    user = user, 
    repo = repo, 
    shortname = arg[2], 
    staged = {} 
  }, repo)
  cmd.pull({ dir = repo })
end

cmd[arg[1] or "help"](arg)
