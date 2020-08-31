;
; File encoding:  UTF-8
;

CEscape(ByRef stQ)
{	
	StringReplace, str, stQ, \, \\, All
	StringReplace, str, str, `a, \a, All
	StringReplace, str, str, `b, \b, All
	StringReplace, str, str, `f, \f, All
	StringReplace, str, str, `n, \n, All
	StringReplace, str, str, `r, \r, All
	StringReplace, str, str, %A_Tab%, \t, All
	StringReplace, str, str, `v, \v, All
	Loop, % Asc(" ")-1
		StringReplace, str, str, % Chr(A_Index), % "\" (A_Index>>6) (A_Index>>3) (A_Index & 7), All
	return str
}
