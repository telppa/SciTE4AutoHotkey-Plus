#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui -MinimizeBox +E0x400

Try {
    Gui Add, % "Tab3", x6 y7 w440 h351 +Theme, General|Advanced|Options|Files|Backup|Time|Comment
} Catch {
    Gui Add, Tab2, x6 y7 w440 h351 +Theme, General|Advanced|Options|Files|Backup|Time|Comment
}
    Gui Add, Text, x25 y44 w255 h18, &Archive name
    Gui Add, ComboBox, x25 y62 w404
    Gui Add, Button, x354 y36 w75 h23, &Browse...
    Gui Add, Button, x25 y105 w168 h23, Pro&files...
    Gui Add, GroupBox, x25 y143 w168 h47, Archive format
    Gui Add, Radio, x34 y161 w48 h20 Checked, &RAR
    Gui Add, Radio, x87 y161 w53 h20, RAR&5
    Gui Add, Radio, x142 y161 w48 h20, &ZIP
    Gui Add, Text, x25 y200 w168 h18, &Compression method
    Gui Add, DropDownList, x25 y216 w168, Store|Fastest|Fast|Normal||Good|Best
    Gui Add, Text, x25 y247 w168 h18, D&ictionary size
    Gui Add, DropDownList, x25 y263 w168, 64 KB|128 KB|256 KB|512 KB|1024 KB|2048 KB|4096 KB||
    Gui Add, Text, x25 y294 w168 h16, Split to &volumes`, size
    Gui Add, ComboBox, x25 y310 w120, 5 MB |100 MB |700 MB  (CD700)|4.095 MB  (FAT32)|4.481 MB  (DVD+R)|Autodetect
    Gui Add, DropDownList, x148 y310 w45, B||KB|MB|GB
    Gui Add, Text, x210 y91 w219 h13, &Update mode
    Gui Add, DropDownList, x210 y105 w219, Add and replace files||Add and update files|Fresh existing files only|Ask before overwrite|Skip existing files|Synchronize archive contents
    Gui Add, GroupBox, x210 y143 w219 h143, Archiving options
    Gui Add, CheckBox, x220 y161 w201 h20, &Delete files after archiving
    Gui Add, CheckBox, x220 y180 w201 h20, Create SF&X archive
    Gui Add, CheckBox, x220 y200 w201 h20, Create &solid archive
    Gui Add, CheckBox, x220 y219 w201 h20, Add r&ecovery record
    Gui Add, CheckBox, x220 y239 w201 h20, &Test archived files
    Gui Add, CheckBox, x220 y258 w201 h20, &Lock archive
    Gui Add, Button, x210 y309 w219 h23, Set &password...

Gui Tab, 2
    Gui Add, GroupBox, x25 y40 w240 h104, NTFS options
    Gui Add, CheckBox, x36 y58 w225 h20, Save file &security
    Gui Add, CheckBox, x36 y78 w225 h20, Save file s&treams
    Gui Add, CheckBox, x36 y97 w225 h20 Disabled, Store symbolic &links as links
    Gui Add, CheckBox, x36 y117 w225 h20 Disabled, Store &hard links as links
    Gui Add, GroupBox, x279 y40 w149 h57, Recovery &record
    Gui Add, Edit, x288 y62 w46 h20 Disabled
    Gui Add, UpDown, x299 y62 w18 h20 Disabled, 0
    Gui Add, Text, x336 y65 w87 h13 Disabled, percent
    Gui Add, GroupBox, x25 y154 w240 h88, Volumes
    Gui Add, CheckBox, x36 y172 w225 h20 Disabled, Pause after each &volume
    Gui Add, CheckBox, x36 y192 w225 h20 Disabled, O&ld style volume names
    Gui Add, Edit, x36 y213 w54 h20 Disabled
    Gui Add, UpDown, x55 y213 w18 h20 Disabled, 0
    Gui Add, Text, x91 y216 w170 h13 Disabled, re&covery volumes
    Gui Add, Button, x279 y159 w149 h23, &Compression...
    Gui Add, Button, x279 y188 w149 h23 Disabled, SF&X options...
    Gui Add, GroupBox, x25 y252 w402 h85, System
    Gui Add, CheckBox, x36 y270 w383 h20, &Background archiving
    Gui Add, CheckBox, x36 y289 w383 h20, Turn PC o&ff when done
    Gui Add, CheckBox, x36 y309 w383 h20, &Wait if other WinRAR copies are active

Gui Tab, 3
    Gui Add, GroupBox, x25 y40 w402 h111, Delete mode
    Gui Add, Radio, x36 y58 w383 h20 Checked Disabled, &Delete files
    Gui Add, Radio, x36 y78 w383 h20 Disabled, Move files to &Recycle Bin
    Gui Add, Radio, x36 y97 w383 h20 Disabled, &Wipe files
    Gui Add, CheckBox, x36 y123 w383 h20 Disabled, Wipe files if &password is set
    Gui Add, GroupBox, x25 y161 w402 h65, Archive features
    Gui Add, CheckBox, x36 y179 w383 h20 Disabled, Use &BLAKE2 file checksum
    Gui Add, CheckBox, x36 y198 w383 h20 Disabled, Save &identical files as references
    Gui Add, GroupBox, x25 y235 w402 h85, Quick open information
    Gui Add, Radio, x36 y253 w383 h20 Disabled, Do &not add
    Gui Add, Radio, x36 y273 w383 h20 Checked Disabled, Add for &larger files
    Gui Add, Radio, x36 y292 w383 h20 Disabled, Add for all &files

Gui Tab, 4
    Gui Add, Text, x25 y47 w309 h13, Files to &add
    Gui Add, Edit, x25 y62 w309 h20 -Theme, wrar521.exe
    Gui Add, Button, x339 y60 w90 h23, A&ppend...
    Gui Add, Text, x25 y86 w309 h13, Files to e&xclude
    Gui Add, Edit, x25 y101 w309 h20 -Theme
    Gui Add, Button, x339 y99 w90 h23, Appe&nd...
    Gui Add, Text, x25 y125 w309 h13, Files to s&tore without compression
    Gui Add, Edit, x25 y140 w309 h20 -Theme
    Gui Add, Text, x25 y172 w309 h13, &File paths
    Gui Add, DropDownList, x25 y188 w309, Store relative paths||Store full paths|Do not store paths|Store full paths including the drive letter
    Gui Add, GroupBox, x25 y219 w404 h85, Archive
    Gui Add, CheckBox, x34 y235 w386 h20, Put each file to &separate archive
    Gui Add, CheckBox, x34 y255 w386 h20, Send archive by &email to
    Gui Add, ComboBox, x52 y276 w176 Disabled
    Gui Add, CheckBox, x238 y276 w182 h20 Disabled, and then &delete

Gui Tab, 5
    Gui Add, GroupBox, x25 y40 w404 h143, Backup options
    Gui Add, CheckBox, x36 y58 w381 h20, &Erase destination disk contents before archiving
    Gui Add, CheckBox, x36 y78 w381 h20, Add &only files with attribute "Archive" set
    Gui Add, CheckBox, x36 y97 w381 h20, Clear attr&ibute "Archive" after compressing
    Gui Add, CheckBox, x36 y117 w381 h20, Open &shared files
    Gui Add, CheckBox, x36 y136 w300 h20, &Generate archive name by mask
    Gui Add, Edit, x336 y138 w81 h18 Disabled, yyyymmddhhmmss
    Gui Add, CheckBox, x36 y156 w381 h20, Keep previous file &versions

Gui Tab, 6
    Gui Add, GroupBox, x25 y40 w404 h85, File time to store
    Gui Add, CheckBox, x36 y58 w383 h20 Checked, High precision &modification time
    Gui Add, CheckBox, x36 y78 w383 h20, Store &creation time
    Gui Add, CheckBox, x36 y97 w383 h20, Store &last access time
    Gui Add, GroupBox, x25 y136 w404 h68, Files to process
    Gui Add, Text, x36 y156 w200 h13, Include &files
    Gui Add, DropDownList, x36 y170 w200, Of any time||Older than|Newer than|Modified before|Modified after
    Gui Add, GroupBox, x25 y216 w404 h68, Archive time
    Gui Add, Text, x36 y235 w200 h13, Set &archive time to
    Gui Add, DropDownList, x36 y250 w200, Current system time||Original archive time|Latest file time

Gui Tab, 7
    Gui Add, Text, x25 y44 w311 h18, Load a comment from the &file
    Gui Add, ComboBox, x25 y62 w404
    Gui Add, Button, x339 y36 w90 h23, &Browse...
    Gui Add, Text, x25 y91 w404 h18, Enter a &comment manually
    Gui Add, Edit, x25 y109 w404 h228

Gui Tab
Gui Add, Button, x209 y364 w75 h23 Default, OK
Gui Add, Button, x290 y364 w75 h23, Cancel
Gui Add, Button, x371 y364 w75 h23, Help

Gui Show, w452 h394, Archive name and parameters - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
