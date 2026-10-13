#==============================================================================
# Map006_LightPuzzle / 诹访宫地下大食堂：随机灯阵验解 / RGSS1
# 放在 Main 上方。只供 MAP6 的事件44使用，不改按钮事件或事件锁定逻辑。
# 0表示灭，1表示亮；目标是25盏全部点亮。
#==============================================================================
module TouhouMap6Lights
  MAP_ID = 6
  WIDTH = 5
  LAMP_COUNT = WIDTH * WIDTH
  FIRST_LAMP_EVENT = 19
  LIGHT_COUNT_VARIABLE = 40
  MAX_RANDOM_ATTEMPTS = 64

  # 翻转自身和上下左右。边界不连接另一侧，和现有25个按钮完全一致。
  def self.flip!(board, index)
    row = index / WIDTH
    column = index % WIDTH
    board[index] ^= 1
    board[index - WIDTH] ^= 1 if row > 0
    board[index + WIDTH] ^= 1 if row < WIDTH - 1
    board[index - 1] ^= 1 if column > 0
    board[index + 1] ^= 1 if column < WIDTH - 1
  end

  # 返回一组可行的按钮下标；无解返回nil。空数组表示本来已经全亮。
  # 只操作副本，不改变传入灯阵，更不改变地图上的任何事件。
  def self.solution_for(lamps)
    return nil unless lamps.is_a?(Array) && lamps.size == LAMP_COUNT
    for value in lamps
      return nil unless value == 0 || value == 1
    end

    # 第一排5个按钮共32种按法。第一排固定后，其余各排的按法唯一。
    for first_row_mask in 0...(1 << WIDTH)
      board = lamps.dup
      presses = []
      for column in 0...WIDTH
        next if (first_row_mask & (1 << column)) == 0
        flip!(board, column)
        presses << column
      end

      # 上一排还有灭灯，就按它正下方的按钮，逐排把灯补成全亮。
      for row in 1...WIDTH
        for column in 0...WIDTH
          next unless board[(row - 1) * WIDTH + column] == 0
          index = row * WIDTH + column
          flip!(board, index)
          presses << index
        end
      end

      # 前四排已由上面的过程保证点亮，只需检查最后一排。
      last_row_lit = true
      for index in (LAMP_COUNT - WIDTH)...LAMP_COUNT
        last_row_lit = false if board[index] == 0
      end
      return presses if last_row_lit
    end
    nil
  end

  def self.solvable?(lamps)
    !solution_for(lamps).nil?
  end

  def self.all_lit?(lamps)
    lamps.all? { |value| value == 1 }
  end

  # 保留原来逐灯独立随机的方式。无解或已经全亮时丢弃，重新抽取。
  def self.generate_layout
    MAX_RANDOM_ATTEMPTS.times do
      lamps = Array.new(LAMP_COUNT) { rand(2) }
      next if all_lit?(lamps)
      return lamps if solvable?(lamps)
    end

    # 有限次数后使用备用生成法，避免持续重抽占用游戏运行。
    # 从全亮状态执行合法翻转，逆向按同一组按钮就能解开，必然有解。
    lamps = Array.new(LAMP_COUNT, 1)
    for index in 0...LAMP_COUNT
      flip!(lamps, index) if rand(2) == 1
    end
    flip!(lamps, LAMP_COUNT / 2) if all_lit?(lamps)
    lamps
  end

  def self.on_target_map?
    $game_map && $game_map.map_id == MAP_ID
  end

  # 事件44：先在内存中选好整盘，再沿用事件里的点灯动画。
  # 暂存到Game_Map内，使中途存档恢复时仍能继续使用同一份布置。
  def self.prepare
    return false unless on_target_map?
    layout = generate_layout
    $game_map.instance_variable_set(:@touhou_map6_lamp_layout, layout)
    $game_variables[LIGHT_COUNT_VARIABLE] = 0
    true
  end

  # 事件44的25个条件分支：下标0对应事件19，下标24对应事件43。
  def self.lit?(index)
    return false unless on_target_map?
    layout = $game_map.instance_variable_get(:@touhou_map6_lamp_layout)
    layout && layout[index] == 1
  end

  # 只等这25盏灯的动画，不被地图上其他怪物的移动路线拖住。
  def self.animations_pending?
    return false unless on_target_map?
    for index in 0...LAMP_COUNT
      event = $game_map.events[FIRST_LAMP_EVENT + index]
      return true if event && event.move_route_forcing
    end
    false
  end

  # 动画完成后按实际朝向统计，防止旧灯态或动画中间态干扰计数。
  # 沿用原事件：朝上(8)为亮、朝下(2)为灭。
  def self.recount_lights
    return 0 unless on_target_map?
    count = 0
    for index in 0...LAMP_COUNT
      event = $game_map.events[FIRST_LAMP_EVENT + index]
      count += 1 if event && event.direction == 8
    end
    $game_variables[LIGHT_COUNT_VARIABLE] = count
    count
  end
end
