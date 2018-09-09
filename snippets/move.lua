function move(path, f)
  local bot = component.proxy(
    component.list("robot")() or component.list("drone")()
  )
  local move_dir = {
    l = bind(bot.turn, false),
    r = bind(bot.turn, true),
    f = bind(bot.move, 3),
    b = bind(bot.move, 2),
    u = bind(bot.move, 1),
    d = bind(bot.move, 0),
    y = f
  }
  for step in string.gmatch(path, "%d*%a") do
    local quantity = string.match(step, "%d+") or 1
    local direction = string.sub(step, -1)
    for i = 1,quantity do 
      move_dir[direction]()
    end
  end
end

function bind(f, arg)
  return function() f(arg) end
end
