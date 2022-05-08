/*! TheGood
	TillaGoto - Go to functions and labels in your script
	Last updated: December 30, 2010
	
	SciTE4AutoHotkey version (by fincs) - Many, MANY changes in order to make it well-behaved
	
	Usage, changelog and help can be found in the thread:
	http://www.autohotkey.com/forum/viewtopic.php?t=41575
	
	快捷键：
		鼠标中键点文字 或 tillagoto.hk.goto.def  （默认 Shift+Enter ） 可跳到文字对应的定义处。
		Shift+滚轮     或 tillagoto.hk.go.back   （默认 Alt+左右箭头） 可跳回或跳前。
		鼠标中键点空白 或 tillagoto.hk.summon.gui（默认 F12）          激活 GUI 。
		Esc                                                            关闭 GUI 。
	
	修改快捷键：
		可在文件 tillagoto.properties 中配置。
	
	更新日志：
		2016.04.20
			彻底支持代码中存在中文的情况。
			可完美分析并定位出代码中的中文标签、函数。
		2022.05.08
			修复热键、标签、函数识别 bug 。
			支持任意文件编码，任意语言文字（例如中英日韩）的标签、函数的识别。
			支持鼠标中键点击任意语言文字（例如中英日韩）的标签、函数时跳转。
			优化跳转后的显示位置。
			重构部分代码。
			重构操作逻辑。
			加入提示。
			界面改进。
*/
	; 避免 GUI 显示时强制退出报错
	ComObjError(false)
	
	; Get SciTE object
	oSciTE := GetSciTEInstance()
	
	; Get SciTE window handle and Scintilla1 handle
	hSciTE := oSciTE.SciTEHandle
	; Scintilla1 = edit panel, Scintilla2 = output panel
	ControlGet, hSci, Hwnd,, Scintilla1, ahk_id %hSciTE%
	
	If !hSci
	{
		MsgBox, 16, TillaGoto, Cannot find SciTE!
		ExitApp
	}
	
	; Read TillaGoto settings using SciTE's property system
	bTrayIcon        := oSciTE.ResolveProp("tillagoto.show.tray.icon") + 0
	iGUIWidth        := oSciTE.ResolveProp("tillagoto.gui.width") + 0
	iGUIHeight       := oSciTE.ResolveProp("tillagoto.gui.height") + 0
	iMargin          := oSciTE.ResolveProp("tillagoto.gui.margin") + 0
	iTransparency    := oSciTE.ResolveProp("tillagoto.gui.transparency") + 0
	bPosLeft         := oSciTE.ResolveProp("tillagoto.gui.posleft") + 0
	bWideView        := oSciTE.ResolveProp("tillagoto.gui.wide.view") + 0
	iAlignFilenames  := oSciTE.ResolveProp("tillagoto.gui.align.filenames") + 0
	cGUIBG           := oSciTE.ResolveProp("tillagoto.gui.bgcolor")
	cControlBG       := oSciTE.ResolveProp("tillagoto.gui.controlbgcolor")
	cControlFG       := oSciTE.ResolveProp("tillagoto.gui.controlfgcolor")
	iControlFontSize := oSciTE.ResolveProp("tillagoto.gui.font.size") + 0
	fControlFont     := oSciTE.ResolveProp("tillagoto.gui.font")
	bSortEntries     := oSciTE.ResolveProp("tillagoto.gui.sort.entries") + 0
	uSummonGUI       := oSciTE.ResolveProp("tillagoto.hk.summon.gui")
	uGoBack          := oSciTE.ResolveProp("tillagoto.hk.go.back")
	uGoForward       := oSciTE.ResolveProp("tillagoto.hk.go.forward")
	uGotoDef         := oSciTE.ResolveProp("tillagoto.hk.goto.def")
	bFilterComments  := oSciTE.ResolveProp("tillagoto.filter.comments") + 0
	bQuitWithEditor  := oSciTE.ResolveProp("tillagoto.quit.with.editor") + 0
	bMatchEverywhere := oSciTE.ResolveProp("tillagoto.match.everywhere") + 0
	bUseMButton      := oSciTE.ResolveProp("tillagoto.use.mbutton") + 0
	iCancelWait      := oSciTE.ResolveProp("tillagoto.cancel.timeout") + 0
	iIncludeMode     := oSciTE.ResolveProp("tillagoto.include.mode") + 0
	bCacheFiles      := oSciTE.ResolveProp("tillagoto.cache.files") + 0
	bDirectives      := oSciTE.ResolveProp("tillagoto.directives") + 0
	
	; #1D2125 -> 1D2125
	cGUIBG     := LTrim(cGUIBG, "#")
	cControlBG := LTrim(cControlBG, "#")
	cControlFG := LTrim(cControlFG, "#")
	
	;Keep backup values
	bFilterCommentsOrig := bFilterComments
	iIncludeModeOrig := iIncludeMode
	
	#NoEnv
	#NoTrayIcon
	#SingleInstance Ignore
	SetTitleMatchMode, RegEx
	DetectHiddenWindows, On
	SetBatchLines, -1
	Menu, Tray, NoStandard
	Menu, Tray, Icon, %A_ScriptDir%\..\toolicon.icl, 16
	Menu, Tray, Tip, TillaGoto for SciTE4AutoHotkey
	Menu, Tray, Add, Close, TrayClose
	
	;Show tray icon if necessary
	If bTrayIcon
		Menu, Tray, Icon
	
	;Get scrollbar width and height
	SysGet, SM_CXVSCROLL, 2
	SysGet, SM_CYHSCROLL, 3
	
	; Check if we'll be using the caching feature
	; 如果包含了库文件，库文件内容一般是不会变的
	; 所以通过通过 CRC32 校验并缓存库文件内容可以加速分析
	If bCacheFiles {
		GetFileCRC32() ;Initialize GetFileCRC32
		OnExit, DeleteCache ;Register sub to delete cache upon exiting the script
	}
	
	;Create GUI
	Gui, +AlwaysOnTop +Border +ToolWindow +LastFound -Caption +HwndhGui
	Gui, Font, s%iControlFontSize% c%cControlFG%, %fControlFont%
	Gui, Color, %cGUIBG%, %cControlBG%
	Gui, Margin, %iMargin%, %iMargin%
	Gui, Add, Edit, w%iGUIWidth% vtxtSearch gtxtSearch_Event hwndhtxtsearch ; height is automatically set by font size
	sortOpt := bSortEntries ? "Sort" : ""
	Gui, Add, ListBox, %sortOpt% wp vlblList glblList_Event hwndhlblList +HScroll +256 ;LBS_NOINTEGRALHEIGHT
	Gui, Add, Button, w0 h0 vlooksLikeNoFocus ; this control only work for handle focus when gui is not active
	
	;Get the height of a listbox item
	SendMessage, 417,,,, ahk_id %hlblList% ;LB_GETITEMHEIGHT
	iGUIItemHeight := ErrorLevel
	
	; Catch WM_KEYDOWN and WM_MOUSEWHEEL
	OnMessage(0x100, "GUIInteract")  ; 方向键与翻页键与 Ctrl+Home Ctrl+End 在 GUI 中选择项目
	OnMessage(0x20A, "GUIInteract")  ; 实际并没有产生任何效果，可能是因为 win10 自带鼠标穿透操控的功能
	OnMessage(0x200, "WM_MouseMove")
	
	; Register main hotkeys
	Hotkey, If, _SciTEIsActive()
	Hotkey, %uSummonGUI%, Press_uSummonGUI
	Hotkey, %uGotoDef%,   Press_uGotoDef
	Hotkey, %uGoBack%,    PreviousView
	Hotkey, %uGoForward%, NextView
	
	;Optimize before starting loop or ending autoexecute section
	EmptyMem()
	
	If bQuitWithEditor {
		Loop {
			Sleep, 1000 ;Check if we need to quit
			If Not WinExist("ahk_id " hSciTE)
				ExitApp
		}
	}
	
Return

TrayClose:
ExitApp

; Necessary for the conditional hotkey/hotstring expression to be registered
#If bUseMButton And _SciTEIsUnderMouse()
MButton::
HandleMButton()
{
	Global hSci, clickX, clickY
	
	Critical
	
	VarSetCapacity(lpPoint, 8, 0)
	DllCall("GetCursorPos", "Ptr", &lpPoint)
	DllCall("ScreenToClient", "Ptr", hSci, "Ptr", &lpPoint)
	; get mouse pos in control Scintilla1
	clickX := NumGet(lpPoint, 0, "Int")
	clickY := NumGet(lpPoint, 4, "Int")
	
	SetTimer, Press_MButton, -1
}
#If _SciTEIsActive()
+WheelDown::
+WheelUp::
HandleShiftWheel()
{
	; Shift+WheelDown = Alt+Right
	LineHistory(InStr(A_ThisHotkey, "Down") ? True : False)
}
#If bShowing
Esc::
HandleEsc()
{
	SetTimer, GuiEscape, -1
}
#If

/************\
 GUI related |
		   */

; User press MButton or uGotoDef(Shift+Enter).
Press_MButton:
Press_uGotoDef:
	; only work for ahk1. This condition cannot be judged in #If, an error will occur.
	If (oSciTE.ResolveProp("Language")!="ahk1")
		return
	
	If (A_ThisLabel = "Press_uGotoDef")
		clickX := -1, clickY := -1
	
	bCheckClick := CheckTextClick(clickX, clickY)
	
	; click a word.
	If (bCheckClick)
	{
		; if GUI is showing, we don't need analyse again.
		If (!bShowing)
		{
			; Get the filename
			sScriptPath := oSciTE.CurrentFile
			Gosub, AnalyseScript
		}
		
		; jump to define if we click some word
		Gosub, SelectItem
	}
	; click nothing.
	Else
	{
		If (bShowing)
			SetFocusOnGui()
		Else
			Gosub, CreateGUI
	}
return

Press_uSummonGUI:
	; only work for ahk1. This condition cannot be judged in #If, an error will occur.
	If (oSciTE.ResolveProp("Language")!="ahk1")
		return
	
	; if GUI is showing, put the focus on it.
	If (bShowing)
		SetFocusOnGui()
	Else
		Gosub, CreateGUI
return

SetFocusOnGui()
{
	Global bFocusOnGui, hGui, txtSearch
	
	Critical
	
	bFocusOnGui := True
	WinActivate, ahk_id %hGui%
	GuiControl, Focus, txtSearch
	
	Critical, Off
}

CreateGUI:
	; Get the filename
	sScriptPath := oSciTE.CurrentFile
	Gosub, AnalyseScript
	
	;Check if we have to append filename
	If (iIncludeMode & 0x10000000)
		AppendFilename()
	
	GuiControl,, txtSearch,
	CreateList()
	
	;Set up textbox and listbox width
	If bWideView {
		
		;We need to calculate the dimensions of the GUI to accomodate all items
		
		;Check if there will be a vscroll if filter is empty
		bVScroll := (sLabels0 + sFuncs0 > iGUIHeight)
		
		;Get the longest item if filter is empty
		iW := GetLongestItem(hlblList) + (bVScroll ? SM_CXVSCROLL : 0) + 4
		iW := iW < iGUIWidth ? iGUIWidth : iW
		
		;Make sure there's no hscroll
		PostMessage, 404,,,, ahk_id %hlblList% ;LB_SETHORIZONTALEXTENT
		
		;Update the size of the controls
		ControlMove,,,, iW,, ahk_id %htxtSearch%
		ControlMove,,,, iW,, ahk_id %hlblList%
	} Else iW := iGUIWidth
	
	;Check if hscroll will appear and adjust height to make sure %iGUIHeight% items are visible
	SendMessage, 403, 0, 0,, ahk_id %hlblList% ;LB_GETHORIZONTALEXTENT
	ControlMove,,,,, iGUIHeight * iGUIItemHeight + (ErrorLevel > iW ? SM_CYHSCROLL : 0) + 4, ahk_id %hlblList%
	
	;Get window info
	WinGetPos, iX, iY,,, ahk_id %hSciTE%
	ControlGetPos, sX, sY, sW, sH,, ahk_id %hSci%
	iX += sX + (Not bPosLeft ? sW - (iW + (iMargin * 2)*A_ScreenDPI/96) - (Sci_VScrollVisible(hSci) ? SM_CXVSCROLL : 0) - 2 : 2)
	iY += sY + 2
	
	;Make sure we should still show the GUI
	If Not _SciTEIsActive()
		Return
	
	Gui, Show, w0 h0
	WinSet, Transparent, 0, ahk_id %hGui%
	Gui, Show, AutoSize x%iX% y%iY%
	
	bShowing := True
	bFocusOnGui := True
	SetTimer, CheckFocus, 50
	
	; Put the focus on the textbox.
	; When you first call GUI, you don't need this. When you call GUI a second time, you will need this.
	GuiControl, Focus, txtSearch
	
	;Do the fade-in effect
	i := 0
	While (i <= iTransparency) {
		WinSet, Transparent, %i%, ahk_id %hGui%
		i += 15
		Sleep, 10
	}
	
	If Not iTransparency Or (iTransparency = 255) ;Turn off if opaque
		WinSet, Transparent, OFF, ahk_id %hGui%
	
Return

GuiEscape:
	bShowing := False
	Gui, Cancel
	Gui, Show, Hide w0 h0
	SetTimer, CheckFocus, Off
	VarSetCapacity(sScript, 0)
	EmptyMem()
Return

CheckFocus:
	GuiActivated   := WinActive("ahk_id " hGui)
	SciteActivated := _SciTEIsActive()
	AppSwitched    := !GuiActivated And !SciteActivated
	TabSwitched    := oSciTE.CurrentFile != sScriptPath
	If (AppSwitched Or TabSwitched)
	{
		SetTimer, CheckFocus, Off
		Gosub, GuiEscape
	}
	Else If (bFocusOnGui And SciteActivated And !GuiActivated)
	{
		bFocusOnGui := False
		Gosub, CloseToolTip
		GuiControl, Focus, looksLikeNoFocus ; move focus on a zero size control, to make it looks like no focus.
	}
Return

;Incremental searching
txtSearch_Event:
	If bShowing {
		GuiControlGet, s,, txtSearch
		CreateList(s)        
	}
Return

PreviousView:
	LineHistory(False)
Return

NextView:
	LineHistory(True)
Return

lblList_Event:
	If (A_GuiEvent <> "DoubleClick")
		Return
SelectItem:
	
	; from Press_MButton or Press_uGotoDef
	If bCheckClick {
		If (i := CheckFuncMatch(clickedFunc "()"))        ; Try with functions first (internal first)
			bIsFunc := True
		Else If (i := CheckLabelMatch(clickedLabel ":"))  ; Try with labels
			bIsFunc := False
		Else
		{
			ToolTip, 没有找到与 “%clickedFunc%” 相关的函数或标签
			SetTimer, CloseToolTip, -2000
			Return
		}
		
		;Move the caret to the position before going to item
		SendMessage, 2025, iPos, 0,, ahk_id %hSci% ;SCI_GOTOPOS
		
		bCheckClick := False
	}
	; from GUIInteract. when user press enter
	Else {
		;Get selected item index. LB_GETCURSEL
		SendMessage, 0x188, 0, 0,, ahk_id %hlblList%
		
		;Check for error. LB_ERR
		If (ErrorLevel = 0xFFFFFFFF)
			Return
		
		;Get the associated item data
		i := GetListBoxItemData(hlblList, ErrorLevel) 
		
		;Retrieve function flag in high-word and set i to the index in low-word
		bIsFunc := (i >> 16)
		i &= 0xFFFF
	}
	
	If bIsFunc {
		;Check if it's external
		If sFuncs%i%_File
			LaunchFile(GetFile(sFuncs%i%_File, True), sFuncs%i%_Line)
		Else ShowLine(sFuncs%i%_Line)
	}
	Else {
		;Check if it's external
		If sLabels%i%_File
			LaunchFile(GetFile(sLabels%i%_File, True), sLabels%i%_Line)
		Else ShowLine(sLabels%i%_Line)
	}
	
	Goto GuiEscape  ;Done
Return

CloseToolTip:
	ToolTip
Return

_SciTEIsActive() {
	Global hSciTE
	return WinActive("ahk_id " hSciTE)
}

_SciTEIsUnderMouse()
{
	Global hSci
	
	MouseGetPos, , , , OutputVarControl, 2
	If (OutputVarControl=hSci)
		return, True
}

GUIInteract(wParam, lParam, msg, hwnd) {
	Local bForward
	
	Critical
	
	;Check which message it is
	If (msg = 0x100) {                              ; WM_KEYDOWN
		
		If (wParam=13) ;Enter
		{
			SetTimer, SelectItem, -1
			Return
		}
		
		;Check if it's the textbox
		If (hwnd = htxtSearch) {
			If (wParam = 38) {         ;Up
				If Not WrapSel(True) {
					ControlSend,, {Up}, ahk_id %hlblList%
					Return True
				}
			} Else If (wParam = 40) {  ;Down
				If Not WrapSel(False) {
					ControlSend,, {Down}, ahk_id %hlblList%
					Return True
				}
			} Else If (wParam = 33) {  ;Page Up
					ControlSend,, {PgUp}, ahk_id %hlblList%
					Return True
			} Else If (wParam = 34) {  ;Page Down
					ControlSend,, {PgDn}, ahk_id %hlblList%
					Return True
			} Else If (wParam = 35) And GetKeyState("Ctrl", "P") {  ;Ctrl+End
					ControlSend,, {End}, ahk_id %hlblList%
					Return True
			} Else If (wParam = 36) And GetKeyState("Ctrl", "P") {  ;Ctrl+Home
					ControlSend,, {Home}, ahk_id %hlblList%
					Return True
			}
		} Else If (hwnd = hlblList) {   ;Make up/down wrap around
			If (wParam = 38) Or (wParam = 40)
				Return WrapSel(wParam = 38) ? True : ""
		}
	}
	Else If (msg = 0x20A) And (hwnd = htxtSearch) { ; WM_MOUSEWHEEL
		
		;Check if the listbox is even populated
		SendMessage, 395, 0, 0,, ahk_id %hlblList%
		If Not ErrorLevel
			Return  ;Listbox is empty
		
		;Sign it if needed
		wParam := wParam > 0x7FFFFFFF ? -(~wParam) - 1 : wParam
		
		;Get notches turned
		wParam := Round((wParam >> 16) / 120)
		bForward := wParam > 0
		
		Loop % Abs(wParam)
			If Not WrapSel(bForward)
				ControlSend,, % bForward ? "{Up}" : "{Down}", ahk_id %hlblList%
		
	}
}

WM_MouseMove()
{
	If (A_GuiControl="txtSearch")
		ToolTip, 语法示例：“() pp” 可匹配 apple()
	Else
		SetTimer, CloseToolTip, -1
}

WrapSel(bUp) {
	Local iCount, iSel
	
	;Get selected item index and count. LB_GETCOUNT. LB_GETCURSEL.
	SendMessage, 395, 0, 0,, ahk_id %hlblList%
	iCount := ErrorLevel
	SendMessage, 392, 0, 0,, ahk_id %hlblList%
	iSel := ErrorLevel
	
	;Select the first/last item. LB_SETCURSEL
	If bUp And (iSel = 0) {
		SendMessage 390, iCount - 1, 0,, ahk_id %hlblList%
		Return 1
	} Else If Not bUp And (iSel = iCount - 1) {
		SendMessage 390, 0, 0,, ahk_id %hlblList%
		Return 1
	}
	Return 0
}

;This sub deletes all cache files on exit
DeleteCache:
	FileDelete, %A_Temp%\*.TGcache
	ExitApp
Return

/*******************\
 Scanning functions |
				  */

;Retrieves labels and functions of the script
AnalyseScript:
	
	;Reset counters
	sLabels0 := 0
	sFuncs0 := 0
	sPaths0 := 0
	sScanFile0 := 0
	
	;Get full text
	sScript := SciUtil_GetText(hSci)
	
	If bDirectives
		GetScriptDirectives(sScript)
	
	;Ban comments if necessary
	;下面这两句的作用是将某些注释（例如文本最最前面的注释）给替换为空格，也正是由于这个函数的作用，导致坐标计算始终出问题，所以被屏蔽掉了
	;副作用是被注释掉的函数或标签也会被识别出来
	; If bFilterComments
		; FilterComments(sScript)
	
	;Get labels and functions
	encoding := SciUtil_GetCP(hSci)
	GetScriptLabels(sScript, False, encoding)
	GetScriptHotkeys(sScript, False, encoding)
	GetScriptFunctions(sScript, False, encoding)
	
	;Check if we're doing #Include files
	If (iIncludeMode & 0x00000001) {
		
		;Get the script's dir
		StringLeft, sScriptDir, sScriptPath, InStr(sScriptPath, "\", False, 0) - 1
		
		;Set the default include path to the script directory
		sWorkDir := sScriptDir
		SetWorkingDir, %sWorkDir%
		
		;Loop through each #Include file
		i := 1
		Loop {
			
			;Get the next include directive
			i := RegExMatch(sScript, "im)(*ANYCRLF)^[[:blank:]]*#Include(Again)?[[:blank:]]*"
								   . "(,|[[:blank:]]+)[[:blank:]]*(\*i[[:blank:]]+)?\K.*?$", t, i)
			
			;Make sure we've got something
			If Not i
				Break
			
			;Replace path variables
			StringReplace t, t, % "%A_ScriptDir%", %sScriptDir%
			StringReplace t, t, % "%A_AppData%", %A_AppData%
			StringReplace t, t, % "%A_AppDataCommon%", %A_AppDataCommon%
			
			;Check if it's a directory or file
			s := FileExist(t)
			If InStr(s, "D") {    ;It's a folder. Change working directory
				sWorkDir := t
				SetWorkingDir, %sWorkDir%
			} Else If s {            ;It's a file
				ScanScriptFile(t, iIncludeMode & 0x01000000, False, True)
				SetWorkingDir, %sWorkDir% ;Put the working dir's path back to here
			}
			
			;Start at next line
			i := RegExMatch(sScript, "[\r\n]+\K.", "", i)
			If Not i ;Check if that was the last line
				Break
		}
		
		;Free memory
		sScript := ""
		
		;Put working dir back to here
		sWorkDir := sScriptDir
		SetWorkingDir, %sWorkDir%
		
		;Loop through Scan directives, if any
		Loop %sScanFile0% {
			
			t := sScanFile%A_Index%
			
			;Replace path variables
			StringReplace t, t, % "%A_ScriptDir%", %sScriptDir%
			StringReplace t, t, % "%A_AppData%", %A_AppData%
			StringReplace t, t, % "%A_AppDataCommon%", %A_AppDataCommon%
			
			;Check if it's a directory or file
			s := FileExist(t)
			If InStr(s, "D") { ;It's a folder. Change working directory
				sWorkDir := t
				SetWorkingDir, %sWorkDir%
			} Else If s {            ;It's a file
				ScanScriptFile(t, iIncludeMode & 0x01000000, False, True)
				SetWorkingDir, %sWorkDir% ;Put the working dir's path back to here
			} Else If RegExMatch(t, "<\K.*(?=\>)", t) And (t := FindLibFile(t)) { ;Check if it's a lib file
				ScanScriptFile(t, iIncludeMode & 0x01000000, True, False)
			}
		}
	}
	
	;Check if we're also scanning library functions
	If (iIncludeMode & 0x00000010) {
		
		;User library takes priority
		Loop, %sScriptDir%\Lib\*.ahk, 1, 1
			ScanScriptFile(A_LoopFileLongPath, iIncludeMode & 0x01000000, True, False) ;With bFuncsOnly flag
		
		Loop, %A_MyDocuments%\AutoHotkey\Lib\*.ahk, 1, 1
			ScanScriptFile(A_LoopFileLongPath, iIncludeMode & 0x01000000, True, False) ;With bFuncsOnly flag
		
		;Get path of running AutoHotkey
		; <fincs-edit> Use actual AutoHotkey build instead of internal one
		UsedAhkPath := oSciTE.ResolveProp("AutoHotkey")
		
		StringLeft, sLibPattern, UsedAhkPath, InStr(UsedAhkPath, "\", False, 0)
		sLibPattern .= "Lib\*.ahk"
		
		Loop, %sLibPattern%, 1, 1
			ScanScriptFile(A_LoopFileLongPath, iIncludeMode & 0x01000000, True, False) ;With bFuncsOnly flag
	}
	
Return

FindLibFile(sLib) {
	Global oSciTE
	
	;Append extension if none given
	StringRight, t, sLib, 4
	If (t <> ".ahk")
		sLib .= ".ahk"
	
	;User library takes priority
	Loop, %sScriptDir%\Lib\*.ahk, 1, 1
		If (A_LoopFileName = sLib)
			Return A_LoopFileLongPath
	
	Loop, %A_MyDocuments%\AutoHotkey\Lib\*.ahk, 1, 1
		If (A_LoopFileName = sLib)
			Return A_LoopFileLongPath
	
	;Get path of running AutoHotkey
	; <fincs-edit> Use actual AutoHotkey build instead of internal one
	UsedAhkPath := oSciTE.ResolveProp("AutoHotkey")
	
	StringLeft, sLibPattern, UsedAhkPath, InStr(UsedAhkPath, "\", False, 0)
	sLibPattern .= "Lib\*.ahk"
	
	Loop, %sLibPattern%, 1, 1
		If (A_LoopFileName = sLib)
			Return A_LoopFileLongPath
}

ScanScriptFile(sPath, bRecurse = False, bFuncsOnly = False, bIsInclude = False) {
	Local encoding, sFile, s, i, sInclude, sScriptDir, iCacheIndex, iCacheType, sWorkDir
	
	sPath := AbsolutePath(sPath)
	
	;Make sure it's not the same as the script
	If (sPath = sScriptPath)
		Return
	
	;Make sure it hasn't already been done
	Loop %sPaths0%
		If (sPaths%A_Index% = sPath)
			Return
	
	sPaths0 += 1
	sPaths%sPaths0% := sPath
	sPaths%sPaths0%_Inc := bIsInclude
	
	; get file encoding with bom. if no bom, we think encoding is 0, which is consistent with scite think.
	encoding := GetFileEncodingWithBom(sPath)
	
	;Get the script's dir and set the default include path to it
	StringLeft sScriptDir, sPath, InStr(sPath, "\", False, 0) - 1
	sWorkDir := sScriptDir
	SetWorkingDir, %sWorkDir%
	
	If bCacheFiles {
		
		;iCacheType := 0x1111 - 0x1000 = file changed/not found, 0x100 = hotkeys, 0x10 = labels, 0x1 = funcs
		iCacheIndex := IsCached(sPath, iCacheType)
		
		;Expand cache array if it is not cached
		If Not iCacheIndex {
			sCache0 += 1
			iCacheIndex := sCache0
			sCache%iCacheIndex%_Path := sPath
		}
		
		If (iIncludeMode & 0x00000100) {
			If Not (iCacheType & 0x001) Or (iCacheType & 0x001) And GetCachedScriptFunctions(iCacheIndex) {
				
				If Not sFile {
					FileRead, sFile, *p%encoding% %sPath%
					ApplyCommentFilterSetting(sFile)
				}
				
				i := sFuncs0
				GetScriptFunctions(sFile, True)
				If (i <> sFuncs0)
					CacheFile("Functions", i, sFuncs0, iCacheIndex)
			}
		}
		
		If Not bFuncsOnly {
			If (iIncludeMode & 0x00001000) {
				If Not (iCacheType & 0x010) Or (iCacheType & 0x010) And GetCachedScriptLabels(iCacheIndex) {
					
					If Not sFile {
						FileRead, sFile, *p%encoding% %sPath%
						ApplyCommentFilterSetting(sFile)
					}
					
					i := sLabels0
					GetScriptLabels(sFile, True)
					If (i <> sLabels0)
						CacheFile("Labels", i, sLabels0, iCacheIndex)
				}
			}
			
			If (iIncludeMode & 0x00010000) {
				If Not (iCacheType & 0x100) Or (iCacheType & 0x100) And GetCachedScriptHotkeys(iCacheIndex) {
					
					If Not sFile {
						FileRead, sFile, *p%encoding% %sPath%
						ApplyCommentFilterSetting(sFile)
					}
					
					i := sLabels0
					GetScriptHotkeys(sFile, True)
					If (i <> sLabels0)
						CacheFile("Hotkeys", i, sLabels0, iCacheIndex)
				}
			}
		}
		
		;Calculate CRC and add to cache array
		sCache%iCacheIndex%_CRC := GetFileCRC32(sPath)
		
	} Else {    ;We don't cache
		
		;Load file and comment if requested
		FileRead, sFile, *p%encoding% %sPath%
		ApplyCommentFilterSetting(sFile)
		
		If (iIncludeMode & 0x00000100)
			GetScriptFunctions(sFile, True)
		If Not bFuncsOnly {
			If (iIncludeMode & 0x00001000)
				GetScriptLabels(sFile, True)
			If (iIncludeMode & 0x00010000)
				GetScriptHotkeys(sFile, True)
		}
	}
	
	;Check if we're recursing
	If bRecurse {
		
		;Check if include files are cached
		If bCacheFiles And (iCacheIndex < sCache0) And Not (iCacheType & 0x1000) {
			Loop, Parse, sCache%iCacheIndex%_IncFiles, `n ;Get the list of cached files
				If FileExist(A_LoopField)
					ScanScriptFile(A_LoopField, bRecurse, False, bIsInclude)
		} Else { ;We'll have to manually look for the include files
			
			If Not sFile {
				FileRead, sFile, *p%encoding% %sPath%
				ApplyCommentFilterSetting(sFile)
			}
			
			;Loop through each #Include file
			i := 1
			Loop {
				
				;Get the next include directive
				i := RegExMatch(sFile, "im)(*ANYCRLF)^[[:blank:]]*#Include(Again)?[[:blank:]]*"
									 . "(,|[[:blank:]]+)[[:blank:]]*(\*i[[:blank:]]+)?\K.*?$", sInclude, i)
				
				;Make sure we've got something
				If Not i
					Break
				
				;Replace path variables
				StringReplace sInclude, sInclude, % "%A_ScriptDir%", %sScriptDir%
				StringReplace sInclude, sInclude, % "%A_AppData%", %A_AppData%
				StringReplace sInclude, sInclude, % "%A_AppDataCommon%", %A_AppDataCommon%
				
				;Check if it's a directory or file
				s := FileExist(sInclude)
				If InStr(s, "D") { ;It's a folder. Change working directory
					sWorkDir := sInclude
					SetWorkingDir, %sWorkDir%
				} Else If s {            ;It's a file
					
					s := AbsolutePath(sInclude)
					
					;Add the file to the cache array
					If bCacheFiles
						sCache%iCacheIndex%_IncFiles .= s "`n"
					
					ScanScriptFile(s, bRecurse, False, bIsInclude)
					SetWorkingDir, %sWorkDir% ;Put the working dir's path back to here
				}
				
				;Start at next line
				i := RegExMatch(sFile, "[\r\n]+\K.", "", i)
				If Not i ;Check if that was the last line
					Break
			}
		}
	}
}

AbsolutePath(sPath) {
	If DllCall("shlwapi\PathIsRelative", "Ptr", &sPath) {
		n := DllCall("GetFullPathName", "Ptr", &sPath, "UInt", 0, "UInt", 0, "Int", 0)
		VarSetCapacity(sAbs, A_IsUnicode ? n * 2 : n)
		DllCall("GetFullPathName", "Ptr", &sPath, "UInt", n, "Str", sAbs, "Ptr*", 0)
		Return sAbs
	} Else Return sPath
}

IsCached(sPath, ByRef iCacheType) {
	Local i
	
	;Default value
	iCacheType := 0
	
	;Look for path in cache array
	Loop %sCache0% {
		If (sCache%A_Index%_Path = sPath) {
			i := A_Index
			Break
		}
	}
	
	;Check if we found the path
	If Not i
		Return 0
	Else {
		
		;Check first if it's the same file
		If (GetFileCRC32(sPath) = sCache%i%_CRC) {
			iCacheType |= FileExist(A_Temp "\" sCache%i%_Functions ".TGcache")  ? 0x001 : 0
			iCacheType |= FileExist(A_Temp "\" sCache%i%_Labels ".TGcache")     ? 0x010 : 0
			iCacheType |= FileExist(A_Temp "\" sCache%i%_Hotkeys ".TGcache")    ? 0x100 : 0
		} Else iCacheType := 0x1000
		
		Return i
	}
}

CacheFile(sType, iStart, iStop, iCacheIndex) {
	Local i, iRand, sAppend
	
	While Not iRand { ;Loop until we have a unique number
		Random, iRand, 1 ;Choose random number
		Loop %sCache0% ;Make sure it's not already taken
			If (sCache%A_Index%_Functions = iRand)
				Or (sCache%A_Index%_Labels = iRand)
				Or (sCache%A_Index%_Hotkeys = iRand) {
				iRand := 0 ;Already taken. Cancel it.
				Break
			}
	}
	
	;Delete file in case it exists
	FileDelete, %A_Temp%\%iRand%.TGcache
	
	;Prep var for file append
	If (sType = "Functions") {
		Loop % (iStop - iStart) {
			i := iStart + A_Index
			sAppend .= sFuncs%i% "`n" sFuncs%i%_Line "`n"
		}
	} Else {
		Loop % (iStop - iStart) {
			i := iStart + A_Index
			sAppend .= sLabels%i% "`n" sLabels%i%_Line "`n"
		}
	}
	
	;Write var to file
	FileAppend, %sAppend%, %A_Temp%\%iRand%.TGcache
	
	;Add cache reference to cache array
	sCache%iCacheIndex%_%sType% := iRand
}

;This sub analyses the script and add the labels in it to the array
GetScriptLabels(ByRef s, bExternal := False, encoding := "") {
	Local i, pos, t, u, v
	
	u := GetScriptEscapeChar(s)
	v := GetScriptCommentFlag(s)
	
	;Reset counter
	i := 1
	Loop {
		
		;Get next label. All valid (non-hotkey) labels are detected.
		;(invalid characters are commas, spaces, and escape char)
		i := RegExMatch(s, "mS)(*ANYCRLF)^[[:blank:]]*(?!\Q" v "\E)"
						 . "\K[^\s\Q," u "\E]+:"  ; label name can use any word except A_Space \t \r \n \, EscapeChar
						 . "(?=([[:blank:]]*[\r\n]|[[:blank:]]+\Q" v "\E))", t, i)
		
		;Make sure we found something
		If Not i
			Break
		
		; make sure we found a:, not a::
		If (SubStr(t, -1, 2)!="::")
		{
			;We found a label. Trim everything after the last colon
			StringLeft t, t, InStr(t, ":", False, 0)
			
			;Make sure it doesn't contain an escape character (unless if it's to escape the comment flag)
			If Not RegExMatch(t, "\Q" u "\E(?!\Q" v "\E)") {
				
				;Erase any occurence of the escape char
				StringReplace, t, t, %u%,, All
				
				sLabels0 += 1    ;Increase counter
				If bExternal {
					sLabels%sLabels0%_File := sPaths0
					sLabels%sLabels0%_Line := LineFromPosEx(s, i)
				} Else {
					sLabels%sLabels0%_File := 0
					; i is the pos in utf-16, we need to transform utf-16 pos to scintilla code page pos.
					; The possible values of encoding are 0 65001 932 936 949 950 1361
					pos := StrPut(SubStr(s, 1, i), "cp" encoding) - 1
					sLabels%sLabels0%_Line := LineFromPos(pos)
				}
				
				sLabels%sLabels0% := t    ;Add to array
			}
		}
		
		;Set i to the beginning of the next line
		i := RegExMatch(s, "[\r\n]+\K.", "", i)
		If Not i
			Break
	}
}

GetCachedScriptLabels(iCacheIndex) {
	Local s, bLineType
	
	;Formulate path
	s := A_Temp "\" sCache%iCacheIndex%_Labels ".TGcache"
	
	;Check if the file exists
	If Not FileExist(s)
		Return True ;Error
	Else {
		
		Loop, Read, %s%
		{   
			If bLineType
				sLabels%sLabels0%_Line := A_LoopReadLine
			Else {
				sLabels0 += 1
				sLabels%sLabels0% := A_LoopReadLine
				sLabels%sLabels0%_File := sPaths0
			}
			bLineType := Not bLineType
		}
	}
}

;This sub analyses the script and add the hotkeys in it to the array (uses the same array as labels)
GetScriptHotkeys(ByRef s, bExternal := False, encoding := "") {
	Local i, pos, n, t, u, v
	
	i := 1
	Loop {
		
		;Get next hotkey
		i := RegExMatch(s, "m)(*ANYCRLF)^[[:blank:]]*\K[a-zA-Z0-9\Q%(){}|:""?#_!@^+&<>*~$``-=\[]';/\.,\E]+"
						 . "([[:blank:]]+&[[:blank:]]+[a-zA-Z0-9\Q%(){}|:""?#_!@^+&<>*~$``-=\[]';/\.,\E]+)?"
						 . "([[:blank:]]+Up)?(?=::)", t, i)
		
		;Make sure we found something
		If Not i
			Break
		
		;Check if it's a valid hotkey
		If Not IsValidHotkey(t) { ;It failed validity test. Check if it's the exception [escapechar][commentflag]
			
			;Get the script's escape character and append comment flag
			u := u ? u : GetScriptEscapeChar(s)
			v := v ? v : GetScriptCommentFlag(s)
			
			StringReplace, t, t, %u%%v%, %v%, UseErrorLevel
			
			;Check if it's worth rechecking validity
			If (Not ErrorLevel) Or (ErrorLevel And Not IsValidHotkey(t))
				Goto, NextIteration
		}
		
		;Append the semi-colons
		t .= "::"
		
		;Expand the array and fill in the elements
		sLabels0 += 1    ;Increase counter
		If bExternal {
			sLabels%sLabels0%_File := sPaths0
			sLabels%sLabels0%_Line := LineFromPosEx(s, i)
		} Else {
			sLabels%sLabels0%_File := 0
			pos := StrPut(SubStr(s, 1, i), "cp" encoding) - 1
			sLabels%sLabels0%_Line := LineFromPos(pos)
		}
		
		sLabels%sLabels0% := t    ;Add to array
		
		NextIteration:
		
		;Set i to the beginning of the next line
		i := RegExMatch(s, "[\r\n]+\K.", "", i)
		If Not i
			Break
	}
}

GetCachedScriptHotkeys(iCacheIndex) {
	Local s, bLineType
	
	;Formulate path
	s := A_Temp "\" sCache%iCacheIndex%_Hotkeys ".TGcache"
	
	;Check if the file exists
	If Not FileExist(s)
		Return True ;Error
	Else {
		
		Loop, Read, %s%
		{
			If bLineType
				sLabels%sLabels0%_Line := A_LoopReadLine
			Else {
				sLabels0 += 1
				sLabels%sLabels0% := A_LoopReadLine
				sLabels%sLabels0%_File := sPaths0
			}
			bLineType := Not bLineType
		}
	}
}

;This sub checks the validity of a hotkey
IsValidHotkey(ByRef s) {
	Critical
	Hotkey, IfWinActive, Title ;Make sure it'll be a variant and not override a current shortcut
	Hotkey, % s, CreateGUI, UseErrorLevel Off ;Using CreateGUI only to test
	i := ErrorLevel ;Keep ErrorLevel value (because the next command will change it)
	Hotkey, IfWinActive ;Turn off context sensitivity
	Return (i <> 2)
}

;This sub analyses the script and add the functions in it to the array
GetScriptFunctions(ByRef s, bExternal := False, encoding := "") {
	Local i, pos, t, u
	
	u := GetScriptCommentFlag(s)
	
	;Loop through the functions
	i := 1
	Loop {
		
		;Get the next function
		; “\w” 包含 “a-zA-Z0-9_” ，同时 “(*UCP)” 表示 \w 支持中文日文韩文等
		i := RegExMatch(s, "mS)(*ANYCRLF)(*UCP)^[[:blank:]]*(?!\Q" u "\E)"
						 . "\K[\w\Q#@$\E]+"  ; func name can use a-z, A-Z, unicode char, 0-9, and _#@$ .
						 . "(?=\(.*?\)(\s+\Q" u "\E.*?[\r\n]+)*?\s*\{)", t, i)
		
		;Check if we found something
		If Not i
			Break
		
		;Make sure it's a valid function
		If t Not In If,While
		{   ;Increment counter
			sFuncs0 += 1
			
			t .= "()"
			If bExternal {
				sFuncs%sFuncs0%_File := sPaths0
				sFuncs%sFuncs0%_Line := LineFromPosEx(s, i)
			} Else {
				sFuncs%sFuncs0%_File := 0
				pos := StrPut(SubStr(s, 1, i), "cp" encoding) - 1
				sFuncs%sFuncs0%_Line := LineFromPos(pos)
			}
			
			sFuncs%sFuncs0% := t
		}
		
		;Get the next function
		i := RegExMatch(s, "[\r\n]+\K.", "", i)
		If Not i
			Break
	}
}

GetCachedScriptFunctions(iCacheIndex) {
	Local s, bLineType
	
	;Formulate path
	s := A_Temp "\" sCache%iCacheIndex%_Functions ".TGcache"
	
	;Check if the file exists
	If Not FileExist(s)
		Return True ;Error
	Else {
		
		Loop, Read, %s%
		{
			If bLineType
				sFuncs%sFuncs0%_Line := A_LoopReadLine
			Else {
				sFuncs0 += 1
				sFuncs%sFuncs0% := A_LoopReadLine
				sFuncs%sFuncs0%_File := sPaths0
			}
			bLineType := Not bLineType
		}
	}
}

GetScriptDirectives(ByRef s) {
	Local i, u, val
	
	;Get the comment flag used
	u := GetScriptCommentFlag(s)
	
	;Check for TillaGoto.bFilterComments
	bFilterComments := RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*\Q" u "\E[[:blank:]]*"
								   . "TillaGoto\.bFilterComments[[:blank:]]*=[[:blank:]]*\K.*?$", val)
								   ? val : bFilterCommentsOrig

	;Check for TillaGoto.iIncludeMode
	iIncludeMode := RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*\Q" u "\E[[:blank:]]*"
								. "TillaGoto\.iIncludeMode[[:blank:]]*=[[:blank:]]*\K.*?$", val)
								? val : iIncludeModeOrig
	
	;Check for Include directives
	i := 1
	Loop {
		i := RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*\Q" u "\E[[:blank:]]*"
						 . "TillaGoto\.ScanFile[[:blank:]]*=[[:blank:]]*\K.*?$", val, i)
		
		If Not i
			Break
		
		;Add to array
		sScanFile0 += 1
		sScanFile%sScanFile0% := val
		
		;Move to next line
		i += StrLen(val) + 1
	}
}

ApplyCommentFilterSetting(ByRef sFile) {
	Global iIncludeMode
	
	;Remove comments if necessary
	bOverride := GetScriptCommentOverride(sFile)
	If (bOverride <> -1)
		bOverride ? FilterComments(sFile, True)
	Else If (iIncludeMode & 0x00100000)
		FilterComments(sFile, True)
}

GetScriptCommentOverride(ByRef s) {
	
	;Get the comment flag used
	sCommentFlag := GetScriptCommentFlag(s)
	
	;Check for TillaGoto.bFilterComments
	Return RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*\Q" sCommentFlag "\E[[:blank:]]*"
					   . "TillaGoto\.bFilterComments[[:blank:]]*=[[:blank:]]*\K.*?$", val)
					   ? val : -1
}

FilterComments(ByRef s, bRespectLines = False) {
	Local i, j, len, sCommentFlag, blank, l1, l2
	
	i := 1
	Loop {
		
		;Get next block start
		i := RegExMatch(s, "m)(*ANYCRLF)^[[:blank:]]*/\*[^!]", "", i)
		
		If Not i
			Break
		
		;Get end of block, starting search at next line
		j := RegExMatch(s, "[\r\n]+\K.", "", i)
		j := RegExMatch(s, "Pm)(*ANYCRLF)^[[:blank:]]*\*/", len, j)
		
		;Make sure there's an end of block
		If Not j
			len := StrLen(s) - i
		Else len += (j - i)
		
		blank := GenSpaces(len)
		
		;Check if we need to respect line numbers
		If bRespectLines And j {
			
			;Get number of lines that would be erased
			l1 := LineFromPosEx(s, i)
			l2 := LineFromPosEx(s, j)
			
			;Put in the same amount of line feed characters
			Loop % (l2 - l1)
				NumPut(10, blank, (A_Index - 1) * (1 + !!A_IsUnicode), A_IsUnicode ? "UShort" : "UChar")
		}
		
		;Blank out
		DllCall("RtlMoveMemory", "Ptr", &s + (i - 1) * (1 + !!A_IsUnicode)
							   , "Ptr", &blank, "UInt", len * (1 + !!A_IsUnicode))
		
		If Not j
			Break
		Else i += len
	}
	
	;Get the comment flag used
	sCommentFlag := GetScriptCommentFlag(s)
	
	;Check if the very first line is a comment
	If (SubStr(s, 1, StrLen(sCommentFlag)) = sCommentFlag) {
		
		i := RegExMatch(s, "[\r\n]")
		If Not i ;The script contains only one line
			Return
		
		blank := GenSpaces(len := i - 1)
		DllCall("RtlMoveMemory", "Ptr", &s, "Ptr", &blank, "UInt", len * (1 + !!A_IsUnicode))
	}
}

GetScriptCommentFlag(ByRef s) {
	Return RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*#CommentFlag[[:blank:]]*(,|[[:blank:]]+)[[:blank:]]*"
					   . "\K.*?[[:blank:]]*$", sCommentFlag) ? sCommentFlag : ";"
}

GetScriptEscapeChar(ByRef s) {
	Return RegExMatch(s, "im)(*ANYCRLF)^[[:blank:]]*#EscapeChar[[:blank:]]*(,|[[:blank:]]+)[[:blank:]]*"
					   . "\K.*?[[:blank:]]*$", sEscapeChar) ? sEscapeChar : "``"
}

/******************\
 Listbox functions |
				 */

AppendFilename() {
	Local i, max
	
	;Check what mode we're in
	If (iAlignFilenames = 0) { ;Simple append
		
		Loop %sLabels0%
			sLabels%A_Index%_List := sLabels%A_Index% (sLabels%A_Index%_File
								  ? (AppendSymbol(sLabels%A_Index%_File) GetFile(sLabels%A_Index%_File)) : "")
		Loop %sFuncs0%
			sFuncs%A_Index%_List := sFuncs%A_Index% (sFuncs%A_Index%_File
								 ? (AppendSymbol(sFuncs%A_Index%_File) GetFile(sFuncs%A_Index%_File)) : "")
		
	} Else { ;Right-align or left-align
		
		;Populate item lengths and find the longest one
		max := 0
		Loop %sLabels0% {
			sLabels%A_Index%_Len := StrLen(sLabels%A_Index%)
			If (i := sLabels%A_Index%_File) And (iAlignFilenames = 1)
				sLabels%A_Index%_Len += StrLen(GetFile(i)) + 1 ;for symbol
			
			If (sLabels%A_Index%_Len > max)
				max := sLabels%A_Index%_Len
		}
		
		Loop %sFuncs0% {
			sFuncs%A_Index%_Len := StrLen(sFuncs%A_Index%)
			If (i := sFuncs%A_Index%_File) And (iAlignFilenames = 1)
				sFuncs%A_Index%_Len += StrLen(GetFile(i)) + 1 ;for symbol
			
			If (sFuncs%A_Index%_Len > max)
				max := sFuncs%A_Index%_Len
		}
		
		;Pad all other items so that they are of the same length
		Loop %sLabels0%
			sLabels%A_Index%_List := sLabels%A_Index% (sLabels%A_Index%_File 
								  ? (GenSpaces(max - sLabels%A_Index%_Len) AppendSymbol(sLabels%A_Index%_File)
								  . GetFile(sLabels%A_Index%_File)) : "")
		Loop %sFuncs0%
			sFuncs%A_Index%_List := sFuncs%A_Index% (sFuncs%A_Index%_File 
								  ? (GenSpaces(max - sFuncs%A_Index%_Len) AppendSymbol(sFuncs%A_Index%_File)
								  . GetFile(sFuncs%A_Index%_File)) : "")
	}
}

GenSpaces(n) {
	Static func
	If Not func {
		If (A_PtrSize = 8)
			hex := "4963C085D27413660F1F840000000000C601204803C8FFCA75F6F3C3"
		Else hex := "8B44240885C074108B4C24048B54240CC6012003CA4875F8C3"
		
		VarSetCapacity(func, StrLen(hex) // 2)
		Loop % StrLen(hex) // 2
			NumPut("0x" . SubStr(hex, 2 * A_Index - 1, 2), func, A_Index - 1, "UChar")
		DllCall("VirtualProtect", "Ptr", &func, "UInt", VarSetCapacity(func), "UInt", 0x40, "UInt*", 0)
	}
	
	VarSetCapacity(s, (n + 1) * (1 + !!A_IsUnicode), 0)
	DllCall(&func, "Ptr", &s, "UInt", n, "Int", 1 + !!A_IsUnicode, "CDecl")
	VarSetCapacity(s, -1)
	
	Return s
}

AppendSymbol(i) { ;Use \ for include files and | for library functions
	Return sPaths%i%_Inc ? " \" : " |"
}

CreateList(filter = "") { 
	Global sLabels0, sFuncs0, bMatchEverywhere, hlblList, bShowing, iIncludeMode
	Static sLastfilter := "`n"  ;Initialize on an impossible filter
	
	;Trim the right side
	While (SubStr(filter, 0) = A_Space)
		StringTrimRight, filter, filter, 1
	
	;Trim right side if it ends in " !" since it changes nothing
	If (StrLen(filter) > 2) And (SubStr(filter, -1) = " !") And (SubStr(filter, -2, 1) <> A_Space)
		StringTrimRight, filter, filter, 2
	
	;Check if the filter is different
	If (filter = sLastfilter) And bShowing
		Return
	sLastfilter := filter
	
	;Disable redraw
	GuiControl, -Redraw, lblList
	
	;Clear
	GuiControl,, lblList,|
	
	;Check if we need to take from the _List elements
	;Although it looks extremely redundant and inefficient, it is much faster than the alternative
	If (iIncludeMode & 0x10000000) {
		
		If (filter = "") {  ;Split cases for speed
			Loop %sLabels0%
				AddListBoxItem(hlblList, sLabels%A_Index%_List, A_Index)
			Loop %sFuncs0%                                               ;0xFFFF highword means function
				AddListBoxItem(hlblList, sFuncs%A_Index%_List, A_Index + (0xFFFF << 16))
		} Else {
			
			;Split cases for speed
			If bMatchEverywhere {
				
				;Parse words
				StringSplit, words, filter, %A_Space%
				
				;Split cases for speed
				If (words0 > 1) {
					
					;Check for negative conditions (!)
					Loop %words0% {
						i := words0 - (A_Index - 1) ;Proceeding backwards because we're modifying the words
						If (InStr(words%i%, "!") = 1) {
							j := i - 1
							If (j And words%j% <> "") Or Not j {
								StringTrimLeft, words%i%, words%i%, 1
								words%i%_Not := StrLen(words%i%)
							}
						}
					}
					
					Loop %sLabels0% {
						bMatch := True, i := A_Index
						Loop %words0% {
							bMatch := bMatch
									  And ((words%A_Index%_Not And Not InStr(sLabels%i%_List, words%A_Index%))
									  Or (Not words%A_Index%_Not And InStr(sLabels%i%_List, words%A_Index%)))
							If Not bMatch
								Break
						}
						If bMatch
							AddListBoxItem(hlblList, sLabels%A_Index%_List, A_Index)
					}
					Loop %sFuncs0% {
						bMatch := True, i := A_Index
						Loop %words0% {
							bMatch := bMatch
									  And ((words%A_Index%_Not And Not InStr(sFuncs%i%_List, words%A_Index%))
									  Or (Not words%A_Index%_Not And InStr(sFuncs%i%_List, words%A_Index%)))
							If Not bMatch
								Break
						}
						If bMatch
							AddListBoxItem(hlblList, sFuncs%A_Index%_List, A_Index + (0xFFFF << 16))
					}
				;It's one word
				} Else {
					
					;Check if it's a negative condition (!)
					If (InStr(filter, "!") = 1) {
						StringTrimLeft, filter, filter, 1
						bNotWord := StrLen(filter)
					}
					
					Loop %sLabels0%
						If (bNotWord And Not InStr(sLabels%A_Index%_List, filter))
						   Or (Not bNotWord And InStr(sLabels%A_Index%_List, filter))
							AddListBoxItem(hlblList, sLabels%A_Index%_List, A_Index)
					Loop %sFuncs0%
						If (bNotWord And Not InStr(sFuncs%A_Index%_List, filter))
						   Or (Not bNotWord And InStr(sFuncs%A_Index%_List, filter))
							AddListBoxItem(hlblList, sFuncs%A_Index%_List, A_Index + (0xFFFF << 16))
				}
			} Else {
				Loop %sLabels0%
					If (InStr(sLabels%A_Index%_List, filter) = 1)
						AddListBoxItem(hlblList, sLabels%A_Index%_List, A_Index)
				Loop %sFuncs0%
					If (InStr(sFuncs%A_Index%_List, filter) = 1)
						AddListBoxItem(hlblList, sFuncs%A_Index%_List, A_Index + (0xFFFF << 16))
			}
		}
		
	} Else {
		
		If (filter = "") {  ;Split cases for speed
			Loop %sLabels0%
				AddListBoxItem(hlblList, sLabels%A_Index%, A_Index)
			Loop %sFuncs0%
				AddListBoxItem(hlblList, sFuncs%A_Index%, A_Index + (0xFFFF << 16))
		} Else {
			
			;Split cases for speed
			If bMatchEverywhere {
				
				;Parse words
				StringSplit, words, filter, %A_Space%
				
				;Split cases for speed
				If (words0 > 1) {
					
					;Check for negative conditions (!)
					Loop %words0% {
						i := words0 - (A_Index - 1) ;Proceeding backwards because we're modifying the words
						If (InStr(words%i%, "!") = 1) {
							j := i - 1
							If (j And words%j% <> "") Or Not j {
								StringTrimLeft, words%i%, words%i%, 1
								words%i%_Not := StrLen(words%i%)
							}
						}
					}
					
					Loop %sLabels0% {
						bMatch := True, i := A_Index
						Loop %words0% {
							bMatch := bMatch And ((words%A_Index%_Not And Not InStr(sLabels%i%, words%A_Index%))
									  Or (Not words%A_Index%_Not And InStr(sLabels%i%, words%A_Index%)))
							If Not bMatch
								Break
						}
						If bMatch
							AddListBoxItem(hlblList, sLabels%A_Index%, A_Index)
					}
					Loop %sFuncs0% {
						bMatch := True, i := A_Index
						Loop %words0% {
							bMatch := bMatch And ((words%A_Index%_Not And Not InStr(sFuncs%i%, words%A_Index%))
									  Or (Not words%A_Index%_Not And InStr(sFuncs%i%, words%A_Index%)))
							If Not bMatch
								Break
						}
						If bMatch
							AddListBoxItem(hlblList, sFuncs%A_Index%, A_Index + (0xFFFF << 16))
					}
				;It's one word
				} Else {
					
					;Check if it's a negative condition (!)
					If (InStr(filter, "!") = 1) {
						StringTrimLeft, filter, filter, 1
						bNotWord := StrLen(filter)
					}
					
					Loop %sLabels0%
						If (bNotWord And Not InStr(sLabels%A_Index%, filter))
						   Or (Not bNotWord And InStr(sLabels%A_Index%, filter))
							AddListBoxItem(hlblList, sLabels%A_Index%, A_Index)
					Loop %sFuncs0%
						If (bNotWord And Not InStr(sFuncs%A_Index%, filter))
						   Or (Not bNotWord And InStr(sFuncs%A_Index%, filter))
							AddListBoxItem(hlblList, sFuncs%A_Index%, A_Index + (0xFFFF << 16))
				}
			} Else {
				Loop %sLabels0%
					If (InStr(sLabels%A_Index%, filter) = 1)
						AddListBoxItem(hlblList, sLabels%A_Index%, A_Index)
				Loop %sFuncs0%
					If (InStr(sFuncs%A_Index%, filter) = 1)
						AddListBoxItem(hlblList, sFuncs%A_Index%, A_Index + (0xFFFF << 16))
			}
		}
	}
	
	;Add hscrollbar if necessary
	ListBoxAdjustHSB(hlblList)
	
	;Select the first item. LB_SETCURSEL
	SendMessage 390, 0, 0,, ahk_id %hlblList%
	
	;Redraw
	GuiControl, +Redraw, lblList
}

GetFile(i, bWholePath = False) {
	Static s, lastIdx := -1
	If bWholePath
		Return sPaths%i%
	Else {
		If (i = lastIdx)
			Return s
		Else {
			s := SubStr(sPaths%i%, InStr(sPaths%i%, "\", False, 0) + 1)
			s := (SubStr(s, -3) = ".ahk" ? SubStr(s, 1, -4) : s)    ;Trim ".ahk"
			Return s
		}
	}
}

ListBoxAdjustHSB(hLB) {
	
	;Declare variables (for clarity's sake)
	dwExtent := 0
	dwMaxExtent := 0
	hDCListBox := 0
	hFontOld := 0
	hFontNew := 0
	VarSetCapacity(lptm, A_IsUnicode ? 60 : 56)
	
	;Use GetDC to retrieve handle to the display context for the list box and store it in hDCListBox
	hDCListBox := DllCall("GetDC", "Ptr", hLB, "Ptr")
	
	;Send the list box a WM_GETFONT message to retrieve the handle to the 
	;font that the list box is using, and store this handle in hFontNew
	SendMessage 49, 0, 0,, ahk_id %hLB%
	hFontNew := ErrorLevel
	
	;Use SelectObject to select the font into the display context.
	;Retain the return value from the SelectObject call in hFontOld
	hFontOld := DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontNew, "Ptr")
	
	;Call GetTextMetrics to get additional information about the font being used
	;(eg. to get tmAveCharWidth's value)
	DllCall("GetTextMetrics", "Ptr", hDCListBox, "Ptr", &lptm)
	tmAveCharWidth := NumGet(lptm, 20, "UInt")
	
	;Get item count using LB_GETCOUNT
	SendMessage 395, 0, 0,, ahk_id %hLB%
	
	;Loop through the items
	Loop %ErrorLevel% {
		
		;Get list box item text
		s := GetListBoxItem(hLB, A_Index - 1)
		
		;For each string, the value of the extent to be used is calculated as follows:
		DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", s, "Int", StrLen(s), "Int64P", nSize)
		dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth
		
		;Keep if it's the highest to date
		If (dwExtent > dwMaxExtent)
			dwMaxExtent := dwExtent
	}
	
	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontOld)
	DllCall("ReleaseDC", "Ptr", hLB, "Ptr", hDCListBox)
	
	;Adjust the horizontal bar using LB_SETHORIZONTALEXTENT
	SendMessage 404, dwMaxExtent, 0,, ahk_id %hLB%
}

AddListBoxItem(hLB, ByRef sItem, iItemData = 0) {
	SendMessage, 0x0180,, &sItem,, ahk_id %hLB% ;LB_ADDSTRING
	If iItemData
		SendMessage, 0x019A, ErrorLevel, iItemData,, ahk_id %hLB% ;LB_SETITEMDATA
}

GetListBoxItem(hLB, i) {
	
	;Get length of item. LB_GETTEXTLEN
	SendMessage 394, %i%, 0,, ahk_id %hLB%
	
	;Check for error
	If (ErrorLevel = 0xFFFFFFFF)
		Return ""
	
	;Prepare variable
	VarSetCapacity(sText, ErrorLevel * (1 + !!A_IsUnicode), 0)
	
	;Retrieve item. LB_GETTEXT
	SendMessage 393, %i%, &sText,, ahk_id %hLB%
	
	;Check for error
	If (ErrorLevel = 0xFFFFFFFF)
		Return ""
	
	;Done
	Return sText
}

GetListBoxItemData(hLB, i) {
	SendMessage, 0x0199, i,,, ahk_id %hLB% ;LB_GETITEMDATA
	Return ErrorLevel
}

GetLongestItem(hLB) { ;We need the listbox to get the font used
	Global sLabels0, sFuncs0, iIncludeMode
	
	;Declare variables (for clarity's sake)
	dwExtent := 0
	dwMaxExtent := 0
	hDCListBox := 0
	hFontOld := 0
	hFontNew := 0
	VarSetCapacity(lptm, A_IsUnicode ? 60 : 56)
	
	;Use GetDC to retrieve handle to the display context for the list box and store it in hDCListBox
	hDCListBox := DllCall("GetDC", "Ptr", hLB, "Ptr")
	
	;Send the list box a WM_GETFONT message to retrieve the handle to the 
	;font that the list box is using, and store this handle in hFontNew
	SendMessage 49, 0, 0,, ahk_id %hLB%
	hFontNew := ErrorLevel
	
	;Use SelectObject to select the font into the display context.
	;Retain the return value from the SelectObject call in hFontOld
	hFontOld := DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontNew, "Ptr")
	
	;Call GetTextMetrics to get additional information about the font being used
	;(eg. to get tmAveCharWidth's value)
	DllCall("GetTextMetrics", "Ptr", hDCListBox, "Ptr", &lptm)
	tmAveCharWidth := NumGet(lptm, 20, "UInt")
	
	;Now, we need to loop through each label/hotkey/function
	If (iIncludeMode & 0x10000000) { ;Check if we're taking from the _List elements. Split for speed
		
		Loop %sLabels0% {
			
			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sLabels%A_Index%_List
										  , "Int", StrLen(sLabels%A_Index%_List), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth
			
			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
		
		Loop %sFuncs0% {
			
			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sFuncs%A_Index%_List
										  , "Int", StrLen(sFuncs%A_Index%_List), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth
			
			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
	} Else {
		
		Loop %sLabels0% {
			
			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sLabels%A_Index%
										  , "Int", StrLen(sLabels%A_Index%), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth
			
			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
		
		Loop %sFuncs0% {
			
			;For each string, the value of the extent to be used is calculated as follows:
			DllCall("GetTextExtentPoint32", "Ptr", hDCListBox, "Str", sFuncs%A_Index%
										  , "Int", StrLen(sFuncs%A_Index%), "Int64P", nSize)
			dwExtent := (nSize & 0xFFFFFFFF) + tmAveCharWidth
			
			;Keep if it's the highest to date
			If (dwExtent > dwMaxExtent)
				dwMaxExtent := dwExtent
		}
	}
	
	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontOld)
	DllCall("ReleaseDC", "Ptr", hLB, "Ptr", hDCListBox)
	
	;Return the longest one found
	Return dwMaxExtent
}

;Used to retrieve the number of characters that can fit in a given width
GetMaxCharacters(hLB, iWidth) { ;We need the listbox to get the font used
	
	;Declare variables (for clarity's sake)
	hDCListBox := 0
	hFontOld := 0
	hFontNew := 0
	VarSetCapacity(lptm, A_IsUnicode ? 60 : 56)
	
	;Use GetDC to retrieve handle to the display context for the list box and store it in hDCListBox
	hDCListBox := DllCall("GetDC", "Ptr", hLB, "Ptr")
	
	;Send the list box a WM_GETFONT message to retrieve the handle to the 
	;font that the list box is using, and store this handle in hFontNew
	SendMessage 49, 0, 0,, ahk_id %hLB%
	hFontNew := ErrorLevel
	
	;Use SelectObject to select the font into the display context.
	;Retain the return value from the SelectObject call in hFontOld
	hFontOld := DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontNew, "Ptr")
	
	;Call GetTextMetrics to get additional information about the font being used
	DllCall("GetTextMetrics", "Ptr", hDCListBox, "Ptr", &lptm)
	tmAveCharWidth := NumGet(lptm, 20, "UInt")
	
	;After all the extents have been calculated, select the old font back into hDCListBox and then release it:
	DllCall("SelectObject", "Ptr", hDCListBox, "Ptr", hFontOld)
	DllCall("ReleaseDC", "Ptr", hLB, "Ptr", hDCListBox)
	
	Return Floor(iWidth / tmAveCharWidth)
}

/********************\
 Scintilla functions |
				   */

Sci_VScrollVisible(hSci) {
	
	;Get the number of lines visible. SCI_LINESONSCREEN
	SendMessage, 2370, 0, 0,, ahk_id %hSci%
	i := ErrorLevel
	
	;Get the number of lines in the document. SCI_GETLINECOUNT
	SendMessage, 2154, 0, 0,, ahk_id %hSci%
	
	;Check if there are more lines than what can be shown
	Return (ErrorLevel > i)
}

LineFromPos(pos) {
	Global hSci
	SendMessage, 2166, pos, 0,, ahk_id %hSci% ;SCI_LINEFROMPOSITION
	Return ErrorLevel + 1  ; line is base on 0, so we need add 1.
}

LineFromPosEx(ByRef s, pos) {
	StrReplace(SubStr(s, 1, pos), "`n", "`n", OutputVarCount)
	Return OutputVarCount + 1
}

CheckTextClick(x, y) {
	Global hSci, iPos, clickedFunc, clickedLabel
	
	;Check if we need to look for position
	If (x = -1) And (y = -1)
		SendMessage, 2008, 0, 0,, ahk_id %hSci% ;SCI_GETCURRENTPOS
	Else
		SendMessage, 2023, x, y,, ahk_id %hSci% ;SCI_POSITIONFROMPOINTCLOSE
	iPos := ErrorLevel
	
	;Check for error
	If (iPos = 0xFFFFFFFF)
		Return False
	Else
	{
		SendMessage, 2143, 0, 0,, ahk_id %hSci%  ; SCI_GETSELECTIONSTART
		selStartPos := ErrorLevel
		SendMessage, 2145, 0, 0,, ahk_id %hSci%  ; SCI_GETSELECTIONEND
		selEndPos   := ErrorLevel
		
		; if we click a selection, text is selection text. otherwise text is the word under the click.
		; selEndPos>selStartPos means real have a selection.
		If (selEndPos>selStartPos And iPos>=selStartPos And iPos<=selEndPos)
		{
			clickedFunc  := SciUtil_GetSelection(hSci)
			clickedLabel := clickedFunc
		}
		Else
		{
			clickedFunc  := SciUtil_GetWord(hSci, iPos)
			clickedLabel := clickedFunc
		}
		
		;Return true if there's something to check
		Return (clickedLabel Or clickedFunc)
	}
}

/***************\
 Line functions |
			  */

CheckFuncMatch(sHaystack) {
	Global sFuncs0
	
	Loop % sFuncs0
		If (sHaystack = sFuncs%A_Index%)
			Return A_Index
	
	Return 0
}

CheckLabelMatch(sHaystack) {
	Global sLabels0
	
	Loop % sLabels0
		If (sHaystack = sLabels%A_Index%)
			Return A_Index
	
	Return 0
}

LaunchFile(sFilePath, line) {
	Global oSciTE
	
	;Open the file in SciTE
	oSciTE.OpenFile(sFilePath)
	
	DisplayTargetLine(line)
}

ShowLine(line) {
	;Record current line before moving
	LineHistory(0, 1)
	
	DisplayTargetLine(line)
	
	;Record new line
	LineHistory(0, 2)
}

DisplayTargetLine(line)
{
	Global hSci
	Static  SCI_GotoLine            := 2024
				, SCI_GetFirstVisibleLine := 2152
				, SCI_VisibleFromDocLine  := 2220
				, SCI_LINESCROLL          := 2168
	
	; Line is zero base
	line := line - 1
	
	SendMessage, SCI_GotoLine, line, 0,, ahk_id %hSci%
	
	; Get our line on screen pos
	SendMessage, SCI_GetFirstVisibleLine, 0, 0,, ahk_id %hSci%
	firstVisibleLine := ErrorLevel
	SendMessage, SCI_VisibleFromDocLine, line, 0,, ahk_id %hSci%
	ourLineOnScreen := ErrorLevel - firstVisibleLine + 1
	
	; Make sure our line on screen is number 6, that means 5 lines before our line.
	SendMessage, SCI_LINESCROLL, 0, ourLineOnScreen - 6,, ahk_id %hSci%
}

LineHistory(bForward, iRecordMode = 0) {
	Static
	Local t
	Global sScriptPath, hSciTE, hSci, bShowing, oSciTE
	
	;If we're not showing, we need to find out what script we're on
	If Not bShowing {
		
		If Not _SciTEIsActive()
			Return
		
		SendMessage, 2381, 0, 0,, ahk_id %hSci%  ; GETFOCUS = 2381
		If (!ErrorLevel)
			Return
		
		;Get the filename
		sScriptPath := oSciTE.CurrentFile
	}
	
	;Match file
	iCurFile := 0
	Loop %iFile0% {
		If (iFile%A_Index% = sScriptPath) {
			iCurFile := A_Index
			iCurLine := iFile%A_Index%_Cur
			Break
		}
	}
	
	;If we're working on a new file, expand array
	If Not iCurFile {
		iFile0 += 1
		iCurLine := 1
		iCurFile := iFile0
		iFile%iCurFile%_Count := 0
		iFile%iCurFile% := sScriptPath
	}
	
	;Check if we just need to record
	If (iRecordMode = 1)    ;Record current line
		LH_GetCurLine(iLines%iCurLine%_%iCurFile%)
	Else If (iRecordMode = 2) { ;Record to the next line
		
		iCurLine += 1
		LH_GetCurLine(iLines%iCurLine%_%iCurFile%)
		
		;Set as the new limit
		iFile%iCurFile%_Count := iCurLine
		
	} Else If bForward {  ;Forward
		
		;Check if it is possible
		If (iCurLine < iFile%iCurFile%_Count) {
			
			;Record the line we're on now
			LH_GetCurLine(iLines%iCurLine%_%iCurFile%)
			
			;Show the next line
			iCurLine += 1
			LH_SetCurLine(iLines%iCurLine%_%iCurFile%)
		}
	} Else {    ;Backward
		
		;Check if it is possible
		If (iCurLine > 1) {
			
			;Record the line we're on now
			LH_GetCurLine(iLines%iCurLine%_%iCurFile%)
			
			;Show the previous line
			iCurLine -= 1
			LH_SetCurLine(iLines%iCurLine%_%iCurFile%)
		}
	}
	
	iFile%iCurFile%_Cur := iCurLine
}

LH_GetCurLine(ByRef uLine) {
	Global hSci
	SendMessage, 2152, 0, 0,, ahk_id %hSci% ;SCI_GETFIRSTVISIBLELINE
	uLine := ErrorLevel
	SendMessage 2008, 0, 0,, ahk_id %hSci% ;SCI_GETCURRENTPOS
	uLine += ErrorLevel << 16
}

LH_SetCurLine(ByRef uLine) {
	Global hSci
	SendMessage, 2025, uLine >> 16, 0,, ahk_id %hSci% ;SCI_GOTOPOS
	SendMessage, 2152, 0, 0,, ahk_id %hSci% ;SCI_GETFIRSTVISIBLELINE
	SendMessage, 2168, 0, (uLine & 0xFFFF) - ErrorLevel,, ahk_id %hSci% ;SCI_LINESCROLL
}

/************************\
 Miscellaneous functions |
					   */

;EmptyMem() by heresy
;http://www.autohotkey.com/forum/viewtopic.php?t=32876
EmptyMem(PID="AHK Rocks"){
	pid:=(pid="AHK Rocks") ? DllCall("GetCurrentProcessId") : pid
	h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid, "Ptr")
	DllCall("SetProcessWorkingSetSize", "Ptr", h, "Int", -1, "Int", -1)
	DllCall("CloseHandle", "Ptr", h)
}

;Based on Lazslo's CRC32() and MCode() functions
;http://www.autohotkey.com/forum/viewtopic.php?p=158999#158999
GetFileCRC32(path = False) {
	Static CRC32, CRC32_Init, CRC32LookupTable

	;Check if we're initiating
	If Not path Or Not CRC32 {
		
		;Prep MCode for CRC32_Init()
		If (A_PtrSize = 8)
			hex := "4533C0418BC0BA080000000F1F440000A8017409D1E8352083B8EDEB02D1E848FFCA75EC41FFC089014883C10441"
				 . "81F80001000072CDF3C3"
		Else hex := "8B54240433C98BC1D1E8F6C1017405352083B8EDA8017409D1E8352083B8EDEB02D1E8A8017409D1E8352083B8ED"
				 . "EB02D1E8A8017409D1E8352083B8EDEB02D1E8A8017409D1E8352083B8EDEB02D1E8A8017409D1E8352083B8EDEB0"
				 . "2D1E8A8017409D1E8352083B8EDEB02D1E8A8017409D1E8352083B8EDEB02D1E889048A4181F9000100000F8279FF"
				 . "FFFFC3"
		
		VarSetCapacity(CRC32_Init, StrLen(hex) // 2)
		Loop % StrLen(hex) // 2
			NumPut("0x" . SubStr(hex, 2 * A_Index - 1, 2), CRC32_Init, A_Index - 1, "UChar")
		
		;Prep MCode for CRC32()
		If (A_PtrSize = 8)
			hex := "85D2742D448BD2660F1F8400000000000FB611418BC048FFC14833D00FB6C2418BD0458B0481C1EA084433C249FF"
				 . "CA75DF41F7D0418BC0C3"
		Else hex := "8B5424088B44240C33C985D2742C53568B742418578B7C24108DA424000000000FB61C3933D881E3FF000000C1E8"
				  . "0833049E413BCA72E95F5E5BF7D0C3"
		
		VarSetCapacity(CRC32, StrLen(hex) // 2)
		Loop % StrLen(hex) // 2
			NumPut("0x" . SubStr(hex, 2 * A_Index - 1, 2), CRC32, A_Index - 1, "UChar")
		
		DllCall("VirtualProtect", "Ptr", &CRC32, "Ptr", VarSetCapacity(CRC32), "UInt", 0x40, "UInt*", 0)
		
		VarSetCapacity(CRC32LookupTable, 256 * 4)
		DllCall(&CRC32_Init, "Ptr", &CRC32LookupTable, "CDecl")
	}
	
	If path {
		FileGetSize, Bytes, %path%
		FileRead, Buffer, %path%
		Return DllCall(&CRC32, "Ptr", &Buffer, "UInt", Bytes, "Int", -1, "Ptr", &CRC32LookupTable, "CDecl UInt")
	}
}

GetFileEncodingWithBom(path)
{
  f := FileOpen(path, "r")
  f.Seek(0)
  header2 := Format("{:X}{:X}", f.ReadUChar(), f.ReadUChar())
  header3 := Format("{}{:X}", header2, f.ReadUChar())
  f.Close()
  
  if (header2="FFFE")
    return, 1200
  else if (header2="FEFF")
    return, 1201
  else if (header3="EFBBBF")
    return, 65001
  else
    return, 0
}

#Include %A_LineFile%\..\..\toolbar\Lib\SciUtil.ahk
#Include %A_LineFile%\..\..\toolbar\Lib\StrPutVar.ahk