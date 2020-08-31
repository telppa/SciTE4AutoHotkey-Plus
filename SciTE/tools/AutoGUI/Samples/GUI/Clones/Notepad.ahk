#NoEnv
#SingleInstance Off
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Global RecentFiles := [], MaxItems := 10

Menu Tray, Icon, Notepad.exe

Menu, FileMenu, Add, &New`tCtrl+N, MenuHandler
Menu, FileMenu, Add, &Open...`tCtrl+O, OpenFile
Menu, FileMenu, Add, &Save`tCtrl+S, MenuHandler
Menu, FileMenu, Add, Save &As..., MenuHandler
Menu, FileMenu, Add
Menu, FileMenu, Add, &Recent Files, MenuHandler
Menu, FileMenu, Disable, &Recent Files
Menu, FileMenu, Add
Menu, FileMenu, Add, Page Set&up..., MenuHandler
Menu, FileMenu, Add, &Print...`tCtrl+P, MenuHandler
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit, MenuHandler

Menu, EditMenu, Add, &Undo`tCtrl+Z, MenuHandler
Menu, EditMenu, Disable, &Undo`tCtrl+Z
Menu, EditMenu, Add
Menu, EditMenu, Add, Cut&`tCtrl+X, MenuHandler
Menu, EditMenu, Disable, Cut&`tCtrl+X
Menu, EditMenu, Add, &Copy`tCtrl+C, MenuHandler
Menu, EditMenu, Disable, &Copy`tCtrl+C
Menu, EditMenu, Add, &Paste`tCtrl+V, MenuHandler
Menu, EditMenu, Add, De&lete`tDel, MenuHandler
Menu, EditMenu, Disable, De&lete`tDel
Menu, EditMenu, Add
Menu, EditMenu, Add, &Find...`tCtrl+F, MenuHandler
Menu, EditMenu, Disable, &Find...`tCtrl+F
Menu, EditMenu, Add, Find &Next`tF3, MenuHandler
Menu, EditMenu, Disable, Find &Next`tF3
Menu, EditMenu, Add, &Replace...`tCtrl+H, MenuHandler
Menu, EditMenu, Add, &Go To...`tCtrl+G, MenuHandler
Menu, EditMenu, Disable, &Go To...`tCtrl+G
Menu, EditMenu, Add
Menu, EditMenu, Add, Select &All`tCtrl+A, MenuHandler
Menu, EditMenu, Add, Time/&Date`tF5, MenuHandler

Menu, FormatMenu, Add, &Word Wrap, MenuHandler
Menu, FormatMenu, Check, &Word Wrap
Menu, FormatMenu, Add, &Font..., MenuHandler

Menu, ViewMenu, Add, &Status Bar, MenuHandler
Menu, ViewMenu, Check, &Status Bar
Menu, ViewMenu, Disable, &Status Bar

Menu, HelpMenu, Add, View &Help, MenuHandler
Menu, HelpMenu, Add
Menu, HelpMenu, Add, &About Notepad, MenuHandler

Menu MenuBar, Add, File, :FileMenu
Menu MenuBar, Add, Edit, :EditMenu
Menu MenuBar, Add, Format, :FormatMenu
Menu MenuBar, Add, View, :ViewMenu
Menu MenuBar, Add, Help, :HelpMenu
Gui Menu, MenuBar

Gui Font, s10, Lucida Console
Gui Add, Edit, x0 y0 w797 h445 +Multi
Gui Font

Gui Font, s9, Segoe UI
Gui Add, StatusBar
SB_SetParts(598)
SB_SetText("  Ln 1, Col 1", 2)

Gui Show, w797 h468, Untitled - !Notepad
Return

MenuHandler:
Return

GuiEscape:
GuiClose:
    ExitApp

OpenFile:
    FileSelectFile SelectedFile, 3,, Open
    If (!ErrorLevel) {
        FileRead Text, %SelectedFile%
        GuiControl,, Edit1, %Text%
        AddToRecentFiles(SelectedFile)
    }
Return

OpenRecentFile:
    FileRead Text, %A_ThisMenuItem%
    GuiControl,, Edit1, %Text%
    AddToRecentFiles(A_ThisMenuItem)
Return

AddToRecentFiles(FileName) {
/*
    If !(FileExist(FileName)) {
        Return
    }
*/
    Loop % RecentFiles.Length() {
        If (FileName = RecentFiles[A_Index]) {
            Try {
                Menu RecentFilesMenu, Delete, %FileName%
            }
            RecentFiles.RemoveAt(A_Index)
            Break
        }
    }

    RecentFiles.Push(FileName)

    Menu FileMenu, Enable, &Recent Files
    Menu RecentFilesMenu, Insert, 1&, %FileName%, OpenRecentFile
    Try {
        Menu RecentFilesMenu, Icon, %FileName%, % "HICON:" . GetFileIcon(FileName)
    }
    Menu FileMenu, Add, &Recent Files, :RecentFilesMenu

    hRecentFilesMenu := MenuGetHandle("RecentFilesMenu")
    ItemCount := DllCall("GetMenuItemCount", "Ptr", hRecentFilesMenu)
    If (ItemCount > MaxItems) {
        DllCall("DeleteMenu", "Ptr", hRecentFilesMenu, "UInt", ItemCount - 1, "UInt", 0x400)
        RecentFiles.Remove(1)
    }
}

GetFileIcon(File, SmallIcon := 1) {
    VarSetCapacity(SHFILEINFO, cbFileInfo := A_PtrSize + 688)
    If (DllCall("Shell32.dll\SHGetFileInfoW"
        , "WStr", File
        , "UInt", 0
        , "Ptr" , &SHFILEINFO
        , "UInt", cbFileInfo
        , "UInt", 0x100 | SmallIcon)) { ; SHGFI_ICON
        Return NumGet(SHFILEINFO, 0, "Ptr")
    }
}
