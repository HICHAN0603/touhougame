require 'zlib'

def assert(condition, message)
  raise message unless condition
end

class Color
  attr_accessor :red, :green, :blue, :alpha
  def initialize(r, g, b, a = 255)
    @red, @green, @blue, @alpha = r, g, b, a
  end
end
class Tone < Color; end

class Bitmap
  attr_reader :width, :height
  def initialize(path_or_width, height = nil)
    @disposed = false
    if height
      @width, @height = path_or_width, height
      @data = "\0" * (@width * @height * 4)
    else
      header = File.binread(path_or_width, 24)
      assert(header[0, 8] == "\x89PNG\r\n\x1a\n".b, 'Invalid PNG asset')
      @width, @height = header[16, 8].unpack('N2')
      if File.basename(path_or_width) == 'background.png'
        @data = File.binread('tmp/title-glow-check/background.rgba')
      end
    end
  end
  def get_pixel(x, y)
    raise 'Reading disposed bitmap' if @disposed
    return Color.new(0, 0, 0, 0) unless @data && x >= 0 && y >= 0 && x < @width && y < @height
    Color.new(*@data[(y * @width + x) * 4, 4].unpack('C4'))
  end
  def set_pixel(x, y, color)
    @data[(y * @width + x) * 4, 4] = [color.red, color.green, color.blue, color.alpha].map { |v| v.to_i }.pack('C4')
  end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
end

class Sprite
  attr_accessor :bitmap, :x, :y, :z, :ox, :oy, :zoom_x, :zoom_y, :blend_type, :tone
  attr_reader :opacity
  def initialize
    @x = @y = @z = @ox = @oy = 0
    @zoom_x = @zoom_y = 1.0
    @opacity = 255
    @disposed = false
  end
  def opacity=(value)
    assert(value >= 0 && value <= 255, 'Invalid sprite opacity')
    @opacity = value.to_i
  end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
end

module Graphics
  class << self
    attr_accessor :frame_rate, :frame_count
    def update; @frame_count += 1; end
    def transition(*args); end
    def freeze; end
  end
end
module Input
  RIGHT = :right; LEFT = :left; UP = :up; DOWN = :down; C = :confirm
  class << self
    attr_accessor :events
    def update; end
    def repeat?(key); (@events[Graphics.frame_count] || []).include?(key); end
    def trigger?(key); repeat?(key); end
  end
end
module Audio
  def self.me_stop; end
  def self.bgs_stop; end
end

load 'Graphics/Titles/LostRecord/Scene_Title_LostRecord.rb'
module LostRecordTitle
  def self.save_available?; $test_continue; end
end
class Scene_Title
  def lr_load_database
    $data_system = Struct.new(:title_bgm, :cursor_se, :buzzer_se).new(:music, :cursor, :buzzer)
    $game_system = Object.new
    def $game_system.bgm_play(value); end
    def $game_system.se_play(value); $test_sounds << value; end
  end
  def command_new_game; $test_commands << :new_game; $scene = nil; end
  def command_continue; $test_commands << :continue; $scene = nil; end
  def command_shutdown; $test_commands << :shutdown; $scene = nil; end
end

def prepare_scene(fps)
  Graphics.frame_rate = fps
  Graphics.frame_count = 0
  Input.events = {}
  $test_continue = true
  $test_sounds, $test_commands = [], []
  scene = Scene_Title.new
  scene.lr_load_database
  { :@lr_sprites => [], :@lr_bitmaps => {}, :@lr_tick => 0,
    :@lr_glow_elapsed => 0.0, :@lr_index => 1, :@continue_enabled => true }.each do |name, value|
    scene.instance_variable_set(name, value)
  end
  scene.lr_build
  scene
end

def release(scene)
  scene.instance_variable_get(:@lr_sprites).each { |s| s.dispose }
  scene.instance_variable_get(:@lr_bitmaps).each_value { |b| b.dispose }
end

[40, 60].each do |fps|
  scene = prepare_scene(fps)
  core = scene.instance_variable_get(:@lr_glow_core)
  halo = scene.instance_variable_get(:@lr_glow_halo)
  mask = scene.instance_variable_get(:@lr_glow_mask)
  assert(mask.get_pixel(320, 240).alpha == 255, 'White opening is missing the local shade')
  assert(mask.get_pixel(80, 240).alpha == 0, 'Dark left background was shaded')
  assert((core.bitmap.width * core.zoom_x - 640).abs < 0.001, 'Wrong overlay width')
  assert((core.bitmap.height * core.zoom_y - 480).abs < 0.001, 'Wrong overlay height')
  assert((core.x - core.ox * core.zoom_x).abs < 0.5, 'Overlay horizontal registration shifted')
  assert((core.y - core.oy * core.zoom_y).abs < 0.5, 'Overlay vertical registration shifted')
  assert(halo.z < scene.instance_variable_get(:@lr_logo).z, 'Halo covers the logo')
  assert(halo.z < scene.instance_variable_get(:@lr_buttons)[0].z, 'Halo covers the menu')
  samples = []
  (fps * 8).times do
    Graphics.update
    scene.update
    samples << [core.opacity, halo.opacity, halo.zoom_x]
  end
  core_peak = samples.index { |s| s[0] == LostRecordTitle::GLOW_CORE_MIN + LostRecordTitle::GLOW_CORE_GAIN }
  halo_peak = samples.index { |s| s[1] == LostRecordTitle::GLOW_HALO_MIN + LostRecordTitle::GLOW_HALO_GAIN }
  assert(core_peak && halo_peak, 'Breathing never reaches its configured peak')
  delay = (halo_peak - core_peak).to_f / fps
  assert((delay - LostRecordTitle::GLOW_HALO_DELAY).abs < 0.04, 'Halo does not follow the core')
  (fps * 4...fps * 8).each do |i|
    previous = samples[i - fps * 4]
    next if i - fps * 4 < fps
    assert((samples[i][0] - previous[0]).abs <= 1, 'Core cycle changes with frame rate')
    assert((samples[i][1] - previous[1]).abs <= 1, 'Halo cycle changes with frame rate')
  end
  assert(samples.map { |s| s[2] }.max > samples.map { |s| s[2] }.min, 'Halo never expands')
  assert(scene.instance_variable_get(:@lr_index) == 1, 'Animation changed menu selection')
  release(scene)
  puts "PASS #{fps} fps: 4-second cycle, delayed halo, registration, layering and opacity"
end

[
  [false, { 2 => [Input::C] }, :new_game, false],
  [true, { 2 => [Input::C] }, :continue, false],
  [true, { 2 => [Input::RIGHT], 3 => [Input::C], 4 => [Input::RIGHT], 5 => [Input::C] }, :shutdown, true]
].each do |available, events, command, expect_buzzer|
  Graphics.frame_rate = 40
  Graphics.frame_count = 0
  Input.events = events
  $test_continue = available
  $test_sounds, $test_commands = [], []
  $BTEST = false
  scene = Scene_Title.new
  $scene = scene
  scene.main
  assert($test_commands == [command], 'Title input dispatch changed')
  assert($test_sounds.include?(:buzzer) == expect_buzzer, 'Disabled menu feedback changed')
  assert(scene.instance_variable_get(:@lr_sprites).all? { |s| s.disposed? }, 'Title sprite leak on exit')
  assert(scene.instance_variable_get(:@lr_bitmaps).values.all? { |b| b.disposed? }, 'Title bitmap leak on exit')
  puts "PASS #{command}: input dispatch, disabled option feedback and resource disposal"
end

LostRecordTitle.send(:remove_const, :GLOW_ENABLED)
LostRecordTitle.const_set(:GLOW_ENABLED, false)
scene = prepare_scene(40)
assert(scene.instance_variable_get(:@lr_glow_core).nil?, 'Glow disable switch failed')
assert(scene.instance_variable_get(:@lr_sprites).length == 34, 'Disabled glow adds resources')
Graphics.update
scene.update
release(scene)
puts 'PASS disabled glow: original title still builds and updates'
