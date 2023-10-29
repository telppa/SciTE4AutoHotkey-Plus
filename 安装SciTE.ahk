#NoEnv
#Requires AutoHotkey v1.1.33+
SetWorkingDir, %A_ScriptDir%

; 管理员权限运行
RunWith("Admin")

; 获取 “AutoHotkey.exe” 位置
SplitPath, A_AhkPath, , OutDir

; 获取 “AutoHotkey.exe” 位置失败 
if (OutDir="")
{
	Text=
	(LTrim
	没找到 AutoHotkey.exe 在哪，请手动把 SciTE 文件夹剪切到正确位置。

	例如你的 AHK 安装路径为 “D:\Apps\Autohotkey”
	那么正确的 SciTE 位置就为 “D:\Apps\Autohotkey\SciTE”

	注意：
	1.路径中不要包含中文 或 “Program Files” 或 “Program Files (x86)”
	2.请手动备份旧版 “SciTE\user” 目录下的自定义设置（例如自定义配色）。
	)
	MsgBox 0x40010, 安装失败, % Text
	ExitApp
}

; 判断路径中是否含有 “Program Files” 或 “Program Files (x86)”
if (InStr(OutDir, "Program Files"))
{
	Text=
	(LTrim
	%OutDir%

	AHK 的安装路径中含有 “Program Files” 或 “Program Files (x86)”
	这代表 AHK 被安装在系统保护目录中，此目录普通程序无写入权限。

	请重新安装 AHK 到其它位置后再运行本安装程序。
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

	AHK 的安装路径中含有非英文字符（例如中文）。
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
	移动文件与文件夹失败，请手动把 SciTE 文件夹剪切到正确位置。

	例如你的 AHK 安装路径为 “D:\Apps\Autohotkey”
	那么正确的 SciTE 位置就为 “D:\Apps\Autohotkey\SciTE”

	注意：
	1.路径中不要包含中文 或 “Program Files” 或 “Program Files (x86)”
	)
	MsgBox 0x40010, 安装失败, % Text
	ExitApp
}

; 创建桌面快捷方式
FileCreateShortcut, %OutDir%\SciTE\SciTE.exe, %A_Desktop%\SciTE4AutoHotkey-Plus.lnk, %OutDir%\SciTE\, , SciTE4AutoHotkey-Plus

; 静默运行脚本关联工具并设置关联
RunWait "%OutDir%\SciTE\tools\AHK 脚本关联工具\AHK 脚本关联工具.ahk" /set
; 静默关联失败则手动运行让用户自行设置
if (ErrorLevel)
	Run "%OutDir%\SciTE\tools\AHK 脚本关联工具\AHK 脚本关联工具.ahk"

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

#Include SciTE\tools\AHK 正则终结者\Lib\RunWith.ahk