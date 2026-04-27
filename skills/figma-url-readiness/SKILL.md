# Figma URL Readiness

Use this skill when the user provides a Figma Design/File URL, especially during brainstorming material intake after they select `Figma Design Draft`.

This skill is for reading Figma and comparing visuals. It is not `codetofigma`.

## Immediate Trigger

If the conversation reaches this point:

```text
Assistant: 你现在手头有哪些材料？（多选）
User: Figma Design Draft。
Assistant: 你的 Figma 设计稿在哪？请提供 Figma URL 或 file key，我来查看。
User: https://www.figma.com/design/...
```

immediately run the `/figma-read` workflow. Do not wait for spec, plan, screenshot diff, or Design Sync.

## Required Checks

1. Parse the Figma URL.
   - Extract file key.
   - Extract `node-id`.
   - Convert `node-id=0-1` to MCP `nodeId: "0:1"`.
2. Check MCP server health with `claude mcp list`.
3. Confirm the current session exposes all Figma Desktop tools:
   - `mcp__figma-desktop__get_metadata`
   - `mcp__figma-desktop__get_screenshot`
   - `mcp__figma-desktop__get_design_context`
4. If server is connected but tools are missing, stop and output restart handoff.
5. If tools are available, read in order:
   - metadata
   - screenshot
   - design context

## Tool-Freeze Failure

If `claude mcp list` shows `figma-desktop` connected but the current session does not expose `mcp__figma-desktop__*`, treat it as context continuation tool-list freeze.

Do not:

- use web reading as a substitute
- infer design details from memory
- route to `codetofigma`
- continue to high-confidence screenshot comparison

Do:

- explain that Claude Code must be restarted
- include the original Figma URL and parsed nodeId
- list the exact next calls for the fresh session

## Visual Diff

For screenshot comparison, prefer ZAI-MCP when available:

- `mcp__zai-mcp-server__analyze_image`
- `mcp__zai-mcp-server__ui_diff_check`
- `mcp__zai-mcp-server__extract_text_from_screenshot`

If ZAI-MCP is unavailable, only continue with built-in image analysis when the requested precision allows it. For strict or high-confidence visual diff, mark the result blocked or low confidence.
