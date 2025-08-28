#Requires -Version 7
param(
    [string]$SubscriptionId,
    [string]$ResourceGroup = "RG-Storm-Lab",
    [string]$Location = "East US",
    [string]$DomainName = "victim.local",
    [string]$AdminPassword = "StormLab2024!",
    [switch]$SkipAzureLogin
)

# Configuración inicial
$ErrorActionPreference = "Stop"
Write-Host "=== Iniciando deployment del laboratorio Storm-0501 ===" -ForegroundColor Green

if (-not $SkipAzureLogin) {
    Connect-AzAccount
    Set-AzContext -SubscriptionId $SubscriptionId
}

# Variables
$templateUri = "https://raw.githubusercontent.com/[tu-repo]/storm-lab-templates/main/azuredeploy.json"
$securePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force

# Deploy infrastructure
Write-Host "Desplegando infraestructura base..." -ForegroundColor Yellow
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroup `
    -TemplateUri $templateUri `
    -adminPassword $securePassword `
    -domainName $DomainName `
    -location $Location

# Configurar VMs
Write-Host "Configurando Domain Controller..." -ForegroundColor Yellow
& .\scripts\Setup-DomainController.ps1 -ResourceGroup $ResourceGroup -VMName "LAB-DC01"

Write-Host "Configurando Entra Connect Server..." -ForegroundColor Yellow
& .\scripts\Setup-EntraConnect.ps1 -ResourceGroup $ResourceGroup -VMName "LAB-CONNECT01"

Write-Host "Configurando Attacker Workstation..." -ForegroundColor Yellow
& .\scripts\Setup-AttackerTools.ps1 -ResourceGroup $ResourceGroup -VMName "LAB-ATTACKER01"

Write-Host "=== Deployment completado! ===" -ForegroundColor Green
Write-Host "Recursos creados en: $ResourceGroup" -ForegroundColor Yellow
Write-Host "Próximo paso: Ejecutar .\scripts\Configure-Azure-Tenant.ps1" -ForegroundColor Yellow
