# Superpowers Fork — Lessons

> 框架级复盘。记录架构、可移植性、agent 盲区等跨项目问题。

---

## L1: 框架与项目耦合限制了可移植性

**问题**: superpowers-fork 在迭代过程中逐步与 ChatBobi 项目咬合，约 15% 的代码包含 ChatBobi 特定引用（硬编码路径、Chrome extension manifest、特定 command 路径）。导致框架被限制在单一项目中，无法直接应用于其他项目。

**具体耦合点**:
- `skills/autotest/SKILL.md`、`mocktest/SKILL.md`、`devicetest/SKILL.md` — 硬编码 ChatBobi command 路径和 Chrome extension 构建产物路径
- `hooks/build-version-report-guard` — 硬编码 `src/.output/chrome-mv3/manifest.json`
- `hooks/superpowers-runtime-sync-reminder` — 提到 "ChatBobi overlay"
- `hooks/test-acceptance-gate` — Chrome extension 版本漂移检查

**为什么没被及时发现**: Agent 在整个开发过程中从未提示此风险。每次迭代都是"满足当前需求"，没有从框架可移植性角度审视改动。Agent 缺乏"我正在改的是一个通用框架"的意识，行为等同于"改项目私有代码"。

**正确方向**: 框架层改动应遵守"不引入项目特定耦合"原则。项目特定逻辑通过配置层或项目侧文件（command/overlay）注入，不写入框架核心。

**后续**:
- [ ] 考虑"去 ChatBobi 化"重构：提取配置层，模板化测试 skill
- [ ] 在框架改动时加入可移植性自检：本次改动是否引入了项目特定路径/假设？
