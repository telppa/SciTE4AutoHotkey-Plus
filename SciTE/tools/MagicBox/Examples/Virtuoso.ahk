If (DllCall("kernel32.dll\GetVersion") & 0xFF < 6) {
    MsgBox 0x10, Error, This script requires Windows Vista or higher.
    Return
}

Instruction := "One who makes or repairs musical instruments, such as violins."
Title := "Quiz"
MainIcon := LoadPicture("dxptasksync.dll", "w32 Icon5", ImageType)
Flags := 0x52
Buttons := 0x8
CustomButtons := []
CustomButtons.Push([101, "Cordon bleu"])
CustomButtons.Push([102, "Sommelier"])
CustomButtons.Push([103, "Luthier"])
CustomButtons.Push([104, "Virtuoso"])
cButtons := CustomButtons.Length()
VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)
Loop %cButtons% {
    iButtonID := CustomButtons[A_Index][1]
    iButtonText := &(b%A_Index% := CustomButtons[A_Index][2])
    NumPut(iButtonID,   pButtons, (4 + A_PtrSize) * (A_Index - 1))
    NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize)
}
Width := 268
Callback := RegisterCallback("Callback", "Fast")

hModule := DllCall("kernel32.dll\LoadLibraryEx", "Str", "ieframe.dll", "UInt", 0, "UInt", 0x2, "Ptr")
Global g_hIcon := DllCall("LoadIcon", "Ptr", hModule, "Ptr", 18211, "Ptr") ; ieframe.dll check mark icon
DllCall("FreeLibrary", "Ptr", hModule)

; TASKDIALOGCONFIG structure
x64 := A_PtrSize == 8
NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0) ; cbSize
NumPut(0x10010, TDC, 4, "Ptr") ; hwndParent
NumPut(Flags, TDC, (x64) ? 20 : 12) ; dwFlags
NumPut(Buttons, TDC, (x64) ? 24 : 16) ; dwCommonButtons
NumPut(&Title, TDC, (x64) ? 28 : 20) ; pszWindowTitle
NumPut(MainIcon, TDC, (x64) ? 36 : 24) ; pszMainIcon
NumPut(&Instruction, TDC, (x64) ? 44 : 28) ; pszMainInstruction
NumPut(cButtons, TDC, (x64) ? 60 : 36) ; cButtons
NumPut(&pButtons, TDC, (x64) ? 64 : 40) ; pButtons
NumPut(Callback, TDC, (x64) ? 140 : 84, "Ptr") ; pfCallback
NumPut(Width, TDC, (x64) ? 156 : 92, "UInt") ; cxWidth

DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
    , "Int*", Button := 0
    , "Int*", Radio := 0
    , "Int*", Checked := 0)

Callback(hWnd, Notification, wParam, lParam, RefData) {
    If (Notification == 2) {
        If (wParam == 2) {
            ExitApp
        } Else If (wParam == 103) {
            hIcon := g_hIcon ; LoadPicture("SyncCenter.dll", "w32 Icon19", _)
        } Else {
            hIcon := LoadPicture("user32.dll", "w32 Icon4", _)
        }
        SendMessage 0x474, 0, %hIcon%,, ahk_id %hWnd% ; TDM_UPDATE_ICON
        Return True
    }
}
