# Install continuous-claude-deepseek
$INSTALL_DIR = if ($env:INSTALL_DIR) { $env:INSTALL_DIR } else { Join-Path $HOME ".local\bin" }
New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
$URL = "https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/continuous-claude-deepseek.ps1"
Invoke-WebRequest -Uri $URL -OutFile (Join-Path $INSTALL_DIR "continuous-claude-deepseek.ps1")
Write-Host "Installed to $INSTALL_DIR\continuous-claude-deepseek.ps1"
Write-Host "Usage: pwsh $INSTALL_DIR\continuous-claude-deepseek.ps1 --prompt 'task' --max-runs 3"
