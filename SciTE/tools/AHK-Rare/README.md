![AHK - Rare Logo](assets/AHK-Rare-Logo.png)

------

**AHK-Rare** - *collection of rare or very useful single functions* 

This is a collection of functions I found at Autohotkey-Forum or inside Autohotkey Scripts. Sometimes you will find one of it an official Autohotkey-Library. Approximately 90-95% of the functions can not be found in any of the [2600 libraries](https://github.com/Ixiko/AHK-libs-and-classes-collection) that I have also put together here at Github.

Some of the collected function seems to be multiple in this collection, because they sometimes use very different methods. This is a crucial difference. You dont wan’t find “THE ONLY ONE” good function here. Take what is the better! 

----

## AHK-Rare GUI ++ SEARCH COMFORTABLE ++![New Gui](assets/AHK-Rare-TheGui_Screenshot.png)

----

## ![Gem](assets/GemSmall.png)[November 24, 2019]: + 7 =  667

**<u>AHK-Rare GUI (V0.80):</u>** 

- bumpy correction of the GUI display for display on 2k monitors

| **NR** | **FUNCTION**                 | **DESCRIPTION**                                              |
| ------ | ---------------------------- | ------------------------------------------------------------ |
| 01     | **ProcessPriority()**        | Useful inside a library function to save/set/reset script’s Process priority |
| 02     | **PIDfromAnyID()**           | get PID from any ID                                          |
| 03     | **StdErr_Write()**           | write directly to stderr for custom error messages           |
| 04     | **ObjGetNumOfKeys()**        | gets the current number of key-value pairs stored in the passed AHK ‘basic object’ |
| 05     | **RGBEuclidianDistance()**   | find the distance between 2 colors                           |
| 06     | **LV_EX_SetTileViewLines()** | sets the maximum number of additional text lines in each tile, not counting the title |
| 07     | **HideFocusBorder()**        | Hide the dotted focus border                                 |



## ![Gem](assets/GemSmall.png)[September 21, 2019]:

**<u>AHK-Rare GUI (V0.79):</u>** 

- Fixed a problem with screen resolution. Now the gui detects if the script it's running on 2k or 4k Monitor (only if it's the primary monitor). It is taken care that the Gui is created within the visible range of the monitor. 
- The AHK-Rare logo has a width of 660 pixels. This looks good on a 4k monitor. For 2k monitors, the image is scaled to half the size.
- AHK-Rare.ahk was renamed AHK-Rare.txt because it caused too much confusion.
- added a statusbar to the gui, because the GUI looks strange under Win 10. The status bar then shows if the clipboard is empty, contains anything other than a function from AHK-Rare, or if there is an AHK-Rare function that can be inserted into an editor.
- What should work then, of course, is the copy function. And this works again now.



## ![Gem](assets/GemSmall.png)[September 14, 2019]: + 14 =  660

**<u>AHK-Rare GUI:</u>** Fixed many issue’s in the parsing algorithm. Small changes to gui layout. The ***EXAMPLE(s)*** and ***DESCRIPTION*** tabs will be highlighted if they have content. Basic search is working. The output in the ***DESCRIPTION*** tab is clearer now. Unfortunately, I still have not got any differently colored description keys.

| **Nr** | FUNCTION                  | DESCRIPTION                                                  |
| :----: | ------------------------- | ------------------------------------------------------------ |
|   01   | **LVM_GetItemText()**     | gets the text of a ListView item or subitem *(newer function for all AHK versions including 64bit - from jballi)* |
|   02   | **NumStr()**              | Use NumStr() to format a float or to pad leading characters (any character!) to a numeric string<br>     Number=21.3263<br>     NumStr(Number,10,2,"_") returns "_____21.33"<br>     NumStr(Number,10,0,"0") returns "0000000021"<br>     NumStr(Number,10,2) returns "21.33" |
|   03   | **SetWidth()**            | increases a string’s length by adding spaces to it and aligns it Left/Center/Right |
|   04   | **Replicate()**           | replicates one char x-times                                  |
|   05   | **Space()**               | generates a string containing only spaces                    |
|   06   | **GetPriority()**         | ascertains the priority level for an existing process        |
|   07   | **ProcessCreationTime()** | ascertains the creation time for an existing process and returns a time string |
|   08   | **ProcessOwner()**        | returns the Owner for a given Process ID                     |
|   09   | **ColorAdjL()**           | adjust luminance for a given RGB color                       |
|   10   | **Filexpro()**            | retreaves file extended properties Object                    |
|   11   | **SoundExC()**            | phonetic algorithm for indexing names by sound               |
|   12   | **PixelCheckSum()**       | Generates a CheckSum for a region of pixels in Screen/Window |
|   13   | **Control_GetFont()**     | Given an handle to a GuiControl, Control_GetFont() will return the Fontname & Fontsize |
|   14   | **GetElementByName()**    | search for one element by name                               |



## ![Gem](assets/GemSmall.png)[August 28, 2019]: + 13 =  646

**<u>AHK-Rare GUI:</u>** There are only a few new functions this time, as I have created a script (alpha release) for a more comfortable presentation of the function collection (AHK-Rare_TheGui.ahk). The gui is divided into 2 areas. In the upper area, all functions are displayed for selection. In the lower area you will find more information after selecting a function. With a right click on the displayed code or the detailed description, the function will be copied to the clipboard.

| **Nr** | FUNCTION                         | DESCRIPTION                                                  |
| :----: | -------------------------------- | ------------------------------------------------------------ |
|   01   | **GetClassNN()**                 | missing subfunction of FindChildWindow                       |
|   02   | **GetClassNN_EnumChildProc()**   | missing subfunction of FindChildWindow                       |
|   03   | **ScaleToFit()**                 | returns the dimensions of the scaled source rectangle that fits within the destination rectangle |
|   04   | **gcd()**                        | MCode GCD - Find the greatest common divisor (GCD) of two numbers |
|   05   | **LVM_CalculateSize()**          | calculate the width and height required to display a given number of rows of a ListView control |
|   06   | **LV_RemoveSelBorder()**         | to remove the listview’s selection border                    |
|   07   | **LockCursorToPrimaryMonitor()** | prevents the cursor from leaving the primary monitor         |
|   08   | **DisableFadeEffect()**          | Disabling fade effect on gui animations                      |
|   09   | **RestartNetwork()**             | Restart “Local area connection” without admin privileges     |
|   10   | **PrintStr()**                   | Prints the passed string on the default printer              |
|   11   | **GetAllResponseHeaders()**      | Returns a string that contains all response headers          |
|   12   | **GetCaretPos()**                | Alternative to A_CaretX & A_CaretY (maybe not better)        |
|   13   | **GetFontNamesFromFile()**       | get’s the name of a font from a .ttf-FontFile                |



## ![Gem](assets/GemSmall.png) [July 01, 2019]: +19 =  633

| Nr                | **FUNCTION**                  | **DESCRIPTION**                                              |
| :---------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| 01 | **GetProcessMemoryInfo()**	| get informations about memory consumption of a process |
| 02 | **SetTimerEx()**                   	| Similar to SetTimer, but calls a function, optionally with one or more parameters |
| 03 | **get_png_image_info()**     	| Getting PNG image info |
| 04 | **RapidHotkey()**                 	| Using this function you can send keystrokes or launch a Label by pressing a key several times. |
| 05 | **hk()** | Disable all keyboard buttons |
| 06 | **ScriptExist()** | true oder false if script is running or not |
| 07 | **GetStartupWindowState()** | to check, if script exe was launched by windows’s shortcut with MAXIMIZE |
| 08 | **SetTextAndResize()** | resizes a control to adapt to updated values |
| 09 | **HWNDToClassNN()** | a different approach to get classNN from handle |
| 10 | **GetBitmapFromAnything()** | Supports paths, icon handles and hBitmaps |
| 11 | **LV_HeaderFontSet()** | sets font for listview headers |
| 12 | **UpdateScrollBars()** | immediate update of the window content when using a scrollbar |
| 13 | **SelectFolder()** | the Common File Dialog lets you add controls to it |
| 14 | **IsCheckboxStyle()** | checks style(code) if it’s a checkbox |
| 15 | **DropShadow()** | Drop Shadow On Borderless Window, (DWM STYLE) |
| 16 | **GetGuiClassStyle()** | returns the class style of a Autohotkey-Gui |
| 17 | **SetGuiClassStyle()** | sets the class style of a Autohotkey-Gui |
| 18 | **RandomString()** | builds a string with random char of specified length |
| 19 | **LV_SetSI()** | set icon for row “subItem” within Listview |



## ![Gem](assets/GemSmall.png) [February 16, 2019]: +37 =  614

| **FUNCTION**                  | **DESCRIPTION**                                              |
| :---------------------------- | :----------------------------------------------------------- |
| **ExtratIcon()**              | extract icon from a resource file                            |
| **GetIconSize()**             | determines the size of the icon (Lexikos function)           |
| **Gdip_GetHICONDimensions()** | get icon dimensions                                          |
| **FoxitInvoke()**             | wm_command wrapper for FoxitReader Version:  9.1             |
| **WinSaveCheckboxes()**       | save the status of checkboxes in other apps                  |
| **GetButtonType()**           | uses the style of a button to get it’s name                  |
| **KeyValueObjectFromLists()** | merge two lists into one key-value object, useful for 2 two lists you retreave from WinGet |
| **List2Array()**              | function uses StrSplit () to return an array                 |
| **CRC32()**                   | CRC32 function, uses MCode                                   |
| **MeasureText()**             | Measures the single-line width and height of the passed text |
| **Gdip_BitmapReplaceColor()** | using Mcode to replace a color with a specific variation     |
| **Gdi_ExtFloodFill()**        | fills an area with the current brush                         |
| **Gdip_AlphaMask32v1()**      | 32bit Gdip-AlphaMask with MCode - one of two builds          |
| **Gdip_AlphaMask32v2()**      | 32bit Gdip-AlphaMask with MCode  - second of two builds      |
| **Gdip_AlphaMask64()**        | 64bit Gdip-AlphaMask with MCode                              |
| **CircleCrop()**              | gdip circlecrop with MCode                                   |
| **ExploreObj()**              | renewed function to print contents of an object              |
| **PIDfromAnyID()**            | for easy retreaving of process ID’s (PID)                    |
| **sortArray()**               | well working function (*with example*)                       |
| **GetCallStack()**            | retrieves the current callstack                              |
| **Traceback()**               | get stack trace                                              |
| **WrapText()**                | basic function to wrap a text to a given width (length)      |
| **processPriority()**         | retrieves the priority of a process via PID                  |
| **Array_Gui()**               | shows your array as an interactive TreeView                  |
| **MoveMouse_Spiral()**        | move mouse in a spiral                                       |
| **TV_GetItemText()**          | retrieves the text/name of the specified treeview node       |
| **WinEnum()**                 | wrapper for Enum(Child)Windows from cocobelgica. a different solution to that one I collected before |
| **SetHoverText()**            | change control’s text on mouseover                           |
| **Menu_Show()**               | its an alternative to Menu, Show, which can display menu without blocking monitored messages |
| **CreateMenu()**              | creates menu from a string in which each item is placed in new line and hierarchy is defined by Tab character on the left (indentation) |
| **CreateDDMenu()**            | Creates dropdown menu from a string in which each item is placed in new line and hierarchy is defined by Tab character on the left (indentation) |
| **FormatByteSize()**          | give’s back the given bytes in KB, MB, GB …. (for AHK_V1 and a second function for AHK_V2) |
| **PathCombine()**             | combine the 2 routes provided in a single absolute path      |
| **GetParentDir()**            | small RegEx function to get parent dir from a given string   |
| **DirGetParent()**            | returns a string containing parent dir, it’s possible to set the level of parent dir |
| **WinWaitProgress()**         | Waits for the progress bar on a window to reach (>=) a given value (a Lexikos function) |



## ![Gem](assets/GemSmall.png)[December 15, 2018]: +22 = 577

optimized layout, began to assign a number for functions identification, Split topics to find functions faster, each function will get the following description* over time:

```Autohotkey
/*    	DESCRIPTION of function 
    	----------------------------------------------------------------------------
		Description  	:	
		Link           	:	
		Author         	:	
		Date           	:	
		AHK-Version 	:	
		License        	:	
		Parameter(s)	:
		Return value	:
		Remark(s)    	:	
		Dependencies	:	
		KeyWords    	:	
    	----------------------------------------------------------------------------
*/
```

**in preparation for a comfortable search and editing program*.



- **Ansi2Oem()** - using Ansi2Unicode and Unicode2Ansi functions
- **Oem2Ansi()** - using Ansi2Unicode and Unicode2Ansi functions
- **Ansi2UTF8()** - using Ansi2Unicode and Unicode2Ansi functions
- **UTF82Ansi()** - using Ansi2Unicode and Unicode2Ansi functions
- **FindChildWindow()** - ***new version!*** - If there was no title or text for the childwindow, the returned value was empty, so this function can handle now a new search parameter  -Class or ClassNN-
- **StdoutToVar_CreateProcess()** - Runs a command line program and returns its output
- **DNSQuery()** - retrieve IP adresses or host/domain names from DNS
- **CreateDIB()** - a wonderfull function by SKAN to draw tiled backgrounds (like chess pattern) to a gui, it can also draw gradients
- **GuiControlLoadImage()** - scale down a picture to fit the given width and height of a picture control
- **Gdip_ResizeBitmap()** - returns resized bitmap
- **Gdip_CropBitmap()** - returns cropped bitmap. Specify how many pixels you want to crop (omit) from each side of bitmap rectangle
- **FontClone()** - backup hFont in memory for further processing
- **GuiDefaultFont()** - returns the default Fontname & Fontsize
- **DateDiff()** - returns the difference between two timestamps in the specified units
- **ObjectNameChange()** - titlebar hook to detect when title changes, (Lexikos’ code)
- **StrGetDimAvgCharWidth()** - average width of a character in pixels
- **BlockKeyboard()** - block keyboard, and unblock it through usage of keyboard
- **GetFileFormat()** - retreaves the codepage format of a file
- **RunUTF8()** - if a .exe file really requires its command line to be encoded as UTF-8, the following might work (a lexikos function)
- **Is64bitProcess()** - check if a process is running in 64bit
- **getSessionId()** - this functions finds out ID of current session
- **SetTrayIcon()** - sets a hex coded icon to as try icon
- **HashFile()** - calculate hashes (MD2,MD5,SH1,SHA256, SHA384, SHA512) from file ;23



## ![Gem](assets/GemSmall.png) [September 30, 2018]: +140 = 555 functions

### **functions for controls** (10)

- **ControlGetClassNN()** - different method is used here in compare to the already existing functions in this collection
- **FocusedControl()** - returns the HWND of the currently focused control, or 0 if there was a problem**
- **GetClassName()** - returns HWND‘s class name without its instance number, e.g. “Edit” or “SysListView32”
- **ControlSelectTab()** - SendMessage wrapper to select the current tab on a MS Tab Control.
- **ClickOK()** - function that search for any button in a window that might be an ‘Ok’ button to close a window dialog
- 4 different **AddToolTip() functions** - very easy to use function to add a tooltip to a control
- **Control_GetFont()** - retrieves the used font of a control



### **networking and Internet** (9)

- **HostToIp()** - gets the IP address for the given host directly using the WinSock 2.0 dll, without using temp files or third party utilities
- **LocalIps()** - with small changes to HostToIP() this can be used to retrieve all LocalIP‘s
- **IE_TabActivateByHandle()** - activates a tab by hwnd in InternetExplorer
- **IE_TabWinID()** - find the HWND of an IE window with a given tab name
- **GetAdaptersInfo()** - GetAdaptersAddresses function & IP_ADAPTER_ADDRESSES structure
- **Color_RGBtoHSV()** - converts beetween color two color spaces: RGB -> HSV
- **Color_HSVtoRGB()** - converts beetween color two color spaces: HSV -> RGB
- **ACCTabActivate()** - activate a Tab in IE - function uses acc.ahk library
- **TabActivate()** - a different approach to activate a Tab in IE - function uses acc.ahk library



### **Strings search and handling** (5)

- **CleanLine()** - Return a line with leading and trailing spaces removed, and tabs converted to spaces
- **StrTrim()** - Remove all leading and trailing whitespace including tabs, spaces, CR and LF
- **GetWordsNumbered()** - gives back an array of words from a string, you can specify the position of the words you want to keep
- **PrintArr()** - show values of an array in a listview gui for debugging
- **StrDiff()** - SIFT3 : Super Fast and Accurate string distance algorithm



### **more ListView functions** (19)

- **LV_SubitemHitTest()** - get‘s clicked column in listview
- **LV_EX_FindString()** - find an item in any listview , function works with ANSI and UNICODE (tested)
- **LV_RemoveSelBorder()** - remove the listview‘s selection border
- **LV_SetExplorerTheme()** - set ‘Explorer’ theme for ListViews & TreeViews on Vista+
- **LV_Update()** - update one listview item
- **LV_RedrawItem()** - this one redraws on listview item
- **LV_SetExStyle()** - set / remove / alternate extended styles to the listview control
- **LV_GetExStyle()** - get / remove / alternate extended styles to the listview control
- **LV_IsItemVisible()** - determines if a listview item is visible
- **LV_SetIconSpacing()** - Sets the space between icons in the icon view
- **LV_GetIconSpacing()** - Get the space between icons in the icon view
- **LV_GetItemPos()** - obtains the position of an item
- **LV_SetItemPos()** - set the position of an item
- **LV_MouseGetCellPos()** - returns the number (row, col) of a cell in a listview at present mouseposition  
- **LV_GetColOrderLocal()** - returns the order of listview columns for a local listview
- **LV_GetColOrder()** - returns the order of listview columns for a listview
- **LV_SetColOrderLocal()** - pass listview hWnd (not listview header hWnd)
- **LV_GetCheckedItems()** - Returns a list of checked items from a standard ListView Control
- **LV_ClickRow()** - simulates a left mousebutton click on a specific row in a listview



### **functions to deal with windows** (22)

- **WinActivateEx()** - Activate a Window, with extra Error Checking and More Features
- **AutoCloseBlockingWindows()** - close all open popup (childwindows), without knowing their names, of a parent window
- **SetParentByClass()** - set parent window by using its window class
- **MoveTogether()** - move 2 windows together - using DllCall to DeferWindowPos
- **SetWindowTheme()** - set Windows UI Theme by window handle
- **HideFocusBorder()** - hides the focus border for the given GUI control or GUI and all of its children
- **WinWaitCreated()** - Wait for a window to be created, returns 0 on timeout and ahk_id otherwise
- **closeContextMenu()** - a smart way to close a context menu
- **CheckWindowStatus()** - check’s if a window is responding or not responding (hung or crashed) - 
- **GuiDisableMove()** - to fix a gui/window to its coordinates
- **WinInsertAfter()** - insert a window after a specific window handle
- **GetWindowOrder()** - determines the window order for a given (parent-)hwnd 
- **EnumWindows()** - Get a list with all the top-level windows on the screen or controls in the window
- **CenterWindow()** - center a window or set position optional by using Top, Left, Right, Bottom or a combination of it
- **MouseGetText()** - get the text in the specified coordinates, function uses Microsoft UIA
- **unmovable()** - makes Gui unmovable
- **movable()** - makes Gui movable
- **A_DefaultGui()** - a nice function to have a possibility to get the number of the default gui
- **GetInfoUnderCursor()** - retreavies ACC-Child under cursor
- **GetAccPath()** - get the Acc path from (child) handle
- **GetEnumIndex()** - for Acc child object
- **enumChildCallback()** - i think this retreave’s the child process ID for a known gui hwnd and the main process ID



### **File System** (6)

- **GetFileAttributes()** - get attributes of a file or folder
- **SetFileTime()** - to set the time
- **SetFileAttributes()** - set attributes of a file or folder
- **FileSetSecurity()** -  set security for the file / folder
- **FileSetOwner()** - set the owner to file / directory
- **FileGetOwner()** - get the owner to file / director



### **Graphic/GDI Functions** (6)

- **GDI_GrayscaleBitmap()** - Converts GDI bitmap to 256 color GreyScale
- **Convert_BlackWhite()** - Convert exist imagefile to black&white , it uses machine code
- **getHBMinfo()**
- **SaveHBITMAPToFile()** - saves the hBitmap to a file
- **DrawRotatePictureOnGraphics()** - rotate a pBitmap
- **CopyBitmapOnGraphic()** - copy a pBitmap of a specific width and height to the Gdip graphics container (pGraphics)



### **ClipBoard Functions** (9)

- **ClipboardGetDropEffect()** - Clipboard function. Retrieves if files in clipboard comes from an explorer cut or copy operation.
- **ClipboardSetFiles()** - Explorer function for Drag&Drop and Pasting. Enables the explorer paste context menu option.
- **CopyFilesToClipboard()** - copy files to clipboard
- **FileToClipboard()** - copying the path to clipboard
- **FileToClipboard()** - a second way to copying the path to clipboard
- **ImageToClipboard()** - Copies image data from file to the clipboard. (first of three approaches)
- **Gdip_ImageToClipboard()** - Copies image data from file to the clipboard. (second approach)
- **Gdip_ImageToClipboard()** - Copies image data from file to the clipboard. (third approach)
- **AppendToClipboard()** - Appends files to CF_HDROP structure in clipboard



### **memory functions** (19)

- **ReadProcessMemory()** - reads data from a memory area in a given process.
- **WriteProcessMemory()** - writes data to a memory area in a specified process. the entire area to be written must be accessible or the operation will fail
- **CopyMemory()** - Copy a block of memory from one place to another 
- **MoveMemory()** - moves a block memory from one place to another
- **FillMemory()** - fills a block of memory with the specified value
- **ZeroMemory()** - fills a memory block with zeros
- **CompareMemory()** - compare two memory blocks
- **VirtualAlloc()** - changes the state of a region of memory within the virtual address space of a specified process. the memory is assigned to zero.AtEOF
- **VirtualFree()** - release a region of pages within the virtual address space of the specified process 
- **ReduceMem()** - reduces usage of memory from calling script 
- **GlobalLock()** - memory management function
- **LocalFree()** - free a locked memory object
- **CreateStreamOnHGlobal()** - creates a stream object that uses an HGLOBAL memory handle to store the stream contents. This object is the OLE-provided implementation of the IStream interface.
- **CoTaskMemFree()** - releases a memory block from a previously assigned task through a call to the CoTaskMemAlloc () or CoTaskMemAlloc () function.
- **CoTaskMemRealloc()** - change the size of a previously assigned block of working memory
- **VarAdjustCapacity()** - adjusts the capacity of a variable to its content
- **GetUIntByAddress()** - get UInt direct from memory. I found this functions only within one script 
- **SetUIntByAddress()** - write UInt direct to memory
- **RtlUlongByteSwap64()** - routine reverses the ordering of the four bytes in a 32-bit unsigned integer value (2 functions for AHK v1 und AHK v2)



### **Systeminformations** (7)

- **GetPhysicallyInstalledSystemMemory()** - recovers the amount of RAM in physically installed KB from the SMBIOS (System Management BIOS) firmware tables, WIN_V SP1+
- **GlobalMemoryStatus()** - retrieves information about the current use of physical and virtual memory of the system
- **GetSystemFileCacheSize()** - retrieves the current size limits for the working set of the system cache
- **DriveSpace()** - retrieves the DriveSpace
- **RtlGetVersion()** - retrieves version of installed windows system
- **UserAccountsEnum()** - list all users with information
- **GetCurrentUserInfo()** - obtains information from the current user



### **Font handling** (3)

- **FontEnum()** - enumerates all uniquely-named fonts in the system that match the font characteristics specified by the LOGFONT structure
- **GetFontTextDimension()** - calculate the height and width of the text in the specified font 
- **GetFontProperties()** - to get the current font‘s width and height



### **converting functions** (8)

- **RadianToDegree()** - convert radian (rad) to degree 
- **DegreeToRadian()** - convert degree to radian (rad)
- **RGBToARGB()** - convert RGB to ARGB
- **ARGBToRGB()** - convert ARGB to RGB.
- **JEE_HexToBinData()** - hexadecimal to binary
- **JEE_BinDataToHex()** - binary to hexadecimal 
- **JEE_BinDataToHex2()** - binary to hexadecimal2
- **DllListExports()** - List of Function exports of a DLL



### **functions for different purposes** (17)

- **pauseSuspendScript()** - function to suspend/pause another script
- **GetCommState()** - this function retrieves the configuration settings of a given serial port
- **Hotkeys()** - a handy function to show all used hotkeys in script
- **ColoredTooltip()** - show a tooltip for a given time with a custom color in rgb format (fore and background is supported). This function shows how to obtain the hWnd of the tooltip.
- **PostMessageUnderMouse()** - Post a message to the window underneath the mouse cursor, can be used to do things involving the mouse scroll wheel
- **GetBinaryType()** - determines the bit architecture of an executable program
- **SetRestrictedDacl()** - run this in your script to hide it from Task Manager
- **type(v)** - Object version: Returns the type of a value: “Integer”, “String”, “Float” or “Object” by Lexikos
- **type(ByRef v)** - COM version: Returns the type of a value: “Integer”, “String”, “Float” or “Object” by Lexikos
- **Time()** - calculate with time, add minutes, hours, days - add or subtract time
- **WM_SETCURSOR()** - Prevent “sizing arrow” cursor when hovering over window border
- **getActiveProcessName()** - this function finds the process to the ‘ForegroundWindow’
- **GetHandleInformation()** - obtain certain properties of a HANDLE
- **SetHandleInformation()** - establishes the properties of a HANDLE
- **InvokeVerb()** - executes the context menu item of the given path



## ![Gem](assets/GemSmall.png) [July 15, 2018]: +79 = 415 functions

I’ve found a lot function this time. I checked the found functions that these can not actually be found in any library, so that these can really be called "Rare". I added some more descriptions, examples, links and moved some functions to the right category. 

---------

***** changing the signs to default code folding signs. I changed **;{** to **{ ;** and **;}** to **}**. I hope it will work in most cases and most code editors.  

-------------

####*+added new section:* RegEx - Strings - useful strings for RegExMatch or Replace

- **2 RegEx strings to find AHK-functions** - not tested yet

  ### Strings/Arrays/Objects/Text/Variables

- **StrCount()** - a very handy function to count a needle in a Haystack
- **SuperInstr()** - Returns min/max position for a | separated values of Needle(s)
- **GetText()** - copies the selected text to a variable while preserving the clipboard.(Ctrl+C method)
- **PutText()** - Pastes text from a variable while preserving the clipboard. (Ctrl+v method)
- **GetFuncDefs()** - get function definitions from a script
- **ExploreObj()** - returns a string containing the formatted object keys and values (very nice for debugging!)
- **LineDelete()** - deletes lines of text from variables / no loop
- **ExtractFuncTOuserAHK()** - extract user function and helps to write it to userAhk.api
- **PdfToText()** - copies a selected PDF file to memory - it needs xpdf - pdftotext.exe
- **PdfPageCounter()** - counts pages of a pdffile (works with 95% of pdf files)
- **PasteWithIndent()** - paste string to an editor with your prefered indent key
- **SplitLine()** - split string to key and value
- **Ask_and_SetbackFocus()** - by opening a msgbox you lost focus and caret pos in any editor - this func will restore the previous positions of the caret
- **Valueof()** - Super Variables processor by Avi Aryan, overcomes the limitation of a single level ( return %var% ) in nesting variables

  ### Windows/Gui

- **WinSetPlacement()** - Sets window position using workspace coordinates (-> no taskbar)
- **AttachToolWindow()** - Attaches a window as a tool window to another window from a different process. 
- **DeAttachToolWindow()** - removes the attached ToolWindow
- **GetFreeGuiNum()** - gets a free gui number
- **DisableFadeEffect()** - disabling fade effect on gui animations
- **RMApp_NCHITTEST()** - Determines what part of a window the mouse is currently over
- **SetWindowTransistionDisable()** - disabling fade effect only for the window of choice 
- **IsWindowUnderCursor()** - Checks if a specific window is under the cursor.
- **GetCenterCoords()** - ?center a gui between 2 monitors?
- **Menu_AssignBitmap()** - assign bitmap to any item in any AHk menu
- **guiMsgBox()** - GUI Message Box to allow selection
- **DisableMinimizeAnim()** - disables or restores original minimize anim setting
- **GetTextSize()** - a corrected version of this function from majkinetor *(tested)*
- **MeasureText()** - alternative to other functions which calculate the text size before display on the screen
- **WinGetClientPos()** - gives back the coordinates of client area inside a gui/window - with DpiFactor correction
- **winfade()** - another winfade function
- **TT_Console()** - Use Tooltip as a User Interface it returns the key which has been pressed
- **ToolTipEx()** - Display ToolTips with custom fonts and colors
- **SafeInput()** - makes sure sure the same window stays active after showing the InputBox. Otherwise you might get the text pasted into another window unexpectedly.
- **CreateFont()** - creates font in memory which can be used with any API function accepting font handles
- **GetHFONT()** - gets a handle to a font used in a AHK gui for example
- **MsgBoxFont()** - style your MsgBox with with your prefered font
- **DisableCloseButton()** - to disable/grey out the close button

  ### Listview

- **LV_HeaderFontSet()** - sets a different font to a Listview header (it's need CreateFont() function) - formerly this function needs a function as a rewrite of SendMessage, I changed it to a DLLCall without an extra function, the depending function *CreateFont()* can be also found in this file
- **LV_Find()** - I think it‘s usefull to find an item position a listview
- **LV_GetSelectedText()** - returns text from selected rows in ListView (in a user friendly way IMO.)
- **LV_Notification()** - easy function for showing notifications by hovering over a listview
- **LV_IsChecked()** - alternate method to find out if a particular row number is checked
- **LV_SetCheckState()** - check (add check mark to) or uncheck (remove the check mark from) an item in the ListView control
- **LV_SetItemState()** - with this function you can set all avaible states to a listview item

  ### Controls

- **ControlDoubleClick()** - simulates a double click on a control with left/middle or right mousebutton
- **GetFocusedControl()** - get focused control from active window -multi Options[ClassNN \ Hwnd \ Text \ List \ All] available 
- **ControlGetTextExt()** - 3 different variants are tried to determine the text of a control
- **getControlInfo()** - get width and heights of controls
- **ControlSetTextAndResize()** - set a new text to a control and resize depending on textwidth and -height
- **GetCPA_file_name()** - retrieves Control Panel applet icon
- **IsControlUnderCursor()** - Checks if a specific control is under the cursor and returns its ClassNN if it is

  ### Other

- **TaskList()** - list all running tasks (no use of COM)
- **ResConImg()** - Resize and convert images. png, bmp, jpg, tiff, or gif 
- **ReleaseModifiers()** - helps to solve the Hotkey stuck problem
- **isaKeyPhysicallyDown()** - belongs to ReleaseModifiers() function
- **CreateCircleProgress(s)** - very nice to see function for a circle progress
- **IndexOfIconResource()** - function is used to convert an icon resource id (as those used in the registry) to icon index(as used by ahk)
- **GetIconforext()** - Gets default registered icon for an extension
- **IsConnected()** - Returns true if there is an available internet connection
- **RGBrightnessToHex()** - transform rbg (with brightness) values to hex 
- **GetHueColorFromFraction()** - get hue color from fraction. example: h(0) is red, h(1/3) is green and h(2/3) is blue (345)
- **MouseDpi()** - Change the current dpi setting of the mouse
- **GetProcessName()** - Gets the process name from a window handle.
- **GetDisplayOrientation()** - working function to get the orientation of screen
- **FileCRC32()** - Computes and returns CRC32 hash for a File passed as parameter
- **FindFreeFileName()** - Finds a non-existing filename for Filepath by appending a number in brackets to the name
- **ToggleSystemCursor()** - choose a cursor from system cursor list
- **GetSysErrorText()** - method to get meaningful data out of the error codes
- **getSysLocale()** - gets the system language 
- **URLPrefGui()** - shimanov‘s workaround for displaying URLs in a gui
- **ReadProxy()** - reads the proxy settings from the windows registry
- **CountFilesR()** - count files recursive in specific folder (uses COM method)
- **CountFiles()** - count files in specific folder (uses COM method)
- **GetThreadStartAddr()** - returns start adresses from all threads of a process
- **FormatFileSize()** - Formats a file size in bytes to a human-readable size string
- **SendToAHK()** - Sends strings by using a hidden gui between AHK scripts
- **ReceiveFromAHK()** - Receiving strings from SendToAHK
- **PathInfo()** - splits a given path to return as object

-----
## ![Gem](assets/GemSmall.png) [June 13, 2018]: 326 functions

- **TimedFunction()** - SetTimer functionality for functions
- **ListGlobalVars()** - ListGlobalVars() neither shows nor activates the AutoHotkey main window, it returns a string
- **HelpToolTips()** -  To show defined GUI control help tooltips on hover.
- **StringM()** -  String manipulation with many options is using RegExReplace  (bloat, drop, Flip, Only, Pattern, Repeat, Replace, Scramble, Split)
- **FileWriteLine()** -  To write data at specified line in a file.
- **FileMD5()** - File MD5 Hashing
- **StringMD5()** - String MD5 Hashing
- **Dec2Base()** - Base to Decimal and 
- **Base2Dec()** - Decimal to Base conversion
- **InjectDll()** - injects a dll to a running process (ahkdll??)
- **HexToFloat()** - Hexadecimal to Float conversion
- **FloatToHex()** - Float to Hexadecimal conversion
- **CalculateDistance()** - calculates the distance between two points in a 2D-Space 
- **IsInRange()** - shows if a second variable is in range
- **GetRange()** - another good screen area selection function
- **GetComboBoxChoice()** - Combobox function
- **LB_AdjustItemHeight()** - Listbox function
- **LB_GetItemHeight()** - Listbox function
- **LB_SetItemHeight()**- Listbox function
- **GetClientSize()** - get size of window without border

----
## ![Gem](assets/GemSmall.png) [June 10, 2018]: 316 functions

*minor layout improvement (so I hope, anyway). In the [AHK forum](https://autohotkey.com/boards/) I read that codefolding does not work. After trying with the [Sublime Text Editor](https://www.sublimetext.com) I noticed that Sublime does not natively support codefolding via the syntax **;{** , **;}**. Maybe that's the problem. The collection was created with  [Scite4Autohotkey](https://github.com/fincs/SciTE4AutoHotkey).*

- **ChangeMacAdress()** - change MacAdress, it makes changes to the registry!
- **ListAHKStats()** - Listvars with select desired section: ListLines, ListVars, ListHotkeys, KeyHistory
- **LV_MoveRow()** - the same like above, but slightly different. With integrated script example
- **AddToolTip()** - Add/Update tooltips to GUI controls
- **ExtractTableData()** - extracts tables from HTML files
- **MouseExtras()** - Allows to use subroutines for Holding and Double Clicking a Mouse Button.
- **CaptureScreen()** - screenshot function 4 - orginally from CaptureScreen.ahk
- **CaptureCursor()** - this captures the cursor, depending function of CaptureScreen()
- **Zoomer()** - zooms a HBitmap, depending function of CaptureScreen()
- **SaveHBITMAPToFile()** - saves a HBitmap to a file, depending function of CaptureScreen()

-----
## ![Gem](assets/GemSmall.png) [June 02, 2018]: 306 functions

***6 functions removed*** - depending functions not available or the functions are doubled, ***added some links*** to the sources of ***origin*** of the functions. As far as findable some feature ***descriptions and example scripts added***.

- **LV_SetBackgroundURL()** - set a ListView's background image
- **GetBgBitMapHandle()** - returns the handle of a background bitmap in a gui
- **CreatePatternBrushFrom()** - can be used to repeat a pattern as background image in a gui
- **GetLastActivePopUp()** - passes the handle of the last active pop-up window of a parent window
- **Convert()** - converts ImageFiles
- **GUI_AutoHide()** - Autohide the GUI function
- **DeskIcons()** - i think its for showing all desktop icons
- **WinFadeToggle()**
- **KilProcess()** - uses DllCalls to end a process
- **ConsoleSend()** - Sends text to a console's input stream
- **StdOutStream()** - Store command line output in autohotkey variable. Supports both x86 and x64.
- **LV_MoveRow()** - moves a listview row up or down
- **SetButtonF()** - Set a button control to call a function instead of a label subroutine 
- **GetScriptVARs()** - returns a key, value array with all script variables (e.g. for debugging purposes)
- **GetAllInputChars()** - Returns a string with input characters
- **LoadScriptResource()** - loads a resource into memory (e.g. picture, scripts..)
- **HIconFromBuffer()** - function provides a HICON handle e.g. from a resource previously loaded into memory (LoadScriptResource)
- **hBMPFromPNGBuffer()** - Function provides a hBitmap handle e.g. from a resource previously loaded into memory (LoadScriptResource)
- **getNextControl()** - I'm not sure if this function works could be an AHK code for the Control.GetNextControl method for System.Windows.Forms
- **SaveSetColours()** - Sys colours saving adapted from an approach found in Bertrand Deo's code

-----
## ![Gem](assets/GemSmall.png) [May 28, 2018]: 293 functions

***Organized layout***, some functions moved to the right topic, delete duplicate functions, adding more info and examples*

***Functionlist to Markdown.ahk*** - my script to handle the Markdown table output for this page. It's not a dynamic script! The output depends from the following syntax: 

```Autohotkey
SystemCursor(OnOff=1) {  							;-- hiding mouse cursor
```

-> it search for '**(**' followed by a '**;--**' , then it recognized it as a function, it uses the comment as short description

-> it ignores all functions without '**;--**' or functions that marked with '**;{ sub**' at the beginning and '**;}**' at the end:

```Autohotkey
;{ sub
;If [var] in [ .. ]
InVar(Haystack, Needle, Delimiter := ",", OmitChars := "") {
	Loop, Parse, % Needle, %Delimiter%, %OmitChars%
		if (A_LoopField = Haystack)
			return 1
	return 0
}

IsWindow(hWnd*) {
	if !hWnd.MaxIndex()
		return DllCall("User32.dll\GetForegroundWindow")
	return i := DllCall("User32.dll\IsWindow", "Ptr", hWnd[1] )
		, ErrorLevel := !i
}
;}
```

***new functions:***

- **LVGetCount()** - get current count of notes in a Listbox
- **LV_SetSelColors()** - Sets the colors for selected rows in a ListView.
- **LV_Select()** - de- or select a row in a ListView
- **![splitbutton](https://raw.githubusercontent.com/Ixiko/AHK-Forum/master/images/SplitButton.png)SplitButton()** - drop down button 
- **TV_Find()** -  return the ID of an item based on the text of the item
- **FileCount(filter)** - count matching files in the working directory
- **AddToolTip()** - adds a ToolTip to a gui button
- **SetTaskbarProgress()** - Accesses Windows 7's ability to display a progress bar behind a taskbar button
- **RegExSplit()** -split a string by a regular expression pattern and receive an array as a result
- **CreateGist()** - sends your script to your gist
- **IsOfficeFile()** - checks if a file is an Office file
- **GetAllResponseHeaders()** - Gets the values of all HTTP headers
- **GetImageTypeW()** - Identify the image type (UniCode)
- **Edit_VCenter()** - Vertically Align Text
- **BetterBox()** - custom input box allows to choose the position of the text insertion point
- **BtnBox()** - show a custom MsgBox with arbitrarily named buttons
- **LoginBox()** - show a custom input box for credentials, return an object with Username and Password
- **MultiBox()** - show a multi-line input box, return the entered text
- **PassBox()** -show a custom input box for a password
- **LoadFile()** - Loads a script file as a child process and returns an object
- **RGBRange()** - returns an array for a color transition from x to y
- **SystemCursor()** - hiding mouse cursor
- **getSelectionCoords()** - creates a click-and-drag selection box to specify an area and returns the coordinates
- **Mean()** - returns Average values in comma delimited list
- **Median()** - returns Median in a set of numbers from a list
- **Mode()** - returns the mode from a list of numbers
- **FloodFill()** - filling an area using color banks
- **CreateBMPGradient()** - Horizontal/Vertical gradient
- **NetStat()** - passes information over network connections similar to the netstat -an CMD command.
- **TV_Load()** - loads TreeView items from an XML string

-----
## ![Gem](assets/GemSmall.png) [May 22, 2018]: 253 functions

+ **FindChildWindow()** - a very good function to get handles from child windows like MDI childs
+ **WinGetMinMaxState()** - returns the state of a window if maximized or minimized
+ **TimeCode()** - result is a date-time string or only time-string (13.05.2018, 11:35:01.241) - can be useful for any kind of logging
+ **RegRead64(), RegWrite64()** - This script provides **RegRead64()** and **RegWrite64()** functions that do not redirect to Wow6432Node on 64-bit machines. Registry calls from 32 bit applications running on 64 bit machines are normally intercepted by the system and redirected from HKLM\SOFTWARE to HKLM\SOFTWARE\Wow6432Node. 
+ **CreateOpenWithMenu()** - Creates an 'open with' menu for the passed file. a function by just me based on code from qwerty12
+ **CircularText(), RotateAroundCenter()** - Given a string it will generate a bitmap of the characters drawn with a given angle between each char, if the angle is 0 it will try to make the string fill the entire circle.
+ **QuickSort()** -  Sort dense arrays or matrices based on Quicksort algorithm
+ **FrameShadow(HGui)** - Drop Shadow On Borderless Window, (DWM STYLE)

-----
## ![Gem](assets/GemSmall.png)[May 06, 2018]: 243 functions

- **getByControlName()**  - function uses DllCalls
- **listAccChildProperty()** - uses COM functionality
- **getText(), getHtmlById(), getTextById(), getHtmlByTagName(), getTextByTagName()** -get text or html from a string
- **TabCtrl_GetCurSel(), TabCtrl_GetItemText()** - the first returns the 1-based index of 

-----
## ![Gem](assets/GemSmall.png) Complete List of functions ![Gem](assets/GemSmall.png)

*sometimes the function names are the same but they use different methods to get the same result*

| FNr  | Line  | name of function and description                             |
| :--: | :---: | ------------------------------------------------------------ |
| 001 | 00011 | **ClipboardGetDropEffect()** - *Clipboard function. Retrieves if files in clipboard comes from an explorer cut or copy operation.* |
| 002 | 00034 | **ClipboardSetFiles()** - *Explorer function for Drag&Drop and Pasting. Enables the explorer paste context menu option.* |
| 003 | 00081 | **CopyFilesToClipboard()** - *copy files to clipboard* |
| 004 | 00137 | **FileToClipboard()** - *copying the path to clipboard* |
| 005 | 00168 | **FileToClipboard()** - *a second way to copying the path to clipboard* |
| 006 | 00204 | **ImageToClipboard()** - *Copies image data from file to the clipboard. (first of three approaches)* |
| 007 | 00218 | **Gdip_ImageToClipboard()** - *Copies image data from file to the clipboard. (second approach)* |
| 008 | 00239 | **Gdip_ImageToClipboard()** - *Copies image data from file to the clipboard. (third approach)* |
| 009 | 00285 | **AppendToClipboard()** - *Appends files to CF_HDROP structure in clipboard* |
| 010 | 00306 | **CMDret_RunReturn()** |
| 011 | 00419 | **ConsoleSend()** - *Sends text to a console's input stream* |
| 012 | 00471 | **ScanCode()** - *subfunction for ConsoleSend* |
| 013 | 00476 | **StdOutStream()** - *Store command line output in autohotkey variable. Supports both x86 and x64.* |
| 014 | 00645 | **StdoutToVar_CreateProcess()** - *Runs a command line program and returns its output* |
| 015 | 00712 | **RunUTF8()** - *if a .exe file really requires its command line to be encoded as UTF-8, the following might work (a lexikos function)* |
| 016 | 00739 | **PrettyTickCount()** - *takes a time in milliseconds and displays it in a readable fashion* |
| 017 | 00748 | **TimePlus()** |
| 018 | 00758 | **FormatSeconds()** - *formats seconds to hours,minutes and seconds -> 12:36:10* |
| 019 | 00766 | **TimeCode()** - *TimCode can be used for protokoll or error logs* |
| 020 | 00778 | **Time()** - *calculate with time, add minutes, hours, days - add or subtract time* |
| 021 | 00924 | **DateDiff()** - *returns the difference between two timestamps in the specified units* |
| 022 | 01022 | **GetProcesses()** - *get the name of all running processes* |
| 023 | 01063 | **getProcesses()** - *get running processes with search using comma separated list* |
| 024 | 01114 | **GetProcessWorkingDir()** - *like the name explains* |
| 025 | 01145 | **GetTextSize()** - *precalcute the Textsize (Width & Height)* |
| 026 | 01155 | **GetTextSize()** - *different function to the above one* |
| 027 | 01231 | **MeasureText()** - *alternative to other functions which calculate the text size before display on the screen* |
| 028 | 01270 | **monitorInfo()** - *shows infos about your monitors* |
| 029 | 01287 | **whichMonitor()** - *return [current monitor, monitor count]* |
| 030 | 01299 | **IsOfficeFile()** - *checks if a file is an Office file* |
| 031 | 01367 | **DeskIcons()** - *i think its for showing all desktop icons* |
| 032 | 01410 | **GetFuncDefs()** - *get function definitions from a script* |
| 033 | 01452 | **IndexOfIconResource()** - *function is used to convert an icon resource id (as those used in the registry) to icon index(as used by ahk)* |
| 034 | 01474 | **IndexOfIconResource_EnumIconResources()** - *subfunction of IndexOfIconResource()* |
| 035 | 01487 | **GetIconforext()** - *Gets default registered icon for an extension* |
| 036 | 01509 | **GetImageType()** - *returns whether a process is 32bit or 64bit* |
| 037 | 01529 | **GetProcessName()** - *Gets the process name from a window handle.* |
| 038 | 01535 | **GetDisplayOrientation()** - *working function to get the orientation of screen* |
| 039 | 01551 | **GetSysErrorText()** - *method to get meaningful data out of the error codes* |
| 040 | 01567 | **getSysLocale()** - *gets the system language* |
| 041 | 01582 | **GetThreadStartAddr()** - *returns start adresses from all threads of a process* |
| 042 | 01625 | **ScriptExist()** - *true oder false if Script is running or not* |
| 043 | 01647 | **GetStartupWindowState()** - *to check, if script exe was launched by windows's shortcut with MAXIMIZE* |
| 044 | 01695 | **LoadPicture()** - *Loads a picture and returns an HBITMAP or HICON to the caller* |
| 045 | 02074 | **GetImageDimensionProperty()** - *this retrieves the dimensions from a dummy Gui* |
| 046 | 02106 | **GetImageDimensions()** - *Retrieves image width and height of a specified image file* |
| 047 | 02146 | **Gdip_FillRoundedRectangle()** |
| 048 | 02167 | **Redraw()** - *redraws the overlay window(s) using the position, text and scrolling settings* |
| 049 | 02245 | **CreateSurface()** - *creates a drawing GDI surface* |
| 050 | 02274 | **ShowSurface()** - *subfunction for CreateSurface* |
| 051 | 02280 | **HideSurface()** - *subfunction for CreateSurface* |
| 052 | 02284 | **WipeSurface()** - *subfunction for CreateSurface* |
| 053 | 02289 | **StartDraw()** - *subfunction for CreateSurface* |
| 054 | 02301 | **EndDraw()** - *subfunction for CreateSurface* |
| 055 | 02306 | **SetPen()** - *subfunction for CreateSurface* |
| 056 | 02322 | **DrawLine()** - *used DLLCall to draw a line* |
| 057 | 02329 | **DrawRectangle()** - *used DLLCall to draw a rectangle* |
| 058 | 02339 | **DrawRectangle()** - *this is for screenshots* |
| 059 | 02368 | **DrawFrameAroundControl()** - *paints a rectangle around a specified control* |
| 060 | 02437 | **Highlight()** - *Show a red rectangle outline to highlight specified region, it's useful to debug* |
| 061 | 02537 | **SetAlpha()** - *set alpha to a layered window* |
| 062 | 02544 | **CircularText()** - *given a string it will generate a bitmap of the characters drawn with a given angle between each char* |
| 063 | 02570 | **RotateAroundCenter()** - *GDIP rotate around center* |
| 064 | 02578 | **Screenshot()** - *screenshot function 1* |
| 065 | 02593 | **TakeScreenshot()** - *screenshot function 2* |
| 066 | 02621 | **CaptureWindow()** - *screenshot function 3* |
| 067 | 02651 | **CaptureScreen()** - *screenshot function 4 - orginally from CaptureScreen.ahk* |
| 068 | 02743 | **CaptureCursor()** - *subfunction for CaptureScreen() - this captures the cursor* |
| 069 | 02769 | **Zoomer()** - *subfunction for CaptureScreen() - zooms a HBitmap, depending function of CaptureScreen()* |
| 070 | 02787 | **Convert()** - *subfunction for CaptureScreen() - converts from one picture format to another one, depending on Gdip restriction only .bmp, .jpg, .png is possible* |
| 071 | 02853 | **SaveHBITMAPToFile()** - *subfunction for CaptureScreen() - saves a HBitmap to a file* |
| 072 | 02865 | **RGBRange()** - *returns an array for a color transition from x to y* |
| 073 | 02895 | **getSelectionCoords()** - *creates a click-and-drag selection box to specify an area* |
| 074 | 02962 | **GetRange()** - *another good screen area selection function* |
| 075 | 03073 | **FloodFill()** - *filling an area using color banks* |
| 076 | 03123 | **CreateBMPGradient()** - *Horizontal/Vertical gradient* |
| 077 | 03146 | **BGR()** - *BGR() subfunction from CreateBMPGradient()* |
| 078 | 03153 | **CreatePatternBrushFrom()** - *as it says* |
| 079 | 03185 | **ResConImg()** - *Resize and convert images. png, bmp, jpg, tiff, or gif* |
| 080 | 03237 | **CreateCircleProgress()** - *very nice to see functions for a circle progress* |
| 081 | 03346 | **UpdateCircleProgress()** - *subfunction for CreateCircleProgress* |
| 082 | 03351 | **DestroyCircleProgress()** - *subfunction for CreateCircleProgress* |
| 083 | 03359 | **RGBrightnessToHex()** - *transform rbg (with brightness) values to hex* |
| 084 | 03364 | **GetHueColorFromFraction()** - *get hue color from fraction. example: h(0) is red, h(1/3) is green and h(2/3) is blue* |
| 085 | 03374 | **SaveHBITMAPToFile()** - *saves the hBitmap to a file* |
| 086 | 03384 | **DrawRotatePictureOnGraphics()** - *rotate a pBitmap* |
| 087 | 03401 | **CopyBitmapOnGraphic()** - *copy a pBitmap of a specific width and height to the Gdip graphics container (pGraphics)* |
| 088 | 03408 | **GDI_GrayscaleBitmap()** - *Converts GDI bitmap to 256 color GreyScale* |
| 089 | 03445 | **Convert_BlackWhite()** - *Convert exist imagefile to black&white , it uses machine code* |
| 090 | 03499 | **BlackWhite()** - *sub from Convert_BlackWhite* |
| 091 | 03508 | **getHBMinfo()** |
| 092 | 03516 | **CreateDIB()** - *a wonderfull function by SKAN to draw tiled backgrounds (like chess pattern) to a gui, it can also draw gradients* |
| 093 | 03569 | **GuiControlLoadImage()** - *scale down a picture to fit the given width and height of a picture control* |
| 094 | 03629 | **Gdip_ResizeBitmap()** - *returns resized bitmap* |
| 095 | 03675 | **Gdip_CropBitmap()** - *returns cropped bitmap. Specify how many pixels you want to crop (omit) from each side of bitmap rectangle* |
| 096 | 03712 | **GetBitmapSize()** - *Lexikos function to get the size of bitmap* |
| 097 | 03739 | **Gdip_BitmapReplaceColor()** - *using Mcode to replace a color with a specific variation* |
| 098 | 03786 | **Gdi_ExtFloodFill()** - *fills an area with the current brush* |
| 099 | 03840 | **Gdip_AlphaMask32v1()** - *32bit Gdip-AlphaMask with MCode - one of two builds* |
| 100 | 03887 | **Gdip_AlphaMask32v2()** - *32bit Gdip-AlphaMask with MCode  - second of two builds* |
| 101 | 03937 | **Gdip_AlphaMask64()** - *64bit Gdip-AlphaMask with MCode* |
| 102 | 03957 | **()** - *LTrim Join* |
| 103 | 03994 | **CircleCrop()** - *gdi circlecrop with MCode* |
| 104 | 04041 | **get_png_image_info()** - *Getting PNG image info* |
| 105 | 04124 | **byte_swap_32()** - *subfunction of get_png_image_info(), change endian-ness for 32-bit integer* |
| 106 | 04130 | **print_line()** - *subfunction of get_png_image_info(),  output line to STDOUT for debugging in my text editor (sublime)* |
| 107 | 04134 | **GetBitmapFromAnything()** - *Supports paths, icon handles and hBitmaps* |
| 108 | 04159 | **Image_TextBox()** - *Function to use Gdip to add text to image* |
| 109 | 04368 | **ColorAdjL()** - *Adjust Luminance for a given RGB color* |
| 110 | 04427 | **PixelCheckSum()** - *Generates a CheckSum for a region of pixels in Screen/Window* |
| 111 | 04510 | **HtmlBox()** - *Gui with ActiveX - Internet Explorer - Control* |
| 112 | 04593 | **EditBox()** - *Displays an edit box with the given text, tile, and options* |
| 113 | 04622 | **()** |
| 114 | 04688 | **Popup()** - *Splashtext Gui* |
| 115 | 04712 | **PIC_GDI_GUI()** - *a GDI-gui to show a picture* |
| 116 | 04750 | **SplitButton()** - *drop down button* |
| 117 | 04826 | **BetterBox()** - *custom input box allows to choose the position of the text insertion point* |
| 118 | 04874 | **BtnBox()** - *show a custom MsgBox with arbitrarily named buttons* |
| 119 | 04922 | **LoginBox()** - *show a custom input box for credentials, return an object with Username and Password* |
| 120 | 04968 | **MultiBox()** - *show a multi-line input box, return the entered text* |
| 121 | 05013 | **PassBox()** - *show a custom input box for a password* |
| 122 | 05058 | **CreateHotkeyWindow()** - *Hotkey Window* |
| 123 | 05094 | **GetUserInput()** - *allows you to create custom dialogs that can store different values (each value has a different set of controls)* |
| 124 | 05170 | **()** |
| 125 | 05291 | **guiMsgBox()** - *GUI Message Box to allow selection* |
| 126 | 05323 | **URLPrefGui()** - *shimanov's workaround for displaying URLs in a gui* |
| 127 | 05431 | **TaskDialog()** - *a Task Dialog is a new kind of dialogbox that has been added in Windows Vista and later. They are similar to message boxes, but with much more power.* |
| 128 | 05461 | **TaskDialogDirect()** - *part of TaskDialog ?* |
| 129 | 05502 | **TaskDialogMsgBox()** - *part of TaskDialog ?* |
| 130 | 05542 | **TaskDialogToUnicode()** - *part of TaskDialog ?* |
| 131 | 05550 | **TaskDialogCallback()** - *part of TaskDialog ?* |
| 132 | 05570 | **TT_Console()** - *Use Tooltip as a User Interface it returns the key which has been pressed* |
| 133 | 05626 | **ToolTipEx()** - *Display ToolTips with custom fonts and colors* |
| 134 | 05836 | **SafeInput()** - *makes sure the same window stays active after showing the InputBox. Otherwise you might get the text pasted into another window unexpectedly.* |
| 135 | 05855 | **FadeGui()** - *used DllCall to Animate (Fade in/out) a window* |
| 136 | 05868 | **WinFadeToggle()** - *smooth fading in out a window* |
| 137 | 05930 | **winfade()** - *another winfade function* |
| 138 | 05947 | **ShadowBorder()** - *used DllCall to draw a shadow around a gui* |
| 139 | 05953 | **FrameShadow()** - *FrameShadow1* |
| 140 | 05964 | **FrameShadow()** - *FrameShadow(): Drop Shadow On Borderless Window, (DWM STYLE)* |
| 141 | 05992 | **RemoveWindowFromTaskbar()** - *remove the active window from the taskbar by using COM* |
| 142 | 06026 | **vtable()** - *subfunction of RemoveWindowFromTaskbar(), ; NumGet(ptr+0) returns the address of the object's virtual function* |
| 143 | 06033 | **ToggleTitleMenuBar()** - *show or hide Titlemenubar* |
| 144 | 06047 | **ToggleFakeFullscreen()** - *sets styles to a window to look like a fullscreen* |
| 145 | 06077 | **FullScreenToggleUnderMouse()** - *toggles a window under the mouse to look like fullscreen* |
| 146 | 06098 | **SetTaskbarProgress()** - *accesses Windows 7's ability to display a progress bar behind a taskbar button.* |
| 147 | 06164 | **SetTaskbarProgress()** - *modified function* |
| 148 | 06221 | **InVar()** - *sub of SetTaskbarProgress, parsing list search* |
| 149 | 06228 | **IsWindow()** - *sub of SetTaskbarProgress, different approach to IsWindow in gui + window - get/find section* |
| 150 | 06235 | **WinSetPlacement()** - *Sets window position using workspace coordinates (-> no taskbar)* |
| 151 | 06264 | **AttachToolWindow()** - *Attaches a window as a tool window to another window from a different process.* |
| 152 | 06284 | **DeAttachToolWindow()** - *removes the attached ToolWindow* |
| 153 | 06306 | **Control_SetTextAndResize()** - *set a new text to a control and resize depending on textwidth and -height* |
| 154 | 06331 | **DropShadow()** - *Drop Shadow On Borderless Window, (DWM STYLE)* |
| 155 | 06364 | **GetGuiClassStyle()** - *returns the class style of a Autohotkey-Gui* |
| 156 | 06375 | **SetGuiClassStyle()** - *sets the class style of a Autohotkey-Gui* |
| 157 | 06392 | **GetComboBoxChoice()** - *Combobox function* |
| 158 | 06412 | **Edit_Standard_Params()** - *these are helper functions to use with edit controls* |
| 159 | 06422 | **Edit_TextIsSelected()** - *returns bool if text is selected in an edit control* |
| 160 | 06429 | **Edit_GetSelection()** - *get selected text in an edit control* |
| 161 | 06441 | **Edit_Select()** - *selects text inside in an edit control* |
| 162 | 06453 | **Edit_SelectLine()** - *selects one line in an edit control* |
| 163 | 06485 | **Edit_DeleteLine()** - *delete one line in an edit control* |
| 164 | 06501 | **Edit_VCenter()** - *Vertically Align Text for edit controls* |
| 165 | 06536 | **IL_LoadIcon()** - *no description* |
| 166 | 06544 | **IL_GuiButtonIcon()** - *no description* |
| 167 | 06570 | **LB_AdjustItemHeight()** - *Listbox function* |
| 168 | 06576 | **LB_GetItemHeight()** - *Listbox function* |
| 169 | 06583 | **LB_SetItemHeight()** - *Listbox function* |
| 170 | 06596 | **LV_GetCount()** - *get current count of notes in from any listview* |
| 171 | 06604 | **LV_SetSelColors()** - *sets the colors for selected rows in a listView.* |
| 172 | 06672 | **LV_Select()** - *select/deselect 1 to all rows of a listview* |
| 173 | 06694 | **LV_GetItemText()** - *read the text from an item in a ListView* |
| 174 | 06733 | **LV_GetText()** - *get text by item and subitem from a Listview* |
| 175 | 06821 | **ExtractInteger()** - *Sub of LV_GetItemText and LV_GetText* |
| 176 | 06844 | **InsertInteger()** - *Sub of LV_GetItemText and LV_GetText* |
| 177 | 06858 | **LV_SetBackgroundURL()** - *set a ListView's background image - please pay attention to the description* |
| 178 | 06904 | **LV_MoveRow()** - *moves a listview row up or down* |
| 179 | 06924 | **LV_MoveRow()** - *the same like above, but slightly different. With integrated script example.* |
| 180 | 06976 | **LV_Find()** - *I think it's usefull to find an item position a listview* |
| 181 | 06991 | **LV_GetSelectedText()** - *Returns text from selected rows in ListView (in a user friendly way IMO.)* |
| 182 | 07040 | **LV_Notification()** - *easy function for showing notifications by hovering over a listview* |
| 183 | 07065 | **LV_IsChecked()** - *alternate method to find out if a particular row number is checked* |
| 184 | 07072 | **LV_HeaderFontSet()** - *sets a different font to a Listview header (it's need CreateFont() function)* |
| 185 | 07165 | **LV_SetCheckState()** - *check (add check mark to) or uncheck (remove the check mark from) an item in the ListView control* |
| 186 | 07196 | **LV_SetItemState()** - *with this function you can set all avaible states to a listview item* |
| 187 | 07234 | **NumPut()** - *mask* |
| 188 | 07235 | **NumPut()** - *iItem* |
| 189 | 07236 | **NumPut()** - *state* |
| 190 | 07237 | **NumPut()** - *stateMask* |
| 191 | 07245 | **LV_SubitemHitTest()** - *get's clicked column in listview* |
| 192 | 07299 | **LV_EX_FindString()** - *find an item in any listview , function works with ANSI and UNICODE (tested)* |
| 193 | 07313 | **LV_RemoveSelBorder()** - *remove the listview's selection border* |
| 194 | 07328 | **LV_SetExplorerTheme()** - *set 'Explorer' theme for ListViews & TreeViews on Vista+* |
| 195 | 07339 | **LV_Update()** - *update one listview item* |
| 196 | 07343 | **LV_RedrawItem()** - *this one redraws on listview item* |
| 197 | 07350 | **LV_SetExStyle()** - *set / remove / alternate extended styles to the listview control* |
| 198 | 07370 | **LV_GetExStyle()** - *get / remove / alternate extended styles to the listview control* |
| 199 | 07374 | **LV_IsItemVisible()** - *determines if a listview item is visible* |
| 200 | 07378 | **LV_SetIconSpacing()** - *Sets the space between icons in the icon view* |
| 201 | 07392 | **LV_GetIconSpacing()** - *Get the space between icons in the icon view* |
| 202 | 07404 | **LV_GetItemPos()** - *obtains the position of an item* |
| 203 | 07422 | **LV_SetItemPos()** - *set the position of an item* |
| 204 | 07440 | **LV_MouseGetCellPos()** - *returns the number (row, col) of a cell in a listview at present mouseposition* |
| 205 | 07480 | **LV_GetColOrderLocal()** - *returns the order of listview columns for a local listview* |
| 206 | 07518 | **LV_GetColOrder()** - *returns the order of listview columns for a listview* |
| 207 | 07577 | **LV_SetColOrderLocal()** - *pass listview hWnd (not listview header hWnd)* |
| 208 | 07591 | **LV_SetColOrder()** - *pass listview hWnd (not listview header hWnd)* |
| 209 | 07644 | **LV_GetCheckedItems()** - *Returns a list of checked items from a standard ListView Control* |
| 210 | 07657 | **LV_ClickRow()** - *simulates a left mousebutton click on a specific row in a listview* |
| 211 | 07670 | **LV_HeaderFontSet()** - *sets font for listview headers* |
| 212 | 07764 | **LV_SetSI()** - *set icon for row "subItem" within Listview* |
| 213 | 07820 | **LVM_CalculateSize()** - *calculate the width and height required to display a given number of rows of a ListView control* |
| 214 | 08007 | **r_Width :=()** - *LOWORD* |
| 215 | 08008 | **r_Height:=()** - *HIWORD* |
| 216 | 08012 | **LV_RemoveSelBorder()** - *to remove the listview's selection border* |
| 217 | 08046 | **LVM_GetItemText()** - *gets the text of a ListView item or subitem.* |
| 218 | 08082 | **NumPut()** - *mask* |
| 219 | 08083 | **NumPut()** - *iItem* |
| 220 | 08084 | **NumPut()** - *iSubItem* |
| 221 | 08101 | **LVM_GetSizeOfLVITEM()** - *sub of LV_GetItemText (06.03.05.000040)* |
| 222 | 08103 | **if ()** - *Vista+* |
| 223 | 08112 | **TabCtrl_GetCurSel()** - *Indexnumber of active tab in a gui* |
| 224 | 08120 | **TabCtrl_GetItemText()** - *returns text of a tab* |
| 225 | 08152 | **SetError()** - *sub of TabCtrl functions* |
| 226 | 08162 | **TV_Find()** - *returns the ID of an item based on the text of the item* |
| 227 | 08176 | **TV_Load()** - *loads TreeView items from an XML string* |
| 228 | 08222 | **()** - *oin* |
| 229 | 08241 | **()** - *oin* |
| 230 | 08358 | **TV_GetItemText()** - *retrieves the text/name of the specified treeview node +* |
| 231 | 08410 | **ControlCreateGradient()** - *draws a gradient as background picture* |
| 232 | 08426 | **AddGraphicButtonPlus()** - *GDI+ add a graphic button to a gui* |
| 233 | 08461 | **UpdateScrollBars()** - *immediate update of the window content when using a scrollbar* |
| 234 | 08655 | **screenDims()** - *returns informations of active screen (size, DPI and orientation)* |
| 235 | 08666 | **DPIFactor()** - *determines the Windows setting to the current DPI factor* |
| 236 | 08682 | **ControlExists()** - *true/false for ControlClass* |
| 237 | 08694 | **GetFocusedControl()** - *retrieves the ahk_id (HWND) of the active window's focused control.* |
| 238 | 08726 | **GetControls()** - *returns an array with ClassNN, Hwnd and text of all controls of a window* |
| 239 | 08755 | **GetOtherControl()** |
| 240 | 08761 | **ListControls()** - *similar function to GetControls but returns a comma seperated list* |
| 241 | 08784 | **Control_GetClassNN()** - *no-loop* |
| 242 | 08796 | **ControlGetClassNN()** - *with loop* |
| 243 | 08810 | **ControlGetClassNN()** - *different method is used here in compare to the already existing functions in this collection* |
| 244 | 08824 | **GetClassName()** - *returns HWND's class name without its instance number, e.g. "Edit" or "SysListView32"* |
| 245 | 08831 | **Control_GetFont()** - *get the currently used font of a control* |
| 246 | 08853 | **IsControlFocused()** - *true/false if a specific control is focused* |
| 247 | 08858 | **getControlNameByHwnd()** - *self explaining* |
| 248 | 08876 | **getByControlName()** - *search by control name return hwnd* |
| 249 | 08910 | **getNextControl()** - *I'm not sure if this feature works could be an AHK code for the Control.GetNextControl method for System.Windows.Forms* |
| 250 | 08961 | **IsControlUnderCursor()** - *Checks if a specific control is under the cursor and returns its ClassNN if it is.* |
| 251 | 08968 | **GetFocusedControl()** - *get focused control from active window -multi Options[ClassNN \ Hwnd \ Text \ List \ All] available* |
| 252 | 09003 | **ControlGetTextExt()** - *3 different variants are tried to determine the text of a control* |
| 253 | 09030 | **getControlInfo()** - *get width and heights of controls* |
| 254 | 09043 | **FocusedControl()** - *returns the HWND of the currently focused control, or 0 if there was a problem* |
| 255 | 09052 | **Control_GetFont()** - *retrieves the used font of a control* |
| 256 | 09064 | **WinForms_GetClassNN()** - *Check which ClassNN an element has* |
| 257 | 09094 | **GetExtraStyle()** - *get Extra Styles from a control* |
| 258 | 09115 | **GetToolbarItems()** - *retrieves the text/names of all items of a toolbar* |
| 259 | 09173 | **ControlGetTabs()** - *retrieves the text of tabs in a tab control* |
| 260 | 09250 | **GetHeaderInfo()** - *Returns an object containing width and text for each item of a remote header control* |
| 261 | 09312 | **WinSaveCheckboxes()** - *save the status of checkboxes in other apps* |
| 262 | 09396 | **GetButtonType()** - *uses the style of a button to get it's name* |
| 263 | 09473 | **HWNDToClassNN()** - *a different approach to get classNN from handle* |
| 264 | 09494 | **IsCheckboxStyle()** - *checks style(code) if it's a checkbox* |
| 265 | 09539 | **Control_GetFont()** - *Given an handle to a GuiControl, Control_GetFont() will return the Fontname & Fontsize* |
| 266 | 09574 | **IsOverTitleBar()** - *WM_NCHITTEST wrapping: what's under a screen point?* |
| 267 | 09584 | **WinGetPosEx()** - *gets the position, size, and offset of a window* |
| 268 | 09757 | **GetParent()** - *get parent win handle of a window* |
| 269 | 09763 | **GetWindow()** - *DllCall wrapper for GetWindow function* |
| 270 | 09769 | **GetForegroundWindow()** - *returns handle of the foreground window* |
| 271 | 09773 | **IsWindowVisible()** - *self explaining* |
| 272 | 09777 | **IsFullScreen()** - *specific window is a fullscreen window?* |
| 273 | 09784 | **IsClosed()** - *AHK function (WinWaitClose) wrapper* |
| 274 | 09791 | **GetClassLong()** |
| 275 | 09798 | **GetWindowLong()** |
| 276 | 09805 | **GetClassStyles()** |
| 277 | 09832 | **GetTabOrderIndex()** |
| 278 | 09859 | **GetCursor()** |
| 279 | 09866 | **GetClientCoords()** |
| 280 | 09876 | **GetClientSize()** - *get size of window without border* |
| 281 | 09884 | **GetWindowCoords()** |
| 282 | 09891 | **GetWindowPos()** |
| 283 | 09901 | **GetWindowPlacement()** - *Gets window position using workspace coordinates (-> no taskbar), returns an object* |
| 284 | 09915 | **GetWindowInfo()** - *returns an Key:Val Object with the most informations about a window (Pos, Client Size, Style, ExStyle, Border size...)* |
| 285 | 09937 | **GetOwner()** |
| 286 | 09941 | **FindWindow()** - *Finds the requested window,and return it's ID* |
| 287 | 09997 | **FindWindow()** - *Finds the first window matching specific criterias.* |
| 288 | 10027 | **ShowWindow()** - *uses a DllCall to show a window* |
| 289 | 10031 | **IsWindow()** - *wrapper for IsWindow DllCall* |
| 290 | 10035 | **GetClassName()** - *wrapper for AHK WinGetClass function* |
| 291 | 10040 | **FindChildWindow()** - *finds childWindow Hwnds of the parent window* |
| 292 | 10106 | **EnumChildWindow()** - *sub function of FindChildWindow* |
| 293 | 10122 | **WinGetMinMaxState()** - *get state if window ist maximized or minimized* |
| 294 | 10150 | **GetBgBitMapHandle()** - *returns the handle of a background bitmap in a gui* |
| 295 | 10156 | **GetLastActivePopup()** - *passes the handle of the last active pop-up window of a parent window* |
| 296 | 10160 | **GetFreeGuiNum()** - *gets a free gui number.* |
| 297 | 10176 | **IsWindowUnderCursor()** - *Checks if a specific window is under the cursor.* |
| 298 | 10184 | **GetCenterCoords()** - *?center a gui between 2 monitors?* |
| 299 | 10205 | **RMApp_NCHITTEST()** - *Determines what part of a window the mouse is currently over* |
| 300 | 10219 | **GetCPA_file_name()** - *retrieves Control Panel applet icon* |
| 301 | 10251 | **WinGetClientPos()** - *gives back the coordinates of client area inside a gui/window - with DpiFactor correction* |
| 302 | 10289 | **CheckWindowStatus()** - *check's if a window is responding or not responding (hung or crashed) -* |
| 303 | 10324 | **GetWindowOrder()** - *determines the window order for a given (parent-)hwnd* |
| 304 | 10359 | **EnumWindows()** - *Get a list with all the top-level windows on the screen or controls in the window* |
| 305 | 10413 | **WinEnum()** - *wrapper for Enum(Child)Windows from cocobelgica. a different solution to that one I collected before* |
| 306 | 10475 | **WinWaitProgress()** - *Waits for the progress bar on a window to reach (>=) a given value (a Lexikos function)* |
| 307 | 10513 | **ControlGetProgress()** - *sub function of WinWaitProgress* |
| 308 | 10518 | **GetClassNN()** - *sub function of FindChildWindow* |
| 309 | 10531 | **GetClassNN_EnumChildProc()** - *sub function of FindChildWindow* |
| 310 | 10543 | **ChooseColor()** - *what is this for?* |
| 311 | 10564 | **GetWindowIcon()** |
| 312 | 10644 | **GetStatusBarText()** |
| 313 | 10660 | **GetAncestor()** |
| 314 | 10665 | **MinMaxInfo()** |
| 315 | 10678 | **GetMouseTaskButton()** - *Gets the index+1 of the taskbar button which the mouse is hovering over* |
| 316 | 10784 | **SureControlClick()** - *Window Activation + ControlDelay to -1 + checked if control received the click* |
| 317 | 10801 | **SureControlCheck()** - *Window Activation + ControlDelay to -1 + Check if the control is really checked now* |
| 318 | 10822 | **ControlClick2()** - *ControlClick Double Click* |
| 319 | 10832 | **ControlFromPoint()** - *returns the hwnd of a control at a specific point on the screen* |
| 320 | 10872 | **EnumChildFindPoint()** - *this function is required by ControlFromPoint* |
| 321 | 10911 | **ControlDoubleClick()** - *simulates a double click on a control with left/middle or right mousebutton* |
| 322 | 10931 | **WinWaitForMinimized()** - *waits until the window is minimized* |
| 323 | 10949 | **CenterWindow()** - *Given a the window's width and height, calculates where to position its upper-left corner so that it is centered EVEN IF the task bar is on the left side or top side of the window* |
| 324 | 10988 | **GuiCenterButtons()** - *Center and resize a row of buttons automatically* |
| 325 | 11040 | **CenterControl()** - *Centers one control* |
| 326 | 11091 | **SetWindowIcon()** |
| 327 | 11097 | **SetWindowPos()** |
| 328 | 11101 | **TryKillWin()** |
| 329 | 11119 | **Win32_SendMessage()** - *Closing a window through sendmessage command* |
| 330 | 11131 | **Win32_TaskKill()** |
| 331 | 11140 | **Win32_Terminate()** |
| 332 | 11151 | **TabActivate()** |
| 333 | 11159 | **FocuslessScroll()** |
| 334 | 11260 | **FocuslessScrollHorizontal()** |
| 335 | 11294 | **Menu_Show()** - *alternate to Menu, Show , which can display menu without blocking monitored messages...* |
| 336 | 11316 | **CatMull_ControlMove()** - *Moves the mouse through 4 points (without control point "gaps")* |
| 337 | 11336 | **GUI_AutoHide()** - *Autohide the GUI function* |
| 338 | 11603 | **SetButtonF()** - *Set a button control to call a function instead of a label subroutine* |
| 339 | 11697 | **AddToolTip()** - *Add/Update tooltips to GUI controls.* |
| 340 | 11830 | **NumPut()** - *cbSize* |
| 341 | 11831 | **NumPut()** - *uFlags* |
| 342 | 11832 | **NumPut()** - *hwnd* |
| 343 | 11833 | **NumPut()** - *uId* |
| 344 | 11883 | **HelpToolTips()** - *To show defined GUI control help tooltips on hover.* |
| 345 | 11914 | **DisableFadeEffect()** - *disabling fade effect on gui animations* |
| 346 | 11938 | **SetWindowTransistionDisable()** - *disabling fade effect only the window of choice* |
| 347 | 11972 | **DisableMinimizeAnim()** - *disables or restores original minimize anim setting* |
| 348 | 11992 | **DisableCloseButton()** - *to disable/grey out the close button* |
| 349 | 12001 | **AutoCloseBlockingWindows()** - *close all open popup (childwindows), without knowing their names, of a parent window* |
| 350 | 12090 | **WinActivateEx()** - *Activate a Window, with extra Error Checking and More Features* |
| 351 | 12127 | **ClickOK()** - *function that search for any button in a window that might be an 'Ok' button to close a window dialog* |
| 352 | 12193 | **ControlSelectTab()** - *SendMessage wrapper to select the current tab on a MS Tab Control.* |
| 353 | 12212 | **SetParentByClass()** - *set parent window by using its window class* |
| 354 | 12220 | **MoveTogether()** - *move 2 windows together - using DllCall to DeferWindowPos* |
| 355 | 12306 | **WinWaitCreated()** - *Wait for a window to be created, returns 0 on timeout and ahk_id otherwise* |
| 356 | 12340 | **closeContextMenu()** - *a smart way to close a context menu* |
| 357 | 12357 | **SetWindowTheme()** - *set Windows UI Theme by window handle* |
| 358 | 12373 | **HideFocusBorder()** - *hides the focus border for the given GUI control or GUI and all of its children* |
| 359 | 12417 | **unmovable()** - *makes Gui unmovable* |
| 360 | 12428 | **movable()** - *makes Gui movable* |
| 361 | 12435 | **GuiDisableMove()** - *to fix a gui/window to its coordinates* |
| 362 | 12441 | **WinInsertAfter()** - *insert a window after a specific window handle* |
| 363 | 12458 | **CenterWindow()** - *center a window or set position optional by using Top, Left, Right, Bottom or a combination of it* |
| 364 | 12501 | **SetHoverText()** - *change control's text on mouseover* |
| 365 | 12582 | **SetTextAndResize()** - *resizes a control to adapt to updated values* |
| 366 | 12648 | **GetMenu()** - *returns hMenu handle* |
| 367 | 12653 | **GetSubMenu()** |
| 368 | 12657 | **GetMenuItemCount()** |
| 369 | 12661 | **GetMenuItemID()** |
| 370 | 12665 | **GetMenuString()** |
| 371 | 12680 | **MenuGetAll()** - *this function and MenuGetAll_sub return all Menu commands from the choosed menu* |
| 372 | 12689 | **MenuGetAll_sub()** - *described above* |
| 373 | 12712 | **GetContextMenuState()** - *returns the state of a menu entry* |
| 374 | 12750 | **GetContextMenuID()** - *returns the ID of a menu entry* |
| 375 | 12773 | **GetContextMenuText()** - *returns the text of a menu entry (standard windows context menus only!!!)* |
| 376 | 12831 | **Menu_AssignBitmap()** - *assign bitmap to any item in any AHk menu* |
| 377 | 12991 | **InvokeVerb()** - *executes the context menu item of the given path* |
| 378 | 13069 | **Menu_Show()** - *its an alternative to Menu, Show, which can display menu without blocking monitored messages* |
| 379 | 13099 | **CreateMenu()** - *creates menu from a string in which each item is placed in new line and hierarchy is defined by Tab character on the left (indentation)* |
| 380 | 13230 | **CreateDDMenu()** - *Creates menu from a string in which each item is placed in new line and hierarchy is defined by Tab character on the left (indentation)* |
| 381 | 13385 | **ExtractIcon()** - *extract icon from a resource file* |
| 382 | 13465 | **GetIconSize()** - *determines the size of the icon (Lexikos function)* |
| 383 | 13501 | **Gdip_GetHICONDimensions()** - *get icon dimensions* |
| 384 | 13540 | **SetTrayIcon()** - *sets a hex coded icon to as try icon* |
| 385 | 13582 | **InvokeVerb()** - *Executes the context menu item of the given path* |
| 386 | 13659 | **Function_Eject()** - *ejects a drive medium* |
| 387 | 13691 | **FileGetDetail()** - *Get specific file property by index* |
| 388 | 13702 | **FileGetDetails()** - *Create an array of concrete file properties* |
| 389 | 13718 | **DirExist()** - *Checks if a directory exists* |
| 390 | 13722 | **GetDetails()** - *Create an array of possible file properties* |
| 391 | 13736 | **Start()** - *Start programs or scripts easier* |
| 392 | 13755 | **IsFileEqual()** - *Returns whether or not two files are equal* |
| 393 | 13763 | **WatchDirectory()** - *Watches a directory/file for file changes* |
| 394 | 13912 | **WatchDirectory()** - *it's different from above not tested* |
| 395 | 14109 | **GetFileIcon()** |
| 396 | 14122 | **ExtractAssociatedIcon()** - *Extracts the associated icon's index for the file specified in path* |
| 397 | 14136 | **ExtractAssociatedIconEx()** - *Extracts the associated icon's index and ID for the file specified in path* |
| 398 | 14149 | **DestroyIcon()** |
| 399 | 14153 | **listfunc()** - *list all functions inside ahk scripts* |
| 400 | 14169 | **CreateOpenWithMenu()** - *creates an 'open with' menu for the passed file.* |
| 401 | 14321 | **FileCount()** - *count matching files in the working directory* |
| 402 | 14329 | **GetImageTypeW()** - *Identify the image type (UniCode)* |
| 403 | 14373 | **FileWriteLine()** - *to write data at specified line in a file.* |
| 404 | 14383 | **FileMD5()** - *file MD5 hashing* |
| 405 | 14399 | **FileCRC32()** - *computes and returns CRC32 hash for a File passed as parameter* |
| 406 | 14417 | **FindFreeFileName()** - *Finds a non-existing filename for Filepath by appending a number in brackets to the name* |
| 407 | 14430 | **CountFilesR()** - *count files recursive in specific folder (uses COM method)* |
| 408 | 14439 | **CountFiles()** - *count files in specific folder (uses COM method)* |
| 409 | 14445 | **PathInfo()** - *splits a given path to return as object* |
| 410 | 14450 | **DriveSpace()** - *retrieves the DriveSpace* |
| 411 | 14458 | **GetBinaryType()** - *determines the bit architecture of an executable program* |
| 412 | 14468 | **GetFileAttributes()** - *get attributes of a file or folder* |
| 413 | 14507 | **SetFileTime()** - *to set the time* |
| 414 | 14516 | **SetFileAttributes()** - *set attributes of a file or folder* |
| 415 | 14554 | **FileSetSecurity()** - *set security for the file / folder* |
| 416 | 14608 | **FileSetOwner()** - *set the owner to file / directory* |
| 417 | 14628 | **FileGetOwner()** - *get the owner to file / directory* |
| 418 | 14645 | **GetFileFormat()** - *retreaves the codepage format of a file* |
| 419 | 14665 | **HashFile()** - *calculate hashes (MD2,MD5,SH1,SHA256, SHA384, SHA512) from file* |
| 420 | 14776 | **PathCombine()** - *combine the 2 routes provided in a single absolute path* |
| 421 | 14800 | **GetParentDir()** - *small RegEx function to get parent dir from a given string* |
| 422 | 14804 | **DirGetParent()** - *returns a string containing parent dir, it's possible to set the level of parent dir* |
| 423 | 14814 | **SelectFolder()** - *the common File Dialog lets you add controls to it* |
| 424 | 14898 | **Filexpro()** - *retreaves file extended properties Object* |
| 425 | 15069 | **CreateFont()** - *creates font in memory which can be used with any API function accepting font handles* |
| 426 | 15122 | **GetHFONT()** - *gets a handle to a font used in a AHK gui for example* |
| 427 | 15135 | **MsgBoxFont()** - *style your MsgBox with with your prefered font* |
| 428 | 15149 | **GetFontProperties()** - *to get the current font's width and height* |
| 429 | 15195 | **FontEnum()** - *enumerates all uniquely-named fonts in the system that match the font characteristics specified by the LOGFONT structure* |
| 430 | 15235 | **GetFontTextDimension()** - *calculate the height and width of the text in the specified font* |
| 431 | 15267 | **GetStockObject()** - *subfunction of GetFontTextDimension()* |
| 432 | 15288 | **FontClone()** - *backup hFont in memory for further processing* |
| 433 | 15330 | **GuiDefaultFont()** - *returns the default Fontname & Fontsize* |
| 434 | 15366 | **StrGetDimAvgCharWidth()** - *average width of a character in pixels* |
| 435 | 15409 | **CreateFont()** - *creates HFont for use with GDI* |
| 436 | 15440 | **MeasureText()** - *Measures the single-line width and height of the passed text* |
| 437 | 15487 | **GetFontNamesFromFile()** - *get's the name of a font from a .ttf-FontFile* |
| 438 | 15635 | **OnMessageEx()** - *Allows multiple functions to be called automatically when the script receives the specified message* |
| 439 | 15864 | **ReceiveData()** - *By means of OnMessage(), this function has been set up to be called automatically whenever new data arrives on the connection.* |
| 440 | 15904 | **HDrop()** - *Drop files to another app* |
| 441 | 15937 | **WM_MOVE()** - *UpdateLayeredWindow* |
| 442 | 15949 | **WM_WINDOWPOSCHANGING()** - *two different examples of handling a WM_WINDOWPOSCHANGING* |
| 443 | 15979 | **WM_WINDOWPOSCHANGING()** - *second examples of handling a WM_WINDOWPOSCHANGING* |
| 444 | 15997 | **CallNextHookEx()** - *Passes the hook information to the next hook procedure in the current hook chain. A hook procedure can call this function either before or after processing the hook information* |
| 445 | 16001 | **WM_DEVICECHANGE()** - *Detects whether a CD has been inserted instead and also outputs the drive - global drv* |
| 446 | 16040 | **ObjectNameChange()** - *titlebar hook to detect when title changes, (Lexikos' code)* |
| 447 | 16088 | **DownloadFile()** |
| 448 | 16111 | **NewLinkMsg()** |
| 449 | 16127 | **TimeGap()** - *Determine by what amount the local system time differs to that of an ntp server* |
| 450 | 16137 | **GetSourceURL()** |
| 451 | 16149 | **DNS_QueryName()** |
| 452 | 16174 | **GetHTMLFragment()** |
| 453 | 16194 | **ScrubFragmentIdents()** |
| 454 | 16205 | **EnumClipFormats()** |
| 455 | 16214 | **GetClipFormatNames()** |
| 456 | 16232 | **GoogleTranslate()** |
| 457 | 16251 | **getText()** - *get text from html* |
| 458 | 16266 | **getHtmlById()** |
| 459 | 16271 | **getTextById()** |
| 460 | 16275 | **getHtmlByTagName()** |
| 461 | 16283 | **getTextByTagName()** |
| 462 | 16291 | **CreateGist()** |
| 463 | 16313 | **GetAllResponseHeaders()** - *gets the values of all HTTP headers* |
| 464 | 16382 | **NetStat()** - *passes information over network connections similar to the netstat -an CMD command.* |
| 465 | 16480 | **ExtractTableData()** - *extracts tables from HTML files* |
| 466 | 16603 | **IsConnected()** - *Returns true if there is an available internet connection* |
| 467 | 16607 | **HostToIp()** - *gets the IP address for the given host directly using the WinSock 2.0 dll, without using temp files or third party utilities* |
| 468 | 16709 | **LocalIps()** - *with small changes to HostToIP() this can be used to retrieve all LocalIP's* |
| 469 | 16778 | **GetAdaptersInfo()** - *GetAdaptersAddresses function & IP_ADAPTER_ADDRESSES structure* |
| 470 | 16833 | **DNSQuery()** - *retrieve IP adresses or host/domain names from DNS* |
| 471 | 16937 | **RestartNetwork()** - *Restart "Local area connection" without admin privileges* |
| 472 | 17001 | **GetAllResponseHeaders()** - *Returns a string that contains all response headers* |
| 473 | 17105 | **Min()** - *returns the smaller of 2 numbers* |
| 474 | 17109 | **Max()** - *determines the larger number* |
| 475 | 17113 | **Mean()** - *returns Average values in comma delimited list* |
| 476 | 17127 | **Median()** - *returns Median in a set of numbers from a list* |
| 477 | 17154 | **Mode()** - *returns the mode from a list of numbers* |
| 478 | 17183 | **Dec2Base()** - *Base to Decimal and* |
| 479 | 17189 | **Base2Dec()** - *Decimal to Base conversion* |
| 480 | 17195 | **HexToFloat()** - *Hexadecimal to Float conversion* |
| 481 | 17199 | **FloatToHex()** - *Float to Hexadecimal conversion* |
| 482 | 17209 | **CalculateDistance()** - *calculates the distance between two points in a 2D-Space* |
| 483 | 17213 | **IsInRange()** - *shows if a second variable is in range* |
| 484 | 17224 | **FormatFileSize()** - *Formats a file size in bytes to a human-readable size string* |
| 485 | 17232 | **Color_RGBtoHSV()** - *converts beetween color two color spaces: RGB -> HSV* |
| 486 | 17262 | **Color_HSVtoRGB()** - *converts beetween color two color spaces: HSV -> RGB* |
| 487 | 17333 | **JEE_HexToBinData()** - *hexadecimal to binary* |
| 488 | 17343 | **JEE_BinDataToHex()** - *binary to hexadecimal* |
| 489 | 17354 | **JEE_BinDataToHex2()** - *binary to hexadecimal2* |
| 490 | 17362 | **RadianToDegree()** - *convert radian (rad) to degree* |
| 491 | 17375 | **DegreeToRadian()** - *convert degree to radian (rad)* |
| 492 | 17389 | **RGBToARGB()** - *convert RGB to ARGB* |
| 493 | 17416 | **ARGBToRGB()** - *convert ARGB to RGB.* |
| 494 | 17435 | **FormatByteSize()** - *give's back the given bytes in KB, MB, GB .... (for AHK_V1)* |
| 495 | 17465 | **FormatByteSize()** - *give's back the given bytes in KB, MB, GB ....(for AHK_V2)* |
| 496 | 17506 | **ObjMerge()** - *merge two objects* |
| 497 | 17521 | **evalRPN()** - *Parsing/RPN calculator algorithm* |
| 498 | 17559 | **StackShow()** |
| 499 | 17566 | **ExploreObj()** - *print object function* |
| 500 | 17622 | **KeyValueObjectFromLists()** - *merge two lists into one key-value object, useful for 2 two lists you retreave from WinGet* |
| 501 | 17689 | **GetCallStack()** - *retrieves the current callstack* |
| 502 | 17763 | **Traceback()** - *get stack trace* |
| 503 | 17853 | **Sort2DArray()** - *a two dimensional TDArray* |
| 504 | 17874 | **SortArray()** - *ordered sort: Ascending, Descending, Reverse* |
| 505 | 17907 | **QuickSort()** - *Sort array using QuickSort algorithm* |
| 506 | 18042 | **QuickAux()** - *subfunction of Quicksort* |
| 507 | 18120 | **Cat()** - *subfunction of Quicksort* |
| 508 | 18135 | **CatCol()** - *subfunction of Quicksort* |
| 509 | 18168 | **sortArray()** - *sorts an array (another way)* |
| 510 | 18249 | **StringMD5()** - *String MD5 Hashing* |
| 511 | 18259 | **uriEncode()** - *a function to escape characters like & for use in URLs.* |
| 512 | 18274 | **Ansi2Unicode()** - *easy convertion from Ansi to Unicode, you can set prefered codepage* |
| 513 | 18294 | **Unicode2Ansi()** - *easy convertion from Unicode to Ansi, you can set prefered codepage* |
| 514 | 18318 | **Ansi2Oem()** - *using Ansi2Unicode and Unicode2Ansi functions* |
| 515 | 18324 | **Oem2Ansi()** - *using Ansi2Unicode and Unicode2Ansi functions* |
| 516 | 18330 | **Ansi2UTF8()** - *using Ansi2Unicode and Unicode2Ansi functions* |
| 517 | 18336 | **UTF82Ansi()** - *using Ansi2Unicode and Unicode2Ansi functions* |
| 518 | 18342 | **CRC32()** - *CRC32 function, uses MCode* |
| 519 | 18357 | **ParseJsonStrToArr()** - *Parse Json string to an array* |
| 520 | 18383 | **parseJSON()** - *Parse Json string to an object* |
| 521 | 18404 | **GetNestedTag()** |
| 522 | 18434 | **GetHTMLbyID()** - *uses COM* |
| 523 | 18449 | **GetHTMLbyTag()** - *uses COM* |
| 524 | 18464 | **GetXmlElement()** - *RegEx function* |
| 525 | 18482 | **sXMLget()** - *simple solution to get information out of xml and html* |
| 526 | 18500 | **cleanlines()** - *removes all empty lines* |
| 527 | 18513 | **cleancolon()** - *what for? removes on ':' at beginning of a string* |
| 528 | 18523 | **cleanspace()** - *removes all Space chars* |
| 529 | 18536 | **SplitLine()** - *split string to key and value* |
| 530 | 18546 | **EnsureEndsWith()** - *Ensure that the string given ends with a given char* |
| 531 | 18554 | **EnsureStartsWith()** - *Ensure that the string given starts with a given char* |
| 532 | 18561 | **StrPutVar()** - *Convert the data to some Enc, like UTF-8, UTF-16, CP1200 and so on* |
| 533 | 18586 | **RegExSplit()** - *split a String by a regular expressin pattern and you will receive an array as a result* |
| 534 | 18611 | **ExtractSE()** - *subfunction of RegExSplit* |
| 535 | 18619 | **StringM()** - *String manipulation with many options is using RegExReplace  (bloat, drop, Flip, Only, Pattern, Repeat, Replace, Scramble, Split)* |
| 536 | 18659 | **StrCount()** - *a very handy function to count a needle in a Haystack* |
| 537 | 18666 | **SuperInstr()** - *Returns min/max position for a | separated values of Needle(s)* |
| 538 | 18695 | **LineDelete()** - *deletes a specific line or a range of lines from a variable containing one or more lines of text. No use of any loop!* |
| 539 | 18771 | **GetWordsNumbered()** - *gives back an array of words from a string, you can specify the position of the words you want to keep* |
| 540 | 18803 | **AddTrailingBackslash()** - *adds a backslash to the beginning of a string if there is none* |
| 541 | 18811 | **CheckQuotes()** |
| 542 | 18820 | **ReplaceForbiddenChars()** - *hopefully working, not tested function, it uses RegExReplace* |
| 543 | 18832 | **WrapText()** - *basic function to wrap a text-string to a given length* |
| 544 | 18870 | **ExtractFuncTOuserAHK()** - *extract user function and helps to write it to userAhk.api* |
| 545 | 18991 | **PdfToText()** - *copies a selected PDF file to memory - it needs xpdf - pdftotext.exe* |
| 546 | 19018 | **PdfPageCounter()** - *counts pages of a pdffile (works with 95% of pdf files)* |
| 547 | 19034 | **PasteWithIndent()** - *paste string to an editor with your prefered indent key* |
| 548 | 19050 | **Ask_and_SetbackFocus()** - *by opening a msgbox you lost focus and caret pos in any editor - this func will restore the previous positions of the caret* |
| 549 | 19098 | **CleanLine()** - *Return a line with leading and trailing spaces removed, and tabs converted to spaces* |
| 550 | 19120 | **StrTrim()** - *Remove all leading and trailing whitespace including tabs, spaces, CR and LF* |
| 551 | 19141 | **StrDiff()** - *SIFT3 : Super Fast and Accurate string distance algorithm* |
| 552 | 19209 | **PrintArr()** - *show values of an array in a listview gui for debugging* |
| 553 | 19251 | **List2Array()** - *function uses StrSplit () to return an array* |
| 554 | 19255 | **Array_Gui()** - *shows your array as an interactive TreeView* |
| 555 | 19317 | **RandomString()** - *builds a string with random char of specified length* |
| 556 | 19327 | **PrintStr()** - *Prints the passed string on the default printer* |
| 557 | 19361 | **()** - *Join* |
| 558 | 19487 | **NumStr()** - *Use to format a float or to pad leading characters (any character!) to a numeric string* |
| 559 | 19526 | **SetWidth()** - *increases a string's length by adding spaces to it and aligns it Left/Center/Right* |
| 560 | 19570 | **Replicate()** - *replicates one char x-times* |
| 561 | 19595 | **Space()** - *generates a string containing only spaces* |
| 562 | 19622 | **SoundExC()** - *phonetic algorithm for indexing names by sound* |
| 563 | 19737 | **DelaySend()** - *Send keystrokes delayed* |
| 564 | 19783 | **SetLayout()** - *set a keyboard layout* |
| 565 | 19788 | **GetAllInputChars()** - *Returns a string with input characters* |
| 566 | 19798 | **ReleaseModifiers()** - *helps to solve the Hotkey stuck problem* |
| 567 | 19845 | **isaKeyPhysicallyDown()** - *belongs to ReleaseModifiers() function* |
| 568 | 19858 | **GetText()** - *copies the selected text to a variable while preserving the clipboard.(Ctrl+C method)* |
| 569 | 19875 | **PutText()** - *Pastes text from a variable while preserving the clipboard. (Ctrl+v method)* |
| 570 | 19887 | **Hotkeys()** - *a handy function to show all used hotkeys in script* |
| 571 | 19938 | **BlockKeyboard()** - *block keyboard, and unblock it through usage of keyboard* |
| 572 | 19987 | **RapidHotkey()** - *Using this function you can send keystrokes or launch a Label by pressing a key several times.* |
| 573 | 20133 | **hk()** - *Disable all keyboard buttons* |
| 574 | 20229 | **ShowTrayBalloon()** |
| 575 | 20255 | **ColoredTooltip()** - *show a tooltip for a given time with a custom color in rgb format (fore and background is supported). This function shows how to obtain the hWnd of the tooltip.* |
| 576 | 20302 | **AddToolTip()** - *very easy to use function to add a tooltip to a control* |
| 577 | 20573 | **AddToolTip()** - *add ToolTips to controls - Advanced ToolTip features + Unicode* |
| 578 | 21168 | **AddToolTip()** - *just a simple add on to allow tooltips to be added to controls without having to monitor the wm_mousemove messages* |
| 579 | 21239 | **AddToolTip()** - *this is a function from jballi -* |
| 580 | 21371 | **NumPut()** - *cbSize* |
| 581 | 21372 | **NumPut()** - *uFlags* |
| 582 | 21373 | **NumPut()** - *hwnd* |
| 583 | 21374 | **NumPut()** - *uId* |
| 584 | 21432 | **CreateNamedPipe()** - *creates an instance of a named pipe and returns a handle for subsequent pipe operations* |
| 585 | 21437 | **RestoreCursors()** - *for normal cursor at GUI* |
| 586 | 21442 | **SetSystemCursor()** - *enables an application to customize the system cursors by using a file or by using the system cursor* |
| 587 | 21523 | **SystemCursor()** - *hiding mouse cursor* |
| 588 | 21562 | **ToggleSystemCursor()** - *choose a cursor from system cursor list* |
| 589 | 21641 | **SetTimerF()** - *Starts a timer that can call functions and object methods* |
| 590 | 21678 | **GlobalVarsScript()** |
| 591 | 21702 | **patternScan()** - *scan for a pattern in memory* |
| 592 | 21801 | **scanInBuf()** - *scan for a pattern in memory buffer* |
| 593 | 21839 | **hexToBinaryBuffer()** |
| 594 | 21862 | **RegRead64()** - *Provides RegRead64() function that do not redirect to Wow6432Node on 64-bit machines (for ansi- and unicode)* |
| 595 | 21955 | **RegWrite64()** - *RegWrite64() function that do not redirect to Wow6432Node on 64-bit machines* |
| 596 | 22028 | **KillProcess()** - *uses DllCalls to end a process* |
| 597 | 22061 | **LoadScriptResource()** - *loads a resource into memory (e.g. picture, scripts..)* |
| 598 | 22106 | **HIconFromBuffer()** - *Function provides a HICON handle e.g. from a resource previously loaded into memory (LoadScriptResource)* |
| 599 | 22121 | **hBMPFromPNGBuffer()** - *Function provides a hBitmap handle e.g. from a resource previously loaded into memory (LoadScriptResource)* |
| 600 | 22155 | **SaveSetColours()** - *Sys colours saving adapted from an approach found in Bertrand Deo's code* |
| 601 | 22189 | **ChangeMacAdress()** - *change MacAdress, it makes changes to the registry!* |
| 602 | 22244 | **ListAHKStats()** - *Select desired section: ListLines, ListVars, ListHotkeys, KeyHistory* |
| 603 | 22309 | **MouseExtras()** - *Allows to use subroutines for Holding and Double Clicking a Mouse Button.* |
| 604 | 22388 | **TimedFunction()** - *SetTimer functionality for functions* |
| 605 | 22415 | **ListGlobalVars()** - *ListGlobalVars() neither shows nor activates the AutoHotkey main window, it returns a string* |
| 606 | 22465 | **TaskList()** - *list all running tasks (no use of COM)* |
| 607 | 22516 | **MouseDpi()** - *Change the current dpi setting of the mouse* |
| 608 | 22536 | **SendToAHK()** - *Sends strings by using a hidden gui between AHK scripts* |
| 609 | 22565 | **ReceiveFromAHK()** - *Receiving strings from SendToAHK* |
| 610 | 22594 | **GetUIntByAddress()** - *get UInt direct from memory. I found this functions only within one script* |
| 611 | 22608 | **SetUIntByAddress()** - *write UInt direct to memory* |
| 612 | 22623 | **SetRestrictedDacl()** - *run this in your script to hide it from Task Manager* |
| 613 | 22710 | **getActiveProcessName()** - *this function finds the process to the 'ForegroundWindow'* |
| 614 | 22725 | **enumChildCallback()** - *i think this retreave's the child process ID for a known gui hwnd and the main process ID* |
| 615 | 22732 | **GetDllBase()** |
| 616 | 22754 | **getProcBaseFromModules()** |
| 617 | 22811 | **InjectDll()** - *injects a dll to a running process (ahkdll??)* |
| 618 | 22836 | **getProcessBaseAddress()** - *gives a pointer to the base address of a process for further memory reading* |
| 619 | 22852 | **LoadFile()** - *Loads a script file as a child process and returns an object* |
| 620 | 22943 | **ReadProcessMemory()** - *reads data from a memory area in a given process.* |
| 621 | 22967 | **WriteProcessMemory()** - *writes data to a memory area in a specified process. the entire area to be written must be accessible or the operation will fail* |
| 622 | 22986 | **CopyMemory()** - *Copy a block of memory from one place to another* |
| 623 | 22996 | **MoveMemory()** - *moves a block memory from one place to another* |
| 624 | 23004 | **FillMemory()** - *fills a block of memory with the specified value* |
| 625 | 23009 | **ZeroMemory()** - *fills a memory block with zeros* |
| 626 | 23013 | **CompareMemory()** - *compare two memory blocks* |
| 627 | 23030 | **VirtualAlloc()** - *changes the state of a region of memory within the virtual address space of a specified process. the memory is assigned to zero.AtEOF* |
| 628 | 23074 | **VirtualFree()** - *release a region of pages within the virtual address space of the specified process* |
| 629 | 23088 | **ReduceMem()** - *reduces usage of memory from calling script* |
| 630 | 23109 | **GlobalLock()** - *memory management functions* |
| 631 | 23127 | **LocalFree()** - *free a locked memory object* |
| 632 | 23134 | **CreateStreamOnHGlobal()** - *creates a stream object that uses an HGLOBAL memory handle to store the stream contents. This object is the OLE-provided implementation of the IStream interface.* |
| 633 | 23139 | **CoTaskMemFree()** - *releases a memory block from a previously assigned task through a call to the CoTaskMemAlloc () or CoTaskMemAlloc () function.* |
| 634 | 23145 | **CoTaskMemAlloc()** - *assign a working memory block* |
| 635 | 23154 | **CoTaskMemRealloc()** - *change the size of a previously assigned block of working memory* |
| 636 | 23164 | **VarAdjustCapacity()** - *adjusts the capacity of a variable to its content* |
| 637 | 23182 | **DllListExports()** - *List of Function exports of a DLL* |
| 638 | 23222 | **RtlUlongByteSwap64()** - *routine reverses the ordering of the four bytes in a 32-bit unsigned integer value (AHK v2)* |
| 639 | 23246 | **RtlUlongByteSwap64()** - *routine reverses the ordering of the four bytes in a 32-bit unsigned integer value (AHK v1)* |
| 640 | 23274 | **PIDfromAnyID()** - *for easy retreaving of process ID's (PID)* |
| 641 | 23325 | **processPriority()** - *retrieves the priority of a process via PID* |
| 642 | 23329 | **GetProcessMemoryInfo()** - *get informations about memory consumption of a process* |
| 643 | 23362 | **SetTimerEx()** - *Similar to SetTimer, but calls a function, optionally with one or more parameters* |
| 644 | 23472 | **DisableFadeEffect()** - *disabling fade effect on gui animations* |
| 645 | 23505 | **GetPriority()** - *ascertains the priority level for an existing process* |
| 646 | 23574 | **ProcessCreationTime()** - *ascertains the creation time for an existing process and returns a time string* |
| 647 | 23632 | **ProcessOwner()** - *returns the Owner for a given Process ID* |
| 648 | 23709 | **UserAccountsEnum()** - *list all users with information* |
| 649 | 23735 | **GetCurrentUserInfo()** - *obtains information from the current user* |
| 650 | 23756 | **GetHandleInformation()** - *obtain certain properties of a HANDLE* |
| 651 | 23781 | **SetHandleInformation()** - *establishes the properties of a HANDLE* |
| 652 | 23796 | **GetPhysicallyInstalledSystemMemory()** - *recovers the amount of RAM in physically installed KB from the SMBIOS (System Management BIOS) firmware tables, WIN_V SP1+* |
| 653 | 23807 | **GlobalMemoryStatus()** - *retrieves information about the current use of physical and virtual memory of the system* |
| 654 | 23823 | **GetSystemFileCacheSize()** - *retrieves the current size limits for the working set of the system cache* |
| 655 | 23835 | **Is64bitProcess()** - *check if a process is running in 64bit* |
| 656 | 23847 | **getSessionId()** - *this functions finds out ID of current session* |
| 657 | 23874 | **CreatePropertyCondition()** - *I hope this one works* |
| 658 | 23890 | **CreatePropertyCondition()** - *I hope this one is better* |
| 659 | 23923 | **CreatePropertyConditionEx()** |
| 660 | 23953 | **UIAgetControlNameByHwnd()** |
| 661 | 23965 | **MouseGetText()** - *get the text in the specified coordinates, function uses Microsoft UIA* |
| 662 | 24033 | **Acc_Get()** |
| 663 | 24085 | **Acc_Error()** |
| 664 | 24090 | **Acc_ChildrenByRole()** |
| 665 | 24132 | **listAccChildProperty()** |
| 666 | 24179 | **GetInfoUnderCursor()** - *retreavies ACC-Child under cursor* |
| 667 | 24187 | **GetAccPath()** - *get the Acc path from (child) handle* |
| 668 | 24202 | **GetEnumIndex()** - *for Acc child object* |
| 669 | 24217 | **GetElementByName()** - *search for one element by name* |
| 670 | 24234 | **IEGet()** - *AutoHotkey_L* |
| 671 | 24242 | **IEGet()** - *AutoHotkey_Basic* |
| 672 | 24256 | **WBGet()** - *AHK_L: based on ComObjQuery docs* |
| 673 | 24270 | **WBGet()** - *AHK_Basic: based on Sean's GetWebBrowser function* |
| 674 | 24284 | **WBGet()** - *based on ComObjQuery docs* |
| 675 | 24302 | **IE_TabActivateByName()** - *activate a TAB by name in InternetExplorer* |
| 676 | 24318 | **IE_TabActivateByHandle()** - *activates a tab by hwnd in InternetExplorer* |
| 677 | 24337 | **IE_TabWinID()** - *find the HWND of an IE window with a given tab name* |
| 678 | 24357 | **ReadProxy()** - *reads the proxy settings from the windows registry* |
| 679 | 24365 | **IE_getURL()** - *using shell.application* |
| 680 | 24378 | **ACCTabActivate()** - *activate a Tab in IE - function uses acc.ahk library* |
| 681 | 24393 | **TabActivate()** - *a different approach to activate a Tab in IE - function uses acc.ahk library* |
| 682 | 24411 | **ComVar()** - *Creates an object which can be used to pass a value ByRef.* |
| 683 | 24428 | **ComVarGet()** - *Called when script accesses an unknown field.* |
| 684 | 24433 | **ComVarSet()** - *Called when script sets an unknown field.* |
| 685 | 24438 | **GetScriptVARs()** - *returns a key, value array with all script variables (e.g. for debugging purposes)* |
| 686 | 24489 | **Valueof()** - *Super Variables processor by Avi Aryan, overcomes the limitation of a single level ( return %var% ) in nesting variables* |
| 687 | 24544 | **type()** - *Object version: Returns the type of a value: "Integer", "String", "Float" or "Object"* |
| 688 | 24568 | **type()** - *COM version: Returns the type of a value: "Integer", "String", "Float" or "Object"* |
| 689 | 24589 | **A_DefaultGui()** - *a nice function to have a possibility to get the number of the default gui* |
| 690 | 24624 | **MCode_Bin2Hex()** - *By Lexikos, http://goo.gl/LjP9Zq* |
| 691 | 24651 | **gcd()** - *MCode GCD - Find the greatest common divisor (GCD) of two numbers* |
| 692 | 24688 | **GetCommState()** - *this function retrieves the configuration settings of a given serial port* |
| 693 | 24802 | **pauseSuspendScript()** - *function to suspend/pause another script* |
| 694 | 24839 | **RtlGetVersion()** - *retrieves version of installed windows system* |
| 695 | 24858 | **PostMessageUnderMouse()** - *Post a message to the window underneath the mouse cursor, can be used to do things involving the mouse scroll wheel* |
| 696 | 24879 | **WM_SETCURSOR()** - *Prevent "sizing arrow" cursor when hovering over window border* |
| 697 | 24896 | **FoxitInvoke()** - *wm_command wrapper for FoxitReader Version:  9.1* |
| 698 | 25140 | **MoveMouse_Spiral()** - *move mouse in a spiral* |
| 699 | 25189 | **ScaleToFit()** - *returns the dimensions of the scaled source rectangle that fits within the destination rectangle* |
| 700 | 25244 | **LockCursorToPrimaryMonitor()** - *prevents the cursor from leaving the primary monitor* |
| 701 | 25292 | **GetCaretPos()** - *Alternative to A_CaretX & A_CaretY (maybe not better)* |
