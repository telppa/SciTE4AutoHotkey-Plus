; Window Cloning Tool (based on a SmartGUI functionality)

ShowCloneDialog:
    WCT_Title := "Window Cloning Tool"
    Gui CloneDlg: New, LabelCloneDlg hWndhCloneDlg AlwaysOnTop
    SetWindowIcon(hCloneDlg, A_ScriptDir . "\Icons\WCT.ico")

    Gui Add, TreeView, x-1 y-1 w484 h48
    Gui Add, Picture, x8 y8 w32 h32, %A_ScriptDir%\Icons\WCT.ico
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x52 y10 w421 h23 +0x200 BackgroundTrans, Activate the target window and click the "Clone" button
    Gui Font

    Gui Font, s9, Segoe UI
    Gui Add, ListView, hWndhLVWinList x10 y57 w374 h242 -Hdr, hWnd|Title
    SetExplorerTheme(hLVWinList)
    LV_ModifyCol(1, 0)
    LV_ModifyCol(2, "AutoHdr")

    Gui Add, Button, gActivateWindow x393 y57 w80 h25 Default, &Activate
    Gui Add, Button, gCloneWindow x393 y90 w80 h25, Cl&one
    Gui Add, Button, gCloneDlgClose x393 y123 w80 h25, &Cancel

    Gui Add, CheckBox, vIncludeMenu x12 y306 w100 h23 Checked, Include menu
    Gui Add, CheckBox, vIncludeStyles x122 y306 w220 h23, Include styles for all controls in output

    Gui Add, StatusBar,, Notice: This tool does not retrieve variables and named styles associated with the controls.
    Gui Show, w482 h360, %WCT_Title%

    GoSub UpdateList
    SetTimer UpdateList, 1500
Return

CloneWindow:
    If (A_GuiControl == "Cl&one") {
        LV_GetText(hWnd, LV_GetNext())
        WinActivate % "ahk_id " . hWnd
    }

    Gui CloneDlg: Submit
    WinGet hTargetWnd, ID, A
    Gosub NewGUI

    If (IncludeMenu) {
        If (hMenu := GetMenu(hTargetWnd)) {
            CloneMenuItems(hMenu, "", "")
            Gui %Child%: Menu, MenuBar
            m.Code .= "Gui Menu, MenuBar" . CRLF
        }
    }

    wi := GetWindowInfo(hTargetWnd)
    ncLeftWidth := wi.ClientX - wi.WindowX
    ncTopHeight := wi.ClientY - wi.WindowY

    WinGet WindowStyle, Style, ahk_id %hTargetWnd%
    if (WindowStyle & 0x40000) { ; WS_SIZEBOX
        g.Window.Options := "+Resize"
    }

;************************************************************************

    WinGet ControlList, ControlListHWnd, ahk_id %hTargetWnd%
    If (ControlList == "") {
        ; MozillaWindowClass, QWidget, etc.
        Gui Auto: +OwnDialogs
        Msgbox 0x30, Window Cloning Tool, % GetClassName(hTargetWnd) . ": unable to clone the window."
        ;Return
    }

    Try {
        Acc_Init()
    }

    hPrevCtrl := 0, PrevAhkName := ""
    Loop Parse, ControlList, `n
    {
        If !(IsWindowVisible(A_LoopField)) {
            Continue
        }

        ClassName := GetClassName(A_LoopField)
        If ((ClassName == "SysHeader32") || (ClassName == "Edit" && PrevAhkName == "ComboBox")) {
            Continue
        }

        ControlGetText ControlText,, ahk_id %A_LoopField%
        ControlGetPos x, y, w, h,, ahk_id %A_LoopField%
        x := x - ncLeftWidth
        y := y - ncTopHeight
        ControlGet ControlStyle, Style,,, ahk_id %A_LoopField%
        ControlGet ControlExStyle, ExStyle,,, ahk_id %A_LoopField%
        ControlType := ControlStyle & 0xF
        Options := ""

        AhkName := TranslateClassName(ClassName)
        If (AhkName == "") {
            Try {
                AhkName := WeHaveToGoDeeper(A_LoopField)
            }
            If (AhkName == "") {
                Continue
            }
        }

        If (ClassName = "Button") {
            ; 1: BS_DEFPUSHBUTTON
            ; 2: BS_CHECKBOX
            ; 3: BS_AUTOCHECK
            ; 4: BS_RADIOBUTTON
            ; 5: BS_3STATE
            ; 6: BS_AUTO3STATE
            ; 9: BS_AUTORADIOBUTTON
            If (ControlType == 1) {
                AhkName := "Button"
                Options .= " +Default"
            } Else If ControlType in 2,3,5,6
                AhkName := "CheckBox"
            Else If ControlType in 4,9
                AhkName := "Radio"
            Else If (ControlType == 7)
                AhkName := "GroupBox"
            Else
                AhkName := "Button"
            ControlGet Checked, Checked,,, ahk_id %A_LoopField%
            If (Checked) {
                Options .= " +Checked"
            }
        } Else If (ClassName == "ComboBox") {
            If (ControlType = 3) {
                AhkName := "DropDownList"
            } Else {
                AhkName := "ComboBox"
            }
        } Else If (ClassName == "Edit") {
            If (ControlType = 4) {
                Options .= " +Multi"
            }
            If ((ControlStyle & 0xF00) == 0x800) {
                Options .= " +ReadOnly"
            }
        } Else If (ClassName == "Static") {
            If (ControlType = 1) {
                Options .= " +Center"
            } Else If (ControlType == 2) {
                Options .= " +Right"
            } Else If (ControlType == 3 || ControlType == 14) {
                ; 3:  SS_ICON
                ; 14: SS_BITMAP
                AhkName := "Picture"
                Options .= " 0x6 +Border" ; SS_WHITERECT
            }
            If (ControlText == "" && h == 2) {
                Options .= " 0x10" ; Separator
            }
        } Else If (AhkName == "Slider") {
            SendMessage 0x400, 0, 0,, ahk_id %A_LoopField% ; TBM_GETPOS
            ControlText := ErrorLEvel
            SendMessage 0x401, 0, 0,, ahk_id %A_LoopField% ; TBM_GETRANGEMIN
            Options .= " Range" . ErrorLevel
            SendMessage 0x402, 0, 0,, ahk_id %A_LoopField% ; TBM_GETRANGEMAX
            Options .= "-" . ErrorLevel
            ; 2:  TBS_VERT
            ; 4:  TBS_TOP
            ; 8:  TBS_BOTH (blunt)
            ; 10: TBS_NOTICKS
            If (ControlType == 2) {
                Options .= " +Vertical"
            } Else If (ControlType == 4) {
                Options .= " +Left"
            } Else If (ControlType == 8) {
                Options .= " +Center"
            } Else If (ControlType == 10) {
                Options .= " +NoTicks"
            }
        } Else If (AhkName == "TreeView") {
            ControlText := ""
        } Else If (AhkName == "UpDown") {
            Options .= " -16"
        } Else If (AhkName == "Tab2") {
            TabLabels := ControlGetTabs(A_LoopField)
            nTabs := TabLabels.Length()
            Loop % nTabs {
                ControlText .= TabLabels[A_Index] . ((A_Index != nTabs) ? "|" : "")
            }
        } Else If (AhkName == "Progress") {
            SendMessage 0x408, 0, 0,, ahk_id %A_LoopField% ; PBM_GETPOS
            ControlText := ErrorLEvel
            Smooth := ControlStyle & 0x1
            If (!Smooth) {
                Options .= " -Smooth"
            }
            If (ControlType == 4) {
                Options .= " +Vertical"
            }
        } Else If (AhkName == "Link" && !InStr(ControlText, "<a")) {
            ControlText := "<a>" . ControlText . "</a>"
        }

        If (ClassName ~= "ComboBox|ListBox") {
            ControlGet Items, List,,, ahk_id %A_LoopField%
            StringReplace ControlText, Items, `n, |, All
        }

        ControlGet Enabled, Enabled,,, ahk_id %A_LoopField%
        If (!Enabled) {
            Options .= " +Disabled"
        }

        Styles := IncludeStyles ? ToHex(ControlStyle) : ""

        Gui %Child%: Add, %AhkName%, hWndhWnd x%x% y%y% w%w% h%h% %Options% %Styles%, %ControlText%

        If (AhkName == "TreeView") {
            Gui %Child%: Default
            Parent := TV_Add("TreeView")
            TV_Add("Child", Parent)
        }

        ;Register(hWnd, Type, ClassNN, Text,,,, Options, Extra, Styles, FontName, FontOptions, Anchor, TabPos)
        Register(hWnd, AhkName, GetClassNN(hWnd), EscapeChars(ControlText),,,, LTrim(Options),, Styles)
        g.ControlList.Push(hWnd)

        PrevAhkName := AhkName
        hPrevCtrl := hWnd
    }

;************************************************************************

    Properties_Reload()

    SysGet cxFrame, 32 ; Border width/height (8)
    WinGetPos wx, wy, ww, wh, ahk_id %hTargetWnd%
    If (ncLeftWidth != cxFrame) {
        ww := ww + ((cxFrame - ncLeftWidth) * 2)
        wh := wh + ((cxFrame - ncLeftWidth) * 2)
    }
    WinMove ahk_id %hChildWnd%,, %wX%, %wY%, %wW%, %wH%
    WinActivate ahk_id %hChildWnd%

    WinGetTitle WinTitle, ahk_id %hTargetWnd%
    g.Window.Title := WinTitle . " (Clone)"
    WinSetTitle ahk_id %hChildWnd%,, % g.Window.Title

    GenerateCode()
Return

CloneMenuItems(hMenu, Prefix, ByRef Commands) {
    ItemCount := GetMenuItemCount(hMenu)
    Loop %ItemCount% {
        ItemString := GetMenuString(hMenu, A_Index - 1)
        ItemID := GetMenuItemID(hMenu, A_Index - 1)
        If (ItemID = -1) { ; Submenu
            hSubMenu := GetSubMenu(hMenu, A_Index - 1)
            If (hSubMenu) {
                OldItemString := ItemString
                ItemString := RegExReplace(ItemString, "[\W]")
                CloneMenuItems(hSubMenu, Prefix . ItemString . "Menu", Commands)
                MenuName := (Prefix = "") ? "MenuBar" : Prefix
                Menu, %MenuName%, Add, %OldItemString%, % ":" . Prefix . ItemString . "Menu"
                Commands .= "Menu " . MenuName . ", Add, " . OldItemString . ", :"  . Prefix . ItemString . "Menu" . CRLF
                Continue
            }
        }

        If (Prefix != "") {
            If (ItemString = "SEPARATOR") {
                Menu, %Prefix%, Add
                Commands .= "Menu " . Prefix . ", Add" . CRLF
            } Else {
                Menu, %Prefix%, Add, %ItemString%, MenuHandler
                ItemString := EscapeChars(ItemString)
                StringReplace ItemString, ItemString, `,, ```,, A
                Commands .= "Menu " . prefix . ", Add, " . ItemString . ", MenuHandler" . CRLF
            }
        }
    }

    m.Code .= Commands
}

ActivateWindow:
    Gui CloneDlg: Submit, NoHide
    LV_GetText(SelectedItem, LV_GetNext())
    WinActivate ahk_id %SelectedItem%
Return

CloneDlgEscape:
CloneDlgClose:
    SetTimer UpdateList, Off
    Gui CloneDlg: Destroy
Return

UpdateList:
    DetectHiddenWindows Off

    Gui CloneDlg: Default
    LV_GetText(SelectedItem, LV_GetNext())
    LV_Delete()

    WinGet WinList, List,,, Program Manager
    Loop %WinList% {
        hWnd := WinList%A_Index%
        WinGetClass wClass, ahk_id %hWnd%
        WinGetTitle wTitle, ahk_id %hWnd%
        If (wClass == "Shell_TrayWnd"
        ||  wClass == "Button"
        ||  wTitle == WCT_Title
        ||  hWnd   == hAutoWnd
        ||  hWnd   == hChildWnd
        ||  wTitle == "") {
            Continue
        }
        LV_Add("", hWnd, wTitle)
    }

    LV_ModifyCol(2, "AutoHdr")

    Loop % LV_GetCount() {
        LV_GetText(Item, A_Index)
        If (Item == SelectedItem) {
            LV_Modify(A_Index, "Select")
        }
    }

    DetectHiddenWindows On
Return

TranslateClassName(ClassName) {
    AhkName := ""
    If (InStr(ClassName, "static")) {
        AhkName := "Text"
    } Else If (InStr(ClassName, "button")) {
        AhkName := "Button"
    } Else If (InStr(ClassName, "edit")) {
        AhkName := "Edit"
    } Else If (InStr(ClassName, "checkbox")) {
        AhkName := "CheckBox"
    } Else If (InStr(ClassName, "group")) {
        AhkName := "GroupBox"
    } Else If (InStr(ClassName, "radio")) {
        AhkName := "Radio"
    } Else If (InStr(ClassName, "combobox")) {
        AhkName := "ComboBox"
    } Else If (InStr(ClassName, "listview")) {
        AhkName := "ListView"
    } Else If (InStr(ClassName, "listbox")) {
        AhkName := "ListBox"
    } Else If (InStr(ClassName, "tree")) {
        AhkName := "TreeView"
    } Else If (InStr(ClassName, "status")) {
        AhkName := "StatusBar"
    } Else If (InStr(ClassName, "tab")) {
        AhkName := "Tab2"
    } Else If (InStr(ClassName, "updown")) {
        AhkName := "UpDown"
    } Else If (InStr(ClassName, "hotkey")) {
        AhkName := "Hotkey"
    } Else If (InStr(ClassName, "progress")) {
        AhkName := "Progress"
    } Else If (InStr(ClassName, "trackbar")) {
        AhkName := "Slider"
    } Else If (InStr(ClassName, "datetime")) {
        AhkName := "DateTime"
    } Else If (InStr(ClassName, "month")) {
        AhkName := "MonthCal"
    } Else If (InStr(ClassName, "link")) {
        AhkName := "Link"
    } Else If (InStr(ClassName, "richedit")) {
        AhkName := "Edit"
    } Else If (InStr(ClassName, "scintilla")) {
        AhkName := "Edit"
    } Else If (InStr(ClassName, "memo")) {
        AhkName := "Edit"
    } Else If (InStr(ClassName, "btn")) {
        AhkName := "Button"
    }
    Return AhkName
}

ControlGetTabs(Control, WinTitle = "", WinText = "") { ; Written by Lexicos
    static TCM_GETITEMCOUNT := 0x1304
         , TCM_GETITEM := A_IsUnicode ? 0x133C : 0x1305
         , TCIF_TEXT := 1
         , MAX_TEXT_LENGTH := 260
         , MAX_TEXT_SIZE := MAX_TEXT_LENGTH * (A_IsUnicode ? 2 : 1)

    static PROCESS_VM_OPERATION := 0x8
         , PROCESS_VM_READ := 0x10
         , PROCESS_VM_WRITE := 0x20
         , READ_WRITE_ACCESS := PROCESS_VM_READ |PROCESS_VM_WRITE |PROCESS_VM_OPERATION
         , PROCESS_QUERY_INFORMATION := 0x400
         , MEM_COMMIT := 0x1000
         , MEM_RELEASE := 0x8000
         , PAGE_READWRITE := 4

    if Control is not integer
    {
        ControlGet Control, Hwnd,, %Control%, %WinTitle%, %WinText%
        if ErrorLevel
            return
    }

    WinGet pid, PID, ahk_id %Control%

    ; Open the process for read/write and query info.
    hproc := DllCall("OpenProcess", "uint", READ_WRITE_ACCESS |PROCESS_QUERY_INFORMATION
                   , "int", false, "uint", pid, "ptr")
    if !hproc
        return

    ; Should we use the 32-bit struct or the 64-bit struct?
    if A_Is64bitOS
        try DllCall("IsWow64Process", "ptr", hproc, "int*", is32bit := true)
    else
        is32bit := true
    RPtrSize := is32bit ? 4 : 8
    TCITEM_SIZE := 16 + RPtrSize*3

    ; Allocate a buffer in the (presumably) remote process.
    remote_item := DllCall("VirtualAllocEx", "ptr", hproc, "ptr", 0
                         , "uptr", TCITEM_SIZE + MAX_TEXT_SIZE
                         , "uint", MEM_COMMIT, "uint", PAGE_READWRITE, "ptr")
    remote_text := remote_item + TCITEM_SIZE

    ; Prepare the TCITEM structure locally.
    VarSetCapacity(local_item, TCITEM_SIZE, 0)
    NumPut(TCIF_TEXT,       local_item, 0, "uint")
    NumPut(remote_text,     local_item, 8 + RPtrSize)
    NumPut(MAX_TEXT_LENGTH, local_item, 8 + RPtrSize*2, "int")

    ; Prepare the local text buffer.
    VarSetCapacity(local_text, MAX_TEXT_SIZE)

    ; Write the local structure into the remote buffer.
    DllCall("WriteProcessMemory", "ptr", hproc, "ptr", remote_item
          , "ptr", &local_item, "uptr", TCITEM_SIZE, "ptr", 0)

    tabs := []

    SendMessage TCM_GETITEMCOUNT,,,, ahk_id %Control%
    Loop % (ErrorLevel != "FAIL") ? ErrorLevel : 0
    {
        ; Retrieve the item text.
        SendMessage TCM_GETITEM, A_Index-1, remote_item,, ahk_id %Control%
        if (ErrorLevel = 1) ; Success
            DllCall("ReadProcessMemory", "ptr", hproc, "ptr", remote_text
                  , "ptr", &local_text, "uptr", MAX_TEXT_SIZE, "ptr", 0)
        else
            local_text := ""

        ; Store the value even on failure:
        tabs[A_Index] := local_text
    }

    ; Release the remote memory and handle.
    DllCall("VirtualFreeEx", "ptr", hproc, "ptr", remote_item
          , "uptr", 0, "uint", MEM_RELEASE)
    DllCall("CloseHandle", "ptr", hproc)

    return tabs
}

; Some MSAA functions from the Acc library
Acc_Init() {
    Static hMod := 0
    If !(hMod) {
        hMod := DllCall("LoadLibrary", "Str", "oleacc.dll", "Ptr")
    }
}

Acc_ObjectFromWindow(hWnd, idObject := 0) {
    o := DllCall("oleacc\AccessibleObjectFromWindow"
    , "Ptr", hWnd
    , "UInt", idObject &= 0xFFFFFFFF
    , "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64")
    , "Ptr*", pacc)
    If (o = 0) {
        Return ComObjEnwrap(9,pacc,1)
    }
}

Acc_WindowFromObject(pacc) {
    hwnd := 0
    If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
    Return hWnd
}

Acc_GetRoleText(nRole) {
    nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
    VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
    DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
    Return sRole
}

Acc_Role(Acc, ChildId := 0) {
    Try Return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}

Acc_Children(Acc) {
    Local child
    cChildren := Acc.accChildCount
    Children := []
    if DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0, "Int", cChildren, "Ptr", VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*", cChildren) = 0 {
    Loop %cChildren%
    i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=3?child:Acc_Query(child)), ObjRelease(child)
    Return Children
    }
}

Acc_Query(Acc) {
    Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

WeHaveToGoDeeper(hWnd) {
    AhkName := ""

    Acc := Acc_ObjectFromWindow(hWnd, 0)
    Role := Acc_Role(Acc_children(Acc)[4], 0)

    If (InStr(Role, "group")) {
        AhkName := "GroupBox"
    } Else If (InStr(Role, "spin")) {
        AhkName := "UpDown"
    } Else If (InStr(Role, "link")) {
        AhkName := "Link"
    } Else {
        OutputDebug % "WCT: unsupported/unrecognized class: " . GetClassName(hWnd) . " (MSAA role: " . Role . ")"
    }

    Return AhkName
}
