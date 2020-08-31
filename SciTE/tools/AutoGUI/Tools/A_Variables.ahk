; A_Variables - AutoHotkey Built-in Variables v1.1.2

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%

Global A := Array()
     , G := Array()
     , hLV
     , NT6 := DllCall("GetVersion") & 0xFF > 5
     , Indent := (NT6) ? "    " : ""

; AutoHotkey Information
G.Push([10, "AutoHotkey Information"])
A.Push(["A_AhkPath", A_AhkPath, 10])
A.Push(["A_AhkVersion", A_AhkVersion, 10])
A.Push(["A_IsUnicode", A_IsUnicode, 10])

; Operating System and User Information
G.Push([20, "Operating System and User Information"])
A.Push(["A_OSType", A_OSType, 20])
A.Push(["A_OSVersion", A_OSVersion, 20])
A.Push(["A_Is64bitOS", A_Is64bitOS, 20])
A.Push(["A_PtrSize", A_PtrSize, 20])
A.Push(["A_Language", A_Language, 20])
A.Push(["A_ComputerName", A_ComputerName, 20])
A.Push(["A_UserName", A_UserName, 20])
A.Push(["A_IsAdmin", A_IsAdmin, 20])

; Screen Resolution
G.Push([30, "Screen Resolution"])
A.Push(["A_ScreenWidth", A_ScreenWidth, 30])
A.Push(["A_ScreenHeight", A_ScreenHeight, 30])
A.Push(["A_ScreenDPI", A_ScreenDPI, 30])

; Script Properties
G.Push([40, "Script Properties"])
A.Push(["A_WorkingDir", A_WorkingDir, 40])
A.Push(["A_ScriptDir", A_ScriptDir, 40])
A.Push(["A_ScriptName", A_ScriptName, 40])
A.Push(["A_ScriptFullPath", A_ScriptFullPath, 40])
A.Push(["A_ScriptHwnd", A_ScriptHwnd, 40])
A.Push(["A_LineNumber", A_LineNumber, 40])
A.Push(["A_LineFile", A_LineFile, 40])
A.Push(["A_ThisFunc", A_ThisFunc, 40])
A.Push(["A_ThisLabel", A_ThisLabel, 40])
A.Push(["A_IsCompiled", A_IsCompiled, 40])
A.Push(["A_IsSuspended", A_IsSuspended, 40])
A.Push(["A_IsPaused", A_IsPaused, 40])
A.Push(["A_ListLines", A_ListLines, 40])
A.Push(["A_ExitReason", A_ExitReason, 40])

; Date and Time
G.Push([50, "Date and Time"])
A.Push(["A_Year", A_Year, 50])
A.Push(["A_Mon", A_Mon, 50])
A.Push(["A_DD", A_DD, 50])
A.Push(["A_YYYY", A_YYYY, 50])
A.Push(["A_MMMM", A_MMMM, 50])
A.Push(["A_MMM", A_MMM, 50])
A.Push(["A_MM", A_MM, 50])
A.Push(["A_DDDD", A_DDDD, 50])
A.Push(["A_DDD", A_DDD, 50])
A.Push(["A_MDAY", A_MDAY, 50])
A.Push(["A_WDay", A_WDay, 50])
A.Push(["A_YDay", A_YDay, 50])
A.Push(["A_YWeek", A_YWeek, 50])
A.Push(["A_Hour", A_Hour, 50])
A.Push(["A_Min", A_Min, 50])
A.Push(["A_Sec", A_Sec, 50])
A.Push(["A_MSec", A_MSec, 50])
A.Push(["A_Now", A_Now, 50])
A.Push(["A_NowUTC", A_NowUTC, 50])
A.Push(["A_TickCount", A_TickCount, 50])

; Script Settings (Performance, Detection and Reliability)
G.Push([60, "Script Settings (Performance, Detection and Reliability)"])
A.Push(["A_BatchLines", A_BatchLines, 60])
A.Push(["A_NumBatchLines", A_NumBatchLines, 60])
A.Push(["A_IsCritical", A_IsCritical, 60])
A.Push(["A_TitleMatchMode", A_TitleMatchMode, 60])
A.Push(["A_TitleMatchModeSpeed", A_TitleMatchModeSpeed, 60])
A.Push(["A_DetectHiddenWindows", A_DetectHiddenWindows, 60])
A.Push(["A_DetectHiddenText", A_DetectHiddenText, 60])
A.Push(["A_WinDelay", A_WinDelay, 60])
A.Push(["A_ControlDelay", A_ControlDelay, 60])
A.Push(["A_KeyDelay", A_KeyDelay, 60])
A.Push(["A_KeyDelayPlay", A_KeyDelayPlay, 60])
A.Push(["A_KeyDuration", A_KeyDelayPlay, 60])
A.Push(["A_KeyDurationPlay", A_KeyDelayPlay, 60])
A.Push(["A_SendMode", A_SendLevel, 60])
A.Push(["A_SendLevel", A_SendLevel, 60])
A.Push(["A_MouseDelay", A_MouseDelay, 60])
A.Push(["A_MouseDelayPlay", A_MouseDelayPlay, 60])
A.Push(["A_DefaultMouseSpeed", A_DefaultMouseSpeed, 60])

; Script Settings (Misc.)
G.Push([70, "Script Settings (Misc.)"])
A.Push(["A_FileEncoding", A_FileEncoding, 70])
A.Push(["A_StringCaseSense", A_StringCaseSense, 70])
A.Push(["A_AutoTrim", A_AutoTrim, 70])
A.Push(["A_FormatInteger", A_FormatInteger, 70])
A.Push(["A_FormatFloat", A_FormatFloat, 70])
A.Push(["A_StoreCapslockMode", A_StoreCapslockMode, 70])

; Coordinate Mode
G.Push([80, "Coordinate Mode"])
A.Push(["A_CoordModeToolTip", A_CoordModeToolTip, 80])
A.Push(["A_CoordModePixel", A_CoordModePixel, 80])
A.Push(["A_CoordModeMouse", A_CoordModeMouse, 80])
A.Push(["A_CoordModeCaret", A_CoordModeCaret, 80])
A.Push(["A_CoordModeMenu", A_CoordModeMenu, 80])

; GUI (Windows and Controls)
G.Push([90, "GUI (Windows and Controls)"])
A.Push(["A_Gui", A_Gui, 90])
A.Push(["A_GuiX", A_GuiX, 90])
A.Push(["A_GuiY", A_GuiY, 90])
A.Push(["A_GuiWidth", A_GuiWidth, 90])
A.Push(["A_GuiHeight", A_GuiHeight, 90])
A.Push(["A_GuiEvent", A_GuiEvent, 90])
A.Push(["A_GuiControl", A_GuiControl, 90])
A.Push(["A_GuiControlEvent", A_GuiControlEvent, 90])
A.Push(["A_EventInfo", A_EventInfo, 90])
A.Push(["A_DefaultGui", A_DefaultGui, 90])
A.Push(["A_DefaultListView", A_DefaultListView, 90])
A.Push(["A_DefaultTreeView", A_DefaultTreeView, 90])

; Menu Identification
G.Push([100, "Menu Identification"])
A.Push(["A_ThisMenuItem", A_ThisMenuItem, 100])
A.Push(["A_ThisMenu", A_ThisMenu, 100])
A.Push(["A_ThisMenuItemPos", A_ThisMenuItemPos, 100])

; Tray Icon Settings
G.Push([110, "Tray Icon Settings"])
A.Push(["A_IconHidden", A_IconHidden, 110])
A.Push(["A_IconTip", A_IconTip, 110])
A.Push(["A_IconFile", A_IconFile, 110])
A.Push(["A_IconNumber", A_IconNumber, 110])

; Hotkeys and Hotstrings
G.Push([120, "Hotkeys and Hotstrings"])
A.Push(["A_ThisHotkey", A_ThisHotkey, 120])
A.Push(["A_PriorHotkey", A_PriorHotkey, 120])
A.Push(["A_PriorKey", A_PriorKey, 120])
A.Push(["A_TimeSinceThisHotkey", A_TimeSinceThisHotkey, 120])
A.Push(["A_TimeSincePriorHotkey", A_TimeSincePriorHotkey, 120])
A.Push(["A_EndChar", A_EndChar, 120])

; User Idle Time
G.Push([130, "User Idle Time"])
A.Push(["A_TimeIdle", A_TimeIdle, 130])
A.Push(["A_TimeIdlePhysical", A_TimeIdlePhysical, 130])
A.Push(["A_TimeIdleKeyboard", A_TimeIdleKeyboard, 130])
A.Push(["A_TimeIdleMouse", A_TimeIdleMouse, 130])

; Special Paths
G.Push([140, "Special Paths"])
A.Push(["A_Temp", A_Temp, 140])
A.Push(["A_WinDir", A_WinDir, 140])
A.Push(["ProgramFiles", ProgramFiles, 140])
A.Push(["A_ProgramFiles", A_ProgramFiles, 140])
A.Push(["A_AppData", A_AppData, 140])
A.Push(["A_AppDataCommon", A_AppDataCommon, 140])
A.Push(["A_Desktop", A_Desktop, 140])
A.Push(["A_DesktopCommon", A_DesktopCommon, 140])
A.Push(["A_StartMenu", A_StartMenu, 140])
A.Push(["A_StartMenuCommon", A_StartMenuCommon, 140])
A.Push(["A_Programs", A_Programs, 140])
A.Push(["A_ProgramsCommon", A_ProgramsCommon, 140])
A.Push(["A_Startup", A_Startup, 140])
A.Push(["A_StartupCommon", A_StartupCommon, 140])
A.Push(["A_MyDocuments", A_MyDocuments, 140])
A.Push(["A_ComSpec", A_ComSpec, 140])
A.Push(["ComSpec", ComSpec, 140])

; IP Address
G.Push([150, "IP Address"])
A.Push(["A_IPAddress1", A_IPAddress1, 150])
A.Push(["A_IPAddress2", A_IPAddress2, 150])
A.Push(["A_IPAddress3", A_IPAddress3, 150])
A.Push(["A_IPAddress4", A_IPAddress4, 150])

; Cursor
G.Push([160, "Cursor"])
A.Push(["A_Cursor", A_Cursor, 160])
A.Push(["A_CaretX", A_CaretX, 160])
A.Push(["A_CaretY", A_CaretY, 160])

; Clipboard
G.Push([170, "Clipboard"])
A.Push(["Clipboard", Clipboard, 170])
A.Push(["ClipboardAll", ClipboardAll, 170])

; Loops
G.Push([180, "Loops"])
A.Push(["A_Index", A_Index, 180])
A.Push(["A_LoopField", A_LoopField, 180])

; Loop Files
G.Push([190, "Loop Files"])
A.Push(["A_LoopReadLine", A_LoopReadLine, 190])
A.Push(["A_LoopFileFullPath", A_LoopFileFullPath, 190])
A.Push(["A_LoopFilePath", A_LoopFilePath, 190])
A.Push(["A_LoopFileDir", A_LoopFileDir, 190])
A.Push(["A_LoopFileName", A_LoopFileName, 190])
A.Push(["A_LoopFileExt", A_LoopFileExt, 190])
A.Push(["A_LoopFileLongPath", A_LoopFileLongPath, 190])
A.Push(["A_LoopFileShortPath", A_LoopFileShortPath, 190])
A.Push(["A_LoopFileShortName", A_LoopFileShortName, 190])
A.Push(["A_LoopFileAttrib", A_LoopFileAttrib, 190])
A.Push(["A_LoopFileSize", A_LoopFileSize, 190])
A.Push(["A_LoopFileSizeKB", A_LoopFileSizeKB, 190])
A.Push(["A_LoopFileSizeMB", A_LoopFileSizeMB, 190])
A.Push(["A_LoopFileTimeCreated", A_LoopFileTimeCreated, 190])
A.Push(["A_LoopFileTimeModified", A_LoopFileTimeModified, 190])
A.Push(["A_LoopFileTimeAccessed", A_LoopFileTimeAccessed, 190])

; Registry
G.Push([200, "Registry"])
A.Push(["A_LoopRegName", A_LoopRegName, 200])
A.Push(["A_LoopRegType", A_LoopRegType, 200])
A.Push(["A_LoopRegKey", A_LoopRegKey, 200])
A.Push(["A_LoopRegSubkey", A_LoopRegSubkey, 200])
A.Push(["A_LoopRegTimeModified", A_LoopRegTimeModified, 200])
A.Push(["A_RegView", A_RegView, 200])

; Special Characters
G.Push([210, "Special Characters"])
A.Push(["A_Space", A_Space, 210])
A.Push(["A_Tab", A_Tab, 210])

; Error Codes
G.Push([220, "Error Codes"])
A.Push(["ErrorLevel", ErrorLevel, 220])
A.Push(["A_LastError", A_LastError, 220])

; AHK_H Only
If (A_DllPath != "") {
    G.Push([230, "AutoHotkey_H Only"])
    A.Push(["NULL", NULL, 230])
    A.Push(["A_AhkDir", A_AhkDir, 230])
    A.Push(["A_IsDll", A_IsDll, 230])
    A.Push(["A_DllPath", A_DllPath, 230])
    A.Push(["A_DllDir", A_DllDir, 230])
    A.Push(["A_ModuleHandle", A_ModuleHandle, 230])
    A.Push(["A_Input", A_Input, 230])
    A.Push(["A_ScriptStruct", A_ScriptStruct, 230])
    A.Push(["A_GlobalStruct", A_GlobalStruct, 230])
    A.Push(["A_MainThreadID", A_MainThreadID, 230])
    A.Push(["A_ThreadID", A_ThreadID, 230])
    A.Push(["A_ZipCompressionLevel", A_ZipCompressionLevel, 230])
}

Menu Tray, Icon, %A_ScriptDir%\..\Icons\A_Variables.ico

Gui +Resize
Gui Color, 0xFEFEFE

Gui Add, Picture, x10 y10 w32 h32, %A_ScriptDir%\..\Icons\A_Variables.ico

Gui Font, c0x003399, MS Shell Dlg 2
;Gui Font, c0x003399 s9, Segoe UI
Gui Add, Text, x45 y11 w630 h26, The following variables are built into the program and can be referenced by any script. With the exception of Clipboard, ErrorLevel, and command line parameters, these variables are read-only`; that is, their contents cannot be directly altered by the script. 

If (NT6) {
    Gui Font, s9 cBlack, Segoe UI
} Else {
    Gui Font, s10 cBlack, Lucida Console
}

Gui Add, ListView, hWndhLV vLV x-1 y48 w690 h339 LV0x4000, Variable|Value
If (!NT6) {
    ; Increase row height on Windows XP
    LV_SetImageList(DllCall("ImageList_Create", "Int", 2, "Int", 20, "UInt", 0x18, "Int", 1, "Int", 1, "Ptr"), 1)
    GuiControl +Grid, SysListView321
}
Gui Font

; Footer area
Gui Add, TreeView, hWndhTV x-1 y386 w690 h48 BackgroundF1F5FB Disabled 
Gui Font, s9, Segoe UI
Gui Add, Edit, hWndhEdtSearch vSearch gSearch x10 y398 w186 h23 +0x2000000 ; WS_CLIPCHILDREN
DllCall("SendMessage", "Ptr", hEdtSearch, "UInt", 0x1501, "Ptr", 1, "WStr", "Search", "Ptr") ; Hint text
Gui Add, Picture, hWndhPicSearch x165 y1 w16 h16, %A_ScriptDir%\..\Icons\Search.ico ; Search icon
DllCall("SetParent", "Ptr", hPicSearch, "Ptr", hEdtSearch)
WinSet Style, -0x40000000, ahk_id %hPicSearch% ; -WS_CHILD
ControlFocus,, ahk_id %hEdtSearch%

Gui Show, w688 h432, A_Variables - AutoHotkey Built-in Variables

Menu ContextMenu, Add, Copy`tCtrl+C, MenuHandler
Menu ContextMenu, Icon, 1&, shell32.dll, 135
Menu ContextMenu, Add, Copy Variable, MenuHandler
Menu ContextMenu, Add, Copy Value, MenuHandler
Menu ContextMenu, Add
Menu ContextMenu, Add, Select All`tCtrl+A, SelectAll

If (NT6) {
    Loop % G.Length() {
        LV_InsertGroup(hLV, G[A_Index][1], G[A_Index][2]) ; Define LV Groups
    }

    SendMessage 0x109D, 1, 0,, ahk_id %hLV% ; LVM_ENABLEGROUPVIEW

    DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLV, "WStr", "Explorer", "Ptr", 0)
}

ShowVariables()

OnMessage(0x100, "OnWM_KEYDOWN")
Return

Search:
    Gui Submit, NoHide
    ShowVariables(Search)
Return

ShowVariables(Filter:= "") {
    LV_Delete()
    GuiControl -Redraw, SysListView321

    For Index, Value in A {
        If (InStr(A[Index][1], Filter) || InStr(A[Index][2], Filter)) {
            Row := LV_Add("", Indent . A[Index][1], A[Index][2])
            If (NT6 && A[Index][3] != "") {
                LV_SetGroup(hLV, Row, A[Index][3])
            }
        }
    }

    GuiControl +Redraw, SysListView321
    LV_ModifyCol(1, 186)
    LV_ModifyCol(2, 483)
}

GuiContextMenu:
    If (A_GuiControl == "LV" && LV_GetNext()) {
        Menu ContextMenu, Show    
    }
Return

MenuHandler:
    Copy(A_ThisMenuItemPos)
Return

Copy(Param) {
    Global

    Gui +LastFound
    ControlGetFocus Focus
    If (Focus == "Edit1") {
        Send ^C
        Return
    }

    Output := ""

    If (Param != 1) {
        Row := 0
        Col := (Param == 2) ? 1 : 2

        While(Row := LV_GetNext(Row)) {
            LV_GetText(Text, Row, Col)
            Output .= Text . "`r`n"
        }
    } Else {
        ControlGet Output, List, Selected, SysListView321
    }

    If (Output != "") {
        Output := RegExReplace(Output, "m`n)^\s+")
        Clipboard := RTrim(Output, " `t`r`n")
    }
}

SelectAll:
    Gui +LastFound
    ControlGetFocus Focus
    If (Focus == "Edit1") {
        Send ^A
        Return
    }

    ControlFocus, SysListView321
    LV_Modify(0, "Select")
Return

LV_InsertGroup(hLV, GroupID, Header, Index := -1) {
    Static iGroupId := (A_PtrSize == 8) ? 36 : 24
    NumPut(VarSetCapacity(LVGROUP, 56, 0), LVGROUP, 0)
    NumPut(0x15, LVGROUP, 4, "UInt") ; mask: LVGF_HEADER|LVGF_STATE|LVGF_GROUPID
    NumPut((A_IsUnicode) ? &Header : UTF16(Header, _), LVGROUP, 8, "Ptr") ; pszHeader
    NumPut(GroupID, LVGROUP, iGroupId, "Int") ; iGroupId
    NumPut(0x8, LVGROUP, iGroupId + 8, "Int") ; state: LVGS_COLLAPSIBLE
    SendMessage 0x1091, %Index%, % &LVGROUP,, ahk_id %hLV% ; LVM_INSERTGROUP
    Return ErrorLevel
}

LV_SetGroup(hLV, Row, GroupID) {
    Static iGroupId := (A_PtrSize == 8) ? 52 : 40
    VarSetCapacity(LVITEM, 58, 0)
    NumPut(0x100, LVITEM, 0, "UInt")  ; mask: LVIF_GROUPID
    NumPut(Row - 1, LVITEM, 4, "Int") ; iItem
    NumPut(GroupID, LVITEM, iGroupId, "Int")
    SendMessage 0x1006, 0, &LVITEM,, ahk_id %HLV% ; LVM_SETITEMA
    Return ErrorLevel
}

UTF16(String, ByRef Var) {
    VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
    StrPut(String, &Var, "UTF-16")
    Return &Var
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    CtrlP := GetKeyState("Ctrl", "P")

    If (wParam == 65 && CtrlP) {
        GoSub SelectAll
        Return False
    }

    If (wParam == 67 && CtrlP) {
        Copy(1)
        Return False    
    }
}

GuiSize:
    ;AutoXYWH("w*", "Static2")
    AutoXYWH("wh", hLV)
    AutoXYWH("wy*", hTV)
    AutoXYWH("y" , hEdtSearch)
    AutoXYWH("y" , hPicSearch)
    WinSet Redraw,, ahk_id %hPicSearch%
Return

GuiEscape:
GuiClose:
    ExitApp

; http://ahkscript.org/boards/viewtopic.php?t=1079
AutoXYWH(DimSize, cList*) {
    Local a
    Static cInfo := {}
 
    If (DimSize = "reset") {
        Return cInfo := {}
    }
 
    For i, ctrl in cList {
        ctrlID := A_Gui ":" ctrl
        If (cInfo[ctrlID].x = "") {
            GuiControlGet i, %A_Gui%: Pos, %ctrl%
            MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
            fx := fy := fw := fh := 0
            For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]"))) {
                If (!RegExMatch(DimSize, "i)" . dim . "\s*\K[\d.-]+", f%dim%)) {
                    f%dim% := 1
                }
            }
            cInfo[ctrlID] := {x: ix, fx: fx, y: iy, fy: fy, w: iw, fw: fw, h: ih, fh: fh, gw: A_GuiWidth, gh: A_GuiHeight, a: a, m: MMD}
        } Else If (cInfo[ctrlID].a.1) {
            dgx := dgw := A_GuiWidth - cInfo[ctrlID].gw, dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
            Options := ""
            For i, dim in cInfo[ctrlID]["a"] {
                Options .= dim . (dg%dim% * cInfo[ctrlID]["f" . dim] + cInfo[ctrlID][dim]) . A_Space
            }
            GuiControl, % A_Gui ":" cInfo[ctrlID].m, % ctrl, % Options
        }
    }
} 
