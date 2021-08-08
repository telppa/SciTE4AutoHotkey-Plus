GenerateCode() {
    Local Item ; ...

    If (!WinExist("ahk_id" . hChildWnd)) {
        GoSub NewGUI
    }

    Header := "#SingleInstance Force" . CRLF
            . "#NoEnv" . CRLF
            . "SetWorkingDir `%A_ScriptDir`%" . CRLF
            . "SetBatchLines -1" . CRLF

    Code := ""

    Includes := ""
    If (g.Anchor) {
        Includes .= "#Include %A_ScriptDir%\AutoXYWH.ahk" . CRLF
    }
    If (TB := ToolbarExist()) {
        Includes .= "#Include %A_ScriptDir%\Toolbar.ahk" . CRLF
    }
    If (g.ControlColor) {
        Includes .= "#Include %A_ScriptDir%\ControlColor.ahk" . CRLF
    }
    If (Includes != "") {
        Header .= CRLF . Includes
    }

    If (Header != "") {
        Header .= CRLF
    }

    If (g.Window.Icon != "") {
        Code .= "Menu Tray, Icon, " . g.Window.Icon . ((g.Window.IconIndex > 1) ? ", " . g.Window.IconIndex : "") . CRLF . CRLF
    }

    GuiOptions := ""
    GuiOptions .= (g.Window.Label != "") ? " +Label" . g.Window.Label : ""
    GuiOptions .= (g.Window.hWndVar != "") ? " +hWnd" . g.Window.hWndVar : ""
    GuiOptions .= (g.Window.Options != "") ? " " . g.Window.Options : ""
    GuiOptions .= (g.Window.Extra != "") ? " " . g.Window.Extra : ""

    NewIsNeeded := False
    If (g.Window.Styles != "") {
        GuiOptions .= " " . g.Window.Styles

        ; Overwrite window style?
        If (RegExMatch(g.Window.Styles, "(?<![\+\-])E?0")) { ; Negative look-behind
            NewIsNeeded := True
        }
    }

    GuiName := ""
    If (g.Window.Name != "") {
        GuiName := " " . g.Window.Name . ": New"
        If (GuiOptions != "") {
            GuiName .= ","
        }
    } Else If (NewIsNeeded) {
        GuiName := " New,"
    }

    If (GuiOptions != "" || GuiName != "") {
        Code .= "Gui" . GuiName . GuiOptions . CRLF
    }

    Spc := Space(g.Window.FontOptions)
    Sep := (g.Window.FontName != "") ? ", " : ""
    If (g.Window.FontOptions != "" || g.Window.FontName != "") {
        GuiFont := "Gui Font," . Spc . g.Window.FontOptions . Sep . g.Window.FontName . CRLF
        Code .= GuiFont
    } Else {
        GuiFont := ""
    }

    If (g.Window.Color != "") {
        Code .= "Gui Color, " . g.Window.Color . CRLF
    }

    ; Menu
    If (m.Code != "") {
        Code .= m.Code . CRLF
    }

    OrderTabItems()
    fTab := False

    ; Controls
    For Each, Item in g.ControlList {
        If (g[Item].Deleted == False) {
            If (g[Item].Text == "" && g[Item].Type != "DateTime") {
                ControlGetText Text,, ahk_id %Item%
            } Else {
                Text := g[Item].Text
            }

            Gui %Child%: Default

            GuiControlGet c, %Child%: Pos, %Item%

            If (g[Item].Tab[1] != "") {
                If (g[Item].Tab[1] != PreviousTab[1] || g[Item].Tab[2] != PreviousTab[2]) {
                    If (g[Item].Tab[2] == 1) {
                        Code .= "Gui Tab, " . g[Item].Tab[1] . CRLF
                    } Else {
                        Code .= "Gui Tab, " . g[Item].Tab[1] . ", " . g[Item].Tab[2] . CRLF
                    }
                }
            }

            PreviousTab := g[Item].Tab

            fFont := False
            Spc := Space(g[Item].FontOptions)
            Sep := (g[Item].FontName != "") ? ", " : ""
            If (g[Item].FontOptions != "" || g[Item].FontName != "") {
                fFont := True
                If (GuiFont != "") {
                    Code .= "Gui Font" . CRLF
                }
                Code .= "Gui Font," . Spc . g[Item].FontOptions . Sep . g[Item].FontName . CRLF
            }

            If (g[Item].Type == "Tab2") {
                CtlType := "Tab3"
                fTab := True
            } Else If (g[Item].Type == "CommandLink") {
                CtlType := "Custom"
            } Else If (g[Item].Type == "Separator") {
                CtlType := "Text"
            } Else {
                CtlType := g[Item].Type
            }

            Code .= "Gui Add, " . CtlType . ", "

            If (g[Item].hWndVar != "") {
                Code .= "hWnd" . g[Item].hWndVar . " "
            }

            If (g[Item].vVar != "") {
                Code .= "v" . g[Item].vVar . " "
            }

            If (g[Item].gLabel != "") {
                Code .= "g" . g[Item].gLabel . " "
            }

            If (CtlType == "ComboBox" || CtlType == "DropDownList") {
                Code .= "x" . cX . " y" . cY . " w" . cW
            } Else If (CtlType == "StatusBar") {
                Code := RTrim(Code, " ")
            } Else {
                Code .= "x" . cX . " y" . cY . " w" . cW . " h" . cH
            }

            If (g[Item].Options != "") {
                Code .= " " . g[Item].Options
            }

            If (g[Item].Extra != "") {
                Code .= " " . Trim(g[Item].Extra) ; ?
            }

            If (g[Item].Styles != "") {
                Code .= " " . g[Item].Styles
            }

            If (Text != "") {
                If (SubStr(Text, 1, 1) == " ") {
                    Text := "% """ . Text . """"
                }
                Code .= ", " . Text
            }

            Code .= CRLF

            If (fFont) {
                Code .= "Gui Font" . CRLF
                If (GuiFont != "" && A_Index != g.ControlList.Length()) {
                    Code .= GuiFont
                }
            }

            If (g[Item].ExplorerTheme) {
                Code .= "DllCall(""UxTheme.dll\SetWindowTheme"", ""Ptr"", "
                     . g[Item].hWndVar . ", ""WStr"", ""Explorer"", ""Ptr"", 0)" . CRLF
            }

            If (g[Item].HintText != "") {
                If (g[Item].Type == "Edit") {
                    Code .= "SendMessage 0x1501, 1, """ . g[Item].HintText
                         . """,, ahk_id %" . g[Item].hWndVar . "% `; EM_SETCUEBANNER" . CRLF

                } Else { ; ComboBox
                    Code .= "hCbxEdit := DllCall(""GetWindow"", ""Ptr"", " . g[Item].hWndVar
                         . ", ""UInt"", 5, ""Ptr"") `; GW_CHILD" . CRLF
                    Code .= "SendMessage 0x1501, 1, """ . g[Item].HintText
                         . """,, ahk_id %hCbxEdit% `; EM_SETCUEBANNER" . CRLF
                }
            }

            If (g[Item].UACShield) {
                Code .= "SendMessage 0x160C, 0, 1,, ahk_id %" . g[Item].hWndVar . "% `; BCM_SETSHIELD" . CRLF
            }

            If (g[Item].BGColor != "") {
                Code .= "ControlColor(" . g[Item].hWndVar . ", " . g.Window.hWndVar . ", " . g[Item].BGColor
                If (g[Item].FGColor != "") {
                    Code .= ", " . g[Item].FGColor
                }
                Code .= ")" . CRLF
            }
        }
    }

    If (fTab) {
        Code .= "Gui Tab" . CRLF
    }

    If (g.ControlList.Length() && !(g.ControlList.Length() == 1 && g[g.ControlList[1]].Deleted)) {
        Code .= CRLF
    }

    ; Gui Show
    WI := GetWindowInfo(hChildWnd)
    Position := (g.Window.Center) ? "" : "x" . WI.WindowX . " y" . WI.WindowY . " "
    Code .= "Gui Show, " . Position . "w" . WI.ClientW . " h" . WI.ClientH

    If (g.Window.Title != "") {
        Code .= ", " . g.Window.Title
    }
    Code .= CRLF

    If (TB) {
        Code .= CRLF . "hToolbar := CreateToolbar()" . CRLF
    }

    If (g.Window.OnClipboardChange && g.Window.EvtFunc) {
        Code .= CRLF . "OnClipboardChange(""ClipChanged"")" . CRLF
    }

    If (g.WinEvents1 != CRLF) {
        Code .= g.WinEvents1
    }

    Code .= "Return" . CRLF ; End of the auto-execute section

    Code .= g_MenuFuncs

    ; Labels/functions
    Code .= g.ControlFuncs

    If (g.Window.Label == "") {
        Label := (g.Window.Name != "") ? g.Window.Name . "Gui" : "Gui"
    } Else {
        Label := g.Window.Label
    }

    Minimized := CRLF . Indent . "If (A_EventInfo == 1) {" . CRLF . Indent . Indent . "Return" . CRLF . Indent . "}" . CRLF

    If (g.Window.GuiSize) {
        Code .= CRLF . Label . "Size"
        If (g.Window.EvtFunc) {
            Code .= "(GuiHwnd, EventInfo, Width, Height) {" . CRLF . Indent . "Global" . Minimized
        } Else {
            Code .= ":" . Minimized
        }

        If (g.Anchor) {
            For Each, hCtrl In g.ControlList {
                If (g[hCtrl].Anchor != "" && !g[hCtrl].Deleted) {
                    Code .= CRLF . Indent . "AutoXYWH(""" . g[hCtrl].Anchor . """, " . g[hCtrl].hWndVar . ")"
                }
            }
        }

        If (TB && !InStr(Toolbar.Options, "Vertical")) {
            Code .= CRLF . Indent . "GuiControl Move, %hToolBar%, w%A_GuiWidth%"
        }

        Code .= CRLF . (g.Window.EvtFunc ? "}" : "Return") . CRLF
    }

    If (g.Window.GuiContextMenu) {
        Code .= CRLF . Label . "ContextMenu"
        If (g.Window.EvtFunc) {
            Code .= "(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {" . CRLF . CRLF
        } Else {
            Code .= ":" . CRLF
        }

        If (m.Context != "") {
            Code .= Indent . "Menu " . m[ContextMenuId].Command . ", Show" . CRLF
        }

        Code .= (g.Window.EvtFunc ? "}" : "Return") . CRLF
    }

    If (g.Window.GuiDropFiles) {
        Code .= CRLF . Label . "DropFiles"
        If (g.Window.EvtFunc) {
            Code .= "(GuiHwnd, FileArray, CtrlHwnd, X, Y) {" . CRLF . CRLF . "}" . CRLF
        } Else {
            Code .= ":" . CRLF . "Return" . CRLF
        }
    }

    If (g.Window.OnClipboardChange) {
        If (g.Window.EvtFunc) {
            Code .= CRLF . "ClipChanged(Type) {" . CRLF . CRLF . "}" . CRLF
        } Else {
            Code .= CRLF . "OnClipboardChange:" . CRLF . "Return" . CRLF
        }
    }

    If (g.Window.GuiEscape) {
        Code .= CRLF . Label . "Escape"
        If (g.Window.EvtFunc) {
            Code .= "(GuiHwnd) {" . CRLF . Indent . "ExitApp" . CRLF . "}" . CRLF
        } Else {
            Code .= ":"
            If (!g.Window.GuiClose) {
                Code .= CRLF . Indent . "ExitApp" . CRLF
            }
        }
    }

    If (g.Window.GuiClose) {
        Code .= CRLF . Label . "Close"
        If (g.Window.EvtFunc) {
            Code .= "(GuiHwnd) {" . CRLF . Indent . "ExitApp" . CRLF . "}" . CRLF
        } Else {
            Code .= ":" . CRLF . Indent . "ExitApp" . CRLF
        }
    }

    Code .= g.WinEvents2

    If (TB) {
        Code .= CRLF . "CreateToolbar() {" . CRLF

        If (!InStr(Toolbar.Options, "TextOnly")) {
            TBIL := " ImageList"

            Code .= Indent . "ImageList := IL_Create(" . Toolbar.Buttons.Length() . ")" . CRLF

            For Each, Item in Toolbar.Buttons {
                If (Item.Text == "") {
                    Continue
                }
                Code .= Indent . "IL_Add(ImageList, """ . Item.Icon . """, " . Item.IconIndex . ")" . CRLF
            }

            Code .= CRLF
        } Else {
            TBIL := ""
        }

        ToolbarButtons := ""
        For Each, Item in Toolbar.Buttons {
            ButtonText := (Item.Text == "") ? "-" : Item.Text

            If (Item.State != "" && Item.Style != "") {
                ButtonOptions := ",," . Item.State . "," . Item.Style
            } Else If (Item.Style != "") {
                ButtonOptions := ",,," . Item.Style
            } Else If (Item.State != "") {
                ButtonOptions := ",," . Item.State
            } Else {
                ButtonOptions := ""
            }

            ToolbarButtons .= Indent . Indent . ButtonText . ButtonOptions . CRLF
        }

        Code .= Indent . "Buttons = " . CRLF . Indent . "(LTrim" . CRLF . ToolbarButtons . Indent . ")" . CRLF . CRLF
        Code .= Indent . "Return ToolbarCreate(""OnToolbar"", Buttons," . TBIL . ", """ . Toolbar.Options . """)" . CRLF
        Code .= "}" . CRLF . CRLF . "OnToolbar(hWnd, Event, Text, Pos, Id) {" . CRLF
        Code .= Indent . "If (Event != ""Click"") {" . CRLF . Indent . Indent . "Return" . CRLF . Indent . "}" . CRLF . CRLF

        For Each, Item in Toolbar.Buttons {
            If (Item.Text == "") {
                Continue
            }

            If (A_Index == 1) {
                Code .= Indent . "If (Text == """ . Item.Text . """) {" . CRLF . CRLF
            } Else {
                Code .= Indent . "} Else If (Text == """ . Item.Text . """) {" . CRLF . CRLF
            }
        }

        Code .= Indent . "}" . CRLF . "}"
    }

    Sci.SetReadOnly(0)
    Sci.BeginUndoAction()
    Sci.ClearAll()
    Sci.SetText("", g_Signature . Header . Code, 2)
    Sci.EndUndoAction()
    Sci.SetReadOnly(1)

    Header := Code := SciText := ""
}

SetIndent() {
    Indent := g_IndentWithSpaces ? Format("{1: " . g_TabSize . "}", "") : "`t"
}
