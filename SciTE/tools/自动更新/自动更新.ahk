#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SetWorkingDir, %A_ScriptDir%

; 管理员权限运行
runwith("admin")

SciteDefaultHome = %A_ScriptDir%\..\..

是否检查更新:
	Now:=A_Now
	FileGetTime, FileTime, %SciteDefaultHome%\$VER, M
	EnvSub, Now, %FileTime%, Days
	; 超过1天没有检查更新，则进行检查。
	if (Now>=1)
	{
		FileSetTime, %A_Now%, %SciteDefaultHome%\$VER, M
		gosub, 检查更新
	}
	ExitApp
return

检查更新:
	网址:="https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/SciTE/%24VER"
	最新版本号:=WinHttp.Download(网址, "Timeout:30")
	; 网络不好或者被GFW导致无法获取更新。
	if (WinHttp.StatusCode!=200)
		return
	else
	{
		FileRead, 当前版本号, %SciteDefaultHome%\$VER
		; 兼容老版的版本号，需要去掉“.”，否则后面的“+0”操作会出现空值。
		当前版本号:=StrReplace(当前版本号, ".")
		if (最新版本号+0>当前版本号+0)
			gosub, 执行更新
	}
return

执行更新:
	网址:="https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/SciTE/tools/自动更新/update.ahk"
	路径:=A_ScriptDir "\update.ahk"
	WinHttp.Download(网址, "Timeout:60",,,路径)
	if (WinHttp.StatusCode!=200)
	{
		MsgBoxEx("自动更新失败，请尝试手动下载更新。", "错误", "前往主页", 4)
		Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
	}
	else
		Run, %路径%, %SciteDefaultHome%
return

#Include %A_ScriptDir%\..\AHK 正则终结者\Lib\RunWith.ahk
#Include %A_ScriptDir%\..\AHK 爬虫终结者\Lib\WinHttp.ahk
#Include %A_ScriptDir%\..\MagicBox\Functions\MsgBoxEx.ahk