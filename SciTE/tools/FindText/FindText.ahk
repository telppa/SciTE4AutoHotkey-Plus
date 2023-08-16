;/*
;===========================================
;  FindText - 屏幕抓字生成字库工具与找字函数
;  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  脚本作者 : FeiYue
;  最新版本 : 9.0
;  更新时间 : 2023-04-15
;
;  用法:  (需要最新版本 AHK v1.1.34+)
;  1. 将本脚本保存为“FindText.ahk”并复制到AHK程序的Lib子目录中
;  2. 抓图并生成调用FindText()的代码
;     2.1 方式一：直接点击“抓图”按钮
;     2.2 方式二：先设定截屏热键，使用热键截屏，再点击“截屏抓图”按钮
;  3. 测试一下调用的代码是否成功:直接点击“测试”按钮
;  4. 复制调用的代码到自己的脚本中
;     4.1 方式一：直接点击“复制”按钮，然后粘贴到自己的脚本中（不推荐）
;     4.2 方式二：取消“附加FindText()函数”的选框，然后点击“复制”按钮，
;         然后粘贴到自己的脚本中，然后在自己的脚本开头加上一行:
;         #Include <FindText>  ; Lib目录中必须有FindText.ahk
;  5. 多色查找模式可以一定程度上适应图像的放大缩小，也可以找图
;  6. 这个库还可以用于快速截屏、获取颜色、写入颜色、编辑后另存图片
;  7. 如果要调用FindTextClass类中的函数，请用无参数的FindText()获取默认对象
;
;===========================================
;*/


if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
  FindText().Gui("Show")


;===== Copy The Following Functions To Your Own Code Just once =====


FindText(ByRef x:="FindTextClass", ByRef y:="", args*)
{
  global FindTextClass
  if (x=="FindTextClass")
    return FindTextClass
  else
    return FindTextClass.FindText(x, y, args*)
}

Class FindTextClass
{  ;// Class Begin

static bind:=[], bits:=[], Lib:=[], Cursor:=0

__New()
{
  this.bind:=[], this.bits:=[], this.Lib:=[], this.Cursor:=0
}

__Delete()
{
  if (this.bits.hBM)
    DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

help:="
(%
;--------------------------------
;  FindText - 屏幕找字函数
;  版本 : 9.0  (2023-04-15)
;--------------------------------
;  返回变量 := FindText(
;      OutputX --> 保存返回的X坐标的变量名称
;    , OutputY --> 保存返回的Y坐标的变量名称
;    , X1 --> 查找范围的左上角X坐标
;    , Y1 --> 查找范围的左上角Y坐标
;    , X2 --> 查找范围的右下角X坐标
;    , Y2 --> 查找范围的右下角Y坐标
;    , err1 --> 文字的黑点容错百分率（0.1=10%）
;    , err0 --> 背景的白点容错百分率（0.1=10%）
;    , Text --> 由工具生成的查找图像的数据，可以一次查找多个，用“|”分隔
;    , ScreenShot --> 是否截屏，为0则使用上一次的截屏数据
;    , FindAll --> 是否搜索所有位置，为0则找到一个位置就返回
;    , JoinText --> 如果想组合查找，可以为1，或者是要查找单词的数组
;    , offsetX --> 组合图像的每个字和前一个字的最大横向间隔
;    , offsetY --> 组合图像的每个字和前一个字的最大高低间隔
;    , dir --> 查找的方向，有上、下、左、右、中心9种
;    , zoomW --> 图像宽度的缩放百分率（1.0=100%）
;    , zoomH --> 图像高度的缩放百分率（1.0=100%）
;  )
;
;  返回变量 --> 如果没找到结果会返回0。否则返回一个二级数组，
;      第一级是每个结果对象，第二级是结果对象的具体信息数组:
;      { 1:左上角X, 2:左上角Y, 3:图像宽度W, 4:图像高度H
;        , x:中心点X, y:中心点Y, id:图像识别文本 }
;  坐标都是相对于屏幕，颜色使用RGB格式
;
;  如果 OutputX 等于 'wait' 或 'wait1' 意味着等待图像出现，
;  如果 OutputX 等于 'wait0' 意味着等待图像消失
;  此时 OutputY 设置等待时间的秒数，如果小于0则无限等待
;  如果超时则返回0，意味着失败，如果等待图像出现成功，则返回位置数组
;  如果等待图像消失成功，则返回 1
;  例1: FindText(X:='wait', Y:=3, 0,0,0,0,0,0,Text)   ; 等待3秒等图像出现
;  例2: FindText(X:='wait0', Y:=-1, 0,0,0,0,0,0,Text) ; 无限等待等图像消失
;--------------------------------
)"

FindText(ByRef OutputX:="", ByRef OutputY:=""
  , x1:="", y1:="", x2:="", y2:="", err1:="", err0:=""
  , text:="", ScreenShot:="", FindAll:=""
  , JoinText:="", offsetX:="", offsetY:="", dir:=""
  , zoomW:=1, zoomH:=1)
{
  local
  if (OutputX ~= "i)^\s*wait[10]?\s*$")
  {
    found:=!InStr(OutputX,"0"), time:=OutputY
    , timeout:=A_TickCount+Round(time*1000)
    , OutputX:=OutputY:=""
    Loop
    {
      ; Wait for the image to remain stable
      While (ok:=this.FindText(OutputX, OutputY
        , x1, y1, x2, y2, err1, err0, text, ScreenShot, FindAll
        , JoinText, offsetX, offsetY, dir, zoomW, zoomH))
        and (found)
      {
        v:=ok[1], x:=v[1], y:=v[2], w:=v[3], h:=v[4]
        Sleep, 10
        if this.FindText(0, 0, x, y, x+w-1, y+h-1
        , err1, err0, text, ScreenShot, FindAll
        , JoinText, offsetX, offsetY, dir, zoomW, zoomH)
          return (this.ok:=ok)
      }
      if (!found and !ok)
        return 1
      if (time>=0 and A_TickCount>=timeout)
        Break
      Sleep, 50
    }
    return 0
  }
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  if InStr(err1,"$") and !InStr(text,"$")
  {
    dir:=offsetX, offsetY:=JoinText, offsetX:=FindAll
    , JoinText:=ScreenShot, FindAll:=text, ScreenShot:=err0
    , text:=err1, err0:=y2, err1:=x2
    , y2:=y1, x2:=x1, y1:=OutputY, x1:=OutputX
  }
  (err1="" && err1:=0)
  , (err0="" && err0:=0)
  , (ScreenShot="" && ScreenShot:=1)
  , (FindAll="" && FindAll:=1)
  , (JoinText="" && JoinText:=0)
  , (offsetX="" && offsetX:=20)
  , (offsetY="" && offsetY:=10)
  , (dir="" && dir:=1)
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  , x-=zx, y-=zy, info:=[], this.ok:=0
  Loop Parse, text, |
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 or h<1 or !(num:=info.Length()) or !bits.Scan0)
  {
    SetBatchLines, %bch%
    return 0
  }
  arr:=[], info2:=[], k:=0, s:=""
  , mode:=(IsObject(JoinText) ? 2 : JoinText ? 1 : 0)
  For i,j in info
  {
    k:=Max(k, j[2]*j[3]), v:=(mode=1 ? i : j[11])
    if (mode and v!="")
      s.="|" v, (!info2[v] && info2[v]:=[]), info2[v].Push(j)
  }
  JoinText:=(mode=1 ? [s] : JoinText)
  , VarSetCapacity(s1, k*4), VarSetCapacity(s0, k*4)
  , VarSetCapacity(ss, w*(h+2))
  , FindAll:=(dir=9 ? 1 : FindAll)
  , allpos_max:=(FindAll or JoinText ? 10240 : 1)
  , ini:={sx:x, sy:y, sw:w, sh:h, zx:zx, zy:zy
  , mode:mode, bits:bits, ss:&ss, s1:&s1, s0:&s0
  , allpos_max:allpos_max, zoomW:zoomW, zoomH:zoomH}
  Loop 2
  {
    if (err1=0 and err0=0) and (num>1 or A_Index>1)
      err1:=0.05, err0:=0.05
    ini.err1:=err1, ini.err0:=err0
    if (!JoinText)
    {
      VarSetCapacity(allpos, allpos_max*8)
      For i,j in info
      Loop % this.PicFind(ini, j, dir, allpos
      , ini.sx, ini.sy, ini.sw, ini.sh)
      {
        x:=NumGet(allpos, 8*A_Index-8, "uint") + zx
        , y:=NumGet(allpos, 8*A_Index-4, "uint") + zy
        , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH), comment:=j[11]
        , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
        if (!FindAll)
          Break, 3
      }
    }
    else
    For k,v in JoinText
    {
      v:=RegExReplace(v, "\s*\|[|\s]*", "|")
      , v:=StrSplit(Trim(v,"|"), (InStr(v,"|")?"|":""), " `t")
      , this.JoinText(ini, arr, info2, v, offsetX, offsetY, FindAll
      , 1, v.Length(), dir, 0, 0, ini.sx, ini.sy, ini.sw, ini.sh)
      if (!FindAll and arr.Length())
        Break, 2
    }
    if (err1!=0 or err0!=0 or arr.Length()
    or info[1][8]=5 or info[1][12])
      Break
  }
  if (dir=9)
    arr:=this.Sort2(arr, Round(x1+x2)//2, Round(y1+y2)//2)
  SetBatchLines, %bch%
  if (arr.Length())
  {
    OutputX:=arr[1].x, OutputY:=arr[1].y, this.ok:=arr
    return arr
  }
  return 0
}

; the join text object <==> [ "abc", "xyz", "a1|a2|a3" ]

JoinText(ini, arr, info2, text, offsetX, offsetY, FindAll
  , index:="", Len:="", dir:="", minY:="", maxY:=""
  , sx:="", sy:="", sw:="", sh:="")
{
  local
  zoomW:=ini.zoomW, zoomH:=ini.zoomH
  , VarSetCapacity(allpos, ini.allpos_max*8)
  For i,j in info2[text[index]]
  if (ini.mode=1 or text[index]==j[11])
  Loop % this.PicFind(ini, j, dir, allpos, sx, sy
    , (index=1?sw:Min(sx+offsetX+Floor(j[2]*zoomW),ini.sx+ini.sw)-sx), sh)
  {
    x:=NumGet(allpos, 8*A_Index-8, "uint")
    , y:=NumGet(allpos, 8*A_Index-4, "uint")
    , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
    , (index=1) && (ini.x:=x, minY:=y, maxY:=y+h)
    if (index<Len)
    {
      if this.JoinText(ini, arr, info2, text, offsetX, offsetY, FindAll
      , index+1, Len, 5, (y1:=Min(y,minY)), (y2:=Max(y+h,maxY)), x+w
      , (y:=Max(y1-offsetY,ini.sy)), 0, Min(y2+offsetY,ini.sy+ini.sh)-y)
      and (index>1 or !FindAll)
        return 1
    }
    else
    {
      comment:=""
      For k,v in text
        comment.=(ini.mode=1 ? info2[v][1][11] : v)
      w:=x+w-ini.x, x:=ini.x+ini.zx
      , h:=Max(y+h,maxY)-Min(y,minY), y:=Min(y,minY)+ini.zy
      , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
      if (index>1 or !FindAll)
        return 1
    }
  }
}

PicFind(ini, j, dir, ByRef allpos, sx, sy, sw, sh)
{
  local
  static MyFunc:=""
  if (!MyFunc)
  {
    x32:=""
    . "5557565383EC7483BC2488000000058BBC24C00000000F84FE0800008BAC24C4"
    . "000000C744240C0000000085ED0F8E560D0000C74424140000000031EDC74424"
    . "0400000000C7442418000000008D76008B8424BC0000008B4C241831F631DB01"
    . "C885FF894424107F3DE99100000066900FAF8424A800000089C189F099F7FF01"
    . "C18B442410803C1831744D8B8424B800000083C30103B424D8000000890CA883"
    . "C50139DF74558B44240C99F7BC24C400000083BC24880000000375B40FAF8424"
    . "9C00000089C189F099F7FF8D0C818B442410803C183175B38B4424048B9424B4"
    . "00000083C30103B424D8000000890C8283C00139DF8944240475AB017C241883"
    . "442414018B9C24DC0000008B442414015C240C398424C40000000F8530FFFFFF"
    . "896C240C31C08B74240439B424C80000008B5C240C0F4DF0399C24CC00000089"
    . "7424040F4CC339C68944240C0F4DC683BC248800000003894424680F84840800"
    . "008B84249C0000008BB424A00000000FAF8424A40000008BBC24880000008D2C"
    . "B08B8424A80000008BB4249C000000F7D885FF8D0486894424200F851E030000"
    . "8B84248C0000008BB424AC000000C744241C00000000C7442424000000008B7C"
    . "2408C1E8100FB6C0894424108B84248C0000000FB6C4894424140FB684248C00"
    . "0000894424188B8424A8000000C1E00285F68944242C89E80F8EBA0000008B9C"
    . "24A800000085DB0F8E8D0000008BB424980000008B6C242403AC24B000000001"
    . "C60344242C8944242803842498000000894424080FB67E028B4C24100FB6160F"
    . "B646012B5424182B44241489FB01CF29CB8D8F000400000FAFC00FAFCBC1E00B"
    . "0FAFCBBBFE05000029FB0FAFDA01C10FAFD301CA399424900000000F93450083"
    . "C60483C5013B74240875A98B9C24A8000000015C24248B4424288344241C0103"
    . "4424208B74241C39B424AC0000000F854AFFFFFF897C24088B8424A80000002B"
    . "8424D8000000C644245300C644245200C744245800000000C744246000000000"
    . "8944245C8B8424AC0000002B8424DC000000894424408B84249400000083E801"
    . "83F8070F87F405000083F803894424480F8EEF0500008B4424608B7424588944"
    . "2458897424608B74245C397424580F8F620A00008B44245C8B742404C7442434"
    . "00000000894424648B8424B40000008D04B08B7424488944245489F083E00189"
    . "44244C89F08BB4249800000083E0038944246C8B4424608B7C244039F80F8F15"
    . "010000837C246C018B5C24580F4F5C2464897C24308B7C246889442424895C24"
    . "448B54244C8B44243085D20F44442424837C244803894424280F8F7602000080"
    . "7C2452008B4424448944242C8B44242C0F857E020000807C2453000F85AF0300"
    . "000FAF8424A80000000344242885FF89C28944241C0F8E590300008BAC24CC00"
    . "00008B9C24C800000031C0039424B00000008B4C240489742418896C2414895C"
    . "24108B6C240CEB13908DB4260000000083C00139C70F841503000039C17E188B"
    . "9C24B40000008B348301D6803E007507836C241001781C39C57ED58B9C24B800"
    . "00008B348301D6803E0175C4836C24140179BD8B74241889F68DBC2700000000"
    . "8344242401836C2430018B442424394424400F8D09FFFFFF8344245801836C24"
    . "64018B4424583944245C0F8DC3FEFFFF8B44243483C4745B5E5F5DC2580083BC"
    . "2488000000010F84E207000083BC2488000000020F84C90500008B84248C0000"
    . "000FB6BC248C000000C744242800000000C744242C00000000C1E8100FB6D08B"
    . "84248C000000895424100FB69424900000000FB6DC8B842490000000C1E8100F"
    . "B6C88B8424900000000FB6F48B44241029C8034C24108944243089D829F001DE"
    . "8944241489D089FA29C201F889742418894424248BB424AC0000008B8424A800"
    . "0000894C241089E98954241C8B6C2430C1E00285F6894424340F8E39FDFFFF8B"
    . "9C24A800000085DB0F8E880000008B8424980000008B54242C039424B0000000"
    . "01C8034C243489CF894C243003BC2498000000EB34395C24107C3D394C24147F"
    . "37394C24187C3189F30FB6F33974241C0F9EC3397424240F9DC183C00483C201"
    . "21D9884AFF39F8741E0FB658020FB648010FB63039DD7EBD31C983C00483C201"
    . "884AFF39F875E28BB424A80000000174242C8B4C24308344242801034C24208B"
    . "442428398424AC0000000F854FFFFFFFE983FCFFFF8B442428807C2452008944"
    . "242C8B442444894424288B44242C0F8482FDFFFF0FAF84249C0000008B5C2428"
    . "85FF8D0498894424140F8E8E0000008BAC24C800000031C9897C24108D742600"
    . "8B8424B40000008B5C2414031C888B8424B80000008B3C880FB6441E0289FAC1"
    . "EA100FB6D229D00FB6541E010FB61C1E0FAFC03B4424087F2789F80FB6C429C2"
    . "0FAFD23B5424087F1789F80FB6C029C30FAFDB3B5C24087E108DB42600000000"
    . "83ED010F88F701000083C101394C2410758E89BC248C0000008B7C24108B4424"
    . "28038424A00000008B5C24348B8C24D00000008904D98B44242C038424A40000"
    . "008944D90483C3013B9C24D4000000895C24340F8C47FDFFFF8B44243483C474"
    . "5B5E5F5DC2580089F68DBC27000000008B7424188B44240485C074A18B9C24B0"
    . "0000008B4C241C8B8424B400000001D98B5C24548B1083C00401CA39D8C60200"
    . "75F2E976FFFFFF89F68DBC27000000000FAF84249C0000008B5C24288D049889"
    . "4424140384248C00000085FF0FB65C0602895C24180FB65C06010FB60406895C"
    . "241C894424200F8E31FFFFFF8B8424CC00000031DB897C24108944243C8B8424"
    . "C8000000894424388B4424088D742600395C24047E658B8424B40000008B4C24"
    . "148B7C2418030C980FB6440E020FB6540E010FB60C0E2B54241C2B4C242089C5"
    . "01F829FD8DB8000400000FAFD20FAFFDC1E20B0FAFFDBDFE05000029C50FAFE9"
    . "01FA0FAFCD01D13B8C2490000000760B836C2438010F8895000000395C240C7E"
    . "618B8424B80000008B4C24148B7C2418030C980FB6440E020FB6540E010FB60C"
    . "0E2B54241C2B4C242089C501F829FD8DB8000400000FAFD20FAFFDC1E20B0FAF"
    . "FDBDFE05000029C50FAFE901FA0FAFCD01D13B8C24900000007707836C243C01"
    . "782E83C301395C24100F8521FFFFFF894424088B7C2410E921FEFFFF8D742600"
    . "89BC248C0000008B7C2410E990FBFFFF894424088B7C2410E983FBFFFFC74424"
    . "48000000008B4424408B74245C8944245C89742440E90CFAFFFF8B8424900000"
    . "008BB424BC00000031C931DB31ED89BC24C0000000894424688B84248C000000"
    . "0FAFC089442408EB1AB80A0000006BDB0AF7E189F901DA89FBC1FB1F01C111D3"
    . "83C6010FBE0685C00F84B80000008D78D083FF0976D383F82F75E58D04AD0000"
    . "00008944241089C80FACD8100FB7C00FAF8424DC00000099F7BC24C40000000F"
    . "AF84249C00000089C70FB7C131C90FAF8424D800000099F7BC24C00000008B94"
    . "24B40000008D04878B7C24108904AA89D88B9C24B800000083C50189043B31DB"
    . "E97BFFFFFF8B84248C000000C1E8100FAF8424DC00000099F7BC24C40000000F"
    . "AF84249C00000089C10FB784248C0000000FAF8424D800000099F7FF8D048189"
    . "84248C00000083BC2488000000058B8424A80000000F9444245283BC24880000"
    . "00030F94442453038424A00000002B8424D80000008944245C8B8424A4000000"
    . "038424AC0000002B8424DC000000894424408B8424A4000000C78424A4000000"
    . "00000000894424588B8424A0000000C78424A00000000000000089442460E953"
    . "F8FFFF8BB424A80000008B8424B0000000C744241000000000C7442414000000"
    . "008D04708944242889F0C1E002894424188B8424AC00000085C00F8ED8F7FFFF"
    . "8B8424A800000085C07E5D8B8C24980000008B5C24288BBC2498000000035C24"
    . "1401E9036C241801EF8DB426000000000FB651020FB6410183C1040FB671FC83"
    . "C3016BC04B6BD22601C289F0C1E00429F001D0C1F8078843FF39F975D38BB424"
    . "A8000000017424148344241001036C24208B442410398424AC00000075828B84"
    . "24A80000008BBC249000000031F6C74424180000000083E801894424208B8424"
    . "AC00000083E801894424248B8424A800000085C00F8EF20000008B6C24188B9C"
    . "24A80000008B44242885ED8BAC24B00000000F9444241C01F38D143089D9895C"
    . "242C89C301CB89F12B8C24A800000001EE8974241401C131C0894C2410E99400"
    . "0000807C241C000F8591000000394424200F84870000008B4C2418394C242474"
    . "7D0FB63A0FB66AFFBE0100000003BC248C00000039EF723D0FB66A0139EF7235"
    . "8B4C24100FB62939EF722A0FB62B39EF72230FB669FF39EF721B0FB6690139EF"
    . "72130FB66BFF39EF720B0FB6730139F70F92C189CE8B6C241489F1884C050083"
    . "C00183C20183C3018344241001398424A8000000741285C00F8564FFFFFF8B74"
    . "2414C6040602EBD78B74242C83442418018B442418398424AC0000000F85E9FE"
    . "FFFF89BC2490000000E90AF6FFFF8B84248C0000008B8C24AC000000C7442410"
    . "00000000C74424140000000083C001C1E0078984248C0000008B8424A8000000"
    . "C1E00285C98944241889E88BAC248C0000000F8EC0F5FFFF8B9424A800000085"
    . "D27E678B8C24980000008B5C2414039C24B000000001C1034424188944241C03"
    . "84249800000089C7908DB426000000000FB651020FB641010FB6316BC04B6BD2"
    . "2601C289F0C1E00429F001D039C50F970383C10483C30139F975D58BBC24A800"
    . "0000017C24148B44241C8344241001034424208B74241039B424AC0000000F85"
    . "74FFFFFFE92FF5FFFFC744240400000000E98EF3FFFFC744243400000000E90D"
    . "F7FFFF90909090909090909090909090"
    x64:=""
    . "4157415641554154555756534881EC88000000488BBC24F00000004C8BAC2420"
    . "01000083F905898C24D000000089542468448944240C44898C24E8000000488B"
    . "B42428010000488B9C2430010000448B942440010000448B9C24480100000F84"
    . "590900004531E44531FF4585DB0F8E1801000044897424184C89AC2420010000"
    . "31C08BAC24D0000000448BB424100100004531E4448BAC24700100004889B424"
    . "280100004531FFC744243000000000C74424100000000089C64889BC24F00000"
    . "0048637C24104531C94531C04803BC24380100004585D27F33EB7A0F1F440000"
    . "410FAFC689C14489C89941F7FA01C142803C0731743C4983C0014963C44501E9"
    . "4183C4014539C2890C837E4489F09941F7FB83FD0375C90FAF8424F800000089"
    . "C14489C89941F7FA42803C07318D0C8175C4488B9424280100004983C0014963"
    . "C74501E94183C7014539C2890C827FBC4401542410834424300103B424780100"
    . "008B4424304139C30F8553FFFFFF448B742418488BBC24F00000004C8BAC2420"
    . "010000488BB4242801000031C04439BC2450010000440F4DF84439A424580100"
    . "00440F4DE04539E74489E5410F4DEF83BC24D0000000030F84950800008B8424"
    . "F80000008B8C24000100000FAF8424080100008D04888B8C24F8000000894424"
    . "208B842410010000F7D88D0481894424308B8424D000000085C00F8548030000"
    . "8B4C24684889C84189CB0FB6C441C1EB1089C20FB6C1450FB6DB4189C28B8424"
    . "1801000085C00F8E300100008B842410010000448964243431C94C89AC242001"
    . "00004889B42428010000448B64240C448B6C24208BB42410010000C1E0024489"
    . "7C2428896C24384889BC24F00000004489D5C744241000000000894424184189"
    . "CF89D748899C243001000085F60F8E84000000488B9C24F00000004963C54531"
    . "D24C8D4C030248635C241048039C2420010000450FB631410FB651FE410FB641"
    . "FF29EA4489F14501DE4189D0418D96000400004429D929F80FAFD10FAFC00FAF"
    . "D1C1E00B8D0402BAFE0500004429F2410FAFD0410FAFD001D04139C4420F9304"
    . "134983C2014983C1044439D67FA544036C2418017424104183C70144036C2430"
    . "4439BC24180100000F855DFFFFFF448B7C2428448B6424348B6C2438488BBC24"
    . "F00000004C8BAC2420010000488BB42428010000488B9C24300100008B842410"
    . "0100002B842470010000C644245700C644245600C744246C00000000C7442474"
    . "00000000894424708B8424180100002B842478010000894424448B8424E80000"
    . "0083E80183F8070F87F305000083F8038944244C0F8EEE0500008B4424748B4C"
    . "246C8944246C894C24748B4C2470394C246C0F8F7E0A00008B4424708B4C244C"
    . "48899C24300100004C89EB4589E54C8BA42430010000C7442438000000008944"
    . "2478418D47FF488D448604488944245889C883E0018944245089C883E0038944"
    . "247C8B4424748B4C244439C80F8FE6000000837C247C018B54246C0F4F542478"
    . "894C243489442430895424480F1F40008B44245085C08B4424340F4444243083"
    . "7C244C03894424100F8F73020000807C2456008B442448894424180F857B0200"
    . "00807C2457000F85770300008B4C24180FAF8C2410010000034C241085ED0F8E"
    . "3C030000448B942458010000448B8C245001000031C0EB140F1F840000000000"
    . "4883C00139C50F8E140300004439F889C27D144189C84403048642803C030075"
    . "064183E90178194439EA7DD489CA41031484803C130175C84183EA0179C26690"
    . "8344243001836C2434018B442430394424440F8D38FFFFFF8344246C01836C24"
    . "78018B44246C394424700F8DF2FEFFFF8B4424384881C4880000005B5E5F5D41"
    . "5C415D415E415FC383BC24D0000000010F841F08000083BC24D0000000020F84"
    . "A30500008B542468448B54240CC744241800000000C74424280000000089D044"
    . "0FB6C2C1E810440FB6C84889D00FB6CC4489D04589CBC1E810894C24100FB6D0"
    . "4C89D00FB6C44129D34401CA89C18B44241029C8034C241089442438410FB6C2"
    . "4589C24129C24401C0448B842418010000894424108B842410010000C1E00245"
    . "85C0894424340F8E70FDFFFF448974243C44896424444889B42428010000448B"
    . "742420448B6424388BB4241001000044897C2440896C24484189CF48899C2430"
    . "01000089D54489D385F67E724C635424284963C631D2488D4407024D01EAEB31"
    . "4439C57C3E4139CC7F394139CF7C344439CB410F9EC044394C24100F9DC14883"
    . "C0044421C141880C124883C20139D67E24440FB6000FB648FF440FB648FE4539"
    . "C37EBD31C94883C00441880C124883C20139D67FDC4403742434017424288344"
    . "24180144037424308B442418398424180100000F856FFFFFFF448B74243C448B"
    . "7C2440448B6424448B6C2448488BB42428010000488B9C2430010000E97BFCFF"
    . "FF8B442410807C245600894424188B442448894424100F8485FDFFFF8B442418"
    . "8B4C24100FAF8424F800000085ED448D14887E79448B8C24500100004531C049"
    . "89DB428B1486438B1C844401D289D98D4202C1E9100FB6C948980FB6040729C8"
    . "8D4A014863D20FAFC00FB614174863C90FB60C0F4439F07F1A0FB6C729C10FAF"
    . "C94439F17F0D0FB6C329C20FAFD24439F27E0A4183E9010F88030200004983C0"
    . "014439C57F9C895C24684C89DB8B4C24388B542410039424000100004C8B9424"
    . "6001000089C801C04898418914828B54241803942408010000418954820489C8"
    . "83C0013B842468010000894424380F8C2CFDFFFFE957FDFFFF0F1F8000000000"
    . "4585FF74A84C8B4424584889F00F1F0089CA03104883C0044C39C0C604130075"
    . "EFEB8A8B4424188B4C24100FAF8424F80000008D048889C10344246885ED8D50"
    . "024863D2440FB614178D500148980FB604074863D20FB614170F8E4EFFFFFF44"
    . "8B9C245801000048895C24604531C948897424204C8964242889CB89C64189D4"
    . "44895C2440448B9C245001000044895C243C4539F94589C87D6E488B44242042"
    . "8B148801DA8D42024898440FB634078D42014863D20FB6141748980FB6040745"
    . "89F34501D6418D8E000400004529D329F2410FAFCB4429E00FAFC0410FAFCB41"
    . "BBFE050000C1E00B4529F3440FAFDA01C8410FAFD301C23B54240C760B836C24"
    . "3C010F88A40000004539E87D6A488B442428428B148801DA8D42024898440FB6"
    . "34078D42014863D20FB6141748980FB604074589F04501D6418D8E0004000045"
    . "29D029F2410FAFC84429E00FAFC0410FAFC841B8FE050000C1E00B4529F0440F"
    . "AFC201C8410FAFD001C23B54240C7707836C24400178354983C1014439CD0F8F"
    . "0EFFFFFF488B5C2460488B7424204C8B642428E915FEFFFF0F1F840000000000"
    . "895C24684C89DBE974FBFFFF488B5C2460488B7424204C8B642428E960FBFFFF"
    . "C744244C000000008B4424448B4C247089442470894C2444E90DFAFFFF8B4424"
    . "688B6C240C4531C04C8B8C243801000031C94189C6440FAFF0EB0F4B8D048048"
    . "63D24C8D04424983C101410FBE0185C00F84940000008D50D083FA0976DD83F8"
    . "2F75E34C89C048C1E8100FB7C00FAF8424780100009941F7FB0FAF8424F80000"
    . "0089442430410FB7C049C1E8200FAF8424700100009941F7FA8B5424308D0482"
    . "4863D183C101890496448904934531C0EB94448B4C24684489C8C1E8100FAF84"
    . "24780100009941F7FB0FAF8424F800000089C1410FB7C10FAF84247001000099"
    . "41F7FA8D04818944246883BC24D0000000058B8424100100000F9444245683BC"
    . "24D0000000030F94442457038424000100002B842470010000894424708B8424"
    . "08010000038424180100002B842478010000894424448B842408010000C78424"
    . "08010000000000008944246C8B842400010000C7842400010000000000008944"
    . "2474E993F8FFFF8B842410010000448B8C24180100004531DBC7442418000000"
    . "0001C048984C01E848894424108B842410010000C1E0024585C9894424280F8E"
    . "18F8FFFF4489742434448BB424100100004585F67E5A48634424204C63542418"
    . "4531C04C03542410488D4C07020F1F000FB6110FB641FF4883C104440FB649FA"
    . "6BC04B6BD22601C24489C8C1E0044429C801D0C1F807438804024983C0014539"
    . "C67FCD8B4C24284401742418014C24204183C3018B4C2430014C242044399C24"
    . "18010000758B4863842410010000448B742434BA010000004531D248899C2430"
    . "0100008B5C24684889BC24F00000004889B4242801000044897424284589D644"
    . "8B942410010000488D48014829C28B8424100100004889542420C74424300000"
    . "000048894C24188B8C241801000083E80144897C24344489642438896C243C89"
    . "C683E90189CA8B4C240C89D74585D20F8EDA0000004C635C24304C8B4C241845"
    . "85F64C8B442420488B442410410F94C74D01D94D01D84A8D5418014901C14901"
    . "C04B8D6C1D0031C0E98E0000000F1F004584FF0F858A00000039C60F84820000"
    . "004439F7747D0FB64AFF440FB662FE41BB0100000001D94439E17245440FB622"
    . "4439E1723C450FB660FF4439E17232450FB661FF4439E17228450FB660FE4439"
    . "E1721E450FB6204439E17215450FB661FE4439E1720B450FB6194439D9410F92"
    . "C344885C05004883C0014883C2014983C1014983C0014139C27E0F85C00F856D"
    . "FFFFFFC644050002EBDC44015424304183C6014439B424180100000F850BFFFF"
    . "FF448B742428448B7C2434448B6424388B6C243C894C240C488BBC24F0000000"
    . "488BB42428010000488B9C2430010000E9E7F5FFFF8B442468448B9424180100"
    . "004531DBC74424100000000083C001C1E007894424688B842410010000C1E002"
    . "4585D2894424180F8EAFF5FFFF44897C243448899C2430010000448B7C246844"
    . "8B9424100100008B5C242044897424284585D27E584C637424104863C34531C0"
    . "488D4C07024D01EE0F1F8400000000000FB6110FB641FF440FB649FE6BC04B6B"
    . "D22601C24489C8C1E0044429C801D04139C7430F9704064983C0014883C10445"
    . "39C27FCC035C241844015424104183C301035C243044399C2418010000759144"
    . "8B742428448B7C2434488B9C2430010000E906F5FFFFC744243800000000E9CD"
    . "F6FFFF90909090909090909090909090"
    this.MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  text:=j[1], w:=j[2], h:=j[3]
  , e1:=(j[12] ? j[6] : Floor(j[4] * ini.err1))
  , e0:=(j[12] ? j[7] : Floor(j[5] * ini.err0))
  , mode:=j[8], color:=j[9], n:=j[10]
  return (!ini.bits.Scan0) ? 0 : DllCall(&MyFunc
    , "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",ini.bits.Scan0, "int",ini.bits.Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",ini.ss, "Ptr",ini.s1, "Ptr",ini.s0
    , "AStr",text, "int",w, "int",h, "int",e1, "int",e0
    , "Ptr",&allpos, "int",ini.allpos_max
    , "int",Floor(w*ini.zoomW), "int",Floor(h*ini.zoomH))
}

/***** 机器码的 C语言 源代码 *****

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , char * ss, unsigned int * s1, unsigned int * s0
  , char * text, int w, int h, int err1, int err0
  , unsigned int * allpos, int allpos_max
  , int new_w, int new_h )
{
  int ok=0, o, i, j, k, v, r, g, b, rr, gg, bb;
  int x, y, x1, y1, x2, y2, len1, len0, e1, e0, max;
  int r_min, r_max, g_min, g_max, b_min, b_max, x3, y3;
  unsigned char * gs;
  unsigned long long sum;
  //----------------------
  // 找多色、找单色、搜图模式
  if (mode==5)
  {
    max=n; v=c*c;
    for (i=0, sum=0, o=0; (j=text[o++])!='\0';)
    {
      if (j>='0' && j<='9')
        sum = sum*10 + (j-'0');
      else if (j=='/')
      {
        y=(sum>>16)&0xFFFF; x=sum&0xFFFF;
        s1[i]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[i++]=sum>>32; sum=0;
      }
    }
    goto StartLookUp;
  }
  //----------------------
  // 生成查表需要的表格
  o=0; len1=0; len0=0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (mode==3)
        i=(y*new_h/h)*Stride+(x*new_w/w)*4;
      else
        i=(y*new_h/h)*sw+(x*new_w/w);
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=(len1>len0) ? len1 : len0;
  //----------------------
  // 颜色位置模式
  // 仅用于多色验证码的识别
  if (mode==3)
  {
    y=c>>16; x=c&0xFFFF;
    c=(y*new_h/h)*Stride+(x*new_w/w)*4;
    goto StartLookUp;
  }
  //----------------------
  // 生成二值化图像
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==0)  // 颜色相似二值化
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb; v=r+rr+rr;
        ss[i]=((1024+v)*r*r+2048*g*g+(1534-v)*b*b<=n) ? 1:0;
      }
  }
  else if (mode==1)  // 灰度阈值二值化
  {
    c=(c+1)<<7;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ss[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 1:0;
  }
  else if (mode==2)  // 灰度差值二值化
  {
    gs=(unsigned char *)(ss+sw*2);
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    for (i=0, y=0; y<sh; y++)
      for (x=0; x<sw; x++, i++)
      {
        if (x==0 || y==0 || x==sw-1 || y==sh-1)
          ss[i]=2;
        else
        {
          n=gs[i]+c;
          ss[i]=(gs[i-1]>n || gs[i+1]>n
          || gs[i-sw]>n   || gs[i+sw]>n
          || gs[i-sw-1]>n || gs[i-sw+1]>n
          || gs[i+sw-1]>n || gs[i+sw+1]>n) ? 1:0;
        }
      }
  }
  else  // (mode==4) 颜色分量二值化
  {
    r=(c>>16)&0xFF; g=(c>>8)&0xFF; b=c&0xFF;
    rr=(n>>16)&0xFF; gg=(n>>8)&0xFF; bb=n&0xFF;
    r_min=r-rr; g_min=g-gg; b_min=b-bb;
    r_max=r+rr; g_max=g+gg; b_max=b+bb;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]; g=Bmp[1+o]; b=Bmp[o];
        ss[i]=(r>=r_min && r<=r_max
            && g>=g_min && g<=g_max
            && b>=b_min && b<=b_max) ? 1:0;
      }
  }
  //----------------------
  StartLookUp:
  w=new_w; h=new_h;
  if (mode==5 || mode==3)
    { x1=sx; y1=sy; x2=sx+sw-w; y2=sy+sh-h; sx=0; sy=0; }
  else
    { x1=0; y1=0; x2=sw-w; y2=sh-h; }
  if (dir<1 || dir>8) dir=1;
  // 1 ==> ( Left to Right ) Top to Bottom
  // 2 ==> ( Right to Left ) Top to Bottom
  // 3 ==> ( Left to Right ) Bottom to Top
  // 4 ==> ( Right to Left ) Bottom to Top
  // 5 ==> ( Top to Bottom ) Left to Right
  // 6 ==> ( Bottom to Top ) Left to Right
  // 7 ==> ( Top to Bottom ) Right to Left
  // 8 ==> ( Bottom to Top ) Right to Left
  if (--dir>3) { i=y1; y1=x1; x1=i; i=y2; y2=x2; x2=i; }
  for (y3=y1; y3<=y2; y3++)
  {
    for (x3=x1; x3<=x2; x3++)
    {
      y=((dir&3)>1) ? y1+y2-y3 : y3;
      x=(dir&1) ? x1+x2-x3 : x3;
      if (dir>3) { i=y; y=x; x=i; }
      //----------------------
      e1=err1; e0=err0;
      if (mode==5)
      {
        o=y*Stride+x*4;
        for (i=0; i<max; i++)
        {
          j=o+s1[i]; c=s0[i]; r=Bmp[2+j]-((c>>16)&0xFF);
          g=Bmp[1+j]-((c>>8)&0xFF); b=Bmp[j]-(c&0xFF);
          if ((r*r>v || g*g>v || b*b>v) && (--e1)<0)
            goto NoMatch;
        }
      }
      else if (mode==3)
      {
        o=y*Stride+x*4;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb; v=r+rr+rr;
            if ((1024+v)*r*r+2048*g*g+(1534-v)*b*b>n && (--e1)<0)
              goto NoMatch;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb; v=r+rr+rr;
            if ((1024+v)*r*r+2048*g*g+(1534-v)*b*b<=n && (--e0)<0)
              goto NoMatch;
          }
        }
      }
      else
      {
        o=y*sw+x;
        for (i=0; i<max; i++)
        {
          if (i<len1 && ss[o+s1[i]]==0 && (--e1)<0) goto NoMatch;
          if (i<len0 && ss[o+s0[i]]==1 && (--e0)<0) goto NoMatch;
        }
        // 清空已经找到的图像
        for (i=0; i<len1; i++)
          ss[o+s1[i]]=0;
      }
      allpos[ok*2]=sx+x; allpos[ok*2+1]=sy+y;
      if (++ok>=allpos_max) goto Return1;
      NoMatch:;
    }
  }
  //----------------------
  Return1:
  return ok;
}

*/

GetBitsFromScreen(ByRef x:=0, ByRef y:=0, ByRef w:=0, ByRef h:=0
  , ScreenShot:=1, ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
{
  local
  static CAPTUREBLT:=""
  (!IsObject(this.bits) && this.bits:=[]), bits:=this.bits
  if (!ScreenShot and bits.Scan0)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    if IsByRef(x)
      w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
      , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
    return bits
  }
  bch:=A_BatchLines, cri:=A_IsCritical
  Critical
  if (id:=this.BindWindow(0,0,1))
  {
    WinGet, id, ID, ahk_id %id%
    WinGetPos, zx, zy, zw, zh, ahk_id %id%
  }
  if (!id)
  {
    SysGet, zx, 76
    SysGet, zy, 77
    SysGet, zw, 78
    SysGet, zh, 79
  }
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (zw>bits.oldzw or zh>bits.oldzh or !bits.hBM)
  {
    DllCall("DeleteObject", "Ptr",bits.hBM)
    , bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
  }
  if (!ScreenShot or w<1 or h<1 or !bits.hBM)
  {
    Critical, %cri%
    SetBatchLines, %bch%
    return bits
  }
  if IsFunc(k:="GetBitsFromScreen2")
    and %k%(bits, x-zx, y-zy, w, h)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    Critical, %cri%
    SetBatchLines, %bch%
    return bits
  }
  if (CAPTUREBLT="")  ; thanks Descolada
  {
    DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*",i:=0)
    CAPTUREBLT:=i ? 0 : 0x40000000
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",bits.hBM, "Ptr")
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC2:=DllCall("GetDCEx", "Ptr",id, "Ptr",0, "int",3, "Ptr")
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",hDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020|CAPTUREBLT)
      DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC2)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
      oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
      DllCall("PrintWindow", "Ptr",id, "Ptr",mDC2, "uint",(mode>3)*3)
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",mDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020)
      DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
      DllCall("DeleteDC", "Ptr",mDC2)
      DllCall("DeleteObject", "Ptr",hBM2)
    }
  }
  else
  {
    win:=DllCall("GetDesktopWindow", "Ptr")
    hDC:=DllCall("GetWindowDC", "Ptr",win, "Ptr")
    DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , "Ptr",hDC, "int",x, "int",y, "uint",0xCC0020|CAPTUREBLT)
    DllCall("ReleaseDC", "Ptr",win, "Ptr",hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  Critical, %cri%
  SetBatchLines, %bch%
  return bits
}

CreateDIBSection(w, h, bpp:=32, ByRef ppvBits:=0, ByRef bi:="")
{
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  , NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  , NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",&bi
    , "int",0, "Ptr*",ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

PicInfo(text)
{
  local
  static info:=[]
  if !InStr(text,"$")
    return
  key:=(r:=StrLen(text))<10000 ? text
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , "Ptr",&text, "uint",r*(1+!!A_IsUnicode), "uint")
  if (info[key])
    return info[key]
  v:=text, comment:="", seterr:=e1:=e0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v, "O)<([^>\n]*)>", r)
    v:=StrReplace(v,r[0]), comment:=Trim(r[1])
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v, "O)\[([^\]\n]*)]", r)
  {
    v:=StrReplace(v,r[0]), r:=StrSplit(r[1], ",", " ")
    , seterr:=1, e1:=r[1], e0:=r[2]
  }
  color:=StrSplit(v,"$")[1], v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5
    : InStr(color,"-") ? 4 : InStr(color,"#") ? 3
    : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
  color:=RegExReplace(color, "[*#\s]")
  if (mode=5)
  {
    ; 你可以使用 Text:="##10-RRGGBB-RRGGBB... $ d:\a.bmp"
    ; 那么 0xRRGGBB(+/-10)... 就是透明色
    if (v~="[^\s\w\-/,]") and FileExist(v)  ; ImageSearch
    {
      if !(hBM:=LoadPicture(v))
        return
      this.GetBitmapWH(hBM, w, h)
      if (w<1 or h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", "Ptr",hBM)
      if (!Scan0)
        return
      r:=RegExReplace(Trim(color,"-"), "i)-(?!0x)", "-0x")
      arr:=StrSplit(r,"-"), n:=Floor(arr.RemoveAt(1))
      VarSetCapacity(v, w*h*18*(1+!!A_IsUnicode)), i:=-4, y:=-1
      SetFormat, IntegerFast, d
      Loop % h
        Loop % w+0*(++y)
        {
          ok:=1, c:=NumGet(Scan0+(i+=4),"uint")
          , r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
          For j,k in arr
            if Abs((k&0xFF)-b)<=n
            and Abs(((k>>8)&0xFF)-g)<=n
            and Abs(((k>>16)&0xFF)-r)<=n and !(ok:=0)
              Break
          if (ok)
            v.=(A_Index-1)|y<<16|(c&0xFFFFFF)<<32 . "/"
        }
      StrReplace(v, "/",, n)
      DllCall("DeleteObject", "Ptr",hBM2)
    }
    else
    {
      v:=Trim(StrReplace(RegExReplace(v,"\s"),",","/"),"/")
      r:=StrSplit(v,"/"), n:=r.Length()//3
      if (!n)
        return
      VarSetCapacity(v, n*18*(1+!!A_IsUnicode))
      x1:=x2:=r[1], y1:=y2:=r[2]
      SetFormat, IntegerFast, d
      Loop % n + (i:=-2)*0
        x:=r[i+=3], y:=r[i+1]
        , (x<x1 && x1:=x), (x>x2 && x2:=x)
        , (y<y1 && y1:=y), (y>y2 && y2:=y)
      Loop % n + (i:=-2)*0
        v.=(r[i+=3]-x1)|(r[i+1]-y1)<<16|(Floor("0x"
        . StrReplace(r[i+2],"0x"))&0xFFFFFF)<<32 . "/"
      w:=x2-x1+1, h:=y2-y1+1
    }
    color:=Floor(StrSplit(color,"-")[1]), len1:=n, len0:=0
  }
  else
  {
    r:=StrSplit(v,"."), w:=r[1]
    , v:=this.base64tobit(r[2]), h:=StrLen(v)//w
    if (w<1 or h<1 or StrLen(v)!=w*h)
      return
    if (mode=4)
    {
      r:=StrSplit(StrReplace(color,"0x"),"-")
      , color:=Floor("0x" r[1]), n:=Floor("0x" r[2])
    }
    else
    {
      r:=StrSplit(color,"@")
      , color:=r[1], n:=Round(r[2],2)+(!r[2])
      , n:=Floor(512*9*255*255*(1-n)*(1-n))
      if (mode=3)
        color:=(((color-1)//w)<<16)|Mod(color-1,w)
    }
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
  }
  e1:=Floor(len1*e1), e0:=Floor(len0*e0)
  return info[key]:=[v, w, h, len1, len0, e1, e0
    , mode, color, n, comment, seterr]
}

GetBitmapWH(hBM, ByRef w, ByRef h)
{
  local
  VarSetCapacity(bm, size:=(A_PtrSize=8 ? 32:24), 0)
  r:=DllCall("GetObject", "Ptr",hBM, "int",size, "Ptr",&bm)
  w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
  return r
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w2, h2)
{
  local
  if (w2<1 or h2<1 or !hBM1 or !hBM2)
    return
  mDC1:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM1:=DllCall("SelectObject", "Ptr",mDC1, "Ptr",hBM1, "Ptr")
  mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
  DllCall("BitBlt", "Ptr",mDC1
    , "int",x1, "int",y1, "int",w2, "int",h2, "Ptr",mDC2
    , "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
  DllCall("DeleteDC", "Ptr",mDC2)
  DllCall("SelectObject", "Ptr",mDC1, "Ptr",oBM1)
  DllCall("DeleteDC", "Ptr",mDC1)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w2,h2,Reverse:=0)
{
  local
  if (w2<1 or h2<1 or !Scan01 or !Scan02)
    return
  p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w2*=4
  if (Reverse)
    p2+=(h2+1)*Stride2, Stride2:=-Stride2
  Loop % h2
    DllCall("RtlMoveMemory","Ptr",p1+=Stride1,"Ptr",p2+=Stride2,"Ptr",w2)
}

; 绑定窗口从而可以后台查找这个窗口的图像
; 相当于始终在前台。解绑窗口使用 FindText().BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  local
  (!IsObject(this.bind) && this.bind:=[]), bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id, bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      WinGet, i, ExStyle, ahk_id %bind_id%
      bind.oldStyle:=i
      WinSet, Transparent, 255, ahk_id %bind_id%
      Loop 30
      {
        Sleep, 100
        WinGet, i, Transparent, ahk_id %bind_id%
      }
      Until (i=255)
    }
  }
  else
  {
    bind_id:=bind.id
    if (bind.mode & 1)
      WinSet, ExStyle, % bind.oldStyle, ahk_id %bind_id%
    bind.id:=0, bind.mode:=0, bind.oldStyle:=0
  }
}

; 使用 FindText().CaptureCursor(1) 设置抓图时捕获鼠标
; 使用 FindText().CaptureCursor(0) 取消抓图时捕获鼠标

CaptureCursor(hDC:=0, zx:=0, zy:=0, zw:=0, zh:=0, get_cursor:=0)
{
  local
  if (get_cursor)
    return this.Cursor
  if (hDC=1 or hDC=0) and (zw=0)
  {
    this.Cursor:=hDC
    return
  }
  VarSetCapacity(mi, 40, 0), NumPut(16+A_PtrSize, mi, "int")
  DllCall("GetCursorInfo", "Ptr",&mi)
  bShow   := NumGet(mi, 4, "int")
  hCursor := NumGet(mi, 8, "Ptr")
  x := NumGet(mi, 8+A_PtrSize, "int")
  y := NumGet(mi, 12+A_PtrSize, "int")
  if (!bShow) or (x<zx or y<zy or x>=zx+zw or y>=zy+zh)
    return
  VarSetCapacity(ni, 40, 0)
  DllCall("GetIconInfo", "Ptr",hCursor, "Ptr",&ni)
  xCenter  := NumGet(ni, 4, "int")
  yCenter  := NumGet(ni, 8, "int")
  hBMMask  := NumGet(ni, (A_PtrSize=8?16:12), "Ptr")
  hBMColor := NumGet(ni, (A_PtrSize=8?24:16), "Ptr")
  DllCall("DrawIconEx", "Ptr",hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, "Ptr",hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", "Ptr",hBMMask)
  DllCall("DeleteObject", "Ptr",hBMColor)
}

MCode(ByRef code, hex)
{
  local
  VarSetCapacity(code, len:=StrLen(hex)//2)
  DllCall("crypt32\CryptStringToBinary", "Str",hex, "uint",0
  , "uint",4 , "Ptr",&code, "uint*",len, "Ptr",0, "Ptr",0)
  DllCall("VirtualProtect","Ptr",&code,"Ptr",len,"uint",0x40,"Ptr*",0)
}

base64tobit(s)
{
  local
  static Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
  {
    s:=RegExReplace(s, "[" A_LoopField "]"
    , ((i:=A_Index-1)>>5&1) . (i>>4&1)
    . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1))
  }
  ListLines, %lls%
  return RegExReplace(RegExReplace(s,"[^01]+"),"10*$")
}

bit2base64(s)
{
  local
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
  {
    s:=StrReplace(s, "|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    , A_LoopField)
  }
  return s
}

xywh2xywh(x1,y1,w1,h1, ByRef x, ByRef y, ByRef w, ByRef h
  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
{
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  w:=Min(x1+w1,zx+zw), x:=Max(x1,zx), w-=x
  , h:=Min(y1+h1,zy+zh), y:=Max(y1,zy), h-=y
}

ASCII(s)
{
  local
  if RegExMatch(s, "O)\$(\d+)\.([\w+/]+)", r)
  {
    s:=RegExReplace(this.base64tobit(r[2]),".{" r[1] "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s:=""
  return s
}

; 可以在脚本的开头用 FindText().PicLib(Text,1) 导入字库,
; 然后使用 FindText().PicLib("说明文字1|说明文字2|...") 获取字库中的数据

PicLib(comments, add_to_Lib:=0, index:=1)
{
  local
  (!IsObject(this.Lib) && this.Lib:=[]), Lib:=this.Lib
  , (!Lib[index] && Lib[index]:=[]), Lib:=Lib[index]
  if (add_to_Lib)
  {
    re:="O)<([^>\n]*)>[^$\n]+\$[^""\r\n]+"
    Loop Parse, comments, |
      if RegExMatch(A_LoopField, re, r)
      {
        s1:=Trim(r[1]), s2:=""
        Loop Parse, s1
          s2.="_" . Format("{:d}",Ord(A_LoopField))
        Lib[s2]:=r[0]
      }
    Lib[""]:=""
  }
  else
  {
    Text:=""
    Loop Parse, comments, |
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop Parse, s1
        s2.="_" . Format("{:d}",Ord(A_LoopField))
      Text.="|" . Lib[s2]
    }
    return Text
  }
}

; 分割字符串为单个文字并获取数据

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; 使用 FindText().PicX(Text) 可以将文字分割成多个单字的组合，从而适应间隔变化
; 但是不能用于“颜色位置二值化”模式, 因为位置是与整体图像相关的

PicX(Text)
{
  local
  if !RegExMatch(Text, "O)(<[^$\n]+)\$(\d+)\.([\w+/]+)", r)
    return Text
  v:=this.base64tobit(r[3]), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r[2] "}","$0`n")
  While InStr(txt,c)
  {
    While !(txt~="m`n)^" c)
      txt:=RegExReplace(txt,"m`n)^.")
    i:=0
    While (txt~="m`n)^.{" i "}" c)
      i:=Format("{:d}",i+1)
    v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
    txt:=RegExReplace(txt,"m`n)^.{" i "}")
    if (v!="")
      Text.="|" r[1] "$" i "." this.bit2base64(v)
  }
  return Text
}

; 截屏，作为后续操作要用的“上一次的截屏”

ScreenShot(x1:=0, y1:=0, x2:=0, y2:=0)
{
  this.FindText(0, 0, x1, y1, x2, y2)
}

; 从“上一次的截屏”中快速获取指定坐标的RGB颜色
; 如果坐标超出了屏幕范围，将返回白色

GetColor(x, y, fmt:=1)
{
  local
  bits:=this.GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
  , c:=(x<zx or x>=zx+zw or y<zy or y>=zy+zh or !bits.Scan0)
  ? 0xFFFFFF : NumGet(bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4,"uint")
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; 在“上一次的截屏”中设置点的RGB颜色

SetColor(x, y, color:=0x000000)
{
  local
  bits:=this.GetBitsFromScreen(0,0,0,0,0,zx,zy,zw,zh)
  if !(x<zx or x>=zx+zw or y<zy or y>=zy+zh or !bits.Scan0)
    NumPut(color,bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4,"uint")
}

; 根据 FindText() 的结果识别一行文字或验证码
; offsetX 为两个文字的最大间隔，超过会插入*号
; offsetY 为两个文字的最大高度差
; overlapW 用于设置覆盖的宽度
; 最后返回数组:{text:识别结果, x:结果左上角X, y:结果左上角Y, w:宽, h:高}

Ocr(ok, offsetX:=20, offsetY:=20, overlapW:=0)
{
  local
  ocr_Text:=ocr_X:=ocr_Y:=min_X:=dx:=""
  For k,v in ok
    x:=v[1]
    , min_X:=(A_Index=1 or x<min_X ? x : min_X)
    , max_X:=(A_Index=1 or x>max_X ? x : max_X)
  While (min_X!="" and min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v[1], y:=v[2]
      if (x<min_X) or Abs(y-ocr_Y)>offsetY
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" or x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v[3], LeftH:=v[4], LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" and LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  return {text:ocr_Text, x:ocr_X, y:min_Y
    , w: min_X-ocr_X, h: max_Y-min_Y}
}

; 按照从左到右、从上到下的顺序排序FindText()的结果
; 忽略轻微的Y坐标差距，返回排序后的数组对象

Sort(ok, dy:=10)
{
  local
  if !IsObject(ok)
    return ok
  s:="", n:=150000, ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k1,v1 in ypos
    if Abs(y-v1)<=dy
    {
      y:=v1, add:=0
      Break
    }
    if (add)
      ypos.Push(y)
    s.=(y*n+x) "." k "|"
  }
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  Loop Parse, s, |
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; 以指定点为中心，按从近到远排序FindText()的结果，返回排序后的数组

Sort2(ok, px, py)
{
  local
  if !IsObject(ok)
    return ok
  s:=""
  For k,v in ok
    s.=((v.x-px)**2+(v.y-py)**2) "." k "|"
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  Loop Parse, s, |
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; 按指定的查找方向，排序FindText()的结果，返回排序后的数组

Sort3(ok, dir:=1)
{
  local
  if !IsObject(ok)
    return ok
  s:="", n:=150000
  For k,v in ok
    x:=v[1], y:=v[2]
    , s.=(dir=1 ? y*n+x
    : dir=2 ? y*n-x
    : dir=3 ? -y*n+x
    : dir=4 ? -y*n-x
    : dir=5 ? x*n+y
    : dir=6 ? x*n-y
    : dir=7 ? -x*n+y
    : dir=8 ? -x*n-y : y*n+x) "." k "|"
  s:=Trim(s,"|")
  Sort, s, N D|
  ok2:=[]
  Loop Parse, s, |
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; 提示某个坐标的位置，或远程控制中当前鼠标的位置

MouseTip(x:="", y:="", w:=10, h:=10, d:=4)
{
  local
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","Ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  Loop 4
  {
    this.RangeTip(x-w, y-h, 2*w+1, 2*h+1, (A_Index & 1 ? "Red":"Blue"), d)
    Sleep, 500
  }
  this.RangeTip()
}

; 显示范围的边框，类似于 ToolTip

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=2)
{
  local
  static id:=0
  if (x="")
  {
    id:=0
    Loop 4
      Gui, Range_%A_Index%: Destroy
    return
  }
  if (!id)
  {
    Loop 4
      Gui, Range_%A_Index%: +Hwndid +AlwaysOnTop -Caption +ToolWindow
        -DPIScale +E0x08000000
  }
  x:=Floor(x), y:=Floor(y), w:=Floor(w), h:=Floor(h), d:=Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 or i=3 ? w+2*d : d)
    , h1:=(i=2 or i=4 ? h+2*d : d)
    Gui, Range_%i%: Color, %color%
    Gui, Range_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
  }
}

; 快速获取屏幕图像的搜索文本数据

GetTextFromScreen(x1, y1, x2, y2, Threshold:=""
  , ScreenShot:=1, ByRef rx:="", ByRef ry:="", cut:=1)
{
  local
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  if (w<1 or h<1)
  {
    SetBatchLines, %bch%
    return
  }
  gs:=[], k:=0
  Loop %h%
  {
    j:=y+A_Index-1
    Loop %w%
      i:=x+A_Index-1, c:=this.GetColor(i,j,0)
      , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  }
  if InStr(Threshold,"**")
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
      Threshold:=50
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop %h%
    {
      y1:=A_Index
      Loop %w%
        x1:=A_Index, i:=y1*sw+x1+1, j:=gs[i]+Threshold
        , s.=( gs[i-1]>j || gs[i+1]>j
        || gs[i-sw]>j || gs[i+sw]>j
        || gs[i-sw-1]>j || gs[i-sw+1]>j
        || gs[i+sw-1]>j || gs[i+sw+1]>j ) ? "1":"0"
    }
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
    {
      pp:=[]
      Loop 256
        pp[A_Index-1]:=0
      Loop % w*h
        pp[gs[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop % w*h
      s.=gs[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  if (cut=1)
  {
    re1:="(^0{" w "}|^1{" w "})"
    re2:="(0{" w "}$|1{" w "}$)"
    While (s~=re1)
      s:=RegExReplace(s,re1), CutUp++
    While (s~=re2)
      s:=RegExReplace(s,re2), CutDown++
  }
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  SetBatchLines, %bch%
  return s
}

; 快速保存截图为BMP文件，可用于调试

SavePic(file, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  if (w<1 or h<1 or !bits.Scan0)
    return
  hBM:=this.CreateDIBSection(w, -h, bpp:=24, ppvBits, bi)
  hBM2:=this.CreateDIBSection(w, h, 32, Scan0), Stride:=w*4
  this.CopyBits(Scan0,Stride,0,0,bits.Scan0,bits.Stride,x,y,w,h)
  this.CopyHBM(hBM, 0, 0, hBM2, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM2)
  size:=((w*bpp+31)//32)*4*h, NumPut(size, bi, 20, "uint")
  VarSetCapacity(bf, 14, 0), StrPut("BM", &bf, "CP0")
  NumPut(54+size, bf, 2, "uint"), NumPut(54, bf, 10, "uint")
  f:=FileOpen(file,"w"), f.RawWrite(bf,14), f.RawWrite(bi,40)
  , f.RawWrite(ppvBits+0, size), f.Close()
  DllCall("DeleteObject", "Ptr",hBM)
}

; 显示保存的图像

ShowPic(file:="", show:=1, ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="")
{
  local
  if (file="")
  {
    this.ShowScreenShot()
    return
  }
  if !FileExist(file) or !(hBM:=LoadPicture(file))
    return
  this.GetBitmapWH(hBM, w, h)
  bits:=this.GetBitsFromScreen(0,0,0,0,0,x,y)
  if (w<1 or h<1 or !bits.Scan0)
  {
    DllCall("DeleteObject", "Ptr",hBM)
    return
  }
  hBM2:=this.CreateDIBSection(w, h, 32, Scan0), Stride:=w*4
  this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
  this.CopyBits(bits.Scan0,bits.Stride,0,0,Scan0,Stride,0,0,w,h)
  DllCall("DeleteObject", "Ptr",hBM2)
  DllCall("DeleteObject", "Ptr",hBM)
  if (show)
    this.ShowScreenShot(x, y, x+w-1, y+h-1, 0)
}

; 显示内存中的屏幕截图用于调试

ShowScreenShot(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static hPic, oldw, oldh
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
  {
    Gui, FindText_Screen: Destroy
    return
  }
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  if (w<1 or h<1 or !bits.Scan0)
    return
  hBM:=this.CreateDIBSection(w, h, 32, Scan0), Stride:=w*4
  this.CopyBits(Scan0,Stride,0,0,bits.Scan0,bits.Stride,x,y,w,h)
  ;---------------
  Gui, FindText_Screen: +LastFoundExist
  IfWinNotExist
  {
    Gui, FindText_Screen: +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
    Gui, FindText_Screen: Margin, 0, 0
    Gui, FindText_Screen: Add, Pic, HwndhPic w%w% h%h%
    Gui, FindText_Screen: Show, NA x%zx% y%zy% w%w% h%h%, Show Pic
    oldw:=w, oldh:=h
  }
  else if (oldw!=w or oldh!=h)
  {
    oldw:=w, oldh:=h
    GuiControl, FindText_Screen: Move, %hPic%, w%w% h%h%
    Gui, FindText_Screen: Show, NA w%w% h%h%
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  DllCall("BitBlt", "Ptr",mDC, "int",0, "int",0, "int",w, "int",h
    , "Ptr",mDC, "int",0, "int",0, "uint",0xC000CA) ; MERGECOPY
  ;---------------
  hDC:=DllCall("GetDC", "Ptr",hPic, "Ptr")
  DllCall("BitBlt", "Ptr",hDC, "int",0, "int",0, "int",w, "int",h
    , "Ptr",mDC, "int",0, "int",0, "uint",0xCC0020)
  DllCall("ReleaseDC", "Ptr",hPic, "Ptr",hDC)
  ;---------------
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  DllCall("DeleteObject", "Ptr",hBM)
}

; 等待几秒钟直到屏幕图像改变，需要先调用FindText().ScreenShot()

WaitChange(time:=-1, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  hash:=this.GetPicHash(x1, y1, x2, y2, 0)
  timeout:=A_TickCount+Round(time*1000)
  Loop
  {
    if (hash!=this.GetPicHash(x1, y1, x2, y2, 1))
      return 1
    if (time>=0 and A_TickCount>=timeout)
      Break
    Sleep, 10
  }
  return 0
}

WaitNotChange(time:=1, timeout:=30, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  oldhash:="", timeout:=A_TickCount+Round(Abs(timeout)*1000)
  Loop
  {
    hash:=this.GetPicHash(x1, y1, x2, y2, 1), t:=A_TickCount
    if (hash!=oldhash)
      oldhash:=hash, timeout2:=t+Round(Abs(time)*1000)
    if (t>=timeout2)
      return 1
    if (t>=timeout)
      return 0
    Sleep, 10
  }
}

GetPicHash(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static h:=DllCall("LoadLibrary", "Str","ntdll", "Ptr")
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  if (w<1 or h<1 or !bits.Scan0)
    return 0
  hash:=0, Stride:=bits.Stride, p:=bits.Scan0+(y-1)*Stride+x*4, w*=4
  Loop % h
    hash:=(hash*31+DllCall("ntdll\RtlComputeCrc32", "uint",0
      , "Ptr",p+=Stride, "uint",w, "uint"))&0xFFFFFFFF
  return hash
}

WindowToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  WinGetPos, winx, winy,,, % id ? "ahk_id " id : "A"
  x:=x1+Floor(winx), y:=y1+Floor(winy)
}

ScreenToWindow(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.WindowToScreen(dx,dy,0,0,id), x:=x1-dx, y:=y1-dy
}

ClientToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  if (!id)
    WinGet, id, ID, A
  VarSetCapacity(pt,8,0), NumPut(0,pt,"int64")
  , DllCall("ClientToScreen", "Ptr",id, "Ptr",&pt)
  , x:=x1+NumGet(pt,"int"), y:=y1+NumGet(pt,4,"int")
}

ScreenToClient(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.ClientToScreen(dx,dy,0,0,id), x:=x1-dx, y:=y1-dy
}

; 不像 FindText 总是使用屏幕坐标，它使用与内置命令
; ImageSearch 一样的 CoordMode 设置的坐标模式

ImageSearch(ByRef rx, ByRef ry, x1, y1, x2, y2, text
  , ScreenShot:=1, FindAll:=0)
{
  local
  dx:=dy:=0
  if (A_CoordModePixel="Window")
    this.WindowToScreen(dx,dy,0,0)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(dx,dy,0,0)
  n:=RegExMatch(text, "O)\*(\d+)", r) ? r[1]:10
  t:=RegExMatch(text, "Oi)\*Trans(\S+)", r) ? "-" r[1]:""
  if FileExist(pic:=RegExReplace(text,"\*\S+\s+"))
    text:="|<>##" n . t "$" pic
  if (ok:=this.FindText(x, y, x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll))
  {
    For k,v in ok  ; you can use ok:=FindText().ok
      v[1]-=dx, v[2]-=dy, v.x-=dx, v.y-=dy
    rx:=x-dx, ry:=y-dy, ErrorLevel:=0
    return 1
  }
  else
  {
    rx:=ry:="", ErrorLevel:=1
    return 0
  }
}

Click(x:="", y:="", other1:="", other2:="")
{
  local
  bak:=A_CoordModeMouse
  CoordMode, Mouse, Screen
  MouseMove, x, y, 0
  Click, %x%, %y%, %other1%, %other2%
  CoordMode, Mouse, %bak%
}

; 动态运行AHK代码作为新线程

Class Thread
{
  __New(args*)
  {
    this.pid:=this.Exec(args*)
  }
  __Delete()
  {
    DetectHiddenWindows, On
    WinWait, % "ahk_pid " this.pid,, 0.5
    IfWinExist, % "ahk_class AutoHotkey ahk_pid " this.pid
    {
      PostMessage, 0x111, 65307
      WinWaitClose,,, 0.5
    }
    Process, Close, % this.pid
  }
  Exec(s, Ahk:="", args:="")    ; required AHK v1.1.34+
  {
    local
    Ahk:=Ahk ? Ahk : A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    add:=A_IsCompiled ? " /script " : ""
    s:="`nDllCall(""SetWindowText"",""Ptr"",A_ScriptHwnd,""Str"",""<AHK>"")`n"
      . "`nSetBatchLines,-1`n" . StrReplace(s,"`r")
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec("""" Ahk """" add " /force * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`n FileDelete, " f "`n" s
      FileDelete, %f%
      FileAppend, %s%, %f%
      r:=this.Clear.Bind(this)
      SetTimer, %r%, -3000
      Run, "%Ahk%" %add% /force "%f%" %args%,, UseErrorLevel, pid
    }
    return pid
  }
  Clear()
  {
    FileDelete, % A_Temp "\~ahk.tmp"
    SetTimer,, Off
  }
}

; FindText().QPC() 用法类似于 A_TickCount

QPC()
{
  static f:=0, c:=DllCall("QueryPerformanceFrequency","Int*",f)+(f/=1000)
  return (!DllCall("QueryPerformanceCounter","Int64*",c))*0+(c/f)
}

; FindText().ToolTip() 用法类似于 ToolTip

ToolTip(s:="", x:="", y:="", num:=1, arg:="")
{
  local
  static ini:=[], ToolTipOff:=""
  f:= "ToolTip_" . Round(num)
  if (s="")
  {
    ini.Delete(f)
    Gui, %f%: Destroy
    return
  }
  ;-----------------
  r1:=A_CoordModeToolTip
  r2:=A_CoordModeMouse
  CoordMode, Mouse, Screen
  MouseGetPos, x1, y1
  CoordMode, Mouse, %r1%
  MouseGetPos, x2, y2
  CoordMode, Mouse, %r2%
  x:=Round(x="" ? x1+16 : x+x1-x2)
  y:=Round(y="" ? y1+16 : y+y1-y2)
  ;-----------------
  bgcolor:=arg.bgcolor!="" ? arg.bgcolor : "FAFBFC"
  color:=arg.color!="" ? arg.color : "Black"
  font:=arg.font ? arg.font : "Consolas"
  size:=arg.size ? arg.size : "10"
  bold:=arg.bold ? arg.bold : ""
  trans:=arg.trans!="" ? Round(arg.trans & 255) : 255
  timeout:=arg.timeout!="" ? arg.timeout : ""
  ;-----------------
  r:=bgcolor "|" color "|" font "|" size "|" bold "|" trans "|" s
  if (ini[f]!=r)
  {
    ini[f]:=r
    Gui, %f%: Destroy
    Gui, %f%: +AlwaysOnTop -Caption +ToolWindow
      -DPIScale +Hwndid +E0x80020
    Gui, %f%: Margin, 2, 2
    Gui, %f%: Color, %bgcolor%
    Gui, %f%: Font, c%color% s%size% %bold%, %font%
    Gui, %f%: Add, Text,, %s%
    Gui, %f%: Show, Hide, %f%
    ;------------------
    dhw:=A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinSet, Transparent, %trans%, ahk_id %id%
    DetectHiddenWindows, %dhw%
  }
  Gui, %f%: +AlwaysOnTop
  Gui, %f%: Show, NA x%x% y%y%
  if (timeout)
  {
    if (!ToolTipOff)
      ToolTipOff:=this.ToolTip.Bind(this,"")
    SetTimer, %ToolTipOff%, % -Round(Abs(timeout*1000))-1
  }
}

; FindText().ObjView() 查看对象的值用于调试

ObjView(obj, keyname="")
{
  local
  if IsObject(obj)  ; thanks lexikos's type(v)
  {
    s:=""
    For k,v in obj
      s.=this.ObjView(v, keyname "[" (StrLen(k)>1000
      || [k].GetCapacity(1) ? """" k """":k) "]")
  }
  else
    s:=keyname ": " (StrLen(obj)>1000
    || [obj].GetCapacity(1) ? """" obj """":obj) "`n"
  if (keyname!="")
    return s
  ;------------------
  Gui, Gui_DeBug_Gui: Destroy
  Gui, Gui_DeBug_Gui: +AlwaysOnTop +Hwndid
  Gui, Gui_DeBug_Gui: Add, Button, y270 w350 gCancel Default, OK
  Gui, Gui_DeBug_Gui: Add, Edit, xp y10 w350 h250 -Wrap -WantReturn
  GuiControl, Gui_DeBug_Gui:, Edit1, %s%
  Gui, Gui_DeBug_Gui: Show,, Debug view object values
  DetectHiddenWindows, Off
  WinWaitClose, ahk_id %id%
  Gui, Gui_DeBug_Gui: Destroy
}

; 从编译后的程序中获取脚本

GetScript()  ; thanks TAC109
{
  local
  if (!A_IsCompiled)
    return
  For i,ahk in ["#1", ">AUTOHOTKEY SCRIPT<"]
  if (rc:=DllCall("FindResource", "Ptr",0, "Str",ahk, "Ptr",10, "Ptr"))
  && (sz:=DllCall("SizeofResource", "Ptr",0, "Ptr",rc, "Uint"))
  && (pt:=DllCall("LoadResource", "Ptr",0, "Ptr",rc, "Ptr"))
  && (pt:=DllCall("LockResource", "Ptr",pt, "Ptr"))
  && (DllCall("VirtualProtect", "Ptr",pt, "Ptr",sz, "UInt",0x4, "UInt*",0))
  && (InStr(StrGet(pt, 20, "utf-8"), "<COMPILER"))
    return this.FormatScript(StrGet(pt, sz, "utf-8"))
}

FormatScript(s, space:="", tab:="    ")
{
  local
  VarSetCapacity(ss, StrLen(s)*2), n:=0, w:=StrLen(tab)
  , space2:=StrReplace(Format("{:020d}",0), "0", tab)
  Loop Parse, s, `n, `r
  {
    v:=Trim(A_LoopField), n2:=n
    if RegExMatch(v, "O)^(\s*\{)+|(\{\s*)+$", r)
      n+=w*StrLen(RegExReplace(r[0], "\s"))
    else if RegExMatch(v, "O)^(\s*\})+", r)
      n-=w*StrLen(RegExReplace(r[0], "\s")), n2:=n
    ss.=Space . SubStr(space2,1,n2) . v . "`r`n"
  }
  return SubStr(ss,1,-2)
}


;==== Optional GUI interface ====


Gui(cmd, arg1:="")
{
  local
  static
  local bch, cri
  static init:=0
  if (!init)
  {
    init:=1
    Gui_ := this.Gui.Bind(this)
    Gui_G := this.Gui.Bind(this, "G")
    Gui_Run := this.Gui.Bind(this, "Run")
    Gui_Off := this.Gui.Bind(this, "Off")
    Gui_Show := this.Gui.Bind(this, "Show")
    Gui_KeyDown := this.Gui.Bind(this, "KeyDown")
    Gui_LButtonDown := this.Gui.Bind(this, "LButtonDown")
    Gui_MouseMove := this.Gui.Bind(this, "MouseMove")
    Gui_ScreenShot := this.Gui.Bind(this, "ScreenShot")
    Gui_ShowPic := this.Gui.Bind(this, "ShowPic")
    Gui_Slider := this.Gui.Bind(this, "Slider")
    Gui_ToolTip := this.Gui.Bind(this, "ToolTip")
    Gui_ToolTipOff := this.Gui.Bind(this, "ToolTipOff")
    Gui_SaveScr := this.Gui.Bind(this, "SaveScr")
    bch:=A_BatchLines, cri:=A_IsCritical
    Critical
    #NoEnv
    %Gui_%("Load_Language_Text")
    %Gui_%("MakeCaptureWindow")
    %Gui_%("MakeMainWindow")
    OnMessage(0x100, Gui_KeyDown)
    OnMessage(0x201, Gui_LButtonDown)
    OnMessage(0x200, Gui_MouseMove)
    Menu, Tray, Add
    Menu, Tray, Add, % Lang["s1"], %Gui_Show%
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    {
      Menu, Tray, Default, % Lang["s1"]
      Menu, Tray, Click, 1
      Menu, Tray, Icon, Shell32.dll, 23
    }
    Critical, %cri%
    SetBatchLines, %bch%
  }
  Switch cmd
  {
  Case "Off":
    return hk:=SubStr(A_ThisHotkey,2)
  Case "G":
    GuiControl, +g, %id%, %Gui_Run%
    return
  Case "Run":
    Critical
    %Gui_%(A_GuiControl)
    return
  Case "Show":
    Gui, FindText_Main: Default
    Gui, Show, Center
    GuiControl, Focus, scr
    return
  Case "MakeCaptureWindow":
    WindowColor:="0xDDEEFF"
    Gui, FindText_Capture: New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12, Verdana
    Gui, -Theme
    ww:=35, hh:=12, nW:=71, nH:=25, w:=11, C_:=[], Cid_:=[]
    Loop % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "" : Mod(i,nW)=1 ? "xm y+1":"x+1"
      Gui, Add, Progress, w%w% h%w% %j% Hwndid
      Control, ExStyle, -0x20000,, ahk_id %id%
      C_[i]:=id, Cid_[id]:=i
    }
    Gui, +Theme
    GuiControlGet, p, Pos, %id%
    w:=pX+pW-15, h:=pY+pH-15
    Gui, Add, Slider, xm w%w% vMySlider1 Hwndid Disabled
      +Center Page20 Line10 NoTicks AltSubmit
    %Gui_G%()
    Gui, Add, Slider, ym h%h% vMySlider2 Hwndid Disabled
      +Center Page20 Line10 NoTicks AltSubmit +Vertical
    %Gui_G%()
    GuiControlGet, p, Pos, %id%
    k:=pX+pW, MySlider1:=MySlider2:=dx:=dy:=0
    ;--------------
    Gui, Add, Button, xm Hwndid Hidden Section, % Lang["Auto"]
    GuiControlGet, p, Pos, %id%
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    Gui, Add, Button, xm+%i% yp w%w% hp -Wrap vRepU Hwndid, % Lang["RepU"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutU Hwndid, % Lang["CutU"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutU3 Hwndid, % Lang["CutU3"]
    %Gui_G%()
    Gui, Add, Button, xm wp hp -Wrap vRepL Hwndid, % Lang["RepL"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutL Hwndid, % Lang["CutL"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutL3 Hwndid, % Lang["CutL3"]
    %Gui_G%()
    Gui, Add, Button, x+15 w%pW% hp -Wrap vAuto Hwndid, % Lang["Auto"]
    %Gui_G%()
    Gui, Add, Button, x+15 w%w% hp -Wrap vRepR Hwndid, % Lang["RepR"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutR Hwndid, % Lang["CutR"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutR3 Hwndid, % Lang["CutR3"]
    %Gui_G%()
    Gui, Add, Button, xm+%i% wp hp -Wrap vRepD Hwndid, % Lang["RepD"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutD Hwndid, % Lang["CutD"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp hp -Wrap vCutD3 Hwndid, % Lang["CutD3"]
    %Gui_G%()
    ;--------------
    Gui, Add, Text, x+60 ys+3 Section, % Lang["SelGray"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelGray ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelColor"]
    Gui, Add, Edit, x+3 yp-3 w150 vSelColor ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelR"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelR ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelG"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelG ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelB"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelB ReadOnly
    ;--------------
    x:=w*6+pW+15*4
    Gui, Add, Tab3, x%x% y+15 -Wrap, % Lang["s2"]
    Gui, Tab, 1
    Gui, Add, Text, x+15 y+15, % Lang["Threshold"]
    Gui, Add, Edit, x+15 w100 vThreshold
    Gui, Add, Button, x+15 yp-3 vGray2Two Hwndid, % Lang["Gray2Two"]
    %Gui_G%()
    Gui, Tab, 2
    Gui, Add, Text, x+15 y+15, % Lang["GrayDiff"]
    Gui, Add, Edit, x+15 w100 vGrayDiff, 50
    Gui, Add, Button, x+15 yp-3 vGrayDiff2Two Hwndid, % Lang["GrayDiff2Two"]
    %Gui_G%()
    Gui, Tab, 3
    Gui, Add, Text, x+15 y+15, % Lang["Similar1"] " 0"
    Gui, Add, Slider, x+0 w120 vSimilar1 Hwndid
      +Center Page1 NoTicks ToolTip, 100
    %Gui_G%()
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColor2Two Hwndid, % Lang["Color2Two"]
    %Gui_G%()
    Gui, Tab, 4
    Gui, Add, Text, x+15 y+15, % Lang["Similar2"] " 0"
    Gui, Add, Slider, x+0 w120 vSimilar2 Hwndid
      +Center Page1 NoTicks ToolTip, 100
    %Gui_G%()
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColorPos2Two Hwndid, % Lang["ColorPos2Two"]
    %Gui_G%()
    Gui, Tab, 5
    Gui, Add, Text, x+10 y+15, % Lang["DiffR"]
    Gui, Add, Edit, x+5 w80 vDiffR Limit3
    Gui, Add, UpDown, vdR Range0-255 Wrap
    Gui, Add, Text, x+5, % Lang["DiffG"]
    Gui, Add, Edit, x+5 w80 vDiffG Limit3
    Gui, Add, UpDown, vdG Range0-255 Wrap
    Gui, Add, Text, x+5, % Lang["DiffB"]
    Gui, Add, Edit, x+5 w80 vDiffB Limit3
    Gui, Add, UpDown, vdB Range0-255 Wrap
    Gui, Add, Button, x+15 yp-3 vColorDiff2Two Hwndid, % Lang["ColorDiff2Two"]
    %Gui_G%()
    Gui, Tab, 6
    Gui, Add, Text, x+10 y+15, % Lang["DiffRGB"]
    Gui, Add, Edit, x+5 w80 vDiffRGB Limit3
    Gui, Add, UpDown, vdRGB Range0-255 Wrap
    Gui, Add, Checkbox, x+15 yp+5 vMultiColor Hwndid, % Lang["MultiColor"]
    %Gui_G%()
    Gui, Add, Button, x+15 yp-5 vUndo Hwndid, % Lang["Undo"]
    %Gui_G%()
    Gui, Tab
    ;--------------
    Gui, Add, Button, xm vReset Hwndid, % Lang["Reset"]
    %Gui_G%()
    Gui, Add, Checkbox, x+15 yp+5 vModify Hwndid, % Lang["Modify"]
    %Gui_G%()
    Gui, Add, Text, x+30, % Lang["Comment"]
    Gui, Add, Edit, x+5 yp-2 w150 vComment
    Gui, Add, Button, x+10 yp-3 vSplitAdd Hwndid, % Lang["SplitAdd"]
    %Gui_G%()
    Gui, Add, Button, x+10 vAllAdd Hwndid, % Lang["AllAdd"]
    %Gui_G%()
    Gui, Add, Button, x+10 wp vOK Hwndid, % Lang["OK"]
    %Gui_G%()
    Gui, Add, Button, x+10 wp vCancel gCancel, % Lang["Cancel"]
    Gui, Add, Button, xm vBind0 Hwndid, % Lang["Bind0"]
    %Gui_G%()
    Gui, Add, Button, x+10 vBind1 Hwndid, % Lang["Bind1"]
    %Gui_G%()
    Gui, Add, Button, x+10 vBind2 Hwndid, % Lang["Bind2"]
    %Gui_G%()
    Gui, Add, Button, x+10 vBind3 Hwndid, % Lang["Bind3"]
    %Gui_G%()
    Gui, Add, Button, x+10 vBind4 Hwndid, % Lang["Bind4"]
    %Gui_G%()
    Gui, Add, Button, x+30 vSave Hwndid, % Lang["Save"]
    %Gui_G%()
    Gui, Show, Hide, % Lang["s3"]
    return
  Case "MakeMainWindow":
    Gui, FindText_Main: New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 10
    Gui, Color, %WindowColor%
    Gui, Font, s12, Verdana
    Gui, Add, Text, xm, % Lang["NowHotkey"]
    Gui, Add, Edit, x+5 w200 vNowHotkey ReadOnly
    Gui, Add, Hotkey, x+5 w200 vSetHotkey1
    Gui, Add, DDL, x+5 w180 vSetHotkey2
      , % "||F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|LWin|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    Gui, Add, GroupBox, xm y+0 w280 h55 vMyGroup cBlack
    Gui, Add, Text, xp+15 yp+20 Section, % Lang["Myww"] ": "
    Gui, Add, Text, x+0 w80, %ww%
    Gui, Add, UpDown, vMyww Range1-100, %ww%
    Gui, Add, Text, x+15 ys, % Lang["Myhh"] ": "
    Gui, Add, Text, x+0 w80, %hh%
    Gui, Add, UpDown, vMyhh Hwndid Range1-100, %hh%
    GuiControlGet, p, Pos, %id%
    GuiControl, Move, MyGroup, % "w" (pX+pW) " h" (pH+30)
    x:=pX+pW+15*2
    Gui, Add, Button, x%x% ys-5 vApply Hwndid, % Lang["Apply"]
    %Gui_G%()
    Gui, Add, Checkbox, x+30 ys vAddFunc Hwndid, % Lang["AddFunc"] " FindText()"
    GuiControlGet, p, Pos, %id%
    pW:=pX+pW-15, pW:=(pW<720?720:pW), w:=pW//5
    Gui, Add, Button, xm y+18 w%w% vCutL2 Hwndid, % Lang["CutL2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutR2 Hwndid, % Lang["CutR2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutU2 Hwndid, % Lang["CutU2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCutD2 Hwndid, % Lang["CutD2"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vUpdate Hwndid, % Lang["Update"]
    %Gui_G%()
    Gui, Font, s6 bold, Verdana
    Gui, Add, Edit, xm y+10 w%pW% h260 vMyPic -Wrap
    Gui, Font, s12 norm, Verdana
    w:=pW//3
    Gui, Add, Button, xm w%w% vCapture Hwndid, % Lang["Capture"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vTest Hwndid, % Lang["Test"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vCopy Hwndid, % Lang["Copy"]
    %Gui_G%()
    Gui, Add, Button, xm y+0 wp vCaptureS Hwndid, % Lang["CaptureS"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vGetRange Hwndid, % Lang["GetRange"]
    %Gui_G%()
    Gui, Add, Button, x+0 wp vGetOffset Hwndid, % Lang["GetOffset"]
    %Gui_G%()
    Gui, Add, Edit, xm y+10 w130 hp vClipText
    Gui, Add, Button, x+0 vPaste Hwndid, % Lang["Paste"]
    %Gui_G%()
    Gui, Add, Button, x+0 vTestClip Hwndid, % Lang["TestClip"]
    %Gui_G%()
    Gui, Add, Button, x+0 vGetClipOffset Hwndid, % Lang["GetClipOffset"]
    %Gui_G%()
    r:=pW
    GuiControlGet, p, Pos, %id%
    w:=((r+15)-(pX+pW))//2, pW:=r
    Gui, Add, Edit, x+0 w%w% hp vOffset
    Gui, Add, Button, x+0 wp vCopyOffset Hwndid, % Lang["CopyOffset"]
    %Gui_G%()
    Gui, Font, cBlue
    Gui, Add, Edit, xm w%pW% h250 vscr Hwndhscr -Wrap HScroll
    Gui, Show, Hide, % Lang["s4"]
    %Gui_%("LoadScr")
    OnExit(Gui_SaveScr)
    return
  Case "LoadScr":
    f:=A_Temp "\~scr1.tmp"
    FileRead, s, %f%
    GuiControl, FindText_Main:, scr, %s%
    return
  Case "SaveScr":
    f:=A_Temp "\~scr1.tmp"
    GuiControlGet, s, FindText_Main:, scr
    FileDelete, %f%
    FileAppend, %s%, %f%
    return
  Case "Capture","CaptureS":
    Gui, FindText_Main: +Hwndid
    if (show_gui:=(WinExist()=id))
    {
      WinMinimize
      Gui, FindText_Main: Hide
    }
    ShowScreenShot:=InStr(cmd,"CaptureS")
    if (ShowScreenShot)
    {
      this.ScreenShot(), f:=%Gui_%("SelectPic")
      if (f="") or !FileExist(f)
      {
        if (show_gui)
        {
          Gui, FindText_Main: Show
          GuiControl, FindText_Main: Focus, scr
        }
        Exit
      }
      this.ShowPic(f)
    }
    ;----------------------
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    For k,v in StrSplit("RButton|Up|Down|Left|Right","|")
    {
      if GetKeyState(v)
        Send {%v% Up}
      Hotkey, *%v%, %Gui_Off%, On UseErrorLevel
    }
    CoordMode, Mouse
    GuiControlGet, w, FindText_Main:, Myww
    GuiControlGet, h, FindText_Main:, Myhh
    oldx:=oldy:="", r:=StrSplit(Lang["s5"],"|")
    if (!show_gui)
      w:=20, h:=8
    Critical, Off
    hk:="", State:=%Gui_%("State")
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y, Bind_ID
      if GetKeyState("Up","P") || (hk="Up")
        (h>1 && h--), hk:=""
      else if GetKeyState("Down","P") || (hk="Down")
        h++, hk:=""
      else if GetKeyState("Left","P") || (hk="Left")
        (w>1 && w--), hk:=""
      else if GetKeyState("Right","P") || (hk="Right")
        w++, hk:=""
      this.RangeTip(x-w,y-h,2*w+1,2*h+1,(A_MSec<500?"Red":"Blue"))
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, % r[1] " : " x "," y "`n" r[2]
    }
    Until (hk="RButton") or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    hk:="", px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      if GetKeyState("Up","P") || (hk="Up")
        (h>1 && h--), hk:=""
      else if GetKeyState("Down","P") || (hk="Down")
        h++, hk:=""
      else if GetKeyState("Left","P") || (hk="Left")
        (w>1 && w--), hk:=""
      else if GetKeyState("Right","P") || (hk="Right")
        w++, hk:=""
      this.RangeTip(x-w,y-h,2*w+1,2*h+1,(A_MSec<500?"Red":"Blue"))
      MouseGetPos, x1, y1
      if (oldx=x1 and oldy=y1)
        Continue
      oldx:=x1, oldy:=y1
      ToolTip, % r[1] " : " x "," y "`n" r[2]
    }
    Until (hk="RButton") or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    ToolTip
    Critical
    this.RangeTip()
    For k,v in StrSplit("RButton|Up|Down|Left|Right","|")
      Hotkey, *%v%, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    if (ShowScreenShot)
      this.ShowPic()
    if (!show_gui)
      return [px-w, py-h, px+w, py+h]
    ;-----------------------
    nW:=71, nH:=25, dx:=dy:=0, c:=WindowColor
    c:=((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
    Loop % nW*(nH+1)
      SendMessage, 0x2001, 0, (A_Index>nW*nH ? 0xAAFFFF:c)
        ,, % "ahk_id " C_[A_Index]
    ww:=w, hh:=h, nW:=2*ww+1, nH:=2*hh+1
    i:=nW>71, j:=nH>25
    Gui, FindText_Capture: Default
    GuiControl, Enable%i%, MySlider1
    GuiControl, Enable%j%, MySlider2
    GuiControl,, MySlider1, % MySlider1:=0
    GuiControl,, MySlider2, % MySlider2:=0
    ;------------------------
    %Gui_%("getcors", !ShowScreenShot)
    %Gui_%("Reset")
    Loop 6
      GuiControl,, Edit%A_Index%
    GuiControl,, Modify, % Modify:=0
    GuiControl,, MultiColor, % MultiColor:=0
    GuiControl,, GrayDiff, 50
    GuiControl, Focus, Gray2Two
    GuiControl, +Default, Gray2Two
    Gui, Show, Center
    Event:=Result:=""
    DetectHiddenWindows, Off
    Critical, Off
    Gui, +LastFound
    WinWaitClose, % "ahk_id " WinExist()
    Critical
    ToolTip
    Gui, FindText_Main: Default
    ;--------------------------------
    if (cors.bind!="")
    {
      WinGetTitle, tt, ahk_id %Bind_ID%
      WinGetClass, tc, ahk_id %Bind_ID%
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
      Result:="`nSetTitleMatchMode, 2`nid:=WinExist(""" tt """)"
        . "`nFindText().BindWindow(id" (cors.bind=0 ? "":"," cors.bind)
        . ")  `; " Lang["s6"] " this.BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      if (!A_IsCompiled)
        FileRead, s, %A_LineFile%
      else
        s:=this.GetScript()
      RegExMatch(s,"Oi)FindText[^\n]+args\*[\s\S]*?r\[3]\s*return[\s}]+",r)
      GuiControl,, scr, % Result "`n`n;==========`n`n`n" r[0] "`n"
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(this.ASCII(Result),"`n")
      Result:=s:=""
    }
    else if (Event="SplitAdd") or (Event="AllAdd")
    {
      GuiControlGet, s,, scr
      r:=SubStr(s, 1, InStr(s,"=FindText("))
      i:=j:=0, re:="<[^>\n]*>[^$\n]+\$[^""\r\n]+"
      While j:=RegExMatch(r, re,, j+1)
        i:=InStr(r,"`n",0,j)
      GuiControl,, scr, % SubStr(s,1,i) . Result . SubStr(s,i+1)
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(this.ASCII(Result),"`n")
      Result:=s:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "State":
    return GetKeyState((arg1?"LButton":"RButton"),"P")
      . "|" GetKeyState((arg1?"LButton":"RButton"))
      . "|" GetKeyState("Ctrl","P")
      . "|" GetKeyState("Ctrl")
  Case "SelectPic":
    Gui, FindText_SelectPic: +LastFoundExist
    IfWinExist
      return
    Pics:=[], Names:=[], s:=""
    Loop Files, % A_Temp "\Ahk_ScreenShot\*.bmp"
      Pics.Push(LoadPicture(v:=A_LoopFileFullPath))
      , Names.Push(v), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    Gui, FindText_SelectPic: New
    Gui, +LastFound +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Font, s12, Verdana
    Gui, Add, Pic, HwndhPic w800 h500 +Border
    Gui, Add, ListBox, % "x+15 w120 hp vSelectBox Hwndid"
      . " AltSubmit 0x100 Choose1", % Trim(s,"|")
    %Gui_G%()
    Gui, Add, Button, xm w170 vOK2 Hwndid Default, % Lang["OK2"]
    %Gui_G%()
    Gui, Add, Button, x+15 wp vCancel2 gCancel, % Lang["Cancel2"]
    Gui, Add, Button, x+15 wp vClearAll Hwndid, % Lang["ClearAll"]
    %Gui_G%()
    Gui, Add, Button, x+15 wp vOpenDir Hwndid, % Lang["OpenDir"]
    %Gui_G%()
    Gui, Add, Button, x+15 wp vSavePic Hwndid, % Lang["SavePic"]
    %Gui_G%()
    GuiControl, Focus, SelectBox
    %Gui_%("SelectBox")
    Gui, Show,, Select ScreenShot
    ;-----------------------
    DetectHiddenWindows, Off
    Critical, Off
    file:=""
    WinWaitClose, % "ahk_id " WinExist()
    Critical
    Gui, Destroy
    Loop % Pics.Length()
      DllCall("DeleteObject", "Ptr",Pics[A_Index])
    Pics:="", Names:=""
    return file
  Case "SavePic":
    GuiControlGet, SelectBox
    f:=Names[SelectBox]
    Gui, Destroy
    Loop % Pics.Length()
      DllCall("DeleteObject", "Ptr",Pics[A_Index])
    Pics:="", Names:="", show_gui_bak:=show_gui
    this.ShowPic(f)
    Gui, FindText_Screen: +OwnDialogs
    Loop
    {
      pos:=%Gui_%("GetRange")
      MsgBox, 4100, Tip, % Lang["s15"] " !"
      IfMsgBox, Yes
        Break
    }
    %Gui_%("ScreenShot", pos[1] "|" pos[2] "|" pos[3] "|" pos[4] "|0")
    this.ShowPic()
    if (show_gui_bak)
    {
      GuiControl, FindText_Main: Focus, scr
      Gui, FindText_Main: Show
    }
    Exit
  Case "SelectBox":
    GuiControlGet, SelectBox
    if (hBM:=Pics[SelectBox])
    {
      this.GetBitmapWH(hBM, w, h)
      GuiControl,, %hPic%, % "*W" (w<800?0:800)
        . " *H" (h<500?0:500) " HBITMAP:*" hBM
    }
    return
  Case "OK2":
    GuiControlGet, SelectBox
    file:=Names[SelectBox]
    Gui, Hide
    return
  Case "ClearAll":
    FileDelete, % A_Temp "\Ahk_ScreenShot\*.bmp"
    Gui, Hide
    return
  Case "OpenDir":
    Run, % A_Temp "\Ahk_ScreenShot\"
    return
  Case "getcors":
    this.xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
    if (w<1 or h<1)
      return
    SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
    if (arg1)
      this.ScreenShot()
    cors:=[], gray:=[], k:=0
    Loop %nH%
    {
      j:=py-hh+A_Index-1, i:=px-ww
      Loop %nW%
        cors[++k]:=c:=this.GetColor(i++,j,0)
        , gray[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    }
    cors.CutLeft:=Abs(px-ww-x)
    cors.CutRight:=Abs(px+ww-(x+w-1))
    cors.CutUp:=Abs(py-hh-y)
    cors.CutDown:=Abs(py+hh-(y+h-1))
    SetBatchLines, %bch%
    return
  Case "GetRange":
    Gui, FindText_Main: +Hwndid
    if (show_gui:=(WinExist()=id))
      Gui, FindText_Main: Hide
    ;---------------------
    Gui, FindText_GetRange: New
    Gui, +LastFound +AlWaysOnTop +ToolWindow -Caption -DPIScale +E0x08000000
    Gui, Color, White
    WinSet, Transparent, 10
    this.xywh2xywh(0,0,0,0,0,0,0,0,x,y,w,h)
    Gui, Show, NA x%x% y%y% w%w% h%h%, GetRange
    ;---------------------
    if GetKeyState("LButton")
      Send {LButton Up}
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    hk:="", State:=%Gui_%("State",1)
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *LButton, %Gui_Off%, On UseErrorLevel
    Hotkey, *LButton Up, %Gui_Off%, On UseErrorLevel
    CoordMode, Mouse
    oldx:=oldy:="", r:=Lang["s7"]
    Critical, Off
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, %r%
    }
    Until (hk!="") or (State!=%Gui_%("State",1))
    hk:="", State:=%Gui_%("State",1)
    x1:=x, y1:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x2, y2
      x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x1-x2), h:=Abs(y1-y2)
      this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
      if (oldx=x2 and oldy=y2)
        Continue
      oldx:=x2, oldy:=y2
      ToolTip, %r%
    }
    Until (hk!="") or (State!=%Gui_%("State",1))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State=%Gui_%("State",1))
      Sleep, 50
    ToolTip
    Critical
    this.RangeTip()
    Hotkey, *LButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, *LButton Up, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    Gui, FindText_GetRange: Destroy
    Clipboard:=p:=x ", " y ", " (x+w-1) ", " (y+h-1)
    if (!show_gui)
      return StrSplit(p, ",", " ")
    ;---------------------
    Gui, FindText_Main: Default
    GuiControlGet, s,, scr
    re:="Oi)(=FindText\([^\n]*?)([^,\n]*,){4}"
      . "([^,\n]*,[^,\n]*,[^,\n]*Text)"
    if RegExMatch(s, re, r)
    {
      s:=StrReplace(s, r[0], r[1] " " p "," r[3], 0, 1)
      GuiControl,, scr, %s%
    }
    Gui, Show
    return
  Case "Test","TestClip":
    Gui, FindText_Main: Default
    Gui, +LastFound
    WinMinimize
    Gui, Hide
    DetectHiddenWindows, Off
    WinWaitClose, % "ahk_id " WinExist()
    Sleep, 100
    ;----------------------
    if (cmd="Test")
      GuiControlGet, s,, scr
    else
      GuiControlGet, s,, ClipText
    if (cmd="Test") and InStr(s,"MCode(")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n" s "`nExitApp`n"
      Thread:= new this.Thread(s)
      DetectHiddenWindows, On
      WinWait, % "ahk_class AutoHotkey ahk_pid " Thread.pid,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
      ; Thread:=""  ; kill the Thread
    }
    else
    {
      Gui, +OwnDialogs
      t:=A_TickCount, n:=150000, X:=Y:=""
      , RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
      , v:=this.FindText(X, Y, -n, -n, n, n, 0, 0, r[0])
      r:=StrSplit(Lang["s8"],"|")
      MsgBox, 4096, Tip, % r[1] ":`t" Round(v.Length()) "`n`n"
        . r[2] ":`t" (A_TickCount-t) " " r[3] "`n`n"
        . r[4] ":`t" X ", " Y "`n`n"
        . r[5] ":`t<" (Comment:=v[1].id) ">", 3
      for i,j in v
        if (i<=2)
          this.MouseTip(j.x, j.y)
      v:="", Clipboard:=X "," Y
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "GetOffset","GetClipOffset":
    Gui, FindText_Main: Hide
    Gui, FindText_Capture: +LastFound
    %Gui_%("Capture")
    Gui, FindText_Main: Default
    if (cmd="GetOffset")
      GuiControlGet, s,, scr
    else
      GuiControlGet, s,, ClipText
    RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    n:=150000, v:=this.FindText(X, Y, -n, -n, n, n, 0, 0, r[0])
    r:=StrReplace("X+" (px-X) ", Y+" (py-Y), "+-", "-")
    if (cmd="GetOffset")
    {
      s:=RegExReplace(s, "i)(\.Click\()[^,\n""]*,[^,)\n]*"
        , "$1" r, 0, 1)
      GuiControl,, scr, %s%
    }
    else
      GuiControl,, Offset, % v ? r:""
    Gui, Show
    GuiControl, Focus, scr
    s:=v:=""
    return
  Case "Paste":
    if RegExMatch(Clipboard, "O)\|?<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    {
      GuiControl,, ClipText, % r[0]
      GuiControl,, MyPic, % Trim(this.ASCII(r[0]),"`n")
    }
    return
  Case "CopyOffset":
    GuiControlGet, s,, Offset
    Clipboard:=s
    return
  Case "Copy":
    Gui, FindText_Main: Default
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      GuiControlGet, s,, scr
      GuiControlGet, r,, AddFunc
      if (r != 1)
        s:=RegExReplace(s,"i)FindText[^\n]+args\*[\s\S]*")
        , s:=RegExReplace(s, "i)\n; ok:=FindText[\s\S]*")
        , s:=SubStr(s, (s~="i)\n[ \t]*Text"))
    }
    Clipboard:=RegExReplace(s,"\R","`r`n")
    GuiControl, Focus, scr
    return
  Case "Apply":
    Gui, FindText_Main: Default
    GuiControlGet, NowHotkey
    GuiControlGet, SetHotkey1
    GuiControlGet, SetHotkey2
    if (NowHotkey!="")
      Hotkey, *%NowHotkey%,, Off UseErrorLevel
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Hotkey, *%k%, %Gui_ScreenShot%, On UseErrorLevel
    GuiControl,, NowHotkey, %k%
    GuiControl,, SetHotkey1
    GuiControl, Choose, SetHotkey2, 0
    return
  Case "ScreenShot":
    Critical
    f:=A_Temp "\Ahk_ScreenShot"
    if !InStr(r:=FileExist(f), "D")
    {
      if (r)
      {
        FileSetAttrib, -R, %f%
        FileDelete, %f%
      }
      FileCreateDir, %f%
    }
    Loop
      f:=A_Temp "\Ahk_ScreenShot\" Format("{:03d}",A_Index) ".bmp"
    Until !FileExist(f)
    this.SavePic(f, StrSplit(arg1,"|")*)
    Gui, FindText_Tip: New
    ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
    Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000020
    Gui, Color, Yellow
    Gui, Font, cRed s48 bold
    Gui, Add, Text,, % Lang["s9"]
    WinSet, Transparent, 200
    Gui, Show, NA y0, ScreenShot Tip
    Sleep, 100
    Gui, Destroy
    return
  Case "Bind0","Bind1","Bind2","Bind3","Bind4":
    this.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,5))
    if GetKeyState("RButton")
      Send {RButton Up}
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    hk:="", State:=%Gui_%("State")
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *RButton, %Gui_Off%, On UseErrorLevel
    CoordMode, Mouse
    oldx:=oldy:=""
    Critical, Off
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ;---------------
      px:=x, py:=y, %Gui_%("getcors",1)
      %Gui_%("Reset"), r:=StrSplit(Lang["s10"],"|")
      ToolTip, % r[1] " : " x "," y "`n" r[2]
    }
    Until (hk!="") or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    ToolTip
    Critical
    Hotkey, *RButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    this.BindWindow(0), cors.bind:=bind_mode
    return
  Case "MySlider1","MySlider2":
    SetTimer, %Gui_Slider%, -10
    return
  Case "Slider":
    Critical
    dx:=nW>71 ? Round((nW-71)*MySlider1/100) : 0
    dy:=nH>25 ? Round((nH-25)*MySlider2/100) : 0
    if (oldx=dx and oldy=dy)
      return
    oldy:=dy, k:=0
    Loop % nW*nH
      c:=(!show[++k] ? WindowColor
      : bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), %Gui_%("SetColor")
    Loop % nW*(oldx!=dx)
    {
      i:=A_Index-dx
      if (i>=1 && i<=71)
      {
        c:=show[nW*nH+A_Index] ? 0x0000FF : 0xAAFFFF
        SendMessage, 0x2001, 0, c,, % "ahk_id " C_[71*25+i]
      }
    }
    oldx:=dx
    return
  Case "Reset":
    show:=[], ascii:=[], bg:=color:=""
    CutLeft:=CutRight:=CutUp:=CutDown:=k:=0
    Loop % nW*nH
      show[++k]:=1, c:=cors[k], %Gui_%("SetColor")
    Loop % cors.CutLeft
      %Gui_%("CutL")
    Loop % cors.CutRight
      %Gui_%("CutR")
    Loop % cors.CutUp
      %Gui_%("CutU")
    Loop % cors.CutDown
      %Gui_%("CutD")
    return
  Case "SetColor":
    if (nW=71 && nH=25)
      tk:=k
    else
    {
      tx:=Mod(k-1,nW)-dx, ty:=(k-1)//nW-dy
      if (tx<0 || tx>=71 || ty<0 || ty>=25)
        return
      tk:=ty*71+tx+1
    }
    c:=c="Black" ? 0x000000 : c="White" ? 0xFFFFFF
      : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
    SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[tk]
    return
  Case "RepColor":
    show[k]:=1, c:=(bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), %Gui_%("SetColor")
    return
  Case "CutColor":
    show[k]:=0, c:=WindowColor, %Gui_%("SetColor")
    return
  Case "RepL":
    if (CutLeft<=cors.CutLeft)
    or (bg!="" and InStr(color,"**")
    and CutLeft=cors.CutLeft+1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutL3":
    Loop 3
      %Gui_%("CutL")
    return
  Case "RepR":
    if (CutRight<=cors.CutRight)
    or (bg!="" and InStr(color,"**")
    and CutRight=cors.CutRight+1)
      return
    k:=1-CutRight, CutRight--
    Loop %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutR3":
    Loop 3
      %Gui_%("CutR")
    return
  Case "RepU":
    if (CutUp<=cors.CutUp)
    or (bg!="" and InStr(color,"**")
    and CutUp=cors.CutUp+1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutU3":
    Loop 3
      %Gui_%("CutU")
    return
  Case "RepD":
    if (CutDown<=cors.CutDown)
    or (bg!="" and InStr(color,"**")
    and CutDown=cors.CutDown+1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutD3":
    Loop 3
      %Gui_%("CutD")
    return
  Case "Gray2Two":
    Gui, FindText_Capture: Default
    GuiControl, Focus, Threshold
    GuiControlGet, Threshold
    if (Threshold="")
    {
      pp:=[]
      Loop 256
        pp[A_Index-1]:=0
      Loop % nW*nH
        if (show[A_Index])
          pp[gray[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      GuiControl,, Threshold, %Threshold%
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop % nW*nH
    {
      ascii[++k]:=v:=(gray[k]<=Threshold)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "GrayDiff2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, GrayDiff
    if (GrayDiff="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % Lang["s11"] " !", 1
      return
    }
    if (CutLeft=cors.CutLeft)
      %Gui_%("CutL")
    if (CutRight=cors.CutRight)
      %Gui_%("CutR")
    if (CutUp=cors.CutUp)
      %Gui_%("CutU")
    if (CutDown=cors.CutDown)
      %Gui_%("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop % nW*nH
    {
      j:=gray[++k]+GrayDiff
      , ascii[k]:=v:=( gray[k-1]>j or gray[k+1]>j
      or gray[k-nW]>j or gray[k+nW]>j
      or gray[k-nW-1]>j or gray[k-nW+1]>j
      or gray[k+nW-1]>j or gray[k+nW+1]>j )
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "Color2Two","ColorPos2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % Lang["s12"] " !", 1
      return
    }
    UsePos:=(cmd="ColorPos2Two") ? 1:0
    GuiControlGet, n,, Similar1
    n:=Round(n/100,2), color:=c "@" n
    , n:=Floor(512*9*255*255*(1-n)*(1-n)), k:=i:=0
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    Loop % nW*nH
    {
      c:=cors[++k], r:=((c>>16)&0xFF)-rr
      , g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb, j:=r+rr+rr
      , ascii[k]:=v:=((1024+j)*r*r+2048*g*g+(1534-j)*b*b<=n)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "ColorDiff2Two":
    Gui, FindText_Capture: Default
    GuiControlGet, c,, SelColor
    if (c="")
    {
      Gui, +OwnDialogs
      MsgBox, 4096, Tip, % Lang["s12"] " !", 1
      return
    }
    GuiControlGet, dR
    GuiControlGet, dG
    GuiControlGet, dB
    rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
    , color:=StrReplace(c "-" n,"0x"), k:=i:=0
    Loop % nW*nH
    {
      c:=cors[++k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF
      , b:=c&0xFF, ascii[k]:=v:=(Abs(r-rr)<=dR
      and Abs(g-gg)<=dG and Abs(b-bb)<=dB)
      if (show[k])
        i:=(v?i+1:i-1), c:=(v?"Black":"White"), %Gui_%("SetColor")
    }
    bg:=i>0 ? "1":"0"
    return
  Case "Modify":
    GuiControlGet, Modify
    return
  Case "MultiColor":
    GuiControlGet, MultiColor
    Result:=""
    ToolTip
    return
  Case "Undo":
    Result:=RegExReplace(Result,",[^/]+/[^/]+/[^/]+$")
    ToolTip, % Trim(Result,"/,")
    return
  Case "Similar1":
    GuiControl,, Similar2, %Similar1%
    return
  Case "Similar2":
    GuiControl,, Similar1, %Similar2%
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    k:=0
    Loop %nH%
    {
      v:=""
      Loop %nW%
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    return
  Case "Auto":
    %Gui_%("GetTxt")
    if (txt="")
    {
      Gui, FindText_Capture: +OwnDialogs
      MsgBox, 4096, Tip, % Lang["s13"] " !", 1
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt,"^" bg "+\n"), %Gui_%("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt,"m`n)" bg "$"), %Gui_%("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt,"\n\K" bg "+\n$"), %Gui_%("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt,"m`n)^" bg), %Gui_%("CutL")
      else Break
    }
    txt:=""
    return
  Case "OK","SplitAdd","AllAdd":
    Gui, FindText_Capture: Default
    Gui, +OwnDialogs
    %Gui_%("GetTxt")
    if (txt="") and (!MultiColor)
    {
      MsgBox, 4096, Tip, % Lang["s13"] " !", 1
      return
    }
    if InStr(color,"@") and (UsePos) and (!MultiColor)
    {
      r:=StrSplit(color,"@")
      k:=i:=j:=0
      Loop % nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=cors.SelPos)
        {
          j:=i
          Break
        }
      }
      if (j=0)
      {
        MsgBox, 4096, Tip, % Lang["s12"] " !", 1
        return
      }
      color:="#" j "@" r[2]
    }
    GuiControlGet, Comment
    if (cmd="SplitAdd") and (!MultiColor)
    {
      if InStr(color,"#")
      {
        MsgBox, 4096, Tip, % Lang["s14"], 3
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop % w:=nW-CutLeft-CutRight
      {
        i++
        if (!show[k++] and A_Index<w)
          Continue
        i:=Format("{:d}",i)
        v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
        txt:=RegExReplace(txt,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}",InStr(v,"`n")-1) "." this.bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}",InStr(txt,"`n")-1) "." this.bit2base64(txt)
    else
    {
      GuiControlGet, dRGB
      r:=StrSplit(Trim(StrReplace(Result,",","/"),"/"),"/")
      , x:=r[1], y:=r[2], s:="", i:=1
      Loop % r.Length()//3
        s.="," (r[i++]-x) "/" (r[i++]-y) "/" r[i++]
      txt:=SubStr(s,2), color:="##" dRGB
    }
    s:="`nText.=""|<" Comment ">" color "$" txt """`n"
    if (cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    x:=px-ww+CutLeft+(nW-CutLeft-CutRight)//2
    y:=py-hh+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["s8"],"|")
    s:="`; #Include <FindText>`n"
    . "`nt1:=A_TickCount, Text:=X:=Y:=""""`n" s
    . "`nif (ok:=FindText(X, Y, " x "-150000, "
    . y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n{"
    . "`n  `; FindText().Click(" . "X, Y, ""L"")"
    . "`n}`n"
    . "`n`; ok:=FindText(X:=""wait"", Y:=3, 0,0,0,0,0,0,Text)    `; " r[7]
    . "`n`; ok:=FindText(X:=""wait0"", Y:=-1, 0,0,0,0,0,0,Text)  `; " r[8]
    . "`n`nMsgBox, 4096, Tip, `% """ r[1] ":``t"" Round(ok.Length())"
    . "`n  . ""``n``n" r[2] ":``t"" (A_TickCount-t1) "" " r[3] """"
    . "`n  . ""``n``n" r[4] ":``t"" ok[1].x "", "" ok[1].y"
    . "`n  . ""``n``n" r[5] ":``t<"" (Comment:=ok[1].id) "">""`n"
    . "`nfor i,v in ok  `; ok " r[6] " ok:=FindText().ok"
    . "`n  if (i<=2)"
    . "`n    FindText().MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    Gui, Hide
    return
  Case "Save":
    x:=px-ww+CutLeft, w:=nW-CutLeft-CutRight
    y:=py-hh+CutUp, h:=nH-CutUp-CutDown
    %Gui_%("ScreenShot", x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "KeyDown":
    Critical
    if (A_Gui!="FindText_Main")
      return
    if (A_GuiControl="scr")
      SetTimer, %Gui_ShowPic%, -150
    else if (A_GuiControl="ClipText")
    {
      GuiControlGet, s, FindText_Main:, ClipText
      GuiControl, FindText_Main:, MyPic, % Trim(this.ASCII(s),"`n")
    }
    return
  Case "ShowPic":
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    GuiControl, FindText_Main:, MyPic, % Trim(this.ASCII(s),"`n")
    return
  Case "LButtonDown":
    Critical
    if (A_Gui!="FindText_Capture")
      return %Gui_%("KeyDown")
    MouseGetPos,,,, k2, 2
    if (k1:=Round(Cid_[k2]))<1
      return
    Gui, FindText_Capture: Default
    if (k1>71*25)
    {
      k3:=nW*nH+(k1-71*25)+dx
      k1:=(show[k3]:=!show[k3]) ? 0x0000FF : 0xAAFFFF
      SendMessage, 0x2001, 0, k1,, % "ahk_id " k2
      return
    }
    k2:=Mod(k1-1,71)+dx, k3:=(k1-1)//71+dy
    if (k2>=nW || k3>=nH)
      return
    k1:=k, k:=k3*nW+k2+1, k2:=c
    if (MultiColor and show[k])
    {
      c:="," Mod(k-1,nW) "/" k3 "/"
      . Format("{:06X}",cors[k]&0xFFFFFF)
      , Result.=InStr(Result,c) ? "":c
      ToolTip, % Trim(Result,"/,")
    }
    else if (Modify and bg!="" and show[k])
    {
      c:=((ascii[k]:=!ascii[k]) ? "Black":"White")
      , %Gui_%("SetColor")
    }
    else
    {
      c:=cors[k], cors.SelPos:=k
      GuiControl,, SelGray, % gray[k]
      GuiControl,, SelColor, % Format("0x{:06X}",c&0xFFFFFF)
      GuiControl,, SelR, % (c>>16)&0xFF
      GuiControl,, SelG, % (c>>8)&0xFF
      GuiControl,, SelB, % c&0xFF
    }
    k:=k1, c:=k2
    return
  Case "MouseMove":
    static PrevControl:=""
    if (PrevControl!=A_GuiControl)
    {
      PrevControl:=A_GuiControl
      SetTimer, %Gui_ToolTip%, % PrevControl ? -500 : "Off"
      SetTimer, %Gui_ToolTipOff%, % PrevControl ? -5500 : "Off"
      ToolTip
    }
    return
  Case "ToolTip":
    MouseGetPos,,, _TT
    IfWinExist, ahk_id %_TT% ahk_class AutoHotkeyGUI
      ToolTip, % Tip_Text[PrevControl]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2","CutR2","CutU2","CutD2":
    Gui, FindText_Main: Default
    GuiControlGet, s,, MyPic
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    GuiControl,, MyPic, % Trim(s,"`n")
    return
  Case "Update":
    Gui, FindText_Main: Default
    GuiControl, Focus, scr
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    if !RegExMatch(s, "O)(<[^>\n]*>[^$\n]+\$)\d+\.[\w+/]+", r)
      return
    GuiControlGet, v,, MyPic
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s, r[0], r[1] . w "." this.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend,, %v%, ahk_id %hscr%
    Control, EditPaste, %s%,, ahk_id %hscr%
    ControlSend,, {Home}, ahk_id %hscr%
    return
  Case "Load_Language_Text":
    s:="
    (
Myww       = 宽度 = 调整捕获范围的宽度
Myhh       = 高度 = 调整捕获范围的高度
AddFunc    = 附加 = 将 FindText() 函数代码一起复制
NowHotkey  = 截屏热键 = 当前的截屏热键
SetHotkey1 = = 第一优先级的截屏热键
SetHotkey2 = = 第二优先级的截屏热键
Apply      = 应用 = 应用新的截屏热键
CutU2      = 上删 = 裁剪下面编辑框中文字的上边缘
CutL2      = 左删 = 裁剪下面编辑框中文字的左边缘
CutR2      = 右删 = 裁剪下面编辑框中文字的右边缘
CutD2      = 下删 = 裁剪下面编辑框中文字的下边缘
Update     = 更新 = 更新下面编辑框中文字到代码行中
GetRange   = 获取屏幕范围 = 获取屏幕范围到剪贴板并替换代码中的范围
GetOffset  = 获取相对坐标 = 获取相对图像中心的坐标并替换代码中的坐标
GetClipOffset  = 获取相对坐标2 = 获取相对左边编辑框的坐标
Capture    = 抓图 = 开始屏幕抓图
CaptureS   = 截屏抓图 = 先恢复上一次的截屏到屏幕再开始抓图
Test       = 测试 = 测试生成的代码是否可以找字成功
TestClip   = 测试2 = 测试左边文本框中的文字，结果复制到剪贴板
Paste      = 粘贴 = 粘贴复制到剪贴板的文字数据
CopyOffset = 复制2 = 复制左边的偏移坐标到剪贴板
Copy       = 复制 = 复制代码到剪贴板
Reset      = 重读 = 重新读取原来的彩色图像
SplitAdd   = 分割添加 = 使用黄色的标签来分割图像为单个的图像数据，添加到旧代码中
AllAdd     = 整体添加 = 将文字数据整体添加到旧代码中
OK         = 确定 = 生成全新的代码替换旧代码
Cancel     = 取消 = 关闭窗口不做任何事
Save       = 保存图片 = 保存修剪后的原始图片到默认目录
Gray2Two      = 灰度阈值二值化 = 灰度小于阈值的为黑色其余白色
GrayDiff2Two  = 灰度差值二值化 = 某点与周围灰度之差大于差值的为黑色其余白色
Color2Two     = 颜色相似二值化 = 指定颜色及相似色为黑色其余白色
ColorPos2Two  = 颜色位置二值化 = 指定颜色及相似色为黑色其余白色，但是记录该色的位置
ColorDiff2Two = 颜色分量二值化 = 指定颜色及颜色分量小于允许值的为黑色其余白色
SelGray    = 灰度 = 选定颜色的灰度值 (0-255)
SelColor   = 颜色 = 选定颜色的RGB颜色值
SelR       = 红 = 选定颜色的红色分量
SelG       = 绿 = 选定颜色的绿色分量
SelB       = 蓝 = 选定颜色的蓝色分量
RepU       = -上 = 撤销裁剪上边缘1个像素
CutU       = 上 = 裁剪上边缘1个像素
CutU3      = 上3 = 裁剪上边缘3个像素
RepL       = -左 = 撤销裁剪左边缘1个像素
CutL       = 左 = 裁剪左边缘1个像素
CutL3      = 左3 = 裁剪左边缘3个像素
Auto       = 自动 = 二值化之后自动裁剪空白边缘
RepR       = -右 = 撤销裁剪右边缘1个像素
CutR       = 右 = 裁剪右边缘1个像素
CutR3      = 右3 = 裁剪右边缘3个像素
RepD       = -下 = 撤销裁剪下边缘1个像素
CutD       = 下 = 裁剪下边缘1个像素
CutD3      = 下3 = 裁剪下边缘3个像素
Modify     = 修改 = 二值化后允许修改黑白点
MultiColor = 多色查找 = 鼠标选择多种颜色，之后点击“确定”按钮
Undo       = 撤销 = 撤销上一次选择的颜色
Comment    = 识别文字 = 识别文本 (包含在<>中)，分割添加时也会分解成单个文字
Threshold  = 灰度阈值 = 灰度阈值 (0-255)
GrayDiff   = 灰度差值 = 灰度差值 (0-255)
Similar1   = 相似度 = 与选定颜色的相似度
Similar2   = 相似度 = 与选定颜色的相似度
DiffR      = 红 = 红色分量允许的偏差 (0-255)
DiffG      = 绿 = 绿色分量允许的偏差 (0-255)
DiffB      = 蓝 = 蓝色分量允许的偏差 (0-255)
DiffRGB    = 红/绿/蓝 = 多色查找时各分量允许的偏差 (0-255)
Bind0      = 绑定窗口1 = 绑定窗口使用GetDCEx()获取后台窗口图像
Bind1      = 绑定窗口1+ = 绑定窗口使用GetDCEx()并修改窗口透明度
Bind2      = 绑定窗口2 = 绑定窗口使用PrintWindow()获取后台窗口图像
Bind3      = 绑定窗口2+ = 绑定窗口使用PrintWindow()并修改窗口透明度
Bind4      = 绑定窗口3 = 绑定窗口使用PrintWindow(,,3)获取后台窗口图像
OK2        = 确定 = 生成全新的代码替换旧代码
Cancel2    = 取消 = 关闭窗口不做任何事
ClearAll   = 清空 = 清空所有保存的截图
OpenDir    = 打开目录 = 打开保存屏幕截图的目录
SavePic    = 保存图片 = 选择一个范围保存为图片
ClipText   = = 显示粘贴的文字数据
Offset     = = 显示“获取相对坐标2”获取的结果
s1  = FindText
s2  = 灰度阈值|灰度差值|颜色相似|颜色位置|颜色分量|多色查找
s3  = 图像二值化及分割
s4  = 抓图生成字库及找字代码
s5  = 位置|先点击右键一次\n把鼠标移开\n再点击右键一次
s6  = 解绑窗口使用
s7  = 请用左键拖动范围\n坐标复制到剪贴板
s8  = 找到|时间|毫秒|位置|结果|值可以这样获取|等待3秒等图像出现|无限等待等图像消失
s9  = 截屏成功
s10 = 鼠标位置|穿透显示绑定窗口\n点击右键完成抓图
s11 = 请先设定灰度差值
s12 = 请先选择核心颜色
s13 = 请先将图像二值化
s14 = 不能用于颜色位置二值化模式, 因为分割后会导致位置错误
s15 = 你确定选择的范围吗？\n\n如果不确定，可以重新选择
    )"
    Lang:=[], Tip_Text:=[]
    Loop Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v,"\n","`n"), "=", "`t ")
        , Lang[r[1]]:=r[2], Tip_Text[r[1]]:=r[3]
    return
  }
}

}  ;// Class End

;================= The End =================

;