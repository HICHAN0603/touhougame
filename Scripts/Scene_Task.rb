#==============================================================================
# Scene_Task / 东方拾梦录任务日志 / RGSS1（Ruby 1.8）
# 资料集中在下面的 get_tasks_info；任务系统本身不绑定某个进度变量。
# get_task(id) 接受；finish_task(id) 完成并保留；remove_task(id) 才删除。
# 调试命令：get_all_task、finish_all_task。不会发放奖励。
# 任务接受与资料编写方式参照叶子《详尽任务显示界面 v2.1》（task.txt）。
#==============================================================================
module TaskJournal
  VERSION = 3
  BACKGROUND = "Scene_Task_v2"
  CATEGORIES = [:main, :side, :special]
  LABELS = {:main => "主线", :side => "支线", :special => "特殊"}
  MARKS = {:main => ["○", "●"], :side => ["△", "▲"], :special => ["☆", "★"]}
  LEGACY_IDS = {2 => 2, 3 => 14, 4 => 17, 5 => 18, 6 => 26, 7 => 901}
  POPUP_FRAMES = 60
  POPUP_SLIDE_FRAMES = 12

  def self.utf8(text)
    return text.to_s.unpack("U*").pack("U*")
  end

  def self.color(index = 0, alpha = 255)
    colors = [[238,235,218], [150,173,236], [242,149,136], [157,221,172],
      [144,207,218], [215,163,217], [219,187,128], [180,185,191],
      [135,143,152], [219,187,128]]
    c = colors[index] || colors[0]
    return Color.new(c[0], c[1], c[2], alpha)
  end

end

class Game_Task
  attr_accessor :id, :title, :briefing, :category, :completed, :expired, :visible
  attr_accessor :chapter, :variable_ids, :switch_ids, :expiry_condition
  attr_accessor :visibility_condition, :migration

  # 前三个参数沿用 task.txt；附加参数用于分类、完成判断与线路条件。
  def initialize(name, briefing, expiry_condition = nil, category = nil,
      completed = false, chapter = "", variable_ids = [], switch_ids = [],
      visibility_condition = nil)
    name = TaskJournal.utf8(name)
    @completed = completed || name.index("\\c[8]") == 0
    @title = name.gsub(/\\[Cc]\[[0-9]+\]/, "")
    for kind in TaskJournal::CATEGORIES
      for mark in TaskJournal::MARKS[kind]
        if @title.index(mark) == 0
          category ||= kind
          @completed = true if mark == TaskJournal::MARKS[kind][1]
          @title = @title[mark.length..-1]
        end
      end
    end
    @category = category || :side
    @category = :side unless TaskJournal::CATEGORIES.include?(@category)
    @briefing = TaskJournal.utf8(briefing)
    @chapter = chapter
    @expiry_condition = expiry_condition
    @visibility_condition = visibility_condition
    @variable_ids = variable_ids
    @switch_ids = switch_ids
    @migration = nil
    @expired = false
    @visible = true
  end

  def status
    return :done if @completed
    return :expired if @expired
    return :active
  end

  def status_label
    return {:active => "进行中", :done => "已完成", :expired => "已过期"}[status]
  end

  def mark
    return TaskJournal::MARKS[@category][@completed ? 1 : 0]
  end

  def name
    color = status == :active ? 9 : 8
    return "\\c[#{color}]" + mark + @title
  end
end

# 旧存档可能含有这个类的对象，保留反序列化所需的类名。
class Game_Encyc
  attr_accessor :name, :briefing
end

class Game_Party
  #--------------------------------------------------------------------------
  # 任务资料区：名称、简介、完成和过期条件都在这里维护。
  # 注意：get_task 的编号是这里的数组下标，不是变量编号。
  #--------------------------------------------------------------------------
  def get_tasks_info
    @tasks_info = []

    # 所有任务都在这里定义；三类使用同样的字段、同样的 Game_Task.new。
    # 分类：:main 主线（○/●），:side 支线（△/▲），:special 特殊（☆/★）。
    # 编号唯一即可，可以按剧情顺序自由排列，不需要额外的任务资料表。
    # 本批主线只在5、10、15……节点变化，区间内目标和说明保持不变。

    #--------------------------------------------------------------------
    # 任务01：突来的通缉｜变量15达到5时接受，达到10时完成
    #--------------------------------------------------------------------
    id          = 1  # 任务编号：事件中调用 get_task(1)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "突来的通缉"  # 任务标题
    description = "一张满是荒唐罪名的拘捕令打乱了采蘑菇的计划。先保住自己的自由再说！"  # 剧情说明
    objective   = "应对堵在魔法店门口的红魔警察。"  # 当前目标：整个5点区间保持一致
    report      = "击退了红魔警察，与爱丽丝决定去香霖堂打听通缉令的消息。"  # 完成报告
    completed   = $game_variables[15] >= 10  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 5]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务02：前往香霖堂｜变量15达到10时接受，达到15时完成
    #--------------------------------------------------------------------
    id          = 2  # 任务编号：事件中调用 get_task(2)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "前往香霖堂"  # 任务标题
    description = "霖之助或许听说过雅罗的动静。出发前，也可以去爱丽丝家拿些补给。"  # 剧情说明
    objective   = "穿过魔法森林，前往香霖堂。"  # 当前目标：整个5点区间保持一致
    report      = "穿过魔法森林，抵达了香霖堂门口。"  # 完成报告
    completed   = $game_variables[15] >= 15  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 10]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务03：询问霖之助｜变量15达到15时接受，达到20时完成
    #--------------------------------------------------------------------
    id          = 3  # 任务编号：事件中调用 get_task(3)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "询问霖之助"  # 任务标题
    description = "已经抵达店门口。红魔为何突然抓人，先听听消息灵通的店主怎么说。"  # 剧情说明
    objective   = "进入香霖堂，向霖之助询问通缉令的事。"  # 当前目标：整个5点区间保持一致
    report      = "霖之助说明红魔加强了戒备。两人决定趁夜潜入红魔馆。"  # 完成报告
    completed   = $game_variables[15] >= 20  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 15]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务04：夜赴红魔｜变量15达到20时接受，达到25时完成
    #--------------------------------------------------------------------
    id          = 4  # 任务编号：事件中调用 get_task(4)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "夜赴红魔"  # 任务标题
    description = "红魔馆加强了戒备。趁夜潜入，直接找蕾米莉亚问个清楚。"  # 剧情说明
    objective   = "离开香霖堂，沿魔法森林的路赶往雅罗边境。"  # 当前目标：整个5点区间保持一致
    report      = "帮助梦美解决了实验引来的妖怪，并确认了这位天界学者的来历。"  # 完成报告
    completed   = $game_variables[15] >= 25  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 20]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务05：边境夜路｜变量15达到25时接受，达到30时完成
    #--------------------------------------------------------------------
    id          = 5  # 任务编号：事件中调用 get_task(5)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "边境夜路"  # 任务标题
    description = "梦美离开了，潜入红魔馆的计划还得继续。别让这段插曲拖到天亮。"  # 剧情说明
    objective   = "继续前进，穿过雅罗与魔法森林的交界。"  # 当前目标：整个5点区间保持一致
    report      = "穿过雅罗与森林的交界，来到了红魔馆。"  # 完成报告
    completed   = $game_variables[15] >= 30  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 25]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务06：红魔馆门前｜变量15达到30时接受，达到35时完成
    #--------------------------------------------------------------------
    id          = 6  # 任务编号：事件中调用 get_task(6)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "红魔馆门前"  # 任务标题
    description = "熟悉的偷书路线也不总是畅通无阻。今晚的门卫，偏偏没有睡着。"  # 剧情说明
    objective   = "与爱丽丝突破红美铃的阻拦。"  # 当前目标：整个5点区间保持一致
    report      = "击退美铃后警报响起，两人改走地下水路。看来熟悉的偷书路线也会失灵。"  # 完成报告
    completed   = $game_variables[15] >= 35  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 30]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务07：地下水路｜变量15达到35时接受，达到40时完成
    #--------------------------------------------------------------------
    id          = 7  # 任务编号：事件中调用 get_task(7)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "地下水路"  # 任务标题
    description = "魔理沙的秘密路线直达图书馆。希望这次的偷书经验能派上正经用场。"  # 剧情说明
    objective   = "沿地下水路寻找通往大图书馆的出口。"  # 当前目标：整个5点区间保持一致
    report      = "在地下水路中了帕秋莉的机关与毒雾，潜入者反而落入了地牢。"  # 完成报告
    completed   = $game_variables[15] >= 40  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 35]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务08：地牢醒来｜变量15达到40时接受，达到45时完成
    #--------------------------------------------------------------------
    id          = 8  # 任务编号：事件中调用 get_task(8)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "地牢醒来"  # 任务标题
    description = "潜入者反而被关进了地牢。先弄清情况，再找逃出去的办法。"  # 剧情说明
    objective   = "醒来后确认爱丽丝和自己的处境。"  # 当前目标：整个5点区间保持一致
    report      = "在地牢醒来，并得到芙兰的援手。牢门终于被打开了。"  # 完成报告
    completed   = $game_variables[15] >= 45  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 40]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务09：离开地牢｜变量15达到45时接受，达到50时完成
    #--------------------------------------------------------------------
    id          = 9  # 任务编号：事件中调用 get_task(9)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "离开地牢"  # 任务标题
    description = "芙兰打开了牢门，还坚持要一起去。现在该找帕秋莉和蕾米莉亚问个明白了。"  # 剧情说明
    objective   = "与爱丽丝、芙兰离开地牢，前往大图书馆。"  # 当前目标：整个5点区间保持一致
    report      = "离开牢房，经历图书馆的交锋，终于获得了见蕾米莉亚的机会。"  # 完成报告
    completed   = $game_variables[15] >= 50  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 45]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务10：前往谒见间｜变量15达到50时接受，达到55时完成
    #--------------------------------------------------------------------
    id          = 10  # 任务编号：事件中调用 get_task(10)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "前往谒见间"  # 任务标题
    description = "这一次似乎真的是传送魔法。终于能问问那位大小姐，到底想做什么。"  # 剧情说明
    objective   = "通过传送前往谒见之间，与蕾米莉亚见面。"  # 当前目标：整个5点区间保持一致
    report      = "在谒见之间与蕾米发生冲突，随后约定到她的房间谈正事。"  # 完成报告
    completed   = $game_variables[15] >= 55  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 50]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务11：私人会面｜变量15达到55时接受，达到60时完成
    #--------------------------------------------------------------------
    id          = 11  # 任务编号：事件中调用 get_task(11)
    category    = :main  # 任务分类
    chapter     = "序章"  # 所属章节
    name        = "私人会面"  # 任务标题
    description = "她终于愿意谈正事。爱丽丝也决定同行，通缉令背后的理由该揭晓了。"  # 剧情说明
    objective   = "前往蕾米莉亚的房间；离开谒见间后右拐，再左拐。"  # 当前目标：整个5点区间保持一致
    report      = "蕾米委托寻找五件天仪，交付折扇，并透露魔理沙的父亲仍然活着。"  # 完成报告
    completed   = $game_variables[15] >= 60  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 55]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务12：等待来信｜变量15达到60时接受，达到65时完成
    #--------------------------------------------------------------------
    id          = 12  # 任务编号：事件中调用 get_task(12)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "等待来信"  # 任务标题
    description = "蕾米提出寻找五件天仪，还透露父亲仍然活着。折扇中的秘密，也许与这趟旅程有关。"  # 剧情说明
    objective   = "在香霖堂休整，研究折扇并等候红魔馆的通知。"  # 当前目标：整个5点区间保持一致
    report      = "研究了折扇，收到红魔馆的来信。第一件天仪的线索指向冥界。"  # 完成报告
    completed   = $game_variables[15] >= 65  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 60]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务13：再访红魔馆｜变量15达到65时接受，达到70时完成
    #--------------------------------------------------------------------
    id          = 13  # 任务编号：事件中调用 get_task(13)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "再访红魔馆"  # 任务标题
    description = "冥界之行已经决定。准备好补给，再听听这次委托还有哪些条件。"  # 剧情说明
    objective   = "前往红魔馆的谒见之间，与蕾米莉亚商议出海。"  # 当前目标：整个5点区间保持一致
    report      = "与蕾米商议了出海安排，帕秋莉加入队伍。"  # 完成报告
    completed   = $game_variables[15] >= 70  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 65]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务14：工坊与港口｜变量15达到70时接受，达到75时完成
    #--------------------------------------------------------------------
    id          = 14  # 任务编号：事件中调用 get_task(14)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "工坊与港口"  # 任务标题
    description = "帕秋莉加入了队伍，并传授三人阵法。工坊靠近西区和住宅区，出海前先去一趟。"  # 剧情说明
    objective   = "先去雅罗中区的机甲工坊，再到南部港口乘船。"  # 当前目标：整个5点区间保持一致
    report      = "完成工坊的准备，抵达港口，确定了出海安排。"  # 完成报告
    completed   = $game_variables[15] >= 75  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 70]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务15：出海准备｜变量15达到75时接受，达到80时完成
    #--------------------------------------------------------------------
    id          = 15  # 任务编号：事件中调用 get_task(15)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "出海准备"  # 任务标题
    description = "港口的安排已经谈妥。隔海相望的生死边界，可不是普通的观光目的地。"  # 剧情说明
    objective   = "准备好装备与补给，开始前往冥界的航程。"  # 当前目标：整个5点区间保持一致
    report      = "航程开始。船上交谈与小憩之后，突如其来的袭击打断了休息。"  # 完成报告
    completed   = $game_variables[15] >= 80  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 75]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务16：海上突袭｜变量15达到80时接受，达到85时完成
    #--------------------------------------------------------------------
    id          = 16  # 任务编号：事件中调用 get_task(16)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "海上突袭"  # 任务标题
    description = "休息被突如其来的动静打断了。先查明发生了什么，保护这艘船。"  # 剧情说明
    objective   = "确认船外的袭击，与同伴会合。"  # 当前目标：整个5点区间保持一致
    report      = "在海盗袭击中弃船，转移到诺亚方舟。退路已断，只能击败海盗船长。"  # 完成报告
    completed   = $game_variables[15] >= 85  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 80]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务17：夺取方舟｜变量15达到85时接受，达到90时完成
    #--------------------------------------------------------------------
    id          = 17  # 任务编号：事件中调用 get_task(17)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "夺取方舟"  # 任务标题
    description = "要继续横渡大海，就必须夺下这艘船。先突破海盗的防线。"  # 剧情说明
    objective   = "穿过诺亚方舟，前往主控室击败船长。"  # 当前目标：整个5点区间保持一致
    report      = "突破海盗防线，击败船长，夺下了诺亚方舟。"  # 完成报告
    completed   = $game_variables[15] >= 90  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 85]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务18：继续航行｜变量15达到90时接受，达到95时完成
    #--------------------------------------------------------------------
    id          = 18  # 任务编号：事件中调用 get_task(18)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "继续航行"  # 任务标题
    description = "海盗船长已经被击败。接下来是掌舵的问题……这艘船竟然没有导航。"  # 剧情说明
    objective   = "乘坐夺下的诺亚方舟，继续前往冥界。"  # 当前目标：整个5点区间保持一致
    report      = "继续跨海航行，与妖梦会合，终于在万苍登陆。"  # 完成报告
    completed   = $game_variables[15] >= 95  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 90]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务19：万苍登陆｜变量15达到95时接受，达到100时完成
    #--------------------------------------------------------------------
    id          = 19  # 任务编号：事件中调用 get_task(19)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "万苍登陆"  # 任务标题
    description = "航程终于结束，妖梦也将前往白玉楼。把船留给小恶魔照看，继续赶路。"  # 剧情说明
    objective   = "从万苍港前往冥界入口，穿过边界。"  # 当前目标：整个5点区间保持一致
    report      = "解决了骚灵三姐妹的阻拦，穿过冥界入口。"  # 完成报告
    completed   = $game_variables[15] >= 100  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 95]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务20：白玉楼来客｜变量15达到100时接受，达到105时完成
    #--------------------------------------------------------------------
    id          = 20  # 任务编号：事件中调用 get_task(20)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "白玉楼来客"  # 任务标题
    description = "入口的阻碍暂时解决了。与此同时，白玉楼也迎来了另一位客人。"  # 剧情说明
    objective   = "继续前往白玉楼，留意冥界的动向。"  # 当前目标：整个5点区间保持一致
    report      = "白玉楼迎来八云紫的来访。会面结束后，她离开了幽幽子的房间。"  # 完成报告
    completed   = $game_variables[15] >= 105  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 100]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务21：庭前的暗影｜变量15达到105时接受，达到110时完成
    #--------------------------------------------------------------------
    id          = 21  # 任务编号：事件中调用 get_task(21)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "庭前的暗影"  # 任务标题
    description = "八云紫离开了幽幽子的房间，却似乎没有摆脱一路跟来的视线。"  # 剧情说明
    objective   = "留意白玉楼庭前发生的动静。"  # 当前目标：整个5点区间保持一致
    report      = "庭前的追踪与交锋仍留下疑问。与此同时，一行人继续向白玉楼前进。"  # 完成报告
    completed   = $game_variables[15] >= 110  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 105]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务22：抵达白玉｜变量15达到110时接受，达到115时完成
    #--------------------------------------------------------------------
    id          = 22  # 任务编号：事件中调用 get_task(22)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "抵达白玉"  # 任务标题
    description = "一行人终于来到白玉。寻找金之天仪的旅程，才刚刚进入关键之处。"  # 剧情说明
    objective   = "与同行者抵达白玉楼城区。"  # 当前目标：整个5点区间保持一致
    report      = "抵达白玉楼城区，妖梦暂时告辞。折扇开始发光，大家决定先找宿屋休整。"  # 完成报告
    completed   = $game_variables[15] >= 115  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 110]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务23：冥界宿屋｜变量15达到115时接受，达到120时完成
    #--------------------------------------------------------------------
    id          = 23  # 任务编号：事件中调用 get_task(23)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "冥界宿屋"  # 任务标题
    description = "帕秋莉建议先休息，再检查术式。至于酒店够不够四星级，还是以后再说吧。"  # 剧情说明
    objective   = "寻找白玉楼城区的宿屋，住宿并研究折扇。"  # 当前目标：整个5点区间保持一致
    report      = "在宿屋研究折扇，决定第二天向北拜访幽幽子。"  # 完成报告
    completed   = $game_variables[15] >= 120  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 115]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务24：向北寻访｜变量15达到120时接受，达到125时完成
    #--------------------------------------------------------------------
    id          = 24  # 任务编号：事件中调用 get_task(24)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "向北寻访"  # 任务标题
    description = "折扇的反应随着前进变强，却仍无法解开。下一步是拜访白玉楼的主人。"  # 剧情说明
    objective   = "从宿屋出发，向北前往幽幽子的居所。"  # 当前目标：整个5点区间保持一致
    report      = "经历入口处的拦阻，说明红魔之行的目的。妖梦同意陪同登楼。"  # 完成报告
    completed   = $game_variables[15] >= 125  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 120]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务25：庭师的引路｜变量15达到125时接受，达到130时完成
    #--------------------------------------------------------------------
    id          = 25  # 任务编号：事件中调用 get_task(25)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "庭师的引路"  # 任务标题
    description = "妖梦同意最后再帮一次忙，也会监视一行人的举动。别辜负这次信任。"  # 剧情说明
    objective   = "与妖梦一起登上白玉楼的阶梯。"  # 当前目标：整个5点区间保持一致
    report      = "在妖梦陪同下登上阶梯，获得了白玉楼主人的迎接。"  # 完成报告
    completed   = $game_variables[15] >= 130  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 125]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务26：拜访幽幽子｜变量15达到130时接受，达到135时完成
    #--------------------------------------------------------------------
    id          = 26  # 任务编号：事件中调用 get_task(26)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "拜访幽幽子"  # 任务标题
    description = "白玉楼的主人似乎已经知道一行人要来。希望这次能够少猜几句谜语。"  # 剧情说明
    objective   = "进入幽幽子的房间，询问金之天仪的下落。"  # 当前目标：整个5点区间保持一致
    report      = "询问了金之天仪的下落。幽幽子暂未交出答案，却邀请大家留下用餐。"  # 完成报告
    completed   = $game_variables[15] >= 135  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 130]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务27：饭前散步｜变量15达到135时接受，达到140时完成
    #--------------------------------------------------------------------
    id          = 27  # 任务编号：事件中调用 get_task(27)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "饭前散步"  # 任务标题
    description = "幽幽子邀请大家留下用餐，暂时却没有交出天仪。先看看这座庭院里还有什么线索。"  # 剧情说明
    objective   = "在白玉楼庭院走走，前往西行妖附近查看。"  # 当前目标：整个5点区间保持一致
    report      = "在西行妖旁与妖梦聊起妖忌的往事，随后得知宴席已经准备好了。"  # 完成报告
    completed   = $game_variables[15] >= 140  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 135]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务28：白玉楼宴席｜变量15达到140时接受，达到145时完成
    #--------------------------------------------------------------------
    id          = 28  # 任务编号：事件中调用 get_task(28)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "白玉楼宴席"  # 任务标题
    description = "妖梦带来了开饭的消息。有关天仪与妖忌的疑问，留到席间继续询问。"  # 剧情说明
    objective   = "返回幽幽子的房间，与大家一起用餐。"  # 当前目标：整个5点区间保持一致
    report      = "席间继续询问天仪，幽幽子提出以实力试炼一行人。"  # 完成报告
    completed   = $game_variables[15] >= 145  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 140]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务29：幽幽子试炼｜变量15达到145时接受，达到150时完成
    #--------------------------------------------------------------------
    id          = 29  # 任务编号：事件中调用 get_task(29)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "幽幽子试炼"  # 任务标题
    description = "想取得天仪，先证明这支队伍的实力。至少这次不用再走一个大迷宫了。"  # 剧情说明
    objective   = "在西行妖前与妖梦联手，接受幽幽子的试炼。"  # 当前目标：整个5点区间保持一致
    report      = "通过幽幽子的试炼，确认妖忌留下的剑就是金之天仪，但妖梦尚不能拔出它。"  # 完成报告
    completed   = $game_variables[15] >= 150  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 145]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务30：庭师的旅程｜变量15达到150时接受，达到155时完成
    #--------------------------------------------------------------------
    id          = 30  # 任务编号：事件中调用 get_task(30)
    category    = :main  # 任务分类
    chapter     = "第一章"  # 所属章节
    name        = "庭师的旅程"  # 任务标题
    description = "妖忌留下的剑就是金之天仪，但妖梦尚不能拔出它。她需要在旅途中继续成长。"  # 剧情说明
    objective   = "带上妖梦，离开白玉楼，返回现世。"  # 当前目标：整个5点区间保持一致
    report      = "带上妖梦离开白玉楼，返回现世。帕秋莉负责向红魔馆汇报。"  # 完成报告
    completed   = $game_variables[15] >= 155  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 150]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务31：雅罗的夜晚｜变量15达到155时接受，达到160时完成
    #--------------------------------------------------------------------
    id          = 31  # 任务编号：事件中调用 get_task(31)
    category    = :main  # 任务分类
    chapter     = "第二章"  # 所属章节
    name        = "雅罗的夜晚"  # 任务标题
    description = "帕秋莉会向红魔馆汇报。看似可以回家的夜晚，却在别处发生了变故。"  # 剧情说明
    objective   = "结束冥界之行，留意雅罗正在发生的事。"  # 当前目标：整个5点区间保持一致
    report      = "雅罗小巷发生了惨案，原本平静的归途被新的风波打断。"  # 完成报告
    completed   = $game_variables[15] >= 160  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 155]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务32：红魔的动向｜变量15达到160时接受，达到165时完成
    #--------------------------------------------------------------------
    id          = 32  # 任务编号：事件中调用 get_task(32)
    category    = :main  # 任务分类
    chapter     = "第二章"  # 所属章节
    name        = "红魔的动向"  # 任务标题
    description = "凶案之后，城市中的不安尚未散去。红魔馆接到的消息，也将影响接下来的行动。"  # 剧情说明
    objective   = "留意红魔馆对雅罗局势的反应。"  # 当前目标：整个5点区间保持一致
    report      = "港区教徒聚集游行，咲夜前往处理。一行人随后决定协助凶案调查。"  # 完成报告
    completed   = $game_variables[15] >= 165  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 160]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务33：接受调查｜变量15达到165时接受，达到170时完成
    #--------------------------------------------------------------------
    id          = 33  # 任务编号：事件中调用 get_task(33)
    category    = :main  # 任务分类
    chapter     = "第二章"  # 所属章节
    name        = "接受调查"  # 任务标题
    description = "一行人被卷入凶案调查。先听清案情，再决定从哪些线索入手。"  # 剧情说明
    objective   = "前往红魔警署二楼，与四季映姬、小町商议查案。"  # 当前目标：整个5点区间保持一致
    report      = "在警署会见四季映姬与小町，确定了现场、证词和档案三路取证的安排。"  # 完成报告
    completed   = $game_variables[15] >= 170  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 165]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务34：三路取证｜变量15达到170时接受，达到175时完成
    #--------------------------------------------------------------------
    id          = 34  # 任务编号：事件中调用 get_task(34)
    category    = :main  # 任务分类
    chapter     = "第二章"  # 所属章节
    name        = "三路取证"  # 任务标题
    description = "现场位于雅罗东部，目击者可从大教堂一带问起。第一次与警察合作，先把线索记全。"  # 剧情说明
    objective   = "调查案发现场、询问目击者，并查阅警署档案。"  # 当前目标：整个5点区间保持一致
    report      = "确认尸体发现处并非第一案发地点，调查开始转向尸体的搬运方式。"  # 完成报告
    completed   = $game_variables[15] >= 175  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 170]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 任务35：追查搬运｜变量15达到175时接受，达到180时完成
    #--------------------------------------------------------------------
    id          = 35  # 任务编号：事件中调用 get_task(35)
    category    = :main  # 任务分类
    chapter     = "第二章"  # 所属章节
    name        = "追查搬运"  # 任务标题
    description = "现场不是第一案发地点。凶手怎样搬运尸体，为什么拖拽痕迹只出现了一段？"  # 剧情说明
    objective   = "检查雅罗东部附近的可疑地点，继续补齐证词与档案。"  # 当前目标：整个5点区间保持一致
    report      = "整理了这一阶段的现场、证词与档案记录。凶手搬运尸体的方法仍需继续追查。"  # 完成报告
    completed   = $game_variables[15] >= 180  # 变量完成条件
    completed ||= (@task_manual_completed || {})[id] == true  # 支持手动完成

    briefing = "\\c[9]剧情说明\\c[0]\n#{description}\n\n"
    if completed
      briefing += "\\c[6]完成报告\\c[0]\n#{report}"
    else
      briefing += "\\c[6]当前目标\\c[0]\n#{objective}"
    end

    @tasks_info[id] = Game_Task.new(
      name, briefing, nil, category, completed, chapter, [15])
    @tasks_info[id].migration = [15, 175]  # 旧存档补录条件

    #--------------------------------------------------------------------
    # 后续主线、支线、特殊事件都继续加在本方法内，沿用上面的单条写法。
    # category 改为 :side 或 :special 即可切换分类。
    # Game_Task.new 参数：
    # 标题、简介、过期条件、分类、完成状态、章节、依赖变量、依赖开关、显示条件。
    # 依赖数组应包含文字和各项条件所使用的全部变量、开关。
    # AB线独立配置变量和显示条件，不共用进度，不必修改任务系统。
    # 例如A线使用变量16及开关61：
    # @tasks_info[101] = Game_Task.new(
    #   "新的调查", "前往指定地点。", nil, :main,
    #   $game_variables[16] >= 10, "第二章 A线", [16], [61],
    #   "$game_switches[61]")
    # 上面的变量和开关仅为示例，按实际剧情选用。
    #--------------------------------------------------------------------

    # 兼容保留旧存档里已经获得的其他任务，统一使用相同的任务定义。
    for id, data in (@task_legacy_definitions || {})
      @tasks_info[id] = Game_Task.new(data[0], data[1], nil, data[2], data[3])
    end
    return @tasks_info
  end
  alias task_journal_party_initialize initialize
  def initialize
    task_journal_party_initialize
    @task_schema_version = TaskJournal::VERSION
    @task_records = {}
    @task_manual_completed = {}
    @task_serial = 0
    @task_signatures = {}
    @task_revision = 0
  end

  def task_ensure
    return if @task_schema_version == TaskJournal::VERSION
    @task_records ||= {}
    @task_manual_completed ||= {}
    @task_serial ||= 0
    @task_signatures = {}
    @task_revision ||= 0
    @task_legacy_definitions ||= {}
    old_ids = @current_encyc || []
    old_info = @encyc_info || []
    if old_ids.include?(7) && old_info[7]
      old = old_info[7]
      state = (@lr_other_quest_states || {})[7]
      kind = state ? state[0] : :side
      done = state ? state[1] : false
      @task_legacy_definitions[901] = [old.name, old.briefing, kind, done]
      @task_records[901] = (@task_serial += 1)
    end
    @task_schema_version = TaskJournal::VERSION
    task_refresh_catalog(false)
    # 迁移条件属于任务资料，系统无需知道变量15或某条AB线。
    for task in @tasks_info
      next if task == nil || task.migration == nil || !task.visible
      var, start = task.migration
      if $game_variables[var] >= start && !@task_records.has_key?(task.id)
        @task_records[task.id] = (@task_serial += 1)
      end
    end
    @encyc_info = @current_encyc = @lr_main_history = nil
    task_refresh_catalog(false)
  end

  def task_condition(condition, default)
    return default if condition == nil || condition == ""
    return condition if condition == true || condition == false
    return !!instance_eval(condition.to_s)
  end

  def task_refresh_catalog(notify = false)
    old_signatures = @task_signatures || {}
    get_tasks_info
    signatures = {}
    @tasks_info.each_with_index do |task, id|
      next if task == nil
      task.id = id
      task.completed = task.completed || (@task_manual_completed || {})[id] == true
      task.expired = !task.completed && task_condition(task.expiry_condition, false)
      task.visible = task_condition(task.visibility_condition, true)
      next unless (@task_records || {}).has_key?(id)
      signature = [task.title, task.briefing, task.status, task.visible, task.category, task.chapter]
      signatures[id] = signature
      if notify && old_signatures[id] && old_signatures[id] != signature && task.visible
        task_notice(id, task.status == :done ? :done : :updated)
      end
    end
    @task_revision = (@task_revision || 0) + 1 if signatures != old_signatures
    @task_signatures = signatures
    return @tasks_info
  end

  def tasks_info
    task_ensure
    task_refresh_catalog(false) if @tasks_info == nil
    return @tasks_info
  end

  def current_tasks
    task_ensure
    tasks_info
    priorities = {:active => 0, :expired => 1, :done => 2}
    ids = @task_records.keys.select { |id| @tasks_info[id] && @tasks_info[id].visible }
    return ids.sort do |a, b|
      pa, pb = priorities[@tasks_info[a].status], priorities[@tasks_info[b].status]
      pa == pb ? @task_records[b] <=> @task_records[a] : pa <=> pb
    end
  end

  def task_accept(id, notify = true)
    return false unless id.is_a?(Integer) && id > 0
    task_ensure
    task_refresh_catalog(false)
    return false if @tasks_info[id] == nil || @task_records.has_key?(id)
    @task_records[id] = (@task_serial += 1)
    @latest_task = id
    task_refresh_catalog(false)
    task_notice(id, :accepted) if notify && @tasks_info[id].visible
    return true
  end

  def task_finish(id)
    return unless id.is_a?(Integer) && id > 0
    task_ensure
    return if tasks_info[id] == nil
    task_accept(id, false) unless @task_records.has_key?(id)
    @task_manual_completed[id] = true
    task_refresh_catalog(true)
  end

  def task_remove(id)
    return unless id.is_a?(Integer) && id > 0
    task_ensure
    @task_records.delete(id)
    @task_manual_completed.delete(id)
    task_refresh_catalog(false)
  end

  def task_dependency_changed(kind, id)
    return unless @task_schema_version == TaskJournal::VERSION && @tasks_info
    for task in @tasks_info
      next if task == nil || !@task_records.has_key?(task.id)
      dependencies = kind == :variable ? task.variable_ids : task.switch_ids
      if dependencies.include?(id)
        task_refresh_catalog(true)
        return
      end
    end
  end

  def task_notice(id, action)
    return if $game_temp == nil
    # 同一段演出中合并提示，完整记录仍保留在日志里。
    $game_temp.task_journal_notice = [id, action]
  end

  def task_revision
    return @task_revision || 0
  end

  attr_writer :latest_task
  def latest_task
    @latest_task = current_tasks[0] unless current_tasks.include?(@latest_task)
    return @latest_task
  end

  # 兼容仍在使用旧名称的事件/脚本。
  def encyc_info; return tasks_info; end
  def current_encyc; return current_tasks; end
  def get_encyc_info; task_ensure; return task_refresh_catalog(false); end
end

class Game_Temp
  attr_accessor :task_journal_notice
end

class Game_Variables
  alias task_journal_variable_set []=
  def []=(id, value)
    previous = self[id]
    task_journal_variable_set(id, value)
    if previous != self[id] && $game_party
      $game_party.task_dependency_changed(:variable, id)
    end
  end
end

class Game_Switches
  alias task_journal_switch_set []=
  def []=(id, value)
    previous = self[id]
    task_journal_switch_set(id, value)
    if previous != self[id] && $game_party
      $game_party.task_dependency_changed(:switch, id)
    end
  end
end

class Interpreter
  def get_task(id)
    $game_party.task_accept(id)
    return true
  end
  def finish_task(id)
    $game_party.task_finish(id)
    return true
  end
  def remove_task(id)
    $game_party.task_remove(id)
    return true
  end
  def get_all_task
    $game_party.tasks_info.each_with_index { |task, id| $game_party.task_accept(id, false) if task }
    return true
  end
  def finish_all_task
    $game_party.current_tasks.each { |id| $game_party.task_finish(id) }
    return true
  end
  def get_encyc(id); return get_task(TaskJournal::LEGACY_IDS[id] || id); end
  def finish_encyc(id); return finish_task(TaskJournal::LEGACY_IDS[id] || id); end
  def get_all_encyc; return get_all_task; end
  def finish_all_encyc; return finish_all_task; end
end

# 格式文字：保留参考脚本的变量、角色名、颜色、图标和图片控制码。
module TaskText
  def self.render(text, width, size = 20)
    text = TaskJournal.utf8(text).gsub(/\\\\/, "\000")
    4.times do
      previous = text.dup
      text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i].to_s }
      break if text == previous
    end
    text.gsub!(/\\[Nn]\[([0-9]+)\]/) { $game_actors[$1.to_i] ? TaskJournal.utf8($game_actors[$1.to_i].name) : "" }
    codes = text.unpack("U*")
    measure = Bitmap.new(1, 1)
    measure.font.size = size
    x = y = index = color = 0
    line_height = 28
    commands = []
    while index < codes.size
      code = codes[index]
      if code == 92 && codes[index + 2] == 91
        ending = index + 3
        ending += 1 while ending < codes.size && codes[ending] != 93
        if ending < codes.size
          tag = codes[index + 1]
          value = codes[index + 3...ending].pack("U*")
          if tag == 67 || tag == 99
            color = value.to_i
            index = ending + 1
            next
          elsif [73,105,80,112].include?(tag)
            picture = [80,112].include?(tag)
            image = picture ? RPG::Cache.picture(value) : RPG::Cache.icon(value)
            w = [image.width, width].min
            h = picture ? image.height * w / image.width : 24
            w = 24 unless picture
            if x + w > width
              x = 0; y += line_height; line_height = 28
            end
            commands.push([:image, x, y, image, w, h, color])
            x += w + 4
            line_height = [line_height, h + 4].max
            index = ending + 1
            next
          end
        end
      end
      if code == 10
        x = 0; y += line_height; line_height = 28
      else
        char = [code == 0 ? 92 : code].pack("U*")
        w = [measure.text_size(char).width, 1].max
        if x + w > width
          x = 0; y += line_height; line_height = 28
        end
        commands.push([:text, x, y, char, w, 28, color])
        x += w
      end
      index += 1
    end
    measure.dispose
    bitmap = Bitmap.new(width + 4, [y + line_height + 4, 32].max)
    bitmap.font.size = size
    for kind, cx, cy, value, w, h, c in commands
      if kind == :text
        bitmap.font.color = Color.new(0, 0, 0, 210)
        bitmap.draw_text(cx + 1, cy + 1, w + 4, 28, value)
        bitmap.font.color = TaskJournal.color(c)
        bitmap.draw_text(cx, cy, w + 4, 28, value)
      else
        bitmap.stretch_blt(Rect.new(cx, cy, w, h), value, value.rect)
      end
    end
    return bitmap
  end
end

class Scene_Task
  def initialize
    @return_to_menu = $scene.is_a?(Scene_Menu)
    @category_index = 0
    @selection = [0, 0, 0]
    @detail_mode = false
    @scroll = 0
  end

  def main
    $game_party.task_ensure
    $game_party.task_refresh_catalog(false)
    begin
      create_ui
      refresh_ui
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        break if $scene != self
      end
      Graphics.freeze
    ensure
      dispose_ui
    end
  end

  def create_ui
    @background = Sprite.new
    @background.z = 80
    @background.bitmap = Bitmap.new(640, 480)
    source = RPG::Cache.windowskin(TaskJournal::BACKGROUND)
    @background.bitmap.stretch_blt(Rect.new(0,0,640,480), source, source.rect)
    @overlay = Sprite.new
    @overlay.z = 103
    @overlay.bitmap = Bitmap.new(640,480)
    @detail_viewport = Viewport.new(248,145,364,252)
    @detail_viewport.z = 104
    @detail = Sprite.new(@detail_viewport)
  end

  def text(bitmap, x, y, width, height, message, size = 20, color = 0, align = 0)
    bitmap.font.size = size
    bitmap.font.color = Color.new(0,0,0,220)
    bitmap.draw_text(x+1,y+1,width,height,message,align)
    bitmap.font.color = TaskJournal.color(color)
    bitmap.draw_text(x,y,width,height,message,align)
  end

  def refresh_ui
    @revision = $game_party.task_revision
    category = TaskJournal::CATEGORIES[@category_index]
    @ids = $game_party.current_tasks.select { |id| $game_party.tasks_info[id].category == category }
    @selection[@category_index] = [[@selection[@category_index], @ids.size-1].min, 0].max
    @selected_id = @ids[@selection[@category_index]]
    b = @overlay.bitmap
    b.clear
    b.fill_rect(56,87,152,310,Color.new(0,0,0,90))
    b.fill_rect(246,70,370,329,Color.new(0,0,0,105))
    TaskJournal::CATEGORIES.each_with_index do |kind, i|
      count = $game_party.current_tasks.select { |id| $game_party.tasks_info[id].category == kind }.size
      color = i == @category_index ? 6 : 7
      label = TaskJournal::MARKS[kind][0] + TaskJournal::LABELS[kind] + "任务  #{count}"
      text(b,i*213+18,17,177,28,label,21,color,1)
      b.fill_rect(i*213+48,48,117,2,TaskJournal.color(6,210)) if i == @category_index
    end
    text(b,62,72,145,24,"任务记录",18,9,1)
    if @ids.empty?
      text(b,62,179,145,28,"暂无任务",18,7,1)
      text(b,263,205,330,30,"尚未获得#{TaskJournal::LABELS[category]}任务",20,7,1)
      text(b,263,244,330,28,"新的委托会记录在这里。",18,7,1)
    else
      top = [@selection[@category_index]-3, 0].max
      top = [top, [@ids.size-7,0].max].min
      @ids[top,7].each_with_index do |id, i|
        task = $game_party.tasks_info[id]
        y = 106+i*40
        if id == @selected_id
          b.fill_rect(61,y,147,37,Color.new(103,137,157,68))
          b.fill_rect(61,y,2,37,TaskJournal.color(6))
        end
        color = task.status == :active ? 0 : 8
        text(b,68,y,137,23,task.mark+task.title,16,color)
        text(b,70,y+20,135,17,task.status_label,12,color)
      end
      task = $game_party.tasks_info[@selected_id]
      text(b,255,78,347,31,task.mark+task.title,23,0)
      subtitle = [task.chapter,TaskJournal::LABELS[task.category],task.status_label].reject{|s|s==""}.join("  ·  ")
      text(b,255,111,347,25,subtitle,16,9)
      $game_party.latest_task = @selected_id
    end
    if @detail.bitmap
      @detail.bitmap.dispose
      @detail.bitmap = nil
    end
    @detail.bitmap = TaskText.render($game_party.tasks_info[@selected_id].briefing,356) if @selected_id
    @scroll = 0
    @detail.oy = 0
    draw_footer
  end

  def draw_footer
    b = @overlay.bitmap
    b.fill_rect(45,428,552,38,Color.new(0,0,0,205))
    hint = @detail_mode ? "↑↓阅读正文   确认／取消返回列表" : "←→切换分类   ↑↓选择   确认阅读   取消返回"
    text(b,50,429,540,24,hint,16,0,1)
    position = @ids.empty? ? "0 / 0" : "#{@selection[@category_index]+1} / #{@ids.size}"
    text(b,50,451,540,20,"#{position}    完成记录将保留在日志中",13,7,1)
  end

  def play(sound)
    $game_system.se_play(sound)
  end

  def update
    refresh_ui if @revision != $game_party.task_revision
    if Input.trigger?(Input::B)
      play($data_system.cancel_se)
      if @detail_mode
        @detail_mode = false
        draw_footer
      else
        $scene = @return_to_menu ? Scene_Menu.new(1) : Scene_Map.new
      end
      return
    end
    if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
      @category_index = (@category_index + (Input.trigger?(Input::RIGHT) ? 1 : -1)) % 3
      @detail_mode = false
      play($data_system.cursor_se)
      refresh_ui
      return
    end
    if Input.trigger?(Input::C)
      if @selected_id
        @detail_mode = !@detail_mode
        play($data_system.decision_se)
        draw_footer
      else
        play($data_system.buzzer_se)
      end
      return
    end
    direction = Input.repeat?(Input::DOWN) ? 1 : (Input.repeat?(Input::UP) ? -1 : 0)
    page = Input.trigger?(Input::R) ? 1 : (Input.trigger?(Input::L) ? -1 : 0)
    if @detail_mode && @detail.bitmap
      maximum = [@detail.bitmap.height-252,0].max
      @scroll = [[@scroll + direction*28 + page*224, 0].max, maximum].min
      @detail.oy = @scroll
    elsif !@ids.empty? && (direction != 0 || page != 0)
      index = @selection[@category_index]
      @selection[@category_index] = [[index+direction+page*7,0].max,@ids.size-1].min
      if index != @selection[@category_index]
        play($data_system.cursor_se)
        refresh_ui
      end
    end
  end

  def dispose_ui
    for sprite in [@detail,@overlay,@background]
      next if sprite == nil
      sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
      sprite.dispose unless sprite.disposed?
    end
    # RGSS1 的 Viewport 没有 disposed?；释放后清空引用以防重复释放。
    if @detail_viewport
      @detail_viewport.dispose
      @detail_viewport = nil
    end
  end
end

class Scene_Encyclopedia < Scene_Task
end

class Sprite_TaskNotice
  def initialize
    @sprite = Sprite.new
    @background = RPG::Cache.windowskin("task_back")
    @icon = RPG::Cache.icon("menu_task")
    @width = @background.width
    @hidden_x = 640
    @rest_x = @hidden_x - @width - 10
    @sprite.x = @hidden_x; @sprite.y = 18; @sprite.z = 8500
    @sprite.bitmap = Bitmap.new(@width, @background.height)
    draw_notice
    @sprite.visible = false
    @phase = :idle
    @phase_frame = 0
  end

  def update
    notice = $game_temp.task_journal_notice
    if notice
      $game_temp.task_journal_notice = nil
      task = $game_party.tasks_info[notice[0]]
      if task && task.visible && $game_party.current_tasks.include?(task.id)
        show
      end
    end
    case @phase
    when :entering
      @phase_frame += 1
      duration = TaskJournal::POPUP_SLIDE_FRAMES
      remaining = duration - @phase_frame
      # 二次缓出：刚进入时移动快，靠近落点时逐渐放慢。
      @sprite.x = @rest_x +
        (@hidden_x - @rest_x) * remaining * remaining / (duration * duration)
      if @phase_frame >= TaskJournal::POPUP_SLIDE_FRAMES
        @sprite.x = @rest_x
        @phase = :holding
        @phase_frame = 0
      end
    when :holding
      @phase_frame += 1
      if @phase_frame >= TaskJournal::POPUP_FRAMES
        @phase = :leaving
        @phase_frame = 0
      end
    when :leaving
      @phase_frame += 1
      duration = TaskJournal::POPUP_SLIDE_FRAMES
      # 二次缓入：起步慢，越接近屏幕右侧移动越快。
      @sprite.x = @rest_x +
        (@hidden_x - @rest_x) * @phase_frame * @phase_frame / (duration * duration)
      @sprite.opacity = 255 * (duration - @phase_frame) / duration
      if @phase_frame >= TaskJournal::POPUP_SLIDE_FRAMES
        @sprite.x = @hidden_x
        @sprite.visible = false
        @phase = :idle
      end
    end
  end

  def draw_notice
    b = @sprite.bitmap
    b.clear
    b.blt(0, 0, @background, @background.rect)
    b.blt(15, 20, @icon, @icon.rect)
    b.font.size = 20
    b.font.color = Color.new(0, 0, 0, 220)
    b.draw_text(48, 16, @width - 57, 32, "更新了任务日志")
    b.font.color = TaskJournal.color(0)
    b.draw_text(47, 15, @width - 57, 32, "更新了任务日志")
  end

  def show
    @sprite.x = @hidden_x
    @sprite.opacity = 255
    @sprite.visible = true
    @phase = :entering
    @phase_frame = 0
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end
end

class Scene_Map
  alias task_journal_map_main main
  def main
    $game_party.task_ensure
    @task_journal_notice = Sprite_TaskNotice.new
    begin
      task_journal_map_main
    ensure
      @task_journal_notice.dispose if @task_journal_notice
      @task_journal_notice = nil
    end
  end
  alias task_journal_map_update update
  def update
    task_journal_map_update
    @task_journal_notice.update if @task_journal_notice
  end
end
