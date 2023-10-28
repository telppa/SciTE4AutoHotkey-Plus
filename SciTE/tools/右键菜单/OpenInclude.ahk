#NoEnv
#NoTrayIcon
#SingleInstance Force
#Requires AutoHotkey v1.1.33+

if (!oSciTE := GetSciTEInstance())
  ExitApp

; 在目标文件中取得的相对路径 例如 abc\x.ahk 实际上是相对于目标文件目录的
; 将本文件的工作目录设为目标文件的目录，这样在本文件中将 abc\x.ahk 转为绝对路径时就与目标文件中进行转换的结果一致了
ScriptDir := oSciTE.ResolveProp("FileDir")
SetWorkingDir %ScriptDir%

CurrentLine := Trim(oSciTE.GetLine, " `t`r`n`v`f")
if (SubStr(CurrentLine, 1, 8) != "#Include")
{
  ; 在输出窗口显示文本
  oSciTE.Output("Not an #Include line!`n行内不含关键字 #Include ！`n")
}
else
{
  path := RegExReplace(CurrentLine, "(#Include|#IncludeAgain)( +)(\*i +)*")
  
  ; 如果 path 是 <xxxx> 形式的
  if (SubStr(path, 1, 1)="<" and SubStr(path, 0, 1)=">")
  {
    ; path = <test_1_2>, lib_name = test_1_2, lib_name2 = test
    ; #Include 支持 <lib> 和 <lib_func> 两种形式
    lib_name  := SubStr(path, 2, -1)
    lib_name2 := StrSplit(lib_name, "_", "", 2)[1]
    
    ; [local_lib, user_lib, standard_lib]
    lib_path  := [ScriptDir "\Lib\", A_MyDocuments "\AutoHotkey\Lib\", A_AhkPath "\..\Lib\"]
    
    ; 基础优先级 文件名 > 路径
    ; 路径优先级 local_lib > user_lib > standard_lib
    ; 例如 #Include <test_1_2> ，且存在 local_lib\test.ahk 和 user_lib\test_1_2.ahk
    ; 那么 user_lib\test_1_2.ahk 会被 include
    for k, v in lib_path
    {
      filepath := v lib_name ".ahk"
      if (FileExist(filepath) and !InStr(FileExist(filepath), "D"))
      {
        oSciTE.OpenFile(filepath)
        ExitApp
      }
    }
    
    for k, v in lib_path
    {
      filepath := v lib_name2 ".ahk"
      if (FileExist(filepath) and !InStr(FileExist(filepath), "D"))
      {
        oSciTE.OpenFile(filepath)
        ExitApp
      }
    }
    
    oSciTE.Output("Library not found!`n没有找到库！`n     Specifically: " path "`n")
  }
  else
  {
    filepath := StrReplace(path, "%A_ScriptDir%", oSciTE.ResolveProp("FileDir"))
    filepath := StrReplace(path, "%A_ScriptFullPath%", oSciTE.ResolveProp("FilePath"))
    filepath := StrReplace(path, "%A_ScriptName%", oSciTE.ResolveProp("FileNameExt"))
    filepath := StrReplace(path, "%A_LineFile%", oSciTE.ResolveProp("FilePath"))
    filepath := GetFullPathName(path)
    if (FileExist(filepath) and !InStr(FileExist(filepath), "D"))
    {
      oSciTE.OpenFile(filepath)
      ExitApp
    }
    
    oSciTE.Output("File not found!`n没有找到文件！`n     Specifically: " filepath "`n")
  }
}
ExitApp

GetFullPathName(path) {
    cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
    VarSetCapacity(buf, cc*(A_IsUnicode?2:1))
    DllCall("GetFullPathName", "str", path, "uint", cc, "str", buf, "ptr", 0, "uint")
    return buf
}

#Include %A_LineFile%\..\..\Lib\GetSciTEInstance.ahk