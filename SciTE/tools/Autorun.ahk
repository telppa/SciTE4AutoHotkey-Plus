;
; SciTE4AutoHotkey Autorun Script
;

#NoEnv
#NoTrayIcon
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%

公用:
	; oSciTE 是超级全局变量
	global oSciTE
	; 屏蔽退出时的无用报错
	ComObjError(false)
	oSciTE := ComObjActive("SciTE4AHK.Application")
	SciTE_Hwnd := oSciTE.SciTEHandle
	
	if (!SciTE_Hwnd)
	{
		MsgBox 0x40030, SciTE4AutoHotkey-Plus, 辅助功能加载失败！`n`n请尝试退出 SciTE4AutoHotkey-Plus 并以普通权限重新运行。
		ExitApp
	}
	
	OnMessage(0x004A, "Receive_WM_COPYDATA")
	
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
  WinClose, ahk_pid %中文帮助PID%   ; 退出时关闭帮助。
  ExitApp
return

; 响应 scite 的事件并分发
Receive_WM_COPYDATA(wParam, lParam)
{
  StringAddress := NumGet(lParam + 2*A_PtrSize)
  CopyOfData := StrGet(StringAddress)
  event := StrSplit(CopyOfData, ":", , 2)
  
	switch event[1]
	{
		case "closed":更新fileTransformed(event[2])  ; 智能编码
	}
	
  return true
}

#Include %A_LineFile%\..\智能操作\智能F1.ahk
#Include %A_LineFile%\..\智能操作\智能Tab.ahk
#Include %A_LineFile%\..\智能操作\智能编码.ahk
#Include %A_LineFile%\..\智能操作\智能标点.ahk