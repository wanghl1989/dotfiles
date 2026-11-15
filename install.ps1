[CmdletBinding()]
param(
    [switch]$SkipTools
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

function Install-ScoopPackages {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        throw "Scoop is required. Install it from https://scoop.sh and try again."
    }

    $hasExtras = @(scoop bucket list | Where-Object {
        ($_.PSObject.Properties["Name"] -and $_.Name -eq "extras") -or
        ($_ -is [string] -and $_ -match '^\s*extras\s')
    }).Count -gt 0
    if (-not $hasExtras) {
        Write-Host ">>> Adding Scoop extras bucket"
        scoop bucket add extras
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add the Scoop extras bucket (exit code $LASTEXITCODE)."
        }
    }

    $packages = @(
        "neovim",
        "lazygit",
        "starship",
        "eza",
        "bat",
        "python",
        "uv",
        "miniconda3"
    )

    foreach ($package in $packages) {
        Write-Host ""
        Write-Host ">>> Installing $package"
        scoop install $package
        if ($LASTEXITCODE -ne 0) {
            throw "Scoop failed to install $package (exit code $LASTEXITCODE)."
        }
    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    Write-Host ""
    Write-Host "tmux has no native Windows build; install it inside WSL if needed."
}

function Initialize-LocalThemes {
    $themeRoot = Join-Path $Root "themes"
    $groups = @{}
    foreach ($file in Get-ChildItem -LiteralPath $themeRoot -Recurse -File) {
        $relative = $file.FullName.Substring($themeRoot.Length).TrimStart("\")
        $parts = $relative -split '[\\/]'
        if ($parts[0] -eq "server" -or $file.Name.StartsWith(".") -or $file.Extension -eq ".md") {
            continue
        }

        $target = Join-Path $Root ("config\" + $relative)
        $target = Join-Path (Split-Path -Parent $target) ("theme" + $file.Extension)
        $key = $target.ToLowerInvariant()
        if (-not $groups.ContainsKey($key)) {
            $groups[$key] = @{ Target = $target; Sources = @{} }
        }
        $groups[$key].Sources[$file.BaseName] = $file.FullName
    }

    foreach ($group in $groups.Values) {
        if (Test-Path -LiteralPath $group.Target) {
            continue
        }
        $selected = "neofusion"
        if (-not $group.Sources.ContainsKey($selected)) {
            $selected = @($group.Sources.Keys | Sort-Object)[0]
        }
        $parent = Split-Path -Parent $group.Target
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $group.Sources[$selected] -Destination $group.Target
        Write-Host "[THEME] Initialized $($group.Target) from $selected"
    }

    $btopConfig = Join-Path $Root "config\btop\btop.conf"
    if (-not (Test-Path -LiteralPath $btopConfig)) {
        Copy-Item -LiteralPath (Join-Path $Root "config\btop\btop.conf.default") -Destination $btopConfig
    }
}

function Assert-SymbolicLinkSupport {
    $probe = Join-Path $env:TEMP ("dotfiles-symlink-test-" + [guid]::NewGuid().ToString("N"))
    $target = "$probe-target.txt"
    $link = "$probe-link.txt"
    New-Item -ItemType File -Path $target -Force | Out-Null
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $target -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Symbolic links are unavailable. Enable Developer Mode or run this installer as Administrator before continuing. $($_.Exception.Message)"
    }
    finally {
        Remove-Item -LiteralPath $link,$target -Force -ErrorAction SilentlyContinue
    }
}

function New-ConfigLink {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Host "[SKIP] Source not found: $Source"
        return
    }

    $parent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $existing = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        $isExpectedLink = $false
        if ($existing.LinkType -eq "SymbolicLink") {
            $target = @($existing.Target)[0]
            if ($null -ne $target) {
                $expected = [IO.Path]::GetFullPath($Source).TrimEnd("\")
                $actual = [IO.Path]::GetFullPath($target).TrimEnd("\")
                $isExpectedLink = $actual.Equals($expected, [StringComparison]::OrdinalIgnoreCase)
            }
        }

        if ($isExpectedLink) {
            Write-Host "[OK] Already linked: $Destination"
            return
        }

        $backup = "$Destination.dotfiles-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        $counter = 0
        while (Test-Path -LiteralPath $backup) {
            $counter++
            $backup = "$Destination.dotfiles-backup-$(Get-Date -Format 'yyyyMMddHHmmss')-$counter"
        }
        Move-Item -LiteralPath $Destination -Destination $backup
        Write-Host "[BACKUP] $Destination -> $backup"
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -ErrorAction Stop | Out-Null
        Write-Host "[LINK] $Destination -> $Source"
    }
    catch {
        throw "Failed to create symbolic link '$Destination'. Enable Developer Mode or run PowerShell as Administrator. $($_.Exception.Message)"
    }
}

function Install-ConfigurationLinks {
    $configDir = Join-Path $HOME ".config"
    $links = @(
        @{ Source = "config\nvim"; Destination = (Join-Path $env:LOCALAPPDATA "nvim") },
        @{ Source = "config\zed"; Destination = (Join-Path $configDir "zed") },
        @{ Source = "config\uv"; Destination = (Join-Path $env:APPDATA "uv") },
        @{ Source = "config\starship\theme.toml"; Destination = (Join-Path $configDir "starship.toml") },
        @{ Source = "config\lazygit\theme.yml"; Destination = (Join-Path $env:APPDATA "lazygit\config.yml") },
        @{ Source = "config\bat"; Destination = (Join-Path $env:APPDATA "bat") },
        @{ Source = "config\yazi"; Destination = (Join-Path $configDir "yazi") },
        @{ Source = "config\btop"; Destination = (Join-Path $configDir "btop") },
        @{ Source = "config\lazydocker\theme.yml"; Destination = (Join-Path $configDir "lazydocker\config.yml") },
        @{ Source = "config\eza"; Destination = (Join-Path $configDir "eza") },
        @{ Source = "config\newsboat"; Destination = (Join-Path $configDir "newsboat") },
        @{ Source = "config\pip\pip.conf"; Destination = (Join-Path $env:APPDATA "pip\pip.ini") },
        @{ Source = ".vimrc"; Destination = (Join-Path $HOME ".vimrc") },
        @{ Source = ".condarc"; Destination = (Join-Path $HOME ".condarc") },
        @{ Source = "Rime"; Destination = (Join-Path $env:APPDATA "Rime") }
    )

    foreach ($link in $links) {
        New-ConfigLink -Source (Join-Path $Root $link.Source) -Destination $link.Destination
    }
}

function Install-PowerShellProfile {
    $profileSource = Join-Path $Root "shell\powershell.ps1"
    $profileDestination = Join-Path $HOME ".powershell.ps1"
    Copy-Item -LiteralPath $profileSource -Destination $profileDestination -Force
    Write-Host "[PROFILE] Copied PowerShell config to $profileDestination"

    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path -LiteralPath $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    $sourceLine = '. "$HOME\.powershell.ps1"'
    $escapedLegacyPath = $profileSource.Replace("'", "''")
    $legacySourceLine = ". '$escapedLegacyPath'"
    $managedLines = @($sourceLine, $legacySourceLine)
    $profileLines = @(Get-Content -LiteralPath $PROFILE -ErrorAction SilentlyContinue)
    $remainingLines = @($profileLines | Where-Object { $_ -notin $managedLines })
    $updatedLines = @($remainingLines) + $sourceLine

    if (($profileLines -join "`n") -ne ($updatedLines -join "`n")) {
        Set-Content -LiteralPath $PROFILE -Value $updatedLines -Encoding UTF8
        Write-Host "[PROFILE] Configured automatic loading in $PROFILE"
    }
    else {
        Write-Host "[OK] PowerShell profile already configured"
    }
}

function Get-KittyTerminalSchemes {
    param([Parameter(Mandatory = $true)][string]$RootPath)

    $themeDir = Join-Path $RootPath "themes\kitty\themes"
    foreach ($file in Get-ChildItem -LiteralPath $themeDir -Filter "*.conf" | Sort-Object Name) {
        $colors = @{}
        $displayName = $file.BaseName
        foreach ($line in Get-Content -LiteralPath $file.FullName) {
            if ($line -match '^\s*##\s*name:\s*(.+?)\s*$') {
                $displayName = $Matches[1]
            }
            if ($line -match '^\s*(background|foreground|selection_background|cursor|color(?:[0-9]|1[0-5]))\s+(#[0-9A-Fa-f]{6})\b') {
                $colors[$Matches[1]] = $Matches[2]
            }
        }

        $required = @("background", "foreground", "selection_background", "cursor")
        for ($index = 0; $index -lt 16; $index++) {
            $required += "color$index"
        }
        foreach ($key in $required) {
            if (-not $colors.ContainsKey($key)) {
                throw "Kitty theme '$($file.FullName)' is missing '$key'."
            }
        }

        [pscustomobject][ordered]@{
            name = "Kitty - $displayName"
            background = $colors.background
            foreground = $colors.foreground
            cursorColor = $colors.cursor
            selectionBackground = $colors.selection_background
            black = $colors.color0
            red = $colors.color1
            green = $colors.color2
            yellow = $colors.color3
            blue = $colors.color4
            purple = $colors.color5
            cyan = $colors.color6
            white = $colors.color7
            brightBlack = $colors.color8
            brightRed = $colors.color9
            brightGreen = $colors.color10
            brightYellow = $colors.color11
            brightBlue = $colors.color12
            brightPurple = $colors.color13
            brightCyan = $colors.color14
            brightWhite = $colors.color15
        }
    }
}

function Find-JsonArrayClose {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][int]$OpenIndex
    )

    $depth = 0
    $inString = $false
    $escaped = $false
    $inLineComment = $false
    $inBlockComment = $false
    for ($index = $OpenIndex; $index -lt $Text.Length; $index++) {
        $char = $Text[$index]
        $next = [char]0
        if ($index + 1 -lt $Text.Length) {
            $next = $Text[$index + 1]
        }

        if ($inLineComment) {
            if ($char -eq [char]10 -or $char -eq [char]13) {
                $inLineComment = $false
            }
            continue
        }
        if ($inBlockComment) {
            if ($char -eq "*" -and $next -eq "/") {
                $inBlockComment = $false
                $index++
            }
            continue
        }
        if ($inString) {
            if ($escaped) {
                $escaped = $false
            }
            elseif ($char -eq "\") {
                $escaped = $true
            }
            elseif ($char -eq '"') {
                $inString = $false
            }
            continue
        }
        if ($char -eq "/" -and $next -eq "/") {
            $inLineComment = $true
            $index++
            continue
        }
        if ($char -eq "/" -and $next -eq "*") {
            $inBlockComment = $true
            $index++
            continue
        }
        if ($char -eq '"') {
            $inString = $true
            continue
        }
        if ($char -eq "[") {
            $depth++
        }
        elseif ($char -eq "]") {
            $depth--
            if ($depth -eq 0) {
                return $index
            }
        }
    }
    return -1
}

function Install-WindowsTerminalThemes {
    param(
        [Parameter(Mandatory = $true)][string]$RootPath,
        [string[]]$SettingsPath
    )

    if ($null -eq $SettingsPath -or $SettingsPath.Count -eq 0) {
        $packagesDir = Join-Path $env:LOCALAPPDATA "Packages"
        $SettingsPath = @(
            (Join-Path $packagesDir "Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
            (Join-Path $packagesDir "Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
        )
    }

    $schemes = @(Get-KittyTerminalSchemes -RootPath $RootPath)
    $foundSettings = $false
    $newline = [string][char]13 + [char]10
    foreach ($path in $SettingsPath | Select-Object -Unique) {
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }
        $foundSettings = $true
        $raw = [IO.File]::ReadAllText($path)
        $schemeMatch = [regex]::Match($raw, '(?m)^[ \t]*"schemes"\s*:\s*\[')
        $newSchemes = @()
        $openIndex = -1
        $existingBody = ""

        if ($schemeMatch.Success) {
            $openIndex = $schemeMatch.Index + $schemeMatch.Value.LastIndexOf("[")
            $closeIndex = Find-JsonArrayClose -Text $raw -OpenIndex $openIndex
            if ($closeIndex -lt 0) {
                throw "Invalid schemes array in Windows Terminal settings: $path"
            }
            $existingBody = $raw.Substring($openIndex + 1, $closeIndex - $openIndex - 1)
            foreach ($scheme in $schemes) {
                $namePattern = '"name"\s*:\s*"' + [regex]::Escape($scheme.name) + '"'
                if ($existingBody -notmatch $namePattern) {
                    $newSchemes += $scheme
                }
            }
        }
        else {
            $newSchemes = $schemes
        }

        if ($newSchemes.Count -eq 0) {
            Write-Host "[OK] Windows Terminal schemes already exist: $path"
            continue
        }

        $lines = @()
        foreach ($scheme in $newSchemes) {
            $lines += "        $($scheme | ConvertTo-Json -Compress)"
        }
        $schemeJson = $lines -join ("," + $newline)

        if ($schemeMatch.Success) {
            $suffix = ""
            if ($existingBody -match '"name"\s*:') {
                $suffix = ","
            }
            $insertion = $newline + $schemeJson + $suffix
            $updated = $raw.Insert($openIndex + 1, $insertion)
        }
        else {
            $rootClose = $raw.LastIndexOf("}")
            if ($rootClose -lt 0) {
                throw "Invalid Windows Terminal settings file: $path"
            }
            $separator = ""
            if ($raw.Substring(0, $rootClose) -match '"[^"\r\n]+"\s*:') {
                $separator = ","
            }
            $block = $separator + $newline + '    "schemes": [' + $newline + $schemeJson + $newline + "    ]" + $newline
            $updated = $raw.Insert($rootClose, $block)
        }

        $backup = "$path.dotfiles-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -LiteralPath $path -Destination $backup
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [IO.File]::WriteAllText($path, $updated, $utf8NoBom)
        Write-Host "[THEME] Added $($newSchemes.Count) Kitty schemes to $path"
        Write-Host "[BACKUP] $backup"
    }

    if (-not $foundSettings) {
        Write-Host "[SKIP] Windows Terminal settings.json not found; no schemes were installed."
    }
}

Write-Host "Dotfiles root: $Root"
Assert-SymbolicLinkSupport
if (-not $SkipTools) {
    Install-ScoopPackages
}

Write-Host ""
Write-Host ">>> Initializing local themes"
Initialize-LocalThemes

Write-Host ""
Write-Host ">>> Linking configuration files"
Install-ConfigurationLinks

Write-Host ""
Write-Host ">>> Configuring PowerShell"
Install-PowerShellProfile

Write-Host ""
Write-Host ">>> Installing Windows Terminal schemes from Kitty"
Install-WindowsTerminalThemes -RootPath $Root

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Write-Host ""
    Write-Host ">>> Rebuilding bat cache"
    bat cache --build
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "bat cache rebuild failed."
    }
}

Write-Host ""
Write-Host "Installation complete. Restart PowerShell to load aliases and tool initialization."
Write-Host "Windows Terminal schemes are named 'Kitty - <theme>'; select one in your profile settings."
