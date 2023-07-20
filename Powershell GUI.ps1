using module './Main/GUI_class.psm1'
Import-module './Main/GUI_Functions.psm1'
function Invoke-Main {
    [GUI]::New() | Out-Null    
}
Invoke-Main


# Invoke-PS2EXE `
#     -inputFile '.\Powershell GUI.ps1' `
#     -outputFile '.\Powershell GUI.exe' `
#     -iconFile ".\Icon\new-icon.ico"  `
#     -company "Stanislaw Horna" `
#     -title "Executable to run gui interface" `
#     -version "1.0.0.0" `
#     -copyright "Stanislaw Horna" `
#     -product "GUI runner" `
#     -noConsole -x64