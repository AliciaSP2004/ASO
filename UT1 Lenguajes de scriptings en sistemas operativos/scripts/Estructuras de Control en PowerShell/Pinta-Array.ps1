<#
.synopsis
    Scrip bucle
.description
Script para saludar a los nombres del vector
.notes
    Autor: Alicia
    Fecha: 01/10/2025
    Version: 1.0
#>
$vector=@()
$vector+="Luis"
$vector+="Pedro"
$vector+="Maria"
$vector+="Ana"
$vector+="Jorge"
foreach ($nombre in $vector){
    write-Host "Hola, $nombre"
}