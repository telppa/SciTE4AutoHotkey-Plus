; Auto-GUI load/apply/save settings

LoadSettings() {
    IniRead g_OpenDir, %IniFile%, Options, OpenDir, %A_MyDocuments%
    IniRead g_SaveDir, %IniFile%, Options, SaveDir, %A_MyDocuments%
    IniRead g_SciFontName, %IniFile%, Options, FontName, Lucida Console
    IniRead g_SciFontSize, %IniFile%, Options, FontSize, 10
    IniRead g_TabSize, %IniFile%, Options, TabSize, 4
    IniRead g_CaretWidth, %IniFile%, Options, CaretWidth, 1
    IniRead g_CaretStyle, %IniFile%, Options, CaretStyle, 1
    IniRead g_CaretBlink, %IniFile%, Options, CaretBlink, 500
    IniRead g_LineNumbers, %IniFile%, Options, LineNumbers, 0
    IniRead g_WordWrap, %IniFile%, Options, WordWrap, 1
    IniRead g_HighlightActiveLine, %IniFile%, Options, HighlightActiveLine, 0
    IniRead g_Highlights, %IniFile%, Options, Highlights, 1
    IniRead g_HITMode, %IniFile%, Options, HITMode, 1
    IniRead g_HITLimit, %IniFile%, Options, HITLimit, 2000
    IniRead g_IndentWithSpaces, %IniFile%, Options, IndentWithSpaces, 1
    IniRead g_IndentGuides, %IniFile%, Options, IndentGuides, 0
    IniRead g_ShowGrid, %IniFile%, Options, ShowGrid, 1
    IniRead g_SnapToGrid, %IniFile%, Options, SnapToGrid, 0
    IniRead g_GridSize, %IniFile%, Options, GridSize, 8
    IniRead g_AhkPath64, %IniFile%, Options, AhkPath64, %A_Space%
    IniRead g_AhkPath32, %IniFile%, Options, AhkPath32, %A_Space%
    IniRead g_AhkPathEx, %IniFile%, Options, AhkPathEx, %A_Space%
    IniRead g_AskToSaveOnExit, %IniFile%, Options, AskToSaveOnExit, 1
    IniRead g_HelpFile, %IniFile%, Options, HelpFile, %A_ScriptDir%\..\..\Help\AutoHotkey.chm

    SetIndent()
}

ApplySettings() {
    If (g_ShowGrid) {
        SendMessage TB_CHECKBUTTON, 1080, 1,, ahk_id %hToolbar%
        Menu AutoViewMenu, Check, Show &Grid
    }

    If (g_SnapToGrid) {
        SendMessage TB_CHECKBUTTON, 1090, 1,, ahk_id %hToolbar%
        Menu AutoViewMenu, Check, S&nap to Grid
    }

    If (g_WordWrap) {
        Menu AutoViewMenu, Check, &Wrap Long Lines
    }

    If (g_LineNumbers) {
        Menu AutoViewMenu, Check, Show &Line Numbers
    }

    If (g_AskToSaveOnExit) {
        Menu AutoFileMenu, Check, Ask to Save on Exit
    }

    Menu AutoViewMenu, Check, Show &Control Palette
    Menu AutoViewMenu, Check, Show &Toolbar
    Menu AutoViewMenu, Check, Show &Status Bar
}

SaveSettings() {
    Local Sections, Pos, State

    If (!FileExist(IniFile)) {
        Sections := "[Options]`n`n[Window]`n`n[Properties]`n"

        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            IniFile := g_AppData . "\Auto-GUI.ini"
            FileDelete %IniFile%
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }

    IniWrite %g_OpenDir%, %IniFile%, Options, OpenDir
    IniWrite %g_SaveDir%, %IniFile%, Options, SaveDir
    IniWrite %g_SciFontName%, %IniFile%, Options, FontName
    IniWrite %g_SciFontSize%, %IniFile%, Options, FontSize
    IniWrite %g_TabSize%, %IniFile%, Options, TabSize
    IniWrite %g_CaretWidth%, %IniFile%, Options, CaretWidth
    IniWrite %g_CaretStyle%, %IniFile%, Options, CaretStyle
    IniWrite %g_CaretBlink%, %IniFile%, Options, CaretBlink
    IniWrite %g_LineNumbers%, %IniFile%, Options, LineNumbers
    IniWrite %g_WordWrap%, %IniFile%, Options, WordWrap
    IniWrite %g_HighlightActiveLine%, %IniFile%, Options, HighlightActiveLine
    IniWrite %g_Highlights%, %IniFile%, Options, Highlights
    IniWrite %g_HITMode%, %IniFile%, Options, HITMode
    IniWrite %g_HITLimit%, %IniFile%, Options, HITLimit
    IniWrite %g_IndentWithSpaces%, %IniFile%, Options, IndentWithSpaces
    IniWrite %g_IndentGuides%, %IniFile%, Options, IndentGuides
    IniWrite %g_ShowGrid%, %IniFile%, Options, ShowGrid
    IniWrite %g_SnapToGrid%, %IniFile%, Options, SnapToGrid
    IniWrite %g_GridSize%, %IniFile%, Options, GridSize
    IniWrite %g_AhkPathEx%, %IniFile%, Options, AhkPathEx
    IniWrite %g_AskToSaveOnExit%, %IniFile%, Options, AskToSaveOnExit
    IniWrite %g_HelpFile%, %IniFile%, Options, HelpFile

    ; Main window position and size
    Pos := GetWindowPlacement(hAutoWnd)
    IniWrite % Pos.x, %IniFile%, Window, x
    IniWrite % Pos.y, %IniFile%, Window, y
    IniWrite % Pos.w, %IniFile%, Window, w
    IniWrite % Pos.h, %IniFile%, Window, h
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %IniFile%, Window, State

    ; Properties window position
    If (g_PropX != "") {
        IniWrite %g_PropX%, %IniFile%, Properties, x
        IniWrite %g_PropY%, %IniFile%, Properties, y
    }
}
