# RPG Maker XP / RGSS1. Packed into the empty Scripts.rxdata slot 241.
# The panel, labels, and controls are picture sprites; no text is drawn at runtime.

class Game_System
  def setting_bgm_volume
    @setting_bgm_volume.nil? ? 100 : @setting_bgm_volume
  end

  def setting_bgm_volume=(value)
    @setting_bgm_volume = [[value.to_i, 0].max, 100].min
  end

  def setting_se_volume
    @setting_se_volume.nil? ? 100 : @setting_se_volume
  end

  def setting_se_volume=(value)
    @setting_se_volume = [[value.to_i, 0].max, 100].min
  end

  def setting_battle_active
    @setting_battle_active == 0 ? 0 : 3
  end

  def setting_battle_active=(value)
    @setting_battle_active = value == 0 ? 0 : 3
  end
end

# Apply the saved levels at the final Audio entry points, including direct calls
# made by third-party scripts. Leave each RPG::AudioFile's original volume intact.
class << Audio
  alias setting_original_bgm_play bgm_play
  alias setting_original_se_play se_play

  def bgm_play(name, volume = 100, pitch = 100)
    level = $game_system ? $game_system.setting_bgm_volume : 100
    setting_original_bgm_play(name, volume.to_i * level / 100, pitch)
  end

  def se_play(name, volume = 100, pitch = 100)
    level = $game_system ? $game_system.setting_se_volume : 100
    setting_original_se_play(name, volume.to_i * level / 100, pitch)
  end
end

# RTAB rebuilds @active in atb_setup, once at the start of every battle.
class Scene_Battle
  alias setting_original_atb_setup atb_setup
  def atb_setup
    setting_original_atb_setup
    @active = $game_system.setting_battle_active
  end
end

class Scene_Setting
  ROW_Y = [57, 104, 151, 198, 246]
  PANEL_X = 80
  PANEL_Y = 80

  def main
    @spriteset = Spriteset_Map.new
    @sprites = []
    @row = 0
    begin
      @dim = Sprite.new
      @dim.bitmap = Bitmap.new(640, 480)
      @dim.bitmap.fill_rect(0, 0, 640, 480, Color.new(0, 0, 0, 185))
      @dim.z = 990

      add_picture("Setting_Frame", PANEL_X, PANEL_Y, 1000)
      @focus = add_picture("Setting_Focus", PANEL_X + 23, PANEL_Y + ROW_Y[0], 1001)
      add_picture("Setting_Labels", PANEL_X, PANEL_Y, 1002)
      @bgm = add_picture("Setting_Slider", PANEL_X + 262, PANEL_Y + 57, 1003)
      @se = add_picture("Setting_Slider", PANEL_X + 262, PANEL_Y + 104, 1003)
      @move_skip = add_picture("Setting_Toggle", PANEL_X + 276, PANEL_Y + 153, 1003)
      @voice_skip = add_picture("Setting_Toggle", PANEL_X + 276, PANEL_Y + 200, 1003)
      @mode = add_picture("Setting_Mode", PANEL_X + 264, PANEL_Y + 248, 1003)
      refresh_controls

      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        break if $scene != self
      end
      Graphics.freeze
    ensure
      @sprites.each { |sprite| sprite.dispose unless sprite.disposed? }
      if @dim
        @dim.bitmap.dispose if @dim.bitmap && !@dim.bitmap.disposed?
        @dim.dispose unless @dim.disposed?
      end
      @spriteset.dispose if @spriteset
    end
  end

  def add_picture(name, x, y, z)
    sprite = Sprite.new
    sprite.bitmap = RPG::Cache.picture(name)
    sprite.x = x
    sprite.y = y
    sprite.z = z
    @sprites << sprite
    sprite
  end

  def refresh_controls
    @focus.y = PANEL_Y + ROW_Y[@row]
    @bgm.src_rect.set(0, $game_system.setting_bgm_volume / 10 * 40, 190, 40)
    @se.src_rect.set(0, $game_system.setting_se_volume / 10 * 40, 190, 40)
    @move_skip.src_rect.set(0, $game_switches[23] ? 36 : 0, 154, 36)
    @voice_skip.src_rect.set(0, $game_switches[24] ? 36 : 0, 154, 36)
    @mode.src_rect.set(0, $game_system.setting_battle_active == 0 ? 36 : 0, 174, 36)
  end

  def update
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Menu.new
      return
    end
    if Input.repeat?(Input::UP)
      @row = (@row + 4) % 5
      $game_system.se_play($data_system.cursor_se)
      refresh_controls
      return
    end
    if Input.repeat?(Input::DOWN)
      @row = (@row + 1) % 5
      $game_system.se_play($data_system.cursor_se)
      refresh_controls
      return
    end
    if Input.repeat?(Input::LEFT)
      change_value(-1)
      return
    end
    if Input.repeat?(Input::RIGHT)
      change_value(1)
      return
    end
    change_value(0) if Input.trigger?(Input::C)
  end

  def change_value(direction)
    changed = false
    case @row
    when 0
      return if direction == 0
      old_value = $game_system.setting_bgm_volume
      $game_system.setting_bgm_volume = old_value + direction * 10
      changed = old_value != $game_system.setting_bgm_volume
      if changed
        bgm = $game_system.playing_bgm
        $game_system.bgm_play(bgm) if bgm && bgm.name != ""
      end
    when 1
      return if direction == 0
      old_value = $game_system.setting_se_volume
      $game_system.setting_se_volume = old_value + direction * 10
      changed = old_value != $game_system.setting_se_volume
      $game_system.se_play($data_system.cursor_se) if changed
    when 2, 3
      id = @row == 2 ? 23 : 24
      value = direction == 0 ? !$game_switches[id] : direction > 0
      changed = $game_switches[id] != value
      $game_switches[id] = value
    when 4
      current = $game_system.setting_battle_active
      value = direction == 0 ? (current == 3 ? 0 : 3) : (direction > 0 ? 0 : 3)
      changed = current != value
      $game_system.setting_battle_active = value
    end
    if changed
      $game_system.se_play($data_system.decision_se) if @row >= 2
      refresh_controls
    end
  end
end
