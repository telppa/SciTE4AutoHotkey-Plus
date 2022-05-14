;
; SciTE4AutoHotkey Autorun Script
;

#NoEnv
#NoTrayIcon
#SingleInstance Force
SetWorkingDir, %A_ScriptDir%

公用:
	; oSciTE 是超级全局变量
	global oSciTE
	; 屏蔽退出时的无用报错
	ComObjError(false)
	
	if (!oSciTE := GetSciTEInstance())
		ExitApp
	
	SciTE_Hwnd := oSciTE.SciTEHandle
	
	OnMessage(0x004A, "Receive_WM_COPYDATA")
	
	bTillaGotoEnabled := oSciTE.ResolveProp("tillagoto.enable") + 0
	if bTillaGotoEnabled
		Run, "%A_AhkPath%" TillaGoto.ahk
	
	UserAutorun := oSciTE.UserDir "\Autorun.ahk"
	IfExist, %UserAutorun%
		Run, "%A_AhkPath%" "%UserAutorun%"
	
	Run, 安装字体\安装字体.ahk
	
	Run, 自动更新\自动更新.ahk
	
	gosub, 中文输入法窗口组  ; 智能Tab 智能标点 使用
	
	gosub, 智能F1
	gosub, 智能Tab
	gosub, 智能编码
	gosub, 智能标点
	
	WinWaitClose, ahk_id %SciTE_Hwnd%  ; 随 SciTE 退出。
	WinClose, ahk_pid %中文帮助PID%    ; 退出时关闭帮助。
	ExitApp
return

中文输入法窗口组:
	; 以下3款输入法无法区分状态栏和文字框
	; GroupAdd, IME_CN, ahk_exe iFlyInput.exe         ; 讯飞拼音（新版 class = BaseGui 旧版 class = PinyinputComposition ）
	; GroupAdd, IME_CN, ahk_class GadgetWindow_10000  ; 谷歌拼音
	; GroupAdd, IME_CN, ahk_class APNGWndCls          ; 必应拼音
	GroupAdd, IME_CN, inputBar ahk_class BAIDU_CLASS_IME_87C946A9-47CC-4068-A02B-9381C1F11B24  ; 百度拼音（无法与五笔区分）
	GroupAdd, IME_CN, ahk_class QQPinyinCompWndTSF                                             ; QQ拼音
	GroupAdd, IME_CN, ahk_class QQWubiCompWndII                                                ; QQ五笔
	GroupAdd, IME_CN, ahk_class SoPY_Comp                                                      ; 搜狗拼音
	GroupAdd, IME_CN, ahk_class SoWB_Comp                                                      ; 搜狗五笔
	GroupAdd, IME_CN, ahk_class Microsoft.IME.UIManager.CandidateWindow.Host                   ; 微软拼音（新版 class = ApplicationFrameWindow 控件 text = Microsoft Text Input Application 新旧版都无法与五笔区分）
	GroupAdd, IME_CN, ahk_class INPUT_MAIN_WND_CLASS                                           ; 2345拼音
	GroupAdd, IME_CN, ahk_class PalmInputUICand                                                ; 手心拼音
return

; 响应 scite 的事件并分发
Receive_WM_COPYDATA(wParam, lParam)
{
	StringAddress := NumGet(lParam + 2*A_PtrSize)
	CopyOfData := StrGet(StringAddress)
	event := StrSplit(CopyOfData, ":", , 2)
	
	switch event[1]
	{
		case "closed":更新fileTransformed(event[2])  ; 智能编码
	}
	
	return true
}

#Include %A_LineFile%\..\智能操作\智能F1.ahk
#Include %A_LineFile%\..\智能操作\智能Tab.ahk
#Include %A_LineFile%\..\智能操作\智能编码.ahk
#Include %A_LineFile%\..\智能操作\智能标点.ahk