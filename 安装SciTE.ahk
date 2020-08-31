/*
如果你AHK的安装目录为 “C:\Program Files\Autohotkey”
那么正确的SciTE目录就为 “C:\Program Files\Autohotkey\SciTE”
这样设计的目的是位置放对后就可以随意更新AHK或SciTE，不影响对方。
路径中切勿包含中文，否则部分功能会失效，例如CallTip（单词完成）。

“AutoHotkey_CN.chm”是SciTE的F1功能会用到的中文帮助，不可删改，包括名字也不可！

额外的帮助文件：
“AhkDll.chm” “AutoHotkey_H v2.chm” 是Autohotkey_H版，也就是支持多线程版本的ahk的帮助。
根据我的踩坑经验，即使是v1版本的Autohotkey_H，大部分用法也得照着 “AutoHotkey_H v2.chm” 这本帮助来！
“1HourSoftware.chm” “AutoHotkey趣味代码之Rosetta Code.chm” 这两本帮助中有很多例子，可方便初学者学习！
*/
#NoEnv
SetWorkingDir, %A_ScriptDir%

;获取管理员权限
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
	try
	{
		if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
		else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}

;获取 “AutoHotkey.exe” 位置
SplitPath, A_AhkPath, , OutDir
if (OutDir="")
{
	MsgBox 0x40010, 安装失败, 没找到"AutoHotkey.exe"在哪，手动安装吧！`n`n如果你AHK的安装目录为 “C:\Program Files\Autohotkey”`n那么正确的SciTE目录就为 “C:\Program Files\Autohotkey\SciTE”`n`n反正就是把本文件所在位置的全部文件与文件夹都扔过去！
	ExitApp
}

;判断路径中是否含有中文
if (StrLen(RegExReplace(OutDir, "[[:ascii:]]"))!=0)
	MsgBox 0x40030, 警告, %OutDir%`n`nAHK的安装目录路径中似乎含有非英文字符（例如中文）。`n这将导致部分功能失效，例如CallTip（单词完成）。

;复制旧版的3个文件过来
FileCopy, %OutDir%\SciTE\user\_config.properties, SciTE\user\_config.properties
FileCopy, %OutDir%\SciTE\user\_platform.properties, SciTE\user\_platform.properties
FileCopy, %OutDir%\SciTE\user\SciTE.session, SciTE\user\SciTE.session

;由于此次更新比较多，文件有删减，因此需要提前删除部分位置发生变化的文件，不然看起来很乱
FileRemoveDir, %OutDir%\SciTE, 1
FileDelete, %OutDir%\1HourSoftware.chm
FileDelete, %OutDir%\AhkDll.chm
FileDelete, %OutDir%\AutoHotkey趣味代码之Rosetta Code.chm
FileDelete, %OutDir%\不要删除、移动、改名这4本帮助文件.txt
FileDelete, %OutDir%\一定要解压到ahk安装目录下.txt

;移动文件与目录过去
try
{
	FileMoveDir, SciTE, %OutDir%\SciTE, 2
	FileMoveDir, 额外的帮助文件, %OutDir%\额外的帮助文件, 2
	FileMove, AutoHotkey_CN.chm, %OutDir%\AutoHotkey_CN.chm, 1
	FileMove, 自定义ahk文件的右键菜单.ahk, %OutDir%\自定义ahk文件的右键菜单.ahk, 1
}
catch
{
	MsgBox 0x40010, 安装失败, 移动文件与文件夹失败，手动安装吧！`n`n如果你AHK的安装目录为 “C:\Program Files\Autohotkey”`n那么正确的SciTE目录就为 “C:\Program Files\Autohotkey\SciTE”`n`n反正就是把本文件所在位置的全部文件与文件夹都扔过去！
	ExitApp
}

;创建桌面快捷方式
FileCreateShortcut, %OutDir%\SciTE\SciTE.exe, %A_Desktop%\SciTE4AutoHotkey-Plus.lnk, %OutDir%\SciTE\, , SciTE4AutoHotkey增强版

;技巧的动画演示
MsgBox 0x40044, 信息, 安装成功并已在桌面创建了一个快捷方式。`n如要卸载直接删目录就行了。`n`n最后，是否观看动图演示的SciTE特性与技巧？（强烈建议观看）
IfMsgBox, Yes
	Run, %OutDir%\SciTE\技巧\技巧说明.html