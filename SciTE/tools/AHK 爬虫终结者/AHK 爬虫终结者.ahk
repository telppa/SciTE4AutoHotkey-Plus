/*
主要更新日志：
  2022.04.18
    调整界面大小， DPI 缩放下显示起来更好看。
    版本号 3.9.4。
  2021.11.15
    使用新界面。
    更新 WinHttp 库为 3.9。
    版本号 3.9。
  2021.06.29
    更智能的库引用，生成的代码无需手动引用。
    版本号 3.4
  2021.04.11
    更新 WinHttp 库为 3.2。
    版本号 3.2。
  2021.03.17
    返回值框使用 JSONEditor 。
    版本号 2.0。
  2020.09.07
    修正模板。
    修正默认请求头。
    增加库文件提示。
    增加主页。
    版本号 1.1。
*/
#SingleInstance Force
#NoEnv

界面:
  ; 设置图标必须放第一行，否则失效。
  Menu, Tray, Icon, %A_ScriptDir%\爬虫.ico
  
  Gui, Font, s9, 微软雅黑
  
  Gui, Add, GroupBox, w492 h516, 输入
  
  ; 网址框
  Gui, Add, Edit, Section xp+10 yp+36 w472 h48 v网址,https://www.baidu.com/
  
  ; 设置框
  Gui, Add, Edit, xs y+29 w120 h24 vMethod HwndhMethod
  Gui, Add, Edit, x+56 yp w120 h24 vEnableRedirects HwndhEnableRedirects
  Edit_SetCueBanner(hMethod, "请求方法", True)
  Edit_SetCueBanner(hEnableRedirects, "重定向", True)
  Gui, Add, Button, x+56 yp w120 h24 g导入设置, 从剪贴板导入设置
  
  Gui, Add, Edit, xs y+5 w120 h24 vCharset HwndhCharset
  Gui, Add, Edit, x+56 yp w120 h24 vURLCodePage HwndhURLCodePage
  Edit_SetCueBanner(hCharset, "网页字符集", True)
  Edit_SetCueBanner(hURLCodePage, "URL 代码页", True)
  Gui, Add, Button, x+56 yp w120 h24 g导出设置, 导出设置到剪贴板
  
  Gui, Add, Edit, xs y+5 w120 h24 vTimeout HwndhTimeout
  Gui, Add, Edit, Section xp y+1 w120 h24 vConnectTimeout HwndhConnectTimeout
  Gui, Add, Edit, xp y+1 w120 h24 vDownloadTimeout HwndhDownloadTimeout
  Edit_SetCueBanner(hTimeout, "超时", True)
  Edit_SetCueBanner(hConnectTimeout, "连接超时", True)
  Edit_SetCueBanner(hDownloadTimeout, "下载超时", True)
  
  Gui, Add, Edit, x+56 ys w120 h24 vExpectedStatusCode HwndhExpectedStatusCode
  Gui, Add, Edit, xp y+1 w120 h24 vNumberOfRetries HwndhNumberOfRetries
  Edit_SetCueBanner(hExpectedStatusCode, "期望的状态码", True)
  Edit_SetCueBanner(hNumberOfRetries, "重试次数", True)
  
  Gui, Add, Edit, x+56 ys w120 h24 vProxy HwndhProxy
  Gui, Add, Edit, xp y+1 w120 h24 vProxyBypassList HwndhProxyBypassList
  Edit_SetCueBanner(hProxy, "代理服务器", True)
  Edit_SetCueBanner(hProxyBypassList, "代理服务器白名单", True)
  
  ; 请求头框
  Gui, Add, Edit, xs y+29 w472 h72 -Wrap v请求头,
  (LTrim
  GET /s?&wd=ggh HTTP/1.1
  User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3314.0 Safari/537.36 SE 2.X MetaSr 1.0
  )
  
  ; 提交数据框
  Gui, Add, Edit, xs y+29 w472 h72 v提交数据,
  
  ; 发送按钮
  Gui, Add, Button, xs-1 y+10 w474 h49 g发送, 发送
  
  ; 返回值框。 ActiveX 必须放 GroupBox 前面，否则显示不出来。
  h := calculateHeight("48+29+24+5+24+5+24+1+24+1+24+29+72")  ; 左侧对应控件的高度挨个缩放再四舍五入最后累和
  Gui, Add, ActiveX, Section vWB x522 y42 w472 h%h%, %A_ScriptDir%\jsoneditor-5.15.0\jsonEditor.html
  Gui, Add, GroupBox, x512 y6 w492 h516, 输出
  
  ; 响应头与代码框。这里必须使用控件 v提交数据 的 y 坐标，否则 150% 缩放下位置不正常。
  GuiControlGet, 提交数据Pos_, Pos, 提交数据
  h := calculateHeight("72+10+48")
  Gui, Add, Edit, xs y%提交数据Pos_Y% w231 h%h% -Wrap v响应头,
  Gui, Add, Edit, x+10 yp w231 h130 -Wrap v代码,
  
  ; 标签
  Gui, Add, Text, x72 y17 w372 h24 +0x200 Center, 网址
  Gui, Add, Text, x72 y+53 w372 h24 +0x200 Center, 设置
  Gui, Add, Text, x72 y+137 w372 h24 +0x200 Center, 请求头
  Gui, Add, Text, Section x72 y+77 w372 h24 +0x200 Center, 提交数据
  Gui, Add, Text, x572 y17 w372 h24 +0x200 Center, 返回值
  Gui, Add, Text, Section x572 ys w131 h24 +0x200 Center, 响应头
  Gui, Add, Text, xs+241 ys w131 h24 +0x200 Center, 代码
  
  Gui, Add, StatusBar, v状态栏, %A_Space%%A_Space%%A_Space%%A_Space%主页
  SB_SetParts(80)
  
  Gui, Show, , AHK 爬虫终结者 v3.9.4
  
  gosub, 智能库引用
  
  OnMessage(0x6, "WM_ACTIVATE")                   ; 监视窗口是否激活
  OnMessage(0x200, "WM_MouseMove")                ; 监视鼠标移动消息
  OnMessage(0x201, "WM_LButtonDOWN")              ; 监视鼠标点击消息
  OnMessage(WM_KEYDOWN:=0x100, "gui_KeyDown", 2)  ; JSONEditor 框响应回车、后退等按键
return

GuiEscape:
GuiClose:
  ExitApp
return

智能库引用:
  用户库:=A_MyDocuments "\AutoHotkey\Lib\"
  标准库:=A_AhkPath "\..\Lib\"
  ; 在任意一个库文件目录中找到3个库文件，则简单引用就好。
  if  ((FileExist(用户库 "WinHttp.ahk") and FileExist(用户库 "NonNull.ahk") and FileExist(用户库 "RegEx.ahk"))
    or (FileExist(标准库 "WinHttp.ahk") and FileExist(标准库 "NonNull.ahk") and FileExist(标准库 "RegEx.ahk")))
    {
      库引用:="#Include <WinHttp>"
    }
    else
    {
      ; 库文件目录里找不到3个库文件，则加载3个库文件内容到变量里。
      FileRead, 库引用1, %A_ScriptDir%\Lib\WinHttp.ahk
      FileRead, 库引用2, %A_ScriptDir%\Lib\RegEx.ahk
      FileRead, 库引用3, %A_ScriptDir%\Lib\NonNull.ahk
      库引用1:=StrReplace(库引用1, "#IncludeAgain %A_LineFile%\..\RegEx.ahk", "`r`n" 库引用2)
      库引用1:=StrReplace(库引用1, "#IncludeAgain %A_LineFile%\..\NonNull.ahk", "`r`n" 库引用3)
      库引用:="; ------------------以下是库文件------------------`r`n`r`n" 库引用1
    }
return

导入设置:
  for k, v in StrSplit(Clipboard, "`n", "`r")
  {
    line:=StrSplit(v, ":", "", 2)
    GuiControl, , % line[1], % line[2]
  }
  btt("设置导入成功！",,, 2, "Style1")
  SetTimer, 关闭导入导出设置提示, -3000
return

导出设置:
  Gui, Submit, NoHide
  gosub, 生成变量_设置
  Clipboard:=设置
  btt("设置导出成功！",,, 2, "Style1")
  SetTimer, 关闭导入导出设置提示, -3000
return

关闭导入导出设置提示:
  btt(,,, 2)
return

发送:
  StartTime:=A_TickCount
  gosub, 状态栏计时
  SetTimer, 状态栏计时, 1000
  
  Gui, Submit, NoHide
  
  gosub, 生成变量_设置
  
  待处理变量:=["网址", "设置", "请求头", "提交数据"]
  k:="", v:=""
  for k, v in 待处理变量
    %v%:=Trim(%v%, " `t`r`n`v`f")  ; 去除GUI控件中首尾空白符
  
  返回值:=WinHttp.Download(网址, 设置, 请求头, 提交数据)
  if (WinHttp.Error.Message)       ; 有错误则显示错误信息
    返回值:="错误:" WinHttp.Error.Message
  gosub, 生成模板
  
  ; 把状态码和状态文字添加到响应头最前面
  响应头:="StatusCode:" WinHttp.StatusCode "`r`nStatusText:" WinHttp.StatusText "`r`n" WinHttp.解析对象为信息(WinHttp.ResponseHeaders)
  
  wb.document.parentWindow.editor.setText(返回值)
  GuiControl,,响应头,%响应头%
  GuiControl,,代码,%代码模板%
  
  SetTimer, 状态栏计时, Off
  SB_SetText("已完成！ 耗时 " (A_TickCount-StartTime)//1000 " 秒", 2)
return

状态栏计时:
  SB_SetText("尝试中... 耗时 " (A_TickCount-StartTime)//1000 " 秒", 2)
return

生成变量_设置:
  设置=
  (LTrim
    Method:%Method%
    EnableRedirects:%EnableRedirects%
    Charset:%Charset%
    URLCodePage:%URLCodePage%
    Timeout:%Timeout%
    ConnectTimeout:%ConnectTimeout%
    DownloadTimeout:%DownloadTimeout%
    ExpectedStatusCode:%ExpectedStatusCode%
    NumberOfRetries:%NumberOfRetries%
    Proxy:%Proxy%
    ProxyBypassList:%ProxyBypassList%
  )
return

生成模板:
  设置模板:=RTrim(WinHttp.解析对象为信息(WinHttp.解析信息为对象(设置),0), "`r`n")
  请求头模板:=RTrim(WinHttp.解析对象为信息(WinHttp.解析信息为对象(请求头)), "`r`n")
  代码模板=
  (LTrim
    网址=
    `(```%
    %网址%
    `)
    设置=
    `(```%
    %设置模板%
    `)
    请求头=
    `(```%
    %请求头模板%
    `)
    提交数据=
    `(```%
    %提交数据%
    `)
    
    ; WinHttp.Download(网址, 设置, 请求头, 提交数据, "x:\1.html")  ; 下载并存为文件
    返回值:=WinHttp.Download(网址, 设置, 请求头, 提交数据)  ; 下载并存到变量
    响应头:=WinHttp.解析对象为信息(WinHttp.ResponseHeaders)
    return
    
    %库引用%
  )
return

WM_ACTIVATE(wParam) ; 失去焦点则关闭提示框
{
  if (wParam & 0xFFFF = 0)
  {
    btt(,,, 1)
    btt(,,, 2)
  }
}

WM_MOUSEMOVE()    ; 鼠标移动到状态栏上改变图标
{
  static 手型光标:=DllCall("LoadCursor", "UInt", 0, "Int", 32649, "UInt")
  
  switch, A_GuiControl
  {
    case "状态栏":
    Prev_CoordModeMouse:=A_CoordModeMouse
    CoordMode, Mouse, Window
    MouseGetPos, OutputVarX
    if (OutputVarX<=80)
      DllCall("SetCursor", "UInt", 手型光标)
    CoordMode, Mouse, %Prev_CoordModeMouse%
    
    case "网址":
    说明=
    (LTrim
      必须包含类似 http:// 这样的开头。
      www. 最好也带上，有些网站需要。
    )
    
    case "请求头":
    说明=
    (LTrim
      可直接复制浏览器的 “开发者工具” 中的 Request Headers 的原文。
      可直接复制本工具的 “响应头” 中的 Set-Cookie ，会自动处理为 Cookie 。
      此处常见的设置有 Cookie、Referer、User-Agent 等。
    )
    
    case "提交数据":
    说明=
    (LTrim
      可直接复制浏览器的 “开发者工具” 中的 Request Payload 的原文。
      此处无值时，默认使用 GET 请求。有值时，默认使用 POST 请求。
    )
    
    case "Method":
    说明=
    (LTrim
      支持 GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE 共9种。
      此参数可以小写，但在程序内部，依然会被转换为全大写。
      留空表示自动选择 GET 或 POST 。
    )
    
    case "EnableRedirects":
    说明=
    (LTrim
      1为获取跳转后的页面信息，0为不跳转。
      留空表示1。
    )
    
    case "Charset":
    说明=
    (LTrim
      也就是网页的编码。
      是 UTF-8、gb2312 这样的字符。
      留空表示自动选择。
    )
    
    case "URLCodePage":
    说明=
    (LTrim
      也就是网址的编码。
      是 65001、936 这样的数字。
      留空表示65001。
    )
    
    case "Timeout":
    说明=
    (LTrim
      单位为秒，0为无限。
      当设置此参数，会同时覆盖 “连接超时” 与 “下载超时” 两项参数。
      留空表示不使用此参数。
    )
    
    case "ConnectTimeout":
    说明=
    (LTrim
      单位为秒，0为无限。
      当设置此参数，会在设置时间内尝试连接。
      连接失败，超时返回。连接成功，则继续尝试下载。
      留空表示30。
    )
    
    case "DownloadTimeout":
    说明=
    (LTrim
      单位为秒，0为无限。
      此参数与 “连接超时” 共享设置的时间。
      例如此参数设为30，尝试连接时花费10秒，则 “下载超时” 将只剩20秒。
      留空表示0。
    )
    
    case "ExpectedStatusCode":
    说明=
    (LTrim
      重复访问直到服务器返回的状态码与此参数相同时才停止。
      通常服务器返回的状态码为200表示网页正常，404表示网页找不到了。
      参数 “重试次数” 可设置重复访问的最大次数。
      留空表示不使用此参数。
    )
    
    case "NumberOfRetries":
    说明=
    (LTrim
      重复访问的最大次数。
      与 “期望的状态码” 配对使用。
      留空表示1。
    )
    
    case "Proxy":
    说明=
    (LTrim
      是 http://www.tuzi.com:80 这样的字符。
      有些抓包程序，例如 Fiddler 需要在这里填入 127.0.0.1:8888 才能抓到数据。
      留空表示不使用此参数。
    )
    
    case "ProxyBypassList":
    说明=
    (LTrim
      是 *.microsoft.com 这样的域名。
      符合域名的网址，将不通过代理服务器访问。
      留空表示不使用此参数。
    )
  }
  btt(说明,,,, "Style2")
}

WM_LBUTTONDOWN()  ; 鼠标单击状态栏
{
  If (A_GuiControl="状态栏")
  {
    Prev_CoordModeMouse:=A_CoordModeMouse
    CoordMode, Mouse, Window
    MouseGetPos, OutputVarX
    if (OutputVarX<=80)
      Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
    CoordMode, Mouse, %Prev_CoordModeMouse%
  }
}

gui_KeyDown(wParam, lParam, nMsg, hWnd) { ; http://www.autohotkey.com/board/topic/83954-problem-with-activex-gui/#entry535202
	global wb
	WinGetClass, ClassName, ahk_id %hWnd%
	if (ClassName = "Internet Explorer_Server")
  {
    pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
    VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
    , NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
    , NumPut(nMsg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
    Loop 2
      r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
    ; Loop to work around an odd tabbing issue (it's as if there
    ; is a non-existent element at the end of the tab order).
    until wParam != 9 || wb.Document.activeElement != ""
    ObjRelease(pipa)
    if r = 0  ; S_OK: the message was translated to an accelerator.
      return 0
  }
}

calculateHeight(expression)  ; 计算缩放状态下由多个控件叠加形成的新控件的高度
{
  sum := 0, DPIScale := A_ScreenDPI/96
  
  for k, v in StrSplit(expression, "+")
    sum += Round(v*DPIScale)
  
  return, Round(sum/DPIScale)
}

#Include <WinHttp>
#Include <Fnt>
#Include <Edit>
#Include <BTT>