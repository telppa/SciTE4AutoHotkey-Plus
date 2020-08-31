ParseScript(Source) {
    m.Code := ""

    Loop Parse, Source, `n, `r
    {
        ; Sets the Tabindex and Tabcontrol numbers for the current controls - RH
        If (A_LoopField ~= "i)Add, Tab(2|3)") {
            fTabControl++
        }

        If (RegExMatch(A_LoopField, "iO)^\s*?Gui\s*\,?\s*(\w+\:)?\s?Tab,\s?(?P<TabIndex>([\w\+\-\s]+))", Rex)) {
            fTabIndex := RegExReplace(Rex.TabIndex, "[\r\n]*")
        }

        ; Match menu item
        If (RegExMatch(A_LoopField, "iO)^Menu\s*\,?\s*(?P<MenuName>([\w]+)),\s?Add(,\s?(?P<MenuItem>.*),\s?(?P<GoSub>([\w\:]+)))?", Rex)) {
            m.Code .= "Menu " . Rex.MenuName . ", Add, " . Rex.MenuItem . ", " . Rex.GoSub . CRLF
            Menu % Rex.MenuName, Add, % Rex.MenuItem, % Rex.GoSub
        } Else If (RegExMatch(A_LoopField, "iO)^Menu\s*\,?\s*(?P<MenuName>([\w]+)),\s?Add", Rex)) {
            m.Code .= "Menu " . Rex.MenuName . ", Add`n"
            Menu % Rex.MenuName, Add
        }

        ; Match control
        If (RegExMatch(A_LoopField, "iO)^\s*?Gui\s*\,?\s*(\w+\:)?\s?Add,\s?(?P<Type>([A-Za-z]+)\d?),\s?(?P<Options>([\w\+\-\s]+))(,\s?(?P<Text>(.+)))?", Rex)) {
            ;OutputDebug % Rex.Type . ", " . Rex.Options . ", " . Rex.Text

            Options := ""
            Position := ""
            vVar := ""
            gLabel := ""
            hWndVar := ""
            Style := ""
            ExStyle := ""

            aOptions := StrSplit(Rex.Options, " ")
            For Each, Item in aOptions {
                If (Item ~= "i)\+?(Grid|Group|Vertical|VScroll)") {
                    Options .= Item . " "
                } Else If (Item ~= "i)^\+?v") {
                    vVar := RegExReplace(Item, "i)^\+?v")
                } Else If (Item ~= "i)^\+?g") {
                    gLabel := RegExReplace(Item, "i)^\+?g")
                } Else If (Item ~= "i)^\+?hWnd") {
                    hWndVar := RegExReplace(Item, "i)^\+?hWnd")
                } Else If (Item ~= "i)^(x|y)" || Item ~= "i)^(w|h)p" || Item ~= "i)^(w|h)\d+") {
                    Position .= Item . " "
                } Else If (InStr(Item, "0") == 1) {
                    Style := Item
                } Else If (InStr(Item, "E0") == 1) {
                    ExStyle := Item
                } Else {
                    Options .= Item . " "
                }
            }

            Styles := Style . Space(Style) . ExStyle

            TabPos := [fTabIndex, fTabControl] ; Controls Tab placement of controls - RH

            If (A_LoopField ~= "i)Add, Tab(2|3)") {
                TabPos := ""
            }

            If (Rex.Type = "StatusBar" && StatusBarExist()) {
                GuiControl %Child%: Show, msctls_statusbar321
            } Else {
                Try {
                    ; Puts the controls into the correct tab in GUI window - RH
                    If (fTabIndex) {
                        Gui %Child%: Tab, % TabPos[1], % TabPos[2]
                    }

                    Gui %Child%: Add, % Rex.Type, % "hWndhWnd " . Position . " " . Options . " " . Styles, % Rex.Text
                } Catch e {
                    MsgBox 0x10, Error, % RexType . ", " Position . " " . Options . " " . Styles . " " . Rex.Text
                }
            }

            If (Rex.Type = "TreeView") {
                Parent := TV_Add("TreeView")
                TV_Add("Child", Parent)
            }

            ClassNN := GetClassNN(hWnd)
            ;Register(hWnd, Type, ClassNN, Text,,,, Options, Extra, Styles, FontName, FontOptions, Anchor, TabPos)
            Register(hWnd, Rex.Type, ClassNN, Rex.Text, hWndVar, vVar, gLabel, Options,, Styles,,,, TabPos)

            g.ControlList.Insert(hWnd)
        }

        ; Match Gui Show
        If (RegExMatch(A_LoopField, "iO)^Gui\s?\,?\s?Show,\s?(?P<Options>([\w\s]+)),?\s?(?P<Title>(.+))?", Rex)) {
            Gui %Child%: Show, % Rex.Options, % Rex.Title
            g.Window.Title := Rex.Title
            Options := StrSplit(Rex.Options, " ")
            For Each, Item in Options {
                If (Item ~= "i)^\+?x") {
                    g.Window.x := RegExReplace(Item, "i)^\+?x")
                    g.Window.Center := 0
                    }
                If (Item ~= "i)^\+?y") {
                    g.Window.y := RegExReplace(Item, "i)^\+?y")
                    g.Window.Center := 0
                    }
                If (Item ~= "i)^\+?w")
                    g.Window.w := RegExReplace(Item, "i)^\+?w")
                If (Item ~= "i)^\+?h")
                    g.Window.h := RegExReplace(Item, "i)^\+?h")
            }
        }

    } ; End of the main parse loop

    If (m.Code != "") {
        m.Code .= "Gui Menu, MenuBar" . CRLF
        Gui %Child%: Menu, MenuBar
    }

    GenerateCode()
    Properties_Reload()
}
