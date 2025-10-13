<#
.synopsis
    Scrip calcular nota
.description
Script para calcular que es cada nota
.notes
    Autor: Alicia
    Fecha: 06/10/2025
    Version: 1.0
#>
[int]$nota = Read-Host "Indique la nota"

if ($nota -ge 9 -and $nota -le 10) {
    Write-Host "Sobresaliente"
}
elseif ($nota -le 8 -and $nota -ge 7) {
    Write-Host "Notable"
}
elseif ($nota -le 6 -and $nota -ge 5) {
    Write-Host "Aprobado"
}
else {
    Write-Host "Suspenso"
}