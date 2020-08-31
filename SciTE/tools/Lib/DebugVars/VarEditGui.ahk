
/*
    VarEditGui
    
    Public interface:
        ed := new VarEditGui({Name, Value, Type, ReadOnly})
        ed.SetVar({Name, Value, Type, ReadOnly)
        ed.Show()
        ed.Cancel()
        ed.Hide()
        ed.OnSave := Func(ed, value, type)
        ed.OnDirty := Func(ed)
        ed.OnCancel := Func(ed)
*/
class VarEditGui {
    __New(aVar:="") {
        editOpt := ""
        if aVar && (aVar.type = "integer" || aVar.type = "float")
            editOpt := "r1 Multi" ; Default to one line.
        this.CreateGui(editOpt)
        if aVar
            this.SetVar(aVar)
    }
    
    SetVar(aVar) {
        this.Dirty := false
        this.Var := aVar
        GuiControl Disable, % this.hSaveBtn
        
        type := aVar.type
        value := aVar.value
        readonly := aVar.readonly
        
        if readonly
            types := "|" type
        else {
            ; 'undefined' can't be set by the user, but may be the initial type
            types := (type = "undefined" ? "|undefined" : "") "|string"
            if VarEditGui_isInt64(value)
                types .= "|integer" (InStr(value,"0x") ? "" : "|float")
            else if VarEditGui_isFloat(value)
                types .= "|float"
        }
        GuiControl,, % this.hType, % types
        GuiControl Choose, % this.hType, % type
        this.preferredType := type
        
        GuiControl % (readonly ? "+" : "-") "ReadOnly", % this.hEdit
        
        OnMessage(0x111, Func("VarEditGui_Suppress"), 1)
        GuiControl,, % this.hEdit, % value
        Sleep -1
        OnMessage(0x111, Func("VarEditGui_Suppress"), 0)
        
        GuiControl,, % InStr(value,"`r`n") ? this.hCRLF : this.hLF, 1
        this.DisEnableEOLControls(value, readonly)
        this.CheckWantReturn(type)
        
        this.UpdateTitle()
    }
    
    CreateGui(editOpt:="") {
        Gui New, hwndhGui LabelVarEditGui_On +Resize
        
        Gui Add, Edit, hwndhEdit gVarEditGui_OnChangeValue w300 r10 %editOpt%
        
        GuiControlGet c, Pos, % hEdit
        this.marginX := cX, this.marginY := cY
        
        Gui Add, DDL, w70 hwndhType gVarEditGui_OnChangeType, undefined||
        
        GuiControlGet c, Pos, % hType
        this.footerH := cH
        
        Gui Add, Radio, x+m h%cH% hwndhLF gVarEditGui_OnChangeEOL, LF
        Gui Add, Radio, x+0 h%cH% hwndhCRLF gVarEditGui_OnChangeEOL, CR+LF
        
        Gui Add, Button, x+m Disabled hwndhSaveBtn gVarEditGui_OnClickSave, &Save
        
        GuiControlGet c, Pos, % hSaveBtn
        cX += cW + this.marginX
        Gui +MinSize%cX%x
        
        this.hGui := hGui
        this.hEdit := hEdit
        this.hType := hType
        this.hLF := hLF
        this.hCRLF := hCRLF
        this.hSaveBtn := hSaveBtn
    }
    
    Show(options:="") {
        VarEditGui.Instances[this.hGui] := this
        Gui % this.hGui ":Show", % options
    }
    
    Cancel() {
        if this.Dirty
            this.CancelEdit()
        else
            this.Hide()
    }
    
    Hide() {
        Gui % this.hGui ":Hide"
        VarEditGui.RevokeHwnd(this.hGui)
    }
    
    RevokeHwnd(hwnd) {
        this.Instances.Delete(hwnd)
    }
    
    __Delete() {
        Gui % this.hGui ":Destroy"
    }
    
    GuiSize(w, h) {
        cW := w - this.marginX*2
        cH := h - this.marginY*3 - this.footerH
        GuiControl Move, % this.hEdit, w%cW% h%cH%
        y := cH + this.marginY*2
        GuiControl Move, % this.hType, y%y%
        Loop 4
            GuiControl Move, Button%A_Index%, y%y%
        GuiControlGet c, Pos, % this.hSaveBtn
        cX := w - this.marginX - cW
        GuiControl Move, % this.hSaveBtn, x%cX% y%y%
    }
    
    UpdateTitle() {
        ; Avoiding Gui Show so GuiSize won't be called before Gui is shown,
        ; and WinSetTitle in case of DetectHiddenWindows Off.
        DllCall("SetWindowText", "ptr", this.hGui, "str"
            , "Inspector - " this.Var.name (this.Dirty ? " (modified)" : ""))
    }
    
    BeginEdit() {
        if !this.OnDirty() {
            this.Dirty := true
            GuiControl Enable, % this.hSaveBtn
            this.UpdateTitle()
        }
    }
    
    CancelEdit() {
        if !this.OnCancel()
            this.SetVar(this.Var)
    }
    
    SaveEdit() {
        GuiControlGet value,, % this.hEdit
        GuiControlGet type,, % this.hType
        GuiControlGet crlf,, % this.hCRLF
        if crlf
            value := StrReplace(value, "`n", "`r`n")
        if !this.OnSave(value, type)
            this.SetVar(this.Var)
    }
    
    ChangeEOL() {
        if !this.Dirty
            this.BeginEdit()
    }
    
    ChangeType() {
        GuiControlGet type,, % this.hType
        this.preferredType := type
        GuiControlGet value,, % this.hEdit
        this.CheckWantReturn(type)
        if !this.Dirty
            this.BeginEdit()
    }
    
    ChangeValue() {
        GuiControlGet value,, % this.hEdit
        if (value = "" || !VarEditGui_isFloat(value) && !VarEditGui_isInt64(value)) {
            ; Only 'string' is valid for this value
            GuiControl,, % this.hType, |string||
        }
        else {
            types := "|string"
            if InStr(value, "0x")
                types .= "|integer||"
            else if InStr(value, ".")
                types .= "|float||"
            else
                types .= "|integer||float"
            GuiControl,, % this.hType, %types%
            GuiControl Choose, % this.hType, % this.preferredType
        }
        this.DisEnableEOLControls(value, false)
        GuiControlGet type,, % this.hType
        this.CheckWantReturn(type)
        if !this.Dirty
            this.BeginEdit()
    }
    
    DisEnableEOLControls(value, readonly) {
        disen := (!readonly && InStr(value,"`n")) ? "Enable" : "Disable"
        GuiControl % disen, % this.hLF
        GuiControl % disen, % this.hCRLF
    }
    
    CheckWantReturn(type) {
        ; For convenience, make Enter activate the Save button if user
        ; is unlikely to want to insert a newline (i.e. type is numeric).
        WantReturn := !(type = "integer" || type = "float")
        GuiControl % (WantReturn ? "+" : "-") "WantReturn", % this.hEdit
        GuiControl % (Wantreturn ? "-" : "+") "Default", % this.hSaveBtn
    }
}

VarEditGui_OnChangeValue() {
    VarEditGui.Instances[WinExist()].ChangeValue()
}
VarEditGui_OnChangeType() {
    VarEditGui.Instances[WinExist()].ChangeType()
}
VarEditGui_OnChangeEOL() {
    VarEditGui.Instances[WinExist()].ChangeEOL()
}
VarEditGui_OnClickSave() {
    VarEditGui.Instances[WinExist()].SaveEdit()
}

VarEditGui_isInt64(s) {
    ; Unlike (s+0 != ""), this detects overflow and rules out floating-point.
    NumPut(0, DllCall("msvcrt\_errno", "ptr"), "int")
	if A_IsUnicode
		DllCall("msvcrt\_wcstoi64", "ptr", &s, "ptr*", endp:=0, "int", 0)
	else
		DllCall("msvcrt\_strtoi64", "ptr", &s, "ptr*", endp:=0, "int", 0)
	return DllCall("msvcrt\_errno", "int*") != 34 ; ERANGE
		&& StrGet(endp) = "" && s != ""
}

VarEditGui_isFloat(s) {
    if s is float
        return s
    return false
}

VarEditGui_OnClose(hwnd) {
    VarEditGui.RevokeHwnd(hwnd)
}

VarEditGui_OnEscape(hwnd) {
    VarEditGui.Instances[hwnd].Cancel()
}

VarEditGui_OnSize(hwnd, e, w, h) {
    VarEditGui.Instances[hwnd].GuiSize(w, h)
}

VarEditGui_Suppress() {
    return 0
}