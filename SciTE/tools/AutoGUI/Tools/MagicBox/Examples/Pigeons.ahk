If (DllCall("kernel32.dll\GetVersion") & 0xFF < 6) {
    MsgBox 0x10, Error, This script requires Windows Vista or higher.
    Return
}

Instruction := "Some facts in regard to the colouring of pigeons well deserve consideration."
Content := "The rock-pigeon is of a slaty-blue, and has a white rump (the Indian sub-species, Columba intermedia of Strickland, having it bluish); the tail has a terminal dark bar, with the bases of the outer feathers externally edged with white; the wings have two black bars; some semi-domestic breeds and some apparently truly wild breeds have, besides the two black bars, the wings chequered with black."
Title := "Variation under Domestication"
MainIcon := 0xFFFB
Width := 300
Callback := RegisterCallback("Callback", "Fast")

; TASKDIALOGCONFIG structure
x64 := A_PtrSize == 8
NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0) ; cbSize
NumPut(&Title, TDC, (x64) ? 28 : 20) ; pszWindowTitle
NumPut(MainIcon, TDC, (x64) ? 36 : 24) ; pszMainIcon
NumPut(&Instruction, TDC, (x64) ? 44 : 28) ; pszMainInstruction
NumPut(&Content, TDC, (x64) ? 52 : 32) ; pszContent
NumPut(Callback, TDC, (x64) ? 140 : 84) ; pfCallback
NumPut(Width, TDC, (x64) ? 156 : 92, "UInt") ; cxWidth

SoundPlay *64

DllCall("Comctl32.dll\TaskDialogIndirect", "UInt", &TDC
    , "Int*", Button := 0
    , "Int*", Radio := 0
    , "Int*", Checked := 0)

Callback(hWnd, Notification, wParam, lParam, RefData) {
    If (Notification == 0) {
        DllCall("PostMessage", "Ptr", hWnd, "UInt", 0x474, "UInt", 0, "UInt", 0xFFFD)
    }
}
