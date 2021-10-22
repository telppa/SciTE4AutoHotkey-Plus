Class RegEx
{
  ; 返回值是数组对象，其每个值都是使用 O 选项返回的匹配对象。
  ; 可用 返回值.MaxIndex()="" 判断无匹配。
  ; 可用 返回值.1.Pos[0] 或 返回值[2].Len[1] 等方式获取每个匹配的各种信息（帮助搜索 “匹配对象” ）。
  GlobalMatch(Haystack, NeedleRegEx, StartingPos:=1)
  {
    ; 为正则添加 O 选项。
    NeedleRegEx:=this.AddOptions(NeedleRegEx, "O")
    Out:=[], Len:=StrLen(Haystack)
    ; RegExMatch() 返回值为0代表没有匹配，为空代表错误（例如正则表达式语法错误）。
    ; 表达式 “m)” 字符串 “” 能形成零宽匹配，因此需要验证 StartingPos<=Len 避免死循环。
    ; 注意第三个参数，是 ByRef 形式，所以无需引号。
    while (StartingPos<=Len and RegExMatch(Haystack, NeedleRegEx, OutputVar, StartingPos))
    {
      ; 匹配成功则设置下次匹配起点为上次成功匹配字符串的末尾。
      ; 这样可以使表达式 “ABCABC” ，匹配字符串 “ABCABCABCABC” 时返回2次结果。
      ; 表达式 “(?=10)” 字符串 “100.10” 能形成零宽匹配，返回的位置是1，宽度是0。
      ; 因此需要 Max(OutputVar.Len[0], 1) 将宽度最小值设为1，才能避免死循环。
      StartingPos:=OutputVar.Pos[0]+Max(OutputVar.Len[0], 1)
      Out.Push(OutputVar)
    }
    return, Out
  }

  ; 此函数作用等同 RegExMatch() ，主要意义是统一返回值格式便于处理。
  Match(Haystack, NeedleRegEx, StartingPos:=1)
  {
    ; 为正则添加 O 选项。
    NeedleRegEx:=this.AddOptions(NeedleRegEx, "O")
    Out:=[]
    if (RegExMatch(Haystack, NeedleRegEx, OutputVar, StartingPos))
      Out.Push(OutputVar)
    return, Out
  }

  ; 此函数用于给正则表达式添加选项。
  ; 添加的选项严格区分大小写！！！例如支持 (*ANYCRLF) 不支持 (*AnyCRLF) 。
  ; 选项将被确保存在且仅存在一个，不会出现 OimO)abc.* 这种情况。
  AddOptions(NeedleRegEx, Options*)
  {
    ; 因为存在 \Qim)\E 这样的免转义规则（表示原义的匹配字符 “im)” ）。
    ; 所以必须使用第一个右括号左边的参数去判断此右括号是否为选项分隔符。
    选项分隔符位置:=InStr(NeedleRegEx, ")")  ; 获取第一个右括号的位置。
    if (选项分隔符位置)
    {
      正则选项:=SubStr(NeedleRegEx, 1, 选项分隔符位置)
      正则本体:=SubStr(NeedleRegEx, 选项分隔符位置+1)
      
      Prev_StringCaseSense:=A_StringCaseSense
      StringCaseSense, On                   ; 大小写敏感。
      temp:=正则选项
      StringReplace, temp, temp, i, , All   ; 以下是正则表达式选项中可能存在的字符。
      StringReplace, temp, temp, m, , All
      StringReplace, temp, temp, s, , All
      StringReplace, temp, temp, x, , All
      StringReplace, temp, temp, A, , All
      StringReplace, temp, temp, D, , All
      StringReplace, temp, temp, J, , All
      StringReplace, temp, temp, U, , All
      StringReplace, temp, temp, X, , All
      StringReplace, temp, temp, P, , All
      StringReplace, temp, temp, O, , All
      StringReplace, temp, temp, S, , All
      StringReplace, temp, temp, C, , All
      StringReplace, temp, temp, `n, , All
      StringReplace, temp, temp, `r, , All
      StringReplace, temp, temp, `a, , All
      StringReplace, temp, temp, %A_Space%, , All
      StringReplace, temp, temp, %A_Tab%, , All
      StringCaseSense, %Prev_StringCaseSense%
    }
    
    if (!选项分隔符位置 or temp!=")")       ; temp 若包含除 ")" 之外的字符，则说明它不是选项分隔符。
    {
      正则选项:=")"                         ; 没有选项分隔符，则说明没有正则选项，所以创建一个空选项。
      正则本体:=NeedleRegEx
    }
    
    ; 将特殊选项 (*UCP)(*ANYCRLF)(*BSR_ANYCRLF) 去重。
    RegExMatch(正则本体, "^(\Q(*UCP)\E|\Q(*ANYCRLF)\E|\Q(*BSR_ANYCRLF)\E)+", 正则特殊选项)
    if (正则特殊选项)
    {
      if (InStr(正则特殊选项, "(*UCP)"), true)  ; 标记存在哪个特殊选项。true 表示区分大小写。
        flag1:=1
      if (InStr(正则特殊选项, "(*ANYCRLF)"), true)
        flag2:=1
      if (InStr(正则特殊选项, "(*BSR_ANYCRLF)"), true)
        flag3:=1
      
      ; 删除特殊选项，便于之后单独添加。
      正则本体:=RegExReplace(正则本体, "^(\Q(*UCP)\E|\Q(*ANYCRLF)\E|\Q(*BSR_ANYCRLF)\E)+", "", "", 1)
    }
    
    Prev_StringCaseSense:=A_StringCaseSense
    StringCaseSense, On
    for k, Option in Options
      switch, Option
      {
        case "(*UCP)":
          flag1:=1
        
        case "(*ANYCRLF)":
          flag2:=1
        
        case "(*BSR_ANYCRLF)":
          flag3:=1
        
        case "i","m","s","x","A","D","J","U","X","P","O","S","C","``n","``r","``a":
          if (!InStr(正则选项, Option, true))       ; 检查目前选项中是否存在待添加选项，确保其唯一。true 表示区分大小写。
            正则选项:=Option 正则选项
      }
    StringCaseSense, %Prev_StringCaseSense%
    
    ; 根据标记单独进行特殊选项添加，确保特殊选项唯一。
    if (flag3)
      正则本体:="(*BSR_ANYCRLF)" 正则本体
    if (flag2)
      正则本体:="(*ANYCRLF)" 正则本体
    if (flag1)
      正则本体:="(*UCP)" 正则本体
    
    return, 正则选项 正则本体
  }
}