;
; File encoding:  UTF-8
;

SciUtil_GetCP(hSci)
{
	; Retrieve active codepage. SCI_GETCODEPAGE
	SendMessage, 2137, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}

SciUtil_GetCurPos(hSci)
{
	; Get the current position. SCI_GETCURRENTPOS
	SendMessage, 2008, 0, 0,, ahk_id %hSci%
	return ErrorLevel
}

SciUtil_SetCurPos(hSci, pos)
{
	; Set the current position. SCI_GOTOPOS
	SendMessage, 2025, pos, 0,, ahk_id %hSci%
	; Ensure the caret is visible. SCI_SCROLLCARET
	;SendMessage, 2169, 0, 0,, ahk_id %hSci%
}

SciUtil_GetText(hSci)
{	
	; Retrieve text length. SCI_GETLENGTH
	SendMessage, 2006, 0, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, iLength + 1)
	
	; Fill buffer with text. SCI_GETTEXT
	SendMessage, 2182, iLength + 1, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Read buffer
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength + 1)
	
	; We're done with the remote buffer
	RemoteBuf_Close(hBuf)
	
	return StrGet(&sText, "CP" SciUtil_GetCP(hSci))
}

SciUtil_GetSelection(hSci)
{	
	;Get length. SCI_GETSELTEXT
	SendMessage, 2161, 0, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	;Check if the line is empty
	if iLength = 1
		return
	
	; Open remote buffer
	RemoteBuf_Open(hBuf, hSci, iLength)
	
	; Fill buffer. SCI_GETSELTEXT
	SendMessage, 2161, 0, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Prep var
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength)
	
	; Done
	RemoteBuf_Close(hBuf)

	return StrGet(&sText, "CP" SciUtil_GetCP(hSci))
}

SciUtil_GetLine(hSci, iLine)
{
	; Retrieve line length. SCI_LINELENGTH
	SendMessage, 2350, iLine, 0,, ahk_id %hSci%
	iLength := ErrorLevel
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, iLength + 1)
	
	; Fill buffer with text. SCI_GETLINE
	SendMessage, 2153, iLine, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Read buffer
	VarSetCapacity(sText, iLength)
	RemoteBuf_Read(hBuf, sText, iLength + 1)
	
	; We're done with the remote buffer
	RemoteBuf_Close(hBuf)
	
	; Trim off ending characters & return
	return Trim(StrGet(&sText, "CP" SciUtil_GetCP(hSci)), "`r`n")
}

SciUtil_InsertText(hSci, sText, pos := -1)
{
	; Prepare a local buffer for conversion
	sNewLen := StrPut(sText, "CP" (cp := SciUtil_GetCP(hSci)))
	VarSetCapacity(sTextCnv, sNewLen)
	
	; Open remote buffer (add 1 for 0 at the end of the string)
	RemoteBuf_Open(hBuf, hSci, sNewLen + 1)
	
	; Convert the text to the destination codepage
	StrPut(sText, &sTextCnv, "CP" cp)
	RemoteBuf_Write(hBuf, sTextCnv, sNewLen + 1)
	
	; Call Scintilla to insert the text. SCI_INSERTTEXT
	SendMessage, 2003, pos, RemoteBuf_Get(hBuf),, ahk_id %hSci%
	
	; Move the caret to the end of the insertion
	SciUtil_SetCurPos(hSci, SciUtil_GetCurPos(hSci) + sNewLen)
	
	; Done
	RemoteBuf_Close(hBuf)
}
