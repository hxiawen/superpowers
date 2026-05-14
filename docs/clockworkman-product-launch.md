# Clockworkman：定位摘要与副产品推出清单

> 内部工作稿：把「夏老板线」方法论插件作为**可对外推出的副产品**时，用一页纸对齐叙事与待办。  
> 与上游关系：衍生自 [obra/superpowers](https://github.com/obra/superpowers)（MIT）；推出时须在仓库中保留许可证与致谢（见下文「法务」）。

---

## 1. 一句话定位

**Clockworkman**：面向**真实商业软件**的代理开发**交付管线**——用**版本化文档契约、三验证流、Hook 门禁、审查与演进闭环**，把「能写代码」提升为「**能迭代、能发版、能审计、能运营**」。

---

## 2. 相对官方 Superpowers：五条差异（精要）

| 维度 | 官方 Superpowers（社区版） | Clockworkman（夏老板线） |
|------|---------------------------|---------------------------|
| Spec | 重对话与技能触发，无同等**格式 + 进 Plan 前硬门槛** | **Spec 最小集 + 预检**（如 Affected Paths / Invariants / Figma Diff）与版本目录绑定 |
| 版本 | 无统一 **Vx.y.z + PRn 文件包** 合同 | **六版本文件 + 每 PR 四文件**，与 Stop / 预检联动 |
| 测试 | TDD **哲学与技能**强 | **双轨**：PR `tdd-log` + 版本 `Vx.y.z-test.md` 固定 **`## Acceptance status (hooks)`**；**autotest → mocktest → devicetest**（+ 计划内 Figma 线）；hook **机读** |
| 演进 | 主要 **Issue/PR/社区** | **反馈 → evolution-keeper → 阈值 → 人类 confirm/skip → LESSONS.md** 与技能/hook/测试对齐 |
| 记忆 | 框架**不打包**多层记忆 | **组织记忆**靠版本文档 + LESSONS + feedback；**运行时本能库**非当前核心（可与 ECC 类等互补） |

---

## 3. 相对 ECC 等「大而全 harness」：往哪走

- **不做**：与 Everything Claude Code 等拼「命令数量、跨工具覆盖面、instincts 全家桶」的第一阶段目标。  
- **要做**：**版本化交付 + 证据链 + 验收门禁 + 责任分界** 的**可引用标准**；必要时在文档中写清**与 ECC 并存**的推荐姿势。  
- **叙事**：Clockworkman = **SDLC 合同与发版纪律**；不是又一个通用聊天写代码包。

---

## 4. 副产品推出：要做哪些事（清单）

下列按**依赖顺序**排列；可多人并行，但「法务与命名」应尽早冻结。

### 4.1 战略与叙事

- [ ] **受众定义**：技术小白 / 个人极客 / 小团队 / 是否含「必须上发版流水线」的企业场景。  
- [ ] **承诺边界**：开源核心功能 vs 商业支持 vs 仅文档；**不承诺**与 ChatBobi 商业条款混谈。  
- [ ] **一页官网级文案**：问题 → 方案 → 三条证据（版本树、三验证、LESSONS）。  
- [ ] **与上游关系声明**：致谢 Jesse Vincent / obra/superpowers；MIT；**非**官方 Superpowers。

### 4.2 法务与合规

- [ ] **LICENSE**：保留 MIT 全文；衍生作品版权与年份。  
- [ ] **NOTICE / THIRD_PARTY**：列出上游版权与仓库链接。  
- [ ] **商标用语**：对外称 Clockworkman；避免暗示 Anthropic/obra **背书**；不抢注冲突商标前先做检索（可选律师）。  
- [ ] **隐私**：若未来有遥测/官网表单，单独隐私说明；默认**无**遥测更安全。

### 4.3 品牌与技术命名（工程）

- [ ] **仓库与插件 id**：GitHub 名、marketplace 插件名、`clockworkman:*` 等前缀的**对照表**与**迁移/别名期**策略。  
- [ ] **全仓替换计划**：Skills / Hooks / 命令 / Agents / 文档 / 测试断言 / 产品仓 overlay 脚本名（如 `sync-*.sh`）。  
- [ ] **破坏性变更公告**：旧命令/旧技能 id 的**截止移除日期**。

### 4.4 仓库与工程卫生

- [ ] **默认分支与标签策略**：`main` / 发版分支 / `sp-*` 或 `cw-*` tag 命名规范。  
- [ ] **CI**：最小集——shell 测试、关键 hook 契约、禁止回归的 grep（旧前缀、错误 acceptance 标题等）。  
- [ ] **贡献指南**：替换 upstream 的「拒 fork PR」语境为 **Clockworkman 自己的** PR 标准与范围。  
- [ ] **安全**：依赖与 hook 脚本审计说明；敏感路径不写进公开示例。

### 4.5 文档体系（用户 vs 维护者）

- [ ] **5 分钟上手**：安装 → 开一个 `Vx.y.z` 目录 → 跑通一次最小验收路径。  
- [ ] **参考手册**：Runtime Sync（或更名后）三层、MANAGED_FILES、LOCAL_RELEASES。  
- [ ] **Hook 专章**：事件、顺序、`## Acceptance status (hooks)` 约定、常见阻断与自愈。  
- [ ] **与 ECC/Cursor/Claude 并存**：推荐目录结构与冲突避免（rules、hooks 覆盖顺序）。  
- [ ] **升级指南**：从 Superpowers 官方 / 从旧 fork 名 → Clockworkman 的步骤。

### 4.6 分发与安装

- [ ] **Claude Code**：marketplace 条目、安装命令、`plugin` 元数据（`.claude-plugin` 等）。  
- [ ] **Cursor**：若支持：marketplace 或手动安装说明；hooks-cursor 差异写清。  
- [ ] **版本与 changelog**：对用户可见的 **changelog**（可与内部 `changelogs.md` 策略对齐）。  
- [ ] **缓存路径说明**：安装后目录位置、与 `deploy` 脚本的关系。

### 4.7 与主产品（如 ChatBobi）的关系

- [ ] **仓库分离**：Clockworkman **通用**文档默认无 ChatBobi 专有路径；专用技能可 **optional 插件** 或 **示例仓**。  
- [ ] **产品仓只保留**：overlay、sync 脚本指针、LOCAL_RELEASES；避免外界误以为 ChatBobi 闭源部分是 Clockworkman 必需依赖。

### 4.8 社区与运营（若走开源）

- [ ] **Issue 模板**：bug / 功能 / 仅提问。  
- [ ] **行为准则**（可选）：CODE_OF_CONDUCT 是否沿用、是否简化。  
- [ ] **讨论区**：Discussions 或 Discord 二选一即可，避免空转。  
- [ ] **发布节奏**：例如「稳定 tag + 迁移说明」双周或按月。

### 4.9 发布日检查（Go / No-Go）

- [ ] 干净 clone + 按文档装插件 + 跑通 **一次** 三验证写入与 Stop gate。  
- [ ] 随机抽 3 个 hook 脚本 **无**硬编码夏老板本机路径。  
- [ ] LICENSE + NOTICE 在发布包内可见。  
- [ ] 旧名搜索：发布分支上无 **意外** 遗留品牌/路径（允许的除外：致谢、迁移表）。

---

## 5. 建议时间顺序（精要）

1. **冻结**：品牌名、许可证页、与上游表述。  
2. **改名与 CI**：工程可重复构建与测试绿。  
3. **用户文档 + 安装**：外人能 30 分钟跑通最小路径。  
4. **市场/仓库公开 + tag**：首次「公开预览」或正式版。  
5. **与 ECC 等联合说明**：减少「重复造轮子」质疑，吸引对的人。

---

## 6. 开源结论

Clockworkman **可以**作为 **MIT 开源项目**推出；条件是 **保留上游 MIT 义务**（版权与许可文本），并用 **NOTICE** 说明衍生关系。开源不妨碍其作为夏老板**副产品**——核心是**边界与叙事**是否清晰，而非许可证是否封闭。
