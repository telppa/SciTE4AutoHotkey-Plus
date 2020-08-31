
class TreeListView extends TreeListView._Base
{
    static ICON_SIZE := 16
    
    static FromHwnd  ; Hwnd:Object map of controls/instances
    
    ; MinEditColumn := 0 ; Disabled
    ; MaxEditColumn := 0
    
    InitClass() {
        if this.FromHwnd
            return
        this.FromHwnd := {}
        
        il := DllCall("comctl32.dll\ImageList_Create"
            , "int", this.ICON_SIZE, "int", this.ICON_SIZE
            , "uint", 0x21, "int", 2, "int", 5, "ptr")
        IL_Add(il, A_LineFile "\..\empty.png")
        IL_Add(il, A_LineFile "\..\plus.png")
        IL_Add(il, A_LineFile "\..\minus.png")
        this.ImageList := il
        
        OnMessage(0x2, this.OnWmDestroy.Bind(this))
        OnMessage(0x100, this.OnWmKeyDown.Bind(this))
        OnMessage(0x111, this.OnWmCommand.Bind(this))
        OnMessage(0x201, lbd := this.OnWmLButtonDown.Bind(this))
        OnMessage(0x203, lbd) ; DBLCLK
        OnMessage(0x4E, this.OnWmNotify.Bind(this))
    }
    
    __New(RootNode, Options:="", Headers:=" | ", GuiName:="") {
        TreeListView.InitClass()
        
        this.root := RootNode
        RootNode.expanded := true
        
        restore_gui_on_return := new this.GuiScope()
        
        if (GuiName != "")
            Gui %GuiName%: Default
        Gui +hwndhGui
        ; The requirements for the old ListView content to NOT appear momentarily
        ; when we hide the Edit control seem to be: 1) Edit is created first; and
        ; 2) ListView has WS_CLIPSIBLINGS (+0x4000000).
        Gui Add, Edit, % "hwndhEdit Hidden "
            . (DllCall("GetWindow", "ptr", hGui, "uint", 5, "ptr")
                ? "xp yp wp yp" : "xm y0 w0 h0") ; Preserve point of origin for LV
        Gui Add, ListView, NoSortHdr +0x4000000 %Options% hwndhLV, %Headers%
        this.hGui := hGui
        this.hLV := hLV
        this.hEdit := hEdit
        
        static LVM_GETHEADER := 0x101F
        SendMessage % LVM_GETHEADER,,,, % "ahk_id " this.hLV
        this.hLVH := ErrorLevel
        
        this.CtrlName[hLV] := "LV"
        this.CtrlName[hEdit] := "Edit"
        
        this.RegisterHwnd()
        
        ; Copy the ImageList, otherwise it gets destroyed the first time a ListView
        ; is destroyed.  LVS_SHAREIMAGELIST would let controls share the ImageList,
        ; but it's still destroyed when the last ListView is destroyed.
        LV_SetImageList(DllCall("comctl32.dll\ImageList_Duplicate", "ptr", this.ImageList, "ptr"))
        
        this.Populate()
    }
    
    ;{ Life Cycle
    
    RegisterHwnd() {
        TreeListView.FromHwnd[this.hLV] := this
        TreeListView.FromHwnd[this.hEdit] := this
        TreeListView.FromHwnd[this.hLVH] := this
    }
    
    UnregisterHwnd() {
        TreeListView.FromHwnd.Delete(this.hLV)
        TreeListView.FromHwnd.Delete(this.hEdit)
        TreeListView.FromHwnd.Delete(this.hLVH)
    }
    
    OnDestroy() {
        this.UnregisterHwnd()
    }
    
    ;}
    
    Populate() {
        r := 1
        for i, node in this.root.children {
            node.level := 0
            r := this.InsertRow(r, node)
        }
        this.AfterPopulate()
    }
    
    AfterPopulate() {
        LV_ModifyCol()
    }
    
    Reset() {
        restore_gui_on_return := this.LV_BeginScope()
        LV_Delete()
        this.Populate()
    }
    
    ;{ Row Management
    
    InsertRow(r, node) {
        opt := node.expandable ? "Icon" (node.expanded ? 3 : 2) : ""
        LV_Insert(r, opt, node.values*)
        this.LV_SetItemParam(r, &node)
        if node.level
            this.LV_SetItemIndent(r, node.level)
        ++r
        if node.expanded
            r := this.InsertChildren(r, node)
        return r ; The row after the inserted items.
    }
    RemoveRow(r) {
        node := this.NodeFromRow(r)
        LV_Delete(r)
        if node.expanded
            this.RemoveChildren(r, node)
        return node
    }
    InsertChildren(r, node) {
        level := node.level + 1
        for _, child in node.children {
            child.level := level
            r := this.InsertRow(r, child)
        }
        return r
    }
    RemoveChildren(r, node) {
        Loop % node.children.Length()
            this.RemoveRow(r)
    }
    
    ExpandContract(r) {
        node := this.NodeFromRow(r)
        if !node.expandable
            return
        GuiControl -Redraw, % this.hLV
        if node.expanded := !node.expanded
            this.InsertChildren(r+1, node)
        else
            this.RemoveChildren(r+1, node)
        LV_Modify(0, "-Select")
        LV_Modify(r, "Select Focus Icon" (2+node.expanded))
        GuiControl +Redraw, % this.hLV
    }

    NodeFromRow(r) {
        if data := this.LV_GetItemParam(r)
            return Object(data)
        throw Exception("Bad row", -1, r)
    }
    RowFromNode(obj) {
        return this.LV_FindItemParam(&obj)
    }
    
    ;}
    
    ;{ Tree Management
    
    InsertChild(parent, i, child) {
        if !IsObject(child)
            throw Exception("Invalid child", -1, child)
        if (node := parent.children[i]) {
            ; Insert before this node
            r := this.RowFromNode(node)
        }
        else if parent.expanded {
            ; Find the last visible descendent (parent if none)
            node := parent
            while (n := node.children.Length()) && node.expanded
                node := node.children[n]
            ; Insert after this node (if RowFromNode returns 0, it's likely the root)
            r := this.RowFromNode(node) + 1
        }
        parent.children.InsertAt(i, child)
        child.level := (parent == this.root) ? 0 : parent.level + 1
        if r {
            restore_gui_on_return := this.LV_BeginScope()
            this.InsertRow(r, child)
        }
    }
    RemoveChild(parent, i) {
        if !(child := parent.children.RemoveAt(i))
            throw Exception("No child at index " i, -1)
        if (r := this.RowFromNode(child)) {
            restore_gui_on_return := this.LV_BeginScope()
            this.RemoveRow(r)
        }
    }
    
    ;}
    
    ;{ Editing
    
    CanEdit(row, column:="") {
        ; Note: row parameter is intended for derived implementations.
        return column = "" ; Default edit column
            ? (this.MinEditColumn > 0)
            : (column
            && column >= this.MinEditColumn
            && column <= this.MaxEditColumn)
    }
    BeginEdit(r, column:="") {
        if this.EditRow
            this.SaveEdit("NewEdit")
        if (column = "")
            column := this.MinEditColumn
        if !this.CanEdit(r, column)
            return false
        node := this.NodeFromRow(r)
        static LVIR_LABEL := 2
        static LVM_GETSUBITEMRECT := 0x1038
        VarSetCapacity(rect, 16, 0)
        NumPut(LVIR_LABEL, rect, 0, "int")
        NumPut(column-1, rect, 4, "int")
        SendMessage % LVM_GETSUBITEMRECT, % r-1, % &rect,, % "ahk_id " this.hLV
        if !ErrorLevel
            return false
        this.EditRow := r
        this.EditColumn := column
        ; Scroll whole field into view if needed
        rL := NumGet(rect, 0, "int"), rR := NumGet(rect, 8, "int")
        VarSetCapacity(client_rect, 16, 0)
        DllCall("GetClientRect", "ptr", this.hLV, "ptr", &client_rect)
        client_width := NumGet(client_rect, 8, "int")
        if (rR > client_width) {
            delta := rR - client_width
            if (delta > rL)
                delta := rL
            static LVM_SCROLL := 0x1014
            SendMessage % LVM_SCROLL, % delta, 0,, % "ahk_id " this.hLV
            NumPut(rL - delta, rect, 0, "int")
            NumPut(rR - delta, rect, 8, "int")
            Sleep 100
        }
        ; Convert coordinates
        DllCall("MapWindowPoints", "ptr", this.hLV, "ptr", this.hGui, "ptr", &rect, "uint", 2)
        rL := NumGet(rect, 0, "int"), rT := NumGet(rect, 4, "int")
        rR := NumGet(rect, 8, "int"), rB := NumGet(rect, 12, "int")
        rW := rR - rL - 2, rH := rB - rT
        if column > 1 ; Hack-tweak
            rL += 3, rR += 3
        ; Limit width to visible area when value column is very wide
        if (rW > client_width)
            rW := client_width
        ; Move the edit control into position and show it
        this.EditText := "" node.values[column]
        GuiControl,, % this.hEdit, % this.EditText
        GuiControl Move, % this.hEdit, x%rL% y%rT% w%rW% h%rH%
        GuiControl Show, % this.hEdit
        GuiControl Focus, % this.hEdit
        static EM_SETSEL := 0xB1
        SendMessage % EM_SETSEL, 0, -1,, % "ahk_id " this.hEdit
        return true
    }
    CancelEdit() {
        this.EditRow := ""
        this.EditColumn := ""
        GuiControl Hide, % this.hEdit
    }
    SaveEdit(reason:="") {
        restore_gui_on_return := this.LV_BeginScope()
        if !(r := this.EditRow)
            throw Exception("Not editing", -1)
        GuiControlGet value,, % this.hEdit
        node := this.NodeFromRow(r)
        if this.EditText == "" value  ; Avoid erasing objects.
            return this.CancelEdit()
        c := this.EditColumn
        GuiControl -Redraw, % this.hLV
        this.EditRow := ""
        this.EditColumn := ""
        GuiControl Hide, % this.hEdit
        this.SetNodeValue(node, c, value)
        GuiControl +Redraw, % this.hLV
    }
    IsEditing() {
        return DllCall("IsWindowVisible", "ptr", this.hEdit)
    }
    
    SetNodeValue(node, column, value) {
        value := node.values[column] := value
        if r := this.RowFromNode(node)
            LV_Modify(r, "Col" column, value)
    }
    
    RefreshValues(node) {
        if r := this.RowFromNode(node) {
            restore_gui_on_return := this.LV_BeginScope()
            opt := "Icon" (node.expandable ? (node.expanded ? 3 : 2) : 1)
            LV_Modify(r, opt, node.values*)
        }
    }
    
    ;}
    
    ;{ Keyboard Handling
    
    OnKeyDown(ctrl, key) {
        restore_gui_on_return := this.LV_BeginScope()
        if (ctrl = "LV") {
            if !(r := LV_GetNext(0, "F")) {
                if (key = "Tab") {
                    this.LV_Focus(1)
                    return true
                }
                return
            }
            node := this.NodeFromRow(r)
        }
        if IsFunc(this[ctrl "_Key_" key])
            return this[ctrl "_Key_" key](r, node)
    }
    
    Edit_Key_Enter() {
        this.SaveEdit()
        return true
    }
    
    Edit_Key_Tab() {
        delta := GetKeyState("Shift") ? -1 : 1
        return this.EditNextColumn(delta,, this.EditColumn)
            || this.EditNextRow(delta)
            || this.TabNextControl(delta)
    }
    
    Edit_Key_Up() {
        return this.EditNextRow(-1,, this.EditColumn)
    }
    
    Edit_Key_Down() {
        return this.EditNextRow(+1,, this.EditColumn)
    }
    
    Edit_Key_Escape() {
        this.CancelEdit()
        return true
    }
    
    LV_Key_Tab(r, node) {
        return this.Edit_Key_Tab()
    }
    
    LV_Key_Enter(r, node) {
        if !node.expandable && this.CanEdit(r, , node) {
            this.BeginEdit(r)
            return true
        }
        if node.expandable && !node.expanded
            this.ExpandContract(r)
        else if (r = LV_GetCount())
            return ; Allow default handling
        this.LV_Focus(r+1)
        return true
    }
    
    LV_Key_Left(r, node) {
        if node.expanded {
            this.ExpandContract(r)
            return true
        }
        loop
            r -= 1
        until r < 1 || this.NodeFromRow(r).level < node.level
        if r
            this.LV_Focus(r)
        return true
    }
    
    LV_Key_Right(r, node) {
        if node.expandable
            if node.expanded
                this.LV_Focus(r+1)
            else
                this.ExpandContract(r)
        return true
    }
    
    ;}
    
    ;{ Navigation
    
    EditNextColumn(delta:=1, r:="", c:="") {
        ; r and c specify the origin.
        ; If r is omitted, edit the cell after/before EditRow:EditColumn.
        ; Else if c is omitted, edit the first/last column of r.
        if (r == "")
            r := this.EditRow, (c != "") || (c := this.EditColumn)
        (r != "") || (r := LV_GetNext(,"F"))
        (c != "") || (c := delta>0 ? this.MinEditColumn-1 : this.MaxEditColumn+1)
        loop {
            c += delta
            if (c > this.MaxEditColumn || c < this.MinEditColumn)
                return
        }
        until this.CanEdit(r, c) ; Allow derived implementations to restrict editing further.
        this.LV_Focus(r)
        this.BeginEdit(r, c)
        return true
    }
    
    EditNextRow(delta:=1, r:="", c:="") {
        (r != "") || (r := this.EditRow) || (r := LV_GetNext(,"F"))
        loop {
            r += delta
            if (r > LV_GetCount() || r < 1)
                return
        }
        until c="" ? this.EditNextColumn(delta, r) : this.BeginEdit(r, c)
        (c != "") && this.LV_Focus(r)
        return true
    }
    
    TabNextControl(delta:=1) {
        if ((current := DllCall("GetFocus", "ptr")) == 0 || delta>0 && current == this.hEdit)
            current := this.hLV  ; Tab to the next control after LV.
        if hwnd := DllCall("GetNextDlgTabItem", "ptr", this.hGui, "ptr", current, "int", delta<0, "ptr")
            return DllCall("SetFocus", "ptr", hwnd)
    }
    
    ;}
    
    ;{ General Control Functionality
    
    EnableRedraw(enable) {
        GuiControl % (enable ? "+" : "-") "Redraw", % this.hLV
    }
    
    ScrollPos {
        get {
            return DllCall("GetScrollPos", "ptr", this.hLV, "int", 1)
        }
        set {
            static LVM_GETITEMPOSITION := 0x1010, LVM_SCROLL := 0x1014
            VarSetCapacity(pt, 8, 0)
            SendMessage % LVM_GETITEMPOSITION, % this.ScrollPos, % &pt,, % "ahk_id " this.hLV
            oldPixelY := NumGet(pt, 4, "int")
            SendMessage % LVM_GETITEMPOSITION, % value, % &pt,, % "ahk_id " this.hLV
            newPixelY := NumGet(pt, 4, "int")
            if (ErrorLevel = 1)
                SendMessage % LVM_SCROLL, 0, % newPixelY - oldPixelY,, % "ahk_id " this.hLV
            return value
        }
    }
    
    FocusedNode {
        get {
            restore_gui_on_return := this.LV_BeginScope()
            return (r := LV_GetNext(,"F")) ? this.NodeFromRow(r) : ""
        }
        set {
            restore_gui_on_return := this.LV_BeginScope()
            if !(r := this.RowFromNode(value))
                return ""
            this.LV_Focus(r)
            return value
        }
    }
    
    ;}
    
    ;{ Static Message Handlers
    
    OnWmDestroy(w, l, m, hwnd) {
        for h, tlv in TreeListView.FromHwnd.Clone()
            if (tlv.hGui == hwnd && tlv.hLV == h)
                tlv.OnDestroy()
    }
    
    OnWmLButtonDown(wParam, lParam, msg, hwnd) {
        if !(this := TreeListView.FromHwnd[hwnd])
         || (hwnd != this.hLV)
            return
        static LVM_SUBITEMHITTEST := 0x1039
        static LVHT_ONITEMICON := 2
        static LVHT_ONITEMLABEL := 4
        VarSetCapacity(hti, 24, 0)
        NumPut(lParam & 0xFFFF, hti, 0, "short")
        NumPut(lParam >> 16, hti, 4, "short")
        SendMessage % LVM_SUBITEMHITTEST, 0, % &hti,, % "ahk_id " this.hLV
        where := NumGet(hti, 8, "int")
        r := NumGet(hti, 12, "int") + 1
        if (!r)
            return
        restore_gui_on_return := this.LV_BeginScope()
        if (where = LVHT_ONITEMICON) {
            GuiControl Focus, % this.hLV
            this.ExpandContract(r)
            return true
        }
        if (where = LVHT_ONITEMLABEL && msg = 0x203 && this.OnDoubleClick) {
            if node := this.NodeFromRow(r)
                this.OnDoubleClick(node)
            return true
        }
        if (where = LVHT_ONITEMLABEL && LV_GetNext(r-1) == r) { ; Was already selected.
            c := NumGet(hti, 16, "int") + 1
            this.BeginEdit(r, c)
            return true
        }
    }
    
    OnWmNotify(wParam, lParam) {
        Critical 1000
        hwndFrom := NumGet(lParam+0, "ptr")
        if !(this := TreeListView.FromHwnd[hwndFrom])
            return
        code := NumGet(lParam + A_PtrSize*2, "int")
        if (code = -180 || code = -181) { ; LVN_BEGINSCROLL || LVN_ENDSCROLL
            if this.IsEditing()
                this.SaveEdit("Scroll")
            return
        }
        if (code = -306 || code = -326) && this.BeforeHeaderResize { ; HDN_BEGINTRACK A|W
            column := NumGet(lParam + A_PtrSize*3, "int") + 1
            return this.BeforeHeaderResize(column)
        }
        if (code = -307 || code = -327) && this.AfterHeaderResize { ; HDN_ENDTRACK A|W
            column := NumGet(lParam + A_PtrSize*3, "int") + 1
            return this.AfterHeaderResize(column)
        }
    }
    
    OnWmKeyDown(wParam, lParam, msg, hwnd) {
        if !(this := TreeListView.FromHwnd[hwnd])
        || !(ctrl := this.CtrlName[hwnd])
            return
        keyname := GetKeyName(Format("vk{:x}sc{:x}", wParam, (lParam >> 16) & 0x1FF))
        return this.OnKeyDown(ctrl, keyname)
    }
    
    OnWmCommand(wParam, lParam) {
        if !(this := TreeListView.FromHwnd[lParam])
            return
        static EN_KILLFOCUS := 0x200
        if ((wParam >> 16) = EN_KILLFOCUS) {
            if this.IsEditing()
                this.SaveEdit("Focus")
            ;else: focus was killed as a result of cancelling.
        }
    }
    
    ;}
    
    ;{ ListView Utility
    
    LV_Focus(row) {
        ; Caller must ensure the Gui and ListView are set as default
        LV_Modify(0, "-Select")
        LV_Modify(row, "Focus Select")
    }
    
    ; Based on LV_EX - http://ahkscript.org/boards/viewtopic.php?f=6&t=1256
    LV_GetColumnWidth(column) {
        static LVM_GETCOLUMNWIDTH := 0x101D
        SendMessage % LVM_GETCOLUMNWIDTH, % column-1, 0,, % "ahk_id " this.hLV
        return ErrorLevel
    }
    LV_SetItemIndent(row, numIcons) {
        ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
        static OffIndent := 24 + (A_PtrSize * 3)
        this.LV_LVITEM(LVITEM, 0x00000010, row) ; LVIF_INDENT
        NumPut(numIcons, LVITEM, OffIndent, "Int")
        SendMessage, 0x1006, 0, % &LVITEM, , % "ahk_id " this.hLV
        return ErrorLevel
    }
    LV_GetItemParam(row) {
        ; LVM_GETITEM -> http://msdn.microsoft.com/en-us/library/bb774953(v=vs.85).aspx
        static LVM_GETITEM := A_IsUnicode ? 0x104B : 0x1005 ; LVM_GETITEMW : LVM_GETITEMA
        static OffParam := 24 + (A_PtrSize * 2)
        this.LV_LVITEM(LVITEM, 0x00000004, row) ; LVIF_PARAM
        SendMessage, % LVM_GETITEM, 0, % &LVITEM, , % "ahk_id " this.hLV
        return NumGet(LVITEM, OffParam, "UPtr")
    }
    LV_SetItemParam(row, value) {
        ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
        static OffParam := 24 + (A_PtrSize * 2)
        this.LV_LVITEM(LVITEM, 0x00000004, row) ; LVIF_PARAM
        NumPut(value, LVITEM, OffParam, "UPtr")
        SendMessage, 0x1006, 0, % &LVITEM, , % "ahk_id " this.hLV
        return ErrorLevel
    }
    LV_FindItemParam(param, start := 0) { ; Based on LV_EX_FindString
        ; LVM_FINDITEMA = 0x100D -> http://msdn.microsoft.com/en-us/library/bb774903
        static LVFISize := 40
        VarSetCapacity(LVFI, LVFISize, 0) ; LVFINDINFO
        NumPut(0x1, LVFI, 0, "UInt") ; LVFI_PARAM
        NumPut(param, LVFI, A_PtrSize * 2, "Ptr") ; lParam
        SendMessage, 0x100D, % (start - 1), % &LVFI, , % "ahk_id " this.hLV
        return (ErrorLevel > 0x7FFFFFFF ? 0 : ErrorLevel + 1)
    }
    LV_LVITEM(ByRef LVITEM, mask := 0, row := 1, col := 1) {
        static LVITEMSize := 48 + (A_PtrSize * 3)
        VarSetCapacity(LVITEM, LVITEMSize, 0)
        NumPut(mask, LVITEM, 0, "UInt"), NumPut(row - 1, LVITEM, 4, "Int"), NumPut(col - 1, LVITEM, 8, "Int")
    }
    
    ;}
    
    ;{ General Utility
    
    LV_BeginScope() {
        scope := new this.GuiScope()
        Gui % this.hGui ":Default"
        Gui ListView, % this.hLV
        return scope
    }
    
    class GuiScope {
        __New() {
            this.prev_gui := A_DefaultGui
            this.prev_lv := A_DefaultListView ; Only matters if prev_gui = our gui.
        }
        __Delete() {
            Gui % this.prev_gui ":Default"
            if (this.prev_lv != "")
                Gui ListView, % this.prev_lv
        }
    }
    
    class _Base {
        __call(name:="") {
            throw Exception("Unknown method", -1, name)
        }
        _NewEnum() { ; Allow enumeration for debugging.
            return ObjNewEnum(this)
        }
    }
    
    ;}
}