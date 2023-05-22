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
        $SharedArea.vars.LastExecution.EndTime = (Get-Date).ToString('HH\:mm\:ss\.fff')
        $SharedArea.vars.LastExecution.Message = $Message
        Write-Log -Message $Message
        $SharedArea.PowerShellInstances.Measurement.Stop()
        Write-ConsumptionSummary
        $SharedArea.vars.GUI.ShowExecutionStatus($Message)
        $SharedArea.vars.GUI.UnlockInputs()
    }
    else {
        $MessageLength = $Message.Length
        if ($MessageLength -lt 46) {
            $CharsToDisplay = $MessageLength
        }
        else {
            $CharsToDisplay = 46
        }
        $SharedArea.vars.GUI.WriteStatus($Message.Substring(0, $CharsToDisplay))
        Write-Log -Message $Message
    }
    if (($SharedArea.vars.Timers.Keys.Count -eq 0) -or ($null -eq $SharedArea.vars.Timers)) {
        $StopWatchOverall = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $SharedArea.vars.Timers = @{
            'Order'       = @('Overall proccessing time', $Message)
            'Stopwatches' = @{
                'Overall proccessing time' = $StopWatchOverall
                $Message                   = $StopWatchMessage
            }
        }
    }
    elseif ($Final) {
        foreach ($Watch in $SharedArea.vars.Timers.'Stopwatches'.Keys) {
            if ($Watch.IsRunning) {
                $SharedArea.vars.Timers.'Stopwatches'.$Watch.Stop()
            }
        }
        foreach ($name in $SharedArea.vars.Timers.'Order') {
            $Time = $SharedArea.vars.Timers.'Stopwatches'.$name.Elapsed.ToString("hh\:mm\:ss\.fff")
            "$name - $Time" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'ExecutionTimersName')" -Append
        }
        $EndTime = $SharedArea.vars.LastExecution.EndTime
        "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'ExecutionTimersName')" -Append
    }
    else {
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchToPause = ($SharedArea.vars.Timers.'Order')[(($SharedArea.vars.Timers.'Order').count - 1)]
        $SharedArea.vars.Timers.'Stopwatches'.$StopWatchToPause.Stop()
        $SharedArea.vars.Timers.'Order' += "$Message"
        $SharedArea.vars.Timers.'Stopwatches'.Add($Message, $StopWatchMessage)
    }
    
}
function Write-Log {
    param (
        [String]$Message
    )
    "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'LogName')" -Append
}
function Write-Catch {
    param (
        [String]$Message,
        [switch]$ThrowRUN
    )
    if ($ThrowRUN) {
        Write-Status -Message $Message -Final
        throw
    }
    else {
        Write-Status -Message $Message
    }
}
function Get-Consumption {
    param(
        $ID,
        $CPUs
    )
    $EndSnap = (Get-Process -Id $ID)
    
    $StartCPUtime = ((Get-Process -Id $ID).TotalProcessorTime.Ticks)

    Start-Sleep -Milliseconds $($SharedArea.vars.EnvClass.'ResourceConsumption_Interval')
    $EndSnap = (Get-Process -Id $ID)
    $EndCPUtime = ($EndSnap.TotalProcessorTime.Ticks)

    $CurrentCPU = [math]::Round(((($EndCPUtime - $StartCPUtime) / ($($SharedArea.vars.EnvClass.'ResourceConsumption_Interval') * $CPUs * 10000)) * 100), 2)
    
    if($CurrentCPU -gt 0){
        $SharedArea.vars.ConsumptionMeasurement.'currentCPU' = $CurrentCPU 
    }
    
    if ($SharedArea.vars.ConsumptionMeasurement.'currentCPU' -gt $SharedArea.vars.ConsumptionMeasurement.'peakCPU') {
        $SharedArea.vars.ConsumptionMeasurement.'peakCPU' = $SharedArea.vars.ConsumptionMeasurement.'currentCPU'
    }

    $RAMusageMB = $EndSnap.WorkingSet
    $RAMusageMB /= 1MB
    $SharedArea.vars.ConsumptionMeasurement.'currentRAM' = [math]::Round($RAMusageMB, 1)
    if ($SharedArea.vars.ConsumptionMeasurement.'currentRAM' -gt $SharedArea.vars.ConsumptionMeasurement.'peakRAM') {
        $SharedArea.vars.ConsumptionMeasurement.'peakRAM' = $SharedArea.vars.ConsumptionMeasurement.'currentRAM'
    }

    $SharedArea.vars.ConsumptionMeasurement.'sumCPU' += $CurrentCPU
    $SharedArea.vars.ConsumptionMeasurement.'sumRAM' += $SharedArea.vars.ConsumptionMeasurement.'currentRAM'
    $SharedArea.vars.ConsumptionMeasurement.'counter' ++
    $SharedArea.vars.GUI.WriteUsage(
        $($SharedArea.vars.ConsumptionMeasurement.'currentCPU'),
        $($SharedArea.vars.ConsumptionMeasurement.'currentRAM'),
        $($SharedArea.vars.ConsumptionMeasurement.'peakCPU'),
        $($SharedArea.vars.ConsumptionMeasurement.'peakRAM')
    )
}
function Write-ConsumptionSummary {
    "peakCPU: $($SharedArea.vars.ConsumptionMeasurement.'peakCPU') %" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'RecourceConsumption')" -Append
    "peakRAM: $($SharedArea.vars.ConsumptionMeasurement.'peakRAM') MB" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'RecourceConsumption')" -Append
    $AverageCPU = [math]::Round(($SharedArea.vars.ConsumptionMeasurement.'sumCPU') / ($SharedArea.vars.ConsumptionMeasurement.'counter'), 2)
    $AverageRAM = [math]::Round(($SharedArea.vars.ConsumptionMeasurement.'sumRAM') / ($SharedArea.vars.ConsumptionMeasurement.'counter'), 1)
    "AverageCPU: $AverageCPU %" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'RecourceConsumption')" -Append
    "AverageRAM: $AverageRAM MB" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'RecourceConsumption')" -Append
    $EndTime = $SharedArea.vars.LastExecution.EndTime
    $Message = $SharedArea.vars.LastExecution.Message
    "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($SharedArea.vars.EnvClass.'LogsPath')/$($SharedArea.vars.EnvClass.'RecourceConsumption')" -Append
}