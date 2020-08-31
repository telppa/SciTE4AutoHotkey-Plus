LoadSettings() {
    IniRead g_OpenDir, %IniFile%, Options, OpenDir, %A_MyDocuments%
    IniRead g_SaveDir, %IniFile%, Options, SaveDir, %A_MyDocuments%

    IniRead g_TabBarPos, %IniFile%, Options, TabBarPos, 2
    IniRead g_TabBarStyle, %IniFile%, Options, TabBarStyle, 2
    IniRead g_SciFontName, %IniFile%, Editor, FontName, Lucida Console
    IniRead g_SciFontSize, %IniFile%, Editor, FontSize, 14
    IniRead g_DarkTheme, %IniFile%, Editor, DarkTheme, 0
    IniRead g_TabSize, %IniFile%, Editor, TabSize, 4
    IniRead g_CaretWidth, %IniFile%, Editor, CaretWidth, 1
    IniRead g_CaretStyle, %IniFile%, Editor, CaretStyle, 1
    IniRead g_CaretBlink, %IniFile%, Editor, CaretBlink, 500
    IniRead g_LineNumbers, %IniFile%, Editor, LineNumbers, 0
    IniRead g_SymbolMargin, %IniFile%, Editor, SymbolMargin, 1
    IniRead g_CodeFolding, %IniFile%, Editor, CodeFolding, 0
    IniRead g_WordWrap, %IniFile%, Editor, WordWrap, 1
    IniRead g_SyntaxHighlighting, %IniFile%, Editor, SyntaxHighlighting, 1
    IniRead g_AutoBrackets, %IniFile%, Editor, AutoBrackets, 1
    IniRead g_HighlightActiveLine, %IniFile%, Editor, HighlightActiveLine, 0
    IniRead g_HighlightIdenticalText, %IniFile%, Editor, HighlightIdenticalText, 1
    IniRead g_IndentWithSpaces, %IniFile%, Editor, IndentWithSpaces, 1
    IniRead g_AutoIndent, %IniFile%, Editor, AutoIndent, 1
    IniRead g_IndentGuides, %IniFile%, Editor, IndentGuides, 0
    IniRead g_CheckTimestamp, %IniFile%, Editor, CheckTimestamp, 1

    IniRead g_DesignMode, %IniFile%, Options, DesignMode, 0
    IniRead g_ShowGrid, %IniFile%, Options, ShowGrid, 1
    IniRead g_SnapToGrid, %IniFile%, Options, SnapToGrid, 0
    IniRead g_GridSize, %IniFile%, Options, GridSize, 8

    IniRead g_CaptureStdErr, %IniFile%, Run, CaptureStdErr, 1
    IniRead g_ShowErrorSign, %IniFile%, Run, ShowErrorSign, -1
    IniRead g_AltAhkPath, %IniFile%, Run, AltRun, Undefined
    IniRead ShellMenu, %IniFile%, Run, ShellMenu, 0
    g_ShellMenu1 := ShellMenu & 1
    g_ShellMenu2 := ShellMenu & 2

    IniRead g_DbgPort, %IniFile%, Debug, Port, 9001

    IniRead g_AutoCEnabled, %IniFile%, Autocomplete, Enabled, 0
    IniRead g_AutoCMinLength, %IniFile%, Autocomplete, MinLength, 3
    IniRead g_AutoCMaxItems, %IniFile%, Autocomplete, MaxItems, 7

    IniRead g_Calltips, %IniFile%, Calltips, Enabled, 1

    IniRead g_BackupOnSave, %IniFile%, Backup, Enabled, 1
    IniRead g_BackupDir, %IniFile%, Backup, Dir, %A_Temp%\AutoGUI
    IniRead g_BackupDays, %IniFile%, Backup, Days, 30

    IniRead g_AutoSaveInterval, %IniFile%, AutoSave, SaveInterval, 3
    IniRead g_AutoSaveInLoco, %IniFile%, AutoSave, SaveInLoco, 0
    IniRead g_AutoSaveInBkpDir, %IniFile%, AutoSave, SaveInBkpDir, 1

    IniRead g_AskToSaveOnExit, %IniFile%, Options, AskToSaveOnExit, 1

    IniRead g_SessionsDir, %IniFile%, Sessions, Dir
    IniRead g_LoadLastSession, %IniFile%, Sessions, AutoLoadLast, 1
    IniRead g_RememberSession, %IniFile%, Sessions, SaveOnExit, 1

    IniRead g_HelpFile, %IniFile%, Options, HelpFile, %A_ScriptDir%\Help\AutoHotkey.chm

    IniRead g_SysTrayIcon, %IniFile%, Options, TrayIcon, 0

    SetIndent()
}

ApplyToolbarSettings() {
    If (g_LineNumbers) {
        SendMessage TB_CHECKBUTTON, 2140, 1,, ahk_id %hMainToolbar%
    }

    If (g_CodeFolding) {
        SendMessage TB_CHECKBUTTON, 2150, 1,, ahk_id %hMainToolbar%
    }

    If (g_WordWrap) {
        SendMessage TB_CHECKBUTTON, 2160, 1,, ahk_id %hMainToolbar%
    }

    If (g_SyntaxHighlighting) {
        SendMessage TB_CHECKBUTTON, 2180, 1,, ahk_id %hMainToolbar%
    }

    If (g_DesignMode) {
        SendMessage TB_CHECKBUTTON, 1060, %g_DesignMode%,, ahk_id %hGUIToolbar%
    }

    If (g_ShowGrid) {
        SendMessage TB_CHECKBUTTON, 1080, 1,, ahk_id %hGUIToolbar%
    }

    If (g_SnapToGrid) {
        SendMessage TB_CHECKBUTTON, 1090, 1,, ahk_id %hGUIToolbar%
    }

}

ApplyMenuSettings() {
    If (g_CodeFolding) {
        Menu AutoViewMenu, Check, &Fold Margin
    }

    If (g_WordWrap) {
        Menu AutoViewMenu, Check, &Wrap Long Lines
    }

    If (g_DarkTheme) {
        Menu AutoViewMenu, Check, Enable Dark Theme
    }

    If (g_SyntaxHighlighting) {
        Menu AutoViewMenu, Check, Syntax &Highlighting
    }

    If (g_ShowGrid) {
        Menu AutoOptionsGuiMenu, Check, Show &Grid
    }

    If (g_SnapToGrid) {
        Menu AutoOptionsGuiMenu, Check, S&nap to Grid
    }

    If (g_LineNumbers) {
        Menu AutoViewMenu, Check, &Line Numbers
    }

    If (g_SymbolMargin) {
        Menu AutoViewMenu, Check, Symbol Margin
    }

    If (g_AutoCEnabled) {
        Menu AutoOptionsMenu, Check, Enable &Autocompletion
    }

    If (g_Calltips) {
        Menu AutoOptionsMenu, Check, Enable &Calltips
    }

    If (g_AutoBrackets) {
        Menu AutoOptionsMenu, Check, Autoclose &Brackets
    }

    If (g_HighlightActiveLine) {
        Menu AutoViewMenu, Check, Highlight &Active Line
    }

    If (g_HighlightIdenticalText) {
        Menu AutoViewMenu, Check, Highlight Identical Te&xt
    }

    If (g_DesignMode) {
        Menu AutoViewMenu, Check, &Design Mode
    } Else {
        Menu AutoViewMenu, Check, &Editor Mode
    }

    Menu AutoViewTabBarMenu, Check, % (g_TabBarPos == 1 ? "Top" : "Bottom")
    Menu AutoViewTabBarMenu, Check, % (g_TabBarStyle == 1 ? "Standard" : "Buttons")

    If (g_RememberSession) {
        Menu AutoOptionsMenu, Check, Remember Session
    }

    If (g_AskToSaveOnExit) {
        Menu AutoOptionsMenu, Check, Ask to Save on Exit
    }

    If (g_CaptureStdErr) {
        Menu AutoRunMenu, Check, Capture Standard &Error
    }
}

SaveSettings() {
    If (!FileExist(IniFile)) {
        Sections := "[Options]`n`n[Auto]`n`n[Properties]`n`n[Editor]`n`n[Run]`n`n[Debug]`n`n[Autocomplete]`n`n[Calltips]`n`n[Find]`n`n[FindHistory]`n`n[Sessions]`n`n[Backup]`n`n[AutoSave]`n`n[Recent]`n"
        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %A_AppData%\AutoGUI
            IniFile := A_AppData . "\AutoGUI\AutoGUI.ini"
            FileDelete %IniFile%
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }

    IniWrite %g_OpenDir%, %IniFile%, Options, OpenDir
    IniWrite %g_SaveDir%, %IniFile%, Options, SaveDir

    ; GUI designer options
    IniWrite %g_DesignMode%, %IniFile%, Options, DesignMode
    IniWrite %g_ShowGrid%, %IniFile%, Options, ShowGrid
    IniWrite %g_SnapToGrid%, %IniFile%, Options, SnapToGrid
    IniWrite %g_GridSize%, %IniFile%, Options, GridSize

    ; Tab Bar
    IniWrite %g_TabBarPos%, %IniFile%, Options, TabBarPos
    IniWrite %g_TabBarStyle%, %IniFile%, Options, TabBarStyle

    IniWrite %g_AskToSaveOnExit%, %IniFile%, Options, AskToSaveOnExit

    IniWrite %g_HelpFile%, %IniFile%, Options, HelpFile

    ; Main window position and size
    Pos := GetWindowPlacement(hAutoWnd)
    IniWrite % Pos.x, %IniFile%, Auto, x
    IniWrite % Pos.y, %IniFile%, Auto, y
    IniWrite % Pos.w, %IniFile%, Auto, w
    IniWrite % Pos.h, %IniFile%, Auto, h
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %IniFile%, Auto, Show

    ; Properties window position
    If (g_PropX != "") {
        IniWrite %g_PropX%, %IniFile%, Properties, x
        IniWrite %g_PropY%, %IniFile%, Properties, y
    }

    ; Editor options
    IniWrite %g_SciFontName%, %IniFile%, Editor, FontName
    IniWrite %g_SciFontSize%, %IniFile%, Editor, FontSize
    IniWrite %g_DarkTheme%, %IniFile%, Editor, DarkTheme
    IniWrite %g_TabSize%, %IniFile%, Editor, TabSize
    IniWrite %g_CaretWidth%, %IniFile%, Editor, CaretWidth
    IniWrite %g_CaretStyle%, %IniFile%, Editor, CaretStyle
    IniWrite %g_CaretBlink%, %IniFile%, Editor, CaretBlink
    IniWrite %g_LineNumbers%, %IniFile%, Editor, LineNumbers
    IniWrite %g_CodeFolding%, %IniFile%, Editor, CodeFolding
    IniWrite %g_SymbolMargin%, %IniFile%, Editor, SymbolMargin
    IniWrite %g_WordWrap%, %IniFile%, Editor, WordWrap
    IniWrite %g_SyntaxHighlighting%, %IniFile%, Editor, SyntaxHighlighting
    IniWrite %g_AutoBrackets%, %IniFile%, Editor, AutoBrackets
    IniWrite %g_HighlightActiveLine%, %IniFile%, Editor, HighlightActiveLine
    IniWrite %g_HighlightIdenticalText%, %IniFile%, Editor, HighlightIdenticalText
    IniWrite %g_IndentWithSpaces%, %IniFile%, Editor, IndentWithSpaces
    IniWrite %g_AutoIndent%, %IniFile%, Editor, AutoIndent
    IniWrite %g_IndentGuides%, %IniFile%, Editor, IndentGuides
    IniWrite %g_CheckTimestamp%, %IniFile%, Editor, CheckTimestamp

    ; Run
    IniWrite %g_CaptureStdErr%, %IniFile%, Run, CaptureStdErr
    IniWrite %g_ShowErrorSign%, %IniFile%, Run, ShowErrorSign
    IniWrite % g_ShellMenu1 | g_ShellMenu2, %IniFile%, Run, ShellMenu
    IniWrite %g_AltAhkPath%, %IniFile%, Run, AltRun

    ; Debug
    IniWrite %g_DbgPort%, %IniFile%, Debug, Port

    ; Autocomplete
    IniWrite %g_AutoCEnabled%, %IniFile%, Autocomplete, Enabled
    IniWrite %g_AutoCMinLength%, %IniFile%, Autocomplete, MinLength
    IniWrite %g_AutoCMaxItems%, %IniFile%, Autocomplete, MaxItems

    ; Calltips
    IniWrite %g_Calltips%, %IniFile%, Calltips, Enabled

    ; Backup
    IniWrite %g_BackupOnSave%, %IniFile%, Backup, Enabled
    IniWrite %g_BackupDir%, %IniFile%, Backup, Dir
    IniWrite %g_BackupDays%, %IniFile%, Backup, Days

    ; Auto-save
    IniWrite %g_AutoSaveInterval%, %IniFile%, AutoSave, SaveInterval
    IniWrite %g_AutoSaveInLoco%, %IniFile%, AutoSave, SaveInLoco
    IniWrite %g_AutoSaveInBkpDir%, %IniFile%, AutoSave, SaveInBkpDir

    ; Sessions
    IniWrite %g_SessionsDir%, %IniFile%, Sessions, Dir
    IniWrite %g_LoadLastSession%, %IniFile%, Sessions, AutoLoadLast
    IniWrite %g_RememberSession%, %IniFile%, Sessions, SaveOnExit

    ; Recent files
    If (RecentFiles.Length()) {
        For Index, Filename In RecentFiles {
            IniWrite %Filename%, %IniFile%, Recent, %Index%
        }
    }

    ; Find/Replace
    If (WinExist("ahk_id " . hFindReplaceDlg)) {
        WinGetPos px, py,,, ahk_id %hFindReplaceDlg%
        IniWrite %px%, %IniFile%, Find, x
        IniWrite %py%, %IniFile%, Find, y

        Gui FindReplaceDlg: Submit, NoHide
        IniWrite %g_ChkMatchCase%, %IniFile%, Find, MatchCase
        IniWrite %g_ChkWholeWord%, %IniFile%, Find, WholeWord
        IniWrite %g_ChkRegExFind%, %IniFile%, Find, RegExFind
        IniWrite %g_ChkBackslash%, %IniFile%, Find, Backslash
        IniWrite %g_RadStartingPos%, %IniFile%, Find, FromStart
        IniWrite %g_ChkWrapAround%, %IniFile%, Find, WrapAround

        ; Find/Replace history
        Items := ""

        ControlGet FindItems, List,,, ahk_id %hCbxFind1%
        If (FindItems != "") {
            Loop Parse, FindItems, `n
            {
                Items .= "What" . A_Index . "=" . A_LoopField . "`n"
            }
        }

        ControlGet ReplaceItems, List,,, ahk_id %hCbxReplace%
        If (replaceItems != "") {
            Loop Parse, ReplaceItems, `n
            {
                Items .= "With" . A_Index . "=" . A_LoopField . "`n"
            }
        }

        If (Items != "") {
            IniWrite %Items%, %IniFile%, FindHistory
        }
    }
}
