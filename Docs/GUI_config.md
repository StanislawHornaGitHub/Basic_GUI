# [GUI_config.psm1](/Main/GUI_config.psm1)

GUI_config contains a static class with a static methods that are used in the whole project. It also delivers the set of Variables which are crucial to all functions of GUI and hence you can make changes in one place and be sure that it will reflect whole project.
## Config outline
### Variables:
- **ProgramName** <- Name displayed in a title bar of an app
- **ProgramTitle** <- First line displayed in a GUI window (Centered and bolded)
- **RunButton** <- the name of an Button which is displayed after establishing connection
- **InputVariables** <- Hashtable of variables, where you can lock some fileds and set static values. **Changing the property "ComponentType" is not recommended**
- Jobs <- Hashtable of required scriptblocks. **Not recommended to modify**
- **InvokeConnection** <- Scriptblock of cmdlets invoked once the user click on "Connect" button. It is recommended to modify this one according to the requirements of your projects and all informations which needs to be gathered to establish connection and verify credentials.
- **ResultFolder** <- Variable passed to the background job, easily accessed and it should be used, to be able to change the output folder only in GUI_config to redirect all result files to the new location.
- "Logging Variables" <- under this comment there is a set of variables used for separate logs related to the sections of the program. **Changes are not recommended.**

### Methods:
- FolderStructureCheck() <- method invoked on every program start, simply checking if required directories exist, if not it creates them
- CheckRequiredFiles() <- method invoked on every program start, it is veryfying if no components are missing.
- WriteLog($Message, $Logname) <- standarized method to writes log information in compliant format
- GenerateLog($Message) <- method to add to each message timestamp in a given format
- SaveJobErrors() <- a method which is not completed yet, it is meant to gather all errrors related to the execution part itself
- MergeLogs() <- methond invoked on every program close to merge all gathered logs into one archive log file. One for each program run.
- CleanupOldLogs() <- methond invoked on every program close to reduce the number of historical logs available in folder Logs. The number itself can be change in the variables section of [GUI_config.psm1](#gui_configpsm1)
- StartInstance <- method invoked on every program start, it is veryfying if new program instance can be started by check if there is no other instance of the same file, if not then it is invoking **CheckRequiredFiles()** and **FolderStructureCheck()**
- CloseInstance <- methond invoked on every program close to invoke all neccessary actions: **MergeLogs()**, **CleanupOldLogs()** and **Removing the lock** file for the instance
