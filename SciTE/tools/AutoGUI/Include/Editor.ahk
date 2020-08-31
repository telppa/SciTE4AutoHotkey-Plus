Sci_Config(n, Lexer := 200) { ; SCLEX_AHKL
    Sci[n].SetLexer(Lexer)
    Sci[n].SetCodePage(65001) ; UTF-8
    Sci[n].SetWrapMode(g_WordWrap)
    Sci[n].SetScrollWidthTracking(True)
    Sci[n].SetExtraAscent(2) ; Increase space between lines
    Sci[n].SetVirtualSpaceOptions(1) ; SCVS_RECTANGULARSELECTION

    ; Indentation
    Sci[n].SetTabWidth(g_TabSize)
    Sci[n].SetUseTabs(!g_IndentWithSpaces) ; Indent with spaces
    Sci[n].SetIndentationGuides(g_IndentGuides ? 3 : 0)

    ; Caret
    Sci[n].SetCaretWidth(g_CaretWidth)
    Sci[n].SetCaretStyle(g_CaretStyle)
    Sci[n].SetCaretPeriod(g_CaretBlink)

    Sci_SetStyle(n, g_SciFontName, g_SciFontSize)

    ; Line numbers margin
    Sci[n].SetMarginTypeN(0, 1) ; SC_MARGIN_NUMBER
    Sci[n].MarginLen := 0
    SetLineNumberWidth(n)
    Sci[n].SetMarginLeft(0, 2) ; Left padding

    DefineMarkers(n)

    ; Symbol margin
    Sci[n].SetMarginTypeN(1, SC_MARGIN_SYMBOL)
    Sci[n].SetMarginSensitiveN(1, True)
    ShowSymbolMargin(g_SymbolMargin)

    If (g_CodeFolding) {
        Sci[n].SetProperty("fold", "1")
        Sci[n].SetProperty("fold.compact", "1")
        SetCodeFolding(n)
    }

    ; Autocomplete settings
    Sci[n].AutoCSetIgnoreCase(True)
    Sci[n].AutoCSetMaxHeight(g_AutoCMaxItems)
    Sci[n].AutoCSetOrder(1) ; SC_ORDER_PERFORMSORT

    ; Calltip settings
    Sci[n].CalltipSetFore(CvtClr(0x000000))
    Sci[n].CalltipSetBack(CvtClr(0xFFFFDD))
    Sci[n].SetMouseDwellTime(1000) ; Hover time

    Sci[n].AssignCmdKey(SCK_END, SCI_LINEENDWRAP)
    Sci[n].AssignCmdKey(SCK_HOME, SCI_HOMEWRAP)
    Sci[n].AssignCmdKey(SCK_END  | (SCMOD_SHIFT << 16), SCI_LINEENDWRAPEXTEND)
    Sci[n].AssignCmdKey(SCK_HOME | (SCMOD_SHIFT << 16), SCI_HOMEWRAPEXTEND)

    ; Keywords
    Sci[n].SetKeywords(0, Keywords.Directives, 1)
    Sci[n].SetKeywords(1, Keywords.Commands, 1)
    Sci[n].SetKeywords(2, Keywords.Parameters, 1)
    Sci[n].SetKeywords(3, Keywords.ControlFlow, 1)
    Sci[n].SetKeywords(4, Keywords.Functions, 1)
    Sci[n].SetKeywords(5, Keywords.BuiltinVariables, 1)
    Sci[n].SetKeywords(6, Keywords.Keys, 1)
    ;Sci[n].SetKeywords(7, Keywords.UserDefined1, 1)

    Sci[n].Notify := "OnWM_NOTIFY"

    If (g_ShowWhiteSpaces) {
        ShowWhiteSpaces(g_ShowWhiteSpaces)
    }
}

Sci_SetStyle(n, FontName := "Lucida Console", FontSize := 10) {
    Sci[n].StyleSetFont(STYLE_DEFAULT, "" . FontName, 1)
    Sci[n].StyleSetSize(STYLE_DEFAULT, FontSize)

    If (g_DarkTheme) {
        Sci_SetDarkTheme(n)
    } Else {
        Sci_SetDefaultTheme(n)
    }
}

Sci_SetDefaultTheme(n) {
    Sci[n].StyleSetFore(STYLE_DEFAULT, CvtClr(0x000000))
    Sci[n].StyleSetBack(STYLE_DEFAULT, CvtClr(0xF8F8F8))
    Sci[n].StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Active line background color
    Sci[n].SetCaretLineBack(CvtClr(g_HighlightActiveLine ? 0xD8F3FF : 0xFFFFFF))
    Sci[n].SetCaretLineVisible(True)
    Sci[n].SetCaretLineVisibleAlways(1)

    Sci[n].SetCaretFore(CvtClr(0x000000))

    ; Margin
    Sci[n].StyleSetFore(33, CvtClr(0xCFD2CA)) ; Margin foreground color
    Sci[n].StyleSetBack(33, CvtClr(0xFFFFFF)) ; Margin background color

    ; Selection
    Sci[n].SetSelFore(1, CvtClr(0xFFFFFF))
    Sci[n].SetSelBack(1, CvtClr(0x3399FF))

    ; Matching braces
    Sci[n].StyleSetFore(STYLE_BRACELIGHT, CvtClr(0x3399FF))
    Sci[n].StyleSetBold(STYLE_BRACELIGHT, True)

    If (g_SyntaxHighlighting) {
        ; AHK syntax elements
        Sci[n].StyleSetFore(SCE_AHKL_IDENTIFIER     , CvtClr(0x000000))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTDOC     , CvtClr(0x008888))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTLINE    , CvtClr(0x767676))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTBLOCK   , CvtClr(0x767676))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTKEYWORD , CvtClr(0x0000DD))
        Sci[n].StyleSetFore(SCE_AHKL_STRING         , CvtClr(0x183691))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGOPTS     , CvtClr(0x0000EE))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGBLOCK    , CvtClr(0x183691))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGCOMMENT  , CvtClr(0xFF0000))
        Sci[n].StyleSetFore(SCE_AHKL_LABEL          , CvtClr(0x0000DD))
        Sci[n].StyleSetFore(SCE_AHKL_HOTKEY         , CvtClr(0x0000DD))
        Sci[n].StyleSetFore(SCE_AHKL_HOTSTRING      , CvtClr(0x183691))
        Sci[n].StyleSetFore(SCE_AHKL_HOTSTRINGOPT   , CvtClr(0x990099))
        Sci[n].StyleSetFore(SCE_AHKL_HEXNUMBER      , CvtClr(0x880088))
        Sci[n].StyleSetFore(SCE_AHKL_DECNUMBER      , CvtClr(0x606870))
        ;Sci[n].StyleSetFore(SCE_AHKL_VAR            , CvtClr(0x9F1F6F))
        Sci[n].StyleSetFore(SCE_AHKL_VARREF         , CvtClr(0x990055))
        ;Sci[n].StyleSetFore(SCE_AHKL_OBJECT         , CvtClr(0x008888))
        Sci[n].StyleSetFore(SCE_AHKL_USERFUNCTION   , CvtClr(0x0000DD))
        Sci[n].StyleSetFore(SCE_AHKL_DIRECTIVE      , CvtClr(0x0000CF))
        Sci[n].StyleSetFore(SCE_AHKL_COMMAND        , CvtClr(0x0070A0))
        Sci[n].StyleSetFore(SCE_AHKL_PARAM          , CvtClr(0x0070A0))
        Sci[n].StyleSetFore(SCE_AHKL_CONTROLFLOW    , CvtClr(0x0000DD))
        Sci[n].StyleSetFore(SCE_AHKL_BUILTINFUNCTION, CvtClr(0x0F707F))
        Sci[n].StyleSetFore(SCE_AHKL_BUILTINVAR     , CvtClr(0x9F1F6F))
        Sci[n].StyleSetFore(SCE_AHKL_KEY            , CvtClr(0x9F1F6F))
        ;Sci[n].StyleSetFore(SCE_AHKL_USERDEFINED1   , CvtClr(0x000000))
        Sci[n].StyleSetFore(SCE_AHKL_ESCAPESEQ      , CvtClr(0x660000))
        ;Sci[n].StyleSetFore(SCE_AHKL_ERROR          , 0xFF0000)
    }
}

; Credits to kczx3
Sci_SetDarkTheme(n) {
    Sci[n].StyleSetFore(STYLE_DEFAULT, CvtClr(0xF8F8F2))
    Sci[n].StyleSetBack(STYLE_DEFAULT, CvtClr(0x272822))
    Sci[n].StyleClearAll()

    ; Active line background color
    Sci[n].SetCaretLineBack(CvtClr(g_HighlightActiveLine ? 0x3E3D32 : 0x272822))
    Sci[n].SetCaretLineVisible(True)
    Sci[n].SetCaretLineVisibleAlways(1)

    Sci[n].SetCaretFore(CvtClr(0xF8F8F0))

    ; Margin
    Sci[n].StyleSetFore(33, CvtClr(0xF8F8F2)) ; Margin foreground color
    Sci[n].StyleSetBack(33, CvtClr(0x272822)) ; Margin background color

    ; Selection
    Sci[n].SetSelFore(1, CvtClr(0xFFFFFF))
    Sci[n].SetSelBack(1, CvtClr(0x3399FF))

    ; Matching braces
    Sci[n].StyleSetFore(STYLE_BRACELIGHT, CvtClr(0x3399FF))
    Sci[n].StyleSetBold(STYLE_BRACELIGHT, True)

    If (g_SyntaxHighlighting) {
        ; AHK syntax elements
        Sci[n].StyleSetFore(SCE_AHKL_IDENTIFIER     , CvtClr(0xF8F8F2))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTDOC     , CvtClr(0x008888))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTLINE    , CvtClr(0x75715E))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTBLOCK   , CvtClr(0x75715E))
        Sci[n].StyleSetFore(SCE_AHKL_COMMENTKEYWORD , CvtClr(0x66D9EF))
        Sci[n].StyleSetItalic(SCE_AHKL_COMMENTKEYWORD, True)
        Sci[n].StyleSetFore(SCE_AHKL_STRING         , CvtClr(0xE6DB74))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGOPTS     , CvtClr(0xFD971F))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGBLOCK    , CvtClr(0xE6DB74))
        Sci[n].StyleSetFore(SCE_AHKL_STRINGCOMMENT  , CvtClr(0x75715E))
        Sci[n].StyleSetFore(SCE_AHKL_LABEL          , CvtClr(0xA6E22E))
        Sci[n].StyleSetFore(SCE_AHKL_HOTKEY         , CvtClr(0xA6E22E))
        Sci[n].StyleSetFore(SCE_AHKL_HOTSTRING      , CvtClr(0xA6E22E))
        Sci[n].StyleSetFore(SCE_AHKL_HOTSTRINGOPT   , CvtClr(0xFD971F))
        Sci[n].StyleSetFore(SCE_AHKL_HEXNUMBER      , CvtClr(0xAE81FF))
        Sci[n].StyleSetFore(SCE_AHKL_DECNUMBER      , CvtClr(0xAE81FF))
        ;Sci[n].StyleSetFore(SCE_AHKL_VAR            , CvtClr(0x9F1F6F))
        Sci[n].StyleSetFore(SCE_AHKL_VARREF         , CvtClr(0x990055))
        ;Sci[n].StyleSetFore(SCE_AHKL_OBJECT         , CvtClr(0x008888))
        Sci[n].StyleSetFore(SCE_AHKL_USERFUNCTION   , CvtClr(0xA6E22E))
        Sci[n].StyleSetFore(SCE_AHKL_DIRECTIVE      , CvtClr(0xF92672))
        Sci[n].StyleSetFore(SCE_AHKL_COMMAND        , CvtClr(0xF92672))
        Sci[n].StyleSetFore(SCE_AHKL_PARAM          , CvtClr(0xFD971F))
        Sci[n].StyleSetFore(SCE_AHKL_CONTROLFLOW    , CvtClr(0xF92672))
        Sci[n].StyleSetFore(SCE_AHKL_BUILTINFUNCTION, CvtClr(0x66D9EF))
        Sci[n].StyleSetFore(SCE_AHKL_BUILTINVAR     , CvtClr(0x66D9EF))
        Sci[n].StyleSetItalic(SCE_AHKL_BUILTINVAR   , True)
        Sci[n].StyleSetFore(SCE_AHKL_KEY            , CvtClr(0xA2A2A2))
        Sci[n].StyleSetItalic(SCE_AHKL_KEY          , True)
        ;Sci[n].StyleSetFore(SCE_AHKL_USERDEFINED1   , CvtClr(0xF92672))
        Sci[n].StyleSetFore(SCE_AHKL_ESCAPESEQ      , CvtClr(0xFD971F))
        Sci[n].StyleSetItalic(SCE_AHKL_ESCAPESEQ    , True)
        Sci[n].StyleSetFore(SCE_AHKL_ERROR          , CvtClr(0xFF0000))
    }
}

SetLineNumberWidth(n) {
    If (g_LineNumbers) {
        LineCount := Sci[n].GetLineCount()
        LineCountLen := StrLen(LineCount)
        If (LineCountLen < 2) {
            LineCountLen := 2
        }

        If (LineCountLen != Sci[n].MarginLen) {
            Sci[n].MarginLen := LineCountLen

            If (LineCount < 100) {
                String := "99"
            } Else {
                String := ""
                LineCountLen := StrLen(LineCount)
                Loop %LineCountLen% {
                    String .= "9"
                }
            }

            PixelWidth := Sci[n].TextWidth(STYLE_LINENUMBER, "" . String, 1) + 8
            Sci[n].SetMarginWidthN(0, PixelWidth)
        }
    } Else {
        Sci[n].SetMarginWidthN(0, 0)
        Sci[n].MarginLen := 0
    }
}

DefineMarkers(n) {
    Static XPMLoaded := 0, PixmapBreakpoint, PixmapBookmark, PixmapError

    If (!XPMLoaded) {
        FileRead PixmapBreakpoint, %A_ScriptDir%\Icons\Breakpoint.xpm
        FileRead PixmapBookmark, %A_ScriptDir%\Icons\Handpoint.xpm
        FileRead PixmapError, %A_ScriptDir%\Icons\Error.xpm
        XPMLoaded := 1
    }

    ; Bookmark marker
    Sci[n].MarkerDefine(g_MarkerBookmark, 25) ; 25 = SC_MARK_PIXMAP
    Sci[n].MarkerDefinePixmap(g_MarkerBookmark, "" . PixmapBookmark, 1)

    ; Breakpoint marker
    Sci[n].MarkerDefine(g_MarkerBreakpoint, 25)
    Sci[n].MarkerDefinePixmap(g_MarkerBreakpoint, "" . PixmapBreakpoint, 1)

    ; Debug step marker
    Sci[n].MarkerDefine(g_MarkerDebugStep, SC_MARK_SHORTARROW)
    Sci[n].MarkerSetBack(g_MarkerDebugStep, CvtClr(0xA2C93E))

    ; Error marker
    Sci[n].MarkerDefine(g_MarkerError, 25)
    Sci[n].MarkerDefinePixmap(g_MarkerError, "" . PixmapError, 1)
}

SetCodeFolding(n) {
    Sci[n].SetMarginTypeN(2, SC_MARGIN_SYMBOL)
    Sci[n].SetMarginWidthN(2, 14)
    Sci[n].SetMarginMaskN(2, SC_MASK_FOLDERS)
    Sci[n].SetMarginSensitiveN(2, True)

    Sci[n].MarkerDefine(SC_MARKNUM_FOLDER, SC_MARK_BOXPLUS)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEREND, SC_MARK_BOXPLUSCONNECTED)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEROPENMID, SC_MARK_BOXMINUSCONNECTED)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, SC_MARK_TCORNER)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERSUB, SC_MARK_VLINE)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERTAIL, SC_MARK_LCORNERCURVE)

    SetCodeFoldingColors(n)
}

SetCodeFoldingColors(n) {
    Color := g_DarkTheme ? 0x272822 : 0xFAFAFA

    Loop 7 {
        i := A_Index + 24
        Sci[n].MarkerSetFore(i, CvtClr(Color))
        Sci[n].MarkerSetBack(i, CvtClr(0x008EBC)) ; Border
    }

    Sci[n].2290(1, CvtClr(Color)) ; SCI_SETFOLDMARGINCOLOUR
    Sci[n].2291(1, CvtClr(Color)) ; SCI_SETFOLDMARGINHICOLOUR
}

NewTab:
    NewTab()
Return

NewTab(TabIcon := 1, TabTitle := "") {
    g_TabCounter++

    ; Tab
    TabTitle := TabTitle == "" ? "Untitled " . g_TabCounter : TabTitle
    TabIndex := TabEx.Add(TabTitle, TabIcon)
    If (!TabIndex) {
        Return 0
    }

    ; Scintilla
    Sci[TabIndex] := New Scintilla
    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Sci[TabIndex].Add(hAutoWnd, SciX, SciY, SciW, SciH, SciLexer, 0x50000000, 0x200)
    Sci_Config(TabIndex)
    TabEx.SetSel(TabIndex)

    Sci[TabIndex].Number := g_TabCounter ; Untitled number

    Sci[TabIndex].LastAccessTime := A_Now . A_MSec

    Return TabIndex
}

NewFromTemplate() {
    n := TabEx.GetSel()
    If (n == g_GuiTab || Sci[n].GetModify() || Sci[n].Filename != "") {
        If !(n := NewTab()) {
            Return
        }
    }

    Template := A_WinDir . "\ShellNew\Template.ahk"

    If (FileExist(Template)) {
        FileRead Template, %Template%
        Sci[n].SetText("", Template . CRLF, 1)
        Sci[n].DocumentEnd()
    }
}

DuplicateTab:
    DuplicateTab(g_TabIndex)
Return

DuplicateTab(n) {
    If (TabIndex := NewTab()) {
        Sci[TabIndex].SetText("", GetText(n), 1)
    }
    Return TabIndex
}

CloseTab:
    CloseTab(TabEx.GetSel())
Return

CloseTabN:
    CloseTab(g_TabIndex)
Return

CloseTab(TabIndex, Confirm := True, Multiple := False, Exiting := False) {
    If (TabIndex == 0) {
        Return 0
    }

    SkipConfirmation := False

    If (Confirm && Sci[TabIndex].GetModify()) {
        TabEx.SetSel(TabIndex)
        ;Repaint(Sci[TabIndex].hWnd) ; ?

        Result := ConfirmCloseTab(TabEx.GetText(TabIndex), Multiple)
        If (Result == "Yes") {
            If (!Save(TabIndex)) {
                Return 0
            }

        } Else If (Result == "NoToAll") {
            If (Exiting) {
                Quit()
            }

            SkipConfirmation := True

        } Else If (Result == "Cancel") {
            Sci[TabIndex].GrabFocus()
            Return 0
        }
    }

    If (TabIndex == g_GuiTab) {
        Gui %Child%: Destroy
        g_GuiTab := 0
        g_GuiVis := False
        GoSub SwitchToEditorMode
        Gui Properties: Hide
    }

    TabCount := TabEx.GetCount()
    If (TabCount > 1) {
        IsActiveTab := TabIndex == TabEx.GetSel()

        SendMessage 0x1308, TabIndex - 1, 0,, ahk_id %hTab% ; TCM_DELETEITEM
        DestroyWindow(Sci[TabIndex].hWnd)
        Sci.Remove(TabIndex)

        If (g_GuiTab > TabIndex) {
            g_GuiTab--
        }

        If (IsActiveTab) {
            NewIndex := GetPreviousTab() - 1
            SendMessage 0x1330, NewIndex,,, ahk_id %hTab% ; TCM_SETCURFOCUS
            Sleep 0
            SendMessage 0x130C, NewIndex,,, ahk_id %hTab% ; TCM_SETCURSEL
            GoSub TabHandler
        } Else {
            Repaint(hAutoWnd)
        }

    } Else { ; First and only tab
        SetReadOnly(TabIndex, 0)
        ClearFile(1)
        Sci[1].GrabFocus()
        SetWindowTitle()
        If (Sci[1].GetLexer() != SCLEX_AHKL) {
            Sci_Config(1)
        }
    }

    Return SkipConfirmation ? -1 : 1
}

ClearFile(n) {
    Sci[n].FullName := ""
    Sci[n].FileName := ""
    Sci[n].Encoding := "UTF-8"
    Sci[n].LastWriteTime  := ""
    Sci[n].LastAccessTime := A_Now . A_MSec
    Sci[n].BackupName := ""
    Sci[n].Parameters := ""
    Sci[n].ClearAll()
    Sci[n].SetSavePoint()
    TabEx.SetIcon(n, 1)
    Repaint(Sci[n].hWnd)
}

AskToSaveOnExit:
CloseAllTabs:
    Unsaved := 0
    Loop % Sci.Length() {
        If (Sci[A_Index].GetModify()) {
            Unsaved++
        }
    }

    Confirm := True ; Unsaved?
    NoToAll := Unsaved > 1
    Exiting := A_ThisLabel == "AskToSaveOnExit"
    Aborted := False

    Loop % nTabs := Sci.Length() {
        Ret := CloseTab(nTabs--, Confirm, NoToAll, Exiting)
        If (Ret == -1) { ; No to All
            Confirm := False
        } Else If (Ret == 0) {
            Aborted := True
            Break
        }
    }

    If (A_ThisLabel == "AskToSaveOnExit" && !Aborted) {
        Quit()
    }

    If (!Aborted) {
        Sci[1].Number := g_TabCounter := 1
        TabEx.SetText(1, "Untitled 1")
    }

    Repaint(hAutoWnd)
Return

ConfirmCloseTab(Title, NoToAllBtn := False) {
    Text := "The file was modified. Do you want to save it?"
    If (NoToAllBtn) {
        Buttons := [[6, "Yes"], [7, "No"], [10, "No to All"], [2, "Cancel"]]
        Result := SoftModalMessageBox(Text, Title, Buttons, 1, 0x31, "", 0, -1, hAutoWnd)
    } Else {
        Result := DllCall("MessageBox", "Ptr", hAutoWnd, "Str", Text, "Str", Title, "UInt", 0x33)
    }

    Return {6: "Yes", 7: "No", 10: "NoToAll", 2: "Cancel"}[Result]
}

GetText(n) {
    nLen := Sci[n].GetLength() + 1
    VarSetCapacity(SciText, nLen, 0)
    Sci[n].2182(nLen, &SciText)
    Return StrGet(&SciText, "UTF-8")
}

GetSelectedText() {
    n := TabEx.GetSel()
    SelLength := Sci[n].GetSelText() - 1
    VarSetCapacity(SelText, SelLength, 0)
    Sci[n].GetSelText(0, &SelText)
    Return StrGet(&SelText, SelLength, "UTF-8")
}

SetSelectedText(Text) {
    Sci[TabEx.GetSel()].ReplaceSel("", Text, 1)
}

GetCurrentLine() {
    n := TabEx.GetSel()
    LineNum := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    LineLen := Sci[n].LineLength(LineNum) + 1
    VarSetCapacity(LineText, LineLen, 0)
    Sci[n].2027(LineLen, &LineText) ; SCI_GETCURLINE
    Return RTrim(StrGet(&LineText, "UTF-8"), CRLF)
}

GetCurrentWord(ByRef Word, Pos := -1) {
    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    PrevChar := Chr(Sci[n].GetCharAt(CurrentPos - 1))
    If (PrevChar == " " || PrevChar == ",") {
        CurrentPos--
    }
    CurrentPos := (Pos == -1) ? CurrentPos : Pos
    WordStartPos := Sci[n].WordStartPosition(CurrentPos, True)
    PrevChar := Chr(Sci[n].GetCharAt(WordStartPos - 1))
    If (PrevChar == "#" || PrevChar == ".") {
        WordStartPos--
    }
    WordEndPos := Sci[n].WordEndPosition(CurrentPos, True)
    Word := GetTextRange(n, [WordStartPos, WordEndPos])
    Return [WordStartPos, WordEndPos]
}

; SCI_WORDSTARTPOSITION(int pos, bool onlyWordCharacters) → int
GetWordPos() {
    n := TabEx.GetSel()
    Pos := Sci[n].GetCurrentPos()
    WordStartPos := Sci[n].WordStartPosition(Pos, True)
    PrevChar := Chr(Sci[n].GetCharAt(WordStartPos - 1))
    If (PrevChar == "#" || PrevChar == ".") {
        WordStartPos--
    }
    WordEndPos := Sci[n].WordEndPosition(Pos, True)
    Return [WordStartPos, WordEndPos]
}

GetTextRange(n, Range) {
    VarSetCapacity(Text, Abs(Range[1] - Range[2]) + 1, 0)
    VarSetCapacity(Sci_TextRange, 8 + A_PtrSize, 0)
    NumPut(Range[1], Sci_TextRange, 0, "UInt")
    NumPut(Range[2], Sci_TextRange, 4, "UInt")
    NumPut(&Text, Sci_TextRange, 8, "Ptr")
    Sci[n].2162(0, &Sci_TextRange) ; SCI_GETTEXTRANGE
    Return StrGet(&Text,, "UTF-8")
}

; Scintilla notification handler
OnWM_NOTIFY(wParam, lParam, msg, hWnd, obj) {
    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()

    If (obj.SCNCode == SCN_UPDATEUI) {
        ; The updated field is set to the bit set of things changed since the previous notification.
        ; SC_UPDATE_CONTENT 	0x01 	Contents, styling or markers have been changed.
        ; SC_UPDATE_SELECTION 	0x02 	Selection has been changed.
        ; SC_UPDATE_V_SCROLL 	0x04 	Scrolled vertically.
        ; SC_UPDATE_H_SCROLL 	0x08 	Scrolled horizontally.

        ; Highlight identical text
        If (obj.Updated < 4) {
            If (g_HighlightIdenticalText) {
                HighlightIdenticalText(n, CurPos)
            }

            ; Brace matching
            BracePos := CurPos - 1
            BraceMatch := Sci[n].BraceMatch(BracePos, 0)
            If (BraceMatch == -1) {
                BracePos := CurPos
                BraceMatch := Sci[n].BraceMatch(CurPos, 0)
            }

            If (BraceMatch != -1) {
                Sci[n].BraceHighlight(BracePos, BraceMatch)
            } Else {
                Sci[n].BraceHighlight(-1, -1)
            }
        }

        UpdateStatusBar()

    } Else If (obj.SCNCode == SCN_MODIFIED) {
        ;OutputDebug % obj.ModType

        If (obj.LinesAdded) {
            SetLineNumberWidth(n)
        }

    } Else If (obj.SCNCode == SCN_SAVEPOINTREACHED) {

        SetDocumentStatus(n)

    } Else If (obj.SCNCode == SCN_SAVEPOINTLEFT) {

        SetDocumentStatus(n)

    } Else If (obj.SCNCode == SCN_CHARADDED) {

        ; Auto-indent
        If (obj.Ch == 13 && g_AutoIndent && !GetKeyState("Shift", "P")) {
            Line := Sci[n].LineFromPosition(CurPos)
            Indentation := Sci[n].GetLineIndentation(Line - 1)
            Sci[n].SetLineIndentation(Line, Indentation)
            If (Indentation) {
                Sci[n].GoToPos(Sci[n].GetLineIndentPosition(Line))
            }
        }

        Lexer := Sci[n].GetLexer()

        ; Autocomplete
        If (g_AutoCEnabled && Lexer == SCLEX_AHKL) {
            AutoComplete(g_AutoCMinLength)
        }

        ; Calltips
        If (g_Calltips && Lexer == SCLEX_AHKL && (obj.Ch == 40 || obj.Ch == 44 || obj.Ch == 32)) {
            WordPos := GetCurrentWord(Word, CurPos - 1)
            Calltip := GetCalltip(Word)
            If (Word != "If") {
                ShowCalltip(n, Calltip, WordPos[1])
            }
        }

        If (!g_AutoBrackets) {
            Return
        }

        ; Autoclose brackets ([{""}])
        Char := obj.Ch
        If Char in 40,91,123,34 ; Parentheses, brackets, braces, quotes
        {
            PrevChar := Chr(Sci[n].GetCharAt(CurPos - 2))
            NextChar := Chr(Sci[n].GetCharAt(CurPos))

            ;GetCurrentWord(PrevWord, CurPos - 1)
            GetCurrentWord(NextWord, CurPos + 1)

            If (NextWord == CRLF) {
                NextWord := ""
            }

            If (NextWord != "") {
                Return
            }

            ; Parentheses
            If (obj.Ch == 40 && NextChar != ")") {
                Sci[n].InsertText(CurPos, ")", 1)

            ; Brackets
            } Else If (obj.Ch == 91 && NextChar != "]") {
                Sci[n].InsertText(CurPos, "]", 1)

            ; Braces
            } Else If (obj.Ch == 123 && NextChar != "}") {
                PrevChars := GetTextRange(n, [CurPos - 5, CurPos])
                If (RegExMatch(PrevChars, "\)\s?\r?\n?")) {
                    Line := Sci[n].LineFromPosition(CurPos)
                    iIndentation := Sci[n].GetLineIndentation(Line)

                    If (iIndentation) {
                        If (g_IndentWithSpaces) {
                            sIndentation := Format("{1: " . iIndentation . "}", "")
                        } Else {
                            Loop % iIndentation // g_TabSize {
                                sIndentation .= "`t"
                            }
                        }
                    } Else {
                        sIndentation := ""
                    }

                    Sci[n].InsertText(CurPos, CRLF . sIndentation . Indent . CRLF . sIndentation . "}", 1)
                    Sci[n].GoToPos(CurPos + StrLen(CRLF . sIndentation . Indent))
                } Else {
                    Sci[n].InsertText(CurPos, "}", 1)
                }

            ; Quotes
            } Else If (obj.Ch == 34 && NextChar != """"
             && (PrevChar == ""
             || PrevChar == " "
             || PrevChar == "`r"
             || PrevChar == "`n"
             || PrevChar == ","
             || PrevChar == "("
             || PrevChar == "[")) {
                Sci[n].InsertText(CurPos, """", 1)
            }
        }

    } Else If (obj.SCNCode == SCN_AUTOCCOMPLETED) {

        Keyword := StrGet(obj.Text,, "UTF-8")

        If (g_Calltips && Keyword != "GuiClose") {
            CallTip := GetCallTip(Keyword, True)
            ShowCalltip(n, CallTip, GetWordPos()[1])
        }

    } Else If (obj.SCNCode == SCN_DWELLSTART && Sci[n].GetLexer() == SCLEX_AHKL) {

        If (g_Calltips) {
            If (obj.Position != -1) {
                WordPos := GetCurrentWord(Word, obj.Position)
                ShowCalltip(n, GetCalltip(Word, False), WordPos[1])
            }
        }

        If (g_DbgStatus) {
            If (obj.Position != -1) {
                WordPos := GetCurrentWord(Word, obj.Position)

                Variables := [g_DbgLocalVariables, g_DbgGlobalVariables]

                Loop % Variables.Length() {
                    For Each, Item in Variables[A_Index] {
                        If (Item.Name == Word) {
                            If (Item.Type == "Object") {
                                Value := "(Object)"
                            } Else If (InStr(Item.Type, "(", 1) || Item.Type == "Undefined") {
                                Value := Item.Type
                            } Else {
                                Value := Item.Value
                            }

                            ShowCalltip(n, Word . " = " . Value, WordPos[1])
                            Break 2 ; Break the outer loop
                        }
                    }
                }
            }
        }

    } Else If (obj.SCNCode == SCN_DWELLEND) {

        Sci[n].CalltipCancel()

    } Else If (obj.SCNCode == SCN_CALLTIPCLICK) {

        ; The position field is set to 1 if the click is in an up arrow, 2 if in a down arrow, and 0 if elsewhere.
        If (obj.Position == 0) {
            InsertCalltip()
            Return
        } Else If (obj.Position == 1) {
            g_CalltipParamsIndex--
        } Else {
            g_CalltipParamsIndex++
        }

        If ((obj.Position == 1 && g_CalltipParamsIndex > 1)
        || (g_CalltipParams.Length() == g_CalltipParamsIndex)) {
            Arrow := 1 ; Up arrow
        } Else {
            Arrow := 2 ; Down arrow
        }

        WordStartPos := Sci[n].WordStartPosition(CurPos - 1, True)

        Sci[n].CalltipShow(WordStartPos, Chr(Arrow) . g_CalltipParams[g_CalltipParamsIndex], 1)

    } Else If (obj.SCNCode == SCN_MARGINCLICK) {

        Line := Sci[n].LineFromPosition(obj.Position)

        If (obj.Margin == 1) {
            If (Sci[n].MarkerGet(Line) & (1 << g_MarkerError)) {
                Sci[n].MarkerDelete(Line, g_MarkerError)
            } Else {
                If (GetKeyState("Shift", "P")) {
                    Marker := g_MarkerError
                } Else {
                    Marker := g_DbgStatus ? g_MarkerBreakpoint : g_MarkerBookmark
                }

                ToggleBookmark(Marker, Line)
            }

        } Else If (obj.Margin == 2) {
            Sci[n].ToggleFold(Line)
        }

    } Else If (obj.SCNCode == SCN_ZOOM) {
        Sci[n].MarginLen := 0
        SetLineNumberWidth(n)

    } Else If (obj.SCNCode == SCN_MODIFYATTEMPTRO && n == g_GuiTab) {
        AskToDisconnect()
    }

    Return
}

HighlightIdenticalText(n, CurPos) {
    Local TextLength, WordStartPos, WordEndPos, SelStart, SelEnd, SelCount
        , String, StringLength, MatchCount, TargetStart, TargetEnd

    TextLength := Sci[n].GetLength()

    WordStartPos := Sci[n].WordStartPosition(CurPos, True)
    WordEndPos := Sci[n].WordEndPosition(CurPos, True)
    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()
    SelCount := SelEnd - SelStart

    ; Clear previous highlights
    Sci[n].SetIndicatorCurrent(2)
    Sci[n].IndicatorClearRange(0, TextLength)

    If (SelCount == 0
    || WordStartPos != SelStart
    || WordEndPos != SelEnd
    || Sci[n].LineFromPosition(SelStart) != Sci[n].LineFromPosition(SelEnd)) {
        Return
    }

    String := GetSelectedText()

    Sci[n].IndicSetStyle(2, 8) ; INDIC_STRAIGHTBOX
    Sci[n].IndicSetFore(2, CvtClr(0x3FBBE3))
    Sci[n].IndicSetOutlineAlpha(2, 80) ; Opaque border
    Sci[n].IndicSetAlpha(2, 80)

    Sci[n].SetSearchFlags(0)

    Sci[n].SetTargetStart(0)
    Sci[n].SetTargetEnd(TextLength)
    StringLength := StrPut(String, "UTF-8") - 1

    MatchCount := 0
    While (Sci[n].SearchInTarget(StringLength, "" . String, 1) != -1 && ++MatchCount < 2000) {
        TargetStart := Sci[n].GetTargetStart()
        TargetEnd := Sci[n].GetTargetEnd()
        If (TargetEnd != SelEnd) { ; ?
            Sci[n].IndicatorFillRange(TargetStart, TargetEnd - TargetStart)
        }

        Sci[n].SetTargetStart(TargetEnd)
        Sci[n].SetTargetEnd(TextLength)
    }
}

; Called from SCN_UPDATEUI, TabHandler and SetStatusBar
UpdateStatusBar() {
    If (!g_GuiVis) {
        n := TabEx.GetSel()
        CurPos := Sci[n].GetCurrentPos()
        Line := Sci[n].LineFromPosition(CurPos) + 1
        Column := Sci[n].GetColumn(CurPos) + 1

        SelStart := Sci[n].GetSelectionStart()
        SelEnd := Sci[n].GetSelectionEnd()
        SelLength := SelEnd - SelStart
        Selection := SelLength ? ", " . SelLength : ""

        Gui Auto: Default
        SB_SetText(Line . ":" . Column . Selection, 2)

        UpdateDocumentStatus(n)

        If (g_DbgStatus && Sci[n].FullName = g_DbgSession.CurrentFile) {
            SB_SetText("Debugging")
            SB_SetIcon(IconLib, 103)
        } Else {
            SB_SetText("")
            SendMessage 0x40F, 0, 0,, ahk_id %g_hStatusBar% ; SB_SETICON
        }
    }
}

UpdateDocumentStatus(n) {
    If (n != TabEx.GetSel()) {
        Return
    }

    Gui Auto: Default
    If (Sci[n].GetReadOnly()) {
        SB_SetText("Read only", 3)
    } Else If (Sci[n].GetModify()) {
        SB_SetText("Modified", 3)
    } Else {
        SB_SetText("", 3)
    }

    SB_SetText(GetFileEncodingDisplayName(n), 5)
}

; Called from SCN_SAVEPOINTREACHED, SCN_SAVEPOINTLEFT, NewGUI and Save.
SetDocumentStatus(n) {
    TabCaption := Sci[n].Filename != "" ? Sci[n].Filename : "Untitled " . Sci[n].Number
    TabEx.SetText(n, TabCaption . (Sci[n].GetModify() ? " *" : ""))

    If (!g_GuiVis) {
        UpdateDocumentStatus(n)
    }
}

Undo() {
    n := TabEx.GetSel()
    Sci[n].Undo()
    Repaint(Sci[n].hWnd) ; ?
}

Redo() {
    Sci[TabEx.GetSel()].Redo()
}

Cut() {
    Sci[TabEx.GetSel()].Cut()
}

Copy() {
    n := TabEx.GetSel()
    If (GetSelectedText() == "") {
        Clipboard := GetText(n)
    } Else {
        Sci[n].Copy()
    }
}

Paste() {
    Sci[TabEx.GetSel()].Paste()
}

Clear() {
    Sci[TabEx.GetSel()].Clear()
}

SelectAll() {
    Sci[TabEx.GetSel()].SelectAll()
}

DuplicateLine() {
    Sci[TabEx.GetSel()].LineDuplicate()
}

MoveLineUp() {
    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()
    CurCol := Sci[n].GetColumn(CurPos)
    SelLength := Sci[n].GetSelText() - 1
    Sci[n].MoveSelectedLinesUp()

    ; If there is no selection, maintain the cursor position
    if (!SelLength) {
        NewPos := Sci[n].GetCurrentPos()
        Sci[n].GoToPos(NewPos + CurCol)
    }
}

MoveLineDown() {
    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()
    CurCol := Sci[n].GetColumn(CurPos)
    SelLength := Sci[n].GetSelText() - 1
    Sci[n].MoveSelectedLinesDown()

    if (!SelLength) {
        NewPos := Sci[n].GetCurrentPos()
        Sci[n].GoToPos(NewPos + CurCol)
    }
}

M_AutoComplete() {
    AutoComplete(0)
}

M_ShowCalltip() {
    WordPos := GetCurrentWord(Word)
    Calltip := GetCalltip(Word)
    ShowCalltip(TabEx.GetSel(), Calltip, WordPos[1])
}

M_InsertParameters() {
    InsertCalltip()
}

InsertDateTime() {
    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    FormatTime TimeString, D1
    Sci[n].InsertText(CurrentPos, "" . TimeString, 1)
    Sci[n].GoToPos(CurrentPos + StrPut(TimeString, "UTF-8") - 1)
}

ToggleReadOnly() {
    n := TabEx.GetSel()
    ReadOnly := !Sci[n].GetReadOnly()
    SetReadOnly(n, ReadOnly)

    If (!g_GuiVis) {
        UpdateDocumentStatus(n)
    }
}

SetReadOnly(n, ReadOnly) {
    Sci[n].SetReadOnly(ReadOnly)
    Menu AutoEditMenu, % ReadOnly ? "Check" : "Uncheck", Set as &Read-Only
    SendMessage TB_CHECKBUTTON, 2170, ReadOnly,, ahk_id %hMainToolbar%
}

ShowGoToLineDialog() {
    Line := InputBoxEx("Line Number:", "", "Go to Line", "", "", "x94 w80 Number", hAutoWnd, 270)
    If (!ErrorLevel) {
        ShowChildWindow(0)

        n := TabEx.GetSel()
        Sci[n].GrabFocus()

        If (Line != "") {
            Sci[n].GoToLine(Line - 1) ; 0-based index
            GoToLineEx(n, Line - 1)
        } Else {
            GoToRandomLine(n)
        }
    }
}

ToggleBookmark:
    ToggleBookmark(g_MarkerBookmark)
Return

ToggleErrormark:
    ToggleBookmark(g_MarkerError)
Return

ToggleBookmark(Marker, Line := -1) {
    n := TabEx.GetSel()
    If (Line == -1) {
        Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    }

    If (Sci[n].MarkerGet(Line) & (1 << Marker)) {
        Sci[n].MarkerDelete(Line, Marker)
    } Else {
        Sci[n].MarkerAdd(Line, Marker)
    }
}

MarkSelectedText() {
    n := TabEx.GetSel()
    Sci[n].SetIndicatorCurrent(1)

    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()

    ; Unmark if marked
    If ((Sci[n].IndicatorAllOnFor(SelStart) & 2) == 2) {
        Sci[n].IndicatorClearRange(SelStart, SelEnd - SelStart)
        Return
    }

    Sci[n].IndicSetStyle(1, INDIC_ROUNDBOX)
    Sci[n].IndicSetFore(1, CvtClr(0x3FBBE3))
    Sci[n].IndicSetOutlineAlpha(1, 255) ; Opaque border
    Sci[n].IndicSetAlpha(1, 80)
    Sci[n].IndicatorFillRange(SelStart, SelEnd - SelStart)
    Sci[n].SetSel(-1, Sci[n].GetCurrentPos())
}

ClearAllMarks() {
    n := TabEx.GetSel()
    Sci[n].MarkerDeleteAll(g_MarkerBookmark)
    Sci[n].MarkerDeleteAll(g_MarkerError)
    Sci[n].SetIndicatorCurrent(1)
    Sci[n].IndicatorClearRange(0, Sci[n].GetLength()) ; Marked text
}

GoToNextMark() {
    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    Marks := GetMarks()

    Loop % Marks.Length() {
        If (Marks[A_Index] > CurrentPos) {
            Pos := Marks[A_Index]
            SetSelEx(n, Pos, Pos)
            Break
        }
    }
}

GoToPreviousMark() {
    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    Marks := GetMarks()
    Max := Marks.Length()

    Loop %Max% {
        Index := Max - A_Index + 1
        If (Marks[Index] < CurrentPos) {
            Pos := Marks[Index]
            SetSelEx(n, Pos, Pos, 1)
            Break
        }
    }
}

; SCI_INDICATORALLONFOR: Retrieve a bitmap value representing which indicators are non-zero at a position.
GetMarks() {
    n := TabEx.GetSel()
    StartPos := 0
    EndPos := 0
    Max := Sci[n].GetLength()
    Marks := []

    ; Marked text
    Loop {
        StartPos := Sci[n].IndicatorStart(1, EndPos)
        EndPos := Sci[n].IndicatorEnd(1, StartPos)

        If ((Sci[n].IndicatorAllOnFor(StartPos) & 2) == 2) {
            Marks.Push(EndPos)
        }
    } Until !(EndPos != 0 && EndPos < Max)

    ; Marked lines
    LineStart := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())

    ; 15 (markerMask) = g_MarkerBookmark | g_MarkerBreakpoint | g_MarkerDebugStep | g_MarkerError
    Prev := GetMark(n, 15, LineStart, False)
    If (Prev != -1) {
        Marks.Push(Prev)
    }

    Next := GetMark(n, 15, LineStart, True)
    If (Next != -1) {
        Marks.Push(Next)
    }

    SortArray(Marks)
    Return Marks
}

GetMark(n, Mask, StartLine, Next := True) {
    If (Next) {
        Line := Sci[n].MarkerNext(StartLine + 1, Mask)
    } Else {
        Line := Sci[n].MarkerPrevious(StartLine - 1, Mask)
    }

    Return (Line != -1) ? Sci[n].PositionFromLine(Line) : -1
}

SortArray(ByRef Arr) {
    Len := Arr.Length()
    Loop {
        n := 0
        Loop % (Len - 1) {
            If (Arr[A_Index] > Arr[A_Index + 1]) {
                Temp := Arr[A_Index]
                Arr[A_Index] := Arr[A_Index + 1]
                Arr[A_Index + 1] := Temp
                n := A_Index
            }
        }
        Len := n
    } Until (n == 0)
}

GoToMatchingBrace() {
    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()

    BracePos := CurPos - 1
    BraceMatch := Sci[n].BraceMatch(BracePos, 0)
    If (BraceMatch == -1) {
        BracePos := CurPos
        BraceMatch := Sci[n].BraceMatch(CurPos, 0)
    }

    If (BraceMatch != -1) {
        Sci[n].GoToPos(BraceMatch + 1)
    }
}

Lowercase() {
    Sci[TabEx.GetSel()].LowerCase()
}

Uppercase() {
    Sci[TabEx.GetSel()].UpperCase()
}

TitleCase() {
    n := TabEx.GetSel()
    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()
    SelText := GetTextRange(n, [SelStart, SelEnd])
    StringUpper SelText, SelText, T
    Sci[n].ReplaceSel("", SelText, 1)
    Sci[n].SetSel(SelStart, SelEnd)
}

Dec2Hex() {
    SetSelectedText(ToHex(GetSelectedText()))
}

Hex2Dec() {
    SetSelectedText(ToDec(GetSelectedText()))
}

LookupConstant(ByRef Constant) {
    If (!IsObject(g_AutoCWin32XMLObj)) {
        g_AutoCWin32XMLObj := LoadXML(A_ScriptDir . "\Tools\Windows.xml")
    }

    StringUpper Constant, % Trim(Constant)
    Node := g_AutoCWin32XMLObj.selectSingleNode("//item[@const='" . Constant . "']")
    Value := Node.getAttribute("value")
    Return Value != "" ? Format("0x{:X}", Value) : ""
}

ReplaceConstant() {
    Constant := GetSelectedText()

    Value := LookupConstant(Constant)
    If (Constant ~= "\d+" || Value == "") {
        Run % A_ScriptDir . "\Tools\Constantine.ahk /find " . RegExReplace(Constant, "0X", "0x"), Tools
        Return
    }

    If (InStr(A_ThisMenuItem, "Declare")) {
        SetSelectedText(Constant . " := " . Value)
    } Else If (InStr(A_ThisMenuItem, "SendMessage")) {
        Output := "SendMessage " . Value . ", wParam, lParam,, ahk_id %hWnd% `; " . Constant
        SetSelectedText(Output)
    } Else If (InStr(A_ThisMenuItem, "OnMessage")) {
        Output := "OnMessage(" . Value . ", ""On" . Constant . """)" . CRLF . CRLF
               .  "On" . Constant . "(wParam, lParam, msg, hWnd) {" . CRLF . CRLF . "}" . CRLF
        SetSelectedText(Output)
    }
}

ToggleComment() {
    n := TabEx.GetSel()
    Pos := Sci[n].GetCurrentPos()

    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()
    LineStartPos := Sci[n].PositionFromLine(Sci[n].LineFromPosition(SelStart))
    If (SelStart == SelEnd) {
        SelEnd := Sci[n].GetLineEndPosition(Sci[n].LineFromPosition(SelEnd))
    }

    Sci[n].SetSel(LineStartPos, SelEnd)
    SelText := GetSelectedText()

    Lines := ""
    Count := 0
    Loop Parse, SelText, `n, `r
    {
        ; Uncomment
        If (RegExMatch(A_LoopField, "^\s*\;")) {
            Lines .= RegExReplace(A_LoopField, "\;", "", "", 1) . CRLF
            Count--

        } Else If (A_LoopField == "") {
            Lines .= CRLF

        ; Comment
        } Else {
            RegExMatch(A_LoopField, "^\s+", Indentation)
            Lines .= Indentation . ";" . StrReplace(A_LoopField, Indentation, "",, 1) . CRLF
            Count++
        }
    }

    Lines := RegExReplace(Lines, "`r`n$", "", "", 1)
    SetSelectedText(Lines)
    Sci[n].GoToPos(Pos + Count)
}

ZoomIn() {
    Sci[TabEx.GetSel()].ZoomIn()
}

ZoomOut() {
    Sci[TabEx.GetSel()].ZoomOut()
}

ResetZoom() {
    Sci[TabEx.GetSel()].SetZoom(0)
}

ChangeEditorFont() {
    If (ChooseFont(g_SciFontName, g_SciFontSize, "", "0x000000", 0x800041, hAutoWnd)) {
        Loop % Sci.Length() {
            Sci[A_Index].MarginLen := 0
            Sci_SetStyle(A_Index, g_SciFontName, g_SciFontSize)
        }
    }
}

ToggleLineNumbers() {
    g_LineNumbers := !g_LineNumbers

    Loop % Sci.Length() {
        SetLineNumberWidth(A_Index)
    }

    SendMessage TB_CHECKBUTTON, 2140, %g_LineNumbers%,, ahk_id %hMainToolbar%
    Menu AutoViewMenu, ToggleCheck, &Line Numbers
}

ToggleSymbolMargin() {
    g_SymbolMargin := !g_SymbolMargin

    ShowSymbolMargin(g_SymbolMargin)

    Menu AutoViewMenu, ToggleCheck, Symbol Margin
}

ShowSymbolMargin(bShow) {
    Loop % Sci.Length() {
        Sci[A_Index].SetMarginWidthN(1, bShow ? 16 : 0)
    }
}

ToggleCodeFolding() {
    g_CodeFolding := !g_CodeFolding

    If (g_CodeFolding) {
        Loop % Sci.Length() {
            SetCodeFolding(A_Index)
        }
    } Else {
        Loop % Sci.Length() {
            Sci[A_Index].SetMarginWidthN(2, 0)
        }

        ExpandFolds()
    }

    SendMessage TB_CHECKBUTTON, 2150, %g_CodeFolding%,, ahk_id %hMainToolbar%
    Menu AutoViewMenu, ToggleCheck, &Fold Margin
}

CollapseFolds() {
    Sci[TabEx.GetSel()].FoldAll(0) ; SC_FOLDACTION_CONTRACT
}

ExpandFolds() {
    Sci[TabEx.GetSel()].FoldAll(1) ; SC_FOLDACTION_EXPAND
}

ToggleWordWrap() {
    n := TabEx.GetSel()
    g_WordWrap := !Sci[n].GetWrapMode()
    Sci[n].SetWrapMode(g_WordWrap)
    Menu AutoViewMenu, ToggleCheck, &Wrap Long Lines ; &Word Wrap
    SendMessage TB_CHECKBUTTON, 2160, %g_WordWrap%,, ahk_id %hMainToolbar%
}

; Show spaces, tabs and line breaks
ToggleWhiteSpaces() {
    g_ShowWhiteSpaces := !g_ShowWhiteSpaces

    ShowWhiteSpaces(g_ShowWhiteSpaces)

    SendMessage TB_CHECKBUTTON, 2190, %g_ShowWhiteSpaces%,, ahk_id %hMainToolbar%
    Menu AutoViewMenu, ToggleCheck, &Show White Spaces
}

ShowWhiteSpaces(bShow) {
    Loop % Sci.Length() {
        Sci[A_Index].2086(bShow ? 2 : 0) ; SCI_SETWHITESPACESIZE
        Sci[A_Index].SetWhiteSpaceFore(1, CvtClr(0x008EBC))
        Sci[A_Index].SetViewWS(bShow)
        Sci[A_Index].SetViewEOL(bShow)
    }
}

ToggleSyntaxHighlighting() {
    g_SyntaxHighlighting := !g_SyntaxHighlighting

    If (g_SyntaxHighlighting) {
        Loop % Sci.Length() {
            Sci_SetStyle(A_Index, g_SciFontName, g_SciFontSize)
        }
    } Else {
        Loop % Sci.Length() {
            DisableSyntaxHighlighting(A_Index)
        }
    }

    Menu AutoViewMenu, ToggleCheck, Syntax &Highlighting
    SendMessage TB_CHECKBUTTON, 2180, %g_SyntaxHighlighting%,, ahk_id %hMainToolbar%
}

DisableSyntaxHighlighting(n) {
    Sci[n].StyleClearAll()

    If (g_DarkTheme) {
        Sci[n].StyleSetFore(33, CvtClr(0xf8f8f2))
        Sci[n].StyleSetBack(33, CvtClr(0x272822))
    } Else {
        Sci[n].StyleSetFore(33, CvtClr(0xCFD2CA))
        Sci[n].StyleSetBack(33, CvtClr(0xFFFFFF))
    }
}

ToggleHighlightActiveLine() {
    g_HighlightActiveLine := !g_HighlightActiveLine

    If (g_DarkTheme) {
        Color := g_HighlightActiveLine ? 0x3E3D32 : 0x272822
    } Else {
        Color := g_HighlightActiveLine ? 0xD8F3FF : 0xFFFFFF
    }

    Loop % Sci.Length() {
        Sci[A_Index].SetCaretLineBack(CvtClr(Color))
    }

    Menu AutoViewMenu, ToggleCheck, Highlight &Active Line
}

ToggleHighlightIdenticalText() {
    g_HighlightIdenticalText := !g_HighlightIdenticalText
    Sci[n].SetIndicatorCurrent(2)
    Sci[n].IndicatorClearRange(0, Sci[n].GetLength())
    Menu AutoViewMenu, ToggleCheck, Highlight Identical Te&xt
}

LoadXML(FileName) {
    Local x
    x := ComObjCreate("MSXML2.DOMDocument.6.0")
    x.async := False
    x.load(FileName)
    Return x
}

LoadAutoComplete(FileName) {
    g_AutoCList := ""
    g_AutoCXMLObj := LoadXML(FileName)

    Keys := g_AutoCXMLObj.getElementsByTagName("key")
    For Key in Keys {
        g_AutoCList .= key.getAttribute("name") . " "
    }

    g_AutoCList := RTrim(g_AutoCList, " ")
}

AutoComplete(MinLength := 3, Filter := "") {
    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()

    WordStartPos := Sci[n].WordStartPosition(CurPos, True)
    LengthEntered := CurPos - WordStartPos
    WordFirstChar := Sci[n].GetCharAt(WordStartPos - 1)

    If (WordFirstChar == 35 || WordFirstChar == 46) { ; # .
        LengthEntered++
    }

    If ((LengthEntered >= MinLength) && !Sci[n].AutoCActive()) {
        Sci[n].AutoCShow(LengthEntered, "" . g_AutoCList, 1)
        /*
        GetCurrentWord(Word)
        If (Word = "Ret") {
            Sci[n].AutoCSelect("", "Return", 1)
        }
        */
    }
}

GetCallTip(Keyword, Overload := True) {
    RegExMatch(" " . g_AutoCList . " ", "i) " . Keyword . " ", Keyword)
    Keyword := Trim(Keyword)
    Node := g_AutoCXMLObj.selectSingleNode("//key[@name=""" . Keyword . """]")

    If (Keyword == "Hotkey" || Keyword == "Progress") {
        LineText := GetCurrentLine()
        If (RegExMatch(LineText, "i)\s*Gui")) {
            Return
        }
    }

    Params := Node.selectNodes("params")
    g_CalltipParams := []
    Loop % Params.length {
        Calltip := Params.item(A_Index - 1).text
        Separator := (SubStr(Calltip, 1, 1) != "(") ? " " : ""
        g_CalltipParams.Push(Keyword . Separator . Calltip)
    }

    If (Params.item(0).text != "") {
        Return (Overload && Params.length > 1) ? Chr(2) . g_CalltipParams[1] : g_CalltipParams[1]
    }
}

ShowCalltip(n, Calltip, StartPos) {
    If (CallTip != "") {
        Sci[n].CalltipShow(StartPos, CallTip, 1)
        Return g_CalltipParamsIndex := 1
    }
}

InsertCalltip() {
    n := TabEx.GetSel()
    If (Sci[n].AutoCActive()) {
        Sci[n].AutoCComplete()
    }

    EndPos := GetCurrentWord(Word)[2]
    GetCalltip(Word, False)
    Calltip := StrReplace(g_CalltipParams[g_CalltipParamsIndex], Word,,, 1)

    NextChar := Chr(Sci[n].GetCharAt(EndPos))
    If (NextChar == " " || NextChar == ",") {
        Sci[n].2645(EndPos, 1) ; SCI_DELETERANGE
    }

    Sci[n].InsertText(EndPos, Calltip, 1)
    Sci[n].WordRight()
    Sci[n].CalltipCancel()
}

NextCalltip(Previous := 0) {
    If ((Previous && g_CalltipParamsIndex == 1)
    || (!Previous && g_CalltipParams.Length() == g_CalltipParamsIndex)) {
        Return
    }

    n := TabEx.GetSel()
    obj := {}
    obj.SCNCode := SCN_CALLTIPCLICK
    obj.Position := Previous ? 1 : 2

    Sci[n].Notify(0, 0, 0, 0, obj)
}

ToggleAutoComplete() {
    g_AutoCEnabled := !g_AutoCEnabled
    Menu AutoOptionsMenu, ToggleCheck, Enable &Autocompletion
}

ToggleCalltips() {
    g_Calltips := !g_Calltips
    Menu AutoOptionsMenu, ToggleCheck, Enable &Calltips
}

ToggleAutoBrackets() {
    g_AutoBrackets := !g_AutoBrackets
    Menu AutoOptionsMenu, ToggleCheck, Autoclose &Brackets
}

ShowIndentationDialog:
    Gui IndentDlg: New, LabelIndentDlg hWndhIndentDlg -MinimizeBox OwnerAuto
    SetWindowIcon(hIndentDlg, IconLib, 91)
    Gui Font, s9, Segoe UI
    Gui Color, White
    Gui Add, Text, x16 y16 w95 h23 +0x200, Indentation size:
    Gui Add, Edit, vg_TabSize x112 y17 w50 h21 Number
    Gui Add, UpDown, x167 y18 w17 h21, %g_TabSize%
    Gui Add, CheckBox, vg_IndentWithSpaces x16 y47 w181 h23 Checked%g_IndentWithSpaces%, Indent with spaces
    Gui Add, CheckBox, vg_AutoIndent x16 y79 w181 h23 Checked%g_AutoIndent%, Automatic indentation
    Gui Add, CheckBox, vg_IndentGuides x16 y111 w181 h23 Checked%g_IndentGuides%, Show indentation guides
    Gui Add, Text, x-1 y146 w337 h49 -Background +Border
    Gui Add, Button, gSetIndentationSettings x150 y158 w84 h24 +Default, &OK
    Gui Add, Button, gIndentDlgClose x241 y158 w84 h24, &Cancel
    Gui Show, w334 h194, Indentation Settings
Return

IndentDlgEscape:
IndentDlgClose:
    Gui IndentDlg: Destroy
Return

SetIndentationSettings() {
    Gui IndentDlg: Submit

    IndentView := g_IndentGuides ? 3 : 0 ; 3 = SC_IV_LOOKBOTH

    Loop % Sci.Length() {
        Sci[A_Index].SetTabWidth(g_TabSize)
        Sci[A_Index].SetUseTabs(!g_IndentWithSpaces)
        Sci[A_Index].SetIndentationGuides(IndentView)
    }

    SetIndent() ; For generated code
}

ShowCaretDialog:
    Gui CaretDlg: New, LabelCaretDlg hWndhCaretDlg -MinimizeBox
    SetWindowIcon(hCaretDlg, IconLib, 14)
    Gui Font, s9, Segoe UI
    Gui Color, White
    Gui Add, Text, x22 y22 w120 h23 +0x200, Caret width:
    Gui Add, DropDownList, vDDLCaretWidth x147 y22 w109, Invisible|1|2|3|Block
    CaretWidth := g_CaretStyle == 1 ? g_CaretWidth : g_CaretStyle == 0 ? "Invisible" : "Block"
    GuiControl ChooseString, DDLCaretWidth, %CaretWidth%
    Gui Add, Text, x22 y63 w120 h23 +0x200, Blinking rate:
    Gui Add, Edit, vg_CaretBlink x147 y63 w109 h21 +Number, %g_CaretBlink%
    Gui Add, Text, x-1 y106 w281 h48 +0x200 -Background +Border
    Gui Add, Button, gSetCaretSettings x94 y118 w84 h24 +Default, &OK
    Gui Add, Button, gCaretDlgClose x185 y118 w84 h24, &Cancel
    Gui Show, w279 h152, Caret Settings
Return

CaretDlgEscape:
CaretDlgClose:
    Gui CaretDlg: Destroy
Return

SetCaretSettings() {
    Global
    Gui CaretDlg: Submit

    If (DDLCaretWidth ~= "Block|Invisible") {
        g_CaretStyle := DDLCaretWidth == "Block" ? 2 : 0
    } Else {
        g_CaretWidth := DDLCaretWidth
        g_CaretStyle := 1
    }

    Loop % Sci.Length() {
        Sci[A_Index].SetCaretWidth(g_CaretWidth)
        Sci[A_Index].SetCaretStyle(g_CaretStyle)
        Sci[A_Index].SetCaretPeriod(g_CaretBlink)
    }

    nTbIdx := TabEx.GetSel()
    If (g_CaretBlink == 399 && g_CaretStyle == 2 && GetText(nTbIdx) == "") {
        Sci[nTbIdx].StyleSetFore(STYLE_DEFAULT, CvtClr(0xA6E22E))
        Sci[nTbIdx].StyleSetBack(STYLE_DEFAULT, CvtClr(0x272822))
        Sci[nTbIdx].StyleClearAll()
        Sci[nTbIdx].SetCaretFore(CvtClr(0x00EE00))
        Sci[nTbIdx].StyleSetFore(33, CvtClr(0xF8F8F2))
        Sci[nTbIdx].StyleSetBack(33, CvtClr(0x272822))
        Sci[nTbIdx].SetCaretLineBack(CvtClr(0x272822))
        Send % "Call trans opt: received. 2-19-98 13:24:18 REC:Log>"
    }
}

ToggleRememberSession() {
    g_RememberSession := !g_RememberSession
    g_LoadLastSession := g_RememberSession

    Menu AutoOptionsMenu, ToggleCheck, Remember Session
}

ToggleAskToSaveOnExit() {
    g_AskToSaveOnExit := !g_AskToSaveOnExit
    Menu AutoOptionsMenu, ToggleCheck, Ask to Save on Exit
}

ToggleTheme() {
    g_DarkTheme := !g_DarkTheme

    Loop % Sci.Length() {
        Sci_SetStyle(A_Index, g_SciFontName, g_SciFontSize)
        SetCodeFoldingColors(A_Index)
    }

    Menu AutoViewMenu, ToggleCheck, Enable Dark Theme
}

GoToRandomLine(n) {
    Max := Sci[n].GetLineCount() - 1
    Random RN, 0, %Max%
    Loop %Max% {
        If (GetLine(RN) != CRLF) {
            Break
        }
        RN++
    }
    Sci[n].GoToLine(RN)
    GoToLineEx(n, RN)
}

GetLine(Line) { ; 0-based
    Line := Line > 0 ? Line : 0
    n := TabEx.GetSel()
    LineLen := Sci[n].LineLength(Line)
    VarSetCapacity(LineText, LineLen, 0)
    Sci[n].GetLine(Line, &LineText)
    Return StrGet(&LineText,, "UTF-8")
}

GoToLineEx(n, Line) {
    Pos := Sci[n].PositionFromLine(Line)
    SetSelEx(n, Pos, Pos)
}

SetSelEx(n, StartPos, EndPos, Upward := 0) {
    Line := Sci[n].LineFromPosition(StartPos)

    Sci[n].EnsureVisible(Line) ; Expand hidden lines (contracted folds)

    If (Upward) {
        If (Line < Sci[n].GetFirstVisibleLine()) {
            Sci[n].GoToPos(StartPos)
            Sci[n].VerticalCentreCaret()
        }
    } Else {
        LastVisibleLine := Sci[n].GetFirstVisibleLine() + Sci[n].LinesOnScreen()
        If (Line > LastVisibleLine) {
            Sci[n].GoToPos(StartPos)
            Sci[n].VerticalCentreCaret()
        }
    }

    Sci[n].SetYCaretPolicy(CARET_SLOP|CARET_STRICT|CARET_EVEN, 5)
    Sci[n].SetSel(StartPos, EndPos)
    Sci[n].SetYCaretPolicy(CARET_EVEN, 0)
}

GetPreviousTab() {
    Local f, c, i, lat

    f := False
    c := 0
    i := 1

    Loop % Sci.Length() {
        lat := Sci[A_Index].LastAccessTime

        If (f) {
            If (lat >= c) {
                c := lat
                i := A_Index
            }
        } Else {
            c := lat
            f := True
        }
    }

    Return i
}

SetLexer(ItemName) {
    Lexers := {"AutoHotkey": 200, "Plain Text": 0}
    n := TabEx.GetSel()
    Sci[n].SetLexer(Lexers[ItemName])

    If (ItemName == "Plain Text") {
        DisableSyntaxHighlighting(n)        
    } Else {
        Sci_Config(n, SCLEX_AHKL)
    }
}
