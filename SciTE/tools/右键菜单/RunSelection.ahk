#Requires AutoHotkey v1.1.33+
#NoEnv
#NoTrayIcon
#SingleInstance Force

if (!oSciTE := GetSciTEInstance())
    ExitApp

ScriptDir   := oSciTE.GetProp("FileDir")
FileNameExt := oSciTE.GetProp("FileNameExt")
AhkPath     := oSciTE.GetProp("AutoHotkey")
Selection   := oSciTE.GetSelection()

SetWorkingDir %ScriptDir%

if (RegExReplace(Selection, "\s+") = "")
    oSciTE.SetOutput(">没有任何代码被选中!`n")
else
{
    oSciTE.SetOutput(">" AhkPath " /CP65001 *`n")
    ExecScript(Selection, , AhkPath, FileNameExt)
}
ExitApp

ExecScript(Script, Params := "", AhkPath := "", FileNameExt := "") {
    Pipe := []
    PipeName := "\\.\pipe\" . (FileNameExt ? FileNameExt : "AHK_CQT_" . A_TickCount)

    ; Before reading the file, AutoHotkey calls GetFileAttributes().
    ; This causes the pipe to close, so we must create a second pipe for the actual file contents.
    Loop 2
        Pipe[A_Index] := DllCall( "CreateNamedPipe"
                                , "Str", PipeName, "UInt", 2, "UInt", 0, "UInt", 255
                                , "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", 0, "Ptr")

    If (!FileExist(AhkPath)) {
        AhkPath := A_AhkPath
    }

    Shell := ComObjCreate("WScript.Shell")
    Call = "%AhkPath%" /CP65001 "%PipeName%" %Params%
    Exec := Shell.Exec(Call)

    ; Wait for AutoHotkey to connect to Pipe[1] via GetFileAttributes().
    DllCall("ConnectNamedPipe", "Ptr", Pipe[1], "Ptr", 0)
    ; This pipe is not needed, so close it now.
    DllCall("CloseHandle", "Ptr", Pipe[1])

    DllCall("ConnectNamedPipe", "Ptr", Pipe[2], "Ptr", 0)
    File := FileOpen(Pipe[2], "h", "UTF-8")
    File.Write(Script)
    File.Close()
    DllCall("CloseHandle", "Ptr", Pipe[2])

    Return Exec.StdOut.ReadAll()
}

#Include %A_LineFile%\..\..\Lib\GetSciTEInstance.ahk