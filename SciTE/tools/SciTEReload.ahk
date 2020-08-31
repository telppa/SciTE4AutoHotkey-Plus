;
; SciTE4AutoHotkey Reload Script
;

#NoEnv
SendMode, Input
SetWorkingDir, %A_ScriptDir%\..\

if 0 = 0
{
	MsgBox, 16, SciTE4AutoHotkey, You mustn't run this script directly!
	ExitApp
}

hWnd = %1%

IfWinExist, ahk_id %1%
	WinWaitClose

Sleep, 1000

Run, "%A_WorkingDir%\SciTE.exe"
