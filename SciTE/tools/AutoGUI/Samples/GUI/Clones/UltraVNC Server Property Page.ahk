#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Gui Add, GroupBox, x8 y5 w198 h189, Incoming Connections
Gui Add, CheckBox, x18 y24 w168 h18 Checked, Accept Socket Connections
Gui Add, Text, x17 y46 w153 h15, Display Number or Ports to use:
Gui Add, Radio, x17 y67 w53 h16, Display
Gui Add, Text, x80 y68 w14 h13, N°
Gui Add, Edit, x99 y67 w44 h20 Disabled, 0
Gui Add, Radio, x17 y88 w45 h16, Ports
Gui Add, Text, x68 y89 w27 h13, Main:
Gui Add, Edit, x99 y86 w44 h20 Disabled, 5900
Gui Add, Radio, x152 y88 w47 h15 Checked, Auto
Gui Add, Text, x54 y109 w41 h13 Right, Http:
Gui Add, Edit, x99 y106 w44 h20 Disabled, 5800
Gui Add, CheckBox, x17 y130 w183 h16 Checked, Enable JavaViewer (Http Connect)
Gui Add, CheckBox, x17 y148 w158 h16 Checked, Allow Loopback Connections
Gui Add, CheckBox, x17 y166 w89 h16, LoopbackOnly
Gui Add, GroupBox, x213 y5 w156 h85, When Last Client Disconnects
Gui Add, Radio, x219 y24 w120 h20 Checked, Do Nothing
Gui Add, Radio, x219 y42 w144 h21, Lock Workstation (W2K)
Gui Add, Radio, x219 y63 w120 h18, Logoff Workstation
Gui Add, GroupBox, x213 y96 w155 h98, Keyboard && Mouse
Gui Add, CheckBox, x225 y114 w138 h18, Disable Viewers inputs
Gui Add, CheckBox, x225 y133 w125 h20, Disable Local inputs
Gui Add, CheckBox, x225 y154 w134 h29, Alternate keyboard method
Gui Add, GroupBox, x375 y5 w204 h86, Query on incoming connection
Gui Add, CheckBox, x386 y24 w129 h16, Display Query Window
Gui Add, Text, x413 y47 w42 h13, Timeout:
Gui Add, Edit, x462 y44 w29 h20 Disabled, 10
Gui Add, Text, x495 y47 w44 h13, seconds
Gui Add, Text, x386 y70 w71 h13, Default action:
Gui Add, Radio, x461 y70 w59 h16 Checked Disabled Group, Refuse
Gui Add, Radio, x519 y70 w56 h16 Disabled, Accept
Gui Add, GroupBox, x375 y96 w204 h98, Multi viewer connections
Gui Add, Radio, x383 y115 w191 h16 Checked, Disconnect all existing connections
Gui Add, Radio, x383 y132 w156 h16, Keep existing connections
Gui Add, Radio, x383 y150 w155 h15, Refuse the new connection
Gui Add, Radio, x383 y167 w153 h16, Refuse all new connection 
Gui Add, GroupBox, x9 y198 w315 h143, Authentication
Gui Add, Text, x50 y221 w75 h18, VNC Password:
Gui Add, Edit, x128 y219 w111 h21 Password, password
Gui Add, Text, x21 y244 w104 h18, View-Only Password:
Gui Add, Edit, x128 y244 w111 h21 Password, password
Gui Add, CheckBox, x20 y267 w219 h16, Require MS Logon  (User/Pass./Domain)
Gui Add, CheckBox, x38 y284 w230 h18 Disabled, New MS Logon (supports multiple domains)
Gui Add, Button, x20 y309 w293 h20 Disabled, Configure MS Logon Groups
Gui Add, GroupBox, x332 y198 w248 h189, Misc.
Gui Add, CheckBox, x342 y211 w122 h16, Remove Aero (Vista)
Gui Add, CheckBox, x342 y228 w201 h16, Remove Wallpaper for Viewers
Gui Add, CheckBox, x342 y245 w216 h16 Checked, Enable Blank Monitor on Viewer Request
Gui Add, CheckBox, x359 y262 w213 h16, Disable Only Inputs on Blanking Request
Gui Add, CheckBox, x342 y315 w101 h16, DisableTrayIcon
Gui Add, CheckBox, x342 y351 w203 h16, Forbid the user to close down WinVNC
Gui Add, Text, x356 y366 w138 h13, Default Server Screen Scale:
Gui Add, Text, x522 y366 w18 h13, 1 / 
Gui Add, Edit, x545 y361 w18 h20, 1
Gui Add, GroupBox, x9 y346 w315 h41, File Transfer
Gui Add, CheckBox, x20 y364 w57 h16 Checked, Enable
Gui Add, CheckBox, x107 y364 w200 h16 Checked, User impersonation (for Service only)
Gui Add, GroupBox, x8 y392 w317 h52, DSM Plugin
Gui Add, CheckBox, x20 y414 w47 h16, Use :
Gui Add, ComboBox, x68 y411 w194, No Plugin detected...||
Gui Add, Button, x269 y411 w44 h20 Disabled, Config.
Gui Add, GroupBox, x332 y392 w248 h83, Logging
Gui Add, CheckBox, x342 y408 w209 h16, Log debug infos to the WinVNC.log file
Gui Add, Text, x344 y449 w27 h13, Path:
Gui Add, Edit, x375 y445 w198 h23 Disabled, C:\Software\UltraVNC
Gui Add, Button, x48 y453 w65 h23 Default, &OK
Gui Add, Button, x122 y453 w65 h23, &Apply
Gui Add, Button, x194 y453 w66 h23, &Cancel
Gui Show, w585 h483, UltraVNC Server Property Page - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
