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
$ruta=[Enviroment]::GetFolderPath("MyDocuments")
$vector=@("ASIR1", "ASIR2", "DAW1", "DAW2", "DAW2", "DAM1", "DAM2", "SMR1", "SMR2","SMRd1", "SMRd2")
if(-not (Test-Path $ruta)){
    New-item -path $ruta -ItemType Directory -name $vector| Out-Null
}    
foreach ($nombre in $carpetas) {
    $rutaCarpeta = Join-Path -Path $ruta -ChildPath $nombre
    if (-not (Test-Path $rutaCarpeta)) {
        New-Item -Path $rutaCarpeta -ItemType Directory | Out-Null
    } else {
        Write-Host "Carpeta ya existe: $rutaCarpeta"
    }

    # Crear 20 subcarpetas de usuario
    for ($i = 1; $i -le 20; $i++) {
        $subCarpeta = Join-Path -Path $rutaCarpeta -ChildPath ("User{0}" -f $i)
        if (-not (Test-Path $subCarpeta)) {
            New-Item -Path $subCarpeta -ItemType Directory | Out-Null
        }
    }
    if(-not (Test-Path $ruta)){
        for ($i = 1; $i -lt 20; $i +1) {
        New-item  -ItemType Directory -Path $rutaCarpeta -Force| Out-Null
    }
}
}

