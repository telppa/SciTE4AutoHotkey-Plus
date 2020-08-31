; ConEmu (130113 x86) Settings
#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#Include %A_ScriptDir%\..\..\..\Lib\ControlColor.ahk

Gui Settings: New, LabelGui hWndhWnd

Gui Font, s8, MS Shell Dlg 2

Gui Add, Text, x8 y10 w26 h13, Find:
Gui Add, Edit, x35 y7 w83 h21
Gui Add, Button, x119 y6 w23 h23, >

Gui Add, Text, x159 y10 w44 h13, Storage:
Gui Add, Edit, x212 y7 w341 h21 ReadOnly, HKCU\Software\ConEmu\.Vanilla
Gui Add, Button, x557 y6 w75 h23, Export...

Gui Add, TreeView, gShowOptions x6 y31 w135 h377
Main := TV_Add("Main", 0, "Select Expand")
	Global PrevItem := Main
	TV_Add("Size & Pos", Main)
	TV_Add("Appearance", Main)
	TV_Add("Task bar", Main)
	TV_Add("Update", Main)
Startup:= TV_Add("Startup", 0, "Expand")
	TV_Add("Tasks", Startup)
	TV_Add("ComSpec", Startup)
Features := TV_Add("Features", 0, "Expand")
	TV_Add("Text cursor", Features)
	TV_Add("Colors", Features)
	TV_Add("Transparency", Features)
	TV_Add("Tabs", Features)
	TV_Add("Status bar", Features)
	TV_Add("Integration", Features)
	TV_Add("App distinct", Features)
Keys := TV_Add("Keys & Macro", 0, "Expand")
	TV_Add("Controls", Keys)
	TV_Add("Mark & Paste", Keys)
Far := TV_Add("Far Manager", 0, "Expand")
	TV_Add("Views", Far)
Info := TV_Add("Info", 0, "Expand")
	TV_Add("Debug", Info)

Gui Add, Tab2, x6 y460 w626 h32 -Wrap, Main|Size & Pos|Appearance|Task bar|Update|Startup|Tasks|ComSpec|Features|Text cursor|Colors|Transparency|Tabs|Status bar|Integration|App distinct|Keys & Macro|Controls|Mark & Paste|Far Manager|Views|Info|Debug

; Main
Gui Tab, 1
Gui Add, GroupBox, x149 y33 w479 h145, Font
Gui Add, ComboBox, x158 y52 w194, [Raster Fonts 6x8]|[Raster Fonts 8x8]|[Raster Fonts 16x8]|[Raster Fonts 5x12]|[Raster Fonts 7x12]|[Raster Fonts 8x12]||[Raster Fonts 16x12]|[Raster Fonts 12x16]|[Raster Fonts 10x18]|Consolas|Courier|Courier New|Courier New Baltic|Courier New CE|Courier New CYR|Courier New Greek|Courier New TUR|Fixedsys|Lucida Console|Marlett|Miriam Fixed|Rod|Simplified Arabic Fixed|Source Code Pro|Terminal
Gui Add, CheckBox, x160 y78 w47 h13, &Bold
Gui Add, CheckBox, x211 y78 w47 h13, &Italic
Gui Add, CheckBox, x280 y78 w84 h13 Checked, &Monospace
Gui Add, Text, x161 y101 w72 h13, Font charset:
Gui Add, DropDownList, x239 y98 w113, ANSI|Arabic|Baltic|Chinese Big 5|Default|East Europe|GB 2312|Greek|Hebrew|Hangul|Johab|Mac|OEM||Russian|Shiftjis|Symbol|Thai|Turkish|Vietnamese
Gui Add, Text, x361 y55 w30 h13 Right, Size:
Gui Add, ComboBox, x397 y52 w45, 8|9|10|11|12||14|16|18|19|20|24|26|28|30|32|34|36|40|46|50|52|72
Gui Add, Text, x445 y55 w39 h13 Right, Width:
Gui Add, ComboBox, x490 y52 w45, 0|8||9|10|11|12|14|16|18|19|20|24|26|28|30|32|34|36|40|46|50|52|72
Gui Add, Text, x538 y55 w29 h13 Right, Cell:
Gui Add, ComboBox, x574 y52 w45, 0|8||9|10|11|12|14|16|18|19|20|24|26|28|30|32|34|36|40|46|50|52|72
Gui Add, CheckBox, x397 y78 w218 h13, Auto size (fixed console size in cells)
Gui Add, CheckBox, x397 y103 w86 h13, Extend fonts
Gui Add, DropDownList, x490 y98 w39,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12||13|14|15|None
Gui Add, DropDownList, x535 y98 w39,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13||14|15|None
Gui Add, DropDownList, x580 y98 w39,  0| 1|| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|None
Gui Add, CheckBox, x397 y127 w126 h13 Checked, Change frames font
Gui Add, ComboBox, x397 y145 w152, Lucida Console||...
Gui Add, Text, x556 y148 w12 h13 Center, x
Gui Add, ComboBox, x574 y146 w45, 0||8|9|10|11|12|14|16|18|19|20|24|26|28|30|32|34|36|40|46|50|52|72
Gui Add, GroupBox, x158 y124 w231 h46, Anti-aliasing
Gui Add, Radio, x169 y145 w54 h13, &None
Gui Add, Radio, x229 y145 w71 h13 Checked, &Standard
Gui Add, Radio, x308 y145 w72 h13, &Clear Type

Gui Add, GroupBox, x149 y185 w479 h159
Gui Add, CheckBox, x158 y185 w192 h13, Back&ground image (bmp`, jpg`, png):
Gui Add, Text, x158 y208 w27 h13, Path:
Gui Add, Edit, x194 y205 w392 h20 Disabled, c:\back.bmp
Gui Add, Button, x592 y205 w24 h20 Disabled, ...
Gui Add, Radio, x158 y236 w89 h13 Disabled, Transparent
Gui Add, Radio, x248 y236 w129 h13 Checked, Replace color indexes
Gui Add, Edit, x383 y233 w65 h20, *
Gui Add, Text, x451 y236 w68 h13 Right, Placement:
Gui Add, DropDownList, x524 y233 w92, UpLeft||UpRight|DownLeft|DownRight|Stretch|Tile
Gui Add, Text, x158 y265 w54 h13, Darkening:
Gui Add, Slider, x221 y263 w342 h20 Range0-255 Center NoTicks, 255
Gui Add, Edit, x571 y263 w45 h20, 255
Gui Add, CheckBox, x158 y293 w216 h16 Checked, Allow background plugins (Far Manager)
Gui Add, Text, x158 y315 w54 h13 Disabled, Darkening:
Gui Add, Slider, x221 y314 w342 h20 Range0-100 Center Disabled NoTicks, 0
Gui Add, Edit, x571 y314 w45 h20 Disabled

Gui Tab

Gui Add, Button, x353 y419 w77 h23, Reset
Gui Add, Button, x440 y419 w77 h23, Reload
Gui Add, Button, x527 y419 w105 h23 Default, Save settings

Gui Show, w638 h447, ConEmu 130113 [32] Settings [reg] - Sample GUI

TV_Modify(Main, "Bold")	
ControlFocus SysTreeView321, ConEmu

; Size & Pos
Gui Tab, 2
Gui Add, GroupBox, x149 y33 w479 h372, Console size and Window position
Gui Add, CheckBox, x160 y52 w387 h13 Checked, Show && store current window size and position
Gui Add, CheckBox, x160 y73 w249 h13, Auto save window size and position on exit
Gui Add, Button, x556 y65 w59 h20 Disabled, Apply

Gui Add, GroupBox, x158 y91 w249 h75, Window size (cells)
Gui Add, Radio, x169 y112 w57 h13 Checked, Normal
Gui Add, Radio, x233 y112 w72 h13, Maximized
Gui Add, Radio, x313 y112 w74 h13, Full screen
Gui Add, Text, x164 y137 w38 h13 Right, Width:
Gui Add, Edit, x206 y133 w59 h20, 100
Gui Add, Text, x278 y137 w44 h13 Right, Height:
Gui Add, Edit, x326 y133 w59 h20, 50

Gui Add, GroupBox, x421 y91 w195 h75, Window position (pixels)
Gui Add, Radio, x433 y112 w48 h13, Fixed
Gui Add, Radio, x487 y112 w62 h13 Checked, Cascade
Gui Add, Text, x431 y137 w14 h13 Right, X:
Gui Add, Edit, x452 y133 w65 h20, 281
Gui Add, Text, x521 y137 w15 h13 Right, Y:
Gui Add, Edit, x541 y133 w65 h20, 23

Gui Add, GroupBox, x158 y169 w249 h52, Console buffer height
Gui Add, CheckBox, x169 y192 w125 h13 Checked, Long console output
Gui Add, Edit, x326 y189 w59 h20, 1000

Gui Add, GroupBox, x421 y169 w195 h52, DOS applications (ntvdm)
Gui Add, Text, x428 y192 w107 h13 Right, 16bit height:
Gui Add, DropDownList, x541 y187 w65, Auto||25 lines|28 lines|43 lines|50 lines

Gui Add, GroupBox, x157 y224 w459 h68, Alignment
Gui Add, CheckBox, x169 y244 w224 h13, Center console in ConEmu workspace
Gui Add, CheckBox, x169 y267 w212 h13, Snap to desktop edges
Gui Add, Text, x377 y244 w68 h13 Right, Pad size:
Gui Add, Edit, x452 y242 w65 h20, 0
Gui Add, Text, x523 y244 w68 h13, pixels
Gui Add, Text, x526 y367 w12 h13 Center Disabled, x

; Appearance
Gui Tab, 3
Gui Add, GroupBox, x149 y33 w479 h70, Multi console
Gui Add, CheckBox, x158 y54 w233 h13 Checked, Multiple consoles in one ConEmu window
Gui Add, CheckBox, x395 y54 w222 h13 Checked, Show buttons (toolbar) in tab bar
Gui Add, CheckBox, x158 y77 w233 h13 Checked, Create confirmation ( Win+W`, toolbar [+] )
Gui Add, CheckBox, x395 y77 w116 h13, Close confirmation
Gui Add, CheckBox, x512 y77 w108 h13, Far Editor/Viewer

Gui Add, GroupBox, x149 y111 w479 h47, Appearance
Gui Add, CheckBox, x158 y132 w210 h13 Checked, Enhance progressbars and scrollbars
Gui Add, CheckBox, x380 y132 w110 h13, Desktop mode
Gui Add, CheckBox, x494 y132 w117 h13, Always on top

Gui Add, GroupBox, x149 y166 w479 h47, Scrollbar
Gui Add, Radio, x158 y187 w45 h13, Hide
Gui Add, Radio, x215 y187 w53 h13, Show
Gui Add, Radio, x281 y187 w50 h13 Checked, Auto
Gui Add, Text, x337 y187 w75 h13 Right, Appear delay:
Gui Add, Edit, x418 y184 w60 h20, 100
Gui Add, Text, x488 y187 w65 h13 Right, Disappear:
Gui Add, Edit, x559 y184 w60 h20, 1000

Gui Add, GroupBox, x149 y221 w479 h96, Caption and border options
Gui Add, CheckBox, x158 y242 w176 h13, Hide caption when maximized
Gui Add, CheckBox, x340 y242 w119 h13, Hide caption always
Gui Add, Text, x157 y267 w81 h13 Right, Frame width:
Gui Add, Edit, x244 y263 w60 h20, -1
Gui Add, Text, x331 y267 w75 h13 Right, Appear delay:
Gui Add, Edit, x412 y263 w60 h20, 2000
Gui Add, Text, x484 y267 w65 h13 Right, Disappear:
Gui Add, Edit, x553 y263 w60 h20, 2000
Gui Add, CheckBox, x158 y291 w176 h13, Always show numbers [n/m]
Gui Add, CheckBox, x340 y291 w284 h13 Checked, Hide caption of child GUI windows started in ConEmu

Gui Add, GroupBox, x149 y324 w479 h47, Quake style
Gui Add, CheckBox, x158 y345 w150 h13, Quake style slide down
Gui Add, CheckBox, x340 y345 w141 h13 Disabled, Auto-hide on focus lose
Gui Add, Text, x484 y345 w65 h13 Right Disabled, Animation:
Gui Add, Edit, x553 y341 w60 h20 Disabled, 300

; Task bar
Gui Tab, 4
Gui Add, GroupBox, x149 y33 w479 h47, Taskbar status area (TSA)
Gui Add, CheckBox, x158 y54 w134 h13, Always show TSA icon
Gui Add, CheckBox, x380 y54 w134 h13, Auto minimize to TSA

Gui Add, GroupBox, x149 y86 w479 h96, Taskbar buttons
Gui Add, Radio, x160 y111 w206 h13 Checked, Show all consoles (Win7 and higher)
Gui Add, Radio, x380 y111 w240 h13, Show all consoles (all OS)
Gui Add, Radio, x160 y132 w210 h13, Active console only (ConEmu window)
Gui Add, Radio, x380 y132 w239 h13, Don't show ConEmu window on Taskbar
Gui Add, CheckBox, x160 y156 w215 h13 Checked, Show Shield overlay (Win7 and higher)

Gui Add, GroupBox, x149 y190 w479 h47, When last console (tab) is closed
Gui Add, Radio, x160 y211 w143 h13 Checked, Close ConEmu window
Gui Add, Radio, x313 y211 w149 h13, Leave ConEmu opened
Gui Add, Radio, x470 y211 w152 h13, Hide ConEmu to the TSA

Gui Add, GroupBox, x149 y246 w479 h93, Minimize ConEmu automatically
Gui Add, CheckBox, x160 y267 w299 h13, Minimize on focus lose (not in Quake style)
Gui Add, GroupBox, x149 y291 w479 h47, When Esc pressed
Gui Add, Radio, x160 y312 w149 h13 Checked, If all consoles closed
Gui Add, Radio, x313 y312 w63 h13, Always
Gui Add, Radio, x385 y312 w57 h13, Never
Gui Add, CheckBox, x470 y312 w152 h13 Checked Disabled, Map Shift+Esc to Esc

; Update
Gui Tab, 5
Gui Add, GroupBox, x149 y33 w479 h44, Update settings
Gui Add, CheckBox, x158 y52 w105 h13, Check on startup
Gui Add, CheckBox, x268 y52 w57 h13, Hourly
Gui Add, CheckBox, x332 y52 w117 h13, Show TSA balloon
Gui Add, Radio, x464 y52 w78 h13 Checked, Stable only
Gui Add, Radio, x551 y52 w63 h13, Latest

Gui Add, GroupBox, x149 y80 w479 h44
Gui Add, CheckBox, x158 y78 w77 h16, Use proxy
Gui Add, Text, x158 y98 w63 h13 Disabled, Server:port
Gui Add, Edit, x227 y94 w135 h21 Disabled
Gui Add, Text, x364 y98 w29 h13 Right Disabled, User
Gui Add, Edit, x397 y94 w81 h21 Disabled
Gui Add, Text, x481 y98 w51 h13 Right Disabled, Password
Gui Add, Edit, x538 y94 w81 h21 Disabled

Gui Add, GroupBox, x151 y127 w479 h46, Download path
Gui Add, Edit, x158 y143 w240 h21, `%TEMP`%\ConEmu
Gui Add, Button, x403 y142 w23 h21, ...
Gui Add, CheckBox, x436 y145 w170 h16, Leave downloaded packages

Gui Add, GroupBox, x152 y176 w479 h114, Update command (`%1 - package`, `%2 - ConEmu.exe folder`, `%3 - x86/x64`, `%4 - PID)
Gui Add, Radio, x161 y192 w227 h16 Disabled, Installer (ConEmuSetup.exe)
Gui Add, Edit, x158 y211 w465 h23, "`%1" /p:`%3 /qr
Gui Add, Radio, x161 y239 w339 h16 Checked Disabled, 7-Zip archieve (ConEmu.7z)`, WinRar or 7-Zip required
Gui Add, Edit, x158 y259 w435 h21, "C:\Program Files\7-Zip\7zg.exe" x -y "`%1"
Gui Add, Button, x601 y259 w23 h21, ...

Gui Add, GroupBox, x151 y293 w479 h49, Post-update command
Gui Add, Edit, x158 y311 w465 h21, echo Last successful update>ConEmuUpdate.info && date /t>>ConEmuUpdate.info && time /t>>ConEmuUpdate.info

Gui Add, GroupBox, x151 y345 w479 h46, ConEmu latest version location info
Gui Add, Edit, x158 y363 w465 h21 ReadOnly, http://conemu-maximus5.googlecode.com/svn/trunk/ConEmu/version.ini

; Startup
Gui Tab, 6
Gui Add, GroupBox, x149 y33 w479 h187, Startup options (may be overrided with "/cmd" argument of ConEmu.exe)
Gui Add, Radio, x157 y55 w435 h13 Checked, Command line
Gui Add, Edit, x175 y72 w417 h20
Gui Add, Button, x598 y72 w23 h21, ...
Gui Add, Radio, x157 y96 w435 h13, Tasks file
Gui Add, Edit, x175 y112 w417 h20 Disabled
Gui Add, Button, x598 y111 w23 h21 Disabled, ...
Gui Add, Radio, x157 y137 w435 h13, Specified named task
Gui Add, DropDownList, x175 y153 w444 Disabled, <None>||
Gui Add, Radio, x157 y177 w435 h13 Disabled, Auto save/restore opened tabs
Gui Add, CheckBox, x175 y195 w135 h13 Disabled, Far folders also
Gui Add, CheckBox, x310 y195 w150 h13 Disabled, Far editors/viewers also

Gui Add, GroupBox, x149 y220 w479 h185 Disabled, Selected task contents (view only`, change on Tasks page)
Gui Add, Text, x157 y239 w462 h42 Disabled, Commands (application`, arguments`, "-new_console" params). Command delimiter - empty line`nEach command creates tab in ConEmu when group started`nMark active console tab with '>' sign. Start console 'As Administrator' with '*' sign
Gui Add, Edit, x155 y283 w464 h115 Multi ReadOnly Disabled

; Tasks
Gui Tab, 7
Gui Add, GroupBox, x149 y33 w479 h323, Predefined tasks (command groups)
Gui Add, ListBox, x157 y51 w140 h239
Gui Add, Button, x157 y296 w140 h23, Reload...
Gui Add, Button, x157 y324 w26 h23, +
Gui Add, Button, x184 y324 w26 h23, -
Gui Add, Button, x214 y324 w41 h23, Up
Gui Add, Button, x256 y324 w41 h23, Down
Gui Add, Text, x310 y49 w311 h26, Task name (alias)`, surrounded by {...}`, used in «[+] menu»`, «Recreate dialog» or «/cmd» argument of ConEmu.exe
Gui Add, Edit, x307 y78 w312 h20 Disabled
Gui Add, Text, x310 y103 w312 h13, Task parameters. Example: /dir "C:\" /icon "cmd.exe" /single
Gui Add, Edit, x308 y119 w312 h20 Disabled
Gui Add, Text, x310 y146 w312 h67, Commands (application`, arguments`, "-new_console" params)`nDelimit commands with empty lines`nEach command creates tab in ConEmu when group started`nMark active console tab with '>' sign`nStart console 'As Administrator' with '*' sign
Gui Add, Edit, x307 y215 w312 h104 Multi Disabled
Gui Add, Text, x302 y330 w32 h13 Right Disabled, Add:
Gui Add, Button, x341 y324 w51 h23 Disabled, Tab...
Gui Add, Button, x394 y324 w80 h23 Disabled, Startup dir...
Gui Add, Button, x475 y324 w71 h23 Disabled, File path...
Gui Add, Button, x548 y324 w74 h23 Disabled, Active tabs

Gui Add, GroupBox, x149 y359 w479 h47, Windows 7 taskbar (Jump list)
Gui Add, CheckBox, x158 y380 w171 h13, Add ConEmu tasks to taskbar
Gui Add, CheckBox, x335 y380 w185 h13, Add commands from history`, too
Gui Add, Button, x532 y374 w87 h23, Update Now!

; ComSpec
Gui Tab, 8
Gui Add, GroupBox, x149 y33 w479 h232, Used command processor
Gui Add, Radio, x157 y51 w267 h13 Checked, Auto (tcc - if installed`, `%ComSpec`% - otherwise)
Gui Add, Radio, x427 y51 w147 h13, `%ComSpec`% (env.var.)
Gui Add, Radio, x578 y51 w47 h13, cmd
Gui Add, Radio, x157 y72 w462 h13, Explicit executable (env.var. of ConEmu.exe allowed)
Gui Add, Edit, x172 y90 w425 h20
Gui Add, Button, x602 y90 w20 h18, ...
Gui Add, GroupBox, x157 y114 w378 h46, Choose preferred command processor platform (bits)
Gui Add, Radio, x167 y133 w81 h13 Checked, Same as OS
Gui Add, Radio, x263 y133 w168 h13, Same as running application
Gui Add, Radio, x437 y133 w84 h13, x32 always
Gui Add, Button, x547 y129 w75 h23, Test
Gui Add, CheckBox, x160 y168 w464 h13, Set ComSpec environment variable for child processes to 'tcc.exe'
Gui Add, Text, x160 y194 w141 h13, Cmd.exe output codepage:
Gui Add, DropDownList, x305 y190 w122, Undefined||Automatic|Unicode (/U)|OEM (/A)
Gui Add, CheckBox, x160 y221 w464 h13 Checked, Add `%ConEmuBaseDir`% to `%PATH`%
Gui Add, CheckBox, x160 y242 w464 h13, Support UNC paths in cmd.exe (\\server\share\folder)

Gui Add, GroupBox, x149 y304 w479 h106, Automatic attach of cmd && Tcc/Le to ConEmu (new window will be started if not found)
Gui Add, Text, x160 y320 w462 h26, [HKEY_CURRENT_USER\Software\Microsoft\Command Processor]`nCurrent command stored in registry «AutoRun» (HKLM value is not processed here):
Gui Add, Edit, x157 y351 w462 h21 ReadOnly
Gui Add, CheckBox, x158 y382 w150 h16, Force new ConEmu window
Gui Add, Button, x332 y377 w150 h23, Register ConEmu autorun
Gui Add, Button, x488 y377 w75 h23, Unregister
Gui Add, Button, x568 y377 w51 h23, Clear

; Features
Gui Tab, 9
Gui Add, GroupBox, x149 y33 w479 h91, Miscellaneous options
Gui Add, CheckBox, x158 y52 w134 h13 Checked, Auto register fonts
Gui Add, CheckBox, x158 y75 w131 h13 Checked, Debug steps in caption
Gui Add, CheckBox, x158 y98 w179 h13 Checked, Show «was hidden» warning
Gui Add, CheckBox, x341 y52 w134 h13 Checked, Monitor console lang
Gui Add, CheckBox, x341 y75 w131 h13, Sleep in background
Gui Add, CheckBox, x341 y98 w134 h13, Disable all flashing
Gui Add, CheckBox, x490 y52 w111 h13, Show real console
Gui Add, Button, x602 y51 w20 h18, ...
Gui Add, CheckBox, x490 y75 w131 h13 Checked, Focus in child windows

Gui Add, GroupBox, x149 y132 w479 h73, In-console options
Gui Add, CheckBox, x160 y153 w134 h13, Inject ConEmuHk
Gui Add, CheckBox, x160 y177 w179 h13 Checked, ANSI X3.64 / xterm 256 colors
Gui Add, CheckBox, x341 y151 w114 h13, DosBox (DOS apps)
Gui Add, CheckBox, x341 y177 w113 h13 Disabled, Portable registry
Gui Add, Button, x463 y176 w20 h18 Disabled, ...
Gui Add, CheckBox, x490 y151 w131 h13, Use Clink in prompt

; Text cursor
Gui Tab, 10
Gui Add, GroupBox, x149 y33 w479 h111, Active console Text Cursor
Gui Add, Radio, x161 y55 w143 h13, &Horizontal (as console)
Gui Add, Radio, x317 y55 w122 h13 Checked, &Vertical (as GUI)
Gui Add, Radio, x457 y55 w71 h13, Block
Gui Add, Radio, x533 y55 w87 h13, Rectangle
Gui Add, CheckBox, x161 y83 w288 h13 Checked, Co&lor (inverse screen part under cursor shape)
Gui Add, CheckBox, x457 y83 w75 h13 Checked, Blinking
Gui Add, CheckBox, x161 y111 w132 h13, Fixed cursor size
Gui Add, Edit, x299 y107 w60 h20, 25
Gui Add, Text, x373 y111 w57 h13, (5-100) `%
Gui Add, Text, x449 y111 w75 h13 Right, Min size (pix):
Gui Add, Edit, x533 y107 w60 h20, 2

Gui Add, GroupBox, x149 y163 w479 h111
Gui Add, CheckBox, x161 y163 w180 h13 Checked, Inactive console Text Cursor
Gui Add, Radio, x161 y185 w143 h13, Horizontal (as console)
Gui Add, Radio, x317 y185 w122 h13, Vertical (as GUI)
Gui Add, Radio, x457 y185 w71 h13, Block
Gui Add, Radio, x533 y185 w87 h13 Checked, Rectangle
Gui Add, CheckBox, x161 y213 w288 h13 Checked, Color (inverse screen part under cursor shape)
Gui Add, CheckBox, x457 y213 w75 h13, Blinking
Gui Add, CheckBox, x161 y241 w132 h13, Fixed cursor size
Gui Add, Edit, x299 y237 w60 h20, 25
Gui Add, Text, x373 y241 w57 h13, (5-100) `%
Gui Add, Text, x449 y241 w75 h13 Right, Min size (pix):
Gui Add, Edit, x533 y237 w60 h20, 2

; Colors
Gui Tab, 11
Gui Add, GroupBox, x149 y33 w479 h140, Standard colors: «RRR GGG BBB» (dec)`, «#RRGGBB» (hex)`, «0xBBGGRR» (hex)
Gui Add, Text, x161 y55 w12 h13 Right, 0.
Gui Add, Text, hWndh0 x179 y51 w18 h20 +0x1000
Gui Add, Edit, x199 y51 w68 h20 +E0x20000 -E0x200, 0 0 0
Gui Add, Text, x161 y77 w12 h13 Right, 1.
Gui Add, Text, hWndh1 x179 y72 w18 h20 +0x1000
Gui Add, Edit, x199 y72 w68 h20 +E0x20000 -E0x200, 0 0 128
Gui Add, Text, x161 y98 w12 h13 Right, 2.
Gui Add, Text, hWndh2 x179 y93 w18 h20 +0x1000
Gui Add, Edit, x199 y93 w68 h20 +E0x20000 -E0x200, 35 112 131
Gui Add, Text, x161 y119 w12 h13 Right, 3.
Gui Add, Text, hWndh3 x179 y114 w18 h20 +0x1000
Gui Add, Edit, x199 y114 w68 h20 +E0x20000 -E0x200, 0 128 128
Gui Add, Text, x277 y55 w12 h13 Right, 4.
Gui Add, Text, hWndh4 x295 y51 w18 h20 +0x1000
Gui Add, Edit, x316 y51 w68 h20 +E0x20000 -E0x200, 128 0 0
Gui Add, Text, x277 y77 w12 h13 Right, 5.
Gui Add, Text, hWndh5 x295 y72 w18 h20 +0x1000
Gui Add, Edit, x316 y72 w68 h20 +E0x20000 -E0x200, 1 36 86
Gui Add, Text, x277 y98 w12 h13 Right, 6.
Gui Add, Text, hWndh6 x295 y93 w18 h20 +0x1000
Gui Add, Edit, x316 y93 w68 h20 +E0x20000 -E0x200, 238 237 240
Gui Add, Text, x277 y119 w12 h13 Right, 7.
Gui Add, Text, hWndh7 x295 y114 w18 h20 +0x1000
Gui Add, Edit, x316 y114 w68 h20 +E0x20000 -E0x200, 192 192 192
Gui Add, Text, x394 y55 w12 h13 Right, 8.
Gui Add, Text, hWndh8 x412 y51 w18 h20 +0x1000
Gui Add, Edit, x431 y51 w68 h20 +E0x20000 -E0x200, 128 128 128
Gui Add, Text, x394 y77 w12 h13 Right, 9.
Gui Add, Text, hWndh9 x412 y72 w18 h20 +0x1000
Gui Add, Edit, x431 y72 w68 h20 +E0x20000 -E0x200, 0 0 255
Gui Add, Text, x386 y98 w20 h13 Right, 10.
Gui Add, Text, hWndh10 x412 y93 w18 h20 +0x1000
Gui Add, Edit, x431 y93 w68 h20 +E0x20000 -E0x200, 0 255 0
Gui Add, Text, x386 y119 w20 h13 Right, 11.
Gui Add, Text, hWndh11 x412 y114 w18 h20 +0x1000
Gui Add, Edit, x431 y114 w68 h20 +E0x20000 -E0x200, 0 255 255
Gui Add, Text, x502 y55 w20 h13 Right, 12.
Gui Add, Text, hWndh12 x532 y51 w18 h20 +0x1000
Gui Add, Edit, x550 y51 w68 h20 +E0x20000 -E0x200, 255 0 0
Gui Add, Text, x502 y77 w20 h13 Right, 13.
Gui Add, Text, hWndh13 x532 y72 w18 h20 +0x1000
Gui Add, Edit, x550 y72 w68 h20 +E0x20000 -E0x200, 255 0 255
Gui Add, Text, x502 y98 w20 h13 Right, 14.
Gui Add, Text, hWndh14 x532 y93 w18 h20 +0x1000
Gui Add, Edit, x550 y93 w68 h20 +E0x20000 -E0x200, 255 255 0
Gui Add, Text, x502 y119 w20 h13 Right, 15.
Gui Add, Text, hWndh15 x532 y114 w18 h20 +0x1000
Gui Add, Edit, x550 y114 w68 h20 +E0x20000 -E0x200, 255 255 255

Colors := ["0x000000"
         , "0x000080"
         , "0x237083"
         , "0x008080"
         , "0x800000"
         , "0x800080"
         , "0x808000"
         , "0xC0C0C0"
         , "0x808080"
         , "0x0000FF"
         , "0x00FF00"
         , "0x00FFFF"
         , "0xFF0000"
         , "0xFF00FF"
         , "0xFFFF00"
         , "0xFFFFFF"]

For Index, h in [h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13,h14,h15]
    ControlColor(h, hWnd, Colors[Index])

Gui Add, Text, x158 y145 w36 h13 Right, Text:
Gui Add, DropDownList, x199 y142 w68, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14|#15||Auto
Gui Add, Text, x280 y145 w32 h13 Right, Back:
Gui Add, DropDownList, x316 y142 w68, # 0|# 1|# 2||# 3|# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14|#15|Auto
Gui Add, Text, x389 y145 w38 h13 Right, Popup:
Gui Add, DropDownList, x431 y142 w68, # 0|# 1|# 2|# 3||# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14|#15|Auto
Gui Add, Text, x509 y145 w36 h13 Right, Back:
Gui Add, DropDownList, x550 y142 w68, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14|#15||Auto

Gui Add, GroupBox, x149 y181 w479 h135, Extended foreground colors (same format as Standard colors)
Gui Add, CheckBox, x182 y197 w242 h16, Extend foreground colors with background
Gui Add, DropDownList, x431 y194 w68 Disabled, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14||#15
Gui Add, Text, x154 y228 w20 h13 Right, 16.
Gui Add, Text, hWndh16 x179 y223 w18 h20 +0x1000
Gui Add, Edit, x200 y223 w68 h20 Disabled +E0x20000 -E0x200, 0 0 0
Gui Add, Text, x154 y249 w20 h13 Right, 17.
Gui Add, Text, hWndh17 x179 y244 w18 h20 +0x1000
Gui Add, Edit, x200 y244 w68 h20 Disabled +E0x20000 -E0x200, 0 0 128
Gui Add, Text, x154 y270 w20 h13 Right, 18.
Gui Add, Text, hWndh18 x179 y265 w18 h20 +0x1000
Gui Add, Edit, x200 y265 w68 h20 Disabled +E0x20000 -E0x200, 0 128 0
Gui Add, Text, x154 y291 w20 h13 Right, 19.
Gui Add, Text, hWndh19 x179 y286 w18 h20 +0x1000
Gui Add, Edit, x200 y286 w68 h20 Disabled +E0x20000 -E0x200, 0 128 128
Gui Add, Text, x269 y228 w20 h13 Right, 20.
Gui Add, Text, hWndh20 x296 y223 w18 h20 +0x1000
Gui Add, Edit, x317 y223 w68 h20 Disabled +E0x20000 -E0x200, 128 0 0
Gui Add, Text, x269 y249 w20 h13 Right, 21.
Gui Add, Text, hWndh21 x296 y244 w18 h20 +0x1000
Gui Add, Edit, x317 y244 w68 h20 Disabled +E0x20000 -E0x200, 1 36 86
Gui Add, Text, x269 y270 w20 h13 Right, 22.
Gui Add, Text, hWndh22 x296 y265 w18 h20 +0x1000
Gui Add, Edit, x317 y265 w68 h20 Disabled +E0x20000 -E0x200, 238 237 240
Gui Add, Text, x269 y291 w20 h13 Right, 23.
Gui Add, Text, hWndh23 x296 y286 w18 h20 +0x1000
Gui Add, Edit, x317 y286 w68 h20 Disabled +E0x20000 -E0x200, 192 192 192
Gui Add, Text, x386 y228 w20 h13 Right, 24.
Gui Add, Text, hWndh24 x413 y223 w18 h20 +0x1000
Gui Add, Edit, x431 y223 w68 h20 Disabled +E0x20000 -E0x200, 128 128 128
Gui Add, Text, x386 y249 w20 h13 Right, 25.
Gui Add, Text, hWndh25 x413 y244 w18 h20 +0x1000
Gui Add, Edit, x431 y244 w68 h20 Disabled +E0x20000 -E0x200, 0 0 255
Gui Add, Text, x386 y270 w20 h13 Right, 26.
Gui Add, Text, hWndh26 x413 y265 w18 h20 +0x1000
Gui Add, Edit, x431 y265 w68 h20 Disabled +E0x20000 -E0x200, 0 255 0
Gui Add, Text, x386 y291 w20 h13 Right, 27.
Gui Add, Text, hWndh27 x413 y286 w18 h20 +0x1000
Gui Add, Edit, x431 y286 w68 h20 Disabled +E0x20000 -E0x200, 0 255 255
Gui Add, Text, x503 y228 w20 h13 Right, 28.
Gui Add, Text, hWndh28 x533 y223 w18 h20 +0x1000
Gui Add, Edit, x551 y223 w68 h20 Disabled +E0x20000 -E0x200, 255 0 0
Gui Add, Text, x503 y249 w20 h13 Right, 29.
Gui Add, Text, hWndh29 x533 y244 w18 h20 +0x1000
Gui Add, Edit, x551 y244 w68 h20 Disabled +E0x20000 -E0x200, 255 0 255
Gui Add, Text, x503 y270 w20 h13 Right, 30.
Gui Add, Text, hWndh30 x533 y265 w18 h20 +0x1000
Gui Add, Edit, x551 y265 w68 h20 Disabled +E0x20000 -E0x200, 255 255 0
Gui Add, Text, x503 y291 w20 h13 Right, 31.
Gui Add, Text, hWndh31 x533 y286 w18 h20 +0x1000
Gui Add, Edit, x551 y286 w68 h20 Disabled +E0x20000 -E0x200, 255 255 255

For Index, h in [h16,h17,h18,h19,h20,h21,h22,h23,h24,h25,h26,h27,h28,h29,h30,h31]
    ControlColor(h, hWnd, Colors[Index])
ControlColor(h18, hWnd, "0x008000")

Gui Add, Text, x154 y324 w53 h13, Schemes:
Gui Add, ComboBox, x214 y320 w257, <Current color scheme>||<Default color scheme (Windows standard)>|<Gamma 1 (for use with dark monitors)>|<PowerShell>|<Murena scheme>|<Solarized>|<Solarized (John Doe)>|<Solarized Light>|<Solarized Me>|<Standard VGA>|<tc-maxx>|<Terminal.app>|<xterm>|<Twilight>|<Zenburn>|<Ubuntu>
Gui Add, Button, x475 y319 w75 h23 Disabled, Save
Gui Add, Button, x553 y319 w75 h23 Disabled, Delete...

Gui Add, GroupBox, x149 y345 w479 h47, Graphic enhancement
Gui Add, CheckBox, x155 y366 w117 h13 Checked, Fade when inactive
Gui Add, Text, x274 y366 w29 h13 Right, Low:
Gui Add, Edit, x307 y363 w33 h20, 0
Gui Add, Text, x347 y366 w30 h13 Right, High:
Gui Add, Edit, x380 y363 w30 h20, 208
Gui Add, CheckBox, x427 y366 w194 h13 Checked, TrueMod (24bit color) support

; Transparency
Gui Tab, 12
Gui Add, GroupBox, x149 y33 w479 h128, Alpha transparency
Gui Add, CheckBox, x155 y54 w465 h13, Active window transparency
Gui Add, Text, x154 y80 w77 h13 Right, Transparent
Gui Add, Slider, x245 y80 w315 h20 Range40-255 Center, 255
Gui Add, Text, x574 y80 w47 h13, Opaque
Gui Add, CheckBox, x155 y107 w465 h16, Use separate transparency value for inactive window
Gui Add, Text, x154 y132 w77 h13 Right Disabled, Transparent
Gui Add, Slider, x245 y132 w315 h20 Range0-255 Center Disabled, 255
Gui Add, Text, x574 y132 w47 h13 Disabled, Opaque

Gui Add, GroupBox, x149 y171 w479 h75, Static transparency
Gui Add, CheckBox, x155 y194 w146 h13, «Color key» transparency
Gui Add, Edit, x310 y190 w68 h20, 1 1 1
Gui Add, Text, hWndhColorKey x383 y190 w30 h20 +0x1000
ControlColor(hColorKey, hWnd, "0x000000")
Gui Add, CheckBox, x155 y220 w464 h13, «User screen» transparency (Far Manager feature)

; Tabs
Gui Tab, 13
Gui Add, GroupBox, x149 y33 w479 h122, Tabs (panels`, editors`, viewers)
Gui Add, Radio, x158 y54 w98 h13 Checked, Always show
Gui Add, Radio, x263 y54 w86 h13, Auto show
Gui Add, Radio, x386 y54 w96 h13, Don't show
Gui Add, CheckBox, x493 y54 w113 h13, Tabs on bottom
Gui Add, CheckBox, x158 y77 w96 h13 Checked, Internal CtrlTab
Gui Add, CheckBox, x263 y77 w99 h13 Checked, Lazy tab switch
Gui Add, CheckBox, x386 y77 w89 h13 Checked, Recent mode
Gui Add, CheckBox, x493 y77 w113 h13 Disabled, Hide disabled tabs
Gui Add, CheckBox, x158 y99 w84 h13 Checked, Far windows
Gui Add, CheckBox, x263 y99 w116 h13, Active console only
Gui Add, CheckBox, x386 y99 w233 h13 Checked, «Host-key»+Number iterates Far windows
Gui Add, Text, x175 y125 w63 h13 Right, Tabs font:
Gui Add, ComboBox, x247 y122 w161, Segoe UI Semibold||...
Gui Add, Text, x415 y125 w12 h13 Center, x
Gui Add, ComboBox, x431 y122 w44, 5|6|7|8|9|10|11|12|14|16||18|19|20|24|26|28|30|32
Gui Add, Text, x482 y125 w48 h13 Right, Charset:
Gui Add, DropDownList, x539 y122 w81, ANSI||Arabic|Baltic|Chinese Big 5|Default|East Europe|GB 2312|Greek|Hebrew|Hangul|Johab|Mac|OEM|Russian|Shiftjis|Symbol|Thai|Turkish|Vietnamese

Gui Add, GroupBox, x149 y164 w479 h138, Tab templates
Gui Add, Text, x158 y182 w464 h28, `%s - Title`, `%c - Console number`, `%p - Active PID`, `%n - Name of active process`, `%`% - `%`,`n`%i - Far window number (you can see it in standard F12 menu)
Gui Add, Text, x155 y218 w45 h13 Right, Console:
Gui Add, Edit, x206 y241 w60 h20, `%s
Gui Add, Text, x280 y218 w104 h13, Skip words from title:
Gui Add, Edit, x386 y213 w234 h20, Administrator:|Администратор:
Gui Add, Text, x155 y244 w45 h13 Right, Panels:
Gui Add, Edit, x206 y213 w60 h20, `%s
Gui Add, Text, x271 y244 w44 h13 Right, Viewer:
Gui Add, Edit, x322 y241 w60 h20, <`%c.`%i>[`%s]
Gui Add, Text, x392 y244 w33 h13 Right, Editor:
Gui Add, Edit, x431 y241 w60 h20, <`%c.`%i>{`%s}
Gui Add, Text, x499 y244 w54 h13 Right, Modified:
Gui Add, Edit, x560 y241 w60 h20, <`%c.`%i>[`%s] *
Gui Add, Text, x154 y276 w161 h13 Right, Maximum tab width (in chars):
Gui Add, Edit, x322 y273 w60 h20, 20
Gui Add, Radio, x394 y276 w83 h13 Checked, Admin shield
Gui Add, Radio, x478 y276 w51 h13, suffix
Gui Add, Edit, x535 y273 w86 h20,  (Admin)

; Status bar
Gui Tab, 14
Gui Add, GroupBox, x149 y33 w479 h371
Gui Add, CheckBox, x160 y33 w113 h13 Checked, Show status bar
Gui Add, GroupBox, x157 y51 w461 h96, Font and color
Gui Add, Text, x164 y70 w38 h13 Right, Name:
Gui Add, ComboBox, x209 y67 w173, Tahoma||...
Gui Add, Text, x389 y70 w12 h13 Center, x
Gui Add, ComboBox, x407 y67 w44, 5|6|7|8|9|10|11|12|14||16|18|19|20|24|26|28|30|32
Gui Add, Text, x457 y70 w54 h13 Right, Charset:
Gui Add, DropDownList, x518 y67 w90, ANSI||Arabic|Baltic|Chinese Big 5|Default|East Europe|GB 2312|Greek|Hebrew|Hangul|Johab|Mac|OEM|Russian|Shiftjis|Symbol|Thai|Turkish|Vietnamese
Gui Add, Text, x169 y98 w33 h13 Right, Back:
Gui Add, Edit, x209 y96 w68 h20 +E0x20000 -E0x200, 64 64 64
Gui Add, Text, hWndhSBBack x281 y96 w18 h20 +0x1000
ControlColor(hSBBack, hWnd, "0x404040")
Gui Add, Text, x307 y98 w47 h13 Right, Light:
Gui Add, Edit, x361 y96 w68 h20 +E0x20000 -E0x200, 255 255 255
Gui Add, Text, hWndhSBLight x433 y96 w18 h20 +0x1000
ControlColor(hSBLight, hWnd, "0xFFFFFF")
Gui Add, Text, x476 y98 w35 h13 Right, Dark:
Gui Add, Edit, x518 y96 w68 h20 +E0x20000 -E0x200, 160 160 160
Gui Add, Text, hWndhSBDark x590 y96 w18 h20 +0x1000
ControlColor(hSBDark, hWnd, "0xA0A0A0")
Gui Add, Text, x169 y125 w33 h13 Right, Style:
Gui Add, CheckBox, x209 y125 w144 h13 Checked, Horizontal separator
Gui Add, CheckBox, x361 y125 w134 h13, Vertical separators
Gui Add, CheckBox, x518 y125 w92 h13, System colors
Gui Add, Text, x160 y155 w90 h13, Available columns:
Gui Add, ListBox, x157 y171 w206 h223 +0x100, Console title|Current input HKL|ConEmu window rectangle|ConEmu window size|ConEmu window client area size|ConEmu window work area size|ConEmu window style|ConEmu window extended styles|Foreground HWND|Focus HWND|Cursor information|ConEmu GUI PID|ConEmu GUI HWND|ConEmu GUI View HWND|Console server HWND
Gui Add, Button, x370 y185 w35 h23, >>
Gui Add, Button, x370 y211 w35 h23, >
Gui Add, Button, x370 y241 w35 h23, <
Gui Add, Button, x370 y267 w35 h23, <<
Gui Add, Text, x415 y155 w87 h13, Selected columns:
Gui Add, ListBox, x412 y171 w206 h223 +0x100, Active process|Active VCon|Create new console|Synchronize cur dir|Caps Lock state|Num Lock state|Scroll Lock state|Active console buffer|Console visible rectangle|Console visible size|Console buffer size|Cursor column|Cursor row|Cursor size / visibility|Console server PID|Transparency|Size grip

; Integration
Gui Tab, 15
Gui Add, GroupBox, x149 y33 w479 h132, ConEmu Here - Explorer context menu integration
Gui Add, Text, x160 y54 w59 h13, Menu item:
Gui Add, ComboBox, x224 y49 w171, ConEmu Here||
Gui Add, Text, x403 y54 w89 h13 Right, Configuration:
Gui Add, Edit, x500 y49 w119 h21
Gui Add, Text, x160 y81 w59 h13, Command:
Gui Add, Edit, x224 y78 w395 h21, cmd -cur_console:n
Gui Add, Text, x160 y111 w59 h13, Icon file:
Gui Add, Edit, x224 y106 w395 h21, C:\Software\ConEmu\ConEmu.exe`,0
Gui Add, Button, x463 y132 w75 h23, Register
Gui Add, Button, x544 y132 w75 h23, Unregister

Gui Add, GroupBox, x149 y168 w479 h132, ConEmu Inside - Explorer context menu integration
Gui Add, Text, x160 y189 w59 h13, Menu item:
Gui Add, ComboBox, x224 y185 w171, ConEmu Inside||
Gui Add, Text, x403 y189 w89 h13 Right, Configuration:
Gui Add, Edit, x500 y185 w119 h21, shell
Gui Add, Text, x160 y216 w59 h13, Command:
Gui Add, Edit, x224 y213 w395 h21, powershell -cur_console:n
Gui Add, Text, x160 y242 w59 h13, Icon file:
Gui Add, Edit, x224 y239 w395 h21, powershell.exe
Gui Add, CheckBox, x158 y270 w59 h16, Sync dir
Gui Add, Edit, x224 y265 w216 h21
Gui Add, Button, x461 y265 w75 h23, Register
Gui Add, Button, x544 y265 w75 h23, Unregister

Gui Add, GroupBox, x149 y304 w479 h104, WARNING!!! Enabling this option may cause false alarms in antiviral programs!!!
Gui Add, CheckBox, x157 y322 w312 h13, Force ConEmu as default terminal for console applications
Gui Add, CheckBox, x476 y322 w144 h13, Register on OS startup
Gui Add, Text, x158 y340 w459 h13, List of hooked executables delimited with "|" (e.g. "explorer.exe|devenv.exe|totalcmd.exe"):
Gui Add, Edit, x157 y358 w462 h21, explorer.exe
Gui Add, Text, x158 y387 w77 h13, Confirm close:
Gui Add, Radio, x233 y387 w47 h13, Auto
Gui Add, Radio, x281 y387 w57 h13 Checked, Always
Gui Add, Radio, x340 y387 w51 h13, Never
Gui Add, CheckBox, x395 y387 w228 h13, Don't use ConEmuHk.dll in started console

; App distinct
Gui Tab, 16
Gui Add, GroupBox, x149 y33 w479 h377 +E0x20, Application distinct settings
Gui Add, ListBox, x157 y51 w378 h72
Gui Add, Button, x541 y51 w38 h23, +
Gui Add, Button, x580 y51 w38 h23, -
Gui Add, Button, x541 y75 w38 h23, Up
Gui Add, Button, x580 y75 w38 h23, Down
Gui Add, Button, x541 y99 w77 h23, Reload...
Gui Add, Radio, x160 y129 w71 h13 Disabled, Elevated
Gui Add, Radio, x238 y129 w92 h13 Disabled, Non elevated
Gui Add, Radio, x334 y129 w135 h13 Checked Disabled, Elevation don't matter
Gui Add, Text, x158 y146 w311 h13 Disabled, Executables`, delimited by "|"`, e.g. "tcc.exe|cmd.exe":
Gui Add, Edit, x157 y163 w461 h20 Disabled

Gui AppDistinct: New, +ParentSettings -Caption
Gui Add, GroupBox, x159 y190 w437 h44
Gui Add, CheckBox, x168 y190 w129 h13 Disabled, Extend fonts override
Gui Add, CheckBox, x168 y210 w57 h16 Disabled, Extend
Gui Add, Text, x225 y210 w29 h13 Right Disabled, Bold:
Gui Add, DropDownList, x255 y205 w39 Disabled,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|None
Gui Add, Text, x297 y210 w32 h13 Right Disabled, Italic:
Gui Add, DropDownList, x330 y205 w39 Disabled,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|None
Gui Add, Text, x370 y210 w48 h13 Right Disabled, Replace:
Gui Add, DropDownList, x420 y205 w39 Disabled,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|None
Gui Add, GroupBox, x159 y240 w437 h140
Gui Add, CheckBox, x168 y240 w99 h13 Disabled, Cursor override
Gui Add, Radio, x168 y258 w137 h13 Disabled, &Horizontal (as console)
Gui Add, Radio, x307 y258 w105 h13 Disabled, &Vertical (as GUI)
Gui Add, Radio, x418 y258 w56 h13 Disabled, Block
Gui Add, Radio, x474 y258 w87 h13 Disabled, Rectangle
Gui Add, CheckBox, x168 y286 w57 h13 Disabled, Co&lor
Gui Add, CheckBox, x231 y286 w68 h13 Disabled, Blinking
Gui Add, CheckBox, x307 y286 w50 h13 Disabled, Fixed
Gui Add, Edit, x357 y283 w38 h20 Disabled
Gui Add, Text, x403 y286 w57 h13 Disabled, (5-100) `%
Gui Add, Text, x462 y286 w81 h13 Right Disabled, Min size (pix):
Gui Add, Edit, x546 y283 w38 h20 Disabled
Gui Add, GroupBox, x159 y309 w437 h72
Gui Add, CheckBox, x168 y309 w180 h13 Disabled, Inactive console Text Cursor
Gui Add, Radio, x168 y331 w137 h13 Disabled, Horizontal (as console)
Gui Add, Radio, x307 y331 w105 h13 Disabled, Vertical (as GUI)
Gui Add, Radio, x418 y331 w56 h13 Disabled, Block
Gui Add, Radio, x474 y331 w87 h13 Disabled, Rectangle
Gui Add, CheckBox, x168 y354 w57 h13 Disabled, Color
Gui Add, CheckBox, x231 y354 w68 h13 Disabled, Blinking
Gui Add, CheckBox, x307 y354 w50 h13 Disabled, Fixed
Gui Add, Edit, x357 y351 w38 h20 Disabled
Gui Add, Text, x403 y354 w57 h13 Disabled, (5-100) `%
Gui Add, Text, x462 y354 w81 h13 Right Disabled, Min size (pix):
Gui Add, Edit, x541 y351 w38 h20 Disabled
Gui Add, GroupBox, x159 y387 w437 h49
Gui Add, CheckBox, x168 y387 w131 h13 Disabled, Color palette override
Gui Add, DropDownList, x168 y405 w419 Disabled, <Current color scheme>||<Default color scheme (Windows standard)>|<Gamma 1 (for use with dark monitors)>|<PowerShell>|<Murena scheme>|<Solarized>|<Solarized (John Doe)>|<Solarized Light>|<Solarized Me>|<Standard VGA>|<tc-maxx>|<Terminal.app>|<xterm>|<Twilight>|<Zenburn>|<Ubuntu>
Gui Add, GroupBox, x159 y442 w437 h218
Gui Add, CheckBox, x168 y442 w185 h13 Disabled, Clipboard (Copy/Paste) override
Gui Add, GroupBox, x168 y458 w419 h42 Disabled, Copying text override
Gui Add, CheckBox, x177 y478 w132 h13 Disabled, Detect text line ends
Gui Add, CheckBox, x309 y478 w45 h13 Disabled, Bash
Gui Add, CheckBox, x361 y478 w116 h13 Disabled, Trim trailing spaces
Gui Add, Text, x489 y478 w24 h13 Right Disabled, EOL:
Gui Add, DropDownList, x519 y473 w60 Disabled
Gui Add, GroupBox, x168 y504 w419 h41 Disabled, Starting selection with arrows
Gui Add, CheckBox, x177 y522 w404 h13 Disabled, Start selection with Shift+Arrow (Text = Left/Right`, Block = Up/Down)
Gui Add, GroupBox, x168 y548 w419 h41 Disabled, Pasting text override (with exception of Far Manager)
Gui Add, CheckBox, x177 y565 w153 h13 Disabled, All lines (default Shift+Ins)
Gui Add, CheckBox, x343 y565 w143 h13 Disabled, First line (default Ctrl+V)
Gui Add, GroupBox, x168 y591 w419 h60 Disabled, Prompt override
Gui Add, CheckBox, x177 y609 w402 h13 Disabled, Change prompt (cmd`, powershell`, bash) text cursor position with Left Click
Gui Add, CheckBox, x177 y630 w405 h13 Disabled, Delete word leftward to the cursor (default Ctrl+BackSpace)
SysGet cxVScroll, 2 ; Width of a vertical scroll bar
Gui Add, Custom, ClassScrollBar x600 y190 w%cxVScroll% h208 +0x1
Gui Settings: Default

; Keys & Macro
Gui Tab, 17
Gui Add, GroupBox, x149 y33 w479 h377, Hotkeys`, modifiers`, macros
Gui Add, Text, x160 y49 w54 h13, Show:
Gui Add, Radio, x218 y49 w77 h13 Checked, &All hotkeys
Gui Add, Radio, x301 y49 w86 h13, &User defined
Gui Add, Radio, x394 y49 w59 h13, &System
Gui Add, Radio, x461 y49 w59 h13, &Macros
Gui Add, CheckBox, x524 y49 w98 h13, &Hide unassigned
Gui Add, ListView, x155 y68 w467 h280 +LV0x4000, Type|Hotkey|Description
LV_Add("", "Global", "Ctrl+'", "Minimize/Restore")
LV_Add("", "Global", "<None>", "Minimize/Restore (alternative)")
LV_Add("", "Global", "<None>", "Restore (bring to front)")
LV_Add("", "Global", "Win+Ctrl+Alt+Enter", "Enter TEXT fullscreen mode, when available. If not - standard fullscreen and always on top")
LV_Add("", "Global", "<None>", "Switch focus between ConEmu and child GUI application (e.g. PuTTY or Notepad)")
LV_Add("", "User", "Win+W", "Create new console or new window (check «Multiple consoles in one ConEmu window»)")
LV_Add("", "User", "Win+Shift+W", "Create new console (after «Create confirmation»)")
LV_Add("", "User", "Win+N", "Show create new console popup menu")
LV_Add("", "User", "<None>", "Create new window (after «Create confirmation»)")
LV_Add("", "User", "Ctrl+Shift+O", "Duplicate active «shell» split to bottom: Shell(""new_console:sVn"")")
LV_Add("", "User", "Ctrl+Shift+E", "Duplicate active «shell» split to right: Shell(""new_console:sHn"")")
LV_Add("", "User", "Win+G", "Attach existing Console or GUI application")
LV_Add("", "User", "Win+Q", "Switch next console")
LV_Add("", "User", "Win+Shift+Q", "Switch previous console")
LV_Add("", "User", "Win+'", "Recreate active console")
LV_Add("", "User", "Win+A", "Show alternative console buffer (last command output)")
LV_Add("", "User", "Win+S", "Switch bufferheight mode")
LV_Add("", "User", "Win+Delete", "Close active console")
LV_Add("", "User", "Win+Alt+Delete", "Close current tab: Close(3)")
LV_Add("", "User", "<None>", "Close tabs of the active group: Close(4)")
LV_Add("", "User", "Win+Shift+Delete", "Terminate active process in current console")
LV_Add("", "User", "<None>", "Try to duplicate tab with current state of root process")
LV_Add("", "User", "Win+F4", "Close all tabs (same as «Cross» click): Close(2)")
LV_Add("", "User", "Apps+R", "Rename active tab (for Far Manager only first tab may be renamed)")
LV_Add("", "User", "Win+Alt+Left", "Move active tab leftward")
LV_Add("", "User", "Win+Alt+Right", "Move active tab rightward")
LV_Add("", "User", "Win+X", "Create new «cmd.exe» console")
LV_Add("", "User", "<None>", "Start vertical block selection (like standard console)")
LV_Add("", "User", "<None>", "Start text selection (like text editors)")
LV_Add("", "User", "<None>", "Show opened tabs list (does not works in Far - use macro instead)")
LV_Add("", "User", "Apps+F12", "Show opened tabs list (works in Far too): Tabs(8)")
LV_Add("", "User", "Shift+Insert", "Paste clipboard contents (does not work in Far)")
LV_Add("", "User", "Ctrl+V", "Paste first line of clipboard contents (does not work in Far)")
LV_Add("", "User", "Ctrl+Backspace", "Delete word leftward to the cursor (does not work in Far)")
LV_Add("", "User", "Apps+F", "Find text in active console")
LV_Add("", "User", "Win+H", "Make screenshot of active window")
LV_Add("", "User", "Win+Shift+H", "Make screenshot of entire desktop")
LV_Add("", "User", "Apps+S", "Show status bar")
LV_Add("", "User", "Apps+T", "Show tab bar")
LV_Add("", "User", "Apps+C", "Show window caption")
LV_Add("", "User", "<None>", "Switch «Always on top» window mode")
LV_Add("", "User", "Apps+Space", "Show Tab context menu")
LV_Add("", "User", "Shift+RButton", "Show Tab context menu")
LV_Add("", "User", "Apps+Tab", "Switch to next visible pane (SplitScreen): Tab(10,1)")
LV_Add("", "User", "Apps+Shift+Tab", "Switch to previous visible pane (SplitScreen): Tab(10,-1)")
LV_Add("", "User", "Alt+F9", "Maximize/restore")
LV_Add("", "User", "Alt+Enter", "Full screen")
LV_Add("", "User", "Alt+Space", "Show ConEmu System menu")
LV_Add("", "User", "Ctrl+RButton", "Show ConEmu System menu")
LV_Add("", "User", "Ctrl+Up", "Scroll buffer one line up (disabled in Far /w)")
LV_Add("", "User", "Ctrl+Down", "Scroll buffer one line down (disabled in Far /w)")
LV_Add("", "User", "Ctrl+PgUp", "Scroll buffer one page up (disabled in Far /w)")
LV_Add("", "User", "Ctrl+PgDn", "Scroll buffer one page down (disabled in Far /w)")
LV_Add("", "User", "Pause", "PicView Far plugin: Slideshow start")
LV_Add("", "User", "-_", "PicView Far plugin: Slideshow slower")
LV_Add("", "User", "+=", "PicView Far plugin: Slideshow faster")
LV_Add("", "User", "Ctrl+WheelUp", "Make main font larger: FontSetSize(1,2)")
LV_Add("", "User", "Ctrl+WheelDown", "Make main font smaller: FontSetSize(1,-2)")
LV_Add("", "User", "Ctrl+Shift+F", "Choose and paste file pathname: Paste(4)")
LV_Add("", "User", "Ctrl+Shift+D", "Choose and paste folder path: Paste(5)")
LV_Add("", "User", "Apps+Insert", "Paste path from clipboard in unix format: Paste(8)")
LV_Add("", "Macro 01", "<None>", "<Not set>")
LV_Add("", "Macro 02", "<None>", "<Not set>")
LV_Add("", "Macro 03", "<None>", "<Not set>")
LV_Add("", "Macro 04", "<None>", "<Not set>")
LV_Add("", "Macro 05", "<None>", "<Not set>")
LV_Add("", "Macro 06", "<None>", "<Not set>")
LV_Add("", "Macro 07", "<None>", "<Not set>")
LV_Add("", "Macro 08", "<None>", "<Not set>")
LV_Add("", "Macro 09", "<None>", "<Not set>")
LV_Add("", "Macro 10", "<None>", "<Not set>")
LV_Add("", "Macro 11", "<None>", "<Not set>")
LV_Add("", "Macro 12", "<None>", "<Not set>")
LV_Add("", "Macro 13", "<None>", "<Not set>")
LV_Add("", "Macro 14", "<None>", "<Not set>")
LV_Add("", "Macro 15", "<None>", "<Not set>")
LV_Add("", "Macro 16", "<None>", "<Not set>")
LV_Add("", "Macro 17", "<None>", "<Not set>")
LV_Add("", "Macro 18", "<None>", "<Not set>")
LV_Add("", "Macro 19", "<None>", "<Not set>")
LV_Add("", "Macro 20", "<None>", "<Not set>")
LV_Add("", "Macro 21", "<None>", "<Not set>")
LV_Add("", "Macro 22", "<None>", "<Not set>")
LV_Add("", "Macro 23", "<None>", "<Not set>")
LV_Add("", "Macro 24", "<None>", "<Not set>")
LV_Add("", "Macro 25", "<None>", "<Not set>")
LV_Add("", "Macro 26", "<None>", "<Not set>")
LV_Add("", "Macro 27", "<None>", "<Not set>")
LV_Add("", "Macro 28", "<None>", "<Not set>")
LV_Add("", "Macro 29", "<None>", "<Not set>")
LV_Add("", "Macro 30", "<None>", "<Not set>")
LV_Add("", "Macro 31", "<None>", "<Not set>")
LV_Add("", "Macro 32", "<None>", "<Not set>")
LV_Add("", "Modifier", "LAlt", "Block selection modifier")
LV_Add("", "Modifier", "LShift", "Text selection modifier")
LV_Add("", "Modifier", "<None>", "Right and middle mouse buttons modifier (Text selection)")
LV_Add("", "Modifier", "<None>", "Change prompt text cursor position with left mouse click (cmd, powershell, tcc/le, ...)")
LV_Add("", "Modifier", "LCtrl", "FarGotoEditor modifier (hyperlinks and compiler errors)")
LV_Add("", "Modifier", "<None>", "LDrag modifier")
LV_Add("", "Modifier", "LCtrl", "RDrag modifier")
LV_Add("", "Modifier", "Ctrl+Alt", "Drag ConEmu window by client area")
LV_Add("", "System", "Win+Alt+A", "Show «About» dialog")
LV_Add("", "System", "Win+Alt+K", "Show «Hotkeys»")
LV_Add("", "System", "Win+Alt+P", "Show «Settings» dialog")
LV_Add("", "System", "Win+Alt+Space", "Show ConEmu menu")
LV_Add("", "System", "Ctrl+Win+Alt+Space", "Show real console")
LV_Add("", "System", "Win+Ctrl+Enter", "Full screen")
LV_Add("", "System", "Ctrl+Tab", "Next tab (may be disabled)")
LV_Add("", "System", "Ctrl+Shift+Tab", "Previous tab (may be disabled)")
LV_Add("", "System", "Ctrl+Left", "Switch tab to left (while Ctrl-Tab was pressed and Ctrl - hold)")
LV_Add("", "System", "Ctrl+Up", "Switch tab to left (while Ctrl-Tab was pressed and Ctrl - hold)")
LV_Add("", "System", "Ctrl+Right", "Switch tab to right (while Ctrl-Tab was pressed and Ctrl - hold)")
LV_Add("", "System", "Ctrl+Down", "Switch tab to right (while Ctrl-Tab was pressed and Ctrl - hold)")
LV_Add("", "System", "Esc", "Minimize ConEmu by Esc when no open consoles left (see option «Don't close ConEmu on last console close»)")
LV_Add("", "System", "Shift+Left", "Start text selection, ignored in Far, may be disabled on «Mark & Paste» and «App distinct» pages: Select(0,-1)")
LV_Add("", "System", "Shift+Right", "Start text selection, ignored in Far, may be disabled on «Mark & Paste» and «App distinct» pages: Select(0,1)")
LV_Add("", "System", "Shift+Up", "Start block selection, ignored in Far, may be disabled on «Mark & Paste» and «App distinct» pages: Select(1,0,-1)")
LV_Add("", "System", "Shift+Down", "Start block selection, ignored in Far, may be disabled on «Mark & Paste» and «App distinct» pages: Select(1,0,1)")
LV_Add("", "System", "Win+Left", "Decrease window width (check «Resize with arrows»)")
LV_Add("", "System", "Win+Right", "Increase window width (check «Resize with arrows»)")
LV_Add("", "System", "Win+Up", "Decrease window height (check «Resize with arrows»)")
LV_Add("", "System", "Win+Down", "Increase window height (check «Resize with arrows»)")
LV_Add("", "System", "Win+1", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+2", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+3", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+4", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+5", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+6", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+7", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+8", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+9", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_Add("", "System", "Win+0", "Activate console by number (Use «Host-key»+Number to switch consoles)")
LV_ModifyCol(1, 60)
LV_ModifyCol(2, 120)
LV_ModifyCol(3, 300)
Gui Add, Text, x157 y359 w96 h13 Right Disabled, Choose hotkey:
Gui Add, Hotkey, x259 y356 w71 h21 Disabled
Gui Add, DropDownList, x338 y356 w84 Disabled
Gui Add, DropDownList, x442 y356 w57 Disabled,  |Win|Apps|Ctrl|LCtrl|RCtrl|Alt|LAlt|RAlt|Shift|LShift|RShift
Gui Add, DropDownList, x503 y356 w57 Disabled,  |Win|Apps|Ctrl|LCtrl|RCtrl|Alt|LAlt|RAlt|Shift|LShift|RShift
Gui Add, DropDownList, x565 y356 w57 Disabled,  |Win|Apps|Ctrl|LCtrl|RCtrl|Alt|LAlt|RAlt|Shift|LShift|RShift
Gui Add, Text, x157 y385 w96 h13 Right Disabled, Description:
Gui Add, Edit, x259 y382 w336 h20 Disabled
Gui Add, Button, x598 y380 w24 h23 Disabled, ?

; Controls
Gui Tab, 18
Gui Add, GroupBox, x149 y33 w479 h46, Mouse options
Gui Add, CheckBox, x158 y54 w179 h13 Checked, Send mouse events to console
Gui Add, CheckBox, x341 y54 w146 h13 Checked, Skip click on activation
Gui Add, CheckBox, x490 y54 w131 h13 Checked, Skip in background

Gui Add, GroupBox, x149 y81 w479 h62, Intercept keys
Gui Add, CheckBox, x158 y99 w146 h13 Check3 Checked-1, Install keyboard hooks
Gui Add, CheckBox, x158 y120 w228 h13 Checked, Win+Numbers - activate console
Gui Add, CheckBox, x394 y99 w228 h13, Win+Tab - switch consoles (Tabs)
Gui Add, CheckBox, x394 y120 w228 h13, Win+Arrows - resize window

Gui Add, GroupBox, x149 y145 w479 h42, Seize keys / Send to console
Gui Add, CheckBox, x158 y164 w63 h13, Alt+Tab
Gui Add, CheckBox, x232 y164 w59 h13, Alt+Esc
Gui Add, CheckBox, x314 y164 w63 h13, Ctrl+Esc
Gui Add, CheckBox, x394 y164 w63 h13, PrntScrn
Gui Add, CheckBox, x475 y164 w71 h13, Alt+PrScrn

Gui Add, GroupBox, x149 y189 w479 h70, Miscellaneous
Gui Add, CheckBox, x158 y210 w462 h13, Fix Alt on AltTab/AltF9 (to avoid execution of Far Manager macro`, linked to Alt-release)
Gui Add, CheckBox, x158 y233 w462 h13, Skip focus events (don't send to console FOCUS_EVENT`, useful with Far Manager)

Gui Add, GroupBox, x149 y262 w479 h70, Read line enhancements (command prompt`, ReadConsoleW)
Gui Add, CheckBox, x160 y285 w356 h13 Check3 Checked-1, Change prompt (cmd`, powershell) text cursor position with Left Click
Gui Add, DropDownList, x518 y281 w101, <Always>||Left Ctrl|Right Ctrl|Left Alt|Right Alt|Left Shift|Right Shift
Gui Add, CheckBox, x160 y306 w459 h13 Check3 Checked-1, Delete word leftward to the cursor (default Ctrl+BackSpace)

Gui Add, GroupBox, x149 y335 w479 h73, Hyperlinks and compiler errors (goto editor)
Gui Add, CheckBox, x160 y354 w114 h13 Checked, Highlight and goto
Gui Add, DropDownList, x284 y351 w84, <Always>|Left Ctrl||Right Ctrl|Left Alt|Right Alt|Left Shift|Right Shift
Gui Add, Text, x380 y356 w209 h13 Right, External editor`, when Far not started:
Gui Add, Edit, x160 y377 w431 h21, far.exe /e`%1:`%2 "`%3"
Gui Add, Button, x595 y377 w24 h20, ...

; Mark & Paste
Gui Tab, 19
Gui Add, GroupBox, x149 y33 w479 h98, Text selection
Gui Add, Text, x161 y52 w108 h13, Select text in console:
Gui Add, Radio, x278 y52 w53 h13, Never
Gui Add, Radio, x340 y52 w57 h13 Checked, Always
Gui Add, Radio, x403 y52 w128 h13, Buffer only (cmd.exe)
Gui Add, CheckBox, x160 y77 w374 h13, Freeze console contents before selection (may cause small lag)
Gui Add, CheckBox, x160 y103 w99 h13 Checked, Detect line ends
Gui Add, CheckBox, x265 y103 w78 h13, Bash margin
Gui Add, CheckBox, x349 y103 w116 h13 Check3 Checked-1, Trim trailing spaces
Gui Add, DropDownList, x473 y99 w60, CR+LF||LF|CR

Gui Add, GroupBox, x538 y33 w90 h98, Color indexes
Gui Add, Text, x547 y54 w33 h13 Right, Text:
Gui Add, DropDownList, x583 y49 w36,  0|| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15
Gui Add, Text, x547 y80 w33 h13 Right, Back:
Gui Add, DropDownList, x583 y77 w36,  0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14||15

Gui Add, GroupBox, x149 y137 w479 h65, Select text with mouse (LeftClick+Drag)
Gui Add, CheckBox, x160 y156 w89 h13 Checked, Text selection
Gui Add, DropDownList, x266 y153 w83, <Always>|Left Ctrl|Right Ctrl|Left Alt|Right Alt|Left Shift||Right Shift
Gui Add, CheckBox, x368 y156 w164 h13 Checked, Block (rectangular) selection
Gui Add, DropDownList, x536 y153 w83, <Always>|Left Ctrl|Right Ctrl|Left Alt||Right Alt|Left Shift|Right Shift
Gui Add, CheckBox, x160 y179 w188 h13 Checked, Copy on Left Button release

Gui Add, GroupBox, x149 y208 w479 h68, Select text with keyboard (Also there are two hotkeys on Keys&Macro page)
Gui Add, CheckBox, x160 y229 w462 h13 Checked, Start selection with Shift+Arrow (Text = Left/Right`, Block = Up/Down)
Gui Add, CheckBox, x160 y252 w140 h13, End selection on typing
Gui Add, CheckBox, x304 y252 w68 h13 Disabled, any key

Gui Add, GroupBox, x149 y283 w479 h49, Mouse button actions
Gui Add, Radio, x160 y306 w15 h13
Gui Add, DropDownList, x176 y301 w74, <Always>||Left Ctrl|Right Ctrl|Left Alt|Right Alt|Left Shift|Right Shift
Gui Add, Radio, x257 y306 w150 h13 Checked, Buffer only (e.g. cmd.exe)
Gui Add, Text, x409 y306 w36 h13 Right, Right:
Gui Add, DropDownList, x445 y301 w66, <None>|Copy|Paste|Auto||
Gui Add, Text, x511 y306 w42 h13 Right, Middle:
Gui Add, DropDownList, x553 y301 w66, <None>||Copy|Paste|Auto

Gui Add, GroupBox, x149 y341 w479 h68, Pasting text behavior (with exception of Far Manager)
Gui Add, CheckBox, x158 y361 w176 h13 Checked, All lines (default Shift+Ins)
Gui Add, CheckBox, x344 y363 w137 h13 Checked, First line (default Ctrl+V)
Gui Add, CheckBox, x158 y384 w176 h13 Checked, Confirm <Enter> keypress
Gui Add, CheckBox, x344 y384 w158 h13 Checked, Confirm pasting more than
Gui Add, Edit, x512 y382 w60 h20, 200
Gui Add, Text, x581 y384 w33 h13 Center, chars

; Far Manager
Gui Tab, 20
Gui Add, GroupBox, x149 y33 w479 h68, Shell style Drag and Drop (Far Manager only)
Gui Add, CheckBox, x157 y51 w54 h13 Checked, LDrag
Gui Add, DropDownList, x214 y49 w84, <None>||Left Ctrl|Right Ctrl|Left Alt|Right Alt|Left Shift|Right Shift
Gui Add, CheckBox, x304 y51 w123 h13 Checked, Drop && Confirmation
Gui Add, CheckBox, x433 y51 w62 h13 Checked, Overlay
Gui Add, CheckBox, x518 y51 w101 h13 Checked, Shell icons
Gui Add, CheckBox, x157 y75 w54 h13, RDrag
Gui Add, DropDownList, x214 y72 w84, <None>|Left Ctrl||Right Ctrl|Left Alt|Right Alt|Left Shift|Right Shift
Gui Add, CheckBox, x304 y75 w99 h13 Checked, Copy by default
Gui Add, CheckBox, x433 y75 w99 h13 Checked, Use drop menu

Gui Add, GroupBox, x149 y104 w479 h81, Far Manager options
Gui Add, CheckBox, x157 y124 w152 h13 Checked, Hourglass if not responding
Gui Add, Button, x313 y122 w20 h18 Disabled, ...
Gui Add, CheckBox, x157 y143 w176 h13 Checked, Extend Unicode CharMap
Gui Add, CheckBox, x157 y163 w176 h13, Disable Far flashing
Gui Add, CheckBox, x340 y124 w156 h13 Check3 Checked-1, Resize panels by mouse
Gui Add, CheckBox, x355 y143 w141 h13, use both panel edges
Gui Add, CheckBox, x340 y163 w156 h13, ASCII sort function in Far
Gui Add, CheckBox, x500 y124 w122 h13 Checked, Right selection fix
Gui Add, CheckBox, x500 y143 w122 h13, No zone check
Gui Add, CheckBox, x500 y163 w122 h13 Checked, KeyBar RClick

Gui Add, GroupBox, x149 y189 w479 h125, Far macros
Gui Add, CheckBox, x157 y208 w117 h13 Check3 Checked-1, &RightClick 4 EMenu
Gui Add, Edit, x275 y205 w344 h20, @$If (!CmdLine.Empty) `%Flg_Cmd=1`; `%CmdCurPos=CmdLine.ItemCount-CmdLine.CurPos+1`; `%CmdVal=CmdLine.Value`; Esc $Else `%Flg_Cmd=0`; $End $Text "rclk_gui:" Enter $If (`%Flg_Cmd==1) $Text `%CmdVal `%Flg_Cmd=0`; `%Num=`%CmdCurPos`; $While (`%Num!=0) `%Num=`%Num-1`; CtrlS $End $End
Gui Add, CheckBox, x157 y236 w117 h13 Checked, Safe Far close
Gui Add, Edit, x275 y233 w344 h20, @$while (Dialog||Editor||Viewer||Menu||Disks||MainMenu||UserMenu||Other||Help) $if (Editor) ShiftF10 $else Esc $end $end  Esc  $if (Shell) F10 $if (Dialog) Enter $end $Exit $end  F10
Gui Add, Text, x158 y262 w81 h13, Close tab:
Gui Add, Edit, x248 y259 w371 h20, @$if (Shell) F10 $if (Dialog) Enter $end $else F10 $end
Gui Add, Text, x158 y288 w81 h13, Save all editors:
Gui Add, Edit, x248 y285 w371 h20, @F2 $If (!Editor) $Exit $End `%i0=-1`; F12 `%cur = CurPos`; Home Down `%s = Menu.Select(" * "`,3`,2)`; $While (`%s > 0) $If (`%s == `%i0) MsgBox("FAR SaveAll"`,"Asterisk in menuitem for already processed window"`,0x10001) $Exit $End Enter $If (Editor) F2 $If (!Editor) $Exit $End $Else $If (!Viewer) $Exit $End $End `%i0 = `%s`; F12 `%s = Menu.Select(" * "`,3`,2)`; $End $If (Menu && Title=="Screens") Home $Rep (`%cur-1) Down $End Enter $End $Exit

; Views
Gui Tab, 21
Gui Add, GroupBox, x149 y33 w479 h345, Far Panel Views
Gui Add, GroupBox, x157 y51 w462 h80, Thumbnails mode
Gui Add, Text, x161 y75 w60 h13 Right, Label font:
Gui Add, ComboBox, x229 y72 w174, Tahoma||...
Gui Add, Text, x407 y75 w12 h13 Center, x
Gui Add, ComboBox, x422 y72 w38, 5|6|7|8|9|10|11|12|14||16|18|19|20|24|26|28|30|32
Gui Add, Text, x161 y103 w60 h13 Right, Image size:
Gui Add, Edit, x229 y99 w36 h20, 96
Gui Add, Text, x272 y103 w48 h13 Right, Vert.pad:
Gui Add, Edit, x323 y99 w36 h20, 2
Gui Add, Text, x365 y103 w53 h13 Right, Horz.pad:
Gui Add, Edit, x422 y99 w36 h20, 0
Gui Add, Text, x479 y75 w21 h13 Right, X1:
Gui Add, Edit, x505 y72 w36 h20, 1
Gui Add, Text, x547 y75 w21 h13 Right, Y1:
Gui Add, Edit, x572 y72 w36 h20, 1
Gui Add, Text, x479 y103 w21 h13 Right, X2:
Gui Add, Edit, x505 y99 w36 h20, 5
Gui Add, Text, x547 y103 w21 h13 Right, Y2:
Gui Add, Edit, x572 y99 w36 h20, 20

Gui Add, GroupBox, x157 y137 w462 h80, Tiles mode
Gui Add, Text, x160 y161 w60 h13 Right, Label font:
Gui Add, ComboBox, x229 y158 w174, Tahoma||...
Gui Add, Text, x406 y161 w12 h13 Center, x
Gui Add, ComboBox, x421 y158 w38, 5|6|7|8|9|10|11|12|14||16|18|19|20|24|26|28|30|32
Gui Add, Text, x160 y187 w60 h13 Right, Image size:
Gui Add, Edit, x229 y184 w36 h20, 48
Gui Add, Text, x272 y187 w48 h13 Right, Left pad:
Gui Add, Edit, x323 y184 w36 h20, 4
Gui Add, Text, x365 y187 w53 h13 Right, Right pad:
Gui Add, Edit, x421 y184 w36 h20, 1
Gui Add, Text, x479 y161 w21 h13 Right, X1:
Gui Add, Edit, x505 y158 w36 h20, 4
Gui Add, Text, x547 y161 w21 h13 Right, Y1:
Gui Add, Edit, x571 y158 w36 h20, 4
Gui Add, Text, x479 y187 w21 h13 Right, X2:
Gui Add, Edit, x505 y184 w36 h20, 172
Gui Add, Text, x547 y187 w21 h13 Right, Y2:
Gui Add, Edit, x571 y184 w36 h20, 4

Gui Add, CheckBox, x157 y226 w132 h16 Checked, Load previews for files
Gui Add, Text, x461 y226 w116 h13 Right, Loading timeout (sec.):
Gui Add, Edit, x581 y223 w36 h20, 15
Gui Add, Text, x157 y250 w60 h13, Max. zoom:
Gui Add, DropDownList, x221 y247 w66, 100`%|200`%|300`%|400`%|500`%|600`%||
Gui Add, CheckBox, x464 y249 w152 h16, Restore on Far startup

Gui Add, GroupBox, x157 y272 w152 h73, Preview background
Gui Add, Radio, x166 y293 w78 h16 Checked, Color index
Gui Add, DropDownList, x254 y289 w48, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7|# 8|# 9|#10|#11|#12|#13|#14|#15|Auto||
Gui Add, Radio, x166 y320 w41 h16, RGB
Gui Add, Edit, x211 y317 w68 h20 +E0x20000 -E0x200, 255 255 255
Gui Add, Text, hWndhPreviewBG x283 y317 w18 h20 +0x1000
ControlColor(hPreviewBG, hWnd, "0x000080")

Gui Add, GroupBox, x313 y272 w150 h73
Gui Add, CheckBox, x320 y270 w93 h16 Checked, Preview frame
Gui Add, Radio, x322 y293 w78 h16 Checked, Color index
Gui Add, DropDownList, x406 y289 w48, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7|# 8||# 9|#10|#11|#12|#13|#14|#15|Auto
Gui Add, Radio, x322 y320 w41 h16, RGB
Gui Add, Edit, x365 y317 w68 h20 +E0x20000 -E0x200, 128 128 128
Gui Add, Text, hWndhPreviewFrame x437 y317 w18 h20 +0x1000
ControlColor(hPreviewFrame, hWnd, "0x808080")

Gui Add, GroupBox, x467 y272 w153 h73
Gui Add, CheckBox, x475 y270 w116 h16 Checked, Current item frame
Gui Add, Radio, x475 y293 w78 h16, Color index
Gui Add, DropDownList, x563 y289 w48, # 0|# 1|# 2|# 3|# 4|# 5|# 6|# 7||# 8|# 9|#10|#11|#12|#13|#14|#15|Auto
Gui Add, Radio, x475 y320 w42 h16 Checked, RGB
Gui Add, Edit, x521 y317 w68 h20 +E0x20000 -E0x200, 192 192 192
Gui Add, Text, hWndhCurrentFrame x593 y317 w18 h20 +0x1000
ControlColor(hCurrentFrame, hWnd, "0xC0C0C0")

Gui Add, Button, x157 y348 w75 h23 Disabled, &Apply

; Info
Gui Tab, 22
Gui Add, GroupBox, x149 y33 w479 h49, Performance counters (3020)
Gui Add, Text, x157 y54 w27 h13 Right, FPS:
Gui Add, Edit, x187 y52 w54 h20 ReadOnly, 0.2
Gui Add, Text, x247 y54 w33 h13 Right, Data:
Gui Add, Edit, x283 y52 w54 h20 ReadOnly, 0.1
Gui Add, Text, x343 y54 w41 h13 Right, Render:
Gui Add, Edit, x386 y52 w54 h20 ReadOnly, 0.0
Gui Add, Text, x449 y54 w18 h13 Right, Blt:
Gui Add, Edit, x470 y52 w54 h20 ReadOnly, 0.8
Gui Add, Text, x530 y54 w33 h13 Right, RPS:
Gui Add, Edit, x566 y52 w54 h20 ReadOnly, 1.0

Gui Add, GroupBox, x149 y88 w479 h46, Console states (0x1E7)
Gui Add, Text, x155 y107 w44 h13 Right, Far PID:
Gui Add, Edit, x203 y104 w81 h20 ReadOnly, 0/0
Gui Add, Text, x289 y107 w38 h13 Right, States:
Gui Add, Edit, x331 y104 w288 h20 ReadOnly

Gui Add, GroupBox, x149 y137 w278 h203, Processes
Gui Add, ListBox, x157 y155 w260 h177, (*) [1.0] ConEmuC64.exe - PID:1340|(*) [1.1] cmd.exe - PID:1708

Gui Add, GroupBox, x436 y137 w192 h203, Sizes
Gui Add, Text, x443 y155 w89 h13 Right, Console (chars):
Gui Add, Edit, x539 y151 w81 h20 ReadOnly, 100x50
Gui Add, Text, x487 y179 w45 h13 Right, (pixels):
Gui Add, Edit, x539 y176 w81 h20 ReadOnly, 800x600
Gui Add, Text, x464 y205 w68 h13 Right, DC window:
Gui Add, Edit, x539 y202 w81 h20 ReadOnly, 800x600
Gui Add, Text, x442 y231 w90 h13 Right, Cursor (x`,y`,h):
Gui Add, Edit, x539 y228 w81 h20 ReadOnly, 21x25`, 25 vis
Gui Add, Text, x440 y257 w39 h13 Right, Left:
Gui Add, Edit, x485 y254 w135 h20 ReadOnly, <Absent>
Gui Add, Text, x439 y283 w41 h13 Right, Right:
Gui Add, Edit, x485 y280 w135 h20 ReadOnly, <Absent>
Gui Add, GroupBox, x436 y298 w192 h42, Font
Gui Add, Text, x443 y315 w30 h13 Right, Main:
Gui Add, Edit, x478 y312 w65 h20 ReadOnly, 12x8x8
Gui Add, Text, x550 y315 w20 h13 Right, Fix:
Gui Add, Edit, x574 y312 w47 h20 ReadOnly, 12x8

Gui Add, GroupBox, x149 y340 w479 h47, Current command line
Gui Add, Edit, x157 y358 w461 h20 ReadOnly, "C:\Software\ConEmu\ConEmu.exe" 

; Debug
Gui Tab, 23
Gui Add, GroupBox, x149 y33 w479 h374, Shell activity
Gui Add, Radio, x157 y54 w65 h13 Checked, &Disabled
Gui Add, Radio, x224 y54 w45 h13, Sh&ell
Gui Add, Radio, x272 y54 w53 h13, &Input
Gui Add, Radio, x326 y54 w44 h13, Cmd
Gui Add, Radio, x374 y54 w56 h13 Disabled, Debug
Gui Add, Button, x466 y47 w75 h23, &Reset
Gui Add, Button, x547 y47 w75 h23, Save &as...
Gui Add, ListView, x155 y77 w467 h219, % " "
LV_ModifyCol(1, 62)
Gui Add, Edit, x155 y301 w467 h23 ReadOnly
Gui Add, Edit, x155 y327 w467 h72 Multi ReadOnly

Return ; End of the auto-execute section

ShowOptions:
    ItemID := TV_GetSelection()
    TV_GetText(SelectedItem, ItemID)
    If (SelectedItem = "App distinct") {
        Gui AppDistinct: Show, x0 y0 h408
    } Else {
        Gui AppDistinct: Hide
    }
    GuiControl Choose, SysTabControl321, %SelectedItem%
    TV_Modify(ItemID, "Bold")
    TV_Modify(PrevItem, "-Bold")
    PrevItem := ItemID
Return

GuiEscape:
GuiClose:
    ExitApp
