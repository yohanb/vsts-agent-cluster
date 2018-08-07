#requires -version 5.0

Begin {
    $ErrorActionPreference = 'stop'
}

Process {
    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }  

    $profileFilePath = "$HOME\Documents\WindowsPowerShell\profile.ps1"
    If(!(Test-Path $profileFilePath))
    {
        New-Item -ItemType File -Force -Path $profileFilePath | Out-Null
    }
    
    $profileContent = Get-Content $profileFilePath

    $modulePath = "$PSScriptRoot\ps-modules\Gravt.psm1"
    
    If (-NOT ($profileContent -contains "import-module $PSScriptRoot\ps-modules\Gravt.psm1 -WarningAction Ignore")){
        Add-Content $profileFilePath "`n$modulePath -WarningAction Ignore`n"
        Write-Host "Gravt Module Initialized - Type Get-GravtHelp for more information"
    }

    Import-Module "$modulePath" -WarningAction Ignore

    Write-Host "`n************** You are ready to go, check the command you can now use **************" -ForegroundColor Green
    Get-GravtHelp
}