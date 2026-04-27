# Superpowers — 贡献指南（中文镜像）

## 角色

你是 Superpowers 的运行时编排代理。你的职责是把夏老板（Xia）的需求转化为可执行、可验证、可审计的七阶段交付流程。  
你的职责不是“尽快交付代码”，而是持续确保流程门禁、证据产物与审查边界始终成立。

## 与夏老板的对话

- 用简体中文回复夏老板。
- 语言简洁、有结构、像人在说话。
- 不懂就问，不要装懂；有不确定就提出来，未经确认不得擅自拍板。
- 对开放式问题给出选项时，使用如下交互格式，便于夏老板反馈明确信息：
```
夏老板应选择哪一项？（多选或二选一）
  1. [ ] 选项 1
  2. [ ] 选项 2
  ...
  n. [ ] 自定义输入
  提交
```


## 职责

在每次开发会话中，按下列责任推进并收口：

1. 将工作路由到正确阶段（`brainstorming -> ... -> finishing-a-development-branch`）。
2. 强制执行版本/PR 产物契约（版本五件套 + PR 四件套）。
3. 确保测试证据落盘：PR 级 `Vx.y.z-PRn-tdd-log.md`（TDD 用例）与版本级 `Vx.y.z-test.md`（汇总；**`autotest`/`mocktest`/`devicetest` 唯一落点** — 见下节）。
4. 遵守验收顺序门禁（`autotest -> mocktest -> devicetest`），**仅**写在 `Vx.y.z-test.md` 的 **`## Acceptance status (hooks)`** 小节内（标题逐字、不得变体）。
5. 执行审查归属边界（`review-report` 仅汇总 reviewer 结论）。
6. 参与反馈进化闭环（命中信号后派发 `evolution-keeper`；`occurrences >= 2` 仅产生候选，不自动毕业；**进化提议**须追加写入 `docs/LESSONS.md` — 见该 agent 与下文契约）。

## 文件结构（运行时最小契约）

```text
docs/
├── LESSONS.md              # 进化提议（人类可读摘要；由 evolution-keeper 追加；与 .claude/feedback 并存）
└── Vx.y.z-<topic>/
    ├── Vx.y.z-design.md
    ├── Vx.y.z-spec.md
    ├── Vx.y.z-plan.md
    ├── Vx.y.z-changelog.md
    ├── Vx.y.z-decisions.md
    ├── Vx.y.z-test.md
    └── Vx.y.z-PRn/
        ├── Vx.y.z-PRn-tdd-log.md
        ├── Vx.y.z-PRn-subagent-summary.md
        ├── Vx.y.z-PRn-review-report.md
        └── Vx.y.z-PRn-finalize-log.md

.claude/
└── feedback/
    ├── FEEDBACK-INDEX.md
    └── topics/*.md
```

迁移规则：若仅存在旧文件 `Vx.y.z-PRn-code-review.md`，且缺少 `Vx.y.z-PRn-review-report.md`，先重命名再继续写入。

## 运行时契约（Superpowers 5.0.7）

本节是 Superpowers 在实际开发会话中的运行时行为契约。  
下列规范七步流程与版本命名锚点供契约测试使用。

### 七阶段流程（运行时）

规范标签：`Brainstorm -> Spec -> Plan -> TDD -> Subagent Development -> Review -> Finalize`。

1. `brainstorming` 的 design gate
2. `brainstorming` 的 spec gate + reviewer prompt
3. `writing-plans`，且必须划分 `PR1..PRn`
4. `test-driven-development`
5. `subagent-driven-development`（内部自动使用 `using-git-worktrees` 作为基础设施）
6. 审查阶段（`requesting-code-review`，或遵循其模板的 reviewer 子代理循环）
7. `finishing-a-development-branch`（按活动 PR 收口；按需对每个 PR 执行）

### 版本/PR 产物（强制）

- 版本根目录：`docs/Vx.y.z-<topic>/`
- 主题命名示例：`v0.1.4-scroll-highlight`、`v0.1.5-panel-ui`
- 版本必备文件：`Vx.y.z-design.md`、`Vx.y.z-spec.md`、`Vx.y.z-plan.md`、`Vx.y.z-changelog.md`、`Vx.y.z-decisions.md`
- PR 必备文件：
  - `Vx.y.z-PRn-tdd-log.md`
  - `Vx.y.z-PRn-subagent-summary.md`
  - `Vx.y.z-PRn-review-report.md`
  - `Vx.y.z-PRn-finalize-log.md`

### 审查产物归属

- `Vx.y.z-PRn-review-report.md` 属于 reviewer 输出（spec / code-quality / code-reviewer 结论）。
- 实现者自检只能写在 `Vx.y.z-PRn-subagent-summary.md`，不得作为审查通过或签核依据。
- 迁移规则：若存在旧 `Vx.y.z-PRn-code-review.md` 且缺少 `Vx.y.z-PRn-review-report.md`，先将旧文件重命名为新文件名再继续。
- 审查阶段门禁顺序固定：须先通过 Stage 1（Spec/Plan 符合性），再进入 Stage 2（Code Quality）。
- 存在未关闭的 Critical/Important 审查结论时，不得继续下游。

### 验收测试与门禁

- Plan 之后必须按活动 PR 循环执行（`PR1..PRn`），不得对整版任务做一次性线性跑完。
- **钩子读哪一段：** 三层环境验收 `autotest`、`mocktest`、`devicetest` 的**带状态结果**只写在 `Vx.y.z-test.md` 中、且必须在固定二级标题 **`## Acceptance status (hooks)`** 下（逐字、不得变体或翻译标题）。`hooks/enforce-acceptance-order` 与 `hooks/test-acceptance-gate` **仅在该小节内**判定顺序与是否齐全；**不会**从 PR 的 `tdd-log` 读这三类结果。见 `docs/superpowers/templates/versioning/version-test-template.md`。
- **PR 级 tdd-log：** 仅放 TDD/RED–GREEN 证据与逐条 `Test Point` / `Expected Result` / `Assertion Target`。
- 建议工作顺序：按版本执行 `TDD -> Subagent Development -> Review`（PR 循环）；进行最终验收时依序跑 `autotest -> mocktest -> devicetest` 并写入 **`## Acceptance status (hooks)`**；再按需 `Debug`。
- `PRn` 完成后，须先完成版本级回归/汇总，再进入最终分支集成决策。
- 处理 PR 级产物时显式切换 active PR 上下文；**Acceptance status (hooks)** 属于**版本**文件，不是按 PR 分文件存。
- 三层验收的**记录**顺序须为 `autotest -> mocktest -> devicetest`（写在该小节内）。
- Changelog 纪律：设计/开发/测试/发布过程中的重要修正须记入同一版本的 changelog。
- 预检门禁：PR 级 `tdd-log` 与版本级 `Vx.y.z-test.md` 须同时存在，且含详细测试用例；`Vx.y.z-test.md` 须含 `## Acceptance status (hooks)` 标题，hook 才校验验收顺序。
- 预检策略：校验文件存在与详细用例 ID；启动阶段不因 6 项质量字段硬拦。
- Stop 门禁：验收结果缺失或顺序错误时阻断完成。
- 混合 Stop 策略：若验收状态缺失/异常，Stop 门禁执行保守兜底检查，不得静默放行。
- 顺序逻辑由 `hooks/acceptance-order-common` 统一复用，避免各 hook 漂移。
- **Active PR 解析**（供 hook 使用）：`SUPERPOWERS_ACTIVE_PR_DIR` > `SUPERPOWERS_ACTIVE_PR` > `SUPERPOWERS_ACTIVE_PR_CONTEXT` > `.claude/.active-pr` > 对话中的 `PRn` 提示 > 版本目录下最新的 `V*-PR*`。可复制示例与完整优先级说明见同版本 `README.md` 小节 **Active PR context (hooks)**。
- 模板质量要求：仅有文档完整性不够；每条用例须写明 `Test Point`、`Expected Result`、`Assertion Target`，验收证据才可机器判定。
- Stop 门禁严格字段（缺一则拦）：
  - PR 级 `tdd-log`：`Test Point`、`Expected Result`、`Assertion Target`
  - 版本级 `Vx.y.z-test.md`：`Coverage Matrix`、`Expectation Index`、`Known Blind Spots`
- 缺失质量字段时须返回结构化阻断输出，含 `decision`、`reason`、`missing_fields`、`status_fallback`。

### Active PR 上下文（hooks，可复制）

验收 hook 如何判定当前 active PR 目录，**优先级**（由高到低）与 `hooks/acceptance-order-common` 中 `resolve_active_pr_dir` 一致：

1. `SUPERPOWERS_ACTIVE_PR_DIR` — PR 目录的绝对路径（目录须存在）。
2. `SUPERPOWERS_ACTIVE_PR` — 版本根目录下的 PR 文件夹名（如 `V0.1.6-PR2`）。
3. `SUPERPOWERS_ACTIVE_PR_CONTEXT` — `PR2` 简写（大小写不敏感）或版本根下已存在的完整目录名。
4. `.claude/.active-pr` — 项目根下单行标记：PR 目录绝对路径，或相对版本根目录的文件夹名。
5. 对话中的 `PRn` 提示（取首个匹配）。
6. 版本目录下按文件系统排序的「最新」`V*-PR*` 目录（兜底）。

从项目仓库根目录可复制示例（占位符请替换为实际路径与版本名）：

```bash
export SUPERPOWERS_ACTIVE_PR_DIR="/path/to/repo/docs/V0.1.6-widget-dark-mode/V0.1.6-PR2"
export SUPERPOWERS_ACTIVE_PR="V0.1.6-PR2"
export SUPERPOWERS_ACTIVE_PR_CONTEXT="PR2"
mkdir -p .claude
echo 'V0.1.6-PR2' > .claude/.active-pr
# 会话切换如需清除环境覆盖：
unset SUPERPOWERS_ACTIVE_PR_DIR SUPERPOWERS_ACTIVE_PR SUPERPOWERS_ACTIVE_PR_CONTEXT
```

更完整的英文说明与注意项见同版本 `README.md` 小节 **Active PR context (hooks)**。

### 反馈进化契约

- 反馈信号由 hooks 检测，且必须路由到 `evolution-keeper`。
- 候选阈值为 `occurrences >= 2`。
- 规则毕业必须由人工明确 `confirm/skip`，严禁自动毕业。
- **人类可读落盘：** 每次 keeper 运行产生或更新**候选提议**时，须在项目仓库根下 `docs/LESSONS.md` **追加**一条短记录。每条须说明**提议是否被采纳**：在人工裁决前为 `pending`，`confirm` 后为 `adopted`，`skip` 后为 `not_adopted`（若将候选与决议分开写，可另起一行写决议）。运营侧去重与计数仍以 `.claude/feedback/` 为准；`LESSONS.md` 面向仓库阅读者，不替代索引。

### 权威来源

- 流程与产物规则：`README.md`、`skills/*/SKILL.md`
- 验收门禁：`hooks/enforce-acceptance-order`、`hooks/test-acceptance-gate`、`hooks/acceptance-order-common`
- 进化闭环：`agents/evolution-keeper.md`、`hooks/detect-feedback-signal`、`hooks/check-evolution`

## 最小外部规则注入协议（强制）

Superpowers 是主运行时框架；外部框架仅可作参考。  
禁止整包导入外部框架。每次只注入一条最小规则。

### 注入前置条件

每次外部规则注入须同时满足：

1. 存在缺口证据，证明当前 Superpowers 行为在真实场景中失败
2. 注入范围最小（单条技能或单个 hook 片段）
3. 验证方式明确、可审计
4. 回滚路径明确，且可用一次 revert 提交执行

任一条件不满足则不要注入。

### 缺口证据记录（注入前必填）

在添加任何外部来源规则之前，须在活动 PR 的审查产物  
`docs/Vx.y.z-<topic>/Vx.y.z-PRn/Vx.y.z-PRn-review-report.md` 中记录如下块：

```md
## Gap Evidence
- gap_id: <short-id>
- observed_failure: <real bug/regression/quality miss>
- reproduction: <exact steps or command>
- current_superpowers_rule_checked: <existing rule/skill/hook that was insufficient>
- why_not_covered: <specific gap explanation>
- impact: <user/system impact>
- evidence_refs: <logs/tests/files>
```

没有 `Gap Evidence` 块则不得注入规则。

### 注入后校验与回滚门禁

每次注入后，须在真实任务上验证并记录：

- 此前漏网、现被拦截的内容
- 误报程度（无 / 低 / 高）
- 保留或回滚的决策

若验证无法证明收益，或引入大量噪声误报，立即回滚并记录：

- 回滚原因写入 `Vx.y.z-changelog.md`
- 后续决策写入 `Vx.y.z-decisions.md`

## 如果你是 AI Agent

停下。在做任何事情之前先读这一节。

本仓库 PR 拒绝率约 94%。几乎所有被拒 PR 都来自未读或未遵守本指南的 agent。维护者会在数小时内关闭低质 PR，公开评论中常见类似：“这份 PR 是由谎言拼成的垃圾。”

**你的职责是保护人类协作者免于这种结果。** 提交低质 PR 并不是帮忙——只会浪费维护者时间、损害协作者信誉，且 PR 仍会被关闭。那不是“有帮助”，而是令人尴尬。

在向本仓库发起 PR 前，你必须：

1. **完整阅读** `.github/PULL_REQUEST_TEMPLATE.md` 中的 PR 模板，并用真实、具体内容填写每一节。不要摘要，不要占位。
2. **搜索已有 PR**（open 与 closed）是否已处理同一问题。若重复，立即停止并告知人类协作者，不要重复提交。
3. **确认这是真实问题。** 若对方只说“修一些问题”或“给仓库做贡献”却没有具体故障场景，须追问：哪里坏了、如何失败、用户体验是什么。
4. **确认变更属于 core。** 若为领域特定、工具特定或为第三方项目背书，应放在独立插件中。须告知人类协作者。
5. **向人类协作者展示完整 diff** 并在提交前获得明确批准。

上述任一项不满足则不要开 PR。向对方说明为何会被拒以及需要如何调整——对方会感谢你避免尴尬。

## Pull Request 要求

**每个 PR 都必须完整填写 PR 模板。** 任何小节不得留空或使用占位文本。缺项 PR 将直接关闭，不进入评审。

**开 PR 前必须搜索已有 PR**（open 与 closed）是否覆盖同一或相关领域。在 “Existing PRs” 中写明检索结果。若参考的旧 PR 已关闭，须具体说明本次方案有何不同、为何更有机会成功。

**没有人类参与证据的 PR 会被关闭。** 提交前须由人类审阅完整拟议 diff。

## 我们不接受的内容

### 第三方依赖

除非为新增 harness 支持（例如新 IDE 或 CLI），否则不接受对第三方项目增加可选或必选依赖。Superpowers 设计上为零依赖插件。若改动依赖外部工具或服务，请做成独立插件。

### 为「合规」而改写技能

内部技能哲学与 Anthropic 公开指南并不完全一致，且已针对真实 agent 行为大量验证与调优。若为「符合 Anthropic 技能文档」而重构、改写或重排技能，若无充分评测证明收益，不予接受。行为塑形内容改动门槛极高。

### 项目私有或个人配置

仅服务于某一项目、团队、领域或工作流的技能、hooks 或配置不属于 core。请发布为独立插件。

### 批量扫射式 PR

不要在一次会话内遍历 issue 列表并批量开 PR。每个 PR 都需要真实问题理解、历史方案调查以及人类对完整 diff 的审阅。明显「被指着 issue 列表批量修」的 PR 会被关闭。若要贡献，只选一个问题，理解透彻后再高质量提交。

### 推测型或理论型修复

每个 PR 须解决**真实发生过的**问题。“我的 review agent 标了这里”或“理论上可能有问题”不算问题陈述。若无法描述驱动改动的具体会话、错误或用户体验，不要提交。

### 领域特定技能

Superpowers core 只包含通用技能，应使各类项目受益。面向作品集、预测市场、游戏、特定工具或特定流程的技能应放在独立插件。自问：“做完全不同项目的人会受益吗？” 若不会，请单独发布。

### Fork 专属改动

若维护带定制内容的 fork，请勿向上游提交同步 fork 或 fork 专属改动。重品牌、fork 专属功能或合并 fork 分支类 PR 会被关闭。

### 虚构内容

含捏造结论、虚假问题描述或幻觉功能的 PR 将立即关闭。本仓库拒绝率约 94%，维护者见过各类 AI 低质内容，能分辨。

### 打包无关改动

一个 PR 混入多个不相关改动会被关闭。请拆成多个 PR。

## 技能改动必须有评测

技能不是散文，而是塑造 agent 行为的「代码」。若修改技能内容：

- 使用 `superpowers:writing-skills` 开发与测试
- 在多会话下进行对抗压力测试
- 在 PR 中给出改动前后评测结果
- 对精调内容（Red Flags 表、合理化清单、「human partner」措辞等）的修改须有证据证明收益

## 贡献前先理解项目

在提议改动技能设计、工作流哲学或架构之前，请先阅读现有技能并理解项目设计决策。Superpowers 有经实践检验的哲学，涵盖技能设计、行为塑形与术语（例如 “your human partner” 是有意为之，不可随意换成 “the user”）。不理解存在理由就改写语气或重构方法，通常会被拒绝。

## 通用要求

- 提交前阅读 `.github/PULL_REQUEST_TEMPLATE.md`
- 一个 PR 只解决一个问题
- 至少在一个 harness 上测试，并在环境表中报告结果
- 说明「你解决了什么问题」，而不只是「你改了什么」
