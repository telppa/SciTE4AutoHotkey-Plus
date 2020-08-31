;~ SciTE交互示例
;~ 因为是调用SciTE的com接口，所以显然运行本脚本需要“SciTE.exe”处于运行状态
;~ 同时，SciTE的内置变量“LocalAHK”必须指向32位版本的ahk，否则运行本脚本时报错（此问题已解决，在此说明仅作提示用）
;~ 最后，运行本脚本的ahk版本最好也是32位，否则“自动完成”功能无法正常演示
Run, SciTE.exe
MsgBox,  262208, , 等待2秒, 2		;等2秒以便com接口加载完成

oSciTE := ComObjActive("SciTE4AHK.Application")

;获取SciTE版本
MsgBox, 0, 获取SciTE版本, % oSciTE.Version

;获取SciTE句柄
MsgBox, 0, 获取SciTE句柄, % oSciTE.SciTEHandle

;获取SciTE用户目录
MsgBox, 0, 获取SciTE用户目录, % oSciTE.UserDir

;获取SciTE安装目录
MsgBox, 0, 获取SciTE安装目录, % oSciTE.SciTEDir

;获取当前platform
;就是“user\_platform.properties”文件的版本
MsgBox, 0, 获取当前platform, % oSciTE.ActivePlatform()

;设置当前platform
;就是工具栏上“运行”按钮左边的那个按钮的功能
;总共有4个版本可供设置——default、ansi、unicode、x64
;主要功能是控制使用何种版本的ahk对脚本进行“运行”“调试”“编译”3个操作
;需要注意的是，由于调试功能固定使用“LocalAHK”即32位unicode版本ahk执行，所以更改此设置实际只影响“运行”“编译”两个功能所使用ahk的版本
MsgBox, 0, 设置当前platform, % oSciTE.SetPlatform(platform)

;获取SciTE是否绿色版
MsgBox, 0, 获取SciTE是否绿色版, % oSciTE.IsPortable

;获取当前文件路径
MsgBox, 0, 获取当前文件路径, % oSciTE.CurrentFile

;获取当前文件内容
MsgBox, 0, 获取当前文件内容, % oSciTE.Document

;获取当前选中内容
MsgBox, 0, 获取当前选中内容, % oSciTE.Selection

;打开一个文件
oSciTE.OpenFile(filename)
MsgBox, 打开一个文件

;获取已打开文件列表
oTabs := oSciTE.Tabs
oTabs.Array
MsgBox, 0, 获取已打开文件列表, % oTabs.List
MsgBox, 0, 获取已打开文件数量, % oTabs.Count

;调试一个文件
oSciTE.DebugFile(filename)
MsgBox, 调试一个文件

;插入文本.省略第二参数pos,则使用光标所在位置
text:="这是一段插入到当前位置的文本"
oSciTE.InsertText(text)
MsgBox, 插入文本

;在输出框显示文本
OutputText:="output only support english"
oSciTE.Output(OutputText)
MsgBox, 在输出框显示文本

;切换标签
tabidx:=0		;标签编号从0开始
oSciTE.SwitchToTab(tabidx)
MsgBox, 切换标签

;获取Scintilla句柄，不是scite的
hSci:=获取Scintilla句柄()
MsgBox, 0, 获取Scintilla句柄，不是scite的, % hSci
获取Scintilla句柄()
{
	oSciTE := ComObjActive("SciTE4AHK.Application")
	hEditor:=oSciTE.SciTEHandle
	;Com得到的句柄是SciTE的，而需要的是Scintilla的
	;Get handle to focused control
	ControlGetFocus, cSci, ahk_id %hEditor%
	;Check if it fits the class name
	If InStr(cSci, "Scintilla")
	{
		ControlGet, hSci, Hwnd,, %cSci%, ahk_id %hEditor%
		Return, hSci
	}
	Else
		Return, 0
}

;此功能必须用32位ahk运行才能正常显示
;显示出一个自动完成框（需引用两个文件）
;单词用空格分隔，例如“abc bcd”会显示成“abc`r`nbcd”
MsgBox, 显示出一个自动完成框（此功能必须使用32位版本ahk运行本脚本才能正常）
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
;重载配置.可以理解为让修改后的配置生效
oSciTE.ReloadProps()

;看不懂
oSciTE.ResolveProp(propname)

;向SciTE发消息
oSciTE.Message(msg , wParam, lParam)

;用 Director interface 方式向SciTE发消息
oSciTE.SendDirectorMsg(message)

;同上,不过有两个返回值
oSciTE.SendDirectorMsgRet(message)

;同上,不过返回的是数组
oSciTE.SendDirectorMsgRetArray(message)
*/