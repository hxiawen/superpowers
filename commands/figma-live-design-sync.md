---
description: "Run the Superpowers figma-live-design-sync skill"
---

Use the `superpowers:figma-live-design-sync` skill.

This command orchestrates the loop:

1. Generate or patch the plugin script with codetofigma.
2. Ask the human to bootstrap once by running the Figma plugin in the target design.
3. Update the plugin code and verify hot reload with `/figma-read`.
4. Read back metadata, screenshot, and design context from the same Figma URL/node.
5. Diff against product source/screenshots.
6. Iterate on the plugin script until the Figma output matches or the loop is blocked.
