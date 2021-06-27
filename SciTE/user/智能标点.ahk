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