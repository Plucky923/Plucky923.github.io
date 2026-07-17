# Implement — Site-wide refactor(父任务)

执行计划。两个子任务串行,各自独立验收、独立分支、独立合入。

## Task Map

| 顺序 | 子任务 | 范围 | 验收 |
|---|---|---|---|
| 1 | `cleanup-upgrade` | R1-R10(清理 + 升级 + 站点地图) | AC1-AC4 |
| 2 | `design-redo` | R11-R18(方向 D 视觉) | AC5-AC8 |

## 全局验证命令

```bash
make clean && make build          # 生产构建必须零错误零警告
hugo server -D --gc               # 本地核验
hugo list all                     # 内容清单(AC4)
```

## Review Gates

1. **G1(child-1 开工前)**:用户 review 父任务 prd/design/implement + 子任务 PRD → `task.py start`
2. **G2(child-1 合入前)**:浏览器核验五页面(首页/文章/About/列表/404)+ AC1-AC4 全绿
3. **G3(child-2 开工前)**:child-1 已合 main;design token 草案(色板/字体)给用户过目
4. **G4(child-2 合入前)**:AC5-AC8 + prefers-reduced-motion 核验 + 控制台零错误
5. **G5(父任务关闭)**:`trellis-update-spec` 沉淀新规范(见下)→ commit → finish-work

## Rollback Points

- child-1 升级失败:回退 `go.mod`/`go.sum`/`_vendor/` 三处即回到 v2.82.0
- child-2 视觉回归:`git revert` 单次合入 commit;旧 5719 行 CSS 在 git 历史中完整可查

## Spec 沉淀计划(G5)

任务结束后写入 `.trellis/spec/`:

- 新 package `site/`(Hugo 站):Blowfish 覆写纪律(不整文件复制、覆写登记)、版本 pin 纪律(单一事实源)、design token 纪律(双色语义分工、无版本后缀类名)
- 更新 `.trellis/spec/backend/` 模板残留与本仓无关条目的清理评估
