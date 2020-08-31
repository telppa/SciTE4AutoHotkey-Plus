;
; File encoding:  UTF-8
;
; COM interface for SciTE4AutoHotkey
;     version 1.0 - fincs
;

;------------------------------------------------------------------------------
; COM interface methods
;------------------------------------------------------------------------------

CoI_Methods =
(Join, Com
; Meta
GetVersion & Version = CoI_GetVersion
GetSciTEHandle & SciTEHandle = CoI_GetSciTEHandle
Message
ReloadProps
SciTEDir
IsPortable
UserDir

; Files
GetCurrentFile & CurrentFile = CoI_GetCurrentFile
OpenFile
DebugFile
GetTabs & Tabs = CoI_GetTabs
SwitchToTab

; Text
GetDocument & Document = CoI_GetDocument
GetSelection & Selection = CoI_GetSelection
InsertText
Output

; Platform
GetActivePlatform & ActivePlatform = CoI_GetActivePlatform
SetPlatform

; Director
SendDirectorMsg
SendDirectorMsgRet
SendDirectorMsgRetArray
ResolveProp
)

CoI_Message(this, msg, wParam := 0, lParam := 0)
{
	global _msg, _wParam, _lParam, scitehwnd, hwndgui, ATM_OFFSET
	if (_msg := msg+0) = "" || (_wParam := wParam+0) = "" || (_lParam := lParam+0) = ""
		return
	if (msg >= ATM_OFFSET)
	{
		; Send message in a different thread in order to not crap out whilst exiting
		Critical
		SetTimer, SelfMessage, -10
	}else
		SendMessage, _msg, _wParam, _lParam,, ahk_id %scitehwnd%
	return ErrorLevel
	
	SelfMessage:
	PostMessage, _msg, _wParam, _lParam,, ahk_id %hwndgui%
	return
}

CoI_ReloadProps(this)
{
	global scitehwnd
	SendMessage, 1024+1, 0, 0,, ahk_id %scitehwnd%
}

CoI_SciTEDir(this)
{
	global SciTEDir
	return SciTEDir
}

CoI_IsPortable(this)
{
	global IsPortable
	return IsPortable
}

CoI_UserDir(this)
{
	global LocalSciTEPath
	return LocalSciTEPath
}

CoI_GetTabs(this)
{
	global filesmenu
	static VT_BSTR := 8
	static TabsDispTable := ComDispTable("Array=_GetAsSafeArray, List=_GetAsList, Count=_GetCount")
	
	filescount := DllCall("GetMenuItemCount", "ptr", filesmenu, "int") - 5
	tabs := ComObjArray(VT_BSTR, filescount)
	
	; This code is not 64-bit compatible.
	Loop, %filescount%
		; Prepare a structure
		VarSetCapacity(MENUITEMINFO, 12*4, 0)
		
		; MENUITEMINFO.cbSize = sizeof(MENUITEMINFO)
		, NumPut(12*4, MENUITEMINFO, "UInt")
		
		; MENUITEMINFO.fMask = MIIM_STRING
		, NumPut(0x00000040, MENUITEMINFO, 1*4, "UInt")
		
		; Get the size of the item name
		, DllCall("GetMenuItemInfo", "ptr", filesmenu, "uint", 4+A_Index, "int", 1, "ptr", &MENUITEMINFO)
		
		; Prepare a buffer for holding the data
		, VarSetCapacity(_data, (cch := NumGet(MENUITEMINFO, 10*4, "UInt")) * (!!A_IsUnicode + 1))
		
		; Fill the structure with the buffer
		, NumPut(&_data, MENUITEMINFO, 9*4), NumPut(cch + 1, MENUITEMINFO, 10*4, "UInt")
		
		; Retrieve the item name
		, DllCall("GetMenuItemInfo", "ptr", filesmenu, "uint", 4+A_Index, "int", 1, "ptr", &MENUITEMINFO)
		, VarSetCapacity(_data, -1)
		
		; Append the item to the list
		, tabs[A_Index-1] := RegExReplace(RegExReplace(_data, "^&\d\s"), "&&", "&")
		
	; Return the Tabs object
	return ComDispatch(tabs, TabsDispTable)
}

_GetAsSafeArray(this)
{
	copy := this.Clone(), ComObjFlags(copy, -1)
	return copy
}

_GetAsList(this)
{
	for item in this
		list .= item "`n"
	StringTrimRight, list, list, 1
	return list
}

_GetCount(this)
{
	return this.MaxIndex() + 1
}

CoI_SwitchToTab(this, idx)
{
	global scitehwnd
	
	if IsObject(idx) || (idx+0) = ""
		return
	
	PostMessage, 0x111, 1200+idx, 0,, ahk_id %scitehwnd%
}

CoI_GetDocument(this)
{
	global scintillahwnd
	return SciUtil_GetText(scintillahwnd)
}

CoI_InsertText(this, text, pos=-1)
{
	global scintillahwnd
	if !IsObject(text) && text && !IsObject(pos) && (pos+0) >= -1
		SciUtil_InsertText(scintillahwnd, text, pos)
}

CoI_GetSelection(this)
{
	global scintillahwnd
	return SciUtil_GetSelection(scintillahwnd)
}

CoI_Output(this, text)
{
	Director_Send("output:" CEscape(text))
}

CoI_GetSciTEHandle(this)
{
	global scitehwnd
	return scitehwnd
}

CoI_GetActivePlatform(this)
{
	global curplatform
	return curplatform
}

CoI_SetPlatform(this, plat)
{
	global platforms, curplatform
	if !platforms[plat]
		return 0
	else
	{
		curplatform := plat
		gosub platswitch2
		return 1
	}
}

CoI_GetCurrentFile(this)
{
	return GetSciTEOpenedFile()
}

CoI_GetVersion(this)
{
	global CurrentSciTEVersion
	return CurrentSciTEVersion
}

CoI_OpenFile(this, file)
{
	global scitehwnd
	
	WinActivate, ahk_id %scitehwnd%
	
	if CoI_GetCurrentFile(this) = file
		return
	
	Director_Send("open:" CEscape(file))
}

CoI_DebugFile(this, file)
{
	CoI_OpenFile(this, file)
	Cmd_Debug()
}

CoI_SendDirectorMsg(this, msg)
{
	return Director_Send(msg)
}

global CMsgRetDispTable := ComDispTable("Verb=_CoI_RetGetVerb, Value=_CoI_RetGetValue")

CoI_SendDirectorMsgRet(this, msg)
{
	return ComDispatch(Director_Send(msg, true), CMsgRetDispTable)
}

CoI_SendDirectorMsgRetArray(this, msg)
{
	obj := Director_Send(msg, true, true)
	array := ComObjArray(VT_VARIANT:=12, (t := obj.MaxIndex()) ? t : 0), ComObjFlags(array, -1)
	for each, msg in obj
		array[each - 1] := ComDispatch(msg, CMsgRetDispTable)
	return array
}

_CoI_RetGetVerb(this)
{
	return this.type
}

_CoI_RetGetValue(this)
{
	return this.value
}

CoI_ResolveProp(this, propname)
{
	propVal := Director_Send("askproperty:" propname, true).value
	if SubStr(propVal, 1, 11) != "stringinfo:"
		return
	propVal := SubStr(propVal, 12)
	while RegExMatch(propVal, "O)\$\((.+?)\)", o)
		propVal := SubStr(propVal, 1, o.Pos-1) CoI_ResolveProp(this, o.1) SubStr(propVal, o.Pos+o.Len)
	return propVal
}

;------------------------------------------------------------------------------
; Initialization code
;------------------------------------------------------------------------------

goto _skip_file

InitComInterface()
{
	global CLSID_SciTE4AHK, APPID_SciTE4AHK, oSciTE, hSciTE_Remote, CoI_Methods, IsPortable
	
	if IsPortable
	{
		; Register our CLSID and APPID
		OnExit, IDCleanup
		RegisterIDs(CLSID_SciTE4AHK, APPID_SciTE4AHK)
	}
	
	; Create an IDispatch interface
	Loop, Parse, CoI_Methods, `,
	{
		if !(q := Trim(A_LoopField))
			continue
		IfNotInString, q, =
			funclist .= q "=CoI_" q ","
		else
			funclist .= q ","
	}
	StringTrimRight, funclist, funclist, 1
	oSciTE := ComDispatch("", funclist)
	
	; Expose it
	if !(hSciTE_Remote := ComRemote(oSciTE, CLSID_SciTE4AHK))
	{
		MsgBox, 16, SciTE4AutoHotkey, Can't create COM interface!`nSome program functions may not work.
		if IsPortable
			RevokeIDs(CLSID_SciTE4AHK, APPID_SciTE4AHK)
		OnExit
	}
}

IDCleanup:
RevokeIDs(CLSID_SciTE4AHK, APPID_SciTE4AHK)
ExitApp

RegisterIDs(CLSID, APPID)
{
	RegWrite, REG_SZ, HKCU, Software\Classes\%APPID%,, %APPID%
	RegWrite, REG_SZ, HKCU, Software\Classes\%APPID%\CLSID,, %CLSID%
	RegWrite, REG_SZ, HKCU, Software\Classes\CLSID\%CLSID%,, %APPID%
}

RevokeIDs(CLSID, APPID)
{
	RegDelete, HKCU, Software\Classes\%APPID%
	RegDelete, HKCU, Software\Classes\CLSID\%CLSID%
}

Str2GUID(ByRef var, str)
{
	VarSetCapacity(var, 16)
	DllCall("ole32\CLSIDFromString", "wstr", str, "ptr", &var)
	return &var
}

_skip_file:
_=_
