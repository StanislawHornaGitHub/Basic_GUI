
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
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
    # Main Form
    $Form
    # Labels
    $LabelTitle
    $LabelPortal
    $LabelLogin
    $LabelPassword
    $LabelConnectionStatus
    $LabelConnectionStatusDetails 
    $LabelRunStatus
    $CheckboxShowPassword
    # Boxes
    $BoxPortal
    $BoxLogin
    $BoxPassword
    # Buttons
    $ButtonConnect
    $ButtonRun

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
        $this.LabelTitle = New-Object system.Windows.Forms.Label
        $this.LabelTitle.text = ([GUI_Config]::ProgramTitle)
        $this.LabelTitle.AutoSize = $false
        $this.LabelTitle.TextAlign = "MiddleCenter"
        $this.LabelTitle.width = [GUI_Config]::FormSize_X
        $this.LabelTitle.height = 20
        $this.LabelTitle.location = New-Object System.Drawing.Point(0, 5)
        $this.LabelTitle.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12,  [System.Drawing.FontStyle]::Bold)
        $this.Form.Controls.Add($this.LabelTitle)

        $this.LabelPortal = New-Object system.Windows.Forms.Label
        $this.LabelPortal.text = "Portal FQDN: "
        $this.LabelPortal.AutoSize = $true
        $this.LabelPortal.width = 25
        $this.LabelPortal.height = 10
        $this.LabelPortal.location = New-Object System.Drawing.Point(20, 30)
        $this.LabelPortal.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelPortal)

        $this.LabelLogin = New-Object system.Windows.Forms.Label
        $this.LabelLogin.text = "Login:"
        $this.LabelLogin.AutoSize = $true
        $this.LabelLogin.width = 25
        $this.LabelLogin.height = 10
        $this.LabelLogin.location = New-Object System.Drawing.Point(20, 60)
        $this.LabelLogin.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelLogin)

        $this.LabelPassword = New-Object system.Windows.Forms.Label
        $this.LabelPassword.text = "Password:"
        $this.LabelPassword.AutoSize = $true
        $this.LabelPassword.width = 25
        $this.LabelPassword.height = 10
        $this.LabelPassword.location = New-Object System.Drawing.Point(20, 90)
        $this.LabelPassword.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelPassword)

        $this.LabelConnectionStatus = New-Object system.Windows.Forms.Label
        $this.LabelConnectionStatus.text = "Connection Status"
        $this.LabelConnectionStatus.AutoSize = $true
        $this.LabelConnectionStatus.width = 25
        $this.LabelConnectionStatus.height = 10
        $this.LabelConnectionStatus.location = New-Object System.Drawing.Point(140, 135)
        $this.LabelConnectionStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
        $this.LabelConnectionStatus.Visible = $true
        $this.Form.Controls.Add($this.LabelConnectionStatus)

        $this.LabelConnectionStatusDetails = New-Object system.Windows.Forms.Label
        $this.LabelConnectionStatusDetails.text = "Connection"
        $this.LabelConnectionStatusDetails.AutoSize = $true
        $this.LabelConnectionStatusDetails.width = 25
        $this.LabelConnectionStatusDetails.height = 10
        $this.LabelConnectionStatusDetails.location = New-Object System.Drawing.Point(260, 135)
        $this.LabelConnectionStatusDetails.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.LabelConnectionStatusDetails.Visible = $true
        $this.Form.Controls.Add($this.LabelConnectionStatusDetails)

        $this.LabelRunStatus = New-Object System.Windows.Forms.Label
        $this.LabelRunStatus.Text = "Run Status"
        $this.LabelRunStatus.AutoSize = $true
        $this.LabelRunStatus.TextAlign = "MiddleCenter"
        $this.LabelRunStatus.MaximumSize = New-Object System.Drawing.Size(435, 60)
        $this.LabelRunStatus.width = 25
        $this.LabelRunStatus.height = 10
        $this.LabelRunStatus.location = New-Object System.Drawing.Point(150, 170)
        $this.LabelRunStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.LabelRunStatus.Visible = $true
        $this.Form.Controls.Add($this.LabelRunStatus)

        $this.CheckboxShowPassword = New-Object System.Windows.Forms.Checkbox 
        $this.CheckboxShowPassword.Location = New-Object System.Drawing.Size(140, 110) 
        $this.CheckboxShowPassword.Size = New-Object System.Drawing.Size(200, 20)
        $this.CheckboxShowPassword.Text = "Show Password"
        $this.CheckboxShowPassword.Visible = $true
        $this.CheckboxShowPassword.TabIndex = 4
        $this.CheckboxShowPassword.checked = $true
        $this.CheckboxShowPassword.Add_Click( {$THIS_FORM.ShowPassword()} )
        $this.Form.Controls.Add($this.CheckboxShowPassword)

        ######################################################################
        #------------------------- TextBoxes Section ------------------------#
        ######################################################################

        $this.BoxPortal = New-Object System.Windows.Forms.TextBox 
        $this.BoxPortal.Multiline = $false
        $this.BoxPortal.Location = New-Object System.Drawing.Size(140, 30) 
        $this.BoxPortal.Size = New-Object System.Drawing.Size(300, 20)
        $this.BoxPortal.Add_TextChanged({  })
        $this.Form.Controls.Add($this.BoxPortal)

        $this.BoxLogin = New-Object System.Windows.Forms.TextBox 
        $this.BoxLogin.Multiline = $false
        $this.BoxLogin.Location = New-Object System.Drawing.Size(140, 60) 
        $this.BoxLogin.Size = New-Object System.Drawing.Size(300, 20)
        $this.BoxLogin.Add_TextChanged({  })
        $this.Form.Controls.Add($this.BoxLogin)

        $this.BoxPassword = New-Object System.Windows.Forms.MaskedTextBox 
        $this.BoxPassword.passwordchar = "*"
        $this.BoxPassword.Multiline = $false
        $this.BoxPassword.Location = New-Object System.Drawing.Size(140, 90) 
        $this.BoxPassword.Size = New-Object System.Drawing.Size(300, 20)
        $this.Form.Controls.Add($this.BoxPassword)

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################

        $this.ButtonConnect = New-Object System.Windows.Forms.Button
        $this.ButtonConnect.Location = New-Object System.Drawing.Point(20, 130)
        $this.ButtonConnect.Size = New-Object System.Drawing.Size(100, 30)
        $this.ButtonConnect.Text = 'Connect to portal'
        $this.ButtonConnect.Add_Click({ Write-Host "Connect Button" })
        $this.Form.Controls.Add($this.ButtonConnect)

        $this.ButtonRun = New-Object System.Windows.Forms.Button
        $this.ButtonRun.Location = New-Object System.Drawing.Point(20, 170)
        $this.ButtonRun.Size = New-Object System.Drawing.Size(120, 50)
        $this.ButtonRun.Text = 'Run NXQL Query'
        $this.ButtonRun.Visible = $true
        $this.ButtonRun.ForeColor = 'green'
        $this.ButtonRun.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.ButtonRun.Add_Click({ Write-Host "Run Button" })
        $this.Form.Controls.Add($this.ButtonRun)
        $this.Form.ShowDialog()
    }

    ShowPassword(){
        if ($this.CheckboxShowPassword.checked) {
            $this.BoxPassword.passwordchar = $null
        }
        else {
            $this.BoxPassword.passwordchar = "*"
        }
    }
}