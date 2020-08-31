; IDM 6.23
#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Menu Tray, Icon, shell32.dll, 14

Gui -MinimizeBox

Try {
	Gui Add, % "Tab3", x6 y7 w418 h463, General|File types|Save to|Downloads|Connection|Proxy / Socks|Sites Logins|Dial Up / VPN|Sounds
} Catch {
	Gui Add, Tab2, x6 y7 w418 h463, General|File types|Save to|Downloads|Connection|Proxy / Socks|Sites Logins|Dial Up / VPN|Sounds
}

Gui Tab, 1
	Gui Add, Picture, x21 y54 w32 h32 Icon21, rasdlg.dll
	Gui Font, cGray, System
	Gui Add, Text, x78 y58 w318 h18 Right, Browser/System Integration
	Gui Font
	Gui Add, Text, x63 y78 w344 h2 0x10
	Gui Add, CheckBox, x30 y93 w362 h16 Checked, Launch Internet Download Manager on startup
	Gui Add, CheckBox, x30 y112 w363 h16 Checked, Run module for monitoring in IE-based browsers (AOL`, MSN`, Avant`, etc)
	Gui Add, CheckBox, x30 y132 w362 h16, Automatically start downloading of URLs placed to clipboard
	Gui Add, CheckBox, x30 y151 w360 h16 Checked, Use advanced browser integration
	Gui Add, GroupBox, x16 y171 w392 h224, Capture downloads from the following browsers:
	Gui Add, ListView, x30 y187 w362 h135 -Hdr Checked, Browsers
		LV_Add("Check", "Apple Safari")
		LV_Add("Check", "Google Chrome")
		LV_Add("Check", "Internet Explorer")
		LV_Add("Check", "Mozilla")
		LV_Add("Check", "Mozilla Firefox")
		LV_Add("Check", "Opera")
	Gui Add, Text, x34 y356 w357 h2 0x10
	Gui Add, Text, x21 y369 w291 h15 Right, Customize keys to prevent or force downloading with IDM
	Gui Add, Button, x318 y364 w75 h23, Keys...
	Gui Add, Text, x25 y409 w285 h15 Right, Customize IDM menu items in context menu of browsers
	Gui Add, Button, x318 y405 w75 h23, Edit...
	Gui Add, Button, x318 y437 w75 h23, Edit...
	Gui Add, Text, x30 y442 w282 h15 Right, Customize IDM Download panels in browsers 
	Gui Add, Button, x285 y327 w108 h23, Add browser...

Gui Tab, 2
	Gui Add, Picture, x21 y54 w32 h32 Icon213, shell32.dll
	Gui Font, cGray, System
	Gui Add, Text, x78 y58 w318 h18 Right, Downloaded file types
	Gui Font
	Gui Add, Text, x63 y78 w344 h2 0x10
	Gui Add, Button, x315 y174 w75 h23 Default, Default
	Gui Add, Text, x21 y91 w356 h16, Automatically start downloading the following file types:
	Gui Add, Edit, x21 y110 w381 h59, 3GP 7Z AAC ACE AIF ARJ ASF AVI BIN BZ2 EXE GZ GZIP IMG ISO LZH M4A M4V MKV MOV MP3 MP4 MPA MPE MPEG MPG MSI MSU OGG OGV PDF PLJ PPS PPT QT R0* R1* RA RAR RM RMVB SEA SIT SITX TAR TIF TIFF WAV WMA WMV Z ZIP
	Gui Add, Text, x21 y210 w353 h16, Don't start downloading automatically from the following sites:
	Gui Add, Edit, x21 y229 w381 h49 Multi, *.update.microsoft.com download.windowsupdate.com siteseal.thawte.com ecom.cimetz.com *.voice2page.com
	Gui Add, Text, x21 y281 w284 h16, (separate names by spaces)
	Gui Add, Button, x315 y283 w75 h23, Default
	Gui Add, Text, x21 y314 w381 h16, Don't start downloading automatically from the following addresses:
	Gui Add, Button, x21 y333 w137 h23, Edit list ...

Gui Tab, 3
	If (FileExist(A_WinDir . "\System32\imageres.dll")) {
		Gui Add, Picture, x21 y54 w32 h32 Icon176, imageres.dll
	} Else {
		Gui Add, Picture, x21 y54 w32 h32 Icon4, shell32.dll
	}
	Gui Font, cGray, System
	Gui Add, Text, x82 y58 w308 h18 Right, Categories`, file types`, folders
	Gui Font
	Gui Add, Text, x58 y78 w342 h2 0x10
	Gui Add, GroupBox, x21 y88 w380 h208, Save To...
	Gui Add, Text, x30 y115 w182 h16, Category
	Gui Add, DropDownList, x30 y136 w212, General||Compressed|Documents|Music|Programs|Video
	Gui Add, Text, x31 y167 w357 h16, Automatically put in "General" category the following file types:
	Gui Add, Edit, x31 y185 w362 h23 Multi ReadOnly, The file types that are not listed in any other category
	Gui Add, Text, x30 y219 w363 h16, Default download directory for "General" category
	Gui Add, Edit, x31 y239 w281 h23 ReadOnly, C:\Users\Alguimist\Downloads\
	Gui Add, Button, x318 y239 w75 h23, Browse
	Gui Add, CheckBox, x33 y270 w360 h16 Checked, Change folder for "General" category on last selected
	Gui Add, Edit, x30 y349 w281 h23 ReadOnly, C:\Users\Alguimist\AppData\Roaming\IDM\
	Gui Add, Button, x316 y349 w75 h23, Browse
	Gui Add, Text, x30 y377 w363 h68, Temporary directory is required for storing file parts during download.`nIf you have several physical drives on your computer`, you should select different physical drives for temporary directory and "Save To" folders for faster assembling of downloaded files.
	Gui Add, Button, x318 y136 w75 h23 Disabled, Edit...
	Gui Add, Button, x318 y104 w75 h23, New
	Gui Add, CheckBox, x33 y305 w360 h16, Set file creation date as provided by the server 
	Gui Add, GroupBox, x21 y328 w380 h125, Temporary directory

Gui Tab, 4
	Gui Add, Picture, x21 y54 w32 h32 Icon250, shell32.dll
	Gui Font, cGray, System
	Gui Add, Text, x82 y58 w308 h18 Right, Default download settings
	Gui Font
	Gui Add, Text, x58 y78 w342 h2 0x10
	Gui Add, CheckBox, x24 y128 w362 h16 Checked, Show start download dialog
	Gui Add, CheckBox, x24 y151 w365 h16 Checked, Show download complete dialog
	Gui Add, Text, x31 y172 w356 h16, Note: These settings don't relate to queue processing
	Gui Add, CheckBox, x24 y195 w377 h31 Checked, Start downloading immediately while displaying "Download File Info" dialog
	Gui Add, CheckBox, x24 y232 w377 h16 Checked, Show queue selection panel on pressing "Download Later" button
	Gui Add, CheckBox, x24 y257 w378 h16 Checked, Show queue selection panel on closing batch download dialogs
	Gui Add, CheckBox, x24 y281 w377 h16, Ignore file modification time changes when resuming a download
	Gui Add, GroupBox, x21 y304 w380 h107, Virus checking
	Gui Add, Text, x34 y320 w260 h16, Virus scanner program
	Gui Add, Edit, x30 y336 w282 h23
	Gui Add, Button, x318 y336 w75 h23, Browse
	Gui Add, Text, x34 y362 w260 h16, Command line parameters
	Gui Add, Edit, x30 y379 w281 h23
	Gui Add, Text, x21 y416 w369 h16, If a duplicate download link is added:
	Gui Add, DropDownList, x21 y432 w380, Show a dialog and ask what to do.||Add the duplicate with a numbered file name|Add the duplicate and overwrite the existing file|If existing file is complete`, show download complete dialog`; otherwise resume it.
	Gui Add, Button, x318 y88 w75 h23, Edit...
	Gui Add, Text, x21 y93 w287 h16 Right, Customize "Download progress" dialog
	Gui Add, Text, x21 y190 w381 h2 0x10
	Gui Add, Text, x21 y119 w381 h2 0x10

Gui Tab, 5
	If (FileExist(A_WinDir . "\System32\imageres.dll")) {
		Gui Add, Picture, x21 y54 w32 h32 Icon171, imageres.dll
	} Else {
		Gui Add, Picture, x21 y54 w32 h32 Icon18, shell32.dll
	}
	Gui Font, cGray, System
	Gui Add, Text, x81 y58 w311 h18 Right, Connection type
	Gui Font
	Gui Add, Text, x63 y78 w338 h2 0x10
	Gui Add, GroupBox, x21 y94 w380 h52, Connection Type/Speed
	Gui Add, ComboBox, x30 y114 w362, - Select your internet connection -||Low speed: Dial Up modem / ISDN / Bluetooth / Mobile Edge / IrDA|Medium speed: ADSL / DSL /  Mobile 3G / Wi-Fi / Bluetooth 3.0 / other|High speed: Direct connection (Ethernet/Cable) / Wi-Fi / Mobile 4G / other
	Gui Add, GroupBox, x21 y149 w380 h176, Max. connections number
	Gui Add, Text, x40 y169 w222 h16 Right, Default max. conn. number
	Gui Add, DropDownList, x268 y166 w101, 1|2|4|8||16|24|32
	Gui Add, Text, x30 y195 w360 h2 0x10
	Gui Add, Text, x33 y200 w359 h16, Exceptions:
	Gui Add, ListView, x30 y216 w281 h101 Grid, Server|Number
		LV_ModifyCol(1, 200)
		LV_ModifyCol(2, 50)
	Gui Add, Button, x318 y226 w75 h23 Default, New
	Gui Add, Button, x318 y255 w75 h23 Disabled, Delete
	Gui Add, Button, x318 y284 w75 h23 Disabled, Edit
	Gui Add, GroupBox, x21 y330 w380 h89
	Gui Add, CheckBox, x37 y330 w96 h16, Download limits
	Gui Add, Text, x31 y356 w140 h16 Right Disabled, Download no more than
	Gui Add, Edit, x178 y351 w36 h20 Disabled, 200
	Gui Add, Text, x222 y356 w108 h16 Disabled, MBytes
	Gui Add, Text, x93 y375 w78 h16 Right Disabled, every
	Gui Add, Edit, x178 y372 w36 h20 Disabled, 5
	Gui Add, Text, x225 y375 w104 h16 Disabled, hours
	Gui Add, CheckBox, x37 y396 w314 h16 Checked Disabled, Show warning before stopping downloads

Gui Tab, 6
	Gui Add, Picture, x21 y52 w32 h32 Icon19, shell32.dll
	Gui Font, cGray, System
	Gui Add, Text, x64 y58 w222 h18 Right, Proxy / socks configuration
	Gui Font
	Gui Add, Button, x295 y54 w95 h23 Default, Get from IE
	Gui Add, Text, x64 y83 w338 h2 0x10
	Gui Add, CheckBox, x31 y89 w351 h16, Use automatic configuration script
	Gui Add, Text, x30 y114 w53 h15 Disabled, Address
	Gui Add, Edit, x90 y109 w300 h23 Disabled
	Gui Add, Text, x21 y141 w381 h2 0x10
	Gui Add, CheckBox, x31 y148 w134 h16, Use proxy
	Gui Add, Text, x30 y167 w126 h16 Disabled, Proxy server address
	Gui Add, Text, x172 y167 w51 h16 Disabled, Port
	Gui Add, Text, x229 y167 w78 h16 Disabled, UserName
	Gui Add, Text, x313 y167 w78 h16 Disabled, Password
	Gui Add, Edit, x30 y185 w137 h24 Disabled
	Gui Add, Edit, x172 y185 w51 h24 Disabled
	Gui Add, Edit, x229 y185 w78 h24 Disabled
	Gui Add, Edit, x312 y185 w78 h24 Disabled
	Gui Add, Text, x30 y213 w353 h16 Disabled, Use this proxy for the following protocols:
	Gui Add, CheckBox, x30 y232 w42 h16 Checked Disabled, http
	Gui Add, CheckBox, x97 y232 w47 h16 Checked Disabled, https
	Gui Add, CheckBox, x174 y232 w36 h16 Checked Disabled, ftp
	Gui Add, Button, x298 y229 w92 h23 Disabled, Advanced...
	Gui Add, Text, x21 y258 w381 h2 0x10
	Gui Add, CheckBox, x31 y265 w137 h16, Use socks
	Gui Add, Text, x30 y284 w131 h16 Disabled, Socks server address
	Gui Add, Text, x171 y284 w51 h16 Disabled, Port
	Gui Add, Text, x228 y284 w78 h16 Disabled, UserName
	Gui Add, Text, x312 y284 w78 h16 Disabled, Password
	Gui Add, Edit, x30 y304 w137 h24 Disabled
	Gui Add, Edit, x171 y304 w51 h24 Disabled
	Gui Add, Edit, x228 y304 w78 h24 Disabled
	Gui Add, Edit, x312 y304 w78 h24 Disabled
	Gui Add, Radio, x31 y333 w63 h16 Disabled, Socks 4
	Gui Add, Radio, x123 y333 w63 h16 Checked Disabled, Socks 5
	Gui Add, Text, x21 y353 w381 h2 0x10
	Gui Add, Edit, x30 y379 w362 h29 Multi
	Gui Add, Text, x30 y411 w354 h16, Separate names by spaces
	Gui Add, GroupBox, x21 y361 w381 h72, &Do not use proxy server for addresses beginning with:
	Gui Add, Text, x21 y437 w381 h2 0x10
	Gui Add, CheckBox, x30 y445 w329 h16, Use FTP in &PASV mode

Gui Tab, 7
	Gui Add, Picture, x21 y54 w32 h32 Icon112, shell32.dll
	Gui Font, cGray, System
	Gui Add, Text, x73 y58 w323 h18 Right, User names and passwords for servers/sites
	Gui Font
	Gui Add, Text, x63 y78 w338 h2 0x10
	Gui Add, ListView, x21 y93 w383 h280, Site/Path|User|Password
		LV_ModifyCol(1, 250)
		LV_ModifyCol(2, 50)
		LV_ModifyCol(3, 66)
	Gui Add, Button, x30 y380 w75 h23, New
	Gui Add, Button, x124 y380 w75 h23 Disabled, Edit
	Gui Add, Button, x219 y380 w75 h23 Disabled, Remove

Gui Tab, 8
	Gui Add, Picture, x21 y54 w32 h32 Icon3, rasdlg.dll
	Gui Font, cGray, System
	Gui Add, Text, x81 y58 w312 h18 Right, Dial up / VPN settings
	Gui Font
	Gui Add, Text, x63 y78 w338 h2 0x10
	Gui Add, CheckBox, x22 y96 w371 h16, Use Windows Dial Up / VPN Networking
	Gui Add, GroupBox, x21 y119 w381 h179, Connection options
	Gui Add, Text, x37 y148 w86 h16 Right, Connection:
	Gui Add, DropDownList, x130 y143 w234 Disabled
	Gui Add, Text, x37 y184 w86 h16 Right, User name:
	Gui Add, Edit, x130 y180 w176 h23 Disabled
	Gui Add, Text, x34 y219 w89 h16 Right, Password:
	Gui Add, Edit, x130 y214 w176 h23 Disabled
	Gui Add, CheckBox, x130 y247 w173 h16 Disabled, Save password
	Gui Add, Button, x312 y265 w75 h23 Disabled, Apply
	Gui Add, GroupBox, x21 y304 w381 h88, Redial options
	Gui Add, Text, x30 y327 w198 h16 Right, Redial attempts (zero if endlessly):
	Gui Add, Edit, x237 y322 w42 h23 Disabled, 0
	Gui Add, Text, x286 y327 w102 h16, times
	Gui Add, Text, x31 y359 w197 h16 Right, Time between redial attempts:
	Gui Add, Edit, x237 y354 w42 h23 Disabled, 30
	Gui Add, Text, x286 y359 w104 h16, seconds

Gui Tab, 9
	Gui Add, Picture, x21 y54 w32 h32 Icon139, shell32.dll
	Gui Font, cGray, System
	Gui Add, Text, x82 y58 w318 h18 Right, Sound settings
	Gui Font
	Gui Add, Text, x61 y78 w347 h2 0x10
	Gui Add, GroupBox, x25 y96 w383 h306, Select sounds for Internet Download Manager events
	Gui Add, ListView, x33 y112 w366 h250 Grid Checked, Event|Sound file
		LV_Add("", "Download complete")
		LV_Add("", "Download failed")
		LV_Add("", "Queue processing started")
		LV_Add("", "Queue processing stopped/finished")
		LV_ModifyCol(1, 200)
		LV_ModifyCol(2, 200)
	Gui Add, Button, x105 y370 w75 h23 Disabled, Browse...
	Gui Add, Button, x240 y370 w75 h23 Disabled, Play

Gui Tab
Gui Add, Button, x268 y476 w75 h23 Default, OK
Gui Add, Button, x349 y476 w75 h23, Help
Gui Show, w430 h506, Internet Download Manager Configuration - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
