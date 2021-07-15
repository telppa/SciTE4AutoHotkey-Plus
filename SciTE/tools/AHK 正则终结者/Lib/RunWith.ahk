; 强制自身进程以 管理员权限 或 普通权限 或 ANSI 或 U32 或 U64 版本运行。
; 例1: runwith("admin","u32") 强制自身以 u32 + 管理员权限 运行。
; 例2: runwith("","ansi")     强制自身以 ansi 版本运行（权限不变）。
; 例3: runwith("normal")      强制自身以 普通权限 运行（版本不变）。
RunWith(RunAsAdmin:="Default", ANSI_U32_U64:="Default")
{
	; 格式化预期的模式
	switch, RunAsAdmin
	{
		case "Normal","Standard","No","0":		RunAsAdmin:=0
		case "Admin","Yes","1":								RunAsAdmin:=1
		case "Default":												RunAsAdmin:=A_IsAdmin
		default:															RunAsAdmin:=A_IsAdmin
	}
	switch, ANSI_U32_U64
	{
		case "A32","ANSI","A":								ANSI_U32_U64:="AutoHotkeyA32.exe"
		case "U32","X32","32":								ANSI_U32_U64:="AutoHotkeyU32.exe"
		case "U64","X64","64":								ANSI_U32_U64:="AutoHotkeyU64.exe"
		case "Default":												ANSI_U32_U64:="AutoHotkey.exe"
		default:															ANSI_U32_U64:="AutoHotkey.exe"
	}
	; 获取传递给 “.ahk” 的用户参数（不是 /restart 之类传递给 “.exe” 的开关参数）
	for k, v in A_Args
	{
		if (RunAsAdmin=1)
		{
			; 转义所有的引号与转义符号
			v:=StrReplace(v, "\", "\\")
			v:=StrReplace(v, """", "\""")
			; 无论参数中是否有空格，都给参数两边加上引号
			; Run       的内引号是 "
			ScriptParameters  .= (ScriptParameters="") ? """" v """" : A_Space """" v """"
		}
		else
		{
			; 转义所有的引号与转义符号
			; 注意要转义两次 Run 和 RunAs.exe
			v:=StrReplace(v, "\", "\\")
			v:=StrReplace(v, """", "\""")
			v:=StrReplace(v, "\", "\\")
			v:=StrReplace(v, """", "\""")
			; 无论参数中是否有空格，都给参数两边加上引号
			; RunAs.exe 的内引号是 \"
			ScriptParameters .= (ScriptParameters="") ? "\""" v "\""" : A_Space "\""" v "\"""
		}
	}

	; 判断当前 exe 是什么版本
	if (!A_IsUnicode)
		RunningEXE:="AutoHotkeyA32.exe"
	else if (A_PtrSize=4)
		RunningEXE:="AutoHotkeyU32.exe"
	else if (A_PtrSize=8)
		RunningEXE:="AutoHotkeyU64.exe"

	; 运行模式与预期相同，则直接返回。 ANSI_U32_U64="AutoHotkey.exe" 代表不对 ahk 版本做要求。
	if (A_IsAdmin=RunAsAdmin and (ANSI_U32_U64="AutoHotkey.exe" or ANSI_U32_U64=RunningEXE))
		return
	; 如果当前已经是使用 /restart 参数重启的进程，则报错避免反复重启导致死循环。
	else if (RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
	{
		预期权限:=(RunAsAdmin=1) ? "管理员权限" : "普通权限"
		当前权限:=(A_IsAdmin=1)  ? "管理员权限" : "普通权限"
		ErrorMessage=
		(LTrim
		预期使用: %ANSI_U32_U64%
		当前使用: %RunningEXE%

		预期权限: %预期权限%
		当前权限: %当前权限%

		程序即将退出。
		)
		MsgBox 0x40030, 运行状态与预期不一致, %ErrorMessage%
		ExitApp
	}
	else
	{
		; 获取 AutoHotkey.exe 的路径
		SplitPath, A_AhkPath, , Dir
		if (RunAsAdmin=0)
		{
			; 强制普通权限运行
			switch, A_IsCompiled
			{
				; %A_ScriptFullPath% 必须加引号，否则含空格的路径会被截断。%ScriptParameters% 必须不加引号，因为构造时已经加了。
				; 工作目录不用单独指定，默认使用 A_WorkingDir 。
				case, "1": Run, RunAs.exe /trustlevel:0x20000 "\"%A_ScriptFullPath%\" /restart %ScriptParameters%",, Hide
				default: Run, RunAs.exe /trustlevel:0x20000 "\"%Dir%\%ANSI_U32_U64%\" /restart \"%A_ScriptFullPath%\" %ScriptParameters%",, Hide
			}
		}
		else
		{
			; 强制管理员权限运行
			switch, A_IsCompiled
			{
				; %A_ScriptFullPath% 必须加引号，否则含空格的路径会被截断。%ScriptParameters% 必须不加引号，因为构造时已经加了。
				; 工作目录不用单独指定，默认使用 A_WorkingDir 。
				case, "1": Run, *RunAs "%A_ScriptFullPath%" /restart %ScriptParameters%
				default: Run, *RunAs "%Dir%\%ANSI_U32_U64%" /restart "%A_ScriptFullPath%" %ScriptParameters%
			}
		}
		ExitApp
	}
}