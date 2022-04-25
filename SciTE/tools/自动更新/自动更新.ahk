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
	网址:="https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/README.md"
	返回值:=WinHttp.Download(网址, 设置, 请求头, 提交数据)
	
	; 从 README.md 中提取当前更新信息
	if (返回值!="")
	{
		更新日志:=strMatch(返回值, "- 更新日志：", "<details>")
		
		RegExMatch(更新日志, "m)^> ([\d\.]{10})", 版本号)
		版本号:= "v" StrReplace(版本号1, ".")                             ; 2022.04.25 -> v20220425
		
		更新日志:=RegExReplace(更新日志, "m)^[ \t]*$\r\n", "")            ; 移除空行
		更新日志:=RegExReplace(更新日志, "m)^> ([\d\.]{10})", "$1`r`n")   ; 移除 “> ”
		更新日志:=RegExReplace(更新日志, "m)^> \* ", "    ")              ; 移除 “> * ”
		
		link_github:=Trim(strMatch(t, "[Github](", """"), " `t`r`n`v`f")  ; github 链接
		link_lanzou:=Trim(strMatch(t, "[蓝奏云](", """"), " `t`r`n`v`f")  ; lanzou 链接
		
		if (更新日志="" or 版本号="" or link_github="" or link_lanzou="")
				gosub, GFW
		
		Result := MsgBoxEx(更新日志, 版本号 "版已更新", "蓝奏云下载|Github 下载|主页", 0, "", "AlwaysOnTop")
		
		If (Result == "蓝奏云下载") {
			Run, %link_lanzou%
		} Else If (Result == "Github 下载") {
			Run, %link_github%
		} Else If (Result == "主页") {
			Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
		} Else If (Result == "Cancel") {
			ExitApp
		}
	}
	else
		gosub, GFW
return

GFW:
	说明 := "因为 GFW 的屏蔽，无法收到详细更新日志。`n请尝试点击下方按钮进行手动下载。"
	
	Result := MsgBoxEx(说明, "检测到新版 SciTE4AutoHotkey-Plus", "Github 下载|主页", 0, "", "AlwaysOnTop")
	
	If (Result == "Github 下载") {
		Run, %link_github%
	} Else If (Result == "主页") {
		Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
	} Else If (Result == "Cancel") {
		ExitApp
	}
return

; 例如 strMatch("<em>123</em>", "<e", "m>") 将返回 “m>123</e”
; 例如 strMatch("<em>123</em><em>456</em>", "<e", "m>", 2) 将返回 “m>456</e”
strMatch(text, strStart, strEnd, occurrence := 1, caseSensitive := false)
{
	if (text="" or strStart="" or strEnd="")
		return
	
	posStart := InStr(text, strStart, caseSensitive, 1, occurrence)
	if (posStart=0)
		return
	
	posEnd := InStr(text, strEnd, caseSensitive, posStart+StrLen(strstart))
	if (posEnd=0)
		return
	
	return, SubStr(text, posStart, posEnd-posStart)
}

#Include %A_ScriptDir%\..\AHK 正则终结者\Lib\RunWith.ahk
#Include %A_ScriptDir%\..\AHK 爬虫终结者\Lib\WinHttp.ahk
#Include %A_ScriptDir%\..\MagicBox\Functions\MsgBoxEx.ahk