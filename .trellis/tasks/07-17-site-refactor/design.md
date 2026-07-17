# Design — Site-wide refactor(父任务)

技术设计。需求与验收见 `prd.md`;执行顺序见 `implement.md`。

## 架构决策

### D1. 子任务边界与依赖

```
07-17-site-refactor(父)
├── child-1: cleanup-upgrade   —— 主线一 + 主线二(清理、升级、站点地图)
└── child-2: design-redo       —— 主线三(方向 D 视觉重做)
    依赖:child-1 完成并合入 main 后方可开始
```

依赖理由:在 5719 行未重写 CSS 与 ~80 个模板覆写之上升级 Blowfish 会双重返工;先把基座收敛干净,视觉重做在稳定基座上进行。

### D2. Blowfish 升级策略(v2.82.0 → v2.104.0)

- `hugo mod get github.com/nunocoracao/blowfish/v2@v2.104.0` + `hugo mod vendor`,提交 `go.mod`/`go.sum`/`_vendor/`
- 勘察结论:v2.82→v2.104 共 22 个 minor release,release notes **无声明的 breaking change**(research/blowfish-upgrade-scan.md)
- 风险:release notes 未声明 ≠ 无行为变化;`theme.toml` 未标注 min Hugo version。缓解:升级后立即 `make build` + 浏览器核验五个关键页面(首页/文章/About/列表/404),回归失败则逐 release 二分

### D3. 模板覆写面审计(升级前置步骤)

`_vendor/` 持有 v2.82.0 原版,审计方法:

1. 对 `layouts/**/*.html` 逐文件与 `_vendor/github.com/nunocoracao/blowfish/v2/layouts/**` 同路径文件 diff
2. **一致 → 删除**,回退到主题版本(预计可删大部分 shortcodes 与未定制 partials)
3. **有修改 → 保留**,登记到 `research/override-inventory.md`(文件、修改意图、与 v2.104 原版的 rebase 风险)
4. 升级后对每个保留覆写做 v2.104 rebase 检查:修改意图能否在新版上复现,不能则重写该覆写

判定:已知定制的有 `home/custom.html`、`header/fixed-fill-blur.html`、`home/*`、`comments.html`(utterances);shortcodes 目录疑似全量为原样复制(待审计确认)。

### D4. 版本统一

- Hugo 版本唯一事实源:`publish.yaml` 的 `HUGO_VERSION`(0.161.1);`Makefile` 注释修正为实际版本;`netlify.toml` 删除后该 pin 消失
- 若 v2.104 实际需要更高 Hugo:`publish.yaml` + 本地安装同步升级,注释同步

### D5. 方向 D「星野手稿」设计系统(child-2)

**色板**(`assets/css/schemes/plucky.css` 重写,Blowfish scheme 结构):

| 角色 | 映射 | 语义 |
|---|---|---|
| neutral | 深空靛黑 scale(#05070F 基底 → 星光白) | 底色/文字 |
| primary | violet scale(沿用现有 500=#8B5CF6 血脉,微调) | **宇宙**:链接、交互、星云、hero 装饰 |
| secondary | gold/amber scale(500 ≈ #D4A03C 星光金,非亮黄) | **哲学**:箴言、引文、标题点缀、分隔符 |

纪律:两色不混用于同一组件;gold 永不用于可点击元素,violet 永不用于箴言。

**字体**(自托管 woff2,`static/fonts/`,`@font-face` 入 custom.css):

- 展示 + 正文 serif:**Newsreader**(variable,opsz 轴;OFL)——标题用 opsz 大值,正文用文本光学尺寸
- 元信息等宽:**IBM Plex Mono**(OFL)——日期/标签/坐标/阅读时长/面包屑
- 载荷预算:两族 variable woff2 ≈ 120KB,`font-display: swap`

**星野 hero**:纯 CSS 实现 — 多层 `box-shadow` 星点(2-3 层不同尺寸/密度)+ violet radial-gradient 星云 + 单层极缓(≥120s)位移动画;`@media (prefers-reduced-motion: reduce)` 下动画全关。**零 JS**;现有 `background-blur.js` 随首页重写删除。

**箴言(epigraph)**:新增 `layouts/shortcodes/epigraph.html`(引文 + 出处,gold accent,serif italic);首页箴言轮换用 CSS crossfade keyframes(3-4 条,无 JS)。

**首页结构**(`home/custom.html` 重写):

1. Hero:星野 + serif "plucky." wordmark + 轮换箴言
2. Observations:最新文章列表(等宽日期 + serif 标题)
3. Observer:About teaser 卡片

**文章页**:等宽元信息行(日期 · 阅读时长 · 字数 · 标签),serif 标题,面包屑渲染为 `~/post/...` 路径式(修改现有 `breadcrumbs.html` 覆写),utterances theme 固定 `github-dark`。

**CSS 工程**:`custom.css` 全量重写,结构 = tokens → base → components → utilities;组件类名单一语义,禁止 `v2/v3/v4` 版本后缀;目标 ≤ 1200 行;旧 5719 行整体删除(git 历史留存,不做渐进迁移)。

### D6. 部署与回滚

- 每个子任务一个 feature branch,本地 `hugo server` + 浏览器核验后才合 main(main = 生产,无预览环境)
- 回滚 = `git revert` + push;`_vendor/` 提交使主题版本随仓库可回滚
- 被删示例 section URL 不做 alias(R10),由 404 页兜底

## 兼容性说明

- Hugo 0.161.1 + Blowfish v2.104.0 组合需 child-1 实测;失败回退策略见 D2
- utterances 评论功能保留(R17),仅改 theme 属性
- Blowfish 搜索(JSON index)不受影响;`outputs.home` 保持 `["HTML","RSS","JSON"]`

## 遗留决策(执行期判定,不阻塞)

- 字体最终选型若 Newsreader 渲染不佳,备选 Fraunces / Source Serif 4
- gold 色值在深色底上的对比度需 WCAG AA(≥4.5:1 用于文字时),不足则调亮
