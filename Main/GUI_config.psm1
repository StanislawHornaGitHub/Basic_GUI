enum ComponentType {
    Measurement = -2
    Manual = -1
    Small_GUI = 0
    Big_GUI = 1
}
class GUI_Config {
    # Form Variables (Basic)
    static [string] $ProgramName = "Powershell GUI aaaaaa"
    static [string] $ProgramTitle = "GUI for Powershell automation"
    static [string] $RunButton = "Prepare Report"

    # Form Variables (Advanced)
    static [string] $PreDefinedEnvironment = ""
    static [hashtable] $InputVariables = @{
        'Portal'   = @{
            'Value'         = ""
            'Enabled'       = $true
            'ComponentType' = "Small_GUI"  # Default: "Small_GUI"
        }
        'Login'    = @{
            'Value'         = ""
            'Enabled'       = $true
            'ComponentType' = "Small_GUI"   # Default: "Small_GUI"
        }
        'Password' = @{
            'Value'         = ""
            'Enabled'       = $true
            'ComponentType' = "Small_GUI"   # Default: "Small_GUI"
        }
    }
    static [hashtable] $Jobs = @{
        'InvokeRun' = [scriptblock] {
            Import-Module ./Main/GUI_Functions.psm1
            Invoke-Run -Portal $SharedArea.Vars.Portal -Credentials $SharedArea.Vars.Credentials -Engines $SharedArea.Vars.Engines
        }
        'Measurement' = [scriptblock] {
            Import-Module ./Main/GUI_Functions.psm1
            $ID = (Get-process | Where-Object {$_.MainWindowTitle -eq $SharedArea.Vars.EnvClass.ProgramName}).Id
            $CPUs = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
            $ID | Out-File -FilePath .\test.txt
            $CPUs | Out-File -FilePath .\test.txt -Append
            Get-Process -Id $ID |Out-File -FilePath .\test.txt -Append
            do {
                try {
                    Get-Consumption -ID $ID -CPUs $CPUs
                }
                catch {
                    $_ | Out-File -FilePath .\test.txt -Append
                }
                
            }while ($true)
            $SharedArea.vars.ConsumptionMeasurement | Out-File -FilePath .\test.txt -Append
            Write-ConsumptionSummary
        }
    }
    static [scriptblock] $InvokeConnection = {
        param(
            [String]$Portal,
            [PSCredential]$Credentials
        )
        [GUI_Config]::WriteLog("Trying to retrieve engine list", $([GUI_Config]::Connection_LogName))
        $num = Get-Random -Minimum 0 -Maximum 2
        $ResultHash = @{}
        if ($num -eq 1) {
            $ResultHash.Add("Connected", $true)
            $engines = @{'engine1' = 'aaaaa'
                'engine2'          = 'bbbb'
            }
            [GUI_Config]::WriteLog("Engine list ready", $([GUI_Config]::Connection_LogName)) 
            $ResultHash.Add('Engines', $engines)
        }
        else {
            $ResultHash.Add("Connected", $false)
            $ResultHash.Add("ErrorMessage", "Unauthorised access")
            [GUI_Config]::WriteLog("Unauthorised access", $([GUI_Config]::Connection_LogName)) 
        }
        return $ResultHash
    }

    static [int] $Big_FormSize_X = 480
    static [int] $Big_FormSize_Y = 150
    static [int] $Small_FormSize_X = 480
    static [int] $Small_FormSize_Y = 125
    static [string] $IconPath = "$((Get-Location).Path)\Main\Icon\new-icon.ico"

    # Processing Variables
    static [string] $LockFile = "$((Get-Location).Path)\Main\$([GUI_Config]::ProgramName).LOCK"
    static [int] $LockPeriodInMinutes = 40
    static [string] $ResultFolder = "$((Get-Location).Path)/Output"

    # Required files
    static [array] $MainProgramComponents = @(
        'GUI_config.psm1',
        'GUI_class.psm1',
        'GUI_EnvironmentSelection.psm1',
        'GUI_Functions.psm1',
        'GUI_Handling_functions.psm1'
    )

    # Logging Variables
    static [string] $StatusPath = "$((Get-Location).Path)\Main\Status"
    static [string] $LogsPath = "$((Get-Location).Path)\Main\Log"
    static [string] $MergedLogsPath = "$((Get-Location).Path)\Logs"
    static [int] $ArchiveLogsNumber = 20
    static [string] $ProcessingStatusExtension = "*.status"
    static [string] $FinalStatusExtension = "*.finalstatus"
    static [string] $RecourceConsumption = "Consumption.usage"
    static [int] $ResourceConsumption_Interval = 200 # Default: 200
    static [string] $GUI_LogName = "GUI.log"
    static [string] $Connection_LogName = "Connection.log"
    static [string] $Execution_LogName = "Execution.log"
    static [string] $ExecutionTimersName = "ExecutionTimers.time"
    static [string] $RunErrors = "RUN-Errors.log"
    static [array] $ErrorsToIgnore = @(
        '*Exception calling "ParseExact" with "3" argument(s):*',
        '*excel*',
        '*ldk*'    
    )

    static FolderStructureCheck() {
        if (Test-Path -Path ([GUI_Config]::StatusPath)) {
            Remove-Item -Path ([GUI_Config]::StatusPath) -Recurse -Force -Confirm:$false
        }
        New-Item -ItemType Directory -Path ([GUI_Config]::StatusPath) | Out-Null
        if (-not (Test-Path -Path ([GUI_Config]::LogsPath))) {
            New-Item -ItemType Directory -Path ([GUI_Config]::LogsPath) | Out-Null
        }
        Get-ChildItem -Path ([GUI_Config]::LogsPath) | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Confirm:$false
        }
        if (-not (Test-Path -Path ([GUI_Config]::ResultFolder))) {
            New-Item -ItemType Directory -Path ([GUI_Config]::ResultFolder) | Out-Null
        }
        if (-not (Test-Path -Path ([GUI_Config]::MergedLogsPath))) {
            New-Item -ItemType Directory -Path ([GUI_Config]::MergedLogsPath) | Out-Null
        }
    }

    static CheckRequiredFiles() {
        $Check = @()
        foreach ($file in [GUI_Config]::MainProgramComponents) {
            if ((Test-Path -Path "$((Get-Location).Path)\Main\$file")) {
                $Check += $true
            }
            else {
                $Check += $false
            }
        }
        $NumberOfMissingFiles = ($Check | Where-Object { $_ -eq $false }).count
        if ($NumberOfMissingFiles -gt 0) {
            $MissingFiles = @()
            for ($i = 0; $i -lt $Check.Count; $i++) {
                if ($Check[$i] -eq $false) {
                    $MissingFiles += ([GUI_Config]::MainProgramComponents)[$i]
                }
            }
            if ($NumberOfMissingFiles -eq 1) {
                $Message = "$([GUI_Config]::ProgramName) files are corrupted.`nFollowing file is missing:`n$MissingFiles"
            }
            else {
                $FilesToMessage = $MissingFiles -join "`n"
                $Message = "$([GUI_Config]::ProgramName) files are corrupted.`nFollowing files are missing:`n$FilesToMessage"
            }
            Remove-Item -Path ([GUI_Config]::LockFile) -Force -Confirm:$false
            throw $Message
        }
    }

    static [void] WriteLog([string]$Message, [String]$LogName) {
        [GUI_Config]::GenerateLog($Message) | Out-File -FilePath "$([GUI_Config]::LogsPath)/$LogName" -Append
    }

    static [string] GenerateLog([string]$Message) {
        return "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message"
    }

    static [void] SaveJobError($JobErrors) {
        $FilteredErrors = @()
        $JobErrors = $JobErrors | Sort-Object -Unique
        foreach ($CurrentError in $JobErrors) {
            $flag = $false
            foreach ($ToIgnore in ([GUI_Config]::ErrorsToIgnore)) {
                if ($CurrentError.Exception.Message -like $ToIgnore) {
                    $flag = $true
                }
            }
            if ($flag -eq $false) {
                $FilteredErrors += $CurrentError
            }
        }
        $FilteredErrors | Out-File -FilePath "$([GUI_Config]::LogsPath)\$([GUI_Config]::RunErrors)" -Append
        $FinalStatus = Get-ChildItem -Path ([GUI_Config]::StatusPath) -Filter ([GUI_Config]::FinalStatusExtension) | Select-Object -First 1
        $Message = ($FinalStatus).Name.Split(".")[0]
        $EndTime = ($FinalStatus).LastAccessTime.ToString('HH\:mm\:ss\.fff')
        "Execution status: $Message ; End time: $EndTime`n`n" | Out-File -FilePath "$([GUI_Config]::LogsPath)\$([GUI_Config]::RunErrors)" -Append
    }

    static [void] MergeLogs() {
        $Logs = Get-ChildItem -Path ([GUI_Config]::LogsPath) | Where-Object { ($_.Name -notlike "*$([GUI_Config]::RunErrors)*") -and ($_.Name -ne $([GUI_Config]::ExecutionTimersName)) -and ($_.Name -ne $([GUI_Config]::RecourceConsumption)) }
        $LogsArray = @()
        foreach ($File in $Logs) {
            $ImportedLog = Get-Content -Path $File.FullName
            $LogName = $File.Name.Split(".")[0]
            $LogsArray += $ImportedLog | ForEach-Object {
                $_.Split("|") -join "| $LogName |"
            }
        }
        $LogsArray = $LogsArray | Sort-Object { $_.Split("|")[0] }
        $FlagForLogs = $false
        $flagForErrors = $false
        try {
            $EndTime = (Get-ChildItem -Path ([GUI_Config]::StatusPath) -Filter ([GUI_Config]::FinalStatusExtension) -ErrorAction Stop | Select-Object -First 1).LastAccessTime.ToString('yyy-MM-dd HH\.mm\.ss')
        }
        catch {
            $EndTime = $(([System.DateTime]::Now).ToString('yyy-MM-dd HH\.mm\.ss'))
        }
        Get-ChildItem -Path ([GUI_Config]::StatusPath) -Filter ([GUI_Config]::FinalStatusExtension) | Remove-Item -Force -Confirm:$false
        $MergedLogName = "$EndTime $([GUI_Config]::ProgramName)"
        try {
            $AdditionalData = Get-Content -Path "$([GUI_Config]::LogsPath)\$([GUI_Config]::ExecutionTimersName)" -ErrorAction Stop
            "Timers:" | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log"
            $AdditionalData | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
            $FlagForLogs = $true
            $flagForErrors = $true
        }
        catch {}
        try {
            $ResourceConsumption = Get-Content -Path "$([GUI_Config]::LogsPath)\$([GUI_Config]::RecourceConsumption)"
            "Resource consumption:" | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
            $ResourceConsumption | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
        }
        catch {}
        if ($flagForErrors -eq $true) {
            $Header = "`nErrors:"
        }
        else {
            $Header = "Errors:"
        }
        try {
            $AdditionalData = Get-Content -Path "$([GUI_Config]::LogsPath)\$([GUI_Config]::RunErrors)" -ErrorAction Stop
            $Header | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
            $AdditionalData | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
        }
        catch {}
        if ($FlagForLogs -eq $true) {
            $Header = "`n`nLogs:"
        }
        else {
            $Header = "Logs:"
        }
        try {
            $Header | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
            $LogsArray | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" -Append
        }
        catch {}
    }

    static [void] CleanupOldLogs() {
        $Files = Get-ChildItem $([GUI_Config]::MergedLogsPath)
        $Files | Sort-Object { $_.CreationTimeUtc } -Descending | Select-Object -Skip ([GUI_Config]::ArchiveLogsNumber) | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Confirm:$false
        }
    }

    static [void] CleanupStatuses() {
        $Statuses = Get-ChildItem -Path $([GUI_Config]::StatusPath) 
        if ($Statuses.Count -ge 1) {
            $Statuses | ForEach-Object {
                Remove-Item -Path $_.FullName -Force -Confirm:$false
            }
        }
    }

    static [void] StartInstance() {
        # Check for another program instance
        if ((Test-Path -Path ([GUI_Config]::LockFile)) -and
            ((Get-ChildItem ([GUI_Config]::LockFile)).CreationTime.AddMinutes(([GUI_Config]::LockPeriodInMinutes)) -gt (Get-Date) )) {
            throw "Another instance is running"
        }
        else {
            # If another instance is outdated remove lock file and kill process
            if ((Test-Path -Path ([GUI_Config]::LockFile))) {
                Remove-Item -Path ([GUI_Config]::LockFile) -Force -Confirm:$false
                $ProcessName = (Get-ChildItem ./ -Filter "*.exe").Name.Split(".")[0]
                try {
                    Get-Process -Name $ProcessName | Sort-Object { $_.StartTime } -Descending | Select-Object -Skip 1 | Stop-process
                }
                catch {
                }
            }
            try {
                New-Item -ItemType File -Path ([GUI_Config]::LockFile)
            }
            catch {
                throw "Unknown error"
            }
        }
        [GUI_Config]::CheckRequiredFiles()
        [GUI_Config]::FolderStructureCheck()
    }

    static [void] CloseInstance() {
        [GUI_Config]::MergeLogs()
        [GUI_Config]::CleanupOldLogs()
        try {
            Remove-Item -Path ([GUI_Config]::LockFile) -Force -Confirm:$false
        }
        catch {}
    }
}