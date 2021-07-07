/*
http://www.scintilla.org/ScintillaDoc.html

sci.SetHscrollBar(true), sci.SetVscrollBar(true)	;开启横竖滚动条
sci.SetScrollWidthTracking(true)			;滚动条宽度不变
sci.SetMarginLeft(0,20)					;左边距,可以凭空设置出一个边距

The margins are numbered 0 to 4. Using a margin number outside the valid range has no effect. By default, margin 0 is set to display line numbers, but is given a width of 0, so it is hidden. Margin 1 is set to display non-folding symbols and is given a width of 16 pixels, so it is visible. Margin 2 is set to display the folding symbols, but is given a width of 0, so it is hidden. Of course, you can set the margins to be whatever you wish.
默认设置下, margin 0 用于显示行号,但是宽度为 0. margin 1 用于显示不折叠时的那个范围竖线,默认宽度 16 像素
*/
/*
创建的变量(对象)有
Hwnd主界面
v起始坐标
v全局模式
v替换模式
sci1
sci2
----------
GB正则表达式
v提示
vGB文本
v关闭
v存储正则
v复制代码
v高级按钮

v起始坐标 及其 UpDown 控件
v全局模式
v替换模式
sci1
sci2
均响应实时响应标签
*/
界面:
  DllPath:=查找SciLexer_dll路径()					;可自行从当前目录, SCITE 目录, AutoHotkey.exe 目录 3 个地方查找 SciLexer.dll
  ;设置图标必须放第一行，否则失效
  Menu Tray, Icon, %A_ScriptDir%\正则.ico
  Gui, +Hwnd主界面	+Resize +MinSize				;Gui 的 Hwnd , SCITE 编辑框需要使用. 同时支持界面大小调整,限制最小尺寸
  Gui, Color, , White							;设置控件背景色,主要为了使 Edit 控件背景色为白色,和 SCI框 匹配
  Gui, Add, GroupBox, x5 y10 h105 vGB正则表达式, 正则表达式
  ;scintilla 界面的大小完全由标签 GuiSize 控制了，这里的参数没有意义。
  sci1 := new scintilla(主界面,"","","","",DllPath)			;正则框
          , sci1.SetMarginWidthn(1,0)					;隐藏 margin 1
          , sci1.SetCodepage(65001)					;设置代码页
          , sci1.StyleSetSize(32, 12)					;设置字体大小
          , sci1.SetWrapMode(true)					;使用自动换行模式(避免丑陋的滚动条不必时的出现)
          , sci1.SetText(不再使用的参数,初始正则框内容)			;添加文本. 第一个参数是一个不再使用了的参数
          , sci1.SetModEventMask(SC_MOD_INSERTTEXT|SC_MOD_DELETETEXT)	;设置 "SCN_MODIFIED" 仅响应增删文本
          , sci1.Notify := "Notify"					;使用 "Notify" 函数处理消息. 通过逗号实现放同一行设置可提高性能

  Gui, Add, Text, x13 y89, 起始坐标:
  Gui, Add, Edit, x73 y85 w50 h20 -Multi Number v起始坐标 g实时响应
  Gui, Add, UpDown, 0x80 Range-999-999 g实时响应, 1
  Gui, Add, Checkbox, x135 y80 w65 h30 Checked v全局模式 g实时响应, 全局模式
  Gui, Add, Checkbox, x210 y80 w65 h30 v替换模式 g实时响应 +Disabled, 替换模式
  Gui, Add, Button, y84 w36 h22 v提示, 提示
  gosub,创建正则提示菜单

  Gui, Add, GroupBox, x5 y120 vGB文本, 文本
  ;scintilla 界面的大小完全由标签 GuiSize 控制了，这里的参数没有意义。
  sci2 := new scintilla(主界面,"","","","",DllPath)			;文本框
          , sci2.SetMarginWidthn(1,0)
          , sci2.SetCodepage(65001)					;使用 65001 ,需在 SCI 库文件中替换 5 个 "CP0" 为 "UTF-8". 意义在于, UTF-8 支持的字符比 ANSI 多
          , sci2.StyleSetSize(32, 12)
          , sci2.SetWrapMode(true)					;似乎会影响文本的显示和高亮的显示,还是先屏蔽了吧
          , sci2.SetWrapVisualFlags(1|2)
          , sci2.SetText(不再使用的参数,初始文本框内容)
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED1, 0x000000)		;设置高亮文字颜色1
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED1, 0xFFFFA1)		;设置高亮背景颜色1
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED2, 0xAA0000)		;设置高亮文字颜色2
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED2, 0xFFFFA1)		;设置高亮背景颜色2
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED3, 0x00AA00)		;设置高亮文字颜色3
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED3, 0xFFFFA1)		;设置高亮背景颜色3
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED4, 0x000000)		;设置高亮文字颜色4
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED4, 0x808022)		;设置高亮背景颜色4
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED5, 0xAA0000)		;设置高亮文字颜色5
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED5, 0x808022)		;设置高亮背景颜色5
          , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED6, 0x00AA00)		;设置高亮文字颜色6
          , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED6, 0x808022)		;设置高亮背景颜色6
          , sci2.SetModEventMask(SC_MOD_INSERTTEXT|SC_MOD_DELETETEXT)
          , sci2.Notify := "Notify"

  Gui, Add, Button, v关闭, 关闭
  Gui, Add, Button, v主页, 主页
  Gui, Add, Button, v存储正则 +Disabled, 存储正则
  Gui, Add, Button, v复制代码 +Disabled, 复制代码
  Gui, Add, Button, v高级按钮 g高级按钮 +Disabled, 高级>>
  Gui, Show, CEnter w370 h520, AHK 正则终结者 ver. 0.4
return

Button关闭:
GuiClose:
GuiEscape:
  ExitApp
return

GuiSize:
  缩放系数:=A_ScreenDPI/96
  GuiControl, Move, 提示, % "x" . a_Guiwidth - 50
  GuiControl, Move, 关闭, % "x" . 5 "y" . a_Guiheight - 30
  GuiControl, Move, 主页, % "x" . 50 "y" . a_Guiheight - 30
  GuiControl, Move, 存储正则, % "x" . 95 "y" . a_Guiheight - 30
  GuiControl, Move, 复制代码, % "x" . 165 "y" . a_Guiheight - 30
  GuiControl, Move, 高级按钮, % "x" . a_Guiwidth - 55 "y" . a_Guiheight - 30
  GuiControl, Move, GB文本, % "w" . a_Guiwidth - 10 "h" . a_Guiheight - 155
  GuiControl, Move, GB正则表达式, % "w" . a_Guiwidth - 10
  WinMove, % "ahk_id " sci1.hwnd,, 13*缩放系数, 30*缩放系数, % (a_Guiwidth - 26)*缩放系数, 50*缩放系数
  WinMove, % "ahk_id " sci2.hwnd,, 13*缩放系数, 140*缩放系数, % (a_Guiwidth - 26)*缩放系数, % (a_Guiheight - 183)*缩放系数
return

Button提示:
  Menu, 正则提示菜单, Show
return

Button主页:
  Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
return

Button存储正则:
return

Button复制正则:
return

;obj.modType 中的值不是 modificationType ,或者 modificationType 本来就是一堆标记值相加的结果
;所以正确的解决方式是,通过 sci.SetModEventMask 过滤得到需要的 modificationType
Notify(wParam, lParam, msg, hwnd, obj)
  {
    If (obj.scnCode = SCN_MODIFIED)
        gosub,实时响应
    return
  }

查找SciLexer_dll路径()
{
  IfExist,%A_ScriptDir%\SciLexer.dll		;当前目录
      return,A_ScriptDir . "\SciLexer.dll"

  SplitPath,A_AhkPath,,ahkexedir
  IfExist,%ahkexedir%\SciTE\SciLexer.dll	;SCITE目录
      return,ahkexedir . "\SciTE\SciLexer.dll"

  IfExist,%ahkexedir%\SciLexer.dll		;EXE目录
      return,ahkexedir . "\SciLexer.dll"

  MsgBox, 4112, 错误, 没找到 SciLexer.dll`n这是实现高亮的必要文件，尝试找到并放在当前目录或AutoHotkey.exe目录或SciTE目录。
  ExitApp
}

#Include %A_ScriptDir%\正则提示菜单.ahk
#Include %A_ScriptDir%\高级模式界面.ahk