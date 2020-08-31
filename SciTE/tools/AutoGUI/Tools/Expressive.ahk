; Expressive - Regular Expression Tool

#NoEnv
#SingleInstance Off
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetControlDelay -1
SetBatchLines -1

#Include %A_ScriptDir%\..\Lib\Scintilla.ahk
#Include %A_ScriptDir%\..\Lib\ControlColor.ahk

Global Version := "1.3.1"
, SciLexer := A_ScriptDir . (A_PtrSize == 8 ? "\..\SciLexer64.dll" : "\..\SciLexer32.dll")
, hMatchCount
, Groups := False
, Replace := False
, IconLib := A_ScriptDir . "\..\Icons\Expressive.icl"
, TT := {}
, SCLEX_CONTAINER := 0

Menu Tray, Icon, %IconLib%, 1

Gui New, hWndhWindow -DPIScale

; "Regular Expression" section
Gui Font, s9 Bold, Segoe UI
Gui Add, Text, hWndhRegExHdr x10 y12 w710 h29 +0x200 +E0x200, %A_Space%Regular Expression
Gui Font
Gui Add, Picture, hWndhHelpIcon gShowHelp x697 y18 w16 h16 Icon4 BackgroundTrans, %IconLib%
Gui Font, s13, Lucida Console
Gui Add, Edit, vRegEx gSearch x10 y44 w709 h25 -VScroll
Gui Font

; Options
Gui Font, s8, MS Shell Dlg 2
If (A_ScreenDPI > 96) {
    Gui Add, CheckBox, vIgnoreCase gSetOption x12 y72 w90 h23, Ignore case
    Gui Add, CheckBox, vMultiline gSetOption xp+100 y72 w80 h23, Multiline
    Gui Add, CheckBox, vDOTALL gSetOption xp+90 y72 w80 h23, DOTALL
    Gui Add, CheckBox, vHighlightAll gSearch x580 y72 w140 h23 Checked, Highlight all matches
} Else {
    Gui Add, CheckBox, vIgnoreCase gSetOption x12 y72 w80 h23, Ignore case
    Gui Add, CheckBox, vMultiline gSetOption x100 y72 w60 h23, Multiline
    Gui Add, CheckBox, vDOTALL gSetOption x178 y72 w60 h23, DOTALL
    Gui Add, CheckBox, vHighlightAll gSearch x600 y72 w120 h23 Checked, Highlight all matches
}

; "Text" section
Gui Font, s9 Bold, Segoe UI
Gui Add, Text, hWndhTextHdr x10 y98 w710 h29 +0x200 +E0x200, %A_Space%Text
Gui Add, Text, hWndhMatchCount x612 y104 w100 h20 Right
Gui Font
Global Sci := New Scintilla
Sci.Add(hWindow, 10, 130, 710, 232, SciLexer)
Sci.SetLexer(SCLEX_CONTAINER)
Sci.SetCodePage(65001)
Sci.SetWrapMode(1)
Sci.SetMarginWidthN(0, 0)
Sci.SetMarginWidthN(1, 0)
Sci.StyleSetFont(SCE_AHKL_NEUTRAL, "Lucida Console", 1)
Sci.StyleSetSize(SCE_AHKL_NEUTRAL, 10)
Sci.SetSelFore(1, CvtClr(0xFFFFFF))
Sci.SetSelBack(1, CvtClr(0x3399FF))
Sci.StyleSetBack(SCE_AHKL_USERDEFINED1, CvtClr(0xABDFEE))
Sci.StyleSetFont(SCE_AHKL_USERDEFINED1, "Lucida Console", 1)
Sci.StyleSetSize(SCE_AHKL_USERDEFINED1, 10)
;Sci.SetText("", "", 1)
Sci.Notify := "OnNotify"

; "Groups" section
Gui Font, Bold, Segoe UI
Gui Add, Text, hWndhGroupsHdr gShowGroups x10 y368 w710 h29 +0x200 +E0x200, %A_Space%Groups
Gui Font
Gui Add, Picture, hWndhGroupsChevron x697 y374 w16 h16 Icon2 BackgroundTrans, %IconLib%
Global SciGroups := CreateScintilla(hWindow, 10, 282, 710, 115, SciLexer, "0x40010000")
SciGroups.SetReadOnly(True)

; "Replace" section
Gui Font, Bold, Segoe UI
Gui Add, Text, hWndhReplaceHdr gShowReplace x10 y403 w710 h29 +0x200 +E0x200, %A_Space%Replace
Gui Font
Gui Add, Picture, hWndhReplaceChevron x697 y409 w16 h16 Icon2 BackgroundTrans, %IconLib%
Gui Font, s13, Lucida Console
Gui Add, Edit, hWndhReplaceField vReplacement gReplace x10 y267 w709 h25 -VScroll Hidden
Gui Font
Global SciReplace := CreateScintilla(hWindow, 10, 297, 710, 100, SciLexer, "0x40010000")

Gui Add, Picture, hWndhCollapseChevron x-16 y0 w16 h16 Icon3 BackgroundTrans, %IconLib%

ControlColor(hRegExHdr,   hWindow, 0x336699, 0xFFFFFF)
ControlColor(hTextHdr,    hWindow, 0x336699, 0xFFFFFF)
ControlColor(hMatchCount, hWindow, 0x336699, 0xFFFFFF)
ControlColor(hGroupsHdr,  hWindow, 0xC0C0C0, 0xFFFFFF)
ControlColor(hReplaceHdr, hWindow, 0xC0C0C0, 0xFFFFFF)

Gui Show, w730 h441, Expressive - Regular Expression Tool

hSysMenu := DllCall("GetSystemMenu", "UInt", hWindow, "Int", False, "Ptr")
DllCall("AppendMenu", "UInt", hSysMenu, "UInt", 0x800, "UInt", 0, "Str", "")
DllCall("AppendMenu", "UInt", hSysMenu, "UInt", 1, "UInt", 0, "Str", "Version " . Version)

OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x200, "OnWM_MOUSEMOVE")

TT.IgnoreCase := "Case-insensitive matching. Letters match`ntheir lowercase/uppercase counterparts."
TT.Multiline  := "Beginning and end metacharacters (^ and $)`nmatch the beginning or the end of each line."
TT.DOTALL     := "Makes the ""."" (dot) metacharacter`nmatch anything including line breaks."

Return ; End of the auto-execute section

Search:
    Gui Submit, NoHide

    ; Clear old matches
    Sci.StartStyling(0, 0x1F)
    Sci.SetStyling(Sci.GetLength() + 1, SCE_AHKL_NEUTRAL)

    If (RegExMatch(RegEx, "^([\w``]*)i([\w``]*)\)")) {
        If (!IgnoreCase) {
            GuiControl,, IgnoreCase, 1
        }
    } Else If (IgnoreCase) {
        GuiControl,, IgnoreCase, 0
    }

    If (RegExMatch(RegEx, "^([\w``]*)m([\w``]*)\)")) {
        If (!Multiline) {
            GuiControl,, Multiline, 1
        }
    } Else If (Multiline) {
        GuiControl,, Multiline, 0
    }

    If (RegExMatch(RegEx, "^([\w``]*)s([\w``]*)\)")) {
        If (!DOTALL) {
            GuiControl,, DOTALL, 1
        }
    } Else If (DOTALL) {
        GuiControl,, DOTALL, 0
    }

    If (RegEx == "") {
        GuiControl,, %hMatchCount%, No Match

        SciGroups.SetReadOnly(False)
        SciGroups.ClearAll()
        SciGroups.SetReadOnly(True)

        GoSub Replace
        Return
    }

    SciText := SciGetText()

    StartPos := 1
    Loop {
        FoundPos := RegExMatch(SciText, RegEx, Match, StartPos)
        If (Match == "") {
            HighlightAll := False
            Break
        }

        StartPos := FoundPos + 1

        Length := StrPut(SubStr(SciText, FoundPos, StrLen(Match)), "UTF-8") - 1
        FoundPos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1
        Highlight(FoundPos, Length)
    } Until (!HighlightAll)

    UpdateCounter(SciText, RegEx)

    If (Groups) {
        GoSub UpdateGroups
    }

    If (Replace) {
        GoSub Replace
    }
Return

Highlight(Pos, Length) {
    Sci.StartStyling(Pos, 0x1F)
    Sci.SetStyling(Length, SCE_AHKL_USERDEFINED1)
}

UpdateCounter(Text, RegEx) {
    If (RegExMatch("", RegEx)) {
        Count := -1 ; ERROR: The expression can match nothing and all at the same time.
    } Else {
        RegExReplace(Text, RegEx,, Count)
    }
    
    If (Count == 0) {
        CountMsg := "No Match"
    } Else If (Count == 1) {
        CountMsg := "1 Match"
    } Else If (Count > 1) {
        CountMsg := Count . " Matches"
    } Else If (Count == -1) {
        CountMsg := "..."
    }

    GuiControl,, %hMatchCount%, %CountMsg%
}

SetOption:
    Gui Submit, NoHide

    If (A_GuiControl == "IgnoreCase") {
        Option := "i"
    } Else If (A_GuiControl == "Multiline") {
        Option := "m"
    } Else If (A_GuiControl == "DOTALL") {
        Option := "s"
    }

    If (RegExMatch(RegEx, "^([\w``]*)" . Option . "([\w``]*)\)")) {
        NewStr := RegExReplace(RegEx, "^([\w``]*)" . Option . "([\w``]*)\)", "$1$2)")
        If (SubStr(NewStr, 1, 1) == ")") {
            NewStr := SubStr(NewStr, 2)
        }
    } Else {
        If (!RegExMatch(RegEx, "^[\w``]+\)")) {
            Option .= ")"
        }
        NewStr := Option . RegEx
    }

    GuiControl,, RegEx, %NewStr%
Return

ShowHelp:
    HelpFile := A_ScriptDir . "\..\Help\AutoHotkey.chm"
    Run HH mk:@MSITStore:%HelpFile%::/docs/misc/RegEx-QuickRef.htm
Return

ShowGroups:
    If (!Groups) {
        ControlMove,,,,, 115, % "ahk_id " . Sci.hWnd
        GuiControl Move, %hGroupsHdr%, y250
        GuiControl Move, %hCollapseChevron%, x697 y256
        Control Show,,, % "ahk_id " . SciGroups.hWnd
        ControlColor(hGroupsHdr, hWindow, 0x336699, 0xFFFFFF)
        Groups := True

        GuiControl Move, %hReplaceHdr%, y403
        Control Hide,,, % "ahk_id " . hReplaceField
        Control Hide,,, % "ahk_id " . SciReplace.hWnd
        ControlColor(hReplaceHdr, hWindow, 0xC0C0C0, 0xFFFFFF)
        Replace := False

        GoSub UpdateGroups
    } Else {
        ControlMove,,,,, 232, % "ahk_id " . Sci.hWnd
        GuiControl Move, %hGroupsHdr%, y368
        GuiControl Move, %hCollapseChevron%, x-16
        Control Hide,,, % "ahk_id " . SciGroups.hWnd
        ControlColor(hGroupsHdr, hWindow, 0xC0C0C0, 0xFFFFFF)
        Groups := False
    }

    WinSet Redraw,, ahk_id%hWindow%
Return

UpdateGroups:
    Gui Submit, NoHide

    If (RegEx == "") {
        Return
    }

    SciText := SciGetText()

    RegEx := RegExReplace(RegEx, "^(\w*)\)", "O$1)", Count)
    If (!Count) {
        RegEx := "O)" . RegEx
    }

    RegExMatch(SciText, RegEx, o)
    GrpCount := o.Count()

    Output := ""
    Loop % GrpCount {
        n := (o.Name(A_Index) != "") ? o.Name(A_Index) : A_Index
        Value := (o.Value(A_Index) != "") ? o.Value(A_Index) : "None"
        Output .= n . ": " . Value . "`n"
    }

    SciGroups.SetReadOnly(False)
    If (GrpCount) {
        SciGroups.SetText("", Output, 1)
    } Else {
        SciGroups.ClearAll()
    }
    SciGroups.SetReadOnly(True)
Return

ShowReplace:
    If (!Replace) {
        ControlMove,,,,, 100, % "ahk_id " . Sci.hWnd
        GuiControl Move, %hReplaceHdr%, y235
        GuiControl Move, %hCollapseChevron%, x697 y241
        Control Show,,, % "ahk_id " . hReplaceField
        Control Show,,, % "ahk_id " . SciReplace.hWnd
        ControlColor(hReplaceHdr, hWindow, 0x336699, 0xFFFFFF)
        Replace := True

        Control Hide,,, % "ahk_id " . SciGroups.hWnd
        GuiControl Move, %hGroupsHdr%, y403
        ControlColor(hGroupsHdr, hWindow, 0xC0C0C0, 0xFFFFFF)
        Groups := False

        GoSub Replace

        ControlFocus,, ahk_id%hReplaceField%
    } Else {
        ControlMove,,,,, 232, % "ahk_id " . Sci.hWnd
        GuiControl Move, %hReplaceHdr%, y403
        GuiControl Move, %hCollapseChevron%, x-16
        Control Hide,,, % "ahk_id " . hReplaceField
        Control Hide,,, % "ahk_id " . SciReplace.hWnd
        ControlColor(hReplaceHdr, hWindow, 0xC0C0C0, 0xFFFFFF)
        Replace := False

        GuiControl Move, %hGroupsHdr%, y368
    }

    WinSet Redraw,, ahk_id%hWindow%
Return

Replace:
    Gui Submit, NoHide
    SciText := SciGetText()
    NewStr := RegExReplace(SciText, RegEx, Replacement)
    SciReplace.SetText("", NewStr, 1)
Return

CreateScintilla(hParent, x, y, w, h, SciLexer, Style := "0x50010000", ExStyle := 0x200) {
    Scintilla := New Scintilla
    Scintilla.Add(hParent, x, y, w, h, SciLexer, Style, ExStyle)
    Scintilla.SetLexer(SCLEX_CONTAINER)
    Scintilla.SetCodePage(65001)
    Scintilla.SetMarginWidthN(0, 0)
    Scintilla.SetMarginWidthN(1, 0)
    Scintilla.SetWrapMode(1)
    Scintilla.StyleSetFont(SCE_AHKL_NEUTRAL, "Lucida Console", 1)
    Scintilla.StyleSetSize(SCE_AHKL_NEUTRAL, 10)
    Scintilla.SetSelFore(1, CvtClr(0xFFFFFF))
    Scintilla.SetSelBack(1, CvtClr(0x3399FF))
    Return Scintilla
}

OnNotify(wParam, lParam, msg, hWnd, obj) {
    If (obj.SCNCode == SCN_MODIFIED && obj.modType != 20) {
        GoSub Search
    }
}

GuiEscape:
GuiClose:
    ExitApp

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    Global

    If (wParam == 113) { ; F2
        GoSub ShowGroups
    } Else if (wParam == 114) { ; F3
        GoSub ShowReplace
    } Else If (wParam == 116) { ; F5
        GuiControlGet RegEx,, Edit1

        If (Replace) {
            GuiControlGet ReplaceRegEx,, %hReplaceField%
            Clipboard := "NewStr := RegExReplace(Haystack, """ . RegEx . """, """ . ReplaceRegEx . """)"
        } Else {
            Clipboard := "FoundPos := RegExMatch(Haystack, """ . RegEx . """, OutputVar)"
        }
    }
}

OnWM_MOUSEMOVE(wParam, lParam, msg, hWnd) {
    Static CurrControl, PrevControl := ""
    CurrControl := A_GuiControl

    If (CurrControl != PrevControl && !InStr(CurrControl, " ")) {
        ToolTip ; Turn off any previous tooltip.
        SetTimer DisplayToolTip, 600
        PrevControl := CurrControl
    }
    Return

    DisplayToolTip:
        SetTimer DisplayToolTip, Off
        ToolTip % TT[CurrControl]
        SetTimer RemoveToolTip, 4500
    return

    RemoveToolTip:
        SetTimer RemoveToolTip, Off
        ToolTip
    Return
}

CvtClr(Color) {
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >>16)
}

SciGetText() {
    nLen := Sci.GetLength() + 1
    VarSetCapacity(SciText, nLen, 0)
    Sci.GetText(nLen, &SciText)
    Return StrGet(&SciText, "UTF-8")
}

GetErrorMessage(ErrorCode, LanguageId := 0) {
    VarSetCapacity(ErrorMsg, 8192)
    DllCall("Kernel32.dll\FormatMessage"
        , "UInt", 0x1200 ; FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "UInt", 0
        , "UInt", ErrorCode + 0
        , "UInt", LanguageId
        , "Str" , ErrorMsg
        , "UInt", 8192)
    Return StrGet(&ErrorMsg)
}
