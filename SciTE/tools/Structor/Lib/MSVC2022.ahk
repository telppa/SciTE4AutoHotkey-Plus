if (FileExist("MSVC2022")="D")
{
  ; Structor.ini 配置
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Tools\MSVC\14.30.30705\bin\Hostx64\x86\cl.exe, Structor.ini, Compiler, CompilerPath32
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Auxiliary\Build\vcvars32.bat, Structor.ini, Compiler, BatchFile32
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Tools\MSVC\14.30.30705\bin\Hostx64\x64\cl.exe, Structor.ini, Compiler, CompilerPath64
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Auxiliary\Build\vcvars64.bat, Structor.ini, Compiler, BatchFile64
  IniWrite, 1, Structor.ini, Settings, 64bitOffsets
  IniWrite, 1, Structor.ini, Settings, 32bitOffsets
  
  ; Verifier.ini 配置
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Tools\MSVC\14.30.30705\bin\Hostx64\x86\cl.exe, Verifier.ini, Visual Studio, CompilerPath
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Auxiliary\Build\vcvars32.bat, Verifier.ini, Visual Studio, BatchFile
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Tools\MSVC\14.30.30705\bin\Hostx64\x64\cl.exe, Verifier.ini, Visual Studio, CompilerPath64
  IniWrite, %A_ScriptDir%\MSVC2022\VC\Auxiliary\Build\vcvars64.bat, Verifier.ini, Visual Studio, BatchFile64
}
else
{
  if (A_ScriptName="Structor.ahk")
  {
    IniRead, OutputVar32, Structor.ini, Compiler, CompilerPath32, %A_Space%
    IniRead, OutputVar64, Structor.ini, Compiler, CompilerPath64, %A_Space%
    if (!OutputVar32 and !OutputVar64)
      提示下载完整版 := 1
  }
  if (A_ScriptName="Verifier.ahk")
  {
    IniRead, OutputVar32, Verifier.ini, Visual Studio, CompilerPath, %A_Space%
    IniRead, OutputVar64, Verifier.ini, Visual Studio, CompilerPath64, %A_Space%
    IniRead, OutputVar32_2, Verifier.ini, MinGW, CompilerPath, %A_Space%
    IniRead, OutputVar64_2, Verifier.ini, MinGW, CompilerPath64, %A_Space%
    if (!OutputVar32 and !OutputVar64 and !OutputVar32_2 and !OutputVar64_2)
      提示下载完整版 := 1
  }
}

if (提示下载完整版)
{
  Instruction := "没有找到编译器。"
  Content := "本工具需要指定 C++ 编译器才能正常运行。`r`n建议从下方下载一个带编译器的完整版使用。"
  Title := A_ScriptName
  MainIcon := 0xFFFF
  Flags := 0x10
  CustomButtons := []
  CustomButtons.Push([101, "前往 Github 下载完整版。"])
  CustomButtons.Push([102, "前往 AutoAHK 下载完整版。"])
  CustomButtons.Push([103, "我有编译器。"])
  cButtons := CustomButtons.Length()
  VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)
  Loop %cButtons% {
      iButtonID := CustomButtons[A_Index][1]
      iButtonText := &(b%A_Index% := CustomButtons[A_Index][2])
      NumPut(iButtonID,   pButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
      NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
  }

  ; TASKDIALOGCONFIG structure
  x64 := A_PtrSize == 8
  NumPut(VarSetCapacity(TDC, x64 ? 160 : 96, 0), TDC, 0, "UInt") ; cbSize
  NumPut(Flags, TDC, x64 ? 20 : 12, "Int") ; dwFlags
  NumPut(&Title, TDC, x64 ? 28 : 20, "Ptr") ; pszWindowTitle
  NumPut(MainIcon, TDC, x64 ? 36 : 24, "Ptr") ; pszMainIcon
  NumPut(&Instruction, TDC, x64 ? 44 : 28, "Ptr") ; pszMainInstruction
  NumPut(&Content, TDC, x64 ? 52 : 32, "Ptr") ; pszContent
  NumPut(cButtons, TDC, x64 ? 60 : 36, "UInt") ; cButtons
  NumPut(&pButtons, TDC, x64 ? 64 : 40, "Ptr") ; pButtons

  DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
      , "Int*", Button := 0
      , "Int*", Radio := 0
      , "Int*", Checked := 0)

  If (Button == 101) { ; 前往 Github 下载完整版。
    Run, https://github.com/telppa/Structor
    ExitApp
  } Else If (Button == 102) { ; 前往 AutoAHK 下载完整版。
    Run, https://www.autoahk.com/archives/39950
    ExitApp
  }
}