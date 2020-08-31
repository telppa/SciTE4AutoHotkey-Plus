
Ini2Object(file)
{
	obj := {}, curSect := ""
	IfNotExist, %file%
		return
	Loop, Read, %file%
	{
		x := Trim(A_LoopReadLine), fc := SubStr(x, 1, 1)
		if !x || fc = ";"
			continue
		if fc = [
		{
			if SubStr(x, 0) != "]"
				return ; invalid
			
			curSect := SubStr(x, 2, -1)
		} else
		{
			if not p := InStr(x, "=")
				return ; invalid
			k := RTrim(SubStr(x, 1, p-1))
			v := LTrim(SubStr(x, p+1))
			obj[curSect, k] := v
		}
	}
	return obj
}
