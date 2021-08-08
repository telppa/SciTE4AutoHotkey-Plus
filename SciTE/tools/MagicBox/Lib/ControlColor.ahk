; http://www.autohotkey.com/board/topic/104539-controlcol-set-background-and-text-color-gui-controls/

ControlColor(Control, Window, bc := "", tc := "", Redraw := True) {
    Local a := {}
    a["c"]  := Control
    a["g"]  := Window
    a["bc"] := (bc == "") ? "" : (((bc & 255) << 16) + (((bc >> 8) & 255) << 8) + (bc >> 16))
    a["tc"] := (tc == "") ? "" : (((tc & 255) << 16) + (((tc >> 8) & 255) << 8) + (tc >> 16))

    CC_WindowProc("Set", a, "", "")

    If (Redraw) {
        WinSet Redraw,, ahk_id %Control%
    }
}

CC_WindowProc(hWnd, uMsg, wParam, lParam) {
    Local tc, bc, a
    Static Win := {}
    ; Critical

    If uMsg Between 0x132 And 0x138 ; WM_CTLCOLOR(MSGBOX|EDIT|LISTBOX|BTN|DLG|SCROLLBAR|STATIC)
    If (Win[hWnd].HasKey(lParam)) {
        If (tc := Win[hWnd, lParam, "tc"]) {
            DllCall("gdi32.dll\SetTextColor", "Ptr", wParam, "UInt", tc)
        }

        If (bc := Win[hWnd, lParam, "bc"]) {
            DllCall("gdi32.dll\SetBkColor",   "Ptr", wParam, "UInt", bc)
        }

        Return Win[hWnd, lParam, "Brush"] ; Return the HBRUSH to notify the OS that we altered the HDC.
    }

    If (hWnd == "Set") {
        a := uMsg
        Win[a.g, a.c] := a

        If ((Win[a.g, a.c, "tc"] == "") && (Win[a.g, a.c, "bc"] == "")) {
            Win[a.g].Remove(a.c, "")            
        }

        If (!Win[a.g, "WindowProcOld"]) {
            Win[a.g,"WindowProcOld"] := DllCall("SetWindowLong" . (A_PtrSize == 8 ? "Ptr" : "")
            , "Ptr", a.g, "Int", -4, "Ptr", RegisterCallback("CC_WindowProc", "", 4), "UPtr")
        }

        If (Win[a.g, a.c, "bc"] != "") {
            Win[a.g, a.c, "Brush"] := DllCall("gdi32.dll\CreateSolidBrush", "UInt", a.bc, "UPtr")
        }

        Return
    }

    Return DllCall("CallWindowProc", "Ptr", Win[hWnd, "WindowProcOld"], "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}
