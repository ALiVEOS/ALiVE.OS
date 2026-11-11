# Stamps the build number into addons\main\script_mod.hpp immediately before packing.
#
# Called from the Jenkins build step, after the checkout and BEFORE MakePBO runs.
# It edits the working copy only and never commits: the number belongs to the
# artefact, and committing from the build would push to master, which would
# retrigger the build that made it.
#
# BUILD is YYMMDDR - two digit year, month, day, then which build that day:
# 1 to 9, then a letter from the tenth (10 = a ... 35 = z), so it stays seven
# characters. BUILD_NUM is the same build as a number for the config's
# versionAr[], which CBA compares: YY * 100000 + day of the year * 100 + build.
# The checkout resets every tracked file, so script_mod.hpp cannot carry the
# day's count from one build to the next. An untracked file beside it can, and
# the job has no workspace wipe, so it survives. If that file is ever lost the
# count simply restarts at 1 for the day, which costs nothing.
#
# Author: Jman

$ErrorActionPreference = "Stop"

# Jenkins sets WORKSPACE. Fall back to the repo root two levels up so this can be
# run by hand from a checkout without guessing paths.
$root = $env:WORKSPACE
if ([string]::IsNullOrWhiteSpace($root)) {
    $root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
    Write-Host "ALIVE_stamp_build: WORKSPACE not set, using $root"
}

$header  = Join-Path $root "addons\main\script_mod.hpp"
$counter = Join-Path $root ".buildstamp"

if (-not (Test-Path $header)) {
    throw "ALIVE_stamp_build: cannot find $header"
}

$today = (Get-Date).ToString("yyMMdd")

# Which build of today is this? The counter file holds "<yymmdd> <n>".
$n = 1
if (Test-Path $counter) {
    $parts = (Get-Content $counter -First 1).Split(" ")
    if ($parts.Count -ge 2 -and $parts[0] -eq $today) {
        $n = [int]$parts[1] + 1
    }
}
"$today $n" | Set-Content $counter -Encoding ASCII

# Past nine builds in a day R becomes a letter; past 35 there is no letter left,
# and failing the build is better than two builds sharing a stamp.
if ($n -gt 35) { throw "ALIVE_stamp_build: build $n of $today, past the last letter (z = 35)" }
$r = if ($n -le 9) { "$n" } else { [string][char]([int][char]'a' + $n - 10) }
$stamp = "$today$r"
$now = [datetime]::ParseExact($today, 'yyMMdd', $null)
$stampNum = ($now.Year % 100) * 100000 + $now.DayOfYear * 100 + $n

$before = Select-String -Path $header -Pattern '^#define BUILD\s+(\S+)' | Select-Object -First 1
$old = if ($before) { $before.Matches[0].Groups[1].Value } else { "unknown" }

$content = Get-Content $header
$updated = $content -replace '^#define BUILD\s+.*', "#define BUILD $stamp"
$updated = $updated -replace '^#define BUILD_NUM\s+.*', "#define BUILD_NUM $stampNum"

if (($updated -join "`n") -eq ($content -join "`n")) {
    throw "ALIVE_stamp_build: no '#define BUILD' line was changed in $header"
}

if (-not ($updated -match "^#define BUILD_NUM $stampNum$")) {
    throw "ALIVE_stamp_build: no '#define BUILD_NUM' line in $header"
}

Set-Content -Path $header -Value $updated -Encoding ASCII
Write-Host "ALIVE_stamp_build: BUILD $old -> $stamp, BUILD_NUM $stampNum (build $n of $today)"
