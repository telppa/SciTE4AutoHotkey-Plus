/*
更新日志：
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
支持以下9种设置，输入其它值无任何效果，设置不区分大小写。
直接在冒号后填入参数即可，不填留空也行。
不用管这些注释，不影响正常运行。

网页字符集，不能是“936”之类的数字，必须是“gb2312”这样的字符。
Charset:

URL的编码，是“936”之类的数字，默认是“65001”。有些网站需要UTF-8（65001），有些网站又需要gb2312（936）。
URLCodePage:

代理服务器设置，0表示使用“Proxycfg.exe”的设置；1表示无视“Proxy”指定的代理而直接连接；2表示使用“Proxy”指定的代理，默认是1。
程序会根据“Proxy:”的值自动设置合适的“proxy_setting”，即通常情况下不用管“proxy_setting”，除非你想自己控制。
proxy_setting:

代理服务器，是形如“http://www.tuzi.com:80”的字符。
Proxy:

代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
ProxyBypassList:

重定向，默认获取跳转后的页面信息，0为不跳转。
EnableRedirects:

超时，单位为秒，默认不使用超时（Timeout=-1）。
Timeout:

期望的状态码，通常200表示网页正常，404表示网页找不到了。设置后当网页返回的状态码与此处不一致则抛出调试信息并报错（故使用此参数后建议同时使用try语句）。
expected_status:

重试次数（与期望的状态码配对使用），当网页返回的状态码与期望的状态码不一致时，可以重试的次数。
number_of_retries:

)     ;上一行必须是空行，否则此变量无值

默认请求头=
(
可直接复制粘贴浏览器的“开发者工具”中的“Request Headers”（请求头）全文。
可直接复制粘贴本工具的“响应头”中的“Set-Cookie”，会自动处理为Cookie。
不用管这些注释，不影响正常运行。

GET /s?&wd=ggh HTTP/1.1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3314.0 Safari/537.36 SE 2.X MetaSr 1.0
)

界面:
  ;设置图标必须放第一行，否则失效
  Menu Tray, Icon, %A_ScriptDir%\爬虫.ico

  Gui Add, GroupBox, x24 y16 w528 h700, 输入
  Gui Add, Text, x224 y40 w120 h24 +0x200 Center, 网址
  Gui Add, Edit, x48 y72 w480 h98 v网址,https://www.baidu.com/
  Gui Add, Text, x224 y192 w120 h24 +0x200 Center, 设置
  Gui Add, Edit, x48 y224 w480 h98 v设置, %默认设置%
  Gui Add, Text, x224 y344 w120 h24 +0x200 Center, 请求头
  Gui Add, Edit, x48 y376 w480 h98 -Wrap v请求头, %默认请求头%
  Gui Add, Text, x224 y496 w120 h24 +0x200 Center, Post 数据
  Gui Add, Edit, x48 y528 w480 h98 vPost数据,
  Gui Add, Button, x48 y648 w480 h52 g发送, 发送

  Gui Add, GroupBox, x576 y16 w648 h700, 输出
  Gui Add, Text, x842 y40 w120 h24 +0x200 Center, 返回值
  Gui Add, Edit, x600 y72 w600 h400 v返回值,
  Gui Add, Text, x680 y496 w120 h24 +0x200 Center, 响应头
  Gui Add, Edit, x600 y528 w280 h172 -Wrap v响应头,
  Gui Add, Text, x1000 y496 w120 h24 +0x200 Center, 代码
  Gui Add, Edit, x920 y528 w280 h172 -Wrap v代码,

  Gui Add, StatusBar, v状态栏, %A_Space%%A_Space%%A_Space%%A_Space%主页
  Gui Show, w1250 h750, AHK 爬虫终结者 ver. 1.1
  global 手型光标:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt")
  OnMessage(0x200, "WM_MouseMove")  ;监视鼠标移动消息
  OnMessage(0x201, "WM_LButtonDOWN")    ;监视鼠标点击消息
return

GuiEscape:
GuiClose:
  ExitApp
return

发送:
  Gui, Submit, NoHide

  待处理变量:=["网址", "设置", "请求头", "Post数据"]
  k:="", v:=""
  for k, v in 待处理变量
    %v%:=Trim(%v%, " `t`r`n`v`f")     ;去除GUI控件中首尾空白符

  if (Post数据="")
  {
    返回值:=WinHttp.UrlDownloadToVar(网址, 设置, 请求头)
    gosub, 普通模板
  }
  else
  {
    返回值:=WinHttp.UrlPost(网址, Post数据, 设置, 请求头)
    gosub, Post模板
  }

  ;把状态码和状态文字添加到响应头最前面
  响应头:="", 响应头:="Status:" WinHttp.Status "`r`n" "StatusText:" WinHttp.StatusText "`r`n" WinHttp.解析对象为信息(WinHttp.ResponseHeaders)

  GuiControl,,返回值,%返回值%
  GuiControl,,响应头,%响应头%
  GuiControl,,代码,%代码模板%
return

普通模板:
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

    返回值:=WinHttp.UrlDownloadToVar(网址, 设置, 请求头)
    响应头:=WinHttp.解析对象为信息(WinHttp.ResponseHeaders)
    return

    ;请将“SciTE\tools\AHK 爬虫终结者”目录中的以下两个库文件，自行复制到“本文件同目录”或“Lib目录”。
    #Include <WinHttp>
    #Include <正则全局模式>
  )
return

Post模板:
  设置模板:=RTrim(WinHttp.解析对象为信息(WinHttp.解析信息为对象(设置),0), "`r`n")
  请求头模板:=RTrim(WinHttp.解析对象为信息(WinHttp.解析信息为对象(请求头)), "`r`n")
  代码模板=
  (LTrim
    网址=
    `(```%
    %网址%
    `)
    Post数据=
    `(```%
    %Post数据%
    `)
    设置=
    `(```%
    %设置模板%
    `)
    请求头=
    `(```%
    %请求头模板%
    `)

    返回值:=WinHttp.UrlPost(网址, Post数据, 设置, 请求头)
    响应头:=WinHttp.解析对象为信息(WinHttp.ResponseHeaders)
    return

    ;请将“SciTE\tools\AHK 爬虫终结者”目录中的以下两个库文件，自行复制到“本文件同目录”或“Lib目录”。
    #Include <WinHttp>
    #Include <正则全局模式>
  )
return

WM_LBUTTONDOWN()    ;鼠标单击状态栏
{
  If (A_GuiControl="状态栏")
    Run, https://github.com/telppa/SciTE4AutoHotkey-Plus
}

WM_MOUSEMOVE()  ;鼠标移动到状态栏上改变图标
{
  If (A_GuiControl="状态栏")
    DllCall("SetCursor","UInt",手型光标)
}

#Include %A_ScriptDir%\WinHttp.ahk
#Include %A_ScriptDir%\正则全局模式.ahk