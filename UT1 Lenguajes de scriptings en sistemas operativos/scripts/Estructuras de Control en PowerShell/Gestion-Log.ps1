<#
.synopsis
    Scrip crear ficheros
.description
Script para crear fichero log
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
$carpeta = ".\Documents\Logs"
if(-not (Test-Path $carpeta)){
    New-Item -ItemType Directory -Path $carpeta -Force | Out-Null
}


# Crear los ficheros dentro de la carpeta
for ($i=1;$i -le 10;$i++){
    $archivo = Join-Path $carpeta "log$i.txt"
    New-Item -ItemType File -Path $archivo -Force | Out-Null
}
