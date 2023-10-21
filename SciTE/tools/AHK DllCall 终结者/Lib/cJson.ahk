;
; cJson.ahk 0.6.0-git-built
; Copyright (c) 2021 Philip Taylor (known also as GeekDude, G33kDude)
; https://github.com/G33kDude/cJson.ahk
;
; MIT License
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;

class JSON
{
	static version := "0.6.0-git-built"

	BoolsAsInts[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bBoolsAsInts, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bBoolsAsInts, "Int")
			return value
		}
	}

	NullsAsStrings[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bNullsAsStrings, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bNullsAsStrings, "Int")
			return value
		}
	}

	EmptyObjectsAsArrays[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bEmptyObjectsAsArrays, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bEmptyObjectsAsArrays, "Int")
			return value
		}
	}

	EscapeUnicode[]
	{
		get
		{
			this._init()
			return NumGet(this.lib.bEscapeUnicode, "Int")
		}

		set
		{
			this._init()
			NumPut(value, this.lib.bEscapeUnicode, "Int")
			return value
		}
	}

	_init()
	{
		if (this.lib)
			return
		this.lib := this._LoadLib()

		; Populate globals
		NumPut(&this.True, this.lib.objTrue, "UPtr")
		NumPut(&this.False, this.lib.objFalse, "UPtr")
		NumPut(&this.Null, this.lib.objNull, "UPtr")

		this.fnGetObj := Func("Object")
		NumPut(&this.fnGetObj, this.lib.fnGetObj, "UPtr")

		this.fnCastString := Func("Format").Bind("{}")
		NumPut(&this.fnCastString, this.lib.fnCastString, "UPtr")
	}

	_LoadLib32Bit() {
		static CodeBase64 := ""
		. "3bocAQADAAFwATBXVlMAg+wgixV8DAAAAIt0JDCLXCQANIt8JDiLRCQAPIsKOQ4PhIpBAJSF2w+EqgAci0gDunQADLlfAAiJAHQkGMH+H2aJAFAc"
		. "jVAgxwAiAABVAMdABG4AQmsADAhuAG8ADAwIdwBuAAwQXwBPIQAMFGIAagAMGGUAAGMAiRNmiUgAHo1EJBiJfCQACIlcJASJBCQhAFIc6OIZAWeN"
		. "UCACiRO7IgBnZokAGIPEIDHAW14AX8NmkItUJEAgD7bAifkBLvCJAlQAN9ro7w0AAIkGI422Ad+DBxAFXPDHRCQEARIDYIFZgjOieoAzgwcBhhuQ"
		. "AgABBI8AjUwkBIPkCPC6FIAF/3H8VYSJ5YCUUYHsqIGCAEEEizlmiRCJPEWUgHSBFoB0AQOLBwAPtwiNUfdmgyD6Fw+Hy4GU7P8Af/8Po9EPgkMi"
		. "AgAqWAK+AQiNdkAAD7cLidgGFZ4BABUPo9aNWwJzAOaJB2aD+VsPyISkBYAJjh0AG4AHMG4PhBiAB4AEdA8IhbADACVQAmaDAHgCcokXD4XokQDk"
		. "jVAEgAcEdYEHStiCBwaABwZlgQfIQYAHg8AIgD2CbIkgBw+E/gYAK0WUdr8AEsBXOEAxwYJEMeuAAt3YMcDpl0ERhLQmAkN2AIkfwB4Aew+FYP//"
		. "/4MAwAJmD+/AjU1CmEIziQehJMAKDwARRbyLEIlMJFAYjU28wFwgAkZERCQcAh1MJBTAAhB5ghlEJMIZwAEDT8dn/wBSGItdoIsHg3DsJOmPAR7H"
		. "H0FFOggPhfzBdsACiQchgC+JPCSJwA7oUAD+//+FwA+F4AeBYIAFwBWLRbCJHElDB6IKC2Z3IkBaD8yCjgFRwWFIAsATRWIMhmyABcIaLA+FawuB"
		. "CEMgkMIcD7cQjWpKAAr5AAp7AAeADH0ID4REQQKF0g+EAjuDBCJ1Wo1FqEkFJ7P9ASd1R8uGLzOAUYAhcjDFF8whhwwBAwhz54kH6wvdANjrB93Y"
		. "jXQmCACQuMAF/41l8IJZgKxdjWH8w0AjQC10Dw+OGwCKg0TpMIADCXfaQEG+EUGuZokwT6gYZoNA+y0PhBMHoAJFgpAhMtnox0WEwQMhIAMwD4TY"
		. "oEONUwLPABEId4SLdZQAi1YIi04MiVUQiIlNjOgha02MEAqJB7jAKwD3ZQCIAcoPv8uJywDB+x8ByBHag4DA0InDiUWIABEAg9L/iVWMiVgQCIlQ"
		. "DMIPjXPQQGaD/gl2vKANLogPhOCgDYPj34ABSEUPhYKMXZSiLWbAgzsUD4SSYEPgLkuAEWAWcIABMdtgASuAdQuNSAIPt6CEIA+JyI1KIAr5CYgP"
		. "h9cgQYl9iMAHBDHJ5IDqMI0MiQSJxkACD7/SjQwiSmAG/o164AX/CQB24ot9iIk3hRDJD4RNgCEx0rgDgSHjBo0EgIPCAUABwDnKdfTgGNuhQhnd"
		. "QAiEIKGQIBYQ3vHdWKBMlA+3FYAm+OAU5sJz+AUPIIW+/P//IAPcSFYIQAQAaU6AEpDgE2ZYD4U+QAEkd2Ehcy5r4gEid2zhAR7iASJ3c1XhAQ7i"
		. "AQjgAQgief7RgEmDwAooeUlgToAN2rsjeRirPYAP0SAGAUcd4A8iQBOgAcArjXACArrhBIk3iXMIZoCJE4sXD7cKIgQEhMQgLIPABOsfgwQ9oLT+"
		. "icaJ2gAEW8F+YgSvQR2hJm+BC1oCAmKDXHXUD7dKBSQE02JJ+S8PhG4RYAWD6VyAARkPhwI/4AUPt8n/JI3OCCC24llhcYN3ICbhPWA4fQ+FG0Ic"
		. "A3y/7gnjk4BHQBkGoQ2kEuAGkM4Pg2fgBunqgADbZCqin9riAWcqyuIBYio94gG64AGioUIkYCiF1kvAPqAiuKMNA6Fh4YkMQwiAmSGSBDHAg1Ds"
		. "BOmIwAa54dGDEMIEicbCIhfp5qvgM6ehu6uhqKWhqKSfByqiv6GioUWgx0WIY+EEQKKJRYQBaGeQ2MNHpGBiXQ+E7yEBQZEm3EShhJAu+SOkvvsB"
		. "4WOQMfaLTYhmGIl15EJCc0XNzMwAzIPuAffhicgAweoDjTySAf8AKfiDwDBmiUQAdbyJyInRg/iICXfZMAWLfZARVkaNYQGwBYtFhKAK6AY8cB7J"
		. "CXcgD6PL+A+CTQAHcx6gOvFN0wGEdjjhHvosdTcwAb6DAA66VdJRATsRBDawAE0wUOB0DjABc7PCA10QD4Xv+nICi12ERrmxGzIjZokI4yLXs8AB"
		. "UB2hhOAV0y5DYAEp0C7pvZMBvjEDoYDB4AFmiTPpC6AcQAGJggSheEIBC+n2ISdNc0a7QRjBRumOMA3fGGsIuhAPQAIT3VugCIsH6VmBDkqQITCJ"
		. "DzHJ0SHAMASNAllwRvsJdh2NWUK/gAAFD4a+UYBZEp/CAIcwcAiNWakAweMEjUoGiQ8IZolYUQMGZoldYoiUAw+GaAID1ANzJdkD8jAdD7egAkwL"
		. "gKnB4QSNWghwOFaJcR3CBwgmBBopBCNVKQSvLQQKKgQKJgTMK7GAJQQCKQRsKASDwmoMdDHO0BC7kRTEMli1QQG5QAG5cD8aNKSRAqvRGZkCj0EB"
		. "XEwBekEBu8FmSQFlMQXxMzkFUFEuAPAxyYlI/IPCIgIxHwYxwHABxfhjglkccReNQgAeUEwHDOlrwAygRNnoD7cMWAKwcbF2iRfZ4EyJ0PBxwQDp"
		. "2yAE3SLYcCKLdZCQL4tLAAwPr0MID6/OgAHBifD3YwgwJigByrjDWANAB1MMVOlPUQdNIW27ESOJiAffaTBXGd1ZYCNV0XBTMBb6sGu4wAG6QQJo"
		. "FJKD6zDwAgFi0qEg30WIoHcAaInAB9753EEIhgNkdMjQ6b4QBt7JwGYCDDS5L+wQQeEusEDxixBACCnBMksPt02giAHZ6UunAP2iWY2iAK+iACId"
		. "yenlyQBCleEwWcnpSkkBBpMxUPR7hECgCOn/QADw2ejpy2AAQ7V4tQUAADAxMjM0NTY3ADg5QUJDREVGQTEBSB4AACAwAPgAHQAA8R8AAND9cACo"
		. "tAA/AD8APwA/ADEAalgwBamQJMBwGj0AlK18AdN/AjoAvvwBf/QACmpwAFwQMGYAYQB4bABz0tGh0XHRQdFfxABWkgF1AGXyEHLYIlDQ12CNVNDX"
		. "dCSqaIBgOAIqA1DOFFAB1mRwAMHMEGRiDORj42IAHCT/UBSLA4PU7BigAkBgAURiAaADVSDTOPAATPIAdLIBSPukAx1pGJVpMQWdacLWYQYwGA+3"
		. "BuBo0I4JdAJXUAADdBGDxFADstf2uot+DIt2CAUQ2vpBL4CD0gCDUPoAdtgw2TyDuQgVEOZkwmlxoBKFwHQCvCHniTCJeATr6rFw3kb1dwjQd+QF"
		. "1iQwkJBXjZDdANr/dwGz2Yn+U4nTgewCjAETP4t2BIlNKLSLUBDasJDifahAiXWkiE2jgHGFIgzASw+2BfENiEUKrHHtdKCfgH2sAQAZyYPhIIPB"
		. "WwCLM4B9qACNRgACiQNmiQ4PhSYSAAyQA47qkpawMRD/i3AM8AIAdXyB0AA5eBgPjoDQBIWRBOCwBYsLjUGQAwq4k+sBYAyJRdjBAPgfiUXci0W0"
		. "U3LuwXNF2EFz96HJEzFShWaJCnBIwEe5OofxEhAIEfIID4TU0VagUATGRawQAboBGwUQ9wLwEQyD+AEPwoTy0PgGD4TxaeGn5IQiEZz4AqChgQtg"
		. "CUJRgQsDixWQsFdmNrsAD28FeA0AAIkAUBiNUB4PEQAg8w9+BYgAgGYPANZAEIkTul8AAQAsiVAci0W0iQBcJASJRCQIiQA0JOhNCgAAiwgDuSIA"
		. "dIPHAYkAwoPAAokDZokACotNsDl5EA8Ijn0CAKb+weYEAANxDInCjUgCAIB9owCJC4nIAGbHAiwAD4V1QAQAAIB9rAASQwD///+LVbA5egAYD4/R"
		. "/v//OWB6HA+PyABXCHGLAEYIiQQk6DgMBQJ0OgAcjVACiRMEZokAGQyD+AEPBIUJAEWNdCYAkIkFNTQkATjopQkBSAKwAKM7eBAPjToCAwWWcAyF"
		. "2w+EIQGmiwPpWoEetCYBgCsAO1AYD4Q/AAUAAMZFrAC5RnuACIAThfj9AFJFgLSDAAGAfagAWoJuABCF0g+O3oAnAQAvMf+LcAzp/VMAEoQiZpCB"
		. "LlKCLroKdAAIuYGjxwAiAAJPgaYMjVAQx0AABGIAagDHQAgQZQBjAAFmSA7pCt0BIbaBIIsGOwVCgIB3D4QKBoBKBYp4ggU+gAWLFXyABSA50A+E"
		. "2IETMjmwMA+EZgCngThzgQ8EE76BOI1KIMcCACIAVQDHQgRuhABrAAMIbgBvAAOQDHcAbgADEF+ARUjHQhQCIUIYASFmIIlyHIkLgipmiQBKHolF"
		. "2MH4H4iJRdxIYo1F2EBiBOn8xylFtIsAi4BNtIPAAYkBwWk5BQ2JTECKQA1DDOgcAgjACk20iwGJRWaswAqCUYQXgFHCDgJkiQHBW+k2xhVBM4tx"
		. "gQcDvmzBTwEBQHHHCcAudQDBmwhmiXCS/MGcSgYEnY+LB2AikAEYdEq+QLIAiWDBjVAEvwCsQDUwIIt1pInQQVt5AsAxyYX2ficABAGOCInQv4CK"
		. "AIPBAQCDwgJmiTg5zhh17L5BBMEKMIsDBQCrAYCxGdKJC4MA4iCDwl1miRAAjWX0W15fXY0QZ/hfw0GHxwGDxAAPQUnHRCQAZMAOuUDKIwcCSYCO"
		. "AIo5AKEcjqEIoUA/QcaLEY1iQsBPD4XNwAbDxSsu/ICcATbAxZzBxXkcyA+Ov8GbRghADcNZnIMBAFyCWoUc6YzACqCNdgA5eIDRd4OtbYzR8YBi"
		. "gVf+AAwAv5hw+///ZuVmgXkhBQYlAQXIYTZFsCFnjMarwBGDNuKkM3RjZ5njDQq4IS25gyxGAo1G0gZBM04EgWR3IATACBiLVaTiZEACiMz6AUEC"
		. "pIl9nDHSjUBIAYsDic8EN4kQwYPCAQBCZscBQAkAOfp176Ehi6B9nIkDuKExZoEkhhAgFuISGA+MnCAJsjtgHYyT4SVuHQVBGDgD6bSgBONK6RRC"
		. "AhyNQuAUABGgSASFwMgPiWgAgekvgAXhdzyFeKJ7QTcpPeMIjUVAyPIPEA65QFQAFMdF4ZUAQDKhIAEBAQtNyI1NuIsQiMdFzOECx0XcwwAK5MMA"
		. "4GAEAPIPEYRN0AA3GI1N2GA3IiBCA0QkHAIJTCT6FGABEOEE4ACgfeIAQBkD4gBDSwQk/1IYiwBVwIPsJA+3ArJmoBeEE+AiITMJAAdRQCuLE7lA"
		. "NADjFYkI1onHIlsGi0XAQA+3BAiDwYEGdeDnifiJE+ArAgPhpI1CVIXGt0BUA+k6wScD4zPBZVYBiVQkBIAPtlWjiRQkYVFQ2uh9+AAnk8cEkAUB"
		. "P2ohRHAMMcDrgAmQOcIPhBKhCgLBoH/B4QQ5RA7YCHTqgX4hLWkhBearpHUSoAePoEEKfaFLAeS6gwAChdJ/cYEhjn2kixCNSsA3AAONVDoDhf9+"
		. "QgniCjnQdfdhQAgZYwnpRSJPAJSNDAAMKcriCKAEZoM8QuAAdfaLdSF2wh5hHryPaQBIpBfgWeIQlGK6ZwW84ESgLIgQ4BKBCk1ipOAKVAgB4yuj"
		. "D/khoSEB6e335yVFpACDwgOJEYXAeXjK6dXgAkAHZjjnVF2/QZ0iFeQnQ6rhI+AJH0AOoQQDhdt0d2DgdUABbL5lY6IgxwQghYKix0BA+HQAcgCB"
		. "b3JqBoKidsEo7uZf4UO43eESA0AGJQhBf3BRgCAEqgqRf/YCBAgCBDUBBFatAjsjTgQVEzfwJuma0zEWdfVIABVF3CBfYIMGEIl0iFAgDhqRMh6w"
		. "gwYiJo/6EAVs6ZbAAzAOAVEJMWW5ElshTIr2IAUD6YmDEAJhGInQD4Uz0QKqeEgIBYVJspEBTnQEm/IDASVHIQQHe4Q1wB2Z8CPpv0EGUX3pJRMC"
		. "IIsA6XD58D5VVwBWU4PsRItEJMBYi1QkXIvAj9AZGfAeji/QNGEBMf+JQNWJ+otAGIABBMlyAkAMcA3rJfMpAAF0OVAgWsvBFaADYUwEVCQQcS/t"
		. "IAE5EDN+ANqLBCQxycZEBCQPQEJMJEKLSCAIhcl5BwEBAfci2UA1ELsUgR3NzATMzPVQyInfg+sAAffmweoDjQQAkgHAKcGNQTAAidFmiURcGoVg"
		. "0nXfgHzQBCALEJB0ErgtsStf/rIBgcMAXFwaZjlF4GQOaQSSAG7QP0tmO0RaTVABU1ABUUDpEAtgAIs8JIk4g8RENrhxR+FOw3AwEAsPtwJdYDwI"
		. "D7cOZjkQyw+FHzADMcBmoIXJdStm0CjFyw7MhRPgAUAEMcATBPWQMaACD4TkYBpQLQ+3AAxGD7dcRQBmwDnZdLbpzlAB8hcgMduB7JzhE4QkIrAC"
		. "WpwkjuEArCQitGEAUASL4EOJ0wSBwdAAgIPTAIMg+wAPhwvBTse+hXETuXEThcB4a3ALAIn4g+4B9+GJAvhxExySidcB2yAp2IPAMLARdGYJcRON"
		. "VHAA7Q+EkpmhBU0AsFFyHInLkAAEicbRUYkDD7dCIv7hEeqJTdAIM4FWxNEJmw25Ahswdla4EGdmZmZABOkB9wLvwAf4H8H6AikCwpAbjQRGKfiJ"
		. "CtfwB0zxB9eD6wKDIhrBGmaNVFxm0gDJEAmFbhGxhCRROrAIEyBBckvCAqJLev4AkHXzi7TSAYkGGwkB8gtEJEiNRCRAW3IJwABUImlwOEDSJFQQ"
		. "JEyLELEnQI1MRCQw8mdMJFTgAUTVxGVYdABgdABcRGgPagsPag9qGNBpi1wkOCgPtwMSarqgHoXtYHQ/i1UAs2n2Vol200AX8WkD8CTwAgZq5jyJ"
		. "VQAO1heSDtQRixBuuEIEcQ8wJQOUg5Ap8aEUAokQ6UfRJZD0PQoEgDIcAAYYi2wkkiBAZoSNQUkKvnHMAI1ZAokaZokxCA+3CCAEdHQPtkIdAQ2I"
		. "XCQB8AlmQIP5Ig+PPuF9gyD5Bw+OdJAAjVkA+GaD+xoPh6gBUAQPt9v/JJ2cF7AQ8gjBBUCRQwq/XAHCBQRmiTmJGrsBkQZmiVkCD7dIKwAdwgqk"
		. "sQIsgQgajSBDAokCuDMCA4MsxAR3HTEC8DEPCr4p8QS/ckUFMUELeQK86670XXAC0tN8B2Z0B1TrhncCoHICu3ECvhpu8gEZ8ALxBHEC6cpbAUN2"
		. "cAJ0fL0E4cVZsQTpN3fTcAJUtQliGbwJ6Q93AtATXA+FdneQERADItUHQQDaB93pdX+DRVBbz9EA8wPgTuoB8FylJAwFIhZDBDFxA0kEgByJy4nO"
		. "g+MAD2bB7ggPtpsCiMAZg+YPD7a2A5EAgB0CictmwekADGbB6wQPt8lxgAIPtrmhAbQCEAIDI0EGwUiJ+4uQcb77/InzUAAxALAB0BBxBqAQcASN"
		. "WQhAB1EB4QAGROkd9QuNWYEwIiEID4ZOoVaD+R8PLIZEkADAD23gHnMCgIkyZokL6e731AJ9kCQIjV8BiV3OAMAhkPKgAYPD4QD6IKaL8ABSAevo"
		. "dxIKdxYx8AAE6ZcH0fAAAekWh/AABBRkoQJZ4GYSsACD+14Ph7L+/4D/6Wn///+QBgA="
		static Code := false
		if ((A_PtrSize * 8) != 32) {
			Throw Exception("_LoadLib32Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 5678, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 8216, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			DecompressedSize := 0
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 8216, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			for k, Offset in [24, 509, 598, 1479, 1671, 1803, 1828, 1892, 2290, 2321, 2342, 3228, 3232, 3236, 3240, 3244, 3248, 3252, 3256, 3260, 3264, 3268, 3272, 3276, 3280, 3284, 3288, 3292, 3296, 3300, 3304, 3308, 3312, 3316, 3320, 3324, 3328, 3332, 3336, 3340, 3344, 3348, 3352, 3356, 3360, 3364, 3368, 3372, 3376, 3380, 3384, 3388, 3392, 3396, 3400, 3404, 3408, 3412, 3416, 3420, 3424, 3428, 3432, 3436, 3847, 4091, 4099, 4116, 4508, 4520, 4532, 5455, 6153, 7138, 7453, 7503, 7916, 7926, 7953, 7960] {
				Old := NumGet(pCode + 0, Offset, "Ptr")
				NumPut(Old + pCode, pCode + 0, Offset, "Ptr")
			}
			OldProtect := 0
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 8216, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEmptyObjectsAsArrays": 4, "bEscapeUnicode": 8, "bNullsAsStrings": 12, "dumps": 16, "fnCastString": 288, "fnGetObj": 292, "loads": 296, "objFalse": 3192, "objNull": 3196, "objTrue": 3200} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib64Bit() {
		static CodeBase64 := ""
		. "NLocAQAbAA34DTxTSIMA7EBIiwXkDAAAAEiLAEiJ00ggOQEPhIUANEiFENIPhJwBEIsCQQS5XwEQiUwkOEgAuiIAVQBuAGsIAEiNARyJEEi6IG4A"
		. "bwB3ABNIiQBQCEi6XwBPAIhiAGoBDRC6dAA3AGaJUBxIjVAgQMdAGGUAYwAXEwBIidpmRIlIHsjo/BkBXwNBAFQACBiNUAIAHAAZEDHAAEiDxEBb"
		. "w4tEACRwRQ+2yYlEgCQg6K8OAAAFGAgPH4ABv0GDABAsMdIDTAFHTAAUYOiKpoAqTAAdYDHAABAaAYMYkAEAHJcAQVUAQVRVV1ZTSIEk7MgBB7sU"
		. "gV9EiQIagYyJzUjHQggBARNIiwEPtxBmQIP6IA+HzYAHSQC4/9n///7//wD/SQ+j0A+CMQICgWZIApAPtxFoSInIAxSgARQAD0gAjUkCc+ZIiUUC"
		. "AIALWw+EzQUAMAAPjhMAGYAHbg8MhDyAB4AEdA+FtgIDA4pmg3gCckjAiVUAD4XXgOAACVIEAAkEdQMJxIMEBimABAZlgwSxgQSDwIAIgD3a/f//"
		. "QFxARQAPhCkHADS6wYAUAEjHQwhBggA2YBMxwOmIwALEU0iEiU3BHnsPhWAAMwGAEAJIjVQkcGYAD+/ARTHJSIsMDcsAOYETRTHASQK8BT0PKUQk"
		. "UEjIjbwkwVdIxwBeBEmgSIlUJDBBEFBBArYoQGoAB0ACBwACOAECBcABIMEi/1AwSIsAdCR4SItFAOlijQAEDx9EwSNCSToYD4XeAQ3BI4naSCSJ"
		. "6cEF6E/AHoXAiA+FwwIblCSYAVgAidhIifHodAsngQRAPUNpdyUAXtQPzIKjQD/CFQ+3gJpAExlCZoZ+wVlDGiwPhXFBAw8fhMKDQxzGEQ8MhosA"
		. "B0ACfQ+EV4FDAiJ1R0iJ+oAkhOjAgFqFwHU4yB2ID4c/w4TUciHPHaSHHgQHc+jBGLhAAxD/SIHEAZ5bXl9AXUFcQV3DAAotIHQPD44zgIeD6oIw"
		. "gAMJd9ZBvIGlB0FxwSigOCNIi1UACEgPv+AK+C0PhAJE4ALyDxAVTgoFID64Ij2D+DAPhAIP4AKNSM9mg/kACHeRSItLCJAYSIPC4BtgB40UiYEA"
		. "aFDQSIlLCIUJAESNSNBmQYP5CAl22OAHLg+EUREgSIPg34ABRQ+FBurCI8MHZoM7FA8UhCQBWbdkEP0EAAWARMmAASt1D0iNoEoCD7dCYAVNAC1G"
		. "yuEKwAoPhwmCTMIgAkUx22biI4PoADBDjQybSYnSQcECmESNHEjgBv4RBAZ24EyADUWF24gPhBNAGUGD+2CVAv+AEvMPfgVxCQAAAESJ2jHA0QDq"
		. "Zg9vyIPAAQBmD3LxAmYP/gLBAAHwATnQdecAZg9+wmYPcNgC5QAB2A+vwkGDAOMBdAWNBIABIsBBXPIPKmAAEEuACEWEyQ+EIgALAPIPXsjyDxFL"
		. "MAgPtwNAGYAcMwYBoikFD4XC/P//QPIPWVMIMYAGEXBTCOlA4FHkaOA0ZlgPhSqBZeR3YSNzF2tDAuJ3bEMCBEMC4ndzrUMC8UBJQAIIQAIIRHoC"
		. "3kECg8AKgD0HyvpGenhgUEG4RXoBD0QxwMBBA+m1oAUPRB9AAlQPhaKgAUypwJFBuGEETIAwTMA8FQEFTGBVQYNVIg+EBjkAOGAMBEyNFYMRgB/r"
		. "HZBAt/5JiXDBSYnIoQQkVyAFL2uhIAHER0ALSUALBIdcXHXNAAUhHqEE2iMhL4gPhOQgC4PqXIABEBkPhxOBE7fSSQBjFJJMAdL/4oQPH+Gi1A+D"
		. "ZiAqweNwOH0PheyhASAOHEG5IDsCHoIbC0iJsHMI6dSAA+YGVoAB4aARdMfpuGEGJC7Eo3alQwIpLpJDAiIuRAJ/M4MNIKbY+MYrgq2LBarngBe6"
		. "ISdmIddD4D3U6VXABblh1knAJQAkIGaJSP5MYAbp1dOBOc+mlPnGpr/hcYakwEG9zczMzEepn6Z3iaYCr5JTRYAK0FN2SgzDMl3RF10PhLaQBdIa"
		. "ZreCFAFU6BIQCcFThgD7//9FMdKJ+US6E7NElCS4QSKNDpTSXPQs8B+JyEkPAK/FSMHoI0SNAAyARQHJRSnIAEGDwDBmRYkEAlLQAYnBSInQSACD"
		. "6gFBg/gJdwjOSJijWEmNFEKs6OWBJehYTONYCrAHmWFyZi71VvdydyQxAoWycuq0WV0PhdiwL4zp58It+WosdeBBF3iDxwF0AcEqQwNgVvdL4A8D"
		. "B+3UGevfMBnwRXAzuKElZokDY08BtP9QwR14QAbwAeDBNXeyJ1MnGAJWEAKTAYABi2wNlvJj+AE2EQQ0T0FmuQIfk0/pASAPYSG+ARARAPJIDypD"
		. "CChmiTPwQ0NiV+m8nZADSdAqMCWBKTHSETghIDVIBI1RMFD6CSB2HY1Rv4AABQ9EhuswYY1Rn8IAhyK+8ByNUamwOAbBDOIEchGUAwZEjVnBcVz7"
		. "CQ+GlSAD4ABWv+EAEASO4wCf4wCHUnoxBFQKQQQITAQIVUgESEsEW0sENUcECrVMBApIBPtQEUgEDUsExvBAOEIEg8AM0QOyNS55sBNSF003YIAB"
		. "QbuiDZgBRIlYowFFoQFWvME7pwFgowEqoAG61lzpBHQGEYABvqBzhwFqcIMB+MAZv5CyhwF4RYMB34ABTInIYDRQAPxFMe1JjUACJWAxKTNL6SjA"
		. "DEwPYK9DCEG7oVpSTBtyTIBE6Q6QAYFuESG/8xEhwnSJO4MhViFAdSZzxv5QAhIljQyJ0HKRA2micgHJoADJ8QNTbCrCybBrwfIPWHsEN314v+kx"
		. "0Qd0YxJEgFMP5LdAEn3pCsEBICyAgBRCAsGECRAaScfAc0KKxCym9xJwUAYABumi2RADQb0vqhZo8xECv+FPi0MIRInKECnC6ddQOEQB2rTpH3QA"
		. "0vA8cQCFcABRQB/J6XyFAP2FAK9hgQBRyekdcAAViIQyfuAH6XpQByKO6TXzkACACgVY0ADCAP++DwADDwAKADAxMjM0NQA2Nzg5QUJDRARFRjEB"
		. "BBAAANwQDwAArDAAlREA9AB8cABUtAA/AD8APwArPwAxAPzgzmDwDuz1tT8ARXwBkn8COgB5/AEqKvQAEXAA9SFJAGFgAGwAcwC13RXdX0QAVpIB"
		. "dQBlWBHw3j90ALJsOeWS04hxbVNPKdFsy0gwZajy3VQkEFRMicZibUyNhGlCATHSwGxURW1xAP8MUCgg4cECYEiJdHdBAOACYHSL0APwc0FwcNWz"
		. "X9mxAGi0A3B1datynYEAMOUFMKmBxg+3oH8Q+Al0SVAAA3QLAzC3IQtbXsOQSIuEdgjhb4BIAfCgbhggdOOBxXEKTI1EJCRYIAfomRBIhcAYdMpI"
		. "AOYAATDrwJFwdkiLTtNfEJDYBECQkEFXQVY45fgRMnu0JMByALwk0IFwAEQPKYQk4IEAMIukJGARh6Dmi1EEIERA7VxJic1NmInHRJDn4HuFLkFS"
		. "YA+2NRbw4DRRsDilugACAABBgP4BGQDJg+Egg8FbSACLA0mJwEiDwAACgHwkXABIiQADZkGJCA+FjQAFAABIhdIPjgCjAQAAZkQPbwAFE/7//2YP"
		. "bgQ1IwAOMfbzD34EPREAEkiJ90jBAOcFSQN9GEiFEPYPhSUAvkCE7QAPhaQDAABFhAD2dX9JOXUwDwiOvQQBntsPhCwCBwAIixNIjUICMEG7IgAA"
		. "DAByRIkAGkiLRxBNifgASInaSI2MJKBFAhiEAgfoCQoCMkEWuAEuACsCATxIjVAIArk6AiYTZokIKQBzdBQAEwQADrogAQEniVACDx9AAACLRxiD"
		. "+AEPhAIEAJiD+AYPhFshAgQFD4RyAEmD+FACD4TRhU14AQSLsANBul8AIAJG+QApAB5EDxEAZg/WgHgQZg9+cBgAMIMAUgBDUBzobwkDGA65AmSA"
		. "SAFGRIkISAiDxgGAeyAPj9xjgJGCrA+E6oCIAjPQQQEWiwtBuw0ABL4TAG4AHVEEgBsZSIkC0AJncQIxyUWFIOR+KWaQAAlBuAEAMwCDwQFIg8IC"
		. "AgATAEE5zHXnHrkBCgN+AUGA6UiNSAACGdJIiQuD4gAgg8JdZokQDxAotCTAABMPKLwCJIE6RA8ohCTgEcENgcT4gAFbXl8AXUFcQV1BXkFAX8Nm"
		. "Dx9EQAY7IFEwD4TmQEJFMRj2uXvBCsAshdT9QP//QYMHAcQyFkuAh4ADAoGIj93BBosAF41KAo1CA0JQjVQiA8EuD8MTiQDBg8ABOcJ19whBiQ8B"
		. "EOlo//9o/w8fQ0L3AJdBQrheLANBwU8APMA4AQKRR2PAagCRD4U2gFECko8GwwAbQAI4f1pIi8xPEEBiwGnoJ8NhRGBOuoGFQD+EfoUFQq4floRA"
		. "BYR12kB26LJAotzpUsAGwz3BI5bCI8BzEnTDcxBIQHZPAGIIAGoAA4VIiQjHIEAIZQBjwaFIDGGDe1AO6T5AJcRPi0APSDsN1vmAFYSiwMGTOw2p"
		. "AgPjApcEBawAA0g5wQ+EojPCAwBIOQCnV4WGAvABBb8iAFUAbiwAa4Eigis4gCIgSEC/bgBvAHcABkjAiXgISL9fBCZAA0QQv8Erx0AYAiaJ3Hgc"
		. "AUGBKwDBHkI7RNSJRNbpQ8AVDx+A4SFhQDUPiFP8gBLhD9YBARGLA0WNRCQBhDHS4WdIicFBQk2Ug8LgT8DhTwlE4DmE57rjTwNmiRFCNJKTYAhJ"
		. "O0A0jB0hAXFANA+PsyGEwDSDLuhKgCEu1eFRHwABRkJQAUGJBwI99gU9TZtjBwA9BkARogiOWCABs0BHwFxHEEUYIAoxQF1lJITnwVGLByBNoQmE"
		. "jjgABkAVgAvp/fvkOwRBuqFtSI1BBkGeu0Fu4BjBTWGPWQSBIGyJBABTYhDJYAYjGVM3ogfiJAMa1gAnCBqvBuXkNq3jJulmAAbkQMEC4gvCBQPp"
		. "XqAa5AjgQyWEB3KAB+nS5hODByMBA4Ea+egXw2sB6RKz5glBueEXSY1AiAZBuuIXRYlI4hcMRYmAnsFwVvr//wTppOUJ8g8QB0gAjVQkYGYP78kA"
		. "RTHJSIsNMesRoBGNhCThEEUxwAxBu6AMpqxIiwFIgIlUJDBIjZTiAQgPKYwCBUjHhCTGsCJnYQVUJCggFEAC1pBEAsAnnOYEqIQCRAZjgGnAAkQk"
		. "QGIHAAE4EYIDRCQgIQPyDxEIhCSIAAH/UDBIAItUJGgPtwJmYIXAD4S/4BiiJ7+5whITuWBD4K/kd0ngoaSJwSKhQYnAA0QBB0oEIK7BoQd14EFy"
		. "RbCJCOl5oAjhV0FBWVBED7bNoy6JoA/otJj4ICVYAgSD3MIAEiBMi0EYuAET6xQB4l6NSAFIOcIPJISEYYKJyOBgSMEA4QVJOUQI8HQ24mCjQhTp"
		. "gAiCpOmzV2AK4gZBMcsBDA5AMUEfoIGA1eEMAFJAuGaDeJD+AHXygKHp1yCBAGaQg8IDQYkXaQBQeV2CT0ygAoJPjfqKYYqQw1pCWYBI4MHBDpNh"
		. "uuBKuWzgAEG4oQCpIIQIx2CDdWB+SIHgYQAzQAbpc2EM40eLEgdAsyABobHQdfkNAQVdUArELDHS6OObUTbGBsXiDHMsdFRCcRJ1wQa7ZcYGdABy"
		. "h+EfIndwAFgG6QWxTYXwAm2xWIsV2fUAEEq5AgOJgDtQCoMCSBgI6dzQBfAtBOnTZ4MAIwhtSugQwYphMKydYQK+8iThD1ENuVtRF8Q99/IDBemK"
		. "FgKCAdUyayDCAQA1a35QA+AACALpUIEAiwfp0AEAGpBBV0FWQVUAQVRVV1ZTSIMA7EhIi2kgSYkAzEmJ0kiF7Q8MjlDRHyAkEEyLcQFgKnkYRTHb"
		. "SL4UzcwDAEjgJAjrJKFxH005XCSwSuUhKgSDw6BSxyBMOd0YD4QPAATzAd5+24HRFjHSRTH/ZpA0ADhIhcl5CUj3CNlBv5INjVwkNhhBuRTiUXFX"
		. "yEWJAM1Ig+sCQYPpgAFI9+ZIweoAbgAEkkgBwEgpwQCNQTBIidFmiQJDIXh10k1jyUUAhP90F0WNTf4EuC3xUWPJZkKJCERMENIASItcJAAISo0M"
		. "S2ZBOdACD4VbkE64UTVwKQgPtxRzXUE7VAJQ/g+FP7ABZiAF5whJiTjiMEiDxEgDf4LgMk8QQQ+3CgEwABFmOcoPhQYHRQXzATEEI2aFyXQSt+kQ"
		. "hfXRo8DrquP2PCACD4TKUAGABJMIEYAATAL+MAV0u+lasYABkAoAUho4AE1BHLoT0Qm2GJAlTCQoAEyLCUmJ00iJQONNhcl4e/ANTCCJyEyJyfgT"
		. "SYkC0SMUTInQg8EwgVASDFNJg+oBchSkSJggAkNNQSamkRx/gKoQCfEYcEfCCbAEs0cIEA+3SP7QC3XlMQzASUNHoBI4W17DI/IPghxBujAyCmdm"
		. "IwMA8whI9+5RAMH4AD9IwfoCSCnCAWEJQY0EQkQpyMHQCWaJREv+EUdxH0FACc2D6AK6URy5QaIcmGaJFERVCoXiWlAXQYsQEhzzOnFG/sJ1RlBe"
		. "oDdjCfMTYC4REAlQSoSh0BpIiwJBIrrVq0mJEVAUEA8UtwGCWIISo7Yd6QDj//9MjRU28WHxR2aD+CKwZlHBgyD4Bw+OjJAAjVAA+GaD+hoPh6gB"
		. "EAUPt9JJYxSS4EwB0v/i8A5wGPCNwUACSYsBvlwQBdCNIdIGBGaJMAEHiXih8hUPt0ECRVybQgMiIsAESYsR8VNJifIBw7+JAqAoABbwNCECkv8y"
		. "GgG6cQW7clOfU6EFcgVYAmAmkHIC18V5AmZ/AoJmLvah8QKWp/MC8wpu/grpTzKsc/J88AJ0e7YCdKO5AiOr865xAlN2AmJ/AvuSqGFRFVwPhV8A"
		. "ExEDIWdWC0EAWwvpycExEk2/q7ID85yEsCuPhQzuiQ8HAVwrBJAeSI0VSe8RcdzDg+Mgu740GkCJw2bB6wTTADxZ0gDoDBAB8C7AQwEc0hpAABQC"
		. "AgadAwZjBQ4IMQXADOMFcAbpJxF3CY1QgTAiIQ+GgmQBRoP4Hw+GsStVQQ5sUh5aUB4ZAB7ppvJxb/YYQYugAwGACvOALFEphWrgAQAu4AChIGXw"
		. "cRDTAOvwdJTwECRj9xnwAATpn/euAWHpFo/wAIISZoACjVDgkZAJXg+HUUjpaxABAflG"
		static Code := false
		if ((A_PtrSize * 8) != 64) {
			Throw Exception("_LoadLib64Bit does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		}
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2021 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if (!Code) {
			CompressedSize := VarSetCapacity(DecompressionBuffer, 5343, 0)
			if !DllCall("Crypt32\CryptStringToBinary", "Str", CodeBase64, "UInt", 0, "UInt", 1, "Ptr", &DecompressionBuffer, "UInt*", CompressedSize, "Ptr", 0, "Ptr", 0, "UInt")
				throw Exception("Failed to convert MCLib b64 to binary")
			if !(pCode := DllCall("GlobalAlloc", "UInt", 0, "Ptr", 7984, "Ptr"))
				throw Exception("Failed to reserve MCLib memory")
			DecompressedSize := 0
			if (DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", pCode, "UInt", 7984, "Ptr", &DecompressionBuffer, "UInt", CompressedSize, "UInt*", DecompressedSize, "UInt"))
				throw Exception("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
			OldProtect := 0
			if !DllCall("VirtualProtect", "Ptr", pCode, "Ptr", 7984, "UInt", 0x40, "UInt*", OldProtect, "UInt")
				Throw Exception("Failed to mark MCLib memory as executable")
			Exports := {}
			for ExportName, ExportOffset in {"bBoolsAsInts": 0, "bEmptyObjectsAsArrays": 16, "bEscapeUnicode": 32, "bNullsAsStrings": 48, "dumps": 64, "fnCastString": 304, "fnGetObj": 320, "loads": 336, "objFalse": 3360, "objNull": 3376, "objTrue": 3392} {
				Exports[ExportName] := pCode + ExportOffset
			}
			Code := Exports
		}
		return Code
	}
	_LoadLib() {
		return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
	}

	Dump(obj, pretty := 0)
	{
		this._init()
		if (!IsObject(obj))
			throw Exception("Input must be object")
		size := 0
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr", 0, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		VarSetCapacity(buf, size*2+2, 0)
		DllCall(this.lib.dumps, "Ptr", &obj, "Ptr*", &buf, "Int*", size
		, "Int", !!pretty, "Int", 0, "CDecl Ptr")
		return StrGet(&buf, size, "UTF-16")
	}

	Load(ByRef json)
	{
		this._init()

		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		VarSetCapacity(pJson, A_PtrSize)
		NumPut(&_json, &pJson, 0, "Ptr")

		VarSetCapacity(pResult, 24)

		if (r := DllCall(this.lib.loads, "Ptr", &pJson, "Ptr", &pResult , "CDecl Int")) || ErrorLevel
		{
			throw Exception("Failed to parse JSON (" r "," ErrorLevel ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson)-&_json)//2, Chr(NumGet(NumGet(pJson), "short"))))
		}

		result := ComObject(0x400C, &pResult)[]
		if (IsObject(result))
			ObjRelease(&result)
		return result
	}

	True[]
	{
		get
		{
			static _ := {"value": true, "name": "true"}
			return _
		}
	}

	False[]
	{
		get
		{
			static _ := {"value": false, "name": "false"}
			return _
		}
	}

	Null[]
	{
		get
		{
			static _ := {"value": "", "name": "null"}
			return _
		}
	}
}

