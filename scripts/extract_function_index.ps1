param(
    [string]$Source = "..\\ps4_ref\\spu.elf.c",
    [string]$Output = ".\\docs\\FUNCTION_INDEX.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source file not found: $Source"
}

$lines = Get-Content -LiteralPath $Source
$functions = @()

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^//----- \(([0-9A-F]+)\)') {
        $address = $matches[1]
        $j = $i + 1
        while ($j -lt $lines.Length -and [string]::IsNullOrWhiteSpace($lines[$j])) {
            $j++
        }

        $parts = @()
        while ($j -lt $lines.Length) {
            $line = $lines[$j].Trim()
            if ($line -eq "{") {
                break
            }
            if ($line -ne "") {
                $parts += $line
            }
            if ($line -match '\)\s*$') {
                break
            }
            $j++
        }

        $signature = ($parts -join ' ')
        $name = "<unknown>"
        if ($signature -match '([A-Za-z_][A-Za-z0-9_]*)\s*\(') {
            $name = $matches[1]
        }

        $functions += [pscustomobject]@{
            Address = $address
            Name = $name
            Signature = $signature
            Status = "Undocumented"
        }
    }
}

$markdown = [System.Collections.Generic.List[string]]::new()
$markdown.Add("# Function Index")
$markdown.Add("")
$markdown.Add("Generated from ``$($Source)``.")
$markdown.Add("")
$markdown.Add("Total functions: $($functions.Count)")
$markdown.Add("")
$markdown.Add("| Address | Name | Status | Signature |")
$markdown.Add("| --- | --- | --- | --- |")

foreach ($fn in $functions) {
    $sig = $fn.Signature.Replace("|", "\|")
    $markdown.Add("| ``0x$($fn.Address)`` | ``$($fn.Name)`` | $($fn.Status) | ``$sig`` |")
}

$outDir = Split-Path -Parent $Output
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$outputPath = Join-Path (Resolve-Path -LiteralPath $outDir).Path (Split-Path -Leaf $Output)
[System.IO.File]::WriteAllLines($outputPath, $markdown)
