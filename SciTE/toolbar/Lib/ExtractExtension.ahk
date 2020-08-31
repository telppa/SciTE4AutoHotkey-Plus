
ExtractExtension(dir, extFile, ByRef outExtId)
{
	global SciTEVersionInt
	
	FileGetSize, dataSize, %extFile%
	FileRead, data, *c %extFile%
	pData := &data
	if StrGet(pData, 8, "UTF-8") != "S4AHKEXT"
		return "Invalid format"
	if NumGet(data, 8, "UInt") > SciTEVersionInt
		return "Extension requires a newer version of SciTE4AutoHotkey"
	
	outExtId := Util_ReadLenStr(pData+12, pData)
	uncompSize := NumGet(pData+0, "UInt"), pData += 4
	
	VarSetCapacity(uncompData, uncompSize)
	; COMPRESSION_FORMAT_LZNT1 | COMPRESSION_ENGINE_MAXIMUM
	if DllCall("ntdll\RtlDecompressBuffer", "ushort", 0x102, "ptr", &uncompData, "uint", uncompSize
		, "ptr", pData, "uint", &data + dataSize - pData, "uint*", finalSize) != 0
		return "Decompression error"
	
	return Util_ExtractTree(&uncompData, dir) ? "OK" : "FAIL"
}

Util_ExtractTree(ptr, dir)
{
	try FileCreateDir, %dir%
	nElems := NumGet(ptr+0, "UInt"), ptr += 4
	Loop, %nElems%
	{
		name := dir "\" Util_ReadLenStr(ptr, ptr)
		size := NumGet(ptr+0, "UInt"), ptr += 4
		if (size = 0xFFFFFFFF)
		{
			; Directory
			if not ptr := Util_ExtractTree(ptr, name)
				break
		} else
		{
			f := FileOpen(name, "w", "UTF-8-RAW")
			f.RawWrite(ptr+0, size)
			f := ""
			ptr += (size+3) &~ 3
		}
	}
	return ptr
}

Util_ReadLenStr(ptr, ByRef endPtr)
{
	len := NumGet(ptr+0, "UInt")
	endPtr := ptr + ((len+7)&~3)
	return StrGet(ptr+4, len, "UTF-8")
}
