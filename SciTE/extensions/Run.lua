--[[
    本文件编码必须使用 utf-8 无头，因为下面代码中的字符串都是按 utf-8 无头为基础做的编码转换！
    
    F5 运行命令带了 /ErrorStdOut 参数，可以捕获标准输出。
    因此使用 F5 运行的程序在没退出前，会一直占用 scite 的命令队列，导致无法接收新命令。
    具体表现就是按了 F5 之后，那么 菜单栏 - 工具 中很多选项就是灰的，同时右键菜单很多功能也失效了。
    
    subsystem:immediate 可以让命令不排队，立刻运行，但它不支持传递变量。
    lua 原生的 os.execute() 会产生黑框且无法去掉，引入 lua 三方库 alien 可解决。
--]]

require 'alien\\alien'

-- https://blog.csdn.net/hloveloveu/article/details/5867233
local kernel32 = alien.load('kernel32.dll')
kernel32.MultiByteToWideChar:types{ abi="stdcall"; ret="int";
    "uint" --[[CodePage]], "ulong" --[[dwFlags]], "pointer" --[[lpMultiByteStr]],
    "int" --[[cbMultiByte]], "pointer" --[[lpWideCharStr]], "int" --[[cchWideChar]] }
local MultiByteToWideChar = kernel32.MultiByteToWideChar
function UTF8_To_UTF16(str)
    local codePage = 65001
    local flags    = 0
    local wide_len = MultiByteToWideChar(codePage, flags, str, -1, nil, 0)
    local buffer   = alien.buffer(wide_len * 2) -- 大小必须为 wide_len * 2 ， wide_len 也能运行，但极其容易崩溃
    local res      = MultiByteToWideChar(codePage, flags, str, -1, buffer, wide_len)
    -- 调试用
    -- print(buffer[1]..'|'..buffer[2]..'|'..buffer[3]..'|'..buffer[4]..'|'..buffer[5]..'|'..buffer[6])
		return buffer
end

local shell32 = alien.load('Shell32.dll')
shell32.ShellExecuteW:types("pointer","pointer","pointer","pointer","pointer","pointer","int")
local exec = shell32.ShellExecuteW
function Run(cmd)
    
    -- 因为本文件编码是 utf-8 ，所以本文件内字符串都是 utf-8
    -- ShellExecuteW 的第二个参数要求的是 utf-16 的字符串，所以需要转换，这很容易被忽视！
    local open = UTF8_To_UTF16("open")
    
    -- 实际就是运行这个命令行 "AutoHotkeyU32.exe" /CP65001 "SelectFileInExplorer.ahk" "目标.ext"
    if cmd == "SelectFileInExplorer" then
        
        local exe      = '"'..props['LocalAHK']..'"'
        local ahkfile  = '/CP65001 "'..props['SciteDefaultHome']..'/tools/右键菜单/SelectFileInExplorer.ahk'..'"'
        local ahkparam = '"'..props['FilePath']..'"'
        local ahk      = ahkfile.." "..ahkparam
        
        -- 转换斜杠 \ -> / 不然会被转义引起预期外的错误
        exe = string.gsub(exe,"\\","\/")
        ahk = string.gsub(ahk,"\\","\/")
        
        -- 转换编码 从 scite 传过来的参数值编码是 utf-8
        exe = UTF8_To_UTF16(exe)
        ahk = UTF8_To_UTF16(ahk)
        
        exec(0, open, exe, ahk, 0, 0)
    end
    
    -- 实际就是运行这个命令行 "AutoHotkeyU32.exe" /CP65001 "SUtility.ahk" /addScriptlet
    if cmd == "addScriptlet" then
        
        local exe      = '"'..props['LocalAHK']..'"'
        local ahkfile  = '/CP65001 "'..props['SciteDefaultHome']..'/tools/SUtility.ahk'..'"'
        local ahkparam = "/addScriptlet"
        local ahk      = ahkfile.." "..ahkparam
        
        -- 转换斜杠 \ -> / 不然会被转义引起预期外的错误
        exe = string.gsub(exe,"\\","\/")
        ahk = string.gsub(ahk,"\\","\/")
        
        -- 转换编码 从 scite 传过来的参数值编码是 utf-8
        exe = UTF8_To_UTF16(exe)
        ahk = UTF8_To_UTF16(ahk)
        
        exec(0, open, exe, ahk, 0, 0)
    end
    
    -- 实际就是运行这个命令行 "AutoHotkeyU32.exe" /CP65001 "GotoDefine.ahk"
    if cmd == "GotoDefine" then
        
        local exe      = '"'..props['LocalAHK']..'"'
        local ahkfile  = '/CP65001 "'..props['SciteDefaultHome']..'/tools/右键菜单/GotoDefine.ahk'..'"'
        local ahk      = ahkfile
        
        -- 转换斜杠 \ -> / 不然会被转义引起预期外的错误
        exe = string.gsub(exe,"\\","\/")
        ahk = string.gsub(ahk,"\\","\/")
        
        -- 转换编码 从 scite 传过来的参数值编码是 utf-8
        exe = UTF8_To_UTF16(exe)
        ahk = UTF8_To_UTF16(ahk)
        
        exec(0, open, exe, ahk, 0, 0)
    end
    
    -- 实际就是运行这个命令行 "AutoHotkeyU32.exe" /CP65001 "OpenInAnotherInstance.ahk" "目标.ext"
    if cmd == "OpenInAnotherInstance" then
        
        local exe      = '"'..props['LocalAHK']..'"'
        local ahkfile  = '/CP65001 "'..props['SciteDefaultHome']..'/tools/右键菜单/OpenInAnotherInstance.ahk'..'"'
        local ahkparam = '"'..props['FilePath']..'"'
        local ahk      = ahkfile.." "..ahkparam
        
        -- 转换斜杠 \ -> / 不然会被转义引起预期外的错误
        exe = string.gsub(exe,"\\","\/")
        ahk = string.gsub(ahk,"\\","\/")
        
        -- 转换编码 从 scite 传过来的参数值编码是 utf-8
        exe = UTF8_To_UTF16(exe)
        ahk = UTF8_To_UTF16(ahk)
        
        exec(0, open, exe, ahk, 0, 0)
    end
    
end