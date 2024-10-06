#NoEnv
#Warn ClassOverwrite
#Requires AutoHotkey v1.1.33+

/*
在 dll 内部，会在编码确定性达到一定程度时返回，所以理论上无需担心速度而限制提供的数据大小，越多越好。
但考虑到读取巨大文件时依然会耗时很长，所以还是提供了 MaxReadBytes 参数，并默认限制为10M。
将 MaxReadBytes 参数设为0可读取整个文件。

以下4种编码无法通过指定 FileEncoding CPxxxx 的形式在 ahk 中进行转换并正确显示
但下面的链接中提供了一种基于 DllCall("LCMapStringW") 的额外方法进行转换
参考链接：https://www.autohotkey.com/board/topic/81138-solved-encoding-problem-ucs-2-big-endian/
	euc-tw
	iso-2022-kr
	utf-16be
	utf-32
以下4种编码在 Windows 文档中无对应代码页，故无法转换
参考链接：https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers
	iso-8859-10
	iso-8859-11
	iso-8859-16
	viscii
虽然上述8种编码的内容在 ahk 下很难进行直接的转换并正确显示
但考虑到本库可能为诸如 SciTE 等外部程序提供编码探测功能
故上述8种编码依然正常返回其对应的代码页
*/
FileGetCodePage(Path, MaxReadBytes := 10485760) {
	return UCharDet.CodePage[FileGetCharset(Path, MaxReadBytes)]
}

FileGetCharset(Path, MaxReadBytes := 10485760) {
	if (!f := FileOpen(Path, "r"))
	{
		f.Close()
		throw Exception(Format("Failed to open '{}'.", Path), -1, A_LastError)
	}
	else
	{
		f.Pos         := 0 ; 这句是必需的，删除会影响 utf-32 识别结果
		out_var_bytes := f.RawRead(out_var, (MaxReadBytes = 0 ? f.Length : MaxReadBytes))
		f.Close()
		
		return VarGetCharset(out_var, out_var_bytes)
	}
}

; Var must use ByRef, otherwise the string is easily truncated by 0x00.
VarGetCodePage(ByRef Var, MaxReadBytes := 0) {
	return UCharDet.CodePage[VarGetCharset(Var, MaxReadBytes)]
}

VarGetCharset(ByRef Var, MaxReadBytes := 0) {
  static UCD
	
  ; 直接在 static 中初始化 UCD 会报错，所以只能这样写
  if (UCD = "")
    UCD := new UCharDet()
	
	return UCD.DetectBytes(&Var, (MaxReadBytes = 0 ? VarSetCapacity(Var) : MaxReadBytes))
}

FileGetCodePageByBom(path) {
  f      := FileOpen(path, "r")
  f.Pos  := 0
  header := Format("{:X}{:X}{:X}", f.ReadUChar(), f.ReadUChar(), f.ReadUChar())
  f.Close()
  
  if (SubStr(header, 1, 4) = "FFFE")
    return 1200
  else if (SubStr(header, 1, 4) = "FEFF")
    return 1201
  else if (header = "EFBBBF")
    return 65001
  else
    return 0
}

; modified from https://www.autohotkey.com/boards/viewtopic.php?f=82&t=110783
class UCharDet
{
	static DllPath  := A_LineFile "\..\" (A_PtrSize = 8 ? "uchardet.dll" : "uchardet_x86.dll")
	static CodePage := {"ascii"             : 20127
										, "big5"              : 950
										, "euc-jp"            : 20932 ; 存在2种代码页 20932 51932 后者无法转换
										, "euc-kr"            : 51949
										, "euc-tw"            : 51950
										, "gb18030"           : 54936
										, "ibm852"            : 852
										, "ibm855"            : 855
										, "ibm865"            : 865
										, "ibm866"            : 866
										, "iso-2022-jp"       : 50220 ; 存在3种代码页 50220 50221 50222 三者均可转换
										, "iso-2022-kr"       : 50225
										, "iso-8859-1"        : 28591
										, "iso-8859-2"        : 28592
										, "iso-8859-3"        : 28593
										, "iso-8859-4"        : 28594
										, "iso-8859-5"        : 28595
										, "iso-8859-6"        : 28596
										, "iso-8859-7"        : 28597
										, "iso-8859-8"        : 28598
										, "iso-8859-9"        : 28599
										, "iso-8859-10"       : 28600 ; 无对应代码页 无法转换
										, "iso-8859-11"       : 28601 ; 无对应代码页 无法转换
										, "iso-8859-13"       : 28603
										, "iso-8859-15"       : 28605
										, "iso-8859-16"       : 28606 ; 无对应代码页 无法转换
										, "koi8-r"            : 20866
										, "mac-centraleurope" : 10029
										, "mac-cyrillic"      : 10007
										, "shift_jis"         : 932
										, "tis-620"           : 874
										, "uhc"               : 949
										, "utf-8"             : 65001
										, "utf-16"            : 1200
										, "utf-16be"          : 1201
										, "utf-16le"          : 1200
										, "utf-32"            : 12000
										, "viscii"            : 1258  ; 无对应代码页（但 1258 可部分转换）
										, "windows-1250"      : 1250
										, "windows-1251"      : 1251
										, "windows-1252"      : 1252
										, "windows-1253"      : 1253
										, "windows-1255"      : 1255
										, "windows-1256"      : 1256
										, "windows-1257"      : 1257
										, "windows-1258"      : 1258}

	/**
	 * Create an charset detector.
	 * @return an instance of uchardet_t.
	 *
	 * UCHARDET_INTERFACE uchardet_t uchardet_new(void);
	 */
	__New() {
		if (!this.hModule := DllCall("LoadLibrary", "Str", this.DllPath, "Ptr"))
			throw Exception(Format("Failed to load '{}'.", this.DllPath), -1, A_LastError)
		
		this.Ptr := DllCall(this.DllPath "\uchardet_new", "CDecl Ptr")
	}

	/**
	 * Delete an charset detector.
	 * @param ud [in] the uchardet_t handle to delete.
	 *
	 * UCHARDET_INTERFACE void uchardet_delete(uchardet_t ud);
	 */
	__Delete() {
		DllCall(this.DllPath "\uchardet_delete", "Ptr", this.Ptr, "CDecl")
		this.Ptr := ""
		
		DllCall("FreeLibrary", "Ptr", this.hModule)
		this.hModule := ""
	}

	/**
	 * Feed data to an charset detector.
	 * The detector is able to shortcut processing when it reaches certainty
	 * for an charset, so you should not worry about limiting input data.
	 * As far as you should be concerned: the more the better.
	 *
	 * @param ud [in] handle of an instance of uchardet
	 * @param data [in] data
	 * @param len [in] number of byte of data
	 * @return non-zero number on failure.
	 *
	 * UCHARDET_INTERFACE int uchardet_handle_data(uchardet_t ud, const char * data, size_t len);
	 */
	HandleData(pBytes, nBytes) {
		return DllCall(this.DllPath "\uchardet_handle_data", "Ptr", this.Ptr, "Ptr", pBytes, "Ptr", nBytes, "CDecl Int")
	}

	/**
	 * Notify an end of data to an charset detector.
	 * @param ud [in] handle of an instance of uchardet
	 * 
	 * UCHARDET_INTERFACE void uchardet_data_end(uchardet_t ud);
	 */
	DataEnd() {
		return DllCall(this.DllPath "\uchardet_data_end", "Ptr", this.Ptr, "CDecl")
	}

	/**
	 * Reset an charset detector.
	 * @param ud [in] handle of an instance of uchardet
	 * 
	 * UCHARDET_INTERFACE void uchardet_reset(uchardet_t ud);
	 */
	Reset() {
		return DllCall(this.DllPath "\uchardet_reset", "Ptr", this.Ptr, "CDecl")
	}

	/**
	 * Get an iconv-compatible name of the charset that was detected.
	 * @param ud [in] handle of an instance of uchardet
	 * @return name of charset on success and "" on failure.
	 * 
	 * UCHARDET_INTERFACE const char * uchardet_get_charset(uchardet_t ud);
	 */
	GetCharset() {
		return DllCall(this.DllPath "\uchardet_get_charset", "Ptr", this.Ptr, "CDecl AStr")
	}

	DetectBytes(pBytes, nBytes) {
		this.Reset()
		
		if res := this.HandleData(pBytes, nBytes)
			throw Exception("Internal 'uchardet' error, uchardet_handle_data() returned " res)
		
		this.DataEnd()
		
		return this.GetCharset()
	}
}