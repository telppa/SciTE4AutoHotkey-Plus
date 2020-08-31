; FileZilla 3.6.0.2 Settings Dialog
#NoEnv
#Warn
#SingleInstance Force
SetBatchLines -1

Gui Font, s8, Ms Shell Dlg 2
Gui Add, Text, x7 y7 w61 h13, Select &page:
Gui Add, TreeView, gShowOptions x7 y25 w165 h273
Connection := TV_Add("Connection",, "Expand")
    FTP := TV_Add("FTP", Connection, "Expand")
        TV_Add("Active mode", FTP)
        TV_Add("Passive mode", FTP)
        TV_Add("FTP Proxy", FTP)
    TV_Add("SFTP", Connection)
    TV_Add("Generic proxy", Connection)
Transfers := TV_Add("Transfers",, "Expand")
    TV_Add("File Types", Transfers)
    TV_Add("File exists action", Transfers)
Interface := TV_Add("Interface",, "Expand")
    TV_Add("Themes", Interface)
    TV_Add("Date/time format", Interface)
    TV_Add("Filesize format", Interface)
    TV_Add("File lists", Interface)
TV_Add("Language")
FileEditing := TV_Add("File editing",, "Expand")
    TV_Add("Filetype associations", FileEditing)
TV_Add("Update Check")
TV_Add("Logging")
TV_Add("Debug")

Gui Add, Button, x7 y303 w165 h23 Default, OK
Gui Add, Button, x7 y331 w165 h23, &Cancel

Gui Add, Tab2, vTab x7 y365 w588 h22 -Wrap +Theme, Connection|FTP|Active mode|Passive mode|FTP Proxy|SFTP|Generic proxy|Transfers|File Types|File exists action|Interface|Themes|Date/time format|Filesize format|File lists|Language|File editing|Filetype associations|Update check|Logging|Debug

; Connection
Gui Add, GroupBox, x179 y7 w415 h78, Overview
Gui Add, Text, x188 y24 w359 h26, For more detailed information about what these options do`, please run the`nnetwork configuration wizard.
Gui Add, Button, x188 y53 w173 h23, &Run configuration wizard now...
Gui Add, GroupBox, x179 y85 w415 h77, Timeout
Gui Add, Text, x188 y106 w96 h13, Time&out in seconds:
Gui Add, Edit, x288 y102 w40 h21, 20
Gui Add, Text, x332 y106 w104 h13, (5-9999`, 0 to disable)
Gui Add, Text, x188 y127 w376 h26, If no data is sent or received during an operation for longer than the specified`ntime`, the connection will be closed and FileZilla will try to reconnect.
Gui Add, GroupBox, x179 y162 w415 h103, Reconnection settings
Gui Add, Text, x188 y183 w135 h13, &Maximum number of retries:
Gui Add, Edit, x370 y179 w50 h21, 2
Gui Add, Text, x425 y183 w30 h13, (0-99)
Gui Add, Text, x188 y209 w177 h13, &Delay between failed login attempts:
Gui Add, Edit, x370 y205 w50 h21, 5
Gui Add, Text, x425 y209 w78 h13, (0-999 seconds)
Gui Add, Text, x188 y230 w390 h26, Please note that some servers might ban you if you try to reconnect too often or`nin too short intervals.

Gui Show, w601 h363, FileZilla Settings - Sample GUI

; FTP
Gui Tab, 2
Gui Add, GroupBox, x179 y7 w415 h106, Transfer Mode
Gui Add, Radio, x188 y24 w133 h13 Checked, Pa&ssive (recommended)
Gui Add, Radio, x188 y42 w49 h13, &Active
Gui Add, CheckBox, x188 y60 w247 h13 Checked, Allow &fall back to other transfer mode on failure
Gui Add, Text, x188 y78 w362 h26, If you have problems to retrieve directory listings or to transfer files`, try to`nchange the default transfer mode.
Gui Add, GroupBox, x179 y113 w415 h243, FTP Keep-alive
Gui Add, CheckBox, x188 y134 w174 h13, Send FTP &keep-alive commands
Gui Add, Text, x188 y165 w373 h26, A proper server does not require this. Contact the server administrator if you`nneed this.

; Active mode
Gui Tab, 3
Gui Add, GroupBox, x179 y7 w415 h141, Limit local ports
Gui Add, CheckBox, x189 y29 w170 h13, &Limit local ports used by FileZilla
Gui Add, Text, x207 y47 w369 h39, By default uses any available local port to establish transfers in active mode.`nIf you want to limit FileZilla to use only a small range of ports`, please enter`nthe port range below.
Gui Add, Text, x207 y95 w107 h13, Lo&west available port:
Gui Add, Edit, x321 y91 w50 h21 Disabled, 6000
Gui Add, Text, x207 y121 w109 h13, &Highest available port:
Gui Add, Edit, x321 y117 w50 h21 Disabled, 7000
Gui Add, GroupBox, x179 y148 w415 h180, Active mode IP
Gui Add, Text, x188 y165 w374 h13, In order to use active mode`, FileZilla needs to know your external IP address.
Gui Add, Radio, x188 y181 w280 h13 Checked, &Ask your operating system for the external IP address
Gui Add, Radio, x188 y197 w159 h13, &Use the following IP address:
Gui Add, Edit, x205 y213 w100 h21 Disabled
Gui Add, Text, x205 y234 w345 h13, Use this if you're behind a router and have a static external IP address.
Gui Add, Radio, x188 y250 w248 h13, &Get external IP address from the following URL:
Gui Add, Edit, x205 y266 w210 h21 Disabled, http://ip.filezilla-project.org/ip.php
Gui Add, Text, x205 y290 w210 h13, Default: http://ip.filezilla-project.org/ip.php
Gui Add, CheckBox, x188 y306 w264 h13 Checked Disabled, &Don't use external IP address on local connections.

; Passive mode
Gui Tab, 4
Gui Add, GroupBox, x179 y7 w415 h84, Passive mode
Gui Add, Text, x188 y24 w375 h26, Some misconfigured remote servers which are behind a router`, may reply with`ntheir local IP address.
Gui Add, Radio, x188 y53 w232 h13 Checked, &Use the server's external IP address instead
Gui Add, Radio, x188 y69 w134 h13, &Fall back to active mode

; FTP Proxy
Gui Tab, 5
Gui Add, GroupBox, x179 y7 w415 h349, FTP Proxy
Gui Add, Text, x189 y24 w94 h13, Type of FTP Proxy:
Gui Add, Radio, x189 y42 w44 h13 Checked, &None
Gui Add, Radio, x189 y60 w90 h13, USER@&HOST
Gui Add, Radio, x189 y78 w41 h13, &SITE
Gui Add, Radio, x189 y96 w46 h13, &OPEN
Gui Add, Radio, x189 y114 w55 h13, Cus&tom
Gui Add, Edit, x206 y132 w378 h79 Disabled
Gui Add, Text, x206 y211 w106 h13, Format specifications:
Gui Add, Text, x206 y224 w49 h13, `%h - Host
Gui Add, Text, x275 y224 w75 h13, `%u - Username
Gui Add, Text, x370 y224 w73 h13, `%p - Password
Gui Add, Text, x206 y237 w338 h26, `%a - Account (Lines containing this will be omitted if not using Account`nlogontype)
Gui Add, Text, x206 y263 w78 h13, `%s - Proxy user
Gui Add, Text, x304 y263 w106 h13, `%w - Proxy password
Gui Add, Text, x189 y285 w57 h13, P&roxy host:
Gui Add, Edit, x276 y281 w100 h21 Disabled
Gui Add, Text, x396 y285 w57 h13, Proxy &user:
Gui Add, Edit, x458 y281 w100 h21 Disabled
Gui Add, Text, x189 y311 w82 h13, Pro&xy password:
Gui Add, Edit, x276 y307 w100 h21 Disabled
Gui Add, Text, x189 y333 w305 h13, Note: This only works with plain`, unencrypted FTP connections.

; SFTP
Gui Tab, 6
Gui Add, GroupBox, x179 y7 w415 h349, Public Key Authentication
Gui Add, Text, x189 y29 w383 h26, To support public key authentication`, FileZilla needs to know the private keys to`nuse.
Gui Add, Text, x189 y65 w64 h13, Private &keys:
Gui Add, ListView, x189 y83 w395 h204, Filename|Comment|Data
LV_ModifyCol(1, 150)
LV_ModifyCol(2, 100)
Gui Add, Button, x300 y292 w84 h23, &Add keyfile...
Gui Add, Button, x389 y292 w78 h23 Disabled, &Remove key
Gui Add, Text, x189 y320 w372 h26, Alternatively you can use the Pageant tool from PuTTY to manage your keys`,`nFileZilla does recognize Pageant.

; Generic proxy
Gui Tab, 7
Gui Add, GroupBox, x179 y7 w415 h349, Generic proxy
Gui Add, Text, x189 y24 w111 h13, Type of generic proxy:
Gui Add, Radio, x189 y42 w44 h13 Checked, &None
Gui Add, Radio, x189 y60 w188 h13, &HTTP/1.1 using CONNECT method
Gui Add, Radio, x189 y78 w61 h13, &SOCKS 5
Gui Add, Text, x189 y100 w57 h13, P&roxy host:
Gui Add, Edit, x276 y96 w308 h21 Disabled
Gui Add, Text, x189 y126 w56 h13, Proxy &port:
Gui Add, Edit, x276 y122 w50 h21 Disabled, 0
Gui Add, Text, x189 y152 w57 h13, Proxy &user:
Gui Add, Edit, x276 y148 w308 h21 Disabled
Gui Add, Text, x189 y178 w82 h13, Pro&xy password:
Gui Add, Edit, x276 y174 w308 h21 Disabled
Gui Add, Text, x189 y200 w336 h13, Note: Using a generic proxy forces passive mode on FTP connections.

; Transfers
Gui Tab, 8
Gui Add, GroupBox, x179 y7 w415 h97, Concurrent transfers
Gui Add, Text, x188 y28 w161 h13, Maximum simultaneous &transfers:
Gui Add, Edit, x353 y24 w40 h21, 2
Gui Add, Text, x397 y28 w30 h13, (1-10)
Gui Add, Text, x188 y53 w152 h13, Limit for concurrent &downloads:
Gui Add, Edit, x353 y49 w40 h21, 0
Gui Add, Text, x397 y53 w67 h13, (0 for no limit)
Gui Add, Text, x188 y78 w138 h13, Limit for concurrent &uploads:
Gui Add, Edit, x353 y74 w40 h21, 0
Gui Add, Text, x397 y78 w67 h13, (0 for no limit)
Gui Add, GroupBox, x179 y104 w415 h138, Speed limits
Gui Add, CheckBox, x188 y125 w109 h13, &Enable speed limits
Gui Add, Text, x188 y146 w73 h13, Download &limit:
Gui Add, Edit, x271 y142 w60 h21 Disabled, 100
Gui Add, Text, x336 y146 w42 h13, (in KiB/s)
Gui Add, Text, x188 y172 w59 h13, U&pload limit:
Gui Add, Edit, x271 y168 w60 h21 Disabled, 20
Gui Add, Text, x336 y172 w42 h13, (in KiB/s)
Gui Add, Text, x188 y198 w78 h13, &Burst tolerance:
Gui Add, DropDownList, x271 y194 w75 Disabled, Normal||High|Very high
Gui Add, Text, x188 y220 w0 h13
Gui Add, GroupBox, x179 y242 w415 h114, Filter invalid characters in filenames
Gui Add, CheckBox, x188 y259 w172 h13 Checked, Enable invalid character &filtering
Gui Add, Text, x188 y277 w396 h26, When enabled`, characters that are not supported by the local operating system in`nfilenames are replaced if downloading such a file.
Gui Add, Text, x188 y312 w153 h13, &Replace invalid characters with:
Gui Add, Edit, x346 y308 w25 h21 Center, _
Gui Add, Text, x188 y334 w272 h13, The following characters will be replaced: \ / : * ? " < > |

; File Types
Gui Tab, 9
Gui Add, GroupBox, x179 y7 w415 h77, Default transfer type:
Gui Add, Radio, x188 y28 w42 h13 Checked, &Auto
Gui Add, Radio, x188 y45 w47 h13, A&SCII
Gui Add, Radio, x188 y62 w49 h13, &Binary
Gui Add, GroupBox, x179 y94 w415 h262, Automatic file type classification
Gui Add, Text, x189 y116 w206 h13, Treat the &following filetypes as ASCII files:
Gui Add, ListView, x189 y133 w100 h150 -Hdr, filetypes
FileTypes := ["am", "asp", "bat", "c", "cfm", "cgi", "conf", "cpp", "css", "dhtml", "diz", "h", "hpp", "htm", "html", "in", "inc", "java", "js", "jsp", "lua", "m4", "mak", "md5", "nfo", "nsi", "pas", "patch", "php", "phtml", "pl", "po", "py", "qmail", "sh", "shtml", "sql", "svg", "tcl", "tpl", "txt", "vbs", "xhtml", "xml", "xrc"]
For Each, FileType in FileTypes
{
    LV_Add("", FileType)
}
LV_ModifyCol(1, 40)
Gui Add, Edit, x294 y133 w90 h21
Gui Add, Button, x294 y159 w90 h23 Disabled, A&dd
Gui Add, Button, x294 y187 w90 h23 Disabled, &Remove
Gui Add, Text, x389 y133 w189 h39, If you enter the wrong filetypes`, those`nfiles may get corrupted when`ntransferred.
Gui Add, CheckBox, x189 y287 w218 h13 Checked, Treat files &without extension as ASCII file
Gui Add, CheckBox, x189 y304 w150 h13 Checked, &Treat dotfiles as ASCII files
Gui Add, Text, x189 y321 w271 h13, Dotfiles are filenames starting with a dot`, e.g. .htaccess

; File exists action
Gui Tab, 10
Gui Add, Text, x179 y7 w350 h13, Select default action to perform if target file of a transfer already exists.
Gui Add, GroupBox, x179 y25 w415 h75, Default file exists action
Gui Add, Text, x187 y49 w57 h13, &Downloads:
Gui Add, DropDownList, x249 y45 w267, Ask for action||Overwrite file|Overwrite file if source file newer|Overwrite file if size differs|Overwrite file if size differs or source file is newer|Resume file transfer|Rename file|Skip file
Gui Add, Text, x187 y75 w43 h13, &Uploads:
Gui Add, DropDownList, x249 y71 w267, Ask for action||Overwrite file|Overwrite file if source file newer|Overwrite file if size differs|Overwrite file if size differs or source file is newer|Resume file transfer|Rename file|Skip file
Gui Add, Text, x179 y105 w403 h39, If using 'overwrite if newer'`, your system time has to be synchronized with the`nserver. If the time differs (e.g. different timezone)`, specify a timezone offset in the`nsite manager.
Gui Add, CheckBox, x179 y155 w148 h13, A&llow resume of ASCII files
Gui Add, Text, x197 y171 w373 h26, Resuming ASCII files can cause problems if server uses a different line ending`nformat than the client.

; Interface
Gui Tab, 11
Gui Add, GroupBox, x179 y7 w415 h65, Layout
Gui Add, Text, x188 y28 w167 h13, &Layout of file and directory panes:
Gui Add, DropDownList, x360 y24 w86, Classic||Explorer|Widescreen|Blackboard
Gui Add, CheckBox, x188 y50 w159 h13, &Swap local and remote panes
Gui Add, GroupBox, x179 y77 w415 h47, Message log position
Gui Add, Text, x188 y98 w136 h13, &Position of the message log:
Gui Add, DropDownList, x329 y94 w193, Above the file lists||Next to the transfer queue|As tab in the transfer queue pane
Gui Add, GroupBox, x179 y129 w415 h93, Behaviour
Gui Add, CheckBox, x188 y146 w131 h13 Checked, D&o not save passwords
Gui Add, CheckBox, x188 y164 w94 h13, &Minimize to tray
Gui Add, CheckBox, x188 y182 w393 h13 Checked, P&revent system from entering idle sleep during transfers and other operations
Gui Add, CheckBox, x188 y200 w183 h13, S&how the Site Manager on startup
Gui Add, GroupBox, x179 y227 w415 h39, Transfer Queue
Gui Add, CheckBox, x188 y244 w310 h13, &Display momentary transfer speed instead of average speed

; Themes
Gui Tab, 12
Gui Add, GroupBox, x179 y7 w415 h89, Select Theme
Gui Add, Text, x189 y33 w37 h13, &Theme:
Gui Add, DropDownList, x232 y29 w90, Classic|Blukis|Cyril|LonE|Minimal||OpenCrystal|Tango
Gui Add, Text, x189 y55 w38 h13, Author:
Gui Add, Text, x232 y55 w107 h13, Frédéric Duarte
Gui Add, Text, x189 y73 w29 h13, Email:
Gui Add, Text, x232 y73 w107 h13, pgase.filezilla@free.fr
Gui Add, GroupBox, x179 y96 w415 h260, Available sizes
Gui Add, Progress, x189 y118 w395 h228 cWhite, 100
Gui Add, Text, x192 y121 w75 h23 +BackgroundTrans, 16x16
Gui Add, Text, x198 y145 w43 h13 +BackgroundTrans, Preview:

; Date/time
Gui Tab, 13
Gui Add, GroupBox, x179 y7 w415 h138, Date formatting
Gui Add, Radio, x189 y29 w116 h13 Checked, Use system &defaults
Gui Add, Radio, x189 y47 w178 h13, &ISO 8601 (example: 2007-09-15)
Gui Add, Radio, x189 y65 w55 h13, C&ustom
Gui Add, Edit, x206 y83 w100 h21 Disabled
Gui Add, Text, x311 y87 w116 h13, (example: `%Y-`%m-`%d)
Gui Add, Text, x206 y109 w354 h26, Please read http://wiki.filezilla-project.org/Date_and_Time_formatting for`ndetails
Gui Add, GroupBox, x179 y145 w415 h138, Time formatting
Gui Add, Radio, x189 y167 w116 h13 Checked, U&se system defaults
Gui Add, Radio, x189 y185 w150 h13, I&SO 8601 (example: 15:47)
Gui Add, Radio, x189 y203 w55 h13, Cus&tom
Gui Add, Edit, x206 y221 w100 h21 Disabled
Gui Add, Text, x311 y225 w96 h13, (example: `%H:`%M)
Gui Add, Text, x206 y247 w354 h26, Please read http://wiki.filezilla-project.org/Date_and_Time_formatting for`ndetails

; Filesize format
Gui Tab, 14
Gui Add, GroupBox, x179 y7 w415 h143, Size formatting
Gui Add, Radio, x189 y29 w115 h13 Checked, &Display size in bytes
Gui Add, Radio, x189 y47 w236 h13, &IEC binary prefixes (e.g. 1 KiB = 1024 bytes)
Gui Add, Radio, x189 y65 w300 h13, &Binary prefixes using SI symbols. (e.g. 1 KB = 1024 bytes)
Gui Add, Radio, x189 y83 w302 h13, D&ecimal prefixes using SI symbols (e.g. 1 KB = 1000 bytes)
Gui Add, CheckBox, x189 y101 w140 h13 Checked, &Use thousands separator
Gui Add, Text, x189 y123 w126 h13, Number of decimal places:
Gui Add, Edit, x320 y119 w32 h21 Disabled, 1
Gui Add, UpDown, x353 y119 w18 h21 Disabled -16
Gui Add, GroupBox, x179 y150 w415 h125, Examples
Gui Add, Text, x277 y172 w12 h13, 12
Gui Add, Text, x271 y188 w18 h13, 100
Gui Add, Text, x261 y204 w28 h13, 1.234
Gui Add, Text, x239 y220 w50 h13, 1.058.817
Gui Add, Text, x227 y236 w62 h13, 123.456.789
Gui Add, Text, x189 y252 w100 h13, 63.674.225.613.426

; File lists
Gui Tab, 15
Gui Add, GroupBox, x179 y7 w415 h47, Sorting
Gui Add, Text, x188 y28 w68 h13, Sorting &mode:
Gui Add, DropDownList, x261 y24 w169, Prioritize directories (default)||Keep directories on top|Sort directories inline
Gui Add, GroupBox, x179 y54 w415 h78, Directory comparison
Gui Add, Text, x188 y71 w383 h26, If using timestamp based comparison`, consider two files equal if their timestamp`ndifference does not exceed this threshold.
Gui Add, Text, x188 y106 w168 h13, Comparison &threshold (in minutes):
Gui Add, Edit, x361 y102 w40 h21, 1
Gui Add, GroupBox, x179 y132 w415 h73, Double-click action
Gui Add, Text, x188 y153 w130 h13, &Double-click action on files:
Gui Add, DropDownList, x354 y149 w95, Transfer||Add to queue|View/Edit|None
Gui Add, Text, x188 y179 w161 h13, D&ouble-click action on directories:
Gui Add, DropDownList, x354 y175 w102, Enter directory||Transfer|Add to queue|None

; Language
Gui Tab, 16
Gui Add, GroupBox, x179 y7 w415 h349, Language
Gui Add, Text, x189 y29 w81 h13, &Select language:
Gui Add, ListBox, x189 y47 w151 h277, Default system language||
Gui Add, Text, x189 y333 w270 h13, If you change the language`, you should restart FileZilla.

; File editing
Gui Tab, 17
Gui Add, Text, x184 y12 w71 h13, &Default editor:
Gui Add, Radio, x184 y30 w139 h13 Checked, Do &not use default editor
Gui Add, Radio, x184 y48 w211 h13, &Use system's default editor for text files
Gui Add, Radio, x184 y66 w109 h13, Use &custom editor:
Gui Add, Edit, x201 y85 w308 h21 Disabled
Gui Add, Button, x514 y84 w75 h23 Disabled, &Browse...
Gui Add, Text, x201 y112 w270 h13, Command and its arguments should be properly quoted.
Gui Add, Text, x184 y135 w403 h2 0x10
Gui Add, Radio, x184 y147 w191 h13 Checked, U&se filetype associations if available
Gui Add, Radio, x184 y165 w141 h13 Disabled, &Always use default editor
Gui Add, Text, x184 y188 w403 h2 0x10
Gui Add, CheckBox, x184 y200 w308 h13 Checked, &Watch locally edited files and prompt to upload modifications

; Filetype associations
Gui Tab, 18
Gui Add, GroupBox, x184 y12 w405 h339, Filetype associations
Gui Add, CheckBox, x194 y34 w195 h13 Checked, &Inherit system's filetype associations
Gui Add, Text, x194 y52 w141 h13, C&ustom filetype associations:
Gui Add, Edit, x194 y70 w385 h235
Gui Add, Text, x194 y310 w354 h13, Format: Extension followed by properly quoted command and arguments.
Gui Add, Text, x194 y328 w277 h13, Example: png "c:\program files\viewer\viewer.exe" -open

; Update check
Gui Tab, 19
Gui Add, GroupBox, x179 y7 w415 h349, Automatic update check
Gui Add, CheckBox, x189 y29 w168 h13, &Enable automatic update check
Gui Add, Text, x189 y49 w198 h13, &Number of days between update checks:
Gui Add, Edit, x392 y45 w30 h21, 365
Gui Add, Text, x427 y49 w80 h13, (At least 7 days)
Gui Add, Button, x189 y82 w140 h23, &Run update check now...
Gui Add, CheckBox, x189 y121 w247 h13, Check for &beta versions and release candidates
Gui Add, Text, x189 y150 w70 h13, Privacy policy:
Gui Add, Text, x189 y166 w361 h26, Only the versions of FileZilla and the operating system you are using will be`nsubmitted to the server.

; Logging
Gui Tab, 20
Gui Add, GroupBox, x179 y7 w415 h349, Logging
Gui Add, CheckBox, x189 y29 w175 h13 Checked, &Show timestamps in message log
Gui Add, CheckBox, x189 y47 w66 h13 Checked, &Log to file
Gui Add, Text, x207 y70 w47 h13, Filename:
Gui Add, Edit, x259 y65 w245 h23, A:\AppData\FileZilla\Logs\filezilla.log
Gui Add, Button, x509 y65 w75 h23, &Browse...
Gui Add, CheckBox, x207 y93 w105 h13 Checked, Limit size of logfile
Gui Add, Text, x225 y115 w26 h13, Limit:
Gui Add, Edit, x256 y111 w60 h21, 10
Gui Add, Text, x321 y115 w17 h13, MiB
Gui Add, Text, x225 y137 w359 h39, If the size of the logfile reaches the limit`, it gets renamed by adding ".1" to`nthe end of the filename (possibly overwriting older logfiles) and a new file`ngets created.
Gui Add, Text, x207 y181 w250 h13, Changing logfile settings requires restart of FileZilla.

; Debug
Gui Tab, 21
Gui Add, GroupBox, x179 y7 w415 h349, Debugging settings
Gui Add, CheckBox, x189 y29 w107 h13, &Show debug menu
Gui Add, Text, x189 y56 w166 h13, &Debug information in message log:
Gui Add, DropDownList, x360 y52 w86, 0 - None||1 - Warning|2 - Info|3 - Verbose|4 - Debug
Gui Add, Text, x189 y78 w391 h26, The higher the debug level`, the more information will be displayed in the message`nlog. Displaying debug information has a negative impact on performance.
Gui Add, Text, x189 y104 w320 h13, If reporting bugs`, please provide logs with "Verbose" logging level.
Gui Add, CheckBox, x189 y122 w142 h13, Show &raw directory listing
Return

ShowOptions:
    TV_GetText(OutputVar, A_EventInfo)
    GuiControl ChooseString, SysTabControl321, % OutputVar
Return

GuiEscape:
GuiClose:
    ExitApp
