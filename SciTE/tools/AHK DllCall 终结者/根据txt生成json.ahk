arr:={}
loop, Read, list1.txt
{
  if (A_LoopReadLine="-----------------------------------------------")
    break
  
  arr.Push(StrReplace(A_LoopReadLine, "typedef ", "", "", 1))
}

ret:={}

; 首次处理。将 *PBYTE 之类的合并到 BYTE 中
for k, v in arr
{
  RegExMatch(v, " \S+\;", type)
  type:=LTrim(type, " ")
  type:=RTrim(type, ";")
  
  parentType:=RegExReplace(v, " \S+\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键
  parentTypeWithSalt:=parentType "|" Crypt.Hash.String("SHA1", parentType)
  
  ret[parentTypeWithSalt, type]:=0
}

; 二次处理。将 BYTE 之类的合并到 unsigned char 中
for k, v in arr
{
  RegExMatch(v, " \S+\;", type)
  type:=LTrim(type, " ")
  type:=RTrim(type, ";")
  
  parentType:=RegExReplace(v, " \S+\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键
  parentTypeWithSalt:=parentType "|" Crypt.Hash.String("SHA1", parentType)
  
  typeWithSalt:=type "|" Crypt.Hash.String("SHA1", type)
  if (ret.HasKey(typeWithSalt))
  {
    ret[parentTypeWithSalt].Delete(type)
    ret[parentTypeWithSalt, type]:=ret[typeWithSalt]
    ret.Delete(typeWithSalt)
  }
}

; 三次处理。将 __nullterminated CONST CHAR 之类的合并到 char 中
arr:={}
loop, Read, list2.txt
{
  if (A_LoopReadLine="-----------------------------------------------")
    break
  
  str:=StrSplit(A_LoopReadLine, "|")
  typeWithSalt:=str[1] "|" Crypt.Hash.String("SHA1", str[1])
  parentTypeWithSalt:=str[2] "|" Crypt.Hash.String("SHA1", str[2])
  arr[typeWithSalt]:=parentTypeWithSalt
}
for k, v in arr
{
  ret[v, k]:=ret[k]
  ret.Delete(k)
}

; 四次处理。将 __int64 之类的合并到 Int64 中
arr:={}
loop, Read, list3.txt
{
  if (A_LoopReadLine="-----------------------------------------------")
    break
  
  str:=StrSplit(A_LoopReadLine, "|")
  typeWithSalt:=str[1] "|" Crypt.Hash.String("SHA1", str[1])
  parentTypeWithSalt:=str[2] "|" Crypt.Hash.String("SHA1", str[2])
  arr[typeWithSalt]:=parentTypeWithSalt
}
for k, v in arr
{
  ret[v, k]:=ret[k]
  ret.Delete(k)
}

out:=json.dump(ret)
; 删除加盐的部分
out:=RegExReplace(out, "\|\w+\""", """")
FileDelete, r:\type.json
FileAppend, % out, r:\type.json

; 之后就只能手动进行剩下的合并了
ExitApp

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include <Class_CNG>