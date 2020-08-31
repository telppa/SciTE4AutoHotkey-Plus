
goto _skip_ext_ahk

extmon:
if extMonShown
{
	Gui ExtMon:Show
	return
}
extMonFirstLabel := false
Gui ExtMon:+Owner%hwndgui% LabelExtMon Resize MinSize
Gui ExtMon:Default
Gui, Menu, ExtMonMenu
Gui, Margin, 0, 0
Gui, Add, ListView, w480 h320 Checked vExtMonLV hwndExtMonLVHWND -LV0x10, Name|Version|Author|Internal name
Util_ExtMonLoadExt()
Gui, Show,, Extension Manager
extMonShown := true
extMonRemoveList := {}
return

ExtMonClose:
Gui +OwnDialogs
MsgBox, 35, Extension Manager, Do you want to save changes? This requires a restart.
IfMsgBox, Cancel
	return
IfMsgBox, Yes
{
	for extName,_ in extMonRemoveList
		FileRemoveDir, %ExtensionDir%\%extName%, 1
	Util_ExtMonSaveExt()
}
Gui, Destroy
extMonShown := false
IfMsgBox, Yes
	gosub reloadextsForce
return

ExtMonSize:
GuiControl, Move, ExtMonLV, w%A_GuiWidth% h%A_GuiHeight%
return

ExtMonRemoveExt:
Gui +OwnDialogs
selRows := LV_GetCount("S")
if !selRows
	return
plural := selRows > 1 ? "s" : ""
MsgBox, 52, Extension Manager, Are you sure you want to remove the selected extension%plural%?
IfMsgBox, No
	return
Loop %selRows%
{
	x := LV_GetNext()
	LV_GetText(xt, x, 4)
	extMonRemoveList[xt] := true
	LV_Delete(x)
}
return

ExtMonExportExt:
Gui +OwnDialogs
if LV_GetCount("S") != 1
	return
extToExport := LV_GetNext()
LV_GetText(extIntlName, extToExport, 4)
FileSelectFile, expFile, S16, %extIntlName%.s4x, Export Extension, SciTE4AutoHotkey Extension (*.s4x)
if ErrorLevel
	return
if !RegExMatch(expFile, "\.[^\\/]+$")
	expFile .= ".exe"
if ExportExtension(extIntlName, expFile)
	MsgBox, 64, SciTE4AutoHotkey, Extension exported successfully!
else
	MsgBox, 16, SciTE4AutoHotkey, Failed to export the extension!
return

ExtMonCreateExt:
Gui +Disabled
Gui ExtCreate:+OwnerExtMon LabelExtCreate
Gui ExtCreate:Default
;Gui, Add, Text, w320, Not! Implemented! Sorry!
Gui, Add, Text, Section Right w90, Internal name:
Gui, Add, Edit, ys w320 vExtCreate_IntlName, com.yourname.extname
Gui, Add, Text, xs Section Right w90, Name:
Gui, Add, Edit, ys w320 vExtCreate_Name, Extension name
Gui, Add, Text, xs Section Right w90, Version:
Gui, Add, Edit, ys w320 vExtCreate_Version, 1.0
Gui, Add, Text, xs Section Right w90, Author:
Gui, Add, Edit, ys w320 vExtCreate_Author, Your name
Gui, Add, Text, xs Section Right w90, Behaviour:
Gui, Add, CheckBox, ys vExtCreate_HasProps Checked, Has SciTE properties
Gui, Add, CheckBox, vExtCreate_HasToolbar, Has Toolbar buttons
Gui, Add, CheckBox, vExtCreate_HasLua, Has custom Lua script
Gui, Add, Button, gExtCreateCreate w90, Create
Gui, Show,, New Extension
return

ExtCreateClose:
Gui Destroy
Gui ExtMon:-Disabled
Gui ExtMon:Show
return

ExtCreateCreate:
Gui +OwnDialogs
Gui, Submit, NoHide
if RegExMatch(ExtCreate_IntlName, "[\s\\/:\*?""<>\|]")
{
	MsgBox, 48, New Extension, The internal name should not contain whitespace or any of these characters:`n\ / : * ? `" < > |
	return
}
if !ExtCreate_Name || !ExtCreate_Version || !ExtCreate_Author
{
	MsgBox, 48, New Extension, The extension name, version and author should be filled in.
	return
}

tmpExtDir := ExtensionDir "\" ExtCreate_IntlName

IfExist, %tmpExtDir%\
{
	MsgBox, 48, New Extension, The specified internal name is already in use.
	return
}

gosub ExtCreateClose
Gui ExtMon:Default
Gui +OwnDialogs

FileCreateDir, %tmpExtDir%
manifest := "[Extension]`nName=" ExtCreate_Name "`nVersion=" ExtCreate_Version "`nAuthor=" ExtCreate_Author "`n`n[Behaviour]`n"
if ExtCreate_HasProps
{
	manifest .= "Properties=extension`n"
	FileAppend,
	(LTrim
	# Write properties specific to this extension here
	
	), %tmpExtDir%\extension.properties
}
if ExtCreate_HasToolbar
{
	manifest .= "Toolbar=toolbar.properties`n"
	FileAppend,
	(LTrim
	; Toolbar button definitions specific to this extension
	
	), %tmpExtDir%\toolbar.properties
}

if ExtCreate_HasLua
{
	manifest .= "LuaScript=extension.lua`n"
	FileEncoding, CP0
	FileAppend,
	(LTrim
	-- Lua script specific to this extension
	-- Declare event handler table
	local events = {}
	
	-- Event handler example
	--function events.OnChar(ch)
	--`tprint("OnChar: "..ch.."\n")
	--`t-- If you want to mark this event as being already handled thus stopping
	--`t-- propagation through all extensions and scripts, return true.
	--end
	
	-- Register events
	RegisterEvents(events)
	
	), %tmpExtDir%\extension.lua
	FileEncoding, UTF-8
}

FileAppend, % manifest, %tmpExtDir%\manifest.ini
LV_Add("Check", ExtCreate_Name, ExtCreate_Version, ExtCreate_Author, ExtCreate_IntlName)
return

ExtMonInstallExt:
Gui +OwnDialogs
FileSelectFile, extFile, 1,, Install Extension, SciTE4AutoHotkey Extension (*.s4x)
if ErrorLevel
	return

Loop
	tempName := "~temp" A_TickCount ".tmp", tempDir := ExtensionDir "\" tempName
until !FileExist(tempDir)

rc := ExtractExtension(tempDir, extFile, extIntlName)
if rc != OK
{
	FileRemoveDir, %tempDir%, 1
	MsgBox, 16, SciTE4AutoHotkey, Error while extracting extension! %rc%.
	return
}

if extMonRemoveList[extIntlName]
{
	MsgBox, 16, SciTE4AutoHotkey, You must restart SciTE before reinstalling a removed extension.
	return
}

extUpgrade := !!FileExist(willDir := ExtensionDir "\" extIntlName)
tempM := Util_GetExtManifest(tempName).Extension
if extUpgrade
{
	extPrevVer := Util_GetExtManifest(extIntlName).Extension.Version
	if (extPrevVer > tempM.Version)
	{
		FileRemoveDir, %tempDir%, 1
		MsgBox, 16, SciTE4AutoHotkey, It is not possible to downgrade an extension.
		return
	}
}

msgboxMsg := "Name: " tempM.Name "`nVersion: " tempM.Version
if extUpgrade
	msgBoxMsg .= "`nPrevious version: " extPrevVer
msgboxMsg .= "`nAuthor: " tempM.Author "`n`nDo you want to " (extUpgrade ? "upgrade" : "install") " this extension?"

MsgBox, 36, SciTE4AutoHotkey, % msgboxMsg
IfMsgBox, No
{
	FileRemoveDir, %tempDir%, 1
	return
}

if extUpgrade
{
	FileRemoveDir, %willDir%, 1
	if ErrorLevel
	{
		FileRemoveDir, %tempDir%, 1
		MsgBox, 16, SciTE4AutoHotkey, Could not remove old version.
		return
	}
}

FileMoveDir, %tempDir%, %willDir%
if ErrorLevel
{
	FileRemoveDir, %tempDir%, 1
	MsgBox, 16, SciTE4AutoHotkey, Could not install extension.
	return
}

if !extUpgrade
	LV_Add("Check", tempM.Name, tempM.Version, tempM.Author, extIntlName)
else
{
	Loop, % LV_GetCount()
	{
		LV_GetText(qq, A_Index, 4)
		if (qq = extIntlName)
		{
			LV_Modify(A_Index, "Check", tempM.Name, tempM.Version, tempM.Author, extIntlName)
			break
		}
	}
}

tempM := ""
return

Util_ExtMonLoadExt()
{
	for extName, enabled in Util_GetExtensionList()
	{
		m := Util_GetExtManifest(extName).Extension
		LV_Add(enabled ? "Check" : "", m.Name, m.Version, m.Author, extName)
	}
	LV_ModifyCol(1, "AutoHdr Sort")
	LV_ModifyCol(2, "AutoHdr")
	LV_ModifyCol(3, "AutoHdr")
	LV_ModifyCol(4, "AutoHdr")
}

Util_ExtMonSaveExt()
{
	global ExtMonLVHWND
	ini := "[Installed]`n"
	Loop, % LV_GetCount()
	{
		LV_GetText(extName, A_Index, 4)
		extEn := Util_LVIsChecked(ExtMonLVHWND, A_Index)
		ini .= extName "=" extEn "`n"
	}
	FileDelete, %ExtensionDir%\extensions.ini
	FileAppend, % ini, %ExtensionDir%\extensions.ini
}

Util_LVIsChecked(lvHwnd, rowN)
{
	SendMessage, 4140, rowN-1, 0xF000,, ahk_id %lvHwnd%
	return (ErrorLevel >> 12) - 1
}

Util_CheckReload()
{
	MsgBox, 36, SciTE4AutoHotkey, The selected operation involves a SciTE reload. Continue?
	IfMsgBox, No
		Exit
}

Util_ReloadSciTE()
{
	global SciTEDir, scitehwnd
	Run, "%A_AhkPath%" "%SciTEDir%\tools\SciTEReload.ahk" %scitehwnd%
	WinClose, ahk_id %scitehwnd%
}

Util_GetExtensionList()
{
	return Ini2Object(ExtensionDir "\extensions.ini").Installed
}

Util_GetExtManifest(name)
{
	return Ini2Object(ExtensionDir "\" name "\manifest.ini")
}

Util_ReadExtToolbarDef()
{
	global LocalSciTEPath
	
	data := ""
	
	for extName, enabled in Util_GetExtensionList()
	{
		if !enabled
			continue
		
		mBeh := Util_GetExtManifest(extName).Behaviour
		mPropFile := mBeh.Toolbar
		if !mPropFile
			continue
		
		FileRead, x, *t %LocalSciTEPath%\Extensions\%extName%\%mPropFile%
		StringReplace, x, x, `%EXTDIR`%, %LocalSciTEPath%\Extensions\%extName%, All
		data .= x "`n"
	}
	
	return data
}

Util_RebuildExtensions()
{
	global LocalSciTEPath, scitehwnd
	
	extProps := "# THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH`n"
	luaProps := "-- THIS FILE IS SCRIPT-GENERATED - DON'T TOUCH`n"
	langMenu := "", dlgFilter := ""
	for extName, enabled in Util_GetExtensionList()
	{
		if !enabled
			continue
		
		mBeh := Util_GetExtManifest(extName).Behaviour
		mLuaScript := mBeh.LuaScript
		mProperties := mBeh.Properties
		langMenu .= mBeh.LanguageMenu
		dlgFilter .= mBeh.FileFilter
		
		if mLuaScript
		{
			StringReplace, mLuaScript, mLuaScript, \, /, All
			luaProps .= "dofile(props['SciteUserHome']..'/Extensions/" extName "/" mLuaScript "')`n"
		}
		
		if mProperties
		{
			StringReplace, mProperties, mProperties, \, /, All
			Loop, Parse, mProperties, |
				extProps .= "import Extensions/" extName "/" Trim(A_LoopField) "`n"
		}
	}
	
	if langMenu
		extProps .= "ext.menu.language=" langMenu "`n"
	
	if dlgFilter
		extProps .= "filter.ext=" dlgFilter "`n"
	
	t := A_FileEncoding
	FileEncoding, CP0
	FileDelete, %LocalSciTEPath%\_extensions.lua
	FileAppend, % luaProps, %LocalSciTEPath%\_extensions.lua
	FileEncoding, %t%
	FileDelete, %LocalSciTEPath%\_extensions.properties
	FileAppend, % extProps, %LocalSciTEPath%\_extensions.properties
	;SendMessage, 1024+1, 0, 0,, ahk_id %scitehwnd% ; Reload properties
}

Util_VersionTextToNumber(v)
{
	r := 0, i := 0
	while i < 4 && RegExMatch(v, "O)^(\d+).?", o)
	{
		StringTrimLeft, v, v, % o.Len
		val := o[1] + 0
		r |= (val&0xFFFF) << ((3-i)*8)
		i ++
	}
	return r
}

_skip_ext_ahk:
_=_
