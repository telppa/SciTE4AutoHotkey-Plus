#Include ..\Functions\InputBoxEx.ahk

Details := "Enter the name of an AHK GUI control type or choose one from the list."
Type := "ComboBox"

Start:
    Options := ""

    If (Type ~= "i)ComboBox|DropDownList|DDL|ListBox") {
        Default := "Edit|ComboBox|DropDownList|CheckBox|ListBox||DateTime|MonthCal|Hotkey|Slider"
        If (Type = "ListBox") {
            Options := "r9"
        }
    } Else If (Type = "CheckBox") {
        Default := " In the future, do not show me this message again"
        Options := "Checked"
    } Else If (Type = "DateTime") {
        Default := "LongDate"
        Options := "Right"
    } Else If (Type = "Hotkey") {
        Default := "^!Home"
    } Else If (Type = "Slider") {
        Options := "NoTicks Center Tooltip"
    } Else If (Type = "Text") {
        Default := "AutoHotkey " . A_AhkVersion . " "
                . ((A_IsUnicode) ? "Unicode" : "ANSI") . " "
                . ((A_PtrSize == 4) ? "32-bit" : "64-bit")
        Options := "h30 +0x400201 +E0x200"
    } Else {
        Default := Type
    }

    Try {
        Type := InputBoxEx("Specify the input control type", Details, "InputBoxEx Example", Default, Type, Options, "", "", "", "", "", "MinimizeBox")
    } Catch {
        Type := "ComboBox"
        GoSub Start
    }

    If (!ErrorLevel) {
        GoSub Start
    }

ExitApp
