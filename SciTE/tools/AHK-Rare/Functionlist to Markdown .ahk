#NoEnv
SetBatchLines, -1
FileEncoding, UTF-8

funclist:= listfunc2MD(A_ScriptDir "\AHK-Rare.ahk")

today:= A_DD "-" A_MM "-" A_YYYY
file := A_ScriptDir "\" today "_MDTable.md"

MsgBox, % funclist

file:= FileOpen(file, "w", "UTF-8")
file.Write(funclist)
file.Close()


;Reads files.txt , and opens file by file - it search for function - store them into functions object + store the containing script
;todo - retreave informations about the functions from script lines - detect ; or /**/

/*
Loop, Read, files.txt
{
	filename:=A_LoopReadLine
	ToolTip, File: %A_Index%/%countlines1%, 2000, 500, 6
	funcList:= listfunc(filename)
	If NOT (funcList="") {
		FileAppend, `;`{ %Filename% `n`n`;Functions`:`n, FunctionList.txt
		FileAppend, %funclist%`n, FunctionList.txt

		If Not (rl="") {
			FileAppend, `;Labels`:`n%rl%`n, FunctionList.txt
		}

		FileAppend, `;`}`n`n, FunctionList.txt

		}


}
*/



exitApp

Listfunc2MD(file){																;--list all functions inside a ahk script and write MarkDown Table

	f:=0, s:=0, i:=0
	lst =
			(LTrim
			| FNr | Line | name of function and description |
			|:--: | :--: | :--: |`n
			)

	fileread, z, % file

	Loop, Parse, z, `n, `r
	{
		i++
		ALF:= A_LoopField
		If RegExMatch(ALF, ";\s?<")
			s:=0
		else If RegExMatch(ALF, ";\s?sub")
			s:=1

		If s = 1
			continue

		fnp1:= Instr(ALF, "`(")
		fnp2:= Instr(ALF, "`{")
		cmt:= Instr(ALF, ";--")+3
		If (fnp1 > 0) && (cmt > 0) && (fnp1<cmt)
		{
				f++
				dsc:= Trim(SubStr(ALF, cmt, StrLen(ALF)-cmt+1))
				If !(dsc="")
						dsc:= " - *" . dsc . "*"
				lst.= "| " . SubStr("00000", 1, 3-StrLen(f)) . f . " | " . SubStr("00000", 1, 5-StrLen(i)) . i . " | **" . Trim(SubStr(ALF, 1, fnp1)) . "`)**" . dsc . " |`n"
		}


	}

	return lst

}

