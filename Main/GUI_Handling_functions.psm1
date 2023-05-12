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
<#
            $Global:Location = $CurrentLocation
            $Global:EnvironmentalVariables = $EnvironmentalVariablesFromClass
            $Global:ExistingPSprocesses = $IDs
            $Global:Consumption = @{
                'currentCPU' = 0
                'currentRAM' = ""
                'peakCPU' = 0
                'peakRAM' = ""
                'sumCPU' = 0
                'sumRAM' = 0
                'counter' = 0
            }

1 milisecond = 10000 ticks
#>
function Get-Consumption {
    $delay = 2000
    $StartSnap = (Get-Process powershell | Where-Object { $_.ID -notin $Global:ExistingPSprocesses })
    Start-Sleep -Milliseconds $delay
    $EndSnap = (Get-Process powershell | Where-Object { $_.ID -notin $Global:ExistingPSprocesses })
    
    $StartCPUtime = 0
    $StartSnap | ForEach-Object { $StartCPUtime += $_.TotalProcessorTime.Milliseconds }

    $EndCPUtime = 0
    $EndSnap | ForEach-Object { $EndCPUtime += $_.TotalProcessorTime.Milliseconds }
    if ($EndCPUtime -gt $StartCPUtime) {
        $Global:Consumption.'currentCPU' = [math]::Round((($EndCPUtime - $StartCPUtime) / ($delay * $Global:CPUs) * 100),2)
    }
    if ($Global:Consumption.'currentCPU' -gt $Global:Consumption.'peakCPU') {
        $Global:Consumption.'peakCPU' = $Global:Consumption.'currentCPU'
    }

    $RAMusageMB = 0
    $EndSnap | ForEach-Object { $RAMusageMB += $_.WorkingSet }
    $RAMusageMB /= 1MB
    $Global:Consumption.'currentRAM' = [math]::Round($RAMusageMB,1)
    if ($Global:Consumption.'currentRAM' -gt $Global:Consumption.'peakRAM') {
        $Global:Consumption.'peakRAM' = $Global:Consumption.'currentRAM'
    }

    $Global:Consumption.'sumCPU' += $Global:Consumption.'currentCPU'
    $Global:Consumption.'sumRAM' += $Global:Consumption.'currentRAM'
    $Global:Consumption.'counter' ++
    Write-Consumption
}
function Write-Consumption {
    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "currentCPU-*" | Remove-Item -Force -Confirm:$false
    New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/currentCPU-$($Global:Consumption.currentCPU)"
    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "currentRAM-*" | Remove-Item -Force -Confirm:$false
    New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/currentRAM-$($Global:Consumption.currentRAM)"
    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "peakCPU-*" | Remove-Item -Force -Confirm:$false
    New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/peakCPU-$($Global:Consumption.peakCPU)"
    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "peakRAM-*" | Remove-Item -Force -Confirm:$false
    New-Item -ItemType File -Path "$($Global:EnvironmentalVariables.'StatusPath')/peakRAM-$($Global:Consumption.peakRAM)"   
}
function Write-ConsumptionSummary{
    "peakCPU: $($Global:Consumption.'peakCPU') %" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    "peakRAM: $($Global:Consumption.'peakRAM') MB" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    $AverageCPU = ($Global:Consumption.'sumCPU') / ($Global:Consumption.'counter')
    $AverageRAM =  ($Global:Consumption.'sumRAM') / ($Global:Consumption.'counter')
    "AverageCPU: $AverageCPU %" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    "AverageRAM: $AverageRAM MB" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    $EndTime = (Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "*$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).LastAccessTime.ToString('HH\:mm\:ss\.fff')
    $Message = (Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "*$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).Name.Split(".")[0]
    "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
}