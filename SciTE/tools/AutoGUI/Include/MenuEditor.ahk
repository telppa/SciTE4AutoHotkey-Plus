Class MenuBar {
    Code := ""

    Class Item {
        ParentID := 0
        DisplayName := ""
        Command := ""
        Items := []
    }

    Register(ParentID, ID, Text, Label, SubMenu := 0, Hotkey := "", Flags := 0, Icon := "", Index := 1) {
        this[ID] := New m.Item
        this[ID].ParentId := ParentId
        this[ID].DisplayName := Text
        this[ID].Command := Label
        this[ID].SubMenu := SubMenu
        this[ID].Hotkey := this.ConvertHotkey(Hotkey)
        this[ID].AhkHotkey := Hotkey
        this[ID].Text := DisplayName . ((Hotkey != "") ? "`t" . this[ID].Hotkey : "")
        this[ID].Flags := Flags
        this[ID].Icon := Icon
        this[ID].IconIndex := Index
        this[ParentID].Items.Push(ID)
    }

    ConvertHotkey(Hotkey) {
        StringUpper Hotkey, Hotkey, T
        StringReplace Hotkey, Hotkey, +, Shift+
        StringReplace Hotkey, Hotkey, ^, Ctrl+
        StringReplace Hotkey, Hotkey, !, Alt+
        StringReplace Hotkey, Hotkey, Shift+Ctrl, Ctrl+Shift
        Return Hotkey
    }
}

ShowMenuEditor:
    If (!WinExist("ahk_id " . hMenuEditor)) {
        Gui MenuEditor: New, LabelMenuEditor hWndhMenuEditor +Resize +MinSize373x416
        SetWindowIcon(hMenuEditor, IconLib, 58)

        Gui Font, s9, Segoe UI

        Gui Add, Tab3
        , vMenuType gMenuTabHandler x8 y8 w251 h400 AltSubmit %g_ThemeFix%, Menu Bar|Context Menu|Tray Menu

        Gui Tab, 1
        Gui Add, TreeView, hWndhTV1 vMenuTV1 gTreeViewHandler x15 y36 w236 h364 -E0x200
        Global MenuBarId := TV_Add("Menu Bar", 0, "Bold")
        m.Register(0, MenuBarId, "Menu Bar", "MenuBar", True)
        Gui Tab, 2
        Gui Add, TreeView, hWndhTV2 vMenuTV2 TreeViewHandler x15 y36 w236 h364 -E0x200
        Global ContextMenuId := TV_Add("Context Menu", 0, "Bold")
        m.Register(0, ContextMenuId, "Context Menu", "ContextMenu", True)
        Gui Tab, 3
        Gui Add, TreeView, hWndhTV3 vMenuTV3 TreeViewHandler x15 y36 w236 h340 -E0x200
        Global TrayMenuId := TV_Add("Tray Menu", 0, "Bold")
        m.Register(0, TrayMenuId, "Tray Menu", "Tray", True)
        Gui Add, CheckBox, vNoStandard x18 y379 w234 h23, Remove all &standard tray menu items
        Gui Tab

        Gui Add, GroupBox, x265 y21 w101 h111 Disabled +0x1000
        Gui Add, Button, gAddMenu x276 y37 w80 h23 Default, &Add Menu
        Gui Add, Button, gEditMenu x276 y67 w80 h23, &Edit
        Gui Add, Button, gRemoveMenu x276 y97 w80 h23, &Remove

        Gui Add, GroupBox, x265 y132 w101 h80 Disabled +0x1000
        Gui Add, Button, gMoveItem x276 y148 w80 h23, Move &Up
        Gui Add, Button, gMoveItem x276 y178 w80 h23, Move &Down

        Gui Add, GroupBox, x265 y276 w101 h51 Disabled +0x1000
        Gui Add, Button, gMenuEditorContextMenu x276 y293 w80 h23, &Preview

        Gui Add, GroupBox, x265 y328 w101 h80 Disabled +0x1000
        Gui Add, Button, gSetMenu x276 y345 w80 h23, &OK
        Gui Add, Button, gMenuEditorClose x276 y375 w80 h23, &Cancel
        Gui Font
        Gui Show, w373 h416, Menu Editor

        If (g_NT6orLater) {
            Loop 3 {
                DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hTV%A_Index%, "WStr", "Explorer", "Ptr", 0)
            }
        }
    } Else {
        Gui MenuEditor: Show
    }
Return

MenuEditorEscape:
MenuEditorClose:
    Gui MenuEditor: Hide
Return

MenuTabHandler:
    Gui MenuEditor: Submit, NoHide
Return

AddMenu:
    Gui MenuEditor: Submit, NoHide
    Gui MenuEditor: +Disabled

    Gui TreeView, MenuTV%MenuType%
    SelectedID := TV_GetSelection()

    If (!m[SelectedID].SubMenu) {
        Gui MenuEditor: +OwnDialogs
        MsgBox 0x30, Menu Editor, The Selected item is not a menu or submenu.
        Gui MenuEditor: -Disabled
        Return
    }

    If (SelectedID == MenuBarId) {
        GoSub ShowAddMenuDlg
    } Else {
        GoSub ShowAddMenuItemDlg
    }
Return

EditMenu:
    Gui MenuEditor: Submit, NoHide
    Gui MenuEditor: +Disabled

    Gui TreeView, MenuTV%MenuType%
    SelectedId := TV_GetSelection()
    ParentId := TV_GetParent(SelectedId)

    If (SelectedId == MenuBarId || ParentId == MenuBarId || SelectedId == ContextMenuId) {
        GoSub ShowAddMenuDlg
    } Else If (SelectedId == TrayMenuId) {
        Gui MenuEditor: -Disabled
        Return
    } Else {
        GoSub ShowAddMenuItemDlg
    }
Return

ShowAddMenuDlg:
    If (A_GuiControl == "&Add Menu") {
        Title := "Add Menu"
        DisplayName := "&File"
        MenuName := "FileMenu"
    } Else {
        Title := "Edit Menu"
        Id := TV_GetSelection()
        TV_GetText(DisplayName, Id)
        MenuName := m[Id].Command
    }

    Gui AddMenuDlg: New, +LabelAddMenuDlg -MinimizeBox +OwnerMenuEditor
    Gui Color, White
    Gui Font, s9, Segoe UI
    Gui Add, GroupBox, x8 y4 w284 h99
    Gui Add, Text, x19 y31 w79 h23, Menu Text:
    Gui Add, Edit, vDisplayName gSuggestMenuName x109 y27 w170 h23, %DisplayName%
    Gui Add, Text, x19 y65 w81 h23, Menu Name:
    Gui Add, Edit, vMenuName x109 y61 w170 h22, %MenuName%
    Gui Add, Text, x-1 y113 w302 h48 -Background +Border
    Gui Add, Button, gAddMenuOK x125 y126 w80 h24 +Default, OK
    Gui Add, Button, gAddMenuDlgClose x212 y126 w80 h24, Cancel
    Gui Show, w300 h160, %Title%
Return

SuggestMenuName:
    Gui AddMenuDlg: Submit, NoHide
    Suggestion := RegExReplace(DisplayName, "\W")
    GuiControl,, MenuName, % Suggestion . "Menu"
Return

AddMenuOK:
    Gui AddMenuDlg: Submit, NoHide
    WinGetTitle Title, A

    Gui MenuEditor: Default
    If (Title == "Add Menu") {
        Id := TV_Add(DisplayName, MenuBarId)
        m.Register(MenuBarId, Id, DisplayName, MenuName, True)
        TV_Modify(Id, "Select")
    } Else {
        Id := TV_GetSelection()
        TV_Modify(Id, "", DisplayName)
        m[Id].DisplayName := DisplayName
        m[Id].Command := MenuName
    }
AddMenuDlgEscape:
AddMenuDlgClose:
    Gui MenuEditor: -Disabled
    Gui AddMenuDlg: Hide
Return

; Menu Editor OK button
SetMenu:
    If (!WinExist("ahk_id" . hChildWnd)) {
        GoSub NewGUI
    }

    Gui %Child%: Default
    Global MenuCode := ""
    g_MenuFuncs := ""
    g_MenuHandler := False

    ; Menu bar
    m.Code := CreateMenu(m[MenuBarId].Items)
    If (m.Code != "") {
        MenuName := m[MenuBarId].Command
        Gui Menu, % MenuName
        m.Code .= "Gui Menu, " . MenuName . CRLF
    } Else {
        Gui %Child%: Menu
    }
    MenuCode := ""

    ; Context menu
    m.Context := CreateMenu(m[ContextMenuId].Items)
    If (m.Context != "") {
        g.Window.GuiContextMenu := True
        GuiControl Properties:, ChkGuiContextMenu, 1
    }
    m.Code .= m.Context
    MenuCode := ""

    ; Tray menu
    m.Tray := CreateMenu(m[TrayMenuId].Items)
    If (m.Tray != "") {
        Gui MenuEditor: Submit, NoHide
        If (NoStandard) {
            m.Tray := "Menu Tray, NoStandard" . CRLF . m.Tray
        }
    }
    m.Code .= m.Tray
    MenuCode := ""

    GenerateCode()

    Gui MenuEditor: Hide
Return

CreateMenu(Items) {
    For Each, Item in Items {
        Parent := m[m[Item].ParentId].Command

        If (m[Item].DisplayName == "----------") { ; Separator
            Menu, %Parent%, Add
            MenuCode .= "Menu " . Parent . ", Add" . CRLF
            Continue
        }

        If (m[Item].Items.MaxIndex() != "") {
            Try {
                Menu % m[Item].Command, Delete
            }
            CreateMenu(m[Item].Items)
            Command := ":" . m[Item].Command
        } Else {
            Command := m[Item].Command
        }

        If (m[Item].Hotkey != "") {
            If (m[Item].Hotkey == "Escape" || m[Item].Hotkey == "Delete") {
                m[Item].Hotkey := SubStr(m[Item].Hotkey, 1, 3)
            }
            MenuText := m[Item].DisplayName . "`t" . m[Item].Hotkey
            CodeText := m[Item].DisplayName . "``t" . m[Item].Hotkey
        } Else {
            MenuText := CodeText := m[Item].DisplayName
        }

        Options := (m[Item].Flags.Radio) ? "Radio" : ""

        Menu %Parent%, Add, %MenuText%, % (SubStr(Command, 1, 1) == ":") ? Command : "MenuHandler", %Options%
        MenuCode .= "Menu " . Parent . ", Add, " . CodeText . ", " . Command
        MenuCode .= (Options != "") ? ", " . Options : ""
        MenuCode .= CRLF

        If (m[Item].Flags.Disabled) {
            Menu %Parent%, Disable, %MenuText%
            MenuCode .= "Menu " . Parent . ", Disable, " . CodeText . CRLF
        } Else {
            Menu %Parent%, Enable, %MenuText%
        }
        If (m[Item].Flags.Checked) {
            Menu %Parent%, Check, %MenuText%
            MenuCode .= "Menu " . Parent . ", Check, " . CodeText . CRLF
        } Else {
            Menu %Parent%, Uncheck, %MenuText%
        }
        If (m[Item].Flags.Default) {
            Menu %Parent%, Default, %MenuText%
            MenuCode .= "Menu " . Parent . ", Default, " . CodeText . CRLF
        }

        If (m[Item].Icon != "") {
            Menu, %Parent%, Icon, %MenuText%, % m[Item].Icon, % m[Item].IconIndex
            MenuCode .= "Menu " . Parent . ", Icon, " . CodeText . ", " . m[Item].Icon
            If (m[Item].IconIndex != 1) {
                MenuCode .= ", " . m[Item].IconIndex
            }
            MenuCode .=  CRLF
        }

        ; Generate labels/functions
        If !(m[Item].SubMenu) {

            If !(g_MenuHandler && m[Item].Command == "MenuHandler") {
                g_MenuFuncs .= CRLF . m[Item].Command . ":" . CRLF . "Return" . CRLF                
            }

            If (m[Item].Command == "MenuHandler") {
                g_MenuHandler := True
            }
        }
    }

    Return MenuCode
}

; Preview
MenuEditorContextMenu:
    Gui MenuEditor: Submit, NoHide
    Gui TreeView, MenuTV%MenuType%

    If (MenuType == 1) {
        Try {
            Menu % m[MenubarId].Command, Delete
        }
        CreateMenu(m[MenuBarId].Items)
        Try {
            Menu % m[MenuBarId].Command, Show
        }
    } Else If (MenuType == 2) {
        Try {
            Menu % m[ContextMenuId].Command, Delete
        }
        CreateMenu(m[ContextMenuId].Items)
        Try {
            Menu % m[ContextMenuId].Command, Show
        }
    } Else {
        Menu Tray, DeleteAll
        If (NoStandard) {
            Menu Tray, NoStandard
        } Else {
            Menu Tray, Standard
        }
        CreateMenu(m[TrayMenuId].Items)
        Menu % m[TrayMenuId].Command, Show
    }
Return

ShowAddMenuItemDlg:
    ID := TV_GetSelection()

    If (A_GuiControl == "&Add Menu") {
        Title := "Add Menu Item"
        DisplayName := ""
        Command := ""
        SubMenu := False
        Hotkey := ""
        Icon := ""
        IconIndex := ""
    } Else { ; &Edit
        Title := "Edit Menu Item"
        DisplayName := m[Id].DisplayName
        Command := m[Id].Command
        SubMenu := m[Id].SubMenu
        Hotkey := m[Id].AhkHotkey
        Icon := m[Id].Icon
        IconIndex := m[Id].IconIndex
    }

    Disabled := m[Id].Flags.Disabled ? True : False
    Checked := m[Id].Flags.Checked ? True : False
    Radio := m[Id].Flags.Radio ? True : False
    Bold := m[Id].Flags.Default ? True : False

    Gui AddMenuItemDlg: New, +LabelAddMenuItemDlg +hWndhAddMenuItemDlg +OwnerMenuEditor -MinimizeBox
    Gui Color, 0xFEFEFE
    Gui Font, s9, Segoe UI

    Gui Add, GroupBox, x10 y6 w384 h230
    Gui Add, Text, x25 y26 w75 h23 +0x200, Menu Text:
    Gui Add, ComboBox, hWndhDisplayName vMenuDisplayName x102 y27 w200, <SEPARATOR>
    GuiControl Text, MenuDisplayName, %DisplayName%

    Gui Add, Text, vLabelOrSubMenu x25 y64 w75 h23 +0x200, % (SubMenu) ? "Menu Name:" : "Label:"
    Gui Add, Edit, hWndhCommandEdt vMenuCommand x102 y65 w200 h22, %Command%
    Gui Add, CheckBox, vChkSubMenu gChangeMenuType x310 y65 w75 h23 Checked%SubMenu%, Submenu

    Gui Add, Text, x25 y102 w75 h23 +0x200, Keyboard:
    Gui Add, Hotkey, vMenuHotkey x102 y104 w200 h22, %Hotkey%
    Gui Add, Button, gMenuClearHotkey x308 y103 w75 h23, Clear

    Gui Add, Text, x25 y144 w75 h23 +0x200, Icon Path:
    Gui Add, ComboBox, hWndhCbxMenuIcon vMenuIcon x102 y144 w200, shell32.dll|imageres.dll
    SendMessage 0x0153, -1, 16,, ahk_id%hCbxMenuIcon% ; CB_SETITEMHEIGHT
    GuiControl Text, MenuIcon, %Icon%
    Gui Add, Edit, vMenuIconIndex x308 y144 w48 h22, %IconIndex%
    Gui Add, Button, gChooseMenuIcon x360 y143 w23 h22, ...

    Gui Add, GroupBox, x10 y178 w384 h58, State
    Gui Add, CheckBox, vMenuChecked x42 y199 w75 h23 Checked%Checked%, Chec&ked
    Gui Add, CheckBox, vMenuRadio x129 y199 w75 h23 Checked%Radio%, &Radio
    Gui Add, CheckBox, vMenuDefault x214 y199 w75 h23 Checked%Bold%, D&efault
    Gui Add, CheckBox, vMenuDisabled x305 y199 w73 h23 Checked%Disabled%, &Disabled

    Gui Add, Text, x-1 y250 w408 h48 -Background +Border

    If (A_GuiControl == "&Add Menu") {
        Gui Add, Button, gNextMenuItem x142 y262 w80 h24, &Next
    }

    Gui Add, Button, gAddMenuItem x229 y262 w80 h24, &OK
    Gui Add, Button, gAddMenuItemDlgClose x316 y262 w80 h24, &Cancel

    GuiControl +Default, % A_GuiControl == "&Add Menu" ? "&Next" : "&OK"

    Gui Add, Button, hWndhBtnExamples gShowExamplesMenu x308 y26 w75 h23, Examples
    If (g_NT6orLater) {
        Control Style, +0xC,, ahk_id%hBtnExamples% ; BS_SPLITBUTTON
    }

    Gui Show, w405 h297, %Title%
Return

AddMenuItemDlgEscape:
AddMenuItemDlgClose:
    Gui MenuEditor: -Disabled
    Gui AddMenuItemDlg: Hide
Return

; Add Menu Item dialog OK/Next button
AddMenuItem:
NextMenuItem:
    Gui AddMenuItemDlg: Submit, NoHide

    If (MenuCommand == "") {
        If (ChkSubMenu) {
            Edit_ShowBalloonTip(hCommandEdt, "This field cannot be left blank")
            Return
        } Else {
            MenuCommand := "MenuHandler"
        }
    }

    If (ChkSubMenu && !IsMenuNameAvailable(MenuCommand)) {
        Message := "A menu named """ . MenuCommand . """ already exists."
        Edit_ShowBalloonTip(hCommandEdt, Message, "Invalid menu name", 3)
        Return
    }

    If (A_ThisLabel == "AddMenuItem") {
        Gui MenuEditor: -Disabled
        Gui AddMenuItemDlg: Hide
    }

    If (MenuDisplayName == "") {
        Return
    }

    If (MenuDisplayName == "-" || MenuDisplayName == "<SEPARATOR>") {
        MenuDisplayName := "----------"
    }

    Flags := {"Checked" : MenuChecked
            , "Radio"   : MenuRadio
            , "Default" : MenuDefault
            , "Disabled": MenuDisabled}

    Gui MenuEditor: Default

    WinGetTitle Title, ahk_id %hAddMenuItemDlg%

    If (Title == "Add Menu Item") {
        ParentId := TV_GetSelection()
        Id := TV_Add(MenuDisplayName, ParentId)

        m.Register(TV_GetParent(Id), Id, MenuDisplayName, MenuCommand, ChkSubMenu, MenuHotkey, Flags, MenuIcon, MenuIconIndex)

        If (m[ParentId].Command == "MenuHandler") {
            m[ParentId].Command := RegExReplace(m[ParentId].DisplayName, "\W") . "Menu"
        }

        TV_Modify(ParentId, "Expand")
    } Else {
        Id := TV_GetSelection()
        TV_Modify(Id, "", MenuDisplayName)
        m[Id].DisplayName := MenuDisplayName
        m[Id].Command := MenuCommand
        m[ID].SubMenu := ChkSubMenu
        m[Id].Hotkey := m.ConvertHotkey(MenuHotkey)
        m[Id].AhkHotkey := MenuHotkey
        m[Id].Text := MenuDisplayName . ((MenuHotkey != "") ? "`t" . MenuHotkey : "")
        m[Id].Icon := MenuIcon
        m[Id].IconIndex := MenuIconIndex
        m[Id].Flags := Flags
    }

    ResetMenuItemDlg()

    If (A_ThisLabel == "NextMenuItem") {
        ControlFocus,, ahk_id %hDisplayName%
    }
Return

ChooseMenuIcon:
    Gui AddMenuItemDlg: Submit, NoHide
    IconResource := (MenuIcon != "") ? MenuIcon : g_IconPath
    IconIndex := MenuIconIndex
    If (ChooseIcon(IconResource, IconIndex, hAddMenuItemDlg)) {
        StringReplace IconResource, IconResource, %A_WinDir%\System32\
        GuiControl AddMenuItemDlg: Text, MenuIcon, %IconResource%
        GuiControl AddMenuItemDlg:, MenuIconIndex, %IconIndex%
        g_IconPath := IconResource
    }
Return

RemoveMenu:
    Gui MenuEditor: Submit, NoHide
    Gui TreeView, MenuTV%MenuType%

    Gui MenuEditor: Default

    Id := TV_GetSelection()
    If (Id == 0 || Id == MenuBarId || Id == ContextMenuId || Id == TrayMenuId) {
        ParentId := Id
        Items := m[Id].Items
    } Else {
        ParentId := TV_GetParent(Id)
        Items := m[ParentId].Items
    }

    If (m[Id].Items.MaxIndex() == "") {
        For Each, Item in Items {
            If (Items[A_Index] = Id) {
                m[ParentId].Items.Remove(A_Index)
                If (m[Id].DisplayName == "----------") {
                    If (MenuType == 1) {
                        Try {
                            Menu % m[MenubarId].Command, Delete
                        }
                        CreateMenu(m[MenuBarId].Items)
                    } Else If (MenuType == 2) {
                        Try {
                            Menu % m[ContextMenuId].Command, Delete
                        }
                        CreateMenu(m[ContextMenuId].Items)
                    } Else {
                        Menu Tray, DeleteAll
                        CreateMenu(m[TrayMenuId].Items)
                    }
                } Else {
                    Try {
                        Menu, % m[ParentId].Command, Delete, % m[Id].Text
                    }
                }
            }
        }
    } Else { ; Submenu
        For Index, Item in Items {
            If (m[ParentId].Items[Index] = Id) {
                m[ParentId].Items.Remove(Index)
                Menu, % m[ParentId].Command, Delete, % m[Id].Text
            }
        }
    }

    If (TV_GetParent(Id) == 0) {
        If (MenuType == 1) {
            MenuBarId := TV_Add("Menu Bar", 0, "Bold")
            m.Register(0, MenuBarId, "Menu Bar", "MenuBar", True)
        } Else If (MenuType == 2) {
            ContextMenuId := TV_Add("Context Menu", 0, "Bold")
            m.Register(0, ContextMenuId, "Context Menu", "ContextMenu", True)
        } Else {
            TrayMenuId := TV_Add("Tray Menu", 0, "Bold")
            m.Register(0, TrayMenuId, "Tray Menu", "Tray", True)
        }
    }

    TV_Delete(Id)
Return

MoveItem:
    Gui MenuEditor: Submit, NoHide

    Gui TreeView, MenuTV%MenuType%
    Item := TV_GetSelection()
    TV_GetText(ItemText, Item)
    Parent := TV_GetParent(Item)

    If (A_GuiControl = "Move &Up") {
        Prev := TV_GetPrev(Item)
        N := TV_GetPrev(Prev)

        If (Parent == 0) {
            Return
        } Else {
            FirstSib := TV_GetChild(Parent)
        }

        If (FirstSib = Item) {
            Return
        }
    } Else If (A_GuiControl = "Move &Down") {
        N := TV_GetNext(Item)
        If (!N) {
            Return
        }
    }

    TV_Delete(Item)

    If (A_GuiControl = "Move &Up" && Prev = FirstSib) {
        Id := TV_Add(ItemText, Parent, "First")
    } Else {
        Id := TV_Add(ItemText, Parent, N)
    }

    MaxIndex := m[Id].Items.MaxIndex()

    If (MaxIndex != "") {
        Items := []
        For Each, Item in m[Id].Items {
            Items.Insert(m[Id].Items[MaxIndex - A_Index + 1])
        }

        For Each, Item in Items {
            TV_Add(m[Item].DisplayName, Id, "First")
        }

        TV_Modify(Id, "Expand")
    }

    TV_Modify(Id, "Select")

    MaxIndex := m[Parent].Items.MaxIndex()

    Loop % MaxIndex {
        If (m[Parent].Items[A_Index] == Id) {
            m[Parent].Items.Remove(A_Index)
            Pos := A_Index
            Break
        }
    }

    Temp := []

    NewPos := (A_GuiControl == "Move &Up") ? (Pos - 1) : Pos

    Loop % m[Parent].Items.MaxIndex() {
        If (NewPos = Pos) {
            Temp.Insert(m[Parent].Items[A_Index])
        }

        If (A_Index == NewPos) {
            Temp.Insert(Id)
        }

        If (NewPos != Pos) {
            Temp.Insert(m[Parent].Items[A_Index])
        }
    }

    m[Parent].Items := Temp
Return

ShowExamplesMenu:
    Gui +LastFound

    Try {
        Menu ExamplesMenu, DeleteAll
    }

    AddMenu("ExamplesMenu", "&Open...`tCtrl+O", "LoadMenuExample", "shell32.dll", 5)
    Menu ExamplesMenu, Add, &Save`tCtrl+S, LoadMenuExample
    Menu ExamplesMenu, Icon, &Save`tCtrl+S, shell32.dll, % (g_NT6orLater) ? 259 : 7
    Menu ExamplesMenu, Add
    AddMenu("ExamplesMenu", "&Copy`tCtrl+C", "LoadMenuExample")
    AddMenu("ExamplesMenu", "Select &All`tCtrl+A", "LoadMenuExample")
    Menu ExamplesMenu, Add
    Menu ExamplesMenu, Add, &Reload`tCtrl+R, LoadMenuExample
    If (g_NT6orLater) {
        Menu ExamplesMenu, Icon, &Reload`tCtrl+R, shell32.dll, 239
    }
    Menu ExamplesMenu, Add
        AddMenu("ExamplesSubMenu", "Default", "LoadMenuExample")
        Menu ExamplesSubMenu, Default, Default
        AddMenu("ExamplesSubMenu", "Checked", "LoadMenuExample")
        Menu ExamplesSubMenu, Check, Checked
        Menu ExamplesSubMenu, Add, Radio, LoadMenuExample, Radio
        Menu ExamplesSubMenu, Check, Radio
        AddMenu("ExamplesSubMenu", "Disabled", "LoadMenuExample")
        Menu ExamplesSubMenu, Disable, Disabled
    AddMenu("ExamplesMenu", "States", ":ExamplesSubMenu")
    Menu ExamplesMenu, Add
    AddMenu("ExamplesMenu", "Settings...", "LoadMenuExample", "shell32.dll", 166)
    Menu ExamplesMenu, Add
    AddMenu("ExamplesMenu", "&Help`tF1", "LoadMenuExample", "shell32.dll", 24)
    Menu ExamplesMenu, Add
    AddMenu("ExamplesMenu", "E&xit`tEsc", "LoadMenuExample")

    ControlGetPos x, y,, h,, ahk_id %hBtnExamples%
    Menu ExamplesMenu, Show, %x%, % (y + h)
Return

LoadMenuExample:
    ResetMenuItemDlg()

    If (A_ThisMenuItem == "&Open...`tCtrl+O") {
        GuiControl Text, MenuDisplayName, &Open...
        GuiControl,, MenuHotkey, ^O
        GuiControl Text, MenuIcon, shell32.dll
        GuiControl,, MenuIconIndex, 4
    } Else If (A_ThisMenuItem == "&Save`tCtrl+S") {
        GuiControl Text, MenuDisplayName, &Save
        GuiControl,, MenuHotkey, ^S
        GuiControl Text, MenuIcon, shell32.dll
        GuiControl,, MenuIconIndex, % (g_NT6orLater) ? 259 : 7
    } Else If (A_ThisMenuItem == "&Copy`tCtrl+C") {
        GuiControl Text, MenuDisplayName, &Copy
        GuiControl,, MenuHotkey, ^C
    } Else If (A_ThisMenuItem == "Select &All`tCtrl+A") {
        GuiControl Text, MenuDisplayName, Select &All
        GuiControl,, MenuHotkey, ^A
    } Else If (A_ThisMenuItem == "&Reload`tCtrl+R") {
        GuiControl Text, MenuDisplayName, &Reload
        GuiControl,, MenuHotkey, ^R
        If (g_NT6orLater) {
            GuiControl Text, MenuIcon, shell32.dll
            GuiControl,, MenuIconIndex, 239
        }
    } Else If (A_ThisMenuItem == "Default") {
        GuiControl Text, MenuDisplayName, Default
        GuiControl,, MenuDefault, 1
    } Else If (A_ThisMenuItem == "Checked") {
        GuiControl Text, MenuDisplayName, Checked
        GuiControl,, MenuChecked, 1
    } Else If (A_ThisMenuItem == "Radio") {
        GuiControl Text, MenuDisplayName, Radio
        GuiControl,, MenuChecked, 1
        GuiControl,, MenuRadio, 1
    } Else If (A_ThisMenuItem == "Settings...") {
        GuiControl Text, MenuDisplayName, Settings...
        GuiControl Text, MenuIcon, shell32.dll
        GuiControl,, MenuIconIndex, 166
    } Else If (A_ThisMenuItem == "&Help`tF1") {
        GuiControl Text, MenuDisplayName, &Help
        GuiControl,, MenuHotkey, F1
        GuiControl Text, MenuIcon, shell32.dll
        GuiControl,, MenuIconIndex, 24
    } Else If (A_ThisMenuItem == "E&xit`tEsc") {
        GuiControl Text, MenuDisplayName, E&xit
        GuiControl,, MenuHotkey, Esc
    }
Return

ResetMenuItemDlg() {
    Gui AddMenuItemDlg: Default
    GuiControl, Text, MenuDisplayName
    GuiControl,, MenuCommand
    GuiControl,, ChkSubMenu, 0
    GuiControl,, MenuHotkey
    GuiControl, Text, MenuIcon
    GuiControl,, MenuIconIndex
    GuiControl,, MenuChecked, 0
    GuiControl,, MenuRadio, 0
    GuiControl,, MenuDefault, 0
    GuiControl,, MenuDisabled, 0
}

IsMenuNameAvailable(MenuName) {
    For Menu in m {
        For Each, Item in m[Menu].Items {
            If (m[Item].SubMenu) {
                If (m[Item].Command = MenuName) {
                    Return False
                } Else {
                    OutputDebug % "*" m[Item].Command . " != " . MenuName
                }
            }
        }
    }
    Return True
}

TreeViewHandler:
    Gui MenuEditor: Submit, NoHide
    Gui TreeView, MenuTV%MenuType%
Return

MenuEditorSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("wh", "SysTabControl321", "SysTreeView321", "SysTreeView322", "SysTreeView323")
    GuiControlGet, hButton1, hWnd, Button1
    ControlGetPos,, cy,, ch,, ahk_id %hButton1%
    hParent := GetParent(hButton1)
    ControlGetPos dx, dy, dw, dh,, ahk_id %hParent%
    GuiControl MoveDraw, %hButton1%, % "y" . (dh - ch - 2)
    AutoXYWHSize := "*x"
    Loop 12 {
        AutoXYWH(AutoXYWHSize, "Button" . (A_Index + 1))
        If (A_Index == 7) {
            AutoXYWHSize := "*xy"
        }
    }
Return

ChangeMenuType:
    Gui AddMenuItemDlg: Default
    GuiControlGet ChkSubMenu
    GuiControl,, LabelOrSubMenu, % ChkSubMenu ? "Menu Name:" : "Label:"
Return

MenuClearHotkey:
    GuiControl,, MenuHotkey
Return
