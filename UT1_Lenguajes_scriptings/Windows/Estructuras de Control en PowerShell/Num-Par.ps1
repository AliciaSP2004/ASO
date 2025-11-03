<#
.synopsis
    Scrip condicional 
.description
Script para saber si numero es par o impar
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
$numero=Read-Host "Indique numero"
if($numero %2 -eq 0){
    Write-Output "Par"
}
elseif($numero %2 -eq 1){
    Write-Output "Impar"
}
else{
    Write-Output "No es un numero"
}