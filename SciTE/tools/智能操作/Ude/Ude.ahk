/*
    https://www.autohotkey.com/boards/viewtopic.php?t=98241
    
    Please note that if their encoding number = 0, that means we can detect them, but their encoding number is unknown for Windows.
    That also means you can NOT transform them by using AHK.
    
    X-ISO-10646-UCS-4-3412 = 0
    X-ISO-10646-UCS-4-2413 = 0
    EUC-TW                 = 0
    ISO-2022-CN            = 0
    ASCII                  = 20127
    UTF-8                  = 65001
    UTF-16LE               = 1200
    UTF-16BE               = 1201
    UTF-32LE               = 12000
    UTF-32BE               = 12001
    windows-1251           = 1251
    windows-1252           = 1252
    windows-1253           = 1253
    windows-1255           = 1255
    Big-5                  = 950
    EUC-KR                 = 51949
    EUC-JP                 = 51932
    gb18030                = 54936
    ISO-2022-JP            = 50222
    ISO-2022-KR            = 50225
    HZ-GB-2312             = 52936
    Shift-JIS              = 932
    x-mac-cyrillic         = 10007
    KOI8-R                 = 20866
    IBM855                 = 855
    IBM866                 = 866
    ISO-8859-2             = 28592
    ISO-8859-5             = 28595
    ISO-8859-7             = 28597
    ISO-8859-8             = 28598
    TIS620                 = 874
*/

FileGetEncoding(path, minConfidence := 0)
{
    static dllPath := A_LineFile "\..\" (A_PtrSize=8 ? "UdeExport.dll" : "UdeExport_x86.dll")
    
    ; disable error when file not exist.
    if (!FileExist(path))
        return
    
    encArr := ComObject(0x200C, DllCall(dllPath "\GetFileEncoding", "Ptr", &path, "Ptr"), 1)
    if (encArr[1] and encArr[2] >= minConfidence)
        return encArr[1]
}

FileGetFormat(path, minConfidence := 0)
{
    static dllPath := A_LineFile "\..\" (A_PtrSize=8 ? "UdeExport.dll" : "UdeExport_x86.dll")
    
    if (!FileExist(path))
        return
    
    encArr := ComObject(0x200C, DllCall(dllPath "\GetFileEncoding", "Ptr", &path, "Ptr"), 1)
    if (encArr[0] and encArr[2] >= minConfidence)
        return encArr[0]
}

; str must use ByRef, otherwise the string is easily truncated by 0x00.
StringGetEncoding(ByRef str, minConfidence := 0)
{
    static dllPath := A_LineFile "\..\" (A_PtrSize=8 ? "UdeExport.dll" : "UdeExport_x86.dll")
    
    encArr := ComObject(0x200C, DllCall(dllPath "\GetStringEncoding", "Ptr", &str, "Ptr"), 1)
    if (encArr[1] and encArr[2] >= minConfidence)
        return encArr[1]
}

StringGetFormat(ByRef str, minConfidence := 0)
{
    static dllPath := A_LineFile "\..\" (A_PtrSize=8 ? "UdeExport.dll" : "UdeExport_x86.dll")
    
    encArr := ComObject(0x200C, DllCall(dllPath "\GetStringEncoding", "Ptr", &str, "Ptr"), 1)
    if (encArr[0] and encArr[2] >= minConfidence)
        return encArr[0]
}

FileGetEncodingWithBom(path)
{
  f := FileOpen(path, "r")
  f.Seek(0)
  header2 := Format("{:X}{:X}", f.ReadUChar(), f.ReadUChar())
  header3 := Format("{}{:X}", header2, f.ReadUChar())
  f.Close()
  
  if (header2="FFFE")
    return, 1200
  else if (header2="FEFF")
    return, 1201
  else if (header3="EFBBBF")
    return, 65001
  else
    return, 0
}