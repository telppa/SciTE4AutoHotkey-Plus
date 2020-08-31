; Advanced System Settings -> Hardware -> Device Installation Settings (Windows 7)
#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Gui Color, White
Gui Font, s12 c0x003399, Segoe UI
Gui Add, Text, x18 y9 w557 h45, Do you want Windows to download driver software and realistic icons for your devices?
Gui Font

Gui Font, s9, Segoe UI
Gui Add, Radio, x26 y83 w525 h15, &Yes`, do this automatically (recommended)
Gui Add, Radio, x26 y116 w525 h15 Checked, No`, &let me choose what to do
Gui Add, Radio, x63 y141 w525 h15 Group, &Always install the best driver software from Windows Update.
Gui Add, Radio, x63 y161 w403 h30, &Install driver software from Windows Update if it is not found on my computer.
Gui Add, Radio, x63 y197 w525 h15 Checked, &Never install driver software from Windows Update.
Gui Add, CheckBox, x63 y234 w525 h30, &Replace generic device icons with enhanced icons
Gui Add, Link, x18 y315 w319 h15, <A>Why should I have Windows do this automatically?</A>
Gui Add, Text, x18 y343 w557 h17 Disabled, _____________________________________________________________________________________________________________________________________________
Gui Add, Button, hWndhSaveBtn x345 y366 w130 h26 Disabled, Save Changes
SendMessage 0x160C, 0, 1,, ahk_id%hSaveBtn%
Gui Add, Button, x487 y366 w88 h26 Default, Cancel
Gui Show, w593 h399, Device Installation Settings - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
