---
description: "Run one-click GitHub push and optional milestone tag for superpowers/5.0.7"
---

Use the `superpowers:gitsp` skill for this command.

Execution intent:

1. Ask for commit topic message.
2. Ask whether milestone tag is needed.
3. If yes, ask for tag name (default format: `sp-v5.0.7-xia-YYYY-MM-DD-XX`).
4. Run:
   - `superpowers/5.0.7/scripts/sp-checkpoint.sh -m "<message>"`
   - or with tag:
     `superpowers/5.0.7/scripts/sp-checkpoint.sh -m "<message>" --tag <tag>`
5. Return a structured result block:
   - branch
   - commit SHA
   - tag (or none)
   - push status
