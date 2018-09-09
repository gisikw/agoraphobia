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
  for step in string.gmatch(path, "%d*%a") do
    local n = string.match(step, "%d+") or 1
    local dir = string.sub(step, -1)
    for i = 1,n do 
      perform[dir]()
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

-- move("urflurflurflurflurfl")
-- print("Rotation: "..rotationOffset)
-- print("X: "...positionOffset[1])
-- print("Y: "...positionOffset[2])
-- print("Z: "...positionOffset[3])
