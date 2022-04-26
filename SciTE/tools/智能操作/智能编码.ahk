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
  SetTimer, 检测当前编码, 1000
return

检测当前编码()
{
  global SciTE_Hwnd, codePageWarning
  
  ; GETCODEPAGE = 2137
  if (WinActive("ahk_id " . SciTE_Hwnd) and oSciTE.Msg(2137)!=65001 and 获取当前文件扩展名()="ahk")
  {
    codePageWarning := true
    SetTimer, 显示编码提示, 20
  }
  else if (codePageWarning)
  {
    codePageWarning := false
    SetTimer, 显示编码提示, Off
    btt("")
  }
}

获取当前文件扩展名()
{
  SplitPath, % oSciTE.CurrentFile, , , ext
  return, ext
}

显示编码提示()
{
  global SciTE_Hwnd
  
  btt("注意：当前文件编码不是 “UTF-8带BOM” 。`n"
    . "这意味着你可能会遇到文字乱码、功能失效、运行错误等各种匪夷所思的 Bug 。`n"
    . "强烈建议现在按 F2 将文件编码转换为 “UTF-8带BOM” 。"
    , A_ScreenWidth, A_ScreenHeight, , "Style4", {TargetHWND:SciTE_Hwnd, CoordMode:"Client"})
}

#If codePageWarning
F2::
转换编码为UTF8()
{
  ; IDM_ENCODING_UTF8 = 153
  oSciTE.SendDirectorMsg("menucommand:153")
  
  ; SCI_GETLENGTH = 2006
  len := oSciTE.Msg(2006)
  
  ; 通过在文末插入并删除一个空格来创造保存点。 SCI_DELETERANGE = 2645
  oSciTE.InsertText(" ", len)
  oSciTE.Msg(2645, len, 1)
}
#If

#Include %A_LineFile%\..\..\AHK 正则终结者\Lib\BTT.ahk