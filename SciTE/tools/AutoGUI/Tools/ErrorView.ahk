; Win32 Error Messages Lookup and Listing Tool

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
FileEncoding UTF-8

Global Version := "1.0.3"
     , Total
     , Items
     , hLV
     , hTxtCount
     , Voice

Menu Tray, Icon, %A_ScriptDir%\..\Icons\ErrorView.ico

Gui +Resize
Gui Color, 0xF1F5FB

Menu FileMenu, Add, &Save`tCtrl+S, Save
Menu FileMenu, Add
Menu FileMenu, Add, E&xit`tAlt+Q, GuiClose
Menu EditMenu, Add, &Copy`tCtrl+C, Copy
Menu EditMenu, Add
Menu EditMenu, Add, Select &All`tCtrl+A, SelectAll
Menu MsgMenu,  Add, Show in a Message Box, ShowMsgBox ; Enter
Menu MsgMenu,  Add
Menu MsgMenu,  Add, Speak, Speak ; Space
If (A_PtrSize == 8) {
    Menu MsgMenu, Disable, Speak    
}
Menu ViewMenu, Add, Random &Balloon`tF2, RandomBalloon
Menu ViewMenu, Add
Menu ViewMenu, Add, &Reload`tF5, Reload
Menu HelpMenu, Add, &Online Reference`tF1, OnlineRef
Menu HelpMenu, Add
Menu HelpMenu, Add, &About, ShowAbout

Menu MenuBar, Add, &File,    :FileMenu
Menu MenuBar, Add, &Edit,    :EditMenu
Menu MenuBar, Add, &Message, :MsgMenu
Menu MenuBar, Add, &View,    :ViewMenu
Menu MenuBar, Add, &Help,    :HelpMenu
Gui Menu, MenuBar

Gui Font, s9, Segoe UI

Gui Add, ListView, hWndhLV vLV gLVHandler x-1 y-1 w866 h448 +LV0x14000, ID|Message
LV_ModifyCol(1, "48 Integer")
LV_ModifyCol(2, 618)
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hLV, "WStr", "Explorer", "Ptr", 0)

Gui Add, Edit, hWndhHiddenEdit x20 y20 w0 h0

Gui Add, Picture, hWndhPic x207 y1 w16 h16, ..\Icons\Search.ico
Gui Add, Edit, hWndhEdtSearch vFilter x9 y457 w230 h23 +0x2000000 ; WS_CLIPCHILDREN
DllCall("SendMessage", "Ptr", hEdtSearch, "UInt", 0x1501, "Ptr", 1, "WStr", "Enter search here")
DllCall("SetParent", "Ptr", hPic, "Ptr", hEdtSearch)
WinSet Style, -0x40000000, ahk_id %hPic% ; -WS_CHILD
GuiControl Focus, %hEdtSearch%

Gui Add, Text, hWndhTxtCount x731 y457 w120 h23 +0x202, Loading Messages...

Gui Show, w864 h489, ErrorView - System Error Messages

LoadErrorMessages()

Menu ContextMenu, Add, Message Box, ShowMsgBox
Menu ContextMenu, Default, Message Box
Menu ContextMenu, Add
Menu ContextMenu, Add, &Copy`tCtrl+C, Copy
Menu ContextMenu, Add
Menu ContextMenu, Add, Select &All`tCtrl+A, SelectAll

Voice := ComObjCreate("SAPI.SpVoice")

OnMessage(0x100, "OnWM_KEYDOWN")
Return

GuiEscape:
    Gui Submit, NoHide

    If (Voice.Status.RunningState == 2) { ; SRSEIsSpeaking
        Voice.Speak(" ", 3) ; SVSFlagsAsync | SVSFPurgeBeforeSpeak
        Return
    }

    If (Filter != "") {
        GuiControl,, %hEdtSearch%
        Search()
    } Else {
        GoSub GuiClose
    }
Return

GuiClose:
    ExitApp

GuiSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("wh", hLV)
    AutoXYWH("y", hEdtSearch)
    AutoXYWH("xy", hTxtCount)

    LV_ModifyCol(2, A_GuiWidth - 70)
Return

GuiContextMenu:
    If (A_GuiControl != "LV" || !LV_GetNext()) {
        Return
    }

    Menu ContextMenu, Show
Return

Reload() {
    LV_Delete()
    LoadErrorMessages()
}

LoadErrorMessages() {
    Total := 0
    Items := {}

    Loop 18000 {
        i := A_Index - 1
        Message := GetErrorMessage(i)
        If (Message != "") {
            LV_Add("", i, Message)
            Items.Push([i, Message])
        }
    }

    Total := Items.Length()
    GuiControl,, %hTxtCount%, %Total% Items
}

GetErrorMessage(ErrorCode, LanguageId := 0) {
    Static FuncName := "FormatMessage" . (A_IsUnicode ? "W" : "A")
    Static FormatMessage := 0, hMod, Encoding := A_IsUnicode ? "UTF-16" : "CP0"

    Local Size, ErrorBuf, ErrorMsg

    If (!FormatMessage) {
        hMod := DllCall("GetModuleHandle", "Str", "Kernel32.dll", "Ptr")
        FormatMessage := DllCall("GetProcAddress", "Ptr", hMod, "AStr", FuncName, "Ptr")
    }

    Size := DllCall(FormatMessage
        ; FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "UInt", 0x1300
        , "Ptr",  0
        , "UInt", ErrorCode + 0
        , "UInt", LanguageId ; English: 0x409
        , "Ptr*", ErrorBuf
        , "UInt", 0
        , "Ptr",  0)

    If (!Size) {
        Return ""
    }

    ErrorMsg := StrGet(ErrorBuf, Size, Encoding)
    DllCall("Kernel32.dll\LocalFree", "Ptr", ErrorBuf)

    Return ErrorMsg
}

ShowMsgBox:
LVHandler:
    If (A_GuiEvent == "DoubleClick") {
        Row := A_EventInfo
    } Else {
        Row := LV_GetNext()
    }

    LV_GetText(ErrorCode, Row)
    LV_GetText(ErrorMsg, Row, 2)

    Gui +OwnDialogs
    MsgBox 0, Error %ErrorCode%, %ErrorMsg%
Return

Search:
    Gui Submit, NoHide
    Search(Filter)
Return

Search(Filter := "") {
    Global

    If Filter is Integer
    {
        LV_Delete()
        Loop % Items.Length() {
            If (Items[A_Index][1] == Filter) {
                LV_Add("", Items[A_Index][1], Items[A_Index][2])
                GuiControl,, %hTxtCount%, 1 Item
                Break
            }
        }

        If (!LV_GetCount()) {
            ErrorMsg := GetErrorMessage(Filter + 1 - 1) ; ?
            If (ErrorMsg != "") {
                GuiControl,, %hTxtCount%
                Gui +OwnDialogs
                MsgBox 0, Error %Filter%, %ErrorMsg%
            } Else {
                GuiControl,, %hTxtCount%, Not found
            }
        }

        Return
    }

    LV_Delete()
    GuiControl -Redraw, %hLV%

    Total := 0
    Loop % Items.Length() {
        If (InStr(Items[A_Index][1], Filter) || InStr(Items[A_Index][2], Filter)) {
            LV_Add("", Items[A_Index][1], Items[A_Index][2])
            Total++
        }
    }

    GuiControl +Redraw, %hLV%
    LV_ModifyCol(1, 48)
    WinGetPos,,, GuiWidth
    LV_ModifyCol(2, GuiWidth - 84)

    GuiControl,, %hTxtCount%, % (Total == 0) ? "Not Found" : (Total == 1) ? "1 Item" : Total . " Items"
}

Save:
    Gui +OwnDialogs
    FileSelectFile SelectedFile, S16, Errors.txt, Save
    If (ErrorLevel) {
        Return
    }

    Output := ""
    Loop % LV_GetCount() {
        LV_GetText(ID, A_Index)
        LV_GetText(Message, A_Index, 2)
        Output .= ID . "`t" . Message . "`r`n"
    }

    FileDelete %SelectedFile%
    FileAppend % RTrim(Output, "`r`n"), %SelectedFile%
Return

SelectAll:
    Gui +LastFound
    GuiControlGet FocusedControl, Focus
    GuiControlGet SearchText,, Edit2
    If (FocusedControl == "Edit2" && SearchText != "") {
        Send ^A
    } Else {
        GuiControl Focus, %hLV%
        LV_Modify(0, "Select")
    }
Return

Copy:
    Gui +LastFound
    GuiControlGet FocusedControl, Focus
    GuiControlGet SearchText,, Edit2
    If (FocusedControl == "Edit2" && SearchText != "") {
        Send ^C
    } Else {
        ;ControlGet Selection, List, Selected, SysListView321 ; Truncates long messages
        Row := 0, Output := ""
        While (Row := LV_GetNext(Row)) {
            LV_GetText(ID, Row)
            LV_GetText(Message, Row, 2)

            Output .= ID . "`t" . Message . "`n"
        }
        Clipboard := RTrim(Output, "`n")
    }
Return

RandomBalloon:
    If (LV_GetCount() != Items.Length()) {
        Search()
    }

    Random Number, 0, %Total%
    LV_GetText(ErrorCode, Number)
    LV_GetText(ErrorMsg, Number, 2)
    GuiControl -Redraw, %hLV%
    LV_Modify(Total, "Vis")
    LV_Modify(Number, "Vis Select")
    GuiControl +Redraw, %hLV%
    Edit_ShowBalloonTip(hHiddenEdit, "Error " . ErrorCode, ErrorMsg, Number)
Return

Edit_ShowBalloonTip(hEdtSearch, Title, Text, Icon := 0) {
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(A_IsUnicode ? &Title : UTF16(Title, T), EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(A_IsUnicode ? &Text : UTF16(Text, M), EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdtSearch% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

UTF16(String, ByRef Var) {
    VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
    StrPut(String, &Var, "UTF-16")
    Return &Var
}

Speak:
    If (A_PtrSize == 8) {
        Return
    }

    GuiControlGet Ctl, FocusV
    If (Ctl == "LV" && Row := LV_GetNext()) {
        LV_GetText(ErrorMsg, Row, 2)
        Voice.Speak(ErrorMsg, 1) ; SVSFlagsAsync
    }
Return

OnlineRef:
    Try {
        Run https://msdn.microsoft.com/en-us/library/windows/desktop/ms681381(v=vs.85).aspx
    }
Return

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    Global

    If (wParam == 13) {
        If (hWnd == hEdtSearch) {
            GoSub Search
        } Else If (hWnd == hLV) {
            GoSub ShowMsgBox
        }
    }

    Else If (wParam == 32 && hWnd == hLV) {
        GoSub Speak
    }
}

ShowAbout:
    Gui 1: +Disabled
    Gui About: New, -SysMenu Owner1
    Gui Color, White
    Gui Add, Picture, x15 y16 w32 h32, %A_ScriptDir%\..\Icons\ErrorView.ico
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x56 y11 w120 h23 +0x200, ErrorView
    Gui Font, s9 cDefault, Segoe UI
    Gui Add, Text, x56 y34 w280 h18 +0x200, System Error Messages Lookup/Listing Tool v%Version%
    Gui Add, Text, x1 y72 w391 h48 -Background
    Gui Add, Button, gAboutGuiClose x299 y85 w80 h23 Default, &OK
    Gui Font
    Gui Show, w392 h120, About
Return

AboutGuiEscape:
AboutGuiClose:
    Gui 1: -Disabled
    Gui About: Destroy
Return

#Include %A_ScriptDir%\..\Lib\AutoXYWH.ahk
