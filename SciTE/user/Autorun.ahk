; SciTE4AutoHotkey v3 user autorun script
;
; You are encouraged to edit this script!
;

#NoEnv
#NoTrayIcon
#SingleInstance Force

公用:
  SetWorkingDir, %A_ScriptDir%
  oSciTE := ComObjActive("SciTE4AHK.Application")
  SciTE_Hwnd := oSciTE.SciTEHandle

  gosub, 智能F1
  gosub, 智能Tab
  gosub, 智能标点

  WinWaitClose, ahk_id %SciTE_Hwnd% ; 随 SciTE 退出。
  WinClose, ahk_pid %PID%           ; 退出时关闭帮助。
  ExitApp
return

#Include %A_LineFile%\..\智能F1.ahk
#Include %A_LineFile%\..\智能Tab.ahk
#Include %A_LineFile%\..\智能标点.ahk