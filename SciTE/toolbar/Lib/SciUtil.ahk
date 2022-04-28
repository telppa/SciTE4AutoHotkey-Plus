;
; File encoding:  UTF-8
;

SciUtil_GetCP(hSci)
{
	; Retrieve active codepage. SCI_GETCODEPAGE = 2137
	SendMessage, 2137, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}

SciUtil_GetCurPos(hSci)
{
	; Get the current position. SCI_GETCURRENTPOS = 2008
	SendMessage, 2008, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}

SciUtil_SetCurPos(hSci, pos)
{
	; Set the current position. SCI_GOTOPOS = 2025
	SendMessage, 2025, pos, 0,, ahk_id %hSci%
	; Ensure the caret is visible. SCI_SCROLLCARET = 2169
	; SendMessage, 2169, 0, 0,, ahk_id %hSci%
}

SciUtil_GetStyle(hSci, pos)
{
	; pos 非数字或为空则使用当前位置
	if (pos+0="")
		pos := SciUtil_GetCurPos(hSci)
	
	; SCI_GETSTYLEAT = 2010
	SendMessage, 2010, pos, 0,, ahk_id %hSci%
	return, ErrorLevel
}

SciUtil_GetSelection(hSci)
{
	; SCI_GETSELTEXT = 2161
	SendMessage, 2161, 0, 0,, ahk_id %hSci%
	; len 已包含零终止符长度
	len := ErrorLevel
	
	; Check if the selection is empty
	if (len<=1)
		return
	
	; Open remote buffer
	mem.open(hSci, len)
	
	; SCI_GETSELTEXT = 2161
	SendMessage, 2161, 0, mem.baseAddress,, ahk_id %hSci%
	
	; Read buffer
	mem.read(text)
	mem.close()
	
	; return
	return, StrGet(&text, "CP" SciUtil_GetCP(hSci))
}

SciUtil_GetText(hSci)
{
	; Retrieve text length. SCI_GETLENGTH = 2006
	SendMessage, 2006, 0, 0,, ahk_id %hSci%
	len := ErrorLevel + 1
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	mem.open(hSci, len)
	
	; Fill buffer with text. SCI_GETTEXT = 2182
	SendMessage, 2182, len, mem.baseAddress,, ahk_id %hSci%
	
	; Read buffer
	mem.read(text)
	mem.close()
	
	return, StrGet(&text, "CP" SciUtil_GetCP(hSci))
}

SciUtil_SetText(hSci, text, codePage)
{
	; codePage 非数字或为空则使用当前编码
	if (codePage+0="")
		codePage := SciUtil_GetCP(hSci)
	
	; len 已包含末尾零终止符的长度（写入时以零终止符作为终止判断依据）
	len := StrPutVar(text, textConverted, "CP" codePage)
	
	; 在 scite.exe 的内存中写入数据
	mem.open(hSci, len)
	mem.write(textConverted)
	
	; SCI_SETTEXT = 2181
	SendMessage, 2181, 0, mem.baseAddress,, ahk_id %hSci%
	
	; Done
	mem.close()
}

SciUtil_GetTextRange(hSci, startPos, endPos)
{
	; mem 是接收字符串的
	len := Abs(endPos - startPos) + 1
	mem.open(hSci, len)
	
	; textRange 是结构体
	VarSetCapacity(textRange, 12, 0)
	, NumPut(startPos,        textRange, 0, "Int")
	, NumPut(endPos,          textRange, 4, "Int")
	, NumPut(mem.baseAddress, textRange, 8, "UInt")
	
	; 结构体写入 mem2
	mem2.open(hSci, 12)
	mem2.write(textRange)
	
	; 取文字， SCI_GETTEXTRANGE = 2162
	SendMessage, 2162, 0, mem2.baseAddress,, ahk_id %hSci%
	
	; 释放 mem2
	mem2.close()
	
	; 读出文字，释放 mem
	mem.read(text)
	mem.close()
	
	return, StrGet(&text, "CP" SciUtil_GetCP(hSci))
}

SciUtil_GetWord(hSci, pos)
{
	; pos 非数字或为空则使用当前位置
	if (pos+0="")
		pos := SciUtil_GetCurPos(hSci)
	
	; SCI_WORDSTARTPOSITION = 2266
	SendMessage, 2266, pos, true, , ahk_id %hSci%
	startPos := ErrorLevel
	
	; SCI_WORDENDPOSITION = 2267
	SendMessage, 2267, pos, true, , ahk_id %hSci%
	endPos := ErrorLevel
	
	return, SciUtil_GetTextRange(hSci, startPos, endPos)
}

SciUtil_GetLine(hSci, lineNumber)
{
	; lineNumber 非数字或为空则使用当前行
	if (lineNumber+0="")
	{
		currentPos := SciUtil_GetCurPos(hSci)
		; SCI_LINEFROMPOSITION = 2166
		SendMessage, 2166, currentPos, 0,, ahk_id %hSci%
		lineNumber := ErrorLevel
	}
	
	; SCI_LINELENGTH = 2350
	SendMessage, 2350, lineNumber, 0,, ahk_id %hSci%
	; 为零终止符 +1 长度
	len := ErrorLevel + 1
	
	; Open remote buffer
	mem.open(hSci, len)
	
	; SCI_GETLINE = 2153
	SendMessage, 2153, lineNumber, mem.baseAddress,, ahk_id %hSci%
	
	; Read buffer
	mem.read(text)
	mem.close()
	
	; Trim off ending characters & return
	return, Trim(StrGet(&text, "CP" SciUtil_GetCP(hSci)), "`r`n")
}

SciUtil_GetHome(hSci)
{
	currentPos := SciUtil_GetCurPos(hSci)
	
	; SCI_LINEFROMPOSITION = 2166
	SendMessage, 2166, currentPos, 0,, ahk_id %hSci%
	currentLineNumber := ErrorLevel
	; SCI_POSITIONFROMLINE = 2167
	SendMessage, 2167, currentLineNumber, 0,, ahk_id %hSci%
	lineStartPos := ErrorLevel
	
	return, SciUtil_GetTextRange(hSci, lineStartPos, currentPos)
}

SciUtil_GetEnd(hSci)
{
	currentPos := SciUtil_GetCurPos(hSci)
	
	; SCI_LINEFROMPOSITION = 2166
	SendMessage, 2166, currentPos, 0,, ahk_id %hSci%
	currentLineNumber := ErrorLevel
	; SCI_GETLINEENDPOSITION = 2136
	SendMessage, 2136, currentLineNumber, 0,, ahk_id %hSci%
	lineEndPos := ErrorLevel
	
	return, SciUtil_GetTextRange(hSci, currentPos, lineEndPos)
}

SciUtil_DeleteEnd(hSci)
{
	currentPos := SciUtil_GetCurPos(hSci)
	
	; SCI_LINEFROMPOSITION = 2166
	SendMessage, 2166, currentPos, 0,, ahk_id %hSci%
	currentLineNumber := ErrorLevel
	; SCI_GETLINEENDPOSITION = 2136
	SendMessage, 2136, currentLineNumber, 0,, ahk_id %hSci%
	lineEndPos := ErrorLevel
	
	; SCI_DELETERANGE = 2645
	SendMessage, 2645, currentPos, Abs(lineEndPos - currentPos),, ahk_id %hSci%
}

SciUtil_InsertText(hSci, text, pos, moveCaret)
{
	; pos 非数字或为空则使用当前位置
	if (pos+0="")
		pos := -1
	
	; len 已包含末尾零终止符的长度（写入时以零终止符作为终止判断依据）
	len := StrPutVar(text, textConverted, "CP" SciUtil_GetCP(hSci))
	
	; 在 scite.exe 的内存中写入数据
	mem.open(hSci, len)
	mem.write(textConverted)
	
	; SCI_INSERTTEXT = 2003
	SendMessage, 2003, pos, mem.baseAddress,, ahk_id %hSci%
	
	; Done
	mem.close()
	
	if (moveCaret)
	{
		; 移动光标，注意需要减去1的零终止符的长度
		pos := (pos=-1) ? SciUtil_GetCurPos(hSci) : pos
		SciUtil_SetCurPos(hSci, pos + len - 1)
	}
}

SciUtil_ReplaceSel(hSci, text)
{
	; len 已包含末尾零终止符的长度（写入时以零终止符作为终止判断依据）
	len := StrPutVar(text, textConverted, "CP" SciUtil_GetCP(hSci))
	
	; 在 scite.exe 的内存中写入数据
	mem.open(hSci, len)
	mem.write(textConverted)
	
	; SCI_REPLACESEL = 2170
	SendMessage, 2170, 0, mem.baseAddress,, ahk_id %hSci%
	
	; Done
	mem.close()
}

SciUtil_FindText(hSci, text, startPos, endPos, flag)
{
	if (text="")
		return
	
	; startPos 非数字或为空则使用当前位置
	if (startPos+0="")
		startPos := SciUtil_GetCurPos(hSci)
	
	; endPos 非数字或为空则使用文末位置
	if (endPos+0="")
	{
		; SCI_GETLENGTH = 2006
		SendMessage, 2006, 0, 0,, ahk_id %hSci%
		endPos := ErrorLevel
	}
	
	; SCFIND_NONE      = 0x0
	; SCFIND_WHOLEWORD = 0x2
	; SCFIND_MATCHCASE = 0x4
	; SCFIND_WORDSTART = 0x00100000
	; SCFIND_REGEXP    = 0x00200000
	; SCFIND_POSIX     = 0x00400000
	if (flag="")
		flag := 0x0
	
	; 写入待搜索字符
	len := StrPutVar(text, textConverted, "CP" SciUtil_GetCP(hSci))
	mem2.open(hSci, len)
	mem2.write(textConverted)
	
	; Sci_TextToFind 是结构体
	VarSetCapacity(Sci_TextToFind, 20, 0)
	, NumPut(startPos,          Sci_TextToFind, 0,  "Int")
	, NumPut(endPos,            Sci_TextToFind, 4,  "Int")
	, NumPut(mem2.baseAddress,  Sci_TextToFind, 8,  "UInt")  ; 指针。 SciLexer.dll 是32位的，所以直接设为 uint
	, NumPut(out_matchStartPos, Sci_TextToFind, 12, "Int")
	, NumPut(out_matchEndPos,   Sci_TextToFind, 16, "Int")
	
	; 结构体写入 mem
	mem.open(hSci, 20)
	mem.write(Sci_TextToFind)
	
	; SCI_FINDTEXT = 2150
	SendMessage, 2150, flag, mem.baseAddress,, ahk_id %hSci%
	
	; 读取找到字符的位置
	ret := []
	, mem.read(out)
	, ret.Push(NumGet(out, 12, "Int"))
	, ret.Push(NumGet(out, 16, "Int"))
	
	; 释放
	mem.close()
	mem2.close()
	
	return, ret
}

#Include %A_LineFile%\..\mem.ahk