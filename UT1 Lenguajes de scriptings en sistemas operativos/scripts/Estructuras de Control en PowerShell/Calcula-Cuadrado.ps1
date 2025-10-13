<#
.synopsis
    Scrip bucle
.description
Script para calcular cuadrados
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>

for ($i=1;$i -le 10;$i++){
    $resultado=$i*$i
    write-Host "$i x $i = $resultado"
}