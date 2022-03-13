; https://docs.microsoft.com/en-us/windows/win32/learnwin32/windows-coding-conventions
; https://docs.microsoft.com/en-us/windows/win32/stg/coding-style-conventions
; https://docs.microsoft.com/en-us/windows/win32/winprog/windows-data-types

#NoEnv
#SingleInstance Force

FileRead, ahkType, type.json
ahkType := createAhkTypeFromJson(ahkType)

Gui +AlwaysOnTop

Gui Font, , 微软雅黑
Gui Add, Edit, x11 y39 w605 h176 vedit1
Gui Add, Button, x10 y224 w96 h24 gtranslate, 转换
Gui Add, Radio, x130 y225 w80 h23 gtranslate vradio1, 单行语法
Gui Add, Radio, x220 y225 w80 h23 gtranslate vradio2 +Checked, 多行语法
Gui Add, Edit, x11 y286 w605 h180 vedit2

Gui Add, Text, x360 y225 w100 h23 +0x202, Dll 名:
Gui Add, Edit, x470 y225 w146 h21 gtranslate vedit3

Gui Font, s9 cWhite Bold, Segoe UI
Gui Add, Picture, x11 y10 w606 h26, % "HBITMAP:" Gradient(606, 26)
Gui Add, Text, x11 y10 w606 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%MSDN Syntax
Gui Add, Picture, x11 y257 w606 h26, % "HBITMAP:" Gradient(606, 26)
Gui Add, Text, x11 y257 w606 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%AHK Syntax

Gui Show, w627 h480, AHK DllCall 终结者 ver. 1.0
return

GuiEscape:
GuiClose:
  ExitApp
return

translate:
  Gui, Submit, NoHide
  GuiControl, , edit2, % createDllCallTemplate(edit1, edit3, ahkType, radio2 ? true : false)
return

createDllCallTemplate(text, dllName, ahkType, multiLine:=true)
{
  obj := parseMsdnFunctionSyntax(text)
  
  ; 解析 MSDN 内容时的提示信息放首行
  info := obj.info
  
  ; 换行符
  CRLF := multiLine ? "`r`n" : ""
  
  ; 拼凑字符串 DllCall("xxx.dll\xxxx"
  template := Format("DllCall(""{}{}""{}", dllName ? dllName "\" : "", obj.funcName, CRLF)
  
  for k, v in obj.params
  {
    type    := ahkType[v.paramType]
    oriType := v.paramType
    name    := v.paramName
    oriName := v.paramName
    prefix  := v.hungarian
    
    if (type)
    {
      ; 类型为 Ptr
      if (type="Ptr")
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
          type := "Ptr"
          name := name
        }
      }
      
      ; 类型为非 Ptr Str WStr AStr
      if (type!="Ptr" and !InStr(type, "Str"))
      {
        ; 前缀为 lp p ，则类型应添加*，例如 ULONG *pAlgCount 则对应 UInt*
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
        ; 例如 BCRYPT_ALG_HANDLE  hAlgorithm
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
        
        info .= Format("; 参数 {} 的类型 {} 未知，但根据特征猜测应为 {} 。`r`n", oriName, oriType, type)
      }
      else
      {
        type := "Unknow"
        name := name
        
        info .= Format("; 参数 {} 的类型 {} 未知，需自行确定。`r`n", oriName, oriType)
      }
    }
    
    ; 拼凑字符串 , "Str", var
    template .= Format(", ""{}"", {}{}", type, name, CRLF)
  }
  
  if (!ahkType[obj.retType])
  {
    retType := "Unknow"
    
    info .= Format("; 返回值的类型 {} 未知，需自行确定。`r`n", obj.retType)
  }
  else
    retType := ahkType[obj.retType]
  
  ; 返回值是 Int 型，则可以省略
  if (retType="Int")
    template := RTrim(template, "`r`n") ")"
  else
    ; 拼凑字符串 , "Ptr")
    template .= Format(", ""{}"")", retType)
  
  return, info template
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
      ; 解析 int MessageBox( 这样的内容
      if (!RegExMatch(v, "([\w\s]+?)(\w+\s?)\(", OutputVar))
        MsgBox, 0x40030, , 第%A_Index%行内容解析失败。`n--------`n%v%`n--------
      
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
        ; 如果本行是省略号 ... ，则跳过
        if (StrReplace(v, ".")="")
        {
          ret.info .= "; 函数可能存在额外参数，需自行确定。`r`n"
          
          continue
        }
        else
          MsgBox, 0x40030, , 第%A_Index%行内容解析失败。`n--------`n%v%`n--------
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

; 注意，这里不能用 cjson ，会出现大小写错误的情况。
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include <CreateGradient>