# [GUI_class.psm1](/Main/GUI_class.psm1)
This is the most complex class in this project, as it is responsible for creating, displaying GUI and all user interactions with the GUI. It also is related to:
 - [GUI_config.psm1](/Docs/GUI_config.md)
 - [GUI_EnvironmentSelection.psm1](/Docs/GUI_EnvironmentSelection.md)
 - [Runspaces_class.psm1](/Docs/Runspace_class.md)

## GUI Logic
Basically GUI Form has 2 modes:
1. [Small_GUI](/Screenshots/Initial_View.png) <- Initial mode after program startup. It is used to prompt the user to provide neccessary data and click Connect button to verify provided information
2. [Big_GUI](/Screenshots/Connected.png) <- Mode which is enabled when [InvokeConnection](/Docs/GUI_config.md) proccess is completed.

## GUI outline
### Variables:
- Environment <- Environment selected in [GUI_EnvironmentalSelection.psm1](/Docs/GUI_EnvironmentSelection.md)
- Servers <- List of destination components also related to [GUI_EnvironmentalSelection.psm1](/Docs/GUI_EnvironmentSelection.md)
- Form  <- Main form object for GUI window
- GUI_Components <- Hashtable with Hierarchy and relations of all GUI components (labels, boxes, buttons) implemented in GUI
- Runspace <- Object of class defined in [Runspace_class.psm1](/Docs/Runspace_class.md)

### Methods:
- GUI <- initial constructor, defines all objects based on the information covered in [GUI_config.psm1](/Docs/GUI_config.md)
- NewLabel($Type, $Name, $Location_X, $Location_Y) <- method to create Label object and add it to the main form.
- NewBox($Type, $Name, $Location_X, $Location_Y, $Size_X, $Size_Y, $TextChange) <- method to create TextBox object and add it to the main form.
- NewCheckBox($Type, $Name, $Location_X, $Location_Y, $Size_X, $Size_Y, $Checked, $AddClick) <- method to create Checkbox object and add it to the main form.
- NewButton($Type, $Name, $Location_X, $Location_Y, $Size_X, $Size_Y, $Action) <- method to create Button object and add it to the main form.
- NewProccessingBar($Type, $Name, $Location_X, $Location_Y, $Size_X, $Size_Y, $Speed) <- method to create ProgressBar object and add it to the main form.
- SmallGUI() <- method invoked on every program start to load [Small_GUI](#gui-logic)
- SmallGUIwithConnectionStatus($ErrorMessage) <- method invoked at the end of [InvokeConnection](/Docs/GUI_config.md) proccess if the process itself was not successfull. It returns if the information to the user provided in the proccess itself
- SmallGUIwithConnectionStatus() <- method witout any variable is invoked on input fields change, to notify the user that the connection was broken
- BigGUI() <- method invoked when [InvokeConnection](/Docs/GUI_config.md) proccess was successfull and the program is ready to perform operations.
- LockInputs() <- method used at the beggining of each Run execution to lock all input fields to avoid modifications
- UnlockInputs() <- method to unlock input fields locked by LockInputs() method
- StarProcessing <- method invoked right after the user click on "RunButton", invokes the LockInputs() and displays the components related to the resource measurement.
- ShowExecutionStatus($Message) <- method invoked at the end of each execution to notify the user if everything was done successfully or there were some issues. **If $Message is "Success", than success will be displayed in bold green font, other statuses will be displayed in bold red font**
- WriteStatus($Status) <- method used to display current execution status to the user. information displayed by this method are bold orange font
- WriteUsage($currentCPU, $currentRAM, $peakCPU, $peakRAM) <- metod to refresh information presented to the user about resource consumption.
- WriteTimer($Time) <- method to refresh run section execution time.
- PortalChange() <- method invoked when the portal box is changed. It breaks the connection and cleans up Login box and the Password box
- LoginChange() <- method invoked when the login box is changed. It breaks the connection and cleans up Password box.
- PasswordChange() <- method invoked when the Password box is changed. It breaks the connection and does not clean up anything
- ShowPassword() <- method invoked, when ["show password"](/Screenshots/Initial_View_Password_Shown.png) checkbox is checked. 
- CheckInputs() <- method invoked to verify if all not locked fields are filled in
- InvokeConnection() <- method invoked when the user clicks invoke button, it invokes CheckInputs() and [InvokeConnection](/Docs/GUI_config.md) proccess
- InvokeRun() <- method invoked when th user clicks on run button, it starts all required processes related to the execution of the main part