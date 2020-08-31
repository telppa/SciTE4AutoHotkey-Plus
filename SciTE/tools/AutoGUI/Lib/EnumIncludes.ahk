/**
 * Function: EnumIncludes
 *     Enumerates all #Include files in the specified script by passing the
 *     the full path to each included file, in turn, to the specified callback
 *     function.
 * Syntax:
 *     count := EnumIncludes( AhkScript, callback [, AhkExe ] )
 * Parameter(s):
 *     count      [retval] - total number of identified #Include(s)
 *     AhkScript      [in] - AutoHotkey script file to scan
 *     callback       [in] - callback function, must be a "Function object"
 *     AhkExe    [in, opt] - if specified, must be the path to the AutoHotkey.exe
 *                           to use as reference for the standard library folder
 *                           location. Defaults to A_AhkPath
 * Remarks:
 *     To continue enumeration, the callback function must return true(1); to stop
 *     enumeration, it must return false(0) or blank("").
 */
EnumIncludes(AhkScript, callback, AhkExe:="")
{
	if !IsObject(callback)
		throw Exception("Invalid parameter -> object expected", -1, callback)
	
	static FullPath
	if !VarSetCapacity(FullPath)
		VarSetCapacity(FullPath, 260 * (A_IsUnicode ? 2 : 1))

	if DllCall("GetFullPathName", "Str", AhkScript, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt")
		AhkScript := FullPath
	SplitPath, % AhkScript ,, AhkScriptDir

	if (AhkExe != "") && DllCall("GetFullPathName", "Str", AhkExe, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt")
		AhkExe := FullPath
	if (AhkExe == "") || !FileExist(AhkExe)
		AhkExe := A_AhkPath
	
	cwd := A_WorkingDir
	SetWorkingDir, %AhkScriptDir%
	
	WshExec := "" ; for /iLib (auto-includes)
	includes := {}, count := 0
	script := [ AhkScript ]
	queue := [ AhKScript ]
	while IsObject(f := ObjRemoveAt(queue, 1)) || (f := FileOpen(f, 0|4))
	{
		IsBlockComment := false
		IsContSection := false

		AtEOF := ComObjType(f) ? "AtEndOfStream" : "AtEOF"
		while !f[AtEOF] ; when resumed, will always continue at last postion of file pointer
		{
			line := Trim(f.ReadLine(), " `t`r`n")
			if (line == "")
				continue
			
			if !IsBlockComment && !IsContSection
				if !(IsBlockComment := InStr(line, "/*") == 1) && (InStr(line, "(") == 1)
					IsContSection := line ~= "i)^\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"
			; skip if within block comment/continuation section or if it's a solitary line comment
			if (IsBlockComment && (InStr(line, "*/")==1 ? !(IsBlockComment := false) : 1))
			|| (IsContSection && (InStr(line, ")")==1 ? !(IsContSection := false) : 1))
			|| (InStr(line, ";") == 1)
				continue

			if RegExMatch(line, "Oi)^#Include(?:Again)?(?:\s*,\s*|\s+)(?:\*i\s+)?(\S.*?)(?:\s*|\s+;.*)$", match)
			{
				ThisInclude := ""
				
				static ss_End := A_AhkVersion < "2" ? 0 : -1
				if (InStr(match[1], "<") == 1) && (SubStr(match[1], ss_End) == ">")
				{
					lib := Trim(SubStr(match[1], 2, -1), " `t")
					if pfx := InStr(lib, "_",, 2)
						pfx := SubStr(lib, 1, pfx-1)

					libs := [AhkScript . "\..\Lib", A_MyDocuments . "\AutoHotkey\Lib", AhkExe . "\..\Lib"]
					for i, dir in libs
					{
						if FileExist(ThisInclude := Format("{1}\{2}.ahk", dir, lib))
						|| (pfx && FileExist(ThisInclude := Format("{1}\{2}.ahk", dir, pfx)))
							break
						ThisInclude := ""
					}
				}
				else
				{
					ThisInclude := StrReplace(match[1], "`%A_ScriptDir`%", AhkScriptDir)
					ThisInclude := StrReplace(ThisInclude, "`%A_AppData`%", A_AppData)
					ThisInclude := StrReplace(ThisInclude, "`%A_AppDataCommon`%", A_AppDataCommon)
					ThisInclude := StrReplace(ThisInclude, "`%A_LineFile`%", script[1])

					if InStr(FileExist(ThisInclude), "D")
					{
						SetWorkingDir, %ThisInclude%
						continue
					}
				}

				if (ThisInclude != "") && DllCall("GetFullPathName", "Str", ThisInclude, "UInt", 260, "Str", FullPath, "Ptr", 0, "UInt")
					ThisInclude := FullPath

				if FileExist(ThisInclude) && !includes[ThisInclude]
				{
					includes[ThisInclude] := ++count ; value doesn't really matter as long as it's 'truthy'
					if !callback.Call(ThisInclude)
					{
						f.Close(), f := ""
						break 2
					}
					
					ObjPush(script, ThisInclude)
					ObjPush(queue, ThisInclude)
				}
			} ; if RegExMatch( ... )
		} ; while !f[AtEOF]

		f.Close(), f := "" ; close file/stream
		ObjRemoveAt(script, 1)

		if !ObjLength(queue) && !WshExec
		{
			cmd := Format("{1}{2}{1} /iLib * /ErrorStdOut {1}{3}{1}", Chr(34), A_AhkPath, AhkScript)
			WshExec := ComObjCreate("WScript.Shell").Exec(cmd)
			
			if (err := WshExec.StdErr.ReadAll())
			{
				e := Exception("Failed to retrieve auto-included script files. Script contains syntax error(s).", -1, cmd)
				; idea taken from Lexikos' LoadFile
				if RegExMatch(err, "Os)(.*?) \((\d+)\) : ==> (.*?)(?:\s*Specifically: (.*?))?\R?$", m)
					e.Message .= "`n`nReason:`t" . m[3] . "`nLine text:`t" . m[4] . "`nFile:`t" . m[1] . "`nLine:`t" . m[2]
				throw e
			}
			
			ObjPush(script, "*")
			ObjPush(queue, WshExec.StdOut)
		}
	} ; while IsObject(f := ObjRemoveAt(queue, 1)) ...
 	
	SetWorkingDir, %cwd%

	return count ; NumGet(&includes + 4*A_PtrSize)
}