# Superpowers Runtime Sync 最新流程说明书

更新时间：2026-04-29  
适用范围：Xia 维护的 `superpowers` fork、本机 overlay、已安装 Claude runtime cache  
目标读者：需要修改 `superpowers` 的 Agent / 工程师

## 1. 这份文档解决什么问题

这份说明书用于回答 5 个问题：

1. `superpowers` 到底应该在哪改
2. 遇到 hook / skill / command / CLAUDE 文档变更时应该怎么拉分支
3. 改完以后哪些文档必须同步
4. 怎么把改动部署到本机 Claude 正在使用的 runtime
5. 怎么把结果提交、推送、打 tag、记 changelog

如果你只记一条，记这个：

`fork -> overlay -> installed cache`

也就是：

1. 先在 `superpowers-fork` 改
2. 再把受管文件 capture 到 ChatBobi 的 overlay
3. 再 deploy 到已安装的 Claude plugin cache

不要反过来。不要先改 installed cache。不要把 ChatBobi overlay 当成主编辑位置。

## 2. 三层结构和各自职责

### A. 版本控制真源：`superpowers-fork`

路径：

```text
/Users/harry/Documents/GitHub/superpowers-fork
```

职责：

- 所有正式的 `superpowers` 逻辑修改都应先在这里完成
- 这里负责 Git 历史、分支、commit、push、tag、`changelogs.md`
- 这里是后续和 `upstream` 合并时要依赖的唯一版本控制真源

典型修改内容：

- `CLAUDE.md` / `CLAUDE_zh.md`
- `hooks/*`
- `hooks/hooks.json`
- `hooks/hooks-cursor.json`
- `skills/*`
- `commands/*`
- `tests/claude-code/*`
- `README.md`
- `changelogs.md`

### B. 部署辅助层：ChatBobi overlay

路径：

```text
/Users/harry/Documents/chatbobi/docs/superpowers-local/
```

关键内容：

- `overlay/`
- `MANAGED_FILES.txt`
- `LOCAL_RELEASES.md`
- `backups/`
- `docs/scripts/sync-superpowers-fork.sh`
- `docs/scripts/manage-superpowers-local.sh`

职责：

- 保存“本机要托管的 superpowers 文件子集”
- 提供 capture / status / deploy / restore
- 记录本机级别的部署历史和回滚资产

注意：

- overlay 不是主编辑真源
- overlay 是 fork 到 runtime 之间的受管传输层
- 如果一个文件要参与 deploy，它必须出现在 `MANAGED_FILES.txt`

### C. 运行时目标：installed cache

路径：

```text
~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/
```

当前常见版本：

```text
~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/
```

职责：

- Claude Code 实际运行的 hooks / skills / commands 就在这里

注意：

- 这是部署目标，不是主编辑位置
- 宿主刷新 cache、插件升级、重新安装时，这里可能被覆盖
- 只有紧急 hotfix 且用户明确批准时，才允许把这里当临时抢修点

## 3. 仓库和远端关系

### 上游

```text
upstream = https://github.com/obra/superpowers.git
```

### Xia 维护 fork

```text
origin = https://github.com/doubleweir/superpowers.git
```

### 本机 clone

```text
/Users/harry/Documents/GitHub/superpowers-fork
```

## 4. 哪些任务必须走 Runtime Sync

只要任务涉及以下任一内容，就必须使用 Runtime Sync 思路：

- 修改 hook
- 修改 `hooks.json` / `hooks-cursor.json`
- 修改 skill / command / CLAUDE / README
- 修改 `changelogs.md`
- 修改本地 overlay deploy 规则
- 修改 `MANAGED_FILES.txt`
- 修改本机 runtime 部署方式
- 做 superpowers 的发布、打 tag、回滚、升级、对齐 upstream

不该直接在 ChatBobi 业务流程里处理成“小修”的场景：

- “帮我改一下 superpowers 的 hook”
- “这个 stop gate 太烦了，调一下”
- “给 superpowers 加个提醒”
- “把本地 runtime 再部署一下”
- “把这个改动同步到 GitHub”

## 5. 标准工作流

### 场景 A：修改现有 Xia 维护版 superpowers

按这个顺序：

1. 进入 fork 仓库
2. 从当前 Xia 维护主线拉维护分支
3. 在 fork 中改代码/文档/测试
4. 先跑 fork 侧测试
5. 更新 fork 侧 `changelogs.md`
6. 把受管文件 capture 到 ChatBobi overlay
7. 检查 overlay 和 installed cache 是否 drift
8. deploy 到 installed cache
9. 在真实 Claude 会话中做黑盒验证
10. 更新 ChatBobi 侧 `LOCAL_RELEASES.md`
11. 回到 fork，commit
12. merge 回 Xia 维护主线
13. push 分支
14. 打 release tag
15. push tag

## 6. 分支规范

### fork 仓库里的常见分支角色

- `main`
  - 当前可能跟 Xia 维护主线对齐，也可能只是默认分支
  - 不要想当然在 `main` 上直接改

- `xia/cache-package-<version>`
  - Xia 维护的当前 package 主线
  - 例如：`xia/cache-package-5.0.7`

- 临时维护分支
  - 推荐命名：

```text
xia/<topic>-YYYY-MM-DD
```

示例：

```text
xia/runtime-sync-routing-2026-04-28
xia/runtime-sync-manual-2026-04-29
xia/acceptance-trigger-fix-2026-04-28
```

### 拉分支建议

先看当前基线：

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork status --short --branch
git -C /Users/harry/Documents/GitHub/superpowers-fork log --oneline --decorate -n 5
```

如果当前维护基线是 `xia/cache-package-5.0.7`，从它拉：

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork checkout xia/cache-package-5.0.7
git -C /Users/harry/Documents/GitHub/superpowers-fork checkout -b xia/<topic>-YYYY-MM-DD
```

## 7. 文档规范

### fork 仓库里必须同步的文档

视改动范围，通常需要更新：

- `CLAUDE.md`
- `CLAUDE_zh.md`
- `README.md`
- `changelogs.md`
- 对应的 skill / command 文档
- 对应测试文件

### ChatBobi 侧必须同步的文档

- `docs/superpowers-local/LOCAL_RELEASES.md`
- 如有 managed scope 变化：`docs/superpowers-local/MANAGED_FILES.txt`

### changelog 怎么写

`superpowers-fork/changelogs.md` 是 fork 侧发布记录真源。

每次正式发布应至少写清：

- 这版解决什么
- tag 是什么
- 核心 commit 是什么
- 改了哪些模块
- 怎么验证
- 风险和注意点

### LOCAL_RELEASES 怎么写

`docs/superpowers-local/LOCAL_RELEASES.md` 记录的是本机 overlay / backup / deploy 侧历史，不是 GitHub release 替代品。

每次 meaningful 本地受管变更至少写：

- imported upstream version / tag / commit
- local overlay revision
- managed scope
- backup artifact
- local validation target

## 8. MANAGED_FILES.txt 规范

只有出现在下面这个文件里的内容，capture/deploy 才会受管：

```text
/Users/harry/Documents/chatbobi/docs/superpowers-local/MANAGED_FILES.txt
```

规则：

1. 先决定文件是否真的需要长期 deploy
2. 需要的话再加入 `MANAGED_FILES.txt`
3. 加入后，fork、overlay、runtime 三层都要能找到对应文件
4. 如果 fork 里没有该文件，`capture` 会失败

典型坑：

- 只改了 overlay，忘了加到 `MANAGED_FILES.txt`
- 只改了 `hooks.json`，但它不在 managed list 里，deploy 不会生效
- 把 tests 加进 managed list 了，但 fork 中没同步对应测试文件，导致 capture 失败

## 9. 修改时的推荐命令

### 9.1 看 fork 当前状态

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork status --short --branch
git -C /Users/harry/Documents/GitHub/superpowers-fork log --oneline --decorate -n 8
```

### 9.2 先跑 fork 侧测试

示例：

```bash
bash /Users/harry/Documents/GitHub/superpowers-fork/tests/claude-code/test-superpowers-runtime-sync-reminder.sh
```

根据改动范围补跑：

- `test-check-evolution.sh`
- `test-mark-test-acceptance-needed.sh`
- `test-enforce-acceptance-order-trigger.sh`
- `test-stop-gate-quality-fields.sh`
- 其它相关 hook / skill 测试

### 9.3 capture 到 overlay

```bash
cd /Users/harry/Documents/chatbobi
docs/scripts/sync-superpowers-fork.sh capture
```

### 9.4 检查 drift

```bash
docs/scripts/sync-superpowers-fork.sh status
```

你要看的是：

- 哪些文件 `IN_SYNC`
- 哪些文件 `DRIFT`
- 哪些文件 `MISSING_TARGET`

### 9.5 先做 backup

```bash
docs/scripts/manage-superpowers-local.sh backup latest
```

记住生成的：

```text
docs/superpowers-local/backups/superpowers-<version>-<timestamp>.tar.gz
```

### 9.6 deploy 到 installed cache

```bash
docs/scripts/sync-superpowers-fork.sh deploy latest
```

### 9.7 deploy 后再次核对

```bash
docs/scripts/sync-superpowers-fork.sh status
```

正常预期是 managed files 全部 `IN_SYNC`。

### 9.8 黑盒验证

至少做一项：

- 直接跑 installed cache 里的测试脚本
- 或新开真实 Claude Code 会话验证 hook/skill 行为

示例：

```bash
bash ~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/tests/claude-code/test-superpowers-runtime-sync-reminder.sh
```

## 10. GitHub 上传规范

### 10.1 在维护分支提交

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork add <files>
git -C /Users/harry/Documents/GitHub/superpowers-fork commit -m "feat(runtime): <summary>"
```

### 10.2 merge 回 Xia 维护基线

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork checkout xia/cache-package-5.0.7
git -C /Users/harry/Documents/GitHub/superpowers-fork merge --no-ff xia/<topic>-YYYY-MM-DD -m "merge: <summary>"
```

### 10.3 push 分支

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork push origin xia/cache-package-5.0.7
```

### 10.4 打 tag

格式：

```text
sp-v<version>-xia-YYYY-MM-DD-<NN>
```

示例：

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork tag sp-v5.0.7-xia-2026-04-29-01
git -C /Users/harry/Documents/GitHub/superpowers-fork push origin sp-v5.0.7-xia-2026-04-29-01
```

### 10.5 push 后必须核对

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork status --short --branch
git -C /Users/harry/Documents/GitHub/superpowers-fork tag --list 'sp-v5.0.7-xia-*' --sort=-creatordate | head
```

## 11. 如果是跟 upstream 合并

当 `obra/superpowers` 有更新，需要保留 Xia 本地治理规则时：

1. 在 fork 仓库里 `fetch upstream`
2. 检查 `upstream/main` 和当前 Xia 主线差异
3. 在维护分支中 merge 或 cherry-pick
4. 冲突只在 fork 里解，不在 installed cache 里解
5. 跑 fork 侧测试
6. 再走 capture / status / backup / deploy / verify
7. 更新 `changelogs.md`
8. merge、push、tag

常用命令：

```bash
git -C /Users/harry/Documents/GitHub/superpowers-fork fetch upstream
git -C /Users/harry/Documents/GitHub/superpowers-fork log --oneline --decorate --graph --all -n 20
```

## 12. 常见误区

### 误区 1：直接改 installed cache

问题：

- 改完马上能用，但下次刷新 cache 就丢
- Git 历史没有
- 后续没人知道到底改了什么

正确做法：

- 先改 fork
- 再 capture/deploy

### 误区 2：只改 ChatBobi overlay，不改 fork

问题：

- overlay 变成孤儿状态
- 下次 capture 会把你的 overlay 改动覆盖掉
- GitHub 无法追溯

正确做法：

- fork 是主编辑位置
- overlay 只承接受管文件同步

### 误区 3：改了 hooks.json，但忘了 MANAGED_FILES

问题：

- 本地 `.claude/settings.local.json` 看起来生效
- 真正 deploy 到 runtime 时没带上

正确做法：

- 只要要长期跟随 runtime deploy，就把文件纳入 `MANAGED_FILES.txt`

### 误区 4：只 deploy，不 backup

问题：

- 发生坏 deploy 后回滚成本很高

正确做法：

- risky deploy 前先 `backup latest`

### 误区 5：写了功能，不写验证

问题：

- 别的 Agent 不知道怎么复验
- changelog 和 release 记录不可审计

正确做法：

- 测试命令、黑盒步骤、runtime 状态都写进 changelog / LOCAL_RELEASES

## 13. 发布前检查清单

每次发布前，至少确认：

- fork 改动已经完成并通过相关测试
- `changelogs.md` 已更新
- overlay 已 `capture`
- `status` 已检查
- backup 已生成
- deploy 已完成
- installed cache 黑盒验证通过
- `LOCAL_RELEASES.md` 已更新
- 已 commit
- 已 merge 回维护基线
- 已 push branch
- 已打 tag
- 已 push tag

## 14. 最终结论

对任何 Agent 来说，`superpowers` 的正确工作顺序只有这一条：

1. 在 `superpowers-fork` 改
2. 在 fork 里先测
3. 更新 fork 文档与 `changelogs.md`
4. capture 到 ChatBobi overlay
5. backup + status + deploy
6. 在 installed cache / 真实 Claude 会话里验证
7. 更新 `LOCAL_RELEASES.md`
8. commit / merge / push / tag / push tag

如果你发现自己准备直接改下面这个目录：

```text
~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/
```

先停下来。除非这是经过用户批准的紧急 hotfix，否则你大概率已经走偏了。
