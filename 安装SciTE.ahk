#NoEnv
SetWorkingDir, %A_ScriptDir%

; 管理员权限运行
RunWith("admin")

; 获取 “AutoHotkey.exe” 位置
SplitPath, A_AhkPath, , OutDir
if (OutDir="")
{
	Text=
	(LTrim
	没找到 AutoHotkey.exe 在哪，手动安装吧！

	把 SciTE 文件夹剪切到正确位置即可，路径中不要包含中文！

	例如你的 AHK 安装目录为 “C:\Program Files\Autohotkey”
	那么正确的 SciTE 目录就为 “C:\Program Files\Autohotkey\SciTE”
	
	“SciTE\user” 目录中如果存在自定义设置（例如自定义配色），请手动备份。
	)
	MsgBox 0x40010, 安装失败, % Text
	ExitApp
}

; 判断路径中是否含有中文
if (StrLen(RegExReplace(OutDir, "[[:ascii:]]"))!=0)
{
	Text=
	(LTrim
	%OutDir%

	AHK 的安装路径中似乎含有非英文字符（例如中文）。
	这将导致部分功能失效，例如 CallTip （单词完成）。
	)
	MsgBox 0x40030, 警告, % Text
}

; 获取旧版本号
FileRead, 旧版本号, %OutDir%\SciTE\$VER
if (旧版本号)
	; 兼容老版的版本号，需要去掉“.”，否则“+0”操作会出现空值。
	; 20211115 之后的版本，可以直接复制整个 user 文件夹。
	if (StrReplace(旧版本号, ".")+0>=20211115)
	{
		FileCopy, SciTE\user\Styles\SciTE4AutoHotkey-Plus.style.properties, %OutDir%\SciTE\user\Styles\SciTE4AutoHotkey-Plus.style.properties, 1
		FileCopyDir, %OutDir%\SciTE\user, SciTE\user, 1
	}
	else
	{
		; 复制旧版的4个文件过来
		FileCopy, %OutDir%\SciTE\user\_config.properties,          SciTE\user\备份_config.properties
		FileCopy, %OutDir%\SciTE\user\_platform.properties,        SciTE\user\_platform.properties
		FileCopy, %OutDir%\SciTE\user\SciTE.session,               SciTE\user\SciTE.session
		FileCopy, %OutDir%\SciTE\user\Styles\lpp.style.properties, SciTE\user\Styles\备份SciTE4AutoHotkey-Plus.style.properties

		; 从 _config.properties 中找到用户自定义 style 文件并复制过来
		FileRead, conf, %OutDir%\SciTE\user\_config.properties
		RegExMatch(conf, "im)^import (Styles\\.+\.style)$", userstyle)
		FileCopy, %OutDir%\SciTE\user\%userstyle1%.properties, SciTE\user\%userstyle1%.properties

		; 由于此次更新比较多，文件有删减，因此需要提前删除部分位置发生变化的文件，不然看起来很乱
		FileRecycle, %OutDir%\SciTE, 1
		FileRecycle, %OutDir%\额外的帮助文件, 1
		FileDelete,  %OutDir%\安装SciTE.ahk
		FileDelete,  %OutDir%\自定义ahk文件的右键菜单.ahk
		FileDelete,  %OutDir%\AutoHotkey_CN.chm
		FileDelete,  %OutDir%\chm_config.js
		FileDelete,  %OutDir%\1HourSoftware.chm
		FileDelete,  %OutDir%\AhkDll.chm
		FileDelete,  %OutDir%\AutoHotkey趣味代码之Rosetta Code.chm
		FileDelete,  %OutDir%\不要删除、移动、改名这4本帮助文件.txt
		FileDelete,  %OutDir%\一定要解压到ahk安装目录下.txt
	}

; 移动文件与目录过去
try
{
	FileMoveDir, SciTE, %OutDir%\SciTE, 2
}
catch
{
	Text=
	(LTrim
	移动文件与文件夹失败，手动安装吧！

	把 SciTE 文件夹剪切到正确位置即可，路径中不要包含中文！

	例如你的 AHK 安装目录为 “C:\Program Files\Autohotkey”
	那么正确的 SciTE 目录就为 “C:\Program Files\Autohotkey\SciTE”
	)
	MsgBox 0x40010, 安装失败, % Text
	ExitApp
}

; 创建桌面快捷方式
FileCreateShortcut, %OutDir%\SciTE\SciTE.exe, %A_Desktop%\SciTE4AutoHotkey-Plus.lnk, %OutDir%\SciTE\, , SciTE4AutoHotkey-Plus

; 静默运行脚本关联工具并设置关联
Run, "%OutDir%\SciTE\tools\AHK 脚本关联工具\AHK 脚本关联工具.ahk" /set

; 技巧的动画演示
Text=
(LTrim
安装成功并已在桌面创建了一个快捷方式。
如要卸载直接删目录就行了。

最后，是否观看动图演示的 SciTE 特性与技巧？（强烈建议观看）
)
MsgBox 0x40044, 信息, % Text
IfMsgBox, Yes
	Run, %OutDir%\SciTE\技巧\技巧说明.html

ExitApp

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