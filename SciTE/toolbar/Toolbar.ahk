;
; SciTE4AutoHotkey Toolbar
;
; TillaGoto.iIncludeMode = 0x10111111

#NoEnv
#NoTrayIcon
; 这里要用 Force ，否则会出现 Toolbar 启动失败，但又无法退出造成一片空白的情况。
#SingleInstance Force
#Include %A_ScriptDir%
#Include PlatformRead.ahk
#Include ComInterface.ahk
#Include SciTEDirector.ahk
#Include SciTEMacros.ahk
#Include ProfileUpdate.ahk
#Include Extensions.ahk
SetWorkingDir, %A_ScriptDir%\..
SetBatchLines, -1
DetectHiddenWindows, On

; CLSID and APPID for this script: don't reuse, please!
CLSID_SciTE4AHK := "{D7334085-22FB-416E-B398-B5038A5A0784}"
APPID_SciTE4AHK := "SciTE4AHK.Application"

ATM_OFFSET     := 0x1000
ATM_STARTDEBUG := ATM_OFFSET+0
ATM_STOPDEBUG  := ATM_OFFSET+1
ATM_RELOAD     := ATM_OFFSET+2
ATM_DIRECTOR   := ATM_OFFSET+3
ATM_DRUNTOGGLE := ATM_OFFSET+4

if !A_IsAdmin
	runasverb := "*RunAs "

RegRead, 检查字体, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts, Microsoft YaHei Mono (TrueType)
if (检查字体!="Microsoft YaHei Mono.ttf")
	Run, %runasverb%user\安装字体.ahk

Run, %runasverb%user\自动更新.ahk

if 0 < 2
{
	MsgBox, 16, SciTE4AutoHotkey Toolbar, This script cannot be run independently.
	ExitApp
}

SciTEDir := A_WorkingDir
CurAhkExe := SciTEDir "\..\AutoHotkey.exe" ; Fallback AutoHotkey binary

FileRead, CurrentSciTEVersion, $VER
if CurrentSciTEVersion =
{
	MsgBox, 16, SciTE4AutoHotkey Toolbar, Invalid SciTE4AutoHotkey version!
	ExitApp
}

; Check if the properties file exists
IfNotExist, toolbar.properties
{
	MsgBox, 16, SciTE4AutoHotkey Toolbar, The property file doesn't exist!
	ExitApp
}

; Get the HWND of the SciTE window
scitehwnd = %1%
IfWinNotExist, ahk_id %scitehwnd%
{
	MsgBox, 16, SciTE4AutoHotkey Toolbar, SciTE not found!
	ExitApp
}

; Get the HWND of the SciTE director window
directorhwnd = %2%
IfWinNotExist, ahk_id %directorhwnd%
{
	MsgBox, 16, SciTE4AutoHotkey Toolbar, SciTE director window not found!
	ExitApp
}

; Get the HMENU of the "Files" menu
scitemenu := DllCall("GetMenu", "ptr", scitehwnd, "ptr")
filesmenu := DllCall("GetSubMenu", "ptr", scitemenu, "int", 7, "ptr")

; Get the HWND of its Scintilla control
ControlGet, scintillahwnd, Hwnd,, Scintilla1, ahk_id %scitehwnd%

IsPortable := FileExist("$PORTABLE")
if !IsPortable
	LocalSciTEPath = %A_MyDocuments%\AutoHotkey\SciTE
else
	LocalSciTEPath = %SciTEDir%\user
LocalPropsPath = %LocalSciTEPath%\UserToolbar.properties
global ExtensionDir := LocalSciTEPath "\Extensions"

FileEncoding, UTF-8

; Read toolbar settings from properties file
FileRead, GlobalSettings, toolbar.properties
FileRead, LocalSettings, %LocalPropsPath%
FileRead, SciTEVersion, %LocalSciTEPath%\$VER
if SciTEVersion && (SciTEVersion != CurrentSciTEVersion)
	gosub UpdateProfile
if !IsPortable && (!FileExist(LocalPropsPath) || !SciTEVersion)
{
	; Create the SciTE user folder
	RunWait, "%A_AhkPath%" "%SciTEDir%\tools\NewUser.ahk"
	FileDelete, %LocalSciTEPath%\$VER
	FileAppend, %CurrentSciTEVersion%, %LocalSciTEPath%\$VER

	; Reload properties & reload user toolbar settings
	SendMessage, 1024+1, 0, 0,, ahk_id %scitehwnd%
	FileRead, LocalSettings, %LocalPropsPath%
	FirstTime := true
	SciTEVersion := CurrentSciTEVersion
}

SciTEVersionInt := Util_VersionTextToNumber(SciTEVersion)

IfNotExist, %LocalSciTEPath%\Settings\
	FileCreateDir, %LocalSciTEPath%\Settings\
IfNotExist, %LocalSciTEPath%\Extensions\
	FileCreateDir, %LocalSciTEPath%\Extensions\

IfExist, %LocalSciTEPath%\$NODEFTOOLBAR
	GlobalSettings := ""

ToolbarProps := GlobalSettings "`n" Util_ReadExtToolbarDef() LocalSettings

; Load the tools
ntools = 13
_ToolButs =
(LTrim Join`n
-
Set current platform,1,,autosize
-
Run script (F5),2,,autosize
Debug script (F7),3,,autosize
Pause script (F5),10,hidden,autosize
Stop script,4,hidden,autosize
Run current line of code (F10),5,hidden,autosize
Run until next line of code (F11),6,hidden,autosize
Run until function/label exit (Shift+F11),7,hidden,autosize
Callstack,8,hidden,autosize
Variable list,9,hidden,autosize
---

)
_ToolIL := IL_Create()
_IconLib = toolicon.icl

Tools := []

; Set up the stock buttons
IL_Add(_ToolIL, _IconLib, 18)
IL_Add(_ToolIL, _IconLib, 2)
IL_Add(_ToolIL, _IconLib, 1)
IL_Add(_ToolIL, _IconLib, 3)
IL_Add(_ToolIL, _IconLib, 4)
IL_Add(_ToolIL, _IconLib, 5)
IL_Add(_ToolIL, _IconLib, 6)
IL_Add(_ToolIL, _IconLib, 7)
IL_Add(_ToolIL, _IconLib, 8)
IL_Add(_ToolIL, _IconLib, 19)
Tools[2]  := { Path: "?switch" }
Tools[4]  := { Path: "?run" }
Tools[5]  := { Path: "?debug" }
Tools[6]  := { Path: "?pause" }
Tools[7]  := { Path: "?stop" }
Tools[8]  := { Path: "?stepinto" }
Tools[9]  := { Path: "?stepover" }
Tools[10]  := { Path: "?stepout" }
Tools[11] := { Path: "?stacktrace" }
Tools[12] := { Path: "?varlist" }
i := 11

Loop, Parse, ToolbarProps, `n, `r
{
	curline := Trim(A_LoopField)
	if (curline = "")
		|| SubStr(curline, 1, 1) = ";"
		continue
	else if SubStr(curline, 1, 2) = "--"
	{
		_ToolButs .= "---`n"
		ntools++
		continue
	}else if SubStr(curline, 1, 1) = "-"
	{
		_ToolButs .= "-`n"
		ntools++
		continue
	}else if !RegExMatch(curline, "^=(.*?)\x7C(.*?)(?:\x7C(.*?)(?:\x7C(.*?))?)?$", varz)
		|| varz1 = ""
		continue
	ntools ++
	IfInString, varz1, `,
	{
		MsgBox, 16, SciTE4AutoHotkey Toolbar, A tool name can't contain a comma! Specified:`n%varz1%
		ExitApp
	}
	varz4 := ParseCmdLine((noIconSp := varz4 = "") ? varz2 : varz4)
	if RegExMatch(varz4, "^""\s*(.+?)\s*""", ovt)
		varz4 := ovt1
	StringReplace, varz4, varz4, `",, All
	if noIconSp && varz4 = A_AhkPath
		varz4 .= ",2"
	curtool := Tools[ntools] := { Name: Trim(varz1), Path: Trim(varz2), Hotkey: Trim(varz3) }
	IfInString, varz4, `,
	{
		curtool.Picture := Trim(SubStr(varz4, 1, InStr(varz4, ",")-1))
		curtool.IconNumber := Trim(SubStr(varz4, InStr(varz4, ",")+1))
	}else
	{
		curtool.Picture := Trim(varz4)
		curtool.IconNumber := 1
	}
	
	_ToolButs .= curtool.Name "," (i ++) ",,autosize`n"
	IL_Add(_ToolIL, curtool.Picture, curtool.IconNumber)
}

;  Get HWND of real SciTE toolbar. ~L
ControlGet, scitool, Hwnd,, ToolbarWindow321, ahk_id %scitehwnd%
ControlGetPos,,, guiw, guih,, ahk_id %scitool% ; Get size of real SciTE toolbar. ~L
; Get width of real SciTE toolbar to determine placement for our toolbar. ~L
SendMessage, 1024, 0, 0,, ahk_id %scitehwnd% ; send our custom message to SciTE
x := ErrorLevel

; Create and show the AutoHotkey toolbar
Gui, New, hwndhwndgui +Parent%scitool% -Caption, AHKToolbar4SciTE
Gui, +0x40000000 -0x80000000 ; Must be done *after* the GUI is created. Fixes focus issues. ~L
Gui, Show, x%x% y-2 w%guiw% h%guih% NoActivate
WinActivate, ahk_id %scitehwnd%

OnMessage(ATM_STARTDEBUG, "Msg_StartDebug")
OnMessage(ATM_STOPDEBUG, "Msg_StopDebug")
OnMessage(ATM_RELOAD, "Msg_Reload")
OnMessage(ATM_DRUNTOGGLE, "Msg_DebugRunToggle")
hToolbar := Toolbar_Add(hwndgui, "OnToolbar", "FLAT TOOLTIPS", _ToolIL)
Toolbar_Insert(hToolbar, _ToolButs)
Toolbar_SetMaxTextRows(hToolbar, 0)
if A_ScreenDPI >= 120
	Toolbar_SetButtonSize(hToolbar, 24, 24)

; Build the menus

Menu, ExtMonMenu, Add, 安装扩展, ExtMonInstallExt
Menu, ExtMonMenu, Add, 移除扩展, ExtMonRemoveExt
Menu, ExtMonMenu, Add, 创建扩展, ExtMonCreateExt
Menu, ExtMonMenu, Add, 导出扩展, ExtMonExportExt

Menu, ExtMenu, Add, 扩展管理器, extmon
Menu, ExtMenu, Add, 重启全部扩展, reloadexts

Menu, ToolMenu, Add, 扩展, :ExtMenu
Menu, ToolMenu, Add
Menu, ToolMenu, Add, 编辑 User toolbar properties, editprops
Menu, ToolMenu, Add, 编辑 User autorun script, editautorun
Menu, ToolMenu, Add, 编辑 User Lua script, editlua
Menu, ToolMenu, Add
Menu, ToolMenu, Add, 编辑 Global toolbar properties, editglobalprops
Menu, ToolMenu, Add, 编辑 Global autorun script, editglobalautorun
Menu, ToolMenu, Add
Menu, ToolMenu, Add, 编辑 platform properties, editplatforms
Menu, ToolMenu, Add, 重启 platforms, reloadplatforms
Menu, ToolMenu, Add
Menu, ToolMenu, Add, 重启工具栏, reloadtoolbar
Menu, ToolMenu, Add, 重启工具栏 (with autorun), reloadtoolbarautorun
Menu, ToolMenu, Add
Menu, ToolMenu, Add, 检查更新…, check4updates
/*
Menu, ExtMonMenu, Add, Install extension, ExtMonInstallExt
Menu, ExtMonMenu, Add, Remove extension, ExtMonRemoveExt
Menu, ExtMonMenu, Add, Create extension, ExtMonCreateExt
Menu, ExtMonMenu, Add, Export extension, ExtMonExportExt

Menu, ExtMenu, Add, Extension manager, extmon
Menu, ExtMenu, Add, Reload extensions, reloadexts

Menu, ToolMenu, Add, Extensions, :ExtMenu
Menu, ToolMenu, Add
Menu, ToolMenu, Add, Edit User toolbar properties, editprops
Menu, ToolMenu, Add, Edit User autorun script, editautorun
Menu, ToolMenu, Add, Edit User Lua script, editlua
Menu, ToolMenu, Add
Menu, ToolMenu, Add, Edit Global toolbar properties, editglobalprops
Menu, ToolMenu, Add, Edit Global autorun script, editglobalautorun
Menu, ToolMenu, Add
Menu, ToolMenu, Add, Edit platform properties, editplatforms
Menu, ToolMenu, Add, Reload platforms, reloadplatforms
Menu, ToolMenu, Add
Menu, ToolMenu, Add, Reload toolbar, reloadtoolbar
Menu, ToolMenu, Add, Reload toolbar (with autorun), reloadtoolbarautorun
Menu, ToolMenu, Add
Menu, ToolMenu, Add, Check for updates..., check4updates
*/
; Create group for our windows
GroupAdd, SciTE4AutoHotkey, ahk_id %scitehwnd%
GroupAdd, SciTE4AutoHotkey, ahk_id %hwndgui%

; Set initial variables
dbg_active := false

; Build hotkeys
Hotkey, IfWinActive, ahk_id %scitehwnd%
Loop, %ntools%
	if Tools[A_Index].Hotkey != ""
		Hotkey, % Tools[A_Index].Hotkey, ToolHotkeyHandler

; Create the COM interface
InitComInterface()

; Register the SciTE director
Director_Init()

; Retrieve the default AutoHotkey directory
AhkDir := DirectorReady ? CoI_ResolveProp("", "AutoHotkeyDir") : (SciTEDir "\..")
if DirectorReady && !IsPortable
{
	; Auto-detect the AutoHotkey directory from registry
	temp := Util_GetAhkPath()
	if temp
	{
		CoI_SendDirectorMsg("", "property:AutoHotkeyDir=" CEscape(temp))
		AhkDir := temp
	}
}

; Initialize the macro recorder
Macro_Init()

; Initialize the platforms
platforms := Util_ParsePlatforms("platforms.properties", platlist)
IfExist, %LocalSciTEPath%\_platform.properties
{
	FileReadLine, ov, %LocalSciTEPath%\_platform.properties, 2
	curplatform := SubStr(ov, 14)
}else
	curplatform = Default

Util_PopulatePlatformsMenu()

FileRead, temp, %LocalSciTEPath%\_platform.properties
if platforms[curplatform] != temp
	gosub changeplatform

if DirectorReady
	CurAhkExe := CoI_ResolveProp("", "AutoHotkey")

; Run the autorun script
if 3 != /NoAutorun
	Run, "%A_AhkPath%" "%SciTEDir%\tools\Autorun.ahk"

; Safety SciTE window existance timer
SetTimer, check4scite, 1000

if FirstTime
{
	CoI_OpenFile("", SciTEDir "\TestSuite.ahk")
	MsgBox, 64, SciTE4AutoHotkey, Welcome to SciTE4AutoHotkey!
	Run, "%A_AhkPath%" "%SciTEDir%\tools\PropEdit.ahk"
}

if regenerateUserProps
	Run, "%A_AhkPath%" "%SciTEDir%\tools\PropEdit.ahk" /regenerate
return

; Toolbar event handler
OnToolbar(hToolbar, pEvent, pTxt, pPos, pId)
{
	global
	Critical

	if pEvent = click
		RunTool(pPos)
}

GuiClose:
ExitApp

GuiContextMenu:
; Right click
Menu, ToolMenu, Show
return

check4updates:
Run, "%A_AhkPath%" "%SciTEDir%\tools\SciTEUpdate.ahk"
return

exitroutine:
IfWinExist, ahk_id %scitehwnd%
{
	WinClose
	Sleep 100
	IfWinExist, SciTE ahk_class #32770
		WinWaitClose
	WinWaitClose, ahk_id %scitehwnd%,, 2
	if ErrorLevel = 1
		return
}
ExitApp

reloadexts:
Util_CheckReload()
reloadextsForce:
Util_RebuildExtensions()
Util_ReloadSciTE()
return

editprops:
Run, SciTE.exe "%LocalPropsPath%"
return

;修正了路径
editautorun:
Run, SciTE.exe "%LocalSciTEPath%\Autorun.ahk"
return

editlua:
Run, SciTE.exe "%LocalSciTEPath%\UserLuaScript.lua"
return

editglobalprops:
Run, %runasverb%SciTE.exe "%SciTEDir%\toolbar.properties"
return

editglobalautorun:
Run, %runasverb%SciTE.exe "%SciTEDir%\tools\Autorun.ahk"
return

editplatforms:
Run, %runasverb%SciTE.exe "%SciTEDir%\platforms.properties"
return

reloadplatforms:
Menu, PlatformMenu, DeleteAll
platforms := Util_ParsePlatforms("platforms.properties", platlist)
Util_PopulatePlatformsMenu()
goto changeplatform

reloadtoolbar:
Director_Send("closing:")
Msg_Reload()
return

reloadtoolbarautorun:
Director_Send("closing:")
_ReloadWithAutoRun()
return

check4scite:
; Close the application if the user has closed SciTE
IfWinNotExist, ahk_id %scitehwnd%
{
	SetTimer, check4scite, Off
	gosub, exitroutine
}
return

SciTE_OnClosing()
{
	Critical
	SetTimer, check4scite, 10
}

; Hotkey handler
ToolHotkeyHandler:
curhotkey := A_ThisHotkey
Loop, %ntools%
	toolnumber := A_Index
until Tools[toolnumber].Hotkey = curhotkey
RunTool(toolnumber)
return

platswitch:
curplatform := A_ThisMenuItem
platswitch2:
for i,plat in platlist
	Menu, PlatformMenu, Uncheck, %plat%
Menu, PlatformMenu, Check, %curplatform%
changeplatform:
FileDelete, %LocalSciTEPath%\_platform.properties
FileAppend, % platforms[curplatform], %LocalSciTEPath%\_platform.properties
SendMessage, 1024+1, 0, 0,, ahk_id %scitehwnd%
if DirectorReady
	CurAhkExe := CoI_ResolveProp("", "AutoHotkey")
return

; Function to run a tool
RunTool(toolnumber)
{
	global Tools, dbg_active
	if SubStr(t := Tools[toolnumber].Path, 1, 1) = "?"
		p := "Cmd_" SubStr(t, 2), (IsFunc(p)) ? p.() : ""
	else if !dbg_active
	{
		Run, % ParseCmdLine(cmd := Tools[toolnumber].Path),, UseErrorLevel
		if ErrorLevel = ERROR
			MsgBox, 16, SciTE4AutoHotkey Toolbar, Couldn't launch specified command line! Specified:`n%cmd%
	}
}

Cmd_Switch()
{
	Menu, PlatformMenu, Show
}

Cmd_Run()
{
	global
	if !dbg_active
		PostMessage, 0x111, 303, 0,, ahk_id %scitehwnd%
	else
		PostMessage, 0x111, 1127, 0,, ahk_id %scitehwnd%
}

Cmd_Pause()
{
	global
	PostMessage, 0x111, 1136, 0,, ahk_id %scitehwnd%
}

Cmd_Stop()
{
	global
	PostMessage, 0x111, 1128, 0,, ahk_id %scitehwnd%
}

Cmd_Debug()
{
	global
	PostMessage, 0x111, 302, 0,, ahk_id %scitehwnd%
}

Cmd_StepInto()
{
	global
	PostMessage, 0x111, 1129, 0,, ahk_id %scitehwnd%
}

Cmd_StepOver()
{
	global
	PostMessage, 0x111, 1130, 0,, ahk_id %scitehwnd%
}

Cmd_StepOut()
{
	global
	PostMessage, 0x111, 1131, 0,, ahk_id %scitehwnd%
}

Cmd_Stacktrace()
{
	global
	PostMessage, 0x111, 1132, 0,, ahk_id %scitehwnd%
}

Cmd_Varlist()
{
	global
	PostMessage, 0x111, 1133, 0,, ahk_id %scitehwnd%
}

Msg_StartDebug(a,b,msg)
{
	global
	Toolbar_SetButton(hToolbar, 4, "-hidden")
	Toolbar_SetButton(hToolbar, 5, "hidden")
	Toolbar_SetButton(hToolbar, 6, "hidden")
	Toolbar_SetButton(hToolbar, 7, "-hidden")
	Toolbar_SetButton(hToolbar, 8, "-hidden")
	Toolbar_SetButton(hToolbar, 9, "-hidden")
	Toolbar_SetButton(hToolbar, 10, "-hidden")
	Toolbar_SetButton(hToolbar, 11, "-hidden")
	Toolbar_SetButton(hToolbar, 12, "-hidden")
	dbg_active := true
	dbg_runshown := true
}

Msg_StopDebug()
{
	global
	Toolbar_SetButton(hToolbar, 4, "-hidden")
	Toolbar_SetButton(hToolbar, 5, "-hidden")
	Toolbar_SetButton(hToolbar, 6, "hidden")
	Toolbar_SetButton(hToolbar, 7, "hidden")
	Toolbar_SetButton(hToolbar, 8, "hidden")
	Toolbar_SetButton(hToolbar, 9, "hidden")
	Toolbar_SetButton(hToolbar, 10, "hidden")
	Toolbar_SetButton(hToolbar, 11, "hidden")
	Toolbar_SetButton(hToolbar, 12, "hidden")
	dbg_active := false
}

Msg_DebugRunToggle()
{
	global
	if !dbg_active
		return
	dbg_runshown := !dbg_runshown
	if dbg_runshown
	{
		Toolbar_SetButton(hToolbar, 4, "-hidden")
		Toolbar_SetButton(hToolbar, 6, "hidden")
	}else
	{
		Toolbar_SetButton(hToolbar, 4, "hidden")
		Toolbar_SetButton(hToolbar, 6, "-hidden")
	}
}

Msg_Reload()
{
	global
	Run, "%A_AhkPath%" /restart "%A_ScriptFullPath%" %scitehwnd% %directorhwnd% /NoAutorun
}

_ReloadWithAutoRun()
{
	global
	Run, "%A_AhkPath%" /restart "%A_ScriptFullPath%" %scitehwnd% %directorhwnd%
}

GetSciTEOpenedFile()
{
	global scitehwnd, DirectorReady
	
	if DirectorReady
		return Director_Send("askfilename:", true).value
	else
	{
		WinGetTitle, sctitle, ahk_id %scitehwnd%
		if RegExMatch(sctitle, "^(.+?) [-*] SciTE", o)
			return o1
		return "?ERROR"
	}
}

GetFilename(txt)
{
	SplitPath, txt, o
	return o
}

GetPath(txt)
{
	SplitPath, txt,, o
	return o
}

ParseCmdLine(cmdline)
{
	global _IconLib, curplatform, LocalSciTEPath, SciTEDir, CurAhkExe
	a := GetSciTEOpenedFile()
	
	StringReplace, cmdline, cmdline, `%FILENAME`%, % GetFilename(a), All
	StringReplace, cmdline, cmdline, `%FILEPATH`%, % GetPath(a), All
	StringReplace, cmdline, cmdline, `%FULLFILENAME`%, % a, All
	StringReplace, cmdline, cmdline, `%LOCALAHK`%, "%A_AhkPath%", All
	StringReplace, cmdline, cmdline, `%AUTOHOTKEY`%, "%CurAhkExe%", All
	StringReplace, cmdline, cmdline, `%ICONRES`%, %_IconLib%, All
	StringReplace, cmdline, cmdline, `%SCITEDIR`%, % SciTEDir, All
	StringReplace, cmdline, cmdline, `%USERDIR`%, % LocalSciTEPath, All
	StringReplace, cmdline, cmdline, `%PLATFORM`%, %curplatform%, All

	return cmdline
}

Util_PopulatePlatformsMenu()
{
	global platlist, curplatform
	
	for i,plat in platlist
	{
		Menu, PlatformMenu, Add, %plat%, platswitch
		if (plat = curplatform)
			Menu, PlatformMenu, Check, %plat%
	}
}

Util_GetAhkPath()
{
	RegRead, ov, HKLM, SOFTWARE\AutoHotkey, InstallDir
	if !ov && A_Is64bitOS
	{
		q := A_RegView
		SetRegView, 64
		RegRead, ov, HKLM, SOFTWARE\AutoHotkey, InstallDir
		SetRegView, %q%
	}
	return ov
}

Util_Is64bitProcess(pid)
{
	if !A_Is64bitOS
		return 0
	
	proc := DllCall("OpenProcess", "uint", 0x0400, "uint", 0, "uint", pid, "ptr")
	DllCall("IsWow64Process", "ptr", proc, "uint*", retval)
	DllCall("CloseHandle", "ptr", proc)
	return retval ? 0 : 1
}
