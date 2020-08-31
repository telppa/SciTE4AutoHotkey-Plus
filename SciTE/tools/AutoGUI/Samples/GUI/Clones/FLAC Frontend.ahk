#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Gui Add, ListBox, x12 y12 w393 h134
Gui Add, Button, x412 y12 w75 h23, &Add files
Gui Add, Button, x412 y42 w75 h23, &Remove file
Gui Add, Button, x412 y72 w75 h23, &Clear filelist
Gui Add, GroupBox, x12 y152 w200 h134, Encoding options
Gui Add, Text, x22 y182 w36 h13, Level:
Gui Add, Edit, x60 y179 w21 h20 Center Disabled, 5
Gui Add, Slider, x87 y175 w119 h45 Range0-8 TickInterval1, 5
Gui Add, CheckBox, x25 y213 w123 h17 Checked, Verify after encoding
Gui Add, CheckBox, x25 y237 w128 h17, Calculate ReplayGain
Gui Add, CheckBox, x42 y260 w164 h17 Disabled, Treat input files as one album
Gui Add, GroupBox, x220 y152 w185 h88, General options
Gui Add, CheckBox, x233 y172 w104 h17, Delete input files
Gui Add, CheckBox, x233 y195 w153 h17, Create/read as OGG-FLAC
Gui Add, CheckBox, x233 y218 w133 h17, Keep foreign metadata
Gui Add, GroupBox, x220 y243 w185 h43, Decoding/testing options
Gui Add, CheckBox, x233 y262 w154 h17, Decode/test through errors
Gui Add, Button, x411 y167 w75 h23, Ad&vanced
Gui Add, Button, x412 y234 w75 h23, &Help
Gui Add, Button, x412 y263 w75 h23, A&bout
Gui Add, GroupBox, x12 y292 w469 h53, Output directory (only for encoding and decoding)
Gui Add, Edit, x25 y314 w327 h20 Disabled, << Same as input directory >>
Gui Add, Button, x358 y313 w26 h22, ...
Gui Add, Button, x387 y313 w85 h22, Same as input
Gui Add, Button, x12 y351 w75 h23, &Encode
Gui Add, Button, x107 y351 w75 h23, &Decode
Gui Add, Button, x201 y351 w90 h23, &Test for errors
Gui Add, Button, x311 y351 w75 h23, &Fingerprint
Gui Add, Button, x406 y351 w75 h23, E&xit

Gui Show, w493 h382, FLAC Frontend - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
