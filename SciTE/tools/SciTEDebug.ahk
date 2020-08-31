;
; SciTE4AutoHotkey Script Debugger
;
;TillaGoto.iIncludeMode = 0x10111111

;{ Auto-Execute Section

#SingleInstance Ignore
#NoTrayIcon
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On

global g_appTitle := "SciTE4AutoHotkey Debugger"
ADM_SCITE := 0x1010
ATM_OFFSET := 0x1000
ATM_STARTDEBUG := ATM_OFFSET+0
ATM_STOPDEBUG  := ATM_OFFSET+1
ATM_DRUNTOGGLE := ATM_OFFSET+4
SciControl_InitConstants()

global A_Args := []
Loop, %0%
	A_Args.Push(%A_Index%)

if A_IsCompiled
{
	MsgBox, 16, %g_appTitle%, This program *must* be a uncompiled script!
	ExitApp
}

if A_Args.Length() = 0
{
	MsgBox, 16, %g_appTitle%, You mustn't run this script directly!
	ExitApp
}

; Get the COM SciTE object
oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, %g_appTitle%, SciTE must be running!
	ExitApp
}

global dbgTextFont := oSciTE.ResolveProp("default.text.font")
dbgAddr := oSciTE.ResolveProp("ahk.debugger.address")
dbgPort := oSciTE.ResolveProp("ahk.debugger.port")+0
dbgCaptureStreams := !!oSciTE.ResolveProp("ahk.debugger.capture.streams")

global dbgMaxChildren := oSciTE.ResolveProp("ahk.debugger.max.obj.children")+0
global dbgMaxData := oSciTE.ResolveProp("ahk.debugger.max.data")+0

if A_Args[1] = "/attach"
	bIsAttach := true
else
{
	AhkExecutable := A_Args.RemoveAt(1)
	IfNotExist, %AhkExecutable%
	{
		MsgBox, 16, %g_appTitle%, The AutoHotkey executable doesn't exist!
		ExitApp
	}

	Loop, Files, %AhkExecutable%
	{
		AhkExecutable := A_LoopFileLongPath
		break
	}
	
	ahkType := AHKType(AhkExecutable)
	
	if ahkType = FAIL
	{
		MsgBox, 16, %g_appTitle%, Invalid AutoHotkey executable!
		ExitApp
	}
	
	if ahkType = Legacy
	{
		MsgBox, 16, %g_appTitle%, Debugging is not supported in legacy versions of AutoHotkey (prior to v1.1).
		ExitApp
	}
}

; Get the HWND of SciTE and its Scintilla controls
scitehwnd := oSciTE.SciTEHandle
ControlGet, scintillahwnd, Hwnd,, Scintilla1, ahk_id %scitehwnd%
ControlGet, sciOutputHwnd, Hwnd,, Scintilla2, ahk_id %scitehwnd%

; Initialize output pane and related variables
sciOutputCP := oSciTE.ResolveProp("output.code.page")
if (sciOutputCP = "") ; This means "use the current file's codepage".
{
	SendMessage 2137, 0, 0,, ahk_id %sciOutputHwnd% ; SCI_GETCODEPAGE
	sciOutputCP := ErrorLevel
}
if oSciTE.ResolveProp("clear.before.execute")
	SendMessage, 2004, 0, 0,, ahk_id %sciOutputHwnd% ; SCI_CLEARALL
ControlGetPos, ,,, outputHeight,, ahk_id %sciOutputHwnd%
if !outputHeight ; Output pane not visible
	SendMessage 0x111, 409, 0,, ahk_id %scitehwnd% ; Toggle output pane

; Get the SciTE path
SciTEPath := oSciTE.SciTEDir
SciTEUserHome := oSciTE.ResolveProp("SciteUserHome")

; Get the script to debug
szFilename := !bIsAttach ? oSciTE.CurrentFile : SelectAttachScript(AttachWin, Dbg_PID)
if szFilename =
	ExitApp

; Do not allow debugging neither the toolbar nor the debugger itself
if InStr(szFilename, SciTEPath "\toolbar\") = 1 || (szFilename = A_ScriptFullPath)
{
	MsgBox, 48, %g_appTitle%, Debuging SciTE4AutoHotkey's debugger and toolbar scripts is not supported.
	ExitApp
}

; Check if the toolbar is running
ControlGet, toolbarhwnd, Hwnd,, AutoHotkeyGUI1, ahk_id %scitehwnd%
if toolbarhwnd =
{
	MsgBox, 16, %g_appTitle%, Can't find the toolbar window!
	ExitApp
}

OnExit, GuiClose ; activate an OnExit trap
Gui, Show, Hide, SciTEDebugStub ; create a dummy GUI that SciTE will speak to

; Run SciTE
WinActivate, ahk_id %scitehwnd%
Hotkey, ^!z, CancelSciTE
SciTE_Output("> Waiting for SciTE to connect...  Press Ctrl-Alt-Z to cancel")
SciTEConnected := false
OnMessage(ADM_SCITE, "SciTEMsgHandler")
SciTE_Connect()
Hotkey, ^!z, Off

; Run AutoHotkey and wait for it to connect
SciTE_Output("> Waiting for AutoHotkey to connect...", true)

; Initialize variables
Dbg_OnBreak := true
Dbg_HasStarted := false
Dbg_IsClosing := false
Dbg_ExitByDisconnect := false
Dbg_ExitByGuiClose := false
Dbg_WaitClose := false
Dbg_StackTraceWin := false
Dbg_StreamWin := false
Dbg_BkList := []
Dbg_Ini := SciTEUserHome "\SciTEDebug.ini"

SetDvOwnerWindow()

; Set the DBGp event handlers
DBGp_OnBegin("OnDebuggerConnection")
DBGp_OnBreak("OnDebuggerBreak")
DBGp_OnStream("OnDebuggerStream")
DBGp_OnEnd("OnDebuggerDisconnection")

; Now really run AutoHotkey and wait for it to connect
Dbg_Socket := DBGp_StartListening(dbgAddr, dbgPort) ; start listening
SplitPath, szFilename,, szDir

allArgs := ObjJoin(A_Args,, """")
if !bIsAttach
	Run, "%AhkExecutable%" /Debug=%dbgAddr%:%dbgPort% "%szFilename%" %allArgs%, %szDir%,, Dbg_PID ; run AutoHotkey and store its process ID
else
{
	; Set the Last Found Window
	WinWait, ahk_id %AttachWin%
	; Get PID of the AutoHotkey window
	WinGet, Dbg_PID, PID
	; Tell AutoHotkey to debug
	PostMessage, DllCall("RegisterWindowMessage", "str", "AHK_ATTACH_DEBUGGER"), DllCall("ws2_32\inet_addr", "astr", dbgAddr), dbgPort
}

while (Dbg_AHKExists := Util_ProcessExist(Dbg_PID)) && Dbg_Session = "" ; wait for AutoHotkey to connect or exit
	Sleep, 100 ; avoid smashing the CPU
DBGp_StopListening(Dbg_Socket) ; stop listening

if bIsAttach
{
	Dbg_GetStack()
	SciTE_UpdateCurLineOfCode()
}

if !Dbg_AHKExists
{
	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

if Dbg_Lang != AutoHotkey
{
	; Oops, wrong language, we've got to exit again
	MsgBox, 16, %g_appTitle%, Invalid language: %Dbg_Lang%.

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
	OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
	OnExit ; disable the OnExit trap
	ExitApp ; exit
}

; Update status in output pane
SciTE_Output("> Debugging " szFilename "`n", true)

; Reset saved breakpoints
SendMessage, 0x111, 1135, 0,, ahk_id %scitehwnd%

; Restore variable list/inspector windows
LoadDvWindows()

; Main loop
while !Dbg_IsClosing ; while the debugger is active
{
	IfWinNotExist, ahk_id %scitehwnd% ; oops, the user closed the SciTE window
	{
		if !Dbg_ExitByDisconnect
			DBGp_CloseDebugger(true) ; force closing
		break
	}
	if !Util_ProcessExist(Dbg_PID)
	{
		Dbg_ExitByDisconnect := true
		SciTE_Disconnect()
		break
	}
	; Sleep *after* the above checks, not before, so Dbg_IsClosing is
	; checked first and SciTE_Disconnect() is called only once on Stop.
	Sleep, 100
}
if Dbg_ExitByGuiClose ; we've got to tell SciTE that we are leaving
{
	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	SciTE_Disconnect()
}
SaveDvWindows()
SciTE_Output("> Debugging stopped`n")
OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
OnExit ; disable the OnExit trap
ExitApp

CancelSciTE:
OnExit
ExitApp

;}

;{ Script Attaching

SelectAttachScript(ByRef outwin, ByRef outpid)
{
	global SciTEPath
	
	oldTM := A_TitleMatchMode, oldHW := A_DetectHiddenWindows
	SetTitleMatchMode, 2
	DetectHiddenWindows, On
	
	WinGet, w, List, - AutoHotkey ahk_class AutoHotkey,, %A_ScriptFullPath%
	
	Gui, +LabelAttGui +ToolWindow +AlwaysOnTop
	Gui, Add, ListView, x0 y0 w640 h240 +NoSortHdr -LV0x10 gAttGuiSelect, HWND|Name
	
	i := 0
	Loop, % w
	{
		hwnd := w%A_Index%
		WinGetTitle, ov, ahk_id %hwnd%
		if InStr(ov, SciTEPath) ; Do not allow debugging SciTE4AutoHotkey itself
			continue
		if !RegExMatch(ov, "v([0-9.]+)(-\S+)?$", q) ; Make sure it has a correctly-formed version number
			continue
		if q1 < 1.1.00.00 ; Make sure it is NOT a legacy AutoHotkey version
			continue
		LV_Add("", hwnd, ov)
		i ++
	}
	
	if i = 0
	{
		MsgBox, 48, %g_appTitle%, There are no currently running debuggable AutoHotkey scripts!
		return ""
	}
	
	LV_ModifyCol(1, "AutoHdr")
	LV_ModifyCol(2, "AutoHdr")
	
	Gui, Show, w640 h240, Select running script to debug
	
	global attSelection, attWin
	while !attSelection
		Sleep, 100
	
	if attSelection = -1
		filename := "", outwin := "", outpid := ""
	else
	{
		LV_GetText(filename, attSelection, 2)
		LV_GetText(outwin, attSelection, 1)
		WinGet, outpid, PID, ahk_id %outwin%
	}
	
	Gui, Destroy
	
	DetectHiddenWindows, %oldTM%
	SetTitleMatchMode, %oldTM%
	return filename
}

AttGuiClose:
attSelection := -1
return

AttGuiSelect:
if A_GuiEvent != DoubleClick
	return
attSelection := A_EventInfo
return

;}

;{ Toolbar Commands

F5::
if Dbg_OnBreak
	goto cmd_run
else
	goto cmd_pause

cmd_run:
Dbg_Continue("run")
return

cmd_pause:
if !bIsAsync
{
	MsgBox, 48, %g_appTitle%, Script pausing is not supported in this AutoHotkey version!
	return
}

; We want to send AutoHotkey a break command.
; It must be sent asynchronously because we want to discard its
; response as fast as possible, otherwise OnBreak misbehaves due
; to the use of synchronous commands.
Dbg_Session.Send("break", "", Func("DummyCallback"))
return

DummyCallback(session, ByRef response)
{
}

cmd_stop:
if bIsAttach
{
	MsgBox, 35, %g_appTitle%, Do you wish to stop the script (YES) or just stop debugging (NO)?
	IfMsgBox, Cancel
		return
	IfMsgBox, No
	{
		Dbg_Session.property_set("-n A_DebuggerName --")
		Dbg_Session.detach()
		return
	}
}

; Let the OnExit handler take care of this
OnExit
goto GuiClose

F10::
cmd_stepinto:
Dbg_Continue("step_into")
return

F11::
cmd_stepover:
Dbg_Continue("step_over")
return

+F11::
cmd_stepout:
Dbg_Continue("step_out")
return

cmd_stacktrace:
if Dbg_StackTraceWin
	return
if !Dbg_OnBreak
{
	if !bIsAsync
		return
	Dbg_GetStack()
}
ST_Create()
return

cmd_varlist:
if (!Dbg_OnBreak && !bIsAsync)
	return
cmd_varlist(Dbg_VarListWin)
return

cmd_varlist(ByRef dv)
{
	global Dbg_Session, scitehwnd
	if !dv
		dv := new DebugVarsGui(new Dv2ContextsNode(Dbg_Session))
	else
		dv.Refresh()
	dv.Show()
}

;}

;{ SciTE Message Handler

SciTEMsgHandler(wParam, lParam, msg, hwnd)
{
	Critical
	global scintillahwnd, SciTEConnected, Dbg_ExitByDisconnect, Dbg_Session
		, Dbg_IsClosing, Dbg_WaitClose, Dbg_OnBreak, bIsAsync, InitBkList
	
	; This code used to be a big if/else if block. I've changed it to this pseudo-switch structure.
	if IsLabel("_wP" wParam)
		goto _wP%wParam%
	else
		return false

_wP0: ; SciTE handshake
	SciTEConnected := true
	return true

_wP1: ; Breakpoint setting
	if !bIsAsync && !Dbg_OnBreak
		return true
	
	; We need to launch the breakpoint setting code in a separate thread due to usage of COM
	global _temp := StrGet(lParam, "UTF-8")
	SetTimer, SetBreakpointHelper, -10
	return true
	
_wP2: ; Variable inspection
	if !bIsAsync && !Dbg_OnBreak
	{
		MsgBox, 48, %g_appTitle%, You can't inspect a variable whilst the script is running!
		return false
	}
	
	p := StrSplit(StrGet(lParam, "UTF-8"), Chr(1))
	Dbg_VarName := p.Length()==1 ? p[1] : PropertyNameFromWord(p*)
	
	DvInspectProperty(Dbg_Session, Dbg_VarName)
	return true

_wP3: ; Command
	static _ := [ "run", "stop", "pause", "stepinto", "stepover", "stepout", "stacktrace", "varlist" ]
	p := "cmd_" _[lParam]
	if IsLabel(p)
		gosub %p%
	return true

_wP4: ; Hovering
	if !bIsAsync && !Dbg_OnBreak
		return true
	
	lParam := StrGet(lParam, "UTF-8")
	if lParam =
	{
		ToolTip
		return true
	}
	try propName := PropertyNameFromWord(StrSplit(lParam, Chr(1))*)
	if propName !=
	{
		Dbg_Session.property_get("-m 200 -n " propName, response)
		prop := loadXML(response).selectSingleNode("/response/property")
		propType := prop.getAttribute("type")
		if (propType = "undefined")
		{
			if prop.getAttribute("encoding") ; This is a bit of a hack...
				ToolTip, %propName% is uninitialized
			; Other properties actually don't exist.
			; else ToolTip, %propName% is undefined
		}
		else if (propType = "object")
		{
			propClass := prop.getAttribute("classname")
			propClass := ((propClass ~= "i)^[aeiou]") ? "an " : "a ") propClass
			ToolTip, %propName% is %propClass%
		}
		else
		{
			propData := DBGp_Base64UTF8Decode(prop.text)
			propSize := prop.getAttribute("size")
			if propSize > 200
				propData .= "..."
			ToolTip, %propName% = %propData%
		}
	}
	return true
	
_wP5: ; Breakpoint initialization
	bkfile := ""
	bklines := ""
	bkstring := StrGet(lParam, "UTF-8")
	InitBkList := {}
	Loop, Parse, bkstring, `n
	{
		bkpart := StrSplit(A_LoopField, "|")  ; filename|breakpoints
		InitBkList[bkpart[1]] := bk := []
		Loop, Parse, % bkpart[2], % A_Space
			 bk[A_LoopField] := true
	}
	SetTimer, InitBreakpoints, -10
	return true

_wP255: ; Disconnect
	if !Dbg_ExitByDisconnect
	{
		; This code is executed if the debugger is still present
		rc := DBGp_CloseDebugger()
		if !rc ; cancel the deattach if we are in run mode
			return false ; tell SciTE to not unload the debugging features
		Dbg_IsClosing := true
	}
	Dbg_WaitClose := true ; the main thread can finish waiting now
	Sleep, 10
	return true
}

PropertyNameFromWord(line, wordpos, wordlen)
{
	name := SubStr(line, wordpos, wordlen)
	i := wordpos
	while (i > 1 && SubStr(line, i-1, 1) == ".")
	{
		--i
		name := "." name
		if (i > 1 && SubStr(line, i-1, 1) == "]")
		{
			i := FindLeftBracket(line, i-1, "[")
			if !i
				return
		}
		i := RegExMatch(SubStr(line, 1, i-1), "(?:[\w#@$]|[^\x00-\x7F])+(?=[ \t]*$)", m)
		if !i
			return
		name := m name
	}
	return PropertyNameFromCode(SubStr(line, i), wordpos-i + wordlen)
}

PropertyNameFromCode(s, wordend)
{
	name := PropertyNameEval(s, i := 1, wordend)
	if (i <= wordend)
		throw Exception("Parse error",, SubStr(s,i))
	return name
}

PropertyNameEval(s, ByRef i, wordend:="")
{
	name := ""
	while i <= StrLen(s)
	{
		ch := SubStr(s, i, 1)
		if InStr(" `t", ch)
		{
			i += 1
			continue
		}
		if (ch == "[" && name != "")
		{
			Loop
			{
				index := PropertyNameEval(s, ++i)
				expr := PropertyIndexEval(index)
				if (expr = "")
					throw Exception("Array index eval failed",, index)
				name .= expr
				
				ch := SubStr(s,i,1)
				if (ch == "]")
				{
					++i
					break
				}
				if (ch != ",")
					throw Exception("Parse error",, SubStr(s,i))
			}
		}
		; The placement of this check decides what kind of expressions
		; to the right of the hovered word get included/excluded:
		if (wordend != "" && i > wordend)
			break
		if RegExMatch(s, (name == "" ? "\G" : "\G\.")
			. "(?:[\w#@$]|[^\x00-\x7F])+", m, i)
		{
			name .= m
			i += StrLen(m)
			continue
		}
		if (name == "" && InStr("""'", ch))
		{
			value := ParseQuotedString(s, i, ch)
			StringReplace value, value, `", "", All
			value = ["%value%"]
			i += StrLen(m)
			return value
		}
		break
	}
	return name
}

PropertyIndexEval(prop_name)
{
	if SubStr(prop_name,1,2) = "["""
		return prop_name
	if prop_name is integer
		return "[" prop_name "]"
	if prop_name is float
		return "[""" prop_name """]"
	global Dbg_Session
	Dbg_Session.property_get("-m 200 -n " prop_name, response)
	prop := loadXML(response).selectSingleNode("/response/property")
	if !prop
		|| prop.getAttribute("name") = "(invalid)" ; Invalid - abort.
		|| prop.getAttribute("size") > 200 ; Truncated - don't query (the wrong) property.
		return
	if prop.getAttribute("type") = "object"
		return "Object(" prop.getAttribute("address") ")"
	value := DBGp_Base64UTF8Decode(prop.text)
	if value is integer
		return "[" value "]"
	; The debugger uses "" to mean a literal quote, even on v2,
	; and does not recognize escape sequences.
	StringReplace value, value, `", "", All
	return "[""" value """]"
}

ParseQuotedString(s, ByRef i, q)
{
	value := ""
	while ++i <= StrLen(s)
	{
		ch := SubStr(s,i,1)
		if (ch == "``")
		{
			++i
			Transform ch, Deref, % ch SubStr(s,i,1)
		}
		else if (ch == q)
		{
			++i
			if (SubStr(s,i,1) != q)
				return value
		}
		value .= ch
	}
	throw Exception("Missing " q,, s)
}

FindLeftQuote(s, i, q)
{
	--i
	while i >= 1
	{
		if (SubStr(s, i, 1) == q)
		{
			ch := SubStr(s, i-1, 1)
			if (ch != "``" and ch != q)
				return i
			; TODO: Detect percent signs in v2
			--i ; Skip the escape char/first quote in the pair.
		}
		--i
	}
}

FindLeftBracket(s, i, b)
{
	--i
	while i >= 1
	{
		ch := SubStr(s, i, 1)
		if (ch == b)
			return i
		else if (ch == "]")
			i := FindLeftBracket(s, i, "[")
		else if SubStr(s, i-1, 1) != "``" && InStr("""'", ch)
			i := FindLeftQuote(s, i, ch)
		--i
	}
}

SetEnableChildren(v)
{
	global Dbg_Session
	Dbg_Session.feature_set("-n max_depth -v " (v ? 1 : 0))
}

SetBreakpointHelper:
SetBreakpoint(StrSplit(_temp,"|")*)
return

InitBreakpoints()
{
	global InitBkList
	for filepath, lines in InitBkList
		for line in lines
			SetBreakpoint(filepath, line)
	InitBkList := ""
}

return

SetBreakpoint(filepath, lParam, state:=1)
{
	global Dbg_Session, bInBkProcess
	
	uri := DBGp_EncodeFileURI(filepath)
	bk := Util_GetBk(uri, lParam)
	if ((bk != "") == (state != 0))
		return  ; Breakpoint already in the right state
	if (state = 0)  ; Remove (implies bk != "")
	{
		Dbg_Session.breakpoint_remove("-d " bk.id)
		Util_RemoveBk(uri, lParam)
		; SciTE_BPSymbolRemove(lParam)  ; Done by ahk.lua.  See below.
	}
	else  ; Add (implies bk == "")
	{
		bInBkProcess := true
		Dbg_Session.breakpoint_set("-t line -n " lParam " -f " uri, Dbg_Response)
		IfInString, Dbg_Response, <error ; Check if AutoHotkey actually inserted the breakpoint.
		{
			bInBkProcess := false
			return
		}
		dom := loadXML(Dbg_Response)
		bkID := dom.selectSingleNode("/response/@id").text
		/*
		; This is currently disabled because the new line number would need
		; to be communicated back to ahk.lua.  We don't simply set the marker
		; here, as that would only work for the current file (it would also
		; require ahk.lua to adjust its records based on the markers).
		Dbg_Session.breakpoint_get("-d " bkID, Dbg_Response)
		dom := loadXML(Dbg_Response)
		lParam := dom.selectSingleNode("/response/breakpoint[@id=" bkID "]/@lineno").text
		SciTE_BPSymbol(lParam)
		*/
		Util_AddBkToList(uri, lParam, bkID)
		bInBkProcess := false
	}
}

;}

;{ Exit Routine

GuiClose:
IfWinExist, ahk_id %scitehwnd%
{ ; SciTE is present
	rc := DBGp_CloseDebugger() ; attempt to close the debugger
	if !rc ; if we failed...
		return ; ... just return and don't exit
	; (We succeeded)
	; As we might be the OnExit thread (uninterruptible)
	; we have to pass control to the main thread
	Dbg_ExitByGuiClose := true ; exit by GuiClose
	Dbg_IsClosing := true      ; we're closing, indeed
	return ; just return and let the main thread exit (we set some variables earlier)
}else ; SciTE was closed
	DBGp_CloseDebugger(true) ; force the debugger to close itself

OnMessage(ADM_SCITE, "") ; disable the SciTE message handler
OnExit ; disable the OnExit trap
ExitApp ; exit

; DBGp_CloseDebugger() - used to close the debugger
DBGp_CloseDebugger(force := 0)
{
	global
	if !bIsAsync && !force && !Dbg_OnBreak
	{
		MsgBox, 52, %g_appTitle%, The script is running. Stopping it would mean loss of data. Proceed?
		IfMsgBox, No
			return 0 ; fail
	}
	DBGp_OnEnd("") ; disable the DBGp OnEnd handler
	if bIsAsync || Dbg_OnBreak
	{
		; If we're on a break or the debugger is async we don't need to force the debugger to terminate
		Dbg_Session.stop()
		Dbg_Session.Close()
	}else ; nope, we're not on a break, kill the process
	{
		Dbg_Session.Close()
		Process, Close, %Dbg_PID%
	}
	Dbg_Session := ""
	return 1 ; success
}

;}

;{ SciTE Kitchen Sink Functions

SciTE_Connect()
{
	global
	SendMessage, 0x111, 1124, 0,, ahk_id %scitehwnd% ; call the internal "Debug with AutoHotkey" command
	while !SciTEConnected ; wait for SciTE to connect
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STARTDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Enable the debugging buttons in the toolbar
	SendMessage, 1026, 1, 0,, ahk_id %scitehwnd% ; Enable [Debugging] mark in SciTE's window title
}

SciTE_ToggleRunButton()
{
	global
	SendMessage, ATM_DRUNTOGGLE, 0, 0,, ahk_id %toolbarhwnd%
}

SciTE_Disconnect()
{
	global
	
	Dbg_WaitClose := false
	d := A_TickCount
	SendMessage, 0x111, 1125, 0,, ahk_id %scitehwnd% ; call the "Close active debugging connection" command
	SendMessage, 1026, 0, 0,, ahk_id %scitehwnd% ; call the "Delete debugging title" command
	while !Dbg_WaitClose && (A_TickCount - d) < 1000 ; wait until we process that command
		Sleep, 100 ; sleep a delay to avoid smashing the CPU
	SendMessage, ATM_STOPDEBUG, 0, 0,, ahk_id %toolbarhwnd% ; Disable [Debugging] mark in SciTE's window title
}

;}

;{ DBGp Event Handlers

; OnDebuggerConnection() - fired when we receive a connection.
OnDebuggerConnection(session, init)
{
	global
	local response, dom
	if bIsAttach
		szFilename := session.File
	Dbg_Session := session ; store the session ID in a global variable
	dom := loadXML(init)
	Dbg_Lang := dom.selectSingleNode("/init/@language").text
	session.property_set("-n A_DebuggerName -- " DBGp_Base64UTF8Encode("SciTE4AutoHotkey"))
	session.feature_set("-n max_data -v " dbgMaxData)
	session.feature_set("-n max_children -v " dbgMaxChildren)
	SetEnableChildren(false)
	if dbgCaptureStreams
	{
		session.stdout("-c 2")
		session.stderr("-c 2")
	}
	session.feature_get("-n supports_async", response)
	bIsAsync := !!InStr(response, ">1<")
	; Really nothing more to do
}

; OnDebuggerBreak() - fired when we receive an asynchronous response from the debugger (including break responses).
OnDebuggerBreak(session, ByRef response)
{
	global Dbg_OnBreak, bInBkProcess, _tempResponse
	if bInBkProcess
	{
		; A breakpoint was hit while the script running and the SciTE OnMessage thread is
		; still running. In order to avoid crashing, we must delay this function's processing
		; until the OnMessage thread is finished.
		_tempResponse := response
		SetTimer, TryHandlingBreakAgain, -100
		return
	}
	dom := loadXML(response) ; load the XML document that the variable response is
	status := dom.selectSingleNode("/response/@status").text ; get the status
	if status = break
	{ ; this is a break response
		SciTE_ToggleRunButton()
		Dbg_OnBreak := true ; set the Dbg_OnBreak variable
		; Get info about the script currently running
		Dbg_GetStack()
		SciTE_UpdateCurLineOfCode()
		ST_Update()
		; Update variable lists and object inspectors
		DvRefreshAll()
	}
}

TryHandlingBreakAgain:
OnDebuggerBreak(Dbg_Session, _tempResponse)
return

; OnDebuggerStream() - fired when we receive a stream packet.
OnDebuggerStream(session, ByRef stream)
{
	dom := loadXML(stream)
	type := dom.selectSingleNode("/stream/@type").text
	; Base64-decode but leave as UTF-8:
	DBGp_StringToBinary(data, dom.selectSingleNode("/stream").text, 1)
	VarSetCapacity(data, -1)
	SciTE_OutputUTF8(data)
}

; OnDebuggerDisconnection() - fired when the debugger disconnects.
OnDebuggerDisconnection(session)
{
	global
	Critical

	Dbg_ExitByDisconnect := true ; tell our message handler to just return true without attempting to exit
	Dbg_ExitByGuiClose := true
	Dbg_IsClosing := true
	Dbg_OnBreak := true
	SendMessage, 1026, 0, 0,, ahk_id %scitehwnd% ; Disable [Debugging] mark in SciTE's window title
}

;}

;{ Wrapper for DBGp Commands that set Dbg_OnBreak

Dbg_Continue(cmd)
{
	global
	if !Dbg_OnBreak
		return
	SciTE_DeleteCurLineMarkers()
	ErrorLevel = 0
	Dbg_OnBreak := false
	Dbg_HasStarted := true
	Dbg_Session[cmd]()
	SciTE_ToggleRunButton()
	VE_Close()
	ST_Clear()
	DvContextNode.depth := 0
}

;}

;{ Stacktrace Window

ST_Create()
{
	global
	
	ST_Destroy()
	Dbg_StackTraceWin := true
	Gui 2:+ToolWindow +AlwaysOnTop +LabelSTGui +Resize +MinSize -MaximizeBox
	Gui 2:Add, ListView, x0 y0 w320 h240 +NoSortHdr -LV0x10 gST_Go vST_ListView, Script filename|Line|Stack entry
	ST_Update()
	Gui 2:Show, w320 h240, Callstack
}

ST_Clear()
{
	global
	
	if !Dbg_StackTraceWin
		return
	
	Gui 2:Default
	LV_Delete()
}

ST_Update()
{
	global
	if !Dbg_StackTraceWin
		return
	aStackWhere := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@where"))
	aStackFile  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@filename"))
	aStackLine  := Util_UnpackNodes(Dbg_Stack.selectNodes("/response/stack/@lineno"))
	Loop, % aStackFile.MaxIndex()
		aStackFile[A_Index] := DBGp_DecodeFileURI(aStackFile[A_Index])
	
	Gui 2:Default
	LV_Delete()
	Loop, % aStackWhere.MaxIndex()
		LV_Add("", ST_ShortName(aStackFile[A_Index]), aStackLine[A_Index], aStackWhere[A_Index])
	LV_ModifyCol(1, "AutoHdr")
	LV_ModifyCol(2, "AutoHdr")
	LV_ModifyCol(3, "AutoHdr")
}

ST_ShortName(a)
{
	SplitPath, a, b
	return b
}

ST_Destroy()
{
	global
	aStackWhere=
	aStackFile=
	aStackLine=
	Gui 2:Destroy
	Dbg_StackTraceWin := False
}

ST_Go:
if A_GuiEvent != DoubleClick
	return
SciTE_EnsureFileIsOpen(aStackFile[A_EventInfo])
SciTE_SetCurrentLine(aStackLine[A_EventInfo], 0)
WinActivate, ahk_id %scitehwnd%
DvContextNode.depth := A_EventInfo-1
DvRefreshAll()
return

STGuiClose:
ST_Destroy()
return

STGuiSize:
GuiControl, Move, ST_ListView, w%A_GuiWidth% h%A_GuiHeight%
return

Dbg_GetStack()
{
	global
	if !Dbg_OnBreak && !bIsAsync
		return
	Dbg_Session.stack_get("", Dbg_Stack := "")
	Dbg_Stack := loadXML(Dbg_Stack)
}

;}

;{ Variable Lists, Variable and Object Inspection

#Include <DebugVarsGui>

SetDvOwnerWindow()
{
	fn := Func("ShowDvWindow")
	DebugVarsGui.Show := fn.Bind(DebugVarsGui.Show)
	DebugVarGui.Show := fn.Bind(DebugVarGui.Show)
}

ShowDvWindow(show, dv, options:="", title:="")
{
	%show%(dv, options, title)
	global scitehwnd
	Gui % dv.hGui ":+Owner" scitehwnd " +ToolWindow"
}

VE_Close()
{
	for hwnd, ve in VarEditGui.Instances.Clone()
		ve.Hide()
}

SaveDvWindows()
{
	global Dbg_Ini, Dbg_VarListWin
	
	IniDelete %Dbg_Ini%, Windows ; Clear old list.
	
	VarSetCapacity(rect, 16, 0)
	count := 0
	windows := VarTreeGui.Instances
	windows[Dbg_VarListWin.hGui] := Dbg_VarListWin ; Insert (if hidden) or overwrite.
	for hwnd, dv in windows
	{
		; Get window type
		root := dv.TLV.root
		if (root.base = DvContextNode)
			type := "context:" root.context
		else if (root.base = Dv2ContextsNode)
			type := "variables"
		/*  ; Currently unused; see LoadDvWindows().
		else if (root.base = DvPropertyNode)
			type := "property:" root.fullname
		*/
		else
			continue
		
		WinGet minmax, MinMax, % "ahk_id " dv.hGui
		if minmax = -1
			continue
		opt := (DllCall("IsWindowVisible", "ptr", dv.hGui) ? "" : " Hide")
			.  (minmax = 1 ? " Maximize" : "")
		if minmax = 1 ; Restore to retrieve non-maximized position
			WinRestore % "ahk_id " dv.hGui
		
		; Save position and state
		WinGetPos x, y,,, % "ahk_id " dv.hGui
		DllCall("GetClientRect", "ptr", dv.hGui, "ptr", &rect)
		w := NumGet(rect, 8, "int")
		h := NumGet(rect, 12, "int")
		IniWrite x%x% y%y% w%w% h%h%%opt%`, %type%, %Dbg_Ini%, Windows, % ++count
	}
}

LoadDvWindows()
{
	global Dbg_Ini, Dbg_Session, Dbg_VarListWin
	
	Loop
	{
		IniRead options, %Dbg_Ini%, Windows, %A_Index%
		if !(p := InStr(options, ","))
			break
		type := Trim(SubStr(options, p+1)), options := SubStr(options, 1, p-1)
		if (type ~= "^context:")
		{
			root := new DvContextNode(Dbg_Session, SubStr(type, 9))
			dv := new DebugVarsGui(root)
			dv.Show("NA " options)
		}
		else if (type == "variables")
		{
			root := new Dv2ContextsNode(Dbg_Session)
			dv := new DebugVarsGui(root)
			dv.Show("NA " options)
			Dbg_VarListWin := dv
		}
		/*  ; This is unused because properties are generally undefined at
		    ; this point, and that causes the wrong type of Gui to open.
		else if (type ~= "^property:")
			DvInspectProperty(Dbg_Session, SubStr(type, 10),, "NA " options)
		*/
	}
}

;}

;{ Even More SciTE Kitchen Sink Functions

SciTE_UpdateCurLineOfCode()
{
	global Dbg_Stack, szFilename
	
	cLine := Dbg_Stack.selectSingleNode("/response/stack[1]/@lineno").text
	cFNameURI := Dbg_Stack.selectSingleNode("/response/stack[1]/@filename").text
	cFName := DBGp_DecodeFileURI(cFNameURI)
	
	if cLine =
	{
		SciTE_EnsureFileIsOpen(szFilename)
		return
	}
	
	SciTE_EnsureFileIsOpen(cFName)
	SciTE_SetCurrentLine(cLine)
}

SciTE_RedrawLine(hwnd, line)
{
	global
	
	IfWinNotActive, ahk_id %scitehwnd%
		WinActivate
	
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_ENSUREVISIBLEENFORCEPOLICY, "int", line, "int", 0)
	DllCall("SendMessage", "ptr", hwnd, "uint", SCI_GOTOLINE, "int", line, "int", 0)
}

SciTE_EnsureFileIsOpen(fname)
{
	global oSciTE, scitehwnd
	if SciTE_GetFile() != fname
		oSciTE.OpenFile(fname)
	IfWinNotActive, ahk_id %scitehwnd%
		WinActivate, ahk_id %scitehwnd%
}

SciTE_GetFile()
{	
	global oSciTE
	return oSciTE.CurrentFile
}

SciTE_SetCurrentLine(line, mode := 1) ; show the current line markers in SciTE
{
	global
	line--
	if mode
	{
		; Delete current markers
		SciTE_DeleteCurLineMarkers()
		; Add markers
		DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 11)
		DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 12)
	}
	; Refresh the Scintilla control
	SciTE_RedrawLine(scintillahwnd, line)
}

SciTE_DeleteCurLineMarkers() ; delete the current line markers in SciTE
{
	global
	; Delete current markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 11, "int", 0)
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETEALL, "int", 12, "int", 0)
}

/* ; Currently unused.
SciTE_BPSymbol(line) ; set a breakpoint marker in SciTE
{
	global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERADD, "int", line, "int", 10)
}

SciTE_BPSymbolRemove(line) ; remove a breakpoint marker in SciTE
{
	global
	line--
	; Add markers
	DllCall("SendMessage", "ptr", scintillahwnd, "uint", SCI_MARKERDELETE, "int", line, "int", 10)
}
*/

SciTE_OutputUTF8(ByRef data)  ; data: a UTF-8 string
{
	; Convert the string to the current output codepage (EM_REPLACESEL
	; is used so the OS handles marshalling the memory, but Scintilla
	; handles it the same as SCI_REPLACESEL; i.e. does no conversion).
	; If sciOutputCP is blank, it depends on whichever file is active.
	; We could get the current code page, but previous output can still
	; be corrupted when the user switches files.  So just assume UTF-8.
	global sciOutputCP, sciOutputHwnd
	if (sciOutputCP != 65001 && sciOutputCP != "")
	{
		sdata := StrGet(&data, "UTF-8")
		n := VarSetCapacity(data, StrPut(sdata, "UTF-8"))
		StrPut(sdata, &data, n, sciOutputCP)
	}
	SendMessage 2318, 0, 0,, ahk_id %sciOutputHwnd% ; SCI_DOCUMENTEND
	SendMessage 0xC2, % true, % &data,, ahk_id %sciOutputHwnd% ; EM_REPLACESEL
}

SciTE_Output(ByRef string, replaceLastLine:=false)
{
	global scitehwnd, sciOutputCP, sciOutputHwnd
	SendMessage 2318, 0, 0,, ahk_id %sciOutputHwnd% ; SCI_DOCUMENTEND
	if replaceLastLine
		SendMessage 2338, 0, 0,, ahk_id %sciOutputHwnd% ; SCI_LINEDELETE
	n := VarSetCapacity(data, StrPut(string, "UTF-8"))
	StrPut(string, &data, n, sciOutputCP)
	SendMessage 0xC2, % true, % &data,, ahk_id %sciOutputHwnd% ; EM_REPLACESEL
}

;}

;{ Sandbox

Util_UnpackNodes(nodes)
{
	o := []
	Loop, % nodes.length
		o.Insert(nodes.item[A_Index-1].text)
	return o
}

Util_EscapeRegEx(str)
{
	static tab := "\.*?+[{|()^$"
	Loop, % StrLen(tab)
		StringReplace, str, str, % SubStr(tab, A_Index, 1), % "\" SubStr(tab, A_Index, 1), All
	return str
}

Util_ProcessExist(a)
{
	t := ErrorLevel
	Process, Exist, %a%
	r := ErrorLevel
	ErrorLevel := t
	return r
}

Util_AddBkToList(uri, line, id, cond := "")
{
	global Dbg_BkList
	Dbg_BkList[uri, line] := { id: id, cond: cond }
}

Util_GetBk(uri, line)
{
	global Dbg_BkList
	return Dbg_BkList[uri, line]
}

Util_RemoveBk(uri, line)
{
	global Dbg_BkList
	Dbg_BkList[uri].Remove(line)
}

loadXML(ByRef data)
{
	o := ComObjCreate("MSXML2.DOMDocument")
	o.async := false
	o.setProperty("SelectionLanguage", "XPath")
	o.loadXML(data)
	return o
}

GetExeMachine(exepath)
{
	exe := FileOpen(exepath, "r")
	if !exe
		return
	
	exe.Seek(60), exe.Seek(exe.ReadUInt()+4)
	return exe.ReadUShort()
}

ObjJoin(obj, delim := " ", wrap := "")
{
	var := ""
	for _,val in obj
		val := wrap val wrap, var .= A_Index>1 ? delim val : val
	return var
}

;}
