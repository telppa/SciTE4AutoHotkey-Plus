;/*
;===========================================
;  FindText - 屏幕抓字生成字库工具与找字函数
;  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  脚本作者 : FeiYue
;  最新版本 : 8.5
;  更新时间 : 2021-04-22
;
;  用法:  (需要最新版本 AHK v1.1.31+)
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
;
;===========================================
;*/


if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
  FindText.Gui("Show")


;===== Copy The Following Functions To Your Own Code Just once =====


;--------------------------------
;  FindText - 屏幕找字函数
;--------------------------------
;  返回变量 := FindText(
;      X1 --> 查找范围的左上角X坐标
;    , Y1 --> 查找范围的左上角Y坐标
;    , X2 --> 查找范围的右下角X坐标
;    , Y2 --> 查找范围的右下角Y坐标
;    , err1 --> 文字的黑点容错百分率（0.1=10%）
;    , err0 --> 背景的白点容错百分率（0.1=10%）
;    , Text --> 由工具生成的查找图像的数据，可以一次查找多个，用“|”分隔
;    , ScreenShot --> 是否截屏，为0则使用上一次的截屏数据
;    , FindAll --> 是否搜索所有位置，为0则找到一个位置就返回
;    , JoinText --> 是否组合图像，为1则多个数据组合为一幅图来查找
;    , offsetX --> 组合图像的每个字和前一个字的最大横向间隔
;    , offsetY --> 组合图像的每个字和前一个字的最大高低间隔
;    , dir --> 查找的方向，有上、下、左、右、中心9种
;  )
;  返回变量 --> 如果没找到结果会返回0。否则返回一个二级数组，
;      第一级是每个结果对象，第二级是结果对象的具体信息数组:
;      { 1:左上角X, 2:左上角Y, 3:图像宽度W, 4:图像高度H
;        , x:中心点X, y:中心点Y, id:图像识别文本 }
;  坐标都是相对于屏幕，颜色使用RGB格式
;--------------------------------

FindText(args*)
{
  global FindText
  return FindText.FindText(args*)
}

Class FindText
{  ;// Class Begin

static bind:=[], bits:=[], Lib:=[]

__New()
{
  this.bind:=[], this.bits:=[], this.Lib:=[]
}

__Delete()
{
  if (this.bits.hBM)
    DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

FindText(x1:=0, y1:=0, x2:=0, y2:=0, err1:=0, err0:=0
  , text:="", ScreenShot:=1, FindAll:=1
  , JoinText:=0, offsetX:=20, offsetY:=10, dir:=1)
{
  local
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  centerX:=Round(x1+x2)//2, centerY:=Round(y1+y2)//2
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  , info:=[]
  Loop, Parse, text, |
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 or h<1 or !(num:=info.MaxIndex()) or !bits.Scan0)
  {
    SetBatchLines, %bch%
    return 0
  }
  arr:=[], in:={zx:zx, zy:zy, zw:zw, zh:zh
    , sx:x-zx, sy:y-zy, sw:w, sh:h}, k:=0
  For i,j in info
    k:=Max(k, j.2*j.3), in.comment .= j.11
  VarSetCapacity(s1, k*4), VarSetCapacity(s0, k*4)
  , VarSetCapacity(ss, 2*(w+2)*(h+2))
  , FindAll:=(dir=9 ? 1 : FindAll)
  , JoinText:=(num=1 ? 0 : JoinText)
  , allpos_max:=(FindAll or JoinText ? 10240 : 1)
  , VarSetCapacity(allpos, allpos_max*8)
  Loop, 2
  {
    if (err1=0 and err0=0) and (num>1 or A_Index>1)
      err1:=0.05, err0:=0.05
    Loop, % JoinText ? 1 : num
    {
      this.PicFind(arr, in, info, A_Index, err1, err0
        , FindAll, JoinText, offsetX, offsetY, dir
        , bits, ss, s1, s0, allpos, allpos_max)
      if (!FindAll and arr.MaxIndex())
        Break
    }
    if (err1!=0 or err0!=0 or arr.MaxIndex() or info.1.12)
      Break
  }
  if (dir=9)
    arr:=this.Sort2(arr, centerX, centerY)
  SetBatchLines, %bch%
  return arr.MaxIndex() ? arr:0
}

PicFind(arr, in, info, index, err1, err0
  , FindAll, JoinText, offsetX, offsetY, dir
  , bits, ByRef ss, ByRef s1, ByRef s0
  , ByRef allpos, allpos_max)
{
  local
  static MyFunc:=""
  if (!MyFunc)
  {
    x32:=""
    . "5557565383EC648B6C247883FD050F842C0900008BB424BC000000C744240C00"
    . "00000085F60F8E0A0D000031FF31C0896C2478C74424080000000031C9C74424"
    . "1400000000897C241089C5908D7426008B5C24108BBC24B80000008B7424148B"
    . "54240C01DF89D829DE8B9C24B800000003B424B400000085DB7E58893C2489EB"
    . "89D7EB198BAC24B000000083C70483C00189548D0083C1013904247429837C24"
    . "780389FA0F45D0803C063175D78BAC24AC00000083C70483C00189549D0083C3"
    . "0139042475D78BB424B80000000174241489DD83442408018BBC24A00000008B"
    . "442408017C24108B9C248C000000015C240C398424BC0000000F8551FFFFFF89"
    . "6C24088B6C2478894C240C31C08B74240839B424C00000008B7C240C0F4DF039"
    . "BC24C4000000897424080F4CC739C68944240C0F4DC683FD038904240F84C501"
    . "00008B84248C0000008BB424980000000FAF84249C000000C1E6028974243401"
    . "F08BB4248C000000894424308B8424A0000000F7D885ED8D0486894424200F85"
    . "5E0600008B44247CC744241C00000000C744242400000000C1E8100FB6E88B44"
    . "247C0FB6C4894424100FB644247C894424148B8424A0000000C1E0028944242C"
    . "8B8424A400000085C00F8EC60000008B7C24048B442430896C24188BAC24A000"
    . "000085ED0F8E8D0000008BB424880000008B6C242403AC24A800000001C60344"
    . "242C8944242803842488000000894424040FB67E028B4C24180FB6160FB64601"
    . "2B5424142B44241089FB01CF29CB8D8F000400000FAFC00FAFCBC1E00B0FAFCB"
    . "BBFE05000029FB0FAFDA01C10FAFD301CA399424800000000F93450083C60483"
    . "C5013B74240475A98B9C24A0000000015C24248B4424288344241C0103442420"
    . "8B74241C39B424A40000000F854AFFFFFF897C24048B8424A00000002B8424B8"
    . "000000C644244B00C644244A00C744245000000000C744245C00000000894424"
    . "548B8424A40000002B8424BC000000894424388B84248400000083E80183F807"
    . "0F86A2000000C7442440000000008B4424388B7424548944245489742438E9A2"
    . "000000897C247C83FD058B8424A00000000F9444244A83FD030F9444244B0384"
    . "24980000002B8424B8000000894424548B84249C000000038424A40000002B84"
    . "24BC000000894424388B84249C000000C784249C00000000000000894424508B"
    . "842498000000C7842498000000000000008944245C8B84248400000083E80183"
    . "F8070F875EFFFFFF83F803894424400F8E59FFFFFF8B44245C8B742450894424"
    . "508974245C8B742454397424500F8F8F0900008B4424548B742408C744242C00"
    . "000000894424588B8424AC0000008D04B08B7424408944244C89F083E0018944"
    . "244489F08BB4248800000083E003894424608B44245C8B7C243839F80F8F7C01"
    . "0000837C2460018B4C24500F4F4C2458897C24288944241C894C243C8D742600"
    . "8B7C24448B44242885FF0F4444241C837C244003894424200F8F66010000807C"
    . "244A008B44243C894424248B4424240F856E010000807C244B000F8510020000"
    . "0FAF8424A00000008B14248B5C242085D28D2C180F8E850000008BBC24C40000"
    . "008B9424A800000031C08B9C24C0000000896C24308B4C24088974241801EA89"
    . "7C24148B2C248B7C240C895C2410669039C17E1C8B9C24AC0000008B348301D6"
    . "803E00750B836C2410010F88F002000039C77E1C8B9C24B00000008B348301D6"
    . "803E00740B836C2414010F88D002000083C00139E875B98B6C24308B7424188B"
    . "44240885C074278BBC24A80000008B8424AC0000008B5C244C8D0C2F8D742600"
    . "8B1083C00401CA39D8C6020075F28B442420038424980000008B5C242C8BBC24"
    . "C80000008904DF8B4424240384249C0000008944DF0483C3013B9C24CC000000"
    . "895C242C7D308344241C01836C2428018B44241C394424380F8DA2FEFFFF8344"
    . "245001836C2458018B442450394424540F8D5CFEFFFF8B44242C83C4645B5E5F"
    . "5DC258008B442420807C244A00894424248B44243C894424208B4424240F8492"
    . "FEFFFF0FAF84248C0000008B1C248B4C242085DB8D2C880F8E51FFFFFF8BBC24"
    . "C000000031C9896C24108DB6000000008B8424AC0000008B5C2410031C888B84"
    . "24B00000008B2C880FB6441E0289EAC1EA100FB6D229D00FB6541E010FB61C1E"
    . "0FAFC03B4424047F2789E80FB6C429C20FAFD23B5424047F1789E80FB6C029C3"
    . "0FAFDB3B5C24047E108DB4260000000083EF010F887701000083C1013B0C2475"
    . "8F896C247CE9C4FEFFFF8DB6000000000FAF84248C0000008B4C24208D048889"
    . "4424100344247C0FB64C06010FB67C06020FB60406894C24148B0C2489442418"
    . "85C90F8E86FEFFFF8B8424C400000031DB894424348B8424C000000089442430"
    . "8B442404897C2404908DB42600000000395C24087E658B8424AC0000008B4C24"
    . "108B7C2404030C980FB6440E020FB6540E010FB60C0E2B5424142B4C241889C5"
    . "01F829FD8DB8000400000FAFD20FAFFDC1E20B0FAFFDBDFE05000029C50FAFE9"
    . "01FA0FAFCD01D1398C2480000000730B836C2430010F889E000000395C240C7E"
    . "618B8424B00000008B4C24108B7C2404030C980FB6440E020FB6540E010FB60C"
    . "0E2B5424142B4C241889C501F829FD8DB8000400000FAFD20FAFFDC1E20B0FAF"
    . "FDBDFE05000029C50FAFE901FA0FAFCD01D1398C24800000007207836C243401"
    . "783783C3013B1C240F8522FFFFFF89442404E977FDFFFF89F68DBC2700000000"
    . "8B742418E99DFDFFFF8DB42600000000896C247CE98DFDFFFF89442404E984FD"
    . "FFFF83FD010F848404000083FD020F84EA0100008B44247C0FB67C247CC74424"
    . "2800000000C744242C00000000C1E8100FB6D08B44247C89D50FB6DC8B842480"
    . "000000C1E8100FB6C88B84248000000029CD01D1896C243889DD894C24100FB6"
    . "F40FB684248000000029F501DE896C241489FD8974241829C501F8894424248B"
    . "8424A0000000896C241CC1E002894424348B8424A400000085C00F8E15FAFFFF"
    . "8B4C24308B6C24388B8424A000000085C00F8E8A0000008B8424880000008B54"
    . "242C039424A800000001C8034C243489CF894C243003BC2488000000EB366690"
    . "395C24107C3D394C24147F37394C24187C3189F30FB6F33974241C0F9EC33974"
    . "24240F9DC183C00483C20121D9884AFF39C7741E0FB658020FB648010FB63039"
    . "DD7EBD31C983C00483C201884AFF39C775E28BB424A00000000174242C8B4C24"
    . "308344242801034C24208B442428398424A40000000F854DFFFFFFE955F9FFFF"
    . "8B84248000000031C931F631FF8904248B44247CC744247C000000000FAFC089"
    . "4424048B8424B40000000FB6108D5801EB2789FA8B8C24AC0000000FB7FFC1EA"
    . "100FAF94248C0000008D14BA31FF8914B10FB61389C183C3010FBEC285C00F84"
    . "5FF9FFFF8D50D083FA0977078D14BF8D7C50D083F82F74070FB61384D275D789"
    . "C883F00185C974AA8B8C24B0000000893CB189C10FB61383C60131FFEBB88B84"
    . "24A00000008BB4249C0000000FAF8424A400000083EE01038424A80000008974"
    . "2410894424188B8424A0000000038424980000008944241C8B84249C00000003"
    . "8424A400000039F00F8C0B0100008BB4249800000083C0012BAC249800000089"
    . "4424288B44241CC74424240000000083EE018974242C8B74241001C50FAFB424"
    . "8C0000008D7801896C2430897424208B44242C3944241C0F8C9E0000008B4C24"
    . "108B5C24208B742424035C24342BB42498000000039C2488000000C1E91F0374"
    . "2418894C2414EB53908DB42600000000398424900000007E4B807C2414007544"
    . "8B4C2410398C24940000007E370FB64BFE0FB653FD83C3040FB66BF86BD24B6B"
    . "C92601D189EAC1E20429EA01CAC1FA078854060183C00139F8741889C2C1EA1F"
    . "84D274ACC64406010083C00183C30439F875E88B742430017424248344241001"
    . "8B9C248C0000008B442410015C2420394424280F8536FFFFFF8B8424A0000000"
    . "8B8C24A400000083C00285C98944241C0F8E3FF7FFFF8B8424A40000008B6C24"
    . "18036C241CC744241801000000C74424200000000083C001894424248B8424A0"
    . "000000896C241483C004894424288B8424800000008B9424A000000085D20F8E"
    . "A40000008B4424148B5C24208B742428039C24A800000089C12B8C24A0000000"
    . "89C201C6894C2410908DB426000000000FB642010FB62ABF010000000344247C"
    . "39E8723D0FB66A0239E872358B4C24100FB669FF39E872290FB66EFF39E87221"
    . "0FB669FE39E872190FB62939E872120FB66EFE39E8720A0FB63E39F80F92C189"
    . "CF89F9834424100183C201880B83C60183C3018B4C2410394C241475938BBC24"
    . "A0000000017C242083442418018B5C241C8B742418015C2414397424240F8532"
    . "FFFFFF89842480000000E926F6FFFF8B44247C8BB424A400000031EDC7442414"
    . "000000008D48018B8424A0000000C1E107C1E00285F6894C247C894424180F8E"
    . "F1F5FFFF896C24108B4424308B6C247C8B9C24A000000085DB7E5F8B8C248800"
    . "00008B5C2414039C24A800000001C1034424188944241C0384248800000089C7"
    . "0FB651020FB641010FB6316BC04B6BD22601C289F0C1E00429F001D039C50F97"
    . "0383C10483C30139F975D58BBC24A0000000017C24148B44241C834424100103"
    . "4424208B74241039B424A40000007580E960F5FFFFC744240800000000E9C9F3"
    . "FFFFC744242C00000000E947F8FFFF90"
    x64:=""
    . "4157415641554154555756534881EC88000000488BBC24F0000000488BB42430"
    . "01000083F90589542468448944240844898C24E8000000488B9C243801000048"
    . "8BAC24400100000F84B40900008B8424580100004531ED4531E485C00F8EDC00"
    . "000044897C240C448BBC245001000031D231C04889BC24F00000004889B42430"
    . "0100004531F64531ED4531E4C704240000000089D789C6660F1F840000000000"
    . "4585FF7E6548631424478D1C374489F048039424480100004189F8EB1F0F1F00"
    . "83C0014D63D54183C0044183C5014883C2014139C346894C9500742A83F90345"
    . "89C1440F45C8803A3175D583C0014D63D44183C0044183C4014883C2014139C3"
    . "46890C9375D644013C2483C6014403B4242001000003BC24F800000039B42458"
    . "0100000F8577FFFFFF448B7C240C488BBC24F0000000488BB4243001000031C0"
    . "4439A42460010000440F4DE04439AC2468010000440F4DE84539EC4589EE450F"
    . "4DF483F9030F84110200008B8424F80000008B9424100100000FAF8424180100"
    . "008D04908B9424F8000000894424208B842420010000F7D885C98D0482890424"
    . "0F85CA0600008B4C24684889C84189CB0FB6C441C1EB1089C20FB6C1450FB6DB"
    . "4189C28B84242801000085C00F8E370100008B842420010000448964242831C9"
    . "44896C24304889B42430010000448B6C2420448B6424088BB42420010000C1E0"
    . "0244897424184889BC24F00000004889AC24400100004189CEC744240C000000"
    . "008944241089D748899C24380100004489D585F60F8E8A000000488B9C24F000"
    . "00004963C54531D24C8D4C030248635C240C48039C2430010000660F1F440000"
    . "450FB639410FB651FE410FB641FF29EA4489F94501DF4189D0418D9700040000"
    . "4429D929F80FAFD10FAFC00FAFD1C1E00B8D0402BAFE0500004429FA410FAFD0"
    . "410FAFD001D04139C4420F9304134983C2014983C1044439D67FA544036C2410"
    . "0174240C4183C60144032C244439B424280100000F8558FFFFFF448B74241844"
    . "8B642428448B6C2430488BBC24F0000000488BB42430010000488B9C24380100"
    . "00488BAC24400100008B8424200100002B842450010000C644245700C644244C"
    . "00C744246C00000000C744247800000000894424708B8424280100002B842458"
    . "010000894424408B8424E800000083E80183F8070F86A3000000C74424480000"
    . "00008B4424408B4C247089442470894C2440E9A300000044894C246883F9058B"
    . "8424200100000F9444244C83F9030F94442457038424100100002B8424500100"
    . "00894424708B842418010000038424280100002B842458010000894424408B84"
    . "2418010000C7842418010000000000008944246C8B842410010000C784241001"
    . "000000000000894424788B8424E800000083E80183F8070F875DFFFFFF83F803"
    . "894424480F8E58FFFFFF8B4424788B4C246C8944246C894C24788B4C2470394C"
    . "246C0F8F820A00008B4424708B4C244848899C24380100004889AC2440010000"
    . "4489ED4589E5C74424300000000089442474418D4424FF4C8BA4244001000048"
    . "8D4483044889F3488BB42438010000488944246089C883E0018944245089C883"
    . "E0038944247C4489F04589FE4189C78B4424788B4C244039C80F8F3B01000083"
    . "7C247C018B54246C0F4F542474894C2428890424895424440F1F840000000000"
    . "8B44245085C08B4424280F440424837C2448038944240C0F8F33010000807C24"
    . "4C008B442444894424100F853B010000807C2457000F85D50100008B4C24100F"
    . "AF8C2420010000034C240C4585FF7E50448B942468010000448B8C2460010000"
    . "31C04139C589C27E184189C84403048642803C0300750A4183E9010F88830000"
    . "0039D57E1289CA41031484803C130074064183EA01786D4883C0014139C77FC2"
    . "4585ED741C4C8B4424604889F00F1F0089CA03104883C0044C39C0C604130075"
    . "EF8B4C24308B54240C039424100100004C8B94247001000089C801C048984189"
    . "14828B54241003942418010000418954820489C883C0013B8424780100008944"
    . "24307D2E83042401836C2428018B0424394424400F8DE6FEFFFF8344246C0183"
    . "6C2474018B44246C394424700F8D9DFEFFFF8B4424304881C4880000005B5E5F"
    . "5D415C415D415E415FC3660F1F4400008B44240C807C244C00894424108B4424"
    . "448944240C0F84C5FEFFFF8B4424108B4C240C0FAF8424F80000004585FF448D"
    . "14880F8E39FFFFFF448B8C24600100004531C04989DB662E0F1F840000000000"
    . "428B1486438B1C844401D289D98D4202C1E9100FB6C948980FB6040729C88D4A"
    . "014863D20FAFC00FB614174863C90FB60C0F4439F07F1A0FB6C729C10FAFC944"
    . "39F17F0D0FB6C329C20FAFD24439F27E0A4183E9010F88950100004983C00145"
    . "39C77F9C895C24684C89DBE9B1FEFFFF8B4424108B4C240C0FAF8424F8000000"
    . "8D048889C1034424684585FF8D50024863D2440FB614178D500148980FB60407"
    . "4863D20FB614170F8E74FEFFFF448B9C246801000048895C24584531C9488974"
    . "24184C8964242089CB89C64189D444895C243C448B9C246001000044895C2438"
    . "4539CD4589C87E6E488B442418428B148801DA8D42024898440FB634078D4201"
    . "4863D20FB6141748980FB604074589F34501D6418D8E000400004529D329F241"
    . "0FAFCB4429E00FAFC0410FAFCB41BBFE050000C1E00B4529F3440FAFDA01C841"
    . "0FAFD301C239542408730B836C2438010F88A60000004439C57E6A488B442420"
    . "428B148801DA8D42024898440FB634078D42014863D20FB6141748980FB60407"
    . "4589F04501D6418D8E000400004529D029F2410FAFC84429E00FAFC0410FAFC8"
    . "41B8FE050000C1E00B4529F0440FAFC201C8410FAFD001C2395424087207836C"
    . "243C0178374983C1014539CF0F8F0EFFFFFF488B5C2458488B7424184C8B6424"
    . "20E93BFDFFFF662E0F1F840000000000895C24684C89DBE968FDFFFF488B5C24"
    . "58488B7424184C8B642420E954FDFFFF83F9010F845B05000083F9020F842002"
    . "00008B542468448B542408C744241000000000C74424180000000089D0440FB6"
    . "C2C1E810440FB6C84889D00FB6CC4489D04589CBC1E810894C240C0FB6D04C89"
    . "D00FB6C44129D34401CA89C18B44240C29C8034C240C89442430410FB6C24589"
    . "C24129C24401C0448B8424280100008944240C8B842420010000C1E0024585C0"
    . "894424280F8EFFF9FFFF448974243C44896C244448899C2438010000448B7424"
    . "20448B6C24308B9C242001000044897C243844896424404189CF4889AC244001"
    . "00004189D44489D585DB7E724C635424184963C631D2488D4407024901F2EB31"
    . "4539C47C3E4139CD7F394139CF7C344439CD410F9EC044394C240C0F9DC14883"
    . "C0044421C141880C124883C20139D37E24440FB6000FB648FF440FB648FE4539"
    . "C37EBD31C94883C00441880C124883C20139D37FDC4403742428015C24188344"
    . "241001440334248B442410398424280100000F8570FFFFFF448B7C2438448B74"
    . "243C448B642440448B6C2444488B9C2438010000488BAC2440010000E908F9FF"
    . "FF8B442468448B7424084531C04531DB4531C94189C7440FAFF8488B84244801"
    . "00000FB6104C8D5001EB2B4489CA450FB7C94D63C3C1EA100FAF9424F8000000"
    . "428D148A4531C942891483410FB6124189C04983C2010FBEC285C00F8416F9FF"
    . "FF8D50D083FA097709438D1489448D4C50D083F82F7408410FB61284D275D344"
    . "89C083F0014585C074A14963D34189C04183C30144894C95004531C9410FB612"
    . "EBB08B8424200100008B9424180100000FAF842428010000448D5AFF48984801"
    . "F0488904248B842420010000038424100100008944240C8B8424180100000384"
    . "24280100004439D80F8C610100008B94241001000083C001448B9424F8000000"
    . "894424282B8C24100100004489642448448BA4240001000083EA01C744241800"
    . "00000044897C24408D049500000000895424384489742444450FAFD344896C24"
    . "4C48899C243801000089442420489848894424308B44240C448954241001C144"
    . "8D5001894C243C8B4424383944240C0F8CA40000008B4C24108B5424204589DE"
    . "488B5C24304C6344241841C1EE1F4C03042401CA4C63F94863D24C8D0C174829"
    . "D3EB514139C47E554584F6755044399C24080100007E46410FB64902410FB651"
    . "0183C0014983C0016BD24B6BC92601D14A8D140B4983C104460FB62C3A4489EA"
    . "C1E2044429EA01D1C1F907418848FF4139C2741D89C2C1EA1F84D274A683C001"
    . "41C600004983C1044983C0014139C275E38B5C243C015C24184183C3018B9C24"
    . "F8000000015C241044395C24280F8534FFFFFF448B7C2440448B742444448B64"
    . "2448448B6C244C488B9C24380100008B842420010000448B94242801000083C0"
    . "024585D20F8E9FF6FFFF488B0C24489844897C24384889442410448B7C246848"
    . "899C2438010000C7042401000000488D440101C744240C00000000448974243C"
    . "4889C18B8424280100004889CB83C001894424184863842420010000488D5003"
    . "48F7D048894424288B84242001000048895424208B54240883E8014883C00148"
    . "89442430448B8C24200100004585C90F8EAE000000488B44242048634C240C4C"
    . "8D0C18488B4424284801F14C8D0418488B4424304C8D34184889D80F1F440000"
    . "0FB610440FB650FF41BB010000004401FA4439D2724A440FB650014439D27240"
    . "450FB650FF4439D27236450FB651FF4439D2722C450FB650FE4439D27222450F"
    . "B6104439D27219450FB651FE4439D2720F450FB6114439D2410F92C30F1F4000"
    . "4883C0014488194983C1014883C1014983C0014C39F075888B8C242001000001"
    . "4C240C8304240148035C24108B0424394424180F852BFFFFFF448B7C2438448B"
    . "74243C89542408488B9C2438010000E935F5FFFF8B8424200100008B54246845"
    . "31DBC744240C00000000C1E00283C201894424108B842428010000C1E2078954"
    . "246885C00F8EFFF4FFFF44897C241848899C2438010000448B7C2468448B9424"
    . "200100008B5C242044897424284585D27E504C6374240C4863C34531C0488D4C"
    . "07024901F60FB6110FB641FF440FB649FE6BC04B6BD22601C24489C8C1E00444"
    . "29C801D04139C7430F9704064983C0014883C1044539C27FCC035C2410440154"
    . "240C4183C301031C2444399C2428010000759A448B7C2418448B742428488B9C"
    . "2438010000E95FF4FFFFC744243000000000E93BF7FFFF909090909090909090"
    this.MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  num:=info.MaxIndex(), j:=info[index]
  , text:=j.1, w:=j.2, h:=j.3
  , e1:=(!j.12 ? Floor(j.4*err1) : j.6)
  , e0:=(!j.12 ? Floor(j.5*err0) : j.7)
  , mode:=j.8, color:=j.9, n:=j.10, comment:=j.11
  , sx:=in.sx, sy:=in.sy, sw:=in.sw, sh:=in.sh
  if (JoinText and index>1)
  {
    x:=in.x, y:=in.y, sw:=Min(x+offsetX+w,sx+sw), sx:=x, sw-=sx
    , sh:=Min(y+offsetY+h,sy+sh), sy:=Max(y-offsetY,sy), sh-=sy
  }
  if (mode=3)
    color:=(color//w)*bits.Stride+Mod(color,w)*4
  ok:=!bits.Scan0 ? 0 : DllCall(&MyFunc
    , "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",bits.Scan0, "int",bits.Stride
    , "int",in.zw, "int",in.zh
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",&ss, "Ptr",&s1, "Ptr",&s0
    , "AStr",text, "int",w, "int",h, "int",e1, "int",e0
    , "Ptr",&allpos, "int",allpos_max)
  pos:=[]
  Loop, % ok
    pos.Push( NumGet(allpos, 8*A_Index-8, "uint")
      , NumGet(allpos, 8*A_Index-4, "uint") )
  Loop, % ok
  {
    x:=pos[2*A_Index-1], y:=pos[2*A_Index]
    if (!JoinText)
    {
      x1:=x+in.zx, y1:=y+in.zy
      , arr.Push( {1:x1, 2:y1, 3:w, 4:h
      , x:x1+w//2, y:y1+h//2, id:comment} )
    }
    else if (index=1)
    {
      in.x:=x+w, in.y:=y, in.minY:=y, in.maxY:=y+h
      Loop, % num-1
        if !this.PicFind(arr, in, info, A_Index+1, err1, err0
        , FindAll, JoinText, offsetX, offsetY, 5
        , bits, ss, s1, s0, allpos, 1)
          Continue, 2
      x1:=x+in.zx, y1:=in.minY+in.zy
      , w1:=in.x-x, h1:=in.maxY-in.minY
      , arr.Push( {1:x1, 2:y1, 3:w1, 4:h1
      , x:x1+w1//2, y:y1+h1//2, id:in.comment} )
    }
    else
    {
      in.x:=x+w, in.y:=y
      , (y<in.minY && in.minY:=y)
      , (y+h>in.maxY && in.maxY:=y+h)
      return 1
    }
    if (!FindAll and arr.MaxIndex())
      return
  }
}

GetBitsFromScreen(ByRef x, ByRef y, ByRef w, ByRef h
  , ScreenShot:=1, ByRef zx:="", ByRef zy:=""
  , ByRef zw:="", ByRef zh:="")
{
  local
  static Ptr:="Ptr"
  bits:=this.bits
  if (!ScreenShot)
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
    hBM:=bits.hBM
    , bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
    , DllCall("DeleteObject", Ptr,hBM)
  }
  if (w<1 or h<1 or !bits.hBM)
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
  mDC:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,bits.hBM, Ptr)
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC2:=DllCall("GetDCEx", Ptr,id, Ptr,0, "int",3, Ptr)
      DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , Ptr,hDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020|0x40000000)
      DllCall("ReleaseDC", Ptr,id, Ptr,hDC2)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
      oBM2:=DllCall("SelectObject", Ptr,mDC2, Ptr,hBM2, Ptr)
      DllCall("PrintWindow", Ptr,id, Ptr,mDC2, "uint",(mode>3)*3)
      DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , Ptr,mDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020|0x40000000)
      DllCall("SelectObject", Ptr,mDC2, Ptr,oBM2)
      DllCall("DeleteDC", Ptr,mDC2)
      DllCall("DeleteObject", Ptr,hBM2)
    }
  }
  else
  {
    win:=DllCall("GetDesktopWindow", Ptr)
    hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
    DllCall("BitBlt",Ptr,mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0xCC0020|0x40000000)
    DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteDC", Ptr,mDC)
  Critical, %cri%
  SetBatchLines, %bch%
  return bits
}

CreateDIBSection(w, h, bpp:=32, ByRef ppvBits:=0, ByRef bi:="")
{
  local
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  , NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  , NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",&bi
    , "int",0, "Ptr*",ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

PicInfo(text)
{
  local
  static info:=[], Ptr:="Ptr"
  if !InStr(text,"$")
    return
  key:=(r:=StrLen(text))<1000 ? text
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , Ptr,&text, "uint",r*(1+!!A_IsUnicode), "uint")
  if (info[key])
    return info[key]
  v:=text, comment:="", seterr:=e1:=e0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v,"<([^>]*)>",r)
    v:=StrReplace(v,r), comment:=Trim(r1)
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v,"\[([^\]]*)]",r)
  {
    v:=StrReplace(v,r), r:=StrSplit(r1, ",")
    , seterr:=1, e1:=r.1, e0:=r.2
  }
  color:=StrSplit(v,"$").1, v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5
    : InStr(color,"-") ? 4 : InStr(color,"#") ? 3
    : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
  color:=RegExReplace(color, "[*#\s]")
  if (mode=5)
  {
    if (v~="[^\s\w/]") and FileExist(v)  ; ImageSearch
    {
      if !(hBM:=LoadPicture(v))
        return
      VarSetCapacity(bm, size:=(A_PtrSize=8 ? 32:24), 0)
      DllCall("GetObject", Ptr,hBM, "int",size, Ptr,&bm)
      w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
      if (w<1 or h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", Ptr,hBM)
      if (!Scan0)
        return
      c1:=NumGet(Scan0+0,"uint")&0xFFFFFF
      c2:=NumGet(Scan0+(w-1)*4,"uint")&0xFFFFFF
      c3:=NumGet(Scan0+(w*h-w)*4,"uint")&0xFFFFFF
      c4:=NumGet(Scan0+(w*h-1)*4,"uint")&0xFFFFFF
      if (c1!=c2 or c1!=c3 or c1!=c4)
        c1:=-1
      VarSetCapacity(v, w*h*18*(1+!!A_IsUnicode)), i:=-4, n:=0
      ListLines, % (lls:=A_ListLines)?"Off":"Off"
      SetFormat, IntegerFast, d
      Loop, %h%
      {
        y:=A_Index-1
        Loop, %w%
          if (c:=NumGet(Scan0+(i+=4),"uint")&0xFFFFFF)!=c1
            v.=((A_Index-1)|y<<16) "/" c "/", n++
      }
      ListLines, %lls%
      DllCall("DeleteObject", Ptr,hBM2)
    }
    else
    {
      v:=Trim(StrReplace(RegExReplace(v,"\s"),",","/"),"/")
      r:=StrSplit(v,"/"), n:=r.MaxIndex()//3
      if (!n)
        return
      VarSetCapacity(v, n*18*(1+!!A_IsUnicode))
      x1:=x2:=r.1, y1:=y2:=r.2
      ListLines, % (lls:=A_ListLines)?"Off":"Off"
      SetFormat, IntegerFast, d
      Loop, % n + (i:=-2)*0
        x:=r[i+=3], y:=r[i+1]
        , (x<x1 && x1:=x), (x>x2 && x2:=x)
        , (y<y1 && y1:=y), (y>y2 && y2:=y)
      Loop, % n + (i:=-2)*0
        v.=(r[i+=3]-x1)|(r[i+1]-y1)<<16 . "/"
        . Floor("0x" StrReplace(r[i+2],"0x"))&0xFFFFFF . "/"
      ListLines, %lls%
      w:=x2-x1+1, h:=y2-y1+1
    }
    len1:=n, len0:=0
  }
  else
  {
    r:=StrSplit(v,"."), w:=r.1
    , v:=this.base64tobit(r.2), h:=StrLen(v)//w
    if (w<1 or h<1 or StrLen(v)!=w*h)
      return
    if (mode=4)
    {
      r:=StrSplit(StrReplace(color,"0x"),"-")
      , color:=Round("0x" r.1), n:=Round("0x" r.2)
    }
    else
    {
      r:=StrSplit(color,"@")
      , color:=r.1, n:=Round(r.2,2)+(!r.2)
      , n:=Floor(512*9*255*255*(1-n)*(1-n))
    }
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
  }
  e1:=Floor(len1*e1), e0:=Floor(len0*e0)
  return info[key]:=[v, w, h, len1, len0, e1, e0
    , mode, color, n, comment, seterr]
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w2, h2)
{
  local
  static Ptr:="Ptr"
  mDC1:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM1:=DllCall("SelectObject", Ptr,mDC1, Ptr,hBM1, Ptr)
  mDC2:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM2:=DllCall("SelectObject", Ptr,mDC2, Ptr,hBM2, Ptr)
  DllCall("BitBlt", Ptr,mDC1
    , "int",x1, "int",y1, "int",w2, "int",h2, Ptr,mDC2
    , "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("SelectObject", Ptr,mDC2, Ptr,oBM2)
  DllCall("DeleteDC", Ptr,mDC2)
  DllCall("SelectObject", Ptr,mDC1, Ptr,oBM1)
  DllCall("DeleteDC", Ptr,mDC1)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w2,h2)
{
  local
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
    p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w2*=4
  Loop, % h2
    DllCall("RtlMoveMemory", "Ptr",p1+=Stride1
      , "Ptr",p2+=Stride2, "Ptr",w2)
  ListLines, %lls%
}

; 绑定窗口从而可以后台查找这个窗口的图像
; 相当于始终在前台。解绑窗口使用 FindText.BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  local
  bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id, bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      WinGet, oldStyle, ExStyle, ahk_id %bind_id%
      bind.oldStyle:=oldStyle
      WinSet, Transparent, 255, ahk_id %bind_id%
      Loop, 30
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

; 使用 FindText.CaptureCursor(1) 设置抓图时捕获鼠标
; 使用 FindText.CaptureCursor(0) 取消抓图时捕获鼠标

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
  Ptr:=(A_PtrSize ? "Ptr":"UInt"), PtrSize:=(A_PtrSize=8 ? 8:4)
  VarSetCapacity(mi, 40, 0), NumPut(16+PtrSize, mi, "int")
  DllCall("GetCursorInfo", Ptr,&mi)
  bShow   := NumGet(mi, 4, "int")
  hCursor := NumGet(mi, 8, Ptr)
  x := NumGet(mi, 8+PtrSize, "int")
  y := NumGet(mi, 12+PtrSize, "int")
  if (!bShow) or (x<zx or y<zy or x>=zx+zw or y>=zy+zh)
    return
  VarSetCapacity(ni, 40, 0)
  DllCall("GetIconInfo", Ptr,hCursor, Ptr,&ni)
  xCenter  := NumGet(ni, 4, "int")
  yCenter  := NumGet(ni, 8, "int")
  hBMMask  := NumGet(ni, (PtrSize=8?16:12), Ptr)
  hBMColor := NumGet(ni, (PtrSize=8?24:16), Ptr)
  DllCall("DrawIconEx", Ptr,hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, Ptr,hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", Ptr,hBMMask)
  DllCall("DeleteObject", Ptr,hBMColor)
}

MCode(ByRef code, hex)
{
  local
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  VarSetCapacity(code, len:=StrLen(hex)//2)
  Loop, % len
    NumPut("0x" SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  DllCall("VirtualProtect","Ptr",&code,"Ptr",len,"uint",0x40,"Ptr*",0)
  SetBatchLines, %bch%
  ListLines, %lls%
}

base64tobit(s)
{
  local
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
  Loop, Parse, Chars
  {
    s:=RegExReplace(s, "[" A_LoopField "]"
    , StrReplace( ((i:=A_Index-1)>>5&1) . (i>>4&1)
    . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), "0x"))
  }
  ListLines, %lls%
  return RegExReplace(RegExReplace(s,"10*$"),"[^01]+")
}

bit2base64(s)
{
  local
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
  Loop, Parse, Chars
  {
    s:=StrReplace(s, StrReplace("|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    , "0x"), A_LoopField)
  }
  ListLines, %lls%
  return s
}

xywh2xywh(x1,y1,w1,h1, ByRef x, ByRef y, ByRef w, ByRef h
  , ByRef zx:="", ByRef zy:="", ByRef zw:="", ByRef zh:="")
{
  local
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
  if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
  {
    s:=RegExReplace(this.base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return s
}

; 可以在脚本的开头用 FindText.PicLib(Text,1) 导入字库,
; 然后使用 FindText.PicLib("说明文字1|说明文字2|...") 获取字库中的数据

PicLib(comments, add_to_Lib:=0, index:=1)
{
  local
  Lib:=this.Lib
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]+"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
      {
        s1:=Trim(r1), s2:=""
        Loop, Parse, s1
          s2.="_" . Format("{:d}",Ord(A_LoopField))
        Lib[index,s2]:=r
      }
    Lib[index,""]:=""
  }
  else
  {
    Text:=""
    Loop, Parse, comments, |
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop, Parse, s1
        s2.="_" . Format("{:d}",Ord(A_LoopField))
      Text.="|" . Lib[index,s2]
    }
    return Text
  }
}

; 分割字符串为单个文字并获取数据

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; 使用 FindText.PicX(Text) 可以将文字分割成多个单字的组合，从而适应间隔变化
; 但是不能用于“颜色位置二值化”模式, 因为位置是与整体图像相关的

PicX(Text)
{
  local
  if !RegExMatch(Text,"(<[^$]+)\$(\d+)\.([\w+/]+)",r)
    return Text
  v:=this.base64tobit(r3), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r2 "}","$0`n")
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
      Text.="|" r1 "$" i "." this.bit2base64(v)
  }
  return Text
}

; 截屏，作为后续操作要用的“上一次的截屏”

ScreenShot(x1:=0, y1:=0, x2:=0, y2:=0)
{
  this.FindText(x1, y1, x2, y2)
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

; 在最后一个屏幕截图中设置点的RGB颜色

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
    x:=v.1
    , min_X:=(A_Index=1 or x<min_X ? x : min_X)
    , max_X:=(A_Index=1 or x>max_X ? x : max_X)
  While (min_X!="" and min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) or Abs(y-ocr_Y)>offsetY
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" or x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" and LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX
    , ocr_Y:=LeftY, (LeftY<min_Y && min_Y:=LeftY)
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
  ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k2,v2 in ypos
      if Abs(y-v2)<=dy
      {
        y:=v2, add:=0
        Break
      }
    if (add)
      ypos.Push(y)
    n:=(y*150000+x) "." k, s:=A_Index=1 ? n : s "-" n
  }
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; 以指定点为中心，按从近到远排序FindText()的结果
; 返回排序后的数组对象

Sort2(ok, px, py)
{
  local
  if !IsObject(ok)
    return ok
  For k,v in ok
    n:=((v.x-px)**2+(v.y-py)**2) "." k, s:=A_Index=1 ? n : s "-" n
  Sort, s, N D-
  ok2:=[]
  Loop, Parse, s, -
    ok2.Push( ok[(StrSplit(A_LoopField,".")[2])] )
  return ok2
}

; 提示某个坐标的位置，或远程控制中当前鼠标的位置

MouseTip(x:="", y:="", w:=10, h:=10, d:=4)
{
  local
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  x:=Round(x-w-d), y:=Round(y-h-d), w:=(2*w+1)+2*d, h:=(2*h+1)+2*d
  ;-------------------------
  Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid -DPIScale
  Gui, _MouseTip_: Show, Hide w%w% h%h%
  ;-------------------------
  DetectHiddenWindows, % (dhw:=A_DetectHiddenWindows)?"On":"On"
  i:=w-d, j:=h-d
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%, ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  Gui, _MouseTip_: Show, NA x%x% y%y%
  Loop, 4
  {
    Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
    Sleep, 500
  }
  Gui, _MouseTip_: Destroy
}

; 快速获取屏幕图像的搜索文本数据

GetTextFromScreen(x1, y1, x2, y2, Threshold:=""
  , ScreenShot:=1, ByRef rx:="", ByRef ry:="")
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
  ListLines, % (lls:=A_ListLines)?"Off":"Off"
  gs:=[], k:=0
  Loop, %h%
  {
    j:=y+A_Index-1
    Loop, %w%
      i:=x+A_Index-1, c:=this.GetColor(i,j,0)
      , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  }
  if InStr(Threshold,"**")
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
      Threshold:=50
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop, %h%
    {
      y1:=A_Index
      Loop, %w%
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
      Loop, 256
        pp[A_Index-1]:=0
      Loop, % w*h
        pp[gs[A_Index]]++
      IP:=IS:=0
      Loop, 256
        k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
      Threshold:=Floor(IP/IS)
      Loop, 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop, % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP-IP1, IS2:=IS-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop, % w*h
      s.=gs[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  re1=(^0{%w%}|^1{%w%})
  re2=(0{%w%}$|1{%w%}$)
  While RegExMatch(s,re1)
    s:=RegExReplace(s,re1), CutUp++
  While RegExMatch(s,re2)
    s:=RegExReplace(s,re2), CutDown++
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  SetBatchLines, %bch%
  ListLines, %lls%
  return s
}

; 快速保存截图为BMP文件，可用于调试

SavePic(file, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static Ptr:="Ptr"
  if (x1*x1+y1*y1+x2*x2+y2*y2<=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  if (w<1 or h<1 or !bits.hBM)
    return
  hBM:=this.CreateDIBSection(w, -h, bpp:=24, ppvBits, bi)
  this.CopyHBM(hBM, 0, 0, bits.hBM, x-zx, y-zy, w, h)
  size:=((w*bpp+31)//32)*4*h, NumPut(size, bi, 20, "uint")
  VarSetCapacity(bf, 14, 0), StrPut("BM", &bf, "CP0")
  NumPut(54+size, bf, 2, "uint"), NumPut(54, bf, 10, "uint")
  f:=FileOpen(file,"w"), f.RawWrite(bf,14), f.RawWrite(bi,40)
  , f.RawWrite(ppvBits+0, size), f.Close()
  DllCall("DeleteObject", Ptr,hBM)
}

; 显示保存的图像

ShowPic(file:="", show:=1
  , ByRef zx:="", ByRef zy:="", ByRef w:="", ByRef h:="")
{
  local
  static Ptr:="Ptr"
  Gui, FindText_Screen: Destroy
  if (file="") or !FileExist(file)
    return
  bits:=this.GetBitsFromScreen(0,0,0,0,1,zx,zy,zw,zh)
  hBM:=bits.hBM, hBM2:=LoadPicture(file)
  VarSetCapacity(bm, size:=(A_PtrSize=8 ? 32:24), 0)
  DllCall("GetObject", Ptr,hBM2, "int",size, Ptr,&bm)
  w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
  this.CopyHBM(hBM, 0, 0, hBM2, 0, 0, w, h)
  DllCall("DeleteObject", Ptr,hBM2)
  if (!show)
    return
  ;-------------------
  mDC:=DllCall("CreateCompatibleDC", Ptr,0, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  hBrush:=DllCall("CreateSolidBrush", "uint",0xFFFFFF, Ptr)
  oBrush:=DllCall("SelectObject", Ptr,mDC, Ptr,hBrush, Ptr)
  DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",zw, "int",zh
    , Ptr,mDC, "int",0, "int",0, "uint",0xC000CA) ; MERGECOPY
  DllCall("SelectObject", Ptr,mDC, Ptr,oBrush)
  DllCall("DeleteObject", Ptr,hBrush)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteDC", Ptr,mDC)
  ;-------------------
  Gui, FindText_Screen: +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
  Gui, FindText_Screen: Margin, 0, 0
  Gui, FindText_Screen: Add, Pic,, HBITMAP:*%hBM%
  Gui, FindText_Screen: Show, NA x%zx% y%zy% w%zw% h%zh%, Show Pic
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
    Process, Close, % this.pid
  }
  Exec(s, Ahk:="", args:="")
  {
    local
    Ahk:=Ahk ? Ahk:A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
    s:="DllCall(""SetWindowText"",""Ptr"",A_ScriptHwnd,""Str"",""<AHK>"")`n"
      . StrReplace(s,"`r"), pid:=""
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec("""" Ahk """ /f * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`n FileDelete, " f "`n" s
      FileDelete, %f%
      FileAppend, %s%, %f%
      r:=ObjBindMethod(this, "Clear")
      SetTimer, %r%, -3000
      Run, "%Ahk%" /f "%f%" %args%,, UseErrorLevel, pid
    }
    return pid
  }
  Clear()
  {
    FileDelete, % A_Temp "\~ahk.tmp"
    SetTimer,, Off
  }
}

; FindText.QPC() 用法类似于 A_TickCount

QPC()
{
  static f:=0, c:=DllCall("QueryPerformanceFrequency", "Int*",f)
  return (!DllCall("QueryPerformanceCounter","Int64*",c))*0+(c/f)*1000
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
  if (ok:=this.FindText(x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll))
  {
    rx:=ok.1.x-dx, ry:=ok.1.y-dy, ErrorLevel:=0
    return 1
  }
  else
  {
    rx:=ry:="", ErrorLevel:=1
    return 0
  }
}


/***** 机器码的 C语言 源代码 *****

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride, int zw, int zh
  , int sx, int sy, int sw, int sh
  , char * ss, unsigned int * s1, unsigned int * s0
  , char * text, int w, int h, int err1, int err0
  , unsigned int * allpos, int allpos_max )
{
  int ok=0, o, i, j, k, v, r, g, b, rr, gg, bb;
  int x, y, x1, y1, x2, y2, len1, len0, e1, e0, max;
  int r_min, r_max, g_min, g_max, b_min, b_max, x3, y3;
  unsigned char * gs;
  //----------------------
  // 找多色、找单色、搜图模式
  if (mode==5)
  {
    max=n; v=c*c;
    for (i=0, k=0, c=0, o=0; (j=text[o++])!='\0';)
    {
      if (j>='0' && j<='9') c=c*10+(j-'0');
      if (j=='/' || text[o]=='\0')
      {
        if (k=!k)
          s1[i]=(c>>16)*Stride+(c&0xFFFF)*4;
        else
          s0[i++]=c;
        c=0;
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
      i=(mode==3) ? y*Stride+x*4 : y*sw+x;
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
  if (mode==3) goto StartLookUp;
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
    gs=(unsigned char *)(ss+sw*sh);
    x2=sx+sw; y2=sy+sh;
    for (y=sy-1; y<=y2; y++)
    {
      for (x=sx-1; x<=x2; x++, i++)
        if (x<0 || x>=zw || y<0 || y>=zh)
          gs[i]=0;
        else
        {
          o=y*Stride+x*4;
          gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
        }
    }
    k=sw+2; i=0;
    for (y=1; y<=sh; y++)
      for (x=1; x<=sw; x++, i++)
      {
        o=y*k+x; n=gs[o]+c;
        ss[i]=(gs[o-1]>n || gs[o+1]>n
          || gs[o-k]>n   || gs[o+k]>n
          || gs[o-k-1]>n || gs[o-k+1]>n
          || gs[o+k-1]>n || gs[o+k+1]>n) ? 1:0;
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
  if (mode==5 || mode==3)
    { x1=sx; y1=sy; x2=sx+sw-w; y2=sy+sh-h; sx=0; sy=0; }
  else
    { x1=0; y1=0; x2=sw-w; y2=sh-h; }
  if (dir<1 || dir>8) dir=1;
  // 1 ==> Top to Bottom ( Left to Right )
  // 2 ==> Top to Bottom ( Right to Left )
  // 3 ==> Bottom to Top ( Left to Right )
  // 4 ==> Bottom to Top ( Right to Left )
  // 5 ==> Left to Right ( Top to Bottom )
  // 6 ==> Left to Right ( Bottom to Top )
  // 7 ==> Right to Left ( Top to Bottom )
  // 8 ==> Right to Left ( Bottom to Top )
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
          if (i<len0 && ss[o+s0[i]]!=0 && (--e0)<0) goto NoMatch;
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


;==== Optional GUI interface ====


Gui(cmd, arg1:="")
{
  local
  static
  global FindText
  local lls, bch, cri
  ListLines, % InStr("|KeyDown|LButtonDown|MouseMove|"
    , "|" cmd "|") ? "Off" : A_ListLines
  static init:=0
  if (!init)
  {
    init:=1
    Gui_:=ObjBindMethod(FindText,"Gui")
    Gui_Off:=ObjBindMethod(FindText,"Gui","Off")
    Gui_Show:=ObjBindMethod(FindText,"Gui","Show")
    Gui_KeyDown:=ObjBindMethod(FindText,"Gui","KeyDown")
    Gui_LButtonDown:=ObjBindMethod(FindText,"Gui","LButtonDown")
    Gui_MouseMove:=ObjBindMethod(FindText,"Gui","MouseMove")
    Gui_ScreenShot:=ObjBindMethod(FindText,"Gui","ScreenShot")
    Gui_ShowPic:=ObjBindMethod(FindText,"Gui","ShowPic")
    Gui_Slider:=ObjBindMethod(FindText,"Gui","Slider")
    Gui_ToolTip:=ObjBindMethod(FindText,"Gui","ToolTip")
    Gui_ToolTipOff:=ObjBindMethod(FindText,"Gui","ToolTipOff")
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
    Menu, Tray, Add, % Lang["1"], %Gui_Show%
    if (!A_IsCompiled and A_LineFile=A_ScriptFullPath)
    {
      Menu, Tray, Default, % Lang["1"]
      Menu, Tray, Click, 1
      Menu, Tray, Icon, Shell32.dll, 23
    }
    Critical, %cri%
    SetBatchLines, %bch%
    if (0)
    {
      FindText_Run:
      Critical
      %Gui_%(A_GuiControl)
      return
    }
  }
  Switch cmd
  {
  Case "Off":
    return (KeyDown:=1)
  Case "Show":
    Gui, FindText_Main: Default
    Gui, Show, Center
    GuiControl, Focus, scr
    return
  Case "MakeCaptureWindow":
    ww:=35, hh:=12, WindowColor:="0xDDEEFF"
    Gui, FindText_Capture: New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Color, %WindowColor%
    Gui, Font, s12, Verdana
    Gui, -Theme
    nW:=71, nH:=25, w:=12, C_:=[], Cid_:=[]
    Loop, % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "" : Mod(i,nW)=1 ? "xm y+1":"x+1"
      Gui, Add, Progress, w%w% h%w% %j% Hwndid
      Control, ExStyle, -0x20000,, ahk_id %id%
      C_[i]:=id, Cid_[id]:=i
    }
    Gui, +Theme
    GuiControlGet, p, Pos, %id%
    w:=pX+pW-15, h:=pY+pH-15
    Gui, Add, Slider, xm w%w% vMySlider1 gFindText_Run Disabled
      +Center Page20 Line10 NoTicks AltSubmit
    Gui, Add, Slider, ym h%h% vMySlider2 gFindText_Run Disabled
      +Center Page20 Line10 NoTicks AltSubmit +Vertical
    GuiControlGet, p, Pos, MySlider2
    k:=pX+pW, MySlider1:=MySlider2:=dx:=dy:=0
    ;--------------
    Gui, Add, Button, xm Hwndid Hidden Section, % Lang["Auto"]
    GuiControlGet, p, Pos, %id%
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    Gui, Add, Button, xm+%i% yp w%w% hp -Wrap vRepU gFindText_Run, % Lang["RepU"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutU gFindText_Run, % Lang["CutU"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutU3 gFindText_Run, % Lang["CutU3"]
    Gui, Add, Button, xm wp hp -Wrap vRepL gFindText_Run, % Lang["RepL"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutL gFindText_Run, % Lang["CutL"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutL3 gFindText_Run, % Lang["CutL3"]
    Gui, Add, Button, x+15 w%pW% hp -Wrap vAuto gFindText_Run, % Lang["Auto"]
    Gui, Add, Button, x+15 w%w% hp -Wrap vRepR gFindText_Run, % Lang["RepR"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutR gFindText_Run, % Lang["CutR"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutR3 gFindText_Run, % Lang["CutR3"]
    Gui, Add, Button, xm+%i% wp hp -Wrap vRepD gFindText_Run, % Lang["RepD"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutD gFindText_Run, % Lang["CutD"]
    Gui, Add, Button, x+0 wp hp -Wrap vCutD3 gFindText_Run, % Lang["CutD3"]
    ;--------------
    Gui, Add, Text, x+80 ys+3 Section, % Lang["SelGray"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelGray ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelColor"]
    Gui, Add, Edit, x+3 yp-3 w120 vSelColor ReadOnly
    Gui, Add, Text, x+15 ys, % Lang["SelR"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelR ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelG"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelG ReadOnly
    Gui, Add, Text, x+5 ys, % Lang["SelB"]
    Gui, Add, Edit, x+3 yp-3 w60 vSelB ReadOnly
    ;--------------
    x:=w*6+pW+15*4, w:=k-x
    Gui, Add, Tab3, x%x% y+15 w%w% -Wrap, % Lang["2"]
    Gui, Tab, 1
    Gui, Add, Text, x+15 y+15, % Lang["Threshold"]
    Gui, Add, Edit, x+15 w100 vThreshold
    Gui, Add, Button, x+15 yp-3 vGray2Two gFindText_Run, % Lang["Gray2Two"]
    Gui, Tab, 2
    Gui, Add, Text, x+15 y+15, % Lang["GrayDiff"]
    Gui, Add, Edit, x+15 w100 vGrayDiff, 50
    Gui, Add, Button, x+15 yp-3 vGrayDiff2Two gFindText_Run, % Lang["GrayDiff2Two"]
    Gui, Tab, 3
    Gui, Add, Text, x+15 y+15, % Lang["Similar1"] " 0"
    Gui, Add, Slider, x+0 w120 vSimilar1 gFindText_Run
      +Center Page1 NoTicks ToolTip, 100
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColor2Two gFindText_Run, % Lang["Color2Two"]
    Gui, Tab, 4
    Gui, Add, Text, x+15 y+15, % Lang["Similar2"] " 0"
    Gui, Add, Slider, x+0 w120 vSimilar2 gFindText_Run
      +Center Page1 NoTicks ToolTip, 100
    Gui, Add, Text, x+0, 100
    Gui, Add, Button, x+15 yp-3 vColorPos2Two gFindText_Run, % Lang["ColorPos2Two"]
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
    Gui, Add, Button, x+15 yp-3 vColorDiff2Two gFindText_Run, % Lang["ColorDiff2Two"]
    Gui, Tab, 6
    Gui, Add, Text, x+10 y+15, % Lang["DiffRGB"]
    Gui, Add, Edit, x+5 w80 vDiffRGB Limit3
    Gui, Add, UpDown, vdRGB Range0-255 Wrap
    Gui, Add, Checkbox, x+15 yp+5 vMultiColor gFindText_Run, % Lang["MultiColor"]
    Gui, Add, Button, x+15 yp-5 vUndo gFindText_Run, % Lang["Undo"]
    Gui, Tab
    ;--------------
    Gui, Add, Button, xm vReset gFindText_Run, % Lang["Reset"]
    Gui, Add, Checkbox, x+15 yp+5 vModify gFindText_Run, % Lang["Modify"]
    Gui, Add, Text, x+30, % Lang["Comment"]
    Gui, Add, Edit, x+5 yp-2 w150 vComment
    Gui, Add, Button, x+30 yp-3 vSplitAdd gFindText_Run, % Lang["SplitAdd"]
    Gui, Add, Button, x+10 vAllAdd gFindText_Run, % Lang["AllAdd"]
    Gui, Add, Button, x+10 wp vOK gFindText_Run, % Lang["OK"]
    Gui, Add, Button, x+10 wp vCancel gCancel, % Lang["Cancel"]
    Gui, Add, Button, xm vBind0 gFindText_Run, % Lang["Bind0"]
    Gui, Add, Button, x+10 vBind1 gFindText_Run, % Lang["Bind1"]
    Gui, Add, Button, x+10 vBind2 gFindText_Run, % Lang["Bind2"]
    Gui, Add, Button, x+10 vBind3 gFindText_Run, % Lang["Bind3"]
    Gui, Add, Button, x+10 vBind4 gFindText_Run, % Lang["Bind4"]
    Gui, Add, Button, x+15 vSave gFindText_Run, % Lang["Save"]
    Gui, Show, Hide, % Lang["3"]
    return
  Case "MakeMainWindow":
    Gui, FindText_Main: New
    Gui, +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
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
    Gui, Add, Text, x+0 w60, %ww%
    Gui, Add, UpDown, vMyww Range1-100, %ww%
    Gui, Add, Text, x+15 ys, % Lang["Myhh"] ": "
    Gui, Add, Text, x+0 w60, %hh%
    Gui, Add, UpDown, vMyhh Hwndid Range1-100, %hh%
    GuiControlGet, p, Pos, %id%
    GuiControl, Move, MyGroup, % "w" (pX+pW) " h" (pH+30)
    x:=pX+pW+15*2
    Gui, Add, Button, x%x% ys-8 w150 vApply gFindText_Run, % Lang["Apply"]
    Gui, Add, Checkbox, x+30 ys vAddFunc, % Lang["AddFunc"] " FindText()"
    Gui, Add, Button, xm y+18 w144 vCutL2 gFindText_Run, % Lang["CutL2"]
    Gui, Add, Button, x+0 wp vCutR2 gFindText_Run, % Lang["CutR2"]
    Gui, Add, Button, x+0 wp vCutU2 gFindText_Run, % Lang["CutU2"]
    Gui, Add, Button, x+0 wp vCutD2 gFindText_Run, % Lang["CutD2"]
    Gui, Add, Button, x+0 wp vUpdate gFindText_Run, % Lang["Update"]
    Gui, Font, s6 bold, Verdana
    Gui, Add, Edit, xm y+10 w720 r20 vMyPic -Wrap
    Gui, Font, s12 norm, Verdana
    Gui, Add, Button, xm w240 vCapture gFindText_Run, % Lang["Capture"]
    Gui, Add, Button, x+0 wp vTest gFindText_Run, % Lang["Test"]
    Gui, Add, Button, x+0 wp vCopy gFindText_Run, % Lang["Copy"]
    Gui, Add, Button, xm y+0 wp vCaptureS gFindText_Run, % Lang["CaptureS"]
    Gui, Add, Button, x+0 wp vGetRange gFindText_Run, % Lang["GetRange"]
    Gui, Add, Button, x+0 wp vTestClip gFindText_Run, % Lang["TestClip"]
    Gui, Font, s12 cBlue, Verdana
    Gui, Add, Edit, xm w720 h350 vscr Hwndhscr -Wrap HScroll
    Gui, Show, Hide, % Lang["4"]
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
      f:=%Gui_%("SelectPic")
      if (f="") or !FileExist(f)
      {
        if (show_gui)
        {
          Gui, FindText_Main: Show
          GuiControl, FindText_Main: Focus, scr
        }
        Exit
      }
      FindText.ShowPic(f)
    }
    ;----------------------
    if GetKeyState("RButton")
      Send {RButton Up}
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    KeyDown:=0, State:=%Gui_%("State")
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *RButton, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines)?"Off":"Off"
    CoordMode, Mouse
    w:=ww, h:=hh, oldx:=oldy:="", r:=StrSplit(Lang["5"],"|")
    if (!show_gui)
      w:=20, h:=8
    Critical, Off
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y, Bind_ID
      if (!show_gui)
      {
        w:=x<=1 ? w-1 : x>=A_ScreenWidth-2 ? w+1:w
        h:=y<=1 ? h-1 : y>=A_ScreenHeight-2 ? h+1:h
        w:=(w<1 ? 1:w), h:=(h<1 ? 1:h)
      }
      %Gui_%("Mini_Show")
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until (KeyDown=1) or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    KeyDown:=0
    px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      %Gui_%("Mini_Show")
      MouseGetPos, x1, y1
      if (oldx=x1 and oldy=y1)
        Continue
      oldx:=x1, oldy:=y1
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until (KeyDown=1) or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    ToolTip
    Critical
    %Gui_%("Mini_Hide")
    ListLines, %lls%
    Hotkey, *RButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    if (ShowScreenShot)
      FindText.ShowPic()
    if (!show_gui)
      return [px-w, py-h, px+w, py+h]
    ;-----------------------
    %Gui_%("getcors", !ShowScreenShot)
    %Gui_%("Reset")
    Gui, FindText_Capture: Default
    Loop, 71
      SendMessage, 0x2001, 0, 0xAAFFFF
        ,, % "ahk_id " C_[71*25+A_Index]
    Loop, 6
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
        . "`nFindText.BindWindow(id" (cors.bind=0 ? "":"," cors.bind)
        . ")  `; " Lang["6"] " FindText.BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      if (!A_IsCompiled)
      {
        FileRead, s, %A_LineFile%
        s:=SubStr(s, s~="i)\n[;=]+ Copy The")
      }
      else s:=""
      GuiControl,, scr, % Result "`n" s
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(FindText.ASCII(Result),"`n")
      Result:=s:=""
    }
    else if (Event="SplitAdd") or (Event="AllAdd")
    {
      GuiControlGet, s,, scr
      i:=j:=0, r:="<[^>\n]*>[^$\n]+\$[\w+/,.\-]+"
      While j:=RegExMatch(s,r,"",j+1)
        i:=InStr(s,"`n",0,j)
      GuiControl,, scr, % SubStr(s,1,i) . Result . SubStr(s,i+1)
      if !InStr(Result,"##")
        GuiControl,, MyPic, % Trim(FindText.ASCII(Result),"`n")
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
    Loop, Files, % A_Temp "\Ahk_ScreenShot\*.bmp"
      Pics.Push(LoadPicture(v:=A_LoopFileFullPath))
      , Names.Push(v), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    if !Pics.Length()
    {
      Pics:="", Names:=""
      SetTimer, %Gui_ToolTip%, Off
      ToolTip
      MsgBox, 4096, Tip, % Lang["15"] " !", 3
      return
    }
    Gui, FindText_SelectPic: New
    Gui, +LastFound +AlwaysOnTop -DPIScale
    Gui, Margin, 15, 15
    Gui, Font, s12, Verdana
    Gui, Add, Pic, HwndhPic w800 h500 +Border, % "HBITMAP:*" Pics.1
    Gui, Add, ListBox, % "x+15 w120 hp vSelectBox gFindText_Run"
      . " AltSubmit 0x100 Choose1", % Trim(s,"|")
    Gui, Add, Button, xm w170 vOK2 gFindText_Run Default, % Lang["OK2"]
    Gui, Add, Button, x+15 wp vCancel2 gCancel, % Lang["Cancel2"]
    Gui, Add, Button, x+15 wp vClearAll gFindText_Run, % Lang["ClearAll"]
    Gui, Add, Button, x+15 wp vOpenDir gFindText_Run, % Lang["OpenDir"]
    Gui, Add, Button, x+15 wp vSavePic gFindText_Run, % Lang["SavePic"]
    GuiControl, Focus, SelectBox
    Gui, Show,, Select ScreenShot
    ;-----------------------
    DetectHiddenWindows, Off
    Critical, Off
    file:=""
    WinWaitClose, % "ahk_id " WinExist()
    Critical
    Gui, Destroy
    Loop, % Pics.Length()
      DllCall("DeleteObject", "Ptr",Pics[A_Index])
    Pics:="", Names:=""
    return file
  Case "SavePic":
    GuiControlGet, SelectBox
    f:=Names[SelectBox]
    Gui, Destroy
    Loop, % Pics.Length()
      DllCall("DeleteObject", "Ptr",Pics[A_Index])
    Pics:="", Names:="", show_gui_bak:=show_gui
    FindText.ShowPic(f)
    Gui, FindText_Screen: +OwnDialogs
    Loop
    {
      pos:=%Gui_%("GetRange")
      MsgBox, 4100, Tip, % Lang["16"] " !"
      IfMsgBox, Yes
        Break
    }
    %Gui_%("ScreenShot"
      , pos.1 "|" pos.2 "|" pos.3 "|" pos.4 "|0")
    FindText.ShowPic()
    if (show_gui_bak)
    {
      GuiControl, FindText_Main: Focus, scr
      Gui, FindText_Main: Show
    }
    Exit
  Case "SelectBox":
    GuiControlGet, SelectBox
    if (Pics[SelectBox])
      GuiControl,, %hPic%, % "HBITMAP:*" Pics[SelectBox]
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
  Case "Mini_Show":
    Gui, FindText_Mini_4: +LastFoundExist
    IfWinNotExist
    {
      Loop, 4
      {
        i:=A_Index
        Gui, FindText_Mini_%i%: +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
        Gui, FindText_Mini_%i%: Show, Hide, Mini
      }
    }
    d:=2, w:=w<0 ? 0:w, h:=h<0 ? 0:h, c:=A_MSec<500 ? "Red":"Blue"
    Loop, 4
    {
      i:=A_Index
      x1:=Floor(i=3 ? x+w+1 : x-w-d)
      y1:=Floor(i=4 ? y+h+1 : y-h-d)
      w1:=Floor(i=1 or i=3 ? d : 2*(w+d)+1)
      h1:=Floor(i=2 or i=4 ? d : 2*(h+d)+1)
      Gui, FindText_Mini_%i%: Color, %c%
      Gui, FindText_Mini_%i%: Show, NA x%x1% y%y1% w%w1% h%h1%
    }
    return
  Case "Mini_Hide":
    Gui, FindText_Mini_4: +Hwndid
    Loop, 4
      Gui, FindText_Mini_%A_Index%: Destroy
    WinWaitClose, ahk_id %id%,, 3
    return
  Case "getcors":
    FindText.xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
    if (w<1 or h<1)
      return
    SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
    if (arg1)
      FindText.ScreenShot()
    cors:=[], gray:=[], k:=0
    ListLines, % (lls:=A_ListLines)?"Off":"Off"
    Loop, %nH%
    {
      j:=py-hh+A_Index-1, i:=px-ww
      Loop, %nW%
        cors[++k]:=c:=FindText.GetColor(i++,j,0)
        , gray[k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    }
    ListLines, %lls%
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
    FindText.xywh2xywh(0,0,0,0,0,0,0,0,x,y,w,h)
    Gui, Show, NA x%x% y%y% w%w% h%h%, GetRange
    ;---------------------
    if GetKeyState("LButton")
      Send {LButton Up}
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    KeyDown:=0, State:=%Gui_%("State",1)
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *LButton, %Gui_Off%, On UseErrorLevel
    Hotkey, *LButton Up, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines)?"Off":"Off"
    CoordMode, Mouse
    oldx:=oldy:="", r:=Lang["7"]
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
    Until (KeyDown=1) or (State!=%Gui_%("State",1))
    KeyDown--
    px:=x, py:=y, oldx:=oldy:=""
    Loop
    {
      Sleep, 50
      MouseGetPos, x, y
      w:=Abs(px-x)//2, h:=Abs(py-y)//2, x:=(px+x)//2, y:=(py+y)//2
      %Gui_%("Mini_Show")
      if (oldx=x and oldy=y)
        Continue
      oldx:=x, oldy:=y
      ToolTip, %r%
    }
    Until (KeyDown=1) or (KeyDown<0 and State=%Gui_%("State",1))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State",1))
      Sleep, 50
    ToolTip
    Critical
    %Gui_%("Mini_Hide")
    ListLines, %lls%
    Hotkey, *LButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, *LButton Up, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    Gui, FindText_GetRange: Destroy
    Clipboard:=p:=(x-w) ", " (y-h) ", " (x+w) ", " (y+h)
    if (!show_gui)
      return StrSplit(p, ",", " ")
    ;---------------------
    Gui, FindText_Main: Default
    GuiControlGet, s,, scr
    if RegExMatch(s, "i)(=\s*FindText\()([^,]*,){4}", r)
    {
      s:=StrReplace(s, r, r1 . p ",", 0, 1)
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
      s:=Clipboard
    if (!A_IsCompiled) and InStr(s,"MCode(") and (cmd="Test")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n" s "`nExitApp`n"
      Thread:= new FindText.Thread(s)
      DetectHiddenWindows, On
      WinWait, % "ahk_class AutoHotkey ahk_pid " Thread.pid,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
      Thread:=""  ; kill the Thread
    }
    else
    {
      Gui, +OwnDialogs
      t:=A_TickCount, n:=150000
      , RegExMatch(s,"<[^>\n]*>[^$\n]+\$[\w+/,.\-]+",k)
      , v:=FindText.FindText(-n, -n, n, n, 0, 0, k)
      , X:=v.1.x, Y:=v.1.y, Comment:=v.1.id
      r:=StrSplit(Lang["8"],"|")
      MsgBox, 4096, Tip, % r.1 ":`t" Round(v.MaxIndex()) "`n`n"
        . r.2 ":`t" (A_TickCount-t) " " r.3 "`n`n"
        . r.4 ":`t" X ", " Y "`n`n"
        . r.5 ":`t" (v ? r.6 " ! " Comment : r.7 " !"), 3
      for i,j in v
        if (i<=2)
          FindText.MouseTip(j.x, j.y)
      v:=""
    }
    ;----------------------
    Gui, Show
    GuiControl, Focus, scr
    return
  Case "Copy":
    Gui, FindText_Main: Default
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      GuiControlGet, s,, scr
      GuiControlGet, r,, AddFunc
      if (r != 1)
        s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
    }
    Clipboard:=RegExReplace(s,"\R","`r`n")
    ;----------------------
    Gui, Hide
    Sleep, 100
    Gui, Show
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
    ;------------------------
    GuiControlGet, Myww
    GuiControlGet, Myhh
    if (Myww!=ww or Myhh!=hh)
    {
      nW:=71, dx:=dy:=0
      Loop, % 71*25
        k:=A_Index, c:=WindowColor, %Gui_%("SetColor")
      ww:=Myww, hh:=Myhh, nW:=2*ww+1, nH:=2*hh+1
      i:=nW>71, j:=nH>25
      Gui, FindText_Capture: Default
      GuiControl, Enable%i%, MySlider1
      GuiControl, Enable%j%, MySlider2
      GuiControl,, MySlider1, % MySlider1:=0
      GuiControl,, MySlider2, % MySlider2:=0
    }
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
    FindText.SavePic(f, StrSplit(arg1,"|")*)
    Gui, FindText_Tip: New
    ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
    Gui, +LastFound +AlwaysOnTop +ToolWindow -Caption -DPIScale +E0x08000020
    Gui, Color, Yellow
    Gui, Font, cRed s48 bold
    Gui, Add, Text,, % Lang["9"]
    WinSet, Transparent, 200
    Gui, Show, NA y0, ScreenShot Tip
    Sleep, 100
    Gui, Destroy
    return
  Case "Bind0","Bind1","Bind2","Bind3","Bind4":
    FindText.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,0))
    if GetKeyState("RButton")
      Send {RButton Up}
    if GetKeyState("Ctrl")
      Send {Ctrl Up}
    KeyDown:=0, State:=%Gui_%("State")
    Gui, FindText_HotkeyIf: New, -Caption +ToolWindow +E0x80000
    Gui, Show, NA x0 y0 w0 h0, FindText_HotkeyIf
    Hotkey, IfWinExist, FindText_HotkeyIf
    Hotkey, *RButton, %Gui_Off%, On UseErrorLevel
    ListLines, % (lls:=A_ListLines)?"Off":"Off"
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
      %Gui_%("Reset"), r:=StrSplit(Lang["10"],"|")
      ToolTip, % r.1 " : " x "," y "`n" r.2
    }
    Until (KeyDown=1) or (State!=%Gui_%("State"))
    timeout:=A_TickCount+3000
    While (A_TickCount<timeout) and (State!=%Gui_%("State"))
      Sleep, 50
    ToolTip
    Critical
    ListLines, %lls%
    Hotkey, *RButton, %Gui_Off%, Off UseErrorLevel
    Hotkey, IfWinExist
    Gui, FindText_HotkeyIf: Destroy
    FindText.BindWindow(0), cors.bind:=bind_mode
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
    Loop, % nW*nH
      c:=(!show[++k] ? WindowColor
      : bg="" ? cors[k] : ascii[k]
      ? "Black":"White"), %Gui_%("SetColor")
    Loop, % nW*(oldx!=dx)
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
    show:=[], ascii:=[], bg:=""
    CutLeft:=CutRight:=CutUp:=CutDown:=k:=0
    Loop, % nW*nH
      show[++k]:=1, c:=cors[k], %Gui_%("SetColor")
    Loop, % cors.CutLeft
      %Gui_%("CutL")
    Loop, % cors.CutRight
      %Gui_%("CutR")
    Loop, % cors.CutUp
      %Gui_%("CutU")
    Loop, % cors.CutDown
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
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutL3":
    Loop, 3
      %Gui_%("CutL")
    return
  Case "RepR":
    if (CutRight<=cors.CutRight)
    or (bg!="" and InStr(color,"**")
    and CutRight=cors.CutRight+1)
      return
    k:=1-CutRight, CutRight--
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("RepColor") : "")
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop, %nH%
      k+=nW, (A_Index>CutUp and A_Index<nH+1-CutDown
        ? %Gui_%("CutColor") : "")
    return
  Case "CutR3":
    Loop, 3
      %Gui_%("CutR")
    return
  Case "RepU":
    if (CutUp<=cors.CutUp)
    or (bg!="" and InStr(color,"**")
    and CutUp=cors.CutUp+1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutU3":
    Loop, 3
      %Gui_%("CutU")
    return
  Case "RepD":
    if (CutDown<=cors.CutDown)
    or (bg!="" and InStr(color,"**")
    and CutDown=cors.CutDown+1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("RepColor") : "")
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop, %nW%
      k++, (A_Index>CutLeft and A_Index<nW+1-CutRight
        ? %Gui_%("CutColor") : "")
    return
  Case "CutD3":
    Loop, 3
      %Gui_%("CutD")
    return
  Case "Gray2Two":
    Gui, FindText_Capture: Default
    GuiControl, Focus, Threshold
    GuiControlGet, Threshold
    if (Threshold="")
    {
      pp:=[]
      Loop, 256
        pp[A_Index-1]:=0
      Loop, % nW*nH
        if (show[A_Index])
          pp[gray[A_Index]]++
      IP:=IS:=0
      Loop, 256
        k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
      Threshold:=Floor(IP/IS)
      Loop, 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop, % LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP-IP1, IS2:=IS-IS1
        if (IS1!=0 and IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      GuiControl,, Threshold, %Threshold%
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop, % nW*nH
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
      MsgBox, 4096, Tip, % Lang["11"] " !", 1
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
    Loop, % nW*nH
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
      MsgBox, 4096, Tip, % Lang["12"] " !", 1
      return
    }
    UsePos:=(cmd="ColorPos2Two") ? 1:0
    GuiControlGet, n,, Similar1
    n:=Round(n/100,2), color:=c "@" n
    , n:=Floor(512*9*255*255*(1-n)*(1-n)), k:=i:=0
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    Loop, % nW*nH
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
      MsgBox, 4096, Tip, % Lang["12"] " !", 1
      return
    }
    GuiControlGet, dR
    GuiControlGet, dG
    GuiControlGet, dB
    rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
    , color:=StrReplace(c "-" n,"0x"), k:=i:=0
    Loop, % nW*nH
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
    ListLines, % (lls:=A_ListLines)?"Off":"Off"
    k:=0
    Loop, %nH%
    {
      v:=""
      Loop, %nW%
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines, %lls%
    return
  Case "Auto":
    %Gui_%("GetTxt")
    if (txt="")
    {
      Gui, FindText_Capture: +OwnDialogs
      MsgBox, 4096, Tip, % Lang["13"] " !", 1
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
      MsgBox, 4096, Tip, % Lang["13"] " !", 1
      return
    }
    if InStr(color,"@") and (UsePos) and (!MultiColor)
    {
      r:=StrSplit(color,"@")
      k:=i:=j:=0
      Loop, % nW*nH
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
        MsgBox, 4096, Tip, % Lang["12"] " !", 1
        return
      }
      color:="#" (j-1) "@" r.2
    }
    GuiControlGet, Comment
    if (cmd="SplitAdd") and (!MultiColor)
    {
      if InStr(color,"#")
      {
        MsgBox, 4096, Tip, % Lang["14"], 3
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop, % w:=nW-CutLeft-CutRight
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
          v:=Format("{:d}",InStr(v,"`n")-1) "." FindText.bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      Gui, Hide
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}",InStr(txt,"`n")-1) "." FindText.bit2base64(txt)
    else
    {
      GuiControlGet, dRGB
      r:=StrSplit(Trim(StrReplace(Result,",","/"),"/"),"/")
      , x:=r.1, y:=r.2, s:="", i:=1
      Loop, % r.MaxIndex()//3
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
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["8"],"|")
    s:="`; #Include <FindText>`n"
    . "`n t1:=A_TickCount, X:=Y:=""""`n" s
    . "`n if (ok:=FindText(" x "-150000, " y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n {"
    . "`n   CoordMode, Mouse"
    . "`n   X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id"
    . "`n   `; Click, `%X`%, `%Y`%"
    . "`n }`n"
    . "`n MsgBox, 4096, Tip, `% """ r.1 ":``t"" Round(ok.MaxIndex())"
    . "`n   . ""``n``n" r.2 ":``t"" (A_TickCount-t1) "" " r.3 """"
    . "`n   . ""``n``n" r.4 ":``t"" X "", "" Y"
    . "`n   . ""``n``n" r.5 ":``t"" (ok ? """ r.6 " !"" : """ r.7 " !"")`n"
    . "`n for i,v in ok"
    . "`n   if (i<=2)"
    . "`n     FindText.MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    Gui, Hide
    return
  Case "Save":
    x:=px-ww+CutLeft, w:=nW-CutLeft-CutRight
    y:=py-hh+CutUp, h:=nH-CutUp-CutDown
    %Gui_%("ScreenShot"
      , x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "KeyDown":
    Critical
    if (A_Gui="FindText_Main" && A_GuiControl="scr")
      SetTimer, %Gui_ShowPic%, -150
    return
  Case "ShowPic":
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    GuiControl, FindText_Main:, MyPic, % Trim(FindText.ASCII(s),"`n")
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
      ToolTip, % Tip_Text[PrevControl ""]
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
    if !RegExMatch(s,"(<[^>]*>[^$]+\$)\d+\.[\w+/]+",r)
      return
    GuiControlGet, v,, MyPic
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s,r,r1 . w "." FindText.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend,, %v%, ahk_id %hscr%
    Control, EditPaste, %s%,, ahk_id %hscr%
    ControlSend,, {Home}, ahk_id %hscr%
    return
  Case "Load_Language_Text":
    s=
    (
Myww       = 宽度 = 调整捕获范围的宽度
Myhh       = 高度 = 调整捕获范围的高度
AddFunc    = 附加 = 将 FindText() 函数代码一起复制
NowHotkey  = 截屏热键 = 当前的截屏热键
SetHotkey1 = = 第一优先级的截屏热键
SetHotkey2 = = 第二优先级的截屏热键
Apply      = 应用 = 应用新的截屏热键和调整后的捕获范围值
CutU2      = 上删 = 裁剪下面编辑框中文字的上边缘
CutL2      = 左删 = 裁剪下面编辑框中文字的左边缘
CutR2      = 右删 = 裁剪下面编辑框中文字的右边缘
CutD2      = 下删 = 裁剪下面编辑框中文字的下边缘
Update     = 更新 = 更新下面编辑框中文字到代码行中
GetRange   = 获取屏幕范围 = 获取屏幕范围到剪贴板并替换代码中的范围
TestClip   = 测试复制的文字 = 测试复制到剪贴板的文字代码
Capture    = 抓图 = 开始屏幕抓图
CaptureS   = 截屏抓图 = 先恢复上一次的截屏到屏幕再开始抓图
Test       = 测试 = 测试生成的代码是否可以找字成功
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
1  = 查找文字工具
2  = 灰度阈值|灰度差值|颜色相似|颜色位置|颜色分量|多色查找
3  = 图像二值化及分割
4  = 抓图生成字库及找字代码
5  = 位置|先点击右键一次\n把鼠标移开\n再点击右键一次
6  = 解绑窗口使用
7  = 请用左键拖动范围\n坐标复制到剪贴板
8  = 找到|时间|毫秒|位置|结果|成功|失败
9  = 截屏成功
10 = 鼠标位置|穿透显示绑定窗口\n点击右键完成抓图
11 = 请先设定灰度差值
12 = 请先选择核心颜色
13 = 请先将图像二值化
14 = 不能用于颜色位置二值化模式, 因为分割后会导致位置错误
15 = 请先设置热键并使用热键抓取屏幕截图
16 = 你确定选择的范围吗？\n\n如果不确定，可以重新选择
    )
    Lang:=[], Tip_Text:=[]
    Loop, Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v,"\n","`n"), "=", "`t ")
        , Lang[r.1 ""]:=r.2, Tip_Text[r.1 ""]:=r.3
    return
  }
}

}  ;// Class End

;================= The End =================

;