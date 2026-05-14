# /figma-read — Figma URL Readiness and Visual Diff

从 Figma Design URL 稳定读取画布信息、截图和 design context，并在需要时进行截图对比分析。

此命令只处理 **读取 Figma 设计与视觉对比**。它不生成 Figma 插件脚本，也不属于 `/codetofigma` 流程。

## 触发场景

用户提供 Figma URL 时触发，尤其是 brainstorming 材料收集阶段：

```text
Assistant: 你现在手头有哪些材料？（多选）
User: Figma Design Draft。
Assistant: 你的 Figma 设计稿在哪？请提供 Figma URL 或 file key，我来查看。
User: https://www.figma.com/design/...
```

此时应立即执行 `/figma-read` readiness，而不是等到 spec、plan、截图对比或 codetofigma 阶段。

也适用于用户提供 Figma URL，并要求：

- 查看 / 读取 / 分析 Figma 设计
- 获取 Figma 截图
- 对比 Figma design 与产品源码或产品截图
- 检查 design diff / visual diff / 还原度
- 根据 Figma 截图差异修改源码

## Step 1: 解析 Figma URL

从用户输入中提取：

| 字段 | 说明 |
|------|------|
| file key | `figma.com/design/<file-key>/...` 或 `figma.com/file/<file-key>/...` |
| node-id | URL 参数 `node-id=0-1` |
| MCP nodeId | 将 `0-1` 转换为 `0:1` |

如果 URL 没有 `node-id`：

1. 优先使用 Figma 当前选中的 node。
2. 如果无法确认当前选中 node，向用户询问目标 frame / node。

## Step 2: Figma MCP Readiness

读取 Figma 前必须区分两件事：

```text
MCP server connected != 当前会话可调用 Figma 工具
```

### 2.0 官方配置、本机 Desktop 与本命令的命名约定

Figma 官方文档（[Figma MCP Server Guide](https://github.com/figma/mcp-server-guide)）推荐的 Claude Code 做法是安装插件 `figma@claude-plugins-official`，或手动：

```bash
claude mcp add --transport http figma https://mcp.figma.com/mcp
```

这样注册的 MCP **服务名通常是 `figma`**，会话里暴露的工具前缀为 **`mcp__figma__*`**（与 `figma-desktop` 不同）。

**与本命令及 Superpowers hooks 的关系：**

| 服务名 | 典型 URL | 说明 |
|--------|----------|------|
| **`figma-desktop`** | `http://127.0.0.1:3845/mcp` | Figma Mac 在本地提供的 MCP（画布下方可出现 “MCP server enabled … 3845”）。**本命令要求检查并使用 `mcp__figma-desktop__*`**。使用前请打开 **Figma Mac** 并进入目标设计文件。 |
| **`figma`** | `https://mcp.figma.com/mcp` | 官方远程 MCP；工具前缀为 **`mcp__figma__*`**；部分工具仅远程可用（见 Figma 开发者文档）。 |

**推荐：** 按本命令做 `/figma-read` 时，**保留名为 `figma-desktop`、指向 `127.0.0.1:3845/mcp` 的 MCP**；若还需远程独占能力，可同时保留 **`figma`**。二者可同时存在。

**若 `figma`（远程）未连接但 `figma-desktop` 已连接：** 只要本机 Figma 已打开，**读取** metadata / screenshot / design context **仍可优先走 `figma-desktop`**；远程失败另行排查网络、鉴权或令牌，勿误判为「无法读稿」。**勿**把个人令牌写入仓库或聊天。

**若仅安装官方插件、未单独添加 `figma-desktop`：** 可选用已暴露的 **`mcp__figma__get_metadata` / `get_screenshot` / `get_design_context`** 完成同类读取；本仓库 hooks 仍以 **`figma-desktop__`** 为默认约定——团队若在 fork 中只使用 `figma`，应统一改写 hook/命令文案或增补并行检查。

### 2.1 检查 MCP server

运行：

```bash
claude mcp list
```

确认 `figma-desktop` server 是否 connected。

### 2.2 检查当前会话工具暴露

当前 Claude Code 会话必须能调用以下工具：

- `mcp__figma-desktop__get_metadata`
- `mcp__figma-desktop__get_screenshot`
- `mcp__figma-desktop__get_design_context`

如果 `claude mcp list` 显示 figma-desktop connected，但当前会话工具列表没有这些工具，判定为：

```text
figma_session_tools: missing
```

这是 context continuation 导致的工具列表冻结问题。不要继续猜测、不要用普通网页读取替代、不要把问题归因到 Figma URL。

输出标准 handoff，并要求用户重启 Claude Code：

```md
# Figma Read Handoff

当前问题：
figma-desktop MCP server 已连接，但当前 Claude Code 会话没有加载
`mcp__figma-desktop__get_metadata` / `get_screenshot` / `get_design_context`。
这是 context continuation 导致的工具列表冻结问题。

请重启 Claude Code，然后继续执行：

Figma URL:
<原始 URL>

Node ID:
<解析后的 nodeId>

目标：
1. 使用 get_metadata 查看 Figma 结构
2. 使用 get_screenshot 获取设计截图
3. 使用 get_design_context 获取设计上下文
4. 与产品源码截图进行视觉 diff
5. 根据 diff 修改源码或记录问题

需要读取的项目文档：
- <相关版本 plan/test/design/changelog>
- <相关 PR finalize/review/tdd 记录>
```

### 2.3 状态记录

在相关分析记录或 PR 文档中记录：

```md
## Figma URL Readiness

- figma_mcp_server: connected / disconnected
- figma_session_tools: available / missing
- figma_url_parse: pass / fail
- figma_metadata_read: pass / fail / blocked
- figma_screenshot_read: pass / fail / blocked
- figma_design_context_read: pass / fail / blocked
- resolution: continue / restart_claude_code / reconnect_figma
```

## Step 3: 读取 Figma

当 readiness 通过后，按顺序读取：

1. `get_metadata(nodeId)`：确认目标 frame、层级、命名和尺寸
2. `get_screenshot(nodeId, contentsOnly: true)`：获取用于视觉分析的 Figma 截图
3. `get_design_context(nodeId)`：获取设计上下文、组件结构和可实现信息

如果任一步失败：

- 记录失败步骤和错误
- 不把失败写成视觉结论
- 先修复读取问题，再进入对比

## Step 4: Visual Diff Tool Policy

截图对比优先使用 ZAI-MCP，但不写死为唯一工具。

### 工具策略

1. 如果 ZAI-MCP 可用，优先使用：
   - `mcp__zai-mcp-server__analyze_image`
   - `mcp__zai-mcp-server__ui_diff_check`
   - `mcp__zai-mcp-server__extract_text_from_screenshot`
2. 如果 ZAI-MCP 不可用，只有在内置图像理解足以完成任务时才降级继续。
3. 如果用户要求严格截图对比、像素级 diff、高置信度还原检查，且没有 ZAI-MCP 或等价工具，标记为 blocked。
4. 必须记录实际使用的视觉分析工具和置信度。

状态记录：

```md
## Figma Visual Diff Readiness

- figma_screenshot: available / missing
- product_screenshot: available / missing
- zai_visual_tools: available / missing
- visual_diff_mode: zai / built-in / blocked
- confidence: high / medium / low
```

## Step 5: 对比范围

根据任务要求选择对比范围：

| 对比类型 | 输入 | 输出 |
|----------|------|------|
| Token diff | Figma context + CSS tokens | 色值、字体、尺寸差异 |
| Structure diff | Figma metadata/context + React/HTML 结构 | 层级、命名、布局差异 |
| Visual diff | Figma screenshot + 产品截图 | 视觉差异、严重性、修复建议 |

不要只基于截图猜源码问题。能读取源码时，同时检查组件代码和 token。

## Step 6: 修复策略

根据 diff 来源决定修复对象：

| 判断 | 行动 |
|------|------|
| 源码偏离 Figma design | 修改源码 |
| 产品截图与源码预期不一致 | 调试运行时或样式加载 |
| Figma design 与需求记录不一致 | 记录决策，向用户确认 |
| 工具缺失导致无法读图 | blocked + handoff，不做视觉结论 |

每轮修复后重新读取或重新截图，直到 diff 关闭或记录明确残留问题。
