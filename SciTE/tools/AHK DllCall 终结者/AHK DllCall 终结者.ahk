; https://docs.microsoft.com/en-us/windows/win32/learnwin32/windows-coding-conventions
; https://docs.microsoft.com/en-us/windows/win32/stg/coding-style-conventions
; https://docs.microsoft.com/en-us/windows/win32/winprog/windows-data-types
; https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dtyp/24637f2d-238b-4d22-b44d-fe54b024280c
; https://docs.microsoft.com/en-us/cpp/cpp/data-type-ranges

/* 隐藏功能
F1 帮助
F10 测试解析的例子
F11 输出批量测试结果
F12 输出structor用的类型列表
*/

#NoEnv
#NoTrayIcon
#SingleInstance Force
SetBatchLines, -1

SetWorkingDir, %A_ScriptDir%

; 多语言支持
gosub, multiLanguage

; 加载配置
gosub, loadSettings

; 设置图标必须放第一行，否则失效。
Menu, Tray, Icon, %A_ScriptDir%\DllCall.ico

; 界面
Gui +AlwaysOnTop +HwndhGUI -DPIScale

; DPI 缩放下的字号
fontSizeWithDpiScale := Round(9/(A_ScreenDPI/96))

Gui Font, s%fontSizeWithDpiScale%, 微软雅黑
Gui Add, Edit, x10 y40 w600 h180 gtranslateWithDelay vedit1

Gui Add, Button, x9 y229 w100 h24 gtranslate, %l_gui_1%
Gui Add, Radio, x130 y230 w80 h24 gtranslate voneLine +Checked%oneLine%, %l_gui_2%
Gui Add, Radio, x220 y230 w80 h24 gtranslate vmultiLine +Checked%multiLine%, %l_gui_3%
Gui Add, Text, x360 y230 w100 h24 +0x202, %l_gui_4%
Gui Add, Edit, x470 y230 w140 h22 gtranslateWithDelay vedit3

Gui Add, Edit, x10 y294 w600 h180 vedit2

Gui Add, Checkbox, x10 y476 w100 h24 +Checked%showError% gtranslate vshowError, %l_gui_5%
Gui Add, Checkbox, x110 y476 w100 h24 +Checked%showWarn% gtranslate vshowWarn, %l_gui_6%
Gui Add, Checkbox, x210 y476 w100 h24 +Checked%showInfo% gtranslate vshowInfo, %l_gui_7%
; 因为不同语言下文字长度差别较大，因此控件需要不同的布局
if (A_Language="0804")
{
  Gui Add, Checkbox, x310 y476 w100 h24 +Checked%createVariables% gtranslate vcreateVariables, %l_gui_8%
  Gui Add, Checkbox, x410 y476 w150 h24 +Checked%printRetValAndErrorLevel% gtranslate vprintRetValAndErrorLevel, %l_gui_9%
}
else
{
  Gui Add, Checkbox, x310 y476 w120 h24 +Checked%createVariables% gtranslate vcreateVariables, %l_gui_8%
  Gui Add, Checkbox, x440 y476 w200 h24 +Checked%printRetValAndErrorLevel% gtranslate vprintRetValAndErrorLevel, %l_gui_9%
}
Gui Font, s%fontSizeWithDpiScale% cWhite Bold, Segoe UI
Gui Add, Picture, x10 y10 w602 h26, % "HBITMAP:" Gradient(602, 26)
Gui Add, Text, x10 y10 w602 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%MSDN Syntax
Gui Add, Picture, x10 y264 w602 h26, % "HBITMAP:" Gradient(602, 26)
Gui Add, Text, x10 y264 w602 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%%A_Space%AHK Code

Gui Show, w620 h505, %l_gui_10% v5.0
return

GuiEscape:
GuiClose:
  gosub, saveSettings
  ExitApp
return

translateWithDelay:
  SetTimer, translate, -500
return

translate:
  Gui, Submit, NoHide
  GuiControl, , edit2, % createDllCallTemplate(edit1, edit3, multiLine, showError, showWarn, showInfo, createVariables, printRetValAndErrorLevel)
return

loadSettings:
  IniRead, oneLine, settings.ini, settings, oneLine, 0
  IniRead, multiLine, settings.ini, settings, multiLine, 1
  IniRead, showError, settings.ini, settings, showError, 1
  IniRead, showWarn, settings.ini, settings, showWarn, 1
  IniRead, showInfo, settings.ini, settings, showInfo, 1
  IniRead, createVariables, settings.ini, settings, createVariables, 1
  IniRead, printRetValAndErrorLevel, settings.ini, settings, printRetValAndErrorLevel, 0
return

saveSettings:
  IniWrite, %oneLine%, settings.ini, settings, oneLine
  IniWrite, %multiLine%, settings.ini, settings, multiLine
  IniWrite, %showError%, settings.ini, settings, showError
  IniWrite, %showWarn%, settings.ini, settings, showWarn
  IniWrite, %showInfo%, settings.ini, settings, showInfo
  IniWrite, %createVariables%, settings.ini, settings, createVariables
  IniWrite, %printRetValAndErrorLevel%, settings.ini, settings, printRetValAndErrorLevel
return

#If WinActive("ahk_id " hGUI)
F1::帮助()
F10::测试解析的例子()
F11::输出批量测试结果()
F12::输出structor用的类型列表()
#If

createDllCallTemplate(text, dllName, multiLine:=true, showError:=true, showWarn:=true, showInfo:=true, createVariables:=true, printRetValAndErrorLevel:=true)
{
  global l_tip_1, l_tip_2, l_tip_3, l_tip_4, l_tip_5, l_tip_6, l_tip_7, l_tip_8, l_errorlevel
  
  ; 输入内容为空则直接返回
  if (RegExReplace(text, "\s+")="")
    return
  
  ; 解析 msdn 的函数定义
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
  
  ; 缩进
  indent := multiLine ? "              " : ""
  
  ; 拼凑字符串 DllCall("xxx.dll\xxxx"
  dllName  := dllName ? dllName "\" : ""
  template := Format("ret := DllCall(""{}{}""{}", dllName, msdn.funcName, CRLF)
  
  ; 没有初值的话，会导致解析 LPSTRabcde GetCommandLineA(); 时，多行语法下错误信息的错位
  i := 1
  
  for k, v in msdn.params
  {
    type        := getAhkType(v.paramType)
    oriType     := v.paramType
    name        := v.paramName
    oriName     := v.paramName
    prefix      := v.hungarian
    prefixIsSus := v.isSus
    isOut       := v.isOut
    i           := A_Index+1
    
    if (type)
    {
      ; 类型为 Ptr 且原始类型名中包含 VOID （不区分大小写）字样，则传地址
      ; 通常包括但不限于 LPCVOID, LPVOID, PVOID, CONST void, void
      if (type="Ptr" and InStr(oriType, "VOID"))
      {
        type := "Ptr"
        name := "&" name
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
        ; 前缀为纯 h ，例如 BCRYPT_ALG_HANDLE hAlgorithm
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
        
        if (showWarn and prefixIsSus)
        {
          if (multiLine)
            oWarn[i] := Format(l_tip_7, type, "Unknown")
          else
            warn     .= Format(l_tip_8, name, oriType, type, "Unknown")
        }
        else if (showInfo)
        {
          if (multiLine)
            oInfo[i] := Format(l_tip_1)
          else
            info     .= Format(l_tip_2, oriName, oriType, type)
        }
      }
      else
      {
        type := "Unknown"
        name := name
        
        if (showError)
          if (multiLine)
            oError[i] := Format(l_tip_3, oriType)
          else
            error     .= Format(l_tip_4, oriName, oriType)
      }
    }
    
    ; 拼凑字符串 VarSetCapacity(var, , 0) 或 var=""
    if (createVariables)
      ; 所有 Str AStr WStr 类型，并且带 Out 的参数的，都用 VarSetCapacity(var, , 0)
      if (InStr(type, "Str") and isOut)
        varList .= Format("VarSetCapacity({}, , 0)`r`n", name)
      ; 所有 Ptr 类型，并且用&传地址的，都用 VarSetCapacity(var, , 0)
      else if (InStr(name, "&"))
        varList .= Format("VarSetCapacity({}, , 0)`r`n", oriName)
      ; 其它则用 var=""
      else
        varList .= name " := """"`r`n"
    
    ; 拼凑字符串 , "Str", var
    template .= Format("{}, ""{}"", {}{}", indent, type, name, CRLF)
  }
  
  retType := getAhkType(msdn.retType)
  ; 拼凑字符串 , "Ptr")
  if (retType="Int")
    template := RTrim(template, CRLF) ")"
  else
  {
    if (!retType)
    {
      retType := "Unknown"
      
      if (showError)
        if (multiLine)
          oError[i+1] := Format(l_tip_5, msdn.retType)
        else
          error       .= Format(l_tip_6, msdn.retType)
    }
    
    template .= Format("{}, ""{}"")", indent, retType)
  }
  
  ; 写入行末的提示信息
  for k, v in oError
    template := _lineAppend(template, v, k)
  for k, v in oWarn
    template := _lineAppend(template, v, k)
  for k, v in oInfo
    template := _lineAppend(template, v, k)
  
  if (printRetValAndErrorLevel)
    retValAndErrorLevel := "`r`n" l_errorlevel
  
  return, error warn info varList template retValAndErrorLevel
}

getAhkType(win32Type)
{
  static ahkType
  
  ; 加载类型数据库
  if (!IsObject(ahkType))
  {
    FileRead, ahkType, type.json
    ahkType := createAhkTypeFromJson(ahkType)
  }
  
  type := ahkType[win32Type]
  
  ; 没有在数据库中找到对应类型时，则删除一些无用的前后缀，之后再次尝试
  ; 例如 CONST BYTE -> BYTE
  if (!type)
  {
    win32Type := StrReplace(win32Type, "CONST ")
    win32Type := StrReplace(win32Type, "__nullterminated ")
    win32Type := StrReplace(win32Type, " far")
    win32Type := StrReplace(win32Type, " near")
    type := ahkType[win32Type]
  }
  
  ; 删除无用前后缀之后，依然没找到对应类型，则尝试添加或删除星号并再次进行尝试
  if (!type)
  {
    if (InStr(win32Type, "*"))
    {
      type := ahkType[StrReplace(win32Type, "*")]
      
      if (type)
        type := type "*"
    }
    else
    {
      type := ahkType[win32Type "*"]
      
      if (type)
        type := StrReplace(type, "*")
    }
  }
  
  ; 将两个以上*的类型转为 Ptr*
  StrReplace(type, "*", "", OutputVarCount)
  if (OutputVarCount>=2)
    type := "Ptr*"
  
  return, type
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
      "k*": {
        "l": 0
      },
      "m": {
        "n": 0
      }
    }
  },
  "Ptr": {
    "o*": {
      "p": {
        "q": 0
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
  ret := {}
  
  _forArray(JSON.Load(text), ret)
  
  /* 下面这些不是直接用 typedef 定义的，故无法处理。
  
  __stdcall
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
  /* 无类型，通常意味着此参数不填 。
  
  VOID
  */
  
  ; 添加 HMONITOR
  ; 系统版本大于等于 win2000 才有效。难以判断系统版本，故直接添加。
  ret.HMONITOR := "Ptr"
  
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
  ret.PTCHAR     := "Str"
  
  ; Str 类型
  ret["TCHAR*"]  := "Str"
  ret.LPTSTR     := "Str"
  ret.LPCTSTR    := "Str"
  ret.PTSTR      := "Str"
  ret.PCTSTR     := "Str"
  
  return, ret
}

/*
这是专门给 createAhkTypeFromJson() 用的

*/
_forArray(obj, ByRef ret, fromOutside:=true, haveAsterisk:=false)
{
  static rootValue
  
  if (fromOutside)
    rootValue := ""
  
  for k, v in obj
  {
    ; 带星号的节点及其后代节点，都将被标记
    flag := (InStr(k, "*") or haveAsterisk) and (k!="void*" and k!="CONST void*")
    
    ; 函数从外部被调用，说明现在处于根节点，则更新根节点的值
    if (fromOutside)
      rootValue := k
    ; 子节点迭代循环中
    else
    {
      ; key 中的 CHAR DOUBLE FLOAT INT LONG long* SHORT 会出现重复。
      ; 当 key 出现重复时，以现存的 key 和 value 为准，不进行覆盖。
      if (!ret.HasKey(k))
      {
        if (flag)
        {
          switch, rootValue
          {
            case "Char"  : ret[k] := "AStr"
            case "UShort": ret[k] := "WStr"
            default      : ret[k] := rootValue "*"
          }
        }
        else
          ret[k] := rootValue
      }
    }
    
    if IsObject(v)
      _forArray(v, ret, false, flag ? true : false)
  }
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
  global l_tip2_1, l_tip2_2, l_tip2_3, l_tip2_4, l_tip2_5
  
  ret := {}
  
  ; 删除开始的空白行
  text := RegExReplace(text, "^\s+")
  
  ; 分行解析
  for k, v in StrSplit(text, "`n", "`r")
  {
    ; 保存原始行信息用于记录在错误信息中
    oriLine := v
    
    ; 星号靠左
    v := RegExReplace(v, "\s+(\*+)", "$1 ")
    
    ; 首行提取函数名与返回值类型
    if (A_Index=1)
    {
      ; 解析 LRESULT LowLevelMouseProc( 这样的内容
      if (!RegExMatch(v, "([\w\s]*?)(\w+\s?)\(", OutputVar))
      {
        ret.error .= Format(l_tip2_1, A_Index, oriLine)
        ret.error .= l_tip2_2
        ret.error .= l_tip2_3
      }
      
      ; 提取 NET_API_STATUS NET_API_FUNCTION NetGroupEnum( 中的 NET_API_STATUS 和 NetGroupEnum
      ret.retType  := Trim(StrSplit(OutputVar1, " ")[1], " `t`r`n`v`f")
      ret.funcName := Trim(OutputVar2, " `t`r`n`v`f")
    }
    else
    {
      ; 判断参数是否是 Out 类型的
      if (!RegExMatch(v, "^\s*(_In_|_Out_)", inOrOut))
        RegExMatch(v, "^\s*\[.+?\]", inOrOut)
      
      ; 删除 _In_ 或 _Out_ 这样的内容
      v := RegExReplace(v, "^\s*(_In_|_Out_)")
      ; 删除 [out, optional] 这样的内容
      v := RegExReplace(v, "^\s*\[.+?\]")
      ; 删除前后空白
      v := Trim(v, " `t`r`n`v`f")
      
      ; 无内容
      if (v="")
        continue
      
      ; 函数结束的特征
      if (v=");")
        break
      
      ; 去掉末尾的 “,”
      v := RTrim(v, ",")
      ; 去掉末尾的 “);”
      if (SubStr(v, -1)=");")
        v := SubStr(v, 1, -2)
      
      ; 获取变量名
      if (!RegExMatch(v, "(\w+)$", OutputVar))
      {
        ; 如果本行包含省略号 ... ，则跳过
        if (RegExMatch(v, "\.{3,}"))
          ret.warn .= l_tip2_4
        else
          ret.error .= Format(l_tip2_5, A_Index, oriLine)
        
        continue
      }
      
      ; 分解出变量名和类型名
      name := OutputVar1
      type := SubStr(v, 1, -StrLen(OutputVar1))
      
      hungarianNotationIsSuspicious := false
      ; 提取变量名中的匈牙利命名规则
      ; 由于 MSDN 描述的混乱以及笔误等原因，即使在同一个函数中也可能存在仅部分使用匈牙利命名法
      ; 例如 SetWindowsHookExA 中，4个变量名分别为 idHook lpfn hmod dwThreadId ， hmod 明显有问题
      ; 所以这里先根据大写字母定位再提取
      if (RegExMatch(name, "[A-Z]"))
        RegExMatch(name, "^[a-z_]+", hungarian)
      else
      {
        ; 没有大写字母辅助定位的话，则尽量获取关键信息
        ; 注意长的字符串要放前面，这样才能 p 和 pp 都能被匹配
        RegExMatch(name, "^(lplp|lph|lp|pp|ph|p|h)", hungarian)
        ; 如果仅提取到 p 和 h 单个字母，则标记特征太短了，以便做出可能误判的提示
        if (hungarian="p" or hungarian="h")
          hungarianNotationIsSuspicious := true
      }
      
      ; 计次
      n++
      
      ret["params", n, "paramName"] := name
      ret["params", n, "paramType"] := Trim(type, " `t`r`n`v`f")
      ret["params", n, "hungarian"] := OutputVar1 ? hungarian : ""
      ret["params", n, "isOut"]     := InStr(inOrOut, "out") ? true : false
      ret["params", n, "isSus"]     := hungarianNotationIsSuspicious
    }
  }
  
  return, ret
}

; 不能用 cjson dump 否则 char 会被转为大写的 CHAR 。
#Include %A_ScriptDir%\Lib\JSON.ahk
#Include %A_ScriptDir%\Lib\CreateGradient.ahk
#Include %A_ScriptDir%\Lib\Language.ahk
#Include %A_ScriptDir%\Lib\测试解析的例子.ahk
#Include %A_ScriptDir%\Lib\输出批量测试结果.ahk
#Include %A_ScriptDir%\Lib\输出structor用的类型列表.ahk
#Include %A_ScriptDir%\Lib\帮助.ahk