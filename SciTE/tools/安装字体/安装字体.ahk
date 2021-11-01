#NoEnv
#NoTrayIcon
#SingleInstance Force
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
    MsgBox 0x40040, 成功, 安装字体成功。`n重启SciTE，代码就会以 “雅黑Mono” 字体显示。
  }
  catch
  {
    Run, Microsoft YaHei Mono.ttf
    MsgBox 0x40030, 失败, 安装字体失败。`n请尝试手动安装字体 “SciTE\user\Microsoft YaHei Mono.ttf”`n不然代码显示会非常丑！
  }
}

ExitApp

#Include %A_ScriptDir%\..\AHK 正则终结者\Lib\RunWith.ahk