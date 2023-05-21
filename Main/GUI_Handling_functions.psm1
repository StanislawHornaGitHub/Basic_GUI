using module '.\GUI_config.psm1'
using module '.\GUI_class.psm1'
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
function Write-Status {
    param (
        [String]$Message,
        [Switch]$Final
    )
    if ($Final) {
        $SharedArea.vars.GUI.ShowExecutionStatus($Message)
        #$SharedArea.vars.GUI.UnlockInputs()
        
    }
    else {
        $SharedArea.vars.GUI.WriteStatus($Message)
        # $SharedArea.vars.GUI.GUI_Components.'Big_GUI'.'Label'.'RunStatus'.text = $Message
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
function Get-Consumption {
    try {
        $StartSnap = (Get-Process powershell | Where-Object { $_.ID -notin $Global:ExistingPSprocesses })
    }
    catch {
        return
    }
    
    Start-Sleep -Milliseconds $($Global:EnvironmentalVariables.'ResourceConsumption_Interval')
    $EndSnap = (Get-Process powershell | Where-Object { $_.ID -notin $Global:ExistingPSprocesses })
    
    $StartCPUtime = 0
    $StartSnap | ForEach-Object { $StartCPUtime += $_.TotalProcessorTime.Milliseconds }

    $EndCPUtime = 0
    $EndSnap | ForEach-Object { $EndCPUtime += $_.TotalProcessorTime.Milliseconds }
    if ($EndCPUtime -gt $StartCPUtime) {
        $Global:Consumption.'currentCPU' = [math]::Round((($EndCPUtime - $StartCPUtime) / ($($Global:EnvironmentalVariables.'ResourceConsumption_Interval') * $Global:CPUs) * 100), 2)
    }
    if ($Global:Consumption.'currentCPU' -gt $Global:Consumption.'peakCPU') {
        $Global:Consumption.'peakCPU' = $Global:Consumption.'currentCPU'
    }

    $RAMusageMB = 0
    $EndSnap | ForEach-Object { $RAMusageMB += $_.WorkingSet }
    $RAMusageMB /= 1MB
    $Global:Consumption.'currentRAM' = [math]::Round($RAMusageMB, 1)
    if ($Global:Consumption.'currentRAM' -gt $Global:Consumption.'peakRAM') {
        $Global:Consumption.'peakRAM' = $Global:Consumption.'currentRAM'
    }

    $Global:Consumption.'sumCPU' += $Global:Consumption.'currentCPU'
    $Global:Consumption.'sumRAM' += $Global:Consumption.'currentRAM'
    $Global:Consumption.'counter' ++
    Write-Consumption
}
function Write-Consumption {
    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "currentCPU_*" | `
        Rename-Item -NewName "currentCPU_$($Global:Consumption.currentCPU)"

    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "currentRAM_*" | `
        Rename-Item -NewName "currentRAM_$($Global:Consumption.currentRAM)"

    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "peakCPU_*" | `
        Rename-Item -NewName "peakCPU_$($Global:Consumption.peakCPU)"

    Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "peakRAM_*" | `
        Rename-Item -NewName "peakRAM_$($Global:Consumption.peakRAM)"   
}
function Write-ConsumptionSummary {
    "peakCPU: $($Global:Consumption.'peakCPU') %" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    "peakRAM: $($Global:Consumption.'peakRAM') MB" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    $AverageCPU = [math]::Round(($Global:Consumption.'sumCPU') / ($Global:Consumption.'counter'), 2)
    $AverageRAM = [math]::Round(($Global:Consumption.'sumRAM') / ($Global:Consumption.'counter'), 1)
    "AverageCPU: $AverageCPU %" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    "AverageRAM: $AverageRAM MB" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
    $EndTime = (Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "*$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).LastAccessTime.ToString('HH\:mm\:ss\.fff')
    $Message = (Get-ChildItem -Path $($Global:EnvironmentalVariables.'StatusPath') -Filter "*$($Global:EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).Name.Split(".")[0]
    "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($Global:EnvironmentalVariables.'LogsPath')/$($Global:EnvironmentalVariables.'RecourceConsumption')" -Append
}