;
; File encoding:  UTF-8
;
; SciTE macro support
;     version 1.0 - fincs
;

goto _scim_skip

Macro_Init()
{
	global SciTEMacro
	SciTEMacro := "" ;[]
	
	Director_Send("macroenable:1")
}

SciTE_OnMacro(val)
{
	global SciTEMacroValue
	SciTEMacroValue := val
	SetTimer, OnMacro, -10
}

OnMacro:
Critical
HandleMacroMsg(SciTEMacroValue)
return

HandleMacroMsg(rawmsg)
{
	colon := InStr(rawmsg, ":")
	verb := SubStr(rawmsg, 1, colon-1)
	arg := SubStr(rawmsg, colon+1)
	func := "SciTE_OnMacro" verb
	if IsFunc(func)
		%func%(arg)
}

SciTE_OnMacroGetList()
{
	static _created_menu := 0
	macros := ListMacros()
	if !macros.MaxIndex()
	{
		MsgBox, 48, Toolbar, There aren't any macros!
		return
	}
	if _created_menu
		Menu, MacroList, DeleteAll
	for each, macro in macros
		Menu, MacroList, Add, %macro%, _run_macro
	Menu, MacroList, Show
	_created_menu := 1
}

SciTE_OnMacroRecord(param)
{
	global SciTEMacro
	; Workaround: SciTE does not quite generate what it should
	param := RegExReplace(param, "^(\d+?);(\d+?);1", "$1;0IS;$2")
	param := RegExReplace(param, "^(\d+?);(\d+?);0;$", "$1;0II;$2;0")
	SciTEMacro .= CEscape(param) "`n"
}

SciTE_OnMacroStopRecord()
{
	global SciTEMacro, LocalSciTEPath
	macro := SciTEMacro
	SciTEMacro := ""
	StringTrimRight, macro, macro, 1
	
	InputBox, macro_name, Macro recorder, Enter name for the macro
	if ErrorLevel
		return
	macrofile := LocalSciTEPath "\Macros\" macro_name ".macro"
	FileDelete, %macrofile%
	FileAppend, % macro, %macrofile%, UTF-8
}

_run_macro:
Director_Send("currentmacro:" A_ThisMenuItem)
SciTE_OnMacroRun(A_ThisMenuItem)
return

SciTE_OnMacroRun(macro)
{
	global LocalSciTEPath
	if !macro
	{
		MsgBox, 48, Toolbar, You must select a macro first!
		return
	}
	macrofile := LocalSciTEPath "\Macros\" macro ".macro"
	IfExist, %macrofile%
	Loop, Read, %macrofile%
		macrodata .= "macrocommand:" A_LoopReadLine "`n"
	StringTrimRight, macrodata, macrodata, 1
	Director_Send(macrodata)
}

ListMacros()
{
	global LocalSciTEPath
	macros := []
	Loop, %LocalSciTEPath%\Macros\*.macro
	{
		SplitPath, A_LoopFileFullPath,,,, namenoext
		macros.Insert(namenoext)
	}
	return macros
}

_scim_skip:
_=_
