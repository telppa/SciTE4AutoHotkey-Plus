CreateToolbox(Hidden := 0) {
    GetClientSize(hAutoWnd, WindowW, WindowH)
    ToolboxH := WindowH - g_ToolbarH - g_StatusBarH
    ToolboxOptions := "AltSubmit -Multi +LV0x10000 Background0xFEFEFE"
    Y := g_ToolbarH + 2
    Gui Add, ListView
    , hWndhLVToolbox gToolboxHandler x0 y%Y% w160 h%ToolboxH% %ToolboxOptions% Hidden%Hidden%
    , Control Palette
    SetExplorerTheme(hLVToolbox)

    ; Toolbox ImageList
    Global TboxIL := IL_Create(32)
    IL_Add(TboxIL, IconLib, -9)  ; Button
    IL_Add(TboxIL, IconLib, -10) ; CheckBox
    IL_Add(TboxIL, IconLib, -11) ; ComboBox
    IL_Add(TboxIL, IconLib, -13) ; DropDownList
    IL_Add(TboxIL, IconLib, -12) ; DateTime
    IL_Add(TboxIL, IconLib, -14) ; Edit
    IL_Add(TboxIL, IconLib, -15) ; GroupBox
    IL_Add(TboxIL, IconLib, -16) ; Hotkey
    IL_Add(TboxIL, IconLib, -17) ; Link
    IL_Add(TboxIL, IconLib, -18) ; ListBox
    IL_Add(TboxIL, IconLib, -19) ; ListView
    IL_Add(TboxIL, IconLib, -20) ; Menu
    IL_Add(TboxIL, IconLib, -21) ; MonthCal
    IL_Add(TboxIL, IconLib, -22) ; Picture
    IL_Add(TboxIL, IconLib, -23) ; Progress
    IL_Add(TboxIL, IconLib, -24) ; Radio
    IL_Add(TboxIL, IconLib, -25) ; Separator
    IL_Add(TboxIL, IconLib, -26) ; Slider
    IL_Add(TboxIL, IconLib, -27) ; StatusBar
    IL_Add(TboxIL, IconLib, -28) ; Tab
    IL_Add(TboxIL, IconLib, -29) ; Text
    IL_Add(TboxIL, IconLib, -30) ; Toolbar
    IL_Add(TboxIL, IconLib, -31) ; TreeView
    IL_Add(TboxIL, IconLib, -32) ; UpDown
    IL_Add(TboxIL, IconLib, -33) ; ActiveX
    IL_Add(TboxIL, IconLib, -34) ; Custom
    IL_Add(TboxIL, IconLib, -35) ; Command Link
    LV_SetImageList(TboxIL, 1)

    ; Toolbox items
    LV_Add("Icon1", "Button")
    LV_Add("Icon2", "CheckBox")
    LV_Add("Icon3", "ComboBox")
    LV_Add("Icon4", "Drop-Down List")
    LV_Add("Icon5", "Date Time Picker")
    LV_Add("Icon6", "Edit Box")
    LV_Add("Icon7", "GroupBox")
    LV_Add("Icon8", "Hotkey Box")
    LV_Add("Icon9", "Link")
    LV_Add("Icon10", "ListBox")
    LV_Add("Icon11", "ListView")
    LV_Add("Icon12", "Menu Bar")
    LV_Add("Icon13", "Month Calendar")
    LV_Add("Icon14", "Picture")
    LV_Add("Icon15", "Progress Bar")
    LV_Add("Icon16", "Radio Button")
    LV_Add("Icon17", "Separator")
    LV_Add("Icon18", "Slider")
    LV_Add("Icon19", "Status Bar")
    LV_Add("Icon20", "Tab")
    LV_Add("Icon21", "Text")
    LV_Add("Icon22", "Toolbar")
    LV_Add("Icon23", "TreeView")
    LV_Add("Icon24", "UpDown")
    LV_Add("Icon25", "ActiveX")
    LV_Add("Icon26", "Custom Class")
    If (g_NT6orLater) {
        LV_Add("Icon27", "Command Link")
    }
}

ToolboxHandler:
    If (A_GuiEvent == "Normal" || (A_GuiEvent == "K" && A_EventInfo == 32)) {
        g_Cross := False

        If (!A_EventInfo) {
            Return
        }

        LV_GetText(Type, (A_GuiEvent == "Normal") ? A_EventInfo : LV_GetNext())

        If (Type == "Control Palette") {
            Return
        }

        If (Type == "Menu Bar") {
            Gosub ShowMenuEditor
            Return
        }

        If (Type == "Toolbar") {
            Gosub ShowToolbarEditor
            Return
        }

        If (WinExist("ahk_id " . hChildWnd)) {
            ShowChildWindow(4) ; SW_SHOWNOACTIVATE
        } Else {
            GoSub NewGUI
        }

        If (Type == "Status Bar") {
            AddStatusBar()
            Return
        }

        If (Type == "ActiveX") {
            ShowActiveXDialog()
            Return
        }

        If (Type == "Custom Class") {
            ShowCustomClassDialog()
            Return
        }

        If (A_GuiEvent == "Normal") {
            g_Cross := True

        } Else If (A_GuiEvent == "K") {
            hPrevCtl := g.LastControl
            GuiControlGet Pos, %Child%: Pos, %hPrevCtl%

            If (hPrevCtl && g[hPrevCtl].Type != "StatusBar") {
                If (GetKeyState("Shift", "P")) {
                    g_X := PosX + PosW + 8
                    g_Y := PosY
                } Else {
                    g_X := 8
                    g_Y := PosY + PosH + 8
                }
            } Else {
                g_X := g_Y := 8
            }

            AddControl(Type)
        }
    }
Return

NewGUI:
    If (Sci.GetModify()) {
        Gui Auto: +OwnDialogs
        MsgBox 0x33, %g_AppName%, Unsaved GUI script. Do you want to save it?
        IfMsgBox Yes, {
            If (!Save()) {
                Return
            }
        }
    }

    ; Reset document properties
    ClearFile()
    ApplyTheme()
    SetWindowTitle()

    ; Reset GUI properties
    g := New GuiClass
    g.Window := New g.Window
    ResetMenu()
    DestroyProperties()

    Gui %Child%: Destroy
    Child++

    ; Initial position, size and title
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetWindowRect", "Ptr", Sci.hWnd, "Ptr", &RECT)
    DllCall("MapWindowPoints", "Ptr", 0, "Ptr", GetParent(hAutoWnd), "Ptr", &RECT, "UInt", 1)
    X := NumGet(RECT, 0, "Int") + 2
    Y := NumGet(RECT, 4, "Int") + 2
    W := 620
    H := 420
    g.Window.Title := "Window"
    g.Window.FontName := g_DefGUIFontName
    g.Window.FontOptions := g_DefGUIFontOpts

    Gui %Child%: New, +LabelChild +hWndhChildWnd +Resize +OwnerAuto -DPIScale
    Gui %Child%: Show, x%X% y%Y% w%W% h%H%, % g.Window.Title
    SetWindowIcon(hChildWnd, IconLib, -7)

    GenerateCode()

    CreateResizers()
Return

Class GuiClass {
    ControlList := []
    Selection := []
    ControlFuncs := ""
    WinEvents1 := ""
    WinEvents2 := ""
    Anchor := 0
    ControlColor := 0
    Clipboard := ""
    LastControl := 0

    Class Window {
        Title := "Window"
        hWndVar := ""
        Name := ""
        Label := ""
        Options := ""
        Extra := ""
        Styles := ""
        FontName := ""
        FontOptions := ""
        Color := ""
        GuiClose := 1
        GuiEscape := 1
        GuiSize := 0
        GuiContextMenu := 0
        GuiDropFiles := 0
        OnClipboardChange := 0
        Icon := ""
        IconIndex := 1
        Center := 1
    }

    Class Control {
        Handle := -1
        Class := ""
        ClassNN := ""
        Text := ""
        x := 0
        y := 0
        w := 0
        h := 0
        hWndVar := ""
        vVar := ""
        gLabel := ""
        LabelIsFunc := 0
        Anchor := ""
        Options := ""
        Extra := ""
        Styles := ""
        FontName := ""
        FontOptions := ""
    }
}

AddControl(DisplayName) {
    Gui %Child%: Default

    Type := GetControlType(DisplayName)

    If Type Not In Edit,Hotkey,ListBox,ListView,TreeView
        g_Adding := True

    If Type Not In TreeView,Hotkey,DateTime
        Text := Default[Type].Text

    Options := Default[Type].Options
    Size := " w" . Default[Type].Width . " h" . Default[Type].Height
    Position := " x" . g_X . " y" . g_Y

    If (Type == "Picture") {
        Icon := 0
        If (ChoosePicture(g_PicturePath, Icon)) {
            Text := g_PicturePath
            If (Icon) {
                Options := "+Icon" . Icon
            }
        }

        Size := ""
    } Else If (Type == "Separator") {
        Type := "Text"
    } Else If (Type == "UpDown") {
        If (g[g.LastControl].Type != "Edit") {
            Options .= " -16"
        }
    } Else If (Type == "StatusBar") {
        Size := Position := ""
    } Else If (Type == "CommandLink") {
        Type := "Custom"
    }

    TabPos := IsInTab(g_X, g_Y)
    If (TabPos[1]) {
        Gui %Child%: Tab, % TabPos[1], % TabPos[2]
    }

    _Options := ""
    If (Type == "Tab2") {
        _Options := " AltSubmit +Theme"
    } Else If (Type == "Text" || Type == "Picture") {
        _Options := " +0x100" ; SS_NOTIFY (needed for WM_SETCURSOR)
    }

    Gui %Child%: Default
    Gui Add, %Type%, % "hWndhWnd " . Options . Size . Position . _Options, %Text%

    If (TabPos[1] || Type == "Tab2") {
        Gui %Child%: Tab
    }

    If (Type == "ListView") {
        LV_Add("", "Item")

    } Else If (Type == "TreeView") {
        Gui %Child%: Default
        Parent := TV_Add("TreeView")
        TV_Add("Child", Parent)

    } Else If (DisplayName == "Command Link") {
        Type := "CommandLink"
        Options := ""
        Extra := Default[Type].Options

    } Else If (DisplayName == "Separator") {
        Type := "Separator"
        Options := ""
        Extra := Default[Type].Options

    } Else If (Type == "Custom" || Type == "Picture") {
        Extra := Options
        Options := ""
    }

    ApplyGuiFont(hWnd)

    g.ControlList.Push(hWnd)
    ClassNN := GetClassNN(hWnd)

    Register(hWnd, Type, ClassNN, Text, "", "", "", Options, Extra, "", "", "", "", TabPos)

    GenerateCode()

    Properties_AddItem(ClassNN)
    If (IsWindowVisible(hPropWnd)) {
        GoSub ShowProperties ; ?
    }

    DestroySelection()
    Return hWnd
}

AddSelectedControl() {
    Global
    Local Row, Type

    Gui Auto: Default
    Gui Auto: ListView, %hLvToolbox%

    ;SendMessage 0x100C, 0, 2,, ahk_id %hLvToolbox% ; LVM_GETNEXTITEM
    ;MsgBox % ErrorLevel

    If (Row := LV_GetNext()) {
        LV_GetText(Type, Row)
        If (Type != "Toolbox") {
            AddControl(Type)
        }
    }
}

ApplyGuiFont(hCtl) {
    If (g.Window.FontName != "" || g.Window.FontOptions != "") {
        Gui %Child%: Font, % g.Window.FontOptions, % g.Window.FontName
        GuiControl Font, %hCtl%
        Gui %Child%: Font
    }
}

Register(hWnd, Type, ClassNN, Text := "", hWndVar := "", vVar := "", gLabel := "", Options := "", Extra := "", Styles := "", FontName := "", FontOptions := "", Anchor := "", TabPos := "") {
    g[hWnd] := New g.Control
    g[hWnd].Handle := hWnd
    g[hWnd].Class := GetClassName(hWnd)
    g[hWnd].Type := Type
    g[hWnd].ClassNN := (ClassNN != "") ? ClassNN : GetClassNN(hWnd)
    g[hWnd].Text := Text
    g[hWnd].hWndVar := hWndVar
    g[hWnd].vVar := vVar
    g[hWnd].gLabel := gLabel
    g[hWnd].Options := Options
    g[hWnd].Extra := Extra
    g[hWnd].Styles := Styles
    g[hWnd].FontName := FontName
    g[hWnd].FontOptions := FontOptions
    g[hWnd].Anchor := Anchor
    g[hWnd].Tab := TabPos
    g[hWnd].Deleted := False
    g_Control := g.LastControl := hWnd
}

MoveControl() {
    If (g_Adding) {
        Return
    }

    Gui %Child%: Default

    CoordMode Mouse, Screen
    MouseGetPos mx1, my1,, g_Control, 2

    Selection := GetSelectedItems()

    Controls := []
    For Each, Item In Selection {
        GuiControlGet c, %Child%: Pos, %Item%
        Controls.Push({x: cx, y: cy})
    }

    While (GetKeyState("LButton", "P")) {
        MouseGetPos mx2, my2

        If (mx2 == PrevX && my2 == PrevY) {
            Continue
        }

        PrevX := mx2
        PrevY := my2

        For Index, Item In Selection {
            GuiControlGet c, Pos, % Item
            If (g_SnapToGrid) {
                PosX := RoundTo(Controls[Index].x + (mx2 - mx1), g_GridSize)
                PosY := RoundTo(Controls[Index].y + (my2 - my1), g_GridSize)
            } Else {
                PosX := Controls[Index].x + (mx2 - mx1)
                PosY := Controls[Index].y + (my2 - my1)
            }
            GuiControl MoveDraw, %Item%, % "x" . PosX . " " . "y" . PosY
        }

        If (g_GuiVis) {
            Gui Auto: Default
            SB_SetText("Position: " . (g[Selection[1]].x + (mx2 - mx1)) . ", " . g[Selection[1]].y + (my2 - my1), 2)
            Gui %Child%: Default
        }

        Sleep 1
    }

    If (mx2 == mx1 && my2 == my1) {
        Return
    }

    Properties_UpdateCtlPos()
    GenerateCode()
    UpdateSelection()
    Return
}

ResizeControl(hCtl) {
    HideResizers()

    MouseGetPos mx, my
    ControlGetPos,,, w, h,, ahk_id %hCtl%
    xOffset := w - mx
    yOffset := h - my

    Gui %Child%: Default
    Selection := GetSelectedItems()

    While (GetKeyState("LButton", "P")) {
        MouseGetPos mx, my

        h := my + yOffset
        w := mx + xOffset

        If (g_SnapToGrid) {
            w := RoundTo(w, g_GridSize)
            h := RoundTo(h, g_GridSize)
        }

        For Each, Item In Selection {
            GuiControl MoveDraw, %Item%, w%w% h%h%
        }

        Gui Auto: Default
        SB_SetText("Size: " . w . " x " . h, 3)
        Gui %Child%: Default

        Sleep 1
    }

    Properties_UpdateCtlPos()
    GenerateCode()
    UpdateSelection()
}

RemoveControl(hCtl) {
    If (hCtl == hChildWnd) {
        Return
    }

    If (g[hCtl].Type == "StatusBar") {
        GuiControl Hide, %hCtl%
        g[hCtl].Deleted := True
        GoSub ReloadControlList
        GenerateCode()
        Return
    }

    If (g[hCtl].Type == "Tab2") {
        Gui %Child%: Tab
    }

    hParent := GetParent(hCtl)
    If (hParent != hChildWnd) {
        hCtl := hParent
    }

    g[hCtl].Deleted := DestroyWindow(hCtl)
    g.ControlList.Delete(hCtl)
}

GetSelectedItems() {
    If (g.Selection.Length()) {
        Return g.Selection
    } Else {
        If (g[g_Control].Handle == "") {
            g_Control := GetParent(g_Control)
        }
        SelectedItems := []
        SelectedItems.Push(g_Control)
        Return SelectedItems
    }
}

CutControl() {
    g.Clipboard := g_Control
    GuiControl Hide, %g_Control%
    g[g_Control].Deleted := True
    Menu WindowContextMenu, Enable, Paste
    GenerateCode()
    DestroySelection()
    If (g_Control == hReszdCtl) {
        HideResizers()
    }
}

CopyControl() {
    g.Clipboard := g[g_Control].Clone()
    GuiControlGet Pos, %Child%: Pos, %g_Control%
    g.Clipboard.W := PosW
    g.Clipboard.H := PosH

    Menu WindowContextMenu, Enable, Paste
}

PasteControl() {
    ; From Copy
    If (g.Clipboard.HasKey("Handle")) {
        Type := g.Clipboard.Type
        /*
        If (Type == "Tab2") {
            Type := "Tab3"
        } Else If (Type == "CommandLink") {
            Type := "Custom"
        } Else If (Type == "Separator") {
            Type := "Text"
        }
        */

        x := g_X
        y := g_Y
        w := g.Clipboard.W
        h := g.Clipboard.H
        Text := g.Clipboard.Text
        Options := g.Clipboard.Options
        Extra := g.Clipboard.Extra
        Styles := g.Clipboard.Styles
        FontName := g.Clipboard.FontName
        FontOptions := g.Clipboard.FontOptions
        Anchor := g.Clipboard.Anchor

        TabPos := IsInTab(x, y)
        If (TabPos[1]) {
            Gui %Child%: Tab, % TabPos[1], % TabPos[2]
        }

        Gui %Child%: Add, %Type%, hWndhWnd x%x% y%Y% w%w% h%h% %Options% %Extra% %Styles%, %Text%

        ClassNN := GetClassNN(hWnd)
        Register(hWnd, Type, ClassNN, Text,,,, Options, Extra, Styles, FontName, FontOptions, Anchor, TabPos)
        g.ControlList.Push(hWnd)
        Properties_AddItem(ClassNN)

        fFont := False
        If (FontOptions != "" || FontName != "") {
            Gui %Child%: Font, %FontOptions%, %FontName%
            fFont := True
        } Else If (g.Window.FontOptions != "" || g.Window.FontName != "") {
            Gui %Child%: Font, % g.Window.FontOptions, % g.Window.FontName
            fFont := True
        }

        If (fFont) {
            GuiControl Font, %hWnd%
            Gui %Child%: Font
        }

        If (TabPos[1]) {
            Gui %Child%: Tab
        }
    ; From Cut
    } Else {
        GuiControl Move, % g.Clipboard, x%g_X% y%g_Y%
        GuiControl Show, % g.Clipboard
        g[g.Clipboard].Deleted := False
    }

    GenerateCode()
}

ResetMenu() {
    m.Code := ""
    g_MenuFuncs := ""

    hMenu := GetMenu(hChildWnd)
    TopMenuCount := GetMenuItemCount(hMenu)
    Loop %TopMenuCount% {
        hSubMenu := GetSubMenu(hMenu, A_Index - 1)
        SubMenuCount := GetMenuItemCount(hSubMenu)
        Loop %SubMenuCount% {
            DeleteMenu(hSubMenu, 0)
        }
    }

    Try {
        Menu MenuBar, Delete
    }
}

AddStatusBar() {
    If (StatusBarExist()) {
        Gui %Child%: Default
        GuiControlGet SBVis, Visible, msctls_statusbar321
        GuiControl Hide%SBVis%, msctls_statusbar321
        GuiControlGet hStatusBar, Hwnd, msctls_statusbar321
        g[hStatusBar].Deleted := SBVis
        GenerateCode()
        GoSub ReloadControlList
    } Else {
        AddControl("Status Bar")
    }
}

StatusBarExist() {
    GuiControlGet SBExist, %Child%: hWnd, msctls_statusbar321
    Return SBExist
}

MenuBarExist() {
    Return GetMenu(hCHildWnd)
}

ToolbarExist() {
    Return IsWindow(hChildToolbar)
}

; Mark selected controls
Select(SelectedControls) {
    If (!SelectedControls.Length()) {
        Return
    }

    If (!WinExist("ahk_id " . hSelWnd)) {
        Gui SelWnd: New, hWndhSelWnd +ToolWindow -Border -Caption +E0x20 +OwnerAuto +LastFound -DPIScale
        Gui SelWnd: Color, 0xF0F0F0
        WinSet TransColor, 0xF0F0F0 100
        WinGetPos wX, wY, wW, wH, ahk_id %hChildWnd%
        Gui SelWnd: Show, NA x%wX% y%wY% w%wW% h%wH%
    }

    For Each, Item In SelectedControls {
        ControlGetPos cX, cY, cW, cH,, ahk_id %Item%
        Gui SelWnd: Add, Progress, c1BCDEF x%cX% y%cY% w%cW% h%cH%, 100
    }
}

SelectAllControls() {
    g.Selection := []
    For Each, Item In g.ControlList {
        If (g[Item].Deleted == False) {
            g.Selection.Push(Item)
        }
    }
    Select(g.Selection)
}

SelectTabItems(hTabControl) {
    g.Selection.Push(hTabControl)
    ControlGetPos tx, ty, tw, th,, ahk_id %hTabControl%
    TabItems := GetControlsFromRegion(tx + 1, ty + 1, (tx + tw), (ty + th))
    For Each, Item In TabItems {
        g.Selection.Push(Item)
    }
    Select(g.Selection)
}

DestroySelection() {
    DestroyWindow(hSelWnd)
    g.Selection := []
}

UpdateSelection() {
    DestroyWindow(hSelWnd)
    Select(g.Selection)
}

GetControlsFromRegion(x1, y1, x2, y2) {
    ControlsFromRegion := []

    If (x1 > x2) { ; Selection is from right to left
        x1 ^= x2, x2 ^= x1, x1 ^= x2
    }

    If (y1 > y2) { ; Selection is from bottom to top
        y1 ^= y2, y2 ^= y1, y1 ^= y2
    }

    WinGet Children, ControlListHwnd, ahk_id %hChildWnd%
    Loop Parse, Children, `n
    {
        If (g[A_LoopField].Class == "") {
            Continue
        }

        ControlGetPos CtrlX, CtrlY,,,, ahk_id %A_LoopField%

        If (IfBetween(CtrlX, x1, x2) And (IfBetween(CtrlY, y1, y2))) {
            ControlsFromRegion.Push(A_LoopField)
        }
    }

    Return ControlsFromRegion
}

IsInTab(x, y) {
    TabControls := []
    WinGet Controls, ControlList, ahk_id %hChildWnd%
    Loop Parse, Controls, `n
    {
        If (InStr(A_LoopField, "Tab")) {
            TabControls.Push(A_LoopField)
        }
    }

    For TabControl, Item In TabControls {
        ControlGetPos tx, ty, tw, th, %Item%, ahk_id %hChildWnd%
        If (IfBetween(x, tx, (tx + tw)) && (IfBetween(y, (ty + 1), (ty + th)))) {
            GuiControlGet TabIndex, %Child%:, %Item%
            Return [TabIndex, TabControl]
        }
    }
}

OrderTabItems() {
    TabControls := []
    TabItems := []
    Items := []

    For Index, Item In g.ControlList {
        If (g[Item].Type == "Tab2") {
            TabControls.Push(Item)
        } Else If (g[Item].Tab[1] != "") {
            TabItems[g[Item].Tab[2], g[Item].Tab[1], Index] := Item
        } Else {
            Items.Push(Item)
        }
    }

    OrderedList := []
    For i, TabControl In TabControls {
        OrderedList.Push(TabControl)
        For j, TabPage In TabItems[i] {
            For k, TabItem In TabItems[i][j] {
                OrderedList.Push(TabItems[i][j][k])
            }
        }
    }

    g.ControlList := Items

    For Each, Item In OrderedList {
        g.ControlList.Push(Item)
    }
}

DeleteSelectedControls() {
    Selection := GetSelectedItems()

    For Each, Item In Selection {
        RemoveControl(Item)
        If (Item == hReszdCtl) {
            HideResizers()
        }
    }

    GoSub ReloadControlList
    GenerateCode()
    g.Selection := []
    DestroySelection()
}

AlignLefts() {
    Gui %Child%: Default
    GuiControlGet p, Pos, % g.Selection[1]
    For Each, Item In g.Selection {
        GuiControl Move, %Item%, % "x" . px
        g[Item].x := px
    }
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

AlignRights() {
    Gui %Child%: Default
    GuiControlGet p, Pos, % g.Selection[1]
    For Each, Item In g.Selection {
        ControlGetPos,,, w,,, ahk_id %Item%
        x := (px + pw) - w
        GuiControl Move, % Item, % "x" . x
        g[Item].x := x
    }
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

AlignTops() {
    Gui %Child%: Default
    GuiControlGet p, Pos, % g.Selection[1]
    For Each, Item In g.Selection {
        GuiControl Move, % Item, % "y" . py
        g[Item].y := py
    }
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

AlignBottoms() {
    Gui %Child%: Default
    GuiControlGet p, Pos, % g.Selection[1]
    For Each, Item In g.Selection {
        ControlGetPos, ,,, h,, ahk_id %Item%
        y := (py + ph) - h
        GuiControl Move, % Item, % "y" . y
        g[Item].y := y
    }
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

CenterHorizontally() {
    WinGetPos,,, ww,, ahk_id %hChildWnd%

    Selection := GetSelectedItems()

    If (Selection.Length() > 1) {
        x1 := 1000000
        For Each, Item In Selection {
            ControlGetPos cx,,,,, ahk_id %Item%
            If (cx < x1) {
                x1 := cx
            }
        }
        x2 := 0
        For Each, Item In Selection {
            ControlGetPos cx,, cw,,, ahk_id %Item%
            If ((cx + cw) > x2) {
                x2 := cx + cw
            }
        }
        cw := x1 + x2
    } Else {
        ControlGetPos,,, cw,,, % "ahk_id " . Selection[1]
    }

    ww -= cw
    ww /= 2

    If (Selection.Length() > 1) {
        For Each, Item In Selection {
            ControlGetPos, cx,,,,, ahk_id %Item%
            ControlMove,, % ww + cx,,,, ahk_id %Item%
        }
    } Else {
        ControlMove,, % ww,,,, % "ahk_id " . Selection[1]
    }

    Repaint(hChildWnd)
    Properties_UpdateCtlPos()
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

CenterVertically() {
    GetClientSize(hChildWnd, ww, wh)
    Gui %Child%: Default

    Selection := GetSelectedItems()

    If (Selection.Length() > 1) {
        Min := 1000000
        For Each, Item In Selection {
            GuiControlGet c, Pos, %Item%
            If (cy < Min) {
                Min := cy
            }
        }
        Max := 0
        For Each, Item In Selection {
            GuiControlGet c, Pos, %Item%
            If ((cy + ch) > Max) {
                Max := cy + ch
            }
        }
        ch := Min + Max
    } Else {
        GuiControlGet c, Pos, % Selection[1]
    }

    wh := (wh - ch) / 2

    If (Selection.Length() > 1) {
        For Each, Item In Selection {
            GuiControlGet c, Pos, %Item%
            GuiControl Move, %Item%, % "y" . (wh + cy)
        }
    } Else {
        GuiControl Move, % Selection[1], y%wh%
    }

    Repaint(hChildWnd)
    Properties_UpdateCtlPos()
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

HorizontallySpace() {
    Gui %Child%: Default
    MaxIndex := g.Selection.Length()

    Start := 1000000, End := 0, ControlList := ""
    For Index, Item in g.Selection {
        ControlGetPos, x,, w,,, ahk_id %Item%
        If ((x + w) < Start) {
            Start := x + w
            FirstItem := Item
        }
        If (x > End) {
            End := x
            LastItem := Item
        }
        ControlList .= (Index != MaxIndex) ? Item . "|" : Item
    }

    InnerWidth := End - Start
    InnerItemsWidth := 0
    For Each, Item in g.Selection {
        If ((Item != FirstItem) && (Item != LastItem)) {
            ControlGetPos,,, w,,, ahk_id %Item%
            InnerItemsWidth += w
        }
    }
    EmptySpace := InnerWidth - InnerItemsWidth
    Quotient := EmptySpace // (MaxIndex - 1)

    Sort ControlList, D| F SortByX
    Controls := []
    Loop Parse, ControlList, `|
    {
        Controls.Push(A_LoopField)
    }

    For Index, Control in Controls {
        If ((Index != 1) && (Index != MaxIndex)) {
            GuiControlGet p, Pos, % Controls[(Index - 1)]
            GuiControl MoveDraw, % Control, % "x" . (px + pw) + Quotient
        }
    }

    GenerateCode()
    UpdateSelection()
    HideResizers()
}

VerticallySpace() {
    Gui %Child%: Default
    MaxIndex := g.Selection.Length()

    Start := 1000000, End := 0, ControlList := ""
    For Index, Item in g.Selection {
        ControlGetPos,, y,, h,, ahk_id %Item%
        If ((y + h) < Start) {
            Start := y + h
            FirstItem := Item
        }
        If (y > End) {
            End := y
            LastItem := Item
        }
        ControlList .= (Index != MaxIndex) ? Item . "|" : Item
    }

    InnerHeight := End - Start
    InnerItemsHeight := 0
    For Each, Item in g.Selection {
        If ((Item != FirstItem) && (Item != LastItem)) {
            ControlGetPos,,,, h,, ahk_id %Item%
            InnerItemsHeight += h
        }
    }
    EmptySpace := InnerHeight - InnerItemsHeight
    Quotient := EmptySpace // (MaxIndex - 1)

    Sort ControlList, D| F SortByY
    Controls := []
    Loop Parse, ControlList, `|
    {
        Controls.Push(A_LoopField)
    }

    For Index, Control in Controls {
        If ((Index != 1) && (Index != MaxIndex)) {
            GuiControlGet p, Pos, % Controls[(Index - 1)]
            GuiControl MoveDraw, % Control, % "y" . (py + ph) + Quotient
        }
    }

    GenerateCode()
    UpdateSelection()
    HideResizers()
}

SortByX(hCtl1, hCtl2) {
    ControlGetPos, x1,,,,, ahk_id %hCtl1%
    ControlGetPos, x2,,,,, ahk_id %hCtl2%
    Return (x1 > x2) ? 1 : 0
}

SortByY(hCtl1, hCtl2) {
    ControlGetPos,, y1,,,, ahk_id %hCtl1%
    ControlGetPos,, y2,,,, ahk_id %hCtl2%
    Return (y1 > y2) ? 1 : 0
}

MakeSameWidth:
    MakeSame("w")
Return

MakeSameHeight:
    MakeSame("h")
Return

MakeSameSize:
    MakeSame("wh")
Return

MakeSame(m) {
    Gui %Child%: Default
    ControlGetPos,,, w, h,, % "ahk_id " . g.Selection[1]
    Expression := ""
    If (InStr(m, "w")) {
        Expression .= "w" . w
    }
    If (InStr(m, "h")) {
        Expression .= "h" . h
    }
    For Each, Item In g.Selection {
        GuiControl Move, % Item, %Expression%
    }
    GenerateCode()
    UpdateSelection()
    HideResizers()
}

StretchHorizontally() {
    StretchControl("H")
}

StretchVertically() {
    StretchControl("V")
}

StretchControl(Mode := "H") {
    Gui %Child%: Default
    GetClientSize(hChildWnd, ww, wh)

    If (Mode == "H") {
        Expression := "x0 w" . ww
    } Else { ; Stretch Vertically
        y := 0
        TBHeight := 0
        SBHeight := 0

        If (ToolbarExist()) {
            ControlGetPos,,,, TBHeight,, ahk_id %hChildToolbar%
            ControlGet TBStyle, Style,,, ahk_id %hChildToolbar%
            y := ((TBStyle & 0x3) == 3) ? 0 : TBHeight ; CCS_BOTTOM
        }

        If (StatusBarExist()) {
            ControlGetPos,,,, SBHeight, msctls_statusbar321, ahk_id %hChildWnd%
        }

        Expression := "y" . y . " h" . (wh - TBHeight - SBHeight)
    }

    Selection := GetSelectedItems()
    For Each, Item In Selection {
        GuiControl Move, %Item%, %Expression%
    }

    GenerateCode()
    UpdateSelection()
    HideResizers()
}

ShowAdjustPositionDialog:
    GuiControlGet p, %Child%: Pos, %g_Control%

    Gui SizePosDlg: New, LabelSizePosDlg -MinimizeBox OwnerAuto
    Gui Font, s9, Segoe UI
    Gui Color, White

    Gui Add, GroupBox, x9 y2 w270 h107
    Gui Add, Text, x28 y28 w50 h23 +0x200, &X (Left):
    Gui Add, Edit, hWndhEdtX vEdtX x79 y28 w58 h22
    Gui Add, UpDown, gSizePosDlgApply Range-65536-65536 +0x80, %px%
    Gui Add, Text, x150 y28 w50 h23 +0x200, &Y (Top):
    Gui Add, Edit, vEdtY x201 y29 w58 h22
    Gui Add, UpDown, gSizePosDlgApply Range-65536-65536 +0x80, %py%
    Gui Add, Text, x28 y68 w50 h24 +0x200, &Width:
    Gui Add, Edit, vEdtW x79 y68 w58 h22
    Gui Add, UpDown, gSizePosDlgApply Range-65536-65536 +0x80, %pw%
    Gui Add, Text, x150 y68 w50 h24 +0x200, &Height:
    Gui Add, Edit, vEdtH x201 y68 w58 h22
    Gui Add, UpDown, gSizePosDlgApply Range-65536-65536 +0x80, %ph%

    Gui Add, Button, gSizePosDlgApply x289 y7 w86 h24 +Default, &Apply
    Gui Add, Button, gSizePosDlgReset x289 y45 w86 h24, &Reset
    Gui Add, Button, gSizePosDlgClose x289 y84 w86 h24, &Close

    Gui Show, w385 h117, Position and Size
    SetWindowIcon(WinExist("A"), IconLib, -70)
    SetModalWindow(1)
    SendMessage 0xB1, -1, 0,, ahk_id %hEdtX% ; EM_SETSEL
Return

SizePosDlgApply:
    Gui SizePosDlg: Submit, NoHide
    GuiControl %Child%: MoveDraw, %g_Control%, x%EdtX% y%EdtY% w%EdtW% h%EdtH%
    HideResizers()
Return

SizePosDlgReset:
    Gui SizePosDlg: Default
    GuiControl,, EdtX, %px%
    GuiControl,, EdtY, %py%
    GuiControl,, EdtW, %pw%
    GuiControl,, EdtH, %ph%
    GoSub SizePosDlgApply
Return

SizePosDlgEscape:
SizePosDlgClose:
    GenerateCode()
    Properties_UpdateCtlPos()
    SetModalWindow(0)
    Gui SizePosDlg: Destroy
Return

ChangeTitle:
    SetModalWindow(1)

    Title := UnescapeChars(g.Window.Title)
    NewTitle := InputBoxEx("Window Title", "", "Change Title", Title,,, hAutoWnd,,, IconLib, -37)

    If (!ErrorLevel) {
        WinSetTitle ahk_id %hChildWnd%,, %NewTitle%
        g.Window.Title := EscapeChars(NewTitle, True)
        GenerateCode()

        If (Properties_GetClassNN() == "Window") {
            GuiControl, Properties:, EdtText, %NewTitle%
        }
    }

    SetModalWindow(0)
Return

ChangeText:
    ChangeText(A_GuiControl == "BtnText" ? 1 : 0)
Return

ChangeText(Multiline := False) {
    CtlType := g[g_Control].Type

    If (CtlType ~= "TreeView|ActiveX|Separator") {
        Gui Auto: +OwnDialogs
        MsgBox 0x40, Change Text, Not available for %CtlType%.
        Return

    } Else If (CtlType == "Picture") {
        ImagePath := g[g_Control].Text
        ExtraOpts := g[g_Control].Extra
        ImageType := RegExMatch(ExtraOpts, "i)Icon(\d+)", IconIndex)

        If (ChoosePicture(ImagePath, IconIndex, ImageType)) {
            g[g_Control].Text := ImagePath

            If (ImageType) {
                If (InStr(ExtraOpts, "Icon")) {
                    g[g_Control].Extra := RegExReplace(ExtraOpts, "\+?Icon\d+", "+Icon" . IconIndex)
                } Else {
                    g[g_Control].Extra .= Space(ExtraOpts) . "+Icon" . IconIndex
                }
            } Else {
                g[g_Control].Extra := RegExReplace(ExtraOpts, "\+?Icon\d+")
            }

            Icon := (ImageType) ? "*Icon" . IconIndex . " " : ""
            GuiControl %Child%:, %g_Control%, % Icon . ImagePath
            GenerateCode()
        }
        Return
    }

    hParent := GetParent(g_Control)
    If (g[hParent].Type == "ComboBox") {
        g_Control := hParent
    }

    Instruction := Default[CtlType].DisplayName . " Text"
    Content := ""
    ControlText := UnescapeChars(g[g_Control].Text)
    InputControl := "Edit"
    If (Multiline && RegExMatch(CtlType, "^(Edit|Text|Button|CheckBox|Radio|Link|CommandLink)$")) {
        InputOptions := "Multi R3"
    } Else {
        InputOptions := ""
    }

    If (CtlType == "Text") {
        Instruction := "Text:"

    } Else If (CtlType == "Button") {
        InputControl := "ComboBox"
        ControlText := ControlText
        . "||&OK|&Cancel|&Apply|&Close|...|&Browse...|&Choose|&Change...|&Clear|&Reset|Select &All|&Options..."

    } Else If (CtlType ~= "ComboBox|DropDownList|ListBox") {
        Instruction := CtlType . " Items"
        Content := "Pipe-delimited list of items. To have one of the entries pre-selected, include two pipes after it (e.g. Red|Green||Blue)."

    } Else If (CtlType == "ListView") {
        Instruction := "ListView Columns"
        Content := "Pipe-delimited list of column names (e.g. ID|Name|Value):"

    } Else If (CtlType == "Tab2") {
        Instruction := "Tabs"
        Content := "Separate each tab item with a pipe character (|)."

    } Else If (CtlType ~= "Progress|Slider|UpDown") {
        Instruction := Default[CtlType].DisplayName . " Position"
        InputOptions := "Number"

    } Else If (CtlType == "Hotkey") {
        Instruction := "Hotkey"
        Content := "Modifiers: ^ = Control, + = Shift, ! = Alt.`nSee the <a href=""https://autohotkey.com/docs/KeyList.htm"">key list</a> for available key names."

    } Else If (CtlType == "DateTime") {
        Instruction := "Date Time Picker"
        Content := "Format: (e.g.: LongDate, Time, dd-MM-yyyy)"
        InputControl := "ComboBox"
        PreDefItems := StrReplace("|ShortDate|LongDate|Time", (ControlText != "") ? "|" . ControlText : "")
        ControlText .= "|" . PreDefItems

    } Else If (CtlType == "MonthCal") {
        Instruction := "Month Calendar"
        Content := "To have a date other than today pre-selected, specify it in YYYYMMDD format."

    } Else If (CtlType == "CommandLink") {
        InputOptions := "Multi r3"
    }

    SetModalWindow(1)

    NewText := InputBoxEx(Instruction
        , Content
        , "Change Text"
        , ControlText
        , InputControl
        , InputOptions
        , hAutoWnd
        , "", ""
        , IconLib, -38)

    If (!ErrorLevel) {
        SetControlText(g_Control, NewText)
        GenerateCode()
    }

    SetModalWindow(0)
}

SetControlText(hWnd, Text) {
    If (g[hWnd].Type == "Button" && Text == "...") {
        GuiControl %Child%: Move, %hWnd%, w23 h23
        Properties_UpdateCtlPos()
    }

    ; Unescape newline and tab
    StringReplace Text, Text, ``n, `n, A
    StringReplace Text, Text, ``t, `t, A

    If (g[hWnd].Type == "ListView") {
        Gui %Child%: Default
        Gui ListView, %hWnd%

        While (LV_GetText(foo, 0, 1)) {
            LV_DeleteCol(1)
        }

        Loop Parse, Text, |
        {
            LV_InsertCol(A_Index, "AutoHdr", A_LoopField)
        }
        LV_ModifyCol(1, "AutoHdr")

    } Else If (g[hWnd].Type ~= "Tab2|ListBox") {
        GuiControl %Child%:, %hWnd%, |%Text%

    } Else If (g[hWnd].Type == "DateTime") {
        GuiControl Text, %hWnd%, % (Text == "ShortDate") ? "" : Text

    } Else If (g[hWnd].Type == "CommandLink") {
        CLText := StrSplit(Text, "`n")
        GuiControl %Child%:, %hWnd%, % CLText[1]
        If (CLText.Length() > 1) {
            Note := StrReplace(Text, CLText[1] . "`n")
            SendMessage 0x1609, 0, % "" . Note,, ahk_id %hWnd% ; BCM_SETNOTE
            GuiControl %Child%: Move, %hWnd%, h58
            Properties_UpdateCtlPos()
        }

    } Else {
        GuiControl %Child%:, %hWnd%, %Text%
    }

    If (Properties_GetClassNN() == g[hWnd].ClassNN) {
        GuiControl, Properties:, EdtText, %Text%
    }

    g[hWnd].Text := EscapeChars(Text)
}

EscapeChars(String, Title := False) {
    String := RegExReplace(String, "``(?!n|t)", "````") ; Backtick (lookahead skips `n and `t)
    String := StrReplace(String, " `;", " ```;")        ; Comment
    StringReplace String, String, `%, ```%, A           ; %
    If (Title) {
        StringReplace String, String, `,, ```,, A       ; Comma
    } Else {
        StringReplace String, String, `n, ``n, A        ; Newline
        StringReplace String, String, `t, ``t, A        ; Tab
    }
    Return String
}

UnescapeChars(String) {
    String := StrReplace(String, "``%", "%")
    String := StrReplace(String, " ```;", " `;")
    String := StrReplace(String, "``,", ",")
    ;String := StrReplace(String, "````", "``")
    String := StrReplace(String, "``n", "`n")
    String := StrReplace(String, "``t", "`t")
    Return String
}

ChoosePicture(ByRef ImagePath, ByRef IconIndex, ByRef ImageType := 0) {
    If (!ImageType) {
        Filter := "*.jpg; *.png; *.gif; *.bmp; *.ico; *.icl; *.exe; *.dll; *.cpl; *.jpeg"
        Gui Auto: +OwnDialogs
        FileSelectFile SelectedFile, 1, %ImagePath%, Select Picture File, Picture Files (%Filter%)
        If (ErrorLevel) {
            Return
        }

        SplitPath SelectedFile,,, FileExt
        If (FileExt ~= "i)exe|dll|cpl|icl|scr|ocx|ax") {
            ImagePath := SelectedFile
            ImageType := 1
        } Else {
            ImagePath := SelectedFile
        }
    }

    If (ImageType) {
        If (ChooseIcon(ImagePath, IconIndex, hAutoWnd)) {
            ImagePath := IconPath := StrReplace(ImagePath, A_WinDir . "\System32\")
        } Else {
            Return
        }
    }

    Return 1
}

ShowActiveXDialog() {
    ActiveXComponent := InputBoxEx("ActiveX Component"
        , "Enter the identifier of an ActiveX object that can be embedded in a window.`nA folder path or an Internet address is loaded in Explorer."
        , "ActiveX"
        , "Shell.Explorer|HTMLFile|WMPlayer.OCX"
        , "ComboBox"
        , ""
        , hAutoWnd
        , "", ""
        , IconLib, -33)

    If (!ErrorLevel) {
        Default["ActiveX"].Text := ActiveXComponent
        g_Cross := True
    }
}

ShowCustomClassDialog() {
    ClassName := InputBoxEx("Win32 Control Class Name"
        , "Enter the name of a registered Win32 control class."
        , "Custom Class"
        , "Button|ComboBoxEx32|ReBarWindow32|ScrollBar|SysAnimate32|SysPager|SysTabControl32"
        , "ComboBox"
        , ""
        , hAutoWnd
        , "", ""
        , IconLib, -34)

    If (!ErrorLevel) {
        Default["Custom"].Options := "Class" . ClassName

        If (ClassName == "ComboBoxEx32") {
            Default["Custom"].Options .= " +0x3"
        } Else If (ClassName == "SysPager") {
            Default["Custom"].Options .= " +E0x20000"
        }

        g_Cross := True
    }
}

ToggleShowGrid:
    g_ShowGrid := !g_ShowGrid
    Repaint(hChildWnd)
    SendMessage TB_CHECKBUTTON, 1080, %g_ShowGrid%,, ahk_id %hToolbar%
    Menu AutoOptionsMenu, ToggleCheck, Show &Grid
Return

ToggleSnapToGrid:
    g_SnapToGrid := !g_SnapToGrid
    Menu AutoOptionsMenu, ToggleCheck, S&nap To Grid
    SendMessage TB_CHECKBUTTON, 1090, %g_SnapToGrid%,, ahk_id %hToolbar%
Return

Repaint(hWnd) {
    WinSet Redraw,, ahk_id %hWnd%
}

RedrawWindow:
    WinSet Redraw,, ahk_id %hChildWnd%
    WinSet Redraw,, ahk_id %hAutoWnd%
Return

CreateResizers() {
    g_ResizerColor := DllCall("User32.dll\GetSysColor", "UInt", 13, "UInt")
    g_ResizerBrush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", g_ResizerColor, "UPtr")

    Gui %Child%: Default
    g_Resizers := []
    Loop 8 {
        Gui Add, Text, x0 y0 w%g_ResizerSize% h%g_ResizerSize% hWndhResizer%A_Index% +0x100 Hidden
        g_Resizers.Push(hResizer%A_Index%)
    }

    g_Cursors := {(hResizer1): 32642, (hResizer2): 32645, (hResizer3): 32643, (hResizer4): 32643, (hResizer5): 32645, (hResizer6): 32642, (hResizer7): 32644, (hResizer8): 32644}
}

ShowResizers() {
    Local Item
    Gui %Child%: Default
    GuiControlGet p, Pos, %g_Control%

    GuiControl Movedraw, %hResizer1%, % "x" . (px - g_ResizerSize) . "y" . (py - g_ResizerSize)
    GuiControl MoveDraw, %hResizer2%, % "x" . (px + ((pw - g_ResizerSize) / 2)) . "y" . (py - g_ResizerSize)
    GuiControl MoveDraw, %hResizer3%, % "x" . (px + pw) . "y" . (py - g_ResizerSize)

    GuiControl MoveDraw, %hResizer4%, % "x" . (px - g_ResizerSize) . "y" . (py + ph)
    GuiControl MoveDraw, %hResizer5%, % "x" . (px + ((pw - g_ResizerSize) / 2)) . "y" . (py + ph)
    GuiControl MoveDraw, %hResizer6%, % "x" . (px + pw) . "y" . (py + ph)

    GuiControl MoveDraw, %hResizer7%, % "x" . (px - g_ResizerSize) . "y" . (py + ((ph - g_ResizerSize) / 2))
    GuiControl MoveDraw, %hResizer8%, % "x" . (px + pw) . "y" . (py + ((ph - g_ResizerSize) / 2))

    For Each, Item in g_Resizers {
        GuiControl Show, %Item%
    }

    hReszdCtl := g_Control
}

HideResizers() {
    Local Item
    Gui %Child%: Default
    For Each, Item in g_Resizers {
        GuiControl Hide, %Item%
    }
}

IsResizer(hWnd) {
    Loop 8 {
        If (hWnd == g_Resizers[A_Index]) {
            Return True
        }
    }
    Return False
}

OnResize(hWnd) {
    Gui %Child%: Default
    CoordMode Mouse, Client
    MouseGetPos omx, omy
    GuiControlGet oc, %Child%: Pos, %hReszdCtl%
    ncx := ncy := ncw := nch := 0

    hDC := DllCall("User32.dll\GetDC", "Ptr", hChildWnd, "UPtr")
    VarSetCapacity(RECT, 16, 0)

    If (hWnd == hResizer1) { ; x+y+w+h (NW)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := och - (my - ocy)
            ncw := ocw - (mx - ocx)
            If (mx = omx) ; Prevent flicker while redrawing the focus rect
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, mx, my, ncw + mx, nch + my)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            omx := mx
        }
        ncx := mx, ncy := my
    } Else If (hWnd == hResizer2) { ; y+h (N)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := och - (my - ocy)
            If (oldmy = my)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, ocx - 1, my, ocw + ocx + 1, my + nch + 1)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            oldmy := my
        }
        ncx := ocx, ncy := my, ncw := ocw
    } Else If (hWnd == hResizer3) { ; y+w+h (NE)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := och - (my - ocy)
            ncw := mx - ocx + g_ResizerSize
            If (mx = omx)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, ocx - 1, my - 1, ncw + ocx + 1, nch + my + 1)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            omx := mx
        }
        ncx := ocx, ncy := my
    } Else If (hWnd == hResizer4) { ; x+w+h (SW)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := ocy + (my - ocy)
            ncw := ocw - (mx - ocx)
            If (mx = omx)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, mx, ocy, ncw + mx, nch)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            omx := mx
        }
        ncx := mx, ncy := ocy, nch := nch - ocy
    } Else If (hWnd == hResizer5) { ; h (S)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := ocy + (my - ocy)
            If (oldmy = my)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, ocx, ocy, ocw + ocx - 2, nch)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            oldmy := my
        }
        ncx := ocx, ncy := ocy,  ncw := ocw, nch := nch - ocy
    } Else If (hWnd == hResizer6) { ; w+h (SE)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx, my
            nch := ocy + (my - ocy)
            ncw := ocx + (mx - ocx)
            If ((nch = och) && (ncw = ocw))
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, ocx, ocy, ncw, nch)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            och := nch, ocw := ncw
        }
        ncx := ocx, ncy := ocy, nch := nch - ocy, ncw := ncw - ocx
    } Else If (hWnd == hResizer7) { ; x+w (W)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx
            ncw := ocw - (mx - ocx)
            If (mx = oldmx)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, mx, ocy, ncw + mx, och + ocy)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            oldmx := mx
        }
        ncx := mx, ncy := ocy, nch := och
    } Else If (hWnd == hResizer8) { ; w (E)
        While (GetKeyState("LButton", "P")) {
            MouseGetPos mx
            ncw := ocw - (omx - mx)
            If (ncw = oldncw)
                Continue
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            SetRect(RECT, ocx, ocy, ncw + ocx, och + ocy)
            DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT)
            oldncw := ncw
        }
       ncx := ocx, ncy := ocy, nch := och
    }

    DllCall("User32.dll\DrawFocusRect", "Ptr", hDC, "Ptr", &RECT) ; Remove the focus rect
    DllCall("User32.dll\ReleaseDC", "Ptr", hChildWnd, "Ptr", hDC)

    MouseGetPos mx, my
    If ((mx != omx) || (my != omy)) {
        NewPos := "x" . ncx . "y" . ncy . "w" . ncw . "h" . nch
        GuiControl MoveDraw, %hReszdCtl%, %NewPos%
        g_Control := hReszdCtl
        g[g_Control].x := ncx
        g[g_Control].y := ncy
        g[g_Control].w := ncw
        g[g_Control].h := nch
        GenerateCode()
        ShowResizers()
        Properties_UpdateCtlPos()
    }
}

SetRect(ByRef RECT, x, y, w, h) {
    DllCall("SetRect", "Ptr", &RECT, "UInt", x, "UInt", y, "UInt", w, "UInt", h)
}

ShowChildWindow:
    ShowChildWindow()
Return

; -1: Toggle, 0: Hide, 1: Show
ShowChildWindow(Param := -1) {
    If (Param == -1) {
        Param := !IsWindowVisible(hChildWnd)
    }

    ShowWindow(hChildWnd, Param)
    ShowWindow(hSelWnd, Param)
}

InsertControl:
    AddControl(A_ThisMenuItem)
    g_Adding := False
Return

BlinkBorder:
    BlinkBorder(g_Control)
Return

BlinkBorder(hWnd, Duration := 500, Color := "0x3FBBE3", BorderSize := 4) {
    Local X, Y, W, H, Index, r

    VarSetCapacity(RECT, 16, 0)
    DllCall("GetWindowRect", "Ptr", hWnd ? hWnd : hChildWnd, "Ptr", &RECT)
    X := NumGet(RECT, 0, "Int")
    Y := NumGet(RECT, 4, "Int")
    w := NumGet(RECT, 8, "Int") - X
    H := NumGet(RECT, 12, "Int") - Y

    Loop 4 {
        Index := A_Index + 90
        Gui %Index%: -Caption +ToolWindow +AlwaysOnTop
        Gui %Index%: Color, %Color%
    }

    r := BorderSize
    Gui 91: Show, % "NA x" (x - r) " y" (y - r) " w" (w + r + r) " h" r
    Gui 92: Show, % "NA x" (x - r) " y" (y + h) " w" (w + r + r) " h" r
    Gui 93: Show, % "NA x" (x - r) " y" y " w" r " h" h
    Gui 94: Show, % "NA x" (x + w) " y" y " w" r " h" h

    Sleep %Duration%

    Loop 4 {
        Index := A_Index + 90
        Gui %Index%: Destroy
    }
}

ShowContextMenu:
    g_Control := Properties_GetHandle()
    ShowContextMenu()
Return

ShowContextMenu() {
    Try {
        Menu ControlOptionsMenu, DeleteAll
    } Catch { ; ?
        Menu ControlOptionsMenu, DeleteAll
    }

    Items := Default[g[g_Control].Type].Menu
    CtlOpts := StrSplit(g[g_Control].Options, " ")

    For Each, Item in Items {
        Menu ControlOptionsMenu, Add, %Item%, MenuSetCtlOption
        Loop % CtlOpts.Length() {
            If (CtlOpts[A_Index] == g_ControlOptions[Item]) {
                Menu ControlOptionsMenu, Check, %Item%
            }
        }
    }

    If (g[g_Control].ExplorerTheme) {
        Menu ControlOptionsMenu, Check, Explorer Theme
    } Else If (g[g_Control].UACShield) {
        Menu ControlOptionsMenu, Check, UAC Shield
    }

    Menu ControlContextMenu, Show
}

GetControlType(DisplayName) {
    Static Types := {0:0
,   "Date Time Picker": "DateTime"
,   "Drop-Down List": "DropDownList"
,   "Edit Box": "Edit"
,   "Hotkey Box": "Hotkey"
,   "Month Calendar": "MonthCal"
,   "Progress Bar": "Progress"
,   "Radio Button": "Radio"
,   "Status Bar": "StatusBar"
,   "Tab": "Tab2"
,   "Custom Class": "Custom"
,   "Command Link": "CommandLink"}
    Type := Types[DisplayName]
    Return (Type != "" ? Type : DisplayName)
}

MoveByKey(Direction) {
    DestroyWindow(hSelWnd)
    HideResizers()

    Selection := GetSelectedItems()

    Inc := (GetKeyState("Ctrl", "P")) ? g_GridSize : 1

    If (Direction == "Left") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "x" . px - Inc
        }
    } Else If (Direction == "Up") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "y" . py - Inc
        }
    } Else If (Direction == "Right") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "x" . px + Inc
        }
    } Else If (Direction == "Down") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "y" . py + Inc
        }
    }
}

ResizeByKey(Direction) {
    DestroyWindow(hSelWnd)
    HideResizers()

    Selection := GetSelectedItems()

    Inc := (GetKeyState("Ctrl", "P")) ? g_GridSize : 1

    If (Direction == "Left") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "w" . pw - Inc
        }
    } Else If (Direction == "Up") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "h" . ph - Inc
        }
    } Else If (Direction == "Right") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "w" . pw + Inc
        }
    } Else If (Direction == "Down") {
        For Each, Item in Selection {
            GuiControlGet p, %Child%: Pos, %Item%
            GuiControl %Child%: MoveDraw, %Item%, % "h" . ph + Inc
        }
    }
}
