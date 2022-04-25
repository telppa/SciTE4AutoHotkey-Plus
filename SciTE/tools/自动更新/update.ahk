网址=
(`%
https://raw.githubusercontent.com/telppa/SciTE4AutoHotkey-Plus/master/README.md
)
请求头=
(`%
User-Agent:Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3314.0 Safari/537.36 SE 2.X MetaSr 1.0
)
返回值:=WinHttp.Download(网址, 设置, 请求头, 提交数据)

; 从 README.md 中提取当前更新信息
if (返回值!="")
{
    更新日志:=strMatch(返回值, "- 更新日志：", "<details>")
    
    RegExMatch(更新日志, "m)^> ([\d\.]{10})", 版本号)
    版本号:= "v" StrReplace(版本号1, ".")                             ; 2022.04.25 -> v20220425
    
    更新日志:=RegExReplace(更新日志, "m)^[ \t]*$\r\n", "")            ; 移除空行
    更新日志:=RegExReplace(更新日志, "m)^> ([\d\.]{10})", "$1`r`n")   ; 移除 “> ”
    更新日志:=RegExReplace(更新日志, "m)^> \* ", "    ")              ; 移除 “> * ”
    
    link_github:=Trim(strMatch(t, "[Github](", """"), " `t`r`n`v`f")  ; github 链接
    link_lanzou:=Trim(strMatch(t, "[蓝奏云](", """"), " `t`r`n`v`f")  ; lanzou 链接
    
    if (更新日志="" or 版本号="" or link_github="" or link_lanzou="")
        gosub, GFW
    
    Result := MsgBoxEx(更新日志, 版本号 "版已更新", "蓝奏云下载|Github 下载|主页", 0, "", "AlwaysOnTop")
    
    If (Result == "蓝奏云下载") {
      Run, %link_lanzou%
    } Else If (Result == "Github 下载") {
      Run, %link_github%
    } Else If (Result == "主页") {
      Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
    } Else If (Result == "Cancel") {
      ExitApp
    }
}
else
    gosub, GFW
return

GFW:
    说明 := "因为 GFW 的屏蔽，无法收到详细更新日志。`n请尝试点击下方按钮进行手动下载。"
    
    Result := MsgBoxEx(说明, "检测到新版 SciTE4AutoHotkey-Plus", "Github 下载|主页", 0, "", "AlwaysOnTop")
    
    If (Result == "Github 下载") {
      Run, %link_github%
    } Else If (Result == "主页") {
      Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
    } Else If (Result == "Cancel") {
      ExitApp
    }
    
    ExitApp
return

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

; 例如 strMatch("<em>123</em>", "<e", "m>") 将返回 “m>123</e”
; 例如 strMatch("<em>123</em><em>456</em>", "<e", "m>", 2) 将返回 “m>456</e”
strMatch(text, strStart, strEnd, occurrence := 1, caseSensitive := false)
{
	if (text="" or strStart="" or strEnd="")
		return
	
	posStart := InStr(text, strStart, caseSensitive, 1, occurrence)
	if (posStart=0)
		return
	
	posEnd := InStr(text, strEnd, caseSensitive, posStart+StrLen(strstart))
	if (posEnd=0)
		return
	
	return, SubStr(text, posStart, posEnd-posStart)
}

#Include %A_LineFile%\..\..\AHK 爬虫终结者\Lib\WinHttp.ahk