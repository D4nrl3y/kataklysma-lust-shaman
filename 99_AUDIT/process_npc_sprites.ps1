$ErrorActionPreference = 'Stop'

$kit = 'C:\Users\danrl\Downloads\Kataklysma\Kataklysma_Dev_Kit'
$assets = Join-Path $kit '01_ASSETS\kataklysma'
$sourceDir = Join-Path $kit '99_AUDIT\NPC_SPRITE_SOURCES'
$workDir = Join-Path $kit '99_AUDIT\_npc_sprite_work'
$magick = 'C:\Program Files\ImageMagick-7.1.2-Q16\magick.exe'

if (-not (Test-Path -LiteralPath $magick)) {
    throw "ImageMagick não encontrado em $magick"
}

$sources = [ordered]@{
    zekranu = 'npc_zekranu_sprite_sheet_raw.png'
    zalkiri = 'npc_zalkiri_sprite_sheet_raw.png'
    rakjin = 'npc_rakjin_sprite_sheet_raw.png'
    makjala = 'npc_makjala_sprite_sheet_raw.png'
    grikzan = 'npc_grikzan_sprite_sheet_raw.png'
    vexa_geargrin = 'npc_vexa_geargrin_sprite_sheet_raw.png'
    korgash = 'npc_korgash_sprite_sheet_raw.png'
    azkarra = 'npc_azkarra_sprite_sheet_raw.png'
    tazrima = 'npc_tazrima_sprite_sheet_raw.png'
    mokjala = 'npc_mokjala_sprite_sheet_raw.png'
    rukka = 'npc_rukka_sprite_sheet_raw.png'
    razzik_coilthumb = 'npc_razzik_coilthumb_sprite_sheet_raw.png'
    sister_aruka = 'npc_sister_aruka_sprite_sheet_raw.png'
}

New-Item -ItemType Directory -Force -Path $sourceDir, $workDir | Out-Null

foreach ($key in $sources.Keys) {
    $src = Join-Path $sourceDir $sources[$key]
    if (-not (Test-Path -LiteralPath $src)) {
        throw "Fonte ausente: $src"
    }

    $npcRoot = Join-Path $assets "sprites\npcs\$key"
    $idleDir = Join-Path $npcRoot 'IDLE'
    $walkDir = Join-Path $npcRoot 'WALK'
    $sheetDir = Join-Path $npcRoot 'SHEETS'
    New-Item -ItemType Directory -Force -Path $idleDir, $walkDir, $sheetDir | Out-Null

    $idleFrames = @()
    $walkFrames = @()
    for ($col = 0; $col -lt 4; $col++) {
        $idleIndex = $col + 1
        $walkIndex = $col + 1
        $x = $col * 384

        $idleOut = Join-Path $idleDir ("npc_{0}_idle_{1:D3}.png" -f $key, $idleIndex)
        $walkOut = Join-Path $walkDir ("npc_{0}_walk_{1:D3}.png" -f $key, $walkIndex)
        $idleCrop = "384x512+${x}+0"
        $walkCrop = "384x512+${x}+512"

        # Alpha threshold removes faint background noise while preserving the sprite colors.
        & $magick $src -crop $idleCrop +repage -alpha on -channel A -threshold 2% +channel -trim +repage -filter point -resize x340 -gravity South -background none -extent 543x362 -strip $idleOut
        & $magick $src -crop $walkCrop +repage -alpha on -channel A -threshold 2% +channel -trim +repage -filter point -resize x340 -gravity South -background none -extent 543x362 -strip $walkOut

        $idleFrames += $idleOut
        $walkFrames += $walkOut
    }

    $idleRow = Join-Path $workDir ("{0}_idle_row.png" -f $key)
    $walkRow = Join-Path $workDir ("{0}_walk_row.png" -f $key)
    $allSheet = Join-Path $sheetDir ("npc_{0}_sheet_idle_walk.png" -f $key)
    & $magick @idleFrames +append $idleRow
    & $magick @walkFrames +append $walkRow
    & $magick $idleRow $walkRow -append -strip $allSheet
}

Write-Output "Sprites NPC processados: $($sources.Count) personagens"
