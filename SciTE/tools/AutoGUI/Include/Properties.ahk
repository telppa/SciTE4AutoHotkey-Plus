ShowWindowProperties:
    g_Control := ""
ShowProperties:
    If (!WinExist("ahk_id" . hChildWnd)) {
        GoSub NewGUI
    }

    If (!WinExist("ahk_id " . hPropWnd)) {
    Gui Properties: New, LabelProperties hWndhPropWnd -MinimizeBox OwnerAuto
    SetWindowIcon(hPropWnd, IconLib, 25)
    Gui Font, s9, Segoe UI

    ClassNNList := ""
    For Each, Item In g.ControlList {
        ClassNNList .= g[Item].ClassNN . "|"
    }

    Gui Add, Picture, vCtlIcon gBlinkBorder x12 y13 w16 h16 Icon5, %IconLib%
    Gui Add, DropDownList, hWndhCbxClassNN vCbxClassNN gOnDropDownChange x40 y12 w245, Window||%ClassNNList%
    Gui Add, Button, hWndhBtnReload gReloadControlList x290 y11 w23 h23
    GuiButtonIcon(hBtnReload, IconLib, 90, "L1 T1")

    Gui Add, Tab3
    , hWndhPropTab gPropTabHandler x6 y41 w312 h343 AltSubmit -Wrap %g_ThemeFix%
    , General|Options|Styles|Font|Window|Events

    Gui Tab, 1 ; General
        Gui Add, GroupBox, vGrpText x18 y70 w286 h57, Text
        Gui Add, Edit, vEdtText x30 y91 w189 h21
        Gui Add, Button, vBtnText gChangeText x224 y89 w70 h23, Text...

        Gui Add, GroupBox, x18 y131 w286 h104, Variables
        Gui Add, Text, x30 y152 w65 h21 +0x200, h&Wnd var:
        Gui Add, Edit, vEdtHWndVar x97 y152 w122 h21
        Gui Add, Button, gSuggestHWndVar x224 y151 w70 h23, Suggest
        Gui Add, Text, vTxtVVar x30 y177 w65 h21 +0x200, &v-Var:
        Gui Add, Edit, vEdtVVar x97 y177 w122 h21
        Gui Add, Button, gSuggestVVar x224 y176 w70 h23, Suggest
        Gui Add, Text, vTxtGLabel x30 y202 w65 h21 +0x200, &g-Label:
        Gui Add, Edit, vEdtGLabel x97 y202 w122 h21
        Gui Add, Button, vBtnWinLabel gSuggestWinLabel x224 y201 w70 h23 Hidden, Suggest
        Gui Add, CheckBox, vChkFunction x225 y202 w75 h21, Function

        Gui Add, GroupBox, x18 y239 w286 h79, Position
        Gui Add, Text, x52 y257 w50 h22 +0x200, &X (Left):
        Gui Add, Edit, vEdtX x104 y257 w52 h21
        Gui Add, UpDown, gAdjustPosition Range-65536-65536 +0x80
        Gui Add, Text, x170 y257 w50 h22 +0x200, &Y (Top):
        Gui Add, Edit, vEdtY x221 y257 w52 h21
        Gui Add, UpDown, gAdjustPosition Range-65536-65536 +0x80
        Gui Add, Text, x52 y285 w50 h22 +0x200, &Width:
        Gui Add, Edit, vEdtW x104 y285 w52 h21
        Gui Add, UpDown, gAdjustPosition Range-65536-65536 +0x80
        Gui Add, Text, x170 y285 w50 h22 +0x200, &Height:
        Gui Add, Edit, vEdtH x221 y285 w52 h21, 213
        Gui Add, UpDown, gAdjustPosition Range-65536-65536 +0x80

        Gui Add, GroupBox, x18 y322 w286 h49, Anchor
        Gui Add, CheckBox, vChkAnchorX gRequireHWndVar x32 y339 w42 h23, X
        Gui Add, CheckBox, vChkAnchorY gRequireHWndVar x76 y339 w42 h23, Y
        Gui Add, CheckBox, vChkAnchorW gRequireHWndVar x120 y339 w42 h23, W
        Gui Add, CheckBox, vChkAnchorH gRequireHWndVar x164 y339 w42 h23, H
        Gui Add, CheckBox, vChkMoveDraw x225 y339 w75 h23, Redraw

    Gui Tab, 2 ; Options
        Gui Add, TreeView, hWndhTVCtlOpts gTVCtlOptsHandler x17 y75 w289 h267 -7 +0x9000 Checked -E0x200 AltSubmit
        SendMessage 0x112C, 0, 0x8,, ahk_id %hTVCtlOpts% ; TVM_SETEXTENDEDSTYLE (TVS_EX_NOINDENTSTATE)
        SetExplorerTheme(hTVCtlOpts)

        Gui Add, Text, vTxtCtlsOnly x17 y353 w289 h21 +0x200 Hidden, Options for controls only.
        Gui Add, Edit, hWndhEdtCtlOpts vEdtCtlOpts x17 y349 w289 h21
        SendMessage 0x1501, 1, "Additional options",, ahk_id %hEdtCtlOpts%

    Gui Tab, 3 ; Styles
        Gui Add, Custom, ClassSysTabControl32 hWndhTabStyles gStylesTabHandler x17 y75 w291 h236
        Tab_AddItem(hTabStyles, "Styles")
        Tab_AddItem(hTabStyles, "Extended Styles")
        Gui Add, ListBox
        , hWndhLbxStyles vLbxStyles gLbxStylesHandler x25 y106 w273 h195 +0x108 -E0x200 T98
        Gui Add, ListBox
        , hWndhLbxExStyles vLbxExStyles gLbxStylesHandler x25 y106 w273 h195 +0x108 -E0x200 T98 Hidden
        Gui Add, ListBox
        , hWndhLbxExLV vLbxExLV gLbxStylesHandler x25 y106 w273 h195 +0x108 -E0x200 T98 Hidden
        Gui Add, Edit, hWndhEdtStyles vEdtStyles x17 y318 w200 h23
        SendMessage 0x1501, 1, "Styles",, ahk_id %hEdtStyles%
        Gui Add, Edit, hWndhEdtStylesSum vEdtStylesSum x226 y318 w80 h23
        SendMessage 0x1501, 1, "Sum",, ahk_id %hEdtStylesSum%
        hStylesToolbar := CreateStylesToolbar()

    Gui Tab, 4 ; Font
        Gui Add, GroupBox, x18 y73 w286 h146, Font
        Gui Add, ListView, hWndhLVFontOpts x30 y92 w262 h81 -Hdr, Property|Value
        SetExplorerTheme(hLVFontOpts)
        LV_Add("", "Name")
        LV_Add("", "Style")
        LV_Add("", "Size")
        LV_Add("", "Color")
        Gui Add, Button, gShowFontDialog x193 y182 w100 h24, Change...

        Gui Add, GroupBox, x18 y226 w286 h88, Control Color
        Gui Add, CheckBox, vChkBGColor gEnableBGColor x30 y248 w135 h23, Background color:
        Gui Add, ListView, vBGColorPreview x168 y249 w21 h21 -Hdr Border
        Gui Add, Button, vBtnBGColor gSelectColor x196 y246 w100 h24, Change...
        Gui Add, CheckBox, vChkFGColor gEnableFGColor x30 y276 w135 h23, Foreground color:
        Gui Add, ListView, vFGColorPreview x168 y277 w21 h21 -Hdr Border
        Gui Add, Button, vBtnFGColor gSelectColor x196 y276 w100 h24, Change...

        Gui Add, GroupBox, x18 y320 w286 h50, Window Color
        Gui Add, CheckBox, vChkWinColor x30 y338 w135 h23, Background color:
        Gui Add, ListView, vWinColorPreview x168 y339 w21 h21 -Hdr Border
        Gui Add, Button, vBtnWinColor gSelectColor x196 y337 w100 h24, Change...
        DefWinColor := ToHex(CvtClr(DllCall("GetSysColor", "UInt", 15))) ; COLOR_3DFACE
        GuiControl +Background%DefWinColor%, WinColorPreview

    Gui Tab, 5 ; Window
        Gui Add, TreeView, hWndhTVWinOpts gTVWinOptsHandler x17 y75 w289 h237 -7 +0x9000 Checked -E0x200 AltSubmit
        SendMessage 0x112C, 0, 0x8,, ahk_id %hTVWinOpts% ; TVM_SETEXTENDEDSTYLE (TVS_EX_NOINDENTSTATE)
        SetExplorerTheme(hTVWinOpts)
        TV_Add("Center on Screen", 0, "Check")
        TV_Add("Resizable")
        TV_Add("No Minimize Box")
        TV_Add("No Maximize Box")
        TV_Add("No System Menu")
        TV_Add("Always on Top")
        TV_Add("Own Dialogs")
        TV_Add("Tool Window")
        TV_Add("No DPI Scale")
        TV_Add("Help Button")
        TV_Add("Classic Theme")
        TV_Add("No Title Bar")
        TV_Add("No Taskbar Button")

        Gui Add, Edit, hWndhEdtWinOpts vEdtWinOpts x17 y320 w289 h21
        SendMessage 0x1501, 1, "Additional options",, ahk_id %hEdtWinOpts%

        Gui Add, CheckBox, vChkTrayIcon x21 y348 w121 h23, &Window/tray icon:
        Gui Add, Text, x178 y350 w20 h20 +0x1000
        Gui Add, Picture, vTrayIcon gShowIconPath x180 y352 w16 h16, %A_AhkPath%
        Gui Add, Button, gChooseTrayIcon x206 y348 w100 h24, Change...

    Gui Tab, 6 ; Events
        Gui Add, GroupBox, x18 y71 w286 h100, Standard Events
        Gui Add, CheckBox, vChkGuiClose x30 y90 w119 h23 Checked, Gui&Close
        Gui Add, CheckBox, vChkGuiEscape x30 y115 w119 h23 Checked, Gui&Escape
        Gui Add, CheckBox, vChkGuiSize x30 y140 w119 h23, Gui&Size
        Gui Add, CheckBox, vChkGuiContextMenu x161 y90 w111 h23, GuiContext&Menu
        Gui Add, CheckBox, vChkGuiDropFiles x161 y115 w111 h23, Gui&DropFiles
        Gui Add, CheckBox, vChkOnClipboardChange x161 y140 w131 h23, &OnClipboardChange

        Gui Add, ListView, hWndhLVWinEvts x18 y179 w286 h161 +LV0x114004, Windows Events|Value
        SysGet VScrollBarW, 2 ; SM_CXVSCROLL
        LV_ModifyCol(1, 286 - VScrollBarW - 4)
        LV_ModifyCol(2, 0)
        SetExplorerTheme(hLVWinEvts)
        LV_Add("", "WM_MOUSEMOVE", 0x200)
        LV_Add("", "WM_KEYDOWN", 0x100)
        LV_Add("", "WM_KEYUP", 0x101)
        LV_Add("", "WM_LBUTTONDOWN", 0x201)
        LV_Add("", "WM_LBUTTONUP", 0x202)
        LV_Add("", "WM_LBUTTONDBLCLK", 0x203)
        LV_Add("", "WM_RBUTTONDOWN", 0x204)
        LV_Add("", "WM_MBUTTONDOWN", 0x207)
        LV_Add("", "WM_MOVE", 0x3)
        LV_Add("", "WM_EXITSIZEMOVE", 0x232)
        LV_Add("", "WM_MOUSELEAVE", 0x2A3)
        LV_Add("", "WM_COMMAND", 0x111)
        LV_Add("", "WM_NOTIFY", 0x4E)
        LV_Add("", "WM_PAINT", 0xF)
        LV_Add("", "WM_COPYDATA", 0x4A)
        LV_Add("", "WM_SETCURSOR", 0x20)
        LV_Add("", "WM_ENTERMENULOOP", 0x211)
        LV_Add("", "WM_INITMENU", 0x116)
        LV_Add("", "WM_ENDSESSION", 0x16)
        Gui Add, CheckBox, vChkEvtFunc x18 y348 w183 h24, Standard events as functions
        Gui Add, Button, gShowMoreEvents x205 y348 w100 h24, More Events...

    Gui Tab

    Gui Add, Button, gApplyProperties vBtnOK x48 y391 w86 h24, &OK
    Gui Add, Button, gPropertiesClose x139 y391 w86 h24, &Cancel
    Gui Add, Button, gApplyProperties x230 y391 w86 h24 Default, &Apply

    If (g_PropX == "") {
        WinGetPos ax, ay, aw,, ahk_id %hAutoWnd%
        IniRead g_PropX, %IniFile%, Properties, x, % (ax + aw - 323 - 40)
        IniRead g_PropY, %IniFile%, Properties, y, % ay + 40
    }
    Gui Properties: Show, x%g_PropX% y%g_PropY% w323 h423, Properties

    LoadStylesData()

    } Else {
        Gui Properties: Show, % (InStr(A_ThisFunc, "OnWM") ? "NA" : "")
    }

    ClassNN := g[g_Control].ClassNN
    If (ClassNN == "") {
        ClassNN := "Window"
    }
    GuiControl Properties: ChooseString, CbxClassNN, %ClassNN%

    Gosub OnDropDownChange
Return

PropertiesEscape:
PropertiesClose:
    WinActivate ahk_id %hAutoWnd%
    WinGetPos g_PropX, g_PropY,,, ahk_id %hPropWnd%
    Gui Properties: Hide
Return

LoadProperties:
    Gui Properties: Default
    ClassNN := Properties_GetClassNN()

    ResetProperties()

    Gui Properties: TreeView, %hTVCtlOpts%
    TV_Delete()

    GuiControlGet PropTab,, %hPropTab%
    If (PropTab == 3) {
        LoadStylesTab(g_Control)
    }

    ; Window properties
    If (ClassNN == "Window") {
        If (g.Window.Title != "") {
            GuiControl,, EdtText, % UnescapeChars(g.Window.Title)
        }

        GuiControl,, EdtHWndVar, % g.Window.hWndVar
        GuiControl,, EdtVVar, % g.Window.Name
        GuiControl,, EdtGLabel, % g.Window.Label

        Properties_UpdateWinPos()
        Properties_ShowFontInfo(g.Window.FontName, g.Window.FontOptions)
        Return
    }

    ; Control properties
    If (g[g_Control].Text != "") {
        GuiControl,, EdtText, % UnescapeChars(g[g_Control].Text)
    }

    ; Variables
    GuiControl,, EdtHWndVar, % g[g_Control].hWndVar
    GuiControl,, EdtVVar, % g[g_Control].vVar
    GuiControl,, EdtGLabel, % g[g_Control].gLabel
    GuiControl,, ChkFunction, % g[g_Control].LabelIsFunc

    ; Size/position
    Properties_UpdateCtlPos()

    Anchor := g[g_Control].Anchor
    If (Anchor != "") {
        If (InStr(Anchor, "x")) {
            GuiControl,, ChkAnchorX, 1
        }
        If (InStr(Anchor, "y")) {
            GuiControl,, ChkAnchorY, 1
        }
        If (InStr(Anchor, "w")) {
            GuiControl,, ChkAnchorW, 1
        }
        If (InStr(Anchor, "h")) {
            GuiControl,, ChkAnchorH, 1
        }
        If (InStr(Anchor, "*")) {
            GuiControl,, ChkMoveDraw, 1
        }
    }

    ; Load control options
    Options := Default[g[g_Control].Type].Menu
    CtlOpts := StrSplit(g[g_Control].Options, " ")

    For Each, Option in Options {
        If (Option == "View Mode..." && g[g_Control].ViewMode != "") {
            TV_Add("View Mode: " . g[g_Control].ViewMode, 0, "Check")

        } Else If (Option == "Text Alignment..." && g[g_Control].Alignment != "") {
            TV_Add("Text Alignment: " . g[g_Control].Alignment, 0, "Check")

        } Else If (Option == "Hint Text..." && g[g_Control].HintText != "") {
            TV_Add("Hint Text: " . g[g_Control].HintText, 0, "Check")

        } Else {
            TV_Add(Option, 0, IsCtlOptionSet(Option, CtlOpts, g_Control) ? "Check" : "")
        }
    }

    ; Additional options
    GuiControl, Properties:, EdtCtlOpts, % g[g_Control].Extra

    ; Font
    Properties_ShowFontInfo(g[g_Control].FontName, g[g_Control].FontOptions)

    ; Background color
    If (g[g_Control].BGColor != "") {
        LoadColorPreview("BG", g[g_Control].BGColor)
    } Else If (g[g_Control].Background != "") {
        LoadColorPreview("BG", g[g_Control].Background)
    }

    ; Foreground color
    If (g[g_Control].FGColor != "") {
        LoadColorPreview("FG", g[g_Control].FGColor)
    } Else If (g[g_Control].TextColor != "") {
        LoadColorPreview("FG", g[g_Control].TextColor)
    }
Return

ApplyProperties:
    Gui Properties: Submit, NoHide

    GuiControlGet hCtl, %Child%: hWnd, %CbxClassNN%

    ; Control Anchor (AutoXYWH)
    g[hCtl].Anchor := ""
    If (ChkAnchorX) {
        g[hCtl].Anchor .= "x"
    }
    If (ChkAnchorY) {
        g[hCtl].Anchor .= "y"
    }
    If (ChkAnchorW) {
        g[hCtl].Anchor .= "w"
    }
    If (ChkAnchorH) {
        g[hCtl].Anchor .= "h"
    }
    If (ChkMoveDraw) {
        g[hCtl].Anchor .= "*"
    }

    ; Any control using AutoXYWH?
    g.Anchor := False
    For Each, Item In g.ControlList {
        If (g[Item].Anchor != "") {
            g.Anchor := True
            If (!InStr(g.Window.Options, "+Resize")) {
                TVCheckOption(hTVWinOpts, "Resizable")
                GuiControl Properties:, ChkGuiSize, 1
                ChkGuiSize := True
            }
            Break
        }
    }

    ; Any control using ControlColor?
    g.ControlColor := False
    For Each, Item in g.ControlList {
        If (g[Item].BGColor != "") {
            g.ControlColor := True
            Break
        }
    }

    ; Window tab
    SetWinOptions()
    g.Window.Extra := EdtWinOpts ; Additional options

    ; Enable GuiSize if the option +Resize is present
    If (!ChkGuiSize && InStr(g.Window.Options, "+Resize")) {
        GuiControl Properties:, ChkGuiSize, 1
        ChkGuiSize := True
    }

    ; Window background color
    If (!ChkWinColor && g.Window.Color != "") {
        g.Window.Color := ""
        DefWinColor := ToHex(CvtClr(DllCall("GetSysColor", "UInt", 15))) ; COLOR_3DFACE
        GuiControl Properties: +Background%DefWinColor%, WinColorPreview
    }

    ; Window/tray icon
    If (!ChkTrayIcon && g.Window.Icon != "") {
        g.Window.Icon := ""
        g.Window.IconIndex := 0
        GuiControl, Properties:, TrayIcon, %A_AhkPath%
    }

    ; Standard Events
    g.Window.GuiClose := ChkGuiClose
    g.Window.GuiEscape := ChkGuiEscape
    g.Window.GuiSize := ChkGuiSize
    g.Window.GuiContextMenu := ChkGuiContextMenu
    g.Window.GuiDropFiles := ChkGuiDropFiles
    g.Window.OnClipboardChange := ChkOnClipboardChange
    g.Window.EvtFunc := ChkEvtFunc

    ; Windows Events
    Gui Properties: ListView, %hLVWinEvts%
    Row := 0
    g.WinEvents1 := g.WinEvents2 := CRLF
    Loop {
        Row := LV_GetNext(Row, "Checked")
        If (!Row) {
            Break
        }
        LV_GetText(Event, Row, 1)
        LV_GetText(Value, Row, 2)

        g.WinEvents1 .= "OnMessage(" . Value . ", ""On" . Event . """)" . CRLF
        g.WinEvents2 .= "On" . Event . "(wParam, lParam, msg, hWnd) {`n`n}" . CRLF . CRLF
    }

    TmpWinEvts := g.WinEvents2
    StringTrimRight TmpWinEvts, TmpWinEvts, 2
    g.WinEvents2 := TmpWinEvts

    ; General tab (for window)
    If (CbxClassNN == "Window") {
        If (EdtText != g.Window.Title) {
            g.Window.Title := EscapeChars(EdtText, True)
            WinSetTitle ahk_id %hChildWnd%,, %EdtText%
        }

        g.Window.hWndVar := EdtHWndVar
        g.Window.Name := EdtVVar
        g.Window.Label := EdtGLabel

        MoveChildWindow(EdtX, EdtY, EdtW, EdtH)

        g.Window.Styles := EdtStyles

        GoTo ApplyPropertiesEnd
    }

    ; General tab (for controls)
    If (EdtText != g[hCtl].Text) {
        SetControlText(hCtl, EdtText)
    }

    ; Variables
    g[hCtl].hWndVar := EdtHWndVar
    g[hCtl].vVar := EdtVVar
    g[hCtl].gLabel := EdtGLabel
    g[hCtl].LabelIsFunc := ChkFunction

    ; Generate the code for labels/functions
    g.ControlFuncs := ""
    For Each, Item in g.ControlList {
        If (g[Item].gLabel != "") {
            If (IsLabelAvailable(g[Item].gLabel, A_Index)) {
                g.ControlFuncs .= CRLF . g[Item].gLabel

                If (g[Item].LabelIsFunc) {
                    If (g[Item].Type == "Link") {
                        g.ControlFuncs .= "(CtrlHwnd, GuiEvent, LinkIndex, HrefOrID) {"
                    } Else {
                        g.ControlFuncs .= "(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := """") {"
                    }
                    g.ControlFuncs .= CRLF . CRLF . "}" . CRLF

                } Else {
                    g.ControlFuncs .= ":" . CRLF . "Return" . CRLF
                }
            }
        }
    }

    ; Position/size
    GuiControlGet Pos, %Child%: Pos, %hCtl%
    If (EdtX != PosX || EdtY != PosY || EdtW != PosW || EdtH != PosH) {
        GuiControl MoveDraw, %hCtl%, x%EdtX% y%EdtY% w%EdtW% h%EdtH%
        g[hCtl].x := EdtX
        g[hCtl].y := EdtY
        g[hCtl].w := EdtW
        g[hCtl].h := EdtH

        If (hCtl == hReszdCtl) {
            HideResizers()
        }
    }

    ; Options tab
    SetCtlOptions(hCtl)
    g[hCtl].Extra := EdtCtlOpts ; Additional options

    ; Styles tab
    If (EdtStyles != "") {
        g[hCtl].Styles := Trim(EdtStyles)
    }

    ; Control color for Progress, ListView and TreeView (native options)
    If (g[hCtl].Background != "" && !InStr(g[hCtl].Options, "+Background")) {
        g[hCtl].Options .= " +Background" . g[hCtl].Background
    }

    If (g[hCtl].TextColor != "" && !InStr(g[hCtl].Options, "+C" . g[hCtl].TextColor)) {
        g[hCtl].Options .= " +C" . g[hCtl].TextColor
    }

    g[hCtl].Options := Trim(g[hCtl].Options)

    ApplyControlOptions(hCtl)

    ApplyPropertiesEnd:

    ApplyWindowOptions()

    GenerateCode()

    If (A_GuiControl == "BtnOK") {
        Gui Properties: Hide
    }
Return

OnDropDownChange:
    Gui Properties: Default
    GuiControlGet ClassNN,, %hCbxClassNN%
    GuiControlGet g_Control, %Child%: hWnd, %ClassNN%
    CtlType := g[g_Control].Type

    If (ClassNN == "Window") {
        GuiControl,, CtlIcon, % "*Icon5 " . IconLib
        GuiControl,, GrpText, Title
        GuiControl Hide, BtnText
        GuiControl Enable, EdtText
        GuiControl Move, EdtText, w262
        GuiControl,, TxtVVar, &Name:
        GuiControl,, TxtGLabel, &Label:
        GuiControl Show, BtnWinLabel
        GuiControl Hide, ChkFunction
        GuiControl Disable, ChkAnchorX
        GuiControl Disable, ChkAnchorY
        GuiControl Disable, ChkAnchorW
        GuiControl Disable, ChkAnchorH
        GuiControl Disable, ChkMoveDraw
        GuiControl Show, TxtCtlsOnly
        GuiControl Hide, EdtCtlOpts
    } Else {
        GuiControl,, GrpText, Text
        GuiControl Show, BtnText
        GuiControl Move, EdtText, w189
        If (RegExMatch(CtlType, "^(TreeView|ActiveX|Separator)$")) {
            GuiControl Disable, EdtText
            GuiControl Disable, BtnText
        } Else {
            GuiControl Enable, EdtText
            GuiControl Enable, BtnText
        }

        GuiControl,, TxtVVar, &v-Var:
        GuiControl,, TxtGLabel, &g-Label:
        GuiControl Show, ChkFunction
        GuiControl Hide, BtnWinLabel
        GuiControl Enable, ChkAnchorX
        GuiControl Enable, ChkAnchorY
        GuiControl Enable, ChkAnchorW
        GuiControl Enable, ChkAnchorH
        GuiControl Enable, ChkMoveDraw
        GuiControl Hide, TxtCtlsOnly
        GuiControl Show, EdtCtlOpts
        GuiControl,, CtlIcon, % "*Icon" . Default[CtlType].IconIndex . " " . IconLib
    }

    GoSub LoadProperties

    EnableColorControls(CtlType)
Return

EnableColorControls(CtlType) {
    If (RegExMatch(CtlType, "^(ListView|TreeView|Progress|Button|CheckBox|Radio|GroupBox|CommandLink|Edit|Text|Picture|Link|ListBox|Slider)$")) {
        Action := "Enable"
    } Else {
        Action := "Disable"
    }

    GuiControl %Action%, ChkBGColor
    GuiControl %Action%, BtnBGColor
    GuiControl %Action%, ChkFGColor
    GuiControl %Action%, BtnFGColor
}

ReloadControlList:
    CurClassNN := Properties_GetClassNN()
    Properties_Reload()
    GuiControl Properties: ChooseString, CbxClassNN, %CurClassNN%
    GoSub OnDropDownChange
Return

AdjustPosition:
    Gui Properties: Submit, NoHide
    If (CbxClassNN != "Window") {
        GuiControl %Child%: MoveDraw, %g_Control%, x%EdtX% y%EdtY% w%EdtW% h%EdtH%
    } Else {
        MoveChildWindow(EdtX, EdtY, EdtW, EdtH)
    }
Return

RequireHWndVar:
    GuiControlGet EdtHWndVar, Properties:, EdtHWndVar
    If (EdtHWndVar == "") {
        GuiControl,, EdtHWndVar, % GenerateVarName(Properties_GetHandle())
    }
Return

ResetProperties() {
    GuiControl,, EdtText
    GuiControl,, ChkAnchorX, 0
    GuiControl,, ChkAnchorY, 0
    GuiControl,, ChkAnchorW, 0
    GuiControl,, ChkAnchorH, 0
    GuiControl,, ChkMoveDraw, 0
    GuiControl,, ChkBGColor, 0
    GuiControl +BackgroundDefault, BGColorPreview
    GuiControl,, ChkFGColor, 0
    GuiControl +BackgroundDefault, FGColorPreview
}

SelectColor:
    Caller := A_GuiControl

    If (ChooseColor(Color, hPropWnd)) {
        PartName := SubStr(Caller, 4)
        GuiControl +Background%Color%, %PartName%Preview
        GuiControl,, Chk%PartName%, 1

        If (PartName == "WinColor") {
            If (Color == 0xFFFFFF) {
                Color := "White"
            }

            g.Window.Color := "" . Color

        } Else {
            hCtl := Properties_GetHandle()

            If (PartName == "BGColor") {
                If (g[hCtl].Type ~= "(Progress|ListView|TreeView)") {
                    g[hCtl].Background := Color
                } Else {
                    g[hCtl].BGColor := "" . Color
                }
            } Else {
                If (g[hCtl].Type ~= "(Progress|ListView|TreeView)") {
                    g[hCtl].TextColor := Color
                } Else {
                    g[hCtl].FGColor := "" . Color
                }
            }

            GoSub RequireHWndVar

            If (g.Window.hWndVar == "") {
                g.Window.hWndVar := "hMainWnd"
            }
        }
    }
Return

ChooseTrayIcon:
    IconResource := (g.Window.Icon != "") ? g.Window.Icon : g_IconPath
    IconIndex := g.Window.IconIndex

    If (ChooseIcon(IconResource, IconIndex, hPropWnd)) {
        StringReplace IconResource, IconResource, %A_WinDir%\System32\
        g.Window.Icon := g_IconPath := IconResource
        g.Window.IconIndex := IconIndex
        Gui Properties: Default
        GuiControl,, TrayIcon, % "*Icon" . IconIndex . " " . IconResource
        GuiControl,, ChkTrayIcon, 1
    }
Return

ShowIconPath:
    If (!Icon := g.Window.Icon) {
        Icon := A_AhkPath
    }
    MsgBox 0x2040, Icon Location, % Icon . ", " . g.Window.IconIndex
Return

; Update the drop-down list
Properties_Reload() {
    Gui Properties: Default
    GuiControl,, CbxClassNN, |Window||

    PrevControl := ""
    WinGet ControlList, ControlList, ahk_id %hChildWnd%
    Loop Parse, ControlList, `n
    {
        ; Omit the Edit inside a ComboBox
        If (PrevControl ~= "ComboBox" && A_LoopField ~= "^Edit") {
            GuiControlGet hComboBox, %Child%: hWnd, %PrevControl%
            GuiControlGet hEdit, %Child%: hWnd, %A_LoopField%
            If (hComboBox = hEdit) {
                Continue
            }
        }

        If (A_LoopField ~= "SysHeader|AtlAxWin") {
            Continue
        }

        If (A_LoopField == "msctls_statusbar321") {
            If !(IsWindowVisible(GetHandle(A_LoopField))) {
                Continue
            }
        }

        GuiControlGet hWnd, %Child%: hWnd, %A_LoopField%

        If (IsResizer(hWnd)) {
            Continue
        }

        g[hWnd].ClassNN := A_LoopField
        Properties_AddItem(A_LoopField)
        PrevControl := A_LoopField
    }
    GoSub OnDropDownChange
}

GetHandle(ClassNN) {
    GuiControlGet hWnd, %Child%: hWnd, %ClassNN%
    Return hWnd
}

MenuSetCtlOption:
    MenuItem := A_ThisMenuItem

    If (MenuItem == "Explorer Theme") {
        GoSub SetExplorerTheme
        Return
    }

    If (MenuItem == "Hint Text...") {
        GoSub SetHintText
        Return
    }

    If (MenuItem == "Text Alignment...") {
        GoSub SetTextAlignment
        Return
    }

    If (MenuItem == "View Mode...") {
        GoSub SetListViewMode
        Return
    }

    Option := g_ControlOptions[MenuItem]
    Options := g[g_Control].Options

    If (InStr(Options, Option)) {
        g[g_Control].Options := Trim(StrReplace(Options, Option)) ; Remove
        Check := 0

    } Else {
        ; Enough of mutually exclusive options.
        If (Option == "+Uppercase") {
            Options := RegExReplace(Options, "\s?\+Lowercase")
        } Else If (Option == "+Lowercase") {
            Options := RegExReplace(Options, "\s?\+Uppercase")
        }

        g[g_Control].Options := Options . Space(Options) . Option ; Add
        Check := 1
    }

    ApplyControlOptions(g_Control)

    If (MenuItem == "Vertical Line") {
        OrientSeparator(g_Control)
    }

    If (g[g_Control].ClassNN == Properties_GetClassNN()) {
        TVCheckOption(hTVCtlOpts, MenuItem, Check)
    }

    GenerateCode()
Return

MenuSetCtlOptAuxFunc(hCtl, NewOption, RegEx) {
    If (A_Gui != "Properties") {
        Options := Trim(RegExReplace(g[hCtl].Options, RegEx))
        g[hCtl].Options := Options . Space(Options) . NewOption
        ApplyControlOptions(hCtl)
        GenerateCode()
    }
}

OrientSeparator(hCtl) {
    GuiControlGet Pos, %Child%: Pos, %hCtl%
    GuiControl %Child%: Move, %hCtl%, w%PosH% h%PosW%
    Properties_UpdateCtlPos()
    HideResizers()
}

; Windows Explorer Theme for ListViews and TreeViews
SetExplorerTheme:
    If (!g_NT6orLater) {
        Gui Auto: +OwnDialogs
        MsgBox 0x10, AutoGUI, This option requires Windows Vista or higher.
        Return
    }

    g[g_Control].ExplorerTheme := !g[g_Control].ExplorerTheme

    If (g[g_Control].hWndVar == "") {
        g[g_Control].hWndVar := GenerateVarName(g_Control)
        If (g[g_Control].ClassNN == Properties_GetClassNN()) {
            GuiControl, Properties:, EdtHWndVar, % g[g_Control].hWndVar
        }
    }

    If (A_Gui != "Properties") {
        If (g[g_Control].ClassNN == Properties_GetClassNN()) {
            TVCheckOption(hTVCtlOpts, "Explorer Theme", g[g_Control].ExplorerTheme)
        }

        GenerateCode()        
    }
Return

; Hint Text (EM_SETCUEBANNER) for Edits and ComboBoxes
SetHintText:
    SetModalWindow(1)

    HintText := InputBoxEx("Hint Text", "A message to be displayed when the " . g[g_Control].Type . " control is empty.", g[g_Control].Type . " Property", "Search",,, hAutoWnd,,, IconLib, 14)

    If (!ErrorLevel) {
        g[g_Control].HintText := HintText

        If (g[g_Control].hWndVar == "") {
            g[g_Control].hWndVar := GenerateVarName(g_Control)
        }

        If (g[g_Control].ClassNN == Properties_GetClassNN()) {
            ItemID := TVGetOption(hTVCtlOpts, "Hint Text", 1)
            TV_Modify(ItemID, "Check", "Hint Text: " . HintText)
            GuiControl,, EdtHWndVar, % g[g_Control].hWndVar
        }

        If (A_Gui != "Properties") {
            GenerateCode()
        }
    }

    SetModalWindow(0)
Return

SetListViewMode:
    SetModalWindow(1)

    ViewMode := InputBoxEx("View Mode", "Select the ListView viewing mode.", "ListView Property", "Report||List|Icons|Small Icons|Tile", "DDL",, hAutoWnd,,, IconLib, 57)

    If (!ErrorLevel) {
        If (ViewMode == "Icons") {
            ViewMode := "Icon"
        } Else If (ViewMode == "Small Icons") {
            ViewMode := "IconSmall"
        }

        ViewMode := "+" . ViewMode
        g[g_Control].ViewMode := ViewMode

        If (g[g_Control].ClassNN == Properties_GetClassNN()) {
            ItemID := TVGetOption(hTVCtlOpts, "View Mode", 1)
            TV_Modify(ItemID, "Check", "View Mode: " . ViewMode)
            SetCtlOptions(g_Control)
        }

        MenuSetCtlOptAuxFunc(g_Control, ViewMode, "\s?(\+Report|\+List|\+Icon|\+IconSmall|\+Tile)\b")
    }

    SetModalWindow(0)
Return

SetTextAlignment:
    SetModalWindow(1)

    Alignment := InputBoxEx("Text Alignment",, g[g_Control].Type " Property", "Left||Center|Right", "DDL",, hAutoWnd)

    If (!ErrorLevel) {
        Alignment := "+" . Alignment
        g[g_Control].Alignment := Alignment

        If (g[g_Control].ClassNN == Properties_GetClassNN()) {
            ItemID := TVGetOption(hTVCtlOpts, "Text Alignment", 1)
            TV_Modify(ItemID, "Check", "Text Alignment: " . Alignment)
            SetCtlOptions(g_Control)
        }

        MenuSetCtlOptAuxFunc(g_Control, Alignment, "\s?(\+Left|\+Center|\+Right)\b")
    }

    SetModalWindow(0)
Return

ShowControlOptions:
    If (g_Control == "") {
        g_Control := g.LastControl
    }

    GoSub ShowProperties
    GuiControl Choose, %hPropTab%, 2
Return

ShowWindowOptions:
    GoSub ShowProperties
    GuiControl Choose, %hPropTab%, 5
Return

Space(String) {
    Return (String != "") ? " " : ""
}

Properties_AddItem(ClassNN) {
    GuiControl, Properties:, CbxClassNN, %ClassNN%
}

Properties_GetClassNN() {
    GuiControlGet ClassNN, Properties:, %hCbxClassNN%
    Return ClassNN
}

Properties_GetHandle() {
    GuiControlGet ClassNN, Properties:, %hCbxClassNN%
    GuiControlGet hWnd, %Child%: hWnd, %ClassNN%
    Return hWnd
}

Properties_ShowFontInfo(FontName, FontOptions) {
    Global hLVFontOpts
    Gui Properties: Default
    Gui ListView, %hLVFontOpts%
    RegExMatch(FontOptions, "(s\d+)?(.*)", Match) ; ?
    RegExMatch(Match2, "(\bc.*)", Color)
    Style := StrReplace(Match2, Color1)
    LV_Modify(1, "Col2", FontName)
    LV_Modify(2, "Col2", Trim(Style))
    LV_Modify(3, "Col2", SubStr(Match1, 2)) ; Size
    LV_Modify(4, "Col2", SubStr(Color1, 2))
}

Properties_UpdateCtlPos() {
    If (hCtl := Properties_GetHandle()) {
        GuiControlGet Pos, %Child%: Pos, %hCtl%
        Gui Properties: Default
        GuiControl,, EdtX, %PosX%
        GuiControl,, EdtY, %PosY%
        GuiControl,, EdtW, %PosW%
        GuiControl,, EdtH, %PosH%
    }
}

Properties_UpdateWinPos() {
    If (Properties_GetClassNN() == "Window") {
        Gui Properties: Default
        WI := GetWindowInfo(hChildWnd)
        GuiControl,, EdtX, % WI.ClientX
        GuiControl,, EdtY, % WI.ClientY
        GuiControl,, EdtW, % WI.ClientW
        GuiControl,, EdtH, % WI.ClientH
    }
}

MoveChildWindow(X, Y, Width, Height) {
    WI := GetWindowInfo(hChildWnd)
    X := X + (WI.WindowX - WI.ClientX)
    Y := Y + (WI.WindowY - WI.ClientY)
    W := Width + (WI.WindowW - WI.ClientW)
    H := Height + (WI.WindowH - WI.ClientH)
    WinMove ahk_id %hChildWnd%,, %X%, %Y%, %W%, %H%
}

ShowMoreEvents() {
    Run %A_ScriptDir%\Tools\Constantine.ahk /key Windows\GUI\Window\Messages
}

IsLabelAvailable(Label, ItemIndex) {
    For Index, Item in g.ControlList {
        If (Index >= ItemIndex) {
            Return True
        }

        If (g[Item].gLabel == Label) {
            Return False
        }
    }
    Return True
}

; Retrieve control options
SetCtlOptions(hCtl) {
    Global
    Gui Properties: TreeView, %hTVCtlOpts%

    CtlOpts := ""
    ItemID := 0
    Loop {
        ItemID := TV_GetNext(ItemID, "Checked")
        If !(ItemID) {
            Break
        }

        TV_GetText(Option, ItemID)
        OptVal := g_ControlOptions[Option]
        If (OptVal != "") {
            CtlOpts .= OptVal . " "

        } Else {
            If (InStr(Option, "View Mode") && g[hCtl].ViewMode != "") {
                CtlOpts .= g[hCtl].ViewMode . " "
            } Else If (InStr(Option, "Text Alignment") && g[hCtl].Alignment != "") {
                CtlOpts .= g[hCtl].Alignment . " "
            }
        }
    }

    ItemID := TVGetOption(hTVCtlOpts, "View Mode", 1)
    If !(IsTVItemChecked(hTVCtlOpts, ItemID)) {
        TV_Modify(ItemID, "", "View Mode...")
        g[hCtl].ViewMode := ""
    }

    ItemID := TVGetOption(hTVCtlOpts, "Text Alignment", 1)
    If !(IsTVItemChecked(hTVCtlOpts, ItemID)) {
        TV_Modify(ItemID, "", "Text Alignment...")
        g[hCtl].Alignment := ""
    }

    ItemID := TVGetOption(hTVCtlOpts, "Hint Text", 1)
    If !(IsTVItemChecked(hTVCtlOpts, ItemID)) {
        TV_Modify(ItemID, "", "Hint Text...")
        g[hCtl].HintText := ""
    }

    g[hCtl].Options := RTrim(CtlOpts)
}

IsCtlOptionSet(Option, CtlOpts, hCtl := 0) {
    If (Option == "Explorer Theme") {
        Return g[hCtl].ExplorerTheme
    }

    Loop % CtlOpts.Length() {
        If (CtlOpts[A_Index] == g_ControlOptions[Option]) {
            Return True
        }
    }
    Return False
}

; Retrieve GUI options
SetWinOptions() {
    Global
    Gui Properties: TreeView, %hTVWinOpts%

    WinOpts := ""
    ItemID := 0
    Loop {
        ItemID := TV_GetNext(ItemID, "Checked")
        If !(ItemID) {
            Break
        }

        TV_GetText(Option, ItemID)
        OptVal := g_WindowOptions[Option]
        If (OptVal != "") {
            WinOpts .= OptVal . " "
        }
    }

    g.Window.Options := RTrim(WinOpts)
}

IsWinOptionSet(Option, WinOpts) {
    Loop % WinOpts.Length() {
        If (WinOpts[A_Index] == g_WindowOptions[Option]) {
            Return True
        }
    }
    Return False
}

/*
LVCheckOption(hLV, Option, Check := True) {
    Gui Properties: Default
    Gui Properties: ListView, %hLV%

    Loop {
        Row := LV_GetNext(Row)
        If (!Row) {
            Break
        }

        LV_GetText(ItemText, Row)
        If (ItemText = Option) { ; ==
            LV_Modify(Row, Check ? "Check" : "-Check")
            Break
        }
    }
}
*/

TVGetOption(hTV, Option, MatchMode := 0) {
    Gui Properties: Default
    Gui Properties: TreeView, %hTV%

    ItemID := 0
    Loop {
        ItemID := TV_GetNext(ItemID, "Full")
        If !(ItemID) {
            Return 0
        }

        TV_GetText(ItemText, ItemID)
        If (MatchMode == 1) {
            If (InStr(ItemText, Option)) {
                Return ItemID
            }
        } Else {
            If (ItemText == Option) {
                Return ItemID
            }
        }
    }
}

TVCheckOption(hTV, Option, Check := True) {
    Gui Properties: Default
    Gui Properties: TreeView, %hTV%

    ItemID := 0
    Loop {
        ItemID := TV_GetNext(ItemID, "Full")
        If !(ItemID) {
            Break
        }

        TV_GetText(ItemText, ItemID)
        If (ItemText == Option) {
            TV_Modify(ItemID, Check ? "Check" : "-Check")
            Break
        }
    }
}

TVCtlOptsHandler:
    Gui Properties: TreeView, %hTVCtlOpts%

    If !(A_EventInfo) {
        Return
    }

    hCtl := Properties_GetHandle()

    If (A_GuiEvent == "Normal") {
        ItemID := A_EventInfo
        TV_Modify(ItemID, "Select")
        TV_GetText(ItemText, ItemID)

        ; Check the item when clicked on item text
        If !(TVHitTest(hTVCtlOpts) & 0x40) { ; TVHT_ONITEMSTATEICON
            If (IsTVItemChecked(hTVCtlOpts, ItemID)) {
                TVCheckOption(hTVCtlOpts, ItemText, 0)
            } Else {
                TVCheckOption(hTVCtlOpts, ItemText, 1)
            }
        }

        If (ItemText == "Explorer Theme") {
            GoTo SetExplorerTheme
        }

        /*
        If (ItemText == "Full Row Select" && IsTVItemChecked(hTVCtlOpts, ItemID)) {
            TVCheckOption(hTVCtlOpts, "No Dotted Lines", 1)
        }
        */

        If (ItemText == "Vertical Line") {
            OrientSeparator(hCtl)
        }
    }

    If (A_GuiEvent == "DoubleClick") {

        If (InStr(ItemText, "View Mode")) {
            GoSub SetListViewMode

        } Else If (InStr(ItemText, "Hint Text")) {
            GoSub SetHintText

        } Else If (InStr(ItemText, "Text Alignment")) {
            GoSub SetTextAlignment
        }
    }
Return

TVWinOptsHandler:
    Gui Properties: TreeView, %hTVWinOpts%

    If (A_EventInfo && A_GuiEvent == "Normal") {
        ItemID := A_EventInfo
        TV_Modify(ItemID, "Select")
        TV_GetText(ItemText, ItemID)

        If !(TVHitTest(hTVWinOpts) & 0x40) { ; TVHT_ONITEMSTATEICON
            If (IsTVItemChecked(hTVWinOpts, ItemID)) {
                TVCheckOption(hTVWinOpts, ItemText, 0)
            } Else {
                TVCheckOption(hTVWinOpts, ItemText, 1)
            }
        }

        If (ItemText == "Center on Screen") {
            g.Window.Center := !g.Window.Center
            TVCheckOption(hTVWinOpts, ItemText, g.Window.Center)

        } Else If (ItemText == "Help Button" && IsTVItemChecked(hTVWinOpts, ItemID)) {
            TVCheckOption(hTVWinOpts, "Resizable", 0)
            TVCheckOption(hTVWinOpts, "Tool Window", 0)
            TVCheckOption(hTVWinOpts, "No System Menu", 0)
            TVCheckOption(hTVWinOpts, "No Minimize Box", 1)
        }
    }
Return

IsTVItemChecked(hTV, ItemID) {
    Gui Properties: TreeView, %hTV%
    PrevID := TV_GetPrev(ItemID)
    NextID := TV_GetNext(PrevID, "Checked")
    Return ItemID == NextID
}

GenerateVarName(hCtl, Prepend := "h") {
    CtlType := g[hCtl].Type
    CtlText := g[hCtl].Text

    If (RegExMatch(g[hCtl].Class, "(List|Comb|Tree)")) {
        CtlName := "Items"

    } Else If (StrLen(CtlText) < 20 && (g[hCtl].Class == "Button" || CtlType == "Text")) {
        CtlName := StrReplace(g[hCtl].Text, "&")
        StringUpper CtlName, CtlName, T
        CtlName := RegExReplace(CtlName, "\W")

    } Else If (CtlType == "Edit") {
        CtlName := "Value"

    } Else If (CtlType == "Picture") {
        SplitPath % g[hCtl].Text,,,, NameNoExt
        StringUpper NameNoExt, NameNoExt, T
        CtlName := RegExReplace(NameNoExt, "\W")
    }

    Instance := GetInstanceNumber(hCtl, CtlType)
    If (Instance > 1) {
        CtlName .= Instance
    }

    Return Prepend . Default[CtlType].Prefix . CtlName
}

GetInstanceNumber(hCtl, CtlType) {
    Count := 0
    For Each, Item in g.ControlList {
        If (g[Item].Deleted) {
            Continue
        }

        If (g[Item].Type == CtlType) {
            Count++
        }

        If (g[Item].Handle == hCtl) {
            Break
        }
    }
    Return Count
}

SuggestHWndVar:
    hCtl := Properties_GetHandle()
    GuiControl Properties:, EdtHWndVar, % (hCtl != "" ? GenerateVarName(hCtl) : "hMainWnd")
Return

SuggestVVar:
    hCtl := Properties_GetHandle()
    GuiControl Properties:, EdtVVar, % (hCtl != "" ? GenerateVarName(hCtl, "") : "Main")
Return

SuggestWinLabel:
    GuiControl Properties:, EdtGLabel, Main
Return

ApplyControlOptions(hCtl) {
    ; Reset styles
    CtlType := g[hCtl].Type
    Control Style, % Default[CtlType].Style,, ahk_id %hCtl%
    Control ExStyle, % Default[CtlType].ExStyle,, ahk_id %hCtl%

    If (g[hCtl].Options != "" || g[hCtl].Extra != "" || g[hCtl].Styles != "") {
        Options := g[hCtl].Options . " " . g[hCtl].Extra . " " . g[hCtl].Styles

        Try {
            GuiControl %Child%: %Options%, %hCtl%
        }

        SetWindowPos(hCtl, 0, 0, 0, 0, 0, 0x37)

        If (CtlType == "Picture") {
            If (RegExMatch(EdtCtlOpts, "Icon(\d+)", Index)) {
                GuiControl %Child%:, %hCtl%, % "*Icon" . Index1 . " " . g[hCtl].Text
            }
        } Else If (CtlType == "StatusBar") {
            WinGetPos,,, WinW,, ahk_id %hChildWnd%
            WinMove ahk_id %hChildWnd%,,,, % WinW + 1
            WinMove ahk_id %hChildWnd%,,,, % WinW
        }
    }
}

ApplyWindowOptions() {
    ; Reset styles
    WinSet Style, 0x94CF0000, ahk_id %hChildWnd% ; 0x94CA0000 when executed.
    WinSet ExStyle, 0x100, ahk_id %hChildWnd%

    If (g.Window.Options != "" || g.Window.Extra != "" || g.Window.Styles != "") {
        Options := g.Window.Options . " " . g.Window.Extra . " " . g.Window.Styles

        Options := RegExReplace(Options, "(-Caption|\+AlwaysOnTop|\+Owner)")

        Try {
            Gui % Child . ":" . Options
        }
    }
}

EnableBGColor:
    GuiControlGet Enabled,, ChkBGColor
    If !(Enabled) {
        hCtl := Properties_GetHandle()
        If (g[hCtl].Type ~= "(Progress|ListView|TreeView)") {
            GuiControl +BackgroundDefault, BGColorPreview
            GuiControl +BackgroundDefault, %hCtl%
            g[hCtl].Options := RegExReplace(g[hCtl].Options, "\s\+Background\w+")
            g[hCtl].Background := ""
        } Else {
            g[hCtl].BGColor := ""
        }
    }
Return

EnableFGColor:
    GuiControlGet Enabled,, ChkFGColor
    If !(Enabled) {
        hCtl := Properties_GetHandle()
        If (g[hCtl].Type ~= "(Progress|ListView|TreeView)") {
            GuiControl +BackgroundDefault, FGColorPreview
            GuiControl +CDefault, %hCtl%
            g[hCtl].Options := RegExReplace(g[hCtl].Options, "\s\+C" . g[hCtl].TextColor)
            g[hCtl].TextColor := ""
        } Else {
            g[hCtl].FGColor := ""
        }
    }
Return

LoadColorPreview(Foo, Value) {
    GuiControl,, Chk%Foo%Color, 1
    GuiControl +Background%Value%, %Foo%ColorPreview
}

LoadStylesData() {
    Static Loaded := False
    If (Loaded) {
        Return
    }

    IniStyles := A_ScriptDir . "\Include\Styles.ini"
    IniRead Sections, %IniStyles%
    aSections := StrSplit(Sections, "`n")

    g_oStyles := {}

    Loop % aSections.Length() {
        Class := aSections[A_Index]
        g_oStyles[Class] := {}

        IniRead Section, %IniStyles%, %Class%

        Loop Parse, Section, `n
        {
            aPair := StrSplit(A_LoopField, "=")
            g_oStyles[Class].Push([aPair[1], aPair[2]])
        }
    }

    Loaded := True
}

LoadStyles(Class, ListBox, Append := False) {
    IsChild := (Class == "Window" && g_Control == "") ? False : True

    Items := (Append ? "" : "|")
    Loop % g_oStyles[Class].Length() {
        Key := g_oStyles[Class][A_Index][1]

        If (IsChild && (Key == "WS_MAXIMIZEBOX" || Key == "WS_MINIMIZEBOX" || Key == "WS_OVERLAPPED")) {
            Continue
        }

        If (!IsChild && (Key == "WS_TABSTOP" || Key == "WS_GROUP")) {
            Continue
        }

        If (StrLen(Key) > 25) {
            Key := SubStr(Key, 1, 24) . "..."
        }

        Items .= Key . "`t" . g_oStyles[Class][A_Index][2] . "|"
    }

    GuiControl, Properties:, %ListBox%, %Items%
}

LoadStylesTab(hWnd) {
    Class := g[hWnd].Class

    ; Delete the third styles tab
    SendMessage 0x1308, 2, 0,, ahk_id %hTabStyles% ; TCM_DELETEITEM
    If (ErrorLevel == True) {
        GuiControl Hide, LbxExLV
        GuiControl Show, LbxStyles
        SendMessage 0x1330, 0, 0,, ahk_id %hTabStyles% ; TCM_SETCURFOCUS
        Sleep 0
        SendMessage 0x130C, 0, 0,, ahk_id %hTabStyles% ; TCM_SETCURSEL
    }

    If (Class == "SysListView32") {
        Tab_AddItem(hTabStyles, "Extended ListView")
        LoadStyles("SysListView32Ex", "LbxExLV")
        Repaint(hTabStyles)
    }

    LoadStyles(Class, "LbxStyles")
    LoadStyles("Window", "LbxStyles", 1)
    LoadStyles("WindowEx", "LbxExStyles")

    GuiControl Properties:, EdtStyles, % (hWnd != "") ? g[hWnd].Styles : g.Window.Styles
    GuiControl Properties:, EdtStylesSum
}

Tab_AddItem(hTab, Text) {
    VarSetCapacity(TCITEM, 16 + A_PtrSize * 3, 0)
    NumPut(0x1, TCITEM, 0, "UInt") ; TCIF_TEXT
    NumPut(&Text, TCITEM, 8 + A_PtrSize, "Ptr")
    SendMessage 0x1304, 0, 0,, ahk_id %hTab% ; TCM_GETITEMCOUNT
    SendMessage 0x133E, %ErrorLevel%, &TCITEM, , ahk_id %hTab% ; TCM_INSERTITEMW
}

PropTabHandler:
    GuiControlGet PropTab, Properties:, %hPropTab%
    If (PropTab == 3) {
        LoadStylesTab(Properties_GetHandle())
    }
Return

StylesTabHandler:
    If (A_GuiEvent == "N") {
        Code := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")
        If (Code == -551) { ; TCN_SELCHANGE
            SendMessage 0x130B, 0, 0,, ahk_id %hTabStyles% ; TCM_GETCURSEL
            nTab := Errorlevel + 1
            If (nTab == 1) {
                Lbx := "LbxStyles"
                GuiControl Hide, LbxExStyles
                GuiControl Hide, LbxExLV
                GuiControl Show, LbxStyles
            } Else If (nTab == 2) {
                Lbx := "LbxExStyles"
                GuiControl Hide, LbxStyles
                GuiControl Hide, LbxExLV
                GuiControl Show, LbxExStyles
            } Else If (nTab == 3) {
                Lbx := "LbxExLV"
                GuiControl Hide, LbxStyles
                GuiControl Hide, LbxExStyles
                GuiControl Show, LbxExLV
            }

            ShowStylesSum(Lbx)
        }
    }
Return

ShowStylesSum(Lbx) {
    Global
    Gui Properties: Default

    GuiControlGet Items,, %Lbx%

    Sum := 0
    Loop Parse, Items, |
    {
        StringSplit Field, A_LoopField, `t
        Sum += Field2
    }

    GuiControl,, EdtStylesSum, % Format("0x{:08X}", Sum)
}

LbxStylesHandler:
    ShowStylesSum(A_GuiControl)
Return

CreateStylesToolbar() {
    Buttons := "Add`n-`nRemove`n-`nOverwrite`n-`nDefault`n-`nReset"
    Return ToolbarCreate("OnStylesToolbar", Buttons,, "Flat List TextOnly Tooltips", "", "x14 y351 w295 h24")
}

OnStylesToolbar(hWnd, Event, Text, Pos, Id) {
    Global

    If (Event != "Click") {
        Return
    }

    Gui Properties: Submit, NoHide

    SendMessage 0x130B, 0, 0,, ahk_id %hTabStyles% ; TCM_GETCURSEL
    StylesTab := Errorlevel + 1

    If (StylesTab == 3) {
        Prefix := "LV"
        hLbx := hLbxExLV
    } Else If (StylesTab == 2) {
        Prefix := "E"
        hLbx := hLbxExStyles
    } Else {
        hLbx := hLbxStyles
        Prefix := ""
    }

    If (Text == "Add") {
        Sign := "+"

    } Else If (Text == "Remove") {
        Sign := "-"

    } Else If (Text == "Overwrite") {
        Sign := ""

    } Else If (Text == "Default") {

        hCtl := Properties_GetHandle()
        If (hCtl) {
            Class := g[hCtl].Class
            CtlType := g[hCtl].Type

            If (StylesTab == 1) {
                Style := Default[CtlType].Style
            } Else If (StylesTab == 2) {
                Style := Default[CtlType].ExStyle
            } Else If (StylesTab == 3) {
                Style := Default[CtlType].ExExStyle ; ListView
            }
        } Else { ; Window
            Style := (StylesTab == 1) ? 0x94CA0000 : 0x100
        }

        DefStyle := Style

        Type := 0
        If (Class == "Button") {
            Type := Style & 0xF ; BS_TYPEMASK
            Style &= ~Type
        } Else If (Class == "SysListView32") {
            Type := Style & 0x3 ; LVS_TYPEMASK
            Style &= ~Type
        } Else If (Class == "Static") {
            Type := Style & 0x1F ; SS_TYPEMASK
            Style &= ~Type
        }

        ControlGet Items, List,,, ahk_id %hLbx%
        Loop Parse, Items, `n
        {
            Value := StrSplit(A_LoopField, "`t")[2]
            If (Style & Value || Type == Value) {
                Style &= ~Value
                GuiControl Choose, %hLbx%, %A_Index%
            }
        }

        SendMessage 0x115, 6, 0,, ahk_id %hLbx% ; WM_VSCROLL: scroll to top.
        WinSet Redraw,, ahk_id %hLbx%
        GuiControl,, EdtStylesSum, % Format("0x{:08X}", DefStyle)
        Return

    } Else If (Text == "Reset") {
        SendMessage 0x185, 0, -1,, ahk_id %hLbxStyles% ; LB_SETSEL
        SendMessage 0x185, 0, -1,, ahk_id %hLbxExStyles%
        SendMessage 0x185, 0, -1,, ahk_id %hLbxExLV%
        GuiControl,, EdtStyles
        GuiControl,, EdtStylesSum
        Return
    }

    If (EdtStylesSum != 0 && EdtStylesSum != "") {
        GuiControl,, EdtStyles, % EdtStyles . Space(EdtStyles) . Sign . Prefix . Format("0x{:X}", EdtStylesSum)
    }
}

TVHitTest(hTV) {
    x64 := A_PtrSize == 8
    VarSetCapacity(TVHITTESTINFO, x64 ? 24 : 16, 0)

    VarSetCapacity(POINT, 8, 0)
    DllCall("GetCursorPos", "Ptr", &POINT)
    DllCall("ScreenToClient", "Ptr", hTV, "Ptr", &POINT)
    NumPut(NumGet(POINT, 0, "Int"), TVHITTESTINFO, 0, "Int")
    NumPut(NumGet(POINT, 4, "Int"), TVHITTESTINFO, 4, "Int")

    SendMessage 0x1111, 0, &TVHITTESTINFO,, ahk_id %hTV% ; TVM_HITTEST
    If (ErrorLevel && ErrorLevel != "FAIL") {
        Return NumGet(TVHITTESTINFO, 8, "UInt") ; flags
    }
}

DestroyProperties() {
    WinGetPos g_PropX, g_PropY,,, ahk_id %hPropWnd%
    Gui Properties: Destroy
}

GetClassNN(hCtrl) {
    WinGet ClassNNList, ControlList, ahk_id %hChildWnd%
    Loop Parse, ClassNNList, `n
    {
        GuiControlGet hWnd, %Child%: hWnd, %A_LoopField%
        If (hWnd == hCtrl) {
            Return A_LoopField
        }
    }
}
