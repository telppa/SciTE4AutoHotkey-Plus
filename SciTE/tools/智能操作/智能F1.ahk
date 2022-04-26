; 按 F1 键可在中文帮助中查询光标处单词。
; 2022.04.12 可以直接获取光标处单词了（不需要先选中单词了）。
; 2021.11.05 修复在帮助中打开查找框时切换帮助失败的问题。帮助的位置固定在 “SciTE\中文帮助\” 。
; 2021.06.27 “智能F1” 升级 2.2。使用 ACC 实现全后台操作，提升稳定性。
; 2020.07.24 “智能F1” 全面接管 F1 功能。
; 故需要屏蔽 “SciTEGlobal.properties” “platforms.properties” 文件中的自带 F1 功能。
智能F1:
  gosub, 中文帮助友好提示
return

中文帮助友好提示:
  中文帮助路径 := oSciTE.SciTEDir . "\中文帮助\AutoHotkey_CN.chm"
  if (!FileExist(中文帮助路径))     ; 中文帮助不存在，按 F1 没反应的情况下，友好的提示使用者该怎么做。
  {
    错误提示=
    (LTrim
    请自行于 GitHub 或 QQ 群下载帮助文件
    命名为 “AutoHotkey_CN.chm”
    存放于 “SciTE\中文帮助\AutoHotkey_CN.chm” 。
    )
    MsgBox, 262160, 没有找到中文帮助文件, %错误提示%
  }
return

#If WinActive("ahk_id " . SciTE_Hwnd)                    ; 限制 “智能F1” 的作用范围只在 scite 中。
F1::
  智能F1()
  {
    global 中文帮助PID, 中文帮助路径
    static oWB
    
    PID := 中文帮助PID
    
    WinGetPos, X, Y, W, H, ahk_pid %PID%
    if (PID="" or !(X+Y+W+H))                            ; 首次打开或窗口被最小化（为0）或窗口被关闭（为空）。
    {
      ; 某些时候最小化帮助后，获取到的坐标与大小全为0。
      ; 某些时候最小化帮助后，获取到的坐标为负大小为正。
      ; 前者无法被 WinActivate 或 WinRestore 还原。
      ; 后者则可以。
      ; 对于前者，只能杀进程后重开。
      if (X+Y+W+H=0)
        Process, Close, %PID%                            ; 帮助窗口最小化后无法激活，所以只能杀掉重开。
      
      Run, % 中文帮助路径,,,PID                          ; 打开帮助文件。
      中文帮助PID := PID
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
    
    WinClose, 查找 ahk_pid %PID%                         ; 关掉查找窗口，它存在会无法切换结果。
    
    word := oSciTE.Selection
    word := word ? word : oSciTE.GetWord
    
    ; 有2种方法可以直接让 chm 定位到某个页面中
    ; 1. hh.exe mk:@MSITStore:R:\AutoHotkey.chm::/docs/Variables.htm#IsCompiled
    ; 2. KeyHH.exe -MyID R:\AutoHotkey.chm::/docs/Variables.htm#IsCompiled
    ; 在浏览器中使用 search.htm?q=Call&m=1 可以跳到通过索引搜索单词 Call 的结果页面
    ; 但 hh.exe 和 KeyHH.exe 都不支持带参数的 htm 所以下面这个例子是失败的
    ; 3. KeyHH.exe -MyID R:\AutoHotkey.chm::/docs/search.htm?q=Call&m=1
    ; 所以只能用模拟的方式实现了
    oWB.getElementsByTagName("BUTTON")[2].click()        ; 索引按钮。
    oWB.querySelector("INPUT").value := word             ; 输入关键词。
    ControlSend, , {Enter}{Enter}, ahk_pid %PID%         ; 按两下回车进行搜索。
    oWB.getElementsByTagName("BUTTON")[1].click()        ; 目录按钮。
  }
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