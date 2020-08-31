ShowToolbarEditor:
    If (!WinExist("ahk_id " . hToolbarEditor)) {
        Global Toolbar := New Toolbar
        Toolbar.Buttons := []

        Gui ToolbarEditor: New, LabelToolbarEditor hWndhToolbarEditor ; OwnerAuto
        SetWindowIcon(hToolbarEditor, IconLib, 69)
        Gui Font, s9, Segoe UI
        Gui Color, White

        ; +0x200 makes the first cell editable
        Gui Add, ListView
        , hWndhLVToolbarButtons gToolbarButtonsListHandler x10 y10 w214 h264 +NoSortHdr -Multi +LV0x10000 +0x200
        , Toolbar Items
        LV_ModifyCol(1, "AutoHdr")

        Gui Add, Button, gNewToolbarButton x237 y10 w88 h25 +Default, &New...
        Gui Add, Button, gEditToolbarButton x237 y42 w88 h25, &Edit...
        Gui Add, Button, gDeleteToolbarButton x237 y74 w88 h25, De&lete
        Gui Add, Button, gMoveToolbarButtonUp x334 y10 w88 h25, Move &Up
        Gui Add, Button, gMoveToolbarButtonDown x334 y42 w88 h25, Move &Down
        Gui Add, Button, gDeleteAllToolbarButtons x334 y74 w88 h25, Dele&te All

        Gui Add, GroupBox, x236 y110 w188 h164, Toolbar Options
        Gui Add, CheckBox, vTB_ChkTooltips x250 y132 w80 h23 +Checked, Tooltips
        Gui Add, CheckBox, vTB_ChkFlat x250 y159 w80 h23 +Checked, Flat
        Gui Add, CheckBox, vTB_ChkList x250 y186 w80 h23 +Checked, List
        Gui Add, CheckBox, vTB_ChkBottom x250 y213 w80 h23, Bottom
        Gui Add, CheckBox, vTB_ChkVertical x250 y240 w80 h23, Vertical
        Gui Add, CheckBox, vTB_ChkShowText x339 y132 w80 h23, Show Text
        Gui Add, CheckBox, vTB_ChkTextOnly x338 y159 w80 h23, Text Only
        Gui Add, CheckBox, vTB_ChkTabstop x338 y186 w80 h23, Tabstop
        Gui Add, CheckBox, vTB_ChkBorder x338 y213 w80 h23, Border
        Gui Add, CheckBox, vTB_ChkNoDivider x338 y240 w80 h23, No Divider

        Gui Add, Text, x-1 y285 w435 h49 +Border -Background
        Gui Add, Button, gToolbarEditorHelp x10 y297 w88 h25, &Help
        Gui Add, Button, gToolbarEditorOK x237 y297 w88 h25, &OK
        Gui Add, Button, gToolbarEditorClose x334 y297 w88 h25, &Cancel
        Gui Font
        Gui Show, w433 h333, Toolbar Editor

        SetExplorerTheme(hLVToolbarButtons)
    } Else {
        Gui ToolbarEditor: Show
    }
Return

ToolbarEditorEscape:
ToolbarEditorClose:
    Gui ToolbarEditor: Hide
Return

NewToolbarButton:
EditToolbarButton:
    If (GetKeyState("Shift", "P")) {
        GoSub ToolbarTest
        Return
    }

    If (A_ThisLabel == "EditToolbarButton") {
        Index := LV_GetNext()
        If (!Index) {
            Return
        }

        ToolbarButtonText := Toolbar.Buttons[Index].Text
        ToolbarButtonIconIndex := Toolbar.Buttons[Index].IconIndex
    } Else {
        Index := 0
        ToolbarButtonText := ""
        ToolbarButtonIconIndex := 4
    }

    ChkStayPressed  := RegExMatch(Toolbar.Buttons[Index].Style, "i)\bCHECK\b")
    ChkGrouped      := InStr(Toolbar.Buttons[Index].Style, "CHECKGROUP")
    ChkDropDown     := InStr(Toolbar.Buttons[Index].Style, "DROPDOWN")
    ChkShowText     := InStr(Toolbar.Buttons[Index].Style, "SHOWTEXT")
    ChkStartPressed := InStr(Toolbar.Buttons[Index].State, "CHECKED")
    ChkDisabled     := InStr(Toolbar.Buttons[Index].State, "DISABLED")
    ChkHidden       := InStr(Toolbar.Buttons[Index].State, "HIDDEN")
    ChkbreakRow     := InStr(Toolbar.Buttons[Index].State, "WRAP")

    Gui NewToolbarButtonDlg: New, LabelNewToolbarButtonDlg hWndhNewToolbarButtonDlg -MinimizeBox OwnerToolbarEditor
    Gui Font, s9, Segoe UI
    Gui Color, White

    Gui Add, GroupBox, x10 y7 w381 h110
    Gui Add, Text, x24 y35 w46 h23 +0x200, Text:
    Gui Add, Edit, hWndhToolbarButtonText vToolbarButtonText x71 y35 w221, %ToolbarButtonText%
    Gui Add, Button, gToolbarSeparator x297 y34 w80 h25 +0xC, Separator
    Gui Add, Text, x24 y72 w46 h23 +0x200, Icon:
    Gui Add, ComboBox, vToolbarButtonIcon x71 y73 w221, shell32.dll||imageres.dll
    Gui Add, Edit, vToolbarButtonIconIndex x300 y73 w46 h22, %ToolbarButtonIconIndex%
    Gui Add, Button, gChooseToolbarButtonIcon x353 y71 w24 h24, ...

    Gui Add, GroupBox, x44 y126 w147 h127, Button Styles
    Gui Add, CheckBox, vChkStayPressed x57 y147 w120 h23 Checked%ChkStayPressed%, Stay Pressed
    Gui Add, CheckBox, vChkGrouped x57 y171 w120 h23 Checked%ChkGrouped%, Grouped
    Gui Add, CheckBox, vChkDropDown x57 y195 w120 h23 Checked%ChkDropDown%, Drop-down
    Gui Add, CheckBox, vChkShowText x57 y219 w120 h23 Checked%ChkShowText%, Show Text

    Gui Add, GroupBox, x206 y126 w147 h127, Button States
    Gui Add, CheckBox, vChkStartPressed x222 y147 w120 h23 Checked%ChkStartPressed%, Start Pressed
    Gui Add, CheckBox, vChkDisabled x222 y171 w120 h23 Checked%ChkDisabled%, Disabled
    Gui Add, CheckBox, vChkHidden x222 y195 w120 h23 Checked%ChkHidden%, Hidden
    Gui Add, CheckBox, vChkBreakRow x222 y219 w120 h23 Checked%ChkbreakRow%, Break Row

    Gui Add, Text, x-1 y265 w404 h49 +Border -Background
    If (A_ThisLabel == "NewToolbarButton") {
        Gui Add, Button, gNewToolbarButtonDlgNext x59 y277 w88 h25 +Default, &Next
        Gui Add, Button, gNewToolbarButtonDlgOK x158 y277 w88 h25, &OK
        Gui Add, Button, gNewToolbarButtonDlgClose x256 y277 w88 h25, &Cancel

        GuiControl Text, ToolbarButtonIcon, %g_IconPath%
    } Else {
        Gui Add, Button, gNewToolbarButtonDlgEdit x108 y277 w88 h25 +Default, &OK
        Gui Add, Button, gNewToolbarButtonDlgClose x206 y277 w88 h25, &Cancel

        GuiControl Text, ToolbarButtonIcon, % Toolbar.Buttons[Index].Icon
    }

    ControlGetPos cx, cy,,, &Edit
    WinGetPos wx, wy,,, ahk_id %hToolbarEditor%
    x := wx + cx
    y := wy + cy
    Gui Show, x%x% y%y% w402 h314, % ((A_ThisLabel == "NewToolbarButton") ? "New" : "Edit") . " Toolbar Button"
Return

NewToolbarButtonDlgEscape:
NewToolbarButtonDlgClose:
    Gui NewToolbarButtonDlg: Destroy
Return

NewToolbarButtonDlgOK:
NewToolbarButtonDlgNext:
NewToolbarButtonDlgEdit:
    Gui NewToolbarButtonDlg: Submit, NoHide
    If (A_ThisLabel != "NewToolbarButtonDlgNext") {
        Gui NewToolbarButtonDlg: Destroy
    }

    If (ToolbarButtonText == "" && A_ThisLabel != "NewToolbarButtonDlgNext") {
        Return
    }

    Gui ToolbarEditor: Default

    ToolbarButton := New Toolbar.Button

    ; Button text/tooltip
    If (ToolbarButtonText == "SEPARATOR") {
        ToolbarButton.Text := ""
    } Else If (ToolbarButtonText == "") {
        ToolbarButton.Text := "..."
    } Else {
        ToolbarButton.Text := ToolbarButtonText
    }

    ; Button icon
    ToolbarButton.Icon := ToolbarButtonIcon
    ToolbarButton.IconIndex := ToolbarButtonIconIndex

    ; Button style
    ToolbarButtonStyle := ""
    If (ChkStayPressed) {
        ToolbarButtonStyle .= " CHECK"
    }
    If (ChkGrouped) {
        ToolbarButtonStyle .= " CHECKGROUP"
    }
    If (ChkDropDown) {
        ToolbarButtonStyle .= " DROPDOWN"
    }
    If (ChkShowText) {
        ToolbarButtonStyle .= " SHOWTEXT"
    }
    ToolbarButton.Style := ToolbarButtonStyle

    ; Button state
    ToolbarButtonState := ""
    If (ChkStartPressed) {
        ToolbarButtonState .= " CHECKED"
    }
    If (ChkDisabled) {
        ToolbarButtonState .= " DISABLED"
    }
    If (ChkHidden) {
        ToolbarButtonState .= " HIDDEN"
    }
    If (ChkBreakRow) {
        ToolbarButtonState .= " WRAP"
    }
    ToolbarButton.State := ToolbarButtonState

    If (A_ThisLabel == "NewToolbarButtonDlgEdit") {
        Gui ToolbarEditor: Default
        Index := LV_GetNext()
        Toolbar.Buttons[Index] := ToolbarButton
    } Else {
        Toolbar.Buttons.Push(ToolbarButton)
    }

    GoSub ReloadToolbarButtonsList

    GoSub ResetNewToolbarButtonDlgFields

    If (A_ThisLabel == "NewToolbarButtonDlgNext") {
        GuiControl Focus, %hToolbarButtonText%
    } Else If (A_ThisLabel == "NewToolbarButtonDlgEdit") {
        Gui ToolbarEditor: Default
        GuiControl Focus, %hLVToolbarButtons%
        LV_Modify(Index, "Select")
    }
Return

DeleteToolbarButton:
    Gui ToolbarEditor: Default
    Index := LV_GetNext()
    LV_Delete(Index)
    LV_ModifyCol(1, "AutoHdr")
    Toolbar.Buttons.RemoveAt(Index)
    GoSub ReloadToolbarButtonsList
Return

DeleteAllToolbarButtons:
    Gui ToolbarEditor: Default
    LV_Delete()
    LV_ModifyCol(1, "AutoHdr")
    Toolbar.Buttons := []
Return

MoveToolbarButtonUp:
    Index := LV_GetNext()
    If (Index == 0 || Index == 1) {
        Return
    }

    TempItem := Toolbar.Buttons[Index]
    PrevItem := Toolbar.Buttons[Index - 1]
    Toolbar.Buttons[Index] := PrevItem
    Toolbar.Buttons[Index - 1] := TempItem

    GoSub ReloadToolbarButtonsList

    GuiControl Focus, %hLVToolbarButtons%
    LV_Modify(Index - 1, "Select")
Return

MoveToolbarButtonDown:
    Index := LV_GetNext()
    If (Index == 0 || Index == LV_GetCount()) {
        Return
    }

    TempItem := Toolbar.Buttons[Index]
    NextItem := Toolbar.Buttons[Index + 1]
    Toolbar.Buttons[Index] := NextItem
    Toolbar.Buttons[Index + 1] := TempItem

    GoSub ReloadToolbarButtonsList

    GuiControl Focus, %hLVToolbarButtons%
    LV_Modify(Index + 1, "Select")
Return

Class Toolbar {
    Options := ""

    Class Button {
        Text := ""
        Icon := ""
        IconIndex := 0
        State := ""
        Style := ""
    }
}

ToolbarEditorOK:
    If (!WinExist("ahk_id" . hChildWnd)) {
        GoSub NewGUI
    }

    Gui ToolbarEditor: Default
    Gui ToolbarEditor: Submit, NoHide

    ToolbarOptions := ""

    If (TB_ChkFlat) {
        ToolbarOptions .= " Flat"
    }
    If (TB_ChkList) {
        ToolbarOptions .= " List"
    }
    If (TB_ChkBottom) {
        ToolbarOptions .= " Bottom"
    }
    If (TB_ChkVertical) {
        ToolbarOptions .= " Vertical"
    }
    If (TB_ChkShowText) {
        ToolbarOptions .= " ShowText"
    }
    If (TB_ChkTextOnly) {
        ToolbarOptions .= " TextOnly"
    }
    If (TB_ChkTooltips) {
        ToolbarOptions .= " Tooltips"
    }
    If (TB_ChkNoDivider) {
        ToolbarOptions .= " NoDivider"
    }
    If (TB_ChkTabstop) {
        ToolbarOptions .= " Tabstop"
    }
    If (TB_ChkBorder) {
        ToolbarOptions .= " Border"
    }

    Toolbar.Options := LTrim(ToolbarOptions)

    ToolbarButtons := ""
    For Each, Item in Toolbar.Buttons {
        ButtonText := (Item.Text == "") ? "-" : Item.Text
        ToolbarButtons .= ButtonText . ",," . Item.State . "," . Item.Style . "`n"
    }

    Gui ToolbarEditor: Hide

    DestroyWindow(hChildToolbar)

    If (Toolbar.Buttons.Length()) {
        Gui %Child%: Default
        TBIL := InStr(Toolbar.Options, "textonly") ? "" : ImageList2
        hChildToolbar := ToolbarCreate("", Trim(ToolbarButtons, "`n"), TBIL, Toolbar.Options)
        ApplyGUIFont(hChildToolbar)
    }

    GenerateCode()
Return

ChooseToolbarButtonIcon:
    Gui NewToolbarButtonDlg: Submit, NoHide
    If (ToolbarButtonIcon == "") {
        ToolbarButtonIcon := "shell32.dll"
    }

    If (ChooseIcon(ToolbarButtonIcon, ToolbarButtonIconIndex, hToolbarEditor)) {
        Gui NewToolbarButtonDlg: Default
        GuiControl,, ToolbarButtonIcon, % ToolbarButtonIcon . "||"
        GuiControl,, ToolbarButtonIconIndex, %ToolbarButtonIconIndex%
        g_IconPath := ToolbarButtonIcon
    }
Return

ResetNewToolbarButtonDlgFields:
    Gui NewToolbarButtonDlg: Default
    GuiControl,, %ToolbarButtonText%
Return

ReloadToolbarButtonsList:
    Gui ToolbarEditor: Default

    ImageList1 := IL_Create(100) ; ListView
    ImageList2 := IL_Create(100) ; Toolbar
    LV_Delete()
    LV_SetImageList(ImageList1)

    For Each, Item in Toolbar.Buttons {
        If (Item.Text == "") {
            IconIndex := IL_Add(ImageList1, IconLib, 63)
        } Else {
            IconIndex := IL_Add(ImageList1, Item.Icon, Item.IconIndex)
            IL_Add(ImageList2, Item.Icon, Item.IconIndex)
        }

        LV_Add("Icon" . IconIndex, Item.Text)
    }

    LV_ModifyCol(1, "AutoHdr")
Return

ToolbarTest:
    Toolbar.Buttons := []
    Loop 12 {
        Toolbar.Buttons.Push({"Text": A_Index, "Icon": "shell32.dll", "IconIndex": A_Index + 12})
    }
    GoSub ReloadToolbarButtonsList
Return

ToolbarButtonsListHandler:
    If (A_GuiEvent == "e") {
        LV_GetText(ToolbarButtonText, A_EventInfo)
        Toolbar.Buttons[A_EventInfo].Text := ToolbarButtonText
    } Else If (A_GuiEvent == "DoubleClick") {
        GuiControl Focus, %hLVToolbarButtons%
        Row := LV_GetNext(0, "Focused") - 1
        PostMessage 0x1076, Row, 0,, ahk_id %hLVToolbarButtons% ; LVM_EDITLABELW
    }
Return

ToolbarSeparator:
    GuiControl,, %hToolbarButtonText%, SEPARATOR
    GoSub NewToolbarButtonDlgNext
Return

ToolbarEditorHelp:
    Try {
        Run %A_ScriptDir%\Help\Toolbar Editor.htm
    }
Return
