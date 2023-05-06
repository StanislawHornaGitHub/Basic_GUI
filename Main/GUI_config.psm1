enum ComponentType {
    Small_GUI = 0
    Big_GUI = 1
}
class GUI_Config {
    # Form Variables
    static [string] $ProgramName = "Powershell GUI"
    static [string] $ProgramTitle = "Script for report automation (test change)"
    static [string] $RunButton = "Prepare Report"
    static [int] $Big_FormSize_X = 480
    static [int] $Big_FormSize_Y = 150
    static [int] $Small_FormSize_X = 480
    static [int] $Small_FormSize_Y = 125
    static [string] $IconPath = "$((Get-Location).Path)\Main\Icon\new-icon.ico"

    # Processing Variables
    static [string] $LockFile = "$((Get-Location).Path)\Main\$([GUI_Config]::ProgramName).LOCK"
    static [string] $ResultFolder = "$((Get-Location).Path)/Output"

    # Logging Variables
    static [string] $StatusPath = "$((Get-Location).Path)\Main\Status"
    static [string] $LogsPath = "$((Get-Location).Path)\Main\Log"
    static [string] $MergedLogsPath = "$((Get-Location).Path)\Logs"
    static [int] $ArchiveLogsNumber = 20
    static [string] $ProcessingStatusExtension = "*.status"
    static [string] $FinalStatusExtension = "*.finalstatus"
    static [string] $GUI_LogName = "GUI.log"
    static [string] $Connection_LogName = "Connection.log"
    static [string] $Execution_LogName = "Execution.log"
    static [string] $RunRawLogName = "RUN-raw.log"

    static FolderStructureCheck() {
        if (Test-Path -Path ([GUI_Config]::StatusPath)) {
            Remove-Item -Path ([GUI_Config]::StatusPath) -Recurse -Force -Confirm:$false
        }
        New-Item -ItemType Directory -Path ([GUI_Config]::StatusPath) | Out-Null
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

    static [void] WriteLog([string]$Message, [String]$LogName) {
        [GUI_Config]::GenerateLog($Message) | Out-File -FilePath "$([GUI_Config]::LogsPath)/$LogName" -Append
    }

    static [string] GenerateLog([string]$Message) {
        return "$(([System.DateTime]::Now).ToString('HH\:mm\:ss\.fff')) | $Message"
    }

    static [void] MergeLogs() {
        $Logs = Get-ChildItem -Path ([GUI_Config]::LogsPath) | Where-Object { $_.Name -notlike "*$([GUI_Config]::RunRawLogName)*" }
        $LogsArray = @()
        foreach ($File in $Logs) {
            $ImportedLog = Get-Content -Path $File.FullName
            $LogName = $File.Name.Split(".")[0]
            $LogsArray += $ImportedLog | ForEach-Object {
                $_.Split("|") -join "| $LogName |"
            }
        }
        $LogsArray = $LogsArray | Sort-Object { $_.Split("|")[0] }
        $MergedLogName = "$(([System.DateTime]::Now).ToString('yyy-MM-dd HH\.mm\.ss')) $([GUI_Config]::ProgramName)"
        $LogsArray | Out-File -FilePath "$([GUI_Config]::MergedLogsPath)\$MergedLogName.log" 

    }

    static [void] CleanupOldLogs() {
        $Files = Get-ChildItem $([GUI_Config]::MergedLogsPath)
        $Files | Sort-Object { $_.CreationTimeUtc } -Descending | Select-Object -Skip ([GUI_Config]::ArchiveLogsNumber) | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Confirm:$false
        }
    }

    static [void] StartInstance() {
        if (Test-Path -Path ([GUI_Config]::LockFile)) {
            throw "Another instance is running"
        }
        else {
            try {
                New-Item -ItemType File -Path ([GUI_Config]::LockFile)
            }
            catch {
                throw "Unknown error"
            }
        }
        [GUI_Config]::FolderStructureCheck()
    }

    static [void] CloseInstance() {
        [GUI_Config]::MergeLogs()
        [GUI_Config]::CleanupOldLogs()
        try {
            Remove-Item -Path ([GUI_Config]::LockFile) -Force -Confirm:$false
        }
        catch {
        }
    }
}