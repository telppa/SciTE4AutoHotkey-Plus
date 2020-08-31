; Adventure v2.6.2
; Tested on AHK v1.1.30.03 Unicode 32/64-bit, Windows XP/7/10

; Script options
#SingleInstance Off
#NoEnv
#MaxMem 640
#NoTrayIcon
#KeyHistory 0
SetBatchLines -1
DetectHiddenWindows On
SetWinDelay -1
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8
ListLines Off

Files := [] ; Store filenames passed as parameters
Loop %0% {
    Loop Files, % %A_Index%
        Files.Push(A_LoopFileLongPath)
}
Param = %1%
0 := 0

If (Files.Length() && (hPrevInst := WinExist("AutoGUI v")) && Param != "/new") {
    For Each, File in Files {
        SendFile(File, hPrevInst)
    }

    WinActivate ahk_id %hPrevInst%
    ExitApp
}

; Libraries
#Include %A_ScriptDir%\Lib\AuxLib.ahk
#Include %A_ScriptDir%\Lib\GuiTabEx.ahk
#Include %A_ScriptDir%\Lib\Toolbar.ahk
#Include %A_ScriptDir%\Lib\Scintilla.ahk
#Include %A_ScriptDir%\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\Include\Globals.ahk
#Include %A_ScriptDir%\Include\Keywords.ahk

;Menu Tray, UseErrorLevel ; Suppress menu warnings
Menu Tray, Icon, %IconLib%

If (FileExist(A_AppData . "\AutoGUI\AutoGUI.ini")) {
    IniFile := A_AppData . "\AutoGUI\AutoGUI.ini"
} Else {
    IniFile := A_ScriptDir . "\AutoGUI.ini"
}

LoadSettings()

Gui Auto: New, LabelAuto hWndhAutoWnd Resize MinSize680 -DPIScale, %g_AppName% v%g_Version%
Gui Auto: Default

AddMenu("AutoFileMenu", "&New File`tCtrl+N", "NewTab", IconLib, -7)
Menu AutoEditMenu, Add, &Undo`tCtrl+Z, Undo
AddMenu("AutoSearchMenu", "&Find...`tCtrl+F", "ShowFindDialog", IconLib, -21)
Menu AutoConvertMenu, Add, &UPPERCASE`tCtrl+Shift+U, Uppercase
AddMenu("AutoControlMenu", "Change Text...", "ChangeText", IconLib, -14)
AddMenu("AutoLayoutMenu", "Align &Lefts", "AlignLefts", IconLib, -26)
AddMenu("AutoWindowMenu", "Change &Title...", "ChangeTitle", IconLib, -37)
Menu AutoViewMenu, Add, &Editor Mode, SwitchToEditorMode, Radio
Menu AutoLexerMenu, Add, AutoHotkey, SetLexer
Menu AutoOptionsMenu, Add, Enable &Autocompletion, ToggleAutoComplete
If (A_PtrSize == 8) {
    AddMenu("AutoRunMenu", "Run with AHK 64-&bit`tF9", "RunScript", IconLib, -93)
    AddMenu("AutoRunMenu", "Run with AHK 32-bit`tShift+F9", "RunScript", IconLib, -92)
} Else {
    AddMenu("AutoRunMenu", "Run with AHK 32-bit`tF9", "RunScript", IconLib, -92)
    AddMenu("AutoRunMenu", "Run with AHK 64-&bit`tShift+F9", "RunScript", IconLib, -93)
}
AddMenu("AutoDebugMenu", "Start Debugging`tF5", "DebugRun", IconLib, -104)
AddMenu("AutoToolsMenu", "&Window Cloning Tool", "ShowCloneDialog", "Icons\WCT.ico")
AddMenu("AutoHelpMenu", "AutoHotkey &Help File`tF1", "HelpMenuHandler", IconLib, -78)

Menu AutoMenuBar, Add, % " &File ", :AutoFileMenu
Menu AutoMenuBar, Add, % " &Edit ", :AutoEditMenu
Menu AutoMenuBar, Add, % " Te&xt ", :AutoConvertMenu
Menu AutoMenubar, Add, % " &Search ", :AutoSearchMenu
If (g_DesignMode) {
    Menu AutoMenuBar, Add, % " &Control ", :AutoControlMenu
    Menu AutoMenuBar, Add, % " L&ayout ", :AutoLayoutMenu
    Menu AutoMenuBar, Add, % " &Window ", :AutoWindowMenu
}
Menu AutoMenuBar, Add, % " &View ", :AutoViewMenu
Menu AutoMenuBar, Add, % " &Lexer ", :AutoLexerMenu
Menu AutoMenuBar, Add, % " &Options ", :AutoOptionsMenu
Menu AutoMenuBar, Add, % " &Run ", :AutoRunMenu
Menu AutoMenuBar, Add, % " &Debug ", :AutoDebugMenu
Menu AutoMenuBar, Add, % " &Tools ", :AutoToolsMenu
Menu AutoMenuBar, Add, % " &Help ", :AutoHelpMenu
Gui Menu, AutoMenuBar

IniRead g_InitialX, %IniFile%, Auto, x
IniRead g_InitialY, %IniFile%, Auto, y
IniRead g_InitialW, %IniFile%, Auto, w, 952
IniRead g_InitialH, %IniFile%, Auto, h, 611
IniRead ShowState, %IniFile%, Auto, Show, 3 ; SW_MAXIMIZE

If (FileExist(IniFile)) {
    SetWindowPlacement(hAutoWnd, g_InitialX, g_InitialY, g_InitialW, g_InitialH, 0)
} Else {
    Gui Show, w%g_InitialW% h%g_InitialH% Hide
}

Gui Font, s9, Segoe UI
Gui Add, StatusBar, hWndg_hStatusBar
GuiControlGet g_StatusBar, Pos, %g_hStatusBar%

If (g_DesignMode) {
    CreateToolbox(0)
}

Gui Add, Edit, hWndg_hHiddenEdit x0 y0 w0 h0

GoSub CreateTabControl

; Initial instance of Scintilla
Sci[1] := New Scintilla
Sci_GetIdealSize(SciX, SciY, SciW, SciH)
Sci[1].Add(hAutoWnd, SciX, SciY, SciW, SciH, SciLexer, 0x50000000, 0x200)
Sci_Config(1)

CreateEditorToolbar()
CreateDesignToolbar()

ShowWindow(hAutoWnd, ShowState)
WinActivate ahk_id %hAutoWnd%

ApplyToolbarSettings()
SetStatusBar()
#Include %A_ScriptDir%\Include\Menu.ahk
ApplyMenuSettings()

Sci[1].GrabFocus()

If (!g_DesignMode) {
    CreateToolbox(1)
}

; Dispatch messages
OnMessage(0x136, "OnWM_CTLCOLORDLG")
OnMessage(0x3,   "OnWM_MOVE")
OnMessage(0x201, "OnWM_LBUTTONDOWN")
OnMessage(0x204, "OnWM_RBUTTONDOWN")
OnMessage(0x207, "OnWM_MBUTTONDOWN")
OnMessage(0x200, "OnWM_MOUSEMOVE")
OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x101, "OnWM_KEYUP")
OnMessage(0x104, "OnWM_SYSKEYDOWN")
OnMessage(0x203, "OnWM_LBUTTONDBLCLK")
OnMessage(0x232, "OnWM_EXITSIZEMOVE")
OnMessage(0x18,  "OnWM_SHOWWINDOW")
OnMessage(0xA0,  "OnWM_NCMOUSEMOVE")
OnMessage(0x138, "OnWM_CTLCOLORSTATIC")
OnMessage(0x20,  "OnWM_SETCURSOR")
OnMessage(0x202, "OnWM_LBUTTONUP")
OnMessage(0x4A,  "OnWM_COPYDATA")
OnMessage(0x1C,  "OnWM_ACTIVATEAPP")
OnMessage(0x211, "OnWM_ENTERMENULOOP")
OnMessage(0x116, "OnWM_INITMENU")
OnMessage(10000, "CustomMessage")
OnMessage(0x16,  "OnWM_ENDSESSION")

LoadRecentFiles()
SetSessionsDir()

If (Files.Length()) {
    Open(Files)
} Else If (g_LoadLastSession) {
    LoadLastSession()
}

hBitmapTile := LoadImage(A_ScriptDir . "\Icons\8x8.bmp", g_GridSize, g_GridSize, 0)
hCursorCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr")
hCursorDragMove := LoadImage(A_ScriptDir . "\Icons\DragMove.cur", 32, 32, 2)

SetExplorerTheme(hLVToolbox)

#Include %A_ScriptDir%\Include\Controls.ahk

SplitPath A_AhkPath,, AhkDir
g_AhkPath3264 := AhkDir . (A_PtrSize == 4 ? "\AutoHotkeyU64.exe" : "\AutoHotkeyU32.exe")

g_hShellWnd := CreateShellMenuWindow()

CreateTabContextMenu()

Global g_ThemeFix := DllCall("UxTheme.dll\IsThemeActive") ? "" : "-Theme" ; Temp

StartAutoSave()

LoadToolsMenu()
LoadHelpMenu()

LoadAutoComplete(A_ScriptDir . "\Include\AutoHotkey.xml")

DeleteOldBackups()

If (A_ScreenDPI != 96) {
    Gui Auto: +OwnDialogs
    MsgBox 0x30, Warning, %g_AppName% has not been adapted to High-DPI display scaling.`n`nThe program will exit.
    ExitApp
}

If (!A_IsUnicode) {
    Gui Auto: +OwnDialogs
    MsgBox 0x10, Error, %g_AppName% is incompatible with the ANSI build of AutoHotkey.
    ExitApp
}

Return ; End of the auto-execute section.

TabHandler:
    TabIndex := TabEx.GetSel()

    ShowWindow(Sci[TabIndex].hWnd)
    Loop % Sci.Length() {
        If (A_Index != TabIndex) {
            ShowWindow(Sci[A_Index].hWnd, 0)
        }
    }

    Sci[TabIndex].GrabFocus()

    If (TabIndex != g_GuiTab) {
        ShowChildWindow(0)
    }

    WrapMode := Sci[TabIndex].GetWrapMode()
    SendMessage TB_CHECKBUTTON, 2160, WrapMode,, ahk_id %hMainToolbar%
    Menu AutoViewMenu, % WrapMode ? "Check" : "Uncheck", &Wrap Long Lines

    ReadOnly := Sci[TabIndex].GetReadOnly()
    SendMessage TB_CHECKBUTTON, 2170, ReadOnly,, ahk_id %hMainToolbar%
    Menu AutoEditMenu, % ReadOnly ? "Check" : "Uncheck", Set as &Read-Only

    UpdateStatusBar()

    SetWindowTitle(Sci[TabIndex].FullName)

    Sci[TabIndex].LastAccessTime := A_Now . A_MSec

    CheckModified()
Return

CreateEditorToolbar() {
    EditorTBIL := IL_Create(32)
    IL_Add(EditorTBIL, IconLib, -7)   ; New Tab
    IL_Add(EditorTBIL, IconLib, -9)   ; Open
    IL_Add(EditorTBIL, IconLib, -10)  ; Save
    IL_Add(EditorTBIL, IconLib, -125) ; Save All
    IL_Add(EditorTBIL, IconLib, -126) ; Design Mode
    IL_Add(EditorTBIL, IconLib, -6)   ; New GUI
    IL_Add(EditorTBIL, IconLib, -15)  ; Cut
    IL_Add(EditorTBIL, IconLib, -16)  ; Copy
    IL_Add(EditorTBIL, IconLib, -17)  ; Paste
    IL_Add(EditorTBIL, IconLib, -81)  ; Undo
    IL_Add(EditorTBIL, IconLib, -82)  ; Redo
    IL_Add(EditorTBIL, IconLib, -21)  ; Find
    IL_Add(EditorTBIL, IconLib, -22)  ; Replace
    IL_Add(EditorTBIL, IconLib, -23)  ; Find in Files
    IL_Add(EditorTBIL, IconLib, -130) ; Mark Current Line
    IL_Add(EditorTBIL, IconLib, -131) ; Mark Selected Text
    IL_Add(editorTBIL, IconLib, -137) ; Line numbers
    IL_Add(EditorTBIL, IconLib, -83)  ; Fold Margin
    IL_Add(EditorTBIL, IconLib, -85)  ; Word Wrap
    IL_Add(EditorTBIL, IconLib, -87)  ; Read Only
    IL_Add(EditorTBIL, IconLib, -86)  ; Syntax Highlighting
    IL_Add(EditorTBIL, IconLib, -84)  ; Show White Spaces
    IL_Add(EditorTBIL, IconLib, -104) ; Debug Run
    IL_Add(EditorTBIL, IconLib, -106) ; Debug Stop
    IL_Add(EditorTBIL, IconLib, -109) ; Step Into
    IL_Add(EditorTBIL, IconLib, -110) ; Step Over
    IL_Add(EditorTBIL, IconLib, -111) ; Step Out
    IL_Add(EditorTBIL, IconLib, -115) ; Inspect Variables
    IL_Add(EditorTBIL, IconLib, -138) ; Execute
    IL_Add(EditorTBIL, IconLib, -78)  ; Help

    EditorTBBtns = 
    (LTrim
        -
        New File
        Open
        Save
        Save All
        -
        Design Mode
        New GUI
        -
        Cut
        Copy
        Paste
        -
        Undo
        Redo
        -
        Find
        Replace
        Find in Files
        -
        Mark Current Line
        Mark Selected Text
        -
        Line Numbers,,,, 2140
        Fold Margin,,,, 2150
        Word Wrap,,,, 2160
        Read Only,,,, 2170
        Syntax Highlighting,,,, 2180
        Show White Spaces,,,, 2190
        -
        Start Debugging / Continue,,,, 2500
        Stop Debugging,, HIDDEN,, 2501
        Step Into,, HIDDEN,, 2502
        Step Over,, HIDDEN,, 2503
        Step Out,, HIDDEN,, 2504
        Inspect Variables,, HIDDEN,, 2505
        -
        Execute,,, DROPDOWN SHOWTEXT
        -
        Help
    )

    Extra := (g_TabBarPos == 1) ? "+E0x200" : ""
    Extra .= (g_DesignMode) ? " Hidden" : ""

    hMainToolbar := ToolbarCreate("OnMainToolbar", EditorTBBtns, EditorTBIL, "FLAT LIST TOOLTIPS", Extra, "", 65536)
}

OnMainToolbar(hWnd, Event, Text, Pos, Id, Left, Bottom) {
    Static SkipClick := 0
    Local n, ItemID, FullPath, WorkingDir, FileExt, CMFlags := 0, Verb

    If (Event == "DropDown") {
        If (!g_ShellMenu1) {
            ShowShellMenuDlg()
            Return
        }

        SkipClick := 1

        If (g_ShellMenu1 && !DllCall("IsMenu", "Ptr", g_hShellMenu) && WinExist("ahk_id" . g_hShellWnd)) {
            n := TabEx.GetSel()
            FullPath := Sci[n].FullName
            If (!FileExist(FullPath)) {
                Return
            }

            SplitPath FullPath,, WorkingDir, FileExt
            FixRootDir(WorkingDir)

            If (IsAhkFileExt(FileExt)) {
                CMFlags |= 0x20 ; CMF_NODEFAULT
            }

            If (GetKeyState("Shift", "P")) {
                CMFlags |= 0x100 ; CMF_EXTENDEDVERBS
            }

            g_hShellMenu := GetShellContextMenu(FullPath, CMFlags)

            ItemID := ShowPopupMenu(g_hShellMenu, 0x100, Left, Bottom, g_hShellWnd) ; TPM_RETURNCMD

            If (ItemID) {
                Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
                OutputDebug Shell context menu item: ID: %ItemID%, Verb: "%Verb%".

                If (Verb == "paste") {
                    PasteFile(WorkingDir)

                } Else {
                    If (Sci[n].GetModify()) {
                        Gui Auto: +OwnDialogs
                        MsgBox 0x4, %g_AppName%, Save the file before proceeding with the requested action?
                        IfMsgBox Yes, {
                            If (!Save(n)) {
                                SkipClick := 0
                                DestroyShellMenu(g_hShellMenu)
                                Return
                            }
                        }
                    }

                    RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, hAutoWnd, Left, Bottom)
                }

                SkipClick := 0
            }

            DestroyShellMenu(g_hShellMenu)
        }

        Return
    }

    If (Event != "Click") {
        Return
    }

    If (SkipClick) {
        SkipClick := 0
        Return
    }

    If (Text == "Execute") {
        Execute()

    } Else If (Text == "New File") {
        NewTab()
    } Else If (Text == "Open") {
        Open()
    } Else If (Text == "Save") {
        Save(TabEx.GetSel())
    } Else If (Text == "Save All") {
        GoSub SaveAll

    } Else If (Text == "Undo") {
        Undo()
    } Else If (Text == "Redo") {
        Redo()

    } Else If (Text == "Design Mode") {
        GoSub SwitchToDesignMode
    } Else If (Text == "New GUI") {
        GoSub NewGUI

    } Else If (Text == "Cut") {
        Cut()
    } Else If (Text == "Copy") {
        Copy()
    } Else If (Text == "Paste") {
        Paste()

    } Else If (Text == "Find") {
        GoSub ShowFindDialog
    } Else If (Text == "Replace") {
        GoSub ShowReplaceDialog
    } Else If (Text == "Find in Files") {
        FindInFiles()

    } Else If (Text == "Mark Current Line") {
        ToggleBookmark(g_MarkerBookmark)
    } Else If (Text == "Mark Selected Text") {
        MarkSelectedText()

    } Else If (Text == "Line Numbers") {
        ToggleLineNumbers()
    } Else If (Text == "Fold Margin") {
        ToggleCodeFolding()
    } Else If (Text == "Word Wrap") {
        ToggleWordWrap()
    } Else If (Text == "Read Only") {
        ToggleReadOnly()
    } Else If (Text == "Syntax Highlighting") {
        ToggleSyntaxHighlighting()
    } Else If (Text == "Show White Spaces") {
        ToggleWhiteSpaces()

    } Else If (Id == 2500) {
        DebugRun()
    } Else If (Text == "Step Into") {
        GoSub StepInto
    } Else If (Text == "Step Over") {
        GoSub StepOver
    } Else If (Text == "Step Out") {
        GoSub StepOut
    } Else If (Text == "Stop Debugging") {
        GoSub DebugStop
    } Else If (Text == "Inspect Variables") {
        GoSub ShowVarList

    } Else If (Text == "Help") {
        OpenHelpFile(GetSelectedText())
    }
}

; Design Mode toolbar
CreateDesignToolbar() {
    TbarIL := IL_Create(32)
    IL_Add(TbarIL, IconLib, -7)   ; New File
    IL_Add(TbarIL, IconLib, -9)   ; Open
    IL_Add(TbarIL, IconLib, -10)  ; Save
    IL_Add(TbarIL, IconLib, -125) ; Save All
    IL_Add(TbarIL, IconLib, -126) ; Design Mode
    IL_Add(TbarIL, IconLib, -6)   ; New GUI
    IL_Add(TbarIL, IconLib, -38)  ; Show/Hide Preview Window
    IL_Add(TbarIL, IconLib, -72)  ; Show Grid
    IL_Add(TbarIL, IconLib, -73)  ; Snap to Grid
    IL_Add(TbarIL, IconLib, -26)  ; Align Lefts
    IL_Add(TbarIL, IconLib, -27)  ; Align Rights
    IL_Add(TbarIL, IconLib, -28)  ; Align Tops
    IL_Add(TbarIL, IconLib, -29)  ; Align Bottoms
    IL_Add(TbarIL, IconLib, -30)  ; Center Horizontally
    IL_Add(TbarIL, IconLib, -31)  ; Center Vertically
    IL_Add(TbarIL, IconLib, -33)  ; Horizontally Space
    IL_Add(TbarIL, IconLib, -32)  ; Vertically Space
    IL_Add(TbarIL, IconLib, -34)  ; Make Same Width
    IL_Add(TbarIL, IconLib, -35)  ; Make Same Height
    IL_Add(TbarIL, IconLib, -36)  ; Make Same Size
    IL_Add(TbarIL, "Icons\WCT.ico") ; Window Cloning Tool
    IL_Add(TbarIL, IconLib, -12)  ; Execute
    IL_Add(TbarIL, IconLib, -25)  ; Properties

    TbarButtons = 
        (LTrim
            -
            New File
            Open
            Save
            Save All
            -
            Design Mode,,,, 1060
            New GUI
            Show/Hide Preview Window,,,, 1070
            -
            Show Grid,,,, 1080
            Snap to Grid,,,, 1090
            -
            Align Lefts
            Align Rights
            Align Tops
            Align Bottoms
            -
            Center Horizontally
            Center Vertically
            -
            Horizontally Space
            Vertically Space
            -
            Make Same Width
            Make Same Height
            Make Same Size
            -
            Window Cloning Tool
            -
            Execute,,, SHOWTEXT
            -
            Properties
        )

    Extra := (g_TabBarPos == 1) ? "+E0x200" : ""
    Extra .= (g_DesignMode) ? "" : " Hidden"

    hGUIToolbar := ToolbarCreate("OnGUIToolbar", TbarButtons, TbarIL, "FLAT LIST TOOLTIPS", Extra)
    SendMessage 0x41F, 0, 0x00180018,, ahk_id %hGUIToolbar% ; TB_SETBUTTONSIZE
}

OnGUIToolbar(hWnd, Event, Text, Pos, Id) {
    If (Event == "Hot") {
        If (GetActiveWindow() != hAutoWnd && Text != "Execute") {
            Tooltip %Text%
            SetTimer RemoveToolTip, 3000
        }
        Return
    }

    If (Event != "Click") {
        Return
    }

    If (Text == "New GUI") {
        GoSub NewGUI
    } Else If (Text == "New File") {
        NewTab()
    } Else If (Text == "Open") {
        Open()
    } Else If (Text == "Save") {
        Save(TabEx.GetSel())
    } Else If (Text == "Save All") {
        GoSub SaveAll

    } Else If (Text == "Design Mode") {
        GoSub SwitchToEditorMode
    } Else If (Text == "Show/Hide Preview Window") {
        ShowChildWindow()

    } Else If (Text == "Show Grid") {
        GoSub ToggleGrid
    } Else If (Text == "Snap to Grid") {
        GoSub ToggleSnapToGrid

    } Else If (Text == "Align Lefts") {
        AlignLefts()
    } Else If (Text == "Align Rights") {
        AlignRights()
    } Else If (Text == "Align Tops") {
        AlignTops()
    } Else If (Text == "Align Bottoms") {
        AlignBottoms()

    } Else If (Text == "Center Horizontally") {
        CenterHorizontally()
    } Else If (Text == "Center Vertically") {
        CenterVertically()

    } Else If (Text == "Horizontally Space") {
        HorizontallySpace()
    } Else If (Text == "Vertically Space") {
        VerticallySpace()

    } Else If (Text == "Make Same Width") {
        MakeSame("w")
    } Else If (Text == "Make Same Height") {
        MakeSame("h")
    } Else If (Text == "Make Same Size") {
        MakeSame("wh")

    } Else If (Text == "Window Cloning Tool") {
        GoSub ShowCloneDialog

    } Else If (Text == "Execute") {
        Execute()

    } Else If (Text == "Properties") {
        GoSub ShowProperties
    }

    Tooltip
}

RemoveToolTip:
    SetTimer RemoveToolTip, Off
    ToolTip
Return

OnWM_NCMOUSEMOVE() {
    Tooltip
}

SetStatusBar(GD := 0) {
    Gui Auto: Default
    If (GD) {
        SB_SetParts()
        SB_SetParts(162, 170, 170, 170)

        SB_SetIcon(IconLib, 4,  1) ; GUI Designer
        SB_SetIcon(IconLib, 75, 2) ; Position
        SB_SetIcon(IconLib, 76, 3) ; Size
        SB_SetIcon(IconLib, 77, 4) ; Cursor

        SB_SetText("GUI Designer", 1)
    } Else {
        SB_SetParts()
        SB_SetParts(162, 200, 200, 62) ; Mode | Line:Pos | Document Status | Overtype Mode | Save Encoding

        If (g_Insert) {
            SB_SetText("    Insert", 4)
        } Else {
            SB_SetText("Overstrike", 4)
        }

        SB_SetText(A_FileEncoding, 5)

        ;SB_SetText("", 1) ; ?
        UpdateStatusBar()
    }
}

; Message handling

AutoSize:
    If (A_EventInfo == 1) { ; The window has been minimized.
        Return
    }

    Gui Auto: Default

    GuiControlGet, ToolBox, Pos, %hLVToolbox%
    GuiControlGet, TabCtl, Pos, %hTab%

    GuiControl Move, %hGUIToolbar%, w%A_GuiWidth%
    GuiControl Move, %hMainToolbar%, w%A_GuiWidth%

    GuiControl Move, %hLVToolbox%, % "h" . A_GuiHeight - g_ToolbarH - g_StatusBarH

    If (g_TabBarPos == 1) {
        TabCtlY := g_ToolbarH
        SciY := TabCtlY + TabCtlH + 1
        SciH := A_GuiHeight - g_StatusBarH - SciY
    } Else {
        TabCtlY := A_GuiHeight - g_StatusBarH - TabCtlH
        SciY := g_ToolbarH
        SciH := A_GuiHeight - g_StatusBarH - TabCtlH - SciY
    }

    If (g_DesignMode) {
        TabCtlW := A_GuiWidth - ToolboxW - 2
        SciW := A_GuiWidth - ToolBoxW - g_SplitterW
    } Else {
        TabCtlW := A_GuiWidth
        SciW := A_GuiWidth + 1
    }

    GuiControl MoveDraw, %hTab%, y%TabCtlY% w%TabCtlW%

    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, 0, 0, SciW, SciH, 0, 0x16) ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
    }

    If (g_DesignMode) {
        Gui ListView, %hLVToolbox%
        LV_ModifyCol(1, "AutoHdr")
    }
Return

AutoDropFiles:
    Files := StrSplit(A_GuiEvent, "`n")
    Open(Files)
Return

AutoClose:
    If (g_RememberSession) {
        GoSub SaveSessionOnExit
    }

    If (g_AskToSaveOnExit) {
        GoSub AskToSaveOnExit
    } Else {
        Quit()
    }
Return

Quit() {
    If (g_DbgStatus) {
        GoSub DebugStop
        DBGp_StopListening(g_DbgSocket)
    }

    SaveSettings()

    DllCall("DestroyWindow", "Ptr", g_hShellWnd)

    IL_Destroy(TabExIL)

    FileDelete %g_TempFile%
    FileDelete %A_Temp%\AutoXYWH.ahk
    FileDelete %A_Temp%\Toolbar.ahk
    FileDelete %A_Temp%\ControlColor.ahk

    ExitApp
}

ChildSize:
    If (A_EventInfo == 1) { ; The window has been minimized.
        ShowChildWindow(0)
        Return
    }

    If (g_GuiVis) {
        Gui Auto: Default
        SB_SetText("Size: " . A_GuiWidth . " x " . A_GuiHeight, 3)
    }
Return

ChildEscape:
ChildClose:
    ShowChildWindow(0)
Return

OnWM_CTLCOLORDLG() {
    Static Brush := 0

    If (A_Gui != Child || !g_ShowGrid) {
        Return
    }

    If (!Brush) {
        Brush := DllCall("Gdi32.dll\CreatePatternBrush", "Ptr", hBitmapTile, "Ptr")
    }

    Return Brush
}

OnWM_MOVE(wParam, lParam, msg, hWnd) {
    If (hWnd != hChildWnd) {
        Return
    }

    WinGetPos wx, wy,,, ahk_id %hChildWnd%

    If (WinExist("ahk_id " . hSelWnd)) {
        WinMove ahk_id %hSelWnd%,, %wx%, %wy%
    }

    Gui Auto: Default
    SB_SetText("Position: " . wx . ", " . wy, 2)
}

OnWM_EXITSIZEMOVE(wParam, lParam, msg, hWnd) {
    If (hWnd == hChildWnd) {
        GenerateCode()

        Properties_UpdateWinPos()

        If (ToolbarExist()) {
            Repaint(hChildWnd)
        }
    }
}

OnWM_MOUSEMOVE(wParam, lParam, msg, hWnd) {
    Static hPrevCtrl := 0

    If (GetActiveWindow() != hAutoWnd && hWnd != hGUIToolbar) {
        Tooltip
    }

    CoordMode Mouse, Window
    MouseGetPos x1, y1, hWindow, hControl, 2

    If (hControl == "") {
        hControl := hWindow
    }

    ; Update status bar info
    If (g_GuiVis) {
        If ((hControl != hPrevCtrl) ) {
            If (hControl != hChildWnd) {
                GuiControlGet Pos, Pos, %hControl%
                MouseGetPos,,,, ClassNN

                Gui Auto: Default
                SB_SetText("Position: " . PosX . ", " . PosY, 2)
                SB_SetText("Size: " . PosW . " x " . PosH, 3)
                SB_SetText(ClassNN, 5)
            } Else {
                WinGetTitle WinTitle, ahk_id %hWindow%
                wi := GetWindowInfo(hWindow)
                wx := wi.WindowX
                wy := wi.WindowY
                ww := wi.ClientW
                wh := wi.ClientH

                Gui Auto: Default
                SB_SetText("AutoHotkeyGUI", 5)
                SB_SetText("Position: " . wx . ", " . wy, 2)
                SB_SetText("Size: " . ww . " x " . wh, 3)
            }

            hPrevCtrl := hControl
        }

        Gui Auto: Default
        CoordMode Mouse, Client
        MouseGetPos mx, my
        SB_SetText("Cursor: " . mx . ", " . my, 4)
    }

    If (hWindow != hChildWnd) {
        Return
    }

    LButtonP := wParam & 1 ; MK_LBUTTON

    If (LButtonP && IsResizer(hControl)) {
        OnResize(hControl)

    } Else If (LButtonP && !(wParam & 0x8)) { ; MK_CONTROL
        If (hControl == hChildWnd) {
            DestroyWindow(hSelWnd)
            WinGetPos wx, wy, ww, wh, ahk_id %hChildWnd%
            ; Translucid selection rectangle (based on maestrith's GUI Creator)
            Gui SelRect: New, LabelSelRect hWndhSelRect -Caption AlwaysOnTop ToolWindow
            Gui SelRect: Color, 1BCDEF
            WinSet Transparent, 40, ahk_id %hSelRect%
            Gui SelRect: Show, x%wx% y%wy% w%ww% h%wh% NoActivate Hide
            Gui SelRect: Show, NoActivate

            While GetKeyState("LButton", "P") {
                CoordMode Mouse, Window
                MouseGetPos x2, y2
                WinSet Region, %x1%-%y1% %x2%-%y1% %x2%-%y2% %x1%-%y2% %x1%-%y1%, ahk_id %hSelRect%
            }
            Gui SelRect: Destroy

            g.Selection := GetControlsFromRegion(x1, y1, x2, y2)
            Select(g.Selection)
        } Else {
            If (wParam & 0x4) { ; MK_SHIFT
                DestroyWindow(hSelWnd)
                ResizeControl(hControl)
            } Else {
                DestroyWindow(hSelWnd)
                HideResizers()
                MoveControl()
                ShowResizers()
                Select(g.Selection)
            }
        }
    }
}

OnWM_LBUTTONDOWN(wParam, lParam, msg, hWnd) {
    g_LButtonDown := 1

    If (GetClassName(hWnd) == "Scintilla") {
        ShowChildWindow(0)
    }

    If (GetActiveWindow() != hChildWnd) {
        Return
    }

    If (IsResizer(hWnd)) {
        Return
    }

    MouseGetPos,,, hGui, g_Control, 2

    CtrlP := wParam & 0x8 ; MK_CONTROL

    If (g_Cross) {
        If (!CtrlP) {
            g_Cross := False
        }

        g_X := lParam & 0xFFFF
        g_Y := lParam >> 16

        Gui Auto: Default
        RowNumber := LV_GetNext()
        LV_GetText(Type, RowNumber)
        If (Type != "Toolbox") {
            AddControl(Type)
        }

        Return
    }

    If (g_Control == "") {
        DestroyWindow(hSelWnd)
        HideResizers()
        If (IsWindowVisible(hPropWnd)) {
            GoSub ShowProperties
        }
        Return
    } Else {
        ShowResizers()
    }

    If (CtrlP) {
        fSelect := True
        Loop % g.Selection.Length() {
            If (g_Control == g.Selection[A_Index]) {
                g.Selection.Remove(A_Index)
                fSelect := False
                Break
            }
        }
        If (fSelect) {
            If (g[g_Control].Type == "Tab2") {
                SelectTabItems(g_Control)
            } Else {
                g.Selection.Push(g_Control)
                Select([g_Control])
            }
        } Else {
            UpdateSelection()
        }
    } Else {
        DestroyWindow(hSelWnd)

        If (g_Control != "" && g[g_Control].ClassNN == "") {
            g_Control := GetParent(g_Control)
        }

        If (IsWindowVisible(hPropWnd)) {
            GoSub ShowProperties
        }
    }

    If (g[g_Control].Type == "Tab2") {
        Return
    }

    Return 0
}

OnWM_LBUTTONDBLCLK(wParam, lParam, msg, hWnd) {
    If (hWnd == hAutoWnd) {
        NewTab()
        Return
    }

    If (GetActiveWindow() != hChildWnd) {
        Return
    }

    MouseGetPos,,,, g_Control, 2
    If (g_Control == "") {
        GoSub ChangeTitle
    } Else If (g_Control == hChildToolbar){
        GoSub ShowToolbarEditor
    } Else {
        g_Control := g[g_Control].ClassNN == "" ? GetParent(g_Control) : g_Control
        GoSub ChangeText
    }

    Return 0
}

OnWM_MBUTTONDOWN(wParam, lParam, msg, hWnd) {
    MouseGetPos,,, hGui, g_Control, 2

    If (hGui == hChildWnd) {
        If (g_Control != "" && g[g_Control].ClassNN == "") {
            g_Control := GetParent(g_Control) ; For ComboBox and ActiveX
        }

        GoSub ShowProperties
    }

    Return
}

OnWM_RBUTTONDOWN(wParam, lParam, msg, hWnd) {
    g_X := lParam & 0xFFFF
    g_Y := lParam >> 16

    If (hWnd == hChildToolbar) {
        AddMenu("ChildToolbarMenu", "Properties", "ShowToolbarEditor", IconLib, -25)
        Menu ChildToolbarMenu, Show
        Return
    }

    MouseGetPos,,, g_Gui, g_Control, 2
    If (g_Gui != hChildWnd) {
        If (hWnd == hTab) {
            g_TabIndex := TabHitTest(hTab, lParam & 0xFFFF, lParam >> 16)
            ShowTabContextMenu()
        }
        Return
    }

    If (g[g_Control].Type == "Tab2") {
        VarSetCapacity(RECT, 16, 0)
        DllCall("GetClientRect", "Ptr", g_Control, "Ptr", &RECT)
        SendMessage 0x1328, 0, &RECT,, ahk_id %g_Control% ; TCM_ADJUSTRECT
        tiy := NumGet(RECT, 4, "Int")
        ControlGetPos,, ty,,,, ahk_id %g_Control%
        If (g_Y > (tiy + ty)) {
            g_Control := ""
        }
    }

    If (g_Control == "" || IsResizer(g_Control)) {
        Menu WindowContextMenu, Show
    } Else {
        If (g[g_Control].Handle == "") {
            g_Control := GetParent(g_Control) ; For ComboBox and ActiveX
        }
        ShowContextMenu()
    }

    Return 0
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    hActiveWnd := WinExist("A")

    ShiftP := GetKeyState("Shift", "P")
    CtrlP := GetKeyState("Ctrl", "P") && !GetKeyState("vkA5", "P") ; vkA5: AltGr = Ctrl + Alt

    ; Main window
    If (hActiveWnd == hAutoWnd) {
        If (CtrlP) {
            If (wParam == 9) { ; Ctrl+Tab
                NextTab := TabEx.GetSel()
                If (ShiftP) {
                    NextTab := (NextTab == 1) ? TabEx.GetCount() - 1 : NextTab - 2
                } Else If (NextTab == TabEx.GetCount()) {
                    NextTab := 0
                }
                SendMessage 0x1330, NextTab,,, ahk_id %hTab% ; TCM_SETCURFOCUS.
                Sleep 0 ; This line and the next are necessary only for certain tab controls.
                SendMessage 0x130C, NextTab,,, ahk_id %hTab% ; TCM_SETCURSEL
                GoSub TabHandler
                Return False

            } Else If (wParam == 13) { ; Ctrl + Enter
                AutoComplete(1)
                Return False
            } Else If (wParam == 32) { ; Ctrl + Space
                WordPos := GetCurrentWord(Word)
                Calltip := GetCalltip(Word)
                ShowCalltip(TabEx.GetSel(), Calltip, WordPos[1])
                Return False
            } Else If (wParam == 0x6B) { ; ^Numpad+
                ZoomIn()
                Return False
            } Else If (wParam == 0x6D) { ; ^Numpad-
                ZoomOut()
                Return False
            } Else If (wParam == 0x60) { ; ^Numpad0
                ResetZoom()
                Return False
            } Else If (ShiftP && wParam == 0x26) { ; Ctrl + Shift + Up
                MoveLineUp()
                Return False
            } Else If (ShiftP && wParam == 0x28) { ; Ctrl + Shift + Down
                MoveLineDown()
                Return False
            } Else If (wParam == 0x28) { ; Ctrl + Down
                DuplicateLine()
                Return False
            } Else If (ShiftP && wParam == 34) { ; Ctrl + Shift + Pg Dn
                NextCalltip()
                Return False
            } Else If (ShiftP && wParam == 33) { ; Ctrl + Shift + Pg Up
                NextCalltip(1)
                Return False
            }
        }

        If (wParam == 113) { ; F2
            ToggleBookmark(ShiftP ? g_MarkerError : g_MarkerBookmark)
            Return False
        } Else If (wParam == 114) { ; F3
            If (ShiftP) {
                GoSub FindPrev
            } Else {
                GoSub FindNext
            }
            Return False
        } Else If (wParam == 0x2D) { ; Insert
            If (CtrlP) {
                InsertCalltip()
                Return False
            } Else {
                g_Insert := !g_Insert
                If (g_Insert) {
                    SB_SetText("    Insert", 4)
                } Else {
                    SB_SetText("Overstrike", 4)
                }
            }
        } Else If (wParam == 27) { ; Esc
            n := TabEx.GetSel()
            If (g_AutoCEnabled && Sci[n].AutoCActive()) {
                Sci[n].CallTipCancel() ; ?
                g_AutoCEnabled := False
                SetTimer SuspendAutoComplete, -3000
                Return False
            }

            hCursor := DllCall("GetCursor", "Ptr")
            If (hCursor == hCursorDragMove) {
                DllCall("ReleaseCapture")
            }
        }

    ; Preview window
    } Else If (hActiveWnd == hChildWnd) {
        If (ShiftP) {
            If (wParam == 37) { ; Shift + Left
                ResizeByKey("Left")
                Return False
            } Else If (wParam == 38) { ; Shift + Up
                ResizeByKey("Up")
                Return False
            } Else If (wParam == 39) { ; Shift + Right
                ResizeByKey("Right")
                Return False
            } Else If (wParam == 40) { ; Shift + Down
                ResizeByKey("Down")
                Return False
            }
        }

        If (wParam == 37) { ; Left
            MoveByKey("Left")
            Return False
        } Else If (wParam == 38) { ; Up
            MoveByKey("Up")
            Return False
        } Else If (wParam == 39) { ; Right
            MoveByKey("Right")
            Return False
        } Else If (wParam == 40) { ; Down
            MoveByKey("Down")
            Return False
        } Else If (wParam == 46) { ; Del
            DeleteSelectedControls()
        } Else If (wParam == 65 && CtrlP) { ; ^A
            SelectAllControls()
        } Else If (wParam == 113) { ; F2
            Gosub ChangeText
        } Else If (wParam == 114) { ; F3
            BlinkBorder(g_Control)
            Return False
        } Else If (wParam == 93) { ; AppsKey
            Menu WindowContextMenu, Show
        }

    } Else If (hActiveWnd == hAddMenuItemDlg) {
        ControlGetFocus FocusedControl, ahk_id %hAddMenuItemDlg%
        If (FocusedControl == "msctls_hotkey321") {
            ReservedKeys := {8: "Backspace", 13: "Enter", 27: "Esc", 32: "Space", 46: "Del"}
            If ReservedKeys.HasKey(wParam) {
                GuiControl,, msctls_hotkey321, % ReservedKeys[wParam]
                Return False
            }
            Return
        }

    } Else If (hActiveWnd == hFindReplaceDlg) {
        ;If (CtrlP && wParam == 86) { ; ^V

    } Else If (hActiveWnd == hVarListWnd) {
        If (wParam == 13) {
            GoSub ModifyVariable
            Return False
        }
    }

    ; Any window
    If (CtrlP) {
        If (wParam == 120) { ; ^F9
            GoSub RunSelectedText
            Return False

        } Else If (wParam == 80) { ; ^P
            ScriptDirectives()
            Return False

        } Else If (wParam == 78) { ; ^N
            NewTab()
            Return False

        } Else If (wParam == 87) { ; ^W
            GoSub CloseTab
            Return False

        } Else If (wParam == 79) { ; ^O
            Open()
            Return False

        } Else If (ShiftP && wParam == 83) { ; ^+S
            SaveAs(TabEx.GetSel())
            Return False

        } Else If (wParam == 83) { ; ^S
            Save(TabEx.GetSel())
            Return False

        } Else If (wParam == 73) { ; ^I
            GoSub ImportGUI
            Return False

        } Else If (wParam == 0x74) { ; ^F5
            ;GoSub DebugRunToCursor
            Return False

        } Else If (wParam == 71) { ; ^G
            ShowGoToLineDialog()
            Return False
        }
    }

    If (ShiftP && wParam == 117) { ; Shift + F6
        GoSub StepOut
        Return False
    }

    If (wParam == 120) { ; F9
        Execute()
        Return False

    } Else If (wParam == 116) { ; F5
        DebugRun()
        Return False

    } Else If (wParam == 117) { ; F6
        GoSub StepInto
        Return False

    } Else If (wParam == 0x70) { ; F1
        OpenHelpFile(GetSelectedText())
        Return False

    } Else If (wParam == 0x7A) { ; F11
        ShowChildWindow()
        Return False

    } Else If (wParam == 0x7B) { ; F12
        If (g_DesignMode) {
            GoSub SwitchToEditorMode
        } Else {
            GoSub SwitchToDesignMode
        }
        Return False

    } Else If (wParam == 0x77) { ; F8
        GoSub DebugStop
        Return False

    } Else If (wParam == 115) { ; F4
        ToggleBreakpoint()
        Return False

    } Else If (wParam == 19) { ; Pause/Break
        GoSub DebugBreak
        Return
    }
}

OnWM_SYSKEYDOWN(wParam, lParam, msg, hWnd) {
    If (WinExist() == hAddMenuItemDlg) {
        Return
    }

    If (wParam == 120) { ; Alt+F9
        RunScript(4)
        Return False
    } Else If (wParam == 116) { ; Alt+F5
        DebugRun(1)
        Return False
    } Else If (wParam == 0x79) { ; F10
        If (IsWindowVisible(hPropWnd)) {
            ShowWindow(hPropWnd, 0)
        } Else {
            GoSub ShowProperties
        }
        Return False
    } Else If (wParam == 71) { ; Alt+G
        GoSub NewGUI
        Return False
    }
}

OnWM_KEYUP(wParam) {
    If (WinExist() == hChildWnd) {
        If (g_Cross && wParam == 17) { ; Ctrl
            g_Cross := False
            DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")) ; IDC_ARROW
        }

        ; Restore the selection after moving controls with the arrow keys
        If (wParam >= 37 && wParam <= 40) {
            GenerateCode()
            UpdateSelection()
        }
    }
}

SwitchToEditorMode:
    g_DesignMode := False

    ShowChildWindow(0)
    ShowWindow(hGUIToolbar, 0)
    ShowWindow(hLVToolbox, 0)
    ShowWindow(hMainToolbar, 1)

    GetClientSize(hAutoWnd, WindowW, WindowH)
    GuiControl Auto: MoveDraw, %hTab%, x0 w%WindowW%

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, SciX, SciY, SciW, SciH, 0, 0x14)
    }

    Repaint(hAutoWnd)

    Sci[TabEx.GetSel()].GrabFocus()

    SetStatusBar() ; ?

    CheckMenuRadioItem(MenuGetHandle("AutoViewMenu"), 0, 0, 1)
    Try {
        Menu AutoMenuBar, Delete, &Control
        Menu AutoMenuBar, Delete, &Layout
        Menu AutoMenuBar, Delete, &Window
    }
Return

SwitchToDesignMode:
    g_DesignMode := True

    If (g_GuiTab == TabEx.GetSel()) {
        ShowWindow(hChildWnd, 1)
    }

    ShowWindow(hLVToolbox, 1)
    ShowWindow(hMainToolbar, 0)
    ShowWindow(hGUIToolbar, 1)
    SendMessage TB_CHECKBUTTON, 1060, 1,, ahk_id %hGUIToolbar%

    Gui Auto: Default
    GetClientSize(hAutoWnd, WindowW, WindowH)
    GuiControlGet ToolBox, Pos, %hLVToolbox%
    SplitterW := (g_TabBarStyle == 1 ? g_SplitterW : g_SplitterW - 2)
    GuiControl MoveDraw, %hTab%, % "x" . (ToolBoxW + SplitterW) . " w" . (WindowW - ToolboxW - SplitterW)

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, SciX, SciY, SciW, SciH, 0, 0x14)
    }

    Repaint(hAutoWnd)

    CheckMenuRadioItem(MenuGetHandle("AutoViewMenu"), 1, 0, 1)
    Menu AutoMenuBar, Insert, 5&, &Window, :AutoWindowMenu
    Menu AutoMenuBar, Insert, 5&, &Layout, :AutoLayoutMenu
    Menu AutoMenuBar, Insert, 5&, &Control, :AutoControlMenu
Return

Open:
    Open()
Return

Open(Files := "", Flag := 0) {
    If (!Files.Length()) {
        n := TabEx.GetSel()
        If (Sci[n].FullName != "") {
            SplitPath % Sci[n].FullName,, StartPath
        } Else {
            StartPath := g_OpenDir
        }

        Gui Auto: +OwnDialogs
        FileSelectFile Files, M3, %StartPath%, Open
        If (ErrorLevel) {
            Return 0
        } Else {
            TempList := StrSplit(Files, "`n")
            BasePath := RTrim(TempList.RemoveAt(1), "\") ; RTrim for root folders

            Files := []
            For Each, FileName in TempList {
                Files.Push(BasePath . "\" . FileName)
            }
        }
    }

    For Each, File in Files {
        ;OutputDebug %A_ThisFunc%: %File%

        n := IsFileOpened(File)
        If (n && !Flag) {
            TabEx.SetSel(n)
            Continue
        }

        _Open:
        Try {
            fOpen := FileOpen(File, "r", "UTF-8-RAW")

            fEncoding := fOpen.Position ? fOpen.Encoding : "UTF-8-RAW"

            fRead := fOpen.Read()

            fOpen.Close()
        } Catch e {
            MsgBox 0x16
            , Error %A_LastError%
            , % (File != "" ? File . "`n" : "") . e.Message . "`n" . e.Extra
            IfMsgBox TryAgain, {
                GoTo _Open
            } Else IfMsgBox Continue, {
                Continue
            } Else {
                Return 0
            }
        }

        SplitPath File, Filename, g_OpenDir, FileExt
        AhkExt := FileExt = "AHK"

        If (Flag == 1 && AhkExt) {
            Gosub NewGUI
            ParseScript(fRead) ; Import GUI

        } Else {
            n := TabEx.GetSel()
            Icon := AhkExt ? 2 : IL_Add(TabExIL, "HICON:" . GetFileIcon(File))

            If (Flag == 0 && (Sci[n].Filename != "" || Sci[n].GetModify() || n == g_GuiTab)) {
                n := NewTab(Icon, Filename)

            } Else {
                SetWindowTitle(File)
                TabEx.SetText(n, Filename)
                TabEx.SetIcon(n, Icon)
            }

            If (!IsAhkFileExt(FileExt)) {
                Sci[n].SetLexer(0)
            }

            Sci[n].FullName := File
            Sci[n].Filename := Filename
            Sci[n].Encoding := fEncoding
            Sci[n].SetText("", fRead, 1)
            Sci[n].SetSavePoint()

            If (Flag == 0) {
                Sci[n].EmptyUndoBuffer()
            }

            FileGetTime Timestamp, %File%
            Sci[n].LastWriteTime := Timestamp
        }

        fRead := ""

        AddToRecentFiles(File)
    }

    Return n
}

SaveAs:
    SaveAs(TabEx.GetSel())
Return

SaveAs(n) {
    TabEx.SetSel(n)

    StartPath := (Sci[n].FileName != "") ? Sci[n].FullName : g_SaveDir
    Gui Auto: +OwnDialogs
    FileSelectFile SelectedFile, S16, %StartPath%, Save, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel) {
        Return
    }

    SplitPath SelectedFile, Filename,, FileExt
    If (FileExt == "" && !FileExist(SelectedFile . ".ahk")) {
        SelectedFile .= ".ahk"
        Filename .= ".ahk"
        FileExt := "ahk"
    }

    Sci[n].FullName := SelectedFile
    Sci[n].Filename := Filename

    If (!IsAhkFileExt(FileExt) || Sci[n].GetLexer() != SCLEX_AHKL) {
        Sci[n].SetLexer(0)
        DisableSyntaxHighlighting(n)
    } Else {
        Sci_Config(n)
    }

    SetWindowTitle(SelectedFile)

    Return Save(n)
}

Save:
    Save(TabEx.GetSel())
Return

Save(n) {
    If (Sci[n].Filename == "") {
        Return SaveAs(n)
    }

    SciText  := GetText(n)
    FullPath := Sci[n].FullName
    Encoding := GetSaveEncoding(n)

    ; Backup a copy of the file before saving
    If (g_BackupOnSave) {
        If (BackupDirCreated()) {
            TempName := GetTempFileName(g_BackupDir, "ahk.tmp")
            If (FileExist(FullPath)) {
                FileCopy %FullPath%, %TempName%, 1
            } Else {
                FileAppend %SciText%, %TempName%, %Encoding%
            }
        }
    }

    If (WriteFile(FullPath, SciText, Encoding) < 0) {
        SetWindowTitle("Error saving file: " . FullPath)
        Return 0
    }

    Sci[n].SetSavePoint()
    SetDocumentStatus(n)
    TabEx.SetIcon(n, GetIconForTab(n))

    SplitPath FullPath,, g_SaveDir
    If (n == g_GuiTab) {
        CopyLibraries(g_SaveDir)
    }

    AddToRecentFiles(FullPath)

    Repaint(Sci[n].hWnd) ; ?

    FileGetTime Timestamp, %FullPath%
    Sci[n].LastWriteTime := Timestamp

    Return 1
}

SaveAll:
    Loop % Sci.Length() {
        If (Sci[A_Index].GetModify()) {
            Save(A_Index)
        }
    }
Return

SaveCopy:
    n := TabEx.GetSel()
    If (Sci[n].FileName != "") {
        SplitPath % Sci[n].FullName,, Dir, Extension, NameNoExt
        StartPath := Dir . "\" . NameNoExt . " - Copy." . Extension
    } Else {
        StartPath := g_SaveDir
    }

    Gui Auto: +OwnDialogs
    FileSelectFile SelectedFile, S16, %StartPath%, Save a Copy, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel) {
        Return
    }

    SplitPath SelectedFile,,, FileExt
    If (FileExt == "" && Sci[n].GetLexer() == SCLEX_AHKL && !FileExist(SelectedFile . ".ahk")) {
        SelectedFile .= ".ahk"
    }

    SciText := GetText(n)
    Encoding := GetSaveEncoding(n)
    WriteFile(SelectedFile, SciText, Encoding)

    AddToRecentFiles(SelectedFile)
Return

CopyLibraries(Dir) {
    If (g.Anchor) {
        FileCopy %A_ScriptDir%\Lib\AutoXYWH.ahk, %Dir%\AutoXYWH.ahk
    }

    If (ToolbarExist()) {
        FileCopy %A_ScriptDir%\Lib\Toolbar.ahk, %Dir%\Toolbar.ahk
    }

    If (g.ControlColor) {
        FileCopy %A_ScriptDir%\Lib\ControlColor.ahk, %Dir%\ControlColor.ahk
    }
}

RunScript:
    RunScript(A_ThisMenuItemPos)
Return

RunScript(Mode := 1) {
    n := TabEx.GetSel()

    AhkPath := (GetKeyState("Shift", "P") || Mode == 2) ? g_AhkPath3264 : A_AhkPath

    SciText := GetText(n)

    Params := Sci[n].Parameters

    ; Run Selected Text (Ctrl+F9)
    If (Mode == 5) {
        Text := GetSelectedText()
        If (Text == "") {
            Text := SciText
        }
        ExecScript(Text, Params, AhkPath)
        Return
    }

    ; Alternative run (Alt+F9)
    If (Mode == 4) {
        If ((AhkPath := GetAltRun()) == "") {
            Return
        }
    }

    If (Sci[n].Filename != "") {
        If (Sci[n].GetModify()) {
            If (!Save(n)) {
                Return
            }
        }
        FullPath := Sci[n].FullName
        SplitPath FullPath,, WorkingDir
    } Else {
        ; Unsaved scripts run from the Temp folder
        FullPath := g_TempFile
        WorkingDir := A_Temp
        FileDelete %FullPath%
        FileAppend %SciText%, %FullPath%, %A_FileEncoding%
        CopyLibraries(WorkingDir)
    }

    FixRootDir(WorkingDir)

    If (g_CaptureStdErr) {
        AhkRunGetStdErr(n, AhkPath, FullPath, Params, WorkingDir)
    } Else {
        Run % AhkPath . " """ . FullPath . """ " . Params, %WorkingDir%
    }
}

RunSelectedText:
    RunScript(5)
Return

GetAltRun() {
    Return FileExist(g_AltAhkPath) ? g_AltAhkPath : BrowseForAltRun()
}

BrowseForAltRun() {
    StartPath := FileExist(g_AltAhkPath) ? g_AltAhkPath : A_ProgramFiles
    Gui Auto: +OwnDialogs
    FileSelectFile AltAhkPath, 3, %StartPath%, Select File, Executable Files (*.exe)
    Return ErrorLevel ? "" : g_AltAhkPath := AltAhkPath
}

ShowParamsDlg() {
    n := TabEx.GetSel()

    Info := "Parameters are stored in the variables %1%, %2%, and so on.`n"
         .  "They are also stored as an array in the built-in variable A_Args.`n"
         .  "See the online <a href=""https://autohotkey.com/docs/Scripts.htm#cmd"">help topic</a> for details."

    Params := InputBoxEx("Script Parameters", Info, "Command Line Parameters", Sci[n].Parameters
    , "", "-Wrap", hAutoWnd, 500, "", IconLib, 91)
    If (!ErrorLevel) {
        Sci[n].Parameters := Params
    }
}

Compile() {
    SplitPath A_AhkPath,, AhkDir
    Ahk2ExePath := AhkDir . "\Compiler\Ahk2Exe.exe"

    Run %Ahk2ExePath%,, UseErrorLevel, PID
    If (ErrorLevel) {
        ErrorMsgBox(GetErrorMessage(A_LastError), "Auto")
        Return
    }

    n := TabEx.GetSel()
    AhkScript := Sci[n].FullName

    If (AhkScript && !Sci[n].GetModify()) {
        SplitPath AhkScript,, ScriptDir,, NameNoExt

        SetBatchLines 20ms
        Sleep 100

        WinWait Ahk2Exe ahk_pid %PID%
        WinGet hWnd, ID, Ahk2Exe ahk_pid %PID%
        WinActivate ahk_id %hWnd%
        WinWaitActive ahk_id %hWnd%

        ControlSetText Edit1, %AhkScript%, ahk_id %hWnd%

        If (!FileExist(ExeFile := ScriptDir . "\" . NameNoExt . ".exe")) {
            ControlSetText Edit2, %ExeFile%, ahk_id %hWnd%
        }

        SetBatchLines -1
    }
}

AddMenu(MenuName, MenuItemName := "", Subroutine := "MenuHandler", Icon := "", IconIndex := 0) {
    Menu, %MenuName%, Add, %MenuItemName%, %Subroutine%

    If (Icon != "") {
        Menu, %MenuName%, Icon, %MenuItemName%, %Icon%, %IconIndex%
    }
}

MenuHandler:
    Gui Auto: +OwnDialogs
    MsgBox 0x40, AutoGUI, Not implemented yet.
Return

AddToRecentFiles(FileName) {
    Static RecentFilesMenu := 0, MaxItems := 15

    If (!FileExist(FileName)) {
        Return
    }

    ; Determine the handle of the Recent Files menu
    If !(RecentFilesMenu) {
        hAutoMenu := GetMenu(hAutoWnd)
        hFileMenu := GetSubMenu(hAutoMenu, 0)
        FileMenuCount := GetMenuItemCount(hFileMenu)
        Loop %FileMenuCount% {
            If (GetMenuString(hFileMenu, A_Index - 1) = "Recent &Files") {
                RecentFilesMenu := GetSubMenu(hFileMenu, A_Index - 1)
                Break
            }
        }
    }

    MaxIndex := RecentFiles.Length()
    Loop %MaxIndex% {
        ; The drive letter may be uppercase or lowercase
        If (FileName = RecentFiles[A_Index]) {
            Try {
                Menu AutoRecentMenu, Delete, %FileName%
            }
            RecentFiles.RemoveAt(A_Index)
            Break
        }
    }
    RecentFiles.Push(FileName)

    Menu AutoFileMenu, Enable, Recent &Files
    Menu AutoRecentMenu, Insert, 1&, %FileName%, OpenRecentFile
    Try {
        Menu AutoRecentMenu, Icon, %Filename%, % "HICON:" . GetFileIcon(Filename)
    }
    Menu AutoFileMenu, Add, Recent &Files, :AutoRecentMenu

    ItemCount := GetMenuItemCount(RecentFilesMenu)
    If (ItemCount > MaxItems) {
        DeleteMenu(RecentFilesMenu, ItemCount - 1)
        RecentFiles.Remove(1)
    }
}

OpenRecentFile:
    Open([A_ThisMenuItem])
Return

LoadRecentFiles() {
    IniRead Recent, %IniFile%, Recent
    If (Recent != "ERROR") {
        Loop Parse, Recent, `n
        {
            RecentFile := SubStr(A_LoopField, InStr(A_LoopField, "=") + 1)
            AddToRecentFiles(RecentFile)
        }
    }
}

HelpMenuHandler:
    If (A_ThisMenuItem == "AutoHotkey &Help File`tF1") {
        Run %g_HelpFile%
        Return
    }

    Node := g_HelpMenuXMLObj.selectSingleNode("//MenuItem[@name=""" . A_ThisMenuItem . """]")
    URL := Node.getAttribute("url")
    If (SubStr(URL, 1, 1) == "/") {
        Run HH mk:@MSITStore:%g_HelpFile%::%URL%
    } Else {
        Try {
            Run %URL%
        }
    }
Return

ShowAbout:
    Gui About: New, LabelAbout -MinimizeBox OwnerAuto
    Gui Color, White
    Gui Add, Picture, x9 y10 w64 h64, %IconLib%
    Gui Font, s20 W700 Q4 c00ADEF, Verdana
    Gui Add, Text, x80 y8 w200, Adventure
    Gui Font
    Gui Font, s9, Segoe UI
    Gui Add, Text, x245 y23, v%g_Version%
    FileGetVersion SciVer, %SciLexer%
    Gui Add, Text, x81 y41, Scintilla %SciVer%
    Gui Add, Text, x81 y58 w365 +0x4000, % "AutoHotkey " . A_AhkVersion . " " . (A_IsUnicode ? "Unicode" : "ANSI") . " " . (A_PtrSize == 8 ? "64-bit" : "32-bit")
    Gui Add, Link, x81 y102 w200 h16, <a href="https://sourceforge.net/projects/autogui/">SourceForge Project Page</a>
    Gui Add, Link, x81 y124 w200 h16, <a href="https://autohotkey.com/boards/viewforum.php?f=64">AutoGUI in the AHK Forum</a>
    Gui Add, Link, x81 y146 w200 h16, <a href="Help\Credits.htm">Credits</a>
    Gui Add, Text, x0 y189 w463 h1 +0x5
    Gui Add, Text, x0 y190 w463 h48 -Background
    Gui Add, Link, x16 y206 w87 h16 -Background, <a href="https://autohotkey.com">autohotkey.com</a>
    Gui Add, Button, gAboutClose x371 y203 w80 h24 Default, OK
    Gui Show, w463 h239, About
    ControlFocus Button1, About
    Gui +LastFound
    SendMessage 0x80, 0, DllCall("LoadIcon", "Ptr", 0, "Ptr", 32516, "Ptr") ; WM_SETICON, OIC_INFORMATION
    SetModalWindow(1)
Return

AboutEscape:
AboutClose:
    SetModalWindow(0)
    Gui About: Destroy
Return

CreateTabContextMenu() {
    AddMenu("TabContextMenu", "Close Tab", "CloseTabN", IconLib, -8)
    Menu TabContextMenu, Add
    AddMenu("TabContextMenu", "Duplicate Tab Contents", "DuplicateTab", IconLib, -7)
    AddMenu("TabContextMenu", "Open Folder in Explorer", "OpenFolder", IconLib, -9)
    AddMenu("TabContextMenu", "Copy Path to Clipboard", "CopyFilePath", IconLib, -11)
    AddMenu("TabContextMenu", "Open in a New Window", "OpenNewInstance", IconLib, -1)
    Menu TabContextMenu, Add
    If (g_ShellMenu2) {
        Menu TabContextMenu, Add, Explorer Context Menu, ShowShellMenuDlg
    } Else {
        AddMenu("TabContextMenu", "File Properties", "ShowFileProperties", IconLib, -25)
    }
}

ShowTabContextMenu() {
    Local FullPath, State, hTabContextMenu, hShellMenu := 0, Filename, X, Y, ItemID, WorkingDir, Verb

    FullPath := Sci[g_TabIndex].FullName
    State := FileExist(FullPath) ? "Enable" : "Disable"
    Menu TabContextMenu, %State%, Open Folder in Explorer
    Menu TabContextMenu, %State%, Copy Path to Clipboard
    Menu TabContextMenu, %State%, Open in a New Window
    Try {
        Menu TabContextMenu, %State%, File Properties
    }

    hTabContextMenu := MenuGetHandle("TabContextMenu")

    If (g_ShellMenu2) {
        hShellMenu := GetShellContextMenu(FullPath, GetKeyState("Shift", "P") ? 0x100 : 0)

        Filename := Sci[g_TabIndex].Filename
        DllCall("InsertMenu", "Ptr", hShellMenu, "Uint", 0, "Uint", 0x0400|0x800, "Ptr", 0, "Ptr", 0)
        DllCall("InsertMenu", "Ptr", hShellMenu, "Uint", 0, "Uint", 0x0400|0x002, "Ptr", 0, "Ptr", &Filename)

        DllCall("ModifyMenu", "Ptr", hTabContextMenu, "UInt", g_ShellMenu2Pos
        , "UInt", 0x410 | (State == "Enable" ? 0 : 1), "UPtr", hShellMenu, "Str", "Explorer Context Menu")
    }

    GetMousePos(X, Y, "Screen")

    ItemID := ShowPopupMenu(hTabContextMenu, 0x100, X, Y, g_hShellWnd)

    If (!ItemID) {
        DestroyShellMenu(hShellMenu)
        Return

    } Else If (ItemID < 11000 && hShellMenu) {
        WorkingDir := GetFileDir(FullPath)

        Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
        OutputDebug Shell context menu item: ID: %ItemID%, Verb: "%Verb%".

        If (Verb == "paste") {
            PasteFile(WorkingDir)

        } Else {
            If (Sci[g_TabIndex].GetModify()) {
                Gui Auto: +OwnDialogs
                MsgBox 0x4, %g_AppName%, Save the file before proceeding with the requested action?
                IfMsgBox Yes, {
                    If (!Save(g_TabIndex)) {
                        DestroyShellMenu(hShellMenu)
                        Return
                    }
                }
            }

            RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, hAutoWnd, X, Y)
        }

    } Else { ; IDs attributed by AHK start at 11003
        SendMessage 0x111, %ItemID%, 0,, ahk_id %hAutoWnd% ; WM_COMMAND
    }

    If (g_ShellMenu2) {
        DestroyShellMenu(hShellMenu)
    }
}

OpenFolder() {
    FullPath := Sci[g_TabIndex].FullName
    If (FileExist(FullPath)) {
        Run *open explorer.exe /select`,"%FullPath%"
    }
}

CopyFilePath:
    Clipboard := Sci[g_TabIndex].FullName
Return

ShowFileProperties:
    Run % "Properties " . Sci[g_TabIndex].FullName
Return

; SetMainWindowTitle
SetWindowTitle(Filename := "") {
    If (FileName != "") {
        WinSetTitle ahk_id%hAutoWnd%,, % g_AppName . " v" . g_Version . " - " . Filename
    } Else {
        WinSetTitle ahk_id%hAutoWnd%,, %g_AppName% v%g_Version%
    }
}

OnWM_CTLCOLORSTATIC(wParam, lParam) {
    If (IsResizer(lParam)) {
        DllCall("SetBkColor", "Ptr", wParam, "UInt", 0)
        Return g_ResizerBrush
    }
}

OnWM_SETCURSOR(wParam, lParam, Msg, hWnd) {
    If (g_Cursors[wParam]) {
        hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", g_Cursors[wParam], "Ptr")
        DllCall("SetCursor", "Ptr", hCursor)
        Return True
    }

    If (g_Cross && hWnd == hChildWnd) {
        DllCall("SetCursor", "Ptr", hCursorCross)
        Return True
    }

    If (!g_Adding) {
        If (hWnd == hChildWnd && wParam != hChildWnd && GetKeyState("LButton", "P")) {
            hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32646, "Ptr") ; IDC_SIZEALL
            DllCall("SetCursor", "Ptr", hCursor)
            Return True
        }
    }
}

OnWM_LBUTTONUP(wParam, lParam, msg, hWnd) {
    g_LButtonDown := 0
    g_Adding := False
}

SetModalWindow(Modal := True) {
    Global
    If (Modal) {
        Gui Auto: +Disabled
        Gui %Child%: +Disabled
        Gui Properties: +Disabled
        OnMessage(0x100, "")
        OnMessage(0x104, "")
    } Else {
        Gui Auto: -Disabled
        Gui %Child%: -Disabled
        Gui Properties: -Disabled
        OnMessage(0x100, "OnWM_KEYDOWN")
        OnMessage(0x104, "OnWM_SYSKEYDOWN")
    }
}

SuspendAutoComplete:
    g_AutoCEnabled := True
Return

SendFile(Filename, hPrevInst) {
    Loop 10 {
        If (SendData(Filename, hPrevInst) == True) {
            Break
        } Else {
            Sleep 100
        }
    }
}

SendData(ByRef String, ByRef hWnd) {
    VarSetCapacity(COPYDATASTRUCT, 3 * A_PtrSize, 0)
    cbSize := (StrLen(String) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(cbSize, COPYDATASTRUCT, A_PtrSize)
    NumPut(&String, COPYDATASTRUCT, 2 * A_PtrSize)
    SendMessage 0x4A, 0, &COPYDATASTRUCT,, ahk_id %hWnd%
    Return ErrorLevel
}

OnWM_COPYDATA(wParam, lParam, msg, hWnd) {
    Data := StrGet(NumGet(lParam + 2 * A_PtrSize)) ; COPYDATASTRUCT lpData
    Open([Data])
    Return True
}

ShowImportGUIDialog:
    Gui ImportGUIDlg: New, LabelImportGUIDlg hWndhImportGUIDlg -MinimizeBox OwnerAuto
    SetWindowIcon(hImportGUIDlg, IconLib, 40)
    Gui Color, 0xFAFAFA
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x12 y12 w409 h21, Select the Import Method
    Gui Font
    Gui Font, s9, Segoe UI
    Gui Add, Text, x12 y39 w498 h23 +0x200
    , Warning: none of these methods preserve the entire script. Do not overwrite the original file.
    Gui Add, Radio, vClone x22 y73 w368 h23 Checked, Clone Window
    Gui Add, Radio, vParse x22 y105 w368 h23, Parse Script (Not Recommended)
    Gui Add, Text, x-1 y146 w525 h48 Border -Background
    Gui Add, Button, gImportGUIDlgOK x343 y158 w80 h23 +Default, &OK
    Gui Add, Button, gImportGUIDlgClose x429 y158 w80 h23, &Cancel
    Gui Show, w523 h193, Import GUI
Return

ImportGUIDlgEscape:
ImportGUIDlgClose:
    Gui ImportGUIDlg: Cancel
Return

ImportGUIDlgOK:
    Gui ImportGUIDlg: Submit

    If (Clone) {
        GoSub ShowCloneDialog
    } Else {
        FileSelectFile FileName, 1, %g_OpenDir%, Open, AutoHotkey Scripts (*.ahk)
        If (!ErrorLevel) {
            Open([FileName], 1)
        }
    }
Return

OnWM_ENTERMENULOOP() {
    Return 1 ; Prevent repainting problems on XP?
}

OnWM_INITMENU(wParam) {
    ; OutputDebug % MenuGetName(wParam) ; Always returns "AutoMenuBar"
    n := TabEx.GetSel()

    ; Includes
    Try {
        Menu AutoFileMenu, % Sci[n].Filename != "" ? "Enable" : "Disable", Open Included File...
    }

    ; Encoding
    Encoding := GetFileEncodingDisplayName(n)
    Loop %g_MaxEncodings% {
        Try {
            Menu AutoEncodingMenu, Uncheck, %A_Index%&
        }
    }
    Try {
        Menu AutoEncodingMenu, Check, %Encoding%
    }

    ; Sessions
    LoadSessionMenu()

    ; Lexer
    Loop % g_Lexers.Length() {
        Try {
            Menu AutoLexerMenu, Uncheck, %A_Index%&
        }
    }
    Lexer := g_Lexers[Sci[n].GetLexer()]
    If (Lexer != "") {
        Try {
            Menu AutoLexerMenu, Check, %Lexer%
        }
    }
}

OnWM_ACTIVATEAPP(wParam, lParam, msg, hWnd) {
    If (wParam) {
        CheckModified()
    }

    Return 0
}

RestoreWindow() {
    WinGet WinState, MinMax, ahk_id %hAutoWnd%
    If (WinState == -1) { ; Minimized
        WinRestore ahk_id %hAutoWnd%
    }
}

CheckModified() {
    n := TabEx.GetSel()

    If (Sci[n].LastWriteTime == "" || Sci[n].ChangedOutside) {
        Sci[n].ChangedOutside := False
        Return 0
    }

    If (g_CheckTimestamp) {
        ; Check if the file exists
        If (Sci[n].Filename != "" && !FileExist(Sci[n].FullName)) {
            OnMessage(0x1C, "")
            RestoreWindow()
            Gui Auto: +OwnDialogs
            MsgBox 0x40030, %g_AppName%, % "File not found: " . Sci[n].FullName
            Sci[n].LastWriteTime := ""
            OnMessage(0x1C, "OnWM_ACTIVATEAPP")
            Return
        }

        Filename := Sci[n].FullName
        FileGetTime Timestamp, %Filename%

        ; Check if the file has been modified outside
        If (Timestamp != Sci[n].LastWriteTime) {
            Sci[n].ChangedOutside := True

            OnMessage(0x1C, "")

            RestoreWindow()
            Gui Auto: +OwnDialogs
            MsgBox 0x34, %g_AppName%, % Sci[n].Filename . " was modified outside.`nShould the file be reloaded?"
            IfMsgBox Yes, {
                CurrentPos := Sci[n].GetCurrentPos()
                Open([Filename], 2)
                Sci[n].GoToPos(CurrentPos)
            } Else {
                Sci[n].ChangedOutside := False
                Return 0
            }

            OnMessage(0x1C, "OnWM_ACTIVATEAPP")
        }
    }
}

AutoSizeWindow:
    Gui %Child%: Margin, 8, 8
    Gui %Child%: Show, AutoSize
    GenerateCode()
Return

LoadToolsMenu() {
    If (FileExist(A_AppData . "\AutoGUI\Tools.ini")) {
        g_IniTools := A_AppData . "\AutoGUI\Tools.ini"
    } Else {
        g_IniTools := A_ScriptDir . "\Tools\Tools.ini"

        If (!FileExist(g_IniTools)) {
            FileCopy %A_ScriptDir%\Tools\DefaultTools.ini, %A_ScriptDir%\Tools\Tools.ini
            If (ErrorLevel) {
                FileCreateDir %A_AppData%\AutoGUI
                FileCopy %A_ScriptDir%\Tools\DefaultTools.ini, %A_AppData%\AutoGUI\Tools.ini
                g_IniTools := A_AppData . "\AutoGUI\Tools.ini"
            }
        }
    }

    IniRead IniSections, %g_IniTools%

    Loop Parse, IniSections, `n, `r
    {
        IniRead Icon, %g_IniTools%, %A_LoopField%, Icon, %A_Space%
        IniRead IconIndex, %g_IniTools%, %A_LoopField%, IconIndex, 1
        Try {
            AddMenu("AutoToolsMenu", A_LoopField, "RunTool", GetToolIconPath(Icon), IconIndex)
        }
    }

    Menu AutoToolsMenu, Add
    AddMenu("AutoToolsMenu", "Configure Tools...", "ShowToolsDialog", IconLib, -43)
}

RunTool() {
    IniRead File, %g_IniTools%, %A_ThisMenuItem%, File, %A_Space%
    If (!FileExist(File)) {
        If (FileExist(A_ScriptDir . "\Tools\" . File)) {
            File = %A_ScriptDir%\Tools\%File%
        }
    }

    IniRead WorkingDir, %g_IniTools%, %A_ThisMenuItem%, WorkingDir, %A_Space%
    If (WorkingDir == "") {
        WorkingDir := GetFileDir(File)
    }

    Params := ReadIni(g_IniTools, A_ThisMenuItem, "Params", "")
    If (Params != "") {
        n := TabEx.GetSel()

        If (InStr(Params, "{FILENAME}")) {
            Params := StrReplace(Params, "{FILENAME}", Sci[n].FullName)
        }

        If (InStr(Params, "{FILEDIR}")) {
            SplitPath % Sci[n].FullName,, FileDir
            Params := StrReplace(Params, "{FILEDIR}", FileDir)
        }

        If (InStr(Params, "{SELECTEDTEXT}")) {
            Params := StrReplace(Params, "{SELECTEDTEXT}", GetSelectedText())
        }

        If (InStr(Params, "{AUTOGUIDIR}")) {
            Params := StrReplace(Params, "{AUTOGUIDIR}", A_ScriptDir)
        }
    }

    Try {
        Run "%File%" %Params%, %WorkingDir%
    } Catch {
        ErrorMsgBox("Error executing """ . File . """.", "Auto", g_AppName)
        GoSub ShowToolsDialog
    }
}

ShowIncludesDialog:
    Gui IncludesDlg: New, LabelIncludesDlg hWndhIncludesDlg -MinimizeBox OwnerAuto
    SetWindowIcon(hIncludesDlg, IconLib, 101)
    Gui Color, White

    Gui Font, s12 cNavy, Segoe UI
    Gui Add, Text, x8 y9 w120 h22 +0x200, List of Includes
    Gui Font
    Gui Font, s9, Segoe UI
    Gui Add, Text, x8 y32 w285 h20 +0x200, Select the files to be opened.

    Gui Add, ListView, hWndhLVIncludes x0 y60 w620 h294 +LV0x114004, Filename|Path
    Gui Add, Text, x0 y355 w620 h48 -Background
    Gui Add, Button, gOpenIncludes x433 y366 w84 h24 +Default, &Open
    Gui Add, Button, gIncludesDlgClose x525 y366 w84 h24, &Cancel
    Gui Font
    Gui Show, w620 h402, Open Included File

    LV_ModifyCol(1, 174)
    LV_ModifyCol(2, 425)
    SetExplorerTheme(hLVIncludes)

    FullName := Sci[TabEx.GetSel()].FullName
    If (FullName != "") {
        Try {
            EnumIncludes(FullName, Func("EnumIncludesCallback"))
        }
    }
Return

EnumIncludesCallback(Param) {
    SplitPath Param, Filename, FilePath
    LV_Add("", Filename, FilePath)
    Return True ; must return true to continue enumeration
}

IncludesDlgEscape:
IncludesDlgClose:
    Gui IncludesDlg: Destroy
Return

OpenIncludes() {
    Files := []
    Row := 0
    Loop {
        Row := LV_GetNext(Row, "Checked")
        If (!Row) {
            Break
        }

        LV_GetText(Filename, Row, 1)
        LV_GetText(FilePath, Row, 2)
        Files.Push(FilePath . "\" . Filename)
    }

    If (Files.Length()) {
        Open(Files)
    }

    Gui IncludesDlg: Destroy
}

SetSessionsDir() {
    If (g_SessionsDir == "ERROR" || !FileExist(g_SessionsDir)) {
        If (FileExist(A_AppData . "\AutoGUI\Sessions\*.session")) {
            g_SessionsDir := A_AppData . "\AutoGUI\Sessions"
        } Else {
            g_SessionsDir := A_ScriptDir . "\Sessions"
            FileCreateDir %g_SessionsDir%
            If (ErrorLevel) { ; No permission to write in the application folder
                g_SessionsDir := A_AppData . "\AutoGUI\Sessions"
                FileCreateDir %g_SessionsDir%
            }
        }
    }
}

LoadSessionMenu() {
    hMenu := MenuGetHandle("AutoSessionMenu")
    If (hMenu) {
        Loop % GetMenuItemCount(hMenu) {
            Menu AutoSessionMenu, Delete, 1&
        }
    }

    MostRecentFile := ""
    MostRecentDate := 0
    ItemCount := 0
    Loop %g_SessionsDir%\*.session
    {
        SplitPath A_LoopFileName,,,, NameNoExt

        If (A_LoopFileTimeModified > MostRecentDate) {
            MostRecentDate := A_LoopFileTimeModified
            MostRecentFile := NameNoExt
        }

        Menu AutoSessionMenu, Add, %NameNoExt%, M_LoadSession
        ItemCount++
    }

    If (ItemCount > 1) {
        Menu AutoSessionMenu, Delete, %MostRecentFile%
        Menu AutoSessionMenu, Insert, 1&, %MostRecentFile%, M_LoadSession
    }

    If (ItemCount) {
        Menu AutoSessionMenu, Default, %MostRecentFile%
        Menu AutoSessionMenu, Add
    }

    AddMenu("AutoSessionMenu", "Open Sessions Folder", "OpenSessionsFolder", IconLib, -9)
    If (!FileExist(g_SessionsDir . "\*.session")) {
        Menu AutoSessionMenu, Disable, Open Sessions Folder
    }

    Menu AutoFileMenu, Add, &Load Session, :AutoSessionMenu
}

M_LoadSession() {
    SessionFile = %g_SessionsDir%\%A_ThisMenuItem%.session
    LoadSession(SessionFile)
}

LoadSession(SessionFile) {
    Files := []
    Active := 1
    If (FileExist(SessionFile)) {
        FileRead Session, %SessionFile%
        Loop Parse, Session, `n, `r
        {
            Fields := StrSplit(A_LoopField, "|")
            If (FileExist(Fields[1])) {
                Files.Push(Fields[1])
            }

            If (Fields[2]) {
                Active := A_Index
            }
        }
    }

    If (Files.Length()) {
        If (Sci[TabEx.GetSel()].GetModify()) {
            Active += TabEx.GetCount()
        } Else {
            Active += TabEx.GetCount() - 1
        }

        Open(Files)
        Sleep -1
        TabEx.SetSel(Active)
        FileSetTime %A_Now%, %SessionFile%
    }
}

LoadLastSession() {
    MostRecentFile := ""
    MostRecentDate := 0
    Loop %g_SessionsDir%\*.session
    {
        If (A_LoopFileTimeModified > MostRecentDate) {
            MostRecentDate := A_LoopFileTimeModified
            MostRecentFile := A_LoopFileLongPath
        }
    }

    LoadSession(MostRecentFile)
}

SaveSessionOnExit:
SaveSession:
    n := TabEx.GetSel()
    Session := ""
    Loop % Sci.Length() {
        Active := n == A_Index ? 1 : 0
        Filename := Sci[A_Index].FullName
        If (FileExist(Filename)) {
            Session .= Filename . "|" . Active . CRLF
        }
    }

    Session := RTrim(Session, CRLF)

    If (A_ThisLabel == "SaveSession") {
        Filename := g_SessionsDir . "\Session Name.session"
        FileSelectFile Filename, S16, %Filename%, Save Session, Session Files (*.session)
        If (ErrorLevel) {
            Return
        }

        SplitPath Filename,,, Ext
        If (!(Ext = "session") && !FileExist(Filename . ".session")) {
            Filename .= ".session"
        }
    } Else {
        Filename := g_SessionsDir . "\Session Saved on Exit.session"
    }

    FileDelete %Filename%
    FileAppend %Session%, %Filename%, UTF-8
    If (ErrorLevel) {
        ErrorMsgBox("Error saving """ . Filename . """.", "Auto", g_AppName)
    }
Return

OpenSessionsFolder:
    Run %g_SessionsDir%
Return

OpenNewInstance() {
    FullPath := Sci[g_TabIndex].FullName
    Run "%A_AhkPath%" "%A_ScriptFullPath%" /new "%FullPath%"
}

Sci_GetIdealSize(ByRef X, ByRef Y, ByRef W, ByRef H) {
    GetClientSize(hAutoWnd, WindowW, WindowH)
    GuiControlGet, ToolBox, Auto: Pos, %hLVToolbox%
    GuiControlGet, TabCtl, Auto: Pos, %hTab%

    If (g_TabBarPos == 1) { ; Top
        Y := TabCtlY + TabCtlH
        H := WindowH - g_StatusBarH - Y
    } Else {
        Y := g_ToolbarH
        H := WindowH - g_StatusBarH - TabCtlH - Y
    }

    X := (g_DesignMode) ? ToolBoxW + g_SplitterW : -1
    W := (g_DesignMode) ? WindowW - ToolBoxW - g_SplitterW : WindowW + 1
}

CreateTabControl:
    GetClientSize(hAutoWnd, WindowW, WindowH)
    If (g_DesignMode) {
        GuiControlGet, ToolBox, Auto: Pos, %hLVToolbox%
        SplitterW := (g_TabBarStyle == 1 ? g_SplitterW : g_SplitterW - 2)
        TabX := ToolboxW + SplitterW
        TabW := WindowW - ToolboxW - SplitterW
    } Else {
        TabX := 0
        TabW := WindowW
    }

    Style := "+AltSubmit -Wrap -TabStop +0x2008000" . (g_TabBarStyle == 1 ? " +Theme" : " +Buttons")

    If (g_TabBarPos == 1) {
        Gui Add, Tab2, hWndhTab gTabHandler x%TabX% y%g_ToolbarH% w%TabW% h25 %Style%, Untitled 1
    } Else {
        TabY := WindowH - g_StatusBarH - 25
        Gui Add, Tab2, hWndhTab gTabHandler x%TabX% y%TabY% w%TabW% h25 %Style%, Untitled 1
    }

    SendMessage 0x1329, 0, 0x00180055,, ahk_id %hTab% ; TCM_SETITEMSIZE (0x18 = 24)

    Ptr := A_PtrSize == 8 ? "Ptr" : ""
    Global OldTabProc := DllCall("GetWindowLong" . Ptr, "Ptr", hTab, "Int", -4, "Ptr") ; GWL_WNDPROC
    NewTabProc := RegisterCallback("NewTabProc", "", 4) ;
    DllCall("SetWindowLong" . Ptr, "Ptr", hTab, "Int", -4, "Ptr", NewTabProc, "Ptr")

    TabEx := New GuiTabEx(hTab)
    TabExIL := IL_Create(3)
    IL_Add(TabExIL, IconLib, 3)   ; Unsaved file
    IL_Add(TabExIL, A_AhkPath, 2) ; AHK default icon
    IL_Add(TabExIL, IconLib, 5)   ; GUI icon
    TabEx.SetImageList(TabExIL)
    TabEx.SetIcon(1, 1)
    TabEx.SetPadding(5, 4)

    Gui Tab
Return

; Adapted from AkelPad
NewTabProc(hWnd, msg, wParam, lParam) {
    Static s_MouseMove := 0

    If (msg == 0x201) { ; WM_LBUTTONDOWN
        TabIndex := TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16)

        If (TabIndex) {
            s_MouseMove := 4
            If (!g_MouseCapture) {
                g_MouseCapture := 1
                DllCall("SetCapture", "Ptr", hWnd)
            }

            If (TabIndex != TabEx.GetSel()) {
                TabEx.SetSel(TabIndex)
            }
        }
        Return True

    } Else If (msg == 0x200) { ; WM_MOUSEMOVE
        If (g_MouseCapture) {
            If (s_MouseMove > 0) {
                If (--s_MouseMove == 0) {
                    DllCall("SetCursor", "Ptr", hCursorDragMove)
                }
            }
            Return True
        }

    } Else If (msg == 0x202) { ; WM_LBUTTONUP
        If (g_MouseCapture) {
            g_MouseCapture := 0
            DllCall("ReleaseCapture")

            If (s_MouseMove == 0) {
                DropItem := TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16)

                DragItem := TabEx.GetSel()
                If (DropItem && DropItem != DragItem) {
                    SwapTabs(DragItem, DropItem)
                }
            }
            Return True
        }

    } Else If (msg == 0x215) { ; WM_CAPTURECHANGED
        If (g_MouseCapture) {
            g_MouseCapture := 0
            DllCall("ReleaseCapture")
        }

    } Else If (msg == 0x207) { ; WM_MBUTTONDOWN
        CloseTab(TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16))
        Return True
    }

    Return DllCall("CallWindowProcA", "Ptr", OldTabProc, "Ptr", hWnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

; nTab := TabHitTest(hTab, lParam & 0xFFFF, lParam >> 16)
TabHitTest(hTab, x, y) {
    VarSetCapacity(TCHITTESTINFO, 16, 0)
    NumPut(x, TCHITTESTINFO, 0)
    NumPut(y, TCHITTESTINFO, 4)
    NumPut(6, HITTESTINFO, 8) ; 6 = TCHT_ONITEM
    SendMessage 0x130D, 0, &TCHITTESTINFO,, ahk_id %hTab% ; TCM_HITTEST
    Return Int(ErrorLevel) + 1
}

; Drag: source. Drop: destination.
SwapTabs(DragItem, DropItem) {
    If (g_GuiTab) {
        If (DragItem == g_GuiTab) {
            g_GuiTab := DropItem
        } Else If (DragItem < g_GuiTab && DropItem >= g_GuiTab) {
            g_GuiTab--
        } Else If (DragItem > g_GuiTab && DropItem <= g_GuiTab) {
            g_GuiTab++
        }
    }

    ObjSci := Sci.RemoveAt(DragItem)
    Sci.InsertAt(DropItem, ObjSci)

    Loop % Sci.Length() {
        SetDocumentStatus(A_Index)
        TabEx.SetIcon(A_Index, GetIconForTab(A_Index))
    }

    TabEx.SetSel(DropItem)
}

SetTabBarPos:
    If (A_ThisMenuItem == "Top") {
        TabCtlY := g_ToolbarH
        g_TabBarPos := 1
        Menu AutoViewTabBarMenu, Uncheck, Bottom
    } Else {
        GetClientSize(hAutoWnd, WindowW, WindowH)
        TabCtlY := WindowH - g_StatusBarH - 25 ; 25 = TabCtlH
        g_TabBarPos := 2
        Menu AutoViewTabBarMenu, Uncheck, Top
    }

    Control ExStyle, ^0x200,, ahk_id %hMainToolbar% ; Toggle WS_EX_CLIENTEDGE
    Control ExStyle, ^0x200,, ahk_id %hGUIToolbar%
    ; 0x37: SWP_NOSIZE | SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_DRAWFRAME
    SetWindowPos(hMainToolbar, 0, 0, 0, 0, 0, 0x37)
    SetWindowPos(hGUIToolbar, 0, 0, 0, 0, 0, 0x37)

    GuiControl MoveDraw, %hTab%, y%TabCtlY%

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, SciX, SciY, 0, 0, 0, 0x15) ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
    }

    Menu AutoViewTabBarMenu, Check, %A_ThisMenuItem%
Return

SetTabBarStyle:
    If (A_ThisMenuItem == "Standard") {
        GuiControl Auto: -Buttons, %hTab%
        DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hTab, "WStr", "Explorer", "Ptr", 0)
        g_TabBarStyle := 1
        Menu AutoViewTabBarMenu, Uncheck, Buttons
    } Else {
        DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hTab, "Str", " ", "Str", " ")
        GuiControl Auto: +Buttons, %hTab%
        g_TabBarStyle := 2
        Menu AutoViewTabBarMenu, Uncheck, Standard
    }

    If (g_DesignMode) {
        GuiControlGet, TabCtl, Pos, %hTab%
        TabCtlX := A_ThisMenuItem == "Standard" ? TabCtlX + 2 : TabCtlX - 2
        GuiControl MoveDraw, %hTab%, x%TabCtlX%
    }

    Menu AutoViewTabBarMenu, Check, %A_ThisMenuItem%
Return

GetIconForTab(n) {
    If (n == g_GuiTab) {
        Icon := 3
    } Else If (SubStr(Sci[n].Filename, -2) = "AHK") {
        Icon := 2
    } Else If (Sci[n].Filename == "") {
        Icon := 1
    } Else {
        hIcon := GetFileIcon(Sci[n].FullName)
        Icon := IL_Add(TabExIL, "HICON:" . hIcon)
    }

    Return Icon
}

ShowBackupDialog:
    Gui BackupDlg: New, LabelBackupDlg hWndhBackupDlg -MinimizeBox OwnerAuto
    SetWindowIcon(hBackupDlg, IconLib, 10)
    Gui Color, White
    Gui Add, Radio, x0 y0 w0 h0

    Gui Add, Progress, x-1 y0 w526 h49 -Smooth +Background008EBC +Border, 0
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x11 y12 w297 h23 +0x200 +BackgroundTrans, Auto-save and Backup Settings
    Gui Font

    Gui Font, s9, Segoe UI
    Gui Add, Text, x12 y57 w69 h23 +0x200, Directory:
    Gui Add, Edit, vg_BackupDir x84 y58 w347 h21, %g_BackupDir%
    Gui Add, Button, gChooseBackupDir x436 y56 w80 h23, &Choose...

    Gui Add, CheckBox, vg_BackupOnSave x12 y88 w237 h23 +Checked%g_BackupOnSave%
    , Backup a copy of the file before saving

    Gui Add, GroupBox, x8 y117 w509 h114, Auto-save
    Gui Add, Text, x20 y136 w139 h23 +0x200, Save automatically after
    Gui Add, Edit, vg_AutoSaveInterval x162 y137 w42 h21 +Number +Right, %g_AutoSaveInterval%
    Gui Add, Text, x212 y136 w58 h23 +0x200, minutes
    Gui Add, CheckBox, vg_AutoSaveInLoco x20 y168 w237 h23 +Checked%g_AutoSaveInLoco%
    , Save the file in its current location
    Gui Add, CheckBox, vg_AutoSaveInBkpDir x20 y199 w237 h23 +Checked%g_AutoSaveInBkpDir%
    , Save the file in the backup directory

    Gui Add, Text, x12 y238 w183 h23 +0x200, Delete backup copies older than
    Gui Add, Edit, vg_BackupDays x197 y240 w42 h21 +Number +Right, %g_BackupDays%
    Gui Add, Text, x245 y238 w45 h23 +0x200, days

    Gui Add, Text, x-1 y275 w526 h48 -Background +Border
    Gui Add, Button, gBackupDlgOK x341 y287 w84 h24 +Default, &OK
    Gui Add, Button, gBackupDlgClose x432 y287 w84 h24, &Cancel

    Gui Show, w524 h322, Auto-save and Backup Settings
Return

BackupDlgEscape:
BackupDlgClose:
    Gui BackupDlg: Destroy
Return

BackupDlgOK:
    Gui BackupDlg: Submit

    g_BackupDir := RTrim(g_BackupDir, "\")

    If (g_AutoSaveInterval < 1) {
        g_AutoSaveInterval := 3 ; Default
    }

    DeleteOldBackups()

    ResetAutoSave()
Return

ChooseBackupDir:
    Gui BackupDlg: +OwnDialogs
    FileSelectFolder SelectedFolder,,, Select Folder
    If (!ErrorLevel) {
        GuiControl, BackupDlg:, g_BackupDir, %SelectedFolder%
    }
Return

AutoSaveTimer() {
    Critical

    If (g_AutoSaveInLoco) {
        Loop % Sci.Length() {
            ; Only for documents with name
            If (Sci[A_Index].FullName != "" && Sci[A_Index].GetModify()) {
                Save(A_Index)
            }
        }
    }

    If (g_AutoSaveInBkpDir) {
        Loop % Sci.Length() {
            If (Sci[A_Index].FullName != "" && !Sci[A_Index].GetModify()) {
                Continue ; The file has not been modified
            }

            ; Generate backup name for named documents
            If (Sci[A_Index].FullName != "") {
                If (!InStr(Sci[A_Index].BackupName, "[")) {
                    CRC32 := CRC32(Sci[A_Index].FullName)
                    SplitPath % Sci[A_Index].FullName, Filename,, FileExt
                    FileExt := "." . FileExt . ".tmp"
                    Sci[A_Index].BackupName := g_BackupDir . "\" . Filename . " [" . CRC32 . "]" . FileExt
                }
            ; For unnamed documents
            } Else If (Sci[A_Index].BackupName == "") {
                Sci[A_Index].BackupName := GetTempFileName(g_BackupDir, "tmp")
            }

            SciText := GetText(A_Index)
            If (SciText != "") {
                If (BackupDirCreated()) {
                    BackupName := Sci[A_Index].BackupName
                    Encoding := (SubStr(BackupName, -7, 4) = ".INI") ? "UTF-16" : A_FileEncoding
                    FileDelete %BackupName%
                    FileAppend %SciText%, %BackupName%, %Encoding%
                }
            }
        }
    }
}

; Credits to jNizM
CRC32(String, Encoding = "UTF-8") {
    Local ChrLength, Length, Data, hMod, CRC32
    ChrLength := (Encoding = "CP1200" || Encoding = "UTF-16") ? 2 : 1
    Length := (StrPut(String, Encoding) - 1) * ChrLength
    VarSetCapacity(Data, Length, 0)
    StrPut(String, &Data, Floor(Length / ChrLength), Encoding)
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll", "Ptr")
    CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &Data, "UInt", Length, "UInt")
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
    Return Format("{:08X}", CRC32)
}

GetTempFileName(Dir, Ext := "tmp") {
    Local Num, Filename
    Static Attempts := 0

    Random Num, 1, 2147483647

    Filename := Dir . "\" . Num . "." . Ext
    If (FileExist(Filename)) {
        Attempts++
        If (Attempts > 10) {
            Attempts := 0
            Filename := Dir . "\" . A_Now . " " . Num . "." . Ext
            Return Filename
        }

        GetTempFileName(Dir, Ext)
    }

    Attempts := 0
    Return Filename
}

DeleteOldBackups(Ext := "tmp") {
    Loop %g_BackupDir%\*.%Ext% {
        Now := A_Now
        EnvSub Now, %A_LoopFileTimeModified%, Days
        If (Now >= g_BackupDays) {
            FileDelete %A_LoopFileLongPath%
        }
    }
}

BackupDirCreated() {
    If (!FileExist(g_BackupDir)) {
        FileCreateDir %g_BackupDir%
        Return !ErrorLevel
    }
    Return True
}

StartAutoSave() {
    If (g_AutoSaveInLoco || g_AutoSaveInBkpDir) {
        SetTimer AutoSaveTimer, % g_AutoSaveInterval * 60000
    }
}

ResetAutoSave() {
    Try {
        SetTimer AutoSaveTimer, Off
    }

    StartAutoSave()
}

CustomMessage(wParam, lParam) {
    n := TabEx.GetSel()

    If (wParam == 1) { ; Integration with Find in Files
        If (WinExist("ahk_id " . lParam)) {
            ControlGetText Params,, ahk_id %lParam%
            Params := StrSplit(Params, "|")
            If (FileExist(Params[1])) {
                Open([Params[1]])
                Sleep -1
                n := TabEx.GetSel()
                GoToLineEx(n, Params[2] - 1)
                WinActivate ahk_id %hAutoWnd%
            }
        }

    } Else If (wParam == 2) { ; Request all open file names
        Filenames := ""
        If (Sci[n].FullName != "") {
            Filenames .= Sci[n].FullName . ";"
        }

        Loop % Sci.Length() {
            If (A_Index == n) {
                Continue ; ?
            }

            If (Sci[A_Index].FullName != "") {
                Filenames .= Sci[A_Index].FullName . ";"
            }
        }

        GuiControl,, %g_hHiddenEdit%, %Filenames%
        Sleep -1
        SendMessage 10000, 2, %g_hHiddenEdit%,, ahk_id %lParam%

    } Else If (wParam == 3) { ; Script Directives
        If (WinExist("ahk_id " . lParam)) {
            ControlGetText Params,, ahk_id %lParam%
            Sci[n].InsertText(0, Params, 1)
            SendMessage 0x10, 0, 0,, % "ahk_id" . GetParent(lParam) ; WM_CLOSE
        }
    }
}

ScriptDirectives() {
    Run %A_ScriptDir%\Tools\Directives.ahk /AutoGUI
}

OnWM_SHOWWINDOW(wParam, lParam, msg, hWnd) {
    If (hWnd == hChildWnd) {
        SetStatusBar(g_GuiVis := wParam)
    }
}

FormatAhkStdErr(AhkStdErr, ByRef File := "", ByRef Line := 0) {
    If (RegExMatch(AhkStdErr, "Us)^(.*) \((\d+)\) : ==> (.*)\s*(?:Specifically: (.*))?$", Match)) {
        Message := "File: """ . (File := Match1) . """."
        Message .= "`n`nError at line " . (Line := Match2) . "."
        If (Match4 != "") {
            Message .= "`n`nSpecifically: " . Match4
        }
        Message .= "`n`nError: " . Match3
        Return Message
    } Else {
        Return AhkStdErr
    }
}

ToggleCaptureStdErr:
    g_CaptureStdErr := !g_CaptureStdErr
    Menu AutoRunMenu, ToggleCheck, Capture Standard &Error
Return

AhkRunGetStdErr(n, AhkPath, AhkScript, Parameters, WorkingDir, AhkDbgParams := "") {
    CmdLine := """" . AhkPath . """ /ErrorStdOut " . AhkDbgParams . " """ . AhkScript . """ " . Parameters
    StdErr := RunGetStdOut(CmdLine, "CP0", WorkingDir, ExitCode)
    If (ExitCode == 2) {
        Marked := 0
        AhkStdErr := FormatAhkStdErr(StdErr, File, Line)
        If (Line) {
            If (AhkScript != File && File != g_TempFile) {
                n := IsFileOpened(File)
                If (n) {
                    TabEx.SetSel(n)
                    Sleep 1
                } Else {
                    n := Open([File])
                }
            }

            If (n) {
                --Line
                GoToLineEx(n, Line)
                If (g_ShowErrorSign) {
                    If !(Sci[n].MarkerGet(Line) & (1 << g_MarkerError)) {
                        Sci[n].MarkerAdd(Line, g_MarkerError)
                        Marked := 1
                    }
                }
            }
        }

        ErrorMsgBox(AhkStdErr, "Auto")
        If (g_ShowErrorSign == -1 && Marked) {
            Sci[n].MarkerDelete(Line, g_MarkerError)
        }

        ; Debug
        If (AhkDbgParams) {
            GoSub DebugError
        }
    }
}

GetSaveEncoding(n) {
    If (SubStr(Sci[n].Filename, -2) = "INI") {
        Sci[n].Encoding := Encoding := "UTF-16"

    } Else If (Sci[n].Encoding == "CP1252") {
        Encoding := "UTF-8-RAW"

    } Else {
        Encoding := IsValidEncoding(Sci[n].Encoding) ? Sci[n].Encoding : "UTF-8"
    }

    Return Encoding
}

IsValidEncoding(Encoding) {
    For K, V in g_Encodings {
        If (Encoding == K) {
            Return 1
        }
    }
    Return 0
}

SetSaveEncoding(ItemName) {
    n := TabEx.GetSel()

    If (ItemName == "UTF-16 LE") {
        Sci[n].Encoding := "UTF-16"
    } Else If (ItemName == "UTF-8 without BOM") {
        Sci[n].Encoding := "UTF-8-RAW"
    } Else {
        Sci[n].Encoding := "UTF-8"
    }

    If (!g_GuiVis) {
        Gui Auto: Default
        SB_SetText(ItemName, 5)
    }

    Sci[n].FullName != "" ? Save(n) : SaveAs(n)
}

GetFileEncodingDisplayName(n) {
    Encoding := g_Encodings[Sci[n].Encoding]
    Return Encoding != "" ? Encoding : "UTF-8"
}

WriteFile(Filename, String, Encoding := "UTF-8") {
    f := FileOpen(Filename, "w", Encoding)
    If (!IsObject(f)) {
        ErrorMsgBox("Error saving """ . Filename . """.`n`n" . GetErrorMessage(A_LastError), "Auto")
        Return -1
    }
    Bytes := f.Write(String)
    f.Close()
    Return Bytes
}

Execute() {
    n := TabEx.GetSel()
    FullPath := Sci[n].FullName

    If (Sci[n].GetLexer() == SCLEX_AHKL && (SubStr(FullPath, -2) = "AHK" || FullPath == "")) {
        RunScript()

    } Else {
        RunFile()
    }
}

RunFile() {
    n := TabEx.GetSel()

    If (Sci[n].GetModify()) {
        If (!Save(n)) {
            Return
        }
    }

    FullPath := Sci[n].FullName
    WorkingDir := GetFileDir(FullPath)

    Run % FullPath . " " . Sci[n].Parameters, %WorkingDir%, UseErrorLevel
    If (ErrorLevel) {
        ErrorMsgBox(GetErrorMessage(A_LastError), "Auto")
    }
}

OnWM_ENDSESSION(wParam, lParam) {
    If (g_RememberSession) {
        GoSub SaveSessionOnExit
    }

    Quit()
}

GetTempDir() {
    Local LP

    If (g_NT6orLater) {
        Return A_Temp
    } Else {
        DllCall("GetLongPathName", "Str", A_Temp, "Str", LP, "UInt", VarSetCapacity(LP, 512, 0))
        Return LP
    }
}

ShowShellMenuDlg() {
    Options =
    (LTrim Join|
        Enabled for the drop-down arrow of the Execute button
        Enabled as part of the context menu of tab bar items
        Enabled in both places
        Disabled||
    )

    Option := g_ShellMenu1 | g_ShellMenu2
    Option := InputBoxEx("Explorer Context Menu", "Warning: this feature is experimental.", "Explorer Context Menu Settings", Options, "DDL", "AltSubmit Choose" . Option, hAutoWnd)
    If (!ErrorLevel) {
        If (Option == 4) {
            Option := 0
        }

        g_ShellMenu1 := Option & 1
        g_ShellMenu2 := Option & 2

        hTabContextMenu := MenuGetHandle("TabContextMenu")
        DeleteMenu(hTabContextMenu, g_ShellMenu2Pos)
        Menu TabContextMenu, DeleteAll
        CreateTabContextMenu()
    }
}

#Include %A_ScriptDir%\Lib\RunGetStdOut.ahk
#Include %A_ScriptDir%\Lib\ShellMenu.ahk
#Include %A_ScriptDir%\Lib\CommonDialogs.ahk
#Include %A_ScriptDir%\Lib\GuiButtonIcon.ahk
#Include %A_ScriptDir%\Lib\ExecScript.ahk
#Include %A_ScriptDir%\Lib\EnumIncludes.ahk
#Include %A_ScriptDir%\Lib\DBGp.ahk
#Include %A_ScriptDir%\Lib\LV_GroupView.ahk
#Include %A_ScriptDir%\Tools\MagicBox\Functions\InputBoxEx.ahk
#Include %A_ScriptDir%\Tools\MagicBox\Functions\SoftModalMessageBox.ahk

#Include %A_ScriptDir%\Include\Editor.ahk
#Include %A_ScriptDir%\Include\Designer.ahk
#Include %A_ScriptDir%\Include\Properties.ahk
#Include %A_ScriptDir%\Include\FontDialog.ahk
#Include %A_ScriptDir%\Include\MenuEditor.ahk
#Include %A_ScriptDir%\Include\ToolbarEditor.ahk
#Include %A_ScriptDir%\Include\CloneWindow.ahk
#Include %A_ScriptDir%\Include\Settings.ahk
#Include %A_ScriptDir%\Include\Parser.ahk
#Include %A_ScriptDir%\Include\ContextHelp.ahk
#Include %A_ScriptDir%\Include\GenerateCode.ahk
#Include %A_ScriptDir%\Include\FindReplace.ahk
#Include %A_ScriptDir%\Include\ToolsDialog.ahk
#Include %A_ScriptDir%\Include\Debug.ahk
