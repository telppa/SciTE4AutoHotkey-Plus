智能库引用:
  用户库:=A_MyDocuments "\AutoHotkey\Lib\"
  标准库:=A_AhkPath "\..\Lib\"
  ; 在任意一个库目录中找到所需库文件，则简单引用就好。
  if (FileExist(用户库 "GlobalRegExMatch.ahk") or FileExist(标准库 "GlobalRegExMatch.ahk"))
  {
    库引用:="#Include <GlobalRegExMatch>"
  }
  else
  {
    ; 库目录里找不到所需库文件，则加载库文件内容到变量里。
    FileRead, 库引用1, %A_ScriptDir%\Lib\GlobalRegExMatch.ahk
    库引用:="; ------------------以下是库文件------------------`r`n" 库引用1
  }
return