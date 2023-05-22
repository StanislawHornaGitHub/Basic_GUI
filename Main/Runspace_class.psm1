class RunSpaceArea {
    $SharedArea = [hashtable]::Synchronized(@{
            'Host'                = $Host
            'RunSpaces'           = @{}
            'PowershellInstances' = @{}
            'Scriptblocks'        = @{}
            'JobStatuses'         = @{}
            'Vars'                = @{}
        })

    RunSpaceArea([hashtable]$Jobs) {
        $ThisSharedArea = $this.SharedArea
        foreach ($job in $Jobs.Keys) {            
            # Create runspace
            $this.SharedArea.RunSpaces.Add($job, ([System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()))
            $this.SharedArea.RunSpaces.$job.ApartmentState = "MTA"
            $this.SharedArea.RunSpaces.$job.ThreadOptions = "UseNewThread"
            $this.SharedArea.RunSpaces.$job.Open()
            $this.SharedArea.RunSpaces.$job.SessionStateProxy.SetVariable('SharedArea', $ThisSharedArea)
        }
        $this.CreatePSinstances($Jobs)
    }
    CreatePSinstances([hashtable]$Jobs) {
        foreach ($job in $Jobs.Keys) {  
            # Create PowerShell instance
            If(-not ($this.SharedArea.PowerShellInstances.ContainsKey($job))){
                $this.SharedArea.PowerShellInstances.Add($job, ([powershell]::Create()))
                $this.SharedArea.PowerShellInstances.$job.runspace = $this.SharedArea.RunSpaces.$job
                $this.SharedArea.PowerShellInstances.$job.AddScript($jobs.$job)
                $this.SharedArea.Scriptblocks.Add($job, $Jobs.$job)
            }else{
                Write-Error -Message "$job already exists"
                return
            }
        }  
    }
    ReConstruct([hashtable]$Jobs){
        $this.DisposeAllJobs()
        $this.SharedArea.JobStatuses = @{}
        $this.SharedArea.vars = @{}
        $this.SharedArea.Scriptblocks = @{}
        $this.CreatePSinstances($Jobs)
    }
    StartAllJobs() {
        $this.StartJob($($this.SharedArea.PowerShellInstances.Keys))
    }
    DisposeAllJobs() {
        $this.DisposeJob($($this.SharedArea.PowerShellInstances.Keys))
    }
    StartJob([array]$JobNames) {
        foreach ($job in $JobNames) {
            if (-not ($this.SharedArea.JobStatuses.ContainsKey($job))) {
                $this.SharedArea.JobStatuses.Add($job, $this.SharedArea.PowerShellInstances.$job.BeginInvoke())
            }else {
                $this.SharedArea.JobStatuses.$job = $this.SharedArea.PowerShellInstances.$job.BeginInvoke()
            }
        }
    }
    DisposeJob([array]$JobNames) {
        foreach ($job in $JobNames) {
            $this.SharedArea.PowerShellInstances.$job.Dispose()
            $this.SharedArea.PowershellInstances.Remove($job)
            $this.SharedArea.JobStatuses.Remove($job)
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
    WaitAnyPSInstance(){
        $flag = $true
        while ($flag) {
            $flag = $false
            foreach($job in $this.SharedArea.JobStatuses.Keys){
                if($this.SharedArea.JobStatuses.$job.IsCompleted -eq $false){
                    $flag = $true
                    break
                }
            }
        }
    }
    WaitPSInstance([String]$JobName){
        while ($this.SharedArea.JobStatuses.$JobName.IsCompleted -eq $false) {
            
        }
    }
}