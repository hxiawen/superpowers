# Superpowers 单框架融合方案（战略+执行）

## 目标

- 保留 **Superpowers** 作为唯一框架与主流程。
- 仅吸收 `pmskills` 的两项核心能力：
  - 毒舌 PM 式需求澄清（去攻击性）
  - feedback 记录与规则毕业（自我进化）
- 不引入第二套主控，不并行运行两套流程。
- 本方案直接用于实际开发，不走试点流程。
- 本方案改造范围仅限 `superpowers/5.0.7`，排除 `superpowers/demo`。

## 战略层决策

- **主控不变**：以 Superpowers 的元技能与工作流为最高执行规则。
- **能力内化**：把 pmskills 的两项能力改写为 Superpowers 文档中的增强策略章节。
- **门禁不改**：继续使用 Superpowers 的 TDD 和完成前验证门禁，增强策略不替代门禁。

## 执行层落地

### A. 毒舌 PM 澄清增强（只增强，不改主流程）

#### 注入点

- `brainstorming`：每轮澄清执行反模糊问题模板（每次 1 问）
- `writing-plans`：对每个任务做“价值与边界复核”

#### 四类问题模板

1. 价值真实性：这是真需求还是主观假设？
2. 路径闭合：用户从输入到完成目标的路径是否闭合？
3. MVP 裁剪：如果砍 50%，哪些能力必须保留？
4. AI 增强：哪些手工步骤可由 AI 自动建议或自动化？

#### 风格约束

- 直白，说人话
- 面向技术小白、资深产品经理和设计师
- 质疑逻辑，质疑实现路径
- 结论必须落到可执行决策

### B. feedback-evolution 轻量闭环（记录 -> 聚合 -> 提议）

#### 角色归属（单角色）

- 新增单一角色：`evolution-keeper`
- 由主 Agent 派发 `evolution-keeper` 执行记录、聚合、提议、确认收口
- 不拆分 observer/runner 双角色，保持轻量角色化

#### 目录约定

```text
.claude/
  feedback/
    FEEDBACK-INDEX.md
    templates/
      feedback-topic-template.md
      feedback-index-template.md
```

#### 记录触发

- 用户明确修正 AI 行为
- 同类问题重复出现（>= 2）
- 流程中出现未覆盖场景
- 可量化低分（精准度/覆盖度/效率/满意度）
- 触发后由主 Agent 派发 `evolution-keeper` 落库与更新索引

#### 规则毕业阈值

- occurrences >= 2：提议升级为正式规则
- 同类维度持续低分：提议优化相关策略
- 任何提议均需人工确认后执行

#### 状态流转（统一）

- `candidate`：满足候选条件，等待人工确认
- `graduated`：确认后已吸收为正式规则
- `skipped`：人工明确跳过，后续不重复提议（除非新证据重开）

状态流转建议：

`new -> candidate -> (confirm -> graduated) | (skip -> skipped)`

#### 去重与计数规则

- 同主题反馈优先更新，不重复建文件
- 同主题每次命中信号时 `occurrences +1`
- 更新索引时同步刷新 `updated`
- 仅记录可复现、可归类、可行动的反馈

#### 提议输出格式（统一）

每条候选提议至少包含：

1. 标题与来源（source_skill）
2. 证据摘要（触发场景、具体行为）
3. 当前 occurrences 与状态
4. 建议变更点（改什么、影响范围）
5. 用户决策项：`confirm` 或 `skip`

角色化执行补充：

- `evolution-keeper` 每次执行后回传结构化结果（action/topic/occurrences delta/candidate decisions）
- 主 Agent 仅做转述与确认收口，不改写候选决策项语义

#### 最小模板

```md
# FEEDBACK INDEX

- [requirements-clarification-too-shallow](requirements-clarification-too-shallow.md)
  - occurrences: 2
  - source_skill: brainstorming
  - status: candidate
  - updated: 2026-04-20
```

## 门禁对齐（保持 Superpowers 优先）

1. TDD（test-driven-development）
2. 完成前验证（verification-before-completion）
3. feedback-evolution（提醒和提议，不阻断主流程）

冲突处理：

- 若追问过深影响节奏：先缩小范围，再继续主流程
- 若记录反馈影响任务推进：先过门禁，再补反馈
- 若增强策略削弱验证纪律：立即回滚增强策略

## 生产启用方式

### 上线动作（立即生效）

1. 在需求阶段使用四类澄清问题模板。
2. 在计划阶段执行任务边界复核（价值、范围、可执行性）。
3. 每次命中反馈信号后派发 `evolution-keeper` 更新 `FEEDBACK-INDEX.md`。
4. 每次 SessionStart 命中进化提醒后派发 `evolution-keeper` 输出候选提议。
5. 每周一次规则候选评审（人工确认是否毕业）。

### 节奏建议（无试点）

- 日常开发按 Superpowers 原流程推进。
- 澄清与进化能力作为常驻增强层运行，不额外插入新流程阶段。
- 若发现影响效率，可仅调整增强参数，不动主流程。

## 成功标准

- 需求返工率下降
- 完成声明持续符合 Superpowers 验证门禁
- 形成稳定且低噪声的规则候选池

## 能力评估关键点

### 澄清能力（关键点评估）

- 需求进入实现前，是否覆盖四类问题中的至少三类（价值/路径/MVP/AI）。
- 需求文档是否仍存在“核心歧义点”未决。
- 返工问题是否主要来自“实现偏差”而不是“需求未问清”。
- 对同类需求，澄清轮次是否趋稳（不过度追问，也不漏问）。

### 进化能力（关键点评估）

- 记录的反馈是否满足“可复现 + 可归类 + 可行动”。
- 候选规则是否来自高频问题，而非一次性噪声。
- 规则毕业后是否减少同类问题再次出现。
- 提议审批是否保持人工确认，避免自动化误改主流程。

## 风险与规避

- 风险：风格过硬影响协作  
  规避：直白但不攻击，所有质疑都基于事实
- 风险：feedback 噪声过高  
  规避：只记录可复现、可归类、可行动信号

## 执行清单

- [ ] 在项目规则中声明 Superpowers 单框架优先级
- [ ] 启用四类澄清问题模板
- [ ] 创建 feedback 目录、索引和模板
- [ ] 建立每周一次规则候选评审
- [ ] 按能力评估关键点做周度复盘

