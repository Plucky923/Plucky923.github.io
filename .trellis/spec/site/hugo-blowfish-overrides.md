# Blowfish 主题覆写纪律

> 来源:07-17-cleanup-upgrade。教训:本仓曾对 Blowfish 做过 ~80 个文件的整文件复制,其中 80 个与主题原版逐字节一致,升级时全部成为噪音。

## 规则

1. **只覆写真正要改的文件**。`layouts/` 下任何文件必须与 `_vendor/` 中主题原版有实质差异;逐字节一致的覆写禁止提交(审计方法:递归 diff `layouts/` vs `_vendor/github.com/nunocoracao/blowfish/v2/layouts/`)。
2. **覆写即登记**。新增覆写时在 commit message 说明定制意图;大改同步更新任务的 override-inventory。
3. **升级主题先审计**:升级 Blowfish 前,先删一致文件,再对每个保留覆写做新版 rebase 检查(主题可能重构目录,如 v2.104 header 迁入 `partials/header/components/`)。
4. **go.mod 禁留 `replace` pin 主题版本**——它会让 `hugo mod vendor` 静默不升级(真实踩过)。
5. **改 Hugo 内置输出模板**(rss.xml / sitemap.xml / index.json)优先级最低,主题更新频繁,非必要不覆写。
6. `assets/css/custom.css` 的样式集中在 schemes + tokens 体系,禁止向模板里塞内联样式来绕过覆写纪律。
