param(
    [string]$RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot ".."))
)

$ErrorActionPreference = "Stop"
$manifestPath = Join-Path $RepositoryRoot "02_REFERENCE\00_CONTINUITY\character_continuity_manifest.json"
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$targets = @($manifest.characters | Where-Object { $_.type -in @("npc", "entity") })
$missing = [System.Collections.Generic.List[string]]::new()

foreach ($character in $targets) {
    $expectedName = "identity_lock_{0}_v001.png" -f $character.id
    $lockReference = @($character.canonical_references | Where-Object { $_ -match [regex]::Escape("identity_locks/$expectedName") })

    if ($character.status -ne "production_locked_v002") {
        $missing.Add("$($character.id): status is not production_locked_v002")
    }

    if ($lockReference.Count -ne 1) {
        $missing.Add("$($character.id): manifest does not contain exactly one $expectedName reference")
        continue
    }

    $relativePath = $lockReference[0] -replace "^res://", "" -replace "/", "\"
    $absolutePath = Join-Path $RepositoryRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        $missing.Add("$($character.id): missing file $relativePath")
    }
}

Write-Output ("Identity locks checked: {0}" -f $targets.Count)
if ($missing.Count -gt 0) {
    $missing | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Identity lock validation: PASS"
