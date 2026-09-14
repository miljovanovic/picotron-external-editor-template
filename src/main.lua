include("src/player.lua")
include("src/render.lua")

function game_init()
  init_player()
end

function game_update()
  update_player()
end

function game_draw()
  draw_game()
end
