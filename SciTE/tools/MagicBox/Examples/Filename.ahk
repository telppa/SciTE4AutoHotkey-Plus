#Include ..\Functions\MsgBoxEx.ahk

Text := "A file named ""FILENAME.EXT"" already exists in this location.`n`nSelect the action to be taken."

Result := MsgBoxEx(Text, "Confirm", "&Browse...|&Auto-rename|&Compare...|&Replace|Ca&ncel", [69], "", "", 0, 0, "", "", "", "Callback")
ExitApp

Callback:
    If (A_GuiControl == "&Browse...") {
        FileSelectFile SelectedFile
    } Else {
        MsgBox 0x2040, Comparisson, The two files are identical.
    }
Return
