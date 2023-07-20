using module './Main/GUI_config.psm1'
class GUI_Environment {
    static [hashtable] $PortalsToFilter = @{
        'TestTenant' = @{
            'Pool-A' = @('Server-1')
            'Pool-B' = @('Server-2')
            'All'  = @('Server-1', 'Server-2')
        }
    }

    static [System.Object] GUI_EnvironmentSelection($Engines, [string]$PortalFQDN) {
        [GUI_Config]::WriteLog("Environment Selection invoked - $PortalFQDN", ([GUI_Config]::GUI_LogName))
        if (-not (([GUI_Environment]::PortalsToFilter).ContainsKey($PortalFQDN))) {
            [GUI_Config]::WriteLog("Nothing to filter", ([GUI_Config]::GUI_LogName))
            return $Engines
        }
        if (([GUI_config]::PreDefinedEnvironment).ToCharArray().count -gt 1) {
            $Engines = [GUI_Environment]::FilterEngines($Engines, $PortalFQDN, ([GUI_config]::PreDefinedEnvironment))
            return $Engines
        }
        $Global:Selection = ""
        $EnvSelect = New-Object system.Windows.Forms.Form
        $EnvSelect.ClientSize = New-Object System.Drawing.Point(390, 100)
        $EnvSelect.text = ([GUI_Config]::ProgramName)
        $EnvSelect.TopMost = $true
        $EnvSelect.FormBorderStyle = 'FixedDialog'
        $EnvSelect.AutoSize = 'DPI'
        $imgIcon = New-Object system.drawing.icon (([GUI_Config]::IconPath))
        $EnvSelect.Icon = $imgIcon

        ######################################################################
        #-------------------------- Labels Section --------------------------#
        ######################################################################
    
        $LabelQuestion = New-Object system.Windows.Forms.Label
        $LabelQuestion.text = "On which environment do you want to run query?"
        $LabelQuestion.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $LabelQuestion.AutoSize = $true
        $LabelQuestion.width = 370
        $LabelQuestion.height = 10
        $LabelQuestion.location = New-Object System.Drawing.Point(10, 10)
        $LabelQuestion.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
        $EnvSelect.Controls.Add($LabelQuestion)

        ######################################################################
        #------------------------- Buttons Section --------------------------#
        ######################################################################

        $ButtonA = New-Object System.Windows.Forms.Button
        $ButtonA.Location = New-Object System.Drawing.Point(55, 50)
        $ButtonA.Size = New-Object System.Drawing.Size(80, 30)
        $ButtonA.Text = 'Pool-A'
        $ButtonA.Add_Click({
                $EnvSelect.Add_FormClosing({
                        $Global:Selection = "Pool-A" })
                $EnvSelect.Close() })
        $EnvSelect.Controls.Add($ButtonA)

        $ButtonB = New-Object System.Windows.Forms.Button
        $ButtonB.Location = New-Object System.Drawing.Point(150, 50)
        $ButtonB.Size = New-Object System.Drawing.Size(80, 30)
        $ButtonB.Text = 'Pool-B'
        $ButtonB.Add_Click({
                $EnvSelect.Add_FormClosing({
                        $Global:Selection = "Pool-B" })
                $EnvSelect.Close() })
        $EnvSelect.Controls.Add($ButtonB)

        $ButtonAll = New-Object System.Windows.Forms.Button
        $ButtonAll.Location = New-Object System.Drawing.Point(250, 50)
        $ButtonAll.Size = New-Object System.Drawing.Size(80, 30)
        $ButtonAll.Text = 'All'
        $ButtonAll.Add_Click({
                $EnvSelect.Add_FormClosing({
                        $Global:Selection = "All" })
                $EnvSelect.Close() })
        $EnvSelect.Controls.Add($ButtonAll)
        [void]$EnvSelect.ShowDialog()
        $Engines = [GUI_Environment]::FilterEngines($Engines, $PortalFQDN, $Global:Selection)
        return $Engines
    }
    static [System.Object] FilterEngines($Engines, [string]$PortalFQDN, [string]$Environment) {
        [GUI_Config]::WriteLog("Filtering Engines invoked ($PortalFQDN ; $Environment)", ([GUI_Config]::GUI_LogName))
        $Engines = $Engines | Where-Object { $_.name -in $(([GUI_Environment]::PortalsToFilter).$PortalFQDN.$Environment) }
        return $Engines
    }
}