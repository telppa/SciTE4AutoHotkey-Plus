
; TODO: Error checking

ExportExtension(extName, extFile)
{
	tree := Util_DirTree(ExtensionDir "\" extName)
	Util_DumpTree(extFile, tree)
	Util_CompressExtension(extFile, extFile, extName)
	return true
}

Util_CompressExtension(fIn, fOut, extName)
{
	global SciTEVersionInt
	
	FileGetSize, fSize, %fIn%
	FileRead, data, *c %fIn%
	
	; COMPRESSION_FORMAT_LZNT1 | COMPRESSION_ENGINE_MAXIMUM
	DllCall("ntdll\RtlGetCompressionWorkSpaceSize", "ushort", 0x102, "uint*", bufWorkSpaceSize, "uint*", fragWorkSpaceSize)
	VarSetCapacity(bufWorkSpace, bufWorkSpaceSize)
	
	VarSetCapacity(bufTemp, fSize)
	if DllCall("ntdll\RtlCompressBuffer", "ushort", 0x102, "ptr", &data, "uint", fSize
		, "ptr", &bufTemp, "uint", fSize, "uint", fragWorkSpaceSize, "uint*", cSize, "ptr", &bufWorkSpace) != 0
		throw Exception("BAD")
	
	f := FileOpen(fOut, "w", "UTF-8-RAW")
	f.Write("S4AHKEXT")
	f.WriteUInt(SciTEVersionInt)
	Util_FileWriteStr(f, extName)
	f.WriteUInt(fSize)
	f.RawWrite(bufTemp, cSize)
}

Util_DumpTree(f, tree)
{
	if !IsObject(f)
		f := FileOpen(f, "w", "UTF-8-RAW")
	
	tl := tree.MaxIndex(), tl := tl ? tl : 0
	f.WriteUInt(tl)
	for _,e in tree
	{
		Util_FileWriteStr(f, e.name)
		if e.isDir
		{
			f.WriteUInt(-1)
			Util_DumpTree(f, e.contents)
		} else
		{
			fullPath := e.fullPath
			FileGetSize, fSize, %fullPath%
			VarSetCapacity(fData, fSize)
			FileRead, fData, *c %fullPath%
			f.WriteUInt(fSize)
			f.RawWrite(fData, fSize)
			Util_FileAlign(f)
			VarSetCapacity(fData, 0)
		}
	}
}

Util_FileAlign(f)
{
	while f.Pos & 3
		f.WriteUChar(0)
}

Util_FileWriteStr(f, ByRef str)
{
	pos := f.Pos
	f.WriteUInt(0)
	f.Write(str)
	size := (tmp := f.Pos) - pos - 4
	f.Pos := pos
	f.WriteUInt(size)
	f.Pos := tmp
	Util_FileAlign(f)
}

Util_DirTree(dir)
{
	data := [], ldir := StrLen(dir)+1
	Loop, %dir%\*.*, 1
	{
		StringTrimLeft, name, A_LoopFileFullPath, %ldir%
		e := { name: name, fullPath: A_LoopFileLongPath }
		if SubStr(name, 0) = "~" || SubStr(name, -3) = ".bak" || name = "package.json"
			continue
		IfInString, A_LoopFileAttrib, D
		{
			e.isDir := true
			e.contents := Util_DirTree(A_LoopFileFullPath)
		}
		data.Insert(e)
	}
	return data
}
