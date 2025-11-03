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
$suma=0
for ($i=1;$i -le 100;$i++){
    $suma=$suma+$i
    write-Host "La suma da: $suma"
}
