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