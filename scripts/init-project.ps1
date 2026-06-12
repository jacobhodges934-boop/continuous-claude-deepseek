param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Copy-TemplateFile {
    param(
        [string]$TemplatePath,
        [string]$TargetPath,
        [string]$FallbackContent
    )

    if ((Test-Path -Path $TargetPath) -and -not $Force) {
        Write-Host "exists, skipped: $TargetPath"
        return
    }

    $content = if (Test-Path -Path $TemplatePath) {
        [System.IO.File]::ReadAllText($TemplatePath, $utf8)
    } else {
        $FallbackContent
    }
    Write-Utf8File $TargetPath $content
    Write-Host "created: $TargetPath"
}

if (-not (Test-Path -Path $ProjectPath)) {
    throw "Project path does not exist: $ProjectPath"
}

$resolvedProject = (Resolve-Path -Path $ProjectPath).Path
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$templateDocs = Join-Path $repoRoot "templates\continuous-project\docs"

$targetDocs = Join-Path $resolvedProject "docs"
New-Item -ItemType Directory -Force -Path $targetDocs | Out-Null

$nextTasks = @'
# NEXT_TASKS

Write the next project tasks here. Keep tasks small enough for one PR.

## Priority Tasks

1. [ ] Replace this with the highest-priority task.
   - Goal:
   - Files likely involved:
   - Verification:
   - Notes:

2. [ ] Replace this with the second-priority task.
   - Goal:
   - Files likely involved:
   - Verification:
   - Notes:

## Waiting / Needs Human Input

- [ ] Put unclear, risky, or blocked work here.

## Done

- Move completed tasks here with PR numbers or dates.
'@

$sharedNotes = @'
# SHARED_TASK_NOTES

This file gives each automation iteration enough project context to continue safely.

## Project Context

- Project goal:
- Current phase:
- Main stack:
- GitHub repo:
- Important commands:

## Automation Rules

- Read `docs/NEXT_TASKS.md` before choosing work.
- Pick one small, verifiable task per iteration.
- Keep changes scoped. Do not rewrite unrelated code.
- Run the most relevant tests or checks before finishing.
- Update `docs/HANDOFF.md` and task status after each iteration.

## Known Risks / Constraints

- 

## Useful Local Commands

```powershell
# Add project-specific commands here, for example:
# npm test
# npm run lint
```
'@

$handoff = @'
# HANDOFF

Use this file for the latest automation handoff. Keep it short and practical.

## Latest Handoff

- Date:
- Iteration goal:
- Completed:
- Changed files:
- Verification:
- Known issues:
- Next recommended step:

## History

Append older entries below, newest first.
'@

Copy-TemplateFile (Join-Path $templateDocs "NEXT_TASKS.md") (Join-Path $targetDocs "NEXT_TASKS.md") $nextTasks
Copy-TemplateFile (Join-Path $templateDocs "SHARED_TASK_NOTES.md") (Join-Path $targetDocs "SHARED_TASK_NOTES.md") $sharedNotes
Copy-TemplateFile (Join-Path $templateDocs "HANDOFF.md") (Join-Path $targetDocs "HANDOFF.md") $handoff

$prompt = "Read docs/NEXT_TASKS.md, docs/SHARED_TASK_NOTES.md, and docs/HANDOFF.md. Pick the highest-priority task that can be completed and verified in one small iteration. Do not expand scope. After finishing, run relevant checks and update the docs."

Write-Host ""
Write-Host "Project automation docs are ready."
Write-Host "Project: $resolvedProject"
Write-Host ""
Write-Host "Example Claude Code run:"
Write-Host "pwsh path\to\continuous-claude-deepseek.ps1 --provider claude --prompt `"$prompt`" --max-runs 3 --merge-strategy squash"
Write-Host ""
Write-Host "Example Codex CLI run:"
Write-Host "pwsh path\to\continuous-claude-deepseek.ps1 --provider codex --prompt `"$prompt`" --max-runs 3 --merge-strategy squash"
