; Script Directives

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Global Version := "1.0.0"
, CRLF := "`r`n"
, hCursorHelp
, g_Helping := False
, g_HelpFile := A_ScriptDir . "\..\Help\AutoHotkey.chm"
, g_AutoGUI
, g_AutoGUIPath := A_ScriptDir . "\..\AutoGUI.ahk"
, g_StrRequireAdmin
, g_StrRequireVista
, g_StrRequire32bit
, g_StrRequire64bit
, g_StrRequireUnicode
;, g_IndentWithTab := False

Menu Tray, Icon, %A_ScriptDir%\..\Icons\Directives.ico

Gui +hWndhMainWnd
Gui Add, Edit, hWndhEdtIPC x0 y0 w0 h0 ReadOnly Hide

Gui Font, s9, Segoe UI
Gui Add, Tab3, x8 y8 w334 h424 -Wrap, Common|Speed|Hotkeys|Others|Require|Includes

Gui Tab, 1 ; Common
Gui Add, CheckBox, vChkSingleInstance x20 y45 w156 h23 +Checked, #SingleInstance
Gui Add, DropDownList, vDDLSingleInstance x180 y45 w148, Force||Ignore|Off
Gui Add, CheckBox, vChkNoEnv x20 y72 w156 h23 +Checked, #NoEnv
Gui Add, CheckBox, vChkNoTrayIcon x20 y100 w156 h23, #NoTrayIcon
Gui Add, CheckBox, vChkPersistent x20 y128 w156 h23, #Persistent
Gui Add, CheckBox, vChkWarn x20 y157 w156 h23, #Warn
Gui Add, Text, x57 y184 w120 h23 +0x200, Warning Type:
Gui Add, DropDownList, vDDLWarnType x180 y185 w148
, All||LocalSameAsGlobal|UseUnsetLocal|UseUnsetGlobal|UseEnv|ClassOverwrite
Gui Add, Text, x57 y213 w120 h23 +0x200, Warning Mode:
Gui Add, DropDownList, vDDLWarnMode x180 y213 w148, MsgBox||StdOut|OutputDebug|Off
Gui Add, CheckBox, vChkSetWorkingDir x20 y245 w156 h23 +Checked, SetWorkingDir
Gui Add, Edit, vEdtSetWorkingDir x181 y245 w148 h21, `%A_ScriptDir`%
Gui Add, CheckBox, vChkSendMode x20 y275 w156 h23, SendMode
Gui Add, DropDownList, vDDLSendMode x181 y275 w148, Input||Play|Event|InputThenPlay
Gui Add, CheckBox, vChkSetBatchLines x20 y305 w156 h23 +Checked, SetBatchLines
Gui Add, Edit, vEdtSetBatchLines x180 y305 w148, -1
Gui Add, CheckBox, vChkDetectHiddenWindows x20 y335 w156 h23, DetectHiddenWindows
Gui Add, DropDownList, vDDLDetectHiddenWindows x180 y334 w148, On||Off
Gui Add, CheckBox, vChkFileEncoding x20 y365 w156 h23, FileEncoding
Gui Add, ComboBox, vCbxFileEncoding x180 y364 w148, ANSI|UTF-8||UTF-16
Gui Add, CheckBox, vChkProcessPriority x20 y395 w155 h23, Process Priority
Gui Add, DropDownList, vDDLProcessPriority x180 y394 w148, Low|Below Normal|Normal|Above Normal|High||Realtime

Gui Tab
Gui Add, Button, gGenerateCode x76 y444 w84 h24 +Default, &OK
Gui Add, Button, gGuiClose x166 y444 w84 h24, &Cancel
Gui Add, Button, gStartHelp x256 y444 w84 h24, &Help

Gui Show, w349 h481, Script Directives

Gui Tab, 2 ; Speed
Gui Add, CheckBox, vChkSetTitleMatchMode x20 y45 w156 h23, SetTitleMatchMode
Gui Add, DropDownList, vDDLSetTitleMatchMode x180 y45 w148, 1|2||3|RegEx
Gui Add, CheckBox, vChkSetTitleMatchSpeed x20 y74 w156 h23, SetTitleMatchMode
Gui Add, DropDownList, vDDLSetTitleMatchSpeed x180 y74 w148, Fast|Slow||
Gui Add, CheckBox, vChkWinActivateForce x20 y101 w156 h23, #WinActivateForce
Gui Add, CheckBox, vChkSetWinDelay x20 y129 w156 h23, SetWinDelay
Gui Add, Edit, vEdtSetWinDelay x180 y130 w148 h21, -1
Gui Add, CheckBox, vChkSetControlDelay x20 y157 w156 h23, SetControlDelay
Gui Add, Edit, vEdtSetControlDelay x180 y158 w148 h21, -1
Gui Add, CheckBox, vChkSetKeyDelay x20 y185 w120 h23, SetKeyDelay
Gui Add, Edit, vEdtSetKeyDelay hWndhEdtSetKeyDelay x180 y186 w48 h21, -1
SetToolTip(hEdtSetKeyDelay, "Delay")
Gui Add, Edit, vEdtSetKeyDelayDuration hWndhEdtSetKeyDelayDuration x232 y186 w48 h21
SetToolTip(hEdtSetKeyDelayDuration, "Press duration")
Gui Add, CheckBox, vChkSetKeyDelayPlay x287 y186 w48 h23, Play
Gui Add, CheckBox, vChkSetMouseDelay x20 y214 w156 h23, SetMouseDelay
Gui Add, Edit, vEdtSetMouseDelay x181 y215 w98 h21, -1
Gui Add, CheckBox, vChkSetMouseDelayPlay x287 y214 w48 h23, Play
Gui Add, CheckBox, vChkSetDefaultMouseSpeed x20 y245 w156 h23, SetDefaultMouseSpeed
Gui Add, Edit, vEdtSetDefaultMouseSpeed x180 y246 w148, 0
Gui Add, CheckBox, vChkCoordModeMouse x20 y275 w156 h23, CoordMode Mouse
Gui Add, DropDownList, vDDLCoordModeMouse x180 y275 w148, Screen||Window|Client
Gui Add, CheckBox, vChkCoordModeCaret x20 y305 w156 h23, CoordMode Caret
Gui Add, DropDownList, vDDLCoordModeCaret x180 y305 w148, Screen||Window|Client
Gui Add, CheckBox, vChkCoordModePixel x20 y335 w156 h23, CoordMode Pixel
Gui Add, DropDownList, vDDLCoordModePixel x180 y335 w148, Screen||Window|Client
Gui Add, CheckBox, vChkCoordModeMenu x20 y364 w156 h23, CoordMode Menu
Gui Add, DropDownList, vDDLCoordModeMenu x180 y364 w148, Screen||Window|Client
Gui Add, CheckBox, vChkCoordModeToolTip x20 y394 w155 h23, CoordMode ToolTip
Gui Add, DropDownList, vDDLCoordModeToolTip x180 y394 w148, Screen||Window|Client

Gui Tab, 3 ; Hotkeys
Gui Add, CheckBox, vChkMaxThreads x20 y45 w156 h23, #MaxThreads
Gui Add, Edit, vEdtMaxThreads x181 y46 w148 h21, 255
Gui Add, CheckBox, vChkMaxThreadsPerHotkey x20 y73 w156 h23, #MaxThreadsPerHotkey
Gui Add, Edit, vEdtMaxThreadsPerHotkey x181 y74 w148 h21, 2
Gui Add, CheckBox, vChkHotkeyInterval x20 y101 w156 h23, #HotkeyInterval
Gui Add, Edit, vEdtHotkeyInterval x181 y102 w148 h21, 200
Gui Add, CheckBox, vChkMaxHotkeysPerInterval x20 y130 w156 h23, #MaxHotkeysPerInterval
Gui Add, Edit, vEdtMaxHotkeysPerInterval x181 y131 w148 h21, 200
Gui Add, CheckBox, vChkMaxThreadsBuffer x20 y157 w156 h23, #MaxThreadsBuffer
Gui Add, DropDownList, vDDLMaxThreadsBuffer x181 y157 w148, On||Off
Gui Add, CheckBox, vChkHotkeyModifierTimeout x20 y185 w156 h23, #HotkeyModifierTimeout
Gui Add, Edit, vEdtHotkeyModifierTimeout x181 y186 w148 h21, 100
Gui Add, CheckBox, vChkHotstringNoMouse x20 y214 w156 h23, #Hotstring NoMouse
Gui Add, CheckBox, vChkHotstringEndChars x20 y245 w156 h23, #Hotstring EndChars
Gui Add, Edit, vEdtHotstringEndChars x181 y246 w148 h21
Gui Add, CheckBox, vChkHotstringOptions x20 y275 w156 h23, #Hotstring Options
Gui Add, Edit, vEdtHotstringOptions x181 y276 w148 h21
Gui Add, CheckBox, vChkInputLevel x20 y305 w156 h23, #InputLevel
Gui Add, Edit, vEdtInputLevel x181 y306 w148 h21, 1
Gui Add, CheckBox, vChkInstallKeybdHook x20 y335 w156 h23, #InstallKeybdHook
Gui Add, CheckBox, vChkInstallMouseHook x20 y365 w156 h23, #InstallMouseHook
Gui Add, CheckBox, vChkUseHook x20 y395 w155 h23, #UseHook
Gui Add, DropDownList, vDDLUseHook x181 y394 w148, On||Off

Gui Tab, 4 ; Others
Gui Add, CheckBox, vChkStringCaseSense x20 y45 w156 h23, StringCaseSense
Gui Add, DropDownList, vDDLStringCaseSense x181 y45 w148, On||Off|Locale
Gui Add, CheckBox, vChkAutoTrim x20 y74 w156 h23, AutoTrim
Gui Add, DropDownList, vDDLAutoTrim x181 y74 w148, On|Off||
Gui Add, CheckBox, vChkDetectHiddenText x20 y103 w156 h23, DetectHiddenText
Gui Add, DropDownList, vDDLDetectHiddenText x181 y103 w148, On|Off||
Gui Add, CheckBox, vChkSetStoreCapsLockMode x20 y133 w156 h23, SetStoreCapsLockMode
Gui Add, DropDownList, vDDLSetStoreCapsLockMode x181 y132 w148, On|Off||
Gui Add, CheckBox, vChkSetRegView x20 y161 w156 h23, SetRegView
Gui Add, DropDownList, vDDLSetRegView x181 y161 w148, 32||64
Gui Add, CheckBox, vChkMaxMem x20 y191 w156 h23, #MaxMem
Gui Add, Edit, vEdtMaxMem x181 y192 w148 h21, 640
Gui Add, CheckBox, vChkClipboardTimeout x20 y219 w156 h23, #ClipboardTimeout
Gui Add, Edit, vEdtClipboardTimeout x181 y220 w148 h21, 2000
Gui Add, CheckBox, vChkMenuMaskKey x20 y247 w156 h23, #MenuMaskKey
Gui Add, Edit, vEdtMenuMaskKey x181 y248 w148 h21, vk07
Gui Add, CheckBox, vChkKeyHistory x20 y276 w156 h23, #KeyHistory
Gui Add, Edit, vEdtKeyHistory x181 y277 w148 h21, 0
Gui Add, CheckBox, vChkListLines x20 y306 w156 h23, ListLines
Gui Add, DropDownList, vDDLListLines x181 y306 w148, On|Off||
Gui Add, CheckBox, vChkThreadNoTimers x20 y336 w156 h23, Thread NoTimers
Gui Add, CheckBox, vChkMenuTrayClick1 x20 y366 w180 h23, Menu Tray, Click, 1
Gui Add, CheckBox, vChkMenuTrayUseErrorLevel x20 y395 w156 h23, Menu Tray, UseErrorLevel

Gui Tab, 5 ; Require
Gui Add, CheckBox, hWndhChkRequireAdmin vChkRequireAdmin x20 y45 w156 h23, Require Administrator
SetToolTip(hChkRequireAdmin, "Require administrative privileges to execute the script.")
Gui Add, CheckBox, hWndhChkRequireVista vChkRequireVista x20 y73 w156 h23, Require Vista+
SetToolTip(hChkRequireVista, "Some Windows features require Windows Vista or higher.")
Gui Add, CheckBox, hWndhChkRequire32bit vChkRequire32bit x20 y101 w156 h23, Require AHK 32-bit
SetToolTip(hChkRequire32bit, "Some scripts may not be compatible with AutoHotkey 64-bit.")
Gui Add, CheckBox, hWndhChkRequire64bit vChkRequire64bit x20 y130 w156 h23, Require AHK 64-bit
SetToolTip(hChkRequire64bit, "Some scripts may not be compatible with AutoHotkey 32-bit.")
Gui Add, CheckBox, hWndhChkRequireUnicode vChkRequireUnicode x20 y157 w156 h23, Require Unicode
SetToolTip(hChkRequireUnicode, "Some scripts may not be compatible with the ANSI build of AHK.")

Gui Tab, 6 ; Includes
Gui Add, ListView, hWndhLVIncludes x20 y43 w309 h350 -Hdr +LV0x114004, Test
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLVIncludes, "WStr", "Explorer", "Ptr", 0)
Gui Add, Link, gShowIncludesHelp x20 y401 w300 h23, <A>Where are libraries located?</A>

;LV_InsertGroup(hLVIncludes, 1, "Local Library") ; %A_ScriptDir%\Lib\
LV_InsertGroup(hLVIncludes, 2, "User Library")
LV_InsertGroup(hLVIncludes, 3, "Standard Library")

Loop Files, %A_MyDocuments%\AutoHotkey\Lib\*.ah*, R
{
    Row := LV_Add("", A_LoopFileName)
    LV_SetGroup(hLVIncludes, Row, 2)
}

Loop Files, %A_AhkPath%\..\Lib\*.ah*, R
{
    Row := LV_Add("", A_LoopFileName)
    LV_SetGroup(hLVIncludes, Row, 3)
}

SendMessage 0x109D, 1, 0,, ahk_id %hLVIncludes% ; LVM_ENABLEGROUPVIEW

Gui Tab

OnMessage(0x201, "OnWM_LBUTTONDOWN")
OnMessage(0x20,  "OnWM_SETCURSOR")
OnMessage(0x112, "OnWM_SYSCOMMAND")

hSysMenu := DllCall("GetSystemMenu", "Ptr", hMainWnd, "Int", False, "Ptr")
DllCall("InsertMenu", "Ptr", hSysMenu, "UInt", 5, "UInt", 0x401, "UPtr", 0x5DEF, "Str", "Save as default")
DllCall("InsertMenu", "Ptr", hSysMenu, "UInt", 5, "UInt", 0x401, "UPtr", 0x4DEF, "Str", "Restore defaults")
DllCall("InsertMenu", "Ptr", hSysMenu, "UInt", 5, "UInt", 0xC00, "UPtr", 0, "Str", "") ; Separator

g_StrRequireAdmin =
(
CommandLine := DllCall("GetCommandLine", "Str")

If !(A_IsAdmin || RegExMatch(CommandLine, " /restart(?!\S)")) {
    Try {
        If (A_IsCompiled) {
            Run *RunAs "`%A_ScriptFullPath`%" /restart
        } Else {
            Run *RunAs "`%A_AhkPath`%" /restart "`%A_ScriptFullPath`%"
        }
    }
    ExitApp
}
)

g_StrRequireVista =
(
If (DllCall("Kernel32.dll\GetVersion", "UChar") < 6) {
    MsgBox 0x10,, This program requires Windows Vista or higher.
    ExitApp
}
)

g_StrRequire32bit =
(
If (A_PtrSize != 4) {
    SplitPath A_AhkPath,, AhkDir
    AhkPath := AhkDir . "\AutoHotkeyU32.exe"
    Run "`%AhkPath`%" "`%A_ScriptFullPath`%"
    ExitApp
}
)

g_StrRequire64bit =
(
If (A_PtrSize == 4) {
    SplitPath A_AhkPath,, AhkDir
    AhkPath := AhkDir . "\AutoHotkeyU64.exe"
    Run "`%AhkPath`%" "`%A_ScriptFullPath`%"
    ExitApp
}
)

g_StrRequireUnicode =
(
If !(A_IsUnicode) {
    SplitPath A_AhkPath,, AhkDir
    AhkPath := AhkDir . "\AutoHotkey" . (A_Is64bitOS ? "U64" : "U32") . ".exe"
    Run "`%AhkPath`%" "`%A_ScriptFullPath`%"
    ExitApp
}
)

/*
If (g_IndentWithTab) {

}
*/

g_AutoGUI := InStr(DllCall("GetCommandLine", "Str"), " /AutoGUI")
Return

GuiEscape:
GuiClose:
    ExitApp

NotifyAutoGUI:
    SendMessage 10000, 3, hEdtIPC,, % "ahk_id " . GetAutoGUIHandle(g_AutoGUIPath)
Return

GetAutoGUIHandle(AutoGUIPath) {
    If (!hWnd := WinExist("AutoGUI v")) {
        Try {
            Run %AutoGUIPath%,,, AutoGUIPID
        } Catch e {
            MsgBox 0x10, Error %A_LastError%, % e.Message . "`n`n" . e.Extra
            Return
        }

        WinWaitActive ahk_pid %AutoGUIPID%,, 3
        If (ErrorLevel) {
            MsgBox 0x15, Error, Window activation timed out. Try again?
            IfMsgBox Retry, {
                GetAutoGUIHandle(AutoGUIPath)
            }
            Return
        } Else {
            WinGet hWnd, ID, ahk_pid %AutoGUIPID%
        }
    }

    Return hWnd
}

StartHelp() {
    g_Helping := True
    hCursorHelp := DllCall("LoadCursor", "UInt", 0, "UInt", 32651)
}

OnWM_SETCURSOR(wParam, lParam, msg, hWnd) {
    If (g_Helping) {
        DllCall("SetCursor", "Ptr", hCursorHelp)
        Return True
    }
}

OnWM_LBUTTONDOWN(wParam, lParam, msg, hWnd) {
    If (g_Helping) {
        ShowHelp(hWnd)
        Return g_Helping := False
    }
}

ShowHelp(hWnd) {
    GuiControlGet Pos, Pos, %hWnd%
    If (PosX > 30) { ; Skip controls on the right side
        Return
    }

    GuiControlGet Keyword,, %hWnd%, Text

    Keyword := StrReplace(Keyword, "#", "_",, 1)

    If (Pos := InStr(Keyword, " ")) {
        Keyword := SubStr(Keyword, 1, Pos - 1)
    }

    If (Keyword == "Require" || Keyword == "" || Keyword == "<A>Where") {
        Return
    }

    Run hh mk:@MSITStore:%g_HelpFile%::/docs/commands/%Keyword%.htm
}

SetToolTip(hWnd, Text, Title := "", Icon := 0, Balloon := False) {
    Local hTT, Style
    Style := Balloon ? 0x142 : 0x2

    hTT := DllCall("CreateWindowEx", "UInt", 0x8, "Str", "TOOLTIPS_CLASS32", "Str", "", "UInt", Style
        , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt", 0, "Ptr")

    NumPut(VarSetCapacity(TOOLINFO, (A_PtrSize == 8) ? 64 : 44, 0), TOOLINFO, 0, "UInt")
    NumPut(0x11,  TOOLINFO, 4, "UInt") ; uFlags (TTF_IDISHWND | TTF_SUBCLASS)
    NumPut(hWnd,  TOOLINFO, 8 + A_PtrSize, "Ptr")
    NumPut(&Text, TOOLINFO, (A_PtrSize == 8) ? 48 : 36, "Ptr")
    ; TTM_ADDTOOL
    DllCall("SendMessage", "Ptr", hTT, "UInt", A_IsUnicode ? 0x432 : 0x404, "UPtr", 0, "UPtr", &TOOLINFO)
    ; TTM_SETTITLE
    DllCall("SendMessage", "Ptr", hTT, "UInt", A_IsUnicode ? 0x421 : 0x420, "UPtr", Icon, "Str", Title)

    Return hTT
}

OnWM_SYSCOMMAND(wParam, lParam, msg, hWnd) {
    If (wParam == 0x4DEF) { ; Restore defaults

    } Else If (wParam == 0x5DEF) { ; Save as default

    }
}

GenerateCode:
    Gui Submit, NoHide

    Code := ""

    ; Common tab

    If (ChkSingleInstance) {
        Code .= "#SingleInstance " . DDLSingleInstance . CRLF
    }

    If (ChkNoEnv) {
        Code .= "#NoEnv" . CRLF
    }

    If (ChkNoTrayIcon) {
        Code .= "#NoTrayIcon" . CRLF
    }

    If (ChkPersistent) {
        Code .= "#Persistent" . CRLF
    }

    If (ChkWarn) {
        Code .= "#Warn"

        If (DDLWarnType != "All") {
            Code .= " " . DDLWarnType
        }

        If (DDLWarnMode != "MsgBox") {
            If (DDLWarnType != "All") {
                Code .= ", "
            } Else {
                Code .= ",, "
            }

            Code .= DDLWarnMode
        }

        Code .= CRLF
    }

    If (ChkSetWorkingDir) {
        Code .= "SetWorkingDir " . EdtSetWorkingDir . CRLF
    }

    If (ChkSendMode) {
        Code .= "SendMode " . DDLSendMode . CRLF
    }

    If (ChkSetBatchLines) {
        Code .= "SetBatchLines " . EdtSetBatchLines . CRLF
    }

    If (ChkDetectHiddenWindows) {
        Code .= "DetectHiddenWindows " . DDLDetectHiddenWindows . CRLF
    }

    If (ChkFileEncoding) {
        Code .= "FileEncoding " . CbxFileEncoding . CRLF
    }

    If (ChkProcessPriority) {
        Code .= "Process Priority,, " . DDLProcessPriority . CRLF
    }

    ; Speed tab

    If (ChkSetTitleMatchMode) {
        Code .= "SetTitleMatchMode " . DDLSetTitleMatchMode . CRLF
    }

    If (ChkSetTitleMatchSpeed) {
        Code .= "SetTitleMatchMode " . DDLSetTitleMatchSpeed . CRLF
    }

    If (ChkWinActivateForce) {
        Code .= "#WinActivateForce" . CRLF
    }

    If (ChkSetWinDelay) {
        Code .= "SetWinDelay " . EdtSetWinDelay . CRLF
    }

    If (ChkSetControlDelay) {
        Code .= "SetControlDelay " . EdtSetControlDelay . CRLF
    }

    If (ChkSetKeyDelay) {
        Code .= "SetKeyDelay"
        Temp := ""
        Flag := False

        If (ChkSetKeyDelayPlay) {
            Temp := ", Play"
            Flag := True
        }

        If (EdtSetKeyDelayDuration != "") {
            Temp := ", " . EdtSetKeyDelayDuration . Temp
            Flag := True
        } Else If (Flag) {
            Temp := "," . Temp
        }

        If (EdtSetKeyDelay != "") {
            Temp := " " . EdtSetKeyDelay . Temp
        } Else If (Flag) {
            Temp := "," . Temp
        }

        Code .= Temp . CRLF
    }

    If (ChkSetMouseDelay) {
        Code .= "SetMouseDelay"

        If (EdtSetMouseDelay != "") {
            Code .= " " EdtSetMouseDelay
        }

        If (ChkSetMouseDelayPlay) {
            If (EdtSetMouseDelay != "") {
                Code .= ", Play"
            } Else {
                Code .= ",, Play"
            }
        }

        Code .= CRLF
    }

    If (ChkSetDefaultMouseSpeed) {
        Code .= "SetDefaultMouseSpeed " . EdtSetDefaultMouseSpeed . CRLF
    }

    If (ChkCoordModeMouse) {
        Code .= "CoordMode Mouse, " . DDLCoordModeMouse . CRLF
    }

    If (ChkCoordModeCaret) {
        Code .= "CoordMode Caret, " . DDLCoordModeCaret . CRLF
    }

    If (ChkCoordModePixel) {
        Code .= "CoordMode Pixel, " . DDLCoordModePixel . CRLF
    }

    If (ChkCoordModeMenu) {
        Code .= "CoordMode Menu, " . DDLCoordModeMenu . CRLF
    }

    If (ChkCoordModeToolTip) {
        Code .= "CoordMode ToolTip, " . DDLCoordModeToolTip . CRLF
    }

    ; Hotkeys tab

    If (ChkMaxThreads) {
        Code .= "#MaxThreads " . EdtMaxThreads . CRLF
    }

    If (ChkMaxThreadsPerHotkey) {
        Code .= "#MaxThreadsPerHotkey " . EdtMaxThreadsPerHotkey . CRLF
    }

    If (ChkHotkeyInterval) {
        Code .= "#HotkeyInterval " . EdtHotkeyInterval . CRLF
    }

    If (ChkMaxHotkeysPerInterval) {
        Code .= "#MaxHotkeysPerInterval " . EdtMaxHotkeysPerInterval . CRLF
    }

    If (ChkMaxThreadsBuffer) {
        Code .= "#MaxThreadsBuffer " . DDLMaxThreadsBuffer . CRLF
    }

    If (ChkHotkeyModifierTimeout) {
        Code .= "#HotkeyModifierTimeout " . EdtHotkeyModifierTimeout . CRLF
    }

    If (ChkHotstringNoMouse) {
        Code .= "#Hotstring NoMouse" . CRLF
    }

    If (ChkHotstringEndChars) {
        Code .= "#Hotstring EndChars " . EdtHotstringEndChars . CRLF
    }

    If (ChkHotstringOptions) {
        Code .= "#Hotstring Options " . EdtHotstringOptions . CRLF
    }

    If (ChkInputLevel) {
        Code .= "#InputLevel " . EdtInputLevel . CRLF
    }

    If (ChkInstallKeybdHook) {
        Code .= "#InstallKeybdHook" . CRLF
    }

    If (ChkInstallMouseHook) {
        Code .= "#InstallMouseHook" . CRLF
    }

    If (ChkUseHook) {
        Code .= "#UseHook " . DDLUseHook . CRLF
    }

    ; Others tab

    If (ChkStringCaseSense) {
        Code .= "StringCaseSense " . DDLStringCaseSense . CRLF
    }

    If (ChkAutoTrim) {
        Code .= "AutoTrim " . DDLAutoTrim . CRLF
    }

    If (ChkDetectHiddenText) {
        Code .= "DetectHiddenText " . DDLDetectHiddenText . CRLF
    }

    If (ChkSetStoreCapsLockMode) {
        Code .= "SetStoreCapsLockMode " . DDLSetStoreCapsLockMode . CRLF
    }

    If (ChkSetRegView) {
        Code .= "SetRegView " . DDLSetRegView . CRLF
    }

    If (ChkMaxMem) {
        Code .= "#MaxMem " . EdtMaxMem . CRLF
    }

    If (ChkClipboardTimeout) {
        Code .= "#ClipboardTimeout " . EdtClipboardTimeout . CRLF
    }

    If (ChkMenuMaskKey) {
        Code .= "#MenuMaskKey " . EdtMenuMaskKey . CRLF
    }

    If (ChkKeyHistory) {
        Code .= "#KeyHistory " . EdtKeyHistory . CRLF
    }

    If (ChkListLines) {
        Code .= "ListLines " . DDLListLines . CRLF
    }

    If (ChkThreadNoTimers) {
        Code .= "Thread NoTimers" . CRLF
    }

    If (ChkMenuTrayClick1) {
        Code .= "Menu Tray, Click, 1" . CRLF
    }

    If (ChkMenuTrayUseErrorLevel) {
        Code .= "Menu Tray, UseErrorLevel" . CRLF
    }

    Gui ListView, %hLVIncludes%
    Row := 0
    Includes := CRLF
    Loop {
        Row := LV_GetNext(Row, "Checked")
        If (!Row) {
            Break
        }

        LV_GetText(Filename, Row, 1)
        SplitPath Filename,,,, NameNoExt
        Includes .= "#Include <" . NameNoExt . ">" . CRLF
    }

    If (Includes != CRLF) {
        Code .= Includes
    }

    If (ChkRequireAdmin) {
        Code .= CRLF . g_StrRequireAdmin . CRLF
    }

    If (ChkRequireVista) {
        Code .= CRLF . g_StrRequireVista . CRLF
    }

    If (ChkRequire32bit) {
        Code .= CRLF . g_StrRequire32bit . CRLF
    }

    If (ChkRequire64bit) {
        Code .= CRLF . g_StrRequire64bit . CRLF
    }

    If (ChkRequireUnicode) {
        Code .= CRLF . g_StrRequireUnicode . CRLF
    }

    If (g_AutoGUI && !GetKeyState("Shift", "P")) {
        GuiControl,, %hEdtIPC%, %Code%
        GoSub NotifyAutoGUI
    } Else {
        Gui +OwnDialogs
        MsgBox 0x40, Copied to the Clipboard, % Clipboard := Code
        ExitApp
    }
Return

LV_InsertGroup(hLV, GroupID, Header, Index := -1) {
    Static iGroupId := (A_PtrSize == 8) ? 36 : 24
    NumPut(VarSetCapacity(LVGROUP, 56, 0), LVGROUP, 0)
    NumPut(0x15, LVGROUP, 4, "UInt") ; mask: LVGF_HEADER|LVGF_STATE|LVGF_GROUPID
    NumPut(A_IsUnicode ? &Header : UTF16(Header, @), LVGROUP, 8, "Ptr") ; pszHeader
    NumPut(GroupID, LVGROUP, iGroupId, "Int") ; iGroupId
    NumPut(0x8, LVGROUP, iGroupId + 8, "Int") ; state: LVGS_COLLAPSIBLE
    SendMessage 0x1091, %Index%, % &LVGROUP,, ahk_id %hLV% ; LVM_INSERTGROUP
    Return ErrorLevel
}

LV_SetGroup(hLV, Row, GroupID) {
    Static iGroupId := (A_PtrSize == 8) ? 52 : 40
    VarSetCapacity(LVITEM, 58, 0)
    NumPut(0x100, LVITEM, 0, "UInt")  ; mask: LVIF_GROUPID
    NumPut(Row - 1, LVITEM, 4, "Int") ; iItem
    NumPut(GroupID, LVITEM, iGroupId, "Int")
    SendMessage 0x1006, 0, &LVITEM,, ahk_id %HLV% ; LVM_SETITEMA
    Return ErrorLevel
}

UTF16(String, ByRef Var) {
    VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
    StrPut(String, &Var, "UTF-16")
    Return &Var
}

ShowIncludesHelp() {
    Run hh mk:@MSITStore:%g_HelpFile%::/docs/Functions.htm#lib
}
