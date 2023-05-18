$Global:x = [Hashtable]::Synchronized(@{})
$x.Host = $Host
$rs = [RunspaceFactory]::CreateRunspace()
$rs.ApartmentState,$rs.ThreadOptions = "STA","ReUseThread"
$rs.Open()
$rs.SessionStateProxy.SetVariable("x",$x)
$cmd = [PowerShell]::Create().AddScript({
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
$x.w = [Windows.Markup.XamlReader]::Parse(@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
MaxWidth="800" WindowStartupLocation="CenterScreen" WindowStyle="None" SizeToContent="WidthAndHeight">
<Button Name="test" Content="Starte Installation"/>
</Window>
"@)
$x.test = $x.w.FindName('test')

$x.test.Add_Click({
    $x.Host.Runspace.Events.GenerateEvent( "TestClicked", $x.test, $null, "test event") 
} )  

$x.w.ShowDialog()
})
$cmd.Runspace = $rs
$handle = $cmd.BeginInvoke()
Register-EngineEvent -SourceIdentifier "TestClicked" -Action {$Global:x.host.UI.Write("Event Happened!")}

class RunSpaceArea {
    $SharedVar = [hashtable]::Synchronized(@{})
    
}