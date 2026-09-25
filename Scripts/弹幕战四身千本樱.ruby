ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
$game_variables[279] = ($game_variables[279] || 0) + 1

# 每 8 帧发一圈，圈数递增
if $game_variables[279] % 8 == 0
  wave = $game_variables[279] / 8
  for i in 0...12
    angle = i * 30 + wave * 5
    speed = 2.0 + wave * 0.3
    new_bullet([RPG::Cache.picture("bullet2"), Rect.new(32, 96, 32, 32),
                ex, ey, 200, 1.0, 1.0, angle, speed, 0, 1])
  end
end