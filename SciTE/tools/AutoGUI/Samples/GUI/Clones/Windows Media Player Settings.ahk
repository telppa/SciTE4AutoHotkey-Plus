#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

If (FileExist(A_WinDir . "\System32\wmploc.dll")) {
    wmploc := "wmploc.dll"
} Else {
    wmploc := "shell32.dll"
    MsgBox 0x30, Warning, The WMP resource DLL (wmploc.dll) was not found on your system.`nUsing shell32.dll instead. The wrong icons will be displayed.
}

Try {
    Gui Add, % "Tab3", x6 y7 w385 h457, Player|Rip Music|Devices|Burn|Performance|Library|Plug-ins|Privacy|Security|DVD|Network
} Catch {
    Gui Add, Tab2, x6 y7 w385 h457, Player|Rip Music|Devices|Burn|Performance|Library|Plug-ins|Privacy|Security|DVD|Network
}
; Player tab
    Gui Add, Picture, x16 y54 w32 h32 Icon1, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Customize updates and Player settings.
    Gui Add, GroupBox, x16 y93 w366 h59, Automatic updates
    Gui Add, Text, x34 y110 w309 h16, Check for updates:
    Gui Add, Radio, x46 y128 w99 h16, Once a &day
    Gui Add, Radio, x145 y128 w99 h16 Checked, Once a &week
    Gui Add, Radio, x247 y128 w86 h16, Once a &month
    Gui Add, GroupBox, x16 y158 w366 h182, Player settings
    Gui Add, CheckBox, x34 y175 w333 h16, Keep Now Playing on &top of other windows
    Gui Add, CheckBox, x34 y195 w333 h16, Allow screen sa&ver during playback
    Gui Add, CheckBox, x34 y214 w333 h16 Checked, Add local media files to &library when played
    Gui Add, CheckBox, x34 y234 w333 h16, Add &remote media files to library when played
    Gui Add, CheckBox, x34 y253 w333 h16, Connect to the &Internet (overrides other commands)
    Gui Add, CheckBox, x34 y273 w333 h16, &Stop playback when switching to a different user
    Gui Add, CheckBox, x34 y292 w333 h16 Checked, Allow auto&hide of playback controls
    Gui Add, CheckBox, x34 y312 w333 h16, Save recently used to the &Jumplist instead of frequently used

; Rip Music tab
Gui Tab, 2
    Gui Add, Picture, x16 y54 w32 h32 Icon14, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Specify where music is stored and change rip settings.
    Gui Add, GroupBox, x16 y94 w366 h73, Rip music to this location
    Gui Add, Edit, x25 y114 w267 h46 +Multi +ReadOnly -VScroll -E0x200, C:\Users\Alguimist\Music
    Gui Add, Button, x298 y107 w75 h23, C&hange...
    Gui Add, Button, x298 y136 w75 h23, File &Name...
    Gui Add, GroupBox, x16 y171 w366 h268, Rip settings
    Gui Add, Text, x25 y190 w231 h13, &Format:
    Gui Add, DropDownList, x28 y210 w227, Windows Media Audio||Windows Media Audio Pro|Windows Media Audio (Variable Bit Rate)|Windows Media Audio Lossless|MP3|WAV (Lossless)
    Gui Font, s9, Segoe UI
    Gui Add, Link, x190 y237 w191 h44, <a>Learn about copy protection</a>
    Gui Font
    Gui Add, CheckBox, x28 y237 w150 h16, Copy &protect music
    Gui Add, CheckBox, x28 y255 w183 h16, &Rip CD automatically
    Gui Add, CheckBox, x28 y309 w183 h16, &Eject CD after ripping
    Gui Add, Text, x28 y331 w288 h13, A&udio quality:
    Gui Add, Text, x40 y349 w45 h33, Smallest`nSize
    Gui Add, Slider, x88 y353 w228 h23 Range0-5 TickInterval1, 3
    Gui Add, Text, x322 y349 w45 h33, Best`nQuality
    Gui Add, Text, x28 y379 w348 h36, Uses about 56 MB per CD (128 Kbps).

; Devices tab
Gui Tab, 3
    Gui Add, Picture, x16 y54 w32 h32 Icon2, % wmploc
    Gui Add, Text, x52 y57 w324 h33, Specify settings for CDs`, DVDs`, displays`, speakers`, and portable devices.
    Gui Add, GroupBox, x16 y93 w366 h237, De&vices
    Gui Add, ListView, x28 y112 w342 h176 -Hdr, Devices
    IL := IL_Create(4)
    If (A_OSVersion != "WIN_XP") {
        IL_Add(IL, "imageres.dll", 26)
    } Else {
        IL_Add(IL, "shell32.dll", 12)
    }
    IL_Add(IL, wmploc, 83)
    IL_Add(IL, wmploc, 82)
    LV_SetImageList(IL)
    LV_Add("Icon1", "CD Drive (D:)")
    LV_Add("Icon2", "Display")
    LV_Add("Icon3", "Speakers")
    Gui Add, Button, x214 y297 w75 h23, &Refresh
    Gui Add, Button, x298 y297 w75 h23, &Properties
    Gui Add, CheckBox, x22 y340 w351 h33 Checked, When &deleting playlists from devices`, also remove their contents
    Gui Add, Text, x22 y382 w270 h26, Click Advanced to change file conversion options.
    Gui Add, Button, x298 y379 w75 h23, Adva&nced...

; Burn tab
Gui Tab, 4
    Gui Add, Picture, x16 y54 w32 h32 Icon11, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Specify settings for burning audio and data discs.
    Gui Add, GroupBox, x19 y94 w353 h67, General
    Gui Add, Text, x33 y114 w78 h16, Burn speed:
    Gui Add, DropDownList, x133 y112 w63, Fastest||Fast|Medium|Slow
    Gui Add, CheckBox, x33 y140 w321 h16 Checked, Automatically &eject the disc after burning
    Gui Add, GroupBox, x19 y171 w353 h67, Audio CDs
    Gui Add, CheckBox, x33 y192 w321 h16 Checked, Apply &volume leveling across tracks
    Gui Add, CheckBox, x33 y214 w321 h16 Checked, Burn CD without &gaps between tracks
    Gui Add, GroupBox, x19 y247 w353 h67, Data Discs
    Gui Add, Text, x33 y270 w278 h16, Add a list of all burned files to the disc in this format:
    Gui Add, DropDownList, x301 y265 w47, WPL||M3U
    Gui Add, CheckBox, x33 y294 w321 h16 Checked, Use media information to arrange files in &folders on the disc

; Performance tab
Gui Tab, 5
    Gui Add, Picture, x16 y54 w32 h32 Icon20, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Specify connection speed`, buffering`, and playback settings.
    Gui Add, GroupBox, x16 y93 w366 h93, Connection speed
    Gui Add, Radio, x34 y112 w270 h16 Checked, &Detect connection speed (recommended)
    Gui Add, Radio, x34 y132 w270 h16, &Choose connection speed:
    Gui Add, DropDownList, x52 y151 w252 Disabled, Modem (28.8 Kbps)||Modem (33.6 Kbps)|Modem (56 Kbps)|ISDN    (64 Kbps)|Dual ISDN  (128 Kbps)|DSL/Cable (256 Kbps)|DSL/Cable (384 Kbps)|DSL/Cable (768 Kbps)|T1    (1.5 Mbps)|LAN (10 Mbps or more)
    Gui Add, GroupBox, x16 y190 w366 h78, Network buffering
    Gui Add, Radio, x34 y210 w321 h16 Checked, &Use default buffering (recommended)
    Gui Add, Radio, x34 y229 w57 h24, &Buffer
    Gui Add, Edit, x97 y231 w38 h20 Disabled, 5
    Gui Add, Text, x145 y234 w201 h16, seconds of content
    Gui Add, GroupBox, x19 y271 w363 h185, DVD and video playback
    Gui Add, CheckBox, x28 y291 w267 h15, Dro&p frames to keep audio and video synchronized
    Gui Add, CheckBox, x28 y310 w252 h15 Checked, Use video &smoothing
    Gui Add, CheckBox, x28 y328 w252 h15 Checked, Display &full-screen controls
    Gui Add, CheckBox, x28 y349 w252 h15 Checked, Turn on Direct&X Video Acceleration for WMV files
    Gui Add, Text, x28 y372 w117 h13, Video border color:
    Gui Add, Text, x28 y388 w90 h24 +0x4
    Gui Add, Button, x127 y388 w72 h24, Chan&ge...

; Library tab
Gui Tab, 6
    Gui Add, Picture, x16 y54 w32 h32 Icon77, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Specify settings for organizing your digital media collection.
    Gui Add, GroupBox, x16 y93 w366 h117, Media Library Settings
    Gui Add, CheckBox, x28 y112 w339 h16 Checked, Add video files found in the Pictures library
    Gui Add, CheckBox, x28 y135 w339 h16, Add volume leveling information values for new files
    Gui Add, CheckBox, x28 y158 w339 h16 Checked, Delete files from &computer when deleted from library
    Gui Add, CheckBox, x28 y180 w339 h16, Automatically &preview songs on track title hover
    Gui Add, GroupBox, x16 y219 w366 h172, Automatic media information updates for files
    Gui Add, CheckBox, x28 y237 w333 h26 Checked, Retrieve additional information &from the Internet
    Gui Add, Radio, x52 y268 w318 h16 Checked, Only a&dd missing information
    Gui Add, Radio, x52 y291 w318 h16, Ov&erwrite all media information
    Gui Add, CheckBox, x28 y317 w317 h16, Rename &music files using rip music settings
    Gui Add, CheckBox, x28 y340 w314 h16, &Rearrange music in rip music folder`, using rip music settings
    Gui Add, CheckBox, x28 y362 w314 h16 Checked, Maintain my &star ratings as global ratings in files

; Plug-ins tab
Gui Tab, 7
    Gui Add, Picture, x16 y54 w32 h32 Icon78, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Add and configure plug-ins.
    Gui Add, Text, x19 y96 w114 h13, &Category:
    Gui Add, ListView, x19 y112 w120 h260 -Hdr, Category
    LV_Add("select", "Visualization")
    LV_Add("", "Now Playing")
    LV_Add("", "Window")
    LV_Add("", "Background")
    LV_Add("", "Video DSP")
    LV_Add("", "Audio DSP")
    LV_Add("", "Other DSP")
    LV_Add("", "Renderer")
    Gui Add, Text, x150 y96 w234 h13, Visualization:
    Gui Add, ListView, x150 y112 w227 h130 -Hdr, Visualization
    LV_Add("select", "Alchemy")
    LV_Add("", "Bars and Waves")
    LV_Add("", "Battery")
    Gui Add, GroupBox, x150 y249 w228 h124, Alchemy
    Gui Add, Edit, x160 y268 w209 h65 +Multi +ReadOnly -E0x200, Alchemy
    Gui Add, Button, x210 y340 w75 h23, &Properties
    Gui Add, Button, x292 y340 w75 h23 Disabled, &Remove
    Gui Font,, Segoe UI
    Gui Add, Link, x19 y382 w269 h16, <a>Look for plug-ins on the web</a>
    Gui Add, Link, x19 y398 w269 h16, <a>Look for visualizations on the web</a>
    Gui Font

; Privacy tab
Gui Tab, 8
    Gui Add, Picture, x16 y54 w32 h32 Icon79, % wmploc
    Gui Add, Text, x58 y57 w324 h16, Specify privacy settings
    Gui Font,, Segoe UI
    Gui Add, Link, x58 y73 w324 h16, <a>Read the privacy statement online</a>
    Gui Font
    Gui Add, GroupBox, x16 y93 w366 h114, Enhanced Playback and Device Experience
    Gui Add, CheckBox, x28 y112 w348 h16 Checked, Display media &information from the Internet
    Gui Add, CheckBox, x28 y130 w348 h16 Checked, Up&date music files by retrieving media info from the Internet
    Gui Add, CheckBox, x28 y148 w348 h16 Checked, Dow&nload usage rights automatically when I play or sync a file
    Gui Add, CheckBox, x28 y166 w348 h16 Checked, Automatically check if protected files need to be &refreshed
    Gui Add, CheckBox, x28 y184 w348 h16 Checked, Set cloc&k on devices automatically
    Gui Add, GroupBox, x16 y210 w366 h75, Enhanced Content Provider Services
    Gui Add, CheckBox, x28 y229 w348 h13, Send &unique Player ID to content providers
    Gui Add, Text, x28 y249 w246 h26, Click Cookies to view or change privacy settings that affect cookies.
    Gui Add, Button, x286 y250 w84 h23, Cooki&es...
    Gui Add, GroupBox, x16 y289 w366 h55, Windows Media Player Customer Experience Improvement Program
    Gui Add, CheckBox, x28 y305 w348 h33, I want to help make &Microsoft software and services even better by sending Player usage data to Microsoft.
    Gui Add, GroupBox, x16 y348 w366 h102, History
    Gui Add, Text, x28 y366 w252 h16, Store and display a list of recent/frequently played:
    Gui Add, CheckBox, x31 y385 w84 h16 Checked, Mu&sic
    Gui Add, CheckBox, x31 y405 w84 h16 Checked, &Pictures
    Gui Add, CheckBox, x121 y385 w84 h16 Checked, &Video
    Gui Add, CheckBox, x121 y405 w84 h16 Checked, P&laylists
    Gui Add, Button, x286 y385 w84 h23, Clear &History
    Gui Add, Text, x28 y427 w252 h13, Clear caches for CDs`, DVDs`, and devices.
    Gui Add, Button, x286 y421 w84 h23, Clear &Caches

; Security tab
Gui Tab, 9
    Gui Add, Picture, x16 y54 w32 h32 Icon79, % wmploc
    Gui Add, Text, x58 y57 w311 h34, Choose whether to allow script commands and rich media streams to be run and customize zone settings.
    Gui Add, GroupBox, x16 y101 w366 h148, Content
    Gui Add, CheckBox, x30 y119 w333 h24, &Run script commands when present
    Gui Add, CheckBox, x30 y148 w333 h26 Checked, Run &script commands and rich media streams when the Player is in a Web page
    Gui Add, CheckBox, x30 y184 w333 h26, Play &enhanced content that uses Web pages without prompting
    Gui Add, CheckBox, x30 y216 w333 h24, Show local &captions when present
    Gui Add, GroupBox, x16 y255 w366 h132, Security Zone
    Gui Add, Text, x30 y278 w327 h55, The Player uses Internet security zone settings to display Web content`, such as that provided in the Guide and online stores.
    Gui Font,, Segoe UI
    Gui Add, Link, x30 y348 w225 h16, <a>Read the security statement online</a>
    Gui Font
    Gui Add, Button, x262 y338 w105 h23, &Zone Settings...

; DVD tab
Gui Tab, 10
    Gui Add, Picture, x16 y54 w32 h32 Icon10, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Set playback restrictions and language settings for DVDs.
    Gui Add, GroupBox, x16 y93 w366 h75, DVD Playback Restrictions
    Gui Add, Text, x28 y112 w342 h23, Current rating restriction:  None
    Gui Add, Button, x28 y135 w75 h23, &Change...
    Gui Add, GroupBox, x16 y177 w366 h91, Language settings
    Gui Add, Text, x28 y197 w342 h39, Click Defaults to set the default languages to use when playing DVDs and other content.
    Gui Add, Button, x28 y236 w75 h23, &Defaults...
    Gui Add, Button, x28 y275 w75 h23 Disabled, Ad&vanced...

; Network tab
Gui Tab, 11
    Gui Add, Picture, x16 y54 w32 h32 Icon13, % wmploc
    Gui Add, Text, x58 y57 w318 h33, Specify settings for playing digital media content that is streamed from the Internet.
    Gui Add, GroupBox, x16 y93 w366 h106, Protocols for MMS URLs
    Gui Add, Text, x25 y112 w351 h26, Try to use the following protocols when receiving an MMS URL:
    Gui Add, CheckBox, x34 y138 w74 h16 Checked, RTSP/&UDP
    Gui Add, CheckBox, x34 y158 w72 h16 Checked, RTSP/&TCP
    Gui Add, CheckBox, x34 y177 w72 h16 Checked, &HTTP
    Gui Add, CheckBox, x116 y158 w66 h16, U&se ports
    Gui Font,, Segoe UI
    Gui Add, Edit, x184 y156 w75 h20 Disabled, 7000-7007
    Gui Font
    Gui Add, Text, x268 y158 w102 h13, to receive data
    Gui Add, GroupBox, x16 y210 w366 h42, Multicast Streams
    Gui Add, CheckBox, x34 y229 w300 h16 Checked, Allow the player to receive &multicast streams
    Gui Add, GroupBox, x16 y258 w366 h127, Streaming proxy settings
    Gui Add, ListView, x34 y278 w336 h70, Protocol|Proxy
    LV_Add("", "HTTP", "Browser")
    LV_Add("", "RTSP", "None")
    LV_ModifyCol(1, 78)
    LV_ModifyCol(2, 234)
    Gui Add, Text, x34 y359 w255 h13, S&elect the protocol above`, and then click Configure.
    Gui Add, Button, x295 y354 w75 h23, &Configure...
    Gui Add, Picture, x18 y396 w32 h32 Icon74, % wmploc
    Gui Add, Text, x57 y395 w320 h39, To change the proxy settings used for online stores`, use Internet Options in Control Panel.

Gui Tab
Gui Add, Button, x73 y470 w75 h23, OK
Gui Add, Button, x154 y470 w75 h23, Cancel
Gui Add, Button, x235 y470 w75 h23 Disabled, &Apply
Gui Add, Button, x316 y470 w75 h23, Help
Gui Show, w397 h500, Windows Media Player Options - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
