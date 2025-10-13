<#
.synopsis
    Scrip bucle
.description
Script para hacer tabla de multiplicar 5
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
$numero=5
for ($i=1;$i -le 10;$i++){
    $resultado=$numero*$i
    write-Host "$numero x $i = $resultado"
}