# RPG Maker XP / RGSS1. This source is packed into Data/Scripts.rxdata slot 246.
# The ornamental art and fixed UI labels are PNG sprites in Graphics/Pictures.
module SaveLoadOrnate
  SLOT_COUNT = 20
  SLOT_WIDTH = 212
  SLOT_HEIGHT = 352

  def self.filename(index)
    BBS_66RPG_DIR + "Save#{index}.rxdata"
  end

  def self.picture(name)
    RPG::Cache.picture("SaveLoad_" + name)
  end
end

class Window_SaveSlots < Window_Selectable
  def initialize
    super(10, 72, SaveLoadOrnate::SLOT_WIDTH, SaveLoadOrnate::SLOT_HEIGHT)
    @item_max = SaveLoadOrnate::SLOT_COUNT
    @column_max = 1
    self.contents = Bitmap.new(width - 32, @item_max * 32)
    self.opacity = 0
    self.back_opacity = 0
    self.z = 1010
    @cursor_sprite = Sprite.new
    @cursor_sprite.bitmap = SaveLoadOrnate.picture("Cursor")
    @cursor_sprite.z = 1011
    @cursor_sprite.x = self.x + 16
    refresh
    self.index = 0
  end

  def refresh
    self.contents.clear
    for i in 0...@item_max
      path = SaveLoadOrnate.filename(i)
      has_save = FileTest.exist?(path)
      self.contents.font.size = 18
      self.contents.font.color = has_save ? Color.new(228, 226, 206) : Color.new(126, 145, 151)
      self.contents.draw_text(13, i * 32, 32, 32, sprintf("%02d", i + 1))
      self.contents.font.size = 14
      date = has_save ? File.mtime(path).strftime("%m/%d %H:%M") : "— 空档 —"
      self.contents.draw_text(51, i * 32, 124, 32, date)
    end
  end

  def update_cursor_rect
    super
    self.cursor_rect.empty
    return if @cursor_sprite.nil?
    @cursor_sprite.x = self.x + 16
    @cursor_sprite.y = self.y + 16 + @index * 32 - self.oy
    first_y = self.y + 16
    last_y = self.y + self.height - 16 - 32
    @cursor_sprite.visible = @index >= 0 &&
      @cursor_sprite.y >= first_y && @cursor_sprite.y <= last_y
  end

  def dispose
    @cursor_sprite.dispose if @cursor_sprite && !@cursor_sprite.disposed?
    super
  end
end

class Window_SaveDetails < Window_Base
  attr_reader :index

  def initialize(index)
    super(230, 69, 400, 392)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.back_opacity = 0
    self.z = 1010
    @preview = Sprite.new
    @preview.z = 1012
    @index = index
    refresh
  end

  def index=(index)
    @index = index
  end

  def clear_preview
    if @preview.bitmap
      @preview.bitmap.dispose
      @preview.bitmap = nil
    end
    @preview.visible = false
  end

  def refresh
    self.contents.clear
    clear_preview
    path = SaveLoadOrnate.filename(@index)
    unless FileTest.exist?(path)
      draw_preview_message("此槽位尚未存档")
      return
    end

    begin
      stamp = File.mtime(path)
      frame_count = nil
      map_id = nil
      File.open(path, "rb") do |file|
        Marshal.load(file)                     # Character header.
        frame_count = Marshal.load(file)
        8.times { Marshal.load(file) }         # Game state before Game_Map.
        map_id = Marshal.load(file).map_id
      end
      draw_metadata(stamp, frame_count, map_id)
    rescue StandardError
      self.contents.font.size = 18
      self.contents.font.color = Color.new(226, 197, 154)
      self.contents.draw_text(18, 259, 330, 32, "存档信息暂不可用", 1)
    end
    draw_preview(path)
  end

  def draw_metadata(stamp, frame_count, map_id)
    infos = $data_mapinfos
    infos = load_data("Data/MapInfos.rxdata") if infos.nil?
    map_info = infos[map_id] if infos
    map_name = map_info ? map_info.name : "未知地点"
    total_seconds = frame_count / Graphics.frame_rate
    hours = total_seconds / 3600
    minutes = total_seconds / 60 % 60
    seconds = total_seconds % 60
    duration = sprintf("%02d:%02d:%02d", hours, minutes, seconds)
    self.contents.font.size = 19
    self.contents.font.color = Color.new(232, 231, 216)
    self.contents.draw_text(126, 245, 232, 32, map_name)
    self.contents.draw_text(126, 287, 232, 32, stamp.strftime("%Y/%m/%d %H:%M"))
    self.contents.draw_text(126, 329, 232, 32, duration)
  end

  def draw_preview(path)
    shot_path = BBS_66RPG_DIR + "Save#{@index}.jpg"
    if !FileTest.exist?(shot_path) || File.mtime(shot_path) < File.mtime(path) - 86400
      draw_preview_message("此存档暂无可用截图")
      return
    end
    begin
      @preview.bitmap = Bitmap.new(shot_path)
      scale = [336.0 / @preview.bitmap.width, 198.0 / @preview.bitmap.height].min
      image_width = (@preview.bitmap.width * scale).to_i
      image_height = (@preview.bitmap.height * scale).to_i
      @preview.zoom_x = scale
      @preview.zoom_y = scale
      @preview.x = 260 + (336 - image_width) / 2
      @preview.y = 92 + (198 - image_height) / 2
      @preview.visible = true
    rescue StandardError
      clear_preview
      draw_preview_message("此存档暂无可用截图")
    end
  end

  def draw_preview_message(message)
    self.contents.font.size = 20
    self.contents.font.color = Color.new(180, 190, 188)
    self.contents.draw_text(19, 95, 330, 32, message, 1)
  end

  def dispose
    clear_preview
    @preview.dispose
    super
  end
end

module SaveLoadOrnateScene
  def run_save_load_ui(load_mode)
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SaveLoadOrnate.picture("Frame")
    @background_sprite.z = 1000
    @title_sprite = Sprite.new
    @title_sprite.bitmap = SaveLoadOrnate.picture("Titles")
    @title_sprite.src_rect.set(0, load_mode ? 48 : 0, 180, 48)
    @title_sprite.x = 232
    @title_sprite.y = 4
    @title_sprite.z = 1020
    @count_sprite = Sprite.new
    @count_sprite.bitmap = SaveLoadOrnate.picture("Counts")
    @count_sprite.x = 447
    @count_sprite.y = 11
    @count_sprite.z = 1020
    @labels_sprite = Sprite.new
    @labels_sprite.bitmap = SaveLoadOrnate.picture("Labels")
    @labels_sprite.x = 244
    @labels_sprite.y = 323
    @labels_sprite.z = 1020
    @shade_sprite = Sprite.new
    @shade_sprite.bitmap = SaveLoadOrnate.picture("ListShade")
    @shade_sprite.x = 26
    @shade_sprite.y = 84
    @shade_sprite.z = 1005
    @command_window = Window_SaveSlots.new
    initial_index = $game_temp.last_file_index
    initial_index = 0 if initial_index.nil?
    initial_index = [[initial_index, 0].max, SaveLoadOrnate::SLOT_COUNT - 1].min
    @command_window.index = initial_index
    @content_window = Window_SaveDetails.new(initial_index)
    update_slot_count
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      update_slot_count
      break if $scene != self
    end
    Graphics.freeze
  ensure
    @command_window.dispose if @command_window && !@command_window.disposed?
    @content_window.dispose if @content_window && !@content_window.disposed?
    [@shade_sprite, @labels_sprite, @count_sprite, @title_sprite, @background_sprite].each do |sprite|
      sprite.dispose if sprite && !sprite.disposed?
    end
  end

  def update_slot_count
    return if @count_sprite.nil? || @command_window.nil?
    @count_sprite.src_rect.set(0, @command_window.index * 34, 164, 34)
  end
end

class Scene_Save
  include SaveLoadOrnateScene
  def main
    run_save_load_ui(false)
  end
end

class Scene_Load
  include SaveLoadOrnateScene
  def main
    run_save_load_ui(true)
  end
end
