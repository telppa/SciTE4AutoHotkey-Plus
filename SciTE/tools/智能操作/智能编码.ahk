; 可以在 Toolbar.ahk 中添加回调函数 SciTE_OnOpened() SciTE_OnSwitched() 来完成相同的事情。
; 但这样做的问题在于：
  ; 1.已打开一个编码不对的文档，此时新建空白文档，提示难以消失。
  ; 2.启动 scite.exe 后默认打开的文档编码不对，不会提示。
  ; 3.窗口失焦后，提示难以消失。
; 也可以在 自动完成增强版.lua 中使用函数 checkCodepage() 来完成相同的事情。
; 但这样做的问题在于：
  ; 1.提示显示在全部文件共用的输出窗口中容易混淆。
  ; 2.不美观。

智能编码:
  fileTransformed := {}
  SetTimer, 检测当前编码, 400
return

检测当前编码()
{
  global SciTE_Hwnd, codePageWarning, fileTransformed
  
  ; scite 的处理逻辑是，有 bom 头的按头识别，无头的按配置文件中 code.page 值处理。
  ; code.page 值真正生效的配置文件是 _config.properties 。
  ; _config.properties 文件由 菜单栏——工具——设置 生成。
  ; 例1设置 codepage 为 GBK ，那么 utf8 无头与 ansi 都会按 GBK 处理，这时 oSciTE.SciMsg(2137) 读到的值就是 936 。
  ; 例2设置 codepage 为 utf-8 ，那么 utf8 无头与 ansi 都会按 utf8 处理，这时 oSciTE.SciMsg(2137) 读到的值就是 65001 。
  ; 例3设置 codepage 为 single byte ，那么 utf8 无头与 ansi 都会按 cp0 处理，这时 oSciTE.SciMsg(2137) 读到的值就是 0 。
  ; 例1、例2、例3中， utf8bom utf16le utf16be 因为有头，所以都能正确显示，读到的值都是 65001 。
  ; 例1中， utf8 无头被错当 GBK 处理，所以乱码。
  ; 例2中， ansi 被错当 utf8 处理，所以乱码。
  ; 例3中， uft8 无头被错当 cp0 处理，所以乱码。
  ; 特别注意：例3中， ansi 编码的文件显示起来看着正常，但当选择其中的双字节文字时（例如中文），就会出现乱码。
  ; 综上所述，所有的用户都需要按照自己的语言选择对应的 codepage 。
  ; 英语等单字节编码语言，选 single byte 或 utf-8 ，简中选 GBK ，日语选 Shift-JIS 。
  codePageWarning := false
  
  ; GETCODEPAGE = 2137
  if (WinActive("ahk_id " SciTE_Hwnd) and oSciTE.SciMsg(2137)!=65001)
  {
    path := oSciTE.CurrentFile
    SplitPath, path, , , ext
    
    if (ext="ahk")  ; 是 ahk 文件
    {
      codePageWarning := true
      SetTimer, 对编码错误的AHK文件进行警告, 20
    }
    else if (path)  ; 是普通文件
    {
      if (!fileTransformed.HasKey(path))  ; 没有转换过编码
      {
        fileTransformed[path] := true
        对显示为ANSI的文件进行转换(path)
      }
    }
  }
  
  if (!codePageWarning)
  {
    SetTimer, 对编码错误的AHK文件进行警告, Off
    btt("")
  }
}

对编码错误的AHK文件进行警告()
{
  global SciTE_Hwnd
  
  btt("注意：当前文件编码不是 “UTF-8带BOM” 。`n"
    . "这意味着你可能会遇到文字乱码、功能失效、运行错误等各种匪夷所思的 Bug 。`n"
    . "强烈建议现在按 F2 将文件编码转换为 “UTF-8带BOM” 。"
    , A_ScreenWidth, A_ScreenHeight, , "Style4", {TargetHWND:SciTE_Hwnd, CoordMode:"Client"})
}

对显示为ANSI的文件进行转换(path)
{
  encoding := FileGetEncoding(path)
  
  ; 显示为 ANSI 的文件经探测实际编码为 UTF8 无头
  if (encoding=65001)
  {
    ; 避免快速的切换标签导致对错误对象进行转码
    if (oSciTE.CurrentFile=path)
      oSciTE.SendDirectorMsg("menucommand:154")  ; IDM_ENCODING_UCOOKIE = 154
    else
      更新fileTransformed(path)
  }
}

更新fileTransformed(path)
{
  global fileTransformed
  
  fileTransformed.Delete(path)
}

#If codePageWarning
F2::
ANSI与UTF8转为UTF8BOM()
{
  encoding := FileGetEncoding(oSciTE.CurrentFile)
  
  if (encoding=65001)
  {
    ; SCI_GETLENGTH = 2006
    len := oSciTE.SciMsg(2006)
    ; 通过在文末插入并删除一个空格来创造保存点。
    oSciTE.InsertText(" ", len)
    ; SCI_DELETERANGE = 2645
    oSciTE.SciMsg(2645, len, 1)
  }
  else
  {
    ; SCI_GETFIRSTVISIBLELINE = 2152
    firstVisibleLine := oSciTE.SciMsg(2152)
    text := oSciTE.GetDocument()
    oSciTE.SetDocument(text, "65001")
    ; SCI_SETFIRSTVISIBLELINE = 2613
    oSciTE.SciMsg(2613, firstVisibleLine)
  }
  
  ; IDM_ENCODING_UTF8 = 153
  oSciTE.SendDirectorMsg("menucommand:153")
}
#If

#Include %A_LineFile%\..\..\AHK 正则终结者\Lib\BTT.ahk
#Include %A_LineFile%\..\Ude\Ude.ahk