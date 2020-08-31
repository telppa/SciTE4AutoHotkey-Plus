;
; File encoding:  UTF-8
;

goto _aaa_skip

UpdateProfile:
StringReplace, lblname, SciTEVersion, %A_Space%, _, All
if (SciTEVersion > CurrentSciTEVersion) || (SciTEVersion < "3.0.00")
{
	SciTEVersion := ""
	return
}

FileDelete, %LocalSciTEPath%\_platform.properties
FileDelete, %LocalSciTEPath%\$VER
FileAppend, %CurrentSciTEVersion%, %LocalSciTEPath%\$VER
OldVer := SciTEVersion
SciTEVersion := CurrentSciTEVersion
regenerateUserProps := true
if (OldVer < "3.0.05")
	gosub Update_3.0.05
return

Update_3.0.05:
BackupIfExist(LocalSciTEPath "\Styles\Blank.style.properties")
BackupIfExist(LocalSciTEPath "\Styles\Classic.style.properties")
BackupIfExist(LocalSciTEPath "\Styles\Light.style.properties")
BackupIfExist(LocalSciTEPath "\Styles\VisualStudio.style.properties")
FileCopy, %SciTEDir%\newuser\Styles\Blank.style.properties, %LocalSciTEPath%\Styles\Blank.style.properties, 1
FileCopy, %SciTEDir%\newuser\Styles\Classic.style.properties, %LocalSciTEPath%\Styles\Classic.style.properties, 1
FileCopy, %SciTEDir%\newuser\Styles\Light.style.properties, %LocalSciTEPath%\Styles\Light.style.properties, 1
FileCopy, %SciTEDir%\newuser\Styles\VisualStudio.style.properties, %LocalSciTEPath%\Styles\VisualStudio.style.properties, 1
return

BackupIfExist(file)
{
	FileMove, %file%, %file%.old, 1
}

_aaa_skip:
_=_
