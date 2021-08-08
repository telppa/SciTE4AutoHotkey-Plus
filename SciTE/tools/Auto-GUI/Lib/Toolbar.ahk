ToolbarCreate(Handler, Buttons, ImageList := "", Options := "Flat List ToolTips", Extra := "", Pos := "", Padding := "") {
    Static TOOLTIPS := 0x100, WRAPABLE := 0x200, FLAT := 0x800, LIST := 0x1000, TABSTOP := 0x10000, BORDER := 0x800000, TEXTONLY := 0
    Static BOTTOM := 0x3, ADJUSTABLE := 0x20, NODIVIDER := 0x40, VERTICAL := 0x80
    Static CHECKED := 1, HIDDEN := 8, WRAP := 32, DISABLED := 0 ; States
    Static CHECK := 2, CHECKGROUP := 6, DROPDOWN := 8, AUTOSIZE := 16, NOPREFIX := 32, SHOWTEXT := 64, WHOLEDROPDOWN := 128 ; Styles

    StrReplace(Options, "SHOWTEXT", "", fShowText, 1)
    fTextOnly := InStr(Options, "TEXTONLY")

    Styles := 0
    Loop Parse, Options, %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse toolbar styles
        IfEqual A_LoopField,, Continue
        Else Styles |= A_LoopField + 0 ? A_LoopField : %A_LoopField%

    If (Pos != "") {
        Styles |= 0x4C ; CCS_NORESIZE | CCS_NOPARENTALIGN | CCS_NODIVIDER
    }

    Gui Add, Custom, ClassToolbarWindow32 hWndhWnd g_ToolbarHandler -Tabstop %Pos% %Styles% %Extra%
    _ToolbarStorage(hWnd, Handler)

    TBBUTTON_Size := A_PtrSize == 8 ? 32 : 20
    Buttons := StrSplit(Buttons, "`n")
    cButtons := Buttons.Length()
    VarSetCapacity(TBBUTTONS, TBBUTTON_Size * cButtons , 0)

    Index := 0
    Loop %cButtons% {
        Button := StrSplit(Buttons[A_Index], ",", " `t")

        If (Button[1] == "-") {
            iBitmap := 0
            idCommand := 0
            fsState := 0
            fsStyle := 1 ; BTNS_SEP
            iString := -1
        } Else {
            Index++
            iBitmap := (fTextOnly) ? -1 : (Button[2] != "" ? Button[2] - 1 : Index - 1)
            idCommand := (Button[5]) ? Button[5] : 10000 + Index

            fsState := InStr(Button[3], "DISABLED") ? 0 : 4 ; TBSTATE_ENABLED
            Loop Parse, % Button[3], %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse button states
                IfEqual A_LoopField,, Continue
                Else fsState |= %A_LoopField%

            fsStyle := fTextOnly || fShowText ? SHOWTEXT : 0
            Loop Parse, % Button[4], %A_Tab%%A_Space%, %A_Tab%%A_Space% ; Parse button styles
                IfEqual A_LoopField,, Continue
                Else fsStyle |= %A_LoopField%

            iString := &(ButtonText%Index% := Button[1])
        }

        Offset := (A_Index - 1) * TBBUTTON_Size
        NumPut(iBitmap, TBBUTTONS, Offset, "Int")
        NumPut(idCommand, TBBUTTONS, Offset + 4, "Int")
        NumPut(fsState, TBBUTTONS, Offset + 8, "UChar")
        NumPut(fsStyle, TBBUTTONS, Offset + 9, "UChar")
        NumPut(iString, TBBUTTONS, Offset + (A_PtrSize == 8 ? 24 : 16), "Ptr")
    }

    If (Padding != "") {
        SendMessage 0x457, 0, %Padding%,, ahk_id %hWnd% ; TB_SETPADDING
    }

    SendMessage 0x454, 0, 0x9,, ahk_id %hWnd% ; TB_SETEXTENDEDSTYLE (mixed buttons, draw dropdown arrows)
    SendMessage 0x430, 0, %ImageList%,, ahk_id %hWnd% ; TB_SETIMAGELIST
    SendMessage % A_IsUnicode ? 0x444 : 0x414, %cButtons%, % &TBBUTTONS,, ahk_id %hWnd% ; TB_ADDBUTTONS

    If (InStr(Options, "VERTICAL")) {
        VarSetCapacity(SIZE, 8, 0)
        SendMessage 0x453, 0, &SIZE,, ahk_id %hWnd% ; TB_GETMAXSIZE
    } Else {
        SendMessage 0x421, 0, 0,, ahk_id %hWnd% ; TB_AUTOSIZE
    }

    Return hWnd
}

_ToolbarStorage(hWnd, Callback := "") {
    Static o := {}
    Return (o[hWnd] != "") ? o[hWnd] : o[hWnd] := Callback
}

_ToolbarHandler(hWnd) {
    Static n := {-2: "Click", -5: "RightClick", -20: "LDown", -713: "Hot", -710: "DropDown"}
    Local Handler, Code, ButtonId, Pos, Text, Event, RECT, Left, Bottom

    Handler := _ToolbarStorage(hWnd)

    Code := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")

    If (Code != -713) {
        ButtonId := NumGet(A_EventInfo + (3 * A_PtrSize))
    } Else {
        ButtonId := NumGet(A_EventInfo, A_PtrSize == 8 ? 28 : 16, "Int") ; NMTBHOTITEM idNew
    }

    SendMessage 0x419, ButtonId,,, ahk_id %hWnd% ; TB_COMMANDTOINDEX
    Pos := ErrorLevel + 1

    VarSetCapacity(Text, 128, 0)
    SendMessage % A_IsUnicode ? 0x44B : 0x42D, ButtonId, &Text,, ahk_id %hWnd% ; TB_GETBUTTONTEXT

    Event := (n[Code] != "") ? n[Code] : Code

    VarSetCapacity(RECT, 16, 0)
    SendMessage 0x433, ButtonId, &RECT,, ahk_id %hWnd% ; TB_GETRECT
    DllCall("MapWindowPoints", "Ptr", hWnd, "Ptr", 0, "Ptr", &RECT, "UInt", 2)
    Left := NumGet(RECT, 0, "Int")
    Bottom := NumGet(RECT, 12, "Int")

    %Handler%(hWnd, Event, Text, Pos, ButtonId, Left, Bottom)
}
