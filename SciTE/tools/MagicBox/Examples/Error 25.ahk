#Include ..\Functions\MsgBoxEx.ahk

Text := "An error occurred while copying the file NDIS.386`n`nMS-DOS Error 25: Unknown MS-DOS error."

SoundPlay *48
Result := MsgBoxEx(Text, "Network Setup", "Cancel|Try Again|Continue", [9, "explorer.exe"], "", "", 0, 0, "s10 c0x000000", "Fixedsys")
ExitApp
