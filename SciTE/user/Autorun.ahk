; SciTE4AutoHotkey v3 user autorun script
;
; You are encouraged to edit this script!
;

#NoEnv
#NoTrayIcon

公用:
	SetWorkingDir, %A_ScriptDir%
	oSciTE := ComObjActive("SciTE4AHK.Application")
	SciTE_Hwnd := oSciTE.SciTEHandle

	gosub, 中文帮助友好提示
	gosub, 智能Tab
	gosub, 智能标点

	;随SciTE退出
	WinWaitClose, ahk_id %SciTE_Hwnd%
	WinClose, ahk_class HH Parent ahk_exe keyhh.exe
	ExitApp
return

;在帮助文件不存在，按F1没反应的情况下，友好的提示使用者该怎么做。
中文帮助友好提示:
	;由于修改了按“F1”时调用帮助文件的名称，所以在这里做一个友好提示，让按F1没反应的人知道是怎么回事。
	;之所以不直接使用“#If (FileExist(abc))”，是因为那样会报错。
	keyhh路径:=oSciTE.SciTEDir . "\tools\keyhh.exe"
	中文帮助路径:=oSciTE.SciTEDir . "\..\AutoHotkey_CN.chm"
	keyhh是否存在:=FileExist(keyhh路径)
	中文帮助是否存在:=FileExist(中文帮助路径)
return

;2020.7.24“智能F1”全面接管F1功能，故需要屏蔽“SciTEUser.properties”“platforms.properties”文件中的自带F1功能
;限制“智能F1”的作用范围只在scite中
#If WinActive("ahk_id " . SciTE_Hwnd)
F1::
	;中文帮助不存在，则产生一个友好的提示
	if (!中文帮助是否存在)
		MsgBox, 262160, 没有找到中文帮助文件因此F1功能失效, 请自行于GitHub或QQ群下载一份帮助文件`n并命名为“AutoHotkey_CN.chm”`n存放于“AutoHotkey.exe”同目录下。
	else if (!keyhh是否存在)
		MsgBox, 262160, 没有找到 keyhh.exe 因此F1功能失效, 请自行下载 keyhh.exe `n存放于“SciTE.exe\tools”目录下。
	else
	{
		Send, ^{Left}^+{Right}
		Sleep, 50			;延时是必须的，否则偶尔会取不到词
		光标下单词:=" " Trim(oSciTE.Selection(), " `t`r`n`v`f")			;把两侧的空白符去掉，不然“else”无法被正确激活。故意在单词前添加一个空格，这样输入索引的时候会加速不少
		;~ IfWinNotExist, ahk_class HH Parent ahk_exe keyhh.exe			;要想提高稳定性，就只能每次都用 keyhh 打开帮助
			Run, % keyhh路径 " -ahkhelp " 中文帮助路径			;keyhh 可以通过参数 -#klink "IsCompiled" 传递字符到索引中（需要老式索引界面）
		WinWait, ahk_class HH Parent ahk_exe keyhh.exe			;这行不能少，否则很容易无法激活帮助文件
		WinActivate, ahk_class HH Parent ahk_exe keyhh.exe
		WinWaitActive, ahk_class HH Parent ahk_exe keyhh.exe
		SendInput, !n^a{BackSpace}			;清空索引栏单词
		SendInput, {Ctrl Up}{Shift Up}{Alt Up}			;强制释放修饰键，避免出bug
		SendInput, {Blind}{Text}%光标下单词%			;原义的发送获取到的单词，否则“#if”之类的会被错误解析。text 模式与 raw 模式的区别是，text 可以忽略输入法状态
		SendInput, {Home}{Del}{End}{Enter}{Enter}			;因为单词前被故意加了一个空格，用来加速输入，因此完成输入后需要删除那个多余的空格
	}
return
#If

;单词自动完成时使用TAB键，可自动补全命令、函数等，并设好参数。此时若继续按TAB则可以在参数间跳跃，高效连贯的完成输入。
;BUG：
;	逗号左边不能是转义符或者引号。
;	有时会莫名打开文件夹。
;	参数中含有特殊字符（例如英文引号，“\”“/”等等）时无法被自动选中。
;	无缩略语时也会启动智能tab（例如单词password）。
智能Tab:
	标记 := 0
return

;自动完成状态下,使用Tab将展开缩略语,并选中第一个参数
#If (标记=0) and WinExist("ahk_class ListBoxX") and WinActive("ahk_id " . SciTE_Hwnd)
~$Tab::
	;SendInput 发送快捷键是不一定生效的，所以全部使用 Send 代替。
	Send, ^b											;展开缩略语
	Send, ^+{Right}											;在缩略语文件中已经设置过光标位置为单词前,所以这里直接选择下一单词就是了
	;理论上在这个位置判断一下选中内容是否为空就可以修正bug“无缩略语时也会启动智能tab（例如单词password）”，然而却遭遇了获取选中内容时而有效时而失效的问题……
	;添加这个延时可解决“获取选中内容时而有效时而失效的问题”。
	Sleep, 50
	;2020.09.14 必须用instr，因为比如第25-30行都是空行，那么在第25行开始“Send, ^+{Right}”，选中的内容就会包含多个换行符。
	if (InStr(oSciTE.Selection,"`n"))
	{
		Send, {Left}
		return
	}
	if (oSciTE.Selection="")
		return
	标记 := 1
	ToolTip, 智能Tab 已启用
return

;使用Tab在参数间跳跃
;智能Tab启用期间，tab键只起“在参数间跳跃”这一个作用
#If  (标记=1) and !WinExist("ahk_class SoPY_Comp") and WinActive("ahk_id " . SciTE_Hwnd)
$Tab::
	if (oSciTE.Selection<>"")									;当前已有选中文字,则发送右箭头取消选择状态
		Send, {Right}
	Loop,25
	{
		Send, ^+{Right}										;选中右面单词
		选中文本 := oSciTE.Selection								;获取被选中的内容
		if (选中文本="")									;最后一行
		{
			Send, {Right}
			Send, {Enter}
			标记 := 0
			ToolTip,
			return
		}
		else if (SubStr(选中文本, 1, 2)="`r`n" or SubStr(选中文本, -1, 2)="`r`n")		;行末
		{
			Send, ^{Left}
			Send, {Enter}
			标记 := 0
			ToolTip,
			return
		}
		else if (SubStr(选中文本, 0, 1)=")")							;带闭括号的行末
		{
			Send, {Right}
			continue
		}
		else if (SubStr(RTrim(选中文本, " `t`r`n`v`f"), 0, 1)=",")				;逗号后面的参数
		{
			Send, {Right}
			Send, ^+{Right}
			return
		}
		else if (Trim(选中文本, " `t`r`n`v`f")="in")				;专为 for 设置
		{
			Send, {Left}
			Send, {Space}
			Send, ^{Right}
			Send, ^+{Right}
			return
		}
	}
	标记 := 0
	ToolTip,
return

;仅在“自动完成框”与“搜狗输入法框”不存在时，回车键作用为“关闭智能tab”
;“自动完成框”存在时，回车键作用为上屏自动完成单词
;“搜狗输入法框”存在时，回车键作用为上屏输入的英文。换个理解，在搜狗输入法框存在时，回车键总是起上屏英文的作用
#If  (标记=1) and !WinExist("ahk_class ListBoxX") and !WinExist("ahk_class SoPY_Comp") and WinActive("ahk_id " . SciTE_Hwnd)
$NumpadEnter::
$Enter::
	if (oSciTE.Selection<>"")									;当前已有选中文字,则发送右箭头取消选择状态
		Send, {Right}
	;alt+end 和 alt+shift+end都是选中到行末，区别是后者在遇到自动换行时不会选中到真正的行末
	Send, +{End}											;选中文字到行末
	if (SubStr(RTrim(oSciTE.Selection, " `t`r`n`v`f"), 0, 1)=")")					;检查行最后一个非空白字符是否是闭括号,是则补一个闭括号
		Send, {Asc 41}			;使用“{Asc 41}”而非“)”，是因为前者在输入法为中文标点的情况下，依然可以发出英文符号。
	Send, {Enter}
	标记 := 0
	ToolTip,
return
#If

;在代码区，标点总是英文
;在注释区，标点由输入法控制
;这里有个小bug，就是在行注释的行首处，中文输入法状态下，输入一个英文字，比如“f”，然后用“shift”键让英文上屏
;这时获取到的高亮状态是不正确的
;不过由于随便再动一下光标就又能获取到正确高亮状态了，所以这个bug几乎没任何影响
智能标点:
	ime:=new 智能标点()
	SetTimer, 获取当前位置语法高亮风格, 50
return

获取当前位置语法高亮风格:
	;光标位置发生变化的时候获取一次当前位置的高亮风格
	if (A_CaretX<>x or A_CaretY<>y)
	{
		x:=A_CaretX,y:=A_CaretY
		style:=ime.获取当前位置语法高亮风格()
	}
return

#If Style="代码" and WinActive("ahk_id " . SciTE_Hwnd)
	;按键本身就是符号
	$`::发送原义字符("``")
	$[::发送原义字符("[")
	$]::发送原义字符("]")
	$;::发送原义字符(";")
	$'::发送原义字符("'")
	$\::发送原义字符("\")
	$,::发送原义字符(",")
	$.::发送原义字符(".")
	$/::发送原义字符("/")
	;shift与按键组合的符号
	$+1::发送原义字符("!")
	$+4::发送原义字符("$")
	$+6::发送原义字符("^")
	$+9::发送原义字符("(")
	$+0::发送原义字符(")")
	$+-::发送原义字符("_")
	$+;::发送原义字符(":")
	$+'::发送原义字符("""")
	$+,::发送原义字符("<")
	$+.::发送原义字符(">")
	$+/::发送原义字符("?")
return
#If

class 智能标点
{
	Static hSci

	;获取Scintilla的hwnd
	__New()
	{
		oSciTE := ComObjActive("SciTE4AHK.Application")
		hEditor:=oSciTE.SciTEHandle
		;Com得到的句柄SciTE的，而需要的是Scintilla的
		;Get handle to focused control
		ControlGetFocus, cSci, ahk_id %hEditor%
		;Check if it fits the class name
		if InStr(cSci, "Scintilla")
		{
			ControlGet, hSci, Hwnd,, %cSci%, ahk_id %hEditor%
			this.hSci:=hSci
			return,	this
		}
		else
			return, 0
	}

	;高亮风格为1时，代表此位置为行注释
	;高亮风格为2时，代表此位置为块注释
	;高亮风格为6时，代表此位置为字符串
	;高亮风格为20时，代表此位置为语法错误（比如想输入字符串但只输入了一个双引号时）
	;高亮风格的定义，在lpp.style文件中
	;存在一点问题，假设一个快捷键*会激活这个函数
	;假设当前坐标是100，当按下*后，坐标应该变为101
	;但如果此时通过SCI_GETCURRENTPOS得到的坐标依然是100，再代入SCI_GETSTYLEAT
	;返回值将永远是0
	;使用内置变量“A_CaretX”“A_CaretY”替代“SCI_GETCURRENTPOS”后，没再出现过这个问题
	;当然，这也可能跟加入了50ms延时有关
	获取当前位置语法高亮风格()
	{
		;~ SCI_GETCURRENTPOS  2008
		;~ SCI_GETSTYLEAT  2010
		SendMessage, 2008, 0, 0, , % "ahk_id " this.hSci
		SendMessage, 2010, ErrorLevel, 0, , % "ahk_id " this.hSci
		if ErrorLevel in 1,2,6		;虽然理论上6和20也就是字符串区域也是可以有中文标点的，但是实际上这会造成输入一个英文双引号后，第二个英文双引号就很难输出来
			return, "注释"			;在注释区，标点由输入法自行决定
		else
			return, "代码"			;在代码区，标点始终为英文
	}
}

; 这种发送原义字符的方式可以避开输入法的设置
; Send, {Text} 方式绕得过搜狗和微软输入法，但似乎绕不过某些输入法。
; Send, {Asc 41} 方式绕得过搜狗和微软输入法，似乎也绕得过某些输入法，但因为{Asc 41}实现方式就是按住alt再按41，所以会额外激活如alt+4的快捷键。
发送原义字符(字符)
{
	dec:=Ord(字符)
	hex:=Format("{1:X}", dec)
	SendInput, {U+%hex%}
}