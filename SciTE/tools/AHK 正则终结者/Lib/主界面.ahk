/*
http://www.scintilla.org/ScintillaDoc.html

sci.SetHscrollBar(true), sci.SetVscrollBar(true)	; 开启横竖滚动条
sci.SetScrollWidthTracking(true)                  ; 滚动条宽度不变
sci.SetMarginLeft(0,20)                           ; 左边距,可以凭空设置出一个边距

The margins are numbered 0 to 4. Using a margin number outside the valid range has no effect. By default, margin 0 is set to display line numbers, but is given a width of 0, so it is hidden. Margin 1 is set to display non-folding symbols and is given a width of 16 pixels, so it is visible. Margin 2 is set to display the folding symbols, but is given a width of 0, so it is hidden. Of course, you can set the margins to be whatever you wish.
默认设置下, margin 0 用于显示行号,但是宽度为 0. margin 1 用于显示不折叠时的那个范围竖线,默认宽度 16 像素
*/
界面:
  缩放系数:=A_ScreenDPI/96
  DllPath:=查找SciLexer_dll路径()                               ; 可自行从当前目录, SCITE 目录, AutoHotkey.exe 目录 3 个地方查找 SciLexer.dll

  Menu, Tray, Icon, %A_ScriptDir%\正则.ico                      ; 设置图标必须放第一行，否则失效
  Gui, +Hwnd主界面 +Resize +MinSize +0x2000000                  ; Gui 的 Hwnd , SCITE 编辑框需要使用. 同时支持界面大小调整,限制最小尺寸,调整大小不闪烁

  ; scintilla 界面的大小完全由标签 GuiSize 控制了，这里的参数没有意义。
  sci1 := new scintilla(主界面, "", "", "", "", DllPath)        ; 正则框
  , sci1.SetMarginWidthn(1, 0)                                  ; 隐藏 margin 1
  , sci1.SetCodepage(65001)                                     ; 设置代码页
  , sci1.StyleSetSize(32, 12)                                   ; 设置字体大小
  , sci1.SetWrapMode(true)                                      ; 使用自动换行模式(避免丑陋的滚动条不必时的出现)
  , sci1.SetModEventMask(SC_MOD_INSERTTEXT|SC_MOD_DELETETEXT)   ; 设置 "SCN_MODIFIED" 仅响应增删文本
  , sci1.Notify := "Notify"                                     ; 使用 "Notify" 函数处理消息. 通过逗号实现放同一行设置可提高性能

  ; 主窗口使用样式  +0x2000000 避免闪烁后， GroupBox 坐标范围内的所有控件均无法刷新，因此只能用文字+分隔线替代
  Gui, Add, Text, x13 y10, 正则表达式
  Gui, Add, Text, x80 y15 h2 +0x10 vGB正则表达式

  Gui, Add, Text, x15 y89, 起点:
  Gui, Add, Edit, x50 y85 w50 h20 -Multi Number v起点 g实时响应
  Gui, Add, UpDown, 0x80 Range-9999-9999 v起点2 g实时响应, 1
  Gui, Add, Checkbox, x130 y80 w90 h30 Checked v全局模式 g实时响应, 全局模式
  Gui, Add, Checkbox, x230 y80 w90 h30 Checked v兼容模式 g实时响应, 兼容模式
  Gui, Add, Checkbox, x15 y105 w90 h30 v不区分大小写 g实时响应, 不区分大小写
  Gui, Add, Checkbox, x130 y105 w90 h30 v句点全匹配 g实时响应, 句点全匹配
  Gui, Add, Checkbox, x230 y105 w90 h30 v非贪婪模式 g实时响应, 非贪婪模式

  Gui, Add, Button, v参考, 参考
  gosub, 创建正则参考菜单

  ; 主窗口使用样式  +0x2000000 避免闪烁后， GroupBox 坐标范围内的所有控件均无法刷新，因此只能用文字+分隔线替代
  Gui, Add, Text, x13 y145, 文本
  Gui, Add, Text, x44 y150 h2 +0x10 vGB文本

  ; scintilla 界面的大小完全由标签 GuiSize 控制了，这里的参数没有意义。
  sci2 := new scintilla(主界面, "", "", "", "", DllPath)			; 文本框
  , sci2.SetMarginWidthn(1, 0)
  , sci2.SetCodepage(65001)                                   ; 使用 65001 ,需在 SCI 库文件中替换 5 个 "CP0" 为 "UTF-8". 意义在于, UTF-8 支持的字符比 ANSI 多
  , sci2.StyleSetSize(32, 12)
  , sci2.SetWrapMode(true)                                    ; 似乎会影响文本的显示和高亮的显示,还是先屏蔽了吧
  , sci2.SetWrapVisualFlags(1|2)
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED1, 0x000000)		      ; 设置高亮文字颜色1
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED1, 0xFFFFA1)		      ; 设置高亮背景颜色1
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED2, 0xAA0000)		      ; 设置高亮文字颜色2
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED2, 0xFFFFA1)		      ; 设置高亮背景颜色2
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED3, 0x00AA00)		      ; 设置高亮文字颜色3
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED3, 0xFFFFA1)		      ; 设置高亮背景颜色3
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED4, 0x000000)		      ; 设置高亮文字颜色4
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED4, 0x808022)		      ; 设置高亮背景颜色4
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED5, 0xAA0000)		      ; 设置高亮文字颜色5
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED5, 0x808022)		      ; 设置高亮背景颜色5
  , sci2.StyleSetFore(SCE_AHKL_LPPDEFINED6, 0x00AA00)		      ; 设置高亮文字颜色6
  , sci2.StyleSetBack(SCE_AHKL_LPPDEFINED6, 0x808022)		      ; 设置高亮背景颜色6
  , sci2.SetModEventMask(SC_MOD_INSERTTEXT|SC_MOD_DELETETEXT)
  , sci2.Notify := "Notify"

  Gui, Add, Button, v关闭, 关闭
  Gui, Add, Button, v主页, 主页
  Gui, Add, Button, v存储正则 +Disabled, 存储正则
  Gui, Add, Button, v生成代码, 生成代码
  Gui, Show, CEnter w370 h545, AHK 正则终结者 v1.5

  ; 窗口创建后再设置文本内容可以避免内容初始被选中
  sci1.SetText(不再使用的参数, 初始正则框内容)                ; 添加文本. 第一个参数是一个不再使用了的参数
  , sci2.SetText(不再使用的参数, 初始文本框内容)

  OnMessage(0x6, "WM_ACTIVATE")                               ; 监视窗口是否激活
  OnMessage(0x200, "WM_MouseMove")                            ; 监视鼠标移动消息

return

Button关闭:
GuiClose:
GuiEscape:
  ExitApp
return

GuiSize:
  GuiControl, Move, 参考,         % Format("x{1} y106", A_GuiWidth-50)
  GuiControl, Move, 关闭,         % Format("x13 y{1}", A_GuiHeight-30)
  GuiControl, Move, 主页,         % Format("x58 y{1}", A_GuiHeight-30)
  GuiControl, Move, 存储正则,     % Format("x103 y{1}", A_GuiHeight-30)
  GuiControl, Move, 生成代码,     % Format("x{1} y{2}", A_GuiWidth-74, A_GuiHeight-30)
  GuiControl, Move, GB正则表达式, % Format("w{1} h2", A_GuiWidth-90)
  GuiControl, Move, GB文本,       % Format("w{1} h2", A_GuiWidth-54)
  ; 使用 SetWindowPos 比 WinMove 流畅非常多
  SetWindowPos(sci1.hwnd, 13*缩放系数, 30*缩放系数, (A_GuiWidth-26)*缩放系数, 50*缩放系数)
  SetWindowPos(sci2.hwnd, 13*缩放系数, 165*缩放系数, (A_GuiWidth-26)*缩放系数, (A_GuiHeight-208)*缩放系数)
return

Button参考:
  Menu, 正则参考菜单, Show
return

Button主页:
  Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
return

Button存储正则:
return

Button生成代码:
  gosub, 智能库引用
  Gui, Submit, NoHide                     ; 获取 Gui 控件状态
  正则:="", 文本:=""
  sci1.GetText(sci1.getLength()+1, 正则)  ; 获取正则
  sci2.GetText(sci2.getLength()+1, 文本)  ; 获取文本

  正则函数:=全局模式=1 ? "RegEx.GlobalMatch" : "RegEx.Match"

  if (兼容模式=1)
    正则:=RegEx.AddOptions(正则, "m", "(*ANYCRLF)")
  if (不区分大小写=1)
    正则:=RegEx.AddOptions(正则, "i")
  if (句点全匹配=1)
    正则:=RegEx.AddOptions(正则, "s")
  if (非贪婪模式=1)
    正则:=RegEx.AddOptions(正则, "U")

  缩进:=A_Space A_Space

  代码模板=
  (LTrim
    文本=
    `(```%
    %文本%
    `)
    正则=
    `(```%
    %正则%
    `)

    返回值:=%正则函数%(文本, 正则, 起点:=%起点%)
    for k,v in 返回值
    %缩进%MsgBox, `% v.Value[0]

    return

    %库引用%
  )

  Clipboard:=代码模板
  btt("代码已复制到剪贴板",,, 2, "Style2")
  SetTimer, 关闭代码已复制提示, -3000
return

关闭代码已复制提示:
  btt(,,, 2)
return

;obj.modType 中的值不是 modificationType ,或者 modificationType 本来就是一堆标记值相加的结果
;所以正确的解决方式是,通过 sci.SetModEventMask 过滤得到需要的 modificationType
Notify(wParam, lParam, msg, hwnd, obj)
{
  if (obj.scnCode = SCN_MODIFIED)
    gosub, 实时响应
  return
}

查找SciLexer_dll路径()
{
  IfExist, %A_ScriptDir%\SciLexer.dll		    ; 当前目录
    return, A_ScriptDir "\SciLexer.dll"

  SplitPath, A_AhkPath, , ahkexedir
  IfExist, %ahkexedir%\SciTE\SciLexer.dll	  ; SciTE 目录
    return, ahkexedir "\SciTE\SciLexer.dll"

  IfExist, %ahkexedir%\SciLexer.dll		      ; AHK EXE 目录
    return, ahkexedir "\SciLexer.dll"

  MsgBox, 4112, 错误, 没找到 SciLexer.dll`n这是实现高亮的必要文件，尝试找到并放在当前目录或 AutoHotkey.exe 目录或 SciTE 目录。
  ExitApp
}

SetWindowPos(hWnd, x, y, w, h, hWndInsertAfter := 0, uFlags := 0x14)  ; uFlags := 0x4|0x10
{
  return, DllCall("SetWindowPos", "Ptr", hWnd, "Ptr", hWndInsertAfter, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", uFlags)
}

WM_ACTIVATE(wParam)
{
  if (wParam & 0xFFFF = 0)
  {
    btt(,,, 1)
    btt(,,, 2)
  }
}

WM_MOUSEMOVE()
{
  switch, A_GuiControl
  {
    case "起点","起点2":
    说明=
    (LTrim
      从文本的第 n 个字符开始查找匹配
      
      1  表示从首个字符开始
      2  表示从第2个字符开始
      0  表示从最后1个字符开始
      -1 表示从倒数第2个字符开始
      
      以此类推
    )

    case "全局模式":
    说明=
    (LTrim
      一般情况下 “正则表达式” 仅返回首个匹配
      
      此设置可让 “正则表达式” 返回全部匹配
    )

    case "兼容模式":                        ; 鼠标移动到兼容模式按钮上显示提示
    说明=
    (LTrim
      通过为 “正则表达式” 添加 “m)(*ANYCRLF)” 选项
      解决因文本中 “换行符不统一” 而导致的匹配失败
      
      强烈建议勾选此设置
    )

    case "不区分大小写":
    说明=
    (LTrim
      字母 a-z 可以匹配 A-Z
      
      反之亦然
    )

    case "句点全匹配":
    说明=
    (LTrim
      一般情况下 句点 “.” 不能匹配换行符
      此设置可让 句点 “.” 匹配包含换行符在内的所有字符
      
      注意：当换行符是两个字符时 例如 CRLF(``r``n)
      需使用 两个句点 “..” 才能匹配
    )

    case "非贪婪模式":
    说明=
    (LTrim
      一般情况下 限定符 “* ? + {n,m}” 会匹配尽量多的字符
      
      此设置可让 限定符 匹配尽量少的字符
    )
  }
  btt(说明,,,, "Style2")
}