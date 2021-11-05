; SciTE 交互示例
; 因为是调用 SciTE 的 COM 接口，所以显然运行本脚本需要 “SciTE.exe” 处于运行状态
; 同时，SciTE 的内置变量 “LocalAHK” 必须指向32位版本的 AHK ，否则运行本脚本时报错（此问题已解决，在此说明仅作提示用）
; 最后，运行本脚本的 AHK 版本最好也是32位，否则 “自动完成” 功能无法正常演示
Run, SciTE.exe
MsgBox,  262208, , 等待2秒, 2		; 等2秒以便 COM 接口加载完成

oSciTE := ComObjActive("SciTE4AHK.Application")

; 获取 SciTE 版本
MsgBox, 0, 获取SciTE版本, % oSciTE.Version

; 获取 SciTE 句柄
MsgBox, 0, 获取SciTE句柄, % oSciTE.SciTEHandle

; 获取 SciTE 用户目录
MsgBox, 0, 获取SciTE用户目录, % oSciTE.UserDir

; 获取 SciTE 安装目录
MsgBox, 0, 获取SciTE安装目录, % oSciTE.SciTEDir

; 获取 platform
MsgBox, 0, 获取当前platform, % oSciTE.ActivePlatform()

; 设置 platform
; 就是工具栏上 “运行” 按钮左边的那个按钮的功能
; 总共有4个版本可供设置 —— Default ANSI Unicode x64
; 主要功能是控制使用何种版本的 AHK 对脚本进行 “运行” “调试” “编译” 3个操作
; 需要注意的是，由于调试功能固定使用 “LocalAHK” 即32位 Unicode 版本 AHK 执行
; 所以更改此设置实际只影响 “运行” “编译” 两个功能所使用 AHK 的版本
MsgBox, 0, 设置当前platform, % oSciTE.SetPlatform(platform)

; 获取 SciTE 是否绿色版
MsgBox, 0, 获取SciTE是否绿色版, % oSciTE.IsPortable

; 获取当前文件路径
MsgBox, 0, 获取当前文件路径, % oSciTE.CurrentFile

; 获取当前文件内容
MsgBox, 0, 获取当前文件内容, % oSciTE.Document

; 获取当前选中内容
MsgBox, 0, 获取当前选中内容, % oSciTE.Selection

; 打开一个文件
oSciTE.OpenFile(filename)
MsgBox, 打开一个文件

; 获取已打开文件列表
oTabs := oSciTE.Tabs
oTabs.Array
MsgBox, 0, 获取已打开文件列表, % oTabs.List
MsgBox, 0, 获取已打开文件数量, % oTabs.Count

; 调试一个文件
oSciTE.DebugFile(filename)
MsgBox, 调试一个文件

; 插入文本。省略第二参数 pos ，则使用光标所在位置
text:="这是一段插入到当前位置的文本"
oSciTE.InsertText(text)
MsgBox, 插入文本

; 在输出框显示文本
OutputText:="output only support english"
oSciTE.Output(OutputText)
MsgBox, 在输出框显示文本

; 切换标签
tabidx:=0		; 标签编号从0开始
oSciTE.SwitchToTab(tabidx)
MsgBox, 切换标签

; 获取 Scintilla 句柄，不是 SciTE 的
hSci:=获取Scintilla句柄()
MsgBox, 0, 获取Scintilla句柄，不是scite的, % hSci
获取Scintilla句柄()
{
	oSciTE := ComObjActive("SciTE4AHK.Application")
	hEditor:=oSciTE.SciTEHandle
	; COM 得到的句柄是 SciTE 的，而需要的是 Scintilla 的
	; Get handle to focused control
	ControlGetFocus, cSci, ahk_id %hEditor%
	; Check if it fits the class name
	If InStr(cSci, "Scintilla")
	{
		ControlGet, hSci, Hwnd,, %cSci%, ahk_id %hEditor%
		Return, hSci
	}
	Else
		Return, 0
}

; 此功能必须用32位 AHK 运行才能正常显示
; 显示出一个自动完成框（需引用两个文件）
; 单词用空格分隔，例如 “abc bcd” 会显示成 “abc`r`nbcd”
MsgBox, 显示出一个自动完成框（此功能必须使用32位版本 AHK 运行本脚本才能正常）
SciUtil_Autocompletion_Show(hSci, "word1 word2 单词1 单词2")
SciUtil_Autocompletion_Show(hSci, sText)
{
	; Prepare a local buffer for conversion
	sNewLen := StrPut(sText, "CP" (cp := SciUtil_GetCP(hSci)))
	VarSetCapacity(sTextCnv, sNewLen)

	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, sNewLen + 1)

	; Convert the text to the destination codepage
	StrPut(sText, &sTextCnv, "CP" cp)
	RemoteBuf_Write(hBuf, sTextCnv, sNewLen + 1)

	; Call Scintilla to insert the text. SCI_INSERTTEXT
	SendMessage, 2100, 0, RemoteBuf_Get(hBuf),, ahk_id %hSci%

	; Done
	RemoteBuf_Close(hBuf)
}
#Include toolbar\Lib\RemoteBuf.ahk
#Include toolbar\Lib\SciUtil.ahk

/*
; 重载配置，可以理解为让修改后的配置生效
oSciTE.ReloadProps()

; 取参数值，例如 oSciTE.ResolveProp("tillagoto.gui.width")
; 取参数值时可以解析引用，例如 oSciTE.ResolveProp("AutoHotkeyDir")
; AutoHotkeyDir=$(SciteDefaultHome)\..
oSciTE.ResolveProp(propname)

; 向 SciTE 发消息
oSciTE.Message(msg , wParam, lParam)

; 用 Director interface 方式向 SciTE 发消息
oSciTE.SendDirectorMsg(message)

; 同上，不过返回值是对象， verb 和 value
oSciTE.SendDirectorMsgRet(message)

; 同上，不过返回值是存了对象的数组
oSciTE.SendDirectorMsgRetArray(message)
*/