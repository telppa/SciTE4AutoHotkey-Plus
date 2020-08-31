;此函数作用是计算捕获文本在 SCITE 中的坐标和长度,以便 SCITE 据此高亮
以指定代码页计算匹配对象位置及长度(String,VarIn,代码页="UTF-8")
{
  VarInTemp:=[]															;目前匹配对象无法被修改,因此只能创建一个副本,用于存储新的坐标和长度
  Loop,% VarIn.MaxIndex()
    {
      索引:=A_Index
      Loop,% VarIn[索引].Count()+1
        {
          PosVarOut:="",LenVarOut:=""												;重设 Pos 坐标,重设 Len 长度. 将匹配文本之前的所有字符捕捉出来,并转存为 UTF-8 格式,用于计算位置和长度
          VarInTemp[索引, "Pos", A_Index-1]:=StrPutVar(SubStr(String,1,VarIn[索引].Pos[A_Index-1]-1),PosVarOut,代码页)-1	;注意如果不直接使用 StrPut() 返回的成功写入的字符,而用 VarSetCapacity(Var,-1) 的方式,常常会出错
          VarInTemp[索引, "Len", A_Index-1]:=StrPutVar(VarIn[索引].Value[A_Index-1],LenVarOut,代码页)-1				;转换后的字符,注意最后一个字节总是为 0 ,所以需要减 1
          VarInTemp[索引, "Value", A_Index-1]:=VarIn[索引].Value[A_Index-1]
          VarInTemp[索引, "Name", A_Index-1]:=VarIn[索引].Name[A_Index-1]
        }
      VarInTemp[索引, "Count"]:=VarIn[索引].Count()
    }
  VarInTemp["GlobalCount"]:=索引
  return,VarInTemp
}

StrPutVar(string, ByRef var, encoding)
  {
    VarSetCapacity(var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))	;确定容量. StrPut 返回字符数,但 VarSetCapacity 需要字节数
    return StrPut(string, &var, encoding)								;复制或转换字符串
  }