; TightVNC Server 2.7.10
#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

Try {
    Gui Add, % "Tab3", x8 y8 w465 h349 +Theme, Server|Extra Ports|Access Control|Video|Administration
} Catch {
    Gui Add, Tab2, x8 y8 w465 h349 +Theme, Server|Extra Ports|Access Control|Video|Administration
}
    Gui Add, GroupBox, x21 y37 w213 h200, Incoming Viewer Connections
    Gui Add, Checkbox, x36 y58 w185 h16 Checked, Accept incoming connections
    Gui Add, Text, x53 y82 w83 h16, Main server port:
    Gui Add, Edit, x146 y80 w59 h20
    Gui Add, UpDown, x181 y80 w18 h20 0x80 Range0-65536, 5900
    Gui Add, Checkbox, x36 y106 w185 h16 Checked, Require VNC authentication
    Gui Add, Text, x38 y131 w114 h16, Primary password:
    Gui Add, Button, x68 y150 w59 h24, Set...
    Gui Add, Button, x134 y150 w59 h24 Disabled, Unset
    Gui Add, Text, x38 y180 w114 h16, View-only password:
    Gui Add, Button, x68 y199 w59 h24, Set...
    Gui Add, Button, x134 y199 w59 h24 Disabled, Unset
    Gui Add, GroupBox, x21 y245 w213 h99, Miscellaneous
    Gui Add, Checkbox, x36 y267 w182 h16 Checked, Enable file transfers
    Gui Add, Checkbox, x36 y292 w182 h16 Checked, Hide desktop wallpaper
    Gui Add, Checkbox, x36 y316 w182 h16 Checked, Show icon in the notification area
    Gui Add, GroupBox, x248 y37 w213 h73, Web Access
    Gui Add, Checkbox, x263 y58 w192 h16 Checked, Serve Java Viewer to Web clients
    Gui Add, Text, x279 y82 w87 h16, Web access port:
    Gui Add, Edit, x371 y80 w59 h20
    Gui Add, UpDown, x394 y80 w18 h20 0x80 Range0-65536, 5800
    Gui Add, GroupBox, x248 y118 w213 h119, Input Handling
    Gui Add, Checkbox, x263 y139 w192 h16, Block remote input events
    Gui Add, Checkbox, x263 y163 w192 h16, Block remote input on local activity
    Gui Add, Text, x279 y186 w87 h16, Inactivity timeout:
    Gui Add, Edit, x371 y183 w49 h20 Disabled
    Gui Add, UpDown, x384 y183 w18 h20, 3
    Gui Add, Text, x429 y186 w26 h16, sec
    Gui Add, Checkbox, x263 y210 w192 h16, No local input during client sessions
    Gui Add, GroupBox, x248 y245 w213 h99, Update Handling
    Gui Add, Checkbox, x263 y267 w192 h16 Checked, Use mirror driver if available
    Gui Add, Checkbox, x263 y292 w192 h16 Checked, Grab transparent windows
    Gui Add, Text, x263 y316 w102 h16, Screen polling cycle:
    Gui Add, Edit, x371 y313 w59 h20
    Gui Add, UpDown, x394 y313 w18 h20 Range0-1000000 0x80, 1000
    Gui Add, Text, x435 y314 w20 h16, ms

Gui Tab, 2
    Gui Add, GroupBox, x21 y37 w440 h140, Extra Ports
    Gui Add, Text, x36 y56 w321 h16, Mapping of additional listening TCP ports to screen areas:
    Gui Add, ListBox, x36 y77 w321 h82
    Gui Add, Button, x372 y77 w75 h24, Add...
    Gui Add, Button, x372 y106 w75 h24 Disabled, Edit...
    Gui Add, Button, x372 y137 w75 h24 Disabled, Remove
    Gui Add, GroupBox, x21 y184 w440 h159, Help
    Gui Add, Text, x36 y206 w411 h39, By default`, TightVNC Server listens for incoming connections on just one main TCP port`, and shows the complete desktop to its clients.
    Gui Add, Text, x36 y245 w411 h52, However`, it's possible to make it listen on a number of extra ports`, where each port has a specific area of the screen associated with it. If a client then connects to an extra port`, only that part of the screen will be shown.
    Gui Add, Text, x36 y297 w411 h39, Screen areas are represented by patterns like 640x480+120+240 (in this example`, width is 640`, height is 480`, horizontal offset is 120 and vertical offset is 240 pixels).

Gui Tab, 3
    Gui Add, GroupBox, x21 y37 w440 h156, Rules
    Gui Add, ListView, x32 y54 w311 h99
    Gui Add, Button, x350 y53 w99 h23, Add...
    Gui Add, Button, x350 y79 w99 h23 Disabled, Edit...
    Gui Add, Button, x350 y105 w99 h23 Disabled, Remove
    Gui Add, Button, x350 y131 w99 h23 Disabled, Move up
    Gui Add, Button, x350 y157 w99 h23 Disabled, Move down
    Gui Add, Text, x32 y168 w113 h16, Check the rules above:
    Gui Add, Edit, x149 y165 w93 h20
    Gui Add, Text, x246 y168 w99 h16, ( enter IP address )
    Gui Add, GroupBox, x21 y199 w213 h145, Query Settings
    Gui Add, Text, x36 y219 w188 h29, These settings apply only to the rules with Action set to "Query local user".
    Gui Add, Text, x36 y254 w75 h16, Query timeout:
    Gui Add, Edit, x117 y251 w52 h20
    Gui Add, UpDown, x134 y251 w18 h20 0x80 Range0-65536, 30
    Gui Add, Text, x176 y254 w45 h16, seconds
    Gui Add, Text, x36 y277 w165 h16, Default action on timeout:
    Gui Add, Radio, x51 y298 w140 h16 Checked, Reject connection
    Gui Add, Radio, x51 y319 w140 h16, Accept connection
    Gui Add, GroupBox, x248 y199 w213 h145, Loopback Connections
    Gui Add, Text, x263 y219 w186 h42, By default`, connections from the same machine are disallowed to prevent the "cascading windows" effect.
    Gui Add, Text, x263 y264 w186 h29, Loopback settings work independently from the rules configured above!
    Gui Add, Checkbox, x263 y298 w177 h16, Allow loopback connections
    Gui Add, Checkbox, x263 y319 w177 h16 Disabled, Allow only loopback connections

Gui Tab, 4
    Gui Add, GroupBox, x21 y37 w440 h156, Video Detection
    Gui Add, Text, x36 y56 w410 h16, Class names of video windows (enter one class name per line`, without quotes):
    Gui Add, Edit, x36 y76 w410 h81
    Gui Add, Text, x36 y168 w129 h16, Video recognition interval:
    Gui Add, Edit, x173 y165 w59 h20
    Gui Add, UpDown, x247 y168 w16 h16 0x80 Range0-65536, 3000
    Gui Add, Text, x236 y168 w16 h16, ms
    Gui Add, GroupBox, x21 y199 w440 h145, Help
    Gui Add, Text, x36 y220 w410 h42, TightVNC cannot detect video windows on the screen automatically (that cannot be done reliably). However`, you can help it by providing a list of window class names to be recognized as video windows.
    Gui Add, Text, x36 y305 w410 h29, Class name is a special string assigned to each window (e.g. certain versions of Windows Media Player show video in windows with "WMPlayerApp" class name).
    Gui Add, Text, x36 y269 w410 h29, Once such a video window is found`, its contents will be encoded with JPEG and sent to the viewer continuously with minimum delays.

Gui Tab, 5
    Gui Add, GroupBox, x21 y37 w267 h86, Control Interface
    Gui Add, Checkbox, x36 y56 w245 h18, Protect control operations with a password
    Gui Add, Text, x36 y79 w143 h20, Administrative password:
    Gui Add, Button, x161 y74 w56 h24 Disabled, Set...
    Gui Add, Button, x224 y74 w56 h24 Disabled, Unset
    Gui Add, Checkbox, x36 y100 w245 h16 Disabled, Ask password for each operation
    Gui Add, GroupBox, x302 y37 w159 h86, When Last Client Disconnects
    Gui Add, Radio, x311 y56 w143 h16 Checked, Do nothing
    Gui Add, Radio, x311 y77 w143 h16, Lock desktop
    Gui Add, Radio, x311 y98 w143 h16, Logoff current user
    Gui Add, GroupBox, x21 y131 w440 h128, Session Sharing
    Gui Add, Radio, x36 y149 w414 h16 Group, Always treat connections as shared`, add new clients and keep old connections
    Gui Add, Radio, x36 y170 w414 h16, Never treat connections as shared`, disable new clients if there is one already
    Gui Add, Radio, x36 y191 w414 h16, Never treat connections as shared`, disconnect existing clients on new connections
    Gui Add, Radio, x36 y212 w414 h16, Block new non-shared connections if someone is already connected
    Gui Add, Radio, x36 y233 w414 h16 Checked, Disconnect existing clients on new non-shared connections
    Gui Add, GroupBox, x21 y266 w440 h78, Logging
    Gui Add, Text, x36 y287 w189 h16, Log verbosity level (0 disables logging):
    Gui Add, Edit, x228 y284 w38 h20
    Gui Add, UpDown, x230 y284 w18 h20 0x80 Range0-9, 0
    Gui Add, Checkbox, x290 y287 w167 h16, Make log available to all users
    Gui Add, Text, x36 y316 w44 h16, Log file:
    Gui Add, Edit, x84 y313 w282 h20 ReadOnly, C:\Users\Alguimist\AppData\Roaming\TightVNC
    Gui Add, Button, x375 y311 w75 h24, Open folder

Gui Tab

Gui Add, Button, x231 y366 w75 h24 Default, OK
Gui Add, Button, x314 y366 w75 h24, Cancel
Gui Add, Button, x396 y366 w75 h24 Disabled, Apply

Gui Show, w479 h400, TightVNC Server Configuration - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
