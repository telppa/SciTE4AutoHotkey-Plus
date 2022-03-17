; https://docs.microsoft.com/en-us/windows/win32/learnwin32/windows-coding-conventions
; https://docs.microsoft.com/en-us/windows/win32/stg/coding-style-conventions
; https://docs.microsoft.com/en-us/windows/win32/winprog/windows-data-types
; https://docs.microsoft.com/en-us/cpp/cpp/data-type-ranges

#NoEnv
#SingleInstance Force
SetBatchLines, -1

FileRead, ahkType, type.json
ahkType := createAhkTypeFromJson(ahkType)

Gui +AlwaysOnTop

Gui Font, , 微软雅黑
Gui Add, Edit, x10 y40 w600 h180 gtranslateWithDelay vedit1

Gui Add, Button, x9 y229 w100 h24 gtranslate, 转换
Gui Add, Radio, x130 y230 w80 h24 gtranslate vradio1, 单行语法
Gui Add, Radio, x220 y230 w80 h24 gtranslate vmultiLine +Checked, 多行语法
Gui Add, Text, x360 y230 w100 h24 +0x202, Dll 名:
Gui Add, Edit, x470 y230 w140 h22 gtranslateWithDelay vedit3

Gui Add, Edit, x10 y294 w600 h180 vedit2

Gui Add, Checkbox, x10 y476 w80 h24 +Checked gtranslate vshowError, 输出错误
Gui Add, Checkbox, x100 y476 w80 h24 +Checked gtranslate vshowWarn, 输出警告
Gui Add, Checkbox, x190 y476 w80 h24 +Checked gtranslate vshowInfo, 输出提示

Gui Font, s9 cWhite Bold, Segoe UI
Gui Add, Picture, x10 y10 w602 h26, % "HBITMAP:" Gradient(602, 26)
Gui Add, Text, x10 y10 w602 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%MSDN Syntax
Gui Add, Picture, x10 y264 w602 h26, % "HBITMAP:" Gradient(602, 26)
Gui Add, Text, x10 y264 w602 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%AHK Code

Gui Show, w620 h505, AHK DllCall 终结者 ver. 2.4
return

GuiEscape:
GuiClose:
  ExitApp
return

translateWithDelay:
  SetTimer, translate, -500
return

translate:
  Gui, Submit, NoHide
  GuiControl, , edit2, % createDllCallTemplate(edit1, edit3, ahkType, multiLine, showError, showWarn, showInfo)
return

createDllCallTemplate(text, dllName, ahkType, multiLine:=true, showError:=true, showWarn:=true, showInfo:=true)
{
  ; 输入内容为空则直接返回
  if (RegExReplace(text, "\s+")="")
    return
  
  msdn := parseMsdnFunctionSyntax(text)
  
  ; 放在文首和行末的提示信息
  if (showError)
    error := msdn.error, oError := {}
  if (showWarn)
    warn  := msdn.warn,  oWarn  := {}
  if (showInfo)
    info  := msdn.info,  oInfo  := {}
  
  ; 换行符
  CRLF := multiLine ? "`r`n" : ""
  
  ; 拼凑字符串 DllCall("xxx.dll\xxxx"
  dllName  := dllName ? dllName "\" : ""
  template := Format("ret := DllCall(""{}{}""{}", dllName, msdn.funcName, CRLF)
  
  for k, v in msdn.params
  {
    type    := ahkType[v.paramType]
    oriType := v.paramType
    name    := v.paramName
    oriName := v.paramName
    prefix  := v.hungarian
    i       := A_Index+1
    
    ; 没有在数据库中找到对应类型时，删除一些无用的前后缀
    ; 例如 CONST BYTE -> BYTE
    if (!type)
    {
      s := oriType
      s := StrReplace(s, "CONST ")
      s := StrReplace(s, " far")
      type := ahkType[s]
    }
    
    if (type)
    {
      ; 类型为 Ptr 或 Ptr*
      if (type="Ptr" or type="Ptr*")
      {
        ; 原始类型名中包含 VOID （不区分大小写）字样，则传地址
        ; 通常包括但不限于 LPCVOID, LPVOID, PVOID, CONST void, void
        if (InStr(oriType, "VOID"))
        {
          type := "Ptr"
          name := "&" name
        }
        ; 前缀为 lplp lph pp ph ，则类型应为 Ptr*
        else if (RegExMatch(prefix, "(lplp|lph|pp|ph)"))
        {
          type := "Ptr*"
          name := name
        }
        else
        {
          type := type
          name := name
        }
      }
      
      ; 类型为非 Ptr Ptr* Str WStr AStr
      if (!InStr(type, "Ptr") and !InStr(type, "Str"))
      {
        ; 前缀为 lp p ，则类型应添加*，例如 ULONG *pAlgCount 则对应 UInt*
        ; 前缀为 h 时必然是 Ptr 类型，所以这里不用考虑 h
        if (RegExMatch(prefix, "(lp|p)"))
        {
          ; 先删掉*再添加*，避免出现 UInt**
          type := RTrim(type, "*")
          type := type "*"
          name := name
        }
      }
    }
    ; 没有在数据库中找到对应类型
    else
    {
      ; 原始类型名以 LP 开头
      rule1 := SubStr(oriType, 1, 2)=="LP"
      ; 前缀包含 lp 或 p 或 h
      rule2 := RegExMatch(prefix, "(lp|p|h)")
      ; 原始类型名以 P 开头，同时前缀包含 lp 或 p 或 h
      ; 其实 rule3 是 rule2 的一个子集，单独写出来只是为了让逻辑更清晰
      rule3 := SubStr(oriType, 1, 1)=="P" and rule2
      
      if (rule1 or rule2 or rule3)
      {
        ; 例如 BCRYPT_ALG_HANDLE *phAlgorithm
        if (RegExMatch(prefix, "(lplp|lph|pp|ph)"))
        {
          type := "Ptr*"
          name := name
        }
        ; 例如 BCRYPT_ALG_HANDLE hAlgorithm
        else if (InStr(prefix, "h") and !InStr(prefix, "lp") and !InStr(prefix, "p"))
        {
          type := "Ptr"
          name := name
        }
        else
        {
          type := "Ptr"
          name := "&" name
        }
        
        if (showInfo)
          if (multiLine)
            oInfo[i] := Format("  `; 提示：类型未知，但根据特征猜测应为 {} 。", type)
          else
            info     .= Format("; 提示：参数 {} 的类型 {} 未知，但根据特征猜测应为 {} 。`r`n", oriName, oriType, type)
      }
      else
      {
        type := "Unknow"
        name := name
        
        if (showError)
          if (multiLine)
            oError[i] := "  `; 错误：类型未知，需自行确定。"
          else
            error     .= Format("; 错误：参数 {} 的类型 {} 未知，需自行确定。`r`n", oriName, oriType)
      }
    }
    
    ; 拼凑字符串 VarSetCapacity(var, 128, 0) 或 var=""
    if (InStr(name, "&"))
      varList .= Format("VarSetCapacity({}, 128, 0)`r`n", oriName)
    else
      varList .= name " := """"`r`n"
    
    ; 拼凑字符串 , "Str", var
    template .= Format(", ""{}"", {}{}", type, name, CRLF)
  }
  
  retType := ahkType[msdn.retType]
  ; 拼凑字符串 , "Ptr")
  if (retType="Int")
    template := RTrim(template, CRLF) ")"
  else
  {
    if (!retType)
    {
      retType := "Unknow"
      
      if (showError)
        if (multiLine)
          oError[i+1] := "  `; 错误：返回值类型未知，需自行确定。"
        else
          error       .= Format("; 错误：返回值的类型 {} 未知，需自行确定。`r`n", msdn.retType)
    }
    
    template .= Format(", ""{}"")", retType)
  }
  
  ; 写入行末的提示信息
  for k, v in oError
    template := _lineAppend(template, v, k)
  for k, v in oWarn
    template := _lineAppend(template, v, k)
  for k, v in oInfo
    template := _lineAppend(template, v, k)
  
  return, error warn info varList template
}

/*
这是专门给 createDllCallTemplate() 用的

*/
_lineAppend(str, sLine, nLine)
{
  oStr := StrSplit(str, "`n", "`r")
  oStr[nLine] .= sLine
  for k, v in oStr
    ret .= v "`r`n"
  return, RTrim(ret, "`r`n")
}

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
  
  ; 修正 PLCID
  ; 因为 PLCID 的父级 PDWORD 本身就是一个指针，所以 PLCID 没有*，所以导致解析错误，所以这里直接修正。
  ret.PLCID := "UInt*"
  
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
      ; 有星号前缀的转换时将被添加星号后缀，例如 *LPLONG -> Int*
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

/*
解析下面这种 MSDN 网站上的函数说明

BOOL CryptBinaryToStringA(
  [in]            const BYTE *pbBinary,
  [in]            DWORD      cbBinary,
  [in]            DWORD      dwFlags,
  [out, optional] LPSTR      pszString,
  [in, out]       DWORD      *pcchString
);

*/
parseMsdnFunctionSyntax(text)
{
  ret := {}
  
  ; 删除开始的空白行
  text := RegExReplace(text, "^\s+")
  
  ; 分行解析
  for k, v in StrSplit(text, "`n", "`r")
  {
    ; 首行提取函数名与返回值类型
    if (A_Index=1)
    {
      ; 删除 LRESULT CALLBACK LowLevelMouseProc( 中的 CALLBACK 字样
      v := RegExReplace(v, "CALLBACK")
      ; 解析 LRESULT LowLevelMouseProc( 这样的内容
      if (!RegExMatch(v, "([\w\s]*?)(\w+\s?)\(", OutputVar))
        ret.error .= Format("/* 错误：第{}行内容解析失败。`r`n--------`r`n{}`r`n--------`r`n*/`r`n", A_Index, v)
      
      ret.retType  := Trim(OutputVar1, " `t`r`n`v`f")
      ret.funcName := Trim(OutputVar2, " `t`r`n`v`f")
    }
    else
    {
      ; 删除 _In_ 或 _Out_ 这样的内容
      v := RegExReplace(v, "^\s*(_In_|_Out_)")
      ; 删除 [out, optional] 这样的内容
      v := RegExReplace(v, "^\s*\[.+?\]")
      ; 删除前后空白
      v := Trim(v, " `t`r`n`v`f")
      
      ; 函数结束的特征
      if (v=");")
        break
      
      ; 去掉末尾的 “,”
      v := RTrim(v, ",")
      ; 去掉末尾的 “);”
      if (SubStr(v, -1)=");")
        v := SubStr(v, 1, -2)
      
      ; 获取变量名
      if (!RegExMatch(v, "([\w\*]+)$", OutputVar))
      {
        ; 如果本行包含省略号 ... ，则跳过
        if (RegExMatch(v, "\.{3,}"))
          ret.warn .= "; 警告：函数可能存在额外参数，需自行确定。`r`n"
        else
          ret.error .= Format("/* 错误：第{}行内容解析失败。`r`n--------`r`n{}`r`n--------`r`n*/`r`n", A_Index, v)
        
        continue
      }
      
      ; 分解出变量名和类型名
      name := LTrim(OutputVar1, "*")
      type := SubStr(v, 1, -StrLen(OutputVar1))
      
      ; 提取变量名中的匈牙利命名规则
      ; 由于 MSDN 描述的混乱以及笔误等原因，即使在同一个函数中也可能存在仅部分使用匈牙利命名法
      ; 例如 SetWindowsHookExA 中，4个变量名分别为 idHook lpfn hmod dwThreadId ， hmod 明显有问题
      ; 所以这里先根据大写字母定位再提取
      if (RegExMatch(name, "[A-Z]"))
        RegExMatch(name, "^[a-z_]+", hungarian)
      else
        ; 没有大写字母辅助定位的话，则尽量获取关键信息
        ; 注意长的字符串要放前面，这样才能 p 和 pp 都能被匹配
        RegExMatch(name, "^(lplp|lph|lp|pp|ph|p|h)", hungarian)
      
      ; 计次
      n++
      
      ret["params", n, "paramName"] := name
      ret["params", n, "paramType"] := Trim(type, " `t`r`n`v`f")
      ret["params", n, "hungarian"] := OutputVar1 ? hungarian : ""
    }
  }
  
  return, ret
}

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include <CreateGradient>