#NoEnv
#SingleInstance Force

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
FileDelete, r:\out.txt
FileAppend, %vv%, r:\out.txt
MsgBox,共转换出%z%个类型
ExitApp

/*
测试用JSON=
(
{
  "Int": {
    "a": {
      "b": 0,
      "c": 0,
      "d": {
        "e": 0
      },
      "f": {
        "g": 0
      },
      "h": 0,
      "i": 0
    },
    "j": {
      "*k": {
        "l": 0
      },
      "m": {
        "n": 0
      }
    }
  },
  "Ptr": {
    "*o": {
      "p": {
        "*q": 0
      },
      "r": {
        "s": 0
      },
      "t": 0
    },
    "u": {
      "v": {
        "w": 0
      },
      "x": {
        "y": 0
      }
    }
  }
}
)

lala:=createAhkTypeFromJson(测试用JSON)

*/
createAhkTypeFromJson(text)
{
  ret:={}
  
  _forArray(JSON.Load(text), ret)
  
  ; 以下是特殊类型
  ret.HALF_PTR   := "(A_PtrSize=8) ? ""Int""  : ""Short"""
  ret.PHALF_PTR  := "(A_PtrSize=8) ? ""Int""  : ""Short"""
  ret.UHALF_PTR  := "(A_PtrSize=8) ? ""UInt"" : ""UShort"""
  ret.PUHALF_PTR := "(A_PtrSize=8) ? ""UInt"" : ""UShort"""
  ret.TBYTE      := "(A_IsUnicode) ? ""WStr"" : ""UChar"""
  ret.PTBYTE     := "(A_IsUnicode) ? ""WStr"" : ""UChar"""
  ret.TCHAR      := "(A_IsUnicode) ? ""WStr"" : ""Char"""
  ret.PTCHAR     := "(A_IsUnicode) ? ""WStr"" : ""Char"""
  
  return, ret
}

/*
这是专门给 createAhkTypeFromJson() 用的

*/
_forArray(obj, ByRef ret)
{
  static rootValue := ""
  
  for k, v in obj
  {
    ; 根节点的值没被记录（也就是首次进入循环），或者现在就处于根节点
    ; 则更新根节点的值并标记状态 - 现在处于根节点
    if (!rootValue or isRoot)
    {
      rootValue := k
      isRoot := 1
    }
    
    ; 子节点迭代循环中
    if (rootValue and !isRoot)
    {
      ; 不会出现 Str* WStr* AStr* Ptr* 这4种类型
      typeBlackList := rootValue="Str" or rootValue="WStr" or rootValue="AStr" or rootValue="Ptr"
      appendAnAsterisk := (!typeBlackList and SubStr(k, 1, 1)="*") ? "*" : ""
      
      key := LTrim(k, "*")
      ; key 中的 CHAR FLOAT INT LONG *PVOID LPVOID SHORT PDWORD 会出现重复。
      ; 当 key 出现重复时，以现存的 key 和 value 为准，不进行覆盖。
      if (!ret.HasKey(key))
        ret[key] := rootValue appendAnAsterisk
    }
    
    if IsObject(v)
      _forArray(v, ret)
  }
  
  if (isRoot)
    rootValue := ""
}

; 注意，这里不能用 cjson ，会出现大小写错误的情况。
#Include %A_ScriptDir%\Lib\JSON.ahk