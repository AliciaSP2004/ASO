<#
.synopsis
    Scrip Mostrar menu
.description
Script para mostrar un menu
.notes
    Autor: Alicia
    Fecha: 06/10/2025
    Version: 1.0
#>

Write-Host "MENU"
Write-Host "1. Mostrar la fecha actual"
Write-Host "2. Mostrar el usuario actual"
Write-Host "3. Salir"
$opcion = Read-Host "Elige una opcion"

while($opcion -ne "3"){
    Write-Host "MENU"
    Write-Host "1. Mostrar la fecha actual"
    Write-Host "2. Mostrar el usuario actual"
    Write-Host "3. Salir"
    $opcion = Read-Host "Elige una opcion"
    switch($opcion){
        
        "1" { Write-Host "La fecha actual es: $(Get-Date)"}
        "2" { Write-Host "El usuario actual es: $env:USERNAME"}
        "3" { Write-Host "Saliendo..."; Exit 0}
        default{Write-Host "Opcion no valida"}
    }
    
}