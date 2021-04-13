; SciTE4AutoHotkey v3 user autorun script
;
; You are encouraged to edit this script!
;

#NoEnv
#NoTrayIcon
#SingleInstance Force

公用:
  SetWorkingDir, %A_ScriptDir%
  oSciTE := ComObjActive("SciTE4AHK.Application")
  SciTE_Hwnd := oSciTE.SciTEHandle

  gosub, 中文帮助友好提示
  gosub, 智能Tab
  gosub, 智能标点

  WinWaitClose, ahk_id %SciTE_Hwnd% ; 随 SciTE 退出。
  WinClose, ahk_exe keyhh.exe       ; 退出时关闭帮助。
  ExitApp
return

中文帮助友好提示:
  中文帮助路径 := oSciTE.SciTEDir . "\..\AutoHotkey_CN.chm"
  keyhh路径    := oSciTE.SciTEDir . "\tools\keyhh.exe"
  if (!FileExist(中文帮助路径))     ; 中文帮助不存在，按 F1 没反应的情况下，友好的提示使用者该怎么做。
  {
    错误提示=
    (LTrim
    请自行于 GitHub 或 QQ 群下载帮助文件
    命名为 “AutoHotkey_CN.chm”
    存放于 “AutoHotkey.exe” 所在位置。
    )
    MsgBox, 262160, 没有找到中文帮助文件, %错误提示%
  }
  else if (!FileExist(keyhh路径))
  {
    错误提示=
    (LTrim
    请自行下载 keyhh.exe
    存放于 “SciTE.exe\tools” 目录下。
    )
    MsgBox, 262160, 没有找到 keyhh.exe, %错误提示%
  }
return

; 2020.7.24 “智能F1” 全面接管 F1 功能。
; 故需要屏蔽 “SciTEUser.properties” “platforms.properties” 文件中的自带 F1 功能。
#If WinActive("ahk_id " . SciTE_Hwnd)                  ; 限制 “智能F1” 的作用范围只在 scite 中。
F1::
  Send, ^{Left}^+{Right}
  Sleep, 50                                            ; 延时是必须的，否则偶尔会取不到词。
  光标下单词:=Trim(oSciTE.Selection(), " `t`r`n`v`f")  ; 把两侧的空白符去掉，不然 “else” 无法被正确激活。
  光标下单词:=" " 光标下单词                           ; 故意在单词前添加一个空格，这样输入索引栏的时候会加速不少。

  WinGet, MinMax, MinMax, ahk_exe keyhh.exe            ; 为啥用 keyhh.exe ？因为 hh.exe 打开的帮助无法判断、还原最小化状态。
  if (MinMax="")                                       ; 检测帮助文件是否已存在。
  {
    重定位帮助文件显示位置:=1
    Run, % keyhh路径 " -ahkhelp " 中文帮助路径         ; 不要在这里存 PID ，因为重载时此处 PID 会更新，但实际进程 PID 却不变。
    WinWait, ahk_exe keyhh.exe                         ; 这行不能少，否则很容易无法激活帮助文件。
  }
  else if (MinMax=-1)                                  ; 检测帮助文件是否最小化。
  {
    WinRestore, ahk_exe keyhh.exe
  }
  WinActivate, ahk_exe keyhh.exe                       ; 激活。
  WinWaitActive, ahk_exe keyhh.exe

  ControlGetFocus, Focus, ahk_exe keyhh.exe
  if (Focus="")                                        ; 检测帮助文件是否失去过焦点（通常发生在最小化后又手动还原了）。
  {                                                    ; 帮助文件最小化以后，难以自动激活索引栏焦点，故直接重载。
    重定位帮助文件显示位置:=1
    Run, % keyhh路径 " -ahkhelp " 中文帮助路径         ; 不要在这里存 PID ，因为重载时 PID 虽会更新，但实际进程 PID 却不变。
    WinWait, ahk_exe keyhh.exe                         ; 这行不能少，否则很容易无法激活帮助文件。
    WinActivate, ahk_exe keyhh.exe                     ; 激活。
    WinWaitActive, ahk_exe keyhh.exe
  }

  if (重定位帮助文件显示位置)
  {
    SysGet, WorkArea, MonitorWorkArea, 1               ; 获取工作区尺寸，即不含任务栏的屏幕尺寸。
    DPIScale:=A_ScreenDPI/96
    W:=(WorkAreaRight-WorkAreaLeft)//2
    X:=WorkAreaLeft+W+(-1+8)*DPIScale
    Y:=WorkAreaTop
    H:=WorkAreaBottom-Y+(-1+8)*DPIScale
    WinMove, ahk_exe keyhh.exe,, X, Y, W, H            ; 显示在屏幕右侧并占屏幕一半尺寸。
    重定位帮助文件显示位置:=0
  }

  ; 有2种方法可以直接让 chm 定位到某个页面中
  ; 1. hh.exe mk:@MSITStore:R:\AutoHotkey.chm::/docs/Variables.htm#IsCompiled
  ; 2. KeyHH.exe -MyID R:\AutoHotkey.chm::/docs/Variables.htm#IsCompiled
  ; 在浏览器中使用 search.htm?q=Call&m=1 可以跳到通过索引搜索单词 Call 的结果页面
  ; 但 hh.exe 和 KeyHH.exe 都不支持带参数的 htm 所以下面这个例子是失败的
  ; 3. KeyHH.exe -MyID R:\AutoHotkey.chm::/docs/search.htm?q=Call&m=1
  ; 所以只能用快捷键模拟的方式实现了
  SendInput, !n                                             ; 定位到索引栏。
  Sleep, 100                                                ; 这个延时是必须的，否则当焦点不在索引栏时很容易导致清空索引栏失败。
  SendInput, ^a{BackSpace}                                  ; 清空索引栏。
  SendInput, {Ctrl Up}{Shift Up}{Alt Up}{LWin Up}{RWin Up}  ; 强制释放修饰键，避免出 bug 。
  SendInput, {Blind}{Text}%光标下单词%                      ; 原义的发送获取到的单词，否则 “#if” 之类的会被错误解析。text 模式可以忽略输入法状态， raw 不行。
  SendInput, {Home}{Del}{End}{Enter}{Enter}                 ; 因为单词前被故意加了一个空格，因此完成输入后需要删除那个多余的空格。
return
#If

; 单词自动完成时使用 Tab 键，可自动补全命令、函数等，并设好参数。此时若继续按 Tab 则可以在参数间跳跃，高效连贯的完成输入。
; BUG：
;   参数中含有特殊字符（例如英文引号， “\” “/” 等等）时无法被自动选中。
智能Tab:
  标记 := 0
return

; 自动完成状态下，使用 Tab 将展开缩略语，并选中第一个参数。
#If (标记=0) and WinExist("ahk_class ListBoxX") and WinActive("ahk_id " . SciTE_Hwnd)
~$Tab::
  Send, ^b                          ; 展开缩略语。SendInput 发送快捷键是不一定生效的，所以全部使用 Send 代替。
  Send, ^+{Right}                   ; 在缩略语文件中已经设置过光标位置为单词前，所以这里直接选择下一单词就是了。
  Sleep, 50                         ; 添加这个延时可解决 “获取选中内容时而有效时而失效的问题” 。
  if (InStr(oSciTE.Selection,"`n")) ; 必须用 InStr ，因为比如第25-30行都是空行，那么在第25行开始 “Send, ^+{Right}” ，选中的内容就会包含多个换行符。
  {
    Send, {Left}
    return
  }
  if (oSciTE.Selection="")
    return
  标记 := 1
  ToolTip, 智能Tab 已启用
return

; 使用 Tab 在参数间跳跃。
; 智能 Tab 启用期间， Tab 键只起 “在参数间跳跃” 这一个作用。
#If  (标记=1) and !WinExist("ahk_class SoPY_Comp") and WinActive("ahk_id " . SciTE_Hwnd)
$Tab::
  if (oSciTE.Selection<>"")       ; 当前已有选中文字，则发送右箭头取消选择状态。
    Send, {Right}
  loop, 25
  {
    Send, ^+{Right}               ; 选中右面单词。
    选中文本 := oSciTE.Selection  ; 获取被选中的内容。
    if (选中文本="")              ; 最后一行。
    {
      Send, {Right}
      Send, {Enter}
      标记 := 0
      ToolTip
      return
    }
    else if (SubStr(选中文本, 1, 2)="`r`n" or SubStr(选中文本, -1, 2)="`r`n") ; 行末。
    {
      Send, ^{Left}
      Send, {Enter}
      标记 := 0
      ToolTip
      return
    }
    else if (SubStr(选中文本, 0, 1)=")")                        ; 带闭括号的行末。
    {
      Send, {Right}
      continue
    }
    else if (SubStr(RTrim(选中文本, " `t`r`n`v`f"), 0, 1)=",")  ; 逗号后面的参数。
    {
      Send, {Right}
      Send, ^+{Right}
      return
    }
    else if (Trim(选中文本, " `t`r`n`v`f")="in")                ; 专为 for 设置。
    {
      Send, {Left}
      Send, {Space}
      Send, ^{Right}
      Send, ^+{Right}
      return
    }
  }
  标记 := 0
  ToolTip
return

; “自动完成框” 存在时，回车键作用为上屏自动完成单词。
; “搜狗输入法框” 存在时，回车键作用为上屏输入的英文。
; “自动完成框” 与 “搜狗输入法框” 均存在时，回车键作用为上屏输入的英文。
; “自动完成框” 与 “搜狗输入法框” 均不存在时，回车键作用为 “关闭智能 Tab ” 。
#If  (标记=1) and !WinExist("ahk_class ListBoxX") and !WinExist("ahk_class SoPY_Comp") and WinActive("ahk_id " . SciTE_Hwnd)
$NumpadEnter::
$Enter::
  if (oSciTE.Selection<>"")                                     ; 当前已有选中文字，则发送右箭头取消选择状态。
    Send, {Right}
  Send, +{End}                                                  ; 选中文字到行末。 Alt+Shift+End 在遇到自动换行时不会选中到真正的行末。
  if (SubStr(RTrim(oSciTE.Selection, " `t`r`n`v`f"), 0, 1)=")") ; 检查行最后一个非空白字符是否是闭括号，是则补一个闭括号。
    发送原义字符(")")
  Send, {Enter}
  标记 := 0
  ToolTip
return
#If

; 在代码区，标点总是英文。
; 在注释区，标点由输入法控制。
; 这里有个小 bug 。
; 就是在行注释的行首处，中文输入法状态下，输入一个英文字，比如 “f” ，然后用 “Shift” 键让英文上屏，这时获取到的高亮状态是不正确的。
; 不过由于随便再动一下光标就又能获取到正确高亮状态了，所以这个 bug 几乎没任何影响。
智能标点:
  ime:=new 智能标点()
  SetTimer, 获取当前位置语法高亮风格, 50
return

获取当前位置语法高亮风格:
  ; 光标位置发生变化的时候获取一次当前位置的高亮风格。
  if (A_CaretX!=oldx or A_CaretY!=oldy)
  {
    oldx:=A_CaretX, oldy:=A_CaretY
    style:=ime.获取当前位置语法高亮风格()
  }
return

#If Style="代码" and WinActive("ahk_id " . SciTE_Hwnd)
  ; 按键本身就是符号。
  $`::发送原义字符("``")
  $[::发送原义字符("[")
  $]::发送原义字符("]")
  $;::发送原义字符(";")
  $'::发送原义字符("'")
  $\::发送原义字符("\")
  $,::发送原义字符(",")
  $.::发送原义字符(".")
  $/::发送原义字符("/")
  ; Shift 与按键组合的符号。
  $+1::发送原义字符("!")
  $+4::发送原义字符("$")
  $+6::发送原义字符("^")
  $+9::发送原义字符("(")
  $+0::发送原义字符(")")
  $+-::发送原义字符("_")
  $+[::发送原义字符("{")
  $+]::发送原义字符("}")
  $+;::发送原义字符(":")
  $+'::发送原义字符("""")
  $+,::发送原义字符("<")
  $+.::发送原义字符(">")
  $+/::发送原义字符("?")
return
#If

class 智能标点
{
  static hSci

  __New()
  {
    global SciTE_Hwnd                                       ; Com 得到的句柄是 SciTE 的，而需要的是 Scintilla 的。
    ControlGetFocus, cSci, ahk_id %SciTE_Hwnd%              ; 获取焦点处 ClassNN 。
    if InStr(cSci, "Scintilla")
    {
      ControlGet, hSci, Hwnd,, %cSci%, ahk_id %SciTE_Hwnd%  ; 获取 Scintilla 的句柄。
      this.hSci:=hSci
      return,  this
    }
    else
      return, 0
  }

  ; 高亮风格为1时，代表此位置为行注释。
  ; 高亮风格为2时，代表此位置为块注释。
  ; 高亮风格为6时，代表此位置为字符串。
  ; 高亮风格为20时，代表此位置为语法错误（比如想输入字符串但只输入了一个双引号时）。
  ; 高亮风格的定义，在 lpp.style 文件中。
  ; 存在一点问题，假设一个快捷键*会激活这个函数，
  ; 假设当前坐标是100，当按下*后，坐标应该变为101，
  ; 但如果此时通过 SCI_GETCURRENTPOS 得到的坐标依然是100，再代入 SCI_GETSTYLEAT 返回值将永远是0。
  ; 使用内置变量 “A_CaretX” “A_CaretY” 替代 “SCI_GETCURRENTPOS” 后，没再出现过这个问题。
  ; 当然，这也可能跟加入了 50ms 延时有关。
  获取当前位置语法高亮风格()
  {
    SendMessage, 2008, 0, 0, , % "ahk_id " this.hSci          ; SCI_GETCURRENTPOS = 2008
    SendMessage, 2010, ErrorLevel, 0, , % "ahk_id " this.hSci ; SCI_GETSTYLEAT = 2010
    if ErrorLevel in 1,2,6  ; 理论上20区域也是可以有中文标点的，但是这会造成输入一个英文双引号后，第二个英文双引号很难输出来，所以只有1、2、6。
      return, "注释"        ; 在注释区，标点由输入法自行决定。
    else
      return, "代码"        ; 在代码区，标点始终为英文。
  }
}

; 这种发送原义字符的方式可以避开输入法的设置。
; Send, {Text} 方式绕得过搜狗和微软输入法，但似乎绕不过某些输入法。
; Send, {Asc 41} 方式绕得过搜狗和微软输入法，似乎也绕得过某些输入法，但因为 {Asc 41} 实现方式就是按住 Alt 再按41，所以会额外激活如 Alt+4 的快捷键。
发送原义字符(字符)
{
  dec:=Ord(字符)
  hex:=Format("{1:X}", dec)
  SendInput, {U+%hex%}
}