; 在代码区，标点总是英文。
; 在注释区，标点由输入法控制。
; BUG：
  ; 1.在行注释的行首处，中文输入法状态下，输入一个英文字，比如 “f” ，然后用 “Shift” 键让英文上屏，这时获取到的高亮状态是不正确的。
  ; 不过由于随便再动一下光标就又能获取到正确高亮状态了，所以这个 bug 几乎没任何影响。
智能标点:
  SetTimer, 检测光标位置语法高亮风格是否变化, 50
return

检测光标位置语法高亮风格是否变化:
  ; 光标位置发生变化的时候获取一次当前位置的高亮风格。
  if (A_CaretX!=oldx or A_CaretY!=oldy)
  {
      oldx  := A_CaretX
    , oldy  := A_CaretY
    , style := 获取当前位置语法高亮风格()
  }
return

#If style="代码" and WinActive("ahk_id " . SciTE_Hwnd)
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
#If

; 高亮风格为1时，代表此位置为行注释。
; 高亮风格为2时，代表此位置为块注释。
; 高亮风格为6时，代表此位置为字符串。
; 高亮风格为20时，代表此位置为语法错误（比如想输入字符串但只输入了一个双引号时）。
; 高亮风格的定义，在 SciTE4AutoHotkey-Plus.style.properties 文件中。
; 存在一点问题，假设一个快捷键*会激活这个函数，
; 假设当前坐标是100，当按下*后，坐标应该变为101，
; 但如果此时通过 SCI_GETCURRENTPOS 得到的坐标依然是100，再代入 SCI_GETSTYLEAT 返回值将永远是0。
; 使用内置变量 “A_CaretX” “A_CaretY” 替代 “SCI_GETCURRENTPOS” 后，没再出现过这个问题。
; 当然，这也可能跟加入了 50ms 延时有关。
获取当前位置语法高亮风格()
{
  global oSciTE
  
  ; 加 try 是因为退出 scite.exe 后，这里容易报错
  try style := oSciTE.GetStyle()
  
  if style in 1,2,6  ; 理论上区域20也是可以有中文标点的，但是这会造成输入一个英文双引号后，第二个英文双引号很难输出来，所以只有1、2、6。
    return, "注释"   ; 在注释区，标点由输入法自行决定。
  else
    return, "代码"   ; 在代码区，标点始终为英文。
}

; 直接用编辑器插入字符，可以完美绕过输入法，但却无法激活花括号 {} 的自动缩进
; Send, {Text} 方式绕得过搜狗和微软输入法，但似乎绕不过某些输入法。
; Send, {Asc 41} 方式绕得过搜狗和微软输入法，似乎也绕得过某些输入法，但因为 {Asc 41} 实现方式就是按住 Alt 再按41，所以会额外激活如 Alt+4 的快捷键。
发送原义字符(字符)
{
  global oSciTE
  
  ; 修复 shift+x 会导致输入法状态被切换的问题
  ; 原因是用了钩子的热键，例如 $+9:: 或 #If`r`n+9::
  ; 其它程序只能收到消息 {shift down}{shift up}
  ; 而没用钩子的热键，收到的消息则是 {shift down}{9 down}{9 up}{shift up}
  ; 所以通过发送 vkE8 这个无用按键，使得其它程序收到的消息变 {shift down}{vkE8 up}{shift up}
  ; 从而避免被识别为单按了 shift
  Send, {Blind}{vkE8 Up}
  
  GETFOCUS      := oSciTE.Msg(2381)
  GETSELECTIONS := oSciTE.Msg(2570)
  ; 没有获取焦点（可能焦点在查找框中），或输入是花括号，或是多光标模式下，则用按键方式模拟
  if (!GETFOCUS or (字符="{" or 字符="}") or GETSELECTIONS>1)
  {
    hex := Format("{1:X}", Ord(字符))
    Send, {U+%hex%}
    ; 这里也需要修复一次，这是因为当 shift 键被按下时
    ; 此时的 Send a 命令实际操作是 {shift up}{a down}{a up}{shift down}
    ; 所以之前发送的无用按键效果就没了，所以这里要再发送一次
    Send, {Blind}{vkE8 Up}
  }
  else
    oSciTE.ReplaceSel(字符)
  
  if (GETSELECTIONS=1 and (字符="(" or 字符="[" or 字符="{" or 字符=""""))
    补齐配对符号(字符)
}

; 改自 Adventure 3.0.4
补齐配对符号(Char)
{
  global oSciTE
  
  CurPos := oSciTE.GetCurPos
  
  ; GetCharAt = 2007
  PrevChar := Chr(oSciTE.Msg(2007, CurPos - 2))
  NextChar := Chr(oSciTE.Msg(2007, CurPos))
  
  NextWord := oSciTE.GetWord(CurPos + 1)
  If (NextWord != "" && NextWord != "`r`n") {
      Return
  }
  
  ; 圆括号
  If (Char == "(" && NextChar != ")") {
    oSciTE.InsertText(")")
    Send, {Left}
  
  ; 方括号
  } Else If (Char == "[" && NextChar != "]") {
    oSciTE.InsertText("]")
    Send, {Left}
  
  ; 花括号
  } Else If (Char == "{" && NextChar != "}") {
    
    BlankLine := Trim(oSciTE.GetLine, " `t`r`n`v`f")="{"
    PrevChars := oSciTE.GetTextRange(CurPos - 5, CurPos)
    ; 新建函数时的花括号
    If (RegExMatch(PrevChars, "\)\s?\r?\n?") or BlankLine) {
      Send, ^b
      Send, {Blind}{vkE8 Up}
    
    ; 普通花括号
    } Else {
      oSciTE.InsertText("}")
      Send, {Left}
    }
  
  ; 引号
  } Else If (Char == """" && NextChar != """" && (PrevChar == "" || PrevChar ~= "[\s,\(\[\=\:\n\rL]")) {
    oSciTE.InsertText("""")
    Send, {Left}
  }
  
  Send, {Blind}{vkE8 Up}
}