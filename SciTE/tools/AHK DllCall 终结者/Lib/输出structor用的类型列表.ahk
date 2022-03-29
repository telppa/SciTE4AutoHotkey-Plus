输出structor用的类型列表()
{
  ; 加载类型数据库
  FileRead, ahkType, type.json
  ahkType := createAhkTypeFromJson(ahkType)
  
  ; 反转 ahkType 的 key 和 value
  ahkType_flip := {}
  for k, v in ahkType
  {
    ; 不输出所有带*的类型例如 UInt*
    if (InStr(v, "*"))
      continue
    
    ; 不输出 TCHAR TBYTE HALF_PTR UHALF_PTR
    if k in TCHAR,TBYTE,HALF_PTR,UHALF_PTR
      continue
    
    ; 所有 Str AStr WStr 类型都转为 Ptr
    if (InStr(v, "Str"))
      v := "Ptr"
    
    ; 所有 UInt64 类型都转为 Int64
    if (InStr(v, "UInt64"))
      v := "Int64"
    
    if (ahkType_flip[v]="")
      ahkType_flip[v] := {}
    
    ahkType_flip[v].Push(k)
  }
  
  for k, v in ahkType_flip
  {
    out .= k "Types = """
    
    for k2, v2 in v
    {
      n++
      
      if (A_Index=v.MaxIndex())
        out .= v2 """"
      else
        out .= v2 ","
    }
    
    out .= "`r`n"
  }
  
  FileDelete, structor用的类型列表.txt
  FileAppend, %out%, structor用的类型列表.txt
  MsgBox, 0x40000, , 已生成 structor用的类型列表.txt`n`n共转换出%n%个类型
  return
}