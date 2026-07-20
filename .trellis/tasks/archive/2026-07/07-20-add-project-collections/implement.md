# Implement — Add project collections

执行计划。用户已授权规划后自动实施，无需额外的规划审批门。

## Steps

1. 完成当前模板、配置、CSS token 和现有工作树勘察；确认没有已有 Projects content type 可复用。
2. 添加 `content/projects/_index.md`、Projects 菜单项和首页入口；不添加虚构的已发布项目。
3. 新建 section 专用 list/single 模板和两个小 partial，将项目卡片与资源显示逻辑集中。
4. 追加以 `plucky-project-*` 命名的响应式样式，复用现有视觉 token 和 `prefers-reduced-motion` 规则。
5. 添加 `archetypes/project.md`、`make new-project` 命令和 README 使用说明。
6. 用临时 draft bundle 和文本资源验证 `hugo new`、资源发现、详情 HTML 和桌面/窄屏浏览器表现；验证完成后删除临时内容。
7. 运行模板审计、`make clean && make build`、链接/HTML 检查与浏览器回归；更新任务状态与必要的 site 规范，再进行本地提交。

## Validation commands

```bash
make clean && make build
hugo list all
make new-project TITLE="Verification Project"
hugo -D --gc --minify
```

浏览器核验范围：`/`、`/projects/`、临时草稿项目、`/post/`、一篇文章、`/about/`、不存在路由；检查桌面和窄屏、导航链接、Files 文件链接、键盘焦点与控制台。

## Review gates

- G1：实现前确认 PRD/Design/Implement 已将“文件归档”限定为 Hugo page resources，而不是不可能的运行时上传。
- G2：临时 project bundle 证明 Projects single layout 和资源清单路径正确。
- G3：生产构建、页面巡检和覆写审计通过后才提交。

## Rollback points

- 模板或 CSS 不符合站点风格：仅回退本任务的 `layouts/projects/` 与 `plucky-project-*` 规则。
- Hugo archetype 调用不符合预期：回退 `new-project` target，不影响已存在的 `make new`。

## Verification record

- `make new-project TITLE="Verification Project"` 成功生成 draft leaf bundle，并采用 `project` archetype。
- 临时 bundle（含 `verification-notes.txt`）在 `hugo -D --gc --minify` 中渲染了项目卡片、外部链接、资源类型和下载 URL；随后已删除，未进入生产构建。
- `make clean && make build` 成功；生产 `/projects/` 显示零项目空状态，sitemap 包含 `/projects/`，并核验首页、post、文章、about、404 的生成产物存在。
- 本机当前没有可控制的浏览器实例，因此未能做交互截图；浏览器接入失败已按 Browser skill 的诊断流程确认，未用替代浏览器绕过。
