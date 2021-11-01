;
; SciTE4AutoHotkey Autorun Script
;

#NoEnv
#NoTrayIcon
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%

公用:
  oSciTE := ComObjActive("SciTE4AHK.Application")
  SciTE_Hwnd := oSciTE.SciTEHandle
	
	; 由于原版网站已经挂了，估计也不会再更新了，所以屏蔽升级检测，避免带来额外问题
	; bUpdatesEnabled := oSciTE.ResolveProp("automatic.updates") + 0
	; if bUpdatesEnabled
		; Run, "%A_AhkPath%" SciTEUpdate.ahk /silent
	
	bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0
	if bTillaGotoEnabled
		Run, "%A_AhkPath%" TillaGoto.ahk
	
	UserAutorun := oSciTE.UserDir "\Autorun.ahk"
	IfExist, %UserAutorun%
		Run, "%A_AhkPath%" "%UserAutorun%"
	
  gosub, 智能F1
  gosub, 智能Tab
  gosub, 智能标点
	
  WinWaitClose, ahk_id %SciTE_Hwnd% ; 随 SciTE 退出。
  WinClose, ahk_pid %PID%           ; 退出时关闭帮助。
  ExitApp
return

#Include %A_LineFile%\..\智能操作\智能F1.ahk
#Include %A_LineFile%\..\智能操作\智能Tab.ahk
#Include %A_LineFile%\..\智能操作\智能标点.ahk