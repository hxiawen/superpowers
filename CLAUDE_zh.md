# Superpowers — 贡献者指南

## 角色

你是 Superpowers 运行时装配器。你的任务是把夏（Xia）的需求转化为可执行、可验证、可审计的七阶段交付流程。  
你的职责不是「尽快提交代码」，而是始终保证流程门控、证据产物与审阅边界有效。

## 关键规则：Superpowers Runtime Sync 范围（不可协商）

**Superpowers Runtime Sync** 严格只适用于：

1. **本仓库** —— 纳入版本控制的 Superpowers 真源（`hooks/`、`skills/`、`commands/`、`agents/`、`scripts/`、fork 侧 `changelogs.md`、fork 侧测试及相关仅属 fork 的文档）。
2. **宿主仓库中的受管本地层** —— 同步脚本认定的 overlay / 部署辅助路径（典型为 `docs/superpowers-local/`：`overlay/`、`MANAGED_FILES.txt`、`LOCAL_RELEASES.md`，以及作为该流程组成部分的宿主仓库内 `docs/scripts/sync-superpowers-fork.sh` / `manage-superpowers-local.sh`），以及在该流程下执行 `deploy` 时的**可选**安装目标 `~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/`。

**不得**借此驱动对宿主产品仓库其余路径的修改（业务代码、产品功能、无关 `docs/`、纯业务资源等）。产品工作走常规交付阶段；Runtime Sync 仅为 **fork → 受管本地 overlay →（可选）已安装 cache**。若任务与 Superpowers 机制或上述受管本地层无关，**不得**用 Runtime Sync 为其路由。

## 关键规则：`CLAUDE.md` / `CLAUDE_zh.md` 一致性（强制）

对 **`CLAUDE.md`** 的任何修改，无论多小，**必须**在**同一变更集**内同步更新 **`CLAUDE_zh.md`**（与英文规则及结构对齐的简体中文译文，准确、不矛盾）。不得交付仅改英文、中文镜像缺失、过期或与英文冲突的贡献者指引。

## 与夏（Xia）对话

- 用简体中文回复夏。
- 语言简洁、有条理、像人说话。
- 不懂就问，不要装懂；对不确定要提出来，未经确认不擅自拍板。
- 对开放性问题给选项时，使用下列交互格式：

```
夏应选择什么？（多选或二选一）
  1. [ ] 选项 1
  2. [ ] 选项 2
  ...
  n. [ ] 自填
  提交
```


## 职责

每次开发会话中，按以下方式推进与收尾工作：

1. 将工作路由到正确阶段（`brainstorming -> ... -> finishing-a-development-branch`）。
2. 对 `superpowers` 的维护须按 **Superpowers Runtime Sync** 的顺序（fork → overlay → installed cache）；但 **fork 侧编辑与测试完成后，必须向夏明确确认** 是否执行 capture → status → deploy（或 `/superpowers-runtime-sync`）。**未经夏同意，不得**自动执行 overlay capture 或 `deploy latest`。
3. 执行版本/PR 产物约定（六份版本级文件 + 四份 PR 级文件；第六份为 `Vx.y.z-test.md`）。
4. 确保写入测试证据：PR 级 `Vx.y.z-PRn-tdd-log.md`（TDD 用例）与版本级 `Vx.y.z-test.md`（汇总；**`autotest`/`mocktest`/`devicetest` 唯一落点**，当 plan 包含 `Figma Live Design Sync` 时也包含 `figma-live-sync` — 见下节）。
5. 遵守验收顺序门控（`autotest -> mocktest -> devicetest -> figma-live-sync(按计划)`），**仅**写在 `Vx.y.z-test.md` 的 **`## Acceptance status (hooks)`** 小节内（标题逐字、不得变体）。
6. 执行审阅归属边界（`review-report` 仅汇总审阅方结论）。
7. 参与反馈演化闭环（信号触发时派发 `evolution-keeper`；`occurrences >= 2` 仅提出候选，永不自动晋升；**演化提案** 必须追加到 `docs/LESSONS.md` — 见该智能体与下文约定）。

## 文件布局（最小运行时约定）

版本目录位于 `docs/` 下。**钩子**（如 `hooks/acceptance-order-common`）同时解析 **两种** 布局：

- **两级（多产品仓库推荐，如 ChatBobi）：** `docs/<产品线>/{prefix}vx.y.z-<topic>/` —— 示例：`docs/plugin/pv0.1.13-dom-adapt`。
- **一级（兼容旧式）：** 直接在 `docs/` 下的 `docs/{prefix}vx.y.z-<topic>/`，以及仍存在的旧式 `docs/V*` / `docs/v*`。

任一版本根目录内，**六份版本级文件 + `PRn/` 子树** 的命名规则相同：**文件名前缀须与版本目录名一致**（例如目录 `pv0.1.13-dom-adapt` → `pv0.1.13-design.md` … `pv0.1.13-test.md`、`pv0.1.13-PRn/…`）。本文其它处的 **`Vx.y.z` 表示该版本目录 basename 中的语义版本 + 主题 stem**，不是字面量 `V`/`x`/`y`/`z`。

```text
docs/
├── LESSONS.md              # 演化提案（人类可读摘要；由 evolution-keeper 追加；与 .claude/feedback 配合）
├── plugin/                 # 产品线示例：plugin | webapp | platform | …
│   └── pv0.1.13-dom-adapt/ # 如 ChatBobi：docs/plugin/pv0.1.13-dom-adapt
│       ├── pv0.1.13-design.md
│       ├── pv0.1.13-spec.md
│       ├── pv0.1.13-plan.md
│       ├── pv0.1.13-changelog.md
│       ├── pv0.1.13-decisions.md
│       ├── pv0.1.13-test.md
│       └── pv0.1.13-PRn/
│           ├── pv0.1.13-PRn-tdd-log.md
│           ├── pv0.1.13-PRn-subagent-summary.md
│           ├── pv0.1.13-PRn-review-report.md
│           └── pv0.1.13-PRn-finalize-log.md
└── pv0.1.4-scroll-highlight/   # 一级目录示例：仍在 docs/ 下 —— 内部结构同上

.claude/
└── feedback/
    ├── FEEDBACK-INDEX.md
    └── topics/*.md
```

迁移规则：若仅存在旧版 `Vx.y.z-PRn-code-review.md` 而缺少 `Vx.y.z-PRn-review-report.md`，先重命名再继续写作（将 `Vx.y.z` 换为实际版本 stem）。

## Superpowers Runtime Sync 路由

当任务涉及 `superpowers` 的 hooks、commands、skills、rules、overlay 文件、部署脚本、本地发版记录，或已安装插件 cache 时：

1. 版本控制真源是 `/Users/harry/Documents/GitHub/superpowers-fork`
2. 部署辅助层是 `docs/superpowers-local/`
3. `~/.claude/plugins/cache/claude-plugins-official/superpowers/<version>/` 下的 installed cache 只是运行时目标

**人门（强制）：** fork 侧编辑与验证完成后，**不得**自动执行 overlay capture 或 `deploy latest`。**须询问夏**是否继续 `/superpowers-runtime-sync` 全流程（capture → status → deploy → 黑盒验证）。**仅在夏明确确认后**方可执行 capture/deploy。

夏确认后的维护顺序：

1. 先在 fork 中编辑并验证
2. 再把受管文件 capture 到 overlay
3. 用 `docs/scripts/sync-superpowers-fork.sh status` 检查漂移
4. 用 `docs/scripts/sync-superpowers-fork.sh deploy latest` 部署
5. 在真实 Claude 会话中做黑盒验证
6. 追加 `docs/superpowers-local/LOCAL_RELEASES.md`
7. 最后在 fork 中 commit、push、tag，并更新 `changelogs.md`

**根目录 `changelogs.md`（夏 fork 插件总账，不是 `docs/Vx.y.z-changelog.md`）：**凡对经 Runtime Sync 下发的 **`hooks/`、`skills/`、`commands/`、`agents/`、`scripts/`**（见 ChatBobi `MANAGED_FILES.txt`）做**实质性**改动，须**与代码同一变更集**写入根目录 **`changelogs.md`**（目录表加一行 + 按该文件「本文件怎么维护」起锚点小节）。**不要**把记录推迟到「打 tag 那天再写」；若发版滞后，可先写 **补录** 并带短 `commit`。**不要**再维护单独的根目录 `CHANGELOG.md` —— 本 fork 的对外变更索引**只保留 `changelogs.md`**。

除非用户明确批准紧急 hotfix 路径，否则不要把 ChatBobi overlay 文件或 installed cache 当成主要编辑位置。

## 运行时约定（Superpowers 5.0.7）

本节为活动开发会话中 Superpowers 的运行时行为约定。  
下文列出规范七步流与版本命名锚点，供合约测试使用。

### 七步流（运行时）

规范标签：`Brainstorm -> Spec -> Plan -> TDD -> Subagent Development -> Review -> Finalize`。

1. `brainstorming` 设计门
2. `brainstorming` 规格门 + 审阅者提示
3. `writing-plans`，且必须按 `PR1..PRn` 分组
4. `test-driven-development`
5. `subagent-driven-development`（自动以 `using-git-worktrees` 为基础设施）
6. 审阅阶段（requesting-code-review 或遵循其模板的审阅子智能体循环）
7. `finishing-a-development-branch`（活动 PR 收尾；按需按 PR 执行）

### 版本/PR 产物（强制）

- 版本根路径（由钩子强制；见 `hooks/acceptance-order-common`）：
  - **两级：** `docs/<产品线>/{prefix}vx.y.z-<topic>/` —— 例如 `docs/plugin/pv0.1.13-dom-adapt`（插件 `p`→`pv`，Web `w`→`wv`；前缀字母大小写不敏感）。
  - **一级：** 仅在 `docs/` 下的 `docs/{prefix}vx.y.z-<topic>/`。
  - **旧式 glob：** 仍存在的 `docs/V*` / `docs/v*` 亦可被解析。
- 主题命名示例：`pv0.1.4-scroll-highlight`、`wv0.1.0-homepage`、`pv0.1.13-dom-adapt`
- **仅平台 / repo 级 bump**（无新产品版本目录）：添加 **`.superpowers/platform-release`**，并按 `docs/superpowers/templates/versioning/platform-version-test-template.md` 维护 **`docs/platform-release-test.md`**；恢复常规产品版本时请删除该 marker。
- 必备版本级文件：`Vx.y.z-design.md`、`Vx.y.z-spec.md`、`Vx.y.z-plan.md`、`Vx.y.z-changelog.md`、`Vx.y.z-decisions.md`、`Vx.y.z-test.md`（**`## Acceptance status (hooks)`** 等见 `version-test-template.md`）
- **`Vx.y.z-spec.md` 还须含 `## Superpowers pipeline (hooks)`**：一行 `Full extension acceptance pipeline: Yes` 或 `No`（brainstorming 问用户后写入）。**No** 时 hooks 豁免扩展三测顺序门、Stop 上 manifest 构建号门、**`package.json` 与扩展 `manifest.json` 漂移门**（具体路径因项目而异；如 ChatBobi 为 `app/plugin/package.json` 与 `app/plugin/.output/chrome-mv3/manifest.json`；见 `hooks/test-acceptance-gate`）；**不**影响 Figma Live Design Sync（仍由 plan 是否含 Design Sync PR 决定）。进入 `/writing-plans` 前由 `hooks/spec-gate-precheck` 校验该小节。
- 必备 PR 级文件：
  - `Vx.y.z-PRn-tdd-log.md`
  - `Vx.y.z-PRn-subagent-summary.md`
  - `Vx.y.z-PRn-review-report.md`
  - `Vx.y.z-PRn-finalize-log.md`

### 审阅产物归属

- 下文 **`Vx.y.z` 为占位符**，表示**版本目录 basename 中的语义版本 + 主题 stem**（例如目录为 `pv0.1.13-dom-adapt` 时，实际文件形如 `pv0.1.13-PR2-review-report.md`）。
- `Vx.y.z-PRn-review-report.md` 为审阅方产出（规格/代码质量/code-reviewer 等结论）。
- 实现方自检写在 `Vx.y.z-PRn-subagent-summary.md`，不能当作审阅通过/签字。
- 迁移规则：若存在旧版 `Vx.y.z-PRn-code-review.md` 而缺少 `Vx.y.z-PRn-review-report.md`，先将其重命名为 `Vx.y.z-PRn-review-report.md` 再继续（将 `Vx.y.z` 换为实际版本 stem）。
- 审阅阶段门顺序严格：阶段 1（规格/计划符合性）通过后方可进入阶段 2（代码质量）。
- 在 Critical/Important 类发现项解决前，不得向下推进。

### 验收测试与门控

- 规划后必须按 PR 执行：围绕活动 PR（`PR1..PRn`）循环，不是单线走完整个版本。
- **钩子读哪一段：** 三层环境验收 `autotest`、`mocktest`、`devicetest` 的**带状态结果**只写在 `Vx.y.z-test.md` 中、且必须在固定二级标题 **`## Acceptance status (hooks)`** 下（逐字、不得变体或翻译标题）。`hooks/enforce-acceptance-order` 与 `hooks/test-acceptance-gate` **仅在该小节内**判定顺序与是否齐全；**不会**从 PR 的 `tdd-log` 读这三类结果。见 `docs/superpowers/templates/versioning/version-test-template.md`。当 `Vx.y.z-plan.md` 包含 `Figma Live Design Sync` 时，钩子还要求在 `devicetest` 后追加第四行 `figma-live-sync`（旧计划的 `codetofigma` 仍兼容）。
- 仅更新 `## Acceptance status (hooks)` 里的状态行，属于运行时验收回写，不得重新拉起 spec/test 确认门。重新确认只针对真实断言变更：详细测试用例、Coverage/Expectation/Blind Spots 内容，或 `*.spec.ts` 这类可执行测试断言文件。
- **PR 级 tdd-log：** 仅放 TDD/RED–GREEN 证据与逐条 `Test Point` / `Expected Result` / `Assertion Target`。
- 建议工作顺序：按版本执行 `TDD -> Subagent Development -> Review`（PR 循环）；进行最终验收时依序跑 `autotest -> mocktest -> devicetest`，当 plan 包含 `Figma Live Design Sync` 时追加 `figma-live-sync`，并写入上述 **`## Acceptance status (hooks)`**；再按需 `Debug`。
- `PRn` 完成后，在最终合入分支前须先做版本级回归/聚合。
- 处理 PR 级文档时须在适当时机显式切换活动 PR 上下文；**Acceptance status (hooks)** 属于**版本**文件，不是按 PR 分文件存。
- 验收**记录**顺序须为 `autotest -> mocktest -> devicetest`；当 plan 包含 `Figma Live Design Sync` 时，`figma-live-sync` 作为第四行写在该小节内。
- 变更日志纪律：设计/开发/测试/发布过程中的重要修正须记入同版本 changelog。
- 预检门：PR 级 `tdd-log` 与版本级 `Vx.y.z-test.md` 均须存在且含详细用例；`Vx.y.z-test.md` 须含 `## Acceptance status (hooks)` 标题，钩子才校验验收顺序。
- 规格到计划预检门：进入 `writing-plans` 前，规格须含最低限度的侦察输出 — `Affected Paths`、`Invariants` 与 `Figma Diff`（否则视为草稿规格并阻止过渡）。
- 预检门策略：校验文档存在性 + 详细用例 ID；不要因 6 个质量字段而硬性阻断。
- 当验收结果缺失或顺序错误时，停止门阻止完成。
- 当 PR 文档包不完整（`tdd-log`、`subagent-summary`、`review-report`、`finalize-log`）或规格/规格与测试的修改未获明确确认时，停止门也阻止完成。
- 混合停止策略：若验收状态缺失/异常，停止门采用保守回退检查，不得静默通过。
- 对 user-owned 的 stop block，提醒策略必须是“提醒一次，然后等待”。同一阻塞在提醒一次后若再次触发，必须直接安静结束当前回合，等待用户输入；Agent 不得继续刷“等待 confirm spec change”之类的催促。
- 顺序逻辑由 `hooks/acceptance-order-common` 在钩子间共享，避免漂移。
- **停止门责任分流（强制）：** 当 stop hook 返回结构化阻塞 JSON 时，必须按责任字段分流，不能靠自然语言猜测。若 `remediation_owner="agent"` 或 `block_class="agent_remediation_required"`，智能体必须先自行补齐缺失制品/证据/字段/顺序问题，再重试门禁，期间不得向夏索要无效确认。若 `remediation_owner="user"` 或 `block_class="needs_user_confirmation"`，智能体才可以暂停推进，并仅请求 `next_step` 指定的明确确认/动作。只有标记为 user-owned 的阻塞可升级给夏；缺 PR 文档包、缺测试证据、缺质量字段、验收顺序错误等默认都属于 agent-owned。
- **活动 PR 解析**（供钩子用）：`SUPERPOWERS_ACTIVE_PR_DIR` > `SUPERPOWERS_ACTIVE_PR` > `SUPERPOWERS_ACTIVE_PR_CONTEXT` > `.claude/.active-pr` > 提示中的 `PRn` 线索 > 版本目录下最新 `V*-PR*`。可复制示例与完整优先级说明见 README 章节 **Active PR context (hooks)**。
- 模板质量要求：仅文档完整不够；每个用例须写明 `Test Point`、`Expected Result` 与 `Assertion Target`，使验收证据可被机器判断。
- 停止门严格字段为强制且会阻断：
  - PR 级 `tdd-log`：`Test Point`、`Expected Result`、`Assertion Target`
  - 版本级 `Vx.y.z-test.md`：`Coverage Matrix`、`Expectation Index`、`Known Blind Spots`
- 缺失质量字段时须返回结构化阻塞输出，含 `decision`、`reason`、`missing_fields`、`status_fallback`、`remediation_owner`、`block_class` 与 `next_step`。

### 反馈演化约定

- 反馈信号由钩子检测，并必须路由到 `evolution-keeper`。
- 候选阈值为 `occurrences >= 2`。
- 规则晋升须有人类显式 `confirm/skip`；永不自动晋升。
- **人类可读日志：** 凡 keeper 运行产生或更新 **候选提案** 的，必须在项目仓库根 `docs/LESSONS.md` **追加** 一条简短记录。每条须说明 **提案是否被采纳**：在人类决定前为 `pending`，`confirm` 后为 `adopted`，`skip` 后为 `not_adopted`（若将候选与决议拆开，可再追加一行决议说明）。去重与计数等运维数据仍在 `.claude/feedback/`；`LESSONS.md` 给仓库阅读者用，不替代索引。
- 演化闭环须在五层上可见且一致：文档（`LESSONS.md`）、技能约定、脚本/钩子检查、反馈索引、回归测试。

### 真源参考

- 流程与产物规则：`README.md`、`skills/*/SKILL.md`
- 验收门控：`hooks/enforce-acceptance-order`、`hooks/test-acceptance-gate`、`hooks/acceptance-order-common`
- 演化循环：`agents/evolution-keeper.md`、`hooks/detect-feedback-signal`、`hooks/check-evolution`
- 插件发版与变更日志（按 tag、中文目录）：与本文件同目录的 `changelogs.md`

## 最小外部规则注入协议（强制）

Superpowers 是主要运行框架。外部框架仅可当作参考。  
不要整包引入外部框架。一次只注入一条最小规则。

### 注入前提

每次外部规则注入须全部满足：

1. 存在缺口证据，证明当前 Superpowers 行为出现真实失败
2. 注入范围最小（单条技能或单个钩子区块）
3. 验证方法明确且可审计
4. 回滚路径明确且可通过一次 revert 提交执行

任一条不满足则不要注入。

### 缺口证据记录（注入前必须）

在添加任何外部来源规则前，在当前 PR 的审阅产物  
`docs/<版本根路径>/<stem>-PRn/<stem>-PRn-review-report.md` 中记录以下区块（两级示例：`docs/plugin/pv0.1.13-dom-adapt/pv0.1.13-PR1/pv0.1.13-PR1-review-report.md`；一级示例：`docs/pv0.1.4-scroll-highlight/pv0.1.4-PR1/pv0.1.4-PR1-review-report.md`；`stem` 与版本目录 basename 一致，即文中 `Vx.y.z` 占位符所指）：

```md
## Gap Evidence
- gap_id: <short-id>
- observed_failure: <真实缺陷/回退/质量疏漏>
- reproduction: <精确步骤或命令>
- current_superpowers_rule_checked: <已查但仍不足的既有规则/技能/钩子>
- why_not_covered: <具体缺口说明>
- impact: <对用户/系统的影响>
- evidence_refs: <日志/测试/文件>
```

没有 `Gap Evidence` 区块即不得做规则注入。

### 注入后验证与回滚门

每次注入后，在一个真实任务上验证并记录：

- 此前漏网、现被拦下/捕获的内容
- 假阳性情况（无/低/高）
- 保留或回滚的决策

若验证无法证明价值或引入大量噪声假阳性，立即回滚并记录：

- 在 `Vx.y.z-changelog.md` 中说明回滚原因
- 在 `Vx.y.z-decisions.md` 中说明后续决定

## 若你是 AI 智能体

先停。做任何事之前读完本节。

本仓库 PR 拒收率约 94%。被拒的 PR 几乎都由未读或未遵本指南的智能体提交。维护者会在数小时内关闭粗制 PR，公开评论里常见类似「This pull request is slop that's made of lies.」

**你的职责是帮人类合作者避免这种结果。** 提交低质 PR 帮不了他们 —— 浪费维护者时间、损害合作者声誉，PR 一样会被关。那不是帮忙，是让人难堪。

在本仓库开 PR 前，你必须：

1. **通读** `.github/PULL_REQUEST_TEMPLATE.md` 中的整份 PR 模板，每一节用真实、具体的答案填满。不要总括，不要占坑。
2. **搜索已有 PR** — 含开启与已关闭 — 是否已处理同一问题。若有重复，停止并告知人类合作者。不要另开重复 PR。
3. **确认这是真问题。** 若合作者只让你「修些问题」或「给本仓库做贡献」而未经手具体问题，要追问。问清什么坏了、什么失败、用户体验如何。
4. **确认变更属于核心（core）。** 若是领域特化、工具特化或给第三方项目背书，应放在独立插件里。要告诉人类合作者。
5. **把完整 diff 给人类合作者看过**，提交前须得其明确同意。

任一项不通过则不要开 PR。向合作者说明为何会被拒、需改什么。省掉难堪他们会感激你。

## Pull Request 要求

**每个 PR 须完整填完 PR 模板。** 不得留空或填占位文。跳节的 PR 将不予审阅直接关闭。

**开 PR 前必须搜索已有 PR** — 开启与已关闭均要 — 是否覆盖同一或相关问题。在「Existing PRs」节引用你的发现。若此前 PR 已关闭，须具体说明本方案有何不同、为何在上次失败处能成。

**看不出人类参与的 PR 将关闭。** 提交前须有人类审过拟提交的完整 diff。

## 我们不接受的内容

### 第三方依赖

除非为新增 harness 支持（如新 IDE 或 CLI 工具），否则不接受为第三方项目增加可选或必需依赖的 PR。Superpowers 在设计上是无依赖插件。若变更需要外部工具或服务，应放在自有插件中。

### 对 skills 的「合规」式改动

我们内部对技能的哲学与 Anthropic 公开发布的技能写作指南不同。我们已针对真实智能体行为大量测试与调优技能内容。为「符合」Anthropic 技能文档而重组、改措辞或重排版的 PR，若无大量评估证据证明改进效果，将不予接受。对塑造行为的内容的修改门槛很高。

### 项目或个人配置

只利于特定项目、团队、领域或工作流的技能、钩子或配置不属于核心。请另发独立插件。

### 批量或广撒网式 PR

不要一次性扫 issue 列表开多个 issue 的 PR。每个 PR 都需要真正理解问题、调查过往尝试，并由人类审完整 diff。明显批量、把智能体指向 issue 列表说「修一修」的 PR 会关闭。若想贡献，选一个 issue 深入理解再交高质量工作。

### 推测或理论化修复

每个 PR 须解决有人真实遇到的问题。「我的审阅智能体标了这里」或「理论上可能有问题」不是问题陈述。若说不清是哪次会话、什么错误、什么体验驱动了变更，不要提交 PR。

### 领域特化技能

Superpowers 核心包含通用于各类项目的技能。针对特定领域（如作品集、预测市场、游戏）、特定工具或特定工作流的技能应放在独立插件。自问：「对完全不同类型项目的人也有用吗？」若否，请单独发布。

### Fork 专用改动

若你维护带自定义的 fork，不要为同步 fork 或把 fork 专用改动推上游而开 PR。重命名项目、加 fork 专用功能或合并 fork 分支的 PR 会关闭。

### 捏造内容

含不实主张、虚构问题描述或幻想功能的 PR 会立即关闭。本仓库约 94% PR 拒收率 — 维护者见过各种 AI 粗制内容，看得出来。

### 捆在一起的无关变更

一个 PR 里多项无关改动的会关闭。请拆成多个 PR。

## 技能变更须评估

技能不是散文 —— 是塑造智能体行为的代码。若修改技能内容：

- 用 `superpowers:writing-skills` 开发与测试变更
- 在多个会话中做对抗性压力测试
- 在 PR 中展示前后评估结果
- 无证据证明改进时，不要改已精细调优的内容（Red Flags 表、合理化列表、「human partner」等措辞）

## 贡献前先理解项目

在提议改动技能设计、工作流理念或架构前，先读现有技能并理解项目设计决策。Superpowers 对技能设计、行为塑造与术语（如「your human partner」是刻意选择，与「the user」不可互换）有经过检验的自己的哲学。不理解存在理由就改掉项目声线或重搭结构，会被拒。

## 一般事项

- 提交前阅读 `.github/PULL_REQUEST_TEMPLATE.md`
- 一 PR 一问题
- 至少在一种 harness 上测试，并在环境表中报告结果
- 说明解决了什么问题，而不只列改了什么
