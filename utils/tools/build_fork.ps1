param(
    [string]$StageRoot,
    [string]$ModDirName,
    [string[]]$AddonFilter,
    [switch]$SkipOptional,
    [switch]$KeepTemp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

function Get-ModMetadataValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $content = Get-Content $Path -Raw
    $pattern = '(?m)^\s*' + [regex]::Escape($Key) + '\s*=\s*"([^"]*)";'
    $match = [regex]::Match($content, $pattern)
    if (!$match.Success) {
        throw "Unable to read '$Key' from $Path"
    }

    return $match.Groups[1].Value
}

function New-CleanDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Normalize-NameFilter {
    param(
        [string[]]$NameFilter
    )

    if ($null -eq $NameFilter -or $NameFilter.Count -eq 0) {
        return @()
    }

    $normalized = @()
    foreach ($entry in $NameFilter) {
        if ([string]::IsNullOrWhiteSpace($entry)) {
            continue
        }

        foreach ($name in ($entry -split ",")) {
            $trimmed = $name.Trim()
            if (![string]::IsNullOrWhiteSpace($trimmed)) {
                $normalized += $trimmed
            }
        }
    }

    return @($normalized | Sort-Object -Unique)
}

function Format-NameList {
    param(
        [string[]]$Values
    )

    $Values = @($Values | Where-Object { ![string]::IsNullOrWhiteSpace($_) })
    if ($Values.Count -eq 0) {
        return "(none)"
    }

    return [string]::Join(", ", $Values)
}

function Write-LogFiles {
    param(
        [string[]]$Paths
    )

    foreach ($logPath in $Paths) {
        if (!(Test-Path $logPath)) {
            continue
        }

        foreach ($line in (Get-Content $logPath)) {
            Write-Host $line
        }
    }
}

function Get-AddonDirectories {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,
        [string[]]$NameFilter
    )

    if (!(Test-Path $SourceRoot)) {
        return @()
    }

    $NameFilter = @(Normalize-NameFilter -NameFilter $NameFilter)

    $directories = Get-ChildItem $SourceRoot -Directory | Sort-Object Name

    if ($null -ne $NameFilter -and $NameFilter.Count -gt 0) {
        $lookup = @{}
        foreach ($name in $NameFilter) {
            $lookup[$name.ToLowerInvariant()] = $true
        }

        $directories = @($directories | Where-Object { $lookup.ContainsKey($_.Name.ToLowerInvariant()) })
    }

    return @($directories)
}

function Build-PboSet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,
        [Parameter(Mandatory = $true)]
        [string]$TargetRoot,
        [Parameter(Mandatory = $true)]
        [string]$ScratchRoot,
        [Parameter(Mandatory = $true)]
        [string]$MakePboPath,
        [string[]]$NameFilter
    )

    $built = @()
    $addons = @(Get-AddonDirectories -SourceRoot $SourceRoot -NameFilter $NameFilter)

    if ($addons.Count -eq 0) {
        return $built
    }

    New-Item -ItemType Directory -Path $TargetRoot -Force | Out-Null

    foreach ($addon in $addons) {
        $scratchAddon = Join-Path $ScratchRoot $addon.Name
        $builtPbo = Join-Path $ScratchRoot ($addon.Name + ".pbo")
        $makePboStdoutLog = Join-Path $ScratchRoot ($addon.Name + ".makepbo.stdout.log")
        $makePboStderrLog = Join-Path $ScratchRoot ($addon.Name + ".makepbo.stderr.log")

        Copy-Item $addon.FullName $scratchAddon -Recurse -Force

        $arguments = @(
            "-A",
            "-N",
            "-P",
            "-U",
            "-X=thumbs.db,*.h,*.dep,*.bak,*.png,*.log,*.pew",
            $scratchAddon
        )

        Write-Host ("Packing " + $addon.Name + "...")
        $process = Start-Process -FilePath $MakePboPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow -RedirectStandardOutput $makePboStdoutLog -RedirectStandardError $makePboStderrLog
        if ($process.ExitCode -ne 0) {
            Write-LogFiles -Paths @($makePboStdoutLog, $makePboStderrLog)
            throw "MakePbo failed for $($addon.Name)"
        }

        if (!(Test-Path $builtPbo)) {
            Write-LogFiles -Paths @($makePboStdoutLog, $makePboStderrLog)
            throw "Expected output PBO was not created: $builtPbo"
        }

        Move-Item $builtPbo (Join-Path $TargetRoot ($addon.Name + ".pbo")) -Force
        Remove-Item $scratchAddon -Recurse -Force
        foreach ($logPath in @($makePboStdoutLog, $makePboStderrLog)) {
            if (Test-Path $logPath) {
                Remove-Item $logPath -Force
            }
        }
        $built += $addon.Name
    }

    return $built
}

$repoRoot = Get-RepoRoot
$rootModCpp = Join-Path $repoRoot "mod.cpp"
$makePboPath = Join-Path $repoRoot "utils\tools\mikero\MakePbo.exe"

if (!(Test-Path $makePboPath)) {
    throw "MakePbo.exe not found at $makePboPath"
}

if ([string]::IsNullOrWhiteSpace($ModDirName)) {
    $ModDirName = Get-ModMetadataValue -Path $rootModCpp -Key "dir"
}

if ([string]::IsNullOrWhiteSpace($StageRoot)) {
    $StageRoot = Join-Path $repoRoot "build\workshop"
}

$stagePath = Join-Path $StageRoot $ModDirName
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("alive-fork-build-" + [guid]::NewGuid().ToString("N"))
$tempAddonsRoot = Join-Path $tempRoot "addons"
$tempOptionalRoot = Join-Path $tempRoot "optional"
$addonsTargetRoot = Join-Path $stagePath "addons"
$optionalTargetRoot = Join-Path $stagePath "optional"

try {
    New-CleanDirectory -Path $stagePath
    New-CleanDirectory -Path $tempRoot
    New-Item -ItemType Directory -Path $tempAddonsRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $tempOptionalRoot -Force | Out-Null

    $builtAddons = @(Build-PboSet -SourceRoot (Join-Path $repoRoot "addons") -TargetRoot $addonsTargetRoot -ScratchRoot $tempAddonsRoot -MakePboPath $makePboPath -NameFilter $AddonFilter)

    $builtOptional = @()
    if (!$SkipOptional) {
        $builtOptional = @(Build-PboSet -SourceRoot (Join-Path $repoRoot "optional") -TargetRoot $optionalTargetRoot -ScratchRoot $tempOptionalRoot -MakePboPath $makePboPath -NameFilter $AddonFilter)
        if ($builtOptional.Count -eq 0 -and (Test-Path $optionalTargetRoot)) {
            Remove-Item $optionalTargetRoot -Recurse -Force
        }
    }

    Copy-Item $rootModCpp (Join-Path $stagePath "mod.cpp") -Force

    foreach ($file in @("LICENSE.txt", "readme.md", "alive_logo.paa")) {
        $sourcePath = Join-Path $repoRoot $file
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath (Join-Path $stagePath $file) -Force
        }
    }

    $keysSource = Join-Path $repoRoot "keys"
    if (Test-Path $keysSource) {
        Copy-Item $keysSource (Join-Path $stagePath "keys") -Recurse -Force
    }

    $gitRevision = ""
    try {
        $gitRevision = (git -C $repoRoot rev-parse --short HEAD 2>$null)
    } catch {
        $gitRevision = ""
    }

    $manifest = @(
        "Fork build generated: $(Get-Date -Format s)",
        "Stage path: $stagePath",
        "Mod dir: $ModDirName",
        "Git revision: $gitRevision",
        "Packed addons: $(Format-NameList -Values $builtAddons)",
        "Packed optional addons: $(Format-NameList -Values $builtOptional)"
    )

    Set-Content -Path (Join-Path $stagePath "build_fork_manifest.txt") -Value $manifest

    Write-Host ""
    Write-Host ("Fork build staged at: " + $stagePath)
    Write-Host ("Packed addons: " + $builtAddons.Count)
    Write-Host ("Packed optional addons: " + $builtOptional.Count)
    Write-Host "Workshop upload target is the staged mod folder above."
} finally {
    if (!$KeepTemp -and (Test-Path $tempRoot)) {
        Remove-Item $tempRoot -Recurse -Force
    }
}
