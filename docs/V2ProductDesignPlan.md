# 想恋爱 V2 产品设计方案

## 阶段目标

V2 不重做核心功能，目标是把已经上线的 LED 广告牌工具打磨成更适合海外市场、更好玩、更愿意付费的正式版本。

核心结论：

- 基础路径保持不变：选择或输入文字 -> 选择样式 -> 全屏 LED 展示。
- 免费用户仍可完成完整使用闭环，Pro 只增强表现力和效率。
- V2 视觉目标从“霓虹工具”升级为“现场感表达玩具”，打开后要有更强的舞台感和可玩性。
- 市场重点转向美国、日本等海外市场，文案、模板、emoji 和颜文字优先按海外用户的表达习惯设计。
- 不新增账号、服务端、网络请求、广告、分析 SDK 或第三方依赖。

## 技术方案

V2 仍沿用当前工程技术方向：

- SwiftUI 页面和组件。
- StoreKit 2 处理 Pro 权益。
- UserDefaults / AppStorage 保存本地设置。
- 本地 JSON / Codable 或现有本地 store 承载模板、样式、预设。
- 现有本地化体系承载英文和日文市场文案。

实现优先级：

1. 先扩展产品和视觉定义，固化模板、付费点、Pro 特效和验收标准。
2. 再打磨 UI 和交互，优先覆盖首页、模板中心、样式选择、LED 展示页、Pro 会员页。
3. 最后补齐本地化、付费路径、构建和核心路径验收。

## 任务边界

允许修改：

- `docs/` 下的 V2 方案、设计和验收文档。
- SwiftUI UI 层、复用组件、主题 token 的必要增量。
- 本地模板、样式、预设、Pro 权益展示相关数据。
- StoreKit 2 已有 Pro gating 的 UI 和文案。
- 英文、日文本地化文案。

不允许修改，除非后续明确授权：

- 签名、Bundle ID、Team、Version、Build、App Store 配置。
- 新增网络请求、账号系统、服务端、CloudKit、iCloud 同步。
- 新增广告、分析 SDK、ATT、IDFA 或敏感权限。
- 新增第三方依赖、字体文件、xcframework、模型文件。
- 改变免费用户完整使用基础 LED 功能的能力。

## V2 产品定位

一句话定位：

Turn your phone into a glowing message board for the moment.

V2 重点不是“更多设置”，而是让用户更快完成表达：

- 我在现场，想让 TA 看到我。
- 我不想想文案，想直接选一句能用的。
- 我想要更酷的灯牌效果，愿意为更好看的表达付费。
- 我想要英文、日文、emoji、颜文字自然混在一起，而不是翻译腔模板。

## 海外市场设计原则

### 美国市场

- 表达更直接、短句更有行动感。
- 模板优先覆盖 concert、party、pickup、birthday、sports、school event。
- 文案避免过长，优先 1 到 5 个词，适合远距离阅读。
- emoji 可以更外放，但不堆满屏幕。
- 付费卖点要直接：more effects, premium packs, save your best looks。

示例语气：

- LOOK HERE
- YOU GOT THIS
- HAPPY BDAY
- PROM?
- PICK ME!
- BEST NIGHT EVER

### 日本市场

- 表达更轻、更可爱、更含蓄，颜文字和符号更重要。
- 模板优先覆盖 live、oshi support、birthday、confession、meetup。
- 文案可以保留日文短句、英语应援词和颜文字混用。
- 视觉可以更偏 pop、idol live、kawaii neon，但不能变成廉价贴纸风。

示例语气：

- だいすき
- 最高!
- 見て!
- 推ししか勝たん
- お誕生日おめでとう
- こっちだよ (＾▽＾)

## V2 信息架构

保留现有主路径，但强化三个入口：

1. Home
   - 输入仍在首屏。
   - 模板和样式预览更靠前。
   - Pro 效果用动感预览吸引点击，不只放锁标。

2. Templates
   - 从“按场景找句子”升级为“按情绪和现场任务找表达”。
   - 支持 emoji、颜文字、英文短句、日文短句混合。
   - 免费模板足够可用，Pro 模板更精致、更完整、更省时间。

3. Effects
   - 样式选择页变成 V2 付费核心入口。
   - 免费样式负责基础实用。
   - Pro 样式负责炫酷、可玩、可分享。

## V2 模板分类

建议从 5 个旧分类扩展为 9 个 V2 分类。首屏可展示 5 个高频分类，其余放入模板中心。

| 分类 | 用途 | 免费策略 | Pro 策略 |
| --- | --- | --- | --- |
| Concert / Live | 演唱会、live house、idol support | 常用应援短句 | 更强 fandom、front-row、encore 表达 |
| Love / Crush | 表白、暧昧、情侣互动 | 直接表达 | 更浪漫、更俏皮、更适合拍照 |
| Birthday | 生日祝福 | 基础祝福 | 个性化、派对感、年龄梗 |
| Pickup / Welcome | 接机、接人、欢迎 | 实用引导 | 更醒目、更亲密、更长距离可读 |
| Party / Fun | 聚会整活 | 搞笑短句 | 更夸张、更有梗 |
| Sports / Team | 球赛、校队、比赛 | 加油短句 | 队伍应援、胜利庆祝 |
| School / Event | 校园活动、舞会、毕业 | 活动提示 | prom、graduation、club event |
| Travel / Sign | 旅行、路牌、临时提示 | 简单指示 | 机场、酒店、合影提示 |
| Oshi / Kawaii | 日式推し、可爱表达 | 基础日文应援 | 颜文字、符号、idol live 氛围 |

## 模板内容规则

模板要“能直接举起来用”，不是写给设置页看的文案。

规则：

- 单条模板优先 4 到 18 个字符，长句只作为少量 Pro 模板。
- 英文优先全大写或 Title Case，保证远距离可读。
- 日文模板保留自然日语，不要直译中文表达。
- emoji 每条最多 1 到 3 个，避免影响 LED 可读性。
- 颜文字只在适合可爱、日式、整活分类中使用。
- 每个分类至少保留 6 条免费模板，Pro 模板作为更丰富表达。

示例模板：

| 分类 | 免费模板 | Pro 模板 |
| --- | --- | --- |
| Concert / Live | LOOK HERE / ENCORE! / LOVE YOU | FRONT ROW ENERGY / SING IT BACK / BEST NIGHT EVER |
| Love / Crush | I LIKE YOU / BE MINE? / MISS YOU | YOU + ME TONIGHT / SAY YES? / MY FAVORITE PERSON |
| Birthday | HAPPY BDAY / MAKE A WISH / PARTY TIME | BIRTHDAY ICON / WISH BIG / 21 AND GLOWING |
| Pickup / Welcome | WELCOME / OVER HERE / THIS WAY | FINALLY HERE / SAFE LANDING / I MISSED YOU |
| Party / Fun | DANCE BREAK / SEND HELP / NO PHOTOS | MAIN CHARACTER / CHAOS MODE / ONE MORE SONG |
| Sports / Team | GO TEAM / WE GOT THIS / DEFENSE | GAME WINNER / LET'S GOOO / MVP ENERGY |
| School / Event | PROM? / CLASS OF 2026 / GRAD SZN | SAVE ME A DANCE / AFTER PARTY? / WE MADE IT |
| Oshi / Kawaii | 見て! / だいすき / 最高! | 推ししか勝たん / こっちだよ (＾▽＾) / 今日も優勝 |

## V2 付费点

V2 建议不新增 IAP 商品类型，继续复用 Pro 永久解锁，把新增付费点作为 Pro 权益和付费触发入口表达。

### 付费点 1：Pro Effect Packs

用户付费理由：

- 免费样式能用，但 Pro 样式明显更酷、更适合拍视频和现场展示。
- 样式选择页要让用户一眼看出 Pro 的动态价值。

产品表现：

- Pro 样式卡片展示更强预览，不只显示静态名称。
- 点击 Pro 样式后进入对应触发语境的 paywall。
- paywall 文案强调 unlock every premium effect，而不是抽象会员权益。

### 付费点 2：Premium Template Packs

用户付费理由：

- 不想自己想词。
- 想快速找到更适合现场和关系语境的表达。
- 愿意为更好看的成套表达付费。

产品表现：

- 模板中心显示免费模板和 Pro 模板混排，Pro 模板要让人能预览内容。
- Pro 模板不隐藏文案，锁的是“一键使用”。
- 每个分类放少量特别好玩的 Pro 模板，形成自然付费冲动。

备选付费点，暂不作为 V2 主推：

- Saved Looks Plus：保存更多完整样式组合。
- Custom Neon Presets：自定义色彩、速度、字体和动效组合保存。

## 12 个 Pro 特效设计

现有代码已经有 12 个 Pro 样式位置。V2 重点应是把这 12 个特效重新定义得更有差异，而不是只堆名字。

| 特效 | 视觉方向 | 适合场景 | 设计要点 |
| --- | --- | --- | --- |
| Meteor Shower | 流星从文字后方掠过 | Concert / Birthday | 速度快，星尾细，不遮挡文字 |
| Laser Sweep | 激光扫描文字边缘 | Concert / Sports | 蓝粉双色扫光，强调舞台感 |
| Firework Burst | 文字周围爆开彩色烟花 | Birthday / Party | 爆点不宜太密，避免降低可读性 |
| Heart Beat | 文字随心跳轻微放大和发光 | Love / Crush | 节奏像心跳，不做夸张缩放 |
| Heart Rain | 小心形从上方飘落 | Love / Birthday | 心形数量可控，保留主文案层级 |
| Rainbow Flow | 彩虹渐变沿文字流动 | Party / Pride / Fun | 渐变要鲜亮，背景保持暗 |
| Star Flash | 星点随机闪烁 | Concert / Oshi | 星点像舞台灯，不像廉价闪粉 |
| Bullet Fly-In | 多条短句弹幕飞入 | Party / Concert | 保持主句优先，弹幕可作为背景层 |
| Aurora Wave | 极光波纹穿过背景 | Travel / Dreamy | 更高级、柔和，适合高级模板 |
| Bubble Pop | 气泡弹出和破裂 | Birthday / Kawaii | 轻快可爱，不影响文字边缘 |
| Spotlight | 聚光灯追随文字 | Stage / Pickup | 模拟舞台 spotlight，远距离可读 |
| Glitch Pulse | 赛博故障脉冲 | Fun / Sports | 控制闪烁强度，避免刺眼 |

补充设计要求：

- 每个特效都要有静态缩略预览和全屏动态效果。
- Pro 特效必须在样式卡片里有可识别差异。
- 动效不能牺牲 LED 文案远距离可读性。
- 减少频闪风险，避免高频全屏闪白。
- 低性能设备上允许降级粒子数量，但不能变成空效果。

## UI 打磨方向

### Home

- 首屏要像一个小舞台，不像表单。
- 输入区保留，但模板入口要更强，鼓励用户先点模板。
- 样式预览卡要展示真实 LED 视觉，避免纯文本列表。
- Pro 入口要像高级效果入口，不像普通设置按钮。

### Template Center

- 以分类和模板短句为主，不要做复杂搜索产品。
- 分类 tab 使用高密度横向滚动。
- 模板 chip 允许 emoji 和颜文字，但需要控制行高。
- Pro 模板可见但加锁，用户知道付费后得到什么。

### Effect Picker

- 这是 V2 的主要付费场景。
- 免费/Pro 分段要明确，但不要把 Pro 藏到第二屏。
- 每个 Pro 卡片至少展示名称、场景标签、动态感预览、Pro 标识。

### LED Display

- 现场使用优先，控制面板不能抢主文案。
- 横屏效果是核心验收项。
- 单击隐藏控制、双击暂停、速度和字号调节要低干扰。
- Pro 特效的粒子和背景只服务文字，不喧宾夺主。

### Paywall

- paywall 要跟触发来源相关。
- 从 Pro 特效进入时，主标题卖 effects。
- 从 Pro 模板进入时，主标题卖 template packs。
- 保持一个 Pro 永久解锁，不制造复杂订阅认知。

## 海外本地化原则

- 英文不是中文翻译版，要重新写。
- 日文不是中式表达直译，要保留日本 live、推し、可爱表达习惯。
- 付费文案要直接、短、可信。
- 避免确定性夸大，例如不能承诺会被看到、会成功表白。
- 不把娱乐表达描述成专业建议或确定性预测。

## 验收标准

阶段 1：方案验收

- V2 产品目标、边界、付费点、模板分类、12 个 Pro 特效已明确。
- 与现有 `ProductSpec.md` 和 `UIStyleGuide.md` 不冲突。
- 没有引入第三方依赖、网络、账号、广告、分析或敏感权限。

阶段 2：界面验收

- 首页、模板中心、样式选择、展示页、Pro 页达到统一霓虹舞台风格。
- 免费用户可以完整走通核心路径。
- Pro 入口明显但不阻断基础使用。
- 英文和日文文案自然，不是翻译腔。
- 二级页保留现有返回和边缘返回体验。

阶段 3：发布前验收

- Debug 构建通过。
- Release 构建通过。
- 核心路径手动验证通过。
- Pro 购买、恢复购买和已购状态验证通过。
- 横屏 LED 展示在常见尺寸上可读。
- `git status` 无异常构建产物、签名文件或临时文件。

## 三阶段执行计划

### 阶段 1：V2 方案固化

产物：

- V2 产品设计方案。
- 模板分类和样例模板。
- 12 个 Pro 特效定义。
- 付费点和验收标准。

不做：

- 不改 Swift 业务代码。
- 不改工程配置。
- 不跑发布相关操作。

### 阶段 2：核心界面打磨

产物：

- 首页、模板中心、样式选择、展示页、Pro 页的 UI 和交互升级。
- 本地模板和样式数据增量。
- 英文和日文文案增量。

不做：

- 不新增服务端能力。
- 不新增广告或分析。
- 不新增额外 IAP 商品，除非后续明确改商业模式。

当前落地状态（2026-06-18）：

- 模板从 5 个场景扩展到 9 个海外向场景，共 72 条内置模板。
- 首页热门模板改为跟随当前场景，保留免费核心路径，不再固定演唱会样例。
- 模板中心展示本地化模板标题和正文，Pro 模板有明确但不阻断的锁定提示。
- 样式选择页新增 Pro 特效包引导，并在样式卡片中强化免费 / Pro 识别。
- Pro 文案改为围绕 12 个高级特效包、高级模板包和完整样式保存能力表达。
- 未修改签名、Bundle ID、Team、Version、Build、网络、账号、广告、分析、StoreKit 商品配置。

阶段 3A 视觉 polish 状态（2026-06-18）：

- 首页 Hero 增加 LED READY / LIVE MODE / 72 TEMPLATES 状态胶囊，强化打开即上屏的工具感。
- 首页模板 chip 增加小型 LED 牌质感，免费和 Pro 视觉层级更清晰。
- 模板中心正文预览改成发光灯牌样式，让用户更容易判断模板上屏效果。
- 样式选择页 Pro 引导卡增加特效包图标暗示，减少纯文案感。
- Pro 页 Hero 增加 12 EFFECTS / TEMPLATE PACKS / SAVED LOOKS 卖点胶囊，付费价值前置。
- 未修改核心路径、横屏展示逻辑、购买、恢复购买、StoreKit 商品或工程发布配置。

### 阶段 3：验收和 polish

产物：

- Debug / Release 构建验证。
- 核心路径和付费路径检查。
- 视觉一致性、横屏展示和本地化问题修正。

不做：

- 不改签名、版本号、Build 号或 App Store 配置。
- 不替代用户执行发布动作。
