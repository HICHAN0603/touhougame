# RPG Maker XP / RGSS1. Packed into Scripts.rxdata slot 239.
# Battle-only item list and help window; the normal menu's Window_Item is unchanged.

class Window_BattleItem < Window_Selectable
  def initialize
    super(160, 80, 320, 320)
    @column_max = 1
    self.opacity = 255
    self.back_opacity = 155
    self.z = 1200
    refresh
    self.index = @item_max > 0 ? 0 : -1
  end

  def item
    return nil if self.index < 0 || self.index >= @data.size
    @data[self.index]
  end

  def refresh
    self.contents.dispose if self.contents != nil
    self.contents = nil
    @data = []
    for id in 1...$data_items.size
      item = $data_items[id]
      next if item == nil
      # In battle, only "always" and "battle" items with stock are usable.
      next unless item.occasion == 0 || item.occasion == 1
      next unless $game_party.item_can_use?(id)
      @data.push(item)
    end
    @item_max = @data.size
    bitmap_height = [row_max * 32, self.height - 32].max
    self.contents = Bitmap.new(self.width - 32, bitmap_height)
    self.contents.font.size = 18
    for i in 0...@item_max
      draw_item(i)
    end
    self.index = @item_max - 1 if self.index >= @item_max
  end

  def draw_item(index)
    item = @data[index]
    return if item == nil
    y = index * 32
    icon = RPG::Cache.icon(item.icon_name)
    self.contents.font.color = normal_color
    self.contents.blt(4, y + 4, icon, Rect.new(0, 0, 24, 24))
    self.contents.draw_text(32, y, 208, 32, item.name)
    count = $game_party.item_number(item.id)
    self.contents.draw_text(242, y, 38, 32, count.to_s, 2)
  end

  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end

class Window_BattleItemHelp < Window_Base
  def initialize
    super(160, 400, 320, 64)
    self.contents = Bitmap.new(288, 32)
    self.contents.font.size = 14
    self.opacity = 255
    self.back_opacity = 155
    self.z = 1201
    self.visible = true
    @text = nil
  end

  def set_text(text, align = 0)
    text = text.to_s
    if text != @text
      @text = text
      self.contents.clear
      self.contents.font.color = normal_color
      lines = wrap_two_lines(text)
      self.contents.draw_text(4, 0, 280, 16, lines[0], align)
      self.contents.draw_text(4, 16, 280, 16, lines[1], align)
    end
    self.visible = true
  end

  def wrap_two_lines(text)
    lines = ["", ""]
    line = 0
    offset = 0
    while offset < text.size
      byte = text[offset, 1].unpack("C")[0]
      size = byte < 128 ? 1 : (byte < 224 ? 2 : (byte < 240 ? 3 : 4))
      char = text[offset, size]
      offset += size
      if char == "\n"
        line += 1
        break if line > 1
        next
      end
      if self.contents.text_size(lines[line] + char).width > 280
        line += 1
        break if line > 1
      end
      lines[line] += char
    end
    lines
  end
end

class Scene_Battle
  alias battle_item_original_main main
  alias battle_item_original_update_phase3_item_select update_phase3_item_select
  alias battle_item_original_end_item_select end_item_select

  def main
    battle_item_original_main
  ensure
    if @battle_item_help_window != nil && !@battle_item_help_window.disposed?
      @battle_item_help_window.dispose
      @battle_item_help_window = nil
    end
  end

  def start_item_select
    @item_window = Window_BattleItem.new
    @battle_item_help_window = Window_BattleItemHelp.new
    @item_window.help_window = @battle_item_help_window
    @help_window.visible = false
    @actor_command_window.active = false
    @actor_command_window.visible = false
  end

  def end_item_select
    if @battle_item_help_window != nil
      @battle_item_help_window.dispose
      @battle_item_help_window = nil
    end
    battle_item_original_end_item_select
  end

  def update_phase3_item_select
    if @item_window != nil && @item_window.active && @active_actor.inputable? &&
       Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      end_item_select
      return
    end
    battle_item_original_update_phase3_item_select
    if @battle_item_help_window != nil && @item_window != nil
      @battle_item_help_window.visible = @item_window.visible && @item_window.active
      @help_window.visible = false if @battle_item_help_window.visible
    end
  end
end
