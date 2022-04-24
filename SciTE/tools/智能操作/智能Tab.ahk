; 单词自动完成时使用 Tab 键，可自动补全命令、函数等，并设好参数。
; 此时若继续按 Tab 则可以在参数间跳跃，高效连贯的完成输入。
; BUG：
  ; SetFormat DllCall LoadPicture 不够完美。
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
    ctrlB()                    ; 展开缩略语。
    if (oSciTE.GetEnd!=str)    ; 行末内容发生变化，说明缩略语被展开了。
    {
      selNext()                ; 在缩略语文件中已经设置过光标位置为单词前，所以这里直接选择下一单词就是了。
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
    
    if (oSciTE.Selection!="")                      ; 当前已有选中文字，则发送右箭头取消选择状态。
      Send, {Right}
    
    loop, 25
    {
      光标右边文本 := getNext()                    ; 获取光标右边文本。大致等效于 Ctrl+Shift+Right
      右边文本末1  := SubStr(光标右边文本, 0, 1)
      右边文本末2  := SubStr(光标右边文本, -1, 2)
      
      ; 空格或制表符
      if (RegExMatch(光标右边文本, "^[ \t]+$"))
      {
        ctrlRight()
        continue
      }
      ; 文末
      else if (光标右边文本="")
      {
        Send, {Enter}
        标记 := 0
        ToolTip
        return
      }
      ; 行末 例如 msg,aa,bb|`r`nxxxxxx
      else if (右边文本末2="`r`n")
      {
        Send, {Enter}
        标记 := 0
        ToolTip
        return
      }
      ; 闭括号 例如 instr(aa|)`r`nxxxxxx
      else if (右边文本末1=")")
      {
        Send, {Right}
        continue
      }
      ; 闭引号 例如 msg, "aa|" ,bb`r`nxxxxxx
      else if (右边文本末1="""")
      {
        Send, {Right}
        continue
      }
      ; 分隔参数的逗号
      else if (右边文本末1=",")
      {
        ctrlRight()
        selNext()
        return
      }
      ; 专为 for 和 class 设置
      else if (光标右边文本="in" or 光标右边文本="extends")
      {
        ctrlRight()
        selNext()
        return
      }
      else
      {
        ctrlRight()
        continue
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
    
    ; 光标处 style 为字符串，且右边存在引号，则需补引号
    try quote := oSciTE.GetStyle()=6 and InStr(str, """")
    
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
      if (quote)
        发送原义字符("""")
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
        发送原义字符(quote ? """)" : ")")
        Send, {Enter}
        标记 := 0
        ToolTip
      }
      ; 多个闭括号在且仅在行末
      ; 例如 aa|,bb)))
      else if (行末闭括号数量>1 and RTrim(str2, ")")="")
      {
        发送原义字符(quote ? """)" : ")")
        oSciTE.InsertText(str2)
      }
      ; 有1个闭括号在中间
      ; 例如 aa|,bb),cc
      ; 例如 aa|,bb),cc)))
      else
      {
        发送原义字符(quote ? """)" : ")")
        oSciTE.InsertText(str2)
        if (SubStr(str2, 1, 1)=",")
          ctrlRight()
        selNext()
      }
    }
  }
#If

; 这里还可以用 AutomationID 的方式实现
; https://www.cnblogs.com/guyk/p/15572335.html
ctrlB()
{
  global oSciTE
  
  ; IDM_ABBREV = 242
  oSciTE.SendDirectorMsg("menucommand:242")
}

ctrlRight()
{
  global oSciTE
  
  oSciTE.SendDirectorMsg("macrocommand:2310;0II;0;0")
}

; 大致等效于 Ctrl+Shift+Right 选中后得到的内容
getNext()
{
  global oSciTE
  
  curPos  := oSciTE.GetCurPos()
  ; SCI_WORDENDPOSITION = 2267
  nextPos := oSciTE.Msg(2267, curPos, false)
  return, oSciTE.GetTextRange(curPos, nextPos)
}

; 选中右边的单词（单词定义为 a-z|<>*\-+ ）
selNext()
{
  global oSciTE
  
  matchPos := oSciTE.FindText("[\w\|\<\>\*\\\-\+]+","","",0x00200000)
  if (matchPos[1]!=0)
  {
    ; SCI_SETSELECTIONSTART = 2142, SCI_SETSELECTIONEND = 2144
    oSciTE.Msg(2142, matchPos[1])
    oSciTE.Msg(2144, matchPos[2])
  }
}