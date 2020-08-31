#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui -MinimizeBox +E0x400

Try {
    Gui Add, % "Tab3", x6 y7 w472 h335 +Theme, General|Compression|Paths|File list|Viewer|Security|Integration
} Catch {
    Gui Add, Tab2, x6 y7 w472 h335 +Theme, General|Compression|Paths|File list|Viewer|Security|Integration
}
    Gui Add, GroupBox, x21 y40 w215 h70, System
    Gui Add, CheckBox, x31 y58 w195 h20, &Low priority
    Gui Add, CheckBox, x31 y78 w195 h20, &Multithreading
    Gui Add, GroupBox, x21 y117 w215 h67, History
    Gui Add, CheckBox, x31 y136 w195 h20 Checked, Keep archives &history
    Gui Add, CheckBox, x31 y156 w195 h20 Checked, Allow history in &dialogs
    Gui Add, GroupBox, x21 y192 w215 h111, Toolbar
    Gui Add, CheckBox, x31 y209 w195 h20 Checked, Large &buttons
    Gui Add, CheckBox, x31 y229 w195 h20 Checked, Show buttons &text
    Gui Add, CheckBox, x31 y248 w195 h20, Loc&k toolbars
    Gui Add, Button, x31 y271 w96 h23, Toolb&ars...
    Gui Add, Button, x129 y271 w95 h23, B&uttons...
    Gui Add, GroupBox, x247 y40 w215 h163, Interface
    Gui Add, CheckBox, x261 y58 w188 h20, Activate Wi&zard on start
    Gui Add, CheckBox, x261 y78 w188 h20 Checked, Enable &sound
    Gui Add, CheckBox, x261 y97 w188 h20 Checked, Show archive &comment
    Gui Add, CheckBox, x261 y117 w188 h20, &Reuse existing window
    Gui Add, CheckBox, x261 y136 w188 h20, Al&ways on top
    Gui Add, CheckBox, x261 y156 w188 h20 Checked, W&indows progress bars
    Gui Add, CheckBox, x261 y175 w188 h20 Checked, Taskbar &progress bar
    Gui Add, GroupBox, x247 y211 w215 h91, Logging
    Gui Add, CheckBox, x261 y229 w188 h20, Log &errors to file
    Gui Add, CheckBox, x261 y248 w188 h20 Disabled, Li&mit log file size to
    Gui Add, Edit, x279 y271 w36 h20 Disabled, 1000
    Gui Add, Text, x318 y274 w131 h13 Disabled, kilobytes

Gui Tab, 2
    Gui Add, GroupBox, x21 y40 w222 h75, Compression profiles
    Gui Add, Button, x31 y60 w200 h23 Default, Create &default...
    Gui Add, Button, x31 y84 w200 h23, &Organize...
    Gui Add, GroupBox, x253 y40 w209 h75, Volume size list
    Gui Add, Button, x264 y60 w188 h23, Define &volume sizes...
    Gui Add, GroupBox, x21 y125 w441 h52, Default &folder for archives
    Gui Add, Edit, x31 y149 w339 h20
    Gui Add, Button, x376 y148 w75 h23, Bro&wse...
    Gui Add, GroupBox, x21 y187 w441 h94, Default folder for &extracted files
    Gui Add, Edit, x31 y211 w339 h20
    Gui Add, Button, x376 y209 w75 h23, &Browse...
    Gui Add, CheckBox, x31 y235 w420 h20 Checked, Append archive &name to path
    Gui Add, CheckBox, x31 y255 w420 h20, &Remove redundant folders from extraction path

Gui Tab, 3
    Gui Add, GroupBox, x21 y40 w441 h75, Folder for &temporary files
    Gui Add, Edit, x31 y65 w339 h20, C:\Users\Alguimist\AppData\Local\Temp\
    Gui Add, Button, x376 y63 w75 h23, &Browse...
    Gui Add, CheckBox, x31 y89 w420 h20 Checked, &Use only for removable disks
    Gui Add, GroupBox, x21 y125 w441 h75, &Start-up folder
    Gui Add, Edit, x31 y149 w339 h20 Disabled
    Gui Add, Button, x376 y148 w75 h23, B&rowse...
    Gui Add, CheckBox, x31 y174 w420 h20 Checked, R&estore last working folder on start-up

Gui Tab, 4
    Gui Add, GroupBox, x21 y40 w195 h63, List type
    Gui Add, Radio, x31 y58 w177 h20, &List view
    Gui Add, Radio, x31 y78 w177 h20 Checked, &Details
    Gui Add, GroupBox, x21 y114 w195 h63, List style
    Gui Add, CheckBox, x31 y131 w177 h20, Show g&rid lines
    Gui Add, CheckBox, x31 y151 w177 h20 Checked, Full ro&w select
    Gui Add, GroupBox, x229 y40 w233 h137, Selection
    Gui Add, Radio, x240 y60 w218 h20 Group, &Single click to open an item
    Gui Add, Radio, x240 y149 w218 h20 Checked, Dou&ble click to open an item
    Gui Add, Radio, x252 y83 w206 h20 Checked Disabled Group, Do &not underline names
    Gui Add, Radio, x252 y102 w206 h20 Disabled, Underline &current name
    Gui Add, Radio, x252 y122 w206 h20 Disabled, Und&erline all names
    Gui Add, GroupBox, x21 y190 w441 h125, Files
    Gui Add, CheckBox, x31 y206 w426 h20 Checked, S&how archives first
    Gui Add, CheckBox, x31 y226 w426 h20 Checked, Allow all &uppercase names
    Gui Add, CheckBox, x31 y245 w426 h20 Checked, Show encr&ypted or compressed NTFS files in color
    Gui Add, CheckBox, x31 y265 w335 h20 Checked, Merge &volumes contents
    Gui Add, CheckBox, x31 y284 w335 h20, Sh&ow seconds
    Gui Add, Button, x366 y287 w90 h23, Set &font...

Gui Tab, 5
    Gui Add, GroupBox, x21 y40 w210 h104, Viewer type
    Gui Add, Radio, x31 y60 w195 h20, &Internal viewer
    Gui Add, Radio, x31 y79 w195 h20, &External viewer
    Gui Add, Radio, x31 y99 w195 h20 Checked, Asso&ciated program
    Gui Add, Radio, x31 y118 w195 h20, As&k
    Gui Add, GroupBox, x244 y40 w218 h104, Internal viewer
    Gui Add, CheckBox, x255 y60 w203 h20, Use &DOS encoding
    Gui Add, CheckBox, x255 y79 w203 h20, &Reuse existing window
    Gui Add, CheckBox, x255 y99 w203 h20 Checked, &Word wrap
    Gui Add, Text, x21 y154 w441 h13, &Unpack everything for
    Gui Add, Edit, x21 y169 w441 h20, *.exe *.msi *.htm *.html *.part*.rar
    Gui Add, Text, x21 y200 w441 h13, Ignore &modifications for
    Gui Add, Edit, x21 y214 w441 h20
    Gui Add, Text, x21 y245 w353 h13, External &viewer name
    Gui Add, Edit, x21 y260 w353 h20
    Gui Add, Button, x379 y258 w83 h23, &Browse...

Gui Tab, 6
    Gui Add, GroupBox, x21 y40 w441 h72, Prohibited file types
    Gui Add, CheckBox, x31 y60 w420 h20, File &types to exclude from extracting
    Gui Add, Edit, x31 y83 w420 h20 Disabled, *.exe *.com *.pif *.scr *.bat *.cmd *.lnk
    Gui Add, GroupBox, x21 y122 w441 h83, Wipe temporary files
    Gui Add, Radio, x31 y140 w420 h20 Checked, &Never
    Gui Add, Radio, x31 y159 w420 h20, &Always
    Gui Add, Radio, x31 y179 w420 h20, &Encrypted only
    Gui Add, GroupBox, x21 y214 w441 h44, Miscellaneous
    Gui Add, CheckBox, x31 y232 w420 h20 Checked, Propose to select &virus scanner

Gui Tab, 7
    Gui Add, GroupBox, x21 y40 w158 h219, Associate WinRAR with
    Gui Add, CheckBox, x34 y63 w56 h20, &RAR
    Gui Add, CheckBox, x34 y83 w56 h20, &ZIP
    Gui Add, CheckBox, x34 y102 w56 h20, 7-Zip
    Gui Add, CheckBox, x34 y122 w56 h20, ACE
    Gui Add, CheckBox, x34 y141 w56 h20, ARJ
    Gui Add, CheckBox, x34 y161 w56 h20, BZ2
    Gui Add, CheckBox, x34 y180 w56 h20, CAB
    Gui Add, CheckBox, x34 y200 w56 h20, GZip
    Gui Add, CheckBox, x105 y63 w56 h20, ISO
    Gui Add, CheckBox, x105 y83 w56 h20, JAR
    Gui Add, CheckBox, x105 y102 w56 h20, LZH
    Gui Add, CheckBox, x105 y122 w56 h20, TAR
    Gui Add, CheckBox, x105 y141 w56 h20, UUE
    Gui Add, CheckBox, x105 y161 w56 h20, XZ
    Gui Add, CheckBox, x105 y180 w56 h20, Z
    Gui Add, Button, x34 y227 w129 h23, Toggle &all
    Gui Add, GroupBox, x192 y40 w270 h93, Interface
    Gui Add, CheckBox, x202 y63 w251 h20, Add WinRAR to &Desktop
    Gui Add, CheckBox, x202 y83 w251 h20, Add WinRAR to &Start Menu
    Gui Add, CheckBox, x202 y102 w251 h20 Checked, Create WinRAR &program group
    Gui Add, GroupBox, x192 y144 w270 h115, Shell integration
    Gui Add, CheckBox, x202 y166 w251 h20, &Integrate WinRAR into shell
    Gui Add, CheckBox, x202 y185 w251 h20 Disabled, Cascaded con&text menus
    Gui Add, CheckBox, x202 y205 w251 h20 Checked Disabled, Ico&ns in context menus
    Gui Add, Button, x202 y227 w210 h23 Default, &Context menu items...
    Gui Add, GroupBox, x21 y271 w441 h52, &User defined archive extensions
    Gui Add, ComboBox, x34 y294 w417

Gui Tab
    Gui Add, Button, x241 y348 w75 h23 Default, OK
    Gui Add, Button, x322 y348 w75 h23, Cancel
    Gui Add, Button, x403 y348 w75 h23, Help

Gui Show, w484 h378, WinRAR Settings - Sample GUI
Return

GuiEscape:
GuiClose:
    ExitApp
