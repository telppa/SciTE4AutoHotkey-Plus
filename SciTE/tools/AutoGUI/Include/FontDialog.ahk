WinShowFontDialog:
    g_Control := ""
ShowFontDialog:
    Gui FontDlg: New, +LabelFontDlg +hWndhFontDlg -MinimizeBox +OwnerAuto
    Gui Font, s9, Segoe UI
    Gui Color, 0xFEFEFE
    SetWindowIcon(hFontDlg, IconLib, 20)

    Gui Add, CheckBox, vChkFontName gPreviewFont x12 y12 w171 h23, Font name:
    Gui Add, Edit, vEdtFontName gDisplayFontName x12 y38 w171 h23, Ms Shell Dlg
    Gui Add, ListBox, vLbxFontName gDisplayFontName x12 y66 w171 h184 -HScroll +0x100
    ShowLessFonts()

    Gui Add, CheckBox, vChkFontWeight gPreviewFont x191 y12 w100 h23, Weight:
    Gui Add, Edit, vEdtFontWeight gDisplayFontWeight x191 y38 w100 h23, Norm
    Gui Add, ListBox, vLbxFontWeight gDisplayFontWeight x191 y66 w100 h49 +0x100, Regular|Semibold|Bold

    Gui Add, CheckBox, vChkFontSize gPreviewFont x299 y12 w58 h23, Size:
    Gui Add, Edit, vEdtFontSize gDisplayFontSize x299 y38 w58 h23, 8
    Gui Add, ListBox, vLbxFontSize gDisplayFontSize x299 y66 w58 h184 +0x100, 8|9|10|11|12|13|14|15|16|17|18|20

    Gui Add, CheckBox, vChkFontColor gPreviewFont x365 y12 w60 h23, Color:
    Gui Add, ListView
    , vFontColorPreview gChooseFontColor x453 y14 w16 h16 -Hdr +Border +BackgroundBlack AltSubmit
    Gui Add, ComboBox, vCbxFontColor gDisplayFontColor x365 y38 w106, Black||0x003399
    Gui Add, ListBox, vLbxFontColor gDisplayFontColor x365 y66 w107 h184 +0x100
    , Black|Blue|Navy|Green|Teal|Olive|Maroon|Red|Purple|Fuchsia|Lime|Yellow|Aqua|Gray|Silver|White

    Gui Add, CheckBox, vChkItalic gPreviewFont x191 y119 w100 h23, Italic
    Gui Add, CheckBox, vChkUnderline gPreviewFont x191 y141 w100 h23, Underline
    Gui Add, CheckBox, vChkStrikeout gPreviewFont x191 y163 w100 h23, Strikeout
    Gui Add, CheckBox, vChkQuality gPreviewFont x191 y202 w100 h21, Quality:
    Gui Add, DropDownList, vCbxQuality gCheckQuality x191 y227 w100 AltSubmit
    , Default||Draft|Proof|Non-antialiased|Antialiased|Cleartype

    Gui Add, Text, vSampleText x12 y258 w461 h44 +0x201 +E0x200, Automation. Hotkeys. Scripting

    Gui Add, Text, x-1 y310 w487 h48 -Background +Border
    Gui Add, CheckBox, vg_ShowAllFonts gShowAllFonts x12 y323 w171 h23 -Background, Show all fonts
    Gui Add, Button, gFontDlgOK x309 y322 w80 h24 +Default, OK
    Gui Add, Button, gFontDlgClose x395 y322 w80 h24, Cancel

    Gui Show, w485 h357, Font
    SetModalWindow(True)

    If (A_Gui == "Properties") {
        g_Control := Properties_GetHandle()
    }

    GoSub PopulateFontDialog
Return

FontDlgEscape:
FontDlgClose:
    SetModalWindow(False)
    Gui FontDlg: Hide
Return

ShowLessFonts() {
    Fonts := ["Segoe UI"
    , "Tahoma"
    , "Microsoft Sans Serif"
    , "Verdana"
    , "Trebuchet MS"
    , "Arial"
    , "Lucida Console"
    , "Consolas"
    , "Courier New"
    , "Calibri"
    , "Georgia"
    , "FixedSys"
    , "Comic Sans MS"
    , "Segoe Print"
    , "Segoe Script"
    , "MS Sans Serif"
    , "Impact"
    , "Palatino Linotype"
    , "Times New Roman"
    , "Source Code Pro"
    , "Ms Shell Dlg"
    , "Ms Shell Dlg 2"
    , "Webdings"
    , "Wingdings"]

    GuiControl,, LbxFontName, |
    Loop % Fonts.Length() {
        GuiControl,, LbxFontName, % Fonts[A_Index]
    }
}

PreviewFont:
    Gui FontDlg: Default

    Gui Font ; Reset
    GuiControl Font, SampleText

    GetFontOptions(FontName, Options)

    Separator := ""
    If (Options != "" && FontName != "") {
        Separator := ", "
    }

    Gui +LastFound
    WinSetTitle % "Font: " . FontName . Separator . Options

    If (Options != "" || FontName != "") {
        Gui Font, %Options%, %FontName%
        GuiControl Font, SampleText
    }
Return

DisplayFontName:
    Gui FontDlg: Submit, NoHide
    GuiControl,, ChkFontName, 1
    If (A_GuiControl != "EdtFontName") {
        GuiControl,, EdtFontName, %LbxFontName%
    } Else {
        GuiControl ChooseString, LbxFontName, %EdtFontName%
    }
    GoSub PreviewFont
Return

DisplayFontWeight:
    Gui FontDlg: Submit, NoHide
    GuiControl,, ChkFontWeight, 1
    If (A_GuiControl != "EdtFontWeight") {
        Weight := LbxFontWeight
        If (Weight == "Regular") {
            Weight := "Norm"
        } Else If (Weight == "Semibold") {
            Weight := "600"
        } Else {
            Weight := "Bold"
        }
        GuiControl,, EdtFontWeight, %Weight%
    } Else {
        Weight := EdtFontWeight
        If Weight is Integer
        {
            If (Weight < 551) {
                Weight := "Regular"
            } Else If (Weight > 550 && Weight < 612) {
                Weight := "Semibold"
            } Else {
                Weight := "Bold"
            }
        }
        GuiControl ChooseString, LbxFontWeight, %Weight%
    }
    GoSub PreviewFont
Return

CheckQuality:
    GuiControl,, ChkQuality, 1
    GoSub PreviewFont
Return

DisplayFontSize:
    Gui FontDlg: Submit, NoHide
    GuiControl,, ChkFontSize, 1
    If (A_GuiControl != "EdtFontSize") {
        GuiControl,, EdtFontSize, %LbxFontSize%
    } Else {
        GuiControl ChooseString, LbxFontSize, %EdtFontSize%
    }
    GoSub PreviewFont
Return

DisplayFontColor:
    Gui FontDlg: Submit, NoHide
    GuiControl,, ChkFontColor, 1
    If (A_GuiControl != "CbxFontColor") {
        GuiControl Text, CbxFontColor, %LbxFontColor%
    }
    GoSub PreviewFont
Return

ChooseFontColor:
    If (A_GuiEvent == "Normal") {
        FontColor := "0x0080C0"
        If (ChooseColor(FontColor, hFontDlg)) {
            Gui FontDlg: Default
            GuiControl +Background%FontColor%, FontColorPreview
            GuiControl Text, CbxFontColor, %FontColor%
            GuiControl,, ChkFontColor, 1
            GoSub PreviewFont
        }
    }
Return

GetFontOptions(ByRef FontName, ByRef Options) {
    Global

    Gui FontDlg: Default
    Gui Submit, NoHide

    FontName := "", Options := ""

    If (ChkFontName) {
        FontName := EdtFontName
    }
    If (ChkFontSize) {
        If (EdtFontSize != "") {
            Options .= "s" . EdtFontSize . " "
        }
    }
    If (ChkFontWeight) {
        If EdtFontWeight is Integer
            Options .= "w"
        Options .= EdtFontWeight . " "
    }
    If (ChkItalic) {
        Options .= "Italic "
    }
    If (ChkUnderline) {
        Options .= "Underline "
    }
    If (ChkStrikeout) {
        Options .= "Strike "
    }
    If (ChkQuality) {
        Options .= "q" . (CbxQuality - 1) . " "
    }
    If (ChkFontColor) {
        If (CbxFontColor != "") {
            Options .= "c" . CbxFontColor
            GuiControl +Background%CbxFontColor%, FontColorPreview
        }
    }
    Options := RTrim(Options)
}

FontDlgOK:
    GetFontOptions(FontName, FontOptions)

    Gui %Child%: Default
    Gui Font, %FontOptions%, %FontName%

    If (g_Control == "") {
        g.Window.FontName := FontName
        g.Window.FontOptions := FontOptions

        For Each, Item in g.ControlList {
            If (g[Item].FontName == "" && g[Item].FontOptions == "") {
                GuiControl Font, %Item%
            }
        }

        GuiControl Font, %hChildToolbar%

    } Else {
        g[g_Control].FontName := FontName
        g[g_Control].FontOptions := FontOptions

        GuiControl Font, %g_Control%
    }

    ClassNN := Properties_GetClassNN() ; ...
    If ((g_Control == "" && ClassNN == "Window" ) || (ClassNN == g[g_Control].ClassNN)) {
        Properties_ShowFontInfo(FontName, FontOptions)
    }

    Gui %Child%: Font
    GenerateCode()
    GoSub FontDlgClose
Return

PopulateFontDialog:
    If (g_Control != "") {
        FontName := g[g_Control].FontName
        Options  := g[g_Control].FontOptions
    } Else {
        FontName := g.Window.FontName
        Options  := g.Window.FontOptions
    }

    If (FontName != "") {
        GuiControl,, ChkFontName, 1
        GuiControl,, EdtFontName, %FontName%
        GuiControl ChooseString, LbxFontName, %FontName%
    }

    If (Options != "") {
        Options := StrSplit(Options, " ")
        Loop % Options.Length() {
            If (Options[A_Index] ~= "^w") {
                FontWeight := SubStr(Options[A_Index], 2)
                GuiControl,, ChkFontWeight, 1
                GuiControl,, EdtFontWeight, %FontWeight%
                If (FontWeight < 551) {
                    GuiControl ChooseString, LbxFontWeight, Regular
                } Else If (FontWeight > 550 && FontWeight < 612) {
                    GuiControl ChooseString, LbxFontWeight, Semibold
                } Else {
                    GuiControl ChooseString, LbxFontWeight, Bold
                }
            }
            If (Options[A_Index] = "Bold") {
                GuiControl,, ChkFontWeight, 1
                GuiControl,, EdtFontWeight, Bold
                GuiControl ChooseString, LbxFontWeight, Bold
            }
            If (Options[A_Index] = "Italic") {
                GuiControl,, ChkItalic, 1
            }
            If (Options[A_Index] = "Underline") {
                GuiControl,, ChkUnderline, 1
            }
            If (Options[A_Index] = "Strike") {
                GuiControl,, ChkStrikeout, 1
            }
            If (Options[A_Index] ~= "^q") {
                FontQuality := SubStr(Options[A_Index], 2)
                GuiControl,, ChkQuality, 1
                GuiControl Choose, CbxQuality, % (FontQuality + 1)
            }
            If (Options[A_Index] ~= "^s") {
                FontSize := SubStr(Options[A_Index], 2)
                GuiControl,, ChkFontSize, 1
                GuiControl,, EdtFontSize, % FontSize
                GuiControl ChooseString, LbxFontSize, %FontSize%
            }
            If (Options[A_Index] ~= "^c") {
                FontColor := SubStr(Options[A_Index], 2)
                GuiControl,, ChkFontColor, 1
                GuiControl ChooseString, LbxFontColor, %FontColor%
                GuiControl Text, CbxFontColor, %FontColor%
            }
        }
    }

    GoSub PreviewFont
Return

ShowAllFonts:
    Gui FontDlg: Submit, NoHide

    If (g_ShowAllFonts) {
        hDC := DllCall("GetDC", "Ptr", DllCall("GetDesktopWindow", "Ptr"), "Ptr")
        Callback := RegisterCallback("EnumFontsCallback", "F")
        DllCall("EnumFontFamilies", "Ptr", hDC, "Ptr", 0, "Ptr", Callback, "Ptr", lParam := 0)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)

        Sort g_FontList, D|
        GuiControl,, LbxFontName, % "|" . g_FontList
    } Else {
        ShowLessFonts()
    }
Return

EnumFontsCallback(lpelf) {
    FontName := StrGet(lpelf + 28, 32)
    If (SubStr(FontName, 1, 1) != "@") {
        g_FontList .= FontName . "|"
    }

    Return True
}
