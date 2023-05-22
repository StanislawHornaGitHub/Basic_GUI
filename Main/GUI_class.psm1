using module './Main/GUI_config.psm1'
using module './Main/GUI_EnvironmentSelection.psm1'
using module './Main/Runspace_class.psm1'
class GUI {
    # Variables
    $Environment
    $Engines
    # GUI
    $Form
    $GUI_Components = @{
        'Small_GUI'   = @{
            'Label'       = @{}
            'Box'         = @{}
            'Checkbox'    = @{}
            'Button'      = @{}
            'ProgressBar' = @{}
        }
        'Big_GUI'     = @{
            'Label'       = @{}
            'Box'         = @{}
            'Checkbox'    = @{}
            'Button'      = @{}
            'ProgressBar' = @{}
        }
        'Manual'      = @{
            'Label'       = @{}
            'Box'         = @{}
            'Checkbox'    = @{}
            'Button'      = @{}
            'ProgressBar' = @{}
        }
        'Measurement' = @{
            'Label'       = @{}
            'Box'         = @{}
            'Checkbox'    = @{}
            'Button'      = @{}
            'ProgressBar' = @{}
        }
    }
    [RunSpaceArea]$Runspaces
    GUI() {
        [GUI_Config]::StartInstance()
        [GUI_Config]::WriteLog("GUI constructor Invoked", ([GUI_Config]::GUI_LogName))
        $THIS_FORM = $this
        ######################################################################
        #----------------------- GUI Forms Definition -----------------------#
        ######################################################################
        $this.Form = New-Object system.Windows.Forms.Form
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
        $this.Form.text = ([GUI_Config]::ProgramName)
        $this.Form.FormBorderStyle = 'FixedDialog'
        $this.Form.AutoSize = 'DPI'
        $this.Form.TopMost = $true
        # Handling if opened via Powershell ISE
        try {
            $imgIcon = New-Object system.drawing.icon (([GUI_Config]::IconPath))
            $this.Form.Icon = $imgIcon
        }
        catch {
            $p = (Get-Process explorer | Sort-Object -Property CPU -Descending | Select-Object -First 1).Path
            $this.Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($p)
        }
        $this.Form.Add_FormClosing({
                $THIS_FORM.Runspaces.DisposeAllJobs()
                [GUI_Config]::WriteLog("Form Close invoked", ([GUI_Config]::GUI_LogName))
                [GUI_Config]::CloseInstance()
            })
        ######################################################################
        #-------------------------- Labels Section --------------------------#
        ######################################################################
        $this.NewLabel([ComponentType]"Small_GUI", "Title", ([GUI_Config]::ProgramTitle), 0, 5)
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.AutoSize = $false
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.TextAlign = "MiddleCenter"
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.width = [GUI_Config]::Small_FormSize_X
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.height = 20
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)

        $this.NewLabel([ComponentType]"Small_GUI", "Portal", "Portal FQDN:", 20, 30)

        $this.NewLabel([ComponentType]"Small_GUI", "Login", "Login:", 20, 60)

        $this.NewLabel([ComponentType]"Small_GUI", "Password", "Password:", 20, 90)


        if ((([GUI_Config]::InputVariables).'Password'.Enabled) -eq $true) {
            $this.NewLabel([ComponentType]"Big_GUI", "ConnectionStatus", "Connection Status:", 140, 135)
        }
        if ((([GUI_Config]::InputVariables).'Password'.Enabled) -eq $true) {
            $this.NewLabel([ComponentType]"Big_GUI", "ConnectionStatusDetails", "Connection StatusDetails", 285, 135)
            $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        }
        $this.NewLabel([ComponentType]"Big_GUI", "RunStatus", "Run Status", 150, 170)
        $this.GUI_Components.'BIG_GUI'.'Label'.'RunStatus'.MaximumSize = New-Object System.Drawing.Size(290, 60)
        $this.GUI_Components.'BIG_GUI'.'Label'.'RunStatus'.AutoEllipsis = $true
        

        $this.NewCheckBox([ComponentType]"Small_GUI", "ShowPassword", "Show Password", 140, 110, 200, 20, $false, { $THIS_FORM.ShowPassword() })

        ######################################################################
        #------------------------ Measurement Section -----------------------#
        ######################################################################
        $this.NewLabel([ComponentType]"Measurement", "Timer", "00:00:00", 500, 5)
        $this.NewLabel([ComponentType]"Measurement", "CurrentTitle", "Current consumption:", 460, 30)
        $this.NewLabel([ComponentType]"Measurement", "PeakTitle", "Peak consumption:", 460, 120)
        $this.NewLabel([ComponentType]"Measurement", "currentCPU", "CPU: - %", 470, 60)
        $this.NewLabel([ComponentType]"Measurement", "peakCPU", "CPU: - %", 470, 150)
        $this.NewLabel([ComponentType]"Measurement", "currentRAM", "RAM: - MB", 470, 90)
        $this.NewLabel([ComponentType]"Measurement", "peakRAM", "RAM: - MB", 470, 180)

        ######################################################################
        #------------------------- TextBoxes Section ------------------------#
        ######################################################################

        $this.NewBox([ComponentType](([GUI_Config]::InputVariables).'Portal'.'ComponentType'), "Portal", 140, 30, 300, 20, { $THIS_FORM.PortalChange() })
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text = (([GUI_Config]::InputVariables).'Portal'.Value)
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.Enabled = (([GUI_Config]::InputVariables).'Portal'.Enabled)

        $this.NewBox([ComponentType](([GUI_Config]::InputVariables).'Login'.'ComponentType'), "Login", 140, 60, 300, 20, { $THIS_FORM.LoginChange() })
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Login'.'ComponentType').'Box'.'Login'.text = (([GUI_Config]::InputVariables).'Login'.Value)
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Login'.'ComponentType').'Box'.'Login'.Enabled = (([GUI_Config]::InputVariables).'Login'.Enabled)

        $this.NewBox([ComponentType](([GUI_Config]::InputVariables).'Password'.'ComponentType'), "Password", 140, 90, 300, 20, { $THIS_FORM.PasswordChange() })
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.passwordchar = "*"
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text = (([GUI_Config]::InputVariables).'Password'.Value)
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.enabled = (([GUI_Config]::InputVariables).'Password'.Enabled)

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################
        if ((([GUI_Config]::InputVariables).'Password'.Enabled) -eq $true) {
            $this.NewButton([ComponentType]"Small_GUI", "Connect", "Connect to Portal", 20, 130, 100, 30, { $THIS_FORM.InvokeConnection() })
        }

        $this.NewButton([ComponentType]"Big_GUI", "Run", [GUI_Config]::RunButton, 20, 170, 120, 50, { $THIS_FORM.InvokeRun() })
        $this.GUI_Components.'Big_GUI'.'Button'.'Run'.ForeColor = 'green'
        $this.GUI_Components.'Big_GUI'.'Button'.'Run'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)

        $this.NewProcessingBar([ComponentType]"Big_GUI", 'Processing', 150, 202, 300, 15, 40)
        
        if ((([GUI_Config]::InputVariables).'Password'.Enabled) -eq $true) {
            $this.SmallGUI()
        }
        else {
            $this.BigGUI()
        }
        $this.Runspaces = [RunSpaceArea]::New([GUI_config]::Jobs)
        $this.Form.ShowDialog()
    }
    NewLabel(
        [ComponentType]$Type,
        [String]$Name,
        [String]$Text,
        [Int]$Location_X,
        [Int]$Location_Y
    ) {
        $TypeToHash = $Type.ToString()
        if (-not ($this.GUI_Components).$TypeToHash.'Label'.ContainsKey($Name)) {
            $Label = New-Object system.Windows.Forms.Label
            $Label.text = $Text
            $Label.AutoSize = $true
            $Label.width = 50
            $Label.height = 10
            $Label.location = New-Object System.Drawing.Point($Location_X, $Location_Y)
            $Label.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
            $this.GUI_Components.$TypeToHash.'Label'.Add($Name, $Label)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'Label'.$Name)
        }
        if ($Type -eq [ComponentType]'Measurement') {
            $this.GUI_Components.$TypeToHash.'Label'.$Name.visible = $false
        }
    }
    NewBox(
        [ComponentType]$Type,
        [String]$Name,
        [Int]$Location_X,
        [Int]$Location_Y,
        [Int]$Size_X,
        [Int]$Size_Y,
        [Scriptblock]$TextChange    
    ) {
        $TypeToHash = $Type.ToString()
        if (-not ($this.GUI_Components).$TypeToHash.'Box'.ContainsKey($Name)) {
            $Box = New-Object System.Windows.Forms.TextBox 
            $Box.Multiline = $false
            $Box.location = New-Object System.Drawing.Point($Location_X, $Location_Y)
            $Box.Size = New-Object System.Drawing.Size($Size_X, $Size_Y)
            $Box.Add_TextChanged($TextChange)
            $this.GUI_Components.$TypeToHash.'Box'.Add($Name, $Box)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'Box'.$Name)
        }
    }
    NewCheckBox(
        [ComponentType]$Type,
        [String]$Name,
        [String]$Text,
        [Int]$Location_X,
        [Int]$Location_Y,
        [Int]$Size_X,
        [Int]$Size_Y,
        [Bool]$Checked,
        [Scriptblock]$AddClick
    ) {
        $TypeToHash = $Type.ToString()
        if (-not ($this.GUI_Components).$TypeToHash.'Checkbox'.ContainsKey($Name)) {
            $Checkbox = New-Object System.Windows.Forms.Checkbox 
            $Checkbox.Location = New-Object System.Drawing.Size($Location_X, $Location_Y) 
            $Checkbox.Size = New-Object System.Drawing.Size($Size_X, $Size_Y)
            $Checkbox.Text = $Text
            $Checkbox.Visible = $true
            $Checkbox.TabIndex = 4
            $Checkbox.checked = $Checked
            $Checkbox.Add_Click( $AddClick )
            $this.GUI_Components.$TypeToHash.'Checkbox'.Add($Name, $Checkbox)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'Checkbox'.$Name)
        }
    }
    NewButton(
        [ComponentType]$Type,
        [String]$Name,
        [String]$Text,
        [Int]$Location_X,
        [Int]$Location_Y,
        [Int]$Size_X,
        [Int]$Size_Y,
        [Scriptblock]$TextChange  
    ) {
        $TypeToHash = $Type.ToString()
        if (-not ($this.GUI_Components).$TypeToHash.'Button'.ContainsKey($Name)) {
            $Button = New-Object System.Windows.Forms.Button
            $Button.Location = New-Object System.Drawing.Point($Location_X, $Location_Y)
            $Button.Size = New-Object System.Drawing.Size($Size_X, $Size_Y)
            $Button.Text = $Text
            $Button.Add_Click($TextChange)
            $this.GUI_Components.$TypeToHash.'Button'.Add($Name, $Button)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'Button'.$Name)
        }
    }
    NewProcessingBar(
        [ComponentType]$Type,
        [String]$Name,
        [Int]$Location_X,
        [Int]$Location_Y,
        [Int]$Size_X,
        [Int]$Size_Y,
        [Int]$Speed
    ) {
        $TypeToHash = $Type.ToString()
        if (-not ($this.GUI_Components).$TypeToHash.'Button'.ContainsKey($Name)) {
            $ProgressBar = New-Object System.Windows.Forms.ProgressBar
            $ProgressBar.Location = New-Object System.Drawing.Point($Location_X, $Location_Y)
            $ProgressBar.Size = New-Object System.Drawing.Size($Size_X, $Size_Y)
            $ProgressBar.Style = "Marquee"
            $ProgressBar.MarqueeAnimationSpeed = $Speed
            $ProgressBar.Visible = $false
            $this.GUI_Components.$TypeToHash.'ProgressBar'.Add($Name, $ProgressBar)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'ProgressBar'.$Name)
        }
    }
    SmallGUI() {
        [GUI_Config]::WriteLog("SmallGUI method", ([GUI_Config]::GUI_LogName))
        $this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.visible = $true
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $false
            }
        }
        foreach ($Component in $this.GUI_Components.'Measurement'.'Label'.Keys) {
            $this.GUI_Components.'Measurement'.'Label'.$Component.Visible = $false
        }
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
        $this.Form.AcceptButton = $this.GUI_Components.'Small_GUI'.'Button'.'Connect'
    }
    SmallGUIwithConnectionStatus() {
        [GUI_Config]::WriteLog("SmallGUIwithConnectionStatus method", ([GUI_Config]::GUI_LogName))
        $this.SmallGUI()
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatus'.visible = $true
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = "Not connected "
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'red'
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.visible = $true
    }
    SmallGUIwithConnectionStatus([String]$ErrorMessage) {
        [GUI_Config]::WriteLog("SmallGUIwithConnectionStatus([String]$ErrorMessage) method", ([GUI_Config]::GUI_LogName))
        $this.SmallGUI()
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatus'.visible = $true
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = $ErrorMessage
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'red'
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.visible = $true
    }
    BigGUI() {
        [GUI_Config]::WriteLog("BigGUI method", ([GUI_Config]::GUI_LogName))
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Big_FormSize_X, [GUI_Config]::Big_FormSize_Y)
        if ((([GUI_Config]::InputVariables).'Password'.Enabled) -eq $true) {
            $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = "Connected "
            $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'green'
            $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
                New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        }
        $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".ForeColor = 'black'
        $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".text = ""
        $this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.checked = $false
        $this.ShowPassword()
        $this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.visible = $false
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                if ($Object -ne "ProgressBar") {
                    $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $true
                }
                
            }
        }
        $this.Form.AcceptButton = $this.GUI_Components.'Big_GUI'.'Button'.'Run'
    }
    LockInputs() {
        [GUI_Config]::WriteLog("LockInputs method", ([GUI_Config]::GUI_LogName))
        $Inputs = @('Box', 'Button', 'Checkbox')
        foreach ($Object in $Inputs) {
            foreach ($Type in $this.GUI_Components.Keys) {
                if ([ComponentType]$Type -lt 0 ) {
                    continue
                }
                foreach ($Component in $this.GUI_Components.$Type.$Object.Keys) {
                    $this.GUI_Components.$Type.$Object.$Component.enabled = $false
                }
            }
        }
    }
    UnlockInputs() {
        [GUI_Config]::WriteLog("UnlockInputs method", ([GUI_Config]::GUI_LogName))
        $Inputs = @('Box', 'Button', 'Checkbox')
        foreach ($Object in $Inputs) {
            foreach ($Type in $this.GUI_Components.Keys) {
                if ([ComponentType]$Type -lt 0 ) {
                    continue
                }
                foreach ($Component in $this.GUI_Components.$Type.$Object.Keys) {
                    $this.GUI_Components.$Type.$Object.$Component.enabled = $true
                }
            }
        }
    }
    StartProcessing() {
        [GUI_Config]::WriteLog("StartProcessing method", ([GUI_Config]::GUI_LogName))
        $this.LockInputs()
        foreach ($Component in $this.GUI_Components.'Measurement'.'Label'.Keys) {
            $this.GUI_Components.'Measurement'.'Label'.$Component.Visible = $true
        }
        $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".text = "Processing"
        $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".ForeColor = 'orange'
        $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.GUI_Components.'Big_GUI'.'ProgressBar'.'Processing'.visible = $true
    }
    ShowExecutionStatus([String]$CurrentMessage) {
        [GUI_Config]::WriteLog("ShowExecutionStatus method", ([GUI_Config]::GUI_LogName))
        $this.GUI_Components.'Big_GUI'.'ProgressBar'.'Processing'.visible = $false
        if ($CurrentMessage -eq "Success") {
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".text = ($CurrentMessage + " ")
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".ForeColor = 'green'
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".Font = `
                New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        }
        else {
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".text = ($CurrentMessage + " ")
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".ForeColor = 'red'
            $this.GUI_Components.'Big_GUI'.'Label'."RunStatus".Font = `
                New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        }
        $this.GUI_Components.'Measurement'.'Label'.'currentCPU'.text = "CPU: - %"
        $this.GUI_Components.'Measurement'.'Label'.'currentRAM'.text = "RAM: - MB"
        [GUI_Config]::WriteLog("RUN execution status: $CurrentMessage", ([GUI_Config]::GUI_LogName))
    }
    WriteStatus([String]$Status) {
        $this.GUI_Components.'Big_GUI'.'Label'.'RunStatus'.text = $Status
    }
    WriteUsage($currentCPU, $currentRAM, $peakCPU, $peakRAM) {
        $this.GUI_Components.'Measurement'.'Label'.'currentCPU'.text = "CPU: $currentCPU %"
        $this.GUI_Components.'Measurement'.'Label'.'currentRAM'.text = "RAM: $currentRAM MB"
        $this.GUI_Components.'Measurement'.'Label'.'peakCPU'.text = "CPU: $peakCPU %"
        $this.GUI_Components.'Measurement'.'Label'.'peakRAM'.text = "RAM: $peakRAM MB"
    }
    WriteTimer($Time) {
        $this.GUI_Components.'Measurement'.'Label'.'Timer'.text = $Time
    }
    PortalChange() {
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        elseif ($this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text -like "https://*") {
            $FQDN = $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text
            $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text = `
                $FQDN.Substring("https://".Length, ($FQDN.Length - ("https://".Length))).Split("/")[0]
            [GUI_Config]::WriteLog("Portal change - Formating invoked", ([GUI_Config]::GUI_LogName))
            return 
        }
        [GUI_Config]::WriteLog("PortalChange method", ([GUI_Config]::GUI_LogName))
        $this.SmallGUIwithConnectionStatus()
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text = ""
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Login'.text = ""
    }
    LoginChange() {
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        [GUI_Config]::GenerateLog("LoginChange method") | Out-File -FilePath "$([GUI_Config]::LogsPath)/$([GUI_Config]::GUI_LogName)" -Append
        $this.SmallGUIwithConnectionStatus()
        $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text = ""
    }
    PasswordChange() {
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        [GUI_Config]::GenerateLog("PasswordChange method") | Out-File -FilePath "$([GUI_Config]::LogsPath)/$([GUI_Config]::GUI_LogName)" -Append
        $this.SmallGUIwithConnectionStatus()
    }
    ShowPassword() {
        [GUI_Config]::GenerateLog("ShowPassword method") | Out-File -FilePath "$([GUI_Config]::LogsPath)/$([GUI_Config]::GUI_LogName)" -Append
        if ($this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.checked) {
            $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.passwordchar = $null
        }
        else {
            $this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.passwordchar = "*"
        }
    }
    [bool]CheckInputs() {
        [GUI_Config]::GenerateLog("CheckInputs method") | Out-File -FilePath "$([GUI_Config]::LogsPath)/$([GUI_Config]::GUI_LogName)" -Append
        
        if ($this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text.length -lt 1 -and
            ([ComponentType](([GUI_Config]::InputVariables).'Portal'.'ComponentType')) -ge 0
        ) {
            return $true
        }
        if ($this.GUI_Components.(([GUI_Config]::InputVariables).'Login'.'ComponentType').'Box'.'Login'.text.length -lt 1 -and
            ([ComponentType](([GUI_Config]::InputVariables).'Login'.'ComponentType')) -ge 0
        ) {
            return $true
        }
        if ($this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text.length -lt 1 -and
            ([ComponentType](([GUI_Config]::InputVariables).'Password'.'ComponentType')) -ge 0
        ) {
            return $true
        }
        return $false
    }
    InvokeConnection() {
        if ($this.CheckInputs()) {
            return
        }
        $Portal = $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text
        [GUI_Config]::WriteLog("InvokeConnection method - $Portal", ([GUI_Config]::GUI_LogName))
        $Username = ($this.GUI_Components.(([GUI_Config]::InputVariables).'Login'.'ComponentType').'Box'.'Login'.text)
        try {
            $Password = ConvertTo-SecureString ($this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text) -AsPlainText -Force
            $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
        }
        catch {
            [GUI_Config]::WriteLog($_, ([GUI_Config]::GUI_LogName))
            $Credentials = $null
        }
        $Result = & $([GUI_Config]::InvokeConnection) -Portal $Portal -Credentials $Credentials
        if ($Result.'Connected' -eq $true) {
            [GUI_Config]::WriteLog("Connect execution status: Connected ; $Portal", ([GUI_Config]::GUI_LogName))
            $this.BigGUI()
            $this.Engines = [GUI_Environment]::GUI_EnvironmentSelection($Result.'Engines', $Portal)
        }
        else {
            [GUI_Config]::WriteLog("Connect execution status: $($Result.'ErrorMessage')", ([GUI_Config]::GUI_LogName))
            $this.SmallGUIwithConnectionStatus(($Result.'ErrorMessage' + " "))
            $this.Engines = $null
        }
    }
    InvokeRun() {
        $Portal = $this.GUI_Components.(([GUI_Config]::InputVariables).'Portal'.'ComponentType').'Box'.'Portal'.text
        [GUI_Config]::WriteLog("InvokeRun method - $Portal", ([GUI_Config]::GUI_LogName))
        if ($this.CheckInputs()) {
            return
        }
        $this.StartProcessing()
        $this.Runspaces.ReConstruct([GUI_config]::Jobs)
        try {
            $Username = ($this.GUI_Components.(([GUI_Config]::InputVariables).'Login'.'ComponentType').'Box'.'Login'.text)
            $Password = ConvertTo-SecureString ($this.GUI_Components.(([GUI_Config]::InputVariables).'Password'.'ComponentType').'Box'.'Password'.text) -AsPlainText -Force
            $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
        }
        catch {
            [GUI_Config]::WriteLog($_.Exception.Message, ([GUI_Config]::GUI_LogName))
            $Credentials = $null
        }
        $InputVariables = @{
            'CurrentLocation'        = $((Get-Location).Path)
            'Timers'                 = @{}
            'Portal'                 = $Portal
            'Credentials'            = $Credentials
            'Engines'                = $this.Engines
            'GUI'                    = $this 
            'LastExecution'          = @{
                'Message' = ""
                'EndTime' = ""
            }
            'ConsumptionMeasurement' = @{
                'currentCPU' = 0
                'currentRAM' = 0
                'peakCPU'    = 0
                'peakRAM'    = 0
                'sumCPU'     = 0
                'sumRAM'     = 0
                'counter'    = 0
            }
            'EnvClass'               = @{
                'LogsPath'                     = ([GUI_Config]::LogsPath)
                'StatusPath'                   = ([GUI_Config]::StatusPath)
                'LogName'                      = ([GUI_Config]::Execution_LogName)
                'ProcessingStatusExtension'    = (([GUI_Config]::ProcessingStatusExtension).Replace("*", ""))
                'FinalStatusExtension'         = (([GUI_Config]::FinalStatusExtension).Replace("*", ""))
                'RecourceConsumption'          = ([GUI_Config]::RecourceConsumption)
                'ExecutionTimersName'          = ([GUI_Config]::ExecutionTimersName)
                'RunRawLogName'                = ([GUI_Config]::RunErrors)
                'ResourceConsumption_Interval' = ([GUI_config]::ResourceConsumption_Interval)
                'ProgramName'                  = ([GUI_config]::ProgramName)
            }
        }
        $this.Runspaces.AddVariablesToSharedArea($InputVariables)
        $this.Runspaces.StartAllJobs()
    }
}