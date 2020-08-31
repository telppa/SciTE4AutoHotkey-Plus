; MagicBox - Message Box Generator

CheckRequirements()

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
DetectHiddenWindows On

#Include %A_ScriptDir%\..\..\Lib\GuiButtonIcon.ahk
#Include %A_ScriptDir%\..\..\Lib\ResourceId.ahk
#Include %A_ScriptDir%\..\..\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\..\..\Lib\ExecScript.ahk
#Include %A_ScriptDir%\..\..\Lib\ControlColor.ahk
#Include %A_ScriptDir%\..\..\Lib\CommonDialogs.ahk

#Include %A_ScriptDir%\Functions\MsgBoxEx.ahk
#Include %A_ScriptDir%\Functions\MessageBoxCheck.ahk
#Include %A_ScriptDir%\Functions\MessageBoxIndirect.ahk
#Include %A_ScriptDir%\Functions\SoftModalMessageBox.ahk
#Include %A_ScriptDir%\Functions\MsiMessageBox.ahk
#Include %A_ScriptDir%\Functions\WTSSendMessage.ahk
#Include %A_ScriptDir%\Functions\TaskDialog.ahk

Global AppName := "MagicBox"
    , Version := "1.0.4"
    , MsgBoxType
    , Title
    , Text
    , Content
    , StrOK := MB_GetString(1)
    , StrCancel := MB_GetString(2)
    , StrAbort := MB_GetString(3)
    , StrRetry := MB_GetString(4)
    , StrIgnore := MB_GetString(5)
    , StrYes := MB_GetString(6)
    , StrNo := MB_GetString(7)
    , StrTryAgain := MB_GetString(10)
    , StrContinue := MB_GetString(11)
    , NT6 := DllCall("kernel32.dll\GetVersion") & 0xFF > 5
    , x64 := A_PtrSize == 8
    , PID
    , Icon := 0
    , Shield := False
    , Shields := False
    , DefBtn := 0
    , IconRes := (NT6) ? "imageres.dll" : "shell32.dll"
    , IconIdx := 0
    , ResId := 0
    , TDIcon := 0
    , CustomIcon := False
    , IfBlocks := True
    , PrevType := "MsgBox"
    , PrevSection := 1
    , TDI_CustomMainIcon := False
    , TDI_MainIconRes := "imageres.dll"
    , TDI_MainIcon := 0
    , TDI_MainIconIdx := 0
    , TDI_CustomFooterIcon := False
    , TDI_FooterIconRes := "imageres.dll"
    , TDI_FooterIcon := 0
    , TDI_FooterIconIndex := 0
    , CustomButtons := []
    , TDI_ButtonID := 100
    , TDI_ButtonIDs := {"OK": 1, "Cancel": 2, "Yes": 6, "No": 7, "Retry": 4, "Close": 8}
    , TDI_CommonButtons := [[1, "OK"], [6, "Yes"], [7, "No"], [2, "Cancel"], [4, "Retry"], [8, "Close"]]
    , TDI_DefaultButton := 0
    , RadioButtons := []
    , TDI_RadioID := 200
    , TDI_DefaultRadio := 0
    , CustomButtonsDlgCreated := False
    , TDI_Callback := 0
    , TDI_CBData := 0
    , TDI_HyperLink := 0
    , TDCSize := (x64) ? 160 : 96
    , MoreOptionsDlgCreated := False
    , SM_CustomButtons := []
    , SM_DefaultButton := 0
    , Offsets
    , English := False
    , MB_Custom := False
    , MB_CustomButtons := [{}, {}, {}, {}]
    , MB_CustomButtonsDlgCreated := False
    , MBX_CustomFont := False
    , MBX_FontName := "Segoe UI"
    , MBX_FontOptions := "s9"
    , MBX_CustomBGColor := False
    , MBX_BGColor := "0x008EBC"
    , MBX_Adding := False
    , hSysMenu
    , TT := {}
    , IniFile

Global hWindow := 0, hCodeView := 0, hPrevIconBtn := 0, hPrevDefBtn := 0

If (FileExist(A_AppData . "\AutoGUI\MagicBox.ini")) {
    IniFile := A_AppData . "\AutoGUI\MagicBox.ini"
} Else {
    IniFile := A_ScriptDir . "\MagicBox.ini"
}

If (FileExist(IniFile)) {
    IniRead MsgBoxType, %IniFile%, MagicBox, Type, MsgBox
    IniRead Title, %IniFile%, MagicBox, Title
    IniRead Text, %IniFile%, MagicBox, Text
    IniRead Content, %IniFile%, MagicBox, Content
}

Menu Tray, Icon, %A_ScriptDir%\..\..\Icons\MagicBox.ico
Gui MagicBox: New, LabelMagicBox hWndhWindow OwnDialogs
If (NT6) {
    Gui Color, 0xFBFBFB
}

Gui Add, GroupBox, x8 y5 w76 h298, Icon
Gui Add, Button, hWndhNoIconBtn vNoIcon gSetIcon x22 y25 w48 h48, None

Gui Add, Button, hWndhInfoBtn vInfoIcon gSetIcon x22 y79 w48 h48
GuiButtonIcon(hInfoBtn, "user32.dll", 5, "L1 T1 w32 h32")

Gui Add, Button, hWndhWarningBtn vWarningIcon gSetIcon x22 y133 w48 h48
GuiButtonIcon(hWarningBtn, "user32.dll", 2, "L1 T1 w32 h32")

Gui Add, Button, hWndhQuestionBtn vQuestionIcon gSetIcon x22 y187 w48 h48
GuiButtonIcon(hQuestionBtn, "user32.dll", 3, "L1 T1 w32 h32")

Gui Add, Button, hWndhErrorBtn vErrorIcon gSetIcon x22 y242 w48 h48
GuiButtonIcon(hErrorBtn, "user32.dll", 4, "L1 T1 w32 h32")

Gui Add, Button, hWndhSelIconBtn vSelectIconBtn gSelectIcon x8 y310 w76 h23, &Icon...
Gui Add, Picture, vCustomIconPreview gEnableCustomIcon x29 y344 w32 h32

Gui Add, Button, gShowHelp x8 y401 w76 h23, Help
Gui Add, Button, gShowAbout x8 y430 w76 h23, A&bout

Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y5 w353 h54, Title
Gui Add, Edit, vTitle gGenerateCode x104 y25 w330 h21, %Title%
Gui Font

Gui Add, GroupBox, x455 y5 w154 h54, Type
Gui Add, DropDownList, vMsgBoxType gSetMsgBoxType x466 y24 w133, % (NT6) ? "MsgBoxEx|MsgBox||SHMessageBoxCheck|MessageBoxIndirect|SoftModalMessageBox|MsiMessageBox|WTSSendMessage|TaskDialog|TaskDialogIndirect" : "MsgBoxEx|MsgBox||SHMessageBoxCheck|MessageBoxIndirect|SoftModalMessageBox|MsiMessageBox|WTSSendMessage"

Gui Add, Tab2, vHiddenTab x0 y0 w0 h0 -TabStop, 1|TaskDialogIndirect|SoftModalMessageBox|MsgBoxEx

Gui Tab, 1
Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y64 w353 h148, Text
Gui Add, Edit, hWndhText vText gSyncText x104 y83 w330 h116 Multi, %Text%
GuiControl MagicBox: Focus, Text

Gui Add, Edit, vContent gSyncContent x104 y145 w330 h54 Multi Hidden, %Content%
Gui Font

Gui Add, GroupBox, x93 y216 w353 h237, Buttons
Gui Add, Radio, vButtons_OK gSetButtons x105 y236 w23 h23 Checked
Gui Add, Radio, vButtons_OKCancel gSetButtons x105 y262 w23 h23
Gui Add, Radio, vButtons_YesNo gSetButtons x105 y288 w23 h23
Gui Add, Radio, vButtons_YesNoCancel gSetButtons x105 y314 w23 h23
Gui Add, Radio, vButtons_AbortRetryIgnore gSetButtons x105 y341 w23 h23
Gui Add, Radio, vButtons_CancelTryAgainContinue gSetButtons x105 y368 w23 h23
Gui Add, Radio, vButtons_RetryCancel gSetButtons x105 y395 w23 h23
Gui Add, Radio, vStdTDBtns x105 y423 w23 h23 Hidden

Gui Add, Button, vOK_OK gSetButton x130 y236 w87 h23 -Wrap, %StrOK%

Gui Add, Button, vOK_OKCancel gSetButton x130 y262 w87 h23 -Wrap, %StrOK%
Gui Add, Button, vCancel_OKCancel gSetButton x222 y262 w87 h23 -Wrap, %StrCancel%

Gui Add, Button, vYes_YesNo gSetButton x130 y288 w87 h23 -Wrap, %StrYes%
Gui Add, Button, vNo_YesNo gSetButton x222 y288 w87 h23 -Wrap, %StrNo%

Gui Add, Button, vYes_YesNoCancel gSetButton x130 y314 w87 h23 -Wrap, %StrYes%
Gui Add, Button, vNo_YesNoCancel gSetButton x222 y314 w87 h23 -Wrap, %StrNo%
Gui Add, Button, vCancel_YesNoCancel gSetButton x314 y314 w87 h23 -Wrap, %StrCancel%

Gui Add, Button, vAbort_AbortRetryIgnore gSetButton x130 y341 w87 h23 -Wrap, %StrAbort%
Gui Add, Button, vRetry_AbortRetryIgnore gSetButton x222 y341 w87 h23 -Wrap, %StrRetry%
Gui Add, Button, vIgnore_AbortRetryIgnore gSetButton x314 y341 w87 h23 -Wrap, %StrIgnore%

Gui Add, Button, vCancel_CancelTryAgainContinue gSetButton x130 y368 w87 h23 -Wrap, %StrCancel%
Gui Add, Button, vTryAgain_CancelTryAgainContinue gSetButton x222 y368 w87 h23 -Wrap, %StrTryAgain%
Gui Add, Button, vContinue_CancelTryAgainContinue gSetButton x314 y368 w87 h23 -Wrap, %StrContinue%

Gui Add, Button, vRetry_RetryCancel gSetButton x130 y395 w87 h23 -Wrap, %StrRetry%
Gui Add, Button, vCancel_RetryCancel gSetButton x222 y395 w87 h23 -Wrap, %StrCancel%

Gui Add, CheckBox, vHelpBtn gGenerateCode x105 y423 w112 h23, &Help Button

; Options
Gui Add, GroupBox, vOptionsGrp x455 y64 w154 h148, Options
Gui Add, Radio, vNoOwner gGenerateCode x467 y81 w120 h23 Checked, &No owner window
Gui Add, Radio, vOwned gGenerateCode x467 y106 w120 h23, Application &modal
Gui Add, Radio, vTaskModal gGenerateCode x467 y131 w120 h23, Tas&k modal
Gui Add, CheckBox, vAlwaysOnTop gGenerateCode x467 y156 w120 h23, &Always on top
Gui Add, CheckBox, vRTLReading gGenerateCode x467 y181 w120 h23, Right-to-&left reading

; Custom Buttons
Gui Add, GroupBox, vCustomButtonsGrp x455 y216 w154 h52
Gui Add, Button, vCustomButtonsBtn gMB_ShowCustomButtonsDialog x474 y233 w118 h23, C&ustom Buttons...

; Custom Position
Gui Add, GroupBox, vMsgBoxPosGrp x455 y270 w154 h59, Position
Gui Add, Text, vMB_LblX x463 y291 w16 h23 +0x202, X:
Gui Add, Edit, vMB_PosX gGenerateCode x485 y293 w40 h21
Gui Add, Text, vMB_LblY x530 y291 w16 h23 +0x202, Y:
Gui Add, Edit, vMB_PosY gGenerateCode x552 y293 w40 h21

; Timeout
Gui Add, GroupBox, vTimeoutGrp x455 y332 w154 h59, Timeout
Gui Add, CheckBox, vTimeoutEnabled gGenerateCode x467 y354 w21 h23
Gui Add, Edit, vTimeout gGenerateCode x488 y355 w57 h21
Gui Add, UpDown, vUpDown x529 y355 w17 h21, 1
Gui Add, Text, vSeconds x553 y354 w43 h23 +0x200, seconds

Gui Tab
Gui Add, Button, vTestBtn gInternalTest x455 y401 w75 h23 Default, &Test
Gui Add, Button, gViewCode x535 y401 w75 h23, &Code
Gui Add, Button, gReset x455 y430 w75 h23, &Reset
Gui Add, Button, vBtnCopy gCopy x535 y430 w75 h23, Cop&y

Gui Show, w617 h462, %AppName%

Gui Tab, 1
; SHMessageBoxCheck Unique ID
Gui Font, s9, Segoe UI
Gui Add, Edit, vRegVal x467 y354 w130 h22 Limit256 Hidden ; REGSTR_MAX_VALUE_LENGTH
Gui Font

; WTSSendMessage extra option
Gui Add, CheckBox, vWTS_Wait gGenerateCode x467 y206 w130 h22 Checked Hidden, Wait for response

; TaskDialog common buttons
Gui Add, CheckBox, vTD_OK gSetButton x131 y423 w45 h23 Hidden, O&K
Gui Add, CheckBox, vTD_Cancel gSetButton x269 y423 w61 h23 Hidden, Cancel
Gui Add, CheckBox, vTD_Yes gSetButton x177 y423 w47 h23 Hidden, Yes
Gui Add, CheckBox, vTD_No gSetButton x225 y423 w43 h23 Hidden, No
Gui Add, CheckBox, vTD_Retry gSetButton x331 y423 w54 h23 Hidden, Retry
Gui Add, CheckBox, vTD_Close gSetButton x386 y423 w55 h23 Hidden, Close

; TaskDialogIndirect ***********************************************************
Gui Tab, 2
Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y64 w353 h154, Text
Gui Font, s12 c0x003399, Segoe UI
Gui Add, Edit, hWndhMainInstruction vTDI_Instruction gSyncText x104 y83 w330 h54 Multi, %Text%
Gui Font, s9 cDefault, Segoe UI
Gui Add, Edit, vTDI_Content gSyncContent x104 y145 w330 h60 Multi, %Content%
Gui Font

; Expanded Information
Gui Font, s9, Segoe UI
Gui Add, GroupBox, vGrpSection x93 y222 w353 h92, Expanded Text
Gui Add, Edit, vTDI_ExpandedText gTDI_GenerateCode x104 y241 w330 h60 Multi
; Expando Text
Gui Add, Text, vLblCollapsedControlText x104 y242 w90 h23 +0x200 Hidden, C&ollapsed text:
Gui Add, Edit, vTDI_CollapsedControlText gTDI_GenerateCode x200 y244 w234 h21 Hidden
Gui Add, Text, vLblExpandedControlText x104 y275 w90 h23 +0x200 Hidden, Expande&d text:
Gui Add, Edit, vTDI_ExpandedControlText gTDI_GenerateCode x200 y277 w234 h21 Hidden
; Verification Text
Gui Add, Edit, vTDI_VerificationText gTDI_GenerateCode x104 y241 w330 h60 Multi Hidden
; Footer Text
Gui Add, Edit, vTDI_FooterText gTDI_GenerateCode x104 y241 w330 h60 Multi Hidden
Gui Font

; TDI Buttons
Gui Add, GroupBox, x274 y318 w172 h136, Buttons
Gui Add, CheckBox, vTDI_OK gTDI_SetCommonButtons x302 y337 w60 h23, O&K
Gui Add, CheckBox, vTDI_Cancel gTDI_SetCommonButtons x364 y337 w60 h23, Cancel
Gui Add, CheckBox, vTDI_Yes gTDI_SetCommonButtons x302 y362 w60 h23, Yes
Gui Add, CheckBox, vTDI_No gTDI_SetCommonButtons x364 y362 w60 h23, No
Gui Add, CheckBox, vTDI_Retry gTDI_SetCommonButtons x302 y388 w60 h23, Retry
Gui Add, CheckBox, vTDI_Close gTDI_SetCommonButtons x364 y388 w60 h23, Close
Gui Add, Button, gTDI_ShowCustomButtonsDialog x299 y418 w118 h23, C&ustom Buttons...

; TDI Options
Gui Add, GroupBox, x455 y64 w154 h138, Options
Gui Add, CheckBox, vTDI_RelativePosition gTDI_GenerateCode x467 y80 w120 h23, Relative &position
Gui Add, CheckBox, vTDI_AllowCancellation gTDI_GenerateCode x467 y103 w120 h23, Allow &cancellation
Gui Add, CheckBox, vTDI_CanBeMinimized gTDI_GenerateCode x467 y126 w120 h23, Can be &minimized
Gui Add, CheckBox, vTDI_AlwaysOnTop gTDI_GenerateCode x467 y149 w120 h23, &Always on top
Gui Add, CheckBox, vTDI_RTLReading gTDI_GenerateCode x467 y172 w120 h23, Right-to-&left reading

Gui Add, GroupBox, x455 y205 w154 h68, Progress Bar
Gui Add, CheckBox, vTDI_ProgressBar gTDI_GenerateCode x467 y220 w120 h23, &Show progress bar
Gui Add, CheckBox, vTDI_Marquee gTDI_GenerateCode x467 y243 w120 h23, Mar&quee style

Gui Add, GroupBox, x455 y276 w154 h57, Width
Gui Add, Edit, vTDI_Width gTDI_GenerateCode x467 y297 w65 h21 Number
Gui Add, Text, x535 y297 w61 h23 +0x200 Right, dialog units

Gui Add, GroupBox, x455 y336 w154 h57, Timeout
Gui Add, CheckBox, vTDI_TimeoutEnabled gTDI_GenerateCode x467 y356 w21 h23
Gui Add, Edit, vTDI_Timeout gTDI_GenerateCode x488 y357 w50 h21
Gui Add, UpDown, x527 y357 w17 h21, 3
Gui Add, Text, x553 y356 w43 h23 +0x200, seconds

Gui Add, GroupBox, x93 y318 w172 h136, Section
Gui Add, ListBox, hWndhLbxSection vSection gTDI_SetSection x104 y336 w149 h56 AltSubmit, Expanded Text||Expando Button|Verification Text|Footer Text
Gui Add, CheckBox, vTDI_ExpandedByDefault gTDI_GenerateCode x107 y398 w140 h23, E&xpanded by default
Gui Add, CheckBox, vTDI_ExpandInFooterArea gTDI_GenerateCode x107 y421 w140 h23, Expand in &footer area
Gui Add, CheckBox, vTDI_VerificationFlag gTDI_GenerateCode x107 y398 w120 h23 Hidden, Checke&d by default
Gui Add, Button, hWndhFooterIconBtn vBtnFooterIcon gShowFooterIconMenu x104 y400 w76 h23 Hidden, Icon...
Control Style, +0xC,, ahk_id%hFooterIconBtn% ; BS_SPLITBUTTON
GuiButtonIcon(hFooterIconBtn, "shell32.dll", 44, "L1 T1 A0")

; SoftModalMessageBox **********************************************************
Gui Tab, 3
Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y64 w353 h148, Text
Gui Add, Edit, vSM_Text gSyncText x104 y83 w330 h116 Multi, Test
Gui Font

Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y216 w353 h237, Custom Buttons
Gui Add, ListView, hWndhSM_LV vSM_LVButtons gSM_LVHandler x105 y236 w148 h167 NoSortHdr -Multi, ID|Text
LV_ModifyCol(1, 28), LV_ModifyCol(2, 92)
Gui Font
Gui Add, Button, gSM_AddSampleButtons x108 y415 w141 h23, Add &Sample Buttons
Gui Add, Button, gSM_AddButton x265 y234 w81 h23, &Add...
Gui Add, Button, gSM_EditButton x265 y267 w81 h23, &Edit...
Gui Add, Button, gSM_DeleteItem x265 y300 w81 h23, &Delete
Gui Add, Button, gSM_MoveItem x354 y234 w81 h23, Move &Up
Gui Add, Button, gSM_MoveItem x354 y267 w81 h23, Mo&ve Down
Gui Add, Button, gSM_ClearAll x354 y300 w81 h23, De&lete All
Gui Add, Text, x267 y333 w79 h23 +0x200, Default butt&on:
Gui Add, DropDownList, vSM_DefaultButtonList gGenerateCode x355 y334 w80, First button||
Gui Add, GroupBox, x264 y360 w171 h82
Gui Add, Text, x273 y373 w155 h20 +0x200, Range of valid IDs: 1 - 7`, 9 - 11
Gui Add, Text, x273 y393 w155 h20 +0x200, 2  is required for the Close box
Gui Add, Text, x273 y413 w155 h20 +0x200, 9  invokes the callback function

Gui Add, GroupBox, x455 y64 w154 h148, Options
Gui Add, Radio, vSM_NoOwner gGenerateCode x467 y81 w120 h23 Checked, &No owner window
Gui Add, Radio, vSM_Owned gGenerateCode x467 y106 w120 h23, Application &modal
Gui Add, Radio, vSM_TaskModal gGenerateCode x467 y131 w120 h23, Tas&k modal
Gui Add, CheckBox, vSM_AlwaysOnTop gGenerateCode x467 y156 w120 h23, Al&ways on top
Gui Add, CheckBox, vSM_RTLReading gGenerateCode x467 y181 w120 h23, Right-to-&left reading

Gui Add, GroupBox, x455 y332 w154 h59, Timeout
Gui Add, CheckBox, vSM_TimeoutEnabled gGenerateCode x467 y354 w21 h23
Gui Add, Edit, vSM_Timeout gGenerateCode x488 y355 w57 h21 Number
Gui Add, UpDown, x529 y355 w17 h21 Range-1-99999, 1
Gui Add, Text, x553 y354 w43 h23 +0x200, seconds

; MsgBoxEx *********************************************************************
Gui Tab, 4
Gui Font, s9, Segoe UI
Gui Add, GroupBox, x93 y64 w353 h148, Text
Gui Add, Edit, vMBX_Text gSyncText x104 y83 w330 h116 Multi, %Text%

Gui Add, GroupBox, x93 y216 w353 h55, Verification Text
Gui Add, Edit, vMBX_VerificationText gGenerateCode x105 y236 w330 h21

Gui Add, GroupBox, x93 y273 w353 h180, Buttons
Gui Add, ListView, hWndhMBX_LV gMBX_LVHandler x105 y292 w148 h122 -Hdr -Multi +0x200, Custom Buttons ; LVS_EDITLABELS
Gui Font
LV_Add("", "OK")
Gui Add, Button, hWndhMBX_AddBtn gMBX_AddButton x266 y290 w80 h23, &Add Button
Gui Add, Button, gMBX_EditButton x266 y323 w80 h23, &Edit Button
Gui Add, Button, gMBX_DeleteButton x266 y356 w80 h23, &Delete
Gui Add, Button, gMBX_MoveUp x355 y290 w80 h23, Move &Up
Gui Add, Button, gMBX_MoveDown x355 y323 w80 h23, Mo&ve Down
Gui Add, Button, gMBX_DeleteAll x355 y356 w80 h23, De&lete All
Gui Add, Text, x266 y389 w80 h23 +0x200, Default butt&on:
Gui Add, DropDownList, hWndhMBX_DefaultButtonList vMBX_DefaultButtonList gGenerateCode x355 y389 w80, First button||
Gui Add, Text, x105 y421 w147 h23 +0x200 Right, &Predefined button sets:
Gui Add, DropDownList, vMBX_Preset gMBX_SetButtons x266 y421 w168,
(LTrim Join| 
    OK|
    OK - Cancel
    Yes - No
    Yes - No - Cancel
    Cancel - Try Again - Continue
    Retry - Cancel
    Yes - Yes to All - No - No to All
    Save - Don't Save - Cancel
    Close
    Yes - No - Browse...
)

; MsgBoxEx options
Gui Add, GroupBox, x455 y64 w154 h148, Options
Gui Add, CheckBox, vMBX_Owned gGenerateCode x467 y81 w120 h23, Application &modal
Gui Add, CheckBox, vMBX_NoCloseButton gMBX_SetExclusiveOption x467 y106 w120 h23, &No close button
Gui Add, CheckBox, vMBX_CanBeMinimized gMBX_SetExclusiveOption x467 y131 w120 h23, Can be minimi&zed
Gui Add, CheckBox, vMBX_AlwaysOnTop gMBX_GenerateCode x467 y156 w120 h23, Al&ways on top
Gui Add, CheckBox, vMBX_CheckedByDefault gGenerateCode x467 y181 w120 h23, Chec&ked by default

Gui Add, GroupBox, x455 y216 w154 h55
Gui Add, Button, gMBX_SelectFont x474 y234 w118 h23, Choose &Font...

Gui Add, GroupBox, x455 y273 w154 h55
Gui Add, Button, gMBX_SelectColor x474 y291 w118 h23, Back&ground Color...

Gui Add, GroupBox, x455 y332 w154 h59, Timeout
Gui Add, CheckBox, vMBX_TimeoutEnabled gGenerateCode x467 y354 w21 h23
Gui Add, Edit, vMBX_Timeout gGenerateCode x488 y355 w57 h21
Gui Add, UpDown, gGenerateCode x529 y355 w17 h21, 1
Gui Add, Text, x553 y354 w43 h23 +0x200, seconds

If (NT6) {
    DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hSM_LV, "WStr", "Explorer", "Ptr", 0)
    DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hMBX_LV, "WStr", "Explorer", "Ptr", 0)
}

; MSGBOXDATA structure offsets (SoftModalMessageBox)
If (A_Is64BitOS) {
    Offsets := (x64) ? [96, 104, 112, 116, 120, 124] : [52, 56, 60, 64, 68, 72]
} Else {
    Offsets := [48, 52, 56, 60, 64, 68]
}

FileRead _MessageBoxCheck,     Functions\MessageBoxCheck.ahk
FileRead _MessageBoxIndirect,  Functions\MessageBoxIndirect.ahk
FileRead _MsiMessageBox,       Functions\MsiMessageBox.ahk
FileRead _WTSSendMessage,      Functions\WTSSendMessage.ahk
FileRead _SoftModalMessageBox, Functions\SoftModalMessageBox.ahk
FileRead _TaskDialog,          Functions\TaskDialog.ahk
FileRead _MsgBoxEx,            Functions\MsgBoxEx.ahk

OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x104, "OnWM_SYSKEYDOWN") ; For F10 and Alt+F9
OnMessage(0x112, "OnWM_COMMAND")
OnMessage(0x138, "OnWM_CTLCOLORSTATIC")
OnMessage(0x200, "OnWM_MOUSEMOVE")
OnMessage(0x211, "OnWM_ENTERMENULOOP")

WinGet PID, PID, ahk_id %hWindow%

If (MsgBoxType != "MsgBox" && MsgBoxType != "" && MsgBoxType != "ERROR") {
    GuiControl Choose, MsgBoxType, %MsgBoxType%
    GoSub SetMsgBoxType
}

GoSub CreateCodeViewer

DefineTooltips()

; System menu extra-options
hSysMenu := DllCall("GetSystemMenu", "UInt", hWindow, "Int", False, "Ptr")
DllCall("AppendMenu", "Ptr", hSysMenu, "UInt", 0x800, "UInt", 0, "Str", "") ; Separator
DllCall("AppendMenu", "Ptr", hSysMenu, "UInt", 0, "UPtr", 0xDEAD, "Str", "More Options...`tCtrl+O")
DllCall("AppendMenu", "Ptr", hSysMenu, "UInt", 0, "UPtr", 0xC0DE, "Str", "Buttons in English`tCtrl+E")

Return ; End of the auto-execute section

MagicBoxContextMenu:
    Gui MagicBox: Submit, NoHide
    If (A_GuiControl == "QuestionIcon"
        && (MsgBoxType == "TaskDialog" || MsgBoxType == "TaskDialogIndirect")) {
        GoSub SwitchIcons
        GoSub SetIcon
    }
Return

;MagicBoxEscape:
MagicBoxClose:
    ExitApp

InternalTest:
    Gui MagicBox: Submit, NoHide

    If (MsgBoxType != "MsgBoxEx") {
        WinGet hWnd, ID, %Title% ahk_class #32770 ahk_pid %PID%
    } Else {
        If (Title == "") {
            GuiControl,, Title, Title
        }
        WinGet hWnd, IDLast, %Title% ahk_class AutoHotkeyGUI ahk_pid %PID%, %MBX_Text%
        If (hWnd == hWindow || hWnd == hCodeView) {
            Return
        }
    }

    DllCall("DestroyWindow", "Ptr", hWnd)

    SetTimer Test, 0
Return

Test:
    SetTimer Test, Off

    If (MsgBoxType == "TaskDialogIndirect") {
        GoSub TDI_SetVariables
        GoSub TDI_Test
        Return
    } Else If (MsgBoxType == "MsgBoxEx") {
        GoSub MBX_Test
        Return
    }

    GoSub SetVariables

    ; MsgBox
    If (MsgBoxType == "MsgBox") {

        If (Owned || (Flags & 0x2000 && TimeoutEnabled)) {
            Gui +OwnDialogs
        }

        If (Flags == 0x0 && Title == "" && Text == "" && !TimeoutEnabled && !MB_Custom) {
            MsgBox ; Displays the text "Press OK to continue."
        } Else {
            OnMessage(0x44, "OnMsgBox")

            MsgBox % Flags, %Title%, %Text%, %Timeout%

            OnMessage(0x44, "")
        }

    ; SHMessageBoxCheck
    } Else If (MsgBoxType == "SHMessageBoxCheck") {
        If (MessageBoxCheck(Text, Title, Flags, RegVal, (Owned) ? hWindow : 0) == "Suppressed") {
            SHMsgBoxChkDefault()
        }

    ; TaskDialog
    } Else If (MsgBoxType == "TaskDialog") {
        TDIconRes := (CustomIcon && !InStr(IconRes, "imageres.dll")) ? IconRes : ""
        hParent := (Owned) ? hWindow : 0x10010

        TaskDialog(Text, Content, Title, TDButtons, TDIcon, TDIconRes, hParent)

    ; MessageBoxIndirect
    } Else If (MsgBoxType == "MessageBoxIndirect") {

        If (TimeoutEnabled) {
            SetTimer MBI_CloseMsgBox, % Round(Timeout * 1000)
        }

        MessageBoxIndirect(Text
            , Title
            , Flags
            , (CustomIcon) ? IconRes : ""
            , (CustomIcon) ? ResID : 0
            , (Owned) ? hWindow : 0)

    ; MsiMessageBox
    } Else If (MsgBoxType == "MsiMessageBox") {
        MsiMessageBox(Text, Title, Flags, (Owned) ? hWindow : 0)

    ; WTSSendMessage
    } Else If (MsgBoxType == "WTSSendMessage") {
        WTSSendMessage(Text, Title, Flags, Timeout, WTS_Wait,  -1, 0, Response)
        If (!WTS_Wait) {
            MsgBox 0, %AppName%, Response: 32001 (IDASYNC)
        }

    ; SoftModalMessageBox
    } Else If (MsgBoxType == "SoftModalMessageBox") {
        GoSub SoftTest
    }
Return

; Run the generated code in a new instance of AHK (Alt+F9)
ExternalTest:
    ExecScript(Code . "`nExitApp")
Return

SetIcon:
    ; BM_SETSTATE := 0xF3
    SendMessage 0xF3, 0,,, ahk_id %hPrevIconBtn%
    GuiControlGet hIconBtn, hWnd, %A_GuiControl%
    SendMessage 0xF3, 1,,, ahk_id %hIconBtn%
    hPrevIconBtn := hIconBtn

    If (A_GuiControl == "NoIcon") {
        If (Shields) {
            SetColor("0xB00100", "0xFFFFFF")
        }

        Icon := 0
    } Else If (A_GuiControl == "InfoIcon") {
        If (Shields) {
            SetColor("0x187818", "0xFFFFFF")
        }

        Icon := 0x40
    } Else If (A_GuiControl == "WarningIcon") {
        If (Shields) {
            SetColor("0xF3B409", "0x000000")
        }

        Icon := 0x30
    } Else If (A_GuiControl == "QuestionIcon") {
        If (Shields) {
            SetColor("0x075582", "0xFFFFFF")
        }

        Icon := 0x20
    } Else If (A_GuiControl == "ErrorIcon") {
        If (Shields) {
            SetColor("0x9E9086", "0xFFFFFF")
        }

        Icon := 0x10
    }

    TDI_CustomMainIcon := CustomIcon := False
    GoSub GenerateCode
Return

; Routine associated with radio buttons to define the button set
SetButtons:
    Gui MagicBox: Submit, NoHide

    ButtonSet := ""
    If (hPrevDefBtn) {
        GuiControlGet vVar, MagicBox: Name, %hPrevDefBtn%
        ButtonSet := "Buttons_" . StrSplit(vVar, "_")[2]
    }

    If (A_GuiControl != ButtonSet) {
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
        GoSub GenerateCode
    }
Return

; Routine associated with buttons to define the default button
SetButton:
    v := A_GuiControl

    ; Tick the radio button
    If (InStr(v, "TD_")) {
        GuiControl,, StdTDBtns, 1
    } Else {
        GuiControl,, % "Buttons_" . StrSplit(A_GuiControl, "_")[2], 1
    }

    ; Set the default button
    If (MsgBoxType != "TaskDialog") {
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
        GuiControlGet hDefBtn, hWnd, %A_GuiControl%
        SendMessage 0xF3, 1,,, ahk_id %hDefBtn%
        hPrevDefBtn := hDefBtn

        If (v == "Cancel_OKCancel"
            || v == "No_YesNo"
            || v == "No_YesNoCancel"
            || v == "Retry_AbortRetryIgnore"
            || v == "TryAgain_CancelTryAgainContinue"
            || v == "Cancel_RetryCancel") {
            DefBtn := 0x100 ; MB_DEFBUTTON2
        } Else If (v == "Cancel_YesNoCancel"
            || v == "Ignore_AbortRetryIgnore"
            || v == "Continue_CancelTryAgainContinue") {
            DefBtn := 0x200 ; MB_DEFBUTTON3
        } Else {
            DefBtn := 0
        }
    }

    GoSub GenerateCode
Return

; Routine associated with the DropDownList
SetMsgBoxType:
    Gui MagicBox: Submit, NoHide

    If (MsgBoxType != "TaskDialogIndirect") {
        Gui CustomButtonsDlg: Hide
    }

    ; Show/hide the shield icon
    If (MsgBoxType == "TaskDialog" || MsgBoxType == "TaskDialogIndirect") {
        If (!Shield) {
            GuiButtonIcon(hQuestionBtn, "user32.dll", 7, "L1 T1 w32 h32")
            WinSet Redraw,, ahk_id %hQuestionBtn%
            TT.QuestionIcon := "UAC Shield"
            Shield := True
        }
    } Else If (Shield) {
        GuiButtonIcon(hQuestionBtn, "user32.dll", 3, "L1 T1 w32 h32")
        WinSet Redraw,, ahk_id %hQuestionBtn%
        If (Shields) {
            GoSub SwitchIcons
        }
        TT.QuestionIcon := "Question"
        Shield := False
    }

    ; Show/hide the icon selection button
    If (MsgBoxType == "SHMessageBoxCheck"
        || MsgBoxType == "MsiMessageBox"
        || MsgBoxType == "WTSSendMessage") {
        GuiControl Hide, SelectIconBtn
        GuiControl Hide, CustomIconPreview
    } Else {
        GuiControl Show, SelectIconBtn
        GuiControl Show, CustomIconPreview
    }

    If (PrevType == "SHMessageBoxCheck") {
        GuiControl -Disabled, %hQuestionBtn%
    }

    ; Enable all options prior to applying specific settings
    If (HiddenTab == 1) {
        GuiControl -Disabled, Owned
        GuiControl -Disabled, TaskModal
        GuiControl -Disabled, AlwaysOnTop
        GuiControl -Disabled, RTLReading
        GuiControl -Disabled, TimeoutEnabled
        GuiControl -Disabled, Timeout
    }

    If (MsgBoxType == "MsgBoxEx" || MsgBoxType == "SoftModalMessageBox" || MsgBoxType == "TaskDialogIndirect") {
        GuiControl Choose, HiddenTab, %MsgBoxType%
        GoSub GenerateCode
        Return
    }

    GuiControl Choose, HiddenTab, 1

    If (MsgBoxType == "TaskDialog") {
        GuiControl Move, Edit2, h54 ; Main instruction
        Gui Font, s12 c0x003399, Segoe UI
        GuiControl Font, Edit2
        Gui Font
        GuiControl Show, Edit3 ; Content

        GuiControl Show, SelectIconBtn

        ; Default button option is not available
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%

        GuiControl +Disabled, Abort_AbortRetryIgnore
        GuiControl +Disabled, Retry_AbortRetryIgnore
        GuiControl +Disabled, Ignore_AbortRetryIgnore
        GuiControl +Disabled, Cancel_CancelTryAgainContinue
        GuiControl +Disabled, TryAgain_CancelTryAgainContinue
        GuiControl +Disabled, Continue_CancelTryAgainContinue

        ShowTDButtons()

        DisableOptions("TaskModal", "AlwaysOnTop", "RTLReading", "TimeoutEnabled")
        GuiControl +Disabled, Timeout
    } Else If (PrevType == "TaskDialog") {
        Gui Font, s9 cDefault, Segoe UI
        GuiControl Font, Edit2
        Gui Font
        GuiControl Move, Edit2, h116
        GuiControl Hide, Edit3

        GuiControl -Disabled, Abort_AbortRetryIgnore
        GuiControl -Disabled, Retry_AbortRetryIgnore
        GuiControl -Disabled, Ignore_AbortRetryIgnore
        GuiControl -Disabled, Cancel_CancelTryAgainContinue
        GuiControl -Disabled, TryAgain_CancelTryAgainContinue
        GuiControl -Disabled, Continue_CancelTryAgainContinue

        HideTDButtons()

        GuiControl -Disabled, Timeout
    }

    If (MsgBoxType == "SHMessageBoxCheck") {
        ; The question icon is not available on Vista+
        GuiControl +Disabled, %hQuestionBtn%

        DisableOptions("TaskModal", "AlwaysOnTop")

        GuiControl Hide, TimeoutEnabled
        GuiControl Hide, Timeout
        GuiControl Hide, UpDown
        GuiControl Hide, Seconds

        GuiControl Show, RegVal
        GuiControl,, TimeoutGrp, Unique ID
    } Else If (PrevType == "SHMessageBoxCheck") {
        GuiControl Show, TimeoutEnabled
        GuiControl Show, Timeout
        GuiControl Show, UpDown
        GuiControl Show, Seconds

        GuiControl Hide, RegVal
        GuiControl,, TimeoutGrp, Timeout
    }

    If (MsgBoxType == "MsiMessageBox") {
        ; Abort|Retry|Ignore is Cancel|Retry|Ignore
        GuiControl,, Abort_AbortRetryIgnore, % (English) ? "Cancel" : StrCancel

        GuiControl +Disabled, Cancel_CancelTryAgainContinue
        GuiControl +Disabled, TryAgain_CancelTryAgainContinue
        GuiControl +Disabled, Continue_CancelTryAgainContinue

        If (Buttons_CancelTryAgainContinue) {
            SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
        }

        DisableOptions("Buttons_CancelTryAgainContinue"
            , "HelpBtn", "TaskModal", "AlwaysOnTop", "RTLReading", "TimeoutEnabled")
        GuiControl +Disabled, Timeout
    } Else If (PrevType == "MsiMessageBox") {
        GuiControl,, Abort_AbortRetryIgnore, % (English) ? "Abort" : StrAbort

        GuiControl -Disabled, Buttons_CancelTryAgainContinue
        GuiControl -Disabled, Cancel_CancelTryAgainContinue
        GuiControl -Disabled, TryAgain_CancelTryAgainContinue
        GuiControl -Disabled, Continue_CancelTryAgainContinue

        GuiControl -Disabled, HelpBtn

        GuiControl -Disabled, Timeout
    }

    If (MsgBoxType == "WTSSendMessage") {
        GuiControl Show, WTS_Wait
        GuiControl Move, OptionsGrp, h172
        DisableOptions("Owned", "TaskModal", "AlwaysOnTop")
    } Else If (PrevType == "WTSSendMessage") {
        GuiControl Hide, WTS_Wait
        GuiControl Move, OptionsGrp, h148
    }

    If (MsgBoxType == "MsgBox") {
        GuiControl Show, CustomButtonsBtn
        GuiControl Show, CustomButtonsGrp
        GuiControl Show, MsgBoxPosGrp
        GuiControl Show, MB_LblX
        GuiControl Show, MB_PosX
        GuiControl Show, MB_LblY
        GuiControl Show, MB_PosY
    } Else If (PrevType == "MsgBox") {
        GuiControl Hide, CustomButtonsBtn
        GuiControl Hide, CustomButtonsGrp
        GuiControl Hide, MsgBoxPosGrp
        GuiControl Hide, MB_LblX
        GuiControl Hide, MB_PosX
        GuiControl Hide, MB_LblY
        GuiControl Hide, MB_PosY
    }

    PrevType := MsgBoxType

    GoSub GenerateCode
Return

DisableOptions(Options*) {
    For Foo, Option in Options {
        GuiControl,, %Option%, 0
        GuiControl +Disabled, %Option%
    }
}

Reset:
    SendMessage 0xF3, 0,,, ahk_id %hPrevIconBtn%
    Icon := 0
    CustomIcon := False
    GuiControl,, CustomIconPreview

    GuiControl,, Title
    GuiControl,, Text
    GuiControl,, Content

    SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
    DefBtn := 0
    GuiControl,, Buttons_OK, 1
    GuiControl,, HelpBtn, 0

    GuiControl,, NoOwner, 1
    GuiControl,, AlwaysOnTop, 0
    GuiControl,, RTLReading, 0

    GuiControl,, MB_PosX
    GuiControl,, MB_PosY

    GuiControl,, TimeoutEnabled, 0
    GuiControl,, Timeout

    GuiControl,, RegVal

    GuiControl,, WTS_Wait, 1

    If (Shields) {
        ControlColor(hText, hWindow, "", "", 1)
        ControlColor(hMainInstruction, hWindow, "", "", 1)
        Icon := -1
    }

    GuiControl,, TD_OK, 0
    GuiControl,, TD_Yes, 0
    GuiControl,, TD_No, 0
    GuiControl,, TD_Cancel, 0
    GuiControl,, TD_Retry, 0
    GuiControl,, TD_Close, 0

    ; TDI
    TDI_CustomMainIcon := False
    GuiControl,, TDI_Instruction
    GuiControl,, TDI_Content
    GuiControl,, TDI_ExpandedText
    GuiControl,, TDI_CollapsedControlText
    GuiControl,, TDI_ExpandedControlText
    GuiControl,, TDI_VerificationText
    GuiControl,, TDI_FooterText
    GuiControl,, TDI_OK, 0
    GuiControl,, TDI_Yes, 0
    GuiControl,, TDI_No, 0
    GuiControl,, TDI_Cancel, 0
    GuiControl,, TDI_Retry, 0
    GuiControl,, TDI_Close, 0
    GuiControl,, TDI_AlwaysOnTop, 0
    GuiControl,, TDI_AllowCancellation, 0
    GuiControl,, TDI_CanBeMinimized, 0
    GuiControl,, TDI_RelativePosition, 0
    GuiControl,, TDI_RTLReading, 0
    GuiControl,, TDI_ProgressBar, 0
    GuiControl,, TDI_Marquee, 0
    GuiControl,, TDI_Width
    GuiControl,, TDI_TimeoutEnabled, 0
    GuiControl,, TDI_Timeout
    GuiControl,, TDI_ExpandedByDefault, 0
    GuiControl,, TDI_ExpandInFooterArea, 0
    GuiControl,, TDI_VerificationFlag, 0
    TDI_FooterIcon := 0
    TDI_CustomFooterIcon := False
    GuiButtonIcon(hFooterIconBtn, "")

    ; TDI custom buttons
    Gui CustomButtonsDlg: Default
    TDI_ButtonID := 100
    CustomButtons := []
    Gui ListView, LVButtons
    LV_Delete()
    GuiControl,, TDI_CommandLinks, 0
    GuiControl,, TDI_CommandLinksNoIcon, 0
    GuiControl,, TDI_DefaultButtonList, |First button||
    TDI_RadioID := 200
    RadioButtons := []
    Gui ListView, LVRadioButtons
    LV_Delete()
    GuiControl,, TDI_DefaultRadioList, |First button||None

    ; SoftModalMessageBox
    Gui MagicBox: Default
    GuiControl,, SM_Text
    GoSub SM_ClearAll
    GuiControl,, SM_NoOwner, 1
    GuiControl,, SM_AlwaysOnTop, 0
    GuiControl,, SM_RTLReading, 0
    GuiControl,, SM_TimeoutEnabled, 0
    GuiControl,, SM_Timeout

    ; More Options
    Gui MoreOptionsDlg: Default
    GuiControl,, SystemModal, 0
    GuiControl,, NoFocus, 0
    GuiControl,, SetForeground, 0
    GuiControl,, DefaultDesktopOnly, 0
    GuiControl,, Servicenotification, 0
    GuiControl,, Right, 0
    GuiControl,, DefButton4, 0

    ; MB custom buttons
    GoSub MB_CustomButtonsDlgReset
    Gui MagicBox: Default

    ; MsgBoxEx
    GuiControl,, MBX_Text
    GuiControl,, MBX_VerificationText
    Gui ListView, %hMBX_LV%
    LV_Delete()
    LV_Add("", "OK")
    GoSub MBX_UpdateDefaultButtonList
    GuiControl,, MBX_Owned, 0
    GuiControl,, MBX_NoCloseButton, 0
    GuiControl,, MBX_CanBeMinimized, 0
    GuiControl,, MBX_AlwaysOnTop, 0
    GuiControl,, MBX_CheckedByDefault, 0
    MBX_CustomFont := False
    MBX_CustomBGColor := False
    GuiControl,, MBX_TimeoutEnabled, 0
    GuiControl,, MBX_Timeout
Return

SelectIcon:
    Gui MagicBox: Submit, NoHide

    If (ChooseIcon(IconRes, IconIdx, hWindow)) {
        VarSetCapacity(Output, 4096)
        DllCall("ExpandEnvironmentStrings", "Str", IconRes, "Str", Output, "UInt", 4096)

        ; Exclude system path from output
        IconRes := RegExReplace(Output, "i)\Q" . A_WinDir . "\Sys\E(tem32|WOW64)\\")
        ;StringReplace IconRes, Output, %A_WinDir%\System32\

        SplitPath IconRes,,, Extension
        If (Extension = "ico"
            && (MsgBoxType == "MessageBoxIndirect"
            || MsgBoxType == "SoftModalMessageBox"
            || MsgBoxType == "TaskDialog")) {
            MsgBox 0x2030, %AppName%, %MsgBoxType% icon cannot be loaded from an .ico file.
            IconRes := "shell32.dll"
            GoSub SelectIcon
        }

        GuiControl,, CustomIconPreview, *Icon%IconIdx% %IconRes%
        SendMessage 0xF3, 0,,, ahk_id %hPrevIconBtn%

        TDI_CustomMainIcon := CustomIcon := True
        TDI_MainIconRes := IconRes
        TDI_MainIcon := ResId := ResourceIdOfIcon(IconRes, IconIdx - 1)
        TDI_MainIconIdx := IconIdx

        GoSub GenerateCode
    }
Return

EnableCustomIcon:
    SendMessage 0xF3, 0,,, ahk_id %hPrevIconBtn%
    TDI_CustomMainIcon := CustomIcon := True
    GoSub GenerateCode
Return

CreateCodeViewer:
    Gui CodeView: New, LabelCodeView hWndhCodeView Resize
    Gui Font, s10 c0x003399, Lucida Console
    Gui Add, Edit, hWndhEdtCode vEdtCode x8 y8 w583 h287 Multi WantTab
    Gui Font
    TabSize := 4
    VarSetCapacity(TabStops, 4, 0)
    NumPut(TabSize * 4, TabStops, "UInt")
    SendMessage 0xCB, 1, &TabStops,, ahk_id %hEdtCode% ; EM_SETTABSTOPS
    Gui Font, s9, Segoe UI
    Gui Add, CheckBox, vIfBlocks gGenerateCode x8 y307 w333 h23 Checked, &Generate conditional statement blocks for the return value
    Gui Add, Button, gSaveCode x354 y307 w75 h23, &Save
    Gui Add, Button, gCopy x435 y307 w75 h23, &Copy
    Gui Add, Button, gCancel x516 y307 w75 h23, C&lose
    Gui Font
    Gui Show, w599 h343 Hide, %AppName% - Code
    Gui +MinSize599
Return

ViewCode:
    Gui CodeView: Show
    GoSub GenerateCode
Return

CodeViewSize:
    AutoXYWH("wh", "EdtCode")
    AutoXYWH("y", "IfBlocks")
    AutoXYWH("*xy", "Button2", "Button3", "Button4")
Return

CodeViewEscape:
    Gui CodeView: Cancel
Return

Copy:
    GuiControlGet Output, CodeView:, EdtCode
    Clipboard := Output

    If (A_Gui == "CodeView") {
        Gui CodeView: Cancel
    }
Return

SetVariables:
    Gui MagicBox: Submit, NoHide

    SetFormat Integer, Hex

    If (MsgBoxType == "TaskDialog") {

        TDButtons := 0

        If (Buttons_OK) {
            TDButtons := 1
        } Else If (Buttons_OKCancel) {
            TDButtons := 0x9
        } Else If (Buttons_YesNo) {
            TDButtons := 0x6
        } Else If (Buttons_YesNoCancel) {
            TDButtons := 0xE
        } Else If (Buttons_RetryCancel) {
            TDButtons := 0x18
        } Else If (StdTDBtns) {
            If (TD_OK) {
                TDButtons |= 0x1
            }

            If (TD_Yes) {
                TDButtons |= 0x2
            }

            If (TD_No) {
                TDButtons |= 0x4
            }

            If (TD_Cancel) {
                TDButtons |= 0x8
            }

            If (TD_Retry) {
                TDButtons |= 0x10
            }

            If (TD_Close) {
                TDButtons |= 0x20
            }
        }

        If (!CustomIcon) {
            If (Icon == 0) {
                TDIcon := (Shields) ? 0xFFF9 : 0
            } Else If (Icon == 0x10) {
                TDIcon := (Shields) ? 0xFFF7 : 0xFFFE ; TD_ERROR_ICON
            } Else If (Icon == 0x20) {
                TDIcon := (Shields) ? 0xFFFB : 0xFFFC ; TD_SHIELD_ICON
            } Else If (Icon == 0x30) {
                TDIcon := (Shields) ? 0xFFFA : 0xFFFF ; TD_WARNING_ICON
            } Else If (Icon == 0x40) {
                TDIcon := (Shields) ? 0xFFF8 : 0xFFFD ; TD_INFORMATION_ICON
            } Else {
                TDIcon := 0
            }
        } Else {
            SetFormat Integer, D
            TDIcon := ResId
        }

    } Else If (MsgBoxType == "SoftModalMessageBox") {

        Flags := 0x1

        If (SM_TaskModal) {
            Flags |= 0x2000
        }

        If (SM_AlwaysOnTop) {
            Flags |= 0x40000
        }

        If (SM_RTLReading) {
            Flags |= 0x80000  ; MB_RIGHT
            Flags |= 0x100000 ; MB_RTLREADING
        }

        If (CustomIcon) {
            Flags |= 0x80 ; MB_USERICON
        } Else {
            Flags |= Icon
        }

        SetFormat Integer, D
        Timeout := SM_TimeoutEnabled ? Round(SM_Timeout * 1000) : -1

        GuiControlGet hWnd, MagicBox: hWnd, SM_DefaultButtonList
        SendMessage 0x147, 0, 0,, ahk_id %hWnd% ; CB_GETCURSEL
        SM_DefaultButton := (ErrorLevel) ? ErrorLevel : 1

    } Else {

        Flags := 0x0

        ; Buttons
        If (Buttons_OK) {
            Flags := 0
        } Else If (Buttons_OKCancel) {
            Flags := 1
        } Else If (Buttons_YesNo) {
            Flags := 4
        } Else If (Buttons_YesNoCancel) {
            Flags := 3
        } Else If (Buttons_AbortRetryIgnore) {
            Flags := 2
        } Else If (Buttons_CancelTryAgainContinue) {
            Flags := 6
        } Else If (Buttons_RetryCancel) {
            Flags := 5
        }

        If (HelpBtn) {
            Flags |= 0x4000
        }

        If (CustomIcon && (MsgBoxType == "MsgBox"
            || MsgBoxType == "MessageBoxIndirect"
            || MsgBoxType == "SoftModalMessageBox")) {
            Flags |= 0x80 ; MB_USERICON
        } Else {
            Flags |= Icon
        }

        Flags |= DefBtn

        If (TaskModal) {
            Flags |= 0x2000
        }

        If (AlwaysOnTop) {
            Flags |= 0x40000
        }

        If (RTLReading) {
            Flags |= 0x80000  ; MB_RIGHT
            Flags |= 0x100000 ; MB_RTLREADING
        }

        SetFormat Integer, D
        Timeout := (TimeoutEnabled) ? Timeout : ""

        If (MsgBoxType == "MsgBox" && (!MB_Custom := CustomIcon)) {
            Loop 4 {
                If (MB_CustomButtons[A_Index].Text != ""
                ||  MB_CustomButtons[A_Index].IconRes != "") {
                    MB_Custom := True
                    Break
                }
            }

            If (MB_PosX != "" || MB_PosY != "") {
                MB_Custom := True
            }
        }
    }

    If (MoreOptionsDlgCreated && MsgBoxType != "MsiMessageBox") {
        Gui MoreOptionsDlg: Submit
        SetFormat Integer, H

        If (SystemModal) {
            Flags |= 0x1000
        }

        If (NoFocus) {
            Flags |= 0x8000
        }

        If (SetForeground) {
            Flags |= 0x10000
        }

        If (DefaultDesktopOnly) {
            Flags |= 0x20000
        }

        If (ServiceNotification) {
            Flags |= 0x200000
        }

        If (Right) {
            Flags |= 0x80000
        }

        If (DefButton4) {
            Flags ^= DefBtn
            Flags |= 0x300
        }
    }

    SetFormat Integer, D
Return

GenerateCode:
    If (MsgBoxType == "TaskDialogIndirect") {
        GoSub TDI_GenerateCode
        Return
    } Else If (MsgBoxType == "MsgBoxEx") {
        GoSub MBX_GenerateCode
        Return
    }

    GoSub SetVariables

    Gui CodeView: Submit, NoHide

    If (MsgBoxType != "MsgBox") {
        ; Escape line breaks, quotes and semicolons
        Title := EscapeChars(Title)
        Text := EscapeChars(Text)
    } Else {
        ; Escape line breaks, commas, semicolons and percent signs
        Title := MB_EscapeChars(Title)
        Text := MB_EscapeChars(Text)
    }

    Code := ""

    If (MsgBoxType == "MsgBox") {

        If (Owned) {
            Code := "Gui +OwnDialogs`n"
        }

        If (Flags == 0 && Title == "" && !TimeoutEnabled && !MB_Custom) {
            Code .= "MsgBox " . Text
        } Else {
            If (MB_Custom) {
                Code .= "OnMessage(0x44, ""OnMsgBox"")`n"
            }

            Code .= "MsgBox " . Flags . ", " . Title . ", " . Text

            If (TimeoutEnabled) {
                Code .= ", " . Timeout
            }

            If (MB_Custom) {
                Code .= "`nOnMessage(0x44, """")"
            }

            If (IfBlocks) {
                GoSub GenerateIfBlocks
            }

            If (HelpBtn) {
                GoSub GenerateHelp
            }

            If (MB_Custom) {
                Code .= "`n`nOnMsgBox() {`n"
                     .  "    DetectHiddenWindows, On`n"
                     .  "    Process, Exist`n"
                     .  "    If (WinExist(""ahk_class #32770 ahk_pid "" . ErrorLevel)) {`n"

                If (CustomIcon) {
                    Code .= "        hIcon := LoadPicture(""" . IconRes
                         .  """, ""w32 Icon" . IconIdx . """, _)`n"
                         .  "        SendMessage 0x172, 1, %hIcon%, Static1 `; STM_SETIMAGE`n"
                }

                ButtonSet := Flags & 0xF
                If (!ButtonSet) {
                    cButtons := 1
                } Else If (ButtonSet ~= "1|4|5") {
                    cButtons := 2
                } Else {
                    cButtons := 3
                }

                Loop %cButtons% {
                    ButtonText := MB_CustomButtons[A_Index].Text
                    ButtonIcon := MB_CustomButtons[A_Index].IconRes

                    If (ButtonText != "") {
                        ButtonText := MB_EscapeChars(ButtonText)
                        Code .= "        ControlSetText Button" . A_Index . ", " . ButtonText . "`n"
                    }

                    If (ButtonIcon != "") {
                        Code .= "        hIcon := LoadPicture(""" . ButtonIcon . """, "
                             .  """h16 Icon" . MB_CustomButtons[A_Index].IconIdx . """, _)`n"
                             .  "        SendMessage 0xF7, 1, %hIcon%, Button" . A_Index . "`n"
                    }
                }

                If (HelpBtn && (MB_CustomButtons[4].Text != "" || MB_CustomButtons[4].IconRes != "")) {
                    ButtonText := MB_CustomButtons[4].Text
                    ButtonIcon := MB_CustomButtons[4].IconRes

                    HelpBtnPos := cButtons + HelpBtn

                    If (ButtonText != "") {
                        Code .= "        ControlSetText Button" . HelpBtnPos . ", " . ButtonText . "`n"
                    }

                    If (ButtonIcon != "") {
                        Code .= "        hIcon := LoadPicture(""" . ButtonIcon . """, "
                             .  """h16 Icon" . MB_CustomButtons[4].IconIdx . """, _)`n"
                             .  "        SendMessage 0xF7, 1, %hIcon%, Button" . HelpBtnPos . "`n"
                    }
                }

                If (MB_PosX != "" || MB_PosY != "") {
                    x := (MB_PosX != "") ? " " . MB_PosX : ","
                    y := (MB_PosY != "") ? ", " . MB_PosY : ""
                    Code .= "        WinMove" . x . y . "`n"
                }

                Code .= "    }`n}"
            }
        }

    } Else If (MsgBoxType == "SHMessageBoxCheck") {

        Code := "Text := """ . Text . """`n`n"

        If (!Buttons_OK) {
            Code .= "Result := "
        }

        Code .= "MessageBoxCheck(Text, """ . Title . """, " . Flags

        If (SubStr(RegVal, 1, 2) != "A_") {
            Code .= ", """ . RegVal . """"
        } Else {
            Code .= ", " . RegVal
        }

        If (Owned) {
            Code .= ", WinExist(""A""))"
        } Else {
            Code .= (HelpBtn) ? ", A_ScriptHwnd)" : ")"
        }

        If (IfBlocks) {
            GoSub GenerateIfBlocks
        }

        If (HelpBtn) {
            GoSub GenerateHelp
        }

        Code .= "`n`n" . _MessageBoxCheck

    } Else If (MsgBoxType == "TaskDialog") {

        Code .= "Instruction := """ . Text . """`n"
        Code .= "Content := """ . EscapeChars(Content) . """`n`n"

        If (!Buttons_OK) {
            Code .= "Result := "
        }

        Code .= "TaskDialog(Instruction, Content, """ . Title . """, " . TDButtons . ", " . TDIcon

        If (IconRes != "" && IconRes != "imageres.dll") {
            Code .= ", """ . IconRes . """"
        } Else If (Owned) {
            Code .= ", """""
        }

        If (Owned) {
            Code .= ", WinExist(""A""))"
        } Else {
            Code .= ")"
        }

        If (IfBlocks) {
            GoSub GenerateIfBlocks
        }

        Code .= "`n`n" . _TaskDialog

    } Else If (MsgBoxType == "MessageBoxIndirect") {

        If (TimeoutEnabled) {
            Code .= "SetTimer CloseMsgBox, " . Round(Timeout * 1000) . "`n`n"
        }

        Code .= "Text := """ . Text . """`n`n"

        If (!Buttons_OK) {
            Code .= "Result := "
        }

        Code .= "MessageBoxIndirect(Text, """ . Title . """, " . Flags

        If (CustomIcon) {
            Code .= ", """ . IconRes . """, " . ResId
        } Else If (Owned || HelpBtn) {
            Code .= ", """", 0"
        }

        If (Owned) {
            Code .= ", WinExist(""A""))"
        } Else {
            Code .= (HelpBtn) ? ", A_ScriptHwnd)" : ")"
        }

        If (IfBlocks) {
            GoSub GenerateIfBlocks
        }

        If (HelpBtn) {
            GoSub GenerateHelp
        }

        Code .= "`n`n" . _MessageBoxIndirect

        If (TimeoutEnabled) {
            Code .= "`n`nCloseMsgBox:`n"
            Code .= "    SetTimer CloseMsgBox, Off`n"
            Code .= "    WinClose " . Title . " ahk_class #32770`n"
            Code .= "Return`n"
        }

    } Else If (MsgBoxType == "MsiMessageBox") {

        Code .= "Text := """ . Text . """`n`n"

        If (!Buttons_OK) {
            Code .= "Result := "
        }

        Code .= "MsiMessageBox(Text, """ . Title . """, " . Flags

        Code .= (Owned) ? ", WinExist(""A""))" : ")"

        If (IfBlocks) {
            GoSub GenerateIfBlocks
        }

        Code .= "`n`n" . _MsiMessageBox

    } Else If (MsgBoxType == "WTSSendMessage") {

        Code .= "Text := """ . Text . """`n`n"

        If (!Buttons_OK || WTS_Wait) {
            Code .= "Result := "
        }

        Code .= "WTSSendMessage(Text, """ . Title . """, " . Flags . ", "
        Code .= ((TimeoutEnabled) ? Timeout : "0") . ", " . WTS_Wait . ", -1, 0)"

        If (IfBlocks && WTS_Wait) {
            GoSub GenerateIfBlocks
        }

        Code .= "`n`n" . _WTSSendMessage

    } Else If (MsgBoxType == "SoftModalMessageBox") {

        Code .= "Text := """ . EscapeChars(SM_Text) . """`n"

        cButtons := SM_CustomButtons.Length()
        Code .= "Buttons := ["
        SM_Callback := False
        Loop %cButtons% {
            ButtonID := SM_CustomButtons[A_Index][1]
            If (ButtonID == 9) {
                SM_Callback := True
            }

            Code .= "[" . ButtonID . ", """ . EscapeChars(SM_CustomButtons[A_Index][2]) . """], "
        }
        Code := RTrim(Code, ", ")
        Code .= "]`n`n"

        Call := ""
        DefParam := False

        If (SM_Callback) {
            Call := ", ""SoftModalCallback"""
            DefParam := True
        }

        If (SM_Owned) {
            Call := ", WinExist(""A"")" . Call
            DefParam := True
        } Else If (DefParam) {
            Call := ", 0" . Call
        }

        If (SM_TimeoutEnabled) {
            Call := ", " . Timeout . Call
            DefParam := True
        } Else If (DefParam) {
            Call := ", -1" . Call
        }

        If (CustomIcon) {
            Call := ", """ . IconRes . """, " . ResID . Call
            DefParam := True
        } Else If (DefParam) {
            Call := ", """", 0" . Call
        }

        If (Flags != 0x1 || DefParam) {
            Call := ", " . Flags . Call
            DefParam := True
        }

        If (SM_DefaultButton > 1 || DefParam) {
            Call := ", " . SM_DefaultButton . Call
        }

        If (cButtons > 1 || (cButtons && SM_TimeoutEnabled)) {
            Code .= "Result := "
        }

        Code .= "SoftModalMessageBox(Text, """ . Title . """, Buttons" . Call . ")`n`n"

        If (IfBlocks) {
            GoSub SM_GenerateIfBlocks
        }

        If (SM_Callback) {
            Code .= "SoftModalCallback() { `; 9`n    MsgBox`n}`n`n"
        }

        Code .= "" . _SoftModalMessageBox
    }

    GuiControl, CodeView:, EdtCode, %Code%
Return

GenerateIfBlocks:
    If (MsgBoxType == "MsgBox") {

        Ifs := ""
        Br  := ", {`n`n}"

        If (Buttons_OKCancel) {
            Ifs := "`n`nIfMsgBox OK" . Br . " Else IfMsgBox Cancel" . Br
        } Else If (Buttons_YesNo) {
            Ifs := "`n`nIfMsgBox Yes" . Br . " Else IfMsgBox No" . Br
        } Else If (Buttons_YesNoCancel) {
            Ifs := "`n`nIfMsgBox Yes" . Br . " Else IfMsgBox No" . Br . " Else IfMsgBox Cancel" . Br
        } Else If (Buttons_AbortRetryIgnore) {
            Ifs := "`n`nIfMsgBox Abort" . Br . " Else IfMsgBox Retry" . Br . " Else IfMsgBox Ignore" . Br
        } Else If (Buttons_CancelTryAgainContinue) {
            Ifs := "`n`nIfMsgBox Cancel" . Br . " Else IfMsgBox TryAgain" . Br . " Else IfMsgBox Continue" . Br
        } Else If (Buttons_RetryCancel) {
            Ifs := "`n`nIfMsgBox Retry" . Br . " Else IfMsgBox Cancel" . Br
        }

        If (TimeoutEnabled) {
            If (Ifs != "") {
                Ifs .= " Else "
            } Else {
                Ifs .= "`n`n"
            }

            Ifs .= "IfMsgBox Timeout" . Br
        }

        Code .= Ifs

    } Else {
        If (!WTS_Wait && MsgBoxType == "WTSSendMessage") {
            Return
        }

        If (Buttons_OKCancel) {
            Code .= "`n`nIf (Result == ""OK"") {`n`n}"
            Code .= " Else If (Result == ""Cancel"") {`n`n}"
        } Else If (Buttons_YesNo) {
            Code .= "`n`nIf (Result == ""Yes"") {`n`n}"
            Code .= " Else If (Result == ""No"") {`n`n}"
        } Else If (Buttons_YesNoCancel) {
            Code .= "`n`nIf (Result == ""Yes"") {`n`n}"
            Code .= " Else If (Result == ""No"") {`n`n}"
            Code .= " Else If (Result == ""Cancel"") {`n`n}"
        } Else If (Buttons_AbortRetryIgnore) {
            If (MsgBoxType != "MsiMessageBox") {
                Code .= "`n`nIf (Result == ""Abort"") {`n`n}"
            } Else {
                Code .= "`n`nIf (Result == ""Cancel"") {`n`n}"
            }
            Code .= " Else If (Result == ""Retry"") {`n`n}"
            Code .= " Else If (Result == ""Ignore"") {`n`n}"
        } Else If (Buttons_CancelTryAgainContinue) {
            Code .= "`n`nIf (Result == ""Cancel"") {`n`n}"
            Code .= " Else If (Result == ""Try Again"") {`n`n}"
            Code .= " Else If (Result == ""Continue"") {`n`n}"
        } Else If (Buttons_RetryCancel) {
            Code .= "`n`nIf (Result == ""Retry"") {`n`n}"
            Code .= " Else If (Result == ""Cancel"") {`n`n}"
        }

        If (MsgBoxType == "WTSSendMessage" && WTS_Wait && TimeoutEnabled) {
            If (!Buttons_OK) {
                Code .= " Else "
            } Else {
                Code .= "`n`n"
            }
            Code .= "If (Result == ""Timeout"") {`n`n}"
        }
    }
Return

GenerateHelp:
    If (MsgBoxType == "MsgBox" && !Owned) {
        Code := "Gui +OwnDialogs`n" . Code
    }

    Code := "OnMessage(0x53, ""OnHelp"")`n`n" . Code . "`n`nOnHelp() {`n`n}"
Return

EscapeChars(String) {
    StringReplace String, String, `n, ``n, All   ; Newlines
    StringReplace String, String, `", `"`",, All ; Quotes
    StringReplace String, String, `;, ```;, All  ; Semicolons
    ;StringReplace String, String, ``, ````, All ; Backticks
    Return String
}

MB_EscapeChars(String) {
    StringReplace String, String, `n, ``n, All   ; Newlines
    StringReplace String, String, `,, ```,, All  ; Commas
    StringReplace String, String, `;, ```;, All  ; Semicolons
    StringReplace String, String, `%, ```%, All  ; Percent signs
    Return String
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    Global

    CtrlP := GetKeyState("Ctrl", "P")

    If (wParam == 0x78) { ; F9
        If (A_Gui == "CodeView" && CtrlP) {
            GuiControlGet Script, CodeView:, EdtCode
            ExecScript(Script . "`nExitApp")
        } Else {
            GoSub InternalTest
        }
        Return False
    } Else If (wParam == 0x70) { ; F1
        ShowHelp()
        Return False
    } Else If (CtrlP && wParam == 0x4F) { ; Ctrl+O
        GoSub ShowMoreOptions
        Return False
    } Else If (CtrlP && wParam == 0x45) { ; Ctrl+E
        English := SwitchButtonText(!English)
        Return False
    }

    ; Fix for tabstops
    If (wParam == 9) {
        ShiftP := GetKeyState("Shift", "P")

        If (!ShiftP && A_GuiControl == "Title") {
            If (MsgBoxType == "MsgBox") {
                GuiControl Focus, Text
            } Else If (MsgBoxType == "SoftModalMessageBox") {
                GuiControl Focus, SM_Text
            } Else If (MsgBoxType == "TaskDialogIndirect") {
                GuiControl Focus, TDI_Instruction
            } Else If (MsgBoxType == "MsgBoxEx") {
                GuiControl Focus, MBX_Text
            }
            Return False
        } Else If (ShiftP && A_GuiControl ~= "((MBX|SM)_Text|^Text$|TDI_Instruction)") {
            GuiControl Focus, Title
            Return False
        } Else If (!ShiftP && A_GuiControl ~= "_Timeout$", True) {
            GuiControl Focus, TestBtn
            Return False
        } Else If (!ShiftP && A_GuiControl == "BtnCopy") {
            GuiControl Focus, MsgBoxType
            Return False
        } Else If (!ShiftP && A_GuiControl == "MsgBoxType") {
            GuiControl Focus, NoIcon
            Return False
        }
    }

    ; Delete selected item in any LV
    ControlGetFocus FocusedControl, A
    If (InStr(FocusedControl, "SysL", True) && wParam == 0x2E) {
        If (MsgBoxType == "MsgBoxEx") {
            GoSub MBX_DeleteButton
        } Else If (MsgBoxType == "SoftModalMessageBox") {
            GoSub SM_DeleteItem
        } Else If (MsgBoxType == "TaskDialogIndirect") {
            GoSub TDI_DeleteItem
        }
        Return False
    }
}

OnWM_SYSKEYDOWN(wParam, lParam, msg, hWnd) {
    If (wParam == 0x79) { ; F10
        GoSub ViewCode
        Return False
    } Else If (wParam == 120) { ; Alt+F9
        GoSub GenerateCode
        GoSub ExternalTest
        Return False
    } Else If (wParam == 81) { ; Alt+Q
        ExitApp
    }
}

; Show/hide TaskDialog specific button sets
ShowTDButtons(Show := 1) {
    Global
    GuiControl Hide%Show%, HelpBtn
    GuiControl Show%Show%, StdTDBtns
    GuiControl Show%Show%, TD_OK
    GuiControl Show%Show%, TD_Yes
    GuiControl Show%Show%, TD_No
    GuiControl Show%Show%, TD_Cancel
    GuiControl Show%Show%, TD_Retry
    GuiControl Show%Show%, TD_Close

    If (Show) {
        DisableOptions("Buttons_AbortRetryIgnore", "Buttons_CancelTryAgainContinue")
    } Else {
        GuiControl -Disabled, Buttons_AbortRetryIgnore
        GuiControl -Disabled, Buttons_CancelTryAgainContinue
    }
}

HideTDButtons() {
    ShowTDButtons(0)
}

; Show/hide UAC shield icons
SwitchIcons:
    If (Shields) {
        GuiButtonIcon(hNoIconBtn, "")
        GuiControl,, NoIcon, None
        GuiButtonIcon(hInfoBtn, "user32.dll", 5, "L1 T1 w32 h32")
        GuiButtonIcon(hWarningBtn, "user32.dll", 2, "L1 T1 w32 h32")
        GuiButtonIcon(hErrorBtn, "user32.dll", 4, "L1 T1 w32 h32")
        SetColor("", "")
    } Else {
        GuiControl,, NoIcon
        GuiButtonIcon(hNoIconBtn, "imageres.dll", 101, "L1 T1 w32 h32")
        GuiButtonIcon(hInfoBtn, "imageres.dll", 102, "L1 T1 w32 h32")
        GuiButtonIcon(hWarningBtn, "imageres.dll", 103, "L1 T1 w32 h32")
        GuiButtonIcon(hErrorBtn, "user32.dll", 7, "L1 T1 w32 h32")
    }

    Shields := !Shields
Return

; TD/TDI main instruction background and text colors (associated with UAC shields)
SetColor(BGC, FGC) {
    Global
    ControlColor(hText, hWindow, BGC, FGC, 1)
    ControlColor(hMainInstruction, hWindow, BGC, FGC, 1)
}

; TaskDialogIndirect ***********************************************************

TDI_Test:
    VarSetCapacity(TDC, TDCSize, 0)

    ; Custom buttons
    cButtons := CustomButtons.Length()
    If (cButtons) {

        VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)
        Loop %cButtons% {
            iButtonID := CustomButtons[A_Index][1]
            iButtonText := &(b%A_Index% := CustomButtons[A_Index][2])
            NumPut(iButtonID,   pButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
            NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
        }

        NumPut(cButtons, TDC, (x64) ? 60 : 36, "UInt") ; cButtons
        NumPut(&pButtons, TDC, (x64) ? 64 : 40, "Ptr") ; pButtons
    }

    ; Radio buttons
    cRadioButtons := RadioButtons.Length()
    If (cRadioButtons) {

        VarSetCapacity(pRadioButtons, 4 * cRadioButtons + A_PtrSize * cRadioButtons, 0)
        Loop %cRadioButtons% {
            iRadioID := RadioButtons[A_Index][1]
            iRadioText := &(r%A_Index% := RadioButtons[A_Index][2])
            NumPut(iRadioID,   pRadioButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
            NumPut(iRadioText, pRadioButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
        }

        NumPut(cRadioButtons, TDC, (x64) ? 76 : 48, "UInt") ; cRadioButtons
        NumPut(&pRadioButtons, TDC, (x64) ? 80 : 52, "Ptr") ; pRadioButtons
    }

    ; Custom main icon
    If (TDI_CustomMainIcon && !InStr(TDI_MainIconRes, "imageres.dll")) {
        TDI_MainIcon := LoadPicture(TDI_MainIconRes, "w32 Icon" . TDI_MainIconIdx, ImageType)
    }

    ; Custom footer icon
    If (TDI_CustomFooterIcon && !InStr(TDI_FooterIconRes, "imageres.dll")) {
        TDI_FooterIcon := LoadPicture(TDI_FooterIconRes, "w16 Icon" . TDI_FooterIconIdx, ImageType)
    }

    ; Options handled in the callback
    If (TDI_AlwaysOnTop || TDI_TimeoutEnabled || TDI_Marquee) {
        CBData := {}
        CBData.AlwaysOnTop := TDI_AlwaysOnTop
        CBData.Timeout := TDI_Timeout
        CBData.Marquee := TDI_Marquee

        TDI_Callback := RegisterCallback("TDI_Callback", "Fast")
        NumPut(TDI_Callback, TDC, (x64) ? 140 : 84, "Ptr") ; pfCallback
        NumPut(&CBData, TDC, (x64) ? 148 : 88, "Ptr") ; lpCallbackData
    } Else {
        TDI_Callback := False
    }

    If (TDI_RelativePosition) {
        hParent := hWindow
    } Else If (TDI_Cancel) {
        hParent := DllCall("GetDesktopWindow", "Ptr")
    } Else {
        hParent := 0
    }

    ; TASKDIALOGCONFIG structure
    NumPut(TDCSize, TDC, 0, "UInt")                                 ; cbSize
    NumPut(hParent, TDC, 4, "Ptr")                                  ; hwndParent
    ;NumPut(hModule, TDC, (x64) ? 12 : 8, "Ptr")                    ; hInstance
    NumPut(TDI_Flags, TDC, (x64) ? 20 : 12, "Int")                  ; dwFlags
    NumPut(TDI_Buttons, TDC, (x64) ? 24 : 16, "Int")                ; dwCommonButtons
    NumPut(&Title, TDC, (x64) ? 28 : 20, "Ptr")                     ; pszWindowTitle
    NumPut(TDI_MainIcon, TDC, (x64) ? 36 : 24, "Ptr")               ; pszMainIcon
    NumPut(&TDI_Instruction, TDC, (x64) ? 44 : 28, "Ptr")           ; pszMainInstruction
    NumPut(&TDI_Content, TDC, (x64) ? 52 : 32, "Ptr")               ; pszContent
    NumPut(TDI_DefaultButton, TDC, (x64) ? 72 : 44, "Int")          ; nDefaultButton
    NumPut(TDI_DefaultRadio, TDC, (x64) ? 88 : 56, "Int")           ; nDefaultRadioButton
    NumPut(&TDI_VerificationText, TDC, (x64) ? 92 : 60, "Ptr")      ; pszVerificationText
    NumPut(&TDI_ExpandedText, TDC, (x64) ? 100 : 64, "Ptr")         ; pszExpandedInformation
    NumPut(&TDI_ExpandedControlText, TDC, (x64) ? 108 : 68, "Ptr")  ; pszExpandedControlText
    NumPut(&TDI_CollapsedControlText, TDC, (x64) ? 116 : 72, "Ptr") ; pszCollapsedControlText
    NumPut(TDI_FooterIcon, TDC, (x64) ? 124 : 76, "Ptr")            ; pszFooterIcon
    NumPut(&TDI_FooterText, TDC, (x64) ? 132 : 80, "Ptr")           ; pszFooter
    NumPut(TDI_Width, TDC, (x64) ? 156 : 92, "UInt")                ; cxWidth

    DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
        , "Int*", pnButton := 0
        , "Int*", pnRadioButton := 0
        , "Int*", pfVerificationFlagChecked := 0)

    If (TDI_Callback) {
        DllCall("Kernel32.dll\GlobalFree", "Ptr", TDI_Callback)
    }
Return

TDI_Callback(hWnd, Notification, wParam, lParam, RefData) {
    Local CBData := Object(RefData)

    ; TDN_TIMER := 4
    If (Notification == 4 && wParam > CBData.Timeout) {
        ;TDM_CLICK_BUTTON := 0x466, IDCANCEL := 2
        PostMessage 0x466, 2, 0,, ahk_id %hWnd%
    }

    ; TDN_CREATED := 0
    If (Notification == 0 && CBData.AlwaysOnTop) {
        WinSet AlwaysOnTop, On, ahk_id %hWnd%
    }

    If (Notification == 0 && CBData.Marquee) {
        ; TDM_SET_PROGRESS_BAR_MARQUEE := 0x46B
        PostMessage 0x46B, 1, 50,, ahk_id %hWnd%
    }
}

TDI_SetSection:
    Gui MagicBox: Submit, NoHide
    GuiControl,, GrpSection, % LB_GetText(hLbxSection, Section)

    If (PrevSection == 1) {
        GuiControl Hide, TDI_ExpandedText
    } Else If (PrevSection == 2) {
        GuiControl Hide, LblCollapsedControlText
        GuiControl Hide, TDI_CollapsedControlText
        GuiControl Hide, LblExpandedControlText
        GuiControl Hide, TDI_ExpandedControlText
    } Else If (PrevSection == 3) {
        GuiControl Hide, TDI_VerificationText
        GuiControl Hide, TDI_VerificationFlag
    } Else {
        GuiControl Hide, TDI_FooterText
        GuiControl Hide, BtnFooterIcon
    }

    If (Section == 1) {
        GuiControl Show, TDI_ExpandedText
    } Else If (Section == 2) {
        GuiControl Show, LblCollapsedControlText
        GuiControl Show, TDI_CollapsedControlText
        GuiControl Show, LblExpandedControlText
        GuiControl Show, TDI_ExpandedControlText
    } Else If (Section == 3) {
        GuiControl Show, TDI_VerificationText
        GuiControl Show, TDI_VerificationFlag
    } Else {
        GuiControl Show, TDI_FooterText
        GuiControl Show, BtnFooterIcon
    }

    If (Section > 2) {
        GuiControl Hide, TDI_ExpandedByDefault
        GuiControl Hide, TDI_ExpandInFooterArea
    } Else {
        GuiControl Show, TDI_ExpandedByDefault
        GuiControl Show, TDI_ExpandInFooterArea
    }

    PrevSection := Section
Return

; Gets a string from a list box (credits to just_me)
LB_GetText(hWnd, Index) {
    --Index
    SendMessage 0x18A, %Index%, 0,, ahk_id %hWnd% ; LB_GETTEXTLEN
    Len := ErrorLevel
    VarSetCapacity(LB_Text, Len << A_IsUnicode, 0)
    SendMessage 0x189, %Index%, % &LB_Text,, ahk_id %hWnd% ; LB_GETTEXT
    Return StrGet(&LB_Text, Len)
}

TDI_SetCommonButtons:
    If (CustomButtonsDlgCreated) {
        GoSub TDI_UpdateDefaultButtonList
    } Else {
        GoSub TDI_GenerateCode
    }
Return

TDI_ShowCustomButtonsDialog:
    If (CustomButtonsDlgCreated) {
        Gui CustomButtonsDlg: Show
        GoSub TDI_UpdateDefaultButtonList
        Return
    }

    CustomButtonsDlgCreated := True

    Gui CustomButtonsDlg: New, LabelCustomButtonsDlg -MinimizeBox OwnerMagicBox
    Gui Color, 0xFEFEFE

    Gui Add, Button, gTDI_AddItem x180 y207 w80 h23 Default, &Add...
    Gui Add, Button, gTDI_EditItem x180 y238 w80 h23, &Edit...
    Gui Add, Button, gTDI_DeleteItem x180 y268 w80 h23, &Delete
    Gui Add, Button, gTDI_MoveItem x264 y207 w80 h23, &Move Up
    Gui Add, Button, gTDI_MoveItem x264 y238 w80 h23, Mo&ve Down
    Gui Add, Button, gTDI_ClearAll x264 y268 w80 h23, De&lete All

    Gui Add, Text, x11 y347 w335 h2 0x10
    Gui Add, Button, gTDI_SetCustomButtons x94 y360 w80 h23, &OK
    Gui Add, Button, gCancel x180 y360 w80 h23, &Cancel

    Gui Add, Tab2, hWndhTab vTab x11 y13 w332 h329 +0x400 +0x8 Buttons, Buttons|Radio Buttons
    SendMessage 0x1329, 0, 0x0018009E,, ahk_id %hTab% ; TCM_SETITEMSIZE

    Gui Tab, 1 ; Buttons
    Gui Add, ListView, vLVButtons gTDI_LVHandler x11 y46 w332 h150 NoSortHdr -Multi +LV0x4000
    ,   ID|Text|Details
        LV_ModifyCol(1, 32)
        LV_ModifyCol(2, 146)
        LV_ModifyCol(3, 146)
    Gui Add, GroupBox, x11 y210 w162 h73, Command links
    Gui Add, CheckBox, vTDI_CommandLinks gTDI_GenerateCode x24 y228 w132 h23 Checked, &Use command links
    Gui Add, CheckBox, vTDI_CommandLinksNoIcon gTDI_GenerateCode x24 y251 w132 h23, &No icons on buttons
    Gui Add, Text, x11 y312 w76 h23 +0x200, Default &button:
    Gui Add, DropDownList, vTDI_DefaultButtonList x94 y312 w80, First button

    Gui Tab, 2 ; Radio buttons
    Gui Add, ListView, vLVRadioButtons gTDI_LVHandler x11 y46 w332 h150 NoSortHdr -Multi +LV0x4000
    ,   ID|Text
        LV_ModifyCol(1, 40)
        LV_ModifyCol(2, 288)
    Gui Add, Text, x11 y312 w76 h23 +0x200, Default &button:
    Gui Add, DropDownList, vTDI_DefaultRadioList x94 y312 w80, First button||None

    GoSub TDI_UpdateDefaultButtonList

    Gui Show, w355 h396, Task Dialog Custom Buttons
Return

CustomButtonsDlgEscape:
    Gui CustomButtonsDlg: Cancel
Return

TDI_AddItem:
TDI_EditItem:
    Gui CustomButtonsDlg: Submit, NoHide

    Verb := (A_ThisLabel == "TDI_AddItem") ? "Add" : "Edit"

    If (TDI_CommandLinks && Tab == "Buttons") {
        GoSub TDI_%Verb%CommandLink
    } Else {
        GoSub TDI_%Verb%Button
    }
Return

TDI_AddButton:
TDI_EditButton:
    Gui CustomButtonsDlg: Submit, NoHide

    If (A_ThisLabel == "TDI_AddButton") {
        ButtonText := ""

        If (Tab == "Buttons") {
            Title := "New Button"
            Label := "&Button Text:"
        } Else {
            Title := "New Radio Button"
            Label := "&Radio Button Text:"
        }
    } Else { ; Edit
        Label := "&New Text:"

        If (Tab == "Buttons") {
            Title := "Edit Button"
            Gui ListView, LVButtons
        } Else {
            Title := "Edit Radio Button"
            Gui ListView, LVRadioButtons
        }

        If (!Row := LV_GetNext()) {
            Return
        }
        LV_GetText(ButtonText, Row, 2)
    }

    Gui CustomButtonsDlg: +Disabled

    Gui AddButtonDlg: New, LabelTDI_AddButtonDlg -MinimizeBox OwnerCustomButtonsDlg
    Gui Color, 0xFEFEFE
    Gui Add, Text, x18 y14 w120 h23 +0x200, %Label%
    Gui Add, Edit, vButtonText x18 y40 w289 h21, %ButtonText%
    Gui Add, ListView, x-1 y93 w339 h50 Disabled

    If (A_ThisLabel == "TDI_AddButton") {
        Gui Add, Button, gTDI_AddButtonDlgOK x37 y106 w80 h23 Default, &Next
        Gui Add, Button, gTDI_AddButtonDlgOK x122 y106 w80 h23, &OK
        Gui Add, Button, gTDI_AddButtonDlgClose x207 y106 w80 h23, &Cancel
    } Else {
        Gui Add, Button, gTDI_EditButtonDlgOK x80 y106 w80 h23 Default, &OK
        Gui Add, Button, gTDI_AddButtonDlgClose x165 y106 w80 h23, &Cancel
    }

    Gui Show, w325 h142, %Title%
Return

TDI_AddButtonDlgOK:
    If (A_GuiControl == "&Next") {
        Gui AddButtonDlg: Submit, NoHide
        GuiControl,, ButtonText
        GuiControl AddButtonDlg: Focus, ButtonText
    } Else {
        Gui CustomButtonsDlg: -Disabled
        Gui AddButtonDlg: Submit
    }

    If (ButtonText == "") {
        Return
    }

    Gui CustomButtonsDlg: Submit, NoHide
    Gui CustomButtonsDlg: Default
    If (Tab == "Buttons") {
        TDI_ButtonID++
        Gui ListView, LVButtons
        LV_Add("", TDI_ButtonID, ButtonText)
        CustomButtons.Push([TDI_ButtonID, ButtonText])
        GoSub TDI_UpdateDefaultButtonList
    } Else {
        TDI_RadioID++
        Gui ListView, LVRadioButtons
        LV_Add("", TDI_RadioID, ButtonText)
        RadioButtons.Push([TDI_RadioID, ButtonText])
        GoSub TDI_UpdateDefaultRadioList
    }
Return

TDI_EditButtonDlgOK:
    Gui CustomButtonsDlg: -Disabled
    Gui AddButtonDlg: Submit

    Gui CustomButtonsDlg: Submit, NoHide
    Gui CustomButtonsDlg: Default

    If (Tab == "Buttons") {
        Gui ListView, LVButtons
        LV_Modify(Row, "Col2", ButtonText)
        CustomButtons[Row][2] := ButtonText
    } Else {
        Gui ListView, LVRadioButtons
        LV_Modify(Row, "Col2", ButtonText)
        RadioButtons[Row][2] := ButtonText
    }

    GoSub TDI_GenerateCode
Return

TDI_AddButtonDlgEscape:
TDI_AddButtonDlgClose:
    Gui CustomButtonsDlg: -Disabled
    Gui AddButtonDlg: Cancel
Return

TDI_AddCommandLink:
TDI_EditCommandLink:
    If (A_ThisLabel == "TDI_AddCommandLink") {
        Title := "New Command Link Button"
        Label := "&Button Text:"
        CommandLinkText := ""
        CommandLinkNote := ""
    } Else { ; &Edit...
        Title := "Edit Command Link Button"
        Label := "&New Text:"
        Gui ListView, LVButtons
        If (!Row := LV_GetNext()) {
            Return
        }
        LV_GetText(CommandLinkText, Row, 2)
        LV_GetText(CommandLinkNote, Row, 3)
    }

    Gui CustomButtonsDlg: +Disabled

    Gui AddCommandLinkDlg: New, LabelTDI_AddCommandLinkDlg -MinimizeBox OwnerCustomButtonsDlg
    Gui Font, s9, Segoe UI
    Gui Color, 0xFEFEFE
    Gui Add, Text, x18 y14 w289 h23 +0x200, %Label%
    Gui Add, Edit, vCommandLinkText x18 y40 w289 h21, %CommandLinkText%
    Gui Add, Text, x18 y73 w289 h23 +0x200, Additional Information:
    Gui Add, Edit, vCommandLinkNote x18 y97 w289 h36 Multi -VScroll, %CommandLinkNote%
    Gui Add, ListView, x-1 y154 w339 h50 Disabled

    If (A_ThisLabel == "TDI_AddCommandLink") {
        Gui Add, Button, gTDI_AddCommandLinkDlgOK x37 y167 w80 h23 Default, &Next
        Gui Add, Button, gTDI_AddCommandLinkDlgOK x122 y167 w80 h23, &OK
        Gui Add, Button, gTDI_AddCommandLinkDlgClose x207 y167 w80 h23, &Cancel
    } Else {
        Gui Add, Button, gTDI_EditCommandLinkDlgOK x80 y167 w80 h23 Default, &OK
        Gui Add, Button, gTDI_AddCommandLinkDlgClose x165 y167 w80 h23, &Cancel
    }

    Gui Show, w325 h203, %Title%
Return

TDI_AddCommandLinkDlgOK:
    If (A_GuiControl == "&Next") {
        Gui AddCommandLinkDlg: Submit, NoHide
        GuiControl,, CommandLinkText
        GuiControl,, CommandLinkNote
        GuiControl AddCommandLinkDlg: Focus, CommandLinkText
    } Else {
        Gui CustomButtonsDlg: -Disabled
        Gui AddCommandLinkDlg: Submit
    }

    If (CommandLinkText == "") {
        Return
    }

    TDI_ButtonID++

    Gui CustomButtonsDlg: Default
    Gui ListView, LVButtons
    LV_Add("", TDI_ButtonID, CommandLinkText, CommandLinkNote)

    If (CommandLinkNote != "") {
        CommandLinkText .= "`n" . CommandLinkNote
    }

    CustomButtons.Push([TDI_ButtonID, CommandLinkText])

    GoSub TDI_UpdateDefaultButtonList
Return

TDI_EditCommandLinkDlgOK:
    Gui CustomButtonsDlg: -Disabled
    Gui AddCommandLinkDlg: Submit

    Gui CustomButtonsDlg: Default
    Gui ListView, LVButtons
    LV_Modify(Row, "Col2", CommandLinkText)
    LV_Modify(Row, "Col3", CommandLinkNote)

    If (CommandLinkNote != "") {
        CommandLinkText .= "`n" . CommandLinkNote
    }

    CustomButtons[Row][2] := CommandLinkText

    GoSub TDI_GenerateCode
Return

TDI_AddCommandLinkDlgEscape:
TDI_AddCommandLinkDlgClose:
    Gui CustomButtonsDlg: -Disabled
    Gui AddCommandLinkDlg: Cancel
Return

TDI_SetCustomButtons:
    Gui CustomButtonsDlg: Submit
    GoSub TDI_GenerateCode
Return

TDI_DeleteItem:
    Gui CustomButtonsDlg: Submit, NoHide

    If (Tab == "Buttons") {
        Gui ListView, LVButtons
        Row := LV_GetNext()
        LV_Delete(Row)
        CustomButtons.RemoveAt(Row)

        Loop % CustomButtons.Length() {
            r := A_Index + Row - 1
            NewID := r + 100
            CustomButtons[r][1] := NewID
            LV_Modify(r, "", NewID)
        }

        TDI_ButtonID--

        GoSub TDI_UpdateDefaultButtonList
    } Else {
        Gui ListView, LVRadioButtons
        Row := LV_GetNext()
        LV_Delete(Row)
        RadioButtons.RemoveAt(Row)

        Loop % RadioButtons.Length() {
            r := A_Index + Row - 1
            NewID := r + 200
            RadioButtons[r][1] := NewID
            LV_Modify(r, "", NewID)
        }

        TDI_RadioID--

        GoSub TDI_UpdateDefaultRadioList
    }
Return

TDI_ClearAll:
    Gui CustomButtonsDlg: Submit, NoHide

    If (Tab == "Buttons") {
        TDI_ButtonID := 100
        CustomButtons := []
        Gui ListView, LVButtons
        GoSub TDI_UpdateDefaultButtonList
    } Else {
        TDI_RadioID := 200
        RadioButtons := []
        Gui ListView, LVRadioButtons
        GoSub TDI_UpdateDefaultRadioList
    }

    LV_Delete()
Return

TDI_MoveItem:
    Gui CustomButtonsDlg: Submit, NoHide

    LV := (Tab == "Buttons") ? "LVButtons" : "LVRadioButtons"
    Gui ListView, % LV
    Row := LV_GetNext()

    If (A_GuiControl == "&Move Up") {
        If (Row == 1) {
            Return
        }

        NewRow := Row - 1
    } Else {
        If (Row == LV_GetCount()) {
            Return
        }

        NewRow := Row + 1
    }

    If (Tab == "Buttons") {
        LV_GetText(ButtonText, Row, 2)
        LV_GetText(ButtonDetails, Row, 3)

        LV_GetText(TempButtonText, NewRow, 2)
        LV_GetText(TempButtonDetails, NewRow, 3)

        LV_Modify(NewRow, "Col2", ButtonText)
        LV_Modify(NewRow, "Col3", ButtonDetails)

        LV_Modify(Row, "Col2", TempButtonText)
        LV_Modify(Row, "Col3", TempButtonDetails)

        ButtonText := CustomButtons[NewRow][2]
        CustomButtons[NewRow][2] := CustomButtons[Row][2]
        CustomButtons[Row][2] := ButtonText
    } Else { ; Radio Buttons
        LV_GetText(RadioText, Row, 2)
        LV_GetText(TempRadioText, NewRow, 2)

        LV_Modify(NewRow, "Col2", RadioText)
        LV_Modify(Row, "Col2", TempRadioText)

        RadioText := RadioButtons[NewRow][2]
        RadioButtons[NewRow][2] := RadioButtons[Row][2]
        RadioButtons[Row][2] := RadioText
    }

    GuiControl CustomButtonsDlg: Focus, %LV%
    LV_Modify(NewRow, "Select")

    GoSub TDI_GenerateCode
Return

TDI_UpdateDefaultButtonList:
    If (!CustomButtonsDlgCreated) {
        Return
    }

    Gui MagicBox: Submit, NoHide

    ButtonsPDL := ""

    If (TDI_OK) {
        ButtonsPDL .= "OK|"
    }

    If (TDI_Yes) {
        ButtonsPDL .= "Yes|"
    }

    If (TDI_No) {
        ButtonsPDL .= "No|"
    }

    If (TDI_Retry) {
        ButtonsPDL .= "Retry|"
    }

    If (TDI_Cancel) {
        ButtonsPDL .= "Cancel|"
    }

    If (TDI_Close) {
        ButtonsPDL .= "Close|"
    }

    Loop % CustomButtons.Length() {
        ButtonsPDL .= CustomButtons[A_Index][1] . "|"
    }

    GuiControlGet SelectedItem, CustomButtonsDlg:, TDI_DefaultButtonList
    GuiControl, CustomButtonsDlg:, TDI_DefaultButtonList, % "|First button||" . ButtonsPDL
    GuiControl, CustomButtonsDlg: ChooseString, TDI_DefaultButtonList, %SelectedItem%

    GoSub TDI_GenerateCode
Return

TDI_UpdateDefaultRadioList:
    Gui MagicBox: Submit, NoHide

    RadioPDL := ""

    Loop % RadioButtons.Length() {
        RadioPDL .= RadioButtons[A_Index][1] . "|"
    }

    GuiControlGet SelectedItem, CustomButtonsDlg:, TDI_DefaultRadioList
    GuiControl, CustomButtonsDlg:, TDI_DefaultRadioList, % "|First button||" . RadioPDL . "None"
    GuiControl, CustomButtonsDlg: ChooseString, TDI_DefaultRadioList, %SelectedItem%

    GoSub TDI_GenerateCode
Return

TDI_LVHandler:
    Gui CustomButtonsDlg: Submit, NoHide
    Gui ListView, % (Tab == "Buttons") ? "LVButtons" : "LVRadioButtons"
    If (LV_GetNext()) {
        GoSub TDI_EditItem
    } Else {
        GoSub TDI_AddItem
    }
Return

ShowFooterIconMenu:
    ControlGetPos px, py, pw, ph,, ahk_id %hFooterIconBtn%

    Menu FooterIconMenu, Add, No Icon, SetFooterIcon
    Menu FooterIconMenu, Add
    Menu FooterIconMenu, Add, Information, SetFooterIcon
    Menu FooterIconMenu, Icon, Information, user32.dll, 5
    Menu FooterIconMenu, Add, Warning, SetFooterIcon
    Menu FooterIconMenu, Icon, Warning, user32.dll, 2
    Menu FooterIconMenu, Add, UAC shield, SetFooterIcon
    Menu FooterIconMenu, Icon, UAC Shield, user32.dll, 7
    Menu FooterIconMenu, Add, Error, SetFooterIcon
    Menu FooterIconMenu, Icon, Error, user32.dll, 4
    If (Shields) {
        Menu FooterIconMenu, Add
        Menu FooterIconMenu, Add, OK shield, SetFooterIcon
        Menu FooterIconMenu, Icon, OK shield, imageres.dll, 102
        Menu FooterIconMenu, Add, Error shield, SetFooterIcon
        Menu FooterIconMenu, Icon, Error shield, imageres.dll, 101
        Menu FooterIconMenu, Add, Warning shield, SetFooterIcon
        Menu FooterIconMenu, Icon, Warning shield, imageres.dll, 103
    }
    Menu FooterIconMenu, Add
    Menu FooterIconMenu, Add, Choose..., SelectFooterIcon

    Menu FooterIconMenu, Show, %px%, % (py + ph)
    Menu FooterIconMenu, DeleteAll
Return

SetFooterIcon:
    TDI_CustomFooterIcon := False
    Resource := "user32.dll"

    If (A_ThisMenuItem == "Information") {
        TDI_FooterIcon := 0xFFFD
        Index := 5
    } Else If (A_ThisMenuItem == "Warning") {
        TDI_FooterIcon := 0xFFFF
        Index := 2
    } Else If (A_ThisMenuItem == "UAC shield") {
        TDI_FooterIcon := 0xFFFC
        Index := 7
    } Else If (A_ThisMenuItem == "Error") {
        TDI_FooterIcon := 0xFFFE
        Index := 4
    } Else If (A_ThisMenuItem == "OK shield") {
        TDI_FooterIcon := 0xFFF8
        Resource := "imageres.dll"
        Index := 102
    } Else If (A_ThisMenuItem == "Error shield") {
        TDI_FooterIcon := 0xFFF9
        Resource := "imageres.dll"
        Index := 101
    } Else If (A_ThisMenuItem == "Warning shield") {
        TDI_FooterIcon := 0xFFFA
        Resource := "imageres.dll"
        Index := 103
    } Else { ; No Icon
        TDI_FooterIcon := 0
        Resource := ""
        Index := 0
    }

    GuiButtonIcon(hFooterIconBtn, Resource, Index, "L1 T1 A0")
    GoSub TDI_GenerateCode
Return

SelectFooterIcon:
    If (ChooseIcon(TDI_FooterIconRes, TDI_FooterIconIdx, WinExist("A"))) {
        VarSetCapacity(Output, 260)
        DllCall("ExpandEnvironmentStrings", "Str", TDI_FooterIconRes, "Str", Output, "UInt", 260)
        TDI_FooterIconRes := RegExReplace(Output, "i)\Q" . A_WinDir . "\Sys\E(tem32|WOW64)\\")
        TDI_CustomFooterIcon := True
        TDI_FooterIcon := ResourceIdOfIcon(TDI_FooterIconRes, TDI_FooterIconIdx - 1)
        GuiButtonIcon(hFooterIconBtn, TDI_FooterIconRes, TDI_FooterIconIdx, "L1 T1 A0")
        GoSub TDI_GenerateCode
    }
Return

TDI_SetVariables:
    Gui MagicBox: Submit, NoHide

    SetFormat Integer, Hex

    TDI_Flags := 0

    If (HasLinks()) {
        TDI_Flags |= 0x1 ; TDF_ENABLE_HYPERLINKS
        TDI_HyperLink := True ; Generate code for TDN_HYPERLINK_CLICKED
    } Else {
        TDI_HyperLink := False
    }

    If (TDI_AllowCancellation) {
        TDI_Flags |= 0x8
    }

    If (TDI_ProgressBar) {
        TDI_Flags |= 0x200
    }

    If (TDI_Marquee) {
        TDI_Flags |= 0x400
    }

    If (TDI_RelativePosition) {
        TDI_Flags |= 0x1000
    }

    If (TDI_RTLReading) {
        TDI_Flags |= 0x2000
    }

    If (TDI_CanBeMinimized) {
        TDI_Flags |= 0x8000
    }

    If (TDI_ExpandedByDefault) {
        TDI_Flags |= 0x80
    }

    If (TDI_ExpandInFooterArea) {
        TDI_Flags |= 0x40
    }

    If (TDI_VerificationFlag) {
        TDI_Flags |= 0x100
    }

    If (TDI_TimeoutEnabled) {
        TDI_Flags |= 0x800 ; TDF_CALLBACK_TIMER
        SetFormat Integer, D
        TDI_TimeOut := Round(TDI_Timeout * 1000)
        SetFormat Integer, H
    }

    If (TDI_CustomMainIcon && !InStr(TDI_MainIconRes, "imageres.dll")) {
        TDI_Flags |= 0x2 ; TDF_USE_HICON_MAIN
    }

    If (TDI_CustomFooterIcon && !InStr(TDI_FooterIconRes, "imageres.dll")) {
        TDI_Flags |= 0x4 ; TDF_USE_HICON_FOOTER
    }

    TDI_Buttons := 0

    If (TDI_OK) {
        TDI_Buttons |= 0x1
    }

    If (TDI_Cancel) {
        TDI_Buttons |= 0x8
    }

    If (TDI_Yes) {
        TDI_Buttons |= 0x2
    }

    If (TDI_No) {
        TDI_Buttons |= 0x4
    }

    If (TDI_Retry) {
        TDI_Buttons |= 0x10
    }

    If (TDI_Close) {
        TDI_Buttons |= 0x20
    }

    If (CustomButtonsDlgCreated) {
        Gui CustomButtonsDlg: Submit, NoHide

        If (CustomButtons.Length()) {
            If (TDI_CommandLinksNoIcon) {
                TDI_Flags |= 0x20
            } Else If (TDI_CommandLinks) {
                TDI_Flags |= 0x10
            }
        }

        SetFormat Integer, D

        If (TDI_DefaultButtonList != "First button") {
            If (TDI_DefaultButtonList + 0) {
                TDI_DefaultButton := TDI_DefaultButtonList
            } Else {
                TDI_DefaultButton := TDI_ButtonIDs[TDI_DefaultButtonList]
            }
        } Else {
            TDI_DefaultButton := 0
        }

        TDI_DefaultRadio := 0
        If (TDI_DefaultRadioList == "None") {
            TDI_Flags |= 0x4000
        } Else If (TDI_DefaultRadioList != "First button") {
            TDI_DefaultRadio := TDI_DefaultRadioList
        }
    }

    If (!TDI_CustomMainIcon) {
        SetFormat Integer, H
        If (Icon == 0) {
            TDI_MainIcon := (Shields) ? 0xFFF9 : 0
        } Else If (Icon == 0x10) {
            TDI_MainIcon := (Shields) ? 0xFFF7 : 0xFFFE ; TD_ERROR_ICON
        } Else If (Icon == 0x20) {
            TDI_MainIcon := (Shields) ? 0xFFFB : 0xFFFC ; TD_SHIELD_ICON
        } Else If (Icon == 0x30) {
            TDI_MainIcon := (Shields) ? 0xFFFA : 0xFFFF ; TD_WARNING_ICON
        } Else If (Icon == 0x40) {
            TDI_MainIcon := (Shields) ? 0xFFF8 : 0xFFFD ; TD_INFORMATION_ICON
        } Else {
            TDI_MainIcon := 0
        }
    } Else {
        SetFormat Integer, D
        TDI_MainIcon := ResId
    }
Return

TDI_GenerateCode:
    GoSub TDI_SetVariables

    Code := ""

    If (TDI_Instruction != "") {
        Code .= "Instruction := """ . EscapeChars(TDI_Instruction) . """`n"
    }

    If (TDI_Content != "") {
        Code .= "Content := """ . EscapeChars(TDI_Content) . """`n"
    }

    If (Title != "") {
        Code .= "Title := """ . EscapeChars(Title) . """`n"
    }

    If (TDI_MainIcon != 0) {
        If (TDI_CustomMainIcon && !InStr(TDI_MainIconRes, "imageres.dll")) {
            Code .= "MainIcon := LoadPicture(""" . TDI_MainIconRes . """, ""w32 Icon"
            Code .= TDI_MainIconIdx . """, ImageType)`n"
        } Else {
            Code .= "MainIcon := " . TDI_MainIcon . "`n"
        }
    }

    If (TDI_Flags) {
        Code .= "Flags := " . TDI_Flags . "`n"
    }

    If (TDI_Buttons) {
        Code .= "Buttons := " . TDI_Buttons . "`n"
    }

    SetFormat Integer, D

    cButtons := CustomButtons.Length()
    If (cButtons) {
        Code .= "CustomButtons := []`n"
        Loop %cButtons% {
            Code .= "CustomButtons.Push([" . CustomButtons[A_Index][1]
                 .  ", """ . EscapeChars(CustomButtons[A_Index][2]) . """])`n"
        }

        Code .= "cButtons := CustomButtons.Length()`n"
             .  "VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)`n"
             .  "Loop %cButtons% {`n"
             .  "    iButtonID := CustomButtons[A_Index][1]`n"
             .  "    iButtonText := &(b%A_Index% := CustomButtons[A_Index][2])`n"
             .  "    NumPut(iButtonID,   pButtons, (4 + A_PtrSize) * (A_Index - 1), ""Int"")`n"
             .  "    NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, ""Ptr"")`n"
             .  "}`n"
    }

    If (TDI_DefaultButton != 0) {
        Code .= "DefaultButton := " . TDI_DefaultButton . "`n"
    }

    cRadioButtons := RadioButtons.Length()
    If (cRadioButtons) {
        Code .= "RadioButtons := []`n"
        Loop %cRadioButtons% {
            Code .= "RadioButtons.Push([" . RadioButtons[A_Index][1]
                 .  ", """ . EscapeChars(RadioButtons[A_Index][2]) . """])`n"
        }

        Code .= "cRadioButtons := RadioButtons.Length()`n"
             .  "VarSetCapacity(pRadioButtons, 4 * cRadioButtons + A_PtrSize * cRadioButtons, 0)`n"
             .  "Loop %cRadioButtons% {`n"
             .  "    iButtonID := RadioButtons[A_Index][1]`n"
             .  "    iButtonText := &(r%A_Index% := RadioButtons[A_Index][2])`n"
             .  "    NumPut(iButtonID,   pRadioButtons, (4 + A_PtrSize) * (A_Index - 1), ""Int"")`n"
             .  "    NumPut(iButtonText, pRadioButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, ""Ptr"")`n"
             .  "}`n"
    }

    If (TDI_DefaultRadio != 0) {
        Code .= "DefaultRadio := " . TDI_DefaultRadio . "`n"
    }

    If (TDI_ExpandedText != "") {
        Code .= "ExpandedText := """ . EscapeChars(TDI_ExpandedText) . """`n"
    }

    If (TDI_CollapsedControlText != "") {
        Code .= "CollapsedControlText := """ . EscapeChars(TDI_CollapsedControlText) . """`n"
    }

    If (TDI_ExpandedControlText != "") {
        Code .= "ExpandedControlText := """ . EscapeChars(TDI_ExpandedControlText) . """`n"
    }

    If (TDI_VerificationText != "") {
        Code .= "CheckText := """ . EscapeChars(TDI_VerificationText) . """`n"
    }

    If (TDI_FooterIcon != 0 && TDI_FooterText != "") {
        If (TDI_CustomFooterIcon && !InStr(TDI_FooterIconRes, "imageres.dll")) {
            Code .= "FooterIcon := LoadPicture(""" . TDI_FooterIconRes . """, ""w16 Icon"
            Code .= TDI_FooterIconIdx . """, ImageType)`n"
        } Else {
            Code .= "FooterIcon := " . TDI_FooterIcon . "`n"
        }
    }

    If (TDI_FooterText != "") {
        Code .= "FooterText := """ . EscapeChars(TDI_FooterText) . """`n"
    }

    If (TDI_RelativePosition) {
        Code .= "Parent := WinExist(""A"")`n"
    } Else If (TDI_Cancel) {
        Code .= "Parent := DllCall(""GetDesktopWindow"", ""Ptr"")`n"
    }

    IF (TDI_Width) {
        Code .= "Width := " . TDI_Width . "`n"
    }

    TDI_CBData := (TDI_AlwaysOnTop || TDI_TimeoutEnabled || TDI_Marquee)

    If (TDI_CBData || TDI_HyperLink) {
        Code .= "TDCallback := RegisterCallback(""TDCallback"", ""Fast"")`n"
        If (TDI_CBData) {
            Code .= "CBData := {}`n"
        }

        If (TDI_AlwaysOnTop) {
            Code .= "CBData.AlwaysOnTop := True`n"
        }

        If (TDI_Marquee) {
            Code .= "CBData.Marquee := True`n"
        }

        If (TDI_TimeoutEnabled) {
            Code .= "CBData.Timeout := " . TDI_Timeout . " `; ms`n"
        }

        Callback := True
    } Else {
        Callback := False
    }

    Code .= 
    (LTrim
        "`n`; TASKDIALOGCONFIG structure
        x64 := A_PtrSize == 8
        NumPut(VarSetCapacity(TDC, x64 ? 160 : 96, 0), TDC, 0, ""UInt"") `; cbSize`n"
    )

    If (TDI_RelativePosition || TDI_Cancel) {
        Code .= "NumPut(Parent, TDC, 4, ""Ptr"") `; hwndParent`n"
    }

    If (TDI_Flags) {
        Code .= "NumPut(Flags, TDC, x64 ? 20 : 12, ""Int"") `; dwFlags`n"
    }

    If (TDI_Buttons) {
        Code .= "NumPut(Buttons, TDC, x64 ? 24 : 16, ""Int"") `; dwCommonButtons`n"
    }

    If (Title != "") {
        Code .= "NumPut(&Title, TDC, x64 ? 28 : 20, ""Ptr"") `; pszWindowTitle`n"
    }

    If (TDI_MainIcon != 0) {
        Code .= "NumPut(MainIcon, TDC, x64 ? 36 : 24, ""Ptr"") `; pszMainIcon`n"
    }

    If (TDI_Instruction != "") {
        Code .= "NumPut(&Instruction, TDC, x64 ? 44 : 28, ""Ptr"") `; pszMainInstruction`n"
    }

    If (TDI_Content != "") {
        Code .= "NumPut(&Content, TDC, x64 ? 52 : 32, ""Ptr"") `; pszContent`n"
    }

    If (cButtons) {
        Code .= "NumPut(cButtons, TDC, x64 ? 60 : 36, ""UInt"") `; cButtons`n"
        Code .= "NumPut(&pButtons, TDC, x64 ? 64 : 40, ""Ptr"") `; pButtons`n"
    }

    If (TDI_DefaultButton != 0) {
        Code .= "NumPut(DefaultButton, TDC, x64 ? 72 : 44, ""Int"") `; nDefaultButton`n"
    }

    If (cRadioButtons) {
        Code .= "NumPut(cRadioButtons, TDC, x64 ? 76 : 48, ""UInt"") `; cRadioButtons`n"
        Code .= "NumPut(&pRadioButtons, TDC, x64 ? 80 : 52, ""Ptr"") `; pRadioButtons`n"

        If (TDI_DefaultRadio != 0) {
            Code .= "NumPut(DefaultRadio, TDC, x64 ? 88 : 56, ""Int"") `; nDefaultRadioButton`n"
        }
    }

    If (TDI_VerificationText != "") {
        Code .= "NumPut(&CheckText, TDC, x64 ? 92 : 60, ""Ptr"") `; pszVerificationText`n"
    }

    If (TDI_ExpandedText != "") {
        Code .= "NumPut(&ExpandedText, TDC, x64 ? 100 : 64, ""Ptr"") `; pszExpandedInformation`n"
    }

    If (TDI_ExpandedControlText != "") {
        Code .= "NumPut(&ExpandedControlText, TDC, x64 ? 108 : 68, ""Ptr"") `; pszExpandedControlText`n"
    }

    If (TDI_CollapsedControlText != "") {
        Code .= "NumPut(&CollapsedControlText, TDC, x64 ? 116 : 72, ""Ptr"") `; pszCollapsedControlText`n"
    }

    If (TDI_FooterIcon != 0 && TDI_FooterText != "") {
        Code .= "NumPut(FooterIcon, TDC, x64 ? 124 : 76, ""Ptr"") `; pszFooterIcon`n"
    }

    If (TDI_FooterText != "") {
        Code .= "NumPut(&FooterText, TDC, x64 ? 132 : 80, ""Ptr"") `; pszFooter`n"
    }

    If (Callback) {
        Code .= "NumPut(TDCallback, TDC, x64 ? 140 : 84, ""Ptr"") `; pfCallback`n"
        If (TDI_CBData) {
            Code .= "NumPut(&CBData, TDC, x64 ? 148 : 88, ""Ptr"") `; lpCallbackData`n"
        }
    }

    If (TDI_Width) {
        Code .= "NumPut(Width, TDC, x64 ? 156 : 92, ""UInt"") `; cxWidth`n"
    }

    If (Callback) {
        Code .= "`nTDCallback(hWnd, Notification, wParam, lParam, RefData) {`n"
        If (TDI_CBData) {
            Code .= "    Local CBData := Object(RefData)`n"
        }

        If (TDI_TimeoutEnabled) {
            Code .= "`n    If (Notification == 4 && wParam > CBData.Timeout) {`n"
            Code .= "        `; TDM_CLICK_BUTTON := 0x466, IDCANCEL := 2`n"
            Code .= "        PostMessage 0x466, 2, 0,, ahk_id %hWnd%`n    }`n"
        }

        If (TDI_AlwaysOnTop) {
            Code .= "`n    If (Notification == 0 && CBData.AlwaysOnTop) {`n"
            Code .= "        DHW := A_DetectHiddenWindows`n"
            Code .= "        DetectHiddenWindows On`n"
            Code .= "        WinSet AlwaysOnTop, On, ahk_id %hWnd%`n"
            Code .= "        DetectHiddenWindows %DHW%`n    }`n"
        }

        If (TDI_Marquee) {
            Code .= "`n    If (Notification == 0 && CBData.Marquee) {`n"
            Code .= "        `; TDM_SET_PROGRESS_BAR_MARQUEE`n"
            Code .= "        DllCall(""PostMessage"", ""Ptr"", hWnd, ""UInt"", 0x46B, ""UInt"", 1, ""UInt"", 50)"
            Code .= "`n    }`n"
        }

        If (TDI_HyperLink) {
            If (TDI_CBData) {
                Code .= "`n"
            }

            Code .= "    If (Notification == 3) {`n"
            Code .= "        URL := StrGet(lParam, ""UTF-16"") `; <A HREF=""URL"">Link</A>`n    }`n"
        }

        Code .= "}`n"
    }

    Code .= "`nDllCall(""Comctl32.dll\TaskDialogIndirect"", ""Ptr"", &TDC`n"
         .  "    , ""Int*"", Button := 0`n"
         .  "    , ""Int*"", Radio := 0`n"
         .  "    , ""Int*"", Checked := 0)`n"

    If (Callback) {
        Code .= "`nDllCall(""Kernel32.dll\GlobalFree"", ""Ptr"", TDCallback)`n"
    }

    Gui CodeView: Submit, NoHide
    If (IfBlocks) {
        GoSub TDI_GenerateIfBlocks
    }

    GuiControl, CodeView:, EdtCode, %Code%
Return

HasLinks() {
    Global
    RegEx := "\<\/a|A\>"
    Return (RegExMatch(TDI_Content, RegEx)
        || RegExMatch(TDI_ExpandedText, RegEx)
        || RegExMatch(TDI_FooterText, RegEx))
}

TDI_GenerateIfBlocks:
    If (cRadioButtons) {
        Code .= "`n"

        Loop %cRadioButtons% {
            If (A_Index > 1) {
                Code .= " Else "
            }

            Code .= "If (Radio == " . RadioButtons[A_Index][1]
            Code .= ") {`n    `; " . RadioButtons[A_Index][2] . "`n`n}"
        }

        Code .= "`n"
    }

    If (cButtons) {
        Code .= "`n"

        Loop %cButtons% {
            If (A_Index > 1) {
                Code .= " Else "
            }

            Code .= "If (Button == " . CustomButtons[A_Index][1]
            Code .= ") {`n    `; " . StrSplit(CustomButtons[A_Index][2], "`n")[1] . "`n`n}"
        }
    }

    If (TDI_Buttons || TDI_TimeoutEnabled) {
        Code .= (cButtons) ? " Else " : "`n"

        Loop 6 {
            If (TDI_Buttons & (2 ** (A_Index - 1))) {
                Code .= "If (Button == " . TDI_CommonButtons[A_Index][1]
                Code .= ") {`n    `; " . TDI_CommonButtons[A_Index][2] . "`n`n} Else "
            }
        }

        If (TDI_TimeoutEnabled) {
            If (TDI_Buttons & 0x8) {
                Code := StrReplace(Code, "`; Cancel", "`; Cancel or timeout")
            } Else {
                Code .= "If (Button == 2) {`n    `; Timeout`n`n}"
            }
        }

        Code := RTrim(Code, " Else ") . "`n"
    } Else {
        Code .= "`n"
    }

    If (TDI_VerificationText != "") {
        Code .= "`nIf (Checked) {`n`n}`n"
    }

Return

/*
LoadButtonText(ID) {
    Static hModule := DllCall("GetModuleHandle", "Str", "user32.dll")
    Static DefaultValues := {800: "OK", 801: "Cancel", 802: "Abort", 803: "Retry", 804: "Ignore", 805: "Yes", 806: "No", 807: "Close", 808: "Help", 809: "Try Again", 810: "Continue"}

    VarSetCapacity(Buffer, 42)
    If (DllCall("LoadString", "Ptr", hModule, "UInt", ID, "Str", Buffer, "UInt", 42)) {
        String := StrGet(&Buffer, 42)
    } Else {
        String := DefaultValues[ID]
    }

    Return String
}
*/

MB_GetString(ID) {
    Return StrGet(DllCall("MB_GetString", "UInt", ID - 1))
}

MBI_CloseMsgBox:
    SetTimer MBI_CloseMsgBox, Off
    WinClose %Title% ahk_class #32770
Return

; CloudBox
ShowAbout() {
    Static Counter
    Static Colors := ["BAE5F2", "BEE6F2", "C3E8F3", "C7EAF4", "CCEBF5", "D1EDF6", "D5EFF7", "DAF1F8", "DEF2F8", "E3F4F9", "E4F4F9", "E6F5F9", "E8F6FA", "EAF6FA", "ECF7FB", "EEF8FB", "F0F9FB", "F1F9FC", "F3FAFC", "F5FBFD", "F7FCFD", "F9FCFD", "FBFDFE", "FBFDFE", "FBFDFE", "FBFDFE", "FBFDFE", "FBFDFE", "FBFDFE", "FBFDFE", "FDFEFE", "FDFEFE", "FDFEFE", "FFFFFF"]

    Static URL := "https://sourceforge.net/projects/magicbox-factory/"
    Local AboutText := 
    (LTrim
    "Developers and corporations all over the world use MagicBox
    to quickly and efficiently create professional message boxes.

    MagicBox is able to generate code for a variety of message boxes,
    including the sophisticated task dialog introduced in Windows Vista.

    Version " . Version . "

    SourceForge project page:
    "
    )

    Gui MagicBox: +Disabled
    Gui About: New, LabelAbout -MinimizeBox -SysMenu OwnerMagicBox
    Gui Color, 0xFEFEFE

    Loop % Colors.Length() {
        Gui Add, TreeView, % "x-1 y" . (A_Index - 1) . " w437 h1 Background" . Colors[A_Index]
    }

    Gui Add, Picture, x11 y12 w32 h32 BackgroundTrans, %A_ScriptDir%\..\..\Icons\MagicBox.ico
    Gui Font, s13 c0x003399, Tahoma
    Gui Add, Text, x51 y12 w354 h32 +0x200 BackgroundTrans, %AppName%
    Gui Font
    Gui Font,, Tahoma
    Gui Add, Text, x51 y52 w354, %AboutText%
    Gui Font
    Gui Add, Link, x51 y172 w354 h23, <a href="%URL%">%URL%</a>

    Counter := Colors.Length()
    Loop %Counter% {
        Gui Add, TreeView, % "x-1 y" . (210 + A_Index) . " w437 h1 Disabled Background" . Colors[Counter]
        Counter--
    }

    Gui Font, s9, Segoe UI
    Gui Add, Button, gAboutEscape x347 y209 w75 h23 Default, &Close
    Gui Show, w435 h245, About
    ControlFocus Button1, About
}

AboutEscape:
    Gui MagicBox: -Disabled
    Gui About: Destroy
Return

; SHMessageBoxCheck returned the default value
SHMsgBoxChkDefault() {
    Static Message := "The option to suppress a further occurrence of the message box was previously chosen.`n`nTo show it again, define a new unique ID or delete the registry key."
    Static Buttons := [[1, "&Delete Key"], [3, "&Jump to Key"], [2, "&Cancel"]]

    Result := SoftModalMessageBox(Message, AppName, Buttons, 1, 0x81, "regedit.exe", 100, -1, hWindow)

    If (Result == 1) {
        GoSub DeleteKey
    } Else If (Result == 3) {
        GoSub RegJump
    }
}

DeleteKey:
    If (RegVal == "") {
        RegVal := A_ScriptFullPath
    }
    RegDelete HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\DontShowMeThisDialogAgain, %RegVal%
    GoSub Test
Return

RegJump:
    RegKey := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\DontShowMeThisDialogAgain"
    RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %RegKey%
    Run regedit ; -m
Return

; Enable/disable system menu items
OnWM_ENTERMENULOOP(wParam, lParam, msg, hWnd) {
    Disable := MsgBoxType ~= "^(Task|Msi|Magic)"
    DllCall("EnableMenuItem", "Ptr", hSysMenu, "UPtr", 0xDEAD, "UInt", Disable)
    Disable := MsgBoxType ~= "^(Magic|Soft|TaskDialogIndirect)"
    DllCall("EnableMenuItem", "Ptr", hSysMenu, "UPtr", 0xC0DE, "UInt", Disable)
}

; System menu handler
OnWM_COMMAND(wParam, lParam, msg, hWnd) {
    Global
    If (wParam == 0xDEAD) {
        GoSub ShowMoreOptions
    } Else If (wParam == 0xC0DE) {
        English := SwitchButtonText(!English)
    }
}

; This window provides access to old, unusual or obsolete options
ShowMoreOptions:
    Gui MagicBox: Submit, NoHide
    If (MsgBoxType ~= "TaskDialog|TaskDialogIndirect|MsiMessageBox") {
        MsgBox 0x2030, %AppName%, Options not applicable to %MsgBoxType%.
        Return
    }

    Gui MagicBox: +Disabled

    If (MoreOptionsDlgCreated) {
        Gui MoreOptionsDlg: Show
        Return
    }

    Gui MoreOptionsDlg: New, LabelMoreOptionsDlg -MinimizeBox -Theme OwnerMagicBox
    Gui Font,, FixedSys
    Gui Color, 0xFBFBFB
    Gui Add, CheckBox, x0 y0 w0 h0
    Gui Add, CheckBox, vSystemModal x23 y18 w220 h24, MB_SYSTEMMODAL
    Gui Add, CheckBox, vNoFocus x23 y43 w220 h24, MB_NOFOCUS
    Gui Add, CheckBox, vSetForeground x23 y68 w220 h24, MB_SETFOREGROUND
    Gui Add, CheckBox, vDefaultDesktopOnly x23 y93 w220 h24, MB_DEFAULT_DESKTOP_ONLY
    Gui Add, CheckBox, vServiceNotification x23 y118 w220 h24, MB_SERVICE_NOTIFICATION
    Gui Add, CheckBox, vRight x23 y143 w220 h24, MB_RIGHT
    Gui Add, CheckBox, vDefButton4 x23 y168 w220 h24, MB_DEFBUTTON4
    Gui Add, ListView, x-1 y206 w276 h80 0x10 Disabled -E0x200
    Gui Add, Button, gSetMoreOptions x54 y221 w75 h23 Default, &OK
    Gui Add, Button, gMoreOptionsDlgClose x135 y221 w75 h23, &Cancel
    Gui Show, w265 h259, More Options

    MoreOptionsDlgCreated := True
Return

MoreOptionsDlgEscape:
MoreOptionsDlgClose:
    Gui MagicBox: -Disabled
    Gui MoreOptionsDlg: Cancel
Return

SetMoreOptions:
    Gui MagicBox: -Disabled
    Gui MoreOptionsDlg: Submit
    Gui MagicBox: Default

    If (SystemModal) {
        GuiControl,, TaskModal, 0
        GuiControl,, AlwaysOnTop, 0
    }

    If (DefaultDesktopOnly || ServiceNotification) {
        GuiControl,, NoOwner, 1
        GuiControl,, HelpBtn, 0
    }

    If (DefButton4) {
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
    }

    GoSub SetVariables
Return

SwitchButtonText(Eng) {
    Global

    Gui MagicBox: Submit, NoHide
    If (MsgBoxType == "MsiMessageBox") {
        Abort := (Eng) ? "Cancel" : StrCancel
    } Else {
        Abort := (Eng) ? "Abort" : StrAbort
    }

    Gui MagicBox: Default
    GuiControl,, OK_OK, % (Eng) ? "OK" : StrOK
    GuiControl,, OK_OKCancel, % (Eng) ? "OK" : StrOK
    GuiControl,, Cancel_OKCancel, % (Eng) ? "Cancel" : StrCancel
    GuiControl,, Yes_YesNo, % (Eng) ? "Yes" : StrYes
    GuiControl,, No_YesNo, % (Eng) ? "No" : StrNo
    GuiControl,, Yes_YesNoCancel, % (Eng) ? "Yes" : StrYes
    GuiControl,, No_YesNoCancel, % (Eng) ? "No" : StrNo
    GuiControl,, Cancel_YesNoCancel, % (Eng) ? "Cancel" : StrCancel
    GuiControl,, Abort_AbortRetryIgnore, %Abort%
    GuiControl,, Retry_AbortRetryIgnore, % (Eng) ? "Retry" : StrRetry
    GuiControl,, Ignore_AbortRetryIgnore, % (Eng) ? "Ignore" : StrIgnore
    GuiControl,, Cancel_CancelTryAgainContinue, % (Eng) ? "Cancel" : StrCancel
    GuiControl,, TryAgain_CancelTryAgainContinue, % (Eng) ? "Try Again" : StrTryAgain
    GuiControl,, Continue_CancelTryAgainContinue, % (Eng) ? "Continue" : StrContinue
    GuiControl,, Retry_RetryCancel, % (Eng) ? "Retry" : StrRetry
    GuiControl,, Cancel_RetryCancel, % (Eng) ? "Cancel" : StrCancel

    DllCall("CheckMenuItem", x64 ? "Ptr" : "UInt", hSysMenu, "UPtr", 0xC0DE, "UInt", Eng * 8)

    Return Eng
}

; SoftModalMessageBox **********************************************************

SoftTest:
    cButtons := SM_CustomButtons.Length()

    ; The message box cannot be closed in the absence of buttons
    If (!cButtons && (Timeout == -1 || Timeout > 5000)) {
        GoSub SM_AddSampleButtons
        Return
    }

    SM_Callback := ""
    Loop %cButtons% {
        If (SM_CustomButtons[A_Index][1] == 9) {
            If (cButtons == 1 && (Timeout == -1 || Timeout > 5000)) {
                MsgBox 0x2010, %AppName%, Only one button with ID 9: the window cannot be closed.
                Return
            }

            SM_Callback := "SoftModalCallback"
        }
    }

    SoftModalMessageBox(SM_Text
        , Title
        , SM_CustomButtons
        , SM_DefaultButton
        , Flags
        , (CustomIcon) ? IconRes : ""
        , (CustomIcon) ? ResID : 0
        , Timeout
        , (SM_Owned) ? hWindow : 0
        , SM_Callback)
Return

SM_AddButton:
SM_EditButton:
    Gui ListView, %hSM_LV%

    If (A_ThisLabel == "SM_AddButton") {
        Title := "New Button"
        SM_ButtonText := ""
    } Else {
        Title := "Edit Button"

        Row := LV_GetNext()
        If (!Row) {
            Return
        }
        LV_GetText(SM_ButtonID, Row, 1)
        LV_GetText(SM_ButtonText, Row, 2)
    }

    Gui MagicBox: +Disabled

    Gui SM_AddButtonDlg: New, LabelSM_AddButtonDlg -MinimizeBox OwnerMagicBox
    Gui Color, 0xFEFEFE
    Gui Font, s9, Segoe UI
    Gui Add, Text, x37 y22 w68 h23 +0x200 Right, &Button Text:
    Gui Add, Edit, vSM_EdtButtonText gSM_PreviewButtonText x118 y24 w88 h21, %SM_ButtonText%
    Gui Add, Button, x217 y23 w88 h23
    Gui Add, Text, x75 y61 w30 h23 +0x200 Right, ID:
    Gui Add, DropDownList, vSM_DDLButtonID x118 y62 w88 AltSubmit, 1||2 - Cancel|3|4|5|6|7|9 - Callback|10|11
    Gui Add, ListView, x-1 y106 w339 h50 Disabled

    If (A_ThisLabel == "SM_AddButton") {
        Gui Add, Button, gSM_AddButtonDlgOK x24 y119 w88 h23 Default, &Next
        Gui Add, Button, gSM_AddButtonDlgOK x119 y119 w88 h23, &OK
        Gui Add, Button, gSM_AddButtonDlgClose x214 y119 w88 h23, &Cancel
    } Else {
        Gui Add, Button, gSM_EditButtonDlgOK x71 y119 w88 h23 Default, &OK
        Gui Add, Button, gSM_AddButtonDlgClose x166 y119 w88 h23, &Cancel

        If (SM_ButtonID > 7) {
            SM_ButtonID--
        }
        GuiControl Choose, SM_DDLButtonID, %SM_ButtonID%
    }

    Gui Show, w325 h155, %Title%
Return

SM_AddButtonDlgEscape:
SM_AddButtonDlgClose:
    Gui MagicBox: -Disabled
    Gui SM_AddButtonDlg: Cancel
Return

SM_AddButtonDlgOK:
    If (A_GuiControl == "&Next") {
        Gui SM_AddButtonDlg: Submit, NoHide
        GuiControl Choose, SM_DDLButtonID, % SM_DDLButtonID + 1
        GuiControl,, SM_EdtButtonText
        GuiControl SM_AddButtonDlg: Focus, SM_EdtButtonText
    } Else {
        Gui MagicBox: -Disabled
        Gui SM_AddButtonDlg: Submit
    }

    If (SM_EdtButtonText == "") {
        Return
    }

    If (SM_DDLButtonID > 7) {
        SM_DDLButtonID++
    }

    Gui MagicBox: Default
    Gui ListView, %hSM_LV%
    LV_Add("", SM_DDLButtonID, SM_EdtButtonText)
    SM_CustomButtons.Push([SM_DDLButtonID, SM_EdtButtonText])

    GoSub SM_UpdateDefaultButtonList
Return

SM_EditButtonDlgOK:
    Gui MagicBox: -Disabled
    Gui SM_AddButtonDlg: Submit

    If (SM_DDLButtonID > 7) {
        SM_DDLButtonID++
    }

    Gui MagicBox: Default
    Gui ListView, %hSM_LV%
    LV_Modify(Row, "Col1", SM_DDLButtonID)
    LV_Modify(Row, "Col2", SM_EdtButtonText)
    SM_CustomButtons[Row][1] := SM_DDLButtonID
    SM_CustomButtons[Row][2] := SM_EdtButtonText

    GoSub SM_UpdateDefaultButtonList
Return

SM_MoveItem:
    Gui ListView, %hSM_LV%
    Row := LV_GetNext()

    If (A_GuiControl == "Move &Up") {
        If (Row == 1) {
            Return
        }

        NewRow := Row - 1
    } Else {
        If (Row == LV_GetCount()) {
            Return
        }

        NewRow := Row + 1
    }

    LV_Modify(NewRow, "", SM_CustomButtons[Row][1], SM_CustomButtons[Row][2])
    LV_Modify(Row, "", SM_CustomButtons[NewRow][1], SM_CustomButtons[NewRow][2])

    ButtonID := SM_CustomButtons[NewRow][1]
    ButtonText := SM_CustomButtons[NewRow][2]
    SM_CustomButtons[NewRow] := [SM_CustomButtons[Row][1], SM_CustomButtons[Row][2]]
    SM_CustomButtons[Row] := [ButtonID, ButtonText]

    GuiControl MagicBox: Focus, SM_LVButtons
    LV_Modify(NewRow, "Select")

    GoSub SM_UpdateDefaultButtonList
Return

SM_DeleteItem:
    Gui ListView, %hSM_LV%
    Row := LV_GetNext()
    LV_Delete(Row)
    SM_CustomButtons.RemoveAt(Row)
    GoSub SM_UpdateDefaultButtonList
Return

SM_ClearAll:
    Gui ListView, %hSM_LV%
    LV_Delete()
    SM_CustomButtons := []
    GuiControl, MagicBox:, SM_DefaultButtonList, % "|First button||"
    GoSub GenerateCode
Return

SM_AddSampleButtons:
    Gui MagicBox: Default
    Gui ListView, %hSM_LV%
    GoSub SM_ClearAll

    SM_Buttons := []
    SM_Buttons.Push([1, "Save"])
    SM_Buttons.Push([4, "Discard"])
    SM_Buttons.Push([9, "Browse..."])
    SM_Buttons.Push([2, "Cancel"])

    Loop % SM_Buttons.Length() {
        LV_Add("", SM_Buttons[A_Index][1], SM_Buttons[A_Index][2])
        SM_CustomButtons.Push([SM_Buttons[A_Index][1], SM_Buttons[A_Index][2]])
    }

    GoSub SM_UpdateDefaultButtonList
Return

SM_PreviewButtonText:
    Gui SM_AddButtonDlg: Submit, NoHide
    GuiControl,, Button1, %SM_EdtButtonText%
Return

SM_UpdateDefaultButtonList:
    Buttons := ""
    Loop % SM_CustomButtons.Length() {
        Buttons .= SM_CustomButtons[A_Index][2] . "|"
    }

    Gui MagicBox: Submit, NoHide
    GuiControlGet SelectedItem, MagicBox:, %SM_DefaultButtonList%
    GuiControl, MagicBox:, SM_DefaultButtonList, % "|First button||" . Buttons
    GuiControl, MagicBox: ChooseString, SM_DefaultButtonList, %SelectedItem%

    GoSub GenerateCode
Return

SM_LVHandler:
    Gui ListView, %hSM_LV%
    If (LV_GetNext()) {
        GoSub SM_EditButton
    } Else {
        GoSub SM_AddButton
    }
Return

SoftModalCallback() {
    MsgBox 0x40040, %AppName%, SoftModalMessageBox callback invoked., 3
}

SM_GenerateIfBlocks:
    cButtons := SM_CustomButtons.Length()

    If (cButtons < 2 && !SM_TimeoutEnabled) {
        Return
    }

    Loop %cButtons% {
        ButtonID := SM_CustomButtons[A_Index][1]

        If (ButtonID == 9) {
            Continue
        }

        If (A_Index > 1) {
            Code .= " Else "
        }

        Code .= "If (Result == " . ButtonID . ") {`n`n}"
    }

    If (SM_TimeoutEnabled) {
        Code .= " Else If (Result == 32000) {`n`n}"
    }

    Code .= "`n`n"
Return

SyncText:
    Gui MagicBox: Submit, NoHide

    If (A_GuiControl == "Text") {
        GuiControl,, MBX_Text, %Text%
        GuiControl,, SM_Text, %Text%
        GuiControl,, TDI_Instruction, %Text%
    } Else If (A_GuiControl == "SM_Text") {
        GuiControl,, MBX_Text, %SM_Text%
        GuiControl,, Text, %SM_Text%
        GuiControl,, TDI_Instruction, %SM_Text%
    } Else If (A_GuiControl == "TDI_Instruction") {
        GuiControl,, MBX_Text, %TDI_Instruction%
        GuiControl,, Text, %TDI_Instruction%
        GuiControl,, SM_Text, %TDI_Instruction%
    } Else If (A_GuiControl == "MBX_Text") {
        GuiControl,, Text, %MBX_Text%
        GuiControl,, SM_Text, %MBX_Text%
        GuiControl,, TDI_Instruction, %MBX_Text%
    }

    GoSub GenerateCode
Return

SyncContent:
    Gui MagicBox: Submit, NoHide

    If (A_GuiControl == "Content") {
        GuiControl,, TDI_Content, %Content%
        GoSub GenerateCode
    } Else {
        GuiControl,, Content, %TDI_Content%
        GoSub TDI_GenerateCode
    }
Return

; Extended MsgBox **************************************************************

; 0x44 message handling function
OnMsgBox(wParam, lParam, msg, hWnd) {
    Global

    Process Exist
    If (hMsgBox := WinExist(Title . " ahk_class #32770 ahk_pid " . ErrorLevel)) {

        If (CustomIcon) {
            hIcon := LoadPicture(IconRes, "w32 Icon" . IconIdx, _)
            SendMessage 0x172, 1, %hIcon% , Static1
        }

        If (MB_Custom) {
            ButtonSet := Flags & 0xF
            If (!ButtonSet) {
                cButtons := 1
            } Else If (ButtonSet ~= "1|4|5") {
                cButtons := 2
            } Else {
                cButtons := 3
            }

            Loop %cButtons% {
                ButtonText := MB_CustomButtons[A_Index].Text
                ButtonIcon := MB_CustomButtons[A_Index].IconRes

                If (ButtonText != "") {
                    ControlSetText Button%A_Index%, %ButtonText%
                }

                If (ButtonIcon != "") {
                    hIcon := LoadPicture(ButtonIcon, "h16 Icon" . MB_CustomButtons[A_Index].IconIdx, _)
                    SendMessage 0xF7, 1, %hIcon%, Button%A_Index% ; BM_SETIMAGE
                }
            }

            If (HelpBtn && (MB_CustomButtons[4].Text != "" || MB_CustomButtons[4].IconRes != "")) {
                ButtonText := MB_CustomButtons[4].Text
                ButtonIcon := MB_CustomButtons[4].IconRes

                HelpBtnPos := cButtons + HelpBtn

                If (ButtonText != "") {
                    ControlSetText Button%HelpBtnPos%, % ButtonText
                }

                If (ButtonIcon != "") {
                    hIcon := LoadPicture(ButtonIcon, "h16 Icon" . MB_CustomButtons[4].IconIdx, _)
                    SendMessage 0xF7, 1, %hIcon%, Button%HelpBtnPos% ; BM_SETIMAGE
                }
            }
        }

        If (MB_PosX != "" || MB_PosY != "") {
            WinMove MB_PosX, MB_PosY
        }
    } Else If (hMsgBox := WinExist("MsgBox Custom Buttons Help")) {
        SendMessage 0x80, 0, % LoadPicture("user32.dll", "h16 Icon5", _),, ahk_id %hMsgBox% ; WM_SETICON
    }
}

MB_ShowCustomButtonsDialog:
    Gui MagicBox: +Disabled

    If (MB_CustomButtonsDlgCreated) {
        Gui MB_CustomButtonsDlg: Show
        Return
    }

    Gui MB_CustomButtonsDlg: New, LabelMB_CustomButtonsDlg -MinimizeBox OwnerMagicBox
    Gui Font, s9, Segoe UI
    Gui Color, White

    Gui Add, Button, vButton1 gMB_CustomButtonsDlgSelectIcon x49 y39 w88 h26 -Wrap
    Gui Add, Button, vButton2 gMB_CustomButtonsDlgSelectIcon x148 y39 w88 h26 -Wrap
    Gui Add, Button, vButton3 gMB_CustomButtonsDlgSelectIcon x247 y39 w88 h26 -Wrap
    Gui Add, Button, vButton4 gMB_CustomButtonsDlgSelectIcon x346 y39 w88 h26 -Wrap

    Gui Add, Edit, vEdit1 gMB_CustomButtonsDlgPreviewText x49 y74 w88 h21 Center
    Gui Add, Edit, vEdit2 gMB_CustomButtonsDlgPreviewText x148 y74 w88 h21 Center
    Gui Add, Edit, vEdit3 gMB_CustomButtonsDlgPreviewText x247 y74 w88 h21 Center
    Gui Add, Edit, vEdit4 gMB_CustomButtonsDlgPreviewText x346 y74 w88 h21 Center

    ;Gui Add, Text, x48 y104 w384 h23 +0x200 Center, Click the button above each field to select the icon.

    Gui Add, Text, x0 y137 w481 h50 -Background
    Gui Add, Button, gMB_CustomButtonsDlgReset x49 y149 w88 h26, &Reset
    Gui Add, Button, gMB_CustomButtonsDlgOK x148 y149 w88 h26 Default, &OK
    Gui Add, Button, gMB_CustomButtonsDlgClose x247 y149 w88 h26, &Cancel
    Gui Add, Button, gMB_CustomButtonsDlgHelp x346 y149 w88 h26, &Help

    Gui Show, w481 h187, MsgBox Custom Buttons

    GuiControl Focus, Edit1

    MB_CustomButtonsDlgCreated := True
Return

MB_CustomButtonsDlgEscape:
MB_CustomButtonsDlgClose:
    Gui MagicBox: -Disabled
    Gui MB_CustomButtonsDlg: Cancel
Return

MB_CustomButtonsDlgOK:
    Gui MagicBox: -Disabled
    Gui MB_CustomButtonsDlg: Default
    Gui Submit

    MB_CustomButtons[1].Text := Edit1
    MB_CustomButtons[2].Text := Edit2
    MB_CustomButtons[3].Text := Edit3
    MB_CustomButtons[4].Text := Edit4

    Buttons := 0
    Loop 3 {
        If (MB_CustomButtons[A_Index].Text != "" || MB_CustomButtons[A_Index].IconRes != "") {
            Buttons := A_Index
        }
    }

    If (MB_CustomButtons[4].Text != "" || MB_CustomButtons[4].IconRes != "") {
        GuiControl MagicBox:, HelpBtn, 1
    }

    Gui MagicBox: Submit, NoHide
    If (Buttons == 3
        && !Buttons_YesNoCancel && !Buttons_AbortRetryIgnore && !Buttons_CancelTryAgainContinue) {
        GuiControl MagicBox:, Buttons_YesNoCancel, 1
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
    } Else If (Buttons == 2 && Buttons_OK) {
        GuiControl MagicBox:, Buttons_OKCancel, 1
        SendMessage 0xF3, 0,,, ahk_id %hPrevDefBtn%
    }

    GoSub GenerateCode
Return

MB_CustomButtonsDlgReset:
    If (MB_CustomButtonsDlgCreated) {
        Gui MB_CustomButtonsDlg: Default
        Loop 4 {
            GuiControl,, Edit%A_Index%
            SendMessage 0xF7, 1, 0, Button%A_Index%, MsgBox Custom Buttons

            MB_CustomButtons[A_Index].Text := ""
            MB_CustomButtons[A_Index].IconRes := ""
        }
    }
Return

MB_CustomButtonsDlgHelp:
OnMessage(0x44, "OnMsgBox")
MsgBox 0x2000, MsgBox Custom Buttons Help,
(LTrim
    • Leave the field blank to use the default button text.

    • Use a space to increase the distance between the icon and the text.

    • The return value corresponds to the original combination of buttons.

    • Help button: when pressed, the message box remains open.

    • Insert an ampersand before characters that denote an accelerator (Alt+key).

    • Empty all fields, including icons, with the Reset button.

    • Right-click a button to remove only the icon.
)
OnMessage(0x44, "")
Return

MB_CustomButtonsDlgPreviewText:
    Gui MB_CustomButtonsDlg: Default
    Gui Submit, NoHide

    n := SubStr(A_GuiControl, 0, 1)
    If (Edit%n% != "") {
        GuiControl,, Button%n%, % Edit%n%
    } Else {
        GuiControl,, Button%n%, %A_Space%
    }
Return

MB_CustomButtonsDlgSelectIcon:
    If (!NT6) {
        MsgBox 0x2030, %AppName%, Custom button with icon requires Windows Vista or higher.
        Return
    }

    n := SubStr(A_GuiControl, 0, 1)

    MB_IconRes := IconRes
    MB_IconIdx := 0

    If (ChooseIcon(MB_IconRes, MB_IconIdx, hWindow)) {
        ; The icon cannot be displayed if the button has no text
        GuiControlGet ButtonText,, %A_GuiControl%
        If (ButtonText == "") {
            GuiControl,, %A_GuiControl%, %A_Space%
        }

        hIcon := LoadPicture(MB_IconRes, "h16 Icon" . MB_IconIdx, _)
        SendMessage 0xF7, 1, %hIcon%, %A_GuiControl% ; BM_SETIMAGE

        MB_CustomButtons[n].IconRes := MB_IconRes
        MB_CustomButtons[n].IconIdx := MB_IconIdx
    }
Return

MB_CustomButtonsDlgContextMenu() {
    Global g_Button := A_GuiControl
    If (A_GuiControl ~= "Button[1-4]") {
        Menu CustomMsgBoxMenu, Add, Remove Icon, MB_CustomButttonsDlgRemoveIcon
        Menu CustomMsgBoxMenu, Show
        Menu CustomMsgBoxMenu, Delete
    }
}

MB_CustomButttonsDlgRemoveIcon:
    SendMessage 0xF7, 1, 0, %g_Button%, A
    MB_CustomButtons[SubStr(g_Button, 0, 1)].IconRes := ""
Return

; MsgBoxEx *********************************************************************

MBX_SetVariables:
    Gui MagicBox: Submit, NoHide

    MBX_Icon := {0x10: 4, 0x20: 3, 0x30: 2, 0x40: 5}[Icon]

    ControlGet Items, List,,, ahk_id %hMBX_LV%

    ; Set the default button*
    SendMessage 0x147, 0, 0,, ahk_id %hMBX_DefaultButtonList% ; CB_GETCURSEL
    If (ErrorLevel > 1) {
        GuiControlGet MBX_DefaultButton,, %hMBX_DefaultButtonList%
        Items := StrReplace(Items, MBX_DefaultButton, MBX_DefaultButton . "*",, 1)
    }
    MBX_Buttons := StrReplace(Items, "`n", "|")

    MBX_Options := ""
    If (MBX_NoCloseButton) {
        MBX_Options .= "-SysMenu "
    }
    If (MBX_CanBeMinimized) {
        MBX_Options .= "MinimizeBox "
    }
    If (MBX_AlwaysOnTop) {
        MBX_Options .= "AlwaysOnTop"
    }
    MBX_Options := RTrim(MBX_Options)

    If (MBX_CheckedByDefault) {
        MBX_VerificationText := "*" . MBX_VerificationText
    }
Return

MBX_Test:
    GoSub MBX_SetVariables

    MsgBoxEx(MBX_Text
        , Title
        , MBX_Buttons
        , (CustomIcon) ? [IconIdx, IconRes] : MBX_Icon
        , MBX_VerificationText
        , MBX_Options
        , (MBX_Owned) ? WinExist("A") : ""
        , (MBX_TimeoutEnabled) ? MBX_Timeout : 0
        , (MBX_CustomFont) ? MBX_FontOptions : ""
        , (MBX_CustomFont) ? MBX_FontName : ""
        , (MBX_CustomBGColor) ? MBX_BGColor : ""
        , "MBX_Callback")
Return

MBX_GenerateCode:
    GoSub MBX_SetVariables

    Code := "Text := """ . EscapeChars(MBX_Text) . """`n"

    If (MBX_VerificationText != "" && MBX_VerificationText != "*") {
        Code .= "CheckText := """ . EscapeChars(MBX_VerificationText) . """`n"
    }

    Code .= "`n"

    Call := ""
    DefParam := False

    If (InStr(MBX_Buttons, "...")) {
        Call := ", ""Callback"""
        DefParam := True
    }

    If (MBX_CustomBGColor) {
        Call := ", """ . MBX_BGColor . """" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    If (MBX_CustomFont && MBX_FontName) {
        Call := ", """ . MBX_FontName . """" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    If (MBX_CustomFont && MBX_FontOptions) {
        Call := ", """ . MBX_FontOptions . """" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    If (MBX_TimeoutEnabled) {
        Call := ", " . MBX_Timeout . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", 0" . Call
    }

    If (MBX_Owned) {
        Call := ", WinExist(""A"")" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", 0" . Call
    }

    If (MBX_Options) {
        Call := ", """ . MBX_Options . """" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    If (MBX_VerificationText != "" && MBX_VerificationText != "*") {
        Call := ", CheckText" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    If (CustomIcon) {
        If (IconRes != "shell32.dll") {
            Call := ", [" . IconIdx . ", """ . IconRes . """]" . Call
        } Else {
            Call := ", [" . IconIdx . "]" . Call
        }
        DefParam := True
    } Else If (MBX_Icon) {
        Call := ", " . MBX_Icon . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", 0" . Call
    }

    If (MBX_Buttons != "") {
        Call := ", """ . EscapeChars(MBX_Buttons) . """" . Call
        DefParam := True
    } Else If (DefParam) {
        Call := ", """"" . Call
    }

    Call := ", """ . EscapeChars(Title) . """" . Call

    Code .= "Result := MsgBoxEx(Text" . Call . ")`n`n"

    Gui CodeView: Submit, NoHide
    If (IfBlocks) {
        GoSub MBX_GenerateIfBlocks
    }

    If (InStr(MBX_Buttons, "...")) {
        Code .= "Callback() {`n}`n`n"
    }

    Code .= _MsgBoxEx

    GuiControl, CodeView:, EdtCode, %Code%
Return

MBX_GenerateIfBlocks:
    Ifs := ""

    MBX_Buttons := StrReplace(MBX_Buttons, "&")
    MBX_Buttons := StrReplace(MBX_Buttons, "*")

    Loop Parse, MBX_Buttons, |
    {
        If (InStr(A_LoopField, "...")) {
            Continue
        }

        If (A_Index > 1) {
            Ifs .= " Else "
        }

        Ifs .= "If (Result == """ . A_LoopField . """) {`n`n}"
    }

    If (!InStr(MBX_Buttons, "Cancel")) {
        If (Ifs != "") {
            Ifs .= " Else "

            Ifs .= "If (Result == ""Cancel"") {`n`n}"
        }
    }

    If (MBX_TimeoutEnabled) {
        If (Ifs != "") {
            Ifs .= " Else "
        }

        Ifs .= "If (Result == ""TIMEOUT"") {`n`n}"
    }

    Code .= Ifs . "`n`n"
Return

MBX_AddButton:
    Gui ListView, %hMBX_LV%
    LV_Add("", "")
    GuiControl Focus, %hMBX_LV%
    PostMessage 0x1076, LV_GetCount() - 1, 0,, ahk_id %hMBX_LV% ; LVM_EDITLABELW
    MBX_Adding := True
Return

MBX_EditButton:
    Gui ListView, %hMBX_LV%
    GuiControl Focus, %hMBX_LV%
    Row := LV_GetNext(0, "Focused") - 1
    PostMessage 0x1076, Row, 0,, ahk_id %hMBX_LV% ; LVM_EDITLABELW
Return

MBX_DeleteButton:
    Gui ListView, %hMBX_LV%
    LV_Delete(LV_GetNext(0, "Focused"))

    GoSub MBX_UpdateDefaultButtonList
Return

MBX_DeleteAll:
    Gui ListView, %hMBX_LV%
    LV_Delete()

    GoSub MBX_UpdateDefaultButtonList
Return

MBX_SetButtons:
    Gui MagicBox: Submit, NoHide
    Gui ListView, %hMBX_LV%
    LV_Delete()

    MBX_Buttons := StrSplit(MBX_Preset, " - ")
    For Each, Item in MBX_Buttons {
        LV_Add("", Item)
    }

    GoSub MBX_UpdateDefaultButtonList
Return

MBX_SelectFont:
    Loop Parse, MBX_FontOptions, %A_Space%
    {
        If (A_LoopField ~= "^s\d") {
            Size := SubStr(A_LoopField, 2)
        } Else If (A_LoopField ~= "^c\d") {
            Color := SubStr(A_LoopField, 2)
        } Else If (A_LoopField ~= "i)(italic|bold|semibold|underline|strikeout)") {
            Style .= A_LoopField . " "
        }
    }

    If (ChooseFont(MBX_FontName, Size, Style, Color,, hWindow)) {
        Size := (Size != "") ? "s" . Size . " " : ""
        Color := (Color != "") ? "c" . Color : ""
        MBX_FontOptions := RTrim(Size . Style . Color)
        MBX_CustomFont := True
    } Else {
        MBX_CustomFont := False
        MBX_FontOptions := ""
        MBX_FontName := ""
    }

    GoSub GenerateCode
Return

MBX_SelectColor:
    If (ChooseColor(MBX_BGColor, hWindow)) {
        MBX_CustomBGColor := True
    } Else {
        MBX_CustomBGColor := False
    }

    GoSub GenerateCode
Return

MBX_Callback:
    MsgBox 0x40040, %AppName%, MsgBoxEx callback invoked., 3
Return

MBX_SetExclusiveOption:
    If (A_GuiControl == "MBX_NoCloseButton") {
        GuiControl,, MBX_CanBeMinimized, 0
    } Else {
        GuiControl,, MBX_NoCloseButton, 0
    }

    GoSub GenerateCode
Return

MBX_MoveUp:
    Gui ListView, %hMBX_LV%
    If ((Row := LV_GetNext()) > 1) {
        MBX_SwapRows(Row, Row - 1)
    }
Return

MBX_MoveDown:
    Gui ListView, %hMBX_LV%
    Row := LV_GetNext()
    If (Row != LV_GetCount()) {
        MBX_SwapRows(Row, Row + 1)
    }
Return

MBX_SwapRows(Row, NewPos) {
    Global

    LV_GetText(RowText, Row)
    LV_GetText(NewPosText, NewPos)

    LV_Modify(NewPos, "", RowText)
    LV_Modify(Row, "", NewPosText)

    GuiControl MagicBox: Focus, %hMBX_LV%
    LV_Modify(NewPos, "Select")

    GoSub MBX_UpdateDefaultButtonList
}

MBX_LVHandler:
    If (A_GuiEvent == "e") {
        LV_GetText(RowText, A_EventInfo)
        If (RowText == "") {
            GoSub MBX_DeleteButton
        }

        If (MBX_Adding) {
            GuiControl,, MBX_DefaultButtonList, %RowText%
            MBX_Adding := False
            GuiControl Focus, %hMBX_AddBtn%
            GoSub GenerateCode
        } Else {
            GoSub MBX_UpdateDefaultButtonList
        }
    } Else If (A_GuiEvent == "DoubleClick") {
        GoSub MBX_EditButton
    }
Return

MBX_UpdateDefaultButtonList:
    Gui MagicBox: Default

    GuiControlGet SelectedItem,, MBX_DefaultButtonList

    ControlGet MBX_ButtonList, List,,, ahk_id %hMBX_LV%
    GuiControl,, MBX_DefaultButtonList, % "|" . "First button||" . StrReplace(MBX_ButtonList, "`n", "|")

    GuiControl ChooseString, MBX_DefaultButtonList, %SelectedItem%

    GoSub GenerateCode
Return

DefineTooltips() {
    TT.InfoIcon := "Information"
    TT.WarningIcon := "Warning"
    TT.QuestionIcon := "Question"
    TT.ErrorIcon := "Error"

    TT.HelpBtn := "When the user clicks the Help button or presses F1,`nthe system sends a WM_HELP message to the owner."

    TT.NoOwner := TT.SM_NoOwner := "The message box is not owned by another window."

    TT.Owned := TT.SM_Owned := TT.MBX_Owned := "The user must respond to the message box`nbefore continuing work in the owner window."

    TT.TaskModal := TT.SM_TaskModal := "Prevent input to other windows`nbelonging to the current thread."

    TT.MBX_AlwaysOnTop := TT.TDI_AlwaysOnTop := TT.SM_AlwaysOnTop := TT.AlwaysOnTop := "The message box stays above any`nwindow, even when deactivated."

    TT.TDI_RTLReading := TT.SM_RTLReading := TT.RTLReading := "Displays message and title using right-to-left`nreading order on Hebrew and Arabic systems."

    TT.TDI_AllowCancellation := "The dialog can be closed even`nif no cancel button is specified."

    TT.TDI_CanBeMinimized := 
    (LTrim
    "The Task Dialog can be minimized. If a parent
    window is defined, this option has no effect.
    Cannot be used with relative position as well."
    )

    TT.TDI_RelativePosition :=
    (LTrim
    "The task dialog is positioned (centered) relative to the parent window.
    The dialog becomes modal when the handle to the parent is specified."
    )

    TT.TDI_ExpandInFooterArea := "Expanded text is displayed at the`nbottom of the dialog's footer area."
    TT.TDI_ExpandedByDefault := "Expanded text is displayed`nwhen the Task Dialog opens."

    TT.TDI_VerificationFlag := TT.MBX_CheckedByDefault := "The verification check box is initially checked."

    TT.TDI_Marquee := "Used to indicate activity without specifying`nwhat proportion of the progress is complete."

    TT.MBX_NoCloseButton := 
    (LTrim
    "This option removes the close button from the title bar,
    but the message box can still be closed with the Esc key."
    )

    TT.MBX_CanBeMinimized := "Enables the minimize box in the title bar."

    TT.RegVal := "Leave blank to use the full path of the script."

    TT.WTS_Wait :=
    (LTrim
    "If this option is checked, the function does not return
    until the user responds or the time-out interval elapses."
    )
}

OnWM_MOUSEMOVE() {
    Static CurrControl, PrevControl := ""
    CurrControl := A_GuiControl

    If (CurrControl != PrevControl && !InStr(CurrControl, " ")) {
        ToolTip ; Turn off any previous tooltip.
        SetTimer DisplayToolTip, 500 ; 800
        PrevControl := CurrControl
    }
    Return

    DisplayToolTip:
        SetTimer DisplayToolTip, Off
        If (Shields && CurrControl ~= "(Info|Warning|Question|Error)Icon") {
            Return
        }
        ToolTip % TT[CurrControl]
        Duration := StrLen(TT[CurrControl]) * 60
        SetTimer RemoveToolTip, % (Duration > 3500) ? Duration : 3500
    return

    RemoveToolTip:
        SetTimer RemoveToolTip, Off
        ToolTip
    Return
}

ShowHelp() {
    Global
    hCursor := DllCall("LoadCursor", "UInt", 0, "Ptr", 32649, "Ptr")
    SetClassLong := x64 ? "SetClassLongPtr" : "SetClassLong"

    Gui MagicBox: +Disabled
    Gui Help: New, LabelHelp -MinimizeBox -SysMenu OwnerMagicBox
    Gui Color, White
    Gui Add, CheckBox, x0 y0 w0 h0

    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x24 y14 w200 h23 +0x200 BackgroundTrans, Online Reference
    Gui Font

    Gui Font, s9, Segoe UI
    Gui Add, Text, x24 y48 w170 h18 +0x200, MsgBox
    Gui Add, Text, x24 y96 w170 h18 +0x200, SHMessageBoxCheck
    Gui Add, Text, x24 y144 w170 h18 +0x200, MessageBoxIndirect
    Gui Add, Text, x24 y192 w170 h18 +0x200, SoftModalMessageBox
    Gui Add, Text, x24 y240 w170 h18 +0x200, MsiMessageBox
    Gui Add, Text, x24 y288 w170 h18 +0x200, WTSSendMessage
    Gui Add, Text, x24 y336 w170 h18 +0x200, TaskDialog
    Gui Add, Text, x24 y384 w170 h18 +0x200, TaskDialogIndirect
    Gui Font

    Gui Font, c0x356BC0, Segoe UI
    Gui Add, Text, WantTab hWndhLink1 vLink1 gOpenURL x24 y66 w450 h18 +0x300
    , https://autohotkey.com/docs/commands/MsgBox.htm
    Gui Add, Text, hWndhLink2 vLink2 gOpenURL x24 y114 w450 h18 +0x300
    , https://msdn.microsoft.com/en-us/library/windows/desktop/bb773836(v=vs.85).aspx
    Gui Add, Text, hWndhLink3 vLink3 gOpenURL x24 y162 w450 h18 +0x300
    , https://msdn.microsoft.com/en-us/library/windows/desktop/ms645511(v=vs.85).aspx
    Gui Add, Text, hWndhLink4 vLink4 gOpenURL x24 y210 w450 h18 +0x300
    , https://www.google.com.br/#q=SoftModalMessageBox
    Gui Add, Text, hWndhLink5 vLink5 gOpenURL x24 y258 w450 h18 +0x300
    , https://www.google.com.br/#q=MsiMessageBox
    Gui Add, Text, hWndhLink6 vLink6 gOpenURL x24 y306 w450 h18 +0x300
    , https://msdn.microsoft.com/en-us/library/aa383842(v=vs.85).aspx
    Gui Add, Text, hWndhLink7 vLink7 gOpenURL x24 y354 w450 h18 +0x300
    , https://msdn.microsoft.com/en-us/library/windows/desktop/bb760540(v=vs.85).aspx
    Gui Add, Text, hWndhLink8 vLink8 gOpenURL x24 y402 w450 h18 +0x300
    , https://msdn.microsoft.com/en-us/library/windows/desktop/bb760544(v=vs.85).aspx

    DllCall(SetClassLong, "Ptr", hLink1, "Int", -12, "Ptr", hCursor)

    Gui Add, Button, gHelpClose x408 y440 w80 h23 Default, &Close

    WinGetPos,, wy,,, ahk_id %hWindow%
    Gui Show, % "y" . (wy + 30) . "w498 h472", Help
}

OpenURL:
    GuiControlGet URL,, %A_GuiControl%
    Try {
        Run %URL%
    }
Return

HelpEscape:
HelpClose:
    Gui MagicBox: -Disabled
    Gui Help: Destroy
Return

CheckRequirements() {
    If (!A_IsUnicode) {
        MsgBox 0x10, Error, %AppName% is incompatible with the ANSI build of AutoHotkey.
        ExitApp
    }
}

SaveCode:
    FileSelectFile SelectedFile, S16,, Save File, AutoHotkey Scripts (*.ahk)
    If (ErrorLevel) {
        Return
    }

    SplitPath SelectedFile,,, Extension
    If (Extension == "" && !FileExist(SelectedFile . ".ahk")) {
        SelectedFile .= ".ahk"
    }

    Gui CodeView: Submit, NoHide
    FileEncoding UTF-8
    FileDelete %SelectedFile%
    FileAppend %EdtCode%, %SelectedFile%
Return
