using module ./Main/GUI_Configuration.psm1
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
class GUI : GUI_Config {
    # Variables
    $InputFolder
    # Main Form
    $Form
    # Labels
    $LabelPortal
    $LabelLogin
    $LabelPassword
    $LabelConnectionStatus
    $LabelConnectionStatusDetails 
    $LabelNumberOfEngines
    $LabelQuery
    $LabelPort
    $LabelFileName
    $LabelPath
    $LabelRunStatus
    $LabelPlatform
    $LabelLookup
    $LabelOptionsAre
    # Checkboxes
    $CheckboxWindows
    $CheckboxMac_OS
    $CheckboxMobile
    $CheckboxShowPassword
    # Boxes
    $BoxPortal
    $BoxLogin
    $BoxPassword
    $BoxQuery
    $BoxFileName
    $BoxPath
    $BoxPort
    $BoxLookfor
    $BoxErrorOptions
    # Buttons
    $ButtonConnect
    $ButtonPath
    $ButtonWebEditor
    $ButtonValidateQuery
    $ButtonRunQuery

    GUI() {
        ######################################################################
        #----------------------- GUI Forms Definition -----------------------#
        ######################################################################
        $this.Form = New-Object system.Windows.Forms.Form
        $this.Form.ClientSize = New-Object System.Drawing.Point(480, 150)
        $this.Form.text = "Powershell NXQL API"
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
        $this.Form.Add_FormClosing({
                Remove-Item -Path $this.UniqueInstanceLock -Confirm:$false -Force
            })

        ######################################################################
        #-------------------------- Labels Section --------------------------#
        ######################################################################

        $this.LabelPortal = New-Object system.Windows.Forms.Label
        $this.LabelPortal.text = "Portal FQDN: "
        $this.LabelPortal.AutoSize = $true
        $this.LabelPortal.width = 25
        $this.LabelPortal.height = 10
        $this.LabelPortal.location = New-Object System.Drawing.Point(20, 0)
        $this.LabelPortal.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelPortal)

        $this.LabelLogin = New-Object system.Windows.Forms.Label
        $this.LabelLogin.text = "Login:"
        $this.LabelLogin.AutoSize = $true
        $this.LabelLogin.width = 25
        $this.LabelLogin.height = 10
        $this.LabelLogin.location = New-Object System.Drawing.Point(20, 30)
        $this.LabelLogin.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelLogin)

        $this.LabelPassword = New-Object system.Windows.Forms.Label
        $this.LabelPassword.text = "Password:"
        $this.LabelPassword.AutoSize = $true
        $this.LabelPassword.width = 25
        $this.LabelPassword.height = 10
        $this.LabelPassword.location = New-Object System.Drawing.Point(20, 60)
        $this.LabelPassword.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelPassword)

        $this.LabelConnectionStatus = New-Object system.Windows.Forms.Label
        $this.LabelConnectionStatus.text = ""
        $this.LabelConnectionStatus.AutoSize = $true
        $this.LabelConnectionStatus.width = 25
        $this.LabelConnectionStatus.height = 10
        $this.LabelConnectionStatus.location = New-Object System.Drawing.Point(150, 105)
        $this.LabelConnectionStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
        $this.LabelConnectionStatus.Visible = $false
        $this.Form.Controls.Add($this.LabelConnectionStatus)

        $this.LabelConnectionStatusDetails = New-Object system.Windows.Forms.Label
        $this.LabelConnectionStatusDetails.text = ""
        $this.LabelConnectionStatusDetails.AutoSize = $true
        $this.LabelConnectionStatusDetails.width = 25
        $this.LabelConnectionStatusDetails.height = 10
        $this.LabelConnectionStatusDetails.location = New-Object System.Drawing.Point(260, 105)
        $this.LabelConnectionStatusDetails.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.LabelConnectionStatusDetails.Visible = $true
        $this.Form.Controls.Add($this.LabelConnectionStatusDetails)

        $this.LabelNumberOfEngines = New-Object system.Windows.Forms.Label
        $this.LabelNumberOfEngines.text = "Number of engines: "
        $this.LabelNumberOfEngines.AutoSize = $true
        $this.LabelNumberOfEngines.width = 25
        $this.LabelNumberOfEngines.height = 10
        $this.LabelNumberOfEngines.location = New-Object System.Drawing.Point(350, 105)
        $this.LabelNumberOfEngines.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
        $this.LabelNumberOfEngines.Visible = $false
        $this.Form.Controls.Add($this.LabelNumberOfEngines)

        $this.LabelQuery = New-Object system.Windows.Forms.Label
        $this.LabelQuery.text = "NXQL query:"
        $this.LabelQuery.AutoSize = $true
        $this.LabelQuery.width = 25
        $this.LabelQuery.height = 10
        $this.LabelQuery.location = New-Object System.Drawing.Point(20, 140)
        $this.LabelQuery.Visible = $false
        $this.LabelQuery.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelQuery)

        $this.LabelPort = New-Object system.Windows.Forms.Label
        $this.LabelPort.text = "NXQL port:"
        $this.LabelPort.AutoSize = $true
        $this.LabelPort.width = 25
        $this.LabelPort.height = 10
        $this.LabelPort.location = New-Object System.Drawing.Point(550, 140)
        $this.LabelPort.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.LabelPort.Visible = $false
        $this.Form.Controls.Add($this.LabelPort)

        $this.LabelFileName = New-Object System.Windows.Forms.Label
        $this.LabelFileName.Text = "Destination File Name"
        $this.LabelFileName.AutoSize = $true
        $this.LabelFileName.width = 25
        $this.LabelFileName.height = 10
        $this.LabelFileName.location = New-Object System.Drawing.Point(20, 480)
        $this.LabelFileName.Visible = $false
        $this.LabelFileName.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelFileName)

        $this.LabelPath = New-Object System.Windows.Forms.Label
        $this.LabelPath.Text = "Destination Path"
        $this.LabelPath.AutoSize = $true
        $this.LabelPath.width = 25
        $this.LabelPath.height = 10
        $this.LabelPath.location = New-Object System.Drawing.Point(20, 510)
        $this.LabelPath.Visible = $false
        $this.LabelPath.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.Form.Controls.Add($this.LabelPath)

        $this.LabelRunStatus = New-Object System.Windows.Forms.Label
        $this.LabelRunStatus.Text = ""
        $this.LabelRunStatus.AutoSize = $true
        $this.LabelRunStatus.TextAlign = "MiddleCenter"
        $this.LabelRunStatus.MaximumSize = New-Object System.Drawing.Size(435, 60)
        $this.LabelRunStatus.width = 25
        $this.LabelRunStatus.height = 10
        $this.LabelRunStatus.location = New-Object System.Drawing.Point(150, 540)
        $this.LabelRunStatus.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.LabelRunStatus.Visible = $false
        $this.Form.Controls.Add($this.LabelRunStatus)

        $this.LabelPlatform = New-Object System.Windows.Forms.Label
        $this.LabelPlatform.Text = "Select Platform:"
        $this.LabelPlatform.AutoSize = $true
        $this.LabelPlatform.width = 25
        $this.LabelPlatform.height = 10
        $this.LabelPlatform.location = New-Object System.Drawing.Point(550, 0)
        $this.LabelPlatform.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.LabelPlatform.Visible = $false
        $this.Form.Controls.Add($this.LabelPlatform)

        $this.LabelLookup = New-Object System.Windows.Forms.Label
        $this.LabelLookup.Text = "Look for:"
        $this.LabelLookup.AutoSize = $true
        $this.LabelLookup.width = 25
        $this.LabelLookup.height = 10
        $this.LabelLookup.location = New-Object System.Drawing.Point(695, 0)
        $this.LabelLookup.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.LabelLookup.Visible = $false
        $this.Form.Controls.Add($this.LabelLookup)

        $this.LabelOptionsAre = New-Object System.Windows.Forms.Label
        $this.LabelOptionsAre.Text = "Options are:"
        $this.LabelOptionsAre.AutoSize = $true
        $this.LabelOptionsAre.width = 25
        $this.LabelOptionsAre.height = 10
        $this.LabelOptionsAre.location = New-Object System.Drawing.Point(695, 35)
        $this.LabelOptionsAre.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $this.LabelOptionsAre.Visible = $false
        $this.Form.Controls.Add($this.LabelOptionsAre)

        ######################################################################
        #------------------------ Checkboxes Section ------------------------#
        ######################################################################

        # $this.CheckboxWindows = New-Object System.Windows.Forms.Checkbox 
        # $this.CheckboxWindows.Location = New-Object System.Drawing.Size(555, 25) 
        # $this.CheckboxWindows.Size = New-Object System.Drawing.Size(100, 20)
        # $this.CheckboxWindows.Text = "Windows"
        # $this.CheckboxWindows.checked = $true
        # $this.CheckboxWindows.Visible = $false
        # $this.CheckboxWindows.TabIndex = 4
        # $this.CheckboxWindows.Add_Click({ Invoke-CheckboxPlatform })
        # $this.Form.Controls.Add($this.CheckboxWindows)

        $this.CheckboxMac_OS = New-Object System.Windows.Forms.Checkbox 
        $this.CheckboxMac_OS.Location = New-Object System.Drawing.Size(555, 45) 
        $this.CheckboxMac_OS.Size = New-Object System.Drawing.Size(100, 20)
        $this.CheckboxMac_OS.Text = "Mac OS"
        $this.CheckboxMac_OS.Visible = $false
        $this.CheckboxMac_OS.TabIndex = 4
        $this.CheckboxMac_OS.Add_Click({ Invoke-CheckboxPlatform })
        $this.Form.Controls.Add($this.CheckboxMac_OS)

        $this.CheckboxMobile = New-Object System.Windows.Forms.Checkbox 
        $this.CheckboxMobile.Location = New-Object System.Drawing.Size(555, 65) 
        $this.CheckboxMobile.Size = New-Object System.Drawing.Size(100, 20)
        $this.CheckboxMobile.Text = "Mobile"
        $this.CheckboxMobile.Visible = $false
        $this.CheckboxMobile.TabIndex = 4
        $this.CheckboxMobile.Add_Click({ Invoke-CheckboxPlatform })
        $this.Form.Controls.Add($this.CheckboxMobile)

        $this.CheckboxShowPassword = New-Object System.Windows.Forms.Checkbox 
        $this.CheckboxShowPassword.Location = New-Object System.Drawing.Size(140, 80) 
        $this.CheckboxShowPassword.Size = New-Object System.Drawing.Size(200, 20)
        $this.CheckboxShowPassword.Text = "Show Password"
        $this.CheckboxShowPassword.Visible = $true
        $this.CheckboxShowPassword.TabIndex = 4
        $this.CheckboxShowPassword.checked = $false
        $this.CheckboxShowPassword.Add_Click({ Invoke-CheckboxShowPassword })
        $this.Form.Controls.Add($this.CheckboxShowPassword)

        ######################################################################
        #------------------------- TextBoxes Section ------------------------#
        ######################################################################

        $this.BoxPortal = New-Object System.Windows.Forms.TextBox 
        $this.BoxPortal.Multiline = $false
        $this.BoxPortal.Location = New-Object System.Drawing.Size(140, 0) 
        $this.BoxPortal.Size = New-Object System.Drawing.Size(300, 20)
        $this.BoxPortal.Add_TextChanged({ Invoke-BoxPortal })
        $this.Form.Controls.Add($this.BoxPortal)

        $this.BoxLogin = New-Object System.Windows.Forms.TextBox 
        $this.BoxLogin.Multiline = $false
        $this.BoxLogin.Location = New-Object System.Drawing.Size(140, 30) 
        $this.BoxLogin.Size = New-Object System.Drawing.Size(300, 20)
        $this.BoxLogin.Add_TextChanged({ Invoke-CredentialCleanup })
        $this.Form.Controls.Add($this.BoxLogin)

        $this.BoxPassword = New-Object System.Windows.Forms.MaskedTextBox 
        $this.BoxPassword.passwordchar = "*"
        $this.BoxPassword.Multiline = $false
        $this.BoxPassword.Location = New-Object System.Drawing.Size(140, 60) 
        $this.BoxPassword.Size = New-Object System.Drawing.Size(300, 20)
        $this.Form.Controls.Add($this.BoxPassword)

        $this.BoxQuery = New-Object System.Windows.Forms.TextBox 
        $this.BoxQuery.Multiline = $true
        $this.BoxQuery.Location = New-Object System.Drawing.Size(20, 165) 
        $this.BoxQuery.Size = New-Object System.Drawing.Size(660, 300)
        $this.BoxQuery.Scrollbars = 'Vertical'
        $this.BoxQuery.Visible = $false
        $this.BoxQuery.Add_TextChanged({ Invoke-BoxQuery })
        $this.Form.Controls.Add($this.BoxQuery)

        $this.BoxFileName = New-Object System.Windows.Forms.TextBox 
        $this.BoxFileName.Multiline = $false
        $this.BoxFileName.Location = New-Object System.Drawing.Size(190, 480) 
        $this.BoxFileName.Size = New-Object System.Drawing.Size(495, 20)
        $this.BoxFileName.Text = (Get-Date).ToString("yyyy-MM-dd")
        $this.BoxFileName.Visible = $false
        $this.Form.Controls.Add($this.BoxFileName)

        $this.BoxPath = New-Object System.Windows.Forms.TextBox 
        $this.BoxPath.Multiline = $false
        $this.BoxPath.Location = New-Object System.Drawing.Size(150, 510) 
        $this.BoxPath.Size = New-Object System.Drawing.Size(430, 20)
        $this.BoxPath.Text = Get-BoxPathLocation
        $this.BoxPath.Visible = $false
        $this.Form.Controls.Add($this.BoxPath)

        $this.BoxPort = New-Object System.Windows.Forms.TextBox 
        $this.BoxPort.Multiline = $false
        $this.BoxPort.Location = New-Object System.Drawing.Size(640, 140) 
        $this.BoxPort.Size = New-Object System.Drawing.Size(40, 20)
        $this.BoxPort.Text = ""
        $this.BoxPort.Visible = $false
        $this.Form.Controls.Add($this.BoxPort)

        $this.BoxLookfor = New-Object System.Windows.Forms.TextBox 
        $this.BoxLookfor.Text = ""
        $this.BoxLookfor.AutoSize = $true
        $this.BoxLookfor.width = 25
        $this.BoxLookfor.height = 10
        $this.BoxLookfor.location = New-Object System.Drawing.Point(765, 0)
        $this.BoxLookfor.Size = New-Object System.Drawing.Size(315, 20)
        $this.BoxLookfor.Visible = $false
        $this.BoxLookfor.Add_TextChanged({ Invoke-BoxLookFor })
        $this.Form.Controls.Add($this.BoxLookfor)

        $this.BoxErrorOptions = New-Object System.Windows.Forms.TextBox 
        $this.BoxErrorOptions.Text = ""
        $this.BoxErrorOptions.AutoSize = $true
        $this.BoxErrorOptions.Multiline = $true
        $this.BoxErrorOptions.Scrollbars = 'Vertical'
        $this.BoxErrorOptions.ReadOnly = $true
        $this.BoxErrorOptions.width = 25
        $this.BoxErrorOptions.height = 10
        $this.BoxErrorOptions.location = New-Object System.Drawing.Point(700, 60)
        $this.BoxErrorOptions.Size = New-Object System.Drawing.Size(380, 525)
        $this.BoxErrorOptions.Visible = $false
        $this.Form.Controls.Add($this.BoxErrorOptions)

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################

        $this.ButtonConnect = New-Object System.Windows.Forms.Button
        $this.ButtonConnect.Location = New-Object System.Drawing.Point(20, 100)
        $this.ButtonConnect.Size = New-Object System.Drawing.Size(100, 30)
        $this.ButtonConnect.Text = 'Connect to portal'
        $this.ButtonConnect.Add_Click({ Invoke-ButtonConnectToPortal })
        $this.Form.Controls.Add($this.ButtonConnect)

        $this.ButtonPath = New-Object System.Windows.Forms.Button
        $this.ButtonPath.Location = New-Object System.Drawing.Point(585, 505)
        $this.ButtonPath.Size = New-Object System.Drawing.Size(100, 30)
        $this.ButtonPath.Text = 'Select'
        $this.ButtonPath.Visible = $false
        $this.ButtonPath.Add_Click({ $this.BoxPath.Text = Invoke-ButtonSelectPath -inputFolder $this.BoxPath.Text })
        $this.Form.Controls.Add($this.ButtonPath)

        $this.ButtonWebEditor = New-Object System.Windows.Forms.Button
        $this.ButtonWebEditor.Location = New-Object System.Drawing.Point(585, 540)
        $this.ButtonWebEditor.Size = New-Object System.Drawing.Size(100, 50)
        $this.ButtonWebEditor.Visible = $false
        $this.ButtonWebEditor.Text = 'Open Web Query Editor'
        $this.ButtonWebEditor.Add_Click({ Invoke-ButtonQueryWebEditor })
        $this.Form.Controls.Add($this.ButtonWebEditor)

        $this.ButtonValidateQuery = New-Object System.Windows.Forms.Button
        $this.ButtonValidateQuery.Location = New-Object System.Drawing.Point(20, 540)
        $this.ButtonValidateQuery.Size = New-Object System.Drawing.Size(120, 50)
        $this.ButtonValidateQuery.Text = 'Validate Query'
        $this.ButtonValidateQuery.Visible = $false
        $this.ButtonValidateQuery.ForeColor = 'orange'
        $this.ButtonValidateQuery.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.ButtonValidateQuery.Add_Click({ Invoke-ButtonValidateQuery })
        $this.Form.Controls.Add($this.ButtonValidateQuery)

        $this.ButtonRunQuery = New-Object System.Windows.Forms.Button
        $this.ButtonRunQuery.Location = New-Object System.Drawing.Point(20, 540)
        $this.ButtonRunQuery.Size = New-Object System.Drawing.Size(120, 50)
        $this.ButtonRunQuery.Text = 'Run NXQL Query'
        $this.ButtonRunQuery.Visible = $false
        $this.ButtonRunQuery.ForeColor = 'green'
        $this.ButtonRunQuery.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)
        $this.ButtonRunQuery.Add_Click({ Invoke-ButtonRunNXQLQuery })
        $this.Form.Controls.Add($this.ButtonRunQuery)
    }
}