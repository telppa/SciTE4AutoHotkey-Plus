; 在代码区，标点总是英文。
; 在注释区，标点由输入法控制。
; BUG：
  ; 1.在行注释的行首处，中文输入法状态下，输入一个英文字，比如 “f” ，然后用 “Shift” 键让英文上屏，这时获取到的高亮状态是不正确的。
  ; 不过由于随便再动一下光标就又能获取到正确高亮状态了，所以这个 bug 几乎没任何影响。
  
/*为什么要用这个 SetTimer 而不是直接在 #If 中判断呢？
  因为在 #If 中用表达式进行判断，会触发一个错误，大致与 SendMessage 有关。
  以下是错误重现代码。
  
  oSciTE := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}")
  aaaa()
  return
  
  #If aaaa()
    c::ToolTip,lalala
  #If
  
  aaaa(){
    global oSciTE
    MsgBox, % oSciTE.Version
    MsgBox, % oSciTE.GetCurPos
  }
*/
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

#If style="代码" and WinActive("ahk_id " SciTE_Hwnd) and !WinExist("ahk_group IME_CN")
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
  style := oSciTE.GetStyle()
  
  if style in 1,2,6  ; 理论上区域20也是可以有中文标点的，但是这会造成输入一个英文双引号后，第二个英文双引号很难输出来，所以只有1、2、6。
    return, "注释"   ; 在注释区，标点由输入法自行决定。
  else
    return, "代码"   ; 在代码区，标点始终为英文。
}

/*
2022.05.03 对以下13款输入法进行测试：
  百度拼音 5.8.4.8
  百度五笔 1.2.0.67
  QQ拼音   6.6.6304.400
  QQ五笔   2.4.629.400
  搜狗拼音 7.9.0.7504
  搜狗五笔 5.5.0.2552
  微软拼音 14.0.6119.5000
  微软五笔 14.0.6119.5000
  2345拼音 7.7.0.8283
  手心拼音 2.7.0.1702
  讯飞拼音 3.0.0.1727
  谷歌拼音 2.7.25.128
  必应拼音 1.6.302.6
测试共两项内容：
  1. scite 中对智能标点功能进行测试。
  2. 其它编辑器中单独使用3种绕过输入法的 Send 命令进行测试。
以下是结论：
  在 scite 中直接用编辑器插入字符，可以完美绕过全部输入法，但却无法激活花括号 {} 的自动缩进。
  Send {Text}) 与 Send {U+29} 表现完全相同，并存在以下问题。
    百度五笔 谷歌拼音 必应拼音 3款输入法在脚本测试中无法绕过中文状态输入英文标点。
    谷歌拼音 必应拼音 2款输入法在 scite 实测中无法绕过中文状态输入英文标点。（很奇怪百度怎么在这里绕过去了）
  Send {Asc 41} 方式绕得过百度五笔 谷歌拼音 必应拼音，但因其原理是按住 Alt 再按 41，所以会额外激活如 Alt+4 的快捷键。
  {vkE8 Up} 会导致 微软拼音 微软五笔 2345拼音 讯飞拼音 按住 Shift 键输入标点时中英状态发生变化。
  {vkE8 Up} 改 {vkE8} 后只有 2345拼音 依然变化。
 */
发送原义字符(字符)
{
  ; 修复 shift+x 会导致输入法状态被切换的问题
  ; 原因是用了钩子的热键，例如 $+9:: 或 #If`r`n+9::
  ; 其它程序只能收到消息 {shift down}{shift up}
  ; 而没用钩子的热键，收到的消息则是 {shift down}{9 down}{9 up}{shift up}
  ; 所以通过发送 vkE8 这个无用按键，使得其它程序收到的消息变 {shift down}{vkE8 down}{vkE8 up}{shift up}
  ; 从而避免被识别为单按了 shift
  Send, {Blind}{vkE8}
  
  GETFOCUS      := oSciTE.SciMsg(2381)
  GETSELECTIONS := oSciTE.SciMsg(2570)
  ; 没有获取焦点（可能焦点在查找框中），或输入是花括号或句号，或是多光标模式下，则用按键方式模拟
  ; 花括号与句号需要 自动完成增强版.lua 中的 handleChar() 进行处理，所以必须用按键方式去模拟
  if (!GETFOCUS or (字符="{" or 字符="}" or 字符=".") or GETSELECTIONS>1)
  {
    ; 虽然 U+ 与 {Text} 方式个人测试表现完全相同，但 kawvin 却在 2022.04.26 反馈前者让他无法输入标点，后者可以。
    ; 所以干脆换回 {Text} 方式。
    Send, {Text}%字符%
    
    ; 这里也需要修复一次，这是因为当 shift 键被按下时
    ; 此时的 Send a 命令实际操作是 {shift up}{a down}{a up}{shift down}
    ; 所以之前发送的无用按键效果就没了，所以这里要再发送一次
    Send, {Blind}{vkE8}
  }
  else
    oSciTE.ReplaceSel(字符)
  
  if (GETSELECTIONS=1 and (字符="(" or 字符="[" or 字符="{" or 字符=""""))
    补齐配对符号(字符)
}

; 改自 Adventure 3.0.4
补齐配对符号(Char)
{
  CurPos := oSciTE.GetCurPos
  
  ; GetCharAt = 2007
  PrevChar := Chr(oSciTE.SciMsg(2007, CurPos - 2))
  NextChar := Chr(oSciTE.SciMsg(2007, CurPos))
  
  NextWord := oSciTE.GetWord(CurPos + 1)
  If (NextWord != "" && NextWord != "`r`n") {
      Return
  }
  
  ; 圆括号
  If (Char == "(" && NextChar != ")") {
    oSciTE.InsertText(")")
  
  ; 方括号
  } Else If (Char == "[" && NextChar != "]") {
    oSciTE.InsertText("]")
  
  ; 花括号
  } Else If (Char == "{" && NextChar != "}") {
    
    BlankLine := Trim(oSciTE.GetLine, " `t`r`n`v`f")="{"
    PrevChars := oSciTE.GetTextRange(CurPos - 5, CurPos)
    ; 新建函数时的花括号
    If (RegExMatch(PrevChars, "\)\s?\r?\n?") or BlankLine) {
      ctrlB()
    
    ; 普通花括号
    } Else {
      oSciTE.InsertText("}")
    }
  
  ; 引号
  } Else If (Char == """" && NextChar != """" && (PrevChar == "" || PrevChar ~= "[\s,\(\[\=\:\n\rL]")) {
    oSciTE.InsertText("""")
  }
}