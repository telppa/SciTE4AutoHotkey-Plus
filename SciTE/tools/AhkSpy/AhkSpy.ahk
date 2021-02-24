/*
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©© AhkSpy ©©
©©©©©©©©©©©     ©   ©©©©©©   ©©©©©©©©        ©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©      ©   ©©©©©©   ©©©©©©©    ©©    ©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©       ©   ©©©©©©   ©©©©©©©     ©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©    ©   ©       ©©   ©©©  ©©©       ©©©       ©©   ©©   ©©©©
©©©©©©©    ©©   ©   ©    ©   ©    ©©©©©©      ©   ©    ©   ©©   ©©©©
©©©©©©    ©©©   ©   ©©   ©       ©©©©©©©©©    ©   ©©   ©   ©©   ©©©©
©©©©©           ©   ©©   ©   ©    ©©    ©©    ©   ©    ©    ©   ©©©©
©©©©    ©©©©©   ©   ©©   ©   ©©©  ©©©        ©©       ©©©       ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©©©©©©   ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©   ©    ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©©      ©©©©©
©© AhkSpy ©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©

    Автор - serzh82saratov
    E-Mail: serzh82saratov@mail.ru

    Благодарность Malcev, teadrinker, YMP, Irbis за их решения
    Описание - http://forum.script-coding.com/viewtopic.php?pid=72459#p72459
    Обсуждение - http://forum.script-coding.com/viewtopic.php?pid=72244#p72244
    Обсуждение на офф. форуме- https://autohotkey.com/boards/viewtopic.php?f=6&t=52872
    Актуальный исходник - https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/AhkSpy.ahk
*/


Global AhkSpyVersion := 4.76

	; ___________________________ Caption _________________________________________________

ComObjError(false)

Global WS_EX_APPWINDOW := 0x40000, WS_CHILDWINDOW := 0x40000000, WS_EX_LAYERED := 0x80000
		, WS_EX_TRANSPARENT := 0x20, WS_POPUP := 0x80000000, WS_EX_NOACTIVATE := 0x8000000

p1 = %1%
If (p1 = "Zoom")
{  
	Gosub ShowZoom 
	Return
}

SingleInstance()
#NoEnv
#UseHook
#KeyHistory 0

SetBatchLines, -1
ListLines, Off
DetectHiddenWindows, On
CoordMode, Pixel
CoordMode, Menu

Gosub, CheckAhkVersion
Menu, Tray, UseErrorLevel
Menu, Tray, Icon, Shell32.dll, % A_OSVersion = "WIN_XP" ? 222 : 278

Global Path_User := A_AppData "\AhkSpy"
If !InStr(FileExist(Path_User), "D")
	FileCreateDir, % Path_User


Global MemoryFontSize := IniRead("MemoryFontSize", 0)
	, FontBold := IniRead("FontBold", 0)
	, FontSize := MemoryFontSize ? IniRead("FontSize", "15") : 15			;;  Размер шрифта
	, FontFamily :=  "Arial"				;;  Шрифт - Times New Roman | Georgia | Myriad Pro | Arial
	, FontWeight := FontBold ? 900 : 500	;;  Насыщенность шрифта
	, HeigtButton := 30						;;  Высота кнопок
	, RangeTimer := 100						;;  Период опроса данных, увеличьте на слабом ПК
	HeightStart := 530						;;  Высота окна при старте
	wKey := 136								;;  Ширина кнопок
	wColor := wKey // 2						;;  Ширина цветного фрагмента

DarkTheme := IniRead("DarkTheme", 0)
If !DarkTheme
{
	Global ColorFont := "000000"			;;  Цвет шрифта
	, ColorBg := "FFFFFF"					;;  Цвет фона          "F0F0F0" E4E4E4     F8F8F8
	, ColorBgPaused := "f7f7f7"				;;  Цвет фона при паузе     F0F0F0
	, ColorBgModeButton := "f7f7f7"			;;  E1E1E1
	, ColorSelModeButton := "A9D186"		;;  Цвет фона кнопки текущего режима
	, ColorSelMouseHover := "3399FF"		;;  Цвет фона элемента при наведении мыши  3399FF   96C3DC F9D886 8FC5FC AEC7E1
	, ColorSelMouseHoverText := ColorBg		;;  Цвет текста элемента при наведении мыши     96C3DC F9D886 8FC5FC AEC7E1
	, ColorSelButton := "96C3DC"			;;  Цвет фона при нажатии на кнопки
	, ColorSelAnchor := "FFFF80"			;;  Цвет фона заголовка для якоря
	, ColorHighLightBckg := "FFE0E0"		;;  Цвет фона некоторых абзацев
	, ColorDelimiter := "E14B30"			;;  Цвет шрифта разделителя заголовков и параметров
	, ColorTitle := "27419B"				;;  Цвет шрифта заголовка
	, ColorLineTitles := "444499"			;;  Цвет линии заголовка
	, ColorParam := "189200"				;;  Цвет шрифта параметров
	, ColorErrorAccPath := "ff0000"
	, ColorErrorAccMarquee := "ffcc00"
	, ColorErrorAccMarquee := "ffcc00"
	, ColorStyleComment1 := "f0f0f0"
	, ColorStyleComment2 := "C0C0C0" 
	, ColorSelectedFind := "6666FF" 
	, ColorBorderHoverInput := "4A8DFF"
	, ColorPreOverflowHide := "E2E2E2" 
	, ColorScrollArrows := "686868" 
	, ColorScrollBack := "F0F0F0" 
	, ColorScrollFace := "CDCDCD" 
}
Else 
{
	Global ColorFont := "FFFFFF"			;;  Цвет шрифта
	, ColorBg := "000000"					;;  Цвет фона          "F0F0F0" E4E4E4     F8F8F8  
	, ColorBgPaused := "080808"				;;  Цвет фона при паузе     F0F0F0
	, ColorBgModeButton := "000000"			;;  000000
	, ColorSelModeButton := "469EE1"		;;  Цвет фона кнопки текущего режима
	, ColorSelMouseHover := "FDE182"		;;  Цвет фона элемента при наведении мыши     96C3DC F9D886 8FC5FC AEC7E1
	, ColorSelMouseHoverText := "000000"	;;  Цвет текста элемента при наведении мыши     96C3DC F9D886 8FC5FC AEC7E1
	, ColorSelButton := "693C23"			;;  Цвет фона при нажатии на кнопки
	, ColorSelAnchor := "E8BD7D"			;;  Цвет фона заголовка для якоря   E14B30
	, ColorHighLightBckg := "001F1F"		;;  Цвет фона некоторых абзацев
	, ColorDelimiter := "1EB4CF"			;;  Цвет шрифта разделителя заголовков и параметров
	, ColorTitle := "6BB1E7"				;;  Цвет шрифта заголовка   D8BE64
	, ColorLineTitles := "00FFFF"			;;  Цвет линии заголовка
	, ColorParam := "8EC461"				;;  Цвет шрифта параметров   E76DFF
	, ColorErrorAccPath := "00FFFF"
	, ColorErrorAccMarquee := "0033FF"
	, ColorErrorAccMarquee := "0033FF"
	, ColorStyleComment1 := "0F0F0F"
	, ColorStyleComment2 := "3F3F3F" 
	, ColorSelectedFind := "999900" 
	, ColorBorderHoverInput := "B57200"
	, ColorPreOverflowHide := "1D1D1D" 
	, ColorScrollArrows := "979797" 
	, ColorScrollBack := "0F0F0F" 
	, ColorScrollFace := "323232" 
}
Global ColorBgOriginal := ColorBg

Global ThisMode := IniRead("StartMode", "Control"), LastModeSave := (ThisMode = "LastMode")
, ThisMode := ThisMode = "LastMode" ? IniRead("LastMode", "Control") : ThisMode, CheckAhkNewVersion := IniRead("CheckAhkNewVersion", 0) 
, ActiveNoPause := IniRead("ActiveNoPause", 0), MemoryPos := IniRead("MemoryPos", 0), MemorySize := IniRead("MemorySize", 0)
, MemoryZoomSize := IniRead("MemoryZoomSize", 0), MemoryStateZoom := IniRead("MemoryStateZoom", 0), StateLight := IniRead("StateLight", 1)
, StateLightAcc := IniRead("StateLightAcc", 1), SendCode := IniRead("SendCode", "vk"), StateLightMarker := IniRead("StateLightMarker", 1)
, StateUpdate := IniRead("StateUpdate", 0), SendMode := IniRead("SendMode", "send"), SendModeStr := Format("{:L}", SendMode)
, AnchorFullScroll := IniRead("AnchorFullScroll", 1), MemoryAnchor := IniRead("MemoryAnchor", 1), MenuIdView := IniRead("MenuIdView", 0)
, StateAllwaysSpot := IniRead("AllwaysSpot", 0), w_ShowStyles := IniRead("w_ShowStyles", 0), MarkerInvertFrame := IniRead("MarkerInvertFrame", 1)
, c_ShowStyles := IniRead("c_ShowStyles", 0), ViewStrPos := IniRead("ViewStrPos", 0), OnlyShiftTab := IniRead("OnlyShiftTab", 0)
, WordWrap := IniRead("WordWrap", 0), PreMaxHeightStr := IniRead("MaxHeightOverFlow", "1 / 3"), UpdRegister := IniRead("UpdRegister2", 0)
, UseUIA := IniRead("UseUIA", 0), UIAAlienDetect := IniRead("UIAAlienDetect", 0), MinimizeEscape := IniRead("MinimizeEscape", 0)
, DetectHiddenText := IniRead("DetectHiddenText", "on"), MoveTitles := IniRead("MoveTitles", 1), DynamicAccPath := IniRead("DynamicAccPath", 0)
, DynamicControlPath := IniRead("DynamicControlPath", 0), ActiveScriptAllowChange := IniRead("ActiveScriptAllowChange", 1)

, UpdRegisterLink := "https://u.to/zeONFA", testvar, oDivOld, oDivNew, DivWorkIndex := 2, oDivWork1, oDivWork2

, FontDPI := {96:12,120:10,144:8,168:6}[A_ScreenDPI], ScrollPos := {}, AccCoord := [], oOther := {}
, oFind := {}, Edits := [], oMS := {}, oMenu := {}, oPubObj := {}, osCoords := {}

, ClipAdd_Before := 0, ClipAdd_Delimiter := "`r`n"
, HTML_Win, HTML_Control, HTML_Hotkey, rmCtrlX, rmCtrlY, widthTB, FullScreenMode, hColorProgress, hFindAllText, MsgAhkSpyZoom
, hGui, hTBGui, hActiveX, hFindGui, oDoc, ShowMarker, isFindView, isIE, isPaused, PreMaxHeight := MaxHeightStrToNum()
, PreOverflowHide := !!PreMaxHeight, DecimalCode, GetVKCodeNameStr, GetSCCodeNameStr
, oPubObjGUID, oObjActive := {}, oJScript, oBody, isConfirm, isAhkSpy := 1, TitleText, FreezeTitleText, TitleTextP1, exUIASub
, Shift_Tab_Down, hButtonButton, hButtonControl, hButtonWindow
, TitleTextP2 := TitleTextP2_Reserved := "     ( Shift+Tab - Freeze | RButton - CopySelected | Pause - Pause )     v" AhkSpyVersion
, Sleep, oShowMarkers, oShowAccMarkers, oShowMarkersEx, hDCMarkerInvert, hMarkerGui

#Include *i %A_AppData%\AhkSpy\IncludeSettings.ahk

Global _S1 := "<span>", _S2 := "</span>", _DB := "<span style='position: relative; margin-right: 1em;'></span>"

, _BT1 := "<span class='button' unselectable='on' oncontextmenu='return false' contenteditable='false' ", _BT2 := "</span>"

  ;;	Решает проблему запуска ресайза кнопки когда выделен текст, но не получается установить свой курсор
, _BP1 := "<span contenteditable='false'><span class='button' unselectable='on' oncontextmenu='return false'"
	. " contenteditable='false' style='color: #" ColorParam "' name='pre' ", _BP2 := "</span></span>"
  ;;	Прежнее
; , _BP1 := "<span contenteditable='false' oncontextmenu='return false' class='BB'>" _BT1 "style='color: #" ColorParam "' name='pre' ", _BP2 := "</span></span>"

, _BB1 := "<span contenteditable='false' oncontextmenu='return false' class='BB' style='height: 0px;'>" _BT1 " ", _BB2 := "</span></span>"
, _T1 := "<span class='box'><span class='line'><span class='hr'></span><span class='con'><span class='title' ", _T2 := "</span></span></span><br>"
, _T1P := " style='color: #" ColorParam "' "
, _T0 := "<span class='box'><span class='hr'></span></span><span id='id_T0' style='position: absolute'></span>"
, _PRE1 := "<pre contenteditable='true'>", _PRE2 := "</pre>"
, _LPRE := "<pre contenteditable='true' class='lpre'"
, _DP := "  <span style='color: #" ColorDelimiter "'>&#9642</span>  "
, _StIf := "    <span class='QStyle1'>&#9642</span>    <span class='QStyle2' name='MS:'>"
, _BR := "<p class='br'></p>", _DN := "`n", _DN2 := "<div style='height: 0.50em`;'></div>" 

, _PreOverflowHideCSS := ".lpre {max-width: 99`%; max-height: " PreMaxHeight "px; overflow: auto; border: 1px solid #" ColorPreOverflowHide ";}"

, _BodyWrapCSS := "body, .divwork {word-wrap: break-word`; overflow-x: 'hidden';} .lpre {overflow-x: hidden`;}"

, _ButAccViewer := ExtraFile("AccViewer Source") ? _DB _BT1 " id='run_AccViewer'> run accviewer " _BT2 : ""
, _ButiWB2Learner := ExtraFile("iWB2 Learner") ? _DB _BT1 " id='run_iWB2Learner'> run iwb2 learner " _BT2 : ""
, _ButWindow_Detective := FileExist(Path_User "\Window Detective.lnk") ? _DB _BT1 " id='run_Window_Detective'> run window detective " _BT2 : ""
, oZBID := {0:"ZBID_DEFAULT",1:"ZBID_DESKTOP",2:"ZBID_UIACCESS",3:"ZBID_IMMERSIVE_IHM",4:"ZBID_IMMERSIVE_NOTIFICATION",5:"ZBID_IMMERSIVE_APPCHROME"
	,6:"ZBID_IMMERSIVE_MOGO",7:"ZBID_IMMERSIVE_EDGY",8:"ZBID_IMMERSIVE_INACTIVEMOBODY",9:"ZBID_IMMERSIVE_INACTIVEDOCK"
	,10:"ZBID_IMMERSIVE_ACTIVEMOBODY",11:"ZBID_IMMERSIVE_ACTIVEDOCK",12:"ZBID_IMMERSIVE_BACKGROUND",13:"ZBID_IMMERSIVE_SEARCH"
	,14:"ZBID_GENUINE_WINDOWS",15:"ZBID_IMMERSIVE_RESTRICTED",16:"ZBID_SYSTEM_TOOLS",17:"ZBID_LOCK",18:"ZBID_ABOVELOCK_UX"}
	
If UseUIA
	exUIASub := new UIASub

BLGroup := ["Backlight allways","Backlight disable","Backlight hold shift button"]
oOther.anchor := {}, oOther.CurrentProcessId := DllCall("GetCurrentProcessId")

If MemoryAnchor
{
	If oOther.anchor["Win_text"] := IniRead("Win_Anchor")
		oOther.anchor["Win"] := 1
	If oOther.anchor["Control_text"] := IniRead("Control_Anchor")
		oOther.anchor["Control"] := 1
} 



FixIE()
SeDebugPrivilege() 
OnExit("Exit")

CreateMarkerInvert()
ShowMarkersCreate("oShowAccMarkers", "26419F")  
ShowMarkersCreate("oShowMarkers", "E14B30")

Gui, +AlwaysOnTop +HWNDhGui +ReSize -DPIScale +Owner%hMarkerGui% +E%WS_EX_APPWINDOW% ;   +E%WS_EX_NOACTIVATE%
Gui, Color, %ColorBgPaused%
ActiveScriptAllow() 
Gui, Add, ActiveX, Border voDoc HWNDhActiveX x0 y+0, HTMLFile
ActiveScriptAllow(1)

;	https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.htmlwindow?view=netframework-4.8
;	https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model

LoadJScript()
oBody := oDoc.body 
oJScript := oDoc.Script
oJScript.WordWrap := WordWrap
oJScript.MoveTitles := MoveTitles
ComObjConnect(oDoc, Events)

OnMessage(0x133, "WM_CTLCOLOREDIT")
OnMessage(0x201, "WM_LBUTTONDOWN") 
OnMessage(0x204, "WM_RBUTTONDOWN") 
OnMessage(0x7B, "WM_CONTEXTMENU")
OnMessage(0xA1, "WM_NCLBUTTONDOWN")
OnMessage(0x6, "WM_ACTIVATE")
OnMessage(0x47, "WM_WINDOWPOSCHANGED")
OnMessage(0x4a, "WM_COPYDATA")   

;; OnMessage(WM_WINDOWPOSCHANGING := 0x46, "WM_WINDOWPOSCHANGED") 
;; OnMessage(WM_MOVING := 0x216, "WM_WINDOWPOSCHANGED")
;; OnMessage(WM_MOVE := 0x03, "WM_WINDOWPOSCHANGED")

OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "MsgAhkSpyZoom"), "MsgZoom")
DllCall("PostMessage", "Ptr", A_ScriptHWND, "UInt", 0x50, "UInt", 0,	 "UInt", 0x409) ;; eng layout
SetWinEventHook("EVENT_OBJECT_CLOAKED", 0x8017)
SetWinEventHook("EVENT_OBJECT_UNCLOAKED", 0x8018) 

Gui, TB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +%WS_CHILDWINDOW% -%WS_POPUP% +E%WS_EX_NOACTIVATE%
Gui, TB: Color, %ColorBg%
Gui, TB: Font, % " s" FontDPI, Verdana

Gui, TB: Add, Progress, % "  x1 y0 h" HeigtButton-1 " w" wKey "  vColor_Window Background" ColorBgModeButton  
Gui, TB: Add, Text, % "Border hwndhButtonWindow +0x201 c" ColorFont " BackGroundTrans xp yp hp wp", Window

Gui, TB: Add, Progress, % "x+1 y0 h" HeigtButton-1 " w" wKey " vColor_Control Background" ColorBgModeButton  
Gui, TB: Add, Text, % "Border hwndhButtonControl +0x201 c" ColorFont " BackGroundTrans xp yp hp wp", Control

Gui, TB: Add, Progress, % "x+1 y0 h" HeigtButton-1 " w" HeigtButton " vColor_Zoom Background" ColorBgModeButton  
Gui, TB: Add, Text, % "Border hwndhButtonZoom +0x201 c" ColorFont " BackGroundTrans xp yp hp wp", % Chr("0x1F50D") ; 🔍

Gui, TB: Add, Progress, % "x+1 y0 h" HeigtButton-1 " w" wColor " vColorProgress HWNDhColorProgress c" ColorBgOriginal, 100

Gui, TB: Add, Progress, % "x+1 y0 h" HeigtButton-1 " w" wKey " vColor_Button Background" ColorBgModeButton  
Gui, TB: Add, Text, % "Border hwndhButtonButton +0x201 c" ColorFont " BackGroundTrans xp yp hp wp", Button

Gui, TB: Show, % "x0 y0 NA h" HeigtButton " w" widthTB := wKey * 3 + wColor + HeigtButton + 6

Gui, F: +HWNDhFindGui -Caption -DPIScale +Parent%hGui% +%WS_CHILDWINDOW% -%WS_POPUP%
Gui, F: Color, %ColorBgPaused%
Gui, F: Font, % " s" FontDPI
Gui, F: Add, Edit, x1 y0 w180 h26 gFindNew WantTab HWNDhFindEdit
SendMessage, 0x1501, 1, "Find to page",, ahk_id %hFindEdit%   ;; EM_SETCUEBANNER
Gui, F: Add, UpDown, -16 Horz Range0-1 x+0 yp h26 w52 gFindNext vFindUpDown
GuiControl, F: Move, FindUpDown, h26 w52
Gui, F: Font, % " s" FontDPI
; 0x201 CENTER wh
Gui, F: Add, Text, x+10 yp+1 h24 +0x201 gFindOption c%ColorFont%, % " case sensitive "
Gui, F: Add, Text, x+10 yp hp +0x201 gFindOption c%ColorFont%, % " whole word "
; BS_VCENTER := 0xC00, BS_CENTER := 0x300
Gui, F: Add, Button, % "+0x300 +0xC00 yp hp w20 gFindHide x" widthTB - 21 c%ColorFont%, X   
Gui, F: Add, Text, x+10 yp hp +0x201 w152 vFindMatches Left HWNDhFindAllText c%ColorFont%

	; ___________________________ Menu Create _________________________________________________

Menu, Sys, Add, % name := "Backlight allways", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Add, % name := "Backlight hold shift button", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Add, % name := "Backlight disable", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Check, % BLGroup[StateLight]
Menu, Sys, Add
Menu, Sys, Add, % name := "Window or control backlight", % oMenu.Sys[name] := "_Sys_WClight"
Menu, Sys, % StateLightMarker ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Acc object backlight", % oMenu.Sys[name] := "_Sys_Acclight"
Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", % name
Menu, Sys, Add
Menu, Sys, Add, % name := "Spot together (low speed)", % oMenu.Sys[name] := "_Spot_Together"
Menu, Sys, % StateAllwaysSpot ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Work with the active window", % oMenu.Sys[name] := "_Active_No_Pause"
Menu, Sys, % ActiveNoPause ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Spot only Shift+Tab", % oMenu.Sys[name] := "_OnlyShiftTab"
Menu, Sys, % OnlyShiftTab ? "Check" : "UnCheck", % name

If !A_IsCompiled
{
	Menu, Sys, Add
	Menu, Sys, Add, % name := "Check updates", % oMenu.Sys[name] := "_CheckUpdate"
	Menu, Sys, % StateUpdate ? "Check" : "UnCheck", % name
	If StateUpdate
		SetTimer, UpdateAhkSpy, -1000
}
Else
	StateUpdate := 0

Menu, Sys, Add
Menu, Startmode, Add, % name := "Window", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add, % name := "Control", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add, % name := "Button", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add
Menu, Startmode, Add, % name := "Last Mode", % oMenu.Startmode[name] := "_SelStartMode"

Menu, View, Add, % name := "Dynamic control path (low speed)", % oMenu.View[name] := "_DynamicControlPath"
Menu, View, % DynamicControlPath ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Dynamic accesible path (low speed, not recommended)", % oMenu.View[name] := "_DynamicAccPath"
Menu, View, % DynamicAccPath ? "Check" : "UnCheck", % name
Menu, View, Add
Menu, View, Add, % name := "Use UI Automation interface", % oMenu.View[name] := "_UseUIA"
Menu, View, % UseUIA ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "UIA change background for different hwnd", % oMenu.View[name] := "_UIAAlienDetect"
Menu, View, % UIAAlienDetect ? "Check" : "UnCheck", % name  
Menu, View, Add  
Menu, View, Add, % name := "Dark theme (reload needed)", % oMenu.View[name] := "_DarkTheme"
Menu, View, % DarkTheme ? "Check" : "UnCheck", % name 
Menu, View, Add, % name := "Font bold (reload needed)", % oMenu.View[name] := "_FontBold"
Menu, View, % FontBold ? "Check" : "UnCheck", % name 
Menu, View, Add, % name := "Word wrap", % oMenu.View[name] := "_WordWrap"
Menu, View, % WordWrap ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "View coordinates string extended", % oMenu.View[name] := "_ViewStrPos"
Menu, View, % ViewStrPos ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Flash edge", % oMenu.View[name] := "_MarkerInvertFrame"
Menu, View, % MarkerInvertFrame ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Full scroll with existing anchor", % oMenu.View[name] := "_AnchorFullScroll"
Menu, View, % AnchorFullScroll ? "Check" : "UnCheck", % name  
Menu, View, Add, % name := "Moving titles", % oMenu.View[name] := "_MoveTitles"
Menu, View, % MoveTitles ? "Check" : "UnCheck", % name
Menu, Sys, Add, View settings, :View

Menu, Overflow, Add, % name := "Switch off", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 1", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 2", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 3", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 4", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 5", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 6", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 8", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 10", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 15", % oMenu.Overflow[name] := "_MenuOverflowLabel" 
Menu, Overflow, Check, %PreMaxHeightStr%
; Menu, Overflow, Color, % ColorBgOriginal
Menu, View, Add, Big text overflow hide, :Overflow

Menu, Sys, Add, Start mode, :Startmode
Menu, Startmode, Check, % {"Win":"Window","Control":"Control","Hotkey":"Button","LastMode":"Last Mode"}[IniRead("StartMode", "Control")]

Menu, Script, Add, Reload, Reload
Menu, Script, Add, Exit, Exit
Menu, Script, Add
Menu, Script, Add, % name := "Open script dir", % oMenu.Script[name] := "Help_OpenScriptDir"
Menu, Script, Add, % name := "Open user dir", % oMenu.Script[name] := "Help_OpenUserDir"
Menu, Script, Add
Menu, Script, Add, % name := "Remember position", % oMenu.Script[name] := "_MemoryPos"
Menu, Script, % MemoryPos ? "Check" : "UnCheck", % name
Menu, Script, Add, % name := "Remember size", % oMenu.Script[name] := "_MemorySize"
Menu, Script, % MemorySize ? "Check" : "UnCheck", % name
Menu, Script, Add, % name := "Remember font size", % oMenu.Script[name] := "_MemoryFontSize"
Menu, Script, % MemoryFontSize ? "Check" : "UnCheck", % name
Menu, Script, Add, % name := "Remember state zoom", % oMenu.Script[name] := "_MemoryStateZoom"
Menu, Script, % MemoryStateZoom ? "Check" : "UnCheck", % name
Menu, Script, Add, % name := "Remember zoom size", % oMenu.Script[name] := "_MemoryZoomSize"
Menu, Script, % MemoryZoomSize ? "Check" : "UnCheck", % name
Menu, Script, Add, % name := "Remember anchor", % oMenu.Script[name] := "_MemoryAnchor"
Menu, Script, % MemoryAnchor ? "Check" : "UnCheck", % name
Menu, Script, Add
Menu, Script, Add, % name := "Active script allow change", % oMenu.Script[name] := "_ActiveScriptAllowChange"
Menu, Script, % ActiveScriptAllowChange ? "Check" : "UnCheck", % name 
Menu, Script, Add, % name := "Escape button to minimize", % oMenu.Script[name] := "_MinimizeEscape"
Menu, Script, % MinimizeEscape ? "Check" : "UnCheck", % name 
Menu, Sys, Add, Script, :Script

Menu, Help, Add, % name := "Check updates AutoHotkey", % oMenu.Help[name] := "_CheckAhkNewVersion"
Menu, Help, % CheckAhkNewVersion ? "Check" : "UnCheck", % name
If CheckAhkNewVersion
	SetTimer, CheckAhkNewVersion, -3000 
Menu, Help, Add
If FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
	Menu, Help, Add, % name := "AutoHotKey help file", % oMenu.Help[name] := "LaunchHelp"
Menu, Help, Add, % name := "AutoHotKey official help online", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add, % name := "AutoHotKey russian help online", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add
Menu, Help, Add, % name := "About", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add, % name := "About english", % oMenu.Help[name] := "Sys_Help"
Menu, Sys, Add, Help, :Help

Menu, Sys, Add
Menu, Sys, Add, % name := "Pause", % oMenu.Sys[name] := "_PausedScript"
Menu, Sys, Add, % name := "Suspend hotkeys", % oMenu.Sys[name] := "_Suspend"
Menu, Sys, Add, % name := "Default size", % oMenu.Sys[name] := "DefaultSize"
Menu, Sys, Add, % name := "Full screen", % oMenu.Sys[name] := "FullScreenMode"
Menu, Sys, Add, % name := "Find to page", % oMenu.Sys[name] := "_FindView"

; Menu, Sys, Color, % ColorBgOriginal

#Include *i %A_AppData%\AhkSpy\Include.ahk  ;;	Для продолжения выполнения кода используйте GoTo IncludeLabel
IncludeLabel:

Gui, Show, % "NA " (MemoryPos ? " x" IniRead("MemoryPosX", "Center") " y" IniRead("MemoryPosY", "Center") : "")
. (MemorySize ? " h" IniRead("MemorySizeH", HeightStart) " w" IniRead("MemorySizeW", widthTB) : " h" HeightStart " w" widthTB)
Gui, % "+MinSize" widthTB "x" 313

If ThisMode = Hotkey
	Gui, Show
Gosub, Mode_%ThisMode%

Hotkey_Init("Write_HotkeyHTML", "MLRJ")
 
If (MemoryStateZoom && IniRead("ZoomShow", 0))
	AhkSpyZoomShow()
	
WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hGui%
If !DllCall("WindowFromPoint", "Int64", WinX & 0xFFFFFFFF | WinY << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX + WinWidth) & 0xFFFFFFFF | (WinY) << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX + WinWidth) & 0xFFFFFFFF | (WinY + WinHeight) << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX) & 0xFFFFFFFF | (WinY + WinHeight) << 32)
	Gui, Show, NA xCenter yCenter

If !UpdRegister
	SetTimer, UpdRegister, -1000 
	
WinSet, TransParent, 255, ahk_id %hGui%
DllCall("RedrawWindow", "Ptr", hGui, "Uint", 0, "Uint", 0, "Uint", 0x1|0x4)

; MsgBox % oDoc.documentMode  "`n" oDoc.compatMode  "`n" oDoc.designMode := "On"
Return 

	; ___________________________ Hotkey`s _________________________________________________

#If isAhkSpy && Sleep != 1 && OnlyShiftTab && !ActiveNoPause && !isPaused && ThisMode != "Hotkey" && IsHwndUnderMouse(hColorProgress) && !WinActive("ahk_id" hGui)

MButton:: SetTimer(Func("WM_RBUTTONDOWN").Bind(0, 0, 0, hColorProgress), "-" 1)  ; WM_RBUTTONDOWN(0, 0, 0, hColorProgress)

#If isAhkSpy && Sleep != 1 && OnlyShiftTab && !ActiveNoPause && !isPaused && ThisMode != "Hotkey" && IsHwndUnderMouse(hColorProgress)

MButton::
+MButton::
+RButton:: SetTimer(Func("WM_RBUTTONDOWN").Bind(0, 0, 0, hColorProgress), "-" 1)  ; WM_RBUTTONDOWN(0, 0, 0, hColorProgress)
	
#If Shift_Tab_Work

+Tab:: Return

#If isAhkSpy && Sleep != 1 && ActiveNoPause

+Tab:: Goto PausedScript

#If (isAhkSpy && Sleep != 1 && !isPaused && ThisMode != "Hotkey")

^Tab:: 
	If OnlyShiftTab 
		OnlyShiftTab := 0, oOther.OnlyShiftTabReset := 1 
	TransParent(0) 
	SetTimer, Mod_Up_Wait_And_TransParent, -1
+Tab:: 
SpotProc:
SpotProc2:  
	Shift_Tab_Work := 1 
	If (A_ThisHotkey != "")
		Shift_Tab_Down := 1 
	If (ThisMode = "Control")
		Spot_Control() && (Write_Control(), (StateAllwaysSpot ? Spot_Win() : 0))
	Else 
		Spot_Win() && (Write_Win(), (StateAllwaysSpot ? Spot_Control() : 0))
	If (!WinActive("ahk_id" hGui) && A_ThisLabel != "SpotProc2" && !OnlyShiftTab && !oOther.OnlyShiftTabReset)
	{
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc
	}
	Else
		ZoomMsg(3)
	KeyWait, Tab, T0.1
	Sleep(10)
	Shift_Tab_Work := 0
	Return
	

#Tab Up::
F8 Up:: ChangeMode()

#If isAhkSpy && (StateLight = 3 || Shift_Tab_Down)

~*RShift Up::
~*LShift Up:: 
ShiftUpHide:
	HideAllMarkers(), Shift_Tab_Down := 0, CheckHideMarker()
	Return

#If isAhkSpy && Sleep != 1

Break::
Pause::
PausedScript:
_PausedScript:
	If isConfirm
		Return
	isPaused := !isPaused
	Try SetTimer, Loop_%ThisMode%, % isPaused ? "Off" : "On"
	ZoomMsg(2, isPaused)
	ColorBg := isPaused ? ColorBgPaused : ColorBgOriginal
	oBody.style.backgroundColor := "#" ColorBg
	ChangeCSS("css_ColorBg", ".title, .button, .divwork {background-color: #" ColorBg ";}")
	If (ThisMode = "Hotkey" && WinActive("ahk_id" hGui))
		Hotkey_Hook(!isPaused)
	If (isPaused && !WinActive("ahk_id" hGui))
		(ThisMode = "Control" ? Spot_Win() : ThisMode = "Win" ? Spot_Control() : 0)
	HideAllMarkers(), CheckHideMarker()
	Menu, Sys, % (isPaused ? "Check" : "UnCheck"), Pause
	isPaused ? TaskbarProgress(4, hGui, 100) : TaskbarProgress(0, hGui)
	TitleText := (TitleTextP1 := "AhkSpy - " ({"Win":"Window","Control":"Control","Hotkey":"Button"}[ThisMode]))
	. (TitleTextP2 := (isPaused ? "                Paused..." : TitleTextP2_Reserved))
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	PausedTitleText()
	Return

#If isAhkSpy && Sleep != 1 && WinActive("ahk_id" hGui)

^WheelUp::
^WheelDown::
	FontSize := InStr(A_ThisHotkey, "Up") ? ++FontSize : --FontSize
	FontSize := FontSize < 10 ? 10 : FontSize > 24 ? 24 : FontSize 
	oDivWork1.Style.fontSize := FontSize "px"
	oDivWork2.Style.fontSize := FontSize "px"
	TitleText("FontSize: " FontSize)
	If MemoryFontSize
		IniWrite(FontSize, "FontSize") 
	SetTimer, AnchorScroll, -500
	Return

F1::
+WheelUp:: NextLink("-")

F2::
+WheelDown:: NextLink()

F3::
~!WheelUp:: WheelLeft

F4::
~!WheelDown:: WheelRight

F5:: Write_%ThisMode%()		;;  Return original HTML

F6::
^vk46:: _FindView()											;;  Ctrl+F

F7:: AnchorScroll()

F11:: 
	If oOther.ZoomShow && UnderControl(oOther.hZoomLW)
		Return
	FullScreenMode()
	Return

F12:: 
	If oOther.ZoomShow && UnderControl(oOther.hZoomLW)
		Return
	MouseGetPosScreen(x, y), ShowSys(x + 5, y + 5)
	Return

!Space:: SetTimer, ShowSys, -1

Esc::
	If isFindView
		FindHide()
	Else If FullScreenMode
		FullScreenMode()
	Else
		GuiClose()
	Return

+#Tab:: AhkSpyZoomShow()

#If isAhkSpy && Sleep != 1 && IsIEFocus() && (oDoc.selection.createRange().parentElement.isContentEditable)

^+vk41:: oDoc.execCommand("SelectAll")							;;  Ctrl+Shift+A

#If isAhkSpy && Sleep != 1 && IsIEFocus()

^vk41:: R := oBody.createTextRange(), R.moveToElementText(oDivNew), R.select()		;;  Ctrl+A
; ^vk41:: oBody.createTextRange().select()										;;  Ctrl+A

^vk5A:: oDoc.execCommand("Undo")							;;  Ctrl+Z

^vk59:: oDoc.execCommand("Redo")							;;  Ctrl+Y

^vk43:: GetSelected(CopyText) && ((Clipboard := CopyText), ToolTip("copy", 300))		;;  Ctrl+C

^vk56:: ClipPaste()																		;;  Ctrl+V

^vk58:: CutSelection()								;;  Ctrl+X

Del:: DeleteSelection()							;;  Delete

Tab:: PasteStrSelection("    ")							;;  &emsp	"&#x9;"  PasteStrSelection("&#x9;")

Enter:: PasteHTMLSelection("<br>")

#If isAhkSpy && Sleep != 1 && ThisMode != "Hotkey" && (IsIEFocus() || MS_IsSelection())

#RButton:: ClipPaste()

#If isAhkSpy && Sleep != 1 && ThisMode != "Hotkey" && (IsIEFocus() || MS_IsSelection()) && IsTextArea() && GetSelected(CopyText)

RButton::
^RButton::
	If (A_ThisHotkey = "^RButton")
		CopyText := CopyCommaParam(CopyText)
	Clipboard := CopyText
	ToolTip("copy", 300)
	Return

+RButton:: ClipAdd(CopyText, 1)
^+RButton:: ClipAdd(CopyCommaParam(CopyText), 1)

#If isAhkSpy && Sleep != 1 && ThisMode = "Hotkey" && (IsIEFocus() || MS_IsSelection()) && IsTextArea() && GetSelected(CopyText) ;;	Mode = Hotkey

RButton::
	KeyWait, RButton, T0.3
	If ErrorLevel
		ClipAdd(CopyText, 1)
	Else
		Clipboard := CopyText, ToolTip("copy", 300)
	Return

#If (isAhkSpy && Sleep != 1 && !isPaused && ThisMode != "Hotkey")

+#Up:: MouseStep(0, -1)
+#Down:: MouseStep(0, 1)
+#Left:: MouseStep(-1, 0)
+#Right:: MouseStep(1, 0)
^+#Up:: MouseStep(0, -10)
^+#Down:: MouseStep(0, 10)
^+#Left:: MouseStep(-10, 0)
^+#Right:: MouseStep(10, 0)

#If oJScript.ButtonOver

+LButton::
	oJScript.onmousedown(oJScript.ButtonOver)
	KeyWait LButton
	if !oJScript.ButtonOver
		return 
	obj := Func("ButtonClick").Bind(oJScript.ButtonOver)
	SetTimer, % obj, -100
	; ButtonClick(oJScript.ButtonOver)
	oJScript.onmouseup(oJScript.ButtonOver, 1)
	Return

#If !WinActive("ahk_id" hGui) && IsAhkSpyUnderMouse(hc)

+LButton::  
	If (hc = hButtonButton)
		SetTimer("Mode_Hotkey", -1)
	Else If (hc = hButtonControl)
		SetTimer("Mode_Control", -1)
	Else If (hc = hButtonWindow)
		SetTimer("Mode_Win", -1) 
	Else If (hc = hButtonZoom) 
		SetTimer("AhkSpyZoomShow", -1) 
	Return 
#If

IsAhkSpyUnderMouse(Byref hc) {
	MouseGetPos, , , hw, hc, 2
	Return (hw = hGui)
}

IsHwndUnderMouse(hwnd) {
	MouseGetPos, , , , hc, 2
	Return (hc = hwnd)
}
	; ___________________________ Mode_Win _________________________________________________
	
Mode_Win: 
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	ZoomMsg(10, 0)
	; oBody.createTextRange().execCommand("RemoveFormat")   
	ColorButton("Window") 
	
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
		
	Try SetTimer, Loop_%ThisMode%, Off
	
	ScrollPos[ThisMode, 1] := oDivNew.scrollLeft
	ScrollPos[ThisMode, 2] := oDivNew.scrollTop
	
	If ThisMode != Win
		HTML_%ThisMode% := oDivNew.innerHTML, prNotThisMode := 1
		
	ThisMode := "Win"
	
	If (HTML_Win = "")
		Spot_Win(1)
	Write_Win(prNotThisMode) 
	
	TitleText := (TitleTextP1 := "AhkSpy - Window") . TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	If isFindView
		FindNewText()

Loop_Win:
	If ((WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1)
		GoTo Repeat_Loop_Win
	If !OnlyShiftTab && Spot_Win()
		Write_Win(), StateAllwaysSpot ? Spot_Control() : 0
Repeat_Loop_Win:
	If (!isPaused && ThisMode = "Win" && !OnlyShiftTab)
		SetTimer, Loop_Win, -%RangeTimer%
	Return

Spot_Win(NotHTML = 0) {
	Static PrWinPID, ComLine, _ComLine, ProcessBitSize, IsAdmin, WinProcessPath, WinProcessName
	
	If NotHTML
		GoTo HTML_Win
	MouseGetPos, , , WinID, hChild, 3

	If (WinID = hGui || WinID = oOther.hZoom || WinID = oOther.hZoomLW)
		Return 0, HideAllMarkers()

	WinGetTitle, WinTitle, ahk_id %WinID%
	WinTitle := TransformHTML(WinTitle)
	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%
	WinX2 := WinX + WinWidth - 1, WinY2 := WinY + WinHeight - 1
	WinGetClass, WinClass, ahk_id %WinID%
	oOther.WinClass := WinClass
	WinGet, WinPID, PID, ahk_id %WinID%
	If (WinPID != PrWinPID) {
		GetCommandLineProc(WinPID, _ComLine, ProcessBitSize, IsAdmin)
		ComLine := TransformHTML(_ComLine), PrWinPID := WinPID
		WinGet, WinProcessPath, ProcessPath, ahk_id %WinID%
		Loop, %WinProcessPath%
			WinProcessPath = %A_LoopFileLongPath%
		SplitPath, WinProcessPath, WinProcessName
	}
	If (WinClass ~= "(Cabinet|Explore)WClass")
		CLSID := GetCLSIDExplorer(WinID)
	WinGet, WinCountProcess, Count, ahk_pid %WinPID%
	WinGet, WinStyle, Style, ahk_id %WinID%
	WinGet, WinExStyle, ExStyle, ahk_id %WinID% 
	{
		WinGet, WinTransparent, Transparent, ahk_id %WinID%
		If WinTransparent !=
			TransparentStr := _BP1 "id='set_button_Transparent'>Transparent:</span>" _BP2 "  <span id='get_win_Transparent' name='MS:'>"  WinTransparent "</span>"     
	
		WinGet, WinTransColor, TransColor, ahk_id %WinID%
		If WinTransColor !=
			TransColorStr := _BP1 "id='set_button_TransColor'>TransColor:</span>" _BP2 "  <span id='get_win_TransColor' name='MS:'>"  WinTransColor "</span>"
	
		OwnedId := DllCall("GetWindow", "Ptr", WinID, UInt, 4, "Ptr")
		If OwnedId
			OwnedIdStr := "<span class='param'>Owned Id:</span> <span name='MS:'>" Format("0x{:x}", OwnedId) "</span>"
			
		EX1Str := Add_DP(1, OwnedIdStr, TransparentStr, TransColorStr)
	} 
	WinGet, CountControl, ControlListHwnd, ahk_id %WinID%	
	RegExReplace(CountControl, "m`a)$", "", CountControl)
	GetClientPos(WinID, caX, caY, caW, caH)
	caWinRight := WinWidth - caW - caX , caWinBottom := WinHeight - caH - caY
	loop 1000
	{
		StatusBarGetText, SBFieldText, %A_Index%, ahk_id %WinID%
		if ErrorLevel
			Break
		(!sb_fields && sb_fields := []), sb_fields[A_Index] := SBFieldText
	}
	if sb_fields.maxindex()
	{
		while (sb_max := sb_fields.maxindex()) && (sb_fields[sb_max] = "")
			sb_fields.Delete(sb_max)
		for k, v in sb_fields
			SBText .= "<span class='param'>(" k "):</span> <span name='MS:' id='sb_field_" A_Index "'>" TransformHTML(v "") "</span>`n"
		If SBText !=
			SBText := _T1 " id='__StatusBarText'> ( StatusBarText ) </span>" _BT1 " id='copy_sbtext' name='" sb_max "'> copy " _BT2 _T2 _PRE1 "<span>" SBText "</span></span>" _PRE2
	}
	DetectHiddenText, % DetectHiddenText
	WinGetText, WinText, ahk_id %WinID%
	If WinText !=
		WinText := _T1 " id='__WindowText'> ( Window Text ) </span><a></a>" _BT1 " id='copy_wintext'> copy " _BT2 _DB _BT1 " id='wintext_hidden'> hidden - " DetectHiddenText " " _BT2 _T2
		. _LPRE  "><pre id='wintextcon'>" TransformHTML(WinText) "</pre>" _PRE2
	MenuText := GetMenu(WinID)

	If ViewStrPos
		ViewStrPos1 := _DP "<span name='MS:'>" WinX ", " WinY ", " WinX2 ", " WinY2 "</span>" _DP "<span name='MS:'>" WinX ", " WinY ", " WinWidth ", " WinHeight "</span>"

	IsWindowUnicodeStr := _DP "<span class='param'>Is unicode:</span>  <span>" (DllCall("user32\IsWindowUnicode", "Ptr", WinID) ? "True" : "False") "</span>"

	CoordMode, Mouse
	MouseGetPos, WinXS, WinYS, h
	If (h = hGui || h = oOther.hZoom || h = oOther.hZoomLW)
		Return 0, HideAllMarkers()
		
	SetPosObject("Window", [WinX, WinY, WinWidth, WinHeight])   
	SetPosObject("AhkSpy", WinGetPosToArray(hActiveX))
	
	If !StateAllwaysSpot 
	{
		oObjActive.ScreenX := WinXS, oObjActive.ScreenY := WinYS
		PixelGetColor, ColorRGB, %WinXS%, %WinYS%, RGB
		GuiControl, TB: -Redraw, ColorProgress
		GuiControl, % "TB: +c" SubStr(ColorRGB, 3), ColorProgress
		GuiControl, TB: +Redraw, ColorProgress
	}
	If WinExist("ahk_class AutoHotkey ahk_pid" WinPID)
	{
		RegExMatch(StrReplace(_ComLine, WinProcessPath), "(.:\\([^""]+))", m)  ; "(.:[^:]+\\([^""]+))", m) 
		If (m1 != "")
			AhkScriptPAth := m1
		Else 
			AhkScriptPAth := WinProcessPath, IsAhkScriptExe := 1 
			
		AhkScriptStringCode := _T1 " id='__ahkscript'> ( AutoHotkey script " (IsAhkScriptExe ? "compiled" : "") ") </span>" _T2   
			. "<div>" _DN2 
			. (!IsAhkScriptExe ? _BP1 " id='ahkscript_edit'> edit " _BP2 _DB : "")
			. _BP1 " id='ahkscript_folder'> in folder " _BP2 _DB
			. _BP1 " id='ahkscript_copypath'> copy as file " _BP2 _DB
			. _BP1 " id='ahkscript_run'> run " _BP2 _DN2
			. _BP1 " id='ahkscript_suspend'> suspend " _BP2 _DB
			. _BP1 " id='ahkscript_pause'> pause " _BP2 _DB
			. _BP1 " id='ahkscript_reload'> reload " _BP2 _DB
			. _BP1 " id='ahkscript_exit'> exit " _BP2 _DN2
			. _BP1 " id='ahkscript_lines'> lines " _BP2 _DB
			. _BP1 " id='ahkscript_variables'> variables " _BP2 _DB
			. _BP1 " id='ahkscript_hotkeys'> hotkeys " _BP2 _DB
			. _BP1 " id='ahkscript_keyhistory'> key history " _BP2 _DN2 "</div>"
			. _PRE1 "<span id='ahkscriptpath' name='MS:'>" TransformHTML(AhkScriptPAth) "</span>" _PRE2
	}
	If (hParent := DllCall("GetAncestor", "Ptr", WinID, Uint, 1)) && (hParent != WinID)
	{
		WinGet, ParentProcessName, ProcessName, ahk_id %hParent% 
		WinGetClass, ParentClass, ahk_id %hParent%
		_ParentWindow := "`n<span class='param'>Parent window:</span>  <span name='MS:'>" ParentClass "</span>" 
			. _DP " <span name='MS:'>" ParentProcessName "</span>" _DP "<span name='MS:'>" Format("0x{:x}", hParent) "</span>"
	}
	DllCall("GetWindowBand", "ptr", WinID, "uint*", band) 
	WindowBand := _DP "<span class='param'>WindowBand:</span>  <span name='MS:Q'>" oZBID[band] " := <span class='param' name='MS:'>" band "</span></span>"	

	; ___________________________ HTML_Win _________________________________________________

HTML_Win:
	If w_ShowStyles
		WinStyles := GetStyles(WinClass, WinStyle, WinExStyle, WinID)
		 
	HTML_Win := ""
	. _T1 " id='__Title'> ( Title ) </span>" _BT1 " id='pause_button'> pause " _BT2 _T2  _BR 
	
	. _PRE1 "<span id='wintitle1' name='MS:'>" WinTitle "</span>" _PRE2 
	
	. _T1 " id='__Class'> ( Class ) </span>" _T2 

	. _PRE1 "<span id='wintitle2'><span class='param' id='wintitle2_' name='MS:S'>ahk_class </span><span name='MS:'>" WinClass "</span></span>" _PRE2 
	
	. _T1 " id='__ProcessName'> ( ProcessName ) </span>" _BT1 " id='copy_alltitle'> copy titles " _BT2  _T2 
	
	. _PRE1 "<span id='wintitle3'><span class='param' name='MS:S' id='wintitle3_'>ahk_exe </span><span name='MS:'>" WinProcessName "</span></span>" _PRE2 
	
	. _T1 " id='__ProcessPath'> ( ProcessPath ) </span>" _BT1 " id='infolder'> in folder " _BT2  _DB  _BT1 " id='paste_process_path'> paste " _BT2  _T2 
	
	. _PRE1 "<span><span class='param' name='MS:S'>ahk_exe </span><span id='copy_processpath' name='MS:'>" WinProcessPath "</span></span>" _PRE2 
	
	. _T1 " id='__CommandLine'> ( CommandLine ) </span>" _BT1 " id='w_command_line'> launch " _BT2  _DB  
		. _BT1 " id='paste_command_line'> paste " _BT2  _DB  _BT1 " id='clean_command_line'> clean " _BT2  _DB  _BT1 " id='command_line_infolder'> in folder " _BT2  _T2 
	
	. _PRE1 "<span id='c_command_line' name='MS:'>" ComLine "</span>" _PRE2
	
	. AhkScriptStringCode
	
	. _T1 " id='__Position'> ( Position ) </span>" _T2 
	
	. _PRE1  _BP1 " id='set_button_pos'>Pos:" _BP2 "  <span name='MS:'>x" WinX " y" WinY "</span>" 
		. _DP "<span name='MS:'>x&sup2;" WinX2 " y&sup2;" WinY2 "</span>"
		. _DP  _BP1 " id='set_button_pos'>Size:" _BP2 "  <span name='MS:'>w" WinWidth " h" WinHeight "</span>" ViewStrPos1 
	
	. "`n<span class='param'>Client area size:</span>  <span name='MS:'>w" caW " h" caH "</span>" 
		. _DP "<span class='param'>left</span> " caX " <span class='param'>top</span> " caY 
		. " <span class='param'>right</span> " caWinRight " <span class='param'>bottom</span> " caWinBottom  _PRE2 

	. _T1 " id='__Other'> ( Other ) </span>" _BT1 " id='flash_window'> flash " _BT2  _ButWindow_Detective  _T2 

	. _PRE1 "<span class='param' name='MS:N'>PID:</span>  <span name='MS:'>" WinPID "</span>" 
		. _DP  ProcessBitSize  IsAdmin "<span class='param'>Window count:</span> " WinCountProcess  
		. _DP  _BB1 " id='process_close'> process close " _BB2 
		. _DP "<span class='param'>Create info time:  </span><span name='MS:'>" A_Hour ":" A_Min ":" A_Sec 
		. ".<span class='param' style='font-size: 0.75em'>" A_MSec "</span></span>"
		
	. "`n<span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>" WinID "</span>" _DP  _BB1 " id='window_show_hide'> show / hide " _BB2
		. _DP  _BB1 " id='win_close'> close " _BB2  _DP "<span class='param'>Control count:</span>  "
		. CountControl IsWindowUnicodeStr WindowBand _ParentWindow EX1Str CLSID 

	. "`n<span class='param'>Style:  </span><span id='w_Style' name='MS:'>" WinStyle "</span>" 
		. _DP "<span class='param'>ExStyle:  </span><span id='w_ExStyle' name='MS:'>" WinExStyle "</span>" 
		. _DP _BB1 " id='get_styles_w'> " (!w_ShowStyles ? "show" : "hide" ) " styles " _BB2
		. _DP _BB1 " id='update_styles_w'> update styles " _BB2 _PRE2 

	. "`n<span id=WinStyles>" WinStyles "</span>" SBText  WinText  MenuText "<a></a>" _T0 
 
 
	oOther.WinPID := WinPID
	oOther.WinID := WinID
	oOther.ChildID := hChild
	If StateLightMarker && (ThisMode = "Win") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift")))
		ShowMarker(WinX, WinY, WinWidth, WinHeight, 5) 
	Return 1
}

Write_Win(scroll = 0) {
	If (ThisMode != "Win")
		Return 0  
	oDivOld := oDivWork%DivWorkIndex%
	DivWorkIndex := DivWorkIndex = 1 ? 2 : 1
	oDivNew := oDivWork%DivWorkIndex%  
	oDivNew.innerHTML := HTML_Win 
	If oOther.anchor[ThisMode]
		AnchorScroll(AnchorColor())
	Else
		oDivNew.scrollTop := scroll ? ScrollPos[ThisMode, 2] : (ScrollPos[ThisMode, 2] := oDivOld.scrollTop)
		
	If oDivNew.scrollLeft
		oDivNew.scrollLeft := 0 

	oDivNew.style.zIndex := 1 
	oDivOld.style.zIndex := 0 
	
	oDivNew.style.visibility := "visible"
	oDivOld.innerHTML := ""
	Return 1 
}

	; ___________________________ Mode_Control _________________________________________________

Mode_Control:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	ZoomMsg(10, 0)
	; oBody.createTextRange().execCommand("RemoveFormat")
	ColorButton("Control") 
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
		
	Try SetTimer, Loop_%ThisMode%, Off
	
	ScrollPos[ThisMode, 1] := oDivNew.scrollLeft
	ScrollPos[ThisMode, 2] := oDivNew.scrollTop
	
	If ThisMode != Control
		HTML_%ThisMode% := oDivNew.innerHTML, prNotThisMode := 1
		
	ThisMode := "Control"
	
	If (HTML_Control = "")
		Spot_Control(1)
		
	Write_Control(prNotThisMode)
	
	TitleText := (TitleTextP1 := "AhkSpy - Control") . TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	If isFindView
		FindNewText()

Loop_Control:
	If (WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1
		GoTo Repeat_Loop_Control
	If !OnlyShiftTab && Spot_Control()
		Write_Control(), StateAllwaysSpot ? Spot_Win() : 0
		
Repeat_Loop_Control:
	If (!isPaused && ThisMode = "Control" && !OnlyShiftTab) 
		SetTimer, Loop_Control, -%RangeTimer%  
	Return

Spot_Control(NotHTML = 0) {
	If NotHTML
		GoTo HTML_Control
		
	CoordMode, Mouse, Screen
	MouseGetPos, MXS, MYS, WinID, tControlNN
	
	If (WinID = hGui || WinID = oOther.hZoom || WinID = oOther.hZoomLW)
		Return 0, HideAllMarkers()
		
	osCoords.MXS := MXS, osCoords.MYS := MYS
	oObjActive.ScreenX := MXS, oObjActive.ScreenY := MYS
	CoordMode, Mouse, Window
	MouseGetPos, MXWA, MYWA, , tControlID, 2
	osCoords.MXWA := MXWA, osCoords.MYWA := MYWA
	WinGet, ProcessName_A, ProcessName, A
	WinGet, HWND_A, ID, A
	WinGetClass, WinClass_A, A

	CtrlInfo := "", isIE := 0
	ControlNN := tControlNN, ControlID := tControlID
	WinGetPos, WinX, WinY, WinW, WinH, ahk_id %WinID%
	osCoords.WinW := WinW, osCoords.WinH := WinH
	WinGet, WinPID, PID, ahk_id %WinID%
	osCoords.RWinX := RWinX := MXS - WinX, osCoords.RWinY := RWinY := MYS - WinY
	GetClientPos(WinID, caX, caY, caW, caH)
	MXC := RWinX - caX, MYC := RWinY - caY
	osCoords.caW := caW, osCoords.caH := caH
	osCoords.MXC := MXC, osCoords.MYC := MYC
	 
	cc := _DP "" _BB1 " name='x" RWinX " y" RWinY "' id='control_click'> control click " _BB2  
	WithRespectWin := cc "`n" _BP1 " id='set_pos'>Relative window:" _BP2 "  <span name='MS:' id='coord_rwin'>"
		. Round(RWinX / WinW, 4) ", " Round(RWinY / WinH, 4) "</span>  <span class='param'>for</span> <span name='MS:'>w" WinW " h" WinH "</span>" _DP
	WithRespectClient := _BP1 " id='set_pos'>Relative client:" _BP2 "  <span name='MS:' id='coord_rclient'>" Round(MXC / caW, 4) ", " Round(MYC / caH, 4)
		. "</span>  <span class='param'>for</span> <span name='MS:'>w" caW " h" caH "</span>"

	ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH,, ahk_id %ControlID%
	
	AccText := AccInfoUnderMouse(MXS, MYS, WinX, WinY, CtrlX, CtrlY, caX, caY, WinID, ControlID)
	If AccText !=
		AccText := _T1 " id='__AccInfo'> ( Accessible ) </span><a></a>" _BT1 " id='flash_acc'> flash " _BT2 _ButAccViewer _T2 AccText
		
	If ControlID
	{
		CtrlCAX := CtrlX - caX, CtrlCAY := CtrlY - caY
		
		CtrlX2 := CtrlX + CtrlW - 1, CtrlY2 := CtrlY + CtrlH - 1
		CtrlCAX2 := CtrlX2 - caX, CtrlCAY2 := CtrlY2 - caY
		
		CtrlSCX := WinX + CtrlX, CtrlSCY := WinY + CtrlY
		CtrlSCX2 := CtrlSCX + CtrlW - 1, CtrlSCY2 := CtrlSCY + CtrlH - 1 
		
		ControlGetText, CtrlText, , ahk_id %ControlID%
		If CtrlText !=
			CtrlText := _T1 " id='__Control_Text'> ( Control Text ) </span><a></a>" _BT1 " id='copy_button_CtrlText'> copy " _BT2 _DB _BT1 " id='settext_button' value=`" ControlID "`> set " _BT2 
				. _DB  _BT1 " id='paste_Control_Text'> paste " _BT2  _T2  _LPRE " id='content_Control_Text'>" TransformHTML(CtrlText) _PRE2
		
		ControlGet, CtrlStyle, Style,,, ahk_id %ControlID%
		ControlGet, CtrlExStyle, ExStyle,,, ahk_id %ControlID%
		WinGetClass, CtrlClass, ahk_id %ControlID%
		
		If (hParent := DllCall("GetParent", "Ptr", ControlID)) && (hParent != WinID)
		{
			WinGetClass, ParentClass, ahk_id %hParent%
			_ParentControl := _DP "<span class='param'>Parent control:</span>  <span name='MS:'>" ParentClass "</span>" _DP "<span name='MS:'>" Format("0x{:x}", hParent) "</span>"
		}
		
		If ViewStrPos
			ViewStrPos1 := _DP "<span name='MS:'>" CtrlX ", " CtrlY ", " CtrlX2 ", " CtrlY2 "</span>" _DP "<span name='MS:'>" CtrlX ", " CtrlY ", " CtrlW ", " CtrlH "</span>"
			, ViewStrPos2 := _DP "<span name='MS:'>" CtrlCAX ", " CtrlCAY ", " CtrlCAX2 ", " CtrlCAY2 "</span>" _DP "<span name='MS:'>" CtrlCAX ", " CtrlCAY ", " CtrlW ", " CtrlH "</span>"
			. _DP "<span name='MS:'>" CtrlSCX ", " CtrlSCY ", " CtrlSCX2 ", " CtrlSCY2 "</span>" _DP "<span name='MS:'>" CtrlSCX ", " CtrlSCY ", " CtrlW ", " CtrlH "</span>" 	
		
		If DynamicControlPath
			ChildToPath(ControlID), control_path_value := SaveChildPath()
	} 
	If ControlNN !=
	{
		rmCtrlX := MXS - WinX - CtrlX, rmCtrlY := MYS - WinY - CtrlY
		ControlNN_Sub := RegExReplace(ControlNN, "S)\d+| ")
		
		;; Scintilla,Edit,SysListView,SysTreeView,ListBox,ComboBox,CtrlNotfySink,msctls_progress
		;; ,msctls_trackbar,msctls_updown,SysTabControl,ToolbarWindow,AtlAxWin,InternetExplorer_Server
		If IsFunc("GetInfo_" ControlNN_Sub)
			Func := ControlNN_Sub
		Else If RegExMatch(ControlNN_Sub, "i)(TreeView|ListView|ListBox|ComboBox|NotfySink|Edit|Scintilla|progress|trackbar|updown|Tab|Toolbar|RichEd)", Match) 
			Func := IsFunc("GetInfo_" Match) ? Match : {RichEd:"Scintilla",TreeView:"SysTreeView", ListView:"SysListView", NotfySink:"CtrlNotfySink"
				, progress:"msctls_progress", trackbar:"msctls_trackbar", updown:"msctls_updown", Tab:"SysTabControl", Toolbar:"ToolbarWindow"}[Match]
			
		If Func
		{
			CtrlInfo := GetInfo_%Func%(ControlID, ClassName)
			If CtrlInfo !=
			{
				If isIE
					CtrlInfo = %_T1% id='__Info_Class'> ( Info - %CtrlClass% ) </span><a></a>%_BT1% id='flash_IE'> flash %_BT2%%_ButiWB2Learner%%_T2%%CtrlInfo%
				Else
					CtrlInfo = %_T1% id='__Info_Class'> ( Info - %CtrlClass% ) </span><a></a>%_T2%%_PRE1%%CtrlInfo%%_PRE2%
			}
		}
		WithRespectControl := _DP "<span name='MS:'>" Round(rmCtrlX / CtrlW, 4) ", " Round(rmCtrlY / CtrlH, 4) "</span>"
	}
	Else
		rmCtrlX := rmCtrlY := ""
	
	ControlGetFocus, CtrlFocus, ahk_id %WinID%
	WinGet, ProcessName, ProcessName, ahk_id %WinID%
	WinGetClass, WinClass, ahk_id %WinID%
	
	MouseGetPos, , , h
	If (h = hGui || h = oOther.hZoom || h = oOther.hZoomLW)
		Return 0, HideAllMarkers()
		
	If !isIE
		SetPosObject("Control", [CtrlSCX, CtrlSCY, CtrlW, CtrlH])  
 
	SetPosObject("AhkSpy", WinGetPosToArray(hActiveX)) 
	
	If UseUIA && exUIASub.Release() && exUIASub.ElementFromPoint(MXS, MYS)
	{ 
		UIAPID := exUIASub.CurrentProcessId
		CurrentControlTypeIndex := Format("0x{:X}", exUIASub.CurrentControlType)
		CurrentControlTypeName := exUIASub.__ControlType(CurrentControlTypeIndex)
		CurrentAutomationId := exUIASub.CurrentAutomationId  
		CurrentLocalizedControlType := exUIASub.CurrentLocalizedControlType
		CurrentHelpText := exUIASub.CurrentHelpText
		UIAHWND := exUIASub.CurrentNativeWindowHandle
		
		
		WinGet, UIAProcessName, ProcessName, ahk_pid %UIAPID%
		WinGet, UIAProcessPath, ProcessPath, ahk_pid %UIAPID%
		
		Loop, %UIAProcessPath%
			UIAProcessPath = %A_LoopFileLongPath%
			
		If UIAAlienDetect && ((UIAPID != WinPID) || (ControlID && ControlID != UIAHWND) || (!ControlID && WinID != UIAHWND))
			bc = style='background-color: #%ColorHighLightBckg%'
		
		UseUIAStr := "`n" _T1 " id='P__UIA_Object'> ( UIA Interface ) </span><a></a>" _T2
		. _PRE1 "<div " bc "><span class='param' name='MS:N'>PID:</span>  <span name='MS:'>" UIAPID "</span>" 
		
		. (UIAHWND ? _DP "<span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>" Format("0x{:x}", UIAHWND) "</span>"
		. _DP "<span class='param' name='MS:N'>ClassName:</span>  <span name='MS:'>" TransformHTML(exUIASub.CurrentClassName) "</span>" : _DP "HWND undefined")
		
		. _DN (CurrentAutomationId != "" ? "<span class='param' name='MS:N'>AutomationId:</span>  <span name='MS:'>" CurrentAutomationId "</span>" : "AutomationId undefined")
			. _DP (CurrentControlTypeIndex != "" ? "<span class='param' name='MS:N'>ControlType:</span>  <span name='MS:'>" CurrentControlTypeName "</span>"
			. _DP " <span name='MS:'>" CurrentControlTypeIndex "</span>" : "ControlType undefined")
			. (CurrentLocalizedControlType != "" ? _DP
			. "<span class='param' name='MS:N'>LocalizedControlType:</span>  <span name='MS:'>" CurrentLocalizedControlType "</span>" : _DP "LocalizedControlType undefined")
		
		. (CurrentHelpText != "" ? _DN "<span class='param' name='MS:N'>HelpText:</span>  <span name='MS:'>" CurrentHelpText "</span>" : "")
		
		. (UIAProcessName != ""
			? _DN "<span class='param' name='MS:N'>ProcessName:</span>  <span name='MS:'>" TransformHTML(UIAProcessName) "</span>"
			. _DP "<span class='param' name='MS:N'>ProcessPath:</span>  <span name='MS:'>" TransformHTML(UIAProcessPath) "</span>" : "")
		. "</div>" _PRE2
	}
	PixelGetColor, ColorBGR, %MXS%, %MYS%
	ColorRGB := Format("0x{:06X}", (ColorBGR & 0xFF) << 16 | (ColorBGR & 0xFF00) | (ColorBGR >> 16))

	sInvert_RGB := Format("{:06X}", ColorRGB ^ 0xFFFFFF)  
	sColorRGB := SubStr(ColorRGB, 3) 
	
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" sColorRGB, ColorProgress
	GuiControl, TB: +Redraw, ColorProgress

	If (!isIE && ThisMode = "Control" && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift"))))
	{
		If ControlID && StateLightMarker 
			ShowMarker(CtrlSCX, CtrlSCY, CtrlW, CtrlH)
		Else
			HideMarker()
			
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	}
	If ((S_CaretX := A_CaretX) != "")
		CaretPosStr = <span class='param'>Caret:</span>  <span name='MS:'>x%S_CaretX% y%A_CaretY%</span>
	Else 
		CaretPosStr = <span class='error'>Caret position undefined</span>
	
	; ___________________________ HTML_Control _________________________________________________
 
HTML_Control:

	If ControlID
	{
		If c_ShowStyles
			ControlStyles := GetStyles(CtrlClass, CtrlStyle, CtrlExStyle, ControlID)
			
		HTML_ControlExist := ""
		. _T1 " id='__Control'> ( Control ) </span>" _BT1 " id='flash_control'> flash " _BT2  _ButWindow_Detective  _T2 
		
		. _PRE1 "<span class='param'>ClassNN:</span>  <span name='MS:'>" ControlNN "</span>"
			. _DP  "<span class='param'>Class:</span>  <span name='MS:'>" CtrlClass "</span>"
			
		. "`n" _BP1 " id='set_button_pos'>Pos:" _BP2 "  <span name='MS:'>x" CtrlX " y" CtrlY "</span>" 
			. _DP "<span name='MS:'>x&sup2;" CtrlX2 " y&sup2;" CtrlY2 "</span>" _DP  _BP1 " id='set_button_pos'>Size:"  _BP2 
			. "  <span name='MS:'>w" CtrlW " h" CtrlH "</span>" ViewStrPos1 
			
		. "`n" "<span class='param'>Relative client area:</span>  <span name='MS:'>x" CtrlCAX " y" CtrlCAY "</span>" 
			. _DP "<span name='MS:'>x&sup2;" CtrlCAX2 " y&sup2;" CtrlCAY2 "</span>"
			. _DP "<span class='param'>Relative screen:</span>  <span name='MS:'>x" CtrlSCX " y" CtrlSCY "</span>" 
			. _DP "<span name='MS:'>x&sup2;" CtrlSCX2 " y&sup2;" CtrlSCY2 "</span>"
			. ViewStrPos2 
			
		. "`n" _BP1 " id='set_pos'>Mouse relative control:" _BP2 "  <span name='MS:'>x" rmCtrlX " y" rmCtrlY "</span>" WithRespectControl 
		
		. "`n<span class='param'>HWND:</span>  <span name='MS:'>" ControlID "</span>" _DP  _BB1 " id='control_show_hide'> show / hide " _BB2 
			. _DP  _BB1 " id='control_destroy'> close " _BB2  _DP  _BP1 " id='control_path'> Get path " _BP2 
			. "<span id='control_path_error'></span>" _ParentControl 
			
		. "`n<span class='param'>Style:</span>  <span id='c_Style' name='MS:'>" CtrlStyle "</span>" 
			. _DP "<span class='param'>ExStyle:</span>  <span id='c_ExStyle' name='MS:'>" CtrlExStyle "</span>" 
			. _DP _BB1 " id='get_styles_c'> " (!c_ShowStyles ? "show styles" : "hide styles") " " _BB2
			. _DP _BB1 " id='update_styles_c'> update styles " _BB2   _PRE2
		
		. "`n<span id='control_path_value'>" control_path_value "</span>"
		
		. "`n<span id=ControlStyles>" ControlStyles "</span>" 
	} 
	
	HTML_Control := ""
	. _T1 " id='__Mouse'> ( Mouse ) </span>" _BT1 " id='pause_button'> pause " _BT2 _T2 
	
	. _PRE1  _BP1 " id='set_pos'>Screen:" _BP2 "  <span name='MS:' id='coord_screen'>x" MXS " y" MYS "</span>" _DP  _BP1 " id='set_pos'>Window:" _BP2 
		. "  <span name='MS:' id='coord_win'>x" RWinX " y" RWinY "</span>" _DP  _BP1 " id='set_pos'>Client:" _BP2 
		. "  <span name='MS:' id='coord_client'>x" MXC " y" MYC "</span>" WithRespectWin  WithRespectClient 
	
	. "`n<span class='param'>Relative active window:</span>  <span name='MS:' id='coord_awin'>x" MXWA " y" MYWA "</span>" 
		. _DP "<span class='param'>class</span> <span name='MS:'>" WinClass_A 
		. "</span> <span class='param'>exe</span> <span name='MS:'>" ProcessName_A 
		. "</span> <span class='param'>hwnd</span> <span name='MS:'>" HWND_A "</span>" _PRE2 
	
	. _T1 " id='__PixelColor'> ( PixelColor ) </span>" _T2 
	
	. _PRE1 "<span class='param'>RGB: </span> <span name='MS:' id='ColorRGB'>" ColorRGB "</span>" 
		. _DP "#<span name='MS:' id='sColorRGB'>" sColorRGB "</span>" _DP "<span class='param'>BGR: </span> <span name='MS:' id='ColorBGR'>" ColorBGR "</span>" 
		. _DP "#<span name='MS:' id='sColorBGR'>" SubStr(ColorBGR, 3) "</span>" 
		. _DP "<span class='param'>Invert RGB: </span> <span name='MS:' id='sInvert_RGB0'>0x" sInvert_RGB "</span>" 
		. _DP "#<span name='MS:' id='sInvert_RGB'>" sInvert_RGB "</span>" _DP "<span style='background-color: #" sInvert_RGB "' id='RenderInvert_RGB'>          </span>" _PRE2 
	
	. _T1 " id='__Window'> ( Window ) </span>" _BT1 " id='flash_ctrl_window'> flash " _BT2  _T2 
	 
	. _PRE1 "<span><span class='param' name='MS:S'>ahk_class</span> <span name='MS:'>" WinClass "</span></span> "
		. "<span><span class='param' name='MS:S'>ahk_exe</span> <span name='MS:'>" ProcessName "</span></span> "
		. "<span><span class='param' name='MS:S'>ahk_id</span> <span name='MS:'>" WinID "</span></span> "
		. "<span><span class='param' name='MS:S'>ahk_pid</span> <span name='MS:'>" WinPID "</span></span>"
		. _DP "<span class='param'>Create info time:  </span><span name='MS:'>" A_Hour ":" A_Min ":" A_Sec 
		. ".<span class='param' style='font-size: 0.75em'>" A_MSec "</span></span>"

	. "`n<span class='param'>Cursor:</span>  <span name='MS:'>" A_Cursor "</span>" 
		. _DP  CaretPosStr  _DP "<span class='param'>Client area:</span>  <span name='MS:'>x" caX " y" caY " w" caW " h" caH "</span>"

	. "`n" _BP1 " id='set_button_focus_ctrl'>Focus control:" _BP2 "  <span name='MS:'>" CtrlFocus "</span>" _PRE2 

	. "`n" HTML_ControlExist 

	. "`n" CtrlInfo CtrlText UseUIAStr AccText "<a></a>" _T0
	
	oOther.ControlID := ControlID
	oOther.MouseWinID := WinID
	oOther.CtrlClass := CtrlClass
	oOther.MouseWinClass := WinClass
	Return 1
}

Write_Control(scroll = 0) {
	If (ThisMode != "Control")
		Return 0  
	oDivOld := oDivWork%DivWorkIndex%
	DivWorkIndex := DivWorkIndex = 1 ? 2 : 1
	oDivNew := oDivWork%DivWorkIndex%  
	oDivNew.innerHTML := HTML_Control 

	If oOther.anchor[ThisMode]
		AnchorScroll(AnchorColor())
	Else
		oDivNew.scrollTop := scroll ? ScrollPos[ThisMode, 2] : (ScrollPos[ThisMode, 2] := oDivOld.scrollTop)
		
	If oDivNew.scrollLeft
		oDivNew.scrollLeft := 0 

	oDivNew.style.zIndex := 1 
	oDivOld.style.zIndex := 0 
	
	oDivNew.style.visibility := "visible"
	oDivOld.innerHTML := ""
	Return 1
}

	; ___________________________ Get Menu _________________________________________________

GetMenu(hWnd) {
	;; Static prhWnd, MenuText
	;; If (hWnd = prhWnd)
		;; Return MenuText
	;; prhWnd := hWnd
	SendMessage, 0x1E1, 0, 0, , ahk_id %hWnd%	;;  MN_GETHMENU
	hMenu := ErrorLevel
	If !hMenu || (hMenu + 0 = "")
		Return
	Return _T1 " id='__Menu_text'> ( Menu text ) </span><a></a>" _BT1 " id='copy_menutext'> copy " _BT2 _DB
	. _BT1 " id='menu_idview'> id - " (MenuIdView ? "view" : "hide") " " _BT2 _T2 _LPRE " id='pre_menutext'>" RTrim(GetMenuText(hMenu), "`n")  _PRE2
}

GetMenuText(hMenu, child = 0)
{
	Loop, % DllCall("GetMenuItemCount", "Ptr", hMenu)
	{
		idx := A_Index - 1
		nSize++ := DllCall("GetMenuString", "Ptr", hMenu, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)   ;;  MF_BYPOSITION
		nSize := (nSize * (A_IsUnicode ? 2 : 1))
		VarSetCapacity(sString, nSize)
		DllCall("GetMenuString", "Ptr", hMenu, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;;  MF_BYPOSITION
		sString := TransformHTML(sString)
		idn := DllCall("GetMenuItemID", "Ptr", hMenu, "int", idx)
		IdItem := "<span class='param menuitemid' style='display: " (!MenuIdView ? "none" : "inline") ";;'>`t`t`t<span name='MS:'>" idn "</span></span>"
		isSubMenu := (idn = -1) && (hSubMenu := DllCall("GetSubMenu", "Ptr", hMenu, "int", idx)) ? 1 : 0
		If isSubMenu
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  </span><span name='MS:' class='titleparam'>" sString "</span>" IdItem "`n"
		Else If (sString = "")
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  &#8212; &#8212; &#8212; &#8212; &#8212; &#8212; &#8212;</span>" IdItem "`n"
		Else
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  </span><span name='MS:'>" sString "</span>" IdItem "`n"
		If isSubMenu
			sContents .= GetMenuText(hSubMenu, ++child), --child
	}
	Return sContents
}

AddTab(c) {
	loop % c
		Tab .= "<span class='param';'>&#8595;`t</span>"
	Return Tab
}

	; ___________________________ Get Info Control _________________________________________________

;; Scintilla,Edit,SysListView,SysTreeView,ListBox,ComboBox,CtrlNotfySink,msctls_progress
;; ,msctls_trackbar,msctls_updown,SysTabControl,ToolbarWindow,AtlAxWin,InternetExplorer_Server

;; TreeView, ListView, NotfySink, progress, trackbar, updown, Tab, Toolbar


GetInfo_SysListView(hwnd) { 
	ControlGet, ListText, List,,, ahk_id %hwnd%
	ControlGet, RowCount, List, Count,, ahk_id %hwnd%
	ControlGet, ColCount, List, Count Col,, ahk_id %hwnd%
	ControlGet, SelectedCount, List, Count Selected,, ahk_id %hwnd%
	ControlGet, FocusedCount, List, Count Focused,, ahk_id %hwnd%
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" RowCount "</span>" _DP
			. "<span class='param' name='MS:N'>Column count:</span> <span name='MS:'>" ColCount "</span>`n"
			. "<span class='param' name='MS:N'>Selected count:</span> <span name='MS:'>" SelectedCount "</span>" _DP
			. "<span class='param' name='MS:N'>Focused row:</span> <span name='MS:'>" FocusedCount "</span>" _PRE2
			. _T1 " id='__Content_SysListView'> ( Content ) </span>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(ListText)
}

GetInfo_SysTreeView(hwnd) { 
	SendMessage 0x1105, 0, 0, , ahk_id %hwnd%   ;; TVM_GETCOUNT
	ItemCount := ErrorLevel
	Return	"<span class='param' name='MS:N'>Item count:</span> <span name='MS:'>" ItemCount "</span>"
}

GetInfo_ListBox(hwnd) { 
	Return GetInfo_ComboBox(hwnd, 1)
}

GetInfo_ComboBox(hwnd, ListBox = 0) { 
	ControlGet, ListText, List,,, ahk_id %hwnd%
	SendMessage, (ListBox ? 0x188 : 0x147), 0, 0, , ahk_id %hwnd%   ;; 0x188 - LB_GETCURSEL, 0x147 - CB_GETCURSEL
	SelPos := ErrorLevel
	SelPos := SelPos = 0xffffffff || SelPos < 0 ? "NoSelect" : SelPos + 1
	RegExReplace(ListText, "m`a)$", "", RowCount)
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" RowCount "</span>" _DP
			. "<span class='param' name='MS:N'>Row selected:</span> <span name='MS:'>" SelPos "</span>" _PRE2
			. _T1 " id='__Content_ComboBox'> ( Content ) </span>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(ListText)
}

GetInfo_CtrlNotifySink(hwnd) { 
	Return GetInfo_Scintilla(hwnd)
}

	;;  http://forum.script-coding.com/viewtopic.php?pid=117128#p117128
	;;  https://msdn.microsoft.com/en-us/library/windows/desktop/ms645478(v=vs.85).aspx

GetInfo_Edit(hwnd) { 
	Edit_GetFont(hwnd, FName, FSize)
	Return GetInfo_Scintilla(hwnd) "`n<span class='param' name='MS:N'>FontSize:</span> <span name='MS:'>" FSize "</span>" 
		. _DP "<span class='param' name='MS:N'>FontName:</span> <span name='MS:'>" FName "</span>"
		. "`n<span class='param' name='MS:N'>DlgCtrlID:</span> <span name='MS:'>" DllCall("GetDlgCtrlID", Ptr, hwnd) "</span>"
}

Edit_GetFont(hwnd, byref FontName, byref FontSize) {
	SendMessage 0x31, 0, 0, , ahk_id %hwnd% ;; WM_GETFONT
	If ErrorLevel = FAIL
		Return
	hFont := Errorlevel, VarSetCapacity(LF, szLF := 60 * (A_IsUnicode ? 2 : 1))
	DllCall("GetObject", UInt, hFont, Int, szLF, UInt, &LF)
	hDC := DllCall("GetDC", UInt, hwnd), DPI := DllCall("GetDeviceCaps", UInt, hDC, Int, 90)
	DllCall("ReleaseDC", Int, 0, UInt, hDC), FontSize := Round((-NumGet(LF, 0, "Int") * 72) / DPI)
	FontName := DllCall("MulDiv", Int, &LF + 28, Int, 1, Int, 1, Str)
}

GetInfo_Scintilla(hwnd) { 
	ControlGet, LineCount, LineCount,,, ahk_id %hwnd%
	ControlGet, CurrentCol, CurrentCol,,, ahk_id %hwnd%
	ControlGet, CurrentLine, CurrentLine,,, ahk_id %hwnd%
	ControlGet, Selected, Selected,,, ahk_id %hwnd%
	SendMessage, 0x00B0, , , , ahk_id %hwnd%			;;  EM_GETSEL
	EM_GETSEL := ErrorLevel >> 16
	SendMessage, 0x00CE, , , , ahk_id %hwnd%			;;  EM_GETFIRSTVISIBLELINE
	EM_GETFIRSTVISIBLELINE := ErrorLevel + 1
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" LineCount "</span>" _DP
			. "<span class='param' name='MS:N'>Selected length:</span> <span name='MS:'>" StrLen(Selected) "</span>"
			. "`n<span class='param' name='MS:N'>Current row:</span> <span name='MS:'>" CurrentLine "</span>" _DP
			. "<span class='param' name='MS:N'>Current column:</span> <span name='MS:'>" CurrentCol "</span>"
			. "`n<span class='param' name='MS:N'>Current select:</span> <span name='MS:'>" EM_GETSEL "</span>" _DP
			. "<span class='param' name='MS:N'>First visible line:</span> <span name='MS:'>" EM_GETFIRSTVISIBLELINE "</span>"
}

GetInfo_msctls_progress(hwnd) { 
	SendMessage, 0x0400+7,"TRUE",,, ahk_id %hwnd%	;;  PBM_GETRANGE
	PBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+7,,,, ahk_id %hwnd%			;;  PBM_GETRANGE
	PBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400+8,,,, ahk_id %hwnd%			;;  PBM_GETPOS
	PBM_GETPOS := ErrorLevel
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" PBM_GETPOS "</span>" _DP
			. "<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" PBM_GETRANGEMIN "</span>"
			. "  <span class='param' name='MS:N'>Max:</span> <span name='MS:'>" PBM_GETRANGEMAX "</span>"
}

GetInfo_msctls_trackbar(hwnd) { 
	SendMessage, 0x0400+1,,,, ahk_id %hwnd%			;;  TBM_GETRANGEMIN
	TBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+2,,,, ahk_id %hwnd%			;;  TBM_GETRANGEMAX
	TBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400,,,, ahk_id %hwnd%			;;  TBM_GETPOS
	TBM_GETPOS := ErrorLevel
	ControlGet, CtrlStyle, Style,,, ahk_id %hwnd%
	(!(CtrlStyle & 0x0200)) ? (TBS_REVERSED := "No")
	: (TBM_GETPOS := TBM_GETRANGEMAX - (TBM_GETPOS - TBM_GETRANGEMIN), TBS_REVERSED := "Yes")
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" TBM_GETPOS "</span>" _DP
			. "<span class='param'>Invert style:</span>" TBS_REVERSED
			. "`n<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" TBM_GETRANGEMIN "</span>" _DP
			. "<span class='param' name='MS:N'>Max:</span> <span name='MS:'>" TBM_GETRANGEMAX "</span>"
}

GetInfo_msctls_updown(hwnd) { 
	SendMessage, 0x0400+102,,,, ahk_id %hwnd%		;;  UDM_GETRANGE
	UDM_GETRANGE := ErrorLevel
	SendMessage, 0x400+114,,,, ahk_id %hwnd%		;;  UDM_GETPOS32
	UDM_GETPOS32 := ErrorLevel
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" UDM_GETPOS32 "</span>" _DP
			. "<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" UDM_GETRANGE >> 16 "</span>"
			. "  <span class='param' name='MS:N'>Max: </span><span name='MS:'>" UDM_GETRANGE & 0xFFFF "</span>"
}

GetInfo_SysTabControl(hwnd) { 
	ControlGet, SelTab, Tab,,, ahk_id %hwnd%
	SendMessage, 0x1300+44,,,, ahk_id %hwnd%		;;  TCM_GETROWCOUNT
	TCM_GETROWCOUNT := ErrorLevel
	SendMessage, 0x1300+4,,,, ahk_id %hwnd%			;;  TCM_GETITEMCOUNT
	TCM_GETITEMCOUNT := ErrorLevel
	Return	"<span class='param' name='MS:N'>Item count:</span> <span name='MS:'>" TCM_GETITEMCOUNT "</span>" _DP
			. "<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" TCM_GETROWCOUNT "</span>" _DP
			. "<span class='param' name='MS:N'>Selected item:</span> <span name='MS:'>" SelTab "</span>"
}

GetInfo_ToolbarWindow(hwnd) { 
	SendMessage, 0x0418,,,, ahk_id %hwnd%		;;  TB_BUTTONCOUNT
	BUTTONCOUNT := ErrorLevel
	Return	"<span class='param' name='MS:N'>Button count:</span> <span name='MS:'>" BUTTONCOUNT "</span>"
}

	; ___________________________ Get Internet Explorer Info _________________________________________________

	;;  http://www.autohotkey.com/board/topic/84258-iwb2-learner-iwebbrowser2/

GetInfo_AtlAxWin(hwnd) { 
	Return GetInfo_InternetExplorer_Server(hwnd)
}

GetInfo_InternetExplorer_Server(hwnd) {
	Static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	, ratios := [], IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"

	isIE := 1 
	MouseGetPos, , , , hwnd, 3
	If !(pwin := WBGet(hwnd))
		Return
	If !ratios[hwnd]
	{
		ratio := pwin.window.screen.deviceXDPI / pwin.window.screen.logicalXDPI
		Sleep 10 ;; при частом запросе deviceXDPI, возвращает пусто
		!ratio && (ratio := 1)
		ratios[hwnd] := ratio
	}
	ratio := ratios[hwnd]
	pelt := pwin.document.elementFromPoint(rmCtrlX / ratio, rmCtrlY / ratio)
	Tag := pelt.TagName
	If (Tag = "IFRAME" || Tag = "FRAME")
	{
		If pFrame := ComObjQuery(pwin.document.parentWindow.frames[pelt.id], IID_IHTMLWindow2, IID_IHTMLWindow2)
			iFrame := ComObject(9, pFrame, 1)
		Else
			iFrame := ComObj(9, ComObjQuery(pelt.contentWindow, IID_IHTMLWindow2, IID_IHTMLWindow2), 1)
		WB2 := ComObject(9, ComObjQuery(pelt.contentWindow, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)
		If ((Var := WB2.LocationName) != "")
			Frame .= "`n<span class='param' name='MS:N'>Title:  </span><span name='MS:'>" TransformHTML(Var) "</span>"
		If ((Var := WB2.LocationURL) != "")
			Frame .= "`n<span class='param' name='MS:N'>URL:  </span><span name='MS:'>" TransformHTML(Var) "</span>"
		If (iFrame.length)
			Frame .= "`n<span class='param' name='MS:N'>Count frames:  </span><span name='MS:'>" TransformHTML(iFrame.length) "</span>"
		If (Tag != "")
			Frame .= "`n<span class='param' name='MS:N'>TagName:  </span><span name='MS:'>" TransformHTML(Tag) "</span>"
		If ((Var := pelt.id) != "")
			Frame .= "`n<span class='param' name='MS:N'>ID:  </span><span name='MS:'>" TransformHTML(Var) "</span>"
		If ((Var := pelt.className) != "")
			Frame .= "`n<span class='param' name='MS:N'>Class:  </span><span name='MS:'>" TransformHTML(Var) "</span>"
		If ((Var := pelt.sourceIndex) != "")
			Frame .= "`n<span class='param' name='MS:N'>Index:  </span><span name='MS:'>" TransformHTML(Var) "</span>"
		If ((Var := pelt.name) != "")
			Frame .= "`n<span class='param' name='MS:N'>Name:  </span><span name='MS:'>" TransformHTML(Var) "</span>"

		If ((Var := pelt.OuterHtml) != "")
			HTML := _T1 " id='P__Outer_HTML_FRAME'" _T1P "> ( Outer HTML ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		If ((Var := pelt.OuterText) != "")
			Text := _T1 " id='P__Outer_Text_FRAME'" _T1P "> ( Outer Text ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		If Frame !=
			Frame := _T1 " id='__FrameInfo_FRAME'> ( FrameInfo ) </span>" _T2 "<a></a>" _PRE1 Frame _PRE2 HTML Text

		_pbrt := pelt.getBoundingClientRect()
		pelt := iFrame.document.elementFromPoint((rmCtrlX / ratio) - _pbrt.left, (rmCtrlY / ratio) - _pbrt.top)
		__pbrt := pelt.getBoundingClientRect(), pbrt := {}
		pbrt.left := __pbrt.left + _pbrt.left, pbrt.right := __pbrt.right + _pbrt.left
		pbrt.top := __pbrt.top + _pbrt.top, pbrt.bottom := __pbrt.bottom + _pbrt.top
	}
	Else
		pbrt := pelt.getBoundingClientRect()

	WB2 := ComObject(9, ComObjQuery(pwin, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)

	If ((Location := WB2.LocationName) != "")
		Topic .= "<span class='param' name='MS:N'>Title:  </span><span name='MS:'>"  TransformHTML(Location) "</span>`n"
	If ((URL := WB2.LocationURL) != "")
		Topic .= "<span class='param' name='MS:N'>URL:  </span><span name='MS:'>"  TransformHTML(URL) "</span>"
	If Topic !=
		Topic := _PRE1 Topic _PRE2

	If ((Var := pelt.id) != "")
		Info .= "`n<span class='param' name='MS:N'>ID:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.className) != "")
		Info .= "`n<span class='param' name='MS:N'>Class:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.sourceIndex) != "")
		Info .= "`n<span class='param' name='MS:N'>Index:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.name) != "")
		Info .= "`n<span class='param' name='MS:N'>Name:  </span><span name='MS:'>" TransformHTML(Var) "</span>"

	If ((Var := pelt.OuterHtml) != "")
		HTML := _T1 " id='P__Outer_HTML'" _T1P "> ( Outer HTML ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
	If ((Var := pelt.OuterText) != "")
		Text := _T1 " id='P__Outer_Text'" _T1P "> ( Outer Text ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2

	x1 := pbrt.left * ratio, y1 := pbrt.top * ratio
	x2 := pbrt.right * ratio, y2 := pbrt.bottom * ratio
	ObjRelease(pwin), ObjRelease(pelt), ObjRelease(WB2), ObjRelease(iFrame), ObjRelease(pbrt)

	If (ThisMode = "Control") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift")))
	{
		WinGetPos, sX, sY, , , ahk_id %hwnd%
		StateLightMarker ? ShowMarker(sX + x1, sY + y1, x2 - x1, y2 - y1) : 0
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	} 
	; SetPosObject("Control", [Round(sX + x1), Round(sY + y1), Round(x2 - x1), Round(y2 - y1)])  
	SetPosObject("Control", [Format("{:d}", sX + x1), Format("{:d}", sY + y1), Format("{:d}", x2 - x1), Format("{:d}", y2 - y1)])  
	If (pelt.TagName)
		Info := _T1 " id='P__Tag_name' name='MS:N'> ( Tag name: <span name='MS:' style='color: #" ColorFont ";'>"
		. pelt.TagName "</span>" (Frame ? " - (in frame)" : "") " ) </span>" _T2
		. _PRE1  "<span class='param'>Pos: </span><span name='MS:'>x" Round(x1) " y" Round(y1) "</span>"
		. _DP "<span name='MS:'>x&sup2;" Round(x2) - 1 " y&sup2;" Round(y2) - 1 "</span>"
		. _DP "<span class='param'>Size: </span><span name='MS:'>w" Round(x2 - x1) " h" Round(y2 - y1) "</span>" Info _PRE2

	oPubObj.IEElement := {Pos:[sX + x1, sY + y1, x2 - x1, y2 - y1], hwnd:hwnd}
	
	Return Topic Info HTML Text Frame 
}

WBGet(hwnd) {
	Static Msg := DllCall("RegisterWindowMessage", "Str", "WM_HTML_GETOBJECT")
	, IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}", GUID, _ := VarSetCapacity(GUID,16,0)
	SendMessage, Msg, , , , ahk_id %hwnd%
	DllCall("oleacc\ObjectFromLresult", "Ptr", ErrorLevel, "Ptr", &GUID, "Ptr", 0, PtrP, pdoc)
	Return ComObj(9, ComObjQuery(pdoc, IID_IHTMLWindow2, IID_IHTMLWindow2), 1), ObjRelease(pdoc)
}

	; ___________________________ Get Acc Info _________________________________________________

	;;  http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/
	   
AccInfoUnderMouse(mx, my, wx, wy, cx, cy, caX, caY, WinID, ControlID) {
	Static hLibrary, AccObj, WM_GETOBJECT := 0x003D, OBJID_CARET := 0xFFFFFFF8
	
	If (WinID = "") { 
		AccObj := ""
		Return
	}
	If !hLibrary
		hLibrary := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")

	AccObj := ""
	If (oOther.AccCLOAKEDWinID != oPubObj.Acc.WinID)
		ObjRelease(oPubObj.Acc.pAccObj)
		
		;;  https://docs.microsoft.com/en-us/windows/win32/api/oleacc/nf-oleacc-accessibleobjectfrompoint
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", mx & 0xFFFFFFFF | my << 32, "Ptr*", pAccObj
		, "Ptr", VarSetCapacity(varChild, 8 + 2 * A_PtrSize, 0) * 0 + &varChild) = 0
		
	; http://forum.script-coding.com/viewtopic.php?pid=139109#p139109
	; Acc := ComObjEnwrap(9, pacc, 1), child := NumGet(varChild,8,"UInt")
	
	AccObj := ComObject(9, pAccObj, 1)
	
	If !IsObject(AccObj)
		Return
	
	ObjAddRef(pAccObj) 
	child := NumGet(varChild, 8, "UInt")
	
	; SendMessage, WM_GETOBJECT, 0, 1, , % "ahk_id" (ControlID ? ControlID : WinID) 
	SendMessage, WM_GETOBJECT, 0, 1, Chrome_RenderWidgetHostHWND1, % "ahk_id " WinID
	
	oPubObj.Acc := {AccObj: Object(AccObj), child: child, WinID: WinID, ControlID: ControlID, pAccObj: pAccObj} 
	
	ChildCount := AccObj.accChildCount
	If child
		Var := "<span name='MS:'>Simple Element</span>" _DP "<span class='param' name='MS:N'>Id:  </span>" child
	Else If ChildCount
		Var := "<span name='MS:'>Container</span>" _DP "<span class='param' name='MS:N'>ChildCount:  </span>" ChildCount _DP "<span class='param' name='MS:N'>Id:  </span>" child 
	Else
		Var := "<span name='MS:'>Real Object</span>" _DP "<span class='param' name='MS:N'>Id:  </span>" child    ;;  _DP "<span class='param' name='MS:N'>Container child count:  </span>" ChildCount
		
	If DynamicAccPath
	{ 
		If acc_path_func(0)
			acc_path_value := SaveAccPath()
		Else 
			error := "<span style='color:#" ColorErrorAccPath "'>  path not found</span>"
	}
	pathbutton := _DP _BP1 " id='acc_path'> Get path " _BP2 "</span><span id='acc_path_error'>" error "</span>" 
	code := _PRE1 "<span class='param'>Type:</span>  " Var pathbutton 
	. _DP _BP1 " id='acc_DoDefaultAction2'> DoDefaultAction " _BP2 "</span>"
	. _PRE2 "<span id='acc_path_value'>" acc_path_value "</span>" 

	AccGetLocation(AccObj, child)
	x := AccCoord[1], y := AccCoord[2], w := AccCoord[3], h := AccCoord[4] 
	SetPosObject("accesible", [x, y, w, h])  

	code .= _T1 " id='P__Position_relative_Acc'" _T1P "> ( Position relative ) </span>" _T2
		. _PRE1 "<span class='param'>Screen: </span>"
		. "<span name='MS:'>x" x " y" y "</span>"
		. _DP "<span name='MS:'>x&sup2;" x + w - 1 " y&sup2;" y + h - 1 "</span>"
		. _DP "<span class='param'>Size: </span><span name='MS:'>w" w " h" h "</span>"
		.  _DP  "<span class='param'>Mouse: </span><span name='MS:'>x" mx - AccCoord[1] " y" my - AccCoord[2] "</span>`n"

		. "<span class='param'>Window: </span><span name='MS:'>x" x - wx " y" y - wy "</span>"
		. _DP "<span name='MS:'>x&sup2;" x - wx + w - 1 " y&sup2;" y - wy + h - 1 "</span>"
		
		. _DP "<span class='param'>Client: </span><span name='MS:'>x" x - wx - caX " y" y - wy - caY "</span>"
		. _DP "<span name='MS:'>x&sup2;" x - wx + w - 1 - caX " y&sup2;" y - wy + h - 1 - caY "</span>"
		 
		. (cx != "" ? _DP "<span class='param'>Control: </span><span name='MS:'>x" (x - wx - cx) " y" (y - wy - cy) "</span>"
		. _DP "<span name='MS:'>x&sup2;" (x - wx - cx) + w - 1 " y&sup2;" (y - wy - cy) + h - 1 "</span>" : "")  _PRE2

	CaretPos := AccGetLocationToObj(Acc_ObjectFromWindow(WinID, OBJID_CARET))
	If (CaretPos.x != 0 || CaretPos.y != 0)
	{ 
		code .= _T1 " id='P__CaretPos_Acc'" _T1P "> ( Caret position relative ) </span>" _T2
			. _PRE1 "<span class='param'>Screen: </span>"
			. "<span name='MS:'>x" CaretPos.x " y" CaretPos.y "</span>"
			. _DP "<span class='param'>Window: </span>"
			. "<span name='MS:'>x" (CaretPos.x - wx) " y" (CaretPos.y - wy) "</span>"
			. _DP "<span class='param'>Client: </span>"
			. "<span name='MS:'>x" (CaretPos.x - wx - caX) " y" (CaretPos.y - wy - caY) "</span>"
			. _DP "<span class='param'>Size: </span>"
			. "<span name='MS:'>w" CaretPos.w " h" CaretPos.h "</span>" . _PRE2
	} 
	If ((Hwnd := AccWindowFromObject(pAccObj)) != ControlID && Hwnd != WinID) {   ;	можно Acc вместо pAccObj, then ComObjValue
		WinGetClass, CtrlClass, ahk_id %Hwnd%
		WinGet, WinProcess, ProcessName, ahk_id %Hwnd%
		WinGet, WinPID, PID, ahk_id %Hwnd%
		code .= _T1 " id='P__WindowFromObject'" _T1P "> ( WindowFromObject ) </span><a></a>" _T2 _PRE1
		. "<div style='background-color: #" ColorHighLightBckg "'><span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>" Format("0x{:x}", Hwnd) "</span>"
		. _DP "<span class='param' name='MS:N'>Class:</span>  <span name='MS:'>" TransformHTML(CtrlClass) "</span>"
		. _DP "<span class='param' name='MS:N'>Exe:</span>  <span name='MS:'>" TransformHTML(WinProcess) "</span>"
		. _DP "<span class='param' name='MS:N'>PID:</span>  <span name='MS:'>" WinPID "</span></div>" _PRE2
	}
	If ((Var := AccObj.accName(child)) != "")
		code .= _T1 " id='P__Name_Acc'" _T1P "> ( Name ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		
	If ((Var := AccObj.accValue(child)) != "")
		code .= _T1 " id='P__Value_Acc'" _T1P "> ( Value ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		
	AccState(AccObj, child, style, strstyles)
	If (strstyles != "")
		code .= _T1 " id='P__State_Acc'" _T1P "> ( State: <span name='MS:' style='color: #" ColorFont ";'>" style "</span> ) </span>" _T2 _PRE1 strstyles _PRE2
		
	If ((Var := AccRole(AccObj, child)) != "")
		code .= _T1 " id='P__Role_Acc'" _T1P "> ( Role ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>"
		. _DP "<span class='param' name='MS:N'>code: </span><span name='MS:'>" AccObj.accRole(child) "</span>" _PRE2
		
	If (child &&(Var := AccRole(AccObj)) != "")
		code .= _T1 " id='P__Role_parent_Acc'" _T1P "> ( Role - parent ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>"
		. _DP "<span class='param' name='MS:N'>code: </span><span name='MS:'>" AccObj.accRole(0) "</span>" _PRE2
		
	If ((Var := AccObj.accDefaultAction(child)) != "")
		code .= _T1 " id='P__Action_Acc'" _T1P "> ( Action ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" 
		. _DP _BP1 " id='acc_DoDefaultAction'> Execute " _BP2 _PRE2
		
	If ((Var := AccObj.accSelection) > 0)
		code .= _T1 " id='P__Selection_parent_Acc'" _T1P "> ( Selection - parent ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	
	If ((Var := AccObj.accDescription(child)) != "")
		code .= _T1 " id='P__Description_Acc'" _T1P "> ( Description ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	
	If ((Var := AccObj.accKeyboardShortCut(child)) != "")
		code .= _T1 " id='P__ShortCut_Acc'" _T1P "> ( ShortCut ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	
	If ((Var := AccObj.accHelp(child)) != "")
		code .= _T1 " id='P__Help_Acc'" _T1P "> ( Help ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	
	If ((Var := AccObj.AccHelpTopic(child)))
		code .= _T1 " id='P__HelpTopic_Acc'" _T1P "> ( HelpTopic ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
		
	AccAccFocus(WinID, accFocusName, accFocusValue, role, irole)
	If (accFocusName != "")
		code .= _T1 " id='P__Focus_name_Acc'" _T1P "> ( Focus - name ) </span><a></a>" 
		. _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(accFocusName) _PRE2
	If (accFocusValue != "")
		code .= _T1 " id='P__Focus_value_Acc'" _T1P "> ( Focus - value ) </span><a></a>"
		. _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(accFocusValue) _PRE2
	If (role != "" && irole != "")
		, code .= _T1 " id='P__Focus__Role_Acc'" _T1P "> ( Focus - Role ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(role) "</span>"
		. _DP "<span class='param' name='MS:N'>code: </span><span name='MS:'>" irole "</span>" _PRE2 
	 
	Return code
}


EVENT_OBJECT_CLOAKED(hWinEventHook, event, hwnd, idObject, idChild) { 
	Critical
	If (idObject || idChild) || (hwnd != oPubObj.Acc.WinID)
		Return
	; ToolTip % ComObjType(AccObj, "Name") "`n" A_ThisFunc
	oPubObj.Acc.CLOAKED := 1 
	AccInfoUnderMouse("", "", "", "", "", "", "", "", "", "")
	oOther.AccCLOAKEDpAccObj := oPubObj.Acc.pAccObj
	oOther.AccCLOAKEDWinID := oPubObj.Acc.WinID
}

EVENT_OBJECT_UNCLOAKED(hWinEventHook, event, hwnd, idObject, idChild) {
	Critical
	If (idObject || idChild) || (hwnd != oOther.AccCLOAKEDWinID)
		Return 
	; ToolTip % hwnd "`n" oOther.AccCLOAKEDpAccObj "`n" A_ThisFunc
	ObjRelease(oOther.AccCLOAKEDpAccObj)
	oPubObj.Acc.CLOAKED := 0
	oOther.AccCLOAKEDpAccObj := ""
	oOther.AccCLOAKEDWinID := ""
}
 
accDoDefaultAction() { 
	If oPubObj.Acc.CLOAKED
		Return 0, ToolTip("CLOAKED", 500)
	Acc := Object(oPubObj.Acc.AccObj) 
	Acc.accDoDefaultAction(oPubObj.Acc.child)
}

	;;	https://docs.microsoft.com/ru-ru/windows/desktop/WinAuto/object-state-constants
	;;	http://forum.script-coding.com/viewtopic.php?pid=130762#p130762
AccState(Acc, child, byref style, byref str, i := 1) {
	style := Format("0x{1:08X}", Acc.accState(child))
	If (style = 0)
		Return "", str := "<span class='param' name='MS:'>" AccGetStateText(0) "</span>" _DP "<span name='MS:'>" 0x00000000 "</span>`n"
	While (i <= style) {
		if (i & style)
			str .= "<span class='param' name='MS:'>" AccGetStateText(i) "</span>" _DP "<span name='MS:'>" Format("0x{1:08X}", i) "</span>`n"
		i <<= 1
	}
}

AccWindowFromObject(pacc) {
	If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc) ? ComObjValue(pacc) : pacc, "Ptr*", hWnd) = 0
		Return hWnd
}
	;;	http://forum.script-coding.com/viewtopic.php?pid=130762#p130762

AccAccFocus(hWnd, byref name, byref value, byref role, byref irole) {
	Acc := Acc_ObjectFromWindow(hWnd)
	While IsObject(Acc.accFocus)
		Acc := Acc.accFocus
	try 
	{
		child := Acc.accFocus
		name := Acc.accName(child)
		value := Acc.accValue(child)
		role := AccRole(Acc, child) 
		irole := Acc.accRole(0) 
	}
}

AccRole(Acc, ChildId=0) {
	Return ComObjType(Acc, "Name") = "IAccessible" ? AccGetRoleText(Acc.accRole(ChildId)) : ""
}

AccGetRoleText(nRole) {
	nSize := DllCall("oleacc\GetRoleText", "UInt", nRole, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "UInt", nRole, "str", sRole, "UInt", nSize+1)
	Return sRole
}

AccGetStateText(nState) {
	nSize := DllCall("oleacc\GetStateText", "UInt", nState, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "UInt", nState, "str", sState, "UInt", nSize+1)
	Return sState
}

SaveAccPath(Path = "") {
	Static p
	If Path =
		Return p
	p := Path
}

AddSpace(c) {
	loop % c
		Tab .= "<span class='param';'>&#8595;    </span>"
	Return Tab
}

GetAccPath() { 
	if !Acc_GetPath(arr)
		Return 0  
	If !CompareAcc(Acc_Get("Object", arr[1].Path, 0, "ahk_id " arr[1].hWnd), Object(oPubObj.Acc.AccObj))
		Return ""
		
	for k, v in arr
	{ 
		tree .= AddSpace(k - 1) "<span><span name='MS:'>" v.Path "</span>" _DP  "<span name='MS:'>" v.Hwnd "</span>" 
			. _DP "<span name='MS:'>" v.WinClass "</span>" _DP  "<span name='MS:'>" v.ProcessName "</span></span><span name='MS:P'>     </span>"
			. _DP _BP1 " id='b_hwnd_flash' value='" v.Hwnd "'> flash " _BP2 "`n" 
	}
	tree := _T1 " id='P__Tree_Acc_Path'" _T1P "> ( Accessible path ) </span>" _T2 _PRE1 "<span>" tree "</span>" _PRE2
	SaveAccPath(tree)
	Return 1
}

Acc_GetPath(byref arr) {
    Static DesktopHwnd := DllCall("User32.dll\GetDesktopWindow", "ptr") 
	If oPubObj.Acc.CLOAKED
		Return 0
	Acc := Object(oPubObj.Acc.AccObj) 
	arr := []
	
	While Hwnd := Acc_WindowFromObject(Parent := Acc_Parent(Acc)) { 
		If (DesktopHwnd != Hwnd)
			t1 := GetEnumIndex(Acc)
		If t1 = -1
			Return arr := ""
		If (PrHwnd != "" && Hwnd != PrHwnd)
		{
			PrHwnd := Format("0x{:06X}", PrHwnd)
			WinGetClass, WinClass, ahk_id %PrHwnd%
			WinGet, ProcessName, ProcessName, ahk_id %PrHwnd%
			arr.InsertAt(1, {Hwnd: PrHwnd, Path: SubStr(t2, 1, -1), WinClass: WinClass, ProcessName: ProcessName})
		}
		if (t1 = "" || Hwnd = DesktopHwnd)
		   break
		t2 := t1 "." t2
		PrHwnd := Hwnd
		Acc := Parent 
	}
	Return arr.Count()
}

GetEnumIndex(Acc) {	
	If oPubObj.Acc.CLOAKED
		Return -1
	For Each, child in Acc_Children(Acc_Parent(Acc))
	{ 
		if CompareAcc(child, Acc) 
			return A_Index
	}
}

CompareAcc(Acc1, Acc2) { 
	if IsObject(Acc1) && IsObject(Acc2)
	&& (Acc_Location(Acc1) = Acc_Location(Acc2))
	&& (Acc1.accDefaultAction(0) = Acc2.accDefaultAction(0)) 	
	&& (Acc1.accDescription(0) = Acc2.accDescription(0)) 	
	&& (Acc1.accHelp(0) = Acc2.accHelp(0)) 	
	&& (Acc1.accKeyboardShortcut(0) = Acc.accKeyboardShortcut(0)) 
	
	&& (Acc1.accChildCount = Acc2.accChildCount) 
	&& (Acc1.accName(0) = Acc2.accName(0)) 	
	&& (Acc1.accRole(0) = Acc2.accRole(0)) 	
	&& (Acc1.accState(0) = Acc2.accState(0)) 
	&& (Acc1.accValue(0) = Acc2.accValue(0))
		return 1
}

Acc_Children(Acc) {
	if ComObjType(Acc, "Name") != "IAccessible"
		return
	else
	{
		cChildren := Acc.accChildCount, Children := [] 
		if DllCall("oleacc\AccessibleChildren"
		, "Ptr", ComObjValue(Acc)
		, "Int", 0, "Int", cChildren
		, "Ptr", VarSetCapacity(varChildren, cChildren * (8 + 2 * A_PtrSize), 0) * 0 + &varChildren
		, "Int*", cChildren) = 0 
		{
			Loop %cChildren%
				i := (A_Index - 1) * (A_PtrSize * 2 + 8) + 8
				, child := NumGet(varChildren, i)
				, Children.Insert(NumGet(varChildren, i - 8) = 9 ? Acc_Query(child) : child)
				, NumGet(varChildren, i - 8) = 9 ? ObjRelease(child) : ""
			return Children.MaxIndex() ? Children : ""
		}
	}
}
AccGetLocation(Acc, ChildId=0) {
	Static x := 0, y := 0, w := 0, h := 0
	try Acc.accLocation(ComObj(0x4003,&x), ComObj(0x4003,&y), ComObj(0x4003,&w), ComObj(0x4003,&h), ChildId)
	AccCoord[1]:=NumGet(x,0,"int"), AccCoord[2]:=NumGet(y,0,"int"), AccCoord[3]:=NumGet(w,0,"int"), AccCoord[4]:=NumGet(h,0,"int")
}
AccGetLocationToObj(Acc, ChildId=0) {
	Static x := 0, y := 0, w := 0, h := 0
	try Acc.accLocation(ComObj(0x4003,&x), ComObj(0x4003,&y), ComObj(0x4003,&w), ComObj(0x4003,&h), ChildId)
	Return {"x":NumGet(x,0,"int"),"y":NumGet(y,0,"int"),"w":NumGet(w,0,"int"),"h":NumGet(h,0,"int")}
} 
Acc_Location(Acc, ChildId=0) {
	Static x := 0, y := 0, w := 0, h := 0
	try Acc.accLocation(ComObj(0x4003,&x), ComObj(0x4003,&y), ComObj(0x4003,&w), ComObj(0x4003,&h), ChildId)
	return "x" NumGet(x, 0, "int") " y" NumGet(y, 0, "int") " w" NumGet(w, 0, "int") " h" NumGet(h, 0, "int")
}
Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "") {
	If DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32
		, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
		Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}
Acc_ObjectFromWindow(hWnd, idObject = 0) {
	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF
		, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81
		,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
		Return ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc) {
	If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc) ? ComObjValue(pacc) : pacc, "Ptr*", hWnd)=0
		Return	hWnd
} 
Acc_Parent(Acc) { 
	try parent := Acc.accParent 
	return parent ? Acc_Query(parent) : ""
}
Acc_Query(Acc) {
	try return ComObj(9, ComObjQuery(Acc, "{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
Acc_Error(p="") {
	static setting:=0
	return p=""?setting:setting:=p
}
Acc_Role(Acc, ChildId=0) {
	try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}
Acc_GetRoleText(nRole)
{
	nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
	Return	sRole
}
Acc_ChildrenByRole(Acc, Role) {
	if ComObjType(Acc,"Name")!="IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren% {
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
				if NumGet(varChildren,i-8)=9
					AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
				else
					Acc_Role(Acc, child)=Role?Children.Insert(child):
			}
			return Children.MaxIndex()?Children:, ErrorLevel:=0
		} else
			ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj :=   IsObject(WinTitle)? WinTitle
			:   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
	if ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	else {
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			try {
				if A_LoopField is digit
					Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in else-statement
				else
					RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
				if Not Children.HasKey(m2)
					throw
				AccObj := Children[m2]
			} catch {
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				if Acc_Error()
					throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				return   ; Acc_Error
			}
		Acc_Error(AccError)
		StringReplace, Cmd, Cmd, %A_Space%, , All
		properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
		try {
			if (Cmd = "Location")
				AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
			  , ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
			else if (Cmd = "Object")
				ret_val := AccObj
			else if Cmd in Role,State
				ret_val := Acc_%Cmd%(AccObj, ChildID+0)
			else if Cmd in ChildCount,Selection,Focus
				ret_val := AccObj["acc" Cmd]
			else
				ret_val := AccObj["acc" Cmd](ChildID+0)
		} catch {
			ErrorLevel := """" Cmd """ Cmd Not Implemented"
			if Acc_Error()
				throw Exception("Cmd Not Implemented", -1, Cmd)
			return
		}
		return ret_val, ErrorLevel:=0
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}

	; ___________________________ UIA _________________________________________________

class UIASub {
	__New() { 
		Try this.pUIA := ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
		Catch
			Return 0
	}
	__Get(member) { 
		If !this.__Properties(member, PropI, PropW)
			Return 0
		If (PropW = "RECT")
			Return (this.__Hr(DllCall(this.__Vt(PropI, this.pElement), "ptr", this.pElement
			, "ptr", &(rect, VarSetCapacity(rect, 16)))) ? this.__RectToObject(&rect) : 0), VarSetCapacity(rect, 0)
		If !this.__Hr(DllCall(this.__Vt(PropI, this.pElement), "ptr", this.pElement, "ptr*", out))
			Return 0
		Return PropW = "BSTR" ? StrGet(out) : out   
	}
	__RectToObject(prect) { 
		Return {left: NumGet(prect + 0, 0, "Int"), top: NumGet(prect + 0, 4, "Int"), right: NumGet(prect + 0, 8, "Int"), bottom: NumGet(prect + 0, 12, "Int")
			, width: NumGet(prect + 0, 8, "Int") - NumGet(prect + 0, 0, "Int") + 0, height: NumGet(prect + 0, 12, "Int") - NumGet(prect + 0, 4, "Int") + 0}
	}
	__Delete() {
		ObjRelease(this.pUIA)
	}
	__Vt(n, p) {
		Return NumGet(NumGet(p + 0, "ptr") + n * A_PtrSize, "ptr")
	}
	__Hr(hr) {
		;~ http://blogs.msdn.com/b/eldar/archive/2007/04/03/a-lot-of-hresult-codes.aspx
		; Static err:={0x8000FFFF:"Catastrophic failure.",0x80004001:"Not implemented.",0x8007000E:"Out of memory."
		; ,0x80070057:"One or more arguments are not valid.",0x80004002:"Interface not supported.",0x80004003:"Pointer not valid."
		; ,0x80070006:"Handle not valid.",0x80004004:"Operation aborted.",0x80004005:"Unspecified error.",0x80070005:"General access denied."
		; ,0x800401E5:"The object identified by this moniker could not be found.",0x80040201:"UIA_E_ELEMENTNOTAVAILABLE"
		; ,0x80040200:"UIA_E_ELEMENTNOTENABLED",0x80131509:"UIA_E_INVALIDOPERATION",0x80040202:"UIA_E_NOCLICKABLEPOINT"
		; ,0x80040204:"UIA_E_NOTSUPPORTED",0x80040203:"UIA_E_PROXYASSEMBLYNOTLOADED"} ; //not completed
		if hr && (hr &= 0xFFFFFFFF) {
			Return 0
		}
		Return !hr
	}
	__Properties(name, byref index, byref word) {
		Static properties1 := {CurrentProcessId: [20,"int"],CurrentControlType: [21,"CONTROLTYPEID"],CurrentLocalizedControlType: [22,"BSTR"]
		,CurrentName: [23,"BSTR"],CurrentAcceleratorKey: [24,"BSTR"],CurrentAccessKey: [25,"BSTR"],CurrentHasKeyboardFocus: [26,"BOOL"]
		,CurrentIsKeyboardFocusable: [27,"BOOL"],CurrentIsEnabled: [28,"BOOL"],CurrentAutomationId: [29,"BSTR"],CurrentClassName: [30,"BSTR"]
		,CurrentHelpText: [31,"BSTR"],CurrentCulture: [32,"int"],CurrentIsControlElement: [33,"BOOL"],CurrentIsContentElement: [34,"BOOL"]
		,CurrentIsPassword: [35,"BOOL"],CurrentNativeWindowHandle: [36,"UIA_HWND"],CurrentItemType: [37,"BSTR"],CurrentIsOffscreen: [38,"BOOL"]
		,CurrentOrientation: [39,"OrientationType"],CurrentFrameworkId: [40,"BSTR"],CurrentIsRequiredForForm: [41,"BOOL"],CurrentItemStatus: [42,"BSTR"]
		,CurrentBoundingRectangle: [43,"RECT"],CurrentLabeledBy: [44,"IUIAutomationElement"],CurrentAriaRole: [45,"BSTR"]
		,CurrentAriaProperties: [46,"BSTR"],CurrentIsDataValidForForm: [47,"BOOL"],CurrentControllerFor: [48,"IUIAutomationElementArray"]
		,CurrentDescribedBy: [49,"IUIAutomationElementArray"], CurrentFlowsTo: [50,"IUIAutomationElementArray"],CurrentProviderDescription: [51,"BSTR"]}
		
		Static properties2 := {CachedProcessId: [52,"int"],CachedControlType: [53,"CONTROLTYPEID"],CachedLocalizedControlType: [54,"BSTR"]
		,CachedName: [55,"BSTR"],CachedAcceleratorKey: [56,"BSTR"],CachedAccessKey: [57,"BSTR"],CachedHasKeyboardFocus: [58,"BOOL"]
		,CachedIsKeyboardFocusable: [59,"BOOL"],CachedIsEnabled: [60,"BOOL"],CachedAutomationId: [61,"BSTR"],CachedClassName: [62,"BSTR"]
		,CachedHelpText: [63,"BSTR"],CachedCulture: [64,"int"],CachedIsControlElement: [65,"BOOL"],CachedIsContentElement: [66,"BOOL"]
		,CachedIsPassword: [67,"BOOL"],CachedNativeWindowHandle: [68,"UIA_HWND"],CachedItemType: [69,"BSTR"],CachedIsOffscreen: [70,"BOOL"]
		,CachedOrientation: [71,"OrientationType"],CachedFrameworkId: [72,"BSTR"],CachedIsRequiredForForm: [73,"BOOL"]
		,CachedItemStatus: [74,"BSTR"],CachedBoundingRectangle: [75,"RECT"],CachedLabeledBy: [76,"IUIAutomationElement"]
		,CachedAriaRole: [77,"BSTR"],CachedAriaProperties: [78,"BSTR"],CachedIsDataValidForForm: [79,"BOOL"]
		,CachedControllerFor: [80,"IUIAutomationElementArray"],CachedDescribedBy: [81,"IUIAutomationElementArray"]
		,CachedFlowsTo: [82,"IUIAutomationElementArray"],CachedProviderDescription: [83,"BSTR"]}	; (,)(\d+),(.*?)(`r`n)			: [$2,"$3"],
 
		If properties1.HasKey(name)
			Return 1, index := properties1[name][1], word := properties1[name][2]
		If properties2.HasKey(name)
			Return 1, index := properties2[name][1], word := properties2[name][2] 
	}
	__ControlType(n) {
		Static name := {50000:"Button",50001:"Calendar",50002:"CheckBox",50003:"ComboBox",50004:"Edit",50005:"Hyperlink",50006:"Image"
		,50007:"ListItem",50008:"List",50009:"Menu",50010:"MenuBar",50011:"MenuItem",50012:"ProgressBar",50013:"RadioButton"
		,50014:"ScrollBar",50015:"Slider",50016:"Spinner",50017:"StatusBar",50018:"Tab",50019:"TabItem",50020:"Text",50021:"ToolBar"
		,50022:"ToolTip",50023:"Tree",50024:"TreeItem",50025:"Custom",50026:"Group",50027:"Thumb",50028:"DataGrid",50029:"DataItem"
		,50030:"Document",50031:"SplitButton",50032:"Window",50033:"Pane",50034:"Header",50035:"HeaderItem",50036:"Table",50037:"TitleBar",50038:"Separator"}
		Return name[n]
	}
	Release() {
		Return 1, this.pElement && ObjRelease(this.pElement), this.pElement := 0
	} 
	ElementFromPoint(x = "", y = "") {  
		Return this.pElement := this.__Hr(DllCall(this.__Vt(7, this.pUIA), "ptr", this.pUIA, "int64"
			, x = "" ? 0 * DllCall("GetCursorPos", "Int64*", pt) + pt : x & 0xFFFFFFFF | y << 32, "ptr*", pElement)) ? pElement : 0 
	}
	ElementFromHandle(hwnd) {
		Return this.pElement := this.__Hr(DllCall(this.__Vt(6, this.pUIA), "ptr", this.pUIA, "ptr", hwnd, "ptr*", pElement)) ? pElement : 0 
	}
}

	; ___________________________ Mode_Hotkey _________________________________________________

Mode_Hotkey:
	Try SetTimer, Loop_%ThisMode%, Off
	ZoomMsg(10, 1) 
	ShowMarker ? (HideAllMarkers()) : 0
	ColorButton("Button") 
	; oBody.createTextRange().execCommand("RemoveFormat")
	
	ScrollPos[ThisMode, 1] := oDivNew.scrollLeft
	ScrollPos[ThisMode, 2] := oDivNew.scrollTop
	
	If ThisMode != Hotkey
		HTML_%ThisMode% := oDivNew.innerHTML, prNotThisMode := 1
		
	ThisMode := "Hotkey"
	
	If A_GuiControl  ;;	WinActive("ahk_id" hGui)
		Hotkey_Hook(!isPaused)

	If (HTML_Hotkey = "")
		Write_HotkeyHTML({Mods:"Waiting pushed buttons..."}, 1)
	Else 
		Write_Hotkey(prNotThisMode)
	
	TitleText := (TitleTextP1 := "AhkSpy - Button") . TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui% 
	; WinActivate ahk_id %hGui%  
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	If isFindView
		FindNewText()		
	oDoc.getElementById("b_CASend").innerText := " send to " (oOther.ControlID ? "control" : "window")
	Return

Write_HotkeyHTML(K, scroll = 0) {
	Static PrHK1, PrHK2, Name

	Mods := K.Mods, KeyName := K.Name
	Prefix := K.Pref
	Hotkey := K.HK = "" ? K.TK : K.HK
	LRMods := K.LRMods, LRPref := TransformHTML(K.LRPref)
	ThisKey := K.TK, VKCode := K.VK, SCCode := K.SC
	If (K.NFP && Mods KeyName != "")
		NotPhysical	:= " " _DP "<span style='color:#" ColorDelimiter "'> Emulated</span>"

	HK1 := K.IsCode ? Hotkey : ThisKey
	HK2 := HK1 = PrHK1 ? PrHK2 : PrHK1, PrHK1 := HK1, PrHK2 := HK2
	HKComm1 := "    `;  """ (StrLen(Name := GetKeyName(HK2)) = 1 ? Format("{:U}", Name) : Name)
	HKComm2 := (StrLen(Name := GetKeyName(HK1)) = 1 ? Format("{:U}", Name) : Name) """"

	If K.IsCode
		Comment := "<span class='param' name='MS:SP'>    `;  """ KeyName """</span>"
	If (Hotkey != "")
		FComment := "<span class='param' name='MS:SP'>    `;  """ (K.HK = "" ? K.TK : Mods KeyName) """</span>"

	If (LRMods != "")
	{
		LRMStr := "<span name='MS:'>" LRMods KeyName "</span>"
		If (K.HK != "")
			LRPStr := "  " _DP "  <span><span name='MS:'>" LRPref Hotkey "::</span><span class='param' name='MS:SP'>    `;  """ LRMods KeyName """</span></span>"
	}
	If Prefix !=
		DUMods := (K.MLCtrl ? "{LCtrl Down}" : "") (K.MRCtrl ? "{RCtrl Down}" : "")
			. (K.MLShift ? "{LShift Down}" : "") (K.MRShift ? "{RShift Down}" : "")
			. (K.MLAlt ? "{LAlt Down}" : "") (K.MRAlt ? "{RAlt Down}" : "")
			. (K.MLWin ? "{LWin Down}" : "") (K.MRWin ? "{RWin Down}" : "") . "{" Hotkey "}"
			. (K.MLCtrl ? "{LCtrl Up}" : "") (K.MRCtrl ? "{RCtrl Up}" : "")
			. (K.MLShift ? "{LShift Up}" : "") (K.MRShift ? "{RShift Up}" : "")
			. (K.MLAlt ? "{LAlt Up}" : "") (K.MRAlt ? "{RAlt Up}" : "")
			. (K.MLWin ? "{LWin Up}" : "") (K.MRWin ? "{RWin Up}" : "")

	SendHotkey := Hotkey

	oOther.ControlSend := (DUMods = "" ? "{" SendHotkey "}" : DUMods)

	If (oOther.ControlID || oOther.MouseWinID)
		CASend := _DP  _BP1 " id='b_CASend'> send to " (oOther.ControlID ? "control" : "window") " " _BP2  
  
	VKCode_ := "0x" SubStr(VKCode, 3)
	SCCode_ := "0x" SubStr(SCCode, 3)

	If DecimalCode
		(VKCode_ += 0), SCCode_ += 0
	s_DecimalCode := DecimalCode ? "dec" : "hex"

	If (DUMods != "") 
		LRSend := "  " _DP "  <span><span name='MS:'>" SendMode  " <span name='MS:'>" DUMods "</span></span>" Comment "</span>"
	If SCCode !=
		ThisKeySC := "   " _DP "   <span name='MS:'>" VKCode "</span>   " _DP "   <span name='MS:'>" SCCode "</span>   "
		. _DP "   <span name='MS:' id='v_VKDHCode'>" VKCode_ "</span>   " _DP "   <span name='MS:' id='v_SCDHCode'>" SCCode_ "</span>"
	Else
		ThisKeySC := "   " _DP "   <span name='MS:' id='v_VKDHCode'>" VKCode_ "</span>"
	
	
	HTML_Hotkey := ""
	. _T1 "> ( Pushed buttons ) </span>" _BT1 " id='pause_button'> pause " _BT2  _DB  _BT1 " id='LButton_Hotkey'> LButton " _BT2  _T2 
	
	. _PRE1 "<br><span name='MS:'>" Mods  KeyName "</span>" NotPhysical "<br><br>" LRMStr "<br>" _PRE2 

	. _T1 "> ( Command syntax ) </span>" _BT1 " id='SendCode'> " SendCode " " _BT2  _DB  _BT1 " id='SendMode'> " SendModeStr " " _BT2  _T2 

	. _PRE1 "<br><span><span name='MS:'>" Prefix  Hotkey "::</span>" FComment "</span>" LRPStr 

	. "`n<span name='MS:P'>        </span>"

	. "`n<span><span name='MS:'>" SendMode " <span name='MS:'>" Prefix "{" SendHotkey "}</span></span>" Comment "</span>" LRSend 

	. "`n<span name='MS:P'>        </span>"

	. "`n<span><span name='MS:'>ControlSend, ahk_parent, <span name='MS:'>" oOther.ControlSend "</span>, WinTitle</span>" Comment . CASend "</span>"

	. "`n<span name='MS:P'>        </span>"
	
	. "`n<span><span name='MS:'>GetKeyState(""" SendHotkey """, ""P"")</span>" Comment "</span>   " 
		. _DP "   <span><span name='MS:'>KeyWait, " SendHotkey ", D T0.5</span>" Comment "</span>"
	
	. "`n<span name='MS:P'>        </span>"

	. "`n<span><span name='MS:'>" HK2 " & " HK1 "::</span><span class='param' name='MS:SP'>" HKComm1 " & " HKComm2 "</span></span>   " 
		. _DP "   <span><span name='MS:'>" HK2 "::" HK1 "</span><span class='param' name='MS:SP'>" HKComm1 " &#8250 &#8250 " HKComm2 "</span></span>"
	
	. "`n<span name='MS:P'>        </span>" _PRE2

	. _T1 "> ( Key ) </span>" _BT1 " id='numlock'> num " _BT2  _DB  _BT1 " id='locale_change'> locale " _BT2  
		. _DB  _BT1 " id='hook_reload'> hook reload " _BT2  _DB  _BT1 " id='b_DecimalCode'> " s_DecimalCode " " _BT2
		. _DB  _BT1 " id='hotkey_clip_cursor'> clip cursor " _BT2  _T2 
		
	. _PRE1 "<br><span name='MS:'>" ThisKey "</span>   " _DP "   <span name='MS:'>" VKCode  SCCode "</span>" ThisKeySC 
	
	. "`n`n" _PRE2

	. _T1 "> ( GetKeyName ) </span>" _BT1 " id='paste_keyname'> paste " _BT2  _T2 
	. "<br>"
	. "<span id='hotkeybox'><input id='edithotkey' value='" oDoc.getElementById("edithotkey").value "'><button id='keyname'> &#8250 </button>"
		. "<input id='editkeyname' value='" oDoc.getElementById("editkeyname").value "'></span>"
	. "<br>"
	. "<br>"
	. "<span id='vkname'>" GetVKCodeNameStr "</span><span id='scname'>" GetSCCodeNameStr "</span>"
	. _T0


	HTML_Hotkey = %HTML_Hotkey%
	( 
		<style> 
		pre {
			line-height: 1.1em;
		}
		#SendCode, #SendMode {
			text-align: center;
			position: absolute;
		}
		#SendCode {
			width: 3em; left: 12em;
		}
		#SendMode {
			width: 5em; left: 16em;
		}
		#hotkeybox {
			position: relative;
			white-space: pre;
			left: 5px;
			display: inline;
		}
		#edithotkey, #keyname, #editkeyname {
			font-size: 1.2em;
			text-align: center;
			border: 1px dotted;
			border-color: #%ColorFont%;
		}
		#keyname {
			position: relative;
			background-color: #%ColorParam%;
			top: 0px; left: 2px; width: 3em;
			width: 3em;
		}
		#editkeyname {
			position: relative;
			left: 4px; top: 0px;
		} 
		</style>
	) 
	Write_Hotkey(scroll)
}

Write_Hotkey(scroll = 0) {
	oDivOld := oDivWork%DivWorkIndex%
	DivWorkIndex := DivWorkIndex = 1 ? 2 : 1
	oDivNew := oDivWork%DivWorkIndex%  
	oDivNew.innerHTML := HTML_Hotkey  
	oDivNew.scrollTop := scroll ? ScrollPos[ThisMode, 2] : (ScrollPos[ThisMode, 2] := oDivOld.scrollTop)
		
	If oDivNew.scrollLeft
		oDivNew.scrollLeft := 0 

	oDivNew.style.zIndex := 1 
	oDivOld.style.zIndex := 0 
	
	oDivNew.style.visibility := "visible"
	oDivOld.innerHTML := ""
	Return 1
}

	; ___________________________ Hotkey Functions _________________________________________________

	;;  http://forum.script-coding.com/viewtopic.php?pid=69765#p69765

Hotkey_Init(Func, Options = "") {
	#HotkeyInterval 0
	Hotkey_Arr("Func", Func)
	Hotkey_Arr("Up", !!InStr(Options, "U"))
	Hotkey_MouseAndJoyInit(Options)
	Hotkey_SetHook()
	Hotkey_Arr("Hook") ? (Hotkey_Hook(0), Hotkey_Hook(1)) : 0
}

Hotkey_Main(In) {
	Static Prefix := {"LCtrl":"<^","LShift":"<+","LAlt":"<!","LWin":"<#"
	,"RCtrl":">^","RShift":">+","RAlt":">!","RWin":">#"}, K := {}, ModsOnly
	Local IsMod, sIsMod
	IsMod := In.IsMod
	If (In.Opt = "Down") {
		If (K["M" IsMod] != "")
			Return 1
		sIsMod := SubStr(IsMod, 2)
		K["M" sIsMod] := sIsMod "+", K["P" sIsMod] := SubStr(Prefix[IsMod], 2)
		K["M" IsMod] := IsMod "+", K["P" IsMod] := Prefix[IsMod]
	}
	Else If (In.Opt = "Up") {
		sIsMod := SubStr(IsMod, 2)
		K.ModUp := 1, K["M" IsMod] := K["P" IsMod] := ""
		If (K["ML" sIsMod] = "" && K["MR" sIsMod] = "")
			K["M" sIsMod] := K["P" sIsMod] := ""
		If (!Hotkey_Arr("Up") && K.HK != "")
			Return 1
	}
	Else If (In.Opt = "OnlyMods") {
		If !ModsOnly
			Return 0
		K.MCtrl := K.MShift := K.MAlt := K.MWin := K.Mods := ""
		K.PCtrl := K.PShift := K.PAlt := K.PWin := K.Pref := ""
		K.PRCtrl := K.PRShift := K.PRAlt := K.PRWin := ""
		K.PLCtrl := K.PLShift := K.PLAlt := K.PLWin := K.LRPref := ""
		K.MRCtrl := K.MRShift := K.MRAlt := K.MRWin := ""
		K.MLCtrl := K.MLShift := K.MLAlt := K.MLWin := K.LRMods := ""
		Func(Hotkey_Arr("Func")).Call(K)
		Return ModsOnly := 0
	}
	Else If (In.Opt = "GetMod")
		Return !!(K.PCtrl K.PShift K.PAlt K.PWin)
	Else If (In = "LButton")
		GoTo, Hotkey_PressLButton

	K.UP := In.UP, K.IsJM := 0, K.Time := In.Time, K.NFP := In.NFP, K.IsMod := IsMod
	K.Mods := K.MCtrl K.MShift K.MAlt K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLShift K.MRShift K.MLAlt K.MRAlt K.MLWin K.MRWin
	K.VK := "vk" In.VK, K.SC := "sc" In.SC, K.TK := GetKeyName(K.VK K.SC)
	K.TK := K.TK = "" ? K.VK K.SC : (StrLen(K.TK) = 1 ? Format("{:U}", K.TK) : K.TK)
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := K.IsCode := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.IsCode := (SendCode != "name" && StrLen(K.TK) = 1)  ;;	 && !Instr("1234567890-=", K.TK)
	, K.HK := K.IsCode ? K[SendCode] : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, K.Pref := K.PCtrl K.PShift K.PAlt K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLShift K.PRShift K.PLAlt K.PRAlt K.PLWin K.PRWin
	, ModsOnly := 0)
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1

Hotkey_PressLButton:
	ThisHotkey := "LButton"
	K.NFP := !GetKeyState(ThisHotkey, "P")
	GoTo, Hotkey_Drop

Hotkey_PressMouseRButton:
	If !WM_CONTEXTMENU() && !Hotkey_Hook(0)
		Return

Hotkey_PressJoy:
Hotkey_PressMouse:
	ThisHotkey := A_ThisHotkey
	K.NFP := !GetKeyState(ThisHotkey, "P")
Hotkey_Drop:
	K.Time := A_TickCount
	K.Mods := K.MCtrl K.MShift K.MAlt K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLShift K.MRShift K.MLAlt K.MRAlt K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PShift K.PAlt K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLShift K.PRShift K.PLAlt K.PRAlt K.PLWin K.PRWin
	K.HK := K.Name := K.TK := ThisHotkey, ModsOnly := K.UP := K.IsCode := 0, K.IsMod := K.SC := ""
	K.IsJM := A_ThisLabel = "Hotkey_PressJoy" ? 1 : 2
	K.VK := A_ThisLabel = "Hotkey_PressJoy" ? "" : Format("vk{:X}", GetKeyVK(ThisHotkey))
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1
}

#If Hotkey_Arr("Hook")
#If Hotkey_Arr("Hook") && GetKeyState("RButton", "P")
#If Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
#If

Hotkey_MouseAndJoyInit(Options) {
	Static MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
	Local S_FormatInteger, Option
	Option := InStr(Options, "M") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Loop, Parse, MouseKey, |
		Hotkey, %A_LoopField%, Hotkey_PressMouse, % Option
	Option := InStr(Options, "L") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook") && GetKeyState("RButton"`, "P")
	Hotkey, LButton, Hotkey_PressMouse, % Option
	Option := InStr(Options, "R") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Hotkey, RButton, Hotkey_PressMouseRButton, % Option
	Option := InStr(Options, "J") ? "On" : "Off"
	S_FormatInteger := A_FormatInteger
	SetFormat, IntegerFast, D
	Hotkey, IF, Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
	Loop, 128
		Hotkey % Ceil(A_Index / 32) "Joy" Mod(A_Index - 1, 32) + 1, Hotkey_PressJoy, % Option
	SetFormat, IntegerFast, %S_FormatInteger%
	Hotkey, IF
}

Hotkey_Hook(Val = 1) {
	Hotkey_Arr("Hook", Val)
	!Val && Hotkey_Main({Opt:"OnlyMods"})
}

Hotkey_Arr(P*) {
	Static Arr := {}
	Return P.MaxIndex() = 1 ? Arr[P[1]] : (Arr[P[1]] := P[2])
}

	;;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam) {
	Static Mods := {"A4":"LAlt","A5":"RAlt","A2":"LCtrl","A3":"RCtrl"
	,"A0":"LShift","A1":"RShift","5B":"LWin","5C":"RWin"}, oMem := []
	, HEAP_ZERO_MEMORY := 0x8, Size := 16, hHeap := DllCall("GetProcessHeap", Ptr)
	Local pHeap, Lp, Ext, VK, SC, SC1, SC2, IsMod, Time, NFP, KeyUp
	Critical

	If !Hotkey_Arr("Hook")
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	pHeap := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, Size, Ptr)
	DllCall("RtlMoveMemory", Ptr, pHeap, Ptr, lParam, Ptr, Size), oMem.Push(pHeap)
	SetTimer, Hotkey_HookProcWork, -10
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1

	Hotkey_HookProcWork:
		While (oMem[1] != "") {
			If Hotkey_Arr("Hook") {
				Lp := oMem[1]
				VK := Format("{:X}", NumGet(Lp + 0, "UInt"))
				Ext := NumGet(Lp + 0, 8, "UInt")
				SC1 := NumGet(Lp + 0, 4, "UInt")
				NFP := (Ext >> 4) & 1				;;  Не физическое нажатие
				KeyUp := Ext >> 7
				;; Time := NumGet(Lp + 12, "UInt")
				IsMod := Mods[VK]
				If !SC1
					SC2 := GetKeySC("vk" VK), SC := SC2 = "" ? "" : Format("{:X}", SC2)
				Else
					SC := Format("{:X}", (Ext & 1) << 8 | SC1)
				If !KeyUp
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Down", IsMod:IsMod, NFP:NFP, Time:Time, UP:0})
					: Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time, UP:0})
				Else
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Up", IsMod:IsMod, NFP:NFP, Time:Time, UP:1})
					: (Hotkey_Arr("Up") ? Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time, UP:1}) : 0)
			}
			DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, Lp)
			oMem.RemoveAt(1)
		}
		Return
}

Hotkey_SetHook(On = 1) {
	Static hHook
	If (On = 1 && !hHook)
		hHook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13   ;;  WH_KEYBOARD_LL
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else If !On
		DllCall("UnhookWindowsHookEx", "Ptr", hHook), hHook := "", Hotkey_Hook(0)
}

GetVKCodeName(id) {  
  ;;	https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
  ;;	http://www.kbdedit.com/manual/low_level_vk_list.html

	Static Start, VK_, Chr, Num, Undefined, Reserved, Unassigned, VK_Names
	
	If !Start
	{
		Start := 1 
		VK_ := {01:"VK_LBUTTON",02:"VK_RBUTTON",03:"VK_CANCEL",04:"VK_MBUTTON",05:"VK_XBUTTON1",06:"VK_XBUTTON2",08:"VK_BACK",09:"VK_TAB"
		,0C:"VK_CLEAR",0D:"VK_RETURN",10:"VK_SHIFT",11:"VK_CONTROL",12:"VK_MENU",13:"VK_PAUSE",14:"VK_CAPITAL"
		,15:"VK_KANA := VK_HANGEUL := VK_HANGUL := VK_HANGUEL"
		,17:"VK_JUNJA",18:"VK_FINAL",19:"VK_HANJA := VK_KANJI",1B:"VK_ESCAPE",1C:"VK_CONVERT",1D:"VK_NONCONVERT",1E:"VK_ACCEPT"
		,1F:"VK_MODECHANGE",20:"VK_SPACE",21:"VK_PRIOR",22:"VK_NEXT",23:"VK_END",24:"VK_HOME",25:"VK_LEFT",26:"VK_UP",27:"VK_RIGHT"
		,28:"VK_DOWN",29:"VK_SELECT",2A:"VK_PRINT",2B:"VK_EXECUTE",2C:"VK_SNAPSHOT",2D:"VK_INSERT",2E:"VK_DELETE",2F:"VK_HELP"
		,30:"VK_KEY_0",31:"VK_KEY_1",32:"VK_KEY_2",33:"VK_KEY_3",34:"VK_KEY_4",35:"VK_KEY_5",36:"VK_KEY_6",37:"VK_KEY_7",38:"VK_KEY_8"
		,39:"VK_KEY_9",41:"VK_KEY_A",42:"VK_KEY_B",43:"VK_KEY_C",44:"VK_KEY_D",45:"VK_KEY_E",46:"VK_KEY_F",47:"VK_KEY_G",48:"VK_KEY_H"
		,49:"VK_KEY_I",4A:"VK_KEY_J",4B:"VK_KEY_K",4C:"VK_KEY_L",4D:"VK_KEY_M",4E:"VK_KEY_N",4F:"VK_KEY_O",50:"VK_KEY_P",51:"VK_KEY_Q"
		,52:"VK_KEY_R",53:"VK_KEY_S",54:"VK_KEY_T",55:"VK_KEY_U",56:"VK_KEY_V",57:"VK_KEY_W",58:"VK_KEY_X",59:"VK_KEY_Y",5A:"VK_KEY_Z"
		,5B:"VK_LWIN",5C:"VK_RWIN",5D:"VK_APPS",5F:"VK_SLEEP",60:"VK_NUMPAD0",61:"VK_NUMPAD1",62:"VK_NUMPAD2",63:"VK_NUMPAD3"
		,64:"VK_NUMPAD4",65:"VK_NUMPAD5",66:"VK_NUMPAD6",67:"VK_NUMPAD7",68:"VK_NUMPAD8",69:"VK_NUMPAD9",6A:"VK_MULTIPLY"
		,6B:"VK_ADD",6C:"VK_SEPARATOR",6D:"VK_SUBTRACT",6E:"VK_DECIMAL",6F:"VK_DIVIDE",70:"VK_F1",71:"VK_F2",72:"VK_F3",73:"VK_F4"
		,74:"VK_F5",75:"VK_F6",76:"VK_F7",77:"VK_F8",78:"VK_F9",79:"VK_F10",7A:"VK_F11",7B:"VK_F12",7C:"VK_F13",7D:"VK_F14",7E:"VK_F15"
		,7F:"VK_F16",80:"VK_F17",81:"VK_F18",82:"VK_F19",83:"VK_F20",84:"VK_F21",85:"VK_F22",86:"VK_F23",87:"VK_F24"}
	
		VK__ := {90:"VK_NUMLOCK",91:"VK_SCROLL",92:"VK_OEM_FJ_JISHO := VK_OEM_NEC_EQUAL",93:"VK_OEM_FJ_MASSHOU",94:"VK_OEM_FJ_TOUROKU"
		,95:"VK_OEM_FJ_LOYA",96:"VK_OEM_FJ_ROYA",A0:"VK_LSHIFT",A1:"VK_RSHIFT",A2:"VK_LCONTROL",A3:"VK_RCONTROL",A4:"VK_LMENU"
		,A5:"VK_RMENU",A6:"VK_BROWSER_BACK",A7:"VK_BROWSER_FORWARD",A8:"VK_BROWSER_REFRESH",A9:"VK_BROWSER_STOP",AA:"VK_BROWSER_SEARCH"
		,AB:"VK_BROWSER_FAVORITES",AC:"VK_BROWSER_HOME",AD:"VK_VOLUME_MUTE",AE:"VK_VOLUME_DOWN",AF:"VK_VOLUME_UP",B0:"VK_MEDIA_NEXT_TRACK"
		,B1:"VK_MEDIA_PREV_TRACK",B2:"VK_MEDIA_STOP",B3:"VK_MEDIA_PLAY_PAUSE",B4:"VK_LAUNCH_MAIL",B5:"VK_LAUNCH_MEDIA_SELECT"
		,B6:"VK_LAUNCH_APP1",B7:"VK_LAUNCH_APP2",BA:"VK_OEM_1",BB:"VK_OEM_PLUS",BC:"VK_OEM_COMMA",BD:"VK_OEM_MINUS",BE:"VK_OEM_PERIOD"
		,BF:"VK_OEM_2",C0:"VK_OEM_3",C1:"VK_ABNT_C1",C2:"VK_ABNT_C2",DB:"VK_OEM_4",DC:"VK_OEM_5",DD:"VK_OEM_6",DE:"VK_OEM_7",DF:"VK_OEM_8"
		,E1:"VK_OEM_AX",E2:"VK_OEM_102",E3:"VK_ICO_HELP",E4:"VK_ICO_00",E5:"VK_PROCESSKEY",E6:"VK_ICO_CLEAR",E7:"VK_PACKET",E9:"VK_OEM_RESET"
		,EA:"VK_OEM_JUMP",EB:"VK_OEM_PA1",EC:"VK_OEM_PA2",ED:"VK_OEM_PA3",EE:"VK_OEM_WSCTRL",EF:"VK_OEM_CUSEL",F0:"VK_OEM_ATTN"
		,F1:"VK_OEM_FINISH",F2:"VK_OEM_COPY",F3:"VK_OEM_AUTO",F4:"VK_OEM_ENLW",F5:"VK_OEM_BACKTAB",F6:"VK_ATTN",F7:"VK_CRSEL"
		,F8:"VK_EXSEL",F9:"VK_EREOF",FA:"VK_PLAY",FB:"VK_ZOOM",FC:"VK_NONAME",FD:"VK_PA1",FE:"VK_OEM_CLEAR",FF:"VK__none_"}
	 
		for k, v in VK__
			VK_[k] := v
		VK_Names := {}
		for k, v in VK_
			for a, b in StrSplit(v, ":=", " ")
				VK_Names[b] := k
			 
		Undefined := "07|0E|0F|16|1A|3A|3B|3C|3D|3E|3F|40"
		Reserved := "0A|0B|5E|B8|B9|C3|C4|C5|C6|C7|C8|C9|CA|CB|CC|CD|CE|CF|D0|D1|D2|D3|D4|D5|D6|D7|E0"
		Unassigned := "88|89|8A|8B|8C|8D|8E|8F|97|98|99|9A|9B|9C|9D|9E|9F|D8|D9|DA|E8"
	}
	If (id ~= "i)^vk_") && VK_Names.HasKey(id)
		Return QVK(oDoc.getElementById("edithotkey").value := Format("{:U}", id), "0x" VK_Names[id])  ;;	vK_EreOF
		
	If VK := GetKeyVK(id)  
		id := Format("0x{:02X}", VK)
	Else If (id ~= "i)^vk")
		id := "0x" RegExReplace(id, "i)(^vk([0-9a-f]+)).*", "$2")  
		
	If !(InStr(id, "0x") && id > 0 && id < 256)
		Return   ;;	"Is not virtual key code" 
	id := Format("{:02X}", id) 
	If VK_[id]
		Return  QVK(VK_[id], "0x" id)  
	If InStr("|" Undefined "|", "|" id "|")
		Return QVK("0x" id " is Undefined", "", 0)
	If InStr("|" Reserved "|", "|" id "|")
		Return QVK("0x" id " is Reserved", "", 0)
	If InStr("|" Unassigned "|", "|" id "|")
		Return QVK("0x" id " is Unassigned", "", 0) 
} 

QVK(key, value, VK = 1) {
	Static S, T, Description1, Description2
	If !S && S := 1 
		T := _T1 "> ( GetKeyVK ) </span>" _T2 "<br>"
		, Description1 := "<span style='color: #" ColorParam "'>Virtual-key code symbolic names:  </span>"
		, Description2 := "<span style='color: #" ColorDelimiter "'>Virtual-key code symbolic names:  </span>"
	If VK
		Return T _PRE1 Description1 "<span><span name='MS:'>" key "</span><span class='param' name='MS:SP'> := " value "</span></span><br>" _PRE2
	Return T _PRE1 Description2 "<span class='QStyle2'>" key "</span><br>" _PRE2
}

GetScanCode(id) { 
	If SC := GetKeySC(id) 
		Return _T1 "> ( GetKeySC ) </span>" _T2 "<br>" _PRE1 "<span name='MS:'>" Format("0x{:03X}", SC) "</span><br>" _PRE2 
}


	; ___________________________ Menu Labels _________________________________________________

ShowSys(x, y) {
ShowSys:
	ZoomMsg(9, 1)
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 116, "Ptr", RegisterCallback("MenuCheck", "Fast"))
	Menu, Sys, Show, % x, % y
	ZoomMsg(9, 0)
	Return
}

MenuCheck()  {
	DllCall("KillTimer", "Ptr", A_ScriptHwnd, "Ptr", 1)
	If !WinExist("ahk_class #32768 ahk_pid " oOther.CurrentProcessId)
		Return
	If GetKeyState("RButton")
	{
		MouseGetPos, , , WinID
		Menu := MenuGetName(GetMenuForMenu(WinID))
		If Menu && (F := oMenu[Menu][oOther.ThisMenuItem := AccUnderMouse(WinID, Id).accName(Id)]) && (F ~= "^_")
		{
			;; If !(F ~= "^_") ;; Return DllCall("mouse_event", "UInt", 0x0002|0x0004)  
			;;	WinClose("ahk_class #32768 ahk_pid " oOther.CurrentProcessId), SetTimer(F, -1)
			oOther.MenuItemExist := 1
			If IsLabel(F)
				GoSub, % F
			Else
				%F%()
			oOther.MenuItemExist := 0
		}
		KeyWait, RButton
	}
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 16, "Ptr", RegisterCallback("MenuCheck", "Fast"))
}

GetMenuForMenu(hWnd) {
	SendMessage, 0x1E1, 0, 0, , ahk_id %hWnd%	;;  MN_GETHMENU
	hMenu := ErrorLevel
	If (hMenu + 0)
		Return hMenu
}

AccUnderMouse(WinID, ByRef child) {
	Static h
	If Not h
		h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", 0 * DllCall("GetCursorPos", "Int64*", pt) + pt, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild, 8 + 2 * A_PtrSize, 0) * 0 + &varChild) = 0
	Acc := ComObjEnwrap(9, pacc, 1)
	If IsObject(Acc)
		Return Acc, child := NumGet(varChild, 8, "UInt")
}

MaxHeightStrToNum()  {
	Return Round(A_ScreenHeight / SubStr(PreMaxHeightStr, 5))
}

_DarkTheme: 
	IniWrite(DarkTheme := !DarkTheme, "DarkTheme")
	Menu, View, % DarkTheme ? "Check" : "UnCheck"
	, % oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Return
	
_ActiveScriptAllowChange: 
	IniWrite(ActiveScriptAllowChange := !ActiveScriptAllowChange, "ActiveScriptAllowChange")
	Menu, Script, % ActiveScriptAllowChange ? "Check" : "UnCheck"
	, % oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Return
	
_FontBold: 
	IniWrite(FontBold := !FontBold, "FontBold")
	Menu, View, % FontBold ? "Check" : "UnCheck"
	, % oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Return

_ViewStrPos:
	IniWrite(ViewStrPos := !ViewStrPos, "ViewStrPos")
	Menu, View, % ViewStrPos ? "Check" : "UnCheck"
	, % oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Return

_MenuOverflowLabel:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	PreOverflowHide := ThisMenuItem = "Switch off" ? 0 : 1
	IniWrite(ThisMenuItem, "MaxHeightOverFlow")
	for k, v in ["Switch off","1 / 1","1 / 2","1 / 3","1 / 4","1 / 5","1 / 6","1 / 8","1 / 10","1 / 15"]
		Menu, Overflow, UnCheck, % v
	Menu, Overflow, Check, % PreMaxHeightStr := ThisMenuItem
	PreMaxHeight := MaxHeightStrToNum()
	_PreOverflowHideCSS := ".lpre {max-width: 99`%; max-height: " PreMaxHeight "px; overflow: auto; border: 1px solid #" ColorPreOverflowHide ";}"
	ChangeCSS("css_PreOverflowHide", PreOverflowHide ? _PreOverflowHideCSS : "")
	AnchorFitScroll()
	Return

_Sys_Backlight:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Menu, Sys, UnCheck, % BLGroup[StateLight]
	Menu, Sys, Check, % ThisMenuItem
	IniWrite((StateLight := InArr(ThisMenuItem, BLGroup)), "StateLight")
	Return

_MemoryAnchor:
	IniWrite(MemoryAnchor := !MemoryAnchor, "MemoryAnchor")
	If MemoryAnchor
		IniWrite(oOther.anchor["Win_text"], "Win_Anchor")
		, IniWrite(oOther.anchor["Control_text"], "Control_Anchor")
	Menu, Script, % MemoryAnchor ? "Check" : "UnCheck", Remember anchor
	Return

_AnchorFullScroll:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(AnchorFullScroll := !AnchorFullScroll, "AnchorFullScroll") 
	Menu, View, % AnchorFullScroll ? "Check" : "UnCheck", % ThisMenuItem 
	
	If AnchorFullScroll
		AnchorScroll()
	Else 
		oJScript.QS(oDivNew, "#id_T0").style.height := 0 "px" 
	oDivNew.scrollTop := oDivNew.scrollTop + oDoc.getElementById("anchor").getBoundingClientRect().top - 6
	Return

_DynamicControlPath:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(DynamicControlPath := !DynamicControlPath, "DynamicControlPath")
	Menu, View, % DynamicControlPath ? "Check" : "UnCheck", % ThisMenuItem
	Return

_DynamicAccPath:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(DynamicAccPath := !DynamicAccPath, "DynamicAccPath")
	Menu, View, % DynamicAccPath ? "Check" : "UnCheck", % ThisMenuItem
	Return

_UseUIA:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(UseUIA := !UseUIA, "UseUIA")
	If UseUIA && !IsObject(exUIASub)
		exUIASub := new UIASub
	Menu, View, % UseUIA ? "Check" : "UnCheck", % ThisMenuItem
	Return
	
_UIAAlienDetect:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(UIAAlienDetect := !UIAAlienDetect, "UIAAlienDetect") 
	Menu, View, % UIAAlienDetect ? "Check" : "UnCheck", % ThisMenuItem
	Return

_SelStartMode:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	for k, v in ["Window","Control","Button","Last Mode"]
		Menu, Startmode, UnCheck, % v
	IniWrite({"Window":"Win","Control":"Control","Button":"Hotkey","Last Mode":"LastMode"}[ThisMenuItem], "StartMode")
	LastModeSave := (ThisMenuItem = "Last Mode")
	Menu, Startmode, Check, % ThisMenuItem
	Return

_OnlyShiftTab:
	IniWrite(OnlyShiftTab := !OnlyShiftTab, "OnlyShiftTab")
	Menu, Sys, % (OnlyShiftTab ? "Check" : "UnCheck"), Spot only Shift+Tab
	ZoomMsg(12, OnlyShiftTab)
	If !OnlyShiftTab
		Try SetTimer, Loop_%ThisMode%, -100
	If OnlyShiftTab && ActiveNoPause
		GoSub _Active_No_Pause
	Return

_Active_No_Pause:
	ActiveNoPause := IniWrite(!ActiveNoPause, "ActiveNoPause")
	Menu, Sys, % (ActiveNoPause ? "Check" : "UnCheck"), Work with the active window
	ZoomMsg(6, ActiveNoPause)
	If OnlyShiftTab && ActiveNoPause
		GoSub _OnlyShiftTab
	Return

_Suspend:
	isAhkSpy := !isAhkSpy
	Menu, Sys, % !isAhkSpy ? "Check" : "UnCheck", Suspend hotkeys
	ZoomMsg(8, !isAhkSpy)
	Return

_CheckUpdate:
	SetTimer, UpdateAhkSpy, Off
	SetTimer, Upd_Verifi, Off
	StateUpdate := IniWrite(!StateUpdate, "StateUpdate")
	Menu, Sys, % (StateUpdate ? "Check" : "UnCheck"), Check updates
	If StateUpdate
		SetTimer, UpdateAhkSpy, -1 
	Return
	
_CheckAhkNewVersion:
	SetTimer, CheckAhkNewVersion, Off
	SetTimer, lCheckAhkNewVersion, Off
	CheckAhkNewVersion := IniWrite(!CheckAhkNewVersion, "CheckAhkNewVersion")
	Menu, Help, % (CheckAhkNewVersion ? "Check" : "UnCheck"), Check updates AutoHotkey
	If CheckAhkNewVersion
		SetTimer, CheckAhkNewVersion, -1 
	Return


_Sys_Acclight:
	StateLightAcc := IniWrite(!StateLightAcc, "StateLightAcc"), HideAccMarker()
	Menu, Sys, % (StateLightAcc ? "Check" : "UnCheck"), Acc object backlight
	Return

_Sys_WClight:
	StateLightMarker := IniWrite(!StateLightMarker, "StateLightMarker"), HideMarker()
	Menu, Sys, % (StateLightMarker ? "Check" : "UnCheck"), Window or control backlight
	Return

_Spot_Together:
	StateAllwaysSpot := IniWrite(!StateAllwaysSpot, "AllwaysSpot")
	Menu, Sys, % (StateAllwaysSpot ? "Check" : "UnCheck"), Spot together (low speed)
	Return

_MemoryPos:
	IniWrite(MemoryPos := !MemoryPos, "MemoryPos")
	Menu, Script, % MemoryPos ? "Check" : "UnCheck", Remember position
	SavePos()
	Return

_MemorySize:
	IniWrite(MemorySize := !MemorySize, "MemorySize")
	Menu, Script, % MemorySize ? "Check" : "UnCheck", Remember size
	SaveSize()
	Return

_MemoryFontSize:
	IniWrite(MemoryFontSize := !MemoryFontSize, "MemoryFontSize")
	Menu, Script, % MemoryFontSize ? "Check" : "UnCheck", Remember font size
	If MemoryFontSize
		IniWrite(FontSize, "FontSize")
	Return

_MemoryZoomSize:
	IniWrite(MemoryZoomSize := !MemoryZoomSize, "MemoryZoomSize")
	Menu, Script, % MemoryZoomSize ? "Check" : "UnCheck", Remember zoom size
	ZoomMsg(4, MemoryZoomSize)
	Return
	
_MinimizeEscape:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(MinimizeEscape := !MinimizeEscape, "MinimizeEscape")
	Menu, Script, % MinimizeEscape ? "Check" : "UnCheck", %ThisMenuItem%
	Return

_MoveTitles:
	IniWrite(MoveTitles := !MoveTitles, "MoveTitles")
	Menu, View, % MoveTitles ? "Check" : "UnCheck", Moving titles
	if oJScript.MoveTitles := MoveTitles
		oJScript.shift(0)
	else
		oDivNew.scrollLeft := 0, oJScript.conleft30()
	Return
	
_MarkerInvertFrame:
	IniWrite(MarkerInvertFrame := !MarkerInvertFrame, "MarkerInvertFrame")
	Menu, View, % MarkerInvertFrame ? "Check" : "UnCheck", Flash edge
	WinSet, Region, , ahk_id %hMarkerGui%
	Return

_MemoryStateZoom:
	IniWrite(MemoryStateZoom := !MemoryStateZoom, "MemoryStateZoom")
	Menu, Script, % MemoryStateZoom ? "Check" : "UnCheck", Remember state zoom
	IniWrite(oOther.ZoomShow, "ZoomShow")
	Return

_WordWrap:
	IniWrite(WordWrap := !WordWrap, "WordWrap")
	Menu, View, % WordWrap ? "Check" : "UnCheck", Word wrap
	If WordWrap
		oDivNew.scrollLeft := 0
	oJScript.WordWrap := WordWrap
	ChangeCSS("css_Body", WordWrap ? _BodyWrapCSS : "")
	Return

Sys_Help:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	If ThisMenuItem = AutoHotKey official help online
		RunPath("http://ahkscript.org/docs/AutoHotkey.htm")
	Else If ThisMenuItem = AutoHotKey russian help online
		RunPath("http://www.script-coding.com/AutoHotkeyTranslation.html")
	Else If ThisMenuItem = About
		RunPath("http://forum.script-coding.com/viewtopic.php?pid=72459#p72459")
	Else If ThisMenuItem = About english
		RunPath("https://www.autohotkey.com/boards/viewtopic.php?f=6&t=52872") 
	Return

LaunchHelp:
	If !FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
		Return
	IfWinNotExist AutoHotkey Help ahk_class HH Parent ahk_exe hh.exe
		Run % SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm"
	WinActivate
	Minimize()
	Return

DefaultSize:
	If FullScreenMode
	{
		FullScreenMode()
		Gui, 1: Restore
		Sleep 200
	}
	Gui, 1: Show, % "NA w" widthTB "h" HeightStart
	ZoomMsg(5)
	If !MemoryFontSize
		oDoc.getElementById("pre").style.fontSize := FontSize := 15
	Return

Reload:
	Reload
	Return

Help_OpenUserDir:
	RunPath(Path_User)
	Return

Help_OpenScriptDir:
	SelectFilePath(A_ScriptFullPath)
	Minimize()
	Return

	; ___________________________ Functions _________________________________________________

WM_ACTIVATE(wp, lp) {
	Critical
	If isConfirm
		Return
	If ((wp & 0xFFFF = 0) && lp != hGui)  ;;	Deactivated
	{
		ZoomMsg(7, 0)
		If Hotkey_Arr("Hook")
			Hotkey_Hook(0)
	}
	Else If (wp & 0xFFFF != 0 && WinActive("ahk_id" hGui)) ;;	Activated
	{
		ZoomMsg(7, 1)
		If (ThisMode = "Hotkey" && !isPaused)
			Hotkey_Hook(1)
		If !ActiveNoPause
			HideAllMarkers(), CheckHideMarker()
	}
}

WM_WINDOWPOSCHANGED(Wp, Lp) {
	Static PtrAdd := A_PtrSize = 8 ? 8 : 0
	; Critical
	If (NumGet(Lp + 0, 0, "Ptr") != hGui) || Sleep = 1
		Return  
		
	If oOther.ZoomShow
	{
		x := NumGet(Lp + 0, 8 + PtrAdd, "UInt")
		y := NumGet(Lp + 0, 12 + PtrAdd, "UInt")
		w := NumGet(Lp + 0, 16 + PtrAdd, "UInt")
		
		hDWP := DllCall("BeginDeferWindowPos", "Int", 2)
		
		; hDWP := DllCall("DeferWindowPos"
		; , "Ptr", hDWP, "Ptr", hGui, "UInt", -1  ;;	for +AlwaysOnTop
		; , "Int", 0, "Int", 0, "Int", 0, "Int", 0
		; , "UInt", 0x0003)    ;;  SWP_NOMOVE := 0x0002 | SWP_NOSIZE := 0x0001
		
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", oOther.hZoom, "UInt", 0
		, "Int", x + w, "Int", y, "Int", 0, "Int", 0
		, "UInt", 0x0011)    ;; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
		
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", oOther.hZoomLW, "UInt", 0
		, "Int", x + w + 1, "Int", y + 46, "Int", 0, "Int", 0
		, "UInt", 0x0211)    ;; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE | SWP_NOOWNERZORDER := 0x0200
		
		DllCall("EndDeferWindowPos", "Ptr", hDWP)
	}
	If MemoryPos
		SetTimer, SavePos, -400  
} 

GuiSize:
	If A_Gui != 1
		Return
	If A_EventInfo = 1
		ZoomMsg(11, 1)
	Sleep := A_EventInfo  ;;	= 1 minimize
	If A_EventInfo != 1
	{
		ControlsMove(A_GuiWidth, A_GuiHeight)
		If MemorySize
			SetTimer, SaveSize, -400
	}
	Else
		HideAllMarkers(), CheckHideMarker()
	Try SetTimer, Loop_%ThisMode%, % A_EventInfo = 1 || isPaused ? "Off" : "On"
	Return

Minimize() {
	Sleep := 1
	Gui, 1: Minimize
}

GetNameFile(Folder, Name = "Myfile ", Ext = "txt", i = 1) {
	While FileExist(Folder "\" Name "(" i ")." Ext)
		i := A_Index
	Return Folder "\" Name "(" i ")." Ext
}

TimerFunc(hFunc, Time) {
	Try SetTimer, % hFunc, % Time
}

Exit() {
	Gui, %hGui%:, Hide
	Hotkey_SetHook(0)
	If LastModeSave
		IniWrite(ThisMode, "LastMode")  
	oDoc := ""
	DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDCMarkerInvert)
	ExitApp
}

GuiClose() {
	If MinimizeEscape && GetKeyState("Esc", "P")
		Return 1, Minimize()  
	ExitApp
}

CheckAhkVersion:
	If A_AhkVersion < 1.1.33.02
	{
		MsgBox Requires AutoHotkey_L version 1.1.33.02+
		RunPath("http://ahkscript.org/download/")
		ExitApp
	}
	Return

ChangeMode() {
	Try SetTimer, Loop_%ThisMode%, Off
	HideAllMarkers(), MS_Cancel()
	GoSub % "Mode_" (ThisMode = "Control" ? "Win" : "Control")
}
	
WM_NCLBUTTONDOWN(wp) {
	Static HTMINBUTTON := 8

	If (wp = HTMINBUTTON)
	{
		SetTimer, Minimize, -10
		Return 0
	}
} 

TransParent(v) {
	oOther.TransParent := !v
	WinSet, TransParent, % v, % "ahk_id" hGui
	WinSet, TransParent, % v, % "ahk_id" oOther.hZoom
	If !v
		WinHide, % "ahk_id" oOther.hZoomLW
	Else
		WinShow, % "ahk_id" oOther.hZoomLW
} 
		
WM_RBUTTONDOWN(wp, lp, msg, hwnd, tp = 0) { 
	If (hwnd = hColorProgress && !ActiveNoPause && !isPaused && ThisMode != "Hotkey")
	{
		If GetKeyState("Shift")
			TransParent(0)
		ToolTip("Spot", 300)
		ZoomMsg(7, 0) 
		ActiveNoPause := 1
		If OnlyShiftTab 
			OnlyShiftTab := 0, oOther.OnlyShiftTabReset := 1, ZoomMsg(12, 0)
		SetTimer, Loop_%ThisMode%, -1 
		SetTimer, RButton_Up_Wait, -1
	}
} 

RButton_Up_Wait:
	If GetKeyState("RButton", "P") || GetKeyState("MButton", "P") {
		SetTimer, %A_ThisLabel%, -30
		Return
	}
	ActiveNoPause := 0 
	If oOther.OnlyShiftTabReset
		OnlyShiftTab := 1, oOther.OnlyShiftTabReset := 0, ZoomMsg(12, 1)
	If OnlyShiftTab
		SetTimer, Loop_%ThisMode%, Off 
	SetTimer, ShiftUpHide, -300
	Sleep 100
	If GetKeyState("LShift", "P")
	{ 
		ZoomMsg(2, 1)
		HideAllMarkers()
		oObjActive.Magnify.Call(2)
		oObjActive.Redraw.Call()  
	}   
	If oOther.TransParent
		TransParent("Off")  
	If !OnlyShiftTab  
	{
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc
	}
	ToolTip("Stop", 300)
	ZoomMsg(2, 0)
	Return

Mod_Up_Wait_And_TransParent:
	If GetKeyState("LShift", "P") || GetKeyState("LControl", "P") {
		SetTimer, %A_ThisLabel%, -50
		Return
	}
	Sleep := 1
	; ZoomMsg(3) 
	If oOther.OnlyShiftTabReset
		OnlyShiftTab := 1, oOther.OnlyShiftTabReset := 0, ZoomMsg(12, 1)
	HideAllMarkers()
	ZoomMsg(2, 1)
	oObjActive.Magnify.Call(2)
	oObjActive.Redraw.Call()   
	TransParent("Off")
	If !OnlyShiftTab || oOther.OnlyShiftTabReset
	{
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc 
	} 
	ToolTip("Stop", 300)  
	ZoomMsg(2, 0)
	Sleep := 0
	Return


ColorButton(name) {
	for k, v in ["Window", "Control", "Button"]
		ColorProgress("Color_" v, v = name ? ColorSelModeButton : ColorBgModeButton) 
}

ColorProgress(name, color) {  
	GuiControl, % "TB: +Background" color, %name% 
	Gui, TB: Color, %ColorBg%
}

WM_LBUTTONDOWN(wp, lp, msg, hwnd) { 
	If (A_GuiControl = "Color_Window")   
		Gosub Mode_Win
	Else If (A_GuiControl = "Color_Control")  
		Gosub Mode_Control
	Else If (A_GuiControl = "Color_Button")  
		Gosub Mode_Hotkey
	Else If (A_GuiControl = "Color_Zoom")  
		AhkSpyZoomShow() 
	Else If (hwnd = hFindGui)
	{
		MouseGetPos, , , , hControl, 2
		If (hControl = hFindAllText)
			SetTimer, FindAll, -250 
	}
	Else If A_GuiControl = ColorProgress
	{
		If ThisMode = Hotkey
			oDoc.execCommand("Paste"), ToolTip("Paste", 300)
		Else
		{ 
			SendInput {LAlt Down}{Escape}{LAlt Up}
			ToolTip("Alt+Escape", 300)
			ZoomMsg(7, 0)
			If (OnlyShiftTab && !isPaused)
			{
				ToolTip("Spot", 300) 
				OnlyShiftTab := 0
				ZoomMsg(12, 0)
				SetTimer, Loop_%ThisMode%, -1
				SetTimer, OnlyShiftTab_LButton_Up_Wait, -1
			}
		}
	}
}
 
OnlyShiftTab_LButton_Up_Wait:
	KeyWait, LButton 
	OnlyShiftTab := 1
	ZoomMsg(12, 1)
	SetTimer, Loop_%ThisMode%, Off
	SetTimer, ShiftUpHide, -300
	Sleep 100
	ToolTip("Stop", 300) 
	return

   ;;  http://forum.script-coding.com/viewtopic.php?pid=131490#p131490
/*
ChildFromPath(str, hwnd) 
{
	Static GW_HWNDNEXT := 2, GW_CHILD := 5
	hwnd := DllCall("GetWindow", "Ptr", hwnd, UInt, GW_CHILD, "Ptr")
	arr := StrSplit(str, "."), off := 1, i := 1
	Loop 
	{
		If (i = arr[off])
		{
			If (off = arr.Count())
				return hwnd
			hwnd := DllCall("GetWindow", "Ptr", hwnd, UInt, GW_CHILD, "Ptr"), ++off, i := 1 
		}
		Else If (++i) && !(hwnd := DllCall("GetWindow", "Ptr", hwnd, UInt, GW_HWNDNEXT, "Ptr"))
			return   
	}
} 
*/
ChildToPath(hwnd) {
	If !WinExist("ahk_id" hwnd)
		Return 0
	arr := []
 	_ChildToPath(hwnd, arr) 
	for k, v in arr
	{  
		Hwnd := Format("0x{:06X}", v.Hwnd)
		WinGetClass, WinClass, ahk_id %Hwnd%
		WinGet, ProcessName, ProcessName, ahk_id %Hwnd%
		tree .= AddSpace2(k - 1) "<span><span name='MS:'>" v.Path "</span>" _DP  "<span name='MS:'>" Hwnd "</span>" 
			. _DP "<span name='MS:'>" WinClass "</span>" _DP  "<span name='MS:'>" ProcessName "</span></span><span name='MS:P'>     </span>"
			. _DP _BP1 " id='b_hwnd_flash' value='" Hwnd "'> flash " _BP2 "`n"
	} 
	tree := _T1 " id='P__Tree_Control_Path'" _T1P "> ( Control path ) </span>" _T2 _PRE1 "<span>" tree "</span>" _PRE2 
	SaveChildPath(tree)
	Return 1
}

_ChildToPath(hwnd, arr, i = 1) {
	Static GA_PARENT := 1, GA_ROOT := 2, GW_HWNDPREV := 3
	Static DesktopHwnd := DllCall("User32.dll\GetDesktopWindow", "ptr") 
	While hPrev := DllCall("GetWindow", "Ptr", hwnd, UInt, GW_HWNDPREV, "Ptr")
		++i, hwnd := hPrev
	   ;;  DllCall("GetParent", "Ptr", hwnd)
	hParent := DllCall("GetAncestor", "Ptr", hwnd, Uint, GA_PARENT)
	if !hParent || (hParent = DesktopHwnd)
		return
	arr.InsertAt(1, {Hwnd:hParent,Path: RTrim(i "." arr[1].Path, ".")})
	return _ChildToPath(hParent, arr, 1)
}

AddSpace2(c) {
	loop % c
		Tab .= "<span class='param';'>&#8595;  </span>"
	Return Tab
}
SaveChildPath(Path = "") {
	Static p
	If Path =
		Return p
	p := Path
}

ActivateUnderMouse() {
	MouseGetPos, , , WinID
 	WinActivate, ahk_id %WinID%
}

MouseGetPosScreen(ByRef x, ByRef y) {
	VarSetCapacity(POINT, 8, 0)
	NumPut(x, &POINT, 0, "Int")
	NumPut(y, &POINT, 4, "Int")
	DllCall("GetCursorPos", "Ptr", &POINT)
	x := NumGet(POINT, 0, "Int"), y := NumGet(POINT, 4, "Int")
}

WM_CONTEXTMENU() {
	MouseGetPos, , , wid, cid, 2
	If (hColorProgress = cid) {
		Gosub, PausedScript
		ToolTip("Pause", 300)
		Return 0
	}
	Else If (cid != hActiveX && wid = hGui) {
		SetTimer, ShowSys, -1
		Return 0
	}
	Return 1
}

IsTextArea() {
	MouseGetPos, , , , cid, 3
	Return (DllCall("GetParent", Ptr, cid) = hActiveX)
}

ControlsMove(Width, Height) { 
	hDWP := DllCall("BeginDeferWindowPos", "Int", isFindView ? 3 : 2)
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", hTBGui, "UInt", 0
	, "Int", (Width - widthTB) // 2.2, "Int", 0, "Int", 0, "Int", 0
	, "UInt", 0x0011)    ;; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", hActiveX, "UInt", 0
	, "Int", 0, "Int", HeigtButton
	, "Int", Width, "Int", Height - HeigtButton - (isFindView ? 28 : 0)
	, "UInt", 0x0010)    ;; 0x0010 := SWP_NOACTIVATE
	If isFindView
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", hFindGui, "UInt", 0
		, "Int", (Width - widthTB) // 2.2, "Int", (Height - (Height < HeigtButton * 2 ? -2 : 27))
		, "Int", 0, "Int", 0
		, "UInt", 0x0011)    ;; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
	
	SetTimer, AnchorFitScroll, -500 
}

ZoomSpot() {
	If (!isPaused && Sleep != 1 && WinActive("ahk_id" hGui))
		(ThisMode = "Control" ? (Spot_Control() (StateAllwaysSpot ? Spot_Win() : 0) Write_Control()) : (Spot_Win() (StateAllwaysSpot ? Spot_Control() : 0) Write_Win()))
}

MsgZoom(wParam, lParam) {  ;;	получает
	If (wParam = 1)  ;;	шаг мыши
		SetTimer, ZoomSpot, -1
	Else If (wParam = 2)  ;;	ZoomShow
		oOther.ZoomShow := lParam, (MemoryStateZoom && IniWrite(lParam, "ZoomShow"))
	Else If (wParam = 0)  ;;	хэндл окна
		oOther.hZoom := lParam
	Else If (wParam = 3)  ;;	хэндл окна LW
		oOther.hZoomLW := lParam
}	

WM_COPYDATA(wParam, lParam) { 
    CopyOfData := StrGet(NumGet(lParam + 2*A_PtrSize))   
	If (wParam = 1 && ThisMode = "Control") {
		arr := StrSplit(CopyOfData, "`n") 
		BGR := arr[1], offX := arr[2], offY := arr[3]
		ColorRGB := Format("0x{:06X}", (BGR & 0xFF) << 16 | (BGR & 0xFF00) | (BGR >> 16))
		ColorBGR := Format("0x{:06X}", BGR)
		oDoc.getElementById("ColorRGB").innerText := ColorRGB
		oDoc.getElementById("sColorRGB").innerText := SubStr(ColorRGB, 3)  
		oDoc.getElementById("ColorBGR").innerText := ColorBGR
		oDoc.getElementById("sColorBGR").innerText := SubStr(ColorBGR, 3)  
		sInvert_RGB := Format("{:06X}", ColorRGB ^ 0xFFFFFF)    
		oDoc.getElementById("sInvert_RGB0").innerText := "0x" sInvert_RGB
		oDoc.getElementById("sInvert_RGB").innerText := sInvert_RGB 
		oDoc.getElementById("RenderInvert_RGB").style.backgroundColor := "#" sInvert_RGB
		GuiControl, TB: -Redraw, ColorProgress
		GuiControl, % "TB: +c" SubStr(ColorRGB, 3), ColorProgress
		GuiControl, TB: +Redraw, ColorProgress  
		
		oDoc.getElementById("coord_screen").innerText := "x" (osCoords.MXS + offX) " y" (osCoords.MYS + offY)
		oDoc.getElementById("coord_win").innerText := "x" (osCoords.RWinX + offX) " y" (osCoords.RWinY + offY)
		oDoc.getElementById("coord_client").innerText := "x" (osCoords.MXC + offX) " y" (osCoords.MYC + offY)
		oDoc.getElementById("coord_awin").innerText := "x" (osCoords.MXWA + offX) " y" (osCoords.MYWA + offY)
		oDoc.getElementById("coord_rwin").innerText := Round((osCoords.RWinX + offX) / osCoords.WinW, 4) ", " Round((osCoords.RWinY + offY) / osCoords.WinH, 4)
		oDoc.getElementById("coord_rclient").innerText := Round((osCoords.MXC + offX) / osCoords.caW, 4) ", " Round((osCoords.MYC + offY) / osCoords.caH, 4)
	}
    return true
}

ZoomMsg(wParam = -1, lParam = -1) {  ;;	отправляет
	If WinExist("AhkSpyZoom ahk_id" oOther.hZoom)
		SendMessage, % MsgAhkSpyZoom, wParam, lParam, , % "ahk_id" oOther.hZoom
}

ZoomSleep() {
	Sleep := 1
}
ZoomNoSleep() {
	Sleep := 0
}

AhkSpyZoomShow() {
	If !oPubObjGUID
		ObjRegisterActive(oObjActive, oPubObjGUID := CreateGUID())
		, oObjActive.AhkSpy_Minimize := Func("Minimize")
		, oObjActive.ZoomSleep := Func("ZoomSleep")
		, oObjActive.ZoomNoSleep := Func("ZoomNoSleep")
	If !WinExist("ahk_id" oOther.hZoom) {
		Hotkey := ThisMode = "Hotkey"
		Suspend := !isAhkSpy
		If A_IsCompiled
			Run "%A_ScriptFullPath%" "Zoom" "%hGui%" "%ActiveNoPause%" "%isPaused%" "%Suspend%" "%Hotkey%" "%OnlyShiftTab%" "%oPubObjGUID%" "%HeigtButton%", , , PID
		Else
			Run "%A_AHKPath%" "%A_ScriptFullPath%" "Zoom" "%hGui%" "%ActiveNoPause%" "%isPaused%" "%Suspend%" "%Hotkey%" "%OnlyShiftTab%" "%oPubObjGUID%" "%HeigtButton%", , , PID
		WinWait, % "ahk_pid" PID, , 1
	}
	Else If DllCall("IsWindowVisible", "Ptr", oOther.hZoom)
		ZoomMsg(0)
	Else
		ZoomMsg(1) 
	SetTimer(Func("ColorProgress").Bind("Color_Zoom", ColorSelModeButton), "-" 1)
	SetTimer(Func("ColorProgress").Bind("Color_Zoom", ColorBgModeButton), "-" 150)
} 

SetPosObject(Name, arr) {
	If !oOther.ZoomShow
		Return
	oObjActive["Coords" Name] := arr
} 

SavePos() {
	If FullScreenMode || !MemoryPos
		Return
	WinGet, Min, MinMax, ahk_id %hGui%
	If (Min = 0)
	{
		WinGetPos, WinX, WinY, , , ahk_id %hGui%
		IniWrite(WinX, "MemoryPosX"), IniWrite(WinY, "MemoryPosY")
	}
}

SaveSize() {
	If FullScreenMode || !MemorySize
		Return
	WinGet, Min, MinMax, ahk_id %hGui%
	If (Min = 0)
	{
		GetClientPos(hGui, _, _, WinWidth, WinHeight)
		IniWrite(WinWidth, "MemorySizeW"), IniWrite(WinHeight, "MemorySizeH")
	}
}

	;;  http://forum.script-coding.com/viewtopic.php?pid=87817#p87817
	;;  http://www.autohotkey.com/board/topic/93660-embedded-ie-shellexplorer-render-issues-fix-force-it-to-use-a-newer-render-engine/

   ; +1:: MsgBox % oDoc.compatMode "`n" oDoc.documentMode
   
FixIE() {
	Key := "Software\Microsoft\Internet Explorer\MAIN"
	. "\FeatureControl\FEATURE_BROWSER_EMULATION", ver := 8000
	If A_IsCompiled
		ExeName := A_ScriptName
	Else
		SplitPath, A_AhkPath, ExeName
	RegRead, value, HKCU, %Key%, %ExeName%
	If (value != ver)
		RegWrite, REG_DWORD, HKCU, %Key%, %ExeName%, %ver%
}

; так не работает  https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms537169%28v%3dvs.85%29
ActiveScriptAllow(Off = 0) {
	Static keyInternet := "Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3", IsAllow := 1
	If !ActiveScriptAllowChange
		Return
	If !Off
	{
		RegRead, value, HKCU, %KEYInternet%, 1400
		If (value = 0)   ; Включено
			Return 
		IsAllow := 0 
		RegWrite, REG_DWORD, HKCU, %KEYInternet%, 1400, 0   ; Включить
		Return
	}
	Else If !IsAllow 
		RegWrite, REG_DWORD, HKCU, %KEYInternet%, 1400, 3   ; Выключить
}

ObjRegisterActive(Object, CLSID, Flags := 0) {
   static cookieJar := {}
   if !CLSID  {
      if (( cookie := cookieJar.Delete(Object) ) != "")
         DllCall("oleaut32\RevokeActiveObject", UInt, cookie, Ptr, 0)
      Return
   }
   if cookieJar[Object]
      throw Exception("Object is already registered", -1)
   VarSetCapacity(_clsid, 16, 0)
   if (hr := DllCall("ole32\CLSIDFromString", WStr, CLSID, Ptr, &_clsid)) < 0
      throw Exception("Invalid CLSID", -1, CLSID)
   hr := DllCall("oleaut32\RegisterActiveObject", Ptr, &Object, Ptr, &_clsid, UInt, Flags, UIntP, cookie, UInt)
   if hr < 0
      throw Exception(format("Error 0x{:x}", hr), -1)
   cookieJar[Object] := cookie
}

CreateGUID()
{
   VarSetCapacity(pguid, 16, 0)
   if !DllCall("ole32.dll\CoCreateGuid", Ptr, &pguid)  {
      size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
      if DllCall("ole32.dll\StringFromGUID2", Ptr, &pguid, Ptr, &sguid, UInt, size)
         Return StrGet(&sguid)
   }
}

RunPath(Link, WorkingDir = "", Option = "") {
	Run %Link%, %WorkingDir%, %Option%
	Minimize()
}

RunRealPath(Path) {
	SplitPath, Path, , Dir
	Dir := LTrim(Dir, """")
	While !InStr(FileExist(Dir), "D")
		Dir := SubStr(Dir, 1, -1)
	Run, %Path%, %Dir%
}

RunAhkPath(Path, Param = "") {
	SplitPath, Path, , , Extension
	If Extension = exe
		RunPath(Path)
	Else If (!A_IsCompiled && Extension = "ahk")
		RunPath("""" A_AHKPath """ """ Path """ """ Param """")
}

RunShell(Path) {
	ComObjCreate("WScript.Shell").Exec(Path)
}

ExtraFile(Name, GetNoCompile = 0) {
	If FileExist(Path_User "\" Name ".exe")
		Return Path_User "\" Name ".exe"
	If !A_IsCompiled && FileExist(Path_User "\" Name ".ahk")
		Return Path_User "\" Name ".ahk"
}

ShowMarker(x, y, w, h, b := 4) { 
	(w < 8 || h < 8) && (b := 2)
	ShowMarkers(oShowMarkers, x, y, w, h, b)
}

ShowAccMarker(x, y, w, h, b := 2) { 
	ShowMarkers(oShowAccMarkers, x, y, w, h, b)
}

ShowMarkerEx(x, y, w, h, b := 4) { 
	(w < 8 || h < 8) && (b := 2)
	ShowMarkers(oShowMarkersEx, x, y, w, h, b)
}

HideMarker() {
	HideMarkers(oShowMarkers)
}

HideAccMarker() {
	HideMarkers(oShowAccMarkers)
}

HideMarkerEx() {
	HideMarkers(oShowMarkersEx)
}

HideAllMarkers() {
	HideMarker(), HideAccMarker()
}

ShowMarkers(arr, x, y, w, h, b) {
	hDWP := DllCall("BeginDeferWindowPos", "Int", 4)
	for k, v in [[x, y, b, h],[x, y+h-b, w, b],[x+w-b, y, b, h],[x, y, w, b]]
		{
			hDWP := DllCall("DeferWindowPos"
			, "Ptr", hDWP, "Ptr", arr[k], "UInt", -1  ;;	-1 := HWND_TOPMOST
			, "Int", v[1], "Int", v[2], "Int", v[3], "Int", v[4]
			, "UInt", 0x0250)    ;; 0x0010 := SWP_NOACTIVATE | 0x0040 := SWP_SHOWWINDOW | SWP_NOOWNERZORDER := 0x0200
		}
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
	ShowMarker := 1
}

HideMarkers(arr) {
	hDWP := DllCall("BeginDeferWindowPos", "Int", 4)
	Loop 4
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", arr[A_Index], "UInt", 0
		, "Int", 0, "Int", 0, "Int", 0, "Int", 0
		, "UInt", 0x0083)    ;; 0x0080 := SWP_HIDEWINDOW | SWP_NOMOVE := 0x0002 | SWP_NOSIZE := 0x0001
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
	ShowMarker := 0
}

ShowMarkersCreate(arr, color) {
	If !!%arr%
		Return
	S_DefaultGui := A_DefaultGui, %arr% := {}
	
	loop 4
	{
		Gui, New
		Gui, Margin, 0, 0
		Gui, -DPIScale +Owner +HWNDHWND -Caption +%WS_CHILDWINDOW% +E%WS_EX_NOACTIVATE% +ToolWindow -%WS_POPUP% +AlwaysOnTop  +E%WS_EX_TRANSPARENT% 
		Gui, Color, %color% 
		WinSet, TransParent, 250, ahk_id %HWND%
		%arr%[A_Index] := HWND
		Gui, Show, NA Hide
	}
	Gui, %S_DefaultGui%:Default
}

CheckHideMarker() {
	Static Try
	Try := 0
	SetTimer, __CheckHideMarker, -50
	Return

	__CheckHideMarker:
		If (Sleep = 1 || (WinActive("ahk_id" hGui) && !ActiveNoPause) || isPaused)
			HideAllMarkers()
		If (Try := ++Try > 2 ? 0 : Try)
			SetTimer, __CheckHideMarker, -150
		Return
}

FlashArea(x, y, w, h, att = 1) {
	Static hFunc, max := 6
	If (att = 1)
		Try SetTimer, % hFunc, Off
	Mod(att, 2) ? ShowMarkerInvert(x, y, w, h, 5) : HideMarkerInvert()
	If (att = max)
		Return
	hFunc := Func("FlashArea").Bind(x, y, w, h, ++att)
	SetTimer, % hFunc, -100
}

CreateMarkerInvert() {    
	Gui, MI: -DPIScale +HWNDhMarkerGui -Caption +AlwaysOnTop +ToolWindow +E%WS_EX_TRANSPARENT% 
	hDCMarkerInvert := DllCall("GetDC", "Ptr", hMarkerGui)
	WinSet, TransParent, 0, ahk_id %hMarkerGui% 
}

HideMarkerInvert() {
	WinSet, TransParent, 0, ahk_id %hMarkerGui% 
 	Gui, MI: Show, Hide
}

ShowMarkerInvert(x, y, w, h, b := 6) {
	Try Gui, MI: Show, NA x%x% y%y% w%w% h%h% 
	If MarkerInvertFrame
	{
		w < 16 || h < 16 ? b := 2 : 0
		WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
			. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerGui%
	}
	hDC := DllCall("GetDC", "Ptr", 0, "Ptr") 
	
	DllCall("BitBlt", "Ptr", hDCMarkerInvert, "int", 0, "int", 0, "int", w, "int", h
			, "Ptr", hDC, "int", X, "int", Y, "Uint", 0x00330008)   ;; NOTSRCCOPY
	
	WinSet, TransParent, 255, ahk_id %hMarkerGui%
	Gui, MI: +AlwaysOnTop
	DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC)
}

SetEditColor(hwnd, BG, FG) {
	Edits[hwnd] := {BG:BG,FG:FG}
	WM_CTLCOLOREDIT(DllCall("GetDC", "Ptr", hwnd), hwnd)
	DllCall("RedrawWindow", "Ptr", hwnd, "Uint", 0, "Uint", 0, "Uint", 0x1|0x4)
}

WM_CTLCOLOREDIT(wParam, lParam) {
	If !Edits.HasKey(lParam)
		Return 0
	hBrush := DllCall("CreateSolidBrush", UInt, Edits[lParam].BG)
	DllCall("SetTextColor", Ptr, wParam, UInt, Edits[lParam].FG)
	DllCall("SetBkColor", Ptr, wParam, UInt, Edits[lParam].BG)
	DllCall("SetBkMode", Ptr, wParam, UInt, 2)
	Return hBrush
}

InArr(Val, Arr) {
	For k, v in Arr
		If (v == Val)
			Return k
}

TransformHTML(str) {
	Transform, str, HTML, %str%, 3
	StringReplace, str, str, <br>, , 1
	Return str
}

PausedTitleText() {
	Static i := 0, Str := "           Paused..."
 	If !isPaused
		Return i := 0
	i := i > 20 ? 2 : i + 1
	TitleTextP2 := "     " SubStr(Str, i) . SubStr(Str, 1, i - 1)
	TitleText := TitleTextP1 . TitleTextP2
	If !FreezeTitleText
		SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	SetTimer, PausedTitleText, -200
}

TitleText(Text, Time = 1000) {
	FreezeTitleText := 1
	StringReplace, Text, Text, `r`n, % Chr(8629), 1
	StringReplace, Text, Text, %A_Tab%, % "      ", 1
	SendMessage, 0xC, 0, &Text, , ahk_id %hGui%
	SetTimer, TitleShow, -%Time%
}

TitleShow:
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	FreezeTitleText := 0
	Return

ClipAdd(Text, AddTip = 0) {
	If ClipAdd_Before
		Clipboard := Text ClipAdd_Delimiter Clipboard
	Else
		Clipboard := Clipboard ClipAdd_Delimiter Text
	If AddTip
		ToolTip("add", 300)
}

ClipPaste() {
 	If oMS.ELSel && (oMS.ELSel.OuterText != "" || MS_Cancel())
		oMS.ELSel.innerHTML := TransformHTML(Clipboard), oMS.ELSel.Name := "MS:"
		, MoveCaretToSelection(0)
	Else
		oDoc.execCommand("Paste")
	ToolTip("paste", 300)
}

CutSelection() {
 	If MS_IsSelection()
		MoveCaretToSelection(0), Clipboard := oMS.ELSel.OuterText
		, oMS.ELSel.OuterText := "", MS_Cancel()
	Else
		oDoc.execCommand("Cut")
	ToolTip("cut", 300)
}

DeleteSelection() {
 	If MS_IsSelection()
		MoveCaretToSelection(0), oMS.ELSel.OuterText := "", MS_Cancel()
	Else
		oDoc.execCommand("Delete")
}

PasteStrSelection(Str) {
 	If MS_IsSelection()
		MoveCaretToSelection(0), oMS.ELSel.OuterText := TransformHTML(Str), MS_Cancel()
	Else
		oDoc.selection.createRange().text := Str
}

PasteTab() {
	TempClipboard := ClipboardAll
	Clipboard := "" A_Tab ""
	oDoc.execCommand("Paste")
	Clipboard := TempClipboard 
}

PasteHTMLSelection(Str) {
 	If MS_IsSelection()
		oMS.ELSel.innerHTML := Str, MoveCaretToSelection(0)
	Else
		oDoc.selection.createRange().pasteHTML(Str)
}

MoveCaretToSelection(start) {
	R := oBody.createTextRange(), R.moveToElementText(oMS.ELSel), R.collapse(start), R.select()
}

GetSelected(ByRef Text, ByRef IsoMS = "") {
	Text := oMS.ELSel.OuterText
 	If (Text != "")
		IsoMS := 1
	Else
		Text := oDoc.selection.createRange().text, IsoMS := 0
	Return (Text != "")
}

CopyCommaParam(Text) {
 	If !(Text ~= "(x|y|w|h|" Chr(178) ")-*\d+")
		Return Text
	Text := RegExReplace(Text, "i)(x|y|w|h|#|\s|" Chr(178) "|" Chr(9642) ")+", " ")
	Text := TRim(Text, " "), Text := RegExReplace(Text, "(\s|,)+", ", ")
	Return Text
}

Add_DP(addN, Items*) {
 	For k, v in Items 
		If v != 
			Ret .= v _DP
	If Ret =
		Return
	Return (addN ? "`n" : "") SubStr(Ret, 1, -StrLen(_DP))
}

	;;  http://forum.script-coding.com/viewtopic.php?pid=53516#p53516

;; GetCommandLineProc(pid) {
	;; ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process WHERE ProcessId = " pid)._NewEnum.next(X)
	;; Return Trim(X.CommandLine)
;; }

	;;  http://forum.script-coding.com/viewtopic.php?pid=111775#p111775

GetCommandLineProc(PID, ByRef Cmd, ByRef Bit, ByRef IsAdmin) {
	Static PROCESS_QUERY_INFORMATION := 0x400, PROCESS_VM_READ := 0x10, STATUS_SUCCESS := 0

	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, Int, 0, UInt, PID, Ptr)
	if A_Is64bitOS
		DllCall("IsWow64Process", Ptr, hProc, UIntP, IsWow64), Bit := (IsWow64 ? "32" : "64") " bit" _DP
	if (!A_Is64bitOS || IsWow64)
		PtrSize := 4, PtrType := "UInt", pPtr := "UIntP", offsetCMD := 0x40
	else
		PtrSize := 8, PtrType := "Int64", pPtr := "Int64P", offsetCMD := 0x70
	hModule := DllCall("GetModuleHandle", "str", "Ntdll", Ptr)
	if (A_PtrSize < PtrSize) {            ;; скрипт 32, целевой процесс 64
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64QueryInformationProcess64", Ptr)
			failed := "NtWow64QueryInformationProcess64"
		if !ReadProcessMemory := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64ReadVirtualMemory64", Ptr)
			failed := "NtWow64ReadVirtualMemory64"
		info := 0, szPBI := 48, offsetPEB := 8
	}
	else  {
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtQueryInformationProcess", Ptr)
			failed := "NtQueryInformationProcess"
		ReadProcessMemory := "ReadProcessMemory"
		if (A_PtrSize > PtrSize)            ;; скрипт 64, целевой процесс 32
			info := 26, szPBI := 8, offsetPEB := 0
		else                                ;; скрипт и целевой процесс одной битности
			info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
	}
	if failed  {
		DllCall("CloseHandle", Ptr, hProc)
		Return
	}
	VarSetCapacity(PBI, 48, 0)
	if DllCall(QueryInformationProcess, Ptr, hProc, UInt, info, Ptr, &PBI, UInt, szPBI, UIntP, bytes) != STATUS_SUCCESS  {
		DllCall("CloseHandle", Ptr, hProc)
		Return
	}
	pPEB := NumGet(&PBI + offsetPEB, PtrType)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPEB + PtrSize * 4, pPtr, pRUPP, PtrType, PtrSize, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD, UShortP, szCMD, PtrType, 2, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD + PtrSize, pPtr, pCMD, PtrType, PtrSize, UIntP, bytes)
	VarSetCapacity(buff, szCMD, 0)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pCMD, Ptr, &buff, PtrType, szCMD, UIntP, bytes)
	Cmd := StrGet(&buff, "UTF-16")

	DllCall("advapi32\OpenProcessToken", "ptr", hProc, "uint", 0x0008, "ptr*", hToken)
	DllCall("advapi32\GetTokenInformation", "ptr", hToken, "int", 20, "uint*", IsAdmin, "uint", 4, "uint*", size)
	DllCall("CloseHandle", "ptr", hToken)
	IsAdmin := (IsAdmin ? "Admin" _DP : "")

	DllCall("CloseHandle", Ptr, hProc)
}

SeDebugPrivilege() {
	Static PROCESS_QUERY_INFORMATION := 0x400, TOKEN_ADJUST_PRIVILEGES := 0x20, SE_PRIVILEGE_ENABLED := 0x2

	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION, Int, false, UInt, oOther.CurrentProcessId, Ptr)
	DllCall("Advapi32\OpenProcessToken", Ptr, hProc, UInt, TOKEN_ADJUST_PRIVILEGES, PtrP, token)
	DllCall("Advapi32\LookupPrivilegeValue", Ptr, 0, Str, "SeDebugPrivilege", Int64P, luid)
	VarSetCapacity(TOKEN_PRIVILEGES, 16, 0)
	NumPut(1, TOKEN_PRIVILEGES, "UInt")
	NumPut(luid, TOKEN_PRIVILEGES, 4, "Int64")
	NumPut(SE_PRIVILEGE_ENABLED, TOKEN_PRIVILEGES, 12, "UInt")
	DllCall("Advapi32\AdjustTokenPrivileges", Ptr, token, Int, false, Ptr, &TOKEN_PRIVILEGES, UInt, 0, Ptr, 0, Ptr, 0)
	res := A_LastError
	DllCall("CloseHandle", Ptr, token)
	DllCall("CloseHandle", Ptr, hProc)
	Return res  ;; в случае удачи 0
}

	;;  http://www.autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/#entry438372

GetClientPos(hwnd, ByRef left, ByRef top, ByRef w, ByRef h) {
	Static _ := VarSetCapacity(pwi, 60, 0)
	DllCall("GetWindowInfo", "Ptr", hwnd, "Ptr", &pwi)
	left := NumGet(pwi, 20, "Int") - NumGet(pwi, 4, "Int")
	top := NumGet(pwi, 24, "Int") - NumGet(pwi, 8, "Int")
	w := NumGet(pwi, 28, "Int") - NumGet(pwi, 20, "Int")
	h := NumGet(pwi, 32, "Int") - NumGet(pwi, 24, "Int")
}

	;;  http://forum.script-coding.com/viewtopic.php?pid=81833#p81833

SelectFilePath(FilePath) { 
	FilePath := TRim(FilePath)
	FilePath := RegExReplace(FilePath, "(^""|""$)")
	FilePath := TRim(FilePath)
	
	If !FileExist(FilePath)
		Return 0
	SplitPath, FilePath,, Dir
	for window in ComObjCreate("Shell.Application").Windows  {
		ShellFolderView := window.Document
		Try If ((Folder := ShellFolderView.Folder).Self.Path != Dir)
			Continue
		Catch
			Continue
		for item in Folder.Items  {
			If (item.Path != FilePath)
				Continue
			ShellFolderView.SelectItem(item, 1|4|8|16)
			WinActivate, % "ahk_id" window.hwnd
			Return 1
		}
	}
	Run, %A_WinDir%\explorer.exe /select`, "%FilePath%", , UseErrorLevel
	Return 1
}

FileToClipboard(PathToCopy,Method="copy") {
	FileCount:=0
	PathLength:=0

	; Count files and total string length
	Loop,Parse,PathToCopy,`n,`r
	{
		FileCount++
		PathLength+=StrLen(A_LoopField)
	}

	pid:=DllCall("GetCurrentProcessId","uint")
	hwnd:=WinExist("ahk_pid " . pid)
	; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
	hPath := DllCall("GlobalAlloc","uint",0x42,"uint",20 + (PathLength + FileCount + 1) * 2,"UPtr")
	pPath := DllCall("GlobalLock","UPtr",hPath)
	NumPut(20,pPath+0),pPath += 16 ; DROPFILES.pFiles = offset of file list
	NumPut(1,pPath+0),pPath += 4 ; fWide = 0 -->ANSI,fWide = 1 -->Unicode
	Offset:=0
	Loop,Parse,PathToCopy,`n,`r ; Rows are delimited by linefeeds (`r`n).
		offset += StrPut(A_LoopField,pPath+offset,StrLen(A_LoopField)+1,"UTF-16") * 2

	DllCall("GlobalUnlock","UPtr",hPath)
	DllCall("OpenClipboard","UPtr",hwnd)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData","uint",0xF,"UPtr",hPath) ; 0xF = CF_HDROP

	; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
	; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
	mem := DllCall("GlobalAlloc","uint",0x42,"uint",4,"UPtr")
	str := DllCall("GlobalLock","UPtr",mem)

	if (Method="copy")
		DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x05)
	else if (Method="cut")
		DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x02)
	else
	{
		DllCall("CloseClipboard")
		return
	}

	DllCall("GlobalUnlock","UPtr",mem)

	cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect")
	DllCall("SetClipboardData","uint",cfFormat,"UPtr",mem)
	DllCall("CloseClipboard") 
}

ExecCommandAutoHotkey(Command, PID) {
    Static WM_COMMAND := 0x111
     , Commands := {"Reload Script": 65400
           , "Edit Script": 65401
           , "Suspend Hotkeys": 65404
           , "Pause Script": 65403
           , "Exit Script": 65405
           , "Recent Lines": 65406
           , "Variables": 65407
           , "Hotkeys": 65408
           , "Key history": 65409
           , "AHK User Manual": 65411}
	PostMessage WM_COMMAND, % Commands[Command],,, % "ahk_class AutoHotkey ahk_pid" . PID   
} 

GetCLSIDExplorer(hwnd) {
	for window in ComObjCreate("Shell.Application").Windows
		If (window.hwnd = hwnd)
			Return (CLSID := window.Document.Folder.Self.Path) ~= "^::\{" ? "`n<span class='param'>CLSID: </span><span name='MS:'>" CLSID "</span>": ""
}

ChangeLocal(hWnd) {
	Static WM_INPUTLANGCHANGEREQUEST := 0x0050, INPUTLANGCHANGE_FORWARD := 0x0002
	SendMessage, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_FORWARD, , , % "ahk_id" hWnd
}

GetLangName(hWnd) {
	Static LOCALE_SENGLANGUAGE := 0x1001
	Locale := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr) & 0xFFFF
	Size := DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, UInt, 0, UInt, 0) * 2
	VarSetCapacity(lpLCData, Size, 0)
	DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, Str, lpLCData, UInt, Size)
	Return lpLCData
}

ConfirmAction(Action) {
	If !WinActive("ahk_id" hGui) || GetKeyState("Shift")
		Return
	If (!isPaused && bool := 1)
		Gosub, PausedScript
	isConfirm := 1
	bool2 := MsgConfirm(Action, "AhkSpy", hGui)
	isConfirm := 0
	If bool
		Gosub, PausedScript
	If !bool2
		Exit
	Return 1
}

MsgConfirm(Info, Title, hWnd) {
	Static hMsgBox, Text, Yes, No, WinW, WinH
	If !hMsgBox {
		Gui, MsgBox:+HWNDhMsgBox -DPIScale -SysMenu +Owner%hWnd% +AlwaysOnTop
		Gui, MsgBox:Font, % "s" FontDPI " c" ColorFont
		Gui, MsgBox:Color, %ColorBgOriginal%
		Gui, MsgBox:Add, Text, w200 vText r1 Center 
		Gui, MsgBox:Add, Button, w88 vYes xp+4 y+20 gMsgBoxLabel, Yes
		Gui, MsgBox:Add, Button, w88 vNo x+20 gMsgBoxLabel, No 
		WinSet, TransParent, 0, ahk_id %hMsgBox% 
		Gui, MsgBox:Show, NA AutoSize x-32000 y-32000
		WinGetPos, , , WinW, WinH, ahk_id %hMsgBox%
	}
	Gui, MsgBox:+Owner%hWnd% +AlwaysOnTop
	Gui, %hWnd%:+Disabled
	GuiControl, MsgBox:Text, Text, % Info
	CoordMode, Mouse
	MouseGetPos, X, Y
	x := X - (WinW / 2)
	y := Y - WinH - 10
	Gui, MsgBox: Show, NA x%x% y%y%, % Title
	Sleep 1
	WinSet, TransParent, 255, ahk_id %hMsgBox%
	Gui, MsgBox: Show, , % Title
	Gui MsgBox:+AlwaysOnTop
	GuiControl, MsgBox:+Default, No
	GuiControl, MsgBox:Focus, No
	While (RetValue = "")
		Sleep 30
	Gui, %hWnd%:-Disabled
	WinSet, TransParent, 0, ahk_id %hMsgBox% 
	Gui, MsgBox: Show, x-32000 y-32000
	Return RetValue

	MsgBoxLabel:
		RetValue := {Yes:1,No:0}[A_GuiControl]
		Return
}

UnderControl(h) { 
	MouseGetPos, , , Control, , 2
	Return (Control = h)
}

MouseStep(x, y) {
	MouseMove, x, y, 0, R
	If (WinActive("ahk_id" hGui) && !ActiveNoPause) || OnlyShiftTab
	{
		(ThisMode = "Control" ? (Spot_Control() (StateAllwaysSpot ? Spot_Win() : 0) Write_Control()) : (Spot_Win() (StateAllwaysSpot ? Spot_Control() : 0) Write_Win()))
		If DllCall("IsWindowVisible", "Ptr", oOther.hZoom)
			ZoomMsg(3)
	}
	Shift_Tab_Down := 1
}

IsIEFocus() {
	If !WinActive("ahk_id" hGui)
		Return 0
	ControlGetFocus, Focus
	Return InStr(Focus, "Internet")
}

NextLink(s = "") {
	curpos := oDivNew.scrollTop, oDivNew.scrollLeft := 0
	If (!curpos && s = "-")
		Return
	While (pos := oDoc.getElementsByTagName("a").item(A_Index-1).getBoundingClientRect().top) != ""
		(s 1) * pos - 12 > 0 && (!res || abs(res) > abs(pos)) ? res := pos : ""       ;; http://forum.script-coding.com/viewtopic.php?pid=82360#p82360
	If (res = "" && s = "")
		Return
	st := !res ? -curpos : res, co := abs(st) > 150 ? 20 : 10
	Loop % co
		oDivNew.scrollTop := curpos + (st*(A_Index/co))  
	oDivNew.scrollTop := curpos + res - 6
}  

AnchorColor() {
	If !oOther.anchor[ThisMode]
		Return 
	el := GetAnchor()
	el.parentElement.parentElement.firstChild.style.backgroundColor := "#" ColorSelAnchor
	Return el
}

GetAnchor() {
	If !oOther.anchor[ThisMode "_text"]
		Return
	Return oJScript.QS(oDivNew, "#" oOther.anchor[ThisMode "_text"]) ; .parentElement.parentElement.firstChild
}

AnchorScroll(EL = "") { 
	If !oOther.anchor[ThisMode]
		Return
	If !EL
		el := GetAnchor()
	_AnchorFitScroll(EL)  
	oDivNew.scrollTop := oDivNew.scrollTop + EL.getBoundingClientRect().top - 6
}  
 
_AnchorFitScroll(EL, off = 0) { 
	If !AnchorFullScroll
		Return 
	ta := EL.getBoundingClientRect().top   
	ELLast := oJScript.QS(oDivNew, "#id_T0") 
	tl := ELLast.getBoundingClientRect().top   
	clH := oDivNew.clientHeight   
	res := clH - (tl - ta)  
	If res < 0
		res := 0 
	; ToolTip % clH "`n" tl "`n" ba  "`n"  "`n" res, , , 2
	ELLast.style.height := res "px"
	Return 1
}
 
AnchorFitScroll() {
	_AnchorFitScroll(GetAnchor()) 
}

TaskbarProgress(state, hwnd, pct = "") {
	static tbl
	if !tbl {
		try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
		catch
			tbl := "error"
	}
	if tbl = error
		Return
	DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "ptr", tbl, "ptr", hwnd, "uint", state)
	if pct !=
		DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "ptr", tbl, "ptr", hwnd, "int64", pct, "int64", 100)
}

/*
HighLight(elem, time = "", RemoveFormat = 1) {
	If (elem.OuterText = "")
		Return
	Try SetTimer, UnHighLight, % "-" time
	R := oBody.createTextRange()
	(RemoveFormat ? R.execCommand("RemoveFormat") : 0)
	R.collapse(1)
	R.select()
	R.moveToElementText(elem)
	
	; https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/hh801229(v=vs.85)#forecolor
	R.execCommand("ForeColor", 0, ColorBgOriginal) ; неработает 
	R.execCommand("BackColor", 0, ColorSelMouseHover)
	Return

	UnHighLight:
		oBody.createTextRange().execCommand("RemoveFormat")
		Return
}
*/

HighLight(elements, time = 500) {
	Static arr, ot
	R := oBody.createTextRange(), R.collapse(1), R.select()
	
	If elements
		(arr && SetTimer(ot, "Off") %A_ThisFunc%(0))
		, bc := "#" ColorSelMouseHover, tc := "#" ColorSelMouseHoverText 
	Else 
		elements := arr, delete := 1
		
	for k, el in elements
	{
		el.style.backgroundColor := bc
		el.style.color := tc
		Loop % el.all.length
			el.all[A_Index - 1].style.color := tc
	}
	If delete 
		Return 0, arr := 0 
	arr := elements 
	Return 1, SetTimer(ot := Func(A_ThisFunc).Bind(0), "-" time)
}

Hotkey_ClipCursor() { 
	Static lpRect, _ := VarSetCapacity(lpRect, 16, 0)  
	DllCall("GetClipCursor", "Ptr", &lpRect) 
	
	If NumGet(lpRect, 0, "uint") > 0xffff || NumGet(lpRect, 0, "uint") = 0
	{ 
		; WinGetPos, WinX, WinY, WinWidth, WinHeight, % "ahk_id" hActiveX 
		CoordMode, Mouse, Screen
		MouseGetPos, X, Y
		NumPut(X, lpRect, 0, "uint")
		NumPut(Y, lpRect, 4, "uint")
		NumPut(X, lpRect, 8, "uint")
		NumPut(Y, lpRect, 12, "uint") 
		DllCall("ClipCursor", "Ptr", &lpRect + 0)   
		ToolTip2("Cancel press down and up lbutton, and press lbutton 2 seconds, else Ctrl+Alt+Delete", -1, 0, -100, 2)
	}
	Else  
	{
		KeyWait LButton
		KeyWait LButton, D
		KeyWait LButton, T2
		If ErrorLevel
			DllCall("ClipCursor", "Ptr", 0), ToolTip2("", -1, , , 2)
	}
}
	; ___________________________ Command as function _________________________________________________
 
WinGetPosToArray(h) {
	WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " h
	return [WinX, WinY, WinW, WinH] 
}

IniRead(Key, Error := " ") {
	IniRead, Value, %A_AppData%\AhkSpy\Settings.ini, AhkSpy, %Key%, %Error%
	If (Value = "" && Error != " ")
		Value := Error
	Return Value
}

IniWrite(Value, Key) {
	IniWrite, %Value%, %A_AppData%\AhkSpy\Settings.ini, AhkSpy, %Key%
	Return Value
}

MsgBox(msg) {
	MsgBox %msg%
}

WinClose(title) {
	WinClose % title
}

Sleep(time) {
	Sleep time
}

SendInput(key) {
	SendInput % key
}

SetTimer(funcorlabel, time = -500) {
	SetTimer, % funcorlabel, % time
}

GuiControl(SubCommand, ControlID = "", Value = "") { 
	GuiControl, %SubCommand%, %ControlID%, %Value%
}

MouseMoveScreen(x, y) {
	CoordMode, Mouse, Screen
	SetMouseDelay, 0, 0
	SendEvent {Click %x%, %y%, 0}  
}

ToolTip(text, time = 500) {
	CoordMode, Mouse
	CoordMode, ToolTip
	MouseGetPos, X, Y
	ToolTip, %text%, X-10, Y-45
	If (time > 0)
		SetTimer, HideToolTip, -%time%
	Return 1

	HideToolTip:
		ToolTip
		Return
}

ToolTip2(text, time = 500, x = 0, y = 0, ex = 1, CoordMode = "Mouse") {
	If CoordMode = Mouse
	{
		CoordMode, Mouse
		CoordMode, ToolTip
		MouseGetPos, mX, mY
		X+=mX, Y+=mY
	}
	Else 
		CoordMode, ToolTip, %CoordMode%  ;	Screen, Window, Client  (if omitted, it defaults to Screen)
	ToolTip, %text%, x, y, ex
	If (time > 0)
		SetTimer, HideToolTip2, -%time%
	Return 1

	HideToolTip2:
		ToolTip
		Return
}
	; ___________________________ Update _________________________________________________

UpdateAhkSpy(in = 1) {
	Static att, Ver, req
		, url1 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/Readme.txt"
		, url2 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/AhkSpy.ahk"

	If !req
		req := ComObjCreate("WinHttp.WinHttpRequest.5.1"), req.Option(6) := 0
	req.open("GET", url%in%, 1), req.send(), att := 0
	SetTimer, Upd_Verifi, -3000
	Return

	Upd_Verifi:
		If (Status := req.Status) = 200
		{
			Text := req.responseText
			If (req.Option(1) = url1)
				Return (Ver := RegExReplace(Text, "i).*?version\s*(.*?)\R.*", "$1")) > AhkSpyVersion ? UpdateAhkSpy(2) : 0
			If (!InStr(Text, "AhkSpyVersion"))
				Return
			HideAllMarkers()
			If InStr(FileExist(A_ScriptFullPath), "R")
			{
				MsgBox, % 16+262144+8192, AhkSpy, Exist new version %Ver%!`n`nBut the file has an attribute "READONLY".`nUpdate imposible.
				Return
			}
			MsgBox, % 4+32+262144+8192, AhkSpy, Exist new version!`nUpdate v%AhkSpyVersion% to v%Ver%?
			IfMsgBox, No
				Return
			File := FileOpen(A_ScriptFullPath, "w", "UTF-8")
			File.Length := 0, File.Write(Text), File.Close()
			Reload
		}
		Error := (++att = 20 || Status != "")
		SetTimer, % Error ? "UpdateAhkSpy" : "Upd_Verifi", % Error ? -60000 : -3000
		Return
}

UpdRegister() {
	Static req, att := 0
	req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	req.open("post", UpdRegisterLink, 1), req.send()
	SetTimer, UpdRegister_Verifi, -2000
	Return

	UpdRegister_Verifi:
		++att
		If (req.Status = 200)
			IniWrite(1, "UpdRegister2")
		Else If (att <= 3)
			SetTimer, UpdRegister_Verifi, -2000
		Return
}

CheckAhkNewVersion() {
	Static req, att := 0
	req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	req.Option(6) := 0
	req.open("GET", "https://www.autohotkey.com/download/", 1)
	req.send()
	SetTimer, lCheckAhkNewVersion, -3000
	Return

	lCheckAhkNewVersion:
		++att
		If (req.Status = 200)
		{ 
			; RegExMatch(req.responseText, "O)<!--update-->v(.*?) - ", m), ver := m[1]
			ver := RegExReplace(req.responseText, "s).*?<!--update-->v(.*?) - .*", "$1")
			If StrReplace(ver, ".") <= StrReplace(A_AhkVersion, ".")
				Return
			MsgBox, % 4+32+262144+8192, AhkSpy, AutoHotkey new version!`nFor update v%A_AhkVersion% to v%Ver%, need to go autohotkey.com?
			IfMsgBox, No
				Return
			Run https://www.autohotkey.com/download/
			Return
		}
		If (att <= 3)
			SetTimer, lCheckAhkNewVersion, -2000
		Return 
}


	; ___________________________ WindowStyles _________________________________________________

ViewStylesWin(update = 0) {  ;;
	
	If update
	{
		WinGet, WinStyle, Style, % "ahk_id" oOther.WinID
		WinGet, WinExStyle, ExStyle, % "ahk_id" oOther.WinID
		
		If (WinStyle WinExStyle = "")
			Return ToolTip("Window not exist", 500)
		oDoc.getElementById("w_Style").innerText := WinStyle
		oDoc.getElementById("w_ExStyle").innerText := WinExStyle
		w_ShowStyles := 0
	}  
	oDoc.getElementById("get_styles_w").innerText := !(w_ShowStyles := !w_ShowStyles) ? " show styles " : " hide styles "
	IniWrite(w_ShowStyles, "w_ShowStyles")
			
	If w_ShowStyles || update
		Styles := "<a></a>" GetStyles(oOther.WinClass
			, oDoc.getElementById("w_Style").innerText
			, oDoc.getElementById("w_ExStyle").innerText
			, oOther.WinID)

	oDoc.getElementById("WinStyles").innerHTML := Styles
	HTML_Win := oDivNew.innerHTML
}

ViewStylesControl(update = 0) {  ;;
	
	If update
	{
		ControlGet, CtrlStyle, Style,,, % "ahk_id" oOther.ControlID
		ControlGet, CtrlExStyle, ExStyle,,, % "ahk_id" oOther.ControlID
		
		If (CtrlStyle CtrlExStyle = "")
			Return ToolTip("Window not exist", 500)
		oDoc.getElementById("c_Style").innerText := CtrlStyle
		oDoc.getElementById("c_ExStyle").innerText := CtrlExStyle
		c_ShowStyles := 0
	} 
	oDoc.getElementById("get_styles_c").innerText := !(c_ShowStyles := !c_ShowStyles) ? " show styles " : " hide styles "
	IniWrite(c_ShowStyles, "c_ShowStyles")  

	If c_ShowStyles
		Styles := "<a></a>" GetStyles(oOther.CtrlClass
			, oDoc.getElementById("c_Style").innerText
			, oDoc.getElementById("c_ExStyle").innerText
			, oOther.ControlID)
	oDoc.getElementById("ControlStyles").innerHTML := Styles
	HTML_Control := oDivNew.innerHTML
} 

GetStyles(Class, Style, ExStyle, hWnd, IsChild = 0, IsChildInfoExist = 0) {
	;;	http://msdn.microsoft.com/en-us/library/windows/desktop/ms632600(v=vs.85).aspx			Styles
	;;	http://msdn.microsoft.com/en-us/library/windows/desktop/ff700543(v=vs.85).aspx			ExStyles
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25880#p25880							Forum Constants
	;;	https://github.com/AHK-just-me/AHK_Gui_Constants/tree/master/Sources			GitHub Constants
	
	;;	http://www.frolov-lib.ru/books/bsp/v11/ch3_2.htm   русский фак по стилям
	;;	https://github.com/strobejb/winspy/blob/master/src/DisplayStyleInfo.c			Логика WinSpy++
	;;	http://forum.script-coding.com/viewtopic.php?pid=130846#p130846
	
	Static Styles, ExStyles, ClassStyles, DlgStyles, ToolTipStyles, GCL_STYLE := -26
	
	If !hWnd
		Return
	If !Styles
		   ;;  В массивах стили без условий
		Styles := {"WS_BORDER":"0x00800000", "WS_SYSMENU":"0x00080000"
		, "WS_CLIPCHILDREN":"0x02000000", "WS_CLIPSIBLINGS":"0x04000000", "WS_DISABLED":"0x08000000"
		, "WS_HSCROLL":"0x00100000", "WS_MAXIMIZE":"0x01000000"
		, "WS_VISIBLE":"0x10000000", "WS_VSCROLL":"0x00200000"}

		, ExStyles := {"WS_EX_ACCEPTFILES":"0x00000010", "WS_EX_APPWINDOW":"0x00040000", "WS_EX_CLIENTEDGE":"0x00000200"
		, "WS_EX_CONTROLPARENT":"0x00010000", "WS_EX_DLGMODALFRAME":"0x00000001", "WS_EX_LAYOUTRTL":"0x00400000"
		, "WS_EX_LEFTSCROLLBAR":"0x00004000", "WS_EX_WINDOWEDGE":"0x00000100"
		, "WS_EX_MDICHILD":"0x00000040", "WS_EX_NOACTIVATE":"0x08000000", "WS_EX_NOINHERITLAYOUT":"0x00100000"
		, "WS_EX_NOPARENTNOTIFY":"0x00000004", "WS_EX_NOREDIRECTIONBITMAP":"0x00200000", "WS_EX_RIGHT":"0x00001000"
		, "WS_EX_RTLREADING":"0x00002000", "WS_EX_STATICEDGE":"0x00020000"
		, "WS_EX_TOOLWINDOW":"0x00000080", "WS_EX_TOPMOST":"0x00000008", "WS_EX_TRANSPARENT":"0x00000020"}

		, ClassStyles := {"CS_BYTEALIGNCLIENT":"0x00001000", "CS_BYTEALIGNWINDOW":"0x00002000", "CS_CLASSDC":"0x00000040", "CS_IME":"0x00010000"
		, "CS_DBLCLKS":"0x00000008", "CS_DROPSHADOW":"0x00020000", "CS_GLOBALCLASS":"0x00004000", "CS_HREDRAW":"0x00000002"
		, "CS_NOCLOSE":"0x00000200", "CS_OWNDC":"0x00000020", "CS_PARENTDC":"0x00000080", "CS_SAVEBITS":"0x00000800", "CS_VREDRAW":"0x00000001"}
	
	orStyle := Style
	Style := sStyle := Style & 0xffff0000

	IF (Style & 0x00C00000) = 0x00C00000  && (WS_CAPTION := 1, WS_BORDER := 1, Style -= 0x00C00000)  ;;	WS_CAPTION && WS_BORDER 
		Ret .= QStyle("WS_CAPTION", "0x00C00000") QStyle("WS_BORDER", "0x00800000") 
		
	IF !WS_CAPTION && (Style & 0x00400000) && (WS_DLGFRAME := 1, Style -= 0x00400000)  ;;	WS_DLGFRAME 
		Ret .= QStyle("WS_DLGFRAME", "0x00400000", "!(WS_CAPTION)")
		
	For K, V In Styles
		If (Style & V) = V && (%K% := 1, Style -= V) 
			Ret .= QStyle(K, V)
 
	IF (Style & 0x00040000) && (WS_SIZEBOX := 1, WS_THICKFRAME := 1, Style -= 0x00040000)  ;;	WS_SIZEBOX := WS_THICKFRAME 
		Ret .= QStyle("WS_SIZEBOX := WS_THICKFRAME", "0x00040000")

	IF (Style & 0x40000000) && (WS_CHILD := 1, Style -= 0x40000000)  ;;	WS_CHILD := WS_CHILDWINDOW := 0x40000000
		Ret .= QStyle("WS_CHILD := WS_CHILDWINDOW", "0x40000000") 
		
	IF (Style & 0x00010000) && (WS_TABSTOP := 1, Style -= 0x00010000)  ;;	WS_TABSTOP
		Ret .= QStyle("WS_TABSTOP", "0x00010000")    ;;  , "(WS_CHILD)"
		
	IF (Style & 0x00020000) && WS_CHILD && (WS_GROUP := 1, Style -= 0x00020000)  ;;	WS_GROUP
		Ret .= QStyle("WS_GROUP", "0x00020000", "(WS_CHILD)")  

	IF (Style & 0x20000000) && (WS_MINIMIZE := 1, Style -= 0x20000000)  ;;	WS_MINIMIZE := WS_ICONIC
		Ret .= QStyle("WS_MINIMIZE := WS_ICONIC", "0x20000000")   

	IF (Style & 0x80000000) && !WS_CHILD && (WS_POPUP := 1, Style -= 0x80000000)  ;;	WS_POPUP
		Ret .= QStyle("WS_POPUP", "0x80000000", "!(WS_CHILD)")  

	IF (WS_POPUP && WS_BORDER && WS_SYSMENU) && (WS_POPUPWINDOW := 1)  ;;	WS_POPUPWINDOW
		Ret .= QStyle("WS_POPUPWINDOW", "0x80880000", "(WS_POPUP | WS_BORDER | WS_SYSMENU)")

	IF !WS_POPUP && !WS_CHILD && WS_BORDER && WS_CAPTION && (WS_OVERLAPPED := 1)  ;;	WS_OVERLAPPED := WS_TILED
		Ret .= QStyle("WS_OVERLAPPED := WS_TILED", "0x00000000", "(WS_BORDER | WS_CAPTION) & !(WS_POPUP | WS_CHILD)")

	IF WS_SYSMENU && (sStyle & 0x00020000) && (WS_MINIMIZEBOX := 1, (Style & 0x00020000) && (Style -= 0x00020000))  ;;	WS_MINIMIZEBOX
		Ret .= QStyle("WS_MINIMIZEBOX", "0x00020000", "(WS_SYSMENU)") 

	IF WS_SYSMENU && (sStyle & 0x00010000) && (WS_MAXIMIZEBOX := 1)  ;;	WS_MAXIMIZEBOX
		Ret .= QStyle("WS_MAXIMIZEBOX", "0x00010000", "(WS_SYSMENU)")

	If (WS_OVERLAPPED && WS_SIZEBOX && WS_SYSMENU && WS_MINIMIZEBOX && WS_MAXIMIZEBOX)  ;;	WS_OVERLAPPEDWINDOW := WS_TILEDWINDOW
		Ret .= QStyle("WS_OVERLAPPEDWINDOW := WS_TILEDWINDOW", "0x00CF0000", "(WS_OVERLAPPED | WS_SIZEBOX | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)") 

	If IsFunc("GetStyle_" Class)
		ChildStyles := GetStyle_%Class%(orStyle, hWnd, ChildExStyles)
				
	sExStyle := ExStyle
	For K, V In ExStyles
		If (ExStyle & V) && (%K% := 1, ExStyle -= V)
			RetEx .= QStyle(K, V)  

	IF !CS_OWNDC && !CS_CLASSDC && (ExStyle & 0x02000000) && (1, ExStyle -= 0x02000000)  ;;	WS_EX_COMPOSITED
		RetEx .= QStyle("WS_EX_COMPOSITED", "0x02000000", "!(CS_OWNDC | CS_CLASSDC)")  

	IF !WS_MAXIMIZEBOX && !WS_MINIMIZEBOX && (ExStyle & 0x00000400) && (1, ExStyle -= 0x00000400)  ;;	WS_EX_CONTEXTHELP
		RetEx .= QStyle("WS_EX_CONTEXTHELP", "0x00000400", "!(WS_MAXIMIZEBOX | WS_MINIMIZEBOX)")   
		
	IF !CS_OWNDC && !CS_CLASSDC && (ExStyle & 0x00080000) && (1, ExStyle -= 0x00080000)  ;;	WS_EX_LAYERED
		RetEx .= QStyle("WS_EX_LAYERED", "0x00080000", "!(CS_OWNDC | CS_CLASSDC)")   

	IF !WS_EX_RIGHT  ;;	WS_EX_LEFT
		RetEx .= QStyle("WS_EX_LEFT", "0x00000000", "!(WS_EX_RIGHT)")    

	IF !WS_EX_LEFTSCROLLBAR  ;;	WS_EX_RIGHTSCROLLBAR
		RetEx .= QStyle("WS_EX_RIGHTSCROLLBAR", "0x00000000", "!(WS_EX_LEFTSCROLLBAR)")     

	IF !WS_EX_RTLREADING  ;;	WS_EX_LTRREADING
		RetEx .= QStyle("WS_EX_LTRREADING", "0x00000000", "!(WS_EX_RTLREADING)")      

	IF WS_EX_WINDOWEDGE && WS_EX_CLIENTEDGE  ;;	WS_EX_OVERLAPPEDWINDOW
		RetEx .= QStyle("WS_EX_OVERLAPPEDWINDOW", "0x00000300", "(WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)")       

	IF WS_EX_WINDOWEDGE && WS_EX_TOOLWINDOW && WS_EX_TOPMOST  ;;	WS_EX_PALETTEWINDOW 
		RetEx .= QStyle("WS_EX_PALETTEWINDOW", "0x00000188", "(WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)")
 
	IF Style
		Ret .= QStyleRest(8, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Win'>" QStyleTitle("Styles", "", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2  
	Res .= ChildStyles
	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		Res .= _T1 " id='__ExStyles_Win'>" QStyleTitle("ExStyles", "", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2 
	Res .= ChildExStyles 
		
	;;  https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setclasslongw
	StyleBits := DllCall("GetClassLong", "Ptr", hWnd, "int", GCL_STYLE)	
	For K, V In ClassStyles
		If (StyleBits & V) && (%K% := 1)
				RetClass .= QStyle(K, V) 
	
	If RetClass !=
		Res .= _T1 " id='__ClassStyles_Win'>" QStyleTitle("Class Styles", "", 8, StyleBits) "</span>" _T2 _PRE1 RetClass _PRE2

	Return Res
}

QStyleTitle(Title, Name, F, V) {
	If Name !=
		Return " ( " Title " - <span name='MS:' style='color: #" ColorParam ";'>" Name "</span>: <span name='MS:' style='color: #" ColorFont ";'>" Format("0x{:0" F "X}", V) "</span> ) " 
	Return " ( " Title ": <span name='MS:' style='color: #" ColorFont ";'>" Format("0x{:0" F "X}", V) "</span> ) "  
}
QStyleRest(F, V) {
	Return "<span style='color: #" ColorDelimiter ";' name='MS:'>" Format("0x{1:0" F "X}", V) "</span>`n"
}
QStyle(k, v, q = "") {
	Return "<span name='MS:Q'>" k " := <span class='param' name='MS:'>" v "</span></span>" . (q != "" ? _StIf q "</span>`n" : "`n")
}
	; ___________________________ ControlStyles _________________________________________________

/*
	Added:
	Button, Edit, Static, SysListView32, SysTabControl32, SysDateTimePick32, SysMonthCal32, ComboBox, ListBox
	, msctls_trackbar32, msctls_statusbar32, msctls_progress32, msctls_updown32, SysLink, SysHeader32
	, ToolbarWindow32, SysTreeView32, ReBarWindow32, SysAnimate32, SysPager, #32770, tooltips_class32
*/  
	
GetStyle_#32770(Style, hWnd)  {
	;;	https://docs.microsoft.com/en-us/windows/desktop/dlgbox/dialog-box-styles
	Static oStyles
	If !oStyles
		oStyles := {"DS_3DLOOK":"0x00000004","DS_ABSALIGN":"0x00000001","DS_CENTER":"0x00000800","DS_CENTERMOUSE":"0x00001000","DS_CONTEXTHELP":"0x00002000"
		,"DS_CONTROL":"0x00000400","DS_FIXEDSYS":"0x00000008","DS_LOCALEDIT":"0x00000020","DS_MODALFRAME":"0x00000080","DS_NOFAILCREATE":"0x00000010"
		,"DS_NOIDLEMSG":"0x00000100","DS_SETFONT":"0x00000040","DS_SETFOREGROUND":"0x00000200","DS_SHELLFONT":"0x00000048","DS_SYSMODAL":"0x00000002"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)   
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "#32770", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}


GetStyle_tooltips_class32(Style, hWnd)  {
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/tooltip-styles
	Static oStyles
	If !oStyles
		oStyles := {"TTS_ALWAYSTIP":"0x00000001","TTS_BALLOON":"0x00000040","TTS_CLOSE":"0x00000080","TTS_NOANIMATE":"0x00000010","TTS_NOFADE":"0x00000020"
		,"TTS_NOPREFIX":"0x00000002","TTS_USEVISUALSTYLE":"0x00000100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)   
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "tooltips_class32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}



GetStyle_Static(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25869#p25869
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/static-control-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"SS_ELLIPSISMASK":"0xC000"
		,"SS_REALSIZECONTROL":"0x0040","SS_NOPREFIX":"0x0080","SS_NOTIFY":"0x0100","SS_CENTERIMAGE":"0x0200","SS_RIGHTJUST":"0x0400"
		,"SS_REALSIZEIMAGE":"0x0800","SS_SUNKEN":"0x1000","SS_EDITCONTROL":"0x2000","SS_ENDELLIPSIS":"0x4000","SS_PATHELLIPSIS":"0x8000"
		,"SS_WORDELLIPSIS":"0xC000"}

		, oEx := {"SS_CENTER":"0x0001","SS_RIGHT":"0x0002","SS_ICON":"0x0003","SS_BLACKRECT":"0x0004"
		,"SS_GRAYRECT":"0x0005","SS_WHITERECT":"0x0006","SS_BLACKFRAME":"0x0007","SS_GRAYFRAME":"0x0008","SS_WHITEFRAME":"0x0009"
		,"SS_USERITEM":"0x000A","SS_SIMPLE":"0x000B","SS_LEFTNOWORDWRAP":"0x000C","SS_OWNERDRAW":"0x000D","SS_BITMAP":"0x000E"
		,"SS_ENHMETAFILE":"0x000F","SS_ETCHEDHORZ":"0x0010","SS_ETCHEDVERT":"0x0011","SS_ETCHEDFRAME":"0x0012","SS_TYPEMASK":"0x001F"}

	Style := sStyle := Style & 0xffff
	For K, V In oEx
		If ((Style & 0x1F) = V) && (%K% := 1, Style -= V)
		{ 
			Ret .= QStyle(K, V)
			Break
		}
	For K, V In oStyles
		If Style && ((Style & V) = V) && (%K% := 1, Style -= V) 
			Ret .= QStyle(K, V)
	IF !SS_CENTER && !SS_RIGHT  ;;	SS_LEFT
		Ret .= QStyle("SS_LEFT", "0x0000", "!(SS_CENTER | SS_RIGHT)")
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Static", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_Button(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25841#p25841
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/button-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"BS_ICON":"0x0040","BS_BITMAP":"0x0080","BS_LEFT":"0x0100","BS_RIGHT":"0x0200","BS_CENTER":"0x0300"
		,"BS_TOP":"0x0400","BS_BOTTOM":"0x0800","BS_VCENTER":"0x0C00","BS_PUSHLIKE":"0x1000","BS_MULTILINE":"0x2000"
		,"BS_NOTIFY":"0x4000","BS_FLAT":"0x8000"}

		, oEx := {"BS_DEFPUSHBUTTON":"0x0001","BS_CHECKBOX":"0x0002","BS_AUTOCHECKBOX":"0x0003"
		,"BS_RADIOBUTTON":"0x0004","BS_3STATE":"0x0005","BS_AUTO3STATE":"0x0006","BS_GROUPBOX":"0x0007","BS_USERBUTTON":"0x0008"
		,"BS_AUTORADIOBUTTON":"0x0009","BS_PUSHBOX":"0x000A","BS_OWNERDRAW":"0x000B","BS_COMMANDLINK":"0x000E"
		,"BS_DEFCOMMANDLINK":"0x000F","BS_SPLITBUTTON":"0x000C","BS_DEFSPLITBUTTON":"0x000D","BS_PUSHBUTTON":"0x0000","BS_TEXT":"0x0000"}
		  ;; "BS_TYPEMASK":"0x000F"

	Style := sStyle := Style & 0xffff
	For K, V In oEx
		If ((Style & 0xF) = V) && (%K% := 1, Style -= V)
		{
			Ret .= QStyle(K, V)
			Break
		}
	If ((Style & 0x0020) = 0x0020)  ;;	BS_LEFTTEXT  ;;	BS_RIGHTBUTTON
		Ret .= QStyle("BS_LEFTTEXT := BS_RIGHTBUTTON", "0x0020")

	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !BS_ICON && !BS_BITMAP && !BS_AUTOCHECKBOX && !BS_AUTORADIOBUTTON && !BS_CHECKBOX && !BS_RADIOBUTTON  ;;	BS_TEXT
		Ret .= QStyle("BS_TEXT", "0x0000", "!(BS_ICON | BS_BITMAP | BS_AUTOCHECKBOX | BS_AUTORADIOBUTTON | BS_CHECKBOX | BS_RADIOBUTTON)")

	IF !BS_DEFPUSHBUTTON && !BS_CHECKBOX && !BS_AUTOCHECKBOX && !BS_RADIOBUTTON && !BS_GROUPBOX && !BS_AUTORADIOBUTTON  ;;	BS_PUSHBUTTON
		Ret .= QStyle("BS_PUSHBUTTON", "0x0000", "!(BS_DEFPUSHBUTTON | BS_CHECKBOX | BS_AUTOCHECKBOX | BS_RADIOBUTTON | BS_GROUPBOX | BS_AUTORADIOBUTTON)")

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Button", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_Edit(Style, hWnd, byref ResEx)  {
	; https://www.autohotkey.com/boards/viewtopic.php?p=25848#p25848
	; https://docs.microsoft.com/en-us/windows/desktop/controls/edit-control-styles
	; https://docs.microsoft.com/en-us/windows/win32/controls/edit-control-window-extended-styles
	; https://docs.microsoft.com/en-us/windows/win32/controls/em-setextendedstyle
	Static oStyles, oExStyles, EM_GETEXTENDEDSTYLE := 0x1500 + 11
	If !oStyles
		oStyles := {"ES_CENTER":"0x0001","ES_RIGHT":"0x0002","ES_MULTILINE":"0x0004"
		,"ES_UPPERCASE":"0x0008","ES_LOWERCASE":"0x0010","ES_PASSWORD":"0x0020","ES_AUTOVSCROLL":"0x0040"
		,"ES_AUTOHSCROLL":"0x0080","ES_NOHIDESEL":"0x0100","ES_OEMCONVERT":"0x0400","ES_READONLY":"0x0800"
		,"ES_WANTRETURN":"0x1000","ES_NUMBER":"0x2000"}
		
		, oExStyles := {"ES_EX_ALLOWEOL_CR":"0x0001","ES_EX_ALLOWEOL_LF":"0x0002"
		,"ES_EX_CONVERT_EOL_ON_PASTE":"0x0004","ES_EX_ZOOMABLE":"0x0010"}

	SendMessage, EM_GETEXTENDEDSTYLE, 0, 0, , ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	
	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !ES_CENTER && !ES_RIGHT  ;;	ES_LEFT
		Ret .= QStyle("ES_LEFT", "0x0000", "!(ES_CENTER | ES_RIGHT)")

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Edit", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2

	IF ExStyle
	{ 
		For K, V In oExStyles
			If ((ExStyle & V) = V) && (%K% := 1, ExStyle -= V)
				RetEx .= QStyle(K, V)  
		
		If (sExStyle & 3)
			RetEx .= QStyle("ES_EX_ALLOWEOL_ALL", "0x0003", "(ES_EX_ALLOWEOL_CR && ES_EX_ALLOWEOL_LF)")  
		IF ExStyle
			RetEx .= QStyleRest(4, ExStyle)
		
		If RetEx !=
			ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "Edit", 4, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	} 
	
	Return Res
}

GetStyle_ComboLBox(Style, hWnd)  {
	Return GetStyle_ListBox(Style, hWnd)
}

GetStyle_ListBox(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25855#p25855
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/list-box-styles
	Static oStyles
	If !oStyles
		oStyles := {"LBS_NOTIFY":"0x0001","LBS_SORT":"0x0002","LBS_NOREDRAW":"0x0004","LBS_MULTIPLESEL":"0x0008"
		,"LBS_OWNERDRAWFIXED":"0x0010","LBS_OWNERDRAWVARIABLE":"0x0020","LBS_HASSTRINGS":"0x0040"
		,"LBS_USETABSTOPS":"0x0080","LBS_NOINTEGRALHEIGHT":"0x0100","LBS_MULTICOLUMN":"0x0200"
		,"LBS_WANTKEYBOARDINPUT":"0x0400","LBS_EXTENDEDSEL":"0x0800","LBS_DISABLENOSCROLL":"0x1000","LBS_NODATA":"0x2000"
		,"LBS_NOSEL":"0x4000","LBS_COMBOBOX":"0x8000"}
		, WS_VSCROLL := 0x200000, WS_BORDER := 0x800000

	wStyle := Style, Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 

	IF LBS_NOTIFY && LBS_SORT && (wStyle & WS_VSCROLL) && (wStyle & WS_BORDER) && (1, Style -= 0x0003)  ;;	LBS_STANDARD 
		Ret .= QStyle("LBS_STANDARD", "0xA00003", "(LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER)")

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ListBox", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysAnimate32(Style, hWnd)  {
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/animation-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"ACS_CENTER":"0x0001","ACS_TRANSPARENT":"0x0002","ACS_AUTOPLAY":"0x0004","ACS_TIMER":"0x0008"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)  
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysAnimate32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysPager(Style, hWnd)  {
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/pager-control-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"PGS_HORZ":"0x0001","PGS_AUTOSCROLL":"0x0002","PGS_DRAGNDROP":"0x0004"}
		, oEx := {"PGS_VERT":"0x0000"}
	Style := sStyle := Style & 0xffff
	If !(Style & oStyles.PGS_HORZ)
		Ret .= "<span name='MS:'>PGS_VERT := <span class='param' name='MS:'>0x0000   !(PGS_HORZ)</span></span>`n"
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysPager", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_updown32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25878#p25878
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/up-down-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"UDS_WRAP":"0x0001","UDS_SETBUDDYINT":"0x0002","UDS_ALIGNRIGHT":"0x0004","UDS_ALIGNLEFT":"0x0008"
		,"UDS_AUTOBUDDY":"0x0010","UDS_ARROWKEYS":"0x0020","UDS_HORZ":"0x0040","UDS_NOTHOUSANDS":"0x0080","UDS_HOTTRACK":"0x0100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V) 
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_updown32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysDateTimePick32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25878#p25878
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/date-and-time-picker-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"DTS_UPDOWN":"0x0001","DTS_SHOWNONE":"0x0002","DTS_LONGDATEFORMAT":"0x0004","DTS_TIMEFORMAT":"0x0009"
			,"DTS_SHORTDATECENTURYFORMAT":"0x000C","DTS_APPCANPARSE":"0x0010","DTS_RIGHTALIGN":"0x0020"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 
	IF !DTS_LONGDATEFORMAT  ;;	DTS_SHORTDATEFORMAT
		Ret .= QStyle("DTS_SHORTDATEFORMAT", "0x0000", "!(DTS_LONGDATEFORMAT)")

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysDateTimePick32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysMonthCal32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25861#p25861
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/month-calendar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"MCS_DAYSTATE":"0x0001","MCS_MULTISELECT":"0x0002","MCS_WEEKNUMBERS":"0x0004","MCS_NOTODAYCIRCLE":"0x0008"
		,"MCS_NOTODAY":"0x0010","MCS_NOTRAILINGDATES":"0x0040","MCS_SHORTDAYSOFWEEK":"0x0080","MCS_NOSELCHANGEONNAV":"0x0100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysMonthCal32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_trackbar32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25875#p25875
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/trackbar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"TBS_AUTOTICKS":"0x0001","TBS_VERT":"0x0002"
		,"TBS_BOTH":"0x0008","TBS_NOTICKS":"0x0010","TBS_ENABLESELRANGE":"0x0020"
		,"TBS_FIXEDLENGTH":"0x0040","TBS_NOTHUMB":"0x0080","TBS_TOOLTIPS":"0x0100","TBS_REVERSED":"0x0200"
		,"TBS_DOWNISLEFT":"0x0400","TBS_NOTIFYBEFOREMOVE":"0x0800","TBS_TRANSPARENTBKGND":"0x1000"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !TBS_VERT
	{
		Ret .= QStyle("TBS_HORZ", "0x0000", "!(TBS_VERT)")  ;;	TBS_HORZ
		IF ((Style & 0x0004) = 0x0004) && (1, Style -= 0x0004)  ;;	TBS_TOP 
			Ret .= QStyle("TBS_TOP", "0x0004", "(TBS_HORZ)")
		IF !TBS_TOP  ;;	TBS_BOTTOM 
			Ret .= QStyle("TBS_BOTTOM", "0x0000", "!(TBS_TOP) && (TBS_HORZ)")
	}
	Else
	{
		IF ((Style & 0x0004) = 0x0004) && (TBS_LEFT := 1, Style -= 0x0004)  ;;	TBS_LEFT
			Ret .= QStyle("TBS_LEFT", "0x0004", "(TBS_VERT)")

		IF !TBS_LEFT  ;;	TBS_RIGHT 
			Ret .= QStyle("TBS_RIGHT", "0x0000", "!(TBS_LEFT) && (TBS_VERT)")
	}
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_trackbar32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_statusbar32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25870#p25870
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/status-bar-styles
	Static oStyles
	If !oStyles
		oStyles := {"SBARS_SIZEGRIP":"0x0100","SBARS_TOOLTIPS":"0x0800"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_statusbar32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_progress32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25864#p25864
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/progress-bar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"PBS_SMOOTH":"0x0001","PBS_VERTICAL":"0x0004","PBS_MARQUEE":"0x0008","PBS_SMOOTHREVERSE":"0x0010"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V) 
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_progress32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysHeader32(Style, hWnd)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25850#p25850
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/header-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"HDS_BUTTONS":"0x0002","HDS_CHECKBOXES":"0x0400","HDS_DRAGDROP":"0x0040","HDS_FILTERBAR":"0x0100","HDS_FLAT":"0x0200"
		,"HDS_FULLDRAG":"0x0080","HDS_HIDDEN":"0x0008","HDS_HORZ":"0x0000","HDS_HOTTRACK":"0x0004","HDS_NOSIZING":"0x0800","HDS_OVERFLOW":"0x1000"}

	;; Style := DllCall("GetWindowLong", "Ptr", hWnd, "int", GWL_STYLE := -16)

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysHeader32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysLink(Style, hWnd) {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25859#p25859
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/syslink-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"LWS_IGNORERETURN":"0x0002","LWS_NOPREFIX":"0x0004","LWS_RIGHT":"0x0020"
		,"LWS_TRANSPARENT":"0x0001","LWS_USECUSTOMTEXT":"0x0010","LWS_USEVISUALSTYLE":"0x0008"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysLink", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_ReBarWindow32(Style, hWnd) {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25865#p25865
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/rebar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"RBS_AUTOSIZE":"0x2000","RBS_BANDBORDERS":"0x0400","RBS_DBLCLKTOGGLE":"0x8000","RBS_FIXEDORDER":"0x0800"
		,"RBS_REGISTERDROP":"0x1000","RBS_TOOLTIPS":"0x0100","RBS_VARHEIGHT":"0x0200","RBS_VERTICALGRIPPER":"0x4000"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ReBarWindow32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	Return Res
}

GetStyle_CommonControl(Style, ByRef NewStyle) {   ;;	Остаток от стилей контролов
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25846#p25846
	Static oStyles, oEx
	If !oStyles
		oStyles := {"CCS_ADJUSTABLE":"0x0020","CCS_BOTTOM":"0x0003","CCS_NODIVIDER":"0x0040","CCS_NOMOVEY":"0x0002"
		,"CCS_NOPARENTALIGN":"0x0008","CCS_NORESIZE":"0x0004","CCS_TOP":"0x0001","CCS_VERT":"0x0080"}

		,oEx := {"CCS_LEFT":"0x0081","CCS_NOMOVEX":"0x0082","CCS_RIGHT":"0x0083"}

	NewStyle := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((NewStyle & V) = V) && (%K% := 1, NewStyle -= V)
			Ret .= QStyle(K, V)
	IF !CCS_VERT && !CCS_TOP && (NewStyle & oEx.CCS_LEFT) && (1, NewStyle -= oEx.CCS_LEFT)  ;;	CCS_LEFT
		Ret .= QStyle("CCS_LEFT", "0x0081", "!(CCS_VERT | CCS_TOP)")
	IF !CCS_VERT && !CCS_NOMOVEY && (NewStyle & oEx.CCS_NOMOVEX) && (1, NewStyle -= oEx.CCS_NOMOVEX)  ;;	CCS_NOMOVEX
		Ret .= QStyle("CCS_NOMOVEX", "0x0082", "!(CCS_VERT | CCS_NOMOVEY)") 
	IF !CCS_VERT && !CCS_BOTTOM && (NewStyle & oEx.CCS_RIGHT) && (1, NewStyle -= oEx.CCS_RIGHT)  ;;	CCS_RIGHT
		Ret .= QStyle("CCS_RIGHT", "0x0083", "!(CCS_VERT | CCS_BOTTOM)") 
	Return Ret
}




GetStyle_SysListView32(Style, hWnd, byref ResEx)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25857#p25857
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/list-view-window-styles
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/extended-list-view-styles
	Static oStyles, oExStyles, oEx, LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037
	If !oStyles
		oStyles := {"LVS_AUTOARRANGE":"0x0100","LVS_EDITLABELS":"0x0200"
		,"LVS_NOLABELWRAP":"0x0080","LVS_NOSCROLL":"0x2000"
		,"LVS_OWNERDRAWFIXED":"0x0400","LVS_SHAREIMAGELISTS":"0x0040","LVS_SHOWSELALWAYS":"0x0008","LVS_SINGLESEL":"0x0004"
		,"LVS_OWNERDATA":"0x1000","LVS_SORTASCENDING":"0x0010","LVS_SORTDESCENDING":"0x0020"}

		, oExStyles := {"LVS_EX_AUTOAUTOARRANGE":"0x01000000","LVS_EX_AUTOCHECKSELECT":"0x08000000","LVS_EX_AUTOSIZECOLUMNS":"0x10000000"
		,"LVS_EX_BORDERSELECT":"0x00008000","LVS_EX_CHECKBOXES":"0x00000004","LVS_EX_COLUMNOVERFLOW":"0x80000000","LVS_EX_COLUMNSNAPPOINTS":"0x40000000"
		,"LVS_EX_DOUBLEBUFFER":"0x00010000","LVS_EX_FLATSB":"0x00000100","LVS_EX_FULLROWSELECT":"0x00000020","LVS_EX_GRIDLINES":"0x00000001"
		,"LVS_EX_HEADERDRAGDROP":"0x00000010","LVS_EX_HEADERINALLVIEWS":"0x02000000","LVS_EX_HIDELABELS":"0x00020000"
		,"LVS_EX_INFOTIP":"0x00000400","LVS_EX_JUSTIFYCOLUMNS":"0x00200000","LVS_EX_LABELTIP":"0x00004000","LVS_EX_MULTIWORKAREAS":"0x00002000"
		,"LVS_EX_ONECLICKACTIVATE":"0x00000040","LVS_EX_REGIONAL":"0x00000200","LVS_EX_SIMPLESELECT":"0x00100000","LVS_EX_SINGLEROW":"0x00040000"
		,"LVS_EX_SNAPTOGRID":"0x00080000","LVS_EX_SUBITEMIMAGES":"0x00000002","LVS_EX_TRACKSELECT":"0x00000008","LVS_EX_TRANSPARENTBKGND":"0x00400000"
		,"LVS_EX_TRANSPARENTSHADOWTEXT":"0x00800000","LVS_EX_TWOCLICKACTIVATE":"0x00000080"
		,"LVS_EX_UNDERLINECOLD":"0x00001000","LVS_EX_UNDERLINEHOT":"0x00000800"}

		,oEx := {"LVS_TYPEMASK":"0x0003","LVS_ICON":"0x0000","LVS_REPORT":"0x0001","LVS_SMALLICON":"0x0002","LVS_LIST":"0x0003"
		,"LVS_ALIGNMASK":"0x0C00","LVS_ALIGNTOP":"0x0000","LVS_ALIGNLEFT":"0x0800"
		,"LVS_TYPESTYLEMASK":"0xFC00","LVS_NOSORTHEADER":"0x8000","LVS_NOCOLUMNHEADER":"0x4000"}

	SendMessage, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((sStyle & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 

	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_REPORT) && (LVS_REPORT := 1, Style -= oEx.LVS_REPORT)      ;;	LVS_REPORT 
		Ret .= QStyle("LVS_REPORT", "0x0001", "(LVS_TYPEMASK = 0x0001)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_SMALLICON) && (LVS_SMALLICON := 1, Style -= oEx.LVS_SMALLICON)      ;;	LVS_SMALLICON
		Ret .= QStyle("LVS_SMALLICON", "0x0002", "(LVS_TYPEMASK = 0x0002)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_LIST) && (LVS_LIST := 1, Style -= oEx.LVS_LIST)      ;;	LVS_LIST
		Ret .= QStyle("LVS_LIST", "0x0003", "(LVS_TYPEMASK = 0x0003)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_ICON) && !LVS_REPORT && !LVS_SMALLICON && !LVS_LIST && (LVS_ICON := 1)      ;;	LVS_ICON
		Ret .= QStyle("LVS_ICON", "0x0000", "!(LVS_REPORT | LVS_SMALLICON | LVS_LIST)")
	IF ((sStyle & oEx.LVS_ALIGNMASK) = oEx.LVS_ALIGNLEFT) && (LVS_ALIGNLEFT := 1, Style -= oEx.LVS_ALIGNLEFT)      ;;	LVS_ALIGNLEFT
		Ret .= QStyle("LVS_ALIGNLEFT", "0x0800", "(LVS_ALIGNMASK = 0x0800)")
	IF ((sStyle & oEx.LVS_ALIGNMASK) = oEx.LVS_ALIGNTOP) && (LVS_SMALLICON || LVS_ICON) && (LVS_ALIGNTOP := 1, Style -= oEx.LVS_ALIGNTOP)      ;;	LVS_ALIGNTOP
		Ret .= QStyle("LVS_ALIGNTOP", "0x0000", "(LVS_SMALLICON || LVS_ICON)")
	IF ((sStyle & oEx.LVS_NOSORTHEADER) = oEx.LVS_NOSORTHEADER) && (LVS_NOSORTHEADER := 1, Style -= oEx.LVS_NOSORTHEADER)      ;;	LVS_NOSORTHEADER
		Ret .= QStyle("LVS_NOSORTHEADER", "0x8000", "(LVS_TYPEMASK = 0x0003)")
	IF ((sStyle & oEx.LVS_NOCOLUMNHEADER) = oEx.LVS_NOCOLUMNHEADER) && (LVS_NOCOLUMNHEADER := 1, Style -= oEx.LVS_NOCOLUMNHEADER)      ;;	LVS_NOCOLUMNHEADER
		Ret .= QStyle("LVS_NOCOLUMNHEADER", "0x4000")

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysListView32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (%K% := 1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysListView32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	 
	 Return Res
}

GetStyle_SysTreeView32(Style, hWnd, byref ResEx)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25876#p25876
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/tree-view-control-window-styles
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/tree-view-control-window-extended-styles
	Static oStyles, oExStyles, TVM_GETEXTENDEDSTYLE := 0x112D
	If !oStyles
		oStyles := {"TVS_CHECKBOXES":"0x0100","TVS_DISABLEDRAGDROP":"0x0010","TVS_EDITLABELS":"0x0008","TVS_FULLROWSELECT":"0x1000","TVS_HASBUTTONS":"0x0001"
		,"TVS_HASLINES":"0x0002","TVS_INFOTIP":"0x0800","TVS_LINESATROOT":"0x0004","TVS_NOHSCROLL":"0x8000","TVS_NONEVENHEIGHT":"0x4000","TVS_NOSCROLL":"0x2000"
		,"TVS_NOTOOLTIPS":"0x0080","TVS_RTLREADING":"0x0040","TVS_SHOWSELALWAYS":"0x0020","TVS_SINGLEEXPAND":"0x0400","TVS_TRACKSELECT":"0x0200"}

		, oExStyles := {"TVS_EX_AUTOHSCROLL":"0x0020","TVS_EX_DIMMEDCHECKBOXES":"0x0200","TVS_EX_DOUBLEBUFFER":"0x0004","TVS_EX_DRAWIMAGEASYNC":"0x0400"
		,"TVS_EX_EXCLUSIONCHECKBOXES":"0x0100","TVS_EX_FADEINOUTEXPANDOS":"0x0040","TVS_EX_MULTISELECT":"0x0002","TVS_EX_NOINDENTSTATE":"0x0008"
		,"TVS_EX_NOSINGLECOLLAPSE":"0x0001","TVS_EX_PARTIALCHECKBOXES":"0x0080","TVS_EX_RICHTOOLTIP":"0x0010"}

	SendMessage, TVM_GETEXTENDEDSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((sStyle & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysTreeView32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysTreeView32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	
	Return Res
}

GetStyle_SysTabControl32(Style, hWnd, byref ResEx)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25871#p25871
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/tab-control-styles
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/tab-control-extended-styles
	Static oStyles, TCM_GETEXTENDEDSTYLE := 0x1335
	If !oStyles
		oStyles := {"TCS_SCROLLOPPOSITE":"0x0001","TCS_MULTISELECT":"0x0004","TCS_FLATBUTTONS":"0x0008"
		,"TCS_FORCELABELLEFT":"0x0020","TCS_HOTTRACK":"0x0040","TCS_BUTTONS":"0x0100","TCS_MULTILINE":"0x0200"
		,"TCS_FORCEICONLEFT":"0x0010","TCS_FIXEDWIDTH":"0x0400","TCS_RAGGEDRIGHT":"0x0800","TCS_FOCUSONBUTTONDOWN":"0x1000"
		,"TCS_OWNERDRAWFIXED":"0x2000","TCS_TOOLTIPS":"0x4000","TCS_FOCUSNEVER":"0x8000"}

	SendMessage, TCM_GETEXTENDEDSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !TCS_BUTTONS   ;;	TCS_TABS
		Ret .= QStyle("TCS_TABS", "0x0000", "!(TCS_BUTTONS)")
	IF !TCS_MULTILINE   ;;	TCS_SINGLELINE
		Ret .= QStyle("TCS_SINGLELINE", "0x0000", "!(TCS_MULTILINE)")
	IF TCS_MULTILINE   ;;	TCS_RIGHTJUSTIFY
		Ret .= QStyle("TCS_RIGHTJUSTIFY", "0x0000", "(TCS_MULTILINE)")
	IF TCS_MULTILINE && ((Style & 0x0080) = 0x0080) && (TCS_VERTICAL := 1, Style -= 0x0080)  ;;	"TCS_VERTICAL":"0x0080"
		Ret .= QStyle("TCS_VERTICAL", "0x0080", "(TCS_MULTILINE)")
	IF ((Style & 0x0002) = 0x0002) && (1, Style -= 0x0002)   ;;	"TCS_BOTTOM":"0x0002","TCS_RIGHT":"0x0002"
	{
		IF TCS_VERTICAL
			Ret .= QStyle("TCS_RIGHT", "0x0002", "(TCS_VERTICAL)")
		Else
			Ret .= QStyle("TCS_BOTTOM", "0x0002", "!(TCS_VERTICAL)")
	}
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysTabControl32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
 
	If ((ExStyle & 0x00000001) = 0x00000001) && (1, ExStyle -= 0x00000001)  ;;	TCS_EX_FLATSEPARATORS
		RetEx .= QStyle("TCS_EX_FLATSEPARATORS", "0x00000001")
	If ((ExStyle & 0x00000002) = 0x00000002) && (1, ExStyle -= 0x00000002)  ;;	TCS_EX_REGISTERDROP
		RetEx .= QStyle("TCS_EX_REGISTERDROP", "0x00000002")

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysTabControl32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	
	Return Res
}

GetStyle_ComboBox(Style, hWnd, byref ResEx)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25842#p25842
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/combo-box-styles
	Static oStyles, oExStyles, oEx, CBEM_GETEXTENDEDSTYLE := 0x0409
	If !oStyles
		oStyles := {"CBS_SIMPLE":"0x0001","CBS_DROPDOWN":"0x0002","CBS_OWNERDRAWFIXED":"0x0010"
		,"CBS_OWNERDRAWVARIABLE":"0x0020","CBS_AUTOHSCROLL":"0x0040","CBS_OEMCONVERT":"0x0080","CBS_SORT":"0x0100"
		,"CBS_HASSTRINGS":"0x0200","CBS_NOINTEGRALHEIGHT":"0x0400","CBS_DISABLENOSCROLL":"0x0800"
		,"CBS_UPPERCASE":"0x2000","CBS_LOWERCASE":"0x4000"}
		, oEx := {"CBS_DROPDOWNLIST":"0x0003"}
		, oExStyles := {"CBES_EX_CASESENSITIVE":"0x0010","CBES_EX_NOEDITIMAGE":"0x0001","CBES_EX_NOEDITIMAGEINDENT":"0x0002"
		,"CBES_EX_NOSIZELIMIT":"0x0008","CBES_EX_PATHWORDBREAKPROC":"0x0004","CBES_EX_TEXTENDELLIPSIS":"0x0020"}
	
	If (hParent := DllCall("GetParent", "Ptr", hWnd))
	{
		WinGetClass, ParentClass, ahk_id %hParent%
		If ParentClass = ComboBoxEx32
		{
			SendMessage, CBEM_GETEXTENDEDSTYLE, 0, 0, , ahk_id %hParent%
			ExStyle := sExStyle := ErrorLevel
			For K, V In oExStyles
				If ((ExStyle & V) = V) && (1, ExStyle -= V) 
					RetEx .= QStyle(K, V)
			IF ExStyle
				RetEx .= QStyleRest(4, ExStyle) 
		} 
	}
	Style := sStyle := Style & 0xffff
	If ((Style & oEx.CBS_DROPDOWNLIST) = oEx.CBS_DROPDOWNLIST) && (1, Style -= oEx.CBS_DROPDOWNLIST)  ;;	CBS_DROPDOWNLIST
		Ret .= QStyle("CBS_DROPDOWNLIST", oEx.CBS_DROPDOWNLIST)
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ComboBox", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2 
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "ComboBoxEx32", 4, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	Return Res
}

GetStyle_ToolbarWindow32(Style, hWnd, byref ResEx)  {
	;;	https://www.autohotkey.com/boards/viewtopic.php?p=25872#p25872
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-control-and-button-styles
	;;	https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-extended-styles
	;;	https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-_tbbutton
	Static oStyles, oExStyles, TB_GETSTYLE := 0x0439, TB_GETEXTENDEDSTYLE := 0x0455
	If !oStyles
		oStyles := {"TBSTYLE_ALTDRAG":"0x0400","TBSTYLE_CUSTOMERASE":"0x2000","TBSTYLE_FLAT":"0x0800","TBSTYLE_LIST":"0x1000"
		,"TBSTYLE_REGISTERDROP":"0x4000","TBSTYLE_TOOLTIPS":"0x0100","TBSTYLE_TRANSPARENT":"0x8000","TBSTYLE_WRAPABLE":"0x0200"}

		, oExStyles := {"TBSTYLE_EX_DOUBLEBUFFER":"0x80","TBSTYLE_EX_DRAWDDARROWS":"0x01","TBSTYLE_EX_HIDECLIPPEDBUTTONS":"0x10"
		,"TBSTYLE_EX_MIXEDBUTTONS":"0x08","TBSTYLE_EX_MULTICOLUMN":"0x02","TBSTYLE_EX_VERTICAL":"0x04"}

	SendMessage, TB_GETSTYLE, 0, 0, , ahk_id %hWnd%
	Style := sStyle := ErrorLevel & 0xffff

	SendMessage, TB_GETEXTENDEDSTYLE, 0, 0, , ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel 
	
	For K, V In oStyles
		If ((sStyle & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)

	IF Style
		Ret .= GetStyle_CommonControl(Style, Style)
	IF Style
		Ret .= QStyleRest(8, Style)   
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ToolbarWindow32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(4, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "ToolbarWindow32", 4, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2 
		
	Return Res
	
/*
		oBTNS := {"BTNS_BUTTON":"0x00","BTNS_SEP":"0x01","BTNS_CHECK":"0x02","BTNS_GROUP":"0x04","BTNS_CHECKGROUP":"0x06","BTNS_DROPDOWN":"0x08"
		,"BTNS_AUTOSIZE":"0x10","BTNS_NOPREFIX":"0x20","BTNS_SHOWTEXT":"0x40","BTNS_WHOLEDROPDOWN":"0x80"}

		VarSetCapacity(TBBUTTON, A_PtrSize == 8 ? 32 : 20, 0)

		iBitmap := NumGet(TBBUTTON, 0, "Int")
		idCommand := NumGet(TBBUTTON, 4, "Int")
		fsState := NumGet(TBBUTTON, 8, "UChar")
		fsStyle := NumGet(TBBUTTON, 9, "UChar")
		bReserved := NumGet(TBBUTTON, 10, "UChar")
		;;bReserved := NumGet(TBBUTTON, 10, "UChar")
		dwData := NumGet(TBBUTTON, A_PtrSize == 8 ? 16 : 12, "UPtr")
		iString := NumGet(TBBUTTON, A_PtrSize == 8 ? 24 : 16, "Ptr")
*/
}

	; ___________________________ FullScreen _________________________________________________

FullScreenMode() {
	Static Max, hFunc
	hwnd := WinExist("ahk_id" hGui)
	If !FullScreenMode
	{
		FullScreenMode := 1
		Menu, Sys, Check, Full screen
		WinGetNormalPos(hwnd, X, Y, W, H)
		WinGet, Max, MinMax, ahk_id %hwnd%
		If Max = 1
			WinSet, Style, -0x01000000	;;	WS_MAXIMIZE
		Gui, 1: -ReSize -Caption
		Gui, 1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
		Gui, 1: Maximize
		WinSetNormalPos(hwnd, X, Y, W, H)
		hFunc := Func("ControlsMove").Bind(A_ScreenWidth, A_ScreenHeight)
	}
	Else
	{
		Gui, 1: +ReSize +Caption
		If Max = 1
		{
			WinGetNormalPos(hwnd, X, Y, W, H)
			Gui, 1: Maximize
			WinSetNormalPos(hwnd, X, Y, W, H)
		}
		Else
			Gui, 1: Restore
		Sleep 20
		GetClientPos(hwnd, _, _, Width, Height)
		hFunc := Func("ControlsMove").Bind(Width, Height)
		FullScreenMode := 0
		Menu, Sys, UnCheck, Full screen
	}
	SetTimer, % hFunc, -10
}

WinGetNormalPos(hwnd, ByRef x, ByRef y, ByRef w, ByRef h) {
	VarSetCapacity(wp, 44), NumPut(44, wp)
	DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	w := NumGet(wp, 36, "int") - x,  h := NumGet(wp, 40, "int") - y
}

WinSetNormalPos(hwnd, x, y, w, h) {
	VarSetCapacity(wp, 44, 0), NumPut(44, wp, 0, "uint")
	DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &wp)
	NumPut(x, wp, 28, "int"), NumPut(y, wp, 32, "int")
	NumPut(w + x, wp, 36, "int"), NumPut(h + y, wp, 40, "int")
	DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &wp)
}

	; ___________________________ Find _________________________________________________

_FindView() {
	If isFindView
		Return FindHide(), AnchorFitScroll()
	GuiControlGet, p, 1:Pos, %hActiveX%
	GuiControl, 1:Move, %hActiveX%, % "x" pX " y" pY " w" pW " h" pH - 28
	Gui, F: Show, % "NA x" (pW - widthTB) // 2.2 " h26 y" (pY + pH - 27)
	isFindView := 1
	GuiControl, F:Focus, Edit1
	Menu, Sys, Check, Find to page
	FindSearch(1) 
	AnchorFitScroll()
}

FindHide() {
	Gui, F: Show, Hide
	GuiControlGet, a, 1:Pos, %hActiveX%
	GuiControl, 1:Move, %hActiveX%, % "x" aX "y" aY "w" aW "h" aH + 28
	isFindView := 0
	GuiControl, Focus, %hActiveX%
	Menu, Sys, UnCheck, Find to page
}

FindOption(Hwnd) {
	GuiControlGet, p, Pos, %Hwnd%
	If pX =
		Return
	ControlGet, Style, Style,, , ahk_id %Hwnd%
	ControlGetText, Text, , ahk_id %Hwnd%
	DllCall("DestroyWindow", "Ptr", Hwnd)
	; BS_PUSHLIKE := 0x1000
	Gui, %A_Gui%: Add, Text, % "x" pX " y" pY " w" pW " h" pH " g" A_ThisFunc " c" ColorFont " " (Style & 0x1000 ? "+0x0201" : "+Border +0x1201"), % Text
	InStr(Text, "sensitive") ? (oFind.Registr := !(Style & 0x1000)) : (oFind.Whole := !(Style & 0x1000))
	FindSearch(1)
	FindAll()
}

FindNew(Hwnd) {
	ControlGetText, Text, , ahk_id %Hwnd%
	oFind.Text := Text
	hFunc := Func("FindSearch").Bind(1)
	SetTimer, FindAll, -150
	SetTimer, % hFunc, -150
}

FindNewText() {
	hFunc := Func("FindSearch").Bind(1)
	SetTimer, % hFunc, -1
	SetTimer, FindAll, -150
}

FindNext(Hwnd) {
	SendMessage, 0x400+114,,,, ahk_id %Hwnd%		;;  UDM_GETPOS32
	Back := !ErrorLevel
	FindSearch(0, Back)
}

FindAll() {
	If (oFind.Text = "")
	{
		GuiControl, F:Text, FindMatches
		Return
	}
	R := oBody.createTextRange()
	Matches := 0
	R.collapse(1)
	Option := (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
	Loop
	{
		F := R.findText(oFind.Text, 1, Option)
		If (F = 0)
			Break
		El := R.parentElement()
		If (El.TagName = "INPUT" || El.className ~= "^(button|title|param)$") && !R.collapse(0)  ;;	https://msdn.microsoft.com/en-us/library/ff976065(v=vs.85).aspx
			Continue
		; R.execCommand("BackColor", 0, "EF0FFF")
		; R.execCommand("ForeColor", 0, "FFEEFF")
		R.collapse(0), ++Matches
	}
	GuiControl, F:Text, FindMatches, % Matches ? Matches : ""
}

FindSearch(New, Back = 0) {
	Global hFindEdit
	R := oDoc.selection.createRange()
	sR := R.duplicate()
	R.collapse(New || Back ? 1 : 0)
	If (oFind.Text = "" && !R.select()) 
		SetEditColor(hFindEdit, "0x" ColorBgOriginal, "0x" ColorFont)
	Else {
		Option := (Back ? 1 : 0) ^ (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
		Loop {
			F := R.findText(oFind.Text, 1, Option)
			If (F = 0) {
				If !A {
					R.moveToElementText(oBody), R.collapse(!Back), A := 1
					Continue
				}
				If New
					sR.collapse(1), sR.select()
				Break
			}
			If (!New && R.isEqual(sR)) {
				If A {
					hFunc := Func("SetEditColor").Bind(hFindEdit, "0x" ColorBgOriginal, "0x" ColorFont)
					SetTimer, % hFunc, -200
				}
				Break
			}
			El := R.parentElement()

			If (El.TagName = "INPUT" || El.className ~= "^(button|title|param)$") && !R.collapse(Back)
				Continue
			R.select(), F := 1
			Break
		}
		If (F != 1)
			SetEditColor(hFindEdit, "0x" ColorSelectedFind, "0x" ColorFont)
		Else
			SetEditColor(hFindEdit, "0x" ColorBgOriginal, "0x" ColorFont)
	}
}
	; ___________________________ Mouse hover selection _________________________________________________

MS_Cancel() {
	If !oMS.ELSel
		Return
	oMS.ELSel.style.backgroundColor := "" 
	oMS.ELSel.style.color := ""
	
	Loop % oMS.ELSel.all.length 
		oMS.ELSel.all[A_Index-1].style.color := ""
	oMS.ELSel := ""	
}

MS_SelectionCheck() {
	Selection := oDoc.selection.createRange().text != ""
	If Selection
		(!oMS.Selection && MS_Cancel())
	Else If oMS.Selection && MS_IsSelect(EL := oDoc.elementFromPoint(oMS.SCX, oMS.SCY))
		MS_Select(EL)
	oMS.Selection := Selection
}

MS_MouseOver() {
	EL := oMS.EL 
	If !MS_IsSelect(EL)
		Return
	MS_Select(EL)
}

MS_IsSelect(EL) {
	If InStr(EL.Name, "MS:")
		Return 1
}

MS_IsSelection() {
	Return oMS.ELSel.OuterText != ""
}

MS_Select(EL) { 
	If EL.Name = "MS:S" || EL.Name = "MS:SP"
		oMS.ELSel := EL.ParentElement 
	Else If EL.Name = "MS:N"
		oMS.ELSel := oDoc.all.item(EL.sourceIndex + 1)
	Else If EL.Name = "MS:P"
		oMS.ELSel := oDoc.all.item(EL.sourceIndex - 1).ParentElement
	Else
		oMS.ELSel := EL
		
	oMS.ELSel.style.backgroundColor := "#" ColorSelMouseHover
	oMS.ELSel.style.color := "#" ColorSelMouseHoverText
	
	Loop % oMS.ELSel.all.length 
		oMS.ELSel.all[A_Index-1].style.color := "#" ColorSelMouseHoverText
		 
	; ToolTip % oMS.ELSel.all.length "`n" oMS.TextColor2.OuterText "`n" EL.Name "`n" el.style.color 
}
 
	; ___________________________ Load JScripts _________________________________________________
 
ChangeCSS(id, css) {	;;  https://webo.in/articles/habrahabr/68-fast-dynamic-css/ 
	oDoc.getElementById(id).styleSheet.cssText := css
}

LoadJScript() {
	Static onhkinput, ontooltip 
	PreOver_ := PreOverflowHide ? _PreOverflowHideCSS : ""
	BodyWrap_ := WordWrap ? _BodyWrapCSS : ""
html =
(
<head> 
	<style id='css_ColorBg' type="text/css">body, .title, .button, .divwork {background-color: #%ColorBg%;}</style>
	<style id='css_PreOverflowHide' type="text/css">%PreOver_%</style>
	<style id='css_Body' type="text/css">%BodyWrap_%</style>
	<style id='css_Test' type="text/css"></style>
<style>

* {
	margin: 0;
	background: none;
	font-family: %FontFamily%;
	font-weight: %FontWeight%;
	color: #%ColorFont%; 
	// word-spacing: 0.5em;
}
body {  
	overflow: hidden; 
}
.divwork {
	position: absolute; 
	top: 5px;
	left: 5px;
	right: 1px;
	bottom: 1px; 
	font-size: %FontSize%px;
	visibility: hidden;
	overflow: auto;
	scrollbar-face-color: #%ColorScrollFace%;			/* Цвет ползунка  */
    scrollbar-arrow-color: #%ColorScrollArrows%;		/* Цвет стрелок */
    scrollbar-base-color: #%ColorScrollBack%; 	/* Цвет полосы */
	scrollbar-highlight-color: #%ColorScrollBack%;
    scrollbar-shadow-color: #%ColorScrollBack%; /* Цвет тени */
	scrollbar-track-color: #%ColorScrollBack%;
}
.br {
	height:0.1em;
} 
.box {
	position: absolute;
	overflow: hidden; 
	width: 100`%;
	height: 1.5em;
	background: transparent;
	left: 0px;
}
.line {
	position: absolute;
	width: 100`%;
	top: 1px;
}
.con {
	position: absolute;
	left: 30`%;
}
.title {
	margin-right: 50px;
	white-space: pre;
	color: #%ColorTitle%;
}
.hr {
	position: absolute;
	width: 100`%;
	border-bottom: 0.2em dashed;
	border-color: #%ColorLineTitles%;
	height: 0.5em;
}
pre {
	margin-bottom: 0.1em;
	margin-top: 0.1em;
	line-height: 1.4em;
}
.button {
	cursor: hand;
	position: relative;
	border: 1px dotted;
	border-color: #%ColorFont%;
	white-space: pre;
}
.BB {
	display: inline-block; 
} 
.param {
	color: #%ColorParam%;
}
.QStyle1 {
	color: #%ColorStyleComment1%;
}
.QStyle2 {
	color: #%ColorStyleComment2%;
}
.error {
	color: #%ColorDelimiter%;
}  
.titleparam {
	color: #%ColorTitle%;
}
#anchor {
	background-color: #%ColorSelAnchor%;
} 
</style>

</head>

<body contenteditable='false' id='body'>
	<div id='divwork1' class='divwork' onscroll='scrolldiv(this)' onresize='resizediv(this)'></div>
	<div id='divwork2' class='divwork' onscroll='scrolldiv(this)' onresize='resizediv(this)'></div>
</body>

<script type="text/javascript">
	var prWidth, WordWrap, MoveTitles, key1, key2, ButtonOver, ButtonOverColor; 
	
	function shift(el, scroll) {
		var col, Width, clientWidth, scrollLeft, Offset;
		
		clientWidth = el.clientWidth;
		// tooltip(el.id + "   " + el.style.width);
		// alert(clientWidth);
		if (clientWidth < 0)
			return
		scrollLeft = el.scrollLeft;
		Width = (clientWidth + scrollLeft);
		if (scroll && Width == prWidth)
			return
		if (MoveTitles == 1) {
			Offset = ((clientWidth / 100 * 30) + scrollLeft);
			col = el.querySelectorAll('.con');
			for (var i = 0; i < col.length; i++) {
				col[i].style.left = Offset + "px";
			}
		}
		col = el.querySelectorAll('.box');
		for (var i = 0; i < col.length; i++) {
			col[i].style.width = Width + 'px';
		}
		prWidth = Width;
	}
	function conleft30() {
		col = document.querySelectorAll('.con');
		for (var i = 0; i < col.length; i++) {
			col[i].style.left = "30`%";
		}
	}
	function menuitemdisplay(param) {
		col = document.querySelectorAll('.menuitemid');
		for (var i = 0; i < col.length; i++) {
			col[i].style.display = param;
		}
	}
	function getname(el) {
		alert(el.className);
	}
	function removemenuitem(parent, selector) {
		col = parent.querySelectorAll(selector);
		for (var i = 0; i < col.length; i++) {
			parent.removeChild(col[i])
		}
	}
	function resizediv(el) {
		shift(el, 0);
	} 
	function scrolldiv(el) {
		if (WordWrap == 1)
			return 
		shift(el, 1);
	}
	function onmousedown(el) {  // строка 57  
		el.style.backgroundColor = "#%ColorSelButton%";
		ButtonOverColor = el.style.color; 
		el.style.color = "#%ColorBgOriginal%";
		el.style.border = "1px solid"; 
		el.style.borderColor = "#%ColorFont%";
	}
	function onmouseup(el, man) { 
		el.style.backgroundColor = "";
		// el.style.color = (el.name != "pre" ? "#%ColorFont%" : "#%ColorParam%");
		el.style.color = ButtonOverColor;
		if (!man && window.event.button == 2 && el.parentElement.className == 'BB')
			document.documentElement.focus();
	}
	function onmouseover(el) {   
		ButtonOverColor = el.style.color;
		el.style.zIndex = "2";
		el.style.border = "1px solid"; 
		el.style.borderColor = "#%ColorFont%"; 
		ButtonOver = el;
		return 0;
	}
	function onmouseout(el) {  
		el.style.zIndex = "0";
		el.style.backgroundColor = "";
		// el.style.color = (el.name != "pre" ? "#%ColorFont%" : "#%ColorParam%");
		el.style.color = ButtonOverColor;
		el.style.border = "1px dotted";
		el.style.borderColor = "#%ColorFont%";
		ButtonOver = 0;
	} 
	function Assync (param) {
		setTimeout(param, 1);
	}
	function ElementName (param) {
		try {
			el = document.querySelector("[name=" + param + "]");
		} catch (e) {
			return
		}
		return el
	}
	function QS(el, param) {
		return el.querySelector(param); 
	}
	
	//	alert(value);
	//	tooltip(value);
	
</script> 

<script id='tooltipevent' type="text/javascript">
	function tooltip(text) {
		key1 = text;
		tooltipevent.click();
	}
</script>
) 
oDoc.Write("<!DOCTYPE html><head><meta http-equiv=""X-UA-Compatible"" content=""IE=8""></head>" html)
oDoc.Close() 
oDivWork1 := oDoc.getElementById("divwork1")
oDivWork2 := oDoc.getElementById("divwork2") 
 
ComObjConnect(ontooltip := oDoc.getElementById("tooltipevent"), "tooltip_") 
} 

	; ___________________________ Doc Events _________________________________________________

tooltip_onclick() {
	ToolTip(oJScript.key1, 500)
}

BodyExistCheck() { 
	If (oDivNew.innerHTML != "")
		return 
	LoadJScript()
	DivWorkIndex := 2
	oBody := oDoc.body 
	Write_%ThisMode%()  
} 


Class Events {  ;;	http://forum.script-coding.com/viewtopic.php?pid=82283#p82283
	onclick() {
		oevent := oDoc.parentWindow.event.srcElement
		If (oevent.className = "button" || oevent.tagname = "button")
			Return ButtonClick(oevent)
		If (ThisMode = "Hotkey" && !Hotkey_Arr("Hook") && !isPaused && oevent.tagname ~= "PRE|SPAN")
			Hotkey_Hook(1)
	}
	ondblclick() {
		Static wordchar := "(*UCP)[_²#\.\w]"
		oevent := oDoc.parentWindow.event.srcElement
		
		If (oevent.className = "button" || oevent.tagname = "button")
			Return ButtonClick(oevent)
			
		If (oevent.tagname != "input" && (rng := oDoc.selection.createRange()).text != "" && oevent.isContentEditable)
		{ 
			While len != StrLen(rng.text) { 
				len := StrLen(rng.text)
				(SubStr(rng.text, 0) ~= wordchar ? rng.moveEnd("character", 1) 
				: (rng.moveEnd("character", -1), len := StrLen(rng.text))) 
			} 
			While !b {
				rng.moveStart("character", -1) 
				(SubStr(rng.text, 1, 1) ~= wordchar ? 0
				: (rng.moveStart("character", 1), b := 1)) 
			}
			sel := rng.text, rng.moveEnd("character", StrLen(RTrim(sel)) - StrLen(sel)), rng.select()   
		}
		Else If (ThisMode != "Hotkey" && (oevent.className = "title" || oevent.className = "con" || oevent.className = "hr" || oevent.className = "box"))  ;;	anchor
		{
			R := oDoc.selection.createRange(), R.collapse(1), R.select()
			
			If oevent.className = "con"
				_text := oevent.firstChild.id, EL := oevent.parentElement.firstChild
			Else If oevent.className = "hr"
				_text := oevent.parentElement.childNodes[1].firstChild.id, EL := oevent
			Else If oevent.className = "box"
				_text := oevent.firstChild.childNodes[1].firstChild.id, EL := oevent.firstChild.firstChild
			Else If oevent.className = "title"
				_text := oevent.id, EL := oevent.parentElement.parentElement.firstChild
				
			If (_text = "P__Tree_Acc_Path" || _text = "")
				Return
				
			If oOther.anchor[ThisMode]
			{
				pEL := GetAnchor().parentElement.parentElement.firstChild
				pEL.style.background := "'none'"
				pEL.Id := ""
				
				If (_text = oOther.anchor[ThisMode "_text"])
				{
					If AnchorFullScroll 
						oJScript.QS(oDivNew, "#id_T0").style.height := 0
					If MemoryAnchor
						IniWrite("", ThisMode "_Anchor")
					Return oOther.anchor[ThisMode] := 0, oOther.anchor[ThisMode "_text"] := "" 
				}
			}
			
			oOther.anchor[ThisMode] := 1
			oOther.anchor[ThisMode "_text"] := _text
			EL.Id := "anchor"
			EL.style.backgroundColor := "#" ColorSelAnchor
			
			_AnchorFitScroll(EL)
			
			oDivNew.scrollTop := oDivNew.scrollTop + EL.getBoundingClientRect().top - 6
			
			If MemoryAnchor
				IniWrite(oOther.anchor[ThisMode "_text"], ThisMode "_Anchor") 
		}
	}
	onfocusin() { 
		If !(oDoc.parentWindow.event.srcElement.id = "editkeyname" || oDoc.parentWindow.event.srcElement.id = "edithotkey") 
			Return 
		oDoc.parentWindow.event.srcElement.style.border := "1px solid #" ColorBorderHoverInput
		Sleep(1), Hotkey_Hook(0) 
	} 
	onfocusout() {
		If !(oDoc.parentWindow.event.srcElement.id = "editkeyname" || oDoc.parentWindow.event.srcElement.id = "edithotkey") 
			Return
		oDoc.parentWindow.event.srcElement.style.border := "1px dotted"
		oDoc.parentWindow.event.srcElement.style.borderColor :=  "#" ColorFont
		
		If (WinActive("ahk_id" hGui) && !isPaused && ThisMode = "Hotkey")
			Sleep(1), Hotkey_Hook(1)
	}
	onmouseup() {   
		if (oDoc.parentWindow.event.srcElement.className != "button")
			return
		oJScript.onmouseup(oDoc.parentWindow.event.srcElement, 0)
    }
	onmousedown() {   
		if oDoc.parentWindow.event.button != 1		;   only left button https://msdn.microsoft.com/en-us/library/aa703876(v=vs.85).aspx
			return
		if (oDoc.parentWindow.event.srcElement.className != "button")
			return 
		oJScript.onmousedown(oDoc.parentWindow.event.srcElement)
    }
    onmouseover() {   
		if (oDoc.parentWindow.event.srcElement.className = "button")
			return oJScript.onmouseover(oDoc.parentWindow.event.srcElement) 
		If oMS.Selection
			Return
		oMS.EL := oDoc.parentWindow.event.srcElement
		SetTimer, MS_MouseOver, -50
    }
	onmouseout() {
		if (oDoc.parentWindow.event.srcElement.className = "button")
			return oJScript.onmouseout(oDoc.parentWindow.event.srcElement) 
		MS_Cancel()
    }
	onselectionchange() { 
		e := oDoc.parentWindow.event
		oMS.SCX := e.clientX, oMS.SCY := e.clientY
		SetTimer, MS_SelectionCheck, -70
		SetTimer, BodyExistCheck, -1000
    }
	onselectstart() {
		SetTimer, MS_Cancel, -8
    } 
	
	SendMode() {
		IniWrite(SendMode := {Send:"SendInput",SendInput:"SendPlay",SendPlay:"SendEvent",SendEvent:"Send"}[SendMode], "SendMode")
		SendModeStr := Format("{:L}", SendMode), oDoc.getElementById("SendMode").innerText := " " SendModeStr " "
	}
	SendCode() {
		IniWrite(SendCode := {vk:"sc",sc:"name",name:"vk"}[SendCode], "SendCode")
		oDoc.getElementById("SendCode").innerText := " " SendCode " "
	}
	LButton_Hotkey() {
		If Hotkey_Arr("Hook")
			Hotkey_Main("LButton")
	}
	num_scroll(thisid) {
		(OnHook := Hotkey_Arr("Hook")) ? Hotkey_Hook(0) : 0
		SendInput, {%thisid%}
		(OnHook ? Hotkey_Hook(1) : 0)
		ToolTip(thisid " " (GetKeyState(thisid, "T") ? "On" : "Off"), 500)
	}
	NextChangeLocal() {
		(OnHook := Hotkey_Arr("Hook")) ? Hotkey_Hook(0) : 0
		ChangeLocal(hActiveX)
		ToolTip(GetLangName(hActiveX), 500)
		(OnHook ? Hotkey_Hook(1) : 0)
	}
	clean_command_line() { 
		cl := oDoc.getElementById("c_command_line").OuterText
		StringReplace, cl, cl, ", , 1 
		process := oDoc.getElementById("copy_processpath").OuterText
		cl := RegExReplace(cl, "i)\Q" process "\E(.*)", "$1", , 1)
		StringReplace, cl, cl, /CP65001, , 1  
		cl := Trim(cl, " ")
		oDoc.getElementById("c_command_line").innerText :=  RegExReplace(cl, "i)\Q" process "\E(.*)", "$1", , 1)
	}
}

ButtonClick(oevent) { 
	thisid := oevent.id
	If (thisid = "copy_wintext")
		o := oDoc.getElementById("wintextcon")
		, GetKeyState("Shift") ? ClipAdd(o.OuterText, 1) : (Clipboard := o.OuterText), HighLight([o])
	Else If (thisid = "wintext_hidden")
	{
		R := oBody.createTextRange(), R.collapse(1), R.select()
		oDoc.getElementById("wintextcon").disabled := 1
		DetectHiddenText, % DetectHiddenText := (DetectHiddenText = "on" ? "off" : "on")
		IniWrite(DetectHiddenText, "DetectHiddenText")
		If !WinExist("ahk_id" oOther.WinID) && ToolTip("Window not exist", 500)
			Return oDoc.getElementById("wintext_hidden").innerText := " hidden - " DetectHiddenText " "
		WinGetText, WinText, % "ahk_id" oOther.WinID
		oDoc.getElementById("wintextcon").innerHTML := "<pre>" TransformHTML(WinText) "</pre>"
		HTML_Win := oDivNew.innerHTML
		Sleep 200
		oDoc.getElementById("wintextcon").disabled := 0
		oDoc.getElementById("wintext_hidden").innerText := " hidden - " DetectHiddenText " "
	}
	Else If (thisid = "menu_idview")
	{
		IniWrite(MenuIdView := !MenuIdView, "MenuIdView")
		oJScript.menuitemdisplay(!MenuIdView ? "none" : "inline")
		oDoc.getElementById("menu_idview").innerText :=  " id - " (MenuIdView ? "view" : "hide") " "
	}
	Else If (thisid = "copy_menutext")
	{
		pre_menutext := oDoc.getElementById("pre_menutext")
		preclone := pre_menutext.cloneNode(true)
		oJScript.removemenuitem(preclone, ".menuitemsub")
		If !MenuIdView
			oJScript.removemenuitem(preclone, ".menuitemid")
		GetKeyState("Shift") ? ClipAdd(preclone.OuterText, 1) : (Clipboard := preclone.OuterText)
		HighLight([pre_menutext]), preclone := ""
	}
	Else If (thisid = "copy_button")
	{
		o := oDoc.all.item(oevent.sourceIndex + 2) 
		GetKeyState("Shift") ? ClipAdd(o.OuterText, 1) : (Clipboard := o.OuterText), HighLight([o])
	}
	Else If (thisid = "copy_button_CtrlText")
	{
		o := oDoc.all.item(oevent.sourceIndex + 6) 
		GetKeyState("Shift") ? ClipAdd(o.OuterText, 1) : (Clipboard := o.OuterText), HighLight([o])
	} 
	Else If (thisid = "settext_button")
		ControlSetText, , % oDoc.getElementById("content_Control_Text").OuterText, % "ahk_id" oevent.value 
	Else If thisid = copy_alltitle
	{
		HighLight([oDoc.getElementById("wintitle1")
			, oDoc.getElementById("wintitle2")
			, oDoc.getElementById("wintitle3")]) 
		
		Text := (t:=oDoc.getElementById("wintitle1").OuterText) . (t = "" ? "" : " ")
		. oDoc.getElementById("wintitle2").OuterText " " oDoc.getElementById("wintitle3").OuterText
		GetKeyState("Shift") ? ClipAdd(Text, 1) : (Clipboard := Text)
	}
	Else If thisid = copy_sbtext
	{
		elements := []
		Loop % oDoc.getElementById("copy_sbtext").name
			el := oDoc.getElementById("sb_field_" A_Index), elements.Push(el), Text .= el.OuterText "`r`n"
		HighLight(elements)
		Text := RTrim(Text, "`r`n"), GetKeyState("Shift") ? ClipAdd(Text, 1) : (Clipboard := Text)
	}
	Else If thisid = keyname
	{ 
		edithotkey := oDoc.getElementById("edithotkey"), editkeyname := oDoc.getElementById("editkeyname")
		value := edithotkey.value 
		
		If (value = "    " || value = A_Tab)
			value := A_Tab
		Else If (value != " ")
			value := RegExReplace(value, "^\s*(.*?)\s*$", "$1")
			
		If RegExMatch(value, "i)^0x([0-9a-f]+)$", M)
			key := (StrLen(M1) > 2 ? "sc" : "vk") . Format("{:U}", M1)
		Else
			key := value 
		oDoc.getElementById("edithotkey").value := key 
		
		name := GetKeyName(key)
		If (name = key)
			editkeyname.value := Format("vk{:X}", GetKeyVK(key)) (!(sc := GetKeySC(key)) ? "" : Format("sc{:X}", sc))
		Else
			editkeyname.value := (StrLen(name) = 1 ? (Format("{:U}", name)) : name)
			
		o := name = "" ? edithotkey : editkeyname
		o.focus(), o.createTextRange().select()
		oDoc.getElementById("vkname").innerHTML := GetVKCodeNameStr := GetVKCodeName(key)
		oDoc.getElementById("scname").innerHTML := GetSCCodeNameStr := GetScanCode(key)
		HTML_Hotkey := oDivNew.innerHTML 
	}
	Else If thisid = hook_reload
	{
		Suspend On
		Suspend Off
		bool := Hotkey_Arr("Hook"), Hotkey_SetHook(0), Hotkey_SetHook(1), Hotkey_Arr("Hook", bool), ToolTip("Ok", 300)
	}
	Else If thisid = hotkey_clip_cursor
		Hotkey_ClipCursor()
	Else If thisid = pause_button
		Gosub, PausedScript
	Else If (thisid = "infolder" || thisid = "command_line_infolder")
	{	
		If (thisid = "command_line_infolder")
			FilePath := oDoc.getElementById("c_command_line").OuterText
		Else 
			FilePath := oDoc.getElementById("copy_processpath").OuterText

		SelectFilePath(FilePath) ? Minimize() : ToolTip("File not exist", 500)		 
	}
	Else If (thisid = "flash_window" || thisid = "flash_control" || thisid = "flash_ctrl_window")
	{
		hwnd := thisid = "flash_window" ? oOther.WinID : thisid = "flash_ctrl_window" ? oOther.MouseWinID : oOther.ControlID

		If !WinExist("ahk_id" hwnd)
			Return ToolTip("Window not exist", 500)
		WinGetPos, WinX, WinY, WinWidth, WinHeight, % "ahk_id" hwnd
		FlashArea(WinX, WinY, WinWidth, WinHeight)
	}
	Else If (thisid = "flash_acc")
	{
		If oPubObj.Acc.CLOAKED
			Return 0, ToolTip("CLOAKED", 500)
		Acc := Object(oPubObj.Acc.AccObj)
		AccGetLocation(Acc, oPubObj.Acc.child)
		FlashArea(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4])
	}
	Else If (thisid = "flash_IE")
	{
		If !WinExist("ahk_id" oPubObj.IEElement.hwnd)
			Return ToolTip("Parent window not exist", 500)
		FlashArea(oPubObj.IEElement.Pos[1], oPubObj.IEElement.Pos[2], oPubObj.IEElement.Pos[3], oPubObj.IEElement.Pos[4])
	}
	Else If thisid = paste_process_path
		oDoc.getElementById("copy_processpath").innerHTML := TransformHTML(Trim(Trim(Clipboard), """"))
	Else If thisid = w_command_line
		RunRealPath(oDoc.getElementById("c_command_line").OuterText)
	Else If thisid = clean_command_line
		Events.clean_command_line()
	Else If thisid = paste_command_line
		oDoc.getElementById("c_command_line").innerHTML := TransformHTML(Clipboard)
	Else If thisid = paste_Control_Text
		oDoc.getElementById("content_Control_Text").innerText := Clipboard
	Else If (thisid = "process_close" && (oOther.WinPID || !ToolTip("Invalid parametrs", 500)) && ConfirmAction("Process close?"))
		Process, Close, % oOther.WinPID
	Else If (thisid = "win_close" && (oOther.WinPID || !ToolTip("Invalid parametrs", 500)) && ConfirmAction("Window close?"))
		WinClose, % "ahk_id" oOther.WinID
	Else If (thisid = "control_destroy" && (WinExist("ahk_id" oOther.ControlID) || !ToolTip("window not exist", 500)) && ConfirmAction("Window close?"))
			WinClose, % "ahk_id" oOther.ControlID     ;; DllCall("DestroyWindow", "Ptr", oOther.ControlID)   ;;  не работает
	Else If (thisid = "control_show_hide" || thisid = "window_show_hide")
	{
		Hwnd := thisid = "window_show_hide" ? oOther.WinID : oOther.ControlID
		If !WinExist("ahk_id" Hwnd)  
			Return ToolTip("window not exist", 500)
		If b := DllCall("IsWindowVisible", "Ptr", Hwnd) 
			WinHide, % "ahk_id" Hwnd
		Else 
			WinShow, % "ahk_id" Hwnd
		ToolTip(b ? "Hide" : "Show" , 500)
	}
	Else If (thisid = "SendCode")
		Events.SendCode()
	Else If (thisid = "SendMode")
		Events.SendMode()
	Else If (thisid = "LButton_Hotkey")
		Events.LButton_Hotkey()
	Else If (thisid = "numlock" || thisid = "scrolllock")
		Events.num_scroll(thisid)
	Else If thisid = locale_change
		Events.NextChangeLocal()
	Else If thisid = paste_keyname
		edithotkey := oDoc.getElementById("edithotkey"), edithotkey.value := "", edithotkey.focus()
		, oDoc.execCommand("Paste"), oDoc.getElementById("keyname").click()
	Else If thisid = get_styles_w
		ViewStylesWin()
	Else If thisid = update_styles_w
		ViewStylesWin(1) 
	Else If thisid = get_styles_c
		ViewStylesControl()
	Else If thisid = update_styles_c
		ViewStylesControl(1) 
	Else If thisid = run_AccViewer
		RunAhkPath(ExtraFile("AccViewer Source"), oPubObjGUID)
	Else If thisid = run_iWB2Learner
		RunAhkPath(ExtraFile("iWB2 Learner"))
	Else If (thisid = "run_Window_Detective" && ConfirmAction("Run Window Detective?"))
	{
		Minimize()
		If WinExist("Window Detective ahk_class Qt5QWindowIcon ahk_exe Window Detective.exe")
			WinActivate
		Else
			Run % Path_User "\Window Detective.lnk"
		TimerFunc(Func("MyWindowDetectiveStart").Bind(ThisMode = "Win" ? oOther.WinID : oOther.ControlID, WinExist() ? 1 : 0), -300)
	}
	Else If (thisid = "set_button_Transparent" && ToolTip((v := oDoc.getElementById("get_win_Transparent").innerText + 0), 500)) 
		WinSet, Transparent, % v, % "ahk_id" oOther.WinID
	Else If thisid = set_button_TransColor
		WinSet, TransColor, % oDoc.getElementById("get_win_TransColor").innerText, % "ahk_id" oOther.WinID
	Else If thisid = set_button_pos
	{
		HayStack := oevent.OuterText = "Pos:"
		? oDoc.all.item(oevent.sourceIndex + 1).OuterText " " oDoc.all.item(oevent.sourceIndex + 7).OuterText
		: oDoc.all.item(oevent.sourceIndex - 5).OuterText " " oDoc.all.item(oevent.sourceIndex + 1).OuterText
		RegExMatch(HayStack, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
		If (p1 + 0 = "" || p2 + 0 = "" || p3 + 0 = "" || p4 + 0 = "")
			Return ToolTip("Invalid parametrs", 500)
		If (ThisMode = "Win")
			WinMove, % "ahk_id " oOther.WinID, , p1, p2, p3, p4
		Else
			ControlMove, , p1, p2, p3, p4, % "ahk_id " oOther.ControlID
	}
	Else If thisid = control_click
	{
		ControlClick, % oDoc.getElementById("coord_win").innerText, % "ahk_id" oOther.MouseWinID, , , , Pos
	}
	Else If thisid = set_button_focus_ctrl
	{ 
		WinActivate, % "ahk_id " oOther.WinID
		hWnd := oOther.ControlID 
		ControlFocus, , ahk_id %hWnd%
		WinGetPos, X, Y, W, H, ahk_id %hWnd%
		FlashArea(x, y, w, h)
		If GetKeyState("Shift") && (X + Y != "") 
			MouseMoveScreen(X + W // 2, Y + H // 2)
	}
	Else If thisid = set_pos
	{ 
		thisbutton := oevent.OuterText
		If thisbutton != Screen:
		{
			hWnd := oOther.MouseWinID
			If !WinExist("ahk_id " hwnd)
				Return ToolTip("Window not exist", 500)
			WinGet, Min, MinMax, % "ahk_id " hwnd
			If Min = -1
				Return ToolTip("Window minimize", 500)
			WinGetPos, X, Y, W, H, ahk_id %hWnd%
		}
		If thisbutton = Relative window:
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			BlockInput, MouseMove  
			MouseMoveScreen(X + Round(W * p1), Y + Round(H * p2))
		}
		Else If thisbutton = Relative client:
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			GetClientPos(hWnd, caX, caY, caW, caH) 
			MouseMoveScreen(X + Round(caW * p1) + caX, Y + Round(caH * p2) + caY)
		}
		Else
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			BlockInput, MouseMove
			If thisbutton = Screen:  
				MouseMoveScreen(p1, p2)
			Else If thisbutton = Window:  
				MouseMoveScreen(X + p1, Y + p2)
			Else If thisbutton = Mouse relative control:
			{
				hWnd := oOther.ControlID
				If !WinExist("ahk_id " hwnd)
					Return ToolTip("Control not exist", 500)
				WinGetPos, X, Y, W, H, ahk_id %hWnd%  
				MouseMoveScreen(X + p1, Y + p2)
			}
			Else If thisbutton = Client:
			{
				GetClientPos(hWnd, caX, caY, caW, caH)  
				MouseMoveScreen(X + p1 + caX, Y + p2 + caY) 
			}
		}
		If isPaused
		{
			BlockInput, MouseMoveOff
			Return
		}
		If Shift := GetKeyState("Shift")
			ActivateUnderMouse() 
		GoSub, SpotProc2
		BlockInput, MouseMoveOff
		If !Shift
			Sleep(500), HideAllMarkers(), CheckHideMarker()
	} 
	Else If thisid = b_DecimalCode
	{
		oDoc.getElementById("b_DecimalCode").innerText := (DecimalCode := !DecimalCode) ? " dec " : " hex "
		str := oDoc.getElementById("v_SCDHCode").innerText
		oDoc.getElementById("v_SCDHCode").innerText := (DecimalCode) ? Format("{:d}", str) : Format("0x{:X}", str)
		str := oDoc.getElementById("v_VKDHCode").innerText
		oDoc.getElementById("v_VKDHCode").innerText := (DecimalCode) ? Format("{:d}", str) : Format("0x{:X}", str)
	}
	Else If (thisid = "acc_DoDefaultAction" || thisid = "acc_DoDefaultAction2")
		accDoDefaultAction()  
	Else If thisid = b_hwnd_flash
	{ 
		WinGetPos, X, Y, W, H, % "ahk_id" oevent.value
		FlashArea(x, y, w, h)
	}
	Else If thisid = acc_path 
		acc_path_func(1)
	Else If thisid = control_path 
		control_path_func()
	Else If thisid = b_CASend
	{  
		h := (oOther.ControlID ? oOther.ControlID : oOther.MouseWinID)
		If !WinExist("ahk_id " h)
			Return ToolTip("Window not found!", 500)
		ControlSend, , % oOther.ControlSend, ahk_id %h%
		ToolTip("send to " . (oOther.ControlID ? "control: " oOther.CtrlClass : "window: " oOther.MouseWinClass), 700)
	} 
	Else If InStr(thisid, "ahkscript_")
	{
		ToolTip("Ok", 300)
		ahkscriptpath := oDoc.getElementById("ahkscriptpath").innerText 
		If !FileExist(ahkscriptpath)
			Return ToolTip("File not exist!", 500)
		If (thisid = "ahkscript_folder")
			SelectFilePath(ahkscriptpath) ? Minimize() : ToolTip("Invalide path", 500)
		Else If (thisid = "ahkscript_copypath")
			FileToClipboard(ahkscriptpath) 
		Else If (thisid = "ahkscript_run")
			RunRealPath(ahkscriptpath) 
		Else If (thisid = "ahkscript_edit")
			RunRealPath("*Edit " ahkscriptpath)
		Else 
		{ 
			If !WinExist("ahk_class AutoHotkey ahk_pid" . oOther.WinPID)	  
				Return ToolTip("Script not found!", 500)
			If (thisid = "ahkscript_suspend")
				ExecCommandAutoHotkey("Suspend Hotkeys", oOther.WinPID)
			Else If (thisid = "ahkscript_pause")
				ExecCommandAutoHotkey("Pause Script", oOther.WinPID)
			Else If (thisid = "ahkscript_reload")
				ExecCommandAutoHotkey("Reload Script", oOther.WinPID)
			Else If (thisid = "ahkscript_exit")
				ExecCommandAutoHotkey("Exit Script", oOther.WinPID)
			Else If (thisid = "ahkscript_lines")
				ExecCommandAutoHotkey("Recent Lines", oOther.WinPID)
			Else If (thisid = "ahkscript_variables")
				ExecCommandAutoHotkey("Variables", oOther.WinPID)
			Else If (thisid = "ahkscript_hotkeys")
				ExecCommandAutoHotkey("Hotkeys", oOther.WinPID)
			Else If (thisid = "ahkscript_keyhistory")
				ExecCommandAutoHotkey("Key history", oOther.WinPID)
			Else If (thisid = "ahkscript_edit")
				ExecCommandAutoHotkey("Edit Script", oOther.WinPID) 
		}
	}  
}

control_path_func() {
	If !ChildToPath(oOther.ControlID)
		oDoc.getElementById("control_path_error").outerHTML := "<span style='color:#" ColorErrorAccPath "'>  control not found</span>" 
	oDoc.getElementById("control_path_value").innerHTML := SaveChildPath()
	HTML_Control := oDivNew.innerHTML
}

acc_path_func(manual) {
	;; If (manual && oOther.anchor[ThisMode "_text"] = "P__Tree_Acc_Path")
		;; MsgBox %  oDoc.getElementById("P__Tree_Acc_Path").innerHTML
	If !Malcev_AccPathNotBlink && manual
	{
		oDoc.getElementById("acc_path").disabled := 1
		, oDoc.getElementById("acc_path_value").disabled := 1 
		w := oDoc.getElementById("acc_path").offsetWidth
		marquee = 
		( 
			<marquee behavior='scroll' direction='right' bgcolor='#" ColorErrorAccMarquee "' width="%w%px"> &#8226; &#8226; &#8226; 
			</marquee>
		)
		oDoc.getElementById("acc_path").innerHTML := marquee   
	}
	b := GetAccPath() 
	If !manual
		Return b
	If b
	{ 
		oDoc.getElementById("acc_path_error").innerHTML := ""
		oDoc.getElementById("acc_path_value").innerHTML := SaveAccPath() 
	}
	If !b
	{
		oDoc.getElementById("acc_path_error").innerHTML := "<span style='color:#" ColorErrorAccPath "'>  "
			. (oPubObj.Acc.CLOAKED ? "CLOAKED" : (b = 0 ? "path not found" : "path not correct"))  "  </span>" 
		oDoc.getElementById("acc_path_value").innerHTML := ""
	}
	Else 
		oDoc.getElementById("acc_path_value").disabled := 0
	
	oDoc.getElementById("acc_path").innerHTML := ""
	oDoc.getElementById("acc_path").innerText := " Get path "
	oDoc.getElementById("acc_path").disabled := 0
	HTML_Control := oDivNew.innerHTML
}

	; ___________________________ SingleInstance _________________________________________________

SingleInstance(Icon = 0) {
	#NoTrayIcon
	#SingleInstance Off
	DetectHiddenWindows, On
	WinGetTitle, MyTitle, ahk_id %A_ScriptHWND%
	WinGet, id, List, %MyTitle% ahk_class AutoHotkey
	Loop, %id%
	{
		this_id := id%A_Index%
		If (this_id != A_ScriptHWND)
			WinClose, ahk_id %this_id%
	}
	Loop, %id%
	{
		this_id := id%A_Index%
		If (this_id != A_ScriptHWND)
		{
			Start := A_TickCount
			While WinExist("ahk_id" this_id)
			{
				If (A_TickCount - Start > 1500)
				{
					MsgBox, 8196, , Could not close the previous instance of this script.  Keep waiting?
					IfMsgBox, Yes
					{
						WinClose, ahk_id %this_id%
						Sleep 200
						WinGet, WinPID, PID, ahk_id %this_id%
						Process, Close, %WinPID%
						Start := A_TickCount + 200
						Continue
					}
					OnExit
					ExitApp
				}
				Sleep 1
			}
		}
	}
	If Icon
		Menu, Tray, Icon
}

	; __________________________________________________________________________________
	; ___________________________ Zoom _________________________________________________
	; __________________________________________________________________________________

ShowZoom:
hAhkSpy = %2%
If !WinExist("ahk_id" hAhkSpy)
	ExitApp
ActiveNoPause = %3%
AhkSpyPause = %4%
Suspend = %5%
Hotkey = %6%
OnlyShiftTab = %7%
GUID = %8%
HeigtButton = %9%

ListLines Off
SetBatchLines,-1
DetectHiddenWindows On
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

Global ObjActive := ComObjActive(GUID), oZoom := {}, isZoom := 1, hAhkSpy, oMenu := {}, oOther := {}
, MsgAhkSpyZoom, ActiveNoPause, SpyActive, GuiColor, TextColor, GuiColorDisp, HeigtButton
If IniRead("DarkTheme", 0)
	GuiColor := "0A0A0A", TextColor := "F5F5F5", GuiColorDisp := "263FA4"
Else 
	GuiColor := "F5F5F5", TextColor := "0A0A0A", GuiColorDisp := "FFE891"
If !oZoom.pToken := GdipStartup()
{
	MsgBox, 4112, Gdiplus Error, Gdiplus failed to start. Please ensure you have Gdiplus on your system.
	ExitApp
}
Z_MsgZoom(8, Suspend)
Z_MsgZoom(2, AhkSpyPause)
Z_MsgZoom(6, ActiveNoPause)
Z_MsgZoom(7, !!WinActive("ahk_id" hAhkSpy))
Z_MsgZoom(10, Hotkey)
Z_MsgZoom(12, OnlyShiftTab)

oZoom.CurrentProcessId := DllCall("GetCurrentProcessId")
OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "MsgAhkSpyZoom"), "Z_MsgZoom")
OnMessage(0x0020, "WM_SETCURSOR")
OnExit("ZoomOnClose")
OnMessage(0x201, "LBUTTONDOWN") ;; WM_LBUTTONDOWN
OnMessage(0x204, "RBUTTONDOWN") ;; WM_RBUTTONDOWN
OnMessage(0xA1, "LBUTTONDOWN") ;; WM_NCLBUTTONDOWN
 
SetWinEventHook("EVENT_OBJECT_DESTROY", 0x8001)
SetWinEventHook("EVENT_SYSTEM_MINIMIZESTART", 0x0016)
SetWinEventHook("EVENT_SYSTEM_MINIMIZEEND", 0x0017)
SetWinEventHook("EVENT_SYSTEM_MOVESIZESTART", 0x000A)
SetWinEventHook("EVENT_SYSTEM_MOVESIZEEND", 0x000B)			

ObjActive.Magnify := Func("Magnify")
ObjActive.Redraw := Func("Redraw") 

ZoomCreate()  
Send_AhkSpy(0, oZoom.hGui)  
Send_AhkSpy(3, oZoom.hLW) 

WinGet, Min, MinMax, % "ahk_id " hAhkSpy
If Min != -1
	ZoomShow()

MenuAdd("Zoom", "Save to temp file and edit", "_gSave_to_file")
MenuAdd("Zoom", "Save to clipboard", "_gSave_to_Clipboard")
MenuAdd("Zoom", "Save to clipboard as Base64", "_gSave_as_Base64") 
MenuAdd("Zoom")
MenuAdd("Zoom", "Save to file", "_gSave_to_file")
MenuAdd("Zoom", "Save to file and edit", "_gSave_to_file") 
MenuAdd("Zoom", "Select window", "_gMenuZoom", "+BarBreak")
MenuAdd("Zoom", "Select control", "_gMenuZoom")
MenuAdd("Zoom", "Select accesible", "_gMenuZoom")
MenuAdd("Zoom")
MenuAdd("Zoom", "Select AhkSpy", "_gMenuZoom") 
Return 

#If isZoom && oZoom.Show && UnderRender()
Up::MoveStep(0, -1)
Down::MoveStep(0, 1)
Left::MoveStep(-1, 0)
Right::MoveStep(1, 0)
+Up::MoveStep(0, -10)
+Down::MoveStep(0, 10)
+Left::MoveStep(-10, 0)
+Right::MoveStep(10, 0)

#If isZoom && oZoom.Show && oZoom.Crop && UnderRender()
Home::
MButton:: CoupCrop()
+Home::
+MButton:: CircleCoupCrop()
#If isZoom && oZoom.Show && UnderRender()
End::CropToggle()
PgUp::
PgDn::
WheelUp::
WheelDown:: ChangeZoom(FastZoom(InStr(A_ThisHotKey, "Up")))

Tab::
F1::
F11:: ZoomMaximize()

F12:: 
AppsKey::ZoomMenu()

#If isZoom && oZoom.Show && GetMinMax(oZoom.hGui) = 1
Esc:: ZoomMaximize() 
#If

; 1::Gui, Zoom: +Caption  -E%WS_EX_NOACTIVATE%   

; 2::Gui, Zoom: -Caption +E%WS_EX_NOACTIVATE%

ZoomCreate() { 
	oZoom.Zoom := IniRead("MagnifyZoom", 4)
	oZoom.Mark := IniRead("MagnifyMark", "Cross")
	oZoom.MemoryZoomSize := IniRead("MemoryZoomSize", 0)
	oZoom.GuiMinW := 380
	oZoom.GuiMinH := 351
	FontSize := {96:12,120:10,144:8,168:6}[A_ScreenDPI]
	If oZoom.MemoryZoomSize
		GuiW := IniRead("MemoryZoomSizeW", oZoom.GuiMinW), GuiH := IniRead("MemoryZoomSizeH", oZoom.GuiMinH)
	Else
		GuiW := oZoom.GuiMinW, GuiH := oZoom.GuiMinH
	Gui, Zoom: -Caption -DPIScale +Border +LabelZoomOn +HWNDhGuiZoom +AlwaysOnTop +E%WS_EX_NOACTIVATE%    ;;	+Owner%hAhkSpy%
	Gui, Zoom: Color, %GuiColor%
	Gui, Zoom: Add, Text, hwndhStatic +Border
	; DllCall("SetClassLong", "Ptr", hGuiZoom, "int", -26
	; , "int", DllCall("GetClassLong", "Ptr", hGuiZoom, "int", -26) | 0x20000)

	Gui, LW: -Caption +E%WS_EX_LAYERED% +AlwaysOnTop +ToolWindow +HWNDhLW +E%WS_EX_NOACTIVATE% +Owner%hGuiZoom% ;;	++E%WS_EX_NOACTIVATE% +E%WS_EX_TRANSPARENT%

	Gui, ZoomTB: +HWNDhTBGui -Caption -DPIScale +Parent%hGuiZoom% +E%WS_EX_NOACTIVATE% +%WS_CHILDWINDOW% -%WS_POPUP%
	Gui, ZoomTB: Color, %GuiColor%
	h := 32
	Gui, ZoomTB: Add, Slider, % "hwndhSliderZoom gSliderZoom x8 Range1-50 w152 y" (44-h)/2 " h" h " Center AltSubmit NoTicks", % oZoom.Zoom
	Gui, ZoomTB: Font, % "s" FontSize + 2
	Gui, ZoomTB: Add, Text, hwndhTextZoom +0x201 x+10 yp w36 hp c%TextColor%, % oZoom.Zoom
	Gui, ZoomTB: Font, % "s" FontSize + 4
	Gui, ZoomTB: Add, Button, hwndhZoomHideBut gZoomHide x+10 ys h%h% w22, % Chr(0x00D7)
	Gui, ZoomTB: Font, % "s" FontSize - 2
	Gui, ZoomTB: Add, Button, hwndhChangeMark gChangeMark x+10 yp hp w62, % oZoom.Mark
	Gui, ZoomTB: Add, Text, % "hwndhCropWidth hidden Border Section c" TextColor " xp yp wp h" h / 2
	Gui, ZoomTB: Add, Text, % "hwndhCropHeight hidden Border c" TextColor " xs y+0 wp hp"
	Gui, ZoomTB: Font, % "s" FontSize + 4
	Gui, ZoomTB: Add, Button, gZoomMenu hwndhZoomMenu x+10 ys h%h% w22, % Chr(0x2261)
	Gui, ZoomTB: Add, Button, gZoomMaximize x+10 yp hp wp, % Chr(0x1F791) 
	Gui, ZoomTB: Show, NA x0 y0
	Gui, Zoom: Show, % "NA Hide w" GuiW " h" GuiH, AhkSpyZoom
	Gui, Zoom: +MinSize
	
	WinSet, TransParent, 255, ahk_id %hGuiZoom%
	
	oZoom.hdcSrc := DllCall("GetDC", "UPtr", 0, "UPtr")
	oZoom.hDCBuf := CreateCompatibleDC()
	oZoom.hdcMemory := CreateCompatibleDC()

	oZoom.hGui := hGuiZoom
	oZoom.hStatic := hStatic
	oZoom.hTBGui := hTBGui
	oZoom.hLW := hLW

	oZoom.vTextZoom := hTextZoom
	oZoom.vChangeMark := hChangeMark
	oZoom.vCropWidth := hCropWidth
	oZoom.vCropHeight := hCropHeight 
	
	oZoom.vZoomHideBut := hZoomHideBut
	oZoom.vSliderZoom := hSliderZoom
	oZoom.vZoomMenu := hZoomMenu
}

SetSize() {
	Static Top := 45, Left := 0, Right := 6, Bottom := 6

	Width := oZoom.LWWidth := oZoom.GuiWidth - Left - Right
	Height := oZoom.LWHeight := oZoom.GuiHeight - Top - Bottom

	Zoom := oZoom.Zoom
	conW := Mod(Width, Zoom) ? Width - Mod(Width, Zoom) + Zoom : Width
	conW := Mod(conW // Zoom, 2) ? conW : conW + Zoom

	conH := Mod(Height, Zoom) ? Height - Mod(Height, Zoom) + Zoom : Height
	conH := Mod(conH // Zoom, 2) ? conH : conH + Zoom

	oZoom.conX := (((conW - Width) // 2)) * -1
	oZoom.conY :=  (((conH - Height) // 2)) * -1
	
	hDWP := DllCall("BeginDeferWindowPos", "Int", 2)
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", oZoom.hStatic, "UInt", 0
	, "Int", Left - 1, "Int", Top - 1, "Int", Width + 2, "Int", Height + 2
	, "UInt", 0x0010)    ;; 0x0010 := SWP_NOACTIVATE
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", oZoom.hTBGui, "UInt", 0
	, "Int", (oZoom.GuiWidth - oZoom.GuiMinW) / 2
	, "Int", 0, "Int", 0, "Int", 0
	, "UInt", 0x0011)    ;; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	DllCall("EndDeferWindowPos", "Ptr", hDWP)

	oZoom.nWidthSrc := conW // Zoom
	oZoom.nHeightSrc := conH // Zoom
	oZoom.nXOriginSrcOffset := oZoom.nWidthSrc//2
	oZoom.nYOriginSrcOffset := oZoom.nHeightSrc//2
	oZoom.nWidthDest := conW
	oZoom.nHeightDest := conH
	oZoom.xCenter := Round(Width / 2 - Zoom / 2)
	oZoom.yCenter := Round(Height / 2 - Zoom / 2)

	ChangeMarker()

	If oZoom.MemoryZoomSize
		SetTimer, ZoomCheckSize, -100
}

ChangeMarker() {
	Try GoTo % "Marker" oZoom.Mark

	MarkerCross:
		oZoom.oMarkers["Cross"] := [{x:0,y:oZoom.yCenter - 1,w:oZoom.nWidthDest,h:1}
		, {x:0,y:oZoom.yCenter + oZoom.Zoom,w:oZoom.nWidthDest,h:1}
		, {x:oZoom.xCenter - 1,y:0,w:1,h:oZoom.nHeightDest}
		, {x:oZoom.xCenter + oZoom.Zoom,y:0,w:1,h:oZoom.nHeightDest}]
		Return

	MarkerSquare:
		oZoom.oMarkers["Square"] := [{x:oZoom.xCenter - 1,y:oZoom.yCenter,w:oZoom.Zoom + 2,h:1}
		, {x:oZoom.xCenter - 1,y:oZoom.yCenter + oZoom.Zoom + 1,w:oZoom.Zoom + 2,h:1}
		, {x:oZoom.xCenter - 1,y:oZoom.yCenter + 1,w:1,h:oZoom.Zoom}
		, {x:oZoom.xCenter + oZoom.Zoom,y:oZoom.yCenter + 1,w:1,h:oZoom.Zoom}]
		Return

	MarkerGrid:
		If (oZoom.Zoom = 1) {
			Gosub MarkerSquare
			oZoom.oMarkers["Grid"] := oZoom.oMarkers["Square"]
			Return
		}
		oZoom.oMarkers["Grid"] := [{x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter + oZoom.Zoom,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter + oZoom.Zoom * 2,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter + oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter + oZoom.Zoom * 2,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}]
		Return
}

ZoomCheckSize() {
	Static PrWidth, PrHeight
	If (PrWidth = oZoom.GuiWidth && PrHeight = oZoom.GuiHeight)
		Return
	PrWidth := oZoom.GuiWidth, PrHeight := oZoom.GuiHeight
	IniWrite(PrWidth, "MemoryZoomSizeW"), IniWrite(PrHeight, "MemoryZoomSizeH")
}

SliderZoom() {
	SetTimer, ChangeZoom, -1
}

ChangeZoom(Val = "")  {
	If Val =
		GuiControlGet, Val, ZoomTB:, % oZoom.vSliderZoom
	If (Val < 1 || Val > 50)
		Return
	GuiControl, ZoomTB:, % oZoom.vSliderZoom, % oZoom.Zoom := Val
	GuiControl, ZoomTB:, % oZoom.vTextZoom, % oZoom.Zoom
	SetSize()
	Redraw()
	SetTimer, MagnifyZoomSave, -200
}

FastZoom(Add) {
 	Z := oZoom.Zoom, R := Mod(Z, 5)
	If Add
		Z := Z >= 10 ? Z + (5 - R) : Z + 1
	Else	
		Z := Z > 10 ? Z - (!R ? 5 : R) : Z - 1
	Return Z
}

MagnifyZoomSave() {
	IniWrite(oZoom.Zoom, "MagnifyZoom")
}

MoveStep(StepX, StepY) { 
	oZoom.nXOriginSrc += StepX
	oZoom.nYOriginSrc += StepY
	LimitsOriginSrc(), Redraw(), SendCoords()
}

ChangeMark()  {
	Static Mark := {"Cross":"Square","Square":"Grid","Grid":"None","None":"Cross","":"None"}
	oZoom.Mark := Mark[oZoom.Mark], ChangeMarker(), Redraw()
	GuiControl, ZoomTB:, % oZoom.vChangeMark, % oZoom.Mark
	GuiControl, ZoomTB:, -0x0001, % oZoom.vChangeMark
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
	SetTimer, MagnifyMarkSave, -300
}

MagnifyMarkSave() {
	IniWrite(oZoom.Mark, "MagnifyMark")
}

SetWinEventHook(EventProc, eventMin, eventMax = 0)  {
	; DllCall("CoInitialize", UInt, 0)
	Return DllCall("SetWinEventHook"
				, "UInt", eventMin, "UInt", eventMax := !eventMax ? eventMin : eventMax
				, "Ptr", hmodWinEventProc := 0, "Ptr", lpfnWinEventProc := RegisterCallback(EventProc, "F")
				, "UInt", idProcess := 0, "UInt", idThread := 0
				, "UInt", dwflags := 0x0|0x2, "Ptr")	;;	WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
}

UnhookWinEvent(hWinEventHook) {  
	DllCall("UnhookWinEvent", "Ptr", hWinEventHook)
	DllCall("GlobalFree", "Ptr", &hWinEventHook) ; free up allocated memory for RegisterCallback
}

ZoomShow() {
	ShowZoom(1) 
	Send_AhkSpy(2, 1)
	ZoomRules("ZoomHide", 0)
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
}

ZoomHide() {
	ZoomRules("ZoomHide", 1)
	ShowZoom(0) 
	Send_AhkSpy(2, 0)
	GuiControl, ZoomTB:, -0x0001, % oZoom.vZoomHideBut
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
}

ShowZoom(Show) {
	oZoom.Show := Show
	If Show {
		WinGetPos, WinX, WinY, WinW, , ahk_id %hAhkSpy%
		oZoom.LWX := WinX + WinW + 1, oZoom.LWY := WinY + 46
		Gui,  Zoom: Show, % "NA Hide x" WinX + WinW " y" WinY
		Gui,  LW: Show, % "NA x" oZoom.LWX " y" oZoom.LWY " w" 0 " h" 0
		Gui,  Zoom: Show, NA
		try Gui, LW: Show, % "NA x" oZoom.LWX " y" oZoom.LWY " w" oZoom.LWWidth " h" oZoom.LWHeight 
	}
	Else 
	{
		Gui,  LW: Show, % "NA w" 0 " h" 0  ;;	нельзя применять Hide, иначе после появления и ресайза остаётся прозрачный след
		Gui,  Zoom: Show, NA Hide
	}
}

MenuAdd(MenuName, Name = "", Label = "", Options = "") {
	Menu, %MenuName%, Add, %Name%, % oMenu.Zoom[Name] := Label, %Options%
}

	; ___________________________ Zoom Events _________________________________________________

ZoomOnSize() {
	Critical
	If A_EventInfo != 0
		Return
	oZoom.GuiWidth := A_GuiWidth
	oZoom.GuiHeight := A_GuiHeight
	SetSize()
	Redraw()
}

ZoomMaximize() { 
	WinGet, Min, MinMax, % "ahk_id " oZoom.hGui
	If Min = 1
		WinRestore, % "ahk_id " oZoom.hGui
	Else 
		WinMaximize, % "ahk_id " oZoom.hGui   
	WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " oZoom.hGui 
	oZoom.GuiWidth := WinW
	oZoom.GuiHeight := WinH
	SetSize()
	oZoom.LWWidth := oZoom.GuiWidth - 6
	oZoom.LWHeight := oZoom.GuiHeight - 51 
	oZoom.LWX := WinX + 1, oZoom.LWY := WinY + 46 
	Gui,  LW: Show, % "NA x" oZoom.LWX " y" oZoom.LWY " w" oZoom.LWWidth " h" oZoom.LWHeight  
	Redraw() 
	If Min = 1
		WinActivate, % "ahk_id " hAhkSpy
}

ZoomOnClose() {
	ReleaseDC(oZoom.hdcSrc)
	DeleteDC(oZoom.hdcSrc)
	DeleteDC(oZoom.hDCBuf)
	DeleteDC(oZoom.hdcMemory)
	GdipShutdown(oZoom.pToken)
	RestoreCursors()
	ExitApp
}

	; wParam: 0 hide, 1 show, 2 пауза AhkSpy, 3 однократный зум, 4 MemoryZoomSize, 5 MinSize, 6 ActiveNoPause
	; , 7 WinActive AhkSpy, 8 Suspend, 9 Menu, 10 Hotkey, 11 MIN, 12 ShiftTab

Zoom_Msg(wParam, lParam) {
	If wParam = 0  ;;	hide
		ZoomHide()
	Else If wParam = 1  ;;	show
		ZoomShow()
	If wParam = 2  ;;	пауза AhkSpy
		ZoomRules("Pause", lParam)
	Else If wParam = 3  ;;	однократный зум  ;;	AhkSpy отвечает за контекст вызова
		Magnify(1)
	Else If wParam = 4  ;;	MemoryZoomSize
	{
		If (oZoom.MemoryZoomSize := lParam)
			IniWrite(oZoom.GuiWidth, "MemoryZoomSizeW"), IniWrite(oZoom.GuiHeight, "MemoryZoomSizeH")
	}
	Else If (wParam = 5 && DllCall("IsWindowVisible", "Ptr", oZoom.hGui))  ;;	MinSize
		Gui, Zoom:Show, % "NA w" oZoom.GuiMinW " h" oZoom.GuiMinH
	Else If wParam = 6  ;;	ActiveNoPause
		ActiveNoPause := lParam, ZoomRules("Win", ActiveNoPause ? 0 : SpyActive)
	Else If wParam = 7  ;;	WinActive AhkSpy
		SpyActive := lParam, ZoomRules("Win", ActiveNoPause ? 0 : SpyActive)
	Else If wParam = 8  ;;	Suspend
		Suspend % lParam ? "On" : "Off"
	Else If wParam = 9  ;;	Menu
		ZoomRules("Menu", lParam)
	Else If wParam = 10  ;;	Menu
		ZoomRules("Hotkey", lParam)
	Else If wParam = 11  ;;	MIN
		ZoomRules("MIN", 1)
	Else If wParam = 12  ;;	ShiftTab
		ZoomRules("ShiftTab", lParam)
}

Z_MsgZoom(wParam, lParam) {
	obj := Func("Zoom_Msg").Bind(wParam, lParam)
	SetTimer, % obj, -1
	Return 0
}

ZoomRules(Rule, value) {
	Static IsStart, Rules, Arr, Len
	If !IsStart
	{
		Arr := {"ZoomHide":1, "Pause":2, "Win":3, "Sleep":4, "Menu":5, "MIN":6, "MOVE":7, "SIZE":8, "Hotkey":9, "ShiftTab":10}, Len := Arr.Count()
		Loop % VarSetCapacity(Rules, Len - 1)
			StrPut(0, &Rules + A_Index - 1, 1, "CP0")
		IsStart := 1
	}
	StrPut(!!value, &Rules + Arr[Rule] - 1, 1, "CP0")
	If oZoom.Work := !(StrGet(&Rules, Len, "CP0") + 0)
		SetTimer, Magnify, -1
	; ToolTip % Rule "`n" Arr[Rule] "`n" value "`n`n`n"  (StrGet(&Rules, Len, "CP0")) "`n123456789" "`n" oZoom.Work,4,55,6
}

EVENT_OBJECT_DESTROY(hWinEventHook, event, hwnd, idObject, idChild) {
	If (idObject || idChild)
		Return
	If (hwnd = hAhkSpy)
		ExitApp
}

EVENT_SYSTEM_MINIMIZESTART(hWinEventHook, event, hwnd, idObject, idChild) {
	If (idObject || idChild)
		Return
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MIN", 1)
	If oZoom.Show
		oZoom.Minimize := 1, ShowZoom(0)
}

EVENT_SYSTEM_MINIMIZEEND(hWinEventHook, event, hwnd, idObject, idChild) {
	If (idObject || idChild)
		Return
	If (hwnd != hAhkSpy)
		Return
	If oZoom.Minimize
	{
		isEnabled := false, DllCall("dwmapi.dll\DwmIsCompositionEnabled", "UInt", &isEnabled)
		Sleep % !!isEnabled ? 300 : 10
		ShowZoom(1)
		oZoom.Minimize := 0
	}
	ZoomRules("MIN", 0)
}

EVENT_SYSTEM_MOVESIZESTART(hWinEventHook, event, hwnd, idObject, idChild) {
	If (idObject || idChild)
		Return
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MOVE", 1)
}

EVENT_SYSTEM_MOVESIZEEND(hWinEventHook, event, hwnd, idObject, idChild) {
	If (idObject || idChild)
		Return
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MOVE", 0)
}

	; ___________________________ Zoom Sizing _________________________________________________

  ;;	https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-loadcursora
WM_SETCURSOR(W, L, M, H) {
	Static SIZENWSE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32642, "UPtr")
			, SIZENS := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32645, "UPtr")
			, SIZEWE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32644, "UPtr")
	If (oZoom.SIZING = 2)
		Return
	If (W = oZoom.hGui)
	{
		MouseGetPos, mX, mY
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " oZoom.hLW
		If (mX > WinX && mY > WinY)
		{
			If (mX < WinX + WinW - 10)
				DllCall("User32.dll\SetCursor", "Ptr", SIZENS), oZoom.SIZINGType := "NS"
			Else If (mY < WinY + WinH - 10)
				DllCall("User32.dll\SetCursor", "Ptr", SIZEWE), oZoom.SIZINGType := "WE"
			Else
				DllCall("User32.dll\SetCursor", "Ptr", SIZENWSE), oZoom.SIZINGType := "NWSE"
			Return oZoom.SIZING := 1
		}
	}
	Else
		oZoom.SIZING := 0, oZoom.SIZINGType := ""
}

LBUTTONDOWN(W, L, M, H) { 
	If oZoom.SIZING
	{
		ZoomRules("SIZE", 1)
		oZoom.SIZING := 2
		SetSystemCursor("SIZE" oZoom.SIZINGType)
		SetTimer, Sizing, -10
		KeyWait LButton
		SetTimer, Sizing, Off
		RestoreCursors()
		ZoomRules("SIZE", 0)
		oZoom.SIZING := 0, oZoom.SIZINGType := ""
	}
	Else If (H = oZoom.hLW)
	{
		SetTimer, Hand, -1
	}
}

RBUTTONDOWN(W, L, M, H) { 
	If (H = oZoom.vZoomMenu)
		Return ZoomMenu()
	If !(H = oZoom.hLW)
		Return 
	SetTimer CropToggle, -100
}

CropToggle() {
	If !oZoom.Crop
		oZoom.Crop := 1, oZoom.CropX := oZoom.nXOriginSrc, oZoom.CropY := oZoom.nYOriginSrc
	Else 
		oZoom.Crop := 0
	CropMarkToggle()
	Redraw()
	CropChangeControls() 
}

CropMarkToggle() { 
	If (oZoom.Crop && (oZoom.CropPrMark := oZoom.Mark) && oZoom.Mark != "Cross")
		oZoom.Mark := "Cross", ChangeMarker()
	Else If (!oZoom.Crop && oZoom.Mark != oZoom.CropPrMark)
		oZoom.Mark := oZoom.CropPrMark, ChangeMarker()  
}

CropChangeControls() { 
	GuiControl("ZoomTB:", oZoom.vChangeMark, oZoom.Mark)
	GuiControl("ZoomTB:Hide" oZoom.Crop, oZoom.vChangeMark)
	GuiControl("ZoomTB:Show" oZoom.Crop, oZoom.vCropWidth)
	GuiControl("ZoomTB:Show" oZoom.Crop, oZoom.vCropHeight) 
} 

ZoomMenu() { 
	ObjActive.ZoomSleep()
	WinActivate, % "ahk_id " oZoom.hGui
	ZoomRules("Win", 0)
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 333, "Ptr", RegisterCallback("ZoomMenuCheck", "Fast"))
	CoordMode, Menu, Screen 
	If A_GuiControl =
	{
		MouseGetPosScreen(x, y)
		Menu, Zoom, Show, % x - 200, % y + 20
	}
	Else 
	{ 
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " oZoom.vZoomMenu  
		Menu, Zoom, Show, % WinX - 200, % WinY + WinH
	}
	ObjActive.ZoomNoSleep()
}

ZoomMenuCheck()  {
	DllCall("KillTimer", "Ptr", A_ScriptHwnd, "Ptr", 1) 
	If !WinExist("ahk_class #32768 ahk_pid " oZoom.CurrentProcessId)
		Return
	If GetKeyState("RButton")
	{
		MouseGetPos, , , WinID
		Menu := MenuGetName(GetMenuForMenu(WinID)) 
		If Menu && (F := oMenu[Menu][oOther.ThisMenuItem := AccUnderMouse(WinID, Id).accName(Id)])
		{
			oOther.MenuItemExist := 1
			If  !(F ~= "^_")
			{
				KeyWait, RButton
				WinClose % "ahk_id " WinID
			}
			If IsLabel(F)
				GoSub, % F
			Else
				%F%()
			oOther.MenuItemExist := 0
		}
		KeyWait, RButton
	}
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 64, "Ptr", RegisterCallback("ZoomMenuCheck", "Fast"))
}

_gMenuZoom() { 
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem 
	p := ObjActive["Coords" SubStr(ThisMenuItem, 8)]	; SetPosObject
	If p[1] = "" || p[2] = "" || p[3] = "" || p[4] = ""
		Return ToolTip("Coordinates not found!", 800)
	oZoom.Crop := 1
	x := p[1] + 0, y := p[2] + 0, w := p[3] + 0, h := p[4] + 0
	If ThisMenuItem = Select AhkSpy
		y -= HeigtButton, h += HeigtButton
	oZoom.nXOriginSrc := x - oZoom.VSX, oZoom.nYOriginSrc := y - oZoom.VSY
	oZoom.CropX := x + w - 1 - oZoom.VSX, oZoom.CropY := y + h - 1 - oZoom.VSY 
	CropMarkToggle()
	Redraw()
	CropChangeControls()
	SendCoords()
}

_gSave_to_Clipboard() { 
	If !pBitmap := GetBitmap()
		Return ToolTip("Bitmap not found!", 800)
	SetBitmapToClipboard(pBitmap) 
	DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap) 
	ToolTip("Copy to clipboard", 800)
}

_gSave_as_Base64() {
	If GetKeyState("Control", "P")
		tovar := 1
	If GetKeyState("Shift", "P")
		nocrlf := 1
	If !pBitmap := GetBitmap()
		Return ToolTip("Bitmap not found!", 800)  
		
	If BitmapToBase64(pBitmap, tovar || nocrlf ? 1 : 0, Base64) != 0
		Return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap), ToolTip("Error BitmapToBase64!", 1200) 

	DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap) 
	DllCall("OpenClipboard", Ptr, 0)
	DllCall("EmptyClipboard")
	DllCall("CloseClipboard")
	If tovar
		Base64 := FormatBase64ToVaribles(Base64, "Base64", nocrlf ? 0 : 128) 
	Clipboard := Base64
	ToolTip("Copy to clipboard as Base64" (tovar ? " and format AHK variable" : "") (nocrlf ? " and no CRLF" : ""), 800)
		
	; File := A_Temp "\AhkSpy picture for Base64.png"
	; SaveBitmapToFile(pBitmap, File) 
	; DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap) 
	; FileGetSize, nSize, %File%
	; FileRead, buff, *c %File% 
	; If Control
		; Base64 := CryptBinaryToStringBASE64(&buff, nSize, 1)
		; , Base64 := FormatBase64ToVaribles(Base64, "Base64", 128) 
	; Else
		; Base64 := CryptBinaryToStringBASE64(&buff, nSize, 0)
	; VarSetCapacity(buff, 0)
	; DllCall("OpenClipboard", Ptr, 0)
	; DllCall("EmptyClipboard")
	; DllCall("CloseClipboard")
	; Clipboard := Base64
	; ToolTip("Copy to clipboard as Base64" (Control ? " and format AHK variable" : ""), 800)
}  

_gSave_to_file() { 
	If !pBitmap := GetBitmap()
		Return ToolTip("Bitmap not found!", 800)
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	
	file := (ThisMenuItem = "Save to temp file and edit") 
	? A_Temp "\AhkSpy picture.png"
	: A_Desktop "\AhkSpy picture " A_YYYY "-" A_MM "-" A_DD " " A_Hour "." A_Min "." A_Sec ".png"
	
	; GetNameFile(A_Desktop, "AhkSpy picture ", "png")
	
	SaveBitmapToFile(pBitmap, file)
	DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
	If (ThisMenuItem = "Save to file and edit") || (ThisMenuItem = "Save to temp file and edit")
	{ 
		WinClose % "ahk_class #32768 ahk_pid " oZoom.CurrentProcessId
		If GetMinMax(oZoom.hGui) = 1
			ZoomMaximize()
		Run edit %file%
		ObjActive.AhkSpy_Minimize()
	}
	Else
		ToolTip("Save file to desktop", 800)
}

GetBitmap() {
	If oZoom.Crop
		w := oZoom.CropWidth, h := oZoom.CropHeight
		, sx := Min(oZoom.CropX, oZoom.nXOriginSrc)
		, sy := Min(oZoom.CropY, oZoom.nYOriginSrc)
	Else
		w := oZoom.VirtualScreenWidth
		, h := oZoom.VirtualScreenHeight
		, sx := 0, sy := 0
	
	chdc := CreateCompatibleDC()
	hbm := CreateDIBSection(w, h, chdc)
	obm := SelectObject(chdc, hbm)
	DllCall("BitBlt", "Ptr", chdc, "int", 0, "int", 0, "int", w, "int", h
			, "Ptr", oZoom.hdcMemory, "int", sx, "int", sy, "Uint", 0x00CC0020) 
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hbm, "UPtr", 0, "UPtr*", pBitmap)
	SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(chdc)
	return pBitmap
}

CircleCoupCrop() {
	If oZoom.CropWidth = 1 && oZoom.CropHeight = 1
		Return
	x := oZoom.CropX, y := oZoom.CropY
	If oZoom.nXOriginSrc > oZoom.CropX && oZoom.nYOriginSrc > oZoom.CropY ; RD - текущее правее и ниже диагонали Crop
		oZoom.CropX := oZoom.nXOriginSrc, oZoom.nXOriginSrc := x
	Else If oZoom.nXOriginSrc < oZoom.CropX && oZoom.nYOriginSrc > oZoom.CropY ; LD
		oZoom.CropY := oZoom.nYOriginSrc, oZoom.nYOriginSrc := y
	Else If oZoom.nXOriginSrc < oZoom.CropX && oZoom.nYOriginSrc < oZoom.CropY ; LU 
		oZoom.CropX := oZoom.nXOriginSrc, oZoom.nXOriginSrc := x
	Else If oZoom.nXOriginSrc > oZoom.CropX && oZoom.nYOriginSrc < oZoom.CropY ; RU
		oZoom.CropY := oZoom.nYOriginSrc, oZoom.nYOriginSrc := y
	Else
		Return CoupCrop()
	Redraw()
	SendCoords()
} 

CoupCrop() {
	x := oZoom.CropX, y := oZoom.CropY
	oZoom.CropX := oZoom.nXOriginSrc, oZoom.CropY := oZoom.nYOriginSrc
	oZoom.nXOriginSrc := x, oZoom.nYOriginSrc := y
	Redraw()
	SendCoords()
}

SendCoords() { 
	OffX := (oZoom.nXOriginSrc - oZoom.sXOriginSrc)
	OffY := (oZoom.nYOriginSrc - oZoom.sYOriginSrc)
	If (oZoom.displaced && OffX OffY = "00" && (1, oZoom.displaced := 0))
		Gui, Zoom: Color, %GuiColor%
	Else If (!oZoom.displaced && OffX OffY != "00" && (1, oZoom.displaced := 1)) 
		Gui, Zoom: Color, %GuiColorDisp% 
	BGR := DllCall("gdi32.dll\GetPixel", "Ptr", oZoom.hdcMemory, "int", oZoom.nXOriginSrc, "int", oZoom.nYOriginSrc)
	Send_WM_COPYDATA(1, BGR "`n" OffX "`n" OffY, hAhkSpy)
}

Hand() {
	SetTimer, Magnify, Off
	DllCall("GetCursorPos", "int64P", pt)
	oZoom.MoveHandX := pt << 32 >> 32, oZoom.MoveHandY := pt >> 32
	oZoom.MoveXSrc := oZoom.nXOriginSrc
	oZoom.MoveYSrc := oZoom.nYOriginSrc
	SetSystemCursor("HAND")
	SetTimer, MoveHand, 10
	KeyWait, LButton
	SetTimer, MoveHand, Off
	RestoreCursors()
	oZoom.SIZING := 0
	If oZoom.Work
		SetTimer, Magnify, -10
}
	
MoveHand() {
	Static PrnXOriginSrc, PrnYOriginSrc
	PrnXOriginSrc := oZoom.nXOriginSrc
	PrnYOriginSrc := oZoom.nYOriginSrc
	DllCall("GetCursorPos", "int64P", pt)
	MouseX := pt << 32 >> 32, MouseY := pt >> 32 
	XOdds := oZoom.MoveHandX - MouseX
	XOff := XOdds > 0 ? Floor(XOdds / oZoom.Zoom) : Ceil(XOdds / oZoom.Zoom)
	oZoom.nXOriginSrc := oZoom.MoveXSrc + XOff
	YOdds := oZoom.MoveHandY - MouseY
	YOff := YOdds > 0 ? Floor(YOdds / oZoom.Zoom) : Ceil(YOdds / oZoom.Zoom)
	oZoom.nYOriginSrc := oZoom.MoveYSrc + YOff
	If (PrnXOriginSrc <> oZoom.nXOriginSrc || PrnYOriginSrc <> oZoom.nYOriginSrc)
	{
		LimitsOriginSrc()
		SendCoords()
	} 
	Redraw() 
}

LimitsOriginSrc() {
	X := oZoom.nXOriginSrc
	oZoom.nXOriginSrc := X < 0 ? 0 : X > oZoom.VirtualScreenWidth - 1 ? oZoom.VirtualScreenWidth - 1 : X
	Y := oZoom.nYOriginSrc
	oZoom.nYOriginSrc := Y < 0 ? 0 : Y > oZoom.VirtualScreenHeight - 1 ? oZoom.VirtualScreenHeight - 1 : Y
}

UnderRender() { 
	MouseGetPos, , , Control, , 2
	Return (Control = oZoom.hLW)
}

GetMinMax(h) {
	WinGet, Min, MinMax, % "ahk_id " h
	Return Min
}

Sizing() {
	MouseGetPos, mX, mY
	WinGetPos, WinX, WinY, , , % "ahk_id " oZoom.hGui
	If (oZoom.SIZINGType = "NWSE" || oZoom.SIZINGType = "WE")
		Width := " w" (mX - WinX < oZoom.GuiMinW ? oZoom.GuiMinW : mX - WinX)
	If (oZoom.SIZINGType = "NWSE" || oZoom.SIZINGType = "NS")
		Height := " h" (mY - WinY < oZoom.GuiMinH ? oZoom.GuiMinH : mY - WinY)
	Gui, Zoom:Show, % "NA" Width . Height
	SetTimer, Sizing, -1
}

SetSystemCursor(CursorName, cx = 0, cy = 0) {
	Static SystemCursors := {ARROW:32512, IBEAM:32513, WAIT:32514, CROSS:32515, UPARROW:32516, SIZE:32640, ICON:32641, SIZENWSE:32642
					, SIZENESW:32643, SIZEWE:32644 ,SIZENS:32645, SIZEALL:32646, NO:32648, HAND:32649, APPSTARTING:32650, HELP:32651}
	Local CursorHandle, hImage, Name, ID
	If (CursorHandle := DllCall("LoadCursor", Uint, 0, Int, SystemCursors[CursorName]))
		For Name, ID in SystemCursors
			hImage := DllCall("CopyImage", Ptr, CursorHandle, Uint, 0x2, Int, cx, Int, cy, Uint, 0)
			, DllCall("SetSystemCursor", Ptr, hImage, Int, ID)
}

RestoreCursors() {
	DllCall("SystemParametersInfo", UInt, 0x57, UInt, 0, UInt, 0, UInt, 0)  ;;	SPI_SETCURSORS := 0x57
}

Send_AhkSpy(i, Param) { 
	PostMessage, % MsgAhkSpyZoom, i, % Param, , ahk_id %hAhkSpy%
}

Send_WM_COPYDATA(ByRef WParam, ByRef StringToSend, ByRef hwnd) {
    Static TimeOutTime := 0, WM_COPYDATA := 0x4a
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)   
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)   
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  
    Prev_DetectHiddenWindows := A_DetectHiddenWindows 
    DetectHiddenWindows On  
    SendMessage, WM_COPYDATA, WParam, &CopyDataStruct,, ahk_id %hwnd%,,,, %TimeOutTime%
    DetectHiddenWindows %Prev_DetectHiddenWindows%   
    return ErrorLevel
}

	; ___________________________ Zoom Magnify _________________________________________________

Magnify(one = 0) { 
	If (a := oZoom.Work) || one
	{
		MouseGetPos, , , WinID
		If b := (WinID != oZoom.hLW && WinID != oZoom.hGui && WinID != hAhkSpy)
		{ 
			oZoom.NewSpot := 1, oZoom.MouseX := ObjActive.ScreenX, oZoom.MouseY := ObjActive.ScreenY
			If oZoom.Crop
				oZoom.Crop := 0, CropChangeControls()
			UpdateWindow(oZoom.hdcSrc, oZoom.MouseX - oZoom.nXOriginSrcOffset, oZoom.MouseY - oZoom.nYOriginSrcOffset)
		}
	}
	If oZoom.NewSpot && (!a || one && b || a && !b)
		Memory()
	If a
		SetTimer, Magnify, -10
	;; ToolTip % A_TickCount "`nMagnify", 4, 4, 4
}

Redraw() {
	UpdateWindow(oZoom.hdcMemory, oZoom.nXOriginSrc - oZoom.nXOriginSrcOffset , oZoom.nYOriginSrc - oZoom.nYOriginSrcOffset)
}

Memory() {
	SysGet, VSX, 76
	SysGet, VSY, 77
	oZoom.VSX := VSX
	oZoom.VSY := VSY
	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79
	oZoom.nXOriginSrc := oZoom.sXOriginSrc := oZoom.MouseX - VSX
	oZoom.nYOriginSrc := oZoom.sYOriginSrc := oZoom.MouseY - VSY 
	hBM := DllCall("Gdi32.Dll\CreateCompatibleBitmap", "Ptr", oZoom.hdcSrc, "Int", VirtualScreenWidth, "Int", VirtualScreenHeight)
	DllCall("Gdi32.Dll\SelectObject", "Ptr", oZoom.hdcMemory, "Ptr", hBM), DllCall("DeleteObject", "Ptr", hBM)
	StretchBlt(oZoom.hdcMemory, 0, 0, VirtualScreenWidth, VirtualScreenHeight, oZoom.hdcSrc, VSX, VSY, VirtualScreenWidth, VirtualScreenHeight)
	oZoom.VirtualScreenWidth := VirtualScreenWidth, oZoom.VirtualScreenHeight := VirtualScreenHeight
	oZoom.NewSpot := 0
	If oZoom.displaced && (1, oZoom.displaced := 0)
		Gui, Zoom: Color, %GuiColor% 
} 		

	; ___________________________ Zoom Gdip _________________________________________________

UpdateWindow(Src, X, Y) {
	hbm := CreateDIBSection(oZoom.nWidthDest, oZoom.nHeightDest, oZoom.hDCBuf)
	DllCall("SelectObject", "UPtr", oZoom.hDCBuf, "UPtr", hbm)
	StretchBlt(oZoom.hDCBuf, oZoom.conX, oZoom.conY, oZoom.nWidthDest, oZoom.nHeightDest
	, Src, X, Y, oZoom.nWidthSrc, oZoom.nHeightSrc)
	For k, v In oZoom.oMarkers[oZoom.Mark]
		StretchBlt(oZoom.hDCBuf, v.x, v.y, v.w, v.h, oZoom.hDCBuf, v.x, v.y, v.w, v.h, 0x5A0049)	;; PATINVERT
	CropRender()	  
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hbm, "UPtr", 0, "UPtr*", pBitmap)
	; DllCall("SelectObject", "UPtr", oZoom.hDCBuf, "UPtr", hbm)
	DllCall("gdiplus\GdipCreateFromHDC", "UPtr", oZoom.hDCBuf, "UPtr*", G)
	; DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", G, "int", 5)
	DrawImage(G, pBitmap, 0, 0, oZoom.LWWidth, oZoom.LWHeight)
	If oZoom.Show
		UpdateLayeredWindow(oZoom.hLW, oZoom.hDCBuf, oZoom.LWWidth, oZoom.LWHeight)
	DllCall("DeleteObject", "UPtr", hbm)
	DllCall("gdiplus\GdipDeleteGraphics", "UPtr", G)
	DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

CropRender() {
	Static thickness := 2
	If !oZoom.Crop
		Return 
	x := (oZoom.nXOriginSrc - oZoom.CropX) * oZoom.Zoom
	y := (oZoom.nYOriginSrc - oZoom.CropY) * oZoom.Zoom
	xoff := x < 0 ? oZoom.Zoom : 0
	yoff := y < 0 ? oZoom.Zoom : 0  
	oZoom.oMarkers["CropCross"] := [] 
	If y
		oZoom.oMarkers["CropCross"].Push({x:oZoom.xCenter - x + xoff,y:oZoom.yCenter - y - 1,w:x + oZoom.Zoom + -xoff * 2,h:thickness} 
										, {x:oZoom.xCenter - x + xoff,y:oZoom.yCenter - y + oZoom.Zoom,w:x + oZoom.Zoom + -xoff * 2,h:thickness})
	If x
		oZoom.oMarkers["CropCross"].Push({x:oZoom.xCenter - x - 1,y:oZoom.yCenter - y + yoff,h:y + oZoom.Zoom + -yoff * 2,w:thickness} 
								, {x:oZoom.xCenter - x + oZoom.Zoom,y:oZoom.yCenter - y + yoff,h:y + oZoom.Zoom + -yoff * 2,w:thickness})
	For k, v In oZoom.oMarkers["CropCross"]
		StretchBlt(oZoom.hDCBuf, v.x, v.y, v.w, v.h, oZoom.hDCBuf, v.x, v.y, v.w, v.h, 0x5A0049)	;; PATINVERT
	
	oZoom.CropWidth := Abs(oZoom.nXOriginSrc - oZoom.CropX) + 1
	oZoom.CropHeight := Abs(oZoom.nYOriginSrc - oZoom.CropY) + 1
	GuiControl("ZoomTB:", oZoom.vCropWidth, "W: " oZoom.CropWidth)
	GuiControl("ZoomTB:", oZoom.vCropHeight, "H: " oZoom.CropHeight) 
}

GdipStartup() {
	if !DllCall("GetModuleHandle", "str", "gdiplus", UPtr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, UPtr, &si, UPtr, 0)
	Return pToken
}

GdipShutdown(pToken) {
	DllCall("gdiplus\GdiplusShutdown", UPtr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", UPtr)
		DllCall("FreeLibrary", UPtr, hModule)
	Return 0
}

SelectObject(hdc, hgdiobj) {
   Ptr := A_PtrSize ? "UPtr" : "UInt"
   return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
} 

DeleteObject(hObject) {
   return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

UpdateLayeredWindow(hwnd, hdc, w, h) {
	Return DllCall("UpdateLayeredWindow"
					, UPtr, hwnd
					, UPtr, 0
					, UPtr, 0
					, "int64*", w|h<<32
					, UPtr, hdc
					, "int64*", 0
					, "uint", 0
					, "UInt*", 33488896  ;;	(Alpha := 255)<<16|1<<24
					, "uint", 2)
}

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster=0x40CC0020) {  ;;	0x00CC0020|0x40000000
	Return DllCall("gdi32\StretchBlt"
					, UPtr, ddc
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, UPtr, sdc
					, "int", sx
					, "int", sy
					, "int", sw
					, "int", sh
					, "uint", Raster)
}

CreateDIBSection(w, h, hdc) {
	Static bi, _ := VarSetCapacity(bi, 40, 0)
	NumPut(w, bi, 4, "uint")
	NumPut(h, bi, 8, "uint")
	NumPut(40, bi, 0, "uint")
	NumPut(1, bi, 12, "ushort")
	NumPut(0, bi, 16, "uInt")
	NumPut(32, bi, 14, "ushort")
	Return DllCall("CreateDIBSection"
					, "UPtr", hdc
					, "UPtr", &bi
					, "uint", 0
					, "UPtr*",
					, "UPtr", 0
					, "uint", 0, "UPtr")
}

DrawImage(pGraphics, pBitmap, dx, dy, dw, dh) {
	Return DllCall("gdiplus\GdipDrawImageRectRect"
				, "UPtr", pGraphics
				, "UPtr", pBitmap
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "int", 2
				, "UPtr",
				, "UPtr", 0
				, "UPtr", 0)
} 

ReleaseDC(hdc, hwnd=0) {
	Return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}

DeleteDC(hdc) {
	Return DllCall("DeleteDC", "UPtr", hdc)
}

CreateCompatibleDC(hdc=0) {
	Return DllCall("CreateCompatibleDC", "UPtr", hdc)
}

CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff) {
; background should be zero, to not alter the semi-transparent areas of the image
   hBitmap := 0
   DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hBitmap, "int", Background)
   return hBitmap
}

SetBitmapToClipboard(pBitmap) {
; modified by Marius Șucan to have this function report errors

   Ptr := A_PtrSize ? "UPtr" : "UInt"
   off1 := A_PtrSize = 8 ? 52 : 44
   off2 := A_PtrSize = 8 ? 32 : 24
   r1 := DllCall("OpenClipboard", Ptr, 0)
   If !r1
      Return -1

   hBitmap := CreateHBITMAPFromBitmap(pBitmap, 0)
   If !hBitmap
   {
      DllCall("CloseClipboard")
      Return -3
   }

   r2 := DllCall("EmptyClipboard")
   If !r2
   {
      DeleteObject(hBitmap)
      DllCall("CloseClipboard")
      Return -2
   }

   DllCall("GetObject", Ptr, hBitmap, "int", VarSetCapacity(oi, A_PtrSize = 8 ? 104 : 84, 0), Ptr, &oi)
   hdib := DllCall("GlobalAlloc", "uint", 2, Ptr, 40+NumGet(oi, off1, "UInt"), Ptr)
   pdib := DllCall("GlobalLock", Ptr, hdib, Ptr)
   DllCall("RtlMoveMemory", Ptr, pdib, Ptr, &oi+off2, Ptr, 40)
   DllCall("RtlMoveMemory", Ptr, pdib+40, Ptr, NumGet(oi, off2 - (A_PtrSize ? A_PtrSize : 4), Ptr), Ptr, NumGet(oi, off1, "UInt"))
   DllCall("GlobalUnlock", Ptr, hdib)
   DeleteObject(hBitmap)
   r3 := DllCall("SetClipboardData", "uint", 8, Ptr, hdib) ; CF_DIB = 8
   DllCall("CloseClipboard")
   DllCall("GlobalFree", Ptr, hdib)
   E := r3 ? 0 : -4    ; 0 - success
   Return E
}

SaveBitmapToFile(pBitmap, sOutput)  {
	SplitPath, sOutput,,, Extension
	if Extension not in PNG
		return -1
	DllCall("gdiplus\GdipGetImageEncodersSize", UIntP, nCount, UIntP, nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", UInt, nCount, UInt, nSize, Ptr, &ci)
	if !(nCount && nSize)
		return -2 
	Loop, % nCount  {
		sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
		if !InStr(sString, "*." Extension)
			continue

		pCodec := &ci+idx
		break
	} 
	if !pCodec
		return -3
	if A_IsUnicode
		pOutput := &sOutput
	else  {
		VarSetCapacity(wOutput, StrPut(sOutput, "UTF-16")*2, 0)
		StrPut(sOutput, &wOutput, "UTF-16")
		pOutput := &wOutput
	}
	E := DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, pOutput, Ptr, pCodec, UInt, 0)
	return E ? -5 : 0
}

BitmapToBase64(pBitmap, NOCRLF, byref Base64) {  
	DllCall("gdiplus\GdipGetImageEncodersSize", UintP, nCount, UintP, nSize) 
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", UInt, nCount, UInt, nSize, Ptr, &ci)
	if !(nCount && nSize)
		return -2 
	Loop, % nCount  {
		sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
		if !InStr(sString, "*." "PNG")
			continue
		pCodec := &ci+idx
		break
	} 
	if !pCodec
		return -3  
	DllCall( "ole32\CreateStreamOnHGlobal", UInt, 0, Int, 1, PtrP, pStream )
	if !E := DllCall( "gdiplus\GdipSaveImageToStream", Ptr, pBitmap, Ptr, pStream, Ptr, pCodec, UInt, 0)  {
		DllCall( "ole32\GetHGlobalFromStream", Ptr, pStream, PtrP, hData )
		pData := DllCall( "GlobalLock", Ptr, hData, Ptr )
		nSize := DllCall( "GlobalSize", Ptr, hData, Ptr )
		VarSetCapacity( buff, 0), VarSetCapacity( buff, nSize, 0 )
		DllCall( "RtlMoveMemory", Ptr, &buff, Ptr, pData, UInt, nSize )
		DllCall( "GlobalUnlock", Ptr, hData )
		DllCall( "GlobalFree", Ptr, hData )
	}
	ObjRelease(pStream)  
	Base64 := CryptBinaryToStringBASE64(&buff, nSize, NOCRLF)
	return 0
}  
 
FormatBase64ToVaribles(Base64, Name, LenRow = 128) {
	DATALen := StrLen(Base64)
	RowLen := !LenRow ? 16000 : LenRow
	If (RowLen = 16000) || (RowLen >= DATALen)
		Return DataToVarExp(Base64, Name, DATALen)
	Step := 0, Pos := 1  
	If !LenRow
	{
		Loop % Ceil(DATALen / RowLen)
		{
			Str .= SubStr(Base64, Pos, RowLen)
			Pos += RowLen
			If (Pos < DATALen)
				Str .= "`n" Name " = %" Name "%"
		}
		Return Name " = " Str
	} 
	Loop % Ceil(DATALen / RowLen)
	{   
		Str .= SubStr(Base64, Pos, RowLen) "`n" 
		Pos += RowLen, ++Step
		If (Pos >= DATALen || Step * RowLen >= 16000)
			Step := 0, Str .= ")" . (Pos < DATALen ? "`n" Name " = %" Name "%`n(`n" : "")
	}
	Return Name " = `n(`n" Str
}	

DataToVarExp(Base64, Name, DATALen) {
	RowLen := 16000, Pos := 1   
	If (RowLen >= DATALen)
		Return Name " := """ Base64 """"
	Loop % Ceil(DATALen / RowLen)
	{
		p := SubStr(Base64, Pos, RowLen) 
		Pos += RowLen
		Str .= "`n" Name " .= """ p """"
	}
	Return StrReplace(Str, " .= """, " := """, , 1) 
}	

CryptBinaryToStringBASE64(pData, Bytes, NOCRLF = "")  {
   static CRYPT_STRING_BASE64 := 1, CRYPT_STRING_NOCRLF := 0x40000000
   CRYPT := CRYPT_STRING_BASE64 | (NOCRLF ? CRYPT_STRING_NOCRLF : 0)
   
   DllCall("Crypt32\CryptBinaryToString", Ptr, pData, UInt, Bytes, UInt, CRYPT, Ptr, 0, UIntP, Chars)
   VarSetCapacity(OutData, Chars * (A_IsUnicode ? 2 : 1))
   DllCall("Crypt32\CryptBinaryToString", Ptr, pData, UInt, Bytes, UInt, CRYPT, Str, OutData, UIntP, Chars)
   Return OutData
}
	; ___________________________ End _________________________________________________

	;;)			01:58 20.01.2021
