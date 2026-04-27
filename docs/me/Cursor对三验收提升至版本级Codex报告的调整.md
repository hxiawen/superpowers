把 Codex 的评估消化进计划，以我为主做了两件事：

1. 重写可落地主文档
已更新 superpowers/5.0.7/docs/me/三验收提升级版本级_plan.md（v2），核心增补如下：

目标边界用表格写死

纳入：版本唯一真源、去掉双写、先定「唯一验收状态」结构再改 hook。
不纳入（默认）：多 PR 场景下「中间 PR 未跑完三层也能 clean」——若夏老板要这条，单独再定 needs_acceptance / 完成策略。
「唯一契约」+ 解析范围（回应「只改读哪个文件不够」）

约定固定 H2，例如 ## Acceptance status (hooks)，仅在该 H2 到下一同级 ## 之间做 first_match / 顺序与 next_expected（与当前全文扫描区分）。
模板里写明：该节之前避免误触发的叙事、与 Expectation Index 等的关系。
多 PR 与效率预期对齐（回应「边界没真解决」）

写清楚：本次主要是单 PR 少写一份 + 机器契约清晰；不是在不动 Stop 完成条件的前提下，让多 PR 中间阶段也「和收尾一样不卡三层」——那要另开解耦设计。
测试清单显式含 test-version-test-template.sh

并注明要改当前对「Stop hook PR parity」的断言、必要时加节内验收状态回归。
执行检查表 + 与 hooks/tests 的相对链接，便于开干时逐项勾。

2. 同步 Cursor 计划文件
已更新 .cursor/plans/验收提升至版本级_3aeba3f2.plan.md：overview 指向 v2 主文档，todos 拆成「契约 H2 + 节内解析」→ 通用 hook → 文档/模板 → 含 test-version-test-template.sh 的测试。

若你接下来希望把「多 PR 中间也可 clean」也并入同一期，需要单独定一条产品规则；可以在 v2 第一节表格里加一列「二期」即可，我可以在你确认后补一版仍不改代码，只改计划。


将 autotest/mocktest/devicetest 提升为版本级权威

以仓库内为准（v2，已合并 Codex 评审）：superpowers/5.0.7/docs/me/三验收提升级版本级_plan.md — 含：唯一契约、解析范围、多 PR 边界、测试表、检查清单。

摘要





不只改「读版本文件」：须 ## Acceptance status (hooks)（标题可最终定一版）+ 只在该 H2 至下一 ## 前做顺序/下一项推定，避免全文 first-match 与 Expectation Index 误匹配。



本次范围：单 PR 去重 + 版本真源 + 契约；不改「多 PR 中间无三层也 clean」— 需另立需求。



必改测试：test-version-test-template.sh 与模板同步（现仍断言「Stop hook PR parity」等）。

（下方保留 v1 粗纲供对照；细节一律以上述 三验收提升级版本级_plan.md 为准。）

现状分析（略）





Stop 与 UserPrompt 双写 + has_result_in_both 导致双份维护与强耦合。详见 v2 文档「二、问题回顾」。

实现方向（v2 已细化）





节作用域解析、validate_order / next_expected 同范围、模板与 test-version-test-template.sh 对齐、多 PR 预期见 v2 文档第三至六节。

风险与回滚





见 v2 文档第七节。