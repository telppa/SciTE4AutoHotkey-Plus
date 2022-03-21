输出structor用的类型列表()
{
  ; 加载类型数据库
  FileRead, ahkType, type.json
  ahkType := createAhkTypeFromJson(ahkType)
  
  ; 反转 ahkType 的 key 和 value
  ahkType_flip := {}
  for k, v in ahkType
  {
    v := RTrim(v, "*")
    
    if (ahkType_flip[v]="")
      ahkType_flip[v] := {}
    
    ahkType_flip[v].Push(k)
  }
  
  for k, v in ahkType_flip
  {
    out .= k "="
    
    for k2, v2 in v
    {
      n++
      out .= v2 ","
    }
    
    out .= "`r`n"
  }
  
  FileDelete, structor用的类型列表.txt
  FileAppend, %out%, structor用的类型列表.txt
  MsgBox, 0x40000, , 已生成 structor用的类型列表.txt`n`n共转换出%n%个类型
  return
}