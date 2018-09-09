positionOffset = { 0, 0, 0 }
rotationOffset = 0
function move(path, f)
  local bot = component.proxy(
    component.list("robot")() or component.list("drone")()
  )
  local perform = {}
  function perform.l() 
    if bot.turn(false) then
      rotationOffset = (rotationOffset - 1) % 4
    end
  end
  function perform.r() 
    if bot.turn(true) then
      rotationOffset = (rotationOffset + 1) % 4
    end
  end
  function perform.f()
    if bot.move(3) then
      offsetCurrentDirection(1)
    end
  end
  function perform.b()
    if bot.move(2) then
      offsetCurrentDirection(-1)
    end
  end
  function perform.u()
    if bot.move(1) then
      positionOffset[2] = positionOffset[2] + 1
    end
  end
  function perform.d()
    if bot.move(0) then
      positionOffset[2] = positionOffset[2] - 1
    end
  end
  perform.y = f

  local parseString = ""

  function chomp(pattern)
    match = string.match(parseString, "^"..pattern) 
    parseString = string.gsub(parseString, "^"..pattern, "")
    return match
  end

  function parse(str)
    parseString = str
    return parseExpression()
  end

  function parseExpression()
    local left = parsePair()
    if string.len(parseString) == 0 or string.sub(parseString, 0, 1) == ")" then
      return left
    else
      return { type = "Expression", left = left, right = parseExpression() }
    end
  end

  function parsePair()
    local n = chomp("%d+")
    local term = parseTerm()
    if n then
      return { type = "Pair", num = tonumber(n), term = term }
    else
      return term 
    end
  end

  function parseTerm()
    if chomp("%(") then
      local expr = parseExpression()
      chomp("%)")
      return expr
    else
      return { type = "Directive", value = chomp(".") } 
    end
  end

  function visit(node)
    if node.type == "Directive" then
      perform[node.value]()
    elseif node.type == "Pair" then
      for i=1,node.num do
        visit(node.term)
      end
    else
      visit(node.left)
      visit(node.right)
    end
  end
end

function offsetCurrentDirection(i)
  if rotationOffset == 0 then
    positionOffset[1] = positionOffset[1] + i
  elseif rotationOffset == 1 then
    positionOffset[3] = positionOffset[3] + i
  elseif rotationOffset == 2 then
    positionOffset[1] = positionOffset[1] - i
  else
    positionOffset[3] = positionOffset[3] - i
  end
end
