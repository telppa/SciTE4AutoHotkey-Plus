; https://xdebug.org/docs-dbgp.php

DebuggerInit() {
    DBGp_OnBegin("DebuggerConnected")
    DBGp_OnBreak("DebuggerBreak")
    DBGp_OnStream("DebuggerStream")
    DBGp_OnEnd("DebuggerDisconnected")

    g_DbgSocket := DBGp_StartListening("127.0.0.1", g_DbgPort)
}

DebuggerConnected(Session) {
    ;msgbox % "Connected to " . session.File

    ; Redirect OutputDebug.
    If (g_DbgCaptureStderr) {
        Session.stderr("-c 2")
    }

    ;session.stdout("-c 2") ; ?

    g_DbgSession := Session
    g_DbgSession.property_set("-n A_LastError -- 0")

    g_DbgStatus := 1

    DefineBreakpoints()

    ; Step onto the first line.
    Session.step_into()

    ShowDebugButtons()
}

; DebuggerBreak is called whenever the debugger breaks, such
; as when step_into has completed or a breakpoint has been hit.
DebuggerBreak(session, ByRef response) {

    If (InStr(response, "status=""break""")) {
        ; Get the current context; i.e. file and line.
        session.stack_get("-d 0", Response)

        ; Retrieve the line number and file URI.
        RegExMatch(Response, "lineno=""\K\d+", LineNo)
        RegExMatch(Response, "filename=""\K.*?(?="")", FileURI)

        Filename := DBGp_DecodeFileURI(FileURI)
        g_DbgSession.CurrentFile := Filename

        If (Filename == "") {
            Return
        }

        n := TabEx.GetSel()
        CurrentFile := Sci[n].FullName
        If (CurrentFile != Filename) {
            n := IsFileOpened(Filename)
            If (n) {
                TabEx.SetSel(n)
            } Else {
                Open([Filename])
                n := TabEx.GetSel()
            }
        }

        RemoveStepMarker()
        Sci[n].MarkerAdd(LineNo - 1, g_MarkerDebugStep)
        Sci[n].GoToLine(LineNo - 1)
        GoToLineEx(n, LineNo - 1)

        ; Variables
        GetContext()
        If (g_ReloadVarListOnEveryStep && IsWindowVisible(hVarListWnd)) {
            GoSub DisplayVariables
        }

        ; Call Stack
        session.stack_get("", g_DbgStack := "")
        g_DbgStack := LoadXMLData(g_DbgStack)
        GoSub UpdateCallStack

        g_DbgStatus := 2
    }
}

DebuggerStream(session, ByRef packet) {
    ; OutputDebug was called.
    If (RegExMatch(packet, "(?<=<stream type=""stderr"">).*(?=</stream>)", stderr)) {
        stderr := DBGp_Base64UTF8Decode(stderr)

        Global hLVStderr
        Gui Stderr: Default
        FormatTime Time, %A_Now%, HH:mm:ss
        LV_Add("", LV_GetCount() + 1, Time . "." . A_MSec, stderr)
        SendMessage 0x115, 7, 0,, ahk_id %hLVStderr% ; WM_VSCROLL, SB_BOTTOM
    }
}

DebuggerDisconnected(session) {
    ;MsgBox % "Disconnected from " . session.File

    g_DbgStatus := 0
    g_AttachDebugger := False

    DBGp_StopListening(g_DbgSocket)

    RemoveStepMarker()
    ShowDebugButtons(0)

    Loop % g_Breakpoints.Length() {
        g_DbgSession.breakpoint_remove("-d " . g_Breakpoints[A_Index].ID)
    }
}

; Start Debugging
DebugRun(AltRun := False) {
    If (g_DbgStatus == 0) {
        n := TabEx.GetSel()

        If (Sci[n].GetModify()) {
            If (!Save(n)) {
                Return
            }
        }

        If (AltRun) {
            If ((AhkPath := GetAltRun()) == "") {
                Return
            }
        } Else {
            AhkPath := GetKeyState("Shift", "P") ? g_AhkPath3264 : A_AhkPath
        }

        AhkScript := Sci[n].FullName
        Params := Sci[n].Parameters
        WorkingDir := GetFileDir(AhkScript)

        If (!FileExist(AhkScript)) {
            Return
        }

        DebuggerInit()

        RemoveStepMarker()

        If (g_CaptureStdErr) {
            AhkRunGetStdErr(n, AhkPath, AhkScript, Params, WorkingDir, "/Debug=127.0.0.1:" . g_DbgPort)

        } Else {
            RunWait "%AhkPath%" /debug=127.0.0.1:%g_DbgPort% "%AhkScript%" %Params%, %WorkingDir%, UseErrorLevel
            If (ErrorLevel) {
                GoSub DebugError
            }
        }

    } Else {
        g_DbgSession.run()
    }
}

DebugError:
    GoSub DebugStop
    g_DbgStatus := 0
    DBGp_StopListening(g_DbgSocket)
    ShowDebugButtons(0)
Return

DebugBreak:
    g_DbgSession.break()
Return

StepInto:
    g_DbgSession.step_into()
Return

StepOver:
    g_DbgSession.step_over()
Return

StepOut:
    g_DbgSession.step_out()
Return

DebugStop:
    If (g_AttachDebugger) {
        g_DbgSession.detach()
    } Else {
        g_DbgSession.stop()
    }

    g_DbgSession.close()
Return

LoadXMLData(ByRef Data) {
    x := ComObjCreate("MSXML2.DOMDocument")
    x.async := false
    x.loadXML(Data)
    Return x
}

GetContext() {
    ; Local variables
    g_DbgSession.context_get("-c 0", XMLLocal)
    oXMLLocal := LoadXMLData(XMLLocal)
    LocalNodes := oXMLLocal.getElementsByTagName("property")
    GetVariables(LocalNodes, g_DbgLocalVariables)

    ; Global variables
    g_DbgSession.context_get("-c 1", XMLGlobal)
    oXMLGlobal := LoadXMLData(XMLGlobal)
    GlobalNodes := oXMLGlobal.getElementsByTagName("property")
    GetVariables(GlobalNodes, g_DbgGlobalVariables)
}

GetVariables(XMLNodes, ByRef Variables) {
    Variables := []
    For Node in XMLNodes {
        Name := Node.getAttribute("fullname")

        StringUpper Type, % Node.getAttribute("type"), T

        Value := (Type == "Object") ? "" : DBGp_Base64UTF8Decode(Node.text)

        ClassName := Node.getAttribute("classname")
        If (ClassName != "" && ClassName != "Object") {
            Type := Type . " (" . ClassName . ")"
        }

        Facet := Node.getAttribute("facet")

        Variables.Push({"Name": Name, "Value": Value, "Type": Type, "Facet": Facet})
    }
}

ShowVarList:
    GetContext()

    If (IsWindow(hVarListWnd)) {
        GoSub DisplayVariables
        Gui Variables: Show
        Return
    }

    Gui Variables: New, +LabelVarList +hWndhVarListWnd +Resize +AlwaysOnTop
    SetWindowIcon(hVarListWnd, IconLib, 115)
    Gui Font, s9, Segoe UI
    Gui Color, 0xF1F5FB

    Menu VarEditMenu, Add, &Modify Variable, ModifyVariable
    Menu VarEditMenu, Add
    Menu VarEditMenu, Add, &Copy`tCtrl+C, VarListCopy
    Menu VarEditMenu, Add, Select &All`tCtrl+A, VarListSelectAll
    Menu VarEditMenu, Add
    Menu VarEditMenu, Add, E&xit`tEsc, VarListClose

    Menu VarReloadMenu, Add, &Reload List`tCtrl+R, VarListReload
    Menu VarReloadMenu, Add
    Menu VarReloadMenu, Add, Reload on &Every Debug Step, SetVarListReload

    Menu VarShowMenu, Add, Show &Indexed Variables, SetVarListOption
    Menu VarShowMenu, Add, Show &Object Members, SetVarListOption
    Menu VarShowMenu, Add, Show &Reserved Class Members, SetVarListOption
    Menu VarShowMenu, Add,
    Menu VarShowMenu, Add, &Always on Top, SetVarListAlwaysOnTop
    Menu VarShowMenu, Check, &Always on Top

    Menu VarMenuBar, Add, &Edit, :VarEditMenu
    Menu VarMenuBar, Add, &Reload, :VarReloadMenu
    Menu VarMenuBar, Add, &Show, :VarShowMenu
    Gui Menu, VarMenuBar

    Columns := g_NT6orLater ? "Name|Value|Type" : "Name|Value|Type|Scope"
    Gui Add, ListView, +hWndhLVVarList vLVVarList gVarListHandler x0 y0 w621 h370 +LV0x14000, %Columns%
    If (g_NT6orLater) {
        LV_ModifyCol(1, 200)
        LV_ModifyCol(2, 270)
        LV_ModifyCol(3, 130)
    } Else {
        LV_ModifyCol(1, 200)
        LV_ModifyCol(2, 200)
        LV_ModifyCol(3, 100)
        LV_ModifyCol(4, 100)
    }

    Gui Add, Edit, hWndhEdtVarSearch vEdtVarSearch gDisplayVariables x10 y380 w186 h23 +0x2000000 ; WS_CLIPCHILDREN
    DllCall("SendMessage", "Ptr", hEdtVarSearch, "UInt", 0x1501, "Ptr", 1, "WStr", "Search") ; Hint text
    Gui Add, Picture, hWndhPicVarSearch x165 y1 w16 h16, % A_ScriptDir . "\Icons\Search.ico"
    DllCall("SetParent", "Ptr", hPicVarSearch, "Ptr", hEdtVarSearch)
    WinSet Style, -0x40000000, ahk_id %hPicVarSearch% ; -WS_CHILD

    Gui Add, CheckBox, vChkVarName x208 y380 w64 h23 +Checked, &Name
    Gui Add, CheckBox, vChkVarValue x277 y380 w64 h23 +Checked, &Value
    Gui Add, CheckBox, vChkVarRegEx x346 y380 w130 h23, &Regular Expression

    Gui Show, w621 h414, Variables

    VarListIL := IL_Create(7)
    IL_Add(VarListIL, IconLib, 116)
    IL_Add(VarListIL, IconLib, 117)
    IL_Add(VarListIL, IconLib, 118)
    IL_Add(VarListIL, IconLib, 119)
    IL_Add(VarListIL, IconLib, 122)
    IL_Add(VarListIL, IconLib, 120)
    IL_Add(VarListIL, IconLib, 121)
    LV_SetImageList(VarListIL, 1)

    If (g_NT6orLater) {
        LV_InsertGroup(hLVVarList, 1, "Local Variables")
        LV_InsertGroup(hLVVarList, 2, "Global Variables")
        LV_EnableGroupView(hLVVarList)
        SetExplorerTheme(hLVVarList)
    }

    GoSub DisplayVariables

    GuiControl Focus, EdtVarSearch

    If (g_ReloadVarListOnEveryStep) {
        Menu VarReloadMenu, Check, Reload on &Every Debug Step
    }

    If (g_ShowIndexedVariables) {
        Menu VarShowMenu, Check, Show &Indexed Variables
    }

    If (g_ShowObjectMembers) {
        Menu VarShowMenu, Check, Show &Object Members
    }

    If (!g_HideReservedClassMembers) {
        Menu VarShowMenu, Check, Show &Reserved Class Members
    }

    Menu VarContextMenu, Add, Modify Value, ModifyVariable
    Menu VarContextMenu, Add
    Menu VarContextMenu, Add, Copy, VarListCopy
    Menu VarContextMenu, Add, Select All, VarListSelectAll
Return

VarListReload:
    GetContext()
    GoSub DisplayVariables
Return

VarListSize:
    AutoXYWH("wh", hLVVarList)
    AutoXYWH("y", hEdtVarSearch)
    AutoXYWH("y", "ChkVarName")
    AutoXYWH("y", "ChkVarValue")
    AutoXYWH("y", "ChkVarRegEx")
Return

VarListEscape:
VarListClose:
    Gui Variables: Hide
Return

DisplayVariables:
    Gui Variables: Default
    Gui ListView, %hLVVarList%
    Gui Submit, NoHide

    SearchFunc := ChkVarRegEx ? "RegExMatch" : "InStr"

    LV_Delete()
    GuiControl -Redraw, %hLVVarList%

    Variables := [g_DbgLocalVariables, g_DbgGlobalVariables]
    Loop % Variables.Length() {
        i := A_Index
        Scope := i == 1 ? "Local" : "Global"
        For Each, Item in Variables[i] {
            If (g_HideReservedClassMembers && RegExMatch(Item.Name, "\.(base|Name|__Class|__Init)")) {
                Continue
            }

            If (!g_ShowIndexedVariables && InStr(Item.Name, "[")) {
                Continue
            }

            If (!g_ShowObjectMembers && InStr(Item.Name, ".")) {
                Continue
            }

            If ((ChkVarName && %SearchFunc%(Item.Name, EdtVarSearch))
            || (ChkVarValue && %SearchFunc%(Item.Value, EdtVarSearch))) {
                Icon := "Icon" . GetVarIconType(Item.Name, Item.Type, Item.Facet)
                Row := LV_Add(Icon, Item.Name, Item.Value, Item.Type, Scope)
                LV_SetGroup(hLVVarList, Row, i)
            }
        }
    }

    GuiControl +Redraw, %hLVVarList%
Return

GetVarIconType(VarName, VarType, VarFacet) {
    If (InStr(VarType, "Com", 1)) { ; ComObject
        Return 7
    } Else If (InStr(VarType, "Fi", 1)) { ; FileObject
        Return 6
    } Else If (InStr(VarType, "Fu", 1)) { ; Func or BoundFunc
        Return 5
    } Else If (SubStr(VarType, 1, 1) == "O") { ; Object
        Return 3
    } Else If (VarName ~= "\.|\[") { ; Object member or indexed variable
        Return 4
    } Else If (VarFacet == "Builtin" || VarName ~= "i)^(Clipboard|ClipboardAll|ErrorLevel|\d+)$") {
        Return 2
    } Else {
        Return 1
    }
}

VarListHandler:
    If (A_GuiEvent == "DoubleClick") {
        GoSub ModifyVariable
    }
Return

VarListContextMenu:
    If (A_GuiControl == "LVVarList" && LV_GetNext()) {
        Menu VarContextMenu, Show
    }
Return

ModifyVariable:
    Gui Variables: Default

    Row := LV_GetNext()
    If (!Row) {
        Return
    }

    LV_GetText(VarName, Row)
    LV_GetText(VarValue, Row, 2)

    If (g_NT6orLater) {
        Context := LV_GetGroupId(hLVVarList, Row) - 1 ; 0 = local, 1 = global
    } Else {
        LV_GetText(Scope, Row, 4)
        Context := Scope == "Local" ? 0 : 1
    }

    If (VarName = "A_LastError") {
        Gui Variables: +OwnDialogs
        MsgBox 0x40000, A_LastError: %VarValue%, % GetErrorMessage(VarValue+0)
        Return
    }

    Builtin := False
    If (VarName = "ClipboardAll") {
        Builtin := True
    } Else {
        For Each, Item in g_DbgGlobalVariables {
            If (VarName = Item.Name && Item.Facet == "Builtin") {
                Builtin := True
                Break
            }
        }
    }

    If (Builtin) {
        Gui Variables: +OwnDialogs
        MsgBox 0x40010, Modify Variable, "%VarName%" is a READ-ONLY built-in variable.
        Return
    }

    WinGet ExStyle, ExStyle, ahk_id %hVarListWnd%

    NewValue := InputBoxEx("Modify Variable"
        , "Enter the new value for the variable """ . VarName . """:"
        , "Variables"
        , VarValue
        , ""
        , ""
        , hVarListWnd
        , "", ""
        , IconLib, 115
        , ExStyle & 0x8 ? "AlwaysOnTop" : "")

    If (!ErrorLevel) {
        NewValue := DBGp_Base64UTF8Encode(NewValue)
        g_DbgSession.property_set("-c " . Context . " -n " . VarName . " -- " . NewValue, Response)
        If (RegExMatch(Response, "success=""\K\d")) {
            GoSub VarListReload
            ; LV_Modify(_Row, "Vis Select")
            ; TO-DO: get/set ScrollInfo
        } Else {
            Gui Variables: +OwnDialogs
            MsgBox 0x10, Error, The value of the variable "%VarName%" could not be changed.
        }
    }
Return

VarListCopy:
    Gui Variables: Default
    GuiControlGet FocusedControl, Focus
    GuiControlGet SearchText,, Edit1
    If (FocusedControl == "Edit1" && SearchText != "") {
        Send ^C
    } Else {
        Row := 0, Output := ""
        While (Row := LV_GetNext(Row)) {
            LV_GetText(Name, Row)
            LV_GetText(Value, Row, 2)

            Output .= Name . "`t" . Value . "`n"
        }
        Clipboard := RTrim(Output, "`n")
    }
Return

VarListSelectAll:
    Gui Variables: Default
    GuiControlGet FocusedControl, Focus
    GuiControlGet SearchText,, Edit1
    If (FocusedControl == "Edit1" && SearchText != "") {
        Send ^A
    } Else {
        GuiControl Focus, %hLVVarList%
        LV_Modify(0, "Select")
    }
Return

SetVarListOption:
    If (InStr(A_ThisMenuItem, "Indexed")) {
        g_ShowIndexedVariables := !g_ShowIndexedVariables
    } Else If (InStr(A_ThisMenuItem, "Object")) {
        g_ShowObjectMembers := !g_ShowObjectMembers
    } Else If (InStr(A_ThisMenuItem, "Reserved")) {
        g_HideReservedClassMembers := !g_HideReservedClassMembers
    }

    GoSub DisplayVariables

    Menu VarShowMenu, ToggleCheck, %A_ThisMenuItem%
Return

SetVarListAlwaysOnTop:
    WinSet AlwaysOnTop, Toggle, ahk_id %hVarListWnd%
    Menu VarShowMenu, ToggleCheck, &Always on Top
Return

SetVarListReload:
    g_ReloadVarListOnEveryStep := !g_ReloadVarListOnEveryStep
    Menu VarReloadMenu, ToggleCheck, Reload on &Every Debug Step
Return

ShowStderr:
    Gui Stderr: New, +LabelStderr +hWndhWndStderr +Resize +AlwaysOnTop
    SetWindowIcon(hWndStderr, IconLib, 124)
    Gui Font, s10, Courier New
    Gui Add, ListView, hWndhLVStderr x8 y8 w569 h280 +LV0x10000, #|Time|Debug Print
    LV_ModifyCol(1, 36)
    LV_ModifyCol(2, 112)
    LV_ModifyCol(3, 396)
    SetExplorerTheme(hLVStderr)

    Gui Show, w586 h298, Standard Error Viewer
Return

StderrSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("wh", hLVStderr)
Return

StderrEscape:
StderrClose:
    Gui Stderr: Destroy
Return

ShowCallStack:
    Gui CallStack: New, +LabelCallStack +hWndhWndCallStack +Resize +AlwaysOnTop
    SetWindowIcon(hWndCallStack, IconLib, 123)
    Gui Font, s9, Segoe UI
    Gui Add, ListView, hWndhLVCallStack x7 y8 w571 h282 +LV0x14000, File|Line|Stack Entry
    LV_ModifyCol(1, 100)
    LV_ModifyCol(2, 45)
    LV_ModifyCol(3, "AutoHdr")
    SetExplorerTheme(hLVCallStack)

    Gui Show, w586 h298, Call Stack

    If (g_DbgStatus) {
        GoSub UpdateCallStack
    }
Return

CallStackSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("wh", hLVCallStack)
Return

CallStackEscape:
CallStackClose:
    Gui CallStack: Destroy
Return

UpdateCallStack:
    oFilename := g_DbgStack.selectNodes("/response/stack/@filename")
    oLineNo   := g_DbgStack.selectNodes("/response/stack/@lineno")
    oWhere    := g_DbgStack.selectNodes("/response/stack/@where")

    Gui CallStack: Default
    LV_Delete()

    Loop % oWhere.Length() {
        i := A_Index - 1

        Filename := DBGp_DecodeFileURI(oFilename.item[i].text)
        SplitPath Filename, ShortName

        LV_Add("", ShortName, oLineNo.item[i].text, oWhere.item[i].text)
    }
    LV_ModifyCol(3, "AutoHdr")
Return

; TO-DO
DebugRunToCursor:
    n := TabEx.GetSel()
    Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    URI := DBGp_EncodeFileURI(Sci[n].FullName)

    ; 'r': temporary
    g_DbgSession.breakpoint_set("-r 1 -t line -n " . (Line + 1) . " -f " . URI, Response)

    If (g_DbgStatus) {
        g_DbgSession.run()
    }
Return

IsFileOpened(FullName) {
    Loop % Sci.Length() {
        If (Sci[A_Index].FullName = FullName) {
            Return A_Index
        }
    }
    Return False
}

ToggleBreakpoint() {
    n := TabEx.GetSel()
    Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())

    If (Sci[n].MarkerGet(Line) & (1 << g_MarkerBreakpoint)) {
        Sci[n].MarkerDelete(Line, g_MarkerBreakpoint)
        RemoveBreakpoint(Sci[n].FullName, Line + 1)

    } Else {
        Sci[n].MarkerAdd(Line, g_MarkerBreakpoint)
        AddBreakpoint(Sci[n].FullName, Line + 1)
    }
}

DeleteBreakpoints() {
    Loop % Sci.Length() {
        Sci[A_Index].MarkerDeleteAll(g_MarkerBreakpoint)
    }

    Loop % g_Breakpoints.Length() {
        g_DbgSession.breakpoint_remove("-d " . g_Breakpoints[A_Index].ID)
    }
}

AddBreakpoint(File, Line) {
    If (g_DbgStatus) {
        URI := DBGp_EncodeFileURI(File)
        g_DbgSession.breakpoint_set("-t line -n " . Line . " -f " . URI, Response)

        If (RegExMatch(Response, " id=""\K\d+", ID)) {
            g_Breakpoints.Push({"File": File, "Line": Line, "ID": ID})
        }
    }
}

RemoveBreakpoint(File, Line) {
    If (g_DbgStatus) {
        Loop % g_Breakpoints.Length() {
            If (g_Breakpoints[A_Index].File == File && g_Breakpoints[A_Index].Line == Line) {
                g_DbgSession.breakpoint_remove("-d " . g_Breakpoints[A_Index].ID)
                Break
            }
        }
    }
}

; Define breakpoint markers as real breakpoints (called from DebuggerConnected)
DefineBreakpoints() {
    Line := 0
    Loop % Sci.Length() {
        i := A_Index

        If (Sci[i].FullName == "") {
            Continue
        }

        Loop {
            Line := Sci[i].MarkerNext(Line, (1 << g_MarkerBreakpoint)) + 1
            If (Line) {
                AddBreakpoint(Sci[i].FullName, Line)
            }
        } Until (!Line)
    }
}

RemoveStepMarker() {
    Loop % Sci.Length() {
        Sci[A_Index].MarkerDeleteAll(g_MarkerDebugStep)
    }
}

ShowDebugButtons(Show := 1) {
    Loop 5 {
        SendMessage 0x404, % A_Index + 2500, !Show,, ahk_id %hMainToolbar% ; TB_HIDEBUTTON
    }

    Try {
        If (Show) {
            Menu AutoDebugMenu, Rename, Start Debugging`tF5, Continue`tF5
        } Else {
            Menu AutoDebugMenu, Rename, Continue`tF5, Start Debugging`tF5
        }
    }
}

SetDebugPort() {
    Port := InputBoxEx("Debug Port"
        , "Specify the port to be used by the debugger (default: 9001):"
        , "Debug Settings"
        , g_DbgPort
        , ""
        , "Number"
        , hAutoWnd
        , "", ""
        , IconLib, 103)

    If (!ErrorLevel) {
        g_DbgPort := Port
    }
}

ShowAttachDialog:
    Gui Attach: New, +LabelAttach +hWndhWndAttachList
    SetWindowIcon(hWndAttachList, IconLib, 107)
    Gui Font, s9, Segoe UI
    Gui Color, White

    Gui Font, s12 cNavy
    Gui Add, Text, x8 y9 w259 h23 +0x200, List of Running Scripts
    Gui Font, s9 cNormal
    Gui Add, Text, x8 y32 w604 h23 +0x200
    , Attach the debugger to a running script. The script will not be terminated when the debug session ends.

    Gui Add, ListView, hWndhLVAttachList x0 y60 w620 h285 -Multi +LV0x14000, Filename|Path|PID
    LV_ModifyCol(1, 174)
    LV_ModifyCol(2, 387)
    LV_ModifyCol(3, "AutoHdr Integer Left")
    SetExplorerTheme(hLVAttachList)

    Gui Add, Text, x0 y346 w620 h48 -Background
    Gui Add, Button, x8 y357 w84 h24 gListRunningScripts, &Reload List
    Gui Add, Button, x433 y357 w84 h24 +Default gAttachDebugger, &Attach
    Gui Add, Button, x525 y357 w84 h24 gAttachClose, &Cancel

    GoSub ListRunningScripts

    Gui Show, w620 h393, Attach Debugger
Return

ListRunningScripts:
    Gui ListView, %hLVAttachList%
    LV_Delete()

    ; Get the list of running scripts (adapted from DebugVars)
    WinGet Scripts, List, ahk_class AutoHotkey
    Loop % Scripts {
        hWnd := Scripts%A_Index%
        If (hWnd == A_ScriptHwnd) {
            Continue
        }

        PostMessage 0x44, 0, 0,, ahk_id %hWnd% ; WM_COMMNOTIFY, WM_NULL
        If (ErrorLevel) { ; Likely blocked by UIPI (won't be able to attach).
            Continue
        }

        WinGetTitle Title, ahk_id %hwnd%
        Title := RegExReplace(Title, " - AutoHotkey v\S*$")
        SplitPath Title, Filename, Path
        WinGet PID, PID, ahk_id %hWnd%
        LV_Add("", Filename, Path, PID)
    }
Return

AttachEscape:
AttachClose:
    Gui Attach: Destroy
Return

AttachDebugger:
    Gui ListView, %hLVAttachList%
    Row := LV_GetNext()
    If (Row) {
        LV_GetText(Filename, Row, 1)
        LV_GetText(Path, Row, 2)
        LV_GetText(PID, Row, 3)
        GoSub AttachClose

        If (g_DbgStatus) {
            GoSub DebugStop
        }

        DebuggerInit()

        AttachMsg := DllCall("RegisterWindowMessage", "Str", "AHK_ATTACH_DEBUGGER")
        IP := DllCall("ws2_32\inet_addr", "AStr", "127.0.0.1")
        PostMessage %AttachMsg%, %IP%, %g_DbgPort%,, ahk_pid %PID% ahk_class AutoHotkey

        Filename := Path . "\" . Filename
        n := IsFileOpened(Filename)
        If (!n) {
            Open([Filename])
        }

        g_AttachDebugger := True
    }
Return
