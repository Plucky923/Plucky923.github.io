# Add project collections

## Goal

为 `plucky.wang` 增加一级 `Projects` 内容空间。每个项目是一个 Hugo leaf bundle（一个真实目录），可以把同一项目或同一类的说明、PDF、图片、代码压缩包等文件放在一起，并在站点上以项目详情页和可下载文件清单呈现。

本任务是旧 `site-refactor` 中明确排除的 Projects 范围的后续独立实现；以当前生产站点的深色编辑式界面为准，而非尚未落地的旧视觉草案。

## Requirements

- R1：新增 `/projects/` 入口，出现在主导航和首页的内容入口中；不移除现有 Archive、About、GitHub 入口。
- R2：`/projects/` 必须作为项目目录页，展示已发布项目的标题、简述、项目类型、状态和附带资源数量；没有已发布项目时给出清晰、克制的空状态。
- R3：每个项目采用 `content/projects/<slug>/index.md` 目录结构。与 `index.md` 同目录的静态资源必须自动成为该项目详情页的“Files”清单，并以站内链接提供打开/下载。
- R4：项目详情页支持可选的 `projectType`、`status`、`repository`、`demo` 前置字段；没有这些字段或没有文件时仍能正常渲染。
- R5：提供一个可重复使用的项目 archetype 和 `make new-project TITLE="..."` 命令，生成 draft 项目目录与标准前置字段，方便后续新增项目。
- R6：README 说明新的内容布局和创建项目命令。
- R7：页面视觉必须继承当前站点的深色 obsidian 底色、cyan/gold 细节、Space Grotesk 标题、IBM Plex Mono 元信息、现有间距/圆角/动效节奏；不新增第三方脚本、图标库或主题依赖。
- R8：改动只新增必要的 Hugo 覆写与样式，不修改 `_vendor/`，并避免把整份 Blowfish 模板复制到项目中。

## Acceptance Criteria

- [ ] `/projects/` 在生产构建中存在，主导航、首页和项目目录页之间的链接均有效。
- [ ] 一个常规项目 bundle 能在 `/projects/<slug>/` 渲染标题、说明、可选链接、元信息和同目录资源清单。
- [ ] 空项目目录能优雅渲染，不会产生模板错误或误导性的示例项目。
- [ ] `make new-project TITLE="Example"` 生成 `content/projects/<slug>/index.md`，且内容为 draft、使用项目 archetype。
- [ ] `make clean && make build` 零错误、零警告；`hugo list all` 能列出发布的 Projects section。
- [ ] 浏览器核验首页、`/projects/`、一个带资源的草稿项目、`/post/`、文章页、`/about/` 和 404，窄屏与桌面均无明显布局或控制台错误。

## Out of Scope

- 不实现后台上传、登录、文件版本管理或搜索服务；这是静态 Hugo 站点，文件由仓库中的项目 bundle 管理。
- 不迁移或虚构用户尚未提供的现有项目/文件。
- 不部署或推送到 GitHub；本任务只完成本地实现、验证和提交。
