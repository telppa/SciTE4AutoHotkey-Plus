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
	
	bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0
	if bTillaGotoEnabled
		Run, "%A_AhkPath%" TillaGoto.ahk
	
	UserAutorun := oSciTE.UserDir "\Autorun.ahk"
	IfExist, %UserAutorun%
		Run, "%A_AhkPath%" "%UserAutorun%"
	
	Run, 安装字体\安装字体.ahk
	
	Run, 自动更新\自动更新.ahk
	
  gosub, 智能F1
  gosub, 智能Tab
  gosub, 智能编码
  gosub, 智能标点
	
  WinWaitClose, ahk_id %SciTE_Hwnd% ; 随 SciTE 退出。
  WinClose, ahk_pid %PID%           ; 退出时关闭帮助。
  ExitApp
return

#Include %A_LineFile%\..\智能操作\智能F1.ahk
#Include %A_LineFile%\..\智能操作\智能Tab.ahk
#Include %A_LineFile%\..\智能操作\智能编码.ahk
#Include %A_LineFile%\..\智能操作\智能标点.ahk