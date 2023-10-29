输出全部类型列表()
{
  ; 加载类型数据库
  FileRead ahkType, Res\type.json
  ahkType := createAhkTypeFromJson(ahkType)
  
  for k, v in ahkType
  {
    n++
    out .= Format("{}={}`r`n", k, v)
  }
  
  FileCreateDir Output
  FileDelete Output\全部类型列表.txt
  FileAppend %out%, Output\全部类型列表.txt, UTF-8
  MsgBox, 0x40000, , 已生成 全部类型列表.txt`n`n共转换出%n%个类型
  return
}