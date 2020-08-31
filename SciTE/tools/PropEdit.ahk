;
; SciTE4AutoHotkey Settings Editor
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SendMode Input
SetWorkingDir, %A_ScriptDir%

Menu, Tray, Icon, ..\toolicon.icl, 17

scite := GetSciTEInstance()
if !scite
{
	MsgBox, 16, SciTE properties editor, Can't find SciTE!
	ExitApp
}

scite_hwnd := scite.GetSciTEHandle()

LocalSciTEPath := scite.UserDir

UserPropsFile = %LocalSciTEPath%\_config.properties

IfNotExist, %UserPropsFile%
{
	MsgBox, 16, SciTE properties editor, Can't find user properties file!
	ExitApp
}

FileEncoding, UTF-8
FileRead, UserProps, %UserPropsFile%

cplist_v := "0|65001|932|936|949|950|1361"
cplist_n := "System default|UTF-8|Shift-JIS|Chinese GBK|Korean Wansung|Chinese Big5|Korean Johab"

p_style  := FindProp("import Styles\\(.*)\.style", "Classic")
p_locale := FindProp("locale\.properties=locales\\(.*)\.locale\.properties", "English")
p_encoding := FindProp("code\.page=(" cplist_v ")", 0)
p_backup := FindProp("make\.backup=([01])", 1)
p_savepos := FindProp("save\.position=([01])", 1)
p_zoom := FindProp("magnification=(-?\d+)", -1)

if 1 = /regenerate
{
	regenMode := true
	gosub Update2
	ExitApp
}

org_locale := p_locale
org_zoom := p_zoom

stylelist := CountStylesAndChoose(ch1)
localelist := CountLocalesAndChoose(ch2)
p_encoding := FindInList(cplist_v, p_encoding)

Gui, +ToolWindow +AlwaysOnTop

Gui, Add, Text, Section +Right w70, Language:
Gui, Add, DDL, ys R10 Choose%ch2% vp_locale, %localelist%

Gui, Add, Text, xs Section +Right w70, Style:
Gui, Add, DDL, ys Choose%ch1% vp_style gDDL_Choose, %stylelist%|New...

Gui, Add, Text, xs Section +Right w70, File codepage:
Gui, Add, DDL, ys +AltSubmit Choose%p_encoding% vp_encoding, %cplist_n%

Gui, Add, Text, xs Section +Right w70, Default zoom:
Gui, Add, Edit, ys w50
Gui, Add, UpDown, vp_zoom Range-10-10, %p_zoom%

Gui, Add, Text, xs Section +Right w70, Auto-backups:
Gui, Add, CheckBox, ys Checked%p_backup% vp_backup

Gui, Add, Text, xs Section +Right, Remember window position:
Gui, Add, CheckBox, ys Checked%p_savepos% vp_savepos

Gui, Add, Button, xs+40 Section gUpdate, Update
Gui, Add, Button, ys xs+70 gEditStyle, Edit style
Gui, Show,, SciTE settings
return

DDL_Choose:
Gui, +OwnDialogs
GuiControlGet, n_style,, p_style
if (n_style != "New...")
{
	p_style := n_style
	return
}
GuiControl, ChooseString, p_style, %p_style%
FileRead, qvar, %LocalSciTEPath%\Styles\%p_style%.style.properties
if !RegExMatch(qvar, "`am)^s4ahk\.style=1$")
	p_style := "Blank" ; cannot fork an old-format style
InputBox, newStyleName, SciTE properties editor, Enter the name of the new style...,,,,,,,, %p_style%_Edited
if ErrorLevel
	return
if not newStyleName := ValidateFilename(Trim(newStyleName))
	return
IfExist, %LocalSciTEPath%\Styles\%newStyleName%.style.properties
{
	MsgBox, 48, SciTE properties editor, The style already exists.
	return
}
FileCopy, %LocalSciTEPath%\Styles\%p_style%.style.properties, %LocalSciTEPath%\Styles\%newStyleName%.style.properties
if ErrorLevel
{
	MsgBox, 16, SciTE properties editor, Error copying style.
	return
}
stylelist .= "|" newStyleName
GuiControl,, p_style, |%stylelist%|New...
GuiControl, ChooseString, p_style, %newStyleName%
p_style := newStyleName
goto EditStyle_

EditStyle:
Gui, +OwnDialogs
GuiControlGet, n_style,, p_style
EditStyle_:
Run, "%A_AhkPath%" "%A_ScriptDir%\StyleEdit.ahk" "%LocalSciTEPath%\Styles\%p_style%.style.properties"
return

GuiClose:
ExitApp

Update:
Gui, Submit, NoHide
Update2:

p_encoding := GetItem(cplist_v, p_encoding)

FileRead, qvar, %LocalSciTEPath%\Styles\%p_style%.style.properties
p_extra := ""
if RegExMatch(qvar, "`am)^s4ahk\.style=1$")
	p_extra =
	(LTrim
	style.ahk1.0=$(s4ahk.style.default)
	style.ahk1.1=$(s4ahk.style.comment.line)
	style.ahk1.2=$(s4ahk.style.comment.block)
	style.ahk1.3=$(s4ahk.style.escape)
	style.ahk1.4=$(s4ahk.style.operator)
	style.ahk1.5=$(s4ahk.style.operator)
	style.ahk1.6=$(s4ahk.style.string)
	style.ahk1.7=$(s4ahk.style.number)
	style.ahk1.8=$(s4ahk.style.var)
	style.ahk1.9=$(s4ahk.style.var)
	style.ahk1.10=$(s4ahk.style.label)
	style.ahk1.11=$(s4ahk.style.flow)
	style.ahk1.12=$(s4ahk.style.bif)
	style.ahk1.13=$(s4ahk.style.func)
	style.ahk1.14=$(s4ahk.style.directive)
	style.ahk1.15=$(s4ahk.style.old.key)
	style.ahk1.16=$(s4ahk.style.biv)
	style.ahk1.17=$(s4ahk.style.wordop)
	style.ahk1.18=$(s4ahk.style.old.user)
	style.ahk1.19=$(s4ahk.style.biv)
	style.ahk1.20=$(s4ahk.style.error)
	if s4ahk.style.old.synop
	`tstyle.ahk1.4=$(s4ahk.style.old.synop)
	if s4ahk.style.old.deref
	`tstyle.ahk1.9=$(s4ahk.style.old.deref)
	if s4ahk.style.old.bivderef
	`tstyle.ahk1.19=$(s4ahk.style.old.bivderef)

	)

UserProps =
(
# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH
locale.properties=locales\%p_locale%.locale.properties
make.backup=%p_backup%
code.page=%p_encoding%
output.code.page=%p_encoding%
save.position=%p_savepos%
magnification=%p_zoom%
import Styles\%p_style%.style
%p_extra%import _extensions
)

FileDelete, %UserPropsFile%
FileAppend, %UserProps%, %UserPropsFile%

; Reload properties
scite.ReloadProps()

if !regenMode && (p_locale != org_locale || p_zoom != org_zoom)
{
	Gui, +OwnDialogs
	MsgBox, 52, SciTE properties editor, Changing the language or the zoom value requires restarting SciTE.`nReopen SciTE?
	IfMsgBox, Yes
	{
		Gui, Destroy
		WinClose, ahk_id %scite_hwnd%
		WinWaitClose,,, 10
		if !ErrorLevel
			Run, "%A_ScriptDir%\..\SciTE.exe"
		ExitApp
	}
}

return

FindProp(regex, default := "")
{
	global UserProps
	return RegExMatch(UserProps, "`am)^" regex "$", o) ? o1 : default
}

ReplaceProp(regex, repl)
{
	global UserProps
	UserProps := RegExReplace(UserProps, "`am)^" regex "$", repl)
}

CountStylesAndChoose(ByRef choosenum)
{
	global p_style, LocalSciTEPath
	i := 1
	
	Loop, %LocalSciTEPath%\Styles\*.properties
	{
		if !RegExMatch(A_LoopFileName, "\.style\.properties$")
			continue
		style := RegExReplace(A_LoopFileName, "\.style\.properties$")
		if(style = p_style)
			choosenum := i
		list .= "|" Style
		i ++
	}
	StringTrimLeft, list, list, 1
	return list
}

CountLocalesAndChoose(ByRef choosenum)
{
	global p_locale
	i := 1
	
	Loop, %A_ScriptDir%\..\locales\*.properties
	{
		if !RegExMatch(A_LoopFileName, "\.locale\.properties$")
			continue
		locale := RegExReplace(A_LoopFileName, "\.locale\.properties$")
		if (locale = p_locale)
			choosenum := i
		list .= "|" locale
		i ++
	}
	StringTrimLeft, list, list, 1
	return list
}

FindInList(ByRef list, item, delim := "|")
{
	Loop, Parse, list, %delim%
		if (A_LoopField = item)
			return A_Index
}

GetItem(ByRef list, id, delim := "|")
{
	Loop, Parse, list, %delim%
		if (A_Index = id)
			return A_LoopField
}

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
