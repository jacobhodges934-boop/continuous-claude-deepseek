# continuous-claude-deepseek

Windows-friendly continuous development automation for **Claude Code**, **Codex CLI**, and Claude Code Router / DeepSeek setups.

It repeatedly asks an agent to do one small development iteration, then handles the boring GitHub loop for you:

```text
read task -> edit code -> commit -> push branch -> create PR -> wait for checks -> merge -> repeat
```

This project is based on [continuous-claude](https://github.com/AnandChowdhary/continuous-claude), with extra Windows, UTF-8, DeepSeek, and project-bootstrap support.

## Who Is This For?

Use this if you want a repo to keep moving through small PRs while you provide a task list, for example:

- "finish the next E2E test task"
- "read the handoff doc and continue the next safe step"
- "fix one failing CI issue per iteration"
- "keep improving docs until the checklist is complete"

You do **not** need to remember long prompts. Put the project plan in files, then run the automation.

## Install

Open PowerShell 7:

```powershell
irm https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/install.ps1 | iex
```

By default this installs scripts to:

```text
~\.local\bin
```

You can choose another folder:

```powershell
$env:INSTALL_DIR = "D:\tools\continuous-claude-deepseek"
irm https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/install.ps1 | iex
```

## Requirements

- PowerShell 7 (`pwsh`)
- Git
- GitHub CLI (`gh`) logged in with `gh auth login`
- One agent CLI:
  - Claude Code: `claude`
  - or Codex CLI: `codex`

For PR automation, the target project must be a Git repo with a GitHub remote, or you must pass `--owner` and `--repo`.

## Quick Start For A New Project

Go to the project you want to automate:

```powershell
cd D:\path\to\your-project
```

Create the task files:

```powershell
pwsh ~/.local/bin/init-continuous-project.ps1
```

This creates:

```text
docs/NEXT_TASKS.md          prioritized task list
docs/SHARED_TASK_NOTES.md   project context and automation rules
docs/HANDOFF.md             latest handoff, verification, risks, next steps
```

Edit `docs/NEXT_TASKS.md` and write what should happen next.

Then start automation with Claude Code:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 `
  --provider claude `
  --prompt "Read docs/NEXT_TASKS.md, docs/SHARED_TASK_NOTES.md, and docs/HANDOFF.md. Pick the highest-priority task that can be completed and verified in one small iteration. Do not expand scope. After finishing, run relevant checks and update the docs." `
  --max-runs 3 `
  --merge-strategy squash
```

Or start automation with Codex CLI:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 `
  --provider codex `
  --prompt "Read docs/NEXT_TASKS.md, docs/SHARED_TASK_NOTES.md, and docs/HANDOFF.md. Pick the highest-priority task that can be completed and verified in one small iteration. Do not expand scope. After finishing, run relevant checks and update the docs." `
  --max-runs 3 `
  --merge-strategy squash
```

## How Tasks Work

There are two supported styles.

### 1. Direct Prompt

Good for one-off work:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 `
  --prompt "Fix the failing lint errors, run lint again, commit the smallest safe patch." `
  --max-runs 1
```

### 2. Project Task Files

Best for long-running automation:

```powershell
pwsh ~/.local/bin/init-continuous-project.ps1
```

Then write tasks into `docs/NEXT_TASKS.md`. The automation prompt tells the agent to read those files every iteration.

This is the recommended workflow because GitHub readers and future agents can understand the project state without knowing your chat history.

## Common Commands

Run one iteration only:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 --prompt "Fix one small issue from docs/NEXT_TASKS.md" --max-runs 1
```

Run up to 5 successful iterations:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 --prompt "Continue from docs/NEXT_TASKS.md" --max-runs 5
```

Run until stopped, budget limit, or repeated errors:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 --prompt "Continue from docs/NEXT_TASKS.md" --max-runs 0
```

Dry run:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 --prompt "Test setup" --max-runs 1 --dry-run
```

Use explicit GitHub repo:

```powershell
pwsh ~/.local/bin/continuous-claude-deepseek.ps1 `
  --owner your-github-user `
  --repo your-repo `
  --prompt "Continue from docs/NEXT_TASKS.md" `
  --max-runs 3
```

## Claude Code, Codex CLI, And DeepSeek

Default provider is Claude Code:

```powershell
--provider claude
```

Use Codex CLI:

```powershell
--provider codex
```

If Claude Code is routed to DeepSeek through Claude Code Router, this script avoids the common Windows issue where `claude -p` returns text but does not reliably perform file edits. It extracts the prompt and sends it through UTF-8 stdin while preserving CLI flags.

## Windows And Chinese Text Safety

This fork sets PowerShell and process IO to UTF-8 and avoids passing long PR bodies directly as command-line strings.

It also protects GitHub PR titles from mojibake. If a generated title looks like corrupted Chinese, for example:

```text
E2E 娴嬭瘯鎵╁睍...
```

the PR title falls back to:

```text
chore: autonomous iteration <number>
```

The original generated title is kept in the PR body with a notice.

## What Gets Created In GitHub?

When branch automation is enabled, every successful iteration:

1. creates a branch
2. asks the agent to commit changes
3. pushes the branch
4. creates a pull request
5. waits for checks
6. merges the PR
7. pulls the base branch

Disable PR automation if you only want local commits:

```powershell
--disable-branches
```

Disable commits too:

```powershell
--disable-commits
```

## Useful Files

- [continuous-claude-deepseek.ps1](continuous-claude-deepseek.ps1): main automation runner
- [scripts/init-project.ps1](scripts/init-project.ps1): creates project task docs
- [templates/continuous-project/docs/NEXT_TASKS.md](templates/continuous-project/docs/NEXT_TASKS.md): task list template
- [templates/continuous-project/docs/SHARED_TASK_NOTES.md](templates/continuous-project/docs/SHARED_TASK_NOTES.md): project context template
- [templates/continuous-project/docs/HANDOFF.md](templates/continuous-project/docs/HANDOFF.md): handoff template

## Notes

- Old PR titles already written to GitHub do not automatically change when you fix this script. Edit them with `gh pr edit <number> --title "normal title"`.
- Do not run unlimited iterations on a repo you do not trust.
- Keep tasks small and verifiable. This tool works best when every iteration can pass tests or produce a clear handoff.

## License

MIT, following the original continuous-claude project.
