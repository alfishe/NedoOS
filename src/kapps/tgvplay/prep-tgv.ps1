# Prepare a video for the ZX Spectrum converter (to8c8snd, 16col).
# How to run it and which converter fields to set: prep-tgv.md
# BMP 256x192 named <stem>00000.bmp and <stem>.wav (44 kHz stereo 16-bit)
# sit in one folder. Paste the printed path into the converter.
#
#   .\prep-tgv.ps1 .\MyVideos
#   .\prep-tgv.ps1 .\clip.mp4 -Fps 15
#   .\prep-tgv.ps1 .\clip.mp4 -Mode fit -Start 12 -Duration 40
#
# -Mode crop  fill 256x192, cut the sides or the top (default)
# -Mode fit   whole frame, black bars
# -Fps        frames per second written out. 15 matches the converter's 225 cells.

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputPath,
    [string]$OutDir = '',
    [double]$Fps = 15,
    [ValidateSet('crop', 'fit')]
    [string]$Mode = 'crop',
    [double]$Start = 0,
    [double]$Duration = 0,
    [int]$Digits = 5,
    [string]$Ffmpeg = ''
)

$ErrorActionPreference = 'Stop'
if ($Fps -le 0) { throw 'Fps must be greater than 0' }
if ($Digits -lt 3 -or $Digits -gt 6) { throw 'Digits must be 3..6 (the converter only accepts those)' }

function Find-Bin([string]$Name, [string]$Explicit) {
    if ($Explicit -and (Test-Path -LiteralPath $Explicit)) { return (Resolve-Path -LiteralPath $Explicit).Path }
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $roots = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages')
    )
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        $hit = Get-ChildItem -LiteralPath $root -Filter "$Name.exe" -Recurse -ErrorAction SilentlyContinue |
            Select-Object -First 1 -ExpandProperty FullName
        if ($hit) { return $hit }
    }
    return $null
}

$ffmpegExe = Find-Bin 'ffmpeg' $Ffmpeg
if (-not $ffmpegExe) {
    throw "ffmpeg not found. Install it with: winget install Gyan.FFmpeg"
}
$ffprobeExe = Join-Path (Split-Path -Parent $ffmpegExe) 'ffprobe.exe'
if (-not (Test-Path -LiteralPath $ffprobeExe)) {
    $ffprobeExe = Find-Bin 'ffprobe' ''
}
if (-not $ffprobeExe) { throw "ffprobe not found next to $ffmpegExe" }

function Get-Slug([string]$Name) {
    $s = [regex]::Replace($Name.ToLowerInvariant(), '[^a-z0-9]+', '-').Trim('-')
    if (-not $s) { $s = 'clip' }
    if ($s.Length -gt 24) { $s = $s.Substring(0, 24).Trim('-') }
    return $s
}

function Get-MaxCells([double]$Rate) {
    # The converter's own table: cells per frame so the stream keeps up with 17500 Hz sound.
    $table = @(
        @{ Fps = 10; Cells = 338 },
        @{ Fps = 15; Cells = 225 },
        @{ Fps = 20; Cells = 169 },
        @{ Fps = 24; Cells = 141 },
        @{ Fps = 25; Cells = 135 },
        @{ Fps = 30; Cells = 113 }
    )
    foreach ($row in $table) {
        if ([math]::Abs($Rate - $row.Fps) -lt 0.05) { return $row.Cells }
    }
    $n = [int][math]::Round(3380.0 / $Rate)
    if ($n -lt 40) { $n = 40 }
    if ($n -gt 400) { $n = 400 }
    return $n
}

function Convert-One([string]$Video, [string]$DestRoot) {
    $probeJson = & $ffprobeExe -v error -show_entries format=duration -show_entries stream=codec_type,width,height,avg_frame_rate -of json -- $Video
    if ($LASTEXITCODE -ne 0) { throw "ffprobe failed on $Video" }
    $probe = $probeJson | ConvertFrom-Json
    $vstream = @($probe.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1)
    $audio = @($probe.streams | Where-Object { $_.codec_type -eq 'audio' })
    if (-not $vstream[0]) { throw "no video stream in $Video" }
    $srcDur = 0.0
    if ($probe.format.duration) { $srcDur = [double]$probe.format.duration }
    $useDur = $srcDur - $Start
    if ($Duration -gt 0 -and ($useDur -le 0 -or $Duration -lt $useDur)) { $useDur = $Duration }
    if ($useDur -lt 0) { $useDur = 0 }

    $stem = Get-Slug ([IO.Path]::GetFileNameWithoutExtension($Video))
    $dir = Join-Path $DestRoot $stem
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Get-ChildItem -LiteralPath $dir -File | Where-Object {
        $_.Extension -eq '.bmp' -or $_.Extension -eq '.wav' -or $_.Name -eq 'prep.txt'
    } | Remove-Item -Force

    $pattern = Join-Path $dir ($stem + ('%0{0}d.bmp' -f $Digits))
    $wav = Join-Path $dir ($stem + '.wav')

    if ($Mode -eq 'crop') {
        $vf = "fps=$Fps,scale=256:192:force_original_aspect_ratio=increase,crop=256:192,format=bgr24"
    } else {
        $vf = "fps=$Fps,scale=256:192:force_original_aspect_ratio=decrease,pad=256:192:(ow-iw)/2:(oh-ih)/2:black,format=bgr24"
    }

    $seek = @()
    if ($Start -gt 0) { $seek += @('-ss', ('{0}' -f $Start)) }
    if ($Duration -gt 0) { $seek += @('-t', ('{0}' -f $Duration)) }

    Write-Host ""
    Write-Host ("{0}  {1}x{2}  {3} fps source  ->  {4} fps, {5}" -f (Split-Path -Leaf $Video), $vstream[0].width, $vstream[0].height, $vstream[0].avg_frame_rate, $Fps, $Mode)

    $ffArgs = @('-y', '-hide_banner', '-loglevel', 'error') + $seek + @(
        '-i', $Video,
        '-map', '0:v:0', '-an',
        '-vf', $vf,
        '-start_number', '0',
        $pattern
    )
    & $ffmpegExe @ffArgs
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg frame export failed: $Video" }

    if ($audio.Count -eq 0) {
        Write-Host "  no audio track, writing silence"
        $silentDur = $useDur
        if ($silentDur -le 0) { $silentDur = 1 }
        & $ffmpegExe -y -hide_banner -loglevel error -f lavfi -i "anullsrc=r=44100:cl=stereo" -t $silentDur -c:a pcm_s16le $wav
    } else {
        $af = @('-y', '-hide_banner', '-loglevel', 'error') + $seek + @(
            '-i', $Video,
            '-map', '0:a:0', '-vn',
            '-ac', '2', '-ar', '44100', '-c:a', 'pcm_s16le',
            $wav
        )
        & $ffmpegExe @af
    }
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg wav export failed: $Video" }

    $frames = @(Get-ChildItem -LiteralPath $dir -Filter ($stem + '*.bmp') -File)
    $count = $frames.Count
    $last = $count - 1
    if ($last -lt 0) { $last = 0 }
    $cells = Get-MaxCells $Fps
    $prefix = Join-Path $dir $stem

    $note = @(
        "source: $Video",
        ("size: {0}x{1}   source fps: {2}   duration: {3:N1} s" -f $vstream[0].width, $vstream[0].height, $vstream[0].avg_frame_rate, $srcDur),
        "output: 256x192  $Mode  $Fps fps  frames: $count (0..$last)",
        "wav: 44100 Hz stereo 16-bit",
        "",
        "converter (16col on):",
        "  path:       $prefix",
        "  1st frame:  0",
        "  last frame: $last",
        "  frame step: 1",
        "  digits:     $Digits     (path#####.bmp when this is 5)",
        "  cells/frame (the 225 box): $cells",
        ""
    ) -join "`r`n"
    [IO.File]::WriteAllText((Join-Path $dir 'prep.txt'), $note, [Text.UTF8Encoding]::new($true))

    Write-Host "  frames: $count"
    Write-Host "  path:   $prefix"
    Write-Host "  cells:  $cells   (put this in the 225 box, frame step 1, 16col on)"
}

$resolved = (Resolve-Path -LiteralPath $InputPath).Path
$videos = @()
if (Test-Path -LiteralPath $resolved -PathType Container) {
    $videos = @(Get-ChildItem -LiteralPath $resolved -File | Where-Object {
        $_.Extension -match '^\.(mp4|mkv|avi|mov|webm|m4v|wmv)$'
    } | ForEach-Object { $_.FullName })
    if (-not $OutDir) { $OutDir = $resolved }
} else {
    $videos = @($resolved)
    if (-not $OutDir) { $OutDir = Split-Path -Parent $resolved }
}
if ($videos.Count -eq 0) { throw "no video files in $InputPath" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "ffmpeg: $ffmpegExe"
foreach ($v in $videos) {
    Convert-One $v $OutDir
}
Write-Host ""
Write-Host "done. Open prep.txt in each folder and paste path into the converter."
