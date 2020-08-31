;
; File encoding:  UTF-8
;

CUnescape(ByRef stQ)
{
	ListLines, Off
	escp := false
	Loop, Parse, stQ
	{
		c := A_LoopField
		if escp
		{
			escp := false
			if c = \
				c = \
			else if c = a
				c = `a
			else if c = b
				c = `b
			else if c = f
				c = `f
			else if c = n
				c = `n
			else if c = r
				c = `r
			else if c = t
				c = %A_Tab%
			else if c = v
				c = `v
			; TODO: octal stuff
		}else if c = \
		{
			escp := true
			continue
		}
		str .= c
	}
	ListLines, On
	return str
}
