; Grab and Drag 3.2.5 (Firefox Add-on)
#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui Font, s9, Segoe UI

Try {
    Gui Add, % "Tab3", x9 y9 w534 h426, General|More Options|Momentum|Gestures|Advanced
} Catch {
    Gui Add, Tab2, hWndhTab x9 y9 w534 h426, General|More Options|Momentum|Gestures|Advanced
    Control Style, 0x54010040,, ahk_id%hTab%
}

Gui Tab, 1
    Gui Add, GroupBox, x24 y45 w355 h116, Features
    Gui Add, CheckBox, x36 y65 w341 h19, Extension Enabled
    Gui Add, CheckBox, x43 y88 w136 h19 Checked, Momentum Enabled
    Gui Add, CheckBox, x43 y111 w144 h19, Flick Gestures Enabled
    Gui Add, CheckBox, x43 y134 w131 h19 Checked, TextToggle Enabled

    Gui Add, GroupBox, x385 y45 w143 h116, Toggle Hotkey
    Gui Add, CheckBox, x397 y65 w51 h19, Ctrl
    Gui Add, CheckBox, x397 y88 w51 h19 Checked, Alt
    Gui Add, CheckBox, x397 y111 w51 h23 Checked, Shift
    Gui Add, Text, x453 y115 w8 h15 +0x200, +
    Gui Add, DropDownList, x470 y111 w51, A|B|C|D||E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|0|1|2|3|4|5|6|7|8|9|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12

    Gui Add, GroupBox, x24 y167 w504 h74, Behavior
    Gui Add, Text, x33 y191 w42 h15 +0x200, Use the
    Gui Add, DropDownList, x84 y187 w70, left||middle|right
    Gui Add, Text, x164 y191 w169 h15 +0x200,  mouse button to grab and drag
    Gui Add, CheckBox, x36 y214 w490 h19 Checked, Disable grabbing on links

    Gui Add, GroupBox, x24 y247 w504 h132, TextToggle
    Gui Add, DropDownList, x31 y267 w205, Hovering the mouse cursor|Dragging horizontally or clicking|Clicking|Double-clicking||
    Gui Add, Text, x246 y271 w274 h15 +0x200, on webpage text switches to text selection mode
    Gui Add, DropDownList, x31 y294 w205, Hovering the mouse cursor|Dragging horizontally or clicking|Clicking||Double-clicking
    Gui Add, Text, x246 y298 w274 h15 +0x200, on non-text reenables grabbing and dragging mode
    Gui Add, CheckBox, x36 y321 w490 h19, Copy selected text to the clipboard when grabbing is reenabled
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y343 w449 h26 cGray, Warning: The 'hovering' TextToggle option may degrade browser performance on older computers when browsing complex websites.
    Gui Font, s9, Segoe UI
    Gui Add, Button, x26 y383 w500 h26, Edit Website Blacklist...

Gui Tab, 2
    Gui Add, GroupBox, x24 y45 w504 h96, Drag Multiplier
    Gui Add, Edit, x56 y74 w30 h20, 1
    Gui Font, s7, Segoe UI
    Gui Add, Text, x98 y90 w19 h12, slow
    Gui Add, Slider, x88 y63 w435 h26 NoTicks Center Range0-8, 1
    Gui Add, Text, x498 y90 w15 h12, fast
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y105 w467 h26 cGray, Changing this parameter causes the screen to scroll faster or slower than the mouse cursor actually moves. A value of 1.0 provides the default one-to-one scrolling.
    Gui Font, s9, Segoe UI

    Gui Add, GroupBox, x24 y147 w504 h70, Drag Behavior
    Gui Add, CheckBox, x36 y167 w490 h19, Reverse Scroll Direction
    Gui Add, CheckBox, x36 y190 w490 h19, Scrollbar Drag Mode (emulate dragging the scrollbar)

    Gui Add, GroupBox, x24 y223 w504 h119, Cursors
    Gui Add, Text, x33 y247 w87 h15 +0x200, Mouse Cursor
    Gui Add, DropDownList, x129 y243 w229, Open hand||Large open hand|Basic open hand|4-Way arrow|Standard arrow|Invisible|Default cursor
    Gui Add, Text, x33 y274 w87 h15 +0x200, Grabbing Cursor
    Gui Add, DropDownList, x129 y270 w229, Closed hand||Large closed hand|Basic closed hand|4-Way arrow|Standard arrow|Invisible|Default cursor
    Gui Add, CheckBox, x134 y297 w229 h19, Don't change (improves performance)
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y319 w357 h13 cGray, Note: Some operating systems may not display some cursors properly.

Gui Tab, 3
    Gui Font, s9, Segoe UI
    Gui Add, Text, x27 y43 w479 h45, If Momentum is enabled`, releasing a page you've been dragging at a constant velocity will cause the page to continue moving at its current speed until clicked to stop. This allows for fluid and quick movement through long pages.
    Gui Add, GroupBox, x24 y95 w504 h325, GroupBox
    Gui Add, CheckBox, x36 y115 w490 h19 Checked, Momentum Enabled
    Gui Add, Text, x33 y137 w487 h15 +0x200, Time Sensitivity
    Gui Font, s7, Segoe UI
    Gui Add, Text, x60 y181 w22 h12, short
    Gui Add, Slider, x49 y154 w474 h28 NoTicks Center, 50
    Gui Add, Text, x493 y181 w20 h12, long
    Gui Font, s9, Segoe UI
    Gui Add, Text, x33 y196 w487 h15 +0x200, Deceleration Sensitivity
    Gui Font, s7, Segoe UI
    Gui Add, Text, x60 y240 w22 h12, small
    Gui Add, Slider, x49 y213 w474 h28 NoTicks Center, 50
    Gui Add, Text, x492 y240 w21 h12, large
    Gui Font, s9, Segoe UI
    Gui Add, Text, x32 y254 w120 h23 +0x200, Momentum Friction
    Gui Font, s7, Segoe UI
    Gui Add, Text, x60 y299 w45 h12, no friction
    Gui Add, Slider, x49 y273 w474 h29 NoTicks Center, 0
    Gui Add, Text, x467 y299 w46 h12 +0x200, full friction
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y314 w486 h52 cGray, Time Sensitivity controls how much time a page should be dragged at near-constant velocity in order to initiate momentum. Deceleration Sensitivity controls how sensitive momentum is to changes in drag velocity immediately before release. In both cases`, the smaller the values`, the easier it is to trigger momentum.
    Gui Add, Text, x33 y371 w474 h39 cGray, Friction controls how much the page's scrolling decelerates after being released. Low values make the page scroll farther`, while high values make the page stop scrolling after a shorter distance.

Gui Tab, 4
    Gui Font, s9, Segoe UI
    Gui Add, Text, x27 y43 w487 h45, 'Flicks' are mouse gestures made by by quickly flicking the pen/mouse across the screen in a particular direction. Grab and Drag allows you to use flicks to scroll up`, down`, left`, or right. Flicks are mostly useful for pen-based computers.
    Gui Add, GroupBox, x24 y95 w504 h237, Flick Gestures
    Gui Add, CheckBox, x36 y115 w490 h19, Flick Gestures Enabled
    Gui Add, Text, x33 y142 w84 h15 +0x200, Flicks scroll like 
    Gui Add, DropDownList, x130 y138 w247, PgUp/PgDn (one screen at a time)||Home/End (to the edge of the webpage)
    Gui Add, Text, x33 y169 w88 h15 +0x200, Right/Left Flicks 
    Gui Add, DropDownList, x130 y165 w247, only scroll the page||browse back/forward at page edges|always browse back/forward|always browse forward/back
    Gui Add, Text, x33 y191 w487 h15 +0x200, Scroll Speed
    Gui Font, s7, Segoe UI
    Gui Add, Text, x60 y235 w19 h12, slow
    Gui Add, Slider, x50 y208 w474 h29 NoTicks Center, 77
    Gui Add, Text, x498 y235 w15 h12, fast
    Gui Font, s9, Segoe UI
    Gui Add, Text, x33 y250 w487 h15 +0x200, Time Limit
    Gui Font, s7, Segoe UI
    Gui Add, Text, x60 y294 w22 h12, short
    Gui Add, Slider, x50 y266 w474 h29 NoTicks Center, 12
    Gui Add, Text, x493 y294 w20 h12, long
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y309 w433 h13 cGray, Time Limit controls how quickly a flick must be carried out in order to be recognized.

Gui Tab, 5
    Gui Add, GroupBox, x24 y45 w504 h96, Drag Increments
    Gui Font, s7, Segoe UI
    Gui Add, Slider, x52 y64 w468 h30 NoTicks Center, 0
    Gui Add, Text, x60 y90 w34 h12, smooth
    Gui Add, Text, x467 y90 w46 h12, responsive
    Gui Font, s8, Segoe UI
    Gui Add, Text, x33 y105 w463 h26 cGray, Increasing this parameter forces scrolling to occur in larger pixel increments. This sacrifices some scrolling smoothness`, but may give better performance on some machines.

    Gui Font, s9, Segoe UI
    Gui Add, GroupBox, x24 y147 w504 h70, Misc.
    Gui Add, CheckBox, x36 y167 w490 h19 Checked, Smoothly stop scrolling from flicks and momentum
    Gui Add, CheckBox, x36 y190 w490 h19, Paranoid compatibility mode (disable extension if webpage changes mouse cursors)

    Gui Add, GroupBox, x24 y216 w504 h78
    Gui Add, Button, x32 y231 w488 h26, Edit Website Blacklist...
    Gui Add, Button, x32 y260 w488 h26, Toggle Built-in Blacklists...
Gui Tab

Gui Add, Button, x14 y443 w116 h26, Run Startup Wizard
Gui Add, Button, x291 y443 w76 h26 Default, OK
Gui Add, Button, x377 y443 w76 h26, Apply
Gui Add, Button, x462 y443 w76 h26, Cancel

Gui Show, w552 h480, Grab and Drag Preferences - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
