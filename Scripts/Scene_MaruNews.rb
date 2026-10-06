#==============================================================================
# 文文新闻阅读器 / RPG Maker XP / RGSS1（Ruby 1.8）
# 事件脚本：MaruNews(1)、MaruNews(2)……；合上后继续原事件。
# PgUp 上一页；PgDn 下一页；最后一页再按 PgDn 合上；X 随时合上。
# 每篇报道独立起页，首页预留照片，长正文自动续页；每次从头阅读。
#==============================================================================
module MaruNewsReader
  #--------------------------------------------------------------------------
  # 一、可编辑设置。坐标均以 640×480 画面左上角为原点。
  #--------------------------------------------------------------------------
  BACKGROUND_NAME = "文文新闻"       # Graphics/Windowskins 下，不写扩展名
  TITLE_FONT_NAMES = ["华文中宋", "宋体", "SimSun"]
  BODY_FONT_NAMES = ["宋体", "SimSun", "Arial"]
  TITLE_FONT_SIZE = 32
  MIN_TITLE_SIZE = 18               # 标题过长时逐级缩小，防止超出黑框
  BODY_FONT_SIZE = 22
  LINE_HEIGHT = 26
  PARAGRAPH_GAP = 6                 # 空行的间隔，不占完整一行
  FOOTER_FONT_SIZE = 15

  TITLE_RECT = [40, 42, 492, 44]    # 顶部黑框内的白色标题
  BODY_RECT = [40, 112, 492, 318]   # 正文边界，底部留页码
  FOOTER_RECT = [40, 434, 492, 18]

  PHOTO_RECT = [224, 112, 308, 186] # 按参考图放在正文右上方
  PHOTO_GAP = 10                   # 文字与照片之间的距离
  PHOTO_ALLOW_UPSCALE = true       # true：小图也按比例放大；不会拉伸变形
  SHOW_EMPTY_PHOTO_FRAME = false   # 无图时保持空白；调排版可暂改成 true

  OPEN_SE = "047-Book02"
  TURN_SE = "046-Book01"
  CLOSE_SE = "047-Book02"
  SE_VOLUME = 80
  SE_PITCH = 100
  OPEN_TRANSITION_FRAMES = 12
  PAGE_TRANSITION_FRAMES = 6
  CLOSE_TRANSITION_FRAMES = 10
  # 空字符串使用原生淡入；也可填写 Graphics/Transitions 内素材名。
  TRANSITION_NAME = ""

  #--------------------------------------------------------------------------
  # 二、新闻资料区。每期一个编号，每篇一个资料块。
  # :title 标题；:column 栏目；:photo 图片名；:reserve_photo 是否预留照片。
  # 图片放 Graphics/Pictures，例：:photo => "MaruNews/港口照片"。
  # :photo 为 nil 仍留版位；不想留位，将该篇 :reserve_photo 改成 false。
  # :body 的正文写在 NEWS_TEXT 与下方 NEWS_TEXT 之间，保留普通换行。
  # 下面的六期正文由同目录新闻初稿整理，运行时不依赖外部 TXT。
  #--------------------------------------------------------------------------
  NEWS = {
    # 第一号：事件中输入 MaruNews(1)
    1 => {
      :name => "文々。新闻 第一号",
      :articles => [
        # 报道 1 · 雅罗快讯
        {
          :title => "通缉风波未平，魔法使再现红魔馆",
          :column => "雅罗快讯",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
近日在雅罗引起骚动的魔法使雾雨魔理沙，又被目击出现在红魔馆附近。

此前，她因一份通缉令遭士兵追捕。究竟涉及何种罪名，相关人员未向本报作出明确说明。如今目击者称，看守并未立即采取行动。

一位沿街摊主提出了非常实际的问题：“那张画像到底还贴不贴？我后面还有一张招工的。”

本报曾尝试向红魔馆求证。接待人员十分礼貌地表示，目前没有可以提供的消息，并十分礼貌地关上了门。

看来，能否进门与是否得到答案，是两回事。本报将继续追踪。
NEWS_TEXT
        },
        # 报道 2 · 海路见闻
        {
          :title => "前往白玉楼，船票之外还须准备什么？",
          :column => "海路见闻",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
不周之海连接着生者与冥界，也让不少第一次远行的旅客头疼。

“有人以为到了对岸，举着红魔的旗子就有人来接。”一名老船员告诉本报，“我只负责把船开过去，不负责替他解释那面旗子。”

红魔与白玉楼之间的关系，使航行多了一层微妙的顾虑。对于只想做生意的船主，客人背后的国家有时比客人的行李还沉。

船员提醒，穿越结界时不要擅自离开甲板，也不要把远处的幽灵当作引航员。

本报记者曾询问何种准备最重要。对方想了想，回答：“先想清楚，你是去拜访，还是去吵架。”
NEWS_TEXT
        },
        # 报道 3 · 饮食小报
        {
          :title => "白玉楼厨房告急？新鲜食材需求不断",
          :column => "饮食小报",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
近来，一些往返冥界的商人提起，白玉楼对新鲜食材的需求似乎又增加了。

一名供货商表示，送得多并不一定意味着做得好；一道菜会不会被留下，要看主人当时的心情。记者追问是否有稳定受欢迎的菜式，对方沉默片刻，表示下次再来时也许就换了。

关于当地是否准备举行宴会，本报尚未取得答复。

倒是一位厨师托商人带来口信：若有人知道少见食材的去处，请告知白玉楼；只听说过名字，却让人去海上碰运气的情报，就不必再送来了。

本报祝各位厨师平安。
NEWS_TEXT
        },
        # 报道 4 · 广告与编后记
        {
          :title => "香霖堂启事：本店仍在营业",
          :column => "广告与编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
【商店启事】
香霖堂收购、出售各类道具，欢迎到店咨询。
借走的书请归还。翻阅前请先问价。店内座位供商谈交易使用，恕不提供无限续坐服务。

店主特别要求本报保留最后一句，理由是：“有些人不写清楚就当没看见，写清楚了也可能当没看见。”

【射命丸文·编后记】
啊呀呀呀，新一期终于送到各位手上了！
为取得消息，本报记者走访了码头、街道和一扇不愿打开的门。采访对象均保持了相当鲜明的个人态度。

欢迎来信，也欢迎提供独家消息。若您只打算寄来“这也算新闻？”，请至少说明您知道什么更有趣的事。
NEWS_TEXT
        },
      ]
    },

    # 第二号：事件中输入 MaruNews(2)
    2 => {
      :name => "文々。新闻 第二号",
      :articles => [
        # 报道 1 · 山中急报
        {
          :title => "板门哨岗爆炸，诹访宣布进入战争状态",
          :column => "山中急报",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
板门哨岗发生炸弹袭击后，诹访方面宣布进入战争状态，边境通行受到严格限制。

据诹访发布的通告，袭击与神奈间谍有关，一名相关嫌疑人已被控制。神奈方面截至本期付印时，尚未作出本报能够核实的正式回应。

爆炸的具体经过、嫌疑人与现场之间的联系，以及守军当时的行动，仍有待进一步采访。

目前，各报社收到的说明多来自同一份通告，前往现场采访则受到戒严限制。

本报提醒旅客，山中定期航路和边境道路均可能临时关闭。出发前请确认通行情况，不要仅凭一张旧船票前往。
NEWS_TEXT
        },
        # 报道 2 · 雅罗续报
        {
          :title => "母女遇害案公布嫌犯，家属与教徒仍求解释",
          :column => "雅罗续报",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
真丽斯母女遇害案引发的抗议尚未完全平息。此前，八幡大法师出面协调，要求警方给予透明、可信的交代。

警方现已公布嫌疑人犍陀多。追捕中，他坠入地下，未被带回；警方据追捕情况作出死亡判断，但未向本报提供完整遗体的核验说明。

一些教徒仍在询问：案发经过能否公开？此前对真丽斯居民安全与待遇的诉求，是否也将得到回应？

嫌疑人的身份，是调查的一部分。许多居民还在等待，自己下一次走出教堂时能否安心回家。

本报将继续关注案情公布与相关答复。
NEWS_TEXT
        },
        # 报道 3 · 背景读本
        {
          :title => "同一座山，为何分成诹访与神奈？",
          :column => "背景读本",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
妖怪之山西部的诹访，倚重传统信仰、农业与天狗军力；东部神奈则发展矿业、机械与河童技术。

历史战争与信仰竞争，形成了今天的分界。天狗在诹访取得较高地位，一些鬼、山姥及其他妖怪转往神奈，或离开了山中。

本报记者曾询问双方商人，是否准备彻底停止往来。一位诹访工匠先问神奈的零件还送不送；一位神奈商人则惦记着西边尚未到货的粮食。

看来，两国的关系并不能只用地图上那条线说明。

至于战争将怎样影响这些交易，眼下没人愿意给出一个确定的日期。
NEWS_TEXT
        },
        # 报道 4 · 街头采访与编后记
        {
          :title => "边境封锁后，柜台前最常被问的事",
          :column => "街头采访与编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
本报记者在几处店铺听见了相似的问话：“什么时候到货？”

粮商说车还在路上，工匠说零件还在对面。一名信使捏着几封迟迟送不出的家书，表示他最怕别人问：“你不是会飞吗？”

戒严限制着飞行，翅膀并不能替他换来通行许可。

【射命丸文·编后记】
战时通告来得很快，现场的回答却仍在路上。
本报记者准备前往山中，继续追查爆炸与边境的情况。

若有人坚持本报现在就把所有细节写齐，烦请先把现场打开。至少，别要求记者隔着封锁线，替每一个没见过的人作证。
NEWS_TEXT
        },
      ]
    },

    # 第三号：事件中输入 MaruNews(3)
    3 => {
      :name => "文々。新闻 第三号",
      :articles => [
        # 报道 1 · 红魔观察
        {
          :title => "辉守局势紧张，红魔调动军力",
          :column => "红魔观察",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
辉守地区的骚动持续扩大，小人族与红魔方面的矛盾再度成为街头议论的焦点。

红魔已向相关地区调动军力。各地商人关注的，是接下来的道路是否关闭、货物能否通过，以及自己的店铺是否会成为双方临时停留的地方。

关于骚动者的具体要求与内部情况，传闻众多，公开说明仍然有限。本报尚未取得足以交叉核实的完整记录。

与此同时，港口旅客担心陆上的紧张局势会影响远航。码头人员表示，航次变化仍须以当日安排为准。

已经离开泊位的船，大概是眼下最难追回来听通知的读者。
NEWS_TEXT
        },
        # 报道 2 · 航海专栏
        {
          :title => "宇见大三角：老船员不愿省下的那段路",
          :column => "航海专栏",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
谈到宇见大三角，不同船长能说出不同的故事。有人提起突然变强的浪涛，有人提起在附近出没的妖怪，也有人坚称，那里有些潮水与自己记熟的海路完全对不上。

近来，关于海况异常的消息再次增多。对此，老船员的意见倒很一致：该绕的路不要省。

本报记者问，若旅客嫌航程太长，该怎样解释？

对方把海图推了过来：“你也可以让他给你选一条。出了事再问他认不认那条线。”

本报建议出航前听取船员安排。漂亮的海景，通常不会回答返航路线的问题。
NEWS_TEXT
        },
        # 报道 3 · 生活见闻
        {
          :title => "竹林药屋的传闻，为什么总能传出竹林？",
          :column => "生活见闻",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
不少旅人听说，迷途竹林中藏着一处医术高明的药屋。问起准确位置时，得到的指路却经常互相矛盾。

一名收到过兔子送药的居民告诉本报，药确实有效；至于对方从哪里走来，他还没问完，送药人便离开了。

也有旅人声称自己曾经找到了屋门。记者请他画下路线，他画到第三片竹林时，表示此前可能少记了一次转弯。

本报暂不刊登这份地图。

若您需要看病，请向可靠的当地人询问，勿把“有人去过”当成“自己能找到”。尤其不要病着去证明方向感。
NEWS_TEXT
        },
        # 报道 4 · 读者来信与编后记
        {
          :title => "龙宫来信：城里也有城里的烦恼",
          :column => "读者来信与编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
一封自称来自龙宫的来信，谈起了海底生活。

写信者说，旅客常先问宫殿、宴会与宝物；真正长住的人还要关心灯是否准时点亮、岸上的货多久能送到、申请究竟该交给哪位吏员。

信末写道：“若本报有机会前来，请先问清楚海关需要几份说明。我们这里负责回答这个问题的人，也可能需要您先交一份说明。”

【射命丸文·编后记】
啊呀呀呀，这可比‘海底只有珠宝’的传闻有趣多了。

本报记者尚未核实来信的全部内容。不过，若有人愿意替采访者准备住宿，报道的机会当然会大一些。只包宴会、不包返程的邀请，还请写清楚。
NEWS_TEXT
        },
      ]
    },

    # 第四号：事件中输入 MaruNews(4)
    4 => {
      :name => "文々。新闻 第四号",
      :articles => [
        # 报道 1 · 异变追踪
        {
          :title => "多地出现怨灵，来源与异常热力待查",
          :column => "异变追踪",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
魔法森林、雅罗郊外及边境旧矿井附近，陆续传出怨灵活动的消息。目击者除描述灵体外，还提到了异常热力与受损地面。

有关调查仍在进行，怨灵的来源尚未公布。部分居民把事件与山中局势联系起来，但目前传出的说法并没有提供足够依据。

本报提醒，发现灵体或异常地面后，请尽快离开现场，不要自行追入废矿，也不要拾取仍然发热的碎石作为纪念。

一名目击者告诉本报：“最开始我以为是有人在练魔法，直到那东西转头看我。”

希望更多消息能够在更多人受伤之前得到确认。
NEWS_TEXT
        },
        # 报道 2 · 旧闻重读
        {
          :title => "地下条约：被关闭的往来，仍留下什么？",
          :column => "旧闻重读",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
地下都市曾在红魔扩张中受到殖民统治。反抗与战争之后，红魔未能重新控制当地，双方以条约限制地上、地下妖怪的往来。

在地上居民的传闻里，地下常只剩下“危险”二字。但旧商路、家族关系与曾经在两边生活的人，并不会随条约一同消失。

一名受访者向本报提起，自己年轻时认识的地下居民，会先询问客人带了什么消息，后来才改问客人为什么要来。

条约没有明确限制人类，这一细节近来又被谈起。但能找到字面上的空隙，并不意味着对面愿意开门。
NEWS_TEXT
        },
        # 报道 3 · 民生短报
        {
          :title => "怨灵来袭后，药铺与工匠忙碌起来",
          :column => "民生短报",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
受损门窗需要修补，轻伤者需要治疗，一些住户暂时不敢回到原来的房间。突如其来的异变，让药铺和工匠都忙了起来。

一位卖药者说，他近来最常听见的是：“有没有能让人什么都不怕的药？”他只能先询问对方哪里受了伤。

还有居民问，前往妖怪之山购置物资是否安全。本期尚未核实各条道路的最新通行情况，请勿仅凭此前的消息决定行程。

本报欢迎提供受损地区的实际需求。若您只知道‘肯定有人已经去解决了’，暂时还不能替隔壁那位住户补上窗户。
NEWS_TEXT
        },
        # 报道 4 · 编后记
        {
          :title => "那句“地下都是怪物”，究竟是谁说的？",
          :column => "编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
本报记者在采访中多次听见这句话。

有人说是长辈告诉自己的，有人说是旧告示上写的。问起是否亲自见过地下居民，回答却少了许多。

眼下的怨灵确实伤了人，损坏了住处，必须查明来源并尽快处理。但仅凭“来自地下”，还不足以解释它们为何突然出现，又为何带着如此异常的力量。

本报记者打算继续寻找能够回答这些问题的人。

啊呀呀呀，也有人建议我直接下去问。这个提议，本报已经认真记下了。若提议者能够提供可靠的出入口和返程方法，请继续来信，别只把勇气寄给记者。
NEWS_TEXT
        },
      ]
    },

    # 第五号：事件中输入 MaruNews(5)
    5 => {
      :name => "文々。新闻 第五号",
      :articles => [
        # 报道 1 · 海道快讯
        {
          :title => "特急列车遭炮击，八幡大法师出手救援",
          :column => "海道快讯",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
前往荆凑的特急列车遭战车袭击，被迫在梅威海道附近停下。袭击者使用大威力火炮，车上旅客一度面临危险。

八幡大法师随后赶到，阻挡炮击并协助救援，袭击者离开现场。

据现场伤情统计，十一名乘客轻伤，一名列车员手臂骨折，未发生乘客死亡。救援与交通恢复仍需安排。

一位受访乘客说，刚才还在埋怨车为什么停下，如今只想知道同行的人有没有都下来。

本报将继续追踪袭击者身份与事故处理。已购票旅客请向车站确认后续安排，不要自行沿铁轨赶路。
NEWS_TEXT
        },
        # 报道 2 · 荆凑见闻
        {
          :title => "一条街上的人类与妖怪，近来为何彼此提防？",
          :column => "荆凑见闻",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
荆凑街头，人类与妖怪做生意并非新鲜事。有人卖材料，有人修工具，也有人只记得对方每次来都会讨价还价。

最近的伤人事件却改变了这样的日常。一些商铺提早关门，旧矿道与山路上的传闻越传越多，原本熟悉的客人也开始受到盘问。

一位店主告诉本报，自己不愿把所有妖怪都赶走，但也无法让受过伤的伙计只凭一句保证重新开门。

事件的具体原因仍待调查。若把每一次伤害都叫作‘误会’，受伤的人不会接受；若把每个妖怪都当作嫌犯，许多旧生意也将做不下去。
NEWS_TEXT
        },
        # 报道 3 · 城中采访
        {
          :title => "自卫队巡逻，慧音呼吁先保护居民",
          :column => "城中采访",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
荆凑自卫队加强巡逻，慧音参与组织安置与保护工作。学校附近也有家长询问，孩子放学后该走哪条路。

一名巡逻者说，最麻烦的情形未必是发现袭击者，而是听见有人喊了一声，其他人便提着东西追出去，却没有谁说明究竟看见了什么。

居民希望查明妖怪伤人的原因，也担心混乱中有人借机伤及无辜。

本报提醒，发现异常时请尽量记下地点、时间与目击经过。准确的说明，能够帮助调查者找到人；一声‘有妖怪’，往往只会让整条街一起跑起来。
NEWS_TEXT
        },
        # 报道 4 · 信仰生活与编后记
        {
          :title => "莲华寺与博丽神社，都在等待来访者",
          :column => "信仰生活与编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
莲华寺近来接待求助者与受伤居民。寺中的响子忙于迎客，劝来访者进屋坐下时，也努力压低了嗓门。

另一边，一位到过博丽神社的读者提醒本报，若要请巫女处理麻烦，最好把事情说清楚，也别忘了看看门口的赛钱箱。

他随后补充：“她说随意。我不太确定她看到空箱子时，还觉得不觉得随意。”

【射命丸文·编后记】
信仰的争论很大，眼前的需要倒很具体：有人缺药，有人找不到家人，有人等着回家的路重新打开。

各位若知道能够得到帮助的地方，欢迎告诉本报。至于两边谁的茶更好喝，记者会另择时间认真比较。
NEWS_TEXT
        },
      ]
    },

    # 第六号：事件中输入 MaruNews(6)
    6 => {
      :name => "文々。新闻 第六号",
      :articles => [
        # 报道 1 · 日出消息
        {
          :title => "红魔使节抵达日出，会谈内容尚未公开",
          :column => "日出消息",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
红魔使节已抵达日出，获苏我摄政方面接待。双方会谈的详细内容尚未向本报公开。

一些商人希望新的交涉能减少往来中的阻碍；也有人担心，朝廷谈妥的事情最后仍要由沿街店铺承担费用。

本报记者向接待人员询问会谈安排，对方表示双方交流顺利。记者继续询问讨论了哪些事项，得到的答复仍然是：双方交流顺利。

目前能够确认的是，使团已入宫，相关接待正在进行。至于交流究竟将改变什么，本报会在取得可核实的消息后继续报道。

宫门外等待答复的时间，看来也属于外交的一部分。
NEWS_TEXT
        },
        # 报道 2 · 故国旧闻
        {
          :title => "日出之变以后，街上留下了哪些故事？",
          :column => "故国旧闻",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
日出之变结束了旧朝的权力格局。神子败亡，物部家受到重创，苏我家逐渐掌握摄政权。

如今谈起那场变故，不同人仍会从不同地方说起：有人记得宫中的诏令，有人记得被关闭的寺门，也有人只记得那一晚没能回家的亲人。

朝廷的记录能够说明谁在何时接掌了职位，却未必能回答每一个逃难者后来去了哪里。

在寺院与旧街附近，一些老人仍保留着当年的物件。本报曾询问为何没有丢弃。一位老人将东西收好，只说：“这不是给后来当官的人看的。”

这篇旧闻，本报还没有问完。
NEWS_TEXT
        },
        # 报道 3 · 奈良街谈
        {
          :title => "旧店换了招牌，旧客还会回来吗？",
          :column => "奈良街谈",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
日出的街道上，不少旧铺面已经换了主人。有的改卖新货，有的成了当铺，柜台后留下的却还是多年以前的抽屉。

一位店主告诉本报，接手店铺时曾收出几份旧账与书信。如今再看，许多名字都联系不上了。

记者问，既然如此，为何还保存着？对方表示，万一有人回来，至少能让他知道这家店后来变成了什么。

当然，也有店主只想提醒旧客：往年的欠账，不会因为招牌换了就自动消失。

本报建议返乡旅客先认清门口的字，再急着往屋里走。里面可能有人欢迎，也可能有人已经准备好了算盘。
NEWS_TEXT
        },
        # 报道 4 · 编后记
        {
          :title => "这次采访，陪同的人比回答的人还多",
          :column => "编后记",
          :photo => nil,             # 填图片名，例如 "MaruNews/港口照片"
          :reserve_photo => true,    # 首页留照片区；false 可取消
          :body => <<'NEWS_TEXT'
进入宫廷采访，与街头采访颇有不同。

问题尚未问完，旁边便有人确认应由谁来回答；答案刚说到一半，又有人提醒这句话是否适合刊登。本报记者最后得到了一份措辞周全的说明，纸张也十分漂亮。

啊呀呀呀，本报当然理解，各方都有自己的顾虑。

不过，关于会谈、旧政变与城中的种种传闻，读者还在等待可以核实的内容。若答案暂时缺席，本报会先把问题留下。

宫门里面说了什么，本报记者仍会追问。至于今日得到的那份漂亮纸张，已经妥善带回报社，免得有人日后说本报从未来过。
NEWS_TEXT
        },
      ]
    },
  }

  #--------------------------------------------------------------------------
  # 三、内部工具。一般无需修改；不改写全局字体、绘字或输入模块。
  #--------------------------------------------------------------------------
  def self.characters(text)
    return text.to_s.unpack("U*").collect { |code| [code].pack("U*") }
  end

  def self.rect(values)
    return Rect.new(values[0], values[1], values[2], values[3])
  end

  def self.set_font(bitmap, names, size, rgb, bold = false)
    bitmap.font.name = names
    bitmap.font.size = size
    bitmap.font.bold = bold
    bitmap.font.italic = false
    bitmap.font.color = Color.new(rgb[0], rgb[1], rgb[2], 255)
  end

  def self.draw_text(bitmap, x, y, width, height, text, align = 0)
    # 工程的“文字投影”保留了原绘字入口，新闻单独跳过投影。
    if bitmap.respond_to?(:sailcat_draw_text)
      bitmap.sailcat_draw_text(x, y, width, height, text, align)
    else
      bitmap.draw_text(x, y, width, height, text, align)
    end
  end

  def self.play_sound(name)
    return if name == nil || name == ""
    # 通过 Audio 原接口播放，兼容工程已有的音量设置。
    Audio.se_play("Audio/SE/" + name, SE_VOLUME, SE_PITCH)
  end

  def self.transition(frames)
    if TRANSITION_NAME == ""
      Graphics.transition(frames)
    else
      Graphics.transition(frames, "Graphics/Transitions/" + TRANSITION_NAME)
    end
  end

  def self.read(issue_id)
    issue = NEWS[issue_id]
    if issue == nil
      raise ArgumentError, "文文新闻：找不到编号 #{issue_id}，请检查 NEWS 资料区。"
    end
    Scene_MaruNews.new(issue_id, issue).main
    # 事件指令脚本若返回 false 会重试；正常合上必须返回 true。
    return true
  end

  # 优先兼容游戏原生输入：L 为上页，R 为下页，B 为合上。
  # 实体 PgUp／PgDn／X 作为补充；API 返回 0 时不会挡住原生输入。
  # 两种通道共用按住状态，避免同一次按键被重复识别；不改全局 Input。
  class Keys
    KEY_CODES = {:previous => 0x21, :next => 0x22, :close => 0x58}
    INPUT_KEYS = {:previous => Input::L, :next => Input::R, :close => Input::B}

    def initialize
      @native = nil
      if defined?(Win32API)
        begin
          @native = Win32API.new("user32", "GetAsyncKeyState", ["i"], "i")
        rescue StandardError
          # 外部键盘接口不可用时，仍可通过原生输入操作。
          @native = nil
        end
      end
      @last_down = {}
      @triggered = {}
      KEY_CODES.each do |name, code|
        @last_down[name] = Input.press?(INPUT_KEYS[name]) || physical_down?(code)
      end
    end

    def update
      KEY_CODES.each do |name, code|
        input_key = INPUT_KEYS[name]
        input_trigger = Input.trigger?(input_key)
        native_down = physical_down?(code)
        down = input_trigger || Input.press?(input_key) || native_down
        @triggered[name] = (input_trigger || native_down) && !@last_down[name]
        @last_down[name] = down
      end
    end

    def physical_down?(code)
      return false unless @native
      return (@native.call(code) & 0x8000) != 0
    rescue StandardError
      @native = nil
      return false
    end

    def trigger?(name)
      return @triggered[name]
    end
  end

  #--------------------------------------------------------------------------
  # 四、自动排版。照片区域只限制该篇首页，续页全部使用正常宽度。
  #--------------------------------------------------------------------------
  class Paginator
    NO_LINE_START = "，。！？、；：）》】」』〕〉…—,.;:!?)]}"
    NO_LINE_END = "（《【「『〔〈([{"

    def initialize(measure_bitmap)
      @measure = measure_bitmap
      @width_cache = {}
      @body = BODY_RECT
      @photo = PHOTO_RECT
      raise ArgumentError, "文文新闻：正文框或行高无效。" if
        @body[2] <= 0 || @body[3] < LINE_HEIGHT || LINE_HEIGHT <= 0
    end

    def build(issue)
      pages = []
      issue[:articles].each_with_index do |article, article_index|
        @pages = pages
        @article = article
        @article_index = article_index
        new_page(true)
        text = article[:body].to_s.gsub("\r\n", "\n").gsub("\r", "\n").strip
        # 普通单换行明确换行；空白行使用较小段间距。
        text.split("\n", -1).each do |paragraph|
          if paragraph.strip == ""
            @y += PARAGRAPH_GAP unless @page[:lines].empty?
          else
            remaining = MaruNewsReader.characters(paragraph)
            while !remaining.empty?
              prepare_line
              x, width = line_span
              count = fitting_count(remaining, width)
              line = remaining[0, count].join
              @page[:lines].push([x, @y, width, line])
              remaining = remaining[count..-1] || []
              @y += LINE_HEIGHT
            end
          end
        end
      end
      return pages
    end

    def new_page(first_page)
      @page = {
        :article => @article, :article_index => @article_index,
        :first_page => first_page, :lines => []
      }
      @pages.push(@page)
      @y = @body[1]
    end

    def reserves_photo?
      return @page[:first_page] && @article[:reserve_photo] != false
    end

    def overlaps_photo?
      return false unless reserves_photo?
      return @y < @photo[1] + @photo[3] + PHOTO_GAP &&
        @y + LINE_HEIGHT > @photo[1] - PHOTO_GAP
    end

    def line_span
      width = @body[2]
      if overlaps_photo?
        width = [width, @photo[0] - PHOTO_GAP - @body[0]].min
      end
      return [@body[0], width]
    end

    def prepare_line
      # 照片若被配置得很靠左，跳到照片下方，避免零宽行死循环。
      if overlaps_photo? && line_span[1] < BODY_FONT_SIZE
        @y = @photo[1] + @photo[3] + PHOTO_GAP
      end
      new_page(false) if @y + LINE_HEIGHT > @body[1] + @body[3]
    end

    def character_width(char)
      if !@width_cache.has_key?(char)
        @width_cache[char] = [@measure.text_size(char).width, 1].max
      end
      return @width_cache[char]
    end

    def fitting_count(chars, width)
      count = 0
      used = 0
      while count < chars.size && used + character_width(chars[count]) <= width
        used += character_width(chars[count])
        count += 1
      end
      count = 1 if count == 0
      # 某些字体的整串宽度与单字累加略有差异，再量一次实际字符串。
      while count > 1 && @measure.text_size(chars[0, count].join).width > width
        count -= 1
      end
      # 尽量避免中文逗号、句号落在行首，或左括号落在行尾。
      if count < chars.size && count > 1
        count -= 1 if NO_LINE_START.include?(chars[count])
        while count > 1 && NO_LINE_END.include?(chars[count - 1])
          count -= 1
        end
      end
      return count
    end
  end
end

#==============================================================================
# 阅读画面：在当前场景上方临时打开；不替换 $scene，不重建地图。
# 因此合上后保留正在执行的事件、人物站位和当前音乐。
#==============================================================================
class Scene_MaruNews
  def initialize(issue_id, issue)
    @issue_id = issue_id
    @issue = issue
    @page_index = 0
    @closed = false
  end

  def main
    @calling_scene = $scene
    begin
      Graphics.freeze
      create_sprites
      refresh_page
      MaruNewsReader.play_sound(MaruNewsReader::OPEN_SE)
      MaruNewsReader.transition(MaruNewsReader::OPEN_TRANSITION_FRAMES)
      loop do
        Graphics.update
        Input.update
        update
        break if @closed || $scene != @calling_scene
      end
      Graphics.freeze
    ensure
      dispose_sprites
      # 解除冻结，恢复原场景；不销毁 RPG::Cache 管理的素材。
      MaruNewsReader.transition(MaruNewsReader::CLOSE_TRANSITION_FRAMES)
      Input.update
    end
  end

  def create_sprites
    @keys = MaruNewsReader::Keys.new
    # 全屏阅读直接使用 Sprite，不创建或释放 Viewport。
    @background = RPG::Cache.windowskin(MaruNewsReader::BACKGROUND_NAME)
    @background_sprite = Sprite.new
    @background_sprite.bitmap = @background
    @background_sprite.z = 100000
    @canvas = Bitmap.new(640, 480)
    @text_sprite = Sprite.new
    @text_sprite.bitmap = @canvas
    @text_sprite.z = 100001
    MaruNewsReader.set_font(@canvas, MaruNewsReader::BODY_FONT_NAMES,
      MaruNewsReader::BODY_FONT_SIZE, [0, 0, 0])
    @pages = MaruNewsReader::Paginator.new(@canvas).build(@issue)
    raise ArgumentError, "文文新闻：该期未填写任何报道。" if @pages.empty?
  end

  def refresh_page
    @canvas.clear
    page = @pages[@page_index]
    article = page[:article]
    draw_title(article[:title].to_s)
    draw_photo(article) if page[:first_page] && article[:reserve_photo] != false
    MaruNewsReader.set_font(@canvas, MaruNewsReader::BODY_FONT_NAMES,
      MaruNewsReader::BODY_FONT_SIZE, [0, 0, 0])
    page[:lines].each do |line|
      MaruNewsReader.draw_text(@canvas, line[0], line[1], line[2],
        MaruNewsReader::LINE_HEIGHT, line[3])
    end
    draw_footer(page)
    draw_controls
  end

  def draw_title(title)
    r = MaruNewsReader::TITLE_RECT
    size = MaruNewsReader::TITLE_FONT_SIZE
    loop do
      MaruNewsReader.set_font(@canvas, MaruNewsReader::TITLE_FONT_NAMES,
        size, [255, 255, 255], true)
      break if @canvas.text_size(title).width <= r[2] ||
        size <= MaruNewsReader::MIN_TITLE_SIZE
      size -= 1
    end
    MaruNewsReader.draw_text(@canvas, r[0], r[1], r[2], r[3], title, 1)
  end

  def draw_photo(article)
    r = MaruNewsReader::PHOTO_RECT
    name = article[:photo]
    if name == nil || name == ""
      draw_photo_placeholder if MaruNewsReader::SHOW_EMPTY_PHOTO_FRAME
      return
    end
    begin
      image = RPG::Cache.picture(name)
    rescue StandardError
      # 照片未提供／路径写错时仍保留版位，不让阅读过程崩溃。
      draw_photo_placeholder
      return
    end
    scale = [r[2].to_f / image.width, r[3].to_f / image.height].min
    scale = [scale, 1.0].min unless MaruNewsReader::PHOTO_ALLOW_UPSCALE
    width = [(image.width * scale).to_i, 1].max
    height = [(image.height * scale).to_i, 1].max
    x = r[0] + (r[2] - width) / 2
    y = r[1] + (r[3] - height) / 2
    @canvas.stretch_blt(Rect.new(x, y, width, height), image,
      Rect.new(0, 0, image.width, image.height))
  end

  def draw_photo_placeholder
    r = MaruNewsReader::PHOTO_RECT
    color = Color.new(90, 90, 90, 90)
    @canvas.fill_rect(r[0], r[1], r[2], 1, color)
    @canvas.fill_rect(r[0], r[1] + r[3] - 1, r[2], 1, color)
    @canvas.fill_rect(r[0], r[1], 1, r[3], color)
    @canvas.fill_rect(r[0] + r[2] - 1, r[1], 1, r[3], color)
    MaruNewsReader.set_font(@canvas, MaruNewsReader::BODY_FONT_NAMES,
      18, [0, 0, 0])
    MaruNewsReader.draw_text(@canvas, r[0], r[1] + r[3] / 2 - 14,
      r[2], 28, "照片暂缺", 1)
  end

  def draw_footer(page)
    r = MaruNewsReader::FOOTER_RECT
    MaruNewsReader.set_font(@canvas, MaruNewsReader::BODY_FONT_NAMES,
      MaruNewsReader::FOOTER_FONT_SIZE, [0, 0, 0])
    suffix = page[:first_page] ? "" : "（续）"
    text = @issue[:name].to_s + " · " + page[:article][:column].to_s + suffix
    MaruNewsReader.draw_text(@canvas, r[0], r[1], r[2] - 80, r[3], text)
    MaruNewsReader.draw_text(@canvas, r[0] + r[2] - 80, r[1], 80, r[3],
      "#{@page_index + 1}/#{@pages.size} 页", 2)
  end

  def draw_controls
    # 用底板空白纸纹遮住原有 A/B 提示，只改变阅读画面，不改 PNG 文件。
    @canvas.blt(550, 388, @background, Rect.new(550, 322, 66, 66))
    MaruNewsReader.set_font(@canvas, MaruNewsReader::BODY_FONT_NAMES, 12, [0, 0, 0])
    next_label = @page_index == @pages.size - 1 ? "PgDn 合上" : "PgDn 下页"
    ["PgUp 上页", next_label, "X 合上"].each_with_index do |text, index|
      MaruNewsReader.draw_text(@canvas, 550, 394 + index * 18, 66, 18, text)
    end
  end

  def update
    @keys.update
    if @keys.trigger?(:close)
      close_book
    elsif @keys.trigger?(:next)
      if @page_index == @pages.size - 1
        close_book
      else
        turn_page(1)
      end
    elsif @keys.trigger?(:previous)
      turn_page(-1) if @page_index > 0
    end
  end

  def turn_page(direction)
    @page_index += direction
    MaruNewsReader.play_sound(MaruNewsReader::TURN_SE)
    Graphics.freeze
    refresh_page
    MaruNewsReader.transition(MaruNewsReader::PAGE_TRANSITION_FRAMES)
  end

  def close_book
    MaruNewsReader.play_sound(MaruNewsReader::CLOSE_SE)
    @closed = true
  end

  def dispose_sprites
    @text_sprite.dispose if @text_sprite && !@text_sprite.disposed?
    @background_sprite.dispose if @background_sprite && !@background_sprite.disposed?
    @canvas.dispose if @canvas && !@canvas.disposed?
  end
end

# 唯一公开的事件指令，保留作者要求的大小写；其余名称放在独立命名空间。
def MaruNews(issue_id)
  return MaruNewsReader.read(issue_id)
end
