### [Powershell GUI](#screenshots)
This is universal Graphical Interface to implement any script written to work with CLI only.
Whole project was designed to be easily adjustable for any script, without a need to change anything related to designing or modifying the GUI itself.

The goal was to build easy to understand environment for the user (GUI) with some powerfull integrated features such like:
-
- Time measurement system that is based on the statuses displayed to the user during the execution
- Resource consumption (CPU & RAM) monitoring during the execution 
- Automated logging capabilities

All above is achieved without the need to apply it in the script itself.
    
    Write-status -Message "string" -Final [switch]
Using this simple function you are able to display infromation for the user and measure the time between statuses change. Resource Consumption and logging are automatically enabled every time on a basic level.

Project also have [.exe file](/Powershell%20GUI.ps1) which is used to run the script, but you do not have to recreate new .exe when you are making changes to the tasks which are meant to be done. 

In most [Main](./Main/) components I tried to use Object Oriented Programming with some limitations related to the Powershell implementation of classes. At the beggining there was no good reason why I chosen such approach, however now I feel that it was a good choice.

### Project components:
- [GUI_config.psm1](./Docs/GUI_config.md)
- [GUI_class.psm1](./Docs/GUI_class.md)
- [GUI_EnfironmentSelection](./Docs/GUI_EnvironmentSelection.md)
- [Runspace_class.psm1](./Docs/Runspace_class.md)
- [GUI_Handling_Functions.psm1](./Docs/GUI_Handling_functions.md)


# Screenshots
<p align="left">
    <img src="/Screenshots/Initial_View.png" width="487" />
    <img src="/Screenshots/Initial_View_Password_Shown.png" width="487" />
    <img src="/Screenshots/Connected.png" width="487" />
    <img src="/Screenshots/Unauthorised_access.png" width="487" align="top"/>
    <img src="/Screenshots/Second_Status.png" width="630" />
    <img src="/Screenshots/Processing_Parallel.png" width="630" />
    <img src="/Screenshots/Execution_Success.png" width="630" />
    <img src="/Screenshots/Execution_Failure.png" width="630" />
</p>
