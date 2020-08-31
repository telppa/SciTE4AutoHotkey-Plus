Class DefCtl {
    __New(DisplayName, Prefix, Width, Height, Options := "", Style := "", ExStyle := "0", Text := "", Icon := 1) {
        this.DisplayName  := DisplayName
        this.Prefix       := Prefix
        this.Text         := (Text == "=") ? this.DisplayName : Text
        this.Width        := Width
        this.Height       := Height
        this.Options      := Options
        this.Style        := Style
        this.ExStyle      := ExStyle
        this.IconIndex    := Icon
        this.Menu         := ""
    }
}

Global Default := {}
Default.ActiveX      := New DefCtl("ActiveX", "AX", 200, 100, "", 0x54000000,, "HTMLFile", 46)
Default.Button       := New DefCtl("Button", "Btn", 80, 23, "", 0x50012000,, "&OK", 47)
Default.CheckBox     := New DefCtl("CheckBox", "Chk", 120, 23, "", 0x50012003,, "=", 48)
Default.ComboBox     := New DefCtl("ComboBox", "Cbx", 120, 21, "", 0x50010242,, "=", 49)
Default.DateTime     := New DefCtl("Date Time Picker", "Date", 100, 24, "", 0x5201000C,, "", 51)
Default.DropDownList := New DefCtl("Drop-Down List", "DDL", 120, 21, "", 0x50010203,, "DropDownList||", 50)
Default.Edit         := New DefCtl("Edit Box", "Edt", 120, 21, "", 0x50010080, 0x200, "", 52)
Default.GroupBox     := New DefCtl("GroupBox", "Grp", 120, 80, "", 0x50000007,, "=", 53)
Default.Hotkey       := New DefCtl("Hotkey Box", "Hk", 120, 21, "", 0x50010000, 0x200, "", 54)
Default.Link         := New DefCtl("Link", "Lnk", 120, 23, "", 0x50010000,, "<a href=""https://autohotkey.com"">autohotkey.com</a>", 55)
Default.ListBox      := New DefCtl("ListBox", "Lbx", 120, 160, "", 0x50010081, 0x200, "=", 56)
Default.ListView     := New DefCtl("ListView", "LV", 200, 150, "+LV0x4000", 0x50010009, 0x200, "=", 57)
Default.MonthCal     := New DefCtl("Month Calendar", "Month", 225, 160, "", 0x50010000,, "", 59)
Default.Picture      := New DefCtl("Picture", "Pic", 32, 32, "", 0x50000003,, "mspaint.exe", 60)
Default.Progress     := New DefCtl("Progress Bar", "Prg", 120, 20, "-Smooth", 0x50000000,, "33", 61)
Default.Radio        := New DefCtl("Radio Button", "Rad", 120, 23, "", 0x50036009,, "=", 62)
Default.Separator    := New DefCtl("Separator", "Sep", 200, 2, "+0x10", 0x50020010, 0x20000, "", 63)
Default.Slider       := New DefCtl("Slider", "Sldr", 120, 32, "", 0x50010000,, "50", 64)
Default.StatusBar    := New DefCtl("Status Bar", "SB", "", "", "", 0x50000800,, "=", 65)
Default.Tab2         := New DefCtl("Tab", "Tab", 225, 160, "", 0x54010240,, "Tab 1|Tab 2", 66)
Default.Text         := New DefCtl("Text", "Txt", 120, 23, "+0x200", 0x50000200,, "=", 67)
Default.ToolBar      := New DefCtl("Toolbar", "TB", 225, 160, "", 0x50009901,, "=", 69)
Default.TreeView     := New DefCtl("TreeView", "TV", 160, 160, "", 0x50010027, 0x200, "", 68)
Default.UpDown       := New DefCtl("UpDown", "UpDn", 16, 21, "", 0x50000026,, "1", 70)
Default.Custom       := New DefCtl("Custom", "Ctl", 100, 23, "", 0x50010000,, "Custom", 71)
Default.CommandLink  := New DefCtl("Command Link", "CmdLnk", 200, 42, "ClassButton +0x200E", 0x5001200E,, "=", 45)

Default.ListView.ExExStyle := 0x30

Default.Button.Menu   := ["Default", "Disabled", "No Theme"]
Default.CheckBox.Menu := ["Checked", "Disabled"]
Default.ComboBox.Menu := ["Alternate Submit", "Sort Alphabetically", "Uppercase All Items", "Lowercase All Items", "Simple (Edit + ListBox)", "Hint Text...", "No Theme", "Disabled"]
Default.DateTime.Menu := ["Show Checkbox", "Right Align the Drop-down Calendar", "Disabled"]
Default.DropDownList.Menu := ["Alternate Submit", "Sort Alphabetically", "Uppercase All Items", "Lowercase All Items", "No Theme", "Disabled"]
Default.Edit.Menu     := ["Read Only", "Multiline", "No Scrollbar", "Numbers Only", "Text Alignment...", "Hint Text...", "Password Field", "No Theme", "Disabled"]
Default.GroupBox.Menu := ["Text Alignment...", "No Theme"]
Default.Hotkey.Menu   := ["Disabled"]
Default.ListBox.Menu  := ["Alternate Submit", "No Integral Height", "Multiple Selection (Extended)", "Multiple Selection (Simplified)", "Sort Alphabetically", "Disabled"]
Default.ListView.Menu := ["View Mode...", "Alternate Submit", "No Column Header", "Show Checkboxes", "Show Grid", "Single Row Selection", "Show ToolTips", "Explorer Theme", "Prevent Flickering", "Sort Alphabetically", "No Sort Header", "Editable First Cell", "Underline Hot Items", "Disabled"]
Default.MonthCal.Menu := ["Multiple Selection", "Show Week Numbers", "No Today Circle", "No Bottom Label"]
Default.Picture.Menu  := ["Transparent Background", "Use GDI+", "Show Border", "Sunken", "3D Sunken Edge", "3D Outset Border", "Thick Frame"]
Default.Progress.Menu := ["No Smooth Style", "Show Border", "Vertical", "Disabled"]
Default.Radio.Menu    := ["Checked", "Disabled"]
Default.Separator.Menu := ["Vertical Line"]
Default.Slider.Menu   := ["Vertical", "No Ticks", "Blunt", "Thick Thumb", "Show ToolTip", "Disabled"]
Default.StatusBar.Menu := ["Show on Top", "No Theme"]
Default.Tab2.Menu     := ["Single Row (No Wrap)", "Buttons", "Flat Buttons", "Tabs on the Bottom", "Alternate Submit"]
Default.Text.Menu     := ["Single Line", "Show Border", "Sunken", "3D Sunken Edge", "3D Outset Border", "Text Alignment...", "No GUI Background", "Disabled"]
Default.TreeView.Menu := ["Alternate Submit", "Show Checkboxes", "No Expansion Glyph", "No Dotted Lines", "Explorer Theme", "Full Row Select", "Disabled"]
Default.UpDown.Menu   := ["No Buddy (Isolated)", "No Thousands Separator", "Left-sided", "Horizontal", "Disabled"]
Default.CommandLink.Menu := ["Default Button", "Show Border", "Disabled", "No Theme"]

Global g_ControlOptions := {"Default": "+Default"
, "Disabled": "+Disabled"
, "Checked": "+Checked"
, "Multiline": "+Multi"
, "No Scrollbar": "-VScroll"
, "Numbers Only": "+Number"
, "Password Field": "+Password"
, "Read Only": "+ReadOnly"
, "No Column Header": "-Hdr"
, "Show Checkboxes": "+Checked"
, "Show Grid": "+Grid"
, "Single Row Selection": "-Multi"
, "Alternate Submit": "+AltSubmit"
, "Show ToolTips": "+LV0x4000"
, "No Integral Height": "+0x100"
, "Multiple Selection (extended)": "+Multi"
, "Multiple Selection (simplified)": "+0x8"
, "Sort Alphabetically": "+Sort"
, "No Theme": "-Theme"
, "No Smooth Style": "-Smooth"
, "Show Border": "+Border"
, "Vertical": "+Vertical"
, "Uppercase All Items": "+Uppercase"
, "Lowercase All Items": "+Lowercase"
, "Simple (Edit + ListBox)": "+Simple"
, "Multiple Selection": "+Multi"
, "Show Week Numbers": "4"
, "No Today Circle": "8"
, "No Bottom Label": "16"
, "Show Checkbox": "2"
, "Right Align the Drop-down Calendar": "+Right"
, "Use GDI+": "+AltSubmit"
, "Single Line": "+0x200"
, "Sunken": "+0x1000"
, "3D Sunken Edge": "+E0x200"
, "3D Outset Border": "+0x400000"
, "Thick Frame": "+0x40000"
, "Transparent Background": "+BackgroundTrans"
, "No Expansion Glyph": "-Buttons"
, "No Dotted Lines": "-Lines"
, "Thick Thumb": "+0x40"
, "No Ticks": "+NoTicks"
, "Blunt": "+Center"
, "Show ToolTip": "+Tooltip"
, "No Buddy (Isolated)": "-16"
, "No Thousands Separator": "+0x80"
, "Left-sided": "+Left"
, "Horizontal": "+Horz"
, "Buttons": "+Buttons"
, "Flat Buttons": "+0x8"
, "Tabs on the Bottom": "+Bottom"
, "Single Row (No Wrap)": "-Wrap"
, "Underline Hot Items": "+LV0x840"
, "No Sort Header": "+NoSortHdr"
, "Default Button": "+0x1"
, "Prevent Flickering": "+LV0x10000"
, "Editable First Cell": "+0x200"
, "Show on Top": "+0x1"
, "Full Row Select": "+0x1000 -0x2"
, "No GUI Background": "-Background"
, "Vertical Line": "+0x1"}

Global g_WindowOptions := {"Resizable": "+Resize"
, "No Minimize Box": "-MinimizeBox"
, "No Maximize Box": "-MaximizeBox"
, "No System Menu": "-SysMenu"
, "Always on Top": "+AlwaysOnTop"
, "Own Dialogs": "+OwnDialogs"
, "Tool Window": "+ToolWindow"
, "No DPI Scale": "-DPIScale"
, "Help Button": "+E0x400"
, "Classic Theme": "-Theme"
, "No Title Bar": "-Caption"
, "No Taskbar Button": "+Owner"}

; Preview Window Context Menu: Insert
AddMenu("InsertMenu", "Button", "InsertControl", IconLib, -47)
AddMenu("InsertMenu", "CheckBox", "InsertControl", IconLib, -48)
AddMenu("InsertMenu", "ComboBox", "InsertControl", IconLib, -49)
AddMenu("InsertMenu", "Date Time Picker", "InsertControl", IconLib, -51)
AddMenu("InsertMenu", "DropDownList", "InsertControl", IconLib, -50)
AddMenu("InsertMenu", "Edit Box", "InsertControl", IconLib, -52)
AddMenu("InsertMenu", "GroupBox", "InsertControl", IconLib, -53)
AddMenu("InsertMenu", "Hotkey Box", "InsertControl", IconLib, -54)
AddMenu("InsertMenu", "Link", "InsertControl", IconLib, -55)
AddMenu("InsertMenu", "ListBox", "InsertControl", IconLib, -56)
AddMenu("InsertMenu", "ListView", "InsertControl", IconLib, -57)
AddMenu("InsertMenu", "Month Calendar", "InsertControl", IconLib, -59)
AddMenu("InsertMenu", "Picture", "InsertControl", IconLib, -60)
AddMenu("InsertMenu", "Progress Bar", "InsertControl", IconLib, -61)
AddMenu("InsertMenu", "Radio Button", "InsertControl", IconLib, -62)
AddMenu("InsertMenu", "Separator", "InsertControl", IconLib, -63)
AddMenu("InsertMenu", "Slider", "InsertControl", IconLib, -64)
AddMenu("InsertMenu", "Tab", "InsertControl", IconLib, -66)
AddMenu("InsertMenu", "Text", "InsertControl", IconLib, -67)
AddMenu("InsertMenu", "TreeView", "InsertControl", IconLib, -68)
AddMenu("InsertMenu", "UpDown", "InsertControl", IconLib, -70)

; Preview Window: Context Menu
AddMenu("WindowContextMenu", "Add Control", ":InsertMenu", IconLib, -44)
AddMenu("WindowContextMenu", "Paste", "PasteControl", IconLib, -17)
AddMenu("WindowContextMenu")
AddMenu("WindowContextMenu", "Change Title...", "ChangeTitle", IconLib, -37)
AddMenu("WindowContextMenu")
AddMenu("WindowContextMenu", "Fit to Contents", "AutoSizeWindow", IconLib, -99)
AddMenu("WindowContextMenu", "Font...", "ShowFontDialog", IconLib, -20)
AddMenu("WindowContextMenu", "Options...", "ShowWindowOptions", IconLib, -91)
AddMenu("WindowContextMenu")
AddMenu("WindowContextMenu", "Toggle Grid", "ToggleGrid", IconLib, -72)
AddMenu("WindowContextMenu", "Repaint", "RedrawWindow", IconLib, -39)
AddMenu("WindowContextMenu")
AddMenu("WindowContextMenu", "Properties", "ShowProperties", IconLib, -25)
Menu WindowContextMenu, Color, 0xFAFAFA

; Control Context Menu
AddMenu("ControlContextMenu", "Change Text...", "ChangeText", IconLib, -14)
Menu ControlContextMenu, Add
AddMenu("ControlContextMenu", "Cut", "CutControl", IconLib, -15)
AddMenu("ControlContextMenu", "Copy", "CopyControl", IconLib, -16)
AddMenu("ControlContextMenu", "Paste", "PasteControl", IconLib, -17)
AddMenu("ControlContextMenu", "Delete", "DeleteSelectedControls", IconLib, -18)
Menu ControlContextMenu, Add
AddMenu("ControlContextMenu", "Position and Size...", "ShowAdjustPositionDialog", IconLib, -75)
AddMenu("ControlContextMenu", "Font...", "ShowFontDialog", IconLib, -20)
AddMenu("ControlOptionsMenu", "None", "MenuHandler")
AddMenu("ControlContextMenu", "Options", ":ControlOptionsMenu", IconLib, -91)
Menu ControlContextMenu, Add
AddMenu("ControlContextMenu", "Properties", "ShowProperties", IconLib, -25)
