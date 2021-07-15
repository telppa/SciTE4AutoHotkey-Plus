/*
更新日志：
  2021.07.11
    兼容模式生效。
    兼容模式提供说明。
    复制代码按钮生效。
    优化文件目录结构。
    提示按钮中的示例全部生效。
    删除提示按钮中的过时示例。
    更改软件启动后的默认示例。
    处理正则中零宽匹配的问题。
    强制 U32 模式运行避免出错。
    版本号1.0。

  2021.07.07
    错字修改。
    版本号0.4。

  2020.09.07
    界面优化。
    增加主页按钮。
    版本号0.3。

  2020.07.30
    界面可适应系统缩放参数。
    版本号0.2。

已知问题：
1.极限情况下高亮存在性能及闪烁问题
  SCITE 在高亮一次文本后
  高亮一直是跟随着文本的
  比如 abc book bcd
  高亮了 book 后 即使变为 books
  book 的高亮依然存在
2.很多按钮或选项没反应
  因为我还没写 时间不够 无限期延后
3.快速切换起始坐标可能导致高亮出错

todo：
  增加btt库
  设置焦点在匹配处

*/

RunWith(,"u32")                   ; 因为 dll 是32位的，所以必须强制指定运行版本。
#NoEnv
#Include <SCI>                    ; 因为定义了很多全局变量,所以必须放前面. 否则涉及到使用了全局变量的地方,就会不起作用

初始正则框内容:="^a(bc)(d)(e)"    ; 注意如果添加的内容为纯数字,将无法添加. 应该是 SCI 库文件的一个 BUG
初始文本框内容=                   ; 注意使用此种方式添加的文本段落,如果不用 Join 指定链接符的话,默认链接符是 `n. 而正则中对换行的处理默认是 `r`n ,所以会导致问题
(Join`r`n
-------工具说明-------
相邻两个匹配的颜色总不相同
相邻两个子模式匹配的颜色总不相同

亮黄色代表第一个匹配
暗黄色代表第二个匹配
亮黄色代表第三个匹配

红色代表第一个子模式匹配
绿色代表第二个子模式匹配
红色代表第三个子模式匹配

以此类推

abcd
abcde
abcdef
abcdefg
)
gosub, 界面  ; 创建主界面
gosub, 实时响应
return

; 此标签的作用就是获取文本和正则并高亮结果
实时响应:
  Gui, Submit, NoHide                     ; 获取 Gui 控件状态
  正则:=""
  文本:=""
  原始匹配对象:=""                        ; 此对象中存储原始匹配对象. 主要用于调试和扩展
  匹配对象:=""                            ; 此对象中存储原始匹配对象格式化并重算后的坐标,长度,值,名字. 使用前先清空,避免混乱
  全局索引:=""
  高亮风格:=""
  sci1.GetText(sci1.getLength()+1, 正则)  ; 获取正则
  sci2.GetText(sci2.getLength()+1, 文本)  ; 获取文本
  ; sci2.ClearDocumentStyle()               ; 清空高亮. 此种方式会导致自动换行或不换行均出现问题!!!
  sci2.StartStyling(0, 0x1f)              ; 使用默认高亮重绘所有文本,起清空高亮的作用
  , sci2.SetStyling(sci2.getLength(), 1)

  if (兼容模式=1)
    正则:=正则添加选项(正则, "m", "(*ANYCRLF)")

  if (全局模式=1)
    原始匹配对象:=GlobalRegExMatch(文本, 正则, 起始坐标)
  else
    原始匹配对象:=RegExMatchLikeGlobal(文本, 正则, 起始坐标)

  匹配对象:=以指定代码页计算匹配对象位置及长度(文本,原始匹配对象,"UTF-8")
  loop, % 匹配对象["GlobalCount"]                          ; 由于统一了非全局模式与全局模式返回值,使得非全局模式的 "GlobalCount" 的值必然为 1 ,因此可一并通过以下代码实现高亮
  {
    全局索引:=A_Index
    高亮风格:=Mod(全局索引,2)=1 ? 0 : 3                    ; 高亮风格总是为 0 或 3 , SCE_AHKL_LPPDEFINED1+3=SCE_AHKL_LPPDEFINED4. 即 全局1高亮风格+3=全局2高亮风格

    sci2.StartStyling(匹配对象[全局索引]["Pos"][0], 0x1f)  ; 整体高亮. 之所以设置 6种 高亮风格,是为了完美区隔每个整体及其子模式
    , sci2.SetStyling(匹配对象[全局索引]["Len"][0], SCE_AHKL_LPPDEFINED1+高亮风格)
    loop,% 匹配对象[全局索引]["Count"]
    {
      if (Mod(A_Index,2)=1)
        sci2.StartStyling(匹配对象[全局索引]["Pos"][A_Index], 0x1f)				; 子模式1 高亮
        , sci2.SetStyling(匹配对象[全局索引]["Len"][A_Index], SCE_AHKL_LPPDEFINED2+高亮风格)
      else
        sci2.StartStyling(匹配对象[全局索引]["Pos"][A_Index], 0x1f)				; 子模式2 高亮
        , sci2.SetStyling(匹配对象[全局索引]["Len"][A_Index], SCE_AHKL_LPPDEFINED3+高亮风格)
    }
  }
return

#Include <RunWith>
#Include <正则全局模式>
#Include <以指定代码页计算匹配对象位置及长度>

#Include <主界面>
#Include <智能库引用>
#Include <高级模式界面>
#Include <提示按钮菜单项>