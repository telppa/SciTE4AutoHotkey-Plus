#Include ..\Functions\MsgBoxEx.ahk

Text := "Windows XP End of Support is on April 8th, 2014.`n<a href=""https://www.microsoft.com/en-us/WindowsForBusiness/end-of-xp-support"">Click Here</a> to learn more."
CheckText := "Don't show this message again"

Result := MsgBoxEx(Text, "Windows", "OK", 2, CheckText)
ExitApp
