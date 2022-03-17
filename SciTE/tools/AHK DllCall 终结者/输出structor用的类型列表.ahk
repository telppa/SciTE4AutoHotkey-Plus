FileRead, ahkType, type.json
ahkType := createAhkTypeFromJson(ahkType)

aa:={}
for k, v in ahkType
{
  v:=RTrim(v, "*")
  
  if (aa[v]="")
    aa[v]:={}
  aa[v].Push(k)
}

for k, v in aa
{
  vv.=k "="
  
  for k2, v2 in v
  {
    z++
    vv.=v2 ","
  }
  
  vv.="`r`n"
}

FileDelete, structor用的类型列表.txt
FileAppend, %vv%, structor用的类型列表.txt
MsgBox,共转换出%z%个类型
ExitApp

#Include AHK DllCall 终结者.ahk