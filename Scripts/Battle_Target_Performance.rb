# RGSS1: enemy selection help cache. Insert after other Window_Help scripts.
# Window-local, bounded caches; no save data or battle timing changes.
class Window_Help
  TARGET_IMAGE_CACHE_LIMIT = 16
  TARGET_GRADIENT_CACHE_LIMIT = 32

  alias target_perf_original_set_enemy set_enemy
  alias target_perf_original_set_actor set_actor
  alias target_perf_original_set_text set_text
  alias target_perf_original_update update
  alias target_perf_original_dispose dispose
  alias target_perf_original_draw_line draw_line

  def target_perf_signature(enemy)
    state_info = enemy.states.map do |id|
      state = $data_states[id]
      [id, enemy.states_turn[id], state.name.dup, state.hold_turn,
       ICON_STATE_IDS.include?(id)]
    end
    font = self.contents.font
    [enemy, enemy.name.dup, enemy.hp, enemy.sp, enemy.maxhp, enemy.maxsp,
     state_info, $data_system.words.hp.dup, $data_system.words.sp.dup,
     font.name.dup, font.size, font.bold, font.italic,
     self.contents.width, self.contents.height]
  end

  def set_enemy(enemy)
    unless enemy
      @target_perf_enemy = nil
      @target_perf_signature = nil
      return
    end
    @target_perf_enemy = enemy
    signature = target_perf_signature(enemy)
    if @target_perf_signature == signature &&
        @target_perf_contents.equal?(self.contents)
      self.visible = true
      return
    end
    @target_perf_images ||= []
    cached = @target_perf_images.find { |entry| entry[0] == signature }
    if cached && !cached[1].disposed?
      # clone preserves exact RGSS pixel alpha and font properties.
      previous = self.contents
      self.contents = cached[1].clone
      previous.dispose unless previous.disposed?
      @target_perf_images.delete(cached)
      @target_perf_images.push(cached)
    else
      target_perf_original_set_enemy(enemy)
      @target_perf_images.push([signature, self.contents.clone])
      if @target_perf_images.size > TARGET_IMAGE_CACHE_LIMIT
        @target_perf_images.shift[1].dispose
      end
    end
    @target_perf_signature = signature
    @target_perf_contents = self.contents
    @actor = nil
    @text = nil
    self.visible = true
  end

  def target_perf_leave_enemy
    @actor = nil if @target_perf_enemy
    @target_perf_enemy = nil
    @target_perf_signature = nil
    @target_perf_contents = nil
  end

  def set_text(text, align = 0)
    target_perf_leave_enemy
    target_perf_original_set_text(text, align)
  end

  def set_actor(actor)
    target_perf_leave_enemy
    target_perf_original_set_actor(actor)
  end

  def update
    target_perf_original_update
    # RTAB can change HP and state turns even while the cursor is stationary.
    set_enemy(@target_perf_enemy) if self.visible && @target_perf_enemy
  end

  def dispose
    if @target_perf_images
      @target_perf_images.each do |entry|
        entry[1].dispose unless entry[1].disposed?
      end
      @target_perf_images.clear
    end
    @target_perf_gradients = nil
    target_perf_leave_enemy
    target_perf_original_dispose
  end

  def draw_line(sx, sy, ex, ey, first, width = 1, last = first)
    # Preserve arbitrary line behavior used by other scripts.
    unless sy == ey && ex >= sx && sx == sx.to_i && ex == ex.to_i
      return target_perf_original_draw_line(sx, sy, ex, ey, first, width, last)
    end
    distance = ex - sx
    return if distance == 0
    # Cache the exact colors, not an alpha-composited bitmap: blitting the
    # translucent gradient over its shadow would change the original colors.
    key = [distance, first.red, first.green, first.blue, first.alpha,
           last.red, last.green, last.blue, last.alpha]
    @target_perf_gradients ||= []
    cached = @target_perf_gradients.find { |entry| entry[0] == key }
    unless cached
      colors = []
      for i in 1..distance
        colors << Color.new(
          first.red * (distance-i)/distance + last.red * i/distance,
          first.green * (distance-i)/distance + last.green * i/distance,
          first.blue * (distance-i)/distance + last.blue * i/distance,
          first.alpha * (distance-i)/distance + last.alpha * i/distance)
      end
      cached = [key, colors]
      @target_perf_gradients.push(cached)
      @target_perf_gradients.shift if @target_perf_gradients.size > TARGET_GRADIENT_CACHE_LIMIT
    end
    colors = cached[1]
    for i in 1..distance
      if width == 1
        self.contents.set_pixel(sx + i, sy, colors[i-1])
      else
        self.contents.fill_rect(sx + i, sy, width, width, colors[i-1])
      end
    end
  end
end
