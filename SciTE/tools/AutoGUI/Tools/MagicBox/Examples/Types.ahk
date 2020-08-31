; Excerpts from the book "Developer to Designer: GUI Design for the Busy Developer"

#NoEnv
#Warn
#SingleInstance Force
SetBatchLines -1

#Include ..\Functions\MsgBoxEx.ahk

Icon := 1

Text := "Information message boxes contain information that the user should acknowledge `nto confirm that they understand what’s going on with the application."

Result := MsgBoxEx(Text, "Information", "             Next          ...|Cancel", 5, "", "", 0, 0, "", "", "", "Callback")
ExitApp

Callback:
    Icon++
    If (Icon == 2) {
        Text := "Warning message boxes contain information about unexpected results or problems `nthat do not prevent the application from continuing."
        SoundPlay *0x30
    } Else If (Icon == 3) {
        Text := "Question message boxes are used to ask simple questions and to request `nconfirmation of actions."
        SoundPlay *0x20
    } Else If (Icon == 4) {
        Text := "Error message boxes contain information on problems that (at least potentially) `nprevent the application from continuing."
        SoundPlay *0x10
    } Else {

    }

    WinSetTitle, % SubStr(Text, 1, InStr(Text, " "))
    GuiControl,, Static1, *Icon%Icon% user32.dll
    ControlSetText SysLink1, %Text%

    If (Icon == 4) {
        GuiControl Disable, Button1
        GuiControl,, Button2, Close
    }
Return
