/*
本工具提取自      ： Adventure IDE - 3.0.4
完整版默认编译器  ： MSVC2022_Mini
默认编译器制作说明： MSVC2022 制作说明.txt

为实现工具便携性与使用傻瓜化，部分代码有修改，需自行对比原版。

*/

; Verifier - Check the size of data types and constant values
; Structor (another tool) provides information about structures (size and offsets)
; These tools require Windows SDK, Visual Studio or MinGW

; Derived from: https://github.com/ahkscript/AHK-SizeOf-Checker/

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; 自动配置编译器路径
#Include %A_ScriptDir%\Lib\MSVC2022.ahk

Global AppName := "Verifier"
, Version := "1.1.3"
, g_AppData := A_ScriptDir
, Unicode := 1

GoSub LoadSettings

SetMainIcon(A_ScriptDir . "\Icons\" . AppName . ".ico")

Gui Font, s9, Segoe UI
Gui Color, White

Gui Add, Text, vLblInputType x18 y18 w100 h21 +0x200, &Size of:
Gui Add, Edit, hWndhEdtInput vInput gEnableGET x124 y18 w200 h21, DWORD
Gui Add, DropDownList, hWndh1 vInputType gSetInputType x331 y17 w80, Size||Offset|Constant
GuiControl Choose, InputType, %InputType%
GoSub SetInputType

Gui Add, Button, gSelectList x418 y16 w80 h25, From &List...

Gui Add, Text, x18 y61 w100 h23 +0x200, Compiler:
Gui Add, DropDownList, vCompiler gSetCompiler x124 y61 w120, Visual Studio||MinGW
GuiControl Choose, Compiler, %Compiler%

Gui Add, Text, x18 y96 w100 h23 +0x200, Platform:
Gui Add, DropDownList, vPlatform gSetPlatform x124 y96 w63, x86||x64
GuiControl Choose, Platform, %Platform%

Gui Add, Text, x18 y143 w100 h21 +0x200, Compiler Path:
Gui Add, Edit, vCompilerPath gEnableGET x124 y143 w426
Gui Add, Button, gSelectCompiler x557 y141 w80 h24, Browse...

Gui Add, Text, x18 y177 w100 h21 +0x200, Batch File:
Gui Add, Edit, vBatchFile x124 y177 w426
Gui Add, Button, gSelectBatch x557 y176 w80 h24, Browse...

Gui Add, Text, x18 y215 w100 h21 +0x200, &Includes:
Gui Add, Edit, hWndhEdtHeader vNewInclude x124 y215 w200 h21
Gui Add, Button, gAddInclude x331 y214 w80 h23, &Add
Gui Add, Button, gRemoveInclude x331 y246 w80 h23, &Remove
Gui Add, ListView, hWndhListView x124 y246 w200 h150 -Hdr +LV0x114004, Headers

Gui Add, CheckBox, vUnicode x488 y350 w167 h23 Checked, &Unicode
Gui Add, CheckBox, vPausePrompt x488 y374 w167 h23 Checked%PausePrompt%, &Pause command prompt

Gui Add, Text, x-1 y410 w660 h48 -Background +Border
Gui Add, Button, gCheck x124 y422 w80 h23 +Disabled, &Check
Gui Add, Edit, vOutput x213 y423 w345 h21 +ReadOnly -Background
Gui Add, Button, gGuiClose x567 y422 w80 h23, Close

Gui Add, Button, gShowHelp x557 y18 w80 h24, &Help
Gui Add, Button, gShowAbout x557 y52 w80 h24, About

Comp := (Compiler == "Visual Studio") ? "VS" : "MinGW"
Plat := (Platform == "x86") ? "" : "64"
GuiControl,, CompilerPath, % %Comp%CompilerPath%Plat%
GuiControl,, BatchFile, % %Comp%BatchFile%Plat%

If (Includes != "" && Includes != "ERROR") {
    Loop Parse, Includes, `n
    {
        Pair := StrSplit(A_LoopField, "=")
        Checked := (Pair[1] == 1) ? "Check" : ""
        LV_Add(Checked, Pair[2])        
    }
    LV_ModifyCol(1, "AutoHdr")
} Else {
    LV_Add("Check", "windows.h")
    LV_Add("", "commctrl.h")
}

Gui Show, w658 h457, %AppName%

; EM_SETCUEBANNER
DllCall("SendMessage", "Ptr", hEdtHeader, "UInt", 0x1501, "Ptr", 0, "WStr", "Header file", "Ptr")

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hListView, "WStr", "Explorer", "Ptr", 0)

RegRead ProductName, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName

OnMessage(0x100, "OnWM_KEYDOWN")

Return

GuiEscape:
GuiClose:
    GoSub SaveSettings
    DeleteTempFiles()
    ExitApp

Check:
    Gui Submit, NoHide

    If (InStr(Input, ":\") && FileExist(Input)) {
        BulkList := Input
        BulkMode := True
    } Else {
        BulkMode := False
    }

    DeleteTempFiles()

    ; Compile.bat
    Bat := "@ECHO OFF`r`nCD /D " . A_Temp . "`r`n"
    If (BatchFile != "") {
        Bat .= "CALL """ . BatchFile . """`r`n"    
    }

    If (!GetExePathAndArgs(CompilerPath, Args)) {
        Gui +OwnDialogs
        MsgBox 0x10, %AppName%, Invalid file path: %CompilerPath%
        Return
    }

    If (Args != "") {
        Args := " " . Args
    }

    If (Compiler == "Visual Studio") {
        Bat .= """" . CompilerPath . """" . Args . " sizeof.c"
    } Else {
        Bat .= """" . CompilerPath . """" . Args . " sizeof.c -o sizeof.exe"
    }

    If (PausePrompt) {
        Bat .= "`r`nECHO. && PAUSE"    
    }

    FileAppend %Bat%, %A_Temp%\Compile.bat

    Includes := []
    Row := 0
    While (Row := LV_GetNext(Row, "Checked")) {
        LV_GetText(Include, Row)
        Includes.Push(Include)
    }

    ; sizeof.c
    C := ""

    If (Unicode) {
        C .= "#define UNICODE 1`r`n"
    }

    C .= "#include <stdio.h>`r`n"
    If (InputType == "Offset") {
        C .= "#include <stddef.h>`r`n"
    }

    Loop % Includes.Length() {
        If (InStr(Includes[A_Index], ":")) {
            C .= "#include """ . Includes[A_Index] . """`r`n"
        } Else {
            C .= "#include <" . Includes[A_Index] . ">`r`n"
        }
    }

    C .= "`r`nint main() {`r`n"
    If (BulkMode) {
        FileRead List, %BulkList%
        Loop Parse, List, `n, `r
        {
            If (A_LoopField != "") {
                If (InputType == "Size") {
                    C .= "    printf(""" . A_LoopField . " = %d\n"", sizeof(" . A_LoopField . "));`r`n"

                } Else If (InputType == "Offset") {
                    offsetof := StrSplit(A_LoopField, ".")
                    C .= "    printf(""" . A_LoopField . " = %d\n"", "
                    C .= "offsetof(" . offsetof[1] . ", " . offsetof[2] . "));`r`n"

                } Else If (InputType == "Constant") {
                	C .= "    printf(""" . A_LoopField . " = 0x%X (%d)\n"", "
                	C .= A_LoopField . "," . A_LoopField . ");`r`n"
                }
            }
        }
    } Else {
        If (InputType == "Size") {
        	C .= "    printf(""%d"", sizeof(" . Input . "));`r`n"
        } Else If (InputType == "Offset") {
            offsetof := StrSplit(Input, ".")
            C .= "    printf(""%d"", offsetof(" . offsetof[1] . ", " . offsetof[2] . "));`r`n"
        } Else If (InputType == "Constant") {
        	C .= "    printf(""0x%X (%d)"", " . Input . ", " . Input . ");`r`n"
        }
    }
	C .= "    return 0;`r`n}`r`n"

    FileAppend %C%, %A_Temp%\sizeof.c

    GuiControl,, Output, Compiling...
    RunWait %A_Temp%\Compile.bat,, % PausePrompt ? "" : "Hide"

    Stdout := RunGetStdout(A_Temp . "\sizeof.exe")

    If (A_LastError == 2) { ; File not found
        GuiControl,, Output, Compilation failed.
        Return
    }

    If (BulkMode) {
        GuiControl,, Output, Done
        If (GetKeyState("Shift", "P")) {
            Gui +OwnDialogs
            MsgBox 0, %AppName%, %Stdout%
        } Else {
            SplitPath BulkList,, FileDir
            Gui +OwnDialogs
            FileSelectFile SelectedFile, S16, %FileDir%, Save File
            If (!ErrorLevel) {
                Text := Compiler . " " . Platform . " on " . ProductName . "`r`n`r`n" . Stdout
                FileDelete %SelectedFile%
                FileAppend %Text%, %SelectedFile%
            }
        }
    } Else {
        Type := (InputType == "Constant") ? "Value" : InputType
        If (Type == "Size") {
            Bytes := Stdout == 1 ? " byte" : " bytes"
            Stdout .= Bytes
        }

        GuiControl,, Output, %Type% of %Input% is %Stdout%

        If (LogOutput) {
            If (!FileExist(LogFile)) {
                FileAppend %ProductName%`r`n`r`n, %LogFile%
            }
    
            Line := Type . " of " . Input . " is " . Stdout . " (" . Compiler . " " . Platform . ")`r`n"
            FileAppend %Line% , %LogFile%
        }
    }
Return

DeleteTempFiles() {
    FileDelete %A_Temp%\Compile.bat
    FileDelete %A_Temp%\sizeof.c
    FileDelete %A_Temp%\sizeof.obj
    FileDelete %A_Temp%\sizeof.exe
}

AddInclude:
    Gui Submit, NoHide
    If (NewInclude != "") {
        GuiControl,, NewInclude
        LV_Add("Check", NewInclude)
        LV_ModifyCol(1, "AutoHdr")
    }
Return

RemoveInclude:
    If (Row := LV_GetNext()) {
        LV_Delete(Row)
    }
Return

SelectList:
    Gui +OwnDialogs
    FileSelectFile BulkList, 3,, Select List
    If (!ErrorLevel) {
        GuiControl,, Input, %BulkList%
    }
Return

SelectCompiler:
    GuiControlGet CompilerPath,, CompilerPath
    SplitPath CompilerPath,, CompilerDir
    Gui +OwnDialogs
    FileSelectFile SelectedFile, 3, %CompilerDir%, Select Compiler, Executable Files (*.exe)
    If (!ErrorLevel) {
        GuiControl,, CompilerPath, %SelectedFile%
    }
Return

SelectBatch:
    GuiControlGet BatchFile,, BatchFile
    SplitPath BatchFile,, BatchDir
    Gui +OwnDialogs
    FileSelectFile SelectedFile, 3, %BatchDir%, Select Batch File, Batch Files (*.bat; *.cmd)
    If (!ErrorLevel) {
        GuiControl,, BatchFile, %SelectedFile%
    }
Return

SetCompiler:
    ; Store values before submit
    GuiControlGet Platform,, Platform
    GuiControlGet CompilerPath,, CompilerPath
    GuiControlGet BatchFile,, BatchFile

    If (Compiler == "Visual Studio") { ; Changing from VS to MinGW
        If (Platform == "x86") {
            VSCompilerPath := CompilerPath
            VSBatchFile := BatchFile
        } Else {
            VSCompilerPath64 := CompilerPath
            VSBatchFile64 := BatchFile
        }
    } Else { ; Changing from MinGW to VS
        If (Platform == "x86") {
            MinGWCompilerPath := CompilerPath
            MinGWBatchFile := BatchFile
        } Else {
            MinGWCompilerPath64 := CompilerPath
            MinGWBatchFile64 := BatchFile
        }
    }

    GoSub SetCompilerPath
Return

SetPlatform:
    ; Store values before submit
    GuiControlGet Compiler,, Compiler
    GuiControlGet CompilerPath,, CompilerPath
    GuiControlGet BatchFile,, BatchFile

    If (Platform == "x86") { ; Changing from x86 to x64
        If (Compiler == "Visual Studio") {
            VSCompilerPath := CompilerPath
            VSBatchFile := BatchFile
        } Else {
            MinGWCompilerPath := CompilerPath
            MinGWBatchFile := BatchFile
        }
    } Else { ; Changing from x64 to x86
        If (Compiler == "Visual Studio") {
            VSCompilerPath64 := CompilerPath
            VSBatchFile64 := BatchFile
        } Else {
            MinGWCompilerPath64 := CompilerPath
            MinGWBatchFile64 := BatchFile
        }
    }

    GoSub SetCompilerPath
Return

SetCompilerPath:
    Gui Submit, NoHide

    If (Compiler == "Visual Studio") {
        If (Platform == "x86") {
            GuiControl,, CompilerPath, %VSCompilerPath%
            GuiControl,, BatchFile, %VSBatchFile%
        } Else {
            GuiControl,, CompilerPath, %VSCompilerPath64%
            GuiControl,, BatchFile, %VSBatchFile64%
        }
    } Else If (Compiler == "MinGW") {
        If (Platform == "x86") {
            GuiControl,, CompilerPath, %MinGWCompilerPath%
            GuiControl,, BatchFile, %MinGWBatchFile%
        } Else {
            GuiControl,, CompilerPath, %MinGWCompilerPath64%
            GuiControl,, BatchFile, %MinGWBatchFile64%
        }
    }
Return

LoadSettings:
    IniFile := GetIniFileLocation("Verifier.ini")

    IniRead InputType, %IniFile%, Settings, InputType, Size

    IniRead Compiler, %IniFile%, Settings, Compiler, Visual Studio
    IniRead Platform, %IniFile%, Settings, Platform, x86

    IniRead VSCompilerPath, %IniFile%, Visual Studio, CompilerPath, %A_Space%
    IniRead VSCompilerPath64, %IniFile%, Visual Studio, CompilerPath64, %A_Space%
    IniRead VSBatchFile, %IniFile%, Visual Studio, BatchFile, %A_Space%
    IniRead VSBatchFile64, %IniFile%, Visual Studio, BatchFile64, %A_Space%
    
    IniRead MinGWCompilerPath, %IniFile%, MinGW, CompilerPath, %A_Space%
    IniRead MinGWCompilerPath64, %IniFile%, MinGW, CompilerPath64, %A_Space%
    IniRead MinGWBatchFile, %IniFile%, MinGW, BatchFile, %A_Space%
    IniRead MinGWBatchFile64, %IniFile%, MinGW, BatchFile64, %A_Space%
    
    IniRead Includes, %IniFile%, Includes
    
    IniRead PausePrompt, %IniFile%, Settings, PausePrompt, 0
    
    IniRead LogOutput, %IniFile%, Log, LogOutput, 0
    IniRead LogFile, %IniFile%, Log, LogFile, %AppName%.log
Return

SaveSettings:
    CreateIniFile()

    Gui Submit, NoHide

    Comp := (Compiler == "Visual Studio") ? "VS" : "MinGW"
    Plat := (Platform == "x86") ? "" : "64"
    %Comp%CompilerPath%Plat% := CompilerPath
    %Comp%BatchFile%Plat% := BatchFile

    IniWrite %InputType%, %IniFile%, Settings, InputType

    IniWrite %Compiler%, %IniFile%, Settings, Compiler
    IniWrite %Platform%, %IniFile%, Settings, Platform

    IniWrite %VSCompilerPath%, %IniFile%, Visual Studio, CompilerPath
    IniWrite %VSCompilerPath64%, %IniFile%, Visual Studio, CompilerPath64
    IniWrite %VSBatchFile%, %IniFile%, Visual Studio, BatchFile
    IniWrite %VSBatchFile64%, %IniFile%, Visual Studio, BatchFile64

    IniWrite %MinGWCompilerPath%, %IniFile%, MinGW, CompilerPath
    IniWrite %MinGWCompilerPath64%, %IniFile%, MinGW, CompilerPath64
    IniWrite %MinGWBatchFile%, %IniFile%, MinGW, BatchFile
    IniWrite %MinGWBatchFile64%, %IniFile%, MinGW, BatchFile64

    Includes := ""
    Loop % LV_GetCount() {
        LV_GetText(Text, A_Index)

        Checked := 0
        SendMessage 0x102C, % A_Index - 1, 0x2000,, ahk_id %hListView% ; LVM_GETITEMSTATE, LVIS_CHECKED
        If (Errorlevel == 0x2000) {
            Checked := 1
        }

        Includes .= Checked . "=" . Text . "`n"

        IniWrite %Includes%, %IniFile%, Includes
    }

    IniWrite %PausePrompt%, %IniFile%, Settings, PausePrompt

    IniWrite %LogOutput%, %IniFile%, Log, LogOutput
    IniWrite %LogFile%, %IniFile%, Log, LogFile
Return

ShowHelp() {
Gui +OwnDialogs
MsgBox 0, Help, Usage: enter the name of a data type or constant declared in a header file.`nExamples: DWORD`, SYSTEMTIME.wHour`, LVM_GETHEADER (requires commctrl.h)`, etc.`n`nSet compiler and platform before defining the compiler path.`n`n♦ Windows SDK or Visual Studio`n`nCompiler path: path to CL.EXE. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\cl.exe`n`nBatch file: path to VCVARS32.BAT or VCVARS64.BAT or VCVARSX86_AMD64.BAT. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat`n`n♦ MinGW or similars`n`nCompiler path: path to GCC.EXE. Example:`nC:\MinGW\bin\gcc.exe`n`nBatch file: only required if the gcc.exe directory is not in the PATH.`n`nAnother tool, Structor, is more appropriate for information about structures (size and offsets).
}

ShowAbout() {
    Gui 1: +Disabled
    Gui About: New, -SysMenu Owner1
    Gui Color, White
    Gui Add, Picture, x15 y16 w32 h32, %A_ScriptDir%\Icons\%AppName%.ico
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x56 y11 w120 h23 +0x200, %AppName%
    Gui Font, s9 cDefault, Segoe UI
    Gui Add, Text, x56 y34 h18 +0x200, Size of data types and constant values (v %Version%)
    Gui Add, Text, x1 y72 w391 h48 -Background
    Gui Add, Button, gAboutGuiClose x299 y85 w80 h23 Default, &OK
    Gui Font
    Gui Show, w392 h120, About
}

AboutGuiClose() {
    AboutGuiEscape:
    Gui 1: -Disabled
    Gui About: Destroy
    Return
}

OnWM_KEYDOWN(wParam) {
    If (wParam == 120) { ; F9
        GoSub Check
    }
}

EnableGET:
    Gui Submit, NoHide
    If (Input != "" && CompilerPath != "") {
        GuiControl Enable, &Check
    } Else {
        GuiControl Disable, &Check
    }
Return

SetInputType:
    GuiControlGet InputType,, InputType
    GuiControl,, LblInputType, % (InputType == "Size") ? "&Size of:" : InputType . ":"
    HintText := {"Size": "Structure or data type", "Offset": "Structure.Member", "Constant": ""}
    DllCall("SendMessage", "Ptr", hEdtInput, "UInt", 0x1501, "Ptr", 0, "WStr", HintText[InputType], "Ptr")
Return

GetExePathAndArgs(ByRef ExePath, ByRef Args) {
    Local Attrib, FoundPos, FilePath

    Attrib := FileExist(ExePath)
    If (Attrib && !InStr(Attrib, "D")) {
        Return 1

    } Else {
        FoundPos := InStr(ExePath, ".exe")
        If (FoundPos) {
            FilePath := SubStr(ExePath, 1, FoundPos + 3)
            If (FileExist(FilePath)) {
                If (StrLen(FilePath) < StrLen(ExePath)) {
                    Args := SubStr(ExePath, StrLen(FilePath) + 2)
                }

                ExePath := FilePath
                Return 1
            }
        }
    }

    Return 0
}

GetIniFileLocation(Filename) {
    Local FullPath, AppCfgFile
    FullPath := A_ScriptDir . "\" . Filename

    If (!FileExist(FullPath)) {
        AppCfgFile := g_AppData . "\" . Filename
        If (FileExist(AppCfgFile)) {
            Return AppCfgFile
        }
    }

    Return FullPath
}

CreateIniFile() {
    Local Sections

    If (!FileExist(IniFile)) {
        Sections := "[Settings]`n`n[Visual Studio]`n`n[MinGW]`n`n[Includes]`n`n[Log]`n"

        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            IniFile := g_AppData . "\Verifier.ini"
            FileDelete %IniFile%
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }
}

SetMainIcon(IconRes, IconIndex := 1) {
    Try {
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptName : IconRes, %IconIndex%
    }
}

#Include %A_ScriptDir%\Lib\RunGetStdout.ahk
