;
; SciTE4AutoHotkey Autorun Script
;

#NoEnv
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

oSciTE := GetSciTEInstance()
if !oSciTE
{
	MsgBox, 16, SciTE4AutoHotkey, Cannot find SciTE!
	ExitApp
}

UserAutorun := oSciTE.UserDir "\Autorun.ahk"

bUpdatesEnabled := oSciTE.ResolveProp("automatic.updates") + 0
bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0

;由于原版网站已经挂了，估计也不会再更新了，所以屏蔽升级检测，避免带来额外问题
;~ if bUpdatesEnabled
	;~ Run, "%A_AhkPath%" SciTEUpdate.ahk /silent

if bTillaGotoEnabled
	Run, "%A_AhkPath%" TillaGoto.ahk

IfExist, %UserAutorun%
	Run, "%A_AhkPath%" "%UserAutorun%"
