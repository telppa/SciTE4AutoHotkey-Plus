-- 此函数必须配合pipe才能让ahk运行选区代码
function RunSelection()
	local AHK=props["AutoHotkey"].." /CP65001 "
				AHK=string.gsub(AHK,"\\","\/")		-- 斜杠需要转换一下
	local selText=editor:GetSelText()
	local checkEmpty=string.gsub(selText, "%s", "")
	local empty=[[
								MsgBox, 没有任何代码被选中!
								ExitApp
							]]
	if checkEmpty=="" then
		os.execute(AHK..empty)		-- 这里需要用pipe传参才行
	else
		os.execute(AHK..selText)
	end
end