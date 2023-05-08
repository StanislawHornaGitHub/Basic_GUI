# GUI components Structure to read out details
# $GUI_Components = @{
#     'Small_GUI' = @{
#         'Label'       = @{}
#         'Box'         = @{}
#         'Checkbox'    = @{}
#         'Button'      = @{}
#         'ProgressBar' = @{}
#     }
#     'Big_GUI'   = @{
#         'Label'       = @{}
#         'Box'         = @{}
#         'Checkbox'    = @{}
#         'Button'      = @{}
#         'ProgressBar' = @{}
#     }
# }


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
function Invoke-Connection {
    param(
        [hashtable]$GUI_Components,
        [hashtable]$EnvironmentalVariables
    )
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    # Write-Host $Portal
    # Write-Host $Credentials
    # Write-Host $Engines
    Write-Log -Message "Trying to retrieve engine list" -EnvironmentalVariables $EnvironmentalVariables
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    if ($num -eq 1) {
        $ResultHash.Add("Connected", $true)
        $engines = @{'engine1' = 'aaaaa'
            'engine2'          = 'bbbb'
        }
        Write-Log -Message "Engine list ready" -EnvironmentalVariables $EnvironmentalVariables
        $ResultHash.Add('Engines', $engines)
    }
    else {
        $ResultHash.Add("Connected", $false)
        $ResultHash.Add("ErrorMessage", "Unauthorised access")
        Write-Log -Message "Unauthorised access" -EnvironmentalVariables $EnvironmentalVariables
    }
    return $ResultHash
}
function Invoke-Run {
    param(
        [hashtable]$GUI_Components,
        [hashtable]$Engines,
        [hashtable]$EnvironmentalVariables
    )
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    $Timers = @{}
    # Write-Host $Portal
    # Write-Host $Credentials
    # Write-Host $Engines
    $delay = 2000
    Get-Process excel
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 

    $Timers = Write-Status -Message "Microsoft Edge" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers
    Start-Sleep -Milliseconds $delay
    $Timers = Write-Status -Message "Teams" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers
    Start-Sleep -Milliseconds $delay
    $Timers = Write-Status -Message "Chrome" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers
    Start-Sleep -Milliseconds $delay

    lfjn
    ldk

    $Timers = Write-Status -Message "End" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    douh
    if ($num -eq 1) {
        $Timers = Write-Status -Message "Success" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers -Final
    }
    else {
        $Timers = Write-Status -Message "Connection aborted" -EnvironmentalVariables $EnvironmentalVariables -Timers $Timers -Final
    }
    $Error | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')\$($EnvironmentalVariables.'RunRawLogName')" -Append
    return $ResultHash
}
function Write-Status {
    param (
        [String]$Message,
        [hashtable]$EnvironmentalVariables,
        [hashtable]$Timers,
        [Switch]$Final
    )
    if ($Final) {
        New-Item -ItemType File -Path "$($EnvironmentalVariables.'StatusPath')/$Message$($EnvironmentalVariables.'FinalStatusExtension')" | Out-Null
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')/$($EnvironmentalVariables.'LogName')" -Append
    }
    else {
        New-Item -ItemType File -Path "$($EnvironmentalVariables.'StatusPath')/$Message$($EnvironmentalVariables.'ProcessingStatusExtension')" | Out-Null
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')/$($EnvironmentalVariables.'LogName')" -Append
    }
    if (($Timers.Keys.Count -eq 0) -or ($null -eq $Timers)) {
        $StopWatchOverall = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $Timers = @{
            'Order'       = @('Overall proccessing time', $Message)
            'Stopwatches' = @{
                'Overall proccessing time' = $StopWatchOverall
                $Message                   = $StopWatchMessage
            }
        }
    }
    elseif ($Final) {
        foreach ($Watch in $Timers.'Stopwatches'.Keys) {
            if ($Watch.IsRunning) {
                $Timers.'Stopwatches'.$Watch.Stop()
            }
        }
        foreach ($name in $Timers.'Order') {
            $Time = $Timers.'Stopwatches'.$name.Elapsed.ToString("hh\:mm\:ss\.fff")
            "$name - $Time" | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')/$($EnvironmentalVariables.'ExecutionTimersName')" -Append
        }
        $EndTime = (Get-ChildItem -Path $($EnvironmentalVariables.'StatusPath') -Filter "*$($EnvironmentalVariables.'FinalStatusExtension')" | Select-Object -First 1).LastAccessTime.ToString('HH\:mm\:ss\.fff')
        "Execution status: $Message ; End time: $EndTime`n" | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')/$($EnvironmentalVariables.'ExecutionTimersName')" -Append
    }
    else {
        $StopWatchMessage = [System.Diagnostics.Stopwatch]::StartNew()
        $StopWatchToPause = ($Timers.'Order')[(($Timers.'Order').count - 1)]
        $Timers.'Stopwatches'.$StopWatchToPause.Stop()
        $Timers.'Order' += "$Message"
        $Timers.'Stopwatches'.Add($Message, $StopWatchMessage)
    }
    return $Timers
}
function Write-Log {
    param (
        [String]$Message,
        [hashtable]$EnvironmentalVariables
    )
    "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')/$($EnvironmentalVariables.'LogName')" -Append
}