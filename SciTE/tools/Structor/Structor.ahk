/*
本工具提取自      ： Adventure IDE - 3.0.4
完整版默认编译器  ： MSVC2022_Mini
默认编译器制作说明： MSVC2022 制作说明.txt

为实现工具便携性与使用傻瓜化，部分代码有修改，需自行对比原版。

Original Version : https://www.autohotkey.com/boards/viewtopic.php?t=31711
Modified Version : https://github.com/telppa/Structor

*/

; Structor - Structure Helper

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; 自动配置编译器路径
#Include %A_ScriptDir%\Lib\MSVC2022.ahk

Global C
    , AppName := "Structor"
    , Version := "1.2.2"
    , g_AppData := A_ScriptDir
    , StructSize32 := 0
    , StructSize64 := 0
    , Unicode := 1
    , PausePrompt := 0
    , g_aGradColors := [0x3FBBE3, 0x008EBC]

GoSub LoadSettings

SetMainIcon(A_ScriptDir . "\Icons\Structor.ico")

Gui Main: New, LabelMain hWndhMainWnd +Resize +MinSize627x511

Gui Add, Pic, hWndhGrad1 x11 y10 w606 h26, % "HBITMAP:" . Gradient(606, 26)
Gui Font, s9 cWhite Bold, Segoe UI
Gui Add, Text, vLabel1 x11 y10 w606 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%Structure Declaration
Gui Font

Gui Font, s10 c0x003399, Lucida Console
Gui Add, Edit, vInput gEnableParse x11 y39 w605 h176
Gui Font

Gui Font, s9, Segoe UI
Gui Add, Button, vBtnParse gGetOffsets x10 y224 w84 h24 +Disabled, &Compile
Gui Add, CheckBox, vChk32bit gEnableParse x110 y225 w96 h23 +Checked%Chk32bit%, &32-bit offsets
GuiControl % (CompilerPath32 != "") ? "Enable" : "Disable", Chk32bit
Gui Add, CheckBox, vChk64bit gEnableParse x208 y225 w96 h23 +Checked%Chk64bit%, &64-bit offsets
GuiControl % (CompilerPath64 != "") ? "Enable" : "Disable", Chk64bit
Gui Add, Text, vLblStructName x360 y225 w101 h23 +0x202, Structure &Name:
Gui Add, Edit, vStructName x470 y225 w146 h21

Gui Add, Pic, hWndhGrad2 x11 y257 w605 h26, % "HBITMAP:" . Gradient(606, 26)
Gui Font, s9 cWhite Bold, Segoe UI
Gui Add, Text, vLabel2 x11 y257 w605 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%Structure Offsets
Gui Font

Gui Font, s9, Segoe UI
Gui Add, ListView, hWndhLVOffset vLV x11 y286 w603 h180 +LV0x114004, Member|Data Type|32-bit Offset|64-bit Offset
LV_ModifyCol(1, 150)
LV_ModifyCol(2, 150)
LV_ModifyCol(3, "80 Integer")
LV_ModifyCol(4, "80 Integer")

Gui Add, Button, vBtnCopy gGenerateCode x9 y476 w84 h24 +Disabled, C&opy
Gui Add, CheckBox, vChkNumGet x110 y476 w96 h23 +Checked%ChkNumGet%, Num&Get
Gui Add, CheckBox, vChkNumPut x208 y476 w96 h23 +Checked%ChkNumPut%, Num&Put
Gui Add, Button, vBtnSettings gShowSettings x519 y476 w96 h24, &Settings...

Gui Show, w627 h511, %AppName%

Test(113)

If (CompilerPath32 == "" && CompilerPath64 == "") {
    GoSub ShowSettings
}

If (RegExMatch(Clipboard, "^(typedef)? struct")) {
    GuiControl,, Input, %Clipboard%
    GuiControl Main: Enable, BtnParse
}

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLVOffset, "WStr", "Explorer", "Ptr", 0)

Menu ContextMenu, Add, Copy for NumGet, CopyForNumGet
Menu ContextMenu, Add, Copy for NumPut, CopyForNumPut

hSysMenu := DllCall("GetSystemMenu", "Ptr", hMainWnd, "Int", False, "Ptr")
DllCall("InsertMenu", "Ptr", hSysMenu, "UInt", 5, "UInt", 0x400, "UPtr", 0xC0DE, "Str", "About...")
DllCall("InsertMenu", "Ptr", hSysMenu, "UInt", 5, "UInt", 0xC00, "UPtr", 0, "Str", "") ; Separator

OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x112, "OnWM_SYSCOMMAND")
Return

MainEscape:
MainClose:
    GoSub SaveSettings
    DeleteTempFiles()
    ExitApp

GetOffsets:
    Gui Main: Submit, NoHide

    RegEx := "^([\w ]+)\s+(\*?.+);$"

    DataTypes := []
    Members := []
    StructName := ""

    ; Parse input data
    Loop Parse, Input, `n, `r
    {
        Line := RegExReplace(A_LoopField, "(#|//|/\*).+") ; Remove comments and directives
        Line := Trim(Line)
        If (RegExMatch(Line, RegEx, Match)) {
            Match1 := RTrim(Match1)
            Match2 := StrReplace(Match2, "*")

            If (InStr(Match2, ":")) {
                ;MsgBox 0x30, %AppName%, %Match2% is a bit field and will be skipped.
                Continue
            }

            DataTypes.Push(Match1)
            Members.Push(Match2)

        } Else If (RegExMatch(Line, "}\s+(\w+)", Match)) {
            StructName := Match1
        } Else If (RegExMatch(Line, "struct (?:tag)?(\w+)", Match)) {
            StructName := Match1
        }
    }

    If (StructName == "") {
        Gui Main: +OwnDialogs
        MsgBox 0x10, %AppName%, Invalid input.
        Return
    }

    GuiControl,, StructName, %StructName%

    DeleteTempFiles()

    GoSub GenerateCCode

    Offsets32 := []
    Offsets64 := []

    If (Chk32bit) {
        If (CreateBatchFile("32")) {
            GetOffsets("32", Offsets32, StructSize32)
        }
    }

    If (Chk64bit) {
        If (CreateBatchFile("64")) {
            GetOffsets("64", Offsets64, StructSize64)
        }
    }

    LV_Delete()
    Loop % Members.Length() {
        LV_Add("Check", Members[A_Index], DataTypes[A_Index], Offsets32[A_Index], Offsets64[A_Index])
    }

    If (Members.Length()) {
        GuiControl Main: Enable, BtnCopy
    }
Return

; Generate Offsets.c
GenerateCCode:
    C := ""

    If (Unicode) {
        C .= "#define UNICODE 1`r`n"
    }

    C .= "#include <stdio.h>`r`n"
    C .= "#include <stddef.h>`r`n"

    Loop % arrIncludes.Length() {
        If (InStr(arrIncludes[A_Index], ":")) {
            C .= "#include """ . arrIncludes[A_Index] . """`r`n"
        } Else {
            C .= "#include <" . arrIncludes[A_Index] . ">`r`n"
        }
    }

    C .= "`r`nint main() {`r`n"
    C .= "    printf(""%d\n"", sizeof(" . StructName . "));`r`n"

    Loop % Members.Length() {
        If (InStr(Members[A_Index], "[")) {
            If (RegExMatch(Members[A_Index], "\[(.+)\]", Match)) {
                C .= "    printf(""%d\n"", offsetof(" . StructName . ", " . Members[A_Index] . ") - ((" . Match1 . ") * sizeof(" . DataTypes[A_Index] . ")));`r`n"
            }
        } Else {
            C .= "    printf(""%d\n"", offsetof(" . StructName . ", " . Members[A_Index] . "));`r`n"
        }
    }
    C .= "    return 0;`r`n}"

    FileAppend %C%, %A_Temp%\Offsets.c
Return

; Generate the files Compile32.bat and Compile64.bat
CreateBatchFile(xNN) {
    Bat := "@ECHO OFF`r`nCD /D " . A_Temp . "`r`n"
    If (BatchFile%xNN% != "") {
        Bat .= "CALL """ . BatchFile%xNN% . """`r`n"
    }

    CompilerPath := CompilerPath%xNN%

    If (!GetExePathAndArgs(CompilerPath, Args)) {
        Gui Main: +OwnDialogs
        MsgBox 0x10, %AppName%, Invalid file path: CompilerPath%xNN%
        Return 0
    }

    If (Args != "") {
        Args := " " . Args
    }

    If (InStr(CompilerPath, "CL.EXE")) {
        Bat .= """" . CompilerPath . """" . Args . " Offsets.c -FeOffsets" . xNN . ".exe"

    } Else If (InStr(CompilerPath, "GCC.EXE")) {
        Bat .= """" . CompilerPath . """" . Args . " Offsets.c -o Offsets" . xNN . ".exe"
    }

    If (PausePrompt) {
        Bat .= "`r`nECHO. && PAUSE"
    }

    FileAppend %Bat%, %A_Temp%\Compile%xNN%.bat
    Return !ErrorLevel
}

; Compile and run
GetOffsets(xNN, ByRef Offsets, ByRef StructSize) {
    RunWait %A_Temp%\Compile%xNN%.bat,, % PausePrompt ? "" : "Hide"

    Stdout := RunGetStdout(A_Temp . "\Offsets" . xNN . ".exe")

    If (A_LastError == 2) { ; File not found
        Gui Main: +OwnDialogs
        MsgBox 0x10, %AppName%, %xNN%-bit compilation failed.
        Return
    }

    StructSize := 0
    Offsets := []
    Loop Parse, Stdout, `n, `r
    {
        If (A_Index == 1) {
            StructSize := A_LoopField
        } Else {
            Offsets.Push(A_LoopField)
        }
    }
}

DeleteTempFiles() {
    FileDelete %A_Temp%\Compile32.bat
    FileDelete %A_Temp%\Compile64.bat
    FileDelete %A_Temp%\Offsets.c
    FileDelete %A_Temp%\Offsets.obj
    FileDelete %A_Temp%\Offsets32.exe
    FileDelete %A_Temp%\Offsets64.exe
}

CopyForNumGet:
CopyForNumPut:
GenerateCode:
    Gui Main: Default
    Gui Submit, NoHide

    Cap := ""
    Condition := ""
    IncludePlanBFunc := ""

    If (StructSize32 == StructSize64) {
        StructSize := (Chk32bit) ? StructSize32 : StructSize64

    } Else If (Chk32bit && Chk64bit) {
        If (ShortTernary || GetKeyState("Shift", "P")) {
            Cap := "x64 := (A_PtrSize == 8)`r`n"
            Condition := "x64 ? "
        } Else {
            Condition := "(A_PtrSize == 8) ? "
        }

        StructSize := StructSize64 . " : " . StructSize32

    } Else If (Chk32bit) {
        StructSize := StructSize32

    } Else If (Chk64bit) {
        StructSize := StructSize64

    } Else {
        Return
    }

    If (StructSize) {
        Cap .= Format("VarSetCapacity({}, {}, 0)", StructName, Condition . StructSize)
    }

    Get := ""
    Put := ""
    If (A_ThisLabel == "CopyForNumGet") {
        fGet := True
        fPut := False

    } Else If (A_ThisLabel == "CopyForNumPut") {
        fGet := False
        fPut := True

    } Else {
        fGet := ChkNumGet
        fPut := ChkNumPut
    }

    Checked := A_ThisLabel == "GenerateCode" ? "Checked" : ""
    PrevOffset := -1
    Row := 0

    While (Row := LV_GetNext(Row, Checked)) {
        LV_GetText(Member,   Row, 1)
        LV_GetText(DataType, Row, 2)
        LV_GetText(Offset32, Row, 3)
        LV_GetText(Offset64, Row, 4)

        fStr := False, ftype := ""

        If (FoundPos := InStr(Member, "[")) {
            Member := SubStr(Member, 1, FoundPos - 1)
            If (RegExMatch(DataType, "i)(TCHAR|WCHAR|wchar_t|CHAR)", fType))
                fStr := True
        }

        AHKType := GetAHKType(DataType, Member, Row)
        If (!InStr(AHKType, "=")) {  ; Add quotes.    int->"int"    (a=b)?c:d->(a=b)?c:d
            AHKType := Format("""{}""", AHKType)
            If (InStr(AHKType, "Str"))  ; Str AStr WStr
                fStr := True
        }

        switch, fType
        {
            case "TCHAR"            : AHKType := """Str"""
            case "CHAR"             : AHKType := """AStr"""
            case "WCHAR", "wchar_t" : AHKType := """WStr"""
        }

        If (fStr) {
            If (Row == LV_GetCount()) {
                Length := (Offset64 != "") ? (StructSize64 - Offset64) : (StructSize32 - Offset32)
            } Else {
                LV_GetText(NextOffset32, Row + 1, 3)
                LV_GetText(NextOffset64, Row + 1, 4)
                Length := (Offset64 != "") ? (NextOffset64 - Offset64) : (NextOffset32 - Offset32)
            }

            ; If the type is Str(e.g. TCHAR), and you want to do compatibility for ansi and unicode.
            ; The right way is to generate the structure twice by checked and no checked the checkbox-Unicode in Settings.
            ; The ansi size calculated by unicode size is not accurate, that's why we should get the them by generating it twice.
            Tips := ""
            switch, Trim(AHKType, """")
            {
                case "Str": 
                    Encoding := Unicode ? """UTF-16""" : """CP0"""
                    Length   := Unicode ? Length//2 : Length
                    Tips     := Unicode ? "  `; work on AutoHotkeyU32(U64).exe" : "  `; work on AutoHotkeyA32.exe"
                case "AStr":
                    Encoding := """CP0"""
                    Length   := Length
                case "WStr":
                    Encoding := """UTF-16"""
                    Length   //= 2
            }
        }

        u := (Offset32 == PrevOffset
          || Offset64 == PrevOffset
          || (Chk32bit ? Offset32 : Offset64) < PrevOffset) ? "; " : "" ; Union

        If (Condition != "" && Offset32 != Offset64) {
            Offset := Condition . Offset64 . " : " . Offset32
        } Else If (Chk32bit) {
            Offset := Offset32
        } Else If (Chk64bit) {
            Offset := Offset64
        }

        If (DataType ~= "^(RECT|POINTL?)$") {
            Prefix := Member . "_"
            Fields := (DataType == "RECT") ? "left,top,right,bottom" : "X,Y"

            Loop Parse, Fields, `,
            {
                If (fGet) {
                    Get .= Format("{} := NumGet({}, {}, ""Int"")`r`n", u . Prefix . A_LoopField, StructName, Offset)
                }

                If (fPut) {
                    Put .= Format("{}NumPut({}, {}, {}, ""Int"")`r`n", u, Prefix . A_LoopField, StructName, Offset)
                }

                If (Condition != "" && Offset32 != Offset64) {
                    Offset := Condition . (Offset64 + (A_Index * 4)) . " : " . (Offset32 + (A_Index * 4))
                } Else {
                    Offset += 4
                }
            }

            Continue
        }

        If (InStr(Offset, ":"))
            Offset := Format("({})", Offset)

        If (fGet) {
            If (fStr) {
                
                Get .= Format("; Plan A.`r`n{} := StrGet(&{} + {}, {}, {}){}`r`n", u . Member, StructName, Offset, Length, Encoding, Tips)
                
                ; sometimes it's a pointer.
                PlanB =
                (LTrim
                ; Plan B. Try this if Plan A fails.
                ; Pointer_{1} := NumGet({2}, {3}, "Ptr")
                ; {1} := StrGet(Pointer_{1}, {4}){5}`r`n
                )
                PlanB := Format(PlanB, Member, StructName, Offset, Encoding, Tips)
                Get .= PlanB
                
            } Else {
                Get .= Format("{} := NumGet({}, {}, {})`r`n", u . Member, StructName, Offset, AHKType)
            }
        }

        If (fPut) {
            If (fStr) {
                
                Put .= Format("; Plan A.`r`n{}StrPut({}, &{} + {}, {}, {}){}`r`n", u, Member, StructName, Offset, Length, Encoding, Tips)
                
                ; sometimes it's a pointer.
                PlanB =
                (LTrim
                ; Plan B. Try this if Plan A fails.
                ; {1} := "Put your string here."
                ; StrPutVar({1}, Pointer_{1}, {4})
                ; NumPut(&Pointer_{1}, {2}, {3}, "Ptr"){5}`r`n
                )
                PlanB := Format(PlanB, Member, StructName, Offset, Encoding, Tips)
                Put .= PlanB
                IncludePlanBFunc := True
                
            } Else {
                Put .= Format("{}NumPut({}, {}, {}, {})`r`n", u, Member, StructName, Offset, AHKType)
            }
        }

        If (u == "") {
            PrevOffset := (Chk32bit) ? Offset32 : Offset64
        }
    }

    If (Get != "" || Put != "") {
        Cap .= "`r`n`r`n"
    }

    If (Get != "") {
        Get .= "`r`n"
    }

    if (IncludePlanBFunc) {
        PlanBFunc =
        (LTrim
        StrPutVar(str, ByRef var, encoding)
        {
        %A_Space%%A_Space%factor := (encoding="utf-16" or encoding="cp1200") ? 2 : 1
        %A_Space%%A_Space%VarSetCapacity(var, StrPut(str, encoding) * factor)
        %A_Space%%A_Space%return StrPut(str, &var, encoding)
        }
        )
        Put .= "`r`n" PlanBFunc
    }

    If (Cap != "") {
        Gui Main: +OwnDialogs
        MsgBox 0, %AppName%, % Clipboard := Cap . Get . Put
    }
Return

GetAHKType(DataType, Member, Row) {
    ; You can get the following list of types by press F10 in "AHK DllCall Terminator".
    ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=101795
    ; https://autohotkey.com/board/topic/25250-structparser-for-cc-structs/
    Static Types = "Int,UInt,Ptr,UPtr,Short,UShort,Char,UChar,Int64,Float,Double,Str,AStr,WStr"
    , AStrTypes = "__nullterminated CONST CHAR*,CHAR*,CONST CHAR*,INT8*,LPCSTR,LPSTR,PCHAR,PCSTR,PINT8,PSTR"
    , CharTypes = "CCHAR,char,INT8,signed char"
    , DoubleTypes = "double"
    , FloatTypes = "float"
    , IntTypes = "BOOL,HFILE,HRESULT,int,INT32,long,LONG32,NTSTATUS,signed int"
    , Int64Types = "__int64,DWORD64,DWORDLONG,INT64,LARGE_INTEGER,LONG64,LONGLONG,QWORD,signed __int64,UINT64,ULARGE_INTEGER,ULONG64,ULONGLONG,unsigned __int64,USN"
    , PtrTypes = "__int3264,ADCONNECTION_HANDLE,CONST void*,HACCEL,HANDLE,HBITMAP,HBRUSH,HCOLORSPACE,HCONV,HCONVLIST,HCURSOR,HDC,HDDEDATA,HDESK,HDROP,HDWP,HENHMETAFILE,HFONT,HGDIOBJ,HGLOBAL,HHOOK,HICON,HINSTANCE,HKEY,HKL,HLOCAL,HMENU,HMETAFILE,HMODULE,HMONITOR,HPALETTE,HPEN,HRGN,HRSRC,HSZ,HWND,INT_PTR,LDAP_UDP_HANDLE,LONG_PTR,LPARAM,LPCVOID,LPVOID,LRESULT,PCONTEXT_HANDLE,PVOID,RPC_BINDING_HANDLE,SC_HANDLE,SC_LOCK,SERVICE_STATUS_HANDLE,SSIZE_T,void*,WINSTA"
    , ShortTypes = "INT16,short,signed short"
    , StrTypes = "LPCTSTR,LPTSTR,PCTSTR,PTCHAR,PTSTR,TCHAR*"
    , UCharTypes = "BOOLEAN,BYTE,UCHAR,UINT8,unsigned char"
    , UIntTypes = "ACCESS_MASK,COLORREF,DWORD,DWORD32,error_status_t,HCALL,LCID,LCTYPE,LGRPID,NET_API_STATUS,SECURITY_INFORMATION,TOKEN_MANDATORY_POLICY,UINT,UINT32,ULONG,ULONG32,unsigned int,unsigned long"
    , UPtrTypes = "DWORD_PTR,SIZE_T,UINT_PTR,ULONG_PTR,unsigned __int3264,WPARAM"
    , UShortTypes = "ATOM,LANGID,UINT16,UNICODE,unsigned short,USHORT,WCHAR,wchar_t,WORD"
    , WStrTypes = "BSTR,CONST WCHAR*,const wchar_t*,LMCSTR,LMSTR,LPCWSTR,LPWORD,LPWSTR,PCWSTR,PUINT16,PUSHORT,PWCHAR,PWORD,PWSTR,UINT16*,USHORT*,WCHAR*,WORD*"

    Loop Parse, Types, `,
    {
        TypeList := %A_LoopField%Types
        If DataType in %TypeList%
        {
            Return A_LoopField
            Break
        }
    }

    If (Type == "TBYTE")
        Return "(A_IsUnicode) ? ""UShort"" : ""UChar"""

    If (Type == "HALF_PTR")
        Return "(A_PtrSize=8) ? ""Int"" : ""Short"""

    If (Type == "UHALF_PTR")
        Return "(A_PtrSize=8) ? ""UInt"" : ""UShort"""

    If (SubStr(DataType, 1, 2) == "LP" || SubStr(Member, 1, 2) == "lp") {
        Return "Ptr"
    }

    LV_GetText(Offset32, Row, 3)
    LV_GetText(Offset64, Row, 4)

    If (Row == LV_GetCount()) {
        Size := (Offset64 != "") ? (StructSize64 - Offset64) : (StructSize32 - Offset32)
    } Else {
        If (Offset64 != "") {
            LV_GetText(NextOffset, Row + 1, 4)
            Size := NextOffset - Offset64
        } Else {
            LV_GetText(NextOffset, Row + 1, 3)
            Size := NextOffset - Offset32
        }
    }

    Type := (Size >= 8) ? "Ptr" : {1: "Char", 2: "Short", 4: "Int"}[Size]

    Return (Type == "") ? "UInt" : Type
}

MainContextMenu:
    If (A_GuiControl != "LV" || !LV_GetNext()) {
        Return
    }

    Menu ContextMenu, Show
Return

MainSize:
    AutoXYWH("w", hGrad1)
    AutoXYWH("w", "Label1")
    AutoXYWH("w", "Input")
    AutoXYWH("x*", "LblStructName")
    AutoXYWH("x", "StructName")
    AutoXYWH("w", hGrad2)
    AutoXYWH("w", "Label2")
    AutoXYWH("wh", hLVOffset)
    AutoXYWH("y", "BtnCopy")
    AutoXYWH("y", "ChkNumGet")
    AutoXYWH("y", "ChkNumPut")
    AutoXYWH("xy", "BtnSettings")
Return

DPIScale(x) {
    Return (x * A_ScreenDPI) // 96
}

Gradient(Width, Height) {
    Return CreateGradient(DPIScale(Width), DPIScale(Height), 1, g_aGradColors)
}

ShowSettings:
    Gui Settings: New, +LabelSettings -MinimizeBox +OwnerMain
    Gui Color, White

    Gui Add, Pic, x9 y10 w637 h26, % "HBITMAP:" . Gradient(637, 26)
    Gui Font, s9 cWhite Bold, Segoe UI
    Gui Add, Text, x9 y10 w637 h26 +0x200 +E0x200 +BackgroundTrans, %A_Space%Compiler Settings
    Gui Font

    Gui Font, s9, Segoe UI
    Gui Add, GroupBox, x9 y44 w637 h99, 32-bit Compiler
    Gui Add, Text, x26 y71 w97 h21 +0x200, Compiler Path:
    Gui Add, Edit, vCompilerPath32 x124 y71 w418 h22, %CompilerPath32%
    Gui Add, Button, gSelectCompiler32 x549 y69 w84 h24, Browse...
    Gui Add, Text, x26 y105 w97 h21 +0x200, Batch File:
    Gui Add, Edit, vBatchFile32 x124 y105 w418 h22, %BatchFile32%
    Gui Add, Button, gSelectBatchFile32 x549 y103 w84 h24, Browse...

    Gui Add, GroupBox, x9 y149 w637 h99, 64-bit Compiler
    Gui Add, Text, x26 y176 w97 h21 +0x200, Compiler Path:
    Gui Add, Edit, vCompilerPath64 x124 y174 w418 h22, %CompilerPath64%
    Gui Add, Button, gSelectCompiler64 x549 y173 w84 h24, Browse...
    Gui Add, Text, x26 y210 w97 h21 +0x200, Batch File:
    Gui Add, Edit, vBatchFile64 x124 y208 w418 h22, %BatchFile64%
    Gui Add, Button, gSelectBatchFile64 x549 y207 w84 h24, Browse...

    Gui Add, Text, x18 y259 w100 h21 +0x200, &Includes:
    Gui Add, Edit, hWndhEdtHeader vNewInclude x124 y259 w200 h22
    Gui Add, Button, gAddInclude x331 y258 w84 h24, &Add
    Gui Add, Button, gRemoveInclude x331 y290 w84 h24, &Remove
    Gui Add, ListView, hWndhHeaderList x124 y290 w200 h119 -Hdr +LV0x114004, Headers

    Gui Add, CheckBox, vUnicode x483 y360 w167 h23 +Checked%Unicode%, &Unicode
    Gui Add, CheckBox, vPausePrompt x483 y388 w167 h23 +Checked%PausePrompt%, &Pause command prompt

    Gui Add, Text, x-1 y422 w660 h48 +Border -Background
    Gui Add, Button, gShowHelp x11 y434 w84 h24, &Help
    Gui Add, Button, gSettingsOK x469 y434 w84 h24 +Default, &OK
    Gui Add, Button, gSettingsClose x561 y434 w84 h24, Cancel

    If (strIncludes == "" || strIncludes == "ERROR") {
        LV_Add("Check", "windows.h")
        LV_Add("Check", "commctrl.h")
    } Else {
        Loop Parse, strIncludes, `n
        {
            If (A_LoopField != "") {
                Pair := StrSplit(A_LoopField, "=")
                Checked := (Pair[1] == 1) ? "Check" : ""
                LV_Add(Checked, Pair[2])
            }
        }
        LV_ModifyCol(1, "AutoHdr")
    }

    Gui Show, w656 h469, Settings

    DllCall("SetFocus", "Ptr", 0)

    ; EM_SETCUEBANNER
    DllCall("SendMessage", "Ptr", hEdtHeader, "UInt", 0x1501, "Ptr", 0, "WStr", "Header file", "Ptr")

    DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hHeaderList, "WStr", "Explorer", "Ptr", 0)
Return

SettingsEscape:
SettingsClose:
    Gui Settings: Destroy
Return

SettingsOK:
    Gui Settings: Default

    If (!LV_GetCount()) {
        LV_Add("Check", "windows.h")
        LV_Add("Check", "commctrl.h")
    }

    arrIncludes := []
    strIncludes := ""
    Loop % LV_GetCount() {
        LV_GetText(Header, A_Index)

        Checked := 0
        SendMessage 0x102C, % A_Index - 1, 0x2000,, ahk_id %hHeaderList% ; LVM_GETITEMSTATE, LVIS_CHECKED
        If (Errorlevel == 0x2000) {
            arrIncludes.Push(Header)
            Checked := 1
        }

        strIncludes .= Checked . "=" . Header . "`n"
    }

    Gui Settings: Submit

    If (CompilerPath32 != "") {
        GuiControl Main:, Chk32bit, 1
        GuiControl Main: Enable, Chk32bit
    } Else {
        GuiControl Main:, Chk32bit, 0
        GuiControl Main: Disable, Chk32bit
    }

    If (CompilerPath64 != "") {
        GuiControl Main:, Chk64bit, 1
        GuiControl Main: Enable, Chk64bit
    } Else {
        GuiControl Main:, Chk64bit, 0
        GuiControl Main: Disable, Chk64bit
    }
Return

AddInclude:
    Gui Settings: Default
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

SelectCompiler32:
    SelectCompiler("32")
Return

SelectCompiler64:
    SelectCompiler("64")
Return

SelectCompiler(xNN) {
    Global
    GuiControlGet CompilerPath%xNN%,, CompilerPath%xNN%
    SplitPath CompilerPath%xNN%,, CompilerDir
    Gui +OwnDialogs
    FileSelectFile SelectedFile, 3, %CompilerDir%, Select %xNN%-bit Compiler, Executable Files (*.exe)
    If (!ErrorLevel) {
        GuiControl,, CompilerPath%xNN%, %SelectedFile%

        GuiControlGet BatchFile, Settings:, BatchFile%xNN%
        If (BatchFile == "" && RegExMatch(SelectedFile, "i)cl.exe$")) {
            SplitPath SelectedFile,, CompilerDir
            BatchFile := CompilerDir . "\vcvars" . xNN . ".bat"
            If (FileExist(BatchFile)) {
                GuiControl, Settings:, BatchFile%xNN%, %BatchFile%
            } Else {
                BatchFile := GetParentDir(CompilerDir) . "\vcvars" . xNN . ".bat"
                If (FileExist(BatchFile)) {
                    GuiControl, Settings:, BatchFile%xNN%, %BatchFile%
                }
            }
        }
    }
}

GetParentDir(Dir) {
    Return RegExReplace(Dir, "\\[^\\]+$")
}

SelectBatchFile32:
    GuiControlGet BatchFile32,, BatchFile32
    SplitPath BatchFile32,, BatchFileDir
    Gui +OwnDialogs
    FileSelectFile SelectedFile, 3, %BatchFileDir%, Select Batch File, Batch Files (*.bat; *.cmd)
    If (!ErrorLevel) {
        GuiControl,, BatchFile32, %SelectedFile%
    }
Return

SelectBatchFile64:
    GuiControlGet BatchFile64,, BatchFile64
    SplitPath BatchFile64,, BatchFileDir
    Gui +OwnDialogs
    FileSelectFile SelectedFile, 3, %BatchFileDir%, Select Batch File, Batch Files (*.bat; *.cmd)
    If (!ErrorLevel) {
        GuiControl,, BatchFile64, %SelectedFile%
    }
Return

LoadSettings:
    IniFile := GetIniFileLocation("Structor.ini")

    IniRead Chk32bit, %IniFile%, Settings, 32bitOffsets, 0
    IniRead Chk64bit, %IniFile%, Settings, 64bitOffsets, 0
    IniRead PausePrompt, %IniFile%, Settings, PausePrompt, 0
    IniRead ChkNumGet, %IniFile%, Settings, NumGet, 1
    IniRead ChkNumPut, %IniFile%, Settings, NumPut, 1
    IniRead ShortTernary, %IniFile%, Settings, ShortTernary, 1

    IniRead CompilerPath32, %IniFile%, Compiler, CompilerPath32, %A_Space%
    IniRead BatchFile32, %IniFile%, Compiler, BatchFile32, %A_Space%
    IniRead CompilerPath64, %IniFile%, Compiler, CompilerPath64, %A_Space%
    IniRead BatchFile64, %IniFile%, Compiler, BatchFile64, %A_Space%

    IniRead strIncludes, %IniFile%, Includes
    arrIncludes := []
    If (strIncludes == "" || strIncludes == "ERROR") {
        arrIncludes.Push("windows.h")
        arrIncludes.Push("commctrl.h")
    } Else {
        Loop Parse, strIncludes, `n
        {
            Pair := StrSplit(A_LoopField, "=")
            If (Pair[1] == 1) {
                arrIncludes.Push(Pair[2])
            }
        }
    }
Return

SaveSettings:
    CreateIniFile()

    Gui Main: Submit, NoHide

    IniWrite %Chk32bit%, %IniFile%, Settings, 32bitOffsets
    IniWrite %Chk64bit%, %IniFile%, Settings, 64bitOffsets
    IniWrite %PausePrompt%, %IniFile%, Settings, PausePrompt
    IniWrite %ChkNumGet%, %IniFile%, Settings, NumGet
    IniWrite %ChkNumPut%, %IniFile%, Settings, NumPut
    IniWrite %ShortTernary%, %IniFile%, Settings, ShortTernary

    IniWrite %CompilerPath32%, %IniFile%, Compiler, CompilerPath32
    IniWrite %BatchFile32%, %IniFile%, Compiler, BatchFile32
    IniWrite %CompilerPath64%, %IniFile%, Compiler, CompilerPath64
    IniWrite %BatchFile64%, %IniFile%, Compiler, BatchFile64

    IniWrite %strIncludes%, %IniFile%, Includes
Return

EnableParse:
    Gui Main: Submit, NoHide
    If (Input != "" && (Chk32bit || Chk64bit)) {
        GuiControl Main: Enable, BtnParse
    } Else {
        GuiControl Main: Disable, BtnParse
    }
Return

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    Global

    If (hWnd == hEdtHeader && wParam == 13) {
        GoSub AddInclude
        Return False

    } Else If (wParam == 120) { ; F9
        GoSub GetOffsets

    } Else If (wParam ~= "113|114|115") { ; F2, F3, F4
        Test(wParam)
    }
}

Test(Key) {
If (Key == 113) {
Struct =
(
typedef struct {
  int       iBitmap;
  int       idCommand;
  BYTE      fsState;
  BYTE      fsStyle;
#ifdef _WIN64
  BYTE      bReserved[6];
#else
#if defined(_WIN32)
  BYTE      bReserved[2];
#endif
#endif
  DWORD_PTR dwData;
  INT_PTR   iString;
} TBBUTTON, *PTBBUTTON, *LPTBBUTTON;
)
} Else If (Key == 114) {
Struct =
(
typedef struct _SHFILEINFO {
  HICON hIcon;
  int   iIcon;
  DWORD dwAttributes;
  TCHAR szDisplayName[MAX_PATH];
  TCHAR szTypeName[80];
} SHFILEINFO;
)
} Else If (Key == 115) {
Struct =
(
typedef struct tagWINDOWPLACEMENT {
  UINT  length;
  UINT  flags;
  UINT  showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT  rcNormalPosition;
} WINDOWPLACEMENT, *PWINDOWPLACEMENT, *LPWINDOWPLACEMENT;
)
}
    GuiControl Main:, Input, %Struct%
    GoSub EnableParse
}

OnWM_SYSCOMMAND(wParam, lParam, msg, hWnd) {
    If (wParam == 0xC0DE) {
        ShowAbout()
    }
}

ShowAbout() {
    Gui Main: +Disabled
    Gui About: New, -SysMenu OwnerMain
    Gui Color, White
    Gui Add, Picture, x15 y16 w32 h32, %A_ScriptDir%\Icons\Structor.ico
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x56 y11 w120 h23 +0x200, %AppName%
    Gui Font, s9 cDefault, Segoe UI
    Gui Add, Text, x56 y34 h18 +0x200, Structure helper (v %Version%)
    Gui Add, Text, x1 y72 w391 h48 -Background
    Gui Add, Button, gAboutGuiClose x299 y85 w80 h23 Default, &OK
    Gui Show, w392 h120, About
}

AboutGuiClose() {
    AboutGuiEscape:
    Gui Main: -Disabled
    Gui About: Destroy
    Return
}

ShowHelp() {
Gui Settings: +OwnDialogs
MsgBox 0, Help, %AppName% requires a C compiler. Supported: Visual Studio and MinGW.`n`n♦ Visual Studio`, Windows SDK`n`nCompiler Path: path to CL.EXE. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\cl.exe`n`nBatch File: path to VCVARS32.bat or VCVARS64.BAT. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat`n`n♦ MinGW or similars`n`nCompiler Path: path to GCC.EXE. Example:`nC:\MinGW\bin\gcc.exe`n`nBatch File: only needed if the gcc.exe directory is not in the PATH.`n`nEnable "Pause Command Prompt" to see compiler error messages.
}

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
        Sections := "[Settings]`n`n[Compiler]`n`n[Includes]`n"

        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            IniFile := g_AppData . "\Structor.ini"
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

#Include %A_ScriptDir%\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\Lib\CreateGradient.ahk
#Include %A_ScriptDir%\Lib\RunGetStdout.ahk
