# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell --print-full-init | Out-String)
    Set-Alias -Name st -Value starship -Scope Global -Force
}

# Conda shell integration. Miniconda does not always add itself to PATH.
$condaCommand = Get-Command conda -ErrorAction SilentlyContinue
$condaPath = if ($condaCommand) { $condaCommand.Name } else { $null }
if (-not $condaPath) {
    $condaCandidates = @(
        (Join-Path $HOME "scoop\apps\miniconda3\current\condabin\conda.bat"),
        (Join-Path $HOME "miniconda3\condabin\conda.bat"),
        (Join-Path $HOME "Miniconda3\condabin\conda.bat"),
        (Join-Path $env:LOCALAPPDATA "Continuum\miniconda3\condabin\conda.bat"),
        "C:\ProgramData\miniconda3\condabin\conda.bat"
    )
    $condaPath = $condaCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if ($condaPath) {
    Invoke-Expression (& $condaPath shell.powershell hook | Out-String)
    function global:ca { conda activate @args }
    function global:cda { conda deactivate @args }
    function global:cenv { conda env list @args }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name v -Value nvim -Scope Global -Force
    function global:nvimdiff { nvim -d @args }
    $env:EDITOR = "nvim"
    $env:VISUAL = "nvim"
}

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lzg -Value lazygit -Scope Global -Force
}

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function global:ls { eza --icons=auto @args }
    function global:ll { eza --icons=auto --git -h -H -l @args }
    function global:la { eza --icons=auto -a @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name b -Value bat -Scope Global -Force
}

# tmux is available when this profile is used through a compatible environment.
if (Get-Command tmux -ErrorAction SilentlyContinue) {
    Set-Alias -Name tm -Value tmux -Scope Global -Force
    function global:tl { tmux list-session @args }
    function global:ta { tmux attach -t @args }
    function global:tk { tmux kill-session -t @args }
    function global:tn { tmux new -s @args }
}

if (Get-Command pip -ErrorAction SilentlyContinue) {
    function global:pi { pip install @args }
    function global:pu { pip uninstall @args }
    function global:pl { pip list @args }
}
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    function global:pi { python -m pip install @args }
    function global:pu { python -m pip uninstall @args }
    function global:pl { python -m pip list @args }
}

if (Get-Command uv -ErrorAction SilentlyContinue) {
    function global:uva { uv add @args }
    function global:uvr { uv run @args }
    function global:uvs { uv sync @args }
}
