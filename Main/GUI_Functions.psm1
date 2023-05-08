<# 
## Writing status & Log
    Cmdlet: Write-Status -Message "Information visible to the User in GUI" [Switch]-Final
        -Final - Should be used to final result status (success / failure)
    
    Cmdlet: Write-Log -Message "Information will be saved in logs, but user will not be informed"
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
Import-Module '.\Main\GUI_Handling_functions.psm1'
function Invoke-Connection {
    param(
        [String]$Portal,
        [PSCredential]$Credentials
    )

    # Write-Host $Portal
    # Write-Host $Credentials
    # Write-Host $Engines
    Write-Log -Message "Trying to retrieve engine list" 
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    if ($num -eq 1) {
        $ResultHash.Add("Connected", $true)
        $engines = @{'engine1' = 'aaaaa'
            'engine2'          = 'bbbb'
        }
        Write-Log -Message "Engine list ready" 
        $ResultHash.Add('Engines', $engines)
    }
    else {
        $ResultHash.Add("Connected", $false)
        $ResultHash.Add("ErrorMessage", "Unauthorised access")
        Write-Log -Message "Unauthorised access" 
    }
    return $ResultHash
}
function Invoke-Run {
    param(
        [string] $Portal,
        [pscredential] $Credentials,
        $Engines
    )
    
    $delay = 2000
    Get-Process excel
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 
    [System.DateTime]::ParseExact("-", "yyyy-MM-dd'T'HH:mm:ss", $null) 

    Write-Status -Message "Microsoft Edge"  
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "Teams"  
    Start-Sleep -Milliseconds $delay
    Write-Status -Message "Chrome"  
    Start-Sleep -Milliseconds $delay

    lfjn
    ldk
    Write-Status -Message "End"  
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash = @{}
    douh
    if ($num -eq 1) {
        Write-Status -Message "Success"   -Final
    }
    else {
        Write-Status -Message "Connection aborted"   -Final
    }
    $Error | Out-File -FilePath "$($EnvironmentalVariables.'LogsPath')\$($EnvironmentalVariables.'RunRawLogName')" -Append
    return $ResultHash
}