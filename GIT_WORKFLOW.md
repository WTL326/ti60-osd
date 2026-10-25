# ti60-osd / ivlab-239 Git 协作与自动化规范

> 本文件配套 `scripts/git-hooks/`（本地钩子）与 `.github/workflows/verify.yml`（远端 CI），
> 目标：改动有序入库、验证不过不推送、推送后远端自动复验并版本化。

## 1. 分支模型
- `main`：稳定主干，建议设分支保护，只接受 PR 合入。
- 功能/修复：从 `main` 切 `feat/xxx`、`fix/xxx`（或 `quad-osd-overlay` 这类专题分支）。
- 个人实验/草稿：直接推自己的远端分支即可，不必开 PR。

## 2. 什么时候开 PR
满足任一条再开 PR；否则直接 push 或直合主干：
1. 主干受保护、禁止直推；
2. 需要他人 code review / 团队把关；
3. 需要 CI 跑测试作为合并门槛；
4. 需要可关联 issue、可讨论的合并记录；
5. fork 后向原仓库贡献（唯一途径）。

## 3. 提交规范
- 一次 commit = 一个逻辑单元（一个功能点或一个修复）。
- message 前缀：`feat` / `fix` / `chore` / `docs` / `refactor` / `test`。
- `pre-commit` 钩子自动查空白错误、提醒大文件（>5MB）。
- 不建议"每次保存都自动 commit"：历史会被噪音淹没法看。保存可自动 `git add`，commit 按逻辑点做。

## 4. 自动化门禁（已落地）
| 环节 | 触发 | 动作 | 缺工具链时 |
|---|---|---|---|
| pre-commit | `git commit` | 空白检查（git 内置，无需工具链） | 始终生效 |
| pre-push | `git push` | `make -C test` 跑 0xBB 协议测试（rv32im+qemu） | 拒绝推送（`--no-verify` 可绕）|
| GitHub Actions | push / PR | ubuntu 自装 riscv 工具链+qemu，跑同一套测试 | CI 环境自洽 |

> 当前为**严格模式**：缺 Efinity 工具链、或 `make -C test` 失败，都会**拒推**；确需绕过用 `git push --no-verify`。换工具链前缀：`RISCV_BIN=riscv64-unknown-elf-`。

## 5. 版本化
- 语义化 tag：`vMAJOR.MINOR.PATCH`。
- 打 `v*` tag 即触发 release 工作流自动出版本（需另加 release workflow，可在 verify.yml 基础上扩展）。

## 6. 实际例子

### 例 1 —— 日常本地提交（修一个小缺陷）
场景：改完 `src/osd/ui.c` 的 Zoom 枚举边界，本地自测通过，先落本地库、暂不推远端。
```bash
git add src/osd/ui.c                 # 若开了自动暂存，这步已自动做
git commit -m "fix(osd): 修正 Zoom 枚举越界边界"
# pre-commit 自动跑空白检查，干净才让过；到此只在本地，未推远端
```

### 例 2 —— 完成一个功能后合并到 GitHub
场景：37 页全菜单接入完成（即 `quad-osd-overlay` 做的活），要合到远端。
```bash
git status                           # 确认工作树干净、在功能分支
git push -u origin quad-osd-overlay  # pre-push 先跑 make -C test，通过才放行
# 远端 GitHub Actions 自动再跑一遍同一套测试，出现绿勾
# 开 PR 合入主干：浏览器打开 push 输出里的 pull/new/... 链接
# 合并后打版本：
git tag v1.1.0 && git push origin v1.1.0
```

## 7. 一次性启用（每台机器执行一次）
```bash
git config core.hooksPath scripts/git-hooks   # 让 git 用仓库内这套钩子
```
