/*
更新日志：
  2021.08.18
  修复响应头的 Set-Cookie 总是被改变为 Cookie 的问题。
  版本号3.6

  2021.08.16
  修复请求头行首包含空白符会被错误解析的问题。
  增加 Cookie 的快速获取。
  版本号3.5

  2021.04.11
  集成 CreateFormData 函数。
  集成 BinArr 系列函数。
  版本号为3.2

  2021.04.05
  修正部分 URL （ http://snap.ie.sogou.com ），请求头重复添加 Connection: Keep-Alive 的问题。
  添加默认 User-Agent 。
  gzip 解压目前只找到了32位的 dll ，所以还是用老方法解决 gzip 压缩数据的问题。
  版本号为3.1

  2021.04.04
  代码重构。
  版本号为3.0

  2020.08.18
  请求头可直接使用响应头中的“Set-Cookie”值，会自动处理为“Cookie”。
  小幅修改说明。
  版本号为2.0

  2020.08.16
  如果 “Accept-Encoding” 中含有关键词“gzip”，则选项将被自动删除，以避免服务器发送gzip压缩数据回来，无法解压而导致乱码的问题。
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
  修正超时会在错误时间被激活的问题。（https://www.autohotkey.com/boards/viewtopic.php?t=9137）
  以下是tmplinshi对这个问题的详细描述。
  版本号为1.3

  2015.06.05
  添加静态变量Status、StatusText，用法和ResponseHeaders一致。
  添加新功能，若指定状态码与重试次数，将重试n次，直至状态码与预期一致。
  版本号为1.2

已知问题：
  cookie 没有实现像浏览器那样根据属性值自动管理。但是你可以在需要的时候随时取出，自行管理。
  请求头 Content-Type: 末尾会自动追加一个 Charset=UTF-8 （需使用 Fiddler 抓包查看）。
*/

/*
  MsgBox, % WinHttp.Download("https://www.example.com/")  ; 网页内容
  MsgBox, % WinHttp.ResponseHeaders["Content-type"]       ; 响应头 Content-type 段
  MsgBox, % WinHttp.StatusCode                            ; 状态码
  MsgBox, % WinHttp.Cookie                                ; Cookie

  objParam := {"file": ["截图.png"]}                      ; CreateFormData 示例
  WinHttp.CreateFormData(out_postData, out_ContentType, objParam,,,"image/jpg")
  RequestHeaders := "Content-Type: " out_ContentType
  MsgBox, % WinHttp.Download("http://snap.ie.sogou.com/recognition",, RequestHeaders, out_postData)
*/
class WinHttp
{
  static ResponseHeaders:={}, StatusCode:="", StatusText:="", Cookie:="", extra:={}

  /*
  *****************参数*****************
  URL                  网址，必须包含类似 “http://”的开头。“www.” 最好也带上，有些网站需要。
  Options              每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。具体可参照 “解析信息为对象()” 注释中的例子。
  RequestHeaders       同 Options 。
  Data                 数据，默认是文本，即开发者工具中 “Request Payload” 段中的内容。Data 参数无值时，默认使用 GET 请求。有值时，默认使用 POST 请求。
  FilePath             此参数非空，则下载到此路径，否则下载到变量。

  ***************Options***************
  支持以下9种设置，输入其它值无任何效果，不区分大小写。
  Method               请求方法，支持 GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE 共9种。留空可自动选择 GET 或 POST 。
  Charset              网页字符集，也就是网页的编码。不能是 “936” 之类的数字，必须是 “gb2312” 这样的字符。
  URLCodePage          URL 的编码，也就是网址的编码。是 “936” 之类的数字，默认是 “65001” 。有些网站需要 UTF-8（65001） ，有些网站又需要 gb2312（936） 。
  Proxy                代理服务器，是形如 “http://www.tuzi.com:80” 的字符。有些抓包程序，例如 Fiddler 需要在这里填入 “127.0.0.1:8888” 才能抓到数据。
  ProxyBypassList      代理服务器白名单，是形如 “*.microsoft.com” 的域名。符合域名的网址，将不通过代理服务器访问。
  EnableRedirects      重定向，默认获取跳转后的页面信息，0为不跳转。
  Timeout              超时，单位为秒，默认不使用超时。
  ExpectedStatusCode   期望的状态码，通常200表示网页正常，404表示网页找不到了。当网页返回的状态码与此处不一致则抛出调试信息并报错（故使用此参数后建议同时使用try语句）。
  NumberOfRetries      重试次数（与 “期望的状态码” 配对使用），当网页返回的状态码与期望的状态码不一致时，可以重试的次数。

  ************RequestHeaders************
  支持所有 RequestHeader ，可能区分大小写。常见的有以下这些。
  Cookie               常用于登录验证。
  Referer              引用网址，常用于防盗链。
  User-Agent           浏览器标识，常用于防盗链。

  */
  Download(URL, Options:="", RequestHeaders:="", Data:="", FilePath:="")
  {
    Options        := this.解析信息为对象(Options)
    RequestHeaders := this.解析信息为对象(RequestHeaders)
    RequestHeaders := this.解析SetCookie为Cookie(RequestHeaders)

    ComObjError(0)                                            ; 禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理。
    wr := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    /* Options
    https://docs.microsoft.com/en-us/windows/win32/winhttp/winhttprequestoption

    UserAgentString                  := 0
    URL                              := 1
    URLCodePage                      := 2
    EscapePercentInURL               := 3
    SslErrorIgnoreFlags              := 4
    SelectCertificate                := 5
    EnableRedirects                  := 6
    UrlEscapeDisable                 := 7
    UrlEscapeDisableQuery            := 8
    SecureProtocols                  := 9
    EnableTracing                    := 10
    RevertImpersonationOverSsl       := 11
    EnableHttpsToHttpRedirects       := 12
    EnablePassportAuthentication     := 13
    MaxAutomaticRedirects            := 14
    MaxResponseHeaderSize            := 15
    MaxResponseDrainSize             := 16
    EnableHttp1_1                    := 17
    EnableCertificateRevocationCheck := 18
    */

    if (Options.URLCodePage != "")                            ; 设置 URL 的编码。
      wr.Option(2) := Options.URLCodePage

    if (Options.EnableRedirects != "")                        ; 设置是否获取重定向跳转后的页面信息。
      wr.Option(6) := Options.EnableRedirects

    if (Options.Proxy != "")
      wr.SetProxy(2, Options.Proxy, Options.ProxyBypassList)  ; 首个参数为0表示遵循 Proxycfg.exe 的设置。1表示忽略代理直连。2表示使用代理。

    ; 第一个超时参数必须为0，否则会发生内存泄露。
    ; https://docs.microsoft.com/en-us/windows/win32/winhttp/what-s-new-in-winhttp-5-1
    if (Options.Timeout = "")
      wr.SetTimeouts(0, 60000, 30000, 0)                      ; 0表示无限等待，正整数则表示最大超时（单位毫秒）。
    else
      wr.SetTimeouts(0, 60000, 30000, Options.Timeout*1000)   ; 自定义超时。

    ; HTTP/1.1 支持以下9种请求方法。
    Methods := {GET:1, HEAD:1, POST:1, PUT:1, PATCH:1, DELETE:1, CONNECT:1, OPTIONS:1, TRACE:1}
    if (!Methods.Haskey(Options.Method))
      Options.Method := Data="" ? "GET" : "POST"              ; 请求方法为空或错误，则根据 Data 是否有值自动判断方法。
    Options.Method := Format("{:U}", Options.Method)          ; 转换为大写，小写在很多网站会出错。
    wr.Open(Options.Method, URL, true)                        ; true 为异步获取。默认是 false ，龟速的根源！！！卡顿的根源！！！

    ; 如果自己不设置 User-Agent 那么实际上会被自动设置为 Mozilla/4.0 (compatible; Win32; WinHttp.WinHttpRequest.5) 。影响数据抓取。
    if (RequestHeaders["User-Agent"] = "")
      RequestHeaders["User-Agent"] := "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36"
    if (InStr(RequestHeaders["Accept-Encoding"], "gzip"))     ; 这里必须用 RequestHeaders["Accept-Encoding"] 而不是 RequestHeaders.Accept-Encoding 。
      RequestHeaders.Delete("Accept-Encoding")                ; 删掉含 “gzip” 的 “Accept-Encoding” ，避免服务器返回 gzip 压缩后的数据。
    if (InStr(RequestHeaders["Connection"], "Keep-Alive"))
      RequestHeaders.Delete("Connection")                     ; 删掉含 “Keep-Alive” 的 “Connection” ，因为默认就会发送这个值，删掉避免重复发送。
    for k, v in RequestHeaders                                ; 原来的 MSDN 推荐在设置 Cookie 前手动添加一个值，新版找不到这个推荐了，并且 Fiddler 抓包发现这样会让 Cookie 变多，故取消手动添加。
      wr.SetRequestHeader(k, v)                               ; SetRequestHeader() 必须 Open() 之后才有效。

    Loop
    {
      wr.Send(Data)
      wr.WaitForResponse(-1)              ; WaitForResponse 方法确保获取的是完整的响应。-1表示总是使用 SetTimeouts 设置的超时。 https://www.autohotkey.com/boards/viewtopic.php?t=9137

      this.StatusCode := wr.Status()      ; 获取状态码，一般 StatusCode 为200说明请求成功。
      this.StatusText := wr.StatusText()

      if (Options.ExpectedStatusCode="" or Options.ExpectedStatusCode=this.StatusCode)
        break
      ; 尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）。
      ; 即使 NumberOfRetries 为空，表达式依然成立，所以不用为 NumberOfRetries 设置初始值。
      else if (A_Index >= Options.NumberOfRetries)
      {
        this.extra.URL                 := URL
        this.extra.ExpectedStatusCode  := Options.ExpectedStatusCode
        this.extra.StatusCode          := this.StatusCode
        this.extra.StatusText          := this.StatusText
        throw, Exception("经过 " Options.NumberOfRetries " 次尝试后，服务器返回状态码依旧与期望值不一致。", -1, Object(this.extra))
      }
    }

    this.ResponseHeaders := this.解析信息为对象(wr.GetAllResponseHeaders())          ; 存响应头
    temp_ResponseHeaders := this.解析信息为对象(wr.GetAllResponseHeaders())          ; 解析SetCookie为Cookie() 会改变传入的值，所以这里创建一个备份用于解析
    this.Cookie          := this.解析SetCookie为Cookie(temp_ResponseHeaders).Cookie  ; 存 Cookie

    if (FilePath != "")
      return, this.BinArr_ToFile(wr.ResponseBody(), FilePath)                        ; 存为文件
    else if (Options.Charset != "")
      return, this.BinArr_ToString(wr.ResponseBody(), Options.Charset)               ; 存为变量，自定义字符集
    else
      return, wr.ResponseText()                                                      ; 存为变量
  }

  /*
  infos 的格式：每行一个参数，行首至第一个冒号为参数名，之后至行尾为参数值。多个参数换行。
  注意第一行的 “GET /?tn=sitehao123 HTTP/1.1” 其实是没有任何作用的，因为没有 “:” 。但复制过来了也并不会影响正常解析。
  换句话说， Chrome 开发者工具中的 “Request Headers” 那段内容直接复制过来就能用。

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
    if (IsObject(infos))
      return, infos

    ; 以下两步可将 “infos” 换行符统一为 “`r`n” ，避免正则表达式提取时出错。
    StringReplace, infos, infos, `r`n, `n, All
    StringReplace, infos, infos, `n, `r`n, All

    ; 使用正则而不是 StrSplit() 进行处理的原因是，后者会错误处理这样的情况 “程序会根据 “Proxy:” 的值自动设置” 。
    infos_temp := GlobalRegExMatch(infos, "m)^\s*([\w\-]*?):(.*$)", 1)
    ; 将正则匹配到的信息存入新的对象中，像这样 {"Connection":"keep-alive", "Cache-Control":"max-age=0"} 。
    obj:={}
    Loop, % infos_temp.MaxIndex()
    {
      name  := Trim(infos_temp[A_Index].Value[1], " `t`r`n`v`f")  ;Trim()的作用就是把“abc: haha”中haha的多余空白符消除
      value := Trim(infos_temp[A_Index].Value[2], " `t`r`n`v`f")

      ; “Set-Cookie” 是可以一次返回多条的，因此特殊处理将返回值存入数组。
      if (name="Set-Cookie")
      {
        if (!obj.HasKey(name))
          obj[name] := []
        obj[name].Push(value)
      }
      else
        obj[name] := value
    }

    return, obj
  }

  /*
  EnableRedirects:
  ExpectedStatusCode:200
  NumberOfRetries:5

  如果 “ShowEmptyNameAndValue=0” ，那么输出的内容将不包含值为空的行（例如第一行）。
  */
  解析对象为信息(obj, ShowEmptyNameAndValue:=1)
  {
    if (!IsObject(obj))
      return, obj

    for k, v in obj
    {
      if (ShowEmptyNameAndValue=0 and Trim(v, " `t`r`n`v`f")="")
        continue

      if (k="Set-Cookie")
      {
        loop, % v.MaxIndex()
          infos .= k ":" v[A_Index] "`r`n"
      }
      else
        infos .= k ":" v "`r`n"
    }
    return, infos
  }

  /*
  在 “GetAllResponseHeaders” 中， “Set-Cookie” 可能一次存在多个，比如 “Set-Cookie:name=a; domain=xxx.com `r`n Set-Cookie:name=b; domain=www.xxx.com” 。
  之后向服务器发送 cookie 的时候，会先验证 domain ，再验证 path ，两者都成功，再发送所有符合条件的 cookies 。
  domain 的匹配方式是从字符串的尾部开始比较。
  path 的匹配方式是从头开始逐字符串比较（例如 /blog 匹配 /blog 、 /blogrool 等等）。需要注意的是， path 只在 domain 完成匹配后才比较。
  当下次访问 “www.xxx.com” 时，假如有2个符合条件的 cookie ，那么发送给服务器的 cookie 应该是 “name=b; name=a” 。
  当下次访问 “xxx.com” 时，假如只有1个符合条件的 cookie，那么发送给服务器的 cookie 应该是 “name=a” 。
  规则是， path 越详细，越靠前。 domain 越详细，越靠前（ domain 和 path 加起来就是网址了）。
  另外需要注意的是， “Set-Cookie” 中没有 domain 或者 path 的话，则以当前 url 为准。
  如果要覆盖一个已有的 cookie 值，那么需要创建一个 name 、 domain 、 path ，完全相同的 “Set-Cookie” （ name 就是 “cookie:name=value; path=/” 中的 name ）。
  当一个 cookie 存在，并且可选条件允许的话，该 cookie 的值会在接下来的每个请求中被发送至服务器。
  其值被存储在名为 Cookie 的 HTTP 消息头中，并且只包含了 cookie 的值，其它的属性全部被去除（ expires 、 domain 、 path 、 secure 全部没有了）。
  如果在指定的请求中有多个 cookies ，那么它们会被分号和空格分开，例如：（ Cookie:value1 ; value2 ; name1=value1 ）
  在没有 expires 属性时， cookie 的寿命仅限于单一的会话中。浏览器的关闭意味这一次会话的结束，所以会话 cookie 只存在于浏览器保持打开的状态之下。
  如果 expires 属性设置了一个过去的时间点，那么这个 cookie 会被立即删除。
  最后一个属性是 secure 。不像其它属性，该属性只是一个标记并且没有其它的值。
  参考 “http://my.oschina.net/hmj/blog/69638” 。

  此函数将所有 “Set-Cookie” 忽略全部属性后（例如 Domain 适用站点属性、 Expires 过期时间属性等），存为一个 “Cookie” 。
  传入的值里只有 Cookie ，直接返回；只有 Set-Cookie ，处理成 Cookie 后返回；两者都有，处理并覆盖 Cookie 后返回；两者都无，直接返回。
  Cookie 的 name 和 value 不允许包含分号，逗号和空格符。如果包含可以使用 URL 编码。
  参考 “https://blog.oonne.com/site/blog?id=31” “https://www.cnblogs.com/daysme/p/8052930.html”
  */
  解析SetCookie为Cookie(obj)
  {
    if (!obj.HasKey("Set-Cookie"))  ; 没有待处理的 “Set-Cookie” 则直接返回。
      return, obj

    Cookies:={}
    loop, % obj["Set-Cookie"].MaxIndex()
    {
      ; 根据RFC 2965标准，cookie 的 name 可以和属性相同。
      ; 但因为 name 和 value 总在最前面，所以又不会和属性混淆。
      ; https://tools.ietf.org/html/rfc2965
      Set_Cookie      := StrSplit(obj["Set-Cookie"][A_Index], ";", " `t`r`n`v`f")
      ; 可以正确处理 value 中含等号的情况 “Set-Cookie:BAIDUID=C04C13BA70E52C330434FAD20C86265C:FG=1;”
      , NameAndValue  := StrSplit(Set_Cookie[1], "=", " `t`r`n`v`f", 2)
      , name          := NameAndValue[1]
      , value         := NameAndValue[2]
      , Cookies[name] := value
    }
    obj.Delete("Set-Cookie")        ; “Set-Cookie” 转换完成后就删除。

    obj["Cookie"] := ""             ; 同时存在 “Cookie” 和 “Set-Cookie” 时，后者处理完成的值将覆盖前者。
    for k, v in Cookies
      obj["Cookie"] .= k "=" v "; "
    obj["Cookie"] := RTrim(obj["Cookie"], " ")

    return, obj
  }

  /*
  CreateFormData - Creates "multipart/form-data" for http post by tmplinshi

  https://www.autohotkey.com/boards/viewtopic.php?t=7647

  Usage: CreateFormData(ByRef retData, ByRef retHeader, objParam, BoundaryString, RandomBoundaryLength, MimeType)
    retData               - (out) Data used for HTTP POST.
    retHeader             - (out) Content-Type header used for HTTP POST.
    objParam              - (in)  An object defines the form parameters.
    BoundaryString        - (in)  default "----WebKitFormBoundary".
    RandomBoundaryLength  - (in)  default 16.
    MimeType              - (in)  default auto get MimeType.

  To specify files, use array as the value. Example:
      objParam := { "key1": "value1"
                  , "upload[]": ["1.png", "2.png"] }

  Version    : 1.31 / 2021-04-05 - 支持自定义 BoundaryString RandomBoundaryLength MimeType
                                   默认 BoundaryString 为 ----WebKitFormBoundary + 16位随机数
               1.30 / 2019-01-13 - The file parameters are now placed at the end of the retData
               1.20 / 2016-06-17 - Added CreateFormData_WinInet(), which can be used for VxE's HTTPRequest()
               1.10 / 2015-06-23 - Fixed a bug
               1.00 / 2015-05-14
  */
  CreateFormData(ByRef retData, ByRef retHeader, objParam, BoundaryString:="", RandomBoundaryLength:="", MimeType:="") {

    NonNull(BoundaryString, "----WebKitFormBoundary")
    , NonNull(RandomBoundaryLength, 16, 1)

    CRLF := "`r`n"

    Boundary := this.RandomBoundary(RandomBoundaryLength)
    BoundaryLine := "--" . BoundaryString . Boundary

    ; Loop input paramters
    binArrs := []
    fileArrs := []
    For k, v in objParam
    {
      If IsObject(v) {
        For i, FileName in v
        {
          str := BoundaryLine . CRLF
               . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
               . "Content-Type: " . NonNull_ret(MimeType, this.GetMimeType(FileName)) . CRLF . CRLF
          fileArrs.Push( this.BinArr_FromString(str) )
          fileArrs.Push( this.BinArr_FromFile(FileName) )
          fileArrs.Push( this.BinArr_FromString(CRLF) )
        }
      } Else {
        str := BoundaryLine . CRLF
             . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
             . v . CRLF
        binArrs.Push( this.BinArr_FromString(str) )
      }
    }

    binArrs.push( fileArrs* )

    str := BoundaryLine . "--" . CRLF
    binArrs.Push( this.BinArr_FromString(str) )

    retData := this.BinArr_Join(binArrs*)
    retHeader := "multipart/form-data; boundary=" . BoundaryString . Boundary
  }

  RandomBoundary(length) {
    str := [0,1,2,3,4,5,6,7,8,9
    ,"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
    ,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    loop, % length
    {
      Random, n, 1, % str.MaxIndex()
      ret .= str[n]
    }
    Return, ret
  }

  GetMimeType(FileName) {
    n := FileOpen(FileName, "r").ReadUInt()
    Return (n        = 0x474E5089) ? "image/png"
         : (n        = 0x38464947) ? "image/gif"
         : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
         : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
         : (n&0xFFFF = 0x4949    ) ? "image/tiff"
         : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
         : "application/octet-stream"
  }

  /*
  https://www.w3schools.com/asp/ado_ref_stream.asp
  https://gist.github.com/tmplinshi/a97d9a99b9aa5a65fd20
  Update: 2015-6-4 - Added BinArr_ToFile()
  */
  BinArr_FromString(str) {
    oADO := ComObjCreate("ADODB.Stream")

    oADO.Type := 2                        ; adTypeText
    oADO.Mode := 3                        ; adModeReadWrite
    oADO.Open()
    oADO.Charset := "UTF-8"
    oADO.WriteText(str)

    oADO.Position := 0                    ; 位置0， Type 可写。其它位置 Type 只读。 https://www.w3schools.com/asp/prop_stream_type.asp
    oADO.Type := 1                        ; adTypeBinary
    oADO.Position := 3                    ; Skip UTF-8 BOM
    return oADO.Read(), oADO.Close()
  }

  BinArr_FromFile(FileName) {
    oADO := ComObjCreate("ADODB.Stream")

    oADO.Type := 1                        ; adTypeBinary
    oADO.Open()
    oADO.LoadFromFile(FileName)
    return oADO.Read(), oADO.Close()
  }

  BinArr_Join(Arrays*) {
    oADO := ComObjCreate("ADODB.Stream")

    oADO.Type := 1                        ; adTypeBinary
    oADO.Mode := 3                        ; adModeReadWrite
    oADO.Open()
    For i, arr in Arrays
      oADO.Write(arr)
    oADO.Position := 0
    return oADO.Read(), oADO.Close()
  }

  BinArr_ToString(BinArr, Encoding) {
    oADO := ComObjCreate("ADODB.Stream")

    oADO.Type := 1                        ; 以二进制方式操作
    oADO.Mode := 3                        ; 可同时进行读写。 Mode 必须在 Open 前才能设置。 https://www.w3schools.com/asp/prop_stream_mode.asp
    oADO.Open()                           ; 开启物件
    oADO.Write(BinArr)                    ; 写入物件。注意 wr.ResponseBody() 获取到的是无符号的 bytes，通过 adodb.stream 转换成字符串 string

    oADO.Position := 0                    ; 位置0， Type 可写。其它位置 Type 只读。 https://www.w3schools.com/asp/prop_stream_type.asp
    oADO.Type := 2                        ; 以文字模式操作
    oADO.Charset := Encoding              ; 设定编码方式
    return oADO.ReadText(), oADO.Close()  ; 将物件内的文字读出
  }

  BinArr_ToFile(BinArr, FileName) {
    oADO := ComObjCreate("ADODB.Stream")

    oADO.Type := 1                        ; 以二进制方式操作
    oADO.Mode := 3                        ; 可同时进行读写。 Mode 必须在 Open 前才能设置。 https://www.w3schools.com/asp/prop_stream_mode.asp
    oADO.Open()                           ; 开启物件
    oADO.Write(BinArr)                    ; 写入物件。注意没法将 wr.ResponseBody() 存入一个变量，所以必须用这种方式写文件
    oADO.SaveToFile(FileName, 2)          ; 文件存在则覆盖
    oADO.Close()
  }
}

#Include %A_LineFile%\..\NonNull.ahk
#Include %A_LineFile%\..\GlobalRegExMatch.ahk