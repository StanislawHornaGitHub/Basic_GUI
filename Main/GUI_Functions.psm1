<# 
## Writing status & Log
    Cmdlet: Write-Status -Message "Information visible to the User in GUI" [Switch]-Final
        -Final - Should be used to final result status (success / failure)
    
    Cmdlet: Write-Log -Message "Information will be saved in logs, but user will not be informed"
#>
using module '.\\Runspace_class.psm1'
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
    Write-Status -Message "Parallel operations"
    $hashParallel = @{
        'J1' = [scriptblock] {
            $csv = Import-Csv -Path "C:\Temp\Output_Daily_Reports_Powershell\NexthinkRawData.csv"
            for ($i = 1; $i -lt $csv.Count; $i++) {
                $thisDate = $csv[$i]."Last seen"
                $thatDate = $csv[($i - 1)]."Last seen"
                if ([datetime]::ParseExact($thisDate, "yyyy-MM-dd'T'HH:mm:ss", $null) -gt
                    [datetime]::ParseExact($thatDate, "yyyy-MM-dd'T'HH:mm:ss", $null)) {
                    $csv[$i]."Device name" | Out-File "./test.csv" -Append
                }
                if($i -gt 100){
                    break
                }
            }
            "FLAG J1" | Out-File "./tempflagfile.txt" -Append
        }
        'J2' = [scriptblock] {
            $csv = Import-Csv -Path "C:\Temp\Output_Daily_Reports_Powershell\NexthinkRawData.csv"
            for ($i = 1; $i -lt $csv.Count; $i++) {
                $thisDate = $csv[$i]."Last seen"
                $thatDate = $csv[($i - 1)]."Last seen"
                if ([datetime]::ParseExact($thisDate, "yyyy-MM-dd'T'HH:mm:ss", $null) -gt
                    [datetime]::ParseExact($thatDate, "yyyy-MM-dd'T'HH:mm:ss", $null)) {
                    $csv[$i]."Device name" | Out-File "./test.csv" -Append
                }
                if($i -gt 100){
                    break
                }
            }
            "FLAG J2" | Out-File "./tempflagfile.txt" -Append
        }
        'J3' = [scriptblock] {
            $csv = Import-Csv -Path "C:\Temp\Output_Daily_Reports_Powershell\NexthinkRawData.csv"
            for ($i = 1; $i -lt $csv.Count; $i++) {
                $thisDate = $csv[$i]."Last seen"
                $thatDate = $csv[($i - 1)]."Last seen"
                if ([datetime]::ParseExact($thisDate, "yyyy-MM-dd'T'HH:mm:ss", $null) -gt
                    [datetime]::ParseExact($thatDate, "yyyy-MM-dd'T'HH:mm:ss", $null)) {
                    $csv[$i]."Device name" | Out-File "./test.csv" -Append
                }
                if($i -gt 100){
                    break
                }
            }
            "FLAG J3" | Out-File "./tempflagfile.txt" -Append
        }
        'J4' = [scriptblock] {
            $csv = Import-Csv -Path "C:\Temp\Output_Daily_Reports_Powershell\NexthinkRawData.csv"
            for ($i = 1; $i -lt $csv.Count; $i++) {
                $thisDate = $csv[$i]."Last seen"
                $thatDate = $csv[($i - 1)]."Last seen"
                if ([datetime]::ParseExact($thisDate, "yyyy-MM-dd'T'HH:mm:ss", $null) -gt
                    [datetime]::ParseExact($thatDate, "yyyy-MM-dd'T'HH:mm:ss", $null)) {
                    $csv[$i]."Device name" | Out-File "./test.csv" -Append
                }
                if($i -gt 100){
                    break
                }
            }
            "FLAG J4" | Out-File "./tempflagfile.txt" -Append
        }
    }
    try {
        $temp = [RunSpaceArea]::new($hashParallel)
        $temp.StartAllJobs()
        $temp.WaitAnyPSInstance()
    }
    catch {
        write-catch -Message $_ -throwRUN
    }


    lfjn
    ldk
    Write-Status -Message "End"  

    Write-Status -Message "Success" -Final


}