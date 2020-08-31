;
; File encoding:  UTF-8
;

Util_ParsePlatforms(file, ByRef platlist)
{
	plats := {}
	FileRead, file, %file%
	
	platlist := Util_EnumPlatforms(file)
	for i,plat in platlist
		plats[plat] := Util_EvalPlatform(file, plat)
	
	return plats
}

Util_EnumPlatforms(ByRef file)
{
	plats := {}
	Loop, Parse, file, `n, `r
	{
		line := Trim(A_LoopField)
		if (l := SubStr(line, 1, 10)) = ".platform "
		{
			lplats := SubStr(line, 11)
			Loop, Parse, lplats, `,
				plats.Insert(Trim(A_LoopField))
		} else if (l = ".condplat ")
		{
			StringTrimLeft, line, line, 10
			if RegExMatch(line, "^\s*(.+?)\s+(.+)$", o)
			{
				res := false
				,plat := o1
				,cond := o2
				,parm := {}
				Loop, Parse, cond, `,
					(A_Index > 1) ? parm.Insert(Util_Dereference(Trim(A_LoopField))) : (func := Trim(A_LoopField))
				if func in FileExist,WinActive,WinExist
					res := !!%func%(parm*)
				if res
					plats.Insert(plat)
			}
		}
	}
	return plats
}

Util_Dereference(str)
{
	global AhkDir
	StringReplace, str, str, `%AhkDir`%, %AhkDir%, All
	StringReplace, str, str, ```%, `%, All
	return str
}

Util_EvalPlatform(ByRef file, plat)
{
	evalresult = # THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH`nahk.platform=%plat%`n
	condlock = 0
	Loop, Parse, file, `n, `r
	{
		line := Trim(A_LoopField)
		
		; Minimal parsing when in conditional section
		if condlock > 0
		{
			if SubStr(line, 1, 4) = ".if " && !InStr(line, "=")
				condlock ++
			if line = .end
				condlock --
			continue
		}
		
		; Comment ignoring
		else if SubStr(line, 1, 1) = ";"
			continue
		
		; Conditional parsing
		else if SubStr(line, 1, 4) = ".if "
		{
			isAssign := false
			isTrue := false
			
			plats := Trim(SubStr(line, 5))
			if InStr(plats, "=")
			{
				isAssign := true
				spcPos := InStr(plats, " ")
				line := Trim(SubStr(plats, spcPos+1))
				plats := SubStr(plats, 1, spcPos-1)
			}
			
			Loop, Parse, plats, `,
			if(Trim(A_LoopField) = plat)
			{
				isTrue := true
				break
			}
			
			if(!isTrue && !isAssign)
				condlock ++
			else if(isTrue && isAssign)
				evalresult .= line "`n"
		}
		
		; Statement
		else if InStr(line, "=")
			evalresult .= line "`n"
	}
	
	StringTrimRight, evalresult, evalresult, 1
	return evalresult
}
