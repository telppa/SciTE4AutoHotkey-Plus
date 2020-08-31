OpenHelpFile(Keyword := "") {
    If (Keyword == "" || StrLen(Keyword) > 50) {
        Run hh mk:@MSITStore:%g_HelpFile%::/docs/AutoHotkey.htm
        Return
    }

    n := TabEx.GetSel()
    Pos := Sci[n].GetCurrentPos()

    If (Sci[n].GetCharAt(Sci[n].WordStartPosition(Pos, True) - 1) == 35) {
        Keyword := "_" . Keyword ; The keyword is a directive, but the "#" sign was not selected.
    }

    Keyword := StrReplace(Keyword, "#", "_",, 1) ; Replace # with _ in directives
    Keyword := Trim(Keyword, " `t.,:")

    Prefix := SubStr(Keyword, 1, 3)
    If (Prefix = "LV_" || Prefix = "IL_") {
        HTMLPage := "ListView.htm#" . Keyword

    } Else If (Prefix = "TV_") {
        HTMLPage := "TreeView.htm#" . Keyword

    } Else If (Prefix = "SB_") {
        HTMLPage := "GuiControls.htm#" . Keyword

    } Else If (Keyword = "StrPut" || Keyword = "StrGet") {
        HTMLPage := "StrPutGet.htm"

    } Else If (RegExMatch(Keyword, "i)Str(Len|Replace|Split)", Match)) {
        HTMLPage := "String" . Match1 . ".htm"

    } Else If (Keyword = "SendMessage") {
        HTMLPage := "PostMessage.htm"

    } Else If (Keyword = "RunWait") {
        HTMLPage := "Run.htm"

    } Else If (Keyword = "If") {
        HTMLPage := "IfExpression.htm"

    ; Gui events
    } Else If (Keyword ~= "i)^Gui(Close|Escape|Size|ContextMenu|DropFiles)$") {
        HTMLPage := "Gui.htm#" . Keyword

    ; Math functions
    } Else If (Keyword ~= "i)^(Abs|Ceil|Exp|Floor|Log|Ln|Mod|Round|Sqrt|Sin|Cos|Tan|ASin|ACos|ATan)$") {
        HTMLPage := "Math.htm#" . Keyword

    ; Object methods
    } Else If (RegExMatch(Keyword, "i)^(Insert(At)?|Remove(At)?|Push|Pop|Delete|(Min|Max)Index|Length|(Get|Set)Capacity|GetAddress|HasKey|Clone|Base|Count)$", Match)) {
        HTMLPage := "/docs/objects/Object.htm#" . (Keyword ~= "(Min|Max)Index" ? "MinMaxIndex" : Match)
    ; Length: the object method, not the file object property.
    } Else If (Keyword = "Length" && (Sci[n].GetCharAt(Sci[n].WordEndPosition(Pos, True) + 1) == "(")) {
        HTMLPage := "/docs/objects/Object.htm#Length"
    } Else If (Keyword = "_NewEnum") {
        HTMLPage := "/docs/objects/Object.htm#NewEnum"
    } Else If (Keyword = "ObjRelease") {
        HTMLPage := "ObjAddRef.htm"
    } Else If (Keyword ~= "i)Obj(RawGet|RawSet|GetBase|SetBase)") {
        HTMLPage := "/docs/objects/Object.htm#" . SubStr(Keyword, 4)

    ; GUI control types
    } Else If (Keyword ~= "i)^(Button|CheckBox|ComboBox|Custom|DateTime|DropDownList|GroupBox|Link|ListBox|MonthCal|Picture|Radio|Slider|StatusBar|Tab(2)?|Text|UpDown|ActiveX)$") {
        HTMLPage := "GuiControls.htm#" . Keyword
    } Else If (Keyword ~= "i)^(Hotkey|Progress|Edit)$") {
        If (GetCurrentLine() ~= "i)^\s*Gui") {
            HTMLPage := "GuiControls.htm#" . Keyword
        } Else {
            HTMLPage := Keyword . ".htm"
        }
    } Else If (Keyword = "Tab3") {
        HTMLPage := "GuiControls.htm#Tab"
    } Else If (Keyword = "DDL") {
        HTMLPage := "GuiControls.htm#DropDownList"
    } Else If (Keyword = "Pic") {
        HTMLPage := "GuiControls.htm#Picture"

    ; Built-in variables
    } Else If (SubStr(Keyword, 1, 2) = "A_") {
        If (Keyword ~= "i)A_LoopFile") {
            HTMLPage := "LoopFile.htm"
        } Else If (Keyword ~= "i)A_LoopReg") {
            HTMLPage := "LoopReg.htm"
        } Else If (Keyword = "A_LoopField") {
            HTMLPage := "LoopParse.htm"
        } Else If (Keyword = "A_LoopReadLine") {
            HTMLPage := "LoopReadFile.htm"
        } Else {
            HTMLPage := "/docs/Variables.htm#BuiltIn"
        }

    ; File object methods
    } Else If (Keyword ~= "i)^(Read|Write|ReadLine|WriteLine|RawRead|RawWrite|Seek|Pos(ition)|Tell|Length|AtEOF|Close|Encoding)$") {
        HTMLPage := "/docs/objects/File.htm#" . Keyword
    } Else If (RegExMatch(Keyword, "i)^(Read|Write)(U?(Int|Int64|Short|Char|Double|Float))$", Match)) {
        HTMLPage := "/docs/objects/File.htm#" . Match1 . "Num"
    } Else If (Keyword = "__Handle") {
        HTMLPage := "/docs/objects/File.htm#Handle"

    } Else If (Keyword = "True" || Keyword = "False") {
        HTMLPage := "Variables.htm#Boolean"

    } Else If (Keyword = "IfNotExist") {
        HTMLPage := "IfExist.htm"

    } Else If (Keyword ~= "i)_IfWin(Not)?(Active|Exist)") {
        HTMLPage := "_IfWinActive.htm"

    } Else If (Keyword ~= "i)(If)?Win(Not)?Exist") {
        HTMLPage := "WinExist.htm"

    } Else If (Keyword ~= "i)(If)?Win(Not)?Active") {
        HTMLPage := "WinActive.htm"

    } Else If (Keyword ~= "i)GetKey(Name|VK|SC)") {
        HTMLPage := "GetKey.htm"

    ; Function object methods
    } Else If (Keyword ~= "i)^(Call|Bind|Name|IsBuiltIn|IsVariadic|MinParams|MaxParams|IsByRef|IsOptional)$") {
        HTMLPage := "/docs/objects/Func.htm#" . Keyword

    } Else If (Keyword = "HICON" || Keyword = "HBITMAP") {
        HTMLPage := "/docs/misc/ImageHandles.htm"

    } Else If (Keyword ~= "i)^(Clipboard|WinTitle|Arrays|ErrorLevel|Labels|Styles|Threads)$") {
        HTMLPage := "/docs/misc/" . Keyword . ".htm"

    } Else If (Keyword = "ClipboardAll") {
        HTMLPage := "/docs/misc/Clipboard.htm#ClipboardAll"

    } Else If (Keyword ~= "i)^(Object|Func|File)$") {
        HTMLPage := "/docs/objects/" . Keyword . ".htm"

    } Else If (Keyword = "StringTrimRight") {
        HTMLPage := "StringTrimLeft.htm"

    } Else If (Keyword = "_IncludeAgain") {
        HTMLPage := "_Include.htm"

    } Else If (RegExMatch(Keyword, "i)(Join|LTrim)", Match)) {
        HTMLPage := "/docs/Scripts.htm#" . Match1

    } Else If (Keyword = "Exception") {
        HTMLPage := "Throw.htm#Exception"

    } Else If (Keyword = "SendInput") {
        HTMLPage := "Send.htm#SendInputDetail"

    } Else If (Keyword ~= "i)^(Functions|Objects|FAQ|Hotkeys|Hotstrings|KeyList|Scripts|Tutorial|Variables)$") {
        HTMLPage := "/docs/" . Keyword . ".htm"

    } Else {
        HTMLPage := Keyword . ".htm"
    }

    If (!InStr(HTMLPage, "/")) {
        HTMLPage := "/docs/commands/" . HTMLPage
    }

    Run hh mk:@MSITStore:%g_HelpFile%::%HTMLPage%
}
