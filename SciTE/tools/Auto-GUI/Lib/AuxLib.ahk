; Auxiliary function library.

; Window functions *****************************************************

GetWindowPlacement(hWnd) {
    Local WINDOWPLACEMENT, Result := {}
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
    Result.x := NumGet(WINDOWPLACEMENT, 28, "Int")
    Result.y := NumGet(WINDOWPLACEMENT, 32, "Int")
    Result.w := NumGet(WINDOWPLACEMENT, 36, "Int") - Result.x
    Result.h := NumGet(WINDOWPLACEMENT, 40, "Int") - Result.y
    Result.flags := NumGet(WINDOWPLACEMENT, 4, "UInt") ; 2 = WPF_RESTORETOMAXIMIZED
    Result.showCmd := NumGet(WINDOWPLACEMENT, 8, "UInt") ; 1 = normal, 2 = minimized, 3 = maximized
    Return Result
}

SetWindowPlacement(hWnd, x, y, w, h, showCmd) {
    Local WINDOWPLACEMENT
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    NumPut(x, WINDOWPLACEMENT, 28, "Int")
    NumPut(y, WINDOWPLACEMENT, 32, "Int")
    NumPut(w + x, WINDOWPLACEMENT, 36, "Int")
    NumPut(h + y, WINDOWPLACEMENT, 40, "Int")
    NumPut(showCmd, WINDOWPLACEMENT, 8, "UInt")
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
}

GetWindowInfo(hWnd) {
    Local WINDOWINFO, wi := {}
    NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO, 0, "UInt")
    DllCall("GetWindowInfo", "Ptr", hWnd, "Ptr", &WINDOWINFO)
    wi.WindowX := NumGet(WINDOWINFO, 4, "Int")
    wi.WindowY := NumGet(WINDOWINFO, 8, "Int")
    wi.WindowW := NumGet(WINDOWINFO, 12, "Int") - wi.WindowX
    wi.WindowH := NumGet(WINDOWINFO, 16, "Int") - wi.WindowY
    wi.ClientX := NumGet(WINDOWINFO, 20, "Int")
    wi.ClientY := NumGet(WINDOWINFO, 24, "Int")
    wi.ClientW := NumGet(WINDOWINFO, 28, "Int") - wi.ClientX
    wi.ClientH := NumGet(WINDOWINFO, 32, "Int") - wi.ClientY
    wi.Style   := NumGet(WINDOWINFO, 36, "UInt")
    wi.ExStyle := NumGet(WINDOWINFO, 40, "UInt")
    wi.Active  := NumGet(WINDOWINFO, 44, "UInt")
    wi.BorderW := NumGet(WINDOWINFO, 48, "UInt")
    wi.BorderH := NumGet(WINDOWINFO, 52, "UInt")
    ;wi.Atom    := NumGet(WINDOWINFO, 56, "UShort")
    ;wi.Version := NumGet(WINDOWINFO, 58, "UShort")
    Return wi
}

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    Local RECT
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "int")
    Height := NumGet(RECT, 12, "int")
}

SetWindowPos(hWnd, x, y, w, h, hWndInsertAfter := 0, uFlags := 0x40) { ; SWP_SHOWWINDOW
    Return DllCall("SetWindowPos", "Ptr", hWnd, "Ptr", hWndInsertAfter, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", uFlags)
}

IsWindow(hWnd) {
    Return DllCall("IsWindow", "Ptr", hWnd)
}

IsWindowVisible(hWnd) {
    Return DllCall("IsWindowVisible", "Ptr", hWnd)
}

ShowWindow(hWnd, nCmdShow := 1) {
    DllCall("ShowWindow", "Ptr", hWnd, "UInt", nCmdShow)
}

MoveWindow(hWnd, x, y, w, h, bRepaint) {
    DllCall("MoveWindow", "Ptr", hWnd, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", bRepaint)
}

GetActiveWindow() {
    Return DllCall("GetActiveWindow", "Ptr")
}

SetActiveWindow(hWnd) {
    Return DllCall("SetActiveWindow", "Ptr", hWnd)
}

DestroyWindow(hWnd) {
    Return DllCall("DestroyWindow", "Ptr", hWnd)
}

GetParent(hWnd) {
    Return DllCall("GetParent", "Ptr", hWnd, "Ptr")
}

; Flag: GA_PARENT = 1, GA_ROOT = 2, GA_ROOTOWNER = 3
GetAncestor(hWnd, Flag := 2) {
    Return DllCall("GetAncestor", "Ptr", hWnd, "UInt", Flag, "Ptr")
}

SetParent(hWndChild, hWndNewParent) {
    Return DllCall("SetParent", "Ptr", hWndChild, "Ptr", hWndNewParent)
}

GetFocus() {
    Return DllCall("GetFocus", "Ptr")
}

SetFocus(hWnd) {
    Return DllCall("SetFocus", "Ptr", hWnd)
}

SetWindowIcon(hWnd, Filename, Index := 1) {
    Local hIcon := LoadPicture(Filename, "w16 Icon" . Index, ErrorLevel)
    SendMessage 0x80, 0, hIcon,, ahk_id %hWnd% ; WM_SETICON
    Return ErrorLevel
}

; Menu functions *******************************************************

GetMenu(hWnd) {
    Return DllCall("GetMenu", "Ptr", hWnd, "Ptr")
}

GetSubMenu(hMenu, nPos) {
    Return DllCall("GetSubMenu", "Ptr", hMenu, "UInt", nPos, "Ptr")
}

GetMenuItemID(hMenu, nPos) {
    Return DllCall("GetMenuItemID", "Ptr", hMenu, "UInt", nPos)
}

GetMenuItemCount(hMenu) {
    Return DllCall("GetMenuItemCount", "Ptr", hMenu)
}

GetMenuString(ByRef OutputVar, hMenu, ItemPos) { ; Zero-based
    Local lpString
    OutputVar := ""

    VarSetCapacity(lpString, 4096, 0)
    If !(DllCall("GetMenuString", "Ptr", hMenu, "UInt", ItemPos, "Str", lpString, "UInt", 4096, "UInt", 0x400)) {
        Return (GetMenuItemID(hMenu, ItemPos) > -1) ? "SEPARATOR" : "ERROR"
    }

    OutputVar := lpString
    Return GetSubMenu(hMenu, ItemPos) ? "SUBMENU" : "MENUITEM"
}

CheckMenuRadioItem(hMenu, nPos, nFirst := 0, nLast := 0) {
    Return DllCall("CheckMenuRadioItem", "Ptr", hMenu, "UInt", nFirst , "UInt", nLast, "UInt", nPos, "UInt", 0x400)
}

DeleteMenu(hMenu, uPosition, uFlags := 0x400) { ; By position
    Return DllCall("DeleteMenu", "Ptr", hMenu, "UInt", uPosition, "UInt", uFlags)
}

; Misc functions *******************************************************

GetSysColor(nIndex) {
    Return DllCall("GetSysColor", "UInt", nIndex)
}

GetClassName(hWnd) {
    WinGetClass Class, ahk_id %hWnd%
    Return Class
}

ToHex(x) {
    Return Format("0x{:X}", x)
}

ToDec(x) {
    Return Format("{:d}", x)
}

RoundTo(Value, RoundTo) {
    Return Floor(Value/RoundTo) * RoundTo
}

GetFileIcon(File, SmallIcon := 1) {
    Static cbFileInfo := A_PtrSize + 688
    VarSetCapacity(SHFILEINFO, cbFileInfo, 0)
    ;If (DllCall("Shell32.dll\SHGetFileInfoW"
    If (DllCall(g_GetFileInfo
        , "WStr", File
        , "UInt", 0
        , "Ptr" , &SHFILEINFO
        , "UInt", cbFileInfo
        , "UInt", 0x100 | SmallIcon)) { ; SHGFI_ICON
        Return NumGet(SHFILEINFO, 0, "Ptr")
    }
}

CvtClr(Color) {
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16)
}

Edit_ShowBalloonTip(hEdit, Text, Title := "", Icon := 0) {
    Local EDITBALLOONTIP
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(&Title, EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(&Text, EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

; Unsigned int to int (0xFFFFFFFF = -1)
Int(x) {
    Return x << 32 >> 32
}

LoadImage(File, Width, Height, Type, Flags := 0x10) {
    Return DllCall("LoadImage", "Int", 0
    , "Str", File
    , "Int", Type ; 0 = bitmap, 1 = icon, 2 = cursor
    , "Int", Width, "Int", Height
    , "UInt", Flags, "Ptr") ; 0x10 = LR_LOADFROMFILE
}

SetExplorerTheme(hWnd) {
    Return DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "WStr", "Explorer", "Ptr", 0)
}

LV_GetItemIcon(hLV, Row) {
    Local LVITEM
    VarSetCapacity(LVITEM, A_PtrSize == 8 ? 88 : 60, 0)
    NumPut(0x2, LVITEM, 0, "UInt") ; mask (LVIF_IMAGE)
    NumPut(Row - 1, LVITEM, 4, "Int") ; iItem
    SendMessage 0x104B, 0, &LVITEM,, ahk_id %hLV% ; LVM_GETITEMW
    Return NumGet(LVITEM, A_PtrSize == 8 ? 36 : 28, "Int") + 1
}

GetErrorMessage(ErrorCode, LanguageId := 0) {
    Local Size, ErrorBuf, ErrorMsg

    Size := DllCall("Kernel32.dll\FormatMessageW"
        ; FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "UInt", 0x1300
        , "Ptr",  0
        , "UInt", ErrorCode + 0
        , "UInt", LanguageId
        , "Ptr*", ErrorBuf
        , "UInt", 0
        , "Ptr",  0)

    If (!Size) {
        Return ""
    }

    ErrorMsg := StrGet(ErrorBuf, Size, "UTF-16")
    DllCall("Kernel32.dll\LocalFree", "Ptr", ErrorBuf)

    Return ErrorMsg
}

ErrorMsgBox(Message, Window := 1, Title := "Error") {
    Gui %Window%: +OwnDialogs
    MsgBox 0x10, %Title%, %Message%
}

DPIScale(x) {
    Return (x * A_ScreenDPI) // 96
}

IsAhkFileExt(FileExt) {
    Return FileExt ~= "i)^ah((k?h?)(2|h|s)?)$"
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

GetFileExt(FullPath) {
    Local FileExt
    SplitPath FullPath,,, FileExt
    Return FileExt
}

PathAddExt(FullPath, Ext) {
    Local FileExt
    SplitPath FullPath,,, FileExt
    If (FileExt == "" && !FileExist(FullPath . "." . Ext)) {
        Return FullPath . "." . Ext
    }
    Return FullPath
}

GetMousePos(ByRef X, ByRef Y, Origin := "Screen") {
    Local OldCoordMode := A_CoordModeMouse
    CoordMode Mouse, %Origin%
    MouseGetPos X, Y
    CoordMode Mouse, %OldCoordMode%
}

LoadXML(Fullpath) {
    Local x := ComObjCreate("MSXML2.DOMDocument.6.0")
    x.async := False
    x.load(Fullpath)
    Return x
}

LoadXMLData(ByRef Data) {
    Local x := ComObjCreate("MSXML2.DOMDocument.6.0")
    x.async := False
    x.loadXML(Data)
    Return x
}

LoadXMLEx(ByRef oXML, Fullpath) {
    oXML := ComObjCreate("MSXML2.DOMDocument.6.0")
    oXML.async := False

    If (!oXML.load(Fullpath)) {
        MsgBox 0x10, Error, % "Failed to load XML file."
        . "`n`nFilename: """ . Fullpath . """"
        . "`n`nError: " . Format("0x{:X}", oXML.parseError.errorCode & 0xFFFFFFFF)
        . "`n`nReason: " . oXML.parseError.reason
        Return 0
    }

    Return 1
}

RunEx(Target, WorkingDir := "", Options := "", ByRef PID := 0, Window := 1) {
    Run %Target%, %WorkingDir%, %Options%|UseErrorLevel, %PID%
    If (ErrorLevel) {
        ErrorMsgBox(GetErrorMessage(A_LastError), Window)
    }
}

GetFullPath(FilePath) {
    Loop Files, %FilePath%, FD
    {
        FilePath := A_LoopFileLongPath
        Break
    }

    Return FilePath
}

; Alternative: SplitPath FilePath,,,,, Drive
IsPathRelative(FilePath) {
    Return DllCall("Shlwapi.dll\PathIsRelativeW", "WStr", FilePath, "UInt")    
}

/*
StrPutVar(String, ByRef Var, Encoding) {
    VarSetCapacity(Var, StrPut(String, Encoding)
    * ((Encoding = "UTF-16" || Encoding = "CP1200") ? 2 : 1), 0)
    Return StrPut(String, &Var, Encoding)
}
*/

MessageBox(hWnd := 0, Text := "", Title := "", Flags := 0) {
    Return DllCall("MessageBox", "Ptr", hWnd, "Str", Text, "Str", Title, "UInt", Flags, "UInt")
}

SoftModalMessageBox(Text, Title, Buttons, DefBtn := 1, Options := 0x1, IconRes := "", IconID := 1, Timeout := -1, Owner := 0, Callback := "") {
    Local hModule, LoadLib, cButtons, ButtonIDs, ButtonText, b1, b2, b3, b4, x64, Offsets, MBCONFIG, ProcAddr, Ret

    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("kernel32.dll\LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2, "Ptr")
        Options |= 0x80 ; MB_USERICON
    } Else {
        hModule := 0
        LoadLib := False
    }

    cButtons := Buttons.Length()
    VarSetCapacity(ButtonIDs, cButtons * A_PtrSize, 0)
    VarSetCapacity(ButtonText, cButtons * A_PtrSize, 0)
    Loop %cButtons% {
        NumPut(Buttons[A_Index][1], ButtonIDs, 4 * (A_Index - 1), "UInt")
        NumPut(&(b%A_Index% := Buttons[A_Index][2]), ButtonText, A_PtrSize * (A_Index - 1), "Ptr")
    }

    If (Callback != "") {
        Callback := RegisterCallback(Callback, "F")
    }

    x64 := A_PtrSize == 8
    Offsets := (A_Is64BitOS) ? (x64 ? [96, 104, 112, 116, 120, 124] : [52, 56, 60, 64, 68, 72]) : [48, 52, 56, 60, 64, 68]

    ; MSGBOXPARAMS and MSGBOXDATA structures
    NumPut(VarSetCapacity(MBCONFIG, (x64) ? 136 : 76, 0), MBCONFIG, 0, "UInt")
    NumPut(Owner,    MBCONFIG, 1 * A_PtrSize, "Ptr")  ; Owner window
    NumPut(hModule,  MBCONFIG, 2 * A_PtrSize, "Ptr")  ; Icon resource
    NumPut(&Text,    MBCONFIG, 3 * A_PtrSize, "Ptr")  ; Message
    NumPut(&Title,   MBCONFIG, 4 * A_PtrSize, "Ptr")  ; Window title
    NumPut(Options,  MBCONFIG, 5 * A_PtrSize, "UInt") ; Options
    NumPut(IconID,   MBCONFIG, 6 * A_PtrSize, "Ptr")  ; Icon resource ID
    NumPut(Callback, MBCONFIG, 8 * A_PtrSize, "Ptr")  ; Callback
    NumPut(&ButtonIDs,  MBCONFIG, Offsets[1], "Ptr")  ; Button IDs
    NumPut(&ButtonText, MBCONFIG, Offsets[2], "Ptr")  ; Button texts
    NumPut(cButtons,    MBCONFIG, Offsets[3], "UInt") ; Number of buttons
    NumPut(DefBtn - 1,  MBCONFIG, Offsets[4], "UInt") ; Default button
    NumPut(1,           MBCONFIG, Offsets[5], "UInt") ; Allow cancellation
    NumPut(Timeout,     MBCONFIG, Offsets[6], "Int")  ; Timeout (ms)

    ProcAddr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "User32.dll", "Ptr"), "AStr", "SoftModalMessageBox", "Ptr")
    Ret := DllCall(ProcAddr, "Ptr", &MBCONFIG)

    If (LoadLib) {
        DllCall("FreeLibrary", "Ptr", hModule)
    }

    If (Callback != "") {
        DllCall("GlobalFree", "Ptr", Callback)
    }

    Return Ret
}

InputBoxEx(Instruction := "", Content := "", Title := "", DefText := "", CtlType := "", CtlOpts := "", Owner := "", Width := "", Pos := "", Icon := "", IconIndex := 1, WndOpts := "", Callback := "") {
    Local hWnd, hCtl, py, c, cy, ch, oFunc, e, ey, eh, f, ww, ExitCode
    Static p1, p2, Input

    Gui New, hWndhWnd LabelInputBoxEx -0xA0000
    Gui % (Owner) ? "+Owner" . Owner : ""
    Gui Font
    Gui Color, White
    Gui Margin, 10, 12
    py := 10
    Width := (Width) ? Width : 430

    If (Instruction != "") {
        Gui Font, s12 c0x003399, Segoe UI
        Gui Add, Text, vp1 y10, %Instruction%
        py := 40
    }

    Gui Font, s9 cDefault, Segoe UI

    If (Content != "") {
        Gui Add, Link, % "vp2 x10 y" . py . " w" . (Width - 20), %Content%
    }

    GuiControlGet c, Pos, % (Content != "") ? "p2" : "p1"
    py := (Instruction != "" || Content !="") ? (cy + ch + 16) : 22
    Gui Add, % (CtlType != "") ? CtlType : "Edit"
    , % "hWndhCtl vInput x10 y" . py . " w" . (Width - 20) . "h21 " . CtlOpts, %DefText%
    If (Callback != "") {
        oFunc := Func(Callback).Bind(hCtl)
        GuiControl +g, %hCtl%, %oFunc%
    }

    GuiControlGet e, Pos, Input
    py := ey + eh + 20
    Gui Add, Text, hWndf y%py% -Background +Border ; Footer

    Gui Add, Button, % "gInputBoxExOK x" . (Width - 176) . " yp+12 w80 h23 Default", &OK
    Gui Add, Button, % "gInputBoxExClose xp+86 yp w80 h23", &Cancel

    Gui Show, % "w" . Width . " " . Pos, %Title%
    Gui +SysMenu %WndOpts%
    If (Icon != "") {
        hIcon := LoadPicture(Icon, "Icon" . IconIndex, ErrorLevel)
        SendMessage 0x80, 0, hIcon,, ahk_id %hWnd% ; WM_SETICON
    }

    WinGetPos,,, ww,, ahk_id %hWnd%
    GuiControl MoveDraw, %f%, % "x-1 " . " w" . ww . " h" . 48

    If (Owner) {
        WinSet Disable,, ahk_id %Owner%
    }

    GuiControl Focus, Input
    Gui Font

    WinWaitClose ahk_id %hWnd%
    ErrorLevel := ExitCode
    Return Input

    InputBoxExESCAPE:
    InputBoxExCLOSE:
    InputBoxExOK:
        If (Owner) {
            WinSet Enable,, ahk_id %Owner%
        }

        Gui %hWnd%: Submit
        ExitCode := (A_ThisLabel != "InputBoxExOK")
        Gui %hWnd%: Destroy
    Return
}

GetProcAddress(Dll, FuncName) {
    Local hMod := DllCall("GetModuleHandle", "Str", Dll, "Ptr")
    If (!hMod) {
        DllCall("kernel32.dll\LoadLibrary", "Str", Dll, "Ptr")
    }

    Return DllCall("GetProcAddress", "Ptr", hMod, "AStr", FuncName, "Ptr")
}

SelectFileEx(ByRef OutputVar, Save := 0, Flags := 0, hWnd := 0, Title := "", StartPath := "", Filters := "", FilterIndex := 1, DefExt := "", Callback := "") {
    Local WD, FileBuf, nMaxFile := 65535, StrInitialDir, lpStrTitle, lpStrDefExt, lpfnHook, sFilters := ""
    , Desc, Mask,lpStrFilter, i, Byte, OFN, x64 := A_PtrSize == 8, FuncName, BaseDir, RelFiles, Addr, RelFile

    WD := A_WorkingDir
    Flags |= 0x80000 ; Explorer

    VarSetCapacity(FileBuf, nMaxFile, 0)

    If (InStr(FileExist(StartPath), "D")) {
        StartPath := RTrim(StartPath, "\") ; Root?
        VarSetCapacity(StrInitialDir, (StrPut(StartPath, "UTF-16") + 1) * 2, 0)
        StrPut(StartPath, &StrInitialDir, "UTF-16")
    } Else If (StartPath != "") {
        StrPut(StartPath, &FileBuf, "UTF-16")
    }

    lpStrTitle := Title != "" ? &Title : 0

    lpStrDefExt := DefExt != "" ? &DefExt : 0

    lpfnHook := (Flags & 0x20 && Callback != "") ? RegisterCallback(Callback, "F") : 0 ; OFN_ENABLEHOOK

    ; Filters
    Loop Parse, Filters, |
    {
        Desc := A_LoopField
        Mask := SubStr(Desc, InStr(Desc, "(") + 1, -1)
        sFilters .= Desc . "|" . Mask . "|"
    }
    ; A buffer containing pairs of null-terminated filter strings
    VarSetCapacity(lpStrFilter, StrPut(sFilters, "UTF-16") * 2, 0)
    i := -1
    Loop Parse, sFilters
    {
        Byte := A_LoopField == "|" ? 0 : Asc(A_LoopField)
        NumPut(Byte, lpStrFilter, ++i << 1, "UShort")
    }

    ; OPENFILENAMEW
    NumPut(VarSetCapacity(OFN, x64 ? 152 : 88, 0), OFN, 0, "UInt") ; lStructSize
    NumPut(hWnd, OFN, x64 ? 8 : 4, "Ptr")               ; hwndOwner
    NumPut(&lpStrFilter, OFN, x64 ? 24 : 12, "Ptr")     ; lpstrFilter
    NumPut(FilterIndex, OFN, x64 ? 44 : 24, "UInt")     ; nFilterIndex
    NumPut(&FileBuf, OFN, x64 ? 48 : 28, "Ptr")         ; lpstrFile
    NumPut(nMaxFile, OFN, x64 ? 56 : 32, "UInt")        ; nMaxFile
    NumPut(&StrInitialDir, OFN, x64 ? 80 : 44, "Ptr")   ; lpstrInitialDir
    NumPut(lpStrTitle, OFN, x64 ? 88 : 48, "Ptr")       ; lpstrTitle
    NumPut(Flags, OFN, x64 ? 96 : 52, "UInt")           ; Flags
    NumPut(lpStrDefExt, OFN, x64 ? 104 : 60, "Ptr")     ; lpstrDefExt
    NumPut(lpfnHook, OFN, x64 ? 120 : 68, "Ptr")        ; lpfnHook

    FuncName := Save ? "GetSaveFileNameW" : "GetOpenFileNameW"
    If (!DllCall("Comdlg32.dll\" . FuncName, "Ptr", &OFN)) {
        Return 0
    }

    SetWorkingDir %WD% ; The working directory is changed as a side-effect

    BaseDir := OutputVar := StrGet(&FileBuf, "UTF-16")

    If (Flags & 0x200) { ; OFN_ALLOWMULTISELECT
        RelFiles := ""
        Addr := &FileBuf
        Addr += (StrPut(BaseDir, "UTF-16")) * 2 ; Initial offset

        If (SubStr(BaseDir, 0) != "\") {
            BaseDir .= "\" ; Only root dirs end with a backslash
        }

        Loop {
            RelFile := StrGet(Addr, "UTF-16")
            If (!StrLen(RelFile)) {
                Break
            } Else {
                RelFiles .= BaseDir . RelFile . "`n"
                Addr += (StrPut(RelFile, "UTF-16")) * 2
            }
        }

        If (RelFiles != "") {
            OutputVar := RTrim(RelFiles, "`n")
        }
    }

    Return 1
}

; Get the path of the executable associated to a specific file type in the registry.
FindExecutable(Filename, WorkingDir := "", ByRef ErrorMsg := "") {
    Local Executable, RetVal

    VarSetCapacity(Executable, 4096, 0)
    RetVal := DllCall("Shell32.dll\FindExecutable", "Str", Filename, "Str", WorkingDir, "Str", Executable)
    If (RetVal > 32) {
        Return Executable
    }

    If (RetVal == 31) {
        ErrorMsg := "There is no association for the specified file type with an executable file."
    } Else {
        ErrorMsg := GetErrorMessage(RetVal)
    }

    Return "", ErrorLevel := RetVal
}

IndexOf(aArray, Value) {
    Loop % aArray.Length() {
        If (aArray[A_Index] = Value) {
            Return A_Index
        }
    }
    Return False
}

ReverseArray(aArray) {
    Local aTemp := [], Max := aArray.Length(), Index

    Loop % Max {
        Index := Max - A_Index + 1
        aTemp[A_Index] := aArray[Index]
    }

    Return aTemp
}

ToggleMenuItem(MenuName, MenuItem) {
    Try {
        Menu %MenuName%, ToggleCheck, %MenuItem%
    }
}

UpdateMenuItemState(MenuName, MenuItem, Enable) {
    Try {
        Menu %MenuName%, % Enable ? "Enable" : "Disable", %MenuItem%
    }
}

CheckMenuItem(MenuName, MenuItem, bCheck := True) {
    Try {
        Menu %MenuName%, % bCheck ? "Check" : "Uncheck", %MenuItem%
    }
}

EnableSubMenu(MenuName, MenuItemString, SubMenu) {
    Try {
        Menu %MenuName%, Add, %MenuItemString%, :%SubMenu%
        Menu %MenuName%, Enable, %MenuItemString%
    }
}

SetMenuColor(MenuName, Color) {
    Try {
        Menu %MenuName%, Color, %Color%
    }
}

LV_ModifyColEx(Cols*) {
    Local Index, Col
    For Index, Col in Cols {
        LV_ModifyCol(Index, Col)
    }
}

IL_AddEx(hIL, IconRes, Indexes*) {
    Local Each, Index
    For Each, Index in Indexes {
        IL_Add(hIL, IconRes, Index)
    }
}

SetListView(GuiID, LvID) {
    Gui %GuiID%: Default
    Gui ListView, %LvID%
}

SetFont(FontName, FontOptions) {
    Gui Font
    Gui Font, %FontOptions%, %FontName%
}

ResetFont() {
    Gui Font
    Gui Font, s9, Segoe UI
}
