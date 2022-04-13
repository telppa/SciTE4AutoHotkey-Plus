; 单词自动完成时使用 Tab 键，可自动补全命令、函数等，并设好参数。
; 此时若继续按 Tab 则可以在参数间跳跃，高效连贯的完成输入。
; BUG：
  ; 参数中含有特殊字符（例如英文引号， “\” “/” 等等）时无法被自动选中。
智能Tab:
  标记 := 0
return

; 自动完成状态下，使用 Tab 将展开缩略语，并选中第一个参数。
#If WinActive("ahk_id " . SciTE_Hwnd) and WinExist("ahk_class ListBoxX")
~$Tab::
  Tab展开()
  {
    global oSciTE, 标记
    
    str := oSciTE.GetEnd
    Send, ^b                        ; 展开缩略语。SendInput 发送快捷键是不一定生效的，所以全部使用 Send 代替。
    Sleep, 50                       ; 添加这个延时可解决 “获取选中内容时而有效时而失效的问题” 。
    if (oSciTE.GetEnd!=str)
    {
      Send, ^+{Right}               ; 在缩略语文件中已经设置过光标位置为单词前，所以这里直接选择下一单词就是了。
      标记 := 1
      ToolTip, 智能Tab 已启用
    }
  }

; 使用 Tab 在参数间跳跃。
; 智能 Tab 启用期间， Tab 键只起 “在参数间跳跃” 这一个作用。
#If (标记=1) and WinActive("ahk_id " . SciTE_Hwnd) and !WinExist("ahk_class SoPY_Comp")
$Tab::
  Tab跳跃()
  {
    global oSciTE, 标记
    
    if (oSciTE.Selection!="")                        ; 当前已有选中文字，则发送右箭头取消选择状态。
      Send, {Right}
    
    loop, 25
    {
      Send, ^+{Right}                                ; 选中右边单词。
      选中文本 := Trim(oSciTE.Selection, " `t`v`f")  ; 获取被选中的内容。
      
      ; 文末
      if (选中文本="")
      {
        Send, {Right}
        Send, {Enter}
        标记 := 0
        ToolTip
        return
      }
      ; 行末 例如 msg,aa,bb|`r`nxxxxxx
      else if (SubStr(选中文本, -1, 2)="`r`n")
      {
        Send, ^{Left}
        Send, {Enter}
        标记 := 0
        ToolTip
        return
      }
      ; 带闭括号的行末 例如 instr(aa|)`r`nxxxxxx
      else if (SubStr(选中文本, 0, 1)=")")
      {
        Send, {Right}
        continue
      }
      ; 分隔参数的逗号
      else if (SubStr(选中文本, 0, 1)=",")
      {
        Send, {Right}
        Send, ^+{Right}
        return
      }
      ; 专为 for 和 class 设置
      else if (选中文本="in" or 选中文本="extends")
      {
        Send, {Left}
        Send, {Space}
        Send, ^{Right}
        Send, ^+{Right}
        return
      }
    }
  }

; “自动完成框” 存在时，回车键作用为上屏自动完成单词。
; “搜狗输入法框” 存在时，回车键作用为上屏输入的英文。
; “自动完成框” 与 “搜狗输入法框” 均存在时，回车键作用为上屏输入的英文。
; “自动完成框” 与 “搜狗输入法框” 均不存在时，回车键作用为 “关闭智能 Tab ” 。
#If (标记=1) and WinActive("ahk_id " . SciTE_Hwnd) and !WinExist("ahk_class ListBoxX") and !WinExist("ahk_class SoPY_Comp")
$NumpadEnter::
$Enter::
  Enter跳跃()
  {
    global oSciTE, 标记
    
    ; 当前已有选中文字，则发送右箭头取消选择状态。
    if (oSciTE.Selection!="")
      Send, {Right}
    
    ; str = 光标处到行末的字符
    ; 例如 aa,|bb),cc,dd 中的 bb),cc,dd
    str := RTrim(oSciTE.GetEnd, " `t`r`n`v`f")
    
    ; str2 = 第1个闭括号右边的字符
    ; 例如 aa,|bb),cc,dd 中的 ,cc,dd
    pos := InStr(str, ")")
    if (pos>0)
      str2 := SubStr(str, pos+1)
    
    ; 删掉当前行中光标右边的全部内容
    oSciTE.DeleteEnd()
    
    ; 光标右边没有闭括号
    ; 例如 aa|,bb,cc
    if (pos=0)
    {
      Send, {Enter}
      标记 := 0
      ToolTip
    }
    else
    {
      RegExMatch(str, "\)+$", 行末闭括号数量)
      行末闭括号数量 := StrLen(行末闭括号数量)
      
      ; 1个闭括号在且仅在行末
      ; 例如 aa|,bb,cc)
      if (行末闭括号数量=1 and str2="")
      {
        发送原义字符(")")
        Send, {Enter}
        标记 := 0
        ToolTip
      }
      ; 多个闭括号在且仅在行末
      ; 例如 aa|,bb)))
      else if (行末闭括号数量>1 and RTrim(str2, ")")="")
      {
        发送原义字符(")")
        curPos := oSciTE.GetCurPos
        oSciTE.InsertText(str2)
        oSciTE.SetCurPos(curPos)
      }
      ; 有1个闭括号在中间
      ; 例如 aa|,bb),cc
      ; 例如 aa|,bb),cc)))
      else
      {
        发送原义字符(")")
        curPos := oSciTE.GetCurPos
        oSciTE.InsertText(str2)
        oSciTE.SetCurPos(curPos)
        if (SubStr(str2, 1, 1)=",")
          Send, ^{Right}
        Send, ^+{Right}
      }
    }
  }
#If