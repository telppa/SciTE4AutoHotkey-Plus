ShowToolsDialog:
    Gui ToolsDlg: New, +LabelToolsDlg +hWndhToolsDlg
    SetWindowIcon(hToolsDlg, IconLib, 43)
    Gui Color, White

    Gui Add, Progress, x-1 y0 w722 h49 -Smooth +Background008EBC +Border, 0
    Gui Add, Picture, x680 y9 w32 h32 +BackgroundTrans +Icon43, %IconLib%
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x12 y12 w120 h23 +0x200 +BackgroundTrans, Tools
    Gui Font
    Gui Add, Text, x0 y46 w724 0x10 ; Separator

    Gui Font, s9, Segoe UI
    Gui Add, ListView, hWndhLVTools gLVToolsHandler x8 y56 w227 h308 -Hdr -Multi +LV0x14000 +AltSubmit, Tools
    SetExplorerTheme(hLVTools)
    Gui Add, Button, gAddTool x6 y370 w84 h24 +Default, &New...
    Gui Add, Button, gRemoveTool x95 y370 w84 h24, &Remove
    Gui Add, Button, hWndhBtnToolUp gMoveToolUp x184 y370 w24 h24
    GuiButtonIcon(hBtnToolUp, IconLib, 127, "L2 T1")
    Gui Add, Button, hWndhBtnToolDown gMoveToolDown x212 y370 w24 h24
    GuiButtonIcon(hBtnToolDown, IconLib, 128, "L2 T1")

    Gui Add, Text, x251 y58 w88 h23 +0x200, &Display Name:
    Gui Add, Edit, vEdtToolTitle gUpdateToolTitle x251 y84 w450 h22

    Gui Add, Text, x251 y114 w88 h23 +0x200, &File:
    Gui Add, Edit, vEdtToolFile x251 y140 w362 h22
    Gui Add, Button, vBtnToolFile gSelectTool x618 y138 w84 h24, Browse...

    Gui Add, Text, x251 y170 w88 h23 +0x200, &Parameters:
    Gui Add, Edit, vEdtToolParams x251 y196 w362 h22
    Gui Add, Button, hWndhBtnToolParams vBtnToolParams gShowToolParamsMenu x618 y194 w84 h24, Choose

    Gui Add, Text, x251 y226 w88 h23 +0x200, &Working Dir:
    Gui Add, Edit, vEdtToolWorkingDir x251 y252 w362 h22
    Gui Add, Button, vBtnToolWorkingDir gSelectWorkingDir x618 y250 w84 h24, Browse...

    Gui Add, Text, x251 y282 w88 h23 +0x200, &Icon:
    Gui Add, Edit, vEdtToolIcon x251 y308 w314 h22
    Gui Add, Edit, vEdtToolIconIndex x566 y308 w47 h22, 1
    Gui Add, Button, vBtnToolIcon gChooseToolIcon x618 y306 w84 h24, Browse...

    Gui Add, Text, x-1 y400 w723 h48 +Border -Background
    Gui Add, Button, gToolsDlgOK x445 y412 w84 h24, &OK
    Gui Add, Button, gToolsDlgClose x536 y412 w84 h24, &Cancel
    Gui Add, Button, gToolsDlgApply x627 y412 w84 h24, &Apply

    Gui Show, w720 h447, Configure Tools

    GoSub LoadTools
Return

LoadTools:
    Global Tools := []
    Global CurrentRow := 0
    Global ToolsImageList := IL_Create(100)

    IniRead IniSections, %g_IniTools%

    Loop Parse, IniSections, `n, `r
    {
        File       := ReadIni(g_IniTools, A_LoopField, "File")
        Params     := ReadIni(g_IniTools, A_LoopField, "Params", "")
        WorkingDir := ReadIni(g_IniTools, A_LoopField, "WorkingDir", "")
        Icon       := ReadIni(g_IniTools, A_LoopField, "Icon", "")
        IconIndex  := ReadIni(g_IniTools, A_LoopField, "IconIndex", 1)

        ILIndex := IL_Add(ToolsImageList, GetToolIconPath(Icon), IconIndex)
        LV_Add("Icon" . ILIndex, A_LoopField)

        SetToolValues(A_Index, A_LoopField, File, Params, WorkingDir, Icon, IconIndex)
    }

    LV_SetImageList(ToolsImageList, 1)
    LV_ModifyCol(1, "AutoHdr")
    LV_Modify(1, "Select")
    GoSub ShowToolInfo
Return

ReloadTools:
    Gui ToolsDlg: Default

    ToolsImageList := IL_Create(100)
    LV_Delete()
    LV_SetImageList(ToolsImageList, 1)

    For Each, Item in Tools {
        If (Item.Icon != "") {
            IconIndex := IL_Add(ToolsImageList, GetToolIconPath(Item.Icon), Item.IconIndex)
        } Else {
            IconIndex := 0
        }

        LV_Add("Icon" . IconIndex, Item.Title)
    }

    LV_ModifyCol(1, "AutoHdr")
Return

ToolsDlgEscape:
ToolsDlgClose:
    Gui ToolsDlg: Destroy
Return

ToolsDlgClear:
    GuiControl,, EdtToolTitle
    GuiControl,, EdtToolFile
    GuiControl,, EdtToolParams
    GuiControl,, EdtToolWorkingDir
    GuiControl,, EdtToolIcon
    GuiControl,, EdtToolIconIndex
Return

AddTool:
    Gui ListView, %hLVTools%
    CurrentRow := LV_Add("Icon 0", "")
    LV_Modify(CurrentRow, "Select")

    GoSub ToolsDlgClear

    GoSub SelectTool

    LV_ModifyCol(1, "AutoHdr")
    SendMessage 0x115, 7, 0,, ahk_id %hLVTools% ; WM_VSCROLL, SB_BOTTOM
Return

RemoveTool:
    Gui ListView, %hLVTools%
    Row := LV_GetNext()
    If (Row) {
        LV_Delete(Row)
        Tools.RemoveAt(Row)
        GoSub ToolsDlgClear
        CurrentRow := 0
        LV_ModifyCol(1, "AutoHdr")
    }
Return

MoveToolUp:
    Gui ListView, %hLVTools%
    Index := LV_GetNext()
    If (Index == 0 || Index == 1) {
        Return
    }

    Gui ToolsDlg: Submit, NoHide
    SetToolValues(Index, EdtToolTitle, EdtToolFile, EdtToolParams, EdtToolWorkingDir, EdtToolIcon, EdtToolIconIndex)

    TempItem := Tools[Index]
    PrevItem := Tools[Index - 1]
    Tools[Index] := PrevItem
    Tools[Index - 1] := TempItem
    CurrentRow--

    GoSub ReloadTools

    GuiControl Focus, %hLVTools%
    LV_Modify(Index - 1, "Select")
Return

MoveToolDown:
    Gui ListView, %hLVTools%
    Index := LV_GetNext()
    If (Index == 0 || Index == LV_GetCount()) {
        Return
    }

    TempItem := Tools[Index]
    NextItem := Tools[Index + 1]
    Tools[Index] := NextItem
    Tools[Index + 1] := TempItem
    CurrentRow++

    GoSub ReloadTools

    GuiControl Focus, %hLVTools%
    LV_Modify(Index + 1, "Select")
Return

SelectTool:
    Gui ToolsDlg: +OwnDialogs
    FileSelectFile SelectedFile, 3,, Select File
    If (ErrorLevel) {
        Return
    }

    GuiControl, ToolsDlg:, EdtToolFile, %SelectedFile%

    Gui ToolsDlg: Submit, NoHide

    SplitPath SelectedFile,,, Extension, NameNoExt

    If (EdtToolTitle == "" && IsToolTitleAvailable(NameNoExt)) {
        GuiControl, ToolsDlg:, EdtToolTitle, %NameNoExt%
    }

    If (Extension = "EXE") {
        GuiControl, ToolsDlg:, EdtToolIcon, %SelectedFile%
        ILIndex := IL_Add(ToolsImageList, SelectedFile, 1)
        LV_Modify(LV_GetNext(), "Icon" . ILIndex)
    }
Return

ChooseToolIcon:
    If !(Row := LV_GetNext()) {
        Return
    }

    Gui ToolsDlg: Submit, NoHide

    SplitPath EdtToolFile,,, ToolExt
    If (FileExist(EdtToolIcon)) {
        ToolIcon := EdtToolIcon
    } Else {
        ToolIcon := (ToolExt = "exe") ? EdtToolFile : "shell32.dll"
    }

    If (ChooseIcon(ToolIcon, EdtToolIconIndex, hToolsDlg)) {
        Gui ToolsDlg: Default
        GuiControl,, EdtToolIcon, %ToolIcon%
        GuiControl,, EdtToolIconIndex, %EdtToolIconIndex%
        ILIndex := IL_Add(ToolsImageList, ToolIcon, EdtToolIconIndex)
        LV_Modify(Row, "Icon" . ILIndex)
    }
Return

ToolsDlgOK:
ToolsDlgApply:
    Gui ToolsDlg: Submit, NoHide
    Gui ListView, %hLVTools%

    Row := LV_GetNext()
    If (Row) {
        SetToolValues(Row, EdtToolTitle, EdtToolFile, EdtToolParams, EdtToolWorkingDir, EdtToolIcon, EdtToolIconIndex)
    }

    ; Check for tools with the same title
    Loop % Tools.Length() {
        i := A_Index
        Loop % Tools.Length() {
            If (i <= A_Index) {
                Continue
            }

            If (Tools[i].Title == Tools[A_Index].Title) {
                Message := "More than one tool has the title """ . Tools[i].Title . """."
                Edit_ShowBalloonTip(hEdtToolTitle, Message, "The title must be unique", 2)
            }
        }
    }

    Loop % GetMenuItemCount(MenuGetHandle("AutoToolsMenu")) {
        Try {
            Menu AutoToolsMenu, Delete, 3&
        }
    }

    Loop % Tools.Length() {
        If (Tools[A_Index].Title == "" || Tools[A_Index].File == "") {
            Continue
        }

        Icon := GetToolIconPath(Tools[A_Index].Icon)
        Try {
            AddMenu("AutoToolsMenu", Tools[A_Index].Title, "RunTool", Icon, Tools[A_Index].IconIndex)
        }
    }

    If (Tools.Length()) {
        Menu AutoToolsMenu, Add
    }
    AddMenu("AutoToolsMenu", "Configure Tools...", "ShowToolsDialog", IconLib, 43)

    ; Check for writing permission
    FileAppend,, %g_IniTools%, UTF-16
    If (ErrorLevel) {
        FileCreateDir %A_AppData%\AutoGUI
        g_IniTools := A_AppData . "\AutoGUI\Tools.ini"
    }

    FileDelete %g_IniTools%

    Loop % Tools.Length() {
        Section := Tools[A_Index].Title
        If (Section == "" || Tools[A_Index].File == "") {
            Continue
        }

        IniWrite % Tools[A_Index].File, %g_IniTools%, %Section%, File

        If (Tools[A_Index].Params != "") {
            IniWrite % Tools[A_Index].Params, %g_IniTools%, %Section%, Params
        }

        If (Tools[A_Index].WorkingDir != "") {
            IniWrite % Tools[A_Index].WorkingDir, %g_IniTools%, %Section%, WorkingDir
        }

        If (Tools[A_Index].Icon != "") {
            IniWrite % Tools[A_Index].Icon, %g_IniTools%, %Section%, Icon
            If (Tools[A_Index].IconIndex > 1) {
                IniWrite % Tools[A_Index].IconIndex, %g_IniTools%, %Section%, IconIndex
            }
        }
    }

    If (A_ThisLabel == "ToolsDlgOK") {
        Gui ToolsDlg: Destroy
    } Else {
        If (Row) {
            ILIndex := IL_Add(ToolsImageList, GetToolIconPath(Tools[Row].Icon), Tools[Row].IconIndex)
            LV_Modify(Row, "Icon" . ILIndex)
        }
    }
Return

LVToolsHandler:
    If ((A_GuiEvent == "Normal" || A_GuiEvent == "K") && LV_GetNext()) {

        If (CurrentRow) {
            Gui ToolsDlg: Submit, NoHide
            SetToolValues(CurrentRow, EdtToolTitle, EdtToolFile, EdtToolParams, EdtToolWorkingDir, EdtToolIcon, EdtToolIconIndex)
        }

        GoSub ShowToolInfo
    }
Return

SetToolValues(Index, Title, File, Params, WorkingDir, Icon, IconIndex) {
    Tools[Index] := {}
    Tools[Index].Title := Title
    Tools[Index].File := File
    Tools[Index].Params := Params
    Tools[Index].WorkingDir := WorkingDir
    Tools[Index].Icon := Icon
    Tools[Index].IconIndex := IconIndex
}

ShowToolInfo:
    Gui ToolsDlg: Default
    CurrentRow := LV_GetNext()
    GuiControl,, EdtToolTitle, % Tools[CurrentRow].Title
    GuiControl,, EdtToolFile, % Tools[CurrentRow].File
    GuiControl,, EdtToolParams, % Tools[CurrentRow].Params
    GuiControl,, EdtToolWorkingDir, % Tools[CurrentRow].WorkingDir
    GuiControl,, EdtToolIcon, % Tools[CurrentRow].Icon
    GuiControl,, EdtToolIconIndex, % Tools[CurrentRow].IconIndex
Return

UpdateToolTitle:
    Gui ToolsDlg: Submit, NoHide
    Gui ListView, %hLVTools%
    Row := LV_GetNext()
    If (Row) {
        LV_Modify(Row,, EdtToolTitle)
        Tools[Row].Title := EdtToolTitle
    }
Return

SelectWorkingDir:
    GuiControlGet ToolFile, ToolsDlg:, EdtToolFile
    SplitPath ToolFile,, StartingFolder
    Gui ToolsDlg: +OwnDialogs
    FileSelectFolder SelectedFolder, *%StartingFolder%,, Select Folder
    If (!ErrorLevel) {
        GuiControl, ToolsDlg:, EdtToolWorkingDir, %SelectedFolder%
    }
Return

GetToolIconPath(Icon) {
    If (Icon != "" && !FileExist(Icon)) {
        If (FileExist(A_ScriptDir . "\Icons\" . Icon)) {
            Return A_ScriptDir . "\Icons\" . Icon
        }
    }
    Return Icon
}

ShowToolParamsMenu:
    Menu Placeholders, Add, "{FILENAME}", InsertPlaceholder
    Menu Placeholders, Add, "{FILEDIR}", InsertPlaceholder
    Menu Placeholders, Add, "{SELECTEDTEXT}", InsertPlaceholder
    Menu Placeholders, Add, "{AUTOGUIDIR}", InsertPlaceholder

    hParamsMenu := MenuGetHandle("Placeholders")
    WingetPos wx, wy, ww, wh, ahk_id %hToolsDlg%
    ControlGetPos cx, cy, cw, ch,, ahk_id %hBtnToolParams%
    x := wx + cx + cw
    y := wy + cy + ch
    DllCall("TrackPopupMenu", "Ptr", hParamsMenu, "UInt", 0x8, "Int", x, "Int", y, "Int", 0, "Ptr", hToolsDlg, "Ptr", 0)
Return

InsertPlaceholder:
    GuiControlGet hWnd, ToolsDlg: Hwnd, EdtToolParams
    Control EditPaste, %A_ThisMenuItem%,, ahk_id %hWnd%
Return

IsToolTitleAvailable(ToolTitle) {
    For Each, Tool in Tools {
        If (Tool.Title == ToolTitle) {
            Return False
        }
    }
    Return True
}

; IniRead doesn't preserve trailing quotes
ReadIni(IniFile, Section, Key, Default := "ERROR") {
    IniRead IniSections, %IniFile%
    Loop Parse, IniSections, `n, `r
    {
        SectionName := A_LoopField

        If (SectionName == Section) {
            IniRead SectionContent, %IniFile%, %SectionName%
            Loop Parse, SectionContent, `n, `r
            {
                SectionKey := SubStr(A_LoopField, 1, Pos := InStr(A_LoopField, "=") - 1)
                If (SectionKey == Key) {
                    Value := SubStr(A_LoopField, Pos + 2)
                    Return (Value == "") ? Default : Value
                }
            }
        }
    }

    Return Default
}
