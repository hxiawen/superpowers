# Evolution Keeper Acceptance Checklist

Use this checklist to verify the role-based evolution loop end-to-end.

## Scenario 1: Feedback signal hit (UserPromptSubmit path)

- [ ] Provide a correction-style prompt (for example: "不是这样，你漏了一个步骤")
- [ ] Confirm hook reminder asks to dispatch `evolution-keeper`
- [ ] Confirm keeper output contains `## Evolution Keeper Result`
- [ ] Confirm action is one of `recorded|updated|no-op`
- [ ] If topic exists, confirm `occurrences` increments

## Scenario 2: SessionStart evolution reminder path

- [ ] Ensure `.claude/feedback/FEEDBACK-INDEX.md` has at least one entry
- [ ] Ensure one entry is `status: candidate` or `occurrences >= 2`
- [ ] Start a new session and confirm reminder asks to dispatch `evolution-keeper`
- [ ] Confirm keeper returns candidate list and required `confirm/skip` decisions
- [ ] Confirm no auto-graduation occurs without explicit human confirmation

## Scenario 3: Confirm/Skip bookkeeping

- [ ] Execute one `confirm` decision and one `skip` decision
- [ ] Confirm index/topic metadata reflect `graduated` or `skipped`
- [ ] Confirm skipped item is not repeatedly proposed without new evidence
- [ ] Confirm final response includes the keeper result block with updated state
