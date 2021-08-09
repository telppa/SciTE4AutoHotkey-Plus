; Auto-GUI - Windows Form Designer for AutoHotkey
; Tested on AHK v1.1.33.02 Unicode 32/64-bit, Windows XP/7/10.

; Script options
#SingleInstance Off
#NoEnv
#NoTrayIcon
#KeyHistory 0
SetBatchLines -1
DetectHiddenWindows On
SetWinDelay -1
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8
ListLines Off

#Include %A_ScriptDir%\Lib\Scintilla.ahk
#Include %A_ScriptDir%\Include\Globals.ahk
#Include %A_ScriptDir%\Include\Keywords.ahk

If (!LoadSciLexer(SciLexer)) {
    MsgBox 0x10, %g_AppName% - Error
    , % "Failed to load library """ . SciLexer . """.`n`n" . GetErrorMessage(A_LastError) . "`nThe program will exit."
    ExitApp
}

Menu Tray, UseErrorLevel ; Suppress menu warnings
Menu Tray, Icon, %IconLib%

IniFile := GetIniFileLocation("Auto-GUI.ini")
LoadSettings()

Gui Auto: New, LabelAuto hWndhAutoWnd Resize MinSize700 -DPIScale, %g_AppName% v%g_Version%
Gui Auto: Default

AddMenu("AutoFileMenu", "New AHK &GUI`tCtrl+N", "NewGUI", IconLib, -2)
AddMenu("AutoWindowMenu", "Change &Title...", "ChangeTitle", IconLib, -37)
AddMenu("AutoControlMenu", "Change Text...", "ChangeText", IconLib, -38)
AddMenu("AutoLayoutMenu", "Align &Lefts", "AlignLefts", IconLib, -52)
AddMenu("AutoViewMenu", "&Show/Hide Preview Window`tF11", "ShowChildWindow", IconLib, -6)
AddMenu("AutoHelpMenu", "AutoHotkey &Help File`tF1", "OpenAhkHelpFile", IconLib, -81)

Menu AutoMenuBar, Add, % " &File ", :AutoFileMenu
Menu AutoMenuBar, Add, % " &Window ", :AutoWindowMenu
Menu AutoMenuBar, Add, % " &Control ", :AutoControlMenu
Menu AutoMenuBar, Add, % " L&ayout ", :AutoLayoutMenu
Menu AutoMenuBar, Add, % " &View ", :AutoViewMenu
Menu AutoMenuBar, Add, % " &Help ", :AutoHelpMenu
Gui Menu, AutoMenuBar

IniRead g_InitialX, %IniFile%, Window, x
IniRead g_InitialY, %IniFile%, Window, y
IniRead g_InitialW, %IniFile%, Window, w, 952
IniRead g_InitialH, %IniFile%, Window, h, 611
IniRead ShowState, %IniFile%, Window, State, 1 ; SW_MAXIMIZE

If (g_InitialX != "ERROR") {
    SetWindowPlacement(hAutoWnd, g_InitialX, g_InitialY, g_InitialW, g_InitialH, 0)
} Else {
    Gui Show, w%g_InitialW% h%g_InitialH% Hide
}

Gui Font, s9, Segoe UI
Gui Add, StatusBar, hWndg_hStatusBar gSB_Handler
GuiControlGet g_StatusBar, Pos, %g_hStatusBar%

CreateToolbox(!g_ShowToolbox)

Gui Add, Edit, hWndg_hHiddenEdit x0 y0 w0 h0

CreateToolbar()
g_ToolbarH := GetWindowInfo(hToolbar).WindowH

; Initial instance of Scintilla
Sci_GetIdealSize(SciX, SciY, SciW, SciH)
Sci := New Scintilla(hAutoWnd, SciX, SciY, SciW, SciH, 0x50000000, 0x200)

Sci_Config()
Sci.SetReadOnly(True)
Sci.SetCaretStyle(0) ; Invisible

ShowWindow(hAutoWnd, ShowState)
WinActivate ahk_id %hAutoWnd%

SetStatusBar()

; File Menu
;AddMenu("AutoFileMenu", "&New GUI`tCtrl+N", "NewGUI", IconLib, -2)
AddMenu("AutoFileMenu", "&Import GUI...`tCtrl+I", "ShowImportGuiDialog", IconLib, -3)
Menu AutoFileMenu, Add
AddMenu("AutoFileMenu", "&Save`tCtrl+S", "Save", IconLib, -4)
Menu AutoFileMenu, Add, Save &As...`tCtrl+Shift+S, SaveAs
Menu AutoFileMenu, Add, Save a Copy As..., SaveCopy
Menu AutoEncodingMenu, Add, UTF-8, SetSaveEncoding, Radio
Menu AutoEncodingMenu, Check, UTF-8
Menu AutoEncodingMenu, Add, UTF-8 without BOM, SetSaveEncoding, Radio
Menu AutoEncodingMenu, Add, UTF-16 LE, SetSaveEncoding, Radio
Menu AutoFileMenu, Add, Save with Encoding, :AutoEncodingMenu
Menu AutoFileMenu, Add
AddMenu("AutoFileMenu", "Copy Code to Clipboard", "SaveToClipboard", IconLib, -5)
Menu AutoFileMenu, Add
If (A_PtrSize == 8) {
    AddMenu("AutoFileMenu", "Run with AHK 64-&bit`tF9", "M_RunScript64", IconLib, -74)
    AddMenu("AutoFileMenu", "Run with AHK 32-bit`tShift+F9", "M_RunScript32", IconLib, -75)
} Else {
    AddMenu("AutoFileMenu", "Run with AHK 32-bit`tF9", "M_RunScript32", IconLib, -75)
    AddMenu("AutoFileMenu", "Run with AHK 64-&bit`tShift+F9", "M_RunScript64", IconLib, -74)
}
Menu AutoFileMenu, Add
AddMenu("AutoFileMenu", "New Instance", "OpenNewInstance", IconLib, -1)
Menu AutoFileMenu, Add
AddMenu("AutoFileMenu", "Ask to Save on Exit", "ToggleAskToSaveOnExit")
Menu AutoFileMenu, Add
AddMenu("AutoFileMenu", "E&xit`tAlt+Q", "AutoClose", IconLib, -82)
; Window Menu
;AddMenu("AutoWindowMenu", "Change &Title...", "ChangeTitle", IconLib, -37)
Menu AutoWindowMenu, Add
AddMenu("AutoWindowMenu", "Set Font...", "WinShowFontDialog", IconLib, -48)
AddMenu("AutoWindowMenu", "Options...", "ShowWindowOptions", IconLib, -49)
AddMenu("AutoWindowMenu", "&Repaint", "RedrawWindow", IconLib, -51)
AddMenu("AutoWindowMenu", "Fit Window to Contents", "AutoSizeWindow", IconLib, -65)
Menu AutoWindowMenu, Add
AddMenu("AutoWindowMenu", "&Properties", "ShowWindowProperties", IconLib, -36)
; Control Menu
;AddMenu("AutoControlMenu", "Change Text...", "ChangeText", IconLib, -38)
Menu AutoControlMenu, Add
AddMenu("AutoControlMenu", "Cut", "CutControl", IconLib, -41)
AddMenu("AutoControlMenu", "Copy", "CopyControl", IconLib, -5)
AddMenu("AutoControlMenu", "Paste", "PasteControl", IconLib, -42)
AddMenu("AutoControlMenu", "Delete", "DeleteSelectedControls", IconLib, -45)
Menu AutoControlMenu, Add
AddMenu("AutoControlMenu", "Select &All", "SelectAllControls", IconLib, -43)
AddMenu("AutoControlMenu", "Select &None", "DestroySelection", IconLib, -44)
Menu AutoControlMenu, Add
AddMenu("AutoControlMenu", "Position and Size...", "ShowAdjustPositionDialog", IconLib, -70)
AddMenu("AutoControlMenu", "Font...", "ShowFontDialog", IconLib, -48)
AddMenu("AutoControlMenu", "Options...", "ShowControlOptions", IconLib, -49)
Menu AutoControlMenu, Add
AddMenu("AutoControlMenu", "Properties", "ShowProperties", IconLib, -36)
; Layout Menu
;AddMenu("AutoLayoutMenu", "Align &Lefts", "AlignLefts", IconLib, -52)
AddMenu("AutoLayoutMenu", "Align &Rights", "AlignRights", IconLib, -53)
AddMenu("AutoLayoutMenu", "Align &Tops", "AlignTops", IconLib, -54)
AddMenu("AutoLayoutMenu", "Align &Bottoms", "AlignBottoms", IconLib, -55)
Menu AutoLayoutMenu, Add
AddMenu("AutoLayoutMenu", "&Center Horizontally", "CenterHorizontally", IconLib, -57)
AddMenu("AutoLayoutMenu", "Center &Vertically", "CenterVertically", IconLib, -56)
Menu AutoLayoutMenu, Add
AddMenu("AutoLayoutMenu", "Hori&zontally Space", "HorizontallySpace", IconLib, -58)
AddMenu("AutoLayoutMenu", "V&ertically Space", "VerticallySpace", IconLib, -59)
Menu AutoLayoutMenu, Add
AddMenu("AutoLayoutMenu", "Make Same &Width", "MakeSameWidth", IconLib, -60)
AddMenu("AutoLayoutMenu", "Make Same &Height", "MakeSameHeight", IconLib, -61)
AddMenu("AutoLayoutMenu", "Make Same &Size", "MakeSameSize", IconLib, -62)
Menu AutoLayoutMenu, Add
AddMenu("AutoLayoutMenu", "Stretch Horizontally", "StretchHorizontally", IconLib, -63)
AddMenu("AutoLayoutMenu", "Stretch Vertically", "StretchVertically", IconLib, -64)
; View Menu
;AddMenu("AutoViewMenu", "Show/Hide &Preview Window`tF11", "ShowChildWindow", IconLib, -6)
Menu AutoViewMenu, Add
Menu AutoViewMenu, Add, Show &Control Palette, ToggleToolbox
Menu AutoViewMenu, Add, Show &Toolbar, ToggleToolbar
Menu AutoViewMenu, Add, Show &Status Bar, ToggleStatusBar
Menu AutoViewMenu, Add
Menu AutoViewMenu, Add, Show &Grid, ToggleShowGrid
Menu AutoViewMenu, Add, S&nap to Grid, ToggleSnapToGrid
Menu AutoViewMenu, Add
Menu AutoViewMenu, Add, Show &Line Numbers, ToggleLineNumbers
Menu AutoViewMenu, Add, &Wrap Long Lines, ToggleWordWrap
Menu AutoViewMenu, Add
AddMenu("AutoViewMenu", "Choose &Font...", "ChangeEditorFont", IconLib, -48)
; Help Menu
;AddMenu("AutoHelpMenu", "AutoHotkey &Help File`tF1", "HelpMenuHandler", IconLib, -81)
Menu AutoHelpMenu, Add
AddMenu("AutoHelpMenu", "&About", "ShowAbout", IconLib, -80)

hSysMenu := DllCall("GetSystemMenu", "Ptr", hAutoWnd, "Int", False, "Ptr")
DllCall("AppendMenu", "Ptr", hSysMenu, "UInt", 0x800, "UInt", 0, "Str", "") ; Separator
DllCall("AppendMenu", "Ptr", hSysMenu, "UInt", 0, "UInt", 1000, "Str", "Save Settings Now")

ApplySettings()

Sci.GrabFocus()

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
OnMessage(0x16,  "OnWM_ENDSESSION")
OnMessage(0x112, "OnWM_SYSCOMMAND")

hBitmapTile := LoadImage(A_ScriptDir . "\Icons\8x8.bmp", g_GridSize, g_GridSize, 0)
hCursorCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515, "Ptr")

#Include %A_ScriptDir%\Include\Controls.ahk

SetAhkPath()

Menu AutoMenuBar, Color, %g_MenuColor%
/*
If (A_ScreenDPI != 96) {
    Gui Auto: +OwnDialogs
    MsgBox 0x30, Warning, %g_AppName% has not been adapted to High-DPI display scaling.`n`nThe program will exit.
    ExitApp
}
*/
If (!A_IsUnicode) {
    Gui Auto: +OwnDialogs
    MsgBox 0x10, Error, %g_AppName% is incompatible with the ANSI build of AutoHotkey.
    ExitApp
}

Return ; End of the auto-execute section.

CreateToolbar() {
    Local TbIL, TbButtons

    TbIL := IL_Create(23)

    IL_Add(TbIL, IconLib, -2)   ; New GUI
    IL_Add(TbIL, IconLib, -3)   ; Import GUI
    IL_Add(TbIL, IconLib, -4)   ; Save
    IL_Add(TbIL, IconLib, -5)   ; Copy to Clipboard

    IL_Add(TbIL, IconLib, -66)  ; Show Grid
    IL_Add(TbIL, IconLib, -67)  ; Snap to Grid

    IL_Add(TbIL, IconLib, -6)   ; Show/Hide Preview Window
    IL_Add(TbIL, IconLib, -36)  ; Properties

    IL_Add(TbIL, IconLib, -52)  ; Align Lefts
    IL_Add(TbIL, IconLib, -53)  ; Align Rights
    IL_Add(TbIL, IconLib, -54)  ; Align Tops
    IL_Add(TbIL, IconLib, -55)  ; Align Bottoms
    IL_Add(TbIL, IconLib, -57)  ; Center Horizontally
    IL_Add(TbIL, IconLib, -56)  ; Center Vertically
    IL_Add(TbIL, IconLib, -58)  ; Horizontally Space
    IL_Add(TbIL, IconLib, -59)  ; Vertically Space
    IL_Add(TbIL, IconLib, -60)  ; Make Same Width
    IL_Add(TbIL, IconLib, -61)  ; Make Same Height
    IL_Add(TbIL, IconLib, -62)  ; Make Same Size
    IL_Add(TbIL, IconLib, -63)  ; Stretch Horizontally
    IL_Add(TbIL, IconLib, -64)  ; Stretch Vertically

    IL_Add(TbIL, IconLib, -73)  ; Preview

    IL_Add(TbIL, IconLib, -81)  ; Help

    TbButtons = 
        (LTrim
            -
            New GUI
            Import GUI
            Save
            Copy Code to Clipboard
            -
            Show Grid,,,, 1080
            Snap to Grid,,,, 1090
            -
            Show/Hide Preview Window,,,, 1070
            Properties
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
            Stretch Horizontally
            Stretch Vertically
            -
            Preview,,, SHOWTEXT
            -
            Help
        )

    hToolbar := ToolbarCreate("OnToolbar", TbButtons, TbIL, "FLAT LIST TOOLTIPS", "+E0x200")
    SendMessage 0x41F, 0, 0x00180018,, ahk_id %hToolbar% ; TB_SETBUTTONSIZE
}

OnToolbar(hWnd, Event, Text, Pos, Id) {
    If (Event == "Hot") {
        If (GetActiveWindow() != hAutoWnd && Text != "Preview") {
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
    } Else If (Text == "Import GUI") {
        GoSub ShowImportGuiDialog
    } Else If (Text == "Save") {
        Save()
    } Else If (Text == "Copy Code to Clipboard") {
        SaveToClipboard()

    } Else If (Text == "Properties") {
        GoSub ShowProperties
    } Else If (Text == "Show/Hide Preview Window") {
        ShowChildWindow()

    } Else If (Text == "Show Grid") {
        GoSub ToggleShowGrid
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

    } Else If (Text == "Stretch Horizontally") {
        StretchHorizontally()
    } Else If (Text == "Stretch Vertically") {
        StretchVertically()

    } Else If (Text == "Preview") {
        Execute()

    } Else If (Text == "Help") {
        OpenAhkHelpFile()
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

        SB_SetIcon(IconLib, -7,  1) ; Class name
        SB_SetIcon(IconLib, -70, 2) ; Position
        SB_SetIcon(IconLib, -71, 3) ; Size
        SB_SetIcon(IconLib, -72, 4) ; Cursor position

    } Else {
        SB_SetParts()
        SB_SetParts(162, 200, 200) ; Mode | Line:Pos | Document Status | Save Encoding

        ;SB_SetText("Press F1 for help", 1)
        If (IsWindow(hChildWnd)) {
            SB_SetText("Generated code", 1)
            SB_SetIcon(IconLib, -69,  1)
        }

        SB_SetText(A_FileEncoding, 5)

        UpdateStatusBar()
    }
}

Sci_GetIdealSize(ByRef X, ByRef Y, ByRef W, ByRef H) {
    Local WindowW, WindowH

    GetClientSize(hAutoWnd, WindowW, WindowH)
    GuiControlGet ToolBox, Auto: Pos, %hLvToolbox%

    Y := g_ShowToolbar ? g_ToolbarH : 1
    H := WindowH - (g_ShowStatusBar ? g_StatusBarH : 0) - (g_ShowToolbar ? Y : 0)

    If (g_ShowToolbox) {
        X := ToolBoxW + g_SplitterW
        W := WindowW - ToolBoxW - g_SplitterW
    } Else {
        X := 1
        W := WindowW ; + 1
    }
}

; Message handling

AutoSize() {
    Global
    If (A_EventInfo == 1) { ; The window has been minimized.
        Return
    }

    Gui Auto: Default

    GuiControl Move, %hToolbar%, w%A_GuiWidth%

    GuiControl Move, %hLvToolbox%
    , % "h" . A_GuiHeight - g_ToolbarH - (g_ShowStatusBar ? g_StatusBarH : 0)

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    SetWindowPos(Sci.hWnd, 0, 0, SciW, SciH, 0, 0x16) ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE

    Gui ListView, %hLvToolbox%
    LV_ModifyCol(1, "AutoHdr")
}

AutoClose:
    Quit(g_AskToSaveOnExit)
Return

Quit(AskToSave := True) {
    If (AskToSave && Sci.GetModify()) {
        Gui Auto: +OwnDialogs
        MsgBox 0x33, %g_AppName%, Unsaved GUI script. Do you want to save it?
        IfMsgBox Yes, {
            If (!Save()) {
                Return
            }
        } Else IfMsgBox Cancel, {
            Return
        }
    }

    SaveSettings()

    FileDelete %g_TempFile%
    FileDelete %A_Temp%\AutoXYWH.ahk
    FileDelete %A_Temp%\Toolbar.ahk
    FileDelete %A_Temp%\ControlColor.ahk

    ExitApp
}

OnWM_ENDSESSION(wParam, lParam) {
    Quit()
}

ChildSize:
    If (A_EventInfo == 1) { ; The window has been minimized.
        ShowChildWindow(0)
        Return
    }

    If (IsWindowVisible(hChildWnd)) {
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
    Local wx, wy

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

    If (GetActiveWindow() != hAutoWnd && hWnd != hToolbar) {
        Tooltip
    }

    CoordMode Mouse, Window
    MouseGetPos x1, y1, hWindow, hControl, 2

    If (hControl == "") {
        hControl := hWindow
    }

    ; Update status bar info
    If (IsWindowVisible(hChildWnd)) {
        If (hControl != hPrevCtrl) {
            If (hControl != hChildWnd) {
                GuiControlGet Pos, Pos, %hControl%
                MouseGetPos,,,, ClassNN

                Gui Auto: Default
                SB_SetIcon(IconLib, -1 * Default[g[hControl].Type].IconIndex)
                SB_SetText(ClassNN, 1)
                SB_SetText("Position: " . PosX . ", " . PosY, 2)
                SB_SetText("Size: " . PosW . " x " . PosH, 3)

            } Else {
                WinGetTitle WinTitle, ahk_id %hWindow%
                wi := GetWindowInfo(hWindow)
                wx := wi.WindowX
                wy := wi.WindowY
                ww := wi.ClientW
                wh := wi.ClientH

                Gui Auto: Default
                SB_SetIcon(IconLib, -7)
                SB_SetText("AutoHotkeyGUI", 1)
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

    } Else If (LButtonP && !(wParam & 0x8)) { ; 0x8 = MK_CONTROL
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

        AddSelectedControl()
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
    Local RECT, tiy, ty

    g_X := lParam & 0xFFFF
    g_Y := lParam >> 16

    If (hWnd == hChildToolbar) {
        AddMenu("ChildToolbarMenu", "Properties", "ShowToolbarEditor", IconLib, -36)
        Menu ChildToolbarMenu, Show
        Return
    }

    MouseGetPos,,, g_Gui, g_Control, 2
    If (g_Gui != hChildWnd) {
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

    ; Preview window
    If (hActiveWnd == hChildWnd) {
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
    }

    ; Any window
    If (CtrlP) {
        If (wParam == 78) { ; ^N
            GoSub NewGUI
            Return False

        } Else If (ShiftP && wParam == 83) { ; ^+S
            SaveAs()
            Return False

        } Else If (wParam == 83) { ; ^S
            Save()
            Return False

        } Else If (wParam == 73) { ; ^I
            GoSub ShowImportGuiDialog
            Return False

        } Else If (wParam == 71) { ; ^G
            ShowGoToLineDialog()
            Return False
        }
    }

    If (wParam == 120) { ; F9
        Execute()
        Return False

    } Else If (wParam == 122) { ; F11
        ShowChildWindow()
        Return False

    } Else If (wParam == 117) { ; F6
        hWndFocus := GetFocus()

        ; Switch input focus between control palette and the preview window
        If (hWndFocus != hLVToolbox) {
            SetFocus(hLVToolbox)
        } Else {
            SetActiveWindow(hChildWnd)
        }

        Return False
    }
}

OnWM_SYSKEYDOWN(wParam, lParam, msg, hWnd) {
    If (WinExist() == hAddMenuItemDlg) {
        Return
    }

    If (wParam == 120) { ; Alt+F9
        If (GetAhkPathEx() != "") {
            RunScript(g_AhkPathEx)
        }

        Return False

    } Else If (wParam == 0x79) { ; F10
        If (IsWindowVisible(hPropWnd)) {
            ShowWindow(hPropWnd, 0)
        } Else {
            GoSub ShowProperties
        }

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

ToggleToolbox() {
    ShowWindow(hLvToolbox, g_ShowToolbox := !g_ShowToolbox)
    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    SetWindowPos(Sci.hWnd, SciX, SciY, SciW, SciH, 0, 0x14)
    Menu AutoViewMenu, ToggleCheck, Show &Control Palette
}

ToggleToolbar() {
    ShowWindow(hToolbar, g_ShowToolbar := !g_ShowToolbar)

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    SetWindowPos(Sci.hWnd, SciX, SciY, SciW, SciH, 0, 0x14)

    GetClientSize(hAutoWnd, WindowW, WindowH)
    ToolboxH := WindowH - (g_ShowStatusBar ? g_StatusBarH : 0) - (g_ShowToolbar ? g_ToolbarH : 0)
    ToolboxY := g_ShowToolbar ? g_ToolbarH : 0
    GuiControl Auto: MoveDraw, %hLvToolbox%, y%ToolboxY% h%ToolboxH%

    Menu AutoViewMenu, ToggleCheck, Show &Toolbar
}

ToggleStatusBar() {
    ShowWindow(g_hStatusBar, g_ShowStatusBar := !g_ShowStatusBar)

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    SetWindowPos(Sci.hWnd, SciX, SciY, SciW, SciH, 0, 0x14)

    GetClientSize(hAutoWnd, WindowW, WindowH)
    ToolboxH := WindowH - (g_ShowStatusBar ? g_StatusBarH : 0) - (g_ShowToolbar ? g_ToolbarH : 0)
    GuiControl Auto: MoveDraw, %hLvToolbox%, h%ToolboxH%

    Menu AutoViewMenu, ToggleCheck, Show &Status Bar
}

; SetMainWindowTitle
SetWindowTitle(Filename := "") {
    If (FileName != "") {
        WinSetTitle ahk_id%hAutoWnd%,, % g_AppName . " v" . g_Version . " - " . Filename
    } Else {
        WinSetTitle ahk_id%hAutoWnd%,, %g_AppName% v%g_Version%
    }
}

SaveAs() {
    Local StartPath, SelectedFile, Filename, FileExt

    StartPath := (Sci.FileName != "") ? Sci.FullName : g_SaveDir
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

    Sci.FullName := SelectedFile
    Sci.Filename := Filename

    SetWindowTitle(SelectedFile)

    Return Save()
}

Save:
    Save()
Return

Save() {
    If (Sci.Filename == "") {
        Return SaveAs()
    }

    SciText  := GetText()
    FullPath := Sci.FullName
    Encoding := GetSaveEncoding()

    If (WriteFile(FullPath, SciText, Encoding) < 0) {
        SetWindowTitle("Error saving file: " . FullPath)
        Return 0
    }

    Sci.SetSavePoint()
    SetDocumentStatus()

    SplitPath FullPath,, g_SaveDir
    CopyLibraries(g_SaveDir)

    Repaint(Sci.hWnd)

    Return 1
}

SaveCopy:
    If (Sci.FileName != "") {
        SplitPath % Sci.FullName,, Dir, Extension, NameNoExt
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
    If (FileExt == "" && Sci.GetLexer() == SCLEX_AHKL && !FileExist(SelectedFile . ".ahk")) {
        SelectedFile .= ".ahk"
    }

    SciText := GetText()
    Encoding := GetSaveEncoding()
    WriteFile(SelectedFile, SciText, Encoding)
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

SaveToClipboard() {
    Clipboard := GetText()
}

WriteFile(Filename, String, Encoding := "UTF-8") {
    Local f, Bytes

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
    If (Sci.GetLexer() == SCLEX_AHKL) {
        RunScript()
    }
}

M_RunScript64() {
    RunScript(g_AhkPath64)
}

M_RunScript32() {
    RunScript(g_AhkPath32)
}

GetAhkPath() {
    If (GetKeyState("Shift", "P")) {
        Return (A_PtrSize == 4) ? g_AhkPath64 : g_AhkPath32
    } Else {
        Return (A_PtrSize == 4) ? g_AhkPath32 : g_AhkPath64
    }
}

RunScript(AhkPath := "") {
    Local Script, Params, FullPath, WorkingDir

    If (AhkPath == "") {
        AhkPath := GetAhkPath()
    }

    If (Sci.Filename != "") { ; Saved files
        If (Sci.GetModify() && !Save()) {
            Return
        }

        FullPath := Sci.FullName
        SplitPath FullPath,, WorkingDir

    } Else { ; Unsaved scripts run from the Temp folder
        Script := GetText()

        FullPath := g_TempFile
        FileDelete %FullPath%
        FileAppend %Script%, %FullPath%, %A_FileEncoding%
        If (ErrorLevel) {
            Return
        }

        CopyLibraries(WorkingDir := A_Temp)
    }

    Params := Sci.Parameters

    FixRootDir(WorkingDir)

    RunEx(AhkPath . " """ . FullPath . """ " . Params, WorkingDir,,, hAutoWnd)
}

SetAhkPath() {
    SplitPath A_AhkPath,, AhkDir
    If (AhkDir == "") {
        Return
    }

    If (g_AhkPath32 == "") {
        g_AhkPath32 := AhkDir . "\AutoHotkeyU32.exe"
    }

    If (g_AhkPath64 == "") {
        g_AhkPath64 := AhkDir . "\AutoHotkeyU64.exe"
    }
}

GetAhkPathEx() {
    Return FileExist(g_AhkPathEx) ? g_AhkPathEx : BrowseForAhkPathEx()
}

BrowseForAhkPathEx() {
    StartPath := FileExist(g_AhkPathEx) ? g_AhkPathEx : A_ProgramFiles
    Gui Auto: +OwnDialogs
    FileSelectFile AltAhkPath, 3, %StartPath%, Select File, Executable Files (*.exe)
    Return ErrorLevel ? "" : g_AhkPathEx := AltAhkPath
}

AddMenu(MenuName, MenuItemName := "", Subroutine := "MenuHandler", Icon := "", IconIndex := 0) {
    Menu, %MenuName%, Add, %MenuItemName%, %Subroutine%

    If (Icon != "") {
        Menu, %MenuName%, Icon, %MenuItemName%, %Icon%, %IconIndex%
    }
}

MenuHandler:
    Gui Auto: +OwnDialogs
    MsgBox 0x40, %g_AppName%, Not implemented yet.
Return

OpenAhkHelpFile() {
    RunEx(g_HelpFile)
}

ShowAbout() {
    Gui About: New, LabelAbout -SysMenu +OwnerAuto
    Gui Color, White

    hGrad := CreateDIB("1F609F|1F609F|20AEDD|20AEDD", 2, 2, DPIScale(470), DPIScale(180), 1)
    Gui Add, Pic, x0 y0 w470 h180, HBITMAP: %hGrad%

    Gui Add, Picture, x10 y10 w31 h32 +BackgroundTrans, %IconLib%
    Gui Add, Picture, x18 y18 w31 h32 +BackgroundTrans, %IconLib%
    Gui Add, Picture, x26 y26 w31 h32 +BackgroundTrans, %IconLib%

    Gui Font, s18 Bold q4 cWhite, Verdana
    Gui Add, Text, x67 y28 w300 h32 +0x200 +BackgroundTrans, Auto-GUI
    Gui Font
    Gui Font, s9 cWhite, Segoe UI
    Gui Add, Text, x67 y60 w299 h23 +0x200 +BackgroundTrans, Windows Form Designer for AutoHotkey
    Gui Add, Text, x67 y83 w299 h23 +0x200 +BackgroundTrans, Version %g_Version%
    Gui Add, Text, x67 y106 w301 h23 +0x200 +BackgroundTrans, % "AutoHotkey " . A_AhkVersion
    . " " . (A_IsUnicode ? "Unicode" : "ANSI")
    . " " . (A_PtrSize == 8 ? "64-bit" : "32-bit")

    Gui Add, Text, x-1 y173 w472 h50 +0x200 +Border -Background
    Gui Add, Button, gAboutClose x380 y187 w80 h23 +Default, &OK

    Gui Show, w470 h222, About
}

AboutClose() {
    AboutEscape:
    Gui About: Destroy
    Return 1
}

/*
OpenFolder() {
    FullPath := Sci.FullName
    If (FileExist(FullPath)) {
        Run *open explorer.exe /select`,"%FullPath%"
    }
}
*/

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

ShowImportGuiDialog:
    Gui ImportGUIDlg: New, LabelImportGUIDlg hWndhImportGUIDlg -MinimizeBox OwnerAuto
    SetWindowIcon(hImportGUIDlg, IconLib, -3)
    Gui Color, 0xFAFAFA
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x12 y12 w409 h21, Select the Import Method
    Gui Font
    Gui Font, s9, Segoe UI
    Gui Add, Text, x12 y42 w498 h32
    , Warning: none of these methods preserve the entire script. Both have limitations.`nBe careful not to overwrite the original file when choosing the saving location.
    Gui Add, Radio, vClone x22 y83 w368 h23 Checked, Clone the window
    Gui Add, Radio, vParse x22 y115 w368 h23, Parse the script (not recommended)
    Gui Add, Text, x-1 y156 w525 h48 Border -Background
    Gui Add, Button, gImportGUIDlgOK x343 y168 w80 h23 +Default, &OK
    Gui Add, Button, gImportGUIDlgClose x429 y168 w80 h23, &Cancel
    Gui Show, w523 h203, Import GUI
Return

ImportGuiDlgClose() {
    ImportGuiDlgEscape:
    Gui ImportGuiDlg: Destroy
    Return 1
}

ImportGuiDlgOK:
    Gui ImportGuiDlg: Submit

    If (Clone) {
        GoSub ShowCloneDialog
        Return
    }

    FileSelectFile FullPath, 1, %g_OpenDir%, Open, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel) {
        Return
    }

    Try {
        fOpen := FileOpen(FullPath, "r", "")
        fRead := fOpen.Read()
        fEncoding := fOpen.Encoding
        fOpen.Close()

        g_OpenDir := GetFileDir(FullPath)
    } Catch e {
        ErrorMsgBox("File: """ . FullPath . """.`n`n" . GetErrorMessage(A_LastError), "Auto")
        Return
    }

    Gosub NewGUI
    ParseScript(fRead)
    fRead := ""
Return

AutoSizeWindow:
    Gui %Child%: Margin, 8, 8
    Gui %Child%: Show, AutoSize
    GenerateCode()
Return

OpenNewInstance() {
    Local FullPath := Sci.FullName
    Run "%A_AhkPath%" "%A_ScriptFullPath%" /new "%FullPath%"
}

OnWM_SHOWWINDOW(wParam, lParam, msg, hWnd) {
    If (hWnd == hChildWnd) {
        SetStatusBar(g_GuiVis := wParam)
        SendMessage TB_CHECKBUTTON, 1070, %g_GuiVis%,, ahk_id %hToolbar%
    }
}

GetSaveEncoding() {
    Local Encoding
    If (Sci.Encoding == "CP1252") {
        Encoding := "UTF-8-RAW"
    } Else {
        Encoding := IsValidEncoding(Sci.Encoding) ? Sci.Encoding : "UTF-8"
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
    If (ItemName == "UTF-16 LE") {
        Sci.Encoding := "UTF-16"
    } Else If (ItemName == "UTF-8 without BOM") {
        Sci.Encoding := "UTF-8-RAW"
    } Else {
        Sci.Encoding := "UTF-8"
    }

    If (!g_GuiVis) {
        Gui Auto: Default
        SB_SetText(ItemName, 4)
    }

    UpdateEncodingMenu()

    Sci.FullName != "" ? Save() : SaveAs()
}

UpdateEncodingMenu() {
    Loop % GetMenuItemCount(MenuGetHandle("AutoEncodingMenu")) {
        Try {
            Menu AutoEncodingMenu, Uncheck, %A_Index%&
        }
    }
    Try {
        Menu AutoEncodingMenu, Check, % GetFileEncodingDisplayName()
    }
}

SB_Handler() {
    If (A_GuiEvent == "RightClick") {
        If (!g_GuiVis && A_EventInfo == 5) {
            UpdateEncodingMenu()
            Menu AutoEncodingMenu, Show
        }
    }
}

GetFileEncodingDisplayName() {
    Encoding := g_Encodings[Sci.Encoding]
    Return Encoding != "" ? Encoding : "UTF-8"
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

Sci_Config(Lexer := 200) { ; SCLEX_AHKL
    COLOR_APPWORKSPACE := GetSysColor(12)

    Sci.SetLexer(Lexer)
    Sci.SetCodePage(65001) ; UTF-8
    Sci.SetWrapMode(g_WordWrap)
    Sci.SetScrollWidthTracking(True)
    Sci.SetExtraAscent(2) ; Increase space between lines
    Sci.SetVirtualSpaceOptions(1) ; SCVS_RECTANGULARSELECTION

    ; Indentation
    Sci.SetTabWidth(g_TabSize)
    Sci.SetUseTabs(!g_IndentWithSpaces) ; Indent with spaces
    Sci.SetIndentationGuides(g_IndentGuides ? 3 : 0)

    ; Caret
    Sci.SetCaretWidth(g_CaretWidth)
    Sci.SetCaretStyle(g_CaretStyle)
    Sci.SetCaretPeriod(g_CaretBlink)

    Sci.StyleSetFont(STYLE_DEFAULT, "" . g_SciFontName, 1)
    Sci.StyleSetSize(STYLE_DEFAULT, g_SciFontSize)

    Sci.SetMarginWidthN(0, 0)
    Sci.SetMarginWidthN(1, 0)

    Sci.StyleSetFore(STYLE_DEFAULT, CvtClr(0xFFFFFF))
    Sci.StyleSetBack(STYLE_DEFAULT, COLOR_APPWORKSPACE)
    Sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Line numbers margin
    Sci.SetMarginTypeN(0, 1) ; SC_MARGIN_NUMBER
    Sci.MarginLen := 0
    SetLineNumberWidth()
    Sci.SetMarginLeft(0, 4) ; Left padding
    Sci.StyleSetBack(33, COLOR_APPWORKSPACE) ; Margin background color. Initially grayed out.
    /*
    ; Separator
    Sci.SetMarginTypeN(1, 6) ; Separator
    Sci.SetMarginWidthN(1, 0)
    Sci.SetMarginLeft(1, 2)
    */

    ; Keyboard shortcuts
    Sci.AssignCmdKey(SCK_END, SCI_LINEENDWRAP)
    Sci.AssignCmdKey(SCK_HOME, SCI_HOMEWRAP)
    Sci.AssignCmdKey(SCK_END  | (SCMOD_SHIFT << 16), SCI_LINEENDWRAPEXTEND)
    Sci.AssignCmdKey(SCK_HOME | (SCMOD_SHIFT << 16), SCI_HOMEWRAPEXTEND)

    ; Keywords
    Sci.SetKeywords(0, Keywords.Directives, 1)
    Sci.SetKeywords(1, Keywords.Commands, 1)
    Sci.SetKeywords(2, Keywords.Parameters, 1)
    Sci.SetKeywords(3, Keywords.ControlFlow, 1)
    Sci.SetKeywords(4, Keywords.Functions, 1)
    Sci.SetKeywords(5, Keywords.BuiltinVariables, 1)
    Sci.SetKeywords(6, Keywords.Keys, 1)

    Sci.Notify := "OnWM_NOTIFY"
}

; Scintilla notification handler
OnWM_NOTIFY(wParam, lParam, msg, hWnd, obj) {
    Local CurPos, BracePos, BraceMatch

    If (obj.SCNCode == SCN_UPDATEUI) {
        CurPos := Sci.GetCurrentPos()

        ; Content or selection has been updated
        If (obj.Updated < 4 && g_Highlights) {
            Highlight(1, CurPos)
        }

        ; Brace matching
        BracePos := CurPos - 1
        BraceMatch := Sci.BraceMatch(BracePos, 0)
        If (BraceMatch == -1) {
            BracePos := CurPos
            BraceMatch := Sci.BraceMatch(CurPos, 0)
        }

        If (BraceMatch != -1) {
            Sci.BraceHighlight(BracePos, BraceMatch)
        } Else {
            Sci.BraceHighlight(-1, -1)
        }

        UpdateStatusBar()

    } Else If (obj.SCNCode == SCN_MODIFIED) {
        If (obj.LinesAdded) {
            SetLineNumberWidth()
        }

    } Else If (obj.SCNCode == SCN_SAVEPOINTREACHED || obj.SCNCode == SCN_SAVEPOINTLEFT) {
        SetDocumentStatus()

    } Else If (obj.SCNCode == SCN_ZOOM) {
        Sci.MarginLen := 0
        SetLineNumberWidth()
    }
        
    Return
}

SetLineNumberWidth() {
    If (g_LineNumbers) {
        LineCount := Sci.GetLineCount()
        LineCountLen := StrLen(LineCount)
        If (LineCountLen < 2) {
            LineCountLen := 2
        }

        If (LineCountLen != Sci.MarginLen) {
            Sci.MarginLen := LineCountLen

            If (LineCount < 100) {
                String := "99"
            } Else {
                String := ""
                LineCountLen := StrLen(LineCount)
                Loop %LineCountLen% {
                    String .= "9"
                }
            }

            PixelWidth := Sci.TextWidth(STYLE_LINENUMBER, "" . String, 1) + 8
            Sci.SetMarginWidthN(0, PixelWidth)
        }
    } Else {
        Sci.SetMarginWidthN(0, 0)
        Sci.MarginLen := 0
    }
}

ClearFile() {
    Sci.FullName := ""
    Sci.FileName := ""
    Sci.Encoding := "UTF-8"
    Sci.Parameters := ""
    Sci.ClearAll()
    Sci.SetSavePoint()
    Repaint(Sci.hWnd)
}

GetText() {
    Local nLen, SciText
    nLen := Sci.GetLength() + 1
    VarSetCapacity(SciText, nLen, 0)
    Sci.2182(nLen, &SciText)
    Return StrGet(&SciText, "UTF-8")
}

GetSelectedText() {
    Local SelLength, SelText
    SelLength := Sci.GetSelText() - 1
    VarSetCapacity(SelText, SelLength, 0)
    Sci.GetSelText(0, &SelText)
    Return StrGet(&SelText, SelLength, "UTF-8")
}

SetSelectedText(Text) {
    Sci.ReplaceSel("", Text, 1)
}

Highlight(n, CurPos, WordMode := 1, SearchFlags := 0, Limit := 2000) {
    ; Word boundary mode: 0 = single char, 1 = lenient word range, 2 = whole word

    Local TextLength, WordStartPos, WordEndPos, SelStart, SelEnd, SelCount
        , String, StringLength, MatchCount, TargetStart, TargetEnd, bWord

    TextLength := Sci.GetLength()

    WordStartPos := Sci.WordStartPosition(CurPos, WordMode)
    WordEndPos := Sci.WordEndPosition(CurPos, WordMode)

    SelStart := Sci.GetSelectionStart()
    SelEnd := Sci.GetSelectionEnd()
    SelCount := SelEnd - SelStart

    bWord := WordMode == 1 && Sci.2691(SelStart, SelEnd) ; SCI_ISRANGEWORD

    ; Clear previous highlights
    Sci.SetIndicatorCurrent(2)
    Sci.IndicatorClearRange(0, TextLength)

    If (SelCount == 0
    || (WordMode == 1 && !bWord)
    || (WordMode == 2 && (WordStartPos != SelStart || WordEndPos != SelEnd))
    || Sci.LineFromPosition(SelStart) != Sci.LineFromPosition(SelEnd)) {
        Return
    }

    String := GetSelectedText()

    Sci.IndicSetStyle(2, 8) ; INDIC_STRAIGHTBOX
    Sci.IndicSetFore(2, CvtClr(0x3FBBE3))
    Sci.IndicSetAlpha(2, 80)
    Sci.IndicSetOutlineAlpha(2, 80)

    Sci.SetSearchFlags(SearchFlags)

    Sci.2690() ; SCI_TARGETWHOLEDOCUMENT
    StringLength := StrPut(String, "UTF-8") - 1

    MatchCount := 0
    While (Sci.SearchInTarget(StringLength, "" . String, 1) != -1 && ++MatchCount < Limit) {
        TargetStart := Sci.GetTargetStart()
        TargetEnd := Sci.GetTargetEnd()
        If (TargetEnd != SelEnd) {
            Sci.SetIndicatorCurrent(2)
            Sci.IndicatorFillRange(TargetStart, TargetEnd - TargetStart)
        }

        Sci.SetTargetStart(TargetEnd)
        Sci.SetTargetEnd(TextLength)
    }
}

; Called from SCN_UPDATEUI and SetStatusBar
UpdateStatusBar() {
    If (!g_GuiVis) {
        CurPos := Sci.GetCurrentPos()
        Line := Sci.LineFromPosition(CurPos) + 1
        Column := Sci.GetColumn(CurPos) + 1

        SelStart := Sci.GetSelectionStart()
        SelEnd := Sci.GetSelectionEnd()
        SelLength := SelEnd - SelStart
        Selection := SelLength ? ", " . SelLength : ""

        Gui Auto: Default
        SB_SetText(Line . ":" . Column . Selection, 2)

        UpdateDocumentStatus()
    }
}

UpdateDocumentStatus() {
    Gui Auto: Default
    SB_SetText(Sci.GetModify() ? "Unsaved" : "", 3)
    SB_SetText(GetFileEncodingDisplayName(), 4)
}

; Called from SCN_SAVEPOINTREACHED, SCN_SAVEPOINTLEFT, NewGUI and Save.
SetDocumentStatus() {
    If (!g_GuiVis) {
        UpdateDocumentStatus()
    }
}

Copy() {
    If (GetSelectedText() == "") {
        Clipboard := GetText()
    }
}

SelectAll() {
    Sci.SelectAll()
}

ShowGoToLineDialog() {
    Local Line := InputBoxEx("Line Number:", "", "Go to Line", "", "", "x94 w80 Number", hAutoWnd, 270)
    If (!ErrorLevel) {
        ShowChildWindow(0)
        Sci.GrabFocus()

        If (Line != "") {
            Sci.GoToLine(Line - 1) ; 0-based index
            GoToLine(Line - 1)
        }
    }
}

GoToLine(Line) {
    Sci.GoToPos(Sci.PositionFromLine(Line))
    Sci.VerticalCentreCaret()
}

ChangeEditorFont() {
    If (ChooseFont(g_SciFontName, g_SciFontSize, "", "0x000000", 0x800041, hAutoWnd)) {
        Sci.SetZoom(0) ; Reset zoom
        Sci.MarginLen := 0
        Sci.StyleSetFont(STYLE_DEFAULT, "" . g_SciFontName, 1)
        Sci.StyleSetSize(STYLE_DEFAULT, g_SciFontSize)
        ApplyTheme()
    }
}

ToggleLineNumbers() {
    g_LineNumbers := !g_LineNumbers
    SetLineNumberWidth()
    Menu AutoViewMenu, ToggleCheck, Show &Line Numbers
}

ToggleWordWrap() {
    g_WordWrap := !Sci.GetWrapMode()
    Sci.SetWrapMode(g_WordWrap)
    Menu AutoViewMenu, ToggleCheck, &Wrap Long Lines
}

ToggleAskToSaveOnExit() {
    g_AskToSaveOnExit := !g_AskToSaveOnExit
    Menu AutoFileMenu, ToggleCheck, Ask to Save on Exit
}

GetLine(Line) { ; 0-based
    Local LineLen, LineText
    Line := Line > 0 ? Line : 0
    LineLen := Sci.LineLength(Line)
    VarSetCapacity(LineText, LineLen, 0)
    Sci.GetLine(Line, &LineText)
    Return StrGet(&LineText,, "UTF-8")
}

IfBetween(ByRef Var, LowerBound, UpperBound) {
    If Var Between %LowerBound% And %UpperBound%
        Return True
}

IfNotBetween(ByRef Var, LowerBound, UpperBound) {
    If Var Not Between %LowerBound% And %UpperBound%
        Return True
}

GetIniFileLocation(Filename) {
    Local FullPath, AppCfgFile
    FullPath := A_ScriptDir . "\Settings\" . Filename

    If (!FileExist(FullPath)) {
        AppCfgFile := g_AppData . "\" . Filename
        If (FileExist(AppCfgFile)) {
            Return AppCfgFile
        }
    }

    Return FullPath
}

OnWM_SYSCOMMAND(wParam, lParam, msg, hWnd) {
    If (wParam == 0x3E8) {
        SaveSettings()
    }
}

ApplyTheme() {
    Static SCE_AHKL_IDENTIFIER := 1, SCE_AHKL_COMMENTDOC := 2, SCE_AHKL_COMMENTLINE := 3
    , SCE_AHKL_COMMENTBLOCK := 4, SCE_AHKL_COMMENTKEYWORD := 5, SCE_AHKL_STRING := 6
    , SCE_AHKL_STRINGOPTS := 7, SCE_AHKL_STRINGBLOCK := 8, SCE_AHKL_STRINGCOMMENT := 9
    , SCE_AHKL_LABEL := 10, SCE_AHKL_HOTKEY := 11, SCE_AHKL_HOTSTRING := 12
    , SCE_AHKL_HOTSTRINGOPT := 13, SCE_AHKL_HEXNUMBER := 14, SCE_AHKL_DECNUMBER := 15
    , SCE_AHKL_VAR := 16, SCE_AHKL_VARREF := 17, SCE_AHKL_OBJECT := 18
    , SCE_AHKL_USERFUNCTION := 19, SCE_AHKL_DIRECTIVE := 20, SCE_AHKL_COMMAND := 21
    , SCE_AHKL_PARAM := 22, SCE_AHKL_CONTROLFLOW := 23, SCE_AHKL_BUILTINFUNCTION := 24
    , SCE_AHKL_BUILTINVAR := 25, SCE_AHKL_KEY := 26, SCE_AHKL_USERDEFINED1 := 27
    , SCE_AHKL_USERDEFINED2 := 28, SCE_AHKL_ESCAPESEQ := 30, SCE_AHKL_ERROR := 31

    Sci.StyleSetFore(STYLE_DEFAULT, CvtClr(0x000000))
    Sci.StyleSetBack(STYLE_DEFAULT, CvtClr(0xF8F8F8))
    Sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Active line background color
    Sci.SetCaretLineBack(CvtClr(g_HighlightActiveLine ? 0xD8F3FF : 0xFFFFFF))
    Sci.SetCaretLineVisible(True)
    Sci.SetCaretLineVisibleAlways(1)

    Sci.SetCaretFore(CvtClr(0x000000))
    Sci.SetCaretWidth(2)
    Sci.SetCaretStyle(1)

    ; Margin
    Sci.StyleSetFore(33, CvtClr(0xCFD2CA)) ; Margin foreground color
    Sci.StyleSetBack(33, CvtClr(0xFFFFFF)) ; Margin background color

    ; Selection
    Sci.SetSelFore(1, CvtClr(0xFFFFFF))
    Sci.SetSelBack(1, CvtClr(0x3399FF))

    ; Matching braces
    Sci.StyleSetFore(STYLE_BRACELIGHT, CvtClr(0x3399FF))
    Sci.StyleSetBold(STYLE_BRACELIGHT, True)

    ; AHK syntax elements
    Sci.StyleSetFore(SCE_AHKL_IDENTIFIER     , CvtClr(0x000000))
    Sci.StyleSetFore(SCE_AHKL_COMMENTDOC     , CvtClr(0x008888))
    Sci.StyleSetFore(SCE_AHKL_COMMENTLINE    , CvtClr(0x767676))
    Sci.StyleSetFore(SCE_AHKL_COMMENTBLOCK   , CvtClr(0x767676))
    Sci.StyleSetFore(SCE_AHKL_COMMENTKEYWORD , CvtClr(0x0000DD))
    Sci.StyleSetFore(SCE_AHKL_STRING         , CvtClr(0x183691))
    Sci.StyleSetFore(SCE_AHKL_STRINGOPTS     , CvtClr(0x0000EE))
    Sci.StyleSetFore(SCE_AHKL_STRINGBLOCK    , CvtClr(0x183691))
    Sci.StyleSetFore(SCE_AHKL_STRINGCOMMENT  , CvtClr(0xFF0000))
    Sci.StyleSetFore(SCE_AHKL_LABEL          , CvtClr(0x0000DD))
    Sci.StyleSetFore(SCE_AHKL_HOTKEY         , CvtClr(0x0000DD))
    Sci.StyleSetFore(SCE_AHKL_HOTSTRING      , CvtClr(0x183691))
    Sci.StyleSetFore(SCE_AHKL_HOTSTRINGOPT   , CvtClr(0x990099))
    Sci.StyleSetFore(SCE_AHKL_HEXNUMBER      , CvtClr(0x880088))
    Sci.StyleSetFore(SCE_AHKL_DECNUMBER      , CvtClr(0x606870))
    ;Sci.StyleSetFore(SCE_AHKL_VAR            , CvtClr(0x9F1F6F))
    Sci.StyleSetFore(SCE_AHKL_VARREF         , CvtClr(0x990055))
    ;Sci.StyleSetFore(SCE_AHKL_OBJECT         , CvtClr(0x008888))
    Sci.StyleSetFore(SCE_AHKL_USERFUNCTION   , CvtClr(0x0000DD))
    Sci.StyleSetFore(SCE_AHKL_DIRECTIVE      , CvtClr(0x0000CF))
    Sci.StyleSetFore(SCE_AHKL_COMMAND        , CvtClr(0x0070A0))
    Sci.StyleSetFore(SCE_AHKL_PARAM          , CvtClr(0x0070A0))
    Sci.StyleSetFore(SCE_AHKL_CONTROLFLOW    , CvtClr(0x0000DD))
    Sci.StyleSetFore(SCE_AHKL_BUILTINFUNCTION, CvtClr(0x0F707F))
    Sci.StyleSetFore(SCE_AHKL_BUILTINVAR     , CvtClr(0x9F1F6F))
    Sci.StyleSetFore(SCE_AHKL_KEY            , CvtClr(0x9F1F6F))
    ;Sci.StyleSetFore(SCE_AHKL_USERDEFINED1   , CvtClr(0x000000))
    Sci.StyleSetFore(SCE_AHKL_ESCAPESEQ      , CvtClr(0x660000))
    ;Sci.StyleSetFore(SCE_AHKL_ERROR          , CvtClt(0xFF0000))
}

#Include %A_ScriptDir%\Include\Designer.ahk
#Include %A_ScriptDir%\Include\Properties.ahk
#Include %A_ScriptDir%\Include\FontDialog.ahk
#Include %A_ScriptDir%\Include\MenuEditor.ahk
#Include %A_ScriptDir%\Include\ToolbarEditor.ahk
#Include %A_ScriptDir%\Include\CloneWindow.ahk
#Include %A_ScriptDir%\Include\ScriptParser.ahk
#Include %A_ScriptDir%\Include\GenerateCode.ahk
#Include %A_ScriptDir%\Include\Settings.ahk
#Include %A_ScriptDir%\Lib\AuxLib.ahk
#Include %A_ScriptDir%\Lib\Toolbar.ahk
#Include %A_ScriptDir%\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\Lib\CommonDialogs.ahk
#Include %A_ScriptDir%\Lib\GuiButtonIcon.ahk
#Include %A_ScriptDir%\Lib\CreateDIB.ahk
