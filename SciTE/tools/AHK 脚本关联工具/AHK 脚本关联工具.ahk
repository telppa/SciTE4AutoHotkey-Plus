/*
作者：      甲壳虫<jdchenjian@gmail.com>
博客：      http://hi.baidu.com/jdchenjian
脚本说明：  此工具用来修改 AutoHotkey 脚本的右键菜单关联，适用于 AutoHotkey 安装版、绿色版。
脚本版本：  2009-01-21

修改作者：	兔子
更新说明：
2010.01.09	之前某个时间，修改AHK路径、编辑器路径、编译器路径，默认全部在当前目录下寻找
2010.01.09	去掉默认在新建菜单的勾
2010.06.21	如果SCITE为默认编辑器，则复制个人配置文件“SciTEUser.properties”到%USERPROFILE%
2010.06.25	修正因#NoEnv使%USERPROFILE%变量直接引用无效
2016.04.18	删除“2010.06.21”的改动
2021.10.17	新增“编译脚本 (GUI)”的汉化
2021.11.02	自动根据 AutoHotkey.exe 的位置定位基准目录。
2021.11.05	重构代码，精简界面，修复新建模板时的编码问题，修复编辑模板时的权限问题。
*/

#NoEnv
#SingleInstance, force
SendMode Input
SetWorkingDir %A_ScriptDir%

; 版本(仅用于显示）
Script_Version=ver. 1.1

; AutoHotkey 原版的相关信息写在注册表HKCR主键中，
; 尝试当前用户否有权操作该键，如果无权操作HKCR键（受限用户），
; 可通过操作注册表HKCU键来实现仅当前用户关联AHK脚本。
RegWrite, REG_SZ, HKCR, .test
if ErrorLevel
	IsLimitedUser:=1
RegDelete, HKCR, .test
if ErrorLevel
	IsLimitedUser:=1

if IsLimitedUser
{
	RootKey=HKCU              ; 受限用户操作HKCU键
	Subkey=Software\Classes\  ; 为简化后面的脚本，此子键须以“\”结尾
}
else
{
	RootKey=HKCR              ; 非受限用户操作HKCR键
	Subkey=
}

; 检查是否存在AHK注册表项
RegRead, FileType, %RootKey%, %Subkey%.ahk
if (FileType!="")
{
	RegRead, value, %RootKey%, %Subkey%%FileType%\Shell\Open\Command     ; AHK路径
	AHK_Path:=PathGetPath(value)
	RegRead, value, %RootKey%, %Subkey%%FileType%\Shell\Compile\Command  ; 编译器路径
	Compiler_Path:=PathGetPath(value)
	RegRead, value, %RootKey%, %Subkey%%FileType%\Shell\Edit\Command     ; 编辑器路径
	Editor_Path:=PathGetPath(value)
	RegRead, Template_Name, %RootKey%, %Subkey%.ahk\ShellNew, FileName   ; 模板文件名
}
else
	FileType=AutoHotkeyScript

; 通过 AutoHotkey.exe 的位置来定位基准目录
SplitPath, A_AhkPath, , AhkDir

if AHK_Path=
{
	IfExist, %AhkDir%\AutoHotkey.exe
		AHK_path=%AhkDir%\AutoHotkey.exe
}

if Compiler_Path=
{
	IfExist, %AhkDir%\Compiler\Ahk2Exe.exe
		Compiler_Path=%AhkDir%\Compiler\Ahk2Exe.exe
}

if Editor_Path=
{
	IfExist, %AhkDir%\SciTE\SciTE.exe
		Editor_Path=%AhkDir%\SciTE\SciTE.exe
}

if Template_Name=
	Template_Name=Template.ahk

Gui, Font, bold s15
Gui, Add, Text, x10 y10 w480 h290, %A_Space%设置并汉化 .ahk 文件的右键菜单

Gui, Font
Gui, Add, GroupBox, x20 y50 w460 h50 , “运行脚本”
Gui, Add, Edit, x35 y70 w340 h20 vAHK_Path, %AHK_path%
Gui, Add, Button, x385 y70 w40 h20 gFind_AHK, 浏览

Gui, Add, GroupBox, x20 y110 w460 h50 , “编译脚本”
Gui, Add, Edit, x35 y130 w340 h20 vCompiler_Path, %Compiler_Path%
Gui, Add, Button, x385 y130 w40 h20 gChoose_Compiler, 浏览
Gui, Add, Button, x430 y130 w40 h20 gDefault_Compiler, 默认

Gui, Add, GroupBox, x20 y170 w460 h50 , “编辑脚本”
Gui, Add, Edit, x35 y190 w340 h20 vEditor_Path, %Editor_Path%
Gui, Add, Button, x385 y190 w40 h20 gChoose_Editor, 浏览
Gui, Add, Button, x430 y190 w40 h20 gDefault_Editor, 默认

Gui, Add, GroupBox, x20 y230 w460 h50 , “新建脚本”
Gui, Add, Button, x35 y250 w340 h20 gEdit_Template, 自定义新建脚本的模板

Gui, Font, bold s15
Gui, Add, Button, x20 y300 w200 h40 Default gInstall, 设置
Gui, Add, Button, x280 y300 w200 h40 gCancel, 取消

if (A_Args.1="/set")
	gosub, Install
else
	Gui, Show, x250 y200 h350 w500 Center, AHK 脚本关联工具 %Script_Version%
return

GuiClose:
GuiEscape:
Cancel:
	ExitApp
return

; 查找 AutoHotkey 主程序
Find_AHK:
	Gui +OwnDialogs
	FileSelectFile, AHK_Path, 3, , 查找 AutoHotkey.exe, AutoHotkey.exe
	if (AHK_Path!="")
		GuiControl,,AHK_Path, %AHK_Path%
	gosub Default_Compiler
return

; 选择脚本编译器
Choose_Compiler:
	Gui +OwnDialogs
	FileSelectFile, Compiler_Path, 3, , 选择脚本编译器, 程序(*.exe)
	if (Compiler_Path!="")
		GuiControl,,Compiler_Path, %Compiler_Path%
return

; 默认脚本编译器
Default_Compiler:
	GuiControlGet, AHK_Path
	SplitPath, AHK_Path, ,AHK_Dir
	IfExist, %AHK_Dir%\Compiler\Ahk2Exe.exe
	{
		Compiler_Path=%AHK_Dir%\Compiler\Ahk2Exe.exe
		GuiControl,, Compiler_Path, %Compiler_Path%
	}
return

; 选择脚本编辑器
Choose_Editor:
	Gui +OwnDialogs
	FileSelectFile, Editor_Path, 3, , 选择脚本编辑器, 程序(*.exe)
	if (Editor_Path!="")
		GuiControl,,Editor_Path, %Editor_Path%
return

; 默认脚本编辑器
Default_Editor:
	IfExist, %AhkDir%\SciTE\SciTE.exe
		Editor_Path=%AhkDir%\SciTE\SciTE.exe
	else ifExist, %A_WinDir%\system32\notepad.exe
			Editor_Path=%A_WinDir%\system32\notepad.exe
	GuiControl,, Editor_Path, %Editor_Path%
return

; 设置
Install:
	Gui, Submit

	IfNotExist, %AHK_Path%
	{
		MsgBox, 16, , AutoHotkey 路径错误 ！
		return
	}

	IfNotExist, %Compiler_Path%
	{
		MsgBox, 16, , 编译器路径错误 ！
		return
	}

	IfNotExist, %Editor_Path%
	{
		MsgBox, 16, , 编辑器路径错误 ！
		return
	}

	; 写入注册表
	RegWrite, REG_SZ, %RootKey%, %Subkey%.ahk,, %FileType%
	RegWrite, REG_SZ, %RootKey%, %Subkey%.ahk\ShellNew, FileName, %Template_Name%
	IfNotExist, %A_WinDir%\ShellNew\%Template_Name%
		gosub Create_Template

	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%,, AutoHotkey 脚本
	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\DefaultIcon,, %AHK_Path%`,1
	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell,, Open

	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Open,, 运行脚本
	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Open\Command,, "%AHK_Path%" "`%1" `%*

	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile,, 编译脚本
	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile-Gui,, 编译脚本 (GUI)
	IfInString, Compiler_Path, Ahk2Exe.exe
	{
		RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile\Command,, "%Compiler_Path%" /in "`%1"
		RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile-Gui\Command,, "%Compiler_Path%" /gui /in "`%1"
	}
	else
	{
		RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile\Command,, "%Compiler_Path%" "`%1"
		RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Compile-Gui\Command,, "%Compiler_Path%" /gui "`%1"
	}

	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Edit,, 编辑脚本
	RegWrite, REG_SZ, %RootKey%, %Subkey%%FileType%\Shell\Edit\Command,, "%Editor_Path%" "`%1"

	MsgBox, 64, , 设置完毕 ！
	ExitApp
return

; 编辑脚本模板
Edit_Template:
	GuiControlGet, Editor_Path
	IfNotExist, %Editor_Path%
	{
		MsgBox, 64, , 脚本编辑器路径错误 ！
		return
	}
	IfNotExist, %A_WinDir%\ShellNew\%Template_Name%
		gosub Create_Template

	ifExist, %A_WinDir%\system32\notepad.exe
		Run, *RunAs notepad.exe %A_WinDir%\ShellNew\%Template_Name%
	else
		Run, *RunAs %Editor_Path% %A_WinDir%\ShellNew\%Template_Name%
return

; 新建脚本模板
Create_Template:
	FileAppend,
	(
#NoEnv
SendMode Input
SetWorkingDir `%A_ScriptDir`%

	), %A_WinDir%\ShellNew\%Template_Name%, UTF-8

	IfNotExist, %A_WinDir%\ShellNew\%Template_Name%
		MsgBox, 64, , 无法创建脚本模板 ！`n`n请尝试使用管理员权限运行本工具。
return

; 从注册表值字符串中提取路径
PathGetPath(pSourceCmd)
{
	local Path, ArgsStartPos = 0
	if (SubStr(pSourceCmd, 1, 1) = """")
		Path := SubStr(pSourceCmd, 2, InStr(pSourceCmd, """", False, 2) - 2)
	else
	{
		ArgsStartPos := InStr(pSourceCmd, " ")
		if ArgsStartPos
			Path := SubStr(pSourceCmd, 1, ArgsStartPos - 1)
		else
			Path = %pSourceCmd%
	}
	return Path
}