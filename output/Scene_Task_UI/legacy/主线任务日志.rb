#==============================================================================
# 主线任务日志：接在原「★任务系统」之后、Main 之前。
# RGSS1 / Ruby 1.8。变量15负责推进；不修改地图事件或发放奖励。
# 每条资料为：[阶段值, 章节, 标题, 行动目标, 剧情说明]。
# 修改此文件后须同步到 Data/Scripts.rxdata 中的「主线任务日志」。
#==============================================================================
module LR_MainQuest
  VARIABLE_ID = 15
  ID_BASE = 1000
  END_VALUE = 180       # 调查阶段之后的追踪剧情不在本次补全范围内
  POPUP_FRAMES = 180
  MARKERS = {
    :main => ["○", "●"], :side => ["△", "▲"],
    :special => ["☆", "★"]
  }
  # 演出中也会多次变更变量；这些阶段照常归档，地图提示等演出结束。
  DATA = [
    [0, "序章", "出门看看", "离开雾雨魔法店，看看门外的情况。", "原本只是平常的一天，先从出门开始吧。"],
    [5, "序章", "突来的通缉", "应对堵在魔法店门口的红魔警察。", "一张满是荒唐罪名的拘捕令打乱了采蘑菇的计划。先保住自己的自由再说！"],
    [8, "序章", "人偶使援手", "与爱丽丝联手，击退红魔警司。", "爱丽丝赶到了现场；既然对方连旁观者也不放过，就一起打开出路。"],
    [9, "序章", "通缉令疑云", "与爱丽丝商量去哪里打听消息。", "警察暂时撤退了，通缉令背后的理由却还不清楚。逃跑之前，总得弄明白是谁在找麻烦。"],
    [10, "序章", "前往香霖堂", "穿过魔法森林，前往香霖堂。", "霖之助或许听说过雅罗的动静。出发前，也可以去爱丽丝家拿些补给。"],
    [15, "序章", "询问霖之助", "进入香霖堂，向霖之助询问通缉令的事。", "已经抵达店门口。红魔为何突然抓人，先听听消息灵通的店主怎么说。"],
    [20, "序章", "夜赴红魔", "离开香霖堂，沿魔法森林的路赶往雅罗边境。", "红魔馆加强了戒备。趁夜潜入，直接找蕾米莉亚问个清楚。"],
    [21, "序章", "失控的实验", "与爱丽丝击退被实验吸引来的妖怪。", "路遇的学者把森林搅得不太安宁。科学家的观察记录，看来还得靠魔法使护航。"],
    [22, "序章", "天界的学者", "确认学者的来历，结束这场意外的会面。", "妖怪已经被击退。对方似乎对魔理沙的魔力格外感兴趣，先听听她的解释。"],
    [25, "序章", "边境夜路", "继续前进，穿过雅罗与魔法森林的交界。", "梦美离开了，潜入红魔馆的计划还得继续。别让这段插曲拖到天亮。"],
    [30, "序章", "红魔馆门前", "与爱丽丝突破红美铃的阻拦。", "熟悉的偷书路线也不总是畅通无阻。今晚的门卫，偏偏没有睡着。"],
    [32, "序章", "警报响起", "跟随爱丽丝，避开红魔馆的警报与追兵。", "美铃已被击退，警报却响了起来。潜入计划得换一条路。"],
    [35, "序章", "地下水路", "沿地下水路寻找通往大图书馆的出口。", "魔理沙的秘密路线直达图书馆。希望这次的偷书经验能派上正经用场。"],
    [36, "序章", "机关与毒雾", "应对帕秋莉设下的机关，设法脱离困境。", "优雅的施法动作后面竟然是陷阱，水银之毒也开始生效。情况有些不妙。"],
    [40, "序章", "地牢醒来", "醒来后确认爱丽丝和自己的处境。", "潜入者反而被关进了地牢。先弄清情况，再找逃出去的办法。"],
    [41, "序章", "牢门的援手", "寻找离开地牢的办法，与来访的芙兰交谈。", "牢门带着反弹结界，强行攻击未必管用。意外的访客，也许能提供帮助。"],
    [45, "序章", "离开地牢", "与爱丽丝、芙兰离开地牢，前往大图书馆。", "芙兰打开了牢门，还坚持要一起去。现在该找帕秋莉和蕾米莉亚问个明白了。"],
    [46, "序章", "图书馆动静", "留意大图书馆内的动静。", "帕秋莉似乎早已料到有人会脱困。她与咲夜的准备，会影响接下来的会面。"],
    [47, "序章", "女仆的阻拦", "接近帕秋莉，突破咲夜的阻拦。", "图书馆并没有因为来客而安静下来。女仆长的速度，比预想中更加棘手。"],
    [48, "序章", "风符交锋", "稳住阵脚，与同伴会合。", "帕秋莉的风符打断了交锋。先确认同伴的情况，别在混乱中落单。"],
    [49, "序章", "图书馆交涉", "与芙兰一同应对图书馆的冲突，寻找见蕾米的机会。", "芙兰的出现让事情更加热闹。既然对方不肯好好谈，就先突破眼前的阻碍。"],
    [50, "序章", "前往谒见间", "通过传送前往谒见之间，与蕾米莉亚见面。", "这一次似乎真的是传送魔法。终于能问问那位大小姐，到底想做什么。"],
    [51, "序章", "谒见的冲突", "与爱丽丝一起面对蕾米莉亚。", "这场会面牵扯的不只是通缉令，还有爱丽丝未曾了结的旧事。"],
    [53, "序章", "命运的压迫", "在谒见之间稳住阵势，应对蕾米莉亚的行动。", "谈话已经无法平静继续。先与同伴站稳脚跟，再争取开口的机会。"],
    [54, "序章", "大小姐试探", "应对蕾米莉亚的交锋，听取她接下来的安排。", "红魔馆主人的实力不容小看。这场争执究竟是阻拦，还是另一种试探？"],
    [55, "序章", "私人会面", "前往蕾米莉亚的房间；离开谒见间后右拐，再左拐。", "她终于愿意谈正事。爱丽丝也决定同行，通缉令背后的理由该揭晓了。"],
    [60, "第一章", "等待来信", "在香霖堂休整，研究折扇并等候红魔馆的通知。", "蕾米提出寻找五件天仪，还透露父亲仍然活着。折扇中的秘密，也许与这趟旅程有关。"],
    [61, "第一章", "冥界的消息", "读完红魔馆送来的信，与同伴商量出发。", "第一件天仪的线索指向冥界。跨海之前，还需要到红魔馆商议具体安排。"],
    [65, "第一章", "再访红魔馆", "前往红魔馆的谒见之间，与蕾米莉亚商议出海。", "冥界之行已经决定。准备好补给，再听听这次委托还有哪些条件。"],
    [70, "第一章", "工坊与港口", "先去雅罗中区的机甲工坊，再到南部港口乘船。", "帕秋莉加入了队伍，并传授三人阵法。工坊靠近西区和住宅区，出海前先去一趟。"],
    [75, "第一章", "出海准备", "准备好装备与补给，开始前往冥界的航程。", "港口的安排已经谈妥。隔海相望的生死边界，可不是普通的观光目的地。"],
    [76, "第一章", "船上散步", "离开爱丽丝的船舱，到船上看看帕秋莉。", "爱丽丝打算休息。趁航程尚且平静，先与另一位同行者聊聊。"],
    [77, "第一章", "回舱休息", "返回船舱，与爱丽丝交谈。", "帕秋莉对那些离谱罪名的解释，实在让人难以满意。还是先回去休整吧。"],
    [78, "第一章", "航程小憩", "回到自己的房间，调查床铺休息。", "冥界之行还在前头，先养足精神。希望所谓红魔式外交，不会全靠打架。"],
    [80, "第一章", "海上突袭", "确认船外的袭击，与同伴会合。", "休息被突如其来的动静打断了。先查明发生了什么，保护这艘船。"],
    [81, "第一章", "弃船抉择", "与同伴寻找从海盗袭击中脱身的办法。", "诺亚方舟发动了攻击，船体已经严重损坏。人偶与术式能够争取的时间越来越少。"],
    [82, "第一章", "登上海盗船", "抓住同伴争取的空隙，转移到诺亚方舟。", "原船无法继续支撑。现在只能登上海盗船，争取活下来的机会。"],
    [83, "第一章", "爆炸之后", "站稳脚跟，继续寻找海盗船长。", "身后的爆炸让退路彻底消失。失去的人无法挽回，眼前的战斗却还没有结束。"],
    [85, "第一章", "夺取方舟", "穿过诺亚方舟，前往主控室击败船长。", "要继续横渡大海，就必须夺下这艘船。先突破海盗的防线。"],
    [90, "第一章", "继续航行", "乘坐夺下的诺亚方舟，继续前往冥界。", "海盗船长已经被击败。接下来是掌舵的问题……这艘船竟然没有导航。"],
    [95, "第一章", "万苍登陆", "从万苍港前往冥界入口，穿过边界。", "航程终于结束，妖梦也将前往白玉楼。把船留给小恶魔照看，继续赶路。"],
    [96, "第一章", "入口的骚灵", "与拦在冥界入口的骚灵交谈。", "刚到门口就遇上了新的访客。先听清对方的来意，别急着把人家叫成鬼。"],
    [97, "第一章", "特别入场费", "解决骚灵三姐妹的阻拦，打开前进的路。", "一场音乐会竟然附带高额收费。交涉不成，就只好用熟悉的方式解决了。"],
    [99, "第一章", "清静的入口", "整理队伍，继续穿过冥界入口。", "骚灵三姐妹已经让开道路。终于可以继续去白玉楼了。"],
    [100, "第一章", "白玉楼来客", "继续前往白玉楼，留意冥界的动向。", "入口的阻碍暂时解决了。与此同时，白玉楼也迎来了另一位客人。"],
    [102, "第一章", "隙间的来访", "留意八云紫与幽幽子的会面。", "有人先一步造访了白玉楼。她们的谈话，似乎与这片冥界的秘密有关。"],
    [105, "第一章", "庭前的暗影", "留意白玉楼庭前发生的动静。", "八云紫离开了幽幽子的房间，却似乎没有摆脱一路跟来的视线。"],
    [106, "第一章", "不速的追兵", "确认暗中追踪者的动向。", "白玉楼外的追踪浮出水面。八云紫的来访，看来并不是一场简单的叙旧。"],
    [107, "第一章", "试探的袭击", "留意八云紫如何应对来袭者。", "杂兵的试探没能拦住她，真正的追踪者却仍未罢休。"],
    [108, "第一章", "追逐未止", "留意庭前交锋的结果，等待局势明朗。", "对方似乎受人之托而来。这场追逐背后还有哪些目的，现在仍不清楚。"],
    [110, "第一章", "抵达白玉", "与同行者抵达白玉楼城区。", "一行人终于来到白玉。寻找金之天仪的旅程，才刚刚进入关键之处。"],
    [111, "第一章", "折扇的反应", "与同伴确认折扇的异常，安排落脚处。", "妖梦暂时告辞，折扇却开始发光。它是否正在回应某件天仪？"],
    [115, "第一章", "冥界宿屋", "寻找白玉楼城区的宿屋，住宿并研究折扇。", "帕秋莉建议先休息，再检查术式。至于酒店够不够四星级，还是以后再说吧。"],
    [120, "第一章", "向北寻访", "从宿屋出发，向北前往幽幽子的居所。", "折扇的反应随着前进变强，却仍无法解开。下一步是拜访白玉楼的主人。"],
    [122, "第一章", "九尾狐拦路", "应对入口处的拦路者，说明来意。", "通往幽幽子居所的道路又被挡住了。昨夜的追逐，似乎也延续到了这里。"],
    [123, "第一章", "再遇妖梦", "向妖梦说明求见幽幽子的目的。", "拦路者离开了，妖梦却仍对红魔来的客人有所戒备。坦诚交代这趟旅程吧。"],
    [125, "第一章", "庭师的引路", "与妖梦一起登上白玉楼的阶梯。", "妖梦同意最后再帮一次忙，也会监视一行人的举动。别辜负这次信任。"],
    [126, "第一章", "长阶尽头", "继续登阶，与妖梦一同迎接白玉楼的主人。", "已经接近幽幽子的居所。漫长的登阶之后，终于轮到正式会面了。"],
    [130, "第一章", "拜访幽幽子", "进入幽幽子的房间，询问金之天仪的下落。", "白玉楼的主人似乎已经知道一行人要来。希望这次能够少猜几句谜语。"],
    [135, "第一章", "饭前散步", "在白玉楼庭院走走，前往西行妖附近查看。", "幽幽子邀请大家留下用餐，暂时却没有交出天仪。先看看这座庭院里还有什么线索。"],
    [136, "第一章", "古树与庭师", "在西行妖旁与妖梦交谈。", "这棵古老的樱树引起了大家的注意。妖梦的过去，也许与天仪的线索有关。"],
    [140, "第一章", "白玉楼宴席", "返回幽幽子的房间，与大家一起用餐。", "妖梦带来了开饭的消息。有关天仪与妖忌的疑问，留到席间继续询问。"],
    [145, "第一章", "幽幽子试炼", "在西行妖前与妖梦联手，接受幽幽子的试炼。", "想取得天仪，先证明这支队伍的实力。至少这次不用再走一个大迷宫了。"],
    [150, "第一章", "庭师的旅程", "带上妖梦，离开白玉楼，返回现世。", "妖忌留下的剑就是金之天仪，但妖梦尚不能拔出它。她需要在旅途中继续成长。"],
    [155, "第二章", "雅罗的夜晚", "结束冥界之行，留意雅罗正在发生的事。", "帕秋莉会向红魔馆汇报。看似可以回家的夜晚，却在别处发生了变故。"],
    [156, "第二章", "巷中的惨案", "留意雅罗小巷中的事件。", "修女与孩子遭到了陌生人的袭击。这场惨案，正悄悄改变城市的气氛。"],
    [160, "第二章", "红魔的动向", "留意红魔馆对雅罗局势的反应。", "凶案之后，城市中的不安尚未散去。红魔馆接到的消息，也将影响接下来的行动。"],
    [161, "第二章", "广场的风波", "留意港区游行与红魔馆的应对。", "真丽斯教徒聚集抗议，广场上的情绪越来越激动。咲夜被派去处理现场。"],
    [165, "第二章", "接受调查", "前往红魔警署二楼，与四季映姬、小町商议查案。", "一行人被卷入凶案调查。先听清案情，再决定从哪些线索入手。"],
    [170, "第二章", "三路取证", "调查案发现场、询问目击者，并查阅警署档案。", "现场位于雅罗东部，目击者可从大教堂一带问起。第一次与警察合作，先把线索记全。"],
    [171, "第二章", "核对案情", "核对现场痕迹、尸检意见与第一目击者的证词。", "发现尸体的地点，未必就是真正的行凶地点。把时间与路线放在一起，寻找不合之处。"],
    [175, "第二章", "追查搬运", "检查雅罗东部附近的可疑地点，继续补齐证词与档案。", "现场不是第一案发地点。凶手怎样搬运尸体，为什么拖拽痕迹只出现了一段？"]
  ]

  def self.entry(value)
    return nil if value < 0 || value >= END_VALUE
    row = DATA[0]
    for candidate in DATA
      row = candidate if candidate[0] <= value
    end
    # 目击者对话通过“变量15 += 1”记下线索；每个值也单独留档。
    if value >= 172 && value != 175
      return [value, "第二章", "调查新记录", "继续走访目击者，核对警署档案与现场痕迹。",
        "已经记下新的调查进展。将证词中的巡街时间与路线同现场情况对照，继续寻找搬运尸体的线索。"]
    end
    return [value, row[1], row[2], row[3], row[4]]
  end

  def self.marker(kind, done)
    pair = MARKERS[kind] || MARKERS[:side]
    return pair[done ? 1 : 0]
  end
end

class Game_Encyc
  attr_accessor :lr_quest_kind, :lr_quest_done, :lr_quest_title

  def lr_mark(kind, done)
    if @lr_quest_title == nil
      @lr_quest_title = @name.gsub(/\\[Cc]\[[0-9]+\]/, "")
      for pair in LR_MainQuest::MARKERS.values
        for mark in pair
          if @lr_quest_title.index(mark) == 0
            @lr_quest_title = @lr_quest_title[mark.length..-1]
          end
        end
      end
    end
    @lr_quest_kind = kind
    @lr_quest_done = done
    color = done ? 8 : (kind == :main ? 9 : 0)
    @name = "\\c[#{color}]" + LR_MainQuest.marker(kind, done) + @lr_quest_title
  end
end

class Game_Temp
  attr_accessor :lr_quest_notice
end

class Game_Party
  alias lr_quest_original_catalog get_encyc_info

  def get_encyc_info
    @lr_other_quest_states ||= {}
    lr_quest_original_catalog
    for id in 2..6
      @encyc_info[id] = nil
    end
    # 保留已有支线文字，只统一其标记；本次不新增支线剧情。
    @encyc_info.each_with_index do |task, id|
      next if task == nil
      state = @lr_other_quest_states[id] || [:side, false]
      task.lr_mark(state[0], state[1])
    end
    lr_sync_main_quest($game_variables[LR_MainQuest::VARIABLE_ID], false)
    lr_refresh_main_catalog
    return @encyc_info
  end

  def lr_sync_main_quest(value, notify = false)
    return unless value.is_a?(Numeric)
    value = value.to_i
    if @lr_main_history == nil
      # 旧存档无法还原逐条触发历史；按当前变量补齐已越过的阶段。
      @lr_main_history = []
      for row in LR_MainQuest::DATA
        @lr_main_history.unshift(row[0]) if row[0] <= value
      end
      @lr_main_current = LR_MainQuest.entry(value) ? value : nil
      if @lr_main_current && !@lr_main_history.include?(value)
        @lr_main_history.unshift(value)
      end
      @lr_main_last_value = value
    elsif @lr_main_last_value != value
      previous = @lr_main_current
      @lr_main_last_value = value
      @lr_main_current = LR_MainQuest.entry(value) ? value : nil
      if @lr_main_current
        @lr_main_history.delete(value)
        @lr_main_history.unshift(value)
      end
      @latest_encyc = @lr_main_current ? LR_MainQuest::ID_BASE + value : nil
      if notify && $game_temp != nil && (previous != nil || @lr_main_current != nil)
        $game_temp.lr_quest_notice = [previous, @lr_main_current]
      end
    end
    lr_refresh_main_catalog if @encyc_info != nil
  end

  def lr_refresh_main_catalog
    return if @lr_main_history == nil || @encyc_info == nil
    @current_encyc ||= []
    other_ids = @current_encyc.reject do |id|
      (id >= 2 && id <= 6) || (id >= LR_MainQuest::ID_BASE && id < LR_MainQuest::ID_BASE + LR_MainQuest::END_VALUE)
    end
    main_ids = []
    for value in @lr_main_history
      row = LR_MainQuest.entry(value)
      next if row == nil
      id = LR_MainQuest::ID_BASE + value
      done = value != @lr_main_current
      task = @encyc_info[id]
      if task == nil
        task = Game_Encyc.new(row[2], "")
        @encyc_info[id] = task
      end
      task.lr_quest_title = row[2]
      task.lr_mark(:main, done)
      status = done ? "已完成" : "进行中"
      task.briefing = "\\c[9]#{row[1]} · 主线\\c[0]\n" +
        "#{LR_MainQuest.marker(:main, done)}#{row[2]}　#{status}\n\n" +
        "\\c[6]行动目标\\c[0]\n#{row[3]}\n\n#{row[4]}"
      main_ids.push(id)
    end
    @current_encyc = main_ids + other_ids.select { |id| @encyc_info[id] != nil }
  end

  # 返回真实数组，兼容原事件的 unshift / clear 等调用。
  def current_encyc
    get_encyc_info if @encyc_info == nil
    lr_sync_main_quest($game_variables[LR_MainQuest::VARIABLE_ID], false)
    return @current_encyc
  end

  def lr_set_other_quest_state(id, kind, done)
    @lr_other_quest_states ||= {}
    @lr_other_quest_states[id] = [kind, done]
    @encyc_info[id].lr_mark(kind, done) if @encyc_info && @encyc_info[id]
  end

  def lr_finish_current_main
    @lr_main_current = nil
    lr_refresh_main_catalog
  end
end

class Game_Variables
  alias lr_quest_original_variable_set []=
  def []=(id, value)
    previous = self[id]
    if id == LR_MainQuest::VARIABLE_ID && $game_party != nil && previous != value
      $game_party.lr_sync_main_quest(previous, false)
    end
    lr_quest_original_variable_set(id, value)
    if id == LR_MainQuest::VARIABLE_ID && $game_party != nil && previous != self[id]
      $game_party.lr_sync_main_quest(self[id], true)
    end
  end
end

class Interpreter
  def get_encyc(id, kind = :side)
    # 原序章事件仍调用 get_encyc(2)，主线现在统一由变量15自动管理。
    if id >= 2 && id <= 6
      $game_party.current_encyc
      return true
    end
    task = $game_party.encyc_info[id]
    return true if task == nil
    list = $game_party.current_encyc
    return true if list.include?(id)
    $game_party.lr_set_other_quest_state(id, kind, false)
    list.push(id) unless list.include?(id)
    return true
  end

  def finish_encyc(id)
    task = $game_party.encyc_info[id]
    return true if task == nil
    $game_party.lr_set_other_quest_state(id, task.lr_quest_kind || :side, true)
    # 保留已完成任务，供玩家回看；主线是否完成仍以变量15为准。
    list = $game_party.current_encyc
    list.push(id) unless list.include?(id)
    return true
  end

  def finish_all_encyc
    for id in $game_party.current_encyc
      task = $game_party.encyc_info[id]
      if task && task.lr_quest_kind != :main
        $game_party.lr_set_other_quest_state(id, task.lr_quest_kind || :side, true)
      end
    end
    $game_party.lr_finish_current_main
    return true
  end
end

class Window_Encyc
  # 原窗口每次切换任务会重新分配位图，先释放旧位图。
  def refresh(encyc_id)
    self.oy = 0
    self.visible = true
    old_contents = self.contents
    old_contents.dispose if old_contents && !old_contents.disposed?
    task = encyc_id ? $game_party.encyc_info[encyc_id] : nil
    self.contents = Bitmap.new(self.width - 32, task ? task.height : self.height - 32)
    self.contents.font.color = normal_color
    draw_encyc_info(task) if task
  end
end

class Scene_Encyclopedia
  alias lr_quest_original_log_update update
  def update
    lr_quest_original_log_update
    task = @encyc_names_window.encyc
    id = task ? task.id : nil
    if @lr_viewed_quest != id
      @lr_viewed_quest = id
      @encyc_info_window.refresh(id)
      $game_party.latest_encyc = id
    end
  end
end

# 地图右上角的任务更新卡片。不播放音效、不占用对话窗口。
class LR_QuestNotice
  def initialize
    @sprite = Sprite.new
    @sprite.x = 292
    @sprite.y = 20
    @sprite.z = 8500
    @sprite.bitmap = Bitmap.new(328, 118)
    @sprite.visible = false
    @frames = 0
    @disposed = false
  end

  def blocked?
    return true if !$scene.is_a?(Scene_Map) || $game_temp == nil
    return true if $game_temp.message_window_showing || $game_temp.player_transferring
    return true if $game_system.map_interpreter.running?
    # 与已有的场景标题演出错开。
    display = $scene.scene_name_display if $scene.respond_to?(:scene_name_display)
    return true if display && display.remaining_frames > 0
    return false
  end

  def show_notice(notice)
    previous, current = notice
    row = current ? LR_MainQuest.entry(current) : nil
    b = @sprite.bitmap
    b.clear
    b.fill_rect(0, 0, 328, 118, Color.new(12, 19, 30, 225))
    b.fill_rect(0, 0, 3, 118, Color.new(145, 222, 169, 255))
    b.font.size = 18
    b.font.color = Color.new(145, 222, 169)
    b.draw_text(14, 4, 300, 24, row ? "主线任务更新" : "主线调查告一段落")
    b.font.size = 22
    b.font.color = Color.new(255, 255, 255)
    title = row ? "○" + row[2] : "●调查记录已保存"
    b.draw_text(14, 28, 300, 28, title)
    b.font.size = 16
    goal = row ? row[3] : "可以在任务日志中回顾已完成的主线。"
    # 使用 UTF-8 码点拆行，兼容 RGSS1，不从中文字节中截断。
    lines = [""]
    for codepoint in goal.unpack("U*")
      char = [codepoint].pack("U")
      lines.push("") if b.text_size(lines[-1] + char).width > 296
      lines[-1] += char
    end
    lines[0, 2].each_with_index { |line, i| b.draw_text(14, 60 + i * 22, 300, 22, line) }
    @frames = LR_MainQuest::POPUP_FRAMES
    @sprite.opacity = 255
    @sprite.visible = true
  end

  def update
    return if @disposed
    if blocked?
      @sprite.visible = false
      return
    end
    notice = $game_temp.lr_quest_notice
    if notice
      $game_temp.lr_quest_notice = nil
      show_notice(notice)
    end
    return if @frames <= 0
    @sprite.visible = true
    @frames -= 1
    @sprite.opacity = [255, @frames * 16].min
    @sprite.visible = false if @frames <= 0
  end

  def dispose
    return if @disposed
    @sprite.bitmap.dispose
    @sprite.dispose
    @disposed = true
  end
end

class Scene_Map
  alias lr_quest_original_map_main main
  def main
    $game_party.current_encyc
    @lr_quest_notice = LR_QuestNotice.new
    begin
      lr_quest_original_map_main
    ensure
      @lr_quest_notice.dispose if @lr_quest_notice
      @lr_quest_notice = nil
    end
  end

  alias lr_quest_original_map_update update
  def update
    lr_quest_original_map_update
    @lr_quest_notice.update if @lr_quest_notice
  end
end
