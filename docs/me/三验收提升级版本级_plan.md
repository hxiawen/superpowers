# 将 autotest / mocktest / devicetest 提升为版本级 — 可落地计划（v3）

> **实施状态（以代码与根文档为准）**  
> 本计划中的架构与「版本文件唯一、固定 `## Acceptance status (hooks)` 小节」**已在实现中采用**。权威约定请查仓库根级 **`CLAUDE.md`**、**`README.md`**、**`AGENTS.md`** 及 `hooks/acceptance-order-common` / `hooks/enforce-acceptance-order` / `hooks/test-acceptance-gate`。下文的「问题回顾」等段落保留为**设计过程与历史语境**，与当前行为不一致时，以根文档与钩子为准。

本文吸收外部评审意见：**方向不变**，补齐「唯一契约、解析范围、测试清单、多 PR 目标边界」，避免只改“读哪个文件”却导致 first-match 误判断序。

---

## 一、目标边界（先定死，避免范围漂移）

| 项 | 本次**纳入** | 本次**不纳入**（除非另开决策） |
|----|----------------|----------------------------------|
| 核心 | 三层验收的**唯一权威**落在 `docs/.../Vx.y.z-test.md`；消灭 PR tdd-log 与版本文件的**双写** | — |
| 单 PR 版本 | 显著收益：只维护**一份**带状态的三层结果 | — |
| 多 PR 版本 | 仅去掉「PR 里再记一遍」；**不**改变「无完整版本级三层时 Stop 是否 clean」的默认行为 | **不**做「中间 PR 收尾也可 clean、与版本级三层解耦」——若夏老板要「多 PR 不打断、中间也能关会话」，需**单独**定义 `needs_acceptance` / 会话完成策略与门控关系，另开事项 |
| 解析 | **写死**版本文件里**哪一段**供钩子解析，避免全文 first-match 误判 | 禁止仅改“读版本文件”而不改解析范围与模板结构 |

**一句话（对外）**：本次 = **单 PR 去重 + 版本文件机器契约**；**不是**多 PR 下「无三层也可结束会话」的专门优化，除非后续单独拍板。

---

## 二、问题回顾（为何觉得「走两遍 / 被打断」）

1. **Stop 门** [`hooks/test-acceptance-gate`](../../hooks/test-acceptance-gate) 对 `PR_TDD_LOG` 与 `VERSION_TEST` **双份** `require_pattern_in_file` + 双份 `validate_order_in_file`（约 108–124、190–195 行）→ 单 PR 时同一轮结果写两遍。  
2. **UserPromptSubmit** [`hooks/enforce-acceptance-order`](../../hooks/enforce-acceptance-order) 中 `next_expected_test` 依赖 `has_result_in_both`（两文件**同时**有带状态行）才推进 → 双文件强耦合。  
3. 文档 / [`version-test-template.md`](../superpowers/templates/versioning/version-test-template.md) 强调 PR tdd 与版本「同等」顺序校验，与目标冲突。

**保持不变（建议）**

- PR 级 `Vx.y.z-PRn-tdd-log.md`：**TDD 用例** + 逐条 `Test Point` / `Expected Result` / `Assertion Target`（PR 级质量门可继续只盯 tdd-log）。  
- 版本级 `Vx.y.z-test.md`：`Coverage Matrix` / `Expectation Index` / `Known Blind Spots` 与版本汇总用例。  
- 执行顺序仍为 **`autotest -> mocktest -> devicetest`**，仅**权威落点**改为版本。

---

## 三、版本级「唯一验收状态源」契约（高优先级，必须先于改钩子定稿）

**根因（评审意见）**：当前 [`acceptance-order-common`](../../hooks/acceptance-order-common) 的 `first_match_line` 对**整文件**取每个关键词的**首次**匹配行；后文如 **Expectation Index** 再出现 `mocktest` 会误伤顺序。若只把「读哪个文件」从双份改为版本，**而不收窄解析范围**，会出现「人眼看文档对、hook 报顺序错」。

### 3.1 必须固定的结构（契约 v1）

1. **机器可解析的小节标题（唯一、不得变体）**  
   - 全文件**只**允许使用下面**逐字一致**的二级标题（大小写、空格、括号与英文 `hooks` 均不可改）：  
   - **`## Acceptance status (hooks)`**  
   - **禁止**：`验收状态`、`Acceptance Status`、缺 `(hooks)`、多余空格、同级重复第二处「同名」小节等任何变体。模板、示例、README、CLAUDE、技能与**所有**钩子/测试中的「锚点字符串」均须与此相同，避免实现与回归各写各的。  
   - 该 H2 为钩子**唯一**解析入口；无此标题 → **必须 block**（不得回退全文扫描）。  
2. **规范状态行**（三行、顺序为 autotest → mocktest → devicetest）**必须**放在该 H2 下的正文中，格式沿用现有 token：`autotest: pass` / `autotest：通过` 等（与 `validate_order_in_file` 中 `status_tokens` 一致）。  
3. **防误判规则（模板中必须写清）**  
   - 在 **`## Acceptance status (hooks)`** **之前**的篇幅中，**避免**出现会被 `autotest|mocktest|devicetest` 正则当状态行匹配的文本；推荐把该 H2 放在文件前部、大段叙事放在其后。  
   - 后文 `Expectation Index` 等可重复提测试类型名；实现上 **只在「自该 H2 起至下一 `##` 前」** 做 `first_match` / 顺序判断（见 4.1），与小节外文本隔离。

### 3.2 与现有模板差异

- 现 [`version-test-template.md`](../superpowers/templates/versioning/version-test-template.md) 的 *Example early status block* 与 *Stop hook: acceptance order* 的 **PR parity** 说明需整体改写为：**Stop / UserPrompt 仅以**标题为 **`## Acceptance status (hooks)`** 的**唯一小节**为序；PR tdd-log 不再参与三层顺序校验。  
- 原 *PR Coverage* 表：改为「可选 / 多 PR 人力分工说明」或「版本一次性结果」表，**不**再暗示每行 PR 必须各填三列 `autotest|mocktest|devicetest` 才能过 hook（与契约一致后更新文案）。

---

## 四、实现要点（确认后动代码）

### 4.1 钩子

- [`acceptance-order-common`](../../hooks/acceptance-order-common)  
  - 实现 **`section_scoped` 或等价逻辑**：`validate_order_in_file` 与 `next_expected_test_from_version` **仅在**以 **`## Acceptance status (hooks)`** 为锚、**到下一 `##` 前** 的范围内计算 first-match 与 `next_expected`；无该**逐字**标题则**明确 block**（禁止回退整文件 `Vx.y.z-test.md` 扫描）。  
  - 删除或替代 `has_result_in_both` / 旧 `next_expected_test`（无引用则删）。  
- [`enforce-acceptance-order`](../../hooks/enforce-acceptance-order)：下一项待跑仅基于**版本文件 + 上述小节**；Preflight 仍可要求 PR tdd 存在 + 用例号（**不**再要求 PR 内已有三层结果）。  
- [`test-acceptance-gate`](../../hooks/test-acceptance-gate)：删 PR 上三层关键字与 PR 的 `validate_order`；**保留**版本文件内顺序与三关键字 + PR tdd 的 TDD 细粒度质量门 + 版本三字段等。

### 4.2 技能与根文档

- `skills/autotest|mocktest|devicetest/SKILL.md`：主写入 `Vx.y.z-test.md` 的**契约小节**；PR tdd 不强制三层。  
- `executing-plans` / `writing-plans` / `subagent-driven-development` / `finishing-a-development-branch`：PR 循环 = 开发/审阅；**三层验收 = 写版本文件契约区（通常版本收尾或一次性）**，与 第一节边界一致。  
- `README.md` / `CLAUDE.md` / `CLAUDE_zh.md` / `pr-folder-template.md` / `tdd-report-template.md` 同步。

### 4.3 迁移

- 旧内容在 PR tdd 中的 `autotest: pass` 可保留为历史；**以版本文件新小节为准** 过 Stop。

---

## 五、测试清单（高优先级，避免盲区）

| 资产 | 作用 |
|------|------|
| [`tests/claude-code/test-version-test-template.sh`](../../tests/claude-code/test-version-test-template.sh) | **唯一直接**约束 `version-test-template.md` 结构；**必须**随模板改：① **逐字**断言存在 **`## Acceptance status (hooks)`**（不得再用语义相近的弱匹配）；② 删除或替换原 `Stop hook PR parity` 类断言；③ 该小节下三行状态示例的占位说明。 |
| [`tests/claude-code/test-version-pr-doc-contract.sh`](../../tests/claude-code/test-version-pr-doc-contract.sh) | 更新 README/技能中对该标题与「不得变体」的表述契约（若有固定位字符串则一并断言）。 |
| **`enforce-acceptance-order` + `next_expected`（必增，不标「可选」）** | 新增或扩展现有 `tests/claude-code` 用例，**专测**「section scoped」行为，至少覆盖：① **只读** `## Acceptance status (hooks)` 子树内行推进：仅 autotest 有状态时下一期望为 `mocktest`，依此类推至 `devicetest` 与 `done`；② **小节外**出现与验收同名的干扰文本（如正文/EI 中写 `autotest: pass` 或 `mocktest` 叙述）**不得**改变 `next_expected`；③ 无该 H2 或标题非逐字一致时，行为与现有 block 策略一致。实现上可 `source` [`acceptance-order-common`](../../hooks/acceptance-order-common) 对**临时造的最小** `Vx.y.z-test.md` 片段做断言。 |
| `test-acceptance-gate` 相关用例 / `test-stop-gate-*.sh` | 仅版本文件在契约小节内三层+顺序、PR 无三层关键字时 **应通过**；**负例（Stop）**：`Expectation Index` 等**在小节外**的歧义行不触发误拦、顺序仍以契约小节为准。 |
| 原双文件 `next_expected` 测试 | 全部改为**版本单文件 + 上表 enforce 用例**吸收，避免重复定义。 |

---

## 六、多 PR 与「工程效率」的对齐说明（避免预期落空）

- **本次**对多 PR 的帮助主要是：**少维护一份 PR 内三层**、**叙事与实现都以版本文件为单一真源**；**不是**让「未跑完版本三层」的中间 PR 也能和最终 merge 一样 **clean 关 Stop**。  
- 若夏老板要 **「多 PR 开发阶段完全不卡在三层」**，属于 **完成条件与门控解耦**，需单独一版产品规则（例如 per-PR `finalize` 与 `needs_acceptance` 关系），**不在本 v2 包内**。

---

## 七、风险与回滚

- **风险**：老仓库只改半套文档、缺新 H2 → hook 全文件扫描若未删干净仍可能误报；**契约 H2 + 作用域解析** 可降低该风险。  
- **回滚**：恢复对 PR 的三层检查与 `has_result_in_both` 逻辑（可分文件 revert）。

---

## 八、执行检查表（开干时逐项打勾）

- [ ] 契约 v1：模板与代码中 **仅** 使用 **`## Acceptance status (hooks)`**（已写入 3.1，不得变体）+ 节内三行 + 叙事顺序（节前少歧义）  
- [ ] `acceptance-order-common` 节作用域解析 + `enforce-acceptance-order` / `test-acceptance-gate` 联调  
- [ ] **新增** `enforce-acceptance-order` + `next_expected` 专项 shell 测（节内推进、节外不干扰、缺/错标题则 block）  
- [ ] `test-version-test-template.sh` 逐字 H2 断言 + Stop 门场景测  
- [ ] `test-version-pr-doc-contract.sh` + 技能/ROOT 文档  
- [ ] 与第一节「不纳入多 PR clean 解耦」对业务方再确认（若后续要，另起计划）  

---

*本文件路径：`docs/me/三验收提升级版本级_plan.md`（与实现目录相对路径已用 `../..` 链到 `hooks/`、`tests/`）。*
