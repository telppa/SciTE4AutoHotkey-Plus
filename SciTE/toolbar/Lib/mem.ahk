class mem
{
	static hProcess, baseAddress, size
	
	open(hwnd, size)
	{
		WinGet, pid, PID, ahk_id %hwnd%
		
		; 0x38 := PROCESS_VM_OPERATION | PROCESS_VM_READ | PROCESS_VM_WRITE
		hProcess := DllCall("OpenProcess", "UInt", 0x38, "Int", 0, "UInt", pid, "Ptr")
		if (!hProcess)
			throw, A_ThisFunc ">   Unable to open process (" A_LastError ")"
		
		; MEM_COMMIT := 0x1000, PAGE_READWRITE := 4
		baseAddress := DllCall("VirtualAllocEx", "Ptr", hProcess, "Ptr", 0, "UPtr", size, "UInt", 0x1000, "UInt", 4, "Ptr")
		if (!baseAddress)
			throw, A_ThisFunc ">   Unable to allocate memory (" A_LastError ")"
		
		this.hProcess := hProcess
		this.baseAddress := baseAddress
		this.size := size
	}
	
	close()
	{
		; MEM_RELEASE := 0x8000
		ret := DllCall("VirtualFreeEx", "Ptr", this.hProcess, "Ptr", this.baseAddress, "UPtr", 0, "UInt", 0x8000)
		if (ret=0)
			throw, A_ThisFunc ">   Unable to free memory (" A_LastError ")"
		
		DllCall("CloseHandle", "Ptr", this.hProcess)
		
		this.hProcess := ""
		this.baseAddress := ""
		this.size := ""
	}
	
	/* 一定要用 ByRef 返回值
	
	lpBuffer 很可能包含二进制0。
	接收时即使提前设置了变量大小，也很可能收不全数据。
	
	*/
	read(ByRef lpBuffer)
	{
		VarSetCapacity(lpBuffer, this.size, 0)
		ret := DllCall("ReadProcessMemory"
									, "Ptr", this.hProcess
									, "Ptr", this.baseAddress
									, "Ptr", &lpBuffer
									, "UPtr", this.size
									, "UPtr*", 0)
		if (ret=0)
			throw, A_ThisFunc ">   Unable to read process memory (" A_LastError ")"
	}
	
	/* 为什么一定要加 ByRef
	
	; 不加 ByRef 时
	var1 := "字符串abc"
	write(var1)     ; write 内部打印 lpBuffer 可以显示 var1 的值
	
	; 不加 ByRef 时
	StrPutVar("字符串abc", var2, "CP1200")
	Msgbox, % var2  ; 此时有可能打印出值，也有可能打印不出值
	write(var2)     ; write 内部打印 lpBuffer 不能显示 var2 的值
	
	*/
	write(ByRef lpBuffer)
	{
		ret := DllCall("WriteProcessMemory"
									, "Ptr", this.hProcess
									, "Ptr", this.baseAddress
									, "Ptr", &lpBuffer
									, "UPtr", this.size
									, "UPtr*", 0)
		if (ret=0)
			throw, A_ThisFunc ">   Unable to write process memory (" A_LastError ")"
	}
}

class mem2 extends mem
{
	
}