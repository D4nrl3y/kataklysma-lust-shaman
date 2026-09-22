$ErrorActionPreference = 'Stop'

$kit = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit'
$assets = Join-Path $kit '01_ASSETS\kataklysma'
$sourceDir = Join-Path $kit '99_AUDIT\ENTITY_SPRITE_SOURCES'
$workDir = Join-Path $kit '99_AUDIT\_entity_sprite_work'
$magick = 'C:\Program Files\ImageMagick-7.1.2-Q16\magick.exe'

$sources = [ordered]@{
    weakened_water_spirit = @{ file = 'entity_weakened_water_spirit_sprite_sheet_raw.png'; second = 'WALK' }
    corrupted_makrura = @{ file = 'entity_corrupted_makrura_sprite_sheet_raw.png'; second = 'COMBAT' }
    eye_of_storm_avatar = @{ file = 'entity_eye_of_storm_avatar_sprite_sheet_raw.png'; second = 'CAST' }
}

New-Item -ItemType Directory -Force -Path $sourceDir, $workDir | Out-Null

foreach ($key in $sources.Keys) {
    $src = Join-Path $sourceDir $sources[$key].file
    if (-not (Test-Path -LiteralPath $src)) { throw "Fonte ausente: $src" }
    $entityRoot = Join-Path $assets "character\entities\sprites\$key"
    $idleDir = Join-Path $entityRoot 'IDLE'
    $secondDir = Join-Path $entityRoot $sources[$key].second
    $sheetDir = Join-Path $entityRoot 'SHEETS'
    New-Item -ItemType Directory -Force -Path $idleDir, $secondDir, $sheetDir | Out-Null

    $tilePrefix = Join-Path $workDir ("{0}_tile" -f $key)
    Get-ChildItem -LiteralPath $workDir -File -Filter ("{0}_tile-*.png" -f $key) -ErrorAction SilentlyContinue | Remove-Item -Force
    & $magick $src -crop '4x2@' +repage ("{0}-%02d.png" -f $tilePrefix)
    $tiles = Get-ChildItem -LiteralPath $workDir -File -Filter ("{0}_tile-*.png" -f $key) | Sort-Object Name
    if ($tiles.Count -ne 8) { throw "Esperados 8 tiles para $key, encontrados $($tiles.Count)" }

    $idleFrames = @()
    $secondFrames = @()
    for ($i = 0; $i -lt 8; $i++) {
        $tile = $tiles[$i].FullName
        if ($i -lt 4) { $anim = 'idle'; $dir = $idleDir; $frame = $i + 1; $list = 'idle' }
        else { $anim = $sources[$key].second.ToLower(); $dir = $secondDir; $frame = $i - 3; $list = 'second' }
        $out = Join-Path $dir ("entity_{0}_{1}_{2:D3}.png" -f $key, $anim, $frame)
        & $magick $tile -alpha on -channel A -threshold 2% +channel -trim +repage -filter point -resize x340 -gravity South -background none -extent 543x362 -strip $out
        if ($list -eq 'idle') { $idleFrames += $out } else { $secondFrames += $out }
    }

    $idleRow = Join-Path $workDir ("{0}_idle_row.png" -f $key)
    $secondRow = Join-Path $workDir ("{0}_{1}_row.png" -f $key, $sources[$key].second.ToLower())
    $sheet = Join-Path $sheetDir ("entity_{0}_sheet_idle_{1}.png" -f $key, $sources[$key].second.ToLower())
    & $magick @idleFrames +append $idleRow
    & $magick @secondFrames +append $secondRow
    & $magick $idleRow $secondRow -append -strip $sheet
}

Write-Output "Sprites de entidades processados: $($sources.Count)"
