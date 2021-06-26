中文帮助友好提示:
  中文帮助路径 := oSciTE.SciTEDir . "\..\AutoHotkey_CN.chm"
  if (!FileExist(中文帮助路径))     ; 中文帮助不存在，按 F1 没反应的情况下，友好的提示使用者该怎么做。
  {
    错误提示=
    (LTrim
    请自行于 GitHub 或 QQ 群下载帮助文件
    命名为 “AutoHotkey_CN.chm”
    存放于 “AutoHotkey.exe” 所在位置。
    )
    MsgBox, 262160, 没有找到中文帮助文件, %错误提示%
  }
return

; 2021.06.19 “智能F1” 升级 2.0。使用 ACC 实现全后台操作，提升稳定性。
; 2020.07.24 “智能F1” 全面接管 F1 功能。
; 故需要屏蔽 “SciTEUser.properties” “platforms.properties” 文件中的自带 F1 功能。
#If WinActive("ahk_id " . SciTE_Hwnd)                  ; 限制 “智能F1” 的作用范围只在 scite 中。
F1::
  Send, ^{Left}^+{Right}
  Sleep, 50                                            ; 延时是必须的，否则偶尔会取不到词。
  光标下单词:=Trim(oSciTE.Selection(), " `t`r`n`v`f")  ; 把两侧的空白符去掉，不然 “else” 无法被正确激活。

  WinGetPos, X, Y, W, H, ahk_pid %PID%
  if (PID="" or X+Y+W+H=0)                             ; 首次打开或窗口被最小化。
  {
    if (X+Y+W+H=0)
      Process, Close, %PID%                            ; 帮助窗口最小化后无法激活，所以只能杀掉重开。

    Run, % 中文帮助路径,,,PID                          ; 打开帮助文件。
    WinWait, ahk_pid %PID%                             ; 这行不能少，否则初次打开无法输入文本并搜索。
    WinActivate, ahk_pid %PID%                         ; 这行不能少，否则初次打开无法输入文本并搜索。

    SysGet, WorkArea, MonitorWorkArea, 1               ; 获取工作区尺寸，即不含任务栏的屏幕尺寸。
    DPIScale:=A_ScreenDPI/96
    W:=(WorkAreaRight-WorkAreaLeft)//2
    X:=WorkAreaLeft+W+(-1+8)*DPIScale
    Y:=WorkAreaTop
    H:=WorkAreaBottom-Y+(-1+8)*DPIScale
    WinMove, ahk_pid %PID%,, X, Y, W, H                ; 显示在屏幕右侧并占屏幕一半尺寸。

    oWB:=IE_GetWB(PID).document                        ; 获取帮助文件的对象。
  }

  WinActivate, ahk_pid %PID%                           ; 激活。

  oWB.getElementsByTagName("BUTTON")[2].click()        ; 索引按钮。
  oWB.querySelector("INPUT").value := 光标下单词       ; 输入关键词。
  ControlSend, , {Enter}{Enter}, ahk_pid %PID%         ; 按两下回车进行搜索。
  oWB.getElementsByTagName("BUTTON")[1].click()        ; 目录按钮。
return
#If

IE_GetWB(PID) { ; get the parent windows & coord from the element
  IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
  , IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"

  WinGet, ControlListHwnd, ControlListHwnd, ahk_pid %PID%
  for k, v in StrSplit(ControlListHwnd, "`n", "`r")
  {
    WinGetClass, sClass, ahk_id %v%
    if (sClass = "Internet Explorer_Server")
    {
      hCtl := v
      break
    }
  }

  if !(sClass == "Internet Explorer_Server")
  ; document property will fail if no valie com object
  or !(oDoc := ComObject(9, ComObjQuery(Acc_ObjectFromWindow(hCtl), IID_IHTMLWindow2, IID_IHTMLWindow2), 1).document)
      return

  oWin := ComObject(9, ComObjQuery(oDoc, IID_IHTMLWindow2, IID_IHTMLWindow2), 1)
  return, oWB := ComObject(9, ComObjQuery(oWin, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)
}

Acc_Init()
{
  Static  h
  If Not  h
    h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
  Acc_Init()
  If  DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
  Return  ComObjEnwrap(9,pacc,1)
}