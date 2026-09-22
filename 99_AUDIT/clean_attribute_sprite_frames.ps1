$base = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit\01_ASSETS\kataklysma\sprites\attribute_sets'
$work = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit\99_AUDIT\_connected_component_work'
$magick = 'C:\Program Files\ImageMagick-7.1.2-Q16\magick.exe'
$minimumArea = 200

New-Item -ItemType Directory -Force -Path $work | Out-Null

function Get-ForegroundComponents($path) {
    $raw = (& $magick $path -alpha extract -threshold 50% -define connected-components:verbose=true -connected-components 8 null: 2>&1) -join "`n"
    $components = @()
    foreach ($line in ($raw -split "`n")) {
        if ($line -match '^\s*(\d+):\s+\d+x\d+\+[-\d]+\+[-\d]+\s+[-\d.]+,[-\d.]+\s+(\d+)\s+srgb\(255,255,255\)') {
            $components += [pscustomobject]@{ Id = [int]$matches[1]; Area = [int]$matches[2] }
        }
    }
    if ($components.Count -eq 0) {
        return @(0)
    }
    $largest = ($components | Sort-Object Area -Descending | Select-Object -First 1).Area
    return @($components | Where-Object { $_.Area -eq $largest -or $_.Area -ge $minimumArea } | Select-Object -ExpandProperty Id)
}

foreach ($frame in Get-ChildItem $base -Recurse -File -Filter '*.png' | Where-Object { $_.Directory.Name -ne 'SHEETS' }) {
    $ids = Get-ForegroundComponents $frame.FullName
    $expr = ($ids | ForEach-Object { 'u==' + $_ + '/65535' }) -join '||'
    $mask = Join-Path $work ($frame.BaseName + '_mask.png')
    $clean = Join-Path $work ($frame.BaseName + '_clean.png')
    & $magick $frame.FullName -alpha extract -threshold 50% -connected-components 8 -fx ("(" + $expr + ")?1:0") -threshold 50% $mask
    & $magick $frame.FullName $mask -compose CopyOpacity -composite -strip $clean
    Move-Item -LiteralPath $clean -Destination $frame.FullName -Force
    Remove-Item -LiteralPath $mask -Force
}

foreach ($set in Get-ChildItem $base -Directory) {
    $root = $set.FullName
    $frames = @{}
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT')) {
        $frames[$anim] = @(Get-ChildItem (Join-Path $root $anim) -File -Filter '*.png' | Sort-Object Name | Select-Object -ExpandProperty FullName)
    }

    $idleWalk = Join-Path $root 'SHEETS' ('kataklysma_' + $set.Name + '_sheet_idle_walk.png')
    $castCombat = Join-Path $root 'SHEETS' ('kataklysma_' + $set.Name + '_sheet_cast_combat.png')
    $all = Join-Path $root 'SHEETS' ('kataklysma_' + $set.Name + '_sheet_all.png')
    $idleWalkTemp = Join-Path $work ($set.Name + '_idle_walk.png')
    $castCombatTemp = Join-Path $work ($set.Name + '_cast_combat.png')
    $allTemp = Join-Path $work ($set.Name + '_all.png')
    $idleRow = Join-Path $work ($set.Name + '_idle_row.png')
    $walkRow = Join-Path $work ($set.Name + '_walk_row.png')
    $castRow = Join-Path $work ($set.Name + '_cast_row.png')
    $combatRow = Join-Path $work ($set.Name + '_combat_row.png')

    & $magick $frames['IDLE'][0] $frames['IDLE'][1] $frames['IDLE'][2] $frames['IDLE'][3] +append $idleRow
    & $magick $frames['WALK'][0] $frames['WALK'][1] $frames['WALK'][2] $frames['WALK'][3] +append $walkRow
    & $magick $frames['CAST'][0] $frames['CAST'][1] $frames['CAST'][2] $frames['CAST'][3] +append $castRow
    & $magick $frames['COMBAT'][0] $frames['COMBAT'][1] $frames['COMBAT'][2] $frames['COMBAT'][3] +append $combatRow
    & $magick $idleRow $walkRow -append $idleWalkTemp
    & $magick $castRow $combatRow -append $castCombatTemp
    $rows = @()
    foreach ($anim in @('IDLE', 'WALK', 'CAST', 'COMBAT')) {
        $row = Join-Path $work ($set.Name + '_' + $anim.ToLower() + '_row.png')
        & $magick $frames[$anim][0] $frames[$anim][1] $frames[$anim][2] $frames[$anim][3] +append $row
        $rows += $row
    }
    & $magick $rows -append $allTemp

    Move-Item -LiteralPath $idleWalkTemp -Destination $idleWalk -Force
    Move-Item -LiteralPath $castCombatTemp -Destination $castCombat -Force
    Move-Item -LiteralPath $allTemp -Destination $all -Force
    Remove-Item -LiteralPath (($rows + @($idleRow, $walkRow, $castRow, $combatRow)) | Sort-Object -Unique) -Force -ErrorAction SilentlyContinue
    Write-Output ($set.Name + ' cleaned')
}

Write-Output 'QA cleanup complete'
