WinVer := DllCall("kernel32.dll\GetVersion")
MajorVer := WinVer & 0xFF
MinorVer := WinVer >> 8 & 0xFF

If (MajorVer < 6) {
    MsgBox 0x10, Error, This script requires Windows Vista or higher.
    Return
} Else {
    If (MajorVer > 9 || (MajorVer > 5 && MinorVer > 1)) {
        IconRes := "xwizard.exe" ; Windows 8+
    } Else {
        IconRes := "setupcln.dll" ; Vista/7
    }
}

Content := "Setup is now preparing the Windows 95 Setup Wizard,`nwhich will guide you through the rest of the Setup process. Please wait."
Title := "Windows 95 Setup"
MainIcon := LoadPicture(IconRes, "w32 Icon1", ImageType)
Flags := 0xA02
Buttons := 0x8
Callback := RegisterCallback("Callback", "Fast")
CBData := {}
CBData.Marquee := True
CBData.Timeout := 8000 ; ms
Parent := DllCall("GetDesktopWindow", "Ptr")

; TASKDIALOGCONFIG structure
x64 := A_PtrSize == 8
NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0) ; cbSize
NumPut(Parent,   TDC, 4, "Ptr")         ; hwndParent
NumPut(Flags,    TDC, (x64) ? 20 : 12)  ; dwFlags
NumPut(Buttons,  TDC, (x64) ? 24 : 16)  ; dwCommonButtons
NumPut(&Title,   TDC, (x64) ? 28 : 20)  ; pszWindowTitle
NumPut(MainIcon, TDC, (x64) ? 36 : 24)  ; pszMainIcon
NumPut(&Content, TDC, (x64) ? 52 : 32)  ; pszContent
NumPut(Callback, TDC, (x64) ? 140 : 84, "Ptr") ; pfCallback
NumPut(&CBData,  TDC, (x64) ? 148 : 88) ; lpCallbackData

Callback(hWnd, Notification, wParam, lParam, RefData) {
    Static Pos := 0
    CBData := Object(RefData)

    If (Notification == 4) {
        If (wParam > CBData.Timeout) {
            ; TDM_CLICK_BUTTON := 0x466, IDCANCEL := 2
            DllCall("PostMessage", "Ptr", hWnd, "UInt", 0x466, "UInt", 2, "UInt", 0)
        }

        DllCall("SendMessage", "Ptr", hWnd, "UInt", 0x46A, "UInt", Pos, "UInt", 0)
        Pos += 3
    }
}

DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
    , "Int*", Button := 0
    , "Int*", Radio := 0
    , "Int*", Checked := 0)

DllCall("Kernel32.dll\GlobalFree", "Ptr", Callback)
