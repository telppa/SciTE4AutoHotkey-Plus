arr:={}
loop, Read, list.txt
{
  ; 跳过注释
  if (SubStr(A_LoopReadLine, 1, 2)="; ")
    continue
  
  ; 跳过空行
  if (Trim(A_LoopReadLine, " `t`r`n`v`f")="")
    continue
  
  arr.Push(StrReplace(A_LoopReadLine, "typedef ", "", "", 1))
}

ret:={}, typeWithStar:={}

; 预处理，存储所有带*的类型
; 这是为了自动合并类似 PDWORD 到 *PDWORD
for k, v in arr
{
  o:=getType(v)
  type:=o.type
  
  if (InStr(type, "*"))
    typeWithStar[type] := true
}

; 首次处理。将 *PBYTE 之类的合并到 BYTE 中。
for k, v in arr
{
  o:=getType(v)
  type:=o.type
  parentType:=o.parentType
  
  ret[parentType, type]:=0
}

; 二次处理。将 BYTE 之类的合并到 unsigned char 中。
for k, v in arr
{
  o:=getType(v)
  type:=o.type
  parentType:=o.parentType
  
  if (ret.HasKey(type))
  {
    ret[parentType].Delete(type)
    ret[parentType, type]:=ret[type]
    ret.Delete(type)
  }
}

; 三次处理。将 __nullterminated CONST CHAR 之类的合并到 char 下，也就是让 __nullterminated CONST CHAR 与 CCHAR 同级。
; 这个列表只能手动维护。
obj:={"__nullterminated CONST CHAR" : "char"
    , "BOOL far"                    : "int"
    , "BYTE far"                    : "unsigned char"
    , "CONST CHAR"                  : "char"
    , "CONST WCHAR"                 : "wchar_t"
    , "INT_PTR"                     : "__int3264"
    , "LONGLONG"                    : "__int64"
    , "UINT_PTR"                    : "unsigned __int3264"
    , "ULONGLONG"                   : "unsigned __int64"}
; 加盐
for k, v in obj.Clone()
{
  obj[salt(k)]:=salt(v)
  obj.Delete(k)
}
; 移动
for k, v in obj
{
  ret[v, k]:=ret[k]
  ret.Delete(k)
}

; 四次处理。将 __int64 之类的合并到 Int64 中，这一步将绝大多数类型合并到了对应的 AHK 类型下。
; 这个列表只能手动维护。
obj:={"__int3264"          : "Ptr"
    , "__int64"            : "Int64"
    , "char"               : "Char"
    , "CONST void"         : "Ptr"
    , "const wchar_t"      : "UShort"
    , "double"             : "Double"
    , "float"              : "Float"
    , "int"                : "Int"
    , "long"               : "Int"
    , "short"              : "Short"
    , "signed __int64"     : "Int64"
    , "signed char"        : "Char"
    , "signed int"         : "Int"
    , "signed short"       : "Short"
    , "unsigned __int3264" : "UPtr"
    , "unsigned __int64"   : "UInt64"
    , "unsigned char"      : "UChar"
    , "unsigned int"       : "UInt"
    , "unsigned long"      : "UInt"
    , "unsigned short"     : "UShort"
    , "void"               : "Ptr"
    , "wchar_t"            : "UShort"}
; 加盐
for k, v in obj.Clone()
{
  obj[salt(k)]:=salt(v)
  obj.Delete(k)
}
; 移动
for k, v in obj
{
  ret[v, k]:=ret[k]
  ret.Delete(k)
}

; 移动 HANDLE 下的类目。
for k, v in ret[salt("HANDLE")]
  ret[salt("Ptr"), salt("void"), salt("*PVOID"), salt("HANDLE"), k]:=v
; 移动 DWORD 下的类目。
for k, v in ret[salt("DWORD")]
  ret[salt("UInt"), salt("unsigned long"), salt("DWORD"), k]:=v
; 移动 UCHAR *STRING 下的类目。
ret[salt("UChar"), salt("unsigned char"), salt("UCHAR"), salt("*STRING")]:=ret[salt("UCHAR"), salt("*STRING")]
; 因为根节点的 HANDLE DWORD UCHAR 已被移动到正确子节点，故这里直接删除。
ret.Delete(salt("HANDLE"))
ret.Delete(salt("DWORD"))
ret.Delete(salt("UCHAR"))
; 因为 TBYTE TCHAR 会在 createAhkTypeFromJson() 中单独处理，故这里直接删除。
ret.Delete(salt("TBYTE"))
ret.Delete(salt("TCHAR"))

; 导出并删除加盐部分
out:=json.dump(ret)
out:=RegExReplace(out, "\|\w+\""", """")
FileDelete, r:\type.json
FileAppend, % out, r:\type.json
ExitApp

getType(text)
{
  global typeWithStar
  
  ret:={}
  
  RegExMatch(text, " \S+\;", type)
  type:=LTrim(type, " ")
  type:=RTrim(type, ";")
  
  parentType:=RegExReplace(text, " \S+\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键。
  parentTypeWithSalt:=salt(parentType)
  parentTypeWithStarAndSalt:=salt("*" parentType)
  
  if (typeWithStar.HasKey(parentTypeWithStarAndSalt))
    ret.parentType:=parentTypeWithStarAndSalt
  else
    ret.parentType:=parentTypeWithSalt
  
  ret.type:=salt(type)
  
  return, ret
}

salt(text)
{
  return, text "|" Crypt.Hash.String("SHA1", text)
}

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include <Class_CNG>