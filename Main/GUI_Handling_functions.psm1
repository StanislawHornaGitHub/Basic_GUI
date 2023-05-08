function Write-Status {
    param (
        [String]$Message,
        [Switch]$Final
    )
    if ($Final) {
        New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/$Message$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Out-Null
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'LogName')" -Append
    }
    else {
        New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/$Message$($Global:EnvironmentalVariables.'ProcessingStatusExtension')" | Out-Null
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'LogName')" -Append
    }
    if (($Global:Timers.Keys.Count -eq 0) -or ($null -eq $Global:Timers)) {
        $StopWatchOverall = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $Global:Timers = @{
            'Order'       = @('Overall proccessing time', $Message)
            'Stopwatches' = @{
                'Overall proccessing time' = $StopWatchOverall
                $Message                   = $StopWatchMessage
            }
        }
    }
    elseif ($Final) {
        foreach ($Watch in $Global:Timers.'Stopwatches'.Keys) {
            if ($Watch.IsRunning) {
                $Global:Timers.'Stopwatches'.$Watch.Stop()
            }
        }
        foreach ($name in $Global:Timers.'Order') {
            $Time = $Global:Timers.'Stopwatches'.$name.Elapsed.ToString("hh\:mm\:ss\.fff")
            "$name - $Time" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'ExecutionTimersName')" -Append
        }
        $EndTime = (Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "*$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).LastAccessTime.ToString('HH\:mm\:ss\.fff')
        "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'ExecutionTimersName')" -Append
    }
    else {
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchToPause = ($Global:Timers.'Order')[(($Global:Timers.'Order').count - 1)]
        $Global:Timers.'Stopwatches'.$StopWatchToPause.Stop()
        $Global:Timers.'Order' += "$Message"
        $Global:Timers.'Stopwatches'.Add($Message, $StopWatchMessage)
    }
    
}
function Write-Log {
    param (
        [String]$Message
    )
    "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'LogName')" -Append
}