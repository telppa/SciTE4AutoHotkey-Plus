; SciTE 交互示例
; 因为是调用 SciTE 的 COM 接口，所以显然运行本脚本需要 “SciTE.exe” 处于运行状态
Run, ..\..\SciTE.exe
MsgBox,  262208, , 等待2秒, 2		; 等2秒以便 COM 接口加载完成

if (!oSciTE := GetSciTEInstance())
	ExitApp

; 获取 SciTE 版本
MsgBox, % "获取 SciTE 版本`n`n" oSciTE.Version

; 获取 SciTE 句柄
MsgBox, % "获取 SciTE 句柄`n`n" oSciTE.SciTEHandle

; 获取 SciTE 用户目录
MsgBox, % "获取 SciTE 用户目录`n`n" oSciTE.UserDir

; 获取 SciTE 安装目录
MsgBox, % "获取 SciTE 安装目录`n`n" oSciTE.SciTEDir

; 获取 platform
MsgBox, % "获取 platform`n`n" oSciTE.ActivePlatform

; 设置 platform
; 就是工具栏上 “运行” 按钮左边的那个按钮的功能
; 总共有4个版本可供设置 —— Default ANSI Unicode x64
; 主要功能是控制使用何种版本的 AHK 对脚本进行 “运行” “调试” “编译” 3个操作
; 需要注意的是，由于调试功能固定使用 “LocalAHK” 即32位 Unicode 版本 AHK 执行
; 所以更改此设置实际只影响 “运行” “编译” 两个功能所使用 AHK 的版本
MsgBox, % "设置当前 platform`n`n" oSciTE.SetPlatform(platform)

; 获取 SciTE 是否绿色版
MsgBox, % "获取 SciTE 是否绿色版`n`n" oSciTE.IsPortable

; 获取当前文件路径
MsgBox, % "获取当前文件路径`n`n" oSciTE.CurrentFile

; 获取当前文件内容
MsgBox, % "获取当前文件内容`n`n" oSciTE.Document

; 获取光标位置
MsgBox, % "获取光标位置`n`n" oSciTE.GetCurPos

; 设置光标位置
MsgBox, % "设置光标位置`n`n" oSciTE.SetCurPos(5)

; 获取光标处样式
MsgBox, % "获取光标处样式`n`n" oSciTE.GetStyle

; 获取指定位置样式
MsgBox, % "获取指定位置样式`n`n" oSciTE.GetStyle(0)

; 获取选中内容
MsgBox, % "获取选中内容`n`n" oSciTE.Selection

; 获取指定范围文本
MsgBox, % "获取指定范围文本`n`n" oSciTE.GetTextRange(2, 5)

; 获取光标处单词（只获取单词，括号等符号取不到）
MsgBox, % "获取光标处单词`n`n" oSciTE.GetWord

; 获取指定位置单词（只获取单词，括号等符号取不到）
MsgBox, % "获取指定位置单词`n`n" oSciTE.GetWord(10)

; 获取当前行
MsgBox, % "获取当前行`n`n" oSciTE.GetLine

; 获取指定行（首行是0，以此类推）
MsgBox, % "获取指定行`n`n" oSciTE.GetLine(0)

; 获取行首到光标处内容
MsgBox, % "获取行首到光标处内容`n`n" oSciTE.GetHome

; 获取光标处到行尾内容
MsgBox, % "获取光标处到行尾内容`n`n" oSciTE.GetEnd

; 删除光标处到行尾内容
MsgBox, % "删除光标处到行尾内容`n`n" oSciTE.DeleteEnd()

; 替换选中内容
MsgBox, % "替换选中内容`n`n" oSciTE.ReplaceSel("选中内容被替换了")

; 搜索文本
matchPos := oSciTE.FindText("SciTE")
MsgBox, % "搜索文本`n`n" matchPos[1] "|" matchPos[2]

; 用正则在指定范围搜索文本
matchPos := oSciTE.FindText("Sci\w+", 0, 100, 0x00200000)
MsgBox, % "用正则在指定范围搜索文本`n`n" matchPos[1] "|" matchPos[2]

; 打开一个文件
oSciTE.OpenFile(filename)
MsgBox, 打开一个文件

; 获取已打开文件列表
oTabs := oSciTE.Tabs
oTabs.Array
MsgBox, % "获取已打开文件列表`n`n" oTabs.List
MsgBox, % "获取已打开文件数量`n`n" oTabs.Count

; 调试一个文件
; filename 为空时，将调试本示例，导致重复启动，故注释。
; oSciTE.DebugFile(filename)
; MsgBox, 调试一个文件

; 光标处插入文本
text:="这是一段光标处插入文本"
oSciTE.InsertText(text)
MsgBox, 光标处插入文本

; 光标处插入文本并移动光标
text:="这是一段光标处插入文本并移动光标"
oSciTE.InsertText(text, "", true)
MsgBox, 光标处插入文本并移动光标

; 指定位置插入文本
text:="这是一段指定位置插入文本"
oSciTE.InsertText(text, 0)
MsgBox, 指定位置插入文本

; 在输出框显示文本
OutputText:="output only support english"
oSciTE.Output(OutputText)
MsgBox, 在输出框显示文本

; 切换标签（标签编号从0开始）
tabidx:=0
oSciTE.SwitchToTab(tabidx)
MsgBox, 切换标签

; 获取 Scintilla 句柄，不是 SciTE 的
hSci:=获取Scintilla句柄()
MsgBox, % "获取 Scintilla 句柄，不是 SciTE 的`n`n" hSci
获取Scintilla句柄()
{
	global oSciTE
	
	hEditor := oSciTE.SciTEHandle
	; COM 得到的句柄是 SciTE 的，而需要的是 Scintilla 的
	; Get handle to focused control
	ControlGetFocus, cSci, ahk_id %hEditor%
	; Check if it fits the class name
	if InStr(cSci, "Scintilla")
	{
		ControlGet, hSci, Hwnd,, %cSci%, ahk_id %hEditor%
		return, hSci
	}
	else
		return, 0
}

; 显示出一个自动完成框（需引用两个文件）
; 单词用空格分隔，例如 “abc bcd” 会显示成 “abc`r`nbcd”
MsgBox, 显示出一个自动完成框
SciUtil_Autocompletion_Show(hSci, "word1 word2 单词1 单词2")
SciUtil_Autocompletion_Show(hSci, text)
{
	; 文本转换编码
	len := StrPutVar(text, textConverted, "CP" SciUtil_GetCP(hSci))
	
	; 在 scite.exe 的内存中写入数据
	mem.open(hSci, len)
	mem.write(textConverted)
	
	SendMessage, 2100, 0, mem.baseAddress,, ahk_id %hSci%
	
	mem.close()
}

#Include ..\..\tools\Lib\GetSciTEInstance.ahk
#Include ..\..\toolbar\Lib\StrPutVar.ahk
#Include ..\..\toolbar\Lib\SciUtil.ahk

/*
; 重载配置，可以理解为让修改后的配置生效
oSciTE.ReloadProps()

; 取参数值，例如 oSciTE.ResolveProp("tillagoto.gui.width")
; 取参数值时可以解析引用，例如 oSciTE.ResolveProp("AutoHotkeyDir")
; AutoHotkeyDir=$(SciteDefaultHome)\..
oSciTE.ResolveProp(propname)

; 向 Scintilla 发消息
oSciTE.SciMsg(msg , wParam, lParam)

; 向 SciTE 发消息
oSciTE.Message(msg , wParam, lParam)

; 向 SciTE Director 接口发消息
; https://www.scintilla.org/SciTEDirector.html
; 使用宏进行光标左移操作
oSciTE.SendDirectorMsg("macrocommand:2304;0II;0;0")
oSciTE.SendDirectorMsg(message)

; 同上，不过返回值是对象， verb 和 value
oSciTE.SendDirectorMsgRet(message)

; 同上，不过返回值是存了对象的数组
oSciTE.SendDirectorMsgRetArray(message)
*/