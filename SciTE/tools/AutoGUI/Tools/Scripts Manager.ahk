; AutoHotkey Scripts Manager
; Tested with AHK v1.1.30.00 Unicode 32/64-bit on Windows XP/7/10

; Credits
; -------
; tmplinshi - Basic Principle:
; https://autohotkey.com/boards/viewtopic.php?f=28&t=24222
; Lexicos - New Process Notifier:
; https://autohotkey.com/board/topic/56984-new-process-notifier/#entry358038
; Sean - Explorer Context Menu:
; https://autohotkey.com/board/topic/20376-invoking-directly-contextmenu-of-files-and-folders/

#SingleInstance Off
#NoEnv
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows On
Menu Tray, Click, 1

Global AppName := "AutoHotkey Scripts Manager"
     , Version := "1.2.6"
     , IniFile
     , Commands := {"Reload Script": 65400
           , "Edit Script": 65401
           , "Suspend Hotkeys": 65404
           , "Pause Script": 65403
           , "Exit Script": 65405
           , "Recent Lines": 65406
           , "Variables": 65407
           , "Hotkeys": 65408
           , "Key history": 65409
           , "AHK User Manual": 65411}
     , hMainWnd
     , hToolbar
     , hLV
     , hSB
     , ImageList
     , AlwaysOnTop
     , HideWhenMinimized
     , Confirm
     , Notifications
     , g_RegEx := "(.:[^:]*\\([^\x22]+))"
     , Sep
     , hShellWnd := CreateShellMenuWindow()
     , g_pIContextMenu
     , g_pIContextMenu2
     , g_pIContextMenu3
     , IconLib := "..\Icons\Scripts Manager.icl"
     , AhkInfo := "AutoHotkey " . A_AhkVersion . " "
     . (A_IsUnicode ? "Unicode " : "ANSI ")
     . (A_PtrSize == 4 ? "32-bit" : "64-bit")

If (FileExist(A_AppData . "\AutoGUI\Scripts Manager.ini")) {
    IniFile := A_AppData . "\AutoGUI\Scripts Manager.ini"
} Else {
    IniFile := A_ScriptDir . "\Scripts Manager.ini"
}

Menu Tray, Icon, %IconLib%

Gui 1: New, +hWndhMainWnd +Resize, %AppName%

AddMenu("ScriptMenu", "&Reload Script`tCtrl+R",, IconLib, 2)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Edit Script`tCtrl+E",, IconLib, 3)
AddMenu("ScriptMenu", "Set &Default Editor...", "SetDefaultEditor", IconLib, 17)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Suspend Hotkeys`tCtrl+S",, IconLib, 4)
AddMenu("ScriptMenu", "&Pause Script`tPause",, IconLib, 5)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "E&xit Script`tDel",, IconLib, 6)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Open Folder`tCtrl+O", "OpenFolder", IconLib, 11)
AddMenu("ScriptMenu", "&Copy Path`tCtrl+P", "CopyPath", IconLib, 12)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "Command Prompt", "CommandPromptHere", IconLib, 14)
AddMenu("ScriptMenu", "Run...", "CopyPath", IconLib, 15)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "Exit Scripts Manager`tEsc", "GuiClose", IconLib, 13)

AddMenu("InspectMenu", "Recent &Lines`tCtrl+L",, IconLib, 7)
AddMenu("InspectMenu", "&Variables`tCtrl+V",, IconLib, 8)
AddMenu("InspectMenu", "&Hotkeys`tCtrl+H",, IconLib, 9)
AddMenu("InspectMenu", "&Key history`tCtrl+K",, IconLib, 10)

Menu EditMenu, Add, Select &All`tCtrl+A, SelectAll
Menu EditMenu, Add
Menu EditMenu, Add, &Find in Files...`tCtrl+F, FindInFiles

Menu ViewMenu, Add, &Refresh Now`tF5, ReloadList

Menu OptionsMenu, Add, Always on Top, SetAlwaysOnTop
Menu OptionsMenu, Add, Hide When Minimized, SetHideWhenMinimized
Menu OptionsMenu, Add, Confirm Reload/Exit, SetConfirm
Menu OptionsMenu, Add, TrayTip Notifications, SetNotifications

AddMenu("HelpMenu", "AHK User &Manual`tF1", "OpenHelpFile", "hh.exe")
Menu HelpMenu, Add
AddMenu("HelpMenu", "&About", "ShowAbout", "user32.dll", 5)

Menu MenuBar, Add, &Script,  :ScriptMenu
Menu MenuBar, Add, &Inspect, :InspectMenu
Menu MenuBar, Add, &Edit,    :EditMenu
Menu MenuBar, Add, &View,    :ViewMenu
Menu MenuBar, Add, &Options, :OptionsMenu
Menu MenuBar, Add, &Help,    :HelpMenu
Gui Menu, MenuBar

IniRead X, %IniFile%, Position, X
IniRead Y, %IniFile%, Position, Y
IniRead W, %IniFile%, Position, Width, 734
IniRead H, %IniFile%, Position, Height, 441
IniRead State, %IniFile%, Position, State, 1

If (FileExist(IniFile)) {
    SetWindowPlacement(hMainWnd, X, Y, W, H, 0)
} Else {
    Gui Show, w%W% h%H% Hide
}

Gui Font, s9, Segoe UI

Gui Add, StatusBar, hWndhSB
GuiControlGet SBPos, Pos, %hSB%

GetClientSize(hMainWnd, WindowW, WindowH)
LVH := WindowH - 28 - SBPosH
Gui Add, ListView, hWndhLV vList gLVHandler x0 y30 h%LVH% w%WindowW% +LV0x14000 AltSubmit, Filename|Path|PID|State

IniRead Columns, %IniFile%, Position, Columns, 177|424|49|79
aCols := StrSplit(Columns, "|")
LV_ModifyCol(1, aCols[1])
LV_ModifyCol(2, aCols[2])
LV_ModifyCol(3, aCols[3] . " Integer")
LV_ModifyCol(4, aCols[4])

ImageList := IL_Create(10)
IL_Add(ImageList, A_AhkPath)
LV_SetImageList(ImageList)

Gui, Add, Custom, ClassToolbarWindow32 hWndhToolbar gToolbarHandler 0x50009901
GoSub SetToolbar

DllCall("ShowWindow", "Ptr", hMainWnd, "UInt", State)

LoadOptions()

RegRead Sep, HKEY_CURRENT_USER\Control Panel\International, sThousand

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLV, "WStr", "Explorer", "Ptr", 0)

; Get WMI service object.
Global winmgmts := ComObjGet("winmgmts:")

LoadList()
UpdateStatusBar()

; Create sink objects for receiving event noficiations.
ComObjConnect(CreateSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessCreate_")
ComObjConnect(DeleteSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessDelete_")

; Set event polling interval, in seconds.
Interval := 1

; Register for process creation notifications:
winmgmts.ExecNotificationQueryAsync(CreateSink
    , "SELECT * FROM __InstanceCreationEvent"
    . " WITHIN " Interval
    . " WHERE TargetInstance ISA 'Win32_Process'"
    . " AND TargetInstance.Name LIKE 'AutoHotkey%'")

; Register for process deletion notifications:
winmgmts.ExecNotificationQueryAsync(DeleteSink
    , "SELECT * FROM __InstanceDeletionEvent"
    . " WITHIN " Interval
    . " WHERE TargetInstance ISA 'Win32_Process'"
    . " AND TargetInstance.Name LIKE 'AutoHotkey%'")

Hotkey IfWinActive, ahk_id %hMainWnd%
Hotkey ^C, CopySelectedItems

Menu Tray, NoStandard
AddMenu("Tray", "Show Window", "ShowMainWindow", IconLib, 1)
Menu Tray, Default, Show Window
Menu Tray, Add
AddMenu("Tray", "Exit", "GuiClose", IconLib, 13)
Menu Tray, Tip, %AppName%

OnMessage(0x16, "SaveSettings") ; WM_ENDSESSION

Return ; End of the auto-execute section

ReloadList() {
    Row := LV_GetNext()

    LV_Delete()
    IL_Destroy(ImageList)
    ImageList := IL_Create(10)
    IL_Add(ImageList, A_AhkPath)
    LV_SetImageList(ImageList)

    LoadList()
    If (Row) {
        LV_Modify(Row, "Select Focus")
    }

    UpdateStatusBar()
}

LoadList() {
    StrQuery := "Select * from Win32_Process Where Name Like 'AutoHotkey%'"
    For Process in winmgmts.ExecQuery(StrQuery) {
        AddToList(Process)
    }
}

GuiSize:
    If (A_EventInfo == 1) {
        If (HideWhenMinimized) {
            WinHide ahk_id %hMainWnd%
        }
        Return
    }

    AutoXYWH("wh", hLV)
    GuiControl Move, %hToolbar%, w%A_GuiWidth%
Return

GuiContextMenu:
    If (A_GuiControl == "List" && Row := LV_GetNext()) {
        LV_GetText(FullPath, Row, 2)
        If (!FileExist(FullPath)) {
            Return
        }

        WorkingDir := GetFileDir(FullPath)

        hShellMenu := GetShellContextMenu(FullPath, GetKeyState("Shift", "P") ? 0x100 : 0) ; CMF_EXTENDEDVERBS
        If (!hShellMenu) {
            Return
        }

        CoordMode Mouse, Screen
        MouseGetPos X, Y

        ItemID := ShowPopupMenu(hShellMenu, 0x100, X, Y, hShellWnd) ; TPM_RETURNCMD
        If (ItemID) {
            Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
            If (Verb == "paste") {
                PasteFile(WorkingDir)
            } Else {
                RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, hMainWnd, X, Y)            
            }
        }

        DestroyShellMenu(hShellMenu)
    }
Return

GuiEscape:
GuiClose:
    DllCall("DestroyWindow", "Ptr", hShellWnd)
    SaveSettings()
    ExitApp

GetSelectedItems() {
    Local Row := 0, Items := []

    While (Row := LV_GetNext(Row)) {
        LV_GetText(Path, Row, 2)
        If (!FileExist(Path)) {
            Continue
        }
        LV_GetText(PID, Row, 3)
        Items.Push({"PID": PID, "Path": Path})
    }

    Return Items
}

MenuHandler:
    MenuItem := StrReplace(RegExReplace(A_ThisMenuItem, "\t.*"), "&")
    ExecCommand(MenuItem)
Return

OpenFolder() {
    Items := GetSelectedItems()
    For Each, Item in Items {
        Filename := Item.Path
        Run *open explorer.exe /select`,"%Filename%"
    }
}

CopyPath() {
    Filenames := ""
    Items := GetSelectedItems()
    For Each, Item in Items {
        Filenames .= Item.Path . "`r`n"
    }
    Clipboard := RTrim(Filenames, "`r`n")
}

CopySelectedItems:
    ControlGet SelectedItems, List, Selected, SysListView321
    Clipboard := SelectedItems
Return

SelectAll:
    GuiControl Focus, %hLV%
    LV_Modify(0, "Select")
Return

GetWindowIconByPID(PID) {
    WinGet WinIDs, List, ahk_class AutoHotkeyGUI ahk_PID %PID%

    Loop %WinIDs% {
        hWnd := WinIDs%A_Index%
        If (!GetOwner(hWnd)) {
            SendMessage 0x7F, 0, 0,, ahk_id %hWnd% ; WM_GETICON
            If (ErrorLevel) {
                Return ErrorLevel
            }
        }
    }

    Return 0
}

GetOwner(hWnd) {
    Return DllCall("GetWindow", "Ptr", hWnd, "UInt", 4, "Ptr") ; GW_OWNER
}

GetScriptState(PID, State) {
    WinGet hWnd, ID, ahk_class AutoHotkey ahk_pid %PID%
    If (WinExist("ahk_id " . hWnd)) {
        SendMessage 0x211, 0, 0,, ahk_id %hWnd% ; WM_ENTERMENULOOP
        SendMessage 0x212, 0, 0,, ahk_id %hWnd% ; WM_EXITMENULOOP
        Command := (State == "S") ? 65404 : 65403
        hMenu := DllCall("GetMenu", "Ptr", hWnd, "Ptr")
        MenuState := DllCall("GetMenuState", "Ptr", hMenu, "UInt", Command, "UInt", 0) ; By command
        Return MenuState & 0x8 ; MF_CHECKED
    } Else {
        Return 0
    }
}

UpdateToolbar() {
    Row := LV_GetNext()
    LV_GetText(PID, Row, 3)
    Suspended := GetScriptState(PID, "S")
    Paused := GetScriptState(PID, "P")

    ; 0x402 = TB_CHECKBUTTON
    SendMessage 0x402, 10004, %Suspended%,, ahk_id %hToolbar%
    SendMessage 0x402, 10005, %Paused%,,    ahk_id %hToolbar%

    State := Paused ? "Paused" : "Running"
    If (Suspended) {
        State .= " with hotkeys suspended"
    }

    LV_Modify(Row, "Col4", State)
}

ShowAbout:
    OnMessage(0x44, "OnMsgBox")
    Gui +OwnDialogs
    MsgBox 0x80, About, %AppName% %Version%
    OnMessage(0x44, "")
Return

OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        hIcon := LoadPicture(IconLib, "w32", _)
        SendMessage 0x172, 1, %hIcon%, Static1 ; STM_SETIMAGE
    }
}

LVHandler:
    If (A_GuiEvent == "C" || A_GuiEvent == "K") {
        UpdateStatusBar()
        UpdateToolbar()
    }
Return

UpdateStatusBar() {
    Row := LV_GetNext()
    If (Row) {
        ;Started:|CPU Usage:|Working Size:|Virtual Size:|32/64-bit (Image Type)
        SB_SetParts(179, 120, 150, 150)

        LV_GetText(PID, Row, 3)

        SB_SetText("CPU Usage: " . GetCPUUsage(PID), 2)

        StrQuery := "SELECT * FROM Win32_Process WHERE ProcessId=" . PID
        QueryEnum := winmgmts.ExecQuery(StrQuery)._NewEnum()
        If (QueryEnum[Process]) {
            CreationDate := Process.CreationDate
            SubStr(CreationDate, 1, InStr(CreationDate, ".") - 1)
            FormatTime CreationDate, %CreationDate% D1 T0 ; Short date and time with seconds

            WorkingSetSize := "Working Size: " . FormatBytes(Process.WorkingSetSize, Sep)
            VirtualSize := "Virtual Size: " . FormatBytes(Process.VirtualSize, Sep)

            SB_SetText("Started: " . CreationDate, 1)
            SB_SetText(WorkingSetSize, 3)
            SB_SetText(VirtualSize, 4)
            SB_SetText(Is32Bit(PID) ? "32-bit" : "64-bit", 5)
        }

    } Else {
        SB_SetParts(179)
        Count := LV_GetCount()
        If (Count) {
            SB_SetText("Scripts: " . Count, 1)
        }

        SB_SetText(AhkInfo, 2)
    }
}

/*
GetCPUUsage(PID) {
    Static Processors := 0

    If (!Processors) {
        ;Sys := winmgmts.ExecQuery("Select * from Win32_ComputerSystem")._NewEnum
        ;Processors := Sys[Sys] ? Sys.NumberOfLogicalProcessors : 1
        For Sys in winmgmts.ExecQuery("Select NumberOfLogicalProcessors from Win32_ComputerSystem") {
            Processors := Sys.NumberOfLogicalProcessors
        }
    }

    StrQuery := "SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfProc_Process WHERE IDProcess = " . PID
    For Process in winmgmts.ExecQuery(StrQuery) {
        CPUUsage := Format("{1:0.2f}", Process.PercentProcessorTime / Processors)
    }

    Return CPUUsage := (CPUUsage) ? CPUUsage : "0.00"
}
*/

GetCPUUsage(PID) {
    CPUUsage := GetProcessTimes(PID)
    If (CPUUsage < 0) { ; First run
        Sleep 125
        CPUUsage := GetProcessTimes(PID)
    }
    
    Return Round(CPUUsage, 2)
}

; Thanks to whoever wrote this function
GetProcessTimes(PID) {
    Static aPIDs := []
    ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage 
    If aPIDs.HasKey(PID) && A_TickCount - aPIDs[PID, "tickPrior"] < 100
        Return aPIDs[PID, "usagePrior"] 
    ; Open a handle with PROCESS_QUERY_INFORMATION access
    If !hProc := DllCall("OpenProcess", "UInt", 0x400, "Int", 0, "Ptr", PID, "Ptr")
        Return -2, aPIDs.HasKey(PID) ? aPIDs.Remove(PID, "") : "" ; Process doesn't exist anymore or don't have access to it.
         
    DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", lpCreationTime, "Int64*", lpExitTime, "Int64*", lpKernelTimeProcess, "Int64*", lpUserTimeProcess)
    DllCall("CloseHandle", "Ptr", hProc)
    DllCall("GetSystemTimes", "Int64*", lpIdleTimeSystem, "Int64*", lpKernelTimeSystem, "Int64*", lpUserTimeSystem)
   
    If aPIDs.HasKey(PID) ; check if previously run
    {
        ; find the total system run time delta between the two calls
        systemKernelDelta := lpKernelTimeSystem - aPIDs[PID, "lpKernelTimeSystem"] ;lpKernelTimeSystemOld
        systemUserDelta := lpUserTimeSystem - aPIDs[PID, "lpUserTimeSystem"] ; lpUserTimeSystemOld
        ; get the total process run time delta between the two calls 
        procKernalDelta := lpKernelTimeProcess - aPIDs[PID, "lpKernelTimeProcess"] ; lpKernelTimeProcessOld
        procUserDelta := lpUserTimeProcess - aPIDs[PID, "lpUserTimeProcess"] ;lpUserTimeProcessOld
        ; sum the kernal + user time
        totalSystem :=  systemKernelDelta + systemUserDelta
        totalProcess := procKernalDelta + procUserDelta
        ; The result is simply the process delta run time as a percent of system delta run time
        result := 100 * totalProcess / totalSystem
    }
    Else result := -1

    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpUserTimeSystem"] := lpUserTimeSystem
    aPIDs[PID, "lpKernelTimeProcess"] := lpKernelTimeProcess
    aPIDs[PID, "lpUserTimeProcess"] := lpUserTimeProcess
    aPIDs[PID, "tickPrior"] := A_TickCount
    Return aPIDs[PID, "usagePrior"] := result 
}

FormatBytes(n, sThousand := ".") {
    If (n > 999) {
        n /= 1024
        Unit := " K"
    } Else {
        Unit := " B"
    }

    a := ""
    Loop % StrLen(n) {
        a .= SubStr(n, 1 - A_Index, 1)
        If (Mod(A_Index, 3) == 0) {
            a .= sThousand
        }
    }

    a := RTrim(a, sThousand)

    b := ""
    Loop % StrLen(a) {
        b .= SubStr(a, 1 - A_Index, 1)
    }

    Return b . Unit
}

Is32Bit(PID) {
    hProc := DllCall("OpenProcess", "UInt", 0x400, "Int", False, "UInt", PID, "Ptr") ; PROCESS_QUERY_INFORMATION

    If (A_Is64bitOS) {
        ; Determines whether the specified process is running under WOW64.
        Try DllCall("IsWow64Process", "Ptr", hProc, "Int*", Is32Bit := True)
    } Else {
        Is32Bit := True
    }

    DllCall("CloseHandle", "Ptr", hProc)

    Return Is32Bit
}

AddMenu(MenuName, MenuItemName := "", Subroutine := "MenuHandler", Icon := "", IconIndex := 1) {
    Menu, %MenuName%, Add, %MenuItemName%, %Subroutine%

    If (Icon != "") {
        Menu, %MenuName%, Icon, %MenuItemName%, %Icon%, %IconIndex%
    }
}

ExecCommand(Command) {
    Static WM_COMMAND := 0x111

    Items := GetSelectedItems()
    If (!Items.Length()) {
        Return
    }

    If ((Command == "Reload Script" || Command == "Exit Script") && !GetKeyState("Shift", "P")) {
        If (Items.Length() > 1) {
            Filename := "the selected scripts"
        } Else {
            LV_GetText(Filename, LV_GetNext(), 1)
        }

        If (Confirm) {
            Action := (SubStr(Command, 1, 1) == "R") ? "reload" : "exit"
            Gui +OwnDialogs
            MsgBox 0x31, %AppName%, % "Are you sure you want to " . Action . " " . Filename . "?"
            IfMsgBox Cancel, Return
        }
    }

    For Each, Item in Items {
        ;OutputDebug % Command . " (" Commands[Command] "), PID: " Item.PID
        PostMessage WM_COMMAND, % Commands[Command],,, % "ahk_class AutoHotkey ahk_pid" . Item.PID

        If (Command == "Suspend Hotkeys" || Command == "Pause Script") {
            UpdateToolbar()
            /*
            If (Command == "Pause Script" && Row := LV_GetNext()) {
                LV_GetText(PID, Row, 3) ; 3 is the PID column
                SB_SetText("CPU Usage: " . GetCPUUsage(PID), 2)
            }
            */
        }
    }

    If (Command == "Exit Script") {
        ReloadList()
    } Else {
        UpdateStatusBar()
    }
}

OpenHelpFile() {
    Run %A_ScriptDir%\..\Help\AutoHotkey.chm
}

SetToolbar:
    TBIL := IL_Create(11)

    IL_Add(TBIL, IconLib, 2)
    IL_Add(TBIL, IconLib, 3)

    IL_Add(TBIL, IconLib, 16)

    IL_Add(TBIL, IconLib, 4)
    IL_Add(TBIL, IconLib, 5)

    IL_Add(TBIL, IconLib, 6)

    IL_Add(TBIL, IconLib, 7)
    IL_Add(TBIL, IconLib, 8)
    IL_Add(TBIL, IconLib, 9)
    IL_Add(TBIL, IconLib, 10)

    IL_Add(TBIL, IconLib, 11)
    IL_Add(TBIL, IconLib, 12)

    IL_Add(TBIL, IconLib, 14)
    IL_Add(TBIL, IconLib, 15)

    Buttons =
    (LTrim
        -
        Reload Script
        Edit Script
        -
        Find in Files
        -
        Suspend Hotkeys
        Pause Script
        -
        Exit Script
        -
        Recent Lines
        Variables
        Hotkeys
        Key History
        -
        Open Folder
        Copy Path
        -
        Command Prompt
        Run...
    )
    Buttons := StrSplit(Buttons, "`n")

    TBBUTTON_Size := A_PtrSize == 8 ? 32 : 20
    cButtons := Buttons.Length()
    VarSetCapacity(TBBUTTONS, TBBUTTON_Size * cButtons , 0)

    Index := 0
    Loop %cButtons% {
        If (Buttons[A_Index] == "-") {
            iBitmap := 0
            idCommand := 0
            fsStyle := 1 ; BTNS_SEP
            iString := -1
        } Else {
            Index++
            iBitmap := Index - 1
            idCommand := 10000 + Index
            fsStyle := 0
            iString := &(ButtonText%Index% := Buttons[A_Index])
        }

        Offset := (A_Index - 1) * TBBUTTON_Size
        NumPut(iBitmap, TBBUTTONS, Offset, "Int") ; iBitmap
        NumPut(idCommand, TBBUTTONS, Offset + 4, "Int") ; idCommand
        NumPut(0x4, TBBUTTONS, Offset + 8, "UChar") ; fsState (TBSTATE_ENABLED)
        NumPut(fsStyle, TBBUTTONS, Offset + 9, "UChar") ; fsStyle
        NumPut(iString, TBBUTTONS, Offset + (A_PtrSize == 8 ? 24 : 16), "Ptr") ; iString
    }

    SendMessage 0x454, 0, 0x9,, ahk_id %hToolbar% ; TB_SETEXTENDEDSTYLE
    SendMessage 0x430, 0, %TBIL%,, ahk_id %hToolbar% ; TB_SETIMAGELIST
    ;SendMessage 0x43C, 0, 0,, ahk_id %hToolbar% ; TB_SETMAXTEXTROWS
    SendMessage % A_IsUnicode ? 0x444 : 0x414, %cButtons%, % &TBBUTTONS,, ahk_id %hToolbar% ; TB_ADDBUTTONS
    SendMessage 0x421, 0, 0,, ahk_id %hToolbar% ; TB_AUTOSIZE
    SendMessage 0x41F, 0, 0x00180018,, ahk_id %hToolbar% ; TB_SETBUTTONSIZE
Return

ToolbarHandler:
    Code := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")
    If (Code == -2) { ; NM_CLICK
        ButtonId := NumGet(A_EventInfo + (3 * A_PtrSize))

        VarSetCapacity(Text, 128)
        SendMessage % A_IsUnicode ? 0x44B : 0x42D, ButtonId, &Text,, ahk_id %hToolbar% ; TB_GETBUTTONTEXT

        If (Text == "Open Folder") {
            OpenFolder()

        } Else If (Text == "Copy Path") {
            CopyPath()

        } Else If (Text == "Command Prompt") {
            CommandPromptHere()

        } Else If (Text == "Run...") {
            RunFileDlg()

        } Else If (Text == "Find in Files") {
            FindInFiles()

        } Else {
            ExecCommand(Text)
        }
    }
Return

; Called when a new process is detected:
ProcessCreate_OnObjectReady(obj) {
    Process := obj.TargetInstance
    AddToList(Process)

    If (Notifications) {
        CommandLine := StrReplace(Process.CommandLine, Process.ExecutablePath)
        RegExMatch(CommandLine, g_RegEx, m)
        FileGetVersion Ver, % Process.ExecutablePath

        TrayTip New Script Detected, % "
        (LTrim
            File name:`t"  . m2 . "
            Directory:`t"  . GetFileDir(m1) . "
            AutoHotkey:`t" . Process.Name . " v" . Ver . "
            Process ID:`t" . Process.ProcessId . "

            Command line:
            " . Process.CommandLine
        ),, 0x11
    }

    UpdateStatusBar()
}

; Called when a process terminates:
ProcessDelete_OnObjectReady(obj) {
    Process := obj.TargetInstance
    RemoveFromList(Process)

    If (Notifications) {
        CommandLine := StrReplace(Process.CommandLine, Process.ExecutablePath)
        RegExMatch(CommandLine, g_RegEx, m)
        FileGetVersion Ver, % Process.ExecutablePath

        TrayTip Script Terminated, % "
        (LTrim
            File name:`t"  . m2 . "
            Directory:`t"  . GetFileDir(m1) . "
            AutoHotkey:`t" . Process.Name . " v" . Ver . "
            Process ID:`t" . Process.ProcessId
        ),, 0x11
    }

    UpdateStatusBar()
}

AddToList(Process) {
    CommandLine := StrReplace(Process.CommandLine, Process.ExecutablePath)
    If (RegExMatch(CommandLine, g_RegEx, m)) {
        PID := Process.ProcessId

        hIcon := GetWindowIconByPID(PID)
        If (hIcon) {
            hIcon := DllCall("CopyIcon", "Ptr", hIcon, "Ptr")
            IconIndex := IL_Add(ImageList, "HICON: " . hIcon)
        } Else {
            IconIndex := 1
        }

        Suspended := GetScriptState(PID, "S")
        Paused := GetScriptState(PID, "P")

        State := Paused ? "Paused" : "Running"
        If (Suspended) {
            State .= " with hotkeys suspended"
        }

        LV_Add("Icon" . IconIndex, m2, m1, PID, State)
    }
}

RemoveFromList(Process) {
    PID := Process.ProcessId
    Loop % LV_GetCount() {
        LV_GetText(RowPID, A_Index, 3)
        If (RowPID == PID) {
            LV_Delete(A_Index)
            Break
        }
    }
}

ShowMainWindow() {
    WinGet State, MinMax, ahk_id %hMainWnd%
    If (State == -1) {
        WinRestore ahk_id %hMainWnd%
    }

    WinActivate ahk_id %hMainWnd%
}

CommandPromptHere() {
    Row := LV_GetNext()
    If (Row) {
        LV_GetText(FullPath, Row, 2)
        SplitPath FullPath,, StartDir
        FixRootDir(StartDir)
    } Else {
        StartDir := ""
    }

    Run %Comspec%, %StartDir%
}

RunFileDlg() {
    hModule := DllCall("GetModuleHandle", "Str", "shell32.dll", "Ptr")
    RunFileDlg := DllCall("GetProcAddress", "Ptr", hModule, "UInt", 61, "Ptr")
    DllCall(RunFileDlg, "Ptr", hMainWnd, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0)
}

GetWindowPlacement(hWnd) {
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
    Result := {}
    Result.x := NumGet(WINDOWPLACEMENT, 28, "Int")
    Result.y := NumGet(WINDOWPLACEMENT, 32, "Int")
    Result.w := NumGet(WINDOWPLACEMENT, 36, "Int") - Result.x
    Result.h := NumGet(WINDOWPLACEMENT, 40, "Int") - Result.y
    Result.flags := NumGet(WINDOWPLACEMENT, 4, "UInt") ; 2 = WPF_RESTORETOMAXIMIZED
    Result.showCmd := NumGet(WINDOWPLACEMENT, 8, "UInt") ; 1 = normal, 2 = minimized, 3 = maximized
    Return Result
}

SetWindowPlacement(hWnd, x, y, w, h, showCmd) {
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    NumPut(x, WINDOWPLACEMENT, 28, "Int")
    NumPut(y, WINDOWPLACEMENT, 32, "Int")
    NumPut(w + x, WINDOWPLACEMENT, 36, "Int")
    NumPut(h + y, WINDOWPLACEMENT, 40, "Int")
    NumPut(showCmd, WINDOWPLACEMENT, 8, "UInt")
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
}

SaveSettings() {
    If (!FileExist(IniFile)) {
        Sections := "[Options]`n`n[Position]`n"
        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %A_AppData%\AutoGUI
            IniFile := A_AppData . "\AutoGUI\Scripts Manager.ini"
            FileDelete %IniFile%
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }

    IniWrite %AlwaysOnTop%, %IniFile%, Options, AlwaysOnTop
    IniWrite %HideWhenMinimized%, %IniFile%, Options, HideWhenMinimized
    IniWrite %Confirm%, %IniFile%, Options, Confirm
    IniWrite %Notifications%, %IniFile%, Options, Notifications

    Pos := GetWindowPlacement(hMainWnd)
    IniWrite % Pos.x, %IniFile%, Position, X
    IniWrite % Pos.y, %IniFile%, Position, Y
    IniWrite % Pos.w, %IniFile%, Position, Width
    IniWrite % Pos.h, %IniFile%, Position, Height
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %IniFile%, Position, State

    Columns := ""
    Loop % LV_GetCount("Col") {
        SendMessage 0x101D, A_Index - 1, 0,, ahk_id %hLV% ; LVM_GETCOLUMNWIDTH
        Columns .= ErrorLevel . "|"
    }
    Columns := SubStr(Columns, 1, -1)
    IniWrite %Columns%, %IniFile%, Position, Columns
}

SetAlwaysOnTop:
    WinGet ExStyle, ExStyle, ahk_id %hMainWnd%
    If (ExStyle & 0x8) {
        WinSet AlwaysOnTop, Off, ahk_id %hMainWnd%
        AlwaysOnTop := False
        Menu OptionsMenu, Uncheck, Always on Top
    } Else {
        WinSet AlwaysOnTop, On, ahk_id %hMainWnd%
        AlwaysOnTop := True
        Menu OptionsMenu, Check, Always on Top
    }
Return

SetHideWhenMinimized:
    HideWhenMinimized := !HideWhenMinimized
    Menu OptionsMenu, ToggleCheck, Hide When Minimized
Return

SetConfirm:
    Confirm := !Confirm
    Menu OptionsMenu, ToggleCheck, Confirm Reload/Exit
Return

SetNotifications:
    Notifications := !Notifications
    Menu OptionsMenu, ToggleCheck, TrayTip Notifications
Return

FindInFiles() {
    Files := ""
    Row := 0
    While (Row := LV_GetNext(Row)) {
        LV_GetText(Filename, Row, 2)
        Files .= Filename . ";"
    }

    If (Files == "") {
        Loop % LV_GetCount() {
            LV_GetText(Filename, A_Index, 2)
            Files .= Filename . ";"
        }
    }

    If (Files != "") {
        Try {
            Run %A_ScriptDir%\Find in Files.ahk /dir:"%Files%" /mask:*.ahk /sm
        }
    }
}

SetDefaultEditor:
    Run %A_ScriptDir%\Default Editor.ahk
Return

LoadOptions() {
    IniRead AlwaysOnTop, %IniFile%, Options, AlwaysOnTop, 0
    IniRead HideWhenMinimized, %IniFile%, Options, HideWhenMinimized, 0
    IniRead Confirm, %IniFile%, Options, Confirm, 1
    IniRead Notifications, %IniFile%, Options, Notifications, 0

    If (AlwaysOnTop) {
        WinSet AlwaysOnTop, On, ahk_id %hMainWnd%
        Menu OptionsMenu, Check, Always on Top
    }

    If (HideWhenMinimized) {
        Menu OptionsMenu, Check, Hide When Minimized
    }

    If (Confirm) {
        Menu OptionsMenu, Check, Confirm Reload/Exit
    }

    If (Notifications) {
        Menu OptionsMenu, Check, TrayTip Notifications
    }
}

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "Int")
    Height := NumGet(RECT, 12, "Int")
}

GetFileDir(FullPath) {
    Local Dir
    SplitPath FullPath,, Dir
    Return FixRootDir(Dir)
}

FixRootDir(ByRef Dir) {
    If (SubStr(Dir, 0, 1) == ":") {
        Dir := Dir . "\"
    }
    Return Dir
}

#Include %A_ScriptDir%\..\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\..\Lib\ShellMenu.ahk
