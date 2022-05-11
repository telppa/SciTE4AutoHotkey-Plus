创建正则参考菜单:
  Menu, 正则参考菜单, Add, `t正则表达式快速参考, InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, ^`t行首, InsertRegEx
  Menu, 正则参考菜单, Add, $`t行末, InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, .`t任意单个字符, InsertRegEx
  Menu, 正则参考菜单, Add, *`t0或多次匹配, InsertRegEx
  Menu, 正则参考菜单, Add, +`t1或多次匹配, InsertRegEx
  Menu, 正则参考菜单, Add, ?`t0或1次匹配, InsertRegEx
  Menu, 正则参考菜单, Add, {n`,m}`t最少匹配n次`,最多匹配m次, InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, *?`t0或多次匹配(非贪婪模式), InsertRegEx
  Menu, 正则参考菜单, Add, +?`t1或多次匹配(非贪婪模式), InsertRegEx
  Menu, 正则参考菜单, Add, ??`t0或1次匹配(非贪婪模式), InsertRegEx
  Menu, 正则参考菜单, Add, {n`,m}?`t最少匹配n次`,最多匹配m次(非贪婪模式), InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, |`t或, InsertRegEx
  Menu, 正则参考菜单, Add, ()`t子表达式分组, InsertRegEx
  Menu, 正则参考菜单, Add, (?选项)`t改变后续模式选项, InsertRegEx
  Menu, 正则参考菜单, Add, []`t范围内的字符, InsertRegEx
  Menu, 正则参考菜单, Add, [^]`t不在范围内的字符, InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, \d`t数字, InsertRegEx
  Menu, 正则参考菜单, Add, \s`t空白符, InsertRegEx
  Menu, 正则参考菜单, Add, \t`t制表符, InsertRegEx
  Menu, 正则参考菜单, Add, \r`t回车, InsertRegEx
  Menu, 正则参考菜单, Add, \n`t换行, InsertRegEx
  Menu, 正则参考菜单, Add, \w`t单词, InsertRegEx
  Menu, 正则参考菜单, Add, \b`t单词边界, InsertRegEx
  Menu, 正则参考菜单, Add, \Q`t原义开始, InsertRegEx
  Menu, 正则参考菜单, Add, \E`t原义结束, InsertRegEx
  Menu, 正则参考菜单, Add, \`t转义符, InsertRegEx
  Menu, 正则参考菜单, Add,
  Menu, 正则参考菜单, Add, [a-z]`t小写字母, InsertRegEx
  Menu, 正则参考菜单, Add, [A-Z]`t大写字母, InsertRegEx
  ; 注意是小写x，不需要 (*UCP) 选项。https://www.qqxiuzi.cn/zh/hanzi-unicode-bianma.php
  Menu, 正则参考菜单, Add, [\x{4e00}-\x{9fa5}]`t匹配汉字, InsertRegEx
  ; 也可以直接用中文，等价于 [\x{4e00}-\x{9f9f}] ，比 9fa5 仅少6个生僻字。
  Menu, 正则参考菜单, Add, [一-龟]`t匹配汉字, InsertRegEx
return

InsertRegEx:
  if (InStr(A_ThisMenuItem, "正则表达式快速参考"))
  {
    中文帮助路径=%A_AhkPath%\..\SciTE\中文帮助\AutoHotkey_CN.chm
    英文帮助路径=%A_AhkPath%\..\AutoHotkey.chm
    if (FileExist(中文帮助路径))
      Run, hh.exe mk:@MSITStore:%中文帮助路径%::/docs/misc/RegEx-QuickRef.htm
    else if (FileExist(英文帮助路径))
      Run, hh.exe mk:@MSITStore:%英文帮助路径%::/docs/misc/RegEx-QuickRef.htm
    else
      MsgBox, 在 %A_AhkPath% 处没有找到中文或英文帮助文件。
  }
  else
  {
    菜单内容:=StrSplit(A_ThisMenuItem, "`t", " `t`r`n`v`f", 2)[1]
    sci1.REPLACESEL(, 菜单内容)
  }
return