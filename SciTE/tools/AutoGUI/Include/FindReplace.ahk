ShowFindDialog:
ShowReplaceDialog:
    If (WinExist("ahk_id " . hFindReplaceDlg)) {
        Gui FindReplaceDlg: Show

        GuiControlGet FindReplaceTab,, %hFindReplaceTab%
        If (FindReplaceTab != 1 && A_ThisLabel == "ShowFindDialog") {
            GuiControl Choose, %hFindReplaceTab%, 1
            GoSub FindReplaceTabHandler
        }

        DllCall("SetFocus", "Ptr", hCbxFind%FindReplaceTab%)
    } Else {
        WhatItems := ""
        WithItems := ""
        IniRead FindHistory, %IniFile%, FindHistory
        If (FindHistory != "ERROR") {
            Loop Parse, FindHistory, `n
            {
                Item := StrSplit(A_LoopField, "=")
                If (InStr(Item[1], "What")) {
                    WhatItems .= Item[2] . "`n"
                } Else If (InStr(Item[1], "With")) {
                    WithItems .= Item[2] . "`n"
                }
            }
        }

        IniRead g_ChkMatchCase, %IniFile%, Find, MatchCase, 0
        IniRead g_ChkWholeWord, %IniFile%, Find, WholeWord, 0
        IniRead g_ChkRegExFind, %IniFile%, Find, RegExFind, 0
        IniRead g_ChkBackslash, %IniFile%, Find, Backslash, 0
        IniRead g_RadStartingPos, %IniFile%, Find, FromStart, 0
        IniRead g_ChkWrapAround, %IniFile%, Find, WrapAround, 0

        Gui FindReplaceDlg: New, LabelFindReplaceDlg hWndhFindReplaceDlg -MinimizeBox OwnerAuto Delimiter`n
        Gui Font, s9, Segoe UI

        Gui Add, Tab3
        , hWndhFindReplaceTab vFindReplaceTab gFindReplaceTabHandler x8 y8 w466 h182 AltSubmit %g_ThemeFix%
        , Find`nReplace

        Gui Tab, 1
            Gui Add, Text, x31 y45 w42 h23 +0x200, What:
            Gui Add, ComboBox, hWndhCbxFind1 vSearchString gSearchFieldHandler x84 y46 w272, %WhatItems%
            GuiControl Choose, %hCbxFind1%, 1

            Gui Add, Button, hWndhBtnFindNext1 gFindNext x371 y45 w88 h25 Default, Find &Next
            Gui Add, Button, gFindPrev x371 y79 w88 h25, Find &Previous
            Gui Add, Button, gMarkAll x371 y113 w88 h25, Mark &All
            Gui Add, Button, gFindReplaceDlgClose x371 y148 w88 h25, Cancel

            Gui Add, CheckBox, vg_ChkMatchCase gSyncSearchOptions x24 y81 w160 h23 Checked%g_ChkMatchCase%
            , &Case sensitive
            Gui Add, CheckBox, vg_ChkWholeWord gSyncSearchOptions x24 y105 w160 h23 Checked%g_ChkWholeWord%
            , &Match whole word only
            Gui Add, CheckBox, vg_ChkRegExFind gSyncSearchOptions x24 y129 w160 h23 Checked%g_ChkRegExFind%
            , &Regular expression
            Gui Add, CheckBox, vg_ChkBackslash gSyncSearchOptions x24 y153 w160 h23 Checked%g_ChkBackslash%
            , &Backslashed characters

            Gui Add, GroupBox, x196 y75 w160 h99, &Origin
            Gui Add, Radio, vg_RadCurrentPos gSetSearchOrigin x209 y94 w135 h23, Current position
            Gui Add, Radio, vg_RadStartingPos gSetSearchOrigin x209 y118 w135 h23, Starting position
            GuiControl,, % g_RadStartingPos ? "g_RadStartingPos" : "g_RadCurrentPos", 1
            Gui Add, CheckBox, vg_ChkWrapAround gSyncSearchOptions x209 y142 w135 h23 Checked%g_ChkWrapAround%
            , &Wrap around

        Gui Tab, 2
            Gui Add, Text, x31 y45 w42 h23 +0x200, What:
            Gui Add, ComboBox, hWndhCbxFind2 vReplaceWhat gSearchFieldHandler x84 y46 w272, %WhatItems%
            GuiControl Choose, %hCbxFind2%, 1
            Gui Add, Text, x31 y75 w42 h23 +0x200, With:
            Gui Add, ComboBox, hWndhCbxReplace vReplaceWith x84 y76 w272, %WithItems%
            GuiControl Choose, %hCbxReplace%, 1

            Gui Add, Button, hWndhBtnFindNext2 gFindNext x371 y45 w88 h25, Find &Next
            Gui Add, Button, gFindPrev x371 y79 w88 h25, Find &Previous
            Gui Add, Button, gReplace x371 y113 w88 h25, &Replace
            Gui Add, Button, gReplaceAll x371 y148 w88 h25, Replace &All
            Gui Add, Button, gFindReplaceDlgClose x371 y182 w88 h25, &Cancel

            Gui Add, CheckBox, vChkMatchCase gSyncSearchOptions x24 y111 w160 h23, &Case sensitive
            Gui Add, CheckBox, vChkWholeWord gSyncSearchOptions x24 y135 w160 h23, &Match whole word only
            Gui Add, CheckBox, vChkRegExFind gSyncSearchOptions x24 y159 w160 h23, &Regular expression
            Gui Add, CheckBox, vChkBackslash gSyncSearchOptions x24 y183 w160 h23, &Backslashed characters

            Gui Add, GroupBox, x196 y105 w160 h99, &Origin
            Gui Add, Radio, vRadCurrentPos gSetSearchOrigin x209 y124 w135 h23, Current position
            Gui Add, Radio, vRadStartingPos gSetSearchOrigin x209 y148 w135 h23, Starting position
            Gui Add, CheckBox, vChkWrapAround gSyncSearchOptions x209 y172 w135 h23, &Wrap around

        IniRead px, %IniFile%, Find, x, Center
        IniRead py, %IniFile%, Find, y, Center

        SetWindowIcon(hFindReplaceDlg, IconLib, 21)
        Gui FindReplaceDlg: Show, x%px% y%py% w481 h198, Find

        NOTFOUND := -1
    }

    SearchOrigin := -1 ; SearchFromCurrentPos
    NotFoundMsgType := 1

    GoSub SyncSearchOptions

    If (A_ThisLabel == "ShowReplaceDialog") {
        GuiControl Choose, %hFindReplaceTab%, 2
        GoSub FindReplaceTabHandler
    }

    If ((SelText := GetSelectedText()) != "") {
        GuiControl Text, % (A_ThisLabel == "ShowFindDialog") ? hCbxFind1 : hCbxFind2, %SelText%
    }

    Send +{End}
Return

FindReplaceDlgEscape:
FindReplaceDlgClose:
    Gui FindReplaceDlg: Hide
Return

FindReplaceTabHandler:
    Gui FindReplaceDlg: Submit, NoHide

    If (FindReplaceTab == 2) {
        GuiControl Move, %hFindReplaceTab%, h214
        WinMove ahk_id %hFindReplaceDlg%,,,,, % DPIScale(257)
        WinSetTitle ahk_id %hFindReplaceDlg%,, Replace
        SetWindowIcon(hFindReplaceDlg, IconLib, 22)
        GuiControl Text, %hCbxFind2%, %SearchString%
        WinSet Redraw,, ahk_id %hCbxFind2%
        GuiControl +Default, %hBtnFindNext2%
    } Else If (FindReplaceTab == 1) {
        GuiControl Move, %hFindReplaceTab%, h182
        WinMove ahk_id %hFindReplaceDlg%,,,,, % DPIScale(226)
        WinSetTitle ahk_id %hFindReplaceDlg%,, Find
        SetWindowIcon(hFindReplaceDlg, IconLib, 21)
        GuiControl Text, %hCbxFind1%, %ReplaceWhat%
        WinSet Redraw,, ahk_id %hCbxFind1%
        GuiControl +Default, %hBtnFindNext1%
    }
Return

FindNext:
FindPrev:
Replace:
    Gui FindReplaceDlg: Submit, NoHide
    GuiControlGet SearchString,, % hCbxFind%FindReplaceTab%, Text

    n := TabEx.GetSel()

    SearchFlags := GetSearchFlags()

    If (SearchOrigin == -1 || (g_RadStartingPos && A_ThisLabel != PrevLabel)) {
        SearchOrigin := g_RadCurrentPos ; 1 = current position
    }

    OldSearchString := SearchString
    OldReplaceWith := ReplaceWith
    If (g_ChkBackslash) {
        ConvertBackslashes(SearchString)
        ConvertBackslashes(ReplaceWith)
    }

    Length := StrPut(SearchString, "UTF-8") - 1 ; Length of the search string in bytes

    If (A_ThisLabel == "FindNext") {
        If (g_ChkRegExFind) {
            SciText  := GetText(n)
            TempText := GetTextRange(n, [0, Sci[n].GetCurrentPos()])
            StartPos := SearchOrigin ? StrLen(TempText) + 1 : 1

            Pos := RegExMatch(SciText, SearchString, Match, StartPos)
            If (Pos > 0) {
                ;Length := StrPut(SubStr(SciText, Pos, StrLen(Match)), "UTF-8") - 1
                Length := StrPut(Match, "UTF-8") - 1
                FoundPos := StrPut(SubStr(SciText, 1, Pos - 1), "UTF-8") - 1
            } Else {
                FoundPos := NOTFOUND
            }

        } Else {
            Sci[n].SetSearchFlags(SearchFlags)
            Sci[n].SetTargetRange(SearchOrigin ? Sci[n].GetCurrentPos() : 0, Sci[n].GetLength())
            FoundPos := Sci[n].SearchInTarget(Length, "" . SearchString, 1)
        }

        If (FoundPos != NOTFOUND) {
            SetSelEx(n, FoundPos, FoundPos + Length)
            NotFoundMsgType := 2
        }

    } Else If (A_ThisLabel == "FindPrev") {
        If (g_ChkRegExFind) {
            SciText := GetText(n)

            If (SearchOrigin) {
                TempText := GetTextRange(n, [0, Sci[n].GetAnchor()])
                LimitPos := StrLen(TempText)
            } Else {
                LimitPos := StrLen(SciText)
            }

            StartPos := 1
            FoundPos := 0
            Loop {
                StartPos := RegExMatch(SciText, SearchString, Match, StartPos)
                If ((StartPos > 0) && StartPos <= LimitPos) {
                    FoundPos := StartPos
                    Length := StrLen(Match)
                    StartPos++
                    Continue
                }
                Break
            }

            FoundPos--
            If (FoundPos != NOTFOUND) {
                Length := StrPut(SubStr(SciText, FoundPos + 1, Length), "UTF-8") - 1
                FoundPos := StrPut(SubStr(SciText, 1, FoundPos), "UTF-8") - 1

                SetSelEx(n, FoundPos, FoundPos + Length, 1)
            }

        } Else {
            Sci[n].SetSearchFlags(SearchFlags)
            Sci[n].SetTargetRange(SearchOrigin ? Sci[n].GetAnchor() : Sci[n].GetLength(), 0)
            FoundPos := Sci[n].SearchInTarget(Length, "" . SearchString, 1)

            If (FoundPos != NOTFOUND) {
                SetSelEx(n, FoundPos, FoundPos + Length)
            }
        }

    } Else { ; Replace
        ; Find without selecting.
        If (g_ChkRegExFind) {
            SciText := GetText(n)
            TempText := GetTextRange(n, [0, Sci[n].GetAnchor()])
            FoundPos := RegExMatch(SciText, SearchString, Match, StrLen(TempText) + 1)
            If (FoundPos > 0) {
                Length := StrPut(SubStr(SciText, FoundPos, StrLen(Match)), "UTF-8") - 1
                FoundPos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1
                ReplaceWith := RegExReplace(Match, SearchString, ReplaceWith)
            } Else {
                FoundPos := NOTFOUND
            }
        } Else {
            Sci[n].SetSearchFlags(SearchFlags)
            Sci[n].SetTargetRange(Sci[n].GetAnchor(), Sci[n].GetLength())
            FoundPos := Sci[n].SearchInTarget(Length, s := SearchString, 2)
        }

        ; Replace only occurs if the match is selected.
        If (FoundPos != NOTFOUND) {
            If (Sci[n].GetSelText(0, 0) > 1) {
                SelStart := Sci[n].GetSelectionStart()
                SelEnd := Sci[n].GetSelectionEnd()

                If (SelStart == FoundPos && (FoundPos + Length) == SelEnd) {
                    Sci[n].ReplaceSel(SearchFlags, ReplaceWith, 1)
                }
            }

            NotFoundMsgType := 2
        }

        GoSub FindNext ; Find and select.
    }

    ; Wrap around
    If (FoundPos == NOTFOUND && g_ChkWrapAround && SearchOrigin) {
        FR_ShowBalloon(A_ThisLabel == "FindNext"
        ? "End of the document reached. Continuing from start."
        : "Start of the document reached. Continuing from end.")
        SearchOrigin := 0
        GoTo %A_ThisLabel%
    }

    If (FoundPos == NOTFOUND && A_ThisLabel != "Replace") {
        FR_ShowBalloon((NotFoundMsgType == 1)
        ? "Search string not found: """ . SearchString . """."
        : "No further occurrence of """ . SearchString . """.")
    }

    If (FoundPos != NOTFOUND) {
        SearchOrigin := 1 ; Current position
        NotFoundMsgType := 2
    } Else {
        NotFoundMsgType := 1
    }

    AddToFindHistory(hCbxFind1, OldSearchString)
    AddToFindHistory(hCbxFind2, OldSearchString)
    If (A_ThisLabel == "Replace") {
        AddToFindHistory(hCbxReplace, OldReplaceWith)
    }

    PrevLabel := A_ThisLabel

    SciText := TempText := ""
Return

ReplaceAll:
    Gui FindReplaceDlg: Submit, NoHide
    GuiControlGet ReplaceWhat,, %hCbxFind2%, Text
    GuiControlGet ReplaceWith,, %hCbxReplace%, Text

    Count := ReplaceAll(ReplaceWhat, ReplaceWith, GetSearchFlags(), g_ChkRegExFind, g_ChkBackslash, g_RadStartingPos)
    If (Count >= 0) {
        FR_ShowBalloon(Count . " occurrence(s) replaced.")        
    }

    AddToFindHistory(hCbxFind2, ReplaceWhat)
    AddToFindHistory(hCbxReplace, ReplaceWith)
    AddToFindHistory(hCbxFind1, ReplaceWhat)
Return

ReplaceAll(ReplaceWhat, ReplaceWith := "", Flags := 0, RegEx := False, Backslash := False, FromStart := False) {
    n := TabEx.GetSel()
    Sci[n].BeginUndoAction()

    Count := 0

    If (Backslash) {
        ConvertBackslashes(ReplaceWhat)
        ConvertBackslashes(ReplaceWith)
    }

    If (RegEx) {
        If (FromStart) {
            StartPos := 1        
        } Else {
            TempText := GetTextRange(n, [0, Sci[n].GetCurrentPos()])
            StartPos := StrLen(TempText) + 1
        }

        Loop {
            SciText := GetText(n)
            FoundPos := RegExMatch(SciText, ReplaceWhat, Match, StartPos)
            If (!FoundPos) {
                Break
            }

            NewStr := RegExReplace(Match, ReplaceWhat, ReplaceWith)

            StartPos := FoundPos + StrLen(NewStr)
            If (StartPos > StrLen(SciText)) {
                Break
            }

            MatchLen := StrLen(Match)
            If (!MatchLen) {
                StartPos++
                Continue ; Zero-length match.
            }

            ByteLen := StrPut(Match, "UTF-8") - 1
            BytePos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1

            VarSetCapacity(String, StrPut(NewStr, "UTF-8") + 1)
            StrPut(NewStr, &String, "UTF-8")

            Sci[n].SetTargetRange(BytePos, BytePos + ByteLen)
            Sci[n].ReplaceTarget(StrPut(NewStr, "UTF-8") - 1, &String)

            Count++
        }

        SciText := TempText := ""

    } Else {
        WhatLength := StrPut(ReplaceWhat, "UTF-8") - 1
        WithLength := StrPut(ReplaceWith, "UTF-8") - 1

        Sci[n].SetSearchFlags(Flags)
        Sci[n].SetTargetRange(FromStart ? 0 : Sci[n].GetCurrentPos(), Sci[n].GetLength() + 1)

        While (Sci[n].SearchInTarget(WhatLength, "" . ReplaceWhat, 1) != -1) {
            Sci[n].ReplaceTarget(WithLength, r := ReplaceWith, 1)
            Sci[n].SetTargetRange(Sci[n].GetTargetStart() + WithLength, Sci[n].GetLength() + 1)
            Count++
        }
    }

    Sci[n].EndUndoAction()

    Return Count
}

MarkAll:
    Gui FindReplaceDlg: Submit, NoHide
    GuiControlGet SearchString,, %hCbxFind1%, Text
    n := TabEx.GetSel()

    OldSearchString := SearchString
    If (g_ChkBackslash) {
        ConvertBackslashes(SearchString)
    }

    ; SCI_SETINDICATORCURRENT(int indicator): Set the indicator that will be affected by calls to
    ; SCI_INDICATORFILLRANGE(int start, int lengthFill) and SCI_INDICATORCLEARRANGE(int start, int lengthClear).
    Sci[n].SetIndicatorCurrent(1)

    Sci[n].IndicSetStyle(1, INDIC_ROUNDBOX)
    Sci[n].IndicSetFore(1, CvtClr(0x3FBBE3))
    Sci[n].IndicSetOutlineAlpha(1, 255) ; Opaque border
    Sci[n].IndicSetAlpha(1, 80)

    If (!StringLength := StrPut(SearchString, "UTF-8") - 1) {
        Sci[n].IndicatorClearRange(0, Sci[n].GetLength())
        Return
    }

    Count := 0

    If (g_ChkRegExFind) {
        SciText := GetText(n)
        StartPos := 1
        While ((FoundPos := RegExMatch(SciText, SearchString, Match, StartPos)) > 0) {
            StartPos := FoundPos + 1
            If (StartPos > StrLen(SciText)) {
                Break
            }

            MatchLen := StrLen(Match)
            If (!MatchLen) {
                Continue ; Zero-length match.
            }

            ByteLen := StrPut(SubStr(SciText, FoundPos, MatchLen), "UTF-8") - 1
            BytePos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1
            Sci[n].IndicatorFillRange(BytePos, ByteLen)
            Count++
        }
    } Else {
        TextLength := Sci[n].GetLength()

        Sci[n].SetSearchFlags(GetSearchFlags())
        Sci[n].SetTargetRange(0, TextLength)

        Length := StrPut(SearchString, "UTF-8") - 1
        VarSetCapacity(StrBuf, Length)
        StrPut(SearchString, &StrBuf, "UTF-8")

        ;While (Sci[n].SearchInTarget(StringLength, "" . SearchString, 1) != -1) {
        While (Sci[n].SearchInTarget(StringLength, &StrBuf) != -1) {
            TargetStart := Sci[n].GetTargetStart()
            TargetEnd := Sci[n].GetTargetEnd()

            TargetLength := TargetEnd - TargetStart

            If (!TargetLength) {
                Sci[n].SetTargetRange(++TargetEnd, TextLength)
                Continue ; Zero-length match (Scintilla RegEx)
            }

            Sci[n].IndicatorFillRange(TargetStart, TargetLength)
            Count++

            Sci[n].SetTargetRange(TargetEnd, TextLength)
        }
    }

    If (Count) {
        GoToNextMark()
    }

    FR_ShowBalloon((Count ? Count : "No") . " " . ((Count > 1) ? "matches" : "match") . " found.")

    AddToFindHistory(hCbxFind1, OldSearchString)
Return

AddToFindHistory(hCbx, String) {
    ControlGet ComboItems, List,,, ahk_id %hCbx%
    History := String . "`n`n"

    Count := 0
    Loop Parse, ComboItems, `n
    {
        If (A_LoopField == String || A_LoopField == "") {
            Continue
        }

        History .= A_LoopField . "`n"

        Count++
        If (Count > 8) {
            Break
        }
    }

    GuiControl,, %hCbx%, `n%History%
}

GetSearchFlags() {
    Local SearchFlags := 0

    If (g_ChkMatchCase) {
        SearchFlags := 4
    }

    If (g_ChkWholeWord) {
        SearchFlags += 2
    }

    Return SearchFlags
}

; Convert some escape sequences
ConvertBackslashes(ByRef String) {
    n := TabEx.GetSel()
    IsCRLF := Sci[n].GetCharAt(Sci[n].GetLineEndPosition(0)) == 13

    StringReplace String, String, \\, ☺, All
    StringReplace String, String, \n, % IsCRLF ? "`r`n" : "`n", All
    ;StringReplace String, String, \r, `r, All
    StringReplace String, String, \t, %A_Tab%, All
    StringReplace String, String, ☺, \, All
}

SyncSearchOptions:
    Gui FindReplaceDlg: Submit, NoHide

    ; Set exclusive options
    If (A_GuiControl != "") {
        VarPrefix := (FindReplaceTab == 1) ? "g_" : ""
        If (InStr(A_GuiControl, "RegExFind")) {
            GuiControl,, % VarPrefix . "ChkMatchCase", 0
            GuiControl,, % VarPrefix . "ChkWholeWord", 0
            GuiControl,, % VarPrefix . "ChkBackslash", 0
        } Else If (A_GuiControl ~= "MatchCase|WholeWord|Backslash") {
            GuiControl,, % VarPrefix . "ChkRegExFind", 0
        }
    }

    Gui FindReplaceDlg: Submit, NoHide

    ; Synchronize options
    If (FindReplaceTab == 1) {
        GuiControl,, ChkMatchCase, %g_ChkMatchCase%
        GuiControl,, ChkWholeWord, %g_ChkWholeWord%
        GuiControl,, ChkRegExFind, %g_ChkRegExFind%
        GuiControl,, ChkBackslash, %g_ChkBackslash%
        GuiControl,, RadCurrentPos, %g_RadCurrentPos%
        GuiControl,, RadStartingPos, %g_RadStartingPos%
        GuiControl,, ChkWrapAround, %g_ChkWrapAround%
    } Else {
        GuiControl,, g_ChkMatchCase, %ChkMatchCase%
        GuiControl,, g_ChkWholeWord, %ChkWholeWord%
        GuiControl,, g_ChkRegExFind, %ChkRegExFind%
        GuiControl,, g_ChkBackslash, %ChkBackslash%
        GuiControl,, g_RadCurrentPos, %RadCurrentPos%
        GuiControl,, g_RadStartingPos, %RadStartingPos%
        GuiControl,, g_ChkWrapAround, %ChkWrapAround%
    }
Return

SetSearchOrigin:
    GoSub SyncSearchOptions

    Gui FindReplaceDlg: Submit, NoHide
    SearchOrigin := g_RadCurrentPos
Return

SearchFieldHandler:
    NotFoundMsgType := 1
    Gui FindReplaceDlg: Submit, NoHide
    SearchOrigin := g_RadCurrentPos
Return

FR_ShowBalloon(Text, Title := "", Icon := 0) {
    Global
    Gui FindReplaceDlg: Submit, NoHide

    If (IsWindowVisible(hFindReplaceDlg)) {
        hEdt := DllCall("GetWindow", "Ptr", hCbxFind%FindReplaceTab%, "UInt", 5, "Ptr") ; GW_CHILD
        Edit_ShowBalloonTip(hEdt, Text, Title, Icon)
    } Else {
        Gui Auto: +OwnDialogs
        MsgBox 0, % Title != "" ? Title : g_AppName, %Text%
    }
}

FindInFiles() {
    Run %A_ScriptDir%\Tools\Find in Files.ahk /AutoGUI
}
