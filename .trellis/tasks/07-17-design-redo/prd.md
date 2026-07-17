# Direction D visual redesign(子任务 2/2)

> 父任务:`.trellis/tasks/07-17-site-refactor`(设计系统细节见其 design.md **D5**,双色语义纪律、字体、星野、组件结构以那里为准)

## Goal

在 cleanup-upgrade 交付的干净基座上,实现方向 D「星野手稿」:宇宙 × 哲学 × 极客。`custom.css` 全量重写为有 token 刻度的设计系统。

## Requirements

- R11: 深空靛黑底 + 星光白字;金(哲学/人文)+ 紫(宇宙/深空)双色语义分工,纪律见父 design.md D5 表格
- R12: 字体:Newsreader(展示+正文,variable opsz)+ IBM Plex Mono(全部元信息),自托管 woff2 于 `static/fonts/`,`font-display: swap`
- R13: 首页重写:星野 hero + serif wordmark + CSS 轮换箴言 + Observations(最新文章)+ Observer(About teaser)
- R14: `custom.css` 全量重写:tokens → base → components → utilities;目标 ≤ 1200 行;禁止版本后缀类名;旧 5719 行整体删除
- R15: 星野纯 CSS(box-shadow 星点 + radial-gradient 星云 + ≥120s 缓动),零 JS;`prefers-reduced-motion` 下动画全关;删除 `background-blur.js`
- R16: 文章页:等宽元信息行、serif 标题、`~/` 路径式面包屑、新增 `epigraph` shortcode(引文+出处,gold accent)
- R17: utterances theme 固定 `github-dark`
- R18: About 页只搭 Observer 结构与排版,文案保持现有两句不动

## Acceptance Criteria

- [ ] AC5: 浏览器核验首页/文章页:深空底、金紫分工可见、serif 标题、等宽元信息、星野 hero;reduced-motion 下无动画;控制台零错误
- [ ] AC6: `custom.css` ≤ 1200 行,单一色板来源(`schemes/plucky.css` + tokens),无 `v2/v3/v4` 后缀类名
- [ ] AC7: epigraph shortcode 可用;评论深色渲染;About Observer 结构就位
- [ ] AC8: `hugo --gc --minify` 零警告零错误;GitHub Actions 部署绿

## 依赖

**cleanup-upgrade 合入 main 后方可开工**(父 design.md D1;避免在未升级主题上重写 CSS 造成双重返工)。

## Review Gates

- G3(开工前):design token 草案(色板 hex 值、字体、字阶)给用户过目
- G4(合入前):AC5-AC8 全绿
