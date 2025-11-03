<#
.synopsis
    Scrip recorrer ficheros
.description
Script para recorrer los ficheros
.notes
    Autor: Alicia
    Fecha: 06/10/2025
    Version: 1.0
#>
Get-ChildItem .\Logs\*.txt | ForEach-Object {
    "Este es el fichero $($_.Name)" | Out-File $_.FullName
    $linea = Get-Content $_.FullName | Select-Object -First 1
    Write-Host "$($_.Name): $linea"
}