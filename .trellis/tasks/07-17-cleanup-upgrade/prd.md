# Cleanup and Blowfish upgrade(子任务 1/2)

> 父任务:`.trellis/tasks/07-17-site-refactor`(目标、设计决策 D1-D4、回滚策略见其 prd/design/implement)

## Goal

清除 HugoBlox 遗留,统一工具链,升级 Blowfish v2.82.0 → v2.104.0,收敛模板覆写面,落地 About + Blog 站点地图。交付一个**干净、最新、渲染等价**的基座,供 design-redo 在其上工作。

## Requirements

- R1: 删除 `content/teaching/`、`content/event/`、`content/publication/`
- R2: 删除 `.github/workflows/import-publications.yml`、`updater-wip.yml`、`netlify.toml`、`bachelor.html`
- R3: 重写 `README.md`(Blowfish + plucky 站点简述,替换 HugoBlox 模板说明)
- R4: 统一 Hugo 版本叙述:`Makefile` 注释修正为 0.161.1;若升级后主题要求更高版本,则本地 + `publish.yaml` 同步升并记录
- R5: 升级 Blowfish → v2.104.0(`hugo mod get` + `hugo mod vendor` + `hugo mod tidy`)
- R6: `layouts/` 覆写审计:与 v2.82.0 原版一致的文件删除;有修改的登记入 `research/override-inventory.md` 并对 v2.104 做 rebase 检查
- R7: 移除首页 bento 的 Teaching 磁贴(死链),首页其余结构保持可用(视觉重做留给子任务 2)
- R8: 站点地图 = About + Blog;菜单维持 About + GitHub
- R10: 被删 section URL 不做 alias,404 页兜底

## Acceptance Criteria

- [ ] AC1: 全仓 grep 无 teaching/event/publication 内容、HugoBlox 工作流、netlify.toml、bachelor.html;README 与现状一致
- [ ] AC2: 全仓 Hugo 版本号仅一处事实源;`go.mod` 中 Blowfish = v2.104.0;`layouts/` 下无与主题原版一致的文件
- [ ] AC3: `make clean && make build` 零错误零警告;首页/文章/About/列表/404 五页面浏览器核验渲染正常,无死链
- [ ] AC4: `hugo list all` 仅含 post + about;生成的 sitemap 无被删 section URL

## Out of Scope

- 任何视觉重做(R11-R18 属子任务 2)
- `custom.css` 的 5719 行保留不动(子任务 2 全量重写)

## 依赖

无(第一个执行)。子任务 2 依赖本任务合入 main。
