;
; File encoding:  UTF-8
; Author: fincs
;
; Get the current SciTE instance
;

GetSciTEInstance()
{
	olderr := ComObjError()
	ComObjError(false)
	scite := ComObjActive("{D7334085-22FB-416E-B398-B5038A5A0784}")
	ComObjError(olderr)
	return IsObject(scite) ? scite : ""
}
