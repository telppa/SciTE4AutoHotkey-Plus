Text=
(
2021.03.28  
    字体完美等宽。  
    默认使用空格缩进。（不影响咱的缩进显示效果同时能让其它编辑器显示效果更好）  
    更新帮助文件到1.1.33.06。  
    优化帮助文件显示位置与查找速度，默认使用暗黑模式，并增加两个匹配中文的示例。  
    增加工具“FindText”，找字识图取色，简单易用高效。（作者飞跃，博客地址：https://blog.csdn.net/xshlong1981?t=1）  
    优化 Toolbar 运行模式，降低部分机器出错可能。  
    “AHK 正则终结者”里再增加一个匹配中文的示例。  
    修复窗口信息工具“AHK_Window_Info”复制 ClassNN 时的错误前缀。  
    进一步降低配色对比度与饱和度。  

2021.03.17  
    更新“AHK 爬虫终结者”到2.0。（使用了 tmplinshi 的 JSONEditor）  
    关闭“Window Clone Tool”频繁刷新窗口。  

2021.03.10  
    “AHK 正则终结者”里增加一个匹配中文的示例。（帮助文件正则一章里的语法是错的！）  
    修复了一个也许会导致 com 接口有问题的问题。  
    “发送原义字符”增加花括号。  
    进一步降低配色对比度与饱和度。  
    自动完成将在匹配第2个字时才工作。  

2021.02.24  
    更新“AhkSpy”到4.76。  
    删除部分无用文件。  

2021.02.09  
    增加一个遗漏的关键字“Unreachable ”。  

2021.01.21  
    增加一个遗漏的关键字“Parent”。  

2021.01.11  
    汉化了脚本片段功能。（来自群友“快乐就好”的支持）  
)

Result := MsgBoxEx(Text, "v20210328版已更新", "蓝奏云下载|Github 下载", 0, "", "AlwaysOnTop")

If (Result == "蓝奏云下载") {
	Run, https://ahk.lanzous.com/i7z6Qnfmj2b
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
