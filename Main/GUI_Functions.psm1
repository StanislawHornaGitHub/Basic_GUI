Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
function Invoke-Connection {
    param(
        [hashtable]$GUI_Components,
        [String]$LogsPath,
        [String]$LogName
    )
    $Logs = @{
        'LogsPath' = $LogsPath
        'LogName'  = $LogName
    }
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    # Write-Host $Portal
    # Write-Host $Credentials
    # Write-Host $Engines
    Write-Log -Message "Trying to retrieve engine list" -Logs $Logs
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    if ($num -eq 1) {
        $ResultHash.Add("Connected", $true)
        $engines = @{'engine1' = 'aaaaa'
            'engine2'          = 'bbbb'
        }
        Write-Log -Message "Engine list ready" -Logs $Logs
        $ResultHash.Add('Engines', $engines)
    }
    else {
        $ResultHash.Add("Connected", $false)
        $ResultHash.Add("ErrorMessage", "Unauthorised access")
        Write-Log -Message "Unauthorised access" -Logs $Logs
    }
    return $ResultHash
}
function Invoke-Run {
    param(
        [hashtable]$GUI_Components,
        [hashtable]$Engines,
        [String]$LogsPath,
        [String]$LogName,
        [String]$ProcessingStatusExtension,
        [String]$FinalStatusExtension
    )
    $Logs = @{
        'LogsPath'                  = $LogsPath
        'LogName'                   = $LogName
        'ProcessingStatusExtension' = ($ProcessingStatusExtension.Replace("*", ""))
        'FinalStatusExtension'      = ($FinalStatusExtension.Replace("*", ""))
    }
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    # Write-Host $Portal
    # Write-Host $Credentials
    # Write-Host $Engines
    $delay = 2000
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "Processing" -Logs $Logs
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "Teams" -Logs $Logs
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "Chrome" -Logs $Logs
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "End" -Logs $Logs
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    if ($num -eq 1) {
        Write-Status -Message "Success" -Logs $Logs -Final
    }
    else {
        Write-Status -Message "Connection aborted" -Logs $Logs -Final
    }
    return $ResultHash
}
function Write-Status {
    param (
        [String]$Message,
        [hashtable]$Logs,
        [array]$Timers,
        [Switch]$Final
    )
    if ($Final) {
        $Message | Out-File -FilePath "./Main/Status/$Message.finalstatus"
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Logs.'LogsPath')/$($Logs.'LogName')" -Append
    }
    else {
        $Message | Out-File -FilePath "./Main/Status/$Message.status"
        "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Logs.'LogsPath')/$($Logs.'LogName')" -Append
    }
}
function Write-Log {
    param (
        [String]$Message,
        [hashtable]$Logs
    )
    "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message" | Out-File -FilePath "$($Logs.'LogsPath')/$($Logs.'LogName')" -Append
}