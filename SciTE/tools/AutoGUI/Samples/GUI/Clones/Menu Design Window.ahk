; Visual Basic 1.0 Menu Design Window
#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
Menu Tray, UseErrorLevel

Menu Tray, Icon, ..\Icons\AutoGUI.icl, 58
Gui -MinimizeBox
Gui Font, s8 w700, Segoe UI
Gui Color, White
Gui Add, Text, x8 y12 w60 h23 +0x202, Ca&ption:
Gui Add, Edit, x78 y12 w200 h21
Gui Add, Button, x291 y12 w60 h23, &Done
Gui Add, Text, x7 y44 w60 h23 +0x202, CtlNa&me:
Gui Add, Edit, x78 y44 w200 h21
Gui Add, Button, x291 y43 w60 h23, Cancel
Gui Add, Text, x8 y74 w60 h23 +0x202, Inde&x:
Gui Add, Edit, x78 y76 w46 h21
Gui Add, Text, x132 y74 w76 h23 +0x202, &Accelerator:
Gui Add, ComboBox, x219 y76 w130, (none)||
Gui Add, CheckBox, x22 y106 w80 h23, &Checked
Gui Add, CheckBox, x148 y106 w80 h23 Checked, &Enabled
Gui Add, CheckBox, x268 y106 w80 h23 Checked, &Visible
Gui Add, GroupBox, x9 y126 w341 h48 +0x9000
Gui Font, s8 w400, Wingdings
Gui Add, Button, x17 y141 w23 h23, ç
Gui Add, Button, x39 y141 w23 h23, è
Gui Add, Button, x61 y141 w23 h23, é
Gui Add, Button, x83 y141 w23 h23, ê
Gui Font, s8 w700, Ms Shell Dlg 2
Gui Add, Button, x115 y141 w70 h23 Default, &Next
Gui Add, Button, x191 y141 w70 h23, &Insert
Gui Add, Button, x268 y141 w70 h23, Dele&te
Gui Add, ListBox, x10 y173 w340 h134, % "||"
Gui Show, w362 h319, Menu Design Window - Sample GUI
SendInput {Alt 2}
Return

GuiEscape:
GuiClose:
    ExitApp
