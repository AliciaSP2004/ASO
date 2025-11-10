<#
.synopsis
    Script de inventario del sistema
.description
    Recopila información del sistema y la guarda en CSV
.notes
    Autor: Alicia
    Fecha: 10/11/2025
    Version: 1.0
#>

param(
    [switch]$c,  # Mantiene el parámetro original para concatenar
    [string]$OutputPath = "\\ServidorAula\Comparte_aula\Practica_P",
    [string]$LogPath = "\\ServidorAula\Comparte_aula\Practica_PS\log",
    [Parameter(Mandatory = $true)]
    [string]$SessionCode = "UT1_P1_asp, ejemplo UT1_P1_CTP",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$infoColl = @()
Write-Host "Iniciando recopilación de inventario del sistema..."
Write-Verbose "Validando rutas y permisos de salida..."

# -----------------------------------------------------
# Función para registrar actividad en el log
# -----------------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO'
    )

    if (-not $Quiet) {
        switch ($Level) {
            'INFO'  { Write-Host "$Message" -ForegroundColor Cyan }
            'WARN'  { Write-Warning "$Message" }
            'ERROR' { Write-Host "$Message" -ForegroundColor Red }
        }
    }

    # Asegurar que la carpeta del log exista
    if (-not (Test-Path $LogPath)) {
        try {
            New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        } catch {
            Write-Warning "No se pudo crear la carpeta de logs en $LogPath."
            return
        }
    }

    $LogFile = Join-Path $LogPath "PowerShell-PC-Inventory-Activity.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $computer = $env:COMPUTERNAME
    $line = "[${timestamp}] [$SessionCode] [$Level] [$computer] $Message"

    try {
        Add-Content -Path $LogFile -Value $line
    } catch {
        Write-Warning "⚠️ No se pudo escribir en el log: $LogFile"
    }
}

# -----------------------------------------------------
# Función centralizada para salida controlada (modo Quiet)
# -----------------------------------------------------
function Write-OutputControlled {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO'
    )

    Write-Log -Message $Message -Level $Level

    if (-not $Quiet) {
        switch ($Level) {
            'INFO'  { Write-Host $Message -ForegroundColor Cyan }
            'WARN'  { Write-Warning $Message }
            'ERROR' { Write-Host $Message -ForegroundColor Red }
        }
    }
}

# -----------------------------------------------------
# Validar rutas y crear carpetas si no existen
# -----------------------------------------------------
foreach ($pathVar in @('OutputPath', 'LogPath')) {
    $path = Get-Variable -Name $pathVar -ValueOnly

    if (-not (Test-Path -Path $path)) {
        Write-Host "La carpeta '$path' no existe. Intentando crearla..."
        try {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
            Write-Host "Carpeta creada correctamente: $path"
        } catch {
            $fallback = [Environment]::GetFolderPath('MyDocuments')
            Write-Log "No se pudo crear $path. Se usará Documentos: $fallback" 'WARN'
            Set-Variable -Name $pathVar -Value $fallback
        }
    }
}

# -----------------------------------------------------
# Función segura para consultas CIM
# -----------------------------------------------------
function Safe-GetCIM {
    param(
        [string]$ClassName,
        [string]$Property
    )
    try {
        return (Get-CimInstance -Class $ClassName -ErrorAction Stop | Select-Object -ExpandProperty $Property)
    }
    catch {
        Write-OutputControlled "Error al consultar ${ClassName}.${Property}: $_" 'WARN'
        return "N/A"
    }
}
# -----------------------------------------------------
# Definir rutas del CSV y del log
# -----------------------------------------------------
$csv = Join-Path $OutputPath "$env:computername-Inventory.csv"
$ErrorLogPath = Join-Path $LogPath "PowerShell-PC-Inventory-Error-Log.log"

# Variable opcional de ejemplo: si quieres incluir el SessionCode en los nombres
$SessionTag = $SessionCode
function ConcatenateInventory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputFolder,

        [Parameter(Mandatory = $true)]
        [string]$ReportPath
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $uniqueRows = @{}

    Write-OutputControlled "Iniciando consolidación de inventario..." 'INFO'

    Get-ChildItem -Path $InputFolder -Filter *.csv | ForEach-Object {
        try {
            $data = Import-Csv -Path $_.FullName -ErrorAction Stop
            foreach ($row in $data) {
                $key = $row | Out-String
                if (-not $uniqueRows.ContainsKey($key)) {
                    $uniqueRows[$key] = $row
                }
            }
        }
        catch {
            Write-OutputControlled "Error al leer $($_.FullName): $_" 'WARN'
        }
    }

    $outputFile = Join-Path $ReportPath "PowerShell-PC-Inventory-Report-$timestamp.csv"
    $uniqueRows.Values | Export-Csv -Path $outputFile -NoTypeInformation -Force

    Write-OutputControlled "Consolidación completa: $outputFile" 'INFO'
}

  $csvFolderPath = Read-Host "Please specify the full path of your Inventory Output folder"

  # Specify the output file path for the inventory report
  $outputFilePath = Read-Host "Please specify the full path of where you'd like to export the final inventory report to"

  # Initialize an empty hashtable to keep track of unique rows
  $uniqueRows = @{}

  # Loop through each CSV file in the folder
  Get-ChildItem -Path $csvFolderPath -Filter *.csv | ForEach-Object {
    $csvFile = $_.FullName

    # Import the CSV file
    $data = Import-Csv -Path $csvFile

    # Loop through each row in the CSV and add it to the hashtable
    foreach ($row in $data) {
      $rowKey = $row | Out-String
      if (-not $uniqueRows.ContainsKey($rowKey)) {
        $uniqueRows[$rowKey] = $row
      }
    }
  }

  # Export the unique rows to the output CSV file
  $uniqueRows.Values | Export-Csv -Path "$outputFilePath\PowerShell-PC-Inventory-Report-$timestamp.csv" -NoTypeInformation -Force

  Write-Host "Inventory consolidation complete. The inventory report is saved to $outputFilePath\PowerShell-PC-Inventory-Report-$timestamp.csv"
  exit


if ($c) {
  ConcatenateInventory
}

Write-Host "Gathering inventory information..."

# Date
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Installed apps
if ($checkInstalledApps -eq 1) {
  # Get list of installed applications from registry
  $installedApps = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
     -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty DisplayName

  # Filter out empty entries and join them into a comma-separated list
  $appsList = ($installedApps | Where-Object { $_ -ne $null }) -join "`n "

  # Output the variable
  $appsList
} else {
  $appsList = "N/A"
}

# BIOS Version/Date
$BIOSManufacturer = Get-CimInstance -Class win32_bios | Select-Object -ExpandProperty Manufacturer
$BIOSVersion = Get-CimInstance -Class win32_bios | Select-Object -ExpandProperty SMBIOSBIOSVersion
$BIOSName = Get-CimInstance -Class win32_bios | Select-Object -ExpandProperty Name
$BIOS = Write-Output $BIOSManufacturer", "$BIOSVersion", "$BIOSName

# IP and MAC address
# Get the default route with the lowest metric
$defaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Sort-Object -Property Metric | Select-Object -First 1
# Get the interface index for the default route
$interfaceIndex = $defaultRoute.InterfaceIndex
# Get the IP address associated with this interface
$interfaceIP = (Get-NetIPAddress -InterfaceIndex $interfaceIndex | Where-Object { $_.AddressFamily -eq "IPv4" }).IPAddress
# Get the MAC address associated with this interface
$interfaceMAC = (Get-NetAdapter -InterfaceIndex $interfaceIndex).MacAddress

# Serial Number
$SN = Get-CimInstance -Class Win32_Bios | Select-Object -ExpandProperty SerialNumber

# Model
$Model = Get-CimInstance -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model

# CPU
$CPU = Get-CimInstance -Class win32_processor | Select-Object -ExpandProperty Name

# RAM
$RAM = Get-CimInstance -Class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | ForEach-Object { [math]::Round(($_.sum / 1GB),2) }

# Storage
$Storage = Get-CimInstance -Class Win32_LogicalDisk -Filter "DeviceID='$env:systemdrive'" | ForEach-Object { [math]::Round($_.Size / 1GB,2) }

#GPU(s)
function GetGPUInfo {
  $GPUs = Get-CimInstance -Class Win32_VideoController
  foreach ($GPU in $GPUs) {
    $GPU | Select-Object -ExpandProperty Description
  }
}

## If some computers have more than two GPUs, you can copy the lines below, but change the variable and index number by counting them up by 1.
$GPU0 = GetGPUInfo | Select-Object -Index 0
$GPU1 = GetGPUInfo | Select-Object -Index 1

# OS
$OS = Get-CimInstance -Class Win32_OperatingSystem

# OS Build
$OSBuild = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')

# Up time
# Get the last boot time of the system
$lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
# Calculate the uptime by subtracting the last boot time from the current time
$uptime = (Get-Date) - $lastBootTime
# Output the uptime in a readable format
$uptimeReadable = "{0} days, {1} hours, {2} minutes" -f $uptime.Days,$uptime.Hours,$uptime.Minutes

# Username
$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Monitor(s)
# function GetMonitorInfo {
  # Thanks to https://github.com/MaxAnderson95/Get-Monitor-Information
 #  $Monitors = Get-CimInstance -Namespace "root\WMI" -Class "WMIMonitorID"
  # foreach ($Monitor in $Monitors) {
  #   ([System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName)).Replace("$([char]0x0000)","")
  #   ([System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)).Replace("$([char]0x0000)","")
  #   ([System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)).Replace("$([char]0x0000)","")
 #  }
# }

## If some computers have more than three monitors, you can copy the lines below, but change the variable and index number by counting them up by 1.
# $Monitor1 = GetMonitorInfo | Select-Object -Index 0,1
# $Monitor1SN = GetMonitorInfo | Select-Object -Index 2
# $Monitor2 = GetMonitorInfo | Select-Object -Index 3,4
# $Monitor2SN = GetMonitorInfo | Select-Object -Index 5
# $Monitor3 = GetMonitorInfo | Select-Object -Index 6,7
# $Monitor3SN = GetMonitorInfo | Select-Object -Index 8

# $Monitor1 = $Monitor1 -join ' '
# $Monitor2 = $Monitor2 -join ' '
# $Monitor3 = $Monitor3 -join ' '

# Type of computer
# Values are from https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure
$Chassis = Get-CimInstance -ClassName Win32_SystemEnclosure -Namespace 'root\CIMV2' -Property ChassisTypes | Select-Object -ExpandProperty ChassisTypes

$ChassisDescription = switch ($Chassis) {
  "1" { "Other" }
  "2" { "Unknown" }
  "3" { "Desktop" }
  "4" { "Low Profile Desktop" }
  "5" { "Pizza Box" }
  "6" { "Mini Tower" }
  "7" { "Tower" }
  "8" { "Portable" }
  "9" { "Laptop" }
  "10" { "Notebook" }
  "11" { "Hand Held" }
  "12" { "Docking Station" }
  "13" { "All in One" }
  "14" { "Sub Notebook" }
  "15" { "Space-Saving" }
  "16" { "Lunch Box" }
  "17" { "Main System Chassis" }
  "18" { "Expansion Chassis" }
  "19" { "SubChassis" }
  "20" { "Bus Expansion Chassis" }
  "21" { "Peripheral Chassis" }
  "22" { "Storage Chassis" }
  "23" { "Rack Mount Chassis" }
  "24" { "Sealed-Case PC" }
  "30" { "Tablet" }
  "31" { "Convertible" }
  "32" { "Detachable" }
  default { "Unknown" }
}

# Function to write the inventory to the CSV file
function OutputToCSV {
  # CSV properties
  # Thanks to https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Script-Get-beced710
  Write-Host "Adding inventory information to the CSV file..."
  $infoColl =@()
  $infoObject = New-Object PSObject
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Date Collected" -Value $Date
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Hostname" -Value $env:computername
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "IP Address" -Value $interfaceIP
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "MAC Address" -Value $interfaceMAC
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "User" -Value $Username
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Type" -Value $ChassisDescription
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Serial Number/Service Tag" -Value $SN
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Model" -Value $Model
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "BIOS" -Value $BIOS
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "CPU" -Value $CPU
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "RAM (GB)" -Value $RAM
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Storage (GB)" -Value $Storage
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "GPU 0" -Value $GPU0
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "GPU 1" -Value $GPU1
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "OS" -Value $os.Caption
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "OS Version" -Value $os.BuildNumber
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Up time" -Value $uptimeReadable
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 1" -Value $Monitor1
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 1 Serial Number" -Value $Monitor1SN
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 2" -Value $Monitor2
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 2 Serial Number" -Value $Monitor2SN
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 3" -Value $Monitor3
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Monitor 3 Serial Number" -Value $Monitor3SN
  Add-Member -InputObject $infoObject -MemberType NoteProperty -Name "Installed Apps" -Value $appsList
  $infoObject
  $infoColl += $infoObject

  # Output to CSV file
  try {
    $infoColl | Export-Csv -Path $csv -NoTypeInformation
    Write-Host -ForegroundColor Green "Inventory was successfully updated!"
    exit 0
  }
  catch {
    if (-not (Test-Path $ErrorLogPath))
    {
      New-Item -ItemType "file" -Path $ErrorLogPath
      icacls $ErrorLogPath /grant Everyone:F
    }
    Add-Content -Path $ErrorLogPath -Value "[$Date] $Username at $env:computername was unable to export to the inventory file at $csv."
    throw "Unable to export to the CSV file. Please check the permissions on the file."
    exit 1
  }
}

# Just in case the inventory CSV file doesn't exist, create the file and run the inventory.
if (-not (Test-Path $csv))
{
  Write-Host "Creating CSV file..."
  try {
    New-Item -ItemType "file" -Path $csv
    icacls $csv /grant Everyone:F
    OutputToCSV
  }
  catch {
    if (-not (Test-Path $ErrorLogPath))
    {
      New-Item -ItemType "file" -Path $ErrorLogPath
      icacls $ErrorLogPath /grant Everyone:F
    }
    Add-Content -Path $ErrorLogPath -Value "[$Date] $Username at $env:computername was unable to create the inventory file at $csv."
    throw "Unable to create the CSV file. Please check the permissions on the file."
    exit 1
  }
}

# Check to see if the CSV file exists then run the script.
function Check-IfCSVExists {
  Write-Host "Checking to see if the CSV file exists..."
  $import = Import-Csv $csv
  if ($import -match $env:computername)
  {
    try {
      (Get-Content $csv) -notmatch $env:computername | Set-Content $csv
      OutputToCSV
    }
    catch {
      if (-not (Test-Path $ErrorLogPath))
      {
        New-Item -ItemType "file" -Path $ErrorLogPath
        icacls $ErrorLogPath /grant Everyone:F
      }
      Add-Content -Path $ErrorLogPath -Value "[$Date] $Username at $env:computername was unable to import and/or modify the inventory file located at $csv."
      throw "Unable to import and/or modify the CSV file. Please check the permissions on the file."
      exit 1
    }
  }
  else
  {
    OutputToCSV
  }
}

Check-IfCSVExists