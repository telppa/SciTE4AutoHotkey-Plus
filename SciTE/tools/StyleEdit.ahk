;
; SciTE4AutoHotkey Style Editor
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
ListLines, Off

Menu Tray, Icon, ..\toolicon.icl, 17

if 0 != 1
{
	MsgBox, 48, SciTE Style Editor, This script is not designed to be launched directly.
	ExitApp
}

StyleFileName = %1%

scite := GetSciTEInstance()
if !scite
{
	MsgBox 16, SciTE Style Editor, Can't find SciTE!
	ExitApp
}

FileEncoding UTF-8
FileRead StyleText, %StyleFileName%

if !RegExMatch(StyleText, "`am)^s4ahk\.style=1$")
{
	; Legacy style file which cannot be edited by this program.
	scite.OpenFile(StyleFilename)
	ExitApp
}

isv2 := InStr(scite.ResolveProp("ahk.platform"), "v2") = 1

styles := [{prop: "style.*.32", name: "Base Style" }
, {prop: "s4ahk.style.default", name: "Default" }
, {prop: "s4ahk.style.comment.line", name: "Line Comment" }
, {prop: "s4ahk.style.comment.block", name: "Block Comment" }
, {prop: "s4ahk.style.escape", name: "Escaped Char" }
, {prop: "s4ahk.style.operator", name: "Operator" }
, {prop: "s4ahk.style.string", name: "String" }
, {prop: "s4ahk.style.number", name: "Number" }
, {prop: "s4ahk.style.wordop", name: isv2 ? "Word operator" : "Keyword" }
, {prop: "s4ahk.style.var", name: "Variable" }
, {prop: "s4ahk.style.func", name: isv2 ? "Function" : "Built-in Function" }
, {prop: "s4ahk.style.directive", name: "Directive" }
, {prop: "s4ahk.style.label", name: "Label && Hotkey" }
, {prop: "s4ahk.style.flow", name: "Flow of Control" }
, {prop: "s4ahk.style.biv", name: "Built-in Variable" }
, {prop: "s4ahk.style.bif", name: isv2 ? "Built-in Function" : "Command" }
, {prop: "s4ahk.style.error", name: "Syntax Error" } ]
if (!isv2)
{
	styles.Insert({prop: "s4ahk.style.old.key", name: "Key && Button"})
	styles.Insert({prop: "s4ahk.style.old.user", name: "User Keyword"})
}

data := {}

Menu, TheMenu, Add, Set Color, SetColor
Menu, TheMenu, Add, Inherit Color, InheritColor

Gui +ToolWindow +AlwaysOnTop +HwndMainWin
OnMessage(0x0138, "WM_CTLCOLORSTATIC")
Gui Add, Text, Section w80 Center, Code Font:
Gui Add, DDL, ys w210 vddlFont, % ListFonts()
GuiControl ChooseString, ddlFont, % GetTheProp("default.text.font")
Gui Add, Edit, ys w40 Number, 10
Gui Add, UpDown, veditFontSize
Gui Add, Text, xs Section w80 Center
Gui Add, Text, ys w80 Center, Text color
Gui Add, Text, ys w80 Center, Back color
Gui Font, Bold
Gui Add, Text, ys w25, B
Gui Font
Gui Font, Italic
Gui Add, Text, ys w25, I
Gui Font
Gui Font, Underline
Gui Add, Text, ys w25, U
Gui Font
Gui Add, Text, ys w30, EolFilled
for _,style in styles
{
	isFirst := A_Index = 1, Check3 := isFirst ? "" : "Check3"
	data[style.prop] := StrSplit(GetTheProp(style.prop), ",", " `t")
	Gui Add, Text, xs Section w80 Center, % style.name
	Gui Add, Text, ys Border w80 Center vtxtFgClr%A_Index% gChooseColor, % GetStyleParam(style.prop, "fore:")
	Gui Add, Text, ys Border w80 Center vtxtBgClr%A_Index% gChooseColor, % GetStyleParam(style.prop, "back:")
	cB := GetStyleCheck(style.prop, "bold", isFirst)
	cI := GetStyleCheck(style.prop, "italics", isFirst)
	cU := GetStyleCheck(style.prop, "underlined", isFirst)
	cE := GetStyleCheck(style.prop, "eolfilled", isFirst)
	Gui Add, CheckBox, ys %Check3% w25 vchkB%A_Index% Checked%cB%
	Gui Add, CheckBox, ys %Check3% w25 vchkI%A_Index% Checked%cI%
	Gui Add, CheckBox, ys %Check3% w25 vchkU%A_Index% Checked%cU%
	Gui Add, CheckBox, ys %Check3% w25 vchkE%A_Index% Checked%cE%
}
GuiControl,, editFontSize, % GetStyleParam(styles[1].prop, "size:")
Gui Add, Button, xs+150 Section gSaveStyle, Save Style
Gui Show,, SciTE4AutoHotkey Style Editor
WinSet, Redraw,, ahk_id %MainWin%
return

WM_CTLCOLORSTATIC(wParam, lParam, msg, hwnd)
{
	Critical
	static brushes := []
	Gui +OwnDialogs
	GuiControlGet varName, Name, %lParam%
	if InStr(varName, "txt") != 1
		return
	if (brush := brushes[lParam]) && brush >= 0
		DllCall("DeleteObject", "ptr", brush)
	GuiControlGet tt,, %varName%
	if (tt = "Inherited")
		return
	clr := ClrSwap(ColorUnpretty(tt))
	brush := DllCall("CreateSolidBrush", "uint", clr, "ptr")
	DllCall("SetBkMode", "uint", wParam, "int", 1)
	DllCall("SetTextColor", "uint", wParam, "int", clr)
	DllCall("SetBkColor", "uint", wParam, "int", clr)
	return brush
}

GuiClose:
ExitApp

SaveStyle:
Gui Submit, NoHide
Gui +OwnDialogs
for id,which in styles
{
	isntFirst := id>1
	parts := data[which.prop]
	; Remove all style props
	parts2 := []
	for _, part in parts
	{
		if part in bold,notbold,italics,notitalics,underlined,notunderlined,eolfilled,noteolfilled
			continue
		if InStr(part, "fore:") = 1 || InStr(part, "back:") = 1
			continue
		if !isntFirst && (InStr(part, "font:") = 1 || InStr(part, "size:") = 1)
			continue
		parts2.Insert(part)
	}
	if !isntFirst
	{
		parts2.Insert("font:$(default.text.font)")
		parts2.Insert("size:" editFontSize)
	}
	; Set colors
	GuiControlGet fore,, txtFgClr%id%
	GuiControlGet back,, txtBgClr%id%
	if (fore != "Inherited")
		parts2.Insert("fore:" fore)
	if (back != "Inherited")
		parts2.Insert("back:" back)
	; Set style
	(val:=chkB%A_Index%) = 1 ? parts2.Insert("bold")       : (isntFirst&&chkB1&&!val) ? parts2.Insert("notbold")       : ""
	(val:=chkI%A_Index%) = 1 ? parts2.Insert("italics")    : (isntFirst&&chkI1&&!val) ? parts2.Insert("notitalics")    : ""
	(val:=chkU%A_Index%) = 1 ? parts2.Insert("underlined") : (isntFirst&&chkU1&&!val) ? parts2.Insert("notunderlined") : ""
	(val:=chkS%A_Index%) = 1 ? parts2.Insert("eolfilled")  : (isntFirst&&chkE1&&!val) ? parts2.Insert("noteolfilled")  : ""
	; Build string
	str := ""
	for _,part in parts2
		str .= "," part
	StringTrimLeft str, str, 1
	SetTheProp(which.prop, str)
}
SetTheProp("default.text.font", ddlFont)
FileDelete, %StyleFileName%
FileAppend, % StyleText, %StyleFileName%
scite.ReloadProps()
return

ChooseColor:
Gui +OwnDialogs
lastCtrl := A_GuiControl, RegExMatch(lastCtrl, "(\d+)", o), styleId := o1
if (styleId = 1)
	goto SetColor
Menu, TheMenu, Show
return

SetColor:
GuiControlGet q,, %lastCtrl%
if (q = "Inherited")
	GuiControlGet q,, % InStr(lastCtrl, "bg") ? "txtBgClr1" : "txtFgClr1"
clr := ChooseColor(ColorUnpretty(q))
if (clr < 0)
	return
GuiControl,, %lastCtrl%, % ColorPretty(clr)
GuiControl, MoveDraw, %lastCtrl%
return

InheritColor:
GuiControl,, %lastCtrl%, Inherited
GuiControl, MoveDraw, %lastCtrl%
return

GetStyleParam(name, isit)
{
	global data
	for _,part in data[name]
		if InStr(part, isit) = 1
			return SubStr(part, StrLen(isit)+1)
	return "Inherited"
}

GetStyleCheck(name, isit, isFirst)
{
	global data
	for _,part in data[name]
		if (part = isit)
			return 1
		else if (part = "not" isit)
			return 0
	return isFirst ? 0 : "Gray"
}

GetTheProp(name)
{
	global StyleText
	StringReplace name, name, ., \., All
	StringReplace name, name, *, \*, All
	if !RegExMatch(StyleText, "`am)^" name "=(.*)$", o)
	{
		MsgBox Bad format!
		ExitApp
	}
	return o1
}

SetTheProp(name, val)
{
	global StyleText
	StringReplace name, name, ., \., All
	StringReplace name, name, *, \*, All
	StyleText := RegExReplace(StyleText, "`am)^(" name ")=.*$", "$1=" val)
}

ListFonts()
{
	VarSetCapacity(logfont, 128, 0), NumPut(1, logfont, 23, "UChar")
	obj := []
	DllCall("EnumFontFamiliesEx", "ptr", DllCall("GetDC", "ptr", 0), "ptr", &logfont, "ptr", RegisterCallback("EnumFontProc"), "ptr", &obj, "uint", 0)
	for font in obj
		list .= "|" font
	StringTrimLeft list, list, 1
	return list
}

EnumFontProc(lpFont, tm, fontType, lParam)
{
	obj := Object(lParam)
	obj[StrGet(lpFont+28)] := 1
	return 1
}

ChooseColor(initColor := -1)
{
	static init := false, buf
	if !init
	{
		init := true
		VarSetCapacity(buf, 16*4)
	}
	VarSetCapacity(CHOOSECOLOR, 9*A_PtrSize, 0)
	NumPut(9*A_PtrSize, CHOOSECOLOR, 0, "UInt")
	Gui +HwndHwnd
	NumPut(Hwnd, CHOOSECOLOR, 1*A_PtrSize, "UInt")
	NumPut(&buf, CHOOSECOLOR, 4*A_PtrSize)
	flags := 0x100 | 2
	if (initColor >= 0)
	{
		NumPut(ClrSwap(initColor), CHOOSECOLOR, 3*A_PtrSize, "UInt")
		flags |= 1
	}
	NumPut(flags, CHOOSECOLOR, 5*A_PtrSize, "UInt")
	return DllCall("comdlg32\ChooseColor", "ptr", &CHOOSECOLOR) ? ClrSwap(NumGet(CHOOSECOLOR, 3*A_PtrSize, "UInt")) : -1
}

ColorPretty(a)
{
	oldf := A_FormatInteger
	SetFormat, IntegerFast, H
	a += 0
	a := "#" SubStr("000000" SubStr(a, 3), -5)
	SetFormat, IntegerFast, %oldf%
	return a
}

ColorUnpretty(a)
{
	return "0x" SubStr(a, 2)
}

ClrSwap(a)
{
	return (a & 0xFF00) | (a >> 16) | ((a&0xFF)<<16)
}
