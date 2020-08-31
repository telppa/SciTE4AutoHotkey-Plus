创建正则提示菜单:
  Menu, 正则提示菜单, Add, `t不要在表达式前后添加引号 "", InsertRegEx
  Menu, 正则提示菜单, Add, `t选项, InsertRegEx
  Menu, 正则提示菜单, Add,
  Menu, 正则提示菜单, Add, ^`t行首, InsertRegEx
  Menu, 正则提示菜单, Add, $`t行末, InsertRegEx
  Menu, 正则提示菜单, Add,
  Menu, 正则提示菜单, Add, .`t任意单个字符, InsertRegEx
  Menu, 正则提示菜单, Add, *`t0或多次匹配, InsertRegEx
  Menu, 正则提示菜单, Add, +`t1或多次匹配, InsertRegEx
  Menu, 正则提示菜单, Add, ?`t0或1次匹配, InsertRegEx
  Menu, 正则提示菜单, Add, {n`,m}`t最少匹配n次`,最多匹配m次, InsertRegEx
  Menu, 正则提示菜单, Add,
  Menu, 正则提示菜单, Add, *?`t0或多次匹配(非贪婪模式), InsertRegEx
  Menu, 正则提示菜单, Add, +?`t1或多次匹配(非贪婪模式), InsertRegEx
  Menu, 正则提示菜单, Add, ??`t0或1次匹配(非贪婪模式), InsertRegEx
  Menu, 正则提示菜单, Add, {n`,m}?`t最少匹配n次`,最多匹配m次(非贪婪模式), InsertRegEx
  Menu, 正则提示菜单, Add,
  Menu, 正则提示菜单, Add, ()`t子表达式分组, InsertRegEx
  Menu, 正则提示菜单, Add, |`t或, InsertRegEx
  Menu, 正则提示菜单, Add, []`t范围内的字符, InsertRegEx
  Menu, 正则提示菜单, Add, [^]`t不在范围内的字符, InsertRegEx
  Menu, 正则提示菜单, Add,
  Menu, 正则提示菜单, Add, \n`t换行, InsertRegEx
  Menu, 正则提示菜单, Add, \r`t回车(在文件中查找时使用), InsertRegEx
  Menu, 正则提示菜单, Add, \t`t制表符, InsertRegEx
  Menu, 正则提示菜单, Add, \w`t单词, InsertRegEx
  Menu, 正则提示菜单, Add, \s`t空格, InsertRegEx
  Menu, 正则提示菜单, Add, \d`t数字, InsertRegEx
  Menu, 正则提示菜单, Add, \l`t小写字母, InsertRegEx
  Menu, 正则提示菜单, Add, \u`t大写字母, InsertRegEx
  Menu, 正则提示菜单, Add, \Q`t开始引用, InsertRegEx
  Menu, 正则提示菜单, Add, \E`t结束引用, InsertRegEx
  Menu, 正则提示菜单, Add, \`t转义符, InsertRegEx
  Menu, 正则提示菜单, Add, `t正则表达式快速参考, InsertRegEx
return

InsertRegEx:
return