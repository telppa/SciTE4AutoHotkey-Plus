;
; File encoding:  UTF-8
;
; Script description:
;	SUpd - SciTE4AutoHotkey update routines
;

#NoEnv
#NoTrayIcon

global SciTEDir, ParentPID

SUpd_Main()
{
	SendMode Input
	SetWorkingDir, %A_ScriptDir%
	SplitPath, A_AhkPath,, SciTEDir
	ParentPID := __GetParentPID()
	UpdateMain()
	ExitApp
}

SUpd_File(id, out)
{
	fname := A_ScriptDir "\" id ".bin"
	IfNotExist, %fname%
		throw Exception("Unknown file ID", -1, id)
	FileCopy, %fname%, %out%, 1
}

;------------------------------------------------------------------------------
; Internal functions
;------------------------------------------------------------------------------

__GetParentPID()
{
	hScriptProc := DllCall("GetCurrentProcess", "ptr")
	
	VarSetCapacity(pbi, sizeof_pbi := 6*A_PtrSize)
	if DllCall("ntdll\NtQueryInformationProcess", "ptr", hScriptProc, "uint", 0, "ptr", &pbi, "uint", sizeof_pbi, "ptr", 0, "uint") ; 0=ProcessBasicInformation
		throw Exception("NtQueryInformationProcess()", 0, rc " - " w " - " sizeof_pbi) ; Short msg since so rare.
	
	return NumGet(pbi, 5*A_PtrSize)
}
