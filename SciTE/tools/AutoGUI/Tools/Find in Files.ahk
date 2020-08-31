; Find in Files v1.0.1

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetBatchLines -1
DetectHiddenWindows On
SetWorkingDir %A_ScriptDir%

Global hMainWnd
, IniFile
, Stop := True
, hCbxDir
, hCbxMask
, hCbxFind
, MaxHistory
, SingleMatch
, Thousand
, Ascending := False
, ParamDir := ""
, ParamMask := ""
, ParamFind := ""
, Start := False
, AutoGUI := False
, AutoGUIPath := A_ScriptDir . "\..\AutoGUI.ahk"
, AutoGUIData
, Includes
, hEdit
, VScrollBarW
, hQuickViewWnd
, hBtnMenu
, NT6orLater := DllCall("GetVersion") & 0xFF > 5
, IconLib := A_ScriptDir . "\..\Icons\AutoGUI.icl"
, FocusText := False
, hShellWnd := CreateShellMenuWindow()
, g_pIContextMenu
, g_pIContextMenu2
, g_pIContextMenu3

Loop %0% {
    Param := %A_Index%
    If (InStr(Param, "/dir:")) {
        ParamDir := StrReplace(Param, "/dir:")
    } Else If (InStr(Param, "/mask:")) {
        ParamMask := StrReplace(Param, "/mask:")
    } Else If (InStr(Param, "/find:")) {
        ParamFind := StrReplace(Param, "/find:",,, 1)
    } Else If (InStr(Param, "/start")) {
        Start := True
    } Else If (InStr(Param, "/AutoGUI")) {
        AutoGUI := True
    } Else If (Param == "/sm") {
        FocusText := True
    }
}

If (FileExist(A_AppData . "\AutoGUI\Find in Files.ini")) {
    IniFile := A_AppData . "\AutoGUI\Find in Files.ini"
} Else {
    IniFile := A_ScriptDir . "\Find in Files.ini"
}

IniRead SingleMatch, %IniFile%, Options, SingleMatch, 1
IniRead MaxHistory, %IniFile%, Options, MaxHistory, 15

DirHistory  := GetHistory("DirHistory")
If (DirHistory == "") {
    DirHistory := A_MyDocuments . "||"
}
MaskHistory := GetHistory("MaskHistory")
FindHistory := GetHistory("FindHistory", 0)

Menu Tray, Icon, %IconLib%, 23

Gui 1: New, +hWndhMainWnd +Resize -DPIScale, Find in Files
Gui Font, s9, Segoe UI

Gui Add, Edit, hWndhEdit x0 y0 w0 h0 ; For initial focus and IPC

IniRead InitialX, %IniFile%, Position, x
IniRead InitialY, %IniFile%, Position, y
IniRead InitialW, %IniFile%, Position, w
IniRead InitialH, %IniFile%, Position, h
IniRead ShowState, %IniFile%, Position, Show, 1

If (FileExist(IniFile)) {
    SetWindowPlacement(hMainWnd, InitialX, InitialY, InitialW, InitialH, 0)
} Else {
    Gui Show, y100 w794 h484 Hide, Find in Files
}

GetClientSize(hMainWnd, GuiWidth, GuiHeight)

w := GuiWidth - 8 - 6 - 84 - 6
Gui Add, Tab3, hWndhTab x8 y8 w%w% h220, Search

cw := GuiWidth - 111 - 8 - 80 - 14 - 6 - 84 - 6
Gui Add, Text, x22 y47 w86 h23 +0x200, Directory:
Gui Add, ComboBox, hWndhCbxDir vDirectory x111 y47 w%cw%, %DirHistory%

x := GuiWidth - 12 - 84 - 80 - 14
If (NT6orLater) {
    Gui Add, Button, hWndhBtnBrowse gBrowse x%x% y46 w80 h24, &Browse...
} Else {
    Gui Add, Button, hWndhBtnBrowse gBrowse x%x% y46 w23 h24, ...
    Gui Add, Button, hWndhBtnMenu gShowMenu xp+28 y46 w52 h24, Menu
    If (!AutoGUI) {
        GuiControl +Disabled, %hBtnMenu%
    }
}

Gui Add, Text, x22 y88 w86 h23 +0x200, Filters:
Gui Add, ComboBox, hWndhCbxMask vFilters x111 y88 w%cw%, %MaskHistory%

sw := GuiWidth - 22 - 14 - 6 - 84 - 6
Gui Add, Text, hWndhSep1 x22 y120 w%sw% h2 +0x10

Gui Add, Text, x22 y130 w86 h23 +0x200, Find Text:
Gui Add, ComboBox, hWndhCbxFind vTextToFind x111 y130 w%cw%, %FindHistory%

Gui Add, Text, hWndhSep2 x22 y162 w%sw% h2 +0x10

Gui Add, CheckBox, vChkRecurse x22 y171 w160 h23 +Checked, &Search subdirectories
Gui Add, CheckBox, vChkSingleMatch x22 y194 w160 h23 +Checked%SingleMatch%, &One match per file
Gui Add, CheckBox, vChkMatchCase gSetExclusivity x190 y171 w160 h23, &Case sensitive
Gui Add, CheckBox, vChkWholeWords gSetExclusivity x190 y194 w160 h23, &Match whole words
Gui Add, CheckBox, vChkRegEx gSetExclusivity x358 y171 w160 h23, &Regular Expression
Gui Add, CheckBox, vChkBackslashes gSetExclusivity x358 y194 w160 h23, Convert &backslashes
Gui Add, CheckBox, vChkNotContaining x526 y171 w160 h23, &Not containing the text
Gui Add, CheckBox, vChkHexSearch gSetExclusivity x526 y194 w160 h23, &Hexadecimal search

Gui Tab

x := GuiWidth - 84 - 6
Gui Add, Button, hWndhBtnStart gStartSearch x%x% y7 w84 h24 +Default, Start
Gui Add, Button, hWndhBtnCancel gCancelSearch x%x% y38 w84 h24, Cancel
Gui Add, Button, hWndhBtnHelp gShowHelp x%x% y69 w84 h24, Help

Gui Add, StatusBar, vStatusBar
GuiControlGet sb, Pos, msctls_statusbar321

w := GuiWidth - 16
h := GuiHeight - 235 - 8 - sbH
Gui Add, ListView, hWndhLVSearchResults vLV gLVHandler x8 y235 w%w% h%h% +LV0x14000 -Multi
, Filename|Size|Date modified
LV_ModifyCol(1, 455)
LV_ModifyCol(2, 70)
LV_SetCol3Width(hLVSearchResults)

If (AutoGUI) {
    Menu SplitButtonMenu, Add, Current Directory, MenuHandler
    Menu SplitButtonMenu, Add, Current File, MenuHandler
    Menu SplitButtonMenu, Add, Current File and its Includes, MenuHandler
    Menu SplitButtonMenu, Add, All Open Files, MenuHandler
    If (NT6orLater) {
        SplitButton(hBtnBrowse, 16, "SplitButtonMenu", hMainWnd)
    }
}

ShowWindow(hMainWnd, ShowState)
WinActivate ahk_id %hMainWnd%

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLVSearchResults, "WStr", "Explorer", "Ptr", 0)

DllCall("Shlwapi.dll\SHAutoComplete", "Ptr", GetChild(hCbxDir), "UInt", 0)

RegRead Thousand, HKEY_CURRENT_USER\Control Panel\International, sThousand

OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x232, "OnWM_EXITSIZEMOVE")
OnMessage(10000, "CustomMessage")
OnMessage(0x16,  "SaveSettings") ; WM_ENDSESSION

SysGet VScrollBarW, 2 ; SM_CXVSCROLL

If (ParamDir != "") {
    GuiControl Text, %hCbxDir%, %ParamDir%
}

If (ParamMask != "") {
    GuiControl Text, %hCbxMask%, %ParamMask%
}

If (ParamFind != "") {
    GuiControl Text, %hCbxFind%, %ParamFind%
}

If (FocusText) {
    GUiControl Focus, %hCbxFind%
}

If (Start) {
    GoSub StartSearch
}
Return

GuiSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("w",  hTab)
    AutoXYWH("w*", hCbxDir, hCbxMask, hCbxFind)
    AutoXYWH("xt*", hBtnBrowse, hBtnMenu)
    AutoXYWH("w",  hSep1, hSep2)
    AutoXYWH("x",  hBtnStart, hBtnCancel, hBtnHelp)
    AutoXYWH("wh", hLVSearchResults)

    KillSelection()

    LV_SetCol3Width(hLVSearchResults)
Return

GuiEscape:
    If (!Stop) {
        Stop := True
        Return
    }

GuiClose:
    DllCall("DestroyWindow", "Ptr", hShellWnd)
    SaveSettings()
    ExitApp

StartSearch:
    Gui Submit, NoHide

    If (Directory == "") {
        hCbxEdit := GetChild(hCbxDir)
        Edit_ShowBalloonTip(hCbxEdit, "Directory cannot be empty")
        Return
    }

    LV_Delete()
    SB_SetText("")

    ; For case sensitivity in the ComboBox
    GuiControlGet TextToFind,, %hCbxFind%, Text

    AddToHistory(hCbxDir,  Directory)
    AddToHistory(hCbxMask, Filters)
    AddToHistory(hCbxFind, TextToFind)
    KillSelection()

    SimpleMask := True

    If (Filters == "" || Filters == "*") {
        Filters := "*.*"
    }

    If (InStr(Filters, ";") || !RegExMatch(Filters, "^.*\.(\w+|\*)$")) { ; "\*\.(\w+|\*)$"
        Filters := StrReplace(Filters, ".", "\.")
        Filters := StrReplace(Filters, "*", ".*")
        Filters := StrReplace(Filters, "?", ".")

        Masks := StrSplit(Filters, ";", " ")
        SimpleMask := False
    }

    If (ChkWholeWords) {
        ChkRegEx := True
        TextToFind := "\b" . TextToFind . "\b"
        If (!ChkMatchCase) {
            TextToFind := "i)" . TextToFind
        }
    }

    If (ChkBackslashes) {
        ConvertBackslashes(TextToFind)
    }

    Containing := !ChkNotContaining

    If (ChkHexSearch && Containing) {
        arr := StrSplit(TextToFind, " ")
        Loop % arr.Length() {
            arr[A_Index] := "0x" . arr[A_Index]
        }

        LV_ModifyCol(2, "Integer", "Pos")
        LV_ModifyCol(3,, "Data")
        LV_ModifyCol(1, 328)
        LV_ModifyCol(2, 39)
        LV_SetCol3Width(hLVSearchResults, True)

    } Else If (TextToFind != "" && Containing) {
        LV_ModifyCol(2, "Integer", "Line")
        LV_ModifyCol(3,, "Line Text")
        LV_ModifyCol(1, 328)
        LV_ModifyCol(2, 39)
        LV_SetCol3Width(hLVSearchResults, True)

    } Else {
        LV_ModifyCol(2, "Integer", "Size")
        LV_ModifyCol(3,, "Date modified")
        LV_ModifyCol(1, 455)
        LV_ModifyCol(2, 70)
        LV_SetCol3Width(hLVSearchResults, True)
    }

    MatchCount := 0
    FileCount  := 0
    Stop := False

    Directories := StrSplit(Directory, ";", " ")

    For Each, Dir in Directories {
        If (Stop) {
            Break
        }

        Dir := RTrim(Dir, "\")

        If (InStr(FileExist(Dir), "D", 1)) {
            If (SimpleMask) {
                LoopMask := "\" . Filters
            } Else {
                LoopMask := "\*.*"
            }
        } Else {
            LoopMask := ""
        }

        Loop Files, %Dir%%LoopMask%, % ChkRecurse ? "R" : ""
        {
            If (Stop) {
                Break 2
            }

            If (!SimpleMask) {
                If (!RegExMatchArray(A_LoopFileName, Masks)) {
                    Continue
                }
            }

            SB_SetText(" Searching: " . A_LoopFileFullPath)

            If (TextToFind != "") {
                f := FileOpen(A_LoopFileFullPath, "r")

                Found := False

                If (ChkHexSearch) {
                    Matching := False
                    f.Pos := 0
                    i := 1

                    While(!f.AtEoF) {
                        If (Stop) {
                            Break 3
                        }

                        ch := f.ReadUChar()

                        If (arr[i] == ch) {
                            i++
                            Matching := True
                        } Else {
                            i := 1
                            Matching := False
                        }

                        If (i > arr.Length() && Matching) {
                            Found := True

                            If (Containing) {
                                OldPos := f.Pos
                                Pos := A_Index - arr.Length()
                                ChunkPos := (Pos // 16) * 16
                                f.Seek(ChunkPos)
                                f.RawRead(Chunk, 16)
                                f.Seek(ChunkPos)
                                HexData := ""
                                Loop 16 {
                                    UChar := NumGet(Chunk, A_Index - 1, "UChar")
                                    HexData .= Format("{:02X}", UChar) . " "
                                }
                                f.Pos := OldPos

                                LV_Add("", A_LoopFileFullPath, Pos, HexData)
                                MatchCount++
                            }
                        }

                        If (ChkSingleMatch && Found) {
                            Break
                        }
                    }
                }

                Else If (ChkBackslashes) {
                    InitPos := f.Tell() ; BOM

                    FileRead Data, %A_LoopFileFullPath%
                    Data := StrReplace(Data, "`r`n", "`n") ; Replace CRLF with LF

                    StartingPos := 1
                    CRLFCount := 0
                    Line := 0
                    SameLine := False
                    While (FoundPos := InStr(Data, TextToFind, ChkMatchCase, StartingPos)) {
                        If (Stop) {
                            Break 3
                        }

                        FoundPos := FoundPos + InitPos

                        Found := True

                        If (ChkNotContaining) {
                            Break
                        }

                        While (!f.AtEoF) {
                            If (Stop) {
                                Break 4
                            }

                            Pos1 := f.Tell() ; Current pos

                            TextLine := f.ReadLine()

                            If (!SameLine) {
                                Line++

                                LineEnding := SubStr(TextLine, -1, 2)
                                If (LineEnding == "`r`n") {
                                    CRLFCount++ ; Compensate the replacement of CRLF
                                }
                            }

                            Pos2 := f.Tell() ; Position after ReadLine
                            If (Pos2 >= FoundPos + CRLFCount) {
                                LV_Add("", A_LoopFileFullPath, Line, TextLine)
                                MatchCount++

                                f.Seek(Pos1)
                                SameLine := True

                                If (ChkSingleMatch) {
                                    Break 2 ; Breaks 2 while loops
                                } Else {
                                    StartingPos := FoundPos + 1
                                    Break
                                }
                            } Else {
                                SameLine := False
                            }

                            StartingPos := FoundPos + 1
                        }
                    }
                }

                Else {
                    While (!f.AtEoF) {
                        If (Stop) {
                            Break 3
                        }

                        TextLine := f.ReadLine()

                        If (ChkRegEx) {
                            If (RegExMatch(TextLine, TextToFind)) {
                                Found := True
                                If (Containing) {
                                    LV_Add("", A_LoopFileFullPath, A_Index, TextLine)
                                    MatchCount++
                                }
                            }
                        } Else {
                            If (InStr(TextLine, TextToFind, ChkMatchCase)) {
                                Found := True
                                If (Containing) {
                                    LV_Add("", A_LoopFileFullPath, A_Index, TextLine)
                                    MatchCount++
                                }
                            }
                        }

                        If (ChkSingleMatch && Found) {
                            Break
                        }
                    } ; End while
                }

                f.Close()

                If (ChkNotContaining && !Found) {
                    LV_Add2(A_LoopFileFullPath, A_LoopFileSize, A_LoopFileTimeModified)
                    FileCount++
                } Else If (Found && Containing) {
                    FileCount++
                }

            } Else { ; No text to find
                LV_Add2(A_LoopFileFullPath, A_LoopFileSize, A_LoopFileTimeModified)
                FileCount++
            }
        } ; End loop files
    } ; End for loop

    SB_Text := Stop ? " Search aborted. " : " Search finished. "
    If (TextToFind != "") {
        Files := FileCount > 1 ? "files" : "file"
        If (MatchCount) {
            Matches := MatchCount > 1 ? "matches" : "match"
            SB_Text .= MatchCount . " " . Matches . " in " . FileCount . " " . Files . "."
        } Else {
            If (ChkNotContaining && FileCount) {
                SB_Text .= "No match found in " . FileCount . " " . Files . "."
            } Else {
                SB_Text .= "No match found."
            }
        }
    } Else {
        If (FileCount == 1) {
            SB_Text .= "1 file found."
        } Else If (FileCount > 1){
            SB_Text .= FileCount . " files found."
        } Else {
            SB_Text .= "No files found."
        }
    }

    SB_SetText(SB_Text, 1)

    LV_SetCol3Width(hLVSearchResults)

    GuiControl Focus, %hLVSearchResults%

    Stop := True
Return

CancelSearch:
    If (Stop) {
        GoSub GuiClose
    }

    Stop := True
Return

FormatDate(DateTime) {
    FormatTime DateTime, %DateTime% D1
    Return RegExReplace(DateTime, "(.*)\s(.*)", "$2 $1")
}

LV_Add2(FilePath, FileSize, FileTime) {
    LV_Add("", FilePath, FormatBytes(FileSize, Thousand), FormatDate(FileTime))
}

ShowHelp:
    Try {
        Run %A_ScriptDir%\..\Help\Find in Files.htm
    }
Return

Browse:
    GuiControlGet Dir,, Directory
    SplitPath Dir,, StartingFolder
    Gui +OwnDialogs
    FileSelectFolder SelectedFolder, *%StartingFolder%,, Select Folder
    If (!ErrorLevel) {
        GuiControl, Text, Directory, %SelectedFolder%
    }
Return

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
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "ptr", &WINDOWPLACEMENT)
}

SaveSettings() {
    If (!FileExist(IniFile)) {
        Sections := "[Options]`n`n[Position]`n`n[DirHistory]`n`n[MaskHistory]`n`n[FindHistory]`n"
        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %A_AppData%\AutoGUI
            IniFile := A_AppData . "\AutoGUI\Find in Files.ini"
            FileDelete %IniFile%
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }

    IniWrite %MaxHistory%, %IniFile%, Options, MaxHistory

    GuiControlGet SingleMatch,, ChkSingleMatch
    IniWrite %SingleMatch%, %IniFile%, Options, SingleMatch

    Pos := GetWindowPlacement(hMainWnd)
    IniWrite % Pos.x, %IniFile%, Position, x
    IniWrite % Pos.y, %IniFile%, Position, y
    IniWrite % Pos.w, %IniFile%, Position, w
    IniWrite % Pos.h, %IniFile%, Position, h
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %IniFile%, Position, Show

    SaveHistory(hCbxDir,  "DirHistory")
    SaveHistory(hCbxMask, "MaskHistory")
    SaveHistory(hCbxFind, "FindHistory")
}

SaveHistory(hCbx, Section) {
    Items := ""
    ControlGet History, List,,, ahk_id %hCbx%
    If (History != "") {
        Loop Parse, History, `n
        {
            Items .= A_Index . "=" . A_LoopField . "`n"
        }
    }

    If (Items != "") {
        IniWrite %Items%, %IniFile%, %Section%
    }
}

GetHistory(Section, DefaultItem := True) {
    Items := ""
    Loop % MaxHistory {
        IniRead History, %IniFile%, %Section%, %A_Index%
        If (History != "ERROR") {
            Items .= History . (A_Index == 1 && DefaultItem ? "||" : "|")
        }
    }
    Return Items
}

AddToHistory(hCbx, String) {
    If (String == "") {
        Return
    }

    ControlGet ComboItems, List,,, ahk_id %hCbx%
    ComboItems := StrReplace(ComboItems, "`n", "|")

    History := String . "||"

    Counter := 0
    Loop Parse, ComboItems, |
    {
        If (A_LoopField == String || A_LoopField == "") {
            Continue
        }

        History .= A_LoopField . "|"

        Counter++
        If (Counter > (MaxHistory - 2)) {
            Break
        }
    }

    GuiControl,, %hCbx%, |%History%
}

FormatBytes(n, sThousand := ".") {
/*
    If (n > 999) {
        n /= 1024
        Unit := " K"
    } Else {
        Unit := " B"
    }
*/
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

RegExMatchArray(Haystack, arrNeedle) {
    Loop % arrNeedle.Length() {
        If (RegExMatch(Haystack, "i)^" . arrNeedle[A_Index] . "$")) {
            Return True
        }
    }
    Return False
}

GuiContextMenu:
    If (A_GuiControl == "LV" && Row := LV_GetNext()) {
        LV_GetText(FullPath, Row, 1)
        If (!FileExist(FullPath)) {
            Return
        }

        SplitPath FullPath,, WorkingDir
        FixRootDir(WorkingDir)

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

LVHandler:
    If (A_GuiEvent == "DoubleClick") {
        Row := LV_GetNext()
        If (Row) {
            LV_GetText(Filename, Row, 1)
            SplitPath Filename,,, Ext

            If (Ext = "AHK" || Ext = "TXT") {
                If (TextToFind != "") {
                    LV_GetText(Line, Row, 2)
                } Else {
                    Line := 1
                }

                GuiControl,, %hEdit%, %Filename%|%Line%|%TextToFind%

                OpenWithAutoGUI()
            }
        }
    }
    Else If (A_GuiEvent == "ColClick" && A_EventInfo == 2) {
        ShowThousandSeparator(False)
        LV_ModifyCol(2, "Sort" . (Ascending ? " SortDesc" : ""))
        ShowThousandSeparator(True)
        Ascending := !Ascending
    }
Return

OpenWithAutoGUI() {
    SendMessage 10000, 1, %hEdit%,, % "ahk_id " . GetAutoGUIHandle(AutoGUIPath)
}

ShowThousandSeparator(Show := 1) {
    If (Show) {
        Loop % LV_GetCount() {
            LV_GetText(Size, A_Index, 2)
            LV_Modify(A_Index,,, FormatBytes(Size, Thousand))
        }
    } Else {
        Loop % LV_GetCount() {
            LV_GetText(Size, A_Index, 2)
            LV_Modify(A_Index,,, StrReplace(Size, Thousand))
        }
    }
}

; http://ahkscript.org/boards/viewtopic.php?t=1079
AutoXYWH(DimSize, cList*) {
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

            If (InStr(DimSize, "t")) {
                GuiControlGet hWnd, %A_Gui%: hWnd, %ctrl%
                hParentWnd := DllCall("GetParent", "Ptr", hWnd, "Ptr")
                VarSetCapacity(RECT, 16, 0)
                DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", &RECT)
                DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", &RECT, "UInt", 1)
                ix := ix - NumGet(RECT, 0, "Int")
                iy := iy - NumGet(RECT, 4, "Int")
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

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "int")
    Height := NumGet(RECT, 12, "int")
}

ShowWindow(hWnd, nCmdShow := 1) {
    DllCall("ShowWindow", "Ptr", hWnd, "UInt", nCmdShow)
}

GetChild(hWnd) {
    Return DllCall("GetWindow", "Ptr", hWnd, "UInt", 5, "Ptr") ; GW_CHILD
}

Edit_ShowBalloonTip(hEdit, Text, Title := "", Icon := 0) {
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(A_IsUnicode ? &Title : WStr(Title, _), EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(A_IsUnicode ? &Text : WStr(Text, _), EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

WStr(ByRef AStr, ByRef WStr) {
    Size := StrPut(AStr, "UTF-16")
    VarSetCapacity(WStr, Size * 2, 0)
    StrPut(ASTr, &WStr, "UTF-16")
    Return &Wstr
}

ConvertBackslashes(ByRef String) {
    StringReplace String, String, \\, ☺, All
    StringReplace String, String, \n, `n, All
    ;StringReplace String, String, \r, `r, All
    StringReplace String, String, \t, %A_Tab%, All
    StringReplace String, String, ☺, \, All
}

SetExclusivity() {
    Options := {}
    Options.ChkRegEx := ["ChkMatchCase", "ChkWholeWords", "ChkBackslashes", "ChkHexSearch"]
    Options.ChkMatchCase := ["ChkRegEx", "ChkHexSearch"]
    Options.ChkWholeWords := ["ChkRegEx", "ChkHexSearch", "ChkBackslashes"]
    Options.ChkBackslashes := ["ChkRegEx", "ChkWholeWords", "ChkHexSearch"]
    Options.ChkHexSearch := ["ChkRegEx", "ChkMatchCase", "ChkWholeWords", "ChkBackslashes"]

    For Each, Item in Options[A_GuiControl] {
        GuiControl,, %Item%, 0
    }
}

OnWM_EXITSIZEMOVE() {
    KillSelection()
}

; EM_SETSEL to remove the automatic selection in combo boxes
KillSelection() {
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(hCbxDir)
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(hCbxMask)
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(hCbxFind)
}

TrackPopupMenu(Menu, hCtl, hWnd, Flags := 0x8) {
    ; 0x8 = TPM_TOPALIGN | TPM_RIGHTALIGN
    WingetPos wx, wy, ww, wh, ahk_id %hWnd%
    ControlGetPos cx, cy, cw, ch,, ahk_id %hCtl%
    x := wx + cx + cw
    y := wy + cy + ch
    hMenu := MenuGetHandle(Menu)
    DllCall("TrackPopupMenu", "Ptr", hMenu, "UInt", Flags, "Int", x, "Int", y, "Int", 0, "Ptr", hWnd, "Ptr", 0)
}

; Credits to gwarble, https://autohotkey.com/boards/viewtopic.php?f=6&t=22830
SplitButton(hButton, GlyphSize := 16, Menu := "", hWnd := 0) {
    Static _ := OnMessage(0x4E, "SplitButton") ; WM_NOTIFY
    Static _hWnd := hWnd
    Static _hButton
    Static _Menu := "SplitButton_Menu"

    If (Menu == 0x4E) {
        hCtrl := NumGet(GlyphSize+0, 0, "Ptr") ;-> lParam -> NMHDR -> hCtrl
        If (hCtrl == _hButton) { ; BCN_DROPDOWN for SplitButton
            id := NumGet(GlyphSize+0, A_PtrSize * 2, "uInt")
            If (id == 0xFFFFFB20) {
                TrackPopupMenu(_Menu, _hButton, _hWnd)
            }
        }
    } Else { ; Initialize
        If (Menu != "") {
            _Menu := Menu
        }

        _hWnd := hWnd
        _hButton := hButton
        Winset Style, +0xC, ahk_id %hButton% ; BS_SPLITBUTTON
        VarSetCapacity(BUTTON_SPLITINFO, A_PtrSize == 8 ? 32 : 20, 0)
        NumPut(8, BUTTON_SPLITINFO, 0, "Int") ; mask (BCSIF_SIZE)
        NumPut(GlyphSize, BUTTON_SPLITINFO, 4 + A_PtrSize * 2, "Int") ; size
        SendMessage 0x1607, 0, &BUTTON_SPLITINFO,, ahk_id %hButton% ; BCM_SETSPLITINFO
        Return
    }
}

MenuHandler:
    ; AutoGUI message: request list of open files
    SendMessage 10000, 2, %hMainWnd%,, % "ahk_id " . GetAutoGUIHandle(AutoGUIPath)

    Loop 10 {
        If (AutoGUIData == "") {
            Sleep 10
        }
    }

    If (AutoGUIData == "") {
        Return
    }

    CurrentFile := StrSplit(AutoGUIData, ";")[1]

    Item := A_ThisMenuItemPos

    If (Item == 1) { ; Current directory
        SplitPath CurrentFile,, CurrentDir
        GuiControl Text, Directory, %CurrentDir%

    } Else If (Item == 2) { ; Current file
        GuiControl Text, Directory, %CurrentFile%

    } Else If (Item == 3) { ; Includes
        Includes := ""
        Try {
            EnumIncludes(CurrentFile, Func("EnumIncludesCallback"))
        }

        If (Includes != "") {
            GuiControl Text, Directory, % CurrentFile . ";" . Includes
        }
    } Else { ; All open files
        GuiControl Text, Directory, %AutoGUIData%
    }
Return

EnumIncludesCallback(Param) {
    Includes .= Param . ";"
    Return True ; must return true to continue enumeration
}

GetAutoGUIHandle(AutoGUIPath) {
    If (!hWnd := WinExist("AutoGUI v")) {
        Try {
            Run %AutoGUIPath%,,, AutoGUIPID
        } Catch e {
            MsgBox 0x10, Error %A_LastError%, % e.Message . "`n`n" . e.Extra
            Return
        }

        WinWaitActive ahk_pid %AutoGUIPID%,, 3
        If (ErrorLevel) {
            MsgBox 0x15, Error, Window activation timed out. Try again?
            IfMsgBox Retry, {
                GetAutoGUIHandle(AutoGUIPath)
            }
            Return
        } Else {
            WinGet hWnd, ID, ahk_pid %AutoGUIPID%
        }
    }

    Return hWnd
}

CustomMessage(wParam, lParam) {
    If (wParam == 2) { ; Message sent by AutoGUI
        ControlGetText AutoGUIData,, ahk_id %lParam%
        ControlSetText,,, ahk_id %lParam%
    }
}

; For XP
ShowMenu() {
    TrackPopupMenu("SplitButtonMenu", hBtnMenu, hMainWnd)
}

LV_SetCol3Width(hLV, GapForVScroll := False) {
    GetClientSize(hLV, LVW, LVH)
    Col3W := LVW - LV_GetColWidth(hLV, 1) - LV_GetColWidth(hLV, 2)

    ControlGet Style, Style,, ahk_id %hLV%
    If ((Style & 0x100000) || GapForVScroll) { ; WS_HSCROLL
        Col3W := Col3W - VScrollBarW
    }

    LV_ModifyCol(3, Col3W)
}

LV_GetColWidth(hLV, ColN) {
    SendMessage 0x101F, 0, 0,, ahk_id %hLV% ; LVM_GETHEADER
    hHeader := ErrorLevel

    cbHDITEM := (4 * 6) + (A_PtrSize * 6)
    VarSetCapacity(HDITEM, cbHDITEM, 0)
    NumPut(0x1, HDITEM, 0, "UInt") ; mask (HDI_WIDTH)
    SendMessage, % A_IsUnicode ? 0x120B : 0x1203, ColN - 1, &HDITEM,, ahk_id %hHeader% ; HDM_GETITEMW
    Return (ErrorLevel != "FAIL") ? NumGet(HDITEM, 4, "UInt") : 0
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    If (wParam == 0x70) { ; F1
        GoSub ShowHelp
    } Else If (wParam == 0x72) { ; F3
        GoSub QuickView
    }
}

QuickView:
    Data := ""
    Row := LV_GetNext()
    If (Row) {
        LV_GetText(Filename, Row, 1)
        If (FileExist(Filename)) {
            FileRead Data, %Filename%
        }
    }

    If (!WinExist("ahk_id" . hQuickViewWnd)) {
        BGColor := 0x1F609F
        FGColor := 0xFFFFFF

        Gui QuickView: New, +LabelQuickView +hWndhQuickViewWnd +Resize
        hIcon := LoadPicture(IconLib, "Icon24 w16", ErrorLevel)
        SendMessage 0x80, 0, hIcon,, ahk_id %hQuickViewWnd% ; WM_SETICON
        Gui Add, CheckBox, x0 y0 w0 h0
        Gui Font, s9, FixedSys
        Gui Color, %BGColor%
        Gui Add, Edit, hWndhEdtView x8 y0 w830 h530 -E0x200, %Data%
        ControlColor(hEdtView, hQuickViewWnd, BGColor, FGColor)
        Gui Show, w838 h530, Quick View
    } Else {
        GuiControl,, %hEdtView%, %Data%
        Gui QuickView: Show
    }

    GuiControl Focus, %hEdtView%
Return

QuickViewSize:
    GuiControl Move, %hEdtView%, % "w" . (A_GuiWidth - 8) . " h" . A_GuiHeight
Return

QuickViewEscape:
QuickViewClose:
    Gui QuickView: Hide
Return

FixRootDir(ByRef Dir) {
    If (SubStr(Dir, 0, 1) == ":") {
        Dir := Dir . "\"
    }
}

#Include %A_ScriptDir%\..\Lib\ShellMenu.ahk
#Include %A_ScriptDir%\..\Lib\ControlColor.ahk
#Include %A_ScriptDir%\..\Lib\EnumIncludes.ahk
