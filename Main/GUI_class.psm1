# Put all components Labels boxes etc into hashtable and Next
# Make a hashtable a variable in the class, to be able to prepare different GUIs with one class
#Divide hashtables into 2 types: always visible and advanced
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
enum ComponentType {
    Small_GUI = 0
    Big_GUI = 1
}
class GUI_Config {
    static [string] $ProgramName = "Powershell GUI"
    static [string] $ProgramTitle = "Script for report automation"
    static [string] $RunButton = "Prepare Report"
    static [int] $FormSize_X = 480
    static [int] $FormSize_Y = 150

    
}
class GUI {
    # Variables
    $PortalFQDN
    $Credentials
    $Engines
    # GUI
    $Form
    $GUI_Components = @{
        'Small_GUI' = @{
            'Label'    = @{}
            'Box'      = @{}
            'Checkbox' = @{}
            'Button'   = @{}
        }
        'Big_GUI'   = @{
            'Label'    = @{}
            'Box'      = @{}
            'Checkbox' = @{}
            'Button'   = @{}
        }
    }

    GUI() {
        $THIS_FORM = $this
        ######################################################################
        #----------------------- GUI Forms Definition -----------------------#
        ######################################################################
        $this.Form = New-Object system.Windows.Forms.Form
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::FormSize_X, [GUI_Config]::FormSize_Y)
        $this.Form.text = ([GUI_Config]::ProgramName)
        $this.Form.FormBorderStyle = 'FixedDialog'
        $this.Form.AutoSize = 'DPI'
        $this.Form.TopMost = $true
        # Handling if opened via Powershell ISE
        try {
            $p = (Get-Process powershell | Sort-Object -Property CPU -Descending | Select-Object -First 1).Path
            $this.Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($p)
        }
        catch {
            $p = (Get-Process explorer | Sort-Object -Property CPU -Descending | Select-Object -First 1).Path
            $this.Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($p)
        }

        ######################################################################
        #-------------------------- Labels Section --------------------------#
        ######################################################################
        $this.NewLabel([ComponentType]"Small_GUI", "Title", ([GUI_Config]::ProgramTitle), 0, 5)
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.AutoSize = $false
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.TextAlign = "MiddleCenter"
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.width = [GUI_Config]::FormSize_X
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.height = 20
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
       
        # $this.LabelTitle = New-Object system.Windows.Forms.Label
        # $this.LabelTitle.text = ([GUI_Config]::ProgramTitle)
        # $this.LabelTitle.AutoSize = $false
        # $this.LabelTitle.TextAlign = "MiddleCenter"
        # $this.LabelTitle.width = [GUI_Config]::FormSize_X
        # $this.LabelTitle.height = 20
        # $this.LabelTitle.location = New-Object System.Drawing.Point(0, 5)
        # $this.LabelTitle.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        # $this.Form.Controls.Add($this.LabelTitle)

        $this.NewLabel([ComponentType]"Small_GUI", "Portal", "Portal FQDN:", 20, 30)

        # $this.LabelPortal = New-Object system.Windows.Forms.Label
        # $this.LabelPortal.text = "Portal FQDN: "
        # $this.LabelPortal.AutoSize = $true
        # $this.LabelPortal.width = 25
        # $this.LabelPortal.height = 10
        # $this.LabelPortal.location = New-Object System.Drawing.Point(20, 30)
        # $this.LabelPortal.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        # $this.Form.Controls.Add($this.LabelPortal)

        $this.NewLabel([ComponentType]"Small_GUI", "Login", "Login:", 20, 60)


        # $this.LabelLogin = New-Object system.Windows.Forms.Label
        # $this.LabelLogin.text = "Login:"
        # $this.LabelLogin.AutoSize = $true
        # $this.LabelLogin.width = 25
        # $this.LabelLogin.height = 10
        # $this.LabelLogin.location = New-Object System.Drawing.Point(20, 60)
        # $this.LabelLogin.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        # $this.Form.Controls.Add($this.LabelLogin)

        $this.NewLabel([ComponentType]"Small_GUI", "Password", "Password:", 20, 90)

        # $this.LabelPassword = New-Object system.Windows.Forms.Label
        # $this.LabelPassword.text = "Password:"
        # $this.LabelPassword.AutoSize = $true
        # $this.LabelPassword.width = 25
        # $this.LabelPassword.height = 10
        # $this.LabelPassword.location = New-Object System.Drawing.Point(20, 90)
        # $this.LabelPassword.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        # $this.Form.Controls.Add($this.LabelPassword)

        $this.NewLabel([ComponentType]"Small_GUI", "ConnectionStatus", "Connection Status:", 140, 135)

        # $this.LabelConnectionStatus = New-Object system.Windows.Forms.Label
        # $this.LabelConnectionStatus.text = "Connection Status"
        # $this.LabelConnectionStatus.AutoSize = $true
        # $this.LabelConnectionStatus.width = 25
        # $this.LabelConnectionStatus.height = 10
        # $this.LabelConnectionStatus.location = New-Object System.Drawing.Point(140, 135)
        # $this.LabelConnectionStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
        # $this.LabelConnectionStatus.Visible = $true
        # $this.Form.Controls.Add($this.LabelConnectionStatus)

        $this.NewLabel([ComponentType]"Small_GUI", "ConnectionStatusDetails", "Connection StatusDetails", 260, 135)
        $this.GUI_Components.'Small_GUI'.'Label'.'ConnectionStatusDetails'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)

        # $this.LabelConnectionStatusDetails = New-Object system.Windows.Forms.Label
        # $this.LabelConnectionStatusDetails.text = "Connection"
        # $this.LabelConnectionStatusDetails.AutoSize = $true
        # $this.LabelConnectionStatusDetails.width = 25
        # $this.LabelConnectionStatusDetails.height = 10
        # $this.LabelConnectionStatusDetails.location = New-Object System.Drawing.Point(260, 135)
        # $this.LabelConnectionStatusDetails.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        # $this.LabelConnectionStatusDetails.Visible = $true
        # $this.Form.Controls.Add($this.LabelConnectionStatusDetails)

        $this.NewLabel([ComponentType]"Small_GUI", "RunStatus", "Run Status", 150, 170)

        # $this.LabelRunStatus = New-Object System.Windows.Forms.Label
        # $this.LabelRunStatus.Text = "Run Status"
        # $this.LabelRunStatus.AutoSize = $true
        # $this.LabelRunStatus.TextAlign = "MiddleCenter"
        # $this.LabelRunStatus.MaximumSize = New-Object System.Drawing.Size(435, 60)
        # $this.LabelRunStatus.width = 25
        # $this.LabelRunStatus.height = 10
        # $this.LabelRunStatus.location = New-Object System.Drawing.Point(150, 170)
        # $this.LabelRunStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        # $this.LabelRunStatus.Visible = $true
        # $this.Form.Controls.Add($this.LabelRunStatus)

        $this.NewCheckBox([ComponentType]"Small_GUI", "ShowPassword", "Show Password", 140, 110, 200, 20, $false, { $THIS_FORM.ShowPassword() })

        # $this.CheckboxShowPassword = New-Object System.Windows.Forms.Checkbox 
        # $this.CheckboxShowPassword.Location = New-Object System.Drawing.Size(140, 110) 
        # $this.CheckboxShowPassword.Size = New-Object System.Drawing.Size(200, 20)
        # $this.CheckboxShowPassword.Text = "Show Password"
        # $this.CheckboxShowPassword.Visible = $true
        # $this.CheckboxShowPassword.TabIndex = 4
        # $this.CheckboxShowPassword.checked = $true
        # $this.CheckboxShowPassword.Add_Click( { $THIS_FORM.ShowPassword() } )
        # $this.Form.Controls.Add($this.CheckboxShowPassword)

        ######################################################################
        #------------------------- TextBoxes Section ------------------------#
        ######################################################################

        $this.NewBox([ComponentType]"Small_GUI", "Portal", 140, 30, 300, 20, $null)

        # $this.BoxPortal = New-Object System.Windows.Forms.TextBox 
        # $this.BoxPortal.Multiline = $false
        # $this.BoxPortal.Location = New-Object System.Drawing.Size(140, 30) 
        # $this.BoxPortal.Size = New-Object System.Drawing.Size(300, 20)
        # $this.BoxPortal.Add_TextChanged({  })
        # $this.Form.Controls.Add($this.BoxPortal)

        $this.NewBox([ComponentType]"Small_GUI", "Login", 140, 60, 300, 20, { $THIS_FORM.GUI_Components.'Small_GUI'.'Box'.'Portal'.text = "LALALA" })

        # $this.BoxLogin = New-Object System.Windows.Forms.TextBox 
        # $this.BoxLogin.Multiline = $false
        # $this.BoxLogin.Location = New-Object System.Drawing.Size(140, 60) 
        # $this.BoxLogin.Size = New-Object System.Drawing.Size(300, 20)
        # $this.BoxLogin.Add_TextChanged({  })
        # $this.Form.Controls.Add($this.BoxLogin)

        $this.NewBox([ComponentType]"Small_GUI", "Password", 140, 90, 300, 20, { $THIS_FORM.GUI_Components.'Small_GUI'.'Box'.'Login'.text = "BABABA" })
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = "*"
        # $this.BoxPassword = New-Object System.Windows.Forms.MaskedTextBox 
        # $this.BoxPassword.passwordchar = "*"
        # $this.BoxPassword.Multiline = $false
        # $this.BoxPassword.Location = New-Object System.Drawing.Size(140, 90) 
        # $this.BoxPassword.Size = New-Object System.Drawing.Size(300, 20)
        # $this.Form.Controls.Add($this.BoxPassword)

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################

        $this.NewButton([ComponentType]"Small_GUI","Connect","Connect to Portal",20,130,100,30, {Write-Host "Connect to Portal"})

        # $this.ButtonConnect = New-Object System.Windows.Forms.Button
        # $this.ButtonConnect.Location = New-Object System.Drawing.Point(20, 130)
        # $this.ButtonConnect.Size = New-Object System.Drawing.Size(100, 30)
        # $this.ButtonConnect.Text = 'Connect to portal'
        # $this.ButtonConnect.Add_Click({ Write-Host "Connect Button" })
        # $this.Form.Controls.Add($this.ButtonConnect)

        $this.NewButton([ComponentType]"Small_GUI","Run","Run",20,170,120,50,{ Write-Host "Run Button" })
        $this.GUI_Components.'Small_GUI'.'Button'.'Run'.ForeColor = 'green'
        $this.GUI_Components.'Small_GUI'.'Button'.'Run'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)

        # $this.ButtonRun = New-Object System.Windows.Forms.Button
        # $this.ButtonRun.Location = New-Object System.Drawing.Point(20, 170)
        # $this.ButtonRun.Size = New-Object System.Drawing.Size(120, 50)
        # $this.ButtonRun.Text = 'Run NXQL Query'
        # $this.ButtonRun.Visible = $true
        # $this.ButtonRun.ForeColor = 'green'
        # $this.ButtonRun.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        # $this.ButtonRun.Add_Click({ Write-Host "Run Button" })
        # $this.Form.Controls.Add($this.ButtonRun)
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
            $Label.width = 25
            $Label.height = 10
            $Label.location = New-Object System.Drawing.Point($Location_X, $Location_Y)
            $Label.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
            $this.GUI_Components.$TypeToHash.'Label'.Add($Name, $Label)
            $this.Form.Controls.Add($this.GUI_Components.$TypeToHash.'Label'.$Name)
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

    ShowPassword() {
        if ($this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.checked) {
            $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = $null
        }
        else {
            $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = "*"
        }
    }
}