InputBoxEx(Instruction := "", Content := "", Title := "", Default := "", Control := "", Options := "", Owner := "", Width := "", Pos := "", Icon := "", IconIndex := 1, WindowOptions := "", Timeout := "") {
    Static hWnd, py, p1, p2, c, cy, ch, Input, e, ey, eh, f, ww, ExitCode

    Gui New, hWndhWnd LabelInputBoxEx -0xA0000
    Gui % (Owner) ? "+Owner" . Owner : ""
    Gui Font
    Gui Color, White
    Gui Margin, 10, 12
    py := 10
    Width := (Width) ? Width : 430

    If (Instruction != "") {
        Gui Font, s12 c0x003399, Segoe UI
        Gui Add, Text, vp1 y10, %Instruction%
        py := 40
    }

    Gui Font, s9 cDefault, Segoe UI

    If (Content != "") {
        Gui Add, Link, % "vp2 x10 y" . py . " w" . (Width - 20), %Content%
    }

    GuicontrolGet c, Pos, % (Content != "") ? "p2" : "p1"
    py := (Instruction != "" || Content !="") ? (cy + ch + 16) : 22
    Gui Add, % (Control != "") ? Control : "Edit", % "vInput x10 y" . py . " w" . (Width - 20) . "h21 " . Options, %Default%

    GuiControlGet e, Pos, Input
    py := ey + eh + 20
    Gui Add, Text, hWndf y%py% -Background +Border ; Footer

    Gui Add, Button, % "gInputBoxExOK x" . (Width - 176) . " yp+12 w80 h23 Default", &OK
    Gui Add, Button, % "gInputBoxExClose xp+86 yp w80 h23", &Cancel

    Gui Show, % "w" . Width . " " . Pos, %Title%
    Gui +SysMenu %WindowOptions%
    If (Icon != "") {
        hIcon := LoadPicture(Icon, "Icon" . IconIndex, ErrorLevel)
        SendMessage 0x80, 0, hIcon,, ahk_id %hWnd% ; WM_SETICON
    }

    WinGetPos,,, ww,, ahk_id %hWnd%
    Guicontrol MoveDraw, %f%, % "x-1 " . " w" . ww . " h" . 48

    If (Timeout) {
        SetTimer InputBoxExTIMEOUT, % Round(Timeout) * 1000
    }

    If (Owner) {
        WinSet Disable,, ahk_id %Owner%
    }

    GuiControl Focus, Input
    Gui Font

    WinWaitClose ahk_id %hWnd%
    ErrorLevel := ExitCode
    Return Input

    InputBoxExESCAPE:
    InputBoxExCLOSE:
    InputBoxExTIMEOUT:
    InputBoxExOK:
        SetTimer InputBoxExTIMEOUT, Delete

        If (Owner) {
            WinSet Enable,, ahk_id %Owner%
        }

        Gui %hWnd%: Submit
        Gui %hWnd%: Destroy
        ExitCode := (A_ThisLabel == "InputBoxExOK") ? 0 : (A_ThisLabel == "InputBoxExTIMEOUT") ? 2 : 1
    Return
}
