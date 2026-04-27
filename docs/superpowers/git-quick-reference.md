# Superpowers Git Quick Reference

## 0) One-command Checkpoint (Recommended)

```bash
# Commit + push (scoped to superpowers/5.0.7)
superpowers/5.0.7/scripts/sp-checkpoint.sh -m "update <topic>"

# Commit + push + milestone tag
superpowers/5.0.7/scripts/sp-checkpoint.sh -m "update <topic>" --tag sp-v5.0.7-xia-YYYY-MM-DD-XX
```

## 1) Check Current State

```bash
git status -sb
git branch --show-current
git remote -v
```

## 2) Commit a Small Change

```bash
git add superpowers/5.0.7/<changed-path>
git commit -m "superpowers: update <topic>"
git push
```

## 3) Create Milestone Tag

```bash
git tag sp-v5.0.7-xia-YYYY-MM-DD-XX
git push origin sp-v5.0.7-xia-YYYY-MM-DD-XX
```

## 4) Rollback a Bad Commit (Safe for Shared Branch)

```bash
git log --oneline -n 20
git revert <bad-commit-sha>
git push
```

## 5) Return Local Workspace to Milestone (Local Only)

```bash
git fetch --tags
git reset --hard <tag>
```

## 6) Recover from Backup Branch

```bash
git fetch origin
git checkout -b restore-from-backup origin/backup/pre-main-rewrite-20260422-214504
```

## 7) Check Last 10 Commits Readability

```bash
git log --oneline -n 10
```
