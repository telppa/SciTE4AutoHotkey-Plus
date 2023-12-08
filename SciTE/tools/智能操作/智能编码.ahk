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
  fileEncodingDetected := {}
  SetTimer, 检测当前编码, 400
return

检测当前编码()
{
  global SciTE_Hwnd, codePageWarning, fileEncodingDetected
  
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
  ; 由于 2022.05.16 加入了编码探测功能，大部分文件都可以自动识别正确的编码。
  ; 综上所述，所有用户一般不需要手动更改任何关于 codepage 的设置。
  ; 一定要改的话，可按照自己的语言选择对应的 codepage 。英语等单字节编码语言，选 single byte 或 utf-8 ，简中选 GBK 等等。
  
  if (WinActive("ahk_id " SciTE_Hwnd))
  {
    path := oSciTE.CurrentFile
    SplitPath, path, , , ext
    
    if (!fileEncodingDetected.HasKey(path))
      fileEncodingDetected[path] := FileGetCodePageByBom(path)
    
    encoding := fileEncodingDetected[path]
    
    if (ext="ahk" and encoding!=65001)
    {
      if (!codePageWarning)
      {
        codePageWarning := true
        SetTimer, 对编码错误的AHK文件进行警告, 20
      }
      return
    }
  }
  
  关闭警告()
}

对编码错误的AHK文件进行警告()
{
  global SciTE_Hwnd
  
  btt("注意：当前文件编码不是 “UTF-8带BOM” 。`n"
    . "这意味着你可能会遇到文字乱码、功能失效、运行错误等各种匪夷所思的 Bug 。`n"
    . "强烈建议现在按 F2 将文件编码转换为 “UTF-8带BOM” 。"
    , A_ScreenWidth, A_ScreenHeight, , "Style4", {TargetHWND:SciTE_Hwnd, CoordMode:"Client"})
}

关闭警告()
{
  global codePageWarning
  
  codePageWarning := false
  SetTimer, 对编码错误的AHK文件进行警告, Off
  btt("")
}

更新fileEncodingDetected(path)
{
  global fileEncodingDetected
  
  fileEncodingDetected.Delete(path)
}

#If codePageWarning
F2::
AHK文件转为UTF8BOM()
{
  global fileEncodingDetected
  
  Critical
  
  fileEncodingDetected[oSciTE.CurrentFile] := 65001
  关闭警告()
  
  ; GETCODEPAGE = 2137 此处包括 65001 1200 1201
  if (oSciTE.SciMsg(2137)=65001)
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
    ; SCI_DOCLINEFROMVISIBLE = 2221
    firstDocLine := oSciTE.SciMsg(2221, firstVisibleLine)
    
    text := oSciTE.GetDocument()
    oSciTE.SetDocument(text, "65001")
    
    ; SCI_LINESCROLL = 2168
    oSciTE.SciMsg(2168, 0, firstDocLine)
  }
  
  ; IDM_ENCODING_UTF8 = 153
  oSciTE.SendDirectorMsg("menucommand:153")
}
#If

#Include %A_LineFile%\..\..\AHK 正则终结者\Lib\BTT.ahk
#Include %A_LineFile%\..\uchardet\uchardet.ahk