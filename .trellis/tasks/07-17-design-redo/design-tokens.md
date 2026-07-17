# Design Tokens 草案 — 方向 D「星野手稿」(G3 评审件)

父任务 design.md D5 的具体化。开工前需用户过目。

## 色板

### Neutral — 深空靛黑 scale
| token | hex | 用途 |
|---|---|---|
| neutral-900 | #05070F | 页面基底(深空) |
| neutral-800 | #0B0E1A | 卡片/次级表面 |
| neutral-700 | #161B2E | 边框/分隔 |
| neutral-600 | #2A3252 | 弱边框 |
| neutral-400 | #7E86A6 | 次要文字 |
| neutral-200 | #C9CEE4 | 正文 |
| neutral-50  | #F4F6FF | 标题/星光白 |

### Primary = violet(宇宙)— 链接、交互、星云、hero
沿用现有血脉:500 `#8B5CF6`,400 `#A78BFA`(深底上主用 400 保对比),600 `#7C3AED`。

### Secondary = gold(哲学)— 箴言、引文、标题点缀、分隔符
500 `#D4A03C`(星光金),400 `#E0B45C`(深底主用),600 `#B7872F`。
**对比度纪律**:gold 用于文字时仅 400 档,且在 neutral-900 上需实测 ≥ 4.5:1,不足则提亮到 300 `#EBC984`。

### 语义分工(纪律)
- violet = 宇宙/深空:所有可点击元素、链接、按钮、星云雾气、hero 装饰
- gold = 哲学/人文:epigraph、blockquote 左边线、标题装饰符(如 § / ✦)、分隔线、箴言轮换
- 两色永不用于同一组件;gold 永不可点击,violet 永不用于箴言

## 字体

| 角色 | 字体 | 字重/轴 | 用途 |
|---|---|---|---|
| 展示 + 正文 serif | Newsreader(variable) | opsz 6–72,wght 300–700,italic | 标题(opsz 大、wght 500-600)、正文(opsz 文本档、wght 400) |
| 元信息 mono | IBM Plex Mono | 400, 500 | 日期、标签、坐标、阅读时长、面包屑、按钮文字 |

自托管 `static/fonts/`(variable woff2 ×2,≈120KB),`@font-face` + `font-display: swap`;fallback 链 `Georgia, 'Times New Roman', serif` / `ui-monospace, Menlo, monospace`。

## 字阶(1.250 major third,基准 17px)

| 档位 | px | 用途 |
|---|---|---|
| -1 | 13.6 | mono 元信息 |
| 0 | 17 | 正文 |
| 1 | 21.3 | 小节标题/导语 |
| 2 | 26.6 | h3 |
| 3 | 33.3 | h2 |
| 4 | 41.6 | h1/文章标题 |
| 5 | 52 | 页面大标题 |
| 6 | 65 | hero wordmark(fluid clamp 至 ~96) |

行高:正文 1.7,标题 1.15,mono 1.5。正文栏宽 ≈ 68ch。

## 间距刻度(4px 基)

4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96;组件内距 ≤ 24,区块间距 48–96。

## 星野参数

- 3 层 box-shadow 星点:1px ×140、1.5px ×70、2px ×30,随机分布(构建期生成静态值)
- 星云:violet radial-gradient 两团,透明度 ≤ 0.14,静态
- 漂移:仅最密星层,translateY 循环 ≥ 120s,linear
- `@media (prefers-reduced-motion: reduce)` → 全部 animation: none
- 零 JS;`background-blur.js` 删除

## 组件清单(custom.css 重写后)

tokens → base → `hero`(星野+wordmark+epigraph 轮换)→ `meta-row`(mono 元信息)→ `epigraph`(gold 引文)→ `card`(observations 列表项)→ `observer`(about teaser)→ `breadcrumb`(~/ 路径式)→ utilities。类名单一语义,无版本后缀。

## 待用户确认

1. 色板 hex(尤其 gold #D4A03C 系)
2. Newsreader + IBM Plex Mono 组合
3. 字阶基准 17px / 1.250
