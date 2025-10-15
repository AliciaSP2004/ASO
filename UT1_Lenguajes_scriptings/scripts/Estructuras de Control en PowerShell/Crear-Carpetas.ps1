<#
.synopsis
    Scrip crear ficheros
.description
Script para crear fichero log
.notes
    Autor: Alicia
    Fecha: 06/10/2025
    Version: 1.0
#>
$numero=Read-Host "Indique numero"
$carpeta= if($numero % 2 -eq 0){"Pares"} else {"Impares"}
$ruta=[Enviroment]::GetFolderPath("MyDocuments")
$rutaCarpeta= Join-Path $ruta $carpeta
if(-not (Test-Path $rutaCarpeta)){
    New-item  -ItemType Directory -Path $rutaCarpeta -Force| Out-Null
    Write-Host "El numero $numero es $carpeta. Carpeta lista en: $rutaCarpeta"
}
