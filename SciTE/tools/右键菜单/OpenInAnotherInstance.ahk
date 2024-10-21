#Requires AutoHotkey v1.1.33+
#NoEnv
#NoTrayIcon
#SingleInstance Ignore

if (!oSciTE := GetSciTEInstance())
  ExitApp

exePath := oSciTE.SciTEDir "\SciTE.exe"
; 命令行参数中的所有路径必须像 c:/abc/bcd 而不是 c:\abc\bcd
filePath := StrReplace(A_Args[1], "\", "/")

; 用下面这种 -import 加载配置文件启动的形式会导致配色失效，原因未知
; Run, %exePath% "-import SciTE/Multi-opening" "-open:%filePath%"

; 配置多开参数
多开进程            = "-check.if.already.open=0"
禁止加载ahk辅助功能 = "-command.autorun="
只读模式            = "-read.only=1" "-read.only.indicator=1"
禁止保存            = "-ext.lua.startup.script=$(SciteDefaultHome)\extensions\openInAnotherInstance.lua"
状态栏提示          = "-statusbar.text.1=	Line: $(LineNumber) | Column: $(ColumnNumber) | $(OverType) | ($(EOLMode)) | $(FileAttr) 只读模式 | 禁止保存"
命令行              = %多开进程% %禁止加载ahk辅助功能% %只读模式% %禁止保存% %状态栏提示%

; 多开并取得多开进程句柄
Run, %exePath% %命令行% "-open:%filePath%",,, sub_pid
WinWaitActive, ahk_pid %sub_pid%
WinGet, sub_hwnd, ID, ahk_pid %sub_pid%
ControlGet, sub_hSci, Hwnd,, Scintilla1, ahk_id %sub_hwnd%

; 同步主进程当前浏览位置
; 必须先跳到文末，再跳回目标，最后用 SCI_LINESCROLL 修正
; 直接用 SCI_LINESCROLL 跳转位置会偏离，原因未知
firstVisibleLine := oSciTE.SciMsg(2152)                   ; SCI_GETFIRSTVISIBLELINE = 2152
firstDocLine     := oSciTE.SciMsg(2221, firstVisibleLine) ; SCI_DOCLINEFROMVISIBLE = 2221
SendMessage 2154, 0, 0,, ahk_id %sub_hSci%                ; SCI_GETLINECOUNT = 2154
SendMessage 2024, ErrorLevel, 0,, ahk_id %sub_hSci%       ; SCI_GOTOLINE = 2024
SendMessage 2024, firstDocLine, 0,, ahk_id %sub_hSci%
SendMessage 2168, 0, 1,, ahk_id %sub_hSci%                ; SCI_LINESCROLL = 2168

; 记录主进程窗口大小和位置
main_hwnd := oSciTE.SciTEHandle
WinGetPos, oldx, oldy, oldw, oldh, ahk_id %main_hwnd%

; 获取工作区尺寸，即不含任务栏的屏幕区域
; 这样就可以适应任务栏在桌面上下左右任意位置的布局
SysGet, WorkArea, MonitorWorkArea, 1
x := WorkAreaLeft
y := WorkAreaTop
w := (WorkAreaRight-WorkAreaLeft)//2
h := WorkAreaBottom-WorkAreaTop

; 对半分屏幕
MoveWindow(x, y, w, h, main_hwnd)
MoveWindow(w, y, w, h, sub_hwnd)

; 跟随多开进程退出
SetTimer, isSubExit, 500

; 主进程退出后直接杀多开进程，避免多开进程正常退出时覆盖主进程的会话列表
WinWaitClose, ahk_id %main_hwnd%
Process, Close, %sub_pid%

ExitApp

isSubExit:
  if (!WinExist("ahk_id " sub_hwnd))
  {
    WinMove, ahk_id %main_hwnd%, , oldx, oldy, oldw, oldh
    ExitApp
  }
return

; 此函数与 WinMove 命令的区别是
; 此函数设置的窗口大小 窗口可见区域与指定值一致
; WinMove 设置的窗口大小 窗口可见区域小于指定值（因为 win10 中窗口左右下三边均存在7像素的不可见区域）
MoveWindow(x, y, w, h, hwnd)
{
  DPIScale        := A_ScreenDPI/96
  winVersion      := StrSplit(A_OSVersion, ".", "", 1)[1]
  invisibleBorder := (winVersion >= 10) ? Round(7 * DPIScale) : 0
  
  x := x - invisibleBorder
  w := w + invisibleBorder*2
  h := h + invisibleBorder
  
  DllCall("MoveWindow", "Ptr", hwnd, "Int", x, "Int", y, "Int", w, "Int", h, "Int", 1)
}

#Include %A_LineFile%\..\..\Lib\GetSciTEInstance.ahk