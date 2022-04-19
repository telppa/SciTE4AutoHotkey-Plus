帮助()
{
  if (A_Language="0804")
    help=
    (LTrim `%
    主页：
      https://github.com/telppa/SciTE4AutoHotkey-Plus/tree/master/SciTE/tools/AHK DllCall 终结者
    
    教程：
      https://www.autoahk.com/archives/40644
    )
  else
    help=
    (LTrim `%
    HomePage:
      https://github.com/telppa/SciTE4AutoHotkey-Plus/tree/master/SciTE/tools/AHK%20DllCall%20%E7%BB%88%E7%BB%93%E8%80%85
    
    Tutorial:
      https://www.autohotkey.com/boards/viewtopic.php?f=6&t=101795
    )
  
  GuiControl, , edit1, % help
}