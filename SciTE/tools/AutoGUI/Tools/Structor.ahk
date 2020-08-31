; Structor - Structure Helper

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Global C
    , AppName := "Structor"
    , Version := "1.0.1"
    , StructSize32 := 0
    , StructSize64 := 0
    , Unicode := 1
    , PausePrompt := 0

GoSub LoadSettings

Menu Tray, Icon, %A_ScriptDir%\..\Icons\Structor.ico

Gui Main: New, LabelMain hWndhMainWnd +Resize +MinSize627x511

Gui Add, Text, hWndhGrad1 x11 y10 w606 h26 +0xE
ApplyGradient(hGrad1, "008EBC", "3FBBE3")
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

Gui Add, Text, hWndhGrad2 x11 y257 w605 h26 +0xE
ApplyGradient(hGrad2, "008EBC", "3FBBE3")
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
    GoSub DeleteTempFiles
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
        } Else If (RegExMatch(Line, "struct (\w+)", Match)) {
            StructName := Match1
        }
    }

    If (StructName == "") {
        Gui Main: +OwnDialogs
        MsgBox 0x10, %AppName%, Invalid input.
        Return
    }

    GuiControl,, StructName, %StructName%

    GoSub DeleteTempFiles

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

DeleteTempFiles:
    FileDelete %A_Temp%\Compile32.bat
    FileDelete %A_Temp%\Compile64.bat
    FileDelete %A_Temp%\Offsets.c
    FileDelete %A_Temp%\Offsets.obj
    FileDelete %A_Temp%\Offsets32.exe
    FileDelete %A_Temp%\Offsets64.exe
Return

CopyForNumGet:
CopyForNumPut:
GenerateCode:
    Gui Main: Default
    Gui Submit, NoHide

    Cap := ""
    Condition := ""

    If (StructSize32 == StructSize64) {
        StructSize := (Chk32bit) ? StructSize32 : StructSize64

    } Else If (Chk32bit && Chk64bit) {
        If (ShortTernary || GetKeyState("Shift", "P")) {
            Cap := "x64 := A_PtrSize == 8`r`n"
            Condition := "x64 ? "
        } Else {
            Condition := "A_PtrSize == 8 ? "
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
        Cap .= "VarSetCapacity(" . StructName . ", " . Condition . StructSize . ", 0)"
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

        fStr := False
        If (FoundPos := InStr(Member, "[")) {
            Member := SubStr(Member, 1, FoundPos - 1)

            If (DataType ~= "(W|T)CHAR") {
                fStr := True

                If (Row == LV_GetCount()) {
                    Length := (Offset64 != "") ? (StructSize64 - Offset64) : (StructSize32 - Offset32)
                } Else {
                    LV_GetText(NextOffset32, Row + 1, 3)
                    LV_GetText(NextOffset64, Row + 1, 4)
                    Length := (Offset64 != "") ? (NextOffset64 - Offset64) : (NextOffset32 - Offset32)
                }
                Length /= 2
            }
        }

        u := (Offset32 == PrevOffset
          || Offset64 == PrevOffset
          || (Chk32bit ? Offset32 : Offset64) < PrevOffset) ? ";" : "" ; Union

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
                    Get .= u . Prefix . A_LoopField . " := NumGet(" . StructName . ", " . Offset . ", ""Int"")`r`n"
                }

                If (fPut) {
                    Put .= u . "NumPut(" . Prefix . A_LoopField . ", " . StructName . ", " . Offset . ", ""Int"")`r`n"
                }

                If (Condition != "" && Offset32 != Offset64) {
                    Offset := Condition . (Offset64 + (A_Index * 4)) . " : " . (Offset32 + (A_Index * 4))
                } Else {
                    Offset += 4
                }
            }

            Continue
        }

        AHKType := GetAHKType(DataType, Member, Row)

        If (fGet) {
            If (fStr) {
                InStr(Offset, ":") ? Offset := "(" . Offset . ")"
                Get .= u . Member . " := StrGet(&" . StructName . " + " . Offset . ", " . Length . ", ""UTF-16"")`r`n"
            } Else {
                Get .= u . Member . " := NumGet(" . StructName . ", " . Offset . ", """ . AHKType . """)`r`n"
            }
        }

        If (fPut) {
            If (fStr) {
                InStr(Offset, ":") ? Offset := "(" . Offset . ")"
                Put .= "StrPut(" . Member . ", &" . StructName . " + " . Offset . ", " . Length . ", ""UTF-16"")`r`n"
            } Else {
                Put .= u . "NumPut(" . Member . ", " . StructName ", " . Offset . ", """ . AHKType . """)`r`n"
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

    If (Cap != "") {
        Gui Main: +OwnDialogs
        MsgBox 0, %AppName%, % Clipboard := Cap . Get . Put
    }
Return

GetAHKType(DataType, Member, Row) {
    ; https://autohotkey.com/board/topic/25250-structparser-for-cc-structs/
    Static Types = "Int,UInt,Ptr,UPtr,Short,UShort,Char,UChar,Int64,Float,Double"
        , IntTypes = "int,INT,LONG,BOOL"
        , UIntTypes = "unsigned int,unsigned long,UINT,ULONG,DWORD,COLORREF"
        , PtrTypes = "HANDLE,HBITMAP,HBRUSH,HDC,HICON,HISTANCE,HMENU,HWND,LPARAM,WPARAM,INT_PTR,PUINT,PWSTR,PCWSTR"
        , UPtrTypes = "UINT_PTR,ULONG_PTR,DWORD_PTR"
        , ShortTypes = "short"
        , UShortTypes = "unsigned short,WORD,ATOM,USHORT,WCHAR,TCHAR"
        , CharTypes = "char"
        , UCharTypes = "unsigned char,byte,BYTE,UCHAR"
        , Int64Types = "int64,LONGLONG,ULONGLONG,DWORDLONG"
        , FloatTypes = "FLOAT"
        , DoubleTypes = "DOUBLE"

    Loop Parse, Types, `,
    {
        TypeList := %A_LoopField%Types
        If DataType in %TypeList%
        {
            Return A_LoopField
            Break
        }
    }

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

ApplyGradient(Hwnd, RB := "101010", LT := "0000AA", Vertical := 1) {
    ControlGetPos,,, W, H,, ahk_id %Hwnd%
    PixelData := Vertical ? LT "|" LT "|" RB "|" RB : RB "|" RB "|" LT "|" LT
    hBitmap := CreateDIB(PixelData, 2, 2, W, H, True)
    oBitmap := DllCall("User32.dll\SendMessage", "Ptr", Hwnd, "UInt", 0x172, "Ptr", 0, "Ptr", hBitmap)
    return hBitmap, DllCall("Gdi32.dll\DeleteObject", "Ptr", oBitmap)
}

; https://autohotkey.com/boards/viewtopic.php?t=3203
CreateDIB(PixelData, W, H, ResizeW := 0, ResizeH := 0, Gradient := 1) {
    WB := Ceil((W * 3) / 2) * 2, VarSetCapacity(BMBITS, WB * H + 1, 0), P := &BMBITS
    loop, Parse, PixelData, |
        P := Numput("0x" A_LoopField, P + 0, 0, "UInt") - (W & 1 && Mod(A_Index * 3, W * 3) = 0 ? 0 : 1)

    hBM := DllCall("Gdi32.dll\CreateBitmap", "Int", W, "Int", H, "UInt", 1, "UInt", 24, "Ptr", 0, "Ptr")
    hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x2008, "Ptr")
    DllCall("Gdi32.dll\SetBitmapBits", "Ptr", hBM, "UInt", WB * H, "Ptr", &BMBITS)

    if !(Gradient + 0)
        hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x0008, "Ptr")
    return DllCall("User32.dll\CopyImage", "Ptr", hBM, "Int", 0, "Int", ResizeW, "Int", ResizeH, "Int", 0x200C, "UPtr")
}

ShowSettings:
    Gui Settings: New, +LabelSettings -MinimizeBox +OwnerMain
    Gui Color, White

    Gui Add, Text, hWndhGrad3 x9 y10 w637 h26 +0xE
    ApplyGradient(hGrad3, "008EBC", "3FBBE3")
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
    If (FileExist(A_AppData . "\AutoGUI\" . AppName . ".ini")) {
        IniFile := A_AppData . "\AutoGUI\" . AppName . ".ini"
    } Else {
        IniFile := AppName . ".ini"
    }

    IniRead Chk32bit, %IniFile%, Settings, 32bitOffsets, 0
    IniRead Chk64bit, %IniFile%, Settings, 64bitOffsets, 0
    IniRead PausePrompt, %IniFile%, Settings, PausePrompt, 0
    IniRead ChkNumGet, %IniFile%, Settings, NumGet, 1
    IniRead ChkNumPut, %IniFile%, Settings, NumPut, 1
    IniRead ShortTernary, %IniFile%, Settings, ShortTernary, 0

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
    If !(FileExist(IniFile)) {
        Sections := "[Settings]`n`n[Compiler]`n`n[Includes]`n"
        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %A_AppData%\AutoGUI
            IniFile := A_AppData . "\AutoGUI\" . AppName . ".ini"
            FileAppend %Sections%, %IniFile%, UTF-16
        }
    }

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
        GoSub ShowAbout
    }
}

ShowAbout:
    Gui Main: +Disabled
    Gui About: New, -SysMenu OwnerMain
    Gui Color, White
    Gui Add, Picture, x15 y16 w32 h32, %A_ScriptDir%\..\Icons\Structor.ico
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x56 y11 w120 h23 +0x200, %AppName%
    Gui Font, s9 cDefault, Segoe UI
    Gui Add, Text, x56 y34 h18 +0x200, Structure helper (v %Version%)
    Gui Add, Text, x1 y72 w391 h48 -Background
    Gui Add, Button, gAboutGuiClose x299 y85 w80 h23 Default, &OK
    Gui Show, w392 h120, About
Return

AboutGuiEscape:
AboutGuiClose:
    Gui Main: -Disabled
    Gui About: Destroy
Return

ShowHelp:
Gui Settings: +OwnDialogs
MsgBox 0, Help, %AppName% requires a C compiler. Supported: Visual Studio and MinGW.`n`n♦ Visual Studio`, Windows SDK`n`nCompiler Path: path to CL.EXE. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\cl.exe`n`nBatch File: path to VCVARS32.bat or VCVARS64.BAT. Example:`nC:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat`n`n♦ MinGW`, TDM-GCC`n`nCompiler Path: path to GCC.EXE. Example:`nC:\TDM-GCC-64\bin\gcc.exe`n`nBatch File: only needed if the gcc.exe directory is not in the PATH.`n`nEnable "Pause Command Prompt" to see compiler error messages.
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

#Include %A_ScriptDir%\..\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\..\Lib\RunGetStdout.ahk
