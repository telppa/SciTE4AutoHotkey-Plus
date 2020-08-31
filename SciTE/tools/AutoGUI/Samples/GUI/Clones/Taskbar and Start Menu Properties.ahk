; Windows 7 Taskbar and Start Menu Properties
#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Menu Tray, Icon, shell32.dll, 40

Try {
    Gui Add, % "Tab3", x6 y7 w386 h380, Taskbar|Start Menu|Toolbars
} Catch {
    Gui Add, Tab2, x6 y7 w386 h380, Taskbar|Start Menu|Toolbars
}
    Gui Add, CheckBox, x30 y58 w300 h16 Checked, &Lock the taskbar
    Gui Add, CheckBox, x30 y81 w300 h16, A&uto-hide the taskbar
    Gui Add, CheckBox, x30 y104 w300 h16, Use small &icons
    Gui Add, Text, x30 y131 w150 h16, &Taskbar location on screen:
    Gui Add, DropDownList, x186 y127 w165, Bottom||Left|Right|Top
    Gui Add, Text, x30 y161 w150 h16, Taskbar &buttons:
    Gui Add, DropDownList, x186 y156 w165, Always combine`, hide labels||Combine when taskbar is full|Never combine
    Gui Add, GroupBox, x21 y40 w357 h148, Taskbar appearance
    Gui Add, Text, x30 y213 w257 h26, Customize which icons and notifications appear in the notification area.
    Gui Add, Button, x292 y213 w75 h23, &Customize...
    Gui Add, GroupBox, x21 y195 w357 h55, Notification area
    Gui Add, Text, x30 y274 w330 h26, Temporarily view the desktop when you move your mouse to the Show desktop button at end of the taskbar.
    Gui Add, CheckBox, x30 y307 w300 h16 Checked, Use Aero &Peek to preview the desktop
    Gui Add, GroupBox, x21 y257 w357 h78, Preview desktop with Aero Peek
    Gui Add, Link, x21 y354 w300 h13, <A>How do I customize the taskbar?</A>

Gui Tab, 2
    Gui Add, Text, x21 y40 w255 h26, To customize how links`, icons`, and menus look and behave in the Start menu`, click Customize.
    Gui Add, Button, x298 y36 w80 h23 Default, &Customize...
    Gui Add, Text, x21 y86 w108 h13, Power &button action:
    Gui Add, DropDownList, x135 y81 w150, Switch user|Log off|Lock|Restart|Sleep|Shut down||
    Gui Add, CheckBox, x31 y140 w336 h16 Checked, Store and display recently opened &programs in the Start menu 
    Gui Add, CheckBox, x31 y162 w336 h33, Store and display recently opened items in the Start &menu and the taskbar
    Gui Add, GroupBox, x21 y118 w357 h81, Privacy
    Gui Add, Link, x21 y354 w300 h13, <A>How do I change the way the Start menu looks?</A>

Gui Tab, 3
    Gui Add, Text, x21 y40 w335 h20, Select which toolbars to add to the taskbar.
    Gui Add, ListView, x21 y62 w354 h260 -Hdr Checked, Toolbars
        LV_Add("", "Address")
        LV_Add("", "Links")
        LV_Add("", "Desktop")

Gui Tab
Gui Add, Button, x155 y393 w75 h23 Default, OK
Gui Add, Button, x236 y393 w75 h23, Cancel
Gui Add, Button, x317 y393 w75 h23 Disabled, &Apply

Gui Show, w398 h423, Taskbar and Start Menu Properties - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
