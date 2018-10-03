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

function github.push(shortname, changes)
  local function curl(path)
    return io.popen("curl -s https://api.github.com/repos/" .. shortname .. "/git/" .. path):read("*a")
  end

  local tokenFile = io.open("/home/gisikw/.github")
  local token = tokenFile:read("*a"):gsub("\n", "")
  tokenFile:close()

  local commit = curl("refs/heads/master"):match("\"sha\": \"([^\"]+)")

  local tree = curl("commits/" .. commit):match("\"tree\": {%s+\"sha\": \"([^\"]+)")
  --local treeString = '{"base_tree":"' .. tree .. '","tree":['
  local treeString = '{"tree":[' -- Remove all except what we've just added
  treeString = treeString .. '{"path":"storage.lua","mode":"100644","type":"blob","sha":"44d7d025f70224e6efc37ed77c087a6f5a3f8335"},'
  -- TODO Add stuff for each entry
  treeString = treeString .. '{"path":"test_file.txt","mode":"100644","type":"blob","content":"File contents @ ' .. io.popen("date"):read("*a"):gsub("\n","") .. '"}'
  -- /end TODO
  treeString = treeString .. "]}"

  local newTreeSha = io.popen("curl -s -d '" .. treeString .. "' https://api.github.com/repos/" .. shortname .. "/git/trees?access_token=" .. token):read("*a"):match("^{%s*\"sha\": \"([^\"]+)")

  local message = "A test commit message" -- TODO
  local commitString = '{"message":"' .. message .. '","tree":"' .. newTreeSha .. '","parents":["' .. commit .. '"]}'
  local newCommitSha = io.popen("curl -s -d '" .. commitString .. "' https://api.github.com/repos/" .. shortname .. "/git/commits?access_token=" .. token):read("*a"):match("^{%s*\"sha\": \"([^\"]+)")

  os.execute("curl -i -d '{\"sha\":\"" .. newCommitSha .. "\"}' https://api.github.com/repos/" .. shortname .. "/git/refs/heads/master?access_token=" .. token)
end

github.push("gisikw/agoraphobia", {})

return github
