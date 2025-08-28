param(
    [ValidateSet("Azure","Local","Fast")]
    [string]$DeploymentType = "Fast",
    [string]$SubscriptionId
)

Write-Host "=== Storm-0501 Lab Quick Deploy ===" -ForegroundColor Green

switch ($DeploymentType) {
    "Azure" {
        # Deploy completo en Azure
        Write-Host "Desplegando en Azure..." -ForegroundColor Yellow
        & .\deploy-storm-lab.ps1 -SubscriptionId $SubscriptionId
    }
    "Local" {
        # Vagrant deployment
        Write-Host "Desplegando localmente con Vagrant..." -ForegroundColor Yellow
        vagrant up
    }
    "Fast" {
        # Solo configurar Azure tenant y storage accounts
        Write-Host "Configuración rápida - solo recursos Azure..." -ForegroundColor Yellow
        & .\scripts\Fast-Azure-Setup.ps1
    }
}

Write-Host "Deployment completado!" -ForegroundColor Green
Write-Host "Siguiente paso: Revisar README.md para configuración manual pendiente" -ForegroundColor Yellow
