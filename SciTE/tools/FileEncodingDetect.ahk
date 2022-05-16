#NoEnv
#NoTrayIcon
#KeyHistory 0
SetBatchLines -1

; 检测到 bom 则直接退出，这样可以微微的加速
if (FileGetEncodingWithBom(A_Args[1]))
  ExitApp

; FileGetFormat 可以比 FileGetEncoding 多判断两种编码
switch FileGetFormat(A_Args[1])
{
  case "ASCII":
    FileAppend code.page=0, *
  
  ; 西里尔文
  case "windows-1251","x-mac-cyrillic","KOI8-R","IBM855","IBM866","ISO-8859-5":
    FileAppend code.page=0, *
    FileAppend character.set=204, *
  
  ; 拉丁文1（西欧）
  case "windows-1252":
    FileAppend code.page=0, *
  
  ; 希腊文
  case "windows-1253","ISO-8859-7":
    FileAppend code.page=0, *
    FileAppend character.set=161, *
  
  ; 希伯来语
  case "windows-1255","ISO-8859-8":
    FileAppend code.page=0, *
    FileAppend character.set=177, *
  
  ; 拉丁文2（中欧）
  case "ISO-8859-2":
    FileAppend code.page=0, *
  
  ; 泰语
  case "TIS620":
    FileAppend code.page=0, *
    FileAppend character.set=222, *
  
  case "UTF-8":
    FileAppend code.page=65001, *
  
  ; 繁中
  case "EUC-TW","Big-5":
    FileAppend code.page=950, *
    FileAppend character.set=136, *
  
  ; 韩文
  case "EUC-KR","ISO-2022-KR":
    FileAppend code.page=949, *
    FileAppend character.set=129, *
  
  ; 日文
  case "EUC-JP","ISO-2022-JP","Shift-JIS":
    FileAppend code.page=932, *
    FileAppend character.set=128, *
  
  ; 简中
  case "ISO-2022-CN","gb18030","HZ-GB-2312":
    FileAppend code.page=936, *
    FileAppend character.set=134, *
}

#Include %A_LineFile%\..\智能操作\Ude\Ude.ahk