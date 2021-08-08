MessageBox(hWnd, Text, Title := "", Flags := 0) {
    Return DllCall("MessageBox", "Ptr", hWnd, "Str", Text, "Str", Title, "UInt", Flags)
}