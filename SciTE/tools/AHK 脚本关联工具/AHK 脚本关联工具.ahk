/*
作者：      甲壳虫<jdchenjian@gmail.com>
博客：      http://hi.baidu.com/jdchenjian
脚本说明：  此工具用来修改 AutoHotkey 脚本的右键菜单关联，适用于 AutoHotkey 安装版、绿色版。
脚本版本：  2023.10.30

TODO：
静默设置参数支持 ah2 和 ahk2 。
保留部分关联时，需要在管理员权限和普通权限下分别进行1次相同的操作才能让右键菜单显示正常。

修改作者：	兔子
2010.01.09	之前某个时间，修改AHK路径、编辑器路径、编译器路径，默认全部在当前目录下寻找
2010.01.09	去掉默认在新建菜单的勾
2010.06.21	如果SCITE为默认编辑器，则复制个人配置文件“SciTEUser.properties”到%USERPROFILE%
2010.06.25	修正因#NoEnv使%USERPROFILE%变量直接引用无效
2016.04.18	删除“2010.06.21”的改动
2021.10.17	新增“编译脚本 (GUI)”的汉化
2021.11.02	自动根据 AutoHotkey.exe 的位置定位基准目录。
2021.11.05	重构代码，精简界面，修复新建模板时的编码问题，修复编辑模板时的权限问题。
2022.04.21	为日志系统增加缓存，解决日志写入时的性能问题。微调显示。
2022.04.24	静默模式下，成功时不提示。微调显示。
2022.09.02	修复“自定义新建脚本的模板”失败的问题。
2023.10.20	静默模式下，出错时不提示，返回非0退出码。
2023.10.30	新增一个可能的编辑器路径用于自动定位。

修改作者：	布谷布谷
2022.04.15	增加.ah2 .ahk2 文件的关联，并增加脚本关联选项 
2022.04.16	增加右键脚本以管理员身份运行,添加注册表操作日志 
*/

#NoEnv
#SingleInstance Force
#Requires AutoHotkey v1.1.33+
SendMode Input
SetWorkingDir %A_ScriptDir%

; 版本(仅用于显示）
Script_Version=v1.2.6
administrator:=(A_IsAdmin?"已":"未" ) . "获得管理员权限"

Gui, Font, bold s15
Gui, Add, Text, x15 y10 w275 h20 vText__  ; 设置 .xxx 文件的右键菜单

Gui, Font
Gui, Add, Radio,  xp+280 yp- w50 hp vRadio_1  gOptions__ Checked1, ahk
Gui, Add, Radio,  xp+50  yp- wp  hp vRadio_2  gOptions__         , ahk2
Gui, Add, Radio,  xp+50  yp- wp  hp vRadio_3  gOptions__         , ah2
Gui, Add, Button, xp+50  yp- w50 hp vState__0 gState__           , 选项>>

Gui, Font, bold s12
Gui, Add, GroupBox, xp+60 yp   w205 h320 vState__1                   , 保留以下关联
Gui, Font
Gui, Add, Checkbox, xp+12 yp+30 w185 h30  vState__3 gState__ Checked1, 右键 >> 编译脚本
Gui, Add, Checkbox, xp+   yp+35 wp   hp   vState__4 gState__ Checked1, 右键 >> 编译脚本 (GUI)
Gui, Add, Checkbox, xp+   yp+35 wp   hp   vState__5 gState__ Checked1, 右键 >> 编辑脚本
Gui, Add, Checkbox, xp+   yp+35 wp   hp   vState__6 gState__ Checked1, 右键 >> 新建 >> ahk脚本
Gui, Add, Checkbox, xp+   yp+35 wp   hp   vState__7 gState__ Checked1, 右键 >> 以管理员身份运行
Gui, Add, Button,   xp-2  yp+70 wp   hp   vState__2 gState__         , 删除所有关联
Gui, Add, Button,   xp+   yp+35 wp   hp   vState__8 gRunAs__         , 重启并获得管理员权限

Gui, Add, GroupBox, x15    y44   w480 h50          , “运行脚本”
Gui, Add, Edit,     xp+10  yp+18 w340 h20 vAHK_Path,
Gui, Add, Button,   xp+350 yp-   w50  hp  gFind_AHK, 浏览

Gui, Add, GroupBox, x15    y104  w480 h50                  , “编译脚本”
Gui, Add, Edit,     xp+10  yp+18 w340 h20 vCompiler_Path   ,
Gui, Add, Button,   xp+350 yp-   w50  hp  gChoose_Compiler , 浏览
Gui, Add, Button,   xp+60  yp-   wp   hp  gDefault_Compiler, 默认

Gui, Add, GroupBox, x15    y164  w480 h50                , “编辑脚本”
Gui, Add, Edit,     xp+10  yp+18 w340 h20 vEditor_Path   ,
Gui, Add, Button,   xp+350 yp-   w50  hp  gChoose_Editor , 浏览
Gui, Add, Button,   xp+60  yp-   wp   hp  gDefault_Editor, 默认

Gui, Add, GroupBox, x15   y224  w480 h50               , “新建脚本”
Gui, Add, Button,   xp+10 yp+18 w340 h20 gEdit_Template, 自定义新建脚本的模板

Gui, Font, bold s15
Gui, Add, Button, x15  y290 w200 h40 gInstall Default, 设置
Gui, Add, Button, x295 yp-  wp   hp  gCancel         , 取消

Gui, Font
Gui, Font, , Arial,
Gui, Add, Edit, x15 yp+50 w695 h300 vlog HwndhLog, 注册表操作日志：`n

; 启动时隐藏高级界面
GuiControl, Hide, log
loop 8
	GuiControl, Hide, State__%A_Index%

gosub, Options__

if (A_Args.1 = "/set")
	gosub, Install
else
	Gui, Show, AutoSize Center, AHK 脚本关联工具 %Script_Version% ( %administrator% )
return

GuiClose:
GuiEscape:
Cancel:
	ExitApp
return

RunAs__:
	if !(A_IsAdmin||RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
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
return

State__:
	switch A_GuiControl
	{
		Case "State__0":
			State__0:=!State__0
			loop 7
				GuiControl, Show%State__0%, State__%A_Index%
			if !A_IsAdmin
				GuiControl, Show%State__0%, State__8
			GuiControl, Show%State__0%, log
			GuiControl, Text, State__0, % State__0?"<<选项":"选项>>"
			Gui, Show, AutoSize
		Case "State__2":
			logup("清除 ." ahk__ " 文件的注册表")
			RegDelete_(RootKey "\" Subkey "\" FileType)
			RegDelete_(RootKey "\" Subkey "." ahk__)
			logup("--------------------------------------------------------------")
			MsgBox, % 4096+64, , 操作完成 !
		Case "State__3","State__4","State__5","State__6","State__7":
			Gui, Submit, NoHide
	}
return

; 选择文件名类型
Options__:
	Gui, Submit, NoHide
	ahk__:=Radio_3?"ah2":Radio_2?"ahk2":"ahk"
	GuiControl, Text, Text__, 设置 .%ahk__% 文件的右键菜单
	GuiControl, Text, State__1, 保留 .%ahk__% 以下关联
	GuiControl, Text, State__2, 删除 .%ahk__% 所有关联
	
	; AutoHotkey 原版的相关信息写在注册表HKCR主键中，
	; 尝试当前用户否有权操作该键，如果无权操作HKCR键（受限用户），
	; 可通过操作注册表HKCU键来实现仅当前用户关联AHK脚本。
	logup("通过操作注册表测试当前用户否有权操作该键")
	if RegWrite_("REG_SZ","HKCR",".test")
		IsLimitedUser:=1
	if RegDelete_("HKCR", ".test")
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
	logup("--------------------------------------------------------------")
	
	logup("读取 ." ahk__ " 文件的注册表")
	FileType:=AHK_Path:=Compiler_Path:=Editor_Path:=Template_Name:=""
	; 检查是否存在AHK注册表项
	FileType:=RegRead_(RootKey "\" Subkey "." ahk__)
	if (FileType!="")
	{
		AHK_Path       := PathGetPath(RegRead_(RootKey "\" Subkey FileType "\Shell\Open\Command"))         ; AHK路径
		Compiler_Path  := PathGetPath(RegRead_(RootKey "\" Subkey FileType "\Shell\Compile\Command"))      ; 编译器路径
		Compiler_Path_ := PathGetPath(RegRead_(RootKey "\" Subkey FileType "\Shell\Compile-Gui\Command"))  ; 编译器路径
		Editor_Path    := PathGetPath(RegRead_(RootKey "\" Subkey FileType "\Shell\Edit\Command"))         ; 编辑器路径
		Template_Name  := RegRead_(RootKey "\" Subkey "." ahk__ "\ShellNew", "FileName")                   ; 模板文件名 
		(!Compiler_Path&&Compiler_Path:=Compiler_Path_)
	}
	else
		FileType:="AutoHotkeyScript" . (ahk__="ahk"?"":"." . ahk__)
	logup("--------------------------------------------------------------")
	
	; 通过 AutoHotkey.exe 的位置来定位基准目录
	SplitPath, A_AhkPath, , AhkDir
	; 没有从注册表获得路径则尝试从 AutoHotkey.exe 的位置开始寻找目标
	FilePattern:=AhkDir . (ahk__="ahk"?"":"\V2") . "\AutoHotkey.exe"
	(!AHK_Path&&FileExist(FilePattern)&&AHK_Path:=FilePattern)
	FilePattern:=AhkDir . "\Compiler\Ahk2Exe.exe"
	(!Compiler_Path&&FileExist(FilePattern)&&Compiler_Path:=FilePattern)
	FilePattern:=GetFullPathName(A_ScriptDir "\..\..\SciTE.exe")
	(!Editor_Path&&FileExist(FilePattern)&&Editor_Path:=FilePattern)
	FilePattern:=AhkDir . "\SciTE\SciTE.exe"
	(!Editor_Path&&FileExist(FilePattern)&&Editor_Path:=FilePattern)
	(!Template_Name&&Template_Name:="Template." . ahk__)
	
	GuiControl, , AHK_Path, %AHK_Path%
	GuiControl, , Compiler_Path, %Compiler_Path%
	GuiControl, , Editor_Path, %Editor_Path%
return

logup(value:="")
{
	global hLog, log
	static firstIn:=true, text:=""
	
	if (firstIn)
	{
		text := log
		firstIn := false
	}
	
	text .= A_YYYY "-" A_MM "-" A_DD "  " A_Hour ":" A_Min ":" A_Sec "." A_MSec " ：" value "`n"
	
	SetTimer, buffer, -200  ; 缓存间隔200毫秒内的日志，没有新日志后再一次性写入
	return
	
	buffer:
		GuiControl, , log, %text%
		PostMessage, 0x0115, 7, 0, , ahk_id %hLog%
	return
}

RegRead_(KeyName, ValueName:="")
{
	logup("读取：" KeyName " " ValueName)
	RegRead, OutputVar, %KeyName%, %ValueName%
	if (ErrorLevel_:=ErrorLevel)
		logup("失败：" (A_IsAdmin?"":"权限不够 或 ") "注册表不存在")
	else
		logup("数据：" OutputVar)
	return OutputVar
}
RegWrite_(ValueType, KeyName, ValueName:="", Value:="")
{
	logup("写入：" ValueType ", " KeyName ", " ValueName ", " Value)
	RegWrite, %ValueType%, %KeyName%, %ValueName%, %Value%
	if (ErrorLevel_:=ErrorLevel)
		logup("失败：" (A_IsAdmin?"未知错误":"权限不够"))
	else
		logup("成功")
	return ErrorLevel_
}
RegDelete_(KeyName, ValueName:="")
{
	logup("删除：" KeyName ", " ValueName)
	RegDelete, %KeyName%, %ValueName%
	if (ErrorLevel_:=ErrorLevel)
		logup("失败：" (A_IsAdmin?"":"权限不够 或") "注册表不存在")
	else
		logup("成功")
	return ErrorLevel_
}

; 查找 AutoHotkey 主程序
Find_AHK:
	Gui +OwnDialogs
	FileSelectFile, AHK_Path, 3, , 查找 AutoHotkey.exe, AutoHotkey.exe
	if (AHK_Path!="")
		GuiControl, ,AHK_Path, %AHK_Path%
	gosub Default_Compiler
return

; 选择脚本编译器
Choose_Compiler:
	Gui +OwnDialogs
	FileSelectFile, Compiler_Path, 3, , 选择脚本编译器, 程序(*.exe)
	if (Compiler_Path!="")
		GuiControl, ,Compiler_Path, %Compiler_Path%
return

; 默认脚本编译器
Default_Compiler:
	GuiControlGet, AHK_Path
	SplitPath, AHK_Path, , AHK_Dir
	IfExist, %AHK_Dir%\Compiler\Ahk2Exe.exe
	{
		Compiler_Path=%AHK_Dir%\Compiler\Ahk2Exe.exe
		GuiControl, , Compiler_Path, %Compiler_Path%
	}
return

; 选择脚本编辑器
Choose_Editor:
	Gui +OwnDialogs
	FileSelectFile, Editor_Path, 3, , 选择脚本编辑器, 程序(*.exe)
	if (Editor_Path!="")
		GuiControl, ,Editor_Path, %Editor_Path%
return

; 默认脚本编辑器
Default_Editor:
	IfExist, %A_ScriptDir%\..\..\SciTE.exe
		Editor_Path := GetFullPathName(A_ScriptDir "\..\..\SciTE.exe")
	else IfExist, %AhkDir%\SciTE\SciTE.exe
		Editor_Path=%AhkDir%\SciTE\SciTE.exe
	else IfExist, %A_WinDir%\system32\notepad.exe
		Editor_Path=%A_WinDir%\system32\notepad.exe
	GuiControl, , Editor_Path, %Editor_Path%
return

; 设置
Install:
	Gui, Submit, NoHide
	logup("写入注册表")
	IfNotExist, %AHK_Path%
	{
		if (A_Args.1 = "/set")
		{
			ExitApp 1
		}
		else
		{
			logup("AutoHotkey 路径错误 ！")
			MsgBox, % 4096+16, , AutoHotkey 路径错误 ！
			return
		}
	}
	RegWrite_("REG_SZ", RootKey "\" Subkey "." ahk__, , FileType)
	RegWrite_("REG_SZ", RootKey "\" Subkey "." ahk__ "\ShellNew", "FileName", Template_Name)
	RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell", , "Open")
	RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Open", , "运行脚本")
	; %AHK_Path%,1 这种图标设置方式没有成功，所以只能改为 Compiler_Path
	RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Open","Icon", """" Compiler_Path """")
	RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Open\Command", , """" AHK_Path """ ""%1"" %*")
	
	if State__3
	{
		IfNotExist, %Compiler_Path%
		{
			if (A_Args.1 = "/set")
			{
				ExitApp 3
			}
			else
			{
				logup("编译器路径错误 ！")
				MsgBox, % 4096+16, , 编译器路径错误 ！
				return
			}
		}
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile", , "编译脚本")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile","Icon", """" Compiler_Path """")
		IfInString, Compiler_Path, Ahk2Exe.exe
			RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile\Command", , """" Compiler_Path """ /in ""%1""")
		else
			RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile\Command", , """" Compiler_Path """ ""%1""")
	}
	else
		RegDelete_(RootKey "\" Subkey "\" FileType "\Shell\Compile")
	if State__4
	{
		IfNotExist, %Compiler_Path%
		{
			if (A_Args.1 = "/set")
			{
				ExitApp 4
			}
			else
			{
				logup("编译器路径错误 ！")
				MsgBox, % 4096+16, , 编译器路径错误 ！
				return
			}
		}
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile-Gui", , "编译脚本 (GUI)")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile-Gui","Icon", """" Compiler_Path """")
		IfInString, Compiler_Path, Ahk2Exe.exe
			RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile-Gui\Command", , """" Compiler_Path """ /gui /in ""%1""")
		else
			RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Compile-Gui\Command", , """" Compiler_Path """ /gui ""%1""")
	}
	else
		RegDelete_(RootKey "\" Subkey "\" FileType "\Shell\Compile-Gui")
	if State__5
	{
		IfNotExist, %Editor_Path%
		{
			if (A_Args.1 = "/set")
			{
				ExitApp 5
			}
			else
			{
				logup("编辑器路径错误 ！")
				MsgBox, % 4096+16, , 编辑器路径错误 ！
				return
			}
		}
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Edit", , "编辑脚本")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Edit","Icon", """" Editor_Path """")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\Edit\Command", , """" Editor_Path """ ""%1""")
	}
	else
		RegDelete_(RootKey "\" Subkey "\" FileType "\Shell\Edit")
	
	if State__6
	{
		FilePattern=%A_WinDir%\ShellNew\%Template_Name%
		IfNotExist, %FilePattern%
			gosub Create_Template
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType, , "AutoHotkey" (ahk__="ahk" ? "" : 2) " 脚本")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\DefaultIcon", , AHK_Path ",1")
	}
	else
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType)
	
	if State__7
	{
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\runas", "HasLUAShield")
		RegWrite_("REG_SZ", RootKey "\" Subkey FileType "\Shell\runas\Command", , """" AHK_Path """ ""%1"" %*")
	}
	else
		RegDelete_(RootKey "\" Subkey "\" FileType "\Shell\runas")
	
	logup("设置完毕 ！")
	logup("--------------------------------------------------------------")
	if (A_Args.1="/set")
		ExitApp
	MsgBox, % 4096+64, , 设置完毕 ！
return

; 编辑脚本模板
Edit_Template:
	GuiControlGet, Editor_Path
	IfNotExist, %Editor_Path%
	{
		MsgBox, % 4096+16, , 脚本编辑器路径错误 ！
		return
	}
	IfNotExist, %A_WinDir%\ShellNew\%Template_Name%
		gosub Create_Template

	IfExist, %A_WinDir%\system32\notepad.exe
		Run, *RunAs notepad.exe %A_WinDir%\ShellNew\%Template_Name%
	else
		Run, *RunAs %Editor_Path% %A_WinDir%\ShellNew\%Template_Name%
return

; 新建脚本模板
Create_Template:
	if (ahk__ = "ahk")
		txt:="#NoEnv`r`nSendMode Input`r`nSetWorkingDir %A_ScriptDir%`r`n"
	if (ahk__ = "ahk2" || ahk__ = "ah2")
		txt:="SendMode ""Input""`r`nSetWorkingDir A_ScriptDir`r`n"
	FileCreateDir %A_WinDir%\ShellNew
	FileAppend, %txt%, %A_WinDir%\ShellNew\%Template_Name%, UTF-8
	IfNotExist, %A_WinDir%\ShellNew\%Template_Name%
		if (A_Args.1 = "/set")
		{
			ExitApp 6
		}
		else
		{
			logup("无法创建脚本模板 ！")
			MsgBox, % 4096+16, , 无法创建脚本模板 ！`n`n请尝试使用管理员权限运行本工具。
			return
		}
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

; 获取绝对路径
GetFullPathName(path) {
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
    DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
    return buf
}