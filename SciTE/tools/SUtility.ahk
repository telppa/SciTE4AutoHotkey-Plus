;
; Scriptlet Utility
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
DetectHiddenWindows, On
FileEncoding, UTF-8
Menu, Tray, Icon, %A_ScriptDir%\..\toolicon.icl, 11
progName = Scriptlet Utility

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, %progName%, SciTE COM object not found!
	ExitApp
}

textFont := scite.ResolveProp("default.text.font")
LocalSciTEPath := scite.UserDir
scitehwnd := scite.SciTEHandle

sdir = %LocalSciTEPath%\Scriptlets
IfNotExist, %sdir%
{
	MsgBox, 16, %progName%, Scriptlet folder doesn't exist!
	ExitApp
}

; Check command line
if 1 = /insert
{
	if 2 =
	{
		MsgBox, 64, %progName%, Usage: %A_ScriptName% /insert scriptletName
		ExitApp
	}
	IfNotExist, %sdir%\%2%.scriptlet
	{
		MsgBox, 52, %progName%,
		(LTrim
		Invalid scriptlet name: "%2%".
		Perhaps you have clicked on a toolbar icon whose scriptlet attached no longer exists?
		Press OK to edit the toolbar properties file.
		)
		IfMsgBox, Yes
			scite.OpenFile(LocalSciTEPath "\UserToolbar.properties")
		ExitApp
	}
	FileRead, text2insert, %sdir%\%2%.scriptlet
	gosub InsertDirect
	ExitApp
}

if 1 = /addScriptlet
{
	defaultScriptlet := scite.Selection
	if defaultScriptlet =
	{
		MsgBox, 16, %progName%, Nothing is selected!
		ExitApp
	}
	gosub AddBut ; that does it all
	if !_RC
		ExitApp ; Maybe the user has cancelled the action.
	MsgBox, 68, %progName%, Scriptlet added sucessfully. Do you want to open the scriptlet manager?
	IfMsgBox, Yes
		Reload ; no parameters are passed to script
	ExitApp
}

Gui, +MinSize Resize Owner%scitehwnd%
Gui, Add, Button, Section gAddBut, New
Gui, Add, Button, ys gRenBut, Rename
Gui, Add, Button, ys gSubBut, Delete
Gui, Add, ListBox, xs w160 h240 vMainListbox gSelectLB HScroll
Gui, Add, Button, ys Section gToolbarBut, Add to toolbar
Gui, Add, Button, ys gInsertBut, Insert into SciTE
Gui, Add, Button, ys gSaveBut, Save
Gui, Add, Button, ys gOpenInSciTE, Open in SciTE
Gui, Font, S9, %textFont%
Gui, Add, Edit, xs w320 h240 vScriptPane -Wrap WantTab HScroll
Gui, Show,, %progName%

selectQ =
defaultScriptlet =
gosub ListboxUpdate
return

GuiSize:
Anchor("MainListbox", "h")
Anchor("ScriptPane", "wh")
return

GuiGetPos(ctrl, guiId := "")
{
	guiId := guiId ? (guiId ":") : ""
	GuiControlGet, ov, %guiId%Pos, %ctrl%
	return { x: ovx, y: ovy, w: ovw, h: ovh }
}

GuiClose:
ExitApp

SelectLB:
GuiControlGet, fname2open,, MainListbox
FileRead, scriptletText, %sdir%\%fname2open%.scriptlet
GuiControl,, ScriptPane, % scriptletText
Return

AddBut:
Gui +OwnDialogs
InputBox, fname2create, %progName%, Enter the name of the scriptlet to create:
if ErrorLevel
	return
if !fname2create
	return
fname2create := ValidateFilename(fname2create)
IfExist, %sdir%\%fname2create%.scriptlet
{
	gosub CompleteUpdate
	return
}
FileAppend, % defaultScriptlet, %sdir%\%fname2create%.scriptlet
gosub CompleteUpdate
_RC = 1
Return

CompleteUpdate:
selectQ = %fname2create%
gosub ListboxUpdate
selectQ =
if defaultScriptlet =
	gosub SelectLB
return

SubBut:
Gui +OwnDialogs
GuiControlGet, selected,, MainListbox
if selected =
	return
MsgBox, 52, %progName%, Are you sure you want to delete '%selected%'?
IfMsgBox, No
	return
FileDelete, %sdir%\%selected%.scriptlet
fname2create =
gosub CompleteUpdate
return

RenBut:
Gui +OwnDialogs
GuiControlGet, selected,, MainListbox
if selected =
	return
InputBox, fname2create, %progName%, Enter the new name of the scriptlet:,,,,,,,, %selected%
if ErrorLevel
	return
if !fname2create
	return
if (fname2create = selected)
	return
fname2create := ValidateFilename(fname2create)
IfExist, %sdir%\%fname2create%.scriptlet
{
	MsgBox, 48, %progName%, That name already exists!`nChoose another name please.
	return
}
FileMove, %sdir%\%selected%.scriptlet, %sdir%\%fname2create%.scriptlet
gosub CompleteUpdate
return

ToolbarBut:
GuiControlGet, selected,, MainListbox
if selected =
	return

FileAppend, `n=Scriptlet: %selected%|`%LOCALAHK`% tools\SUtility.ahk /insert "%selected%"||`%ICONRES`%`,12, %LocalSciTEPath%\UserToolbar.properties
scite.Message(0x1000+2)
return

InsertBut:
GuiControlGet, text2insert,, ScriptPane
InsertDirect:
if text2insert =
	return
WinActivate, ahk_id %scitehwnd%
scite.InsertText(text2insert)
return

SaveBut:
GuiControlGet, fname2save,, MainListbox
GuiControlGet, text2save,, ScriptPane
FileDelete, %sdir%\%fname2save%.scriptlet
FileAppend, % text2save, %sdir%\%fname2save%.scriptlet
return

OpenInSciTE:
GuiControlGet, fname2open,, MainListbox
if fname2open =
	return
scite.OpenFile(sdir "\" fname2open ".scriptlet")
return

ListboxUpdate:
te =
Loop, %sdir%\*.scriptlet
{
	SplitPath, A_LoopFileName,,,, sn
	if sn =
		continue
	te = %te%|%sn%
	if selectQ = %sn%
		te .= "|"
}
GuiControl,, MainListbox, % te
return

ValidateFilename(fn)
{
	StringReplace, fn, fn, \, _, All
	StringReplace, fn, fn, /, _, All
	StringReplace, fn, fn, :, _, All
	StringReplace, fn, fn, *, _, All
	StringReplace, fn, fn, ?, _, All
	StringReplace, fn, fn, ", _, All
	StringReplace, fn, fn, <, _, All
	StringReplace, fn, fn, >, _, All
	StringReplace, fn, fn, |, _, All
	return fn
}
