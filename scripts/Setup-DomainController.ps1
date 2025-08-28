param(
    [string]$ResourceGroup,
    [string]$VMName = "LAB-DC01",
    [string]$DomainName = "victim.local"
)

$scriptBlock = {
    param($DomainName)
    
    # Instalar AD DS
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    
    # Crear bosque
    $safeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName "VICTIM" `
        -InstallDns `
        -SafeModeAdministratorPassword $safeModePassword `
        -Force
    
    # Reiniciar
    Restart-Computer -Force
}

# Ejecutar en la VM
Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptBlock $scriptBlock `
    -Parameter @{DomainName = $DomainName}

# Esperar reinicio
Start-Sleep 120

# Configuración post-reinicio
$postRebootScript = {
    param($DomainName)
    
    # Crear OUs
    $domainDN = "DC=" + $DomainName.Replace(".", ",DC=")
    New-ADOrganizationalUnit -Name "CorpUsers" -Path $domainDN
    New-ADOrganizationalUnit -Name "ServiceAccounts" -Path $domainDN
    
    # Crear usuarios críticos
    $users = @(
        @{Name="CloudSync-GA"; SAM="cloudsync-ga"; Password="InitialP@ss123!"; OU="ServiceAccounts"},
        @{Name="DA-Compromised"; SAM="da-comp"; Password="CompromisedP@ss!"; OU="CorpUsers"},
        @{Name="Backup-Service"; SAM="svc-backup"; Password="ServiceP@ss123!"; OU="ServiceAccounts"}
    )
    
    foreach ($user in $users) {
        $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force
        New-ADUser `
            -Name $user.Name `
            -SamAccountName $user.SAM `
            -UserPrincipalName "$($user.SAM)@$DomainName" `
            -Path "CN=$($user.OU),$domainDN" `
            -AccountPassword $securePassword `
            -Enabled $true `
            -PasswordNeverExpires $true
    }
    
    # Agregar DA-Compromised a Domain Admins
    Add-ADGroupMember -Identity "Domain Admins" -Members "da-comp"
    
    # Otorgar DCSync a svc-backup
    dsacls $domainDN /G "VICTIM\svc-backup:CA;Replicating Directory Changes All"
    dsacls $domainDN /G "VICTIM\svc-backup:CA;Replicating Directory Changes"
}

Invoke-AzVMRunCommand `
    -ResourceGroupName $ResourceGroup `
    -VMName $VMName `
    -CommandId 'RunPowerShellScript' `
    -ScriptBlock $postRebootScript `
    -Parameter @{DomainName = $DomainName}
