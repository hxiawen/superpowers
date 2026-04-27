# Superpowers × Claude Code — 项目内 CLAUDE.md（精简版）

> 面向 **Claude Code** 会话：以插件包根目录 **`CLAUDE_zh.md`** 为与 `CLAUDE.md` 对齐的**中文全文**；本文件只保留运行时必守核心。细节、完整条文与贡献/PR 规范请读 **`CLAUDE_zh.md`** 与 **`README.md`**。（`docs/me/CALUDE_zh.md` 若为旧名/草案，请以根目录 `CLAUDE_zh.md` 为准。）

[角色]

    你的主要工作是把夏老板（Xia）的需求落实为可执行、可验证、可审计的交付流程；优先保证门禁、证据产物、审查边界成立，而不是「尽快堆代码」。

[与夏老板的对话]

    - 用**简体中文**回复夏老板；简洁、有结构、像人在说话。
    - 不懂就问；不确定须提出，未经确认不擅自决策。
    - 开放式选项可用勾选列表呈现（见 **`CLAUDE_zh.md`** 中的交互格式示例）。

[会话职责]

    在每次开发会话中：
    1. 将工作路由到正确阶段（`brainstorming` → … → `finishing-a-development-branch`）。
    2. 维护版本/PR 产物契约（版本五件套 + PR 四件套，见下节）。
    3. 维护测试证据：PR **`tdd-log`** 管 TDD 用例；版本 **`Vx.y.z-test.md`** 管汇总与**唯一**的 `autotest` / `mocktest` / `devicetest` **状态行**（写在固定标题 **`## Acceptance status (hooks)`** 下，标题逐字、不可变体）。
    4. 遵守验收顺序：`autotest` → `mocktest` → `devicetest`（不可跳步）；**仅**在上述 acceptance 小节内落盘，供 hook 解析。
    5. 遵守审查归属：`review-report` 仅承载 reviewer 结论；实现者自检写入 `subagent-summary`。
    6. 参与反馈进化闭环（`evolution-keeper`；`occurrences >= 2` 仅产候选；`docs/LESSONS.md` 追加摘要，**完整契约见 `CLAUDE_zh.md`**）。

[文件结构 — 运行时最小契约]

    ```text
    docs/
    ├── LESSONS.md
    └── Vx.y.z-<topic>/
        ├── Vx.y.z-design.md … Vx.y.z-decisions.md
        ├── Vx.y.z-test.md   # 含 ## Acceptance status (hooks) 与 Coverage 等
        └── Vx.y.z-PRn/
            ├── Vx.y.z-PRn-tdd-log.md
            ├── Vx.y.z-PRn-subagent-summary.md
            ├── Vx.y.z-PRn-review-report.md
            └── Vx.y.z-PRn-finalize-log.md
    .claude/feedback/   # 与 LESSONS 分工见全文
    ```

    若仅有旧名 `Vx.y.z-PRn-code-review.md` 而无 `…-review-report.md`，先重命名再继续。

[七阶段流程（运行时）]

    规范标签：`Brainstorm` → `Spec` → `Plan` → `TDD` → `Subagent Development` → `Review` → `Finalize`。

    技能映射（与插件内技能一致）：design/spec gate 与 `writing-plans` → `test-driven-development` → `subagent-driven-development`（内含 worktree 基础设施）→ 审查与 `requesting-code-review` 模板 → `finishing-a-development-branch`（**按活动 PR 收口**）。

[版本 / PR 产物]

    - 版本根：`docs/Vx.y.z-<topic>/`；`<topic>` 为**两个**主题词 kebab-case（例：`v0.1.5-panel-ui`）。
    - 版本必备：`…-design/spec/plan/changelog/decisions.md`，以及 **`Vx.y.z-test.md`**（含 acceptance 小节与质量字段，见模板）。
    - 每个 PR 必备：`tdd-log`、`subagent-summary`、`review-report`、`finalize-log`。
    - 审查顺序：Stage 1（Spec/Plan 符合性）→ Stage 2（Code Quality）；未解决 Critical/Important 不得进入 Finalize。

[PR 循环与验收]

    - Plan 之后**按 PR1..PRn 循环**，禁止整版任务一次性线性跑完。
    - 开发/审查主路径：`TDD` → `Subagent Development` → `Review`（按 PR 推进）。三层环境验收 **`autotest` → `mocktest` → `devicetest`** 的**带状态结果**只写入 **`Vx.y.z-test.md`** 的 **`## Acceptance status (hooks)`**；**不要**依赖 PR `tdd-log` 让 hook 读三层状态（tdd 仅 TDD 证据 + 三字段）。详见 **`CLAUDE_zh.md`「验收测试与门控」** 与 `version-test-template.md`。
    - `PRn` 完成后做版本级回归/汇总，再谈分支集成；需要 PR 路径的 hook/文档时绑定 active PR（多为 `PRn`）。
    - 处理 **PR 级** 文档时须**显式**设定 active PR（见下节）。**Acceptance status** 块在**版本**文件，不按 PR 分存。
    - 预检：PR `tdd-log` 与版本 `Vx.y.z-test.md` 须存在、含用例 ID，且版本文件含 **`## Acceptance status (hooks)`**；Stop 对质量字段有严格策略（**见 `CLAUDE_zh.md`**）。
    - Hook 共享逻辑：`hooks/acceptance-order-common`（避免各 hook 漂移）。

[Active PR 上下文（Claude Code 终端/环境）]

    解析优先级（高→低）：`SUPERPOWERS_ACTIVE_PR_DIR` → `SUPERPOWERS_ACTIVE_PR` → `SUPERPOWERS_ACTIVE_PR_CONTEXT` → 项目根 `.claude/.active-pr` → 对话中的 `PRn` 提示 → 版本目录下最新 `V*-PR*`。

    常用片段（占位符替换为真实路径；切换会话可 `unset` 三个环境变量）：

    ```bash
    export SUPERPOWERS_ACTIVE_PR_DIR="/abs/path/to/docs/Vx.y.z-topic/Vx.y.z-PR2"
    mkdir -p .claude && echo 'Vx.y.z-PR2' > .claude/.active-pr
    ```

    完整说明与更多示例：**`README.md` →「Active PR context (hooks)」**。

[反馈进化（概述）]

    Hooks 将信号路由至 `evolution-keeper`；候选阈值 `occurrences >= 2`；毕业须人工 `confirm/skip`。`docs/LESSONS.md` 记录采纳状态（`pending` / `adopted` / `not_adopted`），与 `.claude/feedback/` 分工见 **`CLAUDE_zh.md`「反馈进化契约」**。

[外部规则注入（概述）]

    Superpowers 为主框架；禁止整包外链规则，**一次只注入一条最小规则**。须满足：真实失败证据、最小范围、可审计验证、可一次 revert 回滚。注入前须在当期 `…-review-report.md` 中写 **`Gap Evidence` 块**（字段模板与注入后校验：**见 `CLAUDE_zh.md`「最小外部规则注入协议」**）。

[权威来源与延伸阅读]

    - 中文全文与贡献/PR/不接受清单：**`CLAUDE_zh.md`**（若向上游贡献 Superpowers，须先读其中「若你是 AI 智能体」与 PR 要求）。
    - 安装与平台差异：**`README.md`**。
    - 技能行为细节：**`skills/*/SKILL.md`**；验收 hook：**`hooks/enforce-acceptance-order`**、**`hooks/test-acceptance-gate`**。
    - 进化与反馈 agent：**`agents/evolution-keeper.md`**。

[Claude Code 使用提示]

    - 通过官方市场或团队配置的 marketplace 安装 **superpowers** 插件后，技能与 hooks 随会话加载；具体 `/plugin` 命令以当前 Claude Code 文档为准。
    - 本文件不重复定义命令名；以项目内 **Commands** 与 **插件 README** 为准。
    - 若验收被拦截，先核对：**active PR 是否指对**、**版本 `Vx.y.z-test.md` 是否含 `## Acceptance status (hooks)` 且三行顺序正确**、**PR tdd 与版本测试用例是否齐全**。
