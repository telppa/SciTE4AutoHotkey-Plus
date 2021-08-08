; https://docs.microsoft.com/en-us/windows/desktop/api/shellapi/nf-shellapi-shellaboutw
ShellAbout(hWnd := 0, AppName := "", Message := "", hIcon := 0) {
    DllCall("shell32.dll\ShellAbout", "Ptr", hWnd, "Str", AppName, "Str", Message, "Ptr", hIcon)
}