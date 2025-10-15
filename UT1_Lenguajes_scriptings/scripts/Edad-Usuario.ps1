<#
.synopsis
    Scrip condicional 
.description
Script para saber si esres mayor o menor de edad
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
$edad=[int](Read-Host "Indique edad")
if($edad -lt 18){
    Write-Output "Menor de edad"
}
else{
    Write-Output "Mayor de edad"
}