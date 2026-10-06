#==============================================================================
# Original party train: XRXS13 by fukuyama, distance variant by 叶子.
# Original distribution notice: www.66RPG.com (retain when redistributing).
# Compatibility rewrite for this RPG Maker XP project.
#==============================================================================

module Train_Actor
  TRANSPARENT_SWITCH = true
  TRANSPARENT_SWITCHES_INDEX = 9
  TRAIN_ACTOR_SIZE_MAX = 3       # Three followers plus the leader: four actors.
  TRAIN_ACTOR_DISTANCE = 0       # One empty tile between adjacent actors.
  HISTORY_LIMIT = 128
  SHOW_STAGGER = 3

  # Missing run graphics fall back to the actor's normal walking graphic.
  def self.run_character_available?(name)
    @run_character_files = {} if @run_character_files == nil
    unless @run_character_files.has_key?(name)
      found = false
      for extension in [".png", ".bmp", ".jpg", ".jpeg"]
        path = "Graphics/Characters/" + name + extension
        found = FileTest.exist?(path)
        if !found && defined?(EasyConv)
          found = FileTest.exist?(EasyConv.u2s(path).delete("\0"))
        end
        if found
          found = true
          break
        end
      end
      @run_character_files[name] = found
    end
    return @run_character_files[name]
  end

  class Game_Party_Actor < Game_Character
    attr_accessor :move_speed
    attr_accessor :step_anime

    def initialize
      super
      @through = true
    end

    # Rendering follows both the leader's opacity and its event transparency.
    # Keep the follower's own hide state separate for train animation completion.
    def opacity
      return $game_player.opacity if $game_player
      return @opacity
    end

    def transparent
      return @transparent || ($game_player && $game_player.transparent)
    end

    def train_hidden?
      return @transparent
    end

    def setup(actor, running = false, opacity = 255)
      if actor
        name = actor.character_name
        if running && name != ""
          run_name = name =~ /_run$/ ? name : name + "_run"
          name = run_name if Train_Actor.run_character_available?(run_name)
        end
        if @character_name != name
          @pattern = 0
          @anime_count = 0
        end
        @character_name = name
        @character_hue = actor.character_hue
      else
        @character_name = ""
        @character_hue = 0
      end
      @opacity = opacity
      @blend_type = 0
    end

    def train_target(x, y)
      return if @x == x && @y == y
      dx = x - @x
      dy = y - @y
      if dx.abs >= dy.abs
        dx < 0 ? turn_left : turn_right unless dx == 0
      else
        dy < 0 ? turn_up : turn_down
      end
      @x = x
      @y = y
      @stop_count = 0
    end

    def screen_z(height = 0)
      if $game_player.x == @x && $game_player.y == @y
        return $game_player.screen_z(height) - 1
      end
      super(height)
    end
  end
end

class Game_Party
  def train_actor_followers(player = $game_player)
    train_actor_prepare(player)
    return @train_actor_followers
  end

  def train_actor_prepare(player)
    return if player == nil || $game_map == nil
    if @train_actor_followers == nil || @train_actor_cursors == nil ||
       @train_actor_followers.size != Train_Actor::TRAIN_ACTOR_SIZE_MAX ||
       @train_actor_map_id != $game_map.map_id
      train_actor_reset(player)
    end
  end

  def train_actor_reset(player)
    return if player == nil || $game_map == nil
    @train_actor_followers = [] if @train_actor_followers == nil
    while @train_actor_followers.size < Train_Actor::TRAIN_ACTOR_SIZE_MAX
      @train_actor_followers.push(Train_Actor::Game_Party_Actor.new)
    end
    @train_actor_followers = @train_actor_followers[0,
      Train_Actor::TRAIN_ACTOR_SIZE_MAX]
    @train_actor_history = [[player.x, player.y]]
    @train_actor_cursors = []
    @train_actor_map_id = $game_map.map_id
    @train_actor_switch = train_actor_hidden_switch?
    @train_actor_state = @train_actor_switch || $game_switches[171] ?
      :hidden : :visible
    @train_actor_paths = []
    @train_actor_show_delays = []
    train_actor_extend_history(player) unless
      @train_actor_switch || $game_switches[171]
    for i in 0...@train_actor_followers.size
      follower = @train_actor_followers[i]
      follower.setup(@actors[i + 1],
        player.respond_to?(:is_running) && player.is_running, player.opacity)
      point = @train_actor_switch || $game_switches[171] ?
        [player.x, player.y] :
        train_actor_history_point(train_actor_delay(i))
      follower.moveto(point[0], point[1])
      @train_actor_cursors[i] = train_actor_delay(i)
      follower.transparent = @train_actor_switch || $game_switches[171] ||
        @actors[i + 1] == nil
    end
  end

  def train_actor_hidden_switch?
    return false unless Train_Actor::TRANSPARENT_SWITCH
    return false if $game_switches == nil
    return $game_switches[Train_Actor::TRANSPARENT_SWITCHES_INDEX]
  end

  def train_actor_delay(index)
    return (index + 1) * (Train_Actor::TRAIN_ACTOR_DISTANCE + 1)
  end

  def train_actor_history_point(index)
    return @train_actor_history[index] || @train_actor_history[-1]
  end

  # Build a short, passable entry trail when a new map has no walking history.
  def train_actor_extend_history(player)
    needed = train_actor_delay(Train_Actor::TRAIN_ACTOR_SIZE_MAX - 1) + 1
    while @train_actor_history.size < needed
      last = @train_actor_history[-1]
      preferred = 10 - player.direction
      if preferred == 2 || preferred == 8
        directions = [preferred, 4, 6, 10 - preferred]
      else
        directions = [preferred, 8, 2, 10 - preferred]
      end
      chosen = nil
      for direction in directions
        nx = last[0] + (direction == 6 ? 1 : direction == 4 ? -1 : 0)
        ny = last[1] + (direction == 2 ? 1 : direction == 8 ? -1 : 0)
        next unless $game_map.valid?(nx, ny)
        next unless $game_map.passable?(last[0], last[1], direction)
        next unless $game_map.passable?(nx, ny, 10 - direction)
        next if @train_actor_history.include?([nx, ny])
        chosen = [nx, ny]
        break
      end
      @train_actor_history.push(chosen || last)
    end
  end

  def train_actor_record(player)
    point = [player.x, player.y]
    return if @train_actor_history[0] == point
    @train_actor_history.unshift(point)
    @train_actor_history.pop while @train_actor_history.size >
      Train_Actor::HISTORY_LIMIT
    for i in 0...@train_actor_followers.size
      @train_actor_cursors[i] = [@train_actor_cursors[i] + 1,
        @train_actor_history.size - 1].min
    end
    if @train_actor_state == :gathering
      for path in @train_actor_paths
        path.push(point) if path && path[-1] != point
      end
    end
  end

  def train_actor_begin_switch_change(player)
    return if $game_switches[171]
    train_actor_prepare(player)
    return if @train_actor_followers == nil
    hidden = train_actor_hidden_switch?
    return if hidden == @train_actor_switch
    @train_actor_switch = hidden
    if hidden
      train_actor_start_gathering(player)
    else
      train_actor_start_showing(player)
    end
  end

  def train_actor_start_gathering(player)
    @train_actor_state = :gathering
    @train_actor_paths = []
    for i in 0...@train_actor_followers.size
      follower = @train_actor_followers[i]
      path = []
      history_index = @train_actor_cursors[i]
      if history_index == nil ||
         @train_actor_history[history_index] != [follower.x, follower.y]
        history_index = @train_actor_history.index([follower.x, follower.y])
      end
      history_index = train_actor_delay(i) if history_index == nil
      j = history_index - 1
      while j >= 0
        point = @train_actor_history[j]
        path.push(point) if point && path[-1] != point
        j -= 1
      end
      path.push([player.x, player.y]) if path[-1] != [player.x, player.y]
      @train_actor_paths[i] = path
      follower.transparent = @actors[i + 1] == nil
    end
  end

  def train_actor_start_showing(player)
    @train_actor_state = :showing
    train_actor_extend_history(player)
    @train_actor_paths = []
    @train_actor_show_delays = []
    for i in 0...@train_actor_followers.size
      follower = @train_actor_followers[i]
      follower.moveto(player.x, player.y)
      follower.transparent = true
      path = []
      for j in 1..train_actor_delay(i)
        point = train_actor_history_point(j)
        path.push(point) if path[-1] != point
      end
      @train_actor_paths[i] = path
      @train_actor_show_delays[i] = i * Train_Actor::SHOW_STAGGER
      @train_actor_cursors[i] = train_actor_delay(i)
    end
  end

  def train_actor_transitioning?
    return @train_actor_state == :gathering || @train_actor_state == :showing
  end

  def train_actor_update_followers(player)
    if $game_switches[171]
      train_actor_prepare(player)
      @train_actor_suspended_171 = true
      @train_actor_state = :hidden
      for follower in @train_actor_followers
        follower.transparent = true
      end
      return
    end
    if @train_actor_suspended_171
      @train_actor_suspended_171 = false
      train_actor_reset(player)
    end
    train_actor_prepare(player)
    return if @train_actor_followers == nil
    train_actor_record(player)
    train_actor_begin_switch_change(player)
    all_done = true
    for i in 0...@train_actor_followers.size
      follower = @train_actor_followers[i]
      actor = @actors[i + 1]
      follower.setup(actor,
        player.respond_to?(:is_running) && player.is_running, player.opacity)
      follower.step_anime = player.step_anime
      follower.move_speed = player.move_speed
      if actor == nil
        follower.transparent = true
      elsif @train_actor_state == :hidden
        follower.transparent = true
      elsif @train_actor_state == :gathering
        follower.move_speed = [player.move_speed + 1, 4].max
        if !follower.moving?
          path = @train_actor_paths[i]
          path.shift while path.size > 0 && path[0] == [follower.x, follower.y]
          if path.size > 0
            point = path.shift
            follower.train_target(point[0], point[1])
          else
            follower.transparent = true
          end
        end
        all_done = false unless follower.train_hidden?
      elsif @train_actor_state == :showing
        follower.move_speed = [player.move_speed, 4].max
        if @train_actor_show_delays[i] > 0
          @train_actor_show_delays[i] -= 1
          all_done = false
        else
          follower.transparent = false
          if !follower.moving?
            path = @train_actor_paths[i]
            path.shift while path.size > 0 && path[0] == [follower.x, follower.y]
            if path.size > 0
              point = path.shift
              follower.train_target(point[0], point[1])
            end
          end
          all_done = false if follower.moving? || @train_actor_paths[i].size > 0
        end
      else
        follower.transparent = false
        if !follower.moving?
          desired_index = train_actor_delay(i)
          desired_point = train_actor_history_point(desired_index)
          cursor = @train_actor_cursors[i] || desired_index
          if [follower.x, follower.y] == desired_point
            cursor = desired_index
          elsif cursor > desired_index
            cursor -= 1
          elsif cursor < desired_index
            cursor += 1
          else
            cursor = desired_index
          end
          @train_actor_cursors[i] = cursor
          point = train_actor_history_point(cursor)
          follower.train_target(point[0], point[1])
        end
      end
      follower.update
    end
    if all_done && @train_actor_state == :gathering
      @train_actor_state = :hidden
    elsif all_done && @train_actor_state == :showing
      @train_actor_state = :visible
    end
  end
end

class Game_Player
  attr_reader :move_speed
  attr_reader :step_anime

  alias train_actor_player_update update
  def update
    train_actor_player_update
    $game_party.train_actor_update_followers(self) if $game_party
  end

  alias train_actor_player_moveto moveto
  def moveto(x, y)
    train_actor_player_moveto(x, y)
    $game_party.train_actor_reset(self) if $game_party && $game_map
  end
end

class Spriteset_Map
  alias train_actor_spriteset_initialize initialize
  def initialize
    train_actor_spriteset_initialize
    if $game_party && $game_player
      for follower in $game_party.train_actor_followers($game_player)
        @character_sprites.push(Sprite_Character.new(@viewport1, follower))
      end
    end
  end
end

class Interpreter
  alias train_actor_interpreter_update update
  def update
    if @train_actor_waiting && $game_party &&
       $game_party.train_actor_transitioning?
      return
    end
    @train_actor_waiting = false
    train_actor_interpreter_update
  end

  alias train_actor_command_121 command_121
  def command_121
    old_value = $game_switches[Train_Actor::TRANSPARENT_SWITCHES_INDEX]
    result = train_actor_command_121
    train_actor_wait_for_switch_change(old_value)
    return result
  end

  alias train_actor_command_355 command_355
  def command_355
    old_value = $game_switches[Train_Actor::TRANSPARENT_SWITCHES_INDEX]
    result = train_actor_command_355
    train_actor_wait_for_switch_change(old_value)
    return result
  end

  def train_actor_wait_for_switch_change(old_value)
    return if old_value ==
      $game_switches[Train_Actor::TRANSPARENT_SWITCHES_INDEX]
    return unless $scene.is_a?(Scene_Map)
    return if $game_party == nil || $game_player == nil
    $game_party.train_actor_begin_switch_change($game_player)
    if $game_party.train_actor_transitioning?
      @train_actor_waiting = true
      @wait_count = 1
    end
  end
end
