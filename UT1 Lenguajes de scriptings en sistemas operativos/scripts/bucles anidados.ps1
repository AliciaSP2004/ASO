<#
.synopsis
    Scrip bucle
.description
Script para hacer sumas de acumulado hasta sumar 100
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
param(
    [switch]$asc
)

if ($asc) {
    $numero = 1..9
    Write-Host "Números en forma ascendente:`n"
} else {
    $numero = 9..1
    Write-Host "Números en forma descendente:`n"
}

# Recorre el array en bloques de 3 elementos para formar las filas 3x3
for ($i = 0; $i -lt 9; $i += 3) {
    $fila = $numero[$i..($i+2)]
    Write-Host ("{0,3}{1,3}{2,3}" -f $fila[0], $fila[1], $fila[2])
}