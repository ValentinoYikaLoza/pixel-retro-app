param([string]$Path)

$rows = @(Get-Content -LiteralPath $Path)
$h = $rows.Count
$W = 28
Write-Host "Filas: $h"

$bad = @()
for ($y = 0; $y -lt $h; $y++) { if ($rows[$y].Length -ne $W) { $bad += "y=$y len=$($rows[$y].Length)" } }
if ($bad.Count) { Write-Host ("ANCHOS != 28: " + ($bad -join ', ')) } else { Write-Host "OK: todas las filas miden 28" }

# Matriz de chars (pad defensivo)
$g = @()
for ($y = 0; $y -lt $h; $y++) { $g += ,($rows[$y].PadRight($W).ToCharArray()) }

function IsWalk([int]$x, [int]$y) {
  if ($y -lt 0 -or $y -ge $script:h) { return $false }
  $c = $script:g[$y][$x]
  return ($c -ne '#' -and $c -ne '=')
}

# Totales
$totP = 0; $totO = 0
for ($y = 0; $y -lt $h; $y++) { for ($x = 0; $x -lt $W; $x++) {
  if ($g[$y][$x] -eq '.') { $totP++ }
  if ($g[$y][$x] -eq 'o') { $totO++ }
}}

# Flood fill desde el primer '.' con wrap horizontal (tunel)
$sx = -1; $sy = -1
for ($y = 0; $y -lt $h -and $sy -lt 0; $y++) { for ($x = 0; $x -lt $W; $x++) {
  if ($g[$y][$x] -eq '.') { $sx = $x; $sy = $y; break }
}}
$seen = New-Object 'System.Collections.Generic.HashSet[string]'
$q = New-Object System.Collections.Queue
[void]$seen.Add("$sx,$sy"); $q.Enqueue(@($sx, $sy))
while ($q.Count -gt 0) {
  $c = $q.Dequeue(); $cx = [int]$c[0]; $cy = [int]$c[1]
  $cand = @(
    @((($cx - 1 + $W) % $W), $cy),
    @((($cx + 1) % $W), $cy),
    @($cx, ($cy - 1)),
    @($cx, ($cy + 1))
  )
  foreach ($n in $cand) {
    $nx = [int]$n[0]; $ny = [int]$n[1]
    if ($ny -lt 0 -or $ny -ge $h) { continue }
    $k = "$nx,$ny"
    if ($seen.Contains($k)) { continue }
    if (IsWalk $nx $ny) { [void]$seen.Add($k); $q.Enqueue(@($nx, $ny)) }
  }
}

$rp = 0; $ro = 0; $unreach = @()
for ($y = 0; $y -lt $h; $y++) { for ($x = 0; $x -lt $W; $x++) {
  $ch = $g[$y][$x]
  if ($ch -eq '.' -or $ch -eq 'o') {
    if ($seen.Contains("$x,$y")) { if ($ch -eq '.') { $rp++ } else { $ro++ } }
    else { $unreach += "($x,$y)=$ch" }
  }
}}

Write-Host ""
Write-Host "Pellets:       $rp / $totP alcanzables"
Write-Host "Power pellets:  $ro / $totO alcanzables"
Write-Host "TARGET (comestibles alcanzables): $($rp + $ro)"
if ($unreach.Count) { Write-Host ("INALCANZABLES (" + $unreach.Count + "): " + ($unreach -join '  ')) } else { Write-Host "OK: todos los pellets alcanzables" }

# Simetria de paredes
$asym = @()
for ($y = 0; $y -lt $h; $y++) { for ($x = 0; $x -lt 14; $x++) {
  if (($g[$y][$x] -eq '#') -ne ($g[$y][27 - $x] -eq '#')) { $asym += "($x,$y)" }
}}
Write-Host ("Simetria paredes: " + $(if ($asym.Count -eq 0) { "OK" } else { ($asym.Count.ToString() + " asimetricas: " + ($asym -join ' ')) }))

# Candidatos a spawn: celdas caminables en el tercio inferior, cercanas al centro
Write-Host ""
Write-Host "Candidatos spawn (caminable, mitad-baja, centradas):"
for ($y = [int]($h * 0.66); $y -lt $h; $y++) {
  for ($x = 10; $x -le 17; $x++) {
    if ((IsWalk $x $y) -and $seen.Contains("$x,$y")) { Write-Host ("  ($x,$y)=" + $g[$y][$x]) }
  }
}
