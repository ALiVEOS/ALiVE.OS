# Stamps the build number into addons\main\script_mod.hpp immediately before packing.
#
# Called from the Jenkins build step, after the checkout and BEFORE MakePBO runs.
# It edits the working copy only and never commits: the number belongs to the
# artefact, and committing from the build would push to master, which would
# retrigger the build that made it.
#
# BUILD is YYMMDDR - two digit year, month, day, then which build that day.
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

# Past nine builds in a day this grows to eight digits rather than colliding.
# A number that is merely long is harmless; two builds sharing one is not.
$stamp = "$today$n"

$before = Select-String -Path $header -Pattern '^#define BUILD\s+(\S+)' | Select-Object -First 1
$old = if ($before) { $before.Matches[0].Groups[1].Value } else { "unknown" }

$content = Get-Content $header
$updated = $content -replace '^#define BUILD\s+.*', "#define BUILD $stamp"

if (($updated -join "`n") -eq ($content -join "`n")) {
    throw "ALIVE_stamp_build: no '#define BUILD' line was changed in $header"
}

Set-Content -Path $header -Value $updated -Encoding ASCII
Write-Host "ALIVE_stamp_build: BUILD $old -> $stamp (build $n of $today)"
