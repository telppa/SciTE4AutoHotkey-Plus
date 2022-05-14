;
; File encoding:  UTF-8
; Author: fincs
;
; Get the current SciTE instance
;

GetSciTEInstance()
{
	olderr := ComObjError()
	ComObjError(false)
	; 下面这句将导致管理员权限运行时报错无效的类字符串。
	; scite  := ComObjActive("SciTE4AHK.Application")
	scite  := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}")
	ComObjError(olderr)
	
	oldTitleMatchMode := A_TitleMatchMode
	SetTitleMatchMode 2
	
	if (!IsObject(scite))
	{
		if (WinExist("SciTE4AutoHotkey ahk_exe SciTE.exe"))
		{
			MsgBox 0x40010, SciTE4AutoHotkey - 错误,
			(LTrim
				COM 接口连接失败！
				
				
				以下是可能导致此问题的原因：
				
				%A_Space%1. 使用360杀毒。
				%A_Space%2. 使用精简版系统。
				%A_Space%3. 使用绿色版 AHK 。
				%A_Space%4. 没有文件目录权限。
				
				
				你可以尝试：
				
				%A_Space%1. 退出360杀毒。
				%A_Space%2. 管理员权限运行。
				%A_Space%3. 重装 AHK 到 D 盘。
				%A_Space%4. 重装 SciTE4AutoHotkey-Plus 。
				%A_Space%5. 1+2+3+4 。
			)
		}
		else
			MsgBox 0x40010, 错误, 先打开 SciTE4AutoHotkey 再运行我。
		
		scite := ""
	}
	
	SetTitleMatchMode %oldTitleMatchMode%
	return scite
}