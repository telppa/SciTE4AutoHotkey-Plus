/*
更新日志：
  2021.10.22
    更新 WinHttp 库为 3.7。
    版本号3.7。
  2021.08.18
    更新 WinHttp 库为 3.6。
    版本号3.6。
  2021.08.16
    更新 WinHttp 库为 3.5。
    版本号3.5。
  2021.06.29
    修复智能库引用错误使用本地库作为判断依据。
    版本号3.4
  2021.04.13
    更智能的库引用，生成的代码无需手动引用。
    版本号3.3
  2021.04.11
    更新 WinHttp 库为 3.2。
    版本号3.2。
  2021.04.06
    更新 WinHttp 库为 3.1。
    版本号3.1。
  2021.03.17
    返回值框使用 JSONEditor 。
    版本号2.0。
  2020.09.07
    修正模板。
    修正默认请求头。
    增加库文件提示。
    增加主页。
    版本号1.1。
*/
#SingleInstance Force
#NoEnv

默认设置=
(
支持以下9种设置，输入其它值无任何效果，不区分大小写。
直接在冒号后填入参数即可，不填留空也行。
不用管这些注释，不影响正常运行。

请求方法，支持 GET, HEAD, POST,
          PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE 共9种。
留空可自动选择 GET 或 POST 。
Method:

网页字符集，也就是网页的编码。不能是 “936” 之类的数字，必须是 “gb2312” 这样的字符。
Charset:

URL 的编码，也就是网址的编码。是 “936” 之类的数字，默认是 “65001” 。
有些网站需要 UTF-8（65001） ，有些网站又需要 gb2312（936） 。
URLCodePage:

代理服务器，是形如 “http://www.tuzi.com:80” 的字符。
有些抓包程序，例如 Fiddler 需要在这里填入 “127.0.0.1:8888” 才能抓到数据。
Proxy:

代理服务器白名单，是形如 “*.microsoft.com” 的域名。
符合域名的网址，将不通过代理服务器访问。
ProxyBypassList:

重定向，默认获取跳转后的页面信息，0为不跳转。
EnableRedirects:

超时，单位为秒，默认不使用超时。
Timeout:

期望的状态码，通常200表示网页正常，404表示网页找不到了。
当网页返回的状态码与此处不一致则抛出调试信息并报错。
使用此参数后建议同时使用try语句。
ExpectedStatusCode:

重试次数（与 “期望的状态码” 配对使用）。
当网页返回的状态码与期望的状态码不一致时，可以重试的次数。
NumberOfRetries:

)   ; 上一行必须是空行，否则此变量无值。

默认请求头=
(
可直接复制浏览器的 “开发者工具” 中的 “Request Headers” （请求头）全文。
可直接复制本工具的 “响应头” 中的 “Set-Cookie” ，会自动处理为 Cookie 。
不用管这些注释，不影响正常运行。

GET /s?&wd=ggh HTTP/1.1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3314.0 Safari/537.36 SE 2.X MetaSr 1.0

)   ; 上一行可以不是空行，因为倒数第二行不是 “:” 结尾。

界面:
  ; 设置图标必须放第一行，否则失效。
  Menu, Tray, Icon, %A_ScriptDir%\爬虫.ico

  Gui, -DPIScale
  Gui, Add, GroupBox, x24 y16 w520 h700, 输入
  Gui, Add, Text, x224 y40 w120 h24 +0x200 Center, 网址
  Gui, Add, Edit, x48 y72 w472 h98 v网址,https://www.baidu.com/

  Gui, Add, Edit, x48 y192 w120 h23 , Method:
  Gui, Add, Edit, x224 y192 w120 h23 , Charset:
  Gui, Add, Edit, x400 y192 w120 h23 , URLCodePage:
  Gui, Add, Edit, x224 y272 w120 h23 , Proxy:
  Gui, Add, Edit, x224 y296 w120 h23 , ProxyBypassList:
  Gui, Add, Edit, x224 y232 w120 h23 , EnableRedirects:
  Gui, Add, Edit, x48 y232 w120 h23 , Timeout:
  Gui, Add, Edit, x48 y272 w120 h23 , ExpectedStatusCode:
  Gui, Add, Edit, x48 y296 w120 h23 , NumberOfRetries:

  ; Gui, Add, Text, x224 y192 w120 h24 +0x200 Center, 设置
  ; Gui, Add, Edit, x48 y224 w480 h98 v设置, %默认设置%
  Gui, Add, Text, x224 y344 w120 h24 +0x200 Center, 请求头
  Gui, Add, Edit, x48 y376 w472 h98 -Wrap v请求头, %默认请求头%
  Gui, Add, Text, x224 y496 w120 h24 +0x200 Center, 提交数据
  Gui, Add, Edit, x48 y528 w472 h98 v提交数据,
  Gui, Add, Button, x48 y648 w472 h52 g发送, 发送

  ; ActiveX 必须放 GroupBox 前面，否则显示不出来。
  Gui, Add, ActiveX, vWB x600 y72 w600 h400, %A_ScriptDir%\jsoneditor-5.15.0\jsonEditor.html
  Gui, Add, GroupBox, x576 y16 w648 h700, 输出
  Gui, Add, Text, x842 y40 w120 h24 +0x200 Center, 返回值

  Gui, Add, Text, x680 y496 w120 h24 +0x200 Center, 响应头
  Gui, Add, Edit, x600 y528 w280 h172 -Wrap v响应头,
  Gui, Add, Text, x1000 y496 w120 h24 +0x200 Center, 代码
  Gui, Add, Edit, x920 y528 w280 h172 -Wrap v代码,

  Gui, Add, StatusBar, v状态栏, %A_Space%%A_Space%%A_Space%%A_Space%主页

  Gui, Show, w1250 h750, AHK 爬虫终结者 ver. 3.7

  gosub, 智能库引用

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

发送:
  Gui, Submit, NoHide

  待处理变量:=["网址", "设置", "请求头", "提交数据"]
  k:="", v:=""
  for k, v in 待处理变量
    %v%:=Trim(%v%, " `t`r`n`v`f")     ; 去除GUI控件中首尾空白符

  返回值:=WinHttp.Download(网址, 设置, 请求头, 提交数据)
  gosub, 生成模板

  ; 把状态码和状态文字添加到响应头最前面
  响应头:="StatusCode:" WinHttp.StatusCode "`r`nStatusText:" WinHttp.StatusText "`r`n" WinHttp.解析对象为信息(WinHttp.ResponseHeaders)

  wb.document.parentWindow.editor.setText(返回值)
  GuiControl,,响应头,%响应头%
  GuiControl,,代码,%代码模板%
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

WM_LBUTTONDOWN()  ; 鼠标单击状态栏
{
  If (A_GuiControl="状态栏")
    Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
}

WM_MOUSEMOVE()    ; 鼠标移动到状态栏上改变图标
{
  static 手型光标:=DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt")
  If (A_GuiControl="状态栏")
    DllCall("SetCursor", "UInt", 手型光标)
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

#Include <WinHttp>