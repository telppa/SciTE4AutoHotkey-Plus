#SingleInstance Force
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

是否检查更新:
	Now:=A_Now
	FileGetTime, FileTime, %A_ScriptDir%\..\$VER, M
	EnvSub, Now, %FileTime%, Days
	if (Now>=1)		;超过1天没有检查更新，则进行检查。
	{
		FileSetTime, %A_Now%, %A_ScriptDir%\..\$VER, M
		gosub, 检查更新
	}
	else
		ExitApp
return

检查更新:
	网址:="https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/SciTE/%24VER"
	最新版本号:=WinHttp.Download(网址, 设置, 请求头)
	if (WinHttp.StatusCode!=200)		;网络不好或者被GFW导致无法获取更新。
		ExitApp
	else
	{
		FileRead, 当前版本号, %A_ScriptDir%\..\$VER
		当前版本号:=StrReplace(当前版本号, ".")		;兼容老版的版本号，需要去掉“.”，否则后面的“+0”操作会出现空值。
		if (最新版本号+0>当前版本号+0)
			gosub, 执行更新
	}
return

执行更新:
	网址:="https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/SciTE/update.ahk"
	路径:=A_ScriptDir "\..\update.ahk"
	WinHttp.Download(网址,,,,路径)
	if (WinHttp.StatusCode!=200)
	{
		MsgBoxEx("自动更新失败，请尝试手动下载更新。", "错误", "前往主页", 4)
		Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
	}
	else
	{
		工作目录:=A_ScriptDir "\.."
		Run, %路径%, %工作目录%
	}
return

#Include %A_ScriptDir%\..\tools\AHK 爬虫终结者\WinHttp.ahk
#Include %A_ScriptDir%\..\tools\AHK 爬虫终结者\正则全局模式.ahk
#Include %A_ScriptDir%\..\tools\AutoGUI\Tools\MagicBox\Functions\MsgBoxEx.ahk