local github = {}

local function parseJSONValue(json, key)
  return json:match("\"" .. key .. "\": \"([^\"]+)\"")
end

function github.entriesInTree(shortname, sha)
  local https = io.popen("curl -s https://api.github.com/repos/" .. shortname ..  "/git/trees/" .. sha)
  local result = https:read("*a"):match("\"tree\": %[([^%]]+)%]")
  https:close()
  local entries = {}
  for jsonEntry in result:gmatch("{([^}]+)}") do
    table.insert(entries, {
      path = parseJSONValue(jsonEntry, "path"),
      type = parseJSONValue(jsonEntry, "type"),
      sha = parseJSONValue(jsonEntry, "sha")
    })
  end
  return entries
end

function github.getBlob(shortname, repoPath, filePath)
  os.execute( "wget https://raw.githubusercontent.com/" .. shortname .. "/master/" .. repoPath .. " -O " .. filePath)
end

return github
