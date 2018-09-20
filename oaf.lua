-- Shallow Clone Repository
-- oaf clone gisikw/agoraphobia

-- Pull Latest Files from Master
-- oaf pull

-- Push Latest Files to Master
-- oaf commit -m "Some message"

local fs = require("filesystem")
local shell = require("shell")

local github {
  repo = function()
    "repo identifier"
  end
}

local args = shell.parse(...)
if #args == 0 then
  io.write("Usage: oaf <command>\n")
  return 1
end

local ec = 0
local commands = {
  clone = function(args)
    local repo, reason = github.repo(args[2])
    if not repo then
      if not reason then
        reason = "unknown reason"
      end
      io.stderr:write("oaf: cannot find remote repository '" .. args[2] .. "': " .. reason .. "\n")
      ec = 1
      return
    end

    local dir = string.gsub(args[2], "^.*/", "")
    local path = shell.resolve(dir)
    local result, reason = fs.makeDirectory(path)
    if not result then
      if not reason then
        if fs.exists(path) then
          reason = "file or folder with that name already exists"
        else
          reason = "unknown reason"
        end
      end
      io.stderr:write("oaf: cannot create directory '" .. dir .. "': " .. reason .. "\n")
      ec = 1
    end

    local f = fs.open(path .. "/.oaf") 
    fs.write(f, repo)
    fs.close(f)

    local cwd = shell.getWorkingDirectory()
    shell.setWorkingDirectory(path)
    commands.pull()
    shell.setWorkingDirectory(cwd)
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
