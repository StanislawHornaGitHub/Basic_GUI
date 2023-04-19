using module 'C:\Users\stanislawhorna\VS Code Git\Basic GUI For Report Automation\Main\GUI_class.psm1'
Import-Module 'C:\Users\stanislawhorna\VS Code Git\Basic GUI For Report Automation\Main\GUI_Functions.psm1'
function Show-Password {
    ($Global:Form).ShowPassword()
}
$Global:Form = [GUI]::New()