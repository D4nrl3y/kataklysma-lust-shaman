param(
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$manifestPath = Join-Path $RepositoryRoot '03_GODOT\data\cg_variants.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$missing = @()
$complete = 0

foreach ($scene in $manifest.scenes) {
    if ($scene.files.Count -ne $manifest.variant_count) {
        $missing += "$($scene.id): expected $($manifest.variant_count) files, found $($scene.files.Count)"
        continue
    }

    $sceneMissing = @($scene.files | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $RepositoryRoot "01_ASSETS\kataklysma\cg\scenes\VARIANTS\$_"))
    })
    if ($sceneMissing.Count -gt 0) {
        $missing += "$($scene.id): missing $($sceneMissing -join ', ')"
    } else {
        $complete++
    }
}

Write-Output "CG scenes complete: $complete/$($manifest.scenes.Count)"
if ($missing.Count -gt 0) {
    Write-Output 'Scenes requiring production:'
    $missing | ForEach-Object { Write-Output "- $_" }
    exit 1
}

Write-Output 'All CG scenes contain the required four distinct files.'

