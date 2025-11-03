<#
.synopsis
    Scrip clasificar ficheros
.description
Script para clasificar los ficheros
.notes
    Autor: Alicia
    Fecha: 06/10/2025
    Version: 1.0
#>
$carpeta = "."

Get-ChildItem -Path $carpeta -File | ForEach-Object {
    if ($_.Extension -eq ".csv")  { "$($_.Name) Es un fichero de datos" }
    elseif ($_.Extension -eq ".docx") { "$($_.Name) Es un documento de texto" }
    elseif ($_.Extension -eq ".png")  { "$($_.Name) Es una imagen" }
    else { "$($_.Name) Extension no reconocida" }
}