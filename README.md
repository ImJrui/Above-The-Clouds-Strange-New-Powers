# 云霄国度补丁 · Above The Clouds - Strange New Powers

这是一个《饥荒联机版》（DST）服务器模组，为 Above The Clouds（云霄国度）补充联机版内容与兼容逻辑，涉及农业、角色与配方适配、商店、遗迹重置，以及可选的三分片世界穿越。

本项目不是云霄国度本体。需要启用依赖模组 **Above The Clouds**（`workshop-3322803908`），并在其后加载本模组。`modinfo.lua` 声明 `all_clients_require_mod = true`，加入服务器的客户端也需要安装。

开发前请阅读 [AGENTS.md](AGENTS.md)。玩法说明分别见 [中文内容介绍](内容介绍.md) 和 [英文内容介绍](introduction.md)；具体行为以当前代码、配置和实际加载情况为准。

## 源码参考位置

以下路径都相对于本项目根目录：

| 内容 | 相对路径 |
| --- | --- |
| DST 游戏源码 | `../../data/databundles/scripts` |
| Above The Clouds 依赖源码 | `../../../../workshop/content/322330/3322803908` |
| `steamapps` 祖先目录 | `../../../..` |

只在需要确认接口或原行为时定向读取相关外部源码，不全量读取，不扫描其他创意工坊模组。完整边界和从 `steamapps` 拼接路径的方法见 `AGENTS.md`。

## 目录与文件职责

| 路径 | 用途 |
| --- | --- |
| `main/` | 公共初始化和接线：配置、资源、语言、控制台命令、RPC、分片通信、弹窗与补丁注册。 |
| `postinit/` | 按类型组织对游戏或依赖既有内容的补丁，统一从 `main/postinit.lua` 接入。 |
| `postinit/components/` | 既有组件补丁，例如门与世界迁移、室内天气和刷怪兼容、雾和花粉效果。 |
| `postinit/prefabs/` | 既有预制件、玩家和相关定义表补丁，例如世界组件、采集种植、交易奖励、WX78 模块定义。 |
| `postinit/multipleprefabs/` | 多个预制件共享的修改，例如部署限制、种子、树木、水源和洒水器。 |
| `postinit/stategraphs/` | 既有状态图扩展，涉及玩家和猪的行为状态。 |
| `postinit/screens/` | 既有屏幕类补丁，目前用于玩家 HUD 与穿越弹窗接线。 |
| `postinit/widgets/` | 既有界面部件补丁，目前用于护目镜显示。 |
| `postinit/modules/` | 模块级补丁，目前涉及毁灭季周期与 Map 室内判定。 |
| `postinit/shardindex.lua` | 双穿模式相关的分片索引与世界生成覆盖读取兼容。 |
| `scripts/` | 本项目的预制件、组件、功能模块、布局及其他可加载脚本，也保留部分历史补丁。 |
| `scripts/prefabs/` | 自定义实体及配套定义，例如弹药、调料、食物、树苗、商店、天空之椅和遗迹重置特效；也包含数据表和生成函数。 |
| `scripts/components/` | 自定义组件，例如芯片光环、天空之椅进度、锁店及续锁、遗迹重置和沃尔特瞄准。 |
| `scripts/features/` | 功能模块与工具，包括烹饪、调味食品、商店扩展、拖网掉落、农业界面、遗迹及蚁丘重建；部分文件包含既有对象补丁。 |
| `scripts/rebalance/` | 历史上的平衡与兼容模块，包括角色、配方、动作、出生物品、Boss、技能树和世界生成。 |
| `scripts/map/static_layouts/` | 猪镇世界生成使用的静态布局数据，由世界生成脚本选择并载入。 |
| `scripts/screens/redux/` | 自定义界面类，目前是天空之椅目的地确认弹窗。 |
| `scripts/languages/` | 运行时中文翻译 `plreb_chinese_s.po` 与翻译模板 `strings.pot`。 |
| `strings/` | 中英文文本源：公共名称、配方、动作、界面提示与角色台词。 |
| `strings/tools/` | 文本提取和 PO/POT 生成工具，不属于游戏运行入口。 |
| `anim/` | Klei 动画资源 ZIP，内含动画、构建和纹理等二进制资源。 |
| `images/hud/` | 物品与 HUD 图集纹理和 XML 的 UV 索引；`.xml.bak` 是保留的备份文件。 |
| `preview.xml`、`preview.tex` | 模组列表图标的图集定义与纹理。 |
| `mod.manifest` | 模组二进制清单文件，不作为源码编辑。 |
| `内容介绍.md`、`introduction.md` | 面向玩家的中文、英文玩法介绍与原作者说明。 |
| `tips.md` | 历史开发 API 速查笔记，使用时仍需核实当前接口。 |
| `AGENTS.md` | 仓库读取边界、开发归类、验证要求和 Git 协作规范。 |

`scripts/rebalance/` 和部分 `scripts/features/` 中的既有对象修改属于历史布局。后续对游戏或依赖既有内容的修改按对象类型放入 `postinit/`，本项目自定义内容放入 `scripts/`，双语文本放入 `strings/`。历史补丁按任务范围逐步收敛，不因完善文档而批量迁移代码。

## 入口与加载流程

| 入口 | 职责 |
| --- | --- |
| `modinfo.lua` | 模组元数据、配置项、依赖和加载优先级。当前基础优先级为 `-20`，本地开发目录再减 1。 |
| `modmain.lua` | 依次载入 `main/` 的公共接线，再载入指定的定义、功能和平衡脚本。 |
| `modworldgenmain.lua` | 载入 `scripts/rebalance/worldgen.lua`，处理猪镇关卡与静态布局。 |
| `modservercreationmain.lua` | 接入前端兼容，并调用依赖提供的世界位置开关，启用创建世界相关功能。 |
| `modfrontendmain.lua` | 处理前端卸载模组时的世界位置开关与创建服务器界面恢复。 |

`modmain.lua` 当前先载入配置、资源、文本及台词回退，再接入命令、RPC、分片通信、弹窗和 PostInit；后续功能可能依赖前面建立的全局数据与接口，调整顺序前需核实调用链。

`main/` 的关键文件：

| 文件 | 职责 |
| --- | --- |
| `constants.lua` | 读取配置并兼容旧配置名，定义 `PL_CONFIG`、世界类型和季节映射。 |
| `assets.lua` | 声明 `PrefabFiles`、公共资源和物品图集注册。 |
| `strings.lua` | 导入公共文本和角色台词，按语言加载 PO 并翻译 `STRINGS`。 |
| `autostrings.lua` | 为部分角色描述提供已有台词回退。 |
| `commands.lua` | 遗迹、蚁丘重置及室内检查等控制台辅助命令。 |
| `RPC.lua` | 注册目的地确认的服务端 RPC，以及世界类型、月暴相关的分片 RPC。 |
| `shardnetworking.lua` | 同步连通分片的世界类型并更新传送门目的地。 |
| `popups.lua` | 注册天空之椅弹窗，与 HUD 和自定义屏幕连接。 |
| `postinit.lua` | 按分类清单载入补丁，提供预制件注册后处理，并通过 `require` 包装接入模块补丁。 |
| `toolutil.lua` | 工具函数定义；当前 `modmain.lua` 未显式导入此文件，不能因文件存在就假设本地实现已经执行。 |

新增脚本需要实际接入入口：PostInit 文件加入对应清单；真正导出预制件的文件按需加入 `PrefabFiles`；组件通过实体挂载；辅助定义表和生成函数按需 `require` / `modimport`。一个预制件脚本可以导出多个实体，其文件名不等于全部实体名。

部分补丁只在 `PL_CONFIG.ENABLE_SKYWORTHY` 开启后加载。现有注释掉的导入或未被引用的文件，不代表已启用功能。

## 文本维护

公共文本写在 `strings/common.lua`，通用检查语写在 `strings/generic.lua`，角色文本写在对应角色文件中，沿用双语格式：

```lua
en_zh({EN = "English text", CN = "中文文本"})
```

运行时的 `en_zh` 只返回英文，中文通过 `scripts/languages/plreb_chinese_s.po` 覆盖，因此修改源文后还需核对并同步 PO/POT。`strings/tools/autostring.lua` 可以生成这两个文件，但依赖 Windows 命令及支持其语法的独立 Lua 解释器；运行前先检查实现，运行后审阅警告和生成差异。新增角色文件还需核对 `main/strings.lua` 的导入表。

## 开发与验证

每个新任务创建独立的 `codex/<主题>` 分支，例如 `codex/update-map`。完成相关测试并获得用户明确同意后，才可合并到 `main`；同一任务的后续修订继续使用原主题分支。

仓库目前没有统一构建命令或自动化测试套件。文档改动检查目录、路径、链接和 `git diff --check`；Lua 行为改动需结合可用语法检查和 DST 测试环境验证。涉及客户端表现、存档、世界生成或三分片穿越时，分别覆盖对应场景。具体要求见 `AGENTS.md`，未进行游戏验证时应明确说明。
