;
; File encoding:  UTF-8
; Author: fincs
;
; ComRemote: expose a COM object in order to receive remote (RPC) calls
;

ComRemote(disp, clsid)
{
	static ACTIVEOBJECT_WEAK := 1
	static _base := { Close: Func("_CR_Disconnect"), __Delete: Func("_CR_Disconnect") }
	if DllCall("oleaut32\RegisterActiveObject"
	  , "ptr", pdisp := ComObjValue(disp)
	  , "ptr", Str2GUID(clsid_bin, clsid)
	  , "uint", ACTIVEOBJECT_WEAK
	  , "uint*", dwRegister) < 0
		return

	if DllCall("ole32\CoLockObjectExternal", "ptr", pdisp, "int", 1, "int", 1) < 0
	{
		DllCall("oleaut32\RevokeActiveObject", "uint", dwRegister, "ptr", 0)
		return
	}
	
	return { disp: disp, dwRegister: dwRegister, base: _base }
}

_CR_Disconnect(this)
{
	if this.closed
		return
	DllCall("ole32\CoLockObjectExternal", "ptr", pdisp := ComObjValue(this.disp), "int", 0, "int", 1)
	DllCall("oleaut32\RevokeActiveObject", "uint", this.dwRegister, "ptr", 0)
	DllCall("ole32\CoDisconnectObject", "ptr", pdisp, "uint", 0)
	this.closed := true
}
