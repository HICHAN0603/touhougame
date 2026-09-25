# RGSS1 / Ruby 1.8. Insert after other scripts, immediately before Main.
# All bitmaps owned by this scene; no shared RPG::Cache bitmaps are disposed.
module LostRecordTitle
  ROOT = 'Graphics/Titles/LostRecord/'
  POSITIONS = [[150,359], [263,350], [376,350], [489,359]]
  def self.save_available?
    if defined?(BBS_66RPG_DIR)
      return (0..9).any? { |i| FileTest.exist?(BBS_66RPG_DIR + "Save#{i}.rxdata") }
    end
    (1..4).any? { |i| FileTest.exist?("Save#{i}.rxdata") }
  end
end

class Scene_Title
  def main
    if $BTEST
      battle_test
      return
    end
    @lr_sprites = []
    @lr_bitmaps = {}
    begin
      lr_load_database
      # Preserve the existing optional backup extension and map-name extension.
      if defined?(Window_Backup) && respond_to?(:backup_data)
        @backup_window = Window_Backup.new
        @backup_window.visible = RB::Data_Backup::Activated && $DEBUG
        backup_data if @backup_window.visible
        @backup_window.dispose
        @backup_window = nil
      end
      @continue_enabled = LostRecordTitle.save_available?
      @lr_index = @continue_enabled ? 1 : 0
      @lr_tick = 0
      lr_build
      $game_system.bgm_play($data_system.title_bgm)
      Audio.me_stop
      Audio.bgs_stop
      Graphics.transition(24)
      loop do
        Graphics.update
        Input.update
        update
        break if $scene != self
      end
      Graphics.freeze
    ensure
      @lr_sprites.each { |s| s.dispose unless s.disposed? } if @lr_sprites
      @lr_bitmaps.each_value { |b| b.dispose unless b.disposed? } if @lr_bitmaps
      if @backup_window && !@backup_window.disposed?
        @backup_window.dispose
      end
    end
  end

  def lr_load_database
    $data_actors = load_data('Data/Actors.rxdata')
    $data_classes = load_data('Data/Classes.rxdata')
    $data_skills = load_data('Data/Skills.rxdata')
    $data_items = load_data('Data/Items.rxdata')
    $data_weapons = load_data('Data/Weapons.rxdata')
    $data_armors = load_data('Data/Armors.rxdata')
    $data_enemies = load_data('Data/Enemies.rxdata')
    $data_troops = load_data('Data/Troops.rxdata')
    $data_states = load_data('Data/States.rxdata')
    $data_animations = load_data('Data/Animations.rxdata')
    $data_tilesets = load_data('Data/Tilesets.rxdata')
    $data_common_events = load_data('Data/CommonEvents.rxdata')
    $data_system = load_data('Data/System.rxdata')
    $data_mapinfos = load_data('Data/MapInfos.rxdata')
    $game_system = Game_System.new
  end

  def lr_bitmap(name)
    @lr_bitmaps[name] ||= Bitmap.new(LostRecordTitle::ROOT + name + '.png')
  end

  def lr_sprite(name, x, y, z, centered = false)
    s = Sprite.new
    @lr_sprites << s
    s.bitmap = lr_bitmap(name)
    s.x, s.y, s.z = x, y, z
    if centered
      s.ox = s.bitmap.width / 2
      s.oy = s.bitmap.height / 2
    end
    s
  end

  def lr_build
    lr_sprite('background', 0, 0, 0)
    @lr_particles = []
    18.times do |i|
      s = lr_sprite('spark', 190 + rand(420), rand(430), 1, true)
      s.zoom_x = s.zoom_y = 0.15 + rand(30) / 100.0
      @lr_particles << s
    end
    @lr_logo = lr_sprite('logo', 178, 77, 3)
    @lr_ornament = lr_sprite('ornament', 0, 0, 2)
    @lr_buttons, @lr_glyphs, @lr_labels = [], [], []
    LostRecordTitle::POSITIONS.each_with_index do |p, i|
      @lr_buttons << lr_sprite('button-normal', p[0], p[1], 4, true)
      @lr_glyphs << lr_sprite("glyph-#{i}", p[0], p[1], 5, true)
      @lr_labels << lr_sprite("label-#{i}", p[0], p[1] + 59, 5, true)
    end
    @lr_pointer = lr_sprite('spark', 0, 0, 6, true)
    lr_animate
  end

  def update
    @lr_tick += 1
    if Input.repeat?(Input::RIGHT) || Input.repeat?(Input::DOWN)
      @lr_index = (@lr_index + 1) % 4
      $game_system.se_play($data_system.cursor_se)
    elsif Input.repeat?(Input::LEFT) || Input.repeat?(Input::UP)
      @lr_index = (@lr_index + 3) % 4
      $game_system.se_play($data_system.cursor_se)
    end
    lr_animate
    return unless Input.trigger?(Input::C)
    case @lr_index
    when 0
      command_new_game
    when 1
      @continue_enabled = LostRecordTitle.save_available?
      command_continue
    when 2
      $game_system.se_play($data_system.buzzer_se)
    when 3
      command_shutdown
    end
  end

  def lr_animate
    @lr_logo.opacity = [@lr_tick * 8, 255].min
    @lr_logo.y = 77 + [10 - @lr_tick / 3, 0].max
    fade = [[(@lr_tick - 8) * 12, 0].max, 255].min
    @lr_ornament.opacity = fade
    @lr_buttons.each_with_index do |s, i|
      selected = i == @lr_index
      disabled = i == 2 || (i == 1 && !@continue_enabled)
      name = selected ? 'button-active' : (disabled ? 'button-disabled' : 'button-normal')
      s.bitmap = lr_bitmap(name)
      y = LostRecordTitle::POSITIONS[i][1] - (selected ? 3 : 0)
      s.y = @lr_glyphs[i].y = y
      s.opacity = fade
      @lr_glyphs[i].opacity = disabled ? fade * 0.45 : fade
      @lr_labels[i].opacity = disabled ? fade * 0.55 : fade
      s.tone = Tone.new(0, 0, 0, 0)
      if selected
        pulse = (Math.sin(@lr_tick / 14.0) + 1) * 12
        s.tone = Tone.new(pulse, pulse, pulse, 0)
      end
    end
    p = LostRecordTitle::POSITIONS[@lr_index]
    @lr_pointer.x = p[0]
    @lr_pointer.y = p[1] - 58 + Math.sin(@lr_tick / 10.0) * 3
    @lr_pointer.opacity = fade
    @lr_particles.each_with_index do |s, i|
      s.y -= 0.12 + (i % 4) * 0.04
      s.y = 430 if s.y < 20
      s.opacity = 35 + (Math.sin(@lr_tick / 30.0 + i) + 1) * 45
    end
  end
end
