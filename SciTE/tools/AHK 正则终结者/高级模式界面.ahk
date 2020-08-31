高级按钮:
  GuiControlGet,高级按钮文本,,高级按钮
  If (高级按钮文本="高级>>")
    {
      GuiControl,,高级按钮,高级<<
      ;以下是高级模式界面,通常状态下被隐藏
      Gui, 高级:+Resize +MinSize
      Gui, 高级:Add, GroupBox, x5 y10 w325 h105, 高级设置
      Gui, 高级:Add, Checkbox, x13 y30 w50 h20 Checked, 多行
      Gui, 高级:Add, Checkbox, x80 y30 w90 h20 Checked, 新行符任意
      Gui, 高级:Add, Checkbox, x180 y30 w100 h20, 不区分大小写
      Gui, 高级:Add, Checkbox, x13 y60 w60 h20, 非贪婪
      Gui, 高级:Add, Checkbox, x80 y60 w80 h20 Checked, 研究模式
      Gui, 高级:Add, Checkbox, x180 y60 w130 h20, 使用 Unicode 属性
      Gui, 高级:Add, ListView, x5 y126 w325 h338, 捕获|子模式
      WinGetPos,Px,Py,Pw,,ahk_id %主界面%
      Px:=Px+Pw
      If (Px+335<=A_ScreenWidth)		;高级界面能完全显示在主界面右边,则显示.否则显示在屏幕正中
          Gui, 高级:Show, x%Px% y%Py% w335 h500, 高级模式
      Else
          Gui, 高级:Show,w335 h500, 高级模式
    }
  Else
      gosub,高级GuiClose
return

高级GuiClose:
高级GuiEscape:
  GuiControl,1:,高级按钮,高级>>			;必须指定 "高级按钮" 所在 Gui 编号,否则从 "高级模式" 关闭按钮跳转到此标签时,命令无法正常生效
  Gui, 高级:Destroy
return