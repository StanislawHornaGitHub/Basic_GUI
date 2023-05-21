class RunSpaceArea {
    $SharedArea = [hashtable]::Synchronized(@{
            'Host'                = $Host
            'RunSpaces'           = @{}
            'PowershellInstances' = @{}
            'Scriptblocks'        = @{}
            'JobStatuses'         = @{}
            'Vars'                = @{}
        })

    RunSpaceArea([array]$JobNames, [array]$ScriptBlocks) {
        if ($JobNames.Count -ne $ScriptBlocks.Count) {
            Write-Error "JobNames are not matching with ScriptBlocks"
            return
        }
        $ThisSharedArea = $this.SharedArea
        foreach ($job in $JobNames) {            
            # Create runspace
            $this.SharedArea.RunSpaces.Add($job, ([System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()))
            $this.SharedArea.RunSpaces.$job.ApartmentState = "MTA"
            $this.SharedArea.RunSpaces.$job.ThreadOptions = "UseNewThread"
            $this.SharedArea.RunSpaces.$job.Open()
            $this.SharedArea.RunSpaces.$job.SessionStateProxy.SetVariable('SharedArea', $ThisSharedArea)
        }
        $this.CreatePSinstances($JobNames, $ScriptBlocks)
    }
    CreatePSinstances([array]$JobNames, [array]$ScriptBlocks) {
        $iterator = 0
        foreach ($job in $JobNames) {  
            # Create PowerShell instance
            $this.SharedArea.PowerShellInstances.Add($job, ([powershell]::Create()))
            $this.SharedArea.PowerShellInstances.$job.runspace = $this.SharedArea.RunSpaces.$job
            $this.SharedArea.PowerShellInstances.$job.AddScript($ScriptBlocks[$iterator])
            $this.SharedArea.Scriptblocks.Add($job, $ScriptBlocks[$iterator])
            $iterator++
        }  
    }
    StartAllJobs() {
        $this.StartJob($($this.SharedArea.PowerShellInstances.Keys))
    }
    DisposeAllJobs() {
        $this.DisposeJob($($this.SharedArea.PowerShellInstances.Keys))
    }
    StartJob([array]$JobNames) {
        foreach ($job in $JobNames) {
            $this.SharedArea.JobStatuses.Add($job, $this.SharedArea.PowerShellInstances.$job.BeginInvoke())
        }
    }
    DisposeJob([array]$JobNames) {
        foreach ($job in $JobNames) {
            $this.SharedArea.PowerShellInstances.$job.Dispose()
        }
    }
    AddVariablesToSharedArea([hashtable]$InputVariables) {
        foreach ($var in $InputVariables.Keys) {
            if (-not ($this.SharedArea.Vars.ContainsKey($var))) {
                $this.SharedArea.Vars.Add($var, $InputVariables.$var)
            }
            else {
                $this.SharedArea.Vars.$var = $InputVariables.$var
            }
        }
    }
}