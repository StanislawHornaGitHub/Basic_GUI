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
    static [int] $Big_FormSize_X = 480
    static [int] $Big_FormSize_Y = 150
    static [int] $Small_FormSize_X = 480
    static [int] $Small_FormSize_Y = 125
}
class GUI {
    # Variables
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
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
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
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.width = [GUI_Config]::Small_FormSize_X
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.height = 20
        $this.GUI_Components.'Small_GUI'.'Label'.'Title'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)

        $this.NewLabel([ComponentType]"Small_GUI", "Portal", "Portal FQDN:", 20, 30)

        $this.NewLabel([ComponentType]"Small_GUI", "Login", "Login:", 20, 60)

        $this.NewLabel([ComponentType]"Small_GUI", "Password", "Password:", 20, 90)

        $this.NewLabel([ComponentType]"Big_GUI", "ConnectionStatus", "Connection Status:", 140, 135)

        $this.NewLabel([ComponentType]"Big_GUI", "ConnectionStatusDetails", "Connection StatusDetails", 285, 135)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)

        $this.NewLabel([ComponentType]"Big_GUI", "RunStatus", "Run Status", 150, 170)

        $this.NewCheckBox([ComponentType]"Small_GUI", "ShowPassword", "Show Password", 140, 110, 200, 20, $false, { $THIS_FORM.ShowPassword() })

        ######################################################################
        #------------------------- TextBoxes Section ------------------------#
        ######################################################################

        $this.NewBox([ComponentType]"Small_GUI", "Portal", 140, 30, 300, 20, {$THIS_FORM.PortalChange()})

        $this.NewBox([ComponentType]"Small_GUI", "Login", 140, 60, 300, 20, {$THIS_FORM.LoginChange()})

        $this.NewBox([ComponentType]"Small_GUI", "Password", 140, 90, 300, 20, {$THIS_FORM.PasswordChange()})
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = "*"

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################

        $this.NewButton([ComponentType]"Small_GUI", "Connect", "Connect to Portal", 20, 130, 100, 30, { $THIS_FORM.InvokeConnection() })

        $this.NewButton([ComponentType]"Big_GUI", "Run", "Run", 20, 170, 120, 50, { $THIS_FORM.InvokeRun() })
        $this.GUI_Components.'Big_GUI'.'Button'.'Run'.ForeColor = 'green'
        $this.GUI_Components.'Big_GUI'.'Button'.'Run'.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]::Bold)

        $this.SmallGUI()
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
    SmallGUI() {
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $false
            }
        }
    }
    SmallGUIwithConnectionStatus() {
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $false
            }
        }
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatus'.visible = $true
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = "Not connected "
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'red'
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.visible = $true
    }
    SmallGUIwithConnectionStatus([String]$ErrorMessage) {
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $false
            }
        }
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Small_FormSize_X, [GUI_Config]::Small_FormSize_Y)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatus'.visible = $true
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = $ErrorMessage
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'red'
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.visible = $true
    }
    BigGUI() {
        $this.Form.ClientSize = New-Object System.Drawing.Point([GUI_Config]::Big_FormSize_X, [GUI_Config]::Big_FormSize_Y)
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text = "Connected "
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.ForeColor = 'green'
        $this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.Font = `
            New-Object System.Drawing.Font('Microsoft Sans Serif', 12, [System.Drawing.FontStyle]::Bold)
        foreach ($Object in $this.GUI_Components.'Big_GUI'.Keys) {
            foreach ($Component in $this.GUI_Components.'Big_GUI'.$Object.Keys) {
                $this.GUI_Components.'Big_GUI'.$Object.$Component.Visible = $true
            }
        }
    }
    PortalChange(){
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        $this.SmallGUIwithConnectionStatus()
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.text = ""
        $this.GUI_Components.'Small_GUI'.'Box'.'Login'.text = ""
    }
    LoginChange() {
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        $this.SmallGUIwithConnectionStatus()
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.text = ""
    }
    PasswordChange(){
        if ($this.GUI_Components.'Big_GUI'.'Label'.'ConnectionStatusDetails'.text -notlike "Connected*") {
            return
        }
        $this.SmallGUIwithConnectionStatus()
    }
    ShowPassword() {
        if ($this.GUI_Components.'Small_GUI'.'Checkbox'.'ShowPassword'.checked) {
            $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = $null
        }
        else {
            $this.GUI_Components.'Small_GUI'.'Box'.'Password'.passwordchar = "*"
        }
    }
    InvokeConnection(){
        if($this.GUI_Components.'Small_GUI'.'Box'.'Login'.text.length -lt 1 -or
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.text.length -lt 1){
            return
        }
        $Result = Invoke-Connection -GUI_Components $this.GUI_Components
        if($Result.'Connected'){
            $this.BigGUI()
            $this.Engines = $Result.'Engines'
            $this.Engines
        }else {
            $this.SmallGUIwithConnectionStatus(($Result.'ErrorMessage' + " "))
            $this.Engines = $null
        }
    }
    InvokeRun(){
        if($this.GUI_Components.'Small_GUI'.'Box'.'Login'.text.length -lt 1 -or
        $this.GUI_Components.'Small_GUI'.'Box'.'Password'.text.length -lt 1){
            return
        }
        Invoke-Run -GUI_Components $this.GUI_Components -Engines $this.Engines
    }
}