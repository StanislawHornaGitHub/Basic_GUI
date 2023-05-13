$TimerNew = [System.Diagnostics.Stopwatch]::StartNew()
Remove-Item -Path C:\Temp\Teststatus -Force -Confirm:$false
new-item -Type File -Path C:\Temp\Teststatus1
$TimerNew.Stop()

$TimerRename = [System.Diagnostics.Stopwatch]::StartNew()
Rename-Item -Path C:\Temp\Teststatus -NewName "teststatus1"
$TimerRename.Stop()