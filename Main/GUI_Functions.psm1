function Invoke-Connection{
    param(
        [hashtable]$GUI_Components
    )
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    $num = Get-Random -Minimum 0 -Maximum 2
    $ResultHash =@{}
    if($num -eq 1){
        $ResultHash.Add("Connected", $true)
        $engines = @{'engine1' = 'aaaaa'
    'engine2' = 'bbbb'}
        $ResultHash.Add('Engines',$engines)
    }else {
        $ResultHash.Add("Connected", $false)
        $ResultHash.Add("ErrorMessage","Unauthorised access")
    }
    return $ResultHash
}
function Invoke-Run{
    param(
        [hashtable]$GUI_Components,
        [hashtable]$Engines
    )
    $Portal = $GUI_Components.'Small_GUI'.'Box'.'Portal'.text
    $Username = ($GUI_Components.'Small_GUI'.'Box'.'Login'.text)
    $Password = ConvertTo-SecureString ($GUI_Components.'Small_GUI'.'Box'.'Password'.text) -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential  ($Username, $Password)
    Write-Host $Portal
    Write-Host $Credentials
    Write-Host $Engines
    Start-Sleep -Milliseconds 500
    $GUI_Components.'Big_GUI'.'Label'."RunStatus".text = "Processing start..."
    Start-Sleep -Milliseconds 500
    $GUI_Components.'Big_GUI'.'Label'."RunStatus".text = "Teams..."
    Start-Sleep -Milliseconds 500
    $GUI_Components.'Big_GUI'.'Label'."RunStatus".text = "Chrome..."
    Start-Sleep -Milliseconds 500
    $GUI_Components.'Big_GUI'.'Label'."RunStatus".text = "end"
}