# 工具链版本纪律

> 来源:07-17-cleanup-upgrade。教训:本地 Hugo 0.161.1 / CI 0.161.1 / Netlify 0.136.5 / Makefile 注释 0.162.1,四个版本三个错。

## 规则

1. **Hugo 版本唯一事实源 = `.github/workflows/publish.yaml` 的 `HUGO_VERSION`**。本地安装、`Makefile` 注释、README 向它对齐;升级 Hugo 时先改 workflow,再同步其余。
2. 已删除 `netlify.toml`(HugoBlox 遗留)。部署目标只有 GitHub Pages,**不得再引入第二个部署管线**。
3. Blowfish 版本 pin 在 `go.mod`;升级 = `hugo mod get ...@vX.Y.Z && hugo mod tidy && hugo mod vendor`,三件套一次提交(`_vendor/` 必须随仓,保证 CI 与回滚可复现)。
4. 代理环境:`hugo mod` 命令需要网络,失败先查代理,不要盲目重试。
