# 标题背景呼吸光

已接入游戏实际加载的 `Data/Scripts.rxdata` 中的 `Scene_Title_LostRecord`，并同步到同目录的 `Scene_Title_LostRecord.rb`。

## 当前效果

- 中央白蓝光每 4 秒一轮：1.2 秒亮起、0.24 秒峰值、2.16 秒回落、0.4 秒低谷。
- 蓝紫外晕延迟 0.22 秒，最多向外扩张 1.8%。
- 根据原背景的明亮区域生成临时透明遮罩，为已经纯白的部分留出明暗余量。
- 白区附近的原有光点轻微呼应主光；光效图层位于 LOGO 和菜单后面。
- 两张光效 PNG 保留 1448×1086 原文件，显示时按完整画布缩放到 640×480。

## 调整参数

参数位于标题脚本开头的 `LostRecordTitle` 模块。

| 参数 | 当前值 | 用途 |
| --- | --- | --- |
| `GLOW_ENABLED` | `true` | 开关背景光效 |
| `GLOW_PERIOD` | `4.0` | 一轮的秒数 |
| `GLOW_HALO_DELAY` | `0.22` | 外晕延迟秒数 |
| `GLOW_SHADE_OPACITY` | `30` | 白区的明暗余量 |
| `GLOW_CORE_MIN` / `GLOW_CORE_GAIN` | `6` / `24` | 中央光基础强度及增幅 |
| `GLOW_HALO_MIN` / `GLOW_HALO_GAIN` | `2` / `18` | 外晕基础强度及增幅 |
| `GLOW_HALO_EXPAND` | `0.018` | 外晕最大扩张比例 |

外置 `.rb` 修改后需要重新同步至实际加载的脚本；也可以直接在 RPG Maker XP 脚本编辑器中的同名脚本段调整参数。

## 验证与备份

已通过 40 / 60 帧下的周期、外晕延迟、画布对齐、图层顺序与透明度检查，并检查了新游戏、读取、禁用选项、退出和资源释放。

RGSS 引擎隐藏启动时未发现错误提示；隐藏窗口截图为空，因此这次没有完成游戏内动态图像的目视确认。

修改时只更新了原标题脚本段，其余 253 段保持不变。修改前备份：

- `Scripts.before-background-glow-20261008-093051.rxdata`
- `Scene_Title_LostRecord.before-background-glow-20261008-093051.rb`
