输出全部类型列表()
{
  ; 加载类型数据库
  FileRead, ahkType, type.json
  ahkType := createAhkTypeFromJson(ahkType)
  
  FileDelete, 全部类型列表.txt
  for k, v in ahkType
  {
    n++
    out .= Format("{}={}`r`n", k, v)
  }
  FileAppend, %out%, 全部类型列表.txt
  
  MsgBox, 0x40000, , 已生成 全部类型列表.txt`n`n共转换出%n%个类型
  return
}