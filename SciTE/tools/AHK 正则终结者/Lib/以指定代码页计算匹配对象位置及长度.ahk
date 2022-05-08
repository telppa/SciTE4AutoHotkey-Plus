; 此函数作用是计算捕获文本在 scintilla 中的坐标和长度，以便 scintilla 据此高亮
以指定代码页计算匹配对象位置及长度(str, regExMatchObject, encoding)
{
  ret := []
  
  ret["GlobalCount"] := regExMatchObject.MaxIndex()
  
  for i, v in regExMatchObject
  {
    ; 假设 str="abc" regex="a(b)(c)"
    ; 调试器里，可以看见这里 v.Count 值是3，也就是2个子模式+1个整体的数量
    ; 但是，在这里不管是用 v.Count() 或 v.Count 或 v["Count"] 取到的值却都是2
    ; 帮助里也说这里的 Count 是子模式数量，所以只能以实际为准。
    ret[i, "Count"] := v.Count
    
    loop, % v.Count+1
    {
      i2 := A_Index-1
      ; 将匹配位置之前的所有字符捕捉出来，并转存为 encoding 格式，以计算新位置和长度
      ; 因为 scintilla 中 encoding 不可能是 utf16 所以不用考虑 *2 的情况
      ret[i, "Pos",   i2] := StrPut(SubStr(str, 1, v.Pos[i2]-1), encoding)-1  ; 减掉 StrPut 返回值带的1个零终止符
      ret[i, "Len",   i2] := StrPut(v.Value[i2], encoding)-1
      ret[i, "Value", i2] := v.Value[i2]
      ret[i, "Name",  i2] := v.Name[i2]
    }
  }
  
  return, ret
}