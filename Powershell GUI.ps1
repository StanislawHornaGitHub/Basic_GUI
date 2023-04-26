using module '.\Main\GUI_class.psm1'
using module '.\Main\GUI_Configuration.psm1'


param(
    $Work
)
Import-module '.\Main\GUI_Functions.psm1'
New-Variable -Name 'location' -Value "$((Get-Location).Path)" -Scope Script
function Invoke-Main {
    [GUI]::New() | Out-Null

    
    
}
Invoke-Main
