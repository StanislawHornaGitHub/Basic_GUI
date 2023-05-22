<# 
## Writing status & Log
    Cmdlet: Write-Status -Message "Information visible to the User in GUI" [Switch]-Final
        -Final - Should be used to final result status (success / failure)
    
    Cmdlet: Write-Log -Message "Information will be saved in logs, but user will not be informed"
#>
Import-Module '.\Main\GUI_Handling_functions.psm1'
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
    $csv = Import-Csv -Path "C:\Temp\aa.csv"
    for ($i = 1; $i -lt $csv.Count; $i++) {
        $thisDate = $csv[$i]."Last seen"
        $thatDate = $csv[($i - 1)]."Last seen"
        if ([datetime]::ParseExact($thisDate, "yyyy-MM-dd'T'HH:mm:ss", $null) -gt
            [datetime]::ParseExact($thatDate, "yyyy-MM-dd'T'HH:mm:ss", $null)) {
            $csv[$i]."Device name" | Out-File "./test.csv" -Append
        }
    }

    try {
        lfjn
    }
    catch {
        Write-Catch $_ 
    }
    Start-Sleep -Milliseconds $delay
    lfjn
    ldk
    Write-Status -Message "End"  
    $num = Get-Random -Minimum 0 -Maximum 2
    if ($num -eq 1) {
        Write-Status -Message "Success" -Final
    }
    else {
        Write-Status -Message "Connection aborted" -Final
    }

}