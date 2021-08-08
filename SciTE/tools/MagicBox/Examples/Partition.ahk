If (DllCall("kernel32.dll\GetVersion") & 0xFF < 6) {
    MsgBox 0x10, Error, This script requires Windows Vista or higher.
    Return
}

Instruction := "The requested partition has been marked active."
Content := "When you reboot your computer the operating system on that partition will be started."
;Title := "Disk Administrator"
Title := "Task Dialog Example"
MainIcon := 36
Flags := 0x40
Buttons := 0x1
Width := 218

; TASKDIALOGCONFIG structure
x64 := A_PtrSize == 8
NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0) ; cbSize
NumPut(Flags, TDC, (x64) ? 20 : 12) ; dwFlags
NumPut(Buttons, TDC, (x64) ? 24 : 16) ; dwCommonButtons
NumPut(&Title, TDC, (x64) ? 28 : 20) ; pszWindowTitle
NumPut(MainIcon, TDC, (x64) ? 36 : 24) ; pszMainIcon
NumPut(&Instruction, TDC, (x64) ? 44 : 28) ; pszMainInstruction
NumPut(&Content, TDC, (x64) ? 52 : 32) ; pszContent
NumPut(Width, TDC, (x64) ? 156 : 92, "UInt") ; cxWidth

DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
    , "Int*", Button := 0
    , "Int*", Radio := 0
    , "Int*", Checked := 0)
