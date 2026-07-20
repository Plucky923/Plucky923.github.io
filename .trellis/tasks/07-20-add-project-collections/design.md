# Design — Add project collections

技术设计。需求和验收见 `prd.md`；执行顺序见 `implement.md`。

## Frontend direction

- **Visual thesis**：把项目页做成一册深色的“工作档案目录”——obsidian 画布上用 cyan 作为导航与文件信号、gold 作为分隔与状态细节，延续现有编辑感而不做新的 dashboard。
- **Content plan**：目录页先给出 Projects 的范围和总量，再以可点击的项目目录列出项目；项目页依次呈现项目身份、说明/正文、外部入口和同目录文件清单。
- **Interaction thesis**：项目目录 hover 时以轻微位移和边框亮起确认可进入；文件链接在 hover/focus 时强调下载箭头；进入页面沿用现有短暂的渐入，不增加 JavaScript 动画。

## Content model

```
content/
└── projects/
    ├── _index.md                  # /projects/ 目录页
    └── framevm/                   # 一个项目 leaf bundle
        ├── index.md                # 项目描述和前置字段
        ├── report.pdf              # 自动显示在 Files 中
        ├── diagram.png             # 自动显示在 Files 中
        └── source.zip              # 自动显示在 Files 中
```

`content/projects/<slug>/index.md` 的前置字段契约：

| 字段 | 必需 | 用途 |
| --- | --- | --- |
| `title` | 是 | 项目名称 |
| `date` / `weight` | 建议 | 目录页排序 |
| `description` | 建议 | 目录页简介和 SEO 描述 |
| `projectType` | 否 | 例如 Research、Software、Notes |
| `status` | 否 | 例如 Active、Archived、In progress |
| `repository` | 否 | 外部源码入口 |
| `demo` | 否 | 外部演示或主页入口 |
| `draft` | 是（archetype 默认） | 防止新目录未完成时公开 |

页面资源只从 `.Resources` 读取：`index.md` 仍是页面正文；同目录的 PDF、图片、压缩包等保留 Hugo 的 `RelPermalink`，无需在前置字段中重复登记。这样文件名、URL 和发布路径都由 Hugo 单一管理。

## Template and data flow

```
project bundle files
  -> Hugo Page.Resources
  -> layouts/projects/single.html
  -> Files list (name, media type, open/download link)

project front matter
  -> layouts/partials/project-card.html
  -> layouts/projects/list.html
  -> /projects/ directory
```

- `layouts/projects/list.html` 是 section 专用列表页，使用已有 page-hero 字体与边界语言，不借用通用文章列表的日期分组。
- `layouts/partials/project-card.html` 负责项目目录项，避免列表页和后续首页入口重复定义项目元信息。
- `layouts/projects/single.html` 是 leaf bundle 专用详情页。它渲染正文、可选 `repository`/`demo` 链接和所有页面资源；资源不存在时省略 Files 区域。
- `layouts/partials/project-resource-list.html` 集中资源名、媒体类型、查看/下载链接的 HTML，保持资源显示逻辑只有一个所有者。
- `archetypes/project.md` 配合 `hugo new content --kind project` 生成新项目；`Makefile` 仅包装这个 Hugo 命令和 slug 计算，不自行复制前置字段。

## Layout and visual integration

- 在 `menus.en.toml` 加入 `Projects`，置于 About 与 GitHub 之间；首页 bento 增加同级 Projects 小入口。
- 项目目录采用无多余卡片嵌套的两列响应式目录项；“卡片”仅作为项目可点击的边界，符合当前站点已有 article card 的使用方式。
- 项目详情将 Files 作为带细分隔线的 ledger，不使用 dashboard 小组件；每行完整可点击且支持键盘 focus。
- CSS 只在 `assets/css/custom.css` 追加语义化 `plucky-project-*` 规则，使用现有 token（`--line-*`、`--text-*`、`--font-*`、`--motion-*`、`--radius-*`）。所有动效在 `prefers-reduced-motion` 下取消或保留静态状态。

## Edge cases and accessibility

- 没有项目：目录页显示空状态，不暴露仓库路径或写作指令。
- 没有描述、状态、外部链接或资源：相应元素不输出，页面仍保持完整层级。
- 文件名很长：CSS 使用 `overflow-wrap:anywhere`，小屏不会横向溢出。
- 所有项目和文件操作用真实 `<a>`；外部链接有明确的文字与新窗口语义，下载链接保留文件媒体类型。
- 所有装饰性图形标记 `aria-hidden`，不依赖色彩作为唯一信息源。

## Verification strategy

生产内容保持没有虚构项目。验证时临时生成一个 draft project bundle（含文本资源），以 `hugo -D` 和本地浏览器验证详情页及资源列；完成后删除该临时 bundle。常规生产构建验证空目录页和现有页面没有回归。

## Rollback

本功能只涉及新 section、两处导航、四个小模板、archetype、Makefile/README 和追加 CSS。回滚时可整体 revert 该任务的提交；不会影响主题 vendor 或既有文章内容。
