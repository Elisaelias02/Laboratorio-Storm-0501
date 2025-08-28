param(
    [string]$ResourceGroup,
    [string]$VMName = "LAB-CONNECT01"
)

$setupScript = {
    # Unir al dominio
    $credential = New-Object PSCredential("victim\administrator", (ConvertTo-SecureString "StormLab2024!" -AsPlainText -Force))
    Add-Computer -DomainName "victim.local" -Credential $credential -Restart -Force
}

# Primera fase: unir al dominio
Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptBlock $setupScript

# Esperar reinicio
Start-Sleep 120

# Segunda fase: instalar Entra Connect
$installScript = {
    # Crear directorio temporal
    New-Item -ItemType Directory -Path "C:\temp" -Force
    
    # Descargar .NET Framework 4.8
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP48-x86-x64-AllOS-ENU.exe" -OutFile "C:\temp\NDP48.exe"
    Start-Process -FilePath "C:\temp\NDP48.exe" -ArgumentList "/quiet" -Wait
    
    # Descargar Entra Connect
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi" -OutFile "C:\temp\AzureADConnect.msi"
    
    # Instalar Entra Connect
    msiexec /i "C:\temp\AzureADConnect.msi" /qn /l*v "C:\temp\install.log"
    
    # Crear script de configuración automática
    $configScript = @'
# Este script debe ejecutarse manualmente después del deployment
# para completar la configuración de Entra Connect
Write-Host "Ejecutar Azure AD Connect Wizard manualmente" -ForegroundColor Yellow
Write-Host "1. Custom Installation" -ForegroundColor Yellow
Write-Host "2. Password Hash Synchronization" -ForegroundColor Yellow
Write-Host "3. Conectar a victim.local" -ForegroundColor Yellow
Write-Host "4. Conectar a Azure tenant con Global Admin" -ForegroundColor Yellow
'@
    
    $configScript | Out-File "C:\temp\manual-config-steps.txt"
}

Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptBlock $installScript
