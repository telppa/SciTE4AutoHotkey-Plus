arr:={}
loop, Read, list.txt
{
  ; 跳过注释
  if (SubStr(A_LoopReadLine, 1, 2)="; ")
    continue
  
  ; 跳过空行
  if (Trim(A_LoopReadLine, " `t`r`n`v`f")="")
    continue
  
  ; 去掉 typedef 
  line:=StrReplace(A_LoopReadLine, "typedef ", "", "", 1)
  ; 星号靠左 将 FLOAT *PFLOAT; 变成 FLOAT* PFLOAT;
  line:=RegExReplace(line, "\s+\*", "* ")
  
  arr.Push(line)
}

ret:={}

; 首次处理。将 PBYTE 之类的合并到 BYTE* 中。
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

; 三次处理。将 BOOL far* 之类的移动到 BOOL 同级。
read_ret:=ret.Clone()
for k, v in read_ret
{
  pureType:=StrSplit(k, "|")[1]
  
  if ( InStr(pureType, "*") 
    or InStr(pureType, "CONST ")
    or InStr(pureType, "__nullterminated ")
    or InStr(pureType, " far") )
  {
    pureType:=StrReplace(pureType, "*")
    pureType:=StrReplace(pureType, "CONST ")
    pureType:=StrReplace(pureType, "__nullterminated ")
    pureType:=StrReplace(pureType, " far")
    pureType:=salt(pureType)
    
    ; 移动成功则删除原位置的数据
    if (findAndWrite(ret, pureType, k, v))
      ret.Delete(k)
  }
}

; 四次处理。将 INT_PTR* 之类的合并到 __int3264 下，也就是让 INT_PTR* 与 LONG_PTR 同级。
; 这个列表只能手动维护。
obj:={"INT_PTR*"  : "__int3264"
    , "UINT_PTR*" : "unsigned __int3264"
    , "UINT_PTR"  : "unsigned __int3264"}
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

; 五次处理。将 __int3264 之类的合并到 Ptr 中，这一步将绝大多数类型合并到了对应的 AHK 类型下。
; 这个列表只能手动维护。
obj:={"__int3264"          : "Ptr"
    , "__int64"            : "Int64"
    , "char"               : "Char"
    , "CONST void*"        : "Ptr"
    , "double"             : "Double"
    , "float"              : "Float"
    , "int*"               : "Int"
    , "int"                : "Int"
    , "long*"              : "Int"
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
    , "void*"              : "Ptr"}
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
  ret[salt("Ptr"), salt("void*"), salt("PVOID"), salt("HANDLE"), k]:=v
; 删除已被移动的根节点。
ret.Delete(salt("HANDLE"))
; 因为 TBYTE TCHAR 会在 createAhkTypeFromJson() 中单独处理，故这里直接删除。
ret.Delete(salt("TBYTE*"))
ret.Delete(salt("TCHAR*"))

; 导出并删除加盐部分
out:=json.dump(ret)
out:=RegExReplace(out, "\|\w+\""", """")
FileDelete, type.json
FileAppend, % out, type.json
ExitApp

getType(text)
{
  ret:={}
  
  RegExMatch(text, " (\S+)\;", type)
  parentType:=RegExReplace(text, " (\S+)\;", "")
  
  ; 不加盐的话，int 和 Int 会在 obj 中被视为相同的键。
  ret.parentType:=salt(parentType)
  ret.type:=salt(type1)
  
  return, ret
}

salt(text)
{
  return, text "|" Crypt.Hash.String("SHA1", text)
}

; 在 obj 中查找目标，找到则在找到的位置的同级处写入值
findAndWrite(obj, key_find, key_write, value_write, fromOutside:=1)
{
  static needToBreak
  
  if (fromOutside)
    needToBreak:=0
  
  if (obj.HasKey(key_find) and !fromOutside)
  {
    ; 写入到 obj
    obj[key_write]:=value_write
    needToBreak:=1
  }
  else
  {
    for k, v in obj
    {
      if (needToBreak)
        break
      
      if (IsObject(v))
        findAndWrite(v, key_find, key_write, value_write, 0)
    }
  }
  
  if (fromOutside and needToBreak)
    return, true
}

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\cJson.ahk
#Include <Class_CNG>