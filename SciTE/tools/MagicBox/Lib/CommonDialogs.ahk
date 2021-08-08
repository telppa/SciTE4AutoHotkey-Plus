ChooseFont(ByRef FontName, ByRef Size, ByRef Style, ByRef Color, Flags := 0x141, hOwner := 0) {
    ; FontName: Typeface name (input/output).
    ; Size: Font size (input/output).
    ; Style: Font options: bold, italic, underline, strikeout (input/output).
    ; Color: Font color in hexadecimal format (input/output)
    ; Flags: Default value: CF_SCREENFONTS (1) | CF_INITTOLOGFONTSTRUCT (0x40) | CF_EFFECTS (0x100).
    ; hOwner: A handle to the window that owns the dialog box. Affects position.
    ; Return value: Nonzero if the user clicks the OK button.

    Local lfHeight, x64 := A_PtrSize == 8

    VarSetCapacity(LOGFONT, (A_IsUnicode) ? 92 : 60, 0)
    StrPut(FontName, &LOGFONT + 28, 32) ; Initial name

    lfHeight := (Size) ? -DllCall("MulDiv", "Int", Size, "Int", A_ScreenDPI, "Int", 72) : 12 ; Initial size
    NumPut(lfHeight, LOGFONT, 0, "Int")
    
    ; Initial style
    If (InStr(Style, "bold")) {
        NumPut(700, LOGFONT, 16, "UInt")
    }
    If (InStr(Style, "italic")) {
        NumPut(1, LOGFONT, 20, "Char")
    }
    If (InStr(Style, "underline")) {
        NumPut(1, LOGFONT, 21, "Char")
    }
    If (InStr(Style, "strikeout")) {
        NumPut(1, LOGFONT, 22, "Char")
    }

    Color := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF) ; RGB -> BGR

    NumPut(VarSetCapacity(CHOOSEFONT, x64 ? 104 : 60, 0), CHOOSEFONT, 0, "UInt")
    NumPut(hOwner,   CHOOSEFONT, A_PtrSize, "Ptr")      ; hwndOwner
    NumPut(&LOGFONT, CHOOSEFONT, x64 ? 24 : 12, "Ptr")  ; lpLogFont
    NumPut(Flags,    CHOOSEFONT, x64 ? 36 : 20, "UInt") ; Flags
    NumPut(Color,    CHOOSEFONT, x64 ? 40 : 24, "UInt") ; rgbColors

    If !(DllCall("comdlg32.dll\ChooseFont" . (A_IsUnicode ? "W" : "A"), "Ptr", &CHOOSEFONT)) {
        Return False
    }

    FontName := StrGet(&LOGFONT + 28, 32)

    Size := DllCall("MulDiv", "Int", Abs(NumGet(LOGFONT, 0, "Int")), "Int", 72, "Int", A_ScreenDPI)

    Style := ""
    If (NumGet(LOGFONT, 16, "Int") >= 700) {
        Style .= "bold "
    }
    If (NumGet(LOGFONT, 20, "UChar")) {
        Style .= "italic "
    }
    If (NumGet(LOGFONT, 21, "UChar")) {
        Style .= "underline "
    }
    If (NumGet(LOGFONT, 22, "UChar")) {
        Style .= "strikeout "
    }

    Color := NumGet(CHOOSEFONT, x64 ? 40 : 24, "UInt")
    Color := (Color & 0xFF00) + ((Color & 0xFF0000) >> 16) + ((Color & 0xFF) << 16) ; BGR -> RGB
    Color := Format("0x{:06X}", Color)

    Return True
}

ChooseColor(ByRef Color, hOwner := 0) {
    ; Color: specifies the color initially selected when the dialog box is created.
    ; hOwner: Optional handle to the window that owns the dialog. Affects dialog position.
    ; Return value: Nonzero if the user clicks the OK button.

    rgbResult := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)

    VarSetCapacity(CUSTOM, 64, 0)
    NumPut(VarSetCapacity(CHOOSECOLOR, A_PtrSize * 9, 0), CHOOSECOLOR, 0)
    NumPut(hOwner,      CHOOSECOLOR, A_PtrSize)    ; hwndOwner
    NumPut(rgbResult, CHOOSECOLOR, A_PtrSize * 3)  ; rgbResult
    NumPut(&CUSTOM, CHOOSECOLOR, A_PtrSize * 4)    ; COLORREF *lpCustColors
    NumPut(0x103, CHOOSECOLOR, A_PtrSize * 5)      ; Flags: CC_ANYCOLOR | CC_RGBINIT | CC_FULLOPEN

    RetVal := DllCall("comdlg32\ChooseColor", "Ptr", &CHOOSECOLOR)
    If (ErrorLevel != 0 || RetVal == 0) {
        Return False
    }

    rgbResult := NumGet(CHOOSECOLOR, A_PtrSize * 3)
    Color := (rgbResult & 0xFF00) + ((rgbResult & 0xFF0000) >> 16) + ((rgbResult & 0xFF) << 16)
    Color := Format("0x{:06X}", Color)
    Return True
}

ChooseIcon(ByRef Icon, ByRef Index, hOwner := 0) {
    ; Icon: Icon resource (input/output).
    ; Index: Icon index (input/output).
    ; hOwner: Optional handle to the window that owns the dialog. Affects dialog position.
    ; Return value: Nonzero if the user clicks the OK button.

    VarSetCapacity(wIcon, 1025, 0)
    If (Icon && !StrPut(Icon, &wIcon, StrLen(Icon) + 1, "UTF-16")) {
        Return False
    }

    Index--
    If (DllCall("Shell32.dll\PickIconDlg", "Ptr", hOwner, "Ptr", &wIcon, "UInt", 1025, "Int*", Index)) {
        Index++

        If (A_IsUnicode) {
            VarSetCapacity(wIcon, -1)
            Icon := wIcon
        } Else {
            If (!Icon := StrGet(&wIcon, DllCall("lstrlenW", "UInt", &wIcon) + 1, "UTF-16")) {
                Return False
            }
        }

        Return True
    }
    Return False
}
