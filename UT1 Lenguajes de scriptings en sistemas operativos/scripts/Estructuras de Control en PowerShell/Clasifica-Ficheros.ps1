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
$carpeta = ".\MisFicheros"
New-Item -ItemType Directory -Path $carpeta -Force | Out-Null

# Crear los ficheros dentro de la carpeta
New-Item -ItemType File -Path (Join-Path $carpeta "datos.csv") -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $carpeta "informe.docx") -Force | Out-Null
New-Item -ItemType File -Path (Join-Path $carpeta "imagen.png") -Force | Out-Null

Write-Host "Se han creado los ficheros en la carpeta 'MisFicheros'."