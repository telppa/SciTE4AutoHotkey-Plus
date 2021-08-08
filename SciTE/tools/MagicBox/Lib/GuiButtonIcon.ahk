; GuiButtonIcon
; Function to assign an icon to a Gui Button
; By Fanatic Guru
; Version 2.0 (20140531)
;------------------------------------------------
;
; Signature:
;   GuiButtonIcon(Handle, File, Index, Options)
;
;   Parameters:
;   1) {Handle}     Handle of the button
;   2) {File}       Resource file containing the icon
;   3) {Index}      Index of icon within the file
;   4) {Options}    Single letter flag followed by a number with multiple options delimited by a space
;                       W = Width of the icon (default: 16)
;                       H = Height of the icon (default: 16)
;                       S = Size of the icon, value applied to both width and height
;                       L = Left margin
;                       T = Top margin
;                       R = Right margin
;                       B = Botton margin
;                       A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default: 4)
;
; Return value: true if the icon was succesfully added to the image list
;
; Example:
; Gui, Add, Button, w70 h38 hWndhBtn, Save
; GuiButtonIcon(hBtn, "shell32.dll", 259, "s30 a1 r2")

GuiButtonIcon(Handle, File, Index := 1, Options := "") {
    Local W, H, S, L, T, R, B, A, IL

    RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
    RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
    RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
    RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
    RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
    RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
    RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
    RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :

    VarSetCapacity(button_il, 20 + A_PtrSize, 0)
    IL := DllCall("ImageList_Create", "UInt", W, "UInt", H, "UInt", 0x21, "UInt", 1, "UInt", 1)
    NumPut(IL, button_il, 0, "Ptr")
    NumPut(L, button_il, 0 + A_PtrSize, "UInt")  ; Left margin
    NumPut(T, button_il, 4 + A_PtrSize, "UInt")  ; Top margin
    NumPut(R, button_il, 8 + A_PtrSize, "UInt")  ; Right margin
    NumPut(B, button_il, 12 + A_PtrSize, "UInt") ; Bottom margin
    NumPut(A, button_il, 16 + A_PtrSize, "UInt") ; Alignment
    SendMessage 0x1602, 0, &button_il,, AHK_ID %Handle% ; BCM_SETIMAGELIST
    Return IL_Add(IL, File, Index)
}
