MsiMessageBox(Text, Title := "", Options := 0, Owner := 0) {
    Ret := DllCall("msi.dll\MsiMessageBox"
        , "Ptr" , Owner
        , "Str" , Text
        , "str" , Title
        , "UInt", Options
        , "UInt", 0)
    Return {1: "OK", 2: "Cancel", 3: "Cancel", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again"}[Ret]
}