;
; SciTE4AutoHotkey Updater
;

#SingleInstance Off
#NoEnv
#NoTrayIcon
SendMode Input
SetWorkingDir, %A_ScriptDir%

baseurl = http://fincs.ahk4.net/scite4ahk
isPortable := FileExist("..\$PORTABLE")
today := SubStr(A_Now, 1, 8)
if !isPortable
	LocalSciTEPath = %A_MyDocuments%\AutoHotkey\SciTE
else
	LocalSciTEPath = %A_ScriptDir%\..\user

if 1 = /silent
	isSilent := true
if 1 = /doUpdate
{
	if !A_IsAdmin
		ExitApp
	curRev = %2%
	toFetch = %3%
	curRev += 0
	toFetch += 0
	goto _doUpdate
}

if isSilent
{
	FileRead, lastUpdate, %LocalSciTEPath%\$LASTUPDATE
	if (lastUpdate = today)
		ExitApp
}

f = %A_Temp%\%A_TickCount%.txt
if !isSilent
	ToolTip, Fetching update info...
try
{
	URLDownloadToFile, %baseurl%/upd/version.txt, %f%
	FileRead, latestVer, %f%
	URLDownloadToFile, %baseurl%/upd/revision.txt, %f%
	FileRead, latestRev, %f%
	if !isSilent
		ToolTip
}catch
{
	if !isSilent
	{
		ToolTip
		MsgBox, 16, SciTE4AutoHotkey Updater, Can't connect to the Internet!
	}
	ExitApp
}

FileRead, curVer, ..\$VER
if (curVer < latestVer)
{
	MsgBox, 36, SciTE4AutoHotkey Updater,
	(LTrim
	There is a new SciTE4AutoHotkey version.
	
	Current version:`t%curVer%
	Latest version:`t%latestVer%
	
	Do you wish to download and install it? (a website will be opened)
	Keep in mind that your current version is no longer supported and
	you aren't able anymore to receive hotfixes and definition updates
	until you upgrade to the latest version.
	)
	IfMsgBox, Yes
		Run, %baseurl%/
	ExitApp
}

FileRead, curRev, ..\$REVISION
if curRev =
	curRev := 0

if (curRev >= latestRev)
{
	FileDelete, %LocalSciTEPath%\$LASTUPDATE
	FileAppend, %today%, %LocalSciTEPath%\$LASTUPDATE
	if !isSilent
		MsgBox, 64, SciTE4AutoHotkey Updater, SciTE4AutoHotkey is up to date.
	ExitApp
}

toFetch := latestRev - curRev

MsgBox, 36, SciTE4AutoHotkey Updater,
(
There are %toFetch% update(s) available for SciTE4AutoHotkey.

Do you wish to download and install them?
)
IfMsgBox, No
	ExitApp

CloseSciTE()

if !isPortable && !A_IsAdmin
{
	Run, *RunAs "%A_AhkPath%" "%A_ScriptFullPath%" /doUpdate %curRev% %toFetch%
	ExitApp
}

_doUpdate:

Gui, Add, Text, x12 y10 w390 h20 vMainLabel, Please wait whilst updates are being processed...
Gui, Add, ListView, x12 y30 w390 h180 NoSortHdr NoSort -LV0x10 LV0x1, #|Status|Title|Description
Gui, Show, w411 h226, SciTE4AutoHotkey Updater
Gui, +OwnDialogs

Loop, % toFetch
{
	i := curRev + A_Index
	LV_Add("", i, "Queued", "<<not loaded>>", "<<not loaded>>")
}
LV_ModifyCol()

Loop, % toFetch
{
	i := curRev + A_Index
	LV_Modify(A_Index, "", i, "Downloading...", "<<not loaded>>", "<<not loaded>>")
	LV_ModifyCol()
	
	try
	{
		URLDownloadToFile, %baseurl%/upd/%i%.bin, %A_Temp%\S4AHKupd_%i%.bin
		
		upd := new Update(A_Temp "\S4AHKupd_" i ".bin", "{912B7AED-660B-4BC4-8DA3-34E394D9BBBA}")
		LV_Modify(A_Index, "", i, "Running...", upd.title, upd.descr)
		LV_ModifyCol()
		
		updfold = %A_Temp%\SciTEUpdate%A_Now%
		FileCreateDir, %updfold%
		upd.Run(updfold)
		FileRemoveDir, %updfold%, 1
		
		IfExist, ..\$REVISION
			FileDelete, ..\$REVISION
		FileAppend, %i%, ..\$REVISION
		
		LV_Modify(A_Index, "", i, "Done!", upd.title, upd.descr)
		LV_ModifyCol()
		
		upd := ""
	}catch e
	{
		GuiControl,, MainLabel, There were errors during the update.
		updDone := 1
		MsgBox, 16, SciTE4AutoHotkey Updater, % "There was an error during the update!`n" e.message "`nwhat: " e.what "`nextra: " e.extra
		return
	}
}

FileDelete, %LocalSciTEPath%\$LASTUPDATE
FileAppend, %today%, %LocalSciTEPath%\$LASTUPDATE

GuiControl,, MainLabel, You may now close this window and reopen SciTE.
updDone := 1
MsgBox, 64, SciTE4AutoHotkey Updater, SciTE4AutoHotkey was successfully updated!
return

GuiClose:
if !updDone
{
	MsgBox, 48, SciTE4AutoHotkey Updater, You cannot stop the updating process.
	return
}
ExitApp

/*
Format of a SciTE4AutoHotkey update file:

typedef struct
{
	char magic[4]; // fUPD
	byte_t guid[16]; // program GUID
	int revision;
	int fileCount;
	int scriptFile;
	int infoOff;
} updateHeader_t;

typedef struct
{
	int dataLen;
	byte_t data[dataLen];
} updateFile_t;

typedef struct
{
	int nameLen, descrLen;
	char name[nameLen]; // UTF-8
	char descr[descrLen]; // UTF-8
} updateInfo_t;
*/

class Update
{
	__New(filename, reqGUID)
	{
		f := FileOpen(filename, "r", "UTF-8-RAW")
		if f.Read(4) != "fUPD"
			throw Exception("Invalid update file!", 0, filename)
		if ReadGUID(f) != reqGUID
			throw Exception("Invalid update file!", 0, filename)
		this.f := f
		this.revision := f.ReadUInt()
		this.fileCount := f.ReadUInt()
		this.scriptID := f.ReadUInt()
		infoPos := f.ReadUInt()
		this.filePos := f.Pos
		f.Pos := infoPos
		titleLen := f.ReadUInt(), descrLen := f.ReadUInt()
		VarSetCapacity(buf, infoSize := titleLen + descrLen) ; + 2)
		f.RawRead(buf, infoSize)
		this.title := StrGet(&buf, titleLen, "UTF-8")
		this.descr := StrGet(&buf + titleLen, descrLen, "UTF-8")
	}
	
	Run(target)
	{
		sID := this.scriptID
		f := this.f
		f.Pos := this.filePos
		Loop, % this.fileCount
		{
			id := A_Index-1
			size := f.ReadUInt()
			if !size
				continue
			f2 := FileOpen(target "\" (id != sID ? id ".bin" : "update.ahk"), "w")
			VarSetCapacity(buf, size)
			f.RawRead(buf, size)
			f2.RawWrite(buf, size)
			f2 := ""
		}
		VarSetCapacity(buf, 0)
		
		FileCreateDir, %target%\Lib
		FileCopy, %A_ScriptDir%\Lib\SUpd.ahk, %target%\Lib\SUpd.ahk
		
		RunWait, "%A_AhkPath%" "%target%\update.ahk"
		if ErrorLevel != 0
			throw Exception("Update failed.", 0, "Revision " this.revision)
	}
	
	__Delete()
	{
		this.f.Close()
	}
}

CloseSciTE()
{
	ComObjError(0)
	o := ComObjActive("SciTE4AHK.Application")
	ComObjError(1)
	if !o
		return
	hWnd := o.SciTEHandle
	o := ""
	WinClose, ahk_id %hwnd%
	WinWaitClose, ahk_id %hwnd%,, 5
	if ErrorLevel = 1
		ExitApp
}

ReadGUID(f)
{
	VarSetCapacity(bGUID, 16)
	f.RawRead(bGUID, 16)
	VarSetCapacity(guid, 100)
	DllCall("ole32\StringFromGUID2", "ptr", &bGUID, "ptr", &guid, "int", 50)
	return StrGet(&guid, "UTF-16")
}
