using module './Main/GUI_class.psm1'
Import-module './Main/GUI_Functions.psm1'
function Invoke-Main {
    [GUI]::New() | Out-Null    
}
Invoke-Main
