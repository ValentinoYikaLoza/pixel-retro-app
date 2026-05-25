param([string]$In, [string]$Out)

# Genera un maze 28-ancho simétrico a partir de mitades izquierdas (14 chars/linea).
# full = left + reverse(left)  → garantiza ancho 28 y simetria perfecta.
$lines = @(Get-Content -LiteralPath $In)
$full = foreach ($l in $lines) {
  if ($l.Length -ne 14) { Write-Host "ERROR linea != 14: '$l' (len $($l.Length))"; }
  $arr = $l.ToCharArray()
  [array]::Reverse($arr)
  $l + (-join $arr)
}
$full | Set-Content -LiteralPath $Out -Encoding ascii
Write-Host "Generado $Out ($($full.Count) filas)"
