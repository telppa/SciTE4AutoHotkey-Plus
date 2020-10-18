AutoIndent(Code, Indent = "`t", Newline = "`r`n")
{
	IndentRegEx =
	( LTrim Join
	Catch|else|for|Finally|if|IfEqual|IfExist|
	IfGreater|IfGreaterOrEqual|IfInString|
	IfLess|IfLessOrEqual|IfMsgBox|IfNotEqual|
	IfNotExist|IfNotInString|IfWinActive|IfWinExist|
	IfWinNotActive|IfWinNotExist|Loop|Try|while
	)
	
	; Lock and Block are modified ByRef by Current
	Lock := [], Block := []
	ParentIndent := Braces := 0
	ParentIndentObj := []
	
	for each, Line in StrSplit(Code, "`n", "`r")
	{
		Text := Trim(RegExReplace(Line, "\s;.*")) ; Comment removal
		First := SubStr(Text, 1, 1), Last := SubStr(Text, 0, 1)
		FirstTwo := SubStr(Text, 1, 2)
		
		IsExpCont := (Text ~= "i)^\s*(&&|OR|AND|\.|\,|\|\||:|\?)")
		IndentCheck := (Text ~= "iA)}?\s*\b(" IndentRegEx ")\b")
		
		if (First == "(" && Last != ")")
			Skip := True
		if (Skip)
		{
			if (First == ")")
				Skip := False
			Out .= Newline . RTrim(Line)
			continue
		}
		
		if (FirstTwo == "*/")
			Block := [], ParentIndent := 0
		
		if Block.MinIndex()
			Current := Block, Cur := 1
		else
			Current := Lock, Cur := 0
		
		; Round converts "" to 0
		Braces := Round(Current[Current.MaxIndex()].Braces)
		ParentIndent := Round(ParentIndentObj[Cur])
		
		if (First == "}")
		{
			while ((Found := SubStr(Text, A_Index, 1)) ~= "}|\s")
			{
				if (Found ~= "\s")
					continue
				if (Cur && Current.MaxIndex() <= 1)
					break
				Special := Current.Pop().Ind, Braces--
			}
		}
		
		if (First == "{" && ParentIndent)
			ParentIndent--
		
		Out .= Newline
		Loop, % Special ? Special-1 : Round(Current[Current.MaxIndex()].Ind) + Round(ParentIndent)
			Out .= Indent
		Out .= Trim(Line)
		
		if (FirstTwo == "/*")
		{
			if (!Block.MinIndex())
			{
				Block.Push({ParentIndent: ParentIndent
				, Ind: Round(Lock[Lock.MaxIndex()].Ind) + 1
				, Braces: Round(Lock[Lock.MaxIndex()].Braces) + 1})
			}
			Current := Block, ParentIndent := 0
		}
		
		if (Last == "{")
		{
			Braces++, ParentIndent := (IsExpCont && Last == "{") ? ParentIndent-1 : ParentIndent
			Current.Push({Braces: Braces
			, Ind: ParentIndent + Round(Current[Current.MaxIndex()].ParentIndent) + Braces
			, ParentIndent: ParentIndent + Round(Current[Current.MaxIndex()].ParentIndent)})
			ParentIndent := 0
		}
		
		if ((ParentIndent || IsExpCont || IndentCheck) && (IndentCheck && Last != "{"))
			ParentIndent++
		if (ParentIndent > 0 && !(IsExpCont || IndentCheck))
			ParentIndent := 0
		
		ParentIndentObj[Cur] := ParentIndent
		Special := 0
	}
	
	if Braces
		throw Exception("Segment Open!")
	
	return SubStr(Out, StrLen(Newline)+1)
}
