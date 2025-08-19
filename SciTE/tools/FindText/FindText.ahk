;/*
;===========================================
;  FindText - 屏幕抓字生成字库工具与找字函数
;  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=17834
;
;  脚本作者 : FeiYue
;  最新版本 : 10.0
;  更新时间 : 2024-10-06
;
;  用法:  (需要最新版本 AHK v1.1.34+)
;  1. 将本脚本保存为“FindText.ahk”并复制到AHK执行程序的Lib子目录中（手动建立目录）
;  2. 抓图并生成调用FindText()的代码
;     2.1 方式一：直接点击“抓图”按钮
;     2.2 方式二：先设定截屏热键，使用热键截屏，再点击“截屏抓图”按钮
;  3. 测试一下调用的代码是否成功:直接点击“测试”按钮
;  4. 复制调用的代码到自己的脚本中
;     4.1 方式一：打勾“附加FindText()函数”的选框，然后点击“复制”按钮（不推荐）
;     4.2 方式二：取消“附加FindText()函数”的选框，然后点击“复制”按钮，
;         然后粘贴到自己的脚本中，然后在自己的脚本开头加上一行:
;         #Include <FindText>  ; Lib目录中必须有FindText.ahk
;  5. 多色查找模式可以一定程度上适应图像的放大缩小，常用于游戏中找图
;  6. 这个库还可以用于快速截屏、获取颜色、写入颜色、编辑后另存图片
;  7. 如果要调用FindTextClass类中的函数，请用无参数的FindText()获取类实例对象
;
;===========================================
;*/


if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
  FindText().Gui("Show")


;===== 复制下面的函数和类到你的代码中仅仅一次 =====


FindText(ByRef x:="FindTextClass", ByRef y:="", args*)
{
  static init, obj
  if !VarSetCapacity(init) && (init:="1")
    obj:=new FindTextClass()
  return (x=="FindTextClass" && !args.Length()) ? obj : obj.FindText(x, y, args*)
}

Class FindTextClass
{  ;// Class Begin

Floor(i)
{
  if i is number
    return i+0
  else return 0
}

__New()
{
  this.bits:={ Scan0: 0, hBM: 0, oldzw: 0, oldzh: 0 }
  this.bind:={ id: 0, mode: 0, oldStyle: 0 }
  this.Lib:=[]
  this.Cursor:=0
}

__Delete()
{
  if (this.bits.hBM)
    Try DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

New()
{
  return new FindTextClass()
}

help()
{
return "
(
;--------------------------------
;  FindText - 屏幕找字函数
;  版本 : 10.0  (2024-10-06)
;--------------------------------
;  返回变量:=FindText(
;      OutputX --> 保存返回的X坐标的变量名称
;    , OutputY --> 保存返回的Y坐标的变量名称
;    , X1 --> 查找范围的左上角X坐标
;    , Y1 --> 查找范围的左上角Y坐标
;    , X2 --> 查找范围的右下角X坐标
;    , Y2 --> 查找范围的右下角Y坐标
;    , err1 --> 文字的黑点容错百分率（0.1=10%）
;    , err0 --> 背景的白点容错百分率（0.1=10%）
;      设置 err1<0 或 err0<0 可以打开左右膨胀算法
;      忽略文字线条的轻微错位，此时容错值应该非常小
;      在找图模式中，err0 可以设置要跳过的行列数，加快速度
;    , Text --> 由工具生成的查找图像的数据，可以一次查找多个，用“|”分隔
;    , ScreenShot --> 是否截屏，为0则使用上一次的截屏数据
;    , FindAll --> 是否搜索所有位置，为0则找到一个位置就返回
;    , JoinText --> 如果想组合查找，可以为1，或者是要查找单词的数组
;    , offsetX --> 组合图像的每个字和前一个字的最大横向间隔
;    , offsetY --> 组合图像的每个字和前一个字的最大高低间隔
;    , dir --> 查找的方向，有上、下、左、右、中心9种
;      默认 dir=0，这种返回的结果将按最小误差排序，
;      即使设置了较大的容错，第一个结果也是误差最小的
;    , zoomW --> 图像宽度的缩放百分率（1.0=100%）
;    , zoomH --> 图像高度的缩放百分率（1.0=100%）
;  )
;
;  返回变量 --> 如果没找到结果会返回0。否则返回一个二级数组，
;      第一级是每个结果对象，第二级是结果对象的具体信息对象:
;      { 1:左上角X, 2:左上角Y, 3:图像宽度W, 4:图像高度H
;        , x:中心点X, y:中心点Y, id:图像识别文本 }
;  所有坐标都是相对于屏幕，颜色使用RGB格式
;  所有 RRGGBB 可以使用 Black、White、Red、Green、Blue 代替，
;  所有 DRDGDB 可以使用相似度 1.0（100%） 代替，它是浮点数
;
;  如果 OutputX 等于 'wait' 或 'wait1' 意味着等待图像出现，
;  如果 OutputX 等于 'wait0' 意味着等待图像消失
;  此时 OutputY 设置等待时间的秒数，如果小于0则无限等待
;  如果超时则返回0，意味着失败，如果等待图像出现成功，则返回位置数组
;  如果等待图像消失成功，则返回 1
;  例1: FindText(X:='wait', Y:=3, 0,0,0,0,0,0,Text)   ; 等待3秒等图像出现
;  例2: FindText(X:='wait0', Y:=-1, 0,0,0,0,0,0,Text) ; 无限等待等图像消失
;
;  <FindMultiColor> 或 <FindColor> : 找色 是仅有一个点的 多点找色
;  Text:='|<>##DRDGDB $ 0/0/RRGGBB1-DRDGDB1/RRGGBB2, xn/yn/-RRGGBB3/RRGGBB4, ...'
;  '##'之后的颜色 (0xDRDGDB) 是所有颜色的默认偏色（各个分量允许的变化值）
;  初始点 (0,0) 匹配 0xRRGGBB1(+/-0xDRDGDB1) 或者 0xRRGGBB2(+/-0xDRDGDB)，
;  点 (xn,yn) 匹配 排除 0xRRGGBB3(+/-0xDRDGDB) 和排除 0xRRGGBB4(+/-0xDRDGDB)
;  点坐标后面以 '-' 开头表示要排除后面的所有颜色，其他颜色都匹配
;  每个点最多允许匹配10组颜色 (xn/yn/RRGGBB1/.../RRGGBB10)
;
;  <FindShape> : 类似于 FindMultiColor，仅是把具体颜色替换为
;  这一点的颜色是否与第一点的颜色是否相似
;  Text:='|<>##DRDGDB $ 0/0/1, x1/y1/0, x2/y2/1, xn/yn/0, ...'
;
;  <FindPic> : Text 参数需要手动输入
;  Text:='|<>##DRDGDB/RRGGBB1-DRDGDB1/RRGGBB2... $ d:\a.bmp'
;  '##'之后的颜色 (0xDRDGDB) 是所有颜色的默认偏色（各个分量允许的变化值）
;  这个 0xRRGGBB1(+/-0xDRDGDB1) 和 0xRRGGBB2(+/-0xDRDGDB)... 都是透明色
;
;--------------------------------
)"
}

FindText(ByRef OutputX:="", ByRef OutputY:=""
  , x1:=0, y1:=0, x2:=0, y2:=0, err1:=0, err0:=0, text:=""
  , ScreenShot:=1, FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10
  , dir:=0, zoomW:=1, zoomH:=1)
{
  local
  if (OutputX ~= "i)^\s*wait[10]?\s*$")
  {
    found:=!InStr(OutputX,"0"), time:=this.Floor(OutputY)
    , timeout:=A_TickCount+Round(time*1000), OutputX:=""
    Loop
    {
      ok:=this.FindText(,, x1, y1, x2, y2, err1, err0, text, ScreenShot
        , FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH)
      if (found && ok)
      {
        OutputX:=ok[1].x, OutputY:=ok[1].y
        return ok
      }
      if (!found && !ok)
        return 1
      if (time>=0 && A_TickCount>=timeout)
        Break
      Sleep 50
    }
    return 0
  }
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  , this.ok:=0, info:=[]
  Loop Parse, text, |
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 || h<1 || !(num:=info.Length()) || !bits.Scan0)
  {
    SetBatchLines % bch
    return 0
  }
  arr:=[], info2:=[], k:=0, s:=""
  , mode:=(IsObject(JoinText) ? 2 : JoinText ? 1 : 0)
  For i,j in info
  {
    k:=Max(k, (j[7]=5 && j[8]!=2 ? j[9] : j[2]*j[3]))
    if (mode)
      v:=(mode=1 ? i : j[10]) . "", s.="|" v
      , (v!="") && ((!info2.HasKey(v) && info2[v]:=[]), info2[v].Push(j))
  }
  sx:=x, sy:=y, sw:=w, sh:=h, (mode=1 && JoinText:=[s])
  , allpos_max:=(FindAll || JoinText ? 10000:1)
  , VarSetCapacity(s1,k*4), VarSetCapacity(s0,k*4)
  , VarSetCapacity(ss,sw*(sh+3)), VarSetCapacity(allpos,allpos_max*8)
  , ini:={ sx:sx, sy:sy, sw:sw, sh:sh, zx:zx, zy:zy
  , mode:mode, bits:bits, ss:&ss, s1:&s1, s0:&s0
  , allpos:&allpos, allpos_max:allpos_max
  , err1:err1, err0:err0, zoomW:zoomW, zoomH:zoomH }
  Loop 2
  {
    if (err1=0 && err0=0) && (num>1 || A_Index>1)
      ini.err1:=err1:=0.05, ini.err0:=err0:=0.05
    if (!JoinText)
    {
      For i,j in info
      Loop % this.PicFind(ini, j, dir, sx, sy, sw, sh)
      {
        v:=NumGet(allpos,4*A_Index-4,"uint"), x:=(v&0xFFFF)+zx, y:=(v>>16)+zy
        , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
        , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:j[10]})
        if (!FindAll)
          Break 3
      }
    }
    else
    For k,v in JoinText
    {
      v:=StrSplit(Trim(RegExReplace(v, "\s*\|[|\s]*", "|"), "|")
      , (InStr(v,"|")?"|":""), " `t")
      , this.JoinText(arr, ini, info2, v, 1, offsetX, offsetY
      , FindAll, dir, 0, 0, 0, sx, sy, sw, sh)
      if (!FindAll && arr.Length())
        Break 2
    }
    if (err1!=0 || err0!=0 || arr.Length() || info[1][4] || info[1][7]=5)
      Break
  }
  SetBatchLines % bch
  if (arr.Length())
  {
    OutputX:=arr[1].x, OutputY:=arr[1].y, this.ok:=arr
    return arr
  }
  return 0
}

; the join text object use [ "abc", "xyz", "a1|a2|a3" ]

JoinText(arr, ini, info2, text, index, offsetX, offsetY
  , FindAll, dir, minX, minY, maxY, sx, sy, sw, sh)
{
  local
  if !(Len:=text.Length()) || !info2.HasKey(key:=text[index])
    return 0
  zoomW:=ini.zoomW, zoomH:=ini.zoomH, mode:=ini.mode
  For i,j in info2[key]
  if (mode!=2 || key==j[10])
  Loop % ok:=this.PicFind(ini, j, dir, sx, sy, (index=1 ? sw
  : Min(sx+offsetX+Floor(j[2]*zoomW),ini.sx+ini.sw)-sx), sh)
  {
    if (A_Index=1)
    {
      pos:=[], p:=ini.allpos-4
      Loop % ok
        pos.Push(NumGet(0|p+=4,"uint"))
    }
    v:=pos[A_Index], x:=v&0xFFFF, y:=v>>16
    , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
    , (index=1 && (minX:=x, minY:=y, maxY:=y+h))
    , minY1:=Min(y, minY), maxY1:=Max(y+h, maxY), sx1:=x+w
    if (index<Len)
    {
      sy1:=Max(minY1-offsetY, ini.sy)
      , sh1:=Min(maxY1+offsetY, ini.sy+ini.sh)-sy1
      if this.JoinText(arr, ini, info2, text, index+1, offsetX, offsetY
      , FindAll, 5, minX, minY1, maxY1, sx1, sy1, 0, sh1)
      && (index>1 || !FindAll)
        return 1
    }
    else
    {
      comment:=""
      For k,v in text
        comment.=(mode=2 ? v : info2[v][1][10])
      x:=minX+ini.zx, y:=minY1+ini.zy, w:=sx1-minX, h:=maxY1-minY1
      , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
      if (index>1 || !FindAll)
        return 1
    }
  }
  return 0
}

PicFind(ini, j, dir, sx, sy, sw, sh)
{
  local
  static init, MyFunc
  if !VarSetCapacity(init) && (init:="1")
  {
    x32:="VVdWU4HsmAAAAIuEJNQAAAADhCTMAAAAi5wk@AAAAIO8JKwAAAAFiUQkIIuEJPgA"
    . "AACNBJiJRCQ0D4RKBgAAi4Qk6AAAAIXAD45ADwAAiXwkEIu8JOQAAAAx7ccEJAAA"
    . "AADHRCQIAAAAAMdEJBQAAAAAx0QkDAAAAACNtgAAAACLhCTgAAAAi0wkDDH2MdsB"
    . "yIX@iUQkBH896ZAAAABmkA+vhCTMAAAAicGJ8Jn3@wHBi0QkBIA8GDF0TIuEJNwA"
    . "AACDwwEDtCQAAQAAiQyog8UBOd90VIsEJJn3vCToAAAAg7wkrAAAAAR1tQ+vhCTA"
    . "AAAAicGJ8Jn3@40MgYtEJASAPBgxdbSLRCQUi5Qk2AAAAIPDAQO0JAABAACJDIKD"
    . "wAE534lEJBR1rAF8JAyDRCQIAYu0JAQBAACLRCQIATQkOYQk6AAAAA+FMv@@@4tE"
    . "JBSLfCQQD6+EJOwAAACJbCQwwfgKiUQkKIuEJPAAAAAPr8XB+AqJRCRAg7wkrAAA"
    . "AAQPhCIGAACLhCTAAAAAi5wkxAAAAA+vhCTIAAAAjSyYi4QkzAAAAIucJMAAAAD3"
    . "2IO8JKwAAAABjQSDiUQkLA+ELwYAAIO8JKwAAAACD4Q4CAAAg7wkrAAAAAMPhLkL"
    . "AACLjCTQAAAAhckPjicBAACLhCTMAAAAi6wkzAAAAMdEJAwAAAAAx0QkEAAAAACJ"
    . "fCQYg+gBiUQkCI22AAAAAIt8JBCLtCTUAAAAMcCLXCQgAfsB94Xtif6J738X6bwA"
    . "AADGBAYEg8ABg8MBOccPhKQAAACDvCSsAAAAA3@khcAPtgsPhLoPAAAPtlP@iVQk"
    . "BDlEJAgPhMIPAAAPtlMBiRQki5Qk9AAAAIXSD4SfAQAAD7bpugYAAACD7QGD@QF2"
    . "G4N8JAQBD5TCgzwkAYnVD5TCCeoPttIB0oPKBIHh@QAAAL0BAAAAdByLTCQEiywk"
    . "hckPlEQkBIXtD5TBic0PtkwkBAnNCeqDwwGIFAaDwAE5xw+FXP@@@wF8JBCJ@YNE"
    . "JAwBi0QkDDmEJNAAAAAPjwz@@@+LfCQYg7wkrAAAAAN@FouEJPQAAACFwA+VwDwB"
    . "g5wkxAAAAP+LXCQUi3QkKDHAOfOLdCRAD07YiVwkFItcJDA58w9Pw4lEJDCLhCTM"
    . "AAAAK4QkAAEAAIlEJASLhCTQAAAAK4QkBAEAAIO8JLgAAAAJiUQkCA+ExgAAAIuE"
    . "JLgAAACD6AGD+AcPh7wCAACD+AOJRCQkD463AgAAi0QkBMdEJEQAAAAAx0QkDAAA"
    . "AACJBCSLRCQIiUQkHItcJEQ5HCTHRCRMAAAAAA+MCwEAAItcJEw5XCQcD4zCDQAA"
    . "i3QkRItcJCSLBCQp8PbDAg9Exot0JEyJwotEJBwp8PbDAQ9ExoP7A4nWD0@wD0@C"
    . "iXQkGIlEJBDp3gsAAI12AA+20YPqAYP6AhnSg+ICg8IEgeH9AAAAD5TBCcqIFAbp"
    . "8v3@@4tcJASLdCQIx0QkZAAAAADHRCRgAQAAAMdEJFQAAAAAx0QkWAAAAACJ2I1W"
    . "AYk0JMHoH4lcJBzHRCQMAAAAAAHY0fiJRCQQifDB6B8B8NH4iUQkGInYg8ABicEP"
    . "r8o50A9MwoPACIlMJHyJwQ+vyImMJIAAAACLXCR8OVwkZH0Zi5wkgAAAADlcJFjH"
    . "RCRcAAAAAA+M9QQAAIuMJLgAAACFyQ+FnQIAAIuUJPgAAACF0g+EjgIAAIuEJAQB"
    . "AAAPr4QkAAEAAIP4AQ+EdgIAAIN8JAwBD46lCgAAi0QkNIucJPgAAAAx7cdEJAQA"
    . "AAAAiSwkjXgEi0QkDIPoAYlEJBCLRCQEiwwkizeLRAMEhcmJRCQIich4NotP@DnO"
    . "D4N1BQAAifqNa@zrDY12AIPqBItK@DnOcxeJCotMhQSJTIMEg+gBg@j@deS4@@@@"
    . "@4tMJDSDwAGDBCQBg8cEg0QkBASJNIGLdCQIiTSDiwQkO0QkEHWNi4QkBAEAAIus"
    . "JAABAAAPr8APr+2JRCQEi7Qk+AAAAMdEJAgAAAAAMduLRCQIiwSGiUQkEA+3+MHo"
    . "EIXbiQQkdC0xyY22AAAAAIsUjg+3win4D6@AOeh9D8HqECsUJA+v0jtUJAR8EYPB"
    . "ATnZdduLRCQQiQSeg8MBg0QkCAGLRCQIOUQkDHWiidiBxJgAAABbXl9dwlwAx0Qk"
    . "JAAAAACLRCQIx0QkRAAAAADHRCQMAAAAAIkEJItEJASJRCQc6UT9@@8xwIO8JLAA"
    . "AAACD5TAiYQkhAAAAA+EUAQAADHAg7wksAAAAAGLrCS0AAAAD5TAhe2JRCR4D4SG"
    . "CwAAi7Qk2AAAAIuUJLQAAAAx7YucJOAAAACLjCTcAAAAiXwkCI0ElolEJASNdCYA"
    . "izuDxgSDw1iDwQSJ+MHoEA+vhCQEAQAAmfe8JOgAAAAPr4QkwAAAAIkEJA+3xw+v"
    . "hCQAAQAAmfe8JOQAAACLFCSNBIKJRvyLQ6yNREUAg8UWiUH8O3QkBHWmi4QktAAA"
    . "AIm8JLAAAACLfCQIiUQkFIuEJOwAAAAPr4QktAAAAMH4ColEJCiLhCTgAAAAx0Qk"
    . "QAAAAADHRCQwAAAAAIPACIlEJFDpSfr@@4tEJAyBxJgAAABbXl9dwlwAi4QksAAA"
    . "AMHoEA+vhCQEAQAAmfe8JOgAAAAPr4QkwAAAAInBD7eEJLAAAAAPr4QkAAEAAJn3"
    . "vCTkAAAAjQSBiYQksAAAAOnt+f@@i4Qk6AAAAIu0JNAAAAAPr4Qk5AAAANGkJLQA"
    . "AAADhCTgAAAAhfaJRCRQD47z+v@@i4QkzAAAAInqi2wkUMdEJCQAAAAAx0QkOAAA"
    . "AADB4AKJRCRIMcCLnCTMAAAAhdsPjisBAACLnCS8AAAAAdMDVCRIiVwkEItcJCAD"
    . "XCQ4iVQkPAOUJLwAAACJXCQYiVQkHI12AI28JwAAAACLdCQQMds5nCS0AAAAD7ZO"
    . "AolMJAQPtk4BD7Y2iUwkCIl0JAx2W412AI28JwAAAACLRJ0Ag8MCi3yd@InCD7bM"
    . "D7bAK0QkDMHqECtMJAgPttIrVCQEgf@@@@8AiQQkdyUPr9IPr8mNFFIPr8CNFIqN"
    . "BEI5x3NGMcA5nCS0AAAAd6+JwutBif7B7hCJ8A+28A+v0g+v9jnyd92J+A+21A+v"
    . "yQ+v0jnRd86LNCSJ+A+20A+v0onwD6@GOdB3uroBAAAAuAEAAACLXCQYg0QkEASL"
    . "TCQQiBODwwE7TCQciVwkGA+FGv@@@4u0JMwAAAABdCQ4i1QkPINEJCQBA1QkLItc"
    . "JCQ5nCTQAAAAD4Ws@v@@6U34@@+LRCQQhcB4G4tcJBw52H8Ti0QkGIXAeAuLHCQ5"
    . "2A+ONwYAAItsJFSF7Q+F4AUAAINsJBgBg0QkXAGDRCRYAYt0JGA5dCRcfLiLXCRU"
    . "idiD4AEBxonYg8ABiXQkYIPgA4lEJFTpvvr@@4uEJLAAAACLjCTQAAAAxwQkAAAA"
    . "AMdEJAQAAAAAg8ABweAHiYQksAAAAIuEJMwAAADB4AKFyYlEJAwPjsz4@@+J6Ius"
    . "JLAAAACJfCQQi5QkzAAAAIXSfmaLjCS8AAAAi1wkIIu8JLwAAAADXCQEAcEDRCQM"
    . "iUQkCAHHjXYAjbwnAAAAAA+2UQIPtkEBD7Yxa8BLa9ImAcKJ8MHgBCnwAdA5xQ+X"
    . "A4PBBIPDATn5ddWLnCTMAAAAAVwkBItEJAiDBCQBA0QkLIs8JDm8JNAAAAAPhXf@"
    . "@@+LfCQQ6Qb3@@+LBCTprvr@@4uEJOgAAACLvCTgAAAAD6+EJOQAAADRpCS0AAAA"
    . "jQSHiUQkUIuEJPAAAADB+AqDwAGJRCQki4Qk6AAAAIXAD45ECgAAi3wkJIuEJAQB"
    . "AACLdCRQx0QkMAAAAADHRCQUAAAAAA+vx4lEJECLhCTkAAAAD6@HweACiUQkSIuE"
    . "JOAAAACDwAKJRCQ4ifiNPL0AAAAAiXwkLInHD6+EJAABAACJfCQ8iUQkKIuEJOQA"
    . "AACFwA+OaQEAAItEJDjHRCQcAAAAAIlEJBCLRCQkiUQkGItEJBC7AgAAAA+2OIk8"
    . "JA+2eP8PtkD+iXwkBIlEJAg5nCS0AAAAD4bCAAAAiwSeg8MCi3ye@InCD7bMD7bA"
    . "K0QkCMHqECtMJAQPttIrFCSB@@@@@wCJRCQMd0YPr9IPr8mNFFIPr8CNFIqNBEI5"
    . "x3Kui3wkGItEJCSLTCQsAUwkEItMJCgBTCQcAfg5vCTkAAAAD465AAAAiUQkGOlf"
    . "@@@@if3B7RCJ6A+26A+v0g+v7TnqD4dm@@@@ifgPttQPr8kPr9I50Q+HU@@@@4tM"
    . "JAyJ+A+2+A+v@4nID6@BOfh2kDmcJLQAAAAPhz7@@@+LRCQwi3wkFJmNHL0AAAAA"
    . "97wk6AAAAA+vhCTAAAAAicGLRCQcmfe8JOQAAACLFCTB4hCNBIGLjCTYAAAAiQS5"
    . "i0QkBIPHAYl8JBSLvCTcAAAAweAICdALRCQIiQQf6SD@@@+LfCQ8i0QkJItMJEAB"
    . "TCQwi0wkSAFMJDgB+Dm8JOgAAAB+CYlEJDzpXP7@@4tEJBQPr4Qk7AAAAMH4ColE"
    . "JCiLRCRQx0QkQAAAAADHRCQwAAAAAIt4BIn4ifvB6BAPtteJ+w+2wA+2y4nDD6@Y"
    . "idAPr8KJXCRwiUQkdInID6@BiUQkbOlH9P@@i4Qk0AAAAIXAD45u9f@@i5wkzAAA"
    . "AItEJCDHBCQAAAAAx0QkBAAAAACJfCQMjQRYiUQkGInYweACiUQkCIu0JMwAAACF"
    . "9n5Xi4wkvAAAAItcJBiLvCS8AAAAA1wkBAHpA2wkCAHvD7ZRAoPBBIPDAWvyJg+2"
    . "Uf1rwkuNFAYPtnH8ifDB4AQp8AHQwfgHiEP@Ofl10ou8JMwAAAABfCQEgwQkAQNs"
    . "JCyLBCQ5hCTQAAAAdYqLhCTMAAAAi3wkDDHti5QktAAAADH2g+gBiXwkJIlEJAyL"
    . "hCTQAAAAg+gBiUQkEIucJMwAAACF2w+O4gAAAIu8JMwAAACLRCQYAfeNDDCJ+4l8"
    . "JByJxwHfifMrnCTMAAAAiXwkBIt8JCABwwH3McCJfCQIiRwkhcAPhGQDAAA5RCQM"
    . "D4RaAwAAhe0PhFIDAAA5bCQQD4RIAwAAD7YRD7Z5@74BAAAAA5QksAAAADn6ckYP"
    . "tnkBOfpyPos8JA+2Pzn6cjSLXCQED7Y7OfpyKYs8JA+2f@85+nIeizwkD7Z@ATn6"
    . "chMPtnv@OfpyCw+2cwE58g+Sw4nei3wkCInziBwHg8ABg8EBg0QkBAGDBCQBOYQk"
    . "zAAAAA+FWv@@@4t0JByDxQE5rCTQAAAAD4X@@v@@i3wkJImUJLQAAADpY@L@@8dE"
    . "JEAAAAAAx0QkKAAAAADHRCQwAAAAAMdEJBQAAAAA6cfx@@+DfCRUAQ+E6gEAAIN8"
    . "JFQCD4SVAgAAg2wkEAHpBfr@@4uEJAQBAACLrCQAAQAAD6@AD6@tiUQkBItEJAyF"
    . "wA+P6PX@@zHA6VL2@@+DRCRkAcdEJCQJAAAAi0QkGIucJNQAAAAPr4QkzAAAAANE"
    . "JBCAPAMDD4ZnAQAAi3QkFItcJDA53g9N3oO8JKwAAAADiVwkIA+OdQEAAItEJBgD"
    . "hCTIAAAAD6+EJMAAAACLVCQQA5QkxAAAAIO8JKwAAAAFD4RsAgAAjTSQi4QksAAA"
    . "AIucJLwAAAAB8A+2XAMCiVwkOIucJLwAAAAPtlwDAYlcJDyLnCS8AAAAD7YEA4lE"
    . "JEiLRCQghcAPhKoBAACLRCRAiXwkLDHbi2wkKIu8JLwAAACJRCRo62KNtCYAAAAA"
    . "OVwkMH5Ii4Qk3AAAAIsUmAHyD7ZEFwIPtkwXAStEJDgrTCQ8D7YUFytUJEgPr8AP"
    . "r8mNBEAPr9KNBIiNBFA5hCS0AAAAcgeDbCRoAXhhg8MBOVwkIA+EogEAADlcJBR+"
    . "n4uEJNgAAACLFJgB8g+2RBcCD7ZMFwErRCQ4K0wkPA+2FBcrVCRID6@AD6@JjQRA"
    . "D6@SjQSIjQRQOYQktAAAAA+DWv@@@4PtAQ+JUf@@@4t8JCyDfCQkCQ+EKfj@@4NE"
    . "JEwB6Try@@+DRCQQAekm+P@@g0QkRAHpEfL@@410JgCF2w+EoAAAAAOEJNQAAACL"
    . "XCRAMdKLbCQoicHrJTlUJDB+Fou0JNwAAACLBJYByPYAAXUFg+sBeJqDwgE5VCQg"
    . "dGo5VCQUftWLtCTYAAAAiwSWAcj2AAJ1xIPtAXm@6XD@@@@HRCQEAwAAAOlB8P@@"
    . "i3wkCMYEBwLpEf3@@8cEJAMAAADpOfD@@8dEJCgAAAAAx0QkFAAAAADpGPX@@4NE"
    . "JBgB6XD3@@+LbCQoi4Qk+AAAAINEJAwBhcAPhMoDAACLVCQYA5QkyAAAAItcJAyL"
    . "RCQQA4QkxAAAAIu0JPgAAADB4hCNi@@@@z8J0IkEjou0JLgAAACF9g+F0gIAAItE"
    . "JCiLdCQ0Keg5nCT8AAAAiQSOD44z8v@@6bb+@@+LfCQs64mLtCSEAAAAjQSQiUQk"
    . "PIX2D4WuAQAAi1wkIItEJFAx9otsJCiF24lEJGgPhFn@@@+LhCTYAAAAi1wkaItU"
    . "JDwDFLCJXCRIa8YWgTv@@@8AiUQkOA+XwA+2wIlEJCyLhCTcAAAAiwSwiYQktAAA"
    . "AIuEJLwAAAAPtkQQAomEJIwAAADB4BCJwYuEJLwAAAAPtkQQAYmEJJAAAADB4AgJ"
    . "yIuMJLwAAAAPtgwRCciJjCSUAAAAiYQkiAAAAOsfD6@SD6@JjRRSD6@AjRSKjQRC"
    . "OccPg70AAACDRCRICItEJDg7hCS0AAAAD4PPAAAAi1QkeIt8JEiDRCQ4AoXSiweL"
    . "fwR0JoX2i5wkiAAAAA9FnCSwAAAAhcAPlMAPtsCJRCQsiZwksAAAAInYicIPtswP"
    . "tsDB6hArjCSQAAAAK4QklAAAAA+20iuUJIwAAACB@@@@@wAPhmX@@@+J+8HrEA+2"
    . "2w+v0g+v2znaD4dp@@@@ifsPttcPr8kPr9I50Q+HVv@@@4n7D7bTD6@AD6@SOdAP"
    . "h0P@@@+LRCQshcB0CYPtAQ+IDf3@@4PGAYNEJGhYOXQkIA+Fe@7@@+nP@f@@i0Qk"
    . "LIXAdeHr1otMJCCLbCQohckPhLX9@@8x9usuOUQkcHwSD6@JOUwkdHwJD6@SOVQk"
    . "bH0Jg+0BD4i3@P@@g8YBOXQkIA+Eg@3@@4uEJNgAAACLVCQ8i5wkvAAAAAMUsIuE"
    . "JNwAAACLBLCJhCSwAAAAi4QkvAAAAIuMJLAAAAAPtkQQAsHpEA+2ySnID7ZMEwGL"
    . "nCSwAAAAD6@AD7bfKdmLnCS8AAAAD7YUEw+2nCSwAAAAKdqB@@@@@wAPh1z@@@8P"
    . "r8mNBEAPr9KNBIiNBFA5xw+CXf@@@+lh@@@@x0QkKAAAAADHRCQUAAAAAOnC9@@@"
    . "i1wkDDmcJPwAAACJ2A+OrfD@@4tcJBgxyYnOidgrhCQEAQAAg8ABD0jBicKJ2Iuc"
    . "JAQBAACNRBj@i1wkCDnDD07Di1wkEInFidgrhCQAAQAAg8ABD0nwidiLnCQAAQAA"
    . "jUQY@4tcJAQ5ww9OwznVicMPjIz7@@+LhCTMAAAAg8UBD6@CA4Qk1AAAAInBjUMB"
    . "iUQkIDnefw+J8IAkAQODwAE7RCQgdfODwgEDjCTMAAAAOep13+lJ+@@@i6wkuAAA"
    . "AIXtD4VK@@@@6TX7@@+QkA=="
    x64:="QVdBVkFVQVRVV1ZTSIHsyAAAAEhjhCRQAQAASIu8JKgBAACJjCQQAQAAiVQkMESJ"
    . "jCQoAQAAi7QkgAEAAIusJIgBAABJicRIiUQkWEgDhCRgAQAAg@kFSIlEJChIY4Qk"
    . "sAEAAEiNBIdIiUQkYA+E3AUAAIXtD44BDAAARTH2iVwkEIu8JLgBAABEiXQkCIuc"
    . "JBABAABFMe1Mi7QkcAEAAEUx20Ux@0SJbCQYRImEJCABAABMY1QkCEUxyUUxwEwD"
    . "lCR4AQAAhfZ@Mut3Dx9AAEEPr8SJwUSJyJn3@gHBQ4A8AjF0PEmDwAFJY8dBAflB"
    . "g8cBRDnGQYkMhn5DRInYmff9g@sEdckPr4QkOAEAAInBRInImff+Q4A8AjGNDIF1"
    . "xEiLlCRoAQAASYPAAUljxUEB+UGDxQFEOcaJDIJ@vQF0JAiDRCQYAUQDnCTAAQAA"
    . "i0QkGDnFD4VX@@@@RInoi1wkEESLhCQgAQAAD6+EJJABAABEiWwkGMH4ColEJByL"
    . "hCSYAQAAQQ+vx8H4ColEJECDvCQQAQAABA+EtwUAAIuEJDgBAACLvCRAAQAAD6+E"
    . "JEgBAACNBLiLvCQ4AQAAiUQkCESJ4PfYg7wkEAEAAAGNBIeJRCQgD4SxBQAAg7wk"
    . "EAEAAAIPhIQHAACDvCQQAQAAAw+EowoAAIuEJFgBAACFwA+OHwEAAESJfCQQRIuc"
    . "JBABAABBjWwk@0yLfCQoi7wkoAEAAEUx9kUx7YlcJAhEiYQkIAEAAA8fhAAAAAAA"
    . "RYXkD467AAAASWPFMclJicFNjUQHAUwDjCRgAQAA6xhBxgEEg8EBSYPBAUmDwAFB"
    . "OcwPhIkAAABBg@sDf+KFyUEPtlD@D4S1DgAAQQ+2WP45zQ+Euw4AAEUPthCF@w+E"
    . "fAEAAA+28rgGAAAAg+4Bg@4BdhiD+wFAD5TGQYP6AQ+UwAnwD7bAAcCDyASB4v0A"
    . "AAC+AQAAAHQOhdtAD5TGRYXSD5TCCdYJ8IPBAUmDwQFBiEH@SYPAAUE5zA+Fd@@@"
    . "@0UB5UGDxgFEObQkWAEAAA+PKv@@@4tcJAhEi3wkEESLhCQgAQAAg7wkEAEAAAN@"
    . "FouEJKABAACFwA+VwDwBg5wkQAEAAP+LfCQYi3QkHDHARInlRIucJFgBAAA59w9O"
    . "+EQ7fCRAiXwkGEQPTvgrrCS4AQAARCucJMABAACDvCQoAQAACQ+EuQAAAIuEJCgB"
    . "AACD6AGD+AcPh5ACAACD+AOJRCRID46LAgAAiWwkCESJXCQQRTH2x0QkTAAAAACL"
    . "fCRMOXwkCMdEJGgAAAAAD4wNAQAAi3wkaDl8JBAPjNIMAACLfCRIi3QkTItEJAgp"
    . "8ED2xwIPRMaLdCRoicKLRCQQKfBA9scBD0TGg@8DidcPT@gPT8JBicXptgoAAGaQ"
    . "D7bCg+gBg@gCGcCD4AKDwASB4v0AAAAPlMIJ0EGIAekg@v@@iehBjVMBRIlcJAjB"
    . "6B+JbCQQx4QkiAAAAAAAAAAB6MeEJIQAAAABAAAAx0QkbAAAAADR+MdEJHwAAAAA"
    . "QYnFRInYwegfRAHY0fiJx41FAYnGD6@yOdAPTMJFMfaDwAiJtCSkAAAAicYPr@CJ"
    . "tCSoAAAAi7QkpAAAADm0JIgAAAB9HIu0JKgAAAA5dCR8x4QkgAAAAAAAAAAPjEYE"
    . "AACLhCQoAQAAhcAPhV0CAABIg7wkqAEAAAAPhE4CAACLhCTAAQAAD6+EJLgBAACD"
    . "+AEPhDYCAABBg@4BD45dCQAAQY1G@kyLRCRgTIucJKgBAABFMclFMdJIjRyFBAAA"
    . "AEOLdAgEQ4sUCESJ0UOLfAsETInQOdZyE+kJBAAAZpBIg+gBQYsUgDnWcx1BiVSA"
    . "BEGLFIOD6QGD+f9BiVSDBHXeSMfA@@@@@0mDwQRIg8ABSYPCAUk52UGJNIBBiTyD"
    . "dZ9Ei5QkuAEAAIucJMABAABFD6@SD6@bTIuMJKgBAAAx9jHAQYsssYnvRA+33cHv"
    . "EIXAdDJFMcAPH4QAAAAAAEOLDIEPt9FEKdoPr9JEOdJ9DMHpECn5D6@JOdl8E0mD"
    . "wAFEOcB@2Uhj0IPAAUGJLJFIg8YBQTn2f6pIgcTIAAAAW15fXUFcQV1BXkFfw8dE"
    . "JEgAAAAARIlcJAiJbCQQRTH2x0QkTAAAAADpcP3@@4tEJDAx@4P4AkAPlMeJvCSs"
    . "AAAAD4SpAwAAMcCDfCQwAQ+UwEWFwImEJKAAAAAPhNsKAABEiaQkUAEAAEyLlCR4"
    . "AQAARTHJi7wkOAEAAEyLpCRoAQAARTHbTIusJHABAABEi7QkuAEAAESLvCTAAQAA"
    . "iVwkGEGLGkmDwliJ2MHoEEEPr8eZ9@0Pr8eJwQ+3w0EPr8aZ9@6NBIFDiQSMQYtC"
    . "rEGNBENBg8MWQ4lEjQBJg8EBRTnId72LhCSQAQAARIukJFABAACJXCQwi1wkGESJ"
    . "RCQYQQ+vwMH4ColEJBxIi4QkeAEAAMdEJEAAAAAARTH@SIPACEiJBCTpq@r@@0SJ"
    . "8OnE@v@@i3wkMIn4wegQD6+EJMABAACZ9@0Pr4QkOAEAAInBD7fHD6+EJLgBAACZ"
    . "9@6NBIGJRCQw6Wv6@@+J6ESLjCRYAQAARQHAD6@GSJhIA4QkeAEAAEWFyUiJBCQP"
    . "jnL7@@9CjTylAAAAAMdEJBAAAAAAMcDHRCRIAAAAAESJfCR4iXwkUEWF5A+O6QAA"
    . "AEhjVCQISIu8JDABAABFMe1MY3QkSEwDdCQoSI1sFwJMiwwkRTHSD7Z9AA+2df9E"
    . "D7Zd@usmZi4PH4QAAAAAAA+vyQ+v0o0MSQ+vwI0UkY0EQjnDc2hJg8EIMcBFOcIP"
    . "gxsBAABBiwFBi1kEQYPCAonBD7bUD7bAwekQKfJEKdgPtskp+YH7@@@@AHazQYnf"
    . "QcHvEEUPtv8Pr8lFD6@@RDn5d7IPts8Pr9IPr8k5ynelD7bTD6@AD6@SOdB3mLoB"
    . "AAAAuAEAAABDiBQuSYPFAUiDxQRFOewPj0P@@@+LdCRQRAFkJEgBdCQIg0QkEAGL"
    . "VCQgi3wkEAFUJAg5vCRYAQAAD4Xw@v@@RIt8JHjpFvn@@0WF7XgVRDtsJBB@DoX@"
    . "eAo7fCQID464BQAAi0QkbIXAD4WNBQAAg+8Bg4QkgAAAAAGDRCR8AYuUJIQAAAA5"
    . "lCSAAAAAfLqLdCRsifCD4AEBwonwg8ABiZQkhAAAAIPgA4lEJGzpW@v@@w8fRAAA"
    . "icLpQf@@@0yJ0Oka@P@@i0QkMIuMJFgBAAAx9jH@Qo0spQAAAACDwAHB4AeFyYlE"
    . "JDAPjo@5@@9Ei3QkCESLbCQwRYXkflVIi5QkMAEAAExj30wDXCQoSWPGRTHJSI1M"
    . "AgIPthEPtkH@RA+2Uf5rwEtr0iYBwkSJ0MHgBEQp0AHQQTnFQw+XBAtJg8EBSIPB"
    . "BEU5zH@MQQHuRAHng8YBRAN0JCA5tCRYAQAAdZXp9vf@@4noRQHAD6@GweACSJhI"
    . "A4QkeAEAAEiJBCSLhCSYAQAAwfgKg8ABhe2JRCQID46VCgAAi3wkCIuEJMABAADH"
    . "RCRIAAAAAMdEJBgAAAAARImkJFABAACJrCSIAQAAD6@HiXwkUIlEJHiJ+A+vxsHg"
    . "AkiYSIlEJHBIi4QkeAEAAEiJRCRAifjB4AJImEiJRCQQi4QkuAEAAA+vx4lEJBxI"
    . "iwQkSIPACEiJRCQghfYPjiYBAABIi3wkQESLZCQIMe0Ptl8CTItMJCBBvgIAAABE"
    . "D7ZXAUQPth9Bid3rHQ8fAA+v2w+v0o0cWw+vwI0Uk40EQjnBc2pJg8EIRTnwD4Z9"
    . "AAAAQYsBQYtJBEGDxgKJww+21A+2wMHrEEQp0kQp2A+220Qp64H5@@@@AHazQYnP"
    . "QcHvEEUPtv8Pr9tFD6@@RDn7d7IPtt0Pr9IPr9s52nelD7bJD6@AD6@JOch3mGaQ"
    . "i0QkCEgDfCQQA2wkHEQB4EQ55n5lQYnE6UP@@@8PHwCLRCRIRIt0JBhEievB4xBB"
    . "weIIQQnamU1jzkUJ2ve8JIgBAAAPr4QkOAEAAInBieiZ9@5Ii5QkaAEAAI0EgUKJ"
    . "BIpEifCDwAGJRCQYSIuEJHABAABGiRSI64aLfCRQi0QkCItUJHgBVCRISItUJHBI"
    . "AVQkQAH4ObwkiAEAAH4JiUQkUOmk@v@@i0QkGESLpCRQAQAAD6+EJJABAADB+AqJ"
    . "RCQcSIsEJMdEJEAAAAAARTH@i1gEidgPts8PttPB6BAPtsCJxw+v+InID6@Bibwk"
    . "mAAAAImEJJwAAACJ0A+vwomEJJQAAADpffX@@8dEJEAAAAAAx0QkHAAAAABFMf@H"
    . "RCQYAAAAAOn19P@@i5QkWAEAAIXSD4589v@@Q40EZESLdCQIQo0spQAAAAAx9jH@"
    . "SJhIA4QkYAEAAEmJxUWF5H5aSIuUJDABAABJY8ZMY99FMclNAetIjUwCAg8fRAAA"
    . "D7YRSIPBBERr0iYPtlH7a8JLQY0UAkQPtlH6RInQweAERCnQAdDB+AdDiAQLSYPB"
    . "AUU5zH@KQQHuRAHng8YBRAN0JCA5tCRYAQAAdZBIi3wkWDHSQY1sJP9EiXwkSEUx"
    . "0olcJCBBiddIifhIg8ABSIlEJAi4AQAAAEiJxouEJFgBAABIKf6LfCQwSIl0JBBE"
    . "jXD@RYXkD47TAAAASItEJAhNY99Ii3QkKEuNVB0BTo0MGEiLRCQQTAHeTQHpSo0M"
    . "GDHATAHpZi4PH4QAAAAAAEiFwA+EgQMAADnFD4R5AwAARYXSD4RwAwAARTnWD4Rn"
    . "AwAARA+2Qv9ED7Za@rsBAAAAQQH4RTnYckZED7YaRTnYcj1ED7ZZ@0U52HIzRQ+2"
    . "Wf9FOdhyKUQPtln+RTnYch9ED7YZRTnYchZFD7ZZ@kU52HIMRQ+2GUU52A+Sw2aQ"
    . "iBwGSIPAAUiDwgFJg8EBSIPBAUE5xA+PZP@@@0UB50GDwgFEOZQkWAEAAA+FEv@@"
    . "@4tcJCBEi3wkSOmJ8@@@RIuUJLgBAACLnCTAAQAAMcBFD6@SD6@bRYX2D4569@@@"
    . "6RP3@@+DfCRsAQ+E@AEAAIN8JGwCD4S4AgAAQYPtAelX+v@@g4QkiAAAAAHHRCRI"
    . "CQAAAIn4SIu0JGABAABBD6@ERo0MKEljwYA8BgMPhqQBAACLRCQYRDn4QQ9Mx4O8"
    . "JBABAAADiUQkIA+OsAEAAIuEJEgBAACLlCRAAQAAAfhEAeoPr4QkOAEAAIO8JBAB"
    . "AAAFD4TAAgAARI0MkItEJDBIi7QkMAEAAESLVCQgRAHIjVACRYXSSGPSD7Y0Fo1Q"
    . "AUiYSGPSiXQkUEiLtCQwAQAAD7Y0Fol0JHhIi7QkMAEAAA+2BAaJRCRwD4TrAQAA"
    . "i0QkQESJXCQoRTHSi3QkHEyLnCQwAQAAiYQkjAAAAOtyRDu8JJAAAAB+WUiLhCRw"
    . "AQAAQosUkEQByo1CAo1KAUhj0kEPthQTSJhIY8krVCRwQQ+2BANBD7YMCytEJFAr"
    . "TCR4D6@SD6@AD6@JjQRAjQSIjQRQQTnAcgqDrCSMAAAAAXh+SYPCAUQ5VCQgD47P"
    . "AQAARDlUJBhEiZQkkAAAAA+Oe@@@@0iLhCRoAQAAQosUkEQByo1CAo1KAUhj0kEP"
    . "thQTSJhIY8krVCRwQQ+2BANBD7YMCytEJFArTCR4D6@SD6@AD6@JjQRAjQSIjQRQ"
    . "QTnAD4Mo@@@@g+4BD4kf@@@@RItcJCiDfCRICQ+Eavj@@4NEJGgB6Snz@@9Bg8UB"
    . "6Wb4@@+DRCRMAekA8@@@kIXAD4SzAAAARItUJECLdCQcMcnrM0Q7fCQofiJIi5Qk"
    . "cAEAAESJyAMEikiLlCRgAQAA9gQCAXUGQYPqAXiZSIPBATlMJCB+dzlMJBiJTCQo"
    . "fsNIi4QkaAEAAESJygMUiEiLhCRgAQAA9gQQAnWng+4BeaLpX@@@@w8fhAAAAAAA"
    . "uwMAAADpRvH@@8YEBgLp8Pz@@0G6AwAAAOk+8f@@x0QkHAAAAADHRCQYAAAAAOm7"
    . "9f@@g8cB6aD3@@+LdCQcQYPGAUiDvCSoAQAAAA+EHQQAAEljxouUJEgBAABIjQyF"
    . "AAAAAIuEJEABAAAB+sHiEEQB6AnQSIuUJKgBAACJRAr8i5QkKAEAAIXSD4UeAwAA"
    . "i0QkHCnwRDm0JLABAABIi3QkYIlEDvwPjhPz@@@ppf7@@0SLXCQo64aNBJCJRCQo"
    . "i4QkrAAAAIXAD4XjAQAAi0QkIIXAD4Rg@@@@SIsEJIt0JBxFMcnHRCR4AAAAAESJ"
    . "dCRwRIm8JIwAAABEiZwkkAAAAEiJRCRQSIuEJGgBAACLTCQoTIu8JDABAABMi1Qk"
    . "UEyLhCRwAQAARItcJHhCAwyIQYE6@@@@AEeLBIiNUQKNQQFIY8lBD5fGSGPSSJhF"
    . "D7b2QQ+2FBdBD7YEB4mUJLQAAACJhCS4AAAAweIQweAICdBBD7YUDwnQiZQkvAAA"
    . "AImEJLAAAADrHg+v0g+vyY0UUg+vwI0Uio0EQjnDD4OvAAAASYPCCEU5ww+D4AAA"
    . "AESLvCSgAAAAQYPDAkGLAkGLWgRFhf90Hk2FyYtUJDAPRJQksAAAAEUx9oXAQQ+U"
    . "xolUJDCJ0InCD7bMD7bAweoQK4wkuAAAACuEJLwAAAAPttIrlCS0AAAAgfv@@@8A"
    . "D4Z0@@@@QYnfQcHvEEUPtv8Pr9JFD6@@RDn6D4dz@@@@D7bXD6@JD6@SOdEPh2L@"
    . "@@8PttMPr8APr9I50A+HUf@@@0WF9nQFg+4BeDtJg8EBSINEJFBYg0QkeBZEOUwk"
    . "IA+Pkf7@@0SLdCRwRIu8JIwAAABEi5wkkAAAAOmu@f@@RYX2dcfrwESLdCRwRIu8"
    . "JIwAAABEi5wkkAAAAOml@P@@i0QkIIt0JByFwA+Eff3@@0Ux0us5OYQkmAAAAHwY"
    . "D6@JOYwknAAAAHwMD6@SOZQklAAAAH0Jg+4BD4hm@P@@SYPCAUQ5VCQgD44@@f@@"
    . "SIuEJGgBAACLVCQoTIuMJDABAABCAxSQSIuEJHABAABCiwSQicGNQgKJTCQwwekQ"
    . "SJgPtslBD7YEASnIjUoBSGPSD6@ASGPJRQ+2DAlIi0wkMA+2zUEpyUSJyUyLjCQw"
    . "AQAAQQ+2FBFED7ZMJDBEKcqB+@@@@wAPh0r@@@8Pr8mNBEAPr9KNBIiNBFA5ww+C"
    . "VP@@@+lY@@@@x0QkHAAAAADHRCQYAAAAAOlF9@@@RDm0JLABAABEifAPjhvx@@+J"
    . "+CuEJMABAABFMdKDwAFBD0jCicGLhCTAAQAAjUQH@0E5w0EPTsOJxkSJ6CuEJLgB"
    . "AACDwAFED0nQi4QkuAEAAEGNRAX@OcUPTsU5zolEJCAPjEH7@@9EieJJY8IPr9FI"
    . "Y9JIAdBIA4QkYAEAAEmJwY1GAYlEJCiLRCQgRCnQSI1wAUQ7VCQgfxNKjRQOTInI"
    . "gCADSIPAAUg50HX0g8EBTANMJFg7TCQoddjp6Pr@@4uMJCgBAACFyQ+FQf@@@+nU"
    . "+v@@kJCQkJCQkJCQkJCQkA=="
    MyFunc:=this.MCode(StrReplace((A_PtrSize=8?x64:x32),"@","/"))
  }
  text:=j[1], w:=j[2], h:=j[3]
  , err1:=this.Floor(j[4] ? j[5] : ini.err1)
  , err0:=this.Floor(j[4] ? j[6] : ini.err0)
  , mode:=j[7], color:=j[8], n:=j[9]
  ok:=(!ini.bits.Scan0 || mode<1 || mode>5) ? 0
    : DllCall(MyFunc.Ptr, "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",ini.bits.Scan0, "int",ini.bits.Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",ini.ss, "Ptr",ini.s1, "Ptr",ini.s0
    , "Ptr",text, "int",w, "int",h
    , "int",Floor(Abs(err1)*1024), "int",Floor(Abs(err0)*1024)
    , "int",(err1<0||err0<0), "Ptr",ini.allpos, "int",ini.allpos_max
    , "int",Floor(w*ini.zoomW), "int",Floor(h*ini.zoomH))
  return ok
}

code()
{
return "
(

//***** C source code of machine code *****
// gcc.exe -m32/-m64 -O2

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , unsigned char * ss, unsigned int * s1, unsigned int * s0
  , unsigned char * text, int w, int h
  , int err1, int err0, int more_err
  , unsigned int * allpos, int allpos_max
  , int new_w, int new_h )
{
  int ok, o, i, j, k, v, e1, e0, len1, len0, max, pic, shape, sort;
  int x, y, x1, y1, x2, y2, x3, y3, r, g, b, rr, gg, bb, dR, dG, dB;
  int ii, jj, RunDir, DirCount, RunCount, AllCount1, AllCount2;
  unsigned int c1, c2, *cors, *arr;
  unsigned char *ts, *gs;
  ok=0; o=0; v=0; len1=0; len0=0; ts=ss+sw; gs=ss+sw*3;
  arr=allpos+allpos_max; sort=(dir==0);
  //----------------------
  if (mode==5)
  {
    if (pic=(c==2))  // FindPic
    {
      cors=(unsigned int *)(text+w*h*4); j=(err0>>10)+1; n*=2;
      for (y=0; y<h; y+=j)
      {
        for (x=0; x<w; x+=j)
        {
          o=(y*w+x)*4; rr=text[2+o]; gg=text[1+o]; bb=text[o];
          for (i=2; i<n;)
          {
            c1=cors[i++]; c2=cors[i++];
            r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
            v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
            : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
            && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
            if (v) goto NoMatch1;
          }
          s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
          s0[len1++]=rr<<16|gg<<8|bb;
          NoMatch1:;
        }
      }
      c2=cors[1]; r=(c2>>16)&0xFF; g=(c2>>8)&0xFF; b=c2&0xFF; dR=r*r; dG=g*g; dB=b*b;
    }
    else  // FindMultiColor or FindColor
    {
      shape=(c==1);  // FindShape
      cors=(unsigned int *)text;
      for (i=0; i<n; i++, o+=22)
      {
        c=cors[o]; y=c>>16; x=c&0xFFFF;
        s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[len1++]=o+cors[o+1]*2;
      }
      cors+=2;
    }
    goto StartLookUp;
  }
  //----------------------
  // Generate Lookup Table
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      i=(mode==4) ? (y*new_h/h)*Stride+(x*new_w/w)*4 : (y*new_h/h)*sw+(x*new_w/w);
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  //----------------------
  // Color Position Mode
  // only used to recognize multicolored Verification Code
  if (mode==4)
  {
    y=c>>16; x=c&0xFFFF;
    c=(y*new_h/h)*Stride+(x*new_w/w)*4;
    goto StartLookUp;
  }
  //----------------------
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==1)  // Color Mode
  {
    cors=(unsigned int *)(text+w*h); n*=2;
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
      {
        rr=Bmp[2+o]; gg=Bmp[1+o]; bb=Bmp[o];
        for (k=0; k<n;)
        {
          c1=cors[k++]; c2=cors[k++];
          r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
          v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
          : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
          && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
          if (v) break;
        }
        ts[i]=(v) ? 1:0;
      }
    }
  }
  else if (mode==2)  // Gray Threshold Mode
  {
    c=(c+1)<<7;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ts[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 1:0;
  }
  else if (mode==3)  // Gray Difference Mode
  {
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    for (i=0, y=0; y<sh; y++)
    for (x=0; x<sw; x++, i++)
    if (x==0 || x==sw-1 || y==0 || y==sh-1)
      ts[i]=2;
    else
    {
      n=gs[i]+c;
      ts[i]=(gs[i-1]>n || gs[i+1]>n
      || gs[i-sw]>n   || gs[i+sw]>n
      || gs[i-sw-1]>n || gs[i-sw+1]>n
      || gs[i+sw-1]>n || gs[i+sw+1]>n) ? 1:0;
    }
  }
  //----------------------
  StartLookUp:
  for (i=0, y=0; y<sh; y++)
  {
    for (x=0; x<sw; x++, i++)
    {
      if (mode>=4) { ss[i]=4; continue; }
      r=ts[i]; g=(x==0 ? 3 : ts[i-1]); b=(x==sw-1 ? 3 : ts[i+1]);
      if (more_err)
        ss[i]=4|(r==2||r==1||g==1||b==1)<<1|(r==2||r==0||g==0||b==0);
      else
        ss[i]=4|(r==2||r==1)<<1|(r==2||r==0);
    }
  }
  if (mode<4 && more_err) sx++;
  err1=(len1*err1)>>10;
  err0=(len0*err0)>>10;
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=(len1>len0) ? len1 : len0;
  w=new_w; h=new_h; x1=0; y1=0; x2=sw-w; y2=sh-h;
  // 1 ==> ( Left to Right ) Top to Bottom
  // 2 ==> ( Right to Left ) Top to Bottom
  // 3 ==> ( Left to Right ) Bottom to Top
  // 4 ==> ( Right to Left ) Bottom to Top
  // 5 ==> ( Top to Bottom ) Left to Right
  // 6 ==> ( Bottom to Top ) Left to Right
  // 7 ==> ( Top to Bottom ) Right to Left
  // 8 ==> ( Bottom to Top ) Right to Left
  // 9 ==> Center to Four Sides
  if (dir==9)
  {
    x=(x1+x2)/2; y=(y1+y2)/2; i=x2-x1+1; j=y2-y1+1;
    AllCount1=i*j; i=(i>j?i:j)+8;
    AllCount2=i*i; RunCount=0; DirCount=1; RunDir=0;
    for (ii=0; RunCount<AllCount1 && ii<AllCount2;)
    {
      for(jj=0; jj<DirCount; jj++, ii++)
      {
        if(x>=x1 && x<=x2 && y>=y1 && y<=y2)
        {
          RunCount++;
          goto FindPos;
          FindPos_GoBak:;
        }
        if (RunDir==0) y--;
        else if (RunDir==1) x++;
        else if (RunDir==2) y++;
        else x--;
      }
      if (RunDir & 1) DirCount++;
      RunDir = (++RunDir) & 3;
    }
    goto Return1;
  }
  if (dir<1 || dir>8) dir=1;
  if (--dir>3) { r=y1; y1=x1; x1=r; r=y2; y2=x2; x2=r; }
  for (y3=y1; y3<=y2; y3++)
  {
    for (x3=x1; x3<=x2; x3++)
    {
      y=(dir & 2) ? y1+y2-y3 : y3;
      x=(dir & 1) ? x1+x2-x3 : x3;
      if (dir>3) { r=y; y=x; x=r; }
      //----------------------
      FindPos:
      e1=err1; e0=err0; o=y*sw+x;
      if (ss[o]<4) goto NoMatch;
      if (mode<4)
      {
        for (i=0; i<max; i++)
        {
          if (i<len1 && (ss[o+s1[i]]&2)==0 && (--e1)<0) goto NoMatch;
          if (i<len0 && (ss[o+s0[i]]&1)==0 && (--e0)<0) goto NoMatch;
        }
      }
      else if (mode==5)
      {
        o=(sy+y)*Stride+(sx+x)*4;
        if (pic)
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; c=s0[i]; r=Bmp[2+j]-((c>>16)&0xFF);
            g=Bmp[1+j]-((c>>8)&0xFF); b=Bmp[j]-(c&0xFF);
            v=(c2<0x1000000)?(3*r*r+4*g*g+2*b*b>c2):(r*r>dR||g*g>dG||b*b>dB);
            if (v && (--e1)<0) goto NoMatch;
          }
        }
        else
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
            for (j=i*22, k=cors[j]>0xFFFFFF, n=s0[i]; j<n;)
            {
              c1=cors[j++]; c2=cors[j++];
              if (shape) { if (i==0) c=rr<<16|gg<<8|bb; k=!c1; c1=c; }
              r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
              v=(c2<0x1000000) ? (3*r*r+4*g*g+2*b*b<=c2)
              : (r*r<=((c2>>16)&0xFF)*((c2>>16)&0xFF)
              && g*g<=((c2>>8)&0xFF)*((c2>>8)&0xFF) && b*b<=(c2&0xFF)*(c2&0xFF));
              if (v) { if (k) goto NoMatch2; goto MatchOK; }
            }
            if (k) goto MatchOK;
            NoMatch2:
            if ((--e1)<0) goto NoMatch;
            MatchOK:;
          }
        }
      }
      else  // mode==4
      {
        o=(sy+y)*Stride+(sx+x)*4; j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b>n && (--e1)<0) goto NoMatch;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (3*r*r+4*g*g+2*b*b<=n && (--e0)<0) goto NoMatch;
          }
        }
      }
      ok++;
      if (allpos)
      {
        allpos[ok-1]=(sy+y)<<16|(sx+x); if (sort) arr[ok-1]=err1-e1;
        if (ok>=allpos_max) goto Return1;
      }
      // Skip areas that may overlap
      if (!sort)
      {
        r=y-h+1; if (r<0) r=0; rr=y+h-1; if (rr>sh-h) rr=sh-h;
        g=x-w+1; if (g<0) g=0; gg=x+w-1; if (gg>sw-w) gg=sw-w;
        for (i=r; i<=rr; i++)
          for (j=g; j<=gg; j++)
            ss[i*sw+j] &= 3;
      }
      NoMatch:
      if (dir==9) goto FindPos_GoBak;
    }
  }
  //----------------------
  Return1:
  if (!sort || !allpos || w*h==1)
    return ok;
  // Sort by smallest error
  for (i=1; i<ok; i++)
  {
    k=arr[i]; v=allpos[i];
    for (j=i-1; j>=0 && arr[j]>k; j--)
    {
      arr[j+1]=arr[j]; allpos[j+1]=allpos[j];
    }
    arr[j+1]=k; allpos[j+1]=v;
  }
  // Clean up overlapping results
  w*=w; h*=h; k=ok; ok=0;
  for (i=0; i<k; i++)
  {
    c1=allpos[i]; x1=c1&0xFFFF; y1=c1>>16;
    for (j=0; j<ok; j++)
    {
      c2=allpos[j]; x=(c2&0xFFFF)-x1; y=(c2>>16)-y1;
      if (x*x<w && y*y<h) goto NoMatch3;
    }
    allpos[ok++]=c1;
    NoMatch3:;
  }
  return ok;
}

)"
}

PicInfo(text)
{
  local
  if !InStr(text, "$")
    return
  static init, info, bmp
  if !VarSetCapacity(init) && (init:="1")
    info:=[], bmp:=[]
  key:=(r:=StrLen(v:=Trim(text,"|")))<10000 ? v
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , "Ptr",&v, "uint",r*(1+!!A_IsUnicode), "uint")
  if info.HasKey(key)
    return info[key]
  comment:="", seterr:=err1:=err0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v, "O)<([^>\n]*)>", r)
    v:=StrReplace(v,r[0]), comment:=Trim(r[1])
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v, "O)\[([^\]\n]*)]", r)
  {
    v:=StrReplace(v,r[0]), r:=StrSplit(r[1] ",", ",")
    , seterr:=1, err1:=r[1], err0:=r[2]
  }
  color:=SubStr(v,1,InStr(v,"$")-1), v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5 : InStr(color,"#") ? 4
    : InStr(color,"**") ? 3 : InStr(color,"*") ? 2 : 1
  color:=RegExReplace(StrReplace(color,"@","-"), "[*#\s]")
  (mode=1 || mode=5) && color:=StrReplace(color,"0x")
  if (mode=5)
  {
    if !(v~="^[\s\-\w.]+/[\s\-\w.]+/[\s\-\w./,]+$")  ; <FindPic>
    {
      if !(hBM:=LoadPicture(v))
      {
        MsgBox, 4096, Tip, Can't Load Picture ! %v%
        return
      }
      this.GetBitmapWH(hBM, w, h)
      if (w<1 || h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", "Ptr",hBM)
      if (!Scan0)
        return
      arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length()
      bmp.Push(buf:=this.Buffer(w*h*4 + n*2*4)), v:=buf.Ptr, p:=v+w*h*4-4
      DllCall("RtlMoveMemory", "Ptr",v, "Ptr",Scan0, "Ptr",w*h*4)
      DllCall("DeleteObject", "Ptr",hBM2), color:=Trim(arr[1],"-")
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-" color, "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
        , NumPut(this.ToRGB(c[1]), 0|p+=4, "uint")
        , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), 0|p+=4, "uint")
      color:=2
    }
    else  ; <FindMultiColor> or <FindColor> or <FindShape>
    {
      color:=Trim(StrSplit(color "/", "/")[1], "-")
      arr:=StrSplit(Trim(RegExReplace(v, "i)\s|0x"), ","), ",")
      if !(n:=arr.Length())
        return
      bmp.Push(buf:=this.Buffer(n*22*4)), v:=buf.Ptr
      shape:=(n>1 && StrLen(StrSplit(arr[1] "//","/")[3])=1 ? 1:0)
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1]), y:=this.Floor(r[2])
        , (A_Index=1) ? (x1:=x2:=x, y1:=y2:=y)
        : (x1:=Min(x1,x), x2:=Max(x2,x), y1:=Min(y1,y), y2:=Max(y2,y))
      }
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/","/"), x:=this.Floor(r[1])-x1, y:=this.Floor(r[2])-y1
        , NumPut(y<<16|x, 0|p:=v+(A_Index-1)*22*4, "uint")
        , NumPut(n1:=Min(Max(r.Length()-3,0),(shape?1:10)), 0|p+=4, "uint")
        Loop % n1
          c:=StrSplit(Trim(v1:=r[2+A_Index],"-") "-" color, "-")
          , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
          , NumPut(this.ToRGB(c[1])&0xFFFFFF|(!shape&&InStr(v1,"-")=1?0x1000000:0), 0|p+=4, "uint")
          , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), 0|p+=4, "uint")
      }
      color:=shape, w:=x2-x1+1, h:=y2-y1+1
    }
  }
  else
  {
    r:=StrSplit(v ".", "."), w:=this.Floor(r[1])
    , v:=this.base64tobit(r[2]), h:=StrLen(v)//w
    if (w<1 || h<1 || StrLen(v)!=w*h)
      return
    arr:=StrSplit(color "/", "/"), arr.Pop(), n:=arr.Length()
    , bmp.Push(buf:=this.Buffer(StrPut(v, "CP0") + n*2*4))
    , StrPut(v, buf.Ptr, "CP0"), v:=buf.Ptr, p:=v+w*h-4
    , color:=this.Floor(color)
    if (mode=1)
    {
      For k1,v1 in arr
        c:=StrSplit(Trim(v1,"-") "-", "-")
        , x:=this.Floor(c[2]), x:=(x<=0||x>1?0:Floor(9*255*255*(1-x)*(1-x)))
        , NumPut(this.ToRGB(c[1]), 0|p+=4, "uint")
        , NumPut((InStr(c[2],".")?x:this.Floor("0x" c[2])|0x1000000), 0|p+=4, "uint")
    }
    else if (mode=4)
    {
      r:=StrSplit(Trim(arr[1],"-") "-", "-")
      , n:=this.Floor(r[2]), n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
      , c:=this.Floor(r[1]), color:=(c<1||c>w*h?0:((c-1)//w)<<16|Mod(c-1,w))
    }
  }
  return info[key]:=[v, w, h, seterr, err1, err0, mode, color, n, comment]
}

ToRGB(color)  ; color can use: RRGGBB, Red, Yellow, Black, White
{
  static init, tab
  if !VarSetCapacity(init) && (init:="1")
    tab:=Object("Black", "000000", "White", "FFFFFF"
    , "Red", "FF0000", "Green", "008000", "Blue", "0000FF"
    , "Yellow", "FFFF00", "Silver", "C0C0C0", "Gray", "808080"
    , "Teal", "008080", "Navy", "000080", "Aqua", "00FFFF"
    , "Olive", "808000", "Lime", "00FF00", "Fuchsia", "FF00FF"
    , "Purple", "800080", "Maroon", "800000")
  return this.Floor("0x" (tab.HasKey(color)?tab[color]:color))
}

Buffer(size, FillByte:="")
{
  local
  buf:={}, buf.SetCapacity("_key", size), p:=buf.GetAddress("_key")
  , (FillByte!="" && DllCall("RtlFillMemory","Ptr",p,"Ptr",size,"uchar",FillByte))
  , buf.Ptr:=p, buf.Size:=size
  return buf
}

GetBitsFromScreen(ByRef x:=0, ByRef y:=0, ByRef w:=0, ByRef h:=0
  , ScreenShot:=1, ByRef zx:=0, ByRef zy:=0, ByRef zw:=0, ByRef zh:=0)
{
  local
  static init, CAPTUREBLT
  if !VarSetCapacity(init) && (init:="1")  ; thanks Descolada
  {
    DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*",i:=0)
    CAPTUREBLT:=i ? 0 : 0x40000000
  }
  if InStr(A_OSVersion, ".")  ; thanks QQ:349029755
    DllCall("SetThreadDpiAwarenessContext", "Ptr",-3, "Ptr")
  (!IsObject(this.bits) && this.bits:={Scan0:0, hBM:0, oldzw:0, oldzh:0})
  , bits:=this.bits
  if (!ScreenShot && bits.Scan0)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
    , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
    return bits
  }
  bch:=A_BatchLines, cri:=A_IsCritical
  Critical
  bits.BindWindow:=id:=this.BindWindow(0,0,1)
  if (id)
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
  this.UpdateBits(bits, zx, zy, zw, zh)
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (!ScreenShot || w<1 || h<1 || !bits.hBM)
  {
    Critical % cri
    SetBatchLines % bch
    return bits
  }
  if IsFunc(k:="GetBitsFromScreen2")
    && %k%(bits, x-zx, y-zy, w, h)
  {
    ; Get the bind window use bits.BindWindow
    ; Each small range of data obtained from DXGI must be
    ; copied to the screenshot cache using FindText().CopyBits()
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    Critical % cri
    SetBatchLines % bch
    return bits
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",bits.hBM, "Ptr")
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC:=DllCall("GetDCEx", "Ptr",id, "Ptr",0, "int",3, "Ptr")
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",hDC, "int",x-zx, "int",y-zy, "uint",0xCC0020|CAPTUREBLT)
      DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
      oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
      DllCall("UpdateWindow", "Ptr",id)
      ; RDW_INVALIDATE=0x1|RDW_ERASE=0x4|RDW_ALLCHILDREN=0x80|RDW_FRAME=0x400
      ; DllCall("RedrawWindow", "Ptr",id, "Ptr",0, "Ptr",0, "uint", 0x485)
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
    hDC:=DllCall("GetWindowDC","Ptr",id:=DllCall("GetDesktopWindow","Ptr"),"Ptr")
    DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , "Ptr",hDC, "int",x, "int",y, "uint",0xCC0020|CAPTUREBLT)
    DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  Critical % cri
  SetBatchLines % bch
  return bits
}

UpdateBits(bits, zx, zy, zw, zh)
{
  local
  if (zw>bits.oldzw || zh>bits.oldzh || !bits.hBM)
  {
    Try DllCall("DeleteObject", "Ptr",bits.hBM)
    bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
  }
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
}

CreateDIBSection(w, h, bpp:=32, ByRef ppvBits:=0)
{
  local
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  , NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  , NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",&bi
    , "int",0, "Ptr*",ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

GetBitmapWH(hBM, ByRef w, ByRef h)
{
  local
  VarSetCapacity(bm, size:=(A_PtrSize=8 ? 32:24), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",size, "Ptr",&bm)
  , w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w, h, Clear:=0)
{
  local
  if (w<1 || h<1 || !hBM1 || !hBM2)
    return
  mDC1:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM1:=DllCall("SelectObject", "Ptr",mDC1, "Ptr",hBM1, "Ptr")
  mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
  DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
  , "Ptr",mDC2, "int",x2, "int",y2, "uint",0xCC0020)
  if (Clear)
    DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC1, "int",x1, "int",y1, "uint",MERGECOPY:=0xC000CA)
  DllCall("SelectObject", "Ptr",mDC1, "Ptr",oBM1)
  DllCall("DeleteDC", "Ptr",mDC1)
  DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
  DllCall("DeleteDC", "Ptr",mDC2)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w,h,Reverse:=0)
{
  local
  if (w<1 || h<1 || !Scan01 || !Scan02)
    return
  static init, MFCopyImage
  if !VarSetCapacity(init) && (init:="1")
  {
    MFCopyImage:=DllCall("GetProcAddress", "Ptr"
    , DllCall("LoadLibrary", "Str","Mfplat.dll", "Ptr")
    , "AStr","MFCopyImage", "Ptr")
  }
  if (MFCopyImage && !Reverse)  ; thanks QQ:121507989
  {
    return DllCall(MFCopyImage
      , "Ptr",Scan01+y1*Stride1+x1*4, "int",Stride1
      , "Ptr",Scan02+y2*Stride2+x2*4, "int",Stride2
      , "uint",w*4, "uint",h)
  }
  ListLines % (lls:=A_ListLines)?0:0
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w*=4
  , (Reverse) && (p2+=(h+1)*Stride2, Stride2:=-Stride2)
  Loop % h
    DllCall("RtlMoveMemory","Ptr",p1+=Stride1,"Ptr",p2+=Stride2,"Ptr",w)
  SetBatchLines % bch
  ListLines % lls
}

DrawHBM(hBM, lines)
{
  local
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  oldc:="", brush:=0, VarSetCapacity(rect, 16)
  For k,v in lines  ; [ [x, y, w, h, color] ]
  if IsObject(v)
  {
    if (oldc!=v[5])
    {
      oldc:=v[5], BGR:=(oldc&0xFF)<<16|oldc&0xFF00|(oldc>>16)&0xFF
      DllCall("DeleteObject", "Ptr",brush)
      brush:=DllCall("CreateSolidBrush", "uint",BGR, "Ptr")
    }
    DllCall("SetRect", "Ptr",&rect, "int",v[1], "int",v[2]
      , "int",v[1]+v[3], "int",v[2]+v[4])
    DllCall("FillRect", "Ptr",mDC, "Ptr",&rect, "Ptr",brush)
  }
  DllCall("DeleteObject", "Ptr",brush)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteObject", "Ptr",mDC)
}

; 绑定窗口从而可以后台查找这个窗口的图像
; 相当于始终在前台。解绑窗口使用 FindText().BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  local
  (!IsObject(this.bind) && this.bind:={id:0, mode:0, oldStyle:0})
  , bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id:=this.Floor(bind_id)
    , bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      WinGet, i, ExStyle, ahk_id %bind_id%
      bind.oldStyle:=i
      WinSet, Transparent, 255, ahk_id %bind_id%
      Loop 30
      {
        Sleep 100
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
  if (hDC=1 || hDC=0) && (zw=0)
  {
    this.Cursor:=hDC
    return
  }
  VarSetCapacity(mi, 40, 0), NumPut(16+A_PtrSize, mi, "int")
  DllCall("GetCursorInfo", "Ptr",&mi)
  bShow:=NumGet(mi, 4, "int")
  hCursor:=NumGet(mi, 8, "Ptr")
  x:=NumGet(mi, 8+A_PtrSize, "int")
  y:=NumGet(mi, 12+A_PtrSize, "int")
  if (!bShow) || (x<zx || y<zy || x>=zx+zw || y>=zy+zh)
    return
  VarSetCapacity(ni, 40, 0)
  DllCall("GetIconInfo", "Ptr",hCursor, "Ptr",&ni)
  xCenter:=NumGet(ni, 4, "int")
  yCenter:=NumGet(ni, 8, "int")
  hBMMask:=NumGet(ni, (A_PtrSize=8?16:12), "Ptr")
  hBMColor:=NumGet(ni, (A_PtrSize=8?24:16), "Ptr")
  DllCall("DrawIconEx", "Ptr",hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, "Ptr",hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", "Ptr",hBMMask)
  DllCall("DeleteObject", "Ptr",hBMColor)
}

MCode(hex)
{
  local
  flag:=((hex~="[^A-Fa-f\d\s]") ? 1:4), len:=0
  Loop 2
    if !DllCall("crypt32\CryptStringToBinary", "Str",hex, "uint",0, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=this.Buffer(len)).Ptr), "uint*",len, "Ptr",0, "Ptr",0)
      return
  if DllCall("VirtualProtect", "Ptr",p.Ptr, "Ptr",len, "uint",0x40, "uint*",0)
    return p
}

bin2hex(addr, size, base64:=0)
{
  local
  flag:=(base64 ? 1:4)|0x40000000, len:=0
  Loop 2
    DllCall("crypt32\CryptBinaryToString", "Ptr",addr, "uint",size, "uint",flag
    , "Ptr",(A_Index=1?0:(p:=this.Buffer(len*2)).Ptr), "uint*",len)
  return RegExReplace(StrGet(p.Ptr, len), "\s+")
}

base64tobit(s)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
    if InStr(s, A_LoopField, 1)
      s:=RegExReplace(s, "[" A_LoopField "]", ((i:=A_Index-1)>>5&1)
      . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1))
  s:=RegExReplace(RegExReplace(s,"[^01]+"),"10*$")
  ListLines % lls
  return s
}

bit2base64(s)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop Parse, Chars
    s:=StrReplace(s, "|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), A_LoopField)
  ListLines % lls
  return s
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
  , (!Lib.HasKey(index) && Lib[index]:=[]), Lib:=Lib[index]
  if (add_to_Lib)
  {
    re:="O)<([^>\n]*)>[^$\n]+\$[^""\r\n]+"
    Loop Parse, comments, |
      if RegExMatch(A_LoopField, re, r)
      {
        s1:=Trim(r[1]), s2:=""
        Loop Parse, s1
          s2.=Format("_{:d}", Ord(A_LoopField))
        (s2!="") && Lib[s2]:=r[0]
      }
  }
  else
  {
    Text:=""
    Loop Parse, comments, |
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop Parse, s1
        s2.=Format("_{:d}", Ord(A_LoopField))
      (Lib.HasKey(s2)) && Text.="|" Lib[s2]
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
  this.FindText(,, x1, y1, x2, y2)
}

; 从“上一次的截屏”中快速获取指定坐标的RGB颜色
; 如果坐标超出了屏幕范围，将返回白色

GetColor(x, y, fmt:=1)
{
  local
  bits:=this.GetBitsFromScreen(,,,,0,zx,zy,zw,zh), x-=zx, y-=zy
  , c:=(x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
  ? NumGet(bits.Scan0+y*bits.Stride+x*4,"uint") : 0xFFFFFF
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; 在“上一次的截屏”中设置点的RGB颜色

SetColor(x, y, color:=0x000000)
{
  local
  bits:=this.GetBitsFromScreen(,,,,0,zx,zy,zw,zh), x-=zx, y-=zy
  if (x>=0 && x<zw && y>=0 && y<zh && bits.Scan0)
    NumPut(color, bits.Scan0+y*bits.Stride+x*4, "uint")
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
    , min_X:=(A_Index=1 || x<min_X ? x : min_X)
    , max_X:=(A_Index=1 || x>max_X ? x : max_X)
  While (min_X!="" && min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) || (ocr_Y!="" && Abs(y-ocr_Y)>offsetY)
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" || x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" && LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  (ocr_X="") && ocr_X:=min_Y:=min_X:=max_Y:=0
  return {text:ocr_Text, x:ocr_X, y:min_Y, w:min_X-ocr_X, h:max_Y-min_Y}
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
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
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
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
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
    x:=v.1, y:=v.2
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
  For k,v in StrSplit(s,"|")
    ok2.Push(ok[SubStr(v,InStr(v,".")+1)])
  return ok2
}

; 提示某个坐标的位置，或远程控制中当前鼠标的位置

MouseTip(x:="", y:="", w:=10, h:=10, d:=3)
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
    Sleep 500
  }
  this.RangeTip()
}

; 显示范围的边框，类似于 ToolTip

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=3, num:=1)
{
  local
  ListLines % (lls:=A_ListLines)?0:0
  static init, tab
  if !VarSetCapacity(init) && (init:="1")
    tab:=[]
  (!tab.HasKey(num) && tab[num]:=[0,0,0,0]), Range:=tab[num]
  if (x="")
  {
    if (Range[1])
    Loop 4
    {
      Gui, % Range[A_Index] ":Destroy"
      Range[A_Index]:=0
    }
    ListLines % lls
    return
  }
  if !(Range[1])
  {
    Loop 4
    {
      Gui, New, +Hwndid +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000
      Range[A_Index]:=id
    }
  }
  x:=Floor(x), y:=Floor(y), w:=Floor(w), h:=Floor(h), d:=Floor(d)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 || i=3 ? w+2*d : d)
    , h1:=(i=2 || i=4 ? h+2*d : d)
    Gui, % Range[i] ":Color", %color%
    Gui, % Range[i] ":Show", NA x%x1% y%y1% w%w1% h%h1%
  }
  ListLines % lls
}

State(key)
{
  return GetKeyState(key,"P") || GetKeyState(key)
}

; 用鼠标左右键选取屏幕范围

GetRange(ww:=25, hh:=8, key:="RButton")
{
  local
  static init, KeyOff, hk
  if !VarSetCapacity(init) && (init:="1")
    KeyOff:=this.GetRange.Bind(this, "Off")
  if (ww=="Off")
    return hk:=Trim(A_ThisHotkey, "*")
  ;---------------------
  GetRange_HotkeyIf:=_Gui:=this.GuiNew()
  _Gui.Opt("-Caption +ToolWindow +E0x80000")
  _Gui.Title:="GetRange_HotkeyIf"
  _Gui.Show("NA x0 y0 w0 h0")
  ;---------------------
  if GetKeyState("Ctrl")
    Send {Ctrl Up}
  Hotkey, IfWinExist, GetRange_HotkeyIf
  keys:=key "|Up|Down|Left|Right"
  For k,v in StrSplit(keys, "|")
  {
    if GetKeyState(v)
      Send {%v% Up}
    Hotkey, *%v%, %KeyOff%, On UseErrorLevel
  }
  Hotkey, IfWinExist
  ;---------------------
  Critical % (cri:=A_IsCritical)?"Off":"Off"
  CoordMode, Mouse
  tip:=this.Lang("s5")
  hk:="", oldx:=oldy:="", keydown:=0
  Loop
  {
    Sleep 50
    MouseGetPos, x2, y2
    if (hk=key) || this.State(key) || this.State("Ctrl")
    {
      keydown++
      if (keydown=1)
        MouseGetPos, x1, y1, Bind_ID
      timeout:=A_TickCount+3000
      While (A_TickCount<timeout) && (this.State(key) || this.State("Ctrl"))
        Sleep 50
      hk:=""
      if (keydown>=2)
        Break
    }
    else if (hk="Up") || this.State("Up")
      (hh>1 && hh--), hk:=""
    else if (hk="Down") || this.State("Down")
      hh++, hk:=""
    else if (hk="Left") || this.State("Left")
      (ww>1 && ww--), hk:=""
    else if (hk="Right") || this.State("Right")
      ww++, hk:=""
    x:=(keydown?x1:x2), y:=(keydown?y1:y2)
    this.RangeTip(x-ww, y-hh, 2*ww+1, 2*hh+1, (A_MSec<500?"Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip % "x: " x " y: " y "`n" tip
  }
  ToolTip
  this.RangeTip()
  Hotkey, IfWinExist, GetRange_HotkeyIf
  For k,v in StrSplit(keys, "|")
    Hotkey, *%v%, %KeyOff%, Off UseErrorLevel
  Hotkey, IfWinExist
  GetRange_HotkeyIf.Destroy()
  Critical % cri
  return [x-ww, y-hh, x+ww, y+hh, Bind_ID]
}

GetRange2(key:="LButton")
{
  local
  FindText_GetRange:=_Gui:=this.GuiNew()
  _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  _Gui.BackColor:="White"
  WinSet, Transparent, 10
  this.GetBitsFromScreen(,,,,0,x,y,w,h)
  _Gui.Title:="FindText_GetRange"
  _Gui.Show("NA x" x " y" y " w" w " h" h)
  CoordMode, Mouse
  tip:=this.Lang("s7"), oldx:=oldy:=""
  Loop
  {
    Sleep 50
    MouseGetPos, x1, y1
    if (oldx=x1 && oldy=y1)
      Continue
    oldx:=x1, oldy:=y1
    ToolTip % "x: " x1 " y: " y1 " w: 0 h: 0`n" tip
  }
  Until this.State(key) || this.State("Ctrl")
  Loop
  {
    Sleep 50
    MouseGetPos, x2, y2
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
    this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip % "x: " x " y: " y " w: " w " h: " h "`n" tip
  }
  Until !(this.State(key) || this.State("Ctrl"))
  ToolTip
  this.RangeTip()
  FindText_GetRange.Destroy()
  Clipboard:=x "," y "," (x+w-1) "," (y+h-1)
  return [x, y, x+w-1, y+h-1]
}

BitmapFromScreen(ByRef x:=0, ByRef y:=0, ByRef w:=0, ByRef h:=0
  , ScreenShot:=1, ByRef zx:=0, ByRef zy:=0, ByRef zw:=0, ByRef zh:=0)
{
  local
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy,zw,zh)
  if (w<1 || h<1 || !bits.hBM)
    return
  hBM:=this.CreateDIBSection(w, h)
  this.CopyHBM(hBM, 0, 0, bits.hBM, x-zx, y-zy, w, h, 1)
  return hBM
}

; 快速保存截图为BMP文件，可用于调试
; 如果 file=0 或 "" ，会保存到剪贴板

SavePic(file:=0, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  hBM:=this.BitmapFromScreen(x, y, w, h, ScreenShot)
  this.SaveBitmapToFile(file, hBM)
  DllCall("DeleteObject", "Ptr",hBM)
}

; 保存图像到文件，如果 file=0 或者 ""，保存到剪贴板
; 参数可以是位图句柄或者文件路径，例如： "c:\a.bmp"

SaveBitmapToFile(file, hBM_or_file, x:=0, y:=0, w:=0, h:=0)
{
  local
  if hBM_or_file is number
    hBM_or_file:="HBITMAP:*" hBM_or_file
  if !hBM:=DllCall("CopyImage", "Ptr",LoadPicture(hBM_or_file)
  , "int",0, "int",0, "int",0, "uint",0x2008)
    return
  if (file) || (w!=0 && h!=0)
  {
    (w=0 || h=0) && this.GetBitmapWH(hBM, w, h)
    hBM2:=this.CreateDIBSection(w, -h, bpp:=(file ? 24 : 32))
    this.CopyHBM(hBM2, 0, 0, hBM, x, y, w, h)
    DllCall("DeleteObject", "Ptr",hBM), hBM:=hBM2
  }
  VarSetCapacity(dib, dib_size:=(A_PtrSize=8 ? 104:84), 0)
  , DllCall("GetObject", "Ptr",hBM, "int",dib_size, "Ptr",&dib)
  , pbi:=&dib+(bitmap_size:=A_PtrSize=8 ? 32:24)
  , size:=NumGet(pbi+20, "uint"), pBits:=NumGet(pbi-A_PtrSize, "Ptr")
  if (!file)
  {
    hdib:=DllCall("GlobalAlloc", "uint",2, "Ptr",40+size, "Ptr")
    pdib:=DllCall("GlobalLock", "Ptr",hdib, "Ptr")
    DllCall("RtlMoveMemory", "Ptr",pdib, "Ptr",pbi, "Ptr",40)
    DllCall("RtlMoveMemory", "Ptr",pdib+40, "Ptr",pBits, "Ptr",size)
    DllCall("GlobalUnlock", "Ptr",hdib)
    DllCall("OpenClipboard", "Ptr",0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint",8, "Ptr",hdib)
    DllCall("CloseClipboard")
  }
  else
  {
    if InStr(file,"\") && !FileExist(dir:=RegExReplace(file,"[^\\]*$"))
      Try FileCreateDir, % dir
    VarSetCapacity(bf, 14, 0), NumPut(0x4D42, bf, "short")
    NumPut(54+size, bf, 2, "uint"), NumPut(54, bf, 10, "uint")
    f:=FileOpen(file, "w"), f.RawWrite(bf, 14)
    , f.RawWrite(pbi+0, 40), f.RawWrite(pBits+0, size), f.Close()
  }
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
  if !(hBM:=LoadPicture(file))
    return
  this.GetBitmapWH(hBM, w, h)
  bits:=this.GetBitsFromScreen(,,,,0,x,y,zw,zh)
  this.UpdateBits(bits, x, y, Max(w,zw), Max(h,zh))
  this.CopyHBM(bits.hBM, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
  if (show)
    this.ShowScreenShot(x, y, x+w-1, y+h-1, 0)
  return 1
}

; 显示内存中的屏幕截图用于调试

ShowScreenShot(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static init, hPic, oldx, oldy, oldw, oldh, FindText_Screen
  if !VarSetCapacity(init) && (init:="1")
    FindText_Screen:=""
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
  {
    if (FindText_Screen)
      FindText_Screen.Destroy(), FindText_Screen:=""
    return
  }
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  if !hBM:=this.BitmapFromScreen(x,y,w,h,ScreenShot)
    return
  ;---------------
  if (!FindText_Screen)
  {
    FindText_Screen:=_Gui:=this.GuiNew()  ; WS_EX_NOACTIVATE:=0x08000000
    _Gui.Opt("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
    _Gui.MarginX:=0, _Gui.MarginY:=0
    id:=_Gui.Add("Pic", "w" w " h" h), hPic:=id.Hwnd
    _Gui.Title:="Show Pic"
    _Gui.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  else if (oldx!=x || oldy!=y || oldw!=w || oldh!=h)
  {
    if (oldw!=w || oldh!=h)
      FindText_Screen[hPic].Move(,, w, h)
    FindText_Screen.Show("NA x" x " y" y " w" w " h" h)
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  this.BitmapToWindow(hPic, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
}

BitmapToWindow(hwnd, x1, y1, hBM, x2, y2, w, h)
{
  local
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  hDC:=DllCall("GetDC", "Ptr",hwnd, "Ptr")
  DllCall("BitBlt", "Ptr",hDC, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC, "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("ReleaseDC", "Ptr",hwnd, "Ptr",hDC)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
}

; 快速获取屏幕图像的搜索文本数据

GetTextFromScreen(x1:=0, y1:=0, x2:=0, y2:=0, Threshold:=""
  , ScreenShot:=1, ByRef rx:="", ByRef ry:="", cut:=1)
{
  local
  if (x1=0 && y1=0 && x2=0 && y2=0)
    return this.Gui("CaptureS", ScreenShot)
  SetBatchLines % (bch:=A_BatchLines)?"-1":"-1"
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy)
  if (w<1 || h<1 || !bits.Scan0)
  {
    SetBatchLines % bch
    return
  }
  ListLines % (lls:=A_ListLines)?0:0
  gs:=[]
  j:=bits.Stride-w*4, p:=bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4-j-4
  Loop % h + 0*(k:=0)
  Loop % w + 0*(p+=j)
    c:=NumGet(0|p+=4,"uint")
    , gs[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  if InStr(Threshold,"**")
  {
    Threshold:=Trim(Threshold,"* "), (Threshold="" && Threshold:=50)
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop % h + 0*(y1:=0)
    Loop % w + 0*(y1++)
      i:=y1*sw+A_Index+1, j:=gs[i]+Threshold
      , s.=( gs[i-1]>j || gs[i+1]>j
      || gs[i-sw]>j || gs[i+sw]>j
      || gs[i-sw-1]>j || gs[i-sw+1]>j
      || gs[i+sw-1]>j || gs[i+sw+1]>j ) ? "1":"0"
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=Trim(Threshold,"* ")
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
        if (IS1!=0 && IS2!=0)
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
  ListLines % lls
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
  SetBatchLines % bch
  return s
}

; 等待几秒钟直到屏幕图像改变，需要先调用FindText().ScreenShot()

WaitChange(time:=-1, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  hash:=this.GetPicHash(x1, y1, x2, y2, 0)
  time:=this.Floor(time), timeout:=A_TickCount+Round(time*1000)
  Loop
  {
    if (hash!=this.GetPicHash(x1, y1, x2, y2, 1))
      return 1
    if (time>=0 && A_TickCount>=timeout)
      Break
    Sleep 10
  }
  return 0
}

; 等待屏幕图像稳定下来

WaitNotChange(time:=1, timeout:=30, x1:=0, y1:=0, x2:=0, y2:=0)
{
  local
  oldhash:="", time:=this.Floor(time)
  , timeout:=A_TickCount+Round(this.Floor(timeout)*1000)
  Loop
  {
    hash:=this.GetPicHash(x1, y1, x2, y2, 1), t:=A_TickCount
    if (hash!=oldhash)
      oldhash:=hash, timeout2:=t+Round(time*1000)
    if (t>=timeout2)
      return 1
    if (t>=timeout)
      return 0
    Sleep 100
  }
}

GetPicHash(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  local
  static init:=DllCall("LoadLibrary", "Str","ntdll", "Ptr")
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  if (w<1 || h<1 || !bits.Scan0)
    return 0
  hash:=0, Stride:=bits.Stride, p:=bits.Scan0+(y-1)*Stride+x*4, w*=4
  ListLines % (lls:=A_ListLines)?0:0
  Loop % h
    hash:=(hash*31+DllCall("ntdll\RtlComputeCrc32", "uint",0
      , "Ptr",p+=Stride, "uint",w, "uint"))&0xFFFFFFFF
  ListLines % lls
  return hash
}

WindowToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  if (!id)
    WinGet, id, ID, A
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetWindowRect", "Ptr",id, "Ptr",&rect)
  , x:=x1+NumGet(rect,"int"), y:=y1+NumGet(rect,4,"int")
}

ScreenToWindow(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.WindowToScreen(dx, dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

ClientToScreen(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  if (!id)
    WinGet, id, ID, A
  VarSetCapacity(pt, 8, 0), NumPut(0, pt, "int64")
  , DllCall("ClientToScreen", "Ptr",id, "Ptr",&pt)
  , x:=x1+NumGet(pt,"int"), y:=y1+NumGet(pt,4,"int")
}

ScreenToClient(ByRef x, ByRef y, x1, y1, id:="")
{
  local
  this.ClientToScreen(dx, dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

; 不像 FindText 总是使用屏幕坐标，它使用与内置命令
; PixelGetColor 一样的 CoordMode 设置的坐标模式

PixelGetColor(x, y, ScreenShot:=1, id:="")
{
  if (A_CoordModePixel="Window")
    this.WindowToScreen(x, y, x, y, id)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(x, y, x, y, id)
  if (ScreenShot)
    this.ScreenShot(x, y, x, y)
  return this.GetColor(x, y)
}

; 不像 FindText 总是使用屏幕坐标，它使用与内置命令
; ImageSearch 一样的 CoordMode 设置的坐标模式
; 图片文件参数可以使用 "*n *TransBlack/White/RRGGBB-DRDGDB... d:\a.bmp"

ImageSearch(ByRef rx:="", ByRef ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ImageFile:="", ScreenShot:=1, FindAll:=0, dir:=1)
{
  local
  dx:=dy:=0
  if (A_CoordModePixel="Window")
    this.WindowToScreen(dx, dy, 0, 0)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(dx, dy, 0, 0)
  text:=""
  Loop Parse, ImageFile, |
  if (v:=Trim(A_LoopField))!=""
  {
    text.=InStr(v,"$") ? "|" v : "|##"
    . (RegExMatch(v, "O)(^|\s)\*(\d+)\s", r)
    ? Format("{:06X}", r[2]<<16|r[2]<<8|r[2]) : "000000")
    . (RegExMatch(v, "Oi)(^|\s)\*Trans(\S+)\s", r) ? "/" Trim(r[2],"/"):"")
    . "$" Trim(RegExReplace(v,"(^|\s)\*\S+"))
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x1:=y1:=-n, x2:=y2:=n
  if (ok:=this.FindText(,, x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll,,,, dir))
  {
    For k,v in ok  ; you can use ok:=FindText().ok
      v.1-=dx, v.2-=dy, v.x-=dx, v.y-=dy
    rx:=ok[1].1, ry:=ok[1].2, ErrorLevel:=0
    return ok
  }
  else
  {
    rx:=ry:="", ErrorLevel:=1
    return 0
  }
}

; 不像 FindText 总是使用屏幕坐标，它使用与内置命令
; PixelSearch 一样的 CoordMode 设置的坐标模式
; 颜色参数可以是 "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation 取值 0-255

PixelSearch(ByRef rx:="", ByRef ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ColorID:="", Variation:=0, ScreenShot:=1, FindAll:=0, dir:=1)
{
  local
  n:=this.Floor(Variation), text:=Format("##{:06X}$0/0/", n<<16|n<<8|n)
  . Trim(StrReplace(ColorID, "|", "/"), "- /")
  return this.ImageSearch(rx, ry, x1, y1, x2, y2, text, ScreenShot, FindAll, dir)
}

; 屏幕坐标指示的范围内的某些颜色的像素计数
; 颜色参数可以是 "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation 取值 0-255

PixelCount(x1:=0, y1:=0, x2:=0, y2:=0, ColorID:="", Variation:=0, ScreenShot:=1)
{
  local
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(x,y,w,h,ScreenShot,zx,zy), x-=zx, y-=zy
  sum:=0, VarSetCapacity(s1,4), VarSetCapacity(s0,4), VarSetCapacity(ss,w*(h+3))
  ini:={ bits:bits, ss:&ss, s1:&s1, s0:&s0, allpos:0, allpos_max:0
    , err1:0, err0:0, zoomW:1, zoomH:1 }
  n:=this.Floor(Variation), text:=Format("##{:06X}$0/0/", n<<16|n<<8|n)
  . Trim(StrReplace(ColorID, "|", "/"), "- /")
  if IsObject(j:=this.PicInfo(text))
    sum:=this.PicFind(ini, j, 1, x, y, w, h)
  return sum
}

; 创建包含特定颜色的色块，可以限定这个色块中符合颜色的数量
; ColorID 可以使用 "RRGGBB-DRDGDB|RRGGBB-DRDGDB", "*128", "**50"
; Count1, Count0 是这个色块二值化后黑点和白点的数量最小值

ColorBlock(ColorID, w, h, Count1:=0, Count0:=0)
{
  local
  (Count0>0 && Count1:=0)
  Text:="|<>[" (1-Count1/(w*h)) "," (1-Count0/(w*h)) "]"
  . Trim(StrReplace(ColorID,"|","/"),"- /") . Format("${:d}.",w)
  . this.bit2base64(StrReplace(Format(Format("{{}:0{:d}d{}}",w*h),0),"0"
  , (Count0>0 ? "0":"1")))
  return Text
}

Click(x:="", y:="", other1:="", other2:="", GoBack:=0)
{
  local
  CoordMode, Mouse, % (bak:=A_CoordModeMouse)?"Screen":"Screen"
  if GoBack
    MouseGetPos, oldx, oldy
  MouseMove, x, y, 0
  Sleep 30
  Click % x "," y "," other1 "," other2
  if GoBack
    MouseMove, oldx, oldy, 0
  CoordMode, Mouse, %bak%
  return 1
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
  Exec(s, Ahk:="", args:="")    ; required AHK v1.1.34+ and Ahk2Exe Use .exe
  {
    local
    Ahk:=Ahk ? Ahk : A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    s:="`nDllCall(""SetWindowText"",""Ptr"",A_ScriptHwnd,""Str"",""<AHK>"")`n"
      . "`nSetBatchLines,-1`n" . s, s:=RegExReplace(s, "\R", "`r`n")
    Try
    {
      shell:=ComObjCreate("WScript.Shell")
      oExec:=shell.Exec("""" Ahk """ /script /force /CP0 * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`r`nTry FileDelete " f "`r`n" s
      Try FileDelete % f
      FileAppend % s, % f
      r:=this.Clear.Bind(this)
      SetTimer % r, -3000
      Run "%Ahk%" /script /force /CP0 "%f%" %args%,, UseErrorLevel, pid
    }
    return pid
  }
  Clear()
  {
    Try FileDelete % A_Temp "\~ahk.tmp"
    SetTimer,, Off
  }
}

; FindText().QPC() 用法类似于 A_TickCount

QPC()
{
  static init, f, c
  if !VarSetCapacity(init) && (init:="1")
    f:=0, c:=DllCall("QueryPerformanceFrequency", "Int64*",f)+(f/=1000)
  return (!DllCall("QueryPerformanceCounter","Int64*",c))*0+(c/f)
}

; FindText().ToolTip() 用法类似于 ToolTip

ToolTip(s:="", x:="", y:="", num:=1, arg:="")
{
  local
  static init, ini, tip, timer
  if !VarSetCapacity(init) && (init:="1")
    ini:=[], tip:=[], timer:=[]
  f:="ToolTip_" . this.Floor(num)
  if (s="")
  {
    Try tip[f].Destroy()
    ini[f]:="", tip[f]:=""
    return
  }
  ;-----------------
  r1:=A_CoordModeToolTip
  r2:=A_CoordModeMouse
  CoordMode Mouse, Screen
  MouseGetPos x1, y1
  CoordMode Mouse, %r1%
  MouseGetPos x2, y2
  CoordMode Mouse, %r2%
  (x!="" && x:="x" (this.Floor(x)+x1-x2))
  , (y!="" && y:="y" (this.Floor(y)+y1-y2))
  , (x="" && y="" && x:="x" (x1+16) " y" (y1+16))
  ;-----------------
  bgcolor:=arg.bgcolor!="" ? arg.bgcolor : "FAFBFC"
  color:=arg.color!="" ? arg.color : "Black"
  font:=arg.font ? arg.font : "Consolas"
  size:=arg.size ? arg.size : "10"
  bold:=arg.bold ? arg.bold : ""
  trans:=arg.trans!="" ? arg.trans & 255 : 255
  timeout:=arg.timeout!="" ? arg.timeout : ""
  ;-----------------
  r:=bgcolor "|" color "|" font "|" size "|" bold "|" trans "|" s
  if (!ini.HasKey(f) || ini[f]!=r)
  {
    ini[f]:=r
    Try tip[f].Destroy()
    tip[f]:=_Gui:=this.GuiNew()  ; WS_EX_LAYERED:=0x80000, WS_EX_TRANSPARENT:=0x20
    _Gui.Opt("+LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x80020")
    _Gui.MarginX:=2, _Gui.MarginY:=2
    _Gui.BackColor:=bgcolor
    _Gui.SetFont("c" color " s" size " " bold, font)
    _Gui.Add("Text",, s)
    _Gui.Title:=f
    _Gui.Show("Hide")
    WinSet, Transparent, % trans
  }
  tip[f].Opt("+AlwaysOnTop")
  tip[f].Show("NA " x " " y)
  if (timeout)
  {
    (!timer.HasKey(f) && timer[f]:=this.ToolTip.Bind(this,"","","",num))
    , r:=timer[f]
    SetTimer % r, % -Round(Abs(this.Floor(timeout)*1000))-1
  }
}

; FindText().ObjView() 查看对象的值用于调试

ObjView(obj, keyname:="")
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
  _Gui:=this.GuiNew("+AlwaysOnTop")
  _Gui.Add("Button", "y270 w350 gCancel Default", "OK")
  _Gui.Add("Edit", "xp y10 w350 h250 -Wrap -WantReturn")
  _Gui["Edit1"].Value:=s
  _Gui.Title:="Debug view object values"
  _Gui.Show()
  DetectHiddenWindows 0
  WinWaitClose % "ahk_id " _Gui.Hwnd
  _Gui.Destroy()
}

EditScroll(hEdit, regex:="", line:=0, pos:=0)
{
  local
  ControlGetText, s,, ahk_id %hEdit%
  pos:=(regex!="") ? InStr(SubStr(s,1,s~=regex) " ","`n",0,-1)
    : (line>1) ? InStr(s,"`n",0,1,line-1) : pos
  SendMessage, 0xB1, pos, pos,, ahk_id %hEdit%
  SendMessage, 0xB7,,,, ahk_id %hEdit%
}

LastCtrl()
{
  local
  return (G:=this.GuiFromHwnd(WinExist()))[G.LastHwnd]
}

Hide(args*)
{
  WinMinimize
  WinHide
  ToolTip
  DetectHiddenWindows 0
  WinWaitClose % "ahk_id " WinExist()
}

SC(RGB, hwnd)
{
  SendMessage,0x2001,0,(RGB&0xFF)<<16|RGB&0xFF00|(RGB>>16)&0xFF,,% "ahk_id " hwnd
}


;==== Optional GUI interface ====


Gui(cmd, arg1:="", args*)
{
  local
  static
  local bch, cri, lls, _Gui
  ListLines % InStr("MouseMove|ToolTipOff",cmd)?0:A_ListLines
  static init
  if !VarSetCapacity(init) && (init:="1")
  {
    SavePicDir:=A_Temp "\Ahk_ScreenShot\"
    G_ := this.Gui.Bind(this)
    G_G := this.Gui.Bind(this, "G")
    G_Run := this.Gui.Bind(this, "Run")
    G_Show := this.Gui.Bind(this, "Show")
    G_KeyDown := this.Gui.Bind(this, "KeyDown")
    G_LButtonDown := this.Gui.Bind(this, "LButtonDown")
    G_RButtonDown := this.Gui.Bind(this, "RButtonDown")
    G_MouseMove := this.Gui.Bind(this, "MouseMove")
    G_ScreenShot := this.Gui.Bind(this, "ScreenShot")
    G_ShowPic := this.Gui.Bind(this, "ShowPic")
    G_Slider := this.Gui.Bind(this, "Slider")
    G_ToolTip := this.Gui.Bind(this, "ToolTip")
    G_ToolTipOff := this.Gui.Bind(this, "ToolTipOff")
    G_SaveScr := this.Gui.Bind(this, "SaveScr")
    G_PicShowOK := this.Gui.Bind(this, "PicShowOK")
    G_Drag := this.Gui.Bind(this, "Drag")
    FindText_Capture:=FindText_Main:=""
    PrevControl:=x:=y:=oldx:=oldy:=""
    Pics:=[], hBM_old:=dx:=dy:=0
    bch:=A_BatchLines, cri:=A_IsCritical
    Critical
    #NoEnv
    Lang:=this.Lang(,1), Tip_Text:=this.Lang(,2)
    G_.Call("MakeCaptureWindow")
    G_.Call("MakeMainWindow")
    OnMessage(0x100, G_KeyDown)
    OnMessage(0x201, G_LButtonDown)
    OnMessage(0x204, G_RButtonDown)
    OnMessage(0x200, G_MouseMove)
    Menu, Tray, Add
    Menu, Tray, Add, % Lang["s1"], % G_Show
    if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
    {
      Menu, Tray, Default, % Lang["s1"]
      Menu, Tray, Click, 1
      Menu, Tray, Icon, Shell32.dll, 23
    }
    Critical % cri
    SetBatchLines % bch
    this.GuiNew("+LastFound").Destroy()
  }
  Switch cmd
  {
  Case "G":
    id:=this.LastCtrl()
    Try id.OnEvent("Click", G_Run)
    Catch
      Try id.OnEvent("Change", G_Run)
    return
  Case "Run":
    Critical
    G_.Call(arg1.Name)
    return
  Case "Show":
    FindText_Main.Show(arg1 ? "Center" : "")
    ControlFocus,, % "ahk_id " hscr
    return
  Case "Cancel", "Cancel2":
    WinHide
    return
  Case "MakeCaptureWindow":
    WindowColor:="0xDDEEFF"
    Try FindText_Capture.Destroy()
    FindText_Capture:=_Gui:=this.GuiNew()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    Tab:=_Gui.Add("Tab3", "vMyTab1 -Wrap", StrSplit(Lang["s18"],"|"))
    Tab.UseTab(1)
    C_:=[], Cid_:=[]
    , nW:=71, nH:=25, w:=h:=12, pW:=nW*(w+1)-1, pH:=(nH+1)*(h+1)-1
    id:=_Gui.Add("Text", "w" pW " h" pH), Cid_[id.Hwnd]:=-1
    _Gui.Opt("-Theme")
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "xp yp Section" : Mod(i,nW)=1 ? "xs y+1":"x+1"
      id:=_Gui.Add("Progress", j " w" w " h" h " -E0x20000 Smooth")
      C_[i]:=id.Hwnd, Cid_[id.Hwnd]:=i
    }
    ListLines % lls
    _Gui.Opt("+Theme")
    _Gui.Add("Slider", "xs w" pW " vMySlider1 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider2 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    Tab.UseTab(2)
    id:=_Gui.Add("Pic", "w" (pW-135) " h" pH " +Border -Background Section"), hPic:=id.Hwnd
    Pic_hBM:=this.CreateDIBSection(Pic_w:=(pW-135), Pic_h:=pH)
    _Gui.Add("Slider", "xs wp vMySlider3 +Center Page20 Line10 NoTicks AltSubmit")
    G_G.Call()
    _Gui.Add("Slider", "ys h" pH " vMySlider4 +Center Page20 Line10 NoTicks AltSubmit +Vertical")
    G_G.Call()
    _Gui.Add("ListBox", "ys w120 h200 vSelectBox AltSubmit 0x100")
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vClearAll", Lang["ClearAll"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vOpenDir", Lang["OpenDir"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vLoadPic", Lang["LoadPic"])
    G_G.Call()
    _Gui.Add("Button", "y+0 wp vSavePic", Lang["SavePic"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Text", "xm Section", Lang["SelGray"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelGray ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelColor"])
    _Gui.Add("Edit", "x+5 yp-3 w150 vSelColor ReadOnly")
    _Gui.Add("Text", "x+15 ys", Lang["SelR"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelR ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelG"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelG ReadOnly")
    _Gui.Add("Text", "x+5 ys", Lang["SelB"])
    _Gui.Add("Edit", "x+5 yp-3 w80 vSelB ReadOnly")
    ;--------------
    id:=_Gui.Add("Button", "xm Hidden Section", Lang["Auto"])
    id.GetPos(pX, pY, pW, pH)
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    _Gui.Add("Button", "xm+" i " yp w" w " hp -Wrap vRepU", Lang["RepU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU", Lang["CutU"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutU3", Lang["CutU3"])
    G_G.Call()
    _Gui.Add("Button", "xm wp hp -Wrap vRepL", Lang["RepL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL", Lang["CutL"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutL3", Lang["CutL3"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" pW " hp -Wrap vAuto", Lang["Auto"])
    G_G.Call()
    _Gui.Add("Button", "x+15 w" w " hp -Wrap vRepR", Lang["RepR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR", Lang["CutR"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutR3", Lang["CutR3"])
    G_G.Call()
    _Gui.Add("Button", "xm+" i " wp hp -Wrap vRepD", Lang["RepD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD", Lang["CutD"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp hp -Wrap vCutD3", Lang["CutD3"])
    G_G.Call()
    ;--------------
    Tab:=_Gui.Add("Tab3", "ys -Wrap", StrSplit(Lang["s2"],"|"))
    Tab.UseTab(1)
    _Gui.Add("Text", "x+30 y+35", Lang["Threshold"])
    _Gui.Add("Edit", "x+15 w100 vThreshold")
    _Gui.Add("Button", "x+15 yp-3 vGray2Two", Lang["Gray2Two"])
    G_G.Call()
    Tab.UseTab(2)
    _Gui.Add("Text", "x+30 y+35", Lang["GrayDiff"])
    _Gui.Add("Edit", "x+15 w100 vGrayDiff", "50")
    _Gui.Add("Button", "x+15 yp-3 vGrayDiff2Two", Lang["GrayDiff2Two"])
    G_G.Call()
    Tab.UseTab(3)
    _Gui.Add("Text", "x+10 y+15 Section", Lang["Similar1"] " 0")
    _Gui.Add("Slider", "x+0 w100 vSimilar1 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+10 ys-2 vAddColorSim", Lang["AddColorSim"])
    G_G.Call()
    _Gui.Add("Text", "x+25 ys+4", Lang["DiffRGB2"])
    _Gui.Add("Edit", "x+5 ys w80 vDiffRGB2 Limit3")
    _Gui.Add("UpDown", "vdRGB2 Range0-255 Wrap", 50)
    _Gui.Add("Button", "x+10 ys-2 vAddColorDiff", Lang["AddColorDiff"])
    G_G.Call()
    _Gui.Add("Button", "xs vUndo2", Lang["Undo2"])
    G_G.Call()
    _Gui.Add("Edit", "x+10 yp+2 w340 vColorList")
    _Gui.Add("Button", "x+10 yp-2 vColor2Two", Lang["Color2Two"])
    G_G.Call()
    Tab.UseTab(4)
    _Gui.Add("Text", "x+30 y+35", Lang["Similar2"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar2 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 yp-3 vColorPos2Two", Lang["ColorPos2Two"])
    G_G.Call()
    Tab.UseTab(5)
    _Gui.Add("Text", "x+30 y+15 Section", Lang["Similar3"] " 0")
    _Gui.Add("Slider", "x+0 w120 vSimilar3 +Center Page1 NoTicks ToolTip")
    G_G.Call()
    _Gui.Add("Text", "x+0", "100")
    _Gui.Add("Button", "x+15 ys-2 vUndo", Lang["Undo"])
    G_G.Call()
    _Gui.Add("Checkbox", "xs vMultiColor", Lang["MultiColor"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+50 vFindShape", Lang["FindShape"])
    G_G.Call()
    Tab.UseTab()
    ;--------------
    _Gui.Add("Button", "xm vReset", Lang["Reset"])
    G_G.Call()
    _Gui.Add("Checkbox", "x+15 yp+5 vModify", Lang["Modify"])
    G_G.Call()
    _Gui.Add("Text", "x+30", Lang["Comment"])
    _Gui.Add("Edit", "x+5 yp-2 w250 vComment")
    _Gui.Add("Button", "x+10 yp-3 vSplitAdd", Lang["SplitAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vAllAdd", Lang["AllAdd"])
    G_G.Call()
    _Gui.Add("Button", "x+30 wp vOK", Lang["OK"])
    G_G.Call()
    _Gui.Add("Button", "x+15 wp vCancel", Lang["Cancel"])
    G_G.Call()
    _Gui.Add("Button", "xm vBind0", Lang["Bind0"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind1", Lang["Bind1"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind2", Lang["Bind2"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind3", Lang["Bind3"])
    G_G.Call()
    _Gui.Add("Button", "x+10 vBind4", Lang["Bind4"])
    G_G.Call()
    _Gui.Add("Button", "x+30 vSavePic2", Lang["SavePic2"])
    G_G.Call()
    _Gui.Title:=Lang["s3"]
    _Gui.Show("Hide")
    _Gui.OnEvent("DropFiles", G_Drag)
    return
  Case "Drag":
    Try G_.Call("LoadPic", args[2][1])
    return
  Case "MakeMainWindow":
    Try FindText_Main.Destroy()
    FindText_Main:=_Gui:=this.GuiNew()
    _Gui.Opt("+LastFound +AlwaysOnTop -DPIScale")
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont("s12", "Verdana")
    _Gui.Add("Text", "xm", Lang["NowHotkey"])
    _Gui.Add("Edit", "x+5 w160 vNowHotkey ReadOnly")
    _Gui.Add("Hotkey", "x+5 w160 vSetHotkey1")
    s:="F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|LWin|Ctrl|Shift|Space|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    _Gui.Add("DDL", "x+5 w160 vSetHotkey2", StrSplit(s,"|"))
    _Gui.Add("Button", "x+15 vApply", Lang["Apply"])
    G_G.Call()
    _Gui.Add("GroupBox", "xm y+0 w280 h55 vMyGroup cBlack")
    _Gui.Add("Text", "xp+15 yp+20 Section", Lang["Myww"] ": ")
    _Gui.Add("Text", "x+0 w80", nW//2)
    _Gui.Add("UpDown", "vMyww Range1-100", nW//2)
    _Gui.Add("Text", "x+15 ys", Lang["Myhh"] ": ")
    _Gui.Add("Text", "x+0 w80", nH//2)
    id:=_Gui.Add("UpDown", "vMyhh Range1-100", nH//2)
    id.GetPos(pX, pY, pW, pH)
    _Gui["MyGroup"].Move(,, pX+pW, pH+30)
    id:=_Gui.Add("Checkbox", "x+100 ys vAddFunc", Lang["AddFunc"] " FindText()")
    id.GetPos(pX, pY, pW, pH)
    pW:=pX+pW-15, pW:=(pW<720?720:pW), w:=pW//5
    _Gui.Add("Button", "xm y+18 w" w " vCutL2", Lang["CutL2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutR2", Lang["CutR2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutU2", Lang["CutU2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCutD2", Lang["CutD2"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vUpdate", Lang["Update"])
    G_G.Call()
    _Gui.SetFont("s6 bold", "Verdana")
    _Gui.Add("Edit", "xm y+10 w" pW " h260 vMyPic -Wrap HScroll")
    _Gui.SetFont("s12 norm", "Verdana")
    w:=pW//3
    _Gui.Add("Button", "xm w" w " vCapture", Lang["Capture"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vTest", Lang["Test"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vCopy", Lang["Copy"])
    G_G.Call()
    _Gui.Add("Button", "xm y+0 wp vCaptureS", Lang["CaptureS"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetRange", Lang["GetRange"])
    G_G.Call()
    _Gui.Add("Button", "x+0 wp vGetOffset", Lang["GetOffset"])
    G_G.Call()
    _Gui.Add("Edit", "xm y+10 w130 hp vClipText")
    _Gui.Add("Button", "x+0 vPaste", Lang["Paste"])
    G_G.Call()
    _Gui.Add("Button", "x+0 vTestClip", Lang["TestClip"])
    G_G.Call()
    id:=_Gui.Add("Button", "x+0 vGetClipOffset", Lang["GetClipOffset"])
    G_G.Call()
    id.GetPos(x,, w)
    w:=((pW+15)-(x+w))//2
    _Gui.Add("Edit", "x+0 w" w " hp vOffset")
    _Gui.Add("Button", "x+0 wp vCopyOffset", Lang["CopyOffset"])
    G_G.Call()
    _Gui.SetFont("cBlue")
    id:=_Gui.Add("Edit", "xm w" pW " h250 vscr -Wrap HScroll"), hscr:=id.Hwnd
    _Gui.Title:=Lang["s4"]
    _Gui.Show("Hide")
    G_.Call("LoadScr")
    OnExit(G_SaveScr)
    return
  Case "LoadScr":
    f:=A_Temp "\~scr1.tmp"
    FileRead, s, % f
    FindText_Main["scr"].Value:=s
    return
  Case "SaveScr":
    f:=A_Temp "\~scr1.tmp"
    s:=FindText_Main["scr"].Value
    Try FileDelete % f
    FileAppend % s, % f
    return
  Case "Capture", "CaptureS":
    _Gui:=FindText_Main
    if show_gui:=WinExist("ahk_id " _Gui.Hwnd)
      this.Hide()
    if (cmd="Capture")
    {
      w:=_Gui["Myww"].Value
      h:=_Gui["Myhh"].Value
      p:=this.GetRange(w, h)
      sx:=p[1], sy:=p[2], sw:=p[3]-p[1]+1, sh:=p[4]-p[2]+1
      , Bind_ID:=p[5], bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(1)
    }
    else
    {
      sx:=0, sy:=0, sw:=1, sh:=1, Bind_ID:=WinExist("A"), bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(2)
    }
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(x,y,w,h,(arg1=0?0:1))
    Pics:=[], Pics[hBM]:=1, hBM_x:=hBM_y:=0
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    Names:=["HBITMAP:*" hBM], s:="<New>"
    Loop Files, % SavePicDir "*.bmp"
      Names.Push(v:=A_LoopFileFullPath), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    _Gui["SelectBox"].Delete()
    _Gui["SelectBox"].Add(StrSplit(Trim(s,"|"),"|"))
    ;------------------------
    s:="SelGray|SelColor|SelR|SelG|SelB|Threshold|Comment|ColorList"
    Loop Parse, s, |
      _Gui[A_LoopField].Value:=""
    For k,v in ["Similar1","Similar2","Similar3"]
      _Gui[v].Value:=90
    _Gui["Modify"].Value:=Modify:=0
    _Gui["MultiColor"].Value:=MultiColor:=0
    _Gui["FindShape"].Value:=FindShape:=0
    _Gui["GrayDiff"].Value:=50
    _Gui["Gray2Two"].Focus()
    _Gui["Gray2Two"].Opt("+Default")
    _Gui.Show("Center")
    Event:=Result:=""
    DetectHiddenWindows 0
    Critical, Off
    WinWaitClose % "ahk_id " _Gui.Hwnd
    Critical
    ToolTip
    Pics[hBM]:=1, hBM_old:=0
    For k,v in Pics
      Try DllCall("DeleteObject", "Ptr",k)
    Text:=RegExMatch(Result,"O)\|<[^>\n]*>[^$\n]+\$[^""\r\n]+",r)?r[0]:""
    ;------------------------
    _Gui:=FindText_Main
    if (bind_mode!="")
    {
      WinGetTitle, tt, ahk_id %Bind_ID%
      WinGetClass, tc, ahk_id %Bind_ID%
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt,"[;``]","``$0"),"""","""""")
      Result:="`nSetTitleMatchMode 2`nid:=WinExist(""" tt """)"
        . "`nFindText().BindWindow(id" (bind_mode=0 ? "":"," bind_mode)
        . ")  `; " Lang["s6"] " FindText().BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      s:=""
      if (!A_IsCompiled)
        Try FileRead, s, %A_LineFile%
      re:="Oi)\n\s*FindText[^\n]+args\*[\s\S]*?Script_End[(){}\s]+}"
      s:=RegExMatch(s, re, r) ? "`n;==========`n" r[0] "`n" : ""
      _Gui["scr"].Value:=Result "`n" s
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    else if (Event="SplitAdd" || Event="AllAdd")
    {
      s:=_Gui["scr"].Value
      r:=SubStr(s, 1, InStr(s,"=FindText("))
      i:=j:=0, re:="<[^>\n]*>[^$\n]+\$[^""\r\n]+"
      While j:=RegExMatch(r, re,, j+1)
        i:=InStr(r, "`n", 0, j)
      _Gui["scr"].Value:=SubStr(s,1,i) . Result . SubStr(s,i+1)
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    if (Event) && RegExMatch(Result, "O)\$\d+\.[\w+/]{1,100}", r)
      this.EditScroll(hscr, "\Q" r[0] "\E")
    Event:=Result:=s:=""
    ;----------------------
    if (show_gui && arg1="")
      G_Show.Call()
    else Clipboard:=Text
    return Text
  Case "CaptureUpdate":
    nX:=sx, nY:=sy, nW:=sw, nH:=sh
    bits:=this.GetBitsFromScreen(nX,nY,nW,nH,0,zx,zy)
    cors:=[], show:=[], ascii:=[]
    , SelPos:=bg:=color:=Result:=""
    , dx:=dy:=CutLeft:=CutRight:=CutUp:=CutDown:=0
    ListLines % (lls:=A_ListLines)?0:0
    if (nW>0 && nH>0 && bits.Scan0)
    {
      j:=bits.Stride-nW*4, p:=bits.Scan0+(nY-zy)*bits.Stride+(nX-zx)*4-j-4
      Loop % nH + 0*(k:=0)
      Loop % nW + 0*(p+=j)
        show[++k]:=1, cors[k]:=NumGet(0|p+=4,"uint")
    }
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)<nW && ty<nH ? cors[ty*nW+tx+1]:WindowColor), C_[++k])
    Loop % 71 + 0*(k:=71*25)
      this.SC(0xFFFFAA, C_[++k])
    ListLines % lls
    _Gui:=FindText_Capture
    _Gui["MySlider1"].Enabled:=nW>71
    _Gui["MySlider2"].Enabled:=nH>25
    _Gui["MySlider1"].Value:=0
    _Gui["MySlider2"].Value:=0
    return
  Case "PicUpdate":
    Try i:=0, i:=Pics.HasKey(hBM_old)
    Try (!i) && DllCall("DeleteObject", "Ptr",hBM_old)
    this.GetBitmapWH(hBM, hBM_w, hBM_h), hBM_old:=hBM
    G_.Call("PicShow", 1)
    return
  Case "MySlider3", "MySlider4":
    hBM_x:=Round(FindText_Capture["MySlider3"].Value*(hBM_w-Pic_w)/100)
    hBM_y:=Round(FindText_Capture["MySlider4"].Value*(hBM_h-Pic_h)/100)
    G_.Call("PicShow")
    return
  Case "PicShow":
    w:=hBM_w-Pic_w, h:=hBM_h-Pic_h
    , hBM_x:=Max(Min(hBM_x,w),0), hBM_y:=Max(Min(hBM_y,h),0)
    if (w<0 || h<0)
      this.DrawHBM(Pic_hBM, [[0, 0, Pic_w, Pic_h, WindowColor]])
    this.CopyHBM(Pic_hBM,0,0,hBM,hBM_x,hBM_y,Min(Pic_w,hBM_w),Min(Pic_h,hBM_h))
    if (arg1)
      G_PicShowOK.Call()
    else
    {
      this.BitmapToWindow(hPic,0,0,Pic_hBM,0,0,Pic_w,Pic_h)
      SetTimer % G_PicShowOK, -1000
    }
    FindText_Capture["MySlider3"].Value:=w>0?Round(hBM_x/w*100):0
    FindText_Capture["MySlider4"].Value:=h>0?Round(hBM_y/h*100):0
    return
  Case "PicShowOK":
    FindText_Capture[hPic].Value:="*w0 *h0 HBITMAP:*" Pic_hBM
    return
  Case "Reset":
    G_.Call("CaptureUpdate")
    return
  Case "LoadPic":
    FindText_Capture.Opt("+OwnDialogs")
    f:=arg1
    if (f="")
    {
      if !FileExist(SavePicDir)
        FileCreateDir % SavePicDir
      f:=SavePicDir "*.bmp"
      Loop Files, % f
        f:=A_LoopFileFullPath
      FileSelectFile, f,, %f%, Select Picture
    }
    if !InStr(f,"HBITMAP:") && !FileExist(f)
    {
      MsgBox, 4096, Tip, % Lang["s17"]
      return
    }
    if !this.ShowPic(f, 0, sx, sy, sw, sh)
      return
    hBM:=this.BitmapFromScreen(sx, sy, sw, sh, 0)
    sw:=Min(sw,71), sh:=Min(sh,25)
    G_.Call("CaptureUpdate")
    G_.Call("PicUpdate")
    return
  Case "SavePic":
    FindText_Capture.Hide()
    this.ScreenShot(), this.ShowPic("HBITMAP:*" hBM)
    Try this.GuiFromHwnd(WinExist("Show Pic")).Opt("+OwnDialogs")
    Loop
    {
      p:=this.GetRange2()
      MsgBox, 4099, Tip, % Lang["s15"]
      IfMsgBox, No
        Continue
      Break
    }
    IfMsgBox, Yes
      G_.Call("ScreenShot", p[1] "|" p[2] "|" p[3] "|" p[4] "|0")
    this.ShowPic()
    return
  Case "SelectBox":
    SelectBox:=FindText_Capture["SelectBox"].Value
    Try f:="", f:=Names[SelectBox]
    if (f!="")
      G_.Call("LoadPic", f)
    return
  Case "ClearAll":
    FindText_Capture.Opt("+OwnDialogs")
    MsgBox, 4100, Tip, % Lang["s19"]
    IfMsgBox, Yes
    {
      FindText_Capture.Hide()
      FileDelete % SavePicDir "*.bmp"
    }
    return
  Case "OpenDir":
    if !FileExist(SavePicDir)
      FileCreateDir % SavePicDir
    Run % SavePicDir
    return
  Case "GetRange":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    p:=this.GetRange2(), v:=p[1] ", " p[2] ", " p[3] ", " p[4]
    s:=_Gui["scr"].Value
    re:="i)(=FindText\([^\n]*?)([^(,\n]*,){4}([^,\n]*,[^,\n]*,[^,\n]*Text)"
    if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
    {
      s:=RegExReplace(s, re, "$1 " v ",$3",, 1)
      _Gui["scr"].Value:=s
    }
    _Gui["Offset"].Value:=v
    G_Show.Call()
    return
  Case "Test", "TestClip":
    _Gui:=FindText_Main
    _Gui.Opt("+LastFound")
    this.Hide()
    ;----------------------
    if (cmd="Test")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if (cmd="Test") && InStr(s, "MCode(")
    {
      s:="`n#NoEnv`nMenu, Tray, Click, 1`n" s "`nExitApp`n"
      Thread1:=new this.Thread(s)
      DetectHiddenWindows, 1
      WinWait % "ahk_class AutoHotkey ahk_pid " Thread1.pid,, 3
      if (!ErrorLevel)
        WinWaitClose,,, 30
      ; Thread1:=""  ; kill the Thread
    }
    else
    {
      t:=A_TickCount, v:=X:=Y:=""
      if RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
        v:=this.FindText(X, Y, 0,0,0,0, 0,0, r[0])
      r:=StrSplit(Lang["s8"] "||||", "|")
      MsgBox, 4096, Tip, % r[1] ":`t" (IsObject(v)?v.Length():v) "`n`n"
        . r[2] ":`t" (A_TickCount-t) " " r[3] "`n`n"
        . r[4] ":`t" X ", " Y "`n`n"
        . r[5] ":`t<" (IsObject(v)?v[1].id:"") ">", 3
      Try For i,j in v
        if (i<=2)
          this.MouseTip(j.x, j.y)
      v:="", Clipboard:=X "," Y
    }
    ;----------------------
    G_Show.Call()
    return
  Case "GetOffset", "GetClipOffset":
    FindText_Main.Hide()
    p:=this.GetRange()
    _Gui:=FindText_Main
    if (cmd="GetOffset")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if RegExMatch(s, "O)<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    && this.FindText(X, Y, 0,0,0,0, 0,0, r[0])
    {
      r:=StrReplace("X+" ((p[1]+p[3])//2-X)
        . ", Y+" ((p[2]+p[4])//2-Y), "+-", "-")
      if (cmd="GetOffset")
      {
        re:="i)(\(\)\.\w*Click\w*\()[^,\n]*,[^,)\n]*"
        if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
          s:=RegExReplace(s, re, "$1" r,, 1)
        _Gui["scr"].Value:=s
      }
      _Gui["Offset"].Value:=r
    }
    s:="", G_Show.Call()
    return
  Case "Paste":
    if RegExMatch(Clipboard, "O)\|?<[^>\n]*>[^$\n]+\$[^""\r\n]+", r)
    {
      FindText_Main["ClipText"].Value:=r[0]
      FindText_Main["MyPic"].Value:=Trim(this.ASCII(r[0]),"`n")
    }
    return
  Case "CopyOffset":
    Clipboard:=FindText_Main["Offset"].Value
    return
  Case "Copy":
    ControlGet, s, Selected,,, ahk_id %hscr%
    if (s="")
    {
      s:=FindText_Main["scr"].Value
      r:=FindText_Main["AddFunc"].Value
      if (r != 1)
        s:=RegExReplace(s, "i)\n\s*FindText[^\n]+args\*[\s\S]*")
        , s:=RegExReplace(s, "i)\n; ok:=FindText[\s\S]*")
        , s:=SubStr(s, (s~="i)\n[ \t]*Text"))
    }
    Clipboard:=RegExReplace(s, "\R", "`r`n")
    ControlFocus,, % "ahk_id " hscr
    return
  Case "Apply":
    _Gui:=FindText_Main
    NowHotkey:=_Gui["NowHotkey"].Value
    SetHotkey1:=_Gui["SetHotkey1"].Value
    SetHotkey2:=_Gui["SetHotkey2"].Text
    if (NowHotkey!="")
      Hotkey, *%NowHotkey%,, Off UseErrorLevel
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Hotkey, *%k%, %G_ScreenShot%, On UseErrorLevel
    _Gui["NowHotkey"].Value:=k
    _Gui["SetHotkey1"].Value:=""
    _Gui["SetHotkey2"].Choose(0)
    return
  Case "ScreenShot":
    Critical
    if !FileExist(SavePicDir)
      FileCreateDir % SavePicDir
    Loop
      f:=SavePicDir . Format("{:03d}.bmp",A_Index)
    Until !FileExist(f)
    this.SavePic(f, StrSplit(arg1,"|")*)
    CoordMode, ToolTip
    this.ToolTip(Lang["s9"],, 0,, { bgcolor:"Yellow", color:"Red"
      , size:48, bold:"bold", trans:200, timeout:0.2 })
    return
  Case "Bind0", "Bind1", "Bind2", "Bind3", "Bind4":
    this.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,5))
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(x,y,w,h,1)
    G_.Call("PicUpdate")
    FindText_Capture["MyTab1"].Choose(2)
    this.BindWindow(0)
    return
  Case "MySlider1", "MySlider2":
    SetTimer % G_Slider, -10
    return
  Case "Slider":
    Critical
    dx:=nW>71 ? Round(FindText_Capture["MySlider1"].Value*(nW-71)/100):0
    dy:=nH>25 ? Round(FindText_Capture["MySlider2"].Value*(nH-25)/100):0
    if (oldx=dx && oldy=dy)
      return
    ListLines % (lls:=A_ListLines)?0:0
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
      this.SC(((++tx)>=nW || ty>=nH || !show[i:=ty*nW+tx+1]
      ? WindowColor : bg="" ? cors[i] : ascii[i] ? 0:0xFFFFFF), C_[++k])
    Loop % 71*(oldx!=dx) + 0*(i:=nW*nH+dx)*(k:=71*25)
      this.SC((show[++i]?0xFF0000:0xFFFFAA), C_[++k])
    ListLines % lls
    oldx:=dx, oldy:=dy
    return
  Case "RepColor", "CutColor":
    if (cmd="RepColor")
      show[k]:=1, c:=(bg="" ? cors[k] : ascii[k] ? 0:0xFFFFFF)
    else
      show[k]:=0, c:=WindowColor
    if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
      this.SC(c, C_[ty*71+tx+1])
    return
  Case "RepL":
    if (CutLeft<=0) || (bg!="" && InStr(color,"**") && CutLeft=1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutL3":
    Loop 3
      G_.Call("CutL")
    return
  Case "RepR":
    if (CutRight<=0) || (bg!="" && InStr(color,"**") && CutRight=1)
      return
    k:=1-CutRight, CutRight--
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("RepColor"))
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop % nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && G_.Call("CutColor"))
    return
  Case "CutR3":
    Loop 3
      G_.Call("CutR")
    return
  Case "RepU":
    if (CutUp<=0) || (bg!="" && InStr(color,"**") && CutUp=1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutU3":
    Loop 3
      G_.Call("CutU")
    return
  Case "RepD":
    if (CutDown<=0) || (bg!="" && InStr(color,"**") && CutDown=1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("RepColor"))
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop % nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && G_.Call("CutColor"))
    return
  Case "CutD3":
    Loop 3
      G_.Call("CutD")
    return
  Case "Gray2Two":
    ListLines % (lls:=A_ListLines)?0:0
    gs:=[], k:=0
    Loop % nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    _Gui:=FindText_Capture
    _Gui["Threshold"].Focus()
    Threshold:=_Gui["Threshold"].Value
    if (Threshold="")
    {
      pp:=[]
      Loop 256
        pp[A_Index-1]:=0
      Loop % nW*nH
        if (show[A_Index])
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
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      _Gui["Threshold"].Value:=Threshold
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop % nW*nH
      ascii[++k]:=v:=(gs[k]<=Threshold)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "GrayDiff2Two":
    _Gui:=FindText_Capture
    GrayDiff:=_Gui["GrayDiff"].Value
    if (GrayDiff="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s11"], 1
      return
    }
    ListLines % (lls:=A_ListLines)?0:0
    gs:=[], k:=0
    Loop % nW*nH
      gs[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    if (CutLeft=0)
      G_.Call("CutL")
    if (CutRight=0)
      G_.Call("CutR")
    if (CutUp=0)
      G_.Call("CutU")
    if (CutDown=0)
      G_.Call("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop % nW*nH
      j:=gs[++k]+GrayDiff
      , ascii[k]:=v:=( gs[k-1]>j || gs[k+1]>j
      || gs[k-nW]>j || gs[k+nW]>j
      || gs[k-nW-1]>j || gs[k-nW+1]>j
      || gs[k+nW-1]>j || gs[k+nW+1]>j )
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "AddColorSim", "AddColorDiff":
    _Gui:=FindText_Capture
    c:=StrReplace(_Gui["SelColor"].Value, "0x")
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s12"], 1
      return
    }
    s:=_Gui["ColorList"].Value
    if InStr(cmd, "Sim")
      v:=_Gui["Similar1"].Value, v:=c "-" Round(v/100,2)
    else
      v:=_Gui["dRGB2"].Value, v:=c "-" Format("{:06X}",v<<16|v<<8|v)
    s:=RegExReplace("/" s, "/" c "-[^/]*") . "/" v
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend,, {End}, % "ahk_id " _Gui["ColorList"].Hwnd
    G_.Call("Color2Two")
    return
  Case "Undo2":
    _Gui:=FindText_Capture
    s:=_Gui["ColorList"].Value
    s:=RegExReplace("/" s, "/[^/]+$")
    _Gui["ColorList"].Value:=Trim(s,"/")
    ControlSend,, {End}, % "ahk_id " _Gui["ColorList"].Hwnd
    return
  Case "Color2Two":
    _Gui:=FindText_Capture
    color:=RegExReplace(_Gui["ColorList"].Value, "i)\s|0x")
    if (color="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s16"], 1
      return
    }
    ListLines % (lls:=A_ListLines)?0:0
    k:=i:=v:=0, arr:=StrSplit(Trim(StrReplace(color,"@","-"), "/"), "/")
    Loop % nW*nH
    {
      c:=cors[++k], rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
      For k1,v1 in arr
      {
        r:=StrSplit(Trim(v1,"-") "-", "-"), c:=this.ToRGB(r[1]), n:=r[2]
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        if InStr(n, ".")
        {
          n:=this.Floor(n), n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
          if v:=(3*r*r+4*g*g+2*b*b<=n)
            Break
        }
        else
        {
          c:=this.Floor("0x" n), dR:=(c>>16)&0xFF, dG:=(c>>8)&0xFF, dB:=c&0xFF
          if v:=(Abs(r)<=dR && Abs(g)<=dG && Abs(b)<=dB)
            Break
        }
      }
      ascii[k]:=v, (show[k] && i:=(v?i+1:i-1))
    }
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "ColorPos2Two":
    _Gui:=FindText_Capture
    c:=_Gui["SelColor"].Value
    if (c="")
    {
      _Gui.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s12"], 1
      return
    }
    n:=_Gui["Similar2"].Value, n:=Round(n/100,2), color:="#" c "-" n
    , n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF, k:=i:=0
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nW*nH
      c:=cors[++k], r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
      , ascii[k]:=v:=3*r*r+4*g*g+2*b*b<=n, (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), G_.Call("BlackWhite")
    ListLines % lls
    return
  Case "BlackWhite":
    Loop % 25 + 0*(ty:=dy-1)*(k:=0)
    Loop % 71 + 0*(tx:=dx-1)*(ty++)
    if (k++)*0 + (++tx)<nW && ty<nH && show[i:=ty*nW+tx+1]
      this.SC((ascii[i]?0:0xFFFFFF), C_[k])
    return
  Case "Modify":
    Modify:=FindText_Capture["Modify"].Value
    return
  Case "MultiColor":
    MultiColor:=FindText_Capture["MultiColor"].Value
    Result:=""
    ToolTip
    return
  Case "FindShape":
    FindShape:=FindText_Capture["FindShape"].Value
    (FindShape && !MultiColor) && FindText_Capture["MultiColor"].Value:=MultiColor:=1
    return
  Case "Undo":
    Result:=RegExReplace(Result, ",[^/]+/[^/]+/[^/]+$")
    ToolTip % Trim(Result, ",")
    return
  Case "Similar1", "Similar2", "Similar3":
    i:=FindText_Capture[cmd].Value
    For k,v in ["Similar1","Similar2","Similar3"]
      (v!=cmd) && FindText_Capture[v].Value:=i
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    k:=0
    ListLines % (lls:=A_ListLines)?0:0
    Loop % nH
    {
      v:=""
      Loop % nW
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines % lls
    return
  Case "Auto":
    G_.Call("GetTxt")
    if (txt="")
    {
      FindText_Capture.Opt("+OwnDialogs")
      MsgBox, 4096, Tip, % Lang["s13"], 1
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt, "^" bg "+\n"), G_.Call("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt, "m`n)" bg "$"), G_.Call("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt, "\n\K" bg "+\n$"), G_.Call("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt, "m`n)^" bg), G_.Call("CutL")
      else Break
    }
    txt:=""
    return
  Case "OK", "SplitAdd", "AllAdd":
    _Gui:=FindText_Capture
    _Gui.Opt("+OwnDialogs")
    G_.Call("GetTxt")
    if (txt="") && (!MultiColor)
    {
      MsgBox, 4096, Tip, % Lang["s13"], 1
      return
    }
    if InStr(color,"#") && (!MultiColor)
    {
      k:=i:=j:=0
      ListLines % (lls:=A_ListLines)?0:0
      Loop % nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=SelPos)
        {
          j:=i
          Break
        }
      }
      ListLines % lls
      if (j=0)
      {
        MsgBox, 4096, Tip, % Lang["s12"], 1
        return
      }
      color:="#" j "-" StrSplit(color "-","-")[2]
    }
    Comment:=_Gui["Comment"].Value
    if (cmd="SplitAdd") && (!MultiColor)
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
        if (!show[k++] && A_Index<w)
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
          v:=Format("{:d}.",InStr(v,"`n")-1) . this.bit2base64(v)
          s.="`nText.=""|<" SubStr(Comment,1,1) ">" color "$" v """`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}.",InStr(txt,"`n")-1) . this.bit2base64(txt)
    else
    {
      n:=_Gui["Similar3"].Value, n:=Round(n/100,2), color:="##" n
      , n:=(n<=0||n>1?0:Floor(9*255*255*(1-n)*(1-n)))
      , arr:=StrSplit(Trim(StrReplace(Result,",","/"),"/"),"/"), s:="", i:=1
      SetFormat, IntegerFast, d
      Loop % arr.Length()//3
        x1:=arr[i++], y1:=arr[i++], c1:=arr[i++], c:="0x" c1
        , (A_Index=1 && (x:=x1, y:=y1, rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF))
        , r:=((c>>16)&0xFF)-rr, g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb
        , s.="," (x1-x) "/" (y1-y) "/" (FindShape?3*r*r+4*g*g+2*b*b<=n:c1)
      txt:=SubStr(s,2)
    }
    s:="`nText.=""|<" Comment ">" color "$" txt """`n"
    if (cmd="SplitAdd" || cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      _Gui.Hide()
      return
    }
    x:=nX+CutLeft+(nW-CutLeft-CutRight)//2
    y:=nY+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["s8"] "|||||||", "|")
    s:="`; #Include <FindText>`n"
    . "`nt1:=A_TickCount, Text:=X:=Y:=""""`n" s
    . "`nif (ok:=FindText(X, Y, " x "-150000, "
    . y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n{"
    . "`n  `; FindText()." . "Click(" . "X, Y, ""L"")"
    . "`n}`n"
    . "`n`; ok:=FindText(X:=""wait"", Y:=3, 0,0,0,0,0,0,Text)    `; " r[7]
    . "`n`; ok:=FindText(X:=""wait0"", Y:=-1, 0,0,0,0,0,0,Text)  `; " r[8]
    . "`n`nMsgBox, 4096, Tip, `% """ r[1] ":``t"" (IsObject(ok)?ok.Length():ok)"
    . "`n  . ""``n``n" r[2] ":``t"" (A_TickCount-t1) "" " r[3] """"
    . "`n  . ""``n``n" r[4] ":``t"" X "", "" Y"
    . "`n  . ""``n``n" r[5] ":``t<"" (IsObject(ok)?ok[1].id:"""") "">""`n"
    . "`nTry For i,v in ok  `; ok " r[6] " ok:=FindText().ok"
    . "`n  if (i<=2)"
    . "`n    FindText().MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    _Gui.Hide()
    return
  Case "SavePic2":
    x:=nX+CutLeft, w:=nW-CutLeft-CutRight
    y:=nY+CutUp, h:=nH-CutUp-CutDown
    G_.Call("ScreenShot", x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "ShowPic":
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    FindText_Main["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    return
  Case "KeyDown":
    Critical
    _Gui:=FindText_Main
    if (WinExist()!=_Gui.Hwnd)
      return
    Try ctrl:="", ctrl:=args[3]
    if (ctrl=hscr)
      SetTimer % G_ShowPic, -150
    else if (ctrl=_Gui["ClipText"].Hwnd)
    {
      s:=_Gui["ClipText"].Value
      _Gui["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    }
    return
  Case "LButtonDown":
    Critical
    if (WinExist()!=FindText_Capture.Hwnd)
      return G_.Call("KeyDown", arg1, args*)
    CoordMode, Mouse
    MouseGetPos, k1, k2,, k6, 2
    if (k6=hPic)
    {
      ListLines % (lls:=A_ListLines)?0:0
      Loop
      {
        Sleep 50
        MouseGetPos, k3, k4
        this.RangeTip(Min(k1,k3), Min(k2,k4)
        , Abs(k1-k3)+1, Abs(k2-k4)+1, (A_MSec<500 ? "Red":"Blue"))
      }
      Until !this.State("LButton")
      ListLines % lls
      this.RangeTip()
      this.GetBitsFromScreen(,,,,0,zx,zy)
      this.ClientToScreen(sx, sy, 0, 0, hPic)
      sx:=Min(k1,k3)-sx+hBM_x+zx, sy:=Min(k2,k4)-sy+hBM_y+zy
      , sw:=Abs(k1-k3)+1, sh:=Abs(k2-k4)+1
      if (sw+sh)<5
        sx-=71//2, sy-=25//2, sw:=71, sh:=25
      G_.Call("CaptureUpdate")
      FindText_Capture["MyTab1"].Choose(1)
      return
    }
    if !(Cid_.HasKey(k6) && k5:=Cid_[k6])
      return
    if (k5=-1)
    {
      MouseMove, k1+2, k2+2, 0
      MouseGetPos,,,, k6, 2
      MouseMove, k1, k2, 0
      if !(Cid_.HasKey(k6) && k5:=Cid_[k6]) || (k5=-1)
        return
    }
    if (k5>71*25)
    {
      k1:=nW*nH+dx+(k5-71*25)
      this.SC(((show[k1]:=!show[k1])?0xFF0000:0xFFFFAA), k6)
      return
    }
    k3:=Mod(k5-1,71)+dx, k4:=(k5-1)//71+dy
    if (k3>=nW || k4>=nH)
      return
    k1:=k4*nW+k3+1
    if (Modify && bg!="" && show[k1])
      this.SC(((ascii[k1]:=!ascii[k1])?0:0xFFFFFF), k6)
    else
    {
      k2:=cors[k1], SelPos:=k1
      _Gui:=FindText_Capture
      _Gui["SelGray"].Value:=(((k2>>16)&0xFF)*38+((k2>>8)&0xFF)*75+(k2&0xFF)*15)>>7
      _Gui["SelColor"].Value:=Format("0x{:06X}",k2&0xFFFFFF)
      _Gui["SelR"].Value:=(k2>>16)&0xFF
      _Gui["SelG"].Value:=(k2>>8)&0xFF
      _Gui["SelB"].Value:=k2&0xFF
    }
    if (MultiColor && show[k1])
    {
      (FindShape && Result="") && G_.Call("ColorPos2Two")
      k2:=Format(",{:d}/{:d}/{:06X}", nX+k3, nY+k4, cors[k1]&0xFFFFFF)
      , Result.=InStr(Result,k2) ? "":k2
      ToolTip % Trim(Result, ",")
    }
    return
  Case "RButtonDown":
    Critical
    MouseGetPos,,,, k2, 2
    if (k2!=hPic)
      return
    CoordMode, Mouse
    MouseGetPos, k1, k2
    k5:=hBM_x, k6:=hBM_y
    ListLines % (lls:=A_ListLines)?0:0
    Loop
    {
      Sleep 10
      MouseGetPos, k3, k4
      hBM_x:=k5+k1-k3, hBM_y:=k6+k2-k4
      G_.Call("PicShow")
    }
    Until !this.State("RButton")
    ListLines % lls
    return
  Case "MouseMove":
    Try ctrl_name:="", ctrl_name:=this.GuiCtrlFromHwnd(args[3]).Name
    if (PrevControl != ctrl_name)
    {
      ToolTip
      PrevControl:=ctrl_name
      Try SetTimer % G_ToolTip, % (PrevControl ? -500:"Off")
      Try SetTimer % G_ToolTipOff, % (PrevControl ? -5500:"Off")
    }
    return
  Case "ToolTip":
    MouseGetPos,,, _TT
    if WinExist("ahk_id " _TT " ahk_class AutoHotkeyGUI")
      Try ToolTip % Tip_Text[PrevControl]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2", "CutR2", "CutU2", "CutD2":
    s:=FindText_Main["MyPic"].Value
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    FindText_Main["MyPic"].Value:=Trim(s,"`n")
    return
  Case "Update":
    ControlFocus,, % "ahk_id " hscr
    ControlGet, i, CurrentLine,,, ahk_id %hscr%
    ControlGet, s, Line, %i%,, ahk_id %hscr%
    if !RegExMatch(s, "O)(<[^>\n]*>[^$\n]+\$)\d+\.[\w+/]+", r)
      return
    v:=FindText_Main["MyPic"].Value
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s, r[0], r[1] . w "." this.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend,, %v%, ahk_id %hscr%
    Control, EditPaste, %s%,, ahk_id %hscr%
    ControlSend,, {Home}, ahk_id %hscr%
    return
  }
}

Lang(text:="", getLang:=0)
{
  local
  static init, Lang1, Lang2
  if !VarSetCapacity(init) && (init:="1")
  {
    s:="
    (
Myww       = 宽度 = 调整抓图范围的宽度
Myhh       = 高度 = 调整抓图范围的高度
AddFunc    = 附加 = 复制时带 FindText() 函数
NowHotkey  = 截屏热键 = 当前的截屏热键
SetHotkey1 = = 第一优先级的截屏热键
SetHotkey2 = = 第二优先级的截屏热键
Apply      = 应用 = 应用新的截屏热键
CutU2      = 上删 = 裁剪下面编辑框中文字的上边缘
CutL2      = 左删 = 裁剪下面编辑框中文字的左边缘
CutR2      = 右删 = 裁剪下面编辑框中文字的右边缘
CutD2      = 下删 = 裁剪下面编辑框中文字的下边缘
Update     = 更新 = 更新下面编辑框中文字到代码行中
GetRange   = 获取屏幕范围 = 获取屏幕范围到剪贴板并替换代码中的范围参数
GetOffset  = 获取相对坐标 = 获取相对图像位置的偏移坐标并替换代码中的点击坐标
GetClipOffset  = 获取相对坐标2 = 获取相对左边编辑框的图像的偏移坐标
Capture    = 抓图 = 开始屏幕抓图
CaptureS   = 截屏抓图 = 先截屏，然后显示截屏图像，再手动选择图像内的范围抓图
Test       = 测试 = 测试生成的代码是否可以查找成功
TestClip   = 测试2 = 测试左边文本框中的文字是否可以查找成功，结果复制到剪贴板
Paste      = 粘贴 = 粘贴剪贴板的文字数据
CopyOffset = 复制2 = 复制左边的偏移坐标到剪贴板
Copy       = 复制 = 复制代码到剪贴板
Reset      = 重读 = 重新读取原来的彩色图像
SplitAdd   = 分割添加 = 点击黄色的标签来分割图像为多个图像数据，添加到旧代码中
AllAdd     = 整体添加 = 将文字数据整体添加到旧代码中
Gray2Two      = 灰度阈值二值化 = 灰度小于阈值的为黑色其余白色
GrayDiff2Two  = 灰度差值二值化 = 某点与周围灰度之差大于差值的为黑色其余白色
Color2Two     = 颜色二值化 = 通过颜色列表来转换图像为黑白图
ColorPos2Two  = 颜色位置二值化 = 指定颜色及相似色为黑色其余白色，但是记录该色的位置
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
Modify     = 修改 = 二值化后可以用鼠标在预览区点击手动修改黑白点
MultiColor = 多点找色 = 鼠标选择多种颜色，之后点击“确定”按钮
FindShape  = 找形状 = 鼠标选择多种颜色，会基于第一点的颜色二值化
Undo       = 撤销 = 撤销上一次选择的颜色
Undo2      = 撤销 = 撤销上一次添加到颜色列表的颜色
Comment    = 识别文字 = 识别文本 (包含在<>中)，分割添加时也会分解成单个文字
Threshold  = 灰度阈值 = 灰度阈值 (0-255)
GrayDiff   = 灰度差值 = 灰度差值 (0-255)
Similar1   = 相似度 = 与选定颜色的相似度
Similar2   = 相似度 = 与选定颜色的相似度
Similar3   = 相似度 = 与选定颜色的相似度
AddColorSim  = 添加 = 颜色相似模式添加到颜色列表中再运行颜色二值化
AddColorDiff = 添加 = 颜色偏色模式添加到颜色列表中再运行颜色二值化
ColorList  = = 颜色列表用于转换图像为二值图
DiffRGB    = 红/绿/蓝 = 多色查找时各分量允许的偏差 (0-255)
DiffRGB2   = 红/绿/蓝 = 多色查找时各分量允许的偏差 (0-255)
Bind0      = 绑定窗口1 = 绑定窗口使用GetDCEx()获取后台窗口图像
Bind1      = 绑定窗口1+ = 绑定窗口使用GetDCEx()并修改窗口透明度
Bind2      = 绑定窗口2 = 绑定窗口使用PrintWindow()获取后台窗口图像
Bind3      = 绑定窗口2+ = 绑定窗口使用PrintWindow()并修改窗口透明度
Bind4      = 绑定窗口3 = 绑定窗口使用PrintWindow(,,3)获取后台窗口图像
OK         = 确定 = 生成全新的代码替换旧代码
OK2        = 确定 = 恢复截屏到屏幕然后再抓图
Cancel     = 取消 = 关闭窗口不做任何事
Cancel2    = 取消 = 关闭窗口不做任何事
ClearAll   = 清空 = 清空所有保存的截图
OpenDir    = 打开目录 = 打开保存屏幕截图的目录
SavePic    = 保存图片 = 选择一个范围保存为图片
SavePic2   = 保存图片 = 将修剪后的原始图像保存为图片
LoadPic    = 载入图片 = 载入一张图片作为抓取的图像
ClipText   = = 显示粘贴的文字数据
Offset     = = 显示“获取相对坐标2”或者“获取屏幕范围”的结果
SelectBox  = = 选择截图显示到屏幕左上角
s1  = FindText找字工具
s2  = 灰度阈值|灰度差值|颜色|颜色位置|多色查找
s3  = 图像二值化及分割
s4  = 抓图生成字库及找字代码
s5  = 方向键微调选框\n先点击右键(Ctrl)一次\n把鼠标移开\n再点击右键(Ctrl)一次
s6  = 解绑窗口使用
s7  = 左键(Ctrl)拖动选择范围\n坐标复制到剪贴板
s8  = 找到|时间|毫秒|位置|结果|值可以这样获取|等待3秒等图像出现|无限等待等图像消失
s9  = 截屏成功
s10 = 鼠标位置|穿透显示绑定窗口\n点击右键完成抓图
s11 = 请先设定灰度差值！
s12 = 请先选择核心颜色！
s13 = 请先将图像二值化！
s14 = 不能用于颜色位置二值化模式, 因为分割后会导致位置错误
s15 = 你确定选择的范围吗？\n\n如果不确定，可以重新选择
s16 = 请先添加颜色到颜色列表！
s17 = 你想打开的图片没有找到！
s18 = 捕获|截图
s19 = 你确定要删除所有的截图吗？
    )"
    Lang1:=[], Lang2:=[]
    Loop Parse, s, `n, `r
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v "==","\n","`n"), "=", "`t ")
        , Lang1[r[1]]:=r[2], Lang2[r[1]]:=r[3]
  }
  return getLang=1 ? Lang1 : getLang=2 ? Lang2 : Lang1[text]
}

;---------------------------------
; Gui-V1-V2 Compatibility Library  By FeiYue
;---------------------------------

GuiNew(args*) {
  return new this.GuiCreate(args*)
}

GuiFromHwnd(hwnd:="AllGuiObj", RecurseParent:=0) {
  static init, AllGuiObj
  if !VarSetCapacity(init) && (init:="1")
    AllGuiObj:=[]
  if (hwnd=="AllGuiObj")
    return AllGuiObj
  if (RecurseParent)
    While hwnd && !AllGuiObj.HasKey(hwnd)
      hwnd:=DllCall("GetParent", "Ptr",hwnd, "Ptr")
  return AllGuiObj[hwnd]
}

GuiCtrlFromHwnd(hwnd) {
  return this.GuiFromHwnd(hwnd,1)[hwnd]
}

GuiOnEvent(EventName, args*) {
  return this.GuiFromHwnd(WinExist())["_" EventName].Call(0,args*)
}

GuiClose(args*) {
  return FindText().GuiOnEvent("Close",args*)
}

GuiEscape(args*) {
  return FindText().GuiOnEvent("Escape",args*)
}

GuiSize(args*) {
  return FindText().GuiOnEvent("Size",args*)
}

GuiContextMenu(args*) {
  return FindText().GuiOnEvent("ContextMenu",args*)
}

GuiDropFiles(args*) {
  return FindText().GuiOnEvent("DropFiles",0,args*)
}

Class GuiCreate
{  ;// GuiCreate Class Begin

__New(opts:="", title:="", args*) {
  local
  Gui, New, % opts " +Hwndhwnd +LabelFindTextClass.Gui", % title
  this.Hwnd:=hwnd, this.ClassNN:=[]
  FindText().GuiFromHwnd()[hwnd]:=this
}

__Delete() {
  this.Destroy()
}

Destroy() {
  local
  if !(hwnd:=this.Hwnd)
    return
  this.Hwnd:="", FindText().GuiFromHwnd().Delete(hwnd)
  Try Gui, % hwnd ":Destroy"
  For k,v in this
    (v.Hwnd && v.Hwnd:=""), this[k]:=""
}

OnEvent(EventName, Callback, AddRemove:=1) {
  if IsObject(Callback)
    this["_" EventName]:=Callback
}

Opt(opts) {
  Gui, % this.Hwnd ":" RegExReplace(opts,"i)[+\-\s]Label\S*")
}

Add(type, opts:="", text:="") {
  local
  static init, type2class
  if !VarSetCapacity(init) && (init:="1")
    type2class:=[]
  type:=(type="DropDownList"?"DDL":type="Picture"?"Pic":type)
  name:=RegExMatch(opts,"i)(^|[+\-\s])V(?!Scroll\b|ertical\b)\K\S*",r)?r:""
  opts:=RegExReplace(opts,"i)(^|[+\-\s])V(?!Scroll\b|ertical\b)\S*")
  if IsObject(text)
  {
    s:=""
    For k,v in text
      s.="|" v
    text:=Trim(s, "|")
  }
  Gui, % this.Hwnd ":Add", % type, % opts " +Hwndhwnd", % text
  this.LastHwnd:=hwnd
  if type2class.HasKey(type)
    s:=type2class[type]
  else
  {
    WinGetClass, s, ahk_id %hwnd%
    type2class[type]:=s
  }
  this.ClassNN[s]:=n:=Floor(this.ClassNN[s])+1, classnn:=s . n
  obj:= new this.Control(this.Hwnd, hwnd, type, classnn, name)
  this[hwnd]:=obj, this[classnn]:=obj
  if (name) && !(name~="i)^(Destroy|OnEvent|Opt|Add"
  . "|SetFont|Show|Hide|Move|GetClientPos|GetPos|Maximize"
  . "|Minimize|Restore|Flash|Submit|Hwnd|Name|Title"
  . "|BackColor|MarginX|MarginY|MenuBar|FocusedCtrl)$")
    this[name]:=obj
  return obj
}

SetFont(opts:="", FontName:="") {
  Gui, % this.Hwnd ":Font", % opts, % FontName
}

Show(opts:="", args*) {
  Gui, % this.Hwnd ":Show", % opts
}

Hide() {
  Gui, % this.Hwnd ":Hide"
}

Move(x:="", y:="", w:="", h:="") {
  local
  this.GetPos(pX, pY, pW, pH)
  x:=(x=""?pX:x), y:=(y=""?pY:y), w:=(w=""?pW:w), h:=(h=""?pH:h)
  DllCall("MoveWindow", "Ptr",this.Hwnd, "int",x, "int",y, "int",w, "int",h, "int",1)
}

GetClientPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetClientRect",  "Ptr",this.Hwnd, "Ptr",&rect)
  , DllCall("ClientToScreen", "Ptr",this.Hwnd, "Ptr",&rect)
  , x:=NumGet(rect, 0, "int"), y:=NumGet(rect, 4, "int")
  , w:=NumGet(rect, 8, "int")-x, h:=NumGet(rect, 12, "int")-y
}

GetPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  VarSetCapacity(rect, 16, 0)
  , DllCall("GetWindowRect",  "Ptr",this.Hwnd, "Ptr",&rect)
  , x:=NumGet(rect, 0, "int"), y:=NumGet(rect, 4, "int")
  , w:=NumGet(rect, 8, "int")-x, h:=NumGet(rect, 12, "int")-y
}

Maximize() {
  Gui, % this.Hwnd ":Maximize"
}

Minimize() {
  Gui, % this.Hwnd ":Minimize"
}

Restore() {
  Gui, % this.Hwnd ":Restore"
}

Flash(k:=1) {
  Gui, % this.Hwnd ":Flash", % k ? "":"Off"
}

Submit(hide:=1) {
  local
  (hide && this.Hide()), arr:=[]
  For k,v in this
    if k is number
      if (v.Name!="")
        arr[v.Name]:=v.Value
  return arr
}

BackColor {
  get {
    return this._BackColor
  }
  set {
    this._BackColor:=value
    Gui, % this.Hwnd ":Color", % value
    return value
  }
}

MarginX {
  get {
    return this._MarginX
  }
  set {
    this._MarginX:=value
    Gui, % this.Hwnd ":Margin", % value
    return value
  }
}

MarginY {
  get {
    return this._MarginY
  }
  set {
    this._MarginY:=value
    Gui, % this.Hwnd ":Margin",, % value
    return value
  }
}

MenuBar {
  get {
    return this._MenuBar
  }
  set {
    this._MenuBar:=value
    Gui, % this.Hwnd ":Menu", % value
    return value
  }
}

Title {
  get {
    local
    VarSetCapacity(v, 260*2)
    DllCall("GetWindowText", "Ptr",this.Hwnd, "Str",v, "Int",260)
    return v
  }
  set {
    DllCall("SetWindowText", "Ptr",this.Hwnd, "Str",value)
    return value
  }
}

FocusedCtrl {
  get {
    local
    GuiControlGet, v, % this.Hwnd ":Focus"
    return this[v]
  }
}

Class Control
{  ;// Control Class Begin

__New(GuiHwnd, hwnd, type, classnn, name) {
  this.GuiHwnd:=GuiHwnd, this.Hwnd:=hwnd
  this.Type:=type, this.ClassNN:=classnn, this.Name:=name
}

Opt(opts) {
  GuiControl, % opts, % this.Hwnd
}

OnEvent(EventName, Callback, AddRemove:=1) {
  local
  r:=this.OnEvent_G.Bind(this, Callback)
  GuiControl, +g, % this.Hwnd, % r
}

OnEvent_G(Callback, args*) {
  if IsObject(Callback)
    return %Callback%(this, args*)
}

GetPos(ByRef x:="", ByRef y:="", ByRef w:="", ByRef h:="") {
  local
  GuiControlGet, p, Pos, % this.Hwnd
  x:=Floor(pX), y:=Floor(pY), w:=Floor(pW), h:=Floor(pH)
}

Move(x:="", y:="", w:="", h:="") {
  local
  s:=(x=""?"":" x" x) (y=""?"":" y" y) (w=""?"":" w" w) (h=""?"":" h" h)
  GuiControl, Move, % this.Hwnd, % s
}

Redraw() {
  GuiControl, MoveDraw, % this.Hwnd
}

Focus() {
  Try GuiControl, Focus, % this.Hwnd
}

UseTab(Name:="", Exact:="", index:="") {
  Gui, % this.GuiHwnd ":Tab", % Name, % index, % Exact?"Exact":""
}

SetFont(opts:="", FontName:="") {
  Gui, % this.GuiHwnd ":Font", % opts, % FontName
  GuiControl, Font, % this.Hwnd
}

Add(text) {
  local
  if IsObject(text)
  {
    s:=""
    For k,v in text
      s.="|" v
    text:=Trim(s, "|")
  }
  GuiControl,, % this.Hwnd, % text
}

Delete(N:="") {
  if (N="")
    GuiControl,, % this.Hwnd, |
  else
    this.Choose(N), this.Choose(0)
}

Choose(N) {
  if N is number
    GuiControl, Choose, % this.Hwnd, % N
  else
    GuiControl, ChooseString, % this.Hwnd, % N
}

Gui {
  get {
    return FindText().GuiFromHwnd(this.GuiHwnd)
  }
}

Enabled {
  get {
    local
    GuiControlGet, v, Enabled, % this.Hwnd
    return v
  }
  set {
    GuiControl, % "Enable" (!!value), % this.Hwnd
    return value
  }
}

Visible {
  get {
    local
    GuiControlGet, v, Visible, % this.Hwnd
    return v
  }
  set {
    GuiControl, % "Show" (!!value), % this.Hwnd
    return value
  }
}

Focused {
  get {
    local
    GuiControlGet, v, % this.GuiHwnd ":Focus"
    return (v=this.ClassNN)
  }
}

Value {
  get {
    local
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      this.Opt("+AltSubmit")
    GuiControlGet, v,, % this.Hwnd
    return v
  }
  set {
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      GuiControl, Choose, % this.Hwnd, % value
    else
      GuiControl,, % this.Hwnd, % value
    return value
  }
}

Text {
  get {
    local
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      this.Opt("-AltSubmit")
    GuiControlGet, v,, % this.Hwnd
    return v
  }
  set {
    if (this.Type~="i)^(ListBox|DDL|ComboBox|Tab)$")
      GuiControl, ChooseString, % this.Hwnd, % value
    else
      GuiControl,, % this.Hwnd, % value
    return value
  }
}

}  ;// Control Class End

}  ;// GuiCreate Class End

Script_End() {
}

}  ;// Class End

;================= The End =================

;