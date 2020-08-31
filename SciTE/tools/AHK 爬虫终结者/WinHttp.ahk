/*
更新日志：
	2020.08.18
	请求头可直接使用响应头中的“Set-Cookie”值，会自动处理为“Cookie”。
	小幅修改说明。
	版本号为2.0

	2020.08.16
	如果选项“Accept-Encoding”中含有关键词“gzip”，则选项将被自动删除，以避免服务器发送gzip压缩数据回来，无法解压而导致乱码的问题。
	“Msxml2.XMLHTTP” 可以自动解压gzip数据。https://www.autohotkey.com/boards/viewtopic.php?f=76&t=51629&hilit=gzip
	“Msxml2.XMLHTTP” “Msxml2.ServerXMLHTTP” “WinHttp.WinHttpRequest.5.1” 功能都差不多，2是对3的进一步封装，1和2封装的dll不同，因此只有1能自动解压gzip数据。
	版本号为1.6

	2016.01.23
	----------------------------------------------------------------------------------------------
	Timeout存在一些诡异。

	图片挖掘机访问一些未知链接，超时不设置时。
	会一直访问，永不返回，于是程序就没任何反应了。

	访问google。
	WaitForResponse(5)，SetTimeouts(0, 3000, 30000, 30000)
	将在3秒后超时返回，即后者生效。
	WaitForResponse(3)，SetTimeouts(0, 5000, 30000, 30000)
	将在3秒后超时返回，即前者生效。
	WaitForResponse(-1)，SetTimeouts(0, 5000, 30000, 30000)
	将在5秒后超时返回，即后者生效。
	WaitForResponse(-1)，SetTimeouts(0, 60000, 30000, 30000)
	将在21秒后超时返回，原因未知！

	下载一个几m大的文件。
	WaitForResponse(-1)，SetTimeouts(0, 2000, 2000, 3000)
	将在30秒后返回正确的文件，即前者生效（可能的原因是接收了1个字节后，SetTimeouts最后一个参数的timeout就不生效了）。
	WaitForResponse(50)，SetTimeouts(0, 2000, 2000, 3000)
	将在30秒后返回正确的文件，即前者生效。
	WaitForResponse(10)，SetTimeouts(0, 2000, 2000, 3000)
	将在10秒后超时返回，即前者生效。
	WaitForResponse(10)，SetTimeouts(0, 20000, 20000, 30000)
	将在10秒后超时返回，即前者生效。
	----------------------------------------------------------------------------------------------

	2016.01.23
	修改超时设置，可以指定任意时长的超时。
	版本号为1.5

	2015.09.12
	优化代码结构。
	版本号为1.4

	2015.09.11
	修正超时会在错误时间被激活的问题。（http://ahk8.com/thread-5658-post-33736.html#pid33736）
	以下是tmplinshi对这个问题的详细描述。
	----------------------------------------------------------------------------------------------
	WebRequest.WaitForResponse(超时秒数)
	默认情况下，这个超时秒数并不是你设置为空就一直等待，设置 60 就等待 60 秒。而是要受限于默认的超时设置。

	默认的超时设置为:
	解析超时: 0 秒
	连接超时: 60 秒
	发送超时: 30 秒
	接收超时: 30 秒

	WaitForResponse 应该是指接收超时吧。所以呢，默认的话即使你设置 WaitForResponse(60) 实际上还是最多就等待 30 秒。。

	默认值可以通过 WebRequest.SetTimeouts(解析超时, 连接超时, 发送超时, 接收超时) 来设置，详见 MSDN 的说明。比如把接收超时修改为 120 秒 —— WebRequest.SetTimeouts(0, 60000, 30000, 120000)

	这点没有明白可把我害惨了。最近写的一个查询软件，经常查询失败。我原本以为是网站无响应，因为我没有设置超时，以为软件会一直等待（但是上面说了，“一直等待”会受限于​默认的最大超时）。后来仔细看抓包数据，看到每次都 30 秒超时返回。而用浏览器测试却正常，在 40 多秒的时候返回了结果，这才发觉是软件不对劲。

	希望更多人知道这点说明，有空我还要再发几个帖子说明这一点。。另外@兔子 你也可以修改下代码，如果传递的超时超过了默认的 30 秒则调用一下 SetTimeouts。
	----------------------------------------------------------------------------------------------
	版本号为1.3

	2015.06.05
	添加静态变量Status、StatusText，用法和ResponseHeaders一致。
	添加新功能，若指定状态码与重试次数，将重试n次，直至状态码与预期一致。
	版本号为1.2

已知问题：
	类名和函数名都很长，比如要使用下载到变量时，需要输入“WinHttp.UrlDownloadToVar()”。
	解决的办法有两种：
		1.自己在scite的“AhkAbbrevs.properties”文件中写入“wv=WinHttp.UrlDownloadToVar(|)”，也就是缩略语。这样在你输入“wv”后再按“ctrl+b”就可以自动把这一切输入好了。
		2.自己把这个类的类名和其中函数名改成简单一点的，然后自己用。

	cookie没有实现像浏览器那样的自动管理。但是你可以在需要的时候随时取出，自行管理。
*/

class WinHttp
{
	/*
	“ResponseHeaders”这个变量中存储的就是每次访问网址时，服务器返回的“ResponseHeaders”。当然，它已经被解析成对象了，方便直接使用。
	不需要的时候，可以不用管它。需要的时候，则在下载网址后，紧接着读取这个对象就行了。
	例如“obj:=WinHttp.ResponseHeaders”，此时obj中就包含了刚才访问网址时服务器返回的所有“ResponseHeaders”。
	于是“MsgBox, % obj["Content-type"]”，就得到了“Content-type”。
	于是“MsgBox, % obj["Set-Cookie"]”，就得到了“Set-Cookie”。
	需要注意的是，由于“Set-Cookie”很可能一次返回了多条，所以如果存在多条“Set-Cookie”，它们是用“`r`n”分隔的。
	“Status”和“StatusText”用法与“ResponseHeaders”一致，区别为前两者是纯变量。
	例如“MsgBox, % WinHttp.Status”，就得到了状态码。
	*/
	static ResponseHeaders:=[],Status:="",StatusText:="",extra:=[]

	/*
	*****************版本*****************
	v 2.0

	*****************说明*****************
	此函数与内置命令 UrlDownloadToFile 的区别有以下几点：
	1.下载速度更快，大概100%。
	2.内置命令执行时，整个AHK程序都是卡顿状态。此函数不会。
	3.内置命令下载一些诡异网站（例如“牛杂网”）时，会概率性让进程或线程彻底死掉。此函数不会。
	4.支持设置网页字符集、URL的编码。乱码问题轻松解决。
	5.支持设置所有“Request Header”。常见的有：Cookie、Referer、User-Agent。网站检测问题轻松解决。
	6.支持设置超时，不必死等。
	7.支持设置代理及白名单。
	8.支持设置是否自动重定向网址。
	9.“RequestHeaders”参数格式与chrome的开发者工具中的“Request Header”相同，因此可直接复制过来就用，方便调试。
	10.支持存取“Cookie”，可用于模拟登录状态。
	11.支持判断网页返回时的状态码，例如200，404等。

	*****************参数*****************
	URL 网址，必须包含类似“http://”的开头。“www.”最好也带上，有些网站需要。
	FilePath 下载后的文件存为此名。
	Options、RequestHeaders的格式为：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。具体可参照“解析信息为对象()”注释中的例子。

	*****************Options*****************
	支持以下7种设置，输入其它值无任何效果，无大小写要求。
	proxy_setting 代理服务器设置，0表示使用“Proxycfg.exe”的设置；1表示无视“Proxy”指定的代理而直接连接；2表示使用“Proxy”指定的代理。
	Proxy 代理服务器，是形如“http://www.tuzi.com:80”的字符。程序会根据此处的值自动设置合适的“proxy_setting”，即通常情况下不用管“proxy_setting”，除非你想自己控制。
	ProxyBypassList 代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
	EnableRedirects 重定向，默认获取跳转后的页面信息，0为不跳转。
	Timeout 超时，单位为秒，默认不使用超时（Timeout=-1）。
	expected_status	期望的状态码，通常200表示网页正常，404表示网页找不到了。设置后当网页返回的状态码与此处不一致则抛出调试信息并报错（故使用此参数后建议同时使用try语句）。
	number_of_retries	重试次数（与期望的状态码配对使用），当网页返回的状态码与期望的状态码不一致时，可以重试的次数。

	*****************RequestHeaders*****************
	支持所有RequestHeader，大小写的改变可能会影响结果。常见的有以下这些。
	Cookie ，常用于登录验证。
	Referer 引用网址，常用于防盗链。
	User-Agent 用户信息，常用于防盗链。

	*****************注意*****************
	*/
	URLDownloadToFile(URL, FilePath, Options:="", RequestHeaders:="")
	{
		Options:=this.解析信息为对象(Options)
		RequestHeaders:=this.解析信息为对象(RequestHeaders)
		RequestHeaders:=this.解析SetCookie为Cookie(RequestHeaders)

		ComObjError(0) 														 		;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")

		if (Options["EnableRedirects"]<>"")							;设置是否获取跳转后的页面信息
			WebRequest.Option(6):=Options["EnableRedirects"]
		;proxy_setting没值时，根据Proxy值的情况智能设定是否要进行代理访问。
		;这样的好处是多数情况下需要代理时依然只用给出代理服务器地址即可。而在已经给出代理服务器地址后，又可以很方便的对是否启用代理进行开关。
		if (Options["proxy_setting"]="" and Options["Proxy"]<>"")
			Options["proxy_setting"]:=2										;0表示 Proxycfg.exe 运行了且遵循 Proxycfg.exe 的设置（没运行则效果同设置为1）。1表示忽略代理直连。2表示使用代理
		if (Options["proxy_setting"]="" and Options["Proxy"]="")
			Options["proxy_setting"]:=1
		;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
		WebRequest.SetProxy(Options["proxy_setting"],Options["Proxy"],Options["ProxyBypassList"])
		if (Options["Timeout"]="")											;Options["Timeout"]如果被设置为-1，并不代表无限超时，而是依然遵循SetTimeouts第4个参数设置的最大超时时间
			WebRequest.SetTimeouts(0,60000,30000,0)			;0或-1都表示超时无限等待，正整数则表示最大超时（单位毫秒）
		else																					;修改默认超时时间
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		/*
		else if (Options["Timeout"]>30)									;如果超时设置大于30秒，则需要将默认的最大超时时间修改为大于30秒
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		else
			WebRequest.SetTimeouts(0,60000,30000,30000)	;此为SetTimeouts的默认设置。这句可以不加，因为默认就是这样，加在这里是为了表述清晰。
		*/

		WebRequest.Open("GET", URL, true)   						;true为异步获取。默认是false，龟速的根源！！！卡顿的根源！！！

		;删掉含“gzip”的“Accept-Encoding”设置，避免服务器发送gzip压缩后的数据
		if (InStr(RequestHeaders["Accept-Encoding"], "gzip"))
			RequestHeaders.Delete("Accept-Encoding")
		;SetRequestHeader() 必须 Open() 之后才有效
		for k, v in RequestHeaders
		{
			if (k="Cookie")
				WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，msdn推荐这么做
			WebRequest.SetRequestHeader(k,v)
		}

		Loop
		{
			WebRequest.Send()
			WebRequest.WaitForResponse(-1)								;WaitForResponse方法确保获取的是完整的响应。-1表示总是使用SetTimeouts设置的超时

			;获取状态码，一般status为200说明请求成功
			this.Status:=WebRequest.Status()
			this.StatusText:=WebRequest.StatusText()

			if (Options["expected_status"]="" or Options["expected_status"]=this.Status)
				break
			;尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）
			;即使number_of_retries为空，表达式依然成立，所以不用为number_of_retries设置初始值。
			else if (A_Index>=Options["number_of_retries"])
			{
				this.extra.URL:=URL
				this.extra.Expected_Status:=Options["expected_status"]
				this.extra.Status:=this.Status
				this.extra.StatusText:=this.StatusText
				throw, Exception("经过" Options.number_of_retries "次尝试后，服务器返回状态码依旧与期望值不一致", -1, Object(this.extra))
			}
		}

		ADO:=ComObjCreate("adodb.stream")   		;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
		ADO.Type:=1														;以二进制方式操作
		ADO.Mode:=3 													;可同时进行读写
		ADO.Open()  														;开启物件
		ADO.Write(WebRequest.ResponseBody())    	;写入物件。注意没法将 WebRequest.ResponseBody() 存入一个变量，所以必须用这种方式写文件
		ADO.SaveToFile(FilePath,2)   						 	;文件存在则覆盖
		ADO.Close()
		this.ResponseHeaders:=this.解析信息为对象(WebRequest.GetAllResponseHeaders())
		return, 1
	}

	/*
	*****************版本*****************
	v 2.0

	*****************说明*****************
	此函数与内置命令 UrlDownloadToFile 的区别有以下几点：
	1.直接下载到变量，没有临时文件。
	2.下载速度更快，大概100%。
	3.内置命令执行时，整个AHK程序都是卡顿状态。此函数不会。
	4.内置命令下载一些诡异网站（例如“牛杂网”）时，会概率性让进程或线程彻底死掉。此函数不会。
	5.支持设置网页字符集、URL的编码。乱码问题轻松解决。
	6.支持设置所有“Request Header”。常见的有：Cookie、Referer、User-Agent。网站检测问题轻松解决。
	7.支持设置超时，不必死等。
	8.支持设置代理及白名单。
	9.支持设置是否自动重定向网址。
	10.“RequestHeaders”参数格式与chrome的开发者工具中的“Request Header”相同，因此可直接复制过来就用，方便调试。
	11.支持存取“Cookie”，可用于模拟登录状态。
	12.支持判断网页返回时的状态码，例如200，404等。

	*****************参数*****************
	URL 网址，必须包含类似“http://”的开头。“www.”最好也带上，有些网站需要。
	Options、RequestHeaders的格式为：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。具体可参照“解析信息为对象()”注释中的例子。

	*****************Options*****************
	支持以下9种设置，输入其它值无任何效果，无大小写要求。
	Charset 网页字符集，不能是“936”之类的数字，必须是“gb2312”这样的字符。
	URLCodePage URL的编码，是“936”之类的数字，默认是“65001”。有些网站需要UTF-8，有些网站又需要gb2312。
	proxy_setting 代理服务器设置，0表示使用“Proxycfg.exe”的设置；1表示无视“Proxy”指定的代理而直接连接；2表示使用“Proxy”指定的代理。
	Proxy 代理服务器，是形如“http://www.tuzi.com:80”的字符。程序会根据此处的值自动设置合适的“proxy_setting”，即通常情况下不用管“proxy_setting”，除非你想自己控制。
	ProxyBypassList 代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
	EnableRedirects 重定向，默认获取跳转后的页面信息，0为不跳转。
	Timeout 超时，单位为秒，默认不使用超时（Timeout=-1）。
	expected_status	期望的状态码，通常200表示网页正常，404表示网页找不到了。设置后当网页返回的状态码与此处不一致则抛出调试信息并报错（故使用此参数后建议同时使用try语句）。
	number_of_retries	重试次数（与期望的状态码配对使用），当网页返回的状态码与期望的状态码不一致时，可以重试的次数。

	*****************RequestHeaders*****************
	支持所有RequestHeader，大小写的改变可能会影响结果。常见的有以下这些。
	Cookie ，常用于登录验证。
	Referer 引用网址，常用于防盗链。
	User-Agent 用户信息，常用于防盗链。

	*****************注意*****************
	*/
	UrlDownloadToVar(URL, Options:="", RequestHeaders:="")
	{
		Options:=this.解析信息为对象(Options)
		RequestHeaders:=this.解析信息为对象(RequestHeaders)
		RequestHeaders:=this.解析SetCookie为Cookie(RequestHeaders)

		ComObjError(0) 														 		;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")

		if (Options["URLCodePage"]<>"")    							;设置URL的编码
			WebRequest.Option(2):=Options["URLCodePage"]
		if (Options["EnableRedirects"]<>"")							;设置是否获取跳转后的页面信息
			WebRequest.Option(6):=Options["EnableRedirects"]
		;proxy_setting没值时，根据Proxy值的情况智能设定是否要进行代理访问。
		;这样的好处是多数情况下需要代理时依然只用给出代理服务器地址即可。而在已经给出代理服务器地址后，又可以很方便的对是否启用代理进行开关。
		if (Options["proxy_setting"]="" and Options["Proxy"]<>"")
			Options["proxy_setting"]:=2										;0表示 Proxycfg.exe 运行了且遵循 Proxycfg.exe 的设置（没运行则效果同设置为1）。1表示忽略代理直连。2表示使用代理
		if (Options["proxy_setting"]="" and Options["Proxy"]="")
			Options["proxy_setting"]:=1
		;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
		WebRequest.SetProxy(Options["proxy_setting"],Options["Proxy"],Options["ProxyBypassList"])
		if (Options["Timeout"]="")											;Options["Timeout"]如果被设置为-1，并不代表无限超时，而是依然遵循SetTimeouts第4个参数设置的最大超时时间
			WebRequest.SetTimeouts(0,60000,30000,0)			;0或-1都表示超时无限等待，正整数则表示最大超时（单位毫秒）
		else																					;修改默认超时时间
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		/*
		else if (Options["Timeout"]>30)									;如果超时设置大于30秒，则需要将默认的最大超时时间修改为大于30秒
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		else
			WebRequest.SetTimeouts(0,60000,30000,30000)	;此为SetTimeouts的默认设置。这句可以不加，因为默认就是这样，加在这里是为了表述清晰。
		*/

		WebRequest.Open("GET", URL, true)   						;true为异步获取。默认是false，龟速的根源！！！卡顿的根源！！！

		;删掉含“gzip”的“Accept-Encoding”设置，避免服务器发送gzip压缩后的数据
		if (InStr(RequestHeaders["Accept-Encoding"], "gzip"))
			RequestHeaders.Delete("Accept-Encoding")
		;SetRequestHeader() 必须 Open() 之后才有效
		for k, v in RequestHeaders
		{
			if (k="Cookie")
				WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，msdn推荐这么做
			WebRequest.SetRequestHeader(k,v)
		}

		Loop
		{
			WebRequest.Send()
			WebRequest.WaitForResponse(-1)								;WaitForResponse方法确保获取的是完整的响应。-1表示总是使用SetTimeouts设置的超时

			;获取状态码，一般status为200说明请求成功
			this.Status:=WebRequest.Status()
			this.StatusText:=WebRequest.StatusText()

			if (Options["expected_status"]="" or Options["expected_status"]=this.Status)
				break
			;尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）
			;即使number_of_retries为空，表达式依然成立，所以不用为number_of_retries设置初始值。
			else if (A_Index>=Options["number_of_retries"])
			{
				this.extra.URL:=URL
				this.extra.Expected_Status:=Options["expected_status"]
				this.extra.Status:=this.Status
				this.extra.StatusText:=this.StatusText
				throw, Exception("经过" Options.number_of_retries "次尝试后，服务器返回状态码依旧与期望值不一致", -1, Object(this.extra))
			}
		}

		if (Options["Charset"]<>"") 									;设置字符集
		{
			ADO:=ComObjCreate("adodb.stream")  			;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
			ADO.Type:=1 														;以二进制方式操作
			ADO.Mode:=3 													;可同时进行读写
			ADO.Open()  														;开启物件
			ADO.Write(WebRequest.ResponseBody())  	;写入物件。注意 WebRequest.ResponseBody() 获取到的是无符号的bytes，通过 adodb.stream 转换成字符串string
			ADO.Position:=0 												;从头开始
			ADO.Type:=2 														;以文字模式操作
			ADO.Charset:=Options["Charset"]    				;设定编码方式
			ret_var:=ADO.ReadText()   								;将物件内的文字读出
			ADO.Close()
			this.ResponseHeaders:=this.解析信息为对象(WebRequest.GetAllResponseHeaders())
			return, ret_var
		}
		else
		{
			this.ResponseHeaders:=this.解析信息为对象(WebRequest.GetAllResponseHeaders())
			return, WebRequest.ResponseText()
		}
	}

	/*
	*****************版本*****************
	v 2.0

	*****************说明*****************
	此函数与内置命令 UrlDownloadToFile 的区别有以下几点：
	1.直接下载到变量，没有临时文件。
	2.下载速度更快，大概100%。
	3.内置命令执行时，整个AHK程序都是卡顿状态。此函数不会。
	4.内置命令下载一些诡异网站（例如“牛杂网”）时，会概率性让进程或线程彻底死掉。此函数不会。
	5.支持设置网页字符集、URL的编码。乱码问题轻松解决。
	6.支持设置所有“Request Header”。常见的有：Cookie、Referer、User-Agent。网站检测问题轻松解决。
	7.支持设置超时，不必死等。
	8.支持设置代理及白名单。
	9.支持设置是否自动重定向网址。
	10.“RequestHeaders”参数格式与chrome的开发者工具中的“Request Header”相同，因此可直接复制过来就用，方便调试。
	11.使用“POST”方法，因此可上传数据。
	12.支持存取“Cookie”，可用于模拟登录状态。
	13.支持判断网页返回时的状态码，例如200，404等。

	*****************参数*****************
	URL 网址，必须包含类似“http://”的开头。“www.”最好也带上，有些网站需要。
	Data 数据，默认是文本，即开发者工具中“Request Payload”段中的内容。
	Options、RequestHeaders的格式为：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。具体可参照“解析信息为对象()”注释中的例子。

	*****************Options*****************
	支持以下9种设置，输入其它值无任何效果，无大小写要求。
	Charset 网页字符集，不能是“936”之类的数字，必须是“gb2312”这样的字符。
	URLCodePage URL的编码，是“936”之类的数字，默认是“65001”。有些网站需要UTF-8，有些网站又需要gb2312。
	proxy_setting 代理服务器设置，0表示使用“Proxycfg.exe”的设置；1表示无视“Proxy”指定的代理而直接连接；2表示使用“Proxy”指定的代理。
	Proxy 代理服务器，是形如“http://www.tuzi.com:80”的字符。程序会根据此处的值自动设置合适的“proxy_setting”，即通常情况下不用管“proxy_setting”，除非你想自己控制。
	ProxyBypassList 代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
	EnableRedirects 重定向，默认获取跳转后的页面信息，0为不跳转。
	Timeout 超时，单位为秒，默认不使用超时（Timeout=-1）。
	expected_status	期望的状态码，通常200表示网页正常，404表示网页找不到了。设置后当网页返回的状态码与此处不一致则抛出调试信息并报错（故使用此参数后建议同时使用try语句）。
	number_of_retries	重试次数（与期望的状态码配对使用），当网页返回的状态码与期望的状态码不一致时，可以重试的次数。

	*****************RequestHeaders*****************
	支持所有RequestHeader，大小写的改变可能会影响结果。常见的有以下这些。
	Cookie ，常用于登录验证。
	Referer 引用网址，常用于防盗链。
	User-Agent 用户信息，常用于防盗链。

	*****************注意*****************
	*/
	UrlPost(URL, Data, Options:="", RequestHeaders:="")
	{
		Options:=this.解析信息为对象(Options)
		RequestHeaders:=this.解析信息为对象(RequestHeaders)
		RequestHeaders:=this.解析SetCookie为Cookie(RequestHeaders)

		ComObjError(0) 														 		;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")

		if (Options["URLCodePage"]<>"")    							;设置URL的编码
			WebRequest.Option(2):=Options["URLCodePage"]
		if (Options["EnableRedirects"]<>"")							;设置是否获取跳转后的页面信息
			WebRequest.Option(6):=Options["EnableRedirects"]
		;proxy_setting没值时，根据Proxy值的情况智能设定是否要进行代理访问。
		;这样的好处是多数情况下需要代理时依然只用给出代理服务器地址即可。而在已经给出代理服务器地址后，又可以很方便的对是否启用代理进行开关。
		if (Options["proxy_setting"]="" and Options["Proxy"]<>"")
			Options["proxy_setting"]:=2										;0表示 Proxycfg.exe 运行了且遵循 Proxycfg.exe 的设置（没运行则效果同设置为1）。1表示忽略代理直连。2表示使用代理
		if (Options["proxy_setting"]="" and Options["Proxy"]="")
			Options["proxy_setting"]:=1
		;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
		WebRequest.SetProxy(Options["proxy_setting"],Options["Proxy"],Options["ProxyBypassList"])
		if (Options["Timeout"]="")											;Options["Timeout"]如果被设置为-1，并不代表无限超时，而是依然遵循SetTimeouts第4个参数设置的最大超时时间
			WebRequest.SetTimeouts(0,60000,30000,0)			;0或-1都表示超时无限等待，正整数则表示最大超时（单位毫秒）
		else																					;修改默认超时时间
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		/*
		else if (Options["Timeout"]>30)									;如果超时设置大于30秒，则需要将默认的最大超时时间修改为大于30秒
			WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
		else
			WebRequest.SetTimeouts(0,60000,30000,30000)	;此为SetTimeouts的默认设置。这句可以不加，因为默认就是这样，加在这里是为了表述清晰。
		*/

		WebRequest.Open("POST", URL, true)   ;true为异步获取。默认是false，龟速的根源！！！卡顿的根源！！！

		;删掉含“gzip”的“Accept-Encoding”设置，避免服务器发送gzip压缩后的数据
		if (InStr(RequestHeaders["Accept-Encoding"], "gzip"))
			RequestHeaders.Delete("Accept-Encoding")
		;SetRequestHeader() 必须 Open() 之后才有效
		for k, v in RequestHeaders
		{
			if (k="Cookie")
				WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，msdn推荐这么做
			WebRequest.SetRequestHeader(k,v)
		}

		Loop
		{
			WebRequest.Send(Data)
			WebRequest.WaitForResponse(-1)								;WaitForResponse方法确保获取的是完整的响应。-1表示总是使用SetTimeouts设置的超时

			;获取状态码，一般status为200说明请求成功
			this.Status:=WebRequest.Status()
			this.StatusText:=WebRequest.StatusText()

			if (Options["expected_status"]="" or Options["expected_status"]=this.Status)
				break
			;尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）
			;即使number_of_retries为空，表达式依然成立，所以不用为number_of_retries设置初始值。
			else if (A_Index>=Options["number_of_retries"])
			{
				this.extra.URL:=URL
				this.extra.Expected_Status:=Options["expected_status"]
				this.extra.Status:=this.Status
				this.extra.StatusText:=this.StatusText
				throw, Exception("经过" Options.number_of_retries "次尝试后，服务器返回状态码依旧与期望值不一致", -1, Object(this.extra))
			}
		}

		if (Options["Charset"]<>"")									;设置字符集
		{
			ADO:=ComObjCreate("adodb.stream") 		 	;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
			ADO.Type:=1 														;以二进制方式操作
			ADO.Mode:=3 													;可同时进行读写
			ADO.Open()  														;开启物件
			ADO.Write(WebRequest.ResponseBody())    	;写入物件。注意 WebRequest.ResponseBody() 获取到的是无符号的bytes，通过 adodb.stream 转换成字符串string
			ADO.Position:=0 												;从头开始
			ADO.Type:=2 														;以文字模式操作
			ADO.Charset:=Options["Charset"]   				;设定编码方式
			ret_var:=ADO.ReadText()   								;将物件内的文字读出
			ADO.Close()
			this.ResponseHeaders:=this.解析信息为对象(WebRequest.GetAllResponseHeaders())
			return, ret_var
		}
		else
		{
			this.ResponseHeaders:=this.解析信息为对象(WebRequest.GetAllResponseHeaders())
			return, WebRequest.ResponseText()
		}
	}

	/*
	infos的格式：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。
	换句话说，chrome的开发者工具中“Request Header”那段内容直接复制过来就能用。
	需要注意第一行“GET /?tn=sitehao123 HTTP/1.1”其实是没有任何作用的，因为没有“:”。但复制过来了也并不会影响正常解析。

	infos=
	(
	GET /?tn=sitehao123 HTTP/1.1
	Host: www.baidu.com
	Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	User-Agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36 SE 2.X MetaSr 1.0
	DNT: 1
	Referer: http://www.hao123.com/
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: zh-CN,zh;q=0.8
	)
	*/
	解析信息为对象(infos)
	{
		if (IsObject(infos)=1)
			return, infos

		;以下两步可将“infos”换行符统一为`r`n，避免正则表达式提取时出错
		StringReplace, infos, infos, `r`n, `n, All
		StringReplace, infos, infos, `n, `r`n, All

		;使用正则而不是strsplit()进行处理的原因是，后者会错误处理这样的情况“程序会根据“Proxy:”的值自动设置”
		infos_temp:=GlobalRegExMatch(infos,"m)(^[\w\-]*?):(.*$)",1)
		;将正则匹配到的信息存入新的对象中，像这样{"Connection":"keep-alive","Cache-Control":"max-age=0"}
		obj:=[]
		Loop, % infos_temp.MaxIndex()
		{
			name:=Trim(infos_temp[A_Index].Value[1], " `t`r`n`v`f")						;Trim()的作用就是把“abc: haha”中haha的多余空白符消除
			value:=Trim(infos_temp[A_Index].Value[2], " `t`r`n`v`f")

			;“Set-Cookie”是可以一次返回多条的，因此特殊处理将返回值存入数组。
			if (name="Set-Cookie" and obj.HasKey("Set-Cookie")=0)
				obj["Set-Cookie"]:=[]
			else if (name="Set-Cookie" and obj.HasKey("Set-Cookie")=1)
				obj[name].Push(value)
			else
				obj[name]:=value
		}

		return, obj
	}

	/*
	EnableRedirects:
	expected_status:200
	number_of_retries:5
	
	如果“ShowEmptyNameAndValue=0”，那么输出的内容将不包含值为空的行（例如第一行）。
	*/
	解析对象为信息(obj, ShowEmptyNameAndValue:=1)
	{
		if (IsObject(obj)=0)
			return, obj

		for k, v in obj
		{
			if (ShowEmptyNameAndValue=0 and Trim(v, " `t`r`n`v`f")="")
				continue
			if (k="Set-Cookie")
			{
				loop, % v.MaxIndex()
					infos.=k ":" v[A_Index] "`r`n"
			}
			else
				infos.=k ":" v "`r`n"
		}
		return, infos
	}

	/*
	在“GetAllResponseHeaders”中，“Set-Cookie”可能一次存在多个，比如“Set-Cookie:name=a; domain=xxx.com `r`n Set-Cookie:name=b; domain=www.xxx.com”。
	之后向服务器发送cookie的时候，会先验证domain，再验证path，两者都成功，再发送所有符合条件的cookies。
	domain的匹配方式是从字符串的尾部开始比较。
	path的匹配方式是从头开始逐字符串比较（例如/blog与/blog、/blogrool等等都匹配）。需要注意的是，path只在domain完成匹配后才比较。
	当下次访问“www.xxx.com”时，由于有2个符合条件的cookie，所以发送给服务器的cookie应该是“name=b; name=a”。
	当下次访问“xxx.com”时，由于只有1个符合条件的cookie，所以发送给服务器的cookie应该是“name=a”。
	规则是，path越详细，越靠前。domain越详细，越靠前（domain和path加起来就是网址了）。
	另外需要注意的是，“Set-Cookie”中没有domain或者path的话，则以当前url为准。
	如果要覆盖一个已有的cookie值，那么需要创建一个name、domain、path，完全相同的“Set-Cookie”（name就是“cookie:name=value; path=/”中的name）。
	当一个cookie存在，并且可选条件允许的话，该cookie的值会在接下来的每个请求中被发送至服务器。
	其值被存储在名为Cookie的HTTP消息头中，并且只包含了cookie的值，其它的选项全部被去除（expires，domain，path，secure全部没有了）。
	如果在指定的请求中有多个cookies，那么它们会被分号和空格分开，例如：（Cookie:value1 ; value2 ; name1=value1）
	在没有expires选项时，cookie的寿命仅限于单一的会话中。浏览器的关闭意味这一次会话的结束，所以会话cookie只存在于浏览器保持打开的状态之下。
	如果expires选项设置了一个过去的时间点，那么这个cookie会被立即删除。
	最后一个选项是secure。不像其它选项，该选项只是一个标记并且没有其它的值。
	“http://my.oschina.net/hmj/blog/69638” 参考答案。
	*/

	;参考文章 “https://blog.oonne.com/site/blog?id=31” “https://www.cnblogs.com/daysme/p/8052930.html”
	;此函数将所有“Set-Cookie”忽略全部属性后（例如Domain适用站点属性、Expires过期时间属性等），存为一个“Cookie”。
	;传入的值里只有Cookie，直接返回；只有Set-Cookie，处理成Cookie后返回；两者都有，处理并覆盖Cookie后返回；两者都无，直接返回。
	;Cookie的name和value不允许包含分号，逗号和空格符。如果包含可以使用URL编码。
	解析SetCookie为Cookie(InfosOrObj)
	{
		;传入文本或对象均能处理。
		if (IsObject(InfosOrObj)=0)
			obj:=this.解析信息为对象(InfosOrObj)
		else
			obj:=InfosOrObj

		;没有待处理的“Set-Cookie”则直接返回。
		if (obj.HasKey("Set-Cookie")=0)
			return, InfosOrObj

		Cookies:=[]
		loop, % obj["Set-Cookie"].MaxIndex()
		{
			Set_Cookie:=StrSplit(obj["Set-Cookie"][A_Index], ";", " `t`r`n`v`f")
			;根据RFC 2965标准，cookie的name可以和属性相同，但因为name和value总在最前面，所以又不会和属性混淆。https://tools.ietf.org/html/rfc2965
			;可以正确处理value中含等号的情况 “Set-Cookie:BAIDUID=C04C13BA70E52C330434FAD20C86265C:FG=1;”
			NameAndValue:=StrSplit(Set_Cookie[1], "=", " `t`r`n`v`f", 2), name:=NameAndValue[1], value:=NameAndValue[2]
			Cookies[name]:=value
			/*
			;旧的不标准的获取name和value的方法。从前到后挨个检查每个“;”分隔出的部分，若name不在属性列表里，则认为是name，否则认为是属性，继续检查下一个。
			loop, % Set_Cookie.MaxIndex()
			{
				NameAndValue:=StrSplit(Set_Cookie[A_Index], "=", " `t`r`n`v`f", 2), name:=NameAndValue[1], value:=NameAndValue[2]
				;列出cookie所有可能的属性，检查名字和属性相同则认为是属性而非cookie想传达的值。
				if name not in Expires,Max-Age,Domain,Path,HttpOnly,Secure,SameSite,Comment,CommentURL,Discard,Port,Version
				{
					Cookies[name]:=value
					break
				}
			}
			*/
		}
		obj.Delete("Set-Cookie")			;“Set-Cookie”转换完成后就删除。

		;同时存在“Cookie”和“Set-Cookie”时，后者处理完成的值将覆盖前者。
		obj["Cookie"]:=""
		for k, v in Cookies
			obj["Cookie"].=k "=" v "; "

		return, obj
	}
}