#==============================================================================
# Menu_Display_Layers / 菜单显示层级 / RGSS1（Ruby 1.8）
# 在脚本编辑器中放在 Main 上方；供菜单的 main 方法引用。
# 只设置明确列出的菜单对象，不改 Window_Base、Sprite 或图片系统。
#==============================================================================
module TouhouMenuLayers
  BACKGROUND = 1000       # 菜单底板：高于事件图片视口200
  CONTENT = 1100          # 菜单主体、列表、说明
  TARGET = 1400           # 物品／特技的角色选择框；其底板和光标由原方法跟随
  BOOK_DETAIL = 1110      # 图鉴详情，高于图鉴主列表
  BOOK_IMAGE_OFFSET = 10 # 敌人图像相对详情窗口的偏移
  TASK_BASE = 1000        # 任务界面整体基准，内部继续保留80／103／104的顺序

  # 只在对应菜单初始化时调用，不影响战斗中使用的同类窗口。
  def self.set_windows(windows, z = CONTENT)
    for window in windows
      window.z = z if window
    end
  end

  # 原目标窗口没有在隐藏时同步隐藏独立光标。只扩展这两个菜单
  # 创建的实例，避免光标浮在列表上；不改战斗使用的Window_Target。
  module TargetCursorVisibility
    def visible=(value)
      super(value)
      @cursor_sprite.visible = value && @index != -1 if @cursor_sprite
    end

    def update_cursor_rect
      super
      @cursor_sprite.visible = self.visible && @index != -1 if @cursor_sprite
    end
  end

  def self.set_target(window)
    window.extend(TargetCursorVisibility)
    window.z = TARGET
    window.visible = window.visible
  end

  # 人物状态沿用原来的5000层。首次过渡前同步附属对象，避免它们
  # 在第一次update之前还停留在101～103层；后续仍由原update维护。
  # 此处只调整层级，不调用update，避免提前处理按键或状态说明。
  def self.sync_status_layers(window)
    offsets = [["@bg_sprite", -1], ["@character_window", 1],
      ["@help_window", 2], ["@state_window", 3]]
    for field, offset in offsets
      object = window.instance_variable_get(field)
      object.z = window.z + offset if object
    end
  end
end
