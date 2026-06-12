#!/usr/bin/env pwsh

$runner = Join-Path $PSScriptRoot "continuous-claude-deepseek.ps1"
& pwsh $runner --provider codex @args
