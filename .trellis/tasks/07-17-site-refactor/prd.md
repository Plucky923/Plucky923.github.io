# Site-wide refactor(父任务)

## Goal

在 Hugo + Blowfish 技术栈不变的前提下,对 Plucky923.github.io(www.plucky.wang)做全站重构,三条主线一次完成:

1. **技术债清理与升级** — 清除 HugoBlox 遗留,收敛模板覆写面,统一工具链版本,升级 Blowfish
2. **内容架构重组** — 站点地图收敛为 About + Blog,全英文
3. **视觉重做** — 落地方向 D「星野手稿」:宇宙 × 哲学 × 极客

明确排除:迁移到其他静态站框架。

## Background(代码库勘察,2026-07-17)

### 技术栈现状
- Hugo 静态站,主题 Blowfish **v2.82.0**(`go.mod` pin,`_vendor/` 已 vendor)
- 本地 Hugo `v0.161.1`;GitHub Actions `publish.yaml` pin `0.161.1`;Netlify `netlify.toml` pin `0.136.5`(遗留)→ 版本不一致;`Makefile` 注释声称 0.162.1(过时)
- 部署:push 到 main → GitHub Actions → GitHub Pages,CNAME `www.plucky.wang`
- `Makefile`:`server` / `build` / `clean` / `deploy`(含 macOS SOCKS 代理开关)/ `new`

### HugoBlox → Blowfish 迁移未清理的遗留
- `README.md` 仍是 HugoBlox Academic 模板说明
- `content/teaching/{js,python}`、`content/event/example`、`content/publication/{journal-article,conference-paper,preprint}` 全部示例内容,菜单无入口(孤儿)
- `.github/workflows/import-publications.yml`、`updater-wip.yml` 为 HugoBlox 配套,失效
- `netlify.toml`(Hugo 0.136.5 + pagefind 管线)为 HugoBlox 时代遗留;Blowfish 搜索走 Hugo 自建 `index.json`,pagefind 不需要
- `bachelor.html` 仓库根,内容 = 单个空格,全仓无引用
- 首页 bento 磁贴含 `/teaching/` 链接,删除 section 后将成为死链

### 定制面与设计 DNA 现状
- `layouts/` 下大量 Blowfish 内部模板复制(partials/shortcodes/_default 共 ~80 文件),升级主题的主要风险面
- `assets/css/custom.css` **5719 行**,无设计刻度,类名带 v2/v3/v4 版本后缀 —— 视觉重做的主要包袱
- 配色:obsidian/graphite 中性 + electric violet 主 + luminous cyan 辅(`assets/css/schemes/plucky.css`)
- 首页(`layouts/partials/home/custom.html`):giant "plucky." wordmark + 5 层装饰 hero + bento grid(Archive/About/Teaching)+ latest post
- 文章页:utterances 评论已配置(`layouts/partials/comments.html`,repo = Plucky923/Plucky923.github.io,theme = preferred-color-scheme)
- 真实内容:1 篇文章 `content/post/2026-06-04-why-should-we-write-in-english` + About(ISCAS 博士,OS/系统安全,两句话)

## Requirements

### 主线一:技术债清理与升级
- R1: 删除 `content/teaching/`、`content/event/`、`content/publication/` 全部示例内容
- R2: 删除 `.github/workflows/import-publications.yml`、`updater-wip.yml`、`netlify.toml`、`bachelor.html`
- R3: 重写 `README.md` 为当前站点(Blowfish + plucky)的简要说明
- R4: 统一 Hugo 版本:本地 / CI / 文档同一版本(0.161.1),修正 `Makefile` 过时注释
- R5: 升级 Blowfish v2.82.0 → 最新 v2.x,`hugo mod vendor` 同步 `_vendor/`
- R6: 模板覆写面审计:`layouts/` 下与主题原版一致的文件全部删除,只保留真实修改过的覆写
- R7: 移除首页 bento 中的 Teaching 磁贴(死链),其余首页结构在子任务二前保持可用

### 主线二:内容架构重组
- R8: 站点地图 = About + Blog(`content/post/`);全英文,`defaultContentLanguage = "en"` 不变
- R9: 导航菜单维持 About + GitHub 外链;不新增入口
- R10: 被删示例 section 的 URL 不做 alias(从未有入口,无外链价值),由自定义 404 页兜底

### 主线三:视觉重做 — 方向 D「星野手稿」
- R11: 深空靛黑底色 + 星光白文字;**金 + 紫双色语义分工**:金 = 哲学/人文(箴言、引文、标题点缀),紫 = 宇宙/深空(星云、星野、hero 装饰)
- R12: 字体系统:serif 展示字体(标题/箴言)+ 正文 serif 或 sans + 等宽字体承载全部元信息(日期/标签/坐标/阅读时长);自托管 woff2
- R13: 首页重写:星野 hero + serif wordmark + 轮换箴言 + Observations(最新文章)+ Observer(About  teaser);替换现有 bento/wordmark 实现
- R14: `custom.css` 整体重写:5719 行无约束样式 → 有 token 刻度的设计系统(颜色/字阶/间距/组件),禁止 v2/v3/v4 式版本后缀类名
- R15: 星野动效静态优先,可选极缓漂移;必须尊重 `prefers-reduced-motion`;无第三方 JS 库,JS 预算 < 10KB
- R16: 博客阅读体验:文章即"观测日志"气质 — 等宽元信息行、serif 标题、箴言引文 shortcode、`~/` 路径式面包屑
- R17: utterances 评论保留,theme 固定为深色(如 `github-dark`),不再跟随 preferred-color-scheme
- R18: About 页只搭结构与排版(Observer 框架),文案保持现有两句,用户后续自补

## Acceptance Criteria

- [ ] AC1(R1-R3):仓库中不存在 teaching/event/publication 内容、HugoBlox 工作流、netlify.toml、bachelor.html;README 描述与现状一致
- [ ] AC2(R4-R6):`grep` 全仓 Hugo 版本号仅 0.161.1;`go.mod` 中 Blowfish 为最新 v2.x;`layouts/` 下无与主题原版一致的文件
- [ ] AC3(R5-R7):`make build` 通过,首页/文章/About/404/列表页渲染正常,首页无死链
- [ ] AC4(R8-R10):`hugo list all` 仅含 post + about;sitemap 无被删 section URL;菜单渲染正确
- [ ] AC5(R11-R15):浏览器核验首页/文章页符合方向 D:深空底、金紫分工可见、serif 标题、等宽元信息、星野 hero;`prefers-reduced-motion` 下无动画;无控制台错误
- [ ] AC6(R14):`custom.css` 重写后通过样式 token 审计(单一色板来源、字阶/间距刻度),无版本后缀类名
- [ ] AC7(R16-R18):文章页等宽元信息 + 箴言 shortcode 可用;评论深色渲染;About 结构就位
- [ ] AC8:生产构建 `hugo --gc --minify` 零警告零错误;GitHub Actions 部署绿

## Out of Scope

- 迁移到其他静态站框架(Astro/Next.js/Quartz 等)
- 中英双语 / 多语言结构
- Projects / Publications / Teaching 等新 section
- About 页文案写作(用户后补)
- 新文章写作

## Open Questions

无阻塞项。执行期技术决策(覆写审计策略、Blowfish 升级兼容处理、字体选型)记录于 `design.md`。

## 被否决方案存档

- A. Signal & Noise(深色进化):重做感不足
- B. Paper & Ink(浅色学术):与用户关键词(宇宙/极客)不符
- C. Lab Instrument(单色终端):哲学维度缺失,被方向 D 吸收
