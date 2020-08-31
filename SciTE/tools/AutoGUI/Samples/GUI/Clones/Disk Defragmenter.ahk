; Disk Defragmenter (Windows 7)

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetBatchLines -1

/*
If (DllCall("Kernel32.dll\GetVersion", "UChar") < 6) {
    MsgBox 0x10, Disk Defragmenter, This script requires Windows Vista or higher.
    ExitApp
}
*/

RegRead sShortDate, HKCU\Control Panel\International, sShortDate
RegRead sShortTime, HKCU\Control Panel\International, sShortTime

hModShell := LoadLibrary("shell32.dll")
hMainIcon := DllCall("LoadIcon", "Ptr", hModShell, "UInt", 167, "Ptr")

Menu Tray, Icon, HICON: %hMainIcon%

Gui Defrag: New, +LabelDefrag +hWndhDfrgWnd

Gui Font, s9, Segoe UI
Gui Color, White

;Gui Add, Picture, x18 y13 w32 h32 Icon81, shell32.dll
Gui Add, Picture, x18 y13 w32 h32, HICON: %hMainIcon%
Gui Add, Link, x60 y13 w558 h47, Disk Defragmenter consolidates fragmented files on your computer's hard disk to improve system performance. <a href="https://en.wikipedia.org/wiki/Disk_Defragmenter_(Windows)">Tell me more about Disk Defragmenter.</a>

Gui Add, Text, x12 y66 w79 h15, Schedule:
Gui Add, Text, x102 y75 w517 h1 +0x10
Gui Font, s9 Bold, Segoe UI
Gui Add, Text, x33 y94 w406 h15, Scheduled defragmentation is turned on
Gui Font, s9 Norm, Segoe UI
Gui Add, Text, x33 y114 w406 h15, % "Run at " . FormatHour("000000000100") . " every Wednesday"
Gui Add, Text, x33 y137 w406 h15, % "Next scheduled run: ‎" . FormatDateTime("201808080808")
Gui Add, Button, hWndhBtnCfgSch gConfigSchedule x406 y88 w191 h26, Configure &schedule...
SendMessage 0x160C, 0, 1,, ahk_id %hBtnCfgSch% ; BCM_SETSHIELD

Gui Add, Text, x12 y163 w110 h15, C&urrent status:
Gui Add, Text, x133 y171 w486 h1 +0x10
Gui Add, ListView, x12 y189 w606 h152 +NoSortHdr, Disk|Last Run|Progress
LV_ModifyCol(1, 180)
LV_ModifyCol(2, 240)
LV_ModifyCol(3, 150)

IL := IL_Create()
;IL_Add(IL, "imageres.dll", 32)
;IL_Add(IL, "shell32.dll", 80) ; 166
IL_Add(IL, "HICON:" . LoadIcon(hModShell, 166, 16))
If (FileExist(A_WinDir . "\System32\imageres.dll")) {
    IL_Add(IL, "HICON:" . LoadIcon(LoadLibrary("imageres.dll"), 36, 16))
}
LV_SetImageList(IL, 1)

SysDrvIcon := (DllCall("Kernel32.dll\GetVersion", "UChar") < 6) ? 1 : 2

; The true information could be retrieved from HKLM\SOFTWARE\Microsoft\Dfrg\Statistics
LV_Add("Select Icon" . SysDrvIcon, "System (C:)", FormatDateTime(201808150607) . " (0% fragmented)")
LV_Add("Icon1", "Data (D:)", FormatDateTime(201808150609) . " (0% fragmented)")
LV_Add("Icon1", "Files (F:)", FormatDateTime(201808150612) . " (0% fragmented)")

Gui Add, Text, x12 y351 w606 h49, Only disks that can be defragmented are shown.`nTo best determine if your disks need defragmenting right now, you need to first analyze your disks.

Gui Add, Button, hWndhBtnAnlzDsk x289 y399 w158 h26, &Analyze disk
SendMessage 0x160C, 0, 1,, ahk_id %hBtnAnlzDsk% ; BCM_SETSHIELD
Gui Add, Button, hWndhBtnDfrgDsk x460 y399 w158 h26 +Default, &Defragment disk
SendMessage 0x160C, 0, 1,, ahk_id %hBtnDfrgDsk% ; BCM_SETSHIELD

Gui Add, Text, x0 y428 w646 h1
Gui Add, Text, x-1 y429 w631 h46 -Background
Gui Add, Button, gDefragClose x529 y439 w88 h26, &Close

Gui Show, w629 h474, Disk Defragmenter
SendMessage 0x80, 0, hMainIcon,, ahk_id %hDfrgWnd% ; WM_SETICON

GuiControl Focus, %hBtnDfrgDsk%
SendInput {Alt 2}
Return

DefragEscape:
DefragClose:
    ExitApp

ConfigSchedule:
    Gui CfgSch: New, +LabelCfgSch +hWndhCfgSchWnd -MinimizeBox +OwnerDefrag
    RemoveWindowIcon(hCfgSchWnd)
    Gui Color, White

    Gui Add, Picture, x14 y13 w32 h32, % "HICON:" . LoadIcon(LoadLibrary("dfrgui.exe"), 137, 32)
    Gui Font, s9 Bold, Segoe UI
    Gui Add, Text, x67 y21 w326 h32, Disk defragmenter schedule configuration:
    Gui Font, s9 Norm, Segoe UI

    Gui Add, GroupBox, x14 y58 w399 h174
    Gui Add, CheckBox, x28 y58 w257 h19 +Checked, % "  &Run on a schedule (recommended)"
    Gui Add, Text, x28 y90 w105 h15, &Frequency:
    Gui Add, DropDownList, x177 y90 w224, Daily|Weekly||Monthly
    Gui Add, Text, x28 y124 w105 h28, &Day:
    Gui Add, DropDownList, x177 y124 w224, Sunday|Monday|Tuesday|Wednesday||Thursday|Friday|Saturday

    Times := ""
    Loop 24 {
        If (A_Index == 1) {
            Append := " (midnight)|"
        } Else If (A_Index == 2) {
            Append := "||"
        } Else If (A_Index == 13) {
            Append := " (noon)|"
        } Else {
            Append := "|"
        }
        
        Times .= FormatHour(Format("{:010}", A_Index - 1)) . Append
    }
    Gui Add, Text, x28 y158 w105 h15, &Time:
    Gui Add, DropDownList, x177 y158 w224, %Times%

    Gui Add, Text, x28 y189 w105 h15, D&isks:
    Gui Add, Button, gSelectDisks x177 y189 w224 h26, &Select disks...

    Gui Add, Text, x0 y246 w424 h1 +0x5
    Gui Add, Text, x-1 y248 w426 h47 -Background
    Gui Add, Button, x229 y259 w88 h26  +Disabled, &OK
    Gui Add, Button, gCfgSchClose x326 y259 w88 h26, &Cancel

    WI := GetWindowInfo(hDfrgWnd)
    X := WI.ClientX + WI.BorderW + 2
    Y := WI.ClientY + WI.BorderH + 2
    Gui Show, x%X% y%Y% w424 h294, Disk Defragmenter: Modify Schedule

    Gui Defrag: +Disabled
Return

CfgSchEscape:
CfgSchClose:
    Gui Defrag: -Disabled
    Gui CfgSch: Destroy
Return

SelectDisks:
    Gui Disks: New, +LabelDisks +hWndhDisksWnd -MinimizeBox +OwnerCfgSch
    RemoveWindowIcon(hDisksWnd)
    Gui Color, White
    Gui Font, s9, Segoe UI

    Gui Add, Text, x12 y13 w413 h36, Select the checkbox for each disk you want to defragmented on a schedule.
    Gui Add, Text, x12 y49 w413 h21, &Disks to include in schedule:

    Gui Add, ListView, x12 y69 w413 h171 -Hdr +Checked -LV0x30 +0x40, Disks ; 0x40: LVS_SHAREIMAGELISTS
    LV_SetImageList(IL, 1)
    LV_Add("Check", "Select all disks")
    LV_Add("Icon1 Check", "System (C:)")
    LV_Add("Icon1 Check", "Data (D:)")
    LV_Add("Icon1 Check", "Files (F:)")
    Gui Add, CheckBox, x12 y253 w413 h19 +Checked, &Automatically defragment new disks

    Gui Add, Text, x0 y293 w438 h1 +0x5
    Gui Add, Text, x-1 y295 w440 h53 -Background
    Gui Add, Button, x243 y308 w88 h26  +Disabled, &OK
    Gui Add, Button, gDisksClose x338 y308 w88 h26, &Cancel

    WI := GetWindowInfo(hCfgSchWnd)
    X := WI.ClientX + WI.BorderW + 2
    Y := WI.ClientY + WI.BorderH + 2
    Gui Show, x%X% y%Y% w438 h347, Disk Defragmenter: Select Disks For Schedule

    Gui CfgSch: +Disabled
Return

DisksEscape:
DisksClose:
    Gui CfgSch: -Disabled
    Gui Disks: Destroy
Return

LoadLibrary(DllName) {
    Return DllCall("kernel32.dll\LoadLibraryEx", "Str", DllName, "UInt", 0, "UInt", 0x2, "Ptr")
}

LoadIcon(hModule, ResID, Size := 32) {
    Return DllCall("LoadImage", "Ptr", hModule, "Ptr", ResID, "Int", 1, "Int", Size, "Int", Size, "UInt", 0, "Ptr")
}

RemoveWindowIcon(hWnd) {
    DllCall("uxtheme.dll\SetWindowThemeAttribute", "Ptr", hWnd, "UInt", 1, "Int64*", 6 | 6 << 32, "UInt", 8)    
}

FormatDateTime(Timestamp) {
    Global
    FormatTime DateTime, %Timestamp%, %sShortDate% %sShortTime%
    ;FormatTime DateTime, %Timestamp% D1
    ;DateTime := RegExReplace(DateTime, "(.*)\s(.*)", "$2 $1")
    Return DateTime
}

FormatHour(Time) {
    Global
    FormatTime Time, %Time%, %sShortTime%
    Return Time
}

GetWindowInfo(hWnd) {
    NumPut(VarSetCapacity(WINDOWINFO, 60, 0), WINDOWINFO, 0, "UInt")
    DllCall("GetWindowInfo", "Ptr", hWnd, "Ptr", &WINDOWINFO)
    wi := Object()
    wi.WindowX := NumGet(WINDOWINFO, 4, "Int")
    wi.WindowY := NumGet(WINDOWINFO, 8, "Int")
    wi.WindowW := NumGet(WINDOWINFO, 12, "Int") - wi.WindowX
    wi.WindowH := NumGet(WINDOWINFO, 16, "Int") - wi.WindowY
    wi.ClientX := NumGet(WINDOWINFO, 20, "Int")
    wi.ClientY := NumGet(WINDOWINFO, 24, "Int")
    wi.ClientW := NumGet(WINDOWINFO, 28, "Int") - wi.ClientX
    wi.ClientH := NumGet(WINDOWINFO, 32, "Int") - wi.ClientY
    wi.Style   := NumGet(WINDOWINFO, 36, "UInt")
    wi.ExStyle := NumGet(WINDOWINFO, 40, "UInt")
    wi.Active  := NumGet(WINDOWINFO, 44, "UInt")
    wi.BorderW := NumGet(WINDOWINFO, 48, "UInt")
    wi.BorderH := NumGet(WINDOWINFO, 52, "UInt")
    Return wi
}
