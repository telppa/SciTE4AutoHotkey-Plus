;此函数和 RegExMatch() 有两个区别
;1.仅 3 个参数,第三个参数为 StartingPosition
;2.返回值是数组对象,其每个值都是使用 "O" 选项返回的匹配对象
;可用 返回值.1.Pos[0] 或 返回值[2].Len[1] 等方式获取每个捕获的各种信息. 具体可以获取到什么,请参考 "匹配对象"
;可用 返回值.MaxIndex()="" 判断无匹配
GlobalRegExMatch(Haystack,NeedleRegEx,StartingPosition)
  {
    ObjOut:=[]
    NeedleRegEx:=正则添加O选项(NeedleRegEx)					;为正则添加 "O" 选项
    Loop
      {
        RegExMatch(Haystack,NeedleRegEx,UnquotedOutputVar,StartingPosition)	;注意第三个参数,无需引号却实现了添加引号后的效果…… 混乱的根源就在这些地方……
        If (UnquotedOutputVar.Value[0]="")					;不能直接使用该函数返回值判断是否找到内容. 在表达式为 "0*$" ,待匹配字串为 "100.101" ,会出现返回 位置8 , 长度0 的错误
            break								;匹配值为空(隐含函数失败),则退出循环避免死循环
        StartingPosition:=UnquotedOutputVar.Pos[0]+UnquotedOutputVar.Len[0]	;匹配成功则设置下次匹配起点为上次成功匹配字符串的末尾. 这样可以使表达式 "ABCABC" ,匹配字符串 "ABCABCABCABC" 时返回 2 次结果
        ObjOut.Insert(UnquotedOutputVar)
      }
    return,ObjOut
  }

;此函数作用等同 RegExMatch() ,主要意义是统一返回值格式,便于处理
RegExMatchLikeGlobal(Haystack,NeedleRegEx,StartingPosition)
  {
    ObjOut:=[]
    NeedleRegEx:=正则添加O选项(NeedleRegEx)					;为正则添加 "O" 选项
    RegExMatch(Haystack,NeedleRegEx,UnquotedOutputVar,StartingPosition)
    If (UnquotedOutputVar.Value[0]<>"")
        ObjOut.Insert(UnquotedOutputVar)
    return,ObjOut
  }

;此函数用于给正则表达式添加 "O" 选项,使得输出变量为匹配对象,便于分析处理
;返回值将确保 "O" 选项存在并仅存一个,不会出现 OimO)abc.* 这种情况
;输入到此函数中的正则表达式为不带引号的正则,可包含选项. 例如 im)abc.* 将被支持. "im)123.*" 不被支持
正则添加O选项(NeedleRegEx)
{
  选项分隔符位置:=InStr(NeedleRegEx,")")
  If (选项分隔符位置<>0)
    {
      正则选项:=SubStr(NeedleRegEx,1,选项分隔符位置)
      正则:=SubStr(NeedleRegEx,选项分隔符位置+1)
      StringCaseSense, On			;大小写敏感
      StringReplace, temp, 正则选项, i, , All	;以下是正则表达式选项中可能存在的字符
      StringReplace, temp, temp, m, , All
      StringReplace, temp, temp, s, , All
      StringReplace, temp, temp, x, , All
      StringReplace, temp, temp, A, , All
      StringReplace, temp, temp, D, , All
      StringReplace, temp, temp, J, , All
      StringReplace, temp, temp, U, , All
      StringReplace, temp, temp, X, , All
      StringReplace, temp, temp, P, , All
      StringReplace, temp, temp, S, , All
      StringReplace, temp, temp, C, , All
      StringReplace, temp, temp, O, , All
      StringReplace, temp, temp, `n, , All
      StringReplace, temp, temp, `r, , All
      StringReplace, temp, temp, `a, , All
      StringReplace, temp, temp, %A_Space%, , All
      StringReplace, temp, temp, %A_Tab%, , All
      StringCaseSense, Off
      If (temp=")")				;若最后结果仅剩闭括号 ")" ,说明这个括号的作用是选项分隔符
        {
          If (InStr(正则选项,"O",1)<>0)		;大小写敏感的检查选项中是否存在 "O" 选项,需确保其存在并唯一
              return,NeedleRegEx		;存在选项 "O" 则直接返回
          Else
              return,"O" . 正则选项 . 正则	;添加选项 "O" 并返回
        }
    }
  return,"O)" . NeedleRegEx
}