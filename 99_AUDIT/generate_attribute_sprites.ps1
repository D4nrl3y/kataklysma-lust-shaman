$base = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit\01_ASSETS\kataklysma\sprites\attribute_sets'
$gen = 'C:\Users\danrl\.codex\generated_images\01a0c6e3-3c0e-7ca2-99d8-900b438cf3d8'
$magick = 'C:\Program Files\ImageMagick-7.1.2-Q16\magick.exe'

$sources = @{
    agility    = 'exec-12fc5030-3160-494d-bf43-e800dd3fa336.png'
    stamina    = 'exec-6e9eebfe-121f-43f3-b70f-9461c7ce03a6.png'
    intellect  = 'exec-225c8a71-6433-4c95-92c2-8214b71aefac.png'
    spirit     = 'exec-aeea7aa0-f5bf-416b-b1aa-7526251b0918.png'
    lust       = 'exec-e36c2b82-2da5-40e6-b079-d3cccccd85d8.png'
    corruption = 'exec-45938971-0662-44dc-9278-9b5dec1a0a95.png'
}

New-Item -ItemType Directory -Force -Path $base | Out-Null
$rowNumbers = @{ IDLE = 0; WALK = 1; CAST = 2; COMBAT = 3 }

foreach ($key in $sources.Keys) {
    $root = Join-Path $base ($key + '_max')
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT', 'SHEETS')) {
        New-Item -ItemType Directory -Force -Path (Join-Path $root $anim) | Out-Null
    }

    $src = Join-Path $gen $sources[$key]
    $frames = @{}

    foreach ($anim in $rowNumbers.Keys) {
        $frames[$anim] = @()
        for ($i = 0; $i -lt 4; $i++) {
            $crop = '384x256+' + ($i * 384) + '+' + ($rowNumbers[$anim] * 256)
            $out = Join-Path $root $anim ('kataklysma_' + $key + '_max_' + $anim.ToLower() + '_' + ('{0:D3}' -f ($i + 1)) + '.png')
            & $magick $src -channel A -threshold 2% +channel -crop $crop +repage -filter point -resize '543x362!' -strip $out
            $frames[$anim] += $out
        }
    }

    $idleRow = Join-Path $root 'SHEETS' ($key + '_idle_row.png')
    $walkRow = Join-Path $root 'SHEETS' ($key + '_walk_row.png')
    $castRow = Join-Path $root 'SHEETS' ($key + '_cast_row.png')
    $combatRow = Join-Path $root 'SHEETS' ($key + '_combat_row.png')
    & $magick $frames['IDLE'][0] $frames['IDLE'][1] $frames['IDLE'][2] $frames['IDLE'][3] +append $idleRow
    & $magick $frames['WALK'][0] $frames['WALK'][1] $frames['WALK'][2] $frames['WALK'][3] +append $walkRow
    & $magick $frames['CAST'][0] $frames['CAST'][1] $frames['CAST'][2] $frames['CAST'][3] +append $castRow
    & $magick $frames['COMBAT'][0] $frames['COMBAT'][1] $frames['COMBAT'][2] $frames['COMBAT'][3] +append $combatRow

    $idleWalk = Join-Path $root 'SHEETS' ('kataklysma_' + $key + '_max_sheet_idle_walk.png')
    & $magick $idleRow $walkRow -append $idleWalk

    $castCombat = Join-Path $root 'SHEETS' ('kataklysma_' + $key + '_max_sheet_cast_combat.png')
    & $magick $castRow $combatRow -append $castCombat

    $all = Join-Path $root 'SHEETS' ('kataklysma_' + $key + '_max_sheet_all.png')
    $rows = @()
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT')) {
        $rowFile = Join-Path $root 'SHEETS' ($key + '_' + $anim.ToLower() + '_row.png')
        & $magick $frames[$anim][0] $frames[$anim][1] $frames[$anim][2] $frames[$anim][3] +append $rowFile
        $rows += $rowFile
    }
    & $magick $rows -append $all
    Remove-Item -LiteralPath $rows -Force
    Write-Output ($key + ' complete')
}

Write-Output ('OUTPUT=' + $base)
