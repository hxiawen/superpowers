# Spec Document Reviewer Prompt Template

Use this template when dispatching a spec document reviewer subagent.

**Purpose:** Verify the spec is complete, consistent, and ready for implementation planning.

**Dispatch after:** Spec document is written under version root (`docs/Vx.y.z-<topic>/Vx.y.z-spec.md`)

```
Task tool (general-purpose):
  description: "Review spec document"
  prompt: |
    You are a spec document reviewer. Verify this spec is complete and ready for planning.

    **Spec to review:** [SPEC_FILE_PATH]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, "TBD", incomplete sections |
    | Consistency | Internal contradictions, conflicting requirements |
    | Clarity | Requirements ambiguous enough to cause someone to build the wrong thing |
    | Scope | Focused enough for a single plan — not covering multiple independent subsystems |
    | YAGNI | Unrequested features, over-engineering |
    | Material Traceability | Spec states which inputs were used (`Idea/PRD/Design Draft/Interactive Demo`) and what is still missing |
    | Version Capacity | Scope fits one version capacity; if not, split recommendation is explicit |
    | Testable Acceptance | Requirements can be mapped to acceptance checks without guesswork |

    ## Calibration

    **Only flag issues that would cause real problems during implementation planning.**
    A missing section, a contradiction, or a requirement so ambiguous it could be
    interpreted two different ways — those are issues. Minor wording improvements,
    stylistic preferences, and "sections less detailed than others" are not.

    Approve unless there are serious gaps that would lead to a flawed plan.

    ## Output Format

    ## Spec Review

    **Status:** Approved | Issues Found

    **Blocking Issues (must fix before planning):**
    - [Section X]: [specific issue] - [why it blocks planning]

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters for planning]

    **Material Coverage Check:**
    - Selected materials captured? yes/no
    - Missing critical material? yes/no (what is missing)
    - Material mismatch risk? yes/no (where spec conflicts with provided material)

    **Version Capacity Check:**
    - Fits one version capacity? yes/no
    - If no: suggested split strategy (version/PR boundaries)

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**Reviewer returns:** Status, Issues (if any), Recommendations
