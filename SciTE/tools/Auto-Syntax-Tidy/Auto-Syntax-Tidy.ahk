;Change indentation and case of commands according to syntax
;by toralf & hajos
;requires AHK 1.0.44.09
;www.autohotkey.com/forum/topic7810.html

/*
Known limitations:
 - a space is required after the last ":" for hotkeys, hotstrings and subroutine
 - comments might not have the right indentation in certain strongly
     encapsulated block-structures, due to not knowing what the next line will bring.
 - case correction only works for words longer than 4 characters,
     (except: (in all cases) If, Loop, Else
              (optional)     Goto, Gui, Run, Exit, Send, Sort, Menu
                             Parse, Read, Mouse, SendAndMouse, Default, Permit, Screen, Relative
                             Pixel, Toggle, UseErrorLevel, AlwaysOn, AlwaysOff
     !!! caution !!! case correction is dangerous, since WinTitles in commands are case sensitive

 - after doing indentation in an editor the cursor jumps
     to the first position in the last line
 - Indentation might fail, if a "{" is the last character of a Loop or If statement that
     doesn't support OTB. E.g. "If x = {" or "Loop, Parse, Var, {"

Functionality:
 - Gui: For drag&drop of files, setting of options and feedback
 - command line option "/in" for file and "/log" for log file
 - command line option "/hidden" to start script with hidden GUI
 - command line option "/watch hwnd" to start script with hidden GUI, closes itself when hwnd closes
 - command line option "/toggle" checks if another instance is running and closes both scripts
 - command line option "/hidden" to start script without GUI
 - Options:
         - custom hotkey for indenation
         - custom file extension             (overwrites old file if nothing is specified)
         - custom indentation                (one tab or a number of spaces)
         - different indentation styles      (Rajat, Toralf or BoBo)
         - indentation of continuation lines (a number of tabs or spaces)
         - indentation preservation of block continuation lines (round brackets) On/Off
         - indentation preservation of block comments           (/* ... */)      On/Off
         - case correction for syntax words with more than 4 characters  (thanks Rajat)
         - statistics for script (lines of code, comments, total and empty an time needed)
 - Dropped Files: Contents will be indented and copied to a new file with a user
                  defined extension (overwrites old file if nothing is specified).
 - Hotkey (F2): Highlighted syntax in an editor will be indented, if nothing is
                highlighted all text will be indented. (thanks ChrisM)
 - Gui remembers last position and settings between sessions (thanks Rajat)
 - The case of subroutine calls and function calls is adjusted to the case
       of their respective definitions
 - Ctrl-d toggles debug mode
 - 12% faster then version 7 (due to shortened loop cycles) but 90 lines longer

!!! Not heavily tested !!!!  ---- !!!!!! Backup your data !!!!!

Suggestions are appreciated

Wish:
 - Option to strip code: Remove empty lines, all comments, and join split expressions (&&/AND/OR/||)

changes since version 11:
- tray icon allows to toggle show/hide of GUI and to exit script
- added progressbar if identation is done inside an editor and blockinput is used to limit interference
- shortend code with functions, with new features the line numbers stay equal
- log text is scrolled to the end
- on /hidden, gui is created but hidden, tray icon is visible in both cases.
- on "/watch hwnd" , gui is hidden and closes itself when hwnd closes
- on /toggle, script checks if another instance is running and closes both scripts
- improved possibilty to find path of AHK
- added warning message if syntax files do not exist
- OwnHotKey is stored in INI file and has a control in the GUI

2013.11.21
修改AHKPath为脚本目录，语法文件目录为%AHKPath%\Syntax。bug #1
采用截止今日最新的SCITE4AHK的ahk.api文件，与1.0.48.5的语法文件进行合并。
保留旧的哪怕被移除了的命令，例如REPEAT。这样做的目的是为了支持代码格式化的正常工作。
修改默认不对KEYWORDS进行大小写纠错。bug #2
因为目前程序不够智能，当DLLCALL中函数名符合KEYWORDS时，也会进行纠错，而DLLCALL对大小写是敏感的，因此非常容易造成问题。

2013.11.22
修改代码，使其运行时直接格式化选中的或全部代码。

2014.03.06
修改代码，使其支持对for语句的格式化。feature #1

2014.03.07
修改代码，使其支持中文函数的格式化。bug #3
修改默认格式化风格。
修改代码，使其支持对While,Until,Try,Catch,Finally语句的格式化。feature #1

2014.03.15
修改代码，Until后面一句不应该缩进

2014.03.26
修改代码，改进大小写纠正的问题，以下单词总被纠正为全小写。feature #2
if
else
goto

2016.04.23
修改代码，改进大小写纠正的问题，以下单词总被纠正为全小写。feature #2
loop

2020.09.01
修复会丢掉“++num”这样的行的恶性bug。bug #4
对操作剪贴板可能出现的bug做了处理。bug #5
函数后面的花括号（花括号本身）不缩进。feature #3
修改版本号为v13。

2020.09.03
支持对switch,class语句的格式化。feature #1
大小写校正存在级别，从低到高依次是，Keywords、Keys、Variables、CommandNames、ListOfDirectives
如果低级别和高级别单词存在重复，那么总会被高级别覆盖。
例如Keys中存在单词“click”，CommandNames中也存在单词“Click”，那么大小写最终就会被纠正成后者。feature #4
修复 Variables 列表的纠正。bug #6
更新了语法文件。

2021.01.16
屏蔽GUI下的 Keywords 选项，避免此选项在GUI下被使用，因为它可能纠正dllcall里面的单词，导致代码运行失败。

2021.05.05
纠正大小写时，单词将进行全字匹配，避免 DllCall("XCGUI\XRunXCGUI") 出错。bug #7

2021.11.01
更新了语法文件。
*/

#Requires AutoHotkey v1.1.33+
#SingleInstance ignore
SetBatchLines, -1

Version = v13
ScriptName =  Auto-Syntax-Tidy %Version%

;set working dir, in case this script is called from some other script in a different dir
SetWorkingDir, %A_ScriptDir%
/*
;process command line parameters   ;by Ace_NoOne - www.autohotkey.com/forum/viewtopic.php?t=7556
If %0%{
	Loop, %0% { ; for each command line parameter
		next := A_Index + 1           ;get next parameters number
		; check if known command line parameter exists
		If (%A_Index% = "/in")
			param_in := %next%   ;assign next command line parameter as value
		Else If (%A_Index% = "/log")
			param_log := %next%
		Else If (%A_Index% = "/hidden")
			param_hidden = Hide
		Else If (%A_Index% = "/watch"){
			param_hidden = Hide
			param_watch := %next%
		}Else If (%A_Index% = "/Toggle")
			Gosub, CheckAndToggleRunState
	}
}

;Turn DebugMode on (=1) to show MsgBox with Debug Info
DebugMode = 0

;location of icon file
If ( A_OSType = "WIN32_WINDOWS" )  ; Windows 9x
	IconFile = %A_WinDir%\system\shell32.dll
Else
	IconFile = %A_WinDir%\system32\shell32.dll

;tray menu
Menu, Tray, Icon, %IconFile%, 56   ;icon for taskbar and for Process in task manager
Menu, Tray, Tip, %ScriptName%
Menu, Tray, NoStandard
Menu, Tray, Add, Show/Hide, ShowHideGui
Menu, Tray, Add, Exit, ExitApp
Menu, Tray, Default, Show/Hide
Menu, Tray, Click, 1
*/
SplitPath, A_ScriptName, , , , OutNameNoExt
IniFile = %OutNameNoExt%.ini
Gosub, ReadDataFromIni


; find path to AHK
; 将工作目录固定为脚本目录，Syntax文件夹自然也固定在里面了。bug #1
AHKPath:=A_ScriptDir
IfNotExist %AHKPath%
{ MsgBox,,, Could not find the AutoHotkey folder.`nPlease edit the script:`n%A_ScriptFullPath%`nin Linenumber: %A_LineNumber%
	ExitApp
}

Gosub, ReadSyntaxFiles
/*
If FileExist(param_in){
	Gosub, IndentFile
	ExitApp
}

Gosub, BuildGui

If param_watch
	SetTimer, WatchWindow, On
*/
Gosub,IndentHighlightedText
ExitApp
Return
/*
;disable hotkey in its own gui
Hotkey, IfWinNotActive, %GuiUniqueID%
;set hotkey and remember it
Hotkey, %OwnHotKey%, IndentHighlightedText
OldHtk = %OwnHotKey%
Hotkey, IfWinNotActive,
Return
*/
;#############   End of autoexec section   ####################################

;#############   Toogle debug modus   #########################################
^d::
	DebugMode := not DebugMode
	ToolTip, DebugMode = %DebugMode%
	Sleep, 1000
	ToolTip
Return

;#############   Close script when watch window doesn't exist   ###############
WatchWindow:
	DetectHiddenWindows, On
	If !WinExist("ahk_id " param_watch)  ;check if watch window exists
		Gosub, GuiClose                  ;if not close this script
	DetectHiddenWindows, Off
Return

;#############   Toogle run status - close on second run   ####################
CheckAndToggleRunState:
	;get own PID
	Process, Exist
	OwnPID := ErrorLevel

	;get own title
	If A_IsCompiled
		OwnTitle := A_ScriptFullPath
	Else
		OwnTitle := A_ScriptFullPath " - AutoHotkey v" A_AhkVersion

	;get list of all windows
	DetectHiddenWindows, On
	WinGet, WinIDs, List

	;go through list and get their titles
	Loop, %WinIDs% {
		UniqueID := "ahk_id " WinIDs%A_Index%
		WinGetTitle, winTitle, %UniqueID%

		;check if there is a window with the same title as this script but not itself
		If (winTitle = OwnTitle ) {
			WinGet, winPID, PID, %UniqueID%
			If (winPID <> OwnPID) {
				;close it and itself
				Process, Close, %winPID%
				ExitApp
			}
		}
	}
	DetectHiddenWindows, off
Return

;#############   Read directives and commands from syntax file   ##############
ReadSyntaxFiles:
	;path to syntax files
	PathSyntaxFiles = %AHKPath%\Syntax		; bug #1

	;clear lists
	ListOfDirectives =
	;这个列表从文件中读取类似 IfInString 的以If开头的命令，然后进行缩进。feature #1
	;所以可以直接把后期没被支持的流程命令添加到这里面，让程序识别以进行缩进……
	;当时改for的缩进时就没想到这一点……
	ListOfIFCommands = ,for,while,try,catch,finally,switch,class

	;read each line of syntax file and search for directives and if-keywords
	CommandNamesFile = %PathSyntaxFiles%\CommandNames.txt
	IfNotExist %CommandNamesFile%
	{ MsgBox,,, Could not find the "CommandNames.txt" file.`nPlease edit the script:`n%A_ScriptFullPath%`nin Linenumber: %A_LineNumber%
		ExitApp
	}
	Loop, Read , %CommandNamesFile%   ;Read syntax file
	{ ;remove spaces from read line
		Line = %A_LoopReadLine%
		Line:=Trim(Line, " `t`r`n`v`f")

		;get first character and first 2 characters of line
		StringLeft,FirstChar, Line ,1
		StringLeft,FirstTwoChars, Line ,2

		;if line is comment, continue with next line
		If (FirstChar = ";")
			Continue
		;otherwise if keyword is directive or if-keyword add it to list
		Else If (FirstChar = "#")
			ListOfDirectives=%ListOfDirectives%,%Line%
		Else If (FirstTwoChars = "if") {
			;get first word, since If-keywords in the syntax file have more words
			StringSplit, Array, Line, %A_Space%
			Line = %Array1%
			If (StrLen(Line) > 4)
				ListOfIFCommands=%ListOfIFCommands%,%Line%
		}
	}
	;remove first comma and change to lower char
	StringTrimLeft,ListOfIFCommands,ListOfIFCommands,1
	StringTrimLeft,ListOfDirectives,ListOfDirectives,1

	;remove multiple If
	Sort, ListOfIFCommands, U D,

	FilesSyntax = CommandNames|Keywords|Keys|Variables

	;Loop over all syntax files
	Loop, Parse, FilesSyntax, |
	{ String =
		SyntaxFile = %PathSyntaxFiles%\%A_LoopField%.txt
		IfNotExist %SyntaxFile%
		{ MsgBox,,, Could not find the syntax file "%A_LoopField%.txt".`nPlease edit the script:`n%A_ScriptFullPath%`nin Linenumber: %A_LineNumber%
			ExitApp
		}
		filename:=A_LoopField
		;read each line of syntax file
		Loop, Read , %SyntaxFile%
		{
			;remove spaces from read line
			Line = %A_LoopReadLine%
			Line:=Trim(Line, " `t`r`n`v`f")

			;get first character, length of line and look for spaces
			StringLeft,FirstChar, Line ,1

			;if line contains spaces, continue with next line
			If InStr(Line," ")
				Continue
			;if line is empty, continue with next line
			Else If Line is Space
				Continue
			;if line is comment, continue with next line
			Else If (FirstChar = ";")
				Continue
			;otherwise if word is longer than 4 character, remember it
			; 原版单独处理的 Variables 列表，并且将其分隔符设置为了“|”。
			; 搞不懂原版这么做的意义何在，因为 Variables 列表只在以后的大小写纠正处被使用。
			; 而大小写纠正又是用“,”做分隔符的，所以原版 Variables 纠正是一直失效的…… bug #6
			Else If (StrLen(Line) > 4 or filename="Variables")
				String = %String%,%Line%
		}
		;remove first pipe
		StringTrimLeft,String,String,1
		;store remembered string in var which has same name as syntaxfile
		%A_LoopField% := String
	}

	; 这里的词都是没有被加入列表的
	CommandNames = %CommandNames%,Gui,Run,Edit,Exit,goto,Send,Sort,Menu
									,Files,Reg,Parse,Read,Mouse,SendAndMouse,Permit,Screen,Relative
									,Pixel,Toggle,UseErrorLevel,AlwaysOn,AlwaysOff

	;read in all function names
	BuildInFunctions =
	;read each line of syntax file
	FunctionsFile = %PathSyntaxFiles%\Functions.txt
	IfNotExist %SyntaxFile%
	{ MsgBox,,, Could not find the "Functions.txt" file.`nPlease edit the script:`n%A_ScriptFullPath%`nin Linenumber: %A_LineNumber%
		ExitApp
	}
	Loop, Read , %FunctionsFile%
	{ ;remove spaces from read line
		Line = %A_LoopReadLine%

		;get first character, and name of function plus its braket, e.g. "ATan("
		StringLeft,FirstChar, Line ,1
		StringSplit, Line, Line, (
		Line1:=Trim(Line1, " `t`r`n`v`f")

		;if line is empty, continue with next line
		If Line is Space
			Continue
		;if line is comment, continue with next line
		Else If (FirstChar = ";")
			Continue
		;otherwise remember it with braket
		Else
			BuildInFunctions = %BuildInFunctions%,%Line1%(
	}
	;don't remove first comma, it will be done just before correction

Return

;#############   Read Data from Ini file   ####################################
ReadDataFromIni:
	IniRead, Extension, %IniFile%, Settings, Extension, _autoindent_%Version%.ahk
	IniRead, Indentation, %IniFile%, Settings, Indentation, 1
	IniRead, NumberSpaces, %IniFile%, Settings, NumberSpaces, 2
	IniRead, NumberIndentCont, %IniFile%, Settings, NumberIndentCont, 1
	IniRead, IndentCont, %IniFile%, Settings, IndentCont, 1
	IniRead, Style, %IniFile%, Settings, Style, 1
	IniRead, CaseCorrectCommands, %IniFile%, Settings, CaseCorrectCommands, 1
	IniRead, CaseCorrectVariables, %IniFile%, Settings, CaseCorrectVariables, 1
	IniRead, CaseCorrectBuildInFunctions, %IniFile%, Settings, CaseCorrectBuildInFunctions, 1
	IniRead, CaseCorrectKeys, %IniFile%, Settings, CaseCorrectKeys, 1
	IniRead, CaseCorrectKeywords, %IniFile%, Settings, CaseCorrectKeywords, 0		; bug #2
	IniRead, CaseCorrectDirectives, %IniFile%, Settings, CaseCorrectDirectives, 1
	IniRead, Statistic, %IniFile%, Settings, Statistic, 1
	IniRead, ChkSpecialTabIndent, %IniFile%, Settings, ChkSpecialTabIndent, 1
	IniRead, KeepBlockCommentIndent, %IniFile%, Settings, KeepBlockCommentIndent, 0
	IniRead, AHKPath, %IniFile%, Settings, AHKPath, %A_Space%
	IniRead, OwnHotKey, %IniFile%, Settings, OwnHotKey, F2
Return

OwnHotKey:
	;deacticate old hotkey
	Hotkey, IfWinNotActive, %GuiUniqueID%
	Hotkey, %OldHtk%, IndentHighlightedText, Off
	;Don't allow no hotkey
	If OwnHotKey is Space
	{
		Hotkey, %OldHtk%, IndentHighlightedText
		GuiControl, , OwnHotKey, %OldHtk%
	}Else{
		Hotkey, %OwnHotKey%, IndentHighlightedText
		OldHtk = %OwnHotKey%
	}
	Hotkey, IfWinNotActive,
Return

;#############   Build GUI for Auto-Syntax-Tidy   #############################
BuildGui:
	LogText = Drop your files for indentation on this Gui.`nOr highlight AHK syntax in script and press %OwnHotKey%.`n`n

	Gui, +ToolWindow +AlwaysOnTop
	Gui, Add, Text, xm Section ,Hotkey
	Gui, Add, Hotkey, ys-3 r1 w165 vOwnHotKey gOwnHotKey, %OwnHotKey%

	Gui, Add, Text, xm Section ,Extension for files
	Gui, Add, Edit, ys-3 r1 w117 vExtension, %Extension%

	Gui, Add, GroupBox, xm w210 r6.3,Indentation
	Gui, Add, Text, xp+8 yp+15 Section,Type:
	Gui, Add, Radio, ys vIndentation,1xTab or
	Gui, Add, Radio, ys Checked,Spaces
	Gui, Add, Edit, ys-3 r1 Limit1 Number w15 vNumberSpaces, %NumberSpaces%
	Gui, Add, Text, xs Section,Style:
	Gui, Add, Radio, x+8 ys vStyle,Rajat
	Gui, Add, Radio, x+8 ys Checked,Toralf
	Gui, Add, Radio, x+8 ys ,BoBo
	Gui, Add, Text, xs Section,Indentation of Method1 continuation Lines:
	Gui, Add, Edit, xs ys+15 Section r1 Limit2 Number w20 vNumberIndentCont, %NumberIndentCont%
	Gui, Add, Radio, ys+4 vIndentCont ,Tabs or
	Gui, Add, Radio, ys+4 Checked,Spaces
	Gui, Add, Checkbox, xs vKeepBlockCommentIndent Checked%KeepBlockCommentIndent%, Preserve indent. in Block comments
	Gui, Add, Checkbox, xs vChkSpecialTabIndent Checked%ChkSpecialTabIndent%, Special "Gui,Tab" indent

	Gui, Add, GroupBox, xm w210 r3,Case-Correction for
	Gui, Add, Checkbox, xp+8 yp+18 Section vCaseCorrectCommands Checked%CaseCorrectCommands%,Commands
	Gui, Add, Checkbox, vCaseCorrectVariables Checked%CaseCorrectVariables%,Variables
	Gui, Add, Checkbox, vCaseCorrectBuildInFunctions Checked%CaseCorrectBuildInFunctions%,Build in functions
	Gui, Add, Checkbox, ys vCaseCorrectKeys Checked%CaseCorrectKeys%,Keys
	Gui, Add, Checkbox, vCaseCorrectKeywords Checked%CaseCorrectKeywords% Disabled,Keywords
	Gui, Add, Checkbox, vCaseCorrectDirectives Checked%CaseCorrectDirectives%,Directives
	Gui, Add, Text, xm Section, Information
	Gui, Add, Checkbox, ys vStatistic Checked%Statistic%, Statistic
	Gui, Add, Edit, xm r10 w210 vlog ReadOnly, %LogText%

	If (Indentation = 1)
		GuiControl,,1xTab or,1
	If (Style = 1)
		GuiControl,,Rajat,1
	Else If (Style = 3)
		GuiControl,,BoBo,1
	If (IndentCont = 1)
		GuiControl,, IndentCont, 1

	;get previous position and show Gui
	IniRead, Pos_Gui, %IniFile%, General, Pos_Gui, CEnter
	Gui, Show, %Pos_Gui% %param_Hidden% ,%ScriptName%
	Gui, +LastFound
	GuiUniqueID := "ahk_id " WinExist()

	;get classNN of log control
	GuiControl, Focus, Log
	ControlGetFocus, ClassLog, %GuiUniqueID%
	GuiControl, Focus, Extension
Return

;#############   Toggle show / hide of Gui from tray icon   ###################
ShowHideGui:
	If param_Hidden {
		Gui, Show
		param_Hidden =
	}Else{
		param_Hidden = Hide
		Gui, Show, %param_Hidden%
	}
Return

;#############   Function iif: returns a or b depending on expression   #######
iif(exp,a,b=""){
	If exp
		Return a
	Return b
}

;#############   Shortcut F? - indent highlighted text   ######################
IndentHighlightedText:
	;store time for speed measurement
	StartTime = %A_TickCount%

	;Save and clear clipboard
	ClipSaved := ClipboardAll
	Clipboard =
	Sleep, 50           ;一定要有这一句，才能在clipjump运行的同时，取到剪贴板的值。bug #5

	;Cut highlight to clipboard
	Send, ^c

	;get window UID of current window
	WinUniqueID := WinExist("A")

	;If nothing is highlighted, select all and copy
	If Clipboard is Space
	{ ;Select all and copy to clipboard
		Send, ^a^c
	}

	;get rid of all carriage returns (`r).
	StringReplace, ClipboardString, Clipboard, `r`n, `n, All

	;restore the original clipboard and free memory
	Clipboard := ClipSaved
	ClipSaved =

	;If something is selected, do the indentation and put it back in again
	If ClipboardString is Space
		MsgBox, 0 , %ScriptName%,
	(LTrim
		Couldn't get anything to indent.
		Please try again.
	), 1
	Else {
		;get Options
		Gui, Submit, NoHide

		;create progress bar and block input
		StringReplace, x, ClipboardString, `n, `n, All UseErrorLevel
		NumberOfLines = %ErrorLevel%
		Progress, R0-%NumberOfLines% FM10 WM8000 FS8 WS400, `n, Please wait`, auto-syntax-tidy is Running, %ScriptName%
		BlockInput, On

		;set words for case correction
		Gosub, SetCaseCorrectionSyntax

		;create indentation
		Gosub, CreateIndentSize

		;reset all values
		Gosub, SetStartValues

		;Read each line form clipboard
		Loop, Parse, ClipboardString, `n
		{ ;remember original line with its identation
			AutoTrim, Off
			Original_Line = %A_LoopField%
			AutoTrim, On

			;do the indentation
			Gosub, DoSyntaxIndentation

			;update progress bar every 10th line
			If (Mod(A_Index, 10)=0)
				Progress, %A_Index%, Line: %A_Index% of %NumberOfLines%
		}

		CaseCorrectSubsAndFuncNames()

		;remove last `n
		StringTrimRight,String,String,1

		;Save and clear clipboard
		ClipSaved := ClipboardAll
		Clipboard =
		Sleep, 50           ;一定要有这一句，才能在clipjump运行的同时，取到剪贴板的值bug #5

		;put String into clipboard
		;StringReplace, String, String, `n, `r`n, All
		Clipboard = %String%

		;close progress bar and activate old window again
		Progress, Off
		WinActivate, ahk_id %WinUniqueID%

		;paste clipboard
		Send, ^v{HOME}
		;restore the original clipboard and free memory
		Clipboard := ClipSaved
		ClipSaved =

		;turn off block input
		BlockInput, Off

		;write information
		LogText = %LogText%Indentation done for text in editor.`n
		If Statistic
			Gosub, AddStatisticToLog
		Else
			LogText = %LogText%`n
		GuiControl, ,Log , %LogText%
		ControlSend, %ClassLog%, ^{End}, %GuiUniqueID%
	}
Return

;#############   Set words for case correction   ##############################
SetCaseCorrectionSyntax:
	; 大小写校正原理是简单粗暴的使用“CaseCorrectionSyntax”列表中的每个词依次做校正。
	; 所以修改它们的优先级别，从低到高依次是，Keywords、Keys、Variables、CommandNames、ListOfDirectives
	; 如果低级别和高级别单词存在重复，那么总会被高级别覆盖。
	; 例如Keys中存在单词“click”，CommandNames中也存在单词“Click”，那么大小写最终就会被纠正成后者。feature #4
	; 这样设计的原因是，Keywords中存在大量和其它文件重复的单词，原来需要手工把它们标记出来注释掉，现在只需简单更新文件即可。
	; 同时，在没有进行独立识别单词属性的前提下，也应该按这样的优先级进行处理（后者覆盖前者）。
	CaseCorrectionSyntax:=""
	If CaseCorrectKeywords
		CaseCorrectionSyntax.="," Keywords
	If CaseCorrectKeys
		CaseCorrectionSyntax.="," Keys
	If CaseCorrectVariables
		CaseCorrectionSyntax.="," Variables
	If CaseCorrectCommands
		CaseCorrectionSyntax.="," CommandNames
	If CaseCorrectDirectives
		CaseCorrectionSyntax.="," ListOfDirectives
	;remove first pipe
	StringTrimLeft, CaseCorrectionSyntax, CaseCorrectionSyntax, 1
Return

;#############   Create indentation size depending on options   ###############
CreateIndentSize:
	;clear
	IndentSize =
	IndentContLine =

	;turn of autotrim to be able to assign Spaces and tabs
	AutoTrim, Off

	;Create indentation size depending on option
	If Indentation = 1
		IndentSize = %A_Tab%
	Else
		Loop, %NumberSpaces%
			IndentSize = %IndentSize%%A_Space%

		;Create indentation for line continuation
	If IndentCont = 1
		Loop, %NumberIndentCont%
			IndentContLine = %IndentContLine%%A_Tab%
	Else
		Loop, %NumberIndentCont%
			IndentContLine = %IndentContLine%%A_Space%

		;set autotrim to default
	AutoTrim, On
Return

;#############   Reset all start values   #####################################
SetStartValues:
	String =                 ;string that holds temporarely the file content (with auto-indentation)
	Indent =                 ;indentation string
	IndentIndex = 0          ;Index of array IndentIncrement and IndentCommand
	InBlockComment := False  ;Status if loop is in a Blockcomment
	InsideContinuation := False
	InsideTab = 0
	EmptyLineCount = 0       ;Counts the Number of empty Lines for statistics
	TotalLineCount = 0       ;Counts the Number of total Lines for statistics
	CommentLineCount = 0     ;Counts the Number of comments Lines for statistics
	If CaseCorrectBuildInFunctions
		CaseCorrectFuncList = %BuildInFunctions%  ;CSV list of function names in current script including build in functions
	Else
		CaseCorrectFuncList =                     ;CSV list of function names in current script
	CaseCorrectSubsList=     ;CSV list of subroutine names in current script
	Loop, 11{
		IndentIncrement%A_Index% =
		IndentCommand%A_Index% =
	}
Return

;#############   Indent all dropped files   ###################################
GuiDropFiles:
	;store time for speed measurement
	OverAllStartTime = %A_TickCount%

	;get options
	Gui, Submit,NoHide

	;set words for case correction
	Gosub, SetCaseCorrectionSyntax

	;create indentation
	Gosub, CreateIndentSize

	OverAllCodeLineCount = 0
	OverAllTotalLineCount = 0
	OverAllCommentLineCount = 0
	OverAllCommentLineCount = 0

	;for each dropped file, read file line by line and indent each line
	Loop, Parse, A_GuiControlEvent, `n
	{ ;store time for speed measurement
		StartTime = %A_TickCount%

		;file
		FileToautoIndent = %A_LoopField%

		;reset start values
		Gosub, SetStartValues

		;Read each line in the file and do indentation
		Loop, Read, %FileToautoIndent%
		{ ;remember original line with its identation
			AutoTrim, Off
			Original_Line = %A_LoopReadLine%
			AutoTrim, On

			;do indentation
			Gosub, DoSyntaxIndentation
		}

		CaseCorrectSubsAndFuncNames()

		;paste file with auto-indentation into new file
		;  if Extension is empty, old file will be overwritten
		FileDelete, %FileToautoIndent%%Extension%
		FileAppend, %String%,%FileToautoIndent%%Extension%

		;write information
		LogText = %LogText%Indentation done for: %FileToautoIndent%`n
		If Statistic
			Gosub, AddStatisticToLog
		Else
			LogText = %LogText%`n
		GuiControl, ,Log , %LogText%
		ControlSend, %ClassLog%, ^{End}, %GuiUniqueID%
	}
	If Statistic {
		LogText = %LogText%=====Statistics:=======`n
		LogText = %LogText%=====over all files====`n
		LogText = %LogText%Lines with code: %A_Tab%%A_Tab%%OverAllCodeLineCount%`n
		LogText = %LogText%Lines with comments: %A_Tab%%OverAllCommentLineCount%`n
		LogText = %LogText%Empty Lines: %A_Tab%%A_Tab%%OverAllEmptyLineCount%`n
		LogText = %LogText%Total Number of Lines: %A_Tab%%OverAllTotalLineCount%`n
		;time for speed measurement
		OverAllTimeNeeded := (A_TickCount - OverAllStartTime) / 1000
		LogText = %LogText%Total Process time: %A_Tab%%OverAllTimeNeeded%[s]`n`n
		GuiControl, ,Log , %LogText%
		ControlSend, %ClassLog%, ^{End}, %GuiUniqueID%
	}
Return

;#############   Add statistics to log   ######################################
AddStatisticToLog:
	;calculate lines of code
	CodeLineCount := TotalLineCount - CommentLineCount - EmptyLineCount

	OverAllCodeLineCount    += CodeLineCount
	OverAllTotalLineCount   += TotalLineCount
	OverAllCommentLineCount += CommentLineCount
	OverAllEmptyLineCount   += EmptyLineCount

	;add information
	LogText = %LogText%=====Statistics:=====`n
	LogText = %LogText%Lines with code: %A_Tab%%A_Tab%%CodeLineCount%`n
	LogText = %LogText%Lines with comments: %A_Tab%%CommentLineCount%`n
	LogText = %LogText%Empty Lines: %A_Tab%%A_Tab%%EmptyLineCount%`n
	LogText = %LogText%Total Number of Lines: %A_Tab%%TotalLineCount%`n
	;time for speed measurement
	TimeNeeded := (A_TickCount - StartTime) / 1000
	LogText = %LogText%Process time: %A_Tab%%TimeNeeded%[s]`n`n
Return

;#############   Indent file from command line   ##############################
IndentFile:
	;set words for case correction
	Gosub, SetCaseCorrectionSyntax

	;create indentation
	Gosub, CreateIndentSize

	;file
	FileToautoIndent = %param_in%

	;reset start values
	Gosub, SetStartValues

	;Read each line in the file and do indentation
	Loop, Read, %FileToautoIndent%
	{ ;remember original line with its identation
		AutoTrim, Off
		Original_Line = %A_LoopReadLine%
		AutoTrim, On

		;do indentation
		Gosub, DoSyntaxIndentation
	}

	CaseCorrectSubsAndFuncNames()

	;remove old file and paste with auto-indentation into same file
	FileDelete, %FileToautoIndent%
	FileAppend, %String%, %FileToautoIndent%

	;write information to log file
	LogText = Indentation done for: %FileToautoIndent%`n
	If Statistic
		Gosub, AddStatisticToLog
	FileAppend , %LogText%, %param_log%
Return

;#############   Create indentation for next loop depending on IndentIndex   ##
SetIndentForNextLoop:
	;clear
	Indent =
	If IndentIndex < 0            ;in case something went wrong
		IndentIndex = 0

	;turn AutoTrim off, to be able to process tabs and spaces
	AutoTrim, Off

	;Create indentation depending on IndentIndex
	Loop, %IndentIndex% {
		Increments := IndentIncrement%A_Index%
		Loop, %Increments%
			Indent = %Indent%%IndentSize%
	}

	;turn AutoTrim on, to remove leading and trailing tabs and spaces
	AutoTrim, On
Return

;#############   Strip comments from Line   ###################################
StripCommentsFromLine(Line) {
	StartPos = 1
	Loop {   ;go from semicolon to semicolon, start at 2nd position, First doesn't make sence, since it would be a comment
		StartPos := InStr(Line,";","",StartPos + 1)
		If (StartPos > 1) {
			;the following is not very robust but it will serve for most cases that a ";" is inside an := or () expression
			; limitations:
			; - comments that include a " on an := expression line
			; - comments that include a ") on an ()expression line
			StringMid,CharBeforeSemiColon, Line, StartPos - 1 , 1
			If (CharBeforeSemiColon = "``")            ;semicolon is Escaped
				Continue
			Else If ( 0 < InStr(Line,":=") AND InStr(Line,":=") < StartPos
											AND 0 < InStr(Line,"""") AND InStr(Line,"""") < StartPos
											AND 0 < InStr(Line,"""","",StartPos) )   ;It on the right side of an := expression and surounded with "..."
				Continue
			Else If ( 0 < InStr(Line,"(") AND InStr(Line,"(") < StartPos
											AND InStr(Line,")","",StartPos) > StartPos
											AND 0 < InStr(Line,"""") AND InStr(Line,"""") < StartPos
											AND 0 < InStr(Line,"""","",StartPos) )    ;It is inside and () expression and surounded with "..."
				Continue
			Else {                                     ;it is a semicolon
				StringLeft, Line, Line, StartPos - 1   ;get CommandLine up to semicolon
				Line = %Line%                          ;remove Spaces
				Return Line
			}
		} Else   ;no more semicolon found, hence no comments on this line
			Return Line
	}
}

;#############   Function MemorizeIndent: Store list of indentations   ########
MemorizeIndent(Command,Increment,Index=0){
	global
	If (Index > 0)
		IndentIndex += %Index%
	Else If (Index < 0)
		IndentIndex := Abs(Index)
	IndentCommand%IndentIndex% = %Command%
	IndentIncrement%IndentIndex% = %Increment%
}

;#############   Perform the syntax indentation for each given line   #########
DoSyntaxIndentation:
	;count line
	TotalLineCount ++

	;##################################
	;########### judge on line   ######
	;##################################
	;remove space and tabs from beginning and end of original line
	Line = %Original_Line%

	If Line is Space                ;nothing in line
	{ String = %String%`n

		;count line
		EmptyLineCount ++
		Gosub, FinishThisLine
		Return  ;Continue with next line
	}

	;##################################
	;########### judge on first chars
	;##################################
	;get first and last characters of line
	StringLeft,  FirstChar    , Line, 1
	StringLeft,  FirstTwoChars, Line, 2

	FinishThisLine := False

	;turn AutoTrim off, to be able to process tabs and spaces
	AutoTrim, Off

	If (FirstTwoChars = "*/") {          ;line is end of BlockComment
		String = %String%%Line%`n
		InBlockComment := False
		CommentLineCount ++
		FinishThisLine := True
	}

	Else If InBlockComment {              ;line is inside the BlockComment
		If KeepBlockCommentIndent
			String = %String%%Original_Line%`n
		Else
			String = %String%%Line%`n
		CommentLineCount ++
		FinishThisLine := True
	}

	Else If (FirstTwoChars = "/*") {          ;line is beginning of a BlockComment, end will be */
		String = %String%%Line%`n
		InBlockComment := True
		CommentLineCount ++
		FinishThisLine := True
	}

	Else If (FirstChar = ":") {                 ;line is hotstring
		String = %String%%Line%`n
		MemorizeIndent("Sub",1,-1)
		FinishThisLine := True
	}

	Else If (FirstChar = ";") {          ;line is comment
		String = %String%%Indent%%Line%`n
		CommentLineCount ++
		FinishThisLine := True
	}

	If FinishThisLine {
		Gosub, FinishThisLine
		Return  ;Continue with next line
	}

	;turn AutoTrim back on
	AutoTrim, On

	;##################################
	;########### judge on commands/words
	;##################################

	;get pure command line
	StripedLine := StripCommentsFromLine(Line)

	;get last character of CommandLine
	StringRight, LastChar     , StripedLine, 1

	;get shortest first, second and third word of CommandLine
	Loop, 3
		CommandLine%A_Index% =
	StringReplace, CommandLine, StripedLine, %A_Tab%, %A_Space%,All
	StringReplace, CommandLine, CommandLine, `, , %A_Space%,All
	StringReplace, CommandLine, CommandLine, {, %A_Space%,All
	StringReplace, CommandLine, CommandLine, }, %A_Space%,All
	StringReplace, CommandLine, CommandLine, %A_Space%if(, %A_Space%if%A_Space%,All
	StringReplace, CommandLine, CommandLine, ), %A_Space%,All
	StringReplace, CommandLine, CommandLine, %A_Space%%A_Space%%A_Space%%A_Space%, %A_Space%,All
	StringReplace, CommandLine, CommandLine, %A_Space%%A_Space%%A_Space%, %A_Space%,All
	StringReplace, CommandLine, CommandLine, %A_Space%%A_Space%, %A_Space%,All
	CommandLine = %CommandLine%  ;remove Spaces from begining and end
	StringSplit, CommandLine, CommandLine, %A_Space%
	FirstWord  = %CommandLine1%
	SecondWord = %CommandLine2%
	ThirdWord  = %CommandLine3%

	;get last character of First word
	StringRight, FirstWordLastChar,  FirstWord,  1

	;check if previoulsly found function name is really a function definition
	;if line is not start of bracket block but a funtion name exists
	If ( FirstChar <> "{" AND IndentIndex = 1 AND   FunctionName <> "") {
		FunctionName =         ; then that previous line is not a function definition.
		IndentIndex = 0         ; set back the indentation, which was previously set.
		Gosub, SetIndentForNextLoop
	}

	;Assume line is not a function
	FirstWordIsFunction := False
	;If no indentation and bracket not as first character it might be a function
	If ( IndentIndex = 0 And InStr(FirstWord,"(") > 0 )
		FirstWordIsFunction := ExtractFunctionName(FirstWord,InStr(FirstWord,"("),FunctionName)

	LineIsTabSpecialIndentStart := False
	LineIsTabSpecialIndent      := False
	LineIsTabSpecialIndentEnd   := False
	If (ChkSpecialTabIndent AND FirstWord = "Gui") {
		If (InStr(SecondWord,"add") And ThirdWord = "tab")
			LineIsTabSpecialIndentStart := True
		Else If (InStr(SecondWord,"tab")) {
			If ThirdWord is Space
				LineIsTabSpecialIndentEnd := True
			Else
				LineIsTabSpecialIndent := True
		}
	}

	;turn AutoTrim off, to be able to process tabs and spaces
	AutoTrim, Off

	;###### Start to adjust indentation ##########

	If FirstWord in %ListOfDirectives%         ;line is directive
	{ Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7	; bug #7
		String = %String%%Line%`n
	}
	; bug #4
	; 原版错误的用了2个if，导致通过首字符以为自己是热键。
	; 进入到情况处理中，结果又识别不到“::”，发现自己不是热键，又跳不回去了，又没处理异常情况。
	; 于是就出现了像 ++num 这样的行会被丢掉的情况。
	; 解决方案就是把里面的if提出来，和外面的if做联合判断，避免错误进入情况处理。
	Else If InStr("#!^+<>*~$", FirstChar) AND InStr(FirstWord,"::")		;line is Hotkey (has be be after directives due to the #)
	{
			String = %String%%Line%`n
			MemorizeIndent("Sub",1,-1)
	}
	Else If (FirstChar = "," OR FirstTwoChars = "||" OR FirstTwoChars = "&&"
									OR FirstWord = "and" OR FirstWord = "or" )                     ;line is a implicit continuation
		String = %String%%Indent%%IndentContLine%%Line%`n
	Else If (FirstChar = ")" and InsideContinuation) {  ;line is end of a continuation block
		Gosub, SetIndentOfLastBracket
		String := String . Indent . iif(Style=1,"",IndentSize) . Line . "`n"
		;IndentIndex doesn't need to be reduced, this is done inside SetIndentOfLastBracket
		InsideContinuation := False
	}
	Else If InsideContinuation {                ; line is inside a continuation block
		If AdjustContinuation
			String = %String%%Indent%%Line%`n
		Else
			String = %String%%Original_Line%`n
	}
	Else If (FirstChar = "(") {                 ;line is beginning of a continuation block
		String := String . Indent . iif(Style>1,IndentSize) . Line . "`n"
		MemorizeIndent("(",iif(Style=2,2,1),+1)
		AdjustContinuation := False
		If ( InStr(StripedLine, "LTrim") > 0 AND InStr(StripedLine, "RTrim0") = 0)
			AdjustContinuation := True
		InsideContinuation := True                  ;allow nested cont's
	}
	Else If LineIsTabSpecialIndentStart {                   ;line is a "Gui, Add, Tab" line
		String = %String%%Indent%%Line%`n
		MemorizeIndent("AddTab",1,+1)
	}
	Else If LineIsTabSpecialIndent {                        ;line is a "Gui, Tab, TabName" line
		Gosub, SetIndentOfLastAddTaborBracket
		String = %String%%Indent%%IndentSize%%Line%`n
		MemorizeIndent("Tab",1,+2)
	}
	Else If LineIsTabSpecialIndentEnd {                     ;line is a "Gui, Tab" line
		Gosub, SetIndentOfLastAddTaborBracket
		String = %String%%Indent%%Line%`n
	}
	Else If (FirstWordLastChar = ":") {   ;line is start of subroutine or Hotkey
		If (InStr(FirstWord,"::") = 0) {     ;line is start of a subroutine
			StringTrimRight, SubroutineName, Line, 1
			If SubroutineName not in %CaseCorrectSubsList%
				CaseCorrectSubsList = %CaseCorrectSubsList%,%SubroutineName%
		}
		String = %String%%Line%`n
		MemorizeIndent("Sub",1,-1)
	}
	Else If (FirstChar = "}") {             ;line is end bracket block
		If (FirstWord = "else"){            ;it uses OTB and must be a "}[ ]else [xxx] [{]"
			;do the case correction
			StringReplace, Line, Line, else, else
			Loop, Parse, CaseCorrectionSyntax, `,
				Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

			Gosub, SetIndentOfLastCurledBracket
			IndentIndex --
			Gosub, SetIndentOfLastIfOrOneLineIf

			;else line is also start of If-Statement
			If SecondWord in %ListOfIFCommands%          ;Line is an old  If-statement
			{
				StringReplace, Line, Line, if, if			; feature #2
				StringReplace, ParsedCommand, StripedLine, ```, ,,All
				;Search if a third comma exists
				StringGetPos, ParsedCommand, ParsedCommand , `, ,L3
				If ErrorLevel                           ;Line is an old If-statement
					MemorizeIndent("If",iif(Style=1,0,1),+1)
			}Else If (SecondWord = "if") {              ;Line is a Normal if-statement
				StringReplace, Line, Line, if, if
				MemorizeIndent("If",iif(Style=1,0,1),+1)
				If (LastChar = "{")                     ;it uses OTB
					MemorizeIndent("{",iif(Style=3,0,1),+1)
			}Else If (SecondWord = "loop"){             ;Line is the begining of a loop
				StringReplace, Line, Line, loop, loop
				MemorizeIndent("Loop",iif(Style=1,0,1),+1)
				If (LastChar = "{")                     ;it uses OTB
					MemorizeIndent("{",iif(Style=3,0,1),+1)
			}Else If SecondWord is Space                 ;just a plain Else
			{
				MemorizeIndent("Else",iif(Style=1,0,1),+1)
				If (LastChar = "{")                     ;it uses OTB
					MemorizeIndent("{",iif(Style=3,0,1),+1)
			}
			;if all the previous if didn't satisfy,
			; the Line is an else with any command following,
			;  then nothing has to be done
			String = %String%%Indent%%Line%`n
		}Else {                               ;line is end bracket block without OTB
			Gosub, SetIndentOfLastCurledBracket
			String = %String%%Indent%%Line%`n
			IndentIndex --
		}
	}
	Else If (FirstChar = "{") {                   ;line is start of bracket block
		;check if line is start of a function implementation
		If ( IndentIndex = 1 AND  FunctionName <> "" )
		;then add function name to list if not in it already
			If FunctionName not in %CaseCorrectFuncList%
				CaseCorrectFuncList = %CaseCorrectFuncList%,%FunctionName%(
			;clear function name
		FunctionName =

		IndentIndex ++
		IndentCommand%IndentIndex% = {
		IndentIncrement%IndentIndex% := iif(Style=3,0,1)

		;check if command after { is if or loop
		If (FirstWord = "loop"){                   ;line is start of Loop block after the {
			;do the case correction
			StringReplace, Line, Line, loop, loop
			Loop, Parse, CaseCorrectionSyntax, `,
				Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

			MemorizeIndent("Loop",iif(Style=1,0,1),+1)
			If (LastChar = "{")                     ;it uses OTB
				MemorizeIndent("{",iif(Style=3,0,1),+1)
			;assuming that there are no old one-line if-statements following a {
		}Else If FirstWord in %ListOfIFCommands%  ;line is start of old If-Statement after the {
		{
			;do the case correction
			StringReplace, Line, Line, if, if, 1
			Loop, Parse, CaseCorrectionSyntax, `,
				Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

			MemorizeIndent("If",iif(Style=1,0,1),+1)
		}Else If (FirstWord = "if"){                ;line is start of If-Statement after the {
			;do the case correction
			StringReplace, Line, Line, if, if, 1
			Loop, Parse, CaseCorrectionSyntax, `,
				Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

			MemorizeIndent("If",iif(Style=1,0,1),+1)
			If (LastChar = "{")                     ;it uses OTB
				MemorizeIndent("{",iif(Style=3,0,1),+1)
		}
		String = %String%%Indent%%Line%`n
	}
	Else If FirstWordIsFunction {                ;line is function
		String = %String%%Line%`n
		; 注释掉这一行可使函数后面的花括号不缩进（花括号包围的内容依然缩进）。feature #3
		; MemorizeIndent("Func",1,-1)

		If (LastChar = "{") {                 ;it uses OTB
			If FunctionName not in %CaseCorrectFuncList%
				CaseCorrectFuncList = %CaseCorrectFuncList%,%FunctionName%(
			;clear function name
			FunctionName =

			MemorizeIndent("{",iif(Style=3,0,1),+1)
		}
	}
	Else If (FirstWord = "loop") {         ;line is start of Loop block
		;do the case correction
		StringReplace, Line, Line, loop, loop
		Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

		PrevCommand := IndentCommand%IndentIndex%
		If (PrevCommand = "If"){               ;line is First line of a one-line If-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineIf",iif(Style=2,2,1))
		}Else If (PrevCommand = "Else"){         ;Line is First line of a one-line Else-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineElse",iif(Style=2,2,1))
		}Else If (PrevCommand = "Loop"){         ;Line is First line of a one-line loop-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineLoop",iif(Style=2,2,1))
		}Else {                              ;it follows a Sub , { , OneLineCommand or nothing
			Gosub, SetIndentToLastSubBracketOrTab
			String = %String%%Indent%%Line%`n
		}
		MemorizeIndent("Loop",iif(Style=1,0,1),+1)
		If (LastChar = "{")                  ;it uses OTB
			MemorizeIndent("{",iif(Style=3,0,1),+1)
	}
	Else If FirstWord in %ListOfIFCommands% ;line is start of old If-Statement
	{
		;do the case correction
		StringReplace, Line, Line, if, if
		Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

		PrevCommand := IndentCommand%IndentIndex%

		;eliminate comments and escaped commas
		ParsedCommand := StripCommentsFromLine(Line)
		StringReplace, ParsedCommand, ParsedCommand, ```, ,,All
		;Search if a third comma exists
		StringGetPos, ParsedCommand, ParsedCommand , `, ,L3
		If ( ErrorLevel = 0 ){                 ;Line is a old one-line If-statement
			If (PrevCommand = "If"){           ;Line is a one-line command of an If-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineIf",0)
				MemorizeIndent("OneLineCommand",0,+1)
			}Else If (PrevCommand = "Else"){       ;Line is a one-line command of an Else-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineElse",0)
				MemorizeIndent("OneLineCommand",0,+1)
			}Else If (PrevCommand = "Loop"){       ;Line is a one-line command of a loop-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineLoop",0)
				MemorizeIndent("OneLineCommand",0,+1)
			}Else {                            ;line is Normal one-line if-statement
				Gosub, SetIndentToLastSubBracketOrTab
				String = %String%%Indent%%Line%`n
			}
		}Else {                              ;Line is not an one-line if-statement
			If (PrevCommand = "If"){              ;Line is First line of an one-line If-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineIf",iif(Style=2,2,1))
			} Else If (PrevCommand = "Else"){       ;Line is First line of a one-line Else-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineElse",iif(Style=2,2,1))
			} Else If (PrevCommand = "Loop"){       ;Line is First line of a one-line loop-block
				String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
				MemorizeIndent("OneLineLoop",iif(Style=2,2,1))
			} Else {                             ;it follows a Sub , { , OneLineCommand or nothing
				Gosub, SetIndentToLastSubBracketOrTab
				String = %String%%Indent%%Line%`n
			}
			MemorizeIndent("If",iif(Style=1,0,1),+1)
		}
	}
	Else If (FirstWord = "if"){                  ;line is start of a Normal If-Statement
		;do the case correction
		StringReplace, Line, Line, if, if
		Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

		PrevCommand := IndentCommand%IndentIndex%
		If (PrevCommand = "If"){              ;Line is First line of a one-line If-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineIf",iif(Style=2,2,1))
		} Else If (PrevCommand = "Else"){       ;Line is First line of a one-line Else-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineElse",iif(Style=2,2,1))
		} Else If (PrevCommand = "Loop"){       ;Line is First line of a one-line loop-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineLoop",iif(Style=2,2,1))
		} Else {                             ;it follows a Sub , { , OneLineCommand or nothing
			Gosub, SetIndentToLastSubBracketOrTab
			String = %String%%Indent%%Line%`n
		}
		MemorizeIndent("If",iif(Style=1,0,1),+1)
		If (LastChar = "{")                  ;it uses OTB
			MemorizeIndent("{",iif(Style=3,0,1),+1)
	}
	Else If (FirstWord = "Else") {         ;line is a Else block
		;do the case correction
		StringReplace, Line, Line, else, else
		Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

		PrevCommand := IndentCommand%IndentIndex%
		If PrevCommand in OneLineCommand,Else
			Gosub, SetIndentOfLastIfOrOneLineIf

		;else line is also start of If-Statement
		If SecondWord in %ListOfIFCommands%          ;Line is an old  If-statement
		{
			StringReplace, Line, Line, if, if
			StringReplace, ParsedCommand, StripedLine, ```, ,,All
			;Search if a third comma exists
			StringGetPos, ParsedCommand, ParsedCommand , `, ,L3
			If ErrorLevel {                         ;Line is an old one-line If-statement
				MemorizeIndent("If",1,+1)
			}
		}Else If (SecondWord = "if"){               ;Line is a Normal if-statement
			StringReplace, Line, Line, if, if
			MemorizeIndent("If",iif(Style=1,0,1),+1)
			If (LastChar = "{")                  ;it uses OTB
				MemorizeIndent("{",iif(Style=3,0,1),+1)
		}Else If (Secondword = "loop"){             ;else is followed by a loop command
			;do the case correction
			StringReplace, Line, Line, loop, loop
			MemorizeIndent("Loop",iif(Style=1,0,1),+1)
			If (LastChar = "{")                  ;it uses OTB
				MemorizeIndent("{",iif(Style=3,0,1),+1)
		}Else If SecondWord is Space                 ;just a plain Else
		{ MemorizeIndent("Else",iif(Style=1,0,1),+1)
			If (LastChar = "{")                  ;it uses OTB
				MemorizeIndent("{",iif(Style=3,0,1),+1)
		}
		;if all the previous if didn't satisfy,
		; the Line is an else with any command following,
		;  then nothing has to be done
		String = %String%%Indent%%Line%`n
	}
	Else {                                        ;line is a Normal command or Return
		;do the case correction
		Loop, Parse, CaseCorrectionSyntax, `,
			Line := RegExReplace(Line, "i)\b" A_LoopField "\b", A_LoopField)	; bug #7

		PrevCommand := IndentCommand%IndentIndex%
		If (PrevCommand = "If"){             ;Line is a one-line command of an If-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineIf",0)
			MemorizeIndent("OneLineCommand",0,+1)
		}Else If (PrevCommand = "Else"){      ;Line is a one-line command of an Else-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineElse",0)
			MemorizeIndent("OneLineCommand",0,+1)
		}Else If (PrevCommand = "Loop"){      ;Line is a one-line command of a loop-block
			String := String . Indent . iif(Style<>3,IndentSize) . Line . "`n"
			MemorizeIndent("OneLineLoop",0)
			MemorizeIndent("OneLineCommand",0,+1)
		}Else If (PrevCommand = "Func"){      ;Line follows a function call   ??? is this ever True?
			String = %String%%Line%`n
			IndentIndex = 0
		}Else {                               ;line is Normal command or Return
			Gosub, SetIndentToLastSubBracketOrTab
			PrevCommand := IndentCommand%IndentIndex%

			;if command is end of subroutine (return) no indentation, otherwise keep indentation
			If (FirstWord = "Return" AND PrevCommand = "Sub") {
				String = %String%%Line%`n
				IndentIndex = 0
			}Else
			;String := String . Indent . iif(Style=2,IndentSize) . Line . "`n"
				String = %String%%Indent%%Line%`n
		}
	}
	Gosub, FinishThisLine
Return

FinishThisLine:
	;###### End of change in indentation ##########

	;turn AutoTrim on, to get back to default behaviour
	AutoTrim, On

	;Show MsgBox for debug
	If DebugMode
		Gosub, ShowDebugStrings

	;get Indentation for next loop
	Gosub, SetIndentForNextLoop
Return


;#############   Show MsgBox for debug   ######################################
ShowDebugStrings:
	msgtext = line#: %TotalLineCount%`n
	msgtext = %msgtext%Style: %Style%`n
	msgtext = %msgtext%line: %Line%`n
	msgtext = %msgtext%stripped line: %CommandLine%`n
	msgtext = %msgtext%Indent: |%Indent%|`n
	msgtext = %msgtext%1stChar: >%FirstChar%<`n
	msgtext = %msgtext%1st Word: >%FirstWord%<`n
	msgtext = %msgtext%2nd Word: >%SecondWord%<`n
	msgtext = %msgtext%3rd Word: >%ThirdWord%<`n
	msgtext = %msgtext%1st WordLastChar: >%FirstWordLastChar%<`n
	msgtext = %msgtext%FunctionName: >%FunctionName%<`n`n
	msgtext = %msgtext%IndentIndex: %IndentIndex%`n
	;msgtext = %msgtext%LineIsTabSpecialIndentStart: %LineIsTabSpecialIndentStart%`n
	;msgtext = %msgtext%LineIsTabSpecialIndent: %LineIsTabSpecialIndent%`n
	;msgtext = %msgtext%LineIsTabSpecialIndentEnd: %LineIsTabSpecialIndentEnd%`n`n
	msgtext = %msgtext%Indent1: %IndentIncrement1% - %IndentCommand1%`n
	msgtext = %msgtext%Indent2: %IndentIncrement2% - %IndentCommand2%`n
	msgtext = %msgtext%Indent3: %IndentIncrement3% - %IndentCommand3%`n
	msgtext = %msgtext%Indent4: %IndentIncrement4% - %IndentCommand4%`n
	msgtext = %msgtext%Indent5: %IndentIncrement5% - %IndentCommand5%`n
	msgtext = %msgtext%Indent6: %IndentIncrement6% - %IndentCommand6%`n
	msgtext = %msgtext%Indent7: %IndentIncrement7% - %IndentCommand7%`n
	msgtext = %msgtext%Indent8: %IndentIncrement8% - %IndentCommand8%`n
	msgtext = %msgtext%Indent9: %IndentIncrement9% - %IndentCommand9%`n
	msgtext = %msgtext%Indent10: %IndentIncrement10% - %IndentCommand10%`n
	msgtext = %msgtext%Indent11: %IndentIncrement11% - %IndentCommand11%`n
	;msgtext = %msgtext%`nDirectives: %ListOfDirectives%`n
	;msgtext = %msgtext%`nIf-Commands: %ListOfIFCommands%`n
	;msgtext = %msgtext%`nCommandNames: %CommandNames%`n
	;msgtext = %msgtext%`nKeywords: %Keywords%`n
	;msgtext = %msgtext%`nKeys: %Keys%`n
	;msgtext = %msgtext%`nVariables: %Variables%`n
	;msgtext = %msgtext%`nBuildInFunctions: %BuildInFunctions%`n
	;msgtext = %msgtext%`nCaseCorrectFuncList: %CaseCorrectFuncList%`n

	MsgBox %msgtext%`n%String%
Return

;#############   Set the IndentIndex to to last if or onelineif   ##############
SetIndentOfLastIfOrOneLineIf:
	;loop inverse through command array
	Loop, %IndentIndex% {
		InverseIndex := IndentIndex - A_Index + 2
		;if command is if or onelineif, exit loop and remember the previous Index
		If IndentCommand%InverseIndex% in If,OneLineIf
		{ IndentIndex := InverseIndex - 1
			Break
		}
	}
	;set indentation for that index
	Gosub, SetIndentForNextLoop
Return

;#############   Set the IndentIndex to to last curled bracket   ##############
SetIndentOfLastCurledBracket:
	;loop inverse through command array
	Loop, %IndentIndex% {
		InverseIndex := IndentIndex - A_Index + 1
		;if command is bracket, exit loop and remember the previous Index
		If (IndentCommand%InverseIndex% = "{") {
			IndentIndex := InverseIndex - 1
			Break
		}
	}
	;set indentation for that index
	Gosub, SetIndentForNextLoop
Return

;#############   Set the IndentIndex to to last bracket   #####################
SetIndentOfLastBracket:
	;loop inverse through command array
	Loop, %IndentIndex% {
		InverseIndex := IndentIndex - A_Index + 1
		;if command is bracket, exit loop and remember the previous Index
		If (IndentCommand%InverseIndex% = "(") {
			IndentIndex := InverseIndex - 1
			Break
		}
	}
	;set indentation for that index
	Gosub, SetIndentForNextLoop
Return

;#############   Set the IndentIndex to the last addtab  ######################
SetIndentOfLastAddTaborBracket:
	;loop inverse through command array
	Loop, %IndentIndex% {
		InverseIndex := IndentIndex - A_Index + 1
		;if command is AddTab, exit loop and remember the previous Index
		If IndentCommand%InverseIndex% in {,AddTab
		{ IndentIndex := InverseIndex - 1
			Break
		}
	}
	;set indentation for that index
	Gosub, SetIndentForNextLoop
Return

;#############   Set the IndenIndex to to last Sub or bracket   ###############
SetIndentToLastSubBracketOrTab:
	FoundItem:=False
	;loop inverse through command array
	Loop, %IndentIndex% {
		InverseIndex := IndentIndex - A_Index + 1

		;if command is sub or bracket, exit loop and remember the Index
		If IndentCommand%InverseIndex% in {,Sub
		{ IndentIndex := InverseIndex
			FoundItem:=True
			Break
		}Else If ChkSpecialTabIndent
			If IndentCommand%InverseIndex% in AddTab,Tab
			{ IndentIndex := InverseIndex
				FoundItem:=True
				Break
			}
	}
	;if not found set index to zero
	If ! FoundItem
		IndentIndex = 0

	;set indentation for that index
	Gosub, SetIndentForNextLoop
Return

;#############   Extract Function Names   #####################################
ExtractFunctionName(FirstWord,BracketPosition, ByRef FunctionName)  {
	;get function name without braket
	StringLeft, FunctionName, FirstWord, % BracketPosition - 1

	If (FunctionName = "If")   ;it is a If statement "If(", empty FunctionName and function will Return 0
		FunctionName =

	;check each char in name if it is allowed
	;检查函数名是否合法，原版这里用字母来判断，显然对中文函数名不适合。bug #3
	;另外函数名的合法化判断其实是很难的，因为比如009()每个字都合法，但是却是错的，并且不会报错。
	RegExMatch(FunctionName, "SP)(*UCP)^[[:blank:]]*\K[\w#@\$\?\[\]]+", FunctionName_Len)
	If (FunctionName_Len<>StrLen(FunctionName))
		FunctionName =

	Return StrLen(FunctionName)
}

;#############   Do CaseCorrection for Functions and Subroutines   ############
CaseCorrectSubsAndFuncNames() {
	global
	LenString := StrLen(String)

	;remove first comma
	StringTrimLeft, CaseCorrectFuncList, CaseCorrectFuncList, 1
	StringTrimLeft, CaseCorrectSubsList, CaseCorrectSubsList, 1

	;loop over all remembered function names
	Loop, Parse, CaseCorrectFuncList, CSV
	{ FuncName := A_LoopField
		LenFuncName := StrLen(FuncName)

		;Loop through string to find all occurances of function names
		StartPos = 0
		Loop {
			StartPos := InStr(String,FuncName,0,StartPos + 1)
			If (StartPos > 0) {
				StringMid,PrevChar, String, StartPos - 1 , 1
				If PrevChar is not Alnum
					ReplaceName( String, FuncName, StartPos-1, LenString - StartPos + 1 - LenFuncName )
			} Else
				Break
		}
	}

	;loop over all remembered subroutine names
	Loop, Parse, CaseCorrectSubsList, CSV
	{ SubName := A_LoopField
		LenSubName := StrLen(SubName)

		;Loop through string to find all occurances of function names
		StartPos = 0
		Loop {
			StartPos := InStr(String,SubName,"",StartPos + 1)
			If (StartPos > 0) {
				StringMid,PrevChar, String, StartPos - 1 , 1
				StringMid,NextChar, String, StartPos + LenSubName, 1

				;if it is an exact match the char after the subroutine names has not to be a char
				If NextChar is not Alnum
				{ ;If previous character is a "g" and has TestStrings in same line replace the name.
					If ( PrevChar = "g" ) {
						TestAndReplaceSubName( String, SubName, "Gui,", LenString, LenSubName, StartPos)
						TestAndReplaceSubName( String, SubName, "Gui ", LenString, LenSubName, StartPos)

						;If previous character is something else then Alnum and has TestStrings in same line replace the name.
					}Else If PrevChar is not Alnum
					{ TestAndReplaceSubName( String, SubName, "Gosub" , LenString, LenSubName, StartPos )
						TestAndReplaceSubName( String, SubName, "Menu"  , LenString, LenSubName, StartPos )
						TestAndReplaceSubName( String, SubName, "`:`:"  , LenString, LenSubName, StartPos )
						TestAndReplaceSubName( String, SubName, "Hotkey", LenString, LenSubName, StartPos )
					}
				}
			} Else
				Break
		}
	}
}

TestAndReplaceSubName( ByRef string, Name, TestString, LenString, LenSubName, StartPos ) {
	;find Positions of Teststring and LineFeed in String from the right side starting at routine position
	StringGetPos, PosTestString, String, %TestString%, R , LenString - StartPos + 1
	StringGetPos, PosLineFeed  , String,     `n      , R , LenString - StartPos + 1

	;If %TestString% is in the same line do replace name
	If ( PosLineFeed < PosTestString )
		ReplaceName( String, Name, StartPos - 1, LenString - StartPos + 1 - LenSubName )
}

ReplaceName( ByRef String, Name, PosLeft, PosRight ) {
	;split String up into left and right
	StringLeft, StrLeft, String, PosLeft
	StringRight, StrRight, String, PosRight

	;insert Name into it again
	String = %StrLeft%%Name%%StrRight%
}

;#############   If Gui closes exit all   #####################################
GuiClose:
	;store current position and settings and exit app
	Gui, Show
	WinGetPos, PosX, PosY, SizeW, SizeH, %ScriptName%
	Gui, Submit
	IniWrite, x%PosX% y%PosY%, %IniFile%, General, Pos_Gui
	IniWrite, %Extension%, %IniFile%, Settings, Extension
	IniWrite, %Indentation%, %IniFile%, Settings, Indentation
	IniWrite, %NumberSpaces%, %IniFile%, Settings, NumberSpaces
	IniWrite, %NumberIndentCont%, %IniFile%, Settings, NumberIndentCont
	IniWrite, %IndentCont%, %IniFile%, Settings, IndentCont
	IniWrite, %Style%, %IniFile%, Settings, Style
	IniWrite, %CaseCorrectCommands%, %IniFile%, Settings, CaseCorrectCommands
	IniWrite, %CaseCorrectVariables%, %IniFile%, Settings, CaseCorrectVariables
	IniWrite, %CaseCorrectBuildInFunctions%, %IniFile%, Settings, CaseCorrectBuildInFunctions
	IniWrite, %CaseCorrectKeys%, %IniFile%, Settings, CaseCorrectKeys
	IniWrite, %CaseCorrectKeywords%, %IniFile%, Settings, CaseCorrectKeywords
	IniWrite, %CaseCorrectDirectives%, %IniFile%, Settings, CaseCorrectDirectives
	IniWrite, %Statistic%, %IniFile%, Settings, Statistic

	IniWrite, %ChkSpecialTabIndent%, %IniFile%, Settings, ChkSpecialTabIndent
	IniWrite, %KeepBlockCommentIndent%, %IniFile%, Settings, KeepBlockCommentIndent
	IniWrite, %AHKPath%, %IniFile%, Settings, AHKPath
	IniWrite, %OwnHotKey%, %IniFile%, Settings, OwnHotKey
ExitApp:
	ExitApp
Return
;#############   End of File   #################################################
