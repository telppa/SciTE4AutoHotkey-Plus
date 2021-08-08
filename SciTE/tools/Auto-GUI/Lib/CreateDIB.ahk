; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3203
CreateDIB(PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 0, DIB := 1) {
    Static OSV
    Local LR_1, LR_2, Flags, WB, BMBITS, PE, P, hBM

    If (!VarSetCapacity(OSV)) {
        FileGetVersion, OSV, user32.dll
        OSV := Format("{1:}.{2:}", StrSplit(OSV, ".")*)
    }

    LR_1   :=  0x2000|0x8|0x4              ; LR_CREATEDIBSECTION | LR_COPYDELETEORG | LR_COPYRETURNORG
    LR_2   :=         0x8|0x4                                    ; LR_COPYDELETEORG | LR_COPYRETURNORG   
    Flags  :=  (OSV > 6.3 ? (Gradient ? LR_2 : LR_1) : (Gradient ? LR_1 : LR_2))
    WB     :=  Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, WB * H, 0), P := &BMBITS, PE := P + (WB * H) 
    
    Loop, Parse, PixelData, |
    P := P < PE ? Numput("0x" . A_LoopField, P + 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1) : P
    
    hBM := DllCall("CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
    hBM := DllCall("CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", LR_1, "Ptr")
           DllCall("SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", &BMBITS)
    hBM := DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", 0, "Int", 0, "Int", Flags, "Ptr")
    hBM := DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "UInt", Flags, "Ptr")
    hBM := DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", 0, "Int", 0, "UInt", LR_2, "Ptr")
    Return DllCall("CopyImage", "Ptr", hBM, "Int", 0, "Int", 0, "Int", 0, "UInt", DIB ? LR_1 : LR_2, "Ptr")
}
