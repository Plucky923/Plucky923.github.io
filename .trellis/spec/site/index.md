# Site(Hugo + Blowfish)规范

本仓是 Hugo 静态站(主题 Blowfish,Hugo module 引入)。本 package 规范约束主题覆写、工具链版本、部署。

## Pre-Development Checklist

改 `layouts/`、`assets/`、`config/` 前必读:

- [hugo-blowfish-overrides.md](./hugo-blowfish-overrides.md) — 主题覆写纪律
- [toolchain-versioning.md](./toolchain-versioning.md) — 版本 pin 纪律
- [project-content-bundles.md](./project-content-bundles.md) — Projects 目录与文件资源约定

## Quality Check

- `make clean && make build` 零错误零警告
- 改动 layouts 后必须浏览器核验:首页 / `/post/` / 一篇文章 / `/about/` / 404
- 生产部署 = push 到 main(GitHub Actions → GitHub Pages),无预览环境,合 main 前必须本地核验
