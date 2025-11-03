<#
.synopsis
    Scrip de arrays
.description
Script para haver arrays
.notes
    Autor: Alicia
    Fecha: 29/09/2025
    Version: 1.0
#>
$vector=@()
$vector+="Luis"
$vector+="Pedro"
$vector+="Maria"
$vector[0]
$vector[1]
$vector[2]
$vector[-1]

$numeros=@(1)

$documentos="$env:USERPROFILE\Documents"
$scriptsPath=Join-Path $documentos "Scripts"
$ficheros=dir $directorio