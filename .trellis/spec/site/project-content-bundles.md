# Projects 内容 bundle 约定

`Projects` 是本站用于归档一个项目或一组同类材料的一级 Hugo section。每个项目是一个文件夹，项目内部的 Markdown 文件作为可浏览文档展示。

## 内容结构

```text
content/projects/
├── _index.md
└── <slug>/
    ├── _index.md
    ├── first-note.md
    └── second-design.md
```

- 每个 `<slug>` 必须是 branch bundle，`_index.md` 是项目目录页正文。
- 项目内每个文档必须是 `.md` 文件，并带 Hugo front matter；项目页只展示文档标题，链接到对应文档页。
- 不要把 Markdown 文档作为 Page Resource 或下载文件展示；它们应该是可渲染页面。
- 新项目从 `make new-project TITLE="My Project"` 创建；它使用 `archetypes/project.md` 创建 `_index.md`，并默认 `draft: true`。发布前补齐标题、说明和正文，再把 `draft` 改为 `false`。

## 前置字段

- 项目目录页：`title`、`description`、`draft` 是基础字段。
- `projectType`、`status`、`repository`、`demo` 是可选显示字段；缺省时项目页必须仍可渲染。
- 文档页：至少包含 `title`、`date`、`draft`；`weight` 可用于文档排序。
- 文档数量由 Hugo 页面集合得出，不要在前置字段中维护第二份清单。

## 模板和样式纪律

- 只在 `layouts/projects/` 放置 Projects 专用 list/single 模板；可复用项目卡片和资源清单放入命名明确的 partial。
- 对项目文档清单使用真实 `<a>` 和 `.RelPermalink`，只展示文档标题；不要展示文件名、MIME 类型或下载按钮。
- 新样式使用 `plucky-project-*` 语义类和现有 `--line-*`、`--text-*`、`--font-*`、`--motion-*` token；尊重 `prefers-reduced-motion`。
