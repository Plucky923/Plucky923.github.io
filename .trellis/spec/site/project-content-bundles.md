# Projects 内容 bundle 约定

`Projects` 是本站用于归档一个项目或一组同类材料的一级 Hugo section，不是运行时上传系统。

## 内容结构

```text
content/projects/
├── _index.md
└── <slug>/
    ├── index.md
    ├── report.pdf
    └── source.zip
```

- 每个 `<slug>` 必须是 leaf bundle，`index.md` 是项目页正文；其余同目录文件由 Hugo `Page.Resources` 管理。
- 不要把项目文件放入 `static/` 后再手写链接：项目详情页会自动发现同目录资源，保持 URL、页面和文件清单一致。
- 新项目从 `make new-project TITLE="My Project"` 创建；它使用 `archetypes/project.md` 并默认 `draft: true`。发布前补齐标题、说明和正文，再把 `draft` 改为 `false`。

## 前置字段

- `title`、`description`、`draft` 是基础字段。
- `projectType`、`status`、`repository`、`demo` 是可选显示字段；缺省时项目页必须仍可渲染。
- `weight` 可用于目录排序。文件计数和文件类型由资源本身得出，不要在前置字段中维护第二份清单。

## 模板和样式纪律

- 只在 `layouts/projects/` 放置 Projects 专用 list/single 模板；可复用项目卡片和资源清单放入命名明确的 partial。
- 对项目文件清单使用真实 `<a>` 和 `.RelPermalink`，并在长文件名/窄屏场景下保持可换行。
- 新样式使用 `plucky-project-*` 语义类和现有 `--line-*`、`--text-*`、`--font-*`、`--motion-*` token；尊重 `prefers-reduced-motion`。
