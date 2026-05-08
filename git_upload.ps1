param()
$ErrorActionPreference = "Stop"

# -- Fixed settings ---------------------------------
$GITHUB_ID  = "bjiyoung"
$REPO_NAME  = "qbittorrent-5.2.0"
$SOURCE_DIR = "D:\qbittorrent-5.2.0"
# ---------------------------------------------------

Write-Host ""
Write-Host "=== qBittorrent GitHub Upload Tool ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "  GitHub  : $GITHUB_ID" -ForegroundColor White
Write-Host "  Repo    : $REPO_NAME" -ForegroundColor White
Write-Host "  Source  : $SOURCE_DIR" -ForegroundColor White
Write-Host ""

# Step 1
Write-Host "[1/4] Moving to source folder..." -ForegroundColor Yellow
if (-not (Test-Path $SOURCE_DIR)) {
    Write-Host "ERROR: Folder not found: $SOURCE_DIR" -ForegroundColor Red
    Read-Host "Press Enter to exit"; exit 1
}
Set-Location $SOURCE_DIR
Write-Host "  Done" -ForegroundColor Green

# Step 2
Write-Host "[2/4] Creating GitHub Actions workflow..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Copy-Item (Join-Path $scriptDir "build.yml") (Join-Path $SOURCE_DIR ".github\workflows\build.yml") -Force
Write-Host "  Done" -ForegroundColor Green

# Step 3
Write-Host "[3/4] Git init and commit..." -ForegroundColor Yellow

& git init
& git config user.email "$GITHUB_ID@users.noreply.github.com"
& git config user.name  "$GITHUB_ID"
& git add .

$status = & git status --porcelain
if (-not $status) {
    Write-Host "WARNING: Nothing to commit. Files may already be committed." -ForegroundColor Yellow
} else {
    & git commit -m "Apply custom patches"
}

& git branch -M main
Write-Host "  Done" -ForegroundColor Green

# Step 4
Write-Host ""
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "  Create a GitHub repo now!" -ForegroundColor Magenta
Write-Host ""
Write-Host "  1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "  2. Repository name: $REPO_NAME" -ForegroundColor White
Write-Host "  3. Uncheck 'Add a README file'" -ForegroundColor White
Write-Host "  4. Click [Create repository]" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Magenta
Write-Host ""
Read-Host "[4/4] Press Enter after creating the repo"

# Remove existing remote if any
$remotes = & git remote
if ($remotes -contains "origin") {
    & git remote remove origin
}

& git remote add origin "https://github.com/$GITHUB_ID/$REPO_NAME.git"
& git push -u origin main --force

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Push failed." -ForegroundColor Red
    Write-Host "  - Check repo exists: https://github.com/$GITHUB_ID/$REPO_NAME" -ForegroundColor Red
    Write-Host "  - Make sure 'Add a README file' was NOT checked" -ForegroundColor Red
    Read-Host "Press Enter to exit"; exit 1
}

Write-Host ""
Write-Host "=== Upload complete! ===" -ForegroundColor Green
Write-Host "https://github.com/$GITHUB_ID/$REPO_NAME/actions" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
