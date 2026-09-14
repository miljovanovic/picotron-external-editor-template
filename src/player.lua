function init_player()
  x = 232
  y = 127
end

function update_player()
  if btn(0) then
    x -= 2
  end

  if btn(1) then
    x += 2
  end

  if btn(2) then
    y -= 2
  end

  if btn(3) then
    y += 2
  end
end
