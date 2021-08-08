; =================================================================================
; Function: AutoXYWH
;   Move and resize controls automatically when the window is resized.
;
; Parameters:
;   DimSize - Can be one or more of x/y/w/h, optionally followed by a fraction.
;             The presence of an asterisk in this parameter indicates that the
;             controls are to be moved/resized with 'MoveDraw' instead of 'Move'.
;             This is recommended for GroupBoxes.
;
;   cList   - Variadic list of ControlIDs.
;             ControlID can be a control HWND, associated variable name, ClassNN
;             or displayed text. The latter (displayed text) may not be reliable.
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
; ---------------------------------------------------------------------------------
; Version: 2015-5-29 / Added 'reset' option (by tmplinshi)
;          2014-7-03 / toralf
;          2014-1-2  / tmplinshi
; Mininum AHK version: 1.1.13.01.
; Forum topic: https://www.autohotkey.com/boards/viewtopic.php?t=1079
; =================================================================================

AutoXYWH(DimSize, cList*) {
    Static cInfo := {}

    If (DimSize = "reset") {
        Return cInfo := {}
    }

    For i, ctrl in cList {
        ctrlID := A_Gui ":" ctrl
        If (cInfo[ctrlID].x = "") {
            GuiControlGet i, %A_Gui%: Pos, %ctrl%
            MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
            fx := fy := fw := fh := 0
            For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]"))) {
                If (!RegExMatch(DimSize, "i)" . dim . "\s*\K[\d.-]+", f%dim%)) {
                    f%dim% := 1
                }
            }
            cInfo[ctrlID] := {x: ix, fx: fx, y: iy, fy: fy, w: iw, fw: fw, h: ih, fh: fh, gw: A_GuiWidth, gh: A_GuiHeight, a: a, m: MMD}
        } Else If (cInfo[ctrlID].a.1) {
            dgx := dgw := A_GuiWidth - cInfo[ctrlID].gw, dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
            Options := ""
            For i, dim in cInfo[ctrlID]["a"] {
                Options .= dim . (dg%dim% * cInfo[ctrlID]["f" . dim] + cInfo[ctrlID][dim]) . A_Space
            }
            GuiControl, % A_Gui ":" cInfo[ctrlID].m, % ctrl, % Options
        }
    }
}
