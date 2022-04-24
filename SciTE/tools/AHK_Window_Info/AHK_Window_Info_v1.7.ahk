;Reveal information on windows, controls, etc. 
;by toralf
;requires AHK 1.0.44.04
;www.autohotkey.com/forum/topic8976.html

ScriptName = AHK Window Info 1.7

; License: Attribution-NonCommercial-ShareAlike 2.5 licence from Creative Commons 
; for details see: http://creativecommons.org/licenses/by-nc-sa/2.5/legalcode
;
; export code by sosaited www.autohotkey.com/forum/viewtopic.php?t=8732&p=53372#53372
; idea and lot of code of frame drawing by shimanov
; several ideas from Chris and other users of the AHK forum

; initial ideas taken from these scripts: 
; Ahk Window Spy 1.3.3 by Decarlo www.autohotkey.com/forum/viewtopic.php?t=4679 
; WinInfo Menu by Jon www.autohotkey.com/forum/viewtopic.php?t=8617

;changes since 1.6
; - added a small gap in the mouse picker grid to identify the center (thanks fade2gray)
; - adjusted groupbox size and tab size
; - added reset of picker to default color on dimensional change

;changes since 1.5
; - Groupboxes with bold text have been set -wrap, to fix line breaks on some windows themes
; - BGR is made default for color picker
; - update is stopped when mouse moves over its own gui, allowing easier graping of data, since no Pause key needs to be pressed. 

;changes since 1.4
; - "H" replaced with Hwnd; "P" and "S" with "Pos" and "Size" on advanced tab for Control
; - GroupBox names have bold font
; - Mouse color picker is only updated when mouse tab is visible. Otherwise set to gray
; - set default for color picker to 15x15, since it only influences CPU load when the mouse tab is visible
; - controls list items are only updated when advanced tab is visible. Otherwise set to ">>>not updated<<<""
; - windows statusbar text is only updated when advanced tab is visible. Otherwise set to ">>>not updated<<<""
; - fast/slow visible/hidden window text are only updated when advanced tab is visible. Otherwise set to ">>>not updated<<<""
;todo
; - Window Info should be tested on Windows 9x

;changes since 1.3
; - last tab gets remembered between starts
; - large list hides automatically when tab is not "Advanced"
; - by default not rectangle is drawn around controls
; - gui starts NoActivate
; - fixed a problem with hidden gui and pause key
; - reduced impact in hidden mode on CPU load to nearly 0
; - to support 800x600 screen resolutions the advanced tab initial height is 600 
; - instead of auto-update, update of data can be done on mouse click (button can be L/M/R, default M)
; - when started with "HideGui" turned on: GUI starts hidden, after 500 ms data is collected and GUI shown 
; - changed licence to Attribution-NonCommercial-ShareAlike 2.5 licence from Creative Commons

;changes since 1.2
; - added: Control handle to advanced and list view
; - improved: fixed some spelling mistakes
; - fixed: option "Show tooltip at cursor" had no effect
; - fixed: option "Show tooltip at cursor" wasn't remembered between sessions
; - improved: For all DllCall's the types are put in quotes  
; - changed: coordinates and sizes will have a space after the comma when put on clipboard 
; - changed: the number of characters in the GUI for the list items is limited to 200. Clipboard will receive all 
; - changed: "Introduction - Please Read" button moved to new info tab
; - changed: Renamed "active control in window" to "focused control in window".
; - fixed: Window Info refused to minimize while the right-side list was displayed.
; - changed: While Window Info is minimized, updating of data is turned off
; - fixed: Coordinates of GUI got stored when GUI got closed minimized

;changes since 1.1
; - added: OnExit routine that cleans up frame gui if script exits unexpectedly
; - changed: Tooltip of control frame disappears when mouse gets moved onto it.
; - changed: font size of GUI is now 6pt

;changes since 1.0
; - improved: specified the font for the GUI, MS Sans Serif, 8 point
; - changed: for some OS (WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME) the icon is changed to ID 57
; - improved: small features that simplify maintenance
;        + combine update routines
;        + simplify options actions
;        + simplify Pause Key actions
;        + reorder code
; - improved: new method to capture fast/slow visible/hidden window text (Thanks Chris)
; - changed: Gui (advanced) now holds fields for fast/slow visible/hidden window text
; - added: option to switch color picker between RGB and BGR
; - improved: color picker only updates when mouse moves or color below mouse changes. This reduces jittery update.
; - changed: Color picker now has a 15x15 color matrix
; - changed: checkbox "Show right List" changed to button that alternates between "More Info >>" and "<< Less Info".
; - added: check for minium required AHK version 
; - added: new option to turn auto-update automatically ON when Gui gets inactive (if it had been turned off (by pause or by the large list))

/*
Requests:
[quote="Chris"]Sometimes pressing Window Info's minimize button fails to work.[/quote]I still can't reproduce it. I tried it 20 times any each time the window minimized 

[quote="Chris"]I've made a note to test it on Win9x prior to distribution.[/quote]Please do. Or is there someone else out there to do the testing. Would be very much appreaciated. 

[quote="Chris"]Minor typos in source code comments: "or less or" should be "or else" in 2 places.[/quote]The two cases where "or less or" is written are actually correct. 
*/

AHK_version = 1.0.44.04 
If not A_IsCompiled      ;if it is a script
    CheckAHKVersion(AHK_version)   ;check if minimum AHK Version is installed 

InformationText =
  (LTrim
    This Gui will reveal information on windows, controls, etc.
    This software is under the GNU General Public License for details see: www.autohotkey.com/docs/license.htm
    
    Move your mouse over the area of interest and see the data in this GUI changing accordingly (auto-update). The auto-update stops when this GUI becomes the active one. To achieve this without moving the mouse you can use Alt+Tab to change to %ScriptName%. Or you can use a hotkey to turn the auto-update off. The default hotkey is the Pause key.
    
    When the data for the large list is collected (advanced tab), the auto-update of the data is stopped automatically to allow you to work with the data. Use the toggle hotkey (see below) to create a new snapshot of data. Or turn on the option, to start updating again when the GUI gets deactivated. 
    
    These shortcuts exist:
    =================
    
    => Toggle Auto-Update Hotkey (default: Pause):
    ---------------------------------------------------------------------------
    Toggles (start/stop) auto-updating data in GUI OR creates a new snapshot of data when auto-update has been stopped automatically. 
    
    => Left-Mouse Button:
    ---------------------------------------
    Copies the content of a control to the clipboard. This is achieved in the code with OnMessage(), thus it should not interfere with any of your own hotkeys.
    
    => Middle-Mouse Button:
    ---------------------------------------
    Toggles AlwaysOnTop status of this window. Click inside the window, it will not work on the titlebar. This is achieved in the code with OnMessage(), thus it should not interfere with any of your own hotkeys.
    
    => Win+s hotkey combination:
    ------------------------------------------------
    Exports data to file. It will only work, when auto-update has been stopped. 
    
    Remarks:
    =======
    - You can change the toggle auto-update hotkey in the advanced options (you will not see keys that do not produces visible characters, e.g. the default Pause key). A key has to be specified. A single Ctrl, Shift, Alt, Win key or their combinations are not allowed.
    - The advanced option "Hide/Show Gui" allows you to create snapshots of data while the GUI is hidden. The toggle auto-update hotkey will toggle the visibility of the GUI. Just before the GUI is shown again the data gets collected and the GUI updated.
    - Log to file only works when auto-update has been stopped.
    - Specify a file name you want to save the data too. Insert #'s into the filename, if you want %ScriptName% to number the files automatically. 
  )  

#SingleInstance force
;set working dir, in case this script is called from some other script in a different dir 
SetWorkingDir, %A_ScriptDir%

GoSub, ReadIni
GoSub, CreateTrayMenu
GoSub, BuildGui

WindowControlTextSize = 32767  ; Must be 32767 or less or it won't work on Windows 95.
VarSetCapacity(WindowControlText, WindowControlTextSize)
ControlTextSize = 512          ; Must be 32767 or less or it won't work on Windows 95.
VarSetCapacity(ControlText, ControlTextSize)

;activate auto-update toggle hotkey
HotKey, %HtkPauseAction%, PauseAction, On

;toggle AOT attribute of GUI with middle mouse click
WM_MBUTTONDOWN = 0x207
OnMessage(WM_MBUTTONDOWN, "ToggleOnTopGui1")

;initialize Save hotkey, so it can be easily turned on/off 
HotKey, #s, BtnSaveExport, Off
;initialize update on click hotkey, so it can be easily turned on/off 
Hotkey, IfWinNotActive, ahk_id %Gui1UniqueID%
Hotkey, ~%CbbHtkUpdate%, UpdateOnClick, Off
Hotkey, IfWinNotActive

;activate update on click
If RadUpdateOnClick {
      Hotkey, IfWinNotActive, ahk_id %Gui1UniqueID%
      Hotkey, ~%CbbHtkUpdate%, On
      Hotkey, IfWinNotActive
}Else{
    ;activate auto-start updating at Gui inactivity
    WM_ACTIVATE = 0x6
    If ChkAutoStartUpdate
        OnMessage(WM_ACTIVATE, "WM_ACTIVATE")

    ;set timer once, so that it knows its interval and can be easily turned on/off
    UpdateIsStopped := True
    SetTimer, UpdateInfo, %CbbUpdateInterval%
    If ChkHideGui {
        Sleep, 500
        Gosub, PauseAction
        ToolTip("Press Pause to hide GUI again", 2000)
    }Else
        UpdateIsStopped := False
  }
    
;activate copy-on-click for left mouse click
WM_LBUTTONDOWN = 0x201
If ChkCopyToCB
    OnMessage(WM_LBUTTONDOWN, "WM_LBUTTONDOWN")

;set static parameters to draw frames around control and window
Sysget, ScreenWidth, 78   ; get screen size from virtual screen 
Sysget, ScreenHeight, 79 
frame_cc = 0x0000FF       ;set color for frame, 0x00BBGGRR
frame_cw = 0x00FF00       ;set color for frame, 0x00BBGGRR
frame_t  = 2              ;set line thickness for frame, 1-10

GoSub, ToogleExportActions
GoSub, PrepareFrameDraw  ;create or destroy frame drawing objects

OnExit, ExitSub
Return
;######## End of Auto-Exec-Section

ExitSub:
  GoSub, CleanUpFrameGui
  Sleep,50
  ExitApp
Return

ReadIni:
  SplitPath, A_ScriptName, , , , OutNameNoExt
  IniFile = %OutNameNoExt%.ini
  
  IniRead, Gui1Pos                 , %IniFile%, Settings, Gui1Pos                , x0 y0
  IniRead, Gui1AOTState            , %IniFile%, Settings, Gui1AOTState           , 1
  IniRead, Tab1                    , %IniFile%, Settings, Tab1                   , 1
  IniRead, RadWindow               , %IniFile%, Settings, RadWindow              , 2
  IniRead, RadControl              , %IniFile%, Settings, RadControl             , 2
  IniRead, SelectedRadList         , %IniFile%, Settings, SelectedRadList        , 1
  IniRead, ChkShowList             , %IniFile%, Settings, ChkShowList            , 0
  IniRead, HtkPauseAction          , %IniFile%, Settings, HtkPauseAction         , Pause
  IniRead, ChkCopyToCB             , %IniFile%, Settings, ChkCopyToCB            , 1
  IniRead, ChkHideGui              , %IniFile%, Settings, ChkHideGui             , 0
  IniRead, ChkUseSaveHotkey        , %IniFile%, Settings, ChkUseSaveHotkey       , 0
  IniRead, ChkExportMousePosScreen , %IniFile%, Export  , ChkExportMousePosScreen, 1
  IniRead, ChkExportMousePosAWin   , %IniFile%, Export  , ChkExportMousePosAWin  , 0
  IniRead, ChkExportMousePosWin    , %IniFile%, Export  , ChkExportMousePosWin   , 1
  IniRead, ChkExportMousePointer   , %IniFile%, Export  , ChkExportMousePointer  , 0
  IniRead, ChkExportMouseColorRGB  , %IniFile%, Export  , ChkExportMouseColorRGB , 0
  IniRead, ChkExportMouseColorHex  , %IniFile%, Export  , ChkExportMouseColorHex , 0
  IniRead, ChkExportCtrlText       , %IniFile%, Export  , ChkExportCtrlText      , 1
  IniRead, ChkExportCtrlClass      , %IniFile%, Export  , ChkExportCtrlClass     , 1
  IniRead, ChkExportCtrlPos        , %IniFile%, Export  , ChkExportCtrlPos       , 0
  IniRead, ChkExportCtrlSize       , %IniFile%, Export  , ChkExportCtrlSize      , 0
  IniRead, ChkExportCtrlListItems  , %IniFile%, Export  , ChkExportCtrlListItems , 0
  IniRead, ChkExportWinTitle       , %IniFile%, Export  , ChkExportWinTitle      , 1
  IniRead, ChkExportWinPos         , %IniFile%, Export  , ChkExportWinPos        , 0
  IniRead, ChkExportWinSize        , %IniFile%, Export  , ChkExportWinSize       , 0
  IniRead, ChkExportWinClass       , %IniFile%, Export  , ChkExportWinClass      , 1
  IniRead, ChkExportWinProcess     , %IniFile%, Export  , ChkExportWinProcess    , 1
  IniRead, ChkExportWinUID         , %IniFile%, Export  , ChkExportWinUID        , 0
  IniRead, ChkExportWinPID         , %IniFile%, Export  , ChkExportWinPID        , 0
  IniRead, ChkExportWinStatusText  , %IniFile%, Export  , ChkExportWinStatusText , 1
  IniRead, ChkExportWinText        , %IniFile%, Export  , ChkExportWinText       , 1
  IniRead, ChkExportLargeList      , %IniFile%, Export  , ChkExportLargeList     , 1
  IniRead, EdtExportFile           , %IniFile%, Export  , EdtExportFile          , AHK_Window_Info_Data_###.txt
  IniRead, ChkExportAutoNumber     , %IniFile%, Export  , ChkExportAutoNumber    , 1
  IniRead, ChkExportAppend         , %IniFile%, Export  , ChkExportAppend        , 0
  IniRead, ChkShowInfoToolTip      , %IniFile%, Advanced, ChkShowInfoToolTip     , 1
  IniRead, ChkDrawRectCtrl         , %IniFile%, Advanced, ChkDrawRectCtrl        , 0
  IniRead, ChkDrawRectWin          , %IniFile%, Advanced, ChkDrawRectWin         , 0
  IniRead, ChkTtpMaster            , %IniFile%, Advanced, ChkTtpMaster           , 0
  IniRead, ChkTtpMSPos             , %IniFile%, Advanced, ChkTtpMSPos            , 0
  IniRead, ChkTtpMWPos             , %IniFile%, Advanced, ChkTtpMWPos            , 1
  IniRead, ChkTtpMColor            , %IniFile%, Advanced, ChkTtpMColor           , 1
  IniRead, ChkTtpCClass            , %IniFile%, Advanced, ChkTtpCClass           , 1
  IniRead, ChkTtpCPos              , %IniFile%, Advanced, ChkTtpCPos             , 0
  IniRead, ChkTtpCSize             , %IniFile%, Advanced, ChkTtpCSize            , 0
  IniRead, ChkTtpWClass            , %IniFile%, Advanced, ChkTtpWClass           , 1
  IniRead, ChkTtpWTitle            , %IniFile%, Advanced, ChkTtpWTitle           , 1
  IniRead, CbbUpdateInterval       , %IniFile%, Advanced, CbbUpdateInterval      , 100
  IniRead, CbbColorPickDim         , %IniFile%, Advanced, CbbColorPickDim        , 15x15
  IniRead, RadColorPick            , %IniFile%, Advanced, RadColorPick           , 2
  IniRead, ChkAutoStartUpdate      , %IniFile%, Advanced, ChkAutoStartUpdate     , 1
  IniRead, CbbHtkUpdate            , %IniFile%, Advanced, CbbHtkUpdate           , MButton
  IniRead, RadUpdateOnClick        , %IniFile%, Advanced, RadUpdateOnClick       , 0
  IniRead, RadUpdateAuto           , %IniFile%, Advanced, RadUpdateAuto          , 1
Return

CreateTrayMenu:
  ;location of icon file
  IconFile := A_WinDir "\system" iif(A_OSType = "WIN32_WINDOWS","","32") "\shell32.dll"
  ;create traybar menu
  ;icon for taskbar and for proces in task manager
  If A_OSVersion in WIN_2000,WIN_NT4,WIN_95,WIN_98,WIN_ME
      Menu, Tray, Icon, %IconFile%, 57    
  Else
      Menu, Tray, Icon, %IconFile%, 172
  Menu, Tray, NoStandard
  Menu, Tray, Tip, %ScriptName%
  Menu, Tray, Add, Show, GuiShow
  Menu, Tray, Default, Show 
  Menu, Tray, Add, Exit, GuiClose
  Menu, Tray, Click, 1
Return

GuiShow:
  Gui, 1:Show                   ;show window again if it has been hidden
Return

BuildGui:
  GuiIsVisible := False
  Gui, 1: +LastFound
  Gui1UniqueID := WinExist() 
  Gui, 1:Font, s6, MS Sans Serif
  Gui, 1:Margin, 0, 0
  Gui, 1:Add, Tab, w287 h145 vTab1 gTab1 AltSubmit -Wrap , Simple|Advanced|Mouse|Options|Info
    Gui, 1:Tab, Simple
      Gui, 1:Add, Text, x5 y28 , Window Title
      Gui, 1:Add, Edit, x+2 yp-3 w211 vEdtEasyWindowTitle, 
    
      Gui, 1:Add, Text, x5 y+5, Window Class
      Gui, 1:Add, Edit, x+2 yp-3 w206 vEdtEasyWindowClass, 

      Gui, 1:Add, Text, x5 y+5, Control ClassNN
      Gui, 1:Add, Edit, x+2 yp-3 w196 vEdtEasyControlClass, 

      Gui, 1:Add, Text, x5 y+5, Control Text
      Gui, 1:Add, Edit, x+2 yp-3 w216 vEdtEasyControlText, 

      Gui, 1:Add, Text, x5 y+5, Mouse Position relative to Window
      Gui, 1:Add, Edit, x+2 yp-3 w110 vEdtEasyMousePosWin,

    Gui, 1:Tab, Advanced
      Gui, 1:Add, Text, x5 y28 Section, Pos. rel. to Window
      Gui, 1:Add, Edit, x+2 yp-3 w80 vEdtDataMousePosWin,

      Gui, 1:Add, Button, x+28 yp-1 vBtnShowList gBtnShowList -Wrap, % iif(ChkShowList,"<< Less Info","More Info >>")
      
      Gui, 1:Font, bold 
      Gui, 1:Add, GroupBox, xs w274 h114 -wrap, Control      
      Gui, 1:Font, normal 
        Gui, 1:Add, Text, xs+4 yp+18, Text
        Gui, 1:Add, Edit, x+2 yp-3 w104 vEdtControlText, 
      
        Gui, 1:Add, Text, x+5 yp+3, ClassNN
        Gui, 1:Add, Edit, x+2 yp-3 w91 vEdtControlClass, 
      
        Gui, 1:Add, Text, xs+4 y+5, Pos
        Gui, 1:Add, Edit, x+2 yp-3 w60 vEdtControlPos, 
      
        Gui, 1:Add, Text, x+5 yp+3, Size
        Gui, 1:Add, Edit, x+2 yp-3 w65 vEdtControlSize, 

        Gui, 1:Add, Text, x+5 yp+3, Hwnd
        Gui, 1:Add, Edit, x+2 yp-3 w59 vEdtControlHwnd, 
    
        Gui, 1:Add, Text, xs+4 y+3, List`nItems  
        Gui, 1:Add, Edit, x+4 r3 w237 vEdtListItems, 
        
      Gui, 1:Font, bold 
      Gui, 1:Add, GroupBox, xs w274 h492 -wrap vGrbAdvancedWindow, Window
      Gui, 1:Font, normal 
        Gui, 1:Add, Text, xs+4 yp+18 , Title
        Gui, 1:Add, Edit, x+2 yp-3 w244 vEdtWindowTitle, 
      
        Gui, 1:Add, Text, xs+4 y+5, Position
        Gui, 1:Add, Edit, x+2 yp-3 w88 vEdtWindowPos, 
      
        Gui, 1:Add, Text, x+5 yp+3, Size
        Gui, 1:Add, Edit, x+2 yp-3 w112 vEdtWindowSize,
      
        Gui, 1:Add, Text, xs+4 y+5, Class
        Gui, 1:Add, Edit, x+2 yp-3 w100 vEdtWindowClass, 
      
        Gui, 1:Add, Text, x+5 yp+3, Process
        Gui, 1:Add, Edit, x+2 yp-3 w94 vEdtWindowProcess, 
      
        Gui, 1:Add, Text, xs+4 y+5, Unique ID
        Gui, 1:Add, Edit, x+2 yp-3 w77 vEdtWindowUID, 
      
        Gui, 1:Add, Text, x+5 yp+3, Process ID
        Gui, 1:Add, Edit, x+2 yp-3 w80 vEdtWindowPID, 
    
        Gui, 1:Add, Text, xs+4 y+3, StatusbarText (Part# - Text)  
        Gui, 1:Add, ListBox, xs+4 y+2 r4 w266 vLsbStatusbarText, 
        
        Gui, 1:Add, Text, xs+4 y+3 Section, Fast Visible Text  
        Gui, 1:Add, Edit, y+2 r10 w132 vEdtWindowTextFastVisible, 

        Gui, 1:Add, Text, x+2 ys, Fast Hidden Text  
        Gui, 1:Add, Edit, y+2 r10 w132 vEdtWindowTextFastHidden, 

        Gui, 1:Add, Text, xs Section vTxtWindowTextSlowVisible, Slow Visible Text  
        Gui, 1:Add, Edit, y+2 r10 w132 vEdtWindowTextSlowVisible, 

        Gui, 1:Add, Text, x+2 ys vTxtWindowTextSlowHidden, Slow Hidden Text  
        Gui, 1:Add, Edit, y+2 r10 w132 vEdtWindowTextSlowHidden, 
      
    Gui, 1:Tab, Mouse
      Gui, 1:Add, Text, x5 y28, Data of/under mouse cursor and Positions relative to
      Gui, 1:Add, Text, x5 y+5, Window
      Gui, 1:Add, Edit, x+2 yp-3 w106 vEdtMousePosWin,
      
      Gui, 1:Add, Text, x+5 yp+3, Screen
      Gui, 1:Add, Edit, x+2 yp-3 w88 vEdtMousePosScreen,
    
      Gui, 1:Add, Text, x5 y+5, Active Window
      Gui, 1:Add, Edit, x+2 yp-3 w73 vEdtMousePosAWin,
    
      Gui, 1:Add, Text, x+5 yp+3, Cursor
      Gui, 1:Add, Edit, x+2 yp-3 w92 vEdtMousePointer,
    
      Gui, 1:Add, Text, x5 y+5, RGB Color
      Gui, 1:Add, Edit, x+2 yp-3 w95 vEdtMouseColorRGB,
    
      Gui, 1:Add, Text, x+5 yp+3, RGB Color
      Gui, 1:Add, Edit, x+2 yp-3 w72 vEdtMouseColorHex,
        
      Gui, 1:Font, bold 
      Gui, 1:Add, GroupBox, x5 y+10 Section w274 h305 -wrap, Color Picker
      Gui, 1:Font, normal 
        Gui, 1:Add, Text, xs+4 yp+18, Dimension:
        Gui, 1:Add, ComboBox, x+5 yp-3 w55 vCbbColorPickDim gRefreshControlStates, 1x1|3x3||5x5|7x7|9x9|15x15
        Gui, 1:Add, Radio, x+5 yp+3 vRadColorPick gRefreshControlStates, RGB
        Gui, 1:Add, Radio, x+5 Checked gRefreshControlStates, BGR

        Gui, 1:Add, Text, xs+4 y+5 w10 h5 Section,        ;only to create a gap to the color matix
        
        Loop, 15 {
            Row = %A_Index%
            dy := (Row = 8 OR Row = 9) ? "y+2" : ""
            Gui, 1:Add, Progress, xs+5 %dy% w17 h17 vPgbColorPicker%Row%_1,
            Loop, 14 {
                Column := A_Index + 1
                dx := (A_Index = 7 OR A_Index = 8) ? 2 : 0
                Gui, 1:Add, Progress, x+%dx% w17 h17 vPgbColorPicker%Row%_%Column%,
              }
          }

    Gui, 1:Tab, Options

      Gui, 1:Add, Text, x5 y25 Section , Show window and control data for
      Gui, 1:Add, Radio, xs y+5 vRadWindow gRefreshControlStates, Active Window
      Gui, 1:Add, Radio, xs y+5 Checked gRefreshControlStates, Window under Mouse Cursor

      Gui, 1:Add, Button, x+55 y25 gBtnShowOptions1, Advanced`nOptions

      Gui, 1:Add, Text, xs y+25, Show control data for
      Gui, 1:Add, Radio, xs y+5 vRadControl gRefreshControlStates, Focused Control in Window
      Gui, 1:Add, Radio, xs y+5 Checked gRefreshControlStates, Control under Mouse Cursor

      Gui, 1:Add, Checkbox, xs y+15 vChkTtpMaster gRefreshControlStates Checked%ChkTtpMaster%, Show tooltip at cursor
      Gui, 1:Add, Button, x+3 yp-5 gBtnShowOptions2, Data Filter Options

      Gui, 1:Add, Text, xs y+12 , Draw a rectangle around
      Gui, 1:Add, Checkbox, x+5 vChkDrawRectCtrl gChkDrawRectCtrl Checked%ChkDrawRectCtrl%, control (red)
      Gui, 1:Add, Checkbox, y+5 vChkDrawRectWin gChkDrawRectWin Checked%ChkDrawRectWin%, window (green)
      
      ExportOptions =           ;collect all checkboxes, so they can be parsed in a loop
        (LTrim Join,
          ChkExportMousePosScreen,ChkExportMousePosAWin,ChkExportMousePosWin
          ChkExportMousePointer,ChkExportMouseColorRGB,ChkExportMouseColorHex
          ChkExportCtrlText,ChkExportCtrlClass,ChkExportCtrlPos
          ChkExportCtrlSize,ChkExportCtrlListItems,ChkExportWinTitle,ChkExportWinPos
          ChkExportWinSize,ChkExportWinClass,ChkExportWinProcess
          ChkExportWinUID,ChkExportWinPID,ChkExportWinStatusText
          ChkExportWinText,ChkExportLargeList
        )
       
      Gui, 1:Add, Text, xs y+17 ,Log Data to File  
      Gui, 1:Add, Button, x+5 yp-5 gBtnShowOptions3, Log Options
      Gui, 1:Add, Button, x+5 vBtnSaveExport gBtnSaveExport, Save to file 
      Gui, 1:Add, Edit, xs w255 vEdtExportFile, %EdtExportFile%
      Gui, 1:Add, Button, x+2 yp-1 gBtnBrowseExportFile,... 
    Gui, 1:Tab, Info
      Gui, 1:Add, Text, x5 y25 Section ,
        (
This GUI will reveal information on windows, controls, etc.,
but only when this GUI is not the active window.

- To start/stop updating data press the Auto-Update
  toggle Hotkey (default: Pause).
- To put the content of a field on the clipboard click with
  the left mouse button into the field.
- To toggle the always-on-top state of this GUI use the
  middle mouse button.
        )  
      Gui, 1:Add, Button, x70 y+5 vBtnShowInfo gBtnShowInfo, More Information - Please read
      
  Gui, 1:Tab
  GuiControl, Choose, Tab1, %Tab1%   

  Gui, 1:Add, Radio, x290 y2 Section vRadList1 gRadList, Info on all Controls of one window
  Gui, 1:Add, Radio, x+5 vRadList2 gRadList, Info on all Windows    (Click radio buttons again to refresh list)
  Gui, 1:Add, ListView, xs y+5 w370 h339 vLV1 Count200
    , Z or Stack Order|Unique ID or Handle|Window PID|Class(NN)|Process Name|Hidden|Title or Text|X|Y|Width|Height|Style|ExStyle|Selected|CurrentCol|CurrentLine|LineCount|Choice|Tab|Enabled|Checked

  ;Apply settings
  If RadWindow = 1
      GuiControl, 1:, RadWindow, 1
  If RadControl = 1
      GuiControl, 1:, RadControl, 1
  If RadColorPick = 1
      GuiControl, 1:, RadColorPick, 1
  GuiControl, 1:, RadList%SelectedRadList%, 1
  GuiControl, 1:ChooseString, CbbColorPickDim, %CbbColorPickDim%
  StringSplit, Dim, CbbColorPickDim, x    ;prepare color picker dimensions
  Dim = %Dim1%
  HalfDim := Dim // 2 + 1

  GoSub, ShowHideList 

  If Gui1AOTState {
      Gui, 1:+AlwaysOnTop
      TitleExtension = - *AOT*
    }
  
  If ChkHideGui
      ShowOption = Hide
  Else        
      ShowOption = NoActivate
  Gui, 1:Show, %Gui1Pos% %ShowOption% AutoSize , %ScriptName% %TitleExtension%
  If !ChkHideGui
      GuiIsVisible := True
Return

;###############################################################################
;###   prepare hotkey or mouse interaction with GUI   ##########################
;###############################################################################

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd){       ;Copy-On-Click for controls
    global 
    local Content 

    If A_GuiControl is space                     ;Control is not known
        Return
    If A_GuiControl not contains Edt,Lsb,Pgb     ;Control is something else then edit, listbox or progressbar control
        Return
    
    ;Check for full text vars
    Fulltext = %A_GuiControl%Full
    If (%Fulltext% <> "")
        Content := %Fulltext%
    Else {
        If A_GuiControl contains Pgb                 ;get value from color pickers (progressbar)
            Content := %A_GuiControl%
        Else
            GuiControlGet, Content, , %A_GuiControl% ;get controls content
      }
    
    If Content is space                          ;content is empty or couldn't be retrieved
        Return
  
    If A_GuiControl contains Class               ;change data for specific fields
        Content = %Content%
    Else If A_GuiControl contains UID
        Content = ahk_id %Content%
    Else If A_GuiControl contains PID
        Content = ahk_pid %Content%
    Else If A_GuiControl contains Process
        Content = ahk_exe %Content%
    Else If A_GuiControl contains Pos,Size
      {
        StringReplace, Content, Content, x
        StringReplace, Content, Content, y
        StringReplace, Content, Content, w
        StringReplace, Content, Content, h
        StringReplace, Content, Content, %A_Space%, `,%A_Space%
      }
    Else If A_GuiControl contains Pgb
        Content = 0x%Content%
    ClipBoard = %Content%                   ;put content in clipboard 
  
    If ChkShowInfoToolTip {
        If (StrLen(Content) > 200){             ;give feedback (limit size to 200 characters)
            StringLeft, Content, Content, 200 
            Content = %Content% ...
          }
          ToolTip("ClipBoard = " Content)
      }
  }

WM_ACTIVATE(wParam, lParam, msg, hwnd){
    Global UpdateIsStopped, ChkHideGui
    If (wParam  AND !ChkHideGui) 
        UpdateIsStopped := False 
  }

UpdateOnClick:
  UpdateIsStopped := False    ;needs to be set if large list had set it to true
  GoSub, UpdateInfo           ;collect data
Return

PauseAction:                      ;user has pressed toogle auto-update hotkey
  If ChkHideGui {                 ;user wants hide/show toggle
      UpdateIsStopped := False    ;needs to be set if large list had set it to true
      If GuiIsVisible {
          Gui, 1:Hide 
      }Else{
          SetTimer, UpdateInfo, Off ;turn timer off, to collect only once data
          UpdateIsStopped := False  ;turn update on
          UpdateAfterPause := True  ;set flag to update all
          GoSub, UpdateInfo         ;collect data
          UpdateAfterPause := False ;turn off flag to update all
          UpdateIsStopped := True   ;turn update off
          SetTimer, UpdateInfo, %CbbUpdateInterval% ;turn timer back on
          GoSub, GuiShow            ;bring GUI to front
        }
      GuiIsVisible := not GuiIsVisible
      If ChkShowInfoToolTip
          ToolTip(iif(UpdateIsStopped,"Press " HtkPauseAction " to hide GUI","Wait for " HtkPauseAction " key to`nupdate data and show GUI"),2000)
  }Else {
      UpdateIsStopped := not UpdateIsStopped  ;toggle update status and show feedback
      If UpdateIsStopped                      ;when stopped, bring GUI to front
          GoSub, GuiShow
      If ChkShowInfoToolTip                   ;give feedback
          ToolTip(Scriptname "`n----------------------------`nUpdate data : " iif(UpdateIsStopped,"Off","On"))
    }

  GoSub, ToogleExportActions
  GoSub, PrepareFrameDraw  ;create or destroy frame drawing objects
Return

ToogleExportActions:
  ;Disable Export Save button during update 
  GuiControl, 1:Enable%UpdateIsStopped%, BtnSaveExport

  ;Enable Export Save hotkey when update is stopped and hotkey wanted 
  If (ChkUseSaveHotkey AND UpdateIsStopped)
      HotKey, #s, , On
  Else                 ; ... otherwise de-activate Export Save hotkey
      HotKey, #s, , Off UseErrorLevel
Return

PrepareFrameDraw:           ;create or destroy frame drawing objects
  If (UpdateIsStopped OR (ChkDrawRectCtrl = 0 AND ChkDrawRectWin = 0)){
      GoSub, CleanUpFrameGui
  ;create GUI Only if Gui doesn't exist yet and is needed.
  }Else If ( (ChkDrawRectCtrl OR ChkDrawRectWin) And not FrameGUIExists ){
      FrameGUIExists := True
      ;create transparent GUI covering the whole screen 
      Gui, 2:+Lastfound +AlwaysOnTop
      Gui, 2:Color, Black 
      WinSet, TransColor, Black
      Gui, 2: -Caption +ToolWindow
      Gui, 2:Show, x0 y0 w%ScreenWidth% h%ScreenHeight%, FrameDrawGUI2
      UniqueIDGui2 := WinExist()

      ;create draw objects for that window 
      CreateDrawHandles(UniqueIDGui2, ScreenWidth, ScreenHeight, frame_cc, frame_cw) 
    }
  ;set previous control/window to nothing, so that the frames start to draw immediatly
  PreviousControlID = 
  PreviousWindowID =
Return

CleanUpFrameGui:
  DeleteObject( h_brushC )       ;destroy objects 
  DeleteObject( h_brushW ) 
  DeleteObject( h_region ) 
  DeleteObject( hbm_buffer ) 
    
  DeleteDC( hdc_frame ) 
  DeleteDC( hdc_buffer ) 
  Gui, 2:Destroy                 ;destroy gui
  FrameGUIExists := False
  ToolTip, , , , 2               ;remove control frame tooltip
  ToolTip, , , , 3               ;remove window frame tooltip
Return

;###############################################################################
;###   Interactions with GUI controls   ########################################
;###############################################################################

Tab1:
  GuiControlGet, Tab1, 1:                ;get current value
  GoSub, ClearNotUsedControls
  If (Tab1 = 1){                            ;adjust tab height based on visible tab
      GuiControl, 1:Move, Tab1, h145
  }Else If (Tab1 = 2) {  
      GuiControl, 1:Move, Tab1, h570
  }Else If (Tab1 = 3) {  
      GuiControl, 1:Move, Tab1, h430
  }Else If (Tab1 = 4) {
      GuiControl, 1:Move, Tab1, h274
  }Else If (Tab1 = 5) {  
      GuiControl, 1:Move, Tab1, h174
    }
  ChkShowList := False
  GoSub, ShowHideList
  Gui, 1:Show, AutoSize                         ;autosize GUI
return

ClearNotUsedControls:
  If (Tab1 <> 2) {  
      GuiControl, 1:, EdtListItems, >>>not updated<<<
      GuiControl, 1:, LsbStatusbarText, |>>>not updated<<<
      GuiControl, 1:, EdtWindowTextFastVisible, >>>not updated<<<
      GuiControl, 1:, EdtWindowTextSlowVisible, >>>not updated<<<
      GuiControl, 1:, EdtWindowTextFastHidden, >>>not updated<<<
      GuiControl, 1:, EdtWindowTextSlowHidden, >>>not updated<<<
    }
  If (Tab1 <> 3) {  
      Loop, %Dim% {
          Row := A_Index + 8 - HalfDim
          Loop, %Dim% {
              y++
              Control := "PgbColorPicker" (A_Index + 8 - HalfDim) "_" Row 
              GuiControl, 1:+BackgroundECE9D8,%Control% 
            }
        }
      
    }
Return

ShowHideList:
  GuiControl, 1:, BtnShowList, % iif(ChkShowList,"<< Less Info","More Info >>") 
  GuiControl, 1:Show%ChkShowList%, RadList1      ;show/hide controls
  GuiControl, 1:Show%ChkShowList%, RadList2
  GuiControl, 1:Show%ChkShowList%, LV1          ;show/hide large list
Return

BtnShowList:
  ChkShowList := not ChkShowList
  GoSub, ShowHideList
  Gui, 1:Show, AutoSize                         ;autosize GUI
  If ChkShowList                                    
      GoSub, GetDataForLargeList      ;get data 
Return

RadList:
  LV_Delete()                                      ;clear controls
  StringRight, SelectedRadList, A_GuiControl, 1    ;get which got pressed
  Loop, 2                                          ;deactivate the other
      If (A_Index <> SelectedRadList)
          GuiControl, 1:, RadList%A_Index%, 0
  Gui, 1:Submit, NoHide
  GoSub, GetDataForLargeList                       ;get data 
Return

GetDataForLargeList:
  If (RadList1 = 1){                   ;get data depending on choice
      WindowUniqueID = %EdtWindowUID%
      If EdtWindowUID is not space
          GoSub, GetControlListInfo
    }
  Else
      GoSub, GetAllWindowsInfo   
Return

RefreshControlStates:
  Gui, 1:Submit, NoHide                   ;get current values of all controls
  StringSplit, Dim, CbbColorPickDim, x    ;prepare color picker dimensions
  Dim = %Dim1%
  HalfDim := Dim // 2 + 1
  Loop, 15 {
      Row = %A_Index%
      Loop, 15
          GuiControl, 1:+BackgroundDefault ,PgbColorPicker%Row%_%A_Index%
    }
Return

ChkDrawRectCtrl:
  GuiControlGet, ChkDrawRectCtrl, 1:      ;get current value
  GoSub, PrepareFrameDraw
  ToolTip, , , , 2
Return

ChkDrawRectWin:
  GuiControlGet, ChkDrawRectWin, 1:       ;get current value
  GoSub, PrepareFrameDraw
  ToolTip, , , , 3
Return

;###############################################################################
;###   GUI actions   ###########################################################
;###############################################################################

GuiSize:
  If (A_EventInfo = 0) {   ;restored, or resized
      GuiControl, 1:Move, Tab1, h%A_GuiHeight% 
      w := A_GuiWidth - 290
      h := A_GuiHeight - 22
      GuiControl, 1:Move, LV1, w%w% h%h%
      h -= 143
      GuiControl, 1:Move, GrbAdvancedWindow, h%h%
      h := (h - 218) / 2
      GuiControl, 1:Move, EdtWindowTextFastVisible, h%h%
      GuiControl, 1:Move, EdtWindowTextFastHidden, h%h%
      y := A_GuiHeight - h - 24
      GuiControl, 1:Move, TxtWindowTextSlowVisible, y%y%
      GuiControl, 1:Move, TxtWindowTextSlowHidden, y%y%
      y += 15
      GuiControl, 1:Move, EdtWindowTextSlowVisible, y%y% h%h%
      GuiControl, 1:Move, EdtWindowTextSlowHidden, y%y% h%h%
      If (LastEventInfo = 1){    ;Gui got restored
          ;start updating again
          UpdateIsStopped := False
          ;reactivate frame
          GoSub, PrepareFrameDraw
        }
  }Else If (A_EventInfo = 1) {   ;minimized
      ;stop updating
      UpdateIsStopped := True
      ;remove frames
      GoSub, PrepareFrameDraw
    }
  LastEventInfo = %A_EventInfo%
Return

WriteIni:
  Gui, 1:Submit, NoHide
  WinGetPos, PosX, PosY, SizeW, SizeH, %WinNameGui1%
  Loop, 2
      If (RadList%A_Index% = 1)
          IniWrite, %A_Index%    , %IniFile%, Settings, SelectedRadList
  If (PosX > -4 and PosY > -4)
      IniWrite, x%PosX% y%PosY%      , %IniFile%, Settings, Gui1Pos
  IniWrite, %Gui1AOTState%       , %IniFile%, Settings, Gui1AOTState
  IniWrite, %Tab1%               , %IniFile%, Settings, Tab1
  IniWrite, %RadWindow%          , %IniFile%, Settings, RadWindow
  IniWrite, %RadControl%         , %IniFile%, Settings, RadControl
  IniWrite, %ChkShowList%        , %IniFile%, Settings, ChkShowList
  IniWrite, %HtkPauseAction%     , %IniFile%, Settings, HtkPauseAction
  IniWrite, %ChkCopyToCB%        , %IniFile%, Settings, ChkCopyToCB
  IniWrite, %ChkHideGui%         , %IniFile%, Settings, ChkHideGui
  IniWrite, %ChkUseSaveHotkey%   , %IniFile%, Settings, ChkUseSaveHotkey
  
  Loop, Parse, ExportOptions, `,
      IniWrite, % %A_LoopField%  , %IniFile%, Export  , %A_LoopField%
  IniWrite, %EdtExportFile%      , %IniFile%, Export  , EdtExportFile          
  IniWrite, %ChkExportAutoNumber%, %IniFile%, Export  , ChkExportAutoNumber
  IniWrite, %ChkExportAppend%    , %IniFile%, Export  , ChkExportAppend
  IniWrite, %ChkShowInfoToolTip% , %IniFile%, Advanced, ChkShowInfoToolTip  
  IniWrite, %ChkDrawRectCtrl%    , %IniFile%, Advanced, ChkDrawRectCtrl
  IniWrite, %ChkDrawRectWin%     , %IniFile%, Advanced, ChkDrawRectWin
  IniWrite, %ChkTtpMaster%       , %IniFile%, Advanced, ChkTtpMaster         
  IniWrite, %ChkTtpMSPos%        , %IniFile%, Advanced, ChkTtpMSPos         
  IniWrite, %ChkTtpMWPos%        , %IniFile%, Advanced, ChkTtpMWPos         
  IniWrite, %ChkTtpMColor%       , %IniFile%, Advanced, ChkTtpMColor        
  IniWrite, %ChkTtpCClass%       , %IniFile%, Advanced, ChkTtpCClass        
  IniWrite, %ChkTtpCPos%         , %IniFile%, Advanced, ChkTtpCPos          
  IniWrite, %ChkTtpCSize%        , %IniFile%, Advanced, ChkTtpCSize         
  IniWrite, %ChkTtpWClass%       , %IniFile%, Advanced, ChkTtpWClass        
  IniWrite, %ChkTtpWTitle%       , %IniFile%, Advanced, ChkTtpWTitle        
  IniWrite, %CbbUpdateInterval%  , %IniFile%, Advanced, CbbUpdateInterval   
  IniWrite, %CbbColorPickDim%    , %IniFile%, Advanced, CbbColorPickDim
  IniWrite, %RadColorPick%       , %IniFile%, Advanced, RadColorPick
  IniWrite, %ChkAutoStartUpdate% , %IniFile%, Advanced, ChkAutoStartUpdate
  IniWrite, %CbbHtkUpdate%       , %IniFile%, Advanced, CbbHtkUpdate
  IniWrite, %RadUpdateOnClick%   , %IniFile%, Advanced, RadUpdateOnClick
  IniWrite, %RadUpdateAuto%      , %IniFile%, Advanced, RadUpdateAuto
Return

GuiClose:
GuiEscape:
  GoSub, WriteIni
  ExitApp
Return

;###############################################################################
;###   GUI for information text   ##############################################
;###############################################################################

BtnShowInfo:
  GuiControl, 1:Disable, BtnShowInfo 
  Gui, 3:+Owner1 +AlwaysOnTop +ToolWindow +Resize
  Gui, 3:Font, s8, MS Sans Serif
  Gui, 3:Add, Button, gCloseInfoGui, Close
  Gui, 3:Add, Edit, w600 h400 vEdtInfoText, %InformationText%
  Gui, 3:Show,, Info - %ScriptName%
Return

3GuiClose:
3GuiEscape:
CloseInfoGui:
  GuiControl, 1:Enable, BtnShowInfo 
  Gui, 3:Destroy
Return

3GuiSize:
  w := A_GuiWidth - 20
  h := A_GuiHeight - 45
  GuiControl, 3:Move, EdtInfoText, w%w% h%h%
Return

;###############################################################################
;###   GUI for options   #######################################################
;###############################################################################

BtnShowOptions1:
  ChangeToTab = 1
  GoSub, BtnShowOptions
Return
BtnShowOptions2:
  ChangeToTab = 2
  GoSub, BtnShowOptions
Return
BtnShowOptions3:
  ChangeToTab = 3
  GoSub, BtnShowOptions
Return
BtnShowOptions:
  UpdateIsStopped := True
  Hotkey, IfWinNotActive, ahk_id %Gui1UniqueID%
  Hotkey, ~%CbbHtkUpdate%, Off
  Hotkey, IfWinNotActive
  
  Gui, 1:+Disabled
  Gui, 4:+Owner1 +AlwaysOnTop +ToolWindow
  Gui, 4:Font, s8, MS Sans Serif

  Gui, 4:Add, Tab, Section w300 h390 vTab2 AltSubmit -Wrap, Advanced|ToolTip|Log to File 
    Gui, 4:Tab, Advanced
      Gui, 4:Add, GroupBox, w275 h73, Update data
      Gui, 4:Add, Radio, xp+10 yp+22 Checked%RadUpdateOnClick% vRadUpdateOnClick gRadUpdate, on click with
      Gui, 4:Add, ComboBox, x+5 yp-3 w80 vCbbHtkUpdate, LButton|MButton||RButton
      Gui, 4:Add, Radio, x32 y+8 Checked%RadUpdateAuto% vRadUpdateAuto gRadUpdate, automatically every milliseconds:
      Gui, 4:Add, ComboBox, x+5 yp-3 w50 vCbbUpdateInterval, 100||200|300|400|500|1000|2000

      Gui, 4:Add, Checkbox, x22 y+20 vChkChangePauseHotkey gChkChangePauseHotkey, Change hotkey to toogle auto-update (default: Pause)
      Gui, 4:Add, Hotkey, xp+15 y+5 w150 vHtkPauseAction gHtkPauseAction Disabled, %HtkPauseAction%
    
      Gui, 4:Add, Checkbox, xp-15 y+5 vChkHideGui Checked%ChkHideGui%, Hide/Show GUI with above hotkey`;`nbefore the GUI is shown data will be collected  
      Gui, 4:Add, Checkbox, y+5 vChkAutoStartUpdate Checked%ChkAutoStartUpdate%, Start updating of data again when Gui gets inactive`nafter auto-update has been turned off. 
      Gui, 4:Add, Checkbox, y+5 vChkCopyToCB Checked%ChkCopyToCB%, Copy data to clipboard with left click on data field  

      Gui, 4:Add, Text, y+20, When update is turned off:
      Gui, 4:Add, Checkbox, vChkUseSaveHotkey Checked%ChkUseSaveHotkey%, Use Win+S as hotkey to log data to file
                                                         
      Gui, 4:Add, Checkbox, y+20 Section vChkShowInfoToolTip Checked%ChkShowInfoToolTip%, Show info-tooltips
    Gui, 4:Tab, ToolTip
      Gui, 4:Add, Text, , Check which data you want to see next to the mouse cursor
      Gui, 4:Add, Checkbox, vChkTtpMSPos Checked%ChkTtpMSPos%, Mouse position on screen *
      Gui, 4:Add, Checkbox, vChkTtpMWPos Checked%ChkTtpMWPos%, Mouse position on window
      Gui, 4:Add, Checkbox, vChkTtpMColor Checked%ChkTtpMColor%, Color under mouse pointer
      Gui, 4:Add, Checkbox, vChkTtpCClass Checked%ChkTtpCClass%, Control class under mouse pointer *
      Gui, 4:Add, Checkbox, vChkTtpCPos Checked%ChkTtpCPos%, Control position
      Gui, 4:Add, Checkbox, vChkTtpCSize Checked%ChkTtpCSize%, Control size
      Gui, 4:Add, Checkbox, vChkTtpWClass Checked%ChkTtpWClass%, Window class *                
      Gui, 4:Add, Checkbox, vChkTtpWTitle Checked%ChkTtpWTitle%, Window title *                         
      Gui, 4:Add, Text, , (* = available when Gui is hidden)
    Gui, 4:Tab, Log to File
      Gui, 4:Add, GroupBox, Section w274 h70 , Log this Mouse Data
        Gui, 4:Add, Checkbox, vChkExportMousePosScreen Checked%ChkExportMousePosScreen% xs+4 yp+18, Position on Screen 
        Gui, 4:Add, Checkbox, vChkExportMousePosAWin   Checked%ChkExportMousePosAWin%   xs+125 yp, Pos. rel. to active Window 
        Gui, 4:Add, Checkbox, vChkExportMousePosWin    Checked%ChkExportMousePosWin%    xs+4 y+5, Pos. rel. to Window 
        Gui, 4:Add, Checkbox, vChkExportMousePointer   Checked%ChkExportMousePointer%   xs+125 yp, Cursor Style 
        Gui, 4:Add, Checkbox, vChkExportMouseColorRGB  Checked%ChkExportMouseColorRGB%  xs+4 y+5, RGB Color 
        Gui, 4:Add, Checkbox, vChkExportMouseColorHex  Checked%ChkExportMouseColorHex%  xs+125 yp, Hex Color 
      Gui, 4:Add, GroupBox, xs w274 h75 , Log this Control Data 
        Gui, 4:Add, Checkbox, vChkExportCtrlText  Checked%ChkExportCtrlText%            xs+4 yp+18, Control Text 
        Gui, 4:Add, Checkbox, vChkExportCtrlClass Checked%ChkExportCtrlClass%           xs+125 yp, Control ClassNN 
        Gui, 4:Add, Checkbox, vChkExportCtrlPos   Checked%ChkExportCtrlPos%             xs+4 y+5, Control Position 
        Gui, 4:Add, Checkbox, vChkExportCtrlSize  Checked%ChkExportCtrlSize%            xs+125 yp, Control Size 
        Gui, 4:Add, Checkbox, vChkExportCtrlListItems  Checked%ChkExportCtrlListItems%  xs+4 y+5, Control List Items 
      Gui, 4:Add, GroupBox, xs w274 h110 , Log this Window Data 
        Gui, 4:Add, Checkbox, vChkExportWinTitle       Checked%ChkExportWinTitle%       xs+4 yp+18, Window Title 
        Gui, 4:Add, Checkbox, vChkExportWinPos         Checked%ChkExportWinPos%         xs+4 y+5, Window Position 
        Gui, 4:Add, Checkbox, vChkExportWinSize        Checked%ChkExportWinSize%        xs+125 yp, Window Size 
        Gui, 4:Add, Checkbox, vChkExportWinClass       Checked%ChkExportWinClass%       xs+4 y+5, Window Class 
        Gui, 4:Add, Checkbox, vChkExportWinProcess     Checked%ChkExportWinProcess%     xs+125 yp, Window Process 
        Gui, 4:Add, Checkbox, vChkExportWinUID         Checked%ChkExportWinUID%         xs+4 y+5, Window Unique ID 
        Gui, 4:Add, Checkbox, vChkExportWinPID         Checked%ChkExportWinPID%         xs+125 yp, Win Process ID 
        Gui, 4:Add, Checkbox, vChkExportWinStatusText  Checked%ChkExportWinStatusText%  xs+4 y+5, Statusbar Text 
        Gui, 4:Add, Checkbox, vChkExportWinText        Checked%ChkExportWinText%        xs+125 yp, Window Text 
    
      Gui, 4:Add, Checkbox, xs y+16 vChkExportLargeList  Checked%ChkExportLargeList%, Log Large List         Check:
    
      Gui, 4:Add, Button, x+2 yp-5 gBtnExportCheckAll, All 
      Gui, 4:Add, Button, x+2 gBtnExportCheckNone , None 
      Gui, 4:Add, Button, x+2 gBtnExportCheckReverse , Rev
    
      Gui, 4:Add, Text, xs y+5, Additional log options:
      Gui, 4:Add, Checkbox, y+5 Section vChkExportAutoNumber gChkExportAutoNumber Checked%ChkExportAutoNumber%, Replace "#" in filename with Numbers
      Gui, 4:Add, Checkbox, y+5 vChkExportAppend gChkExportAppend Checked%ChkExportAppend%, Append data to file
  Gui, 4:Tab

  Gui, 4:Add, Button, xm gApplyOptions, Apply Options
  Gui, 4:Add, Button, x+5 g4GuiClose, Cancel

  If RadUpdateOnClick {
      GuiControl, 4:Disable, ChkChangePauseHotkey
      GuiControl, 4:Disable, ChkHideGui
      GuiControl, 4:Disable, ChkAutoStartUpdate
    }
  GuiControl, 4:ChooseString, CbbHtkUpdate, %CbbHtkUpdate%
  GuiControl, 4:ChooseString, CbbUpdateInterval, %CbbUpdateInterval%
  GoSub, ChkExportAutoNumber
  GoSub, ChkExportAppend
  GuiControl, 4:Choose, Tab2, %ChangeToTab%

  Gui, 4:Show,, Options - %ScriptName%
Return

RadUpdate:
  If (A_GuiControl = "RadUpdateOnClick"){
      GuiControl, 4:, RadUpdateAuto, 0
      GuiControl, 4:, ChkChangePauseHotkey, 0
      GuiControl, 4:Disable, ChkChangePauseHotkey
      GuiControl, 4:Disable, HtkPauseAction
      GuiControl, 4:, ChkHideGui, 0
      GuiControl, 4:Disable, ChkHideGui
      GuiControl, 4:, ChkAutoStartUpdate, 0
      GuiControl, 4:Disable, ChkAutoStartUpdate
  }Else{
      GuiControl, 4:, RadUpdateOnClick, 0
      GuiControl, 4:Enable, ChkChangePauseHotkey
      GuiControl, 4:Enable, ChkHideGui
      GuiControl, 4:Enable, ChkAutoStartUpdate
      GuiControl, 4:, ChkAutoStartUpdate, 1
    }
Return

ApplyOptions:
  Gui, 4:Submit
  If ChkCopyToCB
      OnMessage( WM_LBUTTONDOWN, "WM_LBUTTONDOWN" )   ;activate copy-on-click
  Else
      OnMessage( WM_LBUTTONDOWN, "" )                 ;deactivate copy-on-click
  If ChkAutoStartUpdate
      OnMessage(WM_ACTIVATE, "WM_ACTIVATE")       ;activate auto-start updating at Gui inactivity
  Else
      OnMessage(WM_ACTIVATE, "" )                 ;deactivate auto-start updating
  If RadUpdateAuto {
      SetTimer, UpdateInfo, %CbbUpdateInterval%
  }Else{
      SetTimer, UpdateInfo, Off
      Hotkey, IfWinNotActive, ahk_id %Gui1UniqueID%
      Hotkey, ~%CbbHtkUpdate%, UpdateOnClick, On
      Hotkey, IfWinNotActive
    }
  GoSub, PauseAction  
4GuiClose:
4GuiEscape:
  UpdateIsStopped := False
  Gui, 1:-Disabled
  Gui, 4:Destroy
Return

ChkChangePauseHotkey:
  GuiControlGet, ChkChangePauseHotkey, 4:      ;get current value
  If ChkChangePauseHotkey {
      ;de-activate current auto-update toggle hotkey
      HotKey, %HtkPauseAction%, Off
      GuiControl, 4:Enable, HtkPauseAction
  }Else
      GoSub, HtkPauseAction
Return

HtkPauseAction:
  GuiControlGet, HtkPauseAction, 4:      ;get current value
  If HtkPauseAction {
      If HtkPauseAction in ^,+,!         ;don't react on simple modifiers
          return
      ;activate new auto-update toggle hotkey
      HotKey, %HtkPauseAction%, PauseAction, On
      GuiControl, 4:Disable, HtkPauseAction
      GuiControl, 4:, ChkChangePauseHotkey, 0
  }Else{
      GuiControl, 4:, ChkChangePauseHotkey, 1
      GuiControl, 4:Enable, HtkPauseAction
      ToolTip("You need to specify a hotkey", 2000)          
    }
Return

BtnExportCheckAll:
  Loop, Parse, ExportOptions, `,
      GuiControl, 4:, %A_LoopField%, 1
Return
BtnExportCheckNone:
  Loop, Parse, ExportOptions, `,
      GuiControl, 4:, %A_LoopField%, 0
Return
BtnExportCheckReverse:
  Gui, 1:Submit, NoHide
  Loop, Parse, ExportOptions, `,
      GuiControl, 4:, %A_LoopField%, % not %A_LoopField%
Return
ChkExportAutoNumber:
  Gui, 4:Submit, NoHide
  If ChkExportAutoNumber
      GuiControl, 4:Disable, ChkExportAppend
  Else
      GuiControl, 4:Enable, ChkExportAppend   
Return
ChkExportAppend:
  Gui, 4:Submit, NoHide
  If ChkExportAppend
      GuiControl, 4:Disable, ChkExportAutoNumber
  Else
      GuiControl, 4:Enable, ChkExportAutoNumber   
Return

;###############################################################################
;###   getting the data    #####################################################
;###############################################################################

UpdateInfo:
  If UpdateIsStopped
      Return
  
  If (WinActive("A") = Gui1UniqueID )    ;don't update when window becomes the active one
      Return
 
  If (Tab1 > 3 )    ;don't update when tab 4 or tab 5 are visible
      Return
      
  SetBatchLines, -1
  
  ;get mouse pos and make sure mouse is not on frames or tooltips or on it's own gui
  MouseIsOnFrameGUI := False
  GoSub, CheckForFramesAndTipsAndGetMousePos
  If MouseIsOnFrameGUI
      Return
  
  GoSub, SetWhichWindow
  GoSub, SetWhichControl

  If (ChkHideGui And ChkTtpMaster And !GuiIsVisible)   ;update only small info when gui is hidden if tool tips are wanted
      GoSub, UpdateMinimumInfo
  Else If (!ChkHideGui Or UpdateAfterPause) ;update only when gui not set to HideGui or if Pause is release and one update is needed
      GoSub, UpdateAllInfo

  ;draw frames if wanted
  If ( ( ChkDrawRectCtrl OR ChkDrawRectWin )                           ;user wants to see at least one of the frames
     AND PreviousControlID <> ControlID                                ;the control has changed
     AND StatusDrawFrame ){                                             ;AND the Mouse is not on the active window which should be drawn 
      If not FrameGUIExists         ;create frame gui if it had been destroyed, e.g. by viewing the large list
          GoSub, PrepareFrameDraw
      DrawFrameAroundControl(ControlID, WindowUniqueID, frame_t)
     } 
  ;memorize IDs
  PreviousControlID = %ControlID%
  PreviousWindowID = %WindowID%

  If UpdateIsStopped {         ;when update stopped within this run, behave as if toggle hotkey was pressed 
      GoSub, ToogleExportActions      
      GoSub, PrepareFrameDraw  ;create or destroy frame drawing objects
      GoSub, GuiShow
    }
Return

;check if frames or tool tips are under mouse pointer
CheckForFramesAndTipsAndGetMousePos:
  ;get mouse positions relative to screen
  CoordMode, Mouse, Screen  
  MouseGetPos, MouseScreenX, MouseScreenY, MouseWindowUID, MouseControlID  
  WinGetClass, WindowClass, ahk_id %MouseWindowUID%
  WinGetTitle, WindowTitle, ahk_id %MouseWindowUID% 
  If ( MouseWindowUID = UniqueIDGui2                    ;if window is frame gui
       OR  MouseWindowUID = Gui1UniqueID                ;or real gui
       OR (WindowClass = "tooltips_class32"                ;or window is tooltip
           AND ( WindowTitle = PreviousControlID               ;and has the title of the last control
                 OR WindowTitle = PreviousWindowID                 ;or has the title of the last window
                 OR InStr(WindowTitle,Scriptname)) ) ) ;{          ;or has a title that contains the script name, then it might be one of the info tooltips   
      MouseIsOnFrameGUI := True
  If (MouseIsOnFrameGUI AND WindowTitle = PreviousControlID) ;remove control frame tooltip if mouse is on it, to be able to see screen below
      ToolTip, , , , 2               
Return

;set UID of window for which the following data should be retrieved
SetWhichWindow:
  StatusDrawFrame := True
  If (RadWindow = 1){                      ;for active window
      WinGet, WindowUniqueID, ID, A
      If (WindowUniqueID <> MouseWindowUID)  ;mouse is not in active window, don't redraw frames
          StatusDrawFrame := False
  }Else                                    ;for window under mouse pointer
      WindowUniqueID = %MouseWindowUID%
Return
 
;set control ID for which the data should be retrieved 
SetWhichControl:
  If (RadControl = 1)        ;for active control
      ControlGetFocus, ControlID, ahk_id %WindowUniqueID%
  Else                       ;for control under mouse pointer
      ControlID = %MouseControlID%
Return

UpdateMinimumInfo:
  ;optional tooltip
  If ChkTtpMaster {
      InfoString := iif(ChkTtpMSPos,"MScreen: " MouseScreenX "," MouseScreenY "`n")
                  . iif(ChkTtpCClass,"Control ClassNN: " MouseControlID "`n")
                  . iif(ChkTtpWClass,"Window Class: " WindowClass "`n")
                  . iif(ChkTtpWTitle,"Window Title: " WindowTitle "`n")
      StringTrimRight, InfoString, InfoString, 1    ;remove last `n
      If InfoString
          ToolTip(Scriptname "`n----------------------------`n" InfoString)
    }
Return

UpdateAllInfo:
  ;ToolTip, UpdateAllInfo - %A_Now%   ;??? for debug
  
  GoSub, GetMouseInfo
  GoSub, GetControlInfo

  ;optional tooltip
  If ChkTtpMaster {
      InfoString := iif(ChkTtpMSPos,"MScreen: " MouseScreenX "," MouseScreenY "`n")
                    . iif(ChkTtpMWPos,"MWindow: " MouseWindowX "," MouseWindowY "`n")
                    . iif(ChkTtpMColor,"MColor: " MouseColorRGB "`n")
                    . iif(ChkTtpCClass,"Control ClassNN: " MouseControlID "`n")
                    . iif(ChkTtpCPos,"Control Pos: " ControlX "," ControlY "`n")
                    . iif(ChkTtpCSize,"Control Size: " ControlWidth "," ControlHeight "`n")
                    . iif(ChkTtpWClass,"Window Class: " WindowClass "`n")
                    . iif(ChkTtpWTitle,"Window Title: " WindowTitle "`n")
        StringTrimRight, InfoString, InfoString, 1    ;remove last `n
        If InfoString
            ToolTip(Scriptname "`n----------------------------`n" InfoString)
    }
    
  GoSub, GetWindowInfo
  If (Tab1 = 2) ;get window text only when advanced tab is active
      GoSub, GetWindowText
  
  If ChkShowList {                        ;if large list is shown
      If RadList1 = 1               ;get data depending on choice
          GoSub, GetControlListInfo
      Else
          GoSub, GetAllWindowsInfo

      UpdateIsStopped := True                  ;give feedback and stop updating
      If ChkShowInfoToolTip
          ToolTip("Stopped to update data to allow working with "
                  . iif(SelectedRadList = 1,"list of controls")
                  . iif(SelectedRadList = 2,"list of windows")
                  . "`nPress Pause key to create a new snapshot", 2000)
    }
Return

GetMouseInfo:
  ;get mouse pos relative to windows
  WinGetPos, WindowActiveX, WindowActiveY,,, A
  WinGetPos, WindowX, WindowY,,, ahk_id %MouseWindowUID%
  MouseWindowActiveX := MouseScreenX - WindowActiveX
  MouseWindowActiveY := MouseScreenY - WindowActiveY
  MouseWindowX := MouseScreenX - WindowX
  MouseWindowY := MouseScreenY - WindowY
  GuiControl, 1:, EdtMousePosScreen, x%MouseScreenX% y%MouseScreenY%
  GuiControl, 1:, EdtMousePosWin, x%MouseWindowX% y%MouseWindowY%
  GuiControl, 1:, EdtEasyMousePosWin, x%MouseWindowX% y%MouseWindowY%
  GuiControl, 1:, EdtDataMousePosWin, x%MouseWindowX% y%MouseWindowY%
  GuiControl, 1:, EdtMousePosAWin, x%MouseWindowActiveX% y%MouseWindowActiveY%

  ;get pointer shape
  GuiControl, 1:, EdtMousePointer, %A_Cursor%
  
  ;get color below mouse pointer
  CoordMode, Pixel, Screen 
  PixelGetColor, MouseColorRGB, %MouseScreenX%, %MouseScreenY%, RGB
  StringMid, MouseColorR, MouseColorRGB, 3, 2
  StringMid, MouseColorG, MouseColorRGB, 5, 2
  StringMid, MouseColorB, MouseColorRGB, 7, 2
  GuiControl, 1:, EdtMouseColorRGB, % "R" HEXtoDEC(MouseColorR) " G" HEXtoDEC(MouseColorG)" B" HEXtoDEC(MouseColorB)
  GuiControl, 1:, EdtMouseColorHex, %MouseColorRGB%

  If (Tab1 = 3) {      ;Only update color picker when mouse tab is active 
      If ( MouseScreenX MouseScreenY <> OldPosition or MouseColorRGB <> OldMouseColorRGB){    ;only update color picker when mouse moves or color changes
          x := MouseScreenX - HalfDim
          Loop, %Dim% {
              x++
              Row := A_Index + 8 - HalfDim
              y := MouseScreenY - HalfDim
              Loop, %Dim% {
                  y++
                  PixelGetColor, ColorRGB, %x%, %y%, % iif(RadColorPick = 1, "RGB")
                  StringTrimLeft, ColorRGB, ColorRGB, 2
                  Control := "PgbColorPicker" (A_Index + 8 - HalfDim) "_" Row 
                  %Control% = %ColorRGB%  
                  If RadColorPick = 2
                      PixelGetColor, ColorRGB, %x%, %y%, RGB
                  GuiControl, 1:+Background%ColorRGB%,%Control% 
                }
            }
        }
      OldPosition = %MouseScreenX%%MouseScreenY%
      OldMouseColorRGB = %MouseColorRGB%
    }
Return

GetControlInfo:
  GuiControl, 1:, EdtControlClass, %ControlID%
  GuiControl, 1:, EdtEasyControlClass, %ControlID%

  ;get Pos, Size, Text
  ControlGetPos, ControlX, ControlY, ControlWidth, ControlHeight, %ControlID%, ahk_id %WindowUniqueID%
  GuiControl, 1:, EdtControlPos, x%ControlX% y%ControlY%
  GuiControl, 1:, EdtControlSize, w%ControlWidth% h%ControlHeight%

  ControlGet, ControlHwnd, Hwnd,, %ControlID%, ahk_id %WindowUniqueID%
  GuiControl, 1:, EdtControlHwnd, %ControlHwnd%

;Chris suggests to avoid any call to ControlGetText or WinGetText because they force the OS to copy an
; unlimited amount of text across process boundaries. This text could be several megabytes or more if
; someone has a big text file or Word document open. Instead use WM_GETTEXT.
;   ControlGetText, ControlText, %ControlID%, ahk_id %WindowUniqueID%
  MouseGetPos,,,,ControlHWND, 2
  SendMessage, 0xD, ControlTextSize, &ControlText,, ahk_id %ControlHWND%  ; 0xD is WM_GETTEXT.
  EdtControlTextFull := ShowOnlyAPartInGui("EdtControlText", ControlText, 100)
  EdtEasyControlTextFull := ShowOnlyAPartInGui("EdtEasyControlText", ControlText, 100)

  If (Tab1 = 2) { ;get control list data only when advanced tab is active
      ControlGet, ControlListItems, List, , %ControlID%, ahk_id %WindowUniqueID%
      EdtListItemsFull := ShowOnlyAPartInGui("EdtListItems", ControlListItems, 200)
    }
Return

GetWindowInfo:
  ;get Title, Pos, Size, PID, Process, Class
  WinGetTitle, WindowTitle, ahk_id %WindowUniqueID% 
  WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, ahk_id %WindowUniqueID%
  WinGet, WindowPID, PID, ahk_id %WindowUniqueID% 
  WinGet, WindowProcessName, ProcessName, ahk_pid %WindowPID%
  WinGetClass, WindowClass, ahk_id %WindowUniqueID%
  GuiControl, 1:, EdtWindowTitle, %WindowTitle%
  GuiControl, 1:, EdtEasyWindowTitle, %WindowTitle%
  GuiControl, 1:, EdtWindowPos, x%WindowX% y%WindowY%
  GuiControl, 1:, EdtWindowSize, w%WindowWidth% h%WindowHeight%
  GuiControl, 1:, EdtWindowClass, %WindowClass%
  GuiControl, 1:, EdtEasyWindowClass, %WindowClass%
  GuiControl, 1:, EdtWindowProcess, %WindowProcessName%
  GuiControl, 1:, EdtWindowUID, %WindowUniqueID%
  GuiControl, 1:, EdtWindowPID, %WindowPID%

  If (Tab1 = 2) { ;get advanced window data only when advanced tab is active
      ;get and set statusbartext (maximum 10)
      ListOfStatusbarText = 
      Loop, 10 { 
          StatusBarGetText, StatusBarText, %A_Index%, ahk_id %WindowUniqueID%
          If StatusBarText
              ListOfStatusbarText = %ListOfStatusbarText%%A_Index% - %StatusBarText%|
        }
      If ListOfStatusbarText is space
          ListOfStatusbarText = No text found in statusbar
      GuiControl, 1:, LsbStatusbarText, |%ListOfStatusbarText%
    }
Return

GetWindowText:
  EdtWindowTextFastVisible =
  EdtWindowTextSlowVisible =
  EdtWindowTextFastHidden =
  EdtWindowTextSlowHidden =
  
  ;Suggested by Chris
  WinGet, ListOfControlHandles, ControlListHwnd, ahk_id %WindowUniqueID%  ; Requires v1.0.43.06+.
  Loop, Parse, ListOfControlHandles, `n
    {
    	text_is_fast := true
      If not DllCall("GetWindowText", "uint", A_LoopField, "str", WindowControlText, "int", WindowControlTextSize){
      		text_is_fast := false
       		SendMessage, 0xD, WindowControlTextSize, &WindowControlText,, ahk_id %A_LoopField%  ; 0xD is WM_GETTEXT
      	}
    	If (WindowControlText <> ""){
      		ControlGet, WindowControlStyle, Style,,, ahk_id %A_LoopField%
      		If (WindowControlStyle & 0x10000000){  ; Control is visible vs. hidden (WS_VISIBLE).
        			If text_is_fast
        				EdtWindowTextFastVisible = %EdtWindowTextFastVisible%%WindowControlText%`r`n
        			Else
        				EdtWindowTextSlowVisible = %EdtWindowTextSlowVisible%%WindowControlText%`r`n
      		}Else{  ; Hidden text.
        			If text_is_fast
        				EdtWindowTextFastHidden = %EdtWindowTextFastHidden%%WindowControlText%`r`n
        			Else
        				EdtWindowTextSlowHidden = %EdtWindowTextSlowHidden%%WindowControlText%`r`n
        		}
      	}
  }

  EdtWindowTextFastVisibleFull := ShowOnlyAPartInGui("EdtWindowTextFastVisible", EdtWindowTextFastVisible, 400)
  EdtWindowTextSlowVisibleFull := ShowOnlyAPartInGui("EdtWindowTextSlowVisible", EdtWindowTextSlowVisible, 400)
  EdtWindowTextFastHiddenFull := ShowOnlyAPartInGui("EdtWindowTextFastHidden", EdtWindowTextFastHidden, 400)
  EdtWindowTextSlowHiddenFull := ShowOnlyAPartInGui("EdtWindowTextSlowHidden", EdtWindowTextSlowHidden, 400)
Return

ShowOnlyAPartInGui(Control, FullContent, Limit=200){
    Content = %FullContent%
    If (StrLen(Content) > Limit){         ;limits the control text in the GUI. An unlimited length caused on some PCs 100% CPU load
        StringLeft, Content, Content, %Limit%
        Content = %Content% ...
      }
    GuiControl, 1:, %Control%, %Content%
    Return FullContent
  }

GetControlListInfo:
  ;get list of controls in z order
  WinGet, ControlList, ControlList, ahk_id %WindowUniqueID%
  
  ;get all data for these controls
  Loop, Parse, ControlList, `n
    {
      ControlID0 = %A_Index%
      ControlID = %A_LoopField%
      ControlID%A_Index% = %ControlID%
      ControlGetPos, ControlX%A_Index%, ControlY%A_Index%, ControlWidth%A_Index%, ControlHeight%A_Index%, %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlHwnd%A_Index%, Hwnd,, %ControlID%, ahk_id %WindowUniqueID%
      ControlGetText, ControlText%A_Index%, %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlChecked%A_Index%, Checked, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlEnabled%A_Index%, Enabled, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlVisible%A_Index%, Visible, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlTab%A_Index%, Tab, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlChoice%A_Index%, Choice, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlLineCount%A_Index%, LineCount, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlCurrentLine%A_Index%, CurrentLine, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlCurrentCol%A_Index%, CurrentCol, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlSelected%A_Index%, Selected, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlStyle%A_Index%, Style, , %ControlID%, ahk_id %WindowUniqueID%
      ControlGet, ControlExStyle%A_Index%, ExStyle, , %ControlID%, ahk_id %WindowUniqueID%
    }

  ;add all data to listview
  GuiControl, -Redraw, LV1          ; speed up adding data
  LV_Delete()                       ; remove old data
  Loop, %ControlID0% {
      LV_Add(""
        , A_Index                     ; Z or Stack Order
        , ControlHwnd%A_Index%          ; Unique ID
        , ""                          ; Window PID
        , ControlID%A_Index%          ; Window Class
        , ""                          ; Window Process Name
        , ControlVisible%A_Index%     ; Visible or Hidden?
        , ControlText%A_Index%        ; Title or Text
        , ControlX%A_Index%           ; X
        , ControlY%A_Index%           ; Y
        , ControlWidth%A_Index%       ; Width
        , ControlHeight%A_Index%      ; Height
        , ControlStyle%A_Index%       ; Style
        , ControlExStyle%A_Index%     ; ExStyle
        , ControlSelected%A_Index%    ; Selected
        , ControlCurrentCol%A_Index%  ; CurrentCol
        , ControlCurrentLine%A_Index% ; CurrentLine
        , ControlLineCount%A_Index%   ; LineCount
        , ControlChoice%A_Index%      ; Choice
        , ControlTab%A_Index%         ; Tab
        , ControlEnabled%A_Index%     ; Enabled
        , ControlChecked%A_Index%)    ; Checked
    }   
  LV_ModifyCol()                    ; Auto-size all columns 
  LV_ModifyCol(1, "Integer Left")   ; column Z Order 
  LV_ModifyCol(3, 0)                ; hide column Window PID 
  LV_ModifyCol(5, 0)                ; hide column Window Process Name 
  LV_ModifyCol(7, "150")            ; column Text 
  GuiControl, +Redraw, LV1
Return

GetAllWindowsInfo:
  ;get list of all visible windows in stack order
  DetectHiddenWindows, Off 
  WinGet, WinIDs, List 
  Loop, %WinIDs% 
      winListIDsVisible := winListIDsVisible WinIDs%A_Index% "`n" 
  
  ;get list of all windows in stack order
  DetectHiddenWindows, On 
  WinGet, WinIDs, List 

  ;get all data for all windows
  Loop, %WinIDs% {
      UniqueID := "ahk_id " WinIDs%A_Index% 
      WinGetPos, WindowX%A_Index%, WindowY%A_Index%, WindowWidth%A_Index%, WindowHeight%A_Index%, %UniqueID%
      WinGet, winPID%A_Index%, PID, %UniqueID% 
      WinGet, processName%A_Index%, ProcessName, % "ahk_pid " winPID%A_Index%
      WinGetTitle, winTitle%A_Index%, %UniqueID%   
      WinGetClass, winClass%A_Index%, %UniqueID%
    } 
  DetectHiddenWindows, off
  
  ;add all data to listview
  GuiControl, -Redraw, LV1          ; speed up adding data
  LV_Delete()                       ; remove old data
  Loop, %WinIDs% {
      LV_Add(""
        , A_Index                   ; Z or Stack Order
        , WinIDs%A_Index%           ; Unique ID
        , winPID%A_Index%           ; Window PID
        , winClass%A_Index%         ; Window Class
        , processName%A_Index%      ; Process Name
        , iif(InStr(winListIDsVisible,WinIDs%A_Index%),"","Hidden")  ; Visible or Hidden?
        , winTitle%A_Index%         ; Title or Text
        , WindowX%A_Index%          ; X
        , WindowY%A_Index%          ; Y
        , WindowWidth%A_Index%      ; Width
        , WindowHeight%A_Index%)    ; Height
    }   
  LV_ModifyCol()                    ; Auto-size all columns 
  LV_ModifyCol(1, "Integer Left")   ; column Stack Order 
  LV_ModifyCol(4, "100")            ; column Class
  LV_ModifyCol(7, "150")            ; column Title
  GuiControl, +Redraw, LV1
Return

;draw frames around controls and/or windows
DrawFrameAroundControl(ControlID, WindowUniqueID, frame_t){
    global h_brushC, h_brushW, ChkDrawRectCtrl, ChkDrawRectWin
    
    ;get coordinates of Window and control again
    ;(could have been past into the function but it seemed too much parameters)
    WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, ahk_id %WindowUniqueID%
    ControlGetPos, ControlX, ControlY, ControlWidth, ControlHeight, %ControlID%, ahk_id %WindowUniqueID%
    
    ;find upper left corner relative to screen
    StartX := WindowX + ControlX 
    StartY := WindowY + ControlY 
      
    ;show ID in upper left corner
    CoordMode, ToolTip, Screen
    
    ;show frame gui above AOT apps
    Gui, 2: +AlwaysOnTop
    
    If ChkDrawRectWin {
        ;if windows upper left corner is outside the screen
        ; it is assumed that the window is maximized and the frame is made smaller
        If ( WindowX < 0 AND WindowY < 0 ){
            WindowX += 4
            WindowY += 4
            WindowWidth -= 8
            WindowHeight -= 8
          }

        ;remove old rectangle from screen and save/buffer screen below new rectangle
        BufferAndRestoreRegion( WindowX, WindowY, WindowWidth, WindowHeight ) 

        ;draw rectangle frame around window
        DrawFrame( WindowX, WindowY, WindowWidth, WindowHeight, frame_t, h_brushW )

        ;show tooltip above window frame when enough space
        If ( WindowY > 22)
            WindowY -= 22

        ;Show tooltip with windows unique ID 
        ToolTip, %WindowUniqueID%, WindowX, WindowY, 3
      }
    Else
        ;remove old rectangle from screen and save/buffer screen below new rectangle
        BufferAndRestoreRegion( StartX, StartY, ControlWidth, ControlHeight )             

    If ChkDrawRectCtrl {
        ;draw rectangle frame around control
        DrawFrame( StartX, StartY, ControlWidth, ControlHeight, frame_t, h_brushC )

        ;show tooltip above control frame when enough space, or below
        If ( StartY > 22)
            StartY -= 22
        Else 
            StartY += ControlHeight
        
        ;show control tooltip left of window tooltip if position identical (e.g. Windows Start Button on Taskbar) 
        If (StartY = WindowY
            AND StartX < WindowX + 50)
            StartX += 50
                        
        ;Show tooltip with controls unique ID 
        ToolTip, %ControlID%, StartX, StartY, 2
      }
    ;set back ToolTip position to default
    CoordMode, ToolTip, Relative
  }

;###############################################################################
;###   export the data    ######################################################
;###############################################################################

BtnBrowseExportFile:
  Gui, 1:Submit, NoHide
  SelectFile("EdtExportFile", EdtExportFile, "email")
Return

BtnSaveExport:
  Gui, 1:Submit, NoHide

  ;return if no filename is given
  If EdtExportFile is space
    {
      ToolTip("No filename for export specified.", 3000)
      MsgBox, 48, Problem , No export filename is given.
      Return
    }

  ;return if no data is selected for export
  NumberOfExports = 0
  Loop, Parse, ExportOptions, `,
      NumberOfExports := NumberOfExports + %A_LoopField%
  If (NumberOfExports = 0){
      ToolTip("No data selected for export.", 3000)
      Return
    }

  ;get filename
  If (ChkExportAutoNumber){
      FileNameForExport := GetAvailableFileName(EdtExportFile)
      If not FileNameForExport {
          ToolTip("Could get filename for export.`n" ErrorLevel, 3000)
          Return
        }
  }Else
      FileNameForExport = %EdtExportFile%
       
  GuiControl, 1:Disable, BtnSaveExport
  GoSub, ExportDataToFile
  GuiControl, 1:Enable, BtnSaveExport
  If ChkShowInfoToolTip
      ToolTip("Data exported to file: " FileNameForExport, 3000) 
Return

ExportDataToFile: 
  If ChkExportAppend
      FileAppend, `n===========next snapshot===========`n, %FileNameForExport% 
  Else 
      FileDelete, %FileNameForExport%
      
  ExportString := "Data exported from " ScriptName " at " A_Now "`n`nMouse Data`n" 
               . iif(ChkExportMousePosScreen,"Mouse position relative to Screen :`n" EdtMousePosScreen "`n`n")
               . iif(ChkExportMousePosWin,"Mouse position relative to window under mouse pointer :`n" EdtMousePosWin "`n`n")
               . iif(ChkExportMousePosAWin,"Mouse position relative to active window :`n" EdtMousePosAWin "`n`n")
               . iif(ChkExportMousePointer,"Mouse cursor style :`n" EdtMousepointer "`n`n")
               . iif(ChkExportMouseColorRGB,"Pixel Color in RGB format under mouse pointer :`n" EdtMouseColorRGB "`n`n")
               . iif(ChkExportMouseColorHex,"Pixel Color in Hex format (RGB) mouse pointer :`n" EdtMouseColorHex "`n`n")
               . "`nControl data for "
               . iif(RadControl = 1,"active control of " iif(RadWindow = 1,"active window","window under mouse pointer") ,"control under mouse pointer")
               . "`n"
               . iif(ChkExportCtrlText,"Control text :`n" EdtControlText "`n`n")
               . iif(ChkExportCtrlClass,"Control classNN :`n" EdtControlClass "`n`n")
               . iif(ChkExportCtrlPos,"Control position :`n" EdtControlPos "`n`n")
               . iif(ChkExportCtrlSize,"Control size :`n" EdtControlSize "`n`n")
               . iif(ChkExportCtrlListItems,"Control list items :`n" EdtListItems "`n`n")
               . "`nWindow data for "
               . iif(RadWindow = 1,"active window","window under mouse pointer")
               . "`n"
               . iif(ChkExportWinTitle,"Window title :`n" EdtWindowTitle "`n`n")
               . iif(ChkExportWinPos,"Window position :`n" EdtWindowPos "`n`n")
               . iif(ChkExportWinSize,"Window size :`n" EdtWindowSize "`n`n")
               . iif(ChkExportWinClass,"Window class :`n" EdtWindowClass "`n`n")
               . iif(ChkExportWinProcess,"Window process name:`n" EdtWindowprocess "`n`n")
               . iif(ChkExportWinUID,"Window unique ID :`n" EdtWindowUID "`n`n")
               . iif(ChkExportWinPID,"Window PID :`n" EdtWindowPID "`n`n")
  FileAppend, %ExportString%, %FileNameForExport% 

  ExportString =
  If ChkExportWinStatusText {
      StringReplace, StatusbarText, ListOfStatusbarText, |, `n, All
      ExportString = `n######## Window Statusbar Text (Part# - Text) :`n%StatusbarText%`n`n
    } 
  If ChkExportWinText
      ExportString := ExportString 
               . iif(EdtWindowTextFastVisible,"`n######## Fast Visible Window Text :`n" EdtWindowTextFastVisible "`n`n")
               . iif(EdtWindowTextSlowVisible,"`n######## Slow Visible Window Text :`n" EdtWindowTextSlowVisible "`n`n")
               . iif(EdtWindowTextFastHidden,"`n######## Fast Hidden Window Text :`n" EdtWindowTextFastHidden "`n`n")
               . iif(EdtWindowTextSlowHidden,"`n######## Slow Hidden Window Text :`n" EdtWindowTextSlowHidden "`n`n")
  FileAppend, %ExportString%, %FileNameForExport% 

  If ChkExportLargeList {
      If LV_GetCount() {
          ExportString := "`n########"
                          . iif(RadList3,"Data of all controls of the " iif(RadWindow = 1,"active window","window under the mousepointer") ,"Data of all windows")
          ExportString = %ExportString% :`n
             (LTrim Join`s
                ######## Z or Stack Order, Unique ID, Window PID, Window Class,
                Process Name, Hidden, Title or Text, X, Y, Width, Height, Style,
                ExStyle, Selected, CurrentCol, CurrentLine, LineCount, Choice,
                Tab, Enabled, Checked
                
             )
          Columns := LV_GetCount("Col")
          Loop, % LV_GetCount() {
              Row = %A_Index%
              Loop %Columns% {
                  LV_GetText(Text, Row , A_Index)
                  ExportString = %ExportString%%Text%, 
                } 
              StringTrimRight,ExportString,ExportString,1  ;remove last comma 
              ExportString = %ExportString%`n              ;start new line
            } 
        }  
      If ExportString
          FileAppend, %ExportString%, %FileNameForExport% 
    } 
Return

;###############################################################################
;###   small helper functions   ################################################
;###############################################################################

iif(expr, a, b=""){
    If expr
        Return a
    Return b
  }

ToggleOnTopGui1(wParam, lParam, msg, hwnd) {
    Global Gui1UniqueID, Gui1AOTState

    WinGetTitle, CurrentTitle , ahk_id %Gui1UniqueID%
    If (Gui1AOTState){
        Gui, 1: -AlwaysOnTop
        StringTrimRight, CurrentTitle, CurrentTitle, 8
        WinSetTitle, ahk_id %Gui1UniqueID%, , %CurrentTitle%
    }Else { 
        Gui, 1: +AlwaysOnTop
        WinSetTitle, ahk_id %Gui1UniqueID%, , %CurrentTitle% - *AOT* 
      }
    Gui1AOTState := not Gui1AOTState
  }

ToolTip(Text, TimeOut=1000){
    ToolTip, %Text%
    SetTimer, RemoveToolTip, %TimeOut%
    Return
  }
RemoveToolTip:
   ToolTip
Return

HEXtoDEC(HEX){ 
    StringUpper, HEX, HEX 
    Loop, % StrLen(HEX) { 
        StringMid, Col, HEX, % (StrLen(HEX) + 1) - A_Index, 1 
        If Col is integer 
            DEC1 := Col * 16 ** (A_Index - 1) 
        Else 
            DEC1 := (Asc(Col) - 55) * 16 ** (A_Index - 1) 
        DEC += %DEC1% 
      } 
    return DEC 
  }

SelectFile(Control, OldFile, Text){
    Gui, 1:+OwnDialogs
    StringReplace, OutputVar, OldFile, #, *, All
    IfExist %A_ScriptDir%\%OutputVar%
        StartFolder = %A_ScriptDir%
    Else IfExist %OldFile%
        SplitPath, OldFile, , StartFolder
    Else 
        StartFolder = 
    FileSelectFile, SelectedFile, S18, %StartFolder%, Select file for %Text%, Text file (*.txt)
    If SelectedFile {
        StringReplace, SelectedFile, SelectedFile, %A_ScriptDir%\
        GuiControl, 1: ,%Control%, %SelectedFile%
      }
  }

CheckAHKVersion(AHK_version){
    StringSplit, A, A_AHKVERSION, . 
    StringSplit, B, AHK_version, .
    Ax = 0
    Bx = 0
    Loop, %A0%{      ; create unique number for both versions, max. verion 999.999.999.999 leads to 999999999999 
        Ax := Ax + A%A_Index% * 1000 ** ( A0 - A_Index ) 
        Bx := Bx + B%A_Index% * 1000 ** ( A0 - A_Index ) 
      } 
    If ( Bx > Ax ) { 
        msgbox, 16, Old AHK version,
          (LTrim
            This script requires a newer version of AHK.
            Installed version = %A_AHKVERSION%
            Required version = %AHK_version%
            
            Please download latest version and install it.
            This Program will exit and open the webpage
            where you can download the latest AHK version.
          )
        run, http://www.autohotkey.com/download
        ExitApp 
      } 
  }

;#############   Get next free/available File Name   ##########################
GetAvailableFileName(ExportFileName){ 
    ;separate FileName and FileDir
    SplitPath, ExportFileName, FileName, FileDir
  
    ;return ExportFileName if FileName doesn't contain "#"
    If (InStr(FileName, "#") = 0)
        Return, ExportFileName
  
    ;add "\" to FileDir again
    If FileDir
        FileDir = %FileDir%\
  
    ;split FileName with #
    StringSplit, NameArray, FileName, #
    
    ;Search from StartID = 1
    StartID = 1
    Loop { 
        Number := A_Index + StartID - 1
               
        ;untill number is too large ...
        If ( StrLen(Number) > NameArray0 - 1 ) {
            ErrorLevel =
              (LTrim
                All files exist for >%ExportFileName%<
                with all "#" between %StartID% and %Number%.
              )
            Return 0
          }
  
        ;otherwise fill number with leading zeros
        Loop, % NameArray0 - 1 - StrLen(Number)
            Number = 0%Number% 
        
        ;split number in an array
        StringSplit, NumberArray, Number
        
        ;mix and concatenate the names array with the numbers array
        FileName =
        Loop, %NameArray0%
            FileName := FileName . NameArray%A_Index% . NumberArray%A_Index%
        
        ;check if GivenFileName doesn't exist
        If not FileExist(FileDir . FileName)
            Return FileDir . FileName
      } 
  }

;#############   destroy draw objects   ####################################### 
DeleteObject( p_object ) { 
    ;deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources 
    DllCall( "gdi32.dll\DeleteObject", "uint", p_object ) 
  } 

DeleteDC( p_dc ) { 
    ;deletes the specified device context (DC). 
    DllCall( "gdi32.dll\DeleteDC", "uint", p_dc ) 
  } 

;#############   create draw objects   ######################################## 
CreateDrawHandles(UniqueID, ScreenWidth, ScreenHeight, frame_cc, frame_cw){ 
    global   hdc_frame, hdc_buffer, h_region, h_brushC, h_brushW 
  
    ;Get handle to display device context (DC) for the client area of a specified window 
    hdc_frame := DllCall( "GetDC" 
                        , "uint", UniqueID ) 
                        
    ;create buffer to store old color data to remove drawn rectangles 
    hdc_buffer := DllCall( "gdi32.dll\CreateCompatibleDC" 
                         , "uint", hdc_frame ) 
    
    ;Create Bitmap buffer to remove drawn rectangles 
    hbm_buffer := DllCall( "gdi32.dll\CreateCompatibleBitmap" 
                         , "uint", hdc_frame 
                         , "int", ScreenWidth 
                         , "int", ScreenHeight ) 
    
    ;Select Bitmap buffer in buffer to remove drawn rectangles 
    DllCall( "gdi32.dll\SelectObject" 
           , "uint", hdc_buffer 
           , "uint", hbm_buffer ) 
  
    ;create a dummy rectangular region. 
    h_region := DllCall( "gdi32.dll\CreateRectRgn" 
                       , "int", 0 
                       , "int", 0 
                       , "int", 0 
                       , "int", 0 ) 
  
    ;specify the color of the control frame. 
    h_brushC := DllCall( "gdi32.dll\CreateSolidBrush" 
                       , "uint", frame_cc ) 
    ;specify the color of the window frame. 
    h_brushW := DllCall( "gdi32.dll\CreateSolidBrush" 
                       , "uint", frame_cw ) 
  }
  
;#############   remove old rectangle and save screen below new rectangle   ### 
BufferAndRestoreRegion( p_x, p_y, p_w, p_h ) { 
    global   hdc_frame, hdc_buffer 
    static   buffer_state, old_x, old_y, old_w, old_h 
      
    ;Copies the source rectangle directly to the destination rectangle. 
    SRCCOPY   = 0x00CC0020 
        
    ;remove previously drawn rectangle (restore previoulsy buffered color data) 
    if ( buffer_state = "full") 
       ;perform transfer of color data of rectangle from source DC into destination DC 
       ; from buffer to screen, erasing the previously darwn reactangle 
       DllCall( "gdi32.dll\BitBlt" 
              , "uint", hdc_frame 
              , "int", old_x 
              , "int", old_y 
              , "int", old_w 
              , "int", old_h 
              , "uint", hdc_buffer 
              , "int", 0 
              , "int", 0 
              , "uint", SRCCOPY ) 
    else 
       buffer_state = full 
  
    ;remember new rectangle for next loop (to be removed) 
    old_x := p_x 
    old_y := p_y 
    old_w := p_w 
    old_h := p_h 
  
    ; Store current color data of new rectangle in buffer 
    DllCall( "gdi32.dll\BitBlt" 
           , "uint", hdc_buffer 
           , "int", 0 
           , "int", 0 
           , "int", p_w 
           , "int", p_h 
           , "uint", hdc_frame 
           , "int", p_x 
           , "int", p_y 
           , "uint", SRCCOPY ) 
  } 
  
;#############   draw frame   ################################################# 
DrawFrame( p_x, p_y, p_w, p_h, p_t, h_brush ) { 
    global   hdc_frame, h_region
      
    ; modify dummy rectangular region to desired reactangle 
    DllCall( "gdi32.dll\SetRectRgn" 
           , "uint", h_region 
           , "int", p_x 
           , "int", p_y 
           , "int", p_x+p_w 
           , "int", p_y+p_h ) 
    
    ; draw region frame with thickness (width and hight are the same) 
    DllCall( "gdi32.dll\FrameRgn" 
           , "uint", hdc_frame 
           , "uint", h_region 
           , "uint", h_brush 
           , "int", p_t 
           , "int", p_t ) 
  } 
