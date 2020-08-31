#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Menu Tray, Icon, shell32.dll, 131

Gui Body: New, LabelBody hWndhBody
Gui Color, White

Gui Add, Edit, x0 y0 w0 h0 ; Capture focus
Gui Font, s8 w700 cBlack, Segoe UI
Gui Add, Text, x10 y46 w187 h16, You're installing these programs.
Gui Font
Gui Font,, Segoe UI
Gui Add, Text, x10 y62 w456 h16 +0x200, As each item finishes, you can start using it while the others continue to install.
Gui Add, Text, x10 y80 w480 h1 0x10 ; Separator

If (FileExist(A_WinDir . "\System32\ieframe.dll")) {
    Gui Add, Picture, x24 y90 w16 h16 Icon40, ieframe.dll
}
Gui Add, Text, x48 y90 w100 h16 +0x200, Installed
Gui Add, Text, x48 y107 w100 h16 +0x200, Installing
Gui Add, Text, x48 y124 w100 h16 +0x200, 100`% downloaded

Gui Font, w700 c0x0080ff, Segoe UI
Gui Add, Text, x164 y90 w100 h16 +0x200, Start Messenger
Gui Font
Gui Font, s8 w700, Segoe UI
Gui Add, Text, x164 y107 w100 h16 +0x200, Writer
Gui Font
Gui Font, w700 cBlack, Segoe UI
Gui Add, Text, x164 y124 w100 h16 +0x200, Sign-in Assistant
Gui Font

Gui Font,, Segoe UI
Gui Add, Text, x336 y90 w120 h16 +0x200, Done
Gui Font
Gui Add, Progress, x335 y108 w120 h16 -Smooth, 5

Gui Font, w700 cBlack, Segoe UI
Gui Add, Text, x10 y224 w480 h16 +0x200, Select any additional products you want to install.
Gui Font
Gui Add, Text, x10 y243 w480 h2 0x10 ; Separator
Gui Font, w700, Segoe UI
Gui Add, CheckBox, x33 y253 w42 h23, Mail
Gui Add, CheckBox, x33 y282 w60 h23, Toolbar
Gui Add, CheckBox, x33 y311 w92 h23, Photo Gallery
Gui Add, CheckBox, x33 y342 w92 h23, Family Safety
Gui Font

Gui Font,, Segoe UI
Gui Add, Text, x78 y253 w410 h23 +0x200, (15 MB) - Access all your e-mail accounts in one place
Gui Add, Text, x95 y282 w393 h23 +0x200, (5 MB) - Search from any Web page
Gui Add, Text, x126 y311 w362 h23 +0x200, (13 MB) - Easily organize, edit, and share your photos and videos
Gui Add, Text, x126 y341 w364 h23 +0x200, (3 MB) - Help keep your family safe online

Gui Add, Button, x14 y376 w110 h23 Disabled, Add to installation
Gui Font, c0x0080ff, Segoe UI
Gui Add, Text, x10 y400 w263 h25 +0x200, Learn more about these products
Gui Font

Gui Add, Progress, x-1 y430 w502 h49 Border, 0
Gui Font,, Segoe UI
Gui Add, Button, x413 y439 w75 h23, Cancel

Gui Show, w499 h471, Windows Live Installer - Sample GUI

Gui Header: New, -Caption +Parent%hBody%
Gui Header: Color, 0x008EBC
Gui Header: Add, Picture, x24 y6 w28 h28 Icon131, shell32.dll
Gui Font, s14 c0xF3F8FB, Ms Shell Dlg 2
Gui Header: Add, Text, x54 y1 w394 h38 +0x200 BackgroundTrans, Windows Live
Gui Font
Gui Header: Show, x0 y0 w500 h38

Gui Info: New, -Caption +Parent%hBody%
Gui Info: Color, 0xFFFFE1
Gui Info: Font,, Segoe UI
Gui Info: Add, Picture, x4 y4 w16 h16 Icon222, shell32.dll
Gui Info: Add, Text, x25 y0 w480 h23 +0x200, Installation may take a few minutes. Feel free to do other things while you wait.
Gui Info: Font
Gui Info: Show, x10 y196 w480 h23
Return

BodyEscape:
BodyClose:
    ExitApp
