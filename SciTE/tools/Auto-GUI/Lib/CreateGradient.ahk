; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=91899

CreateGradient(W, H, V, aColors) {
    Local

    C := aColors.Length()

    xOFF := (X := V ? W : 0) ? 0 : Ceil(W / (C - 1))
    yOFF := (Y := V ? 0 : H) ? 0 : Ceil(H / (C - 1))

    VarSetCapacity(VERT, C * 16, 0)
    VarSetCapacity(MESH, C * 8,  0)

    Loop % (C, pVert := &VERT, pMesh := &MESH) {
        X :=   V ? (X == 0 ? W : X := 0) : X
        Y :=  !V ? (Y == 0 ? H : Y := 0) : Y
        Color :=  Format("{:06X}", aColors[A_Index] & 0xFFFFFF)
        Color :=  Format("0x{5:}{6:}00{3:}{4:}00{1:}{2:}00", StrSplit(Color)*)
        pVert :=  NumPut(Color, NumPut(Y, NumPut(X, pVert+0, "Int"), "Int"), "Int64")
        pMesh :=  NumPut(A_Index, NumPut(A_Index - 1, pMesh+0, "Int"), "Int")
        V ? (Y += yOFF) : (X += xOFF)
    }

    hBM := DllCall("Gdi32.dll\CreateBitmap", "Int", 1, "Int", 1, "Int", 0x1, "Int", 32, "Ptr*", 0, "Ptr")
    hBM := DllCall("User32.dll\CopyImage", "Ptr", hBM, "Int", 0x0, "Int", W, "Int", H, "Int", 0x8, "Ptr")
    mDC := DllCall("Gdi32.dll\CreateCompatibleDC", "Ptr", 0, "Ptr")
    DllCall("Gdi32.dll\SaveDC", "Ptr", mDC)
    DllCall("Gdi32.dll\SelectObject", "Ptr", mDC, "Ptr", hBM)
    DllCall("Msimg32.dll\GradientFill", "Ptr", mDC, "Ptr", &VERT, "Int", C, "Ptr", &MESH, "Int", C - 1, "Int", !!V)
    DllCall("Gdi32.dll\RestoreDC", "Ptr", mDC, "Int", -1)
    DllCall("Gdi32.dll\DeleteDC", "Ptr", mDC)

    Return hBM
}
