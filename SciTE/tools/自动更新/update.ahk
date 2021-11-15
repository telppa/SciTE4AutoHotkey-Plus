Text=
(
2021.11.15  
    优化目录结构，将“user”目录完全还给用户，以后升级将不影响用户的自定义设置。  
    优化目录结构，将“SciTE”目录外的文件全部放置于目录中，方便手动安装。  
    优化目录结构，将所有“增强功能”放置在独立清晰的文件夹中。  
    优化目录结构，删除部分过时无用的文件。  
    移除过时的“ahkv2”代码与设置。  
    移除过时的“自动更新”代码。  
    字体安装改为非强制。  
    更新“AHK 正则终结者”到1.42。  
    更新“AHK 爬虫终结者”到3.9。  
    更新“AHK 脚本关联工具”到1.1。  
    更新“FindText”到8.6。  
    更新“Auto-GUI”到3.0.1。（提取自 Adventure IDE 3.0.3）  
    解除“Auto-GUI”对高分屏的限制。  
    禁止“Window Clone Tool”频繁刷新窗口。  
    更新“MagicBox”到1.0.4。（提取自 Adventure IDE 3.0.3）  
    更新“AHK-Rare”的自动翻译部分。  
    更新“Auto-Syntax-Tidy”的语法文件。  
    更新“SciTE交互示例”。  
    更新“智能F1”。  
    更新技巧说明。  
    更新遗漏的关键词。  
    更新高亮配色文件。  
    更新“中文帮助文件”到1.1.33.10。  
)

Result := MsgBoxEx(Text, "v20211115版已更新", "蓝奏云下载|Github 下载", 0, "", "AlwaysOnTop")

If (Result == "蓝奏云下载") {
	Run, https://ahk.lanzoui.com/i9oFkwjcm8d
} Else If (Result == "Github 下载") {
	Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
} Else If (Result == "Cancel") {
	ExitApp
}
ExitApp

MsgBoxEx(Text, Title := "", Buttons := "", Icon := "", ByRef CheckText := "", Styles := "", Owner := "", Timeout := "", FontOptions := "", FontName := "", BGColor := "", Callback := "") {
    Static hWnd, y2, p, px, pw, c, cw, cy, ch, f, o, gL, hBtn, lb, DHW, ww, Off, k, v, RetVal
    Static Sound := {2: "*48", 4: "*16", 5: "*64"}

    Gui New, hWndhWnd LabelMsgBoxEx -0xA0000
    Gui % (Owner) ? "+Owner" . Owner : ""
    Gui Font
    Gui Font, % (FontOptions) ? FontOptions : "s9", % (FontName) ? FontName : "Segoe UI"
    Gui Color, % (BGColor) ? BGColor : "White"
    Gui Margin, 10, 12

    If (IsObject(Icon)) {
        Gui Add, Picture, % "x20 y24 w32 h32 Icon" . Icon[1], % (Icon[2] != "") ? Icon[2] : "shell32.dll"
    } Else If (Icon + 0) {
        Gui Add, Picture, x20 y24 Icon%Icon% w32 h32, user32.dll
        SoundPlay % Sound[Icon]
    }

    Gui Add, Link, % "x" . (Icon ? 65 : 20) . " y" . (InStr(Text, "`n") ? 24 : 32) . " vc", %Text%
    GuicontrolGet c, Pos
    GuiControl Move, c, % "w" . (cw + 30)
    y2 := (cy + ch < 52) ? 90 : cy + ch + 34

    Gui Add, Text, vf -Background ; Footer

    Gui Font
    Gui Font, s9, Segoe UI
    px := 42
    If (CheckText != "") {
        CheckText := StrReplace(CheckText, "*",, ErrorLevel)
        Gui Add, CheckBox, vCheckText x12 y%y2% h26 -Wrap -Background AltSubmit Checked%ErrorLevel%, %CheckText%
        GuicontrolGet p, Pos, CheckText
        px := px + pw + 10
    }

    o := {}
    Loop Parse, Buttons, |, *
    {
        gL := (Callback != "" && InStr(A_LoopField, "...")) ? Callback : "MsgBoxExBUTTON"
        Gui Add, Button, hWndhBtn g%gL% x%px% w90 y%y2% h26 -Wrap, %A_Loopfield%
        lb := hBtn
        o[hBtn] := px
        px += 98
    }
    GuiControl +Default, % (RegExMatch(Buttons, "([^\*\|]*)\*", Match)) ? Match1 : StrSplit(Buttons, "|")[1]

    Gui Show, Autosize Center Hide, %Title%
    DHW := A_DetectHiddenWindows
    DetectHiddenWindows On
    WinGetPos,,, ww,, ahk_id %hWnd%
    GuiControlGet p, Pos, %lb% ; Last button
    Off := ww - (((px + pw + 14) * A_ScreenDPI) // 96)
    For k, v in o {
        GuiControl Move, %k%, % "x" . (v + Off)
    }
    Guicontrol MoveDraw, f, % "x-1 y" . (y2 - 10) . " w" . ww . " h" . 48

    Gui Show
    Gui +SysMenu %Styles%
    DetectHiddenWindows %DHW%

    If (Timeout) {
        SetTimer MsgBoxExTIMEOUT, % Round(Timeout) * 1000
    }

    If (Owner) {
        WinSet Disable,, ahk_id %Owner%
    }

    GuiControl Focus, f
    Gui Font
    WinWaitClose ahk_id %hWnd%
    Return RetVal

    MsgBoxExESCAPE:
    MsgBoxExCLOSE:
    MsgBoxExTIMEOUT:
    MsgBoxExBUTTON:
        SetTimer MsgBoxExTIMEOUT, Delete

        If (A_ThisLabel == "MsgBoxExBUTTON") {
            RetVal := StrReplace(A_GuiControl, "&")
        } Else {
            RetVal := (A_ThisLabel == "MsgBoxExTIMEOUT") ? "Timeout" : "Cancel"
        }

        If (Owner) {
            WinSet Enable,, ahk_id %Owner%
        }

        Gui Submit
        Gui %hWnd%: Destroy
    Return
}
