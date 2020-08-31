;
; File encoding:  UTF-8
; Author: Lexikos
;

StrPutVar(string, ByRef var, encoding)
{
	; Ensure capacity.
	VarSetCapacity( var, StrPut(string, encoding)
		; StrPut returns char count, but VarSetCapacity needs bytes.
		* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
	; Copy or convert the string.
	return StrPut(string, &var, encoding)
}
