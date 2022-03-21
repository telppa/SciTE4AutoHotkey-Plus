multiLanguage:
  if (A_Language="0804")
  {
    ; 在 gui 里
    l_gui_1  := "转换"
    l_gui_2  := "单行语法"
    l_gui_3  := "多行语法"
    l_gui_4  := "Dll 名:"
    l_gui_5  := "显示错误"
    l_gui_6  := "显示警告"
    l_gui_7  := "显示提示"
    l_gui_8  := "创建变量"
    l_gui_9  := "打印返回值与错误码"
    l_gui_10  := "AHK DllCall 终结者"
    
    ; 在 createDllCallTemplate() 里
    l_tip_1  := "  `; 提示：类型未知，但根据特征猜测应为 {} 。"
    l_tip_2  := "; 提示：参数 {} 的类型 {} 未知，但根据特征猜测应为 {} 。`r`n"
    l_tip_3  := "  `; 错误：类型未知，需自行确定。"
    l_tip_4  := "; 错误：参数 {} 的类型 {} 未知，需自行确定。`r`n"
    l_tip_5  := "  `; 错误：返回值类型未知，需自行确定。"
    l_tip_6  := "; 错误：返回值的类型 {} 未知，需自行确定。`r`n"
    
    ; 在 parseMsdnFunctionSyntax() 里
    l_tip_7  := "/* 错误：第{}行内容解析失败。`r`n--------`r`n{}`r`n--------`r`n*/`r`n"
    l_tip_8  := "; 错误：获取函数名失败。`r`n"
    l_tip_9  := "; 错误：获取返回值类型失败。`r`n"
    l_tip_10 := "; 警告：函数可能存在额外参数，需自行确定。`r`n"
    l_tip_11 := "/* 错误：第{}行内容解析失败。`r`n--------`r`n{}`r`n--------`r`n*/`r`n"
    
    l_errorlevel := "MsgBox, % ""返回值:"" ret ""``r``n错误码:"" ErrorLevel"
  }
  else
  {
    ; in gui
    l_gui_1  := "Convert"
    l_gui_2  := "One Line"
    l_gui_3  := "Multi Line"
    l_gui_4  := "Dll Name:"
    l_gui_5  := "Show Error"
    l_gui_6  := "Show Warn"
    l_gui_7  := "Show Info"
    l_gui_8  := "Create Variables"
    l_gui_9  := "Print RetVal && ErrorLevel"
    l_gui_10  := "AHK DllCall Terminator"
    
    ; in createDllCallTemplate()
    l_tip_1  := "  `; Info : type unknown, but guess is {} 。"
    l_tip_2  := "; Info : {}'s type {} is unknown, but guess is {} 。`r`n"
    l_tip_3  := "  `; Error : type unknown, need to judge for yourself."
    l_tip_4  := "; Error : {}'s type {} is unknown, need to judge for yourself.`r`n"
    l_tip_5  := "  `; Error : type unknown, need to judge for yourself."
    l_tip_6  := "; Error : return value's type {} is unknown，need to judge for yourself.`r`n"
    
    ; in parseMsdnFunctionSyntax()
    l_tip_7  := "/* Error : line {} failed to parse.`r`n--------`r`n{}`r`n--------`r`n*/`r`n"
    l_tip_8  := "; Error : failed to get the function name.`r`n"
    l_tip_9  := "; Error : failed to get the return value type.`r`n"
    l_tip_10 := "; Warn : function may have additional parameters, need to judge for yourself.`r`n"
    l_tip_11 := "/* Error : line {} failed to parse.`r`n--------`r`n{}`r`n--------`r`n*/`r`n"
    
    l_errorlevel := "MsgBox, % ""return value:"" ret ""``r``nerrorlevel:"" ErrorLevel"
  }
return