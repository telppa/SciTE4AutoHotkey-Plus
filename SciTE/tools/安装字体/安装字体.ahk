#NoEnv
#NoTrayIcon
#SingleInstance Force
#Requires AutoHotkey v1.1.33+
SetWorkingDir, %A_ScriptDir%

; 管理员权限运行
runwith("admin")

RegRead, 检查字体, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts, Microsoft YaHei Mono (TrueType)
if (检查字体!="Microsoft YaHei Mono.ttf")
{
  ; 安装字体
  try
  {
    FileCopy, Microsoft YaHei Mono.ttf, %A_WinDir%\Fonts
    RegWrite, REG_SZ, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts, Microsoft YaHei Mono (TrueType), Microsoft YaHei Mono.ttf
    btt("安装字体成功。`n重启 SciTE ，代码就会以 “雅黑 Mono” 字体显示。")
  }
  catch
  {
    btt("安装字体失败。`n请尝试手动安装字体 “SciTE\tools\安装字体\Microsoft YaHei Mono.ttf”`n不然代码显示会非常丑！")
  }
  
  Sleep, 3000
}

ExitApp

#Include %A_ScriptDir%\..\AHK 正则终结者\Lib\RunWith.ahk
#Include %A_ScriptDir%\..\AHK 正则终结者\Lib\BTT.ahk