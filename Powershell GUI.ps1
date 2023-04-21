using module '.\Main\GUI_class.psm1'
#using module '.\Main\GUI_Configuration.psm1'

param(
    $Work
)

New-Variable -Name 'location' -Value "$((Get-Location).Path)" -Scope Script
function Invoke-Main {
    $ProgramName = ([GUI_Config]::ProgramName)
    If($Work -eq $true){
       [GUI]::New() | Out-Null
    }else{
        Powershell.exe -file "$location\$ProgramName.ps1" -ArgumentList "-Work true"
        start-process powershell -ArgumentList "-file C:\Users\stanislawhorna\VS Code Git\Basic GUI For Report Automation\Powershell GUI.ps1 -Work true"

        # Start-Job -Name $ProgramName `
        # -InitializationScript {
        #     Add-Type -AssemblyName System.Windows.Forms
        #     [System.Windows.Forms.Application]::EnableVisualStyles()
        # }`
        # -ScriptBlock{
        #     param(
        #         $ProgramName,
        #         $location
        #     )
        #     # $ScriptName = "$location\Powershell GUI.ps1"
        #     & "C:\Users\stanislawhorna\VS Code Git\Basic GUI For Report Automation\Powershell GUI.ps1" -Work $true
        # } -ArgumentList $ProgramName, $location
    }
    
    Read-Host "elo"
    
}
Invoke-Main
