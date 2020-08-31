;管理员权限运行
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}
;安装字体
SetWorkingDir, %A_ScriptDir%
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