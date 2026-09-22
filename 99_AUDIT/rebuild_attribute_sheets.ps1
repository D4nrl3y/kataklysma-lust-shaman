$base = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit\01_ASSETS\kataklysma\sprites\attribute_sets'
$work = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit\99_AUDIT\_sheet_rebuild_work'
$magick = 'C:\Program Files\ImageMagick-7.1.2-Q16\magick.exe'

New-Item -ItemType Directory -Force -Path $work | Out-Null

foreach ($set in Get-ChildItem $base -Directory) {
    $root = $set.FullName
    $frames = @{}
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT')) {
        $frames[$anim] = @(Get-ChildItem (Join-Path $root $anim) -File -Filter '*.png' | Sort-Object Name | Select-Object -ExpandProperty FullName)
    }

    $rowFiles = @{}
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT')) {
        $row = Join-Path $work ($set.Name + '_' + $anim.ToLower() + '_row.png')
        & $magick $frames[$anim][0] $frames[$anim][1] $frames[$anim][2] $frames[$anim][3] +append $row
        $rowFiles[$anim] = $row
    }

    $idleWalkTemp = Join-Path $work ($set.Name + '_idle_walk.png')
    $castCombatTemp = Join-Path $work ($set.Name + '_cast_combat.png')
    $allTemp = Join-Path $work ($set.Name + '_all.png')
    & $magick $rowFiles['IDLE'] $rowFiles['WALK'] -append $idleWalkTemp
    & $magick $rowFiles['CAST'] $rowFiles['COMBAT'] -append $castCombatTemp
    & $magick $rowFiles['IDLE'] $rowFiles['WALK'] $rowFiles['CAST'] $rowFiles['COMBAT'] -append $allTemp

    Move-Item -LiteralPath $idleWalkTemp -Destination (Join-Path (Join-Path $root 'SHEETS') ('kataklysma_' + $set.Name + '_sheet_idle_walk.png')) -Force
    Move-Item -LiteralPath $castCombatTemp -Destination (Join-Path (Join-Path $root 'SHEETS') ('kataklysma_' + $set.Name + '_sheet_cast_combat.png')) -Force
    Move-Item -LiteralPath $allTemp -Destination (Join-Path (Join-Path $root 'SHEETS') ('kataklysma_' + $set.Name + '_sheet_all.png')) -Force
    Write-Output ($set.Name + ' sheets rebuilt')
}

Write-Output 'Sheet rebuild complete'
