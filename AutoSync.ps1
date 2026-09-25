param(
    [int]$PollSeconds = 5,
    [int]$SettleSeconds = 10,
    [int]$MinPushSeconds = 20
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$lastPush = [DateTime]::MinValue

Write-Host 'Watching this project. Save files to create a commit and push to GitHub.'
Write-Host 'Keep this window open. Press Ctrl+C to stop.'

while ($true) {
    $changes = & git status --porcelain
    if ($LASTEXITCODE -ne 0) { throw 'Unable to read Git status.' }

    if ($changes) {
        Start-Sleep -Seconds $SettleSeconds
        & git add -A
        if ($LASTEXITCODE -ne 0) { throw 'Unable to stage changes.' }

        & git diff --cached --quiet
        if ($LASTEXITCODE -eq 1) {
            $message = 'Auto save ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            & git commit -m $message
            if ($LASTEXITCODE -ne 0) { throw 'Unable to create a commit.' }
        } elseif ($LASTEXITCODE -ne 0) {
            throw 'Unable to check staged changes.'
        }
    }

    if (((Get-Date) - $lastPush).TotalSeconds -ge $MinPushSeconds) {
        $ahead = & git rev-list --count '@{upstream}..HEAD'
        if ($LASTEXITCODE -eq 0 -and [int]$ahead -gt 0) {
            Write-Host 'Pushing pending commits to GitHub...'
            & git push
            if ($LASTEXITCODE -eq 0) {
                $lastPush = Get-Date
            } else {
                Write-Warning 'Push failed. Will retry while this window remains open.'
                $lastPush = Get-Date
            }
        }
    }

    Start-Sleep -Seconds $PollSeconds
}
