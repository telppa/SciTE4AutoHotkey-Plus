arr:={}
loop, Read, list.txt
{
  if (A_LoopReadLine="-----------------------------------------------")
    break
  
  arr.Push(StrReplace(A_LoopReadLine, "typedef ", "", "", 1))
}

ret:={}

; 首次处理。将 *PBYTE 之类的合并到 BYTE 中。
for k, v in arr
{
  RegExMatch(v, " \S+\;", type)
  type:=LTrim(type, " ")
  type:=RTrim(type, ";")
  
  parentType:=RegExReplace(v, " \S+\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键。
  parentTypeWithSalt:=parentType "|" Crypt.Hash.String("SHA1", parentType)
  
  ret[parentTypeWithSalt, type]:=0
}

; 二次处理。将 BYTE 之类的合并到 unsigned char 中。
for k, v in arr
{
  RegExMatch(v, " \S+\;", type)
  type:=LTrim(type, " ")
  type:=RTrim(type, ";")
  
  parentType:=RegExReplace(v, " \S+\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键。
  parentTypeWithSalt:=parentType "|" Crypt.Hash.String("SHA1", parentType)
  
  typeWithSalt:=type "|" Crypt.Hash.String("SHA1", type)
  if (ret.HasKey(typeWithSalt))
  {
    ret[parentTypeWithSalt].Delete(type)
    ret[parentTypeWithSalt, type]:=ret[typeWithSalt]
    ret.Delete(typeWithSalt)
  }
}

; 三次处理。将 __nullterminated CONST CHAR 之类的合并到 char 下，也就是让 __nullterminated CONST CHAR 与 CCHAR 同级。
; 这个列表只能手动维护。
obj:={"__nullterminated CONST CHAR" : "char"
    , "BOOL far"                    : "int"
    , "BYTE far"                    : "unsigned char"
    , "CONST CHAR"                  : "char"
    , "CONST WCHAR"                 : "wchar_t"
    , "LONGLONG"                    : "__int64"
    , "LPVOID"                      : "void"
    , "ULONGLONG"                   : "unsigned __int64"}
; 加盐
for k, v in obj.Clone()
{
  obj[k "|" Crypt.Hash.String("SHA1", k)]:=v "|" Crypt.Hash.String("SHA1", v)
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
obj:={"__int64"          : "Int64"
    , "char"             : "Char"
    , "CONST void"       : "Ptr"
    , "float"            : "Float"
    , "INT_PTR"          : "Ptr"
    , "int"              : "Int"
    , "LONG_PTR"         : "Ptr"
    , "long"             : "Int"
    , "PVOID"            : "Ptr"
    , "short"            : "Short"
    , "signed __int64"   : "Int64"
    , "signed char"      : "Char"
    , "signed int"       : "Int"
    , "signed short"     : "Short"
    , "UINT_PTR"         : "UPtr"
    , "ULONG_PTR"        : "UPtr"
    , "unsigned __int64" : "UInt64"
    , "unsigned char"    : "UChar"
    , "unsigned int"     : "UInt"
    , "unsigned long"    : "UInt"
    , "unsigned short"   : "UShort"
    , "void"             : "Ptr"
    , "wchar_t"          : "UShort"}
; 加盐
for k, v in obj.Clone()
{
  obj[k "|" Crypt.Hash.String("SHA1", k)]:=v "|" Crypt.Hash.String("SHA1", v)
  obj.Delete(k)
}
; 移动
for k, v in obj
{
  ret[v, k]:=ret[k]
  ret.Delete(k)
}

; 删除加盐的部分重新导入。
out:=json.dump(ret)
out:=RegExReplace(out, "\|\w+\""", """")
ret:=json.load(out)

; 移动 HANDLE 下的类目。
for k, v in ret["HANDLE"]
  ret["Ptr", "PVOID", "HANDLE", k]:=v
; 移动 PDWORD 下的类目。
ret["UInt", "unsigned long", "DWORD", "PDWORD"]:=ret["PDWORD"]
; 因为根节点的 HANDLE PDWORD 已被移动到正确子节点，故这里直接删除。
ret.Delete("HANDLE")
ret.Delete("PDWORD")
; 因为 TBYTE TCHAR 会在 createAhkTypeFromJson() 中单独处理，故这里直接删除。
ret.Delete("TBYTE")
ret.Delete("TCHAR")

out:=json.dump(ret)
FileDelete, r:\type.json
FileAppend, % out, r:\type.json
ExitApp

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include <Class_CNG>