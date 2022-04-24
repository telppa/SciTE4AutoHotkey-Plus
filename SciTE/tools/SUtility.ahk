;
; Scriptlet Utility
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
DetectHiddenWindows, On
FileEncoding, UTF-8
Menu, Tray, Icon, %A_ScriptDir%\..\toolicon.icl, 11
progName := "脚本片段"

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, %progName%, 没有找到 SciTE COM 对象!
	ExitApp
}

textFont := scite.ResolveProp("default.text.font")
LocalSciTEPath := scite.UserDir
scitehwnd := scite.SciTEHandle

sdir = %LocalSciTEPath%\Scriptlets
IfNotExist, %sdir%
{
	MsgBox, 16, %progName%, Scriptlet 文件夹(目录)不存在!
	ExitApp
}

; Check command line
if 1 = /insert
{
	if 2 =
	{
		MsgBox, 64, %progName%, 示例: %A_ScriptName% /insert 脚本片段名
		ExitApp
	}
	IfNotExist, %sdir%\%2%.scriptlet
	{
		MsgBox, 52, %progName%,
		(LTrim
		无效的脚本片段: "%2%".
		工具栏图标对应的脚本片段不存在.
		点击“确定”编辑工具栏文件.
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
		MsgBox, 16, %progName%, 没有选择内容!
		ExitApp
	}
	gosub AddBut ; that does it all
	if !_RC
		ExitApp ; Maybe the user has cancelled the action.
	MsgBox, 68, %progName%, 脚本片段已成功添加。 是否打开脚本片段管理器?
	IfMsgBox, Yes
		Reload ; no parameters are passed to script
	ExitApp
}

Gui, +MinSize Resize Owner%scitehwnd%
Gui, Add, Button, Section gAddBut, 新建
Gui, Add, Button, ys gRenBut, 重命名
Gui, Add, Button, ys gSubBut, 删除
Gui, Add, ListBox, xs w160 h240 vMainListbox gSelectLB HScroll
Gui, Add, Button, ys Section gToolbarBut, 添加到工具栏
Gui, Add, Button, ys gInsertBut, 插入到 SciTE
Gui, Add, Button, ys gSaveBut, 保存
Gui, Add, Button, ys gOpenInSciTE, 在 SciTE 中打开
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
InputBox, fname2create, %progName%, 输入要创建的脚本片段的名称:
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
MsgBox, 52, %progName%,确定要删除 '%selected%'?
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
InputBox, fname2create, %progName%, 输入脚本片段的新名称:,,,,,,,, %selected%
if ErrorLevel
	return
if !fname2create
	return
if (fname2create = selected)
	return
fname2create := ValidateFilename(fname2create)
IfExist, %sdir%\%fname2create%.scriptlet
{
	MsgBox, 48, %progName%, 该名称已存在！`n请选择其他名称.
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
