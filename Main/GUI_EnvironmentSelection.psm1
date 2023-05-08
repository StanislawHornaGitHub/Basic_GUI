using module './Main/GUI_config.psm1'
class GUI_Environment {
    static [hashtable] $PortalsToFilter = @{
        'MoJ' = @{
            'FITS' = @('engine-1')
            'MoJo' = @('engine-10')
            'All' = @('engine-1','engine-10')
        }
    }

    static [System.Object] GUI_EnvironmentSelection($Engines, [string]$PortalFQDN) {
        [GUI_Config]::WriteLog("Environment Selection invoked - $PortalFQDN",([GUI_Config]::GUI_LogName))
        if (-not (([GUI_Environment]::PortalsToFilter).ContainsKey($PortalFQDN))) {
            [GUI_Config]::WriteLog("Nothing to filter",([GUI_Config]::GUI_LogName))
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

        $ButtonFITS = New-Object System.Windows.Forms.Button
        $ButtonFITS.Location = New-Object System.Drawing.Point(55, 50)
        $ButtonFITS.Size = New-Object System.Drawing.Size(80, 30)
        $ButtonFITS.Text = 'FITS EUCS'
        $ButtonFITS.Add_Click({
                $EnvSelect.Add_FormClosing({
                        $Global:Selection = "FITS" })
                $EnvSelect.Close() })
        $EnvSelect.Controls.Add($ButtonFITS)

        $ButtonMoJo = New-Object System.Windows.Forms.Button
        $ButtonMoJo.Location = New-Object System.Drawing.Point(150, 50)
        $ButtonMoJo.Size = New-Object System.Drawing.Size(80, 30)
        $ButtonMoJo.Text = 'MoJo'
        $ButtonMoJo.Add_Click({
                $EnvSelect.Add_FormClosing({
                        $Global:Selection = "MoJo" })
                $EnvSelect.Close() })
        $EnvSelect.Controls.Add($ButtonMoJo)

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
    static [hashtable] FilterEngines([hashtable]$Engines, [string]$PortalFQDN, [string]$Environment) {
        [GUI_Config]::WriteLog("Filtering Engines invoked ($PortalFQDN ; $Environment)",([GUI_Config]::GUI_LogName))
        return $Engines
    }
}