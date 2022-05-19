/*
  更新日志：
    2022.05.19
      增强 新建 与 重命名 按钮。
      去掉了最小化按钮。
      版本号 2.3 。
    2022.05.12
      基于 Kawvin 0.2_2018.08.01 版重构。
      代码片段可分类或不分类。
      代码片段有独立的描述字段。
      支持多关键词搜索。
      限制快捷键作用域。
      bug 修复。
      界面微调。
      添加提示。
      版本号 2.2 。
  
  历史贡献：
    fincs
    快乐就好
    Kawvin
    空
*/

Label_PreSetting:    ;{ 预设置
  #NoEnv
  #NoTrayIcon
  #SingleInstance Ignore
  FileEncoding, UTF-8
  Menu, Tray, Icon, %A_ScriptDir%\..\toolicon.icl, 11
;}

Label_DefVar:        ;{ 定义变量
  ver := 2.3
  progName := "代码片段管理器"
  
  if (!oSciTE := GetSciTEInstance())
    ExitApp
  
  textFont := oSciTE.ResolveProp("default.text.font")
  scitehwnd := oSciTE.SciTEHandle
  LocalSciTEPath := oSciTE.UserDir
  
  sdir := LocalSciTEPath "\Scriptlets"
  if (!InStr(FileExist(sdir), "D"))
    FileCreateDir, %sdir%
;}

if 1 = /insert       ;{ 命令行调用 - 插入到 SciTE
{
  if 2 =
  {
    MsgBox, 64, %progName% - 插入到 SciTE, 命令行示例：`n`n%A_ScriptName% /insert "代码片段文件名（不含后缀）"
    ExitApp
  }
  IfNotExist, %sdir%\%2%.scriptlet
  {
    MsgBox, 52, %progName% - 插入到 SciTE,
    (LTrim
    插入失败！
    
    无效的代码片段： 【%2%】 。
    工具栏图标对应的代码片段不存在。
    点击 “确定” 编辑工具栏配置文件。
    )
    IfMsgBox, Yes
      oSciTE.OpenFile(LocalSciTEPath "\UserToolbar.properties")
    ExitApp
  }
  FileRead, text2insert, %sdir%\%2%.scriptlet
  gosub InsertDirect
  ExitApp
}
;}

if 1 = /addScriptlet ;{ 命令行调用 - 添加代码片段
{
  defaultScriptlet := oSciTE.Selection
  if defaultScriptlet =
  {
    MsgBox, 16, %progName% - 添加代码片段, 添加失败！`n`n选中内容为空。
    ExitApp
  }
  gosub AddBtn  ; that does it all
  if !_RC
    ExitApp     ; Maybe the user has cancelled the action.
  MsgBox, 68, %progName% - 添加代码片段, 添加成功。`n`n是否打开代码片段管理器？
  IfMsgBox, Yes
    Reload      ; no parameters are passed to script
  ExitApp
}
;}

Label_DrawGUI:       ;{ 绘制窗体
  Gui, +Owner%scitehwnd% -MinimizeBox +HwndhGUI
  Gui, Margin, 10, 10
  Gui, Font, S9, %textFont%
  
  Gui, Add, Button, Section x10 w80 h30 gAddBtn, 新建
  Gui, Add, Button, ys w80 h30 gRenBtn, 重命名
  Gui, Add, Button, ys w80 h30 gSubBtn, 删除
  
  Gui, Add, Text, xs w40 h25 +0x200, 搜索：
  Gui, Add, Edit, x+10 yp w210 h25 vSearchStr gSearchChange
  Gui, Add, ListBox, xs w260 h480 vMainListbox gSelectLB HwndhListbox HScroll 0x100 Hidden
  Gui, Add, TreeView, xs yp w260 h480 vMainTreeView gSelectTR HScroll
  
  Gui, Add, Button, ys Section w115 h30 gToolbarBtn, 添加到工具栏
  Gui, Add, Button, ys w115 h30 gInsertBtn, 插入到 SciTE
  Gui, Add, Button, ys w115 h30 gOpenInSciTE, 用 SciTE 编辑
  Gui, Add, Button, ys w80 h30 gSaveBtn, 保存
  
  Gui, Add, Edit, xs w455 h515 vScriptPane WantTab HScroll
  
  Gui, Font, cNavy
  Gui, Add, Text, xs-270 vTipsPane, 使用技巧： 搜索内容后按 Ctrl+I 或 Alt+Enter 直接插入到 SciTE 中。
  
  Gui, Show, , %progName% v%ver%
  GuiControl, Focus, SearchStr
  
  OnMessage(0x200, "tipsHandler")  ; WM_MouseMove
  
  gosub TreeViewUpdate
return
;}

GuiEscape:
GuiClose:            ;{ 关闭窗体
  ExitApp
return
;}

#If WinActive("ahk_id " hGUI)
^n::
AddBtn:              ;{ 新建
  Gui +OwnDialogs
  
  InputBox, fname2create, 新建代码片段, 输入要创建的代码片段名称`n`n格式1： 名称`n格式2： 分类_名称,,,,,,,, % getCategoryName()
  if ErrorLevel
    return
  if !fname2create
    return
  
  fname2create := validateFilename(fname2create)
  if (FileExist(sdir "\" fname2create ".scriptlet"))
  {
    MsgBox, 48, %progName% - 新建, 创建失败！`n`n 【%fname2create%】 已存在，请输入其他名称。
    return
  }
  
  FileAppend, % defaultScriptlet, %sdir%\%fname2create%.scriptlet
  gosub CompleteUpdate
  _RC = 1
Return
;}

^r::
RenBtn:              ;{ 重命名
  Gui +OwnDialogs
  
  if (selected := getSelItemName())
  {
    InputBox, fname2create, 重命名代码片段, 输入代码片段的新名称`n`n格式1： 名称`n格式2： 分类_名称,,,,,,,, %selected%
    if ErrorLevel
      return
    if !fname2create
      return
    if (fname2create = selected)
      return
    
    fname2create := validateFilename(fname2create)
    if (FileExist(sdir "\" fname2create ".scriptlet"))
    {
      MsgBox, 48, %progName% - 重命名, 重命名失败！`n`n 【%fname2create%】 已存在，请输入其他名称。
      return
    }
    
    FileMove, %sdir%\%selected%.scriptlet, %sdir%\%fname2create%.scriptlet
    gosub CompleteUpdate
  }
  else
    showTip("没有选中项目！")
return
;}

^d::
SubBtn:              ;{ 删除
  Gui +OwnDialogs
  
  if (selected := getSelItemName())
  {
    MsgBox, 52, %progName% - 删除, 确认删除 【%selected%】 ？
    IfMsgBox, No
      return
    
    FileDelete, %sdir%\%selected%.scriptlet
    gosub CompleteUpdate
  }
  else
    showTip("没有选中项目！")
return
;}

^t::
ToolbarBtn:          ;{ 添加到工具栏
  if (selected := getSelItemName())
  {
    SendString=`n=代码片段： "%selected%"|`%LOCALAHK`% tools\SUtility.ahk /insert "%selected%"||`%ICONRES`%`,12
    FileAppend, %SendString%, %LocalSciTEPath%\UserToolbar.properties
    showTip(ErrorLevel ? "添加失败" : "添加成功")
    oSciTE.Message(0x1000+2)
  }
  else
    showTip("没有选中项目！")
return
;}

^i::
!enter::
InsertBtn:           ;{ 插入到 SciTE
  GuiControlGet, text2insert,, ScriptPane
InsertDirect:
  text2insert := removeDescription(text2insert)
  if text2insert =
  {
    showTip("没有选中项目！")
    return
  }
  
  oSciTE.InsertText(text2insert)
  WinActivate, ahk_id %scitehwnd%
  ExitApp
return
;}

^o::
OpenInSciTE:         ;{ 用 SciTE 编辑
  path := getSelItemPath()
  if (FileExist(path))
  {
    oSciTE.OpenFile(path)
    ExitApp
  }
  else
    showTip("没有选中项目！")
return
;}

^s::
SaveBtn:             ;{ 保存
  if (path := getSelItemPath())
  {
    GuiControlGet, text2save,, ScriptPane
    FileDelete, %path%
    FileAppend, % text2save, %path%
    showTip(ErrorLevel ? "保存失败" : "保存成功")
  }
  else
    showTip("没有选中项目！")
return
;}

F3::                 ;{ 搜索
  GuiControl,, SearchStr
  GuiControl, Focus, SearchStr
return
;}

#If WinActive("ahk_id " hGUI) and (showBlankListboxFirst = false) and isFocusOnSearchBar()
Up::                 ;{ 搜索框内按方向键可选择 ListBox 中的项目
Down::
  ControlSend,, {%A_ThisHotkey%}, ahk_id %hListbox%
return
;}

CompleteUpdate:      ;{ 更新全部
  gosub TreeViewUpdate
  gosub SearchChange
return
;}

TreeViewUpdate:      ;{ 更新 TreeView
  TV_Delete()
  
  ParentItemID := {}
  sn_with_type := []
  sn_cache := []
  
  Loop, %sdir%\*.scriptlet
  {
    SplitPath, A_LoopFileName,,,, sn
    
    ; 缓存全部项目给 SearchChange 搜索用
    sn_cache.Push(sn)
    
    ; 缓存带分类的项目
    if (InStr(sn, "_"))
    {
      sn_with_type.Push(sn)
      continue
    }
    
    ; 优先创建无分类的项目
    TV_Add(sn)
  }
  
  ; 接着创建带分类的项目
  for k, sn in sn_with_type
  {
    t := StrSplit(sn, "_", "", 2)
    sType := t[1], sName := t[2]
    
    ; 创建分类
    if (!ParentItemID[sType])
      ParentItemID[sType] := TV_Add(sType)
    
    ; 分类中创建项目
    TV_Add(sName, ParentItemID[sType])
  }
return
;}

SearchChange:        ;{ 搜索框变动
  GuiControlGet, SearchStr,, SearchStr
  
  if (SearchStr="")
  {
    showBlankListboxFirst := true
    Guicontrol, Show, MainTreeView
    Guicontrol,, ScriptPane
    Guicontrol, Hide, MainListbox
    return
  }
  else if (showBlankListboxFirst != false)
  {
    showBlankListboxFirst := false
    GuiControl,, MainListbox, |
    Guicontrol, Show, MainListbox
    Guicontrol, Hide, MainTreeView
  }
  
  list := ""
  for k, itemName in sn_cache
  {
    ; 支持 “a b” 匹配 “acdbef”
    for k, v in StrSplit(SearchStr, " ")
      if (!InStr(itemName, v))
        continue, 2
    
    list .= "|" itemName
  }
  
  GuiControl,, MainListbox, % list ? list : "|"
  GuiControl, Choose, MainListbox, 1
  gosub, SelectLB
return
;}

SelectTR:            ;{ TreeView 选中
  if (A_GuiEvent != "S")  ; 只处理选中操作
    return
SelectLB:            ;{ Listbox 选中
  FileRead, scriptletText, % getSelItemPath()
  GuiControl,, ScriptPane, % scriptletText
return
;};}

tipsHandler()
{
  global TipsPane
  static pre_GuiControl:=""
  
  if (A_GuiControl!=pre_GuiControl)
  {
    pre_GuiControl := A_GuiControl
    switch, A_GuiControl
    {
      case "新建":          GuiControl, , TipsPane, 新建： Ctrl+N
      case "重命名":        GuiControl, , TipsPane, 重命名： Ctrl+R
      case "删除":          GuiControl, , TipsPane, 删除： Ctrl+D
      case "保存":          GuiControl, , TipsPane, 保存： Ctrl+S
      case "添加到工具栏":  GuiControl, , TipsPane, 添加到工具栏： Ctrl+T
      case "插入到 SciTE":  GuiControl, , TipsPane, 插入到 SciTE： Ctrl+I 或 Alt+Enter
      case "用 SciTE 编辑": GuiControl, , TipsPane, 用 SciTE 编辑： Ctrl+O
      case "SearchStr":     GuiControl, , TipsPane, 搜索： F3`t搜索语法： “() pp” 可匹配 apple()
      Default:              GuiControl, , TipsPane, 使用技巧： 搜索内容后按 Ctrl+I 或 Alt+Enter 直接插入到 SciTE 中。
    }
  }
}

showTip(text)
{
  ToolTip, %text%
  SetTimer, CloseToolTip, -2000
  return
  
  CloseToolTip:
    ToolTip
  return
}

getSelItemPath()
{
  global sdir
  
  selItemName := getSelItemName()
  if (selItemName)
    return, sdir "\" selItemName ".scriptlet"
}

getSelItemName()
{
  global SearchStr, MainListbox
  
  GuiControlGet, SearchStr,, SearchStr
  if (SearchStr != "")
    GuiControlGet, out,, MainListbox
  else
  {
    id := TV_GetSelection()
    
    if (TV_GetChild(id))
      return
    
    TV_GetText(out1, TV_GetParent(id))
    TV_GetText(out2, id)
    out := out1 ? out1 "_" out2 : out2
  }
  
  return, out
}

getCategoryName()
{
  id := TV_GetSelection()
  
  if (id)
  {
    if (TV_GetChild(id))
      TV_GetText(out, id)
    else if (TV_GetParent(id))
      TV_GetText(out, TV_GetParent(id))
  }
  
  return out="" ? "" : out "_"
}

validateFilename(str)
{
  str := StrReplace(str, "`\")
  str := StrReplace(str, "`/")
  str := StrReplace(str, "`:")
  str := StrReplace(str, "`*")
  str := StrReplace(str, "`?")
  str := StrReplace(str, """")
  str := StrReplace(str, "`<")
  str := StrReplace(str, "`>")
  str := StrReplace(str, "`|")
  str := StrReplace(str, "`r")
  str := StrReplace(str, "`n")
  
  ; 创建的是文件夹的时候，最后一个字符不能是 “.” ，否则会失败。
  ; 创建的是文件时，则会自动删掉最后的 “.” 。
  ; 所以无论何种情况，最后一个字符是 “.” 时，都要被干掉。
  return, RTrim(str, ".")
}

isFocusOnSearchBar()
{
  GuiControlGet, out, FocusV
  return, out="SearchStr" ? true : false
}

removeDescription(text)
{
  ; 正则严格匹配第一个以 /** 开头
  ;                   以 */ 结束的多行注释
  ; 这种注释被设计为即兼容 ahk 原版语法，同时又可以被单独识别而另做它用，并且其长度还很方便代码对齐。
  ; 目前的作用是可在管理器中描述代码片段作者、用法等信息，同时在插入 scite 时被自动剔除以维持简洁。
  ; 未来还可能被用来存储一些命令，例如识别里面的 pos 值，从而在插入代码后再将光标移动到指定位置。
  return RegExReplace(text
                    , "m)(*ANYCRLF)"
                    . "(^\Q/**\E)"
                    . "(.*[\r\n]+)"
                    . "(?s)(.*?)"
                    . "\Q*/\E[\r\n]+"
                    , "", "", 1)
}