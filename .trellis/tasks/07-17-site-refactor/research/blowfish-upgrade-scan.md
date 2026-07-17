# Research: Blowfish v2.82.0 → v2.104.0 升级扫描

日期:2026-07-17 · 方法:GitHub Releases API 全量扫描(22 个 minor release)

## 结论

- **无声明的 breaking change**:release notes 中无一以 breaking/⚠ 标注的变更;命中 "break" 关键字的 4 条均为 bug 修复描述(v2.85.1、v2.86.0、v2.87.0、v2.89.0,修的是 "hugo minify breaks X" 类问题)
- `theme.toml`(main 分支)**未标注 min_version**,Hugo 0.161.1(2026-04)+ Blowfish v2.104.0(2026-07-02)组合需实测
- 最新版本:v2.104.0,published 2026-07-02

## 风险与缓解

| 风险 | 缓解 |
|---|---|
| 未声明的行为变化 | 升级后立即五页面浏览器核验(首页/文章/About/列表/404) |
| Hugo 版本下限 | 构建报错则同步升级本地 + `publish.yaml` 的 HUGO_VERSION |
| 保留覆写与新版 internals 漂移 | 每个保留覆写做 v2.104 rebase 检查(design.md D3) |

## 升级命令

```bash
hugo mod get github.com/nunocoracao/blowfish/v2@v2.104.0
hugo mod vendor
hugo mod tidy
```
