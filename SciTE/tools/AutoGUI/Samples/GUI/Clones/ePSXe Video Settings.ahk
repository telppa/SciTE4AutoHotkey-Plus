#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Gui -Theme
Gui Add, Button, x11 y7 w90 h20, Select device...
Gui Add, Text, x108 y10 w495 h16, Primary

Gui Add, GroupBox, x6 y31 w609 h65, Resolution && Colors
Gui Add, Radio, x15 y47 w101 h16, Fullscreen mode
Gui Add, Radio, x15 y68 w95 h20 Checked, Window mode
Gui Add, Text, x128 y47 w114 h15 Right, Desktop resolution:
Gui Add, DropDownList, x246 y44 w95, %A_Space%320 x  200| 320 x  240| 400 x  300| 512 x  384| 640 x  400| 640 x  480| 656 x  496| 800 x  600||1024 x  768|1152 x  864|1280 x  600|1280 x  720|1280 x  768|1280 x 1024|1360 x  768|1366 x  768|1600 x 1200
Gui Add, Text, x167 y70 w75 h15 Right, Window size:
Gui Add, Edit, x246 y68 w39 h20, 640
Gui Add, Text, x287 y70 w12 h15, x
Gui Add, Edit, x302 y68 w39 h20, 480
Gui Add, Text, x386 y47 w59 h15, Color depth:
Gui Add, DropDownList, x449 y44 w104, 16 Bit|32 Bit||

Gui Add, GroupBox, x6 y96 w609 h65, Textures
Gui Add, Text, x14 y115 w77 h16, Texture quality:
Gui Add, DropDownList, x95 y111 w246, don't care - Use driver's default textures|R4 G4 B4 A4 - Fast`, but less colorful|R5 G5 B5 A1 - Nice colors`, black gets dark red|R8 G8 B8 A8 - Best colors`, more ram needed||
Gui Add, Text, x12 y135 w78 h16, Texture filtering:
Gui Add, DropDownList, x95 y132 w246, 0: None||1: Standard - Glitches will happen|2: Extended - Removes black borders|3: Standard w/o Sprites - unfiltered 2D|4: Extended w/o Sprites - unfiltered 2D|5: Standard + smoothed Sprites|6: Extended + smoothed Sprites
Gui Add, Text, x348 y114 w75 h16, Hi-Res textures:
Gui Add, DropDownList, x426 y111 w180, 0: None (standard)||1: 2xSaI (much vram needed)|2: Stretched (filtering needed)
Gui Add, Text, x348 y133 w75 h18, Gfx card vram:
Gui Add, ComboBox, x426 y132 w104, 0 (Autodetect)||2|4|8|16|32|64|128
Gui Add, Text, x534 y135 w39 h15, MBytes

Gui Add, GroupBox, x6 y161 w609 h55, Framerate
Gui Add, CheckBox, x20 y184 w158 h16, Show FPS display on startup
Gui Add, Button, x182 y184 w17 h16, ...
Gui Add, CheckBox, x234 y174 w92 h16 Checked, Use FPS limit
Gui Add, CheckBox, x234 y193 w126 h16, Use Frame skipping
Gui Add, Radio, x387 y172 w203 h18 Checked, Auto-detect FPS/Frame skipping limit
Gui Add, Radio, x387 y192 w108 h18, FPS limit (10-200) :
Gui Add, Edit, x500 y192 w42 h20, 200.00
Gui Add, Text, x548 y195 w30 h15, FPS

Gui Add, GroupBox, x6 y216 w609 h104, Compatibility
Gui Add, Text, x14 y231 w98 h16, Off-Screen drawing:
Gui Add, DropDownList, x117 y229 w224, 0: None - Fastest`, most glitches|1: Minimum - Missing screens|2: Standard - OK for most games|3: Enhanced - Shows more stuff||4: Extended - Can cause garbage
Gui Add, Text, x14 y252 w98 h16, Advanced blending:
Gui Add, DropDownList, x117 y250 w224, 0: None|1: Software - Slower and glitches|2: Hardware - Fast`, not all cards support it||
Gui Add, Text, x11 y275 w102 h15, Framebuffer textures:
Gui Add, DropDownList, x117 y271 w224, 0: Emulated vram - effects need FVP|1: Black - Fast but no special effects|2: Gfx card buffer - Can be slow||3: Gfx card buffer & software - slow
Gui Add, Text, x11 y296 w102 h15, Framebuffer access:
Gui Add, DropDownList, x117 y293 w224, 0: Emulated vram - OK for most games||1: Gfx card buffer reads|2: Gfx card buffer moves|3: Gfx card buffer reads & moves|4: Full software drawing (FVP)
Gui Add, CheckBox, x354 y252 w99 h16 Checked, Alpha Multipass
Gui Add, Text, x461 y252 w149 h15, Correct opaque texture areas
Gui Add, CheckBox, x354 y276 w81 h16 Checked, Mask bit
Gui Add, Text, x461 y276 w149 h15, Needed by a few games

Gui Add, GroupBox, x6 y320 w609 h119, Misc
Gui Add, CheckBox, x20 y335 w111 h16, Scanlines
Gui Add, Text, x206 y335 w102 h15, TV screen alike lines
Gui Add, Text, x315 y335 w243 h15, Scanline brightness (0...255`, -1=Monitor dot matrix):
Gui Add, Edit, x563 y333 w42 h20, 0
Gui Add, CheckBox, x20 y351 w165 h16, Unfiltered framebuffer updates
Gui Add, Text, x206 y351 w116 h15, Speed up with mdecs
Gui Add, CheckBox, x20 y367 w95 h16, Color dithering
Gui Add, Text, x206 y367 w396 h15, Smoother shading in 16 bit color depth
Gui Add, CheckBox, x20 y384 w122 h16, Screen smoothing
Gui Add, Text, x206 y384 w399 h15, The complete screen will get smoothed. Very slow on some cards`, lotta vram needed
Gui Add, CheckBox, x20 y400 w122 h16, Disable screensaver
Gui Add, Text, x206 y400 w399 h15, Disable screensaver and power saving modes. Not available in Win95/WinNT
Gui Add, CheckBox, x20 y416 w113 h16, Special game fixes
Gui Add, Button, x141 y416 w17 h16, ...
Gui Add, Text, x206 y416 w396 h15, Some games will need certain special options to work without glitches

Gui Add, GroupBox, x6 y439 w135 h47, Default settings
Gui Add, Button, x17 y455 w53 h23, Fast
Gui Add, Button, x77 y455 w53 h23, Nice

Gui Add, Button, x168 y455 w126 h23, OK
Gui Add, Button, x326 y455 w126 h23, Cancel
Gui Add, Button, x483 y445 w131 h41, Copy settings`n to clipboard

Gui Show, w620 h492, Configure Pete's PSX D3D (DX7) Renderer... - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
