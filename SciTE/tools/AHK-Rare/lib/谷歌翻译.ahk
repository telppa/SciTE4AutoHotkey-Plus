谷歌翻译初始化:
   Gui, 谷歌翻译: +AlwaysOnTop -DPIScale
   Gui, 谷歌翻译: Font, s20, 微软雅黑
   Gui, 谷歌翻译: Add, Edit, x0 y0 w520 h414 v谷歌翻译内容框
   Gui, 谷歌翻译: Show, Hide w520 h414, 谷歌翻译
   GoogleTranslate("")          ;初始化翻译函数
Return

谷歌翻译GuiEscape:
谷歌翻译GuiClose:
    Gui, 谷歌翻译: Hide
return

谷歌翻译(str)
{
   pos:=获取最佳显示坐标()
   Gui, 谷歌翻译: Show, % "x" pos[1] "y" pos[2]
   GuiControl, 谷歌翻译:Text, 谷歌翻译内容框, 翻译中……
   GuiControl, 谷歌翻译:Text, 谷歌翻译内容框, % GoogleTranslate(str) "`r`n`r`n---------------谷歌翻译---------------`r`n`r`n" str
   return
}

获取最佳显示坐标(w:=520, h:=414)
{
   CoordMode, Mouse, Screen
   MouseGetPos, x, y
   CoordMode, Mouse, Window
   x:=x+w>A_ScreenWidth ? A_ScreenWidth-w : x           ;通过当前鼠标坐标和翻译框的宽高计算最佳显示坐标，确保翻译框显示时不会超出屏幕范围
   y:=y+h>A_ScreenHeight ? A_ScreenHeight-h : y
   return, [x, y]
}

;~ MsgBox, % GoogleTranslate("今日の天気はとても良いです")
;~ MsgBox, % GoogleTranslate("Hello my love")
GoogleTranslate(str, from := "auto", to := "zh-cn") {
   static JS := CreateScriptObj(), _ := JS.( GetJScript() ) := JS.("delete ActiveXObject; delete GetObject;")
   if (str="")          ;没有文字传入则初始化函数
      return
   ret := json.load(SendRequest(JS, str, to, from, proxy := "")), 翻译结果:=""          ;json.load处理后的返回值不能取名叫json
   for k, v in ret[1]
      翻译结果.=v[1]          ;google是按句子翻译的，v[1]表示翻译结果，v[2]表示原文，配合可实现翻译逐句对应。
   return, 翻译结果
}

SendRequest(JS, str, to, from, proxy) {
   static http
   ComObjError(false)
   if !http
   {
      http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
      ( proxy && http.SetProxy(2, proxy) )
      http.open( "get", "https://translate.google.cn", 1 )
      http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
      http.send()
      http.WaitForResponse(-1)
   }
   http.open( "POST", "https://translate.google.cn/translate_a/single?client=webapp&sl="
      . from . "&tl=" . to . "&hl=" . to
      . "&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&otf=0&ssel=0&tsel=0&pc=1&kc=1"
      . "&tk=" . JS.("tk").(str), 1 )

   http.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")
   http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
   http.send("q=" . URIEncode(str))
   http.WaitForResponse(-1)
   Return http.responsetext
}

URIEncode(str, encoding := "UTF-8") {
   VarSetCapacity(var, StrPut(str, encoding))
   StrPut(str, &var, encoding)

   While code := NumGet(Var, A_Index - 1, "UChar")  {
      bool := (code > 0x7F || code < 0x30 || code = 0x3D)
      UrlStr .= bool ? "%" . Format("{:02X}", code) : Chr(code)
   }
   Return UrlStr
}

GetJScript() {
   script =
   (
      var TKK = ((function() {
        var a = 561666268;
        var b = 1526272306;
        return 406398 + '.' + (a + b);
      })());

      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
            var c = b.charAt(d + 2),
                c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
                c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
            a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }

      function tk(a) {
          for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
              var c = a.charCodeAt(f);
              128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
              (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
              g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
          }
          a = h;
          for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
          a = b(a, "+-3^+b+-f");
          a ^= Number(e[1]) || 0;
          0 > a && (a = (a & 2147483647) + 2147483648);
          a `%= 1E6;
          return a.toString() + "." + (a ^ h)
      }
   )
   Return script
}

CreateScriptObj() {
   static doc
   doc := ComObjCreate("htmlfile")
   doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
   Return ObjBindMethod(doc.parentWindow, "eval")
}

;不加载json库，就会莫名其妙的失败，没有反应，没有提示。
#Include <json>