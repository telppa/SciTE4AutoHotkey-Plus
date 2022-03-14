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
  
  /* 下面这些不是直接用 typedef 定义的，故无法处理。

  APIENTRY
  CALLBACK
  CONST
  UNICODE_STRING
  WINAPI

  POINTER_32
  POINTER_64
  POINTER_SIGNED
  POINTER_UNSIGNED
  */
  /* 64位编译是 Int64 ，32位编译是 Int 。跟 Ptr 完全一样，故不用处理。

  INT_PTR
  UINT_PTR
  LONG_PTR
  ULONG_PTR
  */
  /* 32位 CPU 是 Double ，64位 CPU 是 Int64 。难以判断 CPU 版本，故直接算作 Int64 。
  LONGLONG
  ULONGLONG
  */
  /* 无类型，通常意味着 Ptr 。
  
  VOID
  */
  
  ; 添加 double
  ret.double := "Double"
  
  ; 添加 HMONITOR
  ; 系统版本大于等于 win2000 才有效。难以判断系统版本，故直接添加。
  ret.HMONITOR := "Ptr"
  
  ; Str 类型
  ret.LPTSTR  := "Str"
  ret.LPCTSTR := "Str"
  ret.PTSTR   := "Str"
  ret.PCTSTR  := "Str"
  ; 从 Char 中分离出 AStr 类型
  ret.LPSTR   := "AStr"
  ret.LPCSTR  := "AStr"
  ret.PSTR    := "AStr"
  ret.PCSTR   := "AStr"
  ; 从 UShort 中分离出 WStr 类型
  ret.LPWSTR  := "WStr"
  ret.LPCWSTR := "WStr"
  ret.PWSTR   := "WStr"
  ret.PCWSTR  := "WStr"
  
  ; 64位编译是 Int ，32位编译是 Short 。
  ret.HALF_PTR   := "(A_PtrSize=8) ? ""Int""     : ""Short"""
  ret.PHALF_PTR  := "(A_PtrSize=8) ? ""Int*""    : ""Short*"""
  ret.UHALF_PTR  := "(A_PtrSize=8) ? ""UInt""    : ""UShort"""
  ret.PUHALF_PTR := "(A_PtrSize=8) ? ""UInt*""   : ""UShort*"""
  
  ; Unicode 编译是 UShort ，Ansi 编译是 UChar 。
  ret.TBYTE      := "(A_IsUnicode) ? ""UShort""  : ""UChar"""
  ret.PTBYTE     := "(A_IsUnicode) ? ""UShort*"" : ""UChar*"""
  
  ; Unicode 编译是 UShort ，Ansi 编译是 Char 。
  ret.TCHAR      := "(A_IsUnicode) ? ""UShort""  : ""Char"""
  ret.PTCHAR     := "(A_IsUnicode) ? ""UShort*"" : ""Char*"""
  
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
      ; 有星号前缀的转换时将被添加星号后缀，例如 *LPLONG => Int*
      appendAnAsterisk := SubStr(k, 1, 1)="*" ? "*" : ""
      
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

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\JSON.ahk