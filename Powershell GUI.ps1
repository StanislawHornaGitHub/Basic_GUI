using module '.\Main\GUI_class.psm1'
#using module '.\Main\GUI_Configuration.psm1'

param(
    $Work
)

New-Variable -Name 'location' -Value "$((Get-Location).Path)" -Scope Script
function Invoke-Main {
    $ProgramName = ([GUI_Config]::ProgramName)
    [GUI]::New() | Out-Null

    
    Read-Host "elo"
    
}
Invoke-Main
