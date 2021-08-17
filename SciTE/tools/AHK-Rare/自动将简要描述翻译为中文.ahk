#NoEnv
#SingleInstance force
ListLines, Off
SetBatchLines, -1

MsgBox 0x41, 注意, AHK-Rare 最新汉化版被集成于 “SciTE4AHK增强版” 中。`n`n点击确定后，将通过网络对文件进行汉化，因此运行一次可能需要10分钟甚至更久，在此期间推荐看看 “SciTE4AHK增强版” 的各种特性，它是最适合中文用户的 AHK IDE。`n`n本自动汉化程序最好运行2遍，然后对比两遍生成文件的异同，以做校正。（自带的 “AHK-Rare中文.txt” 就是这样得来的）`n
IfMsgBox, Cancel
	ExitApp

Run, https://github.com/telppa/SciTE4AutoHotkey-Plus

FileRead, txt, AHK-Rare.txt

;根据标记“;<01.01.000001>……;</01.01.000001>”提取段落。
ret:=GlobalRegExMatch(txt,"m)(*ANYCRLF);<[\d\.]+>[\s\S]*?;</[\d\.]+>",1)

obj_储存翻译后的文本:=[]		;正则对象只读不可写，因此需要单独建立一个可写的对象。
for k, v in ret
	obj_储存翻译后的文本.Push(ret[A_Index].Value)

;再来一个对象存原版文字，待会替换时需要用到。
obj_储存原版文本:=obj_储存翻译后的文本.Clone()

for k, v in obj_储存翻译后的文本
{
	;按理说应该使用规则“(?<=;-- ).*”，但是原版有几十条描述缺少那个空格，所以必须使用“(?<=;--).*”。
	RegExMatch(v, "m)(*ANYCRLF)(?<=;--).*", OutputVar)
	loop
	{
		翻译好的文本:=GoogleTranslate(OutputVar)
		;检查翻译是否成功，不成功就重复5遍，直到成功为止。
		if (翻译好的文本!="")
			break
		else if (A_Index>5)
			break
	}
	obj_储存翻译后的文本[k]:=StrReplace(v, OutputVar, " " 翻译好的文本, OutputVarCount, 1)		;翻译好的文本前面须添加一个空格。
}

for k, v in obj_储存原版文本
	txt:=StrReplace(txt, v, obj_储存翻译后的文本[A_Index], OutputVarCount, 1)
FileAppend, %txt%, AHK-Rare中文.txt, utf-8

ExitApp

#Include <GlobalRegExMatch>
#Include <谷歌翻译>