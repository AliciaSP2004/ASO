<#
.SYNOPSIS
    Script para automatizar la creacion de los objetos del dominio de  Active Directory.

.DESCRIPTION
    Este script crea Unidades Organizativas, grupos de seguridad y usuarios
    en Active Directory a partir de un archivo CSV.

.PARAMETER CsvPath
    Contiene la ruta al archivo CSV con los datos de usuarios y grupos.

.PARAMETER Domain
   Contiene el nombre del dominio de Active Directory.

.PARAMETER LogFile
   Contiene la ruta del archivo de log donde se registran las acciones.

.EXAMPLE
   Un ejemplo de como ejecutarle .\CrearAD_Grupo6.ps1 -CsvPath .\Usuarios_Grupo6.csv -Verbose

.NOTES
    Autor: Alicia Sainz Grupo6
    Fecha: 19/12/2025
    Version: 1.1

#>
<#Cambiar nombre del dominio #>

param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CsvPath,

    [string]$Domain = "alicia.local",

    [string]$LogFile
)

# Resolver ruta del script y del log
$rutaScript = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $LogFile) {
    $LogFile = Join-Path $rutaScript "CrearAD_Grupo6_Log.txt"
}

# Preparar los log
if (-not (Test-Path (Split-Path $LogFile))) {
    New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force | Out-Null
}
"" | Out-File -FilePath $LogFile -Encoding UTF8

function Write-Log {
    param([string]$Mensaje)
    $linea = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Mensaje"
    $linea | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Verbose $linea
}

# Importar modulo de Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Log "Modulo ActiveDirectory cargado correctamente"
}
catch {
    Write-Error "No se pudo cargar el modulo ActiveDirectory"
    exit 1
}

# Importar el archivo CSV
$usuarios = Import-Csv -Path $CsvPath
Write-Log "CSV cargado correctamente desde $CsvPath"

# Construir DN del dominio
$dnDominio = ($Domain.Split('.') | ForEach-Object { "DC=$_" }) -join ','

# Definicion de las UO y los grupos
$nombresOU = @(
    "OUGrupo6_Usuarios",
    "OUGrupo6_Equipos",
    "OUGrupo6_Administracion"
)

$nombresGrupos = @(
    "GGGrupo6_Admins",
    "GGGrupo6_Empleados"
)

function Ensure-OU {
    param([string]$NombreOU)

    $ouExiste = Get-ADOrganizationalUnit -Filter "Name -eq '$NombreOU'" -ErrorAction SilentlyContinue

    if (-not $ouExiste) {
        try {
            New-ADOrganizationalUnit -Name $NombreOU -Path $dnDominio -ProtectedFromAccidentalDeletion $false
            Write-Log "OU creada: $NombreOU"
        }
        catch {
            Write-Log "ERROR creando OU $NombreOU : $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "OU ya existe: $NombreOU"
    }
}

# Creacion de las UOs
foreach ($ou in $nombresOU) {
    Ensure-OU -NombreOU $ou
}

# Creacion de los grupos de seguridad
foreach ($grupo in $nombresGrupos) {
    $grupoExiste = Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue

    if (-not $grupoExiste) {
        try {
            $rutaGrupo = "OU=OUGrupo6_Usuarios,$dnDominio"
            New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security -Path $rutaGrupo
            Write-Log "Grupo creado: $grupo"
        }
        catch {
            Write-Log "ERROR creando grupo $grupo : $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "Grupo ya existe: $grupo"
    }
}

# Creacion de los usuarios
foreach ($usuario in $usuarios) {

    $nombre      = $usuario.Nombre.Trim()
    $apellidos   = $usuario.Apellidos.Trim()
    $usuarioAD   = $usuario.Usuario.Trim()
    $nombreOU    = $usuario.OU.Trim()
    $gruposCelda = $usuario.Grupos

    $dnOU = "OU=$nombreOU,$dnDominio"
    $nombreMostrado = "$nombre $apellidos"

    $usuarioExiste = Get-ADUser -Filter "SamAccountName -eq '$usuarioAD'" -ErrorAction SilentlyContinue

    if (-not $usuarioExiste) {
        try {
            $contrasenaSegura = ConvertTo-SecureString $usuario.Contrasena -AsPlainText -Force

            New-ADUser `
                -Name $nombreMostrado `
                -GivenName $nombre `
                -Surname $apellidos `
                -SamAccountName $usuarioAD `
                -UserPrincipalName "$usuarioAD@$Domain" `
                -AccountPassword $contrasenaSegura `
                -Path $dnOU `
                -Enabled $true `
                -ChangePasswordAtLogon $true

            Write-Log "Usuario creado: $usuarioAD"
        }
        catch {
            Write-Log "ERROR creando usuario $usuarioAD : $($_.Exception.Message)"
            continue
        }
    }
    else {
        Write-Log "Usuario ya existe: $usuarioAD"
    }

    # Asignar los grupos a los usuarios
    if ($gruposCelda) {
        $listaGrupos = $gruposCelda -split ';' | ForEach-Object { $_.Trim() }

        foreach ($grupoAsignar in $listaGrupos) {
            try {
                Add-ADGroupMember -Identity $grupoAsignar -Members $usuarioAD -ErrorAction Stop
                Write-Log "Añadido $usuarioAD al grupo $grupoAsignar"
            }
            catch {
                Write-Log "ERROR añadiendo $usuarioAD al grupo $grupoAsignar : $($_.Exception.Message)"
            }
        }
    }
}

Write-Log "Script finalizado correctamente"

Write-Host "EL SCRIPT SE ESTA EJECUTANDO" -ForegroundColor Green
