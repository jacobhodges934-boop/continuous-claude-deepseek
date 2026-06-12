# Install continuous-claude-deepseek
$INSTALL_DIR = if ($env:INSTALL_DIR) { $env:INSTALL_DIR } else { Join-Path $HOME ".local\bin" }
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null

$BASE_URL = "https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main"
Invoke-WebRequest -Uri "$BASE_URL/continuous-claude-deepseek.ps1" -OutFile (Join-Path $INSTALL_DIR "continuous-claude-deepseek.ps1")
Invoke-WebRequest -Uri "$BASE_URL/scripts/init-project.ps1" -OutFile (Join-Path $INSTALL_DIR "init-continuous-project.ps1")

Write-Host "Installed to $INSTALL_DIR"
Write-Host ""
Write-Host "Initialize a project:"
Write-Host "  pwsh $INSTALL_DIR\init-continuous-project.ps1"
Write-Host ""
Write-Host "Run automation:"
Write-Host "  pwsh $INSTALL_DIR\continuous-claude-deepseek.ps1 --provider claude --prompt 'Read docs/NEXT_TASKS.md and continue one small verified task.' --max-runs 3"
