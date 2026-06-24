param(
  [string]$RepoPath = 'C:\Users\TLSDemo\secureagent-20260623001717',
  [string]$Branch = 'main',
  [string[]]$Files = @('code1.ps','code2.py','donotdelete.txt')
)

# Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error 'git not found. Ensure Git is installed and on PATH.'; exit 1
}

if (-not (Test-Path -LiteralPath $RepoPath)) { Write-Error "Repo path not found: $RepoPath"; exit 1 }
if (-not (Test-Path (Join-Path $RepoPath '.git'))) { Write-Error "Not a git repository: $RepoPath"; exit 1 }

Push-Location $RepoPath
try {
  git checkout $Branch
  git pull origin $Branch

  foreach ($f in $Files) {
    if (-not (Test-Path -LiteralPath $f)) { Write-Error "Missing file: $f"; exit 1 }
  }

  git add -- $Files
  $commitMsg = "Add files: $($Files -join ', ')"
  $coAuthor = "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  git commit -m "$commitMsg" -m "$coAuthor" 2>&1 | Write-Output

  if ($LASTEXITCODE -eq 0) {
    Write-Output "Pushing to origin/$Branch..."
    git push origin $Branch 2>&1 | Write-Output
  } else {
    Write-Output "No changes to commit or commit failed."
  }
} finally {
  Pop-Location
}
